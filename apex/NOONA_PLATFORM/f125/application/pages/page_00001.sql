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
,p_plug_name=>'المؤسسات المشتركة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.id, t.tenant_code, t.name_ar, t.country_code, t.deployment_model,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''COMPANIES'') as companies,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''USERS'') as users,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''MODULES'') as modules,',
'       noona_platform_admin_pkg.tenant_metric(t.id, ''LAST_LOGIN'') as last_login,',
'       noona_ui_pkg.code_label(t.legal_hold) as legal_hold, noona_ui_pkg.status_badge(t.status_code) as status_html',
'  from plt_tenant t'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'المؤسسات المشتركة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820265000000011)
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
,p_internal_uid=>91820265000000011
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000013)
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
 p_id=>wwv_flow_imp.id(91820265000000014)
,p_db_column_name=>'TENANT_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000015)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المؤسسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000016)
,p_db_column_name=>'COUNTRY_CODE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الدولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000017)
,p_db_column_name=>'DEPLOYMENT_MODEL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'نموذج التشغيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000018)
,p_db_column_name=>'COMPANIES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'شركات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000019)
,p_db_column_name=>'USERS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'مستخدمون'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000020)
,p_db_column_name=>'MODULES'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'وحدات مشترك فيها'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000021)
,p_db_column_name=>'LAST_LOGIN'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'آخر دخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000022)
,p_db_column_name=>'LEGAL_HOLD'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'حجز قانوني'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000023)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820265000000012)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'12'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TENANT_CODE:NAME_AR:COUNTRY_CODE:DEPLOYMENT_MODEL:COMPANIES:USERS:MODULES:LAST_LOGIN:LEGAL_HOLD:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000024)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000010)
,p_button_name=>'NEW_TENANT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز مؤسسة جديدة'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:4:&SESSION.::&DEBUG.:::'
);

wwv_flow_imp.component_end;
end;
/
