prompt --application/pages/page_00012
begin
--   Manifest
--     PAGE: 00012
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>145
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>12
,p_name=>'Reports'
,p_alias=>'REPORTS'
,p_step_title=>'تقارير مركز الخدمة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000305)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000306)
,p_name=>'P12_KIND'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000305)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إجمالي العمليات (خدمات وقطع);SUMMARY,الخدمات المنفذة;SERVICES,مبيعات قطع الغيار;PARTS,أكثر الخدمات طلباً;TOP_SERVICES,أكثر القطع مبيعاً;TOP_PARTS,إنتاجية الفنيين وعمولاتهم;TECHNICIANS,مدة بقاء المركبات;STAY,مطالبات التأمين;INSURANCE,الحجوزات ونسبة الحضور;APPOINTMENTS,الخدمات والتجديدات المستحقة;DUE,حسب الشركة المصنعة;MAKES,أعلى المركبات إنفاقاً;VEHICLES'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000307)
,p_name=>'P12_PERIOD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000305)
,p_prompt=>'الفترة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مخصصة;CUSTOM,اليوم;TODAY,هذا الشهر;MONTH,الشهر السابق;LAST_MONTH,هذه السنة;YEAR'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000308)
,p_name=>'P12_FROM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000305)
,p_prompt=>'من'
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
 p_id=>wwv_flow_imp.id(91820280000000309)
,p_name=>'P12_TO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000305)
,p_prompt=>'إلى'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000310)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000305)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000311)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820280000000305)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000312)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P12_KIND := nvl(:P12_KIND, ''SUMMARY''); :P12_PERIOD := nvl(:P12_PERIOD, ''MONTH'');',
'    :P12_FROM := nvl(:P12_FROM, to_char(trunc(sysdate, ''MM''), ''YYYY-MM-DD'')); :P12_TO := nvl(:P12_TO, to_char(sysdate, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000312
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000313)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_aut_pkg.report_html(:P12_KIND, to_date(:P12_FROM, ''YYYY-MM-DD''), to_date(:P12_TO, ''YYYY-MM-DD''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000314)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Period'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    case :P12_PERIOD',
'        when ''TODAY'' then :P12_FROM := to_char(sysdate, ''YYYY-MM-DD''); :P12_TO := :P12_FROM;',
'        when ''MONTH'' then :P12_FROM := to_char(trunc(sysdate, ''MM''), ''YYYY-MM-DD''); :P12_TO := to_char(sysdate, ''YYYY-MM-DD'');',
'        when ''LAST_MONTH'' then :P12_FROM := to_char(add_months(trunc(sysdate, ''MM''), -1), ''YYYY-MM-DD'');',
'            :P12_TO := to_char(trunc(sysdate, ''MM'') - 1, ''YYYY-MM-DD'');',
'        when ''YEAR'' then :P12_FROM := to_char(trunc(sysdate, ''YYYY''), ''YYYY-MM-DD''); :P12_TO := to_char(sysdate, ''YYYY-MM-DD'');',
'        else null;',
'    end case;',
'    if :P12_KIND = ''DUE'' then :P12_TO := to_char(greatest(to_date(:P12_TO, ''YYYY-MM-DD''), sysdate + 30), ''YYYY-MM-DD''); end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST in (''P12_PERIOD'', ''P12_KIND'')'
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>91820280000000314
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000315)
,p_branch_action=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.::P12_KIND,P12_PERIOD,P12_FROM,P12_TO:&P12_KIND.,&P12_PERIOD.,&P12_FROM.,&P12_TO.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
