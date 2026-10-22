prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
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
 p_id=>11
,p_name=>'Customer'
,p_alias=>'CUSTOMER'
,p_step_title=>'بيانات العميل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000037)
,p_plug_name=>'بيانات العميل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000038)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000039)
,p_name=>'P11_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'اسم العميل'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000040)
,p_name=>'P11_NAME_EN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'الاسم بالإنجليزية'
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
 p_id=>wwv_flow_imp.id(91820269000000041)
,p_name=>'P11_PERSON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'نوع العميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:فرد;Y,منشأة;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000042)
,p_name=>'P11_TAX'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'الرقم الضريبي (للفاتورة الضريبية)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>15
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
 p_id=>wwv_flow_imp.id(91820269000000043)
,p_name=>'P11_CR'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'السجل التجاري'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000044)
,p_name=>'P11_PHONE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
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
 p_id=>wwv_flow_imp.id(91820269000000045)
,p_name=>'P11_EMAIL'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'البريد الإلكتروني'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000046)
,p_name=>'P11_ADDRESS'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'العنوان'
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
 p_id=>wwv_flow_imp.id(91820269000000047)
,p_name=>'P11_TERM'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'شروط الدفع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, code r from ref_payment_term where is_active = ''Y'' order by due_days'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000048)
,p_name=>'P11_LIMIT'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'حد الائتمان (فارغ = بلا حد)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000049)
,p_name=>'P11_STATUS'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,موقوف مؤقتاً;ON_HOLD,محظور;BLOCKED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000050)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    if :P11_ID is not null and :P11_NAME is null then',
'        l := noona_sal_pkg.customer_json(:P11_ID);',
'        :P11_NAME := json_value(l, ''$.name''); :P11_NAME_EN := json_value(l, ''$.nameEn''); :P11_PERSON := json_value(l, ''$.person'');',
'        :P11_TAX := json_value(l, ''$.tax''); :P11_CR := json_value(l, ''$.cr''); :P11_PHONE := json_value(l, ''$.phone'');',
'        :P11_EMAIL := json_value(l, ''$.email''); :P11_ADDRESS := json_value(l, ''$.address''); :P11_TERM := json_value(l, ''$.term'');',
'        :P11_LIMIT := json_value(l, ''$.limit''); :P11_STATUS := json_value(l, ''$.status'');',
'    end if;',
'    :P11_TERM := nvl(:P11_TERM, ''NET30''); :P11_STATUS := nvl(:P11_STATUS, ''ACTIVE''); :P11_PERSON := nvl(:P11_PERSON, ''Y'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000050
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820269000000052)
,p_validation_name=>'P11_NAME required (SAVE)'
,p_validation_sequence=>14
,p_validation=>'P11_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820269000000051)
,p_associated_item=>wwv_flow_imp.id(91820269000000039)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000051)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000053)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820269000000037)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000054)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P11_ID := noona_sal_pkg.save_customer(json_object(',
'    ''id'' value to_number(:P11_ID), ''name'' value :P11_NAME, ''nameEn'' value :P11_NAME_EN, ''person'' value :P11_PERSON, ''tax'' value :P11_TAX,',
'    ''cr'' value :P11_CR, ''phone'' value :P11_PHONE, ''email'' value :P11_EMAIL, ''address'' value :P11_ADDRESS, ''term'' value :P11_TERM,',
'    ''limit'' value to_number(:P11_LIMIT), ''status'' value :P11_STATUS));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820269000000051)
,p_process_success_message=>'تم حفظ العميل'
,p_internal_uid=>91820269000000054
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000055)
,p_plug_name=>'الذمم المفتوحة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.source_entity_type, o.source_entity_id, o.doc_no, to_char(o.due_date, ''YYYY-MM-DD'') as due_date, o.original_amount, o.open_amount,',
'       greatest(trunc(sysdate) - o.due_date, 0) as days_late',
'  from ar_open_item o where o.customer_account_id = :P11_ID and o.open_amount > 0 and o.item_type = ''INVOICE'' order by o.due_date'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الذمم المفتوحة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820269000000056)
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
,p_internal_uid=>91820269000000056
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000058)
,p_db_column_name=>'SOURCE_ENTITY_TYPE'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000059)
,p_db_column_name=>'SOURCE_ENTITY_ID'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000060)
,p_db_column_name=>'DOC_NO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000061)
,p_db_column_name=>'DUE_DATE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الاستحقاق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000062)
,p_db_column_name=>'ORIGINAL_AMOUNT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000063)
,p_db_column_name=>'OPEN_AMOUNT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المتبقي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000064)
,p_db_column_name=>'DAYS_LATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'أيام التأخير'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820269000000057)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'57'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DUE_DATE:ORIGINAL_AMOUNT:OPEN_AMOUNT:DAYS_LATE'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820269000000065)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:11:P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
