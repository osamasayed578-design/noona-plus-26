prompt --application/pages/page_00075
begin
--   Manifest
--     PAGE: 00075
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
 p_id=>75
,p_name=>'Messaging'
,p_alias=>'MESSAGING'
,p_step_title=>'الرسائل النصية وواتساب'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000683)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000754)
,p_plug_name=>'القنوات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_api_pkg.channels_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000755)
,p_plug_name=>'إعداد قناة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint"><b>المحاكي</b> يسجل الرسالة كمرسلة دون اتصال (للتجربة). <b>مزود REST</b> يرسل POST لعنوان المزود بالجسم المحدد ({{to}} و{{text}} و{{sender}})، والمفتاح يحفظ مشفراً ويوضع مكان {{secret}} في ترويسة التفويض.<br>القواعد: سطر لكل حدث بالصيغة <code dir="ltr">EVENT|النص</code> مثل <code>AR_RECEIPT.CREATED|شكراً {{name}}، استلمنا {{total}} - {{company}}</code>. المتغيرات: {{name}} {{number}} {{total}} {{company}}. ترسل لجوال العميل المسجل.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000756)
,p_name=>'P75_CHANNEL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_prompt=>'القناة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:رسائل نصية SMS;SMS,واتساب;WHATSAPP'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000757)
,p_name=>'P75_ADAPTER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_prompt=>'المحول'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المحاكي (تجربة);SIMULATOR,مزود REST;REST'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000758)
,p_name=>'P75_URL'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_prompt=>'عنوان مزود الخدمة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>1000
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000759)
,p_name=>'P75_AUTH'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_prompt=>'ترويسة التفويض'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000760)
,p_name=>'P75_SECRET'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_prompt=>'مفتاح المزود (يترك فارغاً لإبقاء الحالي)'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000761)
,p_name=>'P75_SENDER'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_prompt=>'اسم المرسل'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
 p_id=>wwv_flow_imp.id(91820262000000762)
,p_name=>'P75_BODY'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_prompt=>'جسم الطلب للمزود (JSON)'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000763)
,p_name=>'P75_RULES'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_prompt=>'قواعد الإرسال التلقائي'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000764)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000755)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ القناة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000765)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P75_AUTH := nvl(:P75_AUTH, ''Authorization: Bearer {{secret}}'');',
'    :P75_BODY := nvl(:P75_BODY, ''{"to":"{{to}}","text":"{{text}}","sender":"{{sender}}"}'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000765
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000766)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number; l_r json_array_t := json_array_t(); l_o json_object_t;',
'begin',
'    for r in (select trim(column_value) v from table(apex_string.split(:P75_RULES, chr(10))) where instr(column_value, ''|'') > 0) loop',
'        l_o := json_object_t(); l_o.put(''event'', trim(substr(r.v, 1, instr(r.v, ''|'') - 1)));',
'        l_o.put(''template'', trim(substr(r.v, instr(r.v, ''|'') + 1))); l_r.append(l_o);',
'    end loop;',
'    l_o := json_object_t(); l_o.put(''channel'', :P75_CHANNEL); l_o.put(''adapter'', :P75_ADAPTER); l_o.put(''url'', :P75_URL);',
'    l_o.put(''authHeader'', :P75_AUTH); l_o.put(''secret'', :P75_SECRET); l_o.put(''sender'', :P75_SENDER); l_o.put(''body'', :P75_BODY);',
'    l_o.put(''rules'', l_r);',
'    l_id := noona_api_pkg.save_channel(l_o.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000764)
,p_process_success_message=>'تم حفظ القناة'
,p_internal_uid=>91820262000000766
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000767)
,p_plug_name=>'رسالة تجريبية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000768)
,p_name=>'P75_TCH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000767)
,p_prompt=>'القناة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:رسائل نصية SMS;SMS,واتساب;WHATSAPP'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000769)
,p_name=>'P75_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000767)
,p_prompt=>'رقم الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
 p_id=>wwv_flow_imp.id(91820262000000770)
,p_name=>'P75_TEXT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000767)
,p_prompt=>'النص'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>1000
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000771)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000767)
,p_button_name=>'SEND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إرسال'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000772)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Send'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_api_pkg.send_message(:P75_TCH, :P75_TO, :P75_TEXT);',
'    l := noona_api_pkg.dispatch(20);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000771)
,p_process_success_message=>'أرسلت الرسالة؛ حالتها في الأحداث الصادرة'
,p_internal_uid=>91820262000000772
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000773)
,p_branch_action=>'f?p=&APP_ID.:75:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
