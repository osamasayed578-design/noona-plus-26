prompt --application/pages/page_00050
begin
--   Manifest
--     PAGE: 00050
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
 p_id=>50
,p_name=>'Reports'
,p_alias=>'REPORTS'
,p_step_title=>'تقارير سلسلة الإمداد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () {',
'    // المرشحات الموحدة: يظهر لكل تقرير ما يخصه فقط',
'    var map = {STOCK: ["WH", "CAT", "ZERO"], CARD: ["ITEM", "FROM", "TO", "WH"], EXPIRY: ["DAYS", "WH"], REORDER: [], FIT: ["MAKE", "MODEL", "YEAR", "WH"], PREG: ["FROM", "TO", "SUP"], PITEM: ["FROM", "TO", "CAT"], SSTMT: ["SUP", "FROM", "TO"], AGING: ["ASOF"]};',
'    var all = ["FROM", "TO", "ASOF", "WH", "CAT", "ITEM", "SUP", "DAYS", "MAKE", "MODEL", "YEAR", "ZERO"];',
'    var sel = document.getElementById(''P50_REPORT'');',
'    function sync() { var on = map[sel.value] || [];',
'        all.forEach(function (k) { var c = document.getElementById(''P50_'' + k + ''_CONTAINER''); if (c) c.style.display = on.indexOf(k) >= 0 ? '''' : ''none''; }); }',
'    sel.addEventListener(''change'', function () { sync(); apex.submit(''RUN''); });',
'    sync();',
'})();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000301)
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
 p_id=>wwv_flow_imp.id(91820268000000302)
,p_name=>'P50_REPORT'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:أرصدة المخزون وقيمته;STOCK,بطاقة صنف (حركة تفصيلية);CARD,الدفعات المنتهية والقريبة الانتهاء;EXPIRY,الأصناف تحت حد الطلب;REORDER,بحث قطع الغيار بالمركبة;FIT,سجل المشتريات;PREG,المشتريات حسب الصنف;PITEM,كشف حساب مورد;SSTMT,أعمار ديون الموردين;AGING'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000303)
,p_name=>'P50_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
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
 p_id=>wwv_flow_imp.id(91820268000000304)
,p_name=>'P50_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
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
 p_id=>wwv_flow_imp.id(91820268000000305)
,p_name=>'P50_ASOF'
,p_item_sequence=>25
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'في تاريخ'
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
 p_id=>wwv_flow_imp.id(91820268000000306)
,p_name=>'P50_WH'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'المستودع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from inv_warehouse where company_id = noona_inv_pkg.company and status_code = ''ACTIVE'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل المستودعات'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000307)
,p_name=>'P50_CAT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'الفئة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from inv_item_category where is_active = ''Y'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل الفئات'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000308)
,p_name=>'P50_ITEM'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'الصنف (رقم / كود / باركود)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>60
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000309)
,p_name=>'P50_SUP'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'المورد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select s.supplier_no || '' - '' || p.display_name_ar d, a.id r from ap_supplier_account a join ap_supplier s on s.id = a.supplier_id join pty_party p on p.id = s.party_id where a.company_id = noona_pur_pkg.company order by p.display_name_ar'
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
 p_id=>wwv_flow_imp.id(91820268000000310)
,p_name=>'P50_DAYS'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'خلال (يوم)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000311)
,p_name=>'P50_MAKE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'شركة المركبة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>60
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
 p_id=>wwv_flow_imp.id(91820268000000312)
,p_name=>'P50_MODEL'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'الطراز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>60
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000313)
,p_name=>'P50_YEAR'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'سنة الصنع'
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
 p_id=>wwv_flow_imp.id(91820268000000314)
,p_name=>'P50_ZERO'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_prompt=>'إظهار الأرصدة الصفرية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000315)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820268000000316)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820268000000301)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820268000000317)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P50_REPORT := nvl(:P50_REPORT, ''STOCK'');',
':P50_FROM := nvl(:P50_FROM, to_char(trunc(sysdate, ''YYYY''), ''YYYY-MM-DD''));',
':P50_TO := nvl(:P50_TO, to_char(sysdate, ''YYYY-MM-DD''));',
':P50_ASOF := nvl(:P50_ASOF, to_char(sysdate, ''YYYY-MM-DD''));',
':P50_DAYS := nvl(:P50_DAYS, 90);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820268000000317
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000318)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_from date := to_date(:P50_FROM, ''YYYY-MM-DD'');',
'    l_to date := to_date(:P50_TO, ''YYYY-MM-DD'');',
'    l_card varchar2(300) := ''f?p='' || :APP_ID || '':50:'' || :APP_SESSION || ''::NO::P50_REPORT,P50_ITEM:CARD,'';',
'begin',
'    return case :P50_REPORT',
'        when ''STOCK'' then noona_inv_pkg.stock_balance(:P50_WH, :P50_CAT, nvl(:P50_ZERO, ''N''),',
'             ''f?p='' || :APP_ID || '':11:'' || :APP_SESSION || ''::NO:RP:P11_ID:#ID#'')',
'        when ''CARD'' then case when :P50_ITEM is null then ''<div class="nn-empty">أدخل رقم الصنف أو الباركود</div>''',
'             else noona_inv_pkg.item_card(noona_inv_pkg.item_by_barcode(:P50_ITEM), l_from, l_to, :P50_WH) end',
'        when ''EXPIRY'' then noona_inv_pkg.expiry_report(:P50_DAYS, :P50_WH)',
'        when ''REORDER'' then noona_inv_pkg.reorder_report',
'        when ''FIT'' then noona_inv_pkg.fitment_search(:P50_MAKE, :P50_MODEL, :P50_YEAR, :P50_WH)',
'        when ''PREG'' then noona_pur_pkg.purchase_register(l_from, l_to, :P50_SUP, ''f?p='' || :APP_ID || '':35:'' || :APP_SESSION || ''::NO:RP:P35_ID:#ID#'')',
'        when ''PITEM'' then noona_pur_pkg.purchases_by_item(l_from, l_to, :P50_CAT)',
'        when ''SSTMT'' then noona_pur_pkg.supplier_statement(:P50_SUP, l_from, l_to)',
'        when ''AGING'' then noona_pur_pkg.ap_aging(to_date(:P50_ASOF, ''YYYY-MM-DD''),',
'             ''f?p='' || :APP_ID || '':50:'' || :APP_SESSION || ''::NO::P50_REPORT,P50_SUP:SSTMT,#ID#'')',
'    end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
