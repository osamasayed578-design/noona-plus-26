prompt --application/pages/page_00086
begin
--   Manifest
--     PAGE: 00086
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
 p_id=>86
,p_name=>'Project Costs'
,p_alias=>'PROJECT-COSTS'
,p_step_title=>'التكاليف الفعلية للمشروع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''prj.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000646)
,p_plug_name=>'مصروف مباشر (من الصندوق أو البنك)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000647)
,p_name=>'P86_PROJECT'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000646)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000648)
,p_name=>'P86_WBS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000646)
,p_prompt=>'بند العمل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select lpad('' '', (wbs_level - 1) * 2) || code || '' - '' || name_ar d, id r from prj_wbs where project_id = :P86_PROJECT and status_code <> ''CANCELLED'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000649)
,p_name=>'P86_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000646)
,p_prompt=>'نوع التكلفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مواد;MATERIAL,عمالة;LABOR,معدات;EQUIPMENT,مقاولو باطن;SUBCONTRACT,مصروفات غير مباشرة;OVERHEAD,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000650)
,p_name=>'P86_AMOUNT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000646)
,p_prompt=>'المبلغ'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000651)
,p_name=>'P86_PLACE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000646)
,p_prompt=>'مدفوع من'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''صندوق: '' || name_ar d, ''BOX:'' || id r from csh_cash_box where company_id = noona_prj_pkg.company and status_code = ''ACTIVE'' union all select ''بنك: '' || name_ar, ''BANK:'' || id from csh_bank_account where company_id = noona_prj_pkg.company and status_code = ''ACTIVE'''
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
 p_id=>wwv_flow_imp.id(91820273000000652)
,p_name=>'P86_DESC'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000646)
,p_prompt=>'البيان'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000653)
,p_name=>'P86_REF'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000646)
,p_prompt=>'المرجع (فاتورة/إيصال)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>100
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000654)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000646)
,p_button_name=>'POST_EXPENSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'ترحيل المصروف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000655)
,p_plug_name=>'صرف مواد من المخزون'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000656)
,p_name=>'P86_MWBS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000655)
,p_prompt=>'بند العمل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select lpad('' '', (wbs_level - 1) * 2) || code || '' - '' || name_ar d, id r from prj_wbs where project_id = :P86_PROJECT and status_code <> ''CANCELLED'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000657)
,p_name=>'P86_WH'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000655)
,p_prompt=>'المستودع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from inv_warehouse where company_id = noona_prj_pkg.company and status_code = ''ACTIVE'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820273000000658)
,p_name=>'P86_ITEM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000655)
,p_prompt=>'الصنف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select i.name_ar || '' ('' || i.code || '')'' d, i.id r from inv_item i where i.status_code = ''ACTIVE'' and i.item_type not in (''SERVICE'', ''NON_STOCK'') order by i.name_ar'
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
 p_id=>wwv_flow_imp.id(91820273000000659)
,p_name=>'P86_QTY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000655)
,p_prompt=>'الكمية'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000660)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000655)
,p_button_name=>'ISSUE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'صرف للمشروع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000661)
,p_plug_name=>'ساعات العمل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000662)
,p_name=>'P86_EMP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000661)
,p_prompt=>'الموظف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_prj_pkg.company) order by 1'
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
 p_id=>wwv_flow_imp.id(91820273000000663)
,p_name=>'P86_TWBS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000661)
,p_prompt=>'بند العمل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select lpad('' '', (wbs_level - 1) * 2) || code || '' - '' || name_ar d, id r from prj_wbs where project_id = :P86_PROJECT and status_code <> ''CANCELLED'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000664)
,p_name=>'P86_TDATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000661)
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000665)
,p_name=>'P86_HOURS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000661)
,p_prompt=>'الساعات'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000666)
,p_name=>'P86_RATE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000661)
,p_prompt=>'تكلفة الساعة (فارغ = من الراتب)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000667)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000661)
,p_button_name=>'TIMESHEET'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تسجيل الساعات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000668)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000661)
,p_button_name=>'POST_TS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تحميل الساعات المعتمدة على المشروع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000669)
,p_plug_name=>'ساعات بانتظار التحميل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob := ''<table class="nn-prj-t"><thead><tr><th>التاريخ</th><th>الموظف</th><th>البند</th><th class="n">الساعات</th><th class="n">تكلفة الساعة</th></tr></thead><tbody>'';',
'    n pls_integer := 0;',
'begin',
'    for r in (select t.work_date, noona_hr_pkg.employee_name(t.employee_id) emp, w.code, t.hours, t.cost_rate from prj_timesheet t',
'               join prj_wbs w on w.id = t.wbs_id where t.project_id = :P86_PROJECT and t.status_code in (''DRAFT'', ''SUBMITTED'') order by t.work_date) loop',
'        n := n + 1; l := l || ''<tr><td>'' || to_char(r.work_date, ''YYYY-MM-DD'') || ''</td><td>'' || apex_escape.html(r.emp) || ''</td><td>''',
'            || apex_escape.html(r.code) || ''</td><td class="n">'' || r.hours || ''</td><td class="n">'' || r.cost_rate || ''</td></tr>'';',
'    end loop;',
'    return case when n = 0 then ''<div class="nn-empty">لا توجد ساعات بانتظار التحميل</div>'' else l || ''</tbody></table>'' end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000670)
,p_plug_name=>'حركات التكلفة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prj_pkg.costs_html(:P86_PROJECT, 200);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000671)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRJ'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c clob;',
'    function n(p varchar2) return number is begin return to_number(p); end;',
'begin',
'    case apex_application.g_x01',
'        when ''BOQ'' then l_c := ''{"n":'' || noona_prj_pkg.save_boq(n(apex_application.g_x02), apex_application.g_clob_01) || ''}'';',
'        when ''VO'' then l_c := ''{"id":'' || noona_prj_pkg.save_variation(apex_application.g_clob_01) || ''}'';',
'        when ''BUDGET'' then l_c := ''{"id":'' || noona_prj_pkg.save_budget(n(apex_application.g_x02), apex_application.g_clob_01,',
'                                                                       apex_application.g_x03) || ''}'';',
'        when ''CLAIM'' then noona_prj_pkg.save_claim(apex_application.g_clob_01);',
'            l_c := noona_prj_pkg.claim_json(json_value(apex_application.g_clob_01, ''$.id'' returning number));',
'        when ''REV'' then noona_prj_pkg.reverse_cost(n(apex_application.g_x02), apex_application.g_x03);',
'        else raise_application_error(-20500, ''NOONA-PRJ-099: عملية غير معروفة'');',
'    end case;',
'    htp.prn(nvl(l_c, to_clob(''{"ok":true}'')));',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''err'', regexp_replace(nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm),',
'                                          ''\s*\[cid=[^]]+\]'', ''''));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000671
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000672)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P86_TYPE := nvl(:P86_TYPE, ''OTHER''); :P86_TDATE := nvl(:P86_TDATE, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000672
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000673)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Expense'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l_id number;',
'begin',
'    select json_object(''project'' value to_number(:P86_PROJECT), ''wbs'' value to_number(:P86_WBS), ''type'' value :P86_TYPE,',
'                       ''amount'' value to_number(:P86_AMOUNT), ''place'' value :P86_PLACE, ''desc'' value :P86_DESC, ''ref'' value :P86_REF',
'                       returning clob) into l_doc from dual;',
'    l_id := noona_prj_pkg.post_expense(l_doc); :P86_AMOUNT := null; :P86_DESC := null; :P86_REF := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000654)
,p_process_success_message=>'تم ترحيل المصروف على المشروع'
,p_internal_uid=>91820273000000673
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000674)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Issue'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l_id number;',
'begin',
'    select json_object(''project'' value to_number(:P86_PROJECT), ''wbs'' value to_number(:P86_MWBS), ''wh'' value to_number(:P86_WH),',
'                       ''lines'' value json_array(json_object(''i'' value to_number(:P86_ITEM), ''q'' value to_number(:P86_QTY))) returning clob)',
'      into l_doc from dual;',
'    l_id := noona_prj_pkg.issue_material(l_doc); :P86_QTY := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000660)
,p_process_success_message=>'تم صرف المواد وتحميل تكلفتها'
,p_internal_uid=>91820273000000674
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000675)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Timesheet'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l_id number;',
'begin',
'    select json_object(''employee'' value to_number(:P86_EMP), ''project'' value to_number(:P86_PROJECT), ''wbs'' value to_number(:P86_TWBS),',
'                       ''date'' value :P86_TDATE, ''hours'' value to_number(:P86_HOURS), ''rate'' value to_number(:P86_RATE) returning clob)',
'      into l_doc from dual;',
'    l_id := noona_prj_pkg.save_timesheet(l_doc); :P86_HOURS := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000667)
,p_process_success_message=>'تم تسجيل الساعات'
,p_internal_uid=>91820273000000675
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000676)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Post Timesheets'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_prj_pkg.post_timesheets(:P86_PROJECT);',
'    apex_application.g_print_success_message := ''تم تحميل '' || l || '' سجل ساعات على المشروع'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000668)
,p_internal_uid=>91820273000000676
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000677)
,p_branch_action=>'f?p=&APP_ID.:86:&SESSION.::&DEBUG.::P86_PROJECT:&P86_PROJECT.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
