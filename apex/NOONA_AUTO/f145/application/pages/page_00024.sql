prompt --application/pages/page_00024
begin
--   Manifest
--     PAGE: 00024
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
 p_id=>24
,p_name=>'Bundles'
,p_alias=>'BUNDLES'
,p_step_title=>'الباقات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000506)
,p_plug_name=>'الباقات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select b.id, b.code, b.name_ar, noona_prc_pkg.bundle_text(b.id) as rule_text,',
'       (select count(*) from sal_bundle_line l where l.bundle_id = b.id) as lines_count, noona_prc_pkg.bundle_price(b.id) as price,',
'       b.channels, b.effective_from, b.effective_to, noona_ui_pkg.status_badge(b.status_code) as status_html',
'  from sal_bundle b where b.company_id = noona_prc_pkg.company order by b.status_code, b.name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الباقات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820280000000507)
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
,p_internal_uid=>91820280000000507
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000509)
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
 p_id=>wwv_flow_imp.id(91820280000000510)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000511)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الباقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000512)
,p_db_column_name=>'RULE_TEXT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'التسعير'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000513)
,p_db_column_name=>'LINES_COUNT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المكونات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000514)
,p_db_column_name=>'PRICE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'سعر الباقة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000515)
,p_db_column_name=>'CHANNELS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'القنوات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000516)
,p_db_column_name=>'EFFECTIVE_FROM'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'من'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000517)
,p_db_column_name=>'EFFECTIVE_TO'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'إلى'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000518)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820280000000508)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'508'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:RULE_TEXT:LINES_COUNT:PRICE:CHANNELS:EFFECTIVE_FROM:EFFECTIVE_TO:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000519)
,p_plug_name=>'باقة جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الباقة مكونان على الأقل؛ ويضاف غيرهما بعد الحفظ من «إدارة باقة».</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000520)
,p_name=>'P24_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
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
 p_id=>wwv_flow_imp.id(91820280000000521)
,p_name=>'P24_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'اسم الباقة'
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
 p_id=>wwv_flow_imp.id(91820280000000522)
,p_name=>'P24_DESC'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'الوصف'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000523)
,p_name=>'P24_METHOD'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'طريقة السعر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سعر ثابت للباقة;FIXED_PRICE,خصم نسبة من مجموع المكونات;PCT_OFF,خصم مبلغ من مجموع المكونات;AMOUNT_OFF'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000524)
,p_name=>'P24_VALUE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'السعر / النسبة / المبلغ'
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
 p_id=>wwv_flow_imp.id(91820280000000525)
,p_name=>'P24_C1'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'المكون 1'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'with z (d, r, o) as (select ''صنف: '' || i.item_no || '' - '' || i.name_ar || '' ('' || to_char(nvl(c.sale_price, 0), ''FM999,990.00'') || '')'', ''ITEM-'' || i.id, 3 from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = noona_prc_pkg.company and i.status_code = ''ACTIVE'' union all select ''خدمة سيارات: '' || code || '' - '' || name_ar || '' ('' || to_char(price, ''FM999,990.00'') || '')'', ''AUT_SERVICE-'' || id, 9 from aut_service where company_id = noona_prc_pkg.company and is_active = ''Y'') select d, r from z order by o, d'
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
 p_id=>wwv_flow_imp.id(91820280000000526)
,p_name=>'P24_Q1'
,p_item_sequence=>65
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'كمية المكون 1'
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
 p_id=>wwv_flow_imp.id(91820280000000527)
,p_name=>'P24_C2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'المكون 2'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'with z (d, r, o) as (select ''صنف: '' || i.item_no || '' - '' || i.name_ar || '' ('' || to_char(nvl(c.sale_price, 0), ''FM999,990.00'') || '')'', ''ITEM-'' || i.id, 3 from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = noona_prc_pkg.company and i.status_code = ''ACTIVE'' union all select ''خدمة سيارات: '' || code || '' - '' || name_ar || '' ('' || to_char(price, ''FM999,990.00'') || '')'', ''AUT_SERVICE-'' || id, 9 from aut_service where company_id = noona_prc_pkg.company and is_active = ''Y'') select d, r from z order by o, d'
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
 p_id=>wwv_flow_imp.id(91820280000000528)
,p_name=>'P24_Q2'
,p_item_sequence=>75
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'كمية المكون 2'
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
 p_id=>wwv_flow_imp.id(91820280000000529)
,p_name=>'P24_CH'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'القنوات (بلا اختيار = الكل)'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'STATIC2:نقاط البيع;POS,فواتير المبيعات;SALES,المستشفيات;HIS,خدمة السيارات;AUT,المطاعم;RST'
,p_lov_columns=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000530)
,p_name=>'P24_INCL'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_prompt=>'السعر شامل الضريبة'
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
 p_id=>wwv_flow_imp.id(91820280000000531)
,p_name=>'P24_FROM'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
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
 p_id=>wwv_flow_imp.id(91820280000000532)
,p_name=>'P24_TO'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820280000000519)
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
 p_id=>wwv_flow_imp.id(91820280000000534)
