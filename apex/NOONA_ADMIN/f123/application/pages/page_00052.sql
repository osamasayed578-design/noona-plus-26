prompt --application/pages/page_00052
begin
--   Manifest
--     PAGE: 00052
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>52
,p_name=>'Payment Terms'
,p_alias=>'PAYMENT-TERMS'
,p_step_title=>'شروط الدفع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000602)
,p_plug_name=>'شروط الدفع'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.id, t.code, t.name_ar, noona_ui_pkg.code_label(t.base_date_rule) as base_rule, t.due_days,',
'       case when t.early_discount_pct is not null then t.early_discount_pct || ''% خلال '' || t.early_discount_days || '' يوم'' end as discount,',
'       (select listagg(l.due_pct || ''% بعد '' || l.due_days || '' يوم'', ''، '') within group (order by l.line_no)',
'          from ref_payment_term_line l where l.payment_term_id = t.id) as installments,',
'       noona_ui_pkg.status_badge(case t.is_active when ''Y'' then ''ACTIVE'' else ''INACTIVE'' end) as status_html',
'  from ref_payment_term t'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'شروط الدفع'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000603)
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
,p_internal_uid=>91820262000000603
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000605)
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
 p_id=>wwv_flow_imp.id(91820262000000606)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000607)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الشرط'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000608)
,p_db_column_name=>'BASE_RULE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'يحسب من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000609)
,p_db_column_name=>'DUE_DAYS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'أيام الاستحقاق'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000610)
,p_db_column_name=>'DISCOUNT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'خصم السداد المبكر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000611)
,p_db_column_name=>'INSTALLMENTS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الأقساط'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000612)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000604)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'604'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:BASE_RULE:DUE_DAYS:DISCOUNT:INSTALLMENTS:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000613)
,p_plug_name=>'شرط دفع جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000614)
,p_name=>'P52_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000613)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>50
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000615)
,p_name=>'P52_NAME_AR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000613)
,p_prompt=>'الاسم (مثال: صافي 30 يوم)'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000616)
,p_name=>'P52_BASE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000613)
,p_prompt=>'يحسب الاستحقاق من'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تاريخ المستند;DOC_DATE,تاريخ التسليم;DELIVERY_DATE,نهاية الشهر;END_OF_MONTH,تاريخ الاستلام;RECEIPT_DATE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000617)
,p_name=>'P52_DAYS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000613)
,p_prompt=>'أيام الاستحقاق'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000618)
,p_name=>'P52_DISC_PCT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000613)
,p_prompt=>'خصم السداد المبكر %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000619)
,p_name=>'P52_DISC_DAYS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820262000000613)
,p_prompt=>'خلال (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000621)
,p_validation_name=>'P52_CODE required (CREATE)'
,p_validation_sequence=>17
,p_validation=>'P52_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000620)
,p_associated_item=>wwv_flow_imp.id(91820262000000614)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000622)
,p_validation_name=>'P52_NAME_AR required (CREATE)'
,p_validation_sequence=>18
,p_validation=>'P52_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000620)
,p_associated_item=>wwv_flow_imp.id(91820262000000615)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000623)
,p_validation_name=>'P52_DAYS required (CREATE)'
,p_validation_sequence=>19
,p_validation=>'P52_DAYS'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000620)
,p_associated_item=>wwv_flow_imp.id(91820262000000617)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000620)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000613)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الشرط'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000624)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Term'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_refdata_pkg.create_payment_term(:P52_CODE, :P52_NAME_AR, :P52_BASE, :P52_DAYS, :P52_DISC_PCT, :P52_DISC_DAYS);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000620)
,p_process_success_message=>'تم إنشاء شرط الدفع'
,p_internal_uid=>91820262000000624
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000625)
,p_plug_name=>'أقساط وتفعيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000626)
,p_name=>'P52_TERM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000625)
,p_prompt=>'شرط الدفع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from ref_payment_term order by 1'
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
 p_id=>wwv_flow_imp.id(91820262000000627)
,p_name=>'P52_INST_PCT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000625)
,p_prompt=>'نسبة القسط %'
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
 p_id=>wwv_flow_imp.id(91820262000000628)
,p_name=>'P52_INST_DAYS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000625)
,p_prompt=>'يستحق بعد (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000629)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000625)
,p_button_name=>'ADD_INSTALLMENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة القسط'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000630)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000625)
,p_button_name=>'ACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تفعيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000631)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000625)
,p_button_name=>'DEACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إيقاف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000632)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Installment'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_refdata_pkg.add_installment(:P52_TERM, :P52_INST_PCT, :P52_INST_DAYS);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000629)
,p_process_success_message=>'تمت إضافة القسط'
,p_internal_uid=>91820262000000632
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000633)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Activate Term'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_refdata_pkg.set_term_active(:P52_TERM, ''Y'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000630)
,p_process_success_message=>'تم التفعيل'
,p_internal_uid=>91820262000000633
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000634)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Deactivate Term'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_refdata_pkg.set_term_active(:P52_TERM, ''N'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000631)
,p_process_success_message=>'تم الإيقاف'
,p_internal_uid=>91820262000000634
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000635)
,p_branch_action=>'f?p=&APP_ID.:52:&SESSION.::&DEBUG.:52::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
