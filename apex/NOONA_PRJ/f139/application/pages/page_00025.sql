prompt --application/pages/page_00025
begin
--   Manifest
--     PAGE: 00025
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
 p_id=>25
,p_name=>'Housekeeping'
,p_alias=>'HOUSEKEEPING'
,p_step_title=>'التدبير الفندقي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000010)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''frontdesk.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000260)
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
 p_id=>wwv_flow_imp.id(91820273000000261)
,p_name=>'P25_PROPERTY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000260)
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
 p_id=>wwv_flow_imp.id(91820273000000262)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P25_PROPERTY := nvl(:P25_PROPERTY, noona_hsp_pkg.default_property);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000262
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000263)
,p_plug_name=>'التدبير الفندقي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P25_PROPERTY is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    return ''<div id="nnFd" class="nn-fd" data-mode="hk" data-property="'' || :P25_PROPERTY',
'        || ''" data-folio="'' || apex_escape.html_attribute(replace(apex_page.get_url(p_page => 24, p_items => ''P24_ID'', p_values => ''990000000001''), ''990000000001'', ''990000000001''))',
'        || ''" data-res="'' || apex_escape.html_attribute(apex_page.get_url(p_page => 22, p_clear_cache => ''22'',',
'               p_items => ''P22_PROPERTY,P22_ROOM'', p_values => :P25_PROPERTY || '',990000000001'')) || ''"''',
'        || '' data-req="'' || apex_escape.html_attribute(apex_page.get_url(p_page => 71, p_clear_cache => ''71'',',
'               p_items => ''P71_NEW_ROOM'', p_values => ''990000000001'')) || ''"''',
'        || '' data-resv="'' || apex_escape.html_attribute(replace(apex_page.get_url(p_page => 23, p_items => ''P23_ID'', p_values => ''990000000001''), ''990000000001'', ''990000000001'')) || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000264)
,p_plug_name=>'لا يوجد فندق'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>12
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">لا توجد غرف فندقية بعد. أضف عقاراً من «إضافة عقار» وفعّل «تشغيل الوحدات فندقياً»، أو أنشئ الغرف من «إعداد الضيافة».</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P25_PROPERTY is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000265)
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
,p_internal_uid=>91820273000000265
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000266)
,p_branch_action=>'f?p=&APP_ID.:25:&SESSION.::&DEBUG.::P25_PROPERTY:&P25_PROPERTY.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000267)
,p_plug_name=>'مهام التنظيف المفتوحة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.id, r.room_no, case t.task_type when ''DEPARTURE_CLEAN'' then ''تنظيف مغادرة'' when ''STAYOVER'' then ''تنظيف يومي لغرفة مشغولة''',
'       when ''DEEP_CLEAN'' then ''تنظيف عميق'' when ''TURNDOWN'' then ''تجهيز مسائي'' else ''فحص'' end as task, to_char(t.task_date, ''YYYY-MM-DD'') as d,',
'       noona_hsp_pkg.res_status_label(t.status_code) as status, p.display_name_ar as worker',
'  from hsp_housekeeping_task t join hsp_room r on r.id = t.room_id left join hr_employee e on e.id = t.assigned_employee_id',
'  left join pty_party p on p.id = e.person_party_id',
' where r.property_id = :P25_PROPERTY and t.status_code in (''PENDING'', ''ASSIGNED'', ''IN_PROGRESS'') order by r.room_no'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مهام التنظيف المفتوحة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000268)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_owner=>'NOONA'
,p_internal_uid=>91820273000000268
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000270)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000271)
,p_db_column_name=>'ROOM_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الغرفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000272)
,p_db_column_name=>'TASK'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المهمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000273)
,p_db_column_name=>'D'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000274)
,p_db_column_name=>'STATUS'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000275)
,p_db_column_name=>'WORKER'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'العامل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000269)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'269'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ROOM_NO:TASK:D:STATUS:WORKER'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000276)
,p_plug_name=>'إسناد مهمة لعامل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000277)
,p_name=>'P25_TASK'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000276)
,p_prompt=>'المهمة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.room_no || '' - '' || t.task_type d, t.id r from hsp_housekeeping_task t join hsp_room r on r.id = t.room_id where r.property_id = :P25_PROPERTY and t.status_code in (''PENDING'', ''ASSIGNED'') order by r.room_no'
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
 p_id=>wwv_flow_imp.id(91820273000000278)
,p_name=>'P25_EMP'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000276)
,p_prompt=>'العامل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select e.employee_no || '' - '' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_hsp_pkg.company and m.status_code in (''ACTIVE'', ''NOTICE_PERIOD'')) order by e.employee_no'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000279)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000276)
,p_button_name=>'ASSIGN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إسناد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000280)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Assign'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_hsp_pkg.assign_hk(:P25_TASK, :P25_EMP);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000279)
,p_process_success_message=>'تم الإسناد'
,p_internal_uid=>91820273000000280
);

wwv_flow_imp.component_end;
end;
/
