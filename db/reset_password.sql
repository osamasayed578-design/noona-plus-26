-- =============================================================================
-- NOONA PLUS ERP | إعادة تعيين كلمة مرور مستخدم وفك قفله (يشغل بحساب NOONA_OWNER)
--   sqlplus NOONA_OWNER@//host:1521/PDB @reset_password.sql USERNAME NewPassword
-- كلمة المرور: 10 أحرف على الأقل، حرف كبير وصغير ورقم، ولا تحتوي اسم المستخدم.
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== المستخدمون الحاليون
COLUMN username FORMAT A30
COLUMN user_type FORMAT A16
COLUMN status_code FORMAT A12
COLUMN locked FORMAT A6
COLUMN local_pwd FORMAT A9
SELECT u.username, u.user_type, u.status_code, CASE WHEN u.locked_until > SYSTIMESTAMP THEN 'Y' ELSE 'N' END locked,
       CASE WHEN EXISTS (SELECT 1 FROM sec_credential c WHERE c.user_id = u.id AND c.credential_type = 'PASSWORD' AND c.status_code = 'ACTIVE')
            THEN 'Y' ELSE 'N' END local_pwd
  FROM sec_user u ORDER BY u.user_type, u.username;

DECLARE
  l_user sec_user%ROWTYPE;
  l_salt VARCHAR2(32) := RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(16));
  l_pwd  VARCHAR2(200) := '&2';
BEGIN
  NOONA_CORE_PKG.begin_system;
  BEGIN
    SELECT * INTO l_user FROM sec_user WHERE username = UPPER(TRIM('&1'));
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-SEC-256: اسم الدخول غير موجود: ' || UPPER(TRIM('&1')) || ' (انظر قائمة المستخدمين أعلاه)');
  END;
  NOONA_APEX_PKG.assert_password_policy(l_user.username, l_pwd);
  UPDATE sec_credential SET status_code = 'REVOKED' WHERE user_id = l_user.id AND credential_type = 'PASSWORD' AND status_code = 'ACTIVE';
  INSERT INTO sec_credential (user_id, credential_type, secret_hash, hash_algorithm, salt, last_changed_at, status_code)
  VALUES (l_user.id, 'PASSWORD', NOONA_APEX_PKG.hash_password(l_pwd, l_salt, 20000), 'PBKDF2-SHA256-20000', l_salt, SYSTIMESTAMP, 'ACTIVE');
  UPDATE sec_user SET failed_logins = 0, locked_until = NULL, status_code = 'ACTIVE',
         expires_at = CASE WHEN expires_at < SYSTIMESTAMP THEN NULL ELSE expires_at END
   WHERE id = l_user.id;
  NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_USER', l_user.id, 'RESET_PASSWORD_SCRIPT', 'SUCCESS');
  NOONA_CORE_PKG.end_system;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('تم: كلمة مرور ' || l_user.username || ' جديدة، والحساب مفعل وغير مقفل. ادخل من رابط NOONA_MASTER.');
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  ROLLBACK;
  RAISE;
END;
/
EXIT
