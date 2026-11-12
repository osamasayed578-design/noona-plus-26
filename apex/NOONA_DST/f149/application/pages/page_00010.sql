prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
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
 p_id=>10
,p_name=>'Reps'
,p_alias=>'REPS'
,p_step_title=>'المندوبون'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000123)
,p_plug_name=>'مندوب جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000124)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000123)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مندوب جديد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000125)
,p_plug_name=>'المندوبون'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, r.code, r.full_name, r.user_name, r.phone, r.vehicle_plate, w.name_ar van_wh, b.name_ar cash_box,',
'       nvl(noona_wrk_pkg.employee_name(r.employee_id), ''— غير مربوط —'') emp, noona_wrk_pkg.method_label(r.earnings_method) paym,',
'       noona_dst_pkg.label(r.commission_basis) basis, r.commission_rate, r.commission_per_visit, r.monthly_target,',
'       (select count(*) from dst_route x where x.rep_id = r.id and x.status_code = ''ACTIVE'') routes,',
'       noona_dst_pkg.badge(r.status_code) status_html',
'  from dst_rep r join inv_warehouse w on w.id = r.van_warehouse_id join csh_cash_box b on b.id = r.cash_box_id',
' where r.company_id = noona_dst_pkg.company order by r.full_name'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'المندوبون'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820300000000126)
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
,p_internal_uid=>91820300000000126
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000128)
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
 p_id=>wwv_flow_imp.id(91820300000000129)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000130)
,p_db_column_name=>'FULL_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الاسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000131)
,p_db_column_name=>'EMP'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الموظف (الموارد البشرية)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000132)
,p_db_column_name=>'PAYM'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'صرف العمولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000133)
,p_db_column_name=>'USER_NAME'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المستخدم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000134)
,p_db_column_name=>'PHONE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الجوال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000135)
,p_db_column_name=>'VEHICLE_PLATE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'اللوحة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000136)
,p_db_column_name=>'VAN_WH'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'مستودع السيارة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000137)
,p_db_column_name=>'CASH_BOX'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'العهدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000138)
,p_db_column_name=>'BASIS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'أساس العمولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000139)
,p_db_column_name=>'COMMISSION_RATE'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'النسبة %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000140)
,p_db_column_name=>'COMMISSION_PER_VISIT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'للزيارة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000141)
,p_db_column_name=>'MONTHLY_TARGET'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'الهدف الشهري'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000142)
,p_db_column_name=>'ROUTES'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'الخطوط'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000143)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820300000000127)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'127'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:FULL_NAME:EMP:PAYM:USER_NAME:PHONE:VEHICLE_PLATE:VAN_WH:CASH_BOX:BASIS:COMMISSION_RATE:COMMISSION_PER_VISIT:MONTHLY_TARGET:ROUTES:STATUS_HTML'
);

wwv_flow_imp.component_end;
end;
/
