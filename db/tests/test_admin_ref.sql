-- =============================================================================
-- NOONA PLUS ERP | اختبار البيانات المرجعية وتعديل مسودات مسارات الاعتماد بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_admin_ref.sql
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
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'DDHH24MISSFF2');
  l_sess NUMBER := TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12));
  l_co   NUMBER;
  l_type NUMBER;
  l_rate NUMBER;
  l_term NUMBER;
  l_seq  NUMBER;
  l_def  NUMBER;
  l_ver  NUMBER;
  l_ver2 NUMBER;
  l_st   NUMBER;
  l_n    NUMBER;
  l_s    VARCHAR2(4000);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', l_sess);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));

  -- أسعار الصرف
  l_type := NOONA_REFDATA_PKG.create_rate_type('T' || l_sfx, 'سعر اختبار', 'MANUAL', 'Y');
  l_rate := NOONA_REFDATA_PKG.add_rate(l_type, 'USD', 'SAR', TRUNC(SYSDATE), 3.75);
  SELECT status_code INTO l_s FROM ref_exchange_rate WHERE id = l_rate;
  ok('rate needing approval saved as draft', l_s = 'DRAFT', l_s);
  BEGIN NOONA_REFDATA_PKG.approve_rate(l_rate); ok('maker cannot approve own rate', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('maker cannot approve own rate', 'NOONA-REF-104', SQLERRM); END;
  BEGIN l_n := NOONA_REFDATA_PKG.add_rate(l_type, 'USD', 'USD', TRUNC(SYSDATE), 1); ok('same currency rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('same currency rejected', 'NOONA-REF-102', SQLERRM); END;
  BEGIN l_n := NOONA_REFDATA_PKG.add_rate(l_type, 'USD', 'SAR', TRUNC(SYSDATE), 3.8); ok('duplicate rate rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate rate rejected', 'NOONA-REF-105', SQLERRM); END;
  SELECT ROUND(inverse_rate, 6) INTO l_n FROM ref_exchange_rate WHERE id = l_rate;
  ok('inverse rate computed', l_n = ROUND(1 / 3.75, 6), l_n);
  -- أسعار كل شركة مستقلة: السعر يخص الشركة الحالية ولا يستخدم في غيرها
  SELECT company_id INTO l_n FROM ref_exchange_rate WHERE id = l_rate;
  ok('rate belongs to the current company', l_n = l_co, l_n);
  l_type := NOONA_REFDATA_PKG.create_rate_type('U' || l_sfx, 'سعر اختبار مباشر', 'MANUAL', 'N');
  l_n := NOONA_REFDATA_PKG.add_rate(l_type, 'EUR', 'SAR', TRUNC(SYSDATE), 4.1);
  ok('rate used in its own company', NOONA_REFERENCE_PKG.get_rate('EUR', 'SAR', l_type) = 4.1);
  SELECT NVL(MIN(id), -1) INTO l_n FROM org_company WHERE id <> l_co;
  ok('rate not used by another company', NOONA_REFERENCE_PKG.get_rate('EUR', 'SAR', l_type, SYSTIMESTAMP, l_n) IS NULL);

  -- شروط الدفع
  l_term := NOONA_REFDATA_PKG.create_payment_term('P' || l_sfx, 'صافي 60', 'DOC_DATE', 60, 2, 10);
  NOONA_REFDATA_PKG.add_installment(l_term, 60, 30);
  BEGIN NOONA_REFDATA_PKG.add_installment(l_term, 50, 60); ok('installments over 100% rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('installments over 100% rejected', 'NOONA-REF-113', SQLERRM); END;
  BEGIN l_n := NOONA_REFDATA_PKG.create_payment_term('Q' || l_sfx, 'خطأ', 'DOC_DATE', 10, 2, 20); ok('discount days beyond due rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('discount days beyond due rejected', 'NOONA-REF-111', SQLERRM); END;

  -- تسلسلات المستندات
  l_seq := NOONA_REFDATA_PKG.create_doc_sequence(l_co, 'T' || SUBSTR(l_sfx, -5), 2026, 'TS-');
  ok('sequence preview', NOONA_REFDATA_PKG.preview_doc_no(l_seq) = 'TS-2026-000001', NOONA_REFDATA_PKG.preview_doc_no(l_seq));
  BEGIN NOONA_REFDATA_PKG.update_doc_sequence(l_seq, 'TS-', 0, 'Y'); ok('sequence cannot go backwards', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('sequence cannot go backwards', 'NOONA-REF-123', SQLERRM); END;
  NOONA_REFDATA_PKG.update_doc_sequence(l_seq, 'TX-', 100, 'Y');
  ok('sequence moved forward', NOONA_REFDATA_PKG.preview_doc_no(l_seq) = 'TX-2026-000100', NOONA_REFDATA_PKG.preview_doc_no(l_seq));

  -- مسودات مسارات الاعتماد
  l_def := NOONA_WORKFLOW_PKG.create_definition('W' || l_sfx, 'مسار اختبار', 'PUR_ORDER');
  l_ver := NOONA_WORKFLOW_PKG.new_version(l_def);
  l_n := NOONA_WORKFLOW_PKG.add_step(l_ver, 'START', 'START', 'بداية');
  l_st := NOONA_WORKFLOW_PKG.add_step(l_ver, 'MGR', 'APPROVAL', 'المدير', 'MANAGER');
  l_n := NOONA_WORKFLOW_PKG.add_step(l_ver, 'TMP', 'APPROVAL', 'خطوة زائدة', 'MANAGER');
  l_n := NOONA_WORKFLOW_PKG.add_step(l_ver, 'END', 'END', 'نهاية');
  NOONA_WORKFLOW_PKG.add_transition(l_ver, 'START', 'MGR');
  NOONA_WORKFLOW_PKG.add_transition(l_ver, 'MGR', 'END', 'APPROVED');
  SELECT id INTO l_n FROM wf_step_def WHERE version_id = l_ver AND step_code = 'TMP';
  NOONA_WORKFLOW_PKG.remove_step(l_n);
  NOONA_WORKFLOW_PKG.publish_version(l_ver);
  ok('draft edited and published', TRUE);
  BEGIN NOONA_WORKFLOW_PKG.remove_step(l_st); ok('published version immutable', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('published version immutable', 'NOONA-WF-001', SQLERRM); END;
  l_ver2 := NOONA_WORKFLOW_PKG.copy_version(l_def);
  SELECT COUNT(*) INTO l_n FROM wf_step_def WHERE version_id = l_ver2;
  ok('copy_version copies steps', l_n = 3, l_n);
  SELECT COUNT(*) INTO l_n FROM wf_transition_def WHERE version_id = l_ver2;
  ok('copy_version copies transitions', l_n = 2, l_n);
  l_s := DBMS_LOB.SUBSTR(NOONA_UI_PKG.workflow_diagram(l_ver2), 4000, 1);
  ok('workflow diagram renders steps', INSTR(l_s, 'nn-flow-node') > 0 AND INSTR(l_s, 'المدير') > 0);

  ok('audit chain intact', NOONA_AUDIT_PKG.verify_chain(TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID'))) IS NULL);
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
