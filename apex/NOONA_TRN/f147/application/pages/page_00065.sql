prompt --application/pages/page_00065
begin
--   Manifest
--     PAGE: 00065
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
 p_id=>65
,p_name=>'Customers-Report'
,p_alias=>'CUSTOMERS-REPORT'
,p_step_title=>'الترحيل حسب العملاء والمسارات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000536)
,p_plug_name=>'الترحيل حسب العملاء والمسارات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select noona_sal_pkg.customer_label(o.customer_account_id) customer, f.name_ar || '' ← '' || t.name_ar route, count(*) orders,',
'       round(sum(o.weight_kg) / 1000, 2) tons, sum(o.total_amount) freight, nvl(sum(o.shortage_qty), 0) shortage,',
'       sum(case when o.status_code = ''INVOICED'' then o.total_amount else 0 end) invoiced,',
'       sum(case when o.status_code = ''DELIVERED'' then o.total_amount else 0 end) not_invoiced',
'  from trn_order o join trn_location f on f.id = o.from_location_id join trn_location t on t.id = o.to_location_id',
' where o.company_id = noona_trn_pkg.company and o.status_code not in (''DRAFT'', ''CANCELLED'')',
' group by o.customer_account_id, f.name_ar, t.name_ar order by freight desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الترحيل حسب العملاء والمسارات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000537)
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
,p_internal_uid=>91820290000000537
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000539)
,p_db_column_name=>'CUSTOMER'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'العميل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000540)
,p_db_column_name=>'ROUTE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المسار'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000541)
,p_db_column_name=>'ORDERS'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الأوامر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000542)
,p_db_column_name=>'TONS'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الأطنان'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000543)
,p_db_column_name=>'FREIGHT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الترحيل'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000544)
,p_db_column_name=>'SHORTAGE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'العجز'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000545)
,p_db_column_name=>'INVOICED'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المفوتر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000546)
,p_db_column_name=>'NOT_INVOICED'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'غير المفوتر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000538)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'538'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CUSTOMER:ROUTE:ORDERS:TONS:FREIGHT:SHORTAGE:INVOICED:NOT_INVOICED'
);

wwv_flow_imp.component_end;
end;
/
