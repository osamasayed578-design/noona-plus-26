prompt --application/pages/page_00004
begin
--   Manifest
--     PAGE: 00004
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>151
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>4
,p_name=>'Alert'
,p_alias=>'ALERT'
,p_step_title=>'تنبيه'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820310000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000040)
,p_plug_name=>'التنبيه'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000041)
,p_name=>'P4_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820310000000040)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000042)
,p_plug_name=>'التفاصيل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_h varchar2(32767);',
'begin',
'  for a in (select a.*, r.name_ar rn from eng_alert a join eng_alert_rule r on r.id = a.rule_id where a.id = :P4_ID and a.company_id = noona_eng_pkg.company) loop',
'    l_h := ''<div class="nn-al nn-al-'' || lower(a.severity) || ''">'' || noona_eng_pkg.badge(a.severity) || '' <b>'' || apex_escape.html(a.title) || ''</b>''',
'        || ''<small>'' || apex_escape.html(a.rn) || '' · '' || to_char(a.alert_date, ''YYYY-MM-DD'') || '' · '' || noona_eng_pkg.badge(a.status_code) || ''</small>''',
'        || case when a.detail is not null then ''<p>'' || apex_escape.html(a.detail) || ''</p>'' end || ''</div>'';',
'  end loop;',
'  return l_h;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000043)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000040)
,p_button_name=>'ACK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'استلام'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000044)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820310000000040)
,p_button_name=>'CLOSE_ALERT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إغلاق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000045)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Ack'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_eng_pkg.ack_alert(:P4_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000043)
,p_process_success_message=>'تم استلام التنبيه'
,p_internal_uid=>91820310000000045
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000046)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_eng_pkg.close_alert(:P4_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000044)
,p_process_success_message=>'تم إغلاق التنبيه'
,p_internal_uid=>91820310000000046
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820310000000047)
,p_branch_action=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
