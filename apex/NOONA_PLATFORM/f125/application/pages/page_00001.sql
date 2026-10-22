prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>125
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'لوحة المنصة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820265000000003)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000009)
,p_plug_name=>'مؤشرات المنصة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_platform_admin_pkg.platform_summary;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000010)
,p_plug_name=>'متابعة الاشتراكات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000011)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000010)
,p_button_name=>'APPLY_EXPIRY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تطبيق قواعد الانتهاء الآن (سماح ← قراءة فقط ← تعليق)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000012)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820265000000010)
,p_button_name=>'SUBS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'كل الاشتراكات'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:8:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000013)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Apply Expiry'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_platform_admin_pkg.apply_expiry;',
'    apex_application.g_print_success_message := ''تم تطبيق قواعد الانتهاء: تغيرت حالة '' || l_n || '' مؤسسة'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000011)
,p_internal_uid=>91820265000000013
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000014)
,p_plug_name=>'تنتهي خلال 60 يوماً'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select * from (',
'select t.id, t.tenant_code, t.name_ar, t.country_code, t.deployment_model,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''COMPANIES'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''COMPANIES''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''COMPANIES''), '''') as companies,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''BRANCHES'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''BRANCHES''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''BRANCHES''), '''') as branches,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''USERS'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''USERS''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''USERS''), '''') as users,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''MODULES'') as modules,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''LAST_LOGIN'') as last_login,',
'       noona_platform_admin_pkg.sub_info(t.id, ''PLAN'') as plan_name, noona_platform_admin_pkg.sub_info(t.id, ''END'') as sub_end,',
'       to_number(noona_platform_admin_pkg.sub_info(t.id, ''LEFT'')) as days_left, to_char(t.created_at, ''YYYY-MM-DD'') as joined,',
'       noona_ui_pkg.code_label(t.legal_hold) as legal_hold, noona_ui_pkg.status_badge(t.status_code) as status_html, t.status_code',
'  from plt_tenant t',
') where days_left between 0 and 60 order by days_left'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'تنتهي خلال 60 يوماً'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820265000000015)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820265000000015
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000017)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000018)
,p_db_column_name=>'TENANT_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000019)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المؤسسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000020)
,p_db_column_name=>'COUNTRY_CODE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الدولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000021)
,p_db_column_name=>'DEPLOYMENT_MODEL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'نموذج التشغيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000022)
,p_db_column_name=>'COMPANIES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'شركات (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000023)
,p_db_column_name=>'BRANCHES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'فروع (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000024)
,p_db_column_name=>'USERS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'مستخدمون (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000025)
,p_db_column_name=>'MODULES'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'وحدات مشترك فيها'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000026)
,p_db_column_name=>'LAST_LOGIN'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'آخر دخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000027)
,p_db_column_name=>'PLAN_NAME'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الباقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000028)
,p_db_column_name=>'SUB_END'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'نهاية الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000029)
,p_db_column_name=>'DAYS_LEFT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الأيام المتبقية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000030)
,p_db_column_name=>'JOINED'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'تاريخ الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000031)
,p_db_column_name=>'LEGAL_HOLD'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'حجز قانوني'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000032)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000033)
,p_db_column_name=>'STATUS_CODE'
,p_display_order=>170
,p_column_identifier=>'Q'
,p_column_label=>'رمز الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820265000000016)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'16'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TENANT_CODE:NAME_AR:COUNTRY_CODE:DEPLOYMENT_MODEL:COMPANIES:BRANCHES:USERS:MODULES:LAST_LOGIN:PLAN_NAME:SUB_END:DAYS_LEFT:JOINED:LEGAL_HOLD:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000034)
,p_plug_name=>'منتهية: فترة سماح أو قراءة فقط أو معلقة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>22
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select * from (',
'select t.id, t.tenant_code, t.name_ar, t.country_code, t.deployment_model,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''COMPANIES'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''COMPANIES''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''COMPANIES''), '''') as companies,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''BRANCHES'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''BRANCHES''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''BRANCHES''), '''') as branches,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''USERS'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''USERS''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''USERS''), '''') as users,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''MODULES'') as modules,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''LAST_LOGIN'') as last_login,',
'       noona_platform_admin_pkg.sub_info(t.id, ''PLAN'') as plan_name, noona_platform_admin_pkg.sub_info(t.id, ''END'') as sub_end,',
'       to_number(noona_platform_admin_pkg.sub_info(t.id, ''LEFT'')) as days_left, to_char(t.created_at, ''YYYY-MM-DD'') as joined,',
'       noona_ui_pkg.code_label(t.legal_hold) as legal_hold, noona_ui_pkg.status_badge(t.status_code) as status_html, t.status_code',
'  from plt_tenant t',
') where days_left < 0 or status_code in (''GRACE_PERIOD'', ''READ_ONLY'', ''SUSPENDED'') order by days_left'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'منتهية: فترة سماح أو قراءة فقط أو معلقة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820265000000035)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820265000000035
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000037)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000038)
,p_db_column_name=>'TENANT_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000039)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المؤسسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000040)
,p_db_column_name=>'COUNTRY_CODE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الدولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000041)
,p_db_column_name=>'DEPLOYMENT_MODEL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'نموذج التشغيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000042)
,p_db_column_name=>'COMPANIES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'شركات (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000043)
,p_db_column_name=>'BRANCHES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'فروع (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000044)
,p_db_column_name=>'USERS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'مستخدمون (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000045)
,p_db_column_name=>'MODULES'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'وحدات مشترك فيها'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000046)
,p_db_column_name=>'LAST_LOGIN'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'آخر دخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000047)
,p_db_column_name=>'PLAN_NAME'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الباقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000048)
,p_db_column_name=>'SUB_END'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'نهاية الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000049)
,p_db_column_name=>'DAYS_LEFT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الأيام المتبقية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000050)
,p_db_column_name=>'JOINED'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'تاريخ الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000051)
,p_db_column_name=>'LEGAL_HOLD'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'حجز قانوني'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000052)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000053)
,p_db_column_name=>'STATUS_CODE'
,p_display_order=>170
,p_column_identifier=>'Q'
,p_column_label=>'رمز الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820265000000036)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'36'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TENANT_CODE:NAME_AR:COUNTRY_CODE:DEPLOYMENT_MODEL:COMPANIES:BRANCHES:USERS:MODULES:LAST_LOGIN:PLAN_NAME:SUB_END:DAYS_LEFT:JOINED:LEGAL_HOLD:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000054)
,p_plug_name=>'مشتركون جدد (آخر 30 يوماً)'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>24
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select * from (',
'select t.id, t.tenant_code, t.name_ar, t.country_code, t.deployment_model,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''COMPANIES'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''COMPANIES''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''COMPANIES''), '''') as companies,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''BRANCHES'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''BRANCHES''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''BRANCHES''), '''') as branches,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''USERS'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''USERS''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''USERS''), '''') as users,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''MODULES'') as modules,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''LAST_LOGIN'') as last_login,',
'       noona_platform_admin_pkg.sub_info(t.id, ''PLAN'') as plan_name, noona_platform_admin_pkg.sub_info(t.id, ''END'') as sub_end,',
'       to_number(noona_platform_admin_pkg.sub_info(t.id, ''LEFT'')) as days_left, to_char(t.created_at, ''YYYY-MM-DD'') as joined,',
'       noona_ui_pkg.code_label(t.legal_hold) as legal_hold, noona_ui_pkg.status_badge(t.status_code) as status_html, t.status_code',
'  from plt_tenant t',
') where joined >= to_char(sysdate - 30, ''YYYY-MM-DD'') order by joined desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مشتركون جدد (آخر 30 يوماً)'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820265000000055)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820265000000055
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000057)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000058)
,p_db_column_name=>'TENANT_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000059)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المؤسسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000060)
,p_db_column_name=>'COUNTRY_CODE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الدولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000061)
,p_db_column_name=>'DEPLOYMENT_MODEL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'نموذج التشغيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000062)
,p_db_column_name=>'COMPANIES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'شركات (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000063)
,p_db_column_name=>'BRANCHES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'فروع (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000064)
,p_db_column_name=>'USERS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'مستخدمون (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000065)
,p_db_column_name=>'MODULES'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'وحدات مشترك فيها'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000066)
,p_db_column_name=>'LAST_LOGIN'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'آخر دخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000067)
,p_db_column_name=>'PLAN_NAME'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الباقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000068)
,p_db_column_name=>'SUB_END'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'نهاية الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000069)
,p_db_column_name=>'DAYS_LEFT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الأيام المتبقية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000070)
,p_db_column_name=>'JOINED'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'تاريخ الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000071)
,p_db_column_name=>'LEGAL_HOLD'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'حجز قانوني'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000072)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000073)
,p_db_column_name=>'STATUS_CODE'
,p_display_order=>170
,p_column_identifier=>'Q'
,p_column_label=>'رمز الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820265000000056)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'56'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TENANT_CODE:NAME_AR:COUNTRY_CODE:DEPLOYMENT_MODEL:COMPANIES:BRANCHES:USERS:MODULES:LAST_LOGIN:PLAN_NAME:SUB_END:DAYS_LEFT:JOINED:LEGAL_HOLD:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000074)
,p_plug_name=>'المؤسسات المشتركة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.id, t.tenant_code, t.name_ar, t.country_code, t.deployment_model,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''COMPANIES'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''COMPANIES''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''COMPANIES''), '''') as companies,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''BRANCHES'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''BRANCHES''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''BRANCHES''), '''') as branches,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''USERS'') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, ''USERS''),',
'           '' / '' || noona_platform_admin_pkg.tenant_limit(t.id, ''USERS''), '''') as users,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''MODULES'') as modules,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''LAST_LOGIN'') as last_login,',
'       noona_platform_admin_pkg.sub_info(t.id, ''PLAN'') as plan_name, noona_platform_admin_pkg.sub_info(t.id, ''END'') as sub_end,',
'       to_number(noona_platform_admin_pkg.sub_info(t.id, ''LEFT'')) as days_left, to_char(t.created_at, ''YYYY-MM-DD'') as joined,',
'       noona_ui_pkg.code_label(t.legal_hold) as legal_hold, noona_ui_pkg.status_badge(t.status_code) as status_html, t.status_code',
'  from plt_tenant t'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'المؤسسات المشتركة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820265000000075)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820265000000075
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000077)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000078)
,p_db_column_name=>'TENANT_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000079)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المؤسسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000080)
,p_db_column_name=>'COUNTRY_CODE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الدولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000081)
,p_db_column_name=>'DEPLOYMENT_MODEL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'نموذج التشغيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000082)
,p_db_column_name=>'COMPANIES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'شركات (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000083)
,p_db_column_name=>'BRANCHES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'فروع (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000084)
,p_db_column_name=>'USERS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'مستخدمون (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000085)
,p_db_column_name=>'MODULES'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'وحدات مشترك فيها'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000086)
,p_db_column_name=>'LAST_LOGIN'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'آخر دخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000087)
,p_db_column_name=>'PLAN_NAME'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الباقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000088)
,p_db_column_name=>'SUB_END'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'نهاية الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000089)
,p_db_column_name=>'DAYS_LEFT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الأيام المتبقية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000090)
,p_db_column_name=>'JOINED'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'تاريخ الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000091)
,p_db_column_name=>'LEGAL_HOLD'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'حجز قانوني'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000092)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000093)
,p_db_column_name=>'STATUS_CODE'
,p_display_order=>170
,p_column_identifier=>'Q'
,p_column_label=>'رمز الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820265000000076)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'76'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TENANT_CODE:NAME_AR:COUNTRY_CODE:DEPLOYMENT_MODEL:COMPANIES:BRANCHES:USERS:MODULES:LAST_LOGIN:PLAN_NAME:SUB_END:DAYS_LEFT:JOINED:LEGAL_HOLD:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000094)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000074)
,p_button_name=>'NEW_TENANT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز مؤسسة جديدة'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:4:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820265000000095)
,p_branch_action=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
