prompt --application/pages/page_00091
begin
--   Manifest
--     PAGE: 00091
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
 p_id=>91
,p_name=>'My Subscription'
,p_alias=>'MY-SUBSCRIPTION'
,p_step_title=>'اشتراكي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000868)
,p_plug_name=>'اشتراك المؤسسة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_account_pkg.my_subscription_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000869)
,p_plug_name=>'طلب تجديد أو إضافة أنظمة أو مستخدمين'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">حدد الأنظمة كما تريدها بعد التعديل (المشترك فيها محددة مسبقاً) وعدد المستخدمين والخطة، ثم حوّل المبلغ واكتب مرجع التحويل. نفعل الطلب ونرسل الفاتورة عند تأكيد وصول التحويل.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000870)
,p_name=>'P91_OFF'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000869)
,p_prompt=>'الأنظمة'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'select name_ar || case when monthly_price > 0 then '' ('' || to_char(monthly_price, ''FM999,990'') || '' ريال/شهر)'' else '' (مشمول)'' end d, code r from plt_offering where is_active = ''Y'' order by sort_order'
,p_lov_columns=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000871)
,p_name=>'P91_USERS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000869)
,p_prompt=>'عدد المستخدمين'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000872)
,p_name=>'P91_PLAN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000869)
,p_prompt=>'الخطة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || case when discount_pct > 0 then '' - خصم '' || to_char(discount_pct) || ''%'' end d, code r from plt_plan where is_active = ''Y'' and self_service = ''Y'' and code <> ''TRIAL'' order by decode(code, ''MONTHLY'', 1, ''QUARTERLY'', 2, ''SEMI_ANNUAL'', 3, ''ANNUAL'', 4, 9)'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000873)
,p_name=>'P91_REF'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000869)
,p_prompt=>'مرجع التحويل'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
 p_id=>wwv_flow_imp.id(91820262000000874)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000869)
,p_button_name=>'CALC'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'احسب السعر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000875)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000869)
,p_button_name=>'REQUEST'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال الطلب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000876)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P91_OFF is null then :P91_OFF := noona_account_pkg.tenant_offerings; end if;',
'if :P91_USERS is null then :P91_USERS := nvl(noona_account_pkg.user_limit, 3); end if;',
'if :P91_PLAN is null then :P91_PLAN := ''ANNUAL''; end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000876
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000877)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Request'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'  l := noona_account_pkg.request_change(:P91_OFF, to_number(:P91_USERS), :P91_PLAN, :P91_REF);',
'  :P91_REF := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000875)
,p_process_success_message=>'أرسل الطلب؛ نفعله عند تأكيد التحويل'
,p_internal_uid=>91820262000000877
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000878)
,p_plug_name=>'السعر'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_signup_pkg.quote_html(:P91_OFF, to_number(:P91_USERS), :P91_PLAN);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000879)
,p_plug_name=>'بيانات التحويل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>26
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div class="nn-sgn-bank"><b>حول المبلغ المستحق إلى:</b><br>'' || noona_ui_pkg.esc(noona_signup_pkg.bank_details) || ''</div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000880)
,p_plug_name=>'طلباتي'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000881)
,p_name=>'P91_REQ'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000880)
,p_prompt=>'إلغاء طلب قائم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''#'' || id || '' '' || plan_code || '' - '' || to_char(amount_due, ''FM999,999,990.00'') || '' ريال'' d, id r from plt_sub_request where status_code = ''PENDING'' and tenant_id = noona_account_pkg.tenant order by id desc'
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
 p_id=>wwv_flow_imp.id(91820262000000882)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000880)
,p_button_name=>'CANCEL_REQ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الطلب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000883)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_account_pkg.cancel_request(to_number(:P91_REQ)); :P91_REQ := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000882)
,p_process_success_message=>'ألغي الطلب'
,p_internal_uid=>91820262000000883
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000884)
,p_plug_name=>'الطلبات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_account_pkg.my_requests_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
