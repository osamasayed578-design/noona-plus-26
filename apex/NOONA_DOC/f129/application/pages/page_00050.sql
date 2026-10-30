prompt --application/pages/page_00050
begin
--   Manifest
--     PAGE: 00050
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
 p_id=>50
,p_name=>'Correspondence'
,p_alias=>'MAIL'
,p_step_title=>'المراسلات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''mail.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000215)
,p_plug_name=>'المراسلات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    return ''<div id="nnMail" class="nn-mail" data-open="'' || apex_escape.html_attribute(:P50_OPEN)',
'        || ''" data-file="'' || apex_escape.html_attribute(apex_page.get_url(p_page => 51, p_items => ''P51_MSG,P51_DOC,P51_MODE'',',
'                                                                    p_values => ''990000000001,990000000002,V'')) || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000216)
,p_plug_name=>'فتح'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000217)
,p_name=>'P50_OPEN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000216)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000218)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'MAIL'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c  clob;',
'    l_id number;',
'    l_op varchar2(30) := apex_application.g_x01;',
'    function n(p varchar2) return number is begin return to_number(p); end;',
'    procedure out(p clob) is',
'        l_off pls_integer := 1;',
'    begin',
'        while l_off <= dbms_lob.getlength(p) loop',
'            htp.prn(dbms_lob.substr(p, 8000, l_off));',
'            l_off := l_off + 8000;',
'        end loop;',
'    end;',
'begin',
'    case l_op',
'        when ''META'' then l_c := noona_cor_pkg.meta_json;',
'        when ''FOLDERS'' then l_c := noona_cor_pkg.folders_json;',
'        when ''LIST'' then l_c := noona_cor_pkg.list_json(apex_application.g_x02, apex_application.g_x03, n(apex_application.g_x04));',
'        when ''THREAD'' then l_c := noona_cor_pkg.thread_json(n(apex_application.g_x02));',
'        when ''DIR'' then l_c := noona_cor_pkg.directory_json(apex_application.g_x02);',
'        when ''PARTY'' then l_c := noona_cor_pkg.parties_json(apex_application.g_x02);',
'        when ''DRAFT'' then l_c := noona_cor_pkg.draft_json(n(apex_application.g_x02));',
'        when ''DRAFTSEED'' then l_c := noona_cor_pkg.reply_seed_json(n(apex_application.g_x02), apex_application.g_x03);',
'        when ''SAVE'' then l_id := noona_cor_pkg.save_draft(apex_application.g_clob_01); l_c := ''{"id":'' || l_id || ''}'';',
'        when ''SEND'' then l_id := noona_cor_pkg.send(apex_application.g_clob_01); l_c := ''{"id":'' || l_id || ''}'';',
'        when ''DELDRAFT'' then noona_cor_pkg.delete_draft(n(apex_application.g_x02));',
'        when ''ATTACH'' then',
'            l_id := noona_cor_pkg.attach(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04,',
'                                         apex_web_service.clobbase642blob(apex_application.g_clob_01));',
'            l_c := ''{"doc":'' || l_id || ''}'';',
'        when ''UNATTACH'' then noona_cor_pkg.remove_attachment(n(apex_application.g_x02), n(apex_application.g_x03));',
'        when ''STAR'' then noona_cor_pkg.set_star(n(apex_application.g_x02), apex_application.g_x03);',
'        when ''ARCHIVE'' then noona_cor_pkg.archive_thread(n(apex_application.g_x02));',
'        when ''RESTORE'' then noona_cor_pkg.restore_thread(n(apex_application.g_x02));',
'        when ''UNREAD'' then noona_cor_pkg.mark_unread(n(apex_application.g_x02));',
'        when ''ACK'' then noona_cor_pkg.acknowledge(n(apex_application.g_x02));',
'        when ''DONE'' then noona_cor_pkg.complete(n(apex_application.g_x02), apex_application.g_x03);',
'        when ''REFER'' then noona_cor_pkg.refer(n(apex_application.g_x02), n(apex_application.g_x03), apex_application.g_x04,',
'                                               to_date(apex_application.g_x05, ''YYYY-MM-DD''), apex_application.g_x06);',
'        when ''LETTER'' then l_c := noona_cor_pkg.letter_html(n(apex_application.g_x02));',
'        else raise_application_error(-20500, ''NOONA-COR-099: عملية غير معروفة '' || l_op);',
'    end case;',
'    out(nvl(l_c, to_clob(''{"ok":true}'')));',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''error'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820267000000218
);

wwv_flow_imp.component_end;
end;
/
