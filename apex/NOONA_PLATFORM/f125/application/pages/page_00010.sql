prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
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
 p_id=>10
,p_name=>'Pricing'
,p_alias=>'PRICING'
,p_step_title=>'الأسعار وإعدادات التسجيل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820265000000003)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000229)
,p_plug_name=>'سعر نظام'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">السعر الشهري بالريال قبل الضريبة؛ لا يؤثر على الطلبات السابقة (يحفظ السعر وقت الطلب).</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000230)
,p_name=>'P10_OFF'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000229)
,p_prompt=>'النظام'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' - '' || to_char(monthly_price, ''FM999,990'') || '' ريال'' || case when is_active = ''N'' then '' (موقوف)'' end d, code r from plt_offering order by sort_order'
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
,p_name=>'P10_PRICE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000229)
,p_prompt=>'السعر الشهري الجديد'
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
 p_id=>wwv_flow_imp.id(91820265000000232)
,p_name=>'P10_ACTIVE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820265000000229)
,p_prompt=>'متاح للتسجيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000233)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000229)
,p_button_name=>'SAVE_PRICE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ السعر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000234)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Price'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_signup_pkg.save_offering(:P10_OFF, to_number(:P10_PRICE), nvl(:P10_ACTIVE, ''Y''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000233)
,p_process_success_message=>'حفظ السعر'
,p_internal_uid=>91820265000000234
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000235)
,p_plug_name=>'خصم المدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000236)
,p_name=>'P10_PLAN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000235)
,p_prompt=>'الخطة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' - خصم '' || to_char(discount_pct) || ''%'' d, code r from plt_plan where code <> ''TRIAL'' and is_active = ''Y'' order by decode(code, ''MONTHLY'', 1, ''QUARTERLY'', 2, ''SEMI_ANNUAL'', 3, ''ANNUAL'', 4, 9)'
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
 p_id=>wwv_flow_imp.id(91820265000000237)
,p_name=>'P10_PCT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000235)
,p_prompt=>'الخصم %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820265000000238)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000235)
,p_button_name=>'SAVE_DISC'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ الخصم'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000239)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Discount'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_signup_pkg.save_plan_discount(:P10_PLAN, to_number(:P10_PCT));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000238)
,p_process_success_message=>'حفظ الخصم'
,p_internal_uid=>91820265000000239
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000240)
,p_plug_name=>'إعدادات التسجيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">وضع الرموز DEMO يعرض رمز التحقق على الشاشة (للتجربة المحلية)، وEMAIL يرسله بالبريد عبر APEX (يتطلب ضبط SMTP في APEX). رسائل الجوال تحتاج ربط مزود رسائل.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000241)
,p_name=>'P10_KEY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820265000000240)
,p_prompt=>'الإعداد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '': '' || substr(default_value, 1, 60) d, setting_key r from plt_setting_def where setting_key like ''SIGNUP.%'' order by setting_key'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820265000000242)
,p_name=>'P10_VALUE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820265000000240)
,p_prompt=>'القيمة'
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
 p_id=>wwv_flow_imp.id(91820265000000243)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820265000000240)
,p_button_name=>'SAVE_SET'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ الإعداد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000244)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load setting'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P10_VALUE := noona_signup_pkg.setting(:P10_KEY);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':P10_KEY is not null'
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>91820265000000244
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820265000000245)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setting'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_signup_pkg.save_setting(:P10_KEY, :P10_VALUE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820265000000243)
,p_process_success_message=>'حفظ الإعداد'
,p_internal_uid=>91820265000000245
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000246)
,p_plug_name=>'الأنظمة كما يراها العميل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_signup_pkg.offerings_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000247)
,p_plug_name=>'مثال تسعير: المالية والمخزون، 5 مستخدمين، سنوي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_signup_pkg.quote_html(''FIN:SCM'', 5, ''ANNUAL'');'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
