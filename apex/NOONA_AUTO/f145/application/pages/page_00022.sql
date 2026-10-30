prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>145
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>22
,p_name=>'Repricing'
,p_alias=>'REPRICING'
,p_step_title=>'إعادة التسعير والهوامش'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000391)
,p_plug_name=>'تشغيل جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يحسب السعر المقترح لكل صنف وخدمة من تكلفته الحالية وسياسته، ويعرضه أمام السعر الحالي والهامش. راجع الأسطر (عدل السعر أو استبعد سطراً) ثم «تطبيق الأسعار»؛ ويسجل كل تغيير في سجل الأسعار.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000392)
,p_name=>'P22_SCOPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000391)
,p_prompt=>'النطاق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:الكل;ALL,الأصناف;ITEMS,خدمات السيارات;AUT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000393)
,p_name=>'P22_ALL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000391)
,p_prompt=>'إظهار الأسطر التي لا يتغير سعرها'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000394)
,p_name=>'P22_NEWRUN'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820280000000391)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000395)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000391)
,p_button_name=>'NEW_RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'احسب الأسعار المقترحة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000396)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'New Run'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'    :P22_NEWRUN := noona_prc_pkg.new_run(:P22_SCOPE, case :P22_ALL when ''Y'' then ''N'' else ''Y'' end);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000395)
,p_process_success_message=>'تم حساب الأسعار المقترحة؛ راجعها ثم طبقها'
,p_internal_uid=>91820280000000396
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000397)
,p_plug_name=>'مراجعة وتطبيق'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000398)
,p_name=>'P22_RUN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000397)
,p_prompt=>'التشغيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select doc_no || '' - '' || case status_code when ''DRAFT'' then ''مسودة'' when ''APPLIED'' then ''مطبق'' else ''ملغى'' end || '' ('' || lines_count || '' سطر)'' d, id r from sal_price_run where company_id = noona_prc_pkg.company order by id desc'
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
 p_id=>wwv_flow_imp.id(91820280000000399)
,p_name=>'P22_LINE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000397)
,p_prompt=>'السطر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_prc_pkg.target_name(target_type, target_id) || '' : '' || to_char(new_price, ''FM999,990.00'') d, id r from sal_price_run_line where run_id = :P22_RUN order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P22_RUN'
,p_ajax_items_to_submit=>'P22_RUN'
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
 p_id=>wwv_flow_imp.id(91820280000000400)
,p_name=>'P22_PRICE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000397)
,p_prompt=>'السعر المعدل'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000401)
,p_name=>'P22_SEL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000397)
,p_prompt=>'يطبق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نعم;Y,لا (استبعاد);N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000402)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000397)
,p_button_name=>'SET_LINE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تعديل السطر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000403)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820280000000397)
,p_button_name=>'APPLY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تطبيق الأسعار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000404)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820280000000397)
,p_button_name=>'CANCEL_RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء التشغيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000405)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Set Line'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.set_run_line(:P22_LINE, :P22_SEL, to_number(:P22_PRICE));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000402)
,p_process_success_message=>'تم تعديل السطر'
,p_internal_uid=>91820280000000405
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000406)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Apply'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_prc_pkg.apply_run(:P22_RUN);',
'    apex_application.g_print_success_message := ''تم تطبيق '' || l || '' سعر جديد'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000403)
,p_internal_uid=>91820280000000406
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000407)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.cancel_run(:P22_RUN);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000404)
,p_process_success_message=>'تم إلغاء التشغيل'
,p_internal_uid=>91820280000000407
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000408)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Latest Run'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'    if :P22_NEWRUN is not null then :P22_RUN := :P22_NEWRUN; :P22_NEWRUN := null; end if;',
'    :P22_SCOPE := nvl(:P22_SCOPE, ''ALL'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000408
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000409)
,p_plug_name=>'الأسعار المقترحة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select l.id, case l.target_type when ''ITEM'' then ''صنف'' when ''HIS_SERVICE'' then ''خدمة طبية'' else ''خدمة سيارات'' end as kind,',
'       noona_prc_pkg.target_name(l.target_type, l.target_id) as target, l.cost_amount, l.old_price, l.new_price, l.new_min_price,',
'       l.margin_pct, case when l.old_price > 0 then round((l.new_price - l.old_price) / l.old_price * 100, 2) end as change_pct,',
'       case l.is_selected when ''Y'' then ''نعم'' else ''لا'' end as selected, noona_prc_pkg.policy_text(l.policy_id) as rule_text',
'  from sal_price_run_line l where l.run_id = :P22_RUN order by 2, 3'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الأسعار المقترحة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820280000000410)
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
,p_internal_uid=>91820280000000410
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000412)
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
 p_id=>wwv_flow_imp.id(91820280000000413)