,p_validation_name=>'P24_CODE required (SAVE_BUNDLE)'
,p_validation_sequence=>26
,p_validation=>'P24_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000533)
,p_associated_item=>wwv_flow_imp.id(91820280000000520)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000535)
,p_validation_name=>'P24_NAME required (SAVE_BUNDLE)'
,p_validation_sequence=>27
,p_validation=>'P24_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000533)
,p_associated_item=>wwv_flow_imp.id(91820280000000521)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000536)
,p_validation_name=>'P24_VALUE required (SAVE_BUNDLE)'
,p_validation_sequence=>28
,p_validation=>'P24_VALUE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000533)
,p_associated_item=>wwv_flow_imp.id(91820280000000524)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000537)
,p_validation_name=>'P24_C1 required (SAVE_BUNDLE)'
,p_validation_sequence=>29
,p_validation=>'P24_C1'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000533)
,p_associated_item=>wwv_flow_imp.id(91820280000000525)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000538)
,p_validation_name=>'P24_C2 required (SAVE_BUNDLE)'
,p_validation_sequence=>30
,p_validation=>'P24_C2'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000533)
,p_associated_item=>wwv_flow_imp.id(91820280000000527)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000533)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000519)
,p_button_name=>'SAVE_BUNDLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الباقة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000539)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Bundle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l number;',
'    l_j clob;',
'begin',
'    select json_object(''code'' value :P24_CODE, ''name'' value :P24_NAME, ''desc'' value :P24_DESC,',
'           ''method'' value :P24_METHOD, ''value'' value to_number(:P24_VALUE), ''incl'' value :P24_INCL,',
'           ''channels'' value replace(:P24_CH, '':'', '',''), ''from'' value :P24_FROM, ''to'' value :P24_TO,',
'           ''lines'' value json_array(json_object(''type'' value regexp_substr(:P24_C1, ''^[A-Z_]+''), ''id'' value case when instr(:P24_C1, ''-'') > 0 and :P24_C1 not like ''HIS_SERVICE_TYPE-%'' then to_number(substr(:P24_C1, instr(:P24_C1, ''-'') + 1)) end,',
'                                   ''qty'' value nvl(to_number(:P24_Q1), 1)),',
'                       json_object(''type'' value regexp_substr(:P24_C2, ''^[A-Z_]+''), ''id'' value case when instr(:P24_C2, ''-'') > 0 and :P24_C2 not like ''HIS_SERVICE_TYPE-%'' then to_number(substr(:P24_C2, instr(:P24_C2, ''-'') + 1)) end,',
'                                   ''qty'' value nvl(to_number(:P24_Q2), 1))) absent on null) into l_j from dual;',
'    l := noona_prc_pkg.save_bundle(l_j);',
'    :P24_BUNDLE := l;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000533)
,p_process_success_message=>'تم حفظ الباقة'
,p_internal_uid=>91820280000000539
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000540)
,p_plug_name=>'إدارة باقة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000541)
,p_name=>'P24_BUNDLE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000540)
,p_prompt=>'الباقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from sal_bundle where company_id = noona_prc_pkg.company order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000542)
,p_name=>'P24_ADD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000540)
,p_prompt=>'إضافة مكون'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'with z (d, r, o) as (select ''صنف: '' || i.item_no || '' - '' || i.name_ar || '' ('' || to_char(nvl(c.sale_price, 0), ''FM999,990.00'') || '')'', ''ITEM-'' || i.id, 3 from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = noona_prc_pkg.company and i.status_code = ''ACTIVE'' union all select ''خدمة سيارات: '' || code || '' - '' || name_ar || '' ('' || to_char(price, ''FM999,990.00'') || '')'', ''AUT_SERVICE-'' || id, 9 from aut_service where company_id = noona_prc_pkg.company and is_active = ''Y'') select d, r from z order by o, d'
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
 p_id=>wwv_flow_imp.id(91820280000000543)
,p_name=>'P24_ADDQ'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000540)
,p_prompt=>'الكمية'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000544)
,p_name=>'P24_DEL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000540)
,p_prompt=>'حذف مكون'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_prc_pkg.target_name(target_type, target_id) || '' × '' || quantity d, id r from sal_bundle_line where bundle_id = :P24_BUNDLE order by sort_order'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P24_BUNDLE'
,p_ajax_items_to_submit=>'P24_BUNDLE'
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
 p_id=>wwv_flow_imp.id(91820280000000545)
,p_name=>'P24_BST'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000540)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشطة;ACTIVE,موقوفة;INACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000546)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000540)
,p_button_name=>'ADD_LINE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة المكون'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000547)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820280000000540)
,p_button_name=>'DEL_LINE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف المكون'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000548)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820280000000540)
,p_button_name=>'SET_BUNDLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير الحالة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000549)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Line'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.add_bundle_line(:P24_BUNDLE, :P24_ADD, nvl(to_number(:P24_ADDQ), 1));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000546)
,p_process_success_message=>'تمت إضافة المكون'
,p_internal_uid=>91820280000000549
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000550)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delete Line'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.remove_bundle_line(:P24_DEL);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000547)
,p_process_success_message=>'تم حذف المكون'
,p_internal_uid=>91820280000000550
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000551)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Bundle Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.set_bundle_status(:P24_BUNDLE, :P24_BST);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000548)
,p_process_success_message=>'تم تغيير حالة الباقة'
,p_internal_uid=>91820280000000551
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000552)
,p_plug_name=>'مكونات الباقة وتوزيع سعرها'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P24_BUNDLE is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prc_pkg.bundle_html(:P24_BUNDLE);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000553)
,p_branch_action=>'f?p=&APP_ID.:24:&SESSION.::&DEBUG.::P24_BUNDLE:&P24_BUNDLE.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
