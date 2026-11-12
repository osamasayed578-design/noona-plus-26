prompt --application/pages/page_00055
begin
--   Manifest
--     PAGE: 00055
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
 p_id=>55
,p_name=>'Invoicing'
,p_alias=>'INVOICING'
,p_step_title=>'فوترة الترحيل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000622)
,p_plug_name=>'الفوترة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">اختر العميل ثم أوامر الشحن المسلمة: تصدر فاتورة مبيعات آجلة مرحلة على حساب إيرادات النقل (4170) وتظهر في ذمة العميل والإقرار الضريبي.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000623)
,p_name=>'P55_CUST'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000622)
,p_prompt=>'العميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_sal_pkg.customer_label(o.customer_account_id) || '' ('' || count(*) || '' أمر)'' d, o.customer_account_id r from trn_order o where o.company_id = noona_trn_pkg.company and o.status_code = ''DELIVERED'' group by o.customer_account_id order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000624)
,p_name=>'P55_ORDERS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000622)
,p_prompt=>'الأوامر المسلمة'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'select noona_trn_pkg.order_label(o.id) || '' · '' || to_char(o.total_amount, ''FM999G999G990D00'') d, o.id r from trn_order o where o.company_id = noona_trn_pkg.company and o.status_code = ''DELIVERED'' and o.customer_account_id = :P55_CUST order by o.id'
,p_lov_cascade_parent_items=>'P55_CUST'
,p_ajax_items_to_submit=>'P55_CUST'
,p_ajax_optimize_refresh=>'Y'
,p_lov_columns=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000625)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000622)
,p_button_name=>'INVOICE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إصدار الفاتورة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000626)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Invoice'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'  l := noona_trn_pkg.invoice_orders(replace(:P55_ORDERS, '':'', '',''));',
'  :P55_INV := l;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000625)
,p_process_success_message=>'صدرت فاتورة الترحيل ورحلت'
,p_internal_uid=>91820290000000626
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000627)
,p_name=>'P55_INV'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000622)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000628)
,p_plug_name=>'أوامر مفوترة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.id, o.doc_no, noona_sal_pkg.customer_label(o.customer_account_id) customer, o.total_amount, i.doc_no invoice_no, i.doc_date invoice_date',
'  from trn_order o join sal_invoice i on i.id = o.sales_invoice_id where o.company_id = noona_trn_pkg.company and o.status_code = ''INVOICED'' order by o.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أوامر مفوترة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000629)
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
,p_internal_uid=>91820290000000629
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000631)
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
 p_id=>wwv_flow_imp.id(91820290000000632)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الأمر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000633)
,p_db_column_name=>'CUSTOMER'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'العميل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000634)
,p_db_column_name=>'TOTAL_AMOUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الترحيل'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000635)
,p_db_column_name=>'INVOICE_NO'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الفاتورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000636)
,p_db_column_name=>'INVOICE_DATE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'تاريخ الفاتورة'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000630)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'630'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:CUSTOMER:TOTAL_AMOUNT:INVOICE_NO:INVOICE_DATE'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000637)
,p_branch_action=>'f?p=&APP_ID.:55:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
