prompt --application/pages/page_00021
begin
--   Manifest
--     PAGE: 00021
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>137
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>21
,p_name=>'Leave Request'
,p_alias=>'LEAVE-REQUEST'
,p_step_title=>'طلب إجازة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000148)
,p_plug_name=>'طلب إجازة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الإجازة السنوية 21 يوماً (30 بعد خمس سنوات خدمة) تستحق يومياً؛ الاستئذان بالساعات في يوم واحد. الإجازة غير المدفوعة تخصم من الراتب.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000149)
,p_name=>'P21_EMP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_prompt=>'الموظف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.employee_no || '' - '' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_hr_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'', ''SUSPENDED'')) order by e.employee_no'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000150)
,p_name=>'P21_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_prompt=>'نوع الإجازة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select max(name_ar) keep (dense_rank first order by case when tenant_id is null then 1 else 0 end) d, code r from hr_leave_type where is_active = ''Y'' group by code order by min(id)'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000151)
,p_name=>'P21_FROM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_prompt=>'من تاريخ'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609122147107268652
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
 p_id=>wwv_flow_imp.id(91820272000000152)
,p_name=>'P21_TO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_prompt=>'إلى تاريخ'
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
 p_id=>wwv_flow_imp.id(91820272000000153)
,p_name=>'P21_T1'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_prompt=>'من الساعة (للاستئذان) HH:MI'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>6
,p_cMaxlength=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000154)
,p_name=>'P21_T2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_prompt=>'إلى الساعة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>6
,p_cMaxlength=>5
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
 p_id=>wwv_flow_imp.id(91820272000000155)
,p_name=>'P21_SUB'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_prompt=>'البديل أثناء الإجازة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.employee_no || '' - '' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_hr_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'', ''SUSPENDED'')) order by e.employee_no'
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
 p_id=>wwv_flow_imp.id(91820272000000156)
,p_name=>'P21_REASON'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_prompt=>'السبب / الملاحظات'
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
 p_id=>wwv_flow_imp.id(91820272000000157)
,p_plug_name=>'الرصيد المتاح'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P21_EMP is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    return ''<div class="nn-hr-bal">الرصيد المتاح: <b>'' || nvl(noona_hr_pkg.fnum(noona_hr_pkg.leave_available(:P21_EMP, nvl(:P21_TYPE, ''ANNUAL'')), 1), ''بلا حد سنوي'')',
'        || ''</b></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000159)
,p_validation_name=>'P21_EMP required (SUBMIT_LEAVE)'
,p_validation_sequence=>10
,p_validation=>'P21_EMP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000158)
,p_associated_item=>wwv_flow_imp.id(91820272000000149)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000160)
,p_validation_name=>'P21_FROM required (SUBMIT_LEAVE)'
,p_validation_sequence=>11
,p_validation=>'P21_FROM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000158)
,p_associated_item=>wwv_flow_imp.id(91820272000000151)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000158)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000148)
,p_button_name=>'SUBMIT_LEAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال للاعتماد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000161)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Request'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number; l_doc clob;',
'begin',
'    select json_object(''employee'' value to_number(:P21_EMP), ''type'' value nvl(:P21_TYPE, ''ANNUAL''), ''start'' value :P21_FROM,',
'                       ''end'' value nvl(:P21_TO, :P21_FROM), ''start_time'' value :P21_T1, ''end_time'' value :P21_T2,',
'                       ''substitute'' value to_number(:P21_SUB), ''reason'' value :P21_REASON returning clob) into l_doc from dual;',
'    l_id := noona_hr_pkg.request_leave(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000158)
,p_process_success_message=>'تم إرسال طلب الإجازة للاعتماد'
,p_internal_uid=>91820272000000161
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000162)
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
,p_branch_when_button_id=>wwv_flow_imp.id(91820272000000158)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000163)
,p_branch_action=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.::P21_EMP,P21_TYPE,P21_FROM,P21_TO:&P21_EMP.,&P21_TYPE.,&P21_FROM.,&P21_TO.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>20
);

wwv_flow_imp.component_end;
end;
/
