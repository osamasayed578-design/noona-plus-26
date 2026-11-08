prompt --application/pages/page_00013
begin
--   Manifest
--     PAGE: 00013
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
 p_id=>13
,p_name=>'Branch'
,p_alias=>'BRANCH'
,p_step_title=>'الفرع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000119)
,p_plug_name=>'بيانات الفرع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000120)
,p_name=>'P13_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000121)
,p_name=>'P13_COMPANY_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_prompt=>'الشركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(trade_name_ar, legal_name_ar) d, id r from org_company where status_code not in (''CLOSED'', ''ARCHIVED'') and noona_sec_admin_pkg.can_admin_company(id) = ''Y'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820262000000122)
,p_name=>'P13_CODE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_prompt=>'الرمز'
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
 p_id=>wwv_flow_imp.id(91820262000000123)
,p_name=>'P13_NAME_AR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
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
 p_id=>wwv_flow_imp.id(91820262000000124)
,p_name=>'P13_NAME_EN'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_prompt=>'الاسم بالإنجليزية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000125)
,p_name=>'P13_BRANCH_TYPE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_prompt=>'نوع الفرع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مركز رئيسي;HEAD_OFFICE,فرع;BRANCH,مستودع;WAREHOUSE,معرض;SHOWROOM,مصنع;FACTORY,مكتب موقع;SITE_OFFICE'
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
 p_id=>wwv_flow_imp.id(91820262000000126)
,p_name=>'P13_IS_HEAD_OFFICE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_prompt=>'مركز رئيسي للشركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000127)
,p_name=>'P13_COUNTRY_CODE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_prompt=>'الدولة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_COUNTRIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000007)||'.'
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
 p_id=>wwv_flow_imp.id(91820262000000128)
,p_name=>'P13_STATUS'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000130)
,p_validation_name=>'P13_COMPANY_ID required (CREATE)'
,p_validation_sequence=>10
,p_validation=>'P13_COMPANY_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000129)
,p_associated_item=>wwv_flow_imp.id(91820262000000121)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000131)
,p_validation_name=>'P13_CODE required (CREATE)'
,p_validation_sequence=>11
,p_validation=>'P13_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000129)
,p_associated_item=>wwv_flow_imp.id(91820262000000122)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000132)
,p_validation_name=>'P13_NAME_AR required (CREATE)'
,p_validation_sequence=>12
,p_validation=>'P13_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000129)
,p_associated_item=>wwv_flow_imp.id(91820262000000123)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000133)
,p_validation_name=>'P13_BRANCH_TYPE required (CREATE)'
,p_validation_sequence=>13
,p_validation=>'P13_BRANCH_TYPE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000129)
,p_associated_item=>wwv_flow_imp.id(91820262000000125)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000129)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الفرع'
,p_button_position=>'NEXT'
,p_button_condition=>':P13_ID is null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000135)
,p_validation_name=>'P13_COMPANY_ID required (SAVE)'
,p_validation_sequence=>15
,p_validation=>'P13_COMPANY_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000134)
,p_associated_item=>wwv_flow_imp.id(91820262000000121)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000136)
,p_validation_name=>'P13_CODE required (SAVE)'
,p_validation_sequence=>16
,p_validation=>'P13_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000134)
,p_associated_item=>wwv_flow_imp.id(91820262000000122)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000137)
,p_validation_name=>'P13_NAME_AR required (SAVE)'
,p_validation_sequence=>17
,p_validation=>'P13_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000134)
,p_associated_item=>wwv_flow_imp.id(91820262000000123)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000138)
,p_validation_name=>'P13_BRANCH_TYPE required (SAVE)'
,p_validation_sequence=>18
,p_validation=>'P13_BRANCH_TYPE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000134)
,p_associated_item=>wwv_flow_imp.id(91820262000000125)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000134)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ التعديلات'
,p_button_position=>'NEXT'
,p_button_condition=>':P13_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000139)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000119)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000140)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Branch'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P13_ID is not null then',
'    select company_id, code, name_ar, name_en, branch_type, is_head_office, country_code,',
'           noona_ui_pkg.status_label(status_code)',
'      into :P13_COMPANY_ID, :P13_CODE, :P13_NAME_AR, :P13_NAME_EN, :P13_BRANCH_TYPE, :P13_IS_HEAD_OFFICE,',
'           :P13_COUNTRY_CODE, :P13_STATUS',
'      from org_branch where id = :P13_ID and noona_sec_admin_pkg.can_admin_company(company_id) = ''Y'';',
'elsif :P13_IS_HEAD_OFFICE is null then',
'    :P13_IS_HEAD_OFFICE := ''N'';',
'    -- الشركة الممررة من بطاقة الشركة تبقى؛ وإلا تختار تلقائياً إن كانت شركة واحدة فقط',
'    if :P13_COMPANY_ID is null then',
'        select case when count(*) = 1 then min(id) end into :P13_COMPANY_ID from org_company',
'         where status_code not in (''CLOSED'', ''ARCHIVED'') and noona_sec_admin_pkg.can_admin_company(id) = ''Y'';',
'    end if;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000140
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000141)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Branch'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P13_ID := noona_platform_pkg.create_branch(',
'    p_company_id => :P13_COMPANY_ID, p_code => :P13_CODE, p_name_ar => :P13_NAME_AR, p_name_en => :P13_NAME_EN,',
'    p_branch_type => :P13_BRANCH_TYPE, p_is_head_office => :P13_IS_HEAD_OFFICE, p_country_code => :P13_COUNTRY_CODE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000129)
,p_process_success_message=>'تم إنشاء الفرع'
,p_internal_uid=>91820262000000141
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000142)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Branch'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_security_pkg.assert_permission(''ORG_BRANCH.UPDATE'', :P13_COMPANY_ID);',
'update org_branch set name_ar = :P13_NAME_AR, name_en = :P13_NAME_EN, branch_type = :P13_BRANCH_TYPE',
' where id = :P13_ID and noona_sec_admin_pkg.can_admin_company(company_id) = ''Y'';',
'if sql%rowcount = 0 then raise_application_error(-20100, ''NOONA-SEC-260: لا تملك إدارة هذا الفرع''); end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000134)
,p_process_success_message=>'تم حفظ بيانات الفرع'
,p_internal_uid=>91820262000000142
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000143)
,p_plug_name=>'عنوان الفرع ووسائل الاتصال (فواتير الفرع وتقاريره)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P13_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000144)
,p_name=>'P13_ADDRESS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000143)
,p_prompt=>'العنوان'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000145)
,p_name=>'P13_POSTAL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000143)
,p_prompt=>'الرمز البريدي'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
,p_cMaxlength=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000146)
,p_name=>'P13_PHONE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000143)
,p_prompt=>'الهاتف'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>40
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000147)
,p_name=>'P13_MOBILE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000143)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>40
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000148)
,p_name=>'P13_EMAIL'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000143)
,p_prompt=>'البريد الإلكتروني'
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
 p_id=>wwv_flow_imp.id(91820262000000149)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000143)
