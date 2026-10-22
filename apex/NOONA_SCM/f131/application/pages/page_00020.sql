prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>131
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>'Stock Documents'
,p_alias=>'STOCK-DOCS'
,p_step_title=>'حركات ومستندات المخزون'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000126)
,p_plug_name=>'حركات المخزون'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.id, t.doc_no, to_char(t.doc_date, ''YYYY-MM-DD'') as doc_date, y.name_ar as txn_type, w.name_ar as warehouse,',
'       (select name_ar from inv_warehouse where id = t.to_warehouse_id) as to_warehouse, t.reason_code, t.source_entity_type,',
'       (select sum(abs(l.total_cost)) from inv_transaction_line l where l.transaction_id = t.id) as total_value,',
'       noona_ui_pkg.status_badge(t.status_code) as status_html',
'  from inv_transaction t join inv_txn_type y on y.id = t.txn_type_id join inv_warehouse w on w.id = t.warehouse_id',
' where t.company_id = noona_inv_pkg.company order by t.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'حركات المخزون'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820268000000127)
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
,p_detail_link=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820268000000127
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000129)
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
 p_id=>wwv_flow_imp.id(91820268000000130)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000131)
,p_db_column_name=>'DOC_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000132)
,p_db_column_name=>'TXN_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الحركة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000133)
,p_db_column_name=>'WAREHOUSE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المستودع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000134)
,p_db_column_name=>'TO_WAREHOUSE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'إلى مستودع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000135)
,p_db_column_name=>'REASON_CODE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'السبب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000136)
,p_db_column_name=>'SOURCE_ENTITY_TYPE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000137)
,p_db_column_name=>'TOTAL_VALUE'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'القيمة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000138)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820268000000128)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'128'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DOC_DATE:TXN_TYPE:WAREHOUSE:TO_WAREHOUSE:REASON_CODE:SOURCE_ENTITY_TYPE:TOTAL_VALUE:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000139)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820268000000126)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مستند مخزون جديد'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21::'
);

wwv_flow_imp.component_end;
end;
/
