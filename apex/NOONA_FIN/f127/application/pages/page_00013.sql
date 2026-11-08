prompt --application/pages/page_00013
begin
--   Manifest
--     PAGE: 00013
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
 p_id=>13
,p_name=>'Year End'
,p_alias=>'YEAR-END'
,p_step_title=>'إقفال السنة المالية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000433)
,p_plug_name=>'السنوات المالية'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select y.id, y.code, y.name_ar, to_char(y.start_date, ''YYYY-MM-DD'') as start_date, to_char(y.end_date, ''YYYY-MM-DD'') as end_date,',
'       noona_ui_pkg.status_badge(y.status_code) as status_html,',
'       (select max(j.doc_no) from gl_journal j where j.ledger_id = noona_gl_pkg.primary_ledger and j.journal_category = ''CLOSING''',
'           and j.status_code = ''POSTED'' and j.reversal_of_id is null and j.doc_date = y.end_date) as closing_jv',
'  from gl_fiscal_year y where y.company_id = noona_gl_pkg.company order by y.start_date'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'السنوات المالية'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000434)
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
,p_internal_uid=>91820266000000434
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000436)
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
 p_id=>wwv_flow_imp.id(91820266000000437)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000438)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'السنة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000439)
,p_db_column_name=>'START_DATE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000440)
,p_db_column_name=>'END_DATE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000441)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000442)
,p_db_column_name=>'CLOSING_JV'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'قيد الإقفال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000435)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'435'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:START_DATE:END_DATE:STATUS_HTML:CLOSING_JV'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000443)
,p_plug_name=>'الإقفال'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الإقفال ينشئ قيداً آلياً بتاريخ نهاية السنة يصفّر الإيرادات والمصروفات (لكل مركز تكلفة) ويرحل صافي الربح أو الخسارة إلى حساب الأرباح المبقاة، ثم يقفل كل فترات السنة. يشترط ألا توجد قيود أو سندات غير مرحلة في السنة، وأن تقفل السنوات السابقة أولاً. إعادة الفتح لمسؤول المؤسسة فقط وتعكس قيد الإقفال.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000444)
,p_name=>'P13_YEAR'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000443)
,p_prompt=>'السنة المالية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || to_char(start_date, ''YYYY-MM-DD'') || '' - '' || to_char(end_date, ''YYYY-MM-DD'') || '')'' d, id r from gl_fiscal_year where company_id = noona_gl_pkg.company order by start_date'
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
 p_id=>wwv_flow_imp.id(91820266000000445)
,p_name=>'P13_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000443)
,p_prompt=>'سبب إعادة الفتح'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000447)
,p_validation_name=>'P13_YEAR required (CLOSE_YEAR)'
,p_validation_sequence=>12
,p_validation=>'P13_YEAR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000446)
,p_associated_item=>wwv_flow_imp.id(91820266000000444)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000446)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000443)
,p_button_name=>'CLOSE_YEAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إقفال السنة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000449)
,p_validation_name=>'P13_YEAR required (REOPEN_YEAR)'
,p_validation_sequence=>14
,p_validation=>'P13_YEAR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000448)
,p_associated_item=>wwv_flow_imp.id(91820266000000444)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000448)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000443)
,p_button_name=>'REOPEN_YEAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إعادة فتح السنة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000450)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close Year'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_gl_pkg.close_year(:P13_YEAR);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000446)
,p_process_success_message=>'تم إقفال السنة وترحيل النتيجة إلى الأرباح المبقاة'
,p_internal_uid=>91820266000000450
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000451)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reopen Year'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_gl_pkg.reopen_year(:P13_YEAR, :P13_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000448)
,p_process_success_message=>'تمت إعادة فتح السنة وعكس قيد الإقفال'
,p_internal_uid=>91820266000000451
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000452)
,p_branch_action=>'f?p=&APP_ID.:13:&SESSION.::&DEBUG.:13::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
