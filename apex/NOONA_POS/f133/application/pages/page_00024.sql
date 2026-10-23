prompt --application/pages/page_00024
begin
--   Manifest
--     PAGE: 00024
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
 p_id=>24
,p_name=>'Receive'
,p_alias=>'RECEIVE'
,p_step_title=>'تحصيل من عميل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000125)
,p_plug_name=>'التحصيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000126)
,p_name=>'P24_CUST'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820269000000125)
,p_prompt=>'العميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select c.customer_no || '' - '' || p.display_name_ar d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id join pty_party p on p.id = c.party_id where a.company_id = noona_sal_pkg.company order by c.is_walk_in desc, p.display_name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000127)
,p_name=>'P24_DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820269000000125)
,p_prompt=>'التاريخ'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000128)
,p_name=>'P24_AMOUNT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820269000000125)
,p_prompt=>'المبلغ'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000129)
,p_name=>'P24_PLACE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820269000000125)
,p_prompt=>'التحصيل في'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d, r from (select ''صندوق: '' || name_ar d, ''BOX:'' || id r, 1 o from csh_cash_box where company_id = noona_gl_pkg.company and status_code = ''ACTIVE'' union all select ''بنك: '' || name_ar || '' '' || account_no_masked, ''BANK:'' || id, 2 from csh_bank_account where company_id = noona_gl_pkg.company and status_code = ''ACTIVE'') order by o, d'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000130)
,p_name=>'P24_METHOD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820269000000125)
,p_prompt=>'طريقة الدفع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, code r from ref_payment_method where is_active = ''Y'' and method_type <> ''CREDIT'' order by sort_order'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000131)
,p_name=>'P24_REF'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820269000000125)
,p_prompt=>'المرجع (رقم العملية / الشيك)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000132)
,p_name=>'P24_NOTES'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820269000000125)
,p_prompt=>'البيان'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000133)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P24_DATE := nvl(:P24_DATE, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000133
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820269000000135)
,p_validation_name=>'P24_CUST required (RECEIVE)'
,p_validation_sequence=>9
,p_validation=>'P24_CUST'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820269000000134)
,p_associated_item=>wwv_flow_imp.id(91820269000000126)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820269000000136)
,p_validation_name=>'P24_AMOUNT required (RECEIVE)'
,p_validation_sequence=>10
,p_validation=>'P24_AMOUNT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820269000000134)
,p_associated_item=>wwv_flow_imp.id(91820269000000128)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820269000000137)
,p_validation_name=>'P24_PLACE required (RECEIVE)'
,p_validation_sequence=>11
,p_validation=>'P24_PLACE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820269000000134)
,p_associated_item=>wwv_flow_imp.id(91820269000000129)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000134)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000125)
,p_button_name=>'RECEIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تنفيذ التحصيل (يخصص على الأقدم استحقاقاً)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000138)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Receive'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_sal_pkg.receive(json_object(''cust'' value to_number(:P24_CUST), ''date'' value :P24_DATE, ''amount'' value to_number(:P24_AMOUNT),',
'        ''place'' value :P24_PLACE, ''method'' value :P24_METHOD, ''ref'' value :P24_REF, ''notes'' value :P24_NOTES));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820269000000134)
,p_process_success_message=>'تم التحصيل وترحيل القيد وتحديث رصيد الصندوق أو البنك'
,p_internal_uid=>91820269000000138
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000139)
,p_plug_name=>'الذمم المفتوحة للعميل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.doc_no, to_char(o.due_date, ''YYYY-MM-DD'') as due_date, o.original_amount, o.open_amount, greatest(trunc(sysdate) - o.due_date, 0) as days_late',
'  from ar_open_item o where o.customer_account_id = :P24_CUST and o.open_amount > 0 and o.item_type = ''INVOICE'' order by o.due_date'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الذمم المفتوحة للعميل'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820269000000140)
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
,p_internal_uid=>91820269000000140
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000142)
,p_db_column_name=>'DOC_NO'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000143)
,p_db_column_name=>'DUE_DATE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الاستحقاق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000144)
,p_db_column_name=>'ORIGINAL_AMOUNT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000145)
,p_db_column_name=>'OPEN_AMOUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المتبقي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000146)
,p_db_column_name=>'DAYS_LATE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'أيام التأخير'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820269000000141)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'141'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DUE_DATE:ORIGINAL_AMOUNT:OPEN_AMOUNT:DAYS_LATE'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820269000000147)
,p_branch_action=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
