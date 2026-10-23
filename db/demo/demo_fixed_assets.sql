-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للأصول الثابتة (بعد التحديث 22) - تشغل بحساب NOONA_APP ولا تكرر
-- (تكتشف الأصل ذا الرقم التسلسلي DEMO-FA-001):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_fixed_assets.sql ADMIN
-- المحتوى: مبنى وأرض بأرصدة افتتاحية ومجمع منقول، خط إنتاج من البنك مع إضافة رأسمالية، سيارة آجلة على مورد بضريبة،
-- أجهزة حاسب بعهد موظفين، أثاث نقداً، طابعة قديمة؛ إهلاك مرحل لكل أشهر السنة السابقة للشهر الحالي،
-- بيع جهاز حاسب آجلاً وتخريد الطابعة ونقل جهاز؛ إهلاك الشهر الحالي متروك للتشغيل من الشاشة.
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  c_admin CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co   NUMBER;
  l_n    NUMBER;
  l_y0   DATE;
  l_m0   DATE := TRUNC(SYSDATE, 'MM');
  l_sup  NUMBER;
  l_cus  NUMBER;
  l_box  NUMBER;
  l_cc1  NUMBER;
  l_cc2  NUMBER;
  l_bld  NUMBER;
  l_mach NUMBER;
  l_car  NUMBER;
  l_prn  NUMBER;
  l_pc1  NUMBER;
  l_pc2  NUMBER;
  l_runs NUMBER := 0;
  TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  emp    t_ids;

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  FUNCTION d(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION nz(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN NVL(TO_CHAR(p), 'null'); END;
  FUNCTION cat(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM fa_category WHERE code = p_code AND company_id = l_co;
    RETURN l;
  END cat;
  -- الفترة مفتوحة للترحيل؟
  FUNCTION open_date(p DATE) RETURN BOOLEAN IS
    l NUMBER;
  BEGIN
    l := NOONA_GL_PKG.period_for(p);
    RETURN TRUE;
  EXCEPTION WHEN OTHERS THEN RETURN FALSE;
  END open_date;
  FUNCTION asset(p_json VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_FA_PKG.create_asset('{' || p_json || ',"capitalize":"Y"}');
  END asset;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM fa_asset WHERE company_id = l_co AND serial_no = 'DEMO-FA-001';
  IF l_n > 0 THEN
    say('بيانات الأصول التجريبية محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  IF NOONA_FA_PKG.is_ready = 'N' THEN
    l_n := NOONA_FA_PKG.quick_setup;
    say('تم تجهيز الأصول الثابتة (الدفتر والفئات والحسابات)');
  END IF;
  -- بداية السنة إن كانت مفتوحة، وإلا الشهر الحالي
  l_y0 := TRUNC(SYSDATE, 'YYYY');
  IF NOT open_date(l_y0) THEN l_y0 := l_m0; END IF;
  SELECT MIN(party_id) INTO l_sup FROM ap_supplier;
  SELECT MIN(party_id) INTO l_cus FROM ar_customer;
  SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = l_co AND status_code = 'ACTIVE';
  SELECT MIN(id), MAX(id) INTO l_cc1, l_cc2 FROM gl_cost_center WHERE company_id = l_co AND status_code = 'ACTIVE';
  FOR r IN (SELECT ROWNUM rn, id FROM (SELECT e.id FROM hr_employee e WHERE EXISTS (SELECT 1 FROM hr_employment m
              WHERE m.employee_id = e.id AND m.company_id = l_co AND m.status_code = 'ACTIVE') ORDER BY e.employee_no) WHERE ROWNUM <= 3) LOOP
    emp(r.rn) := r.id;
  END LOOP;
  FOR i IN 1 .. 3 LOOP
    IF NOT emp.EXISTS(i) THEN emp(i) := NULL; END IF;
  END LOOP;

  -- أصول قائمة قبل النظام (رصيد افتتاحي ومجمع منقول)
  l_bld := asset('"name_ar":"مبنى الإدارة العامة","category":' || cat('BUILDINGS') || ',"cost":2400000,"residual":120000,'
         || '"funding":"OPENING","opening_accum":456000,'
         || '"acquisition_date":"' || d(l_y0) || '","in_service_date":"' || d(ADD_MONTHS(l_y0, -60)) || '","location":"الرياض - طريق الملك فهد",'
         || '"cost_center":' || nz(l_cc1) || ',"serial":"DEMO-FA-001","reference":"رصيد افتتاحي"');
  l_n := asset('"name_ar":"أرض المستودعات - السلي","category":' || cat('LAND') || ',"cost":1500000,"funding":"OPENING",'
         || '"acquisition_date":"' || d(l_y0) || '","in_service_date":"' || d(ADD_MONTHS(l_y0, -96)) || '","location":"الرياض - حي السلي"');
  l_prn := asset('"name_ar":"طابعة ليزر قديمة","category":' || cat('FURNITURE') || ',"cost":8000,"funding":"OPENING","opening_accum":7200,'
         || '"acquisition_date":"' || d(l_y0) || '","in_service_date":"' || d(ADD_MONTHS(l_y0, -54)) || '","cost_center":' || nz(l_cc1));
  -- مشتريات السنة
  l_mach := asset('"name_ar":"خط تعبئة وتغليف آلي","category":' || cat('MACHINERY') || ',"cost":350000,"vat":52500,"funding":"BANK",'
         || '"acquisition_date":"' || d(l_y0) || '","in_service_date":"' || d(l_y0 + 9) || '","manufacturer":"Krones","model":"KX-200",'
         || '"serial":"KX200-77815","warranty_end":"' || d(ADD_MONTHS(l_y0, 24)) || '","cost_center":' || nz(l_cc2) || ',"location":"المصنع - العنبر 2"');
  IF l_sup IS NOT NULL THEN
    l_car := asset('"name_ar":"شاحنة توزيع إيسوزو","category":' || cat('VEHICLES') || ',"cost":120000,"vat":18000,"funding":"PAYABLE",'
           || '"party":' || l_sup || ',"acquisition_date":"' || d(l_y0) || '","in_service_date":"' || d(l_y0 + 14) || '","manufacturer":"Isuzu",'
           || '"model":"NPR 2026","serial":"JAL-55821","cost_center":' || nz(l_cc2) || ',"reference":"فاتورة المورد 7781"');
  END IF;
  l_n := asset('"name_ar":"أثاث مكاتب الإدارة","category":' || cat('FURNITURE') || ',"cost":45000,"vat":6750,"funding":"'
         || CASE WHEN l_box IS NOT NULL THEN 'CASH' ELSE 'BANK' END || '","cash_box":' || nz(l_box) || ',"acquisition_date":"' || d(l_y0)
         || '","in_service_date":"' || d(l_y0) || '","prorate":"FULL_MONTH","cost_center":' || nz(l_cc1));
  l_pc1 := asset('"name_ar":"حاسب محمول Dell Latitude","category":' || cat('COMPUTERS') || ',"cost":6500,"vat":975,"funding":"BANK",'
         || '"acquisition_date":"' || d(l_y0) || '","in_service_date":"' || d(l_y0) || '","custodian":' || nz(emp(1)) || ',"serial":"DL-5540-01"');
  l_pc2 := asset('"name_ar":"حاسب محمول Dell Latitude","category":' || cat('COMPUTERS') || ',"cost":6500,"vat":975,"funding":"BANK",'
         || '"acquisition_date":"' || d(l_y0) || '","in_service_date":"' || d(l_y0) || '","custodian":' || nz(emp(2)) || ',"serial":"DL-5540-02"');
  l_n := asset('"name_ar":"خادم بيانات HP ProLiant","category":' || cat('COMPUTERS') || ',"cost":38000,"vat":5700,"funding":"BANK",'
         || '"acquisition_date":"' || d(l_y0) || '","in_service_date":"' || d(l_y0) || '","custodian":' || nz(emp(3))
         || ',"location":"غرفة الخوادم","serial":"HP-DL380-9"');
  -- مسودة بانتظار الرسملة
  l_n := NOONA_FA_PKG.create_asset('{"name_ar":"مكيفات مركزية (بانتظار الفاتورة)","category":' || cat('MACHINERY')
         || ',"cost":64000,"funding":"BANK","acquisition_date":"' || d(l_m0) || '"}');
  say('تم إنشاء 10 أصول (9 مرسملة ومسودة)');

  -- إهلاك الأشهر المنتهية من السنة
  FOR p IN (SELECT p.id, p.period_code FROM gl_period p JOIN gl_fiscal_year y ON y.id = p.fiscal_year_id
             WHERE p.company_id = l_co AND p.period_type = 'NORMAL' AND y.status_code = 'OPEN'
               AND p.start_date >= l_y0 AND p.end_date < l_m0
               AND NOT EXISTS (SELECT 1 FROM fa_depreciation_run r JOIN gl_period p2 ON p2.id = r.period_id
                                WHERE r.company_id = l_co AND r.status_code = 'POSTED' AND p2.start_date >= p.start_date)
             ORDER BY p.start_date) LOOP
    l_n := NOONA_FA_PKG.run_depreciation(p.id);
    l_runs := l_runs + 1;
  END LOOP;
  say('تم ترحيل إهلاك ' || l_runs || ' شهراً');

  -- حركات: إضافة رأسمالية، نقل عهدة، بيع آجل، تخريد
  IF l_runs > 0 THEN
    l_n := NOONA_FA_PKG.add_cost(l_mach, 28000, LAST_DAY(ADD_MONTHS(l_m0, -1)), 'BANK', NULL, NULL, NULL, NULL, 4200,
                                 'وحدة فحص بالكاميرا مضافة للخط');
    IF emp(3) IS NOT NULL THEN
      l_n := NOONA_FA_PKG.transfer(l_pc2, LAST_DAY(ADD_MONTHS(l_m0, -1)), NULL, NULL, emp(3), 'الإدارة المالية', 'تسليم عهدة لموظف جديد');
    END IF;
    IF l_cus IS NOT NULL THEN
      l_n := NOONA_FA_PKG.dispose(l_pc1, 'SALE', LAST_DAY(ADD_MONTHS(l_m0, -1)), 4200, 630, 'RECEIVABLE', NULL, NULL, l_cus,
                                  'بيع جهاز مستعمل للعميل');
    END IF;
    l_n := NOONA_FA_PKG.dispose(l_prn, 'SCRAP', LAST_DAY(ADD_MONTHS(l_m0, -1)), 300, 45, 'BANK', NULL, NULL, NULL,
                                'تعطل غير قابل للإصلاح؛ بيعت خردة');
    say('إضافة رأسمالية على خط التعبئة، نقل عهدة، بيع جهاز حاسب آجلاً، تخريد الطابعة');
  END IF;

  COMMIT;
  say('');
  say('تم تحميل بيانات الأصول الثابتة التجريبية. افتح «المالية ← الأصول الثابتة»، وشغّل إهلاك الشهر الحالي من «إهلاك الأصول».');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
