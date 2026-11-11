prompt --application/pages/page_00054
begin
--   Manifest
--     PAGE: 00054
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
 p_id=>54
,p_name=>'Rates'
,p_alias=>'RATES'
,p_step_title=>'تعرفة الترحيل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820290000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000582)
,p_plug_name=>'تعرفة الترحيل'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, r.name_ar, noona_sal_pkg.customer_label(r.customer_account_id) customer, rt.name_ar route, c.name_ar cargo,',
'       noona_trn_pkg.basis_label(r.rate_basis) basis, r.rate_amount, r.min_charge, r.priority_no, r.effective_from, r.effective_to,',
'       noona_trn_pkg.badge(r.status_code) status_html',
'  from trn_rate r left join trn_route rt on rt.id = r.route_id left join trn_cargo_type c on c.id = r.cargo_type_id',
' where r.company_id = noona_trn_pkg.company order by r.priority_no, r.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'تعرفة الترحيل'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820290000000583)
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
,p_detail_link=>'f?p=&APP_ID.:54:&SESSION.::&DEBUG.:RP:P54_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820290000000583
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000585)
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
 p_id=>wwv_flow_imp.id(91820290000000586)
,p_db_column_name=>'NAME_AR'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'التعرفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000587)
,p_db_column_name=>'CUSTOMER'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'العميل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000588)
,p_db_column_name=>'ROUTE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المسار'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000589)
,p_db_column_name=>'CARGO'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الشحنة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000590)
,p_db_column_name=>'BASIS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الأساس'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000591)
,p_db_column_name=>'RATE_AMOUNT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'السعر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000592)
,p_db_column_name=>'MIN_CHARGE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'أدنى ترحيل'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000593)
,p_db_column_name=>'PRIORITY_NO'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الأولوية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000594)
,p_db_column_name=>'EFFECTIVE_FROM'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'من'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000595)
,p_db_column_name=>'EFFECTIVE_TO'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'إلى'
,p_column_type=>'DATE'
,p_format_mask=>'YYYY-MM-DD'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820290000000596)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820290000000584)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'584'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'NAME_AR:CUSTOMER:ROUTE:CARGO:BASIS:RATE_AMOUNT:MIN_CHARGE:PRIORITY_NO:EFFECTIVE_FROM:EFFECTIVE_TO:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820290000000597)
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
 p_id=>wwv_flow_imp.id(91820290000000598)
,p_name=>'P54_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000599)
,p_name=>'P54_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'اسم التعرفة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(91820290000000600)
,p_name=>'P54_CUST'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'العميل (فارغ = الكل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_sal_pkg.customer_label(a.id) d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id where a.company_id = noona_trn_pkg.company and a.status_code = ''ACTIVE'' and nvl(c.is_walk_in, ''N'') = ''N'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820290000000601)
,p_name=>'P54_ROUTE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'المسار (فارغ = الكل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.name_ar || '' · '' || r.distance_km || '' كم · '' || r.standard_hours || '' س'' d, r.id r from trn_route r where r.company_id = noona_trn_pkg.company and r.is_active = ''Y'' order by r.name_ar'
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
 p_id=>wwv_flow_imp.id(91820290000000602)
,p_name=>'P54_CARGO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'نوع الشحنة (فارغ = الكل)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from trn_cargo_type where company_id = noona_trn_pkg.company and is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820290000000603)
,p_name=>'P54_BASIS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'أساس الحساب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:للطن المتري;PER_METRIC_TON,للطن القصير;PER_SHORT_TON,للطن الطويل;PER_LONG_TON,للكيلوجرام;PER_KG,للمتر المكعب;PER_M3,للتر;PER_LITER,للكيلومتر;PER_KM,للطن-كيلومتر;PER_TON_KM,للرحلة;PER_TRIP,للحاوية;PER_CONTAINER,للطبلية;PER_PALLET,للقطعة;PER_PIECE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000604)
,p_name=>'P54_RATE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'السعر'
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
 p_id=>wwv_flow_imp.id(91820290000000605)
,p_name=>'P54_MIN'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'أدنى ترحيل'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820290000000606)
,p_name=>'P54_PRIO'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'الأولوية (الأقل أولاً)'
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
 p_id=>wwv_flow_imp.id(91820290000000607)
,p_name=>'P54_FROM'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'سارية من'
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
 p_id=>wwv_flow_imp.id(91820290000000608)
,p_name=>'P54_TO'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_prompt=>'سارية إلى'
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
 p_id=>wwv_flow_imp.id(91820290000000609)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820290000000597)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000610)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob; l_id number;',
'begin',
'  select json_object(''id'' value to_number(:P54_ID), ''name'' value :P54_NAME, ''customer'' value :P54_CUST, ''route'' value :P54_ROUTE, ''cargo'' value :P54_CARGO, ''basis'' value :P54_BASIS, ''rate'' value to_number(:P54_RATE), ''minCharge'' value to_number(:P54_MIN), ''priority'' value to_number(:P54_PRIO), ''from'' value :P54_FROM, ''to'' value :P54_TO absent on null) into l from dual;',
'  l_id := noona_trn_pkg.save_rate(l);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820290000000609)
,p_process_success_message=>'تم الحفظ'
,p_internal_uid=>91820290000000610
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820290000000611)
,p_branch_action=>'f?p=&APP_ID.:54:&SESSION.::&DEBUG.:RP,54::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820290000000612)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  for r in (select * from trn_rate where id = :P54_ID and company_id = noona_trn_pkg.company) loop',
'    :P54_NAME := r.name_ar; :P54_CUST := r.customer_account_id; :P54_ROUTE := r.route_id; :P54_CARGO := r.cargo_type_id; :P54_BASIS := r.rate_basis;',
'    :P54_RATE := r.rate_amount; :P54_MIN := r.min_charge; :P54_PRIO := r.priority_no; :P54_FROM := to_char(r.effective_from, ''YYYY-MM-DD'');',
'    :P54_TO := to_char(r.effective_to, ''YYYY-MM-DD'');',
'  end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820290000000612
);

wwv_flow_imp.component_end;
end;
/
