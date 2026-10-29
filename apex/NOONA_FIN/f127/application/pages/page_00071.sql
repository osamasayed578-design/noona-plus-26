prompt --application/pages/page_00071
begin
--   Manifest
--     PAGE: 00071
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>71
,p_name=>'Legal Registrations'
,p_alias=>'TAX-REGISTRATIONS'
,p_step_title=>'التسجيلات القانونية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000726)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000741)
,p_plug_name=>'تسجيلات الشركة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_loc_pkg.registrations_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000742)
,p_plug_name=>'تسجيل جديد / تحديث'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يتحقق الرقم من صيغة التسجيل في حزمة الدولة (مثل الرقم الضريبي السعودي 15 رقماً يبدأ وينتهي بـ 3). التسجيل الضريبي الرئيسي يظهر في الفواتير والإقرارات.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000743)
,p_name=>'P71_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000742)
,p_prompt=>'نوع التسجيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t.name_ar || case when t.is_tax_registration = ''Y'' then '' (ضريبي)'' end d, t.id r from loc_registration_type t where t.country_pack_id = noona_loc_pkg.company_pack and t.is_active = ''Y'' order by t.is_tax_registration desc, t.code'
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
 p_id=>wwv_flow_imp.id(91820266000000744)
,p_name=>'P71_NUMBER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000742)
,p_prompt=>'الرقم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>100
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
 p_id=>wwv_flow_imp.id(91820266000000745)
,p_name=>'P71_AUTHORITY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000742)
,p_prompt=>'الجهة المصدرة'
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
 p_id=>wwv_flow_imp.id(91820266000000746)
,p_name=>'P71_ISSUE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000742)
,p_prompt=>'تاريخ الإصدار'
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
 p_id=>wwv_flow_imp.id(91820266000000747)
,p_name=>'P71_EXPIRY'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000742)
,p_prompt=>'تاريخ الانتهاء'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000749)
,p_validation_name=>'P71_TYPE required (SAVE)'
,p_validation_sequence=>7
,p_validation=>'P71_TYPE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000748)
,p_associated_item=>wwv_flow_imp.id(91820266000000743)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000750)
,p_validation_name=>'P71_NUMBER required (SAVE)'
,p_validation_sequence=>8
,p_validation=>'P71_NUMBER'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000748)
,p_associated_item=>wwv_flow_imp.id(91820266000000744)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000748)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000742)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ التسجيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000751)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_loc_pkg.save_registration(json_object(''type'' value to_number(:P71_TYPE), ''number'' value :P71_NUMBER,',
'              ''authority'' value :P71_AUTHORITY, ''issue'' value :P71_ISSUE, ''expiry'' value :P71_EXPIRY, ''primary'' value ''Y''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000748)
,p_process_success_message=>'تم حفظ التسجيل'
,p_internal_uid=>91820266000000751
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000752)
,p_plug_name=>'إنهاء تسجيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000753)
,p_name=>'P71_END'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000752)
,p_prompt=>'التسجيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t.name_ar || '' - '' || g.reg_number d, g.id r from org_legal_registration g join loc_registration_type t on t.id = g.reg_type_id where g.company_id = noona_loc_pkg.company and g.status_code <> ''CANCELLED'' order by t.code'
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
 p_id=>wwv_flow_imp.id(91820266000000754)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000752)
,p_button_name=>'END'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إنهاء التسجيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000755)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'End'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_loc_pkg.end_registration(:P71_END);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000754)
,p_process_success_message=>'تم إنهاء التسجيل'
,p_internal_uid=>91820266000000755
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000756)
,p_branch_action=>'f?p=&APP_ID.:71:&SESSION.::&DEBUG.:71::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
