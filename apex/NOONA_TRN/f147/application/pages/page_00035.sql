prompt --application/pages/page_00035
begin
--   Manifest
--     PAGE: 00035
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
 p_id=>35
,p_name=>'Maintenance Order'
,p_alias=>'MAINT-ORDER'
,p_step_title=>'أمر صيانة عربة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000308)
,p_plug_name=>'فتح أمر صيانة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">تدخل العربة «في الصيانة» ولا تسند لرحلة حتى إقفال الأمر. اختر البرنامج الدوري للصيانة الوقائية، أو البلاغ إذا كانت الصيانة لعطل مسجل.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_ID is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000309)
,p_name=>'P35_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000310)
,p_name=>'P35_VEH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_prompt=>'العربة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select v.plate_no || '' · '' || noona_trn_pkg.status_label(v.status_code) || '' · '' || v.odometer_km || '' كم'' d, v.id r from trn_vehicle v where v.company_id = noona_trn_pkg.company and v.status_code <> ''SOLD'' order by v.plate_no'
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
 p_id=>wwv_flow_imp.id(91820290000000311)
,p_name=>'P35_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:وقائية دورية;PREVENTIVE,إصلاح عطل;CORRECTIVE,عمرة;OVERHAUL,فحص;INSPECTION,إصلاح حادث;ACCIDENT,إطارات;TIRES,تطوير وتحسين;UPGRADE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000312)
,p_name=>'P35_PLAN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_prompt=>'البرنامج الدوري'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select service_name || nvl2(every_km, '' · كل '' || every_km || '' كم'', '''') || nvl2(every_days, '' · كل '' || every_days || '' يوم'', '''') d, id r from trn_maint_plan where company_id = noona_trn_pkg.company and status_code = ''ACTIVE'' order by service_name'
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
 p_id=>wwv_flow_imp.id(91820290000000313)
,p_name=>'P35_INC'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_prompt=>'البلاغ / العطل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select i.doc_no || '' · '' || v.plate_no || '' · '' || substr(i.description, 1, 60) d, i.id r from trn_incident i join trn_vehicle v on v.id = i.vehicle_id where i.company_id = noona_trn_pkg.company and i.status_code <> ''CLOSED'' order by i.id desc'
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
 p_id=>wwv_flow_imp.id(91820290000000314)
,p_name=>'P35_WS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_prompt=>'الورشة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:ورشة داخلية;INTERNAL,ورشة خارجية;EXTERNAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000315)
,p_name=>'P35_VENDOR'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_prompt=>'الورشة الخارجية / المورد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, p.id r from pty_party p where exists (select 1 from ap_supplier s where s.party_id = p.id) order by 1'
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
 p_id=>wwv_flow_imp.id(91820290000000316)
,p_name=>'P35_ODO'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_prompt=>'العداد عند الدخول (كم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000317)
,p_name=>'P35_DESC'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_prompt=>'وصف العمل (يؤخذ من البرنامج أو البلاغ إن ترك فارغاً)'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000319)
,p_validation_name=>'P35_VEH required (OPEN)'
,p_validation_sequence=>10
,p_validation=>'P35_VEH'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000318)
,p_associated_item=>wwv_flow_imp.id(91820290000000310)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000318)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000308)
,p_button_name=>'OPEN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'فتح الأمر وإدخال العربة الصيانة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000320)
,p_process_sequence=>4
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P35_TYPE is null then :P35_TYPE := ''CORRECTIVE''; end if;',
'  if :P35_WS is null then :P35_WS := ''INTERNAL''; end if;',
'  if :P35_ID is null and :P35_INC is not null and :P35_VEH is null then',
'    select max(vehicle_id) into :P35_VEH from trn_incident where id = :P35_INC and company_id = noona_trn_pkg.company;',
'  end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000320
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000321)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Open'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'  select json_object(''vehicle'' value to_number(:P35_VEH), ''type'' value :P35_TYPE, ''plan'' value to_number(:P35_PLAN),',
'         ''incident'' value to_number(:P35_INC), ''workshop'' value :P35_WS, ''vendor'' value to_number(:P35_VENDOR),',
'         ''odometer'' value to_number(:P35_ODO), ''description'' value :P35_DESC absent on null) into l from dual;',
'  :P35_ID := noona_trn_pkg.open_maint(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000318)
,p_process_success_message=>'فتح الأمر؛ أضف قطع الغيار والعمالة ثم أقفله'
,p_internal_uid=>91820290000000321
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000322)
,p_plug_name=>'أمر الصيانة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_trn_pkg.maint_order_html(:P35_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000323)
,p_plug_name=>'إضافة بند'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.maint_order_status(:P35_ID) in (''OPEN'',''IN_PROGRESS'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000324)
,p_name=>'P35_LTYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000323)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:قطع غيار;PART,عمالة;LABOR,زيوت وفلاتر;OIL,إطارات;TIRE,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000325)
,p_name=>'P35_LDESC'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000323)
,p_prompt=>'البيان'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000326)
,p_name=>'P35_LQTY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000323)
,p_prompt=>'الكمية'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000327)
,p_name=>'P35_LCOST'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000323)
,p_prompt=>'تكلفة الوحدة'
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
 p_id=>wwv_flow_imp.id(91820290000000328)
