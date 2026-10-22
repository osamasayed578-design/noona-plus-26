prompt --application/pages/page_00035
begin
--   Manifest
--     PAGE: 00035
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
 p_id=>35
,p_name=>'Quality'
,p_alias=>'QUALITY'
,p_step_title=>'فحوصات الجودة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000158)
,p_plug_name=>'فحوصات الجودة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select q.order_id as id, o.doc_no, noona_inv_pkg.item_label(o.item_id) as product, t.lot_no, q.inspected_qty, q.passed_qty, q.failed_qty,',
'       case when q.status_code <> ''PENDING'' and q.inspected_qty > 0 then round(q.passed_qty / q.inspected_qty * 100, 1) end as pass_rate,',
'       to_char(q.inspection_date, ''YYYY-MM-DD'') as inspection_date, q.notes,',
'       ''<span class="nn-badge '' || case q.status_code when ''PASSED'' then ''is-success'' when ''FAILED'' then ''is-danger'' else ''is-warning'' end || ''">''',
'            || noona_mfg_pkg.status_label(q.status_code) || ''</span>'' as status_html',
'  from mfg_quality_inspection q join mfg_production_order o on o.id = q.order_id left join mfg_order_output t on t.id = q.output_id',
' where q.company_id = noona_mfg_pkg.company order by decode(q.status_code, ''PENDING'', 0, 1), q.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'فحوصات الجودة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820270000000159)
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
,p_internal_uid=>91820270000000159
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000161)
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
 p_id=>wwv_flow_imp.id(91820270000000162)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'أمر الإنتاج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000163)
,p_db_column_name=>'PRODUCT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المنتج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000164)
,p_db_column_name=>'LOT_NO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الدفعة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000165)
,p_db_column_name=>'INSPECTED_QTY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المفحوص'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000166)
,p_db_column_name=>'PASSED_QTY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المقبول'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000167)
,p_db_column_name=>'FAILED_QTY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المرفوض'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000168)
,p_db_column_name=>'PASS_RATE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'نسبة القبول %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000169)
,p_db_column_name=>'INSPECTION_DATE'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000170)
,p_db_column_name=>'NOTES'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'ملاحظات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000171)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'النتيجة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820270000000160)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'160'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:PRODUCT:LOT_NO:INSPECTED_QTY:PASSED_QTY:FAILED_QTY:PASS_RATE:INSPECTION_DATE:NOTES:STATUS_HTML'
);

wwv_flow_imp.component_end;
end;
/
