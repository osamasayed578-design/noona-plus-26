prompt --application/pages/page_00053
begin
--   Manifest
--     PAGE: 00053
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
 p_id=>53
,p_name=>'Cargo-Types'
,p_alias=>'CARGO-TYPES'
,p_step_title=>'أنواع الشحنات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000558)
,p_plug_name=>'أنواع الشحنات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select c.id, c.code, c.name_ar, c.cargo_category, noona_trn_pkg.uom_label(c.default_unit) unit, c.required_vehicle_type, c.hazard_class, c.handling_notes',
'  from trn_cargo_type c where c.company_id = noona_trn_pkg.company order by c.name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أنواع الشحنات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000559)
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
,p_detail_link=>'f?p=&APP_ID.:53:&SESSION.::&DEBUG.:RP:P53_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820290000000559
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000561)
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
 p_id=>wwv_flow_imp.id(91820290000000562)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000563)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000564)
,p_db_column_name=>'CARGO_CATEGORY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000565)
,p_db_column_name=>'UNIT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الوحدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000566)
,p_db_column_name=>'REQUIRED_VEHICLE_TYPE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'العربة المطلوبة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000567)
,p_db_column_name=>'HAZARD_CLASS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'فئة الخطورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000568)
,p_db_column_name=>'HANDLING_NOTES'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'تعليمات المناولة والتفريغ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000560)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'560'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:CARGO_CATEGORY:UNIT:REQUIRED_VEHICLE_TYPE:HAZARD_CLASS:HANDLING_NOTES'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000569)
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
 p_id=>wwv_flow_imp.id(91820290000000570)
,p_name=>'P53_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000571)
,p_name=>'P53_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>50
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000572)
,p_name=>'P53_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_prompt=>'الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>200
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
 p_id=>wwv_flow_imp.id(91820290000000573)
,p_name=>'P53_CAT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_prompt=>'الفئة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عامة;GENERAL,سائبة;BULK,سائلة;LIQUID,مبردة;REFRIGERATED,خطرة;HAZARDOUS,حاويات;CONTAINER,مركبات;VEHICLES,مواشي;LIVESTOCK,قابلة للكسر;FRAGILE,بأبعاد استثنائية;OVERSIZED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000574)
,p_name=>'P53_UNIT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_prompt=>'الوحدة الافتراضية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:طن متري;METRIC_TON,طن قصير (أمريكي);SHORT_TON,طن طويل (بريطاني);LONG_TON,كيلوجرام;KG,متر مكعب;M3,لتر;LITER,حاوية;CONTAINER,طبلية;PALLET,قطعة;PIECE,رحلة;TRIP'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000575)
,p_name=>'P53_VT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_prompt=>'نوع العربة المطلوب'
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
 p_id=>wwv_flow_imp.id(91820290000000576)
,p_name=>'P53_HAZ'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_prompt=>'فئة الخطورة (UN)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000577)
,p_name=>'P53_HND'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_prompt=>'تعليمات المناولة والتفريغ'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>1000
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000578)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000569)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000579)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob; l_id number;',
'begin',
'  select json_object(''id'' value to_number(:P53_ID), ''code'' value :P53_CODE, ''name'' value :P53_NAME, ''category'' value :P53_CAT, ''unit'' value :P53_UNIT, ''vehicleType'' value :P53_VT, ''hazardClass'' value :P53_HAZ, ''handling'' value :P53_HND absent on null) into l from dual;',
'  l_id := noona_trn_pkg.save_cargo_type(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000578)
,p_process_success_message=>'تم الحفظ'
,p_internal_uid=>91820290000000579
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000580)
,p_branch_action=>'f?p=&APP_ID.:53:&SESSION.::&DEBUG.:RP,53::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000581)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for c in (select * from trn_cargo_type where id = :P53_ID and company_id = noona_trn_pkg.company) loop',
'    :P53_CODE := c.code; :P53_NAME := c.name_ar; :P53_CAT := c.cargo_category; :P53_UNIT := c.default_unit; :P53_VT := c.required_vehicle_type;',
'    :P53_HAZ := c.hazard_class; :P53_HND := c.handling_notes;',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000581
);

wwv_flow_imp.component_end;
end;
/
