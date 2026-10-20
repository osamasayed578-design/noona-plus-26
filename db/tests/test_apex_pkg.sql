-- =============================================================================
-- NOONA PLUS ERP | اختبار طبقة APEX (NOONA_APEX_PKG) بحساب مخطط التطبيق NOONA_APP
-- يحاكي دورة طلب APEX: Post-Auth ← Initialization ← صفحة ← Cleanup
-- المتطلبات: install.sql + synonyms + seed/90_demo_tenant_DEV_ONLY.sql
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_apex_pkg.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sess NUMBER := TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12));   -- رقم جلسة APEX وهمي
  l_n    NUMBER;
  l_s    VARCHAR2(4000);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN
      g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE
      g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;

  FUNCTION companies RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM org_company;
    RETURN l;
  END companies;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== NOONA_APEX_PKG tests as ' || USER);

  -- صفحة عامة (الدخول) قبل المصادقة
  NOONA_APEX_PKG.init_request('nobody', l_sess);
  ok('public page: no context, no error', NOONA_APEX_PKG.is_authenticated = 'N');
  ok('public page: VPD hides all companies', companies = 0);
  NOONA_APEX_PKG.init_request('ADMIN', l_sess);
  ok('authenticated but before post-auth: no error, no data', companies = 0);

  -- Post-Authentication
  NOONA_APEX_PKG.post_auth('admin', l_sess);
  ok('post_auth: tenant session established', NOONA_APEX_PKG.is_tenant_user = 'Y');
  ok('post_auth: tenant admin flag', NOONA_APEX_PKG.is_tenant_admin = 'Y');
  ok('post_auth: company context set', SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID') IS NOT NULL);
  ok('header: tenant name', NOONA_APEX_PKG.tenant_name IS NOT NULL, NOONA_APEX_PKG.tenant_name);
  ok('header: company name', NOONA_APEX_PKG.company_name IS NOT NULL, NOONA_APEX_PKG.company_name);
  ok('header: display name', NOONA_APEX_PKG.display_name IS NOT NULL);
  ok('authorization: allow ORG_COMPANY.VIEW', NOONA_APEX_PKG.allow('ORG_COMPANY.VIEW') = 'Y');
  ok('authorization: platform CONFIGURE denied to tenant admin', NOONA_APEX_PKG.allow('PLT_TENANT.CONFIGURE') = 'N');
  ok('data visible inside session', companies > 0, companies);
  COMMIT;   -- APEX يثبت نهاية الطلب

  -- Cleanup ثم طلب جديد على نفس الاتصال (Pool)
  NOONA_APEX_PKG.cleanup_request;
  ok('cleanup: context cleared, no data', companies = 0 AND NOONA_APEX_PKG.is_authenticated = 'N');
  NOONA_APEX_PKG.init_request('ADMIN', l_sess);
  ok('next request: session re-attached', NOONA_APEX_PKG.is_tenant_user = 'Y' AND companies > 0);
  NOONA_APEX_PKG.cleanup_request;

  -- جلسة APEX لمستخدم آخر لا تستطيع ركوب جلسة ADMIN
  NOONA_APEX_PKG.init_request('PLATFORM', l_sess);
  ok('session hijack by other username rejected', NOONA_APEX_PKG.is_authenticated = 'N' AND companies = 0);

  -- مستخدم غير مسجل في NOONA
  BEGIN
    NOONA_APEX_PKG.post_auth('NO_SUCH_USER_X', l_sess + 1);
    ok('post_auth: unknown user rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN
    ok('post_auth: unknown user rejected', INSTR(SQLERRM, 'NOONA-SEC-010') > 0, SQLERRM);
  END;

  -- مسؤول المنصة
  NOONA_APEX_PKG.post_auth('PLATFORM', l_sess + 2);
  ok('platform admin session', NOONA_APEX_PKG.is_platform_admin = 'Y' AND NOONA_APEX_PKG.is_tenant_user = 'N');
  ok('platform admin sees no tenant business data', companies = 0, companies);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.init_request('PLATFORM', l_sess + 2);
  ok('platform session re-attached', NOONA_APEX_PKG.is_platform_admin = 'Y');
  NOONA_APEX_PKG.cleanup_request;

  -- تسجيل الخروج ينهي الجلسة
  NOONA_APEX_PKG.init_request('ADMIN', l_sess);
  NOONA_APEX_PKG.logout;
  COMMIT;
  NOONA_APEX_PKG.init_request('ADMIN', l_sess);
  ok('after logout the APEX session cannot re-attach', NOONA_APEX_PKG.is_authenticated = 'N');
  NOONA_APEX_PKG.cleanup_request;

  -- مخطط التطبيق لا يملك حزم تجاوز العزل
  BEGIN
    EXECUTE IMMEDIATE 'BEGIN NOONA_CTX_PKG.enable_system_mode; END;';
    ok('NOONA_APP cannot call NOONA_CTX_PKG', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('NOONA_APP cannot call NOONA_CTX_PKG', SQLCODE IN (-6550, -201), SQLERRM);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'BEGIN NOONA_CORE_PKG.begin_system; END;';
    ok('NOONA_APP cannot call NOONA_CORE_PKG', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('NOONA_APP cannot call NOONA_CORE_PKG', SQLCODE IN (-6550, -201), SQLERRM);
  END;

  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
  IF g_fail > 0 THEN
    RAISE_APPLICATION_ERROR(-20999, g_fail || ' test(s) failed');
  END IF;
END;
/
EXIT
