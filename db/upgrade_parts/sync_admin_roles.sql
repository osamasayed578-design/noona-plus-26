-- مزامنة دور مسؤول المؤسسة (TENANT_ADMIN) مع الصلاحيات المضافة في الترقيات (كما عند التجهيز: كل الصلاحيات عدا CONFIGURE)
BEGIN
  NOONA_CORE_PKG.begin_system;
  INSERT INTO sec_role_permission (tenant_id, role_id, permission_id, effect)
  SELECT r.tenant_id, r.id, p.id, 'ALLOW'
    FROM sec_role r JOIN sec_permission p ON p.action_code <> 'CONFIGURE' AND p.is_active = 'Y'
   WHERE r.code = 'TENANT_ADMIN'
     AND NOT EXISTS (SELECT 1 FROM sec_role_permission x WHERE x.role_id = r.id AND x.permission_id = p.id);
  DBMS_OUTPUT.PUT_LINE('TENANT_ADMIN permissions added: ' || SQL%ROWCOUNT);
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
