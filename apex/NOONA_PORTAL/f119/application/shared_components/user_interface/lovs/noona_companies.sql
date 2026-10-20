prompt --application/shared_components/user_interface/lovs/noona_companies
begin
--   Manifest
--     NOONA_COMPANIES
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=119
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_list_of_values(
 p_id=>wwv_flow_imp.id(91820261000000201)
,p_lov_name=>'NOONA_COMPANIES'
,p_lov_query=>'select case sys_context(''NOONA_CTX'', ''LANGUAGE'') when ''en'' then nvl(legal_name_en, legal_name_ar) else nvl(trade_name_ar, legal_name_ar) end as d, id as r from org_company where status_code not in (''CLOSED'', ''ARCHIVED'') order by 1'
,p_source_type=>'LEGACY_SQL'
,p_location=>'LOCAL'
);
wwv_flow_imp.component_end;
end;
/
