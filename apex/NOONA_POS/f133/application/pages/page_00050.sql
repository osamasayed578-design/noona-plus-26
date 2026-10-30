prompt --application/pages/page_00050
begin
--   Manifest
--     PAGE: 00050
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>50
,p_name=>'Reports'
,p_alias=>'REPORTS'
,p_step_title=>'تقارير المبيعات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () {',
'    var map = {SREG: ["FROM", "TO", "CUST"], SITEM: ["FROM", "TO", "CAT"], POSR: ["FROM", "TO", "TERM"], CSTMT: ["CUST", "FROM", "TO"], AGING: ["ASOF"]};',
'    var all = ["FROM", "TO", "ASOF", "CUST", "CAT", "TERM"];',
'    var sel = document.getElementById(''P50_REPORT'');',
'    function sync() { var on = map[sel.value] || [];',
'        all.forEach(function (k) { var c = document.getElementById(''P50_'' + k + ''_CONTAINER''); if (c) c.style.display = on.indexOf(k) >= 0 ? '''' : ''none''; }); }',
'    sel.addEventListener(''change'', function () { sync(); apex.submit(''RUN''); });',
'    sync();',
'})();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000212)
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
 p_id=>wwv_flow_imp.id(91820269000000213)
,p_name=>'P50_REPORT'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820269000000212)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سجل المبيعات ومجمل الربح;SREG,المبيعات والربحية حسب الصنف;SITEM,مبيعات نقاط البيع والورديات;POSR,كشف حساب عميل;CSTMT,أعمار ديون العملاء;AGING'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000214)
,p_name=>'P50_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820269000000212)
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
 p_id=>wwv_flow_imp.id(91820269000000215)
,p_name=>'P50_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820269000000212)
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
 p_id=>wwv_flow_imp.id(91820269000000216)
,p_name=>'P50_ASOF'
,p_item_sequence=>25
,p_item_plug_id=>wwv_flow_imp.id(91820269000000212)
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
 p_id=>wwv_flow_imp.id(91820269000000217)
,p_name=>'P50_CUST'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820269000000212)
,p_prompt=>'العميل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select c.customer_no || '' - '' || p.display_name_ar d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id join pty_party p on p.id = c.party_id where a.company_id = noona_sal_pkg.company order by c.is_walk_in desc, p.display_name_ar'
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
 p_id=>wwv_flow_imp.id(91820269000000218)
,p_name=>'P50_CAT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820269000000212)
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
 p_id=>wwv_flow_imp.id(91820269000000219)
,p_name=>'P50_TERM'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820269000000212)
,p_prompt=>'نقطة البيع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from pos_terminal where company_id = noona_pos_pkg.company and status_code = ''ACTIVE'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل نقاط البيع'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000220)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000212)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000221)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820269000000212)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000222)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P50_REPORT := nvl(:P50_REPORT, ''SREG'');',
':P50_FROM := nvl(:P50_FROM, to_char(trunc(sysdate, ''MM''), ''YYYY-MM-DD''));',
':P50_TO := nvl(:P50_TO, to_char(sysdate, ''YYYY-MM-DD''));',
':P50_ASOF := nvl(:P50_ASOF, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000222
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000223)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_from date := to_date(:P50_FROM, ''YYYY-MM-DD'');',
'    l_to date := to_date(:P50_TO, ''YYYY-MM-DD'');',
'begin',
'    return case :P50_REPORT',
'        when ''SREG'' then noona_sal_pkg.sales_register(l_from, l_to, :P50_CUST, ''f?p='' || :APP_ID || '':21:'' || :APP_SESSION || ''::NO:RP:P21_ID:#ID#'')',
'        when ''SITEM'' then noona_sal_pkg.sales_by_item(l_from, l_to, :P50_CAT)',
'        when ''POSR'' then noona_pos_pkg.pos_sales_report(l_from, l_to, :P50_TERM)',
'        when ''CSTMT'' then noona_sal_pkg.customer_statement(:P50_CUST, l_from, l_to)',
'        when ''AGING'' then noona_sal_pkg.ar_aging(to_date(:P50_ASOF, ''YYYY-MM-DD''),',
'             ''f?p='' || :APP_ID || '':50:'' || :APP_SESSION || ''::NO::P50_REPORT,P50_CUST:CSTMT,#ID#'')',
'    end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
