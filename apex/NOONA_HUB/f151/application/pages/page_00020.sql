prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
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
 p_id=>20
,p_name=>'WhatsApp Settings'
,p_alias=>'WHATSAPP'
,p_step_title=>'إعدادات واتساب'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820310000000011)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.addEventListener(''click'', function (e) {',
'  var a = e.target.closest(''a.nn-wa-open''); if (!a) return;',
'  e.preventDefault(); window.open(a.href, ''_blank'', ''noopener'');',
'});'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000113)
,p_plug_name=>'طريقة الإرسال'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint"><b>روابط wa.me</b> (بدون اشتراك): يفتح واتساب على الجهاز برسالة جاهزة ويضغط الموظف إرسال. <b>WhatsApp Cloud API</b>: إرسال تلقائي من رقم الشركة؛ يتطلب حساب Meta Business ورقماً مفعلاً ورمز وصول دائم. الرسائل التي يبدؤها النظام (كالتذكير) تحتاج قالباً معتمداً من Meta: اكتب اسمه في القالب. رمز الوصول يدخله المسؤول هنا فقط ويحفظ مشفراً ولا يعرض بعد الحفظ.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000114)
,p_name=>'P20_PROVIDER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'الطريقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:روابط wa.me (يدوي);LINK,WhatsApp Cloud API (تلقائي);CLOUD_API'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000115)
,p_name=>'P20_PHONEID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'Phone number ID'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>24
,p_cMaxlength=>50
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
 p_id=>wwv_flow_imp.id(91820310000000116)
,p_name=>'P20_BIZID'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'WhatsApp Business Account ID'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>24
,p_cMaxlength=>50
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000117)
,p_name=>'P20_VERSION'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'إصدار Graph API'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>8
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
 p_id=>wwv_flow_imp.id(91820310000000118)
,p_name=>'P20_TOKEN'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'رمز الوصول (فارغ = إبقاء الحالي)'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000119)
,p_name=>'P20_HAS'
,p_item_sequence=>55
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'رمز الوصول المحفوظ'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000120)
,p_name=>'P20_CC'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'رمز الدولة الافتراضي للأرقام المحلية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>6
,p_cMaxlength=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000121)
,p_name=>'P20_SENDER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'رقم الإرسال (للعرض)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>16
,p_cMaxlength=>30
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
 p_id=>wwv_flow_imp.id(91820310000000122)
,p_name=>'P20_ENABLED'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'مفعل'
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
 p_id=>wwv_flow_imp.id(91820310000000123)
,p_name=>'P20_CLEAR'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_prompt=>'حذف رمز الوصول المحفوظ'
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
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000124)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for s in (select * from eng_wa_setting where company_id = noona_eng_pkg.company) loop',
'    :P20_PROVIDER := s.provider; :P20_PHONEID := s.phone_number_id; :P20_BIZID := s.business_account_id; :P20_VERSION := s.api_version;',
'    :P20_CC := s.default_cc; :P20_SENDER := s.sender_phone; :P20_ENABLED := s.is_enabled;',
'  end loop;',
'  :P20_HAS := case noona_eng_pkg.wa_has_token when ''Y'' then ''محفوظ (مشفر)'' else ''لا يوجد'' end;',
'  :P20_TOKEN := null; :P20_CLEAR := ''N'';',
'  if :P20_PROVIDER is null then :P20_PROVIDER := ''LINK''; :P20_VERSION := ''v21.0''; :P20_CC := ''966''; :P20_ENABLED := ''Y''; end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820310000000124
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000125)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000113)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000126)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t();',
'begin',
'  l.put(''provider'', :P20_PROVIDER); l.put(''phoneId'', :P20_PHONEID); l.put(''businessId'', :P20_BIZID); l.put(''version'', :P20_VERSION);',
'  l.put(''token'', :P20_TOKEN); l.put(''cc'', :P20_CC); l.put(''sender'', :P20_SENDER); l.put(''enabled'', :P20_ENABLED); l.put(''clearToken'', :P20_CLEAR);',
'  noona_eng_pkg.save_wa_setting(l.to_clob);',
'  :P20_TOKEN := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000125)
,p_process_success_message=>'تم حفظ إعدادات واتساب'
,p_internal_uid=>91820310000000126
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000127)
,p_plug_name=>'رسالة تجربة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000128)
,p_name=>'P20_TEST_PHONE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820310000000127)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>16
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000129)
,p_name=>'P20_MSG'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820310000000127)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000130)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000127)
,p_button_name=>'TEST'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إرسال تجربة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000131)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Test'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P20_MSG := noona_eng_pkg.send_text(:P20_TEST_PHONE, ''رسالة تجربة من نونا بلس - '' || to_char(sysdate, ''YYYY-MM-DD HH24:MI''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000130)
,p_process_success_message=>'تمت المحاولة؛ راجع النتيجة'
,p_internal_uid=>91820310000000131
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000132)
,p_plug_name=>'نتيجة التجربة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_MSG is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for m in (select * from eng_message where id = :P20_MSG and company_id = noona_eng_pkg.company) loop',
'    return noona_eng_pkg.badge(m.status_code) || case when m.error_text is not null then '' <b>'' || apex_escape.html(m.error_text) || ''</b>'' end',
'        || case when m.link_url is not null then '' <a class="nn-dst-btn nn-dst-wa nn-wa-open" href="'' || apex_escape.html_attribute(m.link_url)',
'             || ''"><span class="fa fa-whatsapp"></span> فتح واتساب</a>'' end;',
'  end loop;',
'  return null;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820310000000133)
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.::P20_MSG:&P20_MSG.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
