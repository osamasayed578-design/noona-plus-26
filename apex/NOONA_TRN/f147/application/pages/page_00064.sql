prompt --application/pages/page_00064
begin
--   Manifest
--     PAGE: 00064
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
 p_id=>64
,p_name=>'Incidents-Report'
,p_alias=>'INCIDENTS-REPORT'
,p_step_title=>'الأعطال والبلاغات وزمن الاستجابة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000676)
,p_plug_name=>'الأعطال والبلاغات وزمن الاستجابة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select noona_trn_pkg.incident_label(i.incident_type) incident_type, noona_trn_pkg.severity_label(i.severity) severity, count(*) incidents,',
'       round(avg((cast(i.acknowledged_at as date) - cast(i.reported_at as date)) * 1440)) avg_ack_min,',
'       round(avg((cast(i.responded_at as date) - cast(i.reported_at as date)) * 1440)) avg_response_min,',
'       round(avg((cast(i.resolved_at as date) - cast(i.reported_at as date)) * 1440)) avg_resolve_min,',
'       sum(case when i.status_code in (''REPORTED'',''ACKNOWLEDGED'',''IN_PROGRESS'') then 1 else 0 end) open_count,',
'       nvl(sum(i.downtime_minutes), 0) downtime, nvl(sum(i.cost_amount), 0) cost',
'  from trn_incident i where i.company_id = noona_trn_pkg.company group by i.incident_type, i.severity order by incidents desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الأعطال والبلاغات وزمن الاستجابة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000677)
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
,p_internal_uid=>91820290000000677
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000679)
,p_db_column_name=>'INCIDENT_TYPE'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000680)
,p_db_column_name=>'SEVERITY'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الخطورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000681)
,p_db_column_name=>'INCIDENTS'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'العدد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000682)
,p_db_column_name=>'AVG_ACK_MIN'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'متوسط زمن الاستلام (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000683)
,p_db_column_name=>'AVG_RESPONSE_MIN'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'متوسط زمن الاستجابة (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000684)
,p_db_column_name=>'AVG_RESOLVE_MIN'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'متوسط زمن الحل (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000685)
,p_db_column_name=>'OPEN_COUNT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'مفتوحة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000686)
,p_db_column_name=>'DOWNTIME'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'التوقف (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000687)
,p_db_column_name=>'COST'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'التكلفة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000678)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'678'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'INCIDENT_TYPE:SEVERITY:INCIDENTS:AVG_ACK_MIN:AVG_RESPONSE_MIN:AVG_RESOLVE_MIN:OPEN_COUNT:DOWNTIME:COST'
);

wwv_flow_imp.component_end;
end;
/
