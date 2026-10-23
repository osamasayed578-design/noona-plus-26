prompt --application/pages/page_00074
begin
--   Manifest
--     PAGE: 00074
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
 p_id=>74
,p_name=>'Nursing Roster'
,p_alias=>'NURSE-ROSTER'
,p_step_title=>'ورديات التمريض والمناوبات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001043)
,p_plug_name=>'المناوبون الآن'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>3
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_nurse_pkg.on_duty_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001044)
,p_plug_name=>'تسجيل مناوبة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001045)
,p_name=>'P74_DATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000001044)
,p_prompt=>'التاريخ (بداية الوردية)'
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
 p_id=>wwv_flow_imp.id(91820275000001046)
,p_name=>'P74_SHIFT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000001044)
,p_prompt=>'الوردية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || start_time || '' - '' || end_time || '')'' d, id r from his_nurse_shift where company_id = noona_his_pkg.company and is_active = ''Y'' order by sort_order'
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
 p_id=>wwv_flow_imp.id(91820275000001047)
,p_name=>'P74_WARD'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000001044)
,p_prompt=>'الجناح أو القسم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_department where company_id = noona_his_pkg.company and dept_type in (''INPATIENT_WARD'', ''EMERGENCY'', ''NURSING'') order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000001048)
,p_name=>'P74_NURSE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000001044)
,p_prompt=>'الممرض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || case title when ''NURSE'' then '''' else '' - '' || title end d, id r from his_doctor where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by case title when ''NURSE'' then 0 else 1 end, name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000001049)
,p_name=>'P74_ROLE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000001044)
,p_prompt=>'الدور'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:ممرض;STAFF,مسؤول الوردية;CHARGE,مساعد تمريض;ASSISTANT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001050)
,p_name=>'P74_ROOMS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000001044)
,p_prompt=>'الغرف المسندة (101,102 - فارغ = كل الجناح)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820275000001051)
,p_name=>'P74_NOTES'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000001044)
,p_prompt=>'ملاحظات'
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
 p_id=>wwv_flow_imp.id(91820275000001053)
,p_validation_name=>'P74_DATE required (ASSIGN)'
,p_validation_sequence=>9
,p_validation=>'P74_DATE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000001052)
,p_associated_item=>wwv_flow_imp.id(91820275000001045)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000001054)
,p_validation_name=>'P74_SHIFT required (ASSIGN)'
,p_validation_sequence=>10
,p_validation=>'P74_SHIFT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000001052)
,p_associated_item=>wwv_flow_imp.id(91820275000001046)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000001055)
,p_validation_name=>'P74_WARD required (ASSIGN)'
,p_validation_sequence=>11
,p_validation=>'P74_WARD'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000001052)
,p_associated_item=>wwv_flow_imp.id(91820275000001047)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820275000001056)
,p_validation_name=>'P74_NURSE required (ASSIGN)'
,p_validation_sequence=>12
,p_validation=>'P74_NURSE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820275000001052)
,p_associated_item=>wwv_flow_imp.id(91820275000001048)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001052)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000001044)
,p_button_name=>'ASSIGN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ المناوبة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001057)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_nurse_pkg.seed_shifts;',
'    :P74_DATE := nvl(:P74_DATE, to_char(sysdate, ''YYYY-MM-DD''));',
'    :P74_COPY_FROM := nvl(:P74_COPY_FROM, to_char(sysdate, ''YYYY-MM-DD''));',
'    :P74_COPY_TO := nvl(:P74_COPY_TO, to_char(sysdate + 1, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000001057
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001058)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Assign'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number; l_doc clob;',
'begin',
'    select json_object(''date'' value :P74_DATE, ''shift'' value to_number(:P74_SHIFT), ''ward'' value to_number(:P74_WARD), ''nurse'' value to_number(:P74_NURSE),',
'           ''role'' value :P74_ROLE, ''rooms'' value :P74_ROOMS, ''notes'' value :P74_NOTES returning clob) into l_doc from dual;',
'    l := noona_his_nurse_pkg.assign_duty(l_doc);',
'    :P74_NURSE := null; :P74_ROOMS := null; :P74_NOTES := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000001052)
,p_process_success_message=>'حفظت المناوبة'
,p_internal_uid=>91820275000001058
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001059)
,p_plug_name=>'نسخ جدول يوم'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001060)
,p_name=>'P74_COPY_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000001059)
,p_prompt=>'من يوم'
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
 p_id=>wwv_flow_imp.id(91820275000001061)
,p_name=>'P74_COPY_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000001059)
,p_prompt=>'إلى يوم'
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
 p_id=>wwv_flow_imp.id(91820275000001062)
,p_name=>'P74_COPY_WARD'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000001059)
,p_prompt=>'الجناح'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_department where company_id = noona_his_pkg.company and dept_type in (''INPATIENT_WARD'', ''EMERGENCY'', ''NURSING'') order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل الأجنحة'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001063)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000001059)
,p_button_name=>'COPY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'نسخ المناوبات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001064)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Copy'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_nurse_pkg.copy_roster(to_date(:P74_COPY_FROM, ''YYYY-MM-DD''), to_date(:P74_COPY_TO, ''YYYY-MM-DD''), to_number(:P74_COPY_WARD));',
'    apex_application.g_print_success_message := ''نسخت '' || l || '' مناوبة'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000001063)
,p_internal_uid=>91820275000001064
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001065)
,p_plug_name=>'حذف مناوبة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>17
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001066)
,p_name=>'P74_DEL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000001065)
,p_prompt=>'المناوبة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select to_char(r.duty_date, ''YYYY-MM-DD'') || '' - '' || s.name_ar || '' - '' || w.name_ar || '' - '' || d.name_ar dd, r.id r from his_nurse_roster r join his_nurse_shift s on s.id = r.shift_id join his_department w on w.id = r.ward_id join his_doctor d on d.id = r.nurse_id where r.company_id = noona_his_pkg.company and r.duty_date >= trunc(sysdate) - 1 order by r.duty_date, s.sort_order, w.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000001067)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000001065)
,p_button_name=>'REMOVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001068)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remove'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_nurse_pkg.remove_duty(:P74_DEL);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000001067)
,p_process_success_message=>'حذفت المناوبة'
,p_internal_uid=>91820275000001068
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001069)
,p_plug_name=>'الورديات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>18
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001070)
,p_name=>'P74_SID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000001069)
,p_prompt=>'تعديل وردية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || start_time || '' - '' || end_time || '')'' d, id r from his_nurse_shift where company_id = noona_his_pkg.company and is_active = ''Y'' order by sort_order'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- وردية جديدة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001071)
,p_name=>'P74_SCODE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000001069)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>8
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
 p_id=>wwv_flow_imp.id(91820275000001072)
,p_name=>'P74_SNAME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000001069)
,p_prompt=>'الاسم'
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
 p_id=>wwv_flow_imp.id(91820275000001073)
,p_name=>'P74_SFROM'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000001069)
,p_prompt=>'من (HH24:MI)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>6
,p_cMaxlength=>5
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
 p_id=>wwv_flow_imp.id(91820275000001074)
,p_name=>'P74_STO'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000001069)
,p_prompt=>'إلى (HH24:MI)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>6
,p_cMaxlength=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001075)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000001069)
,p_button_name=>'SAVE_SHIFT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ الوردية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001076)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Shift'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_nurse_pkg.save_shift(to_number(:P74_SID), :P74_SCODE, :P74_SNAME, :P74_SFROM, :P74_STO);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000001075)
,p_process_success_message=>'حفظت الوردية'
,p_internal_uid=>91820275000001076
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001077)
,p_plug_name=>'جدول المناوبات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, r.duty_date, s.name_ar || '' '' || s.start_time || ''-'' || s.end_time as shift, w.name_ar as ward, d.name_ar as nurse,',
'       case r.duty_role when ''CHARGE'' then ''مسؤول الوردية'' when ''ASSISTANT'' then ''مساعد'' else ''ممرض'' end as duty_role, r.rooms, d.mobile, r.notes',
'  from his_nurse_roster r join his_nurse_shift s on s.id = r.shift_id join his_department w on w.id = r.ward_id join his_doctor d on d.id = r.nurse_id',
' where r.company_id = noona_his_pkg.company and r.duty_date between trunc(sysdate) - 7 and trunc(sysdate) + 14 order by r.duty_date, s.sort_order, w.name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'جدول المناوبات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000001078)
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
,p_internal_uid=>91820275000001078
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000001080)
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
 p_id=>wwv_flow_imp.id(91820275000001081)
,p_db_column_name=>'DUTY_DATE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'التاريخ'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000001082)
,p_db_column_name=>'SHIFT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الوردية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000001083)
,p_db_column_name=>'WARD'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الجناح'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000001084)
,p_db_column_name=>'NURSE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الممرض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000001085)
,p_db_column_name=>'DUTY_ROLE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الدور'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000001086)
,p_db_column_name=>'ROOMS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الغرف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000001087)
,p_db_column_name=>'MOBILE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الجوال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000001088)
,p_db_column_name=>'NOTES'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'ملاحظات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000001079)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'1079'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DUTY_DATE:SHIFT:WARD:NURSE:DUTY_ROLE:ROOMS:MOBILE:NOTES'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000001089)
,p_branch_action=>'f?p=&APP_ID.:74:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
