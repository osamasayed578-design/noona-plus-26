prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>135
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Work Center'
,p_alias=>'WORK-CENTER'
,p_step_title=>'مركز عمل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000063)
,p_plug_name=>'مركز العمل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000064)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000065)
,p_name=>'P11_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000066)
,p_name=>'P11_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
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
 p_id=>wwv_flow_imp.id(91820270000000067)
,p_name=>'P11_CAP'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_prompt=>'الطاقة اليومية بالساعات'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000068)
,p_name=>'P11_LABOR'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_prompt=>'معدل العمالة للساعة'
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
 p_id=>wwv_flow_imp.id(91820270000000069)
,p_name=>'P11_MACHINE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_prompt=>'معدل الآلات للساعة (إهلاك وتشغيل)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000070)
,p_name=>'P11_OVERHEAD'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_prompt=>'معدل التحميل الصناعي للساعة'
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
 p_id=>wwv_flow_imp.id(91820270000000071)
,p_name=>'P11_CC'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_prompt=>'مركز التكلفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from gl_cost_center where company_id = noona_gl_pkg.company order by code'
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
 p_id=>wwv_flow_imp.id(91820270000000072)
,p_name=>'P11_ACTIVE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_prompt=>'نشط'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000073)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_j clob;',
'begin',
'    if :P11_ID is not null then',
'        l_j := noona_mfg_pkg.work_center_json(:P11_ID);',
'        :P11_CODE := json_value(l_j, ''$.code''); :P11_NAME := json_value(l_j, ''$.name''); :P11_CAP := json_value(l_j, ''$.cap'');',
'        :P11_LABOR := json_value(l_j, ''$.labor''); :P11_MACHINE := json_value(l_j, ''$.machine''); :P11_OVERHEAD := json_value(l_j, ''$.overhead'');',
'        :P11_CC := json_value(l_j, ''$.cc''); :P11_ACTIVE := json_value(l_j, ''$.active'');',
'    else',
'        :P11_CAP := nvl(:P11_CAP, 8); :P11_ACTIVE := nvl(:P11_ACTIVE, ''Y'');',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000073
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820270000000075)
,p_validation_name=>'P11_CODE required (SAVE)'
,p_validation_sequence=>11
,p_validation=>'P11_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820270000000074)
,p_associated_item=>wwv_flow_imp.id(91820270000000065)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820270000000076)
,p_validation_name=>'P11_NAME required (SAVE)'
,p_validation_sequence=>12
,p_validation=>'P11_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820270000000074)
,p_associated_item=>wwv_flow_imp.id(91820270000000066)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820270000000077)
,p_validation_name=>'P11_CAP required (SAVE)'
,p_validation_sequence=>13
,p_validation=>'P11_CAP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820270000000074)
,p_associated_item=>wwv_flow_imp.id(91820270000000067)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000074)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000078)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P11_ID := noona_mfg_pkg.save_work_center(json_object(''id'' value to_number(:P11_ID), ''code'' value :P11_CODE, ''name'' value :P11_NAME,',
'        ''cap'' value to_number(:P11_CAP), ''labor'' value to_number(:P11_LABOR), ''machine'' value to_number(:P11_MACHINE),',
'        ''overhead'' value to_number(:P11_OVERHEAD), ''cc'' value to_number(:P11_CC), ''active'' value nvl(:P11_ACTIVE, ''Y'')));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820270000000074)
,p_process_success_message=>'تم حفظ مركز العمل'
,p_internal_uid=>91820270000000078
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000079)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820270000000063)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820270000000080)
,p_branch_action=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
