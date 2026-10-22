prompt --application/shared_components/navigation/lists/navigation_bar
begin
--   Manifest
--     LIST: Navigation Bar
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
 p_id=>wwv_flow_imp.id(17755035362442962)
,p_name=>'Navigation Bar'
,p_list_status=>'PUBLIC'
,p_version_scn=>137120844
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(17767087505443068)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'&APP_USER.'
,p_list_item_link_target=>'#'
,p_list_item_icon=>'fa-user'
,p_list_text_02=>'has-username'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(17767551179443070)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'---'
,p_list_item_link_target=>'separator'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_parent_list_item_id=>wwv_flow_imp.id(17767087505443068)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(17767936235443071)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'تسجيل الخروج'
,p_list_item_link_target=>'&LOGOUT_URL.'
,p_list_item_icon=>'fa-sign-out'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_parent_list_item_id=>wwv_flow_imp.id(17767087505443068)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820260001003360)
,p_list_item_display_sequence=>5
,p_list_item_link_text=>'الأنظمة'
,p_list_item_link_target=>'f?p=NOONA_MASTER:1:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-th'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(91820260001003361)
,p_list_item_display_sequence=>15
,p_list_item_link_text=>'تغيير كلمة المرور'
,p_list_item_link_target=>'f?p=NOONA_MASTER:CHANGE-PASSWORD:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-key'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_parent_list_item_id=>wwv_flow_imp.id(17767087505443068)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
