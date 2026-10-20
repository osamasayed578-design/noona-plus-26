-- =============================================================================
-- NOONA PLUS ERP | NOONA_SEC_ADMIN_PKG - إدارة المستخدمين والأدوار والصلاحيات داخل المؤسسة
--   * كل عملية: حارس الكتابة + صلاحية ذرية + سجل تدقيق
--   * ضوابط: لا ترقية لمسؤول منصة، لا صلاحيات منصة (CONFIGURE) في أدوار المؤسسة،
--     الأدوار المميزة يمنحها مسؤول المؤسسة فقط، ولا يسحب المسؤول آخر منح لدور TENANT_ADMIN (منع الإغلاق الذاتي)
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_SEC_ADMIN_PKG AUTHID DEFINER AS

  FUNCTION create_user(
    p_username        IN VARCHAR2,
    p_display_name    IN VARCHAR2,
    p_email           IN VARCHAR2,
    p_company_id      IN NUMBER,
    p_branch_id       IN NUMBER   DEFAULT NULL,
    p_is_tenant_admin IN VARCHAR2 DEFAULT 'N',
    p_clearance       IN VARCHAR2 DEFAULT 'INTERNAL') RETURN NUMBER;      -- membership id

  PROCEDURE update_member(p_membership_id IN NUMBER, p_display_name IN VARCHAR2, p_email IN VARCHAR2,
                          p_company_id IN NUMBER, p_branch_id IN NUMBER, p_clearance IN VARCHAR2);
  PROCEDURE set_member_status(p_membership_id IN NUMBER, p_status IN VARCHAR2, p_reason IN VARCHAR2);

  FUNCTION create_role(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_name_en IN VARCHAR2 DEFAULT NULL,
                       p_role_type IN VARCHAR2 DEFAULT 'FUNCTIONAL', p_privileged IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;
  PROCEDURE set_role_status(p_role_id IN NUMBER, p_status IN VARCHAR2);

  -- يضيف كل صلاحيات الوحدة للأفعال المحددة (VIEW,CREATE,...) ويرجع عدد المضاف
  FUNCTION add_module_permissions(p_role_id IN NUMBER, p_module_code IN VARCHAR2, p_actions IN VARCHAR2,
                                  p_effect IN VARCHAR2 DEFAULT 'ALLOW') RETURN NUMBER;
  PROCEDURE add_permission(p_role_id IN NUMBER, p_permission_code IN VARCHAR2, p_effect IN VARCHAR2 DEFAULT 'ALLOW');
  PROCEDURE remove_permission(p_role_permission_id IN NUMBER);

  -- p_company_id فارغ = كل شركات المؤسسة
  FUNCTION grant_role(p_membership_id IN NUMBER, p_role_id IN NUMBER, p_company_id IN NUMBER DEFAULT NULL,
                      p_reason IN VARCHAR2 DEFAULT NULL, p_effective_to IN DATE DEFAULT NULL) RETURN NUMBER;
  PROCEDURE revoke_grant(p_grant_id IN NUMBER, p_reason IN VARCHAR2);

  -- تعيين/إعادة تعيين كلمة المرور المحلية لعضو في المؤسسة (يفك القفل). الحساب المشترك مع مؤسسة أخرى
  -- لا تعاد كلمة مروره من هنا (NOONA-SEC-252)، ولا يعيد كلمة مرور مسؤول المؤسسة إلا مسؤول مؤسسة (NOONA-SEC-251)
  PROCEDURE set_password(p_membership_id IN NUMBER, p_password IN VARCHAR2);
  -- تغيير المستخدم الحالي لكلمة مروره المحلية (NOONA-SEC-253 عند خطأ كلمة المرور الحالية)
  PROCEDURE change_password(p_old_password IN VARCHAR2, p_new_password IN VARCHAR2);
END NOONA_SEC_ADMIN_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_SEC_ADMIN_PKG AS

  c_iterations CONSTANT PLS_INTEGER := 20000;    -- PBKDF2: نحو 0.1 ثانية لكل تحقق

  -- تخزين كلمة مرور جديدة (تلغي السابقة وتفك القفل)؛ خاصة بالحزمة وتستدعى بعد التحقق من الصلاحية
  PROCEDURE store_password(p_user_id IN NUMBER, p_password IN VARCHAR2) IS
    l_salt VARCHAR2(32) := RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(16));
  BEGIN
    NOONA_CORE_PKG.begin_system;
    UPDATE sec_credential SET status_code = 'REVOKED'
     WHERE user_id = p_user_id AND credential_type = 'PASSWORD' AND status_code = 'ACTIVE';
    INSERT INTO sec_credential (user_id, credential_type, secret_hash, hash_algorithm, salt, last_changed_at, status_code)
    VALUES (p_user_id, 'PASSWORD', NOONA_APEX_PKG.hash_password(p_password, l_salt, c_iterations),
            'PBKDF2-SHA256-' || c_iterations, l_salt, SYSTIMESTAMP, 'ACTIVE');
    UPDATE sec_user SET failed_logins = 0, locked_until = NULL WHERE id = p_user_id;
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END store_password;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission);
  END guard;

  FUNCTION create_user(
    p_username        IN VARCHAR2,
    p_display_name    IN VARCHAR2,
    p_email           IN VARCHAR2,
    p_company_id      IN NUMBER,
    p_branch_id       IN NUMBER   DEFAULT NULL,
    p_is_tenant_admin IN VARCHAR2 DEFAULT 'N',
    p_clearance       IN VARCHAR2 DEFAULT 'INTERNAL') RETURN NUMBER IS
    l_user   sec_user%ROWTYPE;
    l_party  NUMBER;
    l_member NUMBER;
    l_n      NUMBER;
    l_name   VARCHAR2(128) := UPPER(TRIM(p_username));
  BEGIN
    guard('SEC_USER_MEMBERSHIP.CREATE');
    NOONA_CORE_PKG.assert(REGEXP_LIKE(l_name, '^[A-Z][A-Z0-9_.@-]{2,99}$'), 'NOONA-SEC-200',
      'اسم المستخدم يبدأ بحرف ويتكون من 3 أحرف على الأقل (حروف إنجليزية وأرقام و _ . @ -)', 'Invalid username');
    NOONA_CORE_PKG.assert(p_is_tenant_admin = 'N' OR NOONA_CTX_PKG.is_tenant_admin = 'Y', 'NOONA-SEC-201',
      'تعيين مسؤول مؤسسة جديد مقصور على مسؤول المؤسسة', 'Only a tenant admin can create another tenant admin');
    NOONA_CORE_PKG.begin_system;
    BEGIN
      SELECT * INTO l_user FROM sec_user WHERE username = l_name;
      -- مستخدم موجود (عضو في مؤسسة أخرى): لا يسمح بتغيير نوعه إلى/من مسؤول منصة
      NOONA_CORE_PKG.assert(l_user.user_type NOT IN ('PLATFORM_ADMIN', 'SERVICE', 'INTEGRATION', 'BREAK_GLASS'),
        'NOONA-SEC-202', 'لا يمكن ربط هذا الحساب بالمؤسسة', 'This account cannot be linked to a tenant');
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO sec_user (username, email, display_name, user_type, preferred_language, mfa_required, status_code)
      VALUES (l_name, LOWER(p_email), p_display_name,
              CASE WHEN p_is_tenant_admin = 'Y' THEN 'TENANT_ADMIN' ELSE 'EMPLOYEE' END, 'ar', 'N', 'ACTIVE')
      RETURNING id, username INTO l_user.id, l_user.username;
    END;
    NOONA_CORE_PKG.end_system;

    SELECT COUNT(*) INTO l_n FROM sec_user_membership WHERE user_id = l_user.id;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-SEC-203', 'المستخدم عضو في هذه المؤسسة بالفعل', 'User is already a member');
    INSERT INTO pty_party (party_no, party_type, display_name_ar)
    VALUES ('U-' || l_name, 'PERSON', p_display_name)
    RETURNING id INTO l_party;
    INSERT INTO sec_user_membership (user_id, person_party_id, default_company_id, default_branch_id, clearance_level,
                                     is_tenant_admin, status_code)
    VALUES (l_user.id, l_party, p_company_id, p_branch_id, NVL(p_clearance, 'INTERNAL'), NVL(p_is_tenant_admin, 'N'), 'ACTIVE')
    RETURNING id INTO l_member;
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_USER_MEMBERSHIP', l_member, 'CREATE_USER', 'SUCCESS',
                              p_new_values => '{"username":' || NOONA_CORE_PKG.json_text(l_name) || '}');
    RETURN l_member;
  EXCEPTION
    WHEN OTHERS THEN
      NOONA_CORE_PKG.end_system;
      RAISE;
  END create_user;

  PROCEDURE update_member(p_membership_id IN NUMBER, p_display_name IN VARCHAR2, p_email IN VARCHAR2,
                          p_company_id IN NUMBER, p_branch_id IN NUMBER, p_clearance IN VARCHAR2) IS
    l_user NUMBER;
  BEGIN
    guard('SEC_USER_MEMBERSHIP.UPDATE');
    SELECT user_id INTO l_user FROM sec_user_membership WHERE id = p_membership_id;    -- VPD: داخل المؤسسة فقط
    UPDATE sec_user_membership
       SET default_company_id = p_company_id, default_branch_id = p_branch_id, clearance_level = NVL(p_clearance, clearance_level)
     WHERE id = p_membership_id;
    NOONA_CORE_PKG.begin_system;
    UPDATE sec_user SET display_name = p_display_name, email = LOWER(p_email) WHERE id = l_user;
    NOONA_CORE_PKG.end_system;
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_USER_MEMBERSHIP', p_membership_id, 'UPDATE_USER', 'SUCCESS');
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END update_member;

  PROCEDURE set_member_status(p_membership_id IN NUMBER, p_status IN VARCHAR2, p_reason IN VARCHAR2) IS
  BEGIN
    guard('SEC_USER_MEMBERSHIP.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'SUSPENDED', 'ENDED'), 'NOONA-SEC-210', 'حالة غير صالحة', 'Invalid status');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-SEC-211', 'السبب إلزامي', 'Reason is required');
    NOONA_CORE_PKG.assert(p_membership_id <> NOONA_CTX_PKG.membership_id OR p_status = 'ACTIVE', 'NOONA-SEC-212',
      'لا يمكنك إيقاف حسابك بنفسك', 'You cannot suspend your own membership');
    UPDATE sec_user_membership
       SET status_code = p_status, effective_to = CASE WHEN p_status = 'ENDED' THEN TRUNC(SYSDATE) END
     WHERE id = p_membership_id;
    -- إنهاء الجلسات المفتوحة فوراً
    IF p_status <> 'ACTIVE' THEN
      UPDATE sec_session SET status_code = 'ENDED', ended_at = SYSTIMESTAMP, end_reason = 'MEMBERSHIP_' || p_status
       WHERE membership_id = p_membership_id AND status_code = 'ACTIVE';
    END IF;
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_USER_MEMBERSHIP', p_membership_id, 'STATUS_' || p_status, 'SUCCESS',
                              p_reason => p_reason);
  END set_member_status;

  FUNCTION create_role(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_name_en IN VARCHAR2 DEFAULT NULL,
                       p_role_type IN VARCHAR2 DEFAULT 'FUNCTIONAL', p_privileged IN VARCHAR2 DEFAULT 'N') RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    guard('SEC_ROLE.CREATE');
    NOONA_CORE_PKG.assert(p_role_type NOT IN ('PLATFORM', 'SUPPORT'), 'NOONA-SEC-220',
      'نوع الدور مقصور على المنصة', 'Role type is reserved for the platform');
    INSERT INTO sec_role (code, name_ar, name_en, role_type, is_privileged, status_code)
    VALUES (UPPER(p_code), p_name_ar, p_name_en, p_role_type, NVL(p_privileged, 'N'), 'ACTIVE')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_ROLE', l_id, 'CREATE_ROLE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-SEC-221', 'رمز الدور مستخدم', 'Role code already exists');
  END create_role;

  PROCEDURE set_role_status(p_role_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('SEC_ROLE.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('DRAFT', 'ACTIVE', 'RETIRED'), 'NOONA-SEC-222', 'حالة غير صالحة', 'Invalid status');
    UPDATE sec_role SET status_code = p_status WHERE id = p_role_id AND code <> 'TENANT_ADMIN';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-SEC-223', 'لا يمكن تغيير حالة دور مسؤول المؤسسة',
                          'Tenant admin role status cannot be changed');
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_ROLE', p_role_id, 'ROLE_' || p_status, 'SUCCESS');
  END set_role_status;

  FUNCTION add_module_permissions(p_role_id IN NUMBER, p_module_code IN VARCHAR2, p_actions IN VARCHAR2,
                                  p_effect IN VARCHAR2 DEFAULT 'ALLOW') RETURN NUMBER IS
    l_n NUMBER;
  BEGIN
    guard('SEC_ROLE_PERMISSION.CREATE');
    INSERT INTO sec_role_permission (role_id, permission_id, effect)
    SELECT p_role_id, p.id, p_effect
      FROM sec_permission p
     WHERE p.module_code = UPPER(p_module_code)
       AND p.is_active = 'Y'
       AND p.action_code <> 'CONFIGURE'
       AND INSTR(',' || UPPER(REPLACE(p_actions, ' ')) || ',', ',' || p.action_code || ',') > 0
       AND NOT EXISTS (SELECT 1 FROM sec_role_permission x WHERE x.role_id = p_role_id AND x.permission_id = p.id);
    l_n := SQL%ROWCOUNT;
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_ROLE', p_role_id, 'ADD_PERMISSIONS', 'SUCCESS',
      p_new_values => '{"module":' || NOONA_CORE_PKG.json_text(p_module_code) || ',"actions":' ||
                      NOONA_CORE_PKG.json_text(p_actions) || ',"count":' || l_n || '}');
    RETURN l_n;
  END add_module_permissions;

  PROCEDURE add_permission(p_role_id IN NUMBER, p_permission_code IN VARCHAR2, p_effect IN VARCHAR2 DEFAULT 'ALLOW') IS
    l_perm sec_permission%ROWTYPE;
  BEGIN
    guard('SEC_ROLE_PERMISSION.CREATE');
    BEGIN
      SELECT * INTO l_perm FROM sec_permission WHERE permission_code = UPPER(p_permission_code) AND is_active = 'Y';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-SEC-230', 'صلاحية غير معروفة: ' || p_permission_code, 'Unknown permission');
    END;
    NOONA_CORE_PKG.assert(l_perm.action_code <> 'CONFIGURE', 'NOONA-SEC-231',
      'صلاحيات إعداد المنصة لا تمنح لأدوار المؤسسة', 'Platform configuration permissions cannot be granted');
    MERGE INTO sec_role_permission x
    USING (SELECT p_role_id role_id, l_perm.id permission_id FROM dual) s
       ON (x.role_id = s.role_id AND x.permission_id = s.permission_id)
     WHEN MATCHED THEN UPDATE SET x.effect = p_effect
     WHEN NOT MATCHED THEN INSERT (role_id, permission_id, effect) VALUES (s.role_id, s.permission_id, p_effect);
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_ROLE', p_role_id, 'ADD_PERMISSION:' || l_perm.permission_code, 'SUCCESS');
  END add_permission;

  PROCEDURE remove_permission(p_role_permission_id IN NUMBER) IS
    l_role NUMBER;
  BEGIN
    guard('SEC_ROLE_PERMISSION.DELETE');
    SELECT role_id INTO l_role FROM sec_role_permission WHERE id = p_role_permission_id;
    DELETE FROM sec_role_permission WHERE id = p_role_permission_id;
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_ROLE', l_role, 'REMOVE_PERMISSION', 'SUCCESS');
  END remove_permission;

  FUNCTION grant_role(p_membership_id IN NUMBER, p_role_id IN NUMBER, p_company_id IN NUMBER DEFAULT NULL,
                      p_reason IN VARCHAR2 DEFAULT NULL, p_effective_to IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_role  sec_role%ROWTYPE;
    l_grant NUMBER;
  BEGIN
    guard('SEC_ROLE_GRANT.CREATE');
    SELECT * INTO l_role FROM sec_role WHERE id = p_role_id;
    NOONA_CORE_PKG.assert(l_role.status_code = 'ACTIVE', 'NOONA-SEC-240', 'الدور غير نشط', 'Role is not active');
    NOONA_CORE_PKG.assert(l_role.is_privileged = 'N' OR NOONA_CTX_PKG.is_tenant_admin = 'Y', 'NOONA-SEC-241',
      'الأدوار المميزة يمنحها مسؤول المؤسسة فقط', 'Privileged roles can only be granted by a tenant admin');
    INSERT INTO sec_role_grant (membership_id, role_id, grant_source, reason, requested_by, approved_by, status_code,
                                effective_to)
    VALUES (p_membership_id, p_role_id, 'MANUAL', p_reason, NOONA_CTX_PKG.current_user_name,
            NOONA_CTX_PKG.current_user_name, 'ACTIVE', p_effective_to)
    RETURNING id INTO l_grant;
    INSERT INTO sec_data_scope (role_grant_id, scope_type, company_id)
    VALUES (l_grant, CASE WHEN p_company_id IS NULL THEN 'ALL_TENANT' ELSE 'COMPANY' END, p_company_id);
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_ROLE_GRANT', l_grant, 'GRANT:' || l_role.code, 'SUCCESS',
                              p_reason => p_reason);
    RETURN l_grant;
  END grant_role;

  PROCEDURE revoke_grant(p_grant_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_g    sec_role_grant%ROWTYPE;
    l_code sec_role.code%TYPE;
    l_n    NUMBER;
  BEGIN
    guard('SEC_ROLE_GRANT.UPDATE');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-SEC-211', 'السبب إلزامي', 'Reason is required');
    SELECT * INTO l_g FROM sec_role_grant WHERE id = p_grant_id FOR UPDATE;
    SELECT code INTO l_code FROM sec_role WHERE id = l_g.role_id;
    IF l_code = 'TENANT_ADMIN' THEN
      SELECT COUNT(*) INTO l_n FROM sec_role_grant g JOIN sec_user_membership m ON m.id = g.membership_id
       WHERE g.role_id = l_g.role_id AND g.status_code = 'ACTIVE' AND m.status_code = 'ACTIVE' AND g.id <> p_grant_id;
      NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-SEC-242', 'لا يمكن سحب آخر منح لدور مسؤول المؤسسة',
                            'Cannot revoke the last tenant admin grant');
    END IF;
    UPDATE sec_role_grant SET status_code = 'REVOKED', effective_to = TRUNC(SYSDATE), reason = SUBSTR(reason || ' | ' || p_reason, 1, 1000)
     WHERE id = p_grant_id;
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_ROLE_GRANT', p_grant_id, 'REVOKE:' || l_code, 'SUCCESS', p_reason => p_reason);
  END revoke_grant;

  PROCEDURE set_password(p_membership_id IN NUMBER, p_password IN VARCHAR2) IS
    l_member sec_user_membership%ROWTYPE;
    l_user   sec_user%ROWTYPE;
    l_n      NUMBER;
  BEGIN
    guard('SEC_USER_MEMBERSHIP.UPDATE');
    SELECT * INTO l_member FROM sec_user_membership WHERE id = p_membership_id;      -- VPD: داخل المؤسسة فقط
    NOONA_CORE_PKG.assert(l_member.is_tenant_admin = 'N' OR NOONA_CTX_PKG.is_tenant_admin = 'Y', 'NOONA-SEC-251',
      'إعادة تعيين كلمة مرور مسؤول المؤسسة مقصورة على مسؤول المؤسسة', 'Only a tenant admin can reset a tenant admin password');
    NOONA_CORE_PKG.begin_system;
    SELECT * INTO l_user FROM sec_user WHERE id = l_member.user_id;
    SELECT COUNT(*) INTO l_n FROM sec_user_membership WHERE user_id = l_member.user_id AND tenant_id <> l_member.tenant_id;
    NOONA_CORE_PKG.end_system;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-SEC-252',
      'الحساب مشترك مع مؤسسة أخرى؛ تعاد كلمة مروره من إدارة المنصة', 'Account is shared with another tenant; reset it from the platform');
    NOONA_APEX_PKG.assert_password_policy(l_user.username, p_password);
    store_password(l_user.id, p_password);
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_USER_MEMBERSHIP', p_membership_id, 'SET_PASSWORD', 'SUCCESS');
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END set_password;

  PROCEDURE change_password(p_old_password IN VARCHAR2, p_new_password IN VARCHAR2) IS
    l_user_id  NUMBER := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'USER_ID'));
    l_username sec_user.username%TYPE;
  BEGIN
    NOONA_CORE_PKG.assert(l_user_id IS NOT NULL, 'NOONA-SEC-001', 'لا توجد جلسة صالحة', 'No valid session');
    NOONA_CORE_PKG.begin_system;
    SELECT username INTO l_username FROM sec_user WHERE id = l_user_id;
    NOONA_CORE_PKG.end_system;
    NOONA_CORE_PKG.assert(NOONA_APEX_PKG.check_password(l_username, p_old_password) = 'OK', 'NOONA-SEC-253',
      'كلمة المرور الحالية غير صحيحة', 'Current password is incorrect');
    NOONA_APEX_PKG.assert_password_policy(l_username, p_new_password);
    store_password(l_user_id, p_new_password);
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_USER', l_user_id, 'CHANGE_PASSWORD', 'SUCCESS');
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END change_password;

END NOONA_SEC_ADMIN_PKG;
/
