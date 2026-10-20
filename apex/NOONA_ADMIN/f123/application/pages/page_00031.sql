prompt --application/pages/page_00031
begin
--   Manifest
--     PAGE: 00031
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
 p_id=>31
,p_name=>'User'
,p_alias=>'USER'
,p_step_title=>'المستخدم'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000279)
,p_plug_name=>'بيانات المستخدم'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000280)
,p_name=>'P31_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000281)
,p_name=>'P31_USERNAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
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
 p_id=>wwv_flow_imp.id(91820262000000282)
,p_name=>'P31_DISPLAY_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
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
 p_id=>wwv_flow_imp.id(91820262000000283)
,p_name=>'P31_EMAIL'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
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
 p_id=>wwv_flow_imp.id(91820262000000284)
,p_name=>'P31_COMPANY_ID'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_prompt=>'الشركة الافتراضية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_COMPANIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000004)||'.'
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
 p_id=>wwv_flow_imp.id(91820262000000285)
,p_name=>'P31_BRANCH_ID'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_prompt=>'الفرع الافتراضي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select b.name_ar || '' - '' || nvl(c.trade_name_ar, c.legal_name_ar) d, b.id r from org_branch b join org_company c on c.id = b.company_id where b.status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000286)
,p_name=>'P31_CLEARANCE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_prompt=>'مستوى السرية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عام;PUBLIC,داخلي;INTERNAL,سري;CONFIDENTIAL,سري جداً;SECRET,مقيد للغاية;HIGHLY_RESTRICTED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000287)
,p_name=>'P31_IS_ADMIN'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_prompt=>'مسؤول المؤسسة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نعم;Y,لا;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000288)
,p_name=>'P31_PASSWORD'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_prompt=>'كلمة المرور (10 أحرف: كبير وصغير ورقم)'
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
 p_id=>wwv_flow_imp.id(91820262000000289)
