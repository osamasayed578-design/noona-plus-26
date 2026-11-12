prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>151
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>22
,p_name=>'Template'
,p_alias=>'TEMPLATE'
,p_step_title=>'قالب رسالة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820310000000011)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000147)
,p_plug_name=>'القالب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">المتغيرات: {customer} {amount} {invoice} {date} {balance} {overdue} {days} {link} {company} {title}. لـ Cloud API: اكتب اسم القالب المعتمد في Meta، وتمرر المتغيرات بترتيب ظهورها في النص.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000148)
,p_name=>'P22_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000149)
,p_name=>'P22_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>14
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
 p_id=>wwv_flow_imp.id(91820310000000150)
,p_name=>'P22_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_prompt=>'الاسم'
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
 p_id=>wwv_flow_imp.id(91820310000000151)
,p_name=>'P22_EVENT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_prompt=>'المناسبة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:فاتورة;INVOICE,كشف حساب;STATEMENT,تأكيد سداد;PAYMENT,تذكير بالسداد;REMINDER,رابط البوابة;PORTAL,طلبية;ORDER,تنبيه للمدير;ALERT,عامة;GENERAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000152)
,p_name=>'P22_BODY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_prompt=>'النص'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>4
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000153)
,p_name=>'P22_CLOUD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_prompt=>'اسم القالب المعتمد في Meta (اختياري)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000154)
,p_name=>'P22_LANG'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_prompt=>'لغة القالب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>6
,p_cMaxlength=>10
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
 p_id=>wwv_flow_imp.id(91820310000000155)
,p_name=>'P22_ACTIVE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_prompt=>'نشط'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000156)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for t in (select * from eng_wa_template where id = :P22_ID and company_id = noona_eng_pkg.company) loop',
'    :P22_CODE := t.code; :P22_NAME := t.name_ar; :P22_EVENT := t.event_code; :P22_BODY := t.body_text; :P22_CLOUD := t.cloud_template;',
'    :P22_LANG := t.language_code; :P22_ACTIVE := t.is_active;',
'  end loop;',
'  if :P22_ID is null and :P22_ACTIVE is null then :P22_ACTIVE := ''Y''; :P22_LANG := ''ar''; end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820310000000156
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000158)
,p_validation_name=>'P22_CODE required (SAVE)'
,p_validation_sequence=>10
,p_validation=>'P22_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000157)
,p_associated_item=>wwv_flow_imp.id(91820310000000149)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000159)
,p_validation_name=>'P22_NAME required (SAVE)'
,p_validation_sequence=>11
,p_validation=>'P22_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000157)
,p_associated_item=>wwv_flow_imp.id(91820310000000150)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000160)
,p_validation_name=>'P22_BODY required (SAVE)'
,p_validation_sequence=>12
,p_validation=>'P22_BODY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000157)
,p_associated_item=>wwv_flow_imp.id(91820310000000152)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000157)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000147)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000161)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  noona_security_pkg.assert_permission(''ENG_WA_TEMPLATE.UPDATE'', noona_eng_pkg.company);',
'  if :P22_ID is null then',
'    insert into eng_wa_template (company_id, code, name_ar, name_en, event_code, body_text, cloud_template, language_code, is_active)',
'    values (noona_eng_pkg.company, upper(:P22_CODE), :P22_NAME, upper(:P22_CODE), :P22_EVENT, :P22_BODY, :P22_CLOUD, nvl(:P22_LANG, ''ar''), :P22_ACTIVE)',
'    returning id into :P22_ID;',
'  else',
'    update eng_wa_template set code = upper(:P22_CODE), name_ar = :P22_NAME, event_code = :P22_EVENT, body_text = :P22_BODY,',
'           cloud_template = :P22_CLOUD, language_code = nvl(:P22_LANG, ''ar''), is_active = :P22_ACTIVE',
'     where id = :P22_ID and company_id = noona_eng_pkg.company;',
'  end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000157)
,p_process_success_message=>'تم حفظ القالب'
,p_internal_uid=>91820310000000161
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820310000000162)
,p_branch_action=>'f?p=&APP_ID.:22:&SESSION.::&DEBUG.::P22_ID:&P22_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