,p_button_name=>'SAVE_CONTACT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ بيانات الاتصال'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000150)
,p_process_sequence=>12
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Contact'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P13_ID is not null and :P13_COMPANY_ID is not null then',
'    noona_brand_pkg.get_contact(:P13_COMPANY_ID, :P13_ID, :P13_ADDRESS, :P13_POSTAL, :P13_PHONE, :P13_MOBILE, :P13_EMAIL);',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000150
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000151)
,p_process_sequence=>22
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Contact'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_brand_pkg.save_contact(p_company_id => :P13_COMPANY_ID, p_branch_id => :P13_ID, p_address => :P13_ADDRESS,',
'                             p_postal => :P13_POSTAL, p_phone => :P13_PHONE, p_mobile => :P13_MOBILE, p_email => :P13_EMAIL);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000149)
,p_process_success_message=>'تم حفظ عنوان الفرع ووسائل اتصاله'
,p_internal_uid=>91820262000000151
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000152)
,p_plug_name=>'إغلاق الفرع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000153)
,p_name=>'P13_CLOSE_REASON'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000152)
,p_prompt=>'سبب الإغلاق'
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
 p_id=>wwv_flow_imp.id(91820262000000154)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000152)
,p_button_name=>'CLOSE_BRANCH'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إغلاق الفرع'
,p_button_position=>'NEXT'
,p_button_condition=>':P13_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000155)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close Branch'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_platform_pkg.close_branch(p_branch_id => :P13_ID, p_reason => :P13_CLOSE_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000154)
,p_process_success_message=>'تم إغلاق الفرع'
,p_internal_uid=>91820262000000155
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000156)
,p_branch_action=>'f?p=&APP_ID.:13:&SESSION.::&DEBUG.::P13_ID:&P13_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
