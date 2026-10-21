prompt --application/pages/page_00030
begin
--   Manifest
--     PAGE: 00030
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>'Access Log'
,p_alias=>'ACCESS-LOG'
,p_step_title=>'سجل الوصول للمستندات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000114)
,p_plug_name=>'سجل الوصول'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select l.id, l.created_at, d.reference_no, d.title, decode(l.access_type, ''DOWNLOAD'', ''تنزيل/عرض'', l.access_type) as access_type,',
'       nvl(u.username, l.created_by) as username,',
'       case l.result_code when ''ALLOWED'' then ''<span class="nn-badge is-success">مسموح</span>'' else ''<span class="nn-badge is-danger">مرفوض</span>'' end as result_html',
'  from dms_access_log l join dms_document d on d.id = l.document_id',
'  left join sec_user_membership m on m.id = l.membership_id left join sec_user u on u.id = m.user_id',
' where d.company_id = noona_dms_pkg.company order by l.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'سجل الوصول'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820267000000115)
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
,p_internal_uid=>91820267000000115
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000117)
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
 p_id=>wwv_flow_imp.id(91820267000000118)
,p_db_column_name=>'CREATED_AT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوقت'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000119)
,p_db_column_name=>'REFERENCE_NO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'رقم الأرشيف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000120)
,p_db_column_name=>'TITLE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000121)
,p_db_column_name=>'ACCESS_TYPE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الإجراء'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000122)
,p_db_column_name=>'USERNAME'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المستخدم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000123)
,p_db_column_name=>'RESULT_HTML'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'النتيجة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820267000000116)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'116'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CREATED_AT:REFERENCE_NO:TITLE:ACCESS_TYPE:USERNAME:RESULT_HTML'
);

wwv_flow_imp.component_end;
end;
/
