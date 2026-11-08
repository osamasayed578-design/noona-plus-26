prompt --application/pages/page_00092
begin
--   Manifest
--     PAGE: 00092
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>92
,p_name=>'Letters of Guarantee'
,p_alias=>'GUARANTEES'
,p_step_title=>'خطابات الضمان'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000791)
,p_plug_name=>'خطابات الضمان'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prj_ctr_pkg.guarantees_html(60);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000792)
,p_plug_name=>'خطاب ضمان جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000793)
,p_name=>'P92_NO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'رقم الخطاب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>100
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000794)
,p_name=>'P92_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:ابتدائي (عطاء);BID,نهائي (حسن تنفيذ);PERFORMANCE,دفعة مقدمة;ADVANCE_PAYMENT,بدل محتجز;RETENTION,صيانة;MAINTENANCE,جمركي;CUSTOMS'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000795)
,p_name=>'P92_DIR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'الاتجاه'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:صادر منا (لصالح المالك);ISSUED_BY_US,وارد لنا (من مقاول باطن أو مورد);RECEIVED_FROM_PARTY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000796)
,p_name=>'P92_CONTRACT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'العقد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select c.contract_no || '' - '' || p.name_ar d, c.id r from prj_contract c join prj_project p on p.id = c.project_id where c.company_id = noona_prj_pkg.company order by c.contract_no'
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
 p_id=>wwv_flow_imp.id(91820273000000797)
,p_name=>'P92_PROJECT'
,p_item_sequence=>45
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'المشروع (إن لم يرتبط بعقد)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from prj_project where company_id = noona_prj_pkg.company order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000798)
,p_name=>'P92_BANK'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'البنك المصدر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from ref_bank order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820273000000799)
,p_name=>'P92_BEN'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'المستفيد / مقدم الخطاب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, p.id r from pty_party p where exists (select 1 from ar_customer c join ar_customer_account a on a.customer_id = c.id where c.party_id = p.id and a.company_id = noona_prj_pkg.company) or exists (select 1 from ap_supplier s join ap_supplier_account a on a.supplier_id = s.id where s.party_id = p.id and a.company_id = noona_prj_pkg.company) order by 1'
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
 p_id=>wwv_flow_imp.id(91820273000000800)
,p_name=>'P92_AMOUNT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'المبلغ'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000801)
,p_name=>'P92_MARGIN'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'الغطاء النقدي'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000802)
,p_name=>'P92_ISSUE'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'تاريخ الإصدار'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
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
 p_id=>wwv_flow_imp.id(91820273000000803)
,p_name=>'P92_EXPIRY'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'تاريخ الانتهاء'
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
 p_id=>wwv_flow_imp.id(91820273000000804)
,p_name=>'P92_NOTES'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_prompt=>'ملاحظات'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000806)
,p_validation_name=>'P92_NO required (SAVE)'
,p_validation_sequence=>14
,p_validation=>'P92_NO'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000805)
,p_associated_item=>wwv_flow_imp.id(91820273000000793)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000807)
,p_validation_name=>'P92_BANK required (SAVE)'
,p_validation_sequence=>15
,p_validation=>'P92_BANK'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000805)
,p_associated_item=>wwv_flow_imp.id(91820273000000798)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000808)
,p_validation_name=>'P92_AMOUNT required (SAVE)'
,p_validation_sequence=>16
,p_validation=>'P92_AMOUNT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000805)
,p_associated_item=>wwv_flow_imp.id(91820273000000800)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000809)
,p_validation_name=>'P92_ISSUE required (SAVE)'
,p_validation_sequence=>17
,p_validation=>'P92_ISSUE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000805)
,p_associated_item=>wwv_flow_imp.id(91820273000000802)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000810)
,p_validation_name=>'P92_EXPIRY required (SAVE)'
,p_validation_sequence=>18
,p_validation=>'P92_EXPIRY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000805)
,p_associated_item=>wwv_flow_imp.id(91820273000000803)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000805)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000792)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الخطاب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000811)
,p_plug_name=>'إجراء على خطاب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000812)
,p_name=>'P92_G'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_prompt=>'الخطاب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select guarantee_no || '' - '' || noona_prj_ctr_pkg.guarantee_type_label(guarantee_type) || '' ('' || noona_prj_ctr_pkg.guarantee_status_label(status_code) || '')'' d, id r from prj_guarantee where company_id = noona_prj_pkg.company and status_code not in (''RELEASED'', ''LIQUIDATED'', ''EXPIRED'') order by expiry_date'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000813)
,p_name=>'P92_ACTION'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_prompt=>'الإجراء'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إصدار (وتجنيب الغطاء);ISSUE,تمديد;EXTEND,تخفيض المبلغ;REDUCE,إفراج (يعود الغطاء);RELEASE,تسييل;LIQUIDATE,انتهاء;EXPIRE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000814)
,p_name=>'P92_ADATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_prompt=>'التاريخ'
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
 p_id=>wwv_flow_imp.id(91820273000000815)
