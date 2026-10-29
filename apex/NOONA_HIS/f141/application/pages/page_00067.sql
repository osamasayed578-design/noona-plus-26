prompt --application/pages/page_00067
begin
--   Manifest
--     PAGE: 00067
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>141
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>67
,p_name=>'Integrations'
,p_alias=>'INTEGRATIONS'
,p_step_title=>'الربط الإلكتروني (التأمين والوصفات)'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'$(''#P67_URL,#P67_USER,#P67_EMAIL,#P67_WALLET,#P67_KEYH,#P67_PROV,#P67_LCODE'').attr(''dir'', ''ltr'');'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000944)
,p_plug_name=>'قناة ربط'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000945)
,p_name=>'P67_ID'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'تعديل قناة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from his_integration where company_id = noona_his_pkg.company order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- قناة جديدة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000946)
,p_name=>'P67_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
,p_cMaxlength=>30
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
 p_id=>wwv_flow_imp.id(91820275000000947)
,p_name=>'P67_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'الاسم'
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
 p_id=>wwv_flow_imp.id(91820275000000948)
,p_name=>'P67_KIND'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تأمين (أهلية وموافقات ومطالبات);INSURANCE,منصة الوصفات الإلكترونية;ERX'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000949)
,p_name=>'P67_MODE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'طريقة الربط'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:محاكاة للتجربة;SIMULATOR,REST (JSON);REST,بريد إلكتروني;EMAIL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000950)
,p_name=>'P67_URL'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'عنوان الخدمة (REST)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>1000
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
 p_id=>wwv_flow_imp.id(91820275000000951)
,p_name=>'P67_AUTH'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'المصادقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بدون;NONE,مستخدم وكلمة مرور (Basic);BASIC,رمز وصول (Bearer);BEARER,مفتاح API;API_KEY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000952)
,p_name=>'P67_USER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'المستخدم / بريد المرسل'
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
 p_id=>wwv_flow_imp.id(91820275000000953)
,p_name=>'P67_SECRET'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'كلمة المرور أو المفتاح (فارغ = يبقى الحالي)'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000954)
,p_name=>'P67_KEYH'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'ترويسة المفتاح (API key)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
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
 p_id=>wwv_flow_imp.id(91820275000000955)
,p_name=>'P67_PROV'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'رمز المنشأة لدى القناة (Provider ID)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820275000000956)
,p_name=>'P67_EMAIL'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'بريد الجهة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>320
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
 p_id=>wwv_flow_imp.id(91820275000000957)
,p_name=>'P67_TIMEOUT'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'مهلة الاتصال (ثانية)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000958)
,p_name=>'P67_WALLET'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'مسار محفظة الشهادات (اختياري)'
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
 p_id=>wwv_flow_imp.id(91820275000000959)
,p_name=>'P67_STATUS'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,موقوف;INACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000960)
,p_name=>'P67_SECRET_ST'
,p_item_sequence=>150
,p_item_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_prompt=>'السر المحفوظ'
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
 p_id=>wwv_flow_imp.id(91820275000000961)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000962)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000944)
,p_button_name=>'TEST'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'اختبار الاتصال'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000963)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select code, name_ar, kind, link_mode, base_url, auth_type, username, key_header, provider_code, email, timeout_sec, wallet_path, status_code,',
'           case when secret_enc is not null then ''محفوظ (مشفر)'' else ''لا يوجد'' end',
'      into :P67_CODE, :P67_NAME, :P67_KIND, :P67_MODE, :P67_URL, :P67_AUTH, :P67_USER, :P67_KEYH, :P67_PROV, :P67_EMAIL, :P67_TIMEOUT, :P67_WALLET,',
'           :P67_STATUS, :P67_SECRET_ST',
'      from his_integration where id = :P67_ID and company_id = noona_his_pkg.company;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000000963
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000964)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''id'' value to_number(:P67_ID), ''code'' value :P67_CODE, ''name'' value :P67_NAME, ''kind'' value :P67_KIND, ''mode'' value :P67_MODE,',
'           ''url'' value :P67_URL, ''auth'' value :P67_AUTH, ''user'' value :P67_USER, ''secret'' value :P67_SECRET, ''key_header'' value :P67_KEYH,',
'           ''provider'' value :P67_PROV, ''email'' value :P67_EMAIL, ''timeout'' value to_number(:P67_TIMEOUT), ''wallet'' value :P67_WALLET,',
'           ''status'' value :P67_STATUS returning clob) into l_doc from dual;',
'    :P67_ID := noona_his_link_pkg.save_integration(l_doc);',
'    :P67_SECRET := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000961)
,p_process_success_message=>'حفظت القناة'
,p_internal_uid=>91820275000000964
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000965)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Test'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex_application.g_print_success_message := ''نتيجة الاختبار: '' || noona_his_link_pkg.test_connection(:P67_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000962)
,p_internal_uid=>91820275000000965
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000966)
,p_plug_name=>'ربط شركة تأمين أو جهة بالقناة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000967)
,p_name=>'P67_PAYER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000966)
,p_prompt=>'الجهة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_payer where company_id = noona_his_pkg.company order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000968)
,p_name=>'P67_PCH'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000966)
,p_prompt=>'القناة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from his_integration where company_id = noona_his_pkg.company and kind = ''INSURANCE'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- بدون ربط (يدوي) -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000969)
,p_name=>'P67_LCODE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000966)
,p_prompt=>'رمز الجهة لدى القناة (Payer ID)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000970)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000966)
,p_button_name=>'LINK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ الربط'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000971)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Link'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_link_pkg.set_payer_link(:P67_PAYER, to_number(:P67_PCH), :P67_LCODE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000970)
,p_process_success_message=>'حفظ ربط الجهة'
,p_internal_uid=>91820275000000971
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000972)
,p_plug_name=>'القنوات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, i.code, i.name_ar, case i.kind when ''ERX'' then ''وصفات إلكترونية'' else ''تأمين'' end as kind,',
'       case i.link_mode when ''SIMULATOR'' then ''محاكاة'' when ''REST'' then ''REST'' else ''بريد'' end as link_mode, i.base_url, i.provider_code,',
'       (select listagg(y.name_ar || nvl2(y.link_code, '' ('' || y.link_code || '')'', ''''), ''، '') within group (order by y.name_ar) from his_payer y',
'         where y.integration_id = i.id) as payers, i.last_ok_at, i.last_error,',
'       case i.status_code when ''ACTIVE'' then ''نشطة'' else ''موقوفة'' end as status',
'  from his_integration i where i.company_id = noona_his_pkg.company order by i.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'القنوات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000973)
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
,p_internal_uid=>91820275000000973
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000975)
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
 p_id=>wwv_flow_imp.id(91820275000000976)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000977)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'القناة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000978)
,p_db_column_name=>'KIND'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000979)
,p_db_column_name=>'LINK_MODE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000980)
,p_db_column_name=>'BASE_URL'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'العنوان'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000981)
,p_db_column_name=>'PROVIDER_CODE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'رمز المنشأة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000982)
,p_db_column_name=>'PAYERS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الجهات المرتبطة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000983)
,p_db_column_name=>'LAST_OK_AT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'آخر نجاح'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000984)
,p_db_column_name=>'LAST_ERROR'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'آخر خطأ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000985)
,p_db_column_name=>'STATUS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000974)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'974'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:KIND:LINK_MODE:BASE_URL:PROVIDER_CODE:PAYERS:LAST_OK_AT:LAST_ERROR:STATUS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000986)
,p_branch_action=>'f?p=&APP_ID.:67:&SESSION.::&DEBUG.::P67_ID:&P67_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
