prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
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
 p_id=>wwv_flow_imp.id(91820273000000544)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'اللوحة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-home'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000545)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'السجل العقاري'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-building'
,p_security_scheme=>wwv_flow_imp.id(91820273000000009)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000546)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'العقارات'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000545)
,p_security_scheme=>wwv_flow_imp.id(91820273000000009)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000547)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'إضافة عقار'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000545)
,p_security_scheme=>wwv_flow_imp.id(91820273000000009)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000548)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الضيافة'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-bed'
,p_security_scheme=>wwv_flow_imp.id(91820273000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000549)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'لوحة الاستقبال'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
,p_list_item_icon=>'fa-th'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000548)
,p_security_scheme=>wwv_flow_imp.id(91820273000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000550)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'الحجوزات'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:21::'
,p_list_item_icon=>'fa-calendar'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000548)
,p_security_scheme=>wwv_flow_imp.id(91820273000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000551)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'حجز جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:22:&SESSION.::&DEBUG.:RP,22::'
,p_list_item_icon=>'fa-calendar-plus-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000548)
,p_security_scheme=>wwv_flow_imp.id(91820273000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000552)
,p_list_item_display_sequence=>4
,p_list_item_link_text=>'التدبير الفندقي'
,p_list_item_link_target=>'f?p=&APP_ID.:25:&APP_SESSION.::&DEBUG.:25::'
,p_list_item_icon=>'fa-paint-brush'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000548)
,p_security_scheme=>wwv_flow_imp.id(91820273000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000553)
,p_list_item_display_sequence=>5
,p_list_item_link_text=>'التدقيق الليلي'
,p_list_item_link_target=>'f?p=&APP_ID.:26:&APP_SESSION.::&DEBUG.:26::'
,p_list_item_icon=>'fa-moon-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000548)
,p_security_scheme=>wwv_flow_imp.id(91820273000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000554)
,p_list_item_display_sequence=>6
,p_list_item_link_text=>'تقارير الضيافة'
,p_list_item_link_target=>'f?p=&APP_ID.:28:&APP_SESSION.::&DEBUG.:28::'
,p_list_item_icon=>'fa-bar-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000548)
,p_security_scheme=>wwv_flow_imp.id(91820273000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000555)
,p_list_item_display_sequence=>7
,p_list_item_link_text=>'إعداد الضيافة'
,p_list_item_link_target=>'f?p=&APP_ID.:27:&APP_SESSION.::&DEBUG.:27::'
,p_list_item_icon=>'fa-cog'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000548)
,p_security_scheme=>wwv_flow_imp.id(91820273000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000556)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'الصيانة'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-wrench'
,p_security_scheme=>wwv_flow_imp.id(91820273000000011)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000557)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'لوحة البلاغات'
,p_list_item_link_target=>'f?p=&APP_ID.:70:&APP_SESSION.::&DEBUG.:70::'
,p_list_item_icon=>'fa-columns'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000556)
,p_security_scheme=>wwv_flow_imp.id(91820273000000011)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000558)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'بلاغ جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:71:&SESSION.::&DEBUG.:RP,71::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000556)
,p_security_scheme=>wwv_flow_imp.id(91820273000000011)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000559)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'سجل البلاغات'
,p_list_item_link_target=>'f?p=&APP_ID.:72:&APP_SESSION.::&DEBUG.:72::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000556)
,p_security_scheme=>wwv_flow_imp.id(91820273000000011)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000560)
,p_list_item_display_sequence=>4
,p_list_item_link_text=>'الفرق والفنيون'
,p_list_item_link_target=>'f?p=&APP_ID.:73:&APP_SESSION.::&DEBUG.:73::'
,p_list_item_icon=>'fa-users'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000556)
,p_security_scheme=>wwv_flow_imp.id(91820273000000011)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000561)
,p_list_item_display_sequence=>5
,p_list_item_link_text=>'أنواع الأعطال'
,p_list_item_link_target=>'f?p=&APP_ID.:74:&APP_SESSION.::&DEBUG.:74::'
,p_list_item_icon=>'fa-tags'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000556)
,p_security_scheme=>wwv_flow_imp.id(91820273000000011)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000562)
,p_list_item_display_sequence=>6
,p_list_item_link_text=>'أداء الصيانة'
,p_list_item_link_target=>'f?p=&APP_ID.:75:&APP_SESSION.::&DEBUG.:75::'
,p_list_item_icon=>'fa-line-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000556)
,p_security_scheme=>wwv_flow_imp.id(91820273000000011)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000749)
,p_list_item_display_sequence=>35
,p_list_item_link_text=>'المشروعات والمقاولات'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-briefcase'
,p_security_scheme=>wwv_flow_imp.id(91820273000000563)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000750)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'لوحة المشروعات'
,p_list_item_link_target=>'f?p=&APP_ID.:80:&APP_SESSION.::&DEBUG.:80::'
,p_list_item_icon=>'fa-th-large'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000749)
,p_security_scheme=>wwv_flow_imp.id(91820273000000563)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000751)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'مشروع جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:82:&SESSION.::&DEBUG.:RP,82::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000749)
,p_security_scheme=>wwv_flow_imp.id(91820273000000563)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000000752)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'تقارير المشروعات'
,p_list_item_link_target=>'f?p=&APP_ID.:90:&APP_SESSION.::&DEBUG.:90::'
,p_list_item_icon=>'fa-bar-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000000749)
,p_security_scheme=>wwv_flow_imp.id(91820273000000563)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001054)
,p_list_item_display_sequence=>25
,p_list_item_link_text=>'بيع الوحدات'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-key'
,p_security_scheme=>wwv_flow_imp.id(91820273000000753)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001055)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'لوحة المبيعات'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:30::'
,p_list_item_icon=>'fa-th-large'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001054)
,p_security_scheme=>wwv_flow_imp.id(91820273000000753)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001056)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'حجز / عقد جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001054)
,p_security_scheme=>wwv_flow_imp.id(91820273000000753)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001057)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'الحجوزات والعقود'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:32::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001054)
,p_security_scheme=>wwv_flow_imp.id(91820273000000753)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001058)
,p_list_item_display_sequence=>4
,p_list_item_link_text=>'التحصيل والعمولات'
,p_list_item_link_target=>'f?p=&APP_ID.:34:&APP_SESSION.::&DEBUG.:34::'
,p_list_item_icon=>'fa-money'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001054)
,p_security_scheme=>wwv_flow_imp.id(91820273000000753)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001059)
,p_list_item_display_sequence=>5
,p_list_item_link_text=>'الأسعار وخطط السداد'
,p_list_item_link_target=>'f?p=&APP_ID.:35:&APP_SESSION.::&DEBUG.:35::'
,p_list_item_icon=>'fa-tags'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001054)
,p_security_scheme=>wwv_flow_imp.id(91820273000000753)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001060)
,p_list_item_display_sequence=>6
,p_list_item_link_text=>'التقارير والتسليم'
,p_list_item_link_target=>'f?p=&APP_ID.:36:&APP_SESSION.::&DEBUG.:36::'
,p_list_item_icon=>'fa-bar-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001054)
,p_security_scheme=>wwv_flow_imp.id(91820273000000753)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001061)
,p_list_item_display_sequence=>27
,p_list_item_link_text=>'الإيجارات وإدارة الأملاك'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-building-o'
,p_security_scheme=>wwv_flow_imp.id(91820273000000754)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001062)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'لوحة الإيجارات'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:40::'
,p_list_item_icon=>'fa-th-large'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001061)
,p_security_scheme=>wwv_flow_imp.id(91820273000000754)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001063)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'عقد إيجار جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001061)
,p_security_scheme=>wwv_flow_imp.id(91820273000000754)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001064)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'العقود وقائمة الإيجارات'
,p_list_item_link_target=>'f?p=&APP_ID.:43:&APP_SESSION.::&DEBUG.:43::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001061)
,p_security_scheme=>wwv_flow_imp.id(91820273000000754)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001065)
,p_list_item_display_sequence=>4
,p_list_item_link_text=>'إدارة أملاك الغير'
,p_list_item_link_target=>'f?p=&APP_ID.:44:&APP_SESSION.::&DEBUG.:44::'
,p_list_item_icon=>'fa-handshake-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001061)
,p_security_scheme=>wwv_flow_imp.id(91820273000000754)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001066)
,p_list_item_display_sequence=>5
,p_list_item_link_text=>'العدادات'
,p_list_item_link_target=>'f?p=&APP_ID.:46:&APP_SESSION.::&DEBUG.:46::'
,p_list_item_icon=>'fa-tachometer'
,p_parent_list_item_id=>wwv_flow_imp.id(91820273000001061)
,p_security_scheme=>wwv_flow_imp.id(91820273000000754)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820273000001069)
,p_list_item_display_sequence=>11
,p_list_item_link_text=>'التحليلات والتنبؤ'
,p_list_item_link_target=>'f?p=&APP_ID.:98:&APP_SESSION.::&DEBUG.:98::'
,p_list_item_icon=>'fa-line-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
