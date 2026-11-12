prompt --application/pages/page_00030
begin
--   Manifest
--     PAGE: 00030
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
 p_id=>30
,p_name=>'Data Export'
,p_alias=>'EXPORT'
,p_step_title=>'تصدير البيانات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820310000000012)
,p_reload_on_submit=>'A'
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000192)
,p_plug_name=>'مجموعة البيانات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يصدر بيانات الشركة الحالية التي لديك صلاحية عرضها، بعناوين أعمدة عربية، دون الأعمدة الحساسة. لتصدير تقرير بمرشحاته استخدم «الإجراءات ← تنزيل» في التقرير نفسه.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000193)
,p_name=>'P30_TABLE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820310000000192)
,p_prompt=>'البيانات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.name_ar || '' ('' || e.module_code || '')'' d, e.table_name r from ref_entity_type e where e.is_active = ''Y'' and noona_security_pkg.has_permission(e.table_name || ''.VIEW'', noona_eng_pkg.company) = ''Y'' order by e.module_code, e.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820310000000194)
,p_name=>'P30_FMT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820310000000192)
,p_prompt=>'الصيغة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Excel (xlsx);XLSX,CSV;CSV'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820310000000196)
,p_validation_name=>'P30_TABLE required (EXPORT)'
,p_validation_sequence=>3
,p_validation=>'P30_TABLE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820310000000195)
,p_associated_item=>wwv_flow_imp.id(91820310000000193)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820310000000195)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820310000000192)
,p_button_name=>'EXPORT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تصدير وتنزيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820310000000197)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Export'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_ctx apex_exec.t_context;',
'  l_exp apex_data_export.t_export;',
'begin',
'  l_ctx := apex_exec.open_query_context(p_location => apex_exec.c_location_local_db, p_sql_query => noona_eng_pkg.export_sql(:P30_TABLE));',
'  l_exp := apex_data_export.export(p_context => l_ctx,',
'            p_format => case :P30_FMT when ''CSV'' then apex_data_export.c_format_csv else apex_data_export.c_format_xlsx end,',
'            p_file_name => noona_eng_pkg.export_name(:P30_TABLE));',
'  apex_exec.close(l_ctx);',
'  apex_data_export.download(p_export => l_exp);',
'exception when others then',
'  apex_exec.close(l_ctx);',
'  raise;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820310000000195)
,p_internal_uid=>91820310000000197
);

wwv_flow_imp.component_end;
end;
/
