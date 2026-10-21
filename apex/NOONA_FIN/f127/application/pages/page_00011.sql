prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Periods'
,p_alias=>'PERIODS'
,p_step_title=>'الفترات المحاسبية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000061)
,p_plug_name=>'الفترات المحاسبية'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select p.id, y.name_ar as fiscal_year, p.period_no, p.name_ar, to_char(p.start_date, ''YYYY-MM-DD'') as start_date,',
'       to_char(p.end_date, ''YYYY-MM-DD'') as end_date,',
'       decode(s.status_code, ''OPEN'', ''<span class="nn-badge is-success">مفتوحة</span>'',',
'              ''SOFT_CLOSED'', ''<span class="nn-badge is-warning">مقفلة مبدئياً</span>'',',
'              ''HARD_CLOSED'', ''<span class="nn-badge is-danger">مقفلة نهائياً</span>'', ''<span class="nn-badge is-muted">غير مهيأة</span>'') as status_html,',
'       s.closed_by, s.closed_at',
'  from gl_period p join gl_fiscal_year y on y.id = p.fiscal_year_id',
'  left join gl_period_status s on s.period_id = p.id and s.ledger_id = noona_gl_pkg.primary_ledger and s.module_code = ''GL''',
' where p.company_id = noona_gl_pkg.company order by p.start_date'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الفترات المحاسبية'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000062)
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
,p_internal_uid=>91820266000000062
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000064)
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
 p_id=>wwv_flow_imp.id(91820266000000065)
,p_db_column_name=>'FISCAL_YEAR'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'السنة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000066)
,p_db_column_name=>'PERIOD_NO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'رقم'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000067)
,p_db_column_name=>'NAME_AR'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الفترة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000068)
,p_db_column_name=>'START_DATE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000069)
,p_db_column_name=>'END_DATE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000070)
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
 p_id=>wwv_flow_imp.id(91820266000000071)
,p_db_column_name=>'CLOSED_BY'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'أقفلها'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000072)
,p_db_column_name=>'CLOSED_AT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'وقت الإقفال'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000063)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'63'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'FISCAL_YEAR:PERIOD_NO:NAME_AR:START_DATE:END_DATE:STATUS_HTML:CLOSED_BY:CLOSED_AT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000073)
,p_plug_name=>'تغيير حالة فترة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000074)
,p_name=>'P11_PERIOD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000073)
,p_prompt=>'الفترة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from gl_period p where p.company_id = noona_gl_pkg.company order by p.start_date'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000075)
,p_name=>'P11_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000073)
,p_prompt=>'الحالة الجديدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مفتوحة;OPEN,مقفلة مبدئياً (تمنع الترحيل);SOFT_CLOSED,مقفلة نهائياً;HARD_CLOSED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000077)
,p_validation_name=>'P11_PERIOD required (APPLY)'
,p_validation_sequence=>14
,p_validation=>'P11_PERIOD'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000076)
,p_associated_item=>wwv_flow_imp.id(91820266000000074)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000076)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000073)
,p_button_name=>'APPLY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تطبيق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000078)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Period Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_gl_pkg.set_period_status(:P11_PERIOD, :P11_STATUS);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000076)
,p_process_success_message=>'تم تغيير حالة الفترة'
,p_internal_uid=>91820266000000078
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000079)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
