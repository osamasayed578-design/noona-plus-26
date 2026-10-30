prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>137
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Employee'
,p_alias=>'EMPLOYEE'
,p_step_title=>'ملف الموظف'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000050)
,p_plug_name=>'بطاقة الموظف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_hr_pkg.employee_card(:P11_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000051)
,p_plug_name=>'البيانات الشخصية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000052)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000053)
,p_name=>'P11_NAME_AR'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'الاسم الكامل بالعربية'
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
 p_id=>wwv_flow_imp.id(91820272000000054)
,p_name=>'P11_NAME_EN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'الاسم بالإنجليزية'
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
 p_id=>wwv_flow_imp.id(91820272000000055)
,p_name=>'P11_NATIONALITY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'الجنسية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, country_code r from ref_country where is_active = ''Y'' order by nvl(sort_order, 999), name_ar'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000056)
,p_name=>'P11_NATIONAL_ID'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'رقم الهوية / الإقامة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>10
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
 p_id=>wwv_flow_imp.id(91820272000000057)
,p_name=>'P11_ID_EXPIRY'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'انتهاء الهوية / الإقامة'
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
 p_id=>wwv_flow_imp.id(91820272000000058)
,p_name=>'P11_GENDER'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'الجنس'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:ذكر;M,أنثى;F'
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
 p_id=>wwv_flow_imp.id(91820272000000059)
,p_name=>'P11_BIRTH'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'تاريخ الميلاد'
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
 p_id=>wwv_flow_imp.id(91820272000000060)
,p_name=>'P11_MOBILE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820272000000061)
,p_name=>'P11_EMAIL'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820272000000051)
,p_prompt=>'البريد الإلكتروني'
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000062)
,p_plug_name=>'الوظيفة والراتب البنكي'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000063)
,p_name=>'P11_HIRE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'تاريخ المباشرة'
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
 p_id=>wwv_flow_imp.id(91820272000000064)
,p_name=>'P11_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'نوع التوظيف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:دائم;PERMANENT,محدد المدة;FIXED_TERM,دوام جزئي;PART_TIME,مؤقت;TEMPORARY,متدرب;INTERN,مستشار;CONSULTANT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000065)
,p_name=>'P11_JOB'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'المسمى الوظيفي'
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
 p_id=>wwv_flow_imp.id(91820272000000066)
,p_name=>'P11_UNIT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'الإدارة / القسم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_unit where company_id = noona_hr_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820272000000067)
,p_name=>'P11_BRANCH'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'الفرع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = noona_hr_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820272000000068)
,p_name=>'P11_CC'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'مركز التكلفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from gl_cost_center where company_id = noona_hr_pkg.company order by code'
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
 p_id=>wwv_flow_imp.id(91820272000000069)
,p_name=>'P11_MANAGER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'المدير المباشر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.employee_no || '' - '' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_hr_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'', ''SUSPENDED'')) order by e.employee_no'
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
 p_id=>wwv_flow_imp.id(91820272000000070)
,p_name=>'P11_BANK'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'بنك الراتب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from ref_bank where is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820272000000071)
,p_name=>'P11_IBAN'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'الآيبان (SA + 22 رقماً)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>34
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000072)
,p_name=>'P11_GOSI'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'رقم التأمينات الاجتماعية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820272000000073)
,p_name=>'P11_LEAVE_DAYS'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'الإجازة السنوية (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000074)
,p_name=>'P11_CONTRACT_TYPE'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'نوع العقد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:غير محدد المدة;UNLIMITED,محدد المدة;FIXED_TERM,دوام جزئي;PART_TIME,مؤقت;TEMPORARY'
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
 p_id=>wwv_flow_imp.id(91820272000000075)
,p_name=>'P11_CONTRACT_END'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820272000000062)
,p_prompt=>'نهاية العقد (المحدد المدة)'
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
 p_id=>wwv_flow_imp.id(91820272000000076)
