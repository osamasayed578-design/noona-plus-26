-- =============================================================================
-- NOONA PLUS 26 | للتطوير فقط: خدمة ذكاء اصطناعي تجريبية (GENERIC_OPENAI) تشير للخادم التجريبي tools/ai_mock/server.js
--   sqlplus / as sysdba  (داخل FREEPDB1)   @db/dev/ai_mock_service.sql <host> <port>
--   لا تستخدم في الإنتاج؛ خدمات Claude و OCI ينشئها مسؤول مساحة العمل من APEX بمفتاحه (انظر docs/ai_setup_26.md)
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
DEFINE host = '&1'
DEFINE port = '&2'
DECLARE
  l_apex VARCHAR2(30);
  l_sg   NUMBER;
  l_id   NUMBER;
BEGIN
  SELECT MAX(username) INTO l_apex FROM all_users WHERE username LIKE 'APEX\_2%' ESCAPE '\';
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(host => '&host', lower_port => &port, upper_port => &port,
    ace => xs$ace_type(privilege_list => xs$name_list('http'), principal_name => l_apex, principal_type => xs_acl.ptype_db));
  EXECUTE IMMEDIATE 'SELECT MAX(provisioning_company_id) FROM ' || l_apex || '.wwv_flow_companies WHERE short_name = ''NOONAPLUS''' INTO l_sg;
  EXECUTE IMMEDIATE 'DELETE FROM ' || l_apex || '.wwv_remote_servers WHERE static_id = ''NOONA_AI_MOCK'' AND security_group_id = :1' USING l_sg;
  EXECUTE IMMEDIATE 'SELECT ' || l_apex || '.wwv_seq.nextval FROM dual' INTO l_id;
  EXECUTE IMMEDIATE 'INSERT INTO ' || l_apex || '.wwv_remote_servers (id, security_group_id, name, static_id, base_url, server_type, prompt_on_install,'
    || ' ai_provider_type, ai_provider_api, ai_is_builder_service, ai_model_name) VALUES'
    || ' (:1, :2, ''NOONA AI Mock'', ''NOONA_AI_MOCK'', ''http://&host:&port/v1'', ''GENERATIVE_AI'', ''N'', ''GENERIC_OPENAI'', ''CHAT_COMPLETIONS'', ''N'', ''noona-mock'')'
    USING l_id, l_sg;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('NOONA_AI_MOCK created for ' || l_apex || ' sg=' || l_sg);
END;
/
EXIT
