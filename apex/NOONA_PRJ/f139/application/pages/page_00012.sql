prompt --application/pages/page_00012
begin
--   Manifest
--     PAGE: 00012
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
 p_id=>12
,p_name=>'Property'
,p_alias=>'PROPERTY'
,p_step_title=>'بطاقة العقار'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000084)
,p_plug_name=>'العقار'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_re_pkg.property_card_html(:P12_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000085)
,p_plug_name=>'مخطط الوحدات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_re_pkg.stacking_html(:P12_ID, replace(apex_page.get_url(p_page => 13, p_items => ''P13_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000086)
,p_plug_name=>'تعديل بيانات العقار'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000087)
,p_name=>'P12_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000088)
,p_name=>'P12_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000089)
,p_name=>'P12_CODE'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820273000000090)
,p_name=>'P12_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:فندق;HOTEL,شقق فندقية;SERVICED_APARTMENTS,عمارة سكنية;BUILDING,برج;TOWER,مجمع سكني;COMPOUND,مجمع فلل;VILLA_COMPOUND,مركز تجاري;MALL,مجمع مكاتب;OFFICE_PARK,مستودعات;WAREHOUSE_PARK,مخطط أراض;LAND_SUBDIVISION'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000091)
,p_name=>'P12_CITY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'المدينة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from ref_city where is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820273000000092)
,p_name=>'P12_ADDRESS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
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
 p_id=>wwv_flow_imp.id(91820273000000093)
,p_name=>'P12_BRANCH'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'الفرع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = noona_re_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820273000000094)
,p_name=>'P12_MGMT'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'الملكية والإدارة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مملوك للمنشأة;OWNED,مدار لصالح مالك;MANAGED_FOR_OWNER,ملكية مشتركة;JOINT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000095)
,p_name=>'P12_OWNER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'المالك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select display_name_ar d, id r from pty_party p where status_code = ''ACTIVE'' and (party_type = ''ORGANIZATION'' or exists (select 1 from pty_party_role x where x.party_id = p.id and x.role_code in (''OWNER'', ''LANDLORD'', ''PARTNER''))) order by 1'
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
 p_id=>wwv_flow_imp.id(91820273000000096)
,p_name=>'P12_PHONE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'الهاتف'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820273000000097)
,p_name=>'P12_STARS'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'التصنيف (نجوم)'
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
 p_id=>wwv_flow_imp.id(91820273000000098)
,p_name=>'P12_LICENSE'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'الترخيص'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820273000000099)
,p_name=>'P12_CIN'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'وقت الدخول (HH:MI)'
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
 p_id=>wwv_flow_imp.id(91820273000000100)
,p_name=>'P12_COUT'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'وقت المغادرة (HH:MI)'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000101)
,p_name=>'P12_STATUS'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تشغيلي;OPERATIONAL,تحت التطوير;UNDER_DEVELOPMENT,تحت التجديد;UNDER_RENOVATION,مخطط;PLANNED,مباع بالكامل;SOLD_OUT,غير نشط;INACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000102)
,p_name=>'P12_DESC'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_prompt=>'الوصف والمرافق'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000104)
,p_validation_name=>'P12_NAME required (SAVE)'
,p_validation_sequence=>19
,p_validation=>'P12_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000103)
,p_associated_item=>wwv_flow_imp.id(91820273000000088)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000103)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000086)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000105)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select name_ar, code, property_type, city_id, address_text, branch_id, management_mode, owner_party_id, phone, star_rating,',
'           tourism_license_no, checkin_time, checkout_time, status_code, description',
'      into :P12_NAME, :P12_CODE, :P12_TYPE, :P12_CITY, :P12_ADDRESS, :P12_BRANCH, :P12_MGMT, :P12_OWNER, :P12_PHONE, :P12_STARS,',
'           :P12_LICENSE, :P12_CIN, :P12_COUT, :P12_STATUS, :P12_DESC',
'      from re_property where id = :P12_ID and company_id = noona_re_pkg.company;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000105
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000106)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number; l_doc clob;',
'begin',
'    select json_object(''id'' value to_number(:P12_ID), ''name_ar'' value :P12_NAME, ''code'' value :P12_CODE, ''type'' value :P12_TYPE, ''city'' value to_number(:P12_CITY), ''address'' value :P12_ADDRESS, ''branch'' value to_number(:P12_BRANCH), ''management_mode'' value :P12_MGMT, ''owner_party'' value to_number(:P12_OWNER), ''phone'' value :P12_PHONE, ''star_rating'' value to_number(:P12_STARS), ''license'' value :P12_LICENSE, ''checkin_time'' value :P12_CIN, ''checkout_time'' value :P12_COUT, ''status'' value :P12_STATUS, ''description'' value :P12_DESC returning clob) into l_doc from dual;',
'    l_id := noona_re_pkg.save_property(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000103)
,p_process_success_message=>'تم حفظ بيانات العقار'
,p_internal_uid=>91820273000000106
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000107)
,p_plug_name=>'إضافة مبنى وتوليد وحداته'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000108)
,p_name=>'P12_B_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'اسم المبنى'
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
 p_id=>wwv_flow_imp.id(91820273000000109)
