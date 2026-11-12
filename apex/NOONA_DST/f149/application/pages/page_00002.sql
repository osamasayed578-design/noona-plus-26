prompt --application/pages/page_00002
begin
--   Manifest
--     PAGE: 00002
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>2
,p_name=>'Visit'
,p_alias=>'VISIT'
,p_step_title=>'زيارة محل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'window.DST_METHODS = [{item:''P2_SM'',ref:''P2_SREF'',bank:''P2_SBANK'',chq:''P2_SCHQ''},{item:''P2_CM'',ref:''P2_CREF'',bank:''P2_CBANK'',chq:''P2_CCHQ''}];',
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''dst.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000019)
,p_plug_name=>'بيانات الزيارة'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000020)
,p_name=>'P2_SHOP'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000019)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000021)
,p_name=>'P2_VISIT'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820300000000019)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000022)
,p_name=>'P2_LAT'
,p_item_sequence=>3
,p_item_plug_id=>wwv_flow_imp.id(91820300000000019)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000023)
,p_name=>'P2_LNG'
,p_item_sequence=>4
,p_item_plug_id=>wwv_flow_imp.id(91820300000000019)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000024)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Visit'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_v number := noona_dst_pkg.open_visit(noona_dst_pkg.my_rep);',
'begin',
'  :P2_VISIT := null;',
'  for v in (select id from dst_visit where id = l_v and shop_id = :P2_SHOP) loop :P2_VISIT := v.id; end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820300000000024
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000025)
,p_plug_name=>'المحل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.shop_card_html(:P2_SHOP);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000026)
,p_plug_name=>'زيارة جارية لمحل آخر'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>6
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is null and noona_dst_pkg.open_visit(noona_dst_pkg.my_rep) is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_v number := noona_dst_pkg.open_visit(noona_dst_pkg.my_rep);',
'begin',
'  for v in (select shop_id from dst_visit where id = l_v) loop',
'    return ''<p class="nn-hint">لديك زيارة جارية في <b>'' || apex_escape.html(noona_dst_pkg.shop_label(v.shop_id)) || ''</b>. أنهِها أولاً.</p>''',
'        || ''<a class="nn-dst-btn nn-dst-go" href="'' || apex_page.get_url(p_page => 2, p_items => ''P2_SHOP'', p_values => v.shop_id) || ''">الانتقال للزيارة الجارية</a>'';',
'  end loop;',
'  return null;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000027)
,p_plug_name=>'تسجيل الوصول'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>7
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<button type="button" class="nn-dst-btn nn-dst-checkin" data-lat="P2_LAT" data-lng="P2_LNG" data-req="CHECKIN"><span class="fa fa-map-marker"></span> تسجيل الوصول</button><p class="nn-hint">يسجل وقت الوصول وموقعك ويحسب بعدك عن موقع المحل. أول زيارة لمحل بلا موقع تحفظ موقعه للتوزيع التالي.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is null and noona_dst_pkg.open_visit(noona_dst_pkg.my_rep) is null and noona_dst_pkg.my_rep is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000028)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Check-in'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t();',
'begin',
'  l.put(''shop'', to_number(:P2_SHOP)); l.put(''lat'', to_number(:P2_LAT)); l.put(''lng'', to_number(:P2_LNG));',
'  :P2_VISIT := noona_dst_pkg.start_visit(l.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST = ''CHECKIN'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'تم تسجيل الوصول'
,p_internal_uid=>91820300000000028
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000029)
,p_plug_name=>'الزيارة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.visit_html(:P2_VISIT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000030)
,p_plug_name=>'بيع من السيارة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000031)
,p_plug_name=>'أصناف السيارة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>21
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div data-item="P2_LINES">'' || noona_dst_pkg.items_picker_html(noona_dst_pkg.my_rep, ''SALE'') || ''</div><span data-dst-total="0" hidden></span>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000032)
,p_plug_name=>'الدفع عند البيع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>22
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">اترك المبلغ فارغاً للبيع الآجل ضمن حد المحل، أو <a href="#" class="nn-dst-fill" data-target="P2_SAMT">ادفع الإجمالي كاملاً</a>. النقد والشبكة يرحلان فوراً؛ التحويل والشيك بعد تأكيد المحاسب.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000033)
,p_name=>'P2_LINES'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000032)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000034)
,p_name=>'P2_SM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000032)
,p_prompt=>'طريقة الدفع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نقداً;CASH,تحويل بنكي (رقم الإشعار);BANK_TRANSFER,شيك;CHEQUE,شبكة / بطاقة;CARD,محفظة إلكترونية;WALLET'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000035)
,p_name=>'P2_SAMT'
,p_item_sequence=>11
,p_item_plug_id=>wwv_flow_imp.id(91820300000000032)
,p_prompt=>'المبلغ المدفوع'
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
 p_id=>wwv_flow_imp.id(91820300000000036)
