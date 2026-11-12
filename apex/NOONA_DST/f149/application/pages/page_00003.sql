prompt --application/pages/page_00003
begin
--   Manifest
--     PAGE: 00003
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
 p_id=>3
,p_name=>'Van Load'
,p_alias=>'LOAD'
,p_step_title=>'تحميل وتفريغ السيارة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''dst.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000074)
,p_plug_name=>'الحركة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">التحميل ينقل من مستودع الشركة إلى مستودع السيارة، والتفريغ يعيد المتبقي. يغير الاتجاه أو المستودع قائمة الأصناف.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000075)
,p_name=>'P3_REP'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820300000000074)
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
 p_id=>wwv_flow_imp.id(91820300000000076)
,p_name=>'P3_DIR'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000074)
,p_prompt=>'الاتجاه'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تحميل من المستودع;LOAD,تفريغ إلى المستودع;UNLOAD'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000077)
,p_name=>'P3_WH'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000074)
,p_prompt=>'مستودع الشركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select w.name_ar || '' ('' || w.code || '')'' d, w.id r from inv_warehouse w where w.company_id = noona_dst_pkg.company and w.status_code = ''ACTIVE'' and not exists (select 1 from dst_rep x where x.van_warehouse_id = w.id) order by w.name_ar'
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
 p_id=>wwv_flow_imp.id(91820300000000078)
,p_name=>'P3_LINES'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820300000000074)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000079)
,p_name=>'P3_NOTES'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820300000000074)
,p_prompt=>'ملاحظات'
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
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000080)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P3_REP is null then :P3_REP := noona_dst_pkg.my_rep; end if;',
'  if :P3_DIR is null then :P3_DIR := ''LOAD''; end if;',
'  if :P3_WH is null then :P3_WH := noona_inv_pkg.default_warehouse; end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820300000000080
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000081)
,p_plug_name=>'الأصناف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P3_REP is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div data-item="P3_LINES">'' || noona_dst_pkg.items_picker_html(:P3_REP, :P3_DIR, :P3_WH) || ''</div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000082)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000074)
,p_button_name=>'POST'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'ترحيل الحركة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000083)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Post'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t(); l_id number;',
'begin',
'  l.put(''rep'', to_number(:P3_REP)); l.put(''direction'', :P3_DIR); l.put(''wh'', to_number(:P3_WH)); l.put(''notes'', :P3_NOTES);',
'  l.put(''lines'', json_array_t(nvl(:P3_LINES, ''[]'')));',
'  l_id := noona_dst_pkg.load_van(l.to_clob);',
'  :P3_LINES := null; :P3_NOTES := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000082)
,p_process_success_message=>'تم ترحيل حركة السيارة'
,p_internal_uid=>91820300000000083
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000084)
,p_plug_name=>'مخزون السيارة الآن'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P3_REP is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.van_stock_html(:P3_REP);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000085)
,p_branch_action=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
