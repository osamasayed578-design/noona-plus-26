prompt --application/pages/page_00063
begin
--   Manifest
--     PAGE: 00063
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
 p_id=>63
,p_name=>'Depreciation'
,p_alias=>'DEPRECIATION'
,p_step_title=>'إهلاك الأصول'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000530)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000623)
,p_plug_name=>'تشغيل الإهلاك الشهري'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يحسب إهلاك كل الأصول في الخدمة حتى نهاية الفترة (مع لحاق الأشهر الفائتة) ويرحل قيداً واحداً: من ح/ مصروف الإهلاك (حسب مركز التكلفة) إلى ح/ مجمع الإهلاك. لا تشغل الفترة مرتين، ويعكس آخر تشغيل فقط.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_fa_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000624)
,p_name=>'P63_PERIOD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000623)
,p_prompt=>'الفترة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.period_code || case when exists (select 1 from fa_depreciation_run r where r.period_id = p.id and r.status_code = ''POSTED'') then '' (مهلكة)'' end d, p.id r from gl_period p join gl_fiscal_year y on y.id = p.fiscal_year_id where p.company_id = noona_fa_pkg.company and p.period_type = ''NORMAL'' and y.status_code = ''OPEN'' order by p.start_date'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000626)
,p_validation_name=>'P63_PERIOD required (RUN)'
,p_validation_sequence=>2
,p_validation=>'P63_PERIOD'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000625)
,p_associated_item=>wwv_flow_imp.id(91820266000000624)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000625)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000623)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'احتساب وترحيل الإهلاك'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000627)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P63_PERIOD := nvl(:P63_PERIOD, noona_fa_pkg.next_period);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000627
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000628)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Run'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P63_RUN := noona_fa_pkg.run_depreciation(:P63_PERIOD);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000625)
,p_process_success_message=>'تم احتساب الإهلاك وترحيل قيده'
,p_internal_uid=>91820266000000628
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000629)
,p_name=>'P63_RUN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000623)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000630)
,p_plug_name=>'معاينة إهلاك الفترة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P63_PERIOD is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_fa_pkg.preview_html(:P63_PERIOD);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000631)
,p_plug_name=>'تشغيلات الإهلاك'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, p.period_code, to_char(p.end_date, ''YYYY-MM-DD'') as end_d, r.total_amount,',
'       (select count(*) from fa_depreciation_line l where l.run_id = r.id) as assets, j.doc_no as journal_no,',
'       ''<span class="nn-badge '' || case r.status_code when ''POSTED'' then ''is-success'' else ''is-warning'' end || ''">''',
'       || noona_fa_pkg.status_label(r.status_code) || ''</span>'' as status_html, r.created_by',
'  from fa_depreciation_run r join gl_period p on p.id = r.period_id left join gl_journal j on j.id = r.journal_id',
' where r.company_id = noona_fa_pkg.company order by p.start_date desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'تشغيلات الإهلاك'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000632)
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
,p_detail_link=>'f?p=&APP_ID.:64:&SESSION.::&DEBUG.:RP,64:P64_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820266000000632
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000634)
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
 p_id=>wwv_flow_imp.id(91820266000000635)
,p_db_column_name=>'PERIOD_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الفترة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000636)
,p_db_column_name=>'END_D'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'نهاية الفترة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000637)
,p_db_column_name=>'TOTAL_AMOUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'إجمالي الإهلاك'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000638)
,p_db_column_name=>'ASSETS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الأصول'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000639)
,p_db_column_name=>'JOURNAL_NO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'القيد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000640)
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
 p_id=>wwv_flow_imp.id(91820266000000641)
,p_db_column_name=>'CREATED_BY'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'بواسطة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000633)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'633'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PERIOD_CODE:END_D:TOTAL_AMOUNT:ASSETS:JOURNAL_NO:STATUS_HTML:CREATED_BY'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000642)
,p_branch_action=>'f?p=&APP_ID.:64:&SESSION.::&DEBUG.:RP,64:P64_ID:&P63_RUN.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820266000000625)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000643)
,p_branch_action=>'f?p=&APP_ID.:63:&SESSION.::&DEBUG.::P63_PERIOD:&P63_PERIOD.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
