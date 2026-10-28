-- =============================================================================
-- NOONA PLUS ERP | وحدة ORDS لواجهة REST العامة v1
--   تشغيل بحساب التطبيق (بعد ترقية 33 والمرادفات):  sqlplus NOONA_APP@//host:1521/PDB @ords/api_v1.sql
--   العنوان: https://<server>/ords/noona/v1/...
--     POST /token                  {client_id, client_secret} -> رمز Bearer
--     GET  /openapi.json           توصيف الواجهة
--     GET|POST|DELETE /<resource>[/<id>]   كل المسارات في سجل نقاط النهاية (API_ENDPOINT)
--   كل المنطق (المصادقة والصلاحيات وحد المعدل ومنع التكرار والسجل) في NOONA_API_PKG.serve
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
BEGIN
  ORDS.enable_schema(p_enabled => TRUE, p_url_mapping_type => 'BASE_PATH', p_url_mapping_pattern => 'noona', p_auto_rest_auth => TRUE);
  ORDS.delete_module(p_module_name => 'noona.api.v1');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
DECLARE
  c_mod CONSTANT VARCHAR2(30) := 'noona.api.v1';
  PROCEDURE handler(p_template VARCHAR2, p_method VARCHAR2, p_route VARCHAR2, p_id VARCHAR2) IS
  BEGIN
    ORDS.define_handler(
      p_module_name => c_mod, p_pattern => p_template, p_method => p_method, p_source_type => ORDS.source_type_plsql,
      p_source => 'BEGIN noona_api_pkg.serve(p_method => ''' || p_method || ''', p_route => ' || p_route || ', p_id => ' || p_id
               || ', p_body => ' || CASE WHEN p_method IN ('POST', 'PUT') THEN ':body_text' ELSE 'NULL' END
               || ', p_auth => :auth, p_idem => :idem, p_q => :q, p_limit => :limit, p_offset => :offset, p_from => :from_date, p_to => :to_date,'
               || ' p_filter => NVL(:status, :customer), p_status => :status_code); END;');
    ORDS.define_parameter(p_module_name => c_mod, p_pattern => p_template, p_method => p_method, p_name => 'Authorization', p_bind_variable_name => 'auth',
                          p_source_type => 'HEADER', p_param_type => 'STRING', p_access_method => 'IN');
    ORDS.define_parameter(p_module_name => c_mod, p_pattern => p_template, p_method => p_method, p_name => 'Idempotency-Key', p_bind_variable_name => 'idem',
                          p_source_type => 'HEADER', p_param_type => 'STRING', p_access_method => 'IN');
    ORDS.define_parameter(p_module_name => c_mod, p_pattern => p_template, p_method => p_method, p_name => 'from', p_bind_variable_name => 'from_date',
                          p_source_type => 'URI', p_param_type => 'STRING', p_access_method => 'IN');
    ORDS.define_parameter(p_module_name => c_mod, p_pattern => p_template, p_method => p_method, p_name => 'to', p_bind_variable_name => 'to_date',
                          p_source_type => 'URI', p_param_type => 'STRING', p_access_method => 'IN');
  END handler;
BEGIN
  ORDS.define_module(p_module_name => c_mod, p_base_path => '/v1/', p_items_per_page => 0, p_status => 'PUBLISHED',
                     p_comments => 'NOONA PLUS public REST API v1');
  ORDS.define_template(p_module_name => c_mod, p_pattern => 'token');
  handler('token', 'POST', '''token''', 'NULL');
  ORDS.define_template(p_module_name => c_mod, p_pattern => 'openapi.json');
  handler('openapi.json', 'GET', '''openapi.json''', 'NULL');
  ORDS.define_template(p_module_name => c_mod, p_pattern => ':route');
  handler(':route', 'GET', ':route', 'NULL');
  handler(':route', 'POST', ':route', 'NULL');
  ORDS.define_template(p_module_name => c_mod, p_pattern => ':route/:id');
  handler(':route/:id', 'GET', ':route', ':id');
  handler(':route/:id', 'POST', ':route', ':id');
  handler(':route/:id', 'DELETE', ':route', ':id');
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ORDS module noona.api.v1 published at /ords/noona/v1/');
END;
/
EXIT