,p_name=>'P35_LDEL'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000323)
,p_prompt=>'حذف البند رقم'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000329)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000323)
,p_button_name=>'ADD_LINE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة البند'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000330)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000323)
,p_button_name=>'DEL_LINE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف البند'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000331)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add line'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare x number; begin',
'  x := noona_trn_pkg.add_maint_line(:P35_ID, :P35_LTYPE, :P35_LDESC, nvl(to_number(:P35_LQTY), 1), to_number(:P35_LCOST));',
'  :P35_LDESC := null; :P35_LQTY := null; :P35_LCOST := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000329)
,p_process_success_message=>'أضيف البند'
,p_internal_uid=>91820290000000331
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000332)
,p_process_sequence=>21
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delete line'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.remove_maint_line(to_number(:P35_LDEL)); :P35_LDEL := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000330)
,p_process_success_message=>'حذف البند'
,p_internal_uid=>91820290000000332
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000333)
,p_plug_name=>'إقفال الأمر والترحيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint"><b>مصروف صيانة</b> للإصلاح والصيانة الدورية (يرحل على حساب الصيانة والإصلاح). <b>رأسمالية</b> للعمرة أو التجديد أو التطوير الذي يطيل عمر العربة أو يرفع كفاءتها: تضاف لتكلفة أصل العربة وتهلك على عمرها، ويمكن تمديد العمر الإنتاجي بالأشهر.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.maint_order_status(:P35_ID) in (''OPEN'',''IN_PROGRESS'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000334)
,p_name=>'P35_ODO_OUT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'العداد عند الخروج (كم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000335)
,p_name=>'P35_DOWN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'مدة التوقف (ساعة) - تحسب تلقائياً إن تركت'
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
 p_id=>wwv_flow_imp.id(91820290000000336)
,p_name=>'P35_TREAT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'المعالجة المحاسبية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مصروف صيانة;EXPENSE,رأسمالية تضاف لأصل العربة;CAPITALIZE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000337)
,p_name=>'P35_EXT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'تمديد العمر الإنتاجي (شهر) - للرأسمالية'
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
 p_id=>wwv_flow_imp.id(91820290000000338)
,p_name=>'P35_VAT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'ضريبة القيمة المضافة'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000339)
,p_name=>'P35_FUND'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'السداد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:آجل على الورشة (المورد);PAYABLE,تحويل بنكي;BANK,نقداً من الصندوق;CASH'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000340)
,p_name=>'P35_BANK'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_bank_account where company_id = noona_trn_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820290000000341)
,p_name=>'P35_BOX'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'الصندوق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_cash_box where company_id = noona_trn_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820290000000342)
,p_name=>'P35_REF'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'مرجع فاتورة الورشة'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000343)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_button_name=>'COMPLETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إقفال الأمر وترحيل التكلفة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000344)
,p_name=>'P35_REASON'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_prompt=>'سبب الإلغاء'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>400
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
 p_id=>wwv_flow_imp.id(91820290000000345)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000333)
,p_button_name=>'CANCEL_ORDER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الأمر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000346)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P35_TREAT is null then :P35_TREAT := ''EXPENSE''; end if;',
'  if :P35_FUND is null then',
'    select case max(workshop) when ''EXTERNAL'' then ''PAYABLE'' else ''CASH'' end into :P35_FUND from trn_maint_order where id = :P35_ID;',
'  end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000346
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000347)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Complete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'  select json_object(''odometer'' value to_number(:P35_ODO_OUT), ''downtimeHours'' value to_number(:P35_DOWN), ''treatment'' value :P35_TREAT,',
'         ''lifeExtension'' value to_number(:P35_EXT), ''vat'' value to_number(:P35_VAT), ''funding'' value :P35_FUND,',
'         ''bankAccount'' value to_number(:P35_BANK), ''cashBox'' value to_number(:P35_BOX), ''reference'' value :P35_REF absent on null) into l from dual;',
'  noona_trn_pkg.complete_maint(:P35_ID, l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000343)
,p_process_success_message=>'أقفل الأمر ورحلت التكلفة؛ عادت العربة متاحة'
,p_internal_uid=>91820290000000347
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000348)
,p_process_sequence=>31
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.cancel_maint(:P35_ID, :P35_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000345)
,p_process_success_message=>'ألغي الأمر'
,p_internal_uid=>91820290000000348
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000349)
,p_plug_name=>'رجوع'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000350)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000349)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'صيانة الأسطول'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:34:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000351)
,p_branch_action=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.::P35_ID:&P35_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
