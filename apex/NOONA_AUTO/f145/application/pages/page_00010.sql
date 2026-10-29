prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>145
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>'Services'
,p_alias=>'SERVICES'
,p_step_title=>'الخدمات (الكروت) وقطعها'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000201)
,p_plug_name=>'فئة جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000202)
,p_name=>'P10_C_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000201)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820280000000203)
,p_name=>'P10_C_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000201)
,p_prompt=>'الفئة (ميكانيكا، كهرباء، زيوت، إطارات، سمكرة ودهان...)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820280000000204)
,p_name=>'P10_C_ICON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000201)
,p_prompt=>'أيقونة Font Awesome (fa-cogs)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820280000000205)
,p_name=>'P10_C_COLOR'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000201)
,p_prompt=>'لون الكرت (#1565c0)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>10
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000206)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000201)
,p_button_name=>'ADD_CAT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة الفئة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000207)
,p_plug_name=>'الخدمة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000208)
,p_name=>'P10_ID'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'تعديل خدمة قائمة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select s.name_ar || '' ('' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from aut_service s where s.company_id = noona_aut_pkg.company and s.is_active = ''Y'' order by s.sort_order nulls last, s.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- خدمة جديدة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000209)
,p_name=>'P10_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820280000000210)
,p_name=>'P10_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'اسم الخدمة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820280000000211)
,p_name=>'P10_CAT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'الفئة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from aut_service_category where company_id = noona_aut_pkg.company and is_active = ''Y'' order by sort_order nulls last, name_ar'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000212)
,p_name=>'P10_PRICE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'السعر'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000213)
,p_name=>'P10_INC'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'السعر شامل الضريبة'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000214)
,p_name=>'P10_MIN'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'الوقت القياسي (دقيقة)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000215)
,p_name=>'P10_WDAYS'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'ضمان العمل (يوم)'
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
 p_id=>wwv_flow_imp.id(91820280000000216)
,p_name=>'P10_NDAYS'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'الخدمة التالية بعد (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000217)
,p_name=>'P10_NKM'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'الخدمة التالية بعد (كم)'
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
 p_id=>wwv_flow_imp.id(91820280000000218)
,p_name=>'P10_ICON'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'أيقونة الكرت (fa-tint)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820280000000219)
,p_name=>'P10_SORT'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'الترتيب'
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
 p_id=>wwv_flow_imp.id(91820280000000220)
