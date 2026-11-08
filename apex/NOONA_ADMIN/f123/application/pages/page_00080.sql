prompt --application/pages/page_00080
begin
--   Manifest
--     PAGE: 00080
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>80
,p_name=>'AI Settings'
,p_alias=>'AI-SETTINGS'
,p_step_title=>'الذكاء الاصطناعي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000846)
,p_plug_name=>'الحالة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div class="nn-hint">مساعد نونا يجيب من بيانات النظام بصلاحيات كل مستخدم وشركته وفرعه، ولا ينفذ عمليات. المزود (Claude أو OCI) ومفتاحه يضبطهما مسؤول مساحة عمل APEX في خدمات الذكاء الاصطناعي؛ هنا تختار المؤسسة النموذج والحصة.</div>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000847)
,p_plug_name=>'الاستهلاك'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>6
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t.parse(noona_ai_pkg.settings_json);',
'begin',
'    return ''<div class="nn-ai-stat"><b>الحالة:</b> '' || case l.get_string(''available'') when ''Y'' then ''مفعل ويعمل'' else ''غير متاح'' end',
'        || '' &middot; <b>النموذج:</b> '' || apex_escape.html(nvl(l.get_string(''model''), ''—''))',
'        || '' &middot; <b>المزود:</b> '' || apex_escape.html(nvl(l.get_string(''provider''), ''—''))',
'        || '' &middot; <b>استهلاك هذا الشهر:</b> '' || to_char(l.get_number(''used''), ''FM999G999G999G990'')',
'        || case when l.get_number(''quota'') is not null then '' من '' || to_char(l.get_number(''quota''), ''FM999G999G999G990'') || '' رمز'' else '' رمز (بلا حد)'' end',
'        || ''</div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000848)
,p_plug_name=>'إعدادات المؤسسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000849)
,p_name=>'P80_ENABLED'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000848)
,p_prompt=>'تفعيل مساعد نونا لكل مستخدمي المؤسسة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000850)
,p_name=>'P80_MODEL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000848)
,p_prompt=>'نموذج المحادثة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar || '' — '' || m.name_ar d, m.id r from ai_model m join ai_provider p on p.id = m.provider_id where m.model_kind = ''CHAT'' and m.status_code = ''ACTIVE'' and p.status_code = ''ACTIVE'' order by p.name_ar, m.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000851)
,p_name=>'P80_QUOTA'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000848)
,p_prompt=>'الحصة الشهرية بالرموز (فارغ = بلا حد)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000852)
,p_name=>'P80_RET'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000848)
,p_prompt=>'الاحتفاظ بالمحادثات (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000853)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Settings'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t.parse(noona_ai_pkg.settings_json);',
'begin',
'    :P80_ENABLED := l.get_string(''enabled''); :P80_MODEL := l.get_number(''modelId'');',
'    :P80_QUOTA := l.get_number(''quota''); :P80_RET := nvl(l.get_number(''retentionDays''), 90);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000853
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000854)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000848)
,p_button_name=>'SAVE_AI'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000855)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save AI Settings'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    select json_object(''enabled'' value :P80_ENABLED, ''modelId'' value to_number(:P80_MODEL), ''quota'' value to_number(:P80_QUOTA),',
'                       ''retentionDays'' value to_number(:P80_RET)) into l from dual;',
'    noona_ai_pkg.save_settings(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000854)
,p_process_success_message=>'تم حفظ إعدادات الذكاء الاصطناعي'
,p_internal_uid=>91820262000000855
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000856)
,p_plug_name=>'الاستهلاك اليومي'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select u.usage_date, decode(u.feature_code, ''CHAT'', ''المحادثة'', ''SUMMARY'', ''الملخص التنفيذي'', u.feature_code) feature,',
'       m.name_ar model, u.request_count, u.input_tokens, u.output_tokens, u.input_tokens + u.output_tokens total_tokens, u.cost_amount',
'  from ai_usage u join ai_model m on m.id = u.model_id order by u.usage_date desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الاستهلاك اليومي'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000857)
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
,p_internal_uid=>91820262000000857
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000859)
,p_db_column_name=>'USAGE_DATE'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'اليوم'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000860)
,p_db_column_name=>'FEATURE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوظيفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000861)
,p_db_column_name=>'MODEL'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النموذج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000862)
,p_db_column_name=>'REQUEST_COUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الطلبات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000863)
,p_db_column_name=>'INPUT_TOKENS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'رموز الإدخال'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000864)
,p_db_column_name=>'OUTPUT_TOKENS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'رموز الإخراج'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000865)
,p_db_column_name=>'TOTAL_TOKENS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الإجمالي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000866)
,p_db_column_name=>'COST_AMOUNT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'التكلفة التقديرية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000858)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'858'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'USAGE_DATE:FEATURE:MODEL:REQUEST_COUNT:INPUT_TOKENS:OUTPUT_TOKENS:TOTAL_TOKENS:COST_AMOUNT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000867)
,p_branch_action=>'f?p=&APP_ID.:80:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
