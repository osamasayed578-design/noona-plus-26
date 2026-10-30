prompt --application/pages/page_00040
begin
--   Manifest
--     PAGE: 00040
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
 p_id=>40
,p_name=>'Payroll Runs'
,p_alias=>'PAYROLL-RUNS'
,p_step_title=>'تشغيلات الرواتب'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000219)
,p_plug_name=>'تشغيل جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_pay_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000220)
,p_name=>'P40_PERIOD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000219)
,p_prompt=>'الفترة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.period_code || case when exists (select 1 from pay_run r where r.period_id = p.id and r.run_type = ''REGULAR'') then '' (له تشغيل)'' end d, p.id r from pay_period p where p.company_id = noona_pay_pkg.company and p.payroll_group_id = noona_pay_pkg.default_group order by p.start_date desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000222)
,p_validation_name=>'P40_PERIOD required (CREATE_RUN)'
,p_validation_sequence=>2
,p_validation=>'P40_PERIOD'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000221)
,p_associated_item=>wwv_flow_imp.id(91820272000000220)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000221)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000219)
,p_button_name=>'CREATE_RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء وحساب الرواتب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000223)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820272000000219)
,p_button_name=>'INPUTS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'المدخلات المتغيرة للفترة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000224)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Run'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    :P40_RUN := noona_pay_pkg.create_run(:P40_PERIOD);',
'    l_n := noona_pay_pkg.calculate(:P40_RUN);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000221)
,p_internal_uid=>91820272000000224
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000225)
,p_name=>'P40_RUN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000219)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000226)
,p_branch_action=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41:P41_ID:&P40_RUN.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820272000000221)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000227)
,p_plug_name=>'التشغيلات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, r.run_no, pp.period_code, case r.run_type when ''FINAL_SETTLEMENT'' then ''مخالصة نهاية خدمة'' else ''شهري'' end as run_type,',
'       r.employee_count, r.total_gross, r.total_deductions, r.total_net, r.total_employer_cost,',
'       ''<span class="nn-badge '' || case when r.status_code in (''PAID'', ''CLOSED'') then ''is-success'' when r.status_code in (''POSTED'', ''APPROVED'')',
'       then ''is-info'' else ''is-warning'' end || ''">'' || noona_pay_pkg.status_label(r.status_code) || ''</span>'' as status_html',
'  from pay_run r join pay_period pp on pp.id = r.period_id where r.company_id = noona_pay_pkg.company order by pp.start_date desc, r.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'التشغيلات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000228)
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
,p_detail_link=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41:P41_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820272000000228
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000230)
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
 p_id=>wwv_flow_imp.id(91820272000000231)
,p_db_column_name=>'RUN_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'التشغيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000232)
,p_db_column_name=>'PERIOD_CODE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الفترة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000233)
,p_db_column_name=>'RUN_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000234)
,p_db_column_name=>'EMPLOYEE_COUNT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الموظفون'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000235)
,p_db_column_name=>'TOTAL_GROSS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الإجمالي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000236)
,p_db_column_name=>'TOTAL_DEDUCTIONS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الخصومات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000237)
,p_db_column_name=>'TOTAL_NET'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الصافي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000238)
,p_db_column_name=>'TOTAL_EMPLOYER_COST'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'تكلفة المنشأة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000239)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000229)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'229'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'RUN_NO:PERIOD_CODE:RUN_TYPE:EMPLOYEE_COUNT:TOTAL_GROSS:TOTAL_DEDUCTIONS:TOTAL_NET:TOTAL_EMPLOYER_COST:STATUS_HTML'
);

wwv_flow_imp.component_end;
end;
/
