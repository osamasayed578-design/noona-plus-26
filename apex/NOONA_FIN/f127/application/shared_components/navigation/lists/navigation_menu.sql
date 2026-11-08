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
 p_id=>wwv_flow_imp.id(91820266000000490)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المالية'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-calculator'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الأستاذ العام'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-book'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000492)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'القيود اليومية'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
,p_list_item_icon=>'fa-list-alt'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000493)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'قيد جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:21::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000494)
,p_list_item_display_sequence=>23
,p_list_item_link_text=>'دليل الحسابات'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000495)
,p_list_item_display_sequence=>24
,p_list_item_link_text=>'مراكز التكلفة'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:12::'
,p_list_item_icon=>'fa-crosshairs'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000496)
,p_list_item_display_sequence=>25
,p_list_item_link_text=>'الفترات المحاسبية'
,p_list_item_link_target=>'f?p=&APP_ID.:11:&APP_SESSION.::&DEBUG.:11::'
,p_list_item_icon=>'fa-calendar'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000497)
,p_list_item_display_sequence=>28
,p_list_item_link_text=>'أنواع القيود'
,p_list_item_link_target=>'f?p=&APP_ID.:14:&APP_SESSION.::&DEBUG.:14::'
,p_list_item_icon=>'fa-tags'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000498)
,p_list_item_display_sequence=>26
,p_list_item_link_text=>'إقفال السنة المالية'
,p_list_item_link_target=>'f?p=&APP_ID.:13:&APP_SESSION.::&DEBUG.:13::'
,p_list_item_icon=>'fa-lock'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000499)
,p_list_item_display_sequence=>27
,p_list_item_link_text=>'أسعار الصرف'
,p_list_item_link_target=>'f?p=&APP_ID.:48:&APP_SESSION.::&DEBUG.:48::'
,p_list_item_icon=>'fa-exchange'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000491)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000500)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'النقدية والبنوك'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-money'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000501)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'السندات'
,p_list_item_link_target=>'f?p=&APP_ID.:41:&APP_SESSION.::&DEBUG.:41::'
,p_list_item_icon=>'fa-files-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000500)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000502)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'سند قبض جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:RECEIPT'
,p_list_item_icon=>'fa-arrow-down'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000500)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000503)
,p_list_item_display_sequence=>33
,p_list_item_link_text=>'سند صرف جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:PAYMENT'
,p_list_item_icon=>'fa-arrow-up'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000500)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000504)
,p_list_item_display_sequence=>34
,p_list_item_link_text=>'سند مصروفات جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:EXPENSE'
,p_list_item_icon=>'fa-shopping-cart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000500)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000505)
,p_list_item_display_sequence=>35
,p_list_item_link_text=>'الصناديق والبنوك'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:40::'
,p_list_item_icon=>'fa-university'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000500)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000506)
,p_list_item_display_sequence=>36
,p_list_item_link_text=>'دفتر الصندوق والبنك'
,p_list_item_link_target=>'f?p=&APP_ID.:44:&APP_SESSION.::&DEBUG.:44::'
,p_list_item_icon=>'fa-book'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000500)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000507)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'القوائم المالية'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-file-text'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000508)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'قائمة المركز المالي'
,p_list_item_link_target=>'f?p=&APP_ID.:33:&APP_SESSION.::&DEBUG.:33::'
,p_list_item_icon=>'fa-columns'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000507)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000509)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'قائمة الربح أو الخسارة'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:32::'
,p_list_item_icon=>'fa-line-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000507)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000510)
,p_list_item_display_sequence=>43
,p_list_item_link_text=>'التدفقات النقدية'
,p_list_item_link_target=>'f?p=&APP_ID.:37:&APP_SESSION.::&DEBUG.:37::'
,p_list_item_icon=>'fa-exchange'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000507)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000511)
,p_list_item_display_sequence=>44
,p_list_item_link_text=>'التغيرات في حقوق الملكية'
,p_list_item_link_target=>'f?p=&APP_ID.:38:&APP_SESSION.::&DEBUG.:38::'
,p_list_item_icon=>'fa-users'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000507)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000512)
,p_list_item_display_sequence=>45
,p_list_item_link_text=>'الشركة القابضة (التجميع)'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-object-group'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000513)
,p_list_item_display_sequence=>46
,p_list_item_link_text=>'القوائم المالية الموحدة'
,p_list_item_link_target=>'f?p=&APP_ID.:54:&APP_SESSION.::&DEBUG.:54::'
,p_list_item_icon=>'fa-files-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000512)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000514)
,p_list_item_display_sequence=>47
,p_list_item_link_text=>'مجموعات التجميع'
,p_list_item_link_target=>'f?p=&APP_ID.:52:&APP_SESSION.::&DEBUG.:52::'
,p_list_item_icon=>'fa-cubes'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000512)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000515)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'تقارير الأستاذ'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-book'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000516)
,p_list_item_display_sequence=>51
,p_list_item_link_text=>'ميزان المراجعة'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:30::'
,p_list_item_icon=>'fa-balance-scale'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000515)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000517)
,p_list_item_display_sequence=>52
,p_list_item_link_text=>'دفتر الأستاذ'
,p_list_item_link_target=>'f?p=&APP_ID.:35:&APP_SESSION.::&DEBUG.:35::'
,p_list_item_icon=>'fa-bookmark'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000515)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000518)
,p_list_item_display_sequence=>53
,p_list_item_link_text=>'كشف حساب'
,p_list_item_link_target=>'f?p=&APP_ID.:31:&APP_SESSION.::&DEBUG.:31::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000515)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000519)
,p_list_item_display_sequence=>54
,p_list_item_link_text=>'يومية القيود'
,p_list_item_link_target=>'f?p=&APP_ID.:36:&APP_SESSION.::&DEBUG.:36::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000515)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000520)
,p_list_item_display_sequence=>55
,p_list_item_link_text=>'القيود حسب النوع'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:50::'
,p_list_item_icon=>'fa-tags'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000515)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000521)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'التحليل المالي'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-bar-chart'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000522)
,p_list_item_display_sequence=>61
,p_list_item_link_text=>'تحليل الإيرادات والمصروفات'
,p_list_item_link_target=>'f?p=&APP_ID.:34:&APP_SESSION.::&DEBUG.:34::'
,p_list_item_icon=>'fa-pie-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000521)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000523)
,p_list_item_display_sequence=>62
,p_list_item_link_text=>'مقارنة الفترات'
,p_list_item_link_target=>'f?p=&APP_ID.:39:&APP_SESSION.::&DEBUG.:39::'
,p_list_item_icon=>'fa-sliders'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000521)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000524)
,p_list_item_display_sequence=>63
,p_list_item_link_text=>'قائمة الدخل لعدة سنوات'
,p_list_item_link_target=>'f?p=&APP_ID.:51:&APP_SESSION.::&DEBUG.:51::'
,p_list_item_icon=>'fa-calendar'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000521)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000525)
,p_list_item_display_sequence=>64
,p_list_item_link_text=>'النسب المالية'
,p_list_item_link_target=>'f?p=&APP_ID.:45:&APP_SESSION.::&DEBUG.:45::'
,p_list_item_icon=>'fa-percent'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000521)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000526)
,p_list_item_display_sequence=>70
,p_list_item_link_text=>'الرقابة والتدقيق'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-shield'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000527)
,p_list_item_display_sequence=>71
,p_list_item_link_text=>'الرقابة والتسويات'
,p_list_item_link_target=>'f?p=&APP_ID.:46:&APP_SESSION.::&DEBUG.:46::'
,p_list_item_icon=>'fa-check-square-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000526)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000528)
,p_list_item_display_sequence=>72
,p_list_item_link_text=>'سجل التدقيق المالي'
,p_list_item_link_target=>'f?p=&APP_ID.:47:&APP_SESSION.::&DEBUG.:47::'
,p_list_item_icon=>'fa-history'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000526)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000739)
,p_list_item_display_sequence=>65
,p_list_item_link_text=>'الأصول الثابتة'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-building-o'
,p_security_scheme=>wwv_flow_imp.id(91820266000000529)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000740)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'سجل الأصول'
,p_list_item_link_target=>'f?p=&APP_ID.:60:&APP_SESSION.::&DEBUG.:60::'
,p_list_item_icon=>'fa-cubes'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000739)
,p_security_scheme=>wwv_flow_imp.id(91820266000000529)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000741)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'أصل جديد'
,p_list_item_link_target=>'f?p=&APP_ID.:61:&SESSION.::&DEBUG.:RP,61::'
,p_list_item_icon=>'fa-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000739)
,p_security_scheme=>wwv_flow_imp.id(91820266000000529)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000742)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'إهلاك الأصول'
,p_list_item_link_target=>'f?p=&APP_ID.:63:&APP_SESSION.::&DEBUG.:63::'
,p_list_item_icon=>'fa-line-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000739)
,p_security_scheme=>wwv_flow_imp.id(91820266000000529)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000743)
,p_list_item_display_sequence=>4
,p_list_item_link_text=>'بيع وتخريد الأصول'
,p_list_item_link_target=>'f?p=&APP_ID.:65:&SESSION.::&DEBUG.:RP,65::'
,p_list_item_icon=>'fa-recycle'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000739)
,p_security_scheme=>wwv_flow_imp.id(91820266000000529)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000744)
,p_list_item_display_sequence=>5
,p_list_item_link_text=>'تقارير الأصول'
,p_list_item_link_target=>'f?p=&APP_ID.:66:&APP_SESSION.::&DEBUG.:66::'
,p_list_item_icon=>'fa-bar-chart'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000739)
,p_security_scheme=>wwv_flow_imp.id(91820266000000529)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000745)
,p_list_item_display_sequence=>6
,p_list_item_link_text=>'فئات الأصول'
,p_list_item_link_target=>'f?p=&APP_ID.:67:&APP_SESSION.::&DEBUG.:67::'
,p_list_item_icon=>'fa-tags'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000739)
,p_security_scheme=>wwv_flow_imp.id(91820266000000529)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000887)
,p_list_item_display_sequence=>67
,p_list_item_link_text=>'الضرائب'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-percent'
,p_security_scheme=>wwv_flow_imp.id(91820266000000746)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000888)
,p_list_item_display_sequence=>1
,p_list_item_link_text=>'لوحة الضرائب'
,p_list_item_link_target=>'f?p=&APP_ID.:70:&APP_SESSION.::&DEBUG.:70::'
,p_list_item_icon=>'fa-dashboard'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000887)
,p_security_scheme=>wwv_flow_imp.id(91820266000000746)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000889)
,p_list_item_display_sequence=>2
,p_list_item_link_text=>'الإقرارات الضريبية'
,p_list_item_link_target=>'f?p=&APP_ID.:72:&APP_SESSION.::&DEBUG.:72::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000887)
,p_security_scheme=>wwv_flow_imp.id(91820266000000746)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000890)
,p_list_item_display_sequence=>3
,p_list_item_link_text=>'السجل الضريبي'
,p_list_item_link_target=>'f?p=&APP_ID.:74:&APP_SESSION.::&DEBUG.:74::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000887)
,p_security_scheme=>wwv_flow_imp.id(91820266000000746)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000891)
,p_list_item_display_sequence=>4
,p_list_item_link_text=>'ضريبة الاستقطاع'
,p_list_item_link_target=>'f?p=&APP_ID.:75:&APP_SESSION.::&DEBUG.:75::'
,p_list_item_icon=>'fa-scissors'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000887)
,p_security_scheme=>wwv_flow_imp.id(91820266000000746)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000892)
,p_list_item_display_sequence=>5
,p_list_item_link_text=>'الفوترة الإلكترونية'
,p_list_item_link_target=>'f?p=&APP_ID.:77:&APP_SESSION.::&DEBUG.:77::'
,p_list_item_icon=>'fa-qrcode'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000887)
,p_security_scheme=>wwv_flow_imp.id(91820266000000746)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000893)
,p_list_item_display_sequence=>6
,p_list_item_link_text=>'التسجيلات القانونية'
,p_list_item_link_target=>'f?p=&APP_ID.:71:&APP_SESSION.::&DEBUG.:71::'
,p_list_item_icon=>'fa-id-card-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000887)
,p_security_scheme=>wwv_flow_imp.id(91820266000000746)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000921)
,p_list_item_display_sequence=>38
,p_list_item_link_text=>'المطابقة البنكية'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-check-square'
,p_security_scheme=>wwv_flow_imp.id(91820266000000894)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000922)
,p_list_item_display_sequence=>381
,p_list_item_link_text=>'كشوف الحساب والمطابقة'
,p_list_item_link_target=>'f?p=&APP_ID.:79:&APP_SESSION.::&DEBUG.:79::'
,p_list_item_icon=>'fa-university'
,p_parent_list_item_id=>wwv_flow_imp.id(91820266000000921)
,p_security_scheme=>wwv_flow_imp.id(91820266000000894)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820266000000968)
,p_list_item_display_sequence=>11
,p_list_item_link_text=>'التحليلات والتنبؤ'
,p_list_item_link_target=>'f?p=&APP_ID.:98:&APP_SESSION.::&DEBUG.:98::'
,p_list_item_icon=>'fa-line-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
