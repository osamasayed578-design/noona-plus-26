-- =============================================================================
-- NOONA PLUS ERP | الأساس المالي لمؤسسة بلا تجارة سلعية (عقارات، فنادق، شقق): الصندوق والبنك ومراكز التكلفة،
--   مستخدم معتمد (فصل المهام)، وإيداع رأس المال نقداً وفي البنك ومصروف تشغيلي، وقيد استحقاق - معتمدة ومرحلة
--   sqlplus NOONA_APP@... @demo/demo_finance_base.sql <مسؤول المؤسسة>
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'
DECLARE
  c_admin CONSTANT VARCHAR2(100) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co NUMBER; l_n NUMBER; l_box NUMBER; l_bank NUMBER; l_mem NUMBER; l_role NUMBER;
  v1 NUMBER; v2 NUMBER; v3 NUMBER; j1 NUMBER;
  FUNCTION dt(p_days NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(TRUNC(SYSDATE) - p_days, 'YYYY-MM-DD'); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  FUNCTION voucher(p_type VARCHAR2, p_box NUMBER, p_bank NUMBER, p_party VARCHAR2, p_desc VARCHAR2, p_acc VARCHAR2, p_amt NUMBER, p_days NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    l := NOONA_CSH_PKG.save_voucher(NULL, p_type, TO_DATE(dt(p_days), 'YYYY-MM-DD'), p_box, p_bank, NULL, p_party, p_desc, 'DEMO',
                                    '[{"a":"' || p_acc || '","m":' || p_amt || '}]');
    NOONA_CSH_PKG.submit_voucher(l);
    RETURN l;
  END voucher;
BEGIN
  login(c_admin);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  IF NOONA_GL_PKG.primary_ledger IS NULL THEN l_n := NOONA_GL_PKG.quick_setup; END IF;
  l_box := NOONA_CSH_PKG.quick_setup;
  l_n := NOONA_CSH_PKG.seed_defaults;
  l_n := NOONA_GL_PKG.seed_cost_centers;
  IF NOONA_SAL_PKG.is_ready = 'N' THEN l_n := NOONA_SAL_PKG.quick_setup; END IF;
  IF NOONA_PUR_PKG.is_ready = 'N' THEN l_n := NOONA_PUR_PKG.quick_setup; END IF;
  COMMIT;
  SELECT NVL(MIN(CASE WHEN box_type = 'MAIN' THEN id END), MIN(id)) INTO l_n FROM csh_cash_box
   WHERE company_id = l_co AND status_code = 'ACTIVE' AND box_type IN ('MAIN', 'FRONT_DESK');
  l_box := NVL(l_n, l_box);
  SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = l_co AND status_code = 'ACTIVE';
  SELECT COUNT(*) INTO l_n FROM csh_transaction WHERE company_id = l_co AND external_reference = 'DEMO' AND txn_type = 'RECEIPT';
  IF l_n > 0 THEN DBMS_OUTPUT.PUT_LINE('الأساس المالي محمل سابقاً'); RETURN; END IF;
  SELECT MIN(m.id) INTO l_mem FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE u.username = 'DEMO_APPROVER';
  IF l_mem IS NULL THEN
    l_mem := NOONA_SEC_ADMIN_PKG.create_user('DEMO_APPROVER', 'المعتمد المالي (تجريبي)', 'demo.approver@noona.local', l_co);
  END IF;
  -- دور اعتماد مالي مستقل (قد يكون المستخدم أنشئ من عرض آخر بصلاحيات مختلفة)
  SELECT MIN(id) INTO l_role FROM sec_role WHERE code = 'DEMO_FIN_APPROVER';
  IF l_role IS NULL THEN
    l_role := NOONA_SEC_ADMIN_PKG.create_role('DEMO_FIN_APPROVER', 'معتمد مالي (تجريبي)');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,APPROVE,POST,REVERSE');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,APPROVE,POST');
  END IF;
  BEGIN l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'بيانات تجريبية'); EXCEPTION WHEN OTHERS THEN NULL; END;
  v1 := voucher('RECEIPT', l_box, NULL, 'الشركاء', 'إيداع رأس المال نقداً في الصندوق الرئيسي', '3101', 150000, 90);
  v2 := voucher('RECEIPT', NULL, l_bank, 'الشركاء', 'إيداع رأس المال في الحساب البنكي', '3101', 2500000, 90);
  v3 := voucher('EXPENSE', l_box, NULL, 'شركة الكهرباء', 'فاتورة الكهرباء', '5203', 3200, 20);
  j1 := NOONA_GL_PKG.save_journal_doc('{"id":null,"type":"ACCRUAL","date":"' || dt(10) || '","desc":"استحقاق فاتورة المياه","ref":null,'
        || '"action":"SUBMIT","lines":[{"a":"5203","d":850},{"a":"2103","c":850}]}');
  login('DEMO_APPROVER');
  NOONA_CSH_PKG.approve_voucher(v1); NOONA_CSH_PKG.approve_voucher(v2); NOONA_CSH_PKG.approve_voucher(v3);
  NOONA_GL_PKG.approve_journal(j1);
  login(c_admin);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('الأساس المالي: صندوق ' || NOONA_CSH_PKG.balance(l_box, NULL) || ' / بنك ' || NOONA_CSH_PKG.balance(NULL, l_bank));
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