,p_plug_name=>'هيكل الراتب الشهري'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">لكل بدل: مبلغ ثابت، أو نسبة من الأساسي (اكتب النسبة مثل 25)، أو «حسب سياسة الشركة» المعرفة في الإعدادات لكل شركة أو دولة. البدلات التلقائية في السياسة تضاف دون إدخال. بعد التعيين يعدل أي عنصر من «هيكل الراتب» بحركة مؤرخة.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000077)
,p_name=>'P11_BASIC'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000076)
,p_prompt=>'الراتب الأساسي'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000078)
,p_name=>'P11_HOUSING_M'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000076)
,p_prompt=>'بدل السكن: الطريقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مبلغ ثابت;FIXED,نسبة من الأساسي;PERCENT,حسب سياسة الشركة;POLICY'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- لا يوجد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000079)
,p_name=>'P11_HOUSING'
,p_item_sequence=>25
,p_item_plug_id=>wwv_flow_imp.id(91820272000000076)
,p_prompt=>'بدل السكن: المبلغ أو النسبة %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000080)
,p_name=>'P11_TRANSPORT_M'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000076)
,p_prompt=>'بدل النقل: الطريقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مبلغ ثابت;FIXED,نسبة من الأساسي;PERCENT,حسب سياسة الشركة;POLICY'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- لا يوجد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000081)
,p_name=>'P11_TRANSPORT'
,p_item_sequence=>35
,p_item_plug_id=>wwv_flow_imp.id(91820272000000076)
,p_prompt=>'بدل النقل: المبلغ أو النسبة %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000082)
,p_name=>'P11_OTHER_M'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000076)
,p_prompt=>'بدلات أخرى: الطريقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مبلغ ثابت;FIXED,نسبة من الأساسي;PERCENT,حسب سياسة الشركة;POLICY'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- لا يوجد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000083)
,p_name=>'P11_OTHER'
,p_item_sequence=>45
,p_item_plug_id=>wwv_flow_imp.id(91820272000000076)
,p_prompt=>'بدلات أخرى: المبلغ أو النسبة %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000084)
,p_plug_name=>'حفظ'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000085)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000084)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الملف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000086)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P11_ID is not null then',
'        select p.display_name_ar, p.display_name_en, e.nationality, e.national_id, to_char(e.id_expiry_date, ''YYYY-MM-DD''), e.gender,',
'               to_char(e.birth_date, ''YYYY-MM-DD''), e.work_mobile, e.work_email, to_char(m.start_date, ''YYYY-MM-DD''), m.employment_type,',
'               m.job_title, m.org_unit_id, m.branch_id, m.cost_center_id, m.manager_employee_id, m.bank_id, m.iban, m.gosi_no,',
'               m.annual_leave_days, (select max(c.contract_type) from hr_contract c where c.employment_id = m.id and c.status_code = ''ACTIVE''),',
'               (select to_char(max(c.end_date), ''YYYY-MM-DD'') from hr_contract c where c.employment_id = m.id and c.status_code = ''ACTIVE'')',
'          into :P11_NAME_AR, :P11_NAME_EN, :P11_NATIONALITY, :P11_NATIONAL_ID, :P11_ID_EXPIRY, :P11_GENDER, :P11_BIRTH, :P11_MOBILE,',
'               :P11_EMAIL, :P11_HIRE, :P11_TYPE, :P11_JOB, :P11_UNIT, :P11_BRANCH, :P11_CC, :P11_MANAGER, :P11_BANK, :P11_IBAN, :P11_GOSI,',
'               :P11_LEAVE_DAYS, :P11_CONTRACT_TYPE, :P11_CONTRACT_END',
'          from hr_employment m join hr_employee e on e.id = m.employee_id join pty_party p on p.id = e.person_party_id',
'         where m.id = :P11_ID and m.company_id = noona_hr_pkg.company;',
'    else',
'        :P11_HIRE := nvl(:P11_HIRE, to_char(sysdate, ''YYYY-MM-DD''));',
'        :P11_NATIONALITY := nvl(:P11_NATIONALITY, noona_hr_pkg.company_country);',
'        :P11_LEAVE_DAYS := nvl(:P11_LEAVE_DAYS, case when noona_hr_pkg.company_country = ''SA'' then 21 end);',
'        :P11_HOUSING_M := nvl(:P11_HOUSING_M, ''FIXED''); :P11_TRANSPORT_M := nvl(:P11_TRANSPORT_M, ''FIXED'');',
'    end if;',
'    :P11_SAL_DATE := nvl(:P11_SAL_DATE, to_char(add_months(trunc(sysdate, ''MM''), 1), ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820272000000086
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000087)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_doc clob;',
'    l_o   json_object_t;',
'    l_s   json_object_t := json_object_t();',
'    procedure el(p_code varchar2, p_method varchar2, p_value varchar2) is',
'        l json_object_t := json_object_t();',
'    begin',
'        if p_method is null or (p_method <> ''POLICY'' and p_value is null) then return; end if;',
'        l.put(''method'', p_method);',
'        if p_value is not null then l.put(''value'', to_number(p_value)); end if;',
'        l_s.put(p_code, l);',
'    end;',
'begin',
'    select json_object(''id'' value to_number(:P11_ID), ''name_ar'' value :P11_NAME_AR, ''name_en'' value :P11_NAME_EN,',
'                       ''nationality'' value :P11_NATIONALITY, ''national_id'' value :P11_NATIONAL_ID, ''id_expiry'' value :P11_ID_EXPIRY,',
'                       ''gender'' value :P11_GENDER, ''birth_date'' value :P11_BIRTH, ''mobile'' value :P11_MOBILE, ''email'' value :P11_EMAIL,',
'                       ''hire_date'' value :P11_HIRE, ''type'' value :P11_TYPE, ''job_title'' value :P11_JOB, ''unit'' value to_number(:P11_UNIT),',
'                       ''branch'' value to_number(:P11_BRANCH), ''cost_center'' value to_number(:P11_CC), ''manager'' value to_number(:P11_MANAGER),',
'                       ''bank'' value to_number(:P11_BANK), ''iban'' value :P11_IBAN, ''gosi_no'' value :P11_GOSI,',
'                       ''leave_days'' value to_number(:P11_LEAVE_DAYS), ''contract_type'' value :P11_CONTRACT_TYPE, ''contract_end'' value :P11_CONTRACT_END',
'                       returning clob) into l_doc from dual;',
'    if :P11_ID is null then',
'        l_o := json_object_t.parse(l_doc);',
'        l_s.put(''BASIC'', to_number(:P11_BASIC));',
'        el(''HOUSING'', :P11_HOUSING_M, :P11_HOUSING);',
'        el(''TRANSPORT'', :P11_TRANSPORT_M, :P11_TRANSPORT);',
'        el(''OTHER_ALLOW'', :P11_OTHER_M, :P11_OTHER);',
'        l_o.put(''salary'', l_s);',
'        l_doc := l_o.to_clob;',
'    end if;',
'    :P11_ID := noona_hr_pkg.save_employee(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000085)
,p_process_success_message=>'تم حفظ ملف الموظف'
,p_internal_uid=>91820272000000087
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000088)
,p_plug_name=>'هيكل الراتب'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>45
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_pay_pkg.structure_html(:P11_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000089)
,p_plug_name=>'تعديل عنصر في الراتب (حركة مؤرخة)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">مثال: بدل السكن نسبة 25 من الأساسي، أو بدل النقل حسب سياسة الشركة، أو استثناء الموظف من بدل تلقائي. تعديل الأساسي يغير البدلات المحسوبة كنسبة منه تلقائياً.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000090)
,p_name=>'P11_EL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000089)
,p_prompt=>'العنصر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || case when element_type <> ''EARNING'' then '' (استقطاع)'' end d, code r from pay_element where is_active = ''Y'' and is_recurring = ''Y'' and element_type in (''EARNING'', ''DEDUCTION'') order by sort_order, name_ar'
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
 p_id=>wwv_flow_imp.id(91820272000000091)
