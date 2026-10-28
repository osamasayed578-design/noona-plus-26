-- =============================================================================
-- NOONA PLUS ERP | اختبار النقدية والمحرك المحاسبي (NOONA_CSH_PKG / NOONA_ACE_PKG) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_cash.sql
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
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3');
  l_led  NUMBER;
  l_box  NUMBER;
  l_box2 NUMBER;
  l_bank NUMBER;
  l_bid  NUMBER;
  l_rv   NUMBER;
  l_pv   NUMBER;
  l_ev   NUMBER;
  l_cc   NUMBER;
  l_j    NUMBER;
  l_rev  NUMBER;
  l_mem  NUMBER;
  l_role NUMBER;
  l_n    NUMBER;
  l_bal0 NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_user VARCHAR2(100);
  l_date DATE := TRUNC(SYSDATE);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
BEGIN
  login('ADMIN');
  -- قواعد الأرشفة (المرجع الورقي) لها اختبارها الخاص test_dms؛ تعطل هنا داخل المعاملة
  UPDATE dms_archive_rule SET is_active = 'N';
  l_led := NOONA_GL_PKG.quick_setup;
  l_box := NOONA_CSH_PKG.quick_setup;
  l_box2 := NOONA_CSH_PKG.quick_setup;
  ok('cash setup creates main box (idempotent)', l_box IS NOT NULL AND l_box = l_box2);
  SELECT COUNT(*) INTO l_n FROM ref_doc_sequence
   WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND doc_type_code IN ('CSH_RECEIPT', 'CSH_PAYMENT', 'CSH_EXPENSE');
  ok('voucher sequences created', l_n >= 3, l_n);
  l_box := NOONA_CSH_PKG.create_cash_box('BX' || l_sfx, 'صندوق اختبار');
  l_bal0 := NOONA_CSH_PKG.balance(l_box, NULL);
  ok('new box has zero balance', l_bal0 = 0, l_bal0);
  BEGIN l_n := NOONA_CSH_PKG.create_cash_box('BY' || l_sfx, 'صندوق خطأ', '5202'); ok('box needs a cash account', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('box needs a cash account', 'NOONA-CSH-010', SQLERRM); END;

  SELECT MIN(id) INTO l_bid FROM ref_bank WHERE code = 'SA-RJHI';
  ok('local banks seeded', l_bid IS NOT NULL);
  BEGIN l_n := NOONA_CSH_PKG.create_bank_account('BK' || l_sfx, 'حساب خطأ', l_bid, '123456789', 'XX'); ok('invalid IBAN blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid IBAN blocked', 'NOONA-CSH-015', SQLERRM); END;
  l_bank := NOONA_CSH_PKG.create_bank_account('BK' || l_sfx, 'الحساب الجاري', l_bid, '0108 0000 1234 5678',
                                              'SA03 8000 0000 6080 1016 7519', '1102', 10000);
  SELECT account_no_masked || '|' || iban_masked INTO l_s FROM csh_bank_account WHERE id = l_bank;
  ok('bank numbers stored masked', l_s = '****5678|SA03****7519', l_s);

  -- معتمد ثان (فصل المهام)
  l_user := 'CSA' || l_sfx;
  l_mem := NOONA_SEC_ADMIN_PKG.create_user(l_user, 'أمين صندوق معتمد', LOWER(l_user) || '@x.local',
                                           TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')));
  l_role := NOONA_SEC_ADMIN_PKG.create_role('CSR' || l_sfx, 'معتمد سندات');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,CREATE,UPDATE,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'اختبار');

  -- قواعد السطور
  BEGIN l_n := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', l_date, l_box, NULL, NULL, 'عميل', 'قبض', NULL, '[]');
        ok('voucher needs lines', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('voucher needs lines', 'NOONA-CSH-028', SQLERRM); END;
  BEGIN l_n := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', l_date, l_box, l_bank, NULL, 'عميل', 'قبض', NULL, '[{"a":"3101","m":5}]');
        ok('box or bank (one only)', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('box or bank (one only)', 'NOONA-CSH-024', SQLERRM); END;
  BEGIN l_n := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', l_date, l_box, NULL, NULL, 'عميل', 'قبض', NULL, '[{"a":"1103","m":5}]');
        ok('control account blocked in voucher', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('control account blocked in voucher', 'NOONA-GL-053', SQLERRM); END;
  BEGIN l_n := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', l_date, l_box, NULL, NULL, 'عميل', 'قبض', NULL, '[{"a":"1101","m":5}]');
        ok('own cash account blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('own cash account blocked', 'NOONA-CSH-029', SQLERRM); END;
  BEGIN l_n := NOONA_CSH_PKG.save_voucher(NULL, 'EXPENSE', l_date, l_box, NULL, NULL, 'مورد', 'مصروف', NULL, '[{"a":"4201","m":5}]');
        ok('expense voucher accepts expense accounts only', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('expense voucher accepts expense accounts only', 'NOONA-CSH-026', SQLERRM); END;
  BEGIN l_n := NOONA_CSH_PKG.save_voucher(NULL, 'PAYMENT', l_date, l_box, NULL, NULL, 'مورد', 'دفعة', NULL, '[{"a":"5202","m":-5}]');
        ok('negative line amount blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('negative line amount blocked', 'NOONA-CSH-027', SQLERRM); END;

  -- سند قبض: رأس وتفاصيل
  l_rv := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', l_date, l_box, NULL, NULL, 'شركة الأمل', 'تمويل من الشركاء', 'REF-1',
            '[{"a":"3104","m":3000,"t":"دفعة أولى"},{"a":"4201","m":2000.555},{"a":"","m":null}]');
  SELECT amount INTO l_n FROM csh_transaction WHERE id = l_rv;
  ok('voucher amount = sum of lines (rounded)', l_n = 5000.56, l_n);
  SELECT COUNT(*) INTO l_n FROM csh_transaction_line WHERE transaction_id = l_rv;
  ok('empty lines ignored', l_n = 2, l_n);
  l_rv := NOONA_CSH_PKG.save_voucher(l_rv, 'RECEIPT', l_date, l_box, NULL, NULL, 'شركة الأمل', 'تمويل من الشركاء', 'REF-1',
            '[{"a":"3104","m":3000,"t":"دفعة أولى"},{"a":"4201","m":2000}]');
  SELECT amount INTO l_n FROM csh_transaction WHERE id = l_rv;
  ok('draft re-saved (header + lines replaced)', l_n = 5000, l_n);
  NOONA_CSH_PKG.submit_voucher(l_rv);
  BEGIN l_n := NOONA_CSH_PKG.save_voucher(l_rv, 'RECEIPT', l_date, l_box, NULL, NULL, 'x', 'x', NULL, '[{"a":"4201","m":1}]');
        ok('submitted voucher locked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('submitted voucher locked', 'NOONA-CSH-020', SQLERRM); END;
  BEGIN NOONA_CSH_PKG.approve_voucher(l_rv); ok('maker cannot approve', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('maker cannot approve', 'NOONA-CSH-031', SQLERRM); END;

  login(l_user);
  NOONA_CSH_PKG.approve_voucher(l_rv, 'مطابق');
  SELECT status_code, doc_no INTO l_s, l_c FROM csh_transaction WHERE id = l_rv;
  ok('approved receipt posted with RV number', l_s = 'SETTLED' AND l_c LIKE 'RV-%', l_s || ' ' || l_c);
  SELECT j.id INTO l_j FROM gl_journal j JOIN ace_accounting_event e ON e.id = j.accounting_event_id
   WHERE e.source_entity_type = 'CSH_TRANSACTION' AND e.source_entity_id = l_rv;
  SELECT COUNT(*) INTO l_n FROM gl_journal j JOIN gl_journal_source s ON s.id = j.journal_source_id
   WHERE j.id = l_j AND j.status_code = 'POSTED' AND s.code = 'CASH' AND j.total_debit_func = 5000 AND j.total_credit_func = 5000
     AND j.reference_no LIKE 'RV-%';
  ok('engine journal: posted, balanced, source CASH, linked', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id
   WHERE l.journal_id = l_j AND a.account_code = '1101' AND l.debit_func = 5000;
  ok('receipt debits the cash box account', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM ace_accounting_event WHERE source_entity_type = 'CSH_TRANSACTION' AND source_entity_id = l_rv
     AND status_code = 'POSTED' AND idempotency_key = 'CSH_TRANSACTION:' || l_rv || ':V1';
  ok('accounting event with idempotency key', l_n = 1);
  BEGIN NOONA_CSH_PKG.approve_voucher(l_rv); ok('double posting blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('double posting blocked', 'NOONA-CSH-030', SQLERRM); END;
  ok('box balance after receipt', NOONA_CSH_PKG.balance(l_box, NULL) = 5000, NOONA_CSH_PKG.balance(l_box, NULL));

  -- سند صرف يتجاوز الرصيد
  login('ADMIN');
  l_pv := NOONA_CSH_PKG.save_voucher(NULL, 'PAYMENT', l_date, l_box, NULL, NULL, 'مؤسسة النور', 'سداد', NULL, '[{"a":"2103","m":6000}]');
  NOONA_CSH_PKG.submit_voucher(l_pv);
  login(l_user);
  BEGIN NOONA_CSH_PKG.approve_voucher(l_pv); ok('cash box cannot go negative', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cash box cannot go negative', 'NOONA-CSH-040', SQLERRM); END;
  NOONA_CSH_PKG.reject_voucher(l_pv, 'يتجاوز الرصيد');
  SELECT status_code INTO l_s FROM csh_transaction WHERE id = l_pv;
  ok('rejected voucher back to draft', l_s = 'DRAFT', l_s);

  -- حد الدفع البنكي
  login('ADMIN');
  l_n := NOONA_CSH_PKG.save_voucher(NULL, 'PAYMENT', l_date, NULL, l_bank, 'BANK_TRANSFER', 'مؤسسة النور', 'سداد', NULL,
                                    '[{"a":"2103","m":15000}]');
  NOONA_CSH_PKG.submit_voucher(l_n);
  login(l_user);
  BEGIN NOONA_CSH_PKG.approve_voucher(l_n); ok('bank payment limit enforced', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('bank payment limit enforced', 'NOONA-CSH-041', SQLERRM); END;

  -- سند مصروفات بمركز تكلفة إلزامي
  login('ADMIN');
  SELECT a.id INTO l_n FROM gl_account a JOIN gl_ledger g ON g.coa_id = a.coa_id WHERE g.id = l_led AND a.account_code = '5202';
  NOONA_GL_PKG.set_cc_rule(l_n, 'REQUIRED');
  BEGIN l_ev := NOONA_CSH_PKG.save_voucher(NULL, 'EXPENSE', l_date, l_box, NULL, NULL, 'مالك العقار', 'إيجار', NULL,
                                           '[{"a":"5202","m":1500}]');
        ok('cost center required by account rule', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cost center required by account rule', 'NOONA-GL-055', SQLERRM); END;
  l_cc := NOONA_GL_PKG.create_cost_center('CC' || l_sfx, 'الإدارة العامة');
  l_ev := NOONA_CSH_PKG.save_voucher(NULL, 'EXPENSE', l_date, l_box, NULL, NULL, 'مالك العقار', 'إيجار المكتب', NULL,
                                     '[{"a":"5202","m":1500,"cc":' || l_cc || ',"t":"إيجار شهر"}]');
  NOONA_CSH_PKG.submit_voucher(l_ev);
  login(l_user);
  NOONA_CSH_PKG.approve_voucher(l_ev);
  SELECT doc_no INTO l_s FROM csh_transaction WHERE id = l_ev;
  ok('expense voucher posted with EV number', l_s LIKE 'EV-%', l_s);
  SELECT COUNT(*) INTO l_n FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
    JOIN ace_accounting_event e ON e.id = j.accounting_event_id
   WHERE e.source_entity_id = l_ev AND e.source_entity_type = 'CSH_TRANSACTION' AND l.cost_center_id = l_cc AND l.debit_func = 1500;
  ok('expense posted to cost center', l_n = 1);
  ok('box balance after expense', NOONA_CSH_PKG.balance(l_box, NULL) = 3500, NOONA_CSH_PKG.balance(l_box, NULL));
  login('ADMIN');
  l_c := NOONA_GL_PKG.analysis(TRUNC(l_date, 'YYYY'), l_date, 'EXPENSE', 'CC');
  ok('expense analysis by cost center', INSTR(l_c, 'الإدارة العامة') > 0);
  SELECT a.id INTO l_n FROM gl_account a JOIN gl_ledger g ON g.coa_id = a.coa_id WHERE g.id = l_led AND a.account_code = '5202';
  NOONA_GL_PKG.set_cc_rule(l_n, 'OPTIONAL');

  -- العكس
  BEGIN l_n := NOONA_GL_PKG.reverse_journal(l_j, l_date, 'محاولة'); ok('system journal reversed only via its voucher', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('system journal reversed only via its voucher', 'NOONA-GL-083', SQLERRM); END;
  login(l_user);
  l_rev := NOONA_CSH_PKG.reverse_voucher(l_ev, l_date, 'إيجار مكرر');
  SELECT status_code INTO l_s FROM csh_transaction WHERE id = l_ev;
  ok('voucher reversed', l_s = 'REVERSED', l_s);
  SELECT COUNT(*) INTO l_n FROM gl_journal WHERE id = l_rev AND status_code = 'POSTED' AND accounting_event_id IS NOT NULL;
  ok('reversal journal posted and linked', l_n = 1);
  ok('box balance restored', NOONA_CSH_PKG.balance(l_box, NULL) = 5000, NOONA_CSH_PKG.balance(l_box, NULL));
  BEGIN l_n := NOONA_CSH_PKG.reverse_voucher(l_ev, l_date, 'مرة ثانية'); ok('double reversal blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('double reversal blocked', 'NOONA-CSH-033', SQLERRM); END;

  -- التقارير
  l_c := NOONA_CSH_PKG.cash_book(l_box, NULL, TRUNC(l_date, 'YYYY'), l_date);
  ok('cash book lists vouchers and reversal', INSTR(l_c, 'RV-') > 0 AND INSTR(l_c, '(عكس)') > 0 AND INSTR(l_c, '5,000.00') > 0);
  l_c := NOONA_CSH_PKG.voucher_print(l_rv);
  ok('voucher print with amount in words', INSTR(l_c, 'لا غير') > 0 AND INSTR(l_c, 'شركة الأمل') > 0);
  l_s := NOONA_CSH_PKG.amount_words(1250.5, 'SAR');
  ok('amount in words', INSTR(l_s, 'ألف') > 0 AND INSTR(l_s, 'مائتان وخمسون') > 0 AND INSTR(l_s, 'خمسون') > 0, l_s);
  login('ADMIN');
  l_c := NOONA_GL_PKG.trial_balance(TRUNC(l_date, 'YYYY'), l_date);
  ok('trial balance still balanced', INSTR(l_c, 'الميزان متوازن') > 0);
  l_c := NOONA_GL_PKG.balance_sheet(l_date);
  ok('balance sheet renders', INSTR(l_c, 'nn-rpt') > 0);
  l_c := NOONA_CSH_PKG.summary('1');
  ok('cash dashboard renders', INSTR(l_c, 'nn-kpi') > 0);

  -- كفاية الرصيد في صرف الوحدات الأخرى (سداد مورد): الصندوق لا يصرف فوق رصيده، والبنك حتى رصيده + حد المكشوف
  l_n := NOONA_PUR_PKG.quick_setup;
  l_n := NOONA_PUR_PKG.save_supplier('{"name":"مورد رصيد اختبار ' || l_sfx || '","term":"NET30"}');
  BEGIN l_j := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_n || ',"amount":5000.01,"place":"BOX:' || l_box || '","method":"CASH"}');
    ok('box cannot pay above its balance (other modules)', FALSE);
  EXCEPTION WHEN OTHERS THEN
    ok('box cannot pay above its balance (other modules)', INSTR(SQLERRM, 'NOONA-CSH-040') > 0 OR INSTR(SQLERRM, 'NOONA-PUR-042') > 0, SQLERRM); END;
  l_j := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_n || ',"amount":5000,"place":"BOX:' || l_box || '","method":"CASH"}');
  ok('box can pay exactly its balance', NOONA_CSH_PKG.balance(l_box, NULL) = 0, NOONA_CSH_PKG.balance(l_box, NULL));
  l_bal0 := NOONA_CSH_PKG.balance(NULL, l_bank);
  BEGIN l_j := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_n || ',"amount":' || (GREATEST(l_bal0, 0) + 700) || ',"place":"BANK:' || l_bank || '","method":"BANK_APP"}');
    ok('bank cannot pay above balance without overdraft', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('bank cannot pay above balance without overdraft', 'NOONA-CSH-042', SQLERRM); END;
  BEGIN NOONA_CSH_PKG.set_overdraft(l_bank, -5); ok('negative overdraft rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('negative overdraft rejected', 'NOONA-CSH-043', SQLERRM); END;
  NOONA_CSH_PKG.set_overdraft(l_bank, 1000);
  l_j := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_n || ',"amount":' || (GREATEST(l_bal0, 0) + 700) || ',"place":"BANK:' || l_bank || '","method":"BANK_APP"}');
  ok('overdraft facility allows paying within the limit', NOONA_CSH_PKG.balance(NULL, l_bank) = LEAST(l_bal0, 0) - 700, NOONA_CSH_PKG.balance(NULL, l_bank));
  BEGIN l_j := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_n || ',"amount":400,"place":"BANK:' || l_bank || '","method":"BANK_APP"}');
    ok('overdraft limit enforced', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('overdraft limit enforced', 'NOONA-CSH-042', SQLERRM); END;
  l_c := NOONA_CSH_PKG.negative_balances_html;
  ok('negative balances report', INSTR(l_c, 'الحساب الجاري') > 0 AND INSTR(l_c, 'ضمن التسهيل البنكي') > 0, SUBSTR(l_c, 1, 200));

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
  IF g_fail > 0 THEN RAISE_APPLICATION_ERROR(-20999, g_fail || ' test(s) failed'); END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