,p_name=>'P31_STATUS'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000291)
,p_validation_name=>'P31_USERNAME required (CREATE)'
,p_validation_sequence=>11
,p_validation=>'P31_USERNAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000290)
,p_associated_item=>wwv_flow_imp.id(91820262000000281)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000292)
,p_validation_name=>'P31_DISPLAY_NAME required (CREATE)'
,p_validation_sequence=>12
,p_validation=>'P31_DISPLAY_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000290)
,p_associated_item=>wwv_flow_imp.id(91820262000000282)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000293)
,p_validation_name=>'P31_EMAIL required (CREATE)'
,p_validation_sequence=>13
,p_validation=>'P31_EMAIL'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000290)
,p_associated_item=>wwv_flow_imp.id(91820262000000283)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000294)
,p_validation_name=>'P31_COMPANY_ID required (CREATE)'
,p_validation_sequence=>14
,p_validation=>'P31_COMPANY_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000290)
,p_associated_item=>wwv_flow_imp.id(91820262000000284)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000290)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء المستخدم'
,p_button_position=>'NEXT'
,p_button_condition=>':P31_ID is null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000296)
,p_validation_name=>'P31_USERNAME required (SAVE)'
,p_validation_sequence=>16
,p_validation=>'P31_USERNAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000295)
,p_associated_item=>wwv_flow_imp.id(91820262000000281)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000297)
,p_validation_name=>'P31_DISPLAY_NAME required (SAVE)'
,p_validation_sequence=>17
,p_validation=>'P31_DISPLAY_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000295)
,p_associated_item=>wwv_flow_imp.id(91820262000000282)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000298)
,p_validation_name=>'P31_EMAIL required (SAVE)'
,p_validation_sequence=>18
,p_validation=>'P31_EMAIL'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000295)
,p_associated_item=>wwv_flow_imp.id(91820262000000283)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000299)
,p_validation_name=>'P31_COMPANY_ID required (SAVE)'
,p_validation_sequence=>19
,p_validation=>'P31_COMPANY_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000295)
,p_associated_item=>wwv_flow_imp.id(91820262000000284)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000295)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ التعديلات'
,p_button_position=>'NEXT'
,p_button_condition=>':P31_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000301)
,p_validation_name=>'P31_USERNAME required (SET_PASSWORD)'
,p_validation_sequence=>21
,p_validation=>'P31_USERNAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000300)
,p_associated_item=>wwv_flow_imp.id(91820262000000281)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000302)
,p_validation_name=>'P31_DISPLAY_NAME required (SET_PASSWORD)'
,p_validation_sequence=>22
,p_validation=>'P31_DISPLAY_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000300)
,p_associated_item=>wwv_flow_imp.id(91820262000000282)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000303)
,p_validation_name=>'P31_EMAIL required (SET_PASSWORD)'
,p_validation_sequence=>23
,p_validation=>'P31_EMAIL'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000300)
,p_associated_item=>wwv_flow_imp.id(91820262000000283)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000304)
,p_validation_name=>'P31_COMPANY_ID required (SET_PASSWORD)'
,p_validation_sequence=>24
,p_validation=>'P31_COMPANY_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000300)
,p_associated_item=>wwv_flow_imp.id(91820262000000284)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000300)
,p_button_sequence=>25
,p_button_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_button_name=>'SET_PASSWORD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تعيين كلمة المرور'
,p_button_position=>'NEXT'
,p_button_condition=>':P31_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000305)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000279)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000306)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load User'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P31_ID is not null then',
'    select u.username, u.display_name, u.email, m.default_company_id, m.default_branch_id, m.clearance_level,',
'           m.is_tenant_admin, noona_ui_pkg.status_label(m.status_code)',
'      into :P31_USERNAME, :P31_DISPLAY_NAME, :P31_EMAIL, :P31_COMPANY_ID, :P31_BRANCH_ID, :P31_CLEARANCE,',
'           :P31_IS_ADMIN, :P31_STATUS',
'      from sec_user_membership m join sec_user u on u.id = m.user_id where m.id = :P31_ID;',
'else',
'    :P31_CLEARANCE := nvl(:P31_CLEARANCE, ''INTERNAL''); :P31_IS_ADMIN := nvl(:P31_IS_ADMIN, ''N'');',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000306
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000307)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create User'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P31_ID := noona_sec_admin_pkg.create_user(p_username => :P31_USERNAME, p_display_name => :P31_DISPLAY_NAME,',
'    p_email => :P31_EMAIL, p_company_id => :P31_COMPANY_ID, p_branch_id => :P31_BRANCH_ID,',
'    p_is_tenant_admin => :P31_IS_ADMIN, p_clearance => :P31_CLEARANCE);',
'-- كلمة المرور المحلية (SEC_CREDENTIAL)؛ بدونها يدخل المستخدم بحساب APEX إن وجد',
'if :P31_PASSWORD is not null then',
'    noona_sec_admin_pkg.set_password(p_membership_id => :P31_ID, p_password => :P31_PASSWORD);',
'end if;',
':P31_PASSWORD := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000290)
,p_process_success_message=>'تم إنشاء المستخدم؛ امنحه الأدوار المناسبة'
,p_internal_uid=>91820262000000307
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000308)
,p_process_sequence=>15
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Set Password'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.set_password(p_membership_id => :P31_ID, p_password => :P31_PASSWORD);',
':P31_PASSWORD := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000300)
,p_process_success_message=>'تم تعيين كلمة المرور وفك قفل الحساب'
,p_internal_uid=>91820262000000308
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000309)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save User'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.update_member(p_membership_id => :P31_ID, p_display_name => :P31_DISPLAY_NAME, p_email => :P31_EMAIL,',
'    p_company_id => :P31_COMPANY_ID, p_branch_id => :P31_BRANCH_ID, p_clearance => :P31_CLEARANCE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000295)
,p_process_success_message=>'تم حفظ بيانات المستخدم'
,p_internal_uid=>91820262000000309
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000310)
,p_plug_name=>'أدوار المستخدم'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select g.id, r.name_ar as role_name, r.code, case when s.scope_type = ''ALL_TENANT'' then ''كل المؤسسة''',
'       else (select nvl(c.trade_name_ar, c.legal_name_ar) from org_company c where c.id = s.company_id) end as scope,',
'       g.effective_from, g.effective_to, g.reason, noona_ui_pkg.status_badge(g.status_code) as status_html',
'  from sec_role_grant g join sec_role r on r.id = g.role_id',
'  left join sec_data_scope s on s.role_grant_id = g.id',
' where g.membership_id = :P31_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أدوار المستخدم'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000311)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_owner=>'NOONA'
,p_internal_uid=>91820262000000311
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000313)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000314)
,p_db_column_name=>'ROLE_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الدور'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000315)
,p_db_column_name=>'CODE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000316)
,p_db_column_name=>'SCOPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'نطاق البيانات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000317)
,p_db_column_name=>'EFFECTIVE_FROM'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'من'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000318)
,p_db_column_name=>'EFFECTIVE_TO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'إلى'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000319)
,p_db_column_name=>'REASON'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'السبب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000320)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000312)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'312'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ROLE_NAME:CODE:SCOPE:EFFECTIVE_FROM:EFFECTIVE_TO:REASON:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000321)
,p_plug_name=>'منح دور / سحب / حالة الحساب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000322)
,p_name=>'P31_ROLE_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000321)
,p_prompt=>'الدور'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from sec_role where status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000323)
,p_name=>'P31_SCOPE_COMPANY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000321)
,p_prompt=>'نطاق البيانات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_COMPANIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000004)||'.'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- كل شركات المؤسسة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000324)
,p_name=>'P31_REVOKE_ID'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000321)
,p_prompt=>'منح للسحب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.name_ar || '' ('' || r.code || '')'' d, g.id r from sec_role_grant g join sec_role r on r.id = g.role_id where g.membership_id = :P31_ID and g.status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000325)
,p_name=>'P31_NEW_STATUS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000321)
,p_prompt=>'تغيير حالة الحساب إلى'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,معلق;SUSPENDED,منتهي;ENDED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000326)
,p_name=>'P31_REASON'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000321)
,p_prompt=>'السبب (إلزامي للسحب وتغيير الحالة)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000327)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000321)
,p_button_name=>'GRANT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'منح الدور'
,p_button_position=>'NEXT'
,p_button_condition=>':P31_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000328)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000321)
,p_button_name=>'REVOKE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'سحب المنح'
,p_button_position=>'NEXT'
,p_button_condition=>':P31_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000329)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000321)
,p_button_name=>'CHANGE_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير الحالة'
,p_button_position=>'NEXT'
,p_button_condition=>':P31_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000330)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Grant Role'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_sec_admin_pkg.grant_role(p_membership_id => :P31_ID, p_role_id => :P31_ROLE_ID,',
'                                           p_company_id => :P31_SCOPE_COMPANY, p_reason => :P31_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000327)
,p_process_success_message=>'تم منح الدور'
,p_internal_uid=>91820262000000330
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000331)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Revoke Grant'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.revoke_grant(p_grant_id => :P31_REVOKE_ID, p_reason => :P31_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000328)
,p_process_success_message=>'تم سحب المنح'
,p_internal_uid=>91820262000000331
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000332)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Change Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.set_member_status(p_membership_id => :P31_ID, p_status => :P31_NEW_STATUS, p_reason => :P31_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000329)
,p_process_success_message=>'تم تغيير حالة الحساب'
,p_internal_uid=>91820262000000332
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000333)
,p_branch_action=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.::P31_ID:&P31_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
