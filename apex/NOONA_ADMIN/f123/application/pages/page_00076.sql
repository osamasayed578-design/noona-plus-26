prompt --application/pages/page_00076
begin
--   Manifest
--     PAGE: 00076
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
 p_id=>76
,p_name=>'Data Import'
,p_alias=>'DATA-IMPORT'
,p_step_title=>'استيراد البيانات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000683)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000774)
,p_plug_name=>'ملف CSV'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">السطر الأول عناوين الأعمدة (عربي أو إنجليزي)، والفاصل فاصلة أو فاصلة منقوطة. كل صف مستقل: الصفوف الخاطئة أو المكررة تظهر في تقرير الاستيراد ولا توقف الباقي. حتى 5000 صف للملف.<br>العملاء والموردون: <code dir="ltr">name, phone, email, tax, cr, address, term</code> — الأصناف: <code dir="ltr">no, name, nameEn, type, price, barcode, category</code> — شجرة الحسابات: <code dir="ltr">code, name, parent, type, postable</code></p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000775)
,p_name=>'P76_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000774)
,p_prompt=>'نوع البيانات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:العملاء;CUSTOMERS,الموردون;SUPPLIERS,الأصناف;ITEMS,شجرة الحسابات;ACCOUNTS'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000776)
,p_name=>'P76_FILE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000774)
,p_prompt=>'الملف'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'storage_type', 'APEX_APPLICATION_TEMP_FILES',
  'purge_file_at', 'REQUEST',
  'allow_multiple_files', 'N',
  'file_types', '.csv,text/csv,text/plain',
  'display_as', 'DROPZONE_BLOCK',
  'dropzone_title', 'اسحب ملف CSV هنا أو اضغط للاختيار',
  'dropzone_description', 'CSV بترميز UTF-8 حتى 5 ميجابايت',
  'max_file_size', '5120')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000777)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000774)
,p_button_name=>'IMPORT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'استيراد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000778)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Import'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_blob blob; l_name varchar2(400); l_csv clob; l_job number; l_ok number; l_bad number;',
'begin',
'    if :P76_FILE is null then raise_application_error(-20500, ''NOONA-CON-025: اختر الملف أولاً''); end if;',
'    select blob_content, filename into l_blob, l_name from apex_application_temp_files where name = :P76_FILE;',
'    l_csv := apex_util.blob_to_clob(p_blob => l_blob, p_charset => ''AL32UTF8'');',
'    l_job := noona_conn_pkg.import_csv(:P76_TYPE, l_name, l_csv);',
'    select ok_rows, failed_rows into l_ok, l_bad from api_import_job where id = l_job;',
'    :P76_JOB := l_job;',
'    apex_application.g_print_success_message := ''تم استيراد '' || l_ok || '' صف'' || case when l_bad > 0 then ''، ورفض '' || l_bad || '' (التفاصيل أدناه)'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000777)
,p_internal_uid=>91820262000000778
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000779)
,p_name=>'P76_JOB'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820262000000774)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000780)
,p_plug_name=>'نتيجة الاستيراد'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P76_JOB is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.job_html(to_number(:P76_JOB));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000781)
,p_plug_name=>'نماذج الملفات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000782)
,p_name=>'P76_TPL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000781)
,p_prompt=>'النموذج'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:العملاء;CUSTOMERS,الموردون;SUPPLIERS,الأصناف;ITEMS,شجرة الحسابات;ACCOUNTS,كشف حساب بنكي;BANK_STATEMENT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000783)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000781)
,p_button_name=>'SHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عرض النموذج'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000784)
,p_plug_name=>'النموذج'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>26
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<pre dir="ltr" class="nn-csv">'' || noona_ui_pkg.esc(noona_conn_pkg.template_csv(nvl(:P76_TPL, ''CUSTOMERS''))) || ''</pre>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000785)
,p_plug_name=>'عمليات الاستيراد السابقة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.jobs_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
