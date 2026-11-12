prompt --application/pages/page_00015
begin
--   Manifest
--     PAGE: 00015
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
 p_id=>15
,p_name=>'Shop'
,p_alias=>'SHOP'
,p_step_title=>'محل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''dst.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000218)
,p_plug_name=>'المحل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">اختر عميلاً موجوداً أو اترك الحقل فارغاً واكتب الاسم لإنشاء عميل جديد.</p><button type="button" class="nn-dst-btn nn-dst-mygeo" data-lat="P15_LAT" data-lng="P15_LNG"><span class="fa fa-crosshairs"></span> موقعي الحالي</button>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000219)
,p_name=>'P15_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000220)
,p_name=>'P15_CUST'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'العميل (موجود)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_sal_pkg.customer_label(a.id) d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id where a.company_id = noona_dst_pkg.company and a.status_code = ''ACTIVE'' and nvl(c.is_walk_in, ''N'') = ''N'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- عميل جديد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000221)
,p_name=>'P15_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'اسم المحل (للعميل الجديد)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
 p_id=>wwv_flow_imp.id(91820300000000222)
,p_name=>'P15_OWNER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'صاحب المحل'
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
 p_id=>wwv_flow_imp.id(91820300000000223)
,p_name=>'P15_PHONE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
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
 p_id=>wwv_flow_imp.id(91820300000000224)
,p_name=>'P15_WA'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'واتساب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>16
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
 p_id=>wwv_flow_imp.id(91820300000000225)
,p_name=>'P15_TYPE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بقالة;GROCERY,سوبرماركت;SUPERMARKET,صيدلية;PHARMACY,مطعم;RESTAURANT,مقهى;CAFE,جملة;WHOLESALE,كشك;KIOSK,محطة وقود;STATION,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000226)
,p_name=>'P15_ROUTE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'خط السير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.name_ar || nvl2(r.rep_id, '' · '' || noona_dst_pkg.rep_label(r.rep_id), '''') d, r.id r from dst_route r where r.company_id = noona_dst_pkg.company and r.status_code = ''ACTIVE'' order by r.name_ar'
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
 p_id=>wwv_flow_imp.id(91820300000000227)
,p_name=>'P15_SEQ'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'ترتيب الزيارة'
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
 p_id=>wwv_flow_imp.id(91820300000000228)
,p_name=>'P15_DAYS'
,p_item_sequence=>75
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'أيام خاصة (فارغ = أيام الخط)'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'STATIC2:الأحد;SUN,الاثنين;MON,الثلاثاء;TUE,الأربعاء;WED,الخميس;THU,الجمعة;FRI,السبت;SAT'
,p_lov_columns=>7
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000229)
,p_name=>'P15_LAT'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'خط العرض'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>14
,p_cMaxlength=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000230)
,p_name=>'P15_LNG'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'خط الطول'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>14
,p_cMaxlength=>20
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
 p_id=>wwv_flow_imp.id(91820300000000231)
,p_name=>'P15_ADDR'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'العنوان'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000232)
,p_name=>'P15_LANDMARK'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'علامة مميزة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
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
 p_id=>wwv_flow_imp.id(91820300000000233)
,p_name=>'P15_LIMIT'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'حد الائتمان (للعميل الجديد)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000234)
,p_name=>'P15_STATUS'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,موقوف;INACTIVE,محظور;BLOCKED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000235)
,p_name=>'P15_NOTES'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(91820300000000218)
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
 p_id=>wwv_flow_imp.id(91820300000000236)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for s in (select * from dst_shop where id = :P15_ID and company_id = noona_dst_pkg.company) loop',
'    :P15_CUST := s.customer_account_id; :P15_OWNER := s.owner_name; :P15_PHONE := s.phone; :P15_WA := s.whatsapp; :P15_TYPE := s.shop_type;',
'    :P15_ROUTE := s.route_id; :P15_SEQ := s.route_seq; :P15_DAYS := replace(s.visit_days, '','', '':'');',
'    :P15_LAT := to_char(s.latitude, ''FM990.0000000''); :P15_LNG := to_char(s.longitude, ''FM990.0000000'');',
'    :P15_ADDR := s.address_text; :P15_LANDMARK := s.landmark; :P15_STATUS := s.status_code; :P15_NOTES := s.notes;',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820300000000236
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000237)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000218)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000238)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t();',
'begin',
'  l.put(''id'', to_number(:P15_ID)); l.put(''customer'', to_number(:P15_CUST)); l.put(''name'', :P15_NAME); l.put(''owner'', :P15_OWNER);',
'  l.put(''phone'', :P15_PHONE); l.put(''whatsapp'', :P15_WA); l.put(''type'', :P15_TYPE); l.put(''route'', to_number(:P15_ROUTE));',
'  l.put(''seq'', to_number(:P15_SEQ)); l.put(''days'', replace(:P15_DAYS, '':'', '','')); l.put(''lat'', to_number(:P15_LAT));',
'  l.put(''lng'', to_number(:P15_LNG)); l.put(''address'', :P15_ADDR); l.put(''landmark'', :P15_LANDMARK); l.put(''limit'', to_number(:P15_LIMIT));',
'  l.put(''status'', :P15_STATUS); l.put(''notes'', :P15_NOTES);',
'  :P15_ID := noona_dst_pkg.save_shop(l.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000237)
,p_process_success_message=>'تم حفظ المحل'
,p_internal_uid=>91820300000000238
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000239)
,p_plug_name=>'بطاقة المحل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P15_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dst_pkg.shop_card_html(:P15_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000240)
,p_branch_action=>'f?p=&APP_ID.:15:&SESSION.::&DEBUG.::P15_ID:&P15_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