,p_name=>'P2_SREF'
,p_item_sequence=>12
,p_item_plug_id=>wwv_flow_imp.id(91820300000000032)
,p_prompt=>'رقم المرجع'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>24
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
 p_id=>wwv_flow_imp.id(91820300000000037)
,p_name=>'P2_SBANK'
,p_item_sequence=>13
,p_item_plug_id=>wwv_flow_imp.id(91820300000000032)
,p_prompt=>'البنك المحول منه / بنك الشيك'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>24
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
 p_id=>wwv_flow_imp.id(91820300000000038)
,p_name=>'P2_SCHQ'
,p_item_sequence=>14
,p_item_plug_id=>wwv_flow_imp.id(91820300000000032)
,p_prompt=>'تاريخ استحقاق الشيك'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000039)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000032)
,p_button_name=>'SALE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إصدار الفاتورة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000040)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Sale'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t(); l_p json_object_t; l_id number;',
'begin',
'  l.put(''visit'', to_number(:P2_VISIT));',
'  l.put(''lines'', json_array_t(nvl(:P2_LINES, ''[]'')));',
'  l_p := json_object_t();
  l_p.put(''method'', nvl(:P2_SM, ''CASH'')); l_p.put(''amount'', to_number(:P2_SAMT)); l_p.put(''ref'', :P2_SREF);
  l_p.put(''bank'', :P2_SBANK); l_p.put(''chequeDate'', :P2_SCHQ);',
'  if to_number(:P2_SAMT) > 0 then l.put(''pay'', l_p); end if;',
'  l_id := noona_dst_pkg.visit_sale(l.to_clob);',
'  :P2_LINES := null; :P2_SAMT := null; :P2_SREF := null; :P2_SBANK := null; :P2_SCHQ := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000039)
,p_process_success_message=>'تم إصدار الفاتورة. أرسلها للمحل بواتساب من الأسفل.'
,p_internal_uid=>91820300000000040
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000041)
,p_plug_name=>'تحصيل من الرصيد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000042)
,p_name=>'P2_CINV'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820300000000041)
,p_prompt=>'الفاتورة المسددة (اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select i.doc_no || '' · '' || to_char(i.doc_date, ''YYYY-MM-DD'') || '' · '' || to_char(i.total_amount, ''FM999G999G990D00'') d, i.id r from sal_invoice i join dst_shop s on s.customer_account_id = i.customer_account_id where s.id = :P2_SHOP and i.status_code = ''POSTED'' and i.doc_type in (''INVOICE'', ''SIMPLIFIED_INVOICE'') and exists (select 1 from ar_open_item o where o.source_entity_id = i.id and o.source_entity_type = ''SAL_INVOICE'' and o.status_code in (''OPEN'', ''PARTIALLY_PAID'')) order by i.id desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- أقدم الفواتير أولاً -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000043)
,p_name=>'P2_CM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000041)
,p_prompt=>'طريقة الدفع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نقداً;CASH,تحويل بنكي (رقم الإشعار);BANK_TRANSFER,شيك;CHEQUE,شبكة / بطاقة;CARD,محفظة إلكترونية;WALLET'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000044)
,p_name=>'P2_CAMT'
,p_item_sequence=>11
,p_item_plug_id=>wwv_flow_imp.id(91820300000000041)
,p_prompt=>'المبلغ المحصل'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000045)
,p_name=>'P2_CREF'
,p_item_sequence=>12
,p_item_plug_id=>wwv_flow_imp.id(91820300000000041)
,p_prompt=>'رقم المرجع'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>24
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
 p_id=>wwv_flow_imp.id(91820300000000046)
,p_name=>'P2_CBANK'
,p_item_sequence=>13
,p_item_plug_id=>wwv_flow_imp.id(91820300000000041)
,p_prompt=>'البنك المحول منه / بنك الشيك'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>24
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
 p_id=>wwv_flow_imp.id(91820300000000047)
,p_name=>'P2_CCHQ'
,p_item_sequence=>14
,p_item_plug_id=>wwv_flow_imp.id(91820300000000041)
,p_prompt=>'تاريخ استحقاق الشيك'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000048)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000041)
,p_button_name=>'COLLECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل التحصيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000049)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Collect'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t; l_p json_object_t; l_id number;',
'begin',
'  l_p := json_object_t();
  l_p.put(''method'', nvl(:P2_CM, ''CASH'')); l_p.put(''amount'', to_number(:P2_CAMT)); l_p.put(''ref'', :P2_CREF);
  l_p.put(''bank'', :P2_CBANK); l_p.put(''chequeDate'', :P2_CCHQ);',
