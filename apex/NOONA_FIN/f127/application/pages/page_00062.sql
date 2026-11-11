prompt --application/pages/page_00062
begin
--   Manifest
--     PAGE: 00062
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>62
,p_name=>'Asset Maintenance'
,p_alias=>'ASSET-MAINTENANCE'
,p_step_title=>'صيانة الأصول'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000530)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000629)
,p_plug_name=>'الصيانات الدورية المستحقة خلال 30 يوماً'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_fa_pkg.due_maintenance_html(30);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000630)
,p_plug_name=>'خطة صيانة دورية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">لكل أصل خطط صيانة دورية بالأشهر (فحص، معايرة، تغيير زيت مولد...). تسجيل الصيانة من بطاقة الأصل مع اختيار الخطة يحدّث موعدها التالي تلقائياً. صيانة عربات النقل تدار من «صيانة الأسطول» في نظام النقل وترحل هنا.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000631)
,p_name=>'P62_ASSET'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'الأصل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select asset_no || '' - '' || name_ar d, id r from fa_asset where company_id = noona_fa_pkg.company and status_code in (''IN_SERVICE'', ''CAPITALIZED'', ''FULLY_DEPRECIATED'') order by asset_no'
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
 p_id=>wwv_flow_imp.id(91820266000000632)
,p_name=>'P62_SVC'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'الصيانة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820266000000633)
,p_name=>'P62_EVERY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'كل (شهر)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000634)
,p_name=>'P62_NEXT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'الموعد التالي'
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
 p_id=>wwv_flow_imp.id(91820266000000635)
,p_name=>'P62_COST'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'التكلفة التقديرية'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000637)
,p_validation_name=>'P62_ASSET required (SAVE_PLAN)'
,p_validation_sequence=>7
,p_validation=>'P62_ASSET'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000636)
,p_associated_item=>wwv_flow_imp.id(91820266000000631)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000636)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_button_name=>'SAVE_PLAN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الخطة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000638)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Plan'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare x number; begin',
'  x := noona_fa_pkg.save_maint_plan(null, to_number(:P62_ASSET), :P62_SVC, to_number(:P62_EVERY), to_date(:P62_NEXT, ''YYYY-MM-DD''), to_number(:P62_COST));',
'  :P62_SVC := null; :P62_EVERY := null; :P62_NEXT := null; :P62_COST := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000636)
,p_process_success_message=>'حفظت الخطة'
,p_internal_uid=>91820266000000638
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000639)
,p_plug_name=>'خطط الصيانة الدورية'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select p.id, a.asset_no, a.name_ar, p.service_name, p.every_months, p.last_done_date, p.next_due_date, p.estimated_cost, p.status_code',
'  from fa_maint_plan p join fa_asset a on a.id = p.asset_id where p.company_id = noona_fa_pkg.company order by p.next_due_date'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'خطط الصيانة الدورية'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000640)
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
,p_internal_uid=>91820266000000640
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000642)
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
 p_id=>wwv_flow_imp.id(91820266000000643)
,p_db_column_name=>'ASSET_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'رقم الأصل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000644)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الأصل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000645)
,p_db_column_name=>'SERVICE_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الصيانة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000646)
,p_db_column_name=>'EVERY_MONTHS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'كل (شهر)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000647)
,p_db_column_name=>'LAST_DONE_DATE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'آخر تنفيذ'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000648)
,p_db_column_name=>'NEXT_DUE_DATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الموعد التالي'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000649)
,p_db_column_name=>'ESTIMATED_COST'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'التكلفة التقديرية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000650)
,p_db_column_name=>'STATUS_CODE'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000641)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'641'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ASSET_NO:NAME_AR:SERVICE_NAME:EVERY_MONTHS:LAST_DONE_DATE:NEXT_DUE_DATE:ESTIMATED_COST:STATUS_CODE'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000651)
,p_plug_name=>'سجل صيانة الأصول'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select m.id, m.doc_no, m.doc_date, a.asset_no, nvl(a.name_ar, ''بدون أصل (عربة مستأجرة)'') asset_name,',
'       noona_fa_pkg.maint_type_label(m.maint_type) maint_type, decode(m.treatment, ''CAPITALIZE'', ''رأسمالية'', ''مصروف'') treatment,',
'       m.description, pt.display_name_ar vendor, m.amount, m.vat_amount, m.life_extension_months,',
'       decode(m.source_module, ''TRN'', ''صيانة الأسطول'', ''الأصول'') source_name, decode(m.status_code, ''REVERSED'', ''معكوسة'', ''مرحلة'') status_name',
'  from fa_maintenance m left join fa_asset a on a.id = m.asset_id left join pty_party pt on pt.id = m.vendor_party_id',
' where m.company_id = noona_fa_pkg.company order by m.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'سجل صيانة الأصول'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000652)
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
,p_internal_uid=>91820266000000652
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000654)
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
 p_id=>wwv_flow_imp.id(91820266000000655)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000656)
,p_db_column_name=>'DOC_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000657)
,p_db_column_name=>'ASSET_NO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'رقم الأصل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000658)
,p_db_column_name=>'ASSET_NAME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الأصل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000659)
,p_db_column_name=>'MAINT_TYPE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000660)
,p_db_column_name=>'TREATMENT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المعالجة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000661)
,p_db_column_name=>'DESCRIPTION'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الوصف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000662)
,p_db_column_name=>'VENDOR'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الورشة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000663)
,p_db_column_name=>'AMOUNT'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000664)
,p_db_column_name=>'VAT_AMOUNT'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الضريبة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000665)
,p_db_column_name=>'LIFE_EXTENSION_MONTHS'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'تمديد العمر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000666)
,p_db_column_name=>'SOURCE_NAME'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000667)
,p_db_column_name=>'STATUS_NAME'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000653)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'653'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DOC_DATE:ASSET_NO:ASSET_NAME:MAINT_TYPE:TREATMENT:DESCRIPTION:VENDOR:AMOUNT:VAT_AMOUNT:LIFE_EXTENSION_MONTHS:SOURCE_NAME:STATUS_NAME'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000668)
,p_plug_name=>'عكس صيانة مصروف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000669)
,p_name=>'P62_MAINT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000668)
,p_prompt=>'الصيانة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select doc_no || '' · '' || substr(description, 1, 60) || '' · '' || amount d, id r from fa_maintenance where company_id = noona_fa_pkg.company and status_code = ''POSTED'' and treatment = ''EXPENSE'' order by id desc'
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
 p_id=>wwv_flow_imp.id(91820266000000670)
,p_name=>'P62_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000668)
,p_prompt=>'سبب العكس'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>400
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000671)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000668)
,p_button_name=>'REVERSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عكس القيد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000672)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reverse'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare x number; begin x := noona_fa_pkg.reverse_maintenance(to_number(:P62_MAINT), :P62_REASON); :P62_MAINT := null; :P62_REASON := null; end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000671)
,p_process_success_message=>'عكس قيد الصيانة'
,p_internal_uid=>91820266000000672
);

wwv_flow_imp.component_end;
end;
/
