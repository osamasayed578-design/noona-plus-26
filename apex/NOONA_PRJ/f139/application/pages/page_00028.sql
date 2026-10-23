prompt --application/pages/page_00028
begin
--   Manifest
--     PAGE: 00028
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>28
,p_name=>'Hotel Reports'
,p_alias=>'HOTEL-REPORTS'
,p_step_title=>'تقارير الضيافة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000010)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000360)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000361)
,p_name=>'P28_PROPERTY'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820273000000360)
,p_prompt=>'الفندق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from re_property p where p.company_id = noona_hsp_pkg.company and p.status_code <> ''INACTIVE'' and exists (select 1 from hsp_room r where r.property_id = p.id) order by p.code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000362)
,p_name=>'P28_REPORT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000360)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:النزلاء المقيمون;INHOUSE,الإشغال والإيراد اليومي (ADR وRevPAR);OCC,الوصول والمغادرة القادمة;ARRIVALS,حسابات الشركات المحولة;CITY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000363)
,p_name=>'P28_FROM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000360)
,p_prompt=>'من'
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
 p_id=>wwv_flow_imp.id(91820273000000364)
,p_name=>'P28_TO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000360)
,p_prompt=>'إلى'
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
 p_id=>wwv_flow_imp.id(91820273000000365)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000360)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000366)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P28_PROPERTY := nvl(:P28_PROPERTY, noona_hsp_pkg.default_property); :P28_REPORT := nvl(:P28_REPORT, ''INHOUSE'');',
'    :P28_FROM := nvl(:P28_FROM, to_char(trunc(sysdate, ''MM''), ''YYYY-MM-DD'')); :P28_TO := nvl(:P28_TO, to_char(sysdate, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000366
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000367)
,p_plug_name=>'الإشغال'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P28_REPORT = ''OCC'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_hsp_pkg.occupancy_html(:P28_PROPERTY, to_date(:P28_FROM, ''YYYY-MM-DD''), to_date(:P28_TO, ''YYYY-MM-DD''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000368)
,p_plug_name=>'النزلاء المقيمون'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, r.room_no, noona_hsp_pkg.guest_name(x.guest_party_id) as guest, noona_hsp_pkg.guest_phone(x.guest_party_id) as phone,',
'       to_char(s.check_in_at, ''YYYY-MM-DD HH24:MI'') as since, to_char(s.expected_check_out, ''YYYY-MM-DD'') as dep, s.nightly_rate,',
'       noona_hsp_pkg.folio_balance(noona_hsp_pkg.folio_of_stay(s.id)) as balance, x.doc_no',
'  from hsp_stay s join hsp_room r on r.id = s.room_id join hsp_reservation x on x.id = s.reservation_id',
' where r.property_id = :P28_PROPERTY and s.status_code = ''IN_HOUSE'' and :P28_REPORT = ''INHOUSE'' order by r.room_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'النزلاء المقيمون'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000369)
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
,p_internal_uid=>91820273000000369
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000371)
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
 p_id=>wwv_flow_imp.id(91820273000000372)
,p_db_column_name=>'ROOM_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الغرفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000373)
,p_db_column_name=>'GUEST'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النزيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000374)
,p_db_column_name=>'PHONE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الجوال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000375)
,p_db_column_name=>'SINCE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الدخول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000376)
,p_db_column_name=>'DEP'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المغادرة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000377)
,p_db_column_name=>'NIGHTLY_RATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'سعر الليلة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000378)
,p_db_column_name=>'BALANCE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الرصيد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000379)
,p_db_column_name=>'DOC_NO'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحجز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000370)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'370'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ROOM_NO:GUEST:PHONE:SINCE:DEP:NIGHTLY_RATE:BALANCE:DOC_NO'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000380)
,p_plug_name=>'الوصول والمغادرة القادمة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select x.id, x.doc_no, noona_hsp_pkg.guest_name(x.guest_party_id) as guest, to_char(x.arrival_date, ''YYYY-MM-DD'') as arr,',
'       to_char(x.departure_date, ''YYYY-MM-DD'') as dep, noona_hsp_pkg.res_status_label(x.status_code) as status',
'  from hsp_reservation x where x.property_id = :P28_PROPERTY and :P28_REPORT = ''ARRIVALS''',
'   and x.status_code in (''TENTATIVE'', ''CONFIRMED'', ''GUARANTEED'', ''CHECKED_IN'')',
'   and (x.arrival_date between to_date(:P28_FROM, ''YYYY-MM-DD'') and to_date(:P28_TO, ''YYYY-MM-DD'') + 7',
'        or x.departure_date between to_date(:P28_FROM, ''YYYY-MM-DD'') and to_date(:P28_TO, ''YYYY-MM-DD'') + 7) order by x.arrival_date'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الوصول والمغادرة القادمة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000381)
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
,p_detail_link=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:RP,23:P23_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820273000000381
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000383)
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
 p_id=>wwv_flow_imp.id(91820273000000384)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الحجز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000385)
,p_db_column_name=>'GUEST'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النزيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000386)
,p_db_column_name=>'ARR'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الوصول'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000387)
,p_db_column_name=>'DEP'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المغادرة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000388)
,p_db_column_name=>'STATUS'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000382)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'382'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:GUEST:ARR:DEP:STATUS'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000389)
,p_plug_name=>'حسابات الشركات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select f.id, f.folio_no, noona_hsp_pkg.guest_name(f.payer_party_id) as company, noona_hsp_pkg.guest_name(x.guest_party_id) as guest,',
'       -(select sum(l.amount) from hsp_folio_line l where l.folio_id = f.id and l.line_type = ''TRANSFER'') as amount,',
'       to_char(f.updated_at, ''YYYY-MM-DD'') as d',
'  from hsp_folio f join hsp_reservation x on x.id = f.reservation_id',
' where x.property_id = :P28_PROPERTY and f.status_code = ''TRANSFERRED'' and :P28_REPORT = ''CITY'' order by f.updated_at desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'حسابات الشركات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000390)
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
,p_detail_link=>'f?p=&APP_ID.:24:&SESSION.::&DEBUG.:RP,24:P24_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820273000000390
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000392)
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
 p_id=>wwv_flow_imp.id(91820273000000393)
,p_db_column_name=>'FOLIO_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الحساب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000394)
,p_db_column_name=>'COMPANY'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الشركة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000395)
,p_db_column_name=>'GUEST'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النزيل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000396)
,p_db_column_name=>'AMOUNT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المبلغ المحول'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000397)
,p_db_column_name=>'D'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000391)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'391'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'FOLIO_NO:COMPANY:GUEST:AMOUNT:D'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000398)
,p_branch_action=>'f?p=&APP_ID.:28:&SESSION.::&DEBUG.:28:P28_PROPERTY,P28_REPORT,P28_FROM,P28_TO:&P28_PROPERTY.,&P28_REPORT.,&P28_FROM.,&P28_TO.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
