prompt --application/shared_components/files/noona_5
begin
--   Manifest
--     APP STATIC FILES: 123
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '3C73766720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222076696577426F783D223020302031323020313230223E3C7265637420783D22342220793D2234222077696474683D2231313222206865696768743D22';
wwv_flow_imp.g_varchar2_table(2) := '313132222072783D223238222066696C6C3D2223666666222F3E3C7061746820643D224D323620353420413334203334203020302030203934203534222066696C6C3D226E6F6E6522207374726F6B653D222330303637633022207374726F6B652D7769';
wwv_flow_imp.g_varchar2_table(3) := '6474683D22313322207374726F6B652D6C696E656361703D22726F756E64222F3E3C7061746820643D224D363020323220763234204D34382033342068323422207374726F6B653D222366666239303022207374726F6B652D77696474683D2231302220';
wwv_flow_imp.g_varchar2_table(4) := '7374726F6B652D6C696E656361703D22726F756E64222F3E3C2F7376673E0A';
wwv_flow_imp_shared.create_app_static_file(
 p_id=>wwv_flow_imp.id(91820260001002305)
,p_file_name=>'noona-logo-white.svg'
,p_mime_type=>'image/svg+xml'
,p_file_charset=>'utf-8'
,p_file_content => wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
wwv_flow_imp.component_end;
end;
/
