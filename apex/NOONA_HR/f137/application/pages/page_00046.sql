prompt --application/pages/page_00046
begin
--   Manifest
--     PAGE: 00046
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>137
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>46
,p_name=>'WPS File'
,p_alias=>'WPS-FILE'
,p_step_title=>'ملف التحويل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000292)
,p_plug_name=>'الملف'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000293)
,p_name=>'P46_RUN'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820272000000292)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000294)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Download'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c   clob;',
'    l_off pls_integer := 1;',
'begin',
'    l_c := noona_pay_pkg.bank_file_csv(noona_pay_pkg.run_file(:P46_RUN));',
'    owa_util.mime_header(''text/csv'', false, ''UTF-8'');',
'    htp.p(''Content-Disposition: attachment; filename="WPS-'' || :P46_RUN || ''.csv"'');',
'    owa_util.http_header_close;',
'    htp.prn(unistr(''\FEFF''));',
'    while l_off <= dbms_lob.getlength(l_c) loop',
'        htp.prn(dbms_lob.substr(l_c, 8000, l_off));',
'        l_off := l_off + 8000;',
'    end loop;',
'    apex_application.stop_apex_engine;',
'exception',
'    when apex_application.e_stop_apex_engine then',
'        null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820272000000294
);

wwv_flow_imp.component_end;
end;
/
