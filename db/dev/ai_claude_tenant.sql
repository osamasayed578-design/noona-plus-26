-- =============================================================================
-- NOONA PLUS 26 | تفعيل المساعد لمؤسسة مستخدم بنموذج Claude (خدمة APEX: NOONA_AI_CLAUDE)
--   sqlplus NOONA_APP@... @db/dev/ai_claude_tenant.sql <username> <model_code> <monthly_quota_tokens>
--   مثال: @db/dev/ai_claude_tenant.sql RYD_ADMIN CLAUDE_HAIKU 2000000
--   model_code: CLAUDE_HAIKU (سريع واقتصادي) | CLAUDE_SONNET (متوازن) | CLAUDE_OPUS (الأقوى)
-- المفتاح لا يمر هنا: يدخله مسؤول مساحة العمل في خدمة NOONA_AI_CLAUDE داخل APEX
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
  l_mod NUMBER;
BEGIN
  apex_session.create_session(p_app_id => 127, p_page_id => 1, p_username => '&1');
  NOONA_APEX_PKG.post_auth('&1', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT MAX(id) INTO l_mod FROM ai_model WHERE code = UPPER('&2') AND status_code = 'ACTIVE'
     AND (tenant_id IS NULL OR tenant_id = SYS_CONTEXT('NOONA_CTX', 'TENANT_ID'));
  IF l_mod IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'NOONA: model &2 not found');
  END IF;
  NOONA_AI_PKG.save_settings('{"enabled":"Y","modelId":' || l_mod || ',"quota":' || TO_NUMBER('&3') || ',"retentionDays":90}');
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('TENANT_OK ' || SYS_CONTEXT('NOONA_CTX', 'TENANT_ID') || ' available=' || NOONA_AI_PKG.is_enabled);
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
