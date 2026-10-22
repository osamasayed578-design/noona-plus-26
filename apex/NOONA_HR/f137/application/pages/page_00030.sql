prompt --application/pages/page_00030
begin
--   Manifest
--     PAGE: 00030
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
 p_id=>30
,p_name=>'Loans'
,p_alias=>'LOANS'
,p_step_title=>'السلف والقروض'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000197)
,p_plug_name=>'سلفة / قرض جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">القسط لا يتجاوز نصف الأجر الشهري؛ يخصم آلياً من رواتب الفترات المجدولة، والرصيد كاملاً من مخالصة نهاية الخدمة.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000198)
,p_name=>'P30_EMP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000197)
,p_prompt=>'الموظف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_hr_pkg.employment_label(m.id) d, m.id r from hr_employment m where m.company_id = noona_hr_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'', ''SUSPENDED'') and exists (select 1 from pay_employee_element x where x.employment_id = m.id) order by 1'
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
 p_id=>wwv_flow_imp.id(91820272000000199)
,p_name=>'P30_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000197)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سلفة راتب;SALARY_ADVANCE,قرض;LOAN,سلفة سكن;HOUSING_ADVANCE,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000200)
,p_name=>'P30_AMOUNT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000197)
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
 p_id=>wwv_flow_imp.id(91820272000000201)
,p_name=>'P30_COUNT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000197)
,p_prompt=>'عدد الأقساط'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000202)
,p_name=>'P30_PERIOD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000197)
,p_prompt=>'بداية الخصم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.period_code || case when exists (select 1 from pay_run r where r.period_id = p.id and r.run_type = ''REGULAR'') then '' (له تشغيل)'' end d, p.id r from pay_period p where p.company_id = noona_pay_pkg.company and p.payroll_group_id = noona_pay_pkg.default_group order by p.start_date desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000204)
,p_validation_name=>'P30_EMP required (CREATE_LOAN)'
,p_validation_sequence=>6
,p_validation=>'P30_EMP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000203)
,p_associated_item=>wwv_flow_imp.id(91820272000000198)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000205)
,p_validation_name=>'P30_AMOUNT required (CREATE_LOAN)'
,p_validation_sequence=>7
,p_validation=>'P30_AMOUNT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000203)
,p_associated_item=>wwv_flow_imp.id(91820272000000200)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000206)
,p_validation_name=>'P30_COUNT required (CREATE_LOAN)'
,p_validation_sequence=>8
,p_validation=>'P30_COUNT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000203)
,p_associated_item=>wwv_flow_imp.id(91820272000000201)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000203)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000197)
,p_button_name=>'CREATE_LOAN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء وجدولة الأقساط'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000207)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Loan'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_pay_pkg.create_loan(:P30_EMP, :P30_TYPE, :P30_AMOUNT, :P30_COUNT, :P30_PERIOD);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000203)
,p_process_success_message=>'تم إنشاء السلفة وجدولة أقساطها؛ اصرفها لتصبح قائمة'
,p_internal_uid=>91820272000000207
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000208)
,p_plug_name=>'صرف السلفة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000209)
,p_name=>'P30_PENDING'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000208)
,p_prompt=>'سلفة بانتظار الصرف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select doc_no || '' · '' || noona_hr_pkg.employment_label(employment_id) || '' · '' || principal_amount d, id r from pay_loan where company_id = noona_pay_pkg.company and status_code = ''APPROVED'' order by doc_date'
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
 p_id=>wwv_flow_imp.id(91820272000000210)
,p_name=>'P30_BANK'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000208)
,p_prompt=>'من الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_bank_account where company_id = noona_pay_pkg.company and status_code = ''ACTIVE'' order by code'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000211)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000208)
,p_button_name=>'DISBURSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'صرف وترحيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000212)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Disburse'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_pay_pkg.disburse_loan(:P30_PENDING, :P30_BANK);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000211)
,p_process_success_message=>'تم صرف السلفة وترحيل قيدها (مدين سلف الموظفين / دائن البنك)'
,p_internal_uid=>91820272000000212
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000213)
,p_plug_name=>'السلف القائمة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_pay_pkg.loans_report_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000214)
,p_branch_action=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:30::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
