prompt --application/pages/page_00035
begin
--   Manifest
--     PAGE: 00035
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
 p_id=>35
,p_name=>'Prices & Payment Plans'
,p_alias=>'UNIT-PRICING'
,p_step_title=>'الأسعار وخطط السداد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000870)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000987)
,p_plug_name=>'قائمة أسعار جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">تتولد أسعار كل وحدات البيع في العقار من سعر المتر وعلاوة الطابق (نسبة لكل طابق)، والحد الأدنى بنسبة خصم مسموحة. تبقى مسودة حتى تفعيلها.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000988)
,p_name=>'P35_PROPERTY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000987)
,p_prompt=>'العقار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from re_property p where p.company_id = noona_res_pkg.company and p.status_code <> ''INACTIVE'' and exists (select 1 from re_unit u where u.property_id = p.id and u.usage_type in (''SALE'', ''MIXED'')) order by p.code'
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
 p_id=>wwv_flow_imp.id(91820273000000989)
,p_name=>'P35_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000987)
,p_prompt=>'اسم القائمة'
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
 p_id=>wwv_flow_imp.id(91820273000000990)
,p_name=>'P35_SQM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000987)
,p_prompt=>'سعر المتر'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000991)
,p_name=>'P35_FLOOR_PCT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000987)
,p_prompt=>'علاوة كل طابق %'
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
 p_id=>wwv_flow_imp.id(91820273000000992)
,p_name=>'P35_MAX_DISC'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000987)
,p_prompt=>'أقصى خصم دون موافقة %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000993)
,p_name=>'P35_FROM'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000987)
,p_prompt=>'سارية من'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000995)
,p_validation_name=>'P35_PROPERTY required (CREATE_LIST)'
,p_validation_sequence=>7
,p_validation=>'P35_PROPERTY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000994)
,p_associated_item=>wwv_flow_imp.id(91820273000000988)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000996)
,p_validation_name=>'P35_NAME required (CREATE_LIST)'
,p_validation_sequence=>8
,p_validation=>'P35_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000994)
,p_associated_item=>wwv_flow_imp.id(91820273000000989)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000997)
,p_validation_name=>'P35_SQM required (CREATE_LIST)'
,p_validation_sequence=>9
,p_validation=>'P35_SQM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000994)
,p_associated_item=>wwv_flow_imp.id(91820273000000990)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000994)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000987)
,p_button_name=>'CREATE_LIST'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء القائمة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000998)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Price List'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_a json_array_t := json_array_t(); l_o json_object_t; l_p number; l_id number; l_doc json_object_t := json_object_t();',
'begin',
'    for u in (select u.id, nvl(u.net_area_sqm, u.gross_area_sqm) area, nvl(f.floor_no, 0) fl from re_unit u left join re_floor f on f.id = u.floor_id',
'               where u.property_id = :P35_PROPERTY and u.usage_type in (''SALE'', ''MIXED'') and nvl(u.net_area_sqm, u.gross_area_sqm) > 0) loop',
'        l_p := round(u.area * to_number(:P35_SQM) * (1 + nvl(to_number(:P35_FLOOR_PCT), 0) * u.fl / 100), -2);',
'        l_o := json_object_t(); l_o.put(''unit'', u.id); l_o.put(''price'', l_p);',
'        if :P35_MAX_DISC is not null then l_o.put(''min'', round(l_p * (1 - to_number(:P35_MAX_DISC) / 100), -2)); end if;',
'        l_a.append(l_o);',
'    end loop;',
'    l_doc.put(''property'', to_number(:P35_PROPERTY)); l_doc.put(''name'', :P35_NAME); l_doc.put(''from'', :P35_FROM); l_doc.put(''lines'', l_a);',
'    l_id := noona_res_pkg.save_price_list(l_doc.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000994)
,p_process_success_message=>'تم إنشاء قائمة الأسعار (مسودة)'
,p_internal_uid=>91820273000000998
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000999)
,p_plug_name=>'قوائم الأسعار'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_res_pkg.price_lists_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001000)
,p_plug_name=>'تفعيل قائمة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001001)
,p_name=>'P35_LIST'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001000)
,p_prompt=>'القائمة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from re_price_list where company_id = noona_res_pkg.company and status_code in (''DRAFT'', ''APPROVED'') order by id desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001002)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001000)
,p_button_name=>'ACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تفعيل وتحديث أسعار الوحدات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001003)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Activate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_res_pkg.activate_price_list(:P35_LIST);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001002)
,p_process_success_message=>'تم تفعيل القائمة'
,p_internal_uid=>91820273000001003
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001004)
,p_plug_name=>'خطة سداد جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001005)
,p_name=>'P35_PLAN_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001004)
,p_prompt=>'اسم الخطة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001006)
,p_name=>'P35_PLAN_PROP'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001004)
,p_prompt=>'العقار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from re_property p where p.company_id = noona_res_pkg.company and p.status_code <> ''INACTIVE'' and exists (select 1 from re_unit u where u.property_id = p.id and u.usage_type in (''SALE'', ''MIXED'')) order by p.code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- كل العقارات -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001007)
,p_name=>'P35_DOWN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000001004)
,p_prompt=>'الدفعة الأولى %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001008)
,p_name=>'P35_COUNT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000001004)
,p_prompt=>'عدد الأقساط'
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
 p_id=>wwv_flow_imp.id(91820273000001009)
