-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للموارد البشرية والرواتب (بعد التحديث 21) - تشغل بحساب NOONA_APP ولا تكرر
-- (تكتشف الموظف ذا الهوية 1000000101):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_hr.sql ADMIN
-- المحتوى: 8 موظفين (سعوديون ومقيمون بخدمة من شهر إلى 8 سنوات وبنوك وآيبانات)، أرصدة إجازات مرحلة،
-- رواتب الشهرين السابقين مرحلة ومصروفة (بمخصصات نهاية الخدمة والإجازات)، رواتب الشهر الحالي محسوبة للمراجعة
-- بمكافأة وعمولة وجزاء وإضافي معتمد وغياب وإجازة غير مدفوعة، سلفة قائمة بأقساط، إجازات معتمدة ومعلقة،
-- وحضور بتأخير.
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
  TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  m      t_ids;            -- علاقات التوظيف
  e      t_ids;            -- الموظفون
  l_co   NUMBER;
  l_n    NUMBER;
  l_bank NUMBER;
  l_cc1  NUMBER;
  l_cc2  NUMBER;
  l_m0   DATE := TRUNC(SYSDATE, 'MM');
  l_run  NUMBER;
  l_per  NUMBER;
  l_id   NUMBER;

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  FUNCTION d(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION hire(p_name VARCHAR2, p_en VARCHAR2, p_nid VARCHAR2, p_nat VARCHAR2, p_gender VARCHAR2, p_date DATE, p_job VARCHAR2,
                p_cc NUMBER, p_bank VARCHAR2, p_iban VARCHAR2, p_basic NUMBER, p_house NUMBER, p_trans NUMBER, p_other NUMBER,
                p_expiry DATE DEFAULT NULL) RETURN NUMBER IS
    l_bk NUMBER;
  BEGIN
    SELECT MIN(id) INTO l_bk FROM ref_bank WHERE code = p_bank;
    RETURN NOONA_HR_PKG.save_employee('{"name_ar":"' || p_name || '","name_en":"' || p_en || '","national_id":"' || p_nid
      || '","nationality":"' || p_nat || '","gender":"' || p_gender || '","hire_date":"' || d(p_date) || '","job_title":"' || p_job
      || '","cost_center":' || NVL(TO_CHAR(p_cc), 'null') || ',"bank":' || NVL(TO_CHAR(l_bk), 'null') || ',"iban":"' || p_iban
      || '","gosi_no":"' || SUBSTR(p_nid, 2, 9) || '","id_expiry":' || CASE WHEN p_expiry IS NULL THEN 'null' ELSE '"' || d(p_expiry) || '"' END
      || ',"salary":{"BASIC":' || p_basic || ',"HOUSING":' || p_house || ',"TRANSPORT":' || p_trans || ',"OTHER_ALLOW":' || p_other || '}}');
  END hire;
  FUNCTION emp_of(p_m NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT employee_id INTO l FROM hr_employment WHERE id = p_m; RETURN l;
  END emp_of;
  -- رواتب فترة كاملة: حساب واعتماد وترحيل وصرف
  PROCEDURE payroll(p_month DATE, p_pay BOOLEAN) IS
  BEGIN
    l_per := NOONA_PAY_PKG.period_for(p_month);
    SELECT MIN(id) INTO l_run FROM pay_run WHERE period_id = l_per AND run_type = 'REGULAR';
    IF l_run IS NULL THEN l_run := NOONA_PAY_PKG.create_run(l_per); END IF;
    -- فترة رحلت رواتبها سابقاً لا يعاد حسابها
    IF NOONA_PAY_PKG.run_status(l_run) NOT IN ('OPEN', 'CALCULATED') THEN RETURN; END IF;
    l_n := NOONA_PAY_PKG.calculate(l_run);
    IF p_pay THEN
      NOONA_PAY_PKG.approve_run(l_run);
      l_id := NOONA_PAY_PKG.post_run(l_run);
      IF l_bank IS NOT NULL THEN l_id := NOONA_PAY_PKG.pay_out(l_run, l_bank); END IF;
    END IF;
  END payroll;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM hr_employee WHERE national_id = '1000000101';
  IF l_n > 0 THEN
    say('بيانات الموارد البشرية التجريبية محملة سابقاً - لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  l_n := NOONA_PAY_PKG.quick_setup;
  SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = l_co AND status_code = 'ACTIVE';
  SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY code) INTO l_cc1 FROM gl_cost_center WHERE company_id = l_co;
  SELECT MAX(id) KEEP (DENSE_RANK LAST ORDER BY code) INTO l_cc2 FROM gl_cost_center WHERE company_id = l_co;
  say('التجهيز: مجموعة الرواتب والفترات والحسابات' || CASE WHEN l_bank IS NULL THEN ' (لا يوجد حساب بنكي: لن تصرف الرواتب)' END);

  -- ====================================================== الموظفون
  m(1) := hire('فيصل بن عبدالرحمن الدوسري', 'Faisal Aldossari', '1000000101', 'SA', 'M', ADD_MONTHS(l_m0, -96) + 10, 'المدير المالي',
               l_cc1, 'SA-RJHI', 'SA0380000000608010167519', 18000, 4500, 1800, 1500);
  m(2) := hire('نورة بنت سعد القحطاني', 'Noura Alqahtani', '1000000102', 'SA', 'F', ADD_MONTHS(l_m0, -40) + 4, 'محاسبة أولى',
               l_cc1, 'SA-NCB', 'SA4410000001234567890123', 11000, 2750, 1100, 0);
  m(3) := hire('محمد بن علي الشهري', 'Mohammed Alshehri', '1000000103', 'SA', 'M', ADD_MONTHS(l_m0, -18), 'مندوب مبيعات',
               l_cc2, 'SA-RIBL', 'SA6920000002345678901234', 7000, 1750, 700, 500);
  m(4) := hire('سارة بنت خالد العنزي', 'Sara Alanazi', '1000000104', 'SA', 'F', ADD_MONTHS(l_m0, -6), 'أخصائية موارد بشرية',
               l_cc1, 'SA-ALBI', 'SA1515000003456789012345', 8500, 2125, 850, 0);
  m(5) := hire('أحمد محمود عبدالله', 'Ahmed Mahmoud', '2000000105', 'EG', 'M', ADD_MONTHS(l_m0, -62), 'مشرف مستودع',
               l_cc2, 'SA-RJHI', 'SA0380000000608010167520', 6500, 1625, 650, 300, TRUNC(SYSDATE) + 40);
  m(6) := hire('راجيش كومار', 'Rajesh Kumar', '2000000106', 'IN', 'M', ADD_MONTHS(l_m0, -30), 'فني صيانة',
               l_cc2, 'SA-INMA', 'SA0505000004567890123456', 3500, 875, 350, 0);
  m(7) := hire('مارك أنتوني ريس', 'Mark Anthony Reyes', '2000000107', 'PH', 'M', ADD_MONTHS(l_m0, -12), 'محاسب مساعد',
               l_cc1, 'SA-NCB', 'SA4410000001234567890124', 4500, 1125, 450, 0, TRUNC(SYSDATE) + 20);
  m(8) := hire('عبدالعزيز بن ناصر الحربي', 'Abdulaziz Alharbi', '1000000108', 'SA', 'M', l_m0 + 9, 'كاشير',
               l_cc2, 'SA-RJHI', 'SA0380000000608010167521', 5000, 1250, 500, 0);
  FOR i IN 1 .. 8 LOOP e(i) := emp_of(m(i)); END LOOP;
  l_n := NOONA_HR_PKG.transfer(m(2), TRUNC(SYSDATE), NULL, NULL, NULL, NULL, e(1), 'المدير المباشر');
  l_n := NOONA_HR_PKG.transfer(m(7), TRUNC(SYSDATE), NULL, NULL, NULL, NULL, e(1), 'المدير المباشر');
  say('الموظفون: 8 (5 سعوديين و3 مقيمين؛ نسبة التوطين 62.5%)');
  -- أرصدة إجازات مرحلة من السنة السابقة
  NOONA_HR_PKG.adjust_leave(e(1), 'ANNUAL', 18, 'رصيد مرحل من السنة السابقة');
  NOONA_HR_PKG.adjust_leave(e(2), 'ANNUAL', 9, 'رصيد مرحل من السنة السابقة');
  NOONA_HR_PKG.adjust_leave(e(5), 'ANNUAL', 22, 'رصيد مرحل من السنة السابقة');
  NOONA_HR_PKG.adjust_leave(e(6), 'ANNUAL', 6, 'رصيد مرحل من السنة السابقة');

  -- ====================================================== الشهران السابقان: رواتب مرحلة ومصروفة
  IF ADD_MONTHS(l_m0, -2) >= TRUNC(SYSDATE, 'YYYY') THEN
    l_id := NOONA_HR_PKG.request_leave('{"employee":' || e(5) || ',"type":"ANNUAL","start":"' || d(ADD_MONTHS(l_m0, -2) + 9)
            || '","end":"' || d(ADD_MONTHS(l_m0, -2) + 15) || '","reason":"إجازة سنوية"}');
    NOONA_HR_PKG.approve_leave(l_id);
    l_n := NOONA_PAY_PKG.add_input(NOONA_PAY_PKG.period_for(ADD_MONTHS(l_m0, -2)), m(3), 'COMMISSION', NULL, 2400);
    payroll(ADD_MONTHS(l_m0, -2), TRUE);
    say('رواتب ' || TO_CHAR(ADD_MONTHS(l_m0, -2), 'YYYY-MM') || ': مرحلة ومصروفة');
  END IF;
  IF ADD_MONTHS(l_m0, -1) >= TRUNC(SYSDATE, 'YYYY') THEN
    l_id := NOONA_PAY_PKG.create_loan(m(6), 'SALARY_ADVANCE', 3000, 6, NOONA_PAY_PKG.period_for(ADD_MONTHS(l_m0, -1)), ADD_MONTHS(l_m0, -1) + 2);
    IF l_bank IS NOT NULL THEN l_n := NOONA_PAY_PKG.disburse_loan(l_id, l_bank, NULL, ADD_MONTHS(l_m0, -1) + 2); END IF;
    l_n := NOONA_PAY_PKG.add_input(NOONA_PAY_PKG.period_for(ADD_MONTHS(l_m0, -1)), m(3), 'COMMISSION', NULL, 3150);
    l_n := NOONA_PAY_PKG.add_input(NOONA_PAY_PKG.period_for(ADD_MONTHS(l_m0, -1)), m(6), 'OVERTIME', 12, NULL);
    payroll(ADD_MONTHS(l_m0, -1), TRUE);
    say('رواتب ' || TO_CHAR(ADD_MONTHS(l_m0, -1), 'YYYY-MM') || ': مرحلة ومصروفة، وسلفة 3,000 على 6 أقساط');
  END IF;

  -- ====================================================== الشهر الحالي: إجازات وحضور ومدخلات ثم حساب للمراجعة
  l_id := NOONA_HR_PKG.request_leave('{"employee":' || e(3) || ',"type":"UNPAID","start":"' || d(l_m0 + 2) || '","end":"' || d(l_m0 + 3)
          || '","reason":"ظرف عائلي"}');
  NOONA_HR_PKG.approve_leave(l_id);
  l_id := NOONA_HR_PKG.request_leave('{"employee":' || e(2) || ',"type":"ANNUAL","start":"' || d(LAST_DAY(l_m0) + 3) || '","end":"'
          || d(LAST_DAY(l_m0) + 7) || '","reason":"إجازة سنوية"}');
  l_id := NOONA_HR_PKG.request_leave('{"employee":' || e(6) || ',"type":"SICK","start":"' || d(l_m0 + 1) || '","end":"' || d(l_m0 + 2)
          || '","reason":"تقرير طبي"}');
  NOONA_HR_PKG.approve_leave(l_id);
  l_n := NOONA_HR_PKG.mark_absent(e(7), l_m0 + 4);
  l_n := NOONA_HR_PKG.record_attendance(e(3), l_m0 + 5, '08:45', '17:00');
  l_n := NOONA_HR_PKG.record_attendance(e(4), l_m0 + 5, '07:55', '18:30');
  l_id := NOONA_HR_PKG.request_overtime(e(5), l_m0 + 6, 8, 'جرد المستودع');
  NOONA_HR_PKG.approve_overtime(l_id, 7.5);
  l_id := NOONA_HR_PKG.request_overtime(e(6), l_m0 + 7, 4, 'صيانة طارئة');
  l_per := NOONA_PAY_PKG.period_for(l_m0);
  l_n := NOONA_HR_PKG.change_salary(m(2), LAST_DAY(l_m0) + 1, 12000, 3000, 1200, 0, 'علاوة سنوية');
  SELECT COUNT(*) INTO l_n FROM pay_run WHERE period_id = l_per AND run_type = 'REGULAR' AND status_code IN ('POSTED', 'PAID', 'CLOSED');
  IF l_n = 0 THEN
    l_n := NOONA_PAY_PKG.add_input(l_per, m(3), 'COMMISSION', NULL, 2800);
    l_n := NOONA_PAY_PKG.add_input(l_per, m(4), 'BONUS', NULL, 1500);
    l_n := NOONA_PAY_PKG.add_input(l_per, m(7), 'PENALTY', NULL, 150);
    payroll(l_m0, FALSE);
    say('رواتب ' || TO_CHAR(l_m0, 'YYYY-MM') || ': محسوبة بانتظار المراجعة والاعتماد (إجازة غير مدفوعة، غياب، إضافي، عمولة، مكافأة، جزاء، قسط سلفة)');
  ELSE
    say('رواتب ' || TO_CHAR(l_m0, 'YYYY-MM') || ' مرحلة سابقاً؛ لم تضف مدخلات للشهر الحالي');
  END IF;

  COMMIT;
  say('');
  say('تم تحميل بيانات الموارد البشرية والرواتب التجريبية. افتح «الموارد البشرية والرواتب».');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
