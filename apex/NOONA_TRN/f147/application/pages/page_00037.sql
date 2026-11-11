prompt --application/pages/page_00037
begin
--   Manifest
--     PAGE: 00037
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
 p_id=>37
,p_name=>'Fleet Performance'
,p_alias=>'FLEET-PERFORMANCE'
,p_step_title=>'مصروفات قطع الغيار وأداء العربات والسائقين'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000358)
,p_plug_name=>'الفترة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000359)
,p_name=>'P37_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000358)
,p_prompt=>'من'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000360)
,p_name=>'P37_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000358)
,p_prompt=>'إلى'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000361)
,p_name=>'P37_VEH'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000358)
,p_prompt=>'العربة (الكل إن تركت)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select plate_no d, id r from trn_vehicle where company_id = noona_trn_pkg.company order by plate_no'
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
 p_id=>wwv_flow_imp.id(91820290000000362)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000358)
,p_button_name=>'SHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000363)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P37_FROM is null then :P37_FROM := to_char(trunc(sysdate, ''YYYY''), ''YYYY-MM-DD''); end if;',
'if :P37_TO is null then :P37_TO := to_char(sysdate, ''YYYY-MM-DD''); end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000363
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000364)
,p_plug_name=>'أداء العربات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_trn_pkg.vehicle_perf_html(to_date(:P37_FROM, ''YYYY-MM-DD''), to_date(:P37_TO, ''YYYY-MM-DD''), to_number(:P37_VEH));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000365)
,p_plug_name=>'أداء السائقين'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_trn_pkg.driver_perf_html(to_date(:P37_FROM, ''YYYY-MM-DD''), to_date(:P37_TO, ''YYYY-MM-DD''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000366)
,p_plug_name=>'مصروفات قطع الغيار والزيوت والإطارات لكل عربة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_trn_pkg.parts_report_html(to_date(:P37_FROM, ''YYYY-MM-DD''), to_date(:P37_TO, ''YYYY-MM-DD''), to_number(:P37_VEH));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000367)
,p_plug_name=>'بنود الصيانة (للتصدير إلى Excel)'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select v.plate_no, o.doc_no, cast(o.completed_at as date) done_date, noona_trn_pkg.maint_type_label(o.maint_type) maint_type,',
'       noona_trn_pkg.maint_type_label(l.line_type) line_type, l.description, l.quantity, l.unit_cost, l.amount,',
'       decode(l.from_stock, ''Y'', ''المخزون'', ''خارجي'') source, o.odometer_km, l.next_due_km, l.next_due_date',
'  from trn_maint_line l join trn_maint_order o on o.id = l.order_id join trn_vehicle v on v.id = o.vehicle_id',
' where o.company_id = noona_trn_pkg.company and o.status_code = ''COMPLETED''',
'   and o.completed_at >= to_date(:P37_FROM, ''YYYY-MM-DD'') and o.completed_at < to_date(:P37_TO, ''YYYY-MM-DD'') + 1',
'   and (:P37_VEH is null or o.vehicle_id = to_number(:P37_VEH))',
' order by v.plate_no, o.completed_at'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'بنود الصيانة (للتصدير إلى Excel)'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000368)
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
,p_internal_uid=>91820290000000368
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000370)
,p_db_column_name=>'PLATE_NO'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'العربة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000371)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الأمر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000372)
,p_db_column_name=>'DONE_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000373)
,p_db_column_name=>'MAINT_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'نوع الصيانة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000374)
,p_db_column_name=>'LINE_TYPE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'البند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000375)
,p_db_column_name=>'DESCRIPTION'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'البيان'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000376)
,p_db_column_name=>'QUANTITY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000377)
,p_db_column_name=>'UNIT_COST'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'التكلفة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000378)
,p_db_column_name=>'AMOUNT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000379)
,p_db_column_name=>'SOURCE'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000380)
,p_db_column_name=>'ODOMETER_KM'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'العداد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000381)
,p_db_column_name=>'NEXT_DUE_KM'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الاستبدال عند (كم)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000382)
,p_db_column_name=>'NEXT_DUE_DATE'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الاستبدال بتاريخ'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000369)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'369'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PLATE_NO:DOC_NO:DONE_DATE:MAINT_TYPE:LINE_TYPE:DESCRIPTION:QUANTITY:UNIT_COST:AMOUNT:SOURCE:ODOMETER_KM:NEXT_DUE_KM:NEXT_DUE_DATE'
);

wwv_flow_imp.component_end;
end;
/
