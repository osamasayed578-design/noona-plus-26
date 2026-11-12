prompt --application/pages/page_00032
begin
--   Manifest
--     PAGE: 00032
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
 p_id=>32
,p_name=>'Commissions'
,p_alias=>'COMMISSIONS'
,p_step_title=>'عمولات المندوبين'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000371)
,p_plug_name=>'الحساب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">تحسب العمولة لكل مندوب حسب أساسه (نسبة من المبيعات الصافية أو من التحصيل أو مبلغ لكل زيارة منفذة) مع نسبة إنجاز الهدف. إعادة الحساب تحدث الشهر نفسه.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000372)
,p_name=>'P32_MONTH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000371)
,p_prompt=>'أي يوم من الشهر'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000373)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000371)
,p_button_name=>'CALC'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حساب العمولات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000374)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P32_MONTH is null then :P32_MONTH := to_char(sysdate, ''YYYY-MM-DD''); end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820300000000374
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000375)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Calc'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'  l := noona_dst_pkg.calc_commissions(to_date(:P32_MONTH, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000373)
,p_process_success_message=>'تم حساب العمولات'
,p_internal_uid=>91820300000000375
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000376)
,p_plug_name=>'العمولات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select c.id, to_char(c.period_start, ''YYYY-MM'') month, noona_dst_pkg.rep_label(c.rep_id) rep, noona_dst_pkg.label(c.basis) basis,',
'       c.base_amount, c.visits_count, c.target_amount, c.achievement_pct, c.commission_amount, noona_dst_pkg.badge(c.status_code) status_html',
'  from dst_commission c where c.company_id = noona_dst_pkg.company order by c.period_start desc, c.commission_amount desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'العمولات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820300000000377)
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
,p_internal_uid=>91820300000000377
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000379)
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
 p_id=>wwv_flow_imp.id(91820300000000380)
,p_db_column_name=>'MONTH'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الشهر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000381)
,p_db_column_name=>'REP'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المندوب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000382)
,p_db_column_name=>'BASIS'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الأساس'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000383)
,p_db_column_name=>'BASE_AMOUNT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المبلغ الأساس'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000384)
,p_db_column_name=>'VISITS_COUNT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الزيارات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000385)
,p_db_column_name=>'TARGET_AMOUNT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الهدف'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000386)
,p_db_column_name=>'ACHIEVEMENT_PCT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الإنجاز %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000387)
,p_db_column_name=>'COMMISSION_AMOUNT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'العمولة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000388)
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
 p_id=>wwv_flow_imp.id(91820300000000378)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'378'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'MONTH:REP:BASIS:BASE_AMOUNT:VISITS_COUNT:TARGET_AMOUNT:ACHIEVEMENT_PCT:COMMISSION_AMOUNT:STATUS_HTML'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000389)
,p_branch_action=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
