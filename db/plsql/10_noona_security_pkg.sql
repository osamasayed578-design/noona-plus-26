-- =============================================================================
-- NOONA PLUS ERP | NOONA_SECURITY_PKG
-- إنشاء السياق الأمني بعد التحقق من العضوية، وقرار الصلاحية الذرية RESOURCE.ACTION:
--   Explicit Deny → (Classification/SoD/Context لاحقاً) → Allow → Default Deny
-- يستدعى من APEX: Authentication Post-Login + Initialization PL/SQL + Cleanup PL/SQL
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_SECURITY_PKG AUTHID DEFINER AS
  e_access_denied EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_access_denied, -20100);

  -- بعد نجاح المصادقة: يتحقق من الحساب والعضوية وينشئ SEC_SESSION ويثبت NOONA_CTX
  PROCEDURE establish_session(
    p_username        IN VARCHAR2,
    p_tenant_id       IN NUMBER,
    p_company_id      IN NUMBER   DEFAULT NULL,
    p_branch_id       IN NUMBER   DEFAULT NULL,
    p_apex_session_id IN NUMBER   DEFAULT NULL,
    p_ip_address      IN VARCHAR2 DEFAULT NULL,
    p_auth_method     IN VARCHAR2 DEFAULT 'APEX_ACCOUNTS');

  -- بداية كل طلب APEX/ORDS: يعيد بناء السياق من SEC_SESSION الموثقة (لا من Page Items)
  PROCEDURE attach_session(p_apex_session_id IN NUMBER, p_username IN VARCHAR2);

  -- تبديل الشركة/الفرع ضمن النطاق الممنوح فقط
  PROCEDURE switch_company(p_company_id IN NUMBER, p_branch_id IN NUMBER DEFAULT NULL);

  -- نهاية الطلب (Cleanup) - يمنع وراثة السياق عبر Connection Pool
  PROCEDURE detach_session;
  PROCEDURE end_session(p_reason IN VARCHAR2 DEFAULT 'LOGOUT');

  FUNCTION has_permission(p_permission_code IN VARCHAR2,
                          p_company_id      IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  PROCEDURE assert_permission(p_permission_code IN VARCHAR2,
                              p_company_id      IN NUMBER DEFAULT NULL);

  FUNCTION can_access_company(p_company_id IN NUMBER) RETURN VARCHAR2;
END NOONA_SECURITY_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_SECURITY_PKG AS

  PROCEDURE deny(p_code VARCHAR2, p_msg VARCHAR2) IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20100, p_code || ': ' || p_msg);
  END;

  FUNCTION company_in_scope(p_membership_id NUMBER, p_tenant_id NUMBER, p_company_id NUMBER) RETURN BOOLEAN IS
    l_cnt NUMBER;
  BEGIN
    IF p_company_id IS NULL THEN
      RETURN TRUE;
    END IF;
    SELECT COUNT(*) INTO l_cnt
      FROM sec_user_membership m
     WHERE m.id = p_membership_id
       AND (m.default_company_id = p_company_id
            OR m.is_tenant_admin = 'Y'
            OR EXISTS (SELECT 1
                         FROM sec_role_grant g
                         JOIN sec_data_scope s ON s.role_grant_id = g.id AND s.tenant_id = g.tenant_id
                        WHERE g.membership_id = m.id
                          AND g.tenant_id = p_tenant_id
                          AND g.status_code = 'ACTIVE'
                          AND TRUNC(SYSDATE) BETWEEN g.effective_from AND NVL(g.effective_to, DATE '9999-12-31')
                          AND (s.scope_type = 'ALL_TENANT' OR s.company_id = p_company_id)));
    RETURN l_cnt > 0;
  END company_in_scope;

  PROCEDURE establish_session(
    p_username        IN VARCHAR2,
    p_tenant_id       IN NUMBER,
    p_company_id      IN NUMBER   DEFAULT NULL,
    p_branch_id       IN NUMBER   DEFAULT NULL,
    p_apex_session_id IN NUMBER   DEFAULT NULL,
    p_ip_address      IN VARCHAR2 DEFAULT NULL,
    p_auth_method     IN VARCHAR2 DEFAULT 'APEX_ACCOUNTS') IS
    l_user       sec_user%ROWTYPE;
    l_mem        sec_user_membership%ROWTYPE;
    l_tenant_st  plt_tenant.status_code%TYPE;
    l_company_id NUMBER;
    l_branch_id  NUMBER;
    l_session_id NUMBER;
  BEGIN
    NOONA_CTX_PKG.clear_context;
    NOONA_CTX_PKG.enable_system_mode;

    BEGIN
      SELECT * INTO l_user FROM sec_user WHERE username = UPPER(p_username);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CTX_PKG.clear_context;
      deny('NOONA-SEC-010', 'Unknown user');
    END;
    IF l_user.status_code <> 'ACTIVE' OR (l_user.expires_at IS NOT NULL AND l_user.expires_at < SYSTIMESTAMP) THEN
      NOONA_CTX_PKG.clear_context;
      deny('NOONA-SEC-011', 'User account is not active');
    END IF;

    SELECT status_code INTO l_tenant_st FROM plt_tenant WHERE id = p_tenant_id;
    IF l_tenant_st NOT IN ('TRIAL', 'ACTIVE', 'GRACE_PERIOD', 'READ_ONLY', 'SUSPENDED') THEN
      NOONA_CTX_PKG.clear_context;
      deny('NOONA-SEC-012', 'Tenant is not available');
    END IF;

    BEGIN
      SELECT * INTO l_mem
        FROM sec_user_membership
       WHERE tenant_id = p_tenant_id
         AND user_id = l_user.id
         AND status_code = 'ACTIVE'
         AND TRUNC(SYSDATE) BETWEEN effective_from AND NVL(effective_to, DATE '9999-12-31');
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CTX_PKG.clear_context;
      deny('NOONA-SEC-013', 'No active membership in this tenant');
    END;

    -- المؤسسة المعلقة: يقتصر وصول مديرها على الاشتراك والدفع (6.10.7)
    IF l_tenant_st = 'SUSPENDED' AND l_mem.is_tenant_admin <> 'Y' THEN
      NOONA_CTX_PKG.clear_context;
      deny('NOONA-SEC-014', 'Tenant is suspended');
    END IF;

    l_company_id := NVL(p_company_id, l_mem.default_company_id);
    l_branch_id  := CASE WHEN p_company_id IS NULL THEN l_mem.default_branch_id ELSE p_branch_id END;
    IF NOT company_in_scope(l_mem.id, p_tenant_id, l_company_id) THEN
      NOONA_CTX_PKG.clear_context;
      deny('NOONA-SEC-015', 'Company is outside the granted scope');
    END IF;

    NOONA_CTX_PKG.set_context(
      p_tenant_id       => p_tenant_id,
      p_user_id         => l_user.id,
      p_membership_id   => l_mem.id,
      p_username        => l_user.username,
      p_company_id      => l_company_id,
      p_branch_id       => l_branch_id,
      p_language        => l_user.preferred_language,
      p_clearance       => l_mem.clearance_level,
      p_is_tenant_admin => l_mem.is_tenant_admin);

    INSERT INTO sec_session (tenant_id, user_id, membership_id, apex_session_id, company_id, branch_id,
                             language_code, auth_method, ip_address, status_code)
    VALUES (p_tenant_id, l_user.id, l_mem.id, p_apex_session_id, l_company_id, l_branch_id,
            l_user.preferred_language, p_auth_method, p_ip_address, 'ACTIVE')
    RETURNING id INTO l_session_id;

    UPDATE sec_user SET last_login_at = SYSTIMESTAMP, failed_logins = 0 WHERE id = l_user.id;

    NOONA_CTX_PKG.set_context(
      p_tenant_id       => p_tenant_id,
      p_user_id         => l_user.id,
      p_membership_id   => l_mem.id,
      p_username        => l_user.username,
      p_company_id      => l_company_id,
      p_branch_id       => l_branch_id,
      p_language        => l_user.preferred_language,
      p_clearance       => l_mem.clearance_level,
      p_session_id      => l_session_id,
      p_is_tenant_admin => l_mem.is_tenant_admin);

    NOONA_AUDIT_PKG.log_event('AUTH', 'SEC_SESSION', l_session_id, 'LOGIN', 'SUCCESS');
  END establish_session;

  PROCEDURE attach_session(p_apex_session_id IN NUMBER, p_username IN VARCHAR2) IS
    l_s   sec_session%ROWTYPE;
    l_u   sec_user%ROWTYPE;
    l_m   sec_user_membership%ROWTYPE;
  BEGIN
    NOONA_CTX_PKG.clear_context;
    NOONA_CTX_PKG.enable_system_mode;
    BEGIN
      SELECT * INTO l_s
        FROM (SELECT * FROM sec_session
               WHERE apex_session_id = p_apex_session_id AND status_code = 'ACTIVE'
               ORDER BY started_at DESC)
       WHERE ROWNUM = 1;
      SELECT * INTO l_u FROM sec_user WHERE id = l_s.user_id;
      SELECT * INTO l_m FROM sec_user_membership WHERE id = l_s.membership_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CTX_PKG.clear_context;
      deny('NOONA-SEC-020', 'No active NOONA session');
    END;
    IF l_u.username <> UPPER(p_username) OR l_u.status_code <> 'ACTIVE' OR l_m.status_code <> 'ACTIVE' THEN
      NOONA_CTX_PKG.clear_context;
      deny('NOONA-SEC-021', 'Session context is no longer valid');
    END IF;
    UPDATE sec_session SET last_activity_at = SYSTIMESTAMP WHERE id = l_s.id;
    NOONA_CTX_PKG.set_context(
      p_tenant_id       => l_s.tenant_id,
      p_user_id         => l_u.id,
      p_membership_id   => l_m.id,
      p_username        => l_u.username,
      p_company_id      => l_s.company_id,
      p_branch_id       => l_s.branch_id,
      p_language        => l_s.language_code,
      p_clearance       => l_m.clearance_level,
      p_session_id      => l_s.id,
      p_is_tenant_admin => l_m.is_tenant_admin);
  END attach_session;

  PROCEDURE switch_company(p_company_id IN NUMBER, p_branch_id IN NUMBER DEFAULT NULL) IS
    l_sid NUMBER := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'SESSION_ID'));
  BEGIN
    IF NOT company_in_scope(NOONA_CTX_PKG.membership_id, NOONA_CTX_PKG.tenant_id, p_company_id) THEN
      deny('NOONA-SEC-015', 'Company is outside the granted scope');
    END IF;
    UPDATE sec_session SET company_id = p_company_id, branch_id = p_branch_id WHERE id = l_sid;
    NOONA_CTX_PKG.set_company(p_company_id, p_branch_id);
    NOONA_AUDIT_PKG.log_event('SECURITY', 'SEC_SESSION', l_sid, 'SWITCH_COMPANY', 'SUCCESS',
                              p_new_values => '{"company_id":' || p_company_id || '}');
  END switch_company;

  PROCEDURE detach_session IS
  BEGIN
    NOONA_CTX_PKG.clear_context;
  END detach_session;

  PROCEDURE end_session(p_reason IN VARCHAR2 DEFAULT 'LOGOUT') IS
    l_sid NUMBER := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'SESSION_ID'));
  BEGIN
    IF l_sid IS NOT NULL THEN
      UPDATE sec_session
         SET status_code = 'ENDED', ended_at = SYSTIMESTAMP, end_reason = SUBSTR(p_reason, 1, 30)
       WHERE id = l_sid;
      NOONA_AUDIT_PKG.log_event('AUTH', 'SEC_SESSION', l_sid, 'LOGOUT', 'SUCCESS');
    END IF;
    NOONA_CTX_PKG.clear_context;
  END end_session;

  FUNCTION has_permission(p_permission_code IN VARCHAR2,
                          p_company_id      IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    l_tenant  NUMBER := NOONA_CTX_PKG.tenant_id;
    l_member  NUMBER := NOONA_CTX_PKG.membership_id;
    l_company NUMBER := NVL(p_company_id, NOONA_CTX_PKG.company_id);
    l_allow   NUMBER := 0;
    l_deny    NUMBER := 0;
  BEGIN
    IF l_tenant IS NULL OR l_member IS NULL THEN
      RETURN 'N';                                   -- Default Deny
    END IF;
    FOR r IN (
      WITH granted_roles AS (
        SELECT DISTINCT rc.role_id, g.id AS grant_id
          FROM sec_role_grant g
          JOIN (SELECT CONNECT_BY_ROOT parent_role_id AS root_role_id, child_role_id AS role_id
                  FROM sec_role_composite
                CONNECT BY NOCYCLE PRIOR child_role_id = parent_role_id
                UNION ALL
                SELECT id, id FROM sec_role) rc ON rc.root_role_id = g.role_id
         WHERE g.tenant_id = l_tenant
           AND g.membership_id = l_member
           AND g.status_code = 'ACTIVE'
           AND TRUNC(SYSDATE) BETWEEN g.effective_from AND NVL(g.effective_to, DATE '9999-12-31')
           AND (l_company IS NULL
                OR NOT EXISTS (SELECT 1 FROM sec_data_scope s WHERE s.role_grant_id = g.id)
                OR EXISTS (SELECT 1 FROM sec_data_scope s
                            WHERE s.role_grant_id = g.id
                              AND (s.scope_type = 'ALL_TENANT' OR s.company_id = l_company))))
      SELECT rp.effect
        FROM granted_roles gr
        JOIN sec_role_permission rp ON rp.role_id = gr.role_id
        JOIN sec_permission p ON p.id = rp.permission_id
        JOIN sec_role ro ON ro.id = gr.role_id AND ro.status_code = 'ACTIVE'
       WHERE p.permission_code = p_permission_code
         AND p.is_active = 'Y')
    LOOP
      IF r.effect = 'DENY' THEN
        l_deny := l_deny + 1;
      ELSE
        l_allow := l_allow + 1;
      END IF;
    END LOOP;
    IF l_deny > 0 THEN
      RETURN 'N';                                   -- Explicit Deny يتقدم
    END IF;
    RETURN CASE WHEN l_allow > 0 THEN 'Y' ELSE 'N' END;
  END has_permission;

  PROCEDURE assert_permission(p_permission_code IN VARCHAR2,
                              p_company_id      IN NUMBER DEFAULT NULL) IS
  BEGIN
    IF has_permission(p_permission_code, p_company_id) = 'N' THEN
      NOONA_AUDIT_PKG.log_event('SECURITY', NULL, NULL, 'PERMISSION_CHECK', 'DENIED',
                                p_reason => p_permission_code);
      deny('NOONA-SEC-100', 'Permission denied: ' || p_permission_code);
    END IF;
  END assert_permission;

  FUNCTION can_access_company(p_company_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN company_in_scope(NOONA_CTX_PKG.membership_id, NOONA_CTX_PKG.tenant_id, p_company_id)
                THEN 'Y' ELSE 'N' END;
  END can_access_company;

END NOONA_SECURITY_PKG;
/
