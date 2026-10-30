prompt --application/pages/page_00056
begin
--   Manifest
--     PAGE: 00056
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>141
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>56
,p_name=>'Inpatient'
,p_alias=>'INPATIENT'
,p_step_title=>'التنويم ولوحة الأسرة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(''#P56_REASON,#P56_SUMMARY'').attr(''dir'', ''ltr'');',
'document.addEventListener(''click'', function (e) {',
'  var b = e.target.closest(''[data-visit]''); if (!b || !b.dataset.visit) return;',
'  location.href = ''f?p='' + apex.env.APP_ID + '':76:'' + apex.env.APP_SESSION + ''::NO:RP,76:P76_VISIT:'' + b.dataset.visit;',
'});'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000615)
,p_plug_name=>'الأسرة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_care_pkg.bed_board_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000616)
,p_plug_name=>'دخول مريض'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000617)
,p_name=>'P56_PATIENT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000616)
,p_prompt=>'المريض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' - '' || mrn || nvl2(mobile, '' - '' || mobile, '''') d, id r from his_patient where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000618)
,p_name=>'P56_BED'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000616)
,p_prompt=>'السرير المتاح'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || b.bed_no || nvl2(b.room_no, '' ('' || b.room_no || '')'', '''') d, b.id r from his_bed b join his_department d on d.id = b.ward_id where b.company_id = noona_his_pkg.company and b.status_code = ''AVAILABLE'' order by d.name_ar, b.bed_no'
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
 p_id=>wwv_flow_imp.id(91820275000000619)
,p_name=>'P56_DOCTOR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000616)
,p_prompt=>'الطبيب المعالج'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company and d.status_code = ''ACTIVE'' order by p.sort_order, p.name_ar, d.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000620)
,p_name=>'P56_BILL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000616)
,p_prompt=>'الدفع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:حسب ملف المريض;,نقدي;CASH,على التأمين/الجهة;PAYER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000621)
,p_name=>'P56_APPROVAL'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000616)
,p_prompt=>'رقم موافقة التنويم'
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
 p_id=>wwv_flow_imp.id(91820275000000622)
,p_name=>'P56_REASON'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000616)
,p_prompt=>'سبب التنويم (بالإنجليزية)'
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
 p_id=>wwv_flow_imp.id(91820275000000623)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000616)
,p_button_name=>'ADMIT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'دخول'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000624)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000616)
,p_button_name=>'CHARGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'ترحيل أيام السرير حتى اليوم'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000625)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Admit'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number; l_doc clob;',
'begin',
'    select json_object(''patient'' value to_number(:P56_PATIENT), ''bed'' value to_number(:P56_BED), ''doctor'' value to_number(:P56_DOCTOR),',
'           ''bill_to'' value :P56_BILL, ''approval'' value :P56_APPROVAL, ''reason'' value :P56_REASON returning clob) into l_doc from dual;',
'    l := noona_his_care_pkg.admit(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000623)
,p_process_success_message=>'تم الدخول'
,p_internal_uid=>91820275000000625
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000626)
,p_process_sequence=>15
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Charge'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_care_pkg.charge_beds;',
'    apex_application.g_print_success_message := ''رحلت '' || l || '' يوم سرير'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000624)
,p_internal_uid=>91820275000000626
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000627)
,p_plug_name=>'نقل أو خروج'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000628)
,p_name=>'P56_ADM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000627)
,p_prompt=>'المريض المنوم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.admission_no || '' - '' || p.name_ar || '' - '' || b.bed_no d, a.id r from his_admission a join his_visit v on v.id = a.visit_id join his_patient p on p.id = v.patient_id left join his_bed b on b.id = a.bed_id where a.company_id = noona_his_pkg.company and a.status_code = ''ADMITTED'' order by b.bed_no'
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
 p_id=>wwv_flow_imp.id(91820275000000629)
,p_name=>'P56_NEWBED'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000627)
,p_prompt=>'النقل إلى سرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || b.bed_no || nvl2(b.room_no, '' ('' || b.room_no || '')'', '''') d, b.id r from his_bed b join his_department d on d.id = b.ward_id where b.company_id = noona_his_pkg.company and b.status_code = ''AVAILABLE'' order by d.name_ar, b.bed_no'
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
 p_id=>wwv_flow_imp.id(91820275000000630)
,p_name=>'P56_DTYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000627)
,p_prompt=>'نوع الخروج'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إلى المنزل;HOME,تحويل لمستشفى آخر;TRANSFER,على مسؤوليته;AGAINST_ADVICE,وفاة;DECEASED'
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
 p_id=>wwv_flow_imp.id(91820275000000631)
,p_name=>'P56_SUMMARY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000627)
,p_prompt=>'ملخص الخروج / سبب التحويل (بالإنجليزية)'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000632)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000627)
,p_button_name=>'TRANSFER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'نقل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000633)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000627)
,p_button_name=>'DISCHARGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'خروج'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000634)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Transfer'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_care_pkg.transfer_bed(:P56_ADM, to_number(:P56_NEWBED), :P56_SUMMARY);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000632)
,p_process_success_message=>'تم النقل'
,p_internal_uid=>91820275000000634
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000635)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Discharge'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_care_pkg.discharge(:P56_ADM, :P56_DTYPE, :P56_SUMMARY);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000633)
,p_process_success_message=>'تم الخروج؛ أكمل المحاسبة من ملف الزيارة'
,p_internal_uid=>91820275000000635
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000636)
,p_plug_name=>'الأسرة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000637)
,p_name=>'P56_SBED'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000636)
,p_prompt=>'السرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || b.bed_no d, b.id r from his_bed b join his_department d on d.id = b.ward_id where b.company_id = noona_his_pkg.company order by d.name_ar, b.bed_no'
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
 p_id=>wwv_flow_imp.id(91820275000000638)
,p_name=>'P56_SSTATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000636)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:متاح;AVAILABLE,تحت التنظيف;CLEANING,موقوف;BLOCKED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000639)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000636)
,p_button_name=>'SET_BED'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير حالة السرير'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000640)
,p_name=>'P56_WARD'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000636)
,p_prompt=>'الجناح (لسرير جديد)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_department where company_id = noona_his_pkg.company and dept_type = ''INPATIENT_WARD'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000641)
,p_name=>'P56_BEDNO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000636)
,p_prompt=>'رقم السرير'
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
 p_id=>wwv_flow_imp.id(91820275000000642)
,p_name=>'P56_ROOM'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000636)
,p_prompt=>'الغرفة'
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
 p_id=>wwv_flow_imp.id(91820275000000643)
,p_name=>'P56_CLASS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000636)
,p_prompt=>'الفئة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عام;WARD,شبه خاص;SEMI_PRIVATE,خاص;PRIVATE,جناح;SUITE,عناية مركزة;ICU,حضانة;NICU,عزل;ISOLATION'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000644)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000636)
,p_button_name=>'ADD_BED'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة سرير'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000645)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Bed Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_care_pkg.set_bed_status(:P56_SBED, :P56_SSTATUS);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000639)
,p_process_success_message=>'تغيرت حالة السرير'
,p_internal_uid=>91820275000000645
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000646)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Bed'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_care_pkg.save_bed(null, to_number(:P56_WARD), :P56_BEDNO, :P56_ROOM, :P56_CLASS);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000644)
,p_process_success_message=>'أضيف السرير'
,p_internal_uid=>91820275000000646
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000647)
,p_branch_action=>'f?p=&APP_ID.:56:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
