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
  FUNCTION task_cards(p_session IN VARCHAR2, p_limit IN PLS_INTEGER DEFAULT 20) RETURN CLOB;
  FUNCTION notification_list(p_session IN VARCHAR2, p_limit IN PLS_INTEGER DEFAULT 10) RETURN CLOB;

  -- حالات موحدة: تسمية عربية وشارة ملونة (تستخدم في التقارير بعرض HTML)
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
  FUNCTION status_badge(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
  -- تسميات رموز شائعة: فحوص التفعيل، أنواع الفروع، نعم/لا
  FUNCTION code_label(p_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

  -- لوحة إدارة المؤسسة
  FUNCTION admin_summary(p_session IN VARCHAR2) RETURN CLOB;

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
    FOR r IN (SELECT app_alias, app_name_ar, icon_class FROM noona_v_apps ORDER BY sort_order) LOOP
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
      WHEN p_code IN ('ACTIVE', 'PASSED', 'APPROVED', 'EFFECTIVE', 'COMPLETED', 'OCCUPIED') THEN 'is-success'
      WHEN p_code IN ('FAILED', 'REJECTED', 'SUSPENDED', 'CLOSED', 'REVOKED', 'CANCELLED', 'LOCKED', 'TRANSACTIONS_BLOCKED') THEN 'is-danger'
      WHEN p_code IN ('PENDING', 'SUBMITTED', 'UNDER_CONFIGURATION', 'READY_FOR_REVIEW', 'WAIVED', 'CLOSING', 'WAITING',
                      'UNDER_REVIEW', 'GRACE_PERIOD', 'READ_ONLY', 'VACANT') THEN 'is-warning'
      WHEN p_code IN ('DRAFT', 'SCHEDULED', 'RUNNING', 'TRIAL', 'PLANNED', 'INVITED') THEN 'is-info'
      ELSE 'is-muted' END;
    RETURN '<span class="nn-badge ' || l_class || '">' || esc(status_label(p_code)) || '</span>';
  END status_badge;

  -- ---------------------------------------------------------------- لوحة الإدارة
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
        || kpi('شركات نشطة من ' || l_comp, l_comp_act, 'fa-building-o', 'is-success')
        || kpi('فروع نشطة', l_br, 'fa-map-marker', 'is-info')
        || kpi('مستخدمون نشطون', l_users, 'fa-users', 'is-info')
        || kpi('أدوار', l_roles, 'fa-key', 'is-muted')
        || kpi('تفويضات بانتظار الاعتماد', l_dlg_pending, 'fa-share', CASE WHEN l_dlg_pending > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('مسارات اعتماد منشورة', l_wf, 'fa-sitemap', 'is-info')
        || kpi('فحوص تفعيل فاشلة', l_checks, 'fa-exclamation-triangle', CASE WHEN l_checks > 0 THEN 'is-danger' ELSE 'is-muted' END)
        || '</div>';
  END admin_summary;

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
      WHEN 'AUTHORITY_MATRIX' THEN 'مصفوفة الصلاحيات'
      ELSE p_code END;
  END code_label;

END NOONA_UI_PKG;
/
