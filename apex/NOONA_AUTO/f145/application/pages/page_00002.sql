prompt --application/pages/page_00002
begin
--   Manifest
--     PAGE: 00002
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
 p_id=>2
,p_name=>'Check-in'
,p_alias=>'CHECK-IN'
,p_step_title=>'استلام سيارة وفتح أمر إصلاح'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000025)
,p_plug_name=>'المركبة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">اكتب رقم اللوحة واضغط «بحث»: تملأ بيانات المركبة المسجلة. اللوحة الجديدة تسجل مع الأمر.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000026)
,p_name=>'P2_PLATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_prompt=>'رقم اللوحة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000028)
,p_validation_name=>'P2_PLATE required (FIND)'
,p_validation_sequence=>2
,p_validation=>'P2_PLATE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000027)
,p_associated_item=>wwv_flow_imp.id(91820280000000026)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000027)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_button_name=>'FIND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'بحث'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000029)
,p_name=>'P2_VEH'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000030)
,p_name=>'P2_MAKE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_prompt=>'الشركة المصنعة'
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
 p_id=>wwv_flow_imp.id(91820280000000031)
,p_name=>'P2_MODEL'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_prompt=>'الطراز'
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
 p_id=>wwv_flow_imp.id(91820280000000032)
,p_name=>'P2_YEAR'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_prompt=>'سنة الصنع'
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
 p_id=>wwv_flow_imp.id(91820280000000033)
,p_name=>'P2_COLOR'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_prompt=>'اللون'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820280000000034)
,p_name=>'P2_VIN'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_prompt=>'رقم الهيكل (VIN)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>22
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
 p_id=>wwv_flow_imp.id(91820280000000035)
,p_name=>'P2_OWNER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_prompt=>'اسم المالك / العميل'
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
 p_id=>wwv_flow_imp.id(91820280000000036)
,p_name=>'P2_PHONE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820280000000025)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000037)
,p_plug_name=>'الاستلام'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000038)
,p_name=>'P2_ODO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000037)
,p_prompt=>'قراءة العداد (كم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000039)
,p_name=>'P2_FUEL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000037)
,p_prompt=>'مستوى الوقود'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:فارغ;EMPTY,ربع;QUARTER,نصف;HALF,ثلاثة أرباع;THREE_QUARTERS,ممتلئ;FULL'
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
 p_id=>wwv_flow_imp.id(91820280000000040)
,p_name=>'P2_BAY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000037)
,p_prompt=>'الرافعة / موقع العمل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from aut_bay where company_id = noona_aut_pkg.company and is_active = ''Y'' order by sort_order nulls last, code'
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
 p_id=>wwv_flow_imp.id(91820280000000041)
,p_name=>'P2_PROMISED'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000037)
,p_prompt=>'الموعد المتوقع للتسليم (YYYY-MM-DD HH24:MI)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>16
,p_cMaxlength=>16
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
 p_id=>wwv_flow_imp.id(91820280000000042)
