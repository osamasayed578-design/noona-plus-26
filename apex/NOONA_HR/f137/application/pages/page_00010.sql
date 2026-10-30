prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>137
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>'Employees'
,p_alias=>'EMPLOYEES'
,p_step_title=>'الموظفون'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000034)
,p_plug_name=>'الموظفون'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select m.id, e.employee_no, p.display_name_ar as name_ar, m.job_title, u.name_ar as unit_name,',
'       case when noona_hr_pkg.is_citizen(m.employee_category) = ''Y'' then noona_hr_pkg.category_label(m.employee_category) else nvl(c.name_ar, e.nationality) end as nationality,',
'       to_char(m.start_date, ''YYYY-MM-DD'') as hire_date, round(noona_hr_pkg.service_years(m.id), 1) as years,',
'       noona_pay_pkg.monthly_wage(m.id) as wage, noona_hr_pkg.leave_available(m.employee_id) as leave_bal,',
'       ''<span class="nn-badge '' || case m.status_code when ''ACTIVE'' then ''is-success'' when ''TERMINATED'' then ''is-danger'' else ''is-warning'' end',
'       || ''">'' || noona_hr_pkg.status_label(m.status_code) || ''</span>'' as status_html',
'  from hr_employment m join hr_employee e on e.id = m.employee_id join pty_party p on p.id = e.person_party_id',
'  left join org_unit u on u.id = m.org_unit_id left join ref_country c on c.country_code = e.nationality',
' where m.company_id = noona_hr_pkg.company and exists (select 1 from pay_employee_element x where x.employment_id = m.id)',
' order by e.employee_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الموظفون'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000035)
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
,p_internal_uid=>91820272000000035
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000037)
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
 p_id=>wwv_flow_imp.id(91820272000000038)
,p_db_column_name=>'EMPLOYEE_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم الوظيفي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000039)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الاسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000040)
,p_db_column_name=>'JOB_TITLE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المسمى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000041)
,p_db_column_name=>'UNIT_NAME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الإدارة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000042)
,p_db_column_name=>'NATIONALITY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الجنسية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000043)
,p_db_column_name=>'HIRE_DATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'التعيين'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000044)
,p_db_column_name=>'YEARS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الخدمة (سنة)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000045)
,p_db_column_name=>'WAGE'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الراتب الشهري'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000046)
,p_db_column_name=>'LEAVE_BAL'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'رصيد الإجازة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000047)
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
 p_id=>wwv_flow_imp.id(91820272000000036)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'36'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'EMPLOYEE_NO:NAME_AR:JOB_TITLE:UNIT_NAME:NATIONALITY:HIRE_DATE:YEARS:WAGE:LEAVE_BAL:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000048)
,p_plug_name=>'إجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000049)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000048)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'موظف جديد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11::'
);

wwv_flow_imp.component_end;
end;
/
