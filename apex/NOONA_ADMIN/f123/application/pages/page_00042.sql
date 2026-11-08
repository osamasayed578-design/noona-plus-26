prompt --application/pages/page_00042
begin
--   Manifest
--     PAGE: 00042
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
 p_id=>42
,p_name=>'Rules'
,p_alias=>'RULES'
,p_step_title=>'شروط التوجيه'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000478)
,p_plug_name=>'شروط التوجيه'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select id, code, name_ar, dbms_lob.substr(rule_expression, 400, 1) as expression,',
'       noona_ui_pkg.status_badge(status_code) as status_html from wf_rule'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'شروط التوجيه'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000479)
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
,p_internal_uid=>91820262000000479
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000481)
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
 p_id=>wwv_flow_imp.id(91820262000000482)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000483)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الشرط'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000484)
,p_db_column_name=>'EXPRESSION'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'التعبير'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000485)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000480)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'480'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:EXPRESSION:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000486)
,p_plug_name=>'شرط جديد (مثال: المبلغ أكبر من أو يساوي 10000)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000487)
,p_name=>'P42_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000486)
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
 p_id=>wwv_flow_imp.id(91820262000000488)
,p_name=>'P42_NAME_AR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000486)
,p_prompt=>'اسم الشرط'
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
 p_id=>wwv_flow_imp.id(91820262000000489)
,p_name=>'P42_FIELD'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000486)
,p_prompt=>'الحقل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المبلغ;amount,العملة;currency,الأولوية;priority,الشركة;company_id,الفرع;branch_id,نوع المستند;document_type'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000490)
,p_name=>'P42_OP'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000486)
,p_prompt=>'المقارنة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:أكبر من أو يساوي;>=,أكبر من;>,أصغر من;<,أصغر من أو يساوي;<=,يساوي;=,لا يساوي;!=,ضمن القائمة;in'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000491)
,p_name=>'P42_VALUE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000486)
,p_prompt=>'القيمة (للقائمة افصل بفاصلة)'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000493)
,p_validation_name=>'P42_CODE required (CREATE)'
,p_validation_sequence=>13
,p_validation=>'P42_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000492)
,p_associated_item=>wwv_flow_imp.id(91820262000000487)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000494)
,p_validation_name=>'P42_NAME_AR required (CREATE)'
,p_validation_sequence=>14
,p_validation=>'P42_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000492)
,p_associated_item=>wwv_flow_imp.id(91820262000000488)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000495)
,p_validation_name=>'P42_VALUE required (CREATE)'
,p_validation_sequence=>15
,p_validation=>'P42_VALUE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000492)
,p_associated_item=>wwv_flow_imp.id(91820262000000491)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000492)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000486)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الشرط'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000496)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Rule'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_val varchar2(4000);',
'    l_id  number;',
'begin',
'    if :P42_OP = ''in'' then',
'        select ''['' || listagg(case when validate_conversion(trim(column_value) as number) = 1 then trim(column_value)',
'                                   else ''"'' || replace(trim(column_value), ''"'') || ''"'' end, '','') || '']''',
'          into l_val from table(apex_string.split(:P42_VALUE, '',''));',
'    elsif validate_conversion(:P42_VALUE as number) = 1 then',
'        l_val := :P42_VALUE;',
'    else',
'        l_val := ''"'' || replace(:P42_VALUE, ''"'') || ''"'';',
'    end if;',
'    l_id := noona_workflow_pkg.create_rule(:P42_CODE, :P42_NAME_AR,',
'        ''{"field":"'' || :P42_FIELD || ''","op":"'' || :P42_OP || ''","value":'' || l_val || ''}'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000492)
,p_process_success_message=>'تم إنشاء الشرط؛ استخدمه في انتقالات المسار'
,p_internal_uid=>91820262000000496
);

wwv_flow_imp.component_end;
end;
/
