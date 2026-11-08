prompt --application/pages/page_00023
begin
--   Manifest
--     PAGE: 00023
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
 p_id=>23
,p_name=>'Assignments'
,p_alias=>'ASSIGNMENTS'
,p_step_title=>'تعيين الموظفين على المناصب'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000249)
,p_plug_name=>'التعيينات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select a.id, pt.display_name_ar as employee_name, e.employee_no, p.name_ar as position_name, u.name_ar as unit_name,',
'       noona_ui_pkg.code_label(a.assignment_type) as assignment_type, a.fte_pct, a.effective_from, a.effective_to, noona_ui_pkg.status_badge(a.status_code) as status_html',
'  from org_position_assignment a join hr_employment em on em.id = a.employment_id',
'  join hr_employee e on e.id = em.employee_id join pty_party pt on pt.id = e.person_party_id',
'  join org_position p on p.id = a.position_id join org_unit u on u.id = p.org_unit_id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'التعيينات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000250)
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
,p_internal_uid=>91820262000000250
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000252)
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
 p_id=>wwv_flow_imp.id(91820262000000253)
,p_db_column_name=>'EMPLOYEE_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الموظف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000254)
,p_db_column_name=>'EMPLOYEE_NO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الرقم الوظيفي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000255)
,p_db_column_name=>'POSITION_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المنصب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000256)
,p_db_column_name=>'UNIT_NAME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الوحدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000257)
,p_db_column_name=>'ASSIGNMENT_TYPE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'نوع التعيين'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000258)
,p_db_column_name=>'FTE_PCT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'النسبة %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000259)
,p_db_column_name=>'EFFECTIVE_FROM'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'من'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000260)
,p_db_column_name=>'EFFECTIVE_TO'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'إلى'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000261)
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
 p_id=>wwv_flow_imp.id(91820262000000251)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'251'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'EMPLOYEE_NAME:EMPLOYEE_NO:POSITION_NAME:UNIT_NAME:ASSIGNMENT_TYPE:FTE_PCT:EFFECTIVE_FROM:EFFECTIVE_TO:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000262)
,p_plug_name=>'تعيين جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000263)
,p_name=>'P23_EMPLOYMENT_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000262)
,p_prompt=>'الموظف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select pt.display_name_ar || '' ('' || e.employee_no || '')'' d, em.id r from hr_employment em join hr_employee e on e.id = em.employee_id join pty_party pt on pt.id = e.person_party_id where em.status_code in (''PENDING'',''ACTIVE'') order by 1'
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
 p_id=>wwv_flow_imp.id(91820262000000264)
,p_name=>'P23_POSITION_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000262)
,p_prompt=>'المنصب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '') - '' || noona_ui_pkg.status_label(status_code) d, id r from org_position where status_code not in (''CANCELLED'',''CLOSED'',''FROZEN'',''PLANNED'') order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000265)
,p_name=>'P23_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000262)
,p_prompt=>'نوع التعيين'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:أساسي;PRIMARY,إضافي;ADDITIONAL,بالإنابة;ACTING,إعارة;SECONDMENT,مؤقت;TEMPORARY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000266)
,p_name=>'P23_FROM'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000262)
,p_prompt=>'من تاريخ'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
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
 p_id=>wwv_flow_imp.id(91820262000000267)
,p_name=>'P23_FTE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000262)
,p_prompt=>'نسبة التفرغ %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000269)
,p_validation_name=>'P23_EMPLOYMENT_ID required (ASSIGN)'
,p_validation_sequence=>18
,p_validation=>'P23_EMPLOYMENT_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000268)
,p_associated_item=>wwv_flow_imp.id(91820262000000263)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000270)
,p_validation_name=>'P23_POSITION_ID required (ASSIGN)'
,p_validation_sequence=>19
,p_validation=>'P23_POSITION_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000268)
,p_associated_item=>wwv_flow_imp.id(91820262000000264)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000271)
,p_validation_name=>'P23_FROM required (ASSIGN)'
,p_validation_sequence=>20
,p_validation=>'P23_FROM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000268)
,p_associated_item=>wwv_flow_imp.id(91820262000000266)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000268)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000262)
,p_button_name=>'ASSIGN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تعيين'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000272)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P23_FROM := nvl(:P23_FROM, to_char(sysdate, ''YYYY-MM-DD'')); :P23_FTE := nvl(:P23_FTE, 100);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000272
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000273)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Assign'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_org_pkg.assign_position(p_employment_id => :P23_EMPLOYMENT_ID, p_position_id => :P23_POSITION_ID,',
'        p_assignment_type => :P23_TYPE, p_from => to_date(:P23_FROM, ''YYYY-MM-DD''), p_fte_pct => nvl(:P23_FTE, 100));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000268)
,p_process_success_message=>'تم التعيين'
,p_internal_uid=>91820262000000273
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000274)
,p_plug_name=>'إنهاء تعيين'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000275)
,p_name=>'P23_END_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000274)
,p_prompt=>'التعيين'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select pt.display_name_ar || '' - '' || p.name_ar d, a.id r from org_position_assignment a join hr_employment em on em.id = a.employment_id join hr_employee e on e.id = em.employee_id join pty_party pt on pt.id = e.person_party_id join org_position p on p.id = a.position_id where a.status_code in (''EFFECTIVE'',''SCHEDULED'') order by 1'
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
 p_id=>wwv_flow_imp.id(91820262000000276)
,p_name=>'P23_END_DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000274)
,p_prompt=>'تاريخ الانتهاء'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
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
 p_id=>wwv_flow_imp.id(91820262000000277)
,p_name=>'P23_END_REASON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000274)
,p_prompt=>'السبب'
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
 p_id=>wwv_flow_imp.id(91820262000000278)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000274)
,p_button_name=>'END_ASSIGNMENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إنهاء التعيين'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000279)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'End Assignment'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_org_pkg.end_assignment(p_assignment_id => :P23_END_ID, p_end_date => to_date(:P23_END_DATE, ''YYYY-MM-DD''), p_reason => :P23_END_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000278)
,p_process_success_message=>'تم إنهاء التعيين'
,p_internal_uid=>91820262000000279
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000280)
,p_branch_action=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
