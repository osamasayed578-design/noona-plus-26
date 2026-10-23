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
 p_id=>wwv_flow_imp.id(91820275000000499)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المستشفى'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-hospital-o'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000500)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الاستقبال والمواعيد'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-calendar'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000501)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'لوحة المواعيد'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-calendar-check-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000500)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000502)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'حجز موعد'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000500)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000503)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'المرضى'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000500)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000504)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'زيارة جديدة'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000500)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000505)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الزيارات والمحاسبة'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-stethoscope'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000506)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'الزيارات'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000505)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000507)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'المحاسبة'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-money'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000505)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000508)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'قوائم المعامل والأشعة والأقسام'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-flask'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000509)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'الإعداد'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cogs'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000510)
,p_list_item_display_sequence=>51
,p_list_item_link_text=>'الأقسام والعيادات والمعامل'
,p_list_item_link_target=>'f?p=&APP_ID.:60:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000509)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000511)
,p_list_item_display_sequence=>52
,p_list_item_link_text=>'دليل الخدمات ومواردها'
,p_list_item_link_target=>'f?p=&APP_ID.:61:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-book'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000509)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000512)
,p_list_item_display_sequence=>53
,p_list_item_link_text=>'الأطباء وساعات العمل'
,p_list_item_link_target=>'f?p=&APP_ID.:62:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user-md'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000509)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000513)
,p_list_item_display_sequence=>54
,p_list_item_link_text=>'التأمين والجهات المتعاقدة'
,p_list_item_link_target=>'f?p=&APP_ID.:63:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-shield'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000509)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000514)
,p_list_item_display_sequence=>55
,p_list_item_link_text=>'مكونات التحاليل وقوالب التقارير'
,p_list_item_link_target=>'f?p=&APP_ID.:64:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-flask'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000509)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000515)
,p_list_item_display_sequence=>56
,p_list_item_link_text=>'الأجهزة الطبية والمعايرة'
,p_list_item_link_target=>'f?p=&APP_ID.:66:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-wrench'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000509)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000516)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'التقارير والمطالبات'
,p_list_item_link_target=>'f?p=&APP_ID.:70:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000806)
,p_list_item_display_sequence=>45
,p_list_item_link_text=>'الرعاية السريرية'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-heartbeat'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000807)
,p_list_item_display_sequence=>451
,p_list_item_link_text=>'الصيدلية الداخلية'
,p_list_item_link_target=>'f?p=&APP_ID.:55:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-medkit'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000806)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000808)
,p_list_item_display_sequence=>452
,p_list_item_link_text=>'التنويم ولوحة الأسرة'
,p_list_item_link_target=>'f?p=&APP_ID.:56:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-bed'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000806)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000809)
,p_list_item_display_sequence=>453
,p_list_item_link_text=>'جدول العمليات'
,p_list_item_link_target=>'f?p=&APP_ID.:57:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-scissors'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000806)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000810)
,p_list_item_display_sequence=>454
,p_list_item_link_text=>'العلاج الطبيعي والجلسات'
,p_list_item_link_target=>'f?p=&APP_ID.:58:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-child'
,p_parent_list_item_id=>wwv_flow_imp.id(91820275000000806)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820275000000811)
,p_list_item_display_sequence=>65
,p_list_item_link_text=>'مطالبات التأمين'
,p_list_item_link_target=>'f?p=&APP_ID.:71:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-file-text'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
