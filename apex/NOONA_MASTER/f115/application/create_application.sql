prompt --application/create_application
begin
--   Manifest
--     FLOW: 115
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>115
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_imp_workspace.create_flow(
 p_id=>wwv_flow.g_flow_id
,p_owner=>nvl(wwv_flow_application_install.get_schema,'NOONA_APP')
,p_name=>nvl(wwv_flow_application_install.get_application_name,'NOONA Master')
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'NOONA_MASTER')
,p_page_view_logging=>'YES'
,p_page_protection_enabled_y_n=>'Y'
,p_checksum_salt=>'9962F96ADA072A24F5AC3C25EB07B8C429D7CB5BE621FB6688E5F1CB3A9D3697'
,p_bookmark_checksum_function=>'SH512'
,p_compatibility_mode=>'24.2'
,p_flow_language=>'ar'
,p_flow_language_derived_from=>'FLOW_PRIMARY_LANGUAGE'
,p_allow_feedback_yn=>'Y'
,p_date_format=>'DS'
,p_timestamp_format=>'DS'
,p_timestamp_tz_format=>'DS'
,p_direction_right_to_left=>'Y'
,p_flow_image_prefix => nvl(wwv_flow_application_install.get_image_prefix,'')
,p_authentication_id=>wwv_flow_imp.id(17669757721607584)
,p_security_scheme=>wwv_flow_imp.id(91820260000000101)
,p_vpd=>'noona_apex_pkg.init_request(p_username => :APP_USER, p_apex_session_id => :APP_SESSION);'
,p_vpd_teardown_code=>'noona_apex_pkg.cleanup_request;'
,p_error_handling_function=>'noona_owner.noona_apex_error'
,p_application_tab_set=>0
,p_logo_type=>'T'
,p_logo_text=>'NOONA Master'
,p_proxy_server=>nvl(wwv_flow_application_install.get_proxy,'')
,p_no_proxy_domains=>nvl(wwv_flow_application_install.get_no_proxy_domains,'')
,p_flow_version=>'Release 1.0'
,p_flow_status=>'AVAILABLE_W_EDIT_LINK'
,p_flow_unavailable_text=>'This application is currently unavailable at this time.'
,p_exact_substitutions_only=>'Y'
,p_browser_cache=>'N'
,p_browser_frame=>'D'
,p_rejoin_existing_sessions=>'N'
,p_csv_encoding=>'Y'
,p_auto_time_zone=>'N'
,p_substitution_string_01=>'APP_NAME'
,p_substitution_value_01=>'NOONA Master'
,p_file_prefix => nvl(wwv_flow_application_install.get_static_app_file_prefix,'')
,p_files_version=>6
,p_version_scn=>136794641
,p_print_server_type=>'INSTANCE'
,p_file_storage=>'DB'
,p_is_pwa=>'Y'
,p_pwa_is_installable=>'N'
,p_pwa_is_push_enabled=>'N'
);
wwv_flow_imp.component_end;
end;
/
