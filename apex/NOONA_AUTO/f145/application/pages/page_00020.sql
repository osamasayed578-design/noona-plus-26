prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>145
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>'Pricing Policies'
,p_alias=>'PRICING'
,p_step_title=>'سياسات التسعير'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000331)
,p_plug_name=>'كيف يحسب سعر البيع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">التكلفة: الصنف بمتوسط تكلفته المرجح (أو آخر سعر شراء أو التكلفة المعيارية)، والخدمة ببطاقة تكلفتها (موادها + العمالة بالدقائق × تكلفة الساعة + الأعباء). ثم سعر البيع حسب السياسة: <b>نسبة فوق التكلفة</b> (100 + 25% = 125)، <b>هامش من سعر البيع</b> (100 ÷ (1 - 20%) = 125)، <b>مبلغ ثابت</b> فوق التكلفة، أو <b>معامل</b> (التكلفة × 1.5)؛ مع أدنى هامش يحدد أدنى سعر بيع دون موافقة، وتقريب لأعلى. تطبق السياسة الأخص: الصنف أو الخدمة، ثم الفئة أو النوع، ثم الكل.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000332)
,p_plug_name=>'سياسات التسعير'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select p.id, p.code, p.name_ar, noona_prc_pkg.target_label(p.target_type, p.target_id, p.target_code) as target,',
'       noona_prc_pkg.policy_text(p.id) as rule_text, p.priority_no, p.effective_from, p.effective_to,',
'       noona_ui_pkg.status_badge(p.status_code) as status_html',
'  from sal_pricing_policy p where p.company_id = noona_prc_pkg.company and p.target_type in (''ITEM'', ''ITEM_CATEGORY'', ''ALL_ITEMS'', ''AUT_SERVICE'', ''AUT_CATEGORY'', ''ALL_AUT'') order by p.status_code, p.priority_no, p.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'سياسات التسعير'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820280000000333)
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
,p_internal_uid=>91820280000000333
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000335)
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
 p_id=>wwv_flow_imp.id(91820280000000336)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000337)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'السياسة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000338)
,p_db_column_name=>'TARGET'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'تنطبق على'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000339)
,p_db_column_name=>'RULE_TEXT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'القاعدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000340)
,p_db_column_name=>'PRIORITY_NO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الأولوية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000341)
,p_db_column_name=>'EFFECTIVE_FROM'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'من'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000342)
,p_db_column_name=>'EFFECTIVE_TO'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'إلى'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000343)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820280000000334)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'334'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:TARGET:RULE_TEXT:PRIORITY_NO:EFFECTIVE_FROM:EFFECTIVE_TO:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000344)
,p_plug_name=>'سياسة جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000345)
,p_name=>'P20_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
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
 p_id=>wwv_flow_imp.id(91820280000000346)
,p_name=>'P20_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
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
 p_id=>wwv_flow_imp.id(91820280000000347)
,p_name=>'P20_TARGET'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'تنطبق على'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'with z (d, r, o) as (select ''★ كل الأصناف'' d, ''ALL_ITEMS'' r, 1 o from dual union all select ''فئة أصناف: '' || name_ar, ''ITEM_CATEGORY-'' || id, 2 from inv_item_category where is_active = ''Y'' union all select ''صنف: '' || i.item_no || '' - '' || i.name_ar || '' ('' || to_char(nvl(c.sale_price, 0), ''FM999,990.00'') || '')'', ''ITEM-'' || i.id, 3 from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = noona_prc_pkg.company and i.status_code = ''ACTIVE'' union all select ''★ كل خدمات السيارات'', ''ALL_AUT'', 7 from dual union all select ''فئة خدمات سيارات: '' || name_ar, ''AUT_CATEGORY-'' || id, 8 from aut_service_category where company_id = noona_prc_pkg.company union all select ''خدمة سيارات: '' || code || '' - '' || name_ar || '' ('' || to_char(price, ''FM999,990.00'') || '')'', ''AUT_SERVICE-'' || id, 9 from aut_service where company_id = noona_prc_pkg.company and is_active = ''Y'') select d, r from z order by o, d'
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
 p_id=>wwv_flow_imp.id(91820280000000348)
