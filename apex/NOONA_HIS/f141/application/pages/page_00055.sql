prompt --application/pages/page_00055
begin
--   Manifest
--     PAGE: 00055
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
 p_id=>55
,p_name=>'Pharmacy'
,p_alias=>'PHARMACY'
,p_step_title=>'الصيدلية الداخلية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000579)
,p_plug_name=>'صرف الوصفة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000580)
,p_name=>'P55_RX'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000579)
,p_prompt=>'الوصفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select x.rx_no || '' - '' || p.name_ar || '' ('' || case x.status_code when ''ACTIVE'' then ''جديدة'' else ''جزئية'' end || '')'' d, x.id r from his_prescription x join his_visit v on v.id = x.visit_id join his_patient p on p.id = v.patient_id where x.company_id = noona_his_pkg.company and x.status_code in (''ACTIVE'', ''PARTIAL'') and nvl(x.expires_on, trunc(cast(x.rx_at as date)) + 30) >= trunc(sysdate) order by x.rx_at desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000581)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000579)
,p_button_name=>'BILL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال للمحاسبة (فوترة الأدوية)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000582)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000579)
,p_button_name=>'DELIVER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تسليم الأدوية (يصرف من مستودع الصيدلية)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000583)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000000579)
,p_button_name=>'CANCEL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الوصفة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000584)
,p_name=>'P55_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000579)
,p_prompt=>'سبب الإقفال دون صرف (صرف من صيدلية خارجية، لم يستلم...)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000585)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820275000000579)
,p_button_name=>'CLOSE_EXT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إقفال دون صرف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000586)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820275000000579)
,p_button_name=>'EXPIRE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إقفال الوصفات المنتهية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000587)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820275000000579)
,p_button_name=>'PRINT_RX'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة الوصفة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:if($v(''P55_RX''))location.href=''f?p=''+apex.env.APP_ID+'':38:''+apex.env.APP_SESSION+''::NO:RP,38:P38_ID:''+$v(''P55_RX'');'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000588)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close External'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_care_pkg.close_prescription(:P55_RX, :P55_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000585)
,p_process_success_message=>'أقفلت الوصفة دون صرف من الصيدلية'
,p_internal_uid=>91820275000000588
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000589)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Expire'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_care_pkg.expire_prescriptions;',
'    apex_application.g_print_success_message := ''أقفلت '' || l || '' وصفة منتهية'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000586)
,p_internal_uid=>91820275000000589
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000590)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Bill'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_care_pkg.bill_prescription(:P55_RX);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000581)
,p_process_success_message=>'أرسلت الأدوية للمحاسبة'
,p_internal_uid=>91820275000000590
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000591)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Deliver'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_care_pkg.deliver_prescription(:P55_RX);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000582)
,p_process_success_message=>'سلمت الأدوية'
,p_internal_uid=>91820275000000591
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000592)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_care_pkg.cancel_prescription(:P55_RX);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000583)
,p_process_success_message=>'ألغيت الوصفة'
,p_internal_uid=>91820275000000592
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000593)
,p_plug_name=>'الوصفات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select x.id, x.rx_no, to_char(x.rx_at, ''YYYY-MM-DD HH24:MI'') as rx_at, p.name_ar as patient, p.mrn, nvl(i.name_en, i.name_ar) as medicine,',
'       l.dose || '' '' || l.frequency || nvl2(l.duration_days, '' x '' || l.duration_days || ''d'', '''') as sig, l.quantity, l.dispensed_qty,',
'       case when l.order_id is null then ''لم تفوتر'' when o.invoice_id is null and (select ov.visit_type from his_visit ov where ov.id = o.visit_id)',
'            not in (''INPATIENT'', ''EMERGENCY'', ''DAY_CASE'') then ''بانتظار السداد''',
'            when o.status_code = ''COMPLETED'' then ''مسلمة'' else ''جاهزة للتسليم'' end as state,',
'       (select nvl(sum(h.on_hand_qty), 0) from inv_onhand h join his_department d on d.id = x.pharmacy_id where h.item_id = l.item_id',
'         and h.warehouse_id = d.warehouse_id) as stock, nvl(x.expires_on, trunc(cast(x.rx_at as date)) + 30) as expires_on, x.erx_no,',
'       case v.status_code when ''OPEN'' then ''مفتوحة'' else ''مقفلة'' end as visit_state',
'  from his_prescription x join his_prescription_line l on l.prescription_id = x.id join inv_item i on i.id = l.item_id',
'  join his_visit v on v.id = x.visit_id join his_patient p on p.id = v.patient_id left join his_order o on o.id = l.order_id',
' where x.company_id = noona_his_pkg.company and x.status_code in (''ACTIVE'', ''PARTIAL'') and nvl(x.expires_on, trunc(cast(x.rx_at as date)) + 30) >= trunc(sysdate)',
' order by x.rx_at desc, l.line_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الوصفات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000594)
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
,p_internal_uid=>91820275000000594
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000596)
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
 p_id=>wwv_flow_imp.id(91820275000000597)
,p_db_column_name=>'RX_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوصفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000598)
,p_db_column_name=>'RX_AT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000599)
,p_db_column_name=>'PATIENT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المريض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000600)
,p_db_column_name=>'MRN'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الرقم الطبي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000601)
,p_db_column_name=>'MEDICINE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Medicine'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000602)
,p_db_column_name=>'SIG'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Sig'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000603)
,p_db_column_name=>'QUANTITY'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000604)
,p_db_column_name=>'DISPENSED_QTY'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'المصروف'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000605)
,p_db_column_name=>'STATE'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000606)
,p_db_column_name=>'STOCK'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'رصيد الصيدلية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000607)
,p_db_column_name=>'EXPIRES_ON'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'صالحة حتى'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000608)
,p_db_column_name=>'ERX_NO'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الوصفة الإلكترونية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000609)
,p_db_column_name=>'VISIT_STATE'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'الزيارة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000595)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'595'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'RX_NO:RX_AT:PATIENT:MRN:MEDICINE:SIG:QUANTITY:DISPENSED_QTY:STATE:STOCK:EXPIRES_ON:ERX_NO:VISIT_STATE'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000610)
,p_branch_action=>'f?p=&APP_ID.:55:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
