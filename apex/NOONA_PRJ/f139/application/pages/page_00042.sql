prompt --application/pages/page_00042
begin
--   Manifest
--     PAGE: 00042
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
 p_id=>42
,p_name=>'Lease Card'
,p_alias=>'LEASE'
,p_step_title=>'عقد الإيجار'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000859)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001063)
,p_plug_name=>'العقد'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prp_pkg.lease_html(:P42_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001064)
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
 p_id=>wwv_flow_imp.id(91820273000001065)
,p_name=>'P42_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000001064)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001066)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001064)
,p_button_name=>'EDIT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تعديل'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41:P41_ID:&P42_ID.'
,p_button_condition=>'noona_prp_pkg.lease_status(:P42_ID) = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001067)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000001064)
,p_button_name=>'ACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تفعيل العقد'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prp_pkg.lease_status(:P42_ID) in (''DRAFT'', ''APPROVED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001068)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000001064)
,p_button_name=>'BILL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'فوترة المستحق'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prp_pkg.lease_status(:P42_ID) in (''ACTIVE'', ''RENEWAL_PENDING'', ''RENEWED'', ''EXPIRED'', ''TERMINATED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001069)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820273000001064)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001070)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820273000001064)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'العقود'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:43:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001071)
,p_plug_name=>'التأمين'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_prp_pkg.lease_status(:P42_ID) not in (''DRAFT'', ''CANCELLED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001072)
,p_name=>'P42_PLACE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001071)
,p_prompt=>'الصندوق أو البنك'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001073)
,p_name=>'P42_DEDUCT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001071)
,p_prompt=>'خصومات من التأمين (عند الإخلاء)'
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
 p_id=>wwv_flow_imp.id(91820273000001074)
,p_name=>'P42_DEDUCT_REASON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000001071)
,p_prompt=>'سبب الخصم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>300
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001075)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001071)
,p_button_name=>'DEPOSIT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'استلام التأمين'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prp_pkg.lease_status(:P42_ID) in (''ACTIVE'', ''RENEWAL_PENDING'') and noona_prp_pkg.has_deposit(:P42_ID) = ''N'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001076)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000001071)
,p_button_name=>'SETTLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تسوية ورد التأمين'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prp_pkg.lease_status(:P42_ID) in (''TERMINATED'', ''EXPIRED'', ''RENEWED'') and noona_prp_pkg.has_deposit(:P42_ID) = ''Y'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001077)
,p_plug_name=>'التجديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_prp_pkg.lease_status(:P42_ID) in (''ACTIVE'', ''RENEWAL_PENDING'', ''EXPIRED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001078)
,p_name=>'P42_NEW_END'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001077)
,p_prompt=>'نهاية العقد الجديد'
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
 p_id=>wwv_flow_imp.id(91820273000001079)
,p_name=>'P42_NEW_RENT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001077)
,p_prompt=>'الإيجار السنوي الجديد'
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
 p_id=>wwv_flow_imp.id(91820273000001080)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001077)
,p_button_name=>'RENEW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إنشاء عقد التجديد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001081)
,p_plug_name=>'الإنهاء والإخلاء'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_prp_pkg.lease_status(:P42_ID) in (''ACTIVE'', ''RENEWAL_PENDING'', ''SIGNED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001082)
,p_name=>'P42_END_DATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001081)
,p_prompt=>'تاريخ الإخلاء'
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
 p_id=>wwv_flow_imp.id(91820273000001083)
,p_name=>'P42_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001081)
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
 p_id=>wwv_flow_imp.id(91820273000001084)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001081)
,p_button_name=>'TERMINATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إنهاء العقد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001085)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Activate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prp_pkg.activate_lease(:P42_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001067)
,p_process_success_message=>'تم تفعيل العقد وتوليد جدول الاستحقاقات'
,p_internal_uid=>91820273000001085
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001086)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Bill'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_prp_pkg.bill_rent(:P42_ID);',
'    apex_application.g_print_success_message := ''صدرت '' || l_n || '' فاتورة'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001068)
,p_internal_uid=>91820273000001086
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001087)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Deposit'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_prp_pkg.receive_deposit(:P42_ID, :P42_PLACE);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001075)
,p_process_success_message=>'تم استلام التأمين'
,p_internal_uid=>91820273000001087
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001088)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Settle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    noona_prp_pkg.settle_deposit(:P42_ID, case when to_number(:P42_DEDUCT) > 0 then json_array(json_object(''reason'' value :P42_DEDUCT_REASON,',
'                                 ''amount'' value to_number(:P42_DEDUCT))) end, :P42_PLACE);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001076)
,p_process_success_message=>'تمت تسوية التأمين'
,p_internal_uid=>91820273000001088
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001089)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Renew'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_prp_pkg.renew_lease(:P42_ID, to_date(:P42_NEW_END, ''YYYY-MM-DD''), to_number(:P42_NEW_RENT));',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 42, p_items => ''P42_ID'', p_values => l_id));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001080)
,p_internal_uid=>91820273000001089
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001090)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Terminate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prp_pkg.terminate_lease(:P42_ID, to_date(:P42_END_DATE, ''YYYY-MM-DD''), :P42_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001084)
,p_process_success_message=>'تم إنهاء العقد وتحرير الوحدات'
,p_internal_uid=>91820273000001090
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001091)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P42_END_DATE := nvl(:P42_END_DATE, to_char(sysdate, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000001091
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000001092)
,p_branch_action=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.::P42_ID:&P42_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
