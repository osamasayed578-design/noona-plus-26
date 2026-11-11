prompt --application/pages/page_00015
begin
--   Manifest
--     PAGE: 00015
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>131
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>15
,p_name=>'Costing Method'
,p_alias=>'COSTING-METHOD'
,p_step_title=>'طريقة تكلفة الأصناف (FIFO / المتوسط المرجح)'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000319)
,p_plug_name=>'طريقة التكلفة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint"><b>المتوسط المرجح</b> (الافتراضي): كل صرف بمتوسط تكلفة الرصيد. <b>FIFO - الوارد أولاً يصرف أولاً</b>: كل استلام طبقة بسعرها، والصرف (مبيعات، نقاط بيع، تصنيع، صيانة، إتلاف، مرتجع مشتريات) يستهلك الأقدم فالأحدث. عند التحول إلى FIFO يصبح الرصيد القائم أول طبقة بتكلفته الحالية. التحويل بين المستودعات لا يغير الطبقات. LIFO غير مسموح في المعايير الدولية (IAS 2).</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000320)
,p_name=>'P15_CAT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820268000000319)
,p_prompt=>'فئة كاملة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from inv_item_category order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820268000000321)
,p_name=>'P15_ITEM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820268000000319)
,p_prompt=>'أو صنف محدد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select item_no || '' - '' || name_ar d, id r from inv_item where item_type not in (''SERVICE'', ''NON_STOCK'') order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820268000000322)
,p_name=>'P15_METHOD'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820268000000319)
,p_prompt=>'الطريقة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:FIFO - الوارد أولاً يصرف أولاً;FIFO,المتوسط المرجح;WEIGHTED_AVERAGE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000323)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820268000000319)
,p_button_name=>'APPLY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تطبيق'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820268000000324)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Apply'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare n number; begin',
'  n := noona_inv_pkg.set_costing_method(to_number(:P15_ITEM), case when :P15_ITEM is null then to_number(:P15_CAT) end, :P15_METHOD);',
'  apex_application.g_print_success_message := ''تغيرت طريقة التكلفة لـ '' || n || '' صنف'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820268000000323)
,p_internal_uid=>91820268000000324
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000325)
,p_plug_name=>'أصناف FIFO'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select i.id, i.item_no, i.name_ar, cat.name_ar category, noona_inv_pkg.on_hand(i.id) on_hand, ic.average_cost,',
'       (select count(*) from inv_cost_layer l where l.item_id = i.id and l.company_id = c.company_id and l.status_code = ''OPEN'') layers',
'  from inv_item_company c join inv_item i on i.id = c.item_id left join inv_item_category cat on cat.id = i.category_id',
'  left join inv_item_cost ic on ic.item_id = i.id and ic.company_id = c.company_id and ic.warehouse_id is null',
' where c.company_id = noona_inv_pkg.company and c.costing_method = ''FIFO'' order by i.name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أصناف FIFO'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820268000000326)
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
,p_detail_link=>'f?p=&APP_ID.:15:&SESSION.::&DEBUG.::P15_SHOW:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820268000000326
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000328)
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
 p_id=>wwv_flow_imp.id(91820268000000329)
,p_db_column_name=>'ITEM_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'رقم الصنف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000330)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الصنف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000331)
,p_db_column_name=>'CATEGORY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000332)
,p_db_column_name=>'ON_HAND'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الرصيد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000333)
,p_db_column_name=>'AVERAGE_COST'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'متوسط الطبقات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000334)
,p_db_column_name=>'LAYERS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الطبقات المفتوحة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820268000000327)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'327'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ITEM_NO:NAME_AR:CATEGORY:ON_HAND:AVERAGE_COST:LAYERS'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000335)
,p_name=>'P15_SHOW'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820268000000319)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000336)
,p_plug_name=>'طبقات FIFO للصنف المختار'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P15_SHOW is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_inv_pkg.fifo_layers_html(to_number(:P15_SHOW));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
