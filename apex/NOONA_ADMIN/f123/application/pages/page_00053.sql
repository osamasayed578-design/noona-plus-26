prompt --application/pages/page_00053
begin
--   Manifest
--     PAGE: 00053
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
 p_id=>53
,p_name=>'Document Sequences'
,p_alias=>'DOC-SEQUENCES'
,p_step_title=>'تسلسلات المستندات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000639)
,p_plug_name=>'تسلسلات المستندات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, nvl(c.trade_name_ar, c.legal_name_ar) as company_name, b.name_ar as branch_name, s.doc_type_code, s.fiscal_year,',
'       noona_refdata_pkg.preview_doc_no(s.id) as next_doc_no, noona_ui_pkg.code_label(s.is_gapless) as gapless,',
'       decode(s.reset_policy, ''YEARLY'', ''سنوي'', ''MONTHLY'', ''شهري'', ''بدون'') as reset_policy,',
'       noona_ui_pkg.status_badge(case s.is_active when ''Y'' then ''ACTIVE'' else ''INACTIVE'' end) as status_html',
'  from ref_doc_sequence s left join org_company c on c.id = s.company_id left join org_branch b on b.id = s.branch_id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'تسلسلات المستندات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000640)
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
,p_internal_uid=>91820262000000640
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000642)
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
 p_id=>wwv_flow_imp.id(91820262000000643)
,p_db_column_name=>'COMPANY_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الشركة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000644)
,p_db_column_name=>'BRANCH_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الفرع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000645)
,p_db_column_name=>'DOC_TYPE_CODE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'نوع المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000646)
,p_db_column_name=>'FISCAL_YEAR'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'السنة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000647)
,p_db_column_name=>'NEXT_DOC_NO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الرقم التالي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000648)
,p_db_column_name=>'GAPLESS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'بلا فجوات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000649)
,p_db_column_name=>'RESET_POLICY'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'إعادة الترقيم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000650)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000641)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'641'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'COMPANY_NAME:BRANCH_NAME:DOC_TYPE_CODE:FISCAL_YEAR:NEXT_DOC_NO:GAPLESS:RESET_POLICY:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000651)
,p_plug_name=>'تسلسل جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000652)
,p_name=>'P53_COMPANY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_prompt=>'الشركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_COMPANIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000004)||'.'
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
 p_id=>wwv_flow_imp.id(91820262000000653)
,p_name=>'P53_BRANCH'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_prompt=>'الفرع (اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = :P53_COMPANY and status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P53_COMPANY'
,p_ajax_items_to_submit=>'P53_COMPANY'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000654)
,p_name=>'P53_DOC_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_prompt=>'نوع المستند (مثال: PO, SI, JV)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000655)
,p_name=>'P53_YEAR'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_prompt=>'السنة المالية'
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
 p_id=>wwv_flow_imp.id(91820262000000656)
,p_name=>'P53_PREFIX'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_prompt=>'البادئة (مثال: PO-)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820262000000657)
,p_name=>'P53_PADDING'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_prompt=>'عدد الخانات'
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
 p_id=>wwv_flow_imp.id(91820262000000658)
,p_name=>'P53_GAPLESS'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_prompt=>'بلا فجوات (للمستندات الضريبية)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000659)
,p_name=>'P53_RESET'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_prompt=>'إعادة الترقيم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سنوي;YEARLY,شهري;MONTHLY,بدون;NEVER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000661)
,p_validation_name=>'P53_COMPANY required (CREATE)'
,p_validation_sequence=>20
,p_validation=>'P53_COMPANY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000660)
,p_associated_item=>wwv_flow_imp.id(91820262000000652)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000662)
,p_validation_name=>'P53_DOC_TYPE required (CREATE)'
,p_validation_sequence=>21
,p_validation=>'P53_DOC_TYPE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000660)
,p_associated_item=>wwv_flow_imp.id(91820262000000654)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000663)
,p_validation_name=>'P53_YEAR required (CREATE)'
,p_validation_sequence=>22
,p_validation=>'P53_YEAR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000660)
,p_associated_item=>wwv_flow_imp.id(91820262000000655)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000660)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000651)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء التسلسل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000664)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P53_YEAR := nvl(:P53_YEAR, to_char(sysdate, ''YYYY''));',
':P53_PADDING := nvl(:P53_PADDING, 6);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000664
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000665)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Sequence'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_refdata_pkg.create_doc_sequence(p_company_id => :P53_COMPANY, p_doc_type => :P53_DOC_TYPE,',
'                p_fiscal_year => :P53_YEAR, p_prefix => :P53_PREFIX, p_branch_id => :P53_BRANCH,',
'                p_padding => :P53_PADDING, p_gapless => nvl(:P53_GAPLESS, ''N''), p_reset => :P53_RESET);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000660)
,p_process_success_message=>'تم إنشاء التسلسل'
,p_internal_uid=>91820262000000665
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000666)
,p_plug_name=>'تعديل تسلسل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000667)
,p_name=>'P53_SEQ'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000666)
,p_prompt=>'التسلسل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select s.doc_type_code || '' · '' || s.fiscal_year || '' · '' || nvl(c.trade_name_ar, c.legal_name_ar) || '' → '' || noona_refdata_pkg.preview_doc_no(s.id) d, s.id r from ref_doc_sequence s join org_company c on c.id = s.company_id order by 1'
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
 p_id=>wwv_flow_imp.id(91820262000000668)
,p_name=>'P53_E_PREFIX'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000666)
,p_prompt=>'البادئة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820262000000669)
,p_name=>'P53_E_NEXT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000666)
,p_prompt=>'الرقم التالي (لا يقل عن الحالي)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000670)
,p_name=>'P53_E_ACTIVE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000666)
,p_prompt=>'فعال'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000671)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000666)
,p_button_name=>'UPDATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ التعديل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000672)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Sequence'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P53_SEQ is not null then',
'    select prefix, next_number, is_active into :P53_E_PREFIX, :P53_E_NEXT, :P53_E_ACTIVE from ref_doc_sequence where id = :P53_SEQ;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000672
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000673)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Update Sequence'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_refdata_pkg.update_doc_sequence(:P53_SEQ, :P53_E_PREFIX, :P53_E_NEXT, :P53_E_ACTIVE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000671)
,p_process_success_message=>'تم حفظ التسلسل'
,p_internal_uid=>91820262000000673
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000674)
,p_branch_action=>'f?p=&APP_ID.:53:&SESSION.::&DEBUG.:53:P53_SEQ:&P53_SEQ.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
