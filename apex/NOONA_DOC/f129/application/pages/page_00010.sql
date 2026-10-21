prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
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
 p_id=>10
,p_name=>'Archive'
,p_alias=>'ARCHIVE'
,p_step_title=>'البحث في الأرشيف'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000029)
,p_plug_name=>'الأرشيف'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select d.id, d.reference_no, t.name_ar as type_name, d.title, d.external_ref, d.physical_location,',
'       to_char(d.document_date, ''YYYY-MM-DD'') as document_date,',
'       (select listagg(noona_dms_pkg.entity_label(k.entity_type, k.entity_id), ''، '') within group (order by k.id)',
'          from dms_document_link k where k.document_id = d.id and k.status_code = ''ACTIVE'') as linked_to,',
'       case when d.current_version_id is null then ''<span class="nn-badge is-muted">ورقي فقط</span>''',
'            else ''<span class="nn-badge is-success">'' || (select c.file_name from dms_document_version v join dms_file_content c on c.id = v.content_id',
'                                                            where v.id = d.current_version_id) || ''</span>'' end as file_html,',
'       d.created_by, d.created_at',
'  from dms_document d join dms_document_type t on t.id = d.document_type_id',
' where d.company_id = noona_dms_pkg.company and d.is_deleted = ''N'' and t.code <> ''COMPANY_LOGO''',
' order by d.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الأرشيف'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820267000000030)
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
,p_detail_link=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11:P11_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820267000000030
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000032)
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
 p_id=>wwv_flow_imp.id(91820267000000033)
,p_db_column_name=>'REFERENCE_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'رقم الأرشيف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000034)
,p_db_column_name=>'TYPE_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000035)
,p_db_column_name=>'TITLE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'العنوان'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000036)
,p_db_column_name=>'EXTERNAL_REF'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المرجع الورقي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000037)
,p_db_column_name=>'PHYSICAL_LOCATION'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'موقع الأصل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000038)
,p_db_column_name=>'DOCUMENT_DATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000039)
,p_db_column_name=>'LINKED_TO'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'مرتبط بـ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000040)
,p_db_column_name=>'FILE_HTML'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الصورة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000041)
,p_db_column_name=>'CREATED_BY'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'أرشفه'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000042)
,p_db_column_name=>'CREATED_AT'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'وقت الأرشفة'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820267000000031)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'31'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'REFERENCE_NO:TYPE_NAME:TITLE:EXTERNAL_REF:PHYSICAL_LOCATION:DOCUMENT_DATE:LINKED_TO:FILE_HTML:CREATED_BY:CREATED_AT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000043)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000029)
,p_button_name=>'NEW_DOC'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'أرشفة مستند'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.:RP,12::'
);

wwv_flow_imp.component_end;
end;
/
