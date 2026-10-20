prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
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
 p_id=>10
,p_name=>'Change Password'
,p_alias=>'CHANGE-PASSWORD'
,p_step_title=>'تغيير كلمة المرور'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000010)
,p_plug_name=>'تغيير كلمة المرور'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000011)
,p_name=>'P10_OLD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820263000000010)
,p_prompt=>'كلمة المرور الحالية'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000012)
,p_name=>'P10_NEW'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820263000000010)
,p_prompt=>'كلمة المرور الجديدة (10 أحرف: كبير وصغير ورقم)'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000013)
,p_name=>'P10_CONFIRM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820263000000010)
,p_prompt=>'تأكيد كلمة المرور الجديدة'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820263000000015)
,p_validation_name=>'P10_OLD required (CHANGE)'
,p_validation_sequence=>4
,p_validation=>'P10_OLD'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820263000000014)
,p_associated_item=>wwv_flow_imp.id(91820263000000011)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820263000000016)
,p_validation_name=>'P10_NEW required (CHANGE)'
,p_validation_sequence=>5
,p_validation=>'P10_NEW'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820263000000014)
,p_associated_item=>wwv_flow_imp.id(91820263000000012)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820263000000017)
,p_validation_name=>'P10_CONFIRM required (CHANGE)'
,p_validation_sequence=>6
,p_validation=>'P10_CONFIRM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820263000000014)
,p_associated_item=>wwv_flow_imp.id(91820263000000013)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000014)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820263000000010)
,p_button_name=>'CHANGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تغيير كلمة المرور'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000018)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820263000000010)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000019)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Change Password'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_verified varchar2(1) := ''N'';',
'begin',
'    if :P10_NEW <> :P10_CONFIRM then',
'        raise_application_error(-20500, ''NOONA-SEC-255: كلمة المرور الجديدة وتأكيدها غير متطابقين'');',
'    end if;',
'    -- مستخدم ما زال يدخل بحساب APEX: يتحقق من كلمته الحالية هناك',
'    if noona_apex_pkg.check_password(:APP_USER, :P10_OLD) = ''NO_LOCAL''',
'       and apex_util.is_login_password_valid(p_username => :APP_USER, p_password => :P10_OLD) then',
'        l_verified := ''Y'';',
'    end if;',
'    noona_sec_admin_pkg.change_password(p_old_password => :P10_OLD, p_new_password => :P10_NEW,',
'                                        p_old_verified => l_verified);',
'    :P10_OLD := null; :P10_NEW := null; :P10_CONFIRM := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000014)
,p_process_success_message=>'تم تغيير كلمة المرور؛ استخدمها في الدخول القادم'
,p_internal_uid=>91820263000000019
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820263000000020)
,p_branch_action=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
