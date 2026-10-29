-- =============================================================================
-- NOONA PLUS ERP | NOONA_PLATFORM_ADMIN_PKG - لوحة المنصة (مسؤول المنصة فقط)
--   * مؤشرات المنصة ومقاييس كل مؤسسة
--   * اشتراك المؤسسة في الوحدات (PLT_ENTITLEMENT) بخانات اختيار؛ يحدد الأنظمة الظاهرة في شاشة الأنظمة
--   * سجل تدقيق المنصة والتحقق من سلسلة أي مؤسسة
--   * إعادة تعيين كلمة مرور أي مستخدم (ومنها الحسابات المشتركة بين المؤسسات)
-- مسؤول المنصة لا يرى بيانات المؤسسات عبر VPD؛ القراءة هنا بوضع النظام داخل استدعاء واحد مغلق
-- (begin_system ... end_system) ولا تعرض إلا مقاييس وبيانات تشغيلية، لا بيانات أعمال.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_PLATFORM_ADMIN_PKG AUTHID DEFINER AS

  -- مقياس لمؤسسة: COMPANIES / BRANCHES / USERS / MODULES / LAST_LOGIN
  FUNCTION tenant_metric(p_tenant_id IN NUMBER, p_metric IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION platform_summary RETURN CLOB;

  -- وحدات المؤسسة بخانات اختيار (class nn-mod، القيمة = رقم الوحدة)؛ الوحدات الأساسية دائماً مفعلة
  FUNCTION module_matrix(p_tenant_id IN NUMBER) RETURN CLOB;
  -- حفظ الاشتراك: المختار مفعل وغير المختار موقوف (يعيد 'enabled:disabled')
  FUNCTION set_tenant_modules(p_tenant_id IN NUMBER, p_module_ids IN VARCHAR2) RETURN VARCHAR2;

  -- حدود الاشتراك (USERS / BRANCHES / COMPANIES): رقم = حد أقصى، فارغ = بلا حد
  PROCEDURE set_tenant_limit(p_tenant_id IN NUMBER, p_metric_code IN VARCHAR2, p_limit IN NUMBER);
  FUNCTION tenant_limit(p_tenant_id IN NUMBER, p_metric_code IN VARCHAR2) RETURN NUMBER;

  -- مستخدمو المؤسسة المسؤولون (للدعم الفني: إعادة كلمة المرور)
  FUNCTION tenant_admins_html(p_tenant_id IN NUMBER) RETURN CLOB;

  -- سجل التدقيق (p_tenant_id فارغ = أحداث المنصة) وآخر p_limit حدث
  FUNCTION audit_html(p_tenant_id IN NUMBER DEFAULT NULL, p_limit IN PLS_INTEGER DEFAULT 100) RETURN CLOB;
  -- التحقق من سلسلة التدقيق: NULL = سليمة، وإلا رقم أول حدث غير مطابق
  FUNCTION verify_tenant_chain(p_tenant_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- الاشتراكات (فترة وباقة وتجديد وانتهاء)
  -- تسجيل/تعديل اشتراك المؤسسة الحالي بباقة (TRIAL/MONTHLY/QUARTERLY/SEMI_ANNUAL/ANNUAL) من تاريخ لعدد فترات
  -- (أو حتى تاريخ نهاية محدد)؛ يعيد رقم الاشتراك. يعيد تفعيل المؤسسة الموقوفة بسبب الانتهاء
  FUNCTION set_subscription(p_tenant_id IN NUMBER, p_plan_code IN VARCHAR2, p_start IN DATE, p_periods IN NUMBER DEFAULT 1,
                            p_end IN DATE DEFAULT NULL, p_note IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- تجديد لعدد فترات من نهاية الفترة (أو من اليوم إن كان منتهياً)، مع تغيير الباقة اختيارياً
  FUNCTION renew_subscription(p_tenant_id IN NUMBER, p_periods IN NUMBER DEFAULT 1, p_plan_code IN VARCHAR2 DEFAULT NULL,
                              p_note IN VARCHAR2 DEFAULT NULL) RETURN DATE;
  -- قواعد الانتهاء (يومياً): بعد نهاية الفترة ← فترة سماح ← قراءة فقط ← تعليق؛ يعيد عدد المؤسسات المتغيرة.
  -- لا يستدعى من جلسة مؤسسة
  FUNCTION apply_expiry RETURN NUMBER;
  -- حقل من الاشتراك الحالي لمؤسسة (لمسؤول المنصة): PLAN / CYCLE / START / END / LEFT / STATUS / NO
  FUNCTION sub_info(p_tenant_id IN NUMBER, p_field IN VARCHAR2) RETURN VARCHAR2;
  -- سجل التفعيل والتجديد وتغيير الباقة لمؤسسة
  FUNCTION subscription_history_html(p_tenant_id IN NUMBER) RETURN CLOB;
END NOONA_PLATFORM_ADMIN_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PLATFORM_ADMIN_PKG AS

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN NOONA_UI_PKG.esc(p);
  END esc;

  FUNCTION tenant_metric(p_tenant_id IN NUMBER, p_metric IN VARCHAR2) RETURN VARCHAR2 IS
    l_v VARCHAR2(100);
  BEGIN
    IF NVL(SYS_CONTEXT('NOONA_CTX', 'PLATFORM_ADMIN'), 'N') <> 'Y' THEN
      RETURN NULL;                                          -- لا يكشف شيئاً لغير مسؤول المنصة
    END IF;
    NOONA_CORE_PKG.begin_system;
    CASE p_metric
      WHEN 'COMPANIES' THEN SELECT TO_CHAR(COUNT(*)) INTO l_v FROM org_company WHERE tenant_id = p_tenant_id;
      WHEN 'BRANCHES' THEN SELECT TO_CHAR(COUNT(*)) INTO l_v FROM org_branch WHERE tenant_id = p_tenant_id AND status_code = 'ACTIVE';
      WHEN 'USERS' THEN SELECT TO_CHAR(COUNT(*)) INTO l_v FROM sec_user_membership WHERE tenant_id = p_tenant_id AND status_code = 'ACTIVE';
      WHEN 'MODULES' THEN
        SELECT CASE WHEN COUNT(*) = 0 THEN 'الكل' ELSE TO_CHAR(SUM(CASE WHEN is_enabled = 'Y' THEN 1 ELSE 0 END)) END INTO l_v
          FROM plt_entitlement WHERE tenant_id = p_tenant_id AND module_id IS NOT NULL AND feature_id IS NULL
           AND TRUNC(SYSDATE) BETWEEN effective_from AND NVL(effective_to, DATE '9999-12-31');
      WHEN 'LAST_LOGIN' THEN
        SELECT TO_CHAR(MAX(s.started_at), 'YYYY-MM-DD HH24:MI') INTO l_v FROM sec_session s WHERE s.tenant_id = p_tenant_id;
      ELSE l_v := NULL;
    END CASE;
    NOONA_CORE_PKG.end_system;
    RETURN l_v;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END tenant_metric;

  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_class VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span>'
        || '<div><div class="nn-kpi-value">' || esc(p_value) || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION platform_summary RETURN CLOB IS
    l_t NUMBER; l_act NUMBER; l_trial NUMBER; l_risk NUMBER; l_co NUMBER; l_users NUMBER; l_sess NUMBER;
    l_new NUMBER; l_soon NUMBER; l_exp NUMBER; l_ren NUMBER; l_none NUMBER;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.begin_system;
    SELECT COUNT(*) INTO l_new FROM plt_tenant WHERE created_at >= SYSTIMESTAMP - INTERVAL '30' DAY;
    SELECT COUNT(CASE WHEN e BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 30 THEN 1 END), COUNT(CASE WHEN e < TRUNC(SYSDATE) THEN 1 END)
      INTO l_soon, l_exp
      FROM (SELECT s.tenant_id, MAX(s.current_period_end) e FROM plt_subscription s JOIN plt_tenant t ON t.id = s.tenant_id
             WHERE s.status_code <> 'CANCELLED' AND t.status_code NOT IN ('CLOSED', 'ARCHIVED') GROUP BY s.tenant_id);
    SELECT COUNT(*) INTO l_ren FROM plt_subscription_snapshot WHERE snapshot_reason = 'RENEWAL' AND created_at >= TRUNC(SYSDATE, 'MM');
    SELECT COUNT(*) INTO l_none FROM plt_tenant t WHERE t.status_code NOT IN ('CLOSED', 'ARCHIVED')
       AND NOT EXISTS (SELECT 1 FROM plt_subscription s WHERE s.tenant_id = t.id AND s.status_code <> 'CANCELLED');
    SELECT COUNT(*), COUNT(CASE WHEN status_code = 'ACTIVE' THEN 1 END), COUNT(CASE WHEN status_code = 'TRIAL' THEN 1 END),
           COUNT(CASE WHEN status_code IN ('GRACE_PERIOD', 'READ_ONLY', 'SUSPENDED') THEN 1 END)
      INTO l_t, l_act, l_trial, l_risk FROM plt_tenant WHERE status_code NOT IN ('CLOSED', 'ARCHIVED');
    SELECT COUNT(*) INTO l_co FROM org_company WHERE status_code NOT IN ('CLOSED', 'ARCHIVED');
    SELECT COUNT(*) INTO l_users FROM sec_user_membership WHERE status_code = 'ACTIVE';
    SELECT COUNT(*) INTO l_sess FROM sec_session WHERE status_code = 'ACTIVE' AND started_at > SYSTIMESTAMP - INTERVAL '1' DAY;
    NOONA_CORE_PKG.end_system;
    RETURN '<div class="nn-hello"><div class="nn-hello-title">لوحة المنصة</div><div class="nn-hello-sub">'
        || '<span class="fa fa-server" aria-hidden="true"></span> ' || esc(NOONA_APEX_PKG.display_name) || '</div></div>'
        || '<div class="nn-kpis">'
        || kpi('مؤسسات مشتركة', l_t, 'fa-building', 'is-info')
        || kpi('نشطة', l_act, 'fa-check-circle', 'is-success')
        || kpi('تجريبية', l_trial, 'fa-flask', 'is-info')
        || kpi('بحاجة متابعة (سماح/قراءة/معلقة)', l_risk, 'fa-exclamation-triangle', CASE WHEN l_risk > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('شركات', l_co, 'fa-building-o', 'is-muted')
        || kpi('مستخدمون نشطون', l_users, 'fa-users', 'is-muted')
        || kpi('جلسات آخر 24 ساعة', l_sess, 'fa-sign-in', 'is-muted')
        || kpi('مشتركون جدد (30 يوماً)', l_new, 'fa-user-plus', 'is-success')
        || kpi('تنتهي خلال 30 يوماً', l_soon, 'fa-hourglass-half', CASE WHEN l_soon > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('اشتراكات منتهية', l_exp, 'fa-calendar-times-o', CASE WHEN l_exp > 0 THEN 'is-danger' ELSE 'is-muted' END)
        || kpi('تجديدات هذا الشهر', l_ren, 'fa-refresh', 'is-info')
        || kpi('بلا اشتراك مسجل', l_none, 'fa-question-circle', CASE WHEN l_none > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || '</div>';
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END platform_summary;

  FUNCTION module_matrix(p_tenant_id IN NUMBER) RETURN CLOB IS
    l_html CLOB;
    l_any  NUMBER;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    IF p_tenant_id IS NULL THEN
      RETURN '<div class="nn-empty">اختر المؤسسة</div>';
    END IF;
    NOONA_CORE_PKG.begin_system;
    SELECT COUNT(*) INTO l_any FROM plt_entitlement WHERE tenant_id = p_tenant_id AND module_id IS NOT NULL AND feature_id IS NULL;
    l_html := '<div class="nn-modgrid">';
    FOR m IN (SELECT md.id, md.module_code, md.name_ar, md.is_core,
                     (SELECT MAX(e.is_enabled) KEEP (DENSE_RANK LAST ORDER BY e.effective_from, e.id)
                        FROM plt_entitlement e
                       WHERE e.tenant_id = p_tenant_id AND e.module_id = md.id AND e.feature_id IS NULL
                         AND TRUNC(SYSDATE) BETWEEN e.effective_from AND NVL(e.effective_to, DATE '9999-12-31')) AS enabled
                FROM plt_module md WHERE md.is_active = 'Y' ORDER BY md.package_no) LOOP
      l_html := l_html || ('<label class="nn-mod' || CASE WHEN m.is_core = 'Y' THEN ' is-core' END || '">'
             || '<input type="checkbox" class="nn-mod-cb" value="' || m.id || '"'
             || CASE WHEN m.is_core = 'Y' OR l_any = 0 OR m.enabled = 'Y' THEN ' checked' END
             || CASE WHEN m.is_core = 'Y' THEN ' disabled' END || '>'
             || '<span class="nn-mod-code">' || esc(m.module_code) || '</span><span class="nn-mod-name">' || esc(m.name_ar)
             || CASE WHEN m.is_core = 'Y' THEN ' <small>(أساسية)</small>' END || '</span></label>');
    END LOOP;
    NOONA_CORE_PKG.end_system;
    RETURN l_html || ('</div>'
        || CASE WHEN l_any = 0 THEN '<div class="nn-empty is-warning">لم تحدد وحدات هذه المؤسسة بعد؛ كل الوحدات تعمل '
                                    || 'حتى تحفظ الاشتراك أول مرة</div>' END);
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END module_matrix;

  FUNCTION set_tenant_modules(p_tenant_id IN NUMBER, p_module_ids IN VARCHAR2) RETURN VARCHAR2 IS
    l_ids  VARCHAR2(4000) := ',' || REPLACE(p_module_ids, ' ') || ',';
    l_on   NUMBER := 0;
    l_off  NUMBER := 0;
    l_want VARCHAR2(1);
    l_cur  plt_entitlement%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(NOT REGEXP_LIKE(l_ids, '[^0-9,]'), 'NOONA-PLT-301', 'قائمة وحدات غير صالحة', 'Invalid module list');
    NOONA_CORE_PKG.begin_system;
    FOR m IN (SELECT id, is_core FROM plt_module WHERE is_active = 'Y') LOOP
      l_want := CASE WHEN m.is_core = 'Y' OR INSTR(l_ids, ',' || m.id || ',') > 0 THEN 'Y' ELSE 'N' END;
      BEGIN
        SELECT * INTO l_cur FROM plt_entitlement
         WHERE tenant_id = p_tenant_id AND module_id = m.id AND feature_id IS NULL AND metric_id IS NULL
           AND TRUNC(SYSDATE) BETWEEN effective_from AND NVL(effective_to, DATE '9999-12-31')
           AND ROWNUM = 1;
        IF l_cur.is_enabled <> l_want THEN
          UPDATE plt_entitlement SET is_enabled = l_want, computed_at = SYSTIMESTAMP WHERE id = l_cur.id;
          IF l_want = 'Y' THEN l_on := l_on + 1; ELSE l_off := l_off + 1; END IF;
        END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        INSERT INTO plt_entitlement (tenant_id, module_id, is_enabled, source_code)
        VALUES (p_tenant_id, m.id, l_want, 'CONTRACT_OVERRIDE');
        IF l_want = 'Y' THEN l_on := l_on + 1; ELSE l_off := l_off + 1; END IF;
      END;
    END LOOP;
    NOONA_CORE_PKG.end_system;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', p_tenant_id, 'SET_MODULES', 'SUCCESS',
      p_new_values => '{"enabled":' || l_on || ',"disabled":' || l_off || '}');
    RETURN l_on || ':' || l_off;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END set_tenant_modules;

  FUNCTION tenant_limit(p_tenant_id IN NUMBER, p_metric_code IN VARCHAR2) RETURN NUMBER IS
    l_v NUMBER;
  BEGIN
    IF NVL(SYS_CONTEXT('NOONA_CTX', 'PLATFORM_ADMIN'), 'N') <> 'Y' THEN
      RETURN NULL;
    END IF;
    NOONA_CORE_PKG.begin_system;
    SELECT MIN(NVL(e.hard_limit, e.limit_qty)) INTO l_v
      FROM plt_entitlement e JOIN plt_usage_metric m ON m.id = e.metric_id
     WHERE e.tenant_id = p_tenant_id AND m.code = p_metric_code AND e.is_enabled = 'Y'
       AND TRUNC(SYSDATE) BETWEEN e.effective_from AND NVL(e.effective_to, DATE '9999-12-31');
    NOONA_CORE_PKG.end_system;
    RETURN l_v;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END tenant_limit;

  PROCEDURE set_tenant_limit(p_tenant_id IN NUMBER, p_metric_code IN VARCHAR2, p_limit IN NUMBER) IS
    l_metric NUMBER;
    l_id     NUMBER;
    l_used   NUMBER;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(p_metric_code IN ('USERS', 'BRANCHES', 'COMPANIES'), 'NOONA-PLT-302',
      'مقياس غير مدعوم', 'Unsupported metric');
    NOONA_CORE_PKG.assert(p_limit IS NULL OR p_limit >= 1, 'NOONA-PLT-303', 'الحد يجب أن يكون 1 على الأقل', 'Limit must be at least 1');
    NOONA_CORE_PKG.begin_system;
    SELECT id INTO l_metric FROM plt_usage_metric WHERE code = p_metric_code;
    -- لا يقل الحد عن الاستخدام الحالي (لا تتعطل المؤسسة فجأة)
    l_used := TO_NUMBER(CASE p_metric_code
                          WHEN 'USERS' THEN tenant_metric(p_tenant_id, 'USERS')
                          WHEN 'BRANCHES' THEN tenant_metric(p_tenant_id, 'BRANCHES')
                          ELSE tenant_metric(p_tenant_id, 'COMPANIES') END);
    NOONA_CORE_PKG.assert(p_limit IS NULL OR p_limit >= NVL(l_used, 0), 'NOONA-PLT-304',
      'الحد أقل من الاستخدام الحالي (' || l_used || ')', 'Limit is below current usage');
    SELECT MIN(id) INTO l_id FROM plt_entitlement
     WHERE tenant_id = p_tenant_id AND metric_id = l_metric AND module_id IS NULL AND feature_id IS NULL
       AND TRUNC(SYSDATE) BETWEEN effective_from AND NVL(effective_to, DATE '9999-12-31');
    IF l_id IS NULL THEN
      INSERT INTO plt_entitlement (tenant_id, metric_id, is_enabled, limit_qty, hard_limit, source_code)
      VALUES (p_tenant_id, l_metric, CASE WHEN p_limit IS NULL THEN 'N' ELSE 'Y' END, p_limit, p_limit, 'CONTRACT_OVERRIDE');
    ELSE
      UPDATE plt_entitlement
         SET limit_qty = p_limit, hard_limit = p_limit, is_enabled = CASE WHEN p_limit IS NULL THEN 'N' ELSE 'Y' END,
             computed_at = SYSTIMESTAMP
       WHERE id = l_id;
    END IF;
    NOONA_CORE_PKG.end_system;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', p_tenant_id, 'SET_LIMIT:' || p_metric_code, 'SUCCESS',
      p_new_values => '{"limit":' || NVL(TO_CHAR(p_limit), 'null') || '}');
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END set_tenant_limit;

  FUNCTION tenant_admins_html(p_tenant_id IN NUMBER) RETURN CLOB IS
    l_html CLOB := '<table class="nn-table"><thead><tr><th>اسم الدخول</th><th>الاسم</th><th>البريد</th><th>آخر دخول</th><th>الحالة</th></tr></thead><tbody>';
    l_n    PLS_INTEGER := 0;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.begin_system;
    FOR u IN (SELECT u.username, u.display_name, u.email, u.last_login_at, m.status_code
                FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
               WHERE m.tenant_id = p_tenant_id AND m.is_tenant_admin = 'Y' ORDER BY u.username) LOOP
      l_n := l_n + 1;
      l_html := l_html || ('<tr><td>' || esc(u.username) || '</td><td>' || esc(u.display_name) || '</td><td>' || esc(u.email)
             || '</td><td>' || TO_CHAR(u.last_login_at, 'YYYY-MM-DD HH24:MI') || '</td><td>' || NOONA_UI_PKG.status_badge(u.status_code) || '</td></tr>');
    END LOOP;
    NOONA_CORE_PKG.end_system;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty">لا يوجد مسؤول لهذه المؤسسة</div>';
    END IF;
    RETURN l_html || ('</tbody></table>');
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END tenant_admins_html;

  FUNCTION audit_html(p_tenant_id IN NUMBER DEFAULT NULL, p_limit IN PLS_INTEGER DEFAULT 100) RETURN CLOB IS
    l_html CLOB := '<table class="nn-table"><thead><tr><th>رقم الحدث</th><th>الوقت</th><th>الفئة</th><th>الكيان</th>'
                || '<th>الإجراء</th><th>النتيجة</th><th>المستخدم</th><th>السبب</th></tr></thead><tbody>';
    l_row  VARCHAR2(32767);
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.begin_system;
    FOR e IN (SELECT * FROM (
                SELECT a.id, a.occurred_at, a.event_category, a.entity_type, a.entity_id, a.action_code, a.result_code, a.reason,
                       (SELECT u.username FROM sec_user u WHERE u.id = a.actor_user_id) AS actor
                  FROM aud_event a
                 WHERE (a.tenant_id = p_tenant_id OR (p_tenant_id IS NULL AND a.tenant_id IS NULL))
                 ORDER BY a.id DESC) WHERE ROWNUM <= p_limit) LOOP
      -- كل صف يبنى منفصلاً: حدث واحد بقيمة غير متوقعة لا يوقف عرض السجل كله
      BEGIN
        l_row := '<tr><td>' || TO_CHAR(e.id) || '</td><td>' || TO_CHAR(e.occurred_at, 'YYYY-MM-DD HH24:MI:SS') || '</td><td>'
              || esc(SUBSTR(NOONA_UI_PKG.code_label(e.event_category), 1, 200)) || '</td><td>'
              || esc(SUBSTR(e.entity_type, 1, 100)) || ' #' || SUBSTR(TO_CHAR(e.entity_id), 1, 40)
              || '</td><td>' || esc(SUBSTR(e.action_code, 1, 100)) || '</td><td>'
              || NOONA_UI_PKG.status_badge(SUBSTR(e.result_code, 1, 30)) || '</td><td>'
              || esc(SUBSTR(e.actor, 1, 128)) || '</td><td>' || esc(SUBSTR(e.reason, 1, 1000)) || '</td></tr>';
      EXCEPTION WHEN OTHERS THEN
        l_row := '<tr><td>' || TO_CHAR(e.id) || '</td><td colspan="7">تعذر عرض تفاصيل الحدث: '
              || esc(SUBSTR(SQLERRM, 1, 300)) || '</td></tr>';
      END;
      DBMS_LOB.APPEND(l_html, TO_CLOB(l_row));
    END LOOP;
    NOONA_CORE_PKG.end_system;
    RETURN l_html || ('</tbody></table>');
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END audit_html;

  FUNCTION verify_tenant_chain(p_tenant_id IN NUMBER) RETURN NUMBER IS
    l_bad NUMBER;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.begin_system;
    l_bad := NOONA_AUDIT_PKG.verify_chain(p_tenant_id);
    NOONA_CORE_PKG.end_system;
    RETURN l_bad;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END verify_tenant_chain;

  -- ================================================================ الاشتراكات
  FUNCTION cycle_months(p_cycle VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE p_cycle WHEN 'MONTHLY' THEN 1 WHEN 'QUARTERLY' THEN 3 WHEN 'SEMI_ANNUAL' THEN 6 WHEN 'ANNUAL' THEN 12
                        WHEN 'MULTI_YEAR' THEN 24 ELSE 0 END;
  END cycle_months;

  FUNCTION plan_version(p_plan_code VARCHAR2) RETURN plt_plan_version%ROWTYPE IS
    l plt_plan_version%ROWTYPE;
  BEGIN
    SELECT v.* INTO l FROM plt_plan_version v JOIN plt_plan p ON p.id = v.plan_id
     WHERE p.code = UPPER(p_plan_code) AND p.is_active = 'Y' AND v.status_code = 'PUBLISHED'
       AND v.version_no = (SELECT MAX(x.version_no) FROM plt_plan_version x WHERE x.plan_id = p.id AND x.status_code = 'PUBLISHED');
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PLT-320', 'الباقة غير موجودة أو غير منشورة: ' || p_plan_code, 'Plan not found');
  END plan_version;

  FUNCTION current_sub(p_tenant_id NUMBER) RETURN plt_subscription%ROWTYPE IS
    l plt_subscription%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM (SELECT * FROM plt_subscription WHERE tenant_id = p_tenant_id AND status_code <> 'CANCELLED'
                           ORDER BY current_period_end DESC NULLS LAST, id DESC) WHERE ROWNUM = 1;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN l;
  END current_sub;

  PROCEDURE snapshot(p_tenant_id NUMBER, p_sub NUMBER, p_reason VARCHAR2, p_note VARCHAR2) IS
    l plt_subscription%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM plt_subscription WHERE id = p_sub;
    INSERT INTO plt_subscription_snapshot (tenant_id, subscription_id, snapshot_reason, snapshot_data)
    VALUES (p_tenant_id, p_sub, p_reason,
            JSON_OBJECT('plan_version' VALUE l.plan_version_id, 'cycle' VALUE l.billing_cycle,
                        'start' VALUE TO_CHAR(l.current_period_start, 'YYYY-MM-DD'), 'end' VALUE TO_CHAR(l.current_period_end, 'YYYY-MM-DD'),
                        'status' VALUE l.status_code, 'note' VALUE p_note, 'by' VALUE NOONA_CTX_PKG.current_user_name));
  END snapshot;

  -- إعادة تفعيل مؤسسة أوقفت بسبب الانتهاء أو كانت تجريبية وأصبحت مدفوعة
  PROCEDURE reactivate(p_tenant_id NUMBER, p_trial BOOLEAN, p_reason VARCHAR2) IS
    l_st VARCHAR2(30);
  BEGIN
    SELECT status_code INTO l_st FROM plt_tenant WHERE id = p_tenant_id;
    IF l_st IN ('GRACE_PERIOD', 'READ_ONLY', 'SUSPENDED') OR (l_st IN ('TRIAL', 'PENDING_ACTIVATION') AND NOT p_trial) THEN
      NOONA_PLATFORM_PKG.system_set_status(p_tenant_id, 'ACTIVE', p_reason);
    END IF;
  END reactivate;

  FUNCTION set_subscription(p_tenant_id IN NUMBER, p_plan_code IN VARCHAR2, p_start IN DATE, p_periods IN NUMBER DEFAULT 1,
                            p_end IN DATE DEFAULT NULL, p_note IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_pv    plt_plan_version%ROWTYPE;
    l_cycle VARCHAR2(30);
    l_sub   plt_subscription%ROWTYPE;
    l_start DATE := TRUNC(NVL(p_start, SYSDATE));
    l_end   DATE;
    l_trial BOOLEAN;
    l_tr    VARCHAR2(1);
    l_code  VARCHAR2(30);
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(NVL(p_periods, 1) BETWEEN 1 AND 60, 'NOONA-PLT-321', 'عدد الفترات بين 1 و 60', 'Periods must be 1-60');
    NOONA_CORE_PKG.begin_system;
    l_pv := plan_version(p_plan_code);
    SELECT billing_cycle INTO l_cycle FROM plt_plan WHERE id = l_pv.plan_id;
    l_trial := NVL(l_pv.trial_days, 0) > 0;
    l_tr := CASE WHEN l_trial THEN 'Y' ELSE 'N' END;
    l_end := TRUNC(NVL(p_end, CASE WHEN l_trial THEN l_start + l_pv.trial_days - 1
                                    ELSE ADD_MONTHS(l_start, cycle_months(l_cycle) * NVL(p_periods, 1)) - 1 END));
    NOONA_CORE_PKG.assert(l_end >= l_start, 'NOONA-PLT-322', 'نهاية الفترة قبل بدايتها', 'Period end is before its start');
    l_sub := current_sub(p_tenant_id);
    IF l_sub.id IS NULL THEN
      SELECT tenant_code INTO l_code FROM plt_tenant WHERE id = p_tenant_id;
      INSERT INTO plt_subscription (tenant_id, subscription_no, plan_version_id, billing_cycle, current_period_start, current_period_end,
                                    next_billing_date, status_code)
      VALUES (p_tenant_id, 'SUB-' || l_code || '-' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS'), l_pv.id, CASE WHEN l_tr = 'Y' THEN 'ONE_TIME' ELSE l_cycle END,
              l_start, l_end, CASE WHEN l_tr = 'N' THEN l_end + 1 END, CASE WHEN l_tr = 'Y' THEN 'TRIAL' ELSE 'ACTIVE' END)
      RETURNING id INTO l_sub.id;
      snapshot(p_tenant_id, l_sub.id, 'ACTIVATION', p_note);
    ELSE
      UPDATE plt_subscription
         SET plan_version_id = l_pv.id, billing_cycle = CASE WHEN l_tr = 'Y' THEN 'ONE_TIME' ELSE l_cycle END, current_period_start = l_start,
             current_period_end = l_end, next_billing_date = CASE WHEN l_tr = 'N' THEN l_end + 1 END, grace_ends_at = NULL,
             read_only_ends_at = NULL, status_code = CASE WHEN l_tr = 'Y' THEN 'TRIAL' ELSE 'ACTIVE' END
       WHERE id = l_sub.id;
      snapshot(p_tenant_id, l_sub.id, CASE WHEN l_sub.plan_version_id = l_pv.id THEN 'AMENDMENT' ELSE 'UPGRADE' END, p_note);
    END IF;
    IF l_end >= TRUNC(SYSDATE) THEN
      reactivate(p_tenant_id, l_trial, 'تسجيل الاشتراك: ' || p_plan_code || ' حتى ' || TO_CHAR(l_end, 'YYYY-MM-DD'));
    END IF;
    NOONA_CORE_PKG.end_system;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', p_tenant_id, 'SET_SUBSCRIPTION', 'SUCCESS',
      p_new_values => '{"plan":"' || UPPER(p_plan_code) || '","start":"' || TO_CHAR(l_start, 'YYYY-MM-DD') || '","end":"' || TO_CHAR(l_end, 'YYYY-MM-DD') || '"}',
      p_reason => p_note);
    RETURN l_sub.id;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END set_subscription;

  FUNCTION renew_subscription(p_tenant_id IN NUMBER, p_periods IN NUMBER DEFAULT 1, p_plan_code IN VARCHAR2 DEFAULT NULL,
                              p_note IN VARCHAR2 DEFAULT NULL) RETURN DATE IS
    l_sub   plt_subscription%ROWTYPE;
    l_pv    plt_plan_version%ROWTYPE;
    l_cycle VARCHAR2(30);
    l_start DATE;
    l_end   DATE;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(NVL(p_periods, 1) BETWEEN 1 AND 60, 'NOONA-PLT-321', 'عدد الفترات بين 1 و 60', 'Periods must be 1-60');
    NOONA_CORE_PKG.begin_system;
    l_sub := current_sub(p_tenant_id);
    NOONA_CORE_PKG.assert(l_sub.id IS NOT NULL, 'NOONA-PLT-323', 'لا يوجد اشتراك مسجل للمؤسسة؛ سجل الاشتراك أولاً', 'No subscription to renew');
    IF p_plan_code IS NOT NULL THEN
      l_pv := plan_version(p_plan_code);
    ELSE
      SELECT * INTO l_pv FROM plt_plan_version WHERE id = l_sub.plan_version_id;
    END IF;
    SELECT billing_cycle INTO l_cycle FROM plt_plan WHERE id = l_pv.plan_id;
    NOONA_CORE_PKG.assert(cycle_months(l_cycle) > 0, 'NOONA-PLT-324', 'اختر باقة مدفوعة للتجديد (التجربة لا تجدد)',
                          'Choose a paid plan to renew');
    -- التجديد يكمل من نهاية الفترة؛ الاشتراك المنتهي يبدأ من اليوم
    l_start := CASE WHEN l_sub.current_period_end >= TRUNC(SYSDATE) THEN l_sub.current_period_end + 1 ELSE TRUNC(SYSDATE) END;
    l_end := ADD_MONTHS(l_start, cycle_months(l_cycle) * NVL(p_periods, 1)) - 1;
    UPDATE plt_subscription
       SET plan_version_id = l_pv.id, billing_cycle = l_cycle, current_period_start = l_start, current_period_end = l_end,
           next_billing_date = l_end + 1, grace_ends_at = NULL, read_only_ends_at = NULL, status_code = 'ACTIVE'
     WHERE id = l_sub.id;
    snapshot(p_tenant_id, l_sub.id, 'RENEWAL', p_note);
    reactivate(p_tenant_id, FALSE, 'تجديد الاشتراك حتى ' || TO_CHAR(l_end, 'YYYY-MM-DD'));
    NOONA_CORE_PKG.end_system;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', p_tenant_id, 'RENEW_SUBSCRIPTION', 'SUCCESS',
      p_new_values => '{"periods":' || NVL(p_periods, 1) || ',"end":"' || TO_CHAR(l_end, 'YYYY-MM-DD') || '"}', p_reason => p_note);
    RETURN l_end;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END renew_subscription;

  FUNCTION apply_expiry RETURN NUMBER IS
    l_n      NUMBER := 0;
    l_target VARCHAR2(30);
    l_st     VARCHAR2(30);
    l_next   VARCHAR2(30);
    FUNCTION rnk(p VARCHAR2) RETURN NUMBER IS
    BEGIN
      RETURN CASE p WHEN 'GRACE_PERIOD' THEN 1 WHEN 'READ_ONLY' THEN 2 WHEN 'SUSPENDED' THEN 3 ELSE 0 END;
    END rnk;
  BEGIN
    NOONA_CORE_PKG.assert(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID') IS NULL, 'NOONA-PLT-325', 'قواعد الانتهاء تنفذ من المنصة فقط',
                          'Expiry rules run from the platform only');
    NOONA_CORE_PKG.begin_system;
    FOR r IN (SELECT s.id, s.tenant_id, s.current_period_end e, s.status_code sst, t.status_code tst, t.tenant_code,
                     NVL(v.trial_days, 0) trial, v.grace_days, v.read_only_days
                FROM plt_subscription s JOIN plt_tenant t ON t.id = s.tenant_id JOIN plt_plan_version v ON v.id = s.plan_version_id
               WHERE s.status_code <> 'CANCELLED' AND s.current_period_end < TRUNC(SYSDATE)
                 AND t.status_code IN ('TRIAL', 'ACTIVE', 'GRACE_PERIOD', 'READ_ONLY')
                 AND s.id = (SELECT MAX(x.id) KEEP (DENSE_RANK LAST ORDER BY x.current_period_end) FROM plt_subscription x
                              WHERE x.tenant_id = s.tenant_id AND x.status_code <> 'CANCELLED')) LOOP
      -- التجربة: قراءة فقط مباشرة ثم تعليق؛ المدفوع: سماح ثم قراءة فقط ثم تعليق
      l_target := CASE WHEN r.trial = 0 AND TRUNC(SYSDATE) - r.e <= r.grace_days THEN 'GRACE_PERIOD'
                       WHEN TRUNC(SYSDATE) - r.e <= CASE WHEN r.trial = 0 THEN r.grace_days ELSE 0 END + r.read_only_days THEN 'READ_ONLY'
                       ELSE 'SUSPENDED' END;
      UPDATE plt_subscription
         SET status_code = CASE l_target WHEN 'GRACE_PERIOD' THEN 'GRACE_PERIOD' WHEN 'READ_ONLY' THEN 'READ_ONLY' ELSE 'EXPIRED' END,
             grace_ends_at = CAST(r.e + CASE WHEN r.trial = 0 THEN r.grace_days ELSE 0 END + 1 AS TIMESTAMP),
             read_only_ends_at = CAST(r.e + CASE WHEN r.trial = 0 THEN r.grace_days ELSE 0 END + r.read_only_days + 1 AS TIMESTAMP)
       WHERE id = r.id;
      -- تصعيد حالة المؤسسة فقط (لا يخفض حالة وضعها مسؤول المنصة) بالمسارات المسموحة:
      -- من التجربة أو فترة السماح إلى التعليق يمر بالقراءة فقط
      l_st := r.tst;
      IF rnk(l_target) > rnk(l_st) THEN
        l_n := l_n + 1;
      END IF;
      WHILE rnk(l_target) > rnk(l_st) LOOP
        l_next := CASE WHEN l_st IN ('TRIAL', 'GRACE_PERIOD') AND l_target = 'SUSPENDED' THEN 'READ_ONLY' ELSE l_target END;
        NOONA_PLATFORM_PKG.system_set_status(r.tenant_id, l_next, 'انتهاء الاشتراك في ' || TO_CHAR(r.e, 'YYYY-MM-DD'));
        l_st := l_next;
      END LOOP;
    END LOOP;
    NOONA_CORE_PKG.end_system;
    RETURN l_n;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END apply_expiry;

  FUNCTION sub_info(p_tenant_id IN NUMBER, p_field IN VARCHAR2) RETURN VARCHAR2 IS
    l_sub plt_subscription%ROWTYPE;
    l_v   VARCHAR2(400);
  BEGIN
    IF NVL(SYS_CONTEXT('NOONA_CTX', 'PLATFORM_ADMIN'), 'N') <> 'Y' THEN
      RETURN NULL;
    END IF;
    NOONA_CORE_PKG.begin_system;
    l_sub := current_sub(p_tenant_id);
    IF l_sub.id IS NOT NULL THEN
      l_v := CASE p_field
               WHEN 'START' THEN TO_CHAR(l_sub.current_period_start, 'YYYY-MM-DD')
               WHEN 'END' THEN TO_CHAR(l_sub.current_period_end, 'YYYY-MM-DD')
               WHEN 'LEFT' THEN TO_CHAR(l_sub.current_period_end - TRUNC(SYSDATE))
               WHEN 'STATUS' THEN l_sub.status_code
               WHEN 'NO' THEN l_sub.subscription_no
               WHEN 'CYCLE' THEN l_sub.billing_cycle END;
      IF p_field IN ('PLAN', 'PLAN_CODE') THEN
        SELECT CASE p_field WHEN 'PLAN' THEN p.name_ar ELSE p.code END INTO l_v
          FROM plt_plan_version v JOIN plt_plan p ON p.id = v.plan_id WHERE v.id = l_sub.plan_version_id;
      END IF;
    END IF;
    NOONA_CORE_PKG.end_system;
    RETURN l_v;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END sub_info;

  FUNCTION subscription_history_html(p_tenant_id IN NUMBER) RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.begin_system;
    l_html := '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>الإجراء</th><th>الباقة</th><th>من</th><th>إلى</th><th>بواسطة</th>'
           || '<th>ملاحظة</th></tr></thead><tbody>';
    FOR r IN (SELECT n.created_at, n.snapshot_reason, n.snapshot_data,
                     (SELECT p.name_ar FROM plt_plan_version v JOIN plt_plan p ON p.id = v.plan_id
                       WHERE v.id = JSON_VALUE(n.snapshot_data, '$.plan_version' RETURNING NUMBER)) plan
                FROM plt_subscription_snapshot n WHERE n.tenant_id = p_tenant_id ORDER BY n.id DESC) LOOP
      l_n := l_n + 1;
      l_html := l_html || (('<tr><td>' || TO_CHAR(r.created_at, 'YYYY-MM-DD HH24:MI') || '</td><td>'
             || CASE r.snapshot_reason WHEN 'ACTIVATION' THEN 'تفعيل' WHEN 'RENEWAL' THEN 'تجديد' WHEN 'UPGRADE' THEN 'تغيير الباقة'
                                       WHEN 'AMENDMENT' THEN 'تعديل الفترة' ELSE r.snapshot_reason END
             || '</td><td>' || esc(r.plan) || '</td><td>' || esc(JSON_VALUE(r.snapshot_data, '$.start')) || '</td><td>'
             || esc(JSON_VALUE(r.snapshot_data, '$.end')) || '</td><td>' || esc(JSON_VALUE(r.snapshot_data, '$.by')) || '</td><td class="nn-rpt-text">'
             || esc(JSON_VALUE(r.snapshot_data, '$.note')) || '</td></tr>'));
    END LOOP;
    NOONA_CORE_PKG.end_system;
    IF l_n = 0 THEN
      l_html := l_html || ('<tr><td colspan="7">لم يسجل اشتراك بعد</td></tr>');
    END IF;
    RETURN l_html || ('</tbody></table>');
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END subscription_history_html;

END NOONA_PLATFORM_ADMIN_PKG;
/
