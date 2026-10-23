prompt --application/pages/page_00033
begin
--   Manifest
--     PAGE: 00033
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>141
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>33
,p_name=>'Prescription'
,p_alias=>'PRESCRIPTION'
,p_step_title=>'Prescription - الوصفة الطبية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(''#P33_INSTR,[id^=P33_DOSE],[id^=P33_FREQ]'').attr(''dir'', ''ltr'');'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000532)
,p_plug_name=>'Prescription'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000533)
,p_name=>'P33_VISIT'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Visit'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select v.visit_no || '' - '' || p.name_ar || '' ('' || p.mrn || '')'' d, v.id r from his_visit v join his_patient p on p.id = v.patient_id where v.company_id = noona_his_pkg.company and v.status_code = ''OPEN'' order by v.visit_at desc'
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
 p_id=>wwv_flow_imp.id(91820275000000534)
,p_name=>'P33_D1'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Medicine 1'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(i.name_en, i.name_ar) || '' ('' || to_char(c.sale_price, ''FM999G990D00'') || '')'' d, i.id r from inv_item i join inv_item_company c on c.item_id = i.id and c.company_id = noona_his_pkg.company where i.item_type not in (''SERVICE'', ''NON_STOCK'') and i.status_code = ''ACTIVE'' and i.is_sellable = ''Y'' and c.sale_price is not null order by nvl(i.name_en, i.name_ar)'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'-'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000535)
,p_name=>'P33_Q1'
,p_item_sequence=>11
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Qty 1'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000536)
,p_name=>'P33_DOSE1'
,p_item_sequence=>12
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Dose 1 (e.g. 500 mg)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
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
 p_id=>wwv_flow_imp.id(91820275000000537)
,p_name=>'P33_FREQ1'
,p_item_sequence=>13
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Frequency 1 (e.g. TID)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000538)
,p_name=>'P33_DAYS1'
,p_item_sequence=>14
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Days 1'
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
 p_id=>wwv_flow_imp.id(91820275000000539)
,p_name=>'P33_D2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Medicine 2'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(i.name_en, i.name_ar) || '' ('' || to_char(c.sale_price, ''FM999G990D00'') || '')'' d, i.id r from inv_item i join inv_item_company c on c.item_id = i.id and c.company_id = noona_his_pkg.company where i.item_type not in (''SERVICE'', ''NON_STOCK'') and i.status_code = ''ACTIVE'' and i.is_sellable = ''Y'' and c.sale_price is not null order by nvl(i.name_en, i.name_ar)'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'-'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000540)
,p_name=>'P33_Q2'
,p_item_sequence=>21
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Qty 2'
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
 p_id=>wwv_flow_imp.id(91820275000000541)
,p_name=>'P33_DOSE2'
,p_item_sequence=>22
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Dose 2 (e.g. 500 mg)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000542)
,p_name=>'P33_FREQ2'
,p_item_sequence=>23
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Frequency 2 (e.g. TID)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
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
 p_id=>wwv_flow_imp.id(91820275000000543)
,p_name=>'P33_DAYS2'
,p_item_sequence=>24
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Days 2'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000544)
,p_name=>'P33_D3'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Medicine 3'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(i.name_en, i.name_ar) || '' ('' || to_char(c.sale_price, ''FM999G990D00'') || '')'' d, i.id r from inv_item i join inv_item_company c on c.item_id = i.id and c.company_id = noona_his_pkg.company where i.item_type not in (''SERVICE'', ''NON_STOCK'') and i.status_code = ''ACTIVE'' and i.is_sellable = ''Y'' and c.sale_price is not null order by nvl(i.name_en, i.name_ar)'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'-'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000545)
,p_name=>'P33_Q3'
,p_item_sequence=>31
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Qty 3'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000546)
,p_name=>'P33_DOSE3'
,p_item_sequence=>32
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Dose 3 (e.g. 500 mg)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
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
 p_id=>wwv_flow_imp.id(91820275000000547)
,p_name=>'P33_FREQ3'
,p_item_sequence=>33
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Frequency 3 (e.g. TID)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000548)
,p_name=>'P33_DAYS3'
,p_item_sequence=>34
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Days 3'
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
 p_id=>wwv_flow_imp.id(91820275000000549)
,p_name=>'P33_INSTR'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Instructions (e.g. after meals)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000550)
,p_name=>'P33_VALID'
,p_item_sequence=>55
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_prompt=>'Valid for (days, default 30)'
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
 p_id=>wwv_flow_imp.id(91820275000000551)
