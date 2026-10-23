prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
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
 p_id=>wwv_flow_imp.id(91820269000000380)
,p_list_item_display_sequence=>35
,p_list_item_link_text=>'المطاعم والكافتريا'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-cutlery'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000381)
,p_list_item_display_sequence=>351
,p_list_item_link_text=>'لوحة المطعم'
,p_list_item_link_target=>'f?p=&APP_ID.:60:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-dashboard'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000380)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000382)
,p_list_item_display_sequence=>352
,p_list_item_link_text=>'الصالة والطلبات'
,p_list_item_link_target=>'f?p=&APP_ID.:61:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-th-large'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000380)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000383)
,p_list_item_display_sequence=>353
,p_list_item_link_text=>'شاشة المطبخ'
,p_list_item_link_target=>'f?p=&APP_ID.:62:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-fire'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000380)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000384)
,p_list_item_display_sequence=>354
,p_list_item_link_text=>'العملاء الآجلون والتحصيل'
,p_list_item_link_target=>'f?p=&APP_ID.:63:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-user-circle'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000380)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000385)
,p_list_item_display_sequence=>355
,p_list_item_link_text=>'لوحة مبيعات المطعم'
,p_list_item_link_target=>'f?p=&APP_ID.:64:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-pie-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000380)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000386)
,p_list_item_display_sequence=>356
,p_list_item_link_text=>'سجل الطلبات'
,p_list_item_link_target=>'f?p=&APP_ID.:66:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000380)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000387)
,p_list_item_display_sequence=>357
,p_list_item_link_text=>'إعداد المطعم والقائمة'
,p_list_item_link_target=>'f?p=&APP_ID.:65:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-cogs'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000380)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000388)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المبيعات'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-line-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000389)
,p_list_item_display_sequence=>15
,p_list_item_link_text=>'نقطة البيع'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-shopping-basket'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000390)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'المبيعات والعملاء'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-file-text-o'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000391)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'فاتورة مبيعات جديدة'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000390)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000392)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'فواتير المبيعات والمرتجعات'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-files-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000390)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000393)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'العملاء'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-users'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000390)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000394)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'التحصيل من العملاء'
,p_list_item_link_target=>'f?p=&APP_ID.:23:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-money'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000390)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000395)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'إدارة نقاط البيع'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-desktop'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000396)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'تقرير الوردية وإقفالها'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-lock'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000397)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'إعداد نقاط البيع'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-cogs'
,p_parent_list_item_id=>wwv_flow_imp.id(91820269000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820269000000398)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
