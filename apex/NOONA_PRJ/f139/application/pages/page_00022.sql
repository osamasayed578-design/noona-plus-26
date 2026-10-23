prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
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
 p_id=>22
,p_name=>'New Reservation'
,p_alias=>'NEW-RESERVATION'
,p_step_title=>'حجز جديد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000010)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000209)
,p_plug_name=>'النزيل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000210)
,p_name=>'P22_PROPERTY'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820273000000209)
,p_prompt=>'الفندق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from re_property p where p.company_id = noona_hsp_pkg.company and p.status_code <> ''INACTIVE'' and exists (select 1 from hsp_room r where r.property_id = p.id) order by p.code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000211)
,p_name=>'P22_GUEST'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000209)
,p_prompt=>'اسم النزيل'
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
 p_id=>wwv_flow_imp.id(91820273000000212)
,p_name=>'P22_PHONE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000209)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820273000000213)
,p_name=>'P22_IDTYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000209)
,p_prompt=>'نوع الهوية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:هوية وطنية;NATIONAL_ID,إقامة;IQAMA,جواز سفر;PASSPORT,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000214)
,p_name=>'P22_IDNO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000209)
,p_prompt=>'رقم الهوية / الإقامة / الجواز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820273000000215)
,p_name=>'P22_NAT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000209)
,p_prompt=>'الجنسية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, country_code r from ref_country where is_active = ''Y'' order by nvl(sort_order, 999), name_ar'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000216)
,p_name=>'P22_COMPANY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000209)
,p_prompt=>'الشركة الحاجزة (اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select display_name_ar d, id r from pty_party where party_type = ''ORGANIZATION'' and status_code = ''ACTIVE'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000217)
,p_plug_name=>'الإقامة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000218)
,p_name=>'P22_ARR'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'الوصول'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609122147107268652
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
 p_id=>wwv_flow_imp.id(91820273000000219)
,p_name=>'P22_DEP'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'المغادرة'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
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
 p_id=>wwv_flow_imp.id(91820273000000220)
,p_name=>'P22_RT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'نوع الغرفة / الشقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || noona_hsp_pkg.available_count(property_id, id, to_date(:P22_ARR, ''YYYY-MM-DD''), to_date(:P22_DEP, ''YYYY-MM-DD'')) || '' متاحة)'' d, id r from hsp_room_type where property_id = :P22_PROPERTY and is_active = ''Y'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P22_PROPERTY,P22_ARR,P22_DEP'
,p_ajax_items_to_submit=>'P22_PROPERTY,P22_ARR,P22_DEP'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000221)
,p_name=>'P22_ROOM'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'غرفة محددة (اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.room_no || '' - '' || t.name_ar d, r.id r from hsp_room r join hsp_room_type t on t.id = r.room_type_id where r.property_id = :P22_PROPERTY and r.status_code = ''ACTIVE'' and noona_hsp_pkg.is_free(r.id, to_date(:P22_ARR, ''YYYY-MM-DD''), to_date(:P22_DEP, ''YYYY-MM-DD'')) = ''Y'' order by r.room_no'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- أول غرفة متاحة من النوع -'
,p_lov_cascade_parent_items=>'P22_PROPERTY,P22_ARR,P22_DEP'
,p_ajax_items_to_submit=>'P22_PROPERTY,P22_ARR,P22_DEP'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000222)
,p_name=>'P22_PLAN'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'خطة السعر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from hsp_rate_plan where property_id = :P22_PROPERTY and is_active = ''Y'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P22_PROPERTY'
,p_ajax_items_to_submit=>'P22_PROPERTY'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000223)
,p_name=>'P22_RATE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'سعر الليلة (يترك للسعر المعتمد)'
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
 p_id=>wwv_flow_imp.id(91820273000000224)
,p_name=>'P22_ADULTS'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'البالغون'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000225)
,p_name=>'P22_CHILDREN'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'الأطفال'
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
 p_id=>wwv_flow_imp.id(91820273000000226)
