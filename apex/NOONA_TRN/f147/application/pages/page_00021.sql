prompt --application/pages/page_00021
begin
--   Manifest
--     PAGE: 00021
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
 p_id=>21
,p_name=>'Trip'
,p_alias=>'TRIP'
,p_step_title=>'الرحلة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000127)
,p_plug_name=>'الرحلة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_trn_pkg.trip_html(:P21_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000128)
,p_name=>'P21_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000127)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000129)
,p_plug_name=>'الشحنات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.id, o.doc_no, noona_sal_pkg.customer_label(o.customer_account_id) customer, c.name_ar cargo, o.quantity, noona_trn_pkg.uom_label(o.uom_code) uom,',
'       round(x.loaded_kg / 1000, 3) tons, f.name_ar from_loc, tl.name_ar to_loc, o.total_amount, o.delivered_qty, o.shortage_qty, o.receiver_name,',
'       o.delivered_at, o.damage_notes, noona_trn_pkg.badge(o.status_code) status_html',
'  from trn_trip_order x join trn_order o on o.id = x.order_id join trn_cargo_type c on c.id = o.cargo_type_id',
'  join trn_location f on f.id = o.from_location_id join trn_location tl on tl.id = o.to_location_id',
' where x.trip_id = :P21_ID order by o.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الشحنات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000130)
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
,p_internal_uid=>91820290000000130
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000132)
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
 p_id=>wwv_flow_imp.id(91820290000000133)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الأمر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000134)
,p_db_column_name=>'CUSTOMER'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'العميل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000135)
,p_db_column_name=>'CARGO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الشحنة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000136)
,p_db_column_name=>'QUANTITY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000137)
,p_db_column_name=>'UOM'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الوحدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000138)
,p_db_column_name=>'TONS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'طن'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000139)
,p_db_column_name=>'FROM_LOC'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000140)
,p_db_column_name=>'TO_LOC'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000141)
,p_db_column_name=>'TOTAL_AMOUNT'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'الترحيل'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000142)
,p_db_column_name=>'DELIVERED_QTY'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'المسلم'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000143)
,p_db_column_name=>'SHORTAGE_QTY'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'العجز'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000144)
,p_db_column_name=>'RECEIVER_NAME'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'المستلم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000145)
,p_db_column_name=>'DELIVERED_AT'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'وقت التسليم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000146)
,p_db_column_name=>'DAMAGE_NOTES'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'الأضرار'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000147)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000131)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'131'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:CUSTOMER:CARGO:QUANTITY:UOM:TONS:FROM_LOC:TO_LOC:TOTAL_AMOUNT:DELIVERED_QTY:SHORTAGE_QTY:RECEIVER_NAME:DELIVERED_AT:DAMAGE_NOTES:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000148)
,p_plug_name=>'إضافة أو إخراج شحنة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P21_ID) in (''PLANNED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000149)
,p_name=>'P21_ADD_ORDER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000148)
,p_prompt=>'شحنة مؤكدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_trn_pkg.order_label(o.id) d, o.id r from trn_order o where o.company_id = noona_trn_pkg.company and o.status_code = ''CONFIRMED'' order by o.id'
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
 p_id=>wwv_flow_imp.id(91820290000000150)
,p_name=>'P21_DEL_ORDER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000148)
,p_prompt=>'شحنة في الرحلة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_trn_pkg.order_label(x.order_id) d, x.order_id r from trn_trip_order x where x.trip_id = :P21_ID order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000151)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000148)
,p_button_name=>'ADD_ORDER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تحميل على الرحلة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000152)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000148)
,p_button_name=>'DEL_ORDER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إخراج من الرحلة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000153)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Order'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.add_order(:P21_ID, :P21_ADD_ORDER);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000151)
,p_process_success_message=>'تم تحميل الشحنة'
,p_internal_uid=>91820290000000153
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000154)
,p_process_sequence=>21
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remove Order'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.remove_order(:P21_ID, :P21_DEL_ORDER);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000152)
,p_process_success_message=>'أخرجت الشحنة'
,p_internal_uid=>91820290000000154
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000155)
,p_plug_name=>'نقاط التوقف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, s.sort_order, l.name_ar location, decode(s.stop_purpose, ''LOADING'', ''تحميل'', ''UNLOADING'', ''تفريغ'', ''REST'', ''استراحة'', ''FUEL'', ''وقود'',',
'       ''CHECKPOINT'', ''تفتيش'', ''CUSTOMS'', ''جمارك'', ''BORDER'', ''حدود'', ''WEIGHBRIDGE'', ''ميزان'', ''REPAIR'', ''إصلاح'', ''أخرى'') purpose,',
'       s.planned_minutes, s.actual_arrival, s.actual_departure,',
'       round((cast(s.actual_departure as date) - cast(s.actual_arrival as date)) * 1440) actual_minutes',
'  from trn_trip_stop s join trn_location l on l.id = s.location_id where s.trip_id = :P21_ID order by s.sort_order, s.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'نقاط التوقف'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000156)
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
,p_internal_uid=>91820290000000156
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000158)
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
 p_id=>wwv_flow_imp.id(91820290000000159)
