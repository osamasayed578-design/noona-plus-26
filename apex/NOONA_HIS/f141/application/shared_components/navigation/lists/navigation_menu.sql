prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>141
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
 p_id=>wwv_flow_imp.id(91820275000000487)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المستشفى'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-hospital-o'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000488)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الاستقبال والمواعيد'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-calendar'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000489)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'لوحة المواعيد'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-calendar-check-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000488)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000490)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'حجز موعد'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000488)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000491)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'المرضى'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000488)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000492)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'زيارة جديدة'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000488)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000493)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الزيارات والمحاسبة'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-stethoscope'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000494)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'الزيارات'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000493)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000495)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'المحاسبة'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-money'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000493)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000496)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'قوائم المعامل والأشعة والأقسام'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-flask'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000497)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'الإعداد'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cogs'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000498)
,p_list_item_display_sequence=>51
,p_list_item_link_text=>'الأقسام والعيادات والمعامل'
,p_list_item_link_target=>'f?p=&APP_ID.:60:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000497)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000499)
,p_list_item_display_sequence=>52
,p_list_item_link_text=>'دليل الخدمات ومواردها'
,p_list_item_link_target=>'f?p=&APP_ID.:61:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-book'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000497)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000500)
,p_list_item_display_sequence=>53
,p_list_item_link_text=>'الأطباء وساعات العمل'
,p_list_item_link_target=>'f?p=&APP_ID.:62:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user-md'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000497)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000501)
,p_list_item_display_sequence=>54
,p_list_item_link_text=>'التأمين والجهات المتعاقدة'
,p_list_item_link_target=>'f?p=&APP_ID.:63:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-shield'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000497)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000502)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'التقارير والمطالبات'
,p_list_item_link_target=>'f?p=&APP_ID.:70:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
