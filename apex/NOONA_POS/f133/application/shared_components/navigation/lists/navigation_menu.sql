prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
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
 p_id=>wwv_flow_imp.id(91820269000000220)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المبيعات'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-line-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000221)
,p_list_item_display_sequence=>15
,p_list_item_link_text=>'نقطة البيع'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-shopping-basket'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000222)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'المبيعات والعملاء'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-file-text-o'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000223)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'فاتورة مبيعات جديدة'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000222)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000224)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'فواتير المبيعات والمرتجعات'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-files-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000222)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000225)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'العملاء'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-users'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000222)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000226)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'التحصيل من العملاء'
,p_list_item_link_target=>'f?p=&APP_ID.:23:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-money'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000222)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000227)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'إدارة نقاط البيع'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-desktop'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000228)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'تقرير الوردية وإقفالها'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-lock'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000227)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000229)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'إعداد نقاط البيع'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-cogs'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000227)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000230)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
