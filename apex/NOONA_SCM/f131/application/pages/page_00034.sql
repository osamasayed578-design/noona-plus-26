prompt --application/pages/page_00034
begin
--   Manifest
--     PAGE: 00034
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
 p_id=>34
,p_name=>'Purchase Invoices'
,p_alias=>'PURCHASES'
,p_step_title=>'فواتير المشتريات والمرتجعات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000219)
,p_plug_name=>'فواتير المشتريات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, i.doc_no, to_char(i.gl_date, ''YYYY-MM-DD'') as gl_date, case i.invoice_type when ''CREDIT_MEMO'' then ''مرتجع'' else ''فاتورة'' end as inv_type,',
'       noona_pur_pkg.supplier_label(i.supplier_account_id) as supplier, case when i.supplier_invoice_no not like ''#%'' then i.supplier_invoice_no end as sup_inv,',
'       noona_pur_pkg.mode_label(i.payment_mode) as pay_mode, i.subtotal, i.tax_amount, i.total_amount,',
'       (select sum(open_amount) from ap_open_item where invoice_id = i.id and item_type = ''INVOICE'') as open_amount,',
'       noona_ui_pkg.status_badge(i.status_code) as status_html',
'  from ap_invoice i where i.company_id = noona_pur_pkg.company order by i.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'فواتير المشتريات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820268000000220)
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
,p_detail_link=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.:RP,35:P35_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820268000000220
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000222)
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
 p_id=>wwv_flow_imp.id(91820268000000223)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000224)
,p_db_column_name=>'GL_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000225)
,p_db_column_name=>'INV_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000226)
,p_db_column_name=>'SUPPLIER'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المورد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000227)
,p_db_column_name=>'SUP_INV'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'فاتورة المورد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000228)
,p_db_column_name=>'PAY_MODE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000229)
,p_db_column_name=>'SUBTOTAL'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الصافي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000230)
,p_db_column_name=>'TAX_AMOUNT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الضريبة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000231)
,p_db_column_name=>'TOTAL_AMOUNT'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'الإجمالي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000232)
,p_db_column_name=>'OPEN_AMOUNT'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'المتبقي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000233)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820268000000221)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'221'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:GL_DATE:INV_TYPE:SUPPLIER:SUP_INV:PAY_MODE:SUBTOTAL:TAX_AMOUNT:TOTAL_AMOUNT:OPEN_AMOUNT:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000234)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820268000000219)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'فاتورة مشتريات جديدة'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.:RP,35::'
);

wwv_flow_imp.component_end;
end;
/
