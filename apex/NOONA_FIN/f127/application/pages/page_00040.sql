prompt --application/pages/page_00040
begin
--   Manifest
--     PAGE: 00040
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
 p_id=>40
,p_name=>'Cash and Banks'
,p_alias=>'CASH-BANKS'
,p_step_title=>'الصناديق والبنوك'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000187)
,p_plug_name=>'أرصدة الصناديق والبنوك'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_csh_pkg.balances_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000188)
,p_plug_name=>'صندوق جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000189)
,p_name=>'P40_BOX_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000188)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000190)
,p_name=>'P40_BOX_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000188)
,p_prompt=>'اسم الصندوق'
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
 p_id=>wwv_flow_imp.id(91820266000000191)
,p_name=>'P40_BOX_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000188)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:صندوق رئيسي;MAIN,عهدة نثرية;PETTY_CASH,درج نقاط بيع;POS_DRAWER,صندوق استقبال;FRONT_DESK,عهدة;CUSTODY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000192)
,p_name=>'P40_BOX_ACC'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000188)
,p_prompt=>'حساب النقدية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.account_code r from gl_account a where a.coa_id = noona_gl_pkg.primary_coa and a.subledger_code = ''CASH'' and a.is_postable = ''Y'' and a.status_code = ''ACTIVE'' order by a.account_code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000193)
,p_name=>'P40_BOX_MAX'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000188)
,p_prompt=>'الحد الأعلى للرصيد (اختياري)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000194)
,p_name=>'P40_BOX_CUR'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000188)
,p_prompt=>'العملة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select currency_code || '' - '' || name_ar d, currency_code r from ref_currency where is_active = ''Y'' order by case when currency_code = noona_gl_pkg.ledger_currency then 0 else 1 end, currency_code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000195)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000188)
,p_button_name=>'ADD_BOX'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الصندوق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000196)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Box'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_csh_pkg.create_cash_box(:P40_BOX_CODE, :P40_BOX_NAME, :P40_BOX_ACC, :P40_BOX_TYPE, :P40_BOX_MAX, :P40_BOX_CUR);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000195)
,p_process_success_message=>'تمت إضافة الصندوق'
,p_internal_uid=>91820266000000196
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000197)
,p_plug_name=>'حساب بنكي جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000198)
,p_name=>'P40_BANK_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000199)
,p_name=>'P40_BANK_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_prompt=>'اسم الحساب (مثل: الحساب الجاري)'
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
 p_id=>wwv_flow_imp.id(91820266000000200)
,p_name=>'P40_BANK'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_prompt=>'البنك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from ref_bank where is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820266000000201)
,p_name=>'P40_ACC_NO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_prompt=>'رقم الحساب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>40
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
 p_id=>wwv_flow_imp.id(91820266000000202)
,p_name=>'P40_IBAN'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_prompt=>'الآيبان'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>40
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000203)
,p_name=>'P40_BANK_ACC'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_prompt=>'حساب النقدية في الدليل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.account_code r from gl_account a where a.coa_id = noona_gl_pkg.primary_coa and a.subledger_code = ''CASH'' and a.is_postable = ''Y'' and a.status_code = ''ACTIVE'' order by a.account_code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000204)
,p_name=>'P40_BANK_MAX'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_prompt=>'حد الدفع للسند الواحد (اختياري)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000205)
,p_name=>'P40_BANK_CUR'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_prompt=>'العملة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select currency_code || '' - '' || name_ar d, currency_code r from ref_currency where is_active = ''Y'' order by case when currency_code = noona_gl_pkg.ledger_currency then 0 else 1 end, currency_code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000206)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000197)
,p_button_name=>'ADD_BANK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الحساب البنكي'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000207)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Bank'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_csh_pkg.create_bank_account(:P40_BANK_CODE, :P40_BANK_NAME, :P40_BANK, :P40_ACC_NO, :P40_IBAN,',
'                                               :P40_BANK_ACC, :P40_BANK_MAX, :P40_BANK_CUR);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000206)
,p_process_success_message=>'تمت إضافة الحساب البنكي (يحفظ الرقم مقنعاً)'
,p_internal_uid=>91820266000000207
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000208)
,p_plug_name=>'تعديل حساب بنكي'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000209)
,p_name=>'P40_EDIT_BANK'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000208)
,p_prompt=>'الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' '' || name_ar || '' '' || account_no_masked d, id r from csh_bank_account where company_id = noona_gl_pkg.company order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000210)
,p_name=>'P40_EDIT_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000208)
,p_prompt=>'الاسم'
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
 p_id=>wwv_flow_imp.id(91820266000000211)
