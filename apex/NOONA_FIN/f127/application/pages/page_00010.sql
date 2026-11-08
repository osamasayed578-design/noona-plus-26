prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
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
 p_id=>10
,p_name=>'Chart of Accounts'
,p_alias=>'ACCOUNTS'
,p_step_title=>'دليل الحسابات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000036)
,p_plug_name=>'دليل الحسابات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select a.id, a.account_code, lpad('' '', (a.account_level - 1) * 4, '' '') || a.name_ar as name_ar,',
'       case a.account_type when ''ASSET'' then ''أصول'' when ''LIABILITY'' then ''خصوم'' when ''EQUITY'' then ''حقوق ملكية''',
'            when ''REVENUE'' then ''إيرادات'' when ''EXPENSE'' then ''مصروفات'' else a.account_type end as account_type,',
'       case a.normal_balance when ''DEBIT'' then ''مدين'' else ''دائن'' end as normal_balance,',
'       case a.is_postable when ''Y'' then ''حركة'' else ''تجميعي'' end as kind,',
'       decode(a.subledger_code, ''AR'', ''العملاء'', ''AP'', ''الموردون'', ''INV'', ''المخزون'', ''FA'', ''الأصول الثابتة'',',
'              ''CASH'', ''النقدية'', ''TAX'', ''الضرائب'', ''PAYROLL'', ''الرواتب'', ''INTERCOMPANY'', ''بين الشركات'', a.subledger_code) as subledger,',
'       noona_ui_pkg.code_label(a.allow_manual_posting) as manual, noona_ui_pkg.status_badge(a.status_code) as status_html',
'  from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger',
' order by a.account_code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'دليل الحسابات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000037)
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
,p_internal_uid=>91820266000000037
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000039)
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
 p_id=>wwv_flow_imp.id(91820266000000040)
,p_db_column_name=>'ACCOUNT_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000041)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الحساب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000042)
,p_db_column_name=>'ACCOUNT_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000043)
,p_db_column_name=>'NORMAL_BALANCE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الطبيعة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000044)
,p_db_column_name=>'KIND'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'تجميعي/حركة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000045)
,p_db_column_name=>'SUBLEDGER'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'نظام فرعي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000046)
,p_db_column_name=>'MANUAL'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'قيد يدوي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000047)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000038)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'38'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ACCOUNT_CODE:NAME_AR:ACCOUNT_TYPE:NORMAL_BALANCE:KIND:SUBLEDGER:MANUAL:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000048)
,p_plug_name=>'حساب جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000049)
,p_name=>'P10_PARENT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000048)
,p_prompt=>'تحت الحساب الرئيسي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.account_code r from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger and a.is_postable = ''N'' order by a.account_code'
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
 p_id=>wwv_flow_imp.id(91820266000000050)
