prompt --application/pages/page_00000
begin
--   Manifest
--     PAGE: 00000
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>125
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>0
,p_name=>'Global Page'
,p_step_title=>'Global Page'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'D'
,p_page_component_map=>'14'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820260001002550)
,p_plug_name=>'NOONA Company Badge'
,p_region_template_options=>'#DEFAULT#'
,p_plug_display_sequence=>10
,p_plug_display_point=>'BEFORE_NAVIGATION_BAR'
,p_function_body_language=>'PLSQL'
,p_plug_source=>'return noona_brand_pkg.header_badge(p_app_id => :APP_ID, p_session => :APP_SESSION);'
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp.component_end;
end;
/
