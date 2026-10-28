prompt --application/pages/page_00067
begin
--   Manifest
--     PAGE: 00067
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
 p_id=>67
,p_name=>'Asset Categories'
,p_alias=>'ASSET-CATEGORIES'
,p_step_title=>'فئات الأصول'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000507)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000681)
,p_plug_name=>'التجهيز'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_fa_pkg.is_ready = ''N'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000682)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000681)
,p_button_name=>'SETUP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز الأصول الثابتة (الدفتر والفئات الافتراضية والحسابات)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000683)
,p_process_sequence=>5
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setup'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_fa_pkg.quick_setup;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000682)
,p_process_success_message=>'تم التجهيز'
,p_internal_uid=>91820266000000683
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000684)
,p_plug_name=>'فئة جديدة / تعديل فئة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_fa_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000685)
,p_name=>'P67_ID'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'الفئة (للتعديل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from fa_category where company_id = noona_fa_pkg.company order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- فئة جديدة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000686)
,p_name=>'P67_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
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
 p_id=>wwv_flow_imp.id(91820266000000687)
,p_name=>'P67_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
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
 p_id=>wwv_flow_imp.id(91820266000000688)
,p_name=>'P67_METHOD'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'طريقة الإهلاك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:القسط الثابت;STRAIGHT_LINE,القسط المتناقص (1.5);DECLINING_BALANCE,المتناقص المضاعف (2);DOUBLE_DECLINING,لا يهلك (أراض);NONE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000689)
,p_name=>'P67_LIFE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'العمر الإنتاجي (شهر)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000690)
,p_name=>'P67_RES'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'القيمة المتبقية %'
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
 p_id=>wwv_flow_imp.id(91820266000000691)
,p_name=>'P67_PRORATE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'بداية الإهلاك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:يومي من تاريخ التشغيل;DAILY,شهر كامل من شهر التشغيل;FULL_MONTH,منتصف الشهر (حتى يوم 15 شهر كامل);MID_MONTH,من الشهر التالي;NEXT_MONTH'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000692)
,p_name=>'P67_ASSET_ACC'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'حساب الأصل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.id r from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger and a.is_postable = ''Y'' order by a.account_code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000693)
,p_name=>'P67_ACCUM_ACC'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'حساب مجمع الإهلاك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.id r from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger and a.is_postable = ''Y'' order by a.account_code'
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
 p_id=>wwv_flow_imp.id(91820266000000694)
,p_name=>'P67_EXP_ACC'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'حساب مصروف الإهلاك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select a.account_code || '' - '' || a.name_ar d, a.id r from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger and a.is_postable = ''Y'' order by a.account_code'
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
 p_id=>wwv_flow_imp.id(91820266000000695)
,p_name=>'P67_THRESHOLD'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_prompt=>'الحد الأدنى للرسملة'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000697)
,p_validation_name=>'P67_CODE required (SAVE)'
,p_validation_sequence=>15
,p_validation=>'P67_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000696)
,p_associated_item=>wwv_flow_imp.id(91820266000000686)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000698)
,p_validation_name=>'P67_NAME required (SAVE)'
,p_validation_sequence=>16
,p_validation=>'P67_NAME'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000696)
,p_associated_item=>wwv_flow_imp.id(91820266000000687)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000699)
,p_validation_name=>'P67_ASSET_ACC required (SAVE)'
,p_validation_sequence=>17
,p_validation=>'P67_ASSET_ACC'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000696)
,p_associated_item=>wwv_flow_imp.id(91820266000000692)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000696)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000684)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الفئة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000700)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P67_ID is not null then',
'        select code, name_ar, depreciation_method, useful_life_months, residual_pct, prorate_convention, asset_account_id,',
'               accum_depr_account_id, depr_expense_account_id, capitalization_threshold',
'          into :P67_CODE, :P67_NAME, :P67_METHOD, :P67_LIFE, :P67_RES, :P67_PRORATE, :P67_ASSET_ACC, :P67_ACCUM_ACC, :P67_EXP_ACC,',
'               :P67_THRESHOLD',
'          from fa_category where id = :P67_ID and company_id = noona_fa_pkg.company;',
'    else',
'        :P67_METHOD := nvl(:P67_METHOD, ''STRAIGHT_LINE'');',
'        :P67_PRORATE := nvl(:P67_PRORATE, ''DAILY'');',
'        :P67_ACCUM_ACC := nvl(:P67_ACCUM_ACC, noona_fa_pkg.acc(''1209''));',
'        :P67_EXP_ACC := nvl(:P67_EXP_ACC, noona_fa_pkg.acc(''5206''));',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000700
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000701)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P67_ID := noona_fa_pkg.save_category(:P67_ID, :P67_CODE, :P67_NAME, :P67_METHOD, :P67_LIFE, :P67_RES, :P67_PRORATE,',
'                                          :P67_ASSET_ACC, :P67_ACCUM_ACC, :P67_EXP_ACC, :P67_THRESHOLD);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000696)
,p_process_success_message=>'تم حفظ الفئة'
,p_internal_uid=>91820266000000701
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000702)
,p_plug_name=>'الفئات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select c.id, c.code, c.name_ar, noona_fa_pkg.method_label(c.depreciation_method) as method, c.useful_life_months,',
'       round(c.useful_life_months / 12, 1) as years, c.residual_pct, aa.account_code || '' - '' || aa.name_ar as asset_acc,',
'       ad.account_code as accum_acc, ae.account_code as exp_acc,',
'       (select count(*) from fa_asset a where a.category_id = c.id and a.status_code not in (''DISPOSED'', ''DRAFT'')) as assets',
'  from fa_category c left join gl_account aa on aa.id = c.asset_account_id left join gl_account ad on ad.id = c.accum_depr_account_id',
'  left join gl_account ae on ae.id = c.depr_expense_account_id where c.company_id = noona_fa_pkg.company order by c.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الفئات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000703)
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
,p_internal_uid=>91820266000000703
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000705)
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
 p_id=>wwv_flow_imp.id(91820266000000706)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000707)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000708)
,p_db_column_name=>'METHOD'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000709)
,p_db_column_name=>'USEFUL_LIFE_MONTHS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'العمر (شهر)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000710)
,p_db_column_name=>'YEARS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'العمر (سنة)'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000711)
,p_db_column_name=>'RESIDUAL_PCT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المتبقية %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000712)
,p_db_column_name=>'ASSET_ACC'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'حساب الأصل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000713)
,p_db_column_name=>'ACCUM_ACC'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'المجمع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000714)
,p_db_column_name=>'EXP_ACC'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'المصروف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000715)
,p_db_column_name=>'ASSETS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الأصول القائمة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000704)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'704'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:METHOD:USEFUL_LIFE_MONTHS:YEARS:RESIDUAL_PCT:ASSET_ACC:ACCUM_ACC:EXP_ACC:ASSETS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000716)
,p_branch_action=>'f?p=&APP_ID.:67:&SESSION.::&DEBUG.::P67_ID:&P67_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
