prompt --application/pages/page_00071
begin
--   Manifest
--     PAGE: 00071
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
 p_id=>71
,p_name=>'API Clients'
,p_alias=>'API-CLIENTS'
,p_step_title=>'عملاء API'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000701)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000712)
,p_plug_name=>'العملاء'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_api_pkg.clients_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000713)
,p_plug_name=>'عميل جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">ينشأ لكل عميل حساب خدمة بالدور والشركة المحددين، فتطبق عليه نفس صلاحيات المستخدمين وعزل البيانات. <b>السر يظهر مرة واحدة فقط</b> بعد الإنشاء؛ احفظه في النظام المتكامل.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000714)
,p_name=>'P71_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000713)
,p_prompt=>'اسم العميل / النظام'
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
 p_id=>wwv_flow_imp.id(91820262000000715)
,p_name=>'P71_ROLE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000713)
,p_prompt=>'الدور (الصلاحيات)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from sec_role where status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820262000000716)
,p_name=>'P71_COMPANY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000713)
,p_prompt=>'الشركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(trade_name_ar, legal_name_ar) d, id r from org_company where status_code not in (''CLOSED'', ''ARCHIVED'') and noona_sec_admin_pkg.can_admin_company(id) = ''Y'' order by 1'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000717)
,p_name=>'P71_RATE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000713)
,p_prompt=>'حد الطلبات في الدقيقة'
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
 p_id=>wwv_flow_imp.id(91820262000000718)
,p_name=>'P71_TTL'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000713)
,p_prompt=>'مدة رمز الدخول (دقائق)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000719)
,p_name=>'P71_IPS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820262000000713)
,p_prompt=>'عناوين IP المسموحة (اختياري، مفصولة بفواصل، تقبل *)'
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
 p_id=>wwv_flow_imp.id(91820262000000720)
,p_name=>'P71_DESC'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820262000000713)
,p_prompt=>'الوصف'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>1000
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000722)
,p_validation_name=>'P71_NAME required (CREATE)'
,p_validation_sequence=>9
,p_validation=>'P71_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000721)
,p_associated_item=>wwv_flow_imp.id(91820262000000714)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000723)
,p_validation_name=>'P71_ROLE required (CREATE)'
,p_validation_sequence=>10
,p_validation=>'P71_ROLE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000721)
,p_associated_item=>wwv_flow_imp.id(91820262000000715)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000721)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000713)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء العميل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000724)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P71_RATE := nvl(:P71_RATE, 60);',
'    :P71_TTL := nvl(:P71_TTL, 60);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000724
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000725)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    l := noona_api_pkg.create_client(json_object(''name'' value :P71_NAME, ''role'' value to_number(:P71_ROLE),',
'             ''company'' value to_number(:P71_COMPANY), ''rate'' value to_number(:P71_RATE), ''ttl'' value to_number(:P71_TTL),',
'             ''ips'' value :P71_IPS, ''description'' value :P71_DESC));',
'    apex_application.g_print_success_message := ''تم إنشاء العميل. معرف العميل: '' || json_value(l, ''$.clientId'')',
'        || '' — السر (يظهر مرة واحدة فقط): '' || json_value(l, ''$.clientSecret'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000721)
,p_internal_uid=>91820262000000725
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000726)
,p_plug_name=>'إدارة عميل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000727)
,p_name=>'P71_CLIENT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000726)
,p_prompt=>'العميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || client_id || '')'' d, id r from api_client order by id desc'
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
 p_id=>wwv_flow_imp.id(91820262000000728)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000726)
,p_button_name=>'ROTATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إصدار سر جديد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000729)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000726)
,p_button_name=>'SUSPEND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إيقاف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000730)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000726)
,p_button_name=>'ACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تفعيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000731)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820262000000726)
,p_button_name=>'REVOKE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء نهائي'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000732)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820262000000726)
,p_button_name=>'TOKENS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء رموز الدخول'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000733)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Rotate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l varchar2(200);',
'begin',
'    l := noona_api_pkg.rotate_secret(:P71_CLIENT);',
'    apex_application.g_print_success_message := ''السر الجديد (يظهر مرة واحدة فقط، والسر القديم ورموزه ألغيت): '' || l;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000728)
,p_internal_uid=>91820262000000733
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000734)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Suspend'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_api_pkg.set_client_status(:P71_CLIENT, ''SUSPENDED'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000729)
,p_process_success_message=>'تم إيقاف العميل وإلغاء رموزه'
,p_internal_uid=>91820262000000734
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000735)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Activate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_api_pkg.set_client_status(:P71_CLIENT, ''ACTIVE'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000730)
,p_process_success_message=>'تم تفعيل العميل'
,p_internal_uid=>91820262000000735
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000736)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Revoke'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_api_pkg.set_client_status(:P71_CLIENT, ''REVOKED'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000731)
,p_process_success_message=>'تم إلغاء العميل نهائياً'
,p_internal_uid=>91820262000000736
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000737)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Tokens'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_api_pkg.revoke_tokens(:P71_CLIENT);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000732)
,p_process_success_message=>'تم إلغاء رموز الدخول الحالية'
,p_internal_uid=>91820262000000737
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000738)
,p_branch_action=>'f?p=&APP_ID.:71:&SESSION.::&DEBUG.:71::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
