prompt --application/pages/page_00041
begin
--   Manifest
--     PAGE: 00041
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>41
,p_name=>'Lease'
,p_alias=>'LEASE-EDIT'
,p_step_title=>'عقد إيجار'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000871)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001044)
,p_plug_name=>'العقار والوحدات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001045)
,p_name=>'P41_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000001044)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001046)
,p_name=>'P41_PROPERTY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001044)
,p_prompt=>'العقار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from re_property p where p.company_id = noona_res_pkg.company and p.status_code <> ''INACTIVE'' and exists (select 1 from re_unit u where u.property_id = p.id and u.usage_type in (''LEASE'', ''MIXED'')) order by p.code'
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
 p_id=>wwv_flow_imp.id(91820273000001047)
,p_name=>'P41_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001044)
,p_prompt=>'نوع العقد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سكني;RESIDENTIAL,تجاري (مكتب/معرض);COMMERCIAL,محل تجزئة;RETAIL,صناعي/مستودع;INDUSTRIAL,أرض;LAND,مواقف;PARKING'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001048)
,p_name=>'P41_UNITS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000001044)
,p_prompt=>'الوحدات'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'select u.code || '' - '' || noona_re_pkg.unit_type_label(u.unit_type) || '' ('' || noona_re_pkg.unit_status_label(u.status_code) || '')'' d, u.id r from re_unit u where u.property_id = :P41_PROPERTY and u.usage_type in (''LEASE'', ''MIXED'', ''OWNER_USE'') and u.status_code not in (''SOLD'', ''HANDED_OVER'', ''BLOCKED'') order by u.code'
,p_lov_cascade_parent_items=>'P41_PROPERTY'
,p_ajax_items_to_submit=>'P41_PROPERTY'
,p_ajax_optimize_refresh=>'Y'
,p_lov_columns=>6
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001049)
,p_plug_name=>'المستأجر'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001050)
,p_name=>'P41_TENANT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001049)
,p_prompt=>'المستأجر (مسجل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, p.id r from pty_party p where p.status_code = ''ACTIVE'' and exists (select 1 from ar_customer c join ar_customer_account a on a.customer_id = c.id where c.party_id = p.id and a.company_id = noona_res_pkg.company and c.is_walk_in = ''N'') order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- مستأجر جديد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001051)
,p_name=>'P41_TENANT_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001049)
,p_prompt=>'أو اسم مستأجر جديد'
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
 p_id=>wwv_flow_imp.id(91820273000001052)
,p_name=>'P41_PHONE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000001049)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820273000001053)
,p_name=>'P41_TAX'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000001049)
,p_prompt=>'الرقم الضريبي (للشركات)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001054)
,p_plug_name=>'المدة والإيجار'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001055)
,p_name=>'P41_START'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'البداية'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001056)
,p_name=>'P41_END'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'النهاية'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001057)
,p_name=>'P41_RENT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'الإيجار السنوي'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001058)
,p_name=>'P41_FREQ'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'دورية الفوترة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:شهري;MONTHLY,ربع سنوي;QUARTERLY,نصف سنوي;SEMI_ANNUAL,سنوي;ANNUAL,مقدماً دفعة واحدة;UPFRONT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001059)
,p_name=>'P41_ADVANCE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'الفوترة مقدماً (أول الفترة)'
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
 p_id=>wwv_flow_imp.id(91820273000001060)
,p_name=>'P41_ESC'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'الزيادة السنوية %'
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
 p_id=>wwv_flow_imp.id(91820273000001061)
,p_name=>'P41_DEPOSIT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'التأمين'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001062)
,p_name=>'P41_GRACE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'فترة السماح للسداد (أيام)'
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
 p_id=>wwv_flow_imp.id(91820273000001063)
,p_name=>'P41_NOTICE'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'مدة الإشعار (أيام)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001064)
,p_name=>'P41_REG'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820273000001054)
,p_prompt=>'رقم التوثيق (إيجار)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>100
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001065)
,p_plug_name=>'بنود إضافية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001066)
,p_name=>'P41_SERVICE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001065)
,p_prompt=>'رسوم الخدمات (شهرياً)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001067)
,p_name=>'P41_PARKING'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001065)
,p_prompt=>'المواقف (شهرياً)'
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
 p_id=>wwv_flow_imp.id(91820273000001068)
