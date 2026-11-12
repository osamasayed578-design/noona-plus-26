prompt --application/pages/page_09999
begin
--   Manifest
--     PAGE: 09999
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
 p_id=>9999
,p_name=>'Login Page'
,p_alias=>'LOGIN'
,p_step_title=>'NOONA PLUS - تسجيل الدخول'
,p_warn_on_unsaved_changes=>'N'
,p_first_item=>'AUTO_FIRST_ITEM'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2101157952850466385
,p_page_template_options=>'#DEFAULT#'
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'12'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17759538014443009)
,p_plug_name=>'NOONA PLUS'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2674157997338192145
,p_plug_display_sequence=>10
,p_region_image=>'#APP_FILES#icons/app-icon-512.png'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(17761150100443026)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(17759538014443009)
,p_button_name=>'LOGIN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل الدخول'
,p_button_position=>'NEXT'
,p_button_alignment=>'LEFT'
,p_grid_new_row=>'Y'
,p_grid_new_column=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17760049504443021)
,p_name=>'P9999_USERNAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(17759538014443009)
,p_prompt=>'اسم المستخدم'
,p_placeholder=>'اسم المستخدم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>100
,p_tag_attributes=>'autocomplete="username"'
,p_label_alignment=>'RIGHT'
,p_field_template=>2040785906935475274
,p_item_icon_css_classes=>'fa-user'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17760331831443023)
,p_name=>'P9999_PASSWORD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(17759538014443009)
,p_prompt=>'كلمة المرور'
,p_placeholder=>'كلمة المرور'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>40
,p_cMaxlength=>100
,p_tag_attributes=>'autocomplete="current-password"'
,p_label_alignment=>'RIGHT'
,p_field_template=>2040785906935475274
,p_item_icon_css_classes=>'fa-key'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17760756383443025)
,p_name=>'P9999_REMEMBER'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(17759538014443009)
,p_prompt=>'تذكر اسم المستخدم'
,p_display_as=>'NATIVE_SINGLE_CHECKBOX'
,p_label_alignment=>'RIGHT'
,p_display_when=>'apex_authentication.persistent_cookies_enabled'
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'checked_value', '',
  'unchecked_value', '',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820263000000008)
