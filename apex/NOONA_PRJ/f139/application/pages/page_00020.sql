prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
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
 p_id=>20
,p_name=>'Front Desk'
,p_alias=>'FRONT-DESK'
,p_step_title=>'لوحة الاستقبال'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000010)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''frontdesk.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000166)
,p_plug_name=>'الفندق'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000167)
,p_name=>'P20_PROPERTY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000166)
,p_prompt=>'الفندق / العقار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from re_property p where p.company_id = noona_hsp_pkg.company and p.status_code <> ''INACTIVE'' and exists (select 1 from hsp_room r where r.property_id = p.id) order by p.code'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000168)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P20_PROPERTY := nvl(:P20_PROPERTY, noona_hsp_pkg.default_property);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000168
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000169)
,p_plug_name=>'المؤشرات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>8
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_PROPERTY is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div id="nnFdKpi">'' || noona_hsp_pkg.front_summary(:P20_PROPERTY) || ''</div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000170)
,p_plug_name=>'لوحة الاستقبال'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_PROPERTY is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    return ''<div id="nnFd" class="nn-fd" data-mode="rack" data-property="'' || :P20_PROPERTY',
'        || ''" data-folio="'' || apex_escape.html_attribute(replace(apex_page.get_url(p_page => 24, p_items => ''P24_ID'', p_values => ''990000000001''), ''990000000001'', ''990000000001''))',
'        || ''" data-res="'' || apex_escape.html_attribute(apex_page.get_url(p_page => 22, p_clear_cache => ''22'',',
'               p_items => ''P22_PROPERTY,P22_ROOM'', p_values => :P20_PROPERTY || '',990000000001'')) || ''"''',
'        || '' data-req="'' || apex_escape.html_attribute(apex_page.get_url(p_page => 71, p_clear_cache => ''71'',',
'               p_items => ''P71_NEW_ROOM'', p_values => ''990000000001'')) || ''"''',
'        || '' data-resv="'' || apex_escape.html_attribute(replace(apex_page.get_url(p_page => 23, p_items => ''P23_ID'', p_values => ''990000000001''), ''990000000001'', ''990000000001'')) || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000171)
,p_plug_name=>'لا يوجد فندق'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>12
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">لا توجد غرف فندقية بعد. أضف عقاراً من «إضافة عقار» وفعّل «تشغيل الوحدات فندقياً»، أو أنشئ الغرف من «إعداد الضيافة».</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P20_PROPERTY is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000172)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'FD'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c  clob;',
'    l_id number;',
'    l_op varchar2(30) := apex_application.g_x01;',
'    l_p  number;',
'    l_d1 date;',
'    l_d2 date;',
'    function n(p varchar2) return number is begin return to_number(p); end;',
'    function d(p varchar2) return date is begin return to_date(p, ''YYYY-MM-DD''); end;',
'    procedure out(p clob) is',
'        l_off pls_integer := 1;',
'    begin',
'        while l_off <= dbms_lob.getlength(p) loop',
'            htp.prn(dbms_lob.substr(p, 8000, l_off));',
'            l_off := l_off + 8000;',
'        end loop;',
'    end;',
'begin',
'    l_p := case when l_op in (''TYPES'', ''FREE'') then n(apex_application.g_x02) end;',
'    l_d1 := case when l_op = ''FREE'' then d(apex_application.g_x03) end;',
'    l_d2 := case when l_op = ''FREE'' then d(apex_application.g_x04) end;',
'    case l_op',
'        when ''RACK'' then l_c := noona_hsp_pkg.rack_json(n(apex_application.g_x02));',
'        when ''CHART'' then l_c := noona_hsp_pkg.chart_json(n(apex_application.g_x02), d(apex_application.g_x03), n(apex_application.g_x04));',
'        when ''STAY'' then l_c := noona_hsp_pkg.stay_json(n(apex_application.g_x02));',
'        when ''TYPES'' then',
'            select json_object(''types'' value (select json_arrayagg(json_object(''id'' value t.id, ''name'' value t.name_ar,',
'                       ''rate'' value noona_hsp_pkg.nightly_rate((select min(p.id) from hsp_rate_plan p where p.property_id = t.property_id',
'                                     and p.is_active = ''Y'' and p.stay_type = ''DAILY''), t.id, noona_hsp_pkg.business_date(t.property_id)),',
'                       ''free'' value noona_hsp_pkg.available_count(t.property_id, t.id, noona_hsp_pkg.business_date(t.property_id),',
'                                     noona_hsp_pkg.business_date(t.property_id) + 1)) order by t.code returning clob)',
'                       from hsp_room_type t where t.property_id = l_p and t.is_active = ''Y''),',
'                   ''plans'' value (select json_arrayagg(json_object(''id'' value p.id, ''name'' value p.name_ar) order by p.code returning clob)',
'                       from hsp_rate_plan p where p.property_id = l_p and p.is_active = ''Y'') returning clob)',
'              into l_c from dual;',
'        when ''FREE'' then',
'            select json_arrayagg(json_object(''id'' value r.id, ''no'' value r.room_no, ''type'' value t.name_ar, ''hk'' value r.housekeeping_status)',
'                   order by r.room_no returning clob) into l_c',
'              from hsp_room r join hsp_room_type t on t.id = r.room_type_id',
'             where r.property_id = l_p and r.status_code = ''ACTIVE''',
'               and noona_hsp_pkg.is_free(r.id, l_d1, l_d2) = ''Y'';',
'            l_c := nvl(l_c, to_clob(''[]''));',
'        when ''PARTIES'' then',
'            select json_arrayagg(json_object(''id'' value id, ''name'' value display_name_ar) order by display_name_ar returning clob) into l_c',
'              from pty_party where party_type = ''ORGANIZATION'' and status_code = ''ACTIVE'';',
'            l_c := nvl(l_c, to_clob(''[]''));',
'        when ''WALKIN'' then l_id := noona_hsp_pkg.walk_in(apex_application.g_clob_01); l_c := ''{"stay":'' || l_id || ''}'';',
'        when ''CHECKIN'' then l_id := noona_hsp_pkg.check_in(n(apex_application.g_x02), n(apex_application.g_x03), nvl(apex_application.g_x04, ''N''));',
'            l_c := ''{"stay":'' || l_id || ''}'';',
'        when ''NOSHOW'' then noona_hsp_pkg.mark_no_show(n(apex_application.g_x02));',
'        when ''EXTEND'' then noona_hsp_pkg.change_departure(n(apex_application.g_x02), d(apex_application.g_x03));',
'        when ''MOVE'' then l_id := noona_hsp_pkg.move_room(n(apex_application.g_x02), n(apex_application.g_x03), apex_application.g_x04);',
'            l_c := ''{"stay":'' || l_id || ''}'';',
'        when ''CHARGE'' then l_id := noona_hsp_pkg.post_charge(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04,',
'                                                            n(apex_application.g_x05));',
'        when ''PAY'' then l_id := noona_hsp_pkg.post_payment(n(apex_application.g_x02), n(apex_application.g_x03), apex_application.g_x04,',
'                                                          null, null, apex_application.g_x05);',
'        when ''CHECKOUT'' then l_id := noona_hsp_pkg.check_out(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := ''{"folio":'' || l_id || ''}'';',
'        when ''HK'' then noona_hsp_pkg.set_hk_status(n(apex_application.g_x02), apex_application.g_x03);',
'        when ''RTS'' then noona_hsp_pkg.return_to_service(n(apex_application.g_x02));',
'        when ''SUMMARY'' then l_c := noona_hsp_pkg.front_summary(n(apex_application.g_x02));',
'        else raise_application_error(-20500, ''NOONA-HSP-099: عملية غير معروفة '' || l_op);',
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
,p_internal_uid=>91820273000000172
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000173)
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.::P20_PROPERTY:&P20_PROPERTY.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