,p_name=>'P41_ONETIME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000001065)
,p_prompt=>'رسوم لمرة واحدة (عمولة/إدارة)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001069)
,p_name=>'P41_NOTES'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000001065)
,p_prompt=>'ملاحظات'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>1000
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001070)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001065)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ مسودة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001071)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000001065)
,p_button_name=>'SAVE_ACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ وتفعيل العقد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001072)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P41_ID is not null and :P41_PROPERTY is null then',
'        select property_id, lease_type, lessee_party_id, to_char(start_date, ''YYYY-MM-DD''), to_char(end_date, ''YYYY-MM-DD''), annual_rent,',
'               billing_frequency, billing_in_advance, json_value(escalation_rule, ''$.pct''), deposit_amount, grace_days, notice_days, registration_no, notes',
'          into :P41_PROPERTY, :P41_TYPE, :P41_TENANT, :P41_START, :P41_END, :P41_RENT, :P41_FREQ, :P41_ADVANCE, :P41_ESC, :P41_DEPOSIT,',
'               :P41_GRACE, :P41_NOTICE, :P41_REG, :P41_NOTES',
'          from prp_lease where id = :P41_ID and company_id = noona_res_pkg.company;',
'        select listagg(unit_id, '':'') within group (order by unit_id) into :P41_UNITS from prp_lease_unit where lease_id = :P41_ID;',
'    end if;',
'    :P41_TYPE := nvl(:P41_TYPE, ''RESIDENTIAL''); :P41_FREQ := nvl(:P41_FREQ, ''MONTHLY''); :P41_ADVANCE := nvl(:P41_ADVANCE, ''Y'');',
'    :P41_START := nvl(:P41_START, to_char(trunc(sysdate), ''YYYY-MM-DD''));',
'    :P41_END := nvl(:P41_END, to_char(add_months(trunc(sysdate), 12) - 1, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000001072
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001073)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_o json_object_t := json_object_t(); l_u json_array_t := json_array_t(); l_c json_array_t := json_array_t(); l_x json_object_t;',
'begin',
'    for u in (select column_value v from table(apex_string.split(:P41_UNITS, '':'')) where column_value is not null) loop l_u.append(to_number(u.v)); end loop;',
'    if :P41_SERVICE > 0 then l_x := json_object_t(); l_x.put(''type'', ''SERVICE_CHARGE''); l_x.put(''amount'', to_number(:P41_SERVICE)); l_x.put(''freq'', ''MONTHLY''); l_c.append(l_x); end if;',
'    if :P41_PARKING > 0 then l_x := json_object_t(); l_x.put(''type'', ''PARKING''); l_x.put(''amount'', to_number(:P41_PARKING)); l_x.put(''freq'', ''MONTHLY''); l_c.append(l_x); end if;',
'    if :P41_ONETIME > 0 then l_x := json_object_t(); l_x.put(''type'', ''OTHER''); l_x.put(''amount'', to_number(:P41_ONETIME)); l_x.put(''freq'', ''ONE_TIME''); l_c.append(l_x); end if;',
'    if :P41_ID is not null then l_o.put(''id'', to_number(:P41_ID)); end if;',
'    l_o.put(''type'', :P41_TYPE); l_o.put(''property'', to_number(:P41_PROPERTY)); l_o.put(''units'', l_u); l_o.put(''charges'', l_c);',
'    if :P41_TENANT is not null then l_o.put(''tenant'', to_number(:P41_TENANT)); end if;',
'    l_o.put(''tenantName'', :P41_TENANT_NAME); l_o.put(''phone'', :P41_PHONE); l_o.put(''tax'', :P41_TAX);',
'    l_o.put(''start'', :P41_START); l_o.put(''end'', :P41_END); l_o.put(''rent'', to_number(:P41_RENT)); l_o.put(''freq'', :P41_FREQ);',
'    l_o.put(''advance'', :P41_ADVANCE); l_o.put(''deposit'', nvl(to_number(:P41_DEPOSIT), 0)); l_o.put(''escalation'', to_number(:P41_ESC));',
'    l_o.put(''grace'', to_number(:P41_GRACE)); l_o.put(''notice'', to_number(:P41_NOTICE)); l_o.put(''registration'', :P41_REG); l_o.put(''notes'', :P41_NOTES);',
'    :P41_ID := noona_prp_pkg.save_lease(l_o.to_clob);',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 42, p_items => ''P42_ID'', p_values => :P41_ID));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001070)
,p_internal_uid=>91820273000001073
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001074)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Activate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_o json_object_t := json_object_t(); l_u json_array_t := json_array_t(); l_c json_array_t := json_array_t(); l_x json_object_t;',
'begin',
'    for u in (select column_value v from table(apex_string.split(:P41_UNITS, '':'')) where column_value is not null) loop l_u.append(to_number(u.v)); end loop;',
'    if :P41_SERVICE > 0 then l_x := json_object_t(); l_x.put(''type'', ''SERVICE_CHARGE''); l_x.put(''amount'', to_number(:P41_SERVICE)); l_x.put(''freq'', ''MONTHLY''); l_c.append(l_x); end if;',
'    if :P41_PARKING > 0 then l_x := json_object_t(); l_x.put(''type'', ''PARKING''); l_x.put(''amount'', to_number(:P41_PARKING)); l_x.put(''freq'', ''MONTHLY''); l_c.append(l_x); end if;',
'    if :P41_ONETIME > 0 then l_x := json_object_t(); l_x.put(''type'', ''OTHER''); l_x.put(''amount'', to_number(:P41_ONETIME)); l_x.put(''freq'', ''ONE_TIME''); l_c.append(l_x); end if;',
'    if :P41_ID is not null then l_o.put(''id'', to_number(:P41_ID)); end if;',
'    l_o.put(''type'', :P41_TYPE); l_o.put(''property'', to_number(:P41_PROPERTY)); l_o.put(''units'', l_u); l_o.put(''charges'', l_c);',
'    if :P41_TENANT is not null then l_o.put(''tenant'', to_number(:P41_TENANT)); end if;',
'    l_o.put(''tenantName'', :P41_TENANT_NAME); l_o.put(''phone'', :P41_PHONE); l_o.put(''tax'', :P41_TAX);',
'    l_o.put(''start'', :P41_START); l_o.put(''end'', :P41_END); l_o.put(''rent'', to_number(:P41_RENT)); l_o.put(''freq'', :P41_FREQ);',
'    l_o.put(''advance'', :P41_ADVANCE); l_o.put(''deposit'', nvl(to_number(:P41_DEPOSIT), 0)); l_o.put(''escalation'', to_number(:P41_ESC));',
'    l_o.put(''grace'', to_number(:P41_GRACE)); l_o.put(''notice'', to_number(:P41_NOTICE)); l_o.put(''registration'', :P41_REG); l_o.put(''notes'', :P41_NOTES);',
'    :P41_ID := noona_prp_pkg.save_lease(l_o.to_clob);',
'    noona_prp_pkg.activate_lease(:P41_ID);',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 42, p_items => ''P42_ID'', p_values => :P41_ID));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001071)
,p_internal_uid=>91820273000001074
);

wwv_flow_imp.component_end;
end;
/
