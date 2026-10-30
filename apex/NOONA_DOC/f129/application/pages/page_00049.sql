prompt --application/pages/page_00049
begin
--   Manifest
--     PAGE: 00049
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>49
,p_name=>'Document File'
,p_alias=>'DOCUMENT-FILE'
,p_step_title=>'ملف المستند'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000002)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000210)
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
 p_id=>wwv_flow_imp.id(91820267000000211)
,p_name=>'P49_DOC'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820267000000210)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000212)
,p_name=>'P49_VER'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820267000000210)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000213)
,p_name=>'P49_MODE'
,p_item_sequence=>3
,p_item_plug_id=>wwv_flow_imp.id(91820267000000210)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000214)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Download'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    noona_dms_pkg.download(:P49_DOC, :P49_VER, case :P49_MODE when ''D'' then ''DOWNLOAD'' else ''VIEW'' end);',
'    apex_application.stop_apex_engine;',
'exception',
'    when apex_application.e_stop_apex_engine then',
'        null;',
'    when others then',
'        if sqlerrm like ''%NOONA-%'' then',
'            owa_util.mime_header(''text/html'', true, ''UTF-8'');',
'            htp.p(''<!doctype html><html lang="ar" dir="rtl"><meta charset="utf-8"><body style="font:16px/1.8 Tahoma,sans-serif;color:#7a1f1f;background:#fff5f5;margin:0;padding:28px;text-align:center"><p style="font-size:40px;margin:0">&#9888;</p><p>''',
'                || apex_escape.html(regexp_replace(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+''), ''^NOONA-[A-Z]+-[0-9]+: | *\[cid=[^]]*\]'')) || ''</p></body></html>'');',
'            apex_application.stop_apex_engine;',
'        else',
'            raise;',
'        end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820267000000214
);

wwv_flow_imp.component_end;
end;
/
