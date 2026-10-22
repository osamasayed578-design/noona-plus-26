prompt --application/pages/page_00040
begin
--   Manifest
--     PAGE: 00040
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>135
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>40
,p_name=>'MRP'
,p_alias=>'MRP'
,p_step_title=>'تخطيط احتياجات المواد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''mfg.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000172)
,p_plug_name=>'الخيارات'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000173)
,p_name=>'P40_REORDER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820270000000172)
,p_prompt=>'الوصول لحدود الطلب (الحد الأدنى والأعلى)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000174)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000172)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إعادة الحساب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000175)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P40_REORDER := nvl(:P40_REORDER, ''Y'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000175
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000176)
,p_plug_name=>'المقترحات'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    function js(p clob) return clob is begin return replace(p, ''</'', ''<\/''); end;',
'begin',
'    return ''<script type="application/json" id="nnMfgData">'' || js(noona_mfg_pkg.mrp_json(nvl(:P40_REORDER, ''Y''))) || ''</script>''',
'        || ''<script type="application/json" id="nnMfgLists">'' || js(noona_mfg_pkg.lists_json(''whs'')) || ''</script>''',
'        || ''<div id="nnMrp" class="nn-doc nn-td nn-mfg" data-co="''',
'        || apex_escape.html_attribute(noona_apex_pkg.company_name) || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000177)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'EXEC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_c clob;',
'begin',
'    l_c := noona_mfg_pkg.mrp_execute(apex_application.g_clob_01);',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''orders'', json_value(l_c, ''$.orders'' returning number));',
'    apex_json.write(''req'', json_value(l_c, ''$.reqNo''));',
'    apex_json.write(''url'', apex_page.get_url(p_page => 30));',
'    apex_json.close_object;',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000177
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820270000000178)
,p_branch_action=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:40:P40_REORDER:&P40_REORDER.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
