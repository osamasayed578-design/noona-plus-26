prompt --application/pages/page_00031
begin
--   Manifest
--     PAGE: 00031
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>141
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>31
,p_name=>'Visit'
,p_alias=>'VISIT'
,p_step_title=>'الزيارة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000145)
,p_plug_name=>'الزيارة'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000146)
,p_name=>'P31_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820275000000145)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000147)
,p_name=>'P31_INVOICE'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820275000000145)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000148)
,p_plug_name=>'ملف الزيارة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P31_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_pkg.visit_html(:P31_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000149)
,p_plug_name=>'طلب خدمة (كشف، تحليل، أشعة، رسم قلب، إجراء، عملية، جلسة)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_pkg.is_open(:P31_ID) = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000150)
,p_name=>'P31_SERVICE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000149)
,p_prompt=>'الخدمة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select s.name_ar || '' ('' || noona_his_pkg.type_label(s.service_type) || '' - '' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from his_service s where s.company_id = noona_his_pkg.company and s.status_code = ''ACTIVE'' order by s.service_type, s.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000151)
,p_name=>'P31_QTY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000149)
,p_prompt=>'الكمية'
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
 p_id=>wwv_flow_imp.id(91820275000000152)
,p_name=>'P31_ONOTES'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000149)
,p_prompt=>'ملاحظات الطلب'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000153)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000149)
,p_button_name=>'ADD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الطلب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000154)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Order'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_pkg.add_order(:P31_ID, to_number(:P31_SERVICE), nvl(to_number(:P31_QTY), 1), null, :P31_ONOTES);',
'    :P31_SERVICE := null; :P31_QTY := null; :P31_ONOTES := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000153)
,p_process_success_message=>'أضيف الطلب'
,p_internal_uid=>91820275000000154
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000155)
,p_plug_name=>'موافقة التأمين أو إلغاء طلب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_pkg.is_open(:P31_ID) = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000156)
,p_name=>'P31_ORDER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000155)
,p_prompt=>'الطلب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select o.line_no || '' - '' || s.name_ar || '' ('' || noona_his_pkg.order_status_label(o.status_code) || '')'' d, o.id r from his_order o join his_service s on s.id = o.service_id where o.visit_id = :P31_ID and o.status_code in (''ORDERED'', ''APPROVAL_PENDING'') and o.invoice_id is null order by o.line_no'
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
 p_id=>wwv_flow_imp.id(91820275000000157)
,p_name=>'P31_APPROVAL'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000155)
,p_prompt=>'رقم الموافقة / سبب الرفض أو الإلغاء'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000158)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000155)
,p_button_name=>'APPROVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تسجيل الموافقة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000159)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000155)
,p_button_name=>'REJECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض التأمين (يحول نقدي)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000160)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000000155)
,p_button_name=>'CANCEL_ORDER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الطلب'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000161)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.set_approval(:P31_ORDER, :P31_APPROVAL, ''Y'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000158)
,p_process_success_message=>'سجلت الموافقة'
,p_internal_uid=>91820275000000161
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000162)
,p_process_sequence=>21
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.set_approval(:P31_ORDER, :P31_APPROVAL, ''N'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000159)
,p_process_success_message=>'سجل الرفض وتحولت الخدمة على المريض'
,p_internal_uid=>91820275000000162
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000163)
,p_process_sequence=>22
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel Order'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.cancel_order(:P31_ORDER, :P31_APPROVAL);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000160)
,p_process_success_message=>'ألغي الطلب'
,p_internal_uid=>91820275000000163
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000164)
,p_plug_name=>'ملاحظات الطبيب والتشخيص'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_pkg.is_open(:P31_ID) = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000165)
,p_name=>'P31_VITALS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000164)
,p_prompt=>'العلامات الحيوية (الضغط، الحرارة، النبض، الوزن)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>1000
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000166)
,p_name=>'P31_COMPLAINT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000164)
,p_prompt=>'الشكوى'
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
 p_id=>wwv_flow_imp.id(91820275000000167)
,p_name=>'P31_DIAG'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000164)
,p_prompt=>'التشخيص'
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
 p_id=>wwv_flow_imp.id(91820275000000168)
