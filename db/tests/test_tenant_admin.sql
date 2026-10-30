-- =============================================================================
-- NOONA PLUS ERP | اختبار فصل إدارة المنصة عن إدارة المؤسسة، بحساب NOONA_APP
--   * مسؤول المؤسسة يعين مسؤول شركة؛ مسؤول الشركة يدير مستخدمي شركته وفروعها فقط وبأدوار غير مميزة
--   * المنصة: الاشتراك (باقة وفترة وتجديد)، قواعد الانتهاء (سماح ← قراءة فقط ← تعليق)، المؤشرات،
--     ولا يرى مسؤول المنصة بيانات أعمال المؤسسات
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_tenant_admin.sql
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
  g_pass  PLS_INTEGER := 0;
  g_fail  PLS_INTEGER := 0;
  l_sfx   VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3');
  l_co1   NUMBER;
  l_co2   NUMBER;
  l_br1   NUMBER;
  l_ca    NUMBER;     -- عضوية مسؤول الشركة
  l_u1    NUMBER;     -- مستخدم في الشركة 1
  l_u2    NUMBER;     -- مستخدم في الشركة 2
  l_adm   NUMBER;     -- عضوية مسؤول المؤسسة
  l_role  NUMBER;
  l_cadm  NUMBER;
  l_tadm  NUMBER;
  l_g     NUMBER;
  l_t     NUMBER;
  l_n     NUMBER;
  l_s     VARCHAR2(4000);
  l_c     CLOB;
  l_d     DATE;
  l_d0    DATE;

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
  FUNCTION tstatus(p_tenant NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT status_code INTO l FROM plt_tenant WHERE id = p_tenant; RETURN l;
  END tstatus;
  FUNCTION scope_of(p_grant NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT scope_type || ':' || company_id || ':' || scope_value_id INTO l FROM sec_data_scope WHERE role_grant_id = p_grant; RETURN l;
  END scope_of;
BEGIN
  -- ======================================================== مسؤول المؤسسة يعين مسؤول شركة
  login('ADMIN');
  l_adm := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'));
  ok('tenant admin level', NOONA_SEC_ADMIN_PKG.admin_level = 'TENANT' AND NOONA_SEC_ADMIN_PKG.is_org_admin = 'Y');
  SELECT MIN(id) INTO l_co1 FROM org_company WHERE status_code NOT IN ('CLOSED', 'ARCHIVED');
  l_co2 := NOONA_PLATFORM_PKG.create_company('TCO' || l_sfx, 'شركة ثانية اختبار', 'Second test co', 'SA', 'SAR');
  ok('tenant admin administers every company', NOONA_SEC_ADMIN_PKG.can_admin_company(l_co1) = 'Y'
     AND NOONA_SEC_ADMIN_PKG.can_admin_company(l_co2) = 'Y');
  SELECT id INTO l_cadm FROM sec_role WHERE code = 'COMPANY_ADMIN';
  SELECT id INTO l_tadm FROM sec_role WHERE code = 'TENANT_ADMIN';
  SELECT is_privileged INTO l_s FROM sec_role WHERE id = l_cadm;
  ok('company admin role exists and is privileged', l_s = 'Y');
  l_ca := NOONA_SEC_ADMIN_PKG.create_user('CA' || l_sfx, 'مسؤول شركة اختبار', 'ca' || l_sfx || '@noona.test', l_co1);
  l_u2 := NOONA_SEC_ADMIN_PKG.create_user('UB' || l_sfx, 'موظف الشركة الثانية', 'ub' || l_sfx || '@noona.test', l_co2);
  BEGIN
    l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_ca, l_cadm, NULL, 'بدون شركة');
    ok('company admin role needs a company scope', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('company admin role needs a company scope', 'NOONA-SEC-245', SQLERRM); END;
  l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_ca, l_cadm, l_co1, 'مسؤول الشركة الأولى');
  ok('company admin granted on company 1', scope_of(l_g) = 'COMPANY:' || l_co1 || ':', scope_of(l_g));
  l_role := NOONA_SEC_ADMIN_PKG.create_role('TR' || l_sfx, 'دور وظيفي اختبار');
  COMMIT;

  -- ======================================================== مسؤول الشركة: داخل شركته وفروعها فقط
  login('CA' || l_sfx);
  ok('company admin level', NOONA_SEC_ADMIN_PKG.admin_level = 'COMPANY' AND NOONA_SEC_ADMIN_PKG.is_org_admin = 'Y');
  ok('administration app visible to company admin', NOONA_PORTAL_PKG.app_visible('NOONA_ADMIN', NULL) = 'Y');
  ok('company scope: own company only', NOONA_SEC_ADMIN_PKG.can_admin_company(l_co1) = 'Y'
     AND NOONA_SEC_ADMIN_PKG.can_admin_company(l_co2) = 'N');
  l_u1 := NOONA_SEC_ADMIN_PKG.create_user('UA' || l_sfx, 'موظف الشركة الأولى', 'ua' || l_sfx || '@noona.test', l_co1);
  ok('company admin creates users in own company', l_u1 IS NOT NULL);
  BEGIN
    l_n := NOONA_SEC_ADMIN_PKG.create_user('UX' || l_sfx, 'خارج النطاق', 'ux' || l_sfx || '@noona.test', l_co2);
    ok('cannot create users in another company', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot create users in another company', 'NOONA-SEC-260', SQLERRM); END;
  BEGIN
    l_n := NOONA_SEC_ADMIN_PKG.create_user('UY' || l_sfx, 'مسؤول مؤسسة', 'uy' || l_sfx || '@noona.test', l_co1, NULL, 'Y');
    ok('cannot create a tenant admin', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot create a tenant admin', 'NOONA-SEC-201', SQLERRM); END;
  l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_u1, l_role, l_co1, 'صلاحيات الشركة');
  ok('grant with company scope', scope_of(l_g) = 'COMPANY:' || l_co1 || ':', scope_of(l_g));
  SELECT MIN(id) INTO l_br1 FROM org_branch WHERE company_id = l_co1 AND status_code <> 'CLOSED';
  IF l_br1 IS NOT NULL THEN
    l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_u1, l_role, NULL, 'صلاحيات الفرع', NULL, l_br1);
    ok('grant with branch scope', scope_of(l_g) = 'BRANCH:' || l_co1 || ':' || l_br1, scope_of(l_g));
  END IF;
  BEGIN
    l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_u1, l_role, NULL, 'كل المؤسسة');
    ok('tenant-wide scope refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('tenant-wide scope refused', 'NOONA-SEC-244', SQLERRM); END;
  BEGIN
    l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_u1, l_tadm, l_co1, 'ترقية');
    ok('privileged roles refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('privileged roles refused', 'NOONA-SEC-241', SQLERRM); END;
  BEGIN
    l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_u2, l_role, l_co1, 'مستخدم شركة أخرى');
    ok('users of another company are out of scope', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('users of another company are out of scope', 'NOONA-SEC-261', SQLERRM); END;
  BEGIN
    NOONA_SEC_ADMIN_PKG.set_member_status(l_u2, 'SUSPENDED', 'اختبار');
    ok('cannot suspend another company user', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot suspend another company user', 'NOONA-SEC-261', SQLERRM); END;
  BEGIN
    NOONA_SEC_ADMIN_PKG.set_password(l_adm, 'Strong#Pass2026x');
    ok('cannot reset the tenant admin password', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('cannot reset the tenant admin password', INSTR(SQLERRM, 'NOONA-SEC-251') > 0 OR INSTR(SQLERRM, 'NOONA-SEC-261') > 0, SQLERRM); END;
  BEGIN
    l_n := NOONA_PLATFORM_PKG.create_branch(l_co2, 'XB' || SUBSTR(l_sfx, 1, 6), 'فرع خارج النطاق', 'Out', 'BRANCH');
    ok('cannot add branches to another company', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('cannot add branches to another company', INSTR(SQLERRM, 'NOONA-SEC-260') > 0 OR INSTR(SQLERRM, 'NOONA-SEC-100') > 0, SQLERRM); END;
  BEGIN
    l_n := NOONA_PLATFORM_PKG.create_company('XC' || l_sfx, 'شركة', 'Co', 'SA', 'SAR');
    ok('company admin cannot create companies', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('company admin cannot create companies', 'NOONA-SEC-100', SQLERRM); END;
  l_c := NOONA_SEC_ADMIN_PKG.subscription_html;
  ok('company admin sees the subscription and limits', INSTR(l_c, 'الباقة') > 0 AND INSTR(l_c, 'المستخدمون النشطون') > 0);
  BEGIN
    l_n := NOONA_PLATFORM_ADMIN_PKG.apply_expiry;
    ok('expiry rules cannot run from a tenant session', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('expiry rules cannot run from a tenant session', 'NOONA-PLT-325', SQLERRM); END;

  -- مستخدم عادي لا يرى الإدارة
  login('UA' || l_sfx);
  ok('regular user: no administration', NOONA_SEC_ADMIN_PKG.is_org_admin = 'N' AND NOONA_PORTAL_PKG.app_visible('NOONA_ADMIN', NULL) = 'N');
  BEGIN
    l_c := NOONA_SEC_ADMIN_PKG.subscription_html;
    ok('regular user cannot read the subscription', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('regular user cannot read the subscription', 'NOONA-SEC-262', SQLERRM); END;

  -- ======================================================== المنصة: الاشتراكات دون بيانات الأعمال
  login('PLATFORM');
  SELECT COUNT(*) INTO l_n FROM org_company;
  ok('platform admin sees no company business data', l_n = 0, l_n);
  SELECT COUNT(*) INTO l_n FROM sec_user_membership;
  ok('platform admin sees no tenant users', l_n = 0, l_n);
  BEGIN
    l_n := NOONA_SEC_ADMIN_PKG.create_user('PZ' || l_sfx, 'x', 'x@x', l_co1);
    ok('platform admin cannot manage tenant users', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('platform admin cannot manage tenant users', SQLERRM LIKE '%NOONA-%', SQLERRM); END;
  l_t := NOONA_PLATFORM_PKG.provision_tenant(
           p_tenant_code => 'SB' || l_sfx, p_tenant_slug => 'sub-' || l_sfx, p_name_ar => 'مؤسسة اشتراك اختبار', p_name_en => 'Sub test',
           p_country_code => 'SA', p_base_currency => 'SAR', p_admin_username => 'SBADM' || l_sfx,
           p_admin_email => 'sb' || l_sfx || '@noona.test', p_admin_name => 'مسؤول', p_company_code => 'SB-CO',
           p_company_name_ar => 'شركة الاشتراك', p_idempotency_key => 'SUB-' || l_sfx, p_is_trial => 'Y');
  login('SBADM' || l_sfx);
  SELECT COUNT(*) INTO l_n FROM sec_role WHERE code = 'COMPANY_ADMIN';
  ok('provisioning creates the company admin role', l_n = 1, l_n);
  login('PLATFORM');
  ok('new tenant without subscription', NOONA_PLATFORM_ADMIN_PKG.sub_info(l_t, 'END') IS NULL);
  -- تجربة انتهت منذ 27 يوماً: قراءة فقط
  l_n := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_t, 'TRIAL', TRUNC(SYSDATE) - 40, 1, NULL, 'تجربة');
  ok('trial registered (14 days)', NOONA_PLATFORM_ADMIN_PKG.sub_info(l_t, 'END') = TO_CHAR(TRUNC(SYSDATE) - 27, 'YYYY-MM-DD')
     AND NOONA_PLATFORM_ADMIN_PKG.sub_info(l_t, 'STATUS') = 'TRIAL', NOONA_PLATFORM_ADMIN_PKG.sub_info(l_t, 'END'));
  l_n := NOONA_PLATFORM_ADMIN_PKG.apply_expiry;
  ok('expired trial becomes read-only', tstatus(l_t) = 'READ_ONLY', tstatus(l_t));
  BEGIN
    l_d := NOONA_PLATFORM_ADMIN_PKG.renew_subscription(l_t, 1);
    ok('a trial is not renewed (choose a paid plan)', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('a trial is not renewed (choose a paid plan)', 'NOONA-PLT-324', SQLERRM); END;
  -- اشتراك شهري من اليوم: يعاد التفعيل
  l_n := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_t, 'MONTHLY', TRUNC(SYSDATE), 1, NULL, 'تحويل لمدفوع');
  ok('paid subscription reactivates the tenant', tstatus(l_t) = 'ACTIVE'
     AND NOONA_PLATFORM_ADMIN_PKG.sub_info(l_t, 'END') = TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), 1) - 1, 'YYYY-MM-DD'), tstatus(l_t));
  ok('plan shown', NOONA_PLATFORM_ADMIN_PKG.sub_info(l_t, 'PLAN') = 'اشتراك شهري');
  -- سنوي انتهى منذ 10 أيام: فترة سماح
  l_n := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_t, 'ANNUAL', ADD_MONTHS(TRUNC(SYSDATE) - 9, -12), 1, NULL, 'بيانات تاريخية');
  l_n := NOONA_PLATFORM_ADMIN_PKG.apply_expiry;
  ok('expired paid subscription enters the grace period', tstatus(l_t) = 'GRACE_PERIOD'
     AND NOONA_PLATFORM_ADMIN_PKG.sub_info(l_t, 'STATUS') = 'GRACE_PERIOD', tstatus(l_t));
  -- انتهى منذ 100 يوم: تعليق (عبر القراءة فقط)
  l_n := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_t, 'ANNUAL', TRUNC(SYSDATE) - 465, 1, TRUNC(SYSDATE) - 100, 'بيانات تاريخية');
  ok('setting an already expired period does not reactivate', tstatus(l_t) = 'GRACE_PERIOD', tstatus(l_t));
  l_n := NOONA_PLATFORM_ADMIN_PKG.apply_expiry;
  ok('long expired subscription suspends the tenant', tstatus(l_t) = 'SUSPENDED', tstatus(l_t));
  l_d := NOONA_PLATFORM_ADMIN_PKG.renew_subscription(l_t, 2, 'QUARTERLY', 'تجديد ستة أشهر');
  ok('renewal from today reactivates', tstatus(l_t) = 'ACTIVE' AND l_d = ADD_MONTHS(TRUNC(SYSDATE), 6) - 1, tstatus(l_t) || ' ' || l_d);
  l_d0 := l_d;
  l_d := NOONA_PLATFORM_ADMIN_PKG.renew_subscription(l_t, 1);
  -- يكمل من اليوم التالي لنهاية الفترة السابقة: نفس اليوم بعد 3 أشهر ناقص يوم (دون قفزة آخر الشهر)
  ok('renewal of an active subscription continues from its end',
     l_d = LEAST(ADD_MONTHS(TRUNC(l_d0 + 1, 'MM'), 3) + (EXTRACT(DAY FROM l_d0 + 1) - 1), LAST_DAY(ADD_MONTHS(TRUNC(l_d0 + 1, 'MM'), 3))) - 1,
     TO_CHAR(l_d0, 'YYYY-MM-DD') || ' -> ' || TO_CHAR(l_d, 'YYYY-MM-DD'));
  l_c := NOONA_PLATFORM_ADMIN_PKG.subscription_history_html(l_t);
  ok('subscription history (activation, change, renewals)', INSTR(l_c, 'تفعيل') > 0 AND INSTR(l_c, 'تجديد') > 0 AND INSTR(l_c, 'تغيير الباقة') > 0);
  l_c := NOONA_PLATFORM_ADMIN_PKG.platform_summary;
  ok('platform dashboard: new, expiring, expired, renewals', INSTR(l_c, 'مشتركون جدد') > 0 AND INSTR(l_c, 'تنتهي خلال 30 يوماً') > 0
     AND INSTR(l_c, 'تجديدات هذا الشهر') > 0);

  ROLLBACK;
  -- تنظيف ما حفظ للاختبار (مسؤول الشركة والمستخدمون والدور والشركة الثانية)
  login('ADMIN');
  UPDATE sec_role_grant SET status_code = 'REVOKED' WHERE membership_id IN (l_ca, l_u2);
  UPDATE sec_user_membership SET status_code = 'ENDED' WHERE id IN (l_ca, l_u2);
  UPDATE sec_role SET status_code = 'RETIRED' WHERE id = l_role;
  UPDATE org_company SET status_code = 'ARCHIVED' WHERE id = l_co2;
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
