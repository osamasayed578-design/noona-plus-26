prompt --application/shared_components/security/authorizations/noona_bank_recon
begin
--   Manifest
--     SECURITY SCHEME: NOONA - Bank Reconciliation
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(91820266000000880)
,p_name=>'NOONA - Bank Reconciliation'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return noona_security_pkg.has_permission(''CSH_BANK_STATEMENT.VIEW'', noona_conn_pkg.company) = ''Y'';'
,p_error_message=>'المطابقة البنكية تتطلب صلاحية كشوف الحساب / Bank statement access required'
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);
wwv_flow_imp.component_end;
end;
/
