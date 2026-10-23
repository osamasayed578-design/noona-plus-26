prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
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
 p_id=>11
,p_name=>'Property Wizard'
,p_alias=>'PROPERTY-WIZARD'
,p_step_title=>'إضافة عقار'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000042)
,p_plug_name=>'1. بيانات العقار'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000043)
,p_name=>'P11_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'اسم العقار'
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
 p_id=>wwv_flow_imp.id(91820273000000044)
,p_name=>'P11_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:فندق;HOTEL,شقق فندقية;SERVICED_APARTMENTS,عمارة سكنية;BUILDING,برج;TOWER,مجمع سكني;COMPOUND,مجمع فلل;VILLA_COMPOUND,مركز تجاري;MALL,مجمع مكاتب;OFFICE_PARK,مستودعات;WAREHOUSE_PARK,مخطط أراض;LAND_SUBDIVISION'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000045)
,p_name=>'P11_CITY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'المدينة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from ref_city where is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820273000000046)
,p_name=>'P11_ADDRESS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'العنوان (الحي، الشارع)'
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
 p_id=>wwv_flow_imp.id(91820273000000047)
,p_name=>'P11_BRANCH'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'الفرع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = noona_re_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820273000000048)
,p_name=>'P11_MGMT'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'الملكية والإدارة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مملوك للمنشأة;OWNED,مدار لصالح مالك;MANAGED_FOR_OWNER,ملكية مشتركة;JOINT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000049)
,p_name=>'P11_OWNER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'المالك (لأملاك الغير)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select display_name_ar d, id r from pty_party p where status_code = ''ACTIVE'' and (party_type = ''ORGANIZATION'' or exists (select 1 from pty_party_role x where x.party_id = p.id and x.role_code in (''OWNER'', ''LANDLORD'', ''PARTNER''))) order by 1'
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
 p_id=>wwv_flow_imp.id(91820273000000050)
,p_name=>'P11_PHONE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'هاتف الاستقبال / الإدارة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820273000000051)
,p_name=>'P11_STARS'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'التصنيف (نجوم الفندق)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000052)
,p_name=>'P11_LICENSE'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'ترخيص السياحة / البلدية'
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
 p_id=>wwv_flow_imp.id(91820273000000053)
,p_name=>'P11_DESC'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820273000000042)
,p_prompt=>'الوصف والمرافق (مسبح، مواقف، نادٍ...)'
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
 p_id=>wwv_flow_imp.id(91820273000000054)
,p_plug_name=>'2. المباني والطوابق'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">حتى ثلاثة مبانٍ؛ لكل مبنى عدد الطوابق والدور الأرضي اختيارياً. يمكن إضافة مبانٍ أخرى لاحقاً من بطاقة العقار.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000055)
,p_name=>'P11_B1_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 1: الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
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
 p_id=>wwv_flow_imp.id(91820273000000056)
,p_name=>'P11_B1_FLOORS'
,p_item_sequence=>11
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 1: عدد الطوابق'
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
 p_id=>wwv_flow_imp.id(91820273000000057)
,p_name=>'P11_B1_GROUND'
,p_item_sequence=>12
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 1: يوجد دور أرضي بوحدات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000058)
,p_name=>'P11_B2_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 2: الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
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
 p_id=>wwv_flow_imp.id(91820273000000059)
,p_name=>'P11_B2_FLOORS'
,p_item_sequence=>21
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 2: عدد الطوابق'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000060)
,p_name=>'P11_B2_GROUND'
,p_item_sequence=>22
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 2: يوجد دور أرضي بوحدات'
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
 p_id=>wwv_flow_imp.id(91820273000000061)
,p_name=>'P11_B3_NAME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 3: الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
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
 p_id=>wwv_flow_imp.id(91820273000000062)
,p_name=>'P11_B3_FLOORS'
,p_item_sequence=>31
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 3: عدد الطوابق'
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
 p_id=>wwv_flow_imp.id(91820273000000063)
,p_name=>'P11_B3_GROUND'
,p_item_sequence=>32
,p_item_plug_id=>wwv_flow_imp.id(91820273000000054)
,p_prompt=>'المبنى 3: يوجد دور أرضي بوحدات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000064)
,p_plug_name=>'3. توليد الوحدات (لكل طابق)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">ترقم الوحدات آلياً: رقم الطابق ثم تسلسل الوحدة (101، 102 ... 201). تعدّل تفاصيل أي وحدة لاحقاً من مخطط الوحدات.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000065)
,p_name=>'P11_PER_FLOOR'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000064)
,p_prompt=>'عدد الوحدات في كل طابق'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000066)
,p_name=>'P11_UTYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000064)
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
 p_id=>wwv_flow_imp.id(91820273000000067)
,p_name=>'P11_USAGE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000064)
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
 p_id=>wwv_flow_imp.id(91820273000000068)
,p_name=>'P11_BEDS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000064)
,p_prompt=>'غرف النوم'
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
 p_id=>wwv_flow_imp.id(91820273000000069)
,p_name=>'P11_BATHS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000064)
,p_prompt=>'دورات المياه'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000070)
,p_name=>'P11_AREA'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000064)
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
 p_id=>wwv_flow_imp.id(91820273000000071)
