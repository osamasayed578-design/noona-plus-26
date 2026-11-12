prompt --application/pages/page_00063
begin
--   Manifest
--     PAGE: 00063
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
 p_id=>63
,p_name=>'Drivers-Report'
,p_alias=>'DRIVERS-REPORT'
,p_step_title=>'أداء السائقين'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000680)
,p_plug_name=>'أداء السائقين'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select d.full_name, d.license_expiry, count(t.id) trips, nvl(sum(t.actual_distance_km), 0) km,',
'       sum(case when noona_trn_pkg.timeliness(t.id) in (''ON_TIME'', ''EARLY'') then 1 else 0 end) on_time,',
'       round(sum(case when noona_trn_pkg.timeliness(t.id) in (''ON_TIME'', ''EARLY'') then 1 else 0 end) / nullif(count(t.id), 0) * 100) on_time_pct,',
'       (select count(*) from trn_incident i where i.driver_id = d.id) incidents,',
'       (select nvl(sum(o.shortage_qty), 0) from trn_trip_order x join trn_order o on o.id = x.order_id join trn_trip tt on tt.id = x.trip_id where tt.driver_id = d.id) shortage',
'  from trn_driver d left join trn_trip t on t.driver_id = d.id and t.status_code = ''COMPLETED''',
' where d.company_id = noona_trn_pkg.company group by d.id, d.full_name, d.license_expiry order by trips desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أداء السائقين'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000681)
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
,p_internal_uid=>91820290000000681
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000683)
,p_db_column_name=>'FULL_NAME'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'السائق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000684)
,p_db_column_name=>'LICENSE_EXPIRY'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'انتهاء الرخصة'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000685)
,p_db_column_name=>'TRIPS'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الرحلات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000686)
,p_db_column_name=>'KM'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الكيلومترات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000687)
,p_db_column_name=>'ON_TIME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'في الموعد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000688)
,p_db_column_name=>'ON_TIME_PCT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الالتزام %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000689)
,p_db_column_name=>'INCIDENTS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'البلاغات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000690)
,p_db_column_name=>'SHORTAGE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'العجز'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000682)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'682'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'FULL_NAME:LICENSE_EXPIRY:TRIPS:KM:ON_TIME:ON_TIME_PCT:INCIDENTS:SHORTAGE'
);

wwv_flow_imp.component_end;
end;
/
