prompt --application/pages/page_00098
begin
--   Manifest
--     PAGE: 00098
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>137
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>98
,p_name=>'Analytics'
,p_alias=>'ANALYTICS'
,p_step_title=>'التحليلات والتنبؤ'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''anl.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000429)
,p_plug_name=>'التحليلات والتنبؤ'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div id="nnAnl" class="nn-anl" data-modules="HR" data-unified="N"></div>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000430)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'ANL'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l clob;',
'    l_pos pls_integer := 1;',
'    l_br number := to_number(nullif(apex_application.g_x03, ''''));',
'begin',
'    l := case apex_application.g_x01',
'           when ''VIEW'' then noona_anl_pkg.view_json(apex_application.g_x02, l_br, apex_application.g_x06)',
'           when ''CHART'' then noona_anl_pkg.chart_json(apex_application.g_x02, apex_application.g_x04,',
'                                                      to_number(nvl(apex_application.g_x05, ''3'')), l_br, apex_application.g_x06)',
'           when ''ANOM'' then noona_anl_pkg.anomalies_json(12, 2, apex_application.g_x06)',
'           when ''COMPANIES'' then noona_anl_pkg.companies_json(apex_application.g_x02, trunc(sysdate, ''MM''), trunc(sysdate))',
'           else ''{"ok":false,"msg":"طلب غير معروف"}'' end;',
'    owa_util.mime_header(''application/json'', false); owa_util.http_header_close;',
'    while l_pos <= dbms_lob.getlength(l) loop',
'        htp.prn(dbms_lob.substr(l, 8000, l_pos)); l_pos := l_pos + 8000;',
'    end loop;',
'exception when others then',
'    apex_json.open_object; apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', regexp_replace(nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm),',
'                                          ''\s*\[cid=[^]]+\]'', ''''));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820272000000430
);

wwv_flow_imp.component_end;
end;
/