,p_name=>'P40_EDIT_BNK'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000208)
,p_prompt=>'البنك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from ref_bank where is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820266000000212)
,p_name=>'P40_EDIT_NO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000208)
,p_prompt=>'رقم الحساب الجديد (اتركه فارغاً للإبقاء)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>40
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
 p_id=>wwv_flow_imp.id(91820266000000213)
,p_name=>'P40_EDIT_IBAN'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000208)
,p_prompt=>'الآيبان الجديد'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>40
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000214)
,p_name=>'P40_EDIT_MAX'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000208)
,p_prompt=>'حد الدفع للسند'
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
 p_id=>wwv_flow_imp.id(91820266000000215)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000208)
,p_button_name=>'EDIT_BANK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ التعديل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000216)
,p_process_sequence=>25
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Edit Bank'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_csh_pkg.update_bank_account(:P40_EDIT_BANK, :P40_EDIT_NAME, :P40_EDIT_BNK, :P40_EDIT_NO, :P40_EDIT_IBAN, :P40_EDIT_MAX);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000215)
,p_process_success_message=>'تم تعديل الحساب البنكي'
,p_internal_uid=>91820266000000216
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000217)
,p_plug_name=>'أرصدة سالبة تحتاج تسوية'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_csh_pkg.negative_balances_html is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_csh_pkg.negative_balances_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000218)
,p_plug_name=>'حد السحب على المكشوف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>36
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">لا يصرف أي صندوق فوق رصيده في كل الأنظمة (السندات، المشتريات، المشروعات، العقارات، الإيجارات، نقاط البيع). الحساب البنكي كذلك ما لم يحدد له حد سحب على المكشوف بتسهيل من البنك؛ عندها يصرف حتى الرصيد + الحد. اترك الحد صفراً لإلغائه.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000219)
,p_name=>'P40_OD_BANK'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000218)
,p_prompt=>'الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' '' || name_ar || nvl2(overdraft_limit, '' (الحد الحالي '' || to_char(overdraft_limit, ''FM999,999,999,990'') || '')'', '''') d, id r from csh_bank_account where company_id = noona_gl_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000220)
,p_name=>'P40_OD_LIMIT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000218)
,p_prompt=>'الحد'
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
 p_id=>wwv_flow_imp.id(91820266000000221)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000218)
,p_button_name=>'SET_OD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الحد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000222)
,p_process_sequence=>27
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Overdraft'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_csh_pkg.set_overdraft(:P40_OD_BANK, to_number(:P40_OD_LIMIT));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000221)
,p_process_success_message=>'تم حفظ حد السحب على المكشوف'
,p_internal_uid=>91820266000000222
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000223)
,p_plug_name=>'الإعدادات الافتراضية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>38
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يضيف صندوق العهد النثرية وحساباً بنكياً جارياً افتراضياً (عدّل رقمه من "تعديل حساب بنكي") إن لم توجد.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000224)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000223)
,p_button_name=>'SEED_CASH'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة الصناديق والبنوك الافتراضية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000225)
,p_process_sequence=>26
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Seed Cash'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_csh_pkg.seed_defaults;',
'    apex_application.g_print_success_message := case when l_n > 0 then ''أضيف '' || l_n || '' (صندوق/حساب بنكي) افتراضي''',
'                                                     else ''موجودة مسبقاً؛ لم يضف شيء'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000224)
,p_internal_uid=>91820266000000225
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000226)
,p_plug_name=>'حالة صندوق أو حساب بنكي'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000227)
,p_name=>'P40_PLACE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000226)
,p_prompt=>'الصندوق / الحساب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''صندوق: '' || code || '' '' || name_ar d, ''BOX:'' || id r from csh_cash_box where company_id = noona_gl_pkg.company union all select ''بنك: '' || code || '' '' || name_ar || '' '' || account_no_masked, ''BANK:'' || id from csh_bank_account where company_id = noona_gl_pkg.company order by 1'
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
 p_id=>wwv_flow_imp.id(91820266000000228)
,p_name=>'P40_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000226)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,معلق (صندوق);SUSPENDED,مجمد (بنك);FROZEN,مغلق;CLOSED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000229)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000226)
,p_button_name=>'SET_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تطبيق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000230)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Place Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P40_PLACE like ''BOX:%'' then',
'    noona_csh_pkg.set_box_status(to_number(substr(:P40_PLACE, 5)), :P40_STATUS);',
'else',
'    noona_csh_pkg.set_bank_status(to_number(substr(:P40_PLACE, 6)), :P40_STATUS);',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000229)
,p_process_success_message=>'تم تغيير الحالة'
,p_internal_uid=>91820266000000230
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000231)
,p_branch_action=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:40::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
