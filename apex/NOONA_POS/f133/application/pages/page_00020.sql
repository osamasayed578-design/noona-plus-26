prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>'Sales Invoices'
,p_alias=>'INVOICES'
,p_step_title=>'فواتير المبيعات والمرتجعات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000066)
,p_plug_name=>'فواتير المبيعات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, i.doc_no, to_char(i.doc_date, ''YYYY-MM-DD'') as doc_date,',
'       case i.doc_type when ''CREDIT_NOTE'' then ''مرتجع'' when ''INVOICE'' then ''ضريبية'' else ''مبسطة'' end as doc_type,',
'       i.customer_name_snapshot as customer, noona_sal_pkg.mode_label(i.payment_mode) as pay_mode, i.subtotal, i.tax_amount, i.total_amount,',
'       i.subtotal - i.cogs_amount as gross_profit,',
'       (select sum(open_amount) from ar_open_item where source_entity_type = ''SAL_INVOICE'' and source_entity_id = i.id) as open_amount,',
'       noona_ui_pkg.status_badge(i.status_code) as status_html',
'  from sal_invoice i where i.company_id = noona_sal_pkg.company order by i.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'فواتير المبيعات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820269000000067)
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
,p_internal_uid=>91820269000000067
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000069)
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
 p_id=>wwv_flow_imp.id(91820269000000070)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000071)
,p_db_column_name=>'DOC_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000072)
,p_db_column_name=>'DOC_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000073)
,p_db_column_name=>'CUSTOMER'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'العميل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000074)
,p_db_column_name=>'PAY_MODE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000075)
,p_db_column_name=>'SUBTOTAL'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الصافي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000076)
,p_db_column_name=>'TAX_AMOUNT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الضريبة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000077)
,p_db_column_name=>'TOTAL_AMOUNT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الإجمالي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000078)
,p_db_column_name=>'GROSS_PROFIT'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'مجمل الربح'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000079)
,p_db_column_name=>'OPEN_AMOUNT'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'المتبقي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000080)
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
 p_id=>wwv_flow_imp.id(91820269000000068)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'68'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DOC_DATE:DOC_TYPE:CUSTOMER:PAY_MODE:SUBTOTAL:TAX_AMOUNT:TOTAL_AMOUNT:GROSS_PROFIT:OPEN_AMOUNT:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000081)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000066)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'فاتورة مبيعات جديدة'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21::'
);

wwv_flow_imp.component_end;
end;
/
