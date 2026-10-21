prompt --application/pages/page_00023
begin
--   Manifest
--     PAGE: 00023
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>23
,p_name=>'Storage Settings'
,p_alias=>'STORAGE'
,p_step_title=>'مكان حفظ الملفات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000178)
,p_plug_name=>'مكان الحفظ الحالي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dms_pkg.storage_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000179)
,p_plug_name=>'تغيير مكان الحفظ'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">مجلد الخادم أو NAS يخصصه مسؤول قاعدة البيانات للمؤسسة كـ Oracle DIRECTORY باسم يبدأ بـ <b dir="ltr">NOONA_DMS_T&lt;رقم المؤسسة&gt;</b> مع صلاحية القراءة والكتابة لـ NOONA_OWNER. الملفات الجديدة تحفظ في المكان المختار، والسابقة تبقى في مكانها وتقرأ منه، ويمكن نقلها بزر النقل. بيانات المستند وبصمته تبقى في قاعدة البيانات.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000180)
,p_name=>'P23_MEDIUM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000179)
,p_prompt=>'مكان الحفظ'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:داخل قاعدة البيانات;DATABASE,مجلد على الخادم / NAS;SERVER_FOLDER,تخزين سحابي OCI/S3 (مرحلة لاحقة);OBJECT_STORAGE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000181)
,p_name=>'P23_DIR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000179)
,p_prompt=>'المجلد المخصص'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select column_value d, column_value r from table(noona_dms_pkg.storage_directories)'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- لا يوجد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000182)
,p_name=>'P23_PATH'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820267000000179)
,p_prompt=>'وصف المسار (للتوثيق)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000183)
,p_name=>'P23_PREFIX'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820267000000179)
,p_prompt=>'بادئة أسماء الملفات'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>50
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000184)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Storage'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select storage_medium, directory_name, base_path, file_prefix into :P23_MEDIUM, :P23_DIR, :P23_PATH, :P23_PREFIX',
'      from dms_storage_profile where company_id = noona_dms_pkg.company and is_active = ''Y'';',
'exception when no_data_found then',
'    :P23_MEDIUM := ''DATABASE'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820267000000184
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000185)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000179)
,p_button_name=>'SAVE_STORAGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000186)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820267000000179)
,p_button_name=>'TEST_STORAGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'اختبار الاتصال'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000187)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820267000000179)
,p_button_name=>'MOVE_FILES'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'نقل ملفات قاعدة البيانات إلى المجلد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000188)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Storage'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dms_pkg.set_storage(:P23_MEDIUM, :P23_DIR, :P23_PATH, :P23_PREFIX);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000185)
,p_process_success_message=>'تم حفظ مكان الحفظ؛ اختبر الاتصال'
,p_internal_uid=>91820267000000188
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000189)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Test Storage'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_r varchar2(1000);',
'begin',
'    l_r := noona_dms_pkg.test_storage;',
'    if l_r <> ''OK'' then raise_application_error(-20500, ''NOONA-DMS-146: فشل اختبار مكان الحفظ: '' || l_r); end if;',
'    apex_application.g_print_success_message := ''الاختبار ناجح: تمت الكتابة والقراءة والحذف في مكان الحفظ'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000186)
,p_internal_uid=>91820267000000189
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000190)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Move Files'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_dms_pkg.move_files(500);',
'    apex_application.g_print_success_message := ''تم نقل '' || l_n || '' ملف إلى المجلد'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000187)
,p_internal_uid=>91820267000000190
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000191)
,p_branch_action=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
