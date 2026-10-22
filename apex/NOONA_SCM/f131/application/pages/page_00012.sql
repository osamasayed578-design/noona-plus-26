prompt --application/pages/page_00012
begin
--   Manifest
--     PAGE: 00012
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>131
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>12
,p_name=>'Categories'
,p_alias=>'CATEGORIES'
,p_step_title=>'فئات الأصناف والحسابات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000064)
,p_plug_name=>'فئات الأصناف'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select g.id, g.code, g.name_ar, decode(g.product_profile, ''GENERAL'', ''عام'', ''AUTO_PART'', ''قطع غيار'', ''PHARMA'', ''أدوية'', ''RAW_MATERIAL'', ''خامات'', ''FOOD'', ''أغذية'', ''ELECTRONICS'', ''إلكترونيات'', ''APPAREL'', ''ملابس'', g.product_profile) as profile,',
'       (select account_code || '' - '' || name_ar from gl_account where id = g.inventory_account_id) as inv_acc, (select account_code || '' - '' || name_ar from gl_account where id = g.cogs_account_id) as cogs_acc,',
'       (select account_code || '' - '' || name_ar from gl_account where id = g.revenue_account_id) as rev_acc, (select account_code || '' - '' || name_ar from gl_account where id = g.expense_account_id) as exp_acc,',
'       (select count(*) from inv_item i where i.category_id = g.id) as items',
'  from inv_item_category g order by g.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'فئات الأصناف'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820268000000065)
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
,p_internal_uid=>91820268000000065
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000067)
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
 p_id=>wwv_flow_imp.id(91820268000000068)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000069)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000070)
,p_db_column_name=>'PROFILE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'ملف الأصناف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000071)
,p_db_column_name=>'INV_ACC'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'حساب المخزون'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000072)
,p_db_column_name=>'COGS_ACC'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'تكلفة المبيعات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000073)
,p_db_column_name=>'REV_ACC'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الإيراد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000074)
,p_db_column_name=>'EXP_ACC'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المصروف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000075)
,p_db_column_name=>'ITEMS'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الأصناف'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820268000000066)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'66'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:PROFILE:INV_ACC:COGS_ACC:REV_ACC:EXP_ACC:ITEMS'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000076)
,p_plug_name=>'فئة جديدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000077)
,p_name=>'P12_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820268000000076)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
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
 p_id=>wwv_flow_imp.id(91820268000000078)
,p_name=>'P12_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820268000000076)
,p_prompt=>'اسم الفئة'
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
 p_id=>wwv_flow_imp.id(91820268000000079)
,p_name=>'P12_PROFILE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820268000000076)
,p_prompt=>'ملف الأصناف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بضائع عامة;GENERAL,قطع غيار السيارات;AUTO_PART,الأدوية والمستحضرات;PHARMA,أغذية;FOOD,إلكترونيات;ELECTRONICS,ملابس;APPAREL,خامات ومواد أولية;RAW_MATERIAL'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000080)
,p_name=>'P12_INV'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820268000000076)
,p_prompt=>'حساب المخزون'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.account_code r from gl_account a where a.coa_id = noona_gl_pkg.primary_coa and a.is_postable = ''Y'' and a.account_type = ''ASSET'' order by a.account_code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'الافتراضي 1105'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000081)
,p_name=>'P12_COGS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820268000000076)
,p_prompt=>'حساب تكلفة المبيعات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.account_code r from gl_account a where a.coa_id = noona_gl_pkg.primary_coa and a.is_postable = ''Y'' and a.account_type = ''EXPENSE'' order by a.account_code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'الافتراضي 5101'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000082)
,p_name=>'P12_REV'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820268000000076)
,p_prompt=>'حساب الإيراد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.account_code r from gl_account a where a.coa_id = noona_gl_pkg.primary_coa and a.is_postable = ''Y'' and a.account_type = ''REVENUE'' order by a.account_code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'الافتراضي 4101'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000083)
,p_name=>'P12_EXP'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820268000000076)
,p_prompt=>'حساب المصروف (للصرف والخدمات)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.account_code r from gl_account a where a.coa_id = noona_gl_pkg.primary_coa and a.is_postable = ''Y'' and a.account_type = ''EXPENSE'' order by a.account_code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'الافتراضي 5299'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820268000000085)
,p_validation_name=>'P12_CODE required (ADD)'
,p_validation_sequence=>19
,p_validation=>'P12_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820268000000084)
,p_associated_item=>wwv_flow_imp.id(91820268000000077)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820268000000086)
,p_validation_name=>'P12_NAME required (ADD)'
,p_validation_sequence=>20
,p_validation=>'P12_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820268000000084)
,p_associated_item=>wwv_flow_imp.id(91820268000000078)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000084)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820268000000076)
,p_button_name=>'ADD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الفئة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820268000000087)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Category'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_inv_pkg.create_category(:P12_CODE, :P12_NAME, :P12_PROFILE, null, :P12_INV, :P12_COGS, :P12_REV, :P12_EXP);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820268000000084)
,p_process_success_message=>'تمت إضافة الفئة'
,p_internal_uid=>91820268000000087
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820268000000088)
,p_branch_action=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.:12::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
