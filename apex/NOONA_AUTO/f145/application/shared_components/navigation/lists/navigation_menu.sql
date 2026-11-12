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
 p_id=>wwv_flow_imp.id(91820280000000320)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة الورشة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000321)
,p_list_item_display_sequence=>15
,p_list_item_link_text=>'مهامي (الفني)'
,p_list_item_link_target=>'f?p=&APP_ID.:70:&APP_SESSION.::&DEBUG.:70::'
,p_list_item_icon=>'fa-mobile'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000322)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'استلام سيارة'
,p_list_item_link_target=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:RP,2::'
,p_list_item_icon=>'fa-sign-in'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000323)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'أوامر الإصلاح'
,p_list_item_link_target=>'f?p=&APP_ID.:4:&APP_SESSION.::&DEBUG.:4::'
,p_list_item_icon=>'fa-list'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000324)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'الحجوزات'
,p_list_item_link_target=>'f?p=&APP_ID.:5:&APP_SESSION.::&DEBUG.:5::'
,p_list_item_icon=>'fa-calendar'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000325)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'المركبات'
,p_list_item_link_target=>'f?p=&APP_ID.:6:&APP_SESSION.::&DEBUG.:6::'
,p_list_item_icon=>'fa-car'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000326)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'مطالبات التأمين'
,p_list_item_link_target=>'f?p=&APP_ID.:8:&APP_SESSION.::&DEBUG.:8::'
,p_list_item_icon=>'fa-shield'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000327)
,p_list_item_display_sequence=>70
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:12::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000328)
,p_list_item_display_sequence=>80
,p_list_item_link_text=>'الإعداد'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cogs'
,p_security_scheme=>wwv_flow_imp.id(91820280000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000329)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'الخدمات وقطعها'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-th-large'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000328)
,p_security_scheme=>wwv_flow_imp.id(91820280000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000330)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'الرافعات والفنيون'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&APP_SESSION.::&DEBUG.:11::'
,p_list_item_icon=>'fa-users'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000328)
,p_security_scheme=>wwv_flow_imp.id(91820280000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000331)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'شركات التأمين'
,p_list_item_link_target=>'f?p=&APP_ID.:9:&APP_SESSION.::&DEBUG.:9::'
,p_list_item_icon=>'fa-building'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000328)
,p_security_scheme=>wwv_flow_imp.id(91820280000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000552)
,p_list_item_display_sequence=>75
,p_list_item_link_text=>'التسعير والعروض'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-tags'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000553)
,p_list_item_display_sequence=>76
,p_list_item_link_text=>'العروض والتخفيضات'
,p_list_item_link_target=>'f?p=&APP_ID.:23:&APP_SESSION.::&DEBUG.:23::'
,p_list_item_icon=>'fa-percent'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000552)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000554)
,p_list_item_display_sequence=>77
,p_list_item_link_text=>'الباقات'
,p_list_item_link_target=>'f?p=&APP_ID.:24:&APP_SESSION.::&DEBUG.:24::'
,p_list_item_icon=>'fa-gift'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000552)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000555)
,p_list_item_display_sequence=>78
,p_list_item_link_text=>'سياسات التسعير'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
,p_list_item_icon=>'fa-calculator'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000552)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000556)
,p_list_item_display_sequence=>79
,p_list_item_link_text=>'بطاقات التكلفة'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:21::'
,p_list_item_icon=>'fa-list-alt'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000552)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000557)
,p_list_item_display_sequence=>80
,p_list_item_link_text=>'إعادة التسعير والهوامش'
,p_list_item_link_target=>'f?p=&APP_ID.:22:&APP_SESSION.::&DEBUG.:22::'
,p_list_item_icon=>'fa-refresh'
,p_parent_list_item_id=>wwv_flow_imp.id(91820280000000552)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820280000000560)
,p_list_item_display_sequence=>11
,p_list_item_link_text=>'التحليلات والتنبؤ'
,p_list_item_link_target=>'f?p=&APP_ID.:98:&APP_SESSION.::&DEBUG.:98::'
,p_list_item_icon=>'fa-line-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
