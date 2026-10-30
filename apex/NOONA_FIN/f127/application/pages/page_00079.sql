prompt --application/pages/page_00079
begin
--   Manifest
--     PAGE: 00079
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
 p_id=>79
,p_name=>'Bank Statements'
,p_alias=>'BANK-STATEMENTS'
,p_step_title=>'كشوف الحساب البنكية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000880)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(document).on(''click'', ''.nn-st-open'', function (e) { e.preventDefault(); window.location.href = apex.item(''P79_GO'').getValue().replace(''990000000001'', $(this).data(''id'')); });'))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000881)
,p_plug_name=>'استيراد كشف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">ملف CSV من البنك: أعمدة التاريخ والمبلغ (موجب إيداع، سالب سحب) أو عمودا مدين ودائن، والمرجع والبيان. الأسطر المستوردة سابقاً تتجاهل تلقائياً. بعد الاستيراد يقترح النظام الحركة المقابلة لكل سطر (نفس الحساب والاتجاه والمبلغ خلال 3 أيام، والمرجع يرفع الثقة).</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000882)
,p_name=>'P79_BANK'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000881)
,p_prompt=>'الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from csh_bank_account where company_id = noona_conn_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820266000000883)
,p_name=>'P79_FILE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000881)
,p_prompt=>'ملف الكشف'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'storage_type', 'APEX_APPLICATION_TEMP_FILES',
  'purge_file_at', 'REQUEST',
  'allow_multiple_files', 'N',
  'file_types', '.csv,text/csv,text/plain',
  'display_as', 'DROPZONE_BLOCK',
  'dropzone_title', 'اسحب ملف الكشف هنا أو اضغط للاختيار',
  'dropzone_description', 'CSV بترميز UTF-8',
  'max_file_size', '5120')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000884)
,p_name=>'P79_OPENING'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000881)
,p_prompt=>'الرصيد الافتتاحي (اختياري)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000885)
,p_name=>'P79_CLOSING'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000881)
,p_prompt=>'الرصيد الختامي (اختياري)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000887)
,p_validation_name=>'P79_BANK required (IMPORT)'
,p_validation_sequence=>5
,p_validation=>'P79_BANK'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000886)
,p_associated_item=>wwv_flow_imp.id(91820266000000882)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000886)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000881)
,p_button_name=>'IMPORT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'استيراد ومطابقة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000888)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Import'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_blob blob; l_name varchar2(400); l_csv clob; l_st number;',
'begin',
'    select blob_content, filename into l_blob, l_name from apex_application_temp_files where name = :P79_FILE;',
'    l_csv := apex_util.blob_to_clob(p_blob => l_blob, p_charset => ''AL32UTF8'');',
'    l_st := noona_conn_pkg.import_bank_statement(to_number(:P79_BANK), l_name, l_csv, to_number(:P79_OPENING), to_number(:P79_CLOSING));',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 80, p_items => ''P80_ID'', p_values => l_st));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000886)
,p_internal_uid=>91820266000000888
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000889)
,p_plug_name=>'الكشوف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_conn_pkg.statements_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000890)
,p_plug_name=>'go'
,p_region_template_options=>'#DEFAULT#:u-hidden:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>90
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000891)
,p_name=>'P79_GO'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000890)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000892)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Link'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin :P79_GO := apex_page.get_url(p_page => 80, p_items => ''P80_ID'', p_values => ''990000000001''); end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000892
);

wwv_flow_imp.component_end;
end;
/
