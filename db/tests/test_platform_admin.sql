-- =============================================================================
-- NOONA PLUS ERP | اختبار لوحة المنصة (NOONA_PLATFORM_ADMIN_PKG) وظهور الأنظمة حسب الاشتراك، بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_platform_admin.sql
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
  g_pass   PLS_INTEGER := 0;
  g_fail   PLS_INTEGER := 0;
  l_tenant NUMBER;
  l_gl     NUMBER;
  l_inv    NUMBER;
  l_c      CLOB;
  l_s      VARCHAR2(4000);
  l_n      NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
BEGIN
  -- مستخدم مؤسسة لا يستخدم لوحة المنصة
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_tenant := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID'));
  ok('tenant metric hidden from tenant users', NOONA_PLATFORM_ADMIN_PKG.tenant_metric(l_tenant, 'USERS') IS NULL);
  BEGIN l_c := NOONA_PLATFORM_ADMIN_PKG.platform_summary; ok('platform summary blocked for tenant users', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('platform summary blocked for tenant users', SQLCODE IN (-20100, -20001, -20500), SQLERRM); END;
  SELECT COUNT(*) INTO l_n FROM noona_v_apps WHERE app_alias = 'NOONA_FIN';
  ok('finance visible to tenant admin before subscription rows', l_n = 1);
  NOONA_APEX_PKG.cleanup_request;

  -- مسؤول المنصة
  NOONA_APEX_PKG.post_auth('PLATFORM', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  ok('platform session', SYS_CONTEXT('NOONA_CTX', 'PLATFORM_ADMIN') = 'Y');
  l_c := NOONA_PLATFORM_ADMIN_PKG.platform_summary;
  ok('platform summary renders', INSTR(l_c, 'nn-kpi') > 0);
  ok('tenant metric for platform admin', TO_NUMBER(NOONA_PLATFORM_ADMIN_PKG.tenant_metric(l_tenant, 'USERS')) > 0);
  ok('system mode closed after metric', NVL(SYS_CONTEXT('NOONA_CTX', 'SYSTEM_MODE'), 'N') = 'N');
  SELECT id INTO l_gl FROM plt_module WHERE module_code = 'GL';
  SELECT id INTO l_inv FROM plt_module WHERE module_code = 'INV';
  l_s := NOONA_PLATFORM_ADMIN_PKG.set_tenant_modules(l_tenant, TO_CHAR(l_gl));
  ok('subscription saved', l_s LIKE '%:%', l_s);
  BEGIN l_s := NOONA_PLATFORM_ADMIN_PKG.set_tenant_modules(l_tenant, '1) or (1=1'); ok('invalid module list rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid module list rejected', 'NOONA-PLT-301', SQLERRM); END;
  l_c := NOONA_PLATFORM_ADMIN_PKG.module_matrix(l_tenant);
  ok('module matrix shows GL checked', REGEXP_LIKE(l_c, 'value="' || l_gl || '" checked'));
  ok('module matrix shows INV unchecked', NOT REGEXP_LIKE(l_c, 'value="' || l_inv || '" checked'));
  ok('platform audit chain intact', NOONA_PLATFORM_ADMIN_PKG.verify_tenant_chain(NULL) IS NULL);
  -- حدود الاشتراك
  l_n := TO_NUMBER(NOONA_PLATFORM_ADMIN_PKG.tenant_metric(l_tenant, 'USERS'));
  BEGIN NOONA_PLATFORM_ADMIN_PKG.set_tenant_limit(l_tenant, 'USERS', l_n - 1); ok('limit below usage rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('limit below usage rejected', 'NOONA-PLT-304', SQLERRM); END;
  NOONA_PLATFORM_ADMIN_PKG.set_tenant_limit(l_tenant, 'USERS', l_n);
  ok('user limit saved', NOONA_PLATFORM_ADMIN_PKG.tenant_limit(l_tenant, 'USERS') = l_n);
  NOONA_APEX_PKG.cleanup_request;

  -- المؤسسة ترى المالية فقط من الأنظمة غير الأساسية
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT COUNT(*) INTO l_n FROM noona_v_apps WHERE app_alias = 'NOONA_FIN';
  ok('subscribed system visible', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM noona_v_apps WHERE app_alias IN ('NOONA_SCM', 'NOONA_HR', 'NOONA_MFG');
  ok('unsubscribed systems hidden', l_n = 0, l_n);
  BEGIN l_n := NOONA_SEC_ADMIN_PKG.create_user('LIM' || TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3'), 'x', 'lim@x.local',
                                                TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')));
        ok('user limit enforced for tenant admin', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('user limit enforced for tenant admin', 'NOONA-PLT-020', SQLERRM); END;
  l_c := NOONA_UI_PKG.admin_summary('1');
  ok('admin dashboard shows the limit', INSTR(l_c, 'الحد ') > 0);
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
