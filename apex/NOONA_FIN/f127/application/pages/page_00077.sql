prompt --application/pages/page_00077
begin
--   Manifest
--     PAGE: 00077
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
 p_id=>77
,p_name=>'E-Invoicing'
,p_alias=>'EINVOICING'
,p_step_title=>'الفوترة الإلكترونية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000740)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(document).on(''click'', ''.nn-einv-send, .nn-einv-resend'', function () {',
'  $s(''P77_SUB'', $(this).data(''sub''));',
'  apex.submit({ request: $(this).hasClass(''nn-einv-send'') ? ''SEND'' : ''RESEND'', showWait: true });',
'});'))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000852)
,p_plug_name=>'حالة الربط'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_einv_pkg.summary_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000853)
,p_plug_name=>'إعدادات الربط'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_einv_pkg.profiles_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000854)
,p_plug_name=>'إعداد الربط'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">المرحلة الثانية (الربط والتكامل): كل فاتورة مبيعات مرحلة تولد بصيغة UBL 2.1 مع العداد التسلسلي وتجزئة السلسلة ورمز QR، وترسل للاعتماد (الضريبية) أو الإبلاغ (المبسطة). <b>المحاكي</b> يحاكي ردود الهيئة للاختبار. للإنتاج: خدمة التوقيع (REST) توقع بشهادة CSID (ECDSA) وترسل لبوابة فاتورة وتعيد النتيجة والتوقيع.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000855)
,p_name=>'P77_PROFILE'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000856)
,p_name=>'P77_BRANCH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_prompt=>'الفرع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = noona_loc_pkg.company and status_code = ''ACTIVE'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- كل الفروع -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000857)
,p_name=>'P77_ADAPTER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_prompt=>'المحول'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المحاكي (اختبار);SIMULATOR,خدمة التوقيع والبوابة (REST);REST'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000858)
,p_name=>'P77_MODE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_prompt=>'النمط'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:اعتماد للضريبية وإبلاغ للمبسطة;CLEARANCE,إبلاغ فقط;REPORTING'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000859)
,p_name=>'P77_DEVICE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_prompt=>'معرف وحدة الفوترة (EGS)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820266000000860)
,p_name=>'P77_ENDPOINT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_prompt=>'عنوان خدمة التوقيع (https://...)'
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
 p_id=>wwv_flow_imp.id(91820266000000861)
,p_name=>'P77_CERT'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_prompt=>'مرجع الشهادة (CSID) في خدمة التوقيع'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820266000000862)
,p_name=>'P77_SANDBOX'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_prompt=>'البيئة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:اختبار (Sandbox);Y,إنتاج;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000863)
,p_name=>'P77_STATUS'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:فعال;ACTIVE,قيد الربط;ONBOARDING,موقوف;SUSPENDED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000864)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000854)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الإعداد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000865)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select max(id) into :P77_PROFILE from loc_einvoice_profile where company_id = noona_loc_pkg.company;',
'    if :P77_PROFILE is not null then',
'        select branch_id, adapter_code, integration_mode, device_id, endpoint_ref, certificate_ref, is_sandbox, status_code',
'          into :P77_BRANCH, :P77_ADAPTER, :P77_MODE, :P77_DEVICE, :P77_ENDPOINT, :P77_CERT, :P77_SANDBOX, :P77_STATUS',
'          from loc_einvoice_profile where id = :P77_PROFILE;',
'    end if;',
'    :P77_ADAPTER := nvl(:P77_ADAPTER, ''SIMULATOR''); :P77_MODE := nvl(:P77_MODE, ''CLEARANCE'');',
'    :P77_SANDBOX := nvl(:P77_SANDBOX, ''Y''); :P77_STATUS := nvl(:P77_STATUS, ''ACTIVE'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000865
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000866)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_einv_pkg.save_profile(json_object(''id'' value to_number(:P77_PROFILE), ''branch'' value to_number(:P77_BRANCH),',
'              ''adapter'' value :P77_ADAPTER, ''mode'' value :P77_MODE, ''device'' value :P77_DEVICE, ''endpoint'' value :P77_ENDPOINT,',
'              ''certificate'' value :P77_CERT, ''sandbox'' value :P77_SANDBOX, ''status'' value :P77_STATUS));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000864)
,p_process_success_message=>'تم حفظ إعداد الفوترة الإلكترونية'
,p_internal_uid=>91820266000000866
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000867)
,p_plug_name=>'طابور الإرسال'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000868)
,p_name=>'P77_SUB'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000867)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000869)
,p_name=>'P77_FILTER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000867)
,p_prompt=>'عرض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بانتظار الإرسال أو بها مشكلة;OPEN,معتمدة;CLEARED,مبلغة;ACCEPTED,مرفوضة;REJECTED,فشل التحقق;VALIDATION_FAILED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الكل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000870)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000867)
,p_button_name=>'GO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000871)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000867)
,p_button_name=>'PROCESS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال كل المعلق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000872)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_einv_pkg.process_queue;',
'    apex_application.g_print_success_message := ''تمت معالجة '' || l_n || '' إرسال'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000871)
,p_internal_uid=>91820266000000872
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000873)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Send'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_einv_pkg.submit(to_number(:P77_SUB));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''SEND'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'تم الإرسال'
,p_internal_uid=>91820266000000873
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000874)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Resend'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_einv_pkg.resubmit(to_number(:P77_SUB));',
'    noona_einv_pkg.submit(l_id);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''RESEND'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'تمت إعادة الإرسال'
,p_internal_uid=>91820266000000874
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000875)
,p_plug_name=>'الإرسالات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_einv_pkg.queue_html(:P77_FILTER, replace(apex_page.get_url(p_page => 78, p_items => ''P78_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000876)
,p_branch_action=>'f?p=&APP_ID.:77:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
