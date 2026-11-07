prompt --application/pages/page_00040
begin
--   Manifest
--     PAGE: 00040
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
 p_id=>40
,p_name=>'Fleet'
,p_alias=>'FLEET'
,p_step_title=>'العربات والشاحنات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000282)
,p_plug_name=>'العربات والشاحنات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select v.id, v.plate_no, decode(v.vehicle_type, ''TRUCK'', ''شاحنة'', ''TRAILER'', ''مقطورة'', ''TANKER'', ''صهريج'', ''REFRIGERATED'', ''مبردة'', ''FLATBED'', ''سطحة'',',
'       ''CONTAINER_CARRIER'', ''ناقلة حاويات'', ''TIPPER'', ''قلاب'', ''LOWBED'', ''لوبد'', ''PICKUP'', ''بيك أب'', ''VAN'', ''فان'', v.vehicle_type) vehicle_type,',
'       v.make, v.model, v.model_year, v.capacity_tons, v.capacity_m3, v.odometer_km, v.license_expiry, v.insurance_expiry,',
'       noona_trn_pkg.badge(v.status_code) status_html,',
'       (select count(*) from trn_trip t where t.vehicle_id = v.id and t.status_code = ''COMPLETED'') trips,',
'       (select count(*) from trn_incident i where i.vehicle_id = v.id) incidents',
'  from trn_vehicle v where v.company_id = noona_trn_pkg.company order by v.plate_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'العربات والشاحنات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000283)
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
,p_detail_link=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:RP:P40_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820290000000283
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000285)
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
 p_id=>wwv_flow_imp.id(91820290000000286)
,p_db_column_name=>'PLATE_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'اللوحة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000287)
,p_db_column_name=>'VEHICLE_TYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000288)
,p_db_column_name=>'MAKE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الصانع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000289)
,p_db_column_name=>'MODEL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الطراز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000290)
,p_db_column_name=>'MODEL_YEAR'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'السنة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000291)
,p_db_column_name=>'CAPACITY_TONS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الحمولة (طن)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000292)
,p_db_column_name=>'CAPACITY_M3'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'م³'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000293)
,p_db_column_name=>'ODOMETER_KM'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'العداد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000294)
,p_db_column_name=>'LICENSE_EXPIRY'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'انتهاء الترخيص'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000295)
,p_db_column_name=>'INSURANCE_EXPIRY'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'انتهاء التأمين'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000296)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000297)
,p_db_column_name=>'TRIPS'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الرحلات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000298)
,p_db_column_name=>'INCIDENTS'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'البلاغات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000284)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'284'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PLATE_NO:VEHICLE_TYPE:MAKE:MODEL:MODEL_YEAR:CAPACITY_TONS:CAPACITY_M3:ODOMETER_KM:LICENSE_EXPIRY:INSURANCE_EXPIRY:STATUS_HTML:TRIPS:INCIDENTS'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000299)
,p_plug_name=>'إضافة / تعديل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000300)
,p_name=>'P40_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000301)
,p_name=>'P40_PLATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'رقم اللوحة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000302)
,p_name=>'P40_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:شاحنة;TRUCK,مقطورة;TRAILER,صهريج;TANKER,مبردة;REFRIGERATED,سطحة;FLATBED,ناقلة حاويات;CONTAINER_CARRIER,قلاب;TIPPER,لوبد (معدات ثقيلة);LOWBED,بيك أب;PICKUP,فان;VAN'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000303)
,p_name=>'P40_MAKE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'الصانع'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000304)
,p_name=>'P40_MODEL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'الطراز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000305)
,p_name=>'P40_YEAR'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'سنة الصنع'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000306)
,p_name=>'P40_CAP'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'الحمولة القصوى (طن متري)'
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
 p_id=>wwv_flow_imp.id(91820290000000307)
,p_name=>'P40_M3'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'السعة (م³)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000308)
,p_name=>'P40_ODO'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'العداد (كم)'
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
 p_id=>wwv_flow_imp.id(91820290000000309)
,p_name=>'P40_FUEL'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'استهلاك الوقود لتر/100كم'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000310)
,p_name=>'P40_LIC'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'انتهاء الترخيص'
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
 p_id=>wwv_flow_imp.id(91820290000000311)
,p_name=>'P40_INS'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_prompt=>'انتهاء التأمين'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000312)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000299)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000313)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob; l_id number;',
'begin',
'  select json_object(''id'' value to_number(:P40_ID), ''plate'' value :P40_PLATE, ''type'' value :P40_TYPE, ''make'' value :P40_MAKE, ''model'' value :P40_MODEL, ''year'' value to_number(:P40_YEAR), ''capacityTons'' value to_number(:P40_CAP), ''capacityM3'' value to_number(:P40_M3), ''odometer'' value to_number(:P40_ODO), ''fuelPer100'' value to_number(:P40_FUEL), ''licenseExpiry'' value :P40_LIC, ''insuranceExpiry'' value :P40_INS absent on null) into l from dual;',
'  l_id := noona_trn_pkg.save_vehicle(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000312)
,p_process_success_message=>'تم الحفظ'
,p_internal_uid=>91820290000000313
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000314)
,p_branch_action=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:RP,40::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000315)
,p_plug_name=>'حالة العربة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000316)
,p_name=>'P40_SET'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000315)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:متاحة;AVAILABLE,في الصيانة;MAINTENANCE,خارج الخدمة;OUT_OF_SERVICE,مباعة;SOLD'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000317)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000315)
,p_button_name=>'SET_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير حالة العربة المختارة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000318)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.set_vehicle_status(:P40_ID, :P40_SET);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000317)
,p_process_success_message=>'تم تغيير الحالة'
,p_internal_uid=>91820290000000318
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000319)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for v in (select * from trn_vehicle where id = :P40_ID and company_id = noona_trn_pkg.company) loop',
'    :P40_PLATE := v.plate_no; :P40_TYPE := v.vehicle_type; :P40_MAKE := v.make; :P40_MODEL := v.model; :P40_YEAR := v.model_year;',
'    :P40_CAP := v.capacity_tons; :P40_M3 := v.capacity_m3; :P40_ODO := v.odometer_km; :P40_FUEL := v.fuel_l_per_100km;',
'    :P40_LIC := to_char(v.license_expiry, ''YYYY-MM-DD''); :P40_INS := to_char(v.insurance_expiry, ''YYYY-MM-DD''); :P40_SET := v.status_code;',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000319
);

wwv_flow_imp.component_end;
end;
/
