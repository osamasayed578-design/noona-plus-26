prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Rep'
,p_alias=>'REP'
,p_step_title=>'مندوب'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000142)
,p_plug_name=>'المندوب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">إذا تركت مستودع السيارة والعهدة فارغين ينشئهما النظام (VAN-رمز، REP-رمز). اربط المندوب بمستخدم النظام ليفتح له تطبيق الهاتف خطته تلقائياً.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000143)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000144)
,p_name=>'P11_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820300000000145)
,p_name=>'P11_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
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
 p_id=>wwv_flow_imp.id(91820300000000146)
,p_name=>'P11_USER'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_prompt=>'مستخدم النظام'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(u.display_name, u.username) || '' ('' || u.username || '')'' d, upper(u.username) r from sec_user_membership m join sec_user u on u.id = m.user_id where m.status_code = ''ACTIVE'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820300000000147)
,p_name=>'P11_PHONE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>16
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
 p_id=>wwv_flow_imp.id(91820300000000148)
,p_name=>'P11_PLATE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_prompt=>'لوحة السيارة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>14
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000149)
,p_name=>'P11_WH'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_prompt=>'مستودع السيارة (موجود)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from inv_warehouse where company_id = noona_dst_pkg.company and status_code = ''ACTIVE'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- إنشاء تلقائي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000150)
,p_name=>'P11_BOX'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_prompt=>'العهدة النقدية (موجودة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from csh_cash_box where company_id = noona_dst_pkg.company and status_code = ''ACTIVE'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- إنشاء تلقائي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000151)
,p_name=>'P11_CREDIT'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_prompt=>'يبيع آجلاً ضمن حد المحل'
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000152)
,p_plug_name=>'العمولة والهدف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000153)
,p_name=>'P11_BASIS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000152)
,p_prompt=>'أساس العمولة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نسبة من المبيعات;SALES,نسبة من التحصيل;COLLECTION,مبلغ لكل زيارة منفذة;VISIT,بلا عمولة;NONE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000154)
,p_name=>'P11_RATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000152)
,p_prompt=>'النسبة %'
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
 p_id=>wwv_flow_imp.id(91820300000000155)
,p_name=>'P11_PERVISIT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820300000000152)
,p_prompt=>'مبلغ لكل زيارة منفذة'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000156)
,p_name=>'P11_TARGET'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820300000000152)
,p_prompt=>'الهدف الشهري للمبيعات'
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
 p_id=>wwv_flow_imp.id(91820300000000157)
,p_name=>'P11_STATUS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820300000000152)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,موقوف;INACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000158)
,p_name=>'P11_NOTES'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820300000000152)
,p_prompt=>'ملاحظات'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000159)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for r in (select * from dst_rep where id = :P11_ID and company_id = noona_dst_pkg.company) loop',
'    :P11_CODE := r.code; :P11_NAME := r.full_name; :P11_USER := r.user_name; :P11_PHONE := r.phone; :P11_PLATE := r.vehicle_plate;',
'    :P11_WH := r.van_warehouse_id; :P11_BOX := r.cash_box_id; :P11_CREDIT := r.credit_allowed; :P11_BASIS := r.commission_basis;',
'    :P11_RATE := r.commission_rate; :P11_PERVISIT := r.commission_per_visit; :P11_TARGET := r.monthly_target;',
'    :P11_STATUS := r.status_code; :P11_NOTES := r.notes;',
'  end loop;',
'  if :P11_ID is null and :P11_CREDIT is null then :P11_CREDIT := ''Y''; end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820300000000159
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820300000000161)
,p_validation_name=>'P11_CODE required (SAVE)'
,p_validation_sequence=>18
,p_validation=>'P11_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820300000000160)
,p_associated_item=>wwv_flow_imp.id(91820300000000144)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820300000000162)
,p_validation_name=>'P11_NAME required (SAVE)'
,p_validation_sequence=>19
,p_validation=>'P11_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820300000000160)
,p_associated_item=>wwv_flow_imp.id(91820300000000145)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000160)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000142)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000163)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t();',
'begin',
'  l.put(''id'', to_number(:P11_ID)); l.put(''code'', :P11_CODE); l.put(''name'', :P11_NAME); l.put(''user'', :P11_USER); l.put(''phone'', :P11_PHONE);',
'  l.put(''plate'', :P11_PLATE); l.put(''vanWarehouse'', to_number(:P11_WH)); l.put(''cashBox'', to_number(:P11_BOX)); l.put(''credit'', :P11_CREDIT);',
'  l.put(''basis'', :P11_BASIS); l.put(''rate'', to_number(:P11_RATE)); l.put(''perVisit'', to_number(:P11_PERVISIT));',
'  l.put(''target'', to_number(:P11_TARGET)); l.put(''status'', :P11_STATUS); l.put(''notes'', :P11_NOTES);',
'  :P11_ID := noona_dst_pkg.save_rep(l.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000160)
,p_process_success_message=>'تم حفظ المندوب'
,p_internal_uid=>91820300000000163
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000164)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.::P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