,p_validation_name=>'NOONA - User Enabled'
,p_validation_sequence=>10
,p_validation=>'return noona_apex_pkg.login_block_reason(:P9999_USERNAME);'
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(17763337713443034)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_INVOKE_API'
,p_process_name=>'Set Username Cookie'
,p_attribute_01=>'PLSQL_PACKAGE'
,p_attribute_03=>'APEX_AUTHENTICATION'
,p_attribute_04=>'SEND_LOGIN_USERNAME_COOKIE'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>17763337713443034
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(17763884753443035)
,p_page_process_id=>wwv_flow_imp.id(17763337713443034)
,p_page_id=>9999
,p_name=>'p_username'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>1
,p_value_type=>'EXPRESSION'
,p_value_language=>'PLSQL'
,p_value=>'lower( :P9999_USERNAME )'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(17764382971443035)
,p_page_process_id=>wwv_flow_imp.id(17763337713443034)
,p_page_id=>9999
,p_name=>'p_consent'
,p_direction=>'IN'
,p_data_type=>'BOOLEAN'
,p_has_default=>false
,p_display_sequence=>2
,p_value_type=>'ITEM'
,p_value=>'P9999_REMEMBER'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(17761445357443028)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_INVOKE_API'
,p_process_name=>'Login'
,p_attribute_01=>'PLSQL_PACKAGE'
,p_attribute_03=>'APEX_AUTHENTICATION'
,p_attribute_04=>'LOGIN'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>17761445357443028
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(17761931521443031)
,p_page_process_id=>wwv_flow_imp.id(17761445357443028)
,p_page_id=>9999
,p_name=>'p_username'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>1
,p_value_type=>'ITEM'
,p_value=>'P9999_USERNAME'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(17762427761443034)
,p_page_process_id=>wwv_flow_imp.id(17761445357443028)
,p_page_id=>9999
,p_name=>'p_password'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>2
,p_value_type=>'ITEM'
,p_value=>'P9999_PASSWORD'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(17762971067443034)
,p_page_process_id=>wwv_flow_imp.id(17761445357443028)
,p_page_id=>9999
,p_name=>'p_set_persistent_auth'
,p_direction=>'IN'
,p_data_type=>'BOOLEAN'
,p_has_default=>true
,p_display_sequence=>3
,p_value_type=>'API_DEFAULT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(17765211531443037)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_SESSION_STATE'
,p_process_name=>'Clear Page(s) Cache'
,p_attribute_01=>'CLEAR_CACHE_CURRENT_PAGE'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>17765211531443037
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(17764879997443037)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Get Username Cookie'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P9999_USERNAME := apex_authentication.get_login_username_cookie;',
':P9999_REMEMBER := case when :P9999_USERNAME is not null then ''Y'' end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>17764879997443037
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000099001)
,p_plug_name=>'NOONA-SIGNUP-LINK'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>90
,p_plug_source=>'<div class="nn-sgn-login-link"><a href="f?p=&APP_ID.:RESET-PASSWORD:0">نسيت كلمة المرور؟</a> · <a href="f?p=&APP_ID.:WELCOME:0">تعرّف على نونا بلس والأسعار</a><br>ليس لديك حساب؟ <a href="f?p=&APP_ID.:SIGNUP:0">أنشئ حساب مؤسستك وجرّب مجاناً 14 يوماً</a></div>'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'Y',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000099002)
,p_plug_name=>'NOONA-LOGIN-SHOWCASE'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>95
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_signup_pkg.login_showcase_html(''f?p='' || :APP_ID || '':SIGNUP:0'', ''f?p='' || :APP_ID || '':WELCOME:0'')',
'  || ''<script>'' || chr(10)',
'  || ''(function(){'' || chr(10)',
'  || ''  var root = document.getElementById(''''nnlShow''''); if (!root) return;'' || chr(10)',
'  || ''  document.body.appendChild(root);   // خارج منطقة الصفحة: يملأ الشاشة بجانب عمود الدخول'' || chr(10)',
'  || ''  document.body.classList.add(''''nnl-page'''');'' || chr(10)',
'  || ''  var reduce = window.matchMedia && window.matchMedia(''''(prefers-reduced-motion: reduce)'''').matches;'' || chr(10)',
'  || ''  var back = null; try { back = JSON.parse(localStorage.getItem(''''nn_back'''') || ''''null''''); } catch (e) {}'' || chr(10)',
'  || ''  var neu = root.querySelector(''''.nnl-new''''), old = root.querySelector(''''.nnl-back'''');'' || chr(10)',
'  || ''  var slides = [].slice.call(root.querySelectorAll(''''.nnl-new .nnl-slide'''')), dots = [].slice.call(root.querySelectorAll(''''.nnl-dot''''));'' || chr(10)',
'  || ''  var cur = 0, timer = null, hold = false;'' || chr(10)',
'  || ''  function show(i){ slides[cur].classList.remove(''''is-on''''); dots[cur] && dots[cur].classList.remove(''''is-on'''');'' || chr(10)',
'  || ''    cur = (i + slides.length) % slides.length; slides[cur].classList.add(''''is-on''''); dots[cur] && dots[cur].classList.add(''''is-on''''); }'' || chr(10)',
'  || ''  function play(){ if (reduce || slides.length < 2) return; clearInterval(timer); timer = setInterval(function(){ if (!hold) show(cur + 1); }, 6000); }'' || chr(10)',
'  || ''  dots.forEach(function(d, i){ d.addEventListener(''''click'''', function(){ show(i); play(); }); });'' || chr(10)',
'  || ''  var box = root.querySelector(''''.nnl-new .nnl-slides'''');'' || chr(10)',
'  || ''  box.addEventListener(''''mouseenter'''', function(){ hold = true; }); box.addEventListener(''''mouseleave'''', function(){ hold = false; });'' || chr(10)',
'  || ''  function count(){ root.querySelectorAll(''''[data-count]'''').forEach(function(b){ var t = +b.getAttribute(''''data-count''''), n = 0, s = Math.max(1, Math.round(t / 30));'' || chr(10)',
'  || ''    if (reduce) { b.textContent = t; return; } var k = setInterval(function(){ n = Math.min(t, n + s); b.textContent = n; if (n >= t) clearInterval(k); }, 40); }); }'' || chr(10)',
'  || ''  function tour(){ old.hidden = true; neu.hidden = false; play(); count(); }'' || chr(10)',
'  || ''  if (back && back.org !== undefined) {'' || chr(10)',
'  || ''    neu.hidden = true; old.hidden = false;'' || chr(10)',
'  || ''    var o = old.querySelector(''''.nnl-org''''); if (back.org) o.textContent = ''''، '''' + back.org;'' || chr(10)',
'  || ''    var subs = (back.subs || []), pick = slides.filter(function(s){ return subs.indexOf(s.getAttribute(''''data-code'''')) < 0 && s.getAttribute(''''data-code'''') !== ''''DOC''''; });'' || chr(10)',
'  || ''    var promo = old.querySelector(''''.nnl-promo'''');'' || chr(10)',
'  || ''    if (pick.length) { var c = pick[Math.floor(Math.random() * pick.length)].cloneNode(true); c.classList.add(''''is-on''''); promo.appendChild(c); }'' || chr(10)',
'  || ''    else { promo.remove(); old.querySelector(''''.nnl-promo-h'''').remove(); }'' || chr(10)',
'  || ''    old.querySelector(''''.nnl-tour'''').addEventListener(''''click'''', function(e){ e.preventDefault(); tour(); });'' || chr(10)',
'  || ''  } else { play(); count(); }'' || chr(10)',
'  || ''})();'' || chr(10)',
'  || ''</script>'' || chr(10)',
';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp.component_end;
end;
/
