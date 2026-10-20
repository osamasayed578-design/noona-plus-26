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

  -- مستخدمو المؤسسة المسؤولون (للدعم الفني: إعادة كلمة المرور)
  FUNCTION tenant_admins_html(p_tenant_id IN NUMBER) RETURN CLOB;

  -- سجل التدقيق (p_tenant_id فارغ = أحداث المنصة) وآخر p_limit حدث
  FUNCTION audit_html(p_tenant_id IN NUMBER DEFAULT NULL, p_limit IN PLS_INTEGER DEFAULT 100) RETURN CLOB;
  -- التحقق من سلسلة التدقيق: NULL = سليمة، وإلا رقم أول حدث غير مطابق
  FUNCTION verify_tenant_chain(p_tenant_id IN NUMBER) RETURN NUMBER;
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
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.begin_system;
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
      l_html := l_html || '<label class="nn-mod' || CASE WHEN m.is_core = 'Y' THEN ' is-core' END || '">'
             || '<input type="checkbox" class="nn-mod-cb" value="' || m.id || '"'
             || CASE WHEN m.is_core = 'Y' OR l_any = 0 OR m.enabled = 'Y' THEN ' checked' END
             || CASE WHEN m.is_core = 'Y' THEN ' disabled' END || '>'
             || '<span class="nn-mod-code">' || esc(m.module_code) || '</span><span class="nn-mod-name">' || esc(m.name_ar)
             || CASE WHEN m.is_core = 'Y' THEN ' <small>(أساسية)</small>' END || '</span></label>';
    END LOOP;
    NOONA_CORE_PKG.end_system;
    RETURN l_html || '</div>'
        || CASE WHEN l_any = 0 THEN '<div class="nn-empty is-warning">لا يوجد اشتراك مسجل لهذه المؤسسة بعد؛ كل الوحدات تعمل '
                                    || 'حتى تحفظ الاشتراك أول مرة</div>' END;
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
      l_html := l_html || '<tr><td>' || esc(u.username) || '</td><td>' || esc(u.display_name) || '</td><td>' || esc(u.email)
             || '</td><td>' || TO_CHAR(u.last_login_at, 'YYYY-MM-DD HH24:MI') || '</td><td>' || NOONA_UI_PKG.status_badge(u.status_code) || '</td></tr>';
    END LOOP;
    NOONA_CORE_PKG.end_system;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty">لا يوجد مسؤول لهذه المؤسسة</div>';
    END IF;
    RETURN l_html || '</tbody></table>';
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END tenant_admins_html;

  FUNCTION audit_html(p_tenant_id IN NUMBER DEFAULT NULL, p_limit IN PLS_INTEGER DEFAULT 100) RETURN CLOB IS
    l_html CLOB := '<table class="nn-table"><thead><tr><th>رقم الحدث</th><th>الوقت</th><th>الفئة</th><th>الكيان</th>'
                || '<th>الإجراء</th><th>النتيجة</th><th>المستخدم</th><th>السبب</th></tr></thead><tbody>';
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.begin_system;
    FOR e IN (SELECT * FROM (
                SELECT a.id, a.occurred_at, a.event_category, a.entity_type, a.entity_id, a.action_code, a.result_code, a.reason,
                       (SELECT u.username FROM sec_user u WHERE u.id = a.actor_user_id) AS actor
                  FROM aud_event a
                 WHERE (a.tenant_id = p_tenant_id OR (p_tenant_id IS NULL AND a.tenant_id IS NULL))
                 ORDER BY a.id DESC) WHERE ROWNUM <= p_limit) LOOP
      l_html := l_html || '<tr><td>' || e.id || '</td><td>' || TO_CHAR(e.occurred_at, 'YYYY-MM-DD HH24:MI:SS') || '</td><td>'
             || esc(NOONA_UI_PKG.code_label(e.event_category)) || '</td><td>' || esc(e.entity_type) || ' #' || e.entity_id
             || '</td><td>' || esc(e.action_code) || '</td><td>' || NOONA_UI_PKG.status_badge(e.result_code) || '</td><td>'
             || esc(e.actor) || '</td><td>' || esc(e.reason) || '</td></tr>';
    END LOOP;
    NOONA_CORE_PKG.end_system;
    RETURN l_html || '</tbody></table>';
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

END NOONA_PLATFORM_ADMIN_PKG;
/
