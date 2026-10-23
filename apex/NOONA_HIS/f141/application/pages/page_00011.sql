prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
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
 p_id=>11
,p_name=>'Patient'
,p_alias=>'PATIENT'
,p_step_title=>'بيانات المريض'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000049)
,p_plug_name=>'بيانات المريض'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000050)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000051)
,p_name=>'P11_MRN'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'الرقم الطبي (تلقائي)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000052)
,p_name=>'P11_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
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
 p_id=>wwv_flow_imp.id(91820275000000053)
,p_name=>'P11_NAME_EN'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'الاسم بالإنجليزية'
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
 p_id=>wwv_flow_imp.id(91820275000000054)
,p_name=>'P11_GENDER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'الجنس'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:ذكر;M,أنثى;F'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000055)
,p_name=>'P11_BIRTH'
,p_item_sequence=>25
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'تاريخ الميلاد'
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
 p_id=>wwv_flow_imp.id(91820275000000056)
,p_name=>'P11_ID_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'نوع الهوية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:هوية وطنية;NATIONAL_ID,إقامة;IQAMA,جواز سفر;PASSPORT,رقم حدود;BORDER_NO,شهادة ميلاد;BIRTH_CERT'
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
 p_id=>wwv_flow_imp.id(91820275000000057)
,p_name=>'P11_ID_NO'
,p_item_sequence=>35
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'رقم الهوية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000058)
,p_name=>'P11_NAT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'الجنسية (السعودي معفى من الضريبة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, country_code r from ref_country order by case country_code when ''SA'' then 0 else 1 end, name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000059)
,p_name=>'P11_MOBILE'
,p_item_sequence=>45
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000060)
,p_name=>'P11_BLOOD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'فصيلة الدم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:A+;A+,A-;A-,B+;B+,B-;B-,AB+;AB+,AB-;AB-,O+;O+,O-;O-'
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
 p_id=>wwv_flow_imp.id(91820275000000061)
,p_name=>'P11_EMERG'
,p_item_sequence=>55
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'جهة الاتصال للطوارئ'
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
 p_id=>wwv_flow_imp.id(91820275000000062)
,p_name=>'P11_ALLERGY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'الحساسية'
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
 p_id=>wwv_flow_imp.id(91820275000000063)
,p_name=>'P11_CHRONIC'
,p_item_sequence=>65
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'الأمراض المزمنة'
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
 p_id=>wwv_flow_imp.id(91820275000000064)
,p_name=>'P11_ADDRESS'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_prompt=>'العنوان'
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000065)
,p_plug_name=>'التأمين أو الجهة المتعاقدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000066)
,p_name=>'P11_PLAN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000065)
,p_prompt=>'الجهة وفئة التغطية (فارغ = نقدي)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select y.name_ar || '' - '' || p.name_ar || '' (المريض '' || p.patient_share_pct || ''%)'' d, p.id r from his_payer_plan p join his_payer y on y.id = p.payer_id where p.company_id = noona_his_pkg.company and p.is_active = ''Y'' and y.status_code = ''ACTIVE'' order by y.name_ar, p.code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- نقدي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000067)
,p_name=>'P11_MEMBER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000065)
,p_prompt=>'رقم العضوية'
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
 p_id=>wwv_flow_imp.id(91820275000000068)
,p_name=>'P11_POLICY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000065)
,p_prompt=>'رقم الوثيقة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820275000000069)
,p_name=>'P11_INS_EXP'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000065)
,p_prompt=>'انتهاء التأمين'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000000071)
,p_validation_name=>'P11_NAME required (SAVE)'
,p_validation_sequence=>21
,p_validation=>'P11_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000000070)
,p_associated_item=>wwv_flow_imp.id(91820275000000052)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000070)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000072)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_button_name=>'BOOK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حجز موعد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_PATIENT:&P11_ID.'
,p_button_condition=>':P11_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000073)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000000049)
,p_button_name=>'VISIT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'فتح زيارة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:RP,32:P32_PATIENT:&P11_ID.'
,p_button_condition=>':P11_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000074)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select mrn, name_ar, name_en, gender, to_char(birth_date, ''YYYY-MM-DD''), id_type, id_no, nationality, mobile, blood_group, emergency_contact,',
'           allergies, chronic_diseases, address, payer_plan_id, member_no, policy_no, to_char(insurance_expiry, ''YYYY-MM-DD'')',
'      into :P11_MRN, :P11_NAME, :P11_NAME_EN, :P11_GENDER, :P11_BIRTH, :P11_ID_TYPE, :P11_ID_NO, :P11_NAT, :P11_MOBILE, :P11_BLOOD, :P11_EMERG,',
'           :P11_ALLERGY, :P11_CHRONIC, :P11_ADDRESS, :P11_PLAN, :P11_MEMBER, :P11_POLICY, :P11_INS_EXP',
'      from his_patient where id = :P11_ID and company_id = noona_his_pkg.company;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000000074
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000075)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''id'' value to_number(:P11_ID), ''name'' value :P11_NAME, ''name_en'' value :P11_NAME_EN, ''gender'' value :P11_GENDER, ''birth'' value :P11_BIRTH, ''id_type'' value :P11_ID_TYPE, ''id_no'' value :P11_ID_NO, ''nationality'' value :P11_NAT, ''mobile'' value :P11_MOBILE, ''blood'' value :P11_BLOOD, ''allergies'' value :P11_ALLERGY, ''chronic'' value :P11_CHRONIC, ''plan'' value to_number(:P11_PLAN), ''member'' value :P11_MEMBER, ''policy'' value :P11_POLICY, ''ins_expiry'' value :P11_INS_EXP, ''address'' value :P11_ADDRESS, ''emergency'' value :P11_EMERG returning clob) into l_doc from dual;',
'    :P11_ID := noona_his_pkg.save_patient(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000070)
,p_process_success_message=>'تم حفظ بيانات المريض'
,p_internal_uid=>91820275000000075
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000076)
,p_plug_name=>'زيارات المريض'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select v.id, v.visit_no, to_char(v.visit_at, ''YYYY-MM-DD HH24:MI'') as visit_at, d.name_ar as dept, dr.name_ar as doctor, v.diagnosis,',
'       v.patient_total, v.payer_total, case v.status_code when ''OPEN'' then ''مفتوحة'' when ''CLOSED'' then ''مقفلة'' else ''ملغاة'' end as status',
'  from his_visit v join his_department d on d.id = v.department_id left join his_doctor dr on dr.id = v.doctor_id',
' where v.patient_id = :P11_ID order by v.visit_at desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'زيارات المريض'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000077)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820275000000077
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000079)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000080)
,p_db_column_name=>'VISIT_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الزيارة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000081)
,p_db_column_name=>'VISIT_AT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000082)
,p_db_column_name=>'DEPT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'القسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000083)
,p_db_column_name=>'DOCTOR'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الطبيب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000084)
,p_db_column_name=>'DIAGNOSIS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'التشخيص'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000085)
,p_db_column_name=>'PATIENT_TOTAL'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'على المريض'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000086)
,p_db_column_name=>'PAYER_TOTAL'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'على الجهة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000087)
,p_db_column_name=>'STATUS'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000078)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'78'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'VISIT_NO:VISIT_AT:DEPT:DOCTOR:DIAGNOSIS:PATIENT_TOTAL:PAYER_TOTAL:STATUS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000088)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.::P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
