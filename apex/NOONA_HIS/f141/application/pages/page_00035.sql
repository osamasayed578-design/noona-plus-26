prompt --application/pages/page_00035
begin
--   Manifest
--     PAGE: 00035
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
 p_id=>35
,p_name=>'Nursing'
,p_alias=>'NURSING'
,p_step_title=>'Nursing chart - التمريض'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(''#P35_BP,#P35_VNOTES,#P35_NOTE,#P35_DOSE,#P35_MNOTES'').attr(''dir'', ''ltr'');'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000855)
,p_plug_name=>'Visit'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000856)
,p_name=>'P35_VISIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000855)
,p_prompt=>'الزيارة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select v.visit_no || '' - '' || p.name_ar || '' ('' || p.mrn || '')'' d, v.id r from his_visit v join his_patient p on p.id = v.patient_id where v.company_id = noona_his_pkg.company and v.status_code = ''OPEN'' and v.visit_at >= sysdate - 60 order by v.visit_at desc'
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
 p_id=>wwv_flow_imp.id(91820275000000857)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000855)
,p_button_name=>'VISIT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'ملف الزيارة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:&P35_VISIT.'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000858)
,p_plug_name=>'ملف الزيارة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>2
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_pkg.visit_html(:P35_VISIT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000859)
,p_plug_name=>'Triage (Emergency) - الفرز'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000860)
,p_name=>'P35_TRIAGE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000859)
,p_prompt=>'CTAS level'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:1 - Resuscitation;1,2 - Emergent;2,3 - Urgent;3,4 - Less urgent;4,5 - Non urgent;5'
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
 p_id=>wwv_flow_imp.id(91820275000000861)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000859)
,p_button_name=>'TRIAGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Save triage'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000862)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Triage'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_clin_pkg.set_triage(:P35_VISIT, :P35_TRIAGE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000861)
,p_process_success_message=>'Triage saved'
,p_internal_uid=>91820275000000862
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000863)
,p_plug_name=>'Vital signs - العلامات الحيوية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000864)
,p_name=>'P35_BP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'BP (e.g. 120/80)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>8
,p_cMaxlength=>10
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000865)
,p_name=>'P35_HR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'Pulse (bpm)'
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
 p_id=>wwv_flow_imp.id(91820275000000866)
,p_name=>'P35_TEMP'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'Temp (°C)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000867)
,p_name=>'P35_RR'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'Resp. rate'
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
 p_id=>wwv_flow_imp.id(91820275000000868)
,p_name=>'P35_SPO2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'SpO2 %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000869)
,p_name=>'P35_WT'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'Weight (kg)'
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
 p_id=>wwv_flow_imp.id(91820275000000870)
,p_name=>'P35_HT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'Height (cm)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000871)
,p_name=>'P35_PAIN'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'Pain (0-10)'
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
 p_id=>wwv_flow_imp.id(91820275000000872)
,p_name=>'P35_GLU'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'RBS (mg/dL)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000873)
,p_name=>'P35_VNOTES'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_prompt=>'Notes'
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
 p_id=>wwv_flow_imp.id(91820275000000874)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000863)