,p_name=>'P31_ICD'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000164)
,p_prompt=>'رمز ICD-10'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820275000000169)
,p_name=>'P31_DNOTES'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000164)
,p_prompt=>'ملاحظات وخطة العلاج'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000170)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000164)
,p_button_name=>'SAVE_NOTES'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ الملاحظات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000171)
,p_process_sequence=>4
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select vitals, chief_complaint, diagnosis, icd10, doctor_notes',
'      into :P31_VITALS, :P31_COMPLAINT, :P31_DIAG, :P31_ICD, :P31_DNOTES',
'      from his_visit where id = :P31_ID and company_id = noona_his_pkg.company;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000000171
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000172)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Notes'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''id'' value to_number(:P31_ID), ''vitals'' value :P31_VITALS, ''complaint'' value :P31_COMPLAINT, ''diagnosis'' value :P31_DIAG, ''icd10'' value :P31_ICD, ''notes'' value :P31_DNOTES returning clob) into l_doc from dual;',
'    noona_his_pkg.update_visit(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000170)
,p_process_success_message=>'حفظت الملاحظات'
,p_internal_uid=>91820275000000172
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000173)
,p_plug_name=>'المحاسبة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_pkg.is_open(:P31_ID) = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000174)
,p_plug_name=>'المستحق'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>24
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_pkg.is_open(:P31_ID) = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div class="nn-his-due"><span>المطلوب من المريض <b>'' || to_char(noona_his_pkg.unbilled_total(:P31_ID, ''PATIENT''), ''FM999G999G990D00'') || ''</b></span><span>مطالبة الجهة <b>'' || to_char(noona_his_pkg.unbilled_total(:P31_ID, ''PAYER''), ''FM999G999G990D00'') || ''</b></span></div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000175)
,p_name=>'P31_METHOD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000173)
,p_prompt=>'طريقة الدفع (آجل = على حساب المريض)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, code r from ref_payment_method where is_active = ''Y'' order by sort_order'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000176)
,p_name=>'P31_PLACE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000173)
,p_prompt=>'الصندوق/البنك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d, r from (select ''صندوق: '' || name_ar d, ''BOX:'' || id r, 1 o from csh_cash_box where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' union all select ''بنك: '' || name_ar, ''BANK:'' || id, 2 from csh_bank_account where company_id = noona_his_pkg.company and status_code = ''ACTIVE'') order by o, d'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الافتراضي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000177)
,p_name=>'P31_REF'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000173)
,p_prompt=>'مرجع الدفع (رقم العملية)'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000178)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000173)
,p_button_name=>'INVOICE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إصدار الفاتورة والتحصيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000179)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000173)
,p_button_name=>'CLOSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إقفال الزيارة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000180)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Invoice'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''visit'' value to_number(:P31_ID), ''method'' value :P31_METHOD, ''place'' value :P31_PLACE, ''ref'' value :P31_REF returning clob) into l_doc from dual;',
'    :P31_INVOICE := noona_his_pkg.create_invoice(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000178)
,p_process_success_message=>'صدرت الفاتورة'
,p_internal_uid=>91820275000000180
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000181)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.close_visit(:P31_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000179)
,p_process_success_message=>'أقفلت الزيارة'
,p_internal_uid=>91820275000000181
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000182)
,p_plug_name=>'فواتير الزيارة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, i.doc_no, i.doc_date, i.patient_total, i.payer_total, i.paid_amount, i.payment_method,',
'       case i.status_code when ''POSTED'' then ''مرحلة'' else ''ملغاة'' end as status,',
'       ''<span class="fa fa-print" aria-hidden="true"></span> طباعة'' as prn',
'  from his_invoice i where i.visit_id = :P31_ID order by i.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'فواتير الزيارة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000183)
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
,p_internal_uid=>91820275000000183
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000185)
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
 p_id=>wwv_flow_imp.id(91820275000000186)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الفاتورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000187)
,p_db_column_name=>'DOC_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000188)
,p_db_column_name=>'PATIENT_TOTAL'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'على المريض'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000189)
,p_db_column_name=>'PAYER_TOTAL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'على الجهة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000190)
,p_db_column_name=>'PAID_AMOUNT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المدفوع'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000191)
,p_db_column_name=>'PAYMENT_METHOD'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000192)
,p_db_column_name=>'STATUS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000193)
,p_db_column_name=>'PRN'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'طباعة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_column_link=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41:P41_ID:#ID#'
,p_column_linktext=>'#PRN#'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000184)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'184'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DOC_DATE:PATIENT_TOTAL:PAYER_TOTAL:PAID_AMOUNT:PAYMENT_METHOD:STATUS:PRN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000194)
,p_plug_name=>'نتائج الزيارة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>45
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.id, s.name_ar as service, d.name_ar as dept, case o.result_flag when ''CRITICAL'' then ''حرجة'' when ''ABNORMAL'' then ''غير طبيعية''',
'       else ''طبيعية'' end as flag, to_char(o.completed_at, ''YYYY-MM-DD HH24:MI'') as done_at,',
'       ''<span class="fa fa-file-text-o" aria-hidden="true"></span> التقرير'' as rpt',
'  from his_order o join his_service s on s.id = o.service_id join his_department d on d.id = o.department_id',
' where o.visit_id = :P31_ID and o.status_code = ''COMPLETED'' order by o.line_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'نتائج الزيارة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000195)
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
,p_internal_uid=>91820275000000195
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000197)
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
 p_id=>wwv_flow_imp.id(91820275000000198)
,p_db_column_name=>'SERVICE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الخدمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000199)
,p_db_column_name=>'DEPT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'القسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000200)
,p_db_column_name=>'FLAG'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'التقييم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000201)
,p_db_column_name=>'DONE_AT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الإنجاز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000202)
,p_db_column_name=>'RPT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'التقرير'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_column_link=>'f?p=&APP_ID.:52:&SESSION.::&DEBUG.:RP,52:P52_ID:#ID#'
,p_column_linktext=>'#RPT#'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000196)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'196'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'SERVICE:DEPT:FLAG:DONE_AT:RPT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000203)
,p_branch_action=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.::P41_ID:&P31_INVOICE.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820275000000178)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000204)
,p_branch_action=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.::P31_ID:&P31_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
