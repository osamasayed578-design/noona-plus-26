prompt --application/pages/page_00004
begin
--   Manifest
--     PAGE: 00004
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>125
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>4
,p_name=>'Provision Tenant'
,p_alias=>'PROVISION'
,p_step_title=>'تجهيز مؤسسة جديدة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820265000000003)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000064)
,p_plug_name=>'بيانات المؤسسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000065)
,p_name=>'P4_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'رمز المؤسسة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000066)
,p_name=>'P4_SLUG'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'المعرف في الرابط (حروف إنجليزية صغيرة)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>50
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000067)
,p_name=>'P4_NAME_AR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'الاسم بالعربية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000068)
,p_name=>'P4_NAME_EN'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'الاسم بالإنجليزية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000069)
,p_name=>'P4_COUNTRY'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'الدولة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_COUNTRIES'
,p_lov=>'.'||wwv_flow_imp.id(91820265000000007)||'.'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000070)
,p_name=>'P4_CURRENCY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'العملة الأساسية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_CURRENCIES'
,p_lov=>'.'||wwv_flow_imp.id(91820265000000006)||'.'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000071)
,p_name=>'P4_TRIAL'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'نسخة تجريبية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000072)
,p_name=>'P4_COMPANY_CODE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'رمز الشركة الأولى'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>50
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000073)
,p_name=>'P4_COMPANY_NAME'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'اسم الشركة الأولى'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000074)
,p_name=>'P4_MAX_USERS'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'الحد الأقصى للمستخدمين'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000075)
,p_name=>'P4_MAX_BRANCHES'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'الحد الأقصى للفروع'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000076)
,p_name=>'P4_MAX_COMPANIES'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820265000000064)
,p_prompt=>'الحد الأقصى للشركات'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000077)
,p_plug_name=>'مسؤول المؤسسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000078)
,p_name=>'P4_ADMIN_USER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000077)
,p_prompt=>'اسم الدخول'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000079)
,p_name=>'P4_ADMIN_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000077)
,p_prompt=>'الاسم الكامل'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000080)
,p_name=>'P4_ADMIN_EMAIL'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820265000000077)
,p_prompt=>'البريد الإلكتروني'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000081)
,p_name=>'P4_ADMIN_PASSWORD'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820265000000077)
,p_prompt=>'كلمة المرور الأولى'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820265000000083)
,p_validation_name=>'P4_ADMIN_USER required (PROVISION)'
,p_validation_sequence=>18
,p_validation=>'P4_ADMIN_USER'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820265000000082)
,p_associated_item=>wwv_flow_imp.id(91820265000000078)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820265000000084)
,p_validation_name=>'P4_ADMIN_NAME required (PROVISION)'
,p_validation_sequence=>19
,p_validation=>'P4_ADMIN_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820265000000082)
,p_associated_item=>wwv_flow_imp.id(91820265000000079)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820265000000085)
,p_validation_name=>'P4_ADMIN_EMAIL required (PROVISION)'
,p_validation_sequence=>20
,p_validation=>'P4_ADMIN_EMAIL'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820265000000082)
,p_associated_item=>wwv_flow_imp.id(91820265000000080)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820265000000086)
,p_validation_name=>'P4_ADMIN_PASSWORD required (PROVISION)'
,p_validation_sequence=>21
,p_validation=>'P4_ADMIN_PASSWORD'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820265000000082)
,p_associated_item=>wwv_flow_imp.id(91820265000000081)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000082)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000077)
,p_button_name=>'PROVISION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز المؤسسة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000087)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820265000000077)
,p_button_name=>'CANCEL'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000088)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P4_COUNTRY := nvl(:P4_COUNTRY, ''SA''); :P4_CURRENCY := nvl(:P4_CURRENCY, ''SAR'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820265000000088
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000089)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Provision Tenant'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P3_ID := noona_platform_pkg.provision_tenant(',
'    p_tenant_code => :P4_CODE, p_tenant_slug => lower(:P4_SLUG), p_name_ar => :P4_NAME_AR, p_name_en => :P4_NAME_EN,',
'    p_country_code => :P4_COUNTRY, p_base_currency => :P4_CURRENCY, p_admin_username => :P4_ADMIN_USER,',
'    p_admin_email => :P4_ADMIN_EMAIL, p_admin_name => :P4_ADMIN_NAME, p_company_code => :P4_COMPANY_CODE,',
'    p_company_name_ar => :P4_COMPANY_NAME, p_idempotency_key => ''UI-'' || upper(:P4_CODE), p_is_trial => nvl(:P4_TRIAL, ''N''));',
'noona_sec_admin_pkg.platform_set_password(:P4_ADMIN_USER, :P4_ADMIN_PASSWORD, ''كلمة المرور الأولى عند التجهيز'');',
'noona_platform_admin_pkg.set_tenant_limit(:P3_ID, ''USERS'', :P4_MAX_USERS);',
'noona_platform_admin_pkg.set_tenant_limit(:P3_ID, ''BRANCHES'', :P4_MAX_BRANCHES);',
'noona_platform_admin_pkg.set_tenant_limit(:P3_ID, ''COMPANIES'', :P4_MAX_COMPANIES);',
':P4_ADMIN_PASSWORD := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000082)
,p_process_success_message=>'تم تجهيز المؤسسة؛ حدد الوحدات المشترك فيها'
,p_internal_uid=>91820265000000089
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820265000000090)
,p_branch_action=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:&P3_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
,p_branch_when_button_id=>wwv_flow_imp.id(91820265000000082)
);

wwv_flow_imp.component_end;
end;
/
