prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>131
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
 p_id=>wwv_flow_imp.id(91820268000000319)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة سلسلة الإمداد'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-truck'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000320)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'المخزون والأصناف'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cubes'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000321)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'الأصناف'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-cube'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000320)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000322)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'صنف جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000320)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000323)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'حركات المخزون'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-exchange'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000320)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000324)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'مستند مخزون جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-file-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000320)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000325)
,p_list_item_display_sequence=>25
,p_list_item_link_text=>'قائمة المواد والإنتاج'
,p_list_item_link_target=>'f?p=&APP_ID.:13:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-industry'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000320)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000326)
,p_list_item_display_sequence=>26
,p_list_item_link_text=>'الفئات وحساباتها'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-tags'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000320)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000327)
,p_list_item_display_sequence=>27
,p_list_item_link_text=>'المستودعات'
,p_list_item_link_target=>'f?p=&APP_ID.:14:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-building-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000320)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000328)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'المشتريات والموردون'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-shopping-cart'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000329)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'فاتورة مشتريات جديدة'
,p_list_item_link_target=>'f?p=&APP_ID.:35:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000328)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000330)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'فواتير المشتريات والمرتجعات'
,p_list_item_link_target=>'f?p=&APP_ID.:34:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-files-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000328)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000331)
,p_list_item_display_sequence=>33
,p_list_item_link_text=>'أوامر الشراء'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000328)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000332)
,p_list_item_display_sequence=>34
,p_list_item_link_text=>'الموردون'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-users'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000328)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000333)
,p_list_item_display_sequence=>35
,p_list_item_link_text=>'سداد الموردين'
,p_list_item_link_target=>'f?p=&APP_ID.:37:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-money'
,p_parent_list_item_id=>wwv_flow_imp.id(91820268000000328)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820268000000334)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
