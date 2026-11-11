prompt --application/pages/page_00038
begin
--   Manifest
--     PAGE: 00038
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>147
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>38
,p_name=>'Part Service Life'
,p_alias=>'PART-LIFE'
,p_step_title=>'أعمار استبدال قطع الغيار'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000382)
,p_plug_name=>'عمر الاستبدال'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">عمر كل قطعة غيار أو زيت أو إطار بالكيلومتر أو بالأيام: عند صرفها في أمر صيانة يحدد النظام موعد استبدالها التالي من عداد العربة وتاريخ الإقفال، وتظهر في «صيانة الأسطول» عند اقتراب موعدها.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000383)
,p_name=>'P38_ITEM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000382)
,p_prompt=>'الصنف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select item_no || '' - '' || name_ar d, id r from inv_item where status_code = ''ACTIVE'' and item_type not in (''SERVICE'', ''NON_STOCK'') order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820290000000384)
,p_name=>'P38_KM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000382)
,p_prompt=>'كل (كم)'
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
 p_id=>wwv_flow_imp.id(91820290000000385)
,p_name=>'P38_DAYS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000382)
,p_prompt=>'أو كل (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000387)
,p_validation_name=>'P38_ITEM required (SAVE)'
,p_validation_sequence=>4
,p_validation=>'P38_ITEM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000386)
,p_associated_item=>wwv_flow_imp.id(91820290000000383)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000386)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000382)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000388)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.set_part_life(to_number(:P38_ITEM), to_number(:P38_KM), to_number(:P38_DAYS)); :P38_ITEM := null; :P38_KM := null; :P38_DAYS := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000386)
,p_process_success_message=>'حفظ عمر الاستبدال'
,p_internal_uid=>91820290000000388
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000389)
,p_plug_name=>'الأصناف ذات عمر استبدال'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select item_no, name_ar, service_life_km, service_life_days from inv_item',
' where service_life_km is not null or service_life_days is not null order by name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الأصناف ذات عمر استبدال'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000390)
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
,p_internal_uid=>91820290000000390
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000392)
,p_db_column_name=>'ITEM_NO'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'رقم الصنف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000393)
,p_db_column_name=>'NAME_AR'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الصنف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000394)
,p_db_column_name=>'SERVICE_LIFE_KM'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'كل (كم)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000395)
,p_db_column_name=>'SERVICE_LIFE_DAYS'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'كل (يوم)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000391)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'391'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ITEM_NO:NAME_AR:SERVICE_LIFE_KM:SERVICE_LIFE_DAYS'
);

wwv_flow_imp.component_end;
end;
/
