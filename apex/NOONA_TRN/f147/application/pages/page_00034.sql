prompt --application/pages/page_00034
begin
--   Manifest
--     PAGE: 00034
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>147
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>34
,p_name=>'Fleet Maintenance'
,p_alias=>'MAINTENANCE'
,p_step_title=>'صيانة الأسطول'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000284)
,p_plug_name=>'أمر صيانة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000285)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000284)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'فتح أمر صيانة لعربة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.:RP,35::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000286)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820290000000284)
,p_button_name=>'PLANS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'برامج الصيانة الدورية'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:36:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000287)
,p_plug_name=>'الصيانات الدورية المستحقة (بالكيلومتر أو الأيام)'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>8
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_trn_pkg.maint_due_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000288)
,p_plug_name=>'أوامر الصيانة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.id, o.doc_no, o.opened_at, v.plate_no, noona_trn_pkg.maint_type_label(o.maint_type) maint_type,',
'       noona_trn_pkg.maint_type_label(o.workshop) workshop, pt.display_name_ar vendor, o.description, o.odometer_km,',
'       o.parts_cost, o.labor_cost, o.total_cost, noona_trn_pkg.maint_type_label(o.treatment) treatment, o.life_extension_months,',
'       o.downtime_hours, o.completed_at, noona_trn_pkg.badge(o.status_code) status_html',
'  from trn_maint_order o join trn_vehicle v on v.id = o.vehicle_id left join pty_party pt on pt.id = o.vendor_party_id',
' where o.company_id = noona_trn_pkg.company order by o.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أوامر الصيانة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000289)
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
,p_detail_link=>'f?p=&APP_ID.:35:&SESSION.::&DEBUG.:RP,35:P35_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820290000000289
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000291)
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
 p_id=>wwv_flow_imp.id(91820290000000292)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الأمر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000293)
,p_db_column_name=>'OPENED_AT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الدخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000294)
,p_db_column_name=>'PLATE_NO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'العربة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000295)
,p_db_column_name=>'MAINT_TYPE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000296)
,p_db_column_name=>'WORKSHOP'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الورشة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000297)
,p_db_column_name=>'VENDOR'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المورد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000298)
,p_db_column_name=>'DESCRIPTION'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'العمل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000299)
,p_db_column_name=>'ODOMETER_KM'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'العداد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000300)
,p_db_column_name=>'PARTS_COST'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'القطع'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000301)
,p_db_column_name=>'LABOR_COST'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'العمالة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000302)
,p_db_column_name=>'TOTAL_COST'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الإجمالي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000303)
,p_db_column_name=>'TREATMENT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'المعالجة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000304)
,p_db_column_name=>'LIFE_EXTENSION_MONTHS'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'تمديد العمر (شهر)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000305)
,p_db_column_name=>'DOWNTIME_HOURS'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'التوقف (س)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000306)
,p_db_column_name=>'COMPLETED_AT'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الخروج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000307)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>170
,p_column_identifier=>'Q'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000290)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'290'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:OPENED_AT:PLATE_NO:MAINT_TYPE:WORKSHOP:VENDOR:DESCRIPTION:ODOMETER_KM:PARTS_COST:LABOR_COST:TOTAL_COST:TREATMENT:LIFE_EXTENSION_MONTHS:DOWNTIME_HOURS:COMPLETED_AT:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000308)
,p_plug_name=>'تكلفة الصيانة لكل عربة منذ بداية السنة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_trn_pkg.maint_cost_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
