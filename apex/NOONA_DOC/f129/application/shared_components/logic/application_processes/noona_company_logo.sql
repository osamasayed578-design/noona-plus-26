prompt --application/shared_components/logic/application_processes/noona_company_logo
begin
--   Manifest
--     APPLICATION PROCESS: NOONA_COMPANY_LOGO
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_flow_process(
 p_id=>wwv_flow_imp.id(91820260001002940)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'NOONA_COMPANY_LOGO'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- شعار الشركة الحالية (شعار المشترك) من إدارة المستندات؛ يستدعى من شارة الشركة في الترويسة',
'declare',
'    l_blob blob;',
'    l_mime varchar2(100);',
'    l_hash varchar2(128);',
'begin',
'    noona_brand_pkg.get_company_logo(null, l_blob, l_mime, l_hash);',
'    if l_blob is null then',
'        owa_util.status_line(404, ''Not Found'');',
'    else',
'        owa_util.mime_header(l_mime, false);',
'        htp.p(''Content-Length: '' || dbms_lob.getlength(l_blob));',
'        htp.p(''Cache-Control: private, max-age=600'');',
'        htp.p(''X-Content-Type-Options: nosniff'');',
'        owa_util.http_header_close;',
'        wpg_docload.download_file(l_blob);',
'    end if;',
'    apex_application.stop_apex_engine;',
'exception',
'    when apex_application.e_stop_apex_engine then',
'        null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>'MUST_NOT_BE_PUBLIC_USER'
);
wwv_flow_imp.component_end;
end;
/
