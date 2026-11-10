prompt --application/pages/page_00090
begin
--   Manifest
--     PAGE: 00090
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
 p_id=>90
,p_name=>'Onboarding'
,p_alias=>'ONBOARDING'
,p_step_title=>'بدء التشغيل ونقل البيانات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000846)
,p_plug_name=>'الشركة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>4
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div class="nn-hint">نقل بيانات <b>'' || noona_ui_pkg.esc(noona_apex_pkg.company_name) || ''</b> من النظام السابق. اتبع الخطوات بالترتيب: البيانات الأساسية أولاً ثم الأرصدة الافتتاحية في تاريخ بدء العمل على النظام. كل ملف أرصدة يرحل كاملاً أو لا يرحل منه شيء، فصحح الأخطاء الظاهرة وأعد رفعه. لتغيير الشركة استخدم مبدل الشركة أعلى الشاشة.</div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000847)
,p_plug_name=>'تجهيز الأنظمة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>8
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الشركة لم تجهز بعد: يجهز هذا الزر دليل الحسابات القياسي والسنة المالية والنقدية والمخزون والمبيعات والمشتريات وباقي الأنظمة المشترك فيها، ثم تبدأ الاستيراد.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_gl_pkg.primary_ledger is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000848)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000847)
,p_button_name=>'SETUP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز الأنظمة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000849)
,p_process_sequence=>3
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setup'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex_application.g_print_success_message := ''جهز: '' || noona_account_pkg.setup_company;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000848)
,p_internal_uid=>91820262000000849
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000850)
,p_plug_name=>'خطوات بدء التشغيل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.onboarding_html(''f?p='' || :APP_ID || '':90:'' || :APP_SESSION || ''::NO::P90_TYPE:#TYPE#'');'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000851)
,p_plug_name=>'استيراد ملف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">ملف Excel (xlsx، الورقة الأولى) أو CSV. السطر الأول عناوين الأعمدة بالعربي أو الإنجليزي (مثل: رمز الحساب، مدين، دائن، العميل، رقم الفاتورة، المبلغ، الصنف، الكمية، التكلفة). حتى 5000 صف للملف. نزّل نموذج النوع المختار وعبئه في Excel ثم ارفعه.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000852)
,p_name=>'P90_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000851)
,p_prompt=>'نوع البيانات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:شجرة الحسابات;ACCOUNTS,العملاء;CUSTOMERS,الموردون;SUPPLIERS,الأصناف;ITEMS,الموظفون;EMPLOYEES,أرصدة الحسابات والنقدية والبنوك;OPENING_GL,أرصدة العملاء (فواتير مفتوحة);OPENING_AR,أرصدة الموردين (فواتير مستحقة);OPENING_AP,أرصدة المخزون (كمية وتكلفة);OPENING_STOCK'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000853)
,p_name=>'P90_DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000851)
,p_prompt=>'تاريخ الأرصدة الافتتاحية'
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
 p_id=>wwv_flow_imp.id(91820262000000854)
,p_name=>'P90_FILE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000851)
,p_prompt=>'الملف'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'storage_type', 'APEX_APPLICATION_TEMP_FILES',
  'purge_file_at', 'REQUEST',
  'allow_multiple_files', 'N',
  'file_types', '.xlsx,.csv,text/csv,text/plain,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'display_as', 'DROPZONE_BLOCK',
  'dropzone_title', 'اسحب ملف Excel أو CSV هنا أو اضغط للاختيار',
  'dropzone_description', 'xlsx أو CSV حتى 10 ميجابايت',
  'max_file_size', '10240')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000855)
