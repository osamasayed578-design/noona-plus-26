prompt --application/pages/page_00004
begin
--   Manifest
--     PAGE: 00004
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>4
,p_name=>'End of Day'
,p_alias=>'END-OF-DAY'
,p_step_title=>'تسوية نهاية اليوم'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000086)
,p_plug_name=>'اليوم'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000087)
,p_name=>'P4_REP'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820300000000086)
,p_prompt=>'المندوب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select full_name || '' ('' || code || '')'' d, id r from dst_rep where company_id = noona_dst_pkg.company and status_code = ''ACTIVE'' order by full_name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000088)
,p_name=>'P4_DATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000086)
,p_prompt=>'اليوم'
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
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000089)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P4_REP is null then :P4_REP := noona_dst_pkg.my_rep; end if;',
'  if :P4_DATE is null then :P4_DATE := to_char(sysdate, ''YYYY-MM-DD''); end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820300000000089
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000090)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000086)
,p_button_name=>'SHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000091)
,p_plug_name=>'ملخص اليوم'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P4_REP is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.settlement_preview_html(:P4_REP, to_date(:P4_DATE, ''YYYY-MM-DD''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000092)
,p_plug_name=>'تسليم النقد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">أدخل النقد الذي تسلمه فعلاً. ينقل للصندوق المختار، والعجز يبقى على عهدة المندوب حتى يسوى. إشعارات التحويل والشيكات تؤكد من المحاسب.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P4_REP is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000093)
,p_name=>'P4_COUNTED'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000092)
,p_prompt=>'النقد المسلم'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000094)
,p_name=>'P4_BOX'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000092)
,p_prompt=>'الصندوق المستلم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select b.name_ar || '' ('' || b.code || '')'' d, b.id r from csh_cash_box b where b.company_id = noona_dst_pkg.company and b.status_code = ''ACTIVE'' and not exists (select 1 from dst_rep x where x.cash_box_id = b.id) order by decode(b.box_type, ''MAIN'', 0, 1), b.name_ar'
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
 p_id=>wwv_flow_imp.id(91820300000000095)
,p_name=>'P4_NOTES'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820300000000092)
,p_prompt=>'ملاحظات'
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
 p_id=>wwv_flow_imp.id(91820300000000096)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000092)
,p_button_name=>'SETTLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسوية اليوم'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000097)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Settle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t(); l_id number;',
'begin',
'  l.put(''rep'', to_number(:P4_REP)); l.put(''date'', :P4_DATE); l.put(''counted'', nvl(to_number(:P4_COUNTED), 0));',
'  l.put(''box'', to_number(:P4_BOX)); l.put(''notes'', :P4_NOTES);',
'  l_id := noona_dst_pkg.settle_day(l.to_clob);',
'  :P4_COUNTED := null; :P4_NOTES := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000096)
,p_process_success_message=>'تمت تسوية اليوم وتسليم النقد'
,p_internal_uid=>91820300000000097
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000098)
,p_branch_action=>'f?p=&APP_ID.:4:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
