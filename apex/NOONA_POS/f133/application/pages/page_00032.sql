prompt --application/pages/page_00032
begin
--   Manifest
--     PAGE: 00032
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>32
,p_name=>'Close Shift'
,p_alias=>'CLOSE-SHIFT'
,p_step_title=>'تقرير الوردية وإقفالها'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000168)
,p_plug_name=>'الوردية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000169)
,p_name=>'P32_TERM'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820269000000168)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000170)
,p_name=>'P32_SHIFT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820269000000168)
,p_prompt=>'الوردية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t.name_ar || '' - وردية '' || s.id || '' - '' || to_char(s.opened_at, ''YYYY-MM-DD HH24:MI'') || case s.status_code when ''OPEN'' then '' (مفتوحة)'' else '''' end d, s.id r from pos_shift s join pos_terminal t on t.id = s.terminal_id where s.company_id = noona_pos_pkg.company and (s.status_code = ''OPEN'' or s.opened_at > sysdate - 7) order by s.id desc'
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
 p_id=>wwv_flow_imp.id(91820269000000171)
,p_name=>'P32_COUNTED'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820269000000168)
,p_prompt=>'النقد المعدود في الدرج'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000172)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Default Shift'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P32_SHIFT is null then select max(id) into :P32_SHIFT from pos_shift where company_id = noona_pos_pkg.company and status_code = ''OPEN''',
'    and (terminal_id = :P32_TERM or :P32_TERM is null); end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000172
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000173)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000168)
,p_button_name=>'SHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عرض التقرير'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000174)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820269000000168)
,p_button_name=>'CLOSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إقفال الوردية وترحيل القيد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000175)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820269000000168)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000176)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    if :P32_COUNTED is null then raise_application_error(-20001, ''أدخل النقد المعدود في الدرج''); end if;',
'    l := noona_pos_pkg.close_shift(:P32_SHIFT, to_number(:P32_COUNTED));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820269000000174)
,p_process_success_message=>'تم إقفال الوردية وترحيل قيد مبيعات نقطة البيع (مع فرق النقدية إن وجد)'
,p_internal_uid=>91820269000000176
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000177)
,p_plug_name=>'تقرير الوردية'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return case when :P32_SHIFT is not null then noona_pos_pkg.x_report(:P32_SHIFT) end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820269000000178)
,p_branch_action=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:32:P32_SHIFT:&P32_SHIFT.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
