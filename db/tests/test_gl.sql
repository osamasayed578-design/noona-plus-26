-- =============================================================================
-- NOONA PLUS ERP | اختبار الأستاذ العام (NOONA_GL_PKG) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_gl.sql
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
  l_led2 NUMBER;
  l_j    NUMBER;
  l_rev  NUMBER;
  l_mem  NUMBER;
  l_role NUMBER;
  l_n    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_per  NUMBER;
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
  l_led := NOONA_GL_PKG.quick_setup;
  l_led2 := NOONA_GL_PKG.quick_setup;
  ok('quick setup creates ledger (idempotent)', l_led IS NOT NULL AND l_led = l_led2);
  SELECT COUNT(*) INTO l_n FROM gl_account a JOIN gl_ledger g ON g.coa_id = a.coa_id WHERE g.id = l_led AND a.is_postable = 'Y';
  ok('standard chart loaded', l_n >= 40, l_n);
  l_n := NOONA_PLATFORM_PKG.run_activation_checks(TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')));
  SELECT MAX(status_code) INTO l_s FROM org_company_check
   WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND check_code = 'LEDGER_COA';
  ok('activation check LEDGER_COA passes', l_s = 'PASSED', l_s);

  -- محاسب ثان للاعتماد (فصل المهام)
  l_mem := NOONA_SEC_ADMIN_PKG.create_user('GLA' || l_sfx, 'محاسب معتمد', 'gla' || l_sfx || '@x.local',
                                           TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')));
  l_role := NOONA_SEC_ADMIN_PKG.create_role('GLR' || l_sfx, 'معتمد قيود');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,CREATE,UPDATE,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'اختبار');

  -- قيد يومية
  l_j := NOONA_GL_PKG.create_journal(l_date, 'إثبات رأس المال');
  BEGIN NOONA_GL_PKG.save_lines(l_j, '[{"a":"1103","d":100},{"a":"3101","c":100}]'); ok('control account blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('control account blocked', 'NOONA-GL-053', SQLERRM); END;
  BEGIN NOONA_GL_PKG.save_lines(l_j, '[{"a":"1","d":100},{"a":"3101","c":100}]'); ok('summary account blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('summary account blocked', 'NOONA-GL-052', SQLERRM); END;
  NOONA_GL_PKG.save_lines(l_j, '[{"a":"1102","d":100000},{"a":"3101","c":90000}]');
  BEGIN NOONA_GL_PKG.submit_journal(l_j); ok('unbalanced journal blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unbalanced journal blocked', 'NOONA-GL-061', SQLERRM); END;
  NOONA_GL_PKG.save_lines(l_j, '[{"a":"1102","d":100000,"t":"إيداع"},{"a":"3101","c":100000},{"a":"","d":null}]');
  SELECT COUNT(*) INTO l_n FROM gl_journal_line WHERE journal_id = l_j;
  ok('empty lines ignored', l_n = 2, l_n);
  NOONA_GL_PKG.submit_journal(l_j);
  SELECT status_code INTO l_s FROM gl_journal WHERE id = l_j;
  ok('journal submitted for approval', l_s = 'SUBMITTED', l_s);
  BEGIN NOONA_GL_PKG.approve_journal(l_j); ok('maker cannot approve', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('maker cannot approve', 'NOONA-GL-071', SQLERRM); END;

  login('GLA' || l_sfx);
  NOONA_GL_PKG.approve_journal(l_j, 'مطابق');
  SELECT status_code, doc_no INTO l_s, l_c FROM gl_journal WHERE id = l_j;
  ok('approved journal posted with official number', l_s = 'POSTED' AND l_c LIKE 'JV-%', l_s || ' ' || l_c);
  SELECT NVL(SUM(period_dr_func - period_cr_func), 0) INTO l_n FROM gl_balance b JOIN gl_account a ON a.id = b.account_id
   WHERE b.ledger_id = l_led AND a.account_code = '1102';
  ok('balances updated on posting', l_n >= 100000, l_n);
  l_c := NOONA_GL_PKG.trial_balance(TRUNC(l_date, 'YYYY'), l_date);
  ok('trial balance balanced', INSTR(l_c, 'الميزان متوازن') > 0);
  SELECT id INTO l_n FROM gl_account a WHERE a.account_code = '3101' AND a.coa_id = (SELECT coa_id FROM gl_ledger WHERE id = l_led);
  l_c := NOONA_GL_PKG.account_statement(l_n, TRUNC(l_date, 'YYYY'), l_date);
  ok('account statement lists the journal', INSTR(l_c, 'إثبات رأس المال') > 0);

  -- العكس
  l_rev := NOONA_GL_PKG.reverse_journal(l_j, l_date, 'قيد خاطئ');
  SELECT status_code INTO l_s FROM gl_journal WHERE id = l_j;
  ok('original marked reversed', l_s = 'REVERSED', l_s);
  SELECT COUNT(*) INTO l_n FROM gl_journal WHERE id = l_rev AND status_code = 'POSTED' AND reversal_of_id = l_j;
  ok('reversal journal posted', l_n = 1);
  BEGIN l_n := NOONA_GL_PKG.reverse_journal(l_j, l_date, 'مرة ثانية'); ok('double reversal blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('double reversal blocked', 'NOONA-GL-080', SQLERRM); END;

  -- إقفال الفترة
  login('ADMIN');
  l_per := NOONA_GL_PKG.period_for(l_date);
  NOONA_GL_PKG.set_period_status(l_per, 'SOFT_CLOSED');
  l_j := NOONA_GL_PKG.create_journal(l_date, 'قيد في فترة مقفلة');
  NOONA_GL_PKG.save_lines(l_j, '[{"a":"5202","d":500},{"a":"1101","c":500}]');
  BEGIN NOONA_GL_PKG.submit_journal(l_j); ok('closed period blocks posting', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('closed period blocks posting', 'NOONA-GL-041', SQLERRM); END;
  NOONA_GL_PKG.set_period_status(l_per, 'OPEN');
  NOONA_GL_PKG.submit_journal(l_j);
  ok('reopened period accepts submission', TRUE);
  l_c := NOONA_GL_PKG.gl_summary('1');
  ok('GL dashboard renders', INSTR(l_c, 'nn-kpi') > 0);

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
