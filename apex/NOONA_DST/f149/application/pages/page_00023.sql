prompt --application/pages/page_00023
begin
--   Manifest
--     PAGE: 00023
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>23
,p_name=>'Collection'
,p_alias=>'COLLECTION'
,p_step_title=>'تحصيل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000284)
,p_plug_name=>'التحصيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000285)
,p_name=>'P23_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000284)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000286)
,p_plug_name=>'البيانات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_h varchar2(32767);',
'begin',
'  for c in (select * from dst_collection where id = :P23_ID and company_id = noona_dst_pkg.company) loop',
'    l_h := ''<table class="nn-table"><tbody>''',
'      || ''<tr><th>الرقم</th><td>'' || c.doc_no || '' · '' || noona_dst_pkg.badge(c.status_code) || ''</td></tr>''',
'      || ''<tr><th>المندوب</th><td>'' || apex_escape.html(noona_dst_pkg.rep_label(c.rep_id)) || ''</td></tr>''',
'      || ''<tr><th>المحل</th><td>'' || apex_escape.html(noona_dst_pkg.shop_label(c.shop_id)) || ''</td></tr>''',
'      || ''<tr><th>الطريقة</th><td>'' || noona_dst_pkg.label(c.payment_method) || ''</td></tr>''',
'      || ''<tr><th>المبلغ</th><td><b>'' || to_char(c.amount, ''FM999G999G990D00'') || ''</b></td></tr>''',
'      || ''<tr><th>رقم المرجع</th><td><b>'' || apex_escape.html(c.reference_no) || ''</b></td></tr>''',
'      || ''<tr><th>البنك</th><td>'' || apex_escape.html(c.bank_name) || ''</td></tr>''',
'      || ''<tr><th>استحقاق الشيك</th><td>'' || to_char(c.cheque_due_date, ''YYYY-MM-DD'') || ''</td></tr>''',
'      || ''<tr><th>ملاحظات</th><td>'' || apex_escape.html(c.notes) || ''</td></tr></tbody></table>'';',
'  end loop;',
'  return l_h;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000287)
,p_plug_name=>'التأكيد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">طابق رقم الإشعار أو الشيك مع كشف البنك ثم أكد: يرحل سند القبض على حساب البنك ويخصم من رصيد المحل. الرفض يبقي الرصيد على المحل.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_dst_pkg.collection_status(:P23_ID) = ''PENDING_VERIFY'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000288)
,p_name=>'P23_BANK'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000287)
,p_prompt=>'حساب البنك المستلم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.name_ar || '' · '' || a.account_no_masked d, a.id r from csh_bank_account a where a.company_id = noona_dst_pkg.company and a.status_code = ''ACTIVE'' order by a.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الحساب الافتراضي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000289)
,p_name=>'P23_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000287)
,p_prompt=>'سبب الرفض'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000290)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000287)
,p_button_name=>'VERIFY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تأكيد وترحيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000291)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820300000000287)
,p_button_name=>'REJECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000292)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Verify'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dst_pkg.verify_collection(:P23_ID, to_number(:P23_BANK));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000290)
,p_process_success_message=>'تم تأكيد التحصيل وترحيله'
,p_internal_uid=>91820300000000292
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000293)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dst_pkg.reject_collection(:P23_ID, :P23_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000291)
,p_process_success_message=>'تم رفض التحصيل'
,p_internal_uid=>91820300000000293
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000294)
,p_branch_action=>'f?p=&APP_ID.:22:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
