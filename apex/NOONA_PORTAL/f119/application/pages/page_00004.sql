prompt --application/pages/page_00004
begin
--   Manifest
--     PAGE: 00004
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>119
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>4
,p_name=>'My Requests'
,p_alias=>'MY-REQUESTS'
,p_step_title=>'طلباتي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820264000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820264000000035)
,p_plug_name=>'طلباتي'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, d.name_ar as workflow_name, nvl(e.name_ar, i.object_type) as object_name, i.object_id,',
'       to_char(i.started_at, ''YYYY-MM-DD HH24:MI'') as started_at,',
'       (select listagg(s.name_ar, ''، '') within group (order by t.id) from wf_task t join wf_step_def s on s.id = t.step_id',
'         where t.instance_id = i.id and t.status_code in (''OPEN'', ''CLAIMED'', ''WAITING'')) as current_step,',
'       noona_ui_pkg.status_badge(i.status_code) as status_html,',
'       case i.outcome_code when ''APPROVED'' then ''معتمد'' when ''REJECTED'' then ''مرفوض'' when ''RETURNED'' then ''معاد'' end as outcome',
'  from wf_instance i join wf_definition_version v on v.id = i.version_id join wf_definition d on d.id = v.definition_id',
'  left join ref_entity_type e on e.entity_type_code = i.object_type',
' where i.initiator_member_id = to_number(sys_context(''NOONA_CTX'', ''MEMBERSHIP_ID''))',
' order by i.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'طلباتي'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820264000000036)
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
,p_internal_uid=>91820264000000036
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000038)
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
 p_id=>wwv_flow_imp.id(91820264000000039)
,p_db_column_name=>'WORKFLOW_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المسار'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000040)
,p_db_column_name=>'OBJECT_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000041)
,p_db_column_name=>'OBJECT_ID'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'رقمه'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000042)
,p_db_column_name=>'STARTED_AT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'تاريخ الطلب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000043)
,p_db_column_name=>'CURRENT_STEP'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'عند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000044)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000045)
,p_db_column_name=>'OUTCOME'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'النتيجة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820264000000037)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'37'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'WORKFLOW_NAME:OBJECT_NAME:OBJECT_ID:STARTED_AT:CURRENT_STEP:STATUS_HTML:OUTCOME'
);

wwv_flow_imp.component_end;
end;
/
