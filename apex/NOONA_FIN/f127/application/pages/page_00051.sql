prompt --application/pages/page_00051
begin
--   Manifest
--     PAGE: 00051
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>51
,p_name=>'Income by Year'
,p_alias=>'INCOME-YEARS'
,p_step_title=>'قائمة الدخل لعدة سنوات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000412)
,p_plug_name=>'معايير التقرير'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000413)
,p_name=>'P51_YEARS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000412)
,p_prompt=>'عدد السنوات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سنتان;2,3 سنوات;3,4 سنوات;4,5 سنوات;5,6 سنوات;6'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000414)
,p_name=>'P51_SAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000412)
,p_prompt=>'المقارنة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:السنة كاملة (والحالية حتى تاريخه);N,الفترة نفسها من كل سنة (من يناير حتى اليوم);Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000415)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000412)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000416)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000412)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000417)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P51_YEARS := nvl(:P51_YEARS, ''3'');',
':P51_SAME := nvl(:P51_SAME, ''N'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000417
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000418)
,p_plug_name=>'قائمة الدخل لعدة سنوات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_fin_rpt_pkg.income_years(to_number(:P51_YEARS), :P51_SAME);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
