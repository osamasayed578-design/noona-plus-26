prompt --application/pages/page_00014
begin
--   Manifest
--     PAGE: 00014
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>14
,p_name=>'Shops'
,p_alias=>'SHOPS'
,p_step_title=>'المحلات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000194)
,p_plug_name=>'محل جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000195)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000194)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'محل جديد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:15:&SESSION.::&DEBUG.:RP,15::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000196)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820300000000194)
,p_button_name=>'MAP'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'الخريطة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:16:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000197)
,p_plug_name=>'المحلات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, noona_sal_pkg.customer_label(s.customer_account_id) shop, noona_dst_pkg.label(s.shop_type) shop_type, s.owner_name, s.phone,',
'       r.name_ar route, s.route_seq, nvl(s.visit_days, r.visit_days) days, s.landmark,',
'       case when s.latitude is not null then ''نعم'' else ''لا'' end located, s.last_visit_at, s.last_sale_at,',
'       noona_sal_pkg.customer_balance(s.customer_account_id) balance, noona_sal_pkg.credit_limit(s.customer_account_id) credit_limit,',
'       noona_dst_pkg.badge(s.status_code) status_html',
'  from dst_shop s left join dst_route r on r.id = s.route_id',
' where s.company_id = noona_dst_pkg.company order by r.code, s.route_seq nulls last, s.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'المحلات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820300000000198)
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
,p_detail_link=>'f?p=&APP_ID.:15:&SESSION.::&DEBUG.:RP,15:P15_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820300000000198
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000200)
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
 p_id=>wwv_flow_imp.id(91820300000000201)
,p_db_column_name=>'SHOP'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المحل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000202)
,p_db_column_name=>'SHOP_TYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000203)
,p_db_column_name=>'OWNER_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'صاحب المحل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000204)
,p_db_column_name=>'PHONE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الجوال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000205)
,p_db_column_name=>'ROUTE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'خط السير'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000206)
,p_db_column_name=>'ROUTE_SEQ'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الترتيب'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000207)
,p_db_column_name=>'DAYS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'أيام الزيارة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000208)
,p_db_column_name=>'LANDMARK'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'علامة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000209)
,p_db_column_name=>'LOCATED'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'بموقع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000210)
,p_db_column_name=>'LAST_VISIT_AT'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'آخر زيارة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000211)
,p_db_column_name=>'LAST_SALE_AT'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'آخر شراء'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000212)
,p_db_column_name=>'BALANCE'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الرصيد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000213)
,p_db_column_name=>'CREDIT_LIMIT'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'حد الائتمان'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820300000000214)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820300000000199)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'199'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'SHOP:SHOP_TYPE:OWNER_NAME:PHONE:ROUTE:ROUTE_SEQ:DAYS:LANDMARK:LOCATED:LAST_VISIT_AT:LAST_SALE_AT:BALANCE:CREDIT_LIMIT:STATUS_HTML'
);

wwv_flow_imp.component_end;
end;
/
