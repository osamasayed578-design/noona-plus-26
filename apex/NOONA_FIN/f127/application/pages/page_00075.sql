prompt --application/pages/page_00075
begin
--   Manifest
--     PAGE: 00075
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
 p_id=>75
,p_name=>'Withholding Tax'
,p_alias=>'TAX-WHT'
,p_step_title=>'ضريبة الاستقطاع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000726)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000807)
,p_plug_name=>'استقطاع من مورد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يخصم الاستقطاع من المستحق للمورد (أقدم فواتيره المفتوحة) ويقيد مستحقاً للجهة في 2106، وتصدر شهادة مرقمة. يورد شهرياً بإقرار الاستقطاع.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000808)
,p_name=>'P75_SUP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000807)
,p_prompt=>'المورد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar || case when p.country_code is not null and p.country_code <> noona_loc_pkg.company_country then '' ('' || p.country_code || '' - غير مقيم)'' end d, a.id r from ap_supplier_account a join ap_supplier s on s.id = a.supplier_id join pty_party p on p.id = s.party_id where a.company_id = noona_loc_pkg.company order by 1'
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
 p_id=>wwv_flow_imp.id(91820266000000809)
,p_name=>'P75_CODE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000807)
,p_prompt=>'نوع الاستقطاع ونسبته'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select c.code || '' - '' || c.name_ar d, c.code r from loc_tax_code c join loc_tax_type t on t.id = c.tax_type_id where t.country_pack_id = noona_loc_pkg.company_pack and t.tax_category = ''WITHHOLDING'' and c.status_code = ''ACTIVE'' order by c.code'
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
 p_id=>wwv_flow_imp.id(91820266000000810)
,p_name=>'P75_BASE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000807)
,p_prompt=>'المبلغ المدفوع (الأساس)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000811)
,p_name=>'P75_DATE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000807)
,p_prompt=>'تاريخ الدفع'
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
 p_id=>wwv_flow_imp.id(91820266000000812)
,p_name=>'P75_SERVICE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000807)
,p_prompt=>'طبيعة الخدمة'
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
 p_id=>wwv_flow_imp.id(91820266000000814)
,p_validation_name=>'P75_SUP required (WITHHOLD)'
,p_validation_sequence=>6
,p_validation=>'P75_SUP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000813)
,p_associated_item=>wwv_flow_imp.id(91820266000000808)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000815)
,p_validation_name=>'P75_CODE required (WITHHOLD)'
,p_validation_sequence=>7
,p_validation=>'P75_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000813)
,p_associated_item=>wwv_flow_imp.id(91820266000000809)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000816)
,p_validation_name=>'P75_BASE required (WITHHOLD)'
,p_validation_sequence=>8
,p_validation=>'P75_BASE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000813)
,p_associated_item=>wwv_flow_imp.id(91820266000000810)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000813)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000807)
,p_button_name=>'WITHHOLD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إصدار الشهادة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000817)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Withhold'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_loc_pkg.withhold(json_object(''supplier'' value to_number(:P75_SUP), ''code'' value :P75_CODE, ''base'' value to_number(:P75_BASE),',
'              ''date'' value :P75_DATE, ''service'' value :P75_SERVICE));',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 76, p_items => ''P76_ID'', p_values => l_id));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000813)
,p_internal_uid=>91820266000000817
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000818)
,p_plug_name=>'الفترة'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000819)
,p_name=>'P75_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000818)
,p_prompt=>'من'
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
 p_id=>wwv_flow_imp.id(91820266000000820)
,p_name=>'P75_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000818)
,p_prompt=>'إلى'
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
 p_id=>wwv_flow_imp.id(91820266000000821)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000818)
,p_button_name=>'GO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000822)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P75_FROM := nvl(:P75_FROM, to_char(trunc(sysdate, ''MM''), ''YYYY-MM-DD''));',
'    :P75_TO := nvl(:P75_TO, to_char(sysdate, ''YYYY-MM-DD''));',
'    :P75_DATE := nvl(:P75_DATE, to_char(sysdate, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000822
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000823)
,p_plug_name=>'شهادات الاستقطاع'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_loc_pkg.withholding_html(to_date(:P75_FROM, ''YYYY-MM-DD''), to_date(:P75_TO, ''YYYY-MM-DD''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000824)
,p_plug_name=>'مدفوعات لموردين غير مقيمين'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_loc_pkg.wht_due_html(to_date(:P75_FROM, ''YYYY-MM-DD''), to_date(:P75_TO, ''YYYY-MM-DD''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000825)
,p_plug_name=>'إلغاء شهادة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000826)
,p_name=>'P75_CERT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000825)
,p_prompt=>'الشهادة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select w.certificate_no || '' - '' || p.display_name_ar || '' - '' || w.withheld_amount d, w.id r from loc_withholding_cert w join pty_party p on p.id = w.party_id where w.company_id = noona_loc_pkg.company and w.status_code = ''ISSUED'' order by w.id desc'
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
 p_id=>wwv_flow_imp.id(91820266000000827)
,p_name=>'P75_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000825)
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
 p_id=>wwv_flow_imp.id(91820266000000828)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000825)
,p_button_name=>'CANCEL_CERT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الشهادة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000829)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000825)
,p_button_name=>'VIEW_CERT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عرض وطباعة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000830)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_loc_pkg.cancel_withholding(:P75_CERT, :P75_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000828)
,p_process_success_message=>'تم إلغاء الشهادة وإعادة المبلغ مستحقاً للمورد'
,p_internal_uid=>91820266000000830
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000831)
,p_branch_action=>'f?p=&APP_ID.:76:&SESSION.::&DEBUG.:RP:P76_ID:&P75_CERT.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820266000000829)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000832)
,p_branch_action=>'f?p=&APP_ID.:75:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
