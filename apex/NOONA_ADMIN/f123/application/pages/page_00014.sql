prompt --application/pages/page_00014
begin
--   Manifest
--     PAGE: 00014
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>14
,p_name=>'Business Groups'
,p_alias=>'BUSINESS-GROUPS'
,p_step_title=>'مجموعات الأعمال (الشركات القابضة)'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000158)
,p_plug_name=>'ما هي مجموعة الأعمال؟'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div class="nn-hint">مجموعة الأعمال هي <b>الشركة القابضة</b> وما يتبعها من شركات. اربط كل شركة بمجموعتها من شاشة الشركة، ثم اختر عند تجهيز ماليتها: <b>دليل حسابات خاص بالشركة</b> (حساباتها على حدة) أو <b>دليل المجموعة الموحد</b> (كل الشركات على دليل واحد). القوائم الموحدة للمجموعة في المالية ← القوائم الموحدة.</div>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000159)
,p_plug_name=>'مجموعات الأعمال'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select g.id, g.code, g.name_ar, g.consolidation_currency, (select name_ar from org_business_group x where x.id = g.parent_group_id) parent_name,',
'       (select count(*) from org_company c where c.business_group_id = g.id) companies,',
'       (select listagg(nvl(c.trade_name_ar, c.legal_name_ar), ''، '') within group (order by c.code) from org_company c where c.business_group_id = g.id) company_names,',
'       noona_ui_pkg.status_badge(g.status_code) status_html',
'  from org_business_group g'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مجموعات الأعمال'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000160)
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
,p_internal_uid=>91820262000000160
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000162)
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
 p_id=>wwv_flow_imp.id(91820262000000163)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000164)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الاسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000165)
,p_db_column_name=>'CONSOLIDATION_CURRENCY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'عملة التجميع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000166)
,p_db_column_name=>'PARENT_NAME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المجموعة الأم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000167)
,p_db_column_name=>'COMPANIES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'عدد الشركات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000168)
,p_db_column_name=>'COMPANY_NAMES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الشركات'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000169)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000161)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'161'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:CONSOLIDATION_CURRENCY:PARENT_NAME:COMPANIES:COMPANY_NAMES:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000170)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000159)
,p_button_name=>'CREATE'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مجموعة جديدة'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:15:&SESSION.::&DEBUG.:RP,15::'
);

wwv_flow_imp.component_end;
end;
/