,p_name=>'P90_JOB'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820262000000851)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000856)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000851)
,p_button_name=>'IMPORT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'استيراد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000857)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000851)
,p_button_name=>'TEMPLATE'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تنزيل نموذج الملف'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:90:&SESSION.:TEMPLATE:&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000858)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P90_TYPE is null then :P90_TYPE := ''ACCOUNTS''; end if;',
'if :P90_DATE is null then :P90_DATE := to_char(trunc(sysdate, ''YYYY''), ''YYYY-MM-DD''); end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000858
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000859)
,p_process_sequence=>6
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Template'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l varchar2(32767) := noona_conn_pkg.template_csv(:P90_TYPE);',
'begin',
'    owa_util.mime_header(''text/csv'', false, ''UTF-8'');',
'    htp.p(''Content-Disposition: attachment; filename="noona_'' || lower(:P90_TYPE) || ''.csv"'');',
'    owa_util.http_header_close;',
'    htp.prn(unistr(''\FEFF'') || l);',
'    apex_application.stop_apex_engine;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''TEMPLATE'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>91820262000000859
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000860)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Import'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_blob blob; l_name varchar2(400); l_csv clob; l_job number; l_ok number; l_bad number; l_st varchar2(30);',
'begin',
'    if :P90_FILE is null then raise_application_error(-20500, ''NOONA-CON-025: اختر الملف أولاً''); end if;',
'    select blob_content, filename into l_blob, l_name from apex_application_temp_files where name = :P90_FILE;',
'    l_csv := noona_conn_pkg.file_to_csv(l_blob, l_name);',
'    l_job := noona_conn_pkg.import_csv(:P90_TYPE, l_name, l_csv, to_date(:P90_DATE, ''YYYY-MM-DD''));',
'    select ok_rows, failed_rows, status_code into l_ok, l_bad, l_st from api_import_job where id = l_job;',
'    :P90_JOB := l_job;',
'    apex_application.g_print_success_message := case',
'        when :P90_TYPE like ''OPENING%'' and l_st = ''FAILED'' then ''لم ترحل الأرصدة: '' || l_bad || '' صف به أخطاء (التفاصيل أدناه)''',
'        when :P90_TYPE like ''OPENING%'' then ''رحلت الأرصدة الافتتاحية: '' || l_ok || '' صف''',
'        else ''تم استيراد '' || l_ok || '' صف'' || case when l_bad > 0 then ''، ورفض '' || l_bad || '' (التفاصيل أدناه)'' end end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000856)
,p_internal_uid=>91820262000000860
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000861)
,p_plug_name=>'أعمدة الملف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<pre dir="ltr" class="nn-csv">'' || noona_ui_pkg.esc(noona_conn_pkg.template_csv(nvl(:P90_TYPE, ''ACCOUNTS''))) || ''</pre>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000862)
,p_plug_name=>'نتيجة الاستيراد'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P90_JOB is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.job_html(to_number(:P90_JOB));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000863)
,p_plug_name=>'دفعات الأرصدة الافتتاحية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000864)
,p_name=>'P90_BATCH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000863)
,p_prompt=>'إلغاء دفعة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select batch_no || '' - '' || case scope_code when ''GL'' then ''الحسابات'' when ''AR'' then ''العملاء'' when ''AP'' then ''الموردين'' end d, id r from gl_opening_batch where status_code = ''POSTED'' and scope_code in (''GL'', ''AR'', ''AP'') and company_id = to_number(sys_context(''NOONA_CTX'', ''COMPANY_ID'')) order by id desc'
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
 p_id=>wwv_flow_imp.id(91820262000000865)
,p_name=>'P90_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000863)
,p_prompt=>'سبب الإلغاء'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>400
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
 p_id=>wwv_flow_imp.id(91820262000000866)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000863)
,p_button_name=>'CANCEL_BATCH'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الدفعة بقيد عكسي'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000867)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel batch'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P90_BATCH is null then raise_application_error(-20500, ''NOONA-CON-085: اختر الدفعة''); end if;',
'noona_conn_pkg.cancel_opening(to_number(:P90_BATCH), :P90_REASON);',
':P90_BATCH := null; :P90_REASON := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000866)
,p_process_success_message=>'ألغيت الدفعة وعكس قيدها'
,p_internal_uid=>91820262000000867
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000868)
,p_plug_name=>'الدفعات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>45
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.openings_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000869)
,p_plug_name=>'عمليات الاستيراد السابقة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.jobs_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
