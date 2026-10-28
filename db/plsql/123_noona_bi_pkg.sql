-- =============================================================================
-- NOONA PLUS ERP | NOONA_BI_PKG - مركز التقارير الموحد (التطبيق 143 NOONA_BI)
--   * كتالوج BI_REPORT يجمع تقارير كل الوحدات (المالية، المخزون، المشتريات، المبيعات، الموارد البشرية، الرواتب،
--     الضيافة، الصيانة، التصنيع، المستشفى، المستندات) بالتطبيق والصفحة ورمز التقرير داخل مركز تقارير الوحدة
--   * يظهر التقرير فقط إذا اشتركت المؤسسة في وحدته وللمستخدم صلاحيته (مسؤول المؤسسة يرى كل المشترك فيه)
--   * الشاشة الرئيسية: كارت لكل وحدة بعدد تقاريرها، والمفضلة، والأخيرة، والبحث في كل التقارير
--   * يفتح التقرير في تطبيق وحدته بنفس الجلسة، ويسجل مرات الفتح والمفضلة لكل مستخدم
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_BI_PKG AUTHID DEFINER AS
  -- Y إذا كان التقرير متاحاً للمستخدم الحالي (اشتراك الوحدة + الصلاحية)
  FUNCTION report_ok(p_module_code IN VARCHAR2, p_permission_code IN VARCHAR2) RETURN VARCHAR2;
  -- Y إذا كان للمستخدم تقرير واحد على الأقل (يظهر مركز التقارير في شاشة الأنظمة)
  FUNCTION has_reports RETURN VARCHAR2;
  FUNCTION module_label(p_module_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION module_icon(p_module_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION type_label(p_report_type IN VARCHAR2) RETURN VARCHAR2;

  -- الشاشة الرئيسية: كروت الوحدات + المفضلة + الأخيرة؛ أو نتائج البحث في كل التقارير
  -- p_apps: التطبيقات المثبتة (Alias مفصولة بفواصل)؛ تقارير تطبيق غير مثبت تظهر معطلة
  FUNCTION home_html(p_session IN VARCHAR2, p_apps IN VARCHAR2, p_search IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- تقارير وحدة كبطاقات مع تصفية بالنوع والبحث
  FUNCTION module_html(p_module_code IN VARCHAR2, p_session IN VARCHAR2, p_apps IN VARCHAR2,
                       p_type IN VARCHAR2 DEFAULT NULL, p_search IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- رابط التقرير في تطبيق وحدته (يتحقق من الصلاحية ويسجل الفتح)
  FUNCTION open_url(p_report_id IN NUMBER, p_session IN VARCHAR2) RETURN VARCHAR2;
  -- يبدل المفضلة ويعيد الحالة الجديدة Y/N
  FUNCTION toggle_favorite(p_report_id IN NUMBER) RETURN VARCHAR2;
END NOONA_BI_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_BI_PKG AS

  c_app CONSTANT VARCHAR2(30) := 'NOONA_BI';

  TYPE t_flags IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(200);
  g_mod  t_flags;     -- اشتراك الوحدة ودور فيها (يصفر في بداية كل شاشة)
  g_perm t_flags;     -- الصلاحيات
  g_admin VARCHAR2(1);

  PROCEDURE reset_cache IS
  BEGIN
    g_mod.DELETE;
    g_perm.DELETE;
    g_admin := NULL;
  END reset_cache;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN NOONA_UI_PKG.esc(p);
  END esc;

  FUNCTION company RETURN NUMBER IS
  BEGIN
    RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  END company;

  FUNCTION is_admin RETURN BOOLEAN IS
  BEGIN
    IF g_admin IS NULL THEN
      g_admin := NVL(NOONA_APEX_PKG.is_tenant_admin, 'N');
    END IF;
    RETURN g_admin = 'Y';
  END is_admin;

  -- الوحدة مشترك فيها وللمستخدم دور يمنح صلاحية سماح فيها
  FUNCTION module_ok(p_module VARCHAR2) RETURN VARCHAR2 IS
    l_n NUMBER;
  BEGIN
    IF NOT g_mod.EXISTS(p_module) THEN
      IF NOONA_PLATFORM_PKG.module_enabled(p_module) = 'N' THEN
        g_mod(p_module) := 'N';
      ELSIF is_admin THEN
        g_mod(p_module) := 'Y';
      ELSE
        SELECT COUNT(*) INTO l_n
          FROM sec_role_grant g
          JOIN sec_role_permission rp ON rp.role_id = g.role_id AND rp.effect = 'ALLOW'
          JOIN sec_permission p ON p.id = rp.permission_id
         WHERE g.membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'))
           AND g.status_code = 'ACTIVE'
           AND (g.effective_to IS NULL OR g.effective_to >= TRUNC(SYSDATE))
           AND p.module_code = p_module
           AND ROWNUM = 1;
        g_mod(p_module) := CASE WHEN l_n > 0 THEN 'Y' ELSE 'N' END;
      END IF;
    END IF;
    RETURN g_mod(p_module);
  END module_ok;

  FUNCTION report_ok(p_module_code IN VARCHAR2, p_permission_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NOONA_APEX_PKG.is_tenant_user = 'N' OR module_ok(p_module_code) = 'N' THEN
      RETURN 'N';
    END IF;
    IF p_permission_code IS NULL OR is_admin THEN
      RETURN 'Y';
    END IF;
    IF NOT g_perm.EXISTS(p_permission_code) THEN
      g_perm(p_permission_code) := NOONA_SECURITY_PKG.has_permission(p_permission_code, company);
    END IF;
    RETURN g_perm(p_permission_code);
  END report_ok;

  FUNCTION has_reports RETURN VARCHAR2 IS
    l_n NUMBER;
  BEGIN
    reset_cache;
    SELECT COUNT(*) INTO l_n FROM bi_report r
     WHERE r.status_code = 'PUBLISHED' AND r.app_alias IS NOT NULL
       AND report_ok(r.module_code, r.permission_code) = 'Y' AND ROWNUM = 1;
    RETURN CASE WHEN l_n > 0 THEN 'Y' ELSE 'N' END;
  END has_reports;

  FUNCTION module_label(p_module_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_module_code
      WHEN 'GL' THEN 'المحاسبة والقوائم المالية' WHEN 'CSH' THEN 'النقدية والبنوك' WHEN 'FA' THEN 'الأصول الثابتة'
      WHEN 'INV' THEN 'المخزون' WHEN 'PUR' THEN 'المشتريات والموردون' WHEN 'SAL' THEN 'المبيعات ونقاط البيع والمطاعم'
      WHEN 'HR' THEN 'الموارد البشرية' WHEN 'PAY' THEN 'الرواتب' WHEN 'PRP' THEN 'الإيجارات والضيافة'
      WHEN 'MNT' THEN 'الصيانة' WHEN 'MFG' THEN 'التصنيع' WHEN 'HIS' THEN 'المستشفى والمراكز الطبية'
      WHEN 'DMS' THEN 'المستندات والأرشيف' WHEN 'RE' THEN 'العقارات وبيع الوحدات' WHEN 'PRJ' THEN 'المشروعات والمقاولات'
      WHEN 'LOC' THEN 'الضرائب والفوترة الإلكترونية'
      ELSE p_module_code END;
  END module_label;

  FUNCTION module_icon(p_module_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_module_code
      WHEN 'GL' THEN 'fa-calculator' WHEN 'CSH' THEN 'fa-money' WHEN 'FA' THEN 'fa-cubes' WHEN 'INV' THEN 'fa-archive'
      WHEN 'PUR' THEN 'fa-truck' WHEN 'SAL' THEN 'fa-shopping-cart' WHEN 'HR' THEN 'fa-users' WHEN 'PAY' THEN 'fa-credit-card'
      WHEN 'PRP' THEN 'fa-bed' WHEN 'MNT' THEN 'fa-wrench' WHEN 'MFG' THEN 'fa-industry' WHEN 'HIS' THEN 'fa-hospital-o'
      WHEN 'DMS' THEN 'fa-folder-open' WHEN 'RE' THEN 'fa-building' WHEN 'PRJ' THEN 'fa-briefcase' WHEN 'LOC' THEN 'fa-percent' ELSE 'fa-bar-chart' END;
  END module_icon;

  FUNCTION type_label(p_report_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_report_type WHEN 'FINANCIAL' THEN 'مالي' WHEN 'OPERATIONAL' THEN 'تشغيلي' WHEN 'MANAGEMENT' THEN 'إداري'
                              WHEN 'REGULATORY' THEN 'رقابي ونظامي' WHEN 'ANALYTICAL' THEN 'تحليلي' ELSE p_report_type END;
  END type_label;

  FUNCTION installed(p_apps VARCHAR2, p_alias VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN p_apps IS NULL OR INSTR(',' || p_apps || ',', ',' || p_alias || ',') > 0;
  END installed;

  FUNCTION matches(p_search VARCHAR2, p_name VARCHAR2, p_en VARCHAR2, p_desc VARCHAR2, p_module VARCHAR2) RETURN BOOLEAN IS
    l VARCHAR2(400) := LOWER(TRIM(p_search));
  BEGIN
    RETURN l IS NULL OR INSTR(LOWER(p_name || ' ' || p_en || ' ' || p_desc || ' ' || module_label(p_module)), l) > 0;
  END matches;

  -- بطاقة تقرير
  FUNCTION card(p_id NUMBER, p_name VARCHAR2, p_desc VARCHAR2, p_type VARCHAR2, p_icon VARCHAR2, p_module VARCHAR2,
                p_fav VARCHAR2, p_ok BOOLEAN, p_session VARCHAR2, p_show_module BOOLEAN) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-rh-rep' || CASE WHEN NOT p_ok THEN ' is-disabled' END || '">'
        || CASE WHEN p_ok THEN '<a class="nn-rh-rep-link" href="' || NOONA_UI_PKG.url(c_app, 'OPEN', p_session, 'P3_ID', p_id) || '">'
                ELSE '<div class="nn-rh-rep-link" title="تطبيق الوحدة غير مثبت">' END
        || '<span class="nn-rh-rep-icon fa ' || esc(NVL(p_icon, 'fa-file-text-o')) || '" aria-hidden="true"></span>'
        || '<span class="nn-rh-rep-body"><span class="nn-rh-rep-name">' || esc(p_name) || '</span>'
        || '<span class="nn-rh-rep-desc">' || esc(p_desc) || '</span>'
        || '<span class="nn-rh-rep-tags"><span class="nn-badge is-muted">' || esc(type_label(p_type)) || '</span>'
        || CASE WHEN p_show_module THEN '<span class="nn-badge is-info">' || esc(module_label(p_module)) || '</span>' END
        || CASE WHEN NOT p_ok THEN '<span class="nn-badge is-warning">غير مثبت</span>' END
        || '</span></span>'
        || CASE WHEN p_ok THEN '</a>' ELSE '</div>' END
        || '<button type="button" class="nn-rh-fav' || CASE WHEN p_fav = 'Y' THEN ' is-on' END || '" data-id="' || p_id
        || '" title="' || CASE WHEN p_fav = 'Y' THEN 'إزالة من المفضلة' ELSE 'إضافة للمفضلة' END || '" aria-label="المفضلة">'
        || '<span class="fa ' || CASE WHEN p_fav = 'Y' THEN 'fa-star' ELSE 'fa-star-o' END || '" aria-hidden="true"></span></button>'
        || '</div>';
  END card;

  -- صف تقارير (المفضلة / الأخيرة / نتائج البحث)
  FUNCTION report_list(p_mode VARCHAR2, p_session VARCHAR2, p_apps VARCHAR2, p_search VARCHAR2, p_limit PLS_INTEGER) RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    FOR r IN (SELECT b.id, b.name_ar, b.name_en, b.description, b.report_type, b.icon_class, b.module_code, b.app_alias,
                     NVL(u.is_favorite, 'N') fav, u.last_opened_at, u.open_count
                FROM bi_report b
                LEFT JOIN bi_report_user u ON u.report_id = b.id
                     AND u.membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'))
               WHERE b.status_code = 'PUBLISHED' AND b.app_alias IS NOT NULL
                 AND (p_mode = 'SEARCH' OR (p_mode = 'FAV' AND u.is_favorite = 'Y') OR (p_mode = 'RECENT' AND u.last_opened_at IS NOT NULL))
                 AND report_ok(b.module_code, b.permission_code) = 'Y'
               ORDER BY CASE WHEN p_mode = 'RECENT' THEN u.last_opened_at END DESC NULLS LAST, b.sort_order) LOOP
      CONTINUE WHEN p_mode = 'SEARCH' AND NOT matches(p_search, r.name_ar, r.name_en, r.description, r.module_code);
      l_n := l_n + 1;
      EXIT WHEN l_n > p_limit;
      l_html := l_html || card(r.id, r.name_ar, r.description, r.report_type, r.icon_class, r.module_code, r.fav,
                               installed(p_apps, r.app_alias), p_session, TRUE);
    END LOOP;
    RETURN l_html;
  END report_list;

  FUNCTION search_box(p_session VARCHAR2, p_module VARCHAR2, p_search VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-rh-search"><span class="fa fa-search" aria-hidden="true"></span>'
        || '<input type="search" id="nnRhSearch" class="nn-rh-search-input" value="' || esc(p_search) || '" '
        || 'placeholder="' || CASE WHEN p_module IS NULL THEN 'ابحث في كل التقارير...' ELSE 'ابحث في تقارير ' || esc(module_label(p_module)) || '...' END
        || '" aria-label="بحث في التقارير" autocomplete="off"></div>';
  END search_box;

  FUNCTION home_html(p_session IN VARCHAR2, p_apps IN VARCHAR2, p_search IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html    CLOB;
    l_cards   CLOB;
    l_list    CLOB;
    l_mods    PLS_INTEGER := 0;
    l_total   PLS_INTEGER := 0;
  BEGIN
    reset_cache;
    -- كارت لكل وحدة مشترك فيها وللمستخدم تقارير فيها، بترتيب الكتالوج
    FOR m IN (SELECT module_code, COUNT(*) cnt, MIN(sort_order) o,
                     LISTAGG(CASE WHEN rn <= 3 THEN name_ar END, ' · ') WITHIN GROUP (ORDER BY sort_order) names,
                     SUM(CASE WHEN fav = 'Y' THEN 1 ELSE 0 END) favs
                FROM (SELECT b.module_code, b.sort_order, b.name_ar, u.is_favorite fav,
                             ROW_NUMBER() OVER (PARTITION BY b.module_code ORDER BY b.sort_order) rn
                        FROM bi_report b
                        LEFT JOIN bi_report_user u ON u.report_id = b.id
                             AND u.membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'))
                       WHERE b.status_code = 'PUBLISHED' AND b.app_alias IS NOT NULL
                         AND report_ok(b.module_code, b.permission_code) = 'Y')
               GROUP BY module_code ORDER BY o) LOOP
      l_mods := l_mods + 1;
      l_total := l_total + m.cnt;
      l_cards := l_cards
        || '<a class="nn-rh-mod nn-rh-mod-' || LOWER(m.module_code) || '" href="'
        || NOONA_UI_PKG.url(c_app, 'MODULE', p_session, 'P2_MODULE', m.module_code) || '">'
        || '<span class="nn-rh-mod-head"><span class="nn-rh-mod-icon fa ' || module_icon(m.module_code) || '" aria-hidden="true"></span>'
        || '<span class="nn-rh-mod-name">' || esc(module_label(m.module_code)) || '</span>'
        || '<span class="nn-rh-mod-count">' || m.cnt || '</span></span>'
        || '<span class="nn-rh-mod-list">'
        || esc(m.names) || CASE WHEN m.cnt > 3 THEN ' ...' END
        || '</span>'
        || '<span class="nn-rh-mod-foot">' || m.cnt || ' تقرير'
        || CASE WHEN m.favs > 0 THEN ' &middot; <span class="fa fa-star" aria-hidden="true"></span> ' || m.favs END
        || '<span class="nn-rh-mod-go">عرض التقارير <span class="fa fa-angle-left" aria-hidden="true"></span></span></span></a>';
    END LOOP;

    l_html := '<div class="nn-rh-hero"><div><div class="nn-hello-title">مركز التقارير</div>'
           || '<div class="nn-hello-sub">' || l_total || ' تقرير في ' || l_mods || ' وحدة حسب اشتراك المؤسسة وصلاحياتك'
           || CASE WHEN NOONA_APEX_PKG.company_name IS NOT NULL THEN ' &middot; ' || esc(NOONA_APEX_PKG.company_name) END
           || '</div></div>' || search_box(p_session, NULL, p_search) || '</div>';

    IF l_mods = 0 THEN
      RETURN l_html || '<div class="nn-launch-empty"><span class="fa fa-lock" aria-hidden="true"></span>'
          || '<b>لا توجد تقارير متاحة لك</b><span>التقارير تظهر حسب الوحدات المشترك فيها وصلاحياتك؛ تواصل مع مسؤول المؤسسة</span></div>';
    END IF;

    IF TRIM(p_search) IS NOT NULL THEN
      l_list := report_list('SEARCH', p_session, p_apps, p_search, 200);
      RETURN l_html || '<h3 class="nn-rh-h">نتائج البحث عن «' || esc(TRIM(p_search)) || '»</h3>'
          || NVL(l_list, '<div class="nn-empty">لا توجد تقارير مطابقة</div>');
    END IF;

    l_list := report_list('FAV', p_session, p_apps, NULL, 12);
    IF l_list IS NOT NULL THEN
      l_html := l_html || '<h3 class="nn-rh-h"><span class="fa fa-star" aria-hidden="true"></span> المفضلة</h3><div class="nn-rh-reps">' || l_list || '</div>';
    END IF;
    l_list := report_list('RECENT', p_session, p_apps, NULL, 6);
    IF l_list IS NOT NULL THEN
      l_html := l_html || '<h3 class="nn-rh-h"><span class="fa fa-history" aria-hidden="true"></span> آخر ما فتحته</h3><div class="nn-rh-reps">' || l_list || '</div>';
    END IF;
    RETURN l_html || '<h3 class="nn-rh-h"><span class="fa fa-th-large" aria-hidden="true"></span> الوحدات</h3><div class="nn-rh-mods">' || l_cards || '</div>';
  END home_html;

  FUNCTION module_html(p_module_code IN VARCHAR2, p_session IN VARCHAR2, p_apps IN VARCHAR2,
                       p_type IN VARCHAR2 DEFAULT NULL, p_search IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html  CLOB;
    l_cards CLOB;
    l_chips VARCHAR2(4000);
    l_n     PLS_INTEGER := 0;
    l_all   PLS_INTEGER := 0;
  BEGIN
    reset_cache;
    IF p_module_code IS NULL OR module_ok(p_module_code) = 'N' THEN
      RETURN '<div class="nn-launch-empty"><span class="fa fa-lock" aria-hidden="true"></span><b>الوحدة غير متاحة</b>'
          || '<span>المؤسسة غير مشتركة في هذه الوحدة أو ليس لك صلاحية فيها</span>'
          || '<a href="' || NOONA_UI_PKG.url(c_app, 'HOME', p_session) || '">العودة لمركز التقارير</a></div>';
    END IF;
    -- أنواع التقارير المتاحة في الوحدة كمرشحات
    FOR t IN (SELECT report_type, COUNT(*) cnt FROM bi_report b
               WHERE b.module_code = p_module_code AND b.status_code = 'PUBLISHED' AND b.app_alias IS NOT NULL
                 AND report_ok(b.module_code, b.permission_code) = 'Y'
               GROUP BY report_type ORDER BY MIN(sort_order)) LOOP
      l_all := l_all + t.cnt;
      l_chips := l_chips || '<a class="nn-rh-chip' || CASE WHEN p_type = t.report_type THEN ' is-on' END || '" href="'
              || NOONA_UI_PKG.url(c_app, 'MODULE', p_session, 'P2_MODULE,P2_TYPE', p_module_code || ',' || t.report_type) || '">'
              || esc(type_label(t.report_type)) || ' <b>' || t.cnt || '</b></a>';
    END LOOP;
    l_chips := '<a class="nn-rh-chip' || CASE WHEN p_type IS NULL THEN ' is-on' END || '" href="'
            || NOONA_UI_PKG.url(c_app, 'MODULE', p_session, 'P2_MODULE,P2_TYPE', p_module_code || ',') || '">الكل <b>' || l_all || '</b></a>' || l_chips;

    FOR r IN (SELECT b.id, b.name_ar, b.name_en, b.description, b.report_type, b.icon_class, b.module_code, b.app_alias,
                     NVL(u.is_favorite, 'N') fav
                FROM bi_report b
                LEFT JOIN bi_report_user u ON u.report_id = b.id
                     AND u.membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'))
               WHERE b.module_code = p_module_code AND b.status_code = 'PUBLISHED' AND b.app_alias IS NOT NULL
                 AND (p_type IS NULL OR b.report_type = p_type)
                 AND report_ok(b.module_code, b.permission_code) = 'Y'
               ORDER BY b.sort_order) LOOP
      CONTINUE WHEN NOT matches(p_search, r.name_ar, r.name_en, r.description, NULL);
      l_n := l_n + 1;
      l_cards := l_cards || card(r.id, r.name_ar, r.description, r.report_type, r.icon_class, r.module_code, r.fav,
                                 installed(p_apps, r.app_alias), p_session, FALSE);
    END LOOP;

    l_html := '<div class="nn-rh-hero"><div class="nn-rh-crumb"><a href="' || NOONA_UI_PKG.url(c_app, 'HOME', p_session) || '">'
           || '<span class="fa fa-angle-right" aria-hidden="true"></span> مركز التقارير</a>'
           || '<div class="nn-hello-title"><span class="nn-rh-mod-icon fa ' || module_icon(p_module_code) || '" aria-hidden="true"></span> '
           || esc(module_label(p_module_code)) || '</div></div>' || search_box(p_session, p_module_code, p_search) || '</div>'
           || '<div class="nn-rh-chips">' || l_chips || '</div>';
    RETURN l_html || CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد تقارير مطابقة</div>'
                          ELSE '<div class="nn-rh-reps">' || l_cards || '</div>' END;
  END module_html;

  FUNCTION open_url(p_report_id IN NUMBER, p_session IN VARCHAR2) RETURN VARCHAR2 IS
    r     bi_report%ROWTYPE;
    l_sid VARCHAR2(30) := REGEXP_REPLACE(p_session, '[^0-9]', '');
  BEGIN
    reset_cache;
    BEGIN
      SELECT * INTO r FROM bi_report WHERE id = p_report_id AND status_code = 'PUBLISHED' AND app_alias IS NOT NULL;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20901, 'NOONA-BI-001: التقرير غير موجود أو أوقف');
    END;
    NOONA_CORE_PKG.assert(report_ok(r.module_code, r.permission_code) = 'Y', 'NOONA-BI-002',
      'ليس لك صلاحية هذا التقرير أو المؤسسة غير مشتركة في وحدته', 'Report not available for this user');
    MERGE INTO bi_report_user u
    USING (SELECT TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')) m FROM dual) x
       ON (u.membership_id = x.m AND u.report_id = p_report_id)
     WHEN MATCHED THEN UPDATE SET u.open_count = u.open_count + 1, u.last_opened_at = SYSTIMESTAMP
     WHEN NOT MATCHED THEN INSERT (membership_id, report_id, is_favorite, open_count, last_opened_at)
          VALUES (x.m, p_report_id, 'N', 1, SYSTIMESTAMP);
    -- مسح مرشحات صفحة التقرير السابقة (عند إمكانه) واختيار التقرير داخل مركز تقارير الوحدة
    RETURN 'f?p=' || r.app_alias || ':' || r.page_alias || ':' || l_sid
        || CASE WHEN r.page_no IS NOT NULL OR r.param_item IS NOT NULL
                THEN '::NO:' || r.page_no || ':' || r.param_item || ':' || r.param_value END;
  END open_url;

  FUNCTION toggle_favorite(p_report_id IN NUMBER) RETURN VARCHAR2 IS
    l_new VARCHAR2(1);
    l_mod bi_report.module_code%TYPE;
    l_prm bi_report.permission_code%TYPE;
  BEGIN
    reset_cache;
    SELECT module_code, permission_code INTO l_mod, l_prm FROM bi_report WHERE id = p_report_id;
    NOONA_CORE_PKG.assert(report_ok(l_mod, l_prm) = 'Y', 'NOONA-BI-002',
      'ليس لك صلاحية هذا التقرير', 'Report not available for this user');
    MERGE INTO bi_report_user u
    USING (SELECT TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')) m FROM dual) x
       ON (u.membership_id = x.m AND u.report_id = p_report_id)
     WHEN MATCHED THEN UPDATE SET u.is_favorite = CASE u.is_favorite WHEN 'Y' THEN 'N' ELSE 'Y' END
     WHEN NOT MATCHED THEN INSERT (membership_id, report_id, is_favorite, open_count) VALUES (x.m, p_report_id, 'Y', 0);
    SELECT is_favorite INTO l_new FROM bi_report_user
     WHERE membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')) AND report_id = p_report_id;
    RETURN l_new;
  END toggle_favorite;
END NOONA_BI_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_BI_PKG
