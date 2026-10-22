prompt --application/pages/page_00031
begin
--   Manifest
--     PAGE: 00031
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
 p_id=>31
,p_name=>'Supplier'
,p_alias=>'SUPPLIER'
,p_step_title=>'بيانات المورد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000166)
,p_plug_name=>'بيانات المورد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000167)
,p_name=>'P31_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000168)
,p_name=>'P31_PARTY'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000169)
,p_name=>'P31_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'اسم المورد'
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
 p_id=>wwv_flow_imp.id(91820268000000170)
,p_name=>'P31_NAME_EN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
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
 p_id=>wwv_flow_imp.id(91820268000000171)
,p_name=>'P31_PERSON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'نوع الطرف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:منشأة;N,فرد;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000172)
,p_name=>'P31_TYPE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'نوع المورد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بضائع;GOODS,خدمات;SERVICES,مقاول;CONTRACTOR,مقاول باطن;SUBCONTRACTOR,استشاري;CONSULTANT,خدمات عامة;UTILITY,جهة حكومية;GOVERNMENT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000173)
,p_name=>'P31_TAX'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'الرقم الضريبي (15 رقماً)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>15
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000174)
,p_name=>'P31_CR'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'السجل التجاري'
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
 p_id=>wwv_flow_imp.id(91820268000000175)
,p_name=>'P31_PHONE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'الجوال'
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
 p_id=>wwv_flow_imp.id(91820268000000176)
,p_name=>'P31_EMAIL'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'البريد الإلكتروني'
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
 p_id=>wwv_flow_imp.id(91820268000000177)
,p_name=>'P31_ADDRESS'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'العنوان'
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
 p_id=>wwv_flow_imp.id(91820268000000178)
,p_name=>'P31_TERM'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_prompt=>'شروط الدفع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, code r from ref_payment_term where is_active = ''Y'' order by due_days'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000179)
,p_name=>'P31_STATUS'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820268000000166)
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
 p_id=>wwv_flow_imp.id(91820268000000180)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    if :P31_ID is not null and :P31_NAME is null then',
'        l := noona_pur_pkg.supplier_json(:P31_ID);',
'        :P31_NAME := json_value(l, ''$.name''); :P31_NAME_EN := json_value(l, ''$.nameEn''); :P31_PERSON := json_value(l, ''$.person'');',
'        :P31_TYPE := json_value(l, ''$.type''); :P31_TAX := json_value(l, ''$.tax''); :P31_CR := json_value(l, ''$.cr'');',
'        :P31_PHONE := json_value(l, ''$.phone''); :P31_EMAIL := json_value(l, ''$.email''); :P31_ADDRESS := json_value(l, ''$.address'');',
'        :P31_TERM := json_value(l, ''$.term''); :P31_STATUS := json_value(l, ''$.status''); :P31_PARTY := json_value(l, ''$.party'');',
'    end if;',
'    :P31_TERM := nvl(:P31_TERM, ''NET30''); :P31_STATUS := nvl(:P31_STATUS, ''ACTIVE''); :P31_PERSON := nvl(:P31_PERSON, ''N'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820268000000180
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820268000000182)
,p_validation_name=>'P31_NAME required (SAVE)'
,p_validation_sequence=>15
,p_validation=>'P31_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820268000000181)
,p_associated_item=>wwv_flow_imp.id(91820268000000169)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000181)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000183)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820268000000166)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820268000000184)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P31_ID := noona_pur_pkg.save_supplier(json_object(',
'    ''id'' value to_number(:P31_ID), ''name'' value :P31_NAME, ''nameEn'' value :P31_NAME_EN, ''person'' value :P31_PERSON, ''type'' value :P31_TYPE,',
'    ''tax'' value :P31_TAX, ''cr'' value :P31_CR, ''phone'' value :P31_PHONE, ''email'' value :P31_EMAIL, ''address'' value :P31_ADDRESS,',
'    ''term'' value :P31_TERM, ''status'' value :P31_STATUS));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820268000000181)
,p_process_success_message=>'تم حفظ المورد'
,p_internal_uid=>91820268000000184
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000185)
,p_plug_name=>'مستندات المورد الإلزامية'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P31_PARTY is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dms_pkg.compliance_html(:P31_PARTY, ''SUPPLIER'');'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000186)
,p_plug_name=>'الفواتير المفتوحة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.invoice_id, o.doc_no, to_char(o.due_date, ''YYYY-MM-DD'') as due_date, o.original_amount, o.open_amount,',
'       greatest(trunc(sysdate) - o.due_date, 0) as days_late',
'  from ap_open_item o where o.supplier_account_id = :P31_ID and o.open_amount > 0 and o.item_type = ''INVOICE'' order by o.due_date'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الفواتير المفتوحة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820268000000187)
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
,p_detail_link=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.:RP,35:P35_ID:#INVOICE_ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820268000000187
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000189)
,p_db_column_name=>'INVOICE_ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000190)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الفاتورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000191)
,p_db_column_name=>'DUE_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الاستحقاق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000192)
,p_db_column_name=>'ORIGINAL_AMOUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000193)
,p_db_column_name=>'OPEN_AMOUNT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المتبقي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000194)
,p_db_column_name=>'DAYS_LATE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'أيام التأخير'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820268000000188)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'188'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DUE_DATE:ORIGINAL_AMOUNT:OPEN_AMOUNT:DAYS_LATE'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820268000000195)
,p_branch_action=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:31:P31_ID:&P31_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
