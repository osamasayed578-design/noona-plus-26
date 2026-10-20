prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
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
 p_id=>11
,p_name=>'Company'
,p_alias=>'COMPANY'
,p_step_title=>'الشركة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000033)
,p_plug_name=>'بيانات الشركة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000034)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000035)
,p_name=>'P11_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>50
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000036)
,p_name=>'P11_LEGAL_NAME_AR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_prompt=>'الاسم القانوني بالعربية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
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
 p_id=>wwv_flow_imp.id(91820262000000037)
,p_name=>'P11_LEGAL_NAME_EN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_prompt=>'الاسم القانوني بالإنجليزية'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000038)
,p_name=>'P11_TRADE_NAME_AR'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_prompt=>'الاسم التجاري'
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
 p_id=>wwv_flow_imp.id(91820262000000039)
,p_name=>'P11_COUNTRY_CODE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_prompt=>'الدولة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_COUNTRIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000007)||'.'
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
 p_id=>wwv_flow_imp.id(91820262000000040)
,p_name=>'P11_FUNCTIONAL_CURRENCY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_prompt=>'العملة الوظيفية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_CURRENCIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000006)||'.'
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
 p_id=>wwv_flow_imp.id(91820262000000041)
,p_name=>'P11_STATUS'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000043)
,p_validation_name=>'P11_CODE required (CREATE)'
,p_validation_sequence=>9
,p_validation=>'P11_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000042)
,p_associated_item=>wwv_flow_imp.id(91820262000000035)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000044)
,p_validation_name=>'P11_LEGAL_NAME_AR required (CREATE)'
,p_validation_sequence=>10
,p_validation=>'P11_LEGAL_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000042)
,p_associated_item=>wwv_flow_imp.id(91820262000000036)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000045)
,p_validation_name=>'P11_COUNTRY_CODE required (CREATE)'
,p_validation_sequence=>11
,p_validation=>'P11_COUNTRY_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000042)
,p_associated_item=>wwv_flow_imp.id(91820262000000039)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000046)
,p_validation_name=>'P11_FUNCTIONAL_CURRENCY required (CREATE)'
,p_validation_sequence=>12
,p_validation=>'P11_FUNCTIONAL_CURRENCY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000042)
,p_associated_item=>wwv_flow_imp.id(91820262000000040)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000042)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الشركة'
,p_button_position=>'NEXT'
,p_button_condition=>':P11_ID is null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000048)
,p_validation_name=>'P11_CODE required (SAVE)'
,p_validation_sequence=>14
,p_validation=>'P11_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000047)
,p_associated_item=>wwv_flow_imp.id(91820262000000035)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000049)
,p_validation_name=>'P11_LEGAL_NAME_AR required (SAVE)'
,p_validation_sequence=>15
,p_validation=>'P11_LEGAL_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000047)
,p_associated_item=>wwv_flow_imp.id(91820262000000036)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000050)
,p_validation_name=>'P11_COUNTRY_CODE required (SAVE)'
,p_validation_sequence=>16
,p_validation=>'P11_COUNTRY_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000047)
,p_associated_item=>wwv_flow_imp.id(91820262000000039)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000051)
,p_validation_name=>'P11_FUNCTIONAL_CURRENCY required (SAVE)'
,p_validation_sequence=>17
,p_validation=>'P11_FUNCTIONAL_CURRENCY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000047)
,p_associated_item=>wwv_flow_imp.id(91820262000000040)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000047)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ التعديلات'
,p_button_position=>'NEXT'
,p_button_condition=>':P11_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000052)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000033)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000053)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Company'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P11_ID is not null then',
'    select code, legal_name_ar, legal_name_en, trade_name_ar, country_code, functional_currency,',
'           noona_ui_pkg.status_label(status_code)',
'      into :P11_CODE, :P11_LEGAL_NAME_AR, :P11_LEGAL_NAME_EN, :P11_TRADE_NAME_AR, :P11_COUNTRY_CODE,',
'           :P11_FUNCTIONAL_CURRENCY, :P11_STATUS',
'      from org_company where id = :P11_ID;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000053
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000054)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Company'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P11_ID := noona_platform_pkg.create_company(',
'    p_code => :P11_CODE, p_legal_name_ar => :P11_LEGAL_NAME_AR, p_legal_name_en => :P11_LEGAL_NAME_EN,',
'    p_country_code => :P11_COUNTRY_CODE, p_functional_currency => :P11_FUNCTIONAL_CURRENCY);',
'update org_company set trade_name_ar = :P11_TRADE_NAME_AR where id = :P11_ID;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000042)
,p_process_success_message=>'تم إنشاء الشركة؛ أكمل الفروع ثم شغّل فحوص التفعيل'
,p_internal_uid=>91820262000000054
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000055)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Company'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_security_pkg.assert_permission(''ORG_COMPANY.UPDATE'', :P11_ID);',
'update org_company',
'   set legal_name_ar = :P11_LEGAL_NAME_AR, legal_name_en = :P11_LEGAL_NAME_EN, trade_name_ar = :P11_TRADE_NAME_AR',
' where id = :P11_ID;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000047)
,p_process_success_message=>'تم حفظ بيانات الشركة'
,p_internal_uid=>91820262000000055
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000056)
,p_plug_name=>'شعار الشركة (الترويسة والتقارير)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000057)
,p_name=>'P11_LOGO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000056)
,p_prompt=>'ملف الشعار'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'storage_type', 'APEX_APPLICATION_TEMP_FILES',
  'purge_file_at', 'REQUEST',
  'allow_multiple_files', 'N',
  'file_types', 'image/png,image/jpeg,image/gif,image/webp',
  'display_as', 'DROPZONE_BLOCK',
  'dropzone_title', 'اسحب الشعار هنا أو اضغط للاختيار',
  'dropzone_description', 'PNG أو JPG أو GIF أو WEBP حتى 512 كيلوبايت',
  'max_file_size', '512')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000058)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000056)
