prompt --application/pages/page_00036
begin
--   Manifest
--     PAGE: 00036
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
 p_id=>36
,p_name=>'Maint-Plans'
,p_alias=>'MAINT-PLANS'
,p_step_title=>'برامج الصيانة الدورية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000396)
,p_plug_name=>'برامج الصيانة الدورية'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select p.id, p.service_name, nvl(v.plate_no, ''كل العربات'' || nvl2(p.vehicle_type, '' ('' || p.vehicle_type || '')'', '''')) applies_to,',
'       p.every_km, p.every_days, p.estimated_cost, noona_trn_pkg.badge(p.status_code) status_html',
'  from trn_maint_plan p left join trn_vehicle v on v.id = p.vehicle_id where p.company_id = noona_trn_pkg.company order by p.service_name'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'برامج الصيانة الدورية'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000397)
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
,p_detail_link=>'f?p=&APP_ID.:36:&SESSION.::&DEBUG.:RP:P36_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820290000000397
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000399)
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
 p_id=>wwv_flow_imp.id(91820290000000400)
,p_db_column_name=>'SERVICE_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الخدمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000401)
,p_db_column_name=>'APPLIES_TO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'تنطبق على'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000402)
,p_db_column_name=>'EVERY_KM'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'كل (كم)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000403)
,p_db_column_name=>'EVERY_DAYS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'كل (يوم)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000404)
,p_db_column_name=>'ESTIMATED_COST'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'التكلفة التقديرية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000405)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000398)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'398'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'SERVICE_NAME:APPLIES_TO:EVERY_KM:EVERY_DAYS:ESTIMATED_COST:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000406)
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
 p_id=>wwv_flow_imp.id(91820290000000407)
,p_name=>'P36_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000408)
,p_name=>'P36_SVC'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_prompt=>'الخدمة (تغيير زيت، فرامل، إطارات، فحص دوري...)'
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
 p_id=>wwv_flow_imp.id(91820290000000409)
,p_name=>'P36_VEH'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_prompt=>'عربة محددة (أو اتركها لكل العربات)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select plate_no d, id r from trn_vehicle where company_id = noona_trn_pkg.company and status_code <> ''SOLD'' order by plate_no'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000410)
,p_name=>'P36_VTYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_prompt=>'أو نوع العربات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:شاحنة;TRUCK,مقطورة;TRAILER,صهريج;TANKER,مبردة;REFRIGERATED,سطحة;FLATBED,ناقلة حاويات;CONTAINER_CARRIER,قلاب;TIPPER,لوبد (معدات ثقيلة);LOWBED,بيك أب;PICKUP,فان;VAN'
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
 p_id=>wwv_flow_imp.id(91820290000000411)
,p_name=>'P36_KM'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_prompt=>'كل (كيلومتر)'
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
 p_id=>wwv_flow_imp.id(91820290000000412)
,p_name=>'P36_DAYS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_prompt=>'أو كل (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000413)
,p_name=>'P36_COST'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_prompt=>'التكلفة التقديرية'
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
 p_id=>wwv_flow_imp.id(91820290000000414)
,p_name=>'P36_ST'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,متوقف مؤقتاً;PAUSED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000415)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000406)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000416)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob; l_id number;',
'begin',
'  select json_object(''id'' value to_number(:P36_ID), ''service'' value :P36_SVC, ''vehicle'' value :P36_VEH, ''vehicleType'' value :P36_VTYPE, ''everyKm'' value to_number(:P36_KM), ''everyDays'' value to_number(:P36_DAYS), ''cost'' value to_number(:P36_COST), ''status'' value :P36_ST absent on null) into l from dual;',
'  l_id := noona_trn_pkg.save_maint_plan(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000415)
,p_process_success_message=>'تم الحفظ'
,p_internal_uid=>91820290000000416
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000417)
,p_branch_action=>'f?p=&APP_ID.:36:&SESSION.::&DEBUG.:RP,36::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000418)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for r in (select * from trn_maint_plan where id = :P36_ID and company_id = noona_trn_pkg.company) loop',
'    :P36_SVC := r.service_name; :P36_VEH := r.vehicle_id; :P36_VTYPE := r.vehicle_type; :P36_KM := r.every_km;',
'    :P36_DAYS := r.every_days; :P36_COST := r.estimated_cost; :P36_ST := r.status_code;',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000418
);

wwv_flow_imp.component_end;
end;
/
