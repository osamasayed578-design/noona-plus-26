prompt --application/pages/page_00077
begin
--   Manifest
--     PAGE: 00077
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>77
,p_name=>'API Endpoints'
,p_alias=>'API-ENDPOINTS'
,p_step_title=>'نقاط النهاية والتوثيق'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000732)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000835)
,p_plug_name=>'العنوان الأساسي'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>العنوان: <code dir="ltr">https://&lt;الخادم&gt;/ords/noona/v1/</code> — توصيف OpenAPI 3 (لـ Postman وSwagger): <code dir="ltr">GET /ords/noona/v1/openapi.json</code></p><pre dir="ltr" class="nn-csv">curl -X POST https://server/ords/noona/v1/token -H "Content-Type: application/json" \',
'     -d ''{"client_id":"nn_...","client_secret":"..."}''',
'',
'curl https://server/ords/noona/v1/customers?q=النور -H "Authorization: Bearer &lt;token&gt;"',
'',
'curl -X POST https://server/ords/noona/v1/sales-invoices -H "Authorization: Bearer &lt;token&gt;" \',
'     -H "Idempotency-Key: ORDER-1001" -H "Content-Type: application/json" \',
'     -d ''{"customer":12,"lines":[{"sku":"6281000000011","qty":2,"price":50}]}''</pre><p class="nn-hint">الأخطاء: <code dir="ltr">{"error":{"code","message","requestId"}}</code> — 400 طلب غير صالح، 401 دخول، 403 صلاحية أو IP، 404 غير موجود، 409 تعارض مفتاح منع التكرار، 422 قاعدة عمل، 429 تجاوز حد الطلبات.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000836)
,p_plug_name=>'نقاط النهاية'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_api_pkg.endpoints_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
