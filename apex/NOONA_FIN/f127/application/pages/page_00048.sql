prompt --application/pages/page_00048
begin
--   Manifest
--     PAGE: 00048
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
 p_id=>48
,p_name=>'Exchange Rates'
,p_alias=>'EXCHANGE-RATES'
,p_step_title=>'أسعار الصرف'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000449)
,p_plug_name=>'أسعار صرف الشركة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, r.from_currency || '' - '' || c.name_ar as cur, r.to_currency, t.name_ar as rate_type,',
'       to_char(r.rate_date, ''YYYY-MM-DD'') as rate_date, r.rate, round(1 / r.rate, 6) as inverse_rate,',
'       noona_ui_pkg.status_badge(r.status_code) as status_html, r.reason, r.created_by, r.approved_by',
'  from ref_exchange_rate r join ref_rate_type t on t.id = r.rate_type_id left join ref_currency c on c.currency_code = r.from_currency',
' where r.company_id = noona_gl_pkg.company order by r.rate_date desc, r.from_currency'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أسعار صرف الشركة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000450)
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
,p_internal_uid=>91820266000000450
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000452)
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
 p_id=>wwv_flow_imp.id(91820266000000453)
,p_db_column_name=>'CUR'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'العملة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000454)
,p_db_column_name=>'TO_CURRENCY'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'مقابل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000455)
,p_db_column_name=>'RATE_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'نوع السعر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000456)
,p_db_column_name=>'RATE_DATE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'ساري من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000457)
,p_db_column_name=>'RATE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'السعر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000458)
,p_db_column_name=>'INVERSE_RATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'العكسي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000459)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000460)
,p_db_column_name=>'REASON'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'المصدر / الملاحظة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000461)
,p_db_column_name=>'CREATED_BY'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'أدخله'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000462)
,p_db_column_name=>'APPROVED_BY'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'اعتمده'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000451)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'451'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CUR:TO_CURRENCY:RATE_TYPE:RATE_DATE:RATE:INVERSE_RATE:STATUS_HTML:REASON:CREATED_BY:APPROVED_BY'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000463)
,p_plug_name=>'سعر جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">أسعار الصرف خاصة بالشركة الحالية ولا تظهر ولا تستخدم في غيرها. السعر = عدد وحدات العملة الوظيفية لوحدة واحدة من العملة الأجنبية، ويسري من تاريخه حتى يضاف سعر أحدث. السعر المحاسبي يستخدم آلياً في القيود والسندات بالعملات الأجنبية.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000464)
,p_name=>'P48_TYPE'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820266000000463)
,p_prompt=>'نوع السعر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from ref_rate_type where is_active = ''Y'' order by case code when ''ACCOUNTING'' then 0 else 1 end, name_ar'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000465)
,p_name=>'P48_CUR'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000463)
,p_prompt=>'العملة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select currency_code || '' - '' || name_ar d, currency_code r from ref_currency where is_active = ''Y'' and currency_code <> noona_gl_pkg.ledger_currency order by currency_code'
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
 p_id=>wwv_flow_imp.id(91820266000000466)
,p_name=>'P48_DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000463)
,p_prompt=>'ساري من تاريخ'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000467)
,p_name=>'P48_RATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000463)
,p_prompt=>'السعر'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000468)
,p_name=>'P48_REASON'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000463)
,p_prompt=>'المصدر (مثل: البنك المركزي)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000469)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000463)
,p_button_name=>'ADD_RATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة السعر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000470)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000463)
,p_button_name=>'SEED_RATES'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة أسعار الربط الافتراضية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000471)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P48_TYPE is null then :P48_TYPE := noona_gl_pkg.rate_type; end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000471
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000472)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Rate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number; l_status varchar2(30);',
'begin',
'    l_id := noona_refdata_pkg.add_rate(nvl(:P48_TYPE, noona_gl_pkg.rate_type), :P48_CUR, noona_gl_pkg.ledger_currency,',
'                                       to_date(:P48_DATE, ''YYYY-MM-DD''), :P48_RATE, :P48_REASON);',
'    select status_code into l_status from ref_exchange_rate where id = l_id;',
'    apex_application.g_print_success_message := case l_status',
'        when ''DRAFT'' then ''تم حفظ السعر بانتظار اعتماد مستخدم آخر'' else ''تمت إضافة السعر'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000469)
,p_internal_uid=>91820266000000472
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000473)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Seed Rates'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_gl_pkg.seed_rates;',
'    apex_application.g_print_success_message := case when l_n > 0 then ''أضيف '' || l_n || '' سعر ربط رسمي (راجعها)''',
'                                                     else ''لا توجد أسعار ناقصة (أو العملة الوظيفية ليست الريال)'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000470)
,p_internal_uid=>91820266000000473
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000474)
,p_plug_name=>'اعتماد الأسعار المعلقة (لا يعتمد المدخل سعره)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000475)
,p_name=>'P48_PENDING'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000474)
,p_prompt=>'سعر معلق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select to_char(r.rate_date, ''YYYY-MM-DD'') || '' · '' || r.from_currency || ''/'' || r.to_currency || '' = '' || r.rate || '' · '' || r.created_by d, r.id r from ref_exchange_rate r where r.status_code = ''DRAFT'' and r.company_id = noona_gl_pkg.company order by r.rate_date desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000476)
,p_name=>'P48_REJECT_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000474)
,p_prompt=>'سبب الرفض'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000477)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000474)
,p_button_name=>'APPROVE_RATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000478)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000474)
,p_button_name=>'REJECT_RATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000479)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve Rate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_refdata_pkg.approve_rate(:P48_PENDING);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000477)
,p_process_success_message=>'تم اعتماد السعر'
,p_internal_uid=>91820266000000479
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000480)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject Rate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_refdata_pkg.reject_rate(:P48_PENDING, :P48_REJECT_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000478)
,p_process_success_message=>'تم رفض السعر'
,p_internal_uid=>91820266000000480
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000481)
,p_branch_action=>'f?p=&APP_ID.:48:&SESSION.::&DEBUG.:48::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
