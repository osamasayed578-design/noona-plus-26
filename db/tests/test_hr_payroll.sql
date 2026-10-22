-- =============================================================================
-- NOONA PLUS ERP | اختبار الموارد البشرية والرواتب بحساب NOONA_APP - يتراجع عن كل التغييرات في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_hr_payroll.sql
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
  l_n    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_per  NUMBER;
  l_p0   DATE;
  l_p1   DATE;
  l_pd   NUMBER;
  l_a    NUMBER;   -- علاقة توظيف سعودي
  l_b    NUMBER;   -- غير سعودي يبدأ منتصف الشهر
  l_c7   NUMBER;   -- قديم الخدمة (7 سنوات)
  l_ea   NUMBER;
  l_eb   NUMBER;
  l_lv   NUMBER;
  l_ot   NUMBER;
  l_loan NUMBER;
  l_run  NUMBER;
  l_ra   NUMBER;
  l_rb   NUMBER;
  l_file NUMBER;
  l_eos  NUMBER;
  l_frun NUMBER;
  l_bank NUMBER;
  l_dr   NUMBER;
  l_cr   NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION d(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION amt(p_re NUMBER, p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(rr.amount), 0) INTO l FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
     WHERE rr.run_employee_id = p_re AND el.code = p_code;
    RETURN l;
  END amt;
  FUNCTION emp(p_name VARCHAR2, p_nid VARCHAR2, p_nat VARCHAR2, p_hire DATE, p_basic NUMBER, p_house NUMBER, p_trans NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_HR_PKG.save_employee('{"name_ar":"' || p_name || '","national_id":"' || p_nid || '","nationality":"' || p_nat
      || '","gender":"M","hire_date":"' || d(p_hire) || '","job_title":"محاسب","iban":"SA0380000000608010167519","bank":null,'
      || '"salary":{"BASIC":' || p_basic || ',"HOUSING":' || p_house || ',"TRANSPORT":' || p_trans || '}}');
  END emp;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));

  -- التجهيز
  l_n := NOONA_PAY_PKG.quick_setup;
  ok('payroll ready after setup', NOONA_PAY_PKG.is_ready = 'Y');
  -- أول فترة من الشهر الحالي حتى نهاية السنة لم ترحل رواتبها (يبقى الاختبار قابلاً للتكرار)
  FOR k IN 0 .. 11 - (EXTRACT(MONTH FROM SYSDATE) - 1) LOOP
    l_per := NOONA_PAY_PKG.period_for(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), k));
    SELECT COUNT(*) INTO l_n FROM pay_run WHERE period_id = l_per AND run_type = 'REGULAR' AND status_code IN ('POSTED', 'PAID', 'CLOSED');
    EXIT WHEN l_n = 0;
  END LOOP;
  SELECT start_date, end_date INTO l_p0, l_p1 FROM pay_period WHERE id = l_per;
  l_pd := l_p1 - l_p0 + 1;
  ok('monthly period available', l_per IS NOT NULL AND l_p0 = TRUNC(l_p0, 'MM') AND l_n = 0);
  SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND status_code = 'ACTIVE';
  ok('company has a bank account for salaries', l_bank IS NOT NULL);
  -- لا تتعارض مع رواتب الفترة الحالية في البيانات القائمة
  DELETE FROM pay_run_result WHERE run_employee_id IN (SELECT re.id FROM pay_run_employee re JOIN pay_run r ON r.id = re.run_id
                                                         WHERE r.period_id = l_per AND r.status_code IN ('OPEN', 'CALCULATED', 'APPROVED'));
  DELETE FROM pay_run_employee WHERE run_id IN (SELECT id FROM pay_run WHERE period_id = l_per AND status_code IN ('OPEN', 'CALCULATED', 'APPROVED'));
  DELETE FROM pay_run WHERE period_id = l_per AND status_code IN ('OPEN', 'CALCULATED', 'APPROVED');

  -- ملف الموظف والتحقق
  BEGIN l_n := emp('خطأ', '2123456789', 'SA', l_p0, 5000, 0, 0); ok('saudi id must start with 1', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('saudi id must start with 1', 'NOONA-HR-011', SQLERRM); END;
  BEGIN l_n := NOONA_HR_PKG.save_employee('{"name_ar":"x","nationality":"SA","iban":"SA12","salary":{"BASIC":5000}}'); ok('iban validated', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('iban validated', 'NOONA-HR-013', SQLERRM); END;
  l_a := emp('عبدالله السعودي ' || l_sfx, '1' || LPAD(l_sfx, 9, '7'), 'SA', l_p0, 10000, 2500, 1000);
  ok('saudi employee hired', l_a IS NOT NULL);
  BEGIN l_n := emp('مكرر', '1' || LPAD(l_sfx, 9, '7'), 'SA', l_p0, 5000, 0, 0); ok('duplicate national id rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate national id rejected', 'NOONA-HR-015', SQLERRM); END;
  l_b := emp('راجيش المقيم ' || l_sfx, '2' || LPAD(l_sfx, 9, '8'), 'IN', l_p0 + 15, 6000, 1500, 500);
  l_c7 := emp('خالد القديم ' || l_sfx, '1' || LPAD(l_sfx, 9, '6'), 'SA', ADD_MONTHS(l_p1, -84), 5000, 1250, 500);
  SELECT employee_id INTO l_ea FROM hr_employment WHERE id = l_a;
  SELECT employee_id INTO l_eb FROM hr_employment WHERE id = l_b;
  SELECT employee_category INTO l_s FROM hr_employment WHERE id = l_b;
  ok('category from nationality', l_s = 'NON_SAUDI' AND NOONA_HR_PKG.category(l_a) = 'SAUDI', l_s);
  ok('salary structure stored', NOONA_PAY_PKG.monthly_wage(l_a, l_p1) = 13500 AND NOONA_PAY_PKG.eos_wage(l_a, l_p1) = 13500);
  SELECT COUNT(*) INTO l_n FROM hr_employee_action WHERE employment_id = l_a AND action_type = 'HIRE';
  ok('hire action recorded', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM hr_contract WHERE employment_id = l_a AND status_code = 'ACTIVE';
  ok('contract created', l_n = 1);

  -- مكافأة نهاية الخدمة (المادتان 84 و85)
  l_n := NOONA_PAY_PKG.eos_amount(l_c7, l_p1);
  ok('eos: half month for 5 years then full month', l_n BETWEEN 6750 * 4.5 AND 6750 * 4.5 + 100, l_n);
  ok('eos on resignation after 7 years = two thirds', ABS(NOONA_PAY_PKG.eos_amount(l_c7, l_p1, 'RESIGNATION') - ROUND(l_n * 2 / 3, 2)) < 0.02);
  ok('eos on resignation under 2 years = 0', NOONA_PAY_PKG.eos_amount(l_a, TRUNC(SYSDATE), 'RESIGNATION') = 0);

  -- الإجازات
  BEGIN l_n := NOONA_HR_PKG.request_leave('{"employee":' || l_ea || ',"type":"ANNUAL","start":"' || d(l_p0 + 20) || '","end":"' || d(l_p0 + 24) || '"}');
    ok('annual leave limited by accrued balance', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('annual leave limited by accrued balance', 'NOONA-HR-035', SQLERRM); END;
  NOONA_HR_PKG.adjust_leave(l_ea, 'ANNUAL', 10, 'رصيد مرحل من الشركة السابقة');
  l_lv := NOONA_HR_PKG.request_leave('{"employee":' || l_ea || ',"type":"ANNUAL","start":"' || d(l_p0 + 20) || '","end":"' || d(l_p0 + 24) || '"}');
  NOONA_HR_PKG.approve_leave(l_lv);
  SELECT taken INTO l_n FROM hr_leave_balance WHERE employee_id = l_ea AND balance_year = EXTRACT(YEAR FROM l_p0)
     AND leave_type_id = NOONA_HR_PKG.leave_type_id('ANNUAL');
  ok('approved annual leave reduces balance', l_n = 5, l_n);
  BEGIN l_n := NOONA_HR_PKG.request_leave('{"employee":' || l_ea || ',"type":"SICK","start":"' || d(l_p0 + 22) || '","end":"' || d(l_p0 + 23) || '"}');
    ok('overlapping leave rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('overlapping leave rejected', 'NOONA-HR-034', SQLERRM); END;
  l_lv := NOONA_HR_PKG.request_leave('{"employee":' || l_ea || ',"type":"UNPAID","start":"' || d(l_p0 + 5) || '","end":"' || d(l_p0 + 6) || '"}');
  NOONA_HR_PKG.approve_leave(l_lv);
  ok('unpaid leave days counted', NOONA_HR_PKG.unpaid_leave_days(l_ea, l_p0, l_p1) = 2);

  -- الحضور والإضافي
  l_n := NOONA_HR_PKG.mark_absent(l_eb, l_p0 + 16);
  l_n := NOONA_HR_PKG.record_attendance(l_eb, l_p0 + 17, '09:00', '17:00');
  SELECT late_minutes INTO l_n FROM hr_attendance WHERE id = l_n;
  ok('late minutes after grace', l_n = 60, l_n);
  l_ot := NOONA_HR_PKG.request_overtime(l_ea, l_p0 + 10, 10, 'إقفال نهاية الشهر');
  NOONA_HR_PKG.approve_overtime(l_ot);
  ok('approved overtime hours', NOONA_HR_PKG.overtime_hours(l_ea, l_p0, l_p1) = 10);

  -- المدخلات والسلف
  l_n := NOONA_PAY_PKG.add_input(l_per, l_a, 'BONUS', NULL, 1000);
  l_n := NOONA_PAY_PKG.add_input(l_per, l_b, 'PENALTY', NULL, 200);
  BEGIN l_n := NOONA_PAY_PKG.create_loan(l_a, 'SALARY_ADVANCE', 30000, 2, l_per); ok('installment capped at half wage', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('installment capped at half wage', 'NOONA-PAY-042', SQLERRM); END;
  l_loan := NOONA_PAY_PKG.create_loan(l_a, 'SALARY_ADVANCE', 3000, 3, l_per);
  SELECT COUNT(*) INTO l_n FROM pay_loan_installment WHERE loan_id = l_loan;
  ok('loan installments scheduled', l_n = 3);
  l_n := NOONA_PAY_PKG.disburse_loan(l_loan, l_bank);
  ok('loan disbursed and posted', l_n IS NOT NULL AND NOONA_PAY_PKG.loan_outstanding(l_a) = 3000);

  -- التشغيل
  l_run := NOONA_PAY_PKG.create_run(l_per);
  BEGIN l_n := NOONA_PAY_PKG.create_run(l_per); ok('one regular run per period', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('one regular run per period', 'NOONA-PAY-021', SQLERRM); END;
  l_n := NOONA_PAY_PKG.calculate(l_run);
  ok('run calculated', l_n >= 3, l_n);
  SELECT id INTO l_ra FROM pay_run_employee WHERE run_id = l_run AND employment_id = l_a;
  SELECT id INTO l_rb FROM pay_run_employee WHERE run_id = l_run AND employment_id = l_b;
  ok('full month basic', amt(l_ra, 'BASIC') = 10000 AND amt(l_ra, 'HOUSING') = 2500, amt(l_ra, 'BASIC'));
  ok('unpaid leave deducted at daily wage', amt(l_ra, 'ABSENCE') = 900, amt(l_ra, 'ABSENCE'));
  ok('overtime: hourly wage + 50% of basic hourly', amt(l_ra, 'OVERTIME') = ROUND(10 * (13500 / 240 + 0.5 * 10000 / 240), 2), amt(l_ra, 'OVERTIME'));
  ok('GOSI saudi employee 9.75% of basic+housing', amt(l_ra, 'GOSI_EE') = 1218.75, amt(l_ra, 'GOSI_EE'));
  ok('GOSI saudi employer 11.75%', amt(l_ra, 'GOSI_ER') = 1468.75, amt(l_ra, 'GOSI_ER'));
  ok('loan installment deducted', amt(l_ra, 'LOAN') = 1000, amt(l_ra, 'LOAN'));
  SELECT net_amount INTO l_n FROM pay_run_employee WHERE id = l_ra;
  ok('net = gross - deductions', l_n = ROUND(13500 + 1000 + ROUND(10 * (13500 / 240 + 0.5 * 10000 / 240), 2) - 900 - 1218.75 - 1000, 2), l_n);
  ok('mid-month joiner prorated', amt(l_rb, 'BASIC') = ROUND(6000 * (l_pd - 15) / l_pd, 2), amt(l_rb, 'BASIC'));
  ok('non-saudi: no employee GOSI, employer 2%', amt(l_rb, 'GOSI_EE') = 0 AND amt(l_rb, 'GOSI_ER') = ROUND(7500 * ROUND(30 * (l_pd - 15) / l_pd, 2) / 30 * 0.02, 2),
     amt(l_rb, 'GOSI_ER'));
  ok('absence day deducted', amt(l_rb, 'ABSENCE') = ROUND(8000 / 30, 2), amt(l_rb, 'ABSENCE'));
  ok('penalty input applied', amt(l_rb, 'PENALTY') = 200);
  l_c := NOONA_PAY_PKG.run_register_html(l_run);
  ok('payroll register lists employees', DBMS_LOB.INSTR(l_c, 'عبدالله السعودي') > 0);
  NOONA_PAY_PKG.approve_run(l_run);
  l_n := NOONA_PAY_PKG.post_run(l_run);
  ok('run posted to GL', l_n IS NOT NULL);
  SELECT SUM(l.debit_amount), SUM(l.credit_amount) INTO l_dr, l_cr FROM gl_journal_line l WHERE l.journal_id = l_n;
  ok('payroll journal balanced', l_dr = l_cr AND l_dr > 0, l_dr || '/' || l_cr);
  SELECT NVL(SUM(l.credit_amount), 0) INTO l_dr FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id
   WHERE l.journal_id = l_n AND a.account_code = '2108';
  SELECT NVL(SUM(rr.amount), 0) INTO l_cr FROM pay_run_result rr JOIN pay_run_employee re ON re.id = rr.run_employee_id
    JOIN pay_element el ON el.id = rr.element_id WHERE re.run_id = l_run AND el.code IN ('GOSI_EE', 'GOSI_ER');
  ok('GOSI payable = employee + employer shares', l_dr = l_cr, l_dr || '/' || l_cr);
  SELECT COUNT(*) INTO l_n FROM pay_accrual WHERE employment_id = l_a AND period_id = l_per;
  ok('EOS and leave accruals recorded', l_n = 2, l_n);
  ok('loan outstanding after deduction', NOONA_PAY_PKG.loan_outstanding(l_a) = 2000, NOONA_PAY_PKG.loan_outstanding(l_a));
  l_file := NOONA_PAY_PKG.pay_out(l_run, l_bank);
  SELECT status_code INTO l_s FROM pay_run WHERE id = l_run;
  ok('salaries paid', l_s = 'PAID', l_s);
  l_c := NOONA_PAY_PKG.bank_file_csv(l_file);
  ok('WPS file has IBAN and net', DBMS_LOB.INSTR(l_c, 'SA0380000000608010167519') > 0);
  l_c := NOONA_PAY_PKG.payslip_html(l_ra);
  ok('payslip shows earnings and net', DBMS_LOB.INSTR(l_c, 'الراتب الأساسي') > 0 AND DBMS_LOB.INSTR(l_c, 'العمل الإضافي') > 0);
  BEGIN l_n := NOONA_PAY_PKG.add_input(l_per, l_a, 'BONUS', NULL, 50); ok('no inputs after posting', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no inputs after posting', 'NOONA-PAY-013', SQLERRM); END;

  -- الحركات الوظيفية
  BEGIN l_n := NOONA_HR_PKG.change_salary(l_a, l_p0, 11000, 2750, 1000, 0, 'ترقية'); ok('no salary change inside posted period', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no salary change inside posted period', 'NOONA-HR-023', SQLERRM); END;
  l_n := NOONA_HR_PKG.change_salary(l_a, l_p1 + 1, 11000, 2750, 1000, 0, 'ترقية سنوية');
  ok('salary change effective next period', NOONA_PAY_PKG.element_amount(l_a, 'BASIC', l_p1) = 10000
     AND NOONA_PAY_PKG.element_amount(l_a, 'BASIC', l_p1 + 1) = 11000);
  l_n := NOONA_HR_PKG.transfer(l_a, TRUNC(SYSDATE), NULL, NULL, NULL, 'محاسب أول', NULL, 'ترقية');
  SELECT job_title INTO l_s FROM hr_employment WHERE id = l_a;
  ok('transfer updates job title', l_s = 'محاسب أول', l_s);

  -- مخالصة نهاية الخدمة
  l_eos := NOONA_PAY_PKG.calc_settlement(l_c7, l_p1, 'END_OF_CONTRACT', 'انتهاء العقد');
  SELECT eos_amount INTO l_n FROM hr_end_of_service WHERE id = l_eos;
  ok('settlement EOS calculated', l_n > 30000, l_n);
  l_frun := NOONA_PAY_PKG.approve_settlement(l_eos);
  ok('settlement creates final run', l_frun IS NOT NULL);
  SELECT COUNT(*) INTO l_n FROM pay_run_employee re JOIN pay_run_result rr ON rr.run_employee_id = re.id JOIN pay_element el ON el.id = rr.element_id
   WHERE re.run_id = l_frun AND el.code = 'EOS';
  ok('final run includes EOS award', l_n = 1);
  NOONA_PAY_PKG.approve_run(l_frun);
  l_n := NOONA_PAY_PKG.post_run(l_frun);
  SELECT status_code INTO l_s FROM hr_employment WHERE id = l_c7;
  ok('employment terminated on posting settlement', l_s = 'TERMINATED', l_s);
  ok('reports render', DBMS_LOB.GETLENGTH(NOONA_PAY_PKG.gosi_report_html(l_run)) > 100 AND DBMS_LOB.GETLENGTH(NOONA_PAY_PKG.eos_liability_html) > 100
     AND DBMS_LOB.GETLENGTH(NOONA_HR_PKG.hr_summary) > 100 AND DBMS_LOB.GETLENGTH(NOONA_HR_PKG.leave_balances_report) > 100);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
