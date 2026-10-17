-- =============================================================================
-- NOONA PLUS ERP | Oracle Application Context
-- السياق الأمني الموثوق: يثبت Tenant والمستخدم والشركة والفرع في بداية كل طلب
-- ويزال قبل إعادة الاتصال إلى Pool (BR-009 / 46.2 / 49.2).
-- لا يستدعى SET_CONTEXT إلا من NOONA_SECURITY_PKG بعد التحقق من العضوية.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE CONTEXT NOONA_CTX USING NOONA_CTX_PKG;

CREATE OR REPLACE PACKAGE NOONA_CTX_PKG AUTHID DEFINER AS
  c_namespace CONSTANT VARCHAR2(30) := 'NOONA_CTX';

  PROCEDURE set_context(
    p_tenant_id      IN NUMBER,
    p_user_id        IN NUMBER,
    p_membership_id  IN NUMBER,
    p_username       IN VARCHAR2,
    p_company_id     IN NUMBER   DEFAULT NULL,
    p_branch_id      IN NUMBER   DEFAULT NULL,
    p_language       IN VARCHAR2 DEFAULT 'ar',
    p_clearance      IN VARCHAR2 DEFAULT 'INTERNAL',
    p_session_id     IN NUMBER   DEFAULT NULL,
    p_correlation_id IN VARCHAR2 DEFAULT NULL,
    p_is_tenant_admin IN VARCHAR2 DEFAULT 'N');

  -- جلسة مسؤول المنصة: بدون Tenant، ولا تمنح قراءة بيانات أعمال المؤسسات (10.3)
  PROCEDURE set_platform_context(
    p_user_id        IN NUMBER,
    p_username       IN VARCHAR2,
    p_session_id     IN NUMBER   DEFAULT NULL,
    p_correlation_id IN VARCHAR2 DEFAULT NULL);

  PROCEDURE set_company(p_company_id IN NUMBER, p_branch_id IN NUMBER DEFAULT NULL);
  PROCEDURE set_correlation_id(p_correlation_id IN VARCHAR2);

  -- وضع النظام للوظائف الخلفية والترحيل (يتجاوز VPD) - يستدعى من حزم المالك فقط
  PROCEDURE enable_system_mode;
  PROCEDURE disable_system_mode;
  -- وضع الإتلاف المعتمد للجداول Append-only
  PROCEDURE enable_purge_mode;
  PROCEDURE disable_purge_mode;

  PROCEDURE clear_context;

  FUNCTION tenant_id      RETURN NUMBER;
  FUNCTION user_id        RETURN NUMBER;
  FUNCTION membership_id  RETURN NUMBER;
  FUNCTION company_id     RETURN NUMBER;
  FUNCTION branch_id      RETURN NUMBER;
  FUNCTION language_code  RETURN VARCHAR2;
  FUNCTION clearance      RETURN VARCHAR2;
  FUNCTION correlation_id RETURN VARCHAR2;
  FUNCTION is_system_mode RETURN VARCHAR2;
  FUNCTION purge_mode     RETURN VARCHAR2;
  FUNCTION is_platform_admin RETURN VARCHAR2;
  FUNCTION is_tenant_admin RETURN VARCHAR2;
  FUNCTION current_user_name RETURN VARCHAR2;
