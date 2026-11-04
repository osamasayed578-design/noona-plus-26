prompt --application/pages/page_00006
begin
--   Manifest
--     PAGE: 00006
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>143
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>6
,p_name=>'Prior Years'
,p_alias=>'PRIOR-YEARS'
,p_step_title=>'أرقام السنوات السابقة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820277000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''hist.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820277000000028)
,p_plug_name=>'أرقام السنوات السابقة'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div id="nnHist" class="nn-hist" data-cmp-url="f?p=&APP_ID.:5:&APP_SESSION.::NO"></div>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820277000000029)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'HIST'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l clob;',
'    l_pos pls_integer := 1;',
'    l_br number := to_number(nullif(apex_application.g_x04, ''''));',
'    l_csv clob;',
'    l_first boolean := true;',
'begin',
'    if apex_application.g_x01 = ''META'' then',
'        l := ''{"metrics":'' || noona_anl_pkg.metrics_json(null) || '',"branches":['';',
'        for b in (select id, name_ar from org_branch where company_id = noona_anl_pkg.company and status_code = ''ACTIVE'' order by name_ar) loop',
'            l := l || case when not l_first then '','' end || ''{"id":'' || b.id || '',"name":"'' || apex_escape.json(b.name_ar) || ''"}'';',
'            l_first := false;',
'        end loop;',
'        l := l || ''],"summary":'' || noona_anl_pkg.history_summary_json || ''}'';',
'    elsif apex_application.g_x01 = ''GET'' then',
'        l := noona_anl_pkg.history_json(apex_application.g_x02, to_number(apex_application.g_x03), l_br);',
'    elsif apex_application.g_x01 = ''SAVE'' then',
'        l := ''{"saved":'' || noona_anl_pkg.save_history(apex_application.g_x02, to_number(apex_application.g_x03), l_br,',
'                                    apex_application.g_x05, ''MANUAL'', apex_application.g_x06) || ''}'';',
'    elsif apex_application.g_x01 = ''IMPORT'' then',
'        for i in 1 .. apex_application.g_f01.count loop l_csv := l_csv || apex_application.g_f01(i); end loop;',
'        l := noona_anl_pkg.import_history_csv(l_csv, ''IMPORT'');',
'    else',
'        l := ''{"ok":false,"msg":"طلب غير معروف"}'';',
'    end if;',
'    owa_util.mime_header(''application/json'', false); owa_util.http_header_close;',
'    while l_pos <= dbms_lob.getlength(l) loop',
'        htp.prn(dbms_lob.substr(l, 8000, l_pos)); l_pos := l_pos + 8000;',
'    end loop;',
'exception when others then',
'    rollback;',
'    apex_json.open_object; apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', regexp_replace(nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm),',
'                                          ''\s*\[cid=[^]]+\]'', ''''));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820277000000029
);

wwv_flow_imp.component_end;
end;
/
