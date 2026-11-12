prompt --application/pages/page_00006
begin
--   Manifest
--     PAGE: 00006
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
 p_id=>6
,p_name=>'Alert Rule'
,p_alias=>'RULE'
,p_step_title=>'قاعدة إنذار'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820310000000011)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000064)
,p_plug_name=>'القاعدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الحد: مبلغ (النقد، الذمم، المستحقات) أو عدد (العملاء، الأصناف، التحصيلات، الشيكات) أو نسبة % (انخفاض المبيعات). الأيام: مدى التوقع أو عمر التأخير أو نافذة الاستحقاق. يفحص النظام القواعد كل 3 ساعات ويبلغ مسؤولي المؤسسة، ويرسل واتساب للمدير إن أدخلت رقمه.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000065)
,p_name=>'P6_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000066)
,p_name=>'P6_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
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
 p_id=>wwv_flow_imp.id(91820310000000067)
,p_name=>'P6_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
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
 p_id=>wwv_flow_imp.id(91820310000000068)
,p_name=>'P6_METRIC'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
,p_prompt=>'المؤشر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:انخفاض النقد عن حد;CASH_LOW,عجز نقدي متوقع خلال أيام;FORECAST_NEGATIVE,الذمم المتأخرة تتجاوز حداً;AR_OVERDUE,عملاء تجاوزوا حد الائتمان;OVER_CREDIT_LIMIT,أصناف تحت الحد الأدنى;STOCK_BELOW_MIN,انخفاض المبيعات بنسبة %;SALES_DROP,تحويلات ميدانية لم تؤكد;PENDING_COLLECTIONS,شيكات تستحق قريباً;CHEQUES_DUE,مستحقات موردين قريبة;AP_DUE'
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
 p_id=>wwv_flow_imp.id(91820310000000069)
,p_name=>'P6_THRESHOLD'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
,p_prompt=>'الحد'
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
 p_id=>wwv_flow_imp.id(91820310000000070)
,p_name=>'P6_DAYS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
,p_prompt=>'الأيام'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000071)
,p_name=>'P6_SEV'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
,p_prompt=>'الخطورة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:منخفضة;LOW,متوسطة;MEDIUM,عالية;HIGH,حرجة;CRITICAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000072)
,p_name=>'P6_WA'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
,p_prompt=>'واتساب المدير (اختياري)'
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
 p_id=>wwv_flow_imp.id(91820310000000073)
,p_name=>'P6_ACTIVE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820310000000064)
,p_prompt=>'نشطة'
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
 p_id=>wwv_flow_imp.id(91820310000000074)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for r in (select * from eng_alert_rule where id = :P6_ID and company_id = noona_eng_pkg.company) loop',
'    :P6_CODE := r.code; :P6_NAME := r.name_ar; :P6_METRIC := r.metric; :P6_THRESHOLD := r.threshold; :P6_DAYS := r.days;',
'    :P6_SEV := r.severity; :P6_WA := r.notify_whatsapp; :P6_ACTIVE := r.is_active;',
'  end loop;',
'  if :P6_ID is null and :P6_ACTIVE is null then :P6_ACTIVE := ''Y''; :P6_SEV := ''MEDIUM''; end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820310000000074
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000076)
,p_validation_name=>'P6_CODE required (SAVE)'
,p_validation_sequence=>11
,p_validation=>'P6_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000075)
,p_associated_item=>wwv_flow_imp.id(91820310000000066)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000077)
,p_validation_name=>'P6_NAME required (SAVE)'
,p_validation_sequence=>12
,p_validation=>'P6_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000075)
,p_associated_item=>wwv_flow_imp.id(91820310000000067)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000078)
,p_validation_name=>'P6_METRIC required (SAVE)'
,p_validation_sequence=>13
,p_validation=>'P6_METRIC'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000075)
,p_associated_item=>wwv_flow_imp.id(91820310000000068)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000075)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000064)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000079)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  noona_security_pkg.assert_permission(''ENG_ALERT_RULE.UPDATE'', noona_eng_pkg.company);',
'  if :P6_ID is null then',
'    insert into eng_alert_rule (company_id, code, name_ar, name_en, metric, threshold, days, severity, notify_whatsapp, is_active)',
'    values (noona_eng_pkg.company, upper(:P6_CODE), :P6_NAME, upper(:P6_CODE), :P6_METRIC, to_number(:P6_THRESHOLD), to_number(:P6_DAYS),',
'            :P6_SEV, :P6_WA, :P6_ACTIVE) returning id into :P6_ID;',
'  else',
'    update eng_alert_rule set code = upper(:P6_CODE), name_ar = :P6_NAME, metric = :P6_METRIC, threshold = to_number(:P6_THRESHOLD),',
'           days = to_number(:P6_DAYS), severity = :P6_SEV, notify_whatsapp = :P6_WA, is_active = :P6_ACTIVE',
'     where id = :P6_ID and company_id = noona_eng_pkg.company;',
'  end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000075)
,p_process_success_message=>'تم حفظ القاعدة'
,p_internal_uid=>91820310000000079
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820310000000080)
,p_branch_action=>'f?p=&APP_ID.:6:&SESSION.::&DEBUG.::P6_ID:&P6_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