,p_button_name=>'UPLOAD_LOGO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'رفع الشعار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000059)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000056)
,p_button_name=>'REMOVE_LOGO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إزالة الشعار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000060)
,p_plug_name=>'معاينة الشعار وترويسة التقارير'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>16
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_uri clob := noona_brand_pkg.logo_data_uri(:P11_ID);',
'begin',
'    return case when l_uri is null',
'                then ''<div class="nn-empty">لا يوجد شعار بعد؛ تظهر التقارير باسم الشركة فقط</div>''',
'           end || noona_brand_pkg.report_header(''معاينة ترويسة التقارير'', :P11_ID);',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000061)
,p_process_sequence=>25
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Upload Logo'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_blob blob;',
'    l_name varchar2(400);',
'    l_doc  number;',
'begin',
'    if :P11_LOGO is null then',
'        raise_application_error(-20500, ''NOONA-BRD-003: اختر ملف الشعار أولاً'');',
'    end if;',
'    select blob_content, filename into l_blob, l_name from apex_application_temp_files where name = :P11_LOGO;',
'    l_doc := noona_brand_pkg.set_company_logo(p_company_id => :P11_ID, p_file_name => l_name, p_content => l_blob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000058)
,p_process_success_message=>'تم حفظ الشعار؛ سيظهر في الترويسة والتقارير'
,p_internal_uid=>91820262000000061
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000062)
,p_process_sequence=>26
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remove Logo'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_brand_pkg.remove_company_logo(p_company_id => :P11_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000059)
,p_process_success_message=>'تمت إزالة الشعار'
,p_internal_uid=>91820262000000062
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000063)
,p_plug_name=>'فحوص التفعيل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select id, noona_ui_pkg.code_label(check_code) as check_code, noona_ui_pkg.status_badge(status_code) as status_html, result_info, waived_by, checked_at',
'  from org_company_check where company_id = :P11_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'فحوص التفعيل'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000064)
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
,p_internal_uid=>91820262000000064
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000066)
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
 p_id=>wwv_flow_imp.id(91820262000000067)
