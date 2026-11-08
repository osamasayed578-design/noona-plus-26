prompt --application/pages/page_00044
begin
--   Manifest
--     PAGE: 00044
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
 p_id=>44
,p_name=>'Owners'
,p_alias=>'PROPERTY-OWNERS'
,p_step_title=>'إدارة أملاك الغير'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000859)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001098)
,p_plug_name=>'اتفاقيات الإدارة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prp_pkg.agreements_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001099)
,p_plug_name=>'اتفاقية جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">إيجارات العقار المدار تقيد مستحقة للمالك، وتخصم الأتعاب والمصروفات في كشف المالك ثم يحول الصافي.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001100)
,p_name=>'P44_OWNER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_prompt=>'المالك (مسجل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select display_name_ar d, id r from pty_party p where status_code = ''ACTIVE'' and exists (select 1 from pty_party_role x where x.party_id = p.id and x.role_code in (''OWNER'', ''LANDLORD'')) order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- مالك جديد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001101)
,p_name=>'P44_OWNER_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_prompt=>'أو اسم مالك جديد'
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
 p_id=>wwv_flow_imp.id(91820273000001102)
,p_name=>'P44_PROPERTY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_prompt=>'العقار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from re_property where company_id = noona_res_pkg.company and status_code <> ''INACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000001103)
,p_name=>'P44_FEE_TYPE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_prompt=>'الأتعاب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نسبة من المحصل;PCT_OF_COLLECTION,نسبة من الإيجار;PCT_OF_RENT,مبلغ شهري ثابت;FIXED_MONTHLY,نسبة ومبلغ;MIXED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001104)
,p_name=>'P44_FEE_PCT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_prompt=>'النسبة %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001105)
,p_name=>'P44_FEE_FIXED'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_prompt=>'المبلغ الشهري'
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
 p_id=>wwv_flow_imp.id(91820273000001106)
,p_name=>'P44_REMIT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_prompt=>'التحويل للمالك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:شهري;MONTHLY,ربع سنوي;QUARTERLY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001107)
,p_name=>'P44_FROM'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_prompt=>'من'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000001109)
,p_validation_name=>'P44_PROPERTY required (SAVE_AGR)'
,p_validation_sequence=>10
,p_validation=>'P44_PROPERTY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000001108)
,p_associated_item=>wwv_flow_imp.id(91820273000001102)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000001108)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001099)
,p_button_name=>'SAVE_AGR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الاتفاقية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001110)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Agreement'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_prp_pkg.save_agreement(json_object(''owner'' value to_number(:P44_OWNER), ''ownerName'' value :P44_OWNER_NAME,',
'              ''property'' value to_number(:P44_PROPERTY), ''feeType'' value :P44_FEE_TYPE, ''feePct'' value to_number(:P44_FEE_PCT),',
'              ''feeFixed'' value to_number(:P44_FEE_FIXED), ''remit'' value :P44_REMIT, ''from'' value :P44_FROM));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001108)
,p_process_success_message=>'تم حفظ الاتفاقية'
,p_internal_uid=>91820273000001110
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001111)
,p_plug_name=>'كشوف الملاك'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prp_pkg.statements_html(replace(apex_page.get_url(p_page => 45, p_items => ''P45_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001112)
,p_plug_name=>'كشف جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000001113)
,p_name=>'P44_AGR'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001112)
,p_prompt=>'الاتفاقية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.doc_no || '' - '' || p.display_name_ar || '' - '' || noona_re_pkg.property_name(a.property_id) d, a.id r from prp_management_agreement a join pty_party p on p.id = a.owner_party_id where a.company_id = noona_res_pkg.company and a.status_code = ''ACTIVE'' order by a.id desc'
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
 p_id=>wwv_flow_imp.id(91820273000001114)
,p_name=>'P44_S_FROM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001112)
,p_prompt=>'من'
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
 p_id=>wwv_flow_imp.id(91820273000001115)
,p_name=>'P44_S_TO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000001112)
,p_prompt=>'إلى'
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
 p_id=>wwv_flow_imp.id(91820273000001116)
,p_name=>'P44_EXPENSES'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000001112)
,p_prompt=>'مصروفات دفعت عن المالك'
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
 p_id=>wwv_flow_imp.id(91820273000001117)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000001112)
,p_button_name=>'STATEMENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إعداد الكشف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001118)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Statement'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_prp_pkg.owner_statement(:P44_AGR, to_date(:P44_S_FROM, ''YYYY-MM-DD''), to_date(:P44_S_TO, ''YYYY-MM-DD''),',
'              nvl(to_number(:P44_EXPENSES), 0));',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 45, p_items => ''P45_ID'', p_values => l_id));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000001117)
,p_internal_uid=>91820273000001118
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000001119)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P44_FEE_TYPE := nvl(:P44_FEE_TYPE, ''PCT_OF_COLLECTION''); :P44_REMIT := nvl(:P44_REMIT, ''MONTHLY'');',
'    :P44_S_FROM := nvl(:P44_S_FROM, to_char(add_months(trunc(sysdate, ''MM''), -1), ''YYYY-MM-DD''));',
'    :P44_S_TO := nvl(:P44_S_TO, to_char(trunc(sysdate, ''MM'') - 1, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000001119
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000001120)
,p_branch_action=>'f?p=&APP_ID.:44:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
