prompt --application/pages/page_00050
begin
--   Manifest
--     PAGE: 00050
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
 p_id=>50
,p_name=>'Reports'
,p_alias=>'REPORTS'
,p_step_title=>'تقارير التصنيع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () {',
'    // المرشحات الموحدة: يظهر لكل تقرير ما يخصه فقط',
'    var map = {"ORDERS": ["FROM", "TO", "STATUS"], "WIP": [], "VAR": ["FROM", "TO"], "USAGE": ["FROM", "TO"], "SUMMARY": ["FROM", "TO"], "UTIL": ["FROM", "TO"], "LOAD": ["FROM", "DAYS"], "TREE": ["ITEM", "QTY"], "USED": ["ITEM"], "MRP": [], "QC": ["FROM", "TO"]};',
'    var all = ["FROM", "TO", "STATUS", "ITEM", "QTY", "DAYS"];',
'    var sel = document.getElementById(''P50_REPORT'');',
'    function sync() { var on = map[sel.value] || [];',
'        all.forEach(function (k) { var c = document.getElementById(''P50_'' + k + ''_CONTAINER''); if (c) c.style.display = on.indexOf(k) >= 0 ? '''' : ''none''; }); }',
'    sel.addEventListener(''change'', function () { sync(); apex.submit(''RUN''); });',
'    sync();',
'})();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000186)
,p_plug_name=>'التقرير والمرشحات'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000187)
,p_name=>'P50_REPORT'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سجل أوامر الإنتاج;ORDERS,الإنتاج تحت التشغيل ومطابقته مع الأستاذ;WIP,انحرافات تكاليف الإنتاج;VAR,استهلاك الخامات;USAGE,ملخص الإنتاج حسب المنتج;SUMMARY,استغلال مراكز العمل وكفاءتها;UTIL,أحمال مراكز العمل;LOAD,شجرة قائمة المواد والتكلفة المجمعة;TREE,أين يستخدم الصنف;USED,تخطيط احتياجات المواد;MRP,فحوصات الجودة;QC'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000188)
,p_name=>'P50_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_prompt=>'من تاريخ'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000189)
,p_name=>'P50_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_prompt=>'إلى تاريخ'
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
 p_id=>wwv_flow_imp.id(91820270000000190)
,p_name=>'P50_STATUS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مخطط;PLANNED,معتمد;APPROVED,مطلق للتنفيذ;RELEASED,قيد التنفيذ;IN_PROGRESS,منجز جزئياً;PARTIALLY_COMPLETED,مكتمل;COMPLETED,مقفل;CLOSED,موقوف;ON_HOLD,ملغى;CANCELLED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل الحالات'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000191)
,p_name=>'P50_ITEM'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_prompt=>'الصنف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select item_no || '' - '' || name_ar d, id r from inv_item where status_code = ''ACTIVE'' and item_type not in (''SERVICE'', ''NON_STOCK'') order by item_no'
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
 p_id=>wwv_flow_imp.id(91820270000000192)
,p_name=>'P50_QTY'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_prompt=>'الكمية'
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
 p_id=>wwv_flow_imp.id(91820270000000193)
,p_name=>'P50_DAYS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_prompt=>'عدد الأيام'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000194)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000195)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820270000000186)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000196)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P50_REPORT := nvl(:P50_REPORT, ''ORDERS'');',
':P50_FROM := nvl(:P50_FROM, to_char(trunc(sysdate, ''MM''), ''YYYY-MM-DD''));',
':P50_TO := nvl(:P50_TO, to_char(sysdate, ''YYYY-MM-DD''));',
':P50_QTY := nvl(:P50_QTY, 1);',
':P50_DAYS := nvl(:P50_DAYS, 14);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000196
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000197)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_from date := to_date(:P50_FROM, ''YYYY-MM-DD'');',
'    l_to date := to_date(:P50_TO, ''YYYY-MM-DD'');',
'    l_mo varchar2(300) := ''f?p='' || :APP_ID || '':31:'' || :APP_SESSION || ''::NO:RP:P31_ID:#ID#'';',
'    l_none varchar2(200) := ''<div class="nn-empty">اختر الصنف</div>'';',
'begin',
'    return case :P50_REPORT',
'        when ''ORDERS'' then noona_mfg_pkg.orders_register(l_from, l_to, :P50_STATUS, l_mo)',
'        when ''WIP'' then noona_mfg_pkg.wip_report(l_mo)',
'        when ''VAR'' then noona_mfg_pkg.variance_report(l_from, l_to, l_mo)',
'        when ''USAGE'' then noona_mfg_pkg.material_usage(l_from, l_to)',
'        when ''SUMMARY'' then noona_mfg_pkg.production_summary(l_from, l_to)',
'        when ''UTIL'' then noona_mfg_pkg.wc_utilization(l_from, l_to)',
'        when ''LOAD'' then noona_mfg_pkg.capacity_load(l_from, :P50_DAYS)',
'        when ''TREE'' then case when :P50_ITEM is null then l_none else noona_mfg_pkg.bom_tree(:P50_ITEM, :P50_QTY) end',
'        when ''USED'' then case when :P50_ITEM is null then l_none else noona_mfg_pkg.where_used(:P50_ITEM) end',
'        when ''MRP'' then noona_mfg_pkg.mrp_report',
'        when ''QC'' then noona_mfg_pkg.quality_report(l_from, l_to)',
'    end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
