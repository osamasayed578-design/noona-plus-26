prompt --application/pages/page_00008
begin
--   Manifest
--     PAGE: 00008
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
 p_id=>8
,p_name=>'Subscriptions'
,p_alias=>'SUBSCRIPTIONS'
,p_step_title=>'الاشتراكات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820265000000003)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000200)
,p_plug_name=>'اشتراكات المؤسسات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
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
') where 1 = 1 order by days_left nulls first'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'اشتراكات المؤسسات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820265000000201)
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
,p_internal_uid=>91820265000000201
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000203)
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
 p_id=>wwv_flow_imp.id(91820265000000204)
,p_db_column_name=>'TENANT_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000205)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المؤسسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000206)
,p_db_column_name=>'COUNTRY_CODE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الدولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000207)
,p_db_column_name=>'DEPLOYMENT_MODEL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'نموذج التشغيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000208)
,p_db_column_name=>'COMPANIES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'شركات (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000209)
,p_db_column_name=>'BRANCHES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'فروع (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000210)
,p_db_column_name=>'USERS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'مستخدمون (الحد)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000211)
,p_db_column_name=>'MODULES'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'وحدات مشترك فيها'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000212)
,p_db_column_name=>'LAST_LOGIN'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'آخر دخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000213)
,p_db_column_name=>'PLAN_NAME'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الباقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000214)
,p_db_column_name=>'SUB_END'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'نهاية الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000215)
,p_db_column_name=>'DAYS_LEFT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الأيام المتبقية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000216)
,p_db_column_name=>'JOINED'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'تاريخ الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000217)
,p_db_column_name=>'LEGAL_HOLD'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'حجز قانوني'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000218)
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
 p_id=>wwv_flow_imp.id(91820265000000219)
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
 p_id=>wwv_flow_imp.id(91820265000000202)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'202'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TENANT_CODE:NAME_AR:COUNTRY_CODE:DEPLOYMENT_MODEL:COMPANIES:BRANCHES:USERS:MODULES:LAST_LOGIN:PLAN_NAME:SUB_END:DAYS_LEFT:JOINED:LEGAL_HOLD:STATUS_HTML'
);

wwv_flow_imp.component_end;
end;
/
