prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>147
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>22
,p_name=>'New Trip'
,p_alias=>'NEW-TRIP'
,p_step_title=>'رحلة جديدة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000109)
,p_plug_name=>'الرحلة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يتحقق النظام من توفر العربة والسائق وسريان الرخص والتأمين، ومن الحمولة ونوع العربة والمواد الخطرة لكل شحنة. زمن الوصول المتوقع من الزمن القياسي للمسار ونقاط التوقف.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000110)
,p_name=>'P22_VEH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_prompt=>'العربة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select v.plate_no || '' · '' || v.vehicle_type || '' · '' || v.capacity_tons || '' طن · '' || noona_trn_pkg.status_label(v.status_code) d, v.id r from trn_vehicle v where v.company_id = noona_trn_pkg.company and v.status_code in (''AVAILABLE'', ''ON_TRIP'') order by v.plate_no'
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
 p_id=>wwv_flow_imp.id(91820290000000111)
,p_name=>'P22_DRV'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_prompt=>'السائق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.full_name || '' · '' || d.license_no || '' · '' || noona_trn_pkg.status_label(d.status_code) d, d.id r from trn_driver d where d.company_id = noona_trn_pkg.company and d.status_code in (''AVAILABLE'', ''ON_TRIP'') order by d.full_name'
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
 p_id=>wwv_flow_imp.id(91820290000000112)
,p_name=>'P22_CODRV'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_prompt=>'السائق المساعد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.full_name || '' · '' || d.license_no || '' · '' || noona_trn_pkg.status_label(d.status_code) d, d.id r from trn_driver d where d.company_id = noona_trn_pkg.company and d.status_code in (''AVAILABLE'', ''ON_TRIP'') order by d.full_name'
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
 p_id=>wwv_flow_imp.id(91820290000000113)
,p_name=>'P22_ROUTE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_prompt=>'المسار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.name_ar || '' · '' || r.distance_km || '' كم · '' || r.standard_hours || '' س'' d, r.id r from trn_route r where r.company_id = noona_trn_pkg.company and r.is_active = ''Y'' order by r.name_ar'
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
 p_id=>wwv_flow_imp.id(91820290000000114)
,p_name=>'P22_FROM'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_prompt=>'أو من'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from trn_location where company_id = noona_trn_pkg.company and is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820290000000115)
,p_name=>'P22_TO'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_prompt=>'إلى'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from trn_location where company_id = noona_trn_pkg.company and is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820290000000116)
,p_name=>'P22_DEP'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_prompt=>'موعد التحرك (YYYY-MM-DD HH24:MI)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>16
,p_cMaxlength=>16
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000117)
,p_name=>'P22_ORDERS'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_prompt=>'الشحنات المؤكدة المراد تحميلها'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'select o.doc_no || '' · '' || noona_sal_pkg.customer_label(o.customer_account_id) || '' · '' || noona_trn_pkg.order_label(o.id) d, o.id r from trn_order o where o.company_id = noona_trn_pkg.company and o.status_code = ''CONFIRMED'' order by o.pickup_date nulls last, o.id'
,p_lov_columns=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000118)
,p_name=>'P22_NOTES'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
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
 p_id=>wwv_flow_imp.id(91820290000000119)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P22_DEP is null then :P22_DEP := to_char(sysdate + 1/24, ''YYYY-MM-DD HH24'') || '':00''; end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000119
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000121)
,p_validation_name=>'P22_VEH required (CREATE)'
,p_validation_sequence=>11
,p_validation=>'P22_VEH'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000120)
,p_associated_item=>wwv_flow_imp.id(91820290000000110)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000122)
,p_validation_name=>'P22_DRV required (CREATE)'
,p_validation_sequence=>12
,p_validation=>'P22_DRV'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000120)
,p_associated_item=>wwv_flow_imp.id(91820290000000111)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820290000000123)
,p_validation_name=>'P22_DEP required (CREATE)'
,p_validation_sequence=>13
,p_validation=>'P22_DEP'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820290000000120)
,p_associated_item=>wwv_flow_imp.id(91820290000000116)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000120)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الرحلة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000124)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob; l_o varchar2(4000);',
'begin',
'  l_o := ''['' || replace(:P22_ORDERS, '':'', '','') || '']'';',
'  select json_object(''vehicle'' value to_number(:P22_VEH), ''driver'' value to_number(:P22_DRV), ''coDriver'' value to_number(:P22_CODRV),',
'         ''route'' value to_number(:P22_ROUTE), ''from'' value to_number(:P22_FROM), ''to'' value to_number(:P22_TO), ''departure'' value :P22_DEP,',
'         ''notes'' value :P22_NOTES, ''orders'' value l_o format json absent on null) into l from dual;',
'  :P21_ID := noona_trn_pkg.create_trip(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000120)
,p_process_success_message=>'تم إنشاء الرحلة'
,p_internal_uid=>91820290000000124
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000125)
,p_name=>'P22_DUMMY'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820290000000109)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000126)
,p_branch_action=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.::P21_ID:&P21_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
