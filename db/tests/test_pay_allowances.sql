-- =============================================================================
-- NOONA PLUS ERP | اختبار البدلات المرنة (ثابت/نسبة/سياسة/مستثنى، الشركة/الدولة) بحساب NOONA_APP - يتراجع في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_pay_allowances.sql
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
  l_meal VARCHAR2(30) := 'MEAL_' || l_sfx;
  l_n    NUMBER;
  l_r    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_per  NUMBER;
  l_p0   DATE;
  l_p1   DATE;
  l_pd   NUMBER;
  l_a    NUMBER;
  l_b    NUMBER;
  l_run  NUMBER;
  l_re   NUMBER;
  l_exp  NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION d(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION ea(p_emp NUMBER, p_code VARCHAR2) RETURN NUMBER IS BEGIN RETURN NOONA_PAY_PKG.element_amount(p_emp, p_code, l_p1); END;
  FUNCTION amt(p_re NUMBER, p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(rr.amount), 0) INTO l FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
     WHERE rr.run_employee_id = p_re AND el.code = p_code;
    RETURN l;
  END amt;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_PAY_PKG.quick_setup;
  FOR k IN 0 .. 11 - (EXTRACT(MONTH FROM SYSDATE) - 1) LOOP
    l_per := NOONA_PAY_PKG.period_for(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), k));
    SELECT COUNT(*) INTO l_n FROM pay_run WHERE period_id = l_per AND run_type = 'REGULAR' AND status_code IN ('POSTED', 'PAID', 'CLOSED');
    EXIT WHEN l_n = 0;
  END LOOP;
  SELECT start_date, end_date INTO l_p0, l_p1 FROM pay_period WHERE id = l_per;
  l_pd := l_p1 - l_p0 + 1;
  DELETE FROM pay_run_result WHERE run_employee_id IN (SELECT re.id FROM pay_run_employee re JOIN pay_run r ON r.id = re.run_id
                                                         WHERE r.period_id = l_per AND r.status_code IN ('OPEN', 'CALCULATED', 'APPROVED'));
  DELETE FROM pay_run_employee WHERE run_id IN (SELECT id FROM pay_run WHERE period_id = l_per AND status_code IN ('OPEN', 'CALCULATED', 'APPROVED'));
  DELETE FROM pay_run WHERE period_id = l_per AND status_code IN ('OPEN', 'CALCULATED', 'APPROVED');
  -- قواعد بدلات قائمة في بيانات المؤسسة لا تؤثر على الاختبار (يتراجع في النهاية)
  DELETE FROM pay_element_rule WHERE tenant_id IS NOT NULL AND formula_type IN ('FIXED', 'PCT_OF_ELEMENT');
  ok('company country is SA', NOONA_HR_PKG.company_country = 'SA', NOONA_HR_PKG.company_country);

  -- التعيين: السكن 25% من الأساسي، والمواصلات حسب سياسة الشركة
  l_a := NOONA_HR_PKG.save_employee('{"name_ar":"سلمان النسبة ' || l_sfx || '","national_id":"1' || LPAD(l_sfx, 9, '5')
    || '","nationality":"SA","gender":"M","hire_date":"' || d(l_p0) || '","job_title":"مهندس","iban":"SA0380000000608010167519",'
    || '"salary":{"BASIC":10000,"HOUSING":{"method":"PERCENT","value":25},"TRANSPORT":{"method":"POLICY"}}}');
  l_b := NOONA_HR_PKG.save_employee('{"name_ar":"أحمد الثابت ' || l_sfx || '","national_id":"1' || LPAD(l_sfx, 9, '4')
    || '","nationality":"SA","gender":"M","hire_date":"' || d(l_p0) || '","job_title":"محاسب","iban":"SA0380000000608010167519",'
    || '"salary":{"BASIC":8000,"HOUSING":2000}}');
  ok('housing = 25% of basic', ea(l_a, 'HOUSING') = 2500, ea(l_a, 'HOUSING'));
  ok('fixed housing stays fixed', ea(l_b, 'HOUSING') = 2000);
  ok('policy without a rule = 0', ea(l_a, 'TRANSPORT') = 0);
  SELECT calc_method || '/' || percentage || '/' || basis_code INTO l_s FROM pay_employee_element x JOIN pay_element e ON e.id = x.element_id
   WHERE x.employment_id = l_a AND e.code = 'HOUSING';
  ok('method stored on employee element', l_s = 'PERCENT/25/BASIC', l_s);
  BEGIN l_n := NOONA_HR_PKG.set_element(l_a, 'BASIC', 'PERCENT', 10, NULL, l_p0); ok('basic must be fixed', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('basic must be fixed', 'NOONA-HR-034', SQLERRM); END;
  BEGIN l_n := NOONA_HR_PKG.set_element(l_a, 'HOUSING', 'PERCENT', 10, 'HOUSING', l_p0); ok('no percentage of itself', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no percentage of itself', 'NOONA-HR-033', SQLERRM); END;

  -- سياسة الدولة ثم الشركة
  l_r := NOONA_PAY_PKG.save_allowance_rule('TRANSPORT', 'COUNTRY', 'SA', 'PERCENT', 10, 'BASIC', p_auto => 'N', p_from => l_p0);
  ok('country rule: transport 10% of basic', ea(l_a, 'TRANSPORT') = 1000, ea(l_a, 'TRANSPORT'));
  ok('non-auto rule does not touch fixed employees', ea(l_b, 'TRANSPORT') = 0);
  ok('rule text readable', INSTR(NOONA_PAY_PKG.rule_text(l_r), '10% من') = 1, NOONA_PAY_PKG.rule_text(l_r));
  l_r := NOONA_PAY_PKG.save_allowance_rule('TRANSPORT', 'COMPANY', NULL, 'FIXED', 800, p_auto => 'N', p_from => l_p0);
  ok('company rule overrides country rule', ea(l_a, 'TRANSPORT') = 800, ea(l_a, 'TRANSPORT'));
  l_r := NOONA_PAY_PKG.save_allowance_rule('TRANSPORT', 'COMPANY', NULL, 'PERCENT', 20, 'BASIC', p_max => 1500, p_auto => 'N', p_from => l_p0);
  ok('new company rule replaces the old one, max applied', ea(l_a, 'TRANSPORT') = 1500, ea(l_a, 'TRANSPORT'));
  SELECT COUNT(*) INTO l_n FROM pay_element_rule r JOIN pay_element e ON e.id = r.element_id
   WHERE e.code = 'TRANSPORT' AND r.company_id IS NOT NULL AND r.status_code = 'ACTIVE' AND r.effective_to IS NULL;
  ok('one open company rule per element', l_n = 1, l_n);

  -- عنصر خاص بالمؤسسة وسياسة تلقائية
  l_n := NOONA_PAY_PKG.save_element(NULL, l_meal, 'بدل وجبة', 'EARNING', p_eos => 'N');
  ok('tenant element created', l_n IS NOT NULL);
  BEGIN l_n := NOONA_PAY_PKG.save_element(NULL, 'bad code!', 'x', 'EARNING'); ok('element code validated', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('element code validated', 'NOONA-PAY-060', SQLERRM); END;
  l_r := NOONA_PAY_PKG.save_allowance_rule(l_meal, 'COUNTRY', 'EG', 'FIXED', 777, p_from => l_p0);
  ok('rule for another country is ignored', ea(l_a, l_meal) = 0 AND ea(l_b, l_meal) = 0);
  l_r := NOONA_PAY_PKG.save_allowance_rule(l_meal, 'COMPANY', NULL, 'FIXED', 300, p_from => l_p0);
  ok('auto company allowance applies to every employee', ea(l_a, l_meal) = 300 AND ea(l_b, l_meal) = 300);
  l_n := NOONA_HR_PKG.set_element(l_b, l_meal, 'EXCLUDED', NULL, NULL, l_p0, 'لا يستحق');
  ok('excluded employee gets nothing', ea(l_b, l_meal) = 0 AND ea(l_a, l_meal) = 300);
  ok('monthly wage includes all allowances', NOONA_PAY_PKG.monthly_wage(l_a, l_p1) = 10000 + 2500 + 1500 + 300,
     NOONA_PAY_PKG.monthly_wage(l_a, l_p1));

  -- تغيير الأساسي يغير النسب تلقائياً
  l_n := NOONA_HR_PKG.set_element(l_a, 'BASIC', 'FIXED', 12000, NULL, l_p0, 'ترقية');
  ok('percentage follows new basic', ea(l_a, 'HOUSING') = 3000 AND ea(l_a, 'TRANSPORT') = 1500, ea(l_a, 'HOUSING'));
  SELECT basic_salary INTO l_n FROM hr_contract WHERE employment_id = l_a AND status_code = 'ACTIVE';
  ok('contract basic updated', l_n = 12000);
  ok('salary structure html', DBMS_LOB.INSTR(NOONA_PAY_PKG.structure_html(l_a, l_p1), '25% من') > 0);

  -- تغيير منتصف الفترة: السكن مبلغ ثابت من اليوم 16
  l_n := NOONA_HR_PKG.set_element(l_a, 'HOUSING', 'FIXED', 4000, NULL, l_p0 + 15, 'تعديل سكن');

  -- مسير الرواتب
  l_run := NOONA_PAY_PKG.create_run(l_per);
  l_n := NOONA_PAY_PKG.calculate(l_run);
  SELECT id INTO l_re FROM pay_run_employee WHERE run_id = l_run AND employment_id = l_a;
  l_exp := ROUND(3000 * 15 / l_pd, 2) + ROUND(4000 * (l_pd - 15) / l_pd, 2);
  ok('housing split by effective date in run', ABS(amt(l_re, 'HOUSING') - l_exp) < 0.02, amt(l_re, 'HOUSING') || ' vs ' || l_exp);
  ok('percentage transport in run', amt(l_re, 'TRANSPORT') = 1500, amt(l_re, 'TRANSPORT'));
  ok('auto allowance in run', amt(l_re, l_meal) = 300);
  SELECT COUNT(*) INTO l_n FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
   WHERE rr.run_employee_id = l_re AND el.code = 'TRANSPORT' AND rr.source_info LIKE '%POLICY%';
  ok('run line records the method', l_n = 1);
  SELECT id INTO l_re FROM pay_run_employee WHERE run_id = l_run AND employment_id = l_b;
  ok('excluded allowance not in run', amt(l_re, l_meal) = 0 AND amt(l_re, 'HOUSING') = 2000);
  -- التأمينات على الأساسي + السكن (القاعدة) وللشركات في السعودية
  ok('GOSI base from rule', amt(l_re, 'GOSI_EE') = ROUND(10000 * 9.75 / 100, 2), amt(l_re, 'GOSI_EE'));
  SELECT COUNT(*) INTO l_n FROM pay_element_rule r JOIN pay_element e ON e.id = r.element_id
   WHERE e.code IN ('GOSI_EE', 'GOSI_ER') AND r.tenant_id IS NULL AND NVL(r.country_code, '-') <> 'SA';
  ok('saudi GOSI rules bound to SA', l_n = 0, l_n);

  -- إنهاء قاعدة
  SELECT MAX(id) INTO l_r FROM pay_element_rule r WHERE r.company_id IS NOT NULL AND r.effective_to IS NULL
     AND r.element_id = (SELECT id FROM pay_element WHERE code = l_meal);
  NOONA_PAY_PKG.end_rule(l_r, l_p1);
  ok('ended rule stops after last day', NOONA_PAY_PKG.element_amount(l_a, l_meal, l_p1 + 1) = 0 AND ea(l_a, l_meal) = 300);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
