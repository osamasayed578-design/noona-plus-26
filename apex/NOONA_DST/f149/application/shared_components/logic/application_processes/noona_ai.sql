prompt --application/shared_components/logic/application_processes/noona_ai
begin
--   Manifest
--     APPLICATION PROCESS: NOONA_AI
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_flow_process(
 p_id=>wwv_flow_imp.id(91820260001004941)
,p_process_sequence=>20
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'NOONA_AI'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l clob;',
'    l_pos pls_integer := 1;',
'begin',
'    case apex_application.g_x01',
'        when ''STATE'' then l := ''{"available":"'' || noona_ai_pkg.is_enabled || ''"}'';',
'        when ''CHAT'' then l := noona_ai_pkg.chat(apex_application.g_clob_01);',
'        when ''CONVS'' then l := noona_ai_pkg.conversations_json(30);',
'        when ''MSGS'' then l := noona_ai_pkg.messages_json(to_number(apex_application.g_x02));',
'        when ''DEL'' then noona_ai_pkg.delete_conversation(to_number(apex_application.g_x02)); l := ''{"ok":true}'';',
'        when ''FB'' then noona_ai_pkg.feedback(to_number(apex_application.g_x02), to_number(apex_application.g_x03)); l := ''{"ok":true}'';',
'        when ''SUMMARY'' then l := noona_ai_pkg.executive_summary(null, to_number(nullif(apex_application.g_x02, '''')));',
'        else l := ''{"ok":false,"msg":"طلب غير معروف"}'';',
'    end case;',
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
,p_security_scheme=>'MUST_NOT_BE_PUBLIC_USER'
);
wwv_flow_imp.component_end;
end;
/
