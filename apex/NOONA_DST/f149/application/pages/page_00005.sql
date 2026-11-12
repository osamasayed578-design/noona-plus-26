prompt --application/pages/page_00005
begin
--   Manifest
--     PAGE: 00005
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
 p_id=>5
,p_name=>'New Shop'
,p_alias=>'NEW-SHOP'
,p_step_title=>'محل جديد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''dst.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000099)
,p_plug_name=>'المحل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">من أمام المحل اضغط «موقعي» ليحفظ موقعه للتوزيع التالي. ينشأ حساب العميل تلقائياً.</p><button type="button" class="nn-dst-btn nn-dst-mygeo" data-lat="P5_LAT" data-lng="P5_LNG"><span class="fa fa-crosshairs"></span> موقعي</button>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000100)
,p_name=>'P5_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'اسم المحل'
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
 p_id=>wwv_flow_imp.id(91820300000000101)
,p_name=>'P5_OWNER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'صاحب المحل'
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
 p_id=>wwv_flow_imp.id(91820300000000102)
,p_name=>'P5_PHONE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'الجوال'
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
 p_id=>wwv_flow_imp.id(91820300000000103)
,p_name=>'P5_WA'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'واتساب (إن اختلف)'
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
 p_id=>wwv_flow_imp.id(91820300000000104)
,p_name=>'P5_TYPE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بقالة;GROCERY,سوبرماركت;SUPERMARKET,صيدلية;PHARMACY,مطعم;RESTAURANT,مقهى;CAFE,جملة;WHOLESALE,كشك;KIOSK,محطة وقود;STATION,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000105)
,p_name=>'P5_ROUTE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'خط السير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.name_ar || nvl2(r.rep_id, '' · '' || noona_dst_pkg.rep_label(r.rep_id), '''') d, r.id r from dst_route r where r.company_id = noona_dst_pkg.company and r.status_code = ''ACTIVE'' order by r.name_ar'
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
 p_id=>wwv_flow_imp.id(91820300000000106)
,p_name=>'P5_SEQ'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'ترتيب الزيارة في الخط'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000107)
,p_name=>'P5_LAT'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'خط العرض'
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
 p_id=>wwv_flow_imp.id(91820300000000108)
,p_name=>'P5_LNG'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'خط الطول'
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
 p_id=>wwv_flow_imp.id(91820300000000109)
,p_name=>'P5_ADDR'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'العنوان'
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
 p_id=>wwv_flow_imp.id(91820300000000110)
,p_name=>'P5_LANDMARK'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'علامة مميزة'
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
 p_id=>wwv_flow_imp.id(91820300000000111)
,p_name=>'P5_TAX'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'الرقم الضريبي'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820300000000112)
,p_name=>'P5_CR'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'السجل التجاري'
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
 p_id=>wwv_flow_imp.id(91820300000000113)
,p_name=>'P5_LIMIT'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_prompt=>'حد الائتمان (فارغ = نقدي فقط حسب سياسة الشركة)'
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
 p_id=>wwv_flow_imp.id(91820300000000114)
,p_name=>'P5_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820300000000116)
,p_validation_name=>'P5_NAME required (SAVE)'
,p_validation_sequence=>16
,p_validation=>'P5_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820300000000115)
,p_associated_item=>wwv_flow_imp.id(91820300000000100)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000115)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000099)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ المحل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000117)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t := json_object_t();',
'begin',
'  l.put(''name'', :P5_NAME); l.put(''owner'', :P5_OWNER); l.put(''phone'', :P5_PHONE); l.put(''whatsapp'', :P5_WA); l.put(''type'', :P5_TYPE);',
'  l.put(''route'', to_number(:P5_ROUTE)); l.put(''seq'', to_number(:P5_SEQ)); l.put(''lat'', to_number(:P5_LAT)); l.put(''lng'', to_number(:P5_LNG));',
'  l.put(''address'', :P5_ADDR); l.put(''landmark'', :P5_LANDMARK); l.put(''tax'', :P5_TAX); l.put(''cr'', :P5_CR); l.put(''limit'', to_number(:P5_LIMIT));',
'  :P5_ID := noona_dst_pkg.save_shop(l.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000115)
,p_process_success_message=>'تم حفظ المحل'
,p_internal_uid=>91820300000000117
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000118)
,p_branch_action=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:RP,2,5:P2_SHOP:&P5_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
