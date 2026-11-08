prompt --application/pages/page_00033
begin
--   Manifest
--     PAGE: 00033
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
 p_id=>33
,p_name=>'Sale Contract'
,p_alias=>'SALE-CONTRACT'
,p_step_title=>'عقد بيع وحدة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000858)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000921)
,p_plug_name=>'العقد'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_res_pkg.contract_html(:P33_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000922)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000923)
,p_name=>'P33_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000922)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000924)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000922)
,p_button_name=>'BILL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'فوترة المستحق'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_res_pkg.contract_status(:P33_ID) not in (''DRAFT'', ''TERMINATED'', ''CANCELLED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000925)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000922)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000926)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000000922)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'العقود'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000927)
,p_plug_name=>'توقيع العقد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_res_pkg.contract_status(:P33_ID) in (''DRAFT'', ''APPROVED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000928)
,p_name=>'P33_SIGN_DATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000927)
,p_prompt=>'تاريخ التوقيع'
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
 p_id=>wwv_flow_imp.id(91820273000000929)
,p_name=>'P33_REG'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000927)
,p_prompt=>'رقم التوثيق (اختياري)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
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
 p_id=>wwv_flow_imp.id(91820273000000930)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000927)
,p_button_name=>'SIGN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'توقيع العقد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000931)
,p_plug_name=>'التسليم'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_res_pkg.contract_status(:P33_ID) in (''SIGNED'', ''REGISTERED'', ''UNDER_CONSTRUCTION'', ''READY_FOR_HANDOVER'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000932)
,p_name=>'P33_HO_DATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000931)
,p_prompt=>'موعد/تاريخ التسليم'
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
 p_id=>wwv_flow_imp.id(91820273000000933)
,p_name=>'P33_SNAGS_OPEN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000931)
,p_prompt=>'ملاحظات المعاينة المفتوحة (سطر لكل ملاحظة)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000934)
,p_name=>'P33_SNAGS_FIXED'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000931)
,p_prompt=>'ملاحظات تم إصلاحها (سطر لكل ملاحظة)'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000935)
,p_name=>'P33_KEYS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000931)
,p_prompt=>'عدد المفاتيح'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000936)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000931)
,p_button_name=>'SCHEDULE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'جدولة التسليم'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000937)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000931)
,p_button_name=>'SNAGS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ ملاحظات المعاينة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000938)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000000931)
,p_button_name=>'HANDOVER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسليم الوحدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000939)
,p_plug_name=>'الإفراغ (نقل الملكية)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_res_pkg.contract_status(:P33_ID) in (''SIGNED'', ''REGISTERED'', ''READY_FOR_HANDOVER'', ''HANDED_OVER'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000940)
,p_name=>'P33_DEED'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000939)
,p_prompt=>'رقم الصك الجديد'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
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
 p_id=>wwv_flow_imp.id(91820273000000941)
,p_name=>'P33_AUTH_REF'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000939)
,p_prompt=>'مرجع الجهة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
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
 p_id=>wwv_flow_imp.id(91820273000000942)
,p_name=>'P33_TT_DATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000939)
,p_prompt=>'تاريخ الإفراغ'
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
 p_id=>wwv_flow_imp.id(91820273000000943)
,p_name=>'P33_FEES'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000939)
,p_prompt=>'الرسوم'
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
 p_id=>wwv_flow_imp.id(91820273000000944)
,p_name=>'P33_FINANCED'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000939)
,p_prompt=>'بتمويل بنكي (قبل السداد الكامل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نعم;Y,لا;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000945)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000939)
,p_button_name=>'TITLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تسجيل الإفراغ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000946)
,p_plug_name=>'فسخ العقد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_res_pkg.contract_status(:P33_ID) in (''DRAFT'', ''APPROVED'', ''SIGNED'', ''REGISTERED'', ''UNDER_CONSTRUCTION'', ''READY_FOR_HANDOVER'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000947)
,p_name=>'P33_T_REASON'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000946)
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000948)
,p_name=>'P33_FORFEIT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000946)
,p_prompt=>'المبلغ المصادر من المحصل'
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
 p_id=>wwv_flow_imp.id(91820273000000949)
