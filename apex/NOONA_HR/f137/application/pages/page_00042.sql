prompt --application/pages/page_00042
begin
--   Manifest
--     PAGE: 00042
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
 p_id=>42
,p_name=>'Payroll Inputs'
,p_alias=>'PAYROLL-INPUTS'
,p_step_title=>'المدخلات المتغيرة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000259)
,p_plug_name=>'إدخال'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الإضافي بالساعات (يحسب آلياً: ساعة الأجر + 50% من ساعة الأساسي) أو بمبلغ، والمكافآت والعمولات والجزاءات والخصومات بمبالغ، والغياب بالأيام.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000260)
,p_name=>'P42_PERIOD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000259)
,p_prompt=>'الفترة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.period_code || case when exists (select 1 from pay_run r where r.period_id = p.id and r.run_type = ''REGULAR'') then '' (له تشغيل)'' end d, p.id r from pay_period p where p.company_id = noona_pay_pkg.company and p.payroll_group_id = noona_pay_pkg.default_group order by p.start_date desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000261)
,p_name=>'P42_EMP'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000259)
,p_prompt=>'الموظف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_hr_pkg.employment_label(m.id) d, m.id r from hr_employment m where m.company_id = noona_hr_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'', ''SUSPENDED'') and exists (select 1 from pay_employee_element x where x.employment_id = m.id) order by 1'
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
 p_id=>wwv_flow_imp.id(91820272000000262)
,p_name=>'P42_ELEMENT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000259)
,p_prompt=>'العنصر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مكافأة;BONUS,عمولة;COMMISSION,عمل إضافي (ساعات);OVERTIME,بدلات أخرى (مرة واحدة);OTHER_ALLOW,جزاء;PENALTY,خصم آخر;OTHER_DED,غياب (أيام);ABSENCE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000263)
,p_name=>'P42_QTY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820272000000259)
,p_prompt=>'الكمية (ساعات / أيام)'
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
 p_id=>wwv_flow_imp.id(91820272000000264)
,p_name=>'P42_AMOUNT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820272000000259)
,p_prompt=>'المبلغ'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820272000000266)
,p_validation_name=>'P42_PERIOD required (ADD)'
,p_validation_sequence=>6
,p_validation=>'P42_PERIOD'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820272000000265)
,p_associated_item=>wwv_flow_imp.id(91820272000000260)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000265)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000259)
,p_button_name=>'ADD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000267)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P42_PERIOD is null then',
'        :P42_PERIOD := noona_pay_pkg.period_for(trunc(sysdate));',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820272000000267
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000268)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_pay_pkg.add_input(:P42_PERIOD, :P42_EMP, :P42_ELEMENT, :P42_QTY, :P42_AMOUNT);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000265)
,p_process_success_message=>'تمت الإضافة؛ أعد حساب التشغيل إن كان محسوباً'
,p_internal_uid=>91820272000000268
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000269)
,p_plug_name=>'حذف مدخل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000270)
,p_name=>'P42_DEL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000269)
,p_prompt=>'المدخل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_hr_pkg.employment_label(i.employment_id) || '' · '' || e.name_ar || '' · '' || nvl(to_char(i.amount), i.quantity) d, i.id r from pay_input i join pay_element e on e.id = i.element_id where i.period_id = :P42_PERIOD and i.status_code in (''PENDING'', ''VALIDATED'')'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820272000000271)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000269)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000272)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_pay_pkg.delete_input(:P42_DEL);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820272000000271)
,p_process_success_message=>'تم الحذف'
,p_internal_uid=>91820272000000272
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000273)
,p_plug_name=>'مدخلات الفترة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, noona_hr_pkg.employment_label(i.employment_id) as emp, e.name_ar as element, i.quantity, i.amount,',
'       case i.status_code when ''APPLIED'' then ''مطبق'' else ''بانتظار التشغيل'' end as status, i.created_by',
'  from pay_input i join pay_element e on e.id = i.element_id where i.period_id = :P42_PERIOD and i.company_id = noona_pay_pkg.company'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مدخلات الفترة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820272000000274)
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
,p_internal_uid=>91820272000000274
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000276)
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
 p_id=>wwv_flow_imp.id(91820272000000277)
,p_db_column_name=>'EMP'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الموظف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000278)
,p_db_column_name=>'ELEMENT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'العنصر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000279)
,p_db_column_name=>'QUANTITY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000280)
,p_db_column_name=>'AMOUNT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000281)
,p_db_column_name=>'STATUS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820272000000282)
,p_db_column_name=>'CREATED_BY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'أدخله'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820272000000275)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'275'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'EMP:ELEMENT:QUANTITY:AMOUNT:STATUS:CREATED_BY'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000283)
,p_branch_action=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.::P42_PERIOD:&P42_PERIOD.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