,p_name=>'P20_BASIS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'أساس التكلفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:متوسط التكلفة المرجح;AVERAGE,آخر سعر شراء;LAST_PURCHASE,التكلفة المعيارية;STANDARD,بطاقة التكلفة;COST_SHEET'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000349)
,p_name=>'P20_METHOD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'طريقة سعر البيع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نسبة فوق التكلفة (Markup);MARKUP_PCT,هامش من سعر البيع (Margin);MARGIN_PCT,مبلغ ثابت فوق التكلفة;FIXED_AMOUNT,معامل × التكلفة;MULTIPLIER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000350)
,p_name=>'P20_VALUE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'النسبة / المبلغ / المعامل'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000351)
,p_name=>'P20_MINM'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'أدنى هامش % (أدنى سعر بيع)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000352)
,p_name=>'P20_ROUND'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'التقريب لأعلى'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بدون;NONE,0.05;R005,0.25;R025,0.50;R050,1;R1,5;R5,10;R10,ينتهي بـ .99;END99'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000353)
,p_name=>'P20_PRIO'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'الأولوية (الأصغر أولاً)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000354)
,p_name=>'P20_FROM'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'سارية من'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
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
 p_id=>wwv_flow_imp.id(91820280000000355)
,p_name=>'P20_TO'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_prompt=>'إلى'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000357)
,p_validation_name=>'P20_CODE required (SAVE_POLICY)'
,p_validation_sequence=>24
,p_validation=>'P20_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000356)
,p_associated_item=>wwv_flow_imp.id(91820280000000345)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000358)
,p_validation_name=>'P20_NAME required (SAVE_POLICY)'
,p_validation_sequence=>25
,p_validation=>'P20_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000356)
,p_associated_item=>wwv_flow_imp.id(91820280000000346)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000359)
,p_validation_name=>'P20_TARGET required (SAVE_POLICY)'
,p_validation_sequence=>26
,p_validation=>'P20_TARGET'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000356)
,p_associated_item=>wwv_flow_imp.id(91820280000000347)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000360)
,p_validation_name=>'P20_VALUE required (SAVE_POLICY)'
,p_validation_sequence=>27
,p_validation=>'P20_VALUE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000356)
,p_associated_item=>wwv_flow_imp.id(91820280000000350)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000356)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000344)
,p_button_name=>'SAVE_POLICY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ السياسة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000361)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Policy'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l number;',
'    l_j clob;',
'begin',
'    select json_object(''code'' value :P20_CODE, ''name'' value :P20_NAME, ''targetType'' value regexp_substr(:P20_TARGET, ''^[A-Z_]+''),',
'           ''targetId'' value case when instr(:P20_TARGET, ''-'') > 0 and :P20_TARGET not like ''HIS_SERVICE_TYPE-%'' then to_number(substr(:P20_TARGET, instr(:P20_TARGET, ''-'') + 1)) end, ''targetCode'' value case when :P20_TARGET like ''HIS_SERVICE_TYPE-%'' then substr(:P20_TARGET, instr(:P20_TARGET, ''-'') + 1) end, ''basis'' value :P20_BASIS,',
'           ''method'' value :P20_METHOD, ''value'' value to_number(:P20_VALUE), ''minMargin'' value to_number(:P20_MINM),',
'           ''rounding'' value :P20_ROUND, ''priority'' value to_number(:P20_PRIO), ''from'' value :P20_FROM,',
'           ''to'' value :P20_TO absent on null) into l_j from dual;',
'    l := noona_prc_pkg.save_policy(l_j);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000356)
,p_process_success_message=>'تم حفظ السياسة'
,p_internal_uid=>91820280000000361
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000362)
,p_plug_name=>'إيقاف أو تفعيل سياسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000363)
,p_name=>'P20_POL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000362)
,p_prompt=>'السياسة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from sal_pricing_policy where company_id = noona_prc_pkg.company and target_type in (''ITEM'', ''ITEM_CATEGORY'', ''ALL_ITEMS'', ''AUT_SERVICE'', ''AUT_CATEGORY'', ''ALL_AUT'') order by code'
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
 p_id=>wwv_flow_imp.id(91820280000000364)
,p_name=>'P20_PST'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000362)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:موقوفة;INACTIVE,نشطة;ACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000365)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000362)
,p_button_name=>'SET_POLICY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تطبيق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000366)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Policy Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.set_policy_status(:P20_POL, :P20_PST);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000365)
,p_process_success_message=>'تم تغيير حالة السياسة'
,p_internal_uid=>91820280000000366
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000367)
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:20::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
