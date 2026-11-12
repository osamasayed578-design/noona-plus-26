prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>115
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>'Signup'
,p_alias=>'SIGNUP'
,p_step_title=>'إنشاء حساب مؤسسة - نونا بلس'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_step_template=>2977628563533209425
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000024)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Step'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P20_STEP := noona_signup_pkg.step(:P20_TOKEN);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820263000000024
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000025)
,p_plug_name=>'رأس الموقع'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<header class="nnw-top"><div class="nnw-wrap nnw-top-in"><a class="nnw-logo" href="f?p=&APP_ID.:WELCOME:&SESSION."><img src="#APP_FILES#noona-logo.svg" alt="">نونا بلس</a><nav class="nnw-nav"><a href="f?p=&APP_ID.:WELCOME:&SESSION.#features">المزايا</a><a href="f?p=&APP_ID.:WELCOME:&SESSION.#systems">الأنظمة</a><a href="f?p=&APP_ID.:WELCOME:&SESSION.#pricing">الأسعار</a><a href="f?p=&APP_ID.:WELCOME:&SESSION.#faq">الأسئلة</a></nav><div class="nnw-act"><a class="nnw-link" href="f?p=&APP_ID.:1:&SESSION.">تسجيل الدخول</a><a class="nnw-btn nnw-btn-primary" href="f?p=&APP_ID.:SIGNUP:&SESSION.">ابدأ مجاناً</a></div></div></header>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000026)
,p_plug_name=>'الخطوات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_s number := nvl(:P20_STEP, 1); l_h varchar2(4000);',
'begin',
'  l_h := ''<div class="nn-sgn-hero"><div><h1>أنشئ حساب مؤسستك</h1>''',
'      || ''<p>خمس خطوات وتبدأ تجربتك المجانية 14 يوماً بكل الأنظمة التي تختارها.</p></div></div>''',
'      || ''<ol class="nn-sgn-steps">'';',
'  for i in 1 .. 5 loop',
'    l_h := l_h || ''<li class="'' || case when i < l_s then ''is-done'' when i = l_s then ''is-current'' end || ''"><span>'' || i || ''</span>''',
'        || case i when 1 then ''الحساب'' when 2 then ''التحقق'' when 3 then ''المؤسسة'' when 4 then ''الأنظمة والخطة'' else ''جاهز'' end || ''</li>'';',
'  end loop;',
'  return l_h || ''</ol>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000027)
,p_plug_name=>'بيانات حسابك'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">ستكون مسؤول مؤسستك في النظام، وتضيف بقية المستخدمين بعد الدخول. سنرسل رمز تحقق إلى بريدك وجوالك.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 1'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000028)
,p_name=>'P20_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_prompt=>'الاسم الكامل'
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
 p_id=>wwv_flow_imp.id(91820263000000029)
,p_name=>'P20_EMAIL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_prompt=>'البريد الإلكتروني'
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
 p_id=>wwv_flow_imp.id(91820263000000030)
,p_name=>'P20_MOBILE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_prompt=>'رقم الجوال (05xxxxxxxx)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000031)
,p_name=>'P20_USERNAME'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_prompt=>'اسم الدخول (بالإنجليزية)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
 p_id=>wwv_flow_imp.id(91820263000000032)
,p_name=>'P20_PWD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_prompt=>'كلمة المرور (10 أحرف: كبير وصغير ورقم)'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000033)
,p_name=>'P20_PWD2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_prompt=>'تأكيد كلمة المرور'
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
 p_id=>wwv_flow_imp.id(91820263000000034)
