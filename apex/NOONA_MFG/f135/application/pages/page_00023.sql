prompt --application/pages/page_00023
begin
--   Manifest
--     PAGE: 00023
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
 p_id=>23
,p_name=>'Routing'
,p_alias=>'ROUTING'
,p_step_title=>'مسار التصنيع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''mfg.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000118)
,p_plug_name=>'المسار'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000119)
,p_name=>'P23_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820270000000118)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000120)
,p_plug_name=>'محرر مسار التصنيع'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    function js(p clob) return clob is begin return replace(p, ''</'', ''<\/''); end;',
'begin',
'    return ''<script type="application/json" id="nnMfgData">'' || js(noona_mfg_pkg.routing_doc_json(:P23_ID)) || ''</script>''',
'        || ''<script type="application/json" id="nnMfgLists">'' || js(noona_mfg_pkg.lists_json(''items,wcs'')) || ''</script>''',
'        || ''<div id="nnRt" class="nn-doc nn-td nn-mfg" data-co="''',
'        || apex_escape.html_attribute(noona_apex_pkg.company_name) || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000121)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SAVE_RT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'    l_c clob;',
'begin',
'    l_id := noona_mfg_pkg.save_routing(apex_application.g_clob_01);',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    if l_id is not null then apex_json.write(''url'', apex_page.get_url(p_page => 23, p_clear_cache => ''23'', p_items => ''P23_ID'', p_values => l_id)); end if;',
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
,p_internal_uid=>91820270000000121
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000122)
,p_process_sequence=>2
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'ACT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'    l_c clob;',
'begin',
'    case apex_application.g_x01',
'        when ''PUBLISH'' then noona_mfg_pkg.publish_routing(apex_application.g_x02);',
'        when ''OBSOLETE'' then noona_mfg_pkg.obsolete_routing(apex_application.g_x02);',
'        when ''NEWVER'' then l_id := noona_mfg_pkg.new_routing_version(apex_application.g_x02);',
'    end case;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    if l_id is not null then apex_json.write(''url'', apex_page.get_url(p_page => 23, p_clear_cache => ''23'', p_items => ''P23_ID'', p_values => l_id)); end if;',
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
,p_internal_uid=>91820270000000122
);

wwv_flow_imp.component_end;
end;
/
