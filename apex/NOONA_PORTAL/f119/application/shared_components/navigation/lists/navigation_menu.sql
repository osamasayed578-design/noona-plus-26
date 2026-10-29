prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>119
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
 p_id=>wwv_flow_imp.id(91820264000000077)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'مهامي وإشعاراتي'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-inbox'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820264000000078)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'طلباتي'
,p_list_item_link_target=>'f?p=&APP_ID.:4:&APP_SESSION.::&DEBUG.:4::'
,p_list_item_icon=>'fa-paper-plane-o'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820264000000079)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'تفويضاتي'
,p_list_item_link_target=>'f?p=&APP_ID.:5:&APP_SESSION.::&DEBUG.:5::'
,p_list_item_icon=>'fa-share'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820264000000080)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'تبديل الشركة'
,p_list_item_link_target=>'f?p=&APP_ID.:3:&APP_SESSION.::&DEBUG.:3::'
,p_list_item_icon=>'fa-building-o'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
