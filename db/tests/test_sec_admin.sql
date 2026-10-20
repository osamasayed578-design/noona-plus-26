-- =============================================================================
-- NOONA PLUS ERP | اختبار إدارة المستخدمين والأدوار (NOONA_SEC_ADMIN_PKG) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_sec_admin.sql
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
  l_mem  NUMBER;
  l_role NUMBER;
  l_n    NUMBER;
  l_g    NUMBER;
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

  BEGIN l_mem := NOONA_SEC_ADMIN_PKG.create_user('1bad', 'x', 'x@x', l_co); ok('invalid username rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid username rejected', 'NOONA-SEC-200', SQLERRM); END;

  l_mem := NOONA_SEC_ADMIN_PKG.create_user('U' || l_sfx, 'مستخدم اختبار', 'u' || l_sfx || '@demo.local', l_co);
  ok('user + membership created', l_mem IS NOT NULL);
  BEGIN l_n := NOONA_SEC_ADMIN_PKG.create_user('U' || l_sfx, 'x', 'x@x', l_co); ok('duplicate membership rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate membership rejected', 'NOONA-SEC-203', SQLERRM); END;

  BEGIN l_n := NOONA_SEC_ADMIN_PKG.create_role('P' || l_sfx, 'x', p_role_type => 'PLATFORM'); ok('platform role type blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('platform role type blocked', 'NOONA-SEC-220', SQLERRM); END;
  l_role := NOONA_SEC_ADMIN_PKG.create_role('R' || l_sfx, 'محاسب عام');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,CREATE');
  ok('module permissions added (GL VIEW,CREATE)', l_n > 0, l_n);
  SELECT COUNT(*) INTO l_n FROM sec_role_permission rp JOIN sec_permission p ON p.id = rp.permission_id
   WHERE rp.role_id = l_role AND p.action_code NOT IN ('VIEW', 'CREATE');
  ok('only requested actions added', l_n = 0, l_n);
  BEGIN NOONA_SEC_ADMIN_PKG.add_permission(l_role, 'PLT_TENANT.CONFIGURE'); ok('CONFIGURE permission blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('CONFIGURE permission blocked', 'NOONA-SEC-231', SQLERRM); END;

  l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, l_co, 'اختبار');
  SELECT scope_type INTO l_s FROM sec_data_scope WHERE role_grant_id = l_g;
  ok('grant with company data scope', l_s = 'COMPANY', l_s);
  NOONA_SEC_ADMIN_PKG.revoke_grant(l_g, 'انتهاء الحاجة');
  SELECT status_code INTO l_s FROM sec_role_grant WHERE id = l_g;
  ok('grant revoked', l_s = 'REVOKED', l_s);

  -- كلمات المرور المحلية
  BEGIN NOONA_SEC_ADMIN_PKG.set_password(l_mem, 'short1A'); ok('weak password rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('weak password rejected', 'NOONA-SEC-250', SQLERRM); END;
  BEGIN NOONA_SEC_ADMIN_PKG.set_password(l_mem, 'X' || 'U' || l_sfx || 'a1'); ok('password containing username rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('password containing username rejected', 'NOONA-SEC-250', SQLERRM); END;
  NOONA_SEC_ADMIN_PKG.set_password(l_mem, 'Noona#Pass2026');
  COMMIT;   -- check_password معاملة مستقلة (Autonomous) فلا ترى غير المحفوظ
  ok('correct password accepted', NOONA_APEX_PKG.check_password('u' || l_sfx, 'Noona#Pass2026') = 'OK');
  ok('wrong password rejected', NOONA_APEX_PKG.check_password('U' || l_sfx, 'Noona#Pass2025') = 'INVALID');
  FOR i IN 1 .. 4 LOOP l_s := NOONA_APEX_PKG.check_password('U' || l_sfx, 'bad'); END LOOP;
  l_s := NOONA_APEX_PKG.check_password('U' || l_sfx, 'Noona#Pass2026');
  ok('account locked after 5 failures', l_s = 'LOCKED', l_s);
  NOONA_SEC_ADMIN_PKG.set_password(l_mem, 'Noona#Pass2027');
  COMMIT;
  l_s := NOONA_APEX_PKG.check_password('U' || l_sfx, 'Noona#Pass2027');
  ok('admin reset unlocks account', l_s = 'OK', l_s);
  ok('old password revoked', NOONA_APEX_PKG.check_password('U' || l_sfx, 'Noona#Pass2026') = 'INVALID');
  ok('user without local password falls back', NOONA_APEX_PKG.check_password('ADMIN', 'x') = 'NO_LOCAL');
  ok('unknown user rejected', NOONA_APEX_PKG.check_password('NO_SUCH_USER_' || l_sfx, 'x') = 'INVALID');
  BEGIN EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM NOONA_OWNER.SEC_CREDENTIAL' INTO l_n; ok('app schema cannot read credentials', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('app schema cannot read credentials', SQLCODE IN (-942, -1031), SQLERRM); END;

  BEGIN NOONA_SEC_ADMIN_PKG.set_member_status(TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')), 'SUSPENDED', 'x');
        ok('cannot suspend own membership', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot suspend own membership', 'NOONA-SEC-212', SQLERRM); END;
  NOONA_SEC_ADMIN_PKG.set_member_status(l_mem, 'SUSPENDED', 'اختبار الإيقاف');
  SELECT status_code INTO l_s FROM sec_user_membership WHERE id = l_mem;
  ok('member suspended', l_s = 'SUSPENDED', l_s);

  -- آخر منح لدور مسؤول المؤسسة لا يُسحب
  SELECT MIN(g.id) INTO l_g FROM sec_role_grant g JOIN sec_role r ON r.id = g.role_id
   WHERE r.code = 'TENANT_ADMIN' AND g.status_code = 'ACTIVE'
     AND (SELECT COUNT(*) FROM sec_role_grant g2 WHERE g2.role_id = r.id AND g2.status_code = 'ACTIVE') = 1;
  IF l_g IS NOT NULL THEN
    BEGIN NOONA_SEC_ADMIN_PKG.revoke_grant(l_g, 'x'); ok('last tenant admin grant protected', FALSE);
    EXCEPTION WHEN OTHERS THEN expect('last tenant admin grant protected', 'NOONA-SEC-242', SQLERRM); END;
  ELSE
    ok('last tenant admin grant protected (several admins exist)', TRUE);
  END IF;

  SELECT COUNT(*) INTO l_n FROM aud_event WHERE entity_type IN ('SEC_ROLE', 'SEC_ROLE_GRANT', 'SEC_USER_MEMBERSHIP')
     AND created_at > SYSTIMESTAMP - INTERVAL '5' MINUTE;
  ok('security admin actions audited', l_n >= 5, l_n);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
  IF g_fail > 0 THEN RAISE_APPLICATION_ERROR(-20999, g_fail || ' test(s) failed'); END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
