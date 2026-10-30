prompt --application/pages/page_00032
begin
--   Manifest
--     PAGE: 00032
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
 p_id=>32
,p_name=>'New Visit'
,p_alias=>'NEW-VISIT'
,p_step_title=>'زيارة جديدة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000229)
,p_plug_name=>'الزيارة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000230)
,p_name=>'P32_PATIENT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_prompt=>'المريض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' - '' || mrn || nvl2(mobile, '' - '' || mobile, '''') d, id r from his_patient where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000231)
,p_name=>'P32_DOCTOR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_prompt=>'الطبيب (يضاف كشفه تلقائياً)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company and d.status_code = ''ACTIVE'' order by p.sort_order, p.name_ar, d.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- بدون طبيب -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000232)
,p_name=>'P32_DEPT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_prompt=>'القسم (للمعامل والأشعة المباشرة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_department where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by sort_order, name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- قسم الطبيب -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000233)
,p_name=>'P32_TYPE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_prompt=>'نوع الزيارة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عيادات خارجية;OUTPATIENT,طوارئ;EMERGENCY,تنويم;INPATIENT,إقامة يوم واحد;DAY_CASE,تحويل من جهة;REFERRAL_IN'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000234)
,p_name=>'P32_BILL'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_prompt=>'الدفع (التأمين اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:حسب ملف المريض (التأمين إن وجد);,نقدي بدون تأمين;CASH,على التأمين/الجهة;PAYER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000235)
,p_name=>'P32_APPROVAL'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_prompt=>'رقم الموافقة (إن وجد)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>50
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
 p_id=>wwv_flow_imp.id(91820275000000236)
,p_name=>'P32_COMPLAINT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_prompt=>'الشكوى'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000237)
,p_name=>'P32_ID'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000000239)
,p_validation_name=>'P32_PATIENT required (OPEN)'
,p_validation_sequence=>9
,p_validation=>'P32_PATIENT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000000238)
,p_associated_item=>wwv_flow_imp.id(91820275000000230)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000238)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000229)
,p_button_name=>'OPEN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'فتح الزيارة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000240)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Open'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''patient'' value to_number(:P32_PATIENT), ''doctor'' value to_number(:P32_DOCTOR), ''dept'' value to_number(:P32_DEPT), ''type'' value :P32_TYPE, ''bill_to'' value :P32_BILL, ''approval'' value :P32_APPROVAL, ''complaint'' value :P32_COMPLAINT returning clob) into l_doc from dual;',
'    :P32_ID := noona_his_pkg.open_visit(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000238)
,p_process_success_message=>'فتحت الزيارة'
,p_internal_uid=>91820275000000240
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000241)
,p_branch_action=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.::P31_ID:&P32_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
