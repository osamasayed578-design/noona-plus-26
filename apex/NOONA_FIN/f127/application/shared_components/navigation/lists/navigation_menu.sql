prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
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
 p_id=>wwv_flow_imp.id(91820266000000292)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المالية'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-calculator'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000293)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الأستاذ العام'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-book'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000294)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'القيود اليومية'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-list-alt'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000293)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000295)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'قيد جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000293)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000296)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'دليل الحسابات'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000293)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000297)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'مراكز التكلفة'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-crosshairs'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000293)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000298)
,p_list_item_display_sequence=>25
,p_list_item_link_text=>'الفترات المحاسبية'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-calendar'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000293)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000299)
,p_list_item_display_sequence=>25
,p_list_item_link_text=>'النقدية والبنوك'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-money'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000300)
,p_list_item_display_sequence=>26
,p_list_item_link_text=>'السندات'
,p_list_item_link_target=>'f?p=&APP_ID.:41:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-files-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000299)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000301)
,p_list_item_display_sequence=>27
,p_list_item_link_text=>'سند قبض جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:RECEIPT'
,p_list_item_icon=>'fa-arrow-down'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000299)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000302)
,p_list_item_display_sequence=>28
,p_list_item_link_text=>'سند صرف جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:PAYMENT'
,p_list_item_icon=>'fa-arrow-up'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000299)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000303)
,p_list_item_display_sequence=>29
,p_list_item_link_text=>'سند مصروفات جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:EXPENSE'
,p_list_item_icon=>'fa-shopping-cart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000299)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000304)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الصناديق والبنوك'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-university'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000299)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000305)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'دفتر الصندوق والبنك'
,p_list_item_link_target=>'f?p=&APP_ID.:44:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-book'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000299)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000306)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'التقارير'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-bar-chart'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000307)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'ميزان المراجعة'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-balance-scale'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000306)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000308)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'كشف حساب'
,p_list_item_link_target=>'f?p=&APP_ID.:31:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000306)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000309)
,p_list_item_display_sequence=>43
,p_list_item_link_text=>'قائمة الدخل'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-line-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000306)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000310)
,p_list_item_display_sequence=>44
,p_list_item_link_text=>'الميزانية العمومية'
,p_list_item_link_target=>'f?p=&APP_ID.:33:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-columns'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000306)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000311)
,p_list_item_display_sequence=>45
,p_list_item_link_text=>'تحليل الإيرادات والمصروفات'
,p_list_item_link_target=>'f?p=&APP_ID.:34:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-pie-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000306)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
