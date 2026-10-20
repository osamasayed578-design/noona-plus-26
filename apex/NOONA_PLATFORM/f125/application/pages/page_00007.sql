prompt --application/pages/page_00007
begin
--   Manifest
--     PAGE: 00007
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
 p_id=>7
,p_name=>'Platform Admins'
,p_alias=>'ADMINS'
,p_step_title=>'مسؤولو المنصة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820265000000003)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000092)
,p_plug_name=>'مسؤولو المنصة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select id, username, display_name, email, noona_ui_pkg.code_label(mfa_required) as mfa, to_char(last_login_at, ''YYYY-MM-DD HH24:MI'') as last_login,',
'       noona_ui_pkg.status_badge(status_code) as status_html from sec_user where user_type in (''PLATFORM_ADMIN'', ''SUPPORT'', ''BREAK_GLASS'')'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مسؤولو المنصة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820265000000093)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_owner=>'NOONA'
,p_internal_uid=>91820265000000093
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000095)
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
 p_id=>wwv_flow_imp.id(91820265000000096)
,p_db_column_name=>'USERNAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'اسم الدخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000097)
,p_db_column_name=>'DISPLAY_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الاسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000098)
,p_db_column_name=>'EMAIL'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'البريد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000099)
,p_db_column_name=>'MFA'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'تحقق متعدد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000100)
,p_db_column_name=>'LAST_LOGIN'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'آخر دخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820265000000101)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820265000000094)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'94'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'USERNAME:DISPLAY_NAME:EMAIL:MFA:LAST_LOGIN:STATUS_HTML'
);

wwv_flow_imp.component_end;
end;
/
