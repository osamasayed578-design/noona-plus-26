prompt --application/pages/page_00073
begin
--   Manifest
--     PAGE: 00073
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
 p_id=>73
,p_name=>'Webhooks'
,p_alias=>'WEBHOOKS'
,p_step_title=>'اشتراكات Webhook'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000683)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000726)
,p_plug_name=>'الاشتراكات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_api_pkg.webhooks_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000727)
,p_plug_name=>'اشتراك جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يرسل الحدث POST بصيغة JSON إلى العنوان، مع الترويسات <code dir="ltr">X-Noona-Event</code> و<code dir="ltr">X-Noona-Timestamp</code> و<code dir="ltr">X-Noona-Signature: sha256=HMAC(السر, timestamp.body)</code>. الفشل يعاد بعد 2، 4، 8... دقائق حتى 10 محاولات.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000728)
,p_name=>'P73_EVENT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000727)
,p_prompt=>'الحدث'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:كل الأحداث;*,فاتورة مبيعات مرحلة;SAL_INVOICE.POSTED,تحصيل من عميل;AR_RECEIPT.CREATED,فاتورة مورد مرحلة;AP_INVOICE.POSTED,توقيع عقد بيع وحدة;RE_SALE_CONTRACT.SIGNED,تفعيل عقد إيجار;PRP_LEASE.ACTIVATED,طلب متجر إلكتروني;ORDER.CREATED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000729)
,p_name=>'P73_URL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000727)
,p_prompt=>'عنوان الاستقبال (https://)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>1000
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
 p_id=>wwv_flow_imp.id(91820262000000730)
,p_name=>'P73_DESC'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000727)
,p_prompt=>'الوصف'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000732)
,p_validation_name=>'P73_URL required (CREATE)'
,p_validation_sequence=>5
,p_validation=>'P73_URL'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000731)
,p_associated_item=>wwv_flow_imp.id(91820262000000729)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000731)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000727)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الاشتراك'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000733)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob;',
'begin',
'    l := noona_api_pkg.save_webhook(json_object(''event'' value :P73_EVENT, ''url'' value :P73_URL, ''description'' value :P73_DESC));',
'    apex_application.g_print_success_message := ''تمت إضافة الاشتراك. سر التوقيع (يظهر مرة واحدة فقط): '' || json_value(l, ''$.secret'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000731)
,p_internal_uid=>91820262000000733
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000734)
,p_plug_name=>'إدارة اشتراك'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000735)
,p_name=>'P73_WH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000734)
,p_prompt=>'الاشتراك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select event_type || '' -> '' || target_url d, id r from api_webhook_subscription where status_code <> ''DISABLED'' order by id desc'
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
 p_id=>wwv_flow_imp.id(91820262000000736)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000734)
,p_button_name=>'TEST'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال حدث اختبار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000737)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000734)
,p_button_name=>'PAUSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إيقاف مؤقت'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000738)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000734)
,p_button_name=>'RESUME'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تفعيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000739)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820262000000734)
,p_button_name=>'DISABLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف الاشتراك'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000740)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Test'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_api_pkg.test_webhook(:P73_WH);',
'    l := noona_api_pkg.dispatch(20);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000736)
,p_process_success_message=>'أرسل حدث الاختبار؛ النتيجة في الأحداث الصادرة'
,p_internal_uid=>91820262000000740
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000741)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Pause'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_api_pkg.set_webhook_status(:P73_WH, ''PAUSED'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000737)
,p_process_success_message=>'تم الإيقاف'
,p_internal_uid=>91820262000000741
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000742)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Resume'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_api_pkg.set_webhook_status(:P73_WH, ''ACTIVE'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000738)
,p_process_success_message=>'تم التفعيل'
,p_internal_uid=>91820262000000742
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000743)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Disable'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_api_pkg.set_webhook_status(:P73_WH, ''DISABLED'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000739)
,p_process_success_message=>'تم حذف الاشتراك وإلغاء أحداثه المعلقة'
,p_internal_uid=>91820262000000743
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000744)
,p_branch_action=>'f?p=&APP_ID.:73:&SESSION.::&DEBUG.:73::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
