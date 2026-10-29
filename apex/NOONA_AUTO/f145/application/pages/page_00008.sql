prompt --application/pages/page_00008
begin
--   Manifest
--     PAGE: 00008
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
 p_id=>8
,p_name=>'Insurance Claims'
,p_alias=>'CLAIMS'
,p_step_title=>'مطالبات التأمين'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''aut.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000163)
,p_plug_name=>'تصفية'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000164)
,p_name=>'P8_INSURER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000163)
,p_prompt=>'شركة التأمين'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from aut_insurer where company_id = noona_aut_pkg.company and status_code = ''ACTIVE'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل الشركات'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000165)
,p_name=>'P8_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000163)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المفتوحة;OPEN,لم تقدم;NOT_SUBMITTED,مقدمة;SUBMITTED,معتمدة;APPROVED,معتمدة جزئياً;PARTIALLY_APPROVED,مرفوضة;REJECTED,مدفوعة;PAID'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل الحالات'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000166)
,p_plug_name=>'المطالبات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_aut_pkg.claims_html(to_number(:P8_INSURER), :P8_STATUS);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000167)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'AUT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c  clob;',
'    l_h  clob;',
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
'        when ''JOB'' then l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''ADDSVC'' then l_id := noona_aut_pkg.add_service(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''ADDPART'' then l_id := noona_aut_pkg.add_part(n(apex_application.g_x02), n(apex_application.g_x03), n(apex_application.g_x04));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''ADDLINE'' then l_id := noona_aut_pkg.add_line(apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''UPDLINE'' then noona_aut_pkg.update_line(apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''DELLINE'' then noona_aut_pkg.remove_line(n(apex_application.g_x02));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x03));',
'        when ''LACT'' then noona_aut_pkg.line_action(n(apex_application.g_x02), apex_application.g_x03);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x04));',
'        when ''STATUS'' then noona_aut_pkg.set_job_status(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''UPDJOB'' then noona_aut_pkg.update_job(apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(json_value(apex_application.g_clob_01, ''$.id'' returning number));',
'        when ''CLAIM'' then noona_aut_pkg.set_claim(apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(json_value(apex_application.g_clob_01, ''$.job'' returning number));',
'        when ''INVOICE'' then l_id := noona_aut_pkg.invoice_job(n(apex_application.g_x02), apex_application.g_clob_01);',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''DELIVER'' then noona_aut_pkg.deliver_job(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));',
'        when ''PARTS'' then l_c := ''{"list":'' || noona_aut_pkg.search_parts_json(apex_application.g_x02, n(apex_application.g_x03)) || ''}'';',
'        when ''APPT'' then noona_aut_pkg.set_appointment_status(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04);',
'        when ''CHECKIN'' then l_id := noona_aut_pkg.check_in(n(apex_application.g_x02), apex_application.g_clob_01);',
'            l_c := ''{"id":'' || l_id || ''}'';',
'        when ''PRINT'' then l_h := noona_aut_pkg.job_print(n(apex_application.g_x02));',
'            select json_object(''html'' value l_h returning clob) into l_c from dual;',
'        else raise_application_error(-20500, ''NOONA-AUT-099: عملية غير معروفة '' || l_op);',
'    end case;',
'    out(nvl(l_c, to_clob(''{"ok":true}'')));',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''err'', regexp_replace(nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm),',
'                                          ''\s*\[cid=[^]]+\]'', ''''));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000167
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000168)
,p_branch_action=>'f?p=&APP_ID.:8:&SESSION.::&DEBUG.::P8_INSURER,P8_STATUS:&P8_INSURER.,&P8_STATUS.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
