-- =============================================================================
-- NOONA PLUS ERP | اختبار مركز التقارير الموحد: الكتالوج، كروت الوحدات حسب الاشتراك، صلاحيات المستخدم،
--                  فتح التقرير في تطبيق وحدته، المفضلة والأخيرة والبحث (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_reports_hub.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_sess NUMBER := TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12));
  l_n    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_co   NUMBER;
  l_ten  NUMBER;
  l_mem  NUMBER;
  l_role NUMBER;
  l_g    NUMBER;
  l_mods VARCHAR2(4000);
  l_apps CONSTANT VARCHAR2(400) := 'NOONA_FIN,NOONA_SCM,NOONA_POS,NOONA_HR,NOONA_PRJ,NOONA_MFG,NOONA_HIS,NOONA_DOC';

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  -- الاشتراك يضبطه مسؤول المنصة ثم يعود الاختبار لمسؤول المؤسسة
  PROCEDURE modules(p_ids VARCHAR2) IS
    l VARCHAR2(100);
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth('PLATFORM', l_sess + 9);
    l := NOONA_PLATFORM_ADMIN_PKG.set_tenant_modules(l_ten, p_ids);
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth('ADMIN', l_sess);
  END modules;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION rid(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM bi_report WHERE tenant_id IS NULL AND code = p_code; RETURN l;
  END rid;
  FUNCTION has(p_html CLOB, p_text VARCHAR2) RETURN BOOLEAN IS
  BEGIN RETURN DBMS_LOB.INSTR(p_html, p_text) > 0; END;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', l_sess);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  l_ten := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID'));
  -- يبدأ من مفضلة وسجل فتح فارغين لهذا المستخدم (يتراجع في النهاية)
  DELETE FROM bi_report_user WHERE membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'));

  -- ======================================================== الكتالوج
  SELECT COUNT(*), COUNT(DISTINCT module_code) INTO l_n, l_s FROM bi_report WHERE status_code = 'PUBLISHED' AND app_alias IS NOT NULL;
  ok('catalog has the reports of all modules', l_n >= 60 AND TO_NUMBER(l_s) >= 13, l_n || ' / ' || l_s);
  SELECT COUNT(*) INTO l_n FROM bi_report WHERE status_code = 'PUBLISHED' AND app_alias IS NOT NULL
     AND (page_alias IS NULL OR (param_item IS NOT NULL AND (param_value IS NULL OR page_no IS NULL)));
  ok('every report has a page and a complete selector', l_n = 0, l_n);

  -- ======================================================== كل الوحدات مشترك فيها (مسؤول المؤسسة)
  SELECT LISTAGG(id, ',') WITHIN GROUP (ORDER BY id) INTO l_mods FROM plt_module WHERE is_active = 'Y';
  modules(l_mods);
  ok('reports center visible in systems list', NOONA_PORTAL_PKG.app_visible('NOONA_BI', NULL) = 'Y');
  SELECT COUNT(*) INTO l_n FROM noona_v_apps WHERE app_alias = 'NOONA_BI';
  ok('reports center in apps view', l_n = 1, l_n);
  l_c := NOONA_BI_PKG.home_html(l_sess, l_apps);
  ok('home shows a card per module', has(l_c, 'nn-rh-mod-gl') AND has(l_c, 'nn-rh-mod-inv') AND has(l_c, 'nn-rh-mod-sal')
     AND has(l_c, 'nn-rh-mod-hr') AND has(l_c, 'nn-rh-mod-pay') AND has(l_c, 'nn-rh-mod-mfg') AND has(l_c, 'nn-rh-mod-his')
     AND has(l_c, 'nn-rh-mod-dms') AND has(l_c, 'P2_MODULE:GL'));
  ok('module card lists its first reports', has(l_c, 'ميزان المراجعة · كشف حساب · قائمة الدخل'));
  ok('no favourites or recent yet', NOT has(l_c, 'آخر ما فتحته'));
  l_c := NOONA_BI_PKG.module_html('GL', l_sess, l_apps);
  ok('module page lists its reports', has(l_c, 'ميزان المراجعة') AND has(l_c, 'سجل التدقيق المالي') AND NOT has(l_c, 'سجل المشتريات'));
  ok('module page type chips', has(l_c, 'nn-rh-chip') AND has(l_c, 'تحليلي') AND has(l_c, 'P2_MODULE,P2_TYPE:GL,ANALYTICAL'));
  l_c := NOONA_BI_PKG.module_html('PAY', l_sess, l_apps, 'REGULATORY');
  ok('type filter', has(l_c, 'التأمينات الاجتماعية') AND NOT has(l_c, 'مسير الرواتب'));
  l_c := NOONA_BI_PKG.module_html('INV', l_sess, 'NOONA_FIN');
  ok('report of an app not installed is shown disabled', has(l_c, 'غير مثبت') AND NOT has(l_c, 'P3_ID'));

  -- ======================================================== الفتح والمفضلة والبحث
  l_s := NOONA_BI_PKG.open_url(rid('INV_STOCK'), l_sess);
  ok('open report inside its module report center', l_s = 'f?p=NOONA_SCM:REPORTS:' || l_sess || '::NO:50:P50_REPORT:STOCK', l_s);
  l_s := NOONA_BI_PKG.open_url(rid('GL_TB'), l_sess);
  ok('open a dedicated report page', l_s = 'f?p=NOONA_FIN:TRIAL-BALANCE:' || l_sess, l_s);
  l_s := NOONA_BI_PKG.open_url(rid('MNT_PERF'), l_sess);
  ok('open a page clearing its filters', l_s = 'f?p=NOONA_PRJ:MAINT-REPORTS:' || l_sess || '::NO:75::', l_s);
  l_s := NOONA_BI_PKG.open_url(rid('INV_STOCK'), l_sess);
  l_g := rid('INV_STOCK');
  SELECT open_count INTO l_n FROM bi_report_user WHERE report_id = l_g
     AND membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'));
  ok('opens counted per user', l_n = 2, l_n);
  ok('favourite on', NOONA_BI_PKG.toggle_favorite(rid('HIS_REV')) = 'Y');
  l_c := NOONA_BI_PKG.home_html(l_sess, l_apps);
  ok('home shows favourites and recent', has(l_c, 'المفضلة') AND has(l_c, 'آخر ما فتحته') AND has(l_c, 'nn-rh-fav is-on')
     AND DBMS_LOB.INSTR(l_c, 'أرصدة المخزون') < DBMS_LOB.INSTR(l_c, 'الوحدات</h3>'));
  ok('favourite off', NOONA_BI_PKG.toggle_favorite(rid('HIS_REV')) = 'N');
  l_c := NOONA_BI_PKG.home_html(l_sess, l_apps, 'ميزان');
  ok('search across all reports', has(l_c, 'نتائج البحث') AND has(l_c, 'ميزان المراجعة') AND NOT has(l_c, 'سجل المشتريات'));
  l_c := NOONA_BI_PKG.home_html(l_sess, l_apps, 'GOSI');
  ok('search by English name', has(l_c, 'التأمينات الاجتماعية'));
  l_c := NOONA_BI_PKG.home_html(l_sess, l_apps, 'الرواتب');
  ok('search by module name', has(l_c, 'مسير الرواتب') AND has(l_c, 'السلف القائمة'));

  -- ======================================================== الاشتراك: إيقاف وحدة التصنيع
  SELECT LISTAGG(id, ',') WITHIN GROUP (ORDER BY id) INTO l_mods FROM plt_module WHERE is_active = 'Y' AND module_code <> 'MFG';
  modules(l_mods);
  l_c := NOONA_BI_PKG.home_html(l_sess, l_apps);
  ok('unsubscribed module card hidden', NOT has(l_c, 'nn-rh-mod-mfg') AND has(l_c, 'nn-rh-mod-gl'));
  ok('unsubscribed module page blocked', has(NOONA_BI_PKG.module_html('MFG', l_sess, l_apps), 'الوحدة غير متاحة'));
  l_c := NOONA_BI_PKG.home_html(l_sess, l_apps, 'الإنتاج');
  ok('search skips unsubscribed reports', NOT has(l_c, 'سجل أوامر الإنتاج'));
  BEGIN l_s := NOONA_BI_PKG.open_url(rid('MFG_ORDERS'), l_sess); ok('unsubscribed report cannot be opened', FALSE, l_s);
  EXCEPTION WHEN OTHERS THEN expect('unsubscribed report cannot be opened', 'NOONA-BI-002', SQLERRM); END;
  BEGIN l_s := NOONA_BI_PKG.toggle_favorite(rid('MFG_ORDERS')); ok('unsubscribed report cannot be favourite', FALSE, l_s);
  EXCEPTION WHEN OTHERS THEN expect('unsubscribed report cannot be favourite', 'NOONA-BI-002', SQLERRM); END;
  BEGIN l_s := NOONA_BI_PKG.open_url(-1, l_sess); ok('unknown report', FALSE, l_s);
  EXCEPTION WHEN OTHERS THEN expect('unknown report', 'NOONA-BI-001', SQLERRM); END;

  -- ======================================================== مستخدم بصلاحية الموارد البشرية فقط
  l_mem := NOONA_SEC_ADMIN_PKG.create_user('R' || l_sfx, 'مستخدم تقارير', 'r' || l_sfx || '@demo.local', l_co);
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('R' || l_sfx, l_sess + 1);
  ok('user without roles has no reports', NOONA_BI_PKG.has_reports = 'N' AND NOONA_PORTAL_PKG.app_visible('NOONA_BI', NULL) = 'N');
  ok('empty reports center message', has(NOONA_BI_PKG.home_html(l_sess + 1, l_apps), 'لا توجد تقارير متاحة لك'));
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', l_sess);
  l_role := NOONA_SEC_ADMIN_PKG.create_role('RH' || l_sfx, 'شؤون الموظفين');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'HR', 'VIEW');
  l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, l_co, 'اختبار مركز التقارير');
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('R' || l_sfx, l_sess + 1);
  ok('HR user sees the reports center', NOONA_BI_PKG.has_reports = 'Y' AND NOONA_PORTAL_PKG.app_visible('NOONA_BI', NULL) = 'Y');
  l_c := NOONA_BI_PKG.home_html(l_sess + 1, l_apps);
  ok('HR user sees only the HR card', has(l_c, 'nn-rh-mod-hr') AND NOT has(l_c, 'nn-rh-mod-gl') AND NOT has(l_c, 'nn-rh-mod-pay')
     AND NOT has(l_c, 'nn-rh-mod-his'), SUBSTR(l_c, 1, 300));
  ok('HR module reports', has(NOONA_BI_PKG.module_html('HR', l_sess + 1, l_apps), 'أرصدة الإجازات'));
  ok('payroll module not available to HR user', has(NOONA_BI_PKG.module_html('PAY', l_sess + 1, l_apps), 'الوحدة غير متاحة'));
  l_s := NOONA_BI_PKG.open_url(rid('HR_LEAVES'), l_sess + 1);
  ok('HR user opens an HR report', l_s LIKE 'f?p=NOONA_HR:REPORTS:%::NO:60:P60_REPORT:LEAVES', l_s);
  BEGIN l_s := NOONA_BI_PKG.open_url(rid('GL_TB'), l_sess + 1); ok('HR user cannot open a GL report', FALSE, l_s);
  EXCEPTION WHEN OTHERS THEN expect('HR user cannot open a GL report', 'NOONA-BI-002', SQLERRM); END;
  ok('favourites are per user', NOONA_BI_PKG.toggle_favorite(rid('HR_LEAVES')) = 'Y');
  l_g := rid('HR_LEAVES');
  SELECT COUNT(*) INTO l_n FROM bi_report_user WHERE report_id = l_g AND is_favorite = 'Y';
  ok('one favourite row for this user', l_n = 1, l_n);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