,p_name=>'P92_NEWEXP'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_prompt=>'تاريخ الانتهاء الجديد (للتمديد)'
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
 p_id=>wwv_flow_imp.id(91820273000000816)
,p_name=>'P92_NEWAMT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_prompt=>'المبلغ الجديد (للتخفيض)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000817)
,p_name=>'P92_PLACE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_prompt=>'البنك أو الصندوق (للغطاء والتسييل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''صندوق: '' || name_ar d, ''BOX:'' || id r from csh_cash_box where company_id = noona_prj_pkg.company and status_code = ''ACTIVE'' union all select ''بنك: '' || name_ar, ''BANK:'' || id from csh_bank_account where company_id = noona_prj_pkg.company and status_code = ''ACTIVE'''
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
 p_id=>wwv_flow_imp.id(91820273000000818)
,p_name=>'P92_REASON'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_prompt=>'السبب'
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
 p_id=>wwv_flow_imp.id(91820273000000820)
,p_validation_name=>'P92_G required (APPLY)'
,p_validation_sequence=>28
,p_validation=>'P92_G'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000819)
,p_associated_item=>wwv_flow_imp.id(91820273000000812)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000819)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_button_name=>'APPLY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تنفيذ الإجراء'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000821)
,p_name=>'P92_CONTRACT_IN'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000811)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000822)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P92_TYPE := nvl(:P92_TYPE, ''PERFORMANCE''); :P92_DIR := nvl(:P92_DIR, ''ISSUED_BY_US'');',
':P92_ISSUE := nvl(:P92_ISSUE, to_char(sysdate, ''YYYY-MM-DD'')); :P92_ADATE := nvl(:P92_ADATE, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000822
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000823)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l number;',
'begin',
'    select json_object(''no'' value :P92_NO, ''type'' value :P92_TYPE, ''direction'' value :P92_DIR, ''contract'' value to_number(:P92_CONTRACT),',
'                       ''project'' value to_number(:P92_PROJECT), ''bank'' value to_number(:P92_BANK), ''beneficiary'' value to_number(:P92_BEN),',
'                       ''amount'' value to_number(:P92_AMOUNT), ''margin'' value to_number(:P92_MARGIN), ''issue'' value :P92_ISSUE,',
'                       ''expiry'' value :P92_EXPIRY, ''notes'' value :P92_NOTES returning clob) into l_doc from dual;',
'    l := noona_prj_ctr_pkg.save_guarantee(l_doc); :P92_G := l; :P92_ACTION := ''ISSUE'';',
'    :P92_NO := null; :P92_AMOUNT := null; :P92_MARGIN := null; :P92_NOTES := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000805)
,p_process_success_message=>'تم حفظ الخطاب؛ أصدره من «إجراء على خطاب»'
,p_internal_uid=>91820273000000823
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000824)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Action'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_ctr_pkg.guarantee_action(:P92_G, :P92_ACTION, to_date(:P92_ADATE, ''YYYY-MM-DD''), to_number(:P92_NEWAMT),',
'                                   to_date(:P92_NEWEXP, ''YYYY-MM-DD''), :P92_PLACE, :P92_REASON);',
':P92_NEWAMT := null; :P92_NEWEXP := null; :P92_REASON := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000819)
,p_process_success_message=>'تم تنفيذ الإجراء على الخطاب'
,p_internal_uid=>91820273000000824
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000825)
,p_branch_action=>'f?p=&APP_ID.:92:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
