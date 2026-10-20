prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>125
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(17753914427442914)
,p_name=>'Navigation Menu'
,p_list_status=>'PUBLIC'
,p_version_scn=>137120771
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820265000000102)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المنصة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-server'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820265000000103)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'تجهيز مؤسسة'
,p_list_item_link_target=>'f?p=&APP_ID.:4:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus-circle'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820265000000104)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'سجل تدقيق المنصة'
,p_list_item_link_target=>'f?p=&APP_ID.:5:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-shield'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820265000000105)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'وحدات النظام'
,p_list_item_link_target=>'f?p=&APP_ID.:6:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-cubes'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820265000000106)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'مسؤولو المنصة'
,p_list_item_link_target=>'f?p=&APP_ID.:7:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user-secret'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
