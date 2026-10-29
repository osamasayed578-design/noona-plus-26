prompt --application/pages/page_00082
begin
--   Manifest
--     PAGE: 00082
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>82
,p_name=>'Project Form'
,p_alias=>'PROJECT-FORM'
,p_step_title=>'بيانات المشروع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000581)
,p_plug_name=>'بيانات المشروع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">المشروع العام يكفيه الاسم والنوع. مشروع التطوير العقاري يرتبط بعقار من السجل العقاري لتوزع تكلفته على الوحدات. ينشأ للمشروع مركز تكلفة باسمه تحمل عليه تكاليفه وإيراداته.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000582)
,p_name=>'P82_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000583)
,p_name=>'P82_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'الرمز (فارغ = تلقائي)'
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
 p_id=>wwv_flow_imp.id(91820273000000584)
,p_name=>'P82_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'اسم المشروع'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>400
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000585)
,p_name=>'P82_NAME_EN'
,p_item_sequence=>25
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'اسم المشروع بالإنجليزية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>400
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000586)
,p_name=>'P82_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مشروع لعميل;CLIENT_CONTRACT,مقاولات وإنشاءات;CONSTRUCTION,تطوير عقاري;REAL_ESTATE_DEVELOPMENT,داخلي;INTERNAL,صيانة;MAINTENANCE,رأسمالي;CAPEX,برنامج;PROGRAM'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000587)
,p_name=>'P82_CUSTOMER'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'العميل (المالك)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id join pty_party p on p.id = c.party_id where a.company_id = noona_prj_pkg.company and a.status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- بدون (داخلي) -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000588)
,p_name=>'P82_MANAGER'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'مدير المشروع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_prj_pkg.company) order by 1'
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
 p_id=>wwv_flow_imp.id(91820273000000589)
,p_name=>'P82_PROPERTY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'العقار (للتطوير العقاري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from re_property where company_id = noona_prj_pkg.company order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000590)
,p_name=>'P82_PARENT'
,p_item_sequence=>65
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'البرنامج الأم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from prj_project where company_id = noona_prj_pkg.company order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000591)
,p_name=>'P82_START'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'البداية المخططة'
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
 p_id=>wwv_flow_imp.id(91820273000000592)
,p_name=>'P82_END'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'النهاية المخططة'
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
 p_id=>wwv_flow_imp.id(91820273000000593)
,p_name=>'P82_CONTRACT'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_prompt=>'قيمة العقد (تتحدث من العقد الرئيسي)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000595)
,p_validation_name=>'P82_NAME required (SAVE)'
,p_validation_sequence=>13
,p_validation=>'P82_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000594)
,p_associated_item=>wwv_flow_imp.id(91820273000000584)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000594)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000596)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000581)
,p_button_name=>'CANCEL'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:80:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000597)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P82_ID is not null then',
'        select code, name_ar, name_en, project_type, customer_account_id, manager_employee_id, parent_project_id,',
'               to_char(planned_start, ''YYYY-MM-DD''), to_char(planned_end, ''YYYY-MM-DD''), contract_value,',
'               (select min(id) from re_property where project_id = p.id)',
'          into :P82_CODE, :P82_NAME, :P82_NAME_EN, :P82_TYPE, :P82_CUSTOMER, :P82_MANAGER, :P82_PARENT, :P82_START, :P82_END,',
'               :P82_CONTRACT, :P82_PROPERTY',
'          from prj_project p where id = :P82_ID and company_id = noona_prj_pkg.company;',
'    else',
'        :P82_TYPE := nvl(:P82_TYPE, ''CLIENT_CONTRACT'');',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000597
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000598)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''id'' value to_number(:P82_ID), ''code'' value :P82_CODE, ''name'' value :P82_NAME, ''nameEn'' value :P82_NAME_EN,',
'                       ''type'' value :P82_TYPE, ''customer'' value to_number(:P82_CUSTOMER), ''manager'' value to_number(:P82_MANAGER),',
'                       ''property'' value to_number(:P82_PROPERTY), ''parent'' value to_number(:P82_PARENT), ''start'' value :P82_START,',
'                       ''end'' value :P82_END, ''contract'' value to_number(:P82_CONTRACT) returning clob) into l_doc from dual;',
'    :P82_ID := noona_prj_pkg.save_project(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000594)
,p_process_success_message=>'تم حفظ المشروع'
,p_internal_uid=>91820273000000598
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000599)
,p_branch_action=>'f?p=&APP_ID.:81:&SESSION.::&DEBUG.:81:P81_ID:&P82_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