,p_name=>'P22_CHANNEL'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'قناة الحجز'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:هاتف;PHONE,حضور مباشر;WALK_IN,بريد إلكتروني;EMAIL,الموقع;WEBSITE,منصات الحجز (بوكينج وغيرها);OTA,شركات;CORPORATE,وكيل سفر;TRAVEL_AGENT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000227)
,p_name=>'P22_CREF'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'مرجع القناة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820273000000228)
,p_name=>'P22_REQ'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820273000000217)
,p_prompt=>'طلبات خاصة'
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000229)
,p_plug_name=>'العربون'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000230)
,p_name=>'P22_DEPOSIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000229)
,p_prompt=>'مبلغ العربون'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000231)
,p_name=>'P22_DMETHOD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000229)
,p_prompt=>'طريقة السداد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نقداً;CASH,شبكة / بطاقة;CARD,تحويل بنكي;BANK_TRANSFER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000232)
,p_name=>'P22_BANK'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000229)
,p_prompt=>'الحساب البنكي (للشبكة والتحويل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_bank_account where company_id = noona_hsp_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000233)
,p_name=>'P22_BOX'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000229)
,p_prompt=>'الصندوق (للنقد)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_cash_box where company_id = noona_hsp_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000234)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000229)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تأكيد الحجز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000235)
,p_name=>'P22_ID'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000229)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000236)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P22_PROPERTY := nvl(:P22_PROPERTY, noona_hsp_pkg.default_property);',
'    :P22_ARR := nvl(:P22_ARR, to_char(noona_hsp_pkg.business_date(:P22_PROPERTY), ''YYYY-MM-DD''));',
'    :P22_DEP := nvl(:P22_DEP, to_char(to_date(:P22_ARR, ''YYYY-MM-DD'') + 1, ''YYYY-MM-DD''));',
'    :P22_ADULTS := nvl(:P22_ADULTS, 1); :P22_CHILDREN := nvl(:P22_CHILDREN, 0); :P22_CHANNEL := nvl(:P22_CHANNEL, ''PHONE'');',
'    :P22_IDTYPE := nvl(:P22_IDTYPE, ''NATIONAL_ID''); :P22_NAT := nvl(:P22_NAT, ''SA''); :P22_DMETHOD := nvl(:P22_DMETHOD, ''CASH'');',
'    if :P22_ROOM is not null and :P22_RT is null then',
'        select max(room_type_id) into :P22_RT from hsp_room where id = :P22_ROOM;',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000236
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000237)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''property'' value to_number(:P22_PROPERTY), ''guest_name'' value :P22_GUEST, ''phone'' value :P22_PHONE, ''id_type'' value :P22_IDTYPE, ''id_no'' value :P22_IDNO, ''nationality'' value :P22_NAT, ''company_party'' value to_number(:P22_COMPANY), ''arrival'' value :P22_ARR, ''departure'' value :P22_DEP, ''room_type'' value to_number(:P22_RT), ''room'' value to_number(:P22_ROOM), ''rate_plan'' value to_number(:P22_PLAN), ''rate'' value to_number(:P22_RATE), ''adults'' value to_number(:P22_ADULTS), ''children'' value to_number(:P22_CHILDREN), ''channel'' value :P22_CHANNEL, ''channel_ref'' value :P22_CREF, ''requests'' value :P22_REQ, ''deposit'' value to_number(:P22_DEPOSIT), ''deposit_method'' value :P22_DMETHOD, ''bank_account'' value to_number(:P22_BANK), ''cash_box'' value to_number(:P22_BOX) returning clob) into l_doc from dual;',
'    :P22_ID := noona_hsp_pkg.create_reservation(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000234)
,p_process_success_message=>'تم تأكيد الحجز'
,p_internal_uid=>91820273000000237
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000238)
,p_branch_action=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:RP,23:P23_ID:&P22_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820273000000234)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000239)
,p_branch_action=>'f?p=&APP_ID.:22:&SESSION.::&DEBUG.::P22_PROPERTY:&P22_PROPERTY.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
