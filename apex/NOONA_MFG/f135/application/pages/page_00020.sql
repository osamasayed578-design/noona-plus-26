prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>135
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>'Bills of Materials'
,p_alias=>'BOMS'
,p_step_title=>'قوائم المواد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000081)
,p_plug_name=>'قوائم المواد'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select b.id, noona_inv_pkg.item_label(b.item_id) as product, b.version_no, b.name_ar,',
'       decode(b.bom_type, ''PRODUCTION'', ''إنتاج'', ''PHANTOM'', ''وهمية'', ''KIT'', ''طقم'', ''ENGINEERING'', ''هندسية'', b.bom_type) as bom_type,',
'       b.base_quantity, (select count(*) from mfg_bom_line l where l.bom_id = b.id and l.is_co_product = ''N'') as components,',
'       case when b.status_code = ''PUBLISHED'' then noona_mfg_pkg.std_unit_cost(b.item_id) end as std_cost,',
'       case b.is_default when ''Y'' then ''★'' end as is_default, noona_mfg_pkg.bom_in_use(b.id) as in_use,',
'       ''<span class="nn-badge '' || case b.status_code when ''PUBLISHED'' then ''is-success'' when ''OBSOLETE'' then ''is-danger'' end || ''">''',
'            || noona_mfg_pkg.status_label(b.status_code) || ''</span>'' as status_html',
'  from mfg_bom b where b.company_id = noona_mfg_pkg.company order by b.code, b.version_no desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'قوائم المواد'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820270000000082)
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
,p_detail_link=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820270000000082
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000084)
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
 p_id=>wwv_flow_imp.id(91820270000000085)
,p_db_column_name=>'PRODUCT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المنتج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000086)
,p_db_column_name=>'VERSION_NO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الإصدار'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000087)
,p_db_column_name=>'NAME_AR'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الاسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000088)
,p_db_column_name=>'BOM_TYPE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000089)
,p_db_column_name=>'BASE_QUANTITY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الكمية المرجعية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000090)
,p_db_column_name=>'COMPONENTS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المكونات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000091)
,p_db_column_name=>'STD_COST'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'التكلفة المعيارية للوحدة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000092)
,p_db_column_name=>'IS_DEFAULT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الافتراضية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000093)
,p_db_column_name=>'IN_USE'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'مستخدمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000094)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820270000000083)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'83'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PRODUCT:VERSION_NO:NAME_AR:BOM_TYPE:BASE_QUANTITY:COMPONENTS:STD_COST:IS_DEFAULT:IN_USE:STATUS_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000095)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000081)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'قائمة مواد جديدة'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21::'
);

wwv_flow_imp.component_end;
end;
/