,p_name=>'P2_COMPLAINT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000037)
,p_prompt=>'شكوى العميل / المطلوب'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000043)
,p_name=>'P2_INSPECT'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000037)
,p_prompt=>'فحص الاستلام: الأضرار والخدوش والمتعلقات'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000044)
,p_name=>'P2_SERVICES'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000037)
,p_prompt=>'الخدمات المطلوبة (اختياري؛ تضاف من الكروت لاحقاً)'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'select s.name_ar || '' ('' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from aut_service s where s.company_id = noona_aut_pkg.company and s.is_active = ''Y'' order by s.sort_order nulls last, s.name_ar'
,p_lov_columns=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000045)
,p_plug_name=>'جهة السداد والتأمين'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000046)
,p_name=>'P2_PAYER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000045)
,p_prompt=>'جهة السداد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:العميل;CUSTOMER,شركة التأمين;INSURANCE,الضمان;WARRANTY,داخلي;INTERNAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000047)
,p_name=>'P2_INSURER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000045)
,p_prompt=>'شركة التأمين'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from aut_insurer where company_id = noona_aut_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820280000000048)
,p_name=>'P2_CLAIM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000045)
,p_prompt=>'رقم المطالبة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820280000000049)
,p_name=>'P2_POLICY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000045)
,p_prompt=>'رقم الوثيقة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820280000000050)
,p_name=>'P2_ACCIDENT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000045)
,p_prompt=>'رقم تقرير الحادث (نجم / المرور)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820280000000051)
,p_name=>'P2_DEDUCT'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000045)
,p_prompt=>'تحمل العميل (فارغ = الافتراضي لشركة التأمين)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000052)
,p_plug_name=>'حفظ'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000053)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000052)
,p_button_name=>'OPEN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'فتح أمر الإصلاح'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000054)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P2_PAYER := nvl(:P2_PAYER, ''CUSTOMER'');',
'    :P2_PROMISED := nvl(:P2_PROMISED, to_char(sysdate + 3 / 24, ''YYYY-MM-DD HH24:MI''));',
'    if :P2_VEH is not null and :P2_PLATE is null then',
'        select noona_aut_pkg.plate_label(plate_no) into :P2_PLATE from aut_vehicle where id = :P2_VEH and company_id = noona_aut_pkg.company;',
'    end if;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000054
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000055)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Find'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare v aut_vehicle%rowtype;',
'begin',
'    :P2_VEH := noona_aut_pkg.vehicle_by_plate(:P2_PLATE);',
'    if :P2_VEH is null then',
'        apex_application.g_print_success_message := ''مركبة جديدة؛ أكمل بياناتها وستسجل مع الأمر'';',
'        return;',
'    end if;',
'    select * into v from aut_vehicle where id = :P2_VEH;',
'    :P2_PLATE := noona_aut_pkg.plate_label(v.plate_no); :P2_MAKE := v.make; :P2_MODEL := v.model; :P2_YEAR := v.model_year; :P2_COLOR := v.color; :P2_VIN := v.vin;',
'    :P2_OWNER := v.owner_name; :P2_PHONE := v.owner_phone; :P2_INSURER := v.insurer_id; :P2_POLICY := v.policy_no;',
'    apex_application.g_print_success_message := ''مركبة مسجلة: '' || noona_aut_pkg.vehicle_label(v.id)',
'        || case when v.odometer is not null then '' · آخر عداد '' || v.odometer end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000027)
,p_internal_uid=>91820280000000055
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000056)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Open'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_o  json_object_t := json_object_t();',
'    l_s  json_array_t := json_array_t();',
'    l_i  json_object_t;',
'begin',
'    if :P2_VEH is not null then l_o.put(''vehicle'', to_number(:P2_VEH)); else l_o.put(''plate'', :P2_PLATE); end if;',
'    l_o.put(''make'', :P2_MAKE); l_o.put(''model'', :P2_MODEL); l_o.put(''year'', to_number(:P2_YEAR)); l_o.put(''color'', :P2_COLOR);',
'    l_o.put(''vin'', :P2_VIN); l_o.put(''ownerName'', :P2_OWNER); l_o.put(''ownerPhone'', :P2_PHONE); l_o.put(''phone'', :P2_PHONE);',
'    l_o.put(''odometer'', to_number(:P2_ODO)); l_o.put(''fuel'', :P2_FUEL); l_o.put(''bay'', to_number(:P2_BAY));',
'    l_o.put(''promised'', :P2_PROMISED); l_o.put(''complaint'', :P2_COMPLAINT);',
'    l_o.put(''payer'', :P2_PAYER); l_o.put(''insurer'', to_number(:P2_INSURER)); l_o.put(''claim'', :P2_CLAIM); l_o.put(''policy'', :P2_POLICY);',
'    l_o.put(''accident'', :P2_ACCIDENT); l_o.put(''deductible'', to_number(:P2_DEDUCT));',
'    if :P2_INSPECT is not null then l_i := json_object_t(); l_i.put(''notes'', :P2_INSPECT); l_o.put(''inspection'', l_i); end if;',
'    for s in (select to_number(column_value) id from table(apex_string.split(:P2_SERVICES, '':'')) where column_value is not null) loop',
'        l_s.append(s.id);',
'    end loop;',
'    l_o.put(''services'', l_s);',
'    :P2_VEH := noona_aut_pkg.open_job(l_o.to_clob);   -- يعاد استخدام العنصر لرقم الأمر في التحويل',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000053)
,p_internal_uid=>91820280000000056
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000057)
,p_branch_action=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:&P2_VEH.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
,p_branch_when_button_id=>wwv_flow_imp.id(91820280000000053)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000058)
,p_branch_action=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>20
);

wwv_flow_imp.component_end;
end;
/
