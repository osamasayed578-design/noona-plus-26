prompt --application/pages/page_00030
begin
--   Manifest
--     PAGE: 00030
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>147
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>'Incidents'
,p_alias=>'INCIDENTS'
,p_step_title=>'الأعطال والبلاغات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000232)
,p_plug_name=>'بلاغ جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000233)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000232)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل عطل أو بلاغ'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000234)
,p_plug_name=>'الأعطال والبلاغات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, i.doc_no, i.reported_at, t.doc_no trip_no, v.plate_no, d.full_name driver, noona_trn_pkg.incident_label(i.incident_type) incident_type, noona_trn_pkg.severity_label(i.severity) severity, i.location_text, i.description,',
'       i.assigned_to, round((cast(i.acknowledged_at as date) - cast(i.reported_at as date)) * 1440) ack_minutes,',
'       round((cast(i.resolved_at as date) - cast(i.reported_at as date)) * 1440) resolve_minutes, i.downtime_minutes, i.cost_amount,',
'       noona_trn_pkg.badge(i.status_code) status_html',
'  from trn_incident i join trn_vehicle v on v.id = i.vehicle_id left join trn_trip t on t.id = i.trip_id left join trn_driver d on d.id = i.driver_id',
' where i.company_id = noona_trn_pkg.company order by i.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الأعطال والبلاغات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000235)
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
,p_internal_uid=>91820290000000235
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000237)
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
 p_id=>wwv_flow_imp.id(91820290000000238)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'البلاغ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000239)
,p_db_column_name=>'REPORTED_AT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000240)
,p_db_column_name=>'TRIP_NO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الرحلة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000241)
,p_db_column_name=>'PLATE_NO'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'العربة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000242)
,p_db_column_name=>'DRIVER'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'السائق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000243)
,p_db_column_name=>'INCIDENT_TYPE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000244)
,p_db_column_name=>'SEVERITY'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الخطورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000245)
,p_db_column_name=>'LOCATION_TEXT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'المكان'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000246)
,p_db_column_name=>'DESCRIPTION'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'الوصف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000247)
,p_db_column_name=>'ASSIGNED_TO'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'المكلف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000248)
,p_db_column_name=>'ACK_MINUTES'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'زمن الاستلام (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000249)
,p_db_column_name=>'RESOLVE_MINUTES'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'زمن الحل (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000250)
,p_db_column_name=>'DOWNTIME_MINUTES'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'التوقف (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000251)
,p_db_column_name=>'COST_AMOUNT'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'التكلفة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000252)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000236)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'236'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:REPORTED_AT:TRIP_NO:PLATE_NO:DRIVER:INCIDENT_TYPE:SEVERITY:LOCATION_TEXT:DESCRIPTION:ASSIGNED_TO:ACK_MINUTES:RESOLVE_MINUTES:DOWNTIME_MINUTES:COST_AMOUNT:STATUS_HTML'
);

wwv_flow_imp.component_end;
end;
/
