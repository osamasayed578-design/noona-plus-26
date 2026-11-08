prompt --application/pages/page_00093
begin
--   Manifest
--     PAGE: 00093
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
 p_id=>93
,p_name=>'Equipment'
,p_alias=>'EQUIPMENT'
,p_step_title=>'المعدات وتشغيلها على المشروعات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000826)
,p_plug_name=>'تشغيل المعدات هذا الشهر'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prj_ctr_pkg.equipment_html(trunc(sysdate, ''MM''), trunc(sysdate));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000827)
,p_plug_name=>'معدة جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000828)
,p_name=>'P93_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000827)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>50
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000829)
,p_name=>'P93_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000827)
,p_prompt=>'الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000830)
,p_name=>'P93_ETYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000827)
,p_prompt=>'النوع (حفار، رافعة، خلاطة...)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
 p_id=>wwv_flow_imp.id(91820273000000831)
,p_name=>'P93_OWN'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000827)
,p_prompt=>'الملكية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مملوكة;OWNED,مستأجرة;RENTED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000832)
,p_name=>'P93_RATE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000827)
,p_prompt=>'تكلفة الساعة'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000834)
,p_validation_name=>'P93_CODE required (SAVE_EQ)'
,p_validation_sequence=>7
,p_validation=>'P93_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000833)
,p_associated_item=>wwv_flow_imp.id(91820273000000828)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000835)
,p_validation_name=>'P93_NAME required (SAVE_EQ)'
,p_validation_sequence=>8
,p_validation=>'P93_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000833)
,p_associated_item=>wwv_flow_imp.id(91820273000000829)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000836)
,p_validation_name=>'P93_RATE required (SAVE_EQ)'
,p_validation_sequence=>9
,p_validation=>'P93_RATE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000833)
,p_associated_item=>wwv_flow_imp.id(91820273000000832)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000833)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000827)
,p_button_name=>'SAVE_EQ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ المعدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000837)
,p_plug_name=>'تسجيل تشغيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000838)
,p_name=>'P93_EQ'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000837)
,p_prompt=>'المعدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from prj_equipment where company_id = noona_prj_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000839)
,p_name=>'P93_PROJECT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000837)
,p_prompt=>'المشروع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from prj_project where company_id = noona_prj_pkg.company and status_code not in (''CLOSED'', ''CANCELLED'') order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000840)
,p_name=>'P93_WBS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000837)
,p_prompt=>'بند العمل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select lpad('' '', (wbs_level - 1) * 2) || code || '' - '' || name_ar d, id r from prj_wbs where project_id = :P93_PROJECT and status_code <> ''CANCELLED'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000841)
,p_name=>'P93_DATE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000837)
,p_prompt=>'التاريخ'
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
 p_id=>wwv_flow_imp.id(91820273000000842)
,p_name=>'P93_HOURS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000837)
,p_prompt=>'الساعات'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000843)
,p_name=>'P93_URATE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000837)
,p_prompt=>'تكلفة الساعة (فارغ = من بطاقة المعدة)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000845)
,p_validation_name=>'P93_EQ required (LOG)'
,p_validation_sequence=>18
,p_validation=>'P93_EQ'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000844)
,p_associated_item=>wwv_flow_imp.id(91820273000000838)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000846)
,p_validation_name=>'P93_PROJECT required (LOG)'
,p_validation_sequence=>19
,p_validation=>'P93_PROJECT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000844)
,p_associated_item=>wwv_flow_imp.id(91820273000000839)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000847)
,p_validation_name=>'P93_HOURS required (LOG)'
,p_validation_sequence=>20
,p_validation=>'P93_HOURS'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000844)
,p_associated_item=>wwv_flow_imp.id(91820273000000842)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000844)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000837)
,p_button_name=>'LOG'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تسجيل التشغيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000849)
,p_validation_name=>'P93_EQ required (POST)'
,p_validation_sequence=>22
,p_validation=>'P93_EQ'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000848)
,p_associated_item=>wwv_flow_imp.id(91820273000000838)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000850)
,p_validation_name=>'P93_PROJECT required (POST)'
,p_validation_sequence=>23
,p_validation=>'P93_PROJECT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000848)
,p_associated_item=>wwv_flow_imp.id(91820273000000839)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000851)
,p_validation_name=>'P93_HOURS required (POST)'
,p_validation_sequence=>24
,p_validation=>'P93_HOURS'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000848)
,p_associated_item=>wwv_flow_imp.id(91820273000000842)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000848)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000837)
,p_button_name=>'POST'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تحميل التشغيل على المشروع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000852)
,p_plug_name=>'بانتظار التحميل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob := ''<table class="nn-prj-t"><thead><tr><th>التاريخ</th><th>المعدة</th><th>المشروع</th><th class="n">الساعات</th><th class="n">التكلفة</th></tr></thead><tbody>'';',
'    n pls_integer := 0;',
'begin',
'    for r in (select u.usage_date, e.code || '' - '' || e.name_ar eq, p.code prj, u.hours, u.amount from prj_equipment_usage u',
'               join prj_equipment e on e.id = u.equipment_id join prj_project p on p.id = u.project_id where u.company_id = noona_prj_pkg.company and u.status_code = ''DRAFT'' order by u.usage_date) loop',
'        n := n + 1; l := l || ''<tr><td>'' || to_char(r.usage_date, ''YYYY-MM-DD'') || ''</td><td>'' || apex_escape.html(r.eq) || ''</td><td>''',
'            || apex_escape.html(r.prj) || ''</td><td class="n">'' || r.hours || ''</td><td class="n">'' || to_char(r.amount, ''FM999,999,990.00'') || ''</td></tr>'';',
'    end loop;',
'    return case when n = 0 then ''<div class="nn-empty">لا يوجد تشغيل بانتظار التحميل</div>'' else l || ''</tbody></table>'' end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000853)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P93_OWN := nvl(:P93_OWN, ''OWNED''); :P93_DATE := nvl(:P93_DATE, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000853
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000854)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Equipment'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l number;',
'begin',
'    select json_object(''code'' value :P93_CODE, ''name'' value :P93_NAME, ''type'' value :P93_ETYPE, ''ownership'' value :P93_OWN,',
'                       ''rate'' value to_number(:P93_RATE) returning clob) into l_doc from dual;',
'    l := noona_prj_ctr_pkg.save_equipment(l_doc); :P93_EQ := l; :P93_CODE := null; :P93_NAME := null; :P93_ETYPE := null; :P93_RATE := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000833)
,p_process_success_message=>'تم حفظ المعدة'
,p_internal_uid=>91820273000000854
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000855)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Log'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l number;',
'begin',
'    select json_object(''equipment'' value to_number(:P93_EQ), ''project'' value to_number(:P93_PROJECT), ''wbs'' value to_number(:P93_WBS),',
'                       ''date'' value :P93_DATE, ''hours'' value to_number(:P93_HOURS), ''rate'' value to_number(:P93_URATE) returning clob) into l_doc from dual;',
'    l := noona_prj_ctr_pkg.log_usage(l_doc); :P93_HOURS := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000844)
,p_process_success_message=>'تم تسجيل التشغيل'
,p_internal_uid=>91820273000000855
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000856)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Post'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_prj_ctr_pkg.post_usage(:P93_PROJECT);',
'    apex_application.g_print_success_message := ''تم تحميل '' || l || '' تشغيل على المشروع'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000848)
,p_internal_uid=>91820273000000856
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000857)
,p_branch_action=>'f?p=&APP_ID.:93:&SESSION.::&DEBUG.::P93_PROJECT,P93_EQ:&P93_PROJECT.,&P93_EQ.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
