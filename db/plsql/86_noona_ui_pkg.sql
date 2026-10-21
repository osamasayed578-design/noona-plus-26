-- =============================================================================
-- NOONA PLUS ERP | NOONA_UI_PKG - مكونات واجهة HTML لمناطق PL/SQL Dynamic Content في APEX
--   * كل نص من البيانات يمر عبر esc() (منع XSS)؛ لا تعتمد على كائنات APEX (تترجم في أي قاعدة)
--   * السرعة: استعلام واحد لكل مكون، حد أقصى للصفوف، بلا JavaScript؛ التنسيق في noona.css
--   * الروابط بأسماء التطبيقات والصفحات المستعارة + رقم جلسة APEX (يمرر من المنطقة)
-- الاستخدام في APEX (Region: Dynamic Content، PL/SQL Function Body returning CLOB):
--   return noona_ui_pkg.task_cards(p_session => :APP_SESSION);
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_UI_PKG AUTHID DEFINER AS

  FUNCTION esc(p_text IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
  FUNCTION url(p_app IN VARCHAR2, p_page IN VARCHAR2, p_session IN VARCHAR2,
               p_items IN VARCHAR2 DEFAULT NULL, p_values IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  -- البوابة
  FUNCTION home_summary(p_session IN VARCHAR2) RETURN CLOB;
  FUNCTION app_cards(p_session IN VARCHAR2, p_existing_aliases IN VARCHAR2) RETURN CLOB;
  -- شاشة الأنظمة في التطبيق الرئيسي: الأنظمة المشترك فيها والمخصصة للمستخدم فقط،
  -- وتخطيط يتكيف مع عددها (is-few / is-mid / is-many)
  FUNCTION launcher(p_session IN VARCHAR2, p_existing_aliases IN VARCHAR2) RETURN CLOB;
  FUNCTION task_cards(p_session IN VARCHAR2, p_limit IN PLS_INTEGER DEFAULT 20) RETURN CLOB;
  FUNCTION notification_list(p_session IN VARCHAR2, p_limit IN PLS_INTEGER DEFAULT 10) RETURN CLOB;

  -- حالات موحدة: تسمية عربية وشارة ملونة (تستخدم في التقارير بعرض HTML)
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
  FUNCTION status_badge(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
  -- تسميات رموز شائعة: فحوص التفعيل، أنواع الفروع، نعم/لا
  FUNCTION code_label(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

  -- لوحة إدارة المؤسسة
  FUNCTION admin_summary(p_session IN VARCHAR2) RETURN CLOB;

  -- مصفوفة صلاحيات الدور لوحدة: صف لكل عنصر وعمود لكل فعل، بخانات اختيار (class nn-perm، القيمة = رقم الصلاحية)
  -- صلاحيات المنع (DENY) تظهر معطلة؛ وصلاحيات CONFIGURE لا تظهر (لا تمنح لأدوار المؤسسة)
  FUNCTION permission_matrix(p_role_id IN NUMBER, p_module_code IN VARCHAR2) RETURN CLOB;
  FUNCTION action_label(p_action IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

  -- مسارات الاعتماد: اسم المكلف حسب قاعدة الإسناد، ومخطط الإصدار (خطوات مرتبة من البداية مع الانتقالات)
  FUNCTION assignee_label(p_rule IN VARCHAR2, p_ref_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION workflow_diagram(p_version_id IN NUMBER) RETURN CLOB;
  -- بطاقة ملخص التفويض: المانح والمفوض إليه والمدة والحالة والحدود
  FUNCTION delegation_header(p_delegation_id IN NUMBER) RETURN CLOB;

  -- صفحة المهمة
  FUNCTION task_header(p_task_id IN NUMBER) RETURN CLOB;
  FUNCTION task_timeline(p_task_id IN NUMBER) RETURN CLOB;
END NOONA_UI_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_UI_PKG AS

  c_portal CONSTANT VARCHAR2(30) := 'NOONA_PORTAL';

  FUNCTION esc(p_text IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p_text, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'),
                           '"', '&quot;'), '''', '&#x27;');
  END esc;

  FUNCTION url(p_app IN VARCHAR2, p_page IN VARCHAR2, p_session IN VARCHAR2,
               p_items IN VARCHAR2 DEFAULT NULL, p_values IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    -- القيم أرقام أو رموز داخلية فقط؛ تُرمّز للأمان
    RETURN 'f?p=' || p_app || ':' || p_page || ':' || REGEXP_REPLACE(p_session, '[^0-9]', '') ||
           CASE WHEN p_items IS NOT NULL THEN '::NO::' || p_items || ':' || esc(p_values) END;
  END url;

  FUNCTION fmt_amount(p_amount NUMBER, p_currency VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_amount IS NULL THEN NULL
                ELSE TRIM(TO_CHAR(p_amount, 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,''')) || ' ' || esc(p_currency) END;
  END fmt_amount;

  FUNCTION fmt_time(p_ts TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(p_ts, 'YYYY-MM-DD HH24:MI');
  END fmt_time;

  FUNCTION priority_class(p_code VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'VERY_URGENT' THEN 'is-danger' WHEN 'URGENT' THEN 'is-danger'
                       WHEN 'HIGH' THEN 'is-warning' WHEN 'LOW' THEN 'is-muted' ELSE 'is-info' END;
  END priority_class;

  FUNCTION kpi(p_label VARCHAR2, p_value NUMBER, p_icon VARCHAR2, p_class VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span>'
        || '<div><div class="nn-kpi-value">' || NVL(p_value, 0) || '</div><div class="nn-kpi-label">' || esc(p_label)
        || '</div></div></div>';
  END kpi;

  -- ---------------------------------------------------------------- البوابة
  FUNCTION home_summary(p_session IN VARCHAR2) RETURN CLOB IS
    l_open    NUMBER;
    l_overdue NUMBER;
    l_unread  NUMBER;
    l_apps    NUMBER;
  BEGIN
    SELECT (SELECT COUNT(*) FROM noona_v_my_tasks),
           (SELECT COUNT(*) FROM noona_v_my_tasks WHERE is_overdue = 'Y'),
           (SELECT COUNT(*) FROM noona_v_my_notifications WHERE is_read = 'N'),
           (SELECT COUNT(*) FROM noona_v_apps)
      INTO l_open, l_overdue, l_unread, l_apps
      FROM dual;
    RETURN '<div class="nn-hello"><div class="nn-hello-title">مرحباً، ' || esc(NOONA_APEX_PKG.display_name) || '</div>'
        || '<div class="nn-hello-sub"><span class="fa fa-building-o" aria-hidden="true"></span> '
        || esc(NOONA_APEX_PKG.tenant_name)
        || CASE WHEN NOONA_APEX_PKG.company_name IS NOT NULL THEN ' &middot; ' || esc(NOONA_APEX_PKG.company_name) END
        || ' &middot; <a href="' || url(c_portal, 'COMPANY', p_session) || '">تبديل الشركة</a></div></div>'
        || '<div class="nn-kpis">'
        || kpi('مهام بانتظاري', l_open, 'fa-inbox', 'is-info')
        || kpi('مهام متأخرة', l_overdue, 'fa-clock-o', CASE WHEN l_overdue > 0 THEN 'is-danger' ELSE 'is-muted' END)
        || kpi('إشعارات غير مقروءة', l_unread, 'fa-bell-o', CASE WHEN l_unread > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('تطبيقات متاحة', l_apps, 'fa-th-large', 'is-success')
        || '</div>';
  END home_summary;

  FUNCTION app_cards(p_session IN VARCHAR2, p_existing_aliases IN VARCHAR2) RETURN CLOB IS
    l_html CLOB := '<div class="nn-apps">';
    l_ok   BOOLEAN;
  BEGIN
    FOR r IN (SELECT app_alias, app_name_ar, icon_class FROM noona_v_apps WHERE app_alias <> c_portal ORDER BY sort_order) LOOP
      l_ok := INSTR(',' || p_existing_aliases || ',', ',' || r.app_alias || ',') > 0;
      l_html := l_html
        || CASE WHEN l_ok THEN '<a class="nn-app" href="' || url(r.app_alias, '1', p_session) || '">'
                ELSE '<div class="nn-app is-disabled" title="قيد الإنشاء">' END
        || '<span class="nn-app-icon fa ' || esc(r.icon_class) || '" aria-hidden="true"></span>'
        || '<span class="nn-app-name">' || esc(r.app_name_ar) || '</span>'
        || CASE WHEN NOT l_ok THEN '<span class="nn-badge is-muted">قيد الإنشاء</span>' END
        || CASE WHEN l_ok THEN '</a>' ELSE '</div>' END;
    END LOOP;
    RETURN l_html || '</div>';
  END app_cards;

  FUNCTION launcher(p_session IN VARCHAR2, p_existing_aliases IN VARCHAR2) RETURN CLOB IS
    l_html  CLOB;
    l_cards CLOB;
    l_n     PLS_INTEGER := 0;
    l_ok    BOOLEAN;
    l_tasks NUMBER := 0;
    l_hour  NUMBER := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));
  BEGIN
    BEGIN
      l_tasks := NOONA_PORTAL_PKG.open_task_count;
    EXCEPTION WHEN OTHERS THEN
      l_tasks := 0;
    END;
    FOR r IN (SELECT app_alias, app_name_ar, icon_class, description_ar FROM noona_v_apps ORDER BY sort_order) LOOP
      l_n := l_n + 1;
      l_ok := INSTR(',' || p_existing_aliases || ',', ',' || r.app_alias || ',') > 0;
      l_cards := l_cards
        || CASE WHEN l_ok THEN '<a class="nn-sys" href="' || url(r.app_alias, '1', p_session) || '">'
                ELSE '<div class="nn-sys is-disabled" title="قيد الإنشاء">' END
        || '<span class="nn-sys-icon fa ' || esc(r.icon_class) || '" aria-hidden="true"></span>'
        || '<span class="nn-sys-body"><span class="nn-sys-name">' || esc(r.app_name_ar) || '</span>'
        || '<span class="nn-sys-desc">' || esc(r.description_ar) || '</span></span>'
        || CASE WHEN r.app_alias = c_portal AND l_tasks > 0
                THEN '<span class="nn-sys-count" title="مهام بانتظارك">' || l_tasks || '</span>' END
        || CASE WHEN NOT l_ok THEN '<span class="nn-badge is-muted">قيد الإنشاء</span>' END
        || CASE WHEN l_ok THEN '</a>' ELSE '</div>' END;
    END LOOP;
    l_html := '<div class="nn-hello nn-launch-hello"><div class="nn-hello-title">'
           || CASE WHEN l_hour < 12 THEN 'صباح الخير' ELSE 'مساء الخير' END || '، ' || esc(NOONA_APEX_PKG.display_name)
           || '</div><div class="nn-hello-sub"><span class="fa fa-building-o" aria-hidden="true"></span> '
           || esc(NOONA_APEX_PKG.tenant_name)
           || CASE WHEN NOONA_APEX_PKG.company_name IS NOT NULL THEN ' &middot; ' || esc(NOONA_APEX_PKG.company_name) END
           || '</div></div>';
    IF l_n = 0 THEN
      RETURN l_html || '<div class="nn-launch-empty"><span class="fa fa-lock" aria-hidden="true"></span>'
          || '<b>لم تُخصص لك أنظمة بعد</b><span>تواصل مع مسؤول المؤسسة لمنحك الأدوار المناسبة</span></div>';
    END IF;
    RETURN l_html || '<div class="nn-launch ' || CASE WHEN l_n <= 3 THEN 'is-few' WHEN l_n <= 6 THEN 'is-mid' ELSE 'is-many' END
        || '" data-count="' || l_n || '">' || l_cards || '</div>';
  END launcher;

  FUNCTION task_cards(p_session IN VARCHAR2, p_limit IN PLS_INTEGER DEFAULT 20) RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    FOR r IN (SELECT task_id, step_name_ar, workflow_name_ar, object_name_ar, object_id, requester, amount,
                     currency_code, priority_code, priority_label, on_behalf_of, assigned_at, due_at, is_overdue,
                     status_code
                FROM noona_v_my_tasks
               ORDER BY CASE priority_code WHEN 'VERY_URGENT' THEN 1 WHEN 'URGENT' THEN 2 WHEN 'HIGH' THEN 3 ELSE 4 END,
                        assigned_at
               FETCH FIRST p_limit ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_html := l_html
        || '<a class="nn-task ' || priority_class(r.priority_code) || '" href="'
        || url(c_portal, 'TASK', p_session, 'P2_TASK_ID', r.task_id) || '">'
        || '<div class="nn-task-main"><div class="nn-task-title">' || esc(r.step_name_ar) || '</div>'
        || '<div class="nn-task-meta">' || esc(r.workflow_name_ar) || ' &middot; ' || esc(r.object_name_ar)
        || ' #' || r.object_id || ' &middot; ' || esc(r.requester) || '</div></div>'
        || '<div class="nn-task-side">'
        || CASE WHEN r.amount IS NOT NULL THEN '<div class="nn-task-amount">' || fmt_amount(r.amount, r.currency_code) || '</div>' END
        || '<div class="nn-task-badges"><span class="nn-badge ' || priority_class(r.priority_code) || '">' || esc(r.priority_label) || '</span>'
        || CASE WHEN r.is_overdue = 'Y' THEN '<span class="nn-badge is-danger">متأخرة</span>' END
        || CASE WHEN r.status_code = 'WAITING_INFO' THEN '<span class="nn-badge is-warning">بانتظار معلومات</span>' END
        || CASE WHEN r.on_behalf_of IS NOT NULL THEN '<span class="nn-badge is-info">نيابة عن ' || esc(r.on_behalf_of) || '</span>' END
        || '</div><div class="nn-task-time">' || fmt_time(r.assigned_at) || '</div></div></a>';
    END LOOP;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty"><span class="fa fa-check-circle-o" aria-hidden="true"></span> لا توجد مهام بانتظارك</div>';
    END IF;
    RETURN '<div class="nn-tasks">' || l_html || '</div>';
  END task_cards;

  FUNCTION notification_list(p_session IN VARCHAR2, p_limit IN PLS_INTEGER DEFAULT 10) RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    FOR r IN (SELECT notification_id, title, source_entity_type, source_entity_id, created_at, is_read
                FROM noona_v_my_notifications
               ORDER BY created_at DESC
               FETCH FIRST p_limit ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_html := l_html || '<li class="nn-note' || CASE WHEN r.is_read = 'N' THEN ' is-unread' END || '">'
        || '<span class="nn-note-dot" aria-hidden="true"></span><div class="nn-note-body">'
        || CASE WHEN r.source_entity_type = 'WF_TASK'
                THEN '<a href="' || url(c_portal, 'TASK', p_session, 'P2_TASK_ID', r.source_entity_id) || '">' || esc(r.title) || '</a>'
                ELSE esc(r.title) END
        || '<div class="nn-note-time">' || fmt_time(r.created_at) || '</div></div></li>';
    END LOOP;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty"><span class="fa fa-bell-slash-o" aria-hidden="true"></span> لا توجد إشعارات</div>';
    END IF;
    RETURN '<ul class="nn-notes">' || l_html || '</ul>';
  END notification_list;

  -- ---------------------------------------------------------------- صفحة المهمة
  FUNCTION task_header(p_task_id IN NUMBER) RETURN CLOB IS
    r noona_v_my_tasks%ROWTYPE;
    FUNCTION field(p_label VARCHAR2, p_value VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN '<div class="nn-field"><div class="nn-field-label">' || esc(p_label) || '</div><div class="nn-field-value">'
          || NVL(p_value, '&ndash;') || '</div></div>';
    END;
  BEGIN
    SELECT * INTO r FROM noona_v_my_tasks WHERE task_id = p_task_id;
    RETURN '<div class="nn-taskhead ' || priority_class(r.priority_code) || '">'
        || '<div class="nn-taskhead-title">' || esc(r.step_name_ar)
        || ' <span class="nn-badge ' || priority_class(r.priority_code) || '">' || esc(r.priority_label) || '</span>'
        || CASE WHEN r.is_overdue = 'Y' THEN ' <span class="nn-badge is-danger">متأخرة</span>' END || '</div>'
        || '<div class="nn-fields">'
        || field('المسار', esc(r.workflow_name_ar))
        || field('نوع المعاملة', esc(r.object_name_ar) || ' #' || r.object_id)
        || field('الطالب', esc(r.requester))
        || field('المبلغ', fmt_amount(r.amount, r.currency_code))
        || field('نيابة عن', esc(r.on_behalf_of))
        || field('تاريخ الإسناد', fmt_time(r.assigned_at))
        || field('الاستحقاق', fmt_time(r.due_at))
        || '</div></div>';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty is-warning"><span class="fa fa-info-circle" aria-hidden="true"></span> '
        || 'المهمة غير موجودة أو ليست مسندة إليك أو تم إنجازها</div>';
  END task_header;

  FUNCTION task_timeline(p_task_id IN NUMBER) RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    FOR r IN (SELECT h.action_at, h.step_name_ar, h.action_code, h.action_label, h.actor_name, h.on_behalf_of, h.comments
                FROM noona_v_task_history h
               WHERE h.instance_id = (SELECT t.instance_id FROM noona_v_my_tasks t WHERE t.task_id = p_task_id)
               ORDER BY h.action_at) LOOP
      l_n := l_n + 1;
      l_html := l_html || '<li class="nn-tl-item ' ||
        CASE WHEN r.action_code IN ('APPROVE', 'APPROVE_WITH_CONDITIONS') THEN 'is-success'
             WHEN r.action_code IN ('REJECT', 'CANCEL') THEN 'is-danger'
             WHEN r.action_code IN ('RETURN', 'REQUEST_INFO') THEN 'is-warning' ELSE 'is-info' END || '">'
        || '<div class="nn-tl-head"><strong>' || esc(r.action_label) || '</strong> &middot; ' || esc(r.step_name_ar)
        || '<span class="nn-tl-time">' || fmt_time(r.action_at) || '</span></div>'
        || '<div class="nn-tl-by">' || esc(r.actor_name)
        || CASE WHEN r.on_behalf_of IS NOT NULL THEN ' (نيابة عن ' || esc(r.on_behalf_of) || ')' END || '</div>'
        || CASE WHEN r.comments IS NOT NULL THEN '<div class="nn-tl-comment">' || esc(r.comments) || '</div>' END
        || '</li>';
    END LOOP;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty"><span class="fa fa-history" aria-hidden="true"></span> لا توجد إجراءات سابقة على هذا الطلب</div>';
    END IF;
    RETURN '<ol class="nn-timeline">' || l_html || '</ol>';
  END task_timeline;

  -- ---------------------------------------------------------------- الحالات
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN CASE p_code
      WHEN 'DRAFT' THEN 'مسودة' WHEN 'ACTIVE' THEN 'نشط' WHEN 'INACTIVE' THEN 'غير نشط'
      WHEN 'UNDER_CONFIGURATION' THEN 'قيد الإعداد' WHEN 'READY_FOR_REVIEW' THEN 'جاهز للمراجعة'
      WHEN 'SUSPENDED' THEN 'معلق' WHEN 'CLOSED' THEN 'مغلق' WHEN 'CLOSING' THEN 'قيد الإغلاق' WHEN 'ARCHIVED' THEN 'مؤرشف'
      WHEN 'CLOSURE_REQUESTED' THEN 'طلب إغلاق' WHEN 'UNDER_LIQUIDATION' THEN 'تحت التصفية'
      WHEN 'TRANSACTIONS_BLOCKED' THEN 'المعاملات موقوفة' WHEN 'FINANCIALLY_CLOSED' THEN 'مقفل مالياً'
      WHEN 'LEGALLY_CLOSED' THEN 'مغلق قانونياً'
      WHEN 'PENDING' THEN 'معلق' WHEN 'PASSED' THEN 'ناجح' WHEN 'FAILED' THEN 'فشل' WHEN 'WAIVED' THEN 'مستثنى'
      WHEN 'SUBMITTED' THEN 'مرسل' WHEN 'APPROVED' THEN 'معتمد' WHEN 'REJECTED' THEN 'مرفوض' WHEN 'SCHEDULED' THEN 'مجدول'
      WHEN 'EXPIRED' THEN 'منتهي' WHEN 'REVOKED' THEN 'ملغى' WHEN 'CANCELLED' THEN 'ملغى' WHEN 'TERMINATED' THEN 'منتهي'
      WHEN 'RETIRED' THEN 'متقاعد' WHEN 'SUPERSEDED' THEN 'مستبدل' WHEN 'UNDER_REVIEW' THEN 'قيد المراجعة'
      WHEN 'SUCCESS' THEN 'نجاح' WHEN 'DENIED' THEN 'مرفوض' WHEN 'PUBLISHED' THEN 'منشور'
      WHEN 'VACANT' THEN 'شاغر' WHEN 'OCCUPIED' THEN 'مشغول' WHEN 'FROZEN' THEN 'مجمد' WHEN 'PLANNED' THEN 'مخطط'
      WHEN 'EFFECTIVE' THEN 'ساري' WHEN 'COMPLETED' THEN 'مكتمل' WHEN 'RUNNING' THEN 'قيد التشغيل' WHEN 'WAITING' THEN 'بانتظار إجراء'
      WHEN 'INVITED' THEN 'مدعو' WHEN 'ENDED' THEN 'منتهي' WHEN 'LOCKED' THEN 'مقفل'
      WHEN 'TRIAL' THEN 'تجريبي' WHEN 'READ_ONLY' THEN 'قراءة فقط' WHEN 'GRACE_PERIOD' THEN 'فترة سماح'
      ELSE p_code END;
  END status_label;

  FUNCTION status_badge(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
    l_class VARCHAR2(20);
  BEGIN
    l_class := CASE
      WHEN p_code IN ('ACTIVE', 'PASSED', 'APPROVED', 'EFFECTIVE', 'COMPLETED', 'OCCUPIED', 'SUCCESS', 'PUBLISHED') THEN 'is-success'
      WHEN p_code IN ('FAILED', 'DENIED', 'REJECTED', 'SUSPENDED', 'CLOSED', 'REVOKED', 'CANCELLED', 'LOCKED', 'TRANSACTIONS_BLOCKED') THEN 'is-danger'
      WHEN p_code IN ('PENDING', 'SUBMITTED', 'UNDER_CONFIGURATION', 'READY_FOR_REVIEW', 'WAIVED', 'CLOSING', 'WAITING',
                      'UNDER_REVIEW', 'GRACE_PERIOD', 'READ_ONLY', 'VACANT') THEN 'is-warning'
      WHEN p_code IN ('DRAFT', 'SCHEDULED', 'RUNNING', 'TRIAL', 'PLANNED', 'INVITED') THEN 'is-info'
      ELSE 'is-muted' END;
    RETURN '<span class="nn-badge ' || l_class || '">' || esc(status_label(p_code)) || '</span>';
  END status_badge;

  -- ---------------------------------------------------------------- لوحة الإدارة
  -- حدود الاشتراك التي يحددها مالك المنصة: " (الحد 10)" ولون تحذيري عند الاقتراب
  FUNCTION limit_text(p_metric VARCHAR2, p_used NUMBER) RETURN VARCHAR2 IS
    l_limit NUMBER := NOONA_PLATFORM_PKG.hard_limit(p_metric);
  BEGIN
    RETURN CASE WHEN l_limit IS NOT NULL THEN ' (الحد ' || l_limit || ')' END;
  END limit_text;

  FUNCTION limit_class(p_metric VARCHAR2, p_used NUMBER) RETURN VARCHAR2 IS
    l_limit NUMBER := NOONA_PLATFORM_PKG.hard_limit(p_metric);
  BEGIN
    RETURN CASE WHEN l_limit IS NULL THEN 'is-info'
                WHEN p_used >= l_limit THEN 'is-danger'
                WHEN p_used >= l_limit * 0.8 THEN 'is-warning'
                ELSE 'is-info' END;
  END limit_class;

  FUNCTION admin_summary(p_session IN VARCHAR2) RETURN CLOB IS
    l_comp NUMBER; l_comp_act NUMBER; l_br NUMBER; l_users NUMBER; l_roles NUMBER;
    l_dlg_pending NUMBER; l_wf NUMBER; l_checks NUMBER;
  BEGIN
    SELECT (SELECT COUNT(*) FROM org_company),
           (SELECT COUNT(*) FROM org_company WHERE status_code = 'ACTIVE'),
           (SELECT COUNT(*) FROM org_branch WHERE status_code = 'ACTIVE'),
           (SELECT COUNT(*) FROM sec_user_membership WHERE status_code = 'ACTIVE'),
           (SELECT COUNT(*) FROM sec_role WHERE status_code = 'ACTIVE'),
           (SELECT COUNT(*) FROM dlg_delegation WHERE status_code = 'SUBMITTED'),
           (SELECT COUNT(*) FROM wf_definition_version WHERE status_code = 'ACTIVE'),
           (SELECT COUNT(*) FROM org_company_check WHERE status_code = 'FAILED')
      INTO l_comp, l_comp_act, l_br, l_users, l_roles, l_dlg_pending, l_wf, l_checks
      FROM dual;
    RETURN '<div class="nn-hello"><div class="nn-hello-title">إدارة المؤسسة</div>'
        || '<div class="nn-hello-sub"><span class="fa fa-building-o" aria-hidden="true"></span> '
        || esc(NOONA_APEX_PKG.tenant_name) || ' &middot; ' || esc(NOONA_APEX_PKG.display_name) || '</div></div>'
        || '<div class="nn-kpis">'
        || kpi('شركات نشطة من ' || l_comp || limit_text('COMPANIES', l_comp), l_comp_act, 'fa-building-o', 'is-success')
        || kpi('فروع نشطة' || limit_text('BRANCHES', l_br), l_br, 'fa-map-marker', limit_class('BRANCHES', l_br))
        || kpi('مستخدمون نشطون' || limit_text('USERS', l_users), l_users, 'fa-users', limit_class('USERS', l_users))
        || kpi('أدوار', l_roles, 'fa-key', 'is-muted')
        || kpi('تفويضات بانتظار الاعتماد', l_dlg_pending, 'fa-share', CASE WHEN l_dlg_pending > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('مسارات اعتماد منشورة', l_wf, 'fa-sitemap', 'is-info')
        || kpi('فحوص تفعيل فاشلة', l_checks, 'fa-exclamation-triangle', CASE WHEN l_checks > 0 THEN 'is-danger' ELSE 'is-muted' END)
        || '</div>';
  END admin_summary;

  -- ---------------------------------------------------------------- مصفوفة الصلاحيات
  FUNCTION action_label(p_action IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN CASE p_action
      WHEN 'VIEW' THEN 'عرض' WHEN 'CREATE' THEN 'إنشاء' WHEN 'UPDATE' THEN 'تعديل' WHEN 'DELETE' THEN 'حذف'
      WHEN 'EXPORT' THEN 'تصدير' WHEN 'PRINT' THEN 'طباعة' WHEN 'SUBMIT' THEN 'إرسال' WHEN 'APPROVE' THEN 'اعتماد'
      WHEN 'REJECT' THEN 'رفض' WHEN 'POST' THEN 'ترحيل' WHEN 'REVERSE' THEN 'عكس' WHEN 'CANCEL' THEN 'إلغاء'
      ELSE p_action END;
  END action_label;

  FUNCTION permission_matrix(p_role_id IN NUMBER, p_module_code IN VARCHAR2) RETURN CLOB IS
    c_order CONSTANT VARCHAR2(200) := ',VIEW,CREATE,UPDATE,DELETE,EXPORT,PRINT,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL,';
    TYPE t_list IS TABLE OF VARCHAR2(30);
    l_actions t_list;
    l_html    CLOB;
    l_row     VARCHAR2(32767);
    l_res     VARCHAR2(128);
    l_n       PLS_INTEGER := 0;

    PROCEDURE add(p_text VARCHAR2) IS
    BEGIN
      DBMS_LOB.WRITEAPPEND(l_html, LENGTH(p_text), p_text);
    END add;
  BEGIN
    IF p_role_id IS NULL OR p_module_code IS NULL THEN
      RETURN '<div class="nn-empty">اختر الوحدة لعرض صلاحياتها</div>';
    END IF;
    SELECT action_code BULK COLLECT INTO l_actions
      FROM (SELECT DISTINCT action_code FROM sec_permission
             WHERE module_code = p_module_code AND is_active = 'Y' AND action_code <> 'CONFIGURE')
     ORDER BY NULLIF(INSTR(c_order, ',' || action_code || ','), 0) NULLS LAST, action_code;
    DBMS_LOB.CREATETEMPORARY(l_html, TRUE);
    add('<div class="nn-matrix-wrap"><table class="nn-matrix"><thead><tr><th class="nn-matrix-res">'
        || '<label><input type="checkbox" class="nn-all"> العنصر</label></th>');
    FOR i IN 1 .. l_actions.COUNT LOOP
      add('<th><label><input type="checkbox" class="nn-col" data-col="' || l_actions(i) || '"><span>'
          || esc(action_label(l_actions(i))) || '</span></label></th>');
    END LOOP;
    add('</tr></thead><tbody>');
    FOR r IN (SELECT p.resource_code,
                     NVL(MAX(e.name_ar), p.resource_code) AS res_name,
                     LISTAGG(p.action_code || ':' || p.id || ':' || NVL(rp.effect, '-'), ',') AS cells
                FROM sec_permission p
                LEFT JOIN ref_entity_type e ON e.entity_type_code = p.resource_code
                LEFT JOIN sec_role_permission rp ON rp.permission_id = p.id AND rp.role_id = p_role_id
               WHERE p.module_code = p_module_code AND p.is_active = 'Y' AND p.action_code <> 'CONFIGURE'
               GROUP BY p.resource_code
               ORDER BY 2) LOOP
      l_n := l_n + 1;
      l_row := '<tr><td class="nn-matrix-res"><label><input type="checkbox" class="nn-row"> ' || esc(r.res_name)
            || '</label><small>' || esc(r.resource_code) || '</small></td>';
      FOR i IN 1 .. l_actions.COUNT LOOP
        l_res := REGEXP_SUBSTR(',' || r.cells || ',', ',' || l_actions(i) || ':([0-9]+:[A-Z-]+),', 1, 1, NULL, 1);
        IF l_res IS NULL THEN
          l_row := l_row || '<td class="nn-na">&ndash;</td>';
        ELSIF l_res LIKE '%:DENY' THEN
          l_row := l_row || '<td class="nn-deny" title="منع صريح"><span class="fa fa-ban" aria-hidden="true"></span></td>';
        ELSE
          l_row := l_row || '<td><input type="checkbox" class="nn-perm" data-col="' || l_actions(i) || '" value="'
                || SUBSTR(l_res, 1, INSTR(l_res, ':') - 1) || '"'
                || CASE WHEN l_res LIKE '%:ALLOW' THEN ' checked' END
                || ' aria-label="' || esc(r.res_name || ' - ' || action_label(l_actions(i))) || '"></td>';
        END IF;
      END LOOP;
      add(l_row || '</tr>');
    END LOOP;
    add('</tbody></table></div>');
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty">لا توجد صلاحيات معرفة لهذه الوحدة</div>';
    END IF;
    RETURN l_html;
  END permission_matrix;

  -- ---------------------------------------------------------- مسارات الاعتماد
  FUNCTION assignee_label(p_rule IN VARCHAR2, p_ref_id IN NUMBER) RETURN VARCHAR2 IS
    l_name VARCHAR2(400);
  BEGIN
    IF p_rule IS NULL THEN
      RETURN NULL;
    ELSIF p_ref_id IS NULL THEN
      RETURN code_label(p_rule);
    END IF;
    BEGIN
      CASE
        WHEN p_rule = 'USER' THEN
          SELECT u.display_name INTO l_name FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE m.id = p_ref_id;
        WHEN p_rule = 'POSITION' THEN
          SELECT name_ar INTO l_name FROM org_position WHERE id = p_ref_id;
        WHEN p_rule = 'HEAD_POSITION' THEN                       -- المرجع وحدة تنظيمية: رئيسها
          SELECT name_ar INTO l_name FROM org_unit WHERE id = p_ref_id;
        WHEN p_rule = 'ROLE' THEN
          SELECT name_ar INTO l_name FROM sec_role WHERE id = p_ref_id;
        WHEN p_rule = 'ORG_UNIT' THEN
          SELECT name_ar INTO l_name FROM org_unit WHERE id = p_ref_id;
        ELSE
          NULL;
      END CASE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_name := '#' || p_ref_id;
    END;
    RETURN code_label(p_rule) || CASE WHEN l_name IS NOT NULL THEN ': ' || l_name END;
  END assignee_label;

  FUNCTION workflow_diagram(p_version_id IN NUMBER) RETURN CLOB IS
    TYPE t_num IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    l_depth t_num;                  -- عمق كل خطوة من البداية (BFS)
    l_queue t_num;
    l_head  PLS_INTEGER := 1;
    l_tail  PLS_INTEGER := 0;
    l_start NUMBER;
    l_max   PLS_INTEGER := 0;
    l_html  CLOB;
    l_cnt   PLS_INTEGER := 0;
  BEGIN
    SELECT MIN(id) INTO l_start FROM wf_step_def WHERE version_id = p_version_id AND step_type = 'START';
    IF l_start IS NULL THEN
      RETURN '<div class="nn-empty">أضف خطوة البداية (START) لعرض المخطط</div>';
    END IF;
    l_depth(l_start) := 0; l_tail := 1; l_queue(1) := l_start;
    WHILE l_head <= l_tail LOOP
      FOR t IN (SELECT DISTINCT to_step_id FROM wf_transition_def
                 WHERE version_id = p_version_id AND from_step_id = l_queue(l_head)) LOOP
        IF NOT l_depth.EXISTS(t.to_step_id) THEN
          l_depth(t.to_step_id) := l_depth(l_queue(l_head)) + 1;
          l_max := GREATEST(l_max, l_depth(t.to_step_id));
          l_tail := l_tail + 1; l_queue(l_tail) := t.to_step_id;
        END IF;
      END LOOP;
      l_head := l_head + 1;
    END LOOP;
    l_html := '<div class="nn-flow">';
    FOR d IN 0 .. l_max LOOP
      l_html := l_html || '<div class="nn-flow-row">';
      FOR s IN (SELECT * FROM wf_step_def WHERE version_id = p_version_id ORDER BY id) LOOP
        IF l_depth.EXISTS(s.id) AND l_depth(s.id) = d THEN
          l_cnt := l_cnt + 1;
          l_html := l_html || '<div class="nn-flow-node is-' || LOWER(s.step_type) || '">'
                 || CASE WHEN s.step_type NOT IN ('START', 'END')
                      THEN '<div class="nn-flow-type">' || esc(code_label(s.step_type)) || '</div>' END
                 || '<div class="nn-flow-name">' || esc(s.name_ar) || '</div>'
                 || CASE WHEN s.assignee_rule IS NOT NULL
                      THEN '<div class="nn-flow-who"><span class="fa fa-user" aria-hidden="true"></span> '
                           || esc(assignee_label(s.assignee_rule, s.assignee_ref_id)) || '</div>' END;
          FOR t IN (SELECT x.outcome_code, x.is_default, n.name_ar, r.name_ar AS rule_name
                      FROM wf_transition_def x JOIN wf_step_def n ON n.id = x.to_step_id
                      LEFT JOIN wf_rule r ON r.id = x.rule_id
                     WHERE x.from_step_id = s.id ORDER BY x.sort_order, x.id) LOOP
            l_html := l_html || '<div class="nn-flow-out">&#8595; '
                   || esc(NVL(code_label(t.outcome_code), 'التالي'))
                   || CASE WHEN t.rule_name IS NOT NULL THEN ' (إذا ' || esc(t.rule_name) || ')'
                           WHEN t.is_default = 'Y' THEN ' (افتراضي)' END
                   || ' &larr; ' || esc(t.name_ar) || '</div>';
          END LOOP;
          l_html := l_html || '</div>';
        END IF;
      END LOOP;
      l_html := l_html || '</div>';
    END LOOP;
    -- خطوات غير متصلة بالبداية
    FOR s IN (SELECT * FROM wf_step_def WHERE version_id = p_version_id ORDER BY id) LOOP
      IF NOT l_depth.EXISTS(s.id) THEN
        l_html := l_html || '<div class="nn-flow-row"><div class="nn-flow-node is-orphan"><div class="nn-flow-type">غير متصلة</div>'
               || '<div class="nn-flow-name">' || esc(s.name_ar) || '</div></div></div>';
      END IF;
    END LOOP;
    RETURN l_html || '</div>';
  END workflow_diagram;

  FUNCTION delegation_header(p_delegation_id IN NUMBER) RETURN CLOB IS
    l_d   dlg_delegation%ROWTYPE;
    l_g   VARCHAR2(400);
    l_t   VARCHAR2(400);
    l_lim VARCHAR2(1000);
  BEGIN
    SELECT * INTO l_d FROM dlg_delegation WHERE id = p_delegation_id;
    SELECT MAX(CASE WHEN m.id = l_d.grantor_member_id THEN u.display_name END),
           MAX(CASE WHEN m.id = l_d.delegate_member_id THEN u.display_name END)
      INTO l_g, l_t
      FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
     WHERE m.id IN (l_d.grantor_member_id, l_d.delegate_member_id);
    FOR l IN (SELECT * FROM dlg_limit WHERE delegation_id = p_delegation_id ORDER BY id) LOOP
      l_lim := l_lim || CASE WHEN l_lim IS NOT NULL THEN '، ' END || fmt_amount(l.max_per_transaction, l.currency_code)
            || ' للمعاملة' || CASE WHEN l.max_cumulative IS NOT NULL
                                   THEN ' / ' || fmt_amount(l.max_cumulative, l.currency_code) || ' تراكمي' END;
    END LOOP;
    RETURN '<div class="nn-taskhead is-info"><div class="nn-taskhead-top"><div>'
        || '<div class="nn-taskhead-title">' || esc(code_label(l_d.delegation_type)) || ' &middot; ' || esc(l_d.delegation_no) || '</div>'
        || '<div class="nn-taskhead-sub"><span class="fa fa-user" aria-hidden="true"></span> ' || esc(l_g)
        || ' &larr; <span class="fa fa-share" aria-hidden="true"></span> ' || esc(l_t) || '</div></div>'
        || status_badge(l_d.status_code) || '</div><div class="nn-fields">'
        || '<div class="nn-field"><div class="nn-field-label">من</div><div class="nn-field-value">' || TO_CHAR(l_d.starts_at, 'YYYY-MM-DD') || '</div></div>'
        || '<div class="nn-field"><div class="nn-field-label">إلى</div><div class="nn-field-value">' || NVL(TO_CHAR(l_d.ends_at, 'YYYY-MM-DD'), '-') || '</div></div>'
        || '<div class="nn-field"><div class="nn-field-label">الحد المالي</div><div class="nn-field-value">' || NVL(l_lim, 'بدون حد') || '</div></div>'
        || '<div class="nn-field"><div class="nn-field-label">السبب</div><div class="nn-field-value">' || esc(l_d.reason) || '</div></div>'
        || '</div></div>';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">التفويض غير موجود</div>';
  END delegation_header;

  FUNCTION code_label(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN CASE p_code
      WHEN 'Y' THEN 'نعم' WHEN 'N' THEN 'لا'
      WHEN 'LEGAL_REGISTRATION' THEN 'التسجيلات القانونية' WHEN 'FUNCTIONAL_CURRENCY' THEN 'العملة الوظيفية'
      WHEN 'FISCAL_YEAR' THEN 'السنة المالية' WHEN 'LEDGER_COA' THEN 'دفتر الأستاذ ودليل الحسابات'
      WHEN 'HEAD_BRANCH' THEN 'الفرع الرئيسي' WHEN 'COMPANY_ADMIN' THEN 'مسؤول للشركة'
      WHEN 'DOC_SEQUENCES' THEN 'تسلسلات المستندات' WHEN 'LICENSE_LIMIT' THEN 'حدود الترخيص'
      WHEN 'HEAD_OFFICE' THEN 'مركز رئيسي' WHEN 'BRANCH' THEN 'فرع' WHEN 'WAREHOUSE' THEN 'مستودع'
      WHEN 'SHOWROOM' THEN 'معرض' WHEN 'FACTORY' THEN 'مصنع' WHEN 'SITE_OFFICE' THEN 'مكتب موقع'
      WHEN 'EXECUTIVE' THEN 'إدارة عليا' WHEN 'SECTOR' THEN 'قطاع' WHEN 'DEPARTMENT' THEN 'إدارة' WHEN 'SECTION' THEN 'قسم'
      WHEN 'UNIT' THEN 'وحدة' WHEN 'TEAM' THEN 'فريق' WHEN 'OFFICE' THEN 'مكتب' WHEN 'COMMITTEE' THEN 'لجنة'
      WHEN 'PRIMARY' THEN 'أساسي' WHEN 'ADDITIONAL' THEN 'إضافي' WHEN 'ACTING' THEN 'بالإنابة' WHEN 'SECONDMENT' THEN 'إعارة'
      WHEN 'TEMPORARY' THEN 'مؤقت' WHEN 'ADMINISTRATIVE' THEN 'إداري' WHEN 'FINANCIAL' THEN 'مالي' WHEN 'OPERATIONAL' THEN 'تشغيلي'
      WHEN 'PROJECT' THEN 'مشروعات' WHEN 'CORRESPONDENCE' THEN 'مراسلات' WHEN 'REPORTING' THEN 'تقارير' WHEN 'MATRIX' THEN 'مصفوفي'
      WHEN 'TENANT' THEN 'مؤسسة' WHEN 'COMPANY' THEN 'شركة' WHEN 'PLATFORM' THEN 'منصة' WHEN 'CUSTOM' THEN 'مخصص'
      WHEN 'ALLOW' THEN 'سماح' WHEN 'DENY' THEN 'منع' WHEN 'ALL_TENANT' THEN 'كل المؤسسة'
      WHEN 'APPROVAL' THEN 'اعتماد' WHEN 'REVIEW' THEN 'مراجعة' WHEN 'START' THEN 'بداية' WHEN 'END' THEN 'نهاية'
      WHEN 'DECISION' THEN 'قرار' WHEN 'USER_TASK' THEN 'مهمة' WHEN 'NOTIFICATION' THEN 'إشعار'
      WHEN 'USER' THEN 'مستخدم محدد' WHEN 'REQUESTER' THEN 'الطالب' WHEN 'MANAGER' THEN 'المدير المباشر'
      WHEN 'HEAD_POSITION' THEN 'رئيس الوحدة' WHEN 'POSITION' THEN 'منصب' WHEN 'ROLE' THEN 'دور'
      WHEN 'AUTHORITY_MATRIX' THEN 'مصفوفة الصلاحيات' WHEN 'ORG_UNIT' THEN 'وحدة تنظيمية'
      WHEN 'SYSTEM' THEN 'خطوة نظامية' WHEN 'TIMER' THEN 'مؤقت' WHEN 'PARALLEL_SPLIT' THEN 'تفرع متوازٍ'
      WHEN 'PARALLEL_JOIN' THEN 'دمج متوازٍ' WHEN 'SIGNATURE' THEN 'توقيع' WHEN 'POSTING' THEN 'ترحيل'
      WHEN 'ROUTING' THEN 'توجيه' WHEN 'TASK' THEN 'مهام' WHEN 'CASE' THEN 'حالة' WHEN 'CHECKLIST' THEN 'قائمة تحقق'
      WHEN 'DOCUMENT' THEN 'مستندات' WHEN 'ALL' THEN 'الجميع' WHEN 'ANY' THEN 'أي واحد' WHEN 'MAJORITY' THEN 'الأغلبية'
      WHEN 'APPROVED' THEN 'عند الاعتماد' WHEN 'REJECTED' THEN 'عند الرفض' WHEN 'RETURNED' THEN 'عند الإعادة'
      WHEN 'ACCESS' THEN 'وصول' WHEN 'EMERGENCY' THEN 'طارئ'
      WHEN 'AUTH' THEN 'دخول' WHEN 'SECURITY' THEN 'أمن وصلاحيات' WHEN 'CONFIG' THEN 'إعدادات' WHEN 'DATA_CHANGE' THEN 'تعديل بيانات'
      WHEN 'PAYMENT' THEN 'مدفوعات' WHEN 'INVENTORY' THEN 'مخزون' WHEN 'EXPORT' THEN 'تصدير' WHEN 'SUPPORT' THEN 'دعم فني'
      WHEN 'API' THEN 'تكامل' WHEN 'AI' THEN 'ذكاء اصطناعي' WHEN 'DEPLOYMENT' THEN 'نشر'
      WHEN 'DOC_DATE' THEN 'تاريخ المستند' WHEN 'DELIVERY_DATE' THEN 'تاريخ التسليم' WHEN 'END_OF_MONTH' THEN 'نهاية الشهر'
      WHEN 'RECEIPT_DATE' THEN 'تاريخ الاستلام' WHEN 'HALF_UP' THEN 'تقريب عادي' WHEN 'HALF_EVEN' THEN 'تقريب بنكي'
      WHEN 'UP' THEN 'لأعلى' WHEN 'DOWN' THEN 'لأسفل'
      WHEN 'MODULE' THEN 'وحدة النظام' WHEN 'WORKFLOW' THEN 'مسار اعتماد' WHEN 'ACTION' THEN 'إجراء'
      WHEN 'TRANSACTION_TYPE' THEN 'نوع المعاملة' WHEN 'REQUEST_TYPE' THEN 'نوع الطلب' WHEN 'MAX_CONFIDENTIALITY' THEN 'أعلى سرية'
      ELSE p_code END;
  END code_label;

END NOONA_UI_PKG;
/