,p_name=>'P11_EL_M'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000089)
,p_prompt=>'طريقة الاحتساب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مبلغ ثابت;FIXED,نسبة من عنصر;PERCENT,حسب سياسة الشركة;POLICY,مستثنى (لا يصرف);EXCLUDED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000092)
,p_name=>'P11_EL_V'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000089)
,p_prompt=>'المبلغ أو النسبة %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000093)
,p_name=>'P11_EL_BASIS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000089)
,p_prompt=>'النسبة من'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, code r from pay_element where is_active = ''Y'' and element_type = ''EARNING'' and is_recurring = ''Y'' order by case code when ''BASIC'' then 0 else 1 end, sort_order'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000094)
,p_name=>'P11_SAL_DATE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000089)
,p_prompt=>'يسري من'
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
 p_id=>wwv_flow_imp.id(91820272000000095)
,p_name=>'P11_SAL_REASON'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820272000000089)
,p_prompt=>'السبب (ترقية، علاوة سنوية...)'
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
 p_id=>wwv_flow_imp.id(91820272000000096)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000089)
,p_button_name=>'CHANGE_SALARY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'اعتماد التعديل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000097)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Change Salary'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_hr_pkg.set_element(:P11_ID, :P11_EL, :P11_EL_M, to_number(:P11_EL_V), :P11_EL_BASIS,',
'                                     to_date(:P11_SAL_DATE, ''YYYY-MM-DD''), :P11_SAL_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000096)
,p_process_success_message=>'تم تعديل الراتب بحركة مؤرخة'
,p_internal_uid=>91820272000000097
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000098)
,p_plug_name=>'نقل / تغيير المسمى'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000099)
,p_name=>'P11_TR_UNIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000098)
,p_prompt=>'الإدارة الجديدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_unit where company_id = noona_hr_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820272000000100)
,p_name=>'P11_TR_BRANCH'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000098)
,p_prompt=>'الفرع الجديد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = noona_hr_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820272000000101)
,p_name=>'P11_TR_CC'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000098)
,p_prompt=>'مركز التكلفة الجديد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from gl_cost_center where company_id = noona_hr_pkg.company order by code'
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
 p_id=>wwv_flow_imp.id(91820272000000102)
