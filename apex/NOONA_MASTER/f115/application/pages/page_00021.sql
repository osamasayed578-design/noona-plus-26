prompt --application/pages/page_00021
begin
--   Manifest
--     PAGE: 00021
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>115
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>21
,p_name=>'Reset Password'
,p_alias=>'RESET-PASSWORD'
,p_step_title=>'استعادة كلمة المرور - نونا بلس'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_step_template=>2977628563533209425
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000071)
,p_plug_name=>'استعادة كلمة المرور'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">أدخل اسم الدخول أو البريد المسجل؛ نرسل رمزاً صالحاً 15 دقيقة إلى بريدك.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P21_TOKEN is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000072)
,p_name=>'P21_LOGIN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820263000000071)
,p_prompt=>'اسم الدخول أو البريد الإلكتروني'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>320
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000073)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820263000000071)
,p_button_name=>'SEND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال الرمز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000074)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Send'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P21_TOKEN := noona_account_pkg.request_reset(:P21_LOGIN, owa_util.get_cgi_env(''REMOTE_ADDR''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000073)
,p_process_success_message=>'إن كان الحساب مسجلاً فقد أرسلنا رمزاً إلى بريده'
,p_internal_uid=>91820263000000074
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000075)
,p_plug_name=>'كلمة مرور جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">أدخل الرمز المرسل إلى بريدك وكلمة المرور الجديدة (10 أحرف على الأقل: حرف كبير وصغير ورقم).</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P21_TOKEN is not null and :P21_DONE is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000076)
,p_name=>'P21_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820263000000075)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>10
,p_cMaxlength=>6
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000077)
,p_name=>'P21_NEW'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820263000000075)
,p_prompt=>'كلمة المرور الجديدة'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000078)
,p_name=>'P21_NEW2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820263000000075)
,p_prompt=>'تأكيد كلمة المرور'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000079)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820263000000075)
,p_button_name=>'SET'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تغيير كلمة المرور'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000080)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820263000000075)
,p_button_name=>'AGAIN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طلب رمز جديد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000081)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Set'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_account_pkg.complete_reset(:P21_TOKEN, :P21_CODE, :P21_NEW, :P21_NEW2);',
':P21_NEW := null; :P21_NEW2 := null; :P21_DONE := ''Y'';'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000079)
,p_internal_uid=>91820263000000081
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000082)
,p_process_sequence=>25
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Again'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P21_TOKEN := null; :P21_CODE := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000080)
,p_internal_uid=>91820263000000082
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000083)
,p_plug_name=>'تم'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P21_DONE = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div class="nn-sgn-done"><span class="fa fa-check-circle"></span><h2>تم تغيير كلمة المرور</h2>''',
'  || ''<a class="t-Button t-Button--hot t-Button--large" href="f?p='' || :APP_ID || '':1:0">الدخول إلى النظام</a></div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000084)
,p_name=>'P21_TOKEN'
,p_item_sequence=>900
,p_item_plug_id=>wwv_flow_imp.id(91820263000000071)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000085)
,p_name=>'P21_DONE'
,p_item_sequence=>900
,p_item_plug_id=>wwv_flow_imp.id(91820263000000071)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820263000000086)
,p_branch_action=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:::'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
