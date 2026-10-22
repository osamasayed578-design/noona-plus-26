prompt --application/pages/page_00032
begin
--   Manifest
--     PAGE: 00032
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>135
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>32
,p_name=>'Order Print'
,p_alias=>'ORDER-PRINT'
,p_step_title=>'طباعة أمر الإنتاج'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000152)
,p_plug_name=>'الطباعة'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000153)
,p_name=>'P32_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820270000000152)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000154)
,p_name=>'P32_KIND'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820270000000152)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000155)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000152)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000156)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820270000000152)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع للأمر'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:31:P31_ID:&P32_ID.'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000157)
,p_plug_name=>'المستند'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return case :P32_KIND when ''COST'' then noona_mfg_pkg.order_cost_sheet(:P32_ID) else noona_mfg_pkg.order_print(:P32_ID) end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
