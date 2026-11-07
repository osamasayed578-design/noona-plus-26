-- =============================================================================
-- NOONA PLUS 26 | تفعيل المساعد لمؤسسة مستخدم بالنموذج المحلي (خدمة NOONA_AI_LOCAL)
--   sqlplus NOONA_APP@... @db/dev/ai_local_tenant.sql <username> <model>
--   مثال: @db/dev/ai_local_tenant.sql ADMIN qwen2.5:3b
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
  l_prov NUMBER;
  l_mod  NUMBER;
BEGIN
  apex_session.create_session(p_app_id => 127, p_page_id => 1, p_username => '&1');
  NOONA_APEX_PKG.post_auth('&1', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT MAX(id) INTO l_prov FROM ai_provider WHERE code = 'LOCAL_OLLAMA' AND tenant_id = SYS_CONTEXT('NOONA_CTX', 'TENANT_ID');
  IF l_prov IS NULL THEN
    INSERT INTO ai_provider (code, name_ar, provider_type, endpoint_ref, status_code)
    VALUES ('LOCAL_OLLAMA', 'نموذج محلي (Ollama)', 'PRIVATE_HOSTED', 'NOONA_AI_LOCAL', 'ACTIVE') RETURNING id INTO l_prov;
  END IF;
  SELECT MAX(id) INTO l_mod FROM ai_model WHERE code = 'LOCAL_CHAT' AND tenant_id = SYS_CONTEXT('NOONA_CTX', 'TENANT_ID');
  IF l_mod IS NULL THEN
    INSERT INTO ai_model (code, name_ar, provider_id, model_kind, model_identifier, max_context_tokens, status_code)
    VALUES ('LOCAL_CHAT', 'نموذج محلي مجاني', l_prov, 'CHAT', '&2', 8192, 'ACTIVE') RETURNING id INTO l_mod;
  ELSE
    UPDATE ai_model SET model_identifier = '&2', provider_id = l_prov, status_code = 'ACTIVE' WHERE id = l_mod;
  END IF;
  NOONA_AI_PKG.save_settings('{"enabled":"Y","modelId":' || l_mod || ',"quota":50000000,"retentionDays":90}');
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('TENANT_OK available=' || NOONA_AI_PKG.is_enabled);
END;
/
EXIT
