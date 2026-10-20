prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
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
 p_id=>wwv_flow_imp.id(91820262000000130)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة الإدارة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000131)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الشركات والفروع'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-building-o'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000132)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'الشركات'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-building'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000131)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000133)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'الفروع'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-map-marker'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000131)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000254)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الهيكل التنظيمي'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-sitemap'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000255)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'الهياكل والإصدارات'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000254)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000256)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'المناصب والوظائف'
,p_list_item_link_target=>'f?p=&APP_ID.:22:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-id-badge'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000254)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000257)
,p_list_item_display_sequence=>33
,p_list_item_link_text=>'تعيين الموظفين'
,p_list_item_link_target=>'f?p=&APP_ID.:23:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000254)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000373)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'المستخدمون والصلاحيات'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-users'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000374)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'المستخدمون'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000373)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000375)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'الأدوار والصلاحيات'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-key'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000373)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
