prompt --application/pages/page_00061
begin
--   Manifest
--     PAGE: 00061
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
 p_id=>61
,p_name=>'Fixed Asset'
,p_alias=>'FIXED-ASSET'
,p_step_title=>'بطاقة الأصل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000509)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'(function(){',
'  function show(n, on){ var el = document.getElementById(n + ''_CONTAINER''); if (el) el.style.display = on ? '''' : ''none''; }',
'  function sync(){',
'    var a = $v(''P61_ACTION'') || ''ADD'', f = $v(''P61_AC_FUND'') || ''BANK'';',
'    show(''P61_AMOUNT'', a === ''ADD'' || a === ''IMPAIR'');',
'    [''P61_AC_FUND'', ''P61_AC_VAT''].forEach(function(n){ show(n, a === ''ADD''); });',
'    show(''P61_AC_BANK'', a === ''ADD'' && f === ''BANK''); show(''P61_AC_BOX'', a === ''ADD'' && f === ''CASH'');',
'    show(''P61_AC_PARTY'', a === ''ADD'' && f === ''PAYABLE''); show(''P61_AC_ACCOUNT'', a === ''ADD'' && f === ''ACCOUNT'');',
'    [''P61_NEW_LIFE'', ''P61_NEW_RES''].forEach(function(n){ show(n, a === ''LIFE''); });',
'    [''P61_TR_BRANCH'', ''P61_TR_CC'', ''P61_TR_CUST'', ''P61_TR_LOC''].forEach(function(n){ show(n, a === ''TRANSFER''); });',
'    var g = $v(''P61_FUNDING'') || ''BANK'';',
'    show(''P61_BANK'', g === ''BANK''); show(''P61_BOX'', g === ''CASH''); show(''P61_PARTY'', g === ''PAYABLE'');',
'    show(''P61_ACCOUNT'', g === ''ACCOUNT''); show(''P61_OPEN_ACC'', g === ''OPENING'' || g === ''ACCOUNT''); show(''P61_VAT'', g !== ''OPENING'');',
'  }',
'  [''P61_ACTION'', ''P61_AC_FUND'', ''P61_FUNDING''].forEach(function(n){ $(''#'' + n).off(''change.nnfa'').on(''change.nnfa'', sync); });',
'  sync();',
'})();',
''))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000538)
,p_plug_name=>'بطاقة الأصل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P61_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_fa_pkg.asset_card_html(:P61_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000539)
,p_plug_name=>'بيانات الأصل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P61_ID is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000540)
,p_name=>'P61_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000541)
,p_name=>'P61_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'اسم الأصل'
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
 p_id=>wwv_flow_imp.id(91820266000000542)
,p_name=>'P61_CAT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'الفئة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from fa_category where company_id = noona_fa_pkg.company and is_active = ''Y'' order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000543)
,p_name=>'P61_BRANCH'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'الفرع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820266000000544)
,p_name=>'P61_CC'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'مركز التكلفة (يحمل عليه الإهلاك)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from gl_cost_center where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000545)
,p_name=>'P61_CUSTODIAN'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'العهدة (الموظف المسؤول)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.employee_no || '' - '' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_fa_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'', ''SUSPENDED'')) order by e.employee_no'
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
 p_id=>wwv_flow_imp.id(91820266000000546)
,p_name=>'P61_LOCATION'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'الموقع التفصيلي'
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
 p_id=>wwv_flow_imp.id(91820266000000547)
,p_name=>'P61_TAG'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'رقم الملصق / الباركود (افتراضياً رقم الأصل)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820266000000548)
,p_name=>'P61_SERIAL'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'الرقم التسلسلي'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820266000000549)
,p_name=>'P61_MANUFACTURER'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'الصانع'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820266000000550)
,p_name=>'P61_MODEL'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'الموديل'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820266000000551)
,p_name=>'P61_WARRANTY'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820266000000539)
,p_prompt=>'نهاية الضمان'
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000552)
,p_plug_name=>'التكلفة والإهلاك'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الطريقة والعمر والقيمة المتبقية تؤخذ من الفئة إن تركت فارغة. يبدأ الإهلاك من تاريخ التشغيل حسب قاعدة الفئة، والأشهر الفائتة تلحق في أول تشغيل إهلاك.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P61_ID is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000553)
,p_name=>'P61_ACQ'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000552)
,p_prompt=>'تاريخ الاقتناء (تاريخ القيد)'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609122147107268652
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
 p_id=>wwv_flow_imp.id(91820266000000554)
,p_name=>'P61_SVC'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000552)
,p_prompt=>'تاريخ التشغيل (بداية الإهلاك)'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000555)
,p_name=>'P61_COST'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000552)
,p_prompt=>'التكلفة (دون الضريبة)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000556)
,p_name=>'P61_RESIDUAL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000552)
,p_prompt=>'القيمة المتبقية (الخردة)'
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
 p_id=>wwv_flow_imp.id(91820266000000557)
,p_name=>'P61_LIFE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000552)
,p_prompt=>'العمر الإنتاجي بالأشهر'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000558)
,p_name=>'P61_METHOD'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000552)
,p_prompt=>'طريقة الإهلاك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:القسط الثابت;STRAIGHT_LINE,القسط المتناقص (1.5);DECLINING_BALANCE,المتناقص المضاعف (2);DOUBLE_DECLINING,لا يهلك (أراض);NONE'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- حسب الفئة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000559)
,p_name=>'P61_PRORATE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000552)
,p_prompt=>'بداية الإهلاك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:يومي من تاريخ التشغيل;DAILY,شهر كامل من شهر التشغيل;FULL_MONTH,منتصف الشهر (حتى يوم 15 شهر كامل);MID_MONTH,من الشهر التالي;NEXT_MONTH'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- حسب الفئة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000560)
,p_plug_name=>'التمويل والسداد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P61_ID is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000561)
,p_name=>'P61_FUNDING'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'مصدر التمويل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تحويل بنكي;BANK,نقداً من الصندوق;CASH,آجل على مورد;PAYABLE,حساب محدد;ACCOUNT,رصيد افتتاحي (أصل قائم قبل النظام);OPENING'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000562)
,p_name=>'P61_BANK'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_bank_account where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000563)
,p_name=>'P61_BOX'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'الصندوق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_cash_box where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000564)
,p_name=>'P61_PARTY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'المورد (للشراء الآجل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar || case when exists (select 1 from ap_supplier s where s.party_id = p.id) then '' (مورد)'' else '' (عميل)'' end d, p.id r from pty_party p where exists (select 1 from ap_supplier s where s.party_id = p.id) or exists (select 1 from ar_customer c where c.party_id = p.id) order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000565)
,p_name=>'P61_ACCOUNT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'الحساب المقابل (حساب محدد)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.id r from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger and a.is_postable = ''Y'' order by a.account_code'
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
 p_id=>wwv_flow_imp.id(91820266000000566)
,p_name=>'P61_VAT'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'ضريبة القيمة المضافة على الشراء (مدخلات)'
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
 p_id=>wwv_flow_imp.id(91820266000000567)
,p_name=>'P61_OPEN_ACC'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'مجمع الإهلاك المنقول (للرصيد الافتتاحي)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000568)
,p_name=>'P61_REF'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'المرجع (رقم فاتورة المورد...)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820266000000569)
,p_name=>'P61_CAPITALIZE'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_prompt=>'رسملة وترحيل القيد الآن'
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
 p_id=>wwv_flow_imp.id(91820266000000570)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000560)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الأصل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000571)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P61_ACQ := nvl(:P61_ACQ, to_char(sysdate, ''YYYY-MM-DD''));',
'    :P61_FUNDING := nvl(:P61_FUNDING, ''BANK'');',
'    :P61_CAPITALIZE := nvl(:P61_CAPITALIZE, ''Y'');',
'    :P61_DATE := nvl(:P61_DATE, to_char(sysdate, ''YYYY-MM-DD''));',
'    :P61_AC_FUND := nvl(:P61_AC_FUND, ''BANK'');',
'    if :P61_ID is not null then',
'        select useful_life_months, residual_value into :P61_NEW_LIFE, :P61_NEW_RES from fa_asset_book',
'         where asset_id = :P61_ID and book_id = noona_fa_pkg.default_book;',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000571
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000572)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''name_ar'' value :P61_NAME, ''category'' value to_number(:P61_CAT), ''branch'' value to_number(:P61_BRANCH),',
'                       ''cost_center'' value to_number(:P61_CC), ''custodian'' value to_number(:P61_CUSTODIAN), ''location'' value :P61_LOCATION,',
'                       ''tag'' value :P61_TAG, ''serial'' value :P61_SERIAL, ''manufacturer'' value :P61_MANUFACTURER, ''model'' value :P61_MODEL,',
'                       ''warranty_end'' value :P61_WARRANTY, ''acquisition_date'' value :P61_ACQ, ''in_service_date'' value :P61_SVC,',
'                       ''cost'' value :P61_COST, ''residual'' value :P61_RESIDUAL, ''life_months'' value :P61_LIFE, ''method'' value :P61_METHOD,',
'                       ''prorate'' value :P61_PRORATE, ''funding'' value :P61_FUNDING, ''bank_account'' value :P61_BANK, ''cash_box'' value :P61_BOX,',
'                       ''party'' value :P61_PARTY, ''account'' value :P61_ACCOUNT, ''vat'' value :P61_VAT, ''opening_accum'' value :P61_OPEN_ACC,',
'                       ''reference'' value :P61_REF, ''capitalize'' value :P61_CAPITALIZE returning clob) into l_doc from dual;',
'    :P61_ID := noona_fa_pkg.create_asset(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000570)
,p_process_success_message=>'تم حفظ الأصل'
,p_internal_uid=>91820266000000572
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000573)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>8
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P61_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000574)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000573)
,p_button_name=>'CAPITALIZE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'رسملة وترحيل قيد الاقتناء'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_fa_pkg.asset_status(:P61_ID) = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000575)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000573)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف المسودة'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_fa_pkg.asset_status(:P61_ID) = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000576)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820266000000573)
,p_button_name=>'DISPOSE'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'بيع / تخريد / استبعاد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:65:&SESSION.::&DEBUG.:RP,65:P65_ASSET:&P61_ID.'
,p_button_condition=>'noona_fa_pkg.asset_status(:P61_ID) in (''IN_SERVICE'', ''CAPITALIZED'', ''FULLY_DEPRECIATED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000577)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820266000000573)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'سجل الأصول'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:60:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000578)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Capitalize'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_j number;',
'begin',
'    l_j := noona_fa_pkg.capitalize(:P61_ID);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000574)
,p_process_success_message=>'تمت رسملة الأصل وترحيل قيد الاقتناء'
,p_internal_uid=>91820266000000578
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000579)
,p_process_sequence=>25
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_fa_pkg.delete_asset(:P61_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000575)
,p_process_success_message=>'تم حذف الأصل'
,p_internal_uid=>91820266000000579
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000580)
,p_branch_action=>'f?p=&APP_ID.:60:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820266000000575)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000581)
,p_plug_name=>'حركة على الأصل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الإضافة الرأسمالية ترفع التكلفة، والانخفاض يرفع المجمع (مصروف 5218)، وتغيير العمر والقيمة المتبقية يطبق على العمر المتبقي من الآن (مستقبلياً)، والنقل لا يولد قيداً ويحمل الإهلاك القادم على مركز التكلفة الجديد.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_fa_pkg.asset_status(:P61_ID) in (''IN_SERVICE'', ''CAPITALIZED'', ''FULLY_DEPRECIATED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000582)
,p_name=>'P61_ACTION'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'الحركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إضافة رأسمالية;ADD,انخفاض في القيمة;IMPAIR,تغيير العمر والقيمة المتبقية;LIFE,نقل (فرع/مركز تكلفة/عهدة/موقع);TRANSFER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000583)
,p_name=>'P61_DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'التاريخ'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000584)
,p_name=>'P61_AMOUNT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'المبلغ (للإضافة أو الانخفاض)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000585)
,p_name=>'P61_AC_FUND'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'تمويل الإضافة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تحويل بنكي;BANK,نقداً;CASH,آجل على مورد;PAYABLE,حساب محدد;ACCOUNT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000586)
,p_name=>'P61_AC_BANK'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_bank_account where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000587)
,p_name=>'P61_AC_BOX'
,p_item_sequence=>55
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'الصندوق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_cash_box where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000588)
,p_name=>'P61_AC_PARTY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'المورد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar || case when exists (select 1 from ap_supplier s where s.party_id = p.id) then '' (مورد)'' else '' (عميل)'' end d, p.id r from pty_party p where exists (select 1 from ap_supplier s where s.party_id = p.id) or exists (select 1 from ar_customer c where c.party_id = p.id) order by 1'
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
 p_id=>wwv_flow_imp.id(91820266000000589)
,p_name=>'P61_AC_ACCOUNT'
,p_item_sequence=>65
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'الحساب المقابل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.id r from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger and a.is_postable = ''Y'' order by a.account_code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000590)
,p_name=>'P61_AC_VAT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'ضريبة المدخلات'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000591)
,p_name=>'P61_NEW_LIFE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'العمر الإنتاجي الكلي الجديد (شهر)'
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
 p_id=>wwv_flow_imp.id(91820266000000592)
,p_name=>'P61_NEW_RES'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'القيمة المتبقية الجديدة'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000593)
,p_name=>'P61_TR_BRANCH'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'الفرع الجديد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000594)
,p_name=>'P61_TR_CC'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'مركز التكلفة الجديد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from gl_cost_center where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000595)
,p_name=>'P61_TR_CUST'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'العهدة الجديدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.employee_no || '' - '' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_fa_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'', ''SUSPENDED'')) order by e.employee_no'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000596)
,p_name=>'P61_TR_LOC'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'الموقع الجديد'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000597)
,p_name=>'P61_REASON'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_prompt=>'السبب / البيان'
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
 p_id=>wwv_flow_imp.id(91820266000000598)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000581)
,p_button_name=>'APPLY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تنفيذ الحركة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000599)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Apply'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number; l_d date := to_date(:P61_DATE, ''YYYY-MM-DD'');',
'begin',
'    case nvl(:P61_ACTION, ''ADD'')',
'        when ''ADD'' then l_id := noona_fa_pkg.add_cost(:P61_ID, :P61_AMOUNT, l_d, :P61_AC_FUND, :P61_AC_BANK, :P61_AC_BOX,',
'                                                  :P61_AC_PARTY, :P61_AC_ACCOUNT, :P61_AC_VAT, :P61_REASON);',
'        when ''IMPAIR'' then l_id := noona_fa_pkg.impair(:P61_ID, :P61_AMOUNT, l_d, :P61_REASON);',
'        when ''LIFE'' then l_id := noona_fa_pkg.change_life(:P61_ID, :P61_NEW_LIFE, :P61_NEW_RES, l_d, :P61_REASON);',
'        when ''TRANSFER'' then l_id := noona_fa_pkg.transfer(:P61_ID, l_d, :P61_TR_BRANCH, :P61_TR_CC, :P61_TR_CUST, :P61_TR_LOC, :P61_REASON);',
'    end case;',
'    apex_application.g_print_success_message := ''تم تنفيذ الحركة وتحديث الأصل'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000598)
,p_internal_uid=>91820266000000599
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000600)
,p_plug_name=>'جدول الإهلاك المتوقع'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_fa_pkg.asset_status(:P61_ID) in (''IN_SERVICE'', ''CAPITALIZED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_fa_pkg.schedule_html(:P61_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000601)
,p_branch_action=>'f?p=&APP_ID.:61:&SESSION.::&DEBUG.::P61_ID:&P61_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