,p_db_column_name=>'CHECK_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الفحص'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000068)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النتيجة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000069)
,p_db_column_name=>'RESULT_INFO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'التفاصيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000070)
,p_db_column_name=>'WAIVED_BY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'استثناء بواسطة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000071)
,p_db_column_name=>'CHECKED_AT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'وقت الفحص'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000065)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'65'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CHECK_CODE:STATUS_HTML:RESULT_INFO:WAIVED_BY:CHECKED_AT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000072)
,p_plug_name=>'إجراءات التفعيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000073)
,p_name=>'P11_WAIVE_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000072)
,p_prompt=>'استثناء فحص فاشل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_ui_pkg.code_label(check_code) d, check_code r from org_company_check where company_id = :P11_ID and status_code = ''FAILED'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820262000000074)
,p_name=>'P11_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000072)
,p_prompt=>'السبب (إلزامي للاستثناء وتغيير الحالة)'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000075)
,p_name=>'P11_NEW_STATUS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000072)
,p_prompt=>'تغيير الحالة إلى'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_ui_pkg.status_label(column_value) d, column_value r from table(sys.odcivarchar2list(''UNDER_CONFIGURATION'',''READY_FOR_REVIEW'',''SUSPENDED'',''INACTIVE'',''ACTIVE'',''CLOSURE_REQUESTED'',''UNDER_LIQUIDATION'',''TRANSACTIONS_BLOCKED'',''FINANCIALLY_CLOSED'',''LEGALLY_CLOSED'',''CLOSED'',''ARCHIVED''))'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000076)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000072)
,p_button_name=>'RUN_CHECKS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تشغيل الفحوص'
,p_button_position=>'NEXT'
,p_button_condition=>':P11_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000077)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000072)
,p_button_name=>'WAIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'استثناء الفحص'
,p_button_position=>'NEXT'
,p_button_condition=>':P11_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000078)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000072)
,p_button_name=>'ACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تفعيل الشركة'
,p_button_position=>'NEXT'
,p_button_condition=>':P11_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000079)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820262000000072)
,p_button_name=>'CHANGE_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير الحالة'
,p_button_position=>'NEXT'
,p_button_condition=>':P11_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000080)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Run Checks'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_failed number;',
'begin',
'    l_failed := noona_platform_pkg.run_activation_checks(:P11_ID);',
'    apex_application.g_print_success_message := case when l_failed = 0 then ''نجحت كل الفحوص؛ الشركة جاهزة للتفعيل''',
'                                                     else ''عدد الفحوص الفاشلة: '' || l_failed end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000076)
,p_internal_uid=>91820262000000080
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000081)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Waive Check'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_platform_pkg.waive_check(p_company_id => :P11_ID, p_check_code => :P11_WAIVE_CODE, p_reason => :P11_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000077)
,p_process_success_message=>'تم استثناء الفحص'
,p_internal_uid=>91820262000000081
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000082)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Activate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_platform_pkg.activate_company(p_company_id => :P11_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000078)
,p_process_success_message=>'تم تفعيل الشركة'
,p_internal_uid=>91820262000000082
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000083)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Change Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_platform_pkg.change_company_status(p_company_id => :P11_ID, p_new_status => :P11_NEW_STATUS, p_reason => :P11_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000079)
,p_process_success_message=>'تم تغيير حالة الشركة'
,p_internal_uid=>91820262000000083
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000084)
,p_plug_name=>'فروع الشركة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select id, code, name_ar, noona_ui_pkg.code_label(branch_type) as branch_type, noona_ui_pkg.code_label(is_head_office) as is_head_office,',
'       noona_ui_pkg.status_badge(status_code) as status_html',
'  from org_branch where company_id = :P11_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'فروع الشركة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000085)
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
,p_detail_link=>'f?p=&APP_ID.:13:&SESSION.::&DEBUG.:RP,13:P13_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820262000000085
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000087)
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
 p_id=>wwv_flow_imp.id(91820262000000088)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000089)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الفرع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000090)
,p_db_column_name=>'BRANCH_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000091)
,p_db_column_name=>'IS_HEAD_OFFICE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'رئيسي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000092)
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
 p_id=>wwv_flow_imp.id(91820262000000086)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'86'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:BRANCH_TYPE:IS_HEAD_OFFICE:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000093)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000084)
,p_button_name=>'ADD_BRANCH'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'فرع جديد'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:13:&SESSION.::&DEBUG.:RP,13:P13_COMPANY_ID:&P11_ID.'
,p_button_condition=>':P11_ID is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000094)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.::P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
