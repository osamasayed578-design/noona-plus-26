prompt --application/pages/page_00009
begin
--   Manifest
--     PAGE: 00009
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
 p_id=>9
,p_name=>'Signups'
,p_alias=>'SIGNUPS'
,p_step_title=>'طلبات التسجيل الذاتي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820265000000003)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000220)
,p_plug_name=>'تأكيد التحويل أو رفض الطلب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">العميل يسجل بنفسه من صفحة الدخول فتنشأ مؤسسته فوراً بتجربة 14 يوماً. الخطة المدفوعة بالتحويل البنكي تبقى «بانتظار تأكيد التحويل» حتى تتأكد من وصول المبلغ فتؤكدها هنا، فيتحول اشتراكها للخطة المدفوعة من اليوم.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000221)
,p_name=>'P9_SIGNUP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000220)
,p_prompt=>'الطلب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''#'' || id || '' '' || org_name_ar || '' - '' || plan_code || '' - '' || to_char(amount_due, ''FM999,999,990.00'') || '' ريال'' || nvl2(payment_ref, '' ('' || payment_ref || '')'', '''') d, id r from plt_signup where status_code in (''PAYMENT_PENDING'', ''STARTED'', ''VERIFIED'', ''DETAILS'') order by decode(status_code, ''PAYMENT_PENDING'', 0, 1), id desc'
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
 p_id=>wwv_flow_imp.id(91820265000000222)
,p_name=>'P9_NOTE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000220)
,p_prompt=>'ملاحظة (إلزامية للرفض)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>400
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000223)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000220)
,p_button_name=>'CONFIRM'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تأكيد وصول التحويل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000224)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820265000000220)
,p_button_name=>'REJECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض الطلب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000225)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Confirm'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_signup_pkg.confirm_payment(to_number(:P9_SIGNUP), :P9_NOTE); :P9_SIGNUP := null; :P9_NOTE := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000223)
,p_process_success_message=>'تأكد الدفع وتحول الاشتراك للخطة المدفوعة'
,p_internal_uid=>91820265000000225
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000226)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_signup_pkg.reject_signup(to_number(:P9_SIGNUP), :P9_NOTE); :P9_SIGNUP := null; :P9_NOTE := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000224)
,p_process_success_message=>'رفض الطلب'
,p_internal_uid=>91820265000000226
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000227)
,p_name=>'P9_STATUS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820265000000220)
,p_prompt=>'عرض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بانتظار تأكيد التحويل;PAYMENT_PENDING,تجربة فعالة;PROVISIONED,مدفوع;PAID,غير مكتمل;STARTED,مرفوض;REJECTED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'الكل'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000228)
,p_plug_name=>'الطلبات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_signup_pkg.signups_html(:P9_STATUS);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000229)
,p_plug_name=>'طلبات «اشتراكي» من المؤسسات (تجديد، ترقية، إضافة أنظمة أو مستخدمين)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">عند التأكيد: تفعل الأنظمة المطلوبة وحد المستخدمين، ويجدد الاشتراك (أو يبدأ بالخطة الجديدة من اليوم)، وتصدر فاتورة مبيعات في مؤسستك (BILLING.SELLER_USERNAME) وترسل للعميل بالبريد.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000230)
,p_name=>'P9_REQ'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000229)
,p_prompt=>'الطلب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''#'' || r.id || '' '' || t.name_ar || '' - '' || r.plan_code || '' - '' || to_char(r.amount_due, ''FM999,999,990.00'') || '' ريال'' || nvl2(r.payment_ref, '' ('' || r.payment_ref || '')'', '''') d, r.id r from plt_sub_request r join plt_tenant t on t.id = r.tenant_id where r.status_code = ''PENDING'' order by r.id'
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
 p_id=>wwv_flow_imp.id(91820265000000231)
,p_name=>'P9_RNOTE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000229)
,p_prompt=>'ملاحظة (إلزامية للرفض)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>400
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000232)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000229)
,p_button_name=>'CONFIRM_REQ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تأكيد التحويل وتنفيذ الطلب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000233)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820265000000229)
,p_button_name=>'REJECT_REQ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض الطلب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000234)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Confirm request'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_account_pkg.confirm_request(to_number(:P9_REQ), :P9_RNOTE); :P9_REQ := null; :P9_RNOTE := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000232)
,p_process_success_message=>'نفذ الطلب وأصدرت الفاتورة'
,p_internal_uid=>91820265000000234
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000235)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject request'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_account_pkg.reject_request(to_number(:P9_REQ), :P9_RNOTE); :P9_REQ := null; :P9_RNOTE := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000233)
,p_process_success_message=>'رفض الطلب'
,p_internal_uid=>91820265000000235
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000236)
,p_plug_name=>'طلبات المؤسسات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_account_pkg.requests_html(null);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