,p_name=>'P10_ACTIVE'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;Y,موقوف;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000221)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000207)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الخدمة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000222)
,p_plug_name=>'القطع الافتراضية للخدمة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">تضاف القطع الإلزامية تلقائياً مع الخدمة في أمر الإصلاح وتصرف من المخزون مع الفاتورة؛ الاختيارية تقترح فقط.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P10_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000223)
,p_name=>'P10_P_ITEM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000222)
,p_prompt=>'القطعة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select i.item_no || '' - '' || i.name_ar || nvl2(i.manufacturer_part_no, '' ['' || i.manufacturer_part_no || '']'', '''') d, i.id r from inv_item i where i.status_code = ''ACTIVE'' and i.is_sellable = ''Y'' and i.item_type not in (''SERVICE'', ''ASSET'', ''REAL_ESTATE_UNIT'') order by i.name_ar'
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
 p_id=>wwv_flow_imp.id(91820280000000224)
,p_name=>'P10_P_QTY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000222)
,p_prompt=>'الكمية'
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
 p_id=>wwv_flow_imp.id(91820280000000225)
,p_name=>'P10_P_OPT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000222)
,p_prompt=>'اختيارية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000226)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000222)
,p_button_name=>'ADD_PART'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة / تعديل القطعة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000227)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820280000000222)
,p_button_name=>'DEL_PART'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف القطعة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000228)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P10_INC := nvl(:P10_INC, ''N''); :P10_ACTIVE := nvl(:P10_ACTIVE, ''Y''); :P10_P_QTY := nvl(:P10_P_QTY, 1); :P10_P_OPT := nvl(:P10_P_OPT, ''N'');',
'    if :P10_ID is not null then',
'        select code, name_ar, category_id, price, price_includes_tax, standard_minutes, warranty_days, next_service_days, next_service_km,',
'               icon, sort_order, is_active',
'          into :P10_CODE, :P10_NAME, :P10_CAT, :P10_PRICE, :P10_INC, :P10_MIN, :P10_WDAYS, :P10_NDAYS, :P10_NKM, :P10_ICON, :P10_SORT, :P10_ACTIVE',
'          from aut_service where id = :P10_ID and company_id = noona_aut_pkg.company;',
'    end if;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000228
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000229)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Category'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_o json_object_t := json_object_t(); l number;',
'begin',
'    l_o.put(''code'', :P10_C_CODE); l_o.put(''name'', :P10_C_NAME); l_o.put(''icon'', :P10_C_ICON); l_o.put(''color'', :P10_C_COLOR);',
'    l := noona_aut_pkg.save_category(l_o.to_clob); :P10_CAT := l;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000206)
,p_process_success_message=>'تمت إضافة الفئة'
,p_internal_uid=>91820280000000229
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000230)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Service'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_o json_object_t := json_object_t();',
'begin',
'    l_o.put(''id'', to_number(:P10_ID)); l_o.put(''code'', :P10_CODE); l_o.put(''name'', :P10_NAME); l_o.put(''cat'', to_number(:P10_CAT));',
'    l_o.put(''price'', to_number(:P10_PRICE)); l_o.put(''inc'', :P10_INC); l_o.put(''minutes'', to_number(:P10_MIN));',
'    l_o.put(''warrantyDays'', to_number(:P10_WDAYS)); l_o.put(''nextDays'', to_number(:P10_NDAYS)); l_o.put(''nextKm'', to_number(:P10_NKM));',
'    l_o.put(''icon'', :P10_ICON); l_o.put(''sort'', to_number(:P10_SORT)); l_o.put(''active'', :P10_ACTIVE);',
'    :P10_ID := noona_aut_pkg.save_service(l_o.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000221)
,p_process_success_message=>'تم حفظ الخدمة'
,p_internal_uid=>91820280000000230
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000231)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Part Add'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_o json_object_t := json_object_t();',
'    l_a json_array_t := json_array_t();',
'    l_p json_object_t;',
'begin',
'    l_o.put(''id'', to_number(:P10_ID)); l_o.put(''code'', :P10_CODE); l_o.put(''name'', :P10_NAME); l_o.put(''cat'', to_number(:P10_CAT));',
'    l_o.put(''price'', to_number(:P10_PRICE)); l_o.put(''inc'', :P10_INC); l_o.put(''minutes'', to_number(:P10_MIN));',
'    l_o.put(''warrantyDays'', to_number(:P10_WDAYS)); l_o.put(''nextDays'', to_number(:P10_NDAYS)); l_o.put(''nextKm'', to_number(:P10_NKM));',
'    l_o.put(''icon'', :P10_ICON); l_o.put(''sort'', to_number(:P10_SORT)); l_o.put(''active'', :P10_ACTIVE);',
'    for x in (select item_id, quantity, is_optional from aut_service_part where service_id = to_number(:P10_ID)',
'               and item_id <> nvl(to_number(:P10_P_ITEM), -1) order by id) loop',
'        l_p := json_object_t(); l_p.put(''item'', x.item_id); l_p.put(''qty'', x.quantity); l_p.put(''optional'', x.is_optional); l_a.append(l_p);',
'    end loop;',
'    if :REQUEST = ''ADD_PART'' and :P10_P_ITEM is not null then',
'        l_p := json_object_t(); l_p.put(''item'', to_number(:P10_P_ITEM)); l_p.put(''qty'', to_number(:P10_P_QTY)); l_p.put(''optional'', :P10_P_OPT);',
'        l_a.append(l_p);',
'    end if;',
'    l_o.put(''parts'', l_a);',
'    :P10_ID := noona_aut_pkg.save_service(l_o.to_clob); :P10_P_ITEM := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000226)
,p_process_success_message=>'تم تحديث قطع الخدمة'
,p_internal_uid=>91820280000000231
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000232)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Part Remove'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_o json_object_t := json_object_t();',
'    l_a json_array_t := json_array_t();',
'    l_p json_object_t;',
'begin',
'    l_o.put(''id'', to_number(:P10_ID)); l_o.put(''code'', :P10_CODE); l_o.put(''name'', :P10_NAME); l_o.put(''cat'', to_number(:P10_CAT));',
'    l_o.put(''price'', to_number(:P10_PRICE)); l_o.put(''inc'', :P10_INC); l_o.put(''minutes'', to_number(:P10_MIN));',
'    l_o.put(''warrantyDays'', to_number(:P10_WDAYS)); l_o.put(''nextDays'', to_number(:P10_NDAYS)); l_o.put(''nextKm'', to_number(:P10_NKM));',
'    l_o.put(''icon'', :P10_ICON); l_o.put(''sort'', to_number(:P10_SORT)); l_o.put(''active'', :P10_ACTIVE);',
'    for x in (select item_id, quantity, is_optional from aut_service_part where service_id = to_number(:P10_ID)',
'               and item_id <> nvl(to_number(:P10_P_ITEM), -1) order by id) loop',
'        l_p := json_object_t(); l_p.put(''item'', x.item_id); l_p.put(''qty'', x.quantity); l_p.put(''optional'', x.is_optional); l_a.append(l_p);',
'    end loop;',
'    if :REQUEST = ''ADD_PART'' and :P10_P_ITEM is not null then',
'        l_p := json_object_t(); l_p.put(''item'', to_number(:P10_P_ITEM)); l_p.put(''qty'', to_number(:P10_P_QTY)); l_p.put(''optional'', :P10_P_OPT);',
'        l_a.append(l_p);',
'    end if;',
'    l_o.put(''parts'', l_a);',
'    :P10_ID := noona_aut_pkg.save_service(l_o.to_clob); :P10_P_ITEM := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000227)
,p_process_success_message=>'تم حذف القطعة من الخدمة'
,p_internal_uid=>91820280000000232
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000233)
,p_plug_name=>'قطع الخدمة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>16
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select sp.id, i.item_no, i.name_ar, i.manufacturer_part_no, sp.quantity, case sp.is_optional when ''Y'' then ''اختيارية'' else ''إلزامية'' end as opt,',
'       c.sale_price, noona_inv_pkg.on_hand(i.id, noona_aut_pkg.default_warehouse) as on_hand',
'  from aut_service_part sp join inv_item i on i.id = sp.item_id left join inv_item_company c on c.item_id = i.id and c.company_id = noona_aut_pkg.company',
' where sp.service_id = to_number(:P10_ID) order by sp.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'قطع الخدمة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820280000000234)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_owner=>'NOONA'
,p_internal_uid=>91820280000000234
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000236)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000237)
,p_db_column_name=>'ITEM_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'رقم الصنف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000238)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'القطعة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000239)
,p_db_column_name=>'MANUFACTURER_PART_NO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'رقم القطعة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000240)
,p_db_column_name=>'QUANTITY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000241)
,p_db_column_name=>'OPT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000242)
,p_db_column_name=>'SALE_PRICE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'السعر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000243)
,p_db_column_name=>'ON_HAND'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المتوفر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820280000000235)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'235'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ITEM_NO:NAME_AR:MANUFACTURER_PART_NO:QUANTITY:OPT:SALE_PRICE:ON_HAND'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000244)
,p_plug_name=>'الخدمات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, g.name_ar as cat, s.code, s.name_ar, s.price, case s.price_includes_tax when ''Y'' then ''شامل'' else ''غير شامل'' end as inc,',
'       s.standard_minutes, s.next_service_days, s.next_service_km,',
'       (select count(*) from aut_service_part p where p.service_id = s.id) as parts, case s.is_active when ''Y'' then ''نشطة'' else ''موقوفة'' end as status',
'  from aut_service s join aut_service_category g on g.id = s.category_id where s.company_id = noona_aut_pkg.company',
' order by g.sort_order nulls last, g.name_ar, s.sort_order nulls last, s.name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الخدمات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820280000000245)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:RP,10:P10_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820280000000245
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000247)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000248)
,p_db_column_name=>'CAT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000249)
,p_db_column_name=>'CODE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000250)
,p_db_column_name=>'NAME_AR'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الخدمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000251)
,p_db_column_name=>'PRICE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'السعر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000252)
,p_db_column_name=>'INC'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الضريبة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000253)
,p_db_column_name=>'STANDARD_MINUTES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الدقائق'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000254)
,p_db_column_name=>'NEXT_SERVICE_DAYS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'التالية (يوم)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000255)
,p_db_column_name=>'NEXT_SERVICE_KM'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'التالية (كم)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000256)
,p_db_column_name=>'PARTS'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'القطع'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000257)
,p_db_column_name=>'STATUS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820280000000246)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'246'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CAT:CODE:NAME_AR:PRICE:INC:STANDARD_MINUTES:NEXT_SERVICE_DAYS:NEXT_SERVICE_KM:PARTS:STATUS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000258)
,p_branch_action=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.::P10_ID:&P10_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
