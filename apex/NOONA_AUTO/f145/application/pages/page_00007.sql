prompt --application/pages/page_00007
begin
--   Manifest
--     PAGE: 00007
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
 p_id=>7
,p_name=>'Vehicle'
,p_alias=>'VEHICLE'
,p_step_title=>'بطاقة المركبة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''aut.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000132)
,p_plug_name=>'بيانات المركبة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000133)
,p_name=>'P7_ID'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000134)
,p_name=>'P7_PLATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000135)
,p_name=>'P7_PTYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'نوع اللوحة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:خصوصي;PRIVATE,نقل خاص;COMMERCIAL,أجرة;TAXI,نقل عام;TRANSPORT,دراجة نارية;MOTORCYCLE,مؤقتة;TEMPORARY,دبلوماسية;DIPLOMATIC,تصدير;EXPORT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000136)
,p_name=>'P7_MAKE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'الشركة المصنعة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>100
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000137)
,p_name=>'P7_MODEL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'الطراز'
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
 p_id=>wwv_flow_imp.id(91820280000000138)
,p_name=>'P7_YEAR'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'سنة الصنع'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000139)
,p_name=>'P7_COLOR'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'اللون'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820280000000140)
,p_name=>'P7_VIN'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'رقم الهيكل (VIN)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>22
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
 p_id=>wwv_flow_imp.id(91820280000000141)
,p_name=>'P7_ENGINE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'المحرك'
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
 p_id=>wwv_flow_imp.id(91820280000000142)
,p_name=>'P7_FUEL'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'الوقود'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بنزين;PETROL,ديزل;DIESEL,هجين;HYBRID,كهربائي;ELECTRIC,غاز;GAS'
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
 p_id=>wwv_flow_imp.id(91820280000000143)
,p_name=>'P7_TRANS'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'ناقل الحركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:أوتوماتيك;AUTOMATIC,عادي;MANUAL,CVT;CVT'
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
 p_id=>wwv_flow_imp.id(91820280000000144)
,p_name=>'P7_ODO'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820280000000132)
,p_prompt=>'العداد (كم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000145)
,p_plug_name=>'المالك والتأمين'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000146)
,p_name=>'P7_OWNER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
,p_prompt=>'اسم المالك'
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
 p_id=>wwv_flow_imp.id(91820280000000147)
,p_name=>'P7_PHONE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
,p_prompt=>'جوال المالك'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000148)
,p_name=>'P7_DRIVER'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
,p_prompt=>'السائق'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
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
 p_id=>wwv_flow_imp.id(91820280000000149)
,p_name=>'P7_DPHONE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
,p_prompt=>'جوال السائق'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000150)
,p_name=>'P7_INSURER'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
,p_prompt=>'شركة التأمين'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from aut_insurer where company_id = noona_aut_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820280000000151)
,p_name=>'P7_POLICY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
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
 p_id=>wwv_flow_imp.id(91820280000000152)
,p_name=>'P7_POLEXP'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
,p_prompt=>'انتهاء التأمين'
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
 p_id=>wwv_flow_imp.id(91820280000000153)
,p_name=>'P7_REGEXP'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
,p_prompt=>'انتهاء الاستمارة'
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
 p_id=>wwv_flow_imp.id(91820280000000154)
