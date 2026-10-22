prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>135
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>22
,p_name=>'Routings'
,p_alias=>'ROUTINGS'
,p_step_title=>'مسارات التصنيع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000105)
,p_plug_name=>'مسارات التصنيع'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, noona_inv_pkg.item_label(r.item_id) as product, r.version_no, r.name_ar,',
'       (select count(*) from mfg_routing_operation o where o.routing_id = r.id) as ops,',
'       (select sum(o.run_minutes_per_unit) from mfg_routing_operation o where o.routing_id = r.id) as run_minutes,',
'       (select sum(o.setup_minutes) from mfg_routing_operation o where o.routing_id = r.id) as setup_minutes,',
'       noona_mfg_pkg.routing_in_use(r.id) as in_use,',
'       ''<span class="nn-badge '' || case r.status_code when ''PUBLISHED'' then ''is-success'' when ''OBSOLETE'' then ''is-danger'' end || ''">''',
'            || noona_mfg_pkg.status_label(r.status_code) || ''</span>'' as status_html',
'  from mfg_routing r where r.company_id = noona_mfg_pkg.company order by r.code, r.version_no desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مسارات التصنيع'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820270000000106)
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
,p_detail_link=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:RP,23:P23_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820270000000106
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000108)
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
 p_id=>wwv_flow_imp.id(91820270000000109)
,p_db_column_name=>'PRODUCT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المنتج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000110)
,p_db_column_name=>'VERSION_NO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الإصدار'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000111)
,p_db_column_name=>'NAME_AR'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الاسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000112)
,p_db_column_name=>'OPS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'العمليات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000113)
,p_db_column_name=>'RUN_MINUTES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'دقائق التشغيل للوحدة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000114)
,p_db_column_name=>'SETUP_MINUTES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'دقائق الإعداد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000115)
,p_db_column_name=>'IN_USE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'مستخدم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000116)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820270000000107)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'107'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PRODUCT:VERSION_NO:NAME_AR:OPS:RUN_MINUTES:SETUP_MINUTES:IN_USE:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000117)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000105)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مسار جديد'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:RP,23::'
);

wwv_flow_imp.component_end;
end;
/