,p_name=>'P33_RX'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000000553)
,p_validation_name=>'P33_VISIT required (PRESCRIBE)'
,p_validation_sequence=>20
,p_validation=>'P33_VISIT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000000552)
,p_associated_item=>wwv_flow_imp.id(91820275000000533)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000552)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_button_name=>'PRESCRIBE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Prescribe'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000554)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Prescribe'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l_lines clob;',
'begin',
'    select json_arrayagg(x.l format json returning clob) into l_lines from (select case when :P33_D1 is not null then json_object(''i'' value to_number(:P33_D1), ''q'' value to_number(:P33_Q1), ''dose'' value :P33_DOSE1, ''freq'' value :P33_FREQ1, ''days'' value to_number(:P33_DAYS1), ''instr'' value :P33_INSTR) end l from dual union all select case when :P33_D2 is not null then json_object(''i'' value to_number(:P33_D2), ''q'' value to_number(:P33_Q2), ''dose'' value :P33_DOSE2, ''freq'' value :P33_FREQ2, ''days'' value to_number(:P33_DAYS2), ''instr'' value :P33_INSTR) end from dual union all select case when :P33_D3 is not null then json_object(''i'' value to_number(:P33_D3), ''q'' value to_number(:P33_Q3), ''dose'' value :P33_DOSE3, ''freq'' value :P33_FREQ3, ''days'' value to_number(:P33_DAYS3), ''instr'' value :P33_INSTR) end from dual) x where x.l is not null;',
'    select json_object(''visit'' value to_number(:P33_VISIT), ''valid_days'' value to_number(:P33_VALID),',
'           ''lines'' value nvl(l_lines, to_clob(''[]'')) format json returning clob) into l_doc from dual;',
'    :P33_RX := noona_his_care_pkg.prescribe(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000552)
,p_process_success_message=>'Prescription sent - أرسلت الوصفة (الصرف من صيدلية المستشفى اختياري)'
,p_internal_uid=>91820275000000554
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000555)
,p_plug_name=>'Prescriptions of the visit'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select x.id, x.rx_no, to_char(x.rx_at, ''YYYY-MM-DD HH24:MI'') as rx_at, nvl(i.name_en, i.name_ar) as medicine, l.dose, l.frequency, l.duration_days,',
'       l.quantity, l.dispensed_qty, case x.status_code when ''ACTIVE'' then ''Sent'' when ''PARTIAL'' then ''Partial'' when ''DISPENSED'' then ''Dispensed''',
'       when ''EXTERNAL'' then ''Outside pharmacy'' when ''EXPIRED'' then ''Expired'' else ''Cancelled'' end as status, x.erx_no,',
'       ''<span class="fa fa-print" aria-hidden="true"></span> Print'' as prn',
'  from his_prescription x join his_prescription_line l on l.prescription_id = x.id join inv_item i on i.id = l.item_id',
' where x.visit_id = :P33_VISIT order by x.id desc, l.line_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Prescriptions of the visit'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000556)
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
,p_internal_uid=>91820275000000556
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000558)
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
 p_id=>wwv_flow_imp.id(91820275000000559)
,p_db_column_name=>'RX_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Rx'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000560)
,p_db_column_name=>'RX_AT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Date'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000561)
,p_db_column_name=>'MEDICINE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Medicine'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000562)
,p_db_column_name=>'DOSE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Dose'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000563)
,p_db_column_name=>'FREQUENCY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Frequency'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000564)
,p_db_column_name=>'DURATION_DAYS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Days'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000565)
,p_db_column_name=>'QUANTITY'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Qty'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000566)
,p_db_column_name=>'DISPENSED_QTY'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Dispensed'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000567)
,p_db_column_name=>'STATUS'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Status'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000568)
,p_db_column_name=>'ERX_NO'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'e-Rx'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000569)
,p_db_column_name=>'PRN'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'Print'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_column_link=>'f?p=&APP_ID.:38:&SESSION.::&DEBUG.:RP,38:P38_ID:#ID#'
,p_column_linktext=>'#PRN#'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000557)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'557'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'RX_NO:RX_AT:MEDICINE:DOSE:FREQUENCY:DURATION_DAYS:QUANTITY:DISPENSED_QTY:STATUS:ERX_NO:PRN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000570)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000532)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'الزيارة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:&P33_VISIT.'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000571)
,p_branch_action=>'f?p=&APP_ID.:33:&SESSION.::&DEBUG.::P33_VISIT:&P33_VISIT.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