,p_db_column_name=>'SORT_ORDER'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الترتيب'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000160)
,p_db_column_name=>'LOCATION'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الموقع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000161)
,p_db_column_name=>'PURPOSE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الغرض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000162)
,p_db_column_name=>'PLANNED_MINUTES'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المخطط (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000163)
,p_db_column_name=>'ACTUAL_ARRIVAL'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الوصول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000164)
,p_db_column_name=>'ACTUAL_DEPARTURE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المغادرة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000165)
,p_db_column_name=>'ACTUAL_MINUTES'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الفعلي (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000157)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'157'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'SORT_ORDER:LOCATION:PURPOSE:PLANNED_MINUTES:ACTUAL_ARRIVAL:ACTUAL_DEPARTURE:ACTUAL_MINUTES'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000166)
,p_plug_name=>'نقاط التوقف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P21_ID) in (''PLANNED'',''DISPATCHED'',''IN_TRANSIT'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000167)
,p_name=>'P21_STOP_LOC'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000166)
,p_prompt=>'الموقع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from trn_location where company_id = noona_trn_pkg.company and is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820290000000168)
,p_name=>'P21_STOP_PURPOSE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000166)
,p_prompt=>'الغرض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تحميل;LOADING,تفريغ;UNLOADING,استراحة;REST,تزود بالوقود;FUEL,نقطة تفتيش;CHECKPOINT,جمارك;CUSTOMS,منفذ حدودي;BORDER,ميزان;WEIGHBRIDGE,إصلاح;REPAIR,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000169)
,p_name=>'P21_STOP_MIN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000166)
,p_prompt=>'المدة المخططة (دقيقة)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000170)
,p_name=>'P21_STOP'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000166)
,p_prompt=>'نقطة للتسجيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select s.sort_order || '' · '' || l.name_ar || case when s.actual_arrival is null then '' (لم يصل)'' when s.actual_departure is null then '' (متوقف)'' else '' (غادر)'' end d, s.id r from trn_trip_stop s join trn_location l on l.id = s.location_id where s.trip_id = :P21_ID order by s.sort_order'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000171)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000166)
,p_button_name=>'ADD_STOP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة نقطة توقف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000172)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000166)
,p_button_name=>'STOP_ARRIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'وصل للنقطة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000173)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820290000000166)
,p_button_name=>'STOP_DEPART'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'غادر النقطة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000174)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820290000000166)
,p_button_name=>'STOP_DEL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف النقطة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000175)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Stop'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'  l := noona_trn_pkg.add_stop(:P21_ID, :P21_STOP_LOC, :P21_STOP_PURPOSE, nvl(to_number(:P21_STOP_MIN), 0));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000171)
,p_process_success_message=>'أضيفت نقطة التوقف وتحدث زمن الوصول المتوقع'
,p_internal_uid=>91820290000000175
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000176)
,p_process_sequence=>31
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Stop Arrive'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.stop_arrive(:P21_STOP);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000172)
,p_process_success_message=>'سجل الوصول للنقطة'
,p_internal_uid=>91820290000000176
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000177)
,p_process_sequence=>32
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Stop Depart'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.stop_depart(:P21_STOP);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000173)
,p_process_success_message=>'سجلت المغادرة (يضاف أي تجاوز للتأخير)'
,p_internal_uid=>91820290000000177
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000178)
,p_process_sequence=>33
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Stop Delete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.remove_stop(:P21_STOP);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000174)
,p_process_success_message=>'حذفت النقطة'
,p_internal_uid=>91820290000000178
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000179)
,p_plug_name=>'حركة الرحلة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P21_ID) in (''PLANNED'',''IN_TRANSIT'',''ARRIVED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000180)
,p_name=>'P21_ODO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000179)
,p_prompt=>'قراءة العداد (كم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000181)
,p_process_sequence=>2
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Odometer'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P21_ODO is null then',
'    select case when t.status_code = ''PLANNED'' then v.odometer_km else nvl(t.odometer_start, v.odometer_km) end into :P21_ODO',
'      from trn_trip t join trn_vehicle v on v.id = t.vehicle_id where t.id = :P21_ID and t.company_id = noona_trn_pkg.company;',
'  end if;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000181
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000182)
,p_name=>'P21_FUEL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000179)
,p_prompt=>'إجمالي الوقود (لتر) عند الإقفال'
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
 p_id=>wwv_flow_imp.id(91820290000000183)
