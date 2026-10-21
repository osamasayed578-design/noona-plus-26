-- =============================================================================
-- NOONA PLUS ERP | NOONA_PLATFORM_PKG  (الحزمة 01)
--   * تجهيز المؤسسة Provisioning: آلي، Idempotent، قابل للاستئناف بخطوات مسجلة (10.4)
--   * دورة حالة المؤسسة مع منع الانتقالات غير المسموحة والحجز القانوني
--   * فحص حدود الاشتراك/الترخيص (الشركات، الفروع، المستخدمون، Slots في On-Premises)
--   * الشركات والفروع: الإنشاء، فحوصات ما قبل التفعيل، التفعيل مع Configuration Snapshot
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_PLATFORM_PKG AUTHID DEFINER AS

  -- ---------------------------------------------------------- Tenant (مسؤول المنصة)
  FUNCTION provision_tenant(
    p_tenant_code      IN VARCHAR2,
    p_tenant_slug      IN VARCHAR2,
    p_name_ar          IN VARCHAR2,
    p_name_en          IN VARCHAR2,
    p_country_code     IN VARCHAR2,
    p_base_currency    IN VARCHAR2,
    p_admin_username   IN VARCHAR2,
    p_admin_email      IN VARCHAR2,
    p_admin_name       IN VARCHAR2,
    p_company_code     IN VARCHAR2,
    p_company_name_ar  IN VARCHAR2,
    p_idempotency_key  IN VARCHAR2,
    p_is_trial         IN VARCHAR2 DEFAULT 'N',
    p_language         IN VARCHAR2 DEFAULT 'ar',
    p_timezone         IN VARCHAR2 DEFAULT 'Asia/Riyadh',
    p_deployment_model IN VARCHAR2 DEFAULT 'SAAS',
    p_cell_code        IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE change_tenant_status(p_tenant_id IN NUMBER, p_new_status IN VARCHAR2, p_reason IN VARCHAR2);
  PROCEDURE set_legal_hold(p_tenant_id IN NUMBER, p_hold IN VARCHAR2, p_reason IN VARCHAR2);

  -- On-Premises: هل يسمح الترخيص بإضافة Tenant؟ (التعليق لا يحرر Slot - BR-010)
  FUNCTION tenant_slot_available RETURN VARCHAR2;

  -- ---------------------------------------------------------- Entitlements (داخل المؤسسة)
  -- يرجع الحد الصلب الفعلي للمقياس (NULL = غير محدود)
  FUNCTION hard_limit(p_metric_code IN VARCHAR2) RETURN NUMBER;
  PROCEDURE assert_within_limit(p_metric_code IN VARCHAR2, p_current_count IN NUMBER);
  FUNCTION module_enabled(p_module_code IN VARCHAR2) RETURN VARCHAR2;

  -- ---------------------------------------------------------- Companies & branches
  FUNCTION create_company(
    p_code                IN VARCHAR2,
    p_legal_name_ar       IN VARCHAR2,
    p_legal_name_en       IN VARCHAR2,
    p_country_code        IN VARCHAR2,
    p_functional_currency IN VARCHAR2,
    p_business_group_id   IN NUMBER   DEFAULT NULL,
    p_timezone            IN VARCHAR2 DEFAULT NULL,
    p_language            IN VARCHAR2 DEFAULT 'ar') RETURN NUMBER;

  FUNCTION create_branch(
    p_company_id     IN NUMBER,
    p_code           IN VARCHAR2,
    p_name_ar        IN VARCHAR2,
    p_name_en        IN VARCHAR2,
    p_branch_type    IN VARCHAR2,
    p_is_head_office IN VARCHAR2 DEFAULT 'N',
    p_country_code   IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  -- ينفذ الفحوصات ويسجلها في ORG_COMPANY_CHECK؛ يرجع عدد الفحوصات الفاشلة
  FUNCTION run_activation_checks(p_company_id IN NUMBER) RETURN NUMBER;
  PROCEDURE waive_check(p_company_id IN NUMBER, p_check_code IN VARCHAR2, p_reason IN VARCHAR2);
  PROCEDURE activate_company(p_company_id IN NUMBER);
  PROCEDURE change_company_status(p_company_id IN NUMBER, p_new_status IN VARCHAR2, p_reason IN VARCHAR2);
  PROCEDURE close_branch(p_branch_id IN NUMBER, p_reason IN VARCHAR2);
END NOONA_PLATFORM_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PLATFORM_PKG AS

  -- ================================================================ helpers
  FUNCTION tenant_transition_ok(p_from VARCHAR2, p_to VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN p_from || '>' || p_to IN (
      'PROSPECT>TRIAL', 'PROSPECT>PENDING_ACTIVATION', 'TRIAL>PENDING_ACTIVATION',
      'TRIAL>ACTIVE', 'TRIAL>READ_ONLY', 'TRIAL>ARCHIVED',
      'PENDING_ACTIVATION>ACTIVE', 'PENDING_ACTIVATION>CLOSED', 'ACTIVE>GRACE_PERIOD',
      'ACTIVE>READ_ONLY', 'ACTIVE>SUSPENDED', 'GRACE_PERIOD>ACTIVE',
      'GRACE_PERIOD>READ_ONLY', 'READ_ONLY>ACTIVE', 'READ_ONLY>SUSPENDED',
      'SUSPENDED>ACTIVE', 'SUSPENDED>ARCHIVED', 'ARCHIVED>ACTIVE',
      'ARCHIVED>CLOSED');
  END tenant_transition_ok;

  FUNCTION company_transition_ok(p_from VARCHAR2, p_to VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    -- READY_FOR_REVIEW → ACTIVE عبر activate_company فقط
    RETURN p_from || '>' || p_to IN (
      'DRAFT>UNDER_CONFIGURATION', 'UNDER_CONFIGURATION>READY_FOR_REVIEW', 'READY_FOR_REVIEW>UNDER_CONFIGURATION',
      'ACTIVE>SUSPENDED', 'SUSPENDED>ACTIVE', 'SUSPENDED>INACTIVE',
      'INACTIVE>ACTIVE', 'ACTIVE>CLOSURE_REQUESTED', 'INACTIVE>CLOSURE_REQUESTED',
      'CLOSURE_REQUESTED>ACTIVE', 'CLOSURE_REQUESTED>UNDER_LIQUIDATION', 'UNDER_LIQUIDATION>TRANSACTIONS_BLOCKED',
      'TRANSACTIONS_BLOCKED>FINANCIALLY_CLOSED', 'FINANCIALLY_CLOSED>LEGALLY_CLOSED', 'LEGALLY_CLOSED>CLOSED',
      'CLOSED>ARCHIVED');
  END company_transition_ok;

  PROCEDURE log_step(p_run_id NUMBER, p_tenant_id NUMBER, p_no NUMBER, p_code VARCHAR2, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    MERGE INTO plt_provisioning_step s
    USING (SELECT p_run_id run_id, p_no step_no FROM dual) x
       ON (s.run_id = x.run_id AND s.step_no = x.step_no)
     WHEN MATCHED THEN UPDATE SET s.status_code = 'DONE', s.attempts = s.attempts + 1,
                                  s.finished_at = SYSTIMESTAMP, s.result_info = p_info
     WHEN NOT MATCHED THEN INSERT (tenant_id, run_id, step_no, step_code, attempts, started_at, finished_at,
                                   result_info, status_code)
          VALUES (p_tenant_id, p_run_id, p_no, p_code, 1, SYSTIMESTAMP, SYSTIMESTAMP, p_info, 'DONE');
    UPDATE plt_provisioning_run SET last_step_no = GREATEST(NVL(last_step_no, 0), p_no) WHERE id = p_run_id;
  END log_step;

  PROCEDURE insert_status_hist(p_tenant_id NUMBER, p_from VARCHAR2, p_to VARCHAR2, p_reason VARCHAR2) IS
  BEGIN
    INSERT INTO plt_tenant_status_hist (tenant_id, from_status, to_status, reason, approved_by)
    VALUES (p_tenant_id, p_from, p_to, p_reason, NOONA_CTX_PKG.current_user_name);
  END insert_status_hist;

  -- ================================================================ Tenant
  FUNCTION tenant_slot_available RETURN VARCHAR2 IS
    l_max   NUMBER;
    l_used  NUMBER;
  BEGIN
    BEGIN
      SELECT max_tenants INTO l_max
        FROM (SELECT max_tenants FROM plt_onprem_license
               WHERE status_code IN ('ACTIVE', 'GRACE') ORDER BY valid_from DESC)
       WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 'Y';                         -- SaaS: لا يوجد ترخيص Slots
    END;
    SELECT COUNT(*) INTO l_used
      FROM plt_tenant
     WHERE status_code IN ('TRIAL', 'PENDING_ACTIVATION', 'ACTIVE', 'GRACE_PERIOD', 'READ_ONLY', 'SUSPENDED', 'ARCHIVED');
    RETURN NOONA_CORE_PKG.yn(l_used < l_max);
  END tenant_slot_available;

  FUNCTION provision_tenant(
    p_tenant_code      IN VARCHAR2,
    p_tenant_slug      IN VARCHAR2,
    p_name_ar          IN VARCHAR2,
    p_name_en          IN VARCHAR2,
    p_country_code     IN VARCHAR2,
    p_base_currency    IN VARCHAR2,
    p_admin_username   IN VARCHAR2,
    p_admin_email      IN VARCHAR2,
    p_admin_name       IN VARCHAR2,
    p_company_code     IN VARCHAR2,
    p_company_name_ar  IN VARCHAR2,
    p_idempotency_key  IN VARCHAR2,
    p_is_trial         IN VARCHAR2 DEFAULT 'N',
    p_language         IN VARCHAR2 DEFAULT 'ar',
    p_timezone         IN VARCHAR2 DEFAULT 'Asia/Riyadh',
    p_deployment_model IN VARCHAR2 DEFAULT 'SAAS',
    p_cell_code        IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_tenant   NUMBER;
    l_run      NUMBER;
    l_run_st   plt_provisioning_run.status_code%TYPE;
    l_group    NUMBER;
    l_company  NUMBER;
    l_branch   NUMBER;
    l_user     NUMBER;
    l_party    NUMBER;
    l_member   NUMBER;
    l_role     NUMBER;
    l_grant    NUMBER;
    l_cell     NUMBER;
    l_region   NUMBER;
    l_pack     NUMBER;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.begin_system;

    -- 0) Idempotency: نفس المفتاح يعيد نفس المؤسسة أو يستأنف من آخر خطوة
    BEGIN
      SELECT r.tenant_id, r.id, r.status_code INTO l_tenant, l_run, l_run_st
        FROM plt_provisioning_run r WHERE r.idempotency_key = p_idempotency_key AND r.run_type = 'CREATE';
      IF l_run_st = 'COMPLETED' THEN
        NOONA_CORE_PKG.end_system;
        RETURN l_tenant;
      END IF;
      UPDATE plt_provisioning_run SET status_code = 'RUNNING', error_message = NULL WHERE id = l_run;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_run := NULL;
    END;

    -- 1) RESERVE_TENANT
    IF l_run IS NULL THEN
      NOONA_CORE_PKG.assert(tenant_slot_available = 'Y', 'NOONA-PLT-010',
        'تم بلوغ الحد الأقصى للمؤسسات في الترخيص', 'Licensed tenant limit reached');
      BEGIN
        SELECT c.id, c.region_id INTO l_cell, l_region
          FROM plt_cell c
         WHERE c.code = p_cell_code OR (p_cell_code IS NULL AND c.status_code = 'ACTIVE'
               AND c.region_id IN (SELECT id FROM plt_region WHERE country_code = p_country_code))
         FETCH FIRST 1 ROWS ONLY;
      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      END;
      INSERT INTO plt_tenant (tenant_code, tenant_slug, name_ar, name_en, status_code, deployment_model,
                              isolation_tier, home_region_id, cell_id, country_code, default_language,
                              default_timezone, base_currency)
      VALUES (UPPER(p_tenant_code), LOWER(p_tenant_slug), p_name_ar, p_name_en, 'PENDING_ACTIVATION',
              p_deployment_model, CASE WHEN p_deployment_model = 'ON_PREMISES' THEN 'ON_PREMISES' ELSE 'SHARED' END,
              l_region, l_cell, p_country_code, p_language, p_timezone, p_base_currency)
      RETURNING id INTO l_tenant;
      INSERT INTO plt_provisioning_run (tenant_id, run_type, idempotency_key, started_at, status_code)
      VALUES (l_tenant, 'CREATE', p_idempotency_key, SYSTIMESTAMP, 'RUNNING')
      RETURNING id INTO l_run;
      insert_status_hist(l_tenant, NULL, 'PENDING_ACTIVATION', 'Provisioning started');
      log_step(l_run, l_tenant, 1, 'RESERVE_TENANT', '{"tenant_id":' || l_tenant || '}');
    END IF;

    -- 2) LEGAL_STRUCTURE: مجموعة + شركة + فرع رئيسي (كل خطوة تفحص الوجود أولاً)
    BEGIN
      SELECT id INTO l_group FROM org_business_group WHERE tenant_id = l_tenant AND code = 'MAIN';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO org_business_group (tenant_id, code, name_ar, name_en, consolidation_currency, status_code)
      VALUES (l_tenant, 'MAIN', p_name_ar, p_name_en, p_base_currency, 'ACTIVE')
      RETURNING id INTO l_group;
    END;
    BEGIN
      SELECT id INTO l_company FROM org_company WHERE tenant_id = l_tenant AND code = UPPER(p_company_code);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      SELECT MAX(id) INTO l_pack FROM loc_country_pack WHERE country_code = p_country_code;
      INSERT INTO org_company (tenant_id, business_group_id, code, legal_name_ar, legal_name_en, country_code,
                               country_pack_id, functional_currency, default_language, timezone_code, status_code)
      VALUES (l_tenant, l_group, UPPER(p_company_code), p_company_name_ar, p_name_en, p_country_code,
              l_pack, p_base_currency, p_language, p_timezone, 'UNDER_CONFIGURATION')
      RETURNING id INTO l_company;
    END;
    BEGIN
      SELECT id INTO l_branch FROM org_branch WHERE tenant_id = l_tenant AND company_id = l_company AND code = 'HQ';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO org_branch (tenant_id, company_id, code, name_ar, name_en, branch_type, is_head_office,
                              country_code, timezone_code, currency_code, status_code)
      VALUES (l_tenant, l_company, 'HQ', 'المركز الرئيسي', 'Head Office', 'HEAD_OFFICE', 'Y',
              p_country_code, p_timezone, p_base_currency, 'ACTIVE')
      RETURNING id INTO l_branch;
    END;
    log_step(l_run, l_tenant, 2, 'LEGAL_STRUCTURE', '{"company_id":' || l_company || ',"branch_id":' || l_branch || '}');

    -- 3) TENANT_ADMIN: حساب + طرف + عضوية
    BEGIN
      SELECT id INTO l_user FROM sec_user WHERE username = UPPER(p_admin_username);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO sec_user (username, email, display_name, user_type, preferred_language, timezone_code,
                            mfa_required, status_code)
      VALUES (UPPER(p_admin_username), LOWER(p_admin_email), p_admin_name, 'TENANT_ADMIN', p_language,
              p_timezone, 'Y', 'ACTIVE')
      RETURNING id INTO l_user;
    END;
    BEGIN
      SELECT id, person_party_id INTO l_member, l_party
        FROM sec_user_membership WHERE tenant_id = l_tenant AND user_id = l_user;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO pty_party (tenant_id, party_no, party_type, display_name_ar, country_code)
      VALUES (l_tenant, 'P-' || LPAD(l_user, 6, '0'), 'PERSON', p_admin_name, p_country_code)
      RETURNING id INTO l_party;
      INSERT INTO sec_user_membership (tenant_id, user_id, person_party_id, default_company_id, default_branch_id,
                                       clearance_level, is_tenant_admin, status_code)
      VALUES (l_tenant, l_user, l_party, l_company, l_branch, 'SECRET', 'Y', 'ACTIVE')
      RETURNING id INTO l_member;
    END;
    log_step(l_run, l_tenant, 3, 'TENANT_ADMIN', '{"user_id":' || l_user || ',"membership_id":' || l_member || '}');

    -- 4) ADMIN_ROLE: دور مسؤول المؤسسة بكل صلاحيات المؤسسة (عدا إعداد المنصة)
    BEGIN
      SELECT id INTO l_role FROM sec_role WHERE tenant_id = l_tenant AND code = 'TENANT_ADMIN';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO sec_role (tenant_id, code, name_ar, name_en, role_type, is_privileged, status_code)
      VALUES (l_tenant, 'TENANT_ADMIN', 'مسؤول المؤسسة', 'Tenant Administrator', 'TENANT', 'Y', 'ACTIVE')
      RETURNING id INTO l_role;
      INSERT INTO sec_role_permission (tenant_id, role_id, permission_id, effect)
      SELECT l_tenant, l_role, p.id, 'ALLOW' FROM sec_permission p WHERE p.action_code <> 'CONFIGURE';
    END;
    BEGIN
      SELECT id INTO l_grant FROM sec_role_grant
       WHERE tenant_id = l_tenant AND membership_id = l_member AND role_id = l_role AND status_code = 'ACTIVE';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO sec_role_grant (tenant_id, membership_id, role_id, grant_source, reason, approved_by, status_code)
      VALUES (l_tenant, l_member, l_role, 'MANUAL', 'Tenant provisioning', NOONA_CTX_PKG.current_user_name, 'ACTIVE')
      RETURNING id INTO l_grant;
      INSERT INTO sec_data_scope (tenant_id, role_grant_id, scope_type) VALUES (l_tenant, l_grant, 'ALL_TENANT');
    END;
    log_step(l_run, l_tenant, 4, 'ADMIN_ROLE');

    -- 5) TENANT_DEFAULTS: أنواع أسعار الصرف وشروط الدفع الأساسية
    MERGE INTO ref_rate_type t
    USING (SELECT 'OFFICIAL' code, 'السعر الرسمي' name_ar, 'Official' name_en, 'OFFICIAL' cat FROM dual UNION ALL
           SELECT 'MANUAL', 'سعر يدوي معتمد', 'Manual approved', 'MANUAL' FROM dual UNION ALL
           SELECT 'CLOSING', 'سعر الإقفال', 'Closing', 'CLOSING' FROM dual UNION ALL
           SELECT 'AVERAGE', 'السعر المتوسط', 'Average', 'AVERAGE' FROM dual) s
       ON (t.tenant_id = l_tenant AND t.code = s.code)
     WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, rate_category, requires_approval)
          VALUES (l_tenant, s.code, s.name_ar, s.name_en, s.cat, CASE WHEN s.cat = 'MANUAL' THEN 'Y' ELSE 'N' END);
    MERGE INTO ref_payment_term t
    USING (SELECT 'IMMEDIATE' code, 'فوري' name_ar, 'Immediate' name_en, 0 days FROM dual UNION ALL
           SELECT 'NET30', 'صافي 30 يوماً', 'Net 30', 30 FROM dual UNION ALL
           SELECT 'NET60', 'صافي 60 يوماً', 'Net 60', 60 FROM dual) s
       ON (t.tenant_id = l_tenant AND t.code = s.code)
     WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, due_days)
          VALUES (l_tenant, s.code, s.name_ar, s.name_en, s.days);
    log_step(l_run, l_tenant, 5, 'TENANT_DEFAULTS');

    -- 6) HEALTH_CHECK ثم التفعيل (لا تصبح المؤسسة نشطة قبل نجاح الفحوص)
    DECLARE
      l_ok NUMBER;
    BEGIN
      SELECT COUNT(*) INTO l_ok
        FROM sec_user_membership m
        JOIN sec_role_grant g ON g.membership_id = m.id AND g.status_code = 'ACTIVE'
       WHERE m.tenant_id = l_tenant AND m.is_tenant_admin = 'Y' AND m.status_code = 'ACTIVE';
      NOONA_CORE_PKG.assert(l_ok > 0, 'NOONA-PLT-011', 'فشل فحص الصحة: لا يوجد مسؤول مؤسسة نشط',
                            'Health check failed: no active tenant admin');
    END;
    UPDATE plt_tenant
       SET status_code = CASE WHEN p_is_trial = 'Y' THEN 'TRIAL' ELSE 'ACTIVE' END,
           activated_at = SYSTIMESTAMP
     WHERE id = l_tenant AND status_code = 'PENDING_ACTIVATION';
    IF SQL%ROWCOUNT = 1 THEN
      insert_status_hist(l_tenant, 'PENDING_ACTIVATION', CASE WHEN p_is_trial = 'Y' THEN 'TRIAL' ELSE 'ACTIVE' END,
                         'Provisioning completed');
    END IF;
    log_step(l_run, l_tenant, 6, 'HEALTH_CHECK_ACTIVATE');
    UPDATE plt_provisioning_run SET status_code = 'COMPLETED', finished_at = SYSTIMESTAMP WHERE id = l_run;

    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', l_tenant, 'PROVISION', 'SUCCESS',
                              p_new_values => '{"tenant_code":' || NOONA_CORE_PKG.json_text(p_tenant_code) || '}');
    NOONA_CORE_PKG.end_system;
    RETURN l_tenant;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_run IS NOT NULL THEN
        DECLARE
          l_err VARCHAR2(4000) := SUBSTR(SQLERRM, 1, 4000);
          PROCEDURE mark_failed IS
            PRAGMA AUTONOMOUS_TRANSACTION;
          BEGIN
            UPDATE plt_provisioning_run SET status_code = 'FAILED', error_message = l_err WHERE id = l_run;
            COMMIT;
          END;
        BEGIN
          mark_failed;
        END;
      END IF;
      NOONA_CORE_PKG.end_system;
      RAISE;
  END provision_tenant;

  PROCEDURE change_tenant_status(p_tenant_id IN NUMBER, p_new_status IN VARCHAR2, p_reason IN VARCHAR2) IS
    l_t plt_tenant%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-PLT-012', 'السبب إلزامي', 'Reason is required');
    NOONA_CORE_PKG.begin_system;
    SELECT * INTO l_t FROM plt_tenant WHERE id = p_tenant_id FOR UPDATE;
    NOONA_CORE_PKG.assert(tenant_transition_ok(l_t.status_code, p_new_status), 'NOONA-PLT-013',
      'انتقال غير مسموح من ' || l_t.status_code || ' إلى ' || p_new_status,
      'Transition not allowed from ' || l_t.status_code || ' to ' || p_new_status);
    NOONA_CORE_PKG.assert(NOT (l_t.legal_hold = 'Y' AND p_new_status IN ('ARCHIVED', 'CLOSED')), 'NOONA-PLT-014',
      'المؤسسة تحت حجز قانوني يمنع الأرشفة والإغلاق', 'Legal hold prevents archive/close');
    UPDATE plt_tenant
       SET status_code  = p_new_status,
           suspended_at = CASE WHEN p_new_status = 'SUSPENDED' THEN SYSTIMESTAMP ELSE suspended_at END,
           closed_at    = CASE WHEN p_new_status = 'CLOSED' THEN SYSTIMESTAMP ELSE closed_at END,
           activated_at = CASE WHEN p_new_status = 'ACTIVE' AND activated_at IS NULL THEN SYSTIMESTAMP ELSE activated_at END
     WHERE id = p_tenant_id;
    insert_status_hist(p_tenant_id, l_t.status_code, p_new_status, p_reason);
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', p_tenant_id, 'STATUS_CHANGE', 'SUCCESS',
      '{"status":"' || l_t.status_code || '"}', '{"status":"' || p_new_status || '"}', p_reason);
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END change_tenant_status;

  PROCEDURE set_legal_hold(p_tenant_id IN NUMBER, p_hold IN VARCHAR2, p_reason IN VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-PLT-012', 'السبب إلزامي', 'Reason is required');
    NOONA_CORE_PKG.begin_system;
    UPDATE plt_tenant SET legal_hold = p_hold WHERE id = p_tenant_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', p_tenant_id, 'LEGAL_HOLD_' || p_hold, 'SUCCESS',
                              p_reason => p_reason);
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END set_legal_hold;

  -- ================================================================ Entitlements
  FUNCTION hard_limit(p_metric_code IN VARCHAR2) RETURN NUMBER IS
    l_limit NUMBER;
    l_rows  NUMBER;
  BEGIN
    SELECT COUNT(*), MIN(NVL(e.hard_limit, e.limit_qty))
      INTO l_rows, l_limit
      FROM plt_entitlement e
      JOIN plt_usage_metric m ON m.id = e.metric_id
     WHERE e.tenant_id = NOONA_CTX_PKG.tenant_id
       AND m.code = p_metric_code
       AND e.is_enabled = 'Y'
       AND TRUNC(SYSDATE) BETWEEN e.effective_from AND NVL(e.effective_to, DATE '9999-12-31');
    RETURN CASE WHEN l_rows = 0 THEN NULL ELSE l_limit END;
  END hard_limit;

  PROCEDURE assert_within_limit(p_metric_code IN VARCHAR2, p_current_count IN NUMBER) IS
    l_limit NUMBER := hard_limit(p_metric_code);
    l_name  plt_usage_metric.name_ar%TYPE;
  BEGIN
    IF l_limit IS NOT NULL AND p_current_count >= l_limit THEN
      SELECT MAX(name_ar) INTO l_name FROM plt_usage_metric WHERE code = p_metric_code;
      NOONA_CORE_PKG.raise_error('NOONA-PLT-020',
        'تم بلوغ الحد الأقصى في الاشتراك: ' || NVL(l_name, p_metric_code) || ' = ' || l_limit
        || '. لزيادته تواصل مع مزود الخدمة؛ البيانات الحالية لا تتأثر',
        'Subscription limit reached (' || p_metric_code || ' = ' || l_limit || ')');
    END IF;
  END assert_within_limit;

  FUNCTION module_enabled(p_module_code IN VARCHAR2) RETURN VARCHAR2 IS
    l_rows NUMBER;
    l_on   NUMBER;
  BEGIN
    SELECT COUNT(*), SUM(CASE WHEN e.is_enabled = 'Y' THEN 1 ELSE 0 END)
      INTO l_rows, l_on
      FROM plt_entitlement e
      JOIN plt_module m ON m.id = e.module_id
     WHERE e.tenant_id = NOONA_CTX_PKG.tenant_id
       AND m.module_code = p_module_code
       AND e.feature_id IS NULL
       AND TRUNC(SYSDATE) BETWEEN e.effective_from AND NVL(e.effective_to, DATE '9999-12-31');
    -- بدون أي استحقاقات مسجلة (بيئة تطوير) تعتبر الوحدات مفعلة
    RETURN CASE WHEN l_rows = 0 THEN 'Y' WHEN l_on > 0 THEN 'Y' ELSE 'N' END;
  END module_enabled;

  -- ================================================================ Companies
  FUNCTION create_company(
    p_code                IN VARCHAR2,
    p_legal_name_ar       IN VARCHAR2,
    p_legal_name_en       IN VARCHAR2,
    p_country_code        IN VARCHAR2,
    p_functional_currency IN VARCHAR2,
    p_business_group_id   IN NUMBER   DEFAULT NULL,
    p_timezone            IN VARCHAR2 DEFAULT NULL,
    p_language            IN VARCHAR2 DEFAULT 'ar') RETURN NUMBER IS
    l_count NUMBER;
    l_pack  NUMBER;
    l_id    NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.CREATE');
    SELECT COUNT(*) INTO l_count FROM org_company
     WHERE status_code NOT IN ('CLOSED', 'ARCHIVED', 'LEGALLY_CLOSED');
    assert_within_limit('COMPANIES', l_count);
    SELECT MAX(id) INTO l_pack FROM loc_country_pack WHERE country_code = p_country_code;

    INSERT INTO org_company (business_group_id, code, legal_name_ar, legal_name_en, country_code, country_pack_id,
                             functional_currency, default_language, timezone_code, status_code)
    VALUES (p_business_group_id, UPPER(p_code), p_legal_name_ar, p_legal_name_en, p_country_code, l_pack,
            p_functional_currency, p_language,
            NVL(p_timezone, (SELECT default_timezone FROM ref_country WHERE country_code = p_country_code)),
            'DRAFT')
    RETURNING id INTO l_id;

    INSERT INTO org_company_currency (company_id, currency_role, currency_code)
    VALUES (l_id, 'FUNCTIONAL', p_functional_currency);

    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_COMPANY', l_id, 'CREATE', 'SUCCESS', p_company_id => l_id);
    RETURN l_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      NOONA_CORE_PKG.raise_error('NOONA-PLT-021', 'رمز الشركة مستخدم مسبقاً', 'Company code already exists');
  END create_company;

  FUNCTION create_branch(
    p_company_id     IN NUMBER,
    p_code           IN VARCHAR2,
    p_name_ar        IN VARCHAR2,
    p_name_en        IN VARCHAR2,
    p_branch_type    IN VARCHAR2,
    p_is_head_office IN VARCHAR2 DEFAULT 'N',
    p_country_code   IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_c     org_company%ROWTYPE;
    l_count NUMBER;
    l_id    NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('ORG_BRANCH.CREATE', p_company_id);
    SELECT * INTO l_c FROM org_company WHERE id = p_company_id;
    NOONA_CORE_PKG.assert(l_c.status_code NOT IN ('CLOSED', 'ARCHIVED', 'LEGALLY_CLOSED', 'TRANSACTIONS_BLOCKED'),
      'NOONA-PLT-030', 'لا يمكن إضافة فرع لشركة مغلقة', 'Cannot add a branch to a closed company');
    SELECT COUNT(*) INTO l_count FROM org_branch WHERE status_code <> 'CLOSED';
    assert_within_limit('BRANCHES', l_count);
    IF p_is_head_office = 'Y' THEN
      SELECT COUNT(*) INTO l_count FROM org_branch
       WHERE company_id = p_company_id AND is_head_office = 'Y' AND status_code <> 'CLOSED';
      NOONA_CORE_PKG.assert(l_count = 0, 'NOONA-PLT-031', 'للشركة فرع رئيسي نشط بالفعل',
                            'Company already has an active head office');
    END IF;
    INSERT INTO org_branch (company_id, code, name_ar, name_en, branch_type, is_head_office, country_code,
                            timezone_code, currency_code, status_code)
    VALUES (p_company_id, UPPER(p_code), p_name_ar, p_name_en, p_branch_type, NVL(p_is_head_office, 'N'),
            NVL(p_country_code, l_c.country_code), l_c.timezone_code, l_c.functional_currency, 'ACTIVE')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_BRANCH', l_id, 'CREATE', 'SUCCESS', p_company_id => p_company_id);
    RETURN l_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      NOONA_CORE_PKG.raise_error('NOONA-PLT-032', 'رمز الفرع مستخدم في هذه الشركة', 'Branch code already exists');
  END create_branch;

  FUNCTION run_activation_checks(p_company_id IN NUMBER) RETURN NUMBER IS
    l_c      org_company%ROWTYPE;
    l_failed NUMBER := 0;
    l_n      NUMBER;

    PROCEDURE put_check(p_code VARCHAR2, p_ok BOOLEAN, p_info VARCHAR2) IS
      l_ok VARCHAR2(1) := NOONA_CORE_PKG.yn(p_ok);
    BEGIN
      MERGE INTO org_company_check k
      USING (SELECT p_company_id company_id, p_code check_code FROM dual) x
         ON (k.company_id = x.company_id AND k.check_code = x.check_code)
       WHEN MATCHED THEN UPDATE SET
            k.status_code = CASE WHEN k.status_code = 'WAIVED' AND l_ok = 'N' THEN 'WAIVED'
                                 WHEN l_ok = 'Y' THEN 'PASSED' ELSE 'FAILED' END,
            k.checked_at = SYSTIMESTAMP, k.result_info = p_info
       WHEN NOT MATCHED THEN INSERT (company_id, check_code, checked_at, result_info, status_code)
            VALUES (p_company_id, p_code, SYSTIMESTAMP, p_info, CASE WHEN l_ok = 'Y' THEN 'PASSED' ELSE 'FAILED' END);
    END put_check;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.UPDATE', p_company_id);
    SELECT * INTO l_c FROM org_company WHERE id = p_company_id;

    -- 1) التسجيلات القانونية الإلزامية حسب Country Pack
    SELECT COUNT(*) INTO l_n
      FROM loc_registration_type rt
     WHERE rt.country_pack_id = l_c.country_pack_id
       AND rt.is_mandatory = 'Y' AND rt.applies_to = 'COMPANY' AND rt.is_active = 'Y'
       AND NOT EXISTS (SELECT 1 FROM org_legal_registration r
                        WHERE r.company_id = p_company_id AND r.reg_type_id = rt.id AND r.status_code = 'ACTIVE'
                          AND (r.expiry_date IS NULL OR r.expiry_date >= TRUNC(SYSDATE)));
    put_check('LEGAL_REGISTRATION', l_n = 0, l_n || ' تسجيل إلزامي ناقص');

    -- 2) العملة الوظيفية
    put_check('FUNCTIONAL_CURRENCY', l_c.functional_currency IS NOT NULL, l_c.functional_currency);

    -- 3) سنة مالية مفتوحة بفتراتها
    SELECT COUNT(*) INTO l_n FROM gl_fiscal_year y
     WHERE y.company_id = p_company_id AND y.status_code = 'OPEN'
       AND EXISTS (SELECT 1 FROM gl_period p WHERE p.fiscal_year_id = y.id);
    put_check('FISCAL_YEAR', l_n > 0, l_n || ' سنة مفتوحة');

    -- 4) دفتر أستاذ ودليل حسابات بحسابات قابلة للترحيل
    SELECT COUNT(*) INTO l_n FROM gl_ledger l
     WHERE l.company_id = p_company_id AND l.status_code IN ('DRAFT', 'ACTIVE')
       AND EXISTS (SELECT 1 FROM gl_account a WHERE a.coa_id = l.coa_id AND a.is_postable = 'Y');
    put_check('LEDGER_COA', l_n > 0, l_n || ' دفتر');

    -- 5) فرع رئيسي نشط
    SELECT COUNT(*) INTO l_n FROM org_branch
     WHERE company_id = p_company_id AND is_head_office = 'Y' AND status_code = 'ACTIVE';
    put_check('HEAD_BRANCH', l_n = 1, l_n || ' فرع رئيسي');

    -- 6) مسؤول للشركة (عضوية نشطة تصل إليها)
    SELECT COUNT(*) INTO l_n FROM sec_user_membership m
     WHERE m.status_code = 'ACTIVE'
       AND (m.is_tenant_admin = 'Y' OR m.default_company_id = p_company_id);
    put_check('COMPANY_ADMIN', l_n > 0, l_n || ' مستخدم');

    -- 7) التسلسلات الإلزامية
    SELECT COUNT(DISTINCT doc_type_code) INTO l_n FROM ref_doc_sequence
     WHERE company_id = p_company_id AND is_active = 'Y' AND doc_type_code IN ('SAL_INVOICE', 'GL_JOURNAL');
    put_check('DOC_SEQUENCES', l_n = 2, l_n || '/2 تسلسل');

    -- 8) حدود الاشتراك/الترخيص
    SELECT COUNT(*) INTO l_n FROM org_company WHERE status_code = 'ACTIVE' AND id <> p_company_id;
    put_check('LICENSE_LIMIT', hard_limit('COMPANIES') IS NULL OR l_n < hard_limit('COMPANIES'),
              'نشطة: ' || l_n || ' / الحد: ' || NVL(TO_CHAR(hard_limit('COMPANIES')), 'غير محدود'));

    SELECT COUNT(*) INTO l_failed FROM org_company_check
     WHERE company_id = p_company_id AND status_code = 'FAILED';

    IF l_c.status_code IN ('DRAFT', 'UNDER_CONFIGURATION') AND l_failed = 0 THEN
      UPDATE org_company SET status_code = 'READY_FOR_REVIEW' WHERE id = p_company_id;
    ELSIF l_c.status_code = 'DRAFT' THEN
      UPDATE org_company SET status_code = 'UNDER_CONFIGURATION' WHERE id = p_company_id;
    END IF;
    RETURN l_failed;
  END run_activation_checks;

  PROCEDURE waive_check(p_company_id IN NUMBER, p_check_code IN VARCHAR2, p_reason IN VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.APPROVE', p_company_id);
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-PLT-012', 'السبب إلزامي', 'Reason is required');
    NOONA_CORE_PKG.assert(p_check_code NOT IN ('FUNCTIONAL_CURRENCY', 'HEAD_BRANCH', 'LICENSE_LIMIT'),
      'NOONA-PLT-040', 'هذا الفحص لا يقبل الاستثناء', 'This check cannot be waived');
    UPDATE org_company_check
       SET status_code = 'WAIVED', waived_by = NOONA_CTX_PKG.current_user_name,
           result_info = SUBSTR(result_info || ' | استثناء: ' || p_reason, 1, 4000)
     WHERE company_id = p_company_id AND check_code = p_check_code;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_COMPANY', p_company_id, 'WAIVE_CHECK:' || p_check_code, 'SUCCESS',
                              p_reason => p_reason, p_company_id => p_company_id);
  END waive_check;

  PROCEDURE activate_company(p_company_id IN NUMBER) IS
    l_failed NUMBER;
    l_c      org_company%ROWTYPE;
    l_snap   CLOB;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.APPROVE', p_company_id);
    l_failed := run_activation_checks(p_company_id);
    NOONA_CORE_PKG.assert(l_failed = 0, 'NOONA-PLT-041',
      'لا يمكن التفعيل: ' || l_failed || ' فحص لم يجتز', 'Activation blocked: ' || l_failed || ' failed checks');
    SELECT * INTO l_c FROM org_company WHERE id = p_company_id FOR UPDATE;
    NOONA_CORE_PKG.assert(l_c.status_code = 'READY_FOR_REVIEW', 'NOONA-PLT-042',
      'الشركة ليست جاهزة للمراجعة', 'Company is not READY_FOR_REVIEW');

    SELECT JSON_OBJECT(
             'company'  VALUE JSON_OBJECT('code' VALUE c.code, 'legal_name_ar' VALUE c.legal_name_ar,
                                          'country' VALUE c.country_code, 'currency' VALUE c.functional_currency,
                                          'country_pack_id' VALUE c.country_pack_id),
             'branches' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('code' VALUE b.code, 'head' VALUE b.is_head_office))
                                 FROM org_branch b WHERE b.company_id = c.id AND b.status_code = 'ACTIVE'),
             'checks'   VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('check' VALUE k.check_code, 'status' VALUE k.status_code))
                                 FROM org_company_check k WHERE k.company_id = c.id)
             RETURNING CLOB)
      INTO l_snap
      FROM org_company c WHERE c.id = p_company_id;

    INSERT INTO org_config_snapshot (company_id, snapshot_type, snapshot_data)
    VALUES (p_company_id, 'ACTIVATION', l_snap);
    UPDATE org_company
       SET status_code = 'ACTIVE', activated_at = SYSTIMESTAMP, activated_by = NOONA_CTX_PKG.current_user_name
     WHERE id = p_company_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_COMPANY', p_company_id, 'ACTIVATE', 'SUCCESS',
                              p_new_values => l_snap, p_company_id => p_company_id);
  END activate_company;

  PROCEDURE change_company_status(p_company_id IN NUMBER, p_new_status IN VARCHAR2, p_reason IN VARCHAR2) IS
    l_old org_company.status_code%TYPE;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.APPROVE', p_company_id);
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-PLT-012', 'السبب إلزامي', 'Reason is required');
    SELECT status_code INTO l_old FROM org_company WHERE id = p_company_id FOR UPDATE;
    NOONA_CORE_PKG.assert(company_transition_ok(l_old, p_new_status), 'NOONA-PLT-044',
      'انتقال غير مسموح من ' || l_old || ' إلى ' || p_new_status,
      'Transition not allowed from ' || l_old || ' to ' || p_new_status);
    UPDATE org_company SET status_code = p_new_status WHERE id = p_company_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_COMPANY', p_company_id, 'STATUS_CHANGE', 'SUCCESS',
      '{"status":"' || l_old || '"}', '{"status":"' || p_new_status || '"}', p_reason, p_company_id);
  END change_company_status;

  PROCEDURE close_branch(p_branch_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_b  org_branch%ROWTYPE;
    l_n  NUMBER;
    l_msg VARCHAR2(1000);
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_b FROM org_branch WHERE id = p_branch_id FOR UPDATE;
    NOONA_SECURITY_PKG.assert_permission('ORG_BRANCH.UPDATE', l_b.company_id);
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-PLT-012', 'السبب إلزامي', 'Reason is required');
    -- فحص المسؤوليات المفتوحة قبل الإغلاق (12.4)
    SELECT COUNT(*) INTO l_n FROM inv_warehouse WHERE branch_id = p_branch_id AND status_code = 'ACTIVE';
    IF l_n > 0 THEN l_msg := l_msg || ' مستودعات نشطة=' || l_n; END IF;
    SELECT COUNT(*) INTO l_n FROM csh_cash_box WHERE branch_id = p_branch_id AND status_code = 'ACTIVE';
    IF l_n > 0 THEN l_msg := l_msg || ' صناديق نشطة=' || l_n; END IF;
    SELECT COUNT(*) INTO l_n FROM csh_bank_account WHERE branch_id = p_branch_id AND status_code = 'ACTIVE';
    IF l_n > 0 THEN l_msg := l_msg || ' حسابات بنكية=' || l_n; END IF;
    SELECT COUNT(*) INTO l_n FROM org_position WHERE branch_id = p_branch_id AND status_code = 'OCCUPIED';
    IF l_n > 0 THEN l_msg := l_msg || ' مناصب مشغولة=' || l_n; END IF;
    SELECT COUNT(*) INTO l_n FROM sec_user_membership WHERE default_branch_id = p_branch_id AND status_code = 'ACTIVE';
    IF l_n > 0 THEN l_msg := l_msg || ' مستخدمون افتراضيون=' || l_n; END IF;
    NOONA_CORE_PKG.assert(l_msg IS NULL, 'NOONA-PLT-050',
      'لا يمكن إغلاق الفرع قبل معالجة:' || l_msg, 'Branch has open responsibilities:' || l_msg);
    UPDATE org_branch SET status_code = 'CLOSED', effective_to = TRUNC(SYSDATE) WHERE id = p_branch_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_BRANCH', p_branch_id, 'CLOSE', 'SUCCESS', p_reason => p_reason,
                              p_company_id => l_b.company_id);
  END close_branch;

END NOONA_PLATFORM_PKG;
/
