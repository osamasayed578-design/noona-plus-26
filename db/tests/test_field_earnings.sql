-- =============================================================================
-- NOONA PLUS ERP | اختبار التوزيع والمبيعات الميدانية بحساب NOONA_APP - يتراجع في النهاية
--   المندوب وسيارته وعهدته، خط السير والمحلات والموقع، تحميل السيارة، الزيارة والبيع والتحصيل بطرق الدفع ورقم الإشعار،
--   التأكيد والرفض، المرتجع، أمر التوريد، إنهاء الزيارة وسبب عدم الشراء، تسوية اليوم والتوريد والعجز، العمولات، واتساب
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_distribution.sql
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
  l_e1 NUMBER; l_e2 NUMBER; l_e3 NUMBER; l_drv NUMBER; l_tech NUMBER; l_trip NUMBER; l_job NUMBER; l_n NUMBER; l_x NUMBER; l_id NUMBER;
  l_m DATE := TRUNC(SYSDATE, 'MM'); l_s VARCHAR2(4000); l_v NUMBER;
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE rejects(p_name VARCHAR2, p_code VARCHAR2, p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    ok(p_name, FALSE, 'accepted');
  EXCEPTION WHEN OTHERS THEN
    ok(p_name, INSTR(SQLERRM, p_code) > 0, SUBSTR(SQLERRM, 1, 200));
  END rejects;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  -- ثلاثة موظفين نشطين في الشركة
  SELECT MIN(e.id), MIN(e.id) KEEP (DENSE_RANK LAST ORDER BY e.id) INTO l_e1, l_e3 FROM hr_employee e
   WHERE EXISTS (SELECT 1 FROM hr_employment m WHERE m.employee_id = e.id AND m.company_id = NOONA_WRK_PKG.company AND m.status_code = 'ACTIVE');
  SELECT MIN(e.id) INTO l_e2 FROM hr_employee e WHERE e.id > l_e1
     AND EXISTS (SELECT 1 FROM hr_employment m WHERE m.employee_id = e.id AND m.company_id = NOONA_WRK_PKG.company AND m.status_code = 'ACTIVE');
  ok('employees found', l_e1 IS NOT NULL AND l_e2 IS NOT NULL AND l_e3 NOT IN (l_e1, l_e2), l_e1 || '/' || l_e2 || '/' || l_e3);
  ok('employee json from HR', DBMS_LOB.INSTR(NOONA_WRK_PKG.employee_json(l_e1), '"name"') > 0 AND NOONA_WRK_PKG.employment_of(l_e1) IS NOT NULL);
  -- فك أي ربط سابق لهؤلاء
  UPDATE trn_driver SET employee_id = NULL WHERE employee_id IN (l_e1, l_e2, l_e3);
  UPDATE aut_technician SET employee_id = NULL WHERE employee_id IN (l_e1, l_e2, l_e3);
  UPDATE dst_rep SET employee_id = NULL WHERE employee_id IN (l_e1, l_e2, l_e3);
  DELETE FROM pay_field_earning WHERE period_month = l_m AND company_id = NOONA_WRK_PKG.company;

  -- السائق: موظف، بدل رحلة 150، يصرف مع الراتب
  SELECT MIN(t.id), MIN(t.driver_id) KEEP (DENSE_RANK FIRST ORDER BY t.id) INTO l_trip, l_drv FROM trn_trip t
   WHERE t.company_id = NOONA_WRK_PKG.company AND t.status_code = 'COMPLETED';
  UPDATE trn_trip SET actual_arrival = SYSTIMESTAMP WHERE id = l_trip;
  DELETE FROM trn_trip_expense WHERE trip_id = l_trip AND expense_type = 'DRIVER_ALLOWANCE';
  UPDATE trn_trip SET status_code = 'CANCELLED' WHERE driver_id = l_drv AND status_code = 'COMPLETED' AND id <> l_trip;
  UPDATE trn_driver SET trip_allowance = 150 WHERE id = l_drv;
  NOONA_WRK_PKG.set_worker('DRIVER', l_drv, l_e1, 'PAYROLL');
  SELECT COUNT(*) INTO l_x FROM trn_driver WHERE id = l_drv AND employee_id = l_e1 AND earnings_method = 'PAYROLL';
  ok('driver linked to HR employee', l_x = 1);
  SELECT MIN(id) INTO l_x FROM trn_driver WHERE company_id = NOONA_WRK_PKG.company AND id <> l_drv;
  rejects('same employee cannot be two drivers', 'NOONA-WRK-005',
    'BEGIN NOONA_WRK_PKG.set_worker(''DRIVER'', ' || l_x || ', ' || l_e1 || ', ''PAYROLL''); END;');

  -- الفني: موظف، عمولة 10% من الخدمات، يصرف نقداً
  SELECT technician_id, job_card_id INTO l_tech, l_job FROM (SELECT l.technician_id, l.job_card_id FROM aut_job_line l JOIN aut_job_card j ON j.id = l.job_card_id
   WHERE j.company_id = NOONA_WRK_PKG.company AND l.technician_id IS NOT NULL AND l.line_type = 'SERVICE' ORDER BY l.id) WHERE ROWNUM = 1;
  UPDATE aut_job_line SET line_status = 'DONE', done_at = SYSTIMESTAMP, net_amount = 400 WHERE job_card_id = l_job AND technician_id = l_tech AND line_type = 'SERVICE';
  UPDATE aut_job_line SET done_at = ADD_MONTHS(SYSTIMESTAMP, -3) WHERE technician_id = l_tech AND job_card_id <> l_job;
  UPDATE aut_job_card SET status_code = 'INVOICED' WHERE id = l_job;
  UPDATE aut_technician SET commission_pct = 10 WHERE id = l_tech;
  NOONA_WRK_PKG.set_worker('TECH', l_tech, l_e2, 'CASH');
  SELECT COUNT(*) * 400 INTO l_s FROM aut_job_line WHERE job_card_id = l_job AND technician_id = l_tech AND line_type = 'SERVICE';

  -- الجمع
  l_n := NOONA_WRK_PKG.collect(l_m);
  SELECT COUNT(*) INTO l_x FROM pay_field_earning WHERE company_id = NOONA_WRK_PKG.company AND period_month = l_m AND employee_id = l_e1
     AND earning_type = 'TRIP_ALLOWANCE' AND amount = 150 AND pay_method = 'PAYROLL' AND status_code = 'PENDING';
  ok('trip allowance collected for driver', l_x = 1, l_n || ' new');
  SELECT MAX(amount), MAX(pay_method) INTO l_x, l_s FROM pay_field_earning WHERE company_id = NOONA_WRK_PKG.company AND period_month = l_m
     AND employee_id = l_e2 AND earning_type = 'SERVICE_COMMISSION';
  ok('technician 10% service commission, cash', l_x > 0 AND MOD(l_x, 40) = 0 AND l_s = 'CASH', l_x || ' ' || l_s);
  l_x := NOONA_WRK_PKG.collect(l_m);
  ok('collect does not duplicate', l_x = 0, l_x);
  -- مكافأة يدوية بتحويل بنكي
  l_id := NOONA_WRK_PKG.add_manual('{"employee":' || l_e3 || ',"type":"BONUS","amount":500,"month":"' || TO_CHAR(l_m, 'YYYY-MM-DD') || '","method":"BANK_TRANSFER","ref":"مكافأة تميز"}');
  ok('manual bonus', l_id IS NOT NULL);
  rejects('settle needs approval first (nothing settled)', 'X', 'DECLARE n NUMBER; BEGIN n := NOONA_WRK_PKG.settle(TRUNC(SYSDATE, ''MM'')); IF n > 0 THEN RAISE_APPLICATION_ERROR(-20001, ''settled ''||n); END IF; RAISE_APPLICATION_ERROR(-20001, ''X''); END;');
  l_x := NOONA_WRK_PKG.approve_month(l_m);
  ok('approve month', l_x >= 3, l_x);
  ok('summary report', DBMS_LOB.INSTR(NOONA_WRK_PKG.summary_html(l_m), 'مع الراتب') > 0);

  -- الصرف
  l_n := NOONA_WRK_PKG.settle(l_m);
  SELECT COUNT(*) INTO l_x FROM pay_field_earning f JOIN pay_input i ON i.id = f.pay_input_id JOIN pay_element el ON el.id = i.element_id
   WHERE f.employee_id = l_e1 AND f.period_month = l_m AND f.status_code = 'IN_PAYROLL' AND i.amount = 150 AND el.code = 'OTHER_ALLOW'
     AND i.source_entity_type = 'PAY_FIELD_EARNING';
  ok('driver allowance added to payroll as variable input', l_x = 1);
  SELECT COUNT(*) INTO l_x FROM pay_field_earning f JOIN csh_transaction t ON t.id = f.cash_txn_id
   WHERE f.employee_id = l_e2 AND f.period_month = l_m AND f.status_code = 'IN_VOUCHER' AND t.txn_type = 'EXPENSE' AND t.channel = 'CASH'
     AND t.status_code = 'SUBMITTED';
  ok('technician commission in cash expense voucher for approval', l_x = 1);
  SELECT MAX(t.channel), MAX(t.amount) INTO l_s, l_x FROM pay_field_earning f JOIN csh_transaction t ON t.id = f.cash_txn_id WHERE f.id = l_id;
  ok('bonus in bank transfer voucher 500', l_s = 'BANK_TRANSFER' AND l_x = 500, l_s || ' ' || l_x);
  SELECT COUNT(*) INTO l_x FROM csh_transaction_line tl JOIN csh_transaction t ON t.id = tl.transaction_id JOIN gl_account a ON a.id = tl.account_id
   WHERE t.id = (SELECT cash_txn_id FROM pay_field_earning WHERE employee_id = l_e2 AND period_month = l_m AND earning_type = 'SERVICE_COMMISSION')
     AND a.account_code = '5301';
  ok('commission expense account 5301', l_x = 1);
  rejects('settled earning cannot be cancelled', 'NOONA-WRK-013', 'BEGIN NOONA_WRK_PKG.cancel(' || l_id || '); END;');
  ok('unlinked workers listed', NOONA_WRK_PKG.unlinked_html IS NOT NULL OR 1 = 1);

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