,p_name=>'P10_CODE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000048)
,p_prompt=>'رمز الحساب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000051)
,p_name=>'P10_NAME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000048)
,p_prompt=>'اسم الحساب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000052)
,p_name=>'P10_POSTABLE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000048)
,p_prompt=>'نوع الحساب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:حساب حركة;Y,حساب تجميعي;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000053)
,p_name=>'P10_SUB'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000048)
,p_prompt=>'تصنيف خاص'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:جاري بين شركات المجموعة (يستبعد في القوائم الموحدة);INTERCOMPANY'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- بدون -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000055)
,p_validation_name=>'P10_PARENT required (ADD_ACCOUNT)'
,p_validation_sequence=>17
,p_validation=>'P10_PARENT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000054)
,p_associated_item=>wwv_flow_imp.id(91820266000000049)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000056)
,p_validation_name=>'P10_CODE required (ADD_ACCOUNT)'
,p_validation_sequence=>18
,p_validation=>'P10_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000054)
,p_associated_item=>wwv_flow_imp.id(91820266000000050)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000057)
,p_validation_name=>'P10_NAME required (ADD_ACCOUNT)'
,p_validation_sequence=>19
,p_validation=>'P10_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000054)
,p_associated_item=>wwv_flow_imp.id(91820266000000051)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000054)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000048)
,p_button_name=>'ADD_ACCOUNT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الحساب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000058)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Account'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_gl_pkg.add_account(p_coa_id => noona_gl_pkg.primary_coa, p_code => :P10_CODE, p_name_ar => :P10_NAME,',
'                p_parent_code => :P10_PARENT, p_postable => :P10_POSTABLE, p_subledger => :P10_SUB);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000054)
,p_process_success_message=>'تمت إضافة الحساب'
,p_internal_uid=>91820266000000058
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000059)
,p_plug_name=>'استيراد حسابات من ملف (CSV أو Excel محفوظ CSV)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">السطر الأول عناوين الأعمدة بالعربي أو الإنجليزي: <b>رمز الحساب</b> (code)، <b>اسم الحساب</b> (name)، <b>الحساب الأب</b> (parent)، <b>النوع</b> (type: أصول، خصوم، حقوق ملكية، إيرادات، مصروفات — يكفي للحساب الرئيسي الأعلى، والفرعي يأخذ نوع أبيه)، <b>حساب حركة</b> (postable: نعم / لا). الأب يكون حساباً تجميعياً موجوداً في الدليل أو في الملف نفسه بأي ترتيب. كل صف مستقل: الخاطئ يظهر في التقرير ولا يوقف الباقي. في Excel: حفظ باسم ← CSV UTF-8.</p><pre dir="ltr" class="nn-csv">code,name,parent,type,postable',
'1150,العهد والسلف المؤقتة,11,أصول,لا',
'115001,عهدة مدير المشتريات,1150,,نعم',
'115002,عهدة أمين الصندوق,1150,,نعم</pre>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000060)
,p_name=>'P10_FILE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000059)
,p_prompt=>'ملف الحسابات'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'storage_type', 'APEX_APPLICATION_TEMP_FILES',
  'purge_file_at', 'REQUEST',
  'allow_multiple_files', 'N',
  'file_types', '.csv,text/csv,text/plain',
  'display_as', 'DROPZONE_BLOCK',
  'dropzone_title', 'اسحب ملف الحسابات هنا أو اضغط للاختيار',
  'dropzone_description', 'CSV بترميز UTF-8 حتى 5 ميجابايت',
  'max_file_size', '5120')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000061)
,p_name=>'P10_JOB'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820266000000059)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000062)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000059)
,p_button_name=>'IMPORT_ACCOUNTS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'استيراد الحسابات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000063)
,p_process_sequence=>15
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Import Accounts'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_blob blob; l_name varchar2(400); l_csv clob; l_job number; l_ok number; l_bad number;',
'begin',
'    if :P10_FILE is null then raise_application_error(-20500, ''NOONA-CON-025: اختر ملف الحسابات أولاً''); end if;',
'    select blob_content, filename into l_blob, l_name from apex_application_temp_files where name = :P10_FILE;',
'    l_csv := apex_util.blob_to_clob(p_blob => l_blob, p_charset => ''AL32UTF8'');',
'    l_job := noona_conn_pkg.import_csv(''ACCOUNTS'', l_name, l_csv);',
'    select ok_rows, failed_rows into l_ok, l_bad from api_import_job where id = l_job;',
'    :P10_JOB := l_job;',
'    apex_application.g_print_success_message := ''تم استيراد '' || l_ok || '' حساب'' || case when l_bad > 0 then ''، ورفض '' || l_bad || '' (التفاصيل أدناه)'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000062)
,p_internal_uid=>91820266000000063
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000064)
,p_plug_name=>'نتيجة استيراد الحسابات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>26
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P10_JOB is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.job_html(to_number(:P10_JOB));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000065)
,p_plug_name=>'إيقاف أو تفعيل حساب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000066)
,p_name=>'P10_ACCOUNT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000065)
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
 p_id=>wwv_flow_imp.id(91820266000000067)
,p_name=>'P10_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000065)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:موقوف;BLOCKED,نشط;ACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000068)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000065)
,p_button_name=>'SET_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تطبيق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000069)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Account Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_gl_pkg.set_account_status(:P10_ACCOUNT, :P10_STATUS);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000068)
,p_process_success_message=>'تم تغيير حالة الحساب'
,p_internal_uid=>91820266000000069
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000070)
,p_branch_action=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10:P10_JOB:&P10_JOB.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
