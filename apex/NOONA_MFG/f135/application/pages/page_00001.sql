prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
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
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'التصنيع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000009)
,p_plug_name=>'تجهيز التصنيع'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_mfg_pkg.is_ready = ''N'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000010)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000009)
,p_button_name=>'SETUP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز التصنيع (حسابات الإنتاج تحت التشغيل والتحميل والانحرافات، الترقيم، مركز عمل افتراضي)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000011)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setup'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_mfg_pkg.quick_setup;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820270000000010)
,p_process_success_message=>'تم تجهيز التصنيع: الحسابات 1110 الإنتاج تحت التشغيل، 5103 العمالة المحملة، 5104 الأعباء المحملة، 5105 الانحرافات، وترقيم أوامر الإنتاج'
,p_internal_uid=>91820270000000011
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000012)
,p_plug_name=>'مؤشرات الإنتاج'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_mfg_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_mfg_pkg.mfg_summary;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000013)
,p_plug_name=>'إجراءات سريعة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_mfg_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000014)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000013)
,p_button_name=>'NEW_MO'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'أمر إنتاج جديد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000015)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820270000000013)
,p_button_name=>'NEW_BOM'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'قائمة مواد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000016)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820270000000013)
,p_button_name=>'NEW_RT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'مسار تصنيع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:RP,23::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000017)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820270000000013)
,p_button_name=>'MRP'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تخطيط الاحتياجات'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000018)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820270000000013)
,p_button_name=>'CAP'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'أحمال مراكز العمل'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000019)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820270000000013)
,p_button_name=>'REPORTS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'التقارير'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000020)
,p_plug_name=>'الأوامر المفتوحة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.id, o.doc_no, to_char(o.doc_date, ''YYYY-MM-DD'') as doc_date, noona_inv_pkg.item_label(o.item_id) as product,',
'       o.planned_qty, o.completed_qty, o.scrapped_qty, noona_mfg_pkg.order_progress(o.id) as progress,',
'       to_char(o.planned_start, ''YYYY-MM-DD'') as p_start, to_char(o.planned_end, ''YYYY-MM-DD'') as p_end,',
'       noona_mfg_pkg.priority_label(o.priority) as priority, o.estimated_cost, o.actual_cost,',
'       noona_mfg_pkg.wip_balance(o.id) as wip,',
'       ''<span class="nn-badge '' || case when o.status_code in (''COMPLETED'', ''CLOSED'') then ''is-success'' when o.status_code = ''CANCELLED'' then ''is-danger''',
'            when o.status_code = ''ON_HOLD'' or (o.planned_end < trunc(sysdate) and o.status_code not in (''COMPLETED'', ''CLOSED'')) then ''is-warning''',
'            when o.status_code in (''RELEASED'', ''IN_PROGRESS'', ''PARTIALLY_COMPLETED'') then ''is-info'' end || ''">''',
'            || noona_mfg_pkg.status_label(o.status_code) || ''</span>'' as status_html',
'  from mfg_production_order o where o.company_id = noona_mfg_pkg.company',
'   and o.status_code in (''PLANNED'', ''APPROVED'', ''RELEASED'', ''IN_PROGRESS'', ''PARTIALLY_COMPLETED'', ''ON_HOLD'', ''COMPLETED'')',
' order by decode(o.priority, ''URGENT'', 0, ''HIGH'', 1, ''NORMAL'', 2, 3), o.planned_end nulls last, o.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الأوامر المفتوحة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820270000000021)
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
,p_detail_link=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820270000000021
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000023)
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
 p_id=>wwv_flow_imp.id(91820270000000024)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'رقم الأمر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000025)
,p_db_column_name=>'DOC_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000026)
,p_db_column_name=>'PRODUCT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المنتج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000027)
,p_db_column_name=>'PLANNED_QTY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المخطط'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000028)
,p_db_column_name=>'COMPLETED_QTY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المقبول'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000029)
,p_db_column_name=>'SCRAPPED_QTY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الهالك'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000030)
,p_db_column_name=>'PROGRESS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الإنجاز %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000031)
,p_db_column_name=>'P_START'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'البداية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000032)
,p_db_column_name=>'P_END'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'النهاية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000033)
,p_db_column_name=>'PRIORITY'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الأولوية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000034)
,p_db_column_name=>'ESTIMATED_COST'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'التقديرية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000035)
,p_db_column_name=>'ACTUAL_COST'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الفعلية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000036)
,p_db_column_name=>'WIP'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'تحت التشغيل'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000037)
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
 p_id=>wwv_flow_imp.id(91820270000000022)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'22'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DOC_DATE:PRODUCT:PLANNED_QTY:COMPLETED_QTY:SCRAPPED_QTY:PROGRESS:P_START:P_END:PRIORITY:ESTIMATED_COST:ACTUAL_COST:WIP:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000038)
,p_plug_name=>'بانتظار فحص الجودة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.order_id as id, o.doc_no, noona_inv_pkg.item_label(o.item_id) as product, t.quantity, t.lot_no,',
'       to_char(t.output_date, ''YYYY-MM-DD'') as output_date',
'  from mfg_order_output t join mfg_production_order o on o.id = t.order_id',
' where t.company_id = noona_mfg_pkg.company and t.status_code = ''PENDING_QUALITY'' order by t.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'بانتظار فحص الجودة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820270000000039)
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
,p_detail_link=>'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820270000000039
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000041)
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
 p_id=>wwv_flow_imp.id(91820270000000042)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'أمر الإنتاج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000043)
,p_db_column_name=>'PRODUCT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المنتج'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000044)
,p_db_column_name=>'QUANTITY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000045)
,p_db_column_name=>'LOT_NO'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الدفعة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820270000000046)
,p_db_column_name=>'OUTPUT_DATE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820270000000040)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'40'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:PRODUCT:QUANTITY:LOT_NO:OUTPUT_DATE'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820270000000047)
,p_branch_action=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
