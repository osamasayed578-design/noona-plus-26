-- =============================================================================
-- NOONA PLUS 26 | خدمة ذكاء اصطناعي محلية مجانية (Ollama، متوافقة مع OpenAI) للتجربة والعرض
--   sqlplus / as sysdba  (داخل الـ PDB)   @db/dev/ai_local_service.sql <host> <port> <model>
--   مثال: @db/dev/ai_local_service.sql localhost 11434 qwen2.5:3b
--   تنشئ خدمة APEX بالمعرف NOONA_AI_LOCAL في مساحة NOONAPLUS، وتمنح APEX الاتصال بالمضيف والمنفذ
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
DEFINE host  = '&1'
DEFINE port  = '&2'
DEFINE model = '&3'
DECLARE
  l_apex VARCHAR2(30);
  l_sg   NUMBER;
  l_id   NUMBER;
BEGIN
  SELECT schema INTO l_apex FROM dba_registry WHERE comp_id = 'APEX';
  -- صلاحية على المضيف كله (بلا تحديد منفذ: بعض الإصدارات ترفض المنفذ مع http بخطأ ORA-24244)
  FOR h IN (SELECT '&host' host FROM dual UNION SELECT '127.0.0.1' FROM dual) LOOP
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(host => h.host,
      ace => xs$ace_type(privilege_list => xs$name_list('http', 'connect', 'resolve'), principal_name => l_apex,
                         principal_type => xs_acl.ptype_db));
  END LOOP;
  EXECUTE IMMEDIATE 'SELECT MAX(provisioning_company_id) FROM ' || l_apex || '.wwv_flow_companies WHERE short_name = ''NOONAPLUS''' INTO l_sg;
  IF l_sg IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'مساحة العمل NOONAPLUS غير موجودة؛ ثبّت نونا أولاً');
  END IF;
  EXECUTE IMMEDIATE 'DELETE FROM ' || l_apex || '.wwv_remote_servers WHERE static_id = ''NOONA_AI_LOCAL'' AND security_group_id = :1' USING l_sg;
  EXECUTE IMMEDIATE 'SELECT ' || l_apex || '.wwv_seq.nextval FROM dual' INTO l_id;
  EXECUTE IMMEDIATE 'INSERT INTO ' || l_apex || '.wwv_remote_servers (id, security_group_id, name, static_id, base_url, server_type, prompt_on_install,'
    || ' ai_provider_type, ai_provider_api, ai_is_builder_service, ai_model_name) VALUES'
    || ' (:1, :2, ''NOONA AI Local (Ollama)'', ''NOONA_AI_LOCAL'', ''http://&host:&port/v1'', ''GENERATIVE_AI'', ''N'','
    || ' ''GENERIC_OPENAI'', ''CHAT_COMPLETIONS'', ''N'', :3)'
    USING l_id, l_sg, '&model';
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('SERVICE_OK NOONA_AI_LOCAL -> http://&host:&port/v1 (' || l_apex || ')');
END;
/
EXIT
