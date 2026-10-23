prompt --application/pages/page_00026
begin
--   Manifest
--     PAGE: 00026
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>26
,p_name=>'Night Audit'
,p_alias=>'NIGHT-AUDIT'
,p_step_title=>'التدقيق الليلي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000281)
,p_plug_name=>'إقفال يوم العمل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يسجل عدم الحضور للحجوزات التي لم تصل، ويرحل رسوم ليلة اليوم لكل نزيل مقيم (إيراد الإيواء وضريبة القيمة المضافة على حساب النزيل)، ويحسب الإشغال ومتوسط السعر، ويجعل الغرف المشغولة بحاجة لتنظيف يومي، ثم ينقل تاريخ العمل لليوم التالي.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000282)
,p_name=>'P26_PROPERTY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000281)
,p_prompt=>'الفندق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from re_property p where p.company_id = noona_hsp_pkg.company and p.status_code <> ''INACTIVE'' and exists (select 1 from hsp_room r where r.property_id = p.id) order by p.code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000283)
,p_name=>'P26_NOSHOW'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000281)
,p_prompt=>'تسجيل عدم الحضور آلياً'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000284)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000281)
,p_button_name=>'AUDIT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تشغيل التدقيق الليلي'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000285)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P26_PROPERTY := nvl(:P26_PROPERTY, noona_hsp_pkg.default_property);',
':P26_NOSHOW := nvl(:P26_NOSHOW, ''Y'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000285
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000286)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Audit'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_hsp_pkg.night_audit(:P26_PROPERTY, :P26_NOSHOW);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000284)
,p_process_success_message=>'تم التدقيق الليلي وترحيل رسوم الغرف ونقل تاريخ العمل'
,p_internal_uid=>91820273000000286
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000287)
,p_plug_name=>'الحالة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>8
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P26_PROPERTY is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_hsp_pkg.front_summary(:P26_PROPERTY);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000288)
,p_plug_name=>'سجل التدقيق'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select a.id, to_char(a.business_date, ''YYYY-MM-DD'') as bd, a.occupancy_pct, a.room_revenue, a.adr, a.no_shows,',
'       noona_hsp_pkg.res_status_label(a.status_code) as status, a.created_by, to_char(a.created_at, ''YYYY-MM-DD HH24:MI'') as at_time',
'  from hsp_night_audit a where a.property_id = :P26_PROPERTY order by a.business_date desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'سجل التدقيق'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000289)
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
,p_internal_uid=>91820273000000289
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000291)
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
 p_id=>wwv_flow_imp.id(91820273000000292)
,p_db_column_name=>'BD'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'يوم العمل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000293)
,p_db_column_name=>'OCCUPANCY_PCT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الإشغال %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000294)
,p_db_column_name=>'ROOM_REVENUE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'إيراد الغرف'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000295)
,p_db_column_name=>'ADR'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'متوسط السعر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000296)
,p_db_column_name=>'NO_SHOWS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'عدم الحضور'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000297)
,p_db_column_name=>'STATUS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000298)
,p_db_column_name=>'CREATED_BY'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'بواسطة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000299)
,p_db_column_name=>'AT_TIME'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000290)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'290'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'BD:OCCUPANCY_PCT:ROOM_REVENUE:ADR:NO_SHOWS:STATUS:CREATED_BY:AT_TIME'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000300)
,p_branch_action=>'f?p=&APP_ID.:26:&SESSION.::&DEBUG.::P26_PROPERTY:&P26_PROPERTY.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
