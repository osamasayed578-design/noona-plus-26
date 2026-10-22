prompt --application/shared_components/security/authorizations/noona_pay_view
begin
--   Manifest
--     SECURITY SCHEME: NOONA - Payroll
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>137
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(91820272000000009)
,p_name=>'NOONA - Payroll'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return noona_security_pkg.has_permission(''PAY_RUN.VIEW'', noona_pay_pkg.company) = ''Y'';'
,p_error_message=>'صفحات الرواتب تتطلب صلاحية عرض الرواتب / Payroll access required'
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);
wwv_flow_imp.component_end;
end;
/