,p_db_column_name=>'KIND'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000414)
,p_db_column_name=>'TARGET'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الصنف / الخدمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000415)
,p_db_column_name=>'COST_AMOUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'التكلفة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000416)
,p_db_column_name=>'OLD_PRICE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'السعر الحالي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000417)
,p_db_column_name=>'NEW_PRICE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'السعر المقترح'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000418)
,p_db_column_name=>'NEW_MIN_PRICE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'أدنى سعر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000419)
,p_db_column_name=>'MARGIN_PCT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الهامش %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000420)
,p_db_column_name=>'CHANGE_PCT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'التغير %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000421)
,p_db_column_name=>'SELECTED'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'يطبق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000422)
,p_db_column_name=>'RULE_TEXT'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'السياسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820280000000411)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'411'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'KIND:TARGET:COST_AMOUNT:OLD_PRICE:NEW_PRICE:NEW_MIN_PRICE:MARGIN_PCT:CHANGE_PCT:SELECTED:RULE_TEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000423)
,p_plug_name=>'تقرير الهوامش الحالية'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:is-collapsed'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prc_pkg.margin_html(nvl(:P22_SCOPE, ''ALL''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000424)
,p_plug_name=>'سجل تغيير الأسعار'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>50
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select h.id, h.created_at, case h.target_type when ''ITEM'' then ''صنف'' when ''HIS_SERVICE'' then ''خدمة طبية'' else ''خدمة سيارات'' end as kind,',
'       noona_prc_pkg.target_name(h.target_type, h.target_id) as target, h.old_price, h.new_price, h.cost_amount,',
'       case h.source_code when ''RUN'' then ''إعادة تسعير'' else ''يدوي'' end as src, h.created_by',
'  from sal_price_history h where h.company_id = noona_prc_pkg.company and h.target_type in (''ITEM'', ''ITEM_CATEGORY'', ''ALL_ITEMS'', ''AUT_SERVICE'', ''AUT_CATEGORY'', ''ALL_AUT'') order by h.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'سجل تغيير الأسعار'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820280000000425)
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
,p_internal_uid=>91820280000000425
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000427)
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
 p_id=>wwv_flow_imp.id(91820280000000428)
,p_db_column_name=>'CREATED_AT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوقت'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000429)
,p_db_column_name=>'KIND'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000430)
,p_db_column_name=>'TARGET'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الصنف / الخدمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000431)
,p_db_column_name=>'OLD_PRICE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'السابق'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000432)
,p_db_column_name=>'NEW_PRICE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الجديد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000433)
,p_db_column_name=>'COST_AMOUNT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'التكلفة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000434)
,p_db_column_name=>'SRC'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000435)
,p_db_column_name=>'CREATED_BY'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'بواسطة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820280000000426)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'426'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CREATED_AT:KIND:TARGET:OLD_PRICE:NEW_PRICE:COST_AMOUNT:SRC:CREATED_BY'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000436)
,p_branch_action=>'f?p=&APP_ID.:22:&SESSION.::&DEBUG.::P22_RUN:&P22_RUN.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
