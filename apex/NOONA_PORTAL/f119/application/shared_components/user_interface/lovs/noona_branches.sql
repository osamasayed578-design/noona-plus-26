prompt --application/shared_components/user_interface/lovs/noona_branches
begin
--   Manifest
--     NOONA_BRANCHES
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>119
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_list_of_values(
 p_id=>wwv_flow_imp.id(91820261000000202)
,p_lov_name=>'NOONA_BRANCHES'
,p_lov_query=>'select case sys_context(''NOONA_CTX'', ''LANGUAGE'') when ''en'' then nvl(name_en, name_ar) else name_ar end as d, id as r from org_branch where status_code = ''ACTIVE'' and company_id = to_number(sys_context(''NOONA_CTX'', ''COMPANY_ID'')) order by is_head_office desc, 1'
,p_source_type=>'LEGACY_SQL'
,p_location=>'LOCAL'
);
wwv_flow_imp.component_end;
end;
/