,p_name=>'P33_T_PLACE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000946)
,p_prompt=>'رد الباقي من'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''صندوق: '' || name_ar d, ''BOX:'' || id r from csh_cash_box where company_id = noona_res_pkg.company and status_code = ''ACTIVE'' union all select ''بنك: '' || name_ar, ''BANK:'' || id from csh_bank_account where company_id = noona_res_pkg.company and status_code = ''ACTIVE'''
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
 p_id=>wwv_flow_imp.id(91820273000000950)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000946)
,p_button_name=>'TERMINATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'فسخ العقد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000951)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P33_SIGN_DATE := nvl(:P33_SIGN_DATE, to_char(sysdate, ''YYYY-MM-DD''));',
'    :P33_HO_DATE := nvl(:P33_HO_DATE, to_char(sysdate, ''YYYY-MM-DD'')); :P33_FINANCED := nvl(:P33_FINANCED, ''N'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000951
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000952)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Sign'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_res_pkg.sign_contract(:P33_ID, to_date(:P33_SIGN_DATE, ''YYYY-MM-DD''), :P33_REG);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000930)
,p_process_success_message=>'تم توقيع العقد وفوترة الدفعة الأولى'
,p_internal_uid=>91820273000000952
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000953)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Bill'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_res_pkg.bill_installments(:P33_ID);',
'    apex_application.g_print_success_message := ''صدرت '' || l_n || '' فاتورة قسط'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000924)
,p_internal_uid=>91820273000000953
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000954)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Schedule'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_res_pkg.schedule_handover(:P33_ID, to_date(:P33_HO_DATE, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000936)
,p_process_success_message=>'تمت جدولة التسليم'
,p_internal_uid=>91820273000000954
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000955)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Snags'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_h number; l_j clob;',
'begin',
'    select max(id) into l_h from re_handover where contract_id = :P33_ID and status_code <> ''HANDED_OVER'';',
'    if l_h is null then l_h := noona_res_pkg.schedule_handover(:P33_ID, to_date(:P33_HO_DATE, ''YYYY-MM-DD'')); end if;',
'    select json_arrayagg(json_object(''item'' value v, ''status'' value s) returning clob) into l_j from (',
'      select trim(column_value) v, ''OPEN'' s from table(apex_string.split(:P33_SNAGS_OPEN, chr(10))) where trim(column_value) is not null',
'      union all select trim(column_value), ''FIXED'' from table(apex_string.split(:P33_SNAGS_FIXED, chr(10))) where trim(column_value) is not null);',
'    noona_res_pkg.save_snags(l_h, nvl(l_j, to_clob(''[]'')));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000937)
,p_process_success_message=>'تم حفظ ملاحظات المعاينة'
,p_internal_uid=>91820273000000955
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000956)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Handover'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_h number; l_j clob;',
'begin',
'    select max(id) into l_h from re_handover where contract_id = :P33_ID and status_code <> ''HANDED_OVER'';',
'    if l_h is null then l_h := noona_res_pkg.schedule_handover(:P33_ID, to_date(:P33_HO_DATE, ''YYYY-MM-DD'')); end if;',
'    if :P33_SNAGS_OPEN is not null or :P33_SNAGS_FIXED is not null then',
'        select json_arrayagg(json_object(''item'' value v, ''status'' value s) returning clob) into l_j from (',
'          select trim(column_value) v, ''OPEN'' s from table(apex_string.split(:P33_SNAGS_OPEN, chr(10))) where trim(column_value) is not null',
'          union all select trim(column_value), ''FIXED'' from table(apex_string.split(:P33_SNAGS_FIXED, chr(10))) where trim(column_value) is not null);',
'        noona_res_pkg.save_snags(l_h, nvl(l_j, to_clob(''[]'')));',
'    end if;',
'    noona_res_pkg.complete_handover(l_h, to_date(:P33_HO_DATE, ''YYYY-MM-DD''), to_number(:P33_KEYS));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000938)
,p_process_success_message=>'تم تسليم الوحدة والاعتراف بالإيراد'
,p_internal_uid=>91820273000000956
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000957)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Title'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_res_pkg.transfer_title(:P33_ID, json_object(''deed'' value :P33_DEED, ''ref'' value :P33_AUTH_REF,',
'              ''date'' value :P33_TT_DATE, ''fees'' value to_number(:P33_FEES), ''financed'' value :P33_FINANCED));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000945)
,p_process_success_message=>'تم تسجيل الإفراغ ونقل الملكية'
,p_internal_uid=>91820273000000957
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000958)
,p_process_sequence=>70
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Terminate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_res_pkg.terminate_contract(:P33_ID, :P33_T_REASON, nvl(to_number(:P33_FORFEIT), 0), :P33_T_PLACE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000950)
,p_process_success_message=>'تم فسخ العقد وتحرير الوحدة'
,p_internal_uid=>91820273000000958
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000959)
,p_branch_action=>'f?p=&APP_ID.:33:&SESSION.::&DEBUG.::P33_ID:&P33_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
