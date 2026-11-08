prompt --application/pages/page_00045
begin
--   Manifest
--     PAGE: 00045
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>45
,p_name=>'Owner Statement'
,p_alias=>'OWNER-STATEMENT'
,p_step_title=>'كشف حساب المالك'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000859)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001121)
,p_plug_name=>'الكشف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prp_pkg.statement_html(:P45_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001122)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001123)
,p_name=>'P45_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000001122)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001124)
,p_name=>'P45_PLACE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001122)
,p_prompt=>'التحويل من'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''صندوق: '' || name_ar d, ''BOX:'' || id r from csh_cash_box where company_id = noona_res_pkg.company and status_code = ''ACTIVE'' union all select ''بنك: '' || name_ar, ''BANK:'' || id from csh_bank_account where company_id = noona_res_pkg.company and status_code = ''ACTIVE'''
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001125)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001122)
,p_button_name=>'APPROVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد الكشف'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prp_pkg.statement_status(:P45_ID) = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001126)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000001122)
,p_button_name=>'REMIT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تحويل الصافي للمالك'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prp_pkg.statement_status(:P45_ID) in (''APPROVED'', ''SENT'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001127)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000001122)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001128)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820273000001122)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'الملاك'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:44:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001129)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prp_pkg.approve_statement(:P45_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001125)
,p_process_success_message=>'تم اعتماد الكشف وقيد الأتعاب'
,p_internal_uid=>91820273000001129
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001130)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remit'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prp_pkg.remit_statement(:P45_ID, :P45_PLACE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001126)
,p_process_success_message=>'تم التحويل للمالك'
,p_internal_uid=>91820273000001130
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000001131)
,p_branch_action=>'f?p=&APP_ID.:45:&SESSION.::&DEBUG.::P45_ID:&P45_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