,p_name=>'P20_TERMS'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_prompt=>'الشروط'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'STATIC2:أوافق على شروط الاستخدام وسياسة الخصوصية وحماية البيانات الشخصية;Y'
,p_lov_columns=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000035)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_button_name=>'START'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الحساب وإرسال الرمز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000036)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Start'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P20_PWD is null or :P20_PWD <> nvl(:P20_PWD2, ''#'') then',
'    raise_application_error(-20500, ''NOONA-SGN-028: كلمة المرور وتأكيدها غير متطابقين'');',
'  end if;',
'  :P20_TOKEN := noona_signup_pkg.start_signup(:P20_NAME, :P20_EMAIL, :P20_MOBILE, :P20_USERNAME, :P20_PWD, nvl(:P20_TERMS, ''N''),',
'                                             owa_util.get_cgi_env(''REMOTE_ADDR''));',
'  :P20_DEMO := noona_signup_pkg.demo_message;',
'  :P20_PWD := null; :P20_PWD2 := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000035)
,p_internal_uid=>91820263000000036
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000037)
,p_plug_name=>'التحقق'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 2'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000038)
,p_plug_name=>'الرمز'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>21
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 2'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<p class="nn-hint">أدخل الرمز المرسل إلى <b dir="ltr">'' || noona_ui_pkg.esc(noona_signup_pkg.field(:P20_TOKEN, ''EMAIL''))',
'  || ''</b> و <b dir="ltr">'' || noona_ui_pkg.esc(noona_signup_pkg.field(:P20_TOKEN, ''MOBILE'')) || ''</b>. صالح 10 دقائق.</p>''',
'  || case when :P20_DEMO is not null then ''<div class="nn-sgn-demo">'' || noona_ui_pkg.esc(:P20_DEMO) || ''</div>'' end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000039)
,p_name=>'P20_ECODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820263000000037)
,p_prompt=>'رمز البريد'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>10
,p_cMaxlength=>6
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000040)
,p_name=>'P20_MCODE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820263000000037)
,p_prompt=>'رمز الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>10
,p_cMaxlength=>6
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
 p_id=>wwv_flow_imp.id(91820263000000041)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820263000000037)
,p_button_name=>'VERIFY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تحقق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000042)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820263000000037)
,p_button_name=>'RESEND'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إعادة إرسال الرمز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000043)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Verify'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_signup_pkg.verify(:P20_TOKEN, :P20_ECODE, :P20_MCODE); :P20_DEMO := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000041)
,p_internal_uid=>91820263000000043
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000044)
,p_process_sequence=>25
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Resend'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_signup_pkg.resend(:P20_TOKEN); :P20_DEMO := noona_signup_pkg.demo_message;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000042)
,p_process_success_message=>'أرسلنا رمزاً جديداً'
,p_internal_uid=>91820263000000044
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000045)
,p_plug_name=>'بيانات المؤسسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">البيانات الأساسية فقط؛ تستكمل الفروع والهيكل والأرصدة بعد الدخول من «بدء التشغيل ونقل البيانات».</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 3'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000046)
,p_name=>'P20_ORG'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820263000000045)
,p_prompt=>'اسم المؤسسة (عربي)'
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
 p_id=>wwv_flow_imp.id(91820263000000047)
,p_name=>'P20_ORG_EN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820263000000045)
,p_prompt=>'الاسم بالإنجليزية (اختياري)'
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
 p_id=>wwv_flow_imp.id(91820263000000048)
,p_name=>'P20_COUNTRY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820263000000045)
,p_prompt=>'الدولة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:السعودية;SA,الإمارات;AE,البحرين;BH,عُمان;OM,قطر;QA,الكويت;KW,مصر;EG,السودان;SD'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000049)
,p_name=>'P20_CR'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820263000000045)
,p_prompt=>'السجل التجاري'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>20
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
 p_id=>wwv_flow_imp.id(91820263000000050)
,p_name=>'P20_VAT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820263000000045)
,p_prompt=>'الرقم الضريبي (15 رقماً)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000051)
,p_name=>'P20_CITY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820263000000045)
,p_prompt=>'المدينة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000052)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820263000000045)
,p_button_name=>'SAVE_ORG'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'التالي'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000053)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Org'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_signup_pkg.save_org(:P20_TOKEN, :P20_ORG, :P20_ORG_EN, :P20_COUNTRY, :P20_CR, :P20_VAT, :P20_CITY);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000052)
,p_internal_uid=>91820263000000053
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000054)
,p_plug_name=>'الأنظمة المتاحة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>38
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 4'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_signup_pkg.offerings_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000055)
,p_plug_name=>'اختر أنظمتك وخطتك'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 4'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000056)
,p_name=>'P20_OFF'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820263000000055)
,p_prompt=>'الأنظمة'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'select name_ar || case when monthly_price > 0 then '' ('' || to_char(monthly_price, ''FM999,990'') || '' ريال/شهر)'' else '' (مشمول)'' end d, code r from plt_offering where is_active = ''Y'' order by sort_order'
,p_lov_columns=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000057)
,p_name=>'P20_USERS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820263000000055)
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
 p_id=>wwv_flow_imp.id(91820263000000058)
