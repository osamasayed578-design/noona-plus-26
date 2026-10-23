prompt --application/pages/page_00030
begin
--   Manifest
--     PAGE: 00030
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
 p_id=>30
,p_name=>'Visits'
,p_alias=>'VISITS'
,p_step_title=>'الزيارات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000127)
,p_plug_name=>'إجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000128)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000127)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'زيارة جديدة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:RP,32::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000129)
,p_plug_name=>'الزيارات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select v.id, v.visit_no, to_char(v.visit_at, ''YYYY-MM-DD HH24:MI'') as visit_at, p.name_ar as patient, p.mrn, d.name_ar as dept,',
'       dr.name_ar as doctor, case v.bill_to when ''PAYER'' then ''جهة'' else ''نقدي'' end as bill_to, v.patient_total, v.payer_total, v.paid_amount,',
'       noona_his_pkg.unbilled_total(v.id, ''PATIENT'') + noona_his_pkg.unbilled_total(v.id, ''PAYER'') as unbilled,',
'       case v.status_code when ''OPEN'' then ''مفتوحة'' when ''CLOSED'' then ''مقفلة'' else ''ملغاة'' end as status',
'  from his_visit v join his_patient p on p.id = v.patient_id join his_department d on d.id = v.department_id',
'  left join his_doctor dr on dr.id = v.doctor_id where v.company_id = noona_his_pkg.company order by v.visit_at desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الزيارات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000130)
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
,p_internal_uid=>91820275000000130
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000132)
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
 p_id=>wwv_flow_imp.id(91820275000000133)
,p_db_column_name=>'VISIT_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الزيارة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000134)
,p_db_column_name=>'VISIT_AT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000135)
,p_db_column_name=>'PATIENT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المريض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000136)
,p_db_column_name=>'MRN'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الرقم الطبي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000137)
,p_db_column_name=>'DEPT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'القسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000138)
,p_db_column_name=>'DOCTOR'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الطبيب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000139)
,p_db_column_name=>'BILL_TO'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الدفع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000140)
,p_db_column_name=>'PATIENT_TOTAL'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'على المريض'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000141)
,p_db_column_name=>'PAYER_TOTAL'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'على الجهة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000142)
,p_db_column_name=>'PAID_AMOUNT'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'المدفوع'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000143)
,p_db_column_name=>'UNBILLED'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'غير مفوتر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000144)
,p_db_column_name=>'STATUS'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000131)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'131'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'VISIT_NO:VISIT_AT:PATIENT:MRN:DEPT:DOCTOR:BILL_TO:PATIENT_TOTAL:PAYER_TOTAL:PAID_AMOUNT:UNBILLED:STATUS'
);

wwv_flow_imp.component_end;
end;
/
