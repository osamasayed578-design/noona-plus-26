prompt --application/pages/page_00003
begin
--   Manifest
--     PAGE: 00003
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>125
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>3
,p_name=>'Tenant'
,p_alias=>'TENANT'
,p_step_title=>'المؤسسة المشتركة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820265000000003)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// قبل الإرسال: أرقام الوحدات المختارة',
'$(document).on(''apexbeforepagesubmit'', function () {',
'    $s(''P3_MODS'', $(''.nn-mod-cb:checked'').map(function () { return this.value; }).get().join('',''));',
'});'))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000026)
,p_plug_name=>'المؤسسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000027)
,p_name=>'P3_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000028)
,p_name=>'P3_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_prompt=>'المؤسسة'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000029)
,p_name=>'P3_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000030)
,p_name=>'P3_DETAILS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_prompt=>'التفاصيل'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000031)
,p_name=>'P3_NEW_STATUS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_prompt=>'تغيير الحالة إلى'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_ui_pkg.status_label(column_value) d, column_value r from table(sys.odcivarchar2list(''TRIAL'',''PENDING_ACTIVATION'',''ACTIVE'',''GRACE_PERIOD'',''READ_ONLY'',''SUSPENDED'',''ARCHIVED'',''CLOSED''))'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000032)
,p_name=>'P3_REASON'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_prompt=>'السبب (إلزامي لتغيير الحالة والحجز القانوني)'
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
 p_id=>wwv_flow_imp.id(91820265000000033)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_button_name=>'CHANGE_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تغيير الحالة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000034)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_button_name=>'LEGAL_HOLD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تفعيل الحجز القانوني'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000035)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_button_name=>'RELEASE_HOLD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفع الحجز القانوني'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000036)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820265000000026)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000037)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Tenant'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select name_ar || '' ('' || tenant_code || '')'', noona_ui_pkg.status_label(status_code),',
'       country_code || '' · '' || base_currency || '' · '' || deployment_model || '' · منذ '' || to_char(created_at, ''YYYY-MM-DD'')',
'       || case legal_hold when ''Y'' then '' · تحت حجز قانوني'' end',
'  into :P3_NAME, :P3_STATUS, :P3_DETAILS from plt_tenant where id = :P3_ID;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820265000000037
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000038)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Change Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_platform_pkg.change_tenant_status(:P3_ID, :P3_NEW_STATUS, :P3_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000033)
,p_process_success_message=>'تم تغيير حالة المؤسسة'
,p_internal_uid=>91820265000000038
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000039)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Legal Hold'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_platform_pkg.set_legal_hold(:P3_ID, ''Y'', :P3_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000034)
,p_process_success_message=>'تم تفعيل الحجز القانوني'
,p_internal_uid=>91820265000000039
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000040)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Release Hold'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_platform_pkg.set_legal_hold(:P3_ID, ''N'', :P3_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000035)
,p_process_success_message=>'تم رفع الحجز القانوني'
,p_internal_uid=>91820265000000040
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000041)
,p_plug_name=>'حدود الاشتراك (فارغ = بلا حد)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000042)
,p_name=>'P3_MAX_USERS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000041)
,p_prompt=>'الحد الأقصى للمستخدمين'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000043)
,p_name=>'P3_MAX_BRANCHES'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000041)
,p_prompt=>'الحد الأقصى للفروع'
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
 p_id=>wwv_flow_imp.id(91820265000000044)
