prompt --application/pages/page_00015
begin
--   Manifest
--     PAGE: 00015
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>15
,p_name=>'Business Group'
,p_alias=>'BUSINESS-GROUP'
,p_step_title=>'مجموعة الأعمال'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000171)
,p_plug_name=>'بيانات المجموعة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000172)
,p_name=>'P15_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000171)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000173)
,p_name=>'P15_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000171)
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
 p_id=>wwv_flow_imp.id(91820262000000174)
,p_name=>'P15_NAME_AR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000171)
,p_prompt=>'اسم المجموعة (الشركة القابضة)'
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
 p_id=>wwv_flow_imp.id(91820262000000175)
,p_name=>'P15_NAME_EN'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000171)
,p_prompt=>'الاسم بالإنجليزية'
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
 p_id=>wwv_flow_imp.id(91820262000000176)
,p_name=>'P15_CURRENCY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000171)
,p_prompt=>'عملة التجميع (القوائم الموحدة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_CURRENCIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000006)||'.'
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
 p_id=>wwv_flow_imp.id(91820262000000177)
,p_name=>'P15_PARENT_ID'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000171)
,p_prompt=>'المجموعة الأم (اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from org_business_group where status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- مجموعة رئيسية -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000179)
,p_validation_name=>'P15_CODE required (SAVE)'
,p_validation_sequence=>7
,p_validation=>'P15_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000178)
,p_associated_item=>wwv_flow_imp.id(91820262000000173)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000180)
,p_validation_name=>'P15_NAME_AR required (SAVE)'
,p_validation_sequence=>8
,p_validation=>'P15_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000178)
,p_associated_item=>wwv_flow_imp.id(91820262000000174)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000181)
,p_validation_name=>'P15_CURRENCY required (SAVE)'
,p_validation_sequence=>9
,p_validation=>'P15_CURRENCY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000178)
,p_associated_item=>wwv_flow_imp.id(91820262000000176)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000178)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000171)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000182)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000171)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:14:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000183)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P15_ID is not null then',
'    select code, name_ar, name_en, consolidation_currency, parent_group_id',
'      into :P15_CODE, :P15_NAME_AR, :P15_NAME_EN, :P15_CURRENCY, :P15_PARENT_ID from org_business_group where id = :P15_ID;',
'elsif :P15_CURRENCY is null then',
'    select max(functional_currency) into :P15_CURRENCY from org_company where id = to_number(sys_context(''NOONA_CTX'', ''COMPANY_ID''));',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000183
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000184)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P15_ID := noona_consol_pkg.save_business_group(:P15_ID, :P15_CODE, :P15_NAME_AR, :P15_CURRENCY, :P15_PARENT_ID, :P15_NAME_EN);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000178)
,p_process_success_message=>'تم حفظ مجموعة الأعمال؛ اربط بها الشركات من شاشة كل شركة'
,p_internal_uid=>91820262000000184
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000185)
,p_plug_name=>'شركات المجموعة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P15_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob := ''<table class="nn-table"><thead><tr><th>الشركة</th><th>العملة</th><th>دليل الحسابات</th><th>الحالة</th></tr></thead><tbody>'';',
'begin',
'    for c in (select id, code, nvl(trade_name_ar, legal_name_ar) nm, functional_currency, status_code from org_company',
'               where business_group_id = :P15_ID order by code) loop',
'        l := l || ''<tr><td>'' || apex_escape.html(c.nm) || '' ('' || c.code || '')</td><td>'' || c.functional_currency || ''</td><td>''',
'          || case noona_gl_pkg.coa_mode(c.id) when ''GROUP'' then ''دليل المجموعة الموحد'' when ''OWN'' then ''دليل خاص بالشركة'' else ''لم تجهز ماليتها'' end',
'          || ''</td><td>'' || noona_ui_pkg.status_badge(c.status_code) || ''</td></tr>'';',
'    end loop;',
'    return l || ''</tbody></table>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000186)
,p_branch_action=>'f?p=&APP_ID.:15:&SESSION.::&DEBUG.::P15_ID:&P15_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
