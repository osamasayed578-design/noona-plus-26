-- =============================================================================
-- NOONA PLUS ERP | اختبار إقفال السنة والتقارير المالية (NOONA_GL_PKG / NOONA_FIN_RPT_PKG) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_reports.sql
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
  l_v    NUMBER;
  l_j    NUMBER;
  l_vj   NUMBER;
  l_cls  NUMBER;
  l_fy   NUMBER;
  l_mem  NUMBER;
  l_role NUMBER;
  l_n    NUMBER;
  l_n2   NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_is   CLOB;
  l_user VARCHAR2(100);
  l_date DATE := TRUNC(SYSDATE);
  l_ys   DATE;
  l_ye   DATE;

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
  FUNCTION pl_sum RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(l.debit_func - l.credit_func), 0) INTO l
      FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date BETWEEN l_ys AND l_ye
       AND a.account_type IN ('REVENUE', 'EXPENSE');
    RETURN l;
  END pl_sum;
BEGIN
  login('ADMIN');
  -- قواعد الأرشفة (المرجع الورقي) لها اختبارها الخاص test_dms؛ تعطل هنا داخل المعاملة
  UPDATE dms_archive_rule SET is_active = 'N';
  l_led := NOONA_GL_PKG.quick_setup;
  l_box := NOONA_CSH_PKG.quick_setup;
  -- صندوق مستقل للاختبار (لا يتأثر برصيد الصندوق الرئيسي في قاعدة العميل)
  l_box := NOONA_CSH_PKG.create_cash_box('TB' || SUBSTR(l_sfx, 1, 6), 'صندوق اختبار');
  l_user := 'RPA' || l_sfx;
  l_mem := NOONA_SEC_ADMIN_PKG.create_user(l_user, 'معتمد مالي', LOWER(l_user) || '@x.local', TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')));
  l_role := NOONA_SEC_ADMIN_PKG.create_role('RPR' || l_sfx, 'معتمد مالي');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,CREATE,UPDATE,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,APPROVE,POST,REVERSE');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'اختبار');

  -- بيانات: قبض من الشركاء، مصروف بمركز تكلفة، وقيد يومية إيراد
  l_v := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', l_date, l_box, NULL, NULL, 'الشريك', 'زيادة جاري الشريك', NULL, '[{"a":"3104","m":40000}]');
  NOONA_CSH_PKG.submit_voucher(l_v);
  login(l_user); NOONA_CSH_PKG.approve_voucher(l_v); login('ADMIN');
  l_v := NOONA_CSH_PKG.save_voucher(NULL, 'EXPENSE', l_date, l_box, NULL, NULL, 'شركة الكهرباء', 'فاتورة الكهرباء', NULL, '[{"a":"5203","m":1200}]');
  NOONA_CSH_PKG.submit_voucher(l_v);
  login(l_user); NOONA_CSH_PKG.approve_voucher(l_v); login('ADMIN');
  SELECT journal_id INTO l_vj FROM ace_accounting_event WHERE source_entity_type = 'CSH_TRANSACTION' AND source_entity_id = l_v
     AND reversal_of_event_id IS NULL;
  l_j := NOONA_GL_PKG.create_journal(l_date, 'إيراد خدمات محصل بالبنك');
  NOONA_GL_PKG.save_lines(l_j, '[{"a":"1102","d":9000},{"a":"4201","c":9000}]');
  NOONA_GL_PKG.submit_journal(l_j);
  login(l_user); NOONA_GL_PKG.approve_journal(l_j); login('ADMIN');

  -- الأستاذ
  l_c := NOONA_GL_PKG.trial_balance(TRUNC(l_date, 'YYYY'), l_date, 'N', NULL, 'POSTED', 'f?p=127:31:1::NO::P31_ACCOUNT:#ID#');
  ok('trial balance balanced with drill links', INSTR(l_c, 'الميزان متوازن') > 0 AND INSTR(l_c, 'nn-drill') > 0 AND INSTR(l_c, 'P31_ACCOUNT:') > 0);
  ok('report footer shows basis and extraction time', INSTR(l_c, 'أساس الاحتساب') > 0 AND INSTR(l_c, 'استخرج') > 0);
  l_c := NOONA_GL_PKG.trial_balance(TRUNC(l_date, 'YYYY'), l_date, 'N', NULL, 'ALL');
  ok('trial balance with unposted basis', INSTR(l_c, 'شامل غير المرحل') > 0);
  SELECT a.id INTO l_n FROM gl_account a WHERE a.coa_id = NOONA_GL_PKG.primary_coa AND a.account_code = '4201';
  l_c := NOONA_GL_PKG.account_statement(l_n, TRUNC(l_date, 'YYYY'), l_date, NULL, 'f?p=127:22:1::NO::P22_ID:#ID#');
  ok('statement drills to journal', INSTR(l_c, 'P22_ID:' || l_j) > 0);
  l_c := NOONA_FIN_RPT_PKG.general_ledger(TRUNC(l_date, 'YYYY'), l_date);
  ok('general ledger balanced', INSTR(l_c, 'مجموع المدين = مجموع الدائن لكل حسابات الفترة') > 0 AND INSTR(l_c, 'إيراد خدمات') > 0);
  l_c := NOONA_FIN_RPT_PKG.general_ledger(TRUNC(l_date, 'YYYY'), l_date, '5', '5999');
  ok('general ledger by account range', INSTR(l_c, '5203') > 0 AND INSTR(l_c, '1102 -') = 0);
  l_c := NOONA_FIN_RPT_PKG.journal_register(TRUNC(l_date, 'YYYY'), l_date, 'POSTED');
  ok('journal register (posted) balanced', INSTR(l_c, 'إيراد خدمات محصل بالبنك') > 0 AND INSTR(l_c, 'مجموع المدين = مجموع الدائن') > 0);
  l_n := NOONA_GL_PKG.create_journal(l_date, 'قيد مسودة للتقرير');
  NOONA_GL_PKG.save_lines(l_n, '[{"a":"5207","d":50},{"a":"1101","c":50}]');
  l_c := NOONA_FIN_RPT_PKG.journal_register(TRUNC(l_date, 'YYYY'), l_date, 'UNPOSTED');
  ok('journal register (unposted)', INSTR(l_c, 'قيد مسودة للتقرير') > 0 AND INSTR(l_c, 'إيراد خدمات محصل') = 0);
  NOONA_GL_PKG.cancel_journal(l_n, 'تنظيف');
  l_c := NOONA_FIN_RPT_PKG.journal_view(l_vj);
  ok('journal view shows the source voucher', INSTR(l_c, 'فاتورة الكهرباء') > 0 AND INSTR(l_c, 'لا غير') > 0 AND INSTR(l_c, 'مسار القيد') > 0);

  -- القوائم والتحليل
  l_c := NOONA_FIN_RPT_PKG.cash_flow(TRUNC(l_date, 'YYYY'), l_date);
  ok('cash flow reconciles to cash accounts', INSTR(l_c, 'تتطابق مع أرصدة حسابات النقدية') > 0 AND INSTR(l_c, 'التمويلية') > 0);
  l_c := NOONA_FIN_RPT_PKG.equity_changes(TRUNC(l_date, 'YYYY'), l_date);
  ok('equity changes = net assets', INSTR(l_c, 'إجمالي حقوق الملكية = الأصول - الخصوم') > 0);
  l_c := NOONA_FIN_RPT_PKG.income_compare(TRUNC(l_date, 'YYYY'), l_date, ADD_MONTHS(TRUNC(l_date, 'YYYY'), -12), TRUNC(l_date, 'YYYY') - 1);
  ok('comparative income statement', INSTR(l_c, 'صافي الربح (الخسارة)') > 0 AND INSTR(l_c, '4201') > 0);
  l_c := NOONA_FIN_RPT_PKG.ratios(TRUNC(l_date, 'YYYY'), l_date);
  ok('financial ratios + accounting equation', INSTR(l_c, 'نسبة التداول') > 0 AND INSTR(l_c, 'الأصول = الخصوم + حقوق الملكية') > 0);

  -- الرقابة والتدقيق
  l_n := NOONA_FIN_RPT_PKG.control_failures;
  ok('control checks all pass', l_n = 0, l_n);
  UPDATE gl_journal_line SET debit_func = debit_func + 1 WHERE journal_id = l_j AND line_no = 1;   -- تلاعب مقصود
  l_n := NOONA_FIN_RPT_PKG.control_failures;
  ok('control checks detect tampering', l_n > 0, l_n);
  UPDATE gl_journal_line SET debit_func = debit_func - 1 WHERE journal_id = l_j AND line_no = 1;
  l_c := NOONA_FIN_RPT_PKG.audit_log(l_date, l_date);
  ok('audit log lists approvals and sensitive permissions', INSTR(l_c, 'اعتماد') > 0 AND INSTR(l_c, l_user) > 0);

  -- إقفال السنة
  SELECT id, start_date, end_date INTO l_fy, l_ys, l_ye FROM gl_fiscal_year
   WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND l_date BETWEEN start_date AND end_date;
  -- السنوات السابقة المفتوحة (بيانات سنوات سابقة) تقفل أولاً بالترتيب
  FOR y IN (SELECT id FROM gl_fiscal_year WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'))
               AND end_date < l_ys AND status_code = 'OPEN' ORDER BY start_date) LOOP
    l_cls := NOONA_GL_PKG.close_year(y.id);
  END LOOP;
  -- مستندات معلقة من اختبارات سابقة تمنع الإقفال (تلغى داخل الاختبار ثم يتراجع)
  UPDATE gl_journal SET status_code = 'DRAFT' WHERE id = (SELECT MIN(id) FROM gl_journal WHERE ledger_id = l_led AND status_code = 'CANCELLED');
  BEGIN l_cls := NOONA_GL_PKG.close_year(l_fy); ok('close blocked by unposted documents', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('close blocked by unposted documents', INSTR(SQLERRM, 'NOONA-GL-114') > 0 OR INSTR(SQLERRM, 'NOONA-GL-115') > 0, SQLERRM); END;
  UPDATE gl_journal SET status_code = 'CANCELLED' WHERE ledger_id = l_led AND status_code IN ('DRAFT', 'SUBMITTED', 'APPROVED');
  UPDATE csh_transaction SET status_code = 'CANCELLED'
   WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND status_code IN ('DRAFT', 'SUBMITTED');
  l_n := pl_sum;
  l_is := NOONA_GL_PKG.income_statement(l_ys, l_ye);
  l_cls := NOONA_GL_PKG.close_year(l_fy);
  SELECT COUNT(*) INTO l_n2 FROM gl_journal j JOIN gl_journal_source s ON s.id = j.journal_source_id
   WHERE j.id = l_cls AND j.status_code = 'POSTED' AND j.journal_category = 'CLOSING' AND s.code = 'YEAR_END' AND j.doc_date = l_ye;
  ok('closing journal posted at year end', l_n2 = 1);
  ok('revenue and expenses zero after closing', pl_sum = 0, pl_sum);
  SELECT NVL(SUM(l.credit_func - l.debit_func), 0) INTO l_n2 FROM gl_journal_line l JOIN gl_ledger g ON g.retained_earnings_account_id = l.account_id
   WHERE l.journal_id = l_cls AND g.id = l_led;
  ok('net result moved to retained earnings', l_n2 = -l_n, l_n2 || ' vs ' || -l_n);
  l_c := NOONA_GL_PKG.income_statement(l_ys, l_ye);
  ok('income statement unchanged by closing', DBMS_LOB.SUBSTR(l_c, 400, INSTR(l_c, '<tfoot>')) = DBMS_LOB.SUBSTR(l_is, 400, INSTR(l_is, '<tfoot>')));
  l_c := NOONA_GL_PKG.balance_sheet(l_ye);
  ok('balance sheet balanced after closing', INSTR(l_c, 'الميزانية متوازنة') > 0);
  SELECT status_code INTO l_s FROM gl_fiscal_year WHERE id = l_fy;
  SELECT COUNT(*) INTO l_n2 FROM gl_period_status s JOIN gl_period p ON p.id = s.period_id
   WHERE p.fiscal_year_id = l_fy AND s.ledger_id = l_led AND s.module_code = 'GL' AND s.status_code <> 'HARD_CLOSED';
  ok('year and all periods closed', l_s = 'CLOSED' AND l_n2 = 0, l_s || ' open=' || l_n2);
  BEGIN l_n2 := NOONA_GL_PKG.create_journal(l_date, 'بعد الإقفال'); ok('no posting into a closed year', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no posting into a closed year', 'NOONA-GL-040', SQLERRM); END;
  BEGIN l_n2 := NOONA_GL_PKG.close_year(l_fy); ok('double closing blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('double closing blocked', 'NOONA-GL-111', SQLERRM); END;
  l_c := NOONA_FIN_RPT_PKG.equity_changes(l_ys, l_ye);
  ok('equity changes show closing transfer', INSTR(l_c, 'إقفال نتيجة السنة') > 0 AND INSTR(l_c, 'إجمالي حقوق الملكية = الأصول - الخصوم') > 0);
  NOONA_GL_PKG.reopen_year(l_fy, 'تعديل بعد المراجعة');
  SELECT status_code INTO l_s FROM gl_fiscal_year WHERE id = l_fy;
  ok('year reopened, closing reversed', l_s = 'OPEN' AND pl_sum = l_n, l_s || ' ' || pl_sum);
  l_c := NOONA_GL_PKG.income_statement(l_ys, l_ye);
  ok('income statement unchanged after reopen', DBMS_LOB.SUBSTR(l_c, 400, INSTR(l_c, '<tfoot>')) = DBMS_LOB.SUBSTR(l_is, 400, INSTR(l_is, '<tfoot>')));
  l_n := NOONA_FIN_RPT_PKG.control_failures;
  ok('controls pass after close/reopen', l_n = 0, l_n);

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
