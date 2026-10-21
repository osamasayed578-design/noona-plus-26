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
 p_id=>wwv_flow_imp.id(91820266000000394)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المالية'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-calculator'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000395)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الأستاذ العام'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-book'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000396)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'القيود اليومية'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-list-alt'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000397)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'قيد جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000398)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'دليل الحسابات'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000399)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'مراكز التكلفة'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-crosshairs'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000400)
,p_list_item_display_sequence=>25
,p_list_item_link_text=>'الفترات المحاسبية'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-calendar'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000401)
,p_list_item_display_sequence=>26
,p_list_item_link_text=>'إقفال السنة المالية'
,p_list_item_link_target=>'f?p=&APP_ID.:13:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-lock'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000402)
,p_list_item_display_sequence=>27
,p_list_item_link_text=>'أسعار الصرف'
,p_list_item_link_target=>'f?p=&APP_ID.:48:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-exchange'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000395)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000403)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'النقدية والبنوك'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-money'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000404)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'السندات'
,p_list_item_link_target=>'f?p=&APP_ID.:41:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-files-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000403)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000405)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'سند قبض جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:RECEIPT'
,p_list_item_icon=>'fa-arrow-down'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000403)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000406)
,p_list_item_display_sequence=>33
,p_list_item_link_text=>'سند صرف جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:PAYMENT'
,p_list_item_icon=>'fa-arrow-up'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000403)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000407)
,p_list_item_display_sequence=>34
,p_list_item_link_text=>'سند مصروفات جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:EXPENSE'
,p_list_item_icon=>'fa-shopping-cart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000403)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000408)
,p_list_item_display_sequence=>35
,p_list_item_link_text=>'الصناديق والبنوك'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-university'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000403)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000409)
,p_list_item_display_sequence=>36
,p_list_item_link_text=>'دفتر الصندوق والبنك'
,p_list_item_link_target=>'f?p=&APP_ID.:44:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-book'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000403)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000410)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'القوائم المالية'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-file-text'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000411)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'قائمة المركز المالي'
,p_list_item_link_target=>'f?p=&APP_ID.:33:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-columns'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000410)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000412)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'قائمة الربح أو الخسارة'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-line-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000410)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000413)
,p_list_item_display_sequence=>43
,p_list_item_link_text=>'التدفقات النقدية'
,p_list_item_link_target=>'f?p=&APP_ID.:37:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-exchange'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000410)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000414)
,p_list_item_display_sequence=>44
,p_list_item_link_text=>'التغيرات في حقوق الملكية'
,p_list_item_link_target=>'f?p=&APP_ID.:38:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-users'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000410)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000415)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'تقارير الأستاذ'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-book'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000416)
,p_list_item_display_sequence=>51
,p_list_item_link_text=>'ميزان المراجعة'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-balance-scale'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000415)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000417)
,p_list_item_display_sequence=>52
,p_list_item_link_text=>'دفتر الأستاذ'
,p_list_item_link_target=>'f?p=&APP_ID.:35:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-bookmark'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000415)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000418)
,p_list_item_display_sequence=>53
,p_list_item_link_text=>'كشف حساب'
,p_list_item_link_target=>'f?p=&APP_ID.:31:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000415)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000419)
,p_list_item_display_sequence=>54
,p_list_item_link_text=>'يومية القيود'
,p_list_item_link_target=>'f?p=&APP_ID.:36:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000415)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000420)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'التحليل المالي'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-bar-chart'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000421)
,p_list_item_display_sequence=>61
,p_list_item_link_text=>'تحليل الإيرادات والمصروفات'
,p_list_item_link_target=>'f?p=&APP_ID.:34:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-pie-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000420)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000422)
,p_list_item_display_sequence=>62
,p_list_item_link_text=>'مقارنة الفترات'
,p_list_item_link_target=>'f?p=&APP_ID.:39:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sliders'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000420)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000423)
,p_list_item_display_sequence=>63
,p_list_item_link_text=>'النسب المالية'
,p_list_item_link_target=>'f?p=&APP_ID.:45:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-percent'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000420)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000424)
,p_list_item_display_sequence=>70
,p_list_item_link_text=>'الرقابة والتدقيق'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-shield'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000425)
,p_list_item_display_sequence=>71
,p_list_item_link_text=>'الرقابة والتسويات'
,p_list_item_link_target=>'f?p=&APP_ID.:46:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-check-square-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000424)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000426)
,p_list_item_display_sequence=>72
,p_list_item_link_text=>'سجل التدقيق المالي'
,p_list_item_link_target=>'f?p=&APP_ID.:47:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-history'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000424)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
