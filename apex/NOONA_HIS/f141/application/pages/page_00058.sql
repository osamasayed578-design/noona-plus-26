prompt --application/pages/page_00058
begin
--   Manifest
--     PAGE: 00058
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
 p_id=>58
,p_name=>'Therapy'
,p_alias=>'THERAPY'
,p_step_title=>'العلاج الطبيعي والجلسات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(''#P58_GOALS,#P58_SNOTES,#P58_FREQ'').attr(''dir'', ''ltr'');'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000671)
,p_plug_name=>'خطة علاج'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000672)
,p_name=>'P58_VISIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000671)
,p_prompt=>'الزيارة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select v.visit_no || '' - '' || p.name_ar || '' ('' || p.mrn || '')'' d, v.id r from his_visit v join his_patient p on p.id = v.patient_id where v.company_id = noona_his_pkg.company and v.status_code = ''OPEN'' order by v.visit_at desc'
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
 p_id=>wwv_flow_imp.id(91820275000000673)
,p_name=>'P58_SRV'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000671)
,p_prompt=>'الجلسة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select s.name_ar || '' ('' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from his_service s where s.company_id = noona_his_pkg.company and s.status_code = ''ACTIVE'' and s.service_type in (''PHYSIOTHERAPY'', ''THERAPY'', ''NURSING'', ''DENTAL'') order by 1'
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
 p_id=>wwv_flow_imp.id(91820275000000674)
,p_name=>'P58_SESS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000671)
,p_prompt=>'عدد الجلسات'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000675)
,p_name=>'P58_THER'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000671)
,p_prompt=>'المعالج'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company and d.status_code = ''ACTIVE'' order by p.sort_order, p.name_ar, d.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000676)
,p_name=>'P58_FREQ'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000671)
,p_prompt=>'التكرار (مثلاً 3 أسبوعياً)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000677)
,p_name=>'P58_GOALS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000671)
,p_prompt=>'أهداف العلاج (بالإنجليزية)'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000678)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000671)
,p_button_name=>'PLAN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الخطة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000679)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Plan'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number; l_doc clob;',
'begin',
'    select json_object(''visit'' value to_number(:P58_VISIT), ''service'' value to_number(:P58_SRV), ''sessions'' value to_number(:P58_SESS),',
'           ''therapist'' value to_number(:P58_THER), ''frequency'' value :P58_FREQ, ''goals'' value :P58_GOALS returning clob) into l_doc from dual;',
'    l := noona_his_care_pkg.create_plan(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000678)
,p_process_success_message=>'أنشئت الخطة؛ تسدد قبل أول جلسة'
,p_internal_uid=>91820275000000679
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000680)
,p_plug_name=>'تسجيل جلسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000681)
,p_name=>'P58_PLAN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000680)
,p_prompt=>'الخطة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar || '' - '' || s.name_ar || '' ('' || t.sessions_done || ''/'' || t.sessions_total || '')'' d, t.id r from his_therapy_plan t join his_visit v on v.id = t.visit_id join his_patient p on p.id = v.patient_id join his_service s on s.id = t.service_id where t.company_id = noona_his_pkg.company and t.status_code = ''ACTIVE'' order by p.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000682)
,p_name=>'P58_STHER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000680)
,p_prompt=>'المعالج'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company and d.status_code = ''ACTIVE'' order by p.sort_order, p.name_ar, d.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- معالج الخطة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000683)
,p_name=>'P58_SNOTES'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000680)
,p_prompt=>'ملاحظات الجلسة والتقدم (بالإنجليزية)'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000684)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000680)
,p_button_name=>'SESSION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل الجلسة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000685)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Session'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_care_pkg.record_session(:P58_PLAN, to_number(:P58_STHER), :P58_SNOTES);',
'    apex_application.g_print_success_message := ''سجلت الجلسة رقم '' || l;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000684)
,p_internal_uid=>91820275000000685
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000686)
,p_plug_name=>'الخطط'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.id, p.name_ar as patient, p.mrn, s.name_ar as service, t.sessions_done || '' / '' || t.sessions_total as progress, t.frequency,',
'       (select name_ar from his_doctor where id = t.therapist_id) as therapist,',
'       case t.status_code when ''ACTIVE'' then ''جارية'' when ''COMPLETED'' then ''مكتملة'' else ''ملغاة'' end as status,',
'       case when o.invoice_id is not null then ''نعم'' else ''لا'' end as paid,',
'       (select to_char(max(x.session_at), ''YYYY-MM-DD'') from his_therapy_session x where x.plan_id = t.id) as last_session',
'  from his_therapy_plan t join his_visit v on v.id = t.visit_id join his_patient p on p.id = v.patient_id join his_service s on s.id = t.service_id',
'  join his_order o on o.id = t.order_id where t.company_id = noona_his_pkg.company order by t.status_code, p.name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الخطط'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000687)
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
,p_internal_uid=>91820275000000687
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000689)
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
 p_id=>wwv_flow_imp.id(91820275000000690)
,p_db_column_name=>'PATIENT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المريض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000691)
,p_db_column_name=>'MRN'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الرقم الطبي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000692)
,p_db_column_name=>'SERVICE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الجلسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000693)
,p_db_column_name=>'PROGRESS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المنفذ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000694)
,p_db_column_name=>'FREQUENCY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'التكرار'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000695)
,p_db_column_name=>'THERAPIST'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المعالج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000696)
,p_db_column_name=>'STATUS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000697)
,p_db_column_name=>'PAID'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'مسددة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000698)
,p_db_column_name=>'LAST_SESSION'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'آخر جلسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000688)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'688'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PATIENT:MRN:SERVICE:PROGRESS:FREQUENCY:THERAPIST:STATUS:PAID:LAST_SESSION'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000699)
,p_branch_action=>'f?p=&APP_ID.:58:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
