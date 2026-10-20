prompt --application/shared_components/user_interface/lovs/noona_currencies
begin
--   Manifest
--     NOONA_CURRENCIES
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
 p_id=>wwv_flow_imp.id(91820264000000006)
,p_lov_name=>'NOONA_CURRENCIES'
,p_lov_query=>'select currency_code || '' - '' || case sys_context(''NOONA_CTX'', ''LANGUAGE'') when ''en'' then name_en else name_ar end as d, currency_code as r from ref_currency where is_active = ''Y'' order by currency_code'
,p_source_type=>'LEGACY_SQL'
,p_location=>'LOCAL'
);
wwv_flow_imp.component_end;
end;
/
