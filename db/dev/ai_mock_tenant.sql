-- NOONA PLUS 26 | للتطوير فقط: تفعيل المساعد لمؤسسة مستخدم بالخادم التجريبي (NOONA_AI_MOCK)
--   sqlplus NOONA_APP@... @db/dev/ai_mock_tenant.sql <username>
SET DEFINE ON
SET VERIFY OFF
DECLARE
  l_prov NUMBER;
  l_mod  NUMBER;
BEGIN
  apex_session.create_session(p_app_id => 127, p_page_id => 1, p_username => '&1');
  NOONA_APEX_PKG.post_auth('&1', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT MAX(id) INTO l_prov FROM ai_provider WHERE code = 'DEV_MOCK' AND tenant_id = SYS_CONTEXT('NOONA_CTX', 'TENANT_ID');
  IF l_prov IS NULL THEN
    INSERT INTO ai_provider (code, name_ar, provider_type, endpoint_ref, status_code)
    VALUES ('DEV_MOCK', 'خادم تجريبي', 'PRIVATE_HOSTED', 'NOONA_AI_MOCK', 'ACTIVE') RETURNING id INTO l_prov;
    INSERT INTO ai_model (code, name_ar, provider_id, model_kind, model_identifier, max_context_tokens, status_code)
    VALUES ('DEV_MOCK_CHAT', 'نموذج تجريبي', l_prov, 'CHAT', 'noona-mock', 8000, 'ACTIVE');
  END IF;
  SELECT id INTO l_mod FROM ai_model WHERE code = 'DEV_MOCK_CHAT' AND tenant_id = SYS_CONTEXT('NOONA_CTX', 'TENANT_ID');
  NOONA_AI_PKG.save_settings('{"enabled":"Y","modelId":' || l_mod || ',"quota":2000000}');
  COMMIT;
END;
/
EXIT
