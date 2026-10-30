prompt --application/pages/page_00083
begin
--   Manifest
--     PAGE: 00083
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>83
,p_name=>'Promotions'
,p_alias=>'PROMOTIONS'
,p_step_title=>'العروض والتخفيضات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000505)
,p_plug_name=>'العروض والتخفيضات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select p.id, p.code, p.name_ar, noona_prc_pkg.promotion_text(p.id) as rule_text, p.channels,',
'       (select listagg(noona_prc_pkg.target_label(t.target_type, t.target_id, t.target_code), ''، '') within group (order by t.id)',
'          from sal_promotion_target t where t.promotion_id = p.id) as targets,',
'       p.priority_no, noona_ui_pkg.status_badge(p.status_code) as status_html',
'  from sal_promotion p where p.company_id = noona_prc_pkg.company order by decode(p.status_code, ''ACTIVE'', 0, 1), p.priority_no, p.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'العروض والتخفيضات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820269000000506)
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
,p_internal_uid=>91820269000000506
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000508)
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
 p_id=>wwv_flow_imp.id(91820269000000509)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000510)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'العرض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000511)
,p_db_column_name=>'RULE_TEXT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الشروط'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000512)
,p_db_column_name=>'CHANNELS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'القنوات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000513)
,p_db_column_name=>'TARGETS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'يشمل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000514)
,p_db_column_name=>'PRIORITY_NO'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الأولوية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000515)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820269000000507)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'507'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:RULE_TEXT:CHANNELS:TARGETS:PRIORITY_NO:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000516)
,p_plug_name=>'عرض جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000517)
,p_name=>'P83_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
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
 p_id=>wwv_flow_imp.id(91820269000000518)
,p_name=>'P83_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'اسم العرض'
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
 p_id=>wwv_flow_imp.id(91820269000000519)
,p_name=>'P83_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:خصم نسبة;PCT_OFF,خصم مبلغ للوحدة;AMOUNT_OFF,سعر خاص;FIXED_PRICE,اشتر X واحصل على Y مجاناً;BUY_X_GET_Y,خصم نسبة على قيمة الفاتورة;SPEND_PCT,خصم مبلغ على قيمة الفاتورة;SPEND_AMOUNT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000520)
,p_name=>'P83_VALUE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'النسبة / المبلغ / السعر الخاص'
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
 p_id=>wwv_flow_imp.id(91820269000000521)
,p_name=>'P83_BUY'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'اشتر (كمية)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000522)
,p_name=>'P83_GET'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'واحصل مجاناً على'
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
 p_id=>wwv_flow_imp.id(91820269000000523)
,p_name=>'P83_MINQ'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'أدنى كمية للسطر'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000524)
,p_name=>'P83_MINA'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'أدنى قيمة للفاتورة'
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
 p_id=>wwv_flow_imp.id(91820269000000525)
,p_name=>'P83_MAXD'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'أقصى خصم'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000526)
,p_name=>'P83_TARGET'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'يشمل (ويضاف غيره بعد الحفظ)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'with z (d, r, o) as (select ''★ كل الأصناف'' d, ''ALL_ITEMS'' r, 1 o from dual union all select ''فئة أصناف: '' || name_ar, ''ITEM_CATEGORY-'' || id, 2 from inv_item_category where is_active = ''Y'' union all select ''صنف: '' || i.item_no || '' - '' || i.name_ar || '' ('' || to_char(nvl(c.sale_price, 0), ''FM999,990.00'') || '')'', ''ITEM-'' || i.id, 3 from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = noona_prc_pkg.company and i.status_code = ''ACTIVE'') select d, r from z order by o, d'
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
 p_id=>wwv_flow_imp.id(91820269000000527)
,p_name=>'P83_CH'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'القنوات (بلا اختيار = الكل)'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'STATIC2:نقاط البيع;POS,فواتير المبيعات;SALES,المستشفيات;HIS,خدمة السيارات;AUT,المطاعم;RST'
,p_lov_columns=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000528)
,p_name=>'P83_DAYS'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'الأيام (بلا اختيار = كل الأيام)'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'STATIC2:الأحد;1,الاثنين;2,الثلاثاء;3,الأربعاء;4,الخميس;5,الجمعة;6,السبت;7'
,p_lov_columns=>7
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000529)
,p_name=>'P83_HF'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'من الساعة (0-23)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000530)
,p_name=>'P83_HT'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'إلى الساعة (1-24)'
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
 p_id=>wwv_flow_imp.id(91820269000000531)
,p_name=>'P83_COUPON'
,p_item_sequence=>150
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'كود الكوبون (اختياري)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>50
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000532)
,p_name=>'P83_PRIO'
,p_item_sequence=>160
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'الأولوية'
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
 p_id=>wwv_flow_imp.id(91820269000000533)
,p_name=>'P83_STACK'
,p_item_sequence=>170
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'يجمع مع عروض أخرى'
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
 p_id=>wwv_flow_imp.id(91820269000000534)