,p_name=>'P3_MAX_COMPANIES'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820265000000041)
,p_prompt=>'الحد الأقصى للشركات'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000045)
,p_name=>'P3_USAGE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820265000000041)
,p_prompt=>'الاستخدام الحالي'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000046)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000041)
,p_button_name=>'SAVE_LIMITS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الحدود'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000047)
,p_process_sequence=>15
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Limits'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST is null or :REQUEST <> ''SAVE_LIMITS'' then',
'    :P3_MAX_USERS := noona_platform_admin_pkg.tenant_limit(:P3_ID, ''USERS'');',
'    :P3_MAX_BRANCHES := noona_platform_admin_pkg.tenant_limit(:P3_ID, ''BRANCHES'');',
'    :P3_MAX_COMPANIES := noona_platform_admin_pkg.tenant_limit(:P3_ID, ''COMPANIES'');',
'end if;',
':P3_USAGE := noona_platform_admin_pkg.tenant_metric(:P3_ID, ''USERS'') || '' مستخدم · ''',
'    || noona_platform_admin_pkg.tenant_metric(:P3_ID, ''BRANCHES'') || '' فرع · ''',
'    || noona_platform_admin_pkg.tenant_metric(:P3_ID, ''COMPANIES'') || '' شركة'';'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820265000000047
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000048)
,p_process_sequence=>35
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Limits'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_platform_admin_pkg.set_tenant_limit(:P3_ID, ''USERS'', :P3_MAX_USERS);',
'noona_platform_admin_pkg.set_tenant_limit(:P3_ID, ''BRANCHES'', :P3_MAX_BRANCHES);',
'noona_platform_admin_pkg.set_tenant_limit(:P3_ID, ''COMPANIES'', :P3_MAX_COMPANIES);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000046)
,p_process_success_message=>'تم حفظ حدود الاشتراك'
,p_internal_uid=>91820265000000048
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000049)
,p_plug_name=>'الوحدات المشترك فيها'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000050)
,p_name=>'P3_MODS'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820265000000049)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000051)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000049)
,p_button_name=>'SAVE_MODULES'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الاشتراك'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000052)
,p_plug_name=>'خانات الوحدات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_platform_admin_pkg.module_matrix(:P3_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000053)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Modules'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_r varchar2(50);',
'begin',
'    l_r := noona_platform_admin_pkg.set_tenant_modules(:P3_ID, :P3_MODS);',
'    apex_application.g_print_success_message := ''تم حفظ الاشتراك: تفعيل '' || substr(l_r, 1, instr(l_r, '':'') - 1)',
'        || '' وإيقاف '' || substr(l_r, instr(l_r, '':'') + 1);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000051)
,p_internal_uid=>91820265000000053
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000054)
,p_plug_name=>'مسؤولو المؤسسة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_platform_admin_pkg.tenant_admins_html(:P3_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000055)
,p_plug_name=>'إعادة تعيين كلمة مرور (دعم فني)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000056)
,p_name=>'P3_USERNAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000055)
,p_prompt=>'اسم الدخول'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000057)
,p_name=>'P3_PASSWORD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000055)
,p_prompt=>'كلمة المرور الجديدة'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000058)
,p_name=>'P3_PWD_REASON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820265000000055)
,p_prompt=>'رقم طلب الدعم أو السبب'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000059)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000055)
,p_button_name=>'RESET_PASSWORD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تعيين كلمة المرور'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000060)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reset Password'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.platform_set_password(:P3_USERNAME, :P3_PASSWORD, :P3_PWD_REASON);',
':P3_PASSWORD := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000059)
,p_process_success_message=>'تم تعيين كلمة المرور وفك القفل'
,p_internal_uid=>91820265000000060
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000061)
,p_plug_name=>'سلامة سجل التدقيق'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_bad number := noona_platform_admin_pkg.verify_tenant_chain(:P3_ID);',
'begin',
'    if l_bad is null then',
'        return ''<div class="nn-chain is-ok"><span class="fa fa-shield" aria-hidden="true"></span><div><b>سجل تدقيق المؤسسة سليم</b>''',
'            || ''<small>سلسلة التجزئة مطابقة لكل الأحداث</small></div></div>'';',
'    end if;',
'    return ''<div class="nn-chain is-bad"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span><div>''',
'        || ''<b>انقطاع في سلسلة التدقيق</b><small>أول حدث غير مطابق رقم '' || l_bad || ''</small></div></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000062)
,p_plug_name=>'آخر أحداث التدقيق'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>45
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_platform_admin_pkg.audit_html(:P3_ID, 30);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820265000000063)
,p_branch_action=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:3:P3_ID:&P3_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
