prompt --application/pages/page_00080
begin
--   Manifest
--     PAGE: 00080
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
 p_id=>80
,p_name=>'Bank Reconciliation'
,p_alias=>'BANK-RECON'
,p_step_title=>'مطابقة كشف الحساب'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000880)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(document).on(''click'', ''.nn-recon-ok, .nn-recon-no, .nn-recon-ign'', function () { var b = $(this); if (b.hasClass(''nn-recon-ign'')) { apex.item(''P80_LINE'').setValue(b.data(''id'')); apex.submit(''IGNORE''); } else { apex.item(''P80_MATCH'').setValue(b.data(''id'')); apex.submit(b.hasClass(''nn-recon-ok'') ? ''OK'' : ''NO''); } });'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000893)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000894)
,p_name=>'P80_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000893)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000895)
,p_name=>'P80_MATCH'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820266000000893)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000896)
,p_name=>'P80_LINE'
,p_item_sequence=>3
,p_item_plug_id=>wwv_flow_imp.id(91820266000000893)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000897)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000893)
,p_button_name=>'CONFIRM_ALL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد كل المقترحات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000898)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000893)
,p_button_name=>'AUTO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إعادة المطابقة التلقائية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000899)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820266000000893)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'الكشوف'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:79:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000900)
,p_plug_name=>'الكشف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.statement_html(to_number(:P80_ID));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000901)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Confirm all'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_conn_pkg.confirm_all(to_number(:P80_ID));',
'    apex_application.g_print_success_message := ''تم اعتماد '' || l || '' مطابقة'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000897)
,p_internal_uid=>91820266000000901
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000902)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Auto'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_conn_pkg.auto_match(to_number(:P80_ID));',
'    apex_application.g_print_success_message := ''مقترحات جديدة: '' || l;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000898)
,p_internal_uid=>91820266000000902
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000903)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Confirm'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_conn_pkg.confirm_match(to_number(:P80_MATCH));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''OK'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'تم اعتماد المطابقة'
,p_internal_uid=>91820266000000903
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000904)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_conn_pkg.reject_match(to_number(:P80_MATCH));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''NO'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'تم إلغاء المطابقة'
,p_internal_uid=>91820266000000904
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000905)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Ignore'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_conn_pkg.ignore_line(to_number(:P80_LINE));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''IGNORE'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'تم تجاهل السطر'
,p_internal_uid=>91820266000000905
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000906)
,p_branch_action=>'f?p=&APP_ID.:80:&SESSION.::&DEBUG.::P80_ID:&P80_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
