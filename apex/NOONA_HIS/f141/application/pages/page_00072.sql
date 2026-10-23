prompt --application/pages/page_00072
begin
--   Manifest
--     PAGE: 00072
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
 p_id=>72
,p_name=>'Claim Batch'
,p_alias=>'CLAIM-BATCH'
,p_step_title=>'دفعة مطالبات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'window.nnClaimExport = function () {',
'  var el = document.getElementById(''nnClaimJson''); if (!el) return;',
'  var blob = new Blob([JSON.stringify(JSON.parse(el.textContent), null, 2)], { type: ''application/json'' });',
'  var a = document.createElement(''a''); a.href = URL.createObjectURL(blob); a.download = ''claim-'' + $v(''P72_ID'') + ''.json'';',
'  document.body.appendChild(a); a.click(); a.remove();',
'};'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000804)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000805)
,p_name=>'P72_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000806)
,p_plug_name=>'الدفعة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_claim_pkg.batch_html(:P72_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000807)
,p_name=>'P72_REF'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_prompt=>'مرجع الإرسال لدى الجهة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000808)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_button_name=>'SUBMIT_BATCH'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال الدفعة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000809)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_button_name=>'CANCEL_BATCH'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الدفعة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000810)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_button_name=>'REFRESH'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تحديث حالة السداد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000811)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_button_name=>'SEND_ELECTRONIC'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إرسال إلكتروني عبر قناة الجهة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000812)
,p_button_sequence=>70
,p_button_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_button_name=>'POLL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'متابعة قرار الجهة إلكترونياً'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000813)
,p_process_sequence=>35
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Send Electronic'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l varchar2(30);',
'begin',
'    l := noona_his_link_pkg.send_claim(:P72_ID);',
'    apex_application.g_print_success_message := ''نتيجة الإرسال: '' || noona_his_link_pkg.status_label(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000811)
,p_internal_uid=>91820275000000813
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000814)
,p_process_sequence=>36
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Poll'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l varchar2(30);',
'begin',
'    l := noona_his_link_pkg.poll_claim(:P72_ID);',
'    apex_application.g_print_success_message := case l when ''ADJUDICATED'' then ''سجل قرار الجهة وقيد المرفوض'' else ''الحالة: '' || noona_his_link_pkg.status_label(l) end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000812)
,p_internal_uid=>91820275000000814
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000815)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000816)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820275000000804)
,p_button_name=>'EXPORT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تنزيل ملف المطالبة الإلكتروني (JSON)'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:nnClaimExport();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000817)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Submit'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_claim_pkg.submit_batch(:P72_ID, :P72_REF);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000808)
,p_process_success_message=>'أرسلت الدفعة'
,p_internal_uid=>91820275000000817
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000818)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_claim_pkg.cancel_batch(:P72_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000809)
,p_process_success_message=>'ألغيت الدفعة'
,p_internal_uid=>91820275000000818
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000819)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Refresh'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_claim_pkg.refresh_batch(:P72_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000810)
,p_process_success_message=>'حدثت الحالة'
,p_internal_uid=>91820275000000819
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000820)
,p_plug_name=>'رد الجهة (خصم أو رفض على فاتورة)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000821)
,p_name=>'P72_INV'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000820)
,p_prompt=>'الفاتورة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select i.doc_no || '' - '' || p.name_ar || '' ('' || to_char(l.claimed_amount, ''FM999G990D00'') || '')'' d, i.id r from his_claim_line l join his_invoice i on i.id = l.invoice_id join his_patient p on p.id = i.patient_id where l.batch_id = :P72_ID order by i.doc_no'
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
 p_id=>wwv_flow_imp.id(91820275000000822)
,p_name=>'P72_APPROVED'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000820)
,p_prompt=>'المبلغ المقبول'
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
 p_id=>wwv_flow_imp.id(91820275000000823)
,p_name=>'P72_REASON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000820)
,p_prompt=>'Rejection reason'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000824)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000820)
,p_button_name=>'ADD_DECISION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة للرد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000825)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000820)
,p_button_name=>'RECORD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل رد الجهة (الباقي مقبول بالكامل)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000826)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Decision'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if not apex_collection.collection_exists(''HIS_CLAIM_RESP'') then apex_collection.create_collection(''HIS_CLAIM_RESP''); end if;',
'    apex_collection.add_member(''HIS_CLAIM_RESP'', p_c001 => :P72_ID, p_c002 => :P72_INV, p_c003 => :P72_APPROVED, p_c004 => :P72_REASON);',
'    :P72_INV := null; :P72_APPROVED := null; :P72_REASON := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000824)
,p_process_success_message=>'أضيف للرد'
,p_internal_uid=>91820275000000826
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000827)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Record'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    if apex_collection.collection_exists(''HIS_CLAIM_RESP'') then',
'        select json_arrayagg(json_object(''inv'' value to_number(c002), ''approved'' value to_number(c003), ''reason'' value c004) returning clob)',
'          into l from apex_collections where collection_name = ''HIS_CLAIM_RESP'' and c001 = :P72_ID;',
'    end if;',
'    noona_his_claim_pkg.record_response(:P72_ID, l);',
'    if apex_collection.collection_exists(''HIS_CLAIM_RESP'') then apex_collection.delete_collection(''HIS_CLAIM_RESP''); end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000825)
,p_process_success_message=>'سجل رد الجهة وقيد المرفوض'
,p_internal_uid=>91820275000000827
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000828)
,p_plug_name=>'قرارات الرد المضافة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select c.seq_id as id, i.doc_no, c.c003 as approved, c.c004 as reason from apex_collections c join his_invoice i on i.id = to_number(c.c002)',
' where c.collection_name = ''HIS_CLAIM_RESP'' and c.c001 = :P72_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'قرارات الرد المضافة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000829)
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
,p_internal_uid=>91820275000000829
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000831)
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
 p_id=>wwv_flow_imp.id(91820275000000832)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الفاتورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000833)
,p_db_column_name=>'APPROVED'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المقبول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000834)
,p_db_column_name=>'REASON'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'السبب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000830)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'830'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:APPROVED:REASON'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000835)
,p_plug_name=>'ملف المطالبة'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P72_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<script type="application/json" id="nnClaimJson">'' || replace(noona_his_claim_pkg.batch_json(:P72_ID), ''</'', ''<\/'')',
'    || ''</script>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000836)
,p_branch_action=>'f?p=&APP_ID.:72:&SESSION.::&DEBUG.::P72_ID:&P72_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