,p_name=>'P35_FREQ'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000001004)
,p_prompt=>'تكرار الأقساط'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:شهري;MONTHLY,ربع سنوي;QUARTERLY,نصف سنوي;SEMI_ANNUAL,سنوي;ANNUAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001010)
,p_name=>'P35_HO'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000001004)
,p_prompt=>'دفعة عند التسليم %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000001012)
,p_validation_name=>'P35_PLAN_NAME required (SAVE_PLAN)'
,p_validation_sequence=>24
,p_validation=>'P35_PLAN_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000001011)
,p_associated_item=>wwv_flow_imp.id(91820273000001005)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001011)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001004)
,p_button_name=>'SAVE_PLAN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ الخطة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001013)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Plan'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_res_pkg.save_plan(json_object(''name'' value :P35_PLAN_NAME, ''property'' value to_number(:P35_PLAN_PROP),',
'              ''down'' value to_number(:P35_DOWN), ''count'' value to_number(:P35_COUNT), ''freq'' value :P35_FREQ,',
'              ''handover'' value to_number(:P35_HO)));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001011)
,p_process_success_message=>'تم حفظ خطة السداد'
,p_internal_uid=>91820273000001013
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001014)
,p_plug_name=>'خطط السداد'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_res_pkg.plans_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001015)
,p_plug_name=>'رسملة تكاليف التطوير على الوحدات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">تنقل تكاليف مشروع التطوير المرتبط بالعقار (غير المرسملة) إلى «وحدات عقارية معدة للبيع» وتوزع على الوحدات التي لم تسلم، فتصبح تكلفة الوحدة عند تسليمها.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001016)
,p_name=>'P35_CAP_PROP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001015)
,p_prompt=>'العقار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from re_property where company_id = noona_res_pkg.company and project_id is not null order by code'
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
 p_id=>wwv_flow_imp.id(91820273000001017)
,p_name=>'P35_BASIS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001015)
,p_prompt=>'أساس التوزيع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المساحة;AREA,سعر البيع;SALE_VALUE,عدد الوحدات;UNIT_COUNT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001018)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001015)
,p_button_name=>'CAPITALIZE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رسملة التكاليف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001019)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Capitalize'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_res_pkg.capitalize_costs(:P35_CAP_PROP, :P35_BASIS);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001018)
,p_process_success_message=>'تمت رسملة تكاليف التطوير'
,p_internal_uid=>91820273000001019
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001020)
,p_plug_name=>'الرسملات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_res_pkg.allocations_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001021)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P35_FREQ := nvl(:P35_FREQ, ''QUARTERLY''); :P35_BASIS := nvl(:P35_BASIS, ''AREA'');',
'    :P35_FROM := nvl(:P35_FROM, to_char(sysdate, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000001021
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000001022)
,p_branch_action=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
