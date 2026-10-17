-- =============================================================================
-- NOONA PLUS ERP | NOONA_CORE_PKG - خدمات مشتركة لكل الحزم
--   * أخطاء أعمال موحدة ثنائية اللغة بأرقام ثابتة ورمز NOONA-xxx-nnn و Correlation ID
--   * حارس الكتابة: يمنع المعاملات الجديدة عند READ_ONLY/SUSPENDED (6.10.7) وبدون سياق
--   * تشغيل كتلة بوضع النظام (تجاوز VPD) مع إعادة الوضع دائماً
-- رموز الأخطاء: -20500 أخطاء أعمال | -20100 رفض أمني (NOONA_SECURITY_PKG)
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_CORE_PKG AUTHID DEFINER AS
  c_business_error CONSTANT PLS_INTEGER := -20500;
  e_business EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_business, -20500);

  -- يرفع خطأ أعمال بلغة المستخدم: "NOONA-PLT-010: النص [cid=...]"
  PROCEDURE raise_error(p_code IN VARCHAR2, p_msg_ar IN VARCHAR2, p_msg_en IN VARCHAR2 DEFAULT NULL);

  PROCEDURE assert(p_condition IN BOOLEAN, p_code IN VARCHAR2, p_msg_ar IN VARCHAR2, p_msg_en IN VARCHAR2 DEFAULT NULL);

  -- يتطلب جلسة مؤسسة صالحة
  PROCEDURE require_tenant_context;
  -- يتطلب جلسة مسؤول منصة
  PROCEDURE require_platform_admin;
  -- يتطلب أن تسمح حالة المؤسسة بإنشاء/تعديل المعاملات
  PROCEDURE assert_tenant_writable;

  -- وضع النظام: يحفظ الوضع السابق ويعيده
  PROCEDURE begin_system;
  PROCEDURE end_system;

  FUNCTION yn(p_bool IN BOOLEAN) RETURN VARCHAR2;
  FUNCTION json_text(p_value IN VARCHAR2) RETURN VARCHAR2;   -- قيمة نصية آمنة داخل JSON
END NOONA_CORE_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_CORE_PKG AS
  g_system_depth PLS_INTEGER := 0;

  PROCEDURE raise_error(p_code IN VARCHAR2, p_msg_ar IN VARCHAR2, p_msg_en IN VARCHAR2 DEFAULT NULL) IS
    l_msg VARCHAR2(2000);
  BEGIN
    l_msg := CASE WHEN NOONA_CTX_PKG.language_code = 'en' AND p_msg_en IS NOT NULL THEN p_msg_en ELSE p_msg_ar END;
    RAISE_APPLICATION_ERROR(c_business_error,
      p_code || ': ' || l_msg ||
      CASE WHEN NOONA_CTX_PKG.correlation_id IS NOT NULL THEN ' [cid=' || NOONA_CTX_PKG.correlation_id || ']' END);
  END raise_error;

  PROCEDURE assert(p_condition IN BOOLEAN, p_code IN VARCHAR2, p_msg_ar IN VARCHAR2, p_msg_en IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_condition IS NULL OR NOT p_condition THEN
      raise_error(p_code, p_msg_ar, p_msg_en);
    END IF;
  END assert;

  PROCEDURE require_tenant_context IS
  BEGIN
    IF NOONA_CTX_PKG.tenant_id IS NULL OR NOONA_CTX_PKG.membership_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20100, 'NOONA-SEC-030: لا يوجد سياق مؤسسة موثوق');
    END IF;
  END require_tenant_context;

  PROCEDURE require_platform_admin IS
  BEGIN
    IF NOONA_CTX_PKG.is_platform_admin <> 'Y' THEN
      RAISE_APPLICATION_ERROR(-20100, 'NOONA-SEC-031: العملية مقصورة على مسؤول المنصة');
    END IF;
  END require_platform_admin;

  PROCEDURE assert_tenant_writable IS
    l_status plt_tenant.status_code%TYPE;
  BEGIN
    require_tenant_context;
    SELECT status_code INTO l_status FROM plt_tenant WHERE id = NOONA_CTX_PKG.tenant_id;
    IF l_status IN ('READ_ONLY', 'SUSPENDED', 'ARCHIVED', 'CLOSED') THEN
      raise_error('NOONA-PLT-001',
                  'المؤسسة في وضع ' || l_status || ' ولا تسمح بمعاملات جديدة أو تعديل',
                  'Tenant is ' || l_status || '; new transactions and changes are blocked');
    END IF;
  END assert_tenant_writable;

  PROCEDURE begin_system IS
  BEGIN
    g_system_depth := g_system_depth + 1;
    NOONA_CTX_PKG.enable_system_mode;
  END begin_system;

  PROCEDURE end_system IS
  BEGIN
    g_system_depth := GREATEST(g_system_depth - 1, 0);
    IF g_system_depth = 0 THEN
      NOONA_CTX_PKG.disable_system_mode;
    END IF;
  END end_system;

  FUNCTION yn(p_bool IN BOOLEAN) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_bool THEN 'Y' ELSE 'N' END;
  END yn;

  FUNCTION json_text(p_value IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_value IS NULL THEN 'null'
                ELSE '"' || REPLACE(REPLACE(REPLACE(p_value, '\', '\\'), '"', '\"'), CHR(10), '\n') || '"' END;
  END json_text;

END NOONA_CORE_PKG;
/
