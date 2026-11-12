prompt --application/pages/page_00070
begin
--   Manifest
--     PAGE: 00070
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>145
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>70
,p_name=>'My Tasks'
,p_alias=>'MY-TASKS'
,p_step_title=>'مهامي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.addEventListener(''click'', function (e) {',
'  var b = e.target.closest(''[data-line][data-req]''); if (!b) return;',
'  b.disabled = true; apex.submit({ request: b.getAttribute(''data-req''), set: { P70_LINE: b.getAttribute(''data-line'') } });',
'});'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000314)
,p_plug_name=>'المهام'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000315)
,p_name=>'P70_LINE'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820280000000314)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000316)
,p_plug_name=>'مهامي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_aut_pkg.tech_tasks_html(noona_aut_pkg.my_technician);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000317)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Start'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_aut_pkg.line_action(to_number(:P70_LINE), ''START'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''LINE_START'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'بدأ العمل على البند'
,p_internal_uid=>91820280000000317
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000318)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Done'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_aut_pkg.line_action(to_number(:P70_LINE), ''DONE'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''LINE_DONE'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'تم إنجاز البند'
,p_internal_uid=>91820280000000318
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000319)
,p_branch_action=>'f?p=&APP_ID.:70:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