,p_name=>'P21_REASON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000179)
,p_prompt=>'سبب الإلغاء'
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
 p_id=>wwv_flow_imp.id(91820290000000184)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000179)
,p_button_name=>'DEPART'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تحرك الرحلة'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.trip_status(:P21_ID) in (''PLANNED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000185)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000179)
,p_button_name=>'ARRIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'وصلت الرحلة'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.trip_status(:P21_ID) in (''IN_TRANSIT'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000186)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820290000000179)
,p_button_name=>'COMPLETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إقفال الرحلة'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.trip_status(:P21_ID) in (''IN_TRANSIT'',''ARRIVED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000187)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820290000000179)
,p_button_name=>'CANCEL_TRIP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الرحلة'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.trip_status(:P21_ID) in (''PLANNED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000188)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Depart'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.depart(:P21_ID, to_number(:P21_ODO));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000184)
,p_process_success_message=>'تحركت الرحلة'
,p_internal_uid=>91820290000000188
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000189)
,p_process_sequence=>41
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Arrive'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.arrive(:P21_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000185)
,p_process_success_message=>'سجل وصول الرحلة'
,p_internal_uid=>91820290000000189
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000190)
,p_process_sequence=>42
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Complete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.complete_trip(:P21_ID, to_number(:P21_ODO), to_number(:P21_FUEL));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000186)
,p_process_success_message=>'أقفلت الرحلة؛ العربة والسائق متاحان'
,p_internal_uid=>91820290000000190
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000191)
,p_process_sequence=>43
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.cancel_trip(:P21_ID, :P21_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000187)
,p_process_success_message=>'ألغيت الرحلة'
,p_internal_uid=>91820290000000191
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000192)
,p_plug_name=>'التسليم والتفريغ'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P21_ID) in (''IN_TRANSIT'',''ARRIVED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000193)
,p_name=>'P21_DLV_ORDER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000192)
,p_prompt=>'الشحنة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_trn_pkg.order_label(o.id) d, o.id r from trn_trip_order x join trn_order o on o.id = x.order_id where x.trip_id = :P21_ID and o.status_code = ''IN_TRANSIT'' order by o.id'
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
 p_id=>wwv_flow_imp.id(91820290000000194)
,p_name=>'P21_DLV_QTY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000192)
,p_prompt=>'الكمية المسلمة'
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
 p_id=>wwv_flow_imp.id(91820290000000195)
,p_name=>'P21_DLV_RCV'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000192)
,p_prompt=>'المستلم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000196)
,p_name=>'P21_DLV_DMG'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000192)
,p_prompt=>'الأضرار (إن وجدت)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>1000
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
 p_id=>wwv_flow_imp.id(91820290000000197)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000192)
,p_button_name=>'DELIVER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل التسليم'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000198)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Deliver'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.deliver_order(:P21_ID, :P21_DLV_ORDER, to_number(:P21_DLV_QTY), :P21_DLV_RCV, :P21_DLV_DMG);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000197)
,p_process_success_message=>'سجل التسليم (والعجز إن وجد)'
,p_internal_uid=>91820290000000198
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000199)
,p_plug_name=>'مصروفات الرحلة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select e.id, e.expense_date, decode(e.expense_type, ''FUEL'', ''وقود'', ''TOLL'', ''رسوم طرق'', ''DRIVER_ALLOWANCE'', ''بدل سائق'', ''LOADING'', ''تحميل'',',
'       ''UNLOADING'', ''تفريغ'', ''PARKING'', ''مواقف'', ''REPAIR'', ''إصلاح'', ''TIRES'', ''إطارات'', ''FINE'', ''مخالفات'', ''WEIGHBRIDGE'', ''ميزان'', ''CUSTOMS'', ''جمارك'', ''أخرى'') expense_type,',
'       e.amount, e.liters, e.reference_no, e.notes from trn_trip_expense e where e.trip_id = :P21_ID order by e.expense_date, e.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مصروفات الرحلة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000200)
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
,p_internal_uid=>91820290000000200
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000202)
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
 p_id=>wwv_flow_imp.id(91820290000000203)
