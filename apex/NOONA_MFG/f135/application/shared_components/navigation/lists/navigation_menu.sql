prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>135
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
 p_id=>wwv_flow_imp.id(91820270000000205)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة التصنيع'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-industry'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000206)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الإنتاج'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cogs'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000207)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'أمر إنتاج جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:31:&APP_SESSION.::&DEBUG.:RP,31::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000206)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000208)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'أوامر الإنتاج'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:30::'
,p_list_item_icon=>'fa-list-alt'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000206)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000209)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'فحوصات الجودة'
,p_list_item_link_target=>'f?p=&APP_ID.:35:&APP_SESSION.::&DEBUG.:35::'
,p_list_item_icon=>'fa-check-square-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000206)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000210)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'التخطيط'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-calendar'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000211)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'تخطيط احتياجات المواد'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:40::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000210)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000212)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'أحمال مراكز العمل'
,p_list_item_link_target=>'f?p=&APP_ID.:41:&APP_SESSION.::&DEBUG.:41::'
,p_list_item_icon=>'fa-tasks'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000210)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000213)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'الهندسة والإعداد'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-wrench'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000214)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'قوائم المواد'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
,p_list_item_icon=>'fa-list-ul'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000213)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000215)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'مسارات التصنيع'
,p_list_item_link_target=>'f?p=&APP_ID.:22:&APP_SESSION.::&DEBUG.:22::'
,p_list_item_icon=>'fa-random'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000213)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000216)
,p_list_item_display_sequence=>43
,p_list_item_link_text=>'مراكز العمل'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-building-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000213)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000217)
,p_list_item_display_sequence=>44
,p_list_item_link_text=>'إعدادات التكلفة'
,p_list_item_link_target=>'f?p=&APP_ID.:60:&APP_SESSION.::&DEBUG.:60::'
,p_list_item_icon=>'fa-calculator'
,p_parent_list_item_id=>wwv_flow_imp.id(91820270000000213)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000218)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:50::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820270000000221)
,p_list_item_display_sequence=>11
,p_list_item_link_text=>'التحليلات والتنبؤ'
,p_list_item_link_target=>'f?p=&APP_ID.:98:&APP_SESSION.::&DEBUG.:98::'
,p_list_item_icon=>'fa-line-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
