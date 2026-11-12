prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>151
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
 p_id=>wwv_flow_imp.id(91820310000000225)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'لوحة المدير'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:1::'
,p_list_item_icon=>'fa-tachometer'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000226)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'توقع النقد'
,p_list_item_link_target=>'f?p=&APP_ID.:2:&APP_SESSION.::&DEBUG.:2::'
,p_list_item_icon=>'fa-line-chart'
,p_security_scheme=>wwv_flow_imp.id(91820310000000009)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000227)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'الإنذار المبكر'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-bell'
,p_security_scheme=>wwv_flow_imp.id(91820310000000009)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000228)
,p_list_item_display_sequence=>31
,p_list_item_link_text=>'التنبيهات'
,p_list_item_link_target=>'f?p=&APP_ID.:3:&APP_SESSION.::&DEBUG.:3::'
,p_list_item_icon=>'fa-bell-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000227)
,p_security_scheme=>wwv_flow_imp.id(91820310000000009)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000229)
,p_list_item_display_sequence=>32
,p_list_item_link_text=>'القواعد'
,p_list_item_link_target=>'f?p=&APP_ID.:5:&APP_SESSION.::&DEBUG.:5::'
,p_list_item_icon=>'fa-sliders'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000227)
,p_security_scheme=>wwv_flow_imp.id(91820310000000011)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000230)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'واتساب والعملاء'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-whatsapp'
,p_security_scheme=>wwv_flow_imp.id(91820310000000010)
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000231)
,p_list_item_display_sequence=>41
,p_list_item_link_text=>'إرسال رسالة'
,p_list_item_link_target=>'f?p=&APP_ID.:24:&APP_SESSION.::&DEBUG.:24::'
,p_list_item_icon=>'fa-paper-plane'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000230)
,p_security_scheme=>wwv_flow_imp.id(91820310000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000232)
,p_list_item_display_sequence=>42
,p_list_item_link_text=>'سجل الرسائل'
,p_list_item_link_target=>'f?p=&APP_ID.:23:&APP_SESSION.::&DEBUG.:23::'
,p_list_item_icon=>'fa-list'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000230)
,p_security_scheme=>wwv_flow_imp.id(91820310000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000233)
,p_list_item_display_sequence=>43
,p_list_item_link_text=>'روابط بوابة العملاء'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.:10::'
,p_list_item_icon=>'fa-link'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000230)
,p_security_scheme=>wwv_flow_imp.id(91820310000000010)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000234)
,p_list_item_display_sequence=>44
,p_list_item_link_text=>'قوالب الرسائل'
,p_list_item_link_target=>'f?p=&APP_ID.:21:&APP_SESSION.::&DEBUG.:21::'
,p_list_item_icon=>'fa-file-text-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000230)
,p_security_scheme=>wwv_flow_imp.id(91820310000000011)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000235)
,p_list_item_display_sequence=>45
,p_list_item_link_text=>'إعدادات واتساب'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
,p_list_item_icon=>'fa-cog'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000230)
,p_security_scheme=>wwv_flow_imp.id(91820310000000011)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000236)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'البيانات'
,p_list_item_link_target=>''
,p_list_item_icon=>'fa-database'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000237)
,p_list_item_display_sequence=>51
,p_list_item_link_text=>'تصدير إلى Excel'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.:30::'
,p_list_item_icon=>'fa-file-excel-o'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000236)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000238)
,p_list_item_display_sequence=>52
,p_list_item_link_text=>'سجل التغييرات'
,p_list_item_link_target=>'f?p=&APP_ID.:31:&APP_SESSION.::&DEBUG.:31::'
,p_list_item_icon=>'fa-history'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000236)
,p_security_scheme=>wwv_flow_imp.id(91820310000000009)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820310000000239)
,p_list_item_display_sequence=>53
,p_list_item_link_text=>'دليل الشاشات'
,p_list_item_link_target=>'f?p=&APP_ID.:41:&APP_SESSION.::&DEBUG.:41::'
,p_list_item_icon=>'fa-question-circle'
,p_parent_list_item_id=>wwv_flow_imp.id(91820310000000236)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
