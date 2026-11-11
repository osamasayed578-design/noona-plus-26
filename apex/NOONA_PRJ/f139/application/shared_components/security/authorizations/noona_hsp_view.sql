prompt --application/shared_components/security/authorizations/noona_hsp_view
begin
--   Manifest
--     SECURITY SCHEME: NOONA - Hospitality
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(91820273000000010)
,p_name=>'NOONA - Hospitality'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return noona_security_pkg.has_permission(''HSP_RESERVATION.VIEW'', noona_hsp_pkg.company) = ''Y'' and noona_platform_pkg.module_enabled(''HSP'') = ''Y'';'
,p_error_message=>'صفحات الضيافة تتطلب صلاحية عرض الحجوزات / Hospitality access required'
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);
wwv_flow_imp.component_end;
end;
/
