prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
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
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'مركز خدمة السيارات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''aut.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000011)
,p_plug_name=>'تجهيز مركز الخدمة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">ينشئ حساب إيرادات خدمات الصيانة (4160) ورافعتين افتراضيتين وترقيم أوامر الإصلاح والحجوزات. أضف بعدها فئات الخدمات والخدمات (الكروت) والفنيين من الإعداد. مرة واحدة لكل شركة.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_aut_pkg.is_ready = ''N'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000012)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000011)
,p_button_name=>'SETUP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز مركز الخدمة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000013)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setup'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_aut_pkg.quick_setup;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000012)
,p_process_success_message=>'تم التجهيز: حساب الإيرادات والرافعات والترقيم'
,p_internal_uid=>91820280000000013
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000014)
,p_plug_name=>'المؤشرات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_aut_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_aut_pkg.summary_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000015)
,p_plug_name=>'إجراءات سريعة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_aut_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000016)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000015)
,p_button_name=>'CHECKIN'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'استلام سيارة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:RP,2::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000017)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820280000000015)
,p_button_name=>'BOOK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'الحجوزات'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:5:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000018)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820280000000015)
,p_button_name=>'JOBS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'أوامر الإصلاح'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:4:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000019)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820280000000015)
,p_button_name=>'VEH'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'المركبات'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:6:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000020)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820280000000015)
,p_button_name=>'CLAIMS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'مطالبات التأمين'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:8:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000021)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820280000000015)
,p_button_name=>'RPT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'التقارير'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000022)
,p_plug_name=>'السيارات في الورشة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_aut_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_aut_pkg.board_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000023)
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
'        when ''ADDBND'' then l_id := noona_aut_pkg.add_bundle(n(apex_application.g_x02), n(apex_application.g_x03));',
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
,p_internal_uid=>91820280000000023
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000024)
,p_branch_action=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
