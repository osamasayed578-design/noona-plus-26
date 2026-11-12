prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
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
 p_id=>11
,p_name=>'Portal Link'
,p_alias=>'PORTAL-LINK'
,p_step_title=>'رابط بوابة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820310000000010)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.addEventListener(''click'', function (e) {',
'  var a = e.target.closest(''a.nn-wa-open''); if (!a) return;',
'  e.preventDefault(); window.open(a.href, ''_blank'', ''noopener'');',
'});'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000095)
,p_plug_name=>'الرابط'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000096)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820310000000095)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000097)
,p_name=>'P11_CUST'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820310000000095)
,p_prompt=>'العميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_sal_pkg.customer_label(a.id) d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id where a.company_id = noona_eng_pkg.company and a.status_code = ''ACTIVE'' and nvl(c.is_walk_in, ''N'') = ''N'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820310000000098)
,p_name=>'P11_DAYS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820310000000095)
,p_prompt=>'الصلاحية (أيام، 0 = دائم)'
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
 p_id=>wwv_flow_imp.id(91820310000000099)
,p_name=>'P11_PHONE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820310000000095)
,p_prompt=>'جوال الإرسال (فارغ = جوال العميل)'
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
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000100)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for l in (select * from eng_portal_link where id = :P11_ID and company_id = noona_eng_pkg.company) loop',
'    :P11_CUST := l.customer_account_id; :P11_PHONE := l.phone;',
'  end loop;',
'  if :P11_DAYS is null then :P11_DAYS := ''365''; end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820310000000100
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000102)
,p_validation_name=>'P11_CUST required (CREATE)'
,p_validation_sequence=>6
,p_validation=>'P11_CUST'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000101)
,p_associated_item=>wwv_flow_imp.id(91820310000000097)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000101)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000095)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الرابط'
,p_button_position=>'NEXT'
,p_button_condition=>':P11_ID is null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000103)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P11_ID := noona_eng_pkg.create_link(to_number(:P11_CUST), to_number(:P11_DAYS), :P11_PHONE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000101)
,p_process_success_message=>'تم إنشاء الرابط'
,p_internal_uid=>91820310000000103
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000104)
,p_plug_name=>'الرابط'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_u varchar2(4000) := noona_eng_pkg.link_url(:P11_ID);',
'begin',
'  if l_u is null then return ''<p class="nn-hint">الرابط ملغى أو منتهٍ؛ أنشئ رابطاً جديداً.</p>''; end if;',
'  return ''<p><input class="nn-dst-find" readonly value="'' || apex_escape.html_attribute(l_u) || ''" onclick="this.select()"></p>''',
'      || ''<div class="nn-dst-actions"><a class="nn-dst-btn" target="_blank" rel="noopener" href="'' || apex_escape.html_attribute(l_u)',
'      || ''"><span class="fa fa-external-link"></span> فتح البوابة</a>''',
'      || ''<button type="button" class="nn-dst-btn" onclick="navigator.clipboard.writeText(this.closest(''''.t-Region'''').querySelector(''''input'''').value);apex.message.showPageSuccess(''''تم النسخ'''')">''',
'      || ''<span class="fa fa-copy"></span> نسخ</button></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000105)
,p_plug_name=>'الإرسال'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_eng_pkg.link_url(:P11_ID) is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000106)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000105)
,p_button_name=>'SEND_WA'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال الرابط بواتساب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000107)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820310000000105)
,p_button_name=>'REVOKE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الرابط'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000108)
,p_name=>'P11_MSG'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820310000000105)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000109)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Send'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P11_MSG := noona_eng_pkg.send_event(''PORTAL'', to_number(:P11_CUST), ''ENG_PORTAL_LINK'', :P11_ID, :P11_PHONE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000106)
,p_process_success_message=>'تم تجهيز الرسالة'
,p_internal_uid=>91820310000000109
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000110)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Revoke'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_eng_pkg.revoke_link(:P11_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000107)
,p_process_success_message=>'تم إلغاء الرابط'
,p_internal_uid=>91820310000000110
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000111)
,p_plug_name=>'رسالة واتساب'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_MSG is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_l varchar2(4000) := noona_eng_pkg.message_link(:P11_MSG);',
'begin',
'  if l_l is null then return ''<p class="nn-hint">أرسلت الرسالة عبر WhatsApp Cloud API. راجع «سجل الرسائل».</p>''; end if;',
'  return ''<a class="nn-dst-btn nn-dst-wa nn-wa-open" href="'' || apex_escape.html_attribute(l_l) || ''"><span class="fa fa-whatsapp"></span> فتح واتساب وإرسال</a>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820310000000112)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.::P11_ID,P11_MSG:&P11_ID.,&P11_MSG.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
