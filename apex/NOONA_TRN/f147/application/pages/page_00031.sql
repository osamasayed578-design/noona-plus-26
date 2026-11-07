prompt --application/pages/page_00031
begin
--   Manifest
--     PAGE: 00031
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
 p_id=>31
,p_name=>'Incident'
,p_alias=>'INCIDENT'
,p_step_title=>'عطل أو بلاغ'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000254)
,p_plug_name=>'البلاغ'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P31_ID is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000255)
,p_name=>'P31_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000256)
,p_name=>'P31_TRIP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
,p_prompt=>'الرحلة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t.doc_no || '' · '' || v.plate_no || '' · '' || d.full_name d, t.id r from trn_trip t join trn_vehicle v on v.id = t.vehicle_id join trn_driver d on d.id = t.driver_id where t.company_id = noona_trn_pkg.company and t.status_code in (''PLANNED'',''DISPATCHED'',''IN_TRANSIT'',''ARRIVED'') order by t.id desc'
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
 p_id=>wwv_flow_imp.id(91820290000000257)
,p_name=>'P31_VEH'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
,p_prompt=>'أو العربة (خارج رحلة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select plate_no d, id r from trn_vehicle where company_id = noona_trn_pkg.company order by plate_no'
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
 p_id=>wwv_flow_imp.id(91820290000000258)
,p_name=>'P31_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
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
 p_id=>wwv_flow_imp.id(91820290000000259)
,p_name=>'P31_SEV'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
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
 p_id=>wwv_flow_imp.id(91820290000000260)
,p_name=>'P31_DESC'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
,p_prompt=>'الوصف'
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
 p_id=>wwv_flow_imp.id(91820290000000261)
,p_name=>'P31_LOC'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
,p_prompt=>'أقرب موقع'
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
 p_id=>wwv_flow_imp.id(91820290000000262)
,p_name=>'P31_LOC_TXT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
,p_prompt=>'وصف المكان (كيلومتر، طريق...)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
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
 p_id=>wwv_flow_imp.id(91820290000000263)
,p_name=>'P31_BY'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820290000000254)
,p_prompt=>'المبلّغ'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>200
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000265)
,p_validation_name=>'P31_DESC required (REPORT)'
,p_validation_sequence=>10
,p_validation=>'P31_DESC'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000264)
,p_associated_item=>wwv_flow_imp.id(91820290000000260)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000264)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000254)
,p_button_name=>'REPORT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل البلاغ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000266)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Report'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'  select json_object(''trip'' value to_number(:P31_TRIP), ''vehicle'' value to_number(:P31_VEH), ''type'' value :P31_TYPE, ''severity'' value :P31_SEV,',
'         ''description'' value :P31_DESC, ''location'' value to_number(:P31_LOC), ''locationText'' value :P31_LOC_TXT, ''reportedBy'' value :P31_BY',
'         absent on null) into l from dual;',
'  :P31_ID := noona_trn_pkg.report_incident(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000264)
,p_process_success_message=>'سجل البلاغ؛ تابع الاستجابة من هنا'
,p_internal_uid=>91820290000000266
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000267)
,p_plug_name=>'تفاصيل البلاغ'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P31_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'  for i in (select i.*, v.plate_no, t.doc_no trip_no from trn_incident i join trn_vehicle v on v.id = i.vehicle_id left join trn_trip t on t.id = i.trip_id',
'             where i.id = :P31_ID and i.company_id = noona_trn_pkg.company) loop',
'    l := ''<dl class="nn-trn-facts"><div><dt>البلاغ</dt><dd>'' || apex_escape.html(i.doc_no) || '' '' || noona_trn_pkg.badge(i.status_code) || ''</dd></div>''',
'      || ''<div><dt>العربة</dt><dd>'' || apex_escape.html(i.plate_no) || ''</dd></div><div><dt>الرحلة</dt><dd>'' || apex_escape.html(nvl(i.trip_no, ''—'')) || ''</dd></div>''',
'      || ''<div><dt>النوع / الخطورة</dt><dd>'' || i.incident_type || '' / '' || i.severity || ''</dd></div>''',
'      || ''<div><dt>وقت البلاغ</dt><dd>'' || to_char(i.reported_at, ''YYYY-MM-DD HH24:MI'') || ''</dd></div>''',
'      || ''<div><dt>الاستلام</dt><dd>'' || nvl(to_char(i.acknowledged_at, ''YYYY-MM-DD HH24:MI''), ''—'') || ''</dd></div>''',
'      || ''<div><dt>الحل</dt><dd>'' || nvl(to_char(i.resolved_at, ''YYYY-MM-DD HH24:MI''), ''—'') || ''</dd></div>''',
'      || ''<div><dt>المكلف</dt><dd>'' || apex_escape.html(nvl(i.assigned_to, ''—'')) || ''</dd></div>''',
'      || ''<div><dt>الوصف</dt><dd>'' || apex_escape.html(i.description) || ''</dd></div>''',
'      || ''<div><dt>الاستجابة</dt><dd>'' || apex_escape.html(nvl(i.response_action, ''—'')) || ''</dd></div></dl>'';',
'  end loop;',
'  return l;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000268)
,p_plug_name=>'الاستجابة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_trn_pkg.incident_status(:P31_ID) in (''REPORTED'',''ACKNOWLEDGED'',''IN_PROGRESS'',''RESOLVED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000269)
,p_name=>'P31_ASSIGN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000268)
,p_prompt=>'المكلف بالاستجابة'
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
 p_id=>wwv_flow_imp.id(91820290000000270)
,p_name=>'P31_ACTION'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000268)
,p_prompt=>'الإجراء'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000271)
,p_name=>'P31_DOWN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000268)
,p_prompt=>'مدة التوقف (دقيقة)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000272)
,p_name=>'P31_COST'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000268)
,p_prompt=>'التكلفة'
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
 p_id=>wwv_flow_imp.id(91820290000000273)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000268)
,p_button_name=>'ACK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'استلام وتكليف'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.incident_status(:P31_ID) in (''REPORTED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000274)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000268)
,p_button_name=>'RESPOND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'بدء الاستجابة'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.incident_status(:P31_ID) in (''REPORTED'',''ACKNOWLEDGED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000275)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820290000000268)
,p_button_name=>'RESOLVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تم الحل'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.incident_status(:P31_ID) in (''REPORTED'',''ACKNOWLEDGED'',''IN_PROGRESS'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000276)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820290000000268)
,p_button_name=>'CLOSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إغلاق البلاغ'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_trn_pkg.incident_status(:P31_ID) in (''RESOLVED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000277)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Ack'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.acknowledge_incident(:P31_ID, :P31_ASSIGN);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000273)
,p_process_success_message=>'استلم البلاغ'
,p_internal_uid=>91820290000000277
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000278)
,p_process_sequence=>31
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Respond'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.respond_incident(:P31_ID, :P31_ACTION);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000274)
,p_process_success_message=>'بدأت الاستجابة'
,p_internal_uid=>91820290000000278
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000279)
,p_process_sequence=>32
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Resolve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.resolve_incident(:P31_ID, :P31_ACTION, to_number(:P31_DOWN), to_number(:P31_COST));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000275)
,p_process_success_message=>'تم الحل؛ أضيف التوقف لتأخير الرحلة والتكلفة لمصروفاتها'
,p_internal_uid=>91820290000000279
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000280)
,p_process_sequence=>33
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.close_incident(:P31_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000276)
,p_process_success_message=>'أغلق البلاغ'
,p_internal_uid=>91820290000000280
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000281)
,p_branch_action=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.::P31_ID:&P31_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
