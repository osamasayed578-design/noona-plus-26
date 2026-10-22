prompt --application/pages/page_00023
begin
--   Manifest
--     PAGE: 00023
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
 p_id=>23
,p_name=>'Receipts'
,p_alias=>'RECEIPTS'
,p_step_title=>'التحصيل من العملاء'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000103)
,p_plug_name=>'التحصيلات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select y.id, y.doc_no, to_char(y.doc_date, ''YYYY-MM-DD'') as doc_date, noona_sal_pkg.customer_label(y.customer_account_id) as customer,',
'       (select name_ar from ref_payment_method where id = y.payment_method_id) as method, y.external_reference,',
'       nvl((select ''صندوق: '' || name_ar from csh_cash_box where id = y.cash_box_id), (select ''بنك: '' || name_ar from csh_bank_account where id = y.bank_account_id)) as place,',
'       y.amount, y.unapplied_amount, noona_ui_pkg.status_badge(y.status_code) as status_html',
'  from ar_receipt y where y.company_id = noona_sal_pkg.company order by y.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'التحصيلات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820269000000104)
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
,p_internal_uid=>91820269000000104
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000106)
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
 p_id=>wwv_flow_imp.id(91820269000000107)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000108)
,p_db_column_name=>'DOC_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000109)
,p_db_column_name=>'CUSTOMER'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'العميل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000110)
,p_db_column_name=>'METHOD'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000111)
,p_db_column_name=>'EXTERNAL_REFERENCE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المرجع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000112)
,p_db_column_name=>'PLACE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000113)
,p_db_column_name=>'AMOUNT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000114)
,p_db_column_name=>'UNAPPLIED_AMOUNT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'دفعة مقدمة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000115)
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
 p_id=>wwv_flow_imp.id(91820269000000105)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'105'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DOC_DATE:CUSTOMER:METHOD:EXTERNAL_REFERENCE:PLACE:AMOUNT:UNAPPLIED_AMOUNT:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000116)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000103)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تحصيل جديد'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:24:&SESSION.::&DEBUG.:RP,24::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000117)
,p_plug_name=>'عكس تحصيل (شيك مرتد أو خطأ)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000118)
,p_name=>'P23_RCP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820269000000117)
,p_prompt=>'التحصيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select doc_no || '' - '' || noona_sal_pkg.customer_label(customer_account_id) || '' - '' || amount d, id r from ar_receipt where company_id = noona_sal_pkg.company and status_code = ''CONFIRMED'' order by id desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000119)
,p_name=>'P23_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820269000000117)
,p_prompt=>'السبب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820269000000121)
,p_validation_name=>'P23_REASON required (REVERSE)'
,p_validation_sequence=>16
,p_validation=>'P23_REASON'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820269000000120)
,p_associated_item=>wwv_flow_imp.id(91820269000000119)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000120)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000117)
,p_button_name=>'REVERSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عكس التحصيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000122)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reverse'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_sal_pkg.reverse_receipt(:P23_RCP, trunc(sysdate), :P23_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820269000000120)
,p_process_success_message=>'تم عكس التحصيل وإعادة فتح الذمم'
,p_internal_uid=>91820269000000122
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820269000000123)
,p_branch_action=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:23::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
