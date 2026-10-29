prompt --application/pages/page_00036
begin
--   Manifest
--     PAGE: 00036
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
 p_id=>36
,p_name=>'Medical Certificates'
,p_alias=>'CERTIFICATES'
,p_step_title=>'Medical reports & sick leave - التقارير الطبية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(''#P36_REF,#P36_BODY,#P36_REASON'').attr(''dir'', ''ltr'');'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000896)
,p_plug_name=>'إصدار تقرير أو إجازة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000897)
,p_name=>'P36_VISIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_prompt=>'الزيارة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select v.visit_no || '' - '' || p.name_ar || '' ('' || p.mrn || '')'' d, v.id r from his_visit v join his_patient p on p.id = v.patient_id where v.company_id = noona_his_pkg.company and v.status_code <> ''CANCELLED'' and v.visit_at >= sysdate - 60 order by v.visit_at desc'
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
 p_id=>wwv_flow_imp.id(91820275000000898)
,p_name=>'P36_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إجازة مرضية;SICK_LEAVE,تقرير طبي;MEDICAL_REPORT,خطاب تحويل;REFERRAL,شهادة لياقة;FITNESS,شهادة مرافق;COMPANION'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000899)
,p_name=>'P36_FROM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_prompt=>'من'
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
 p_id=>wwv_flow_imp.id(91820275000000900)
,p_name=>'P36_TO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_prompt=>'إلى'
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
 p_id=>wwv_flow_imp.id(91820275000000901)
,p_name=>'P36_REF'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_prompt=>'محول إلى (مستشفى / تخصص)'
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
 p_id=>wwv_flow_imp.id(91820275000000902)
,p_name=>'P36_DOCTOR'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_prompt=>'الطبيب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company and d.status_code = ''ACTIVE'' order by p.sort_order, p.name_ar, d.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- طبيب الزيارة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000903)
,p_name=>'P36_BODY'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_prompt=>'النص (بالإنجليزية؛ فارغ = الصيغة القياسية)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000904)
,p_name=>'P36_ID'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000000906)
,p_validation_name=>'P36_VISIT required (ISSUE)'
,p_validation_sequence=>9
,p_validation=>'P36_VISIT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000000905)
,p_associated_item=>wwv_flow_imp.id(91820275000000897)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000905)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000896)
,p_button_name=>'ISSUE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إصدار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000907)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Issue'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''visit'' value to_number(:P36_VISIT), ''type'' value :P36_TYPE, ''from'' value :P36_FROM, ''to'' value :P36_TO,',
'           ''referral_to'' value :P36_REF, ''doctor'' value to_number(:P36_DOCTOR), ''body'' value :P36_BODY returning clob) into l_doc from dual;',
'    :P36_ID := noona_his_clin_pkg.issue_certificate(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000905)
,p_process_success_message=>'Issued'
,p_internal_uid=>91820275000000907
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000908)
,p_plug_name=>'إلغاء تقرير'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000909)
,p_name=>'P36_CERT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000908)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select c.cert_no || '' - '' || noona_his_clin_pkg.cert_type_label(c.cert_type) d, c.id r from his_certificate c where c.company_id = noona_his_pkg.company and c.status_code = ''ISSUED'' and c.visit_id = :P36_VISIT order by c.id desc'
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
 p_id=>wwv_flow_imp.id(91820275000000910)
,p_name=>'P36_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000908)
,p_prompt=>'السبب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
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
 p_id=>wwv_flow_imp.id(91820275000000911)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000908)
,p_button_name=>'CANCEL_CERT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء التقرير'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000912)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_clin_pkg.cancel_certificate(:P36_CERT, :P36_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000911)
,p_process_success_message=>'Cancelled'
,p_internal_uid=>91820275000000912
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000913)
,p_plug_name=>'التقارير والإجازات الصادرة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select c.id, c.cert_no, noona_his_clin_pkg.cert_type_label(c.cert_type) as cert_type, c.issued_on, p.name_ar as patient, p.mrn,',
'       c.from_date, c.to_date, c.days, c.referral_to, d.name_ar as doctor, c.verify_code,',
'       case c.status_code when ''ISSUED'' then ''Issued'' else ''Cancelled'' end as status,',
'       ''<span class="fa fa-print" aria-hidden="true"></span> Print'' as prn',
'  from his_certificate c join his_visit v on v.id = c.visit_id join his_patient p on p.id = v.patient_id left join his_doctor d on d.id = c.doctor_id',
' where c.company_id = noona_his_pkg.company and (:P36_VISIT is null or c.visit_id = :P36_VISIT) order by c.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'التقارير والإجازات الصادرة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000914)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_owner=>'NOONA'
,p_internal_uid=>91820275000000914
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000916)
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
 p_id=>wwv_flow_imp.id(91820275000000917)
,p_db_column_name=>'CERT_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000918)
,p_db_column_name=>'CERT_TYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000919)
,p_db_column_name=>'ISSUED_ON'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'تاريخ الإصدار'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000920)
,p_db_column_name=>'PATIENT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المريض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000921)
,p_db_column_name=>'MRN'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'MRN'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000922)
,p_db_column_name=>'FROM_DATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'من'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000923)
,p_db_column_name=>'TO_DATE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'إلى'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000924)
,p_db_column_name=>'DAYS'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الأيام'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000925)
,p_db_column_name=>'REFERRAL_TO'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'محول إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000926)
,p_db_column_name=>'DOCTOR'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الطبيب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000927)
,p_db_column_name=>'VERIFY_CODE'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000928)
,p_db_column_name=>'STATUS'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000929)
,p_db_column_name=>'PRN'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'طباعة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_column_link=>'f?p=&APP_ID.:37:&SESSION.::&DEBUG.:RP,37:P37_ID:#ID#'
,p_column_linktext=>'#PRN#'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000915)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'915'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CERT_NO:CERT_TYPE:ISSUED_ON:PATIENT:MRN:FROM_DATE:TO_DATE:DAYS:REFERRAL_TO:DOCTOR:VERIFY_CODE:STATUS:PRN'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000930)
,p_branch_action=>'f?p=&APP_ID.:37:&SESSION.::&DEBUG.::P37_ID:&P36_ID.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820275000000905)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000931)
,p_branch_action=>'f?p=&APP_ID.:36:&SESSION.::&DEBUG.::P36_VISIT:&P36_VISIT.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
