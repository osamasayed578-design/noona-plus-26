-- =============================================================================
-- NOONA PLUS ERP | NOONA_DELEGATION_PKG  (المرحلة 08 - محرك التفويض المركزي)
--   * التفويض لا يعني مشاركة الحساب: المفوض يعمل بهويته ويسجل أنه نيابة عن المانح
--   * أقل نطاق لازم: كل بعد في DLG_SCOPE يقيد؛ غياب البعد = غير مقيد فيه
--   * يمنع: التفويض للنفس، الدورات، إعادة التفويض غير المسموحة، المفوض غير الفعال،
--     اعتماد المانح أو المفوض لتفويضه، وتجاوز أقل الحدود (المانح/التفويض/السياسة)
--   * الأولوية (16.2): تفويض صريح للعملية > لنوعها > تفويض منصب > بديل > تصعيد
--     وتعادل الأولوية والتحديد بين مفوضين مختلفين لا يحسم عشوائياً (يرجع NULL للتصعيد)
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_DELEGATION_PKG AUTHID DEFINER AS

  FUNCTION create_delegation(
    p_delegation_type   IN VARCHAR2,
    p_grantor_member_id IN NUMBER,
    p_delegate_member_id IN NUMBER,
    p_starts_at         IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_ends_at           IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_reason            IN VARCHAR2,
    p_priority_no       IN NUMBER   DEFAULT 1,
    p_parent_delegation_id IN NUMBER DEFAULT NULL,
    p_timezone          IN VARCHAR2 DEFAULT 'Asia/Riyadh') RETURN NUMBER;

  -- البعد: COMPANY / BRANCH / ORG_UNIT / PROJECT / MODULE / REQUEST_TYPE / WORKFLOW / TRANSACTION_TYPE
  --        / ACTION / PERMISSION / MAX_CONFIDENTIALITY ...
  PROCEDURE add_scope(p_delegation_id IN NUMBER, p_dimension IN VARCHAR2,
                      p_value_id IN NUMBER DEFAULT NULL, p_value_code IN VARCHAR2 DEFAULT NULL);
  PROCEDURE set_limit(p_delegation_id IN NUMBER, p_currency IN VARCHAR2,
                      p_max_per_txn IN NUMBER, p_max_cumulative IN NUMBER DEFAULT NULL);

  PROCEDURE submit(p_delegation_id IN NUMBER);
  PROCEDURE approve(p_delegation_id IN NUMBER, p_comment IN VARCHAR2 DEFAULT NULL);
  PROCEDURE reject(p_delegation_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE revoke_delegation(p_delegation_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE suspend(p_delegation_id IN NUMBER, p_reason IN VARCHAR2);

  -- مهمة مجدولة: تفعيل المجدول وإنهاء المنتهي (تعاد مراجعة المهام المفتوحة في Workflow)
  PROCEDURE process_schedule;

  -- يبحث عن المفوض المؤهل لإجراء محدد نيابة عن المانح؛ يرجع معرف التفويض أو NULL
  FUNCTION find_delegation(
    p_grantor_member_id IN NUMBER,
    p_action_code       IN VARCHAR2,
    p_company_id        IN NUMBER   DEFAULT NULL,
    p_module_code       IN VARCHAR2 DEFAULT NULL,
    p_transaction_type  IN VARCHAR2 DEFAULT NULL,
    p_workflow_code     IN VARCHAR2 DEFAULT NULL,
    p_amount            IN NUMBER   DEFAULT NULL,
    p_currency          IN VARCHAR2 DEFAULT NULL,
    p_confidentiality   IN VARCHAR2 DEFAULT NULL,
    p_at                IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT SYSTIMESTAMP) RETURN NUMBER;

  FUNCTION delegate_of(p_delegation_id IN NUMBER) RETURN NUMBER;

  -- هل يستطيع المستخدم التصرف نيابة عن المانح الآن في هذا السياق؟
  FUNCTION can_act_for(
    p_actor_member_id   IN NUMBER,
    p_grantor_member_id IN NUMBER,
    p_action_code       IN VARCHAR2,
    p_company_id        IN NUMBER   DEFAULT NULL,
    p_transaction_type  IN VARCHAR2 DEFAULT NULL,
    p_workflow_code     IN VARCHAR2 DEFAULT NULL,
    p_amount            IN NUMBER   DEFAULT NULL,
    p_currency          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE record_exercise(
    p_delegation_id IN NUMBER,
    p_action_code   IN VARCHAR2,
    p_entity_type   IN VARCHAR2,
    p_entity_id     IN NUMBER,
    p_task_id       IN NUMBER   DEFAULT NULL,
    p_amount        IN NUMBER   DEFAULT NULL,
    p_currency      IN VARCHAR2 DEFAULT NULL,
    p_result        IN VARCHAR2 DEFAULT 'EXECUTED');
END NOONA_DELEGATION_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_DELEGATION_PKG AS

  FUNCTION get(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN dlg_delegation%ROWTYPE IS
    l_d dlg_delegation%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l_d FROM dlg_delegation WHERE id = p_id FOR UPDATE;
    ELSE
      SELECT * INTO l_d FROM dlg_delegation WHERE id = p_id;
    END IF;
    RETURN l_d;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-DLG-001', 'التفويض غير موجود', 'Delegation not found');
  END get;

  FUNCTION member_active(p_member NUMBER) RETURN BOOLEAN IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n
      FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
     WHERE m.id = p_member AND m.status_code = 'ACTIVE' AND u.status_code = 'ACTIVE'
       AND TRUNC(SYSDATE) BETWEEN m.effective_from AND NVL(m.effective_to, DATE '9999-12-31');
    RETURN l_n = 1;
  END member_active;

  PROCEDURE assert_editable(p_d dlg_delegation%ROWTYPE) IS
  BEGIN
    NOONA_CORE_PKG.assert(p_d.status_code = 'DRAFT', 'NOONA-DLG-002',
      'لا يعدل التفويض بعد إرساله؛ أنشئ إصداراً جديداً', 'Only DRAFT delegations can be edited');
    NOONA_CORE_PKG.assert(p_d.grantor_member_id = NOONA_CTX_PKG.membership_id
                          OR NOONA_SECURITY_PKG.has_permission('DLG_DELEGATION.UPDATE') = 'Y',
      'NOONA-DLG-003', 'غير مخول بتعديل هذا التفويض', 'Not allowed to edit this delegation');
  END assert_editable;

  -- ================================================================ lifecycle
  FUNCTION create_delegation(
    p_delegation_type   IN VARCHAR2,
    p_grantor_member_id IN NUMBER,
    p_delegate_member_id IN NUMBER,
    p_starts_at         IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_ends_at           IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_reason            IN VARCHAR2,
    p_priority_no       IN NUMBER   DEFAULT 1,
    p_parent_delegation_id IN NUMBER DEFAULT NULL,
    p_timezone          IN VARCHAR2 DEFAULT 'Asia/Riyadh') RETURN NUMBER IS
    l_id     NUMBER;
    l_no     VARCHAR2(50);
    l_parent dlg_delegation%ROWTYPE;
    l_maxd   NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_CORE_PKG.assert(p_grantor_member_id = NOONA_CTX_PKG.membership_id
                          OR NOONA_SECURITY_PKG.has_permission('DLG_DELEGATION.CREATE') = 'Y',
      'NOONA-DLG-010', 'لا يمكنك إنشاء تفويض نيابة عن غيرك', 'Cannot create a delegation for another user');
    NOONA_CORE_PKG.assert(p_grantor_member_id <> p_delegate_member_id, 'NOONA-DLG-011',
      'لا يجوز التفويض للنفس', 'Self-delegation is not allowed');
    NOONA_CORE_PKG.assert(member_active(p_grantor_member_id) AND member_active(p_delegate_member_id), 'NOONA-DLG-012',
      'المانح أو المفوض إليه غير فعال', 'Grantor or delegate is not active');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-DLG-013', 'السبب إلزامي', 'Reason is required');
    NOONA_CORE_PKG.assert(p_ends_at IS NOT NULL OR p_delegation_type = 'ACTING', 'NOONA-DLG-014',
      'لا يسمح بتفويض مفتوح بلا نهاية', 'Open-ended delegation is not allowed');
    NOONA_CORE_PKG.assert(p_ends_at IS NULL OR p_ends_at > p_starts_at, 'NOONA-DLG-015',
      'النهاية يجب أن تكون بعد البداية', 'End must be after start');

    SELECT MIN(max_duration_days) INTO l_maxd FROM dlg_policy
     WHERE is_active = 'Y' AND TRUNC(SYSDATE) BETWEEN effective_from AND NVL(effective_to, DATE '9999-12-31');
    NOONA_CORE_PKG.assert(l_maxd IS NULL OR p_ends_at IS NULL
                          OR CAST(p_ends_at AS DATE) - CAST(p_starts_at AS DATE) <= l_maxd, 'NOONA-DLG-016',
      'مدة التفويض تتجاوز الحد المسموح (' || l_maxd || ' يوماً)', 'Delegation exceeds the maximum duration');

    -- إعادة التفويض: يجب أن يسمح الأصل، ولا يتوسع المدى أو المدة
    IF p_parent_delegation_id IS NOT NULL THEN
      l_parent := get(p_parent_delegation_id);
      NOONA_CORE_PKG.assert(l_parent.allow_redelegation = 'Y' AND l_parent.status_code = 'ACTIVE'
                            AND l_parent.delegate_member_id = p_grantor_member_id, 'NOONA-DLG-017',
        'إعادة التفويض غير مسموحة', 'Re-delegation is not permitted');
      NOONA_CORE_PKG.assert(p_starts_at >= l_parent.starts_at
                            AND (l_parent.ends_at IS NULL OR p_ends_at <= l_parent.ends_at), 'NOONA-DLG-018',
        'لا يجوز أن تتجاوز مدة إعادة التفويض مدة الأصل', 'Re-delegation cannot exceed the parent period');
    END IF;

    l_no := 'TMP-' || RAWTOHEX(SYS_GUID());
    INSERT INTO dlg_delegation (delegation_no, delegation_type, grantor_member_id, grantor_position_id,
                                delegate_member_id, parent_delegation_id, starts_at, ends_at, timezone_code,
                                reason, priority_no, status_code)
    VALUES (l_no, p_delegation_type, p_grantor_member_id, NOONA_ORG_PKG.primary_position(p_grantor_member_id),
            p_delegate_member_id, p_parent_delegation_id, p_starts_at, p_ends_at, p_timezone,
            p_reason, NVL(p_priority_no, 1), 'DRAFT')
    RETURNING id INTO l_id;
    UPDATE dlg_delegation SET delegation_no = 'DLG-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || LPAD(l_id, 6, '0')
     WHERE id = l_id;

    -- إعادة التفويض ترث نطاق الأصل وحدوده (لا يتوسع)
    IF p_parent_delegation_id IS NOT NULL THEN
      INSERT INTO dlg_scope (delegation_id, dimension_code, value_id, value_code)
      SELECT l_id, dimension_code, value_id, value_code FROM dlg_scope WHERE delegation_id = p_parent_delegation_id;
      INSERT INTO dlg_limit (delegation_id, currency_code, max_per_transaction, max_cumulative)
      SELECT l_id, currency_code, max_per_transaction, max_cumulative FROM dlg_limit
       WHERE delegation_id = p_parent_delegation_id;
    END IF;
    RETURN l_id;
  END create_delegation;

  PROCEDURE add_scope(p_delegation_id IN NUMBER, p_dimension IN VARCHAR2,
                      p_value_id IN NUMBER DEFAULT NULL, p_value_code IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    assert_editable(get(p_delegation_id));
    NOONA_CORE_PKG.assert(p_value_id IS NOT NULL OR p_value_code IS NOT NULL, 'NOONA-DLG-020',
      'قيمة النطاق إلزامية', 'Scope value is required');
    INSERT INTO dlg_scope (delegation_id, dimension_code, value_id, value_code)
    VALUES (p_delegation_id, p_dimension, p_value_id, p_value_code);
  END add_scope;

  PROCEDURE set_limit(p_delegation_id IN NUMBER, p_currency IN VARCHAR2,
                      p_max_per_txn IN NUMBER, p_max_cumulative IN NUMBER DEFAULT NULL) IS
  BEGIN
    assert_editable(get(p_delegation_id));
    MERGE INTO dlg_limit l
    USING (SELECT p_delegation_id delegation_id, p_currency currency_code FROM dual) x
       ON (l.delegation_id = x.delegation_id AND l.currency_code = x.currency_code)
     WHEN MATCHED THEN UPDATE SET l.max_per_transaction = p_max_per_txn, l.max_cumulative = p_max_cumulative
     WHEN NOT MATCHED THEN INSERT (delegation_id, currency_code, max_per_transaction, max_cumulative)
          VALUES (p_delegation_id, p_currency, p_max_per_txn, p_max_cumulative);
  END set_limit;

  -- نطاقان متداخلان؟ (بعد غائب = غير مقيد)
  FUNCTION scopes_overlap(p_a NUMBER, p_b NUMBER) RETURN BOOLEAN IS
    l_conflict NUMBER;
  BEGIN
    -- يتداخلان ما لم يوجد بعد مقيد في الطرفين بقيم مختلفة كلياً
    SELECT COUNT(*) INTO l_conflict
      FROM (SELECT DISTINCT dimension_code FROM dlg_scope WHERE delegation_id = p_a) da
      JOIN (SELECT DISTINCT dimension_code FROM dlg_scope WHERE delegation_id = p_b) db
        ON db.dimension_code = da.dimension_code
     WHERE NOT EXISTS (SELECT 1 FROM dlg_scope sa JOIN dlg_scope sb
                          ON sb.dimension_code = sa.dimension_code
                         AND (sb.value_id = sa.value_id OR sb.value_code = sa.value_code)
                        WHERE sa.delegation_id = p_a AND sb.delegation_id = p_b
                          AND sa.dimension_code = da.dimension_code);
    RETURN l_conflict = 0;
  END scopes_overlap;

  PROCEDURE submit(p_delegation_id IN NUMBER) IS
    l_d dlg_delegation%ROWTYPE := get(p_delegation_id, TRUE);
    l_n NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    assert_editable(l_d);
    -- منع الدورة: تفويض فعال/مجدول من المفوض إليه إلى المانح لنفس النوع والفترة والنطاق
    FOR r IN (SELECT id FROM dlg_delegation
               WHERE grantor_member_id = l_d.delegate_member_id
                 AND delegate_member_id = l_d.grantor_member_id
                 AND delegation_type = l_d.delegation_type
                 AND status_code IN ('SUBMITTED', 'APPROVED', 'SCHEDULED', 'ACTIVE')
                 AND starts_at < NVL(l_d.ends_at, TIMESTAMP '9999-12-31 00:00:00')
                 AND NVL(ends_at, TIMESTAMP '9999-12-31 00:00:00') > l_d.starts_at) LOOP
      NOONA_CORE_PKG.assert(NOT scopes_overlap(r.id, p_delegation_id), 'NOONA-DLG-030',
        'التفويض ينشئ دورة تفويض متبادل', 'Delegation would create a cycle');
    END LOOP;
    -- تفويض متعارض لنفس المانح بنفس الأولوية والنطاق لمفوض آخر
    SELECT COUNT(*) INTO l_n FROM dlg_delegation o
     WHERE o.grantor_member_id = l_d.grantor_member_id AND o.id <> l_d.id
       AND o.delegate_member_id <> l_d.delegate_member_id
       AND o.delegation_type = l_d.delegation_type AND o.priority_no = l_d.priority_no
       AND o.status_code IN ('SUBMITTED', 'APPROVED', 'SCHEDULED', 'ACTIVE')
       AND o.starts_at < NVL(l_d.ends_at, TIMESTAMP '9999-12-31 00:00:00')
       AND NVL(o.ends_at, TIMESTAMP '9999-12-31 00:00:00') > l_d.starts_at;
    IF l_n > 0 THEN
      FOR r IN (SELECT o.id FROM dlg_delegation o
                 WHERE o.grantor_member_id = l_d.grantor_member_id AND o.id <> l_d.id
                   AND o.delegate_member_id <> l_d.delegate_member_id
                   AND o.delegation_type = l_d.delegation_type AND o.priority_no = l_d.priority_no
                   AND o.status_code IN ('SUBMITTED', 'APPROVED', 'SCHEDULED', 'ACTIVE')) LOOP
        NOONA_CORE_PKG.assert(NOT scopes_overlap(r.id, p_delegation_id), 'NOONA-DLG-031',
          'يوجد تفويض متعارض بنفس الأولوية والنطاق لشخص آخر؛ حدد ترتيب البدلاء',
          'Conflicting delegation with the same priority and scope');
      END LOOP;
    END IF;
    UPDATE dlg_delegation SET status_code = 'SUBMITTED' WHERE id = p_delegation_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'DLG_DELEGATION', p_delegation_id, 'SUBMIT', 'SUCCESS');
  END submit;

  PROCEDURE approve(p_delegation_id IN NUMBER, p_comment IN VARCHAR2 DEFAULT NULL) IS
    l_d  dlg_delegation%ROWTYPE := get(p_delegation_id, TRUE);
    l_me NUMBER := NOONA_CTX_PKG.membership_id;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('DLG_DELEGATION.APPROVE');
    NOONA_CORE_PKG.assert(l_d.status_code = 'SUBMITTED', 'NOONA-DLG-040', 'التفويض ليس بانتظار الاعتماد',
                          'Delegation is not awaiting approval');
    NOONA_CORE_PKG.assert(l_me NOT IN (l_d.grantor_member_id, l_d.delegate_member_id), 'NOONA-DLG-041',
      'لا يعتمد المانح أو المفوض إليه التفويض بنفسه', 'Grantor/delegate cannot approve their own delegation');
    UPDATE dlg_delegation
       SET status_code = CASE WHEN starts_at <= SYSTIMESTAMP THEN 'ACTIVE' ELSE 'SCHEDULED' END
     WHERE id = p_delegation_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'DLG_DELEGATION', p_delegation_id, 'APPROVE', 'SUCCESS', p_reason => p_comment);
  END approve;

  PROCEDURE reject(p_delegation_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_d dlg_delegation%ROWTYPE := get(p_delegation_id, TRUE);
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('DLG_DELEGATION.REJECT');
    NOONA_CORE_PKG.assert(l_d.status_code = 'SUBMITTED', 'NOONA-DLG-040', 'التفويض ليس بانتظار الاعتماد',
                          'Delegation is not awaiting approval');
    UPDATE dlg_delegation SET status_code = 'REJECTED', revoke_reason = p_reason WHERE id = p_delegation_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'DLG_DELEGATION', p_delegation_id, 'REJECT', 'SUCCESS', p_reason => p_reason);
  END reject;

  PROCEDURE revoke_delegation(p_delegation_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_d dlg_delegation%ROWTYPE := get(p_delegation_id, TRUE);
  BEGIN
    NOONA_CORE_PKG.assert(l_d.grantor_member_id = NOONA_CTX_PKG.membership_id
                          OR NOONA_SECURITY_PKG.has_permission('DLG_DELEGATION.CANCEL') = 'Y',
      'NOONA-DLG-050', 'غير مخول بإلغاء التفويض', 'Not allowed to revoke this delegation');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-DLG-013', 'السبب إلزامي', 'Reason is required');
    NOONA_CORE_PKG.assert(l_d.status_code IN ('SUBMITTED', 'APPROVED', 'SCHEDULED', 'ACTIVE', 'SUSPENDED'),
      'NOONA-DLG-051', 'لا يمكن إلغاء تفويض بحالة ' || l_d.status_code, 'Cannot revoke in this status');
    UPDATE dlg_delegation SET status_code = 'REVOKED', revoke_reason = p_reason,
           ends_at = LEAST(NVL(ends_at, SYSTIMESTAMP), SYSTIMESTAMP)
     WHERE id = p_delegation_id;
    -- يمنع إنشاء مهام جديدة فوراً؛ والمهام المفتوحة تعاد لصاحبها الأصلي
    UPDATE wf_task SET assignee_member_id = original_member_id, delegation_id = NULL
     WHERE delegation_id = p_delegation_id AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO');
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'DLG_DELEGATION', p_delegation_id, 'REVOKE', 'SUCCESS', p_reason => p_reason);
  END revoke_delegation;

  PROCEDURE suspend(p_delegation_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_d dlg_delegation%ROWTYPE := get(p_delegation_id, TRUE);
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('DLG_DELEGATION.UPDATE');
    NOONA_CORE_PKG.assert(l_d.status_code = 'ACTIVE', 'NOONA-DLG-052', 'التفويض ليس فعالاً', 'Delegation is not active');
    UPDATE dlg_delegation SET status_code = 'SUSPENDED', revoke_reason = p_reason WHERE id = p_delegation_id;
    UPDATE wf_task SET assignee_member_id = original_member_id, delegation_id = NULL
     WHERE delegation_id = p_delegation_id AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO');
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'DLG_DELEGATION', p_delegation_id, 'SUSPEND', 'SUCCESS', p_reason => p_reason);
  END suspend;

  -- مهمة مجدولة (DBMS_SCHEDULER) تعمل عبر كل المؤسسات بوضع النظام
  PROCEDURE process_schedule IS
  BEGIN
    NOONA_CORE_PKG.begin_system;
    UPDATE dlg_delegation SET status_code = 'ACTIVE'
     WHERE status_code = 'SCHEDULED' AND starts_at <= SYSTIMESTAMP;
    FOR r IN (SELECT id FROM dlg_delegation WHERE status_code = 'ACTIVE' AND ends_at <= SYSTIMESTAMP) LOOP
      UPDATE dlg_delegation SET status_code = 'EXPIRED' WHERE id = r.id;
      UPDATE wf_task SET assignee_member_id = original_member_id, delegation_id = NULL
       WHERE delegation_id = r.id AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO');
    END LOOP;
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END process_schedule;

  -- ================================================================ resolution
  FUNCTION dim_ok(p_delegation_id NUMBER, p_dim VARCHAR2, p_id NUMBER, p_code VARCHAR2) RETURN BOOLEAN IS
    l_rows NUMBER;
    l_hit  NUMBER;
  BEGIN
    SELECT COUNT(*), SUM(CASE WHEN (p_id IS NOT NULL AND value_id = p_id)
                               OR (p_code IS NOT NULL AND value_code = p_code) THEN 1 ELSE 0 END)
      INTO l_rows, l_hit
      FROM dlg_scope WHERE delegation_id = p_delegation_id AND dimension_code = p_dim;
    RETURN l_rows = 0 OR l_hit > 0;
  END dim_ok;

  FUNCTION conf_rank(p_level VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE p_level WHEN 'PUBLIC' THEN 1 WHEN 'INTERNAL' THEN 2 WHEN 'CONFIDENTIAL' THEN 3
                        WHEN 'SECRET' THEN 4 WHEN 'HIGHLY_RESTRICTED' THEN 5 ELSE 2 END;
  END conf_rank;

  FUNCTION matches(p_d dlg_delegation%ROWTYPE, p_action VARCHAR2, p_company NUMBER, p_module VARCHAR2,
                   p_txn_type VARCHAR2, p_wf VARCHAR2, p_amount NUMBER, p_currency VARCHAR2,
                   p_conf VARCHAR2, p_at TIMESTAMP WITH LOCAL TIME ZONE) RETURN BOOLEAN IS
    l_max_conf VARCHAR2(30);
    l_lim      dlg_limit%ROWTYPE;
  BEGIN
    IF p_d.status_code <> 'ACTIVE' OR p_at < p_d.starts_at OR (p_d.ends_at IS NOT NULL AND p_at >= p_d.ends_at) THEN
      RETURN FALSE;
    END IF;
    IF NOT member_active(p_d.delegate_member_id) THEN
      RETURN FALSE;
    END IF;
    IF NOT (dim_ok(p_d.id, 'ACTION', NULL, p_action) AND dim_ok(p_d.id, 'COMPANY', p_company, NULL)
            AND dim_ok(p_d.id, 'MODULE', NULL, p_module) AND dim_ok(p_d.id, 'TRANSACTION_TYPE', NULL, p_txn_type)
            AND dim_ok(p_d.id, 'WORKFLOW', NULL, p_wf)) THEN
      RETURN FALSE;
    END IF;
    SELECT MAX(value_code) INTO l_max_conf FROM dlg_scope
     WHERE delegation_id = p_d.id AND dimension_code = 'MAX_CONFIDENTIALITY';
    IF l_max_conf IS NOT NULL AND conf_rank(p_conf) > conf_rank(l_max_conf) THEN
      RETURN FALSE;
    END IF;
    IF p_amount IS NOT NULL THEN
      BEGIN
        SELECT * INTO l_lim FROM dlg_limit WHERE delegation_id = p_d.id AND currency_code = p_currency;
        IF (l_lim.max_per_transaction IS NOT NULL AND p_amount > l_lim.max_per_transaction)
           OR (l_lim.max_cumulative IS NOT NULL AND l_lim.used_cumulative + p_amount > l_lim.max_cumulative) THEN
          RETURN FALSE;
        END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        -- تفويض مالي بلا حد بعملة المعاملة لا يغطي المبالغ
        IF p_d.delegation_type = 'FINANCIAL' THEN
          RETURN FALSE;
        END IF;
      END;
    END IF;
    RETURN TRUE;
  END matches;

  FUNCTION find_delegation(
    p_grantor_member_id IN NUMBER,
    p_action_code       IN VARCHAR2,
    p_company_id        IN NUMBER   DEFAULT NULL,
    p_module_code       IN VARCHAR2 DEFAULT NULL,
    p_transaction_type  IN VARCHAR2 DEFAULT NULL,
    p_workflow_code     IN VARCHAR2 DEFAULT NULL,
    p_amount            IN NUMBER   DEFAULT NULL,
    p_currency          IN VARCHAR2 DEFAULT NULL,
    p_confidentiality   IN VARCHAR2 DEFAULT NULL,
    p_at                IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT SYSTIMESTAMP) RETURN NUMBER IS
    l_best      NUMBER;
    l_best_key  NUMBER;
    l_best_dlg  NUMBER;
    l_tie       BOOLEAN := FALSE;
    l_key       NUMBER;
  BEGIN
    FOR r IN (SELECT d.*, (SELECT COUNT(*) FROM dlg_scope s WHERE s.delegation_id = d.id) specificity
                FROM dlg_delegation d
               WHERE d.grantor_member_id = p_grantor_member_id AND d.status_code = 'ACTIVE') LOOP
      DECLARE
        l_d dlg_delegation%ROWTYPE;
      BEGIN
        SELECT * INTO l_d FROM dlg_delegation WHERE id = r.id;
        IF matches(l_d, p_action_code, p_company_id, p_module_code, p_transaction_type, p_workflow_code,
                   p_amount, p_currency, p_confidentiality, p_at) THEN
          -- مفتاح الترتيب: الأولوية الأصغر أولاً، ثم الأكثر تحديداً
          l_key := r.priority_no * 1000 - r.specificity;
          IF l_best_key IS NULL OR l_key < l_best_key THEN
            l_best_key := l_key; l_best := r.delegate_member_id; l_best_dlg := r.id; l_tie := FALSE;
          ELSIF l_key = l_best_key AND r.delegate_member_id <> l_best THEN
            l_tie := TRUE;
          END IF;
        END IF;
      END;
    END LOOP;
    RETURN CASE WHEN l_tie THEN NULL ELSE l_best_dlg END;
  END find_delegation;

  FUNCTION delegate_of(p_delegation_id IN NUMBER) RETURN NUMBER IS
    l_m NUMBER;
  BEGIN
    SELECT delegate_member_id INTO l_m FROM dlg_delegation WHERE id = p_delegation_id;
    RETURN l_m;
  END delegate_of;

  FUNCTION can_act_for(
    p_actor_member_id   IN NUMBER,
    p_grantor_member_id IN NUMBER,
    p_action_code       IN VARCHAR2,
    p_company_id        IN NUMBER   DEFAULT NULL,
    p_transaction_type  IN VARCHAR2 DEFAULT NULL,
    p_workflow_code     IN VARCHAR2 DEFAULT NULL,
    p_amount            IN NUMBER   DEFAULT NULL,
    p_currency          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    FOR r IN (SELECT id FROM dlg_delegation
               WHERE grantor_member_id = p_grantor_member_id AND delegate_member_id = p_actor_member_id
                 AND status_code = 'ACTIVE'
               ORDER BY priority_no) LOOP
      DECLARE
        l_d dlg_delegation%ROWTYPE;
      BEGIN
        SELECT * INTO l_d FROM dlg_delegation WHERE id = r.id;
        IF matches(l_d, p_action_code, p_company_id, NULL, p_transaction_type, p_workflow_code,
                   p_amount, p_currency, NULL, SYSTIMESTAMP) THEN
          RETURN r.id;
        END IF;
      END;
    END LOOP;
    RETURN NULL;
  END can_act_for;

  PROCEDURE record_exercise(
    p_delegation_id IN NUMBER,
    p_action_code   IN VARCHAR2,
    p_entity_type   IN VARCHAR2,
    p_entity_id     IN NUMBER,
    p_task_id       IN NUMBER   DEFAULT NULL,
    p_amount        IN NUMBER   DEFAULT NULL,
    p_currency      IN VARCHAR2 DEFAULT NULL,
    p_result        IN VARCHAR2 DEFAULT 'EXECUTED') IS
    l_d    dlg_delegation%ROWTYPE := get(p_delegation_id);
    l_snap CLOB;
  BEGIN
    SELECT JSON_OBJECT('delegation_no' VALUE l_d.delegation_no, 'type' VALUE l_d.delegation_type,
                       'version' VALUE l_d.version_no,
                       'scope' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('dim' VALUE dimension_code,
                                            'id' VALUE value_id, 'code' VALUE value_code))
                                        FROM dlg_scope WHERE delegation_id = l_d.id),
                       'limits' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('cur' VALUE currency_code,
                                            'per_txn' VALUE max_per_transaction, 'used' VALUE used_cumulative))
                                         FROM dlg_limit WHERE delegation_id = l_d.id)
                       RETURNING CLOB)
      INTO l_snap FROM dual;
    INSERT INTO dlg_exercise_event (delegation_id, actor_member_id, authority_member_id, action_code, entity_type,
                                    entity_id, task_id, amount, currency_code, policy_snapshot, result_code,
                                    correlation_id)
    VALUES (p_delegation_id, NOONA_CTX_PKG.membership_id, l_d.grantor_member_id, p_action_code, p_entity_type,
            p_entity_id, p_task_id, p_amount, p_currency, l_snap, p_result, NOONA_CTX_PKG.correlation_id);
    IF p_result = 'EXECUTED' AND p_amount IS NOT NULL THEN
      UPDATE dlg_limit SET used_cumulative = used_cumulative + p_amount
       WHERE delegation_id = p_delegation_id AND currency_code = p_currency;
    END IF;
  END record_exercise;

END NOONA_DELEGATION_PKG;
/
