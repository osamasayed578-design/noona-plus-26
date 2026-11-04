prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>147
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Shipment Order'
,p_alias=>'ORDER'
,p_step_title=>'أمر شحن'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000044)
,p_plug_name=>'بيانات الشحنة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000045)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000046)
,p_name=>'P11_INFO'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'الأمر'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000047)
,p_name=>'P11_CUST'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'العميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_sal_pkg.customer_label(a.id) d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id where a.company_id = noona_trn_pkg.company and a.status_code = ''ACTIVE'' and nvl(c.is_walk_in, ''N'') = ''N'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000048)
,p_name=>'P11_REF'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'مرجع العميل'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820290000000049)
,p_name=>'P11_FROM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'مكان التحميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from trn_location where company_id = noona_trn_pkg.company and is_active = ''Y'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000050)
,p_name=>'P11_TO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'مكان التفريغ'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from trn_location where company_id = noona_trn_pkg.company and is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820290000000051)
,p_name=>'P11_CARGO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'نوع الشحنة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from trn_cargo_type where company_id = noona_trn_pkg.company and is_active = ''Y'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000052)
,p_name=>'P11_DESC'
,p_item_sequence=>45
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'وصف البضاعة'
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
 p_id=>wwv_flow_imp.id(91820290000000053)
,p_name=>'P11_QTY'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'الكمية'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000054)
,p_name=>'P11_UOM'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'الوحدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:طن متري;METRIC_TON,طن قصير (أمريكي);SHORT_TON,طن طويل (بريطاني);LONG_TON,كيلوجرام;KG,متر مكعب;M3,لتر;LITER,حاوية;CONTAINER,طبلية;PALLET,قطعة;PIECE,رحلة;TRIP'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000055)
,p_name=>'P11_KG'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'الوزن بالكيلوجرام (يحسب تلقائياً للأطنان)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000056)
,p_name=>'P11_VOL'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'الحجم (م³)'
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
 p_id=>wwv_flow_imp.id(91820290000000057)
,p_name=>'P11_PKG'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'عدد الطرود'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000058)
,p_name=>'P11_VALUE'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'القيمة المصرح بها'
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
 p_id=>wwv_flow_imp.id(91820290000000059)
,p_name=>'P11_PICKUP'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'تاريخ التحميل'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
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
 p_id=>wwv_flow_imp.id(91820290000000060)
,p_name=>'P11_DELIVERY'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'تاريخ التسليم المطلوب'
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
 p_id=>wwv_flow_imp.id(91820290000000061)
,p_name=>'P11_OTHER'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_prompt=>'رسوم أخرى (تحميل، تفريغ، انتظار)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000062)
,p_plug_name=>'السعر'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يطبق تلقائياً أخص تعرفة سارية (العميل ثم المسار ثم نوع الشحنة). لسعر متفق عليه خاص بهذا الأمر اختر الأساس وأدخل السعر.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000063)
,p_name=>'P11_BASIS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000062)
,p_prompt=>'أساس سعر يدوي (اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:للطن المتري;PER_METRIC_TON,للطن القصير;PER_SHORT_TON,للطن الطويل;PER_LONG_TON,للكيلوجرام;PER_KG,للمتر المكعب;PER_M3,للتر;PER_LITER,للكيلومتر;PER_KM,للطن-كيلومتر;PER_TON_KM,للرحلة;PER_TRIP,للحاوية;PER_CONTAINER,للطبلية;PER_PALLET,للقطعة;PER_PIECE'
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
 p_id=>wwv_flow_imp.id(91820290000000064)
,p_name=>'P11_RATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000062)
,p_prompt=>'السعر اليدوي'
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
 p_id=>wwv_flow_imp.id(91820290000000065)
,p_name=>'P11_PRICE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000062)
,p_prompt=>'الترحيل المحسوب'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000066)
,p_name=>'P11_NOTES'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000062)
,p_prompt=>'ملاحظات'
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
 p_id=>wwv_flow_imp.id(91820290000000067)
