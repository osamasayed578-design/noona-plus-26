prompt --application/pages/page_00027
begin
--   Manifest
--     PAGE: 00027
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
 p_id=>27
,p_name=>'Hotel Setup'
,p_alias=>'HOTEL-SETUP'
,p_step_title=>'إعداد الضيافة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000301)
,p_plug_name=>'الفندق'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000302)
,p_name=>'P27_PROPERTY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000301)
,p_prompt=>'الفندق / العقار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from re_property where company_id = noona_re_pkg.company and status_code <> ''INACTIVE'' order by code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000303)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P27_PROPERTY := nvl(:P27_PROPERTY, noona_hsp_pkg.default_property);',
'    if :P27_PROPERTY is null then',
'        select min(id) into :P27_PROPERTY from re_property where company_id = noona_hsp_pkg.company;',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000303
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000304)
,p_plug_name=>'نوع غرفة / شقة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000305)
,p_name=>'P27_RT_ID'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820273000000304)
,p_prompt=>'تعديل نوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from hsp_room_type where property_id = :P27_PROPERTY order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- نوع جديد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000306)
,p_name=>'P27_RT_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000304)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>10
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
 p_id=>wwv_flow_imp.id(91820273000000307)
,p_name=>'P27_RT_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000304)
,p_prompt=>'الاسم (ديلوكس، جناح، شقة غرفتين...)'
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
 p_id=>wwv_flow_imp.id(91820273000000308)
,p_name=>'P27_RT_ADULTS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000304)
,p_prompt=>'أقصى بالغين'
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
 p_id=>wwv_flow_imp.id(91820273000000309)
,p_name=>'P27_RT_CHILDREN'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000304)
,p_prompt=>'أقصى أطفال'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000310)
,p_name=>'P27_RT_BEDS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000304)
,p_prompt=>'الأسرة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000311)
,p_name=>'P27_RT_RATE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000304)
,p_prompt=>'السعر الأساسي لليلة'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000312)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000304)
,p_button_name=>'SAVE_RT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ النوع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000313)
,p_process_sequence=>6
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load type'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P27_RT_ID is not null then',
'        select code, name_ar, max_adults, max_children, bed_config, base_rate into :P27_RT_CODE, :P27_RT_NAME, :P27_RT_ADULTS,',
'               :P27_RT_CHILDREN, :P27_RT_BEDS, :P27_RT_RATE from hsp_room_type where id = :P27_RT_ID;',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000313
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000314)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save type'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P27_RT_ID := noona_hsp_pkg.save_room_type(:P27_RT_ID, :P27_PROPERTY, :P27_RT_CODE, :P27_RT_NAME,',
'                       :P27_RT_ADULTS, :P27_RT_CHILDREN, :P27_RT_BEDS, :P27_RT_RATE);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000312)
,p_process_success_message=>'تم حفظ النوع'
,p_internal_uid=>91820273000000314
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000315)
,p_plug_name=>'خطة أسعار وسعر موسمي'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الخطة اليومية للفنادق، والأسبوعية والشهرية للشقق الفندقية (يقسم السعر على 7 أو 30 لليلة). السعر الموسمي يسري في فترته على النوع المحدد.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000316)
,p_name=>'P27_PL_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'رمز الخطة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>10
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
 p_id=>wwv_flow_imp.id(91820273000000317)
,p_name=>'P27_PL_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'اسم الخطة'
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
 p_id=>wwv_flow_imp.id(91820273000000318)
,p_name=>'P27_PL_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'نوع الإقامة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:يومي;DAILY,أسبوعي;WEEKLY,شهري;MONTHLY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000319)
,p_name=>'P27_PL_MEAL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'الوجبات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بدون وجبات;ROOM_ONLY,إفطار;BREAKFAST,نصف إقامة;HALF_BOARD,إقامة كاملة;FULL_BOARD'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000320)
,p_name=>'P27_PL_TAX'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'السعر شامل الضريبة'
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
 p_id=>wwv_flow_imp.id(91820273000000321)
,p_name=>'P27_PL_POLICY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'سياسة الإلغاء'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000322)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_button_name=>'SAVE_PLAN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة الخطة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000323)
,p_name=>'P27_R_PLAN'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'الخطة (للسعر الموسمي)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from hsp_rate_plan where property_id = :P27_PROPERTY order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000324)
,p_name=>'P27_R_TYPE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'نوع الغرفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from hsp_room_type where property_id = :P27_PROPERTY order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000325)
,p_name=>'P27_R_FROM'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'من'
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
 p_id=>wwv_flow_imp.id(91820273000000326)
,p_name=>'P27_R_TO'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'إلى'
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
 p_id=>wwv_flow_imp.id(91820273000000327)
