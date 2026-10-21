prompt --application/pages/page_00012
begin
--   Manifest
--     PAGE: 00012
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
 p_id=>12
,p_name=>'Cost Centers'
,p_alias=>'COST-CENTERS'
,p_step_title=>'مراكز التكلفة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000143)
,p_plug_name=>'مراكز التكلفة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select c.id, c.code, c.name_ar, decode(c.center_type, ''COST'', ''تكلفة'', ''PROFIT'', ''ربحية'', ''REVENUE'', ''إيراد'',',
'       ''INVESTMENT'', ''استثمار'', c.center_type) as cc_type, p.code || '' '' || p.name_ar as parent_name,',
'       noona_ui_pkg.status_badge(c.status_code) as status_html',
'  from gl_cost_center c left join gl_cost_center p on p.id = c.parent_center_id',
' where c.company_id = noona_gl_pkg.company order by c.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مراكز التكلفة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000144)
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
,p_internal_uid=>91820266000000144
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000146)
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
 p_id=>wwv_flow_imp.id(91820266000000147)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000148)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'مركز التكلفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000149)
,p_db_column_name=>'CC_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000150)
,p_db_column_name=>'PARENT_NAME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'يتبع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000151)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000145)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'145'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:CC_TYPE:PARENT_NAME:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000152)
,p_plug_name=>'مركز تكلفة جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000153)
,p_name=>'P12_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000152)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000154)
,p_name=>'P12_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000152)
,p_prompt=>'الاسم'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000155)
,p_name=>'P12_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000152)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تكلفة;COST,ربحية;PROFIT,إيراد;REVENUE,استثمار;INVESTMENT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000156)
,p_name=>'P12_PARENT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000152)
,p_prompt=>'يتبع المركز'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, code r from gl_cost_center where company_id = noona_gl_pkg.company order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- رئيسي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000157)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000152)
,p_button_name=>'ADD_CC'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة المركز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000158)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000152)
,p_button_name=>'SEED_CC'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة المراكز الافتراضية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000159)
,p_process_sequence=>5
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Seed Cost Centers'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_gl_pkg.seed_cost_centers;',
'    apex_application.g_print_success_message := case when l_n > 0 then ''أضيفت '' || l_n || '' مراكز تكلفة وربحية افتراضية''',
'                                                     else ''توجد مراكز للشركة؛ لم يضف شيء'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000158)
,p_internal_uid=>91820266000000159
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000160)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Cost Center'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_gl_pkg.create_cost_center(:P12_CODE, :P12_NAME, :P12_TYPE, :P12_PARENT);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000157)
,p_process_success_message=>'تمت إضافة مركز التكلفة'
,p_internal_uid=>91820266000000160
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000161)
,p_plug_name=>'إيقاف أو تفعيل مركز'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000162)
,p_name=>'P12_CC'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000161)
,p_prompt=>'المركز'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from gl_cost_center where company_id = noona_gl_pkg.company order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000163)
,p_name=>'P12_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000161)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:موقوف;BLOCKED,مغلق;CLOSED,نشط;ACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000164)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000161)
,p_button_name=>'SET_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تطبيق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000165)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'CC Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_gl_pkg.set_cost_center_status(:P12_CC, :P12_STATUS);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000164)
,p_process_success_message=>'تم تغيير حالة المركز'
,p_internal_uid=>91820266000000165
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000166)
,p_plug_name=>'قاعدة مركز التكلفة للحساب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000167)
,p_name=>'P12_ACCOUNT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000166)
,p_prompt=>'الحساب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.id r from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger and a.is_postable = ''Y'' order by a.account_code'
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
 p_id=>wwv_flow_imp.id(91820266000000168)
,p_name=>'P12_RULE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000166)
,p_prompt=>'القاعدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إلزامي في كل قيد;REQUIRED,اختياري;OPTIONAL,ممنوع;FORBIDDEN'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000169)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000166)
,p_button_name=>'SET_RULE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ القاعدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000170)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'CC Rule'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_gl_pkg.set_cc_rule(:P12_ACCOUNT, :P12_RULE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000169)
,p_process_success_message=>'تم حفظ قاعدة مركز التكلفة للحساب'
,p_internal_uid=>91820266000000170
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000171)
,p_plug_name=>'حسابات لها قاعدة مركز تكلفة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select a.id, a.account_code, a.name_ar, decode(r.rule_code, ''REQUIRED'', ''إلزامي'', ''FORBIDDEN'', ''ممنوع'', ''اختياري'') as rule_name',
'  from gl_account_dim_rule r join gl_dimension d on d.id = r.dimension_id and d.code = ''COST_CENTER''',
'  join gl_account a on a.id = r.account_id',
' where a.coa_id = noona_gl_pkg.primary_coa and r.rule_code <> ''OPTIONAL'' order by a.account_code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'حسابات لها قاعدة مركز تكلفة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000172)
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
,p_internal_uid=>91820266000000172
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000174)
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
 p_id=>wwv_flow_imp.id(91820266000000175)
,p_db_column_name=>'ACCOUNT_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000176)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الحساب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000177)
,p_db_column_name=>'RULE_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'القاعدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000173)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'173'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ACCOUNT_CODE:NAME_AR:RULE_NAME'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000178)
,p_branch_action=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.:12::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
