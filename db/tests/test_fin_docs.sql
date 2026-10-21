-- =============================================================================
-- NOONA PLUS ERP | اختبار أسعار الصرف والإعدادات الافتراضية ومستندات القيود والسندات (JSON) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_fin_docs.sql
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
  l_usd  NUMBER;
  l_id   NUMBER;
  l_n    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_date DATE := TRUNC(SYSDATE);
  l_d    VARCHAR2(10) := TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD');

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
  l_led := NOONA_GL_PKG.quick_setup;
  l_box := NOONA_CSH_PKG.quick_setup;

  -- أسعار الصرف
  SELECT COUNT(*) INTO l_n FROM ref_rate_type WHERE code = 'ACCOUNTING';
  ok('accounting rate type created', l_n = 1);
  ok('functional currency rate = 1', NOONA_GL_PKG.rate_for('SAR', l_date) = 1);
  ok('USD pegged rate 3.75', NOONA_GL_PKG.rate_for('USD', l_date) = 3.75, NOONA_GL_PKG.rate_for('USD', l_date));
  ok('seed rates idempotent', NOONA_GL_PKG.seed_rates = 0);
  ok('reverse direction derived', ROUND(NOONA_REFERENCE_PKG.get_rate('SAR', 'USD', NOONA_GL_PKG.rate_type, SYSTIMESTAMP), 6) = ROUND(1 / 3.75, 6));
  l_c := NOONA_GL_PKG.currencies_json;
  ok('currencies JSON carries rates', INSTR(l_c, '"c":"USD"') > 0 AND INSTR(l_c, '"r":3.75') > 0);
  ok('no rate for unpriced currency', NOONA_GL_PKG.rate_for('SDG', l_date) IS NULL);

  -- الإعدادات الافتراضية
  SELECT COUNT(*) INTO l_n FROM gl_cost_center WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  ok('cost centers exist after setup', l_n > 0, l_n);
  ok('seed cost centers idempotent', NOONA_GL_PKG.seed_cost_centers = 0);
  SELECT COUNT(*) INTO l_n FROM csh_cash_box WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND box_type = 'PETTY_CASH';
  ok('petty cash box created', l_n >= 1, l_n);
  SELECT COUNT(*) INTO l_n FROM csh_bank_account WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  ok('default bank account exists', l_n >= 1, l_n);
  ok('seed cash defaults idempotent', NOONA_CSH_PKG.seed_defaults = 0);
  SELECT MIN(id) INTO l_id FROM csh_bank_account WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT MIN(id) INTO l_n FROM ref_bank WHERE code = 'SA-NCB';
  NOONA_CSH_PKG.update_bank_account(l_id, 'الحساب الجاري', l_n, '11223344556677', 'SA4410000011223344556677', 50000);
  SELECT account_no_masked || '|' || iban_masked INTO l_s FROM csh_bank_account WHERE id = l_id;
  ok('bank account updated (masked)', l_s = '****6677|SA44****6677', l_s);

  -- صندوق بعملة أجنبية وسند بالسعر الآلي
  l_usd := NOONA_CSH_PKG.create_cash_box('USD' || l_sfx, 'صندوق الدولار', '1101', 'MAIN', NULL, 'USD');
  l_c := NOONA_CSH_PKG.places_json;
  ok('places JSON includes currency', INSTR(l_c, '"BOX:' || l_usd || '"') > 0 AND INSTR(l_c, '"c":"USD"') > 0);
  l_id := NOONA_CSH_PKG.save_voucher_doc('{"id":null,"type":"RECEIPT","date":"' || l_d || '","place":"BOX:' || l_usd
            || '","party":"عميل خارجي","desc":"قبض بالدولار","ref":"P-1","action":"SAVE","lines":[{"a":"4201","m":100,"t":"خدمة"}]}');
  SELECT currency_code || '|' || exchange_rate || '|' || amount || '|' || amount_func INTO l_s FROM csh_transaction WHERE id = l_id;
  ok('foreign voucher uses approved rate', l_s = 'USD|3.75|100|375', l_s);
  BEGIN l_n := NOONA_CSH_PKG.create_cash_box('X' || l_sfx, 'خطأ', '1101', 'MAIN', NULL, 'XXX'); ok('unknown currency blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unknown currency blocked', 'NOONA-CSH-019', SQLERRM); END;

  -- مستند السند: إنشاء ثم تعديل ثم إرسال في استدعاء واحد
  l_id := NOONA_CSH_PKG.save_voucher_doc('{"id":null,"type":"EXPENSE","date":"' || l_d || '","place":"BOX:' || l_box
            || '","party":"مكتبة الرياض","desc":"قرطاسية","ref":"INV-77","action":"SAVE","lines":[{"a":"5207","m":120}]}');
  l_n := NOONA_CSH_PKG.save_voucher_doc('{"id":' || l_id || ',"type":"EXPENSE","date":"' || l_d || '","place":"BOX:' || l_box
            || '","party":"مكتبة الرياض","desc":"قرطاسية ومطبوعات","ref":"INV-77","action":"SUBMIT",'
            || '"lines":[{"a":"5207","m":120,"t":"أوراق"},{"a":"5207","m":30.5,"t":"أحبار"}]}');
  SELECT status_code || '|' || amount || '|' || description INTO l_s FROM csh_transaction WHERE id = l_id;
  ok('voucher doc saved and submitted in one call', l_n = l_id AND l_s = 'SUBMITTED|150.5|قرطاسية ومطبوعات', l_s);
  l_c := NOONA_CSH_PKG.voucher_doc_json(l_id);
  ok('voucher doc JSON (header, lines, words)', INSTR(l_c, '"status":"SUBMITTED"') > 0 AND INSTR(l_c, '"t":"أحبار"') > 0 AND INSTR(l_c, 'لا غير') > 0);
  ok('new voucher doc JSON', INSTR(NOONA_CSH_PKG.voucher_doc_json(NULL, 'PAYMENT'), '"type":"PAYMENT"') > 0);
  BEGIN l_n := NOONA_CSH_PKG.save_voucher_doc('{"id":null,"type":"PAYMENT","date":"' || l_d || '","place":"BOX:' || l_box
                  || '","desc":"بدون سطور","action":"SAVE","lines":[]}'); ok('voucher doc validates lines', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('voucher doc validates lines', 'NOONA-CSH-028', SQLERRM); END;

  -- مستند القيد
  l_id := NOONA_GL_PKG.save_journal_doc('{"id":null,"date":"' || l_d || '","desc":"قيد بالدولار","ref":"R-9","cur":"USD","action":"SAVE",'
            || '"lines":[{"a":"1102","d":1000},{"a":"3104","c":1000,"t":"إيداع"}]}');
  SELECT currency_code || '|' || exchange_rate || '|' || total_debit_func INTO l_s FROM gl_journal WHERE id = l_id;
  ok('journal doc in USD at approved rate', l_s = 'USD|3.75|3750', l_s);
  l_n := NOONA_GL_PKG.save_journal_doc('{"id":' || l_id || ',"date":"' || l_d || '","desc":"قيد بالريال","ref":"R-9","cur":"SAR","action":"SUBMIT",'
            || '"lines":[{"a":"1102","d":500},{"a":"3104","c":500}]}');
  SELECT status_code || '|' || currency_code || '|' || exchange_rate || '|' || total_debit_func INTO l_s FROM gl_journal WHERE id = l_id;
  ok('journal doc updated (currency) and submitted', l_s = 'SUBMITTED|SAR|1|500', l_s);
  l_c := NOONA_GL_PKG.journal_doc_json(l_id);
  ok('journal doc JSON', INSTR(l_c, '"status":"SUBMITTED"') > 0 AND INSTR(l_c, '"a":"1102"') > 0 AND INSTR(l_c, '"desc":"قيد بالريال"') > 0);
  BEGIN l_n := NOONA_GL_PKG.save_journal_doc('{"id":null,"date":"' || l_d || '","desc":"غير متوازن","action":"SUBMIT",'
                  || '"lines":[{"a":"1102","d":10},{"a":"3104","c":9}]}'); ok('journal doc enforces balance', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('journal doc enforces balance', 'NOONA-GL-061', SQLERRM); END;
  BEGIN l_n := NOONA_GL_PKG.save_journal_doc('{"id":null,"date":"' || l_d || '","desc":"عملة بلا سعر","cur":"SDG","action":"SAVE","lines":[]}');
        ok('journal doc needs a rate for unpriced currency', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('journal doc needs a rate for unpriced currency', 'NOONA-GL-045', SQLERRM); END;
  ok('new journal doc JSON', INSTR(NOONA_GL_PKG.journal_doc_json(NULL), '"status":"DRAFT"') > 0);

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
