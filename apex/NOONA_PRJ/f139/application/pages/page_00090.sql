prompt --application/pages/page_00090
begin
--   Manifest
--     PAGE: 00090
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
 p_id=>90
,p_name=>'Project Reports'
,p_alias=>'PROJECT-REPORTS'
,p_step_title=>'تقارير المشروعات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () {',
'    var map = {"PORTFOLIO": ["STATUS"], "CLAIMS": ["FROM", "TO", "DIR"], "RETENTION": [], "COSTS": ["FROM", "TO", "PROJECT"], "UNITS": ["PROJECT", "BASIS"]}, all = [''FROM'', ''TO'', ''DIR'', ''STATUS'', ''PROJECT'', ''BASIS''];',
'    var on = map[$v(''P90_REPORT'')] || [];',
'    all.forEach(function (k) { var c = document.getElementById(''P90_'' + k + ''_CONTAINER''); if (c) c.style.display = on.indexOf(k) >= 0 ? '''' : ''none''; });',
'})();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000737)
,p_plug_name=>'التقرير والمرشحات'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000738)
,p_name=>'P90_REPORT'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820273000000737)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:محفظة المشروعات والربحية;PORTFOLIO,سجل المستخلصات;CLAIMS,المحتجزات والدفعات المقدمة;RETENTION,تكاليف المشروعات حسب النوع;COSTS,توزيع تكلفة التطوير على الوحدات;UNITS'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000739)
,p_name=>'P90_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000737)
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
 p_id=>wwv_flow_imp.id(91820273000000740)
,p_name=>'P90_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000737)
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
 p_id=>wwv_flow_imp.id(91820273000000741)
,p_name=>'P90_DIR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000737)
,p_prompt=>'الاتجاه'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مستخلصات العملاء;RECEIVABLE,مستخلصات مقاولي الباطن;PAYABLE'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'الكل'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000742)
,p_name=>'P90_STATUS'
,p_item_sequence=>35
,p_item_plug_id=>wwv_flow_imp.id(91820273000000737)
,p_prompt=>'حالة المشروع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مخطط;PLANNED,معتمد;APPROVED,قيد التنفيذ;ACTIVE,متوقف مؤقتاً;ON_HOLD,منجز;COMPLETED,مغلق;CLOSED,ملغى;CANCELLED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل الحالات القائمة'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000743)
,p_name=>'P90_PROJECT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000737)
,p_prompt=>'المشروع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from prj_project where company_id = noona_prj_pkg.company order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل المشروعات'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000744)
,p_name=>'P90_BASIS'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000737)
,p_prompt=>'أساس التوزيع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المساحة;AREA,سعر البيع;SALE_VALUE,عدد الوحدات;UNIT_COUNT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000745)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000737)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000746)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000737)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000747)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P90_REPORT := nvl(:P90_REPORT, ''PORTFOLIO''); :P90_BASIS := nvl(:P90_BASIS, ''AREA'');',
':P90_FROM := nvl(:P90_FROM, to_char(trunc(sysdate, ''YYYY''), ''YYYY-MM-DD''));',
':P90_TO := nvl(:P90_TO, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000747
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000748)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_f date := to_date(:P90_FROM, ''YYYY-MM-DD''); l_t date := to_date(:P90_TO, ''YYYY-MM-DD'');',
'begin',
'    return case :P90_REPORT',
'        when ''CLAIMS'' then noona_prj_pkg.claims_register_html(l_f, l_t, :P90_DIR)',
'        when ''RETENTION'' then noona_prj_pkg.retention_html',
'        when ''COSTS'' then noona_prj_pkg.cost_report_html(l_f, l_t, :P90_PROJECT)',
'        when ''UNITS'' then case when :P90_PROJECT is null then ''<div class="nn-empty">اختر مشروع التطوير العقاري</div>''',
'                             else noona_prj_pkg.unit_costs_html(:P90_PROJECT, :P90_BASIS) end',
'        else noona_prj_pkg.portfolio_html(:P90_STATUS, ''f?p='' || :APP_ID || '':81:'' || :APP_SESSION || ''::NO:RP,81:P81_ID:#ID#'') end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
