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
 p_id=>wwv_flow_imp.id(91820262000000137)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة الإدارة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000138)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الشركات والفروع'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-building-o'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000139)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'الشركات'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-building'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000138)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000140)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'الفروع'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-map-marker'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000138)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000261)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الهيكل التنظيمي'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-sitemap'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000262)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'الهياكل والإصدارات'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000261)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000263)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'المناصب والوظائف'
,p_list_item_link_target=>'f?p=&APP_ID.:22:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-id-badge'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000261)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000264)
,p_list_item_display_sequence=>33
,p_list_item_link_text=>'تعيين الموظفين'
,p_list_item_link_target=>'f?p=&APP_ID.:23:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000261)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000551)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'المستخدمون والصلاحيات'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-users'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000552)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'المستخدمون'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000551)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000553)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'الأدوار والصلاحيات'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-key'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000551)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000554)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'مسارات الاعتماد والتفويض'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-sitemap'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000555)
,p_list_item_display_sequence=>51
,p_list_item_link_text=>'مسارات الاعتماد'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-random'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000554)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000556)
,p_list_item_display_sequence=>52
,p_list_item_link_text=>'شروط التوجيه'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-filter'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000554)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000557)
,p_list_item_display_sequence=>53
,p_list_item_link_text=>'التفويضات'
,p_list_item_link_target=>'f?p=&APP_ID.:43:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-share'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000554)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
