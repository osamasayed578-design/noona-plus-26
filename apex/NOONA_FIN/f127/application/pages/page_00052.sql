prompt --application/pages/page_00052
begin
--   Manifest
--     PAGE: 00052
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
 p_id=>52
,p_name=>'Consolidation Groups'
,p_alias=>'CONSOLIDATION-GROUPS'
,p_step_title=>'مجموعات التجميع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000975)
,p_plug_name=>'التجميع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div class="nn-hint">مجموعة التجميع تحدد الشركات التي تجمع قوائمها (مجموعة أعمال وما تحتها، أو كل شركات المؤسسة) وعملة التجميع. الحسابات المصنفة «بين الشركات» في دليل الحسابات، وأي حسابات تضيفها هنا، تستبعد بالكامل من الموحد. وإن حددت حساب الاستثمار في التابعات ونسب الملكية، يستبعد الاستثمار مقابل حقوق ملكية التابعات وتحسب الشهرة وحقوق الأقلية.</div>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000976)
,p_plug_name=>'مجموعات التجميع'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select g.id, g.code, g.name_ar, g.consolidation_currency, nvl((select name_ar from org_business_group b where b.id = g.business_group_id), ''كل شركات المؤسسة'') bg_name,',
'       noona_consol_pkg.elim_accounts(g.id) elim, noona_consol_pkg.invest_accounts(g.id) invest, noona_consol_pkg.ownership_text(g.id) own, (select max(period_code) from gl_consolidation_run r where r.group_id = g.id and r.status_code = ''APPROVED'') last_run',
'  from gl_consolidation_group g'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مجموعات التجميع'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000977)
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
,p_detail_link=>'f?p=&APP_ID.:53:&SESSION.::&DEBUG.:RP,53:P53_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820266000000977
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000979)
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
 p_id=>wwv_flow_imp.id(91820266000000980)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000981)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الاسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000982)
,p_db_column_name=>'CONSOLIDATION_CURRENCY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'العملة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000983)
,p_db_column_name=>'BG_NAME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'مجموعة الأعمال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000984)
,p_db_column_name=>'ELIM'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'حسابات استبعاد إضافية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000985)
,p_db_column_name=>'INVEST'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'حساب الاستثمار'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000986)
,p_db_column_name=>'OWN'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'نسب الملكية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000987)
,p_db_column_name=>'LAST_RUN'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'آخر فترة معتمدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000978)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'978'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:CONSOLIDATION_CURRENCY:BG_NAME:ELIM:INVEST:OWN:LAST_RUN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000988)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000976)
,p_button_name=>'CREATE'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مجموعة تجميع جديدة'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:53:&SESSION.::&DEBUG.:RP,53::'
);

wwv_flow_imp.component_end;
end;
/
