prompt --application/pages/page_00080
begin
--   Manifest
--     PAGE: 00080
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
 p_id=>80
,p_name=>'Field Earnings'
,p_alias=>'FIELD-EARNINGS'
,p_step_title=>'مستحقات العاملين الميدانيين'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000332)
,p_plug_name=>'الشهر'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">العاملون في النقل والتوزيع ومراكز السيارات موظفون في الموارد البشرية ويختارون في شاشاتهم. يجمع النظام مستحقاتهم الشهرية: بدل الرحلات المقفلة، عمولات المندوبين (مبيعات أو تحصيل أو زيارات)، عمولات الفنيين من الخدمات المنجزة، والمكافآت اليدوية. بعد الاعتماد تصرف حسب طريقة كل عامل: <b>مع الراتب</b> (تضاف لمسير الشهر كمدخل متغير) أو <b>نقداً / تحويلاً</b> (سند مصروفات يعتمده المالي).</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000333)
,p_name=>'P80_MONTH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000332)
,p_prompt=>'الشهر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select to_char(add_months(trunc(sysdate, ''MM''), -level + 1), ''YYYY-MM'') d, to_char(add_months(trunc(sysdate, ''MM''), -level + 1), ''YYYY-MM'') r from dual connect by level <= 12'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000334)
,p_name=>'P80_PLACE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000332)
,p_prompt=>'الصندوق أو البنك للصرف النقدي والتحويل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' (صندوق)'' d, ''BOX:'' || id r from csh_cash_box where company_id = noona_hr_pkg.company and status_code = ''ACTIVE'' union all select name_ar || '' (بنك)'', ''BANK:'' || id from csh_bank_account where company_id = noona_hr_pkg.company and status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- تلقائي: الصندوق الرئيسي / أول حساب بنكي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000335)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P80_MONTH is null then :P80_MONTH := to_char(sysdate, ''YYYY-MM''); end if;',
'declare n number; begin n := noona_wrk_pkg.sync_paid; end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820272000000335
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000336)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000332)
,p_button_name=>'COLLECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'جمع المستحقات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000337)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820272000000332)
,p_button_name=>'APPROVE_ALL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'اعتماد كل المعلق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000338)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820272000000332)
,p_button_name=>'SETTLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'صرف المعتمد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000339)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820272000000332)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'مكافأة أو مستحق يدوي'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:81:&SESSION.::&DEBUG.:RP,81::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000340)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Collect'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare n number;',
'begin',
'  n := noona_wrk_pkg.collect(to_date(:P80_MONTH || ''-01'', ''YYYY-MM-DD''));',
'  apex_application.g_print_success_message := ''تم الجمع: '' || n || '' مستحق جديد'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000336)
,p_internal_uid=>91820272000000340
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000341)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare n number;',
'begin',
'  n := noona_wrk_pkg.approve_month(to_date(:P80_MONTH || ''-01'', ''YYYY-MM-DD''));',
'  apex_application.g_print_success_message := ''تم اعتماد '' || n || '' مستحق'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000337)
,p_internal_uid=>91820272000000341
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000342)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Settle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare n number;',
'begin',
'  n := noona_wrk_pkg.settle(to_date(:P80_MONTH || ''-01'', ''YYYY-MM-DD''), :P80_PLACE);',
'  apex_application.g_print_success_message := ''تم صرف '' || n || '' مستحق: مع الراتب إلى مسير الشهر، والنقدي والتحويل في سندات بانتظار الاعتماد المالي'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000338)
,p_internal_uid=>91820272000000342
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000343)
,p_plug_name=>'غير المربوطين'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>8
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_wrk_pkg.unlinked_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000344)
,p_plug_name=>'ملخص الشهر'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_wrk_pkg.summary_html(to_date(:P80_MONTH || ''-01'', ''YYYY-MM-DD''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000345)
,p_plug_name=>'تفاصيل المستحقات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select f.id, noona_wrk_pkg.employee_name(f.employee_id) employee, noona_wrk_pkg.type_label(f.earning_type) etype, f.source_module,',
'       f.source_ref, f.base_amount, f.amount, noona_wrk_pkg.method_label(f.pay_method) method, noona_wrk_pkg.badge(f.status_code) status_html,',
'       (select t.doc_no from csh_transaction t where t.id = f.cash_txn_id) voucher, f.approved_by, f.notes',
'  from pay_field_earning f where f.company_id = noona_hr_pkg.company and f.period_month = to_date(:P80_MONTH || ''-01'', ''YYYY-MM-DD'')',
' order by employee, f.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'تفاصيل المستحقات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000346)
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
,p_detail_link=>'f?p=&APP_ID.:81:&SESSION.::&DEBUG.:RP,81:P81_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820272000000346
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000348)
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
 p_id=>wwv_flow_imp.id(91820272000000349)
,p_db_column_name=>'EMPLOYEE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الموظف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000350)
,p_db_column_name=>'ETYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000351)
,p_db_column_name=>'SOURCE_MODULE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000352)
,p_db_column_name=>'SOURCE_REF'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المرجع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000353)
,p_db_column_name=>'BASE_AMOUNT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الأساس'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000354)
,p_db_column_name=>'AMOUNT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المستحق'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000355)
,p_db_column_name=>'METHOD'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الصرف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000356)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000357)
,p_db_column_name=>'VOUCHER'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'سند الصرف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000358)
,p_db_column_name=>'APPROVED_BY'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'المعتمد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000359)
,p_db_column_name=>'NOTES'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'ملاحظات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000347)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'347'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'EMPLOYEE:ETYPE:SOURCE_MODULE:SOURCE_REF:BASE_AMOUNT:AMOUNT:METHOD:STATUS_HTML:VOUCHER:APPROVED_BY:NOTES'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000360)
,p_branch_action=>'f?p=&APP_ID.:80:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
