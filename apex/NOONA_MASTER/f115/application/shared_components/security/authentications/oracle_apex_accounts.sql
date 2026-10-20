prompt --application/shared_components/security/authentications/oracle_apex_accounts
begin
--   Manifest
--     AUTHENTICATION: NOONA Auth
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>115
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_authentication(
 p_id=>wwv_flow_imp.id(17669757721607584)
,p_name=>'NOONA Auth'
,p_scheme_type=>'NATIVE_APEX_ACCOUNTS'
,p_invalid_session_type=>'LOGIN'
,p_cookie_name=>'NOONA_SESSION'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- بعد نجاح كلمة المرور: إنشاء جلسة NOONA (المؤسسة أو المنصة) وربطها بجلسة APEX',
'procedure noona_post_auth is',
'    l_ip varchar2(100);',
'begin',
'    begin',
'        l_ip := owa_util.get_cgi_env(''REMOTE_ADDR'');',
'    exception when others then',
'        l_ip := null;   -- عنوان IP اختياري ولا يمنع الدخول',
'    end;',
'    noona_apex_pkg.post_auth(',
'        p_username        => apex_application.g_user,',
'        p_apex_session_id => to_number(apex_application.g_instance),',
'        p_ip_address      => l_ip);',
'end noona_post_auth;'))
,p_post_auth_process=>'noona_post_auth'
,p_use_secure_cookie_yn=>'N'
,p_ras_mode=>0
,p_version_scn=>136793541
);
wwv_flow_imp.component_end;
end;
/
