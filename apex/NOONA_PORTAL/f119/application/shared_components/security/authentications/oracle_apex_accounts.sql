prompt --application/shared_components/security/authentications/oracle_apex_accounts
begin
--   Manifest
--     AUTHENTICATION: NOONA Auth
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>119
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_authentication(
 p_id=>wwv_flow_imp.id(17753165707442907)
,p_name=>'NOONA Auth'
,p_scheme_type=>'NATIVE_CUSTOM'
,p_attribute_03=>'noona_authenticate'
,p_attribute_05=>'N'
,p_invalid_session_type=>'LOGIN'
,p_cookie_name=>'NOONA_SESSION'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- مصادقة نونا بلس: بيانات الاعتماد المحلية (SEC_CREDENTIAL، PBKDF2) مع قفل بعد المحاولات الفاشلة؛',
'-- المستخدم الذي لا يملك كلمة مرور محلية بعد يتحقق عبر حساب APEX (للانتقال التدريجي)',
'function noona_authenticate(p_username in varchar2, p_password in varchar2) return boolean is',
'    l_result varchar2(20);',
'begin',
'    l_result := noona_apex_pkg.check_password(p_username, p_password);',
'    if l_result = ''NO_LOCAL'' then',
'        return apex_util.is_login_password_valid(p_username => p_username, p_password => p_password);',
'    end if;',
'    return l_result = ''OK'';',
'end noona_authenticate;',
'',
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
,p_version_scn=>137120596
);
wwv_flow_imp.component_end;
end;
/
