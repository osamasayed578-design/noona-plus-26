prompt --application/pages/page_00041
begin
--   Manifest
--     PAGE: 00041
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>41
,p_name=>'Expiring Documents'
,p_alias=>'EXPIRING'
,p_step_title=>'المستندات المنتهية والقريبة الانتهاء'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000154)
,p_plug_name=>'المعايير'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000155)
,p_name=>'P41_DAYS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000154)
,p_prompt=>'تنتهي خلال'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:30 يوماً;30,60 يوماً;60,90 يوماً;90,180 يوماً;180,المنتهية فقط;0'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000156)
,p_plug_name=>'المستندات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dms_pkg.expiring_html(to_number(nvl(:P41_DAYS, ''30'')), replace(apex_page.get_url(p_page => 11, p_clear_cache => ''11'', p_items => ''P11_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
