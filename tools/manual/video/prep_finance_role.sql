-- تجهيز خارج التصوير لفيديو المالية: دور «المدير المالي» (صلاحيات الأستاذ العام والنقدية) للمحاسبة في شركتها الافتراضية
-- sqlplus NOONA_APP@... @tools/manual/video/prep_finance_role.sql <ADMIN_USER> <ACCOUNTANT_USER>
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
DECLARE
  l_role NUMBER; l_n NUMBER; l_mem NUMBER; l_co NUMBER; l_g NUMBER;
BEGIN
  NOONA_APEX_PKG.post_auth('&1', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT m.id, m.default_company_id INTO l_mem, l_co FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE u.username = UPPER('&2');
  SELECT MIN(id) INTO l_role FROM sec_role WHERE code = 'FIN_MANAGER';
  IF l_role IS NULL THEN
    l_role := NOONA_SEC_ADMIN_PKG.create_role('FIN_MANAGER', 'المدير المالي', 'Finance Manager');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,CREATE,UPDATE,SUBMIT,APPROVE,POST,PRINT,EXPORT,CANCEL');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,CREATE,UPDATE,SUBMIT,APPROVE,POST,PRINT,EXPORT,CANCEL');
  END IF;
  l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, l_co, 'تجهيز فيديو المالية');
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('granted ' || l_g);
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
