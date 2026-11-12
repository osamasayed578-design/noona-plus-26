prompt --application/pages/page_00071
begin
--   Manifest
--     PAGE: 00071
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
 p_id=>71
,p_name=>'My Trip'
,p_alias=>'MY-TRIP'
,p_step_title=>'رحلتي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000710)
,p_plug_name=>'الرحلة'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000711)
,p_name=>'P71_TRIP'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000710)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000712)
,p_plug_name=>'الرحلة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_trn_pkg.driver_trip_html(:P71_TRIP);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000713)
,p_plug_name=>'التحرك'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P71_TRIP) in (''PLANNED'', ''DISPATCHED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000714)
,p_name=>'P71_ODO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000713)
,p_prompt=>'قراءة العداد عند التحرك'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000715)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000713)
,p_button_name=>'DEPART'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'بدء الرحلة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000716)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Depart'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.depart(:P71_TRIP, to_number(:P71_ODO));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000715)
,p_process_success_message=>'بدأت الرحلة؛ طريق السلامة'
,p_internal_uid=>91820290000000716
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000717)
,p_plug_name=>'التسليم'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P71_TRIP) in (''IN_TRANSIT'', ''ARRIVED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000718)
,p_name=>'P71_ORDER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000717)
,p_prompt=>'الشحنة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select o.doc_no || '' · '' || noona_sal_pkg.customer_label(o.customer_account_id) d, o.id r from trn_trip_order x join trn_order o on o.id = x.order_id where x.trip_id = :P71_TRIP and o.status_code = ''IN_TRANSIT'' order by o.id'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر الشحنة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000719)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000717)
,p_button_name=>'POD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسليم بالصورة والتوقيع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000720)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000717)
,p_button_name=>'ARRIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'وصلت الوجهة'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.trip_status(:P71_TRIP) = ''IN_TRANSIT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000721)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Arrive'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.arrive(:P71_TRIP);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000720)
,p_process_success_message=>'تم تسجيل الوصول'
,p_internal_uid=>91820290000000721
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000722)
,p_plug_name=>'إقفال الرحلة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P71_TRIP) in (''IN_TRANSIT'', ''ARRIVED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000723)
,p_name=>'P71_ODO_END'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000722)
,p_prompt=>'قراءة العداد عند العودة'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000724)
,p_name=>'P71_FUEL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000722)
,p_prompt=>'الوقود المستهلك (لتر)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000725)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000722)
,p_button_name=>'COMPLETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إقفال الرحلة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000726)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Complete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.complete_trip(:P71_TRIP, to_number(:P71_ODO_END), to_number(:P71_FUEL));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000725)
,p_process_success_message=>'تم إقفال الرحلة'
,p_internal_uid=>91820290000000726
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000727)
,p_plug_name=>'عطل أو بلاغ'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.trip_status(:P71_TRIP) in (''DISPATCHED'', ''IN_TRANSIT'', ''ARRIVED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000728)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000727)
,p_button_name=>'INCIDENT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'الإبلاغ عن عطل بالموقع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:73:&SESSION.::&DEBUG.:RP,73:P73_TRIP:&P71_TRIP.'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000729)
,p_branch_action=>'f?p=&APP_ID.:72:&SESSION.::&DEBUG.:RP,72:P72_TRIP,P72_ORDER:&P71_TRIP.,&P71_ORDER.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820290000000719)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000730)
,p_branch_action=>'f?p=&APP_ID.:71:&SESSION.::&DEBUG.::P71_TRIP:&P71_TRIP.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