,p_button_name=>'SAVE_VITALS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save vital signs'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000875)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Vitals'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number; l_doc clob;',
'begin',
'    select json_object(''visit'' value to_number(:P35_VISIT), ''bp'' value :P35_BP, ''pulse'' value to_number(:P35_HR), ''temp'' value to_number(:P35_TEMP),',
'           ''rr'' value to_number(:P35_RR), ''spo2'' value to_number(:P35_SPO2), ''weight'' value to_number(:P35_WT), ''height'' value to_number(:P35_HT),',
'           ''pain'' value to_number(:P35_PAIN), ''glucose'' value to_number(:P35_GLU), ''notes'' value :P35_VNOTES returning clob) into l_doc from dual;',
'    l := noona_his_clin_pkg.record_vitals(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000874)
,p_process_success_message=>'Vital signs saved'
,p_internal_uid=>91820275000000875
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000876)
,p_plug_name=>'Vitals chart'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>12
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_clin_pkg.vitals_html(:P35_VISIT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000877)
,p_plug_name=>'Clinical notes - الملاحظات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000878)
,p_name=>'P35_NTYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000877)
,p_prompt=>'Type'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Nursing;NURSING,Progress;PROGRESS,Consultation;CONSULTATION,Procedure;PROCEDURE,Discharge;DISCHARGE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000879)
,p_name=>'P35_AUTHOR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000877)
,p_prompt=>'Author'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_doctor where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by case title when ''NURSE'' then 0 else 1 end, name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- current user -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000880)
,p_name=>'P35_NOTE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000877)
,p_prompt=>'Note (English)'
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
 p_id=>wwv_flow_imp.id(91820275000000881)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000877)
,p_button_name=>'ADD_NOTE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Add note'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000882)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Note'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_clin_pkg.add_note(:P35_VISIT, :P35_NTYPE, :P35_NOTE, to_number(:P35_AUTHOR));',
'    :P35_NOTE := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000881)
,p_process_success_message=>'Note added'
,p_internal_uid=>91820275000000882
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000883)
,p_plug_name=>'Notes'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>22
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_clin_pkg.notes_html(:P35_VISIT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000884)
,p_plug_name=>'Medication administration (MAR) - إعطاء الأدوية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000885)
,p_name=>'P35_LINE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000884)
,p_prompt=>'Medicine'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(i.name_en, i.name_ar) || '' - '' || l.dose || '' '' || l.frequency || '' ('' || x.rx_no || '')'' d, l.id r from his_prescription x join his_prescription_line l on l.prescription_id = x.id join inv_item i on i.id = l.item_id where x.visit_id = :P35_VISIT and x.status_code not in (''CANCELLED'', ''EXPIRED'') order by x.rx_at, l.line_no'
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
 p_id=>wwv_flow_imp.id(91820275000000886)
,p_name=>'P35_OUTCOME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000884)
,p_prompt=>'Outcome'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Given;GIVEN,Held;HELD,Refused;REFUSED,Missed;MISSED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000887)
,p_name=>'P35_ROUTE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000884)
,p_prompt=>'Route'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Oral;ORAL,IV;IV,IM;IM,SC;SC,Inhaled;INHALED,Topical;TOPICAL,Rectal;RECTAL,Other;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000888)
,p_name=>'P35_DOSE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000884)
,p_prompt=>'Dose given'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820275000000889)
,p_name=>'P35_NURSE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000884)
,p_prompt=>'Nurse'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_doctor where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by case title when ''NURSE'' then 0 else 1 end, name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- current user -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000890)
,p_name=>'P35_MNOTES'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000884)
,p_prompt=>'Notes / reason'
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
 p_id=>wwv_flow_imp.id(91820275000000891)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000884)
,p_button_name=>'GIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Record administration'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000892)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'MAR'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number; l_doc clob;',
'begin',
'    select json_object(''line'' value to_number(:P35_LINE), ''outcome'' value :P35_OUTCOME, ''route'' value :P35_ROUTE, ''dose'' value :P35_DOSE,',
'           ''nurse'' value to_number(:P35_NURSE), ''notes'' value :P35_MNOTES returning clob) into l_doc from dual;',
'    l := noona_his_clin_pkg.give_medication(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000891)
,p_process_success_message=>'Administration recorded'
,p_internal_uid=>91820275000000892
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000893)
,p_plug_name=>'MAR'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>32
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P35_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_clin_pkg.mar_html(:P35_VISIT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000894)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select triage_level into :P35_TRIAGE from his_visit where id = :P35_VISIT and company_id = noona_his_pkg.company;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000000894
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000895)
,p_branch_action=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.::P35_VISIT:&P35_VISIT.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
