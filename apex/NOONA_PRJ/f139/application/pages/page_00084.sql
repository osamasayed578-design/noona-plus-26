prompt --application/pages/page_00084
begin
--   Manifest
--     PAGE: 00084
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
 p_id=>84
,p_name=>'WBS'
,p_alias=>'WBS'
,p_step_title=>'بنود العمل ونسب الإنجاز'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000617)
,p_plug_name=>'بنود العمل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prj_pkg.wbs_html(:P84_PROJECT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000618)
,p_plug_name=>'إضافة / تعديل بند'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000619)
,p_name=>'P84_PROJECT'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000620)
,p_name=>'P84_WBS'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_prompt=>'البند (فارغ = جديد)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select lpad('' '', (wbs_level - 1) * 2) || code || '' - '' || name_ar d, id r from prj_wbs where project_id = :P84_PROJECT and status_code <> ''CANCELLED'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- بند جديد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000621)
,p_name=>'P84_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>10
,p_cMaxlength=>50
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
 p_id=>wwv_flow_imp.id(91820273000000622)
,p_name=>'P84_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_prompt=>'الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>400
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000623)
,p_name=>'P84_PARENT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_prompt=>'البند الأب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select lpad('' '', (wbs_level - 1) * 2) || code || '' - '' || name_ar d, id r from prj_wbs where project_id = :P84_PROJECT and status_code <> ''CANCELLED'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000624)
,p_name=>'P84_WEIGHT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_prompt=>'الوزن في الإنجاز %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000625)
,p_name=>'P84_START'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_prompt=>'البداية'
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
 p_id=>wwv_flow_imp.id(91820273000000626)
,p_name=>'P84_END'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_prompt=>'النهاية'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000627)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_button_name=>'SAVE_WBS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ البند'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000628)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_button_name=>'DELETE_WBS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف البند'
,p_button_position=>'NEXT'
,p_button_condition=>':P84_WBS is not null'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000629)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000000618)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع للمشروع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:81:&SESSION.::&DEBUG.::P81_ID:&P84_PROJECT.'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000630)
,p_plug_name=>'تحديث نسبة الإنجاز'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000631)
,p_name=>'P84_PWBS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000630)
,p_prompt=>'البند'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select lpad('' '', (wbs_level - 1) * 2) || code || '' - '' || name_ar d, id r from prj_wbs where project_id = :P84_PROJECT and status_code <> ''CANCELLED'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000632)
,p_name=>'P84_PCT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000630)
,p_prompt=>'نسبة الإنجاز الفعلية %'
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
 p_id=>wwv_flow_imp.id(91820273000000633)
,p_name=>'P84_REMARKS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000630)
,p_prompt=>'ملاحظات / الإثبات'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>2000
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000635)
,p_validation_name=>'P84_PWBS required (PROGRESS)'
,p_validation_sequence=>17
,p_validation=>'P84_PWBS'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000634)
,p_associated_item=>wwv_flow_imp.id(91820273000000631)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000636)
,p_validation_name=>'P84_PCT required (PROGRESS)'
,p_validation_sequence=>18
,p_validation=>'P84_PCT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000634)
,p_associated_item=>wwv_flow_imp.id(91820273000000632)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000634)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000630)
,p_button_name=>'PROGRESS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل الإنجاز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000637)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P84_WBS is not null then',
'        select code, name_ar, parent_wbs_id, weight_pct, to_char(planned_start, ''YYYY-MM-DD''), to_char(planned_end, ''YYYY-MM-DD'')',
'          into :P84_CODE, :P84_NAME, :P84_PARENT, :P84_WEIGHT, :P84_START, :P84_END from prj_wbs where id = :P84_WBS;',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000637
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000638)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save WBS'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l_id number;',
'begin',
'    select json_object(''id'' value to_number(:P84_WBS), ''project'' value to_number(:P84_PROJECT), ''parent'' value to_number(:P84_PARENT),',
'                       ''code'' value :P84_CODE, ''name'' value :P84_NAME, ''weight'' value to_number(:P84_WEIGHT), ''start'' value :P84_START,',
'                       ''end'' value :P84_END returning clob) into l_doc from dual;',
'    l_id := noona_prj_pkg.save_wbs(l_doc);',
'    :P84_WBS := null; :P84_CODE := null; :P84_NAME := null; :P84_PARENT := null; :P84_WEIGHT := null; :P84_START := null; :P84_END := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000627)
,p_process_success_message=>'تم حفظ البند'
,p_internal_uid=>91820273000000638
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000639)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delete WBS'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_pkg.delete_wbs(:P84_WBS); :P84_WBS := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000628)
,p_process_success_message=>'تم حذف البند'
,p_internal_uid=>91820273000000639
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000640)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Progress'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_pkg.update_progress(:P84_PWBS, to_number(:P84_PCT), :P84_REMARKS);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000634)
,p_process_success_message=>'تم تسجيل نسبة الإنجاز'
,p_internal_uid=>91820273000000640
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000641)
,p_branch_action=>'f?p=&APP_ID.:84:&SESSION.::&DEBUG.:84:P84_PROJECT:&P84_PROJECT.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
