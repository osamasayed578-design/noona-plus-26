prompt --application/pages/page_00081
begin
--   Manifest
--     PAGE: 00081
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
 p_id=>81
,p_name=>'Field Earning'
,p_alias=>'FIELD-EARNING'
,p_step_title=>'مستحق عامل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000361)
,p_plug_name=>'المستحق'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000362)
,p_name=>'P81_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000363)
,p_plug_name=>'البيانات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P81_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for e in (select * from pay_field_earning where id = :P81_ID and company_id = noona_hr_pkg.company) loop',
'    return ''<p><b>'' || apex_escape.html(noona_wrk_pkg.employee_name(e.employee_id)) || ''</b> · '' || noona_wrk_pkg.type_label(e.earning_type)',
'        || '' · '' || to_char(e.period_month, ''YYYY-MM'') || '' · <b>'' || to_char(e.amount, ''FM999G999G990D00'') || ''</b> · ''',
'        || noona_wrk_pkg.method_label(e.pay_method) || '' '' || noona_wrk_pkg.badge(e.status_code) || ''</p><p class="nn-hint">'' || apex_escape.html(e.source_ref) || ''</p>'';',
'  end loop;',
'  return null;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000364)
,p_name=>'P81_EMP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000361)
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
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000365)
,p_name=>'P81_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مكافأة;BONUS,عمولة مبيعات;SALES_COMMISSION,عمولة خدمات;SERVICE_COMMISSION,بدل رحلات;TRIP_ALLOWANCE,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000366)
,p_name=>'P81_AMOUNT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_prompt=>'المبلغ'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000367)
,p_name=>'P81_METHOD'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_prompt=>'طريقة الصرف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مع الراتب;PAYROLL,نقداً;CASH,تحويل بنكي;BANK_TRANSFER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000368)
,p_name=>'P81_REF'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_prompt=>'البيان'
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
 p_id=>wwv_flow_imp.id(91820272000000369)
,p_name=>'P81_REASON'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_prompt=>'سبب الإلغاء'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000371)
,p_validation_name=>'P81_EMP required (SAVE)'
,p_validation_sequence=>9
,p_validation=>'P81_EMP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000370)
,p_associated_item=>wwv_flow_imp.id(91820272000000364)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000372)
,p_validation_name=>'P81_AMOUNT required (SAVE)'
,p_validation_sequence=>10
,p_validation=>'P81_AMOUNT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000370)
,p_associated_item=>wwv_flow_imp.id(91820272000000366)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000370)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة المستحق'
,p_button_position=>'NEXT'
,p_button_condition=>':P81_ID is null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000374)
,p_validation_name=>'P81_EMP required (SET_METHOD)'
,p_validation_sequence=>12
,p_validation=>'P81_EMP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000373)
,p_associated_item=>wwv_flow_imp.id(91820272000000364)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000375)
,p_validation_name=>'P81_AMOUNT required (SET_METHOD)'
,p_validation_sequence=>13
,p_validation=>'P81_AMOUNT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000373)
,p_associated_item=>wwv_flow_imp.id(91820272000000366)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000373)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_button_name=>'SET_METHOD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير طريقة الصرف'
,p_button_position=>'NEXT'
,p_button_condition=>':P81_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000377)
,p_validation_name=>'P81_EMP required (APPROVE)'
,p_validation_sequence=>15
,p_validation=>'P81_EMP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000376)
,p_associated_item=>wwv_flow_imp.id(91820272000000364)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000378)
,p_validation_name=>'P81_AMOUNT required (APPROVE)'
,p_validation_sequence=>16
,p_validation=>'P81_AMOUNT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000376)
,p_associated_item=>wwv_flow_imp.id(91820272000000366)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000376)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_button_name=>'APPROVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'اعتماد'
,p_button_position=>'NEXT'
,p_button_condition=>':P81_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000380)
,p_validation_name=>'P81_EMP required (CANCEL_EARNING)'
,p_validation_sequence=>18
,p_validation=>'P81_EMP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000379)
,p_associated_item=>wwv_flow_imp.id(91820272000000364)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000381)
,p_validation_name=>'P81_AMOUNT required (CANCEL_EARNING)'
,p_validation_sequence=>19
,p_validation=>'P81_AMOUNT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000379)
,p_associated_item=>wwv_flow_imp.id(91820272000000366)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000379)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820272000000361)
,p_button_name=>'CANCEL_EARNING'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء'
,p_button_position=>'NEXT'
,p_button_condition=>':P81_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000382)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t();',
'begin',
'  l.put(''employee'', to_number(:P81_EMP)); l.put(''type'', :P81_TYPE); l.put(''amount'', to_number(:P81_AMOUNT));',
'  l.put(''month'', to_char(sysdate, ''YYYY-MM'') || ''-01''); l.put(''method'', :P81_METHOD); l.put(''ref'', :P81_REF);',
'  :P81_ID := noona_wrk_pkg.add_manual(l.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000370)
,p_process_success_message=>'تمت إضافة المستحق؛ يعتمد ويصرف من شاشة المستحقات'
,p_internal_uid=>91820272000000382
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000383)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Method'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_wrk_pkg.set_method(:P81_ID, :P81_METHOD);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000373)
,p_process_success_message=>'تم تغيير طريقة الصرف'
,p_internal_uid=>91820272000000383
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000384)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_wrk_pkg.approve(:P81_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000376)
,p_process_success_message=>'تم الاعتماد'
,p_internal_uid=>91820272000000384
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000385)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_wrk_pkg.cancel(:P81_ID, :P81_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000379)
,p_process_success_message=>'تم الإلغاء'
,p_internal_uid=>91820272000000385
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000386)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for e in (select * from pay_field_earning where id = :P81_ID and company_id = noona_hr_pkg.company) loop',
'    :P81_EMP := e.employee_id; :P81_TYPE := e.earning_type; :P81_AMOUNT := e.amount; :P81_METHOD := e.pay_method; :P81_REF := e.source_ref;',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820272000000386
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000387)
,p_branch_action=>'f?p=&APP_ID.:80:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