,p_name=>'P11_TR_JOB'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000098)
,p_prompt=>'المسمى الجديد'
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
 p_id=>wwv_flow_imp.id(91820272000000103)
,p_name=>'P11_TR_MGR'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000098)
,p_prompt=>'المدير الجديد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.employee_no || '' - '' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_hr_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'', ''SUSPENDED'')) order by e.employee_no'
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
 p_id=>wwv_flow_imp.id(91820272000000104)
,p_name=>'P11_TR_REASON'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820272000000098)
,p_prompt=>'السبب'
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
 p_id=>wwv_flow_imp.id(91820272000000105)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000098)
,p_button_name=>'TRANSFER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'اعتماد النقل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000106)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Transfer'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_hr_pkg.transfer(:P11_ID, trunc(sysdate), :P11_TR_UNIT, :P11_TR_BRANCH, :P11_TR_CC, :P11_TR_JOB, :P11_TR_MGR, :P11_TR_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000105)
,p_process_success_message=>'تم النقل وتسجيل الحركة'
,p_internal_uid=>91820272000000106
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000107)
,p_plug_name=>'الإجازات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, r.doc_no, t.name_ar as leave_type, to_char(r.start_date, ''YYYY-MM-DD'') as from_d, to_char(r.end_date, ''YYYY-MM-DD'') as to_d,',
'       r.duration, noona_hr_pkg.status_label(r.status_code) as status',
'  from hr_leave_request r join hr_leave_type t on t.id = r.leave_type_id join hr_employment m on m.employee_id = r.employee_id',
' where m.id = :P11_ID order by r.start_date desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الإجازات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000108)
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
,p_internal_uid=>91820272000000108
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000110)
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
 p_id=>wwv_flow_imp.id(91820272000000111)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الطلب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000112)
,p_db_column_name=>'LEAVE_TYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000113)
,p_db_column_name=>'FROM_D'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000114)
,p_db_column_name=>'TO_D'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000115)
,p_db_column_name=>'DURATION'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المدة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000116)
,p_db_column_name=>'STATUS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000109)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'109'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:LEAVE_TYPE:FROM_D:TO_D:DURATION:STATUS'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000117)
,p_plug_name=>'قسائم الرواتب'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>80
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select re.id, pp.period_code, r.run_no, re.gross_amount, re.deduction_amount, re.net_amount, noona_pay_pkg.status_label(r.status_code) as status',
'  from pay_run_employee re join pay_run r on r.id = re.run_id join pay_period pp on pp.id = r.period_id',
' where re.employment_id = :P11_ID and noona_security_pkg.has_permission(''PAY_RUN.VIEW'', noona_pay_pkg.company) = ''Y''',
' order by pp.start_date desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'قسائم الرواتب'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000118)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:45:&SESSION.::&DEBUG.:RP,45:P45_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820272000000118
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000120)
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
 p_id=>wwv_flow_imp.id(91820272000000121)
,p_db_column_name=>'PERIOD_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الفترة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000122)
,p_db_column_name=>'RUN_NO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التشغيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000123)
,p_db_column_name=>'GROSS_AMOUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الإجمالي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000124)
,p_db_column_name=>'DEDUCTION_AMOUNT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الخصومات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000125)
,p_db_column_name=>'NET_AMOUNT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الصافي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000126)
,p_db_column_name=>'STATUS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000119)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'119'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PERIOD_CODE:RUN_NO:GROSS_AMOUNT:DEDUCTION_AMOUNT:NET_AMOUNT:STATUS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000127)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.::P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
