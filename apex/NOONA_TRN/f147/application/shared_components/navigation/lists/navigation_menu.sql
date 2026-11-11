prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>147
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
 p_id=>wwv_flow_imp.id(91820290000000657)
,p_list_item_display_sequence=>11
,p_list_item_link_text=>'التحليلات والتنبؤ'
,p_list_item_link_target=>'f?p=&APP_ID.:98:&APP_SESSION.::&DEBUG.:98::'
,p_list_item_icon=>'fa-line-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000658)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة الحركة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-truck'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000659)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'العمليات'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-road'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000660)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'أوامر الشحن'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-cubes'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000659)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000661)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'الرحلات'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
,p_list_item_icon=>'fa-road'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000659)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000662)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'رحلة جديدة'
,p_list_item_link_target=>'f?p=&APP_ID.:22:&APP_SESSION.::&DEBUG.:22::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000659)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000663)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'الأعطال والبلاغات'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:30::'
,p_list_item_icon=>'fa-exclamation-triangle'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000659)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000664)
,p_list_item_display_sequence=>25
,p_list_item_link_text=>'فوترة الترحيل'
,p_list_item_link_target=>'f?p=&APP_ID.:55:&APP_SESSION.::&DEBUG.:55::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000659)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000665)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الأسطول'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-bus'
,p_security_scheme=>wwv_flow_imp.id(91820290000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000666)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'العربات والشاحنات'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:40::'
,p_list_item_icon=>'fa-truck'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000665)
,p_security_scheme=>wwv_flow_imp.id(91820290000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000667)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'السائقون'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&APP_SESSION.::&DEBUG.:42::'
,p_list_item_icon=>'fa-id-card'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000665)
,p_security_scheme=>wwv_flow_imp.id(91820290000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000668)
,p_list_item_display_sequence=>33
,p_list_item_link_text=>'صيانة الأسطول'
,p_list_item_link_target=>'f?p=&APP_ID.:34:&APP_SESSION.::&DEBUG.:34::'
,p_list_item_icon=>'fa-wrench'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000665)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000669)
,p_list_item_display_sequence=>34
,p_list_item_link_text=>'برامج الصيانة الدورية'
,p_list_item_link_target=>'f?p=&APP_ID.:36:&APP_SESSION.::&DEBUG.:36::'
,p_list_item_icon=>'fa-calendar-check-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000665)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000670)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'الإعداد'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cogs'
,p_security_scheme=>wwv_flow_imp.id(91820290000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000671)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'المدن والمواقع'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:50::'
,p_list_item_icon=>'fa-map-marker'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000670)
,p_security_scheme=>wwv_flow_imp.id(91820290000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000672)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'المسارات والمسافات'
,p_list_item_link_target=>'f?p=&APP_ID.:52:&APP_SESSION.::&DEBUG.:52::'
,p_list_item_icon=>'fa-map'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000670)
,p_security_scheme=>wwv_flow_imp.id(91820290000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000673)
,p_list_item_display_sequence=>43
,p_list_item_link_text=>'أنواع الشحنات'
,p_list_item_link_target=>'f?p=&APP_ID.:53:&APP_SESSION.::&DEBUG.:53::'
,p_list_item_icon=>'fa-archive'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000670)
,p_security_scheme=>wwv_flow_imp.id(91820290000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000674)
,p_list_item_display_sequence=>44
,p_list_item_link_text=>'تعرفة الترحيل'
,p_list_item_link_target=>'f?p=&APP_ID.:54:&APP_SESSION.::&DEBUG.:54::'
,p_list_item_icon=>'fa-money'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000670)
,p_security_scheme=>wwv_flow_imp.id(91820290000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000675)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-bar-chart'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000676)
,p_list_item_display_sequence=>51
,p_list_item_link_text=>'تقرير الرحلات والالتزام بالمواعيد'
,p_list_item_link_target=>'f?p=&APP_ID.:61:&APP_SESSION.::&DEBUG.:61::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000675)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000677)
,p_list_item_display_sequence=>52
,p_list_item_link_text=>'استغلال الأسطول وربحية العربات'
,p_list_item_link_target=>'f?p=&APP_ID.:62:&APP_SESSION.::&DEBUG.:62::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000675)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000678)
,p_list_item_display_sequence=>53
,p_list_item_link_text=>'أداء السائقين'
,p_list_item_link_target=>'f?p=&APP_ID.:63:&APP_SESSION.::&DEBUG.:63::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000675)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000679)
,p_list_item_display_sequence=>54
,p_list_item_link_text=>'الأعطال والبلاغات وزمن الاستجابة'
,p_list_item_link_target=>'f?p=&APP_ID.:64:&APP_SESSION.::&DEBUG.:64::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000675)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820290000000680)
,p_list_item_display_sequence=>55
,p_list_item_link_text=>'الترحيل حسب العملاء والمسارات'
,p_list_item_link_target=>'f?p=&APP_ID.:65:&APP_SESSION.::&DEBUG.:65::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820290000000675)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
