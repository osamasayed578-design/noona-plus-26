prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
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
 p_id=>wwv_flow_imp.id(91820266000000138)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المالية'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-calculator'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000139)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الأستاذ العام'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-book'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000140)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'القيود اليومية'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-list-alt'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000139)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000141)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'قيد جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000139)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000142)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'دليل الحسابات'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000139)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000143)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'الفترات المحاسبية'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-calendar'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000139)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000144)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-bar-chart'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000145)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'ميزان المراجعة'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-balance-scale'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000144)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000146)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'كشف حساب'
,p_list_item_link_target=>'f?p=&APP_ID.:31:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000144)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
