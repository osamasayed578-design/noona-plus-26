prompt --application/pages/page_00013
begin
--   Manifest
--     PAGE: 00013
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
 p_id=>13
,p_name=>'Route'
,p_alias=>'ROUTE'
,p_step_title=>'خط سير'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000179)
,p_plug_name=>'خط السير'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">أيام الزيارة مفصولة بفواصل: SUN,MON,TUE,WED,THU,FRI,SAT. المحل يرث أيام خطه ما لم تحدد له أياماً خاصة.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000180)
,p_name=>'P13_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000179)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000181)
,p_name=>'P13_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000179)
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
 p_id=>wwv_flow_imp.id(91820300000000182)
,p_name=>'P13_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000179)
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
 p_id=>wwv_flow_imp.id(91820300000000183)
,p_name=>'P13_REP'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820300000000179)
,p_prompt=>'المندوب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select full_name || '' ('' || code || '')'' d, id r from dst_rep where company_id = noona_dst_pkg.company and status_code = ''ACTIVE'' order by full_name'
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
 p_id=>wwv_flow_imp.id(91820300000000184)
,p_name=>'P13_REGION'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820300000000179)
,p_prompt=>'المنطقة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>100
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
 p_id=>wwv_flow_imp.id(91820300000000185)
,p_name=>'P13_DAYS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820300000000179)
,p_prompt=>'أيام الزيارة'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'STATIC2:الأحد;SUN,الاثنين;MON,الثلاثاء;TUE,الأربعاء;WED,الخميس;THU,الجمعة;FRI,السبت;SAT'
,p_lov_columns=>7
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000186)
,p_name=>'P13_STATUS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820300000000179)
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
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000187)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for r in (select * from dst_route where id = :P13_ID and company_id = noona_dst_pkg.company) loop',
'    :P13_CODE := r.code; :P13_NAME := r.name_ar; :P13_REP := r.rep_id; :P13_REGION := r.region_name;',
'    :P13_DAYS := replace(r.visit_days, '','', '':''); :P13_STATUS := r.status_code;',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820300000000187
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820300000000189)
,p_validation_name=>'P13_CODE required (SAVE)'
,p_validation_sequence=>9
,p_validation=>'P13_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820300000000188)
,p_associated_item=>wwv_flow_imp.id(91820300000000181)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820300000000190)
,p_validation_name=>'P13_NAME required (SAVE)'
,p_validation_sequence=>10
,p_validation=>'P13_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820300000000188)
,p_associated_item=>wwv_flow_imp.id(91820300000000182)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000188)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000179)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000191)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t();',
'begin',
'  l.put(''id'', to_number(:P13_ID)); l.put(''code'', :P13_CODE); l.put(''name'', :P13_NAME); l.put(''rep'', to_number(:P13_REP));',
'  l.put(''region'', :P13_REGION); l.put(''days'', replace(:P13_DAYS, '':'', '','')); l.put(''status'', :P13_STATUS);',
'  :P13_ID := noona_dst_pkg.save_route(l.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000188)
,p_process_success_message=>'تم حفظ خط السير'
,p_internal_uid=>91820300000000191
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000192)
,p_plug_name=>'محلات الخط'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P13_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_h clob;',
'begin',
'  for s in (select id, route_seq, noona_sal_pkg.customer_label(customer_account_id) nm, landmark, latitude from dst_shop',
'             where route_id = :P13_ID order by route_seq nulls last, id) loop',
'    l_h := l_h || ''<tr><td>'' || s.route_seq || ''</td><td><a href="'' || apex_page.get_url(p_page => 15, p_clear_cache => ''15'', p_items => ''P15_ID'', p_values => s.id)',
'        || ''">'' || apex_escape.html(s.nm) || ''</a></td><td>'' || apex_escape.html(s.landmark) || ''</td><td>''',
'        || case when s.latitude is not null then ''<span class="fa fa-map-marker"></span>'' else ''-'' end || ''</td></tr>'';',
'  end loop;',
'  return case when l_h is null then ''<p class="nn-hint">لا محلات في هذا الخط بعد.</p>''',
'    else ''<table class="nn-table"><thead><tr><th>الترتيب</th><th>المحل</th><th>علامة</th><th>الموقع</th></tr></thead><tbody>'' || l_h || ''</tbody></table>'' end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000193)
,p_branch_action=>'f?p=&APP_ID.:13:&SESSION.::&DEBUG.::P13_ID:&P13_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