,p_name=>'P83_FROM'
,p_item_sequence=>180
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'من تاريخ'
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
 p_id=>wwv_flow_imp.id(91820269000000535)
,p_name=>'P83_TO'
,p_item_sequence=>190
,p_item_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_prompt=>'إلى تاريخ'
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
 p_id=>wwv_flow_imp.id(91820269000000537)
,p_validation_name=>'P83_CODE required (SAVE_PROMO)'
,p_validation_sequence=>30
,p_validation=>'P83_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820269000000536)
,p_associated_item=>wwv_flow_imp.id(91820269000000517)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820269000000538)
,p_validation_name=>'P83_NAME required (SAVE_PROMO)'
,p_validation_sequence=>31
,p_validation=>'P83_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820269000000536)
,p_associated_item=>wwv_flow_imp.id(91820269000000518)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000536)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000516)
,p_button_name=>'SAVE_PROMO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ العرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000539)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Promotion'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l number;',
'    l_j clob;',
'    l_t clob;',
'begin',
'    if :P83_TARGET is not null then',
'        select json_array(json_object(''type'' value regexp_substr(:P83_TARGET, ''^[A-Z_]+''), ''id'' value case when instr(:P83_TARGET, ''-'') > 0 and :P83_TARGET not like ''HIS_SERVICE_TYPE-%'' then to_number(substr(:P83_TARGET, instr(:P83_TARGET, ''-'') + 1)) end,',
'               ''code'' value case when :P83_TARGET like ''HIS_SERVICE_TYPE-%'' then substr(:P83_TARGET, instr(:P83_TARGET, ''-'') + 1) end absent on null)) into l_t from dual;',
'    end if;',
'    select json_object(''code'' value :P83_CODE, ''name'' value :P83_NAME, ''type'' value :P83_TYPE,',
'           ''value'' value to_number(:P83_VALUE), ''buyQty'' value to_number(:P83_BUY), ''getQty'' value to_number(:P83_GET),',
'           ''minQty'' value to_number(:P83_MINQ), ''minAmount'' value to_number(:P83_MINA), ''maxDiscount'' value to_number(:P83_MAXD),',
'           ''channels'' value replace(:P83_CH, '':'', '',''), ''days'' value replace(:P83_DAYS, '':'', '',''),',
'           ''hourFrom'' value to_number(:P83_HF), ''hourTo'' value to_number(:P83_HT), ''coupon'' value :P83_COUPON,',
'           ''priority'' value to_number(:P83_PRIO), ''stackable'' value :P83_STACK, ''from'' value :P83_FROM,',
'           ''to'' value :P83_TO, ''targets'' value l_t format json absent on null) into l_j from dual;',
'    l := noona_prc_pkg.save_promotion(l_j);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820269000000536)
,p_process_success_message=>'تم حفظ العرض وتفعيله'
,p_internal_uid=>91820269000000539
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000540)
,p_plug_name=>'إدارة عرض'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000541)
,p_name=>'P83_PROMO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820269000000540)
,p_prompt=>'العرض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from sal_promotion where company_id = noona_prc_pkg.company order by id desc'
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
 p_id=>wwv_flow_imp.id(91820269000000542)
,p_name=>'P83_ADD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820269000000540)
,p_prompt=>'إضافة صنف أو خدمة أو فئة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'with z (d, r, o) as (select ''★ كل الأصناف'' d, ''ALL_ITEMS'' r, 1 o from dual union all select ''فئة أصناف: '' || name_ar, ''ITEM_CATEGORY-'' || id, 2 from inv_item_category where is_active = ''Y'' union all select ''صنف: '' || i.item_no || '' - '' || i.name_ar || '' ('' || to_char(nvl(c.sale_price, 0), ''FM999,990.00'') || '')'', ''ITEM-'' || i.id, 3 from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = noona_prc_pkg.company and i.status_code = ''ACTIVE'') select d, r from z order by o, d'
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
 p_id=>wwv_flow_imp.id(91820269000000543)
,p_name=>'P83_PST'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820269000000540)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,موقوف مؤقتاً;PAUSED,ملغى;CANCELLED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000544)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000540)
,p_button_name=>'ADD_TARGET'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة للعرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000545)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820269000000540)
,p_button_name=>'SET_PROMO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير الحالة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000546)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Target'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.add_promotion_target(:P83_PROMO, :P83_ADD);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820269000000544)
,p_process_success_message=>'تمت الإضافة للعرض'
,p_internal_uid=>91820269000000546
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000547)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Promotion Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.set_promotion_status(:P83_PROMO, :P83_PST);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820269000000545)
,p_process_success_message=>'تم تغيير حالة العرض'
,p_internal_uid=>91820269000000547
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820269000000548)
,p_branch_action=>'f?p=&APP_ID.:83:&SESSION.::&DEBUG.:83::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
