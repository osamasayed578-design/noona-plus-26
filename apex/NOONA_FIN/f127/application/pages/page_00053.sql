prompt --application/pages/page_00053
begin
--   Manifest
--     PAGE: 00053
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
 p_id=>53
,p_name=>'Consolidation Group'
,p_alias=>'CONSOLIDATION-GROUP'
,p_step_title=>'مجموعة التجميع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000936)
,p_plug_name=>'بيانات مجموعة التجميع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000937)
,p_name=>'P53_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000936)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000938)
,p_name=>'P53_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000936)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820266000000939)
,p_name=>'P53_NAME_AR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000936)
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
 p_id=>wwv_flow_imp.id(91820266000000940)
,p_name=>'P53_BG'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000936)
,p_prompt=>'مجموعة الأعمال (الشركة القابضة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from org_business_group where status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- كل شركات المؤسسة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000941)
,p_name=>'P53_CURRENCY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000936)
,p_prompt=>'عملة التجميع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select currency_code || '' - '' || name_ar d, currency_code r from ref_currency where is_active = ''Y'' order by case when currency_code = noona_gl_pkg.ledger_currency then 0 else 1 end, currency_code'
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
 p_id=>wwv_flow_imp.id(91820266000000942)
,p_name=>'P53_ELIM'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000936)
,p_prompt=>'حسابات استبعاد إضافية (أرقام مفصولة بفواصل)'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000944)
,p_validation_name=>'P53_CODE required (SAVE)'
,p_validation_sequence=>7
,p_validation=>'P53_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000943)
,p_associated_item=>wwv_flow_imp.id(91820266000000938)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000945)
,p_validation_name=>'P53_NAME_AR required (SAVE)'
,p_validation_sequence=>8
,p_validation=>'P53_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000943)
,p_associated_item=>wwv_flow_imp.id(91820266000000939)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000946)
,p_validation_name=>'P53_CURRENCY required (SAVE)'
,p_validation_sequence=>9
,p_validation=>'P53_CURRENCY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000943)
,p_associated_item=>wwv_flow_imp.id(91820266000000941)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000943)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000936)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000947)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000936)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:52:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000948)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P53_ID is not null then',
'    select code, name_ar, business_group_id, consolidation_currency into :P53_CODE, :P53_NAME_AR, :P53_BG, :P53_CURRENCY',
'      from gl_consolidation_group where id = :P53_ID;',
'    :P53_ELIM := noona_consol_pkg.elim_accounts(:P53_ID);',
'elsif :P53_CURRENCY is null then',
'    :P53_CURRENCY := noona_gl_pkg.ledger_currency;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000948
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000949)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P53_ID := noona_consol_pkg.save_group(:P53_ID, :P53_CODE, :P53_NAME_AR, :P53_BG, :P53_CURRENCY, :P53_ELIM);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000943)
,p_process_success_message=>'تم حفظ مجموعة التجميع'
,p_internal_uid=>91820266000000949
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000950)
,p_plug_name=>'الشركات المشمولة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P53_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div class="nn-hint">'' || apex_escape.html(noona_consol_pkg.members_text(:P53_ID)) || ''</div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000951)
,p_branch_action=>'f?p=&APP_ID.:53:&SESSION.::&DEBUG.::P53_ID:&P53_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
