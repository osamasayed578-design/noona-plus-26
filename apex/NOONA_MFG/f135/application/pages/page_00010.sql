prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
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
 p_id=>10
,p_name=>'Work Centers'
,p_alias=>'WORK-CENTERS'
,p_step_title=>'مراكز العمل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000048)
,p_plug_name=>'مراكز العمل'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select w.id, w.code, w.name_ar, w.capacity_hours_day, w.labor_rate, w.machine_rate, w.overhead_rate,',
'       w.labor_rate + w.machine_rate + w.overhead_rate as total_rate,',
'       (select code || '' - '' || name_ar from gl_cost_center where id = w.cost_center_id) as cost_center,',
'       (select count(*) from mfg_order_operation p where p.work_center_id = w.id and p.status_code in (''PENDING'', ''IN_PROGRESS'')) as open_ops,',
'       case w.is_active when ''Y'' then ''نشط'' else ''موقوف'' end as active',
'  from mfg_work_center w where w.company_id = noona_mfg_pkg.company order by w.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مراكز العمل'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820270000000049)
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
,p_detail_link=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11:P11_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820270000000049
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000051)
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
 p_id=>wwv_flow_imp.id(91820270000000052)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000053)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'مركز العمل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000054)
,p_db_column_name=>'CAPACITY_HOURS_DAY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الطاقة اليومية (ساعة)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000055)
,p_db_column_name=>'LABOR_RATE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'العمالة/ساعة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000056)
,p_db_column_name=>'MACHINE_RATE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الآلات/ساعة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000057)
,p_db_column_name=>'OVERHEAD_RATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'التحميل/ساعة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000058)
,p_db_column_name=>'TOTAL_RATE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'إجمالي المعدل'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000059)
,p_db_column_name=>'COST_CENTER'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'مركز التكلفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000060)
,p_db_column_name=>'OPEN_OPS'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'عمليات مفتوحة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000061)
,p_db_column_name=>'ACTIVE'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820270000000050)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'50'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:CAPACITY_HOURS_DAY:LABOR_RATE:MACHINE_RATE:OVERHEAD_RATE:TOTAL_RATE:COST_CENTER:OPEN_OPS:ACTIVE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000062)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000048)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مركز عمل جديد'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11::'
);

wwv_flow_imp.component_end;
end;
/
