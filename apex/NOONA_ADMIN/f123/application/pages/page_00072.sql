prompt --application/pages/page_00072
begin
--   Manifest
--     PAGE: 00072
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
 p_id=>72
,p_name=>'API Requests'
,p_alias=>'API-REQUESTS'
,p_step_title=>'سجل طلبات API'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000732)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000770)
,p_plug_name=>'تصفية'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000771)
,p_name=>'P72_CLIENT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000770)
,p_prompt=>'العميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || client_id || '')'' d, id r from api_client order by id desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- كل العملاء -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000772)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000770)
,p_button_name=>'GO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000773)
,p_plug_name=>'الطلبات (آخر 200)'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_api_pkg.requests_html(to_number(:P72_CLIENT));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000774)
,p_plug_name=>'ملاحظة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">لا يسجل جسم الطلب ولا الأسرار. معرف الطلب يظهر للعميل في كل رد خطأ وفي ترويسة <code dir="ltr">X-Request-Id</code> لتتبع المشكلة.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);

wwv_flow_imp.component_end;
end;
/