END NOONA_CTX_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_CTX_PKG AS

  PROCEDURE put(p_attr VARCHAR2, p_value VARCHAR2) IS
  BEGIN
    DBMS_SESSION.SET_CONTEXT(c_namespace, p_attr, p_value);
  END;

  PROCEDURE set_context(
    p_tenant_id      IN NUMBER,
    p_user_id        IN NUMBER,
    p_membership_id  IN NUMBER,
    p_username       IN VARCHAR2,
    p_company_id     IN NUMBER   DEFAULT NULL,
    p_branch_id      IN NUMBER   DEFAULT NULL,
    p_language       IN VARCHAR2 DEFAULT 'ar',
    p_clearance      IN VARCHAR2 DEFAULT 'INTERNAL',
    p_session_id     IN NUMBER   DEFAULT NULL,
    p_correlation_id IN VARCHAR2 DEFAULT NULL,
    p_is_tenant_admin IN VARCHAR2 DEFAULT 'N') IS
  BEGIN
    DBMS_SESSION.CLEAR_ALL_CONTEXT(c_namespace);
    put('TENANT_ID',      TO_CHAR(p_tenant_id));
    put('USER_ID',        TO_CHAR(p_user_id));
    put('MEMBERSHIP_ID',  TO_CHAR(p_membership_id));
    put('USERNAME',       p_username);
    put('COMPANY_ID',     TO_CHAR(p_company_id));
    put('BRANCH_ID',      TO_CHAR(p_branch_id));
    put('LANGUAGE',       NVL(p_language, 'ar'));
    put('CLEARANCE',      NVL(p_clearance, 'INTERNAL'));
    put('SESSION_ID',     TO_CHAR(p_session_id));
    put('CORRELATION_ID', NVL(p_correlation_id, RAWTOHEX(SYS_GUID())));
    put('TENANT_ADMIN',   NVL(p_is_tenant_admin, 'N'));
    put('SYSTEM_MODE',    'N');
    put('PURGE_MODE',     'N');
  END set_context;

  PROCEDURE set_platform_context(
    p_user_id        IN NUMBER,
    p_username       IN VARCHAR2,
    p_session_id     IN NUMBER   DEFAULT NULL,
    p_correlation_id IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    DBMS_SESSION.CLEAR_ALL_CONTEXT(c_namespace);
    put('USER_ID',        TO_CHAR(p_user_id));
    put('USERNAME',       p_username);
    put('SESSION_ID',     TO_CHAR(p_session_id));
    put('CORRELATION_ID', NVL(p_correlation_id, RAWTOHEX(SYS_GUID())));
    put('PLATFORM_ADMIN', 'Y');
    put('LANGUAGE',       'ar');
    put('SYSTEM_MODE',    'N');
    put('PURGE_MODE',     'N');
  END set_platform_context;

  PROCEDURE set_company(p_company_id IN NUMBER, p_branch_id IN NUMBER DEFAULT NULL) IS
  BEGIN
    put('COMPANY_ID', TO_CHAR(p_company_id));
    put('BRANCH_ID',  TO_CHAR(p_branch_id));
  END;

  PROCEDURE set_correlation_id(p_correlation_id IN VARCHAR2) IS
  BEGIN
    put('CORRELATION_ID', p_correlation_id);
  END;

  PROCEDURE enable_system_mode  IS BEGIN put('SYSTEM_MODE', 'Y'); END;
  PROCEDURE disable_system_mode IS BEGIN put('SYSTEM_MODE', 'N'); END;
  PROCEDURE enable_purge_mode   IS BEGIN put('PURGE_MODE', 'Y');  END;
  PROCEDURE disable_purge_mode  IS BEGIN put('PURGE_MODE', 'N');  END;

  PROCEDURE clear_context IS
  BEGIN
    DBMS_SESSION.CLEAR_ALL_CONTEXT(c_namespace);
  END;

  FUNCTION tenant_id      RETURN NUMBER   IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT(c_namespace, 'TENANT_ID')); END;
  FUNCTION user_id        RETURN NUMBER   IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT(c_namespace, 'USER_ID')); END;
  FUNCTION membership_id  RETURN NUMBER   IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT(c_namespace, 'MEMBERSHIP_ID')); END;
  FUNCTION company_id     RETURN NUMBER   IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT(c_namespace, 'COMPANY_ID')); END;
  FUNCTION branch_id      RETURN NUMBER   IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT(c_namespace, 'BRANCH_ID')); END;
  FUNCTION language_code  RETURN VARCHAR2 IS BEGIN RETURN NVL(SYS_CONTEXT(c_namespace, 'LANGUAGE'), 'ar'); END;
  FUNCTION clearance      RETURN VARCHAR2 IS BEGIN RETURN NVL(SYS_CONTEXT(c_namespace, 'CLEARANCE'), 'PUBLIC'); END;
  FUNCTION correlation_id RETURN VARCHAR2 IS BEGIN RETURN SYS_CONTEXT(c_namespace, 'CORRELATION_ID'); END;
  FUNCTION is_system_mode RETURN VARCHAR2 IS BEGIN RETURN NVL(SYS_CONTEXT(c_namespace, 'SYSTEM_MODE'), 'N'); END;
  FUNCTION purge_mode     RETURN VARCHAR2 IS BEGIN RETURN NVL(SYS_CONTEXT(c_namespace, 'PURGE_MODE'), 'N'); END;

  FUNCTION is_platform_admin RETURN VARCHAR2 IS BEGIN RETURN NVL(SYS_CONTEXT(c_namespace, 'PLATFORM_ADMIN'), 'N'); END;
  FUNCTION is_tenant_admin   RETURN VARCHAR2 IS BEGIN RETURN NVL(SYS_CONTEXT(c_namespace, 'TENANT_ADMIN'), 'N'); END;

  FUNCTION current_user_name RETURN VARCHAR2 IS
  BEGIN
    RETURN COALESCE(SYS_CONTEXT(c_namespace, 'USERNAME'),
                    SYS_CONTEXT('APEX$SESSION', 'APP_USER'),
                    SYS_CONTEXT('USERENV', 'SESSION_USER'));
  END current_user_name;

END NOONA_CTX_PKG;
/