,p_name=>'P7_NOTES'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820280000000145)
,p_prompt=>'ملاحظات'
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000155)
,p_plug_name=>'حفظ'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000156)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000155)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000157)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820280000000155)
,p_button_name=>'JOB'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'فتح أمر إصلاح'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:RP,2:P2_VEH:&P7_ID.'
,p_button_condition=>':P7_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000158)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare v aut_vehicle%rowtype;',
'begin',
'    :P7_PTYPE := nvl(:P7_PTYPE, ''PRIVATE'');',
'    if :P7_ID is not null and :P7_PLATE is null then',
'        select * into v from aut_vehicle where id = :P7_ID and company_id = noona_aut_pkg.company;',
'        :P7_PLATE := noona_aut_pkg.plate_label(v.plate_no); :P7_PTYPE := v.plate_type; :P7_MAKE := v.make; :P7_MODEL := v.model; :P7_YEAR := v.model_year;',
'        :P7_COLOR := v.color; :P7_VIN := v.vin; :P7_ENGINE := v.engine; :P7_FUEL := v.fuel_type; :P7_TRANS := v.transmission;',
'        :P7_ODO := v.odometer; :P7_OWNER := v.owner_name; :P7_PHONE := v.owner_phone; :P7_DRIVER := v.driver_name;',
'        :P7_DPHONE := v.driver_phone; :P7_INSURER := v.insurer_id; :P7_POLICY := v.policy_no;',
'        :P7_POLEXP := to_char(v.policy_expiry, ''YYYY-MM-DD''); :P7_REGEXP := to_char(v.registration_expiry, ''YYYY-MM-DD''); :P7_NOTES := v.notes;',
'    end if;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000158
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000159)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_o json_object_t := json_object_t();',
'begin',
'    l_o.put(''id'', to_number(:P7_ID)); l_o.put(''plate'', :P7_PLATE); l_o.put(''plateType'', :P7_PTYPE); l_o.put(''make'', :P7_MAKE);',
'    l_o.put(''model'', :P7_MODEL); l_o.put(''year'', to_number(:P7_YEAR)); l_o.put(''color'', :P7_COLOR); l_o.put(''vin'', :P7_VIN);',
'    l_o.put(''engine'', :P7_ENGINE); l_o.put(''fuel'', :P7_FUEL); l_o.put(''trans'', :P7_TRANS); l_o.put(''odometer'', to_number(:P7_ODO));',
'    l_o.put(''ownerName'', :P7_OWNER); l_o.put(''ownerPhone'', :P7_PHONE); l_o.put(''driverName'', :P7_DRIVER); l_o.put(''driverPhone'', :P7_DPHONE);',
'    l_o.put(''insurer'', to_number(:P7_INSURER)); l_o.put(''policy'', :P7_POLICY); l_o.put(''policyExpiry'', :P7_POLEXP);',
'    l_o.put(''regExpiry'', :P7_REGEXP); l_o.put(''notes'', :P7_NOTES);',
'    :P7_ID := noona_aut_pkg.save_vehicle(l_o.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000156)
,p_process_success_message=>'تم حفظ المركبة'
,p_internal_uid=>91820280000000159
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000160)
,p_plug_name=>'سجل الزيارات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P7_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_aut_pkg.vehicle_html(:P7_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000161)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'AUT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c  clob;',
'    l_h  clob;',
'    l_id number;',
'    l_op varchar2(30) := apex_application.g_x01;',
'    function n(p varchar2) return number is begin return to_number(p); end;',
'    procedure out(p clob) is',
'        l_off pls_integer := 1;',
'    begin',
'        while l_off <= dbms_lob.getlength(p) loop',
'            htp.prn(dbms_lob.substr(p, 8000, l_off));',
'            l_off := l_off + 8000;',
'        end loop;',
'    end;',
'begin',
'    case l_op',
'        when ''JOB'' then l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''ADDSVC'' then l_id := noona_aut_pkg.add_service(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''ADDBND'' then l_id := noona_aut_pkg.add_bundle(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''ADDPART'' then l_id := noona_aut_pkg.add_part(n(apex_application.g_x02), n(apex_application.g_x03), n(apex_application.g_x04));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''ADDLINE'' then l_id := noona_aut_pkg.add_line(apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''UPDLINE'' then noona_aut_pkg.update_line(apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''DELLINE'' then noona_aut_pkg.remove_line(n(apex_application.g_x02));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x03));',
'        when ''LACT'' then noona_aut_pkg.line_action(n(apex_application.g_x02), apex_application.g_x03);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x04));',
'        when ''STATUS'' then noona_aut_pkg.set_job_status(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''UPDJOB'' then noona_aut_pkg.update_job(apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(json_value(apex_application.g_clob_01, ''$.id'' returning number));',
'        when ''CLAIM'' then noona_aut_pkg.set_claim(apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(json_value(apex_application.g_clob_01, ''$.job'' returning number));',
'        when ''INVOICE'' then l_id := noona_aut_pkg.invoice_job(n(apex_application.g_x02), apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''DELIVER'' then noona_aut_pkg.deliver_job(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''PARTS'' then l_c := ''{"list":'' || noona_aut_pkg.search_parts_json(apex_application.g_x02, n(apex_application.g_x03)) || ''}'';',
'        when ''APPT'' then noona_aut_pkg.set_appointment_status(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04);',
'        when ''CHECKIN'' then l_id := noona_aut_pkg.check_in(n(apex_application.g_x02), apex_application.g_clob_01);',
'            l_c := ''{"id":'' || l_id || ''}'';',
'        when ''PRINT'' then l_h := noona_aut_pkg.job_print(n(apex_application.g_x02));',
'            select json_object(''html'' value l_h returning clob) into l_c from dual;',
'        else raise_application_error(-20500, ''NOONA-AUT-099: عملية غير معروفة '' || l_op);',
'    end case;',
'    out(nvl(l_c, to_clob(''{"ok":true}'')));',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''err'', regexp_replace(nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm),',
'                                          ''\s*\[cid=[^]]+\]'', ''''));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000161
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000162)
,p_branch_action=>'f?p=&APP_ID.:7:&SESSION.::&DEBUG.::P7_ID:&P7_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
