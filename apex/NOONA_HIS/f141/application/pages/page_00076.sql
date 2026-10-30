prompt --application/pages/page_00076
begin
--   Manifest
--     PAGE: 00076
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
 p_id=>76
,p_name=>'Inpatient Chart'
,p_alias=>'INPATIENT-CHART'
,p_step_title=>'Inpatient chart - الملف الإلكتروني للمنوم'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(''#P76_DGIVEN,#P76_DNOTES,#P76_TVALUE,#P76_TNOTES,#P76_TDESC'').attr(''dir'', ''ltr'');'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001105)
,p_plug_name=>'المريض'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001106)
,p_name=>'P76_VISIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000001105)
,p_prompt=>'المريض المنوم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select b.bed_no || '' - '' || p.name_ar || '' ('' || p.mrn || '')'' d, v.id r from his_admission a join his_visit v on v.id = a.visit_id join his_patient p on p.id = v.patient_id join his_bed b on b.id = a.bed_id where a.company_id = noona_his_pkg.company and a.status_code = ''ADMITTED'' order by b.bed_no'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001107)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000001105)
,p_button_name=>'NURSING'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'العلامات الحيوية والملاحظات'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.:RP,35:P35_VISIT:&P76_VISIT.'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001108)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000001105)
,p_button_name=>'RX'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'وصفة جديدة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:33:&SESSION.::&DEBUG.:RP,33:P33_VISIT:&P76_VISIT.'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001109)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000001105)
,p_button_name=>'VISIT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'ملف الزيارة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:&P76_VISIT.'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001110)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820275000001105)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001111)
,p_plug_name=>'Record a dose - تسجيل جرعة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P76_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001112)
,p_name=>'P76_DOSE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000001111)
,p_prompt=>'الجرعة المستحقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select to_char(m.due_at, ''MM-DD HH24:MI'') || '' - '' || nvl(i.name_en, i.name_ar) || '' '' || m.dose || '' '' || m.route || case when m.due_at < systimestamp - interval ''30'' minute then '' (overdue)'' end d, m.id r from his_med_schedule m join his_prescription_line l on l.id = m.line_id join inv_item i on i.id = l.item_id where m.visit_id = :P76_VISIT and m.status_code = ''DUE'' and m.due_at <= systimestamp + interval ''2'' hour order by m.due_at'
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
 p_id=>wwv_flow_imp.id(91820275000001113)
,p_name=>'P76_OUTCOME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000001111)
,p_prompt=>'النتيجة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:أُعطيت;GIVEN,أُجّلت;HELD,رفضها المريض;REFUSED,فاتت;MISSED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001114)
,p_name=>'P76_DGIVEN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000001111)
,p_prompt=>'الجرعة المعطاة (إن اختلفت)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820275000001115)
,p_name=>'P76_NURSE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000001111)
,p_prompt=>'الممرض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || case title when ''NURSE'' then '''' else '' - '' || title end d, id r from his_doctor where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by case title when ''NURSE'' then 0 else 1 end, name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- المستخدم الحالي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001116)
,p_name=>'P76_DNOTES'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000001111)
,p_prompt=>'ملاحظات / سبب'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001117)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000001111)
,p_button_name=>'RECORD_DOSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'السجل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001118)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Dose'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_nurse_pkg.record_dose(:P76_DOSE, :P76_OUTCOME, to_number(:P76_NURSE), :P76_DNOTES, :P76_DGIVEN);',
'    :P76_DOSE := null; :P76_DNOTES := null; :P76_DGIVEN := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000001117)
,p_process_success_message=>'Dose recorded'
,p_internal_uid=>91820275000001118
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001119)
,p_plug_name=>'Care plan - خطة المتابعة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>6
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P76_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001120)
,p_name=>'P76_TASK'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_prompt=>'المهمة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_his_nurse_pkg.task_label(t.task_type) || nvl2(t.description, '': '' || t.description, '''') || '' (every '' || t.every_hours || ''h, next '' || to_char(t.next_due_at, ''HH24:MI'') || '')'' d, t.id r from his_care_task t where t.visit_id = :P76_VISIT and t.status_code = ''ACTIVE'' order by t.next_due_at'
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
 p_id=>wwv_flow_imp.id(91820275000001121)
,p_name=>'P76_TVALUE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_prompt=>'النتيجة (مثلاً 140 ملجم/دسل، مدخول 500 مل)'
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
 p_id=>wwv_flow_imp.id(91820275000001122)
,p_name=>'P76_TNOTES'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_prompt=>'ملاحظات'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001123)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_button_name=>'DONE_TASK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تم'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001124)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_button_name=>'STOP_TASK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إيقاف المهمة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001125)
,p_name=>'P76_TTYPE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_prompt=>'مهمة جديدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:العلامات الحيوية;VITALS,سكر الدم;BLOOD_SUGAR,تغيير الوضعية;TURNING,العناية بالجرح;WOUND_CARE,السوائل الداخلة والخارجة;INTAKE_OUTPUT,Doctor round;DOCTOR_ROUND,Observation;OBSERVATION,Other;OTHER'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'-'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001126)
,p_name=>'P76_TDESC'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_prompt=>'الوصف'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001127)
,p_name=>'P76_TEVERY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_prompt=>'كل (ساعات)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001128)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000001119)
,p_button_name=>'ADD_TASK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة مهمة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001129)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Task Done'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_nurse_pkg.complete_task(:P76_TASK, :P76_TVALUE, :P76_TNOTES, to_number(:P76_NURSE));',
'    :P76_TVALUE := null; :P76_TNOTES := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000001123)
,p_process_success_message=>'Task recorded'
,p_internal_uid=>91820275000001129
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001130)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Task Stop'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_nurse_pkg.stop_task(:P76_TASK);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000001124)
,p_process_success_message=>'Task stopped'
,p_internal_uid=>91820275000001130
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001131)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Task Add'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number; l_doc clob;',
'begin',
'    select json_object(''visit'' value to_number(:P76_VISIT), ''type'' value :P76_TTYPE, ''desc'' value :P76_TDESC, ''every'' value to_number(:P76_TEVERY)',
'           returning clob) into l_doc from dual;',
'    l := noona_his_nurse_pkg.add_task(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000001128)
,p_process_success_message=>'Task added'
,p_internal_uid=>91820275000001131
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001132)
,p_plug_name=>'المخطط'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P76_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_nurse_pkg.inpatient_chart_html(:P76_VISIT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000001133)
,p_branch_action=>'f?p=&APP_ID.:76:&SESSION.::&DEBUG.::P76_VISIT:&P76_VISIT.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
