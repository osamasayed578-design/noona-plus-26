prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>145
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
 p_id=>wwv_flow_imp.id(91820280000000312)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة الورشة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000313)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'استلام سيارة'
,p_list_item_link_target=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:RP,2::'
,p_list_item_icon=>'fa-sign-in'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000314)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'أوامر الإصلاح'
,p_list_item_link_target=>'f?p=&APP_ID.:4:&APP_SESSION.::&DEBUG.:4::'
,p_list_item_icon=>'fa-list'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000315)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'الحجوزات'
,p_list_item_link_target=>'f?p=&APP_ID.:5:&APP_SESSION.::&DEBUG.:5::'
,p_list_item_icon=>'fa-calendar'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000316)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'المركبات'
,p_list_item_link_target=>'f?p=&APP_ID.:6:&APP_SESSION.::&DEBUG.:6::'
,p_list_item_icon=>'fa-car'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000317)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'مطالبات التأمين'
,p_list_item_link_target=>'f?p=&APP_ID.:8:&APP_SESSION.::&DEBUG.:8::'
,p_list_item_icon=>'fa-shield'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000318)
,p_list_item_display_sequence=>70
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:12::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000319)
,p_list_item_display_sequence=>80
,p_list_item_link_text=>'الإعداد'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cogs'
,p_security_scheme=>wwv_flow_imp.id(91820280000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000320)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'الخدمات وقطعها'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-th-large'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000319)
,p_security_scheme=>wwv_flow_imp.id(91820280000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000321)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'الرافعات والفنيون'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&APP_SESSION.::&DEBUG.:11::'
,p_list_item_icon=>'fa-users'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000319)
,p_security_scheme=>wwv_flow_imp.id(91820280000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000322)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'شركات التأمين'
,p_list_item_link_target=>'f?p=&APP_ID.:9:&APP_SESSION.::&DEBUG.:9::'
,p_list_item_icon=>'fa-building'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000319)
,p_security_scheme=>wwv_flow_imp.id(91820280000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