,p_name=>'P20_PLAN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820263000000055)
,p_prompt=>'الخطة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select case code when ''TRIAL'' then ''تجربة مجانية 14 يوماً (بلا دفع)'' else name_ar end || case when discount_pct > 0 then '' - خصم '' || to_char(discount_pct) || ''%'' end d, code r from plt_plan where is_active = ''Y'' and self_service = ''Y'' order by decode(code, ''TRIAL'', 0, ''MONTHLY'', 1, ''QUARTERLY'', 2, ''SEMI_ANNUAL'', 3, ''ANNUAL'', 4, 9)'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000059)
,p_name=>'P20_PAY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820263000000055)
,p_prompt=>'طريقة الدفع (للخطة المدفوعة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تحويل بنكي;BANK_TRANSFER,بطاقة (قريباً);CARD'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000060)
,p_name=>'P20_REF'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820263000000055)
,p_prompt=>'رقم/مرجع التحويل (إن حولت)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000061)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820263000000055)
,p_button_name=>'CALC'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'احسب السعر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820263000000062)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820263000000055)
,p_button_name=>'FINISH'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء مؤسستي'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000063)
,p_process_sequence=>6
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P20_USERS is null then :P20_USERS := 3; end if;',
'if :P20_PLAN is null then :P20_PLAN := ''TRIAL''; end if;',
'if :P20_OFF is null then :P20_OFF := ''FIN:DOC''; end if;',
'if :P20_COUNTRY is null then :P20_COUNTRY := ''SA''; end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820263000000063
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000064)
,p_plug_name=>'السعر'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>45
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 4'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_signup_pkg.quote_html(:P20_OFF, to_number(:P20_USERS), :P20_PLAN);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000065)
,p_plug_name=>'بيانات التحويل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>46
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 4 and :P20_PLAN <> ''TRIAL'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div class="nn-sgn-bank"><b>حول المبلغ المستحق إلى:</b><br>'' || noona_ui_pkg.esc(noona_signup_pkg.bank_details)',
'  || ''<br><small>تبدأ مؤسستك فوراً بتجربة، وتتحول للاشتراك المدفوع عند تأكيد التحويل.</small></div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820263000000066)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Finish'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  noona_signup_pkg.save_plan(:P20_TOKEN, :P20_OFF, to_number(:P20_USERS), :P20_PLAN, :P20_PAY, :P20_REF);',
'  :P20_DONE_USER := noona_signup_pkg.finish(:P20_TOKEN);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820263000000062)
,p_internal_uid=>91820263000000066
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000067)
,p_plug_name=>'مؤسستك جاهزة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_STEP = 5'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div class="nn-sgn-done"><span class="fa fa-check-circle"></span><h2>تم إنشاء مؤسستك</h2>''',
'  || ''<p>ادخل باسم الدخول <b dir="ltr">'' || noona_ui_pkg.esc(noona_signup_pkg.field(:P20_TOKEN, ''USERNAME''))',
'  || ''</b> وكلمة المرور التي اخترتها، ثم ابدأ من «إدارة المؤسسة ← بدء التشغيل ونقل البيانات».</p>''',
'  || case when noona_signup_pkg.field(:P20_TOKEN, ''STATUS'') = ''PAYMENT_PENDING''',
'          then ''<p class="nn-hint">المستحق '' || noona_signup_pkg.field(:P20_TOKEN, ''TOTAL'') || '' ريال؛ تعمل مؤسستك الآن بتجربة حتى يؤكد فريقنا التحويل.</p>'' end',
'  || ''<a class="t-Button t-Button--hot t-Button--large" href="f?p='' || :APP_ID || '':1:0">الدخول إلى النظام</a></div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000068)
,p_name=>'P20_TOKEN'
,p_item_sequence=>900
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000069)
,p_name=>'P20_STEP'
,p_item_sequence=>900
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000070)
,p_name=>'P20_DEMO'
,p_item_sequence=>900
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820263000000071)
,p_name=>'P20_DONE_USER'
,p_item_sequence=>900
,p_item_plug_id=>wwv_flow_imp.id(91820263000000027)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820263000000072)
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
