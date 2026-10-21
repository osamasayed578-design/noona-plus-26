-- =============================================================================
-- NOONA PLUS ERP | اختبار أنواع القيود (افتتاحي، تسوية، استحقاق بعكس آلي، إعادة تبويب، الأنواع الآلية) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_journal_types.sql
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
  l_n    NUMBER;
  l_id   NUMBER;
  l_rev  NUMBER;
  l_box  NUMBER;
  l_v    NUMBER;
  l_mem  NUMBER;
  l_role NUMBER;
  l_user VARCHAR2(100);
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_p1   DATE;     -- بداية الفترة الأولى من السنة المالية الحالية
  l_p2   DATE;     -- بداية الفترة الثانية
  l_d1   VARCHAR2(10);
  l_d2   VARCHAR2(10);

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
  FUNCTION doc(p_type VARCHAR2, p_date VARCHAR2, p_ref VARCHAR2, p_action VARCHAR2, p_id NUMBER DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_GL_PKG.save_journal_doc('{"id":' || NVL(TO_CHAR(p_id), 'null') || ',"type":"' || p_type || '","date":"' || p_date
      || '","desc":"اختبار ' || p_type || '","ref":' || CASE WHEN p_ref IS NULL THEN 'null' ELSE '"' || p_ref || '"' END
      || ',"action":"' || p_action || '","lines":[{"a":"5205","d":1200,"cc":null},{"a":"2103","c":1200}]}');
  END doc;
BEGIN
  login('ADMIN');
  l_n := NOONA_GL_PKG.quick_setup;
  l_box := NOONA_CSH_PKG.quick_setup;
  UPDATE dms_archive_rule SET is_active = 'N';                       -- الأرشفة لها اختبارها
  SELECT MIN(p.start_date) INTO l_p1 FROM gl_period p JOIN gl_fiscal_year y ON y.id = p.fiscal_year_id
   WHERE y.company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND TRUNC(SYSDATE) BETWEEN y.start_date AND y.end_date;
  SELECT MIN(p.start_date) INTO l_p2 FROM gl_period p JOIN gl_fiscal_year y ON y.id = p.fiscal_year_id
   WHERE y.company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND TRUNC(SYSDATE) BETWEEN y.start_date AND y.end_date
     AND p.start_date > l_p1;
  l_d1 := TO_CHAR(l_p1 + 1, 'YYYY-MM-DD');
  l_d2 := TO_CHAR(l_p2 + 4, 'YYYY-MM-DD');

  -- المعتمد (فصل المهام)
  l_user := 'JTA' || l_sfx;
  l_mem := NOONA_SEC_ADMIN_PKG.create_user(l_user, 'معتمد قيود', LOWER(l_user) || '@x.local', TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')));
  l_role := NOONA_SEC_ADMIN_PKG.create_role('JTR' || l_sfx, 'معتمد قيود');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,APPROVE,POST,REVERSE');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,APPROVE,POST');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'اختبار');

  -- الأنواع الافتراضية
  SELECT COUNT(*) INTO l_n FROM gl_journal_type WHERE tenant_id IS NULL;
  ok('platform journal types seeded', l_n >= 25, l_n);
  l_c := NOONA_GL_PKG.journal_types_json;
  ok('manual types offered (opening, accrual, reclass)', INSTR(l_c, '"c":"OPENING"') > 0 AND INSTR(l_c, '"c":"ACCRUAL"') > 0
     AND INSTR(l_c, '"c":"RECLASS"') > 0);
  ok('system types not offered for manual entry', INSTR(l_c, '"c":"SALES_INVOICE"') = 0 AND INSTR(l_c, '"c":"REVERSAL"') = 0);
  ok('type label', NOONA_GL_PKG.type_label('ACCRUAL') = 'قيد استحقاق' AND NOONA_GL_PKG.type_label('PURCHASE_INVOICE') = 'فاتورة مشتريات');
  ok('new journal defaults to general type', INSTR(NOONA_GL_PKG.journal_doc_json(NULL), '"type":"GENERAL"') > 0);

  -- قواعد الأنواع
  l_id := doc('GENERAL', l_d2, NULL, 'SAVE');
  SELECT journal_category || '|' || is_opening || '|' || is_adjustment INTO l_s FROM gl_journal WHERE id = l_id;
  ok('general journal', l_s = 'GENERAL|N|N', l_s);
  BEGIN l_n := doc('SALES_INVOICE', l_d2, NULL, 'SAVE'); ok('system type rejected for manual entry', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('system type rejected for manual entry', 'NOONA-GL-134', SQLERRM); END;
  BEGIN l_n := doc('NO_SUCH_TYPE', l_d2, NULL, 'SAVE'); ok('unknown type rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unknown type rejected', 'NOONA-GL-130', SQLERRM); END;
  BEGIN l_n := doc('RECLASS', l_d2, NULL, 'SAVE'); ok('reclass needs a reference', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('reclass needs a reference', 'NOONA-GL-136', SQLERRM); END;
  l_n := doc('RECLASS', l_d2, 'JV-17', 'SAVE');
  SELECT journal_category || '|' || is_adjustment INTO l_s FROM gl_journal WHERE id = l_n;
  ok('reclass with reference is an adjustment', l_s = 'RECLASS|Y', l_s);
  BEGIN l_n := doc('OPENING', l_d2, NULL, 'SAVE'); ok('opening entry only in first period', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('opening entry only in first period', 'NOONA-GL-135', SQLERRM); END;
  l_n := doc('OPENING', l_d1, NULL, 'SAVE');
  SELECT journal_category || '|' || is_opening INTO l_s FROM gl_journal WHERE id = l_n;
  ok('opening entry in first period', l_s = 'OPENING|Y', l_s);
  -- تغيير النوع على المسودة
  l_n := doc('ADJUSTMENT', l_d2, NULL, 'SAVE', l_id);
  SELECT journal_category || '|' || is_adjustment || '|' || NVL(TO_CHAR(auto_reverse_date), '-') INTO l_s FROM gl_journal WHERE id = l_id;
  ok('draft type changed to adjustment', l_s = 'ADJUSTMENT|Y|-', l_s);

  -- الاستحقاق: تاريخ عكس آلي في أول يوم من الفترة التالية، ثم يعكس آلياً
  l_id := doc('ACCRUAL', l_d1, NULL, 'SUBMIT');
  SELECT journal_category || '|' || TO_CHAR(auto_reverse_date, 'YYYY-MM-DD') || '|' || status_code INTO l_s FROM gl_journal WHERE id = l_id;
  ok('accrual gets auto-reverse date (next period start)', l_s = 'ACCRUAL|' || TO_CHAR(l_p2, 'YYYY-MM-DD') || '|SUBMITTED', l_s);
  ok('accrual JSON carries type and reverse date', INSTR(NOONA_GL_PKG.journal_doc_json(l_id), '"rev":"' || TO_CHAR(l_p2, 'YYYY-MM-DD') || '"') > 0);
  login(l_user);
  NOONA_GL_PKG.approve_journal(l_id);
  l_n := NOONA_GL_PKG.process_auto_reversals(l_p2 - 1);
  ok('nothing reversed before the date', l_n = 0, l_n);
  l_n := NOONA_GL_PKG.process_auto_reversals(l_p2);
  SELECT j.status_code || '|' || r.journal_category || '|' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') INTO l_s
    FROM gl_journal j JOIN gl_journal r ON r.id = j.reversed_by_id WHERE j.id = l_id;
  ok('accrual auto-reversed on the next period start', l_n >= 1 AND l_s = 'REVERSED|REVERSAL|' || TO_CHAR(l_p2, 'YYYY-MM-DD'), l_n || ' ' || l_s);
  ok('auto reversal is idempotent', NOONA_GL_PKG.process_auto_reversals(l_p2) = 0);
  login('ADMIN');

  -- السندات تأخذ نوعها
  l_v := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', TO_DATE(l_d2, 'YYYY-MM-DD'), l_box, NULL, NULL, 'عميل', 'قبض نقدي', NULL,
                                    '[{"a":"4201","m":500}]');
  NOONA_CSH_PKG.submit_voucher(l_v);
  login(l_user);
  NOONA_CSH_PKG.approve_voucher(l_v);
  login('ADMIN');
  SELECT j.id, j.journal_category INTO l_id, l_s FROM gl_journal j JOIN csh_transaction t ON t.accounting_event_id = j.accounting_event_id
   WHERE t.id = l_v;
  ok('receipt voucher journal typed RECEIPT', l_s = 'RECEIPT', l_s);
  ok('system journal shows its type in the header', INSTR(NOONA_GL_PKG.journal_header(l_id), 'سند قبض') > 0);

  -- التقارير
  l_c := NOONA_FIN_RPT_PKG.journal_register(l_p1, l_p2 + 30, 'ALL', NULL, 'ACCRUAL');
  ok('journal register filtered by type', INSTR(l_c, 'قيد استحقاق') > 0 AND INSTR(l_c, 'سند قبض') = 0);
  l_c := NOONA_FIN_RPT_PKG.journal_type_summary(l_p1, l_p2 + 30);
  ok('journal type summary lists manual and system types', INSTR(l_c, 'قيد استحقاق') > 0 AND INSTR(l_c, 'قيد عكسي') > 0
     AND INSTR(l_c, 'سند قبض') > 0 AND INSTR(l_c, 'القيود الآلية من المستندات') > 0);

  -- نوع خاص بالمؤسسة
  NOONA_GL_PKG.save_journal_type('BONUS_ACCRUAL' || SUBSTR(l_sfx, 1, 5), 'استحقاق مكافآت', NULL, 'Y', 'Y', 'N', 'Y', 'مكافآت نهاية السنة');
  ok('tenant journal type offered', INSTR(NOONA_GL_PKG.journal_types_json, '"c":"BONUS_ACCRUAL' || SUBSTR(l_sfx, 1, 5) || '"') > 0);
  BEGIN NOONA_GL_PKG.save_journal_type('GENERAL', 'تجاوز'); ok('platform type code reserved', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('platform type code reserved', 'NOONA-GL-133', SQLERRM); END;

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