,p_name=>'P27_R_AMOUNT'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_prompt=>'السعر (لليلة/الأسبوع/الشهر حسب الخطة)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000328)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000315)
,p_button_name=>'SAVE_RATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ السعر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000329)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save plan'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_hsp_pkg.save_rate_plan(null, :P27_PROPERTY, :P27_PL_CODE, :P27_PL_NAME, :P27_PL_TYPE, :P27_PL_MEAL, :P27_PL_TAX, :P27_PL_POLICY);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000322)
,p_process_success_message=>'تمت إضافة خطة الأسعار'
,p_internal_uid=>91820273000000329
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000330)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save rate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_hsp_pkg.set_rate(:P27_R_PLAN, :P27_R_TYPE, to_date(:P27_R_FROM, ''YYYY-MM-DD''), to_date(:P27_R_TO, ''YYYY-MM-DD''), :P27_R_AMOUNT);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000328)
,p_process_success_message=>'تم حفظ السعر'
,p_internal_uid=>91820273000000330
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000331)
,p_plug_name=>'الغرف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000332)
,p_name=>'P27_ROOM_NO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000331)
,p_prompt=>'رقم الغرفة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>8
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
 p_id=>wwv_flow_imp.id(91820273000000333)
,p_name=>'P27_ROOM_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000331)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from hsp_room_type where property_id = :P27_PROPERTY order by code'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000334)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000331)
,p_button_name=>'ADD_ROOM'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة غرفة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000335)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000331)
,p_button_name=>'FROM_UNITS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إنشاء غرف من وحدات الضيافة في العقار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000336)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add room'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_hsp_pkg.add_room(:P27_PROPERTY, :P27_ROOM_TYPE, :P27_ROOM_NO);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000334)
,p_process_success_message=>'تمت إضافة الغرفة'
,p_internal_uid=>91820273000000336
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000337)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'From units'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_hsp_pkg.rooms_from_units(:P27_PROPERTY, :P27_ROOM_TYPE);',
'    apex_application.g_print_success_message := ''تم إنشاء '' || l_n || '' غرفة من الوحدات'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000335)
,p_internal_uid=>91820273000000337
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000338)
,p_process_sequence=>7
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults2'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P27_PL_TYPE := nvl(:P27_PL_TYPE, ''DAILY''); :P27_PL_MEAL := nvl(:P27_PL_MEAL, ''ROOM_ONLY'');',
':P27_PL_TAX := nvl(:P27_PL_TAX, ''N'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000338
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000339)
,p_plug_name=>'أنواع الغرف والأسعار'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.id, t.code, t.name_ar, t.max_adults, t.base_rate, (select count(*) from hsp_room r where r.room_type_id = t.id) as rooms,',
'       (select listagg(pl.name_ar || '': '' || to_char(x.rate_amount, ''FM999G990'') || '' ('' || to_char(x.date_from, ''MM-DD'') || ''→'' || to_char(x.date_to, ''MM-DD'') || '')'', '' | '')',
'          within group (order by x.date_from) from hsp_rate x join hsp_rate_plan pl on pl.id = x.rate_plan_id where x.room_type_id = t.id) as rates',
'  from hsp_room_type t where t.property_id = :P27_PROPERTY order by t.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أنواع الغرف والأسعار'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000340)
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
,p_internal_uid=>91820273000000340
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000342)
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
 p_id=>wwv_flow_imp.id(91820273000000343)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000344)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000345)
,p_db_column_name=>'MAX_ADULTS'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'السعة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000346)
,p_db_column_name=>'BASE_RATE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'السعر الأساسي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000347)
,p_db_column_name=>'ROOMS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الغرف'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000348)
,p_db_column_name=>'RATES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الأسعار الموسمية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000341)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'341'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:MAX_ADULTS:BASE_RATE:ROOMS:RATES'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000349)
,p_plug_name=>'الغرف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, r.room_no, t.name_ar as rtype, f.name_ar as floor_name, noona_hsp_pkg.hk_label(r.housekeeping_status) as hk,',
'       case r.status_code when ''ACTIVE'' then ''في الخدمة'' when ''OUT_OF_ORDER'' then ''خارج الخدمة'' else r.status_code end as status, r.notes',
'  from hsp_room r join hsp_room_type t on t.id = r.room_type_id left join re_floor f on f.id = r.floor_id',
' where r.property_id = :P27_PROPERTY order by f.floor_no, r.room_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الغرف'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000350)
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
,p_internal_uid=>91820273000000350
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000352)
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
 p_id=>wwv_flow_imp.id(91820273000000353)
,p_db_column_name=>'ROOM_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الغرفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000354)
,p_db_column_name=>'RTYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000355)
,p_db_column_name=>'FLOOR_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الطابق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000356)
,p_db_column_name=>'HK'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'النظافة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000357)
,p_db_column_name=>'STATUS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000358)
,p_db_column_name=>'NOTES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'ملاحظات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000351)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'351'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ROOM_NO:RTYPE:FLOOR_NAME:HK:STATUS:NOTES'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000359)
,p_branch_action=>'f?p=&APP_ID.:27:&SESSION.::&DEBUG.::P27_PROPERTY,P27_RT_ID:&P27_PROPERTY.,&P27_RT_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
