prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'التوزيع والمبيعات الميدانية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000011)
,p_plug_name=>'تجهيز التوزيع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يجهز التسلسلات والإعدادات الافتراضية للتوزيع. أضف بعدها المندوبين (ينشأ لكل مندوب مستودع سيارة وعهدة نقدية تلقائياً)، ثم خطوط السير وأيام الزيارة، ثم المحلات بمواقعها. مرة واحدة لكل شركة.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_dst_pkg.is_ready = ''N'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000012)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000011)
,p_button_name=>'SETUP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز التوزيع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000013)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setup'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_dst_pkg.quick_setup;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000012)
,p_process_success_message=>'تم تجهيز التوزيع'
,p_internal_uid=>91820300000000013
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000014)
,p_plug_name=>'اختصارات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>6
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_dst_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.quick_links_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000015)
,p_plug_name=>'خطة اليوم'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_dst_pkg.is_ready = ''Y'' and noona_dst_pkg.my_rep is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.plan_html(noona_dst_pkg.my_rep, trunc(sysdate),',
'  replace(apex_page.get_url(p_page => 2, p_clear_cache => ''2'', p_items => ''P2_SHOP'', p_values => ''XSHOPX''), ''XSHOPX'', ''#SHOP#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000016)
,p_plug_name=>'يومي حتى الآن'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_dst_pkg.is_ready = ''Y'' and noona_dst_pkg.my_rep is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.rep_day_html(noona_dst_pkg.my_rep, trunc(sysdate));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000017)
,p_plug_name=>'أداء اليوم لكل المندوبين'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_dst_pkg.is_ready = ''Y'' and noona_security_pkg.has_permission(''DST_REP.UPDATE'', noona_dst_pkg.company) = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.performance_html(trunc(sysdate), trunc(sysdate));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000018)
,p_branch_action=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
