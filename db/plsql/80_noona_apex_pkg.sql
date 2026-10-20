-- =============================================================================
-- NOONA PLUS ERP | NOONA_APEX_PKG - طبقة الربط بين تطبيقات APEX 24.2 وخدمات الأمن
--   * post_auth     : بعد نجاح المصادقة؛ ينشئ جلسة NOONA (مؤسسة أو منصة) مرتبطة بجلسة APEX
--   * init_request  : Initialization PL/SQL لكل طلب؛ يربط سياق NOONA_CTX بجلسة APEX
--   * cleanup_request: Cleanup PL/SQL لكل طلب؛ يمسح السياق قبل إعادة الاتصال للـPool
--   * دوال قواعد الصلاحيات (Authorization Schemes) وبيانات العرض
-- لا تعتمد على كائنات APEX (تمرر قيم APP_USER و APP_SESSION كمعاملات) لتترجم في أي قاعدة.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_APEX_PKG AUTHID DEFINER AS

  -- Post-Authentication: يختار المؤسسة الأحدث استخداماً للمستخدم؛ أو جلسة منصة لمسؤول المنصة
  PROCEDURE post_auth(p_username        IN VARCHAR2,
                      p_apex_session_id IN NUMBER,
                      p_tenant_id       IN NUMBER   DEFAULT NULL,
                      p_ip_address      IN VARCHAR2 DEFAULT NULL);

  -- Initialization PL/SQL Code (كل طلب). صفحات عامة بلا جلسة NOONA تبقى بلا سياق (Default Deny)
  PROCEDURE init_request(p_username IN VARCHAR2, p_apex_session_id IN NUMBER);

  -- Cleanup PL/SQL Code (كل طلب)
  PROCEDURE cleanup_request;

  -- تسجيل الخروج: ينهي جلسة NOONA
  PROCEDURE logout;

  -- تبديل المؤسسة/الشركة من الواجهة
  PROCEDURE switch_tenant(p_username IN VARCHAR2, p_apex_session_id IN NUMBER, p_tenant_id IN NUMBER);
  PROCEDURE switch_company(p_company_id IN NUMBER, p_branch_id IN NUMBER DEFAULT NULL);

  -- قواعد الصلاحيات: 'Y' / 'N'
  FUNCTION is_authenticated   RETURN VARCHAR2;
  FUNCTION is_tenant_user     RETURN VARCHAR2;
  FUNCTION is_tenant_admin    RETURN VARCHAR2;
  FUNCTION is_platform_admin  RETURN VARCHAR2;
  FUNCTION allow(p_permission_code IN VARCHAR2, p_company_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

  -- بيانات العرض في رأس الصفحة
  FUNCTION tenant_name   RETURN VARCHAR2;
  FUNCTION company_name  RETURN VARCHAR2;
  FUNCTION display_name  RETURN VARCHAR2;

  -- عدد المؤسسات المتاحة للمستخدم (لإظهار مبدل المؤسسة)
  FUNCTION tenant_count(p_username IN VARCHAR2) RETURN NUMBER;

  -- تحقق صفحة الدخول قبل المصادقة: NULL = مسموح، وإلا رسالة عامة (لا تكشف سبب الرفض)
  FUNCTION login_block_reason(p_username IN VARCHAR2) RETURN VARCHAR2;
END NOONA_APEX_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_APEX_PKG AS

  c_allowed_tenant_states CONSTANT VARCHAR2(200) := ',TRIAL,ACTIVE,GRACE_PERIOD,READ_ONLY,SUSPENDED,';

  FUNCTION lang RETURN VARCHAR2 IS
  BEGIN
    RETURN NVL(SYS_CONTEXT('NOONA_CTX', 'LANGUAGE'), 'ar');
  END;

  -- المؤسسة الافتراضية: آخر مؤسسة دخلها المستخدم، ثم الأقدم عضوية
  FUNCTION default_tenant(p_user_id NUMBER) RETURN NUMBER IS
    l_tenant NUMBER;
  BEGIN
    SELECT tenant_id INTO l_tenant
      FROM (SELECT m.tenant_id,
                   (SELECT MAX(s.started_at) FROM sec_session s
                     WHERE s.user_id = m.user_id AND s.tenant_id = m.tenant_id) last_used,
                   m.id
              FROM sec_user_membership m
              JOIN plt_tenant t ON t.id = m.tenant_id
             WHERE m.user_id = p_user_id
               AND m.status_code = 'ACTIVE'
               AND TRUNC(SYSDATE) BETWEEN m.effective_from AND NVL(m.effective_to, DATE '9999-12-31')
               AND INSTR(c_allowed_tenant_states, ',' || t.status_code || ',') > 0
             ORDER BY last_used DESC NULLS LAST, m.id)
     WHERE ROWNUM = 1;
    RETURN l_tenant;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END default_tenant;

  PROCEDURE post_auth(p_username        IN VARCHAR2,
                      p_apex_session_id IN NUMBER,
                      p_tenant_id       IN NUMBER   DEFAULT NULL,
                      p_ip_address      IN VARCHAR2 DEFAULT NULL) IS
    l_user   sec_user%ROWTYPE;
    l_tenant NUMBER;
  BEGIN
    NOONA_CTX_PKG.clear_context;
    NOONA_CORE_PKG.begin_system;
    BEGIN
      SELECT * INTO l_user FROM sec_user WHERE username = UPPER(p_username);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.end_system;
      NOONA_CTX_PKG.clear_context;
      RAISE_APPLICATION_ERROR(-20100, 'NOONA-SEC-010: المستخدم غير مسجل في نظام نونا بلس / User is not registered in NOONA PLUS');
    END;
    l_tenant := CASE WHEN l_user.user_type = 'PLATFORM_ADMIN' THEN NULL
                     ELSE NVL(p_tenant_id, default_tenant(l_user.id)) END;
    NOONA_CORE_PKG.end_system;

    IF l_user.user_type = 'PLATFORM_ADMIN' THEN
      NOONA_SECURITY_PKG.establish_platform_session(p_username, p_apex_session_id, p_ip_address);
    ELSIF l_tenant IS NULL THEN
      NOONA_CTX_PKG.clear_context;
      RAISE_APPLICATION_ERROR(-20100, 'NOONA-SEC-013: لا توجد عضوية فعالة في أي مؤسسة / No active tenant membership');
    ELSE
      NOONA_SECURITY_PKG.establish_session(
        p_username        => p_username,
        p_tenant_id       => l_tenant,
        p_apex_session_id => p_apex_session_id,
        p_ip_address      => p_ip_address,
        p_auth_method     => 'APEX_ACCOUNTS');
    END IF;
  END post_auth;

  PROCEDURE init_request(p_username IN VARCHAR2, p_apex_session_id IN NUMBER) IS
  BEGIN
    NOONA_CORE_PKG.reset_system;
    IF p_username IS NULL OR UPPER(p_username) = 'NOBODY' OR p_apex_session_id IS NULL THEN
      NOONA_CTX_PKG.clear_context;
      RETURN;
    END IF;
    NOONA_SECURITY_PKG.attach_session(p_apex_session_id, p_username);
  EXCEPTION
    WHEN NOONA_SECURITY_PKG.e_access_denied THEN
      -- لا جلسة NOONA بعد (صفحة الدخول أو قبل Post-Auth) أو انتهت صلاحيتها: بلا سياق = لا بيانات
      NOONA_CTX_PKG.clear_context;
  END init_request;

  PROCEDURE cleanup_request IS
  BEGIN
    NOONA_CORE_PKG.reset_system;
    NOONA_CTX_PKG.clear_context;
  END cleanup_request;

  PROCEDURE logout IS
  BEGIN
    NOONA_SECURITY_PKG.end_session('LOGOUT');
  END logout;

  PROCEDURE switch_tenant(p_username IN VARCHAR2, p_apex_session_id IN NUMBER, p_tenant_id IN NUMBER) IS
  BEGIN
    NOONA_SECURITY_PKG.end_session('SWITCH_TENANT');
    post_auth(p_username, p_apex_session_id, p_tenant_id);
  END switch_tenant;

  PROCEDURE switch_company(p_company_id IN NUMBER, p_branch_id IN NUMBER DEFAULT NULL) IS
  BEGIN
    NOONA_SECURITY_PKG.switch_company(p_company_id, p_branch_id);
  END switch_company;

  FUNCTION is_authenticated RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN SYS_CONTEXT('NOONA_CTX', 'SESSION_ID') IS NOT NULL THEN 'Y' ELSE 'N' END;
  END;

  FUNCTION is_tenant_user RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN NOONA_CTX_PKG.tenant_id IS NOT NULL AND NOONA_CTX_PKG.membership_id IS NOT NULL
                THEN 'Y' ELSE 'N' END;
  END;

  FUNCTION is_tenant_admin RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN is_tenant_user = 'Y' AND NOONA_CTX_PKG.is_tenant_admin = 'Y' THEN 'Y' ELSE 'N' END;
  END;

  FUNCTION is_platform_admin RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN NOONA_CTX_PKG.is_platform_admin = 'Y' THEN 'Y' ELSE 'N' END;
  END;

  FUNCTION allow(p_permission_code IN VARCHAR2, p_company_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN NOONA_SECURITY_PKG.has_permission(p_permission_code, p_company_id);
  END allow;

  FUNCTION tenant_name RETURN VARCHAR2 IS
    l    VARCHAR2(400);
    l_ln VARCHAR2(10) := lang;
  BEGIN
    IF NOONA_CTX_PKG.tenant_id IS NULL THEN
      RETURN CASE WHEN is_platform_admin = 'Y' THEN
                    CASE lang WHEN 'en' THEN 'Platform Administration' ELSE 'إدارة المنصة' END END;
    END IF;
    SELECT CASE l_ln WHEN 'en' THEN NVL(name_en, name_ar) ELSE name_ar END INTO l
      FROM plt_tenant WHERE id = NOONA_CTX_PKG.tenant_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END tenant_name;

  FUNCTION company_name RETURN VARCHAR2 IS
    l    VARCHAR2(400);
    l_ln VARCHAR2(10) := lang;
  BEGIN
    IF NOONA_CTX_PKG.company_id IS NULL THEN
      RETURN NULL;
    END IF;
    SELECT CASE l_ln WHEN 'en' THEN NVL(legal_name_en, legal_name_ar)
                     ELSE NVL(trade_name_ar, legal_name_ar) END INTO l
      FROM org_company WHERE id = NOONA_CTX_PKG.company_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END company_name;

  FUNCTION display_name RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    IF NOONA_CTX_PKG.user_id IS NULL THEN
      RETURN NULL;
    END IF;
    NOONA_CORE_PKG.begin_system;
    SELECT NVL(display_name, username) INTO l FROM sec_user WHERE id = NOONA_CTX_PKG.user_id;
    NOONA_CORE_PKG.end_system;
    RETURN l;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RETURN NULL;
  END display_name;

  FUNCTION tenant_count(p_username IN VARCHAR2) RETURN NUMBER IS
    l_n NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    SELECT COUNT(*) INTO l_n
      FROM sec_user u
      JOIN sec_user_membership m ON m.user_id = u.id AND m.status_code = 'ACTIVE'
      JOIN plt_tenant t ON t.id = m.tenant_id
     WHERE u.username = UPPER(p_username)
       AND INSTR(c_allowed_tenant_states, ',' || t.status_code || ',') > 0;
    NOONA_CORE_PKG.end_system;
    RETURN l_n;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END tenant_count;

  FUNCTION login_block_reason(p_username IN VARCHAR2) RETURN VARCHAR2 IS
    l_user sec_user%ROWTYPE;
    l_ok   BOOLEAN := FALSE;
  BEGIN
    IF p_username IS NOT NULL THEN
      NOONA_CORE_PKG.begin_system;
      BEGIN
        SELECT * INTO l_user FROM sec_user WHERE username = UPPER(TRIM(p_username));
        IF l_user.status_code = 'ACTIVE' AND (l_user.expires_at IS NULL OR l_user.expires_at > SYSTIMESTAMP) THEN
          l_ok := l_user.user_type = 'PLATFORM_ADMIN' OR default_tenant(l_user.id) IS NOT NULL;
        END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_ok := FALSE;
      END;
      NOONA_CORE_PKG.end_system;
    END IF;
    IF l_ok THEN
      RETURN NULL;
    END IF;
    RETURN 'تعذر تسجيل الدخول: اسم المستخدم أو كلمة المرور غير صحيحة، أو الحساب غير مفعل في نونا بلس'
        || ' / Login failed: invalid credentials or account not enabled in NOONA PLUS';
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END login_block_reason;

END NOONA_APEX_PKG;
/
