prompt --application/pages/page_00024
begin
--   Manifest
--     PAGE: 00024
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
 p_id=>24
,p_name=>'Send WhatsApp'
,p_alias=>'SEND'
,p_step_title=>'إرسال واتساب'
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
 p_id=>wwv_flow_imp.id(91820310000000177)
,p_plug_name=>'رسالة لعميل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000178)
,p_name=>'P24_CUST'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820310000000177)
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
 p_id=>wwv_flow_imp.id(91820310000000179)
,p_name=>'P24_EVENT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820310000000177)
,p_prompt=>'الرسالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:كشف الحساب والرصيد;STATEMENT,تذكير بالسداد;REMINDER,رابط البوابة;PORTAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000180)
,p_name=>'P24_PHONE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820310000000177)
,p_prompt=>'الجوال (فارغ = جوال العميل)'
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
 p_id=>wwv_flow_imp.id(91820310000000181)
,p_name=>'P24_MSG'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820310000000177)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000183)
,p_validation_name=>'P24_CUST required (SEND)'
,p_validation_sequence=>5
,p_validation=>'P24_CUST'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000182)
,p_associated_item=>wwv_flow_imp.id(91820310000000178)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000182)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000177)
,p_button_name=>'SEND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز وإرسال'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000184)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Send'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P24_MSG := noona_eng_pkg.send_event(:P24_EVENT, to_number(:P24_CUST), ''AR_CUSTOMER_ACCOUNT'', to_number(:P24_CUST), :P24_PHONE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000182)
,p_process_success_message=>'تم تجهيز الرسالة'
,p_internal_uid=>91820310000000184
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000185)
,p_plug_name=>'الرسالة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P24_MSG is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for m in (select * from eng_message where id = :P24_MSG and company_id = noona_eng_pkg.company) loop',
'    return ''<p>'' || apex_escape.html(m.body_text) || ''</p>'' || noona_eng_pkg.badge(m.status_code)',
'        || case when m.error_text is not null then '' '' || apex_escape.html(m.error_text) end',
'        || case when m.link_url is not null then '' <a class="nn-dst-btn nn-dst-wa nn-wa-open" href="'' || apex_escape.html_attribute(m.link_url)',
'             || ''"><span class="fa fa-whatsapp"></span> فتح واتساب وإرسال</a>'' end;',
'  end loop;',
'  return null;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000186)
,p_plug_name=>'تذكير جماعي بالسداد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يجهز رسالة تذكير لكل عميل عليه مبالغ متأخرة. مع Cloud API ترسل تلقائياً؛ مع روابط wa.me تظهر في «سجل الرسائل» بزر فتح لكل عميل.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000187)
,p_name=>'P24_DAYS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820310000000186)
,p_prompt=>'متأخر أكثر من (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000188)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000186)
,p_button_name=>'REMIND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تجهيز التذكيرات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000189)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remind'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'  l_n := noona_eng_pkg.send_reminders(nvl(to_number(:P24_DAYS), 1));',
'  apex_application.g_print_success_message := ''تم تجهيز '' || l_n || '' رسالة تذكير'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000188)
,p_internal_uid=>91820310000000189
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820310000000190)
,p_branch_action=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820310000000188)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820310000000191)
,p_branch_action=>'f?p=&APP_ID.:24:&SESSION.::&DEBUG.::P24_MSG,P24_CUST:&P24_MSG.,&P24_CUST.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
