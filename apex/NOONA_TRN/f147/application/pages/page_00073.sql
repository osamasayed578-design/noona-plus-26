prompt --application/pages/page_00073
begin
--   Manifest
--     PAGE: 00073
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
 p_id=>73
,p_name=>'Report Incident'
,p_alias=>'REPORT-INCIDENT'
,p_step_title=>'الإبلاغ عن عطل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { [''dst.js'', ''pod.js''].forEach(function (f) { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + f; document.head.appendChild(s); }); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000744)
,p_plug_name=>'البلاغ'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<button type="button" class="nn-dst-btn nn-dst-mygeo" data-lat="P73_LAT" data-lng="P73_LNG"><span class="fa fa-crosshairs"></span> إرفاق موقعي الحالي</button>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000745)
,p_name=>'P73_TRIP'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000744)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000746)
,p_name=>'P73_LAT'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820290000000744)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000747)
,p_name=>'P73_LNG'
,p_item_sequence=>3
,p_item_plug_id=>wwv_flow_imp.id(91820290000000744)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000748)
,p_name=>'P73_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000744)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عطل ميكانيكي;BREAKDOWN,إطار;TIRE,حادث;ACCIDENT,تأخير;DELAY,تلف الشحنة;CARGO_DAMAGE,سرقة;THEFT,إيقاف أمني/مروري;POLICE,طقس;WEATHER,إغلاق طريق;ROAD_CLOSURE,حالة صحية;MEDICAL,احتجاز حدودي;BORDER_HOLD,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000749)
,p_name=>'P73_SEV'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000744)
,p_prompt=>'الخطورة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:منخفضة;LOW,متوسطة;MEDIUM,عالية;HIGH,حرجة;CRITICAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000750)
,p_name=>'P73_DESC'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000744)
,p_prompt=>'ماذا حدث؟'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000751)
,p_name=>'P73_PLACE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000744)
,p_prompt=>'وصف المكان'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000753)
,p_validation_name=>'P73_DESC required (REPORT)'
,p_validation_sequence=>8
,p_validation=>'P73_DESC'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000752)
,p_associated_item=>wwv_flow_imp.id(91820290000000750)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000752)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000744)
,p_button_name=>'REPORT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال البلاغ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000754)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P73_SEV is null then :P73_SEV := ''MEDIUM''; end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000754
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000755)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Report'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t(); l_id number;',
'begin',
'  l.put(''trip'', to_number(:P73_TRIP)); l.put(''type'', :P73_TYPE); l.put(''severity'', :P73_SEV); l.put(''description'', :P73_DESC);',
'  l.put(''locationText'', nvl(:P73_PLACE, case when :P73_LAT is not null then ''GPS '' || :P73_LAT || '','' || :P73_LNG end));',
'  l.put(''lat'', to_number(:P73_LAT)); l.put(''lng'', to_number(:P73_LNG));',
'  l_id := noona_trn_pkg.report_incident(l.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000752)
,p_process_success_message=>'تم إرسال البلاغ؛ سيتواصل معك فريق الأسطول'
,p_internal_uid=>91820290000000755
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000756)
,p_branch_action=>'f?p=&APP_ID.:71:&SESSION.::&DEBUG.::P71_TRIP:&P73_TRIP.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
