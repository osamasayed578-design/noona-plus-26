prompt --application/shared_components/security/authorizations/noona_dms_view
begin
--   Manifest
--     SECURITY SCHEME: NOONA - Archive
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(91820267000000009)
,p_name=>'NOONA - Archive'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return noona_security_pkg.has_permission(''DMS_DOCUMENT.VIEW'', noona_dms_pkg.company) = ''Y'';'
,p_error_message=>'صفحات الأرشيف تتطلب صلاحية عرض المستندات / Archive access required'
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);
wwv_flow_imp.component_end;
end;
/
