prompt --application/pages/page_00051
begin
--   Manifest
--     PAGE: 00051
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
 p_id=>51
,p_name=>'Perform Order'
,p_alias=>'PERFORM'
,p_step_title=>'تنفيذ الطلب والنتيجة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(''#P51_RESULT, input[name=f01]'').attr(''dir'', ''ltr'');'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000277)
,p_plug_name=>'النتيجة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000278)
,p_name=>'P51_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820275000000277)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000279)
,p_plug_name=>'الطلب'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l varchar2(4000);',
'begin',
'    select ''<div class="nn-his-card"><div class="nn-his-head"><div><b>'' || apex_escape.html(noona_his_pkg.service_name(s.id)) || ''</b> <span class="nn-rst-chip">''',
'           || noona_his_pkg.order_status_label(o.status_code) || ''</span><br><small>'' || apex_escape.html(p.name_ar) || '' · '' || p.mrn || '' · ''',
'           || case p.gender when ''M'' then ''ذكر'' else ''أنثى'' end || '' · زيارة '' || v.visit_no || nvl2(o.sample_no, '' · عينة '' || o.sample_no, '''')',
'           || ''</small>'' || nvl2(s.normal_range, ''<br><small>Normal range: '' || apex_escape.html(s.normal_range) || ''</small>'', '''')',
'           || nvl2(p.allergies, ''<br><span class="nn-rst-chip is-cancelled">حساسية: '' || apex_escape.html(p.allergies) || ''</span>'', '''')',
'           || nvl2(o.notes, ''<br><small>Doctor notes: '' || apex_escape.html(o.notes) || ''</small>'', '''') || ''</div></div></div>''',
'      into l from his_order o join his_service s on s.id = o.service_id join his_visit v on v.id = o.visit_id join his_patient p on p.id = v.patient_id',
'     where o.id = :P51_ID and o.company_id = noona_his_pkg.company;',
'    return l;',
'exception when no_data_found then return null;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000280)
,p_name=>'P51_RESULT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000277)
,p_prompt=>'Result / Report (English)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>10
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000281)
,p_name=>'P51_FLAG'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000277)
,p_prompt=>'Assessment'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Normal;NORMAL,Abnormal;ABNORMAL,Critical;CRITICAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000282)
,p_name=>'P51_BY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000277)
,p_prompt=>'المنفذ/المعتمد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company and d.status_code = ''ACTIVE'' order by p.sort_order, p.name_ar, d.name_ar'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000283)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000277)
,p_button_name=>'SAMPLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'سحب العينة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000284)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000277)
,p_button_name=>'START'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'بدء التنفيذ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000285)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000000277)
,p_button_name=>'COMPLETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ النتيجة وإنجاز الطلب (يصرف مواد القسم)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000286)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820275000000277)
,p_button_name=>'REPORT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة التقرير'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:52:&SESSION.::&DEBUG.:RP,52:P52_ID:&P51_ID.'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000287)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select result_text, nvl(result_flag, ''NORMAL''), performed_by_id into :P51_RESULT, :P51_FLAG, :P51_BY',
'      from his_order where id = :P51_ID and company_id = noona_his_pkg.company;',
'    if :P51_RESULT is null then :P51_RESULT := noona_his_care_pkg.template_for(:P51_ID); end if;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000000287
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000288)
,p_plug_name=>'Laboratory results'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>8
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_care_pkg.has_params(:P51_ID) = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000289)
,p_plug_name=>'Parameters'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>7
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_care_pkg.has_params(:P51_ID) = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_care_pkg.lab_grid_html(:P51_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000290)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000288)
,p_button_name=>'LAB_SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Save values'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000291)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000288)
,p_button_name=>'LAB_DONE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Validate & release results'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000292)
,p_process_sequence=>25
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Lab Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    l := ''['';',
'    for i in 1 .. apex_application.g_f02.count loop',
'        l := l || case when i > 1 then '','' end || json_object(''p'' value to_number(apex_application.g_f02(i)),',
'             ''v'' value case when regexp_like(trim(apex_application.g_f01(i)), ''^-?[0-9]+([.][0-9]+)?$'') then to_number(trim(apex_application.g_f01(i)),',
'                  ''9999999999D9999'', ''NLS_NUMERIC_CHARACTERS=''''.,'''''') end,',
'             ''t'' value case when not regexp_like(trim(apex_application.g_f01(i)), ''^-?[0-9]+([.][0-9]+)?$'') then trim(apex_application.g_f01(i)) end);',
'    end loop;',
'    l := l || '']'';',
'    noona_his_care_pkg.save_lab_results(:P51_ID, l, ''N'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000290)
,p_process_success_message=>'Values saved'
,p_internal_uid=>91820275000000292
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000293)
,p_process_sequence=>26
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Lab Release'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    l := ''['';',
'    for i in 1 .. apex_application.g_f02.count loop',
'        l := l || case when i > 1 then '','' end || json_object(''p'' value to_number(apex_application.g_f02(i)),',
'             ''v'' value case when regexp_like(trim(apex_application.g_f01(i)), ''^-?[0-9]+([.][0-9]+)?$'') then to_number(trim(apex_application.g_f01(i)),',
'                  ''9999999999D9999'', ''NLS_NUMERIC_CHARACTERS=''''.,'''''') end,',
'             ''t'' value case when not regexp_like(trim(apex_application.g_f01(i)), ''^-?[0-9]+([.][0-9]+)?$'') then trim(apex_application.g_f01(i)) end);',
'    end loop;',
'    l := l || '']'';',
'    noona_his_care_pkg.save_lab_results(:P51_ID, l, ''Y'', to_number(:P51_BY), :P51_RESULT);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000291)
,p_process_success_message=>'Results released'
,p_internal_uid=>91820275000000293
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000294)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Sample'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l varchar2(30);',
'begin',
'    l := noona_his_pkg.collect_sample(:P51_ID);',
'    apex_application.g_print_success_message := ''رقم العينة '' || l;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000283)
,p_internal_uid=>91820275000000294
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000295)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Start'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.start_order(:P51_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000284)
,p_process_success_message=>'بدأ التنفيذ'
,p_internal_uid=>91820275000000295
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000296)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Complete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.complete_order(:P51_ID, :P51_RESULT, :P51_FLAG, to_number(:P51_BY));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000285)
,p_process_success_message=>'حفظت النتيجة وأنجز الطلب'
,p_internal_uid=>91820275000000296
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000297)
,p_branch_action=>'f?p=&APP_ID.:51:&SESSION.::&DEBUG.::P51_ID:&P51_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
