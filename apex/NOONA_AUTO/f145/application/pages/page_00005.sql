prompt --application/pages/page_00005
begin
--   Manifest
--     PAGE: 00005
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
 p_id=>5
,p_name=>'Appointments'
,p_alias=>'APPOINTMENTS'
,p_step_title=>'حجوزات الصيانة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''aut.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000085)
,p_plug_name=>'اليوم'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000086)
,p_name=>'P5_DATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000085)
,p_prompt=>'التاريخ'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000087)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000085)
,p_button_name=>'SHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000088)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820280000000085)
,p_button_name=>'NOSHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تحديث من لم يحضر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000089)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P5_DATE := nvl(:P5_DATE, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000089
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000090)
,p_plug_name=>'حجوزات اليوم'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_aut_pkg.appointments_html(to_date(:P5_DATE, ''YYYY-MM-DD''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000091)
,p_plug_name=>'حجز جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000092)
,p_name=>'P5_PLATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'رقم اللوحة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000093)
,p_name=>'P5_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'اسم العميل'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000094)
,p_name=>'P5_PHONE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000095)
,p_name=>'P5_START'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'الموعد (YYYY-MM-DD HH24:MI)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>16
,p_cMaxlength=>16
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000096)
,p_name=>'P5_MINUTES'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'المدة بالدقائق (فارغ = من الخدمات)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000097)
,p_name=>'P5_BAY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'الرافعة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from aut_bay where company_id = noona_aut_pkg.company and is_active = ''Y'' order by sort_order nulls last, code'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000098)
,p_name=>'P5_TECH'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'الفني'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from aut_technician where company_id = noona_aut_pkg.company and is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820280000000099)
,p_name=>'P5_SOURCE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'المصدر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:هاتف;PHONE,حضور مباشر;WALK_IN,واتساب;WHATSAPP,الموقع;WEB,التطبيق;APP'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000100)
,p_name=>'P5_SERVICES'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'الخدمات المطلوبة'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'select s.name_ar || '' ('' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from aut_service s where s.company_id = noona_aut_pkg.company and s.is_active = ''Y'' order by s.sort_order nulls last, s.name_ar'
,p_lov_columns=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000101)
,p_name=>'P5_COMPLAINT'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_prompt=>'ملاحظات / الشكوى'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820280000000103)
,p_validation_name=>'P5_START required (BOOK)'
,p_validation_sequence=>17
,p_validation=>'P5_START'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820280000000102)
,p_associated_item=>wwv_flow_imp.id(91820280000000095)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000102)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000091)
,p_button_name=>'BOOK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الحجز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000104)
,p_process_sequence=>6
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Start Default'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P5_START := nvl(:P5_START, to_char(to_date(:P5_DATE, ''YYYY-MM-DD'') + 9 / 24, ''YYYY-MM-DD HH24:MI''));',
':P5_SOURCE := nvl(:P5_SOURCE, ''PHONE'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820280000000104
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000105)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Book'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_o json_object_t := json_object_t();',
'    l_s json_array_t := json_array_t();',
'    l   number;',
'begin',
'    l_o.put(''plate'', :P5_PLATE); l_o.put(''name'', :P5_NAME); l_o.put(''phone'', :P5_PHONE); l_o.put(''start'', :P5_START);',
'    l_o.put(''minutes'', to_number(:P5_MINUTES)); l_o.put(''bay'', to_number(:P5_BAY)); l_o.put(''tech'', to_number(:P5_TECH));',
'    l_o.put(''source'', :P5_SOURCE); l_o.put(''complaint'', :P5_COMPLAINT);',
'    for s in (select to_number(column_value) id from table(apex_string.split(:P5_SERVICES, '':'')) where column_value is not null) loop',
'        l_s.append(s.id);',
'    end loop;',
'    l_o.put(''services'', l_s);',
'    l := noona_aut_pkg.book(l_o.to_clob);',
'    :P5_DATE := substr(:P5_START, 1, 10);',
'    :P5_PLATE := null; :P5_NAME := null; :P5_PHONE := null; :P5_START := null; :P5_COMPLAINT := null; :P5_SERVICES := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000102)
,p_process_success_message=>'تم حفظ الحجز'
,p_internal_uid=>91820280000000105
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000106)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'No Shows'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_aut_pkg.mark_no_shows;',
'    apex_application.g_print_success_message := ''حجوزات لم تحضر: '' || l;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'apex_application.g_request = ''NOSHOW'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>91820280000000106
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000107)
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
,p_internal_uid=>91820280000000107
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000108)
,p_branch_action=>'f?p=&APP_ID.:5:&SESSION.::&DEBUG.::P5_DATE:&P5_DATE.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