'  l := l_p; l.put(''visit'', to_number(:P2_VISIT)); l.put(''invoice'', to_number(:P2_CINV));',
'  l_id := noona_dst_pkg.collect(l.to_clob);',
'  :P2_CAMT := null; :P2_CREF := null; :P2_CBANK := null; :P2_CCHQ := null; :P2_CINV := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000048)
,p_process_success_message=>'تم تسجيل التحصيل'
,p_internal_uid=>91820300000000049
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000050)
,p_plug_name=>'طلبية مسبقة (توريد لاحق)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000051)
,p_plug_name=>'أصناف الطلبية'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>41
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div data-item="P2_OLINES">'' || noona_dst_pkg.items_picker_html(noona_dst_pkg.my_rep, ''ORDER'') || ''</div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000052)
,p_plug_name=>'تسليم الطلبية'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>42
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000053)
,p_name=>'P2_OLINES'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000052)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000054)
,p_name=>'P2_ODATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000052)
,p_prompt=>'تاريخ التسليم المطلوب'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000055)
,p_name=>'P2_ONOTES'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000052)
,p_prompt=>'ملاحظات الطلبية'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000056)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000052)
,p_button_name=>'ORDER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إرسال الطلبية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000057)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Order'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t(); l_id number;',
'begin',
'  l.put(''visit'', to_number(:P2_VISIT)); l.put(''lines'', json_array_t(nvl(:P2_OLINES, ''[]'')));',
'  l.put(''date'', :P2_ODATE); l.put(''notes'', :P2_ONOTES);',
'  l_id := noona_dst_pkg.place_order(l.to_clob);',
'  :P2_OLINES := null; :P2_ODATE := null; :P2_ONOTES := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000056)
,p_process_success_message=>'تم إرسال الطلبية للتوريد'
,p_internal_uid=>91820300000000057
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000058)
,p_plug_name=>'مرتجع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000059)
,p_name=>'P2_RINV'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820300000000058)
,p_prompt=>'فاتورة المرتجع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select i.doc_no || '' · '' || to_char(i.doc_date, ''YYYY-MM-DD'') || '' · '' || to_char(i.total_amount, ''FM999G999G990D00'') d, i.id r from sal_invoice i join dst_shop s on s.customer_account_id = i.customer_account_id where s.id = :P2_SHOP and i.status_code = ''POSTED'' and i.doc_type in (''INVOICE'', ''SIMPLIFIED_INVOICE'') and i.doc_date >= trunc(sysdate) - 180 order by i.id desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000060)
,p_plug_name=>'أصناف المرتجع'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>51
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null and :P2_RINV is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div data-item="P2_RLINES">'' || noona_dst_pkg.return_picker_html(:P2_RINV) || ''</div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000061)
,p_plug_name=>'سبب المرتجع'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>52
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null and :P2_RINV is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000062)
,p_name=>'P2_RLINES'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000061)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000063)
,p_name=>'P2_RREASON'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000061)
,p_prompt=>'سبب المرتجع'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000064)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000061)
,p_button_name=>'RETURN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تسجيل المرتجع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000065)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Return'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t(); l_id number;',
'begin',
'  l.put(''visit'', to_number(:P2_VISIT)); l.put(''invoice'', to_number(:P2_RINV)); l.put(''reason'', nvl(:P2_RREASON, ''مرتجع ميداني''));',
'  l.put(''lines'', json_array_t(nvl(:P2_RLINES, ''[]'')));',
'  l_id := noona_dst_pkg.visit_return(l.to_clob);',
'  :P2_RLINES := null; :P2_RINV := null; :P2_RREASON := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000064)
,p_process_success_message=>'تم تسجيل المرتجع وإشعار الدائن'
,p_internal_uid=>91820300000000065
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000066)
,p_plug_name=>'إرسال بواتساب'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.visit_actions_html(:P2_VISIT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000067)
,p_plug_name=>'إنهاء الزيارة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">إذا لم يشترِ المحل ولم يسدد اختر السبب (مطلوب). يحسب النظام نتيجة الزيارة تلقائياً.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P2_VISIT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000068)
,p_name=>'P2_NOSALE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000067)
,p_prompt=>'سبب عدم الشراء'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المحل مغلق;CLOSED,لديه مخزون كافٍ;STOCKED,لا توجد سيولة;NO_CASH,صاحب المحل غير موجود;OWNER_ABSENT,يشتري من منافس;COMPETITOR,السعر مرتفع;PRICE,سبب آخر;OTHER'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- تم البيع أو التحصيل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000069)
,p_name=>'P2_CNOTES'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000067)
,p_prompt=>'ملاحظات الزيارة'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000070)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000067)
,p_button_name=>'CLOSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنهاء الزيارة والمغادرة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000071)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dst_pkg.close_visit(:P2_VISIT, :P2_NOSALE, :P2_CNOTES); :P2_NOSALE := null; :P2_CNOTES := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000070)
,p_process_success_message=>'تم إنهاء الزيارة'
,p_internal_uid=>91820300000000071
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000072)
,p_branch_action=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820300000000070)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000073)
,p_branch_action=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.::P2_SHOP:&P2_SHOP.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
