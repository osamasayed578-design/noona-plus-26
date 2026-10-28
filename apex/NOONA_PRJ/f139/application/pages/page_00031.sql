prompt --application/pages/page_00031
begin
--   Manifest
--     PAGE: 00031
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
 p_id=>31
,p_name=>'New Unit Deal'
,p_alias=>'UNIT-DEAL'
,p_step_title=>'حجز أو عقد بيع جديد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000753)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000770)
,p_plug_name=>'الوحدة والمشتري'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">اختر مشترياً مسجلاً أو اكتب اسم مشترٍ جديد. السعر الافتراضي من قائمة الأسعار الفعالة؛ الخصم تحت الحد الأدنى يحتاج صلاحية اعتماد.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000771)
,p_name=>'P31_UNIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000770)
,p_prompt=>'الوحدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar || '' / '' || u.code || '' ('' || noona_re_pkg.unit_type_label(u.unit_type) || '')'' d, u.id r from re_unit u join re_property p on p.id = u.property_id where u.company_id = noona_res_pkg.company and u.status_code = ''AVAILABLE'' and u.usage_type in (''SALE'', ''MIXED'') order by p.code, u.code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000772)
,p_name=>'P31_BUYER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000770)
,p_prompt=>'المشتري (مسجل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, p.id r from pty_party p where p.status_code = ''ACTIVE'' and exists (select 1 from ar_customer c join ar_customer_account a on a.customer_id = c.id where c.party_id = p.id and a.company_id = noona_res_pkg.company and c.is_walk_in = ''N'') order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- مشتر جديد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000773)
,p_name=>'P31_BUYER_NAME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000770)
,p_prompt=>'أو اسم مشترٍ جديد'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000774)
,p_name=>'P31_PHONE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000770)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820273000000775)
,p_name=>'P31_TAX'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000770)
,p_prompt=>'الرقم الضريبي (للشركات)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000776)
,p_name=>'P31_PRICE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000770)
,p_prompt=>'السعر'
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
 p_id=>wwv_flow_imp.id(91820273000000777)
,p_name=>'P31_DISCOUNT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000770)
,p_prompt=>'الخصم'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000778)
,p_name=>'P31_BROKER'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000770)
,p_prompt=>'الوسيط'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select display_name_ar d, id r from pty_party p where status_code = ''ACTIVE'' and exists (select 1 from pty_party_role x where x.party_id = p.id and x.role_code in (''BROKER'', ''AGENT'')) order by 1'
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000779)
,p_plug_name=>'الحجز بعربون'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000780)
,p_name=>'P31_DEPOSIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000779)
,p_prompt=>'العربون'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000781)
,p_name=>'P31_PLACE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000779)
,p_prompt=>'استلام العربون في'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''صندوق: '' || name_ar d, ''BOX:'' || id r from csh_cash_box where company_id = noona_res_pkg.company and status_code = ''ACTIVE'' union all select ''بنك: '' || name_ar, ''BANK:'' || id from csh_bank_account where company_id = noona_res_pkg.company and status_code = ''ACTIVE'''
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
 p_id=>wwv_flow_imp.id(91820273000000782)
,p_name=>'P31_DAYS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000779)
,p_prompt=>'صلاحية الحجز (أيام)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000783)
,p_name=>'P31_NOTES'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000779)
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
 p_id=>wwv_flow_imp.id(91820273000000784)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000779)
,p_button_name=>'RESERVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حجز الوحدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000785)
,p_plug_name=>'أو عقد بيع مباشر'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000786)
,p_name=>'P31_PLAN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000785)
,p_prompt=>'خطة السداد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from re_payment_plan where company_id = noona_res_pkg.company and is_active = ''Y'' and (property_id is null or property_id = (select property_id from re_unit where id = :P31_UNIT)) order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- دفعة واحدة عند التوقيع -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000787)
,p_name=>'P31_HANDOVER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000785)
,p_prompt=>'التسليم المتوقع'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
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
 p_id=>wwv_flow_imp.id(91820273000000788)
,p_name=>'P31_METHOD'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000785)
,p_prompt=>'الاعتراف بالإيراد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عند التسليم;POINT_IN_TIME,على مدى الإنشاء (مع كل قسط);OVER_TIME'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000789)
,p_name=>'P31_COMMISSION'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000785)
,p_prompt=>'عمولة الوسيط %'
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
 p_id=>wwv_flow_imp.id(91820273000000790)
,p_name=>'P31_ELIGIBLE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000785)
,p_prompt=>'تستحق العمولة عند تحصيل %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000791)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000785)
,p_button_name=>'CONTRACT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إنشاء عقد البيع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000792)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P31_UNIT is not null and :P31_PRICE is null then :P31_PRICE := noona_res_pkg.unit_price(:P31_UNIT); end if;',
'    :P31_DAYS := nvl(:P31_DAYS, 7); :P31_METHOD := nvl(:P31_METHOD, ''POINT_IN_TIME'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000792
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000793)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reserve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_res_pkg.reserve(json_object(''unit'' value to_number(:P31_UNIT), ''buyer'' value to_number(:P31_BUYER), ''buyerName'' value :P31_BUYER_NAME, ''phone'' value :P31_PHONE, ''tax'' value :P31_TAX, ''price'' value to_number(:P31_PRICE), ''discount'' value to_number(:P31_DISCOUNT), ''broker'' value to_number(:P31_BROKER), ''deposit'' value to_number(:P31_DEPOSIT), ''place'' value :P31_PLACE,',
'              ''days'' value to_number(:P31_DAYS), ''notes'' value :P31_NOTES));',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 32, p_items => ''P32_STATUS'', p_values => ''ACTIVE''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000784)
,p_internal_uid=>91820273000000793
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000794)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Contract'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_res_pkg.create_contract(json_object(''unit'' value to_number(:P31_UNIT), ''buyer'' value to_number(:P31_BUYER), ''buyerName'' value :P31_BUYER_NAME, ''phone'' value :P31_PHONE, ''tax'' value :P31_TAX, ''price'' value to_number(:P31_PRICE), ''discount'' value to_number(:P31_DISCOUNT), ''broker'' value to_number(:P31_BROKER), ''plan'' value to_number(:P31_PLAN), ''handover'' value :P31_HANDOVER,',
'              ''method'' value :P31_METHOD, ''commission'' value to_number(:P31_COMMISSION), ''eligible'' value to_number(:P31_ELIGIBLE)));',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 33, p_items => ''P33_ID'', p_values => l_id));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000791)
,p_internal_uid=>91820273000000794
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000795)
,p_branch_action=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.::P31_UNIT:&P31_UNIT.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