,p_name=>'P11_REASON'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000062)
,p_prompt=>'سبب الإلغاء'
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
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000068)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for o in (select * from trn_order where id = :P11_ID and company_id = noona_trn_pkg.company) loop',
'    :P11_CUST := o.customer_account_id; :P11_REF := o.customer_ref; :P11_FROM := o.from_location_id; :P11_TO := o.to_location_id;',
'    :P11_CARGO := o.cargo_type_id; :P11_DESC := o.cargo_description; :P11_QTY := o.quantity; :P11_UOM := o.uom_code;',
'    :P11_KG := o.weight_kg; :P11_VOL := o.volume_m3; :P11_PKG := o.packages_count; :P11_VALUE := o.declared_value;',
'    :P11_PICKUP := to_char(o.pickup_date, ''YYYY-MM-DD''); :P11_DELIVERY := to_char(o.required_delivery_date, ''YYYY-MM-DD'');',
'    :P11_OTHER := o.other_charges; :P11_NOTES := o.notes;',
'    :P11_INFO := o.doc_no || '' · '' || noona_trn_pkg.status_label(o.status_code);',
'    :P11_PRICE := noona_trn_pkg.basis_label(o.rate_basis) || '' '' || o.rate_amount || '' = '' || to_char(o.freight_amount, ''FM999G999G990D00'')',
'                  || '' + رسوم '' || to_char(o.other_charges, ''FM999G990D00'') || '' = '' || to_char(o.total_amount, ''FM999G999G990D00'');',
'    if o.rate_id is null then :P11_BASIS := o.rate_basis; :P11_RATE := o.rate_amount; end if;',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000068
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000070)
,p_validation_name=>'P11_CUST required (SAVE)'
,p_validation_sequence=>25
,p_validation=>'P11_CUST'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000069)
,p_associated_item=>wwv_flow_imp.id(91820290000000047)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000071)
,p_validation_name=>'P11_FROM required (SAVE)'
,p_validation_sequence=>26
,p_validation=>'P11_FROM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000069)
,p_associated_item=>wwv_flow_imp.id(91820290000000049)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000072)
,p_validation_name=>'P11_TO required (SAVE)'
,p_validation_sequence=>27
,p_validation=>'P11_TO'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000069)
,p_associated_item=>wwv_flow_imp.id(91820290000000050)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000073)
,p_validation_name=>'P11_CARGO required (SAVE)'
,p_validation_sequence=>28
,p_validation=>'P11_CARGO'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000069)
,p_associated_item=>wwv_flow_imp.id(91820290000000051)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000074)
,p_validation_name=>'P11_QTY required (SAVE)'
,p_validation_sequence=>29
,p_validation=>'P11_QTY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000069)
,p_associated_item=>wwv_flow_imp.id(91820290000000053)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000069)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ وتسعير'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000076)
,p_validation_name=>'P11_CUST required (CONFIRM)'
,p_validation_sequence=>31
,p_validation=>'P11_CUST'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000075)
,p_associated_item=>wwv_flow_imp.id(91820290000000047)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000077)
,p_validation_name=>'P11_FROM required (CONFIRM)'
,p_validation_sequence=>32
,p_validation=>'P11_FROM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000075)
,p_associated_item=>wwv_flow_imp.id(91820290000000049)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000078)
,p_validation_name=>'P11_TO required (CONFIRM)'
,p_validation_sequence=>33
,p_validation=>'P11_TO'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000075)
,p_associated_item=>wwv_flow_imp.id(91820290000000050)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000079)
,p_validation_name=>'P11_CARGO required (CONFIRM)'
,p_validation_sequence=>34
,p_validation=>'P11_CARGO'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000075)
,p_associated_item=>wwv_flow_imp.id(91820290000000051)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000080)
,p_validation_name=>'P11_QTY required (CONFIRM)'
,p_validation_sequence=>35
,p_validation=>'P11_QTY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000075)
,p_associated_item=>wwv_flow_imp.id(91820290000000053)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000075)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000044)
,p_button_name=>'CONFIRM'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تأكيد الأمر'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.order_status(:P11_ID) = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000081)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000062)
,p_button_name=>'CANCEL_ORDER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الأمر'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.order_status(:P11_ID) in (''DRAFT'',''CONFIRMED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000082)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'  select json_object(''id'' value to_number(:P11_ID), ''customer'' value to_number(:P11_CUST), ''customerRef'' value :P11_REF, ''from'' value to_number(:P11_FROM), ''to'' value to_number(:P11_TO), ''cargo'' value to_number(:P11_CARGO), ''description'' value :P11_DESC, ''qty'' value to_number(:P11_QTY), ''uom'' value :P11_UOM, ''weightKg'' value to_number(:P11_KG), ''volume'' value to_number(:P11_VOL), ''packages'' value to_number(:P11_PKG), ''declaredValue'' value to_number(:P11_VALUE), ''pickupDate'' value :P11_PICKUP, ''deliveryDate'' value :P11_DELIVERY, ''otherCharges'' value to_number(:P11_OTHER), ''basis'' value :P11_BASIS, ''rate'' value to_number(:P11_RATE), ''notes'' value :P11_NOTES absent on null) into l from dual;',
'  :P11_ID := noona_trn_pkg.save_order(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000069)
,p_process_success_message=>'تم حفظ أمر الشحن وتسعيره'
,p_internal_uid=>91820290000000082
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000083)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Confirm'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.confirm_order(:P11_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000075)
,p_process_success_message=>'تم تأكيد الأمر؛ جاهز للتحميل على رحلة'
,p_internal_uid=>91820290000000083
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000084)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.cancel_order(:P11_ID, :P11_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000081)
,p_process_success_message=>'تم إلغاء الأمر'
,p_internal_uid=>91820290000000084
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000085)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.::P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
