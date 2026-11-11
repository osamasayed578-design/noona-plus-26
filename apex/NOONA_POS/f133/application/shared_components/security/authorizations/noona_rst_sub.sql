prompt --application/shared_components/security/authorizations/noona_rst_sub
begin
--   Manifest
--     SECURITY SCHEME: NOONA - Restaurant subscription
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(91820269000000224)
,p_name=>'NOONA - Restaurant subscription'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return noona_portal_pkg.app_visible(''NOONA_POS'', ''SAL'') = ''Y'' and noona_platform_pkg.module_enabled(''RST'') = ''Y'';'
,p_error_message=>'المطاعم والكافتيريا غير مشمولة في اشتراك مؤسستك / Restaurant module not subscribed'
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);
wwv_flow_imp.component_end;
end;
/
