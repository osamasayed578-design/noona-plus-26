prompt --application/pages/page_00030
begin
--   Manifest
--     PAGE: 00030
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
 p_id=>30
,p_name=>'Suppliers'
,p_alias=>'SUPPLIERS'
,p_step_title=>'الموردون'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000152)
,p_plug_name=>'الموردون'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select a.id, s.supplier_no, p.display_name_ar as name_ar, p.tax_number,',
'       (select max(mobile) from ref_contact where party_id = p.id and is_primary = ''Y'') as phone,',
'       (select name_ar from ref_payment_term where id = a.payment_term_id) as term,',
'       noona_pur_pkg.supplier_balance(a.id) as balance,',
'       (select nvl(sum(open_amount), 0) from ap_open_item o where o.supplier_account_id = a.id and o.item_type = ''INVOICE''',
'           and o.due_date < trunc(sysdate)) as overdue,',
'       case a.required_docs_ok when ''Y'' then ''مكتملة'' else ''ناقصة'' end as docs, noona_ui_pkg.status_badge(a.status_code) as status_html',
'  from ap_supplier_account a join ap_supplier s on s.id = a.supplier_id join pty_party p on p.id = s.party_id',
' where a.company_id = noona_pur_pkg.company'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الموردون'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820268000000153)
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
,p_internal_uid=>91820268000000153
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000155)
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
 p_id=>wwv_flow_imp.id(91820268000000156)
,p_db_column_name=>'SUPPLIER_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'رقم المورد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000157)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المورد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000158)
,p_db_column_name=>'TAX_NUMBER'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الرقم الضريبي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000159)
,p_db_column_name=>'PHONE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الجوال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000160)
,p_db_column_name=>'TERM'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'شروط الدفع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000161)
,p_db_column_name=>'BALANCE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الرصيد المستحق'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000162)
,p_db_column_name=>'OVERDUE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المتأخر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000163)
,p_db_column_name=>'DOCS'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'المستندات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000164)
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
 p_id=>wwv_flow_imp.id(91820268000000154)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'154'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'SUPPLIER_NO:NAME_AR:TAX_NUMBER:PHONE:TERM:BALANCE:OVERDUE:DOCS:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000165)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820268000000152)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مورد جديد'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31::'
);

wwv_flow_imp.component_end;
end;
/
