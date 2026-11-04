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
 p_id=>wwv_flow_imp.id(91820262000000139)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة الإدارة'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000140)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'الشركات والفروع'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-building-o'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000141)
,p_list_item_display_sequence=>21
,p_list_item_link_text=>'الشركات'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-building'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000140)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000142)
,p_list_item_display_sequence=>22
,p_list_item_link_text=>'الفروع'
,p_list_item_link_target=>'f?p=&APP_ID.:12:&APP_SESSION.::&DEBUG.:12::'
,p_list_item_icon=>'fa-map-marker'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000140)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000263)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الهيكل التنظيمي'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-sitemap'
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000264)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'الهياكل والإصدارات'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
,p_list_item_icon=>'fa-sitemap'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000263)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000265)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'المناصب والوظائف'
,p_list_item_link_target=>'f?p=&APP_ID.:22:&APP_SESSION.::&DEBUG.:22::'
,p_list_item_icon=>'fa-id-badge'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000263)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000266)
,p_list_item_display_sequence=>33
,p_list_item_link_text=>'تعيين الموظفين'
,p_list_item_link_target=>'f?p=&APP_ID.:23:&APP_SESSION.::&DEBUG.:23::'
,p_list_item_icon=>'fa-user-plus'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000263)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000670)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'المستخدمون والصلاحيات'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-users'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000671)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'المستخدمون'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:30::'
,p_list_item_icon=>'fa-user'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000670)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000672)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'الأدوار والصلاحيات'
,p_list_item_link_target=>'f?p=&APP_ID.:32:&APP_SESSION.::&DEBUG.:32::'
,p_list_item_icon=>'fa-key'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000670)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000673)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'مسارات الاعتماد والتفويض'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-sitemap'
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000674)
,p_list_item_display_sequence=>51
,p_list_item_link_text=>'مسارات الاعتماد'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.:40::'
,p_list_item_icon=>'fa-random'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000673)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000675)
,p_list_item_display_sequence=>52
,p_list_item_link_text=>'شروط التوجيه'
,p_list_item_link_target=>'f?p=&APP_ID.:42:&APP_SESSION.::&DEBUG.:42::'
,p_list_item_icon=>'fa-filter'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000673)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000676)
,p_list_item_display_sequence=>53
,p_list_item_link_text=>'التفويضات'
,p_list_item_link_target=>'f?p=&APP_ID.:43:&APP_SESSION.::&DEBUG.:43::'
,p_list_item_icon=>'fa-share'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000673)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000677)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'البيانات المرجعية'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-database'
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000678)
,p_list_item_display_sequence=>61
,p_list_item_link_text=>'العملات'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:50::'
,p_list_item_icon=>'fa-money'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000677)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000679)
,p_list_item_display_sequence=>62
,p_list_item_link_text=>'أنواع أسعار الصرف'
,p_list_item_link_target=>'f?p=&APP_ID.:51:&APP_SESSION.::&DEBUG.:51::'
,p_list_item_icon=>'fa-exchange'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000677)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000680)
,p_list_item_display_sequence=>63
,p_list_item_link_text=>'شروط الدفع'
,p_list_item_link_target=>'f?p=&APP_ID.:52:&APP_SESSION.::&DEBUG.:52::'
,p_list_item_icon=>'fa-calendar-check-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000677)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000681)
,p_list_item_display_sequence=>64
,p_list_item_link_text=>'تسلسلات المستندات'
,p_list_item_link_target=>'f?p=&APP_ID.:53:&APP_SESSION.::&DEBUG.:53::'
,p_list_item_icon=>'fa-sort-numeric-asc'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000677)
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000682)
,p_list_item_display_sequence=>70
,p_list_item_link_text=>'سجل التدقيق'
,p_list_item_link_target=>'f?p=&APP_ID.:60:&APP_SESSION.::&DEBUG.:60::'
,p_list_item_icon=>'fa-shield'
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000788)
,p_list_item_display_sequence=>65
,p_list_item_link_text=>'التكاملات وواجهات API'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-plug'
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000789)
,p_list_item_display_sequence=>651
,p_list_item_link_text=>'لوحة التكاملات'
,p_list_item_link_target=>'f?p=&APP_ID.:70:&APP_SESSION.::&DEBUG.:70::'
,p_list_item_icon=>'fa-dashboard'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000788)
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000790)
,p_list_item_display_sequence=>652
,p_list_item_link_text=>'عملاء API'
,p_list_item_link_target=>'f?p=&APP_ID.:71:&APP_SESSION.::&DEBUG.:71::'
,p_list_item_icon=>'fa-key'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000788)
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000791)
,p_list_item_display_sequence=>653
,p_list_item_link_text=>'Webhooks'
,p_list_item_link_target=>'f?p=&APP_ID.:73:&APP_SESSION.::&DEBUG.:73::'
,p_list_item_icon=>'fa-bolt'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000788)
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000792)
,p_list_item_display_sequence=>654
,p_list_item_link_text=>'الأحداث الصادرة'
,p_list_item_link_target=>'f?p=&APP_ID.:74:&APP_SESSION.::&DEBUG.:74::'
,p_list_item_icon=>'fa-paper-plane'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000788)
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000793)
,p_list_item_display_sequence=>655
,p_list_item_link_text=>'الرسائل SMS / واتساب'
,p_list_item_link_target=>'f?p=&APP_ID.:75:&APP_SESSION.::&DEBUG.:75::'
,p_list_item_icon=>'fa-comments'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000788)
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000794)
,p_list_item_display_sequence=>656
,p_list_item_link_text=>'استيراد البيانات'
,p_list_item_link_target=>'f?p=&APP_ID.:76:&APP_SESSION.::&DEBUG.:76::'
,p_list_item_icon=>'fa-upload'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000788)
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000795)
,p_list_item_display_sequence=>657
,p_list_item_link_text=>'سجل الطلبات'
,p_list_item_link_target=>'f?p=&APP_ID.:72:&APP_SESSION.::&DEBUG.:72::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000788)
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000796)
,p_list_item_display_sequence=>658
,p_list_item_link_text=>'نقاط النهاية والتوثيق'
,p_list_item_link_target=>'f?p=&APP_ID.:77:&APP_SESSION.::&DEBUG.:77::'
,p_list_item_icon=>'fa-book'
,p_parent_list_item_id=>wwv_flow_imp.id(91820262000000788)
,p_security_scheme=>wwv_flow_imp.id(91820262000000683)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820262000000819)
,p_list_item_display_sequence=>75
,p_list_item_link_text=>'الذكاء الاصطناعي'
,p_list_item_link_target=>'f?p=&APP_ID.:80:&APP_SESSION.::&DEBUG.:80::'
,p_list_item_icon=>'fa-magic'
,p_security_scheme=>wwv_flow_imp.id(17758617306442989)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
