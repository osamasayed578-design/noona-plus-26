prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>137
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
 p_id=>wwv_flow_imp.id(91820272000000368)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'اللوحة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-home'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000369)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الموظفون'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-users'
,p_security_scheme=>wwv_flow_imp.id(91820272000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000370)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'ملفات الموظفين'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-id-card-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000369)
,p_security_scheme=>wwv_flow_imp.id(91820272000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000371)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'موظف جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11::'
,p_list_item_icon=>'fa-user-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000369)
,p_security_scheme=>wwv_flow_imp.id(91820272000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000372)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الإجازات والحضور'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-calendar'
,p_security_scheme=>wwv_flow_imp.id(91820272000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000373)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'الإجازات واعتمادها'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
,p_list_item_icon=>'fa-plane'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000372)
,p_security_scheme=>wwv_flow_imp.id(91820272000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000374)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'طلب إجازة'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000372)
,p_security_scheme=>wwv_flow_imp.id(91820272000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000375)
,p_list_item_display_sequence=>33
,p_list_item_link_text=>'الحضور والإضافي'
,p_list_item_link_target=>'f?p=&APP_ID.:25:&APP_SESSION.::&DEBUG.:25::'
,p_list_item_icon=>'fa-clock-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000372)
,p_security_scheme=>wwv_flow_imp.id(91820272000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000376)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'الرواتب'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-money'
,p_security_scheme=>wwv_flow_imp.id(91820272000000009)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000377)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'تشغيلات الرواتب'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:40::'
,p_list_item_icon=>'fa-calculator'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000376)
,p_security_scheme=>wwv_flow_imp.id(91820272000000009)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000378)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'المدخلات المتغيرة'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&APP_SESSION.::&DEBUG.:42::'
,p_list_item_icon=>'fa-pencil-square-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000376)
,p_security_scheme=>wwv_flow_imp.id(91820272000000009)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000379)
,p_list_item_display_sequence=>43
,p_list_item_link_text=>'السلف والقروض'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:30::'
,p_list_item_icon=>'fa-credit-card'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000376)
,p_security_scheme=>wwv_flow_imp.id(91820272000000009)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000380)
,p_list_item_display_sequence=>44
,p_list_item_link_text=>'مخالصة نهاية الخدمة'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.:RP,50::'
,p_list_item_icon=>'fa-sign-out'
,p_parent_list_item_id=>wwv_flow_imp.id(91820272000000376)
,p_security_scheme=>wwv_flow_imp.id(91820272000000009)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000381)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>'f?p=&APP_ID.:60:&APP_SESSION.::&DEBUG.:60::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820272000000382)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'الإعدادات'
,p_list_item_link_target=>'f?p=&APP_ID.:70:&APP_SESSION.::&DEBUG.:70::'
,p_list_item_icon=>'fa-cog'
,p_security_scheme=>wwv_flow_imp.id(91820272000000009)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
