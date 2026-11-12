prompt --application/pages/page_00042
begin
--   Manifest
--     PAGE: 00042
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>147
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>42
,p_name=>'Drivers'
,p_alias=>'DRIVERS'
,p_step_title=>'السائقون'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000472)
,p_plug_name=>'السائقون'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select d.id, d.full_name, d.phone, d.license_no, d.license_class, d.license_expiry, d.hazmat_certified, noona_trn_pkg.badge(d.status_code) status_html,',
'       nvl(noona_wrk_pkg.employee_name(d.employee_id), ''— غير مربوط —'') emp, noona_wrk_pkg.method_label(d.earnings_method) paym,',
'       noona_wrk_pkg.monthly_salary(d.employee_id) salary, to_char(nvl(d.trip_bonus_rate, d.trip_allowance), ''FM999G990D99'') || decode(d.trip_bonus_basis, ''PER_KM'', '' للكيلو'', ''PER_TON'', '' للطن'', ''PCT_FREIGHT'', ''% من الإيراد'', '' للرحلة'') bonus,',
'       (select count(*) from trn_trip t where t.driver_id = d.id and t.status_code = ''COMPLETED'') trips,',
'       (select nvl(sum(t.actual_distance_km), 0) from trn_trip t where t.driver_id = d.id and t.status_code = ''COMPLETED'') km',
'  from trn_driver d where d.company_id = noona_trn_pkg.company order by d.full_name'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'السائقون'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000473)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP:P42_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820290000000473
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000475)
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
 p_id=>wwv_flow_imp.id(91820290000000476)
,p_db_column_name=>'FULL_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'السائق'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000477)
,p_db_column_name=>'EMP'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الموظف (الموارد البشرية)'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000478)
,p_db_column_name=>'SALARY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الراتب الشهري'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000479)
,p_db_column_name=>'BONUS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'بونص الرحلة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000480)
,p_db_column_name=>'PAYM'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'صرف البونص'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000481)
,p_db_column_name=>'PHONE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الجوال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000482)
,p_db_column_name=>'LICENSE_NO'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الرخصة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000483)
,p_db_column_name=>'LICENSE_CLASS'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000484)
,p_db_column_name=>'LICENSE_EXPIRY'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'انتهاء الرخصة'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000485)
,p_db_column_name=>'HAZMAT_CERTIFIED'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'مواد خطرة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000486)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000487)
,p_db_column_name=>'TRIPS'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الرحلات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000488)
,p_db_column_name=>'KM'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'الكيلومترات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000474)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'474'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'FULL_NAME:EMP:SALARY:BONUS:PAYM:PHONE:LICENSE_NO:LICENSE_CLASS:LICENSE_EXPIRY:HAZMAT_CERTIFIED:STATUS_HTML:TRIPS:KM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000489)
,p_plug_name=>'إضافة / تعديل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000490)
,p_name=>'P42_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000491)
,p_name=>'P42_EMP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'الموظف من الموارد البشرية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.employee_no || '' - '' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_trn_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'')) order by e.employee_no'
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
 p_id=>wwv_flow_imp.id(91820290000000492)
,p_name=>'P42_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'الاسم (فارغ = من ملف الموظف)'
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
 p_id=>wwv_flow_imp.id(91820290000000493)
,p_name=>'P42_PHONE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000494)
,p_name=>'P42_NID'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'رقم الهوية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000495)
,p_name=>'P42_LICNO'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'رقم الرخصة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000496)
,p_name=>'P42_LICCLS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'فئة الرخصة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000497)
,p_name=>'P42_LICEXP'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'انتهاء الرخصة'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000498)
,p_name=>'P42_HAZ'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'مؤهل للمواد الخطرة'
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
 p_id=>wwv_flow_imp.id(91820290000000499)
