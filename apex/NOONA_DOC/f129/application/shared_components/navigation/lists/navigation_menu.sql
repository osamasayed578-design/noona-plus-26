prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
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
 p_id=>wwv_flow_imp.id(91820267000000128)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة الأرشيف'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-archive'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820267000000129)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'البحث في الأرشيف'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-search'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820267000000130)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'أرشفة مستند'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-upload'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820267000000131)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'الإعدادات'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cog'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820267000000132)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'أنواع المستندات'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-files-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820267000000131)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820267000000133)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'قواعد الأرشفة'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-gavel'
,p_parent_list_item_id=>wwv_flow_imp.id(91820267000000131)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820267000000134)
,p_list_item_display_sequence=>43
,p_list_item_link_text=>'سجل الوصول'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-eye'
,p_parent_list_item_id=>wwv_flow_imp.id(91820267000000131)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
