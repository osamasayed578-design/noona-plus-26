prompt --application/pages/page_00044
begin
--   Manifest
--     PAGE: 00044
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
 p_id=>44
,p_name=>'Delegation'
,p_alias=>'DELEGATION'
,p_step_title=>'التفويض'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000507)
,p_plug_name=>'ملخص التفويض'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_ui_pkg.delegation_header(:P44_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000508)
,p_plug_name=>'إجراءات التفويض'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000509)
,p_name=>'P44_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000510)
,p_name=>'P44_STATUS_CODE'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000511)
,p_name=>'P44_CAN_DECIDE'
,p_item_sequence=>3
,p_item_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000512)
,p_name=>'P44_REASON'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_prompt=>'السبب أو الملاحظة (إلزامي للرفض والإلغاء والإيقاف)'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000513)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_button_name=>'SUBMIT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال للاعتماد'
,p_button_position=>'NEXT'
,p_button_condition=>':P44_STATUS_CODE = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000514)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_button_name=>'APPROVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد'
,p_button_position=>'NEXT'
,p_button_condition=>':P44_STATUS_CODE = ''SUBMITTED'' and :P44_CAN_DECIDE = ''Y'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000515)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_button_name=>'REJECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض'
,p_button_position=>'NEXT'
,p_button_condition=>':P44_STATUS_CODE = ''SUBMITTED'' and :P44_CAN_DECIDE = ''Y'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000516)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_button_name=>'SUSPEND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إيقاف مؤقت'
,p_button_position=>'NEXT'
,p_button_condition=>':P44_STATUS_CODE = ''ACTIVE'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000517)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_button_name=>'REVOKE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء التفويض'
,p_button_position=>'NEXT'
,p_button_condition=>':P44_STATUS_CODE in (''APPROVED'', ''SCHEDULED'', ''ACTIVE'', ''SUSPENDED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000518)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820262000000508)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:43:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000519)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Delegation'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- المانح والمفوض إليه لا يعتمدان التفويض (NOONA-DLG-041): تخفى أزرار القرار عنهما',
'select status_code, case when sys_context(''NOONA_CTX'', ''MEMBERSHIP_ID'') in (grantor_member_id, delegate_member_id)',
'                         then ''N'' else ''Y'' end',
'  into :P44_STATUS_CODE, :P44_CAN_DECIDE from dlg_delegation where id = :P44_ID;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000519
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000520)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delegation Action 10'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_delegation_pkg.submit(:P44_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000513)
,p_process_success_message=>'تم إرسال التفويض للاعتماد'
,p_internal_uid=>91820262000000520
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000521)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delegation Action 20'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_delegation_pkg.approve(:P44_ID, :P44_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000514)
,p_process_success_message=>'تم اعتماد التفويض'
,p_internal_uid=>91820262000000521
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000522)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delegation Action 30'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_delegation_pkg.reject(:P44_ID, :P44_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000515)
,p_process_success_message=>'تم رفض التفويض'
,p_internal_uid=>91820262000000522
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000523)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delegation Action 40'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_delegation_pkg.suspend(:P44_ID, :P44_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000516)
,p_process_success_message=>'تم إيقاف التفويض مؤقتاً'
,p_internal_uid=>91820262000000523
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000524)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delegation Action 50'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_delegation_pkg.revoke_delegation(:P44_ID, :P44_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000517)
,p_process_success_message=>'تم إلغاء التفويض'
,p_internal_uid=>91820262000000524
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000525)
,p_plug_name=>'نطاق التفويض'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, noona_ui_pkg.code_label(s.dimension_code) as dimension,',
'       coalesce(s.value_code, (select nvl(c.trade_name_ar, c.legal_name_ar) from org_company c',
'                                where s.dimension_code = ''COMPANY'' and c.id = s.value_id),',
'                (select b.name_ar from org_branch b where s.dimension_code = ''BRANCH'' and b.id = s.value_id),',
'                (select o.name_ar from org_unit o where s.dimension_code = ''ORG_UNIT'' and o.id = s.value_id),',
'                to_char(s.value_id)) as scope_value',
'  from dlg_scope s where s.delegation_id = :P44_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'نطاق التفويض'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000526)
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
,p_internal_uid=>91820262000000526
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000528)
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
 p_id=>wwv_flow_imp.id(91820262000000529)
