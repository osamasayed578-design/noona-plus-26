prompt --application/pages/page_00070
begin
--   Manifest
--     PAGE: 00070
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>137
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>70
,p_name=>'Settings'
,p_alias=>'SETTINGS'
,p_step_title=>'إعدادات الموارد البشرية والرواتب'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000388)
,p_plug_name=>'التجهيز'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000389)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000388)
,p_button_name=>'SETUP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز / استكمال الإعدادات (الحسابات والفترات والوردية)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000390)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setup'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_pay_pkg.quick_setup;',
'    apex_application.g_print_success_message := ''تم التجهيز ('' || l_n || '' إضافة)'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000389)
,p_internal_uid=>91820272000000390
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000391)
,p_plug_name=>'عناصر الراتب'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select e.id, e.code, e.name_ar, case e.element_type when ''EARNING'' then ''استحقاق'' when ''EMPLOYER_CONTRIBUTION'' then ''على المنشأة''',
'       else ''استقطاع'' end as typ, noona_ui_pkg.code_label(e.affects_eos) as eos, noona_ui_pkg.code_label(e.is_recurring) as rec,',
'       case when e.tenant_id is null then ''النظام'' else ''المؤسسة'' end as owner',
'  from pay_element e where e.is_active = ''Y'' order by e.sort_order'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'عناصر الراتب'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000392)
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
,p_internal_uid=>91820272000000392
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000394)
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
 p_id=>wwv_flow_imp.id(91820272000000395)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000396)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'العنصر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000397)
,p_db_column_name=>'TYP'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000398)
,p_db_column_name=>'EOS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'يدخل في نهاية الخدمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000399)
,p_db_column_name=>'REC'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'ثابت شهري'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000400)
,p_db_column_name=>'OWNER'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000393)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'393'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:TYP:EOS:REC:OWNER'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000401)
,p_plug_name=>'إضافة عنصر خاص بالمؤسسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>12
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">مثل بدل وجبة أو بدل اتصال أو بدل طبيعة عمل أو استقطاع ثابت. بعد الإضافة حدد قيمته في سياسة البدلات أو في هيكل راتب الموظف.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000402)
,p_name=>'P70_EL_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000401)
,p_prompt=>'الرمز بالإنجليزية (MEAL_ALLOW)'
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
 p_id=>wwv_flow_imp.id(91820272000000403)
,p_name=>'P70_EL_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000401)
,p_prompt=>'اسم العنصر'
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
 p_id=>wwv_flow_imp.id(91820272000000404)
,p_name=>'P70_EL_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000401)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:استحقاق (بدل);EARNING,استقطاع ثابت;DEDUCTION'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000405)
,p_name=>'P70_EL_EOS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000401)
,p_prompt=>'يدخل في أجر نهاية الخدمة'
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
 p_id=>wwv_flow_imp.id(91820272000000406)
,p_name=>'P70_EL_PRO'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000401)
,p_prompt=>'بالتناسب مع أيام العمل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نعم;Y,لا (يصرف كاملاً);N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000407)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000401)
,p_button_name=>'ADD_ELEMENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة العنصر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000408)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Element'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_pay_pkg.save_element(null, :P70_EL_CODE, :P70_EL_NAME, :P70_EL_TYPE, ''Y'', :P70_EL_PRO, :P70_EL_EOS);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000407)
,p_process_success_message=>'تمت إضافة العنصر'
,p_internal_uid=>91820272000000408
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000409)
,p_plug_name=>'سياسة البدلات (لكل شركة أو دولة)'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, e.name_ar as element, case when r.company_id is not null then ''الشركة: '' || c.legal_name_ar',
'       when r.country_code is not null then ''شركات الدولة: '' || nvl(k.name_ar, r.country_code) else ''كل الشركات'' end as scope,',
'       noona_hr_pkg.category_label(r.employee_category) as category, noona_pay_pkg.rule_text(r.id) as rule_txt,',
'       case r.is_auto when ''Y'' then ''تلقائي لكل الموظفين'' else ''لمن يختار «حسب السياسة»'' end as auto_txt,',
'       to_char(r.effective_from, ''YYYY-MM-DD'') as eff, to_char(r.effective_to, ''YYYY-MM-DD'') as eff_to',
'  from pay_element_rule r join pay_element e on e.id = r.element_id left join org_company c on c.id = r.company_id',
'  left join ref_country k on k.country_code = r.country_code',
' where r.formula_type in (''FIXED'', ''PCT_OF_ELEMENT'') and r.status_code = ''ACTIVE'' and r.tenant_id is not null',
'   and (r.company_id is null or r.company_id = noona_pay_pkg.company)',
' order by e.sort_order, r.effective_from desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'سياسة البدلات (لكل شركة أو دولة)'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000410)
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
,p_internal_uid=>91820272000000410
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000412)
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
 p_id=>wwv_flow_imp.id(91820272000000413)
,p_db_column_name=>'ELEMENT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'البدل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000414)
,p_db_column_name=>'SCOPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النطاق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000415)
,p_db_column_name=>'CATEGORY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000416)
,p_db_column_name=>'RULE_TXT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'القيمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000417)
,p_db_column_name=>'AUTO_TXT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'التطبيق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000418)
,p_db_column_name=>'EFF'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'ساري من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000419)
,p_db_column_name=>'EFF_TO'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'حتى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000411)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'411'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ELEMENT:SCOPE:CATEGORY:RULE_TXT:AUTO_TXT:EFF:EFF_TO'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000420)
,p_plug_name=>'قاعدة بدل جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>16
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">قاعدة الشركة تتقدم على قاعدة الدولة. القاعدة الجديدة لنفس البدل والنطاق والفئة تحل محل السابقة من تاريخ سريانها وتبقى السابقة للفترات الماضية. مثال: بدل السكن 25% من الأساسي بحد أعلى 5000 لكل شركات المؤسسة في السعودية.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000421)
,p_name=>'P70_R_EL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'البدل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || case when element_type <> ''EARNING'' then '' (استقطاع)'' end d, code r from pay_element where is_active = ''Y'' and is_recurring = ''Y'' and element_type in (''EARNING'', ''DEDUCTION'') and code <> ''BASIC'' order by sort_order, name_ar'
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
 p_id=>wwv_flow_imp.id(91820272000000422)
,p_name=>'P70_R_SCOPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'النطاق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:الشركة الحالية فقط;COMPANY,كل شركات المؤسسة في دولة;COUNTRY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000423)
,p_name=>'P70_R_COUNTRY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'الدولة (للنطاق دولة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, country_code r from ref_country where is_active = ''Y'' order by nvl(sort_order, 999), name_ar'
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
 p_id=>wwv_flow_imp.id(91820272000000424)
,p_name=>'P70_R_METHOD'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'الطريقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نسبة من عنصر;PERCENT,مبلغ ثابت;FIXED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000425)
,p_name=>'P70_R_VALUE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'النسبة % أو المبلغ'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000426)
,p_name=>'P70_R_BASIS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'النسبة من'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, code r from pay_element where is_active = ''Y'' and element_type = ''EARNING'' and is_recurring = ''Y'' order by case code when ''BASIC'' then 0 else 1 end, sort_order'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000427)
,p_name=>'P70_R_MIN'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'حد أدنى للمبلغ'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000428)
,p_name=>'P70_R_MAX'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'حد أعلى للمبلغ'
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
 p_id=>wwv_flow_imp.id(91820272000000429)
,p_name=>'P70_R_CAT'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'فئة الموظفين'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_hr_pkg.category_label(c) d, c r from (select noona_hr_pkg.category_for(noona_hr_pkg.company_country) c, 1 o from dual union all select noona_hr_pkg.category_for(''ZZ''), 2 from dual) order by o'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'الكل'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000430)
,p_name=>'P70_R_AUTO'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'التطبيق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تلقائي لكل موظفي النطاق;Y,لمن يحدد له «حسب سياسة الشركة» فقط;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000431)
,p_name=>'P70_R_FROM'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_prompt=>'يسري من'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000432)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000420)
,p_button_name=>'ADD_RULE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ القاعدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000433)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Rule'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_pay_pkg.save_allowance_rule(:P70_R_EL, :P70_R_SCOPE, :P70_R_COUNTRY, :P70_R_METHOD, to_number(:P70_R_VALUE),',
'        :P70_R_BASIS, to_number(:P70_R_MIN), to_number(:P70_R_MAX), :P70_R_CAT, :P70_R_AUTO, to_date(:P70_R_FROM, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000432)
,p_process_success_message=>'تم حفظ قاعدة البدل'
,p_internal_uid=>91820272000000433
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000434)
,p_plug_name=>'إيقاف قاعدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>17
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000435)
,p_name=>'P70_END_RULE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000434)
,p_prompt=>'القاعدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.name_ar || '' - '' || noona_pay_pkg.rule_text(r.id) || '' (من '' || to_char(r.effective_from, ''YYYY-MM-DD'') || '')'' d, r.id r from pay_element_rule r join pay_element e on e.id = r.element_id where r.formula_type in (''FIXED'', ''PCT_OF_ELEMENT'') and r.status_code = ''ACTIVE'' and r.tenant_id is not null and r.effective_to is null and (r.company_id is null or r.company_id = noona_pay_pkg.company) order by 1'
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
 p_id=>wwv_flow_imp.id(91820272000000436)
,p_name=>'P70_END_DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000434)
,p_prompt=>'آخر يوم لتطبيقها'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000437)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000434)
,p_button_name=>'END_RULE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إيقاف القاعدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000438)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'End Rule'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    noona_pay_pkg.end_rule(:P70_END_RULE, to_date(:P70_END_DATE, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000437)
,p_process_success_message=>'تم إيقاف القاعدة'
,p_internal_uid=>91820272000000438
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000439)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P70_R_COUNTRY := nvl(:P70_R_COUNTRY, noona_hr_pkg.company_country);',
'    :P70_R_FROM := nvl(:P70_R_FROM, to_char(trunc(sysdate, ''MM''), ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820272000000439
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000440)
,p_plug_name=>'قواعد التأمينات الاجتماعية والإضافي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, e.name_ar as element, nvl(k.name_ar, ''كل الدول'') as country, noona_hr_pkg.category_label(r.employee_category) as category,',
'       json_value(r.parameters, ''$.pct'') as pct, json_value(r.parameters, ''$.min'') as min_base, json_value(r.parameters, ''$.max'') as max_base,',
'       (select listagg(b.name_ar, '' + '') within group (order by b.sort_order) from pay_element b',
'         where b.code in (select j.c from json_table(r.parameters, ''$.base[*]'' columns (c varchar2(50) path ''$'')) j)) as base,',
'       to_char(r.effective_from, ''YYYY-MM-DD'') as eff',
'  from pay_element_rule r join pay_element e on e.id = r.element_id left join ref_country k on k.country_code = r.country_code',
' where r.status_code = ''ACTIVE'' and r.formula_type not in (''FIXED'', ''PCT_OF_ELEMENT'') order by e.sort_order, r.version_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'قواعد التأمينات الاجتماعية والإضافي'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000441)
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
,p_internal_uid=>91820272000000441
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000443)
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
 p_id=>wwv_flow_imp.id(91820272000000444)
,p_db_column_name=>'ELEMENT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'العنصر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000445)
,p_db_column_name=>'COUNTRY'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الدولة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000446)
,p_db_column_name=>'CATEGORY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000447)
,p_db_column_name=>'PCT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'النسبة %'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000448)
,p_db_column_name=>'BASE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'أساس الاشتراك'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000449)
,p_db_column_name=>'MIN_BASE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الحد الأدنى للأجر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000450)
,p_db_column_name=>'MAX_BASE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحد الأعلى للأجر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000451)
,p_db_column_name=>'EFF'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'ساري من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000442)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'442'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ELEMENT:COUNTRY:CATEGORY:PCT:BASE:MIN_BASE:MAX_BASE:EFF'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000452)
,p_plug_name=>'أنواع الإجازات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.id, t.code, t.name_ar, noona_ui_pkg.code_label(t.is_paid) as paid, decode(t.unit_code, ''HOUR'', ''ساعة'', ''يوم'') as unit,',
'       t.max_per_year from hr_leave_type t where t.is_active = ''Y'' order by t.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أنواع الإجازات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000453)
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
,p_internal_uid=>91820272000000453
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000455)
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
 p_id=>wwv_flow_imp.id(91820272000000456)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000457)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000458)
,p_db_column_name=>'PAID'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'مدفوعة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000459)
,p_db_column_name=>'UNIT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الوحدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000460)
,p_db_column_name=>'MAX_PER_YEAR'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الحد السنوي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000454)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'454'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:PAID:UNIT:MAX_PER_YEAR'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000461)
,p_plug_name=>'فترات الرواتب'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select p.id, p.period_code, to_char(p.start_date, ''YYYY-MM-DD'') as s, to_char(p.end_date, ''YYYY-MM-DD'') as e,',
'       to_char(p.pay_date, ''YYYY-MM-DD'') as pay from pay_period p where p.company_id = noona_pay_pkg.company order by p.start_date desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'فترات الرواتب'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000462)
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
,p_internal_uid=>91820272000000462
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000464)
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
 p_id=>wwv_flow_imp.id(91820272000000465)
,p_db_column_name=>'PERIOD_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الفترة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000466)
,p_db_column_name=>'S'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000467)
,p_db_column_name=>'E'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000468)
,p_db_column_name=>'PAY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'تاريخ الصرف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000463)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'463'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PERIOD_CODE:S:E:PAY'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000469)
,p_branch_action=>'f?p=&APP_ID.:70:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