,p_name=>'P11_FURN'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000064)
,p_prompt=>'التأثيث'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مفروشة;FURNISHED,شبه مفروشة;SEMI_FURNISHED,غير مفروشة;UNFURNISHED'
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
 p_id=>wwv_flow_imp.id(91820273000000072)
,p_name=>'P11_PRICE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000064)
,p_prompt=>'السعر / الإيجار السنوي (اختياري)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000073)
,p_plug_name=>'4. الضيافة (فندق أو شقق فندقية)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">عند التفعيل تصبح كل وحدة غرفة أو شقة فندقية جاهزة في لوحة الاستقبال، بنوع غرفة وسعر أساسي لليلة.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000074)
,p_name=>'P11_HSP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000073)
,p_prompt=>'تشغيل الوحدات فندقياً'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000075)
,p_name=>'P11_RT_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000073)
,p_prompt=>'اسم نوع الغرفة / الشقة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
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
 p_id=>wwv_flow_imp.id(91820273000000076)
,p_name=>'P11_RT_RATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000073)
,p_prompt=>'سعر الليلة الأساسي'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000077)
,p_name=>'P11_RT_ADULTS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000073)
,p_prompt=>'أقصى عدد بالغين'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000078)
,p_plug_name=>'حفظ'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000079)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000078)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء العقار ووحداته'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000080)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P11_TYPE := nvl(:P11_TYPE, ''BUILDING''); :P11_MGMT := nvl(:P11_MGMT, ''OWNED'');',
'    :P11_B1_NAME := nvl(:P11_B1_NAME, ''المبنى الرئيسي''); :P11_UTYPE := nvl(:P11_UTYPE, ''APARTMENT'');',
'    :P11_USAGE := nvl(:P11_USAGE, ''LEASE''); :P11_HSP := nvl(:P11_HSP, ''N''); :P11_RT_ADULTS := nvl(:P11_RT_ADULTS, 2);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000080
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000081)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_o  json_object_t := json_object_t();',
'    l_bs json_array_t := json_array_t();',
'    l_b  json_object_t;',
'    l_u  json_object_t := json_object_t();',
'    l_h  json_object_t := json_object_t();',
'    procedure bld(p_name varchar2, p_floors varchar2, p_ground varchar2, p_code varchar2) is',
'    begin',
'        if p_floors is not null then',
'            l_b := json_object_t(); l_b.put(''code'', p_code); l_b.put(''name'', nvl(p_name, ''مبنى '' || p_code));',
'            l_b.put(''floors'', to_number(p_floors)); l_b.put(''ground'', nvl(p_ground, ''N'')); l_bs.append(l_b);',
'        end if;',
'    end;',
'begin',
'    l_o.put(''name_ar'', :P11_NAME); l_o.put(''type'', :P11_TYPE); l_o.put(''city'', :P11_CITY); l_o.put(''address'', :P11_ADDRESS);',
'    l_o.put(''branch'', :P11_BRANCH); l_o.put(''management_mode'', :P11_MGMT); l_o.put(''owner_party'', :P11_OWNER);',
'    l_o.put(''phone'', :P11_PHONE); l_o.put(''star_rating'', :P11_STARS); l_o.put(''license'', :P11_LICENSE); l_o.put(''description'', :P11_DESC);',
'    bld(:P11_B1_NAME, :P11_B1_FLOORS, :P11_B1_GROUND, ''A''); bld(:P11_B2_NAME, :P11_B2_FLOORS, :P11_B2_GROUND, ''B'');',
'    bld(:P11_B3_NAME, :P11_B3_FLOORS, :P11_B3_GROUND, ''C'');',
'    l_o.put(''buildings'', l_bs);',
'    if :P11_PER_FLOOR is not null then',
'        l_u.put(''per_floor'', :P11_PER_FLOOR); l_u.put(''unit_type'', :P11_UTYPE);',
'        l_u.put(''usage_type'', case when :P11_HSP = ''Y'' then ''HOSPITALITY'' else :P11_USAGE end);',
'        l_u.put(''bedrooms'', :P11_BEDS); l_u.put(''bathrooms'', :P11_BATHS); l_u.put(''area'', :P11_AREA); l_u.put(''furnishing'', :P11_FURN);',
'        l_u.put(''price'', :P11_PRICE); l_o.put(''units'', l_u);',
'    end if;',
'    if :P11_HSP = ''Y'' then',
'        l_h.put(''room_type_name'', :P11_RT_NAME); l_h.put(''base_rate'', :P11_RT_RATE); l_h.put(''max_adults'', :P11_RT_ADULTS);',
'        l_o.put(''hospitality'', l_h);',
'    end if;',
'    :P11_ID := noona_re_pkg.setup_wizard(l_o.to_clob);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000079)
,p_process_success_message=>'تم إنشاء العقار ومبانيه ووحداته'
,p_internal_uid=>91820273000000081
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000082)
,p_name=>'P11_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000078)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000083)
,p_branch_action=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.:RP,12:P12_ID:&P11_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
