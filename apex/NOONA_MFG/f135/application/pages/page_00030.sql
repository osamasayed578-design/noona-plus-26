prompt --application/pages/page_00030
begin
--   Manifest
--     PAGE: 00030
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
 p_id=>30
,p_name=>'Production Orders'
,p_alias=>'ORDERS'
,p_step_title=>'أوامر الإنتاج'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000123)
,p_plug_name=>'أوامر الإنتاج'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.id, o.doc_no, to_char(o.doc_date, ''YYYY-MM-DD'') as doc_date, noona_inv_pkg.item_label(o.item_id) as product,',
'       o.planned_qty, o.completed_qty, o.scrapped_qty, noona_mfg_pkg.order_progress(o.id) as progress,',
'       to_char(o.planned_start, ''YYYY-MM-DD'') as p_start, to_char(o.planned_end, ''YYYY-MM-DD'') as p_end,',
'       noona_mfg_pkg.priority_label(o.priority) as priority, o.estimated_cost, o.actual_cost,',
'       noona_mfg_pkg.wip_balance(o.id) as wip,',
'       ''<span class="nn-badge '' || case when o.status_code in (''COMPLETED'', ''CLOSED'') then ''is-success'' when o.status_code = ''CANCELLED'' then ''is-danger''',
'            when o.status_code = ''ON_HOLD'' or (o.planned_end < trunc(sysdate) and o.status_code not in (''COMPLETED'', ''CLOSED'')) then ''is-warning''',
'            when o.status_code in (''RELEASED'', ''IN_PROGRESS'', ''PARTIALLY_COMPLETED'') then ''is-info'' end || ''">''',
'            || noona_mfg_pkg.status_label(o.status_code) || ''</span>'' as status_html',
'  from mfg_production_order o where o.company_id = noona_mfg_pkg.company',
' order by o.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أوامر الإنتاج'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820270000000124)
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
,p_internal_uid=>91820270000000124
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000126)
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
 p_id=>wwv_flow_imp.id(91820270000000127)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'رقم الأمر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000128)
,p_db_column_name=>'DOC_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000129)
,p_db_column_name=>'PRODUCT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المنتج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000130)
,p_db_column_name=>'PLANNED_QTY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المخطط'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000131)
,p_db_column_name=>'COMPLETED_QTY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المقبول'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000132)
,p_db_column_name=>'SCRAPPED_QTY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الهالك'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000133)
,p_db_column_name=>'PROGRESS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الإنجاز %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000134)
,p_db_column_name=>'P_START'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'البداية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000135)
,p_db_column_name=>'P_END'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'النهاية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000136)
,p_db_column_name=>'PRIORITY'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الأولوية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000137)
,p_db_column_name=>'ESTIMATED_COST'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'التقديرية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000138)
,p_db_column_name=>'ACTUAL_COST'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الفعلية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000139)
,p_db_column_name=>'WIP'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'تحت التشغيل'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000140)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820270000000125)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'125'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DOC_DATE:PRODUCT:PLANNED_QTY:COMPLETED_QTY:SCRAPPED_QTY:PROGRESS:P_START:P_END:PRIORITY:ESTIMATED_COST:ACTUAL_COST:WIP:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000141)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000123)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'أمر إنتاج جديد'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31::'
);

wwv_flow_imp.component_end;
end;
/