,p_name=>'P12_B_CODE'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'الرمز (اختياري)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>8
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
 p_id=>wwv_flow_imp.id(91820273000000110)
,p_name=>'P12_B_FLOORS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'عدد الطوابق'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000111)
,p_name=>'P12_B_GROUND'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'دور أرضي'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000112)
,p_name=>'P12_B_PER'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'وحدات في كل طابق'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000113)
,p_name=>'P12_B_UTYPE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'نوع الوحدات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:شقة;APARTMENT,غرفة فندقية;ROOM,جناح;SUITE,استوديو;STUDIO,فيلا;VILLA,تاون هاوس;TOWNHOUSE,مكتب;OFFICE,محل;SHOP,معرض;SHOWROOM,مستودع;WAREHOUSE,موقف;PARKING,مخزن;STORAGE,قطعة أرض;LAND_PLOT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000114)
,p_name=>'P12_B_USAGE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'الاستخدام'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:للتأجير;LEASE,ضيافة/فندقي;HOSPITALITY,للبيع;SALE,متعدد;MIXED,استخدام المالك;OWNER_USE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000115)
,p_name=>'P12_B_AREA'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'المساحة م2'
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
 p_id=>wwv_flow_imp.id(91820273000000116)
,p_name=>'P12_B_BEDS'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'غرف النوم'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000117)
,p_name=>'P12_B_RT'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_prompt=>'نوع غرفة الضيافة (لتشغيلها فندقياً)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from hsp_room_type where property_id = :P12_ID and is_active = ''Y'' order by code'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000118)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000107)
,p_button_name=>'ADD_BUILDING'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة المبنى وتوليد الوحدات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000119)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Building'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_b number; l_n number; l_doc clob;',
'begin',
'    l_b := noona_re_pkg.add_building(:P12_ID, :P12_B_CODE, :P12_B_NAME, :P12_B_FLOORS, nvl(:P12_B_GROUND, ''N''));',
'    if :P12_B_PER is not null then',
'        select json_object(''building'' value l_b, ''per_floor'' value to_number(:P12_B_PER),',
'                 ''unit_type'' value :P12_B_UTYPE, ''usage_type'' value :P12_B_USAGE, ''area'' value to_number(:P12_B_AREA),',
'                 ''bedrooms'' value to_number(:P12_B_BEDS), ''room_type'' value to_number(:P12_B_RT) returning clob) into l_doc from dual;',
'        l_n := noona_re_pkg.generate_units(l_doc);',
'    end if;',
'    apex_application.g_print_success_message := ''تمت إضافة المبنى'' || case when l_n > 0 then '' و'' || l_n || '' وحدة'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000118)
,p_internal_uid=>91820273000000119
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000120)
,p_plug_name=>'المباني'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select b.id, b.code, b.name_ar, b.floors_count, (select count(*) from re_unit u where u.building_id = b.id) as units,',
'       noona_re_pkg.unit_status_label(b.status_code) as status from re_building b where b.property_id = :P12_ID order by b.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'المباني'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000121)
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
,p_internal_uid=>91820273000000121
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000123)
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
 p_id=>wwv_flow_imp.id(91820273000000124)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000125)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المبنى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000126)
,p_db_column_name=>'FLOORS_COUNT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الطوابق'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000127)
,p_db_column_name=>'UNITS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الوحدات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000128)
,p_db_column_name=>'STATUS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000122)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'122'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:FLOORS_COUNT:UNITS:STATUS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000129)
,p_branch_action=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.::P12_ID:&P12_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
