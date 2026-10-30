-- =============================================================================
-- NOONA PLUS ERP | وحدة ORDS لوكيل التخزين المحلي v1
--   تشغيل بحساب التطبيق بعد ترقية 37:  sqlplus NOONA_APP@//host:1521/PDB @ords/agent_v1.sql
--   العنوان: https://<server>/ords/noona/agent/v1/   والمصادقة بترويسة X-Agent-Key
--     POST hello              بيانات الجهاز والمساحة (نبض كل دقيقة)
--     GET  jobs               المهام المطلوبة (PUT احفظ / GET أرسل / TEST)
--     GET  file/:id           محتوى ملف ليحفظه الوكيل
--     POST file/:id           الوكيل يرسل ملفاً طُلب للعرض (ترويسة X-Job-Id)
--     POST jobs/:id/done      نتيجة المهمة {ok, sha256, ref, error}
--   كل المنطق في NOONA_DMS_AGENT_PKG
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
BEGIN
  ORDS.enable_schema(p_enabled => TRUE, p_url_mapping_type => 'BASE_PATH', p_url_mapping_pattern => 'noona', p_auto_rest_auth => TRUE);
  ORDS.delete_module(p_module_name => 'noona.agent.v1');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
DECLARE
  c_mod CONSTANT VARCHAR2(30) := 'noona.agent.v1';
  PROCEDURE handler(p_template VARCHAR2, p_method VARCHAR2, p_call VARCHAR2) IS
  BEGIN
    ORDS.define_handler(p_module_name => c_mod, p_pattern => p_template, p_method => p_method, p_source_type => ORDS.source_type_plsql,
                        p_source => 'BEGIN noona_dms_agent_pkg.' || p_call || '; END;');
    ORDS.define_parameter(p_module_name => c_mod, p_pattern => p_template, p_method => p_method, p_name => 'X-Agent-Key',
                          p_bind_variable_name => 'akey', p_source_type => 'HEADER', p_param_type => 'STRING', p_access_method => 'IN');
    ORDS.define_parameter(p_module_name => c_mod, p_pattern => p_template, p_method => p_method, p_name => 'X-Job-Id',
                          p_bind_variable_name => 'jobid', p_source_type => 'HEADER', p_param_type => 'STRING', p_access_method => 'IN');
  END handler;
BEGIN
  ORDS.define_module(p_module_name => c_mod, p_base_path => '/agent/v1/', p_items_per_page => 0, p_status => 'PUBLISHED',
                     p_comments => 'NOONA PLUS local storage agent v1');
  ORDS.define_template(p_module_name => c_mod, p_pattern => 'hello');
  handler('hello', 'POST', 'api_hello(:akey, :body_text, :status_code)');
  ORDS.define_template(p_module_name => c_mod, p_pattern => 'jobs');
  handler('jobs', 'GET', 'api_jobs(:akey, :status_code)');
  ORDS.define_template(p_module_name => c_mod, p_pattern => 'jobs/:id/done');
  handler('jobs/:id/done', 'POST', 'api_done(:akey, TO_NUMBER(:id), :body_text, :status_code)');
  ORDS.define_template(p_module_name => c_mod, p_pattern => 'file/:id');
  handler('file/:id', 'GET', 'api_download(:akey, TO_NUMBER(:id), :status_code)');
  handler('file/:id', 'POST', 'api_upload(:akey, TO_NUMBER(:id), TO_NUMBER(:jobid), :body, :status_code)');
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ORDS module noona.agent.v1 published at /ords/noona/agent/v1/');
END;
/
EXIT
