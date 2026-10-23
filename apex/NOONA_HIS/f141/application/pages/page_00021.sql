prompt --application/pages/page_00021
begin
--   Manifest
--     PAGE: 00021
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
 p_id=>21
,p_name=>'Book Appointment'
,p_alias=>'BOOK'
,p_step_title=>'حجز موعد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000097)
,p_plug_name=>'الموعد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000098)
,p_name=>'P21_PATIENT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_prompt=>'المريض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' - '' || mrn || nvl2(mobile, '' - '' || mobile, '''') d, id r from his_patient where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000099)
,p_name=>'P21_DOCTOR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_prompt=>'الطبيب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company and d.status_code = ''ACTIVE'' order by p.sort_order, p.name_ar, d.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000100)
,p_name=>'P21_DATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_prompt=>'التاريخ'
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
 p_id=>wwv_flow_imp.id(91820275000000101)
,p_name=>'P21_TIME'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_prompt=>'الوقت المتاح'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t d, t r from json_table(noona_his_pkg.free_slots(to_number(:P21_DOCTOR), to_date(:P21_DATE, ''YYYY-MM-DD'')), ''$[*]'' columns (t varchar2(5) path ''$''))'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر الوقت -'
,p_lov_cascade_parent_items=>'P21_DOCTOR,P21_DATE'
,p_ajax_items_to_submit=>'P21_DOCTOR,P21_DATE'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000102)
,p_name=>'P21_SERVICE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_prompt=>'الخدمة (فارغ = كشف الطبيب)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_his_pkg.service_name(s.id) || '' ('' || noona_his_pkg.type_label(s.service_type) || '' - '' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from his_service s where s.company_id = noona_his_pkg.company and s.status_code = ''ACTIVE'' order by s.service_type, s.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- كشف الطبيب -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000103)
,p_name=>'P21_CHANNEL'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_prompt=>'القناة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:هاتف;PHONE,حضوري;WALK_IN,الموقع;WEB,التطبيق;APP,تحويل;REFERRAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000104)
,p_name=>'P21_NOTES'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_prompt=>'ملاحظات'
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
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000105)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P21_DATE := nvl(:P21_DATE, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000000105
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000000107)
,p_validation_name=>'P21_PATIENT required (BOOK)'
,p_validation_sequence=>9
,p_validation=>'P21_PATIENT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000000106)
,p_associated_item=>wwv_flow_imp.id(91820275000000098)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000000108)
,p_validation_name=>'P21_DOCTOR required (BOOK)'
,p_validation_sequence=>10
,p_validation=>'P21_DOCTOR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000000106)
,p_associated_item=>wwv_flow_imp.id(91820275000000099)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000000109)
,p_validation_name=>'P21_DATE required (BOOK)'
,p_validation_sequence=>11
,p_validation=>'P21_DATE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000000106)
,p_associated_item=>wwv_flow_imp.id(91820275000000100)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000106)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_button_name=>'BOOK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حجز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000110)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_button_name=>'NEWP'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'مريض جديد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000111)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Book'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''patient'' value to_number(:P21_PATIENT), ''doctor'' value to_number(:P21_DOCTOR), ''service'' value to_number(:P21_SERVICE), ''date'' value :P21_DATE, ''time'' value :P21_TIME, ''channel'' value :P21_CHANNEL, ''notes'' value :P21_NOTES returning clob) into l_doc from dual;',
'    :P21_ID := noona_his_pkg.book(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000106)
,p_process_success_message=>'تم الحجز'
,p_internal_uid=>91820275000000111
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000112)
,p_name=>'P21_ID'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820275000000097)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000113)
,p_branch_action=>'f?p=&APP_ID.:22:&SESSION.::&DEBUG.::P22_ID:&P21_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