,p_db_column_name=>'DIMENSION'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'البعد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000530)
,p_db_column_name=>'SCOPE_VALUE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'القيمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000527)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'527'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DIMENSION:SCOPE_VALUE'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000531)
,p_plug_name=>'تحديد النطاق والحدود (للمسودة)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P44_STATUS_CODE = ''DRAFT'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000532)
,p_name=>'P44_DIM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000531)
,p_prompt=>'البعد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:شركة;COMPANY,فرع;BRANCH,وحدة تنظيمية;ORG_UNIT,وحدة النظام;MODULE,مسار اعتماد;WORKFLOW,إجراء;ACTION'
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
 p_id=>wwv_flow_imp.id(91820262000000533)
,p_name=>'P44_VAL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000531)
,p_prompt=>'القيمة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d, r from (select nvl(trade_name_ar, legal_name_ar) d, ''ID:'' || id r, ''COMPANY'' k from org_company union all select name_ar, ''ID:'' || id, ''BRANCH'' from org_branch where status_code = ''ACTIVE'' union all select name_ar, ''ID:'' || id, ''ORG_UNIT'' from org_unit union all select module_code || '' - '' || name_ar, ''CODE:'' || module_code, ''MODULE'' from plt_module union all select name_ar, ''CODE:'' || code, ''WORKFLOW'' from wf_definition union all select noona_ui_pkg.action_label(column_value), ''CODE:'' || column_value, ''ACTION'' from table(sys.odcivarchar2list(''APPROVE'',''REJECT'',''SUBMIT'',''POST'',''SIGN'',''VIEW'')) ) where k = :P44_DIM order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P44_DIM'
,p_ajax_items_to_submit=>'P44_DIM'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000534)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000531)
,p_button_name=>'ADD_SCOPE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة للنطاق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000535)
,p_name=>'P44_CURRENCY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000531)
,p_prompt=>'عملة الحد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_CURRENCIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000006)||'.'
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
 p_id=>wwv_flow_imp.id(91820262000000536)
,p_name=>'P44_MAX_TXN'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000531)
,p_prompt=>'الحد الأقصى للمعاملة'
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
 p_id=>wwv_flow_imp.id(91820262000000537)
,p_name=>'P44_MAX_CUM'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000531)
,p_prompt=>'الحد التراكمي'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000538)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000531)
,p_button_name=>'SET_LIMIT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ الحد المالي'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000539)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Scope'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_delegation_pkg.add_scope(p_delegation_id => :P44_ID, p_dimension => :P44_DIM,',
'    p_value_id => case when :P44_VAL like ''ID:%'' then to_number(substr(:P44_VAL, 4)) end,',
'    p_value_code => case when :P44_VAL like ''CODE:%'' then substr(:P44_VAL, 6) end);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000534)
,p_process_success_message=>'تمت إضافة النطاق'
,p_internal_uid=>91820262000000539
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000540)
,p_process_sequence=>70
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Set Limit'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_delegation_pkg.set_limit(:P44_ID, :P44_CURRENCY, :P44_MAX_TXN, :P44_MAX_CUM);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000538)
,p_process_success_message=>'تم حفظ الحد المالي'
,p_internal_uid=>91820262000000540
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000541)
,p_plug_name=>'سجل الاستخدام'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select e.id, e.created_at, noona_ui_pkg.action_label(e.action_code) as action_name, e.entity_type, e.entity_id,',
'       e.amount, e.currency_code, e.result_code,',
'       (select u.display_name from sec_user_membership m join sec_user u on u.id = m.user_id where m.id = e.actor_member_id) as actor',
'  from dlg_exercise_event e where e.delegation_id = :P44_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'سجل الاستخدام'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000542)
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
,p_internal_uid=>91820262000000542
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000544)
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
 p_id=>wwv_flow_imp.id(91820262000000545)
,p_db_column_name=>'CREATED_AT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوقت'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000546)
,p_db_column_name=>'ACTION_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الإجراء'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000547)
,p_db_column_name=>'ENTITY_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000548)
,p_db_column_name=>'ENTITY_ID'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'رقمه'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000549)
,p_db_column_name=>'AMOUNT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000550)
,p_db_column_name=>'CURRENCY_CODE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'العملة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000551)
,p_db_column_name=>'RESULT_CODE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'النتيجة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000552)
,p_db_column_name=>'ACTOR'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'المنفذ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000543)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'543'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CREATED_AT:ACTION_NAME:ENTITY_TYPE:ENTITY_ID:AMOUNT:CURRENCY_CODE:RESULT_CODE:ACTOR'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000553)
,p_branch_action=>'f?p=&APP_ID.:44:&SESSION.::&DEBUG.:44:P44_ID:&P44_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
