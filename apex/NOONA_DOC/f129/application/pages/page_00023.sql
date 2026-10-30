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
,p_required_role=>wwv_flow_imp.id(91820267000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000180)
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
 p_id=>wwv_flow_imp.id(91820267000000181)
,p_plug_name=>'تغيير مكان الحفظ'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">مجلد الخادم أو NAS يخصصه مسؤول قاعدة البيانات للمؤسسة كـ Oracle DIRECTORY باسم يبدأ بـ <b dir="ltr">NOONA_DMS_T&lt;رقم المؤسسة&gt;</b> مع صلاحية القراءة والكتابة لـ NOONA_OWNER. الملفات الجديدة تحفظ في المكان المختار، والسابقة تبقى في مكانها وتقرأ منه، ويمكن نقلها بزر النقل. بيانات المستند وبصمته تبقى في قاعدة البيانات. لحفظ الملفات على أجهزة الشركة نفسها اختر «وكيل تخزين محلي» بعد إضافة الوكيل وتثبيته (القسم التالي).</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000182)
,p_name=>'P23_MEDIUM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_prompt=>'مكان الحفظ'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:داخل قاعدة البيانات;DATABASE,مجلد على الخادم / NAS;SERVER_FOLDER,وكيل تخزين محلي عند الشركة;LOCAL_AGENT,تخزين سحابي OCI/S3 (مرحلة لاحقة);OBJECT_STORAGE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000183)
,p_name=>'P23_AGENT'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_prompt=>'الوكيل المحلي (عند اختيار الوكيل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name d, id r from dms_storage_agent where company_id = noona_dms_pkg.company and status_code = ''ACTIVE'' order by name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر الوكيل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000184)
,p_name=>'P23_DIR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_prompt=>'المجلد المخصص'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select column_value d, column_value r from table(noona_dms_pkg.storage_directories)'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- لا يوجد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000185)
,p_name=>'P23_PATH'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_prompt=>'وصف المسار (للتوثيق)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
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
 p_id=>wwv_flow_imp.id(91820267000000186)
,p_name=>'P23_PREFIX'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_prompt=>'بادئة أسماء الملفات'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>50
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000187)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Storage'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select storage_medium, directory_name, base_path, file_prefix, agent_id into :P23_MEDIUM, :P23_DIR, :P23_PATH, :P23_PREFIX, :P23_AGENT',
'      from dms_storage_profile where company_id = noona_dms_pkg.company and is_active = ''Y'';',
'exception when no_data_found then',
'    :P23_MEDIUM := ''DATABASE'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820267000000187
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000188)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_button_name=>'SAVE_STORAGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000189)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_button_name=>'TEST_STORAGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'اختبار الاتصال'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000190)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_button_name=>'MOVE_FILES'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'نقل ملفات قاعدة البيانات إلى مكان الحفظ الحالي'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000191)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Storage'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dms_pkg.set_storage(:P23_MEDIUM, :P23_DIR, :P23_PATH, :P23_PREFIX, :P23_AGENT);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000188)
,p_process_success_message=>'تم حفظ مكان الحفظ؛ اختبر الاتصال'
,p_internal_uid=>91820267000000191
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000192)
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
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000189)
,p_internal_uid=>91820267000000192
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000193)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Move Files'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_dms_pkg.move_files(500);',
'    apex_application.g_print_success_message := ''تم نقل '' || l_n || '' ملف إلى مكان الحفظ (ملفات الوكيل تنقل خلال دقائق)'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000190)
,p_internal_uid=>91820267000000193
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000194)
,p_name=>'P23_NEW_KEY'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000195)
,p_name=>'P23_NEW_AGENT'
,p_item_sequence=>91
,p_item_plug_id=>wwv_flow_imp.id(91820267000000181)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000196)
,p_plug_name=>'تعليمات تثبيت الوكيل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P23_NEW_KEY is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    l := noona_dms_agent_pkg.setup_html(:P23_NEW_AGENT, :P23_NEW_KEY);',
'    apex_util.set_session_state(''P23_NEW_KEY'', null);',
'    return l;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000197)
,p_plug_name=>'وكلاء التخزين المحلي'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الوكيل برنامج صغير يثبت على جهاز أو خادم داخل الشركة (Windows أو Linux) ويحفظ ملفات الأرشيف على أقراصها. هو من يتصل بالنظام فلا يلزم فتح منفذ في شبكة الشركة. الملف لا يحذف من النظام إلا بعد أن يؤكد الوكيل حفظه بنفس البصمة، وعند العرض يجلب منه خلال ثوانٍ. إن كان الوكيل غير متصل تبقى الملفات الجديدة في النظام حتى يعود.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000198)
,p_plug_name=>'حالة الوكلاء'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dms_agent_pkg.agents_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000199)
,p_name=>'P23_AGENT_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000197)
,p_prompt=>'اسم الوكيل الجديد'
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
 p_id=>wwv_flow_imp.id(91820267000000200)
,p_name=>'P23_ACT_AGENT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000197)
,p_prompt=>'الوكيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name d, id r from dms_storage_agent where company_id = noona_dms_pkg.company order by name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر للإجراءات -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000201)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000197)
,p_button_name=>'ADD_AGENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة وكيل وإصدار مفتاحه'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000202)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820267000000197)
,p_button_name=>'NEW_KEY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'مفتاح جديد للوكيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000203)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820267000000197)
,p_button_name=>'DISABLE_AGENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إيقاف الوكيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000204)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820267000000197)
,p_button_name=>'ENABLE_AGENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تفعيل الوكيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000205)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Agent'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P23_NEW_KEY := noona_dms_agent_pkg.create_agent(:P23_AGENT_NAME);',
'    select max(id) into :P23_NEW_AGENT from dms_storage_agent where company_id = noona_dms_pkg.company and name = trim(:P23_AGENT_NAME);',
'    :P23_AGENT_NAME := null;',
'    apex_application.g_print_success_message := ''تمت إضافة الوكيل؛ انسخ المفتاح وتعليمات التثبيت أدناه'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000201)
,p_internal_uid=>91820267000000205
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000206)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'New Key'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P23_ACT_AGENT is null then raise_application_error(-20500, ''NOONA-DMS-165: اختر الوكيل أولاً''); end if;',
'    :P23_NEW_KEY := noona_dms_agent_pkg.new_key(:P23_ACT_AGENT);',
'    :P23_NEW_AGENT := :P23_ACT_AGENT;',
'    apex_application.g_print_success_message := ''تم إصدار مفتاح جديد وتوقف القديم؛ حدّث ملف إعدادات الوكيل'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000202)
,p_internal_uid=>91820267000000206
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000207)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Disable Agent'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dms_agent_pkg.set_status(:P23_ACT_AGENT, ''DISABLED'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000203)
,p_process_success_message=>'تم إيقاف الوكيل'
,p_internal_uid=>91820267000000207
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000208)
,p_process_sequence=>70
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Enable Agent'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dms_agent_pkg.set_status(:P23_ACT_AGENT, ''ACTIVE'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000204)
,p_process_success_message=>'تم تفعيل الوكيل'
,p_internal_uid=>91820267000000208
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000209)
,p_branch_action=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
