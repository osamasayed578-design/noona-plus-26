prompt --application/shared_components/user_interface/lovs/noona_countries
begin
--   Manifest
--     NOONA_COUNTRIES
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>120
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_list_of_values(
 p_id=>wwv_flow_imp.id(91820262000000007)
,p_lov_name=>'NOONA_COUNTRIES'
,p_lov_query=>'select case sys_context(''NOONA_CTX'', ''LANGUAGE'') when ''en'' then name_en else name_ar end as d, country_code as r from ref_country where is_active = ''Y'' order by sort_order nulls last, 1'
,p_source_type=>'LEGACY_SQL'
,p_location=>'LOCAL'
);
wwv_flow_imp.component_end;
end;
/