,p_db_column_name=>'EXPENSE_DATE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'التاريخ'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000204)
,p_db_column_name=>'EXPENSE_TYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000205)
,p_db_column_name=>'AMOUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000206)
,p_db_column_name=>'LITERS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'لتر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000207)
,p_db_column_name=>'REFERENCE_NO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الإيصال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000208)
,p_db_column_name=>'NOTES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'ملاحظات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000201)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'201'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'EXPENSE_DATE:EXPENSE_TYPE:AMOUNT:LITERS:REFERENCE_NO:NOTES'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000209)
,p_plug_name=>'مصروف جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>45
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P21_ID) <> ''CANCELLED'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000210)
,p_name=>'P21_EXP_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000209)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:وقود;FUEL,رسوم طرق;TOLL,بدل سائق;DRIVER_ALLOWANCE,تحميل;LOADING,تفريغ;UNLOADING,مواقف;PARKING,إصلاح;REPAIR,إطارات;TIRES,مخالفات;FINE,ميزان;WEIGHBRIDGE,جمارك;CUSTOMS,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000211)
,p_name=>'P21_EXP_AMT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000209)
,p_prompt=>'المبلغ'
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
 p_id=>wwv_flow_imp.id(91820290000000212)
,p_name=>'P21_EXP_L'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000209)
,p_prompt=>'اللترات (للوقود)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000213)
,p_name=>'P21_EXP_REF'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000209)
,p_prompt=>'رقم الإيصال'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000214)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000209)
,p_button_name=>'ADD_EXP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة المصروف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000215)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Expense'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'  l := noona_trn_pkg.add_expense(:P21_ID, :P21_EXP_TYPE, to_number(:P21_EXP_AMT), to_number(:P21_EXP_L), trunc(sysdate), :P21_EXP_REF);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000214)
,p_process_success_message=>'أضيف المصروف'
,p_internal_uid=>91820290000000215
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000216)
,p_plug_name=>'الأعطال والبلاغات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, i.doc_no, i.reported_at, noona_trn_pkg.incident_label(i.incident_type) incident_type, noona_trn_pkg.severity_label(i.severity) severity, i.description, i.assigned_to, i.response_action, i.downtime_minutes, i.cost_amount,',
'       noona_trn_pkg.badge(i.status_code) status_html from trn_incident i where i.trip_id = :P21_ID order by i.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الأعطال والبلاغات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000217)
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
,p_detail_link=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820290000000217
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000219)
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
 p_id=>wwv_flow_imp.id(91820290000000220)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'البلاغ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000221)
,p_db_column_name=>'REPORTED_AT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000222)
,p_db_column_name=>'INCIDENT_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000223)
,p_db_column_name=>'SEVERITY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الخطورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000224)
,p_db_column_name=>'DESCRIPTION'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الوصف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000225)
,p_db_column_name=>'ASSIGNED_TO'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المكلف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000226)
,p_db_column_name=>'RESPONSE_ACTION'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الاستجابة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000227)
,p_db_column_name=>'DOWNTIME_MINUTES'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'التوقف (د)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000228)
,p_db_column_name=>'COST_AMOUNT'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'التكلفة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000229)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000218)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'218'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:REPORTED_AT:INCIDENT_TYPE:SEVERITY:DESCRIPTION:ASSIGNED_TO:RESPONSE_ACTION:DOWNTIME_MINUTES:COST_AMOUNT:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000230)
,p_plug_name=>'بلاغ'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>55
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000231)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000230)
,p_button_name=>'NEW_INC'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تسجيل عطل أو بلاغ لهذه الرحلة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_TRIP:&P21_ID.'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000232)
,p_branch_action=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.::P21_ID:&P21_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