,p_name=>'P42_ALW'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'بدل الرحلة الافتراضي'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000500)
,p_name=>'P42_BBAS'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'أساس بونص الرحلة (فوق الراتب)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مبلغ ثابت لكل رحلة;PER_TRIP,لكل كيلومتر;PER_KM,لكل طن منقول;PER_TON,نسبة من إيراد الرحلة %;PCT_FREIGHT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000501)
,p_name=>'P42_BRATE'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'قيمة البونص (مبلغ، أو للكيلو، أو للطن، أو نسبة %)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000502)
,p_name=>'P42_PAYM'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_prompt=>'صرف البونص'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مع الراتب (مسير الرواتب);PAYROLL,نقداً (سند صرف);CASH,تحويل بنكي (سند صرف);BANK_TRANSFER,لا يستحق بونص;NONE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000503)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000489)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000504)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob; l_id number;',
'begin',
'  if :P42_EMP is not null then',
'    for e in (select * from json_table(noona_wrk_pkg.employee_json(to_number(:P42_EMP)), ''$'' columns (n varchar2(400) path ''$.name'',',
'              ph varchar2(40) path ''$.phone'', nid varchar2(30) path ''$.nationalId''))) loop',
'      :P42_NAME := nvl(:P42_NAME, e.n); :P42_PHONE := nvl(:P42_PHONE, e.ph); :P42_NID := nvl(:P42_NID, e.nid);',
'    end loop;',
'  end if;',
'  select json_object(''id'' value to_number(:P42_ID), ''employeeId'' value :P42_EMP, ''name'' value :P42_NAME, ''phone'' value :P42_PHONE, ''nationalId'' value :P42_NID, ''licenseNo'' value :P42_LICNO, ''licenseClass'' value :P42_LICCLS, ''licenseExpiry'' value :P42_LICEXP, ''hazmat'' value :P42_HAZ, ''allowance'' value to_number(:P42_ALW), ''bonusBasis'' value :P42_BBAS, ''bonusRate'' value to_number(:P42_BRATE), ''earningsMethod'' value :P42_PAYM absent on null) into l from dual;',
'  l_id := noona_trn_pkg.save_driver(l);',
'  noona_wrk_pkg.set_worker(''DRIVER'', l_id, to_number(:P42_EMP), nvl(:P42_PAYM, ''PAYROLL''));',
'  noona_wrk_pkg.set_bonus(''DRIVER'', l_id, :P42_BBAS, to_number(:P42_BRATE));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000503)
,p_process_success_message=>'تم الحفظ'
,p_internal_uid=>91820290000000504
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000505)
,p_branch_action=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000506)
,p_plug_name=>'الراتب الشهري'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الراتب الشهري يصرف من مسير الرواتب حسب هيكل راتب الموظف في الموارد البشرية، والبونص أعلاه يضاف فوقه عن كل رحلة مقفلة.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P42_EMP is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000507)
,p_name=>'P42_SALARY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000506)
,p_prompt=>'الراتب الشهري (من الموارد البشرية)'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000508)
,p_plug_name=>'حالة السائق'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000509)
,p_name=>'P42_SET'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000508)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:متاح;AVAILABLE,خارج الدوام;OFF_DUTY,موقوف;SUSPENDED,ترك العمل;LEFT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820290000000510)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000508)
,p_button_name=>'SET_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير حالة السائق المختار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000511)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.set_driver_status(:P42_ID, :P42_SET);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000510)
,p_process_success_message=>'تم تغيير الحالة'
,p_internal_uid=>91820290000000511
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000512)
,p_plug_name=>'حساب السائق على الهاتف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">اربط السائق بمستخدم النظام ليفتح «رحلاتي» على هاتفه: التحرك والعداد، التسليم بالصورة والتوقيع، الإبلاغ عن عطل بالموقع، والإقفال.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000513)
,p_name=>'P42_USER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000512)
,p_prompt=>'مستخدم النظام'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(u.display_name, u.username) || '' ('' || u.username || '')'' d, upper(u.username) r from sec_user_membership m join sec_user u on u.id = m.user_id where m.status_code = ''ACTIVE'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820290000000514)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000512)
,p_button_name=>'LINK_USER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'ربط المستخدم بالسائق المختار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000515)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'User'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_trn_pkg.set_driver_user(:P42_ID, :P42_USER);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000514)
,p_process_success_message=>'تم ربط المستخدم'
,p_internal_uid=>91820290000000515
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000516)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for d in (select * from trn_driver where id = :P42_ID and company_id = noona_trn_pkg.company) loop',
'    :P42_USER := d.user_name; :P42_EMP := d.employee_id; :P42_PAYM := d.earnings_method;',
'    :P42_BBAS := d.trip_bonus_basis; :P42_BRATE := d.trip_bonus_rate;',
'    :P42_SALARY := to_char(noona_wrk_pkg.monthly_salary(d.employee_id), ''FM999G999G990D00'');',
'    :P42_NAME := d.full_name; :P42_PHONE := d.phone; :P42_NID := d.national_id; :P42_LICNO := d.license_no; :P42_LICCLS := d.license_class;',
'    :P42_LICEXP := to_char(d.license_expiry, ''YYYY-MM-DD''); :P42_HAZ := d.hazmat_certified; :P42_ALW := d.trip_allowance; :P42_SET := d.status_code;',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000516
);

wwv_flow_imp.component_end;
end;
/
