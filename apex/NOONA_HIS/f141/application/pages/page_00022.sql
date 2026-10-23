prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
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
 p_id=>22
,p_name=>'Appointment'
,p_alias=>'APPOINTMENT'
,p_step_title=>'الموعد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000114)
,p_plug_name=>'الموعد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000115)
,p_name=>'P22_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820275000000114)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000116)
,p_name=>'P22_VISIT'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820275000000114)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000117)
,p_plug_name=>'تفاصيل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l varchar2(4000);',
'begin',
'    select ''<div class="nn-his-card"><div class="nn-his-head"><div><b>'' || apex_escape.html(p.name_ar) || ''</b> <span class="nn-rst-chip">'' || p.mrn',
'           || ''</span><br><small>'' || to_char(a.appt_date, ''YYYY-MM-DD'') || '' '' || a.start_time || '' · '' || apex_escape.html(nvl(d.name_ar, dp.name_ar))',
'           || '' · '' || noona_his_pkg.appt_status_label(a.status_code) || '' · '' || a.appt_no || ''</small></div></div></div>''',
'      into l from his_appointment a join his_patient p on p.id = a.patient_id left join his_doctor d on d.id = a.doctor_id',
'      join his_department dp on dp.id = a.department_id where a.id = :P22_ID;',
'    return l;',
'exception when no_data_found then return null;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000118)
,p_name=>'P22_REASON'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000114)
,p_prompt=>'سبب الإلغاء'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000119)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000114)
,p_button_name=>'ARRIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'وصول المريض وفتح الزيارة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000120)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000114)
,p_button_name=>'CANCEL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الموعد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000121)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000000114)
,p_button_name=>'NOSHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'لم يحضر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000122)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Arrive'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P22_VISIT := noona_his_pkg.arrive(:P22_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000119)
,p_process_success_message=>'فتحت الزيارة'
,p_internal_uid=>91820275000000122
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000123)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.cancel_appointment(:P22_ID, :P22_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000120)
,p_process_success_message=>'ألغي الموعد'
,p_internal_uid=>91820275000000123
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000124)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'No Show'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.mark_no_show(:P22_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000121)
,p_process_success_message=>'سجل عدم الحضور'
,p_internal_uid=>91820275000000124
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000125)
,p_branch_action=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.::P31_ID:&P22_VISIT.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820275000000119)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000126)
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
