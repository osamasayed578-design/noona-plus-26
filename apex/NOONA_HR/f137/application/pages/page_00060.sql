prompt --application/pages/page_00060
begin
--   Manifest
--     PAGE: 00060
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
 p_id=>60
,p_name=>'Reports'
,p_alias=>'REPORTS'
,p_step_title=>'تقارير الموارد البشرية والرواتب'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820272000000002)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000320)
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
 p_id=>wwv_flow_imp.id(91820272000000321)
,p_name=>'P60_REPORT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820272000000320)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:القوى العاملة ونسبة التوطين;HEADCOUNT,أرصدة الإجازات;LEAVES,الحضور الشهري;ATTENDANCE,الهويات والعقود القريبة الانتهاء;EXPIRING,التزام مكافأة نهاية الخدمة;EOS,السلف القائمة;LOANS,مسير رواتب تشغيل;REGISTER,ملخص عناصر الرواتب;ELEMENTS,تقرير التأمينات الاجتماعية;GOSI,تكلفة الرواتب حسب مركز التكلفة;CC'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820272000000322)
,p_name=>'P60_RUN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820272000000320)
,p_prompt=>'التشغيل (لتقارير الرواتب)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.run_no d, r.id r from pay_run r join pay_period p on p.id = r.period_id where r.company_id = noona_pay_pkg.company order by p.start_date desc, r.id desc'
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
 p_id=>wwv_flow_imp.id(91820272000000323)
,p_name=>'P60_DATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820272000000320)
,p_prompt=>'التاريخ / الشهر'
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
 p_id=>wwv_flow_imp.id(91820272000000324)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820272000000320)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820272000000325)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P60_REPORT := nvl(:P60_REPORT, ''HEADCOUNT'');',
':P60_DATE := nvl(:P60_DATE, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820272000000325
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820272000000326)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_d date := to_date(:P60_DATE, ''YYYY-MM-DD'');',
'begin',
'    if :P60_REPORT in (''EOS'', ''LOANS'', ''REGISTER'', ''ELEMENTS'', ''GOSI'', ''CC'')',
'       and noona_security_pkg.has_permission(''PAY_RUN.VIEW'', noona_pay_pkg.company) = ''N'' then',
'        return ''<p class="nn-hint">تقارير الرواتب تتطلب صلاحية عرض الرواتب</p>'';',
'    end if;',
'    return case :P60_REPORT',
'        when ''HEADCOUNT'' then noona_hr_pkg.headcount_report',
'        when ''LEAVES'' then noona_hr_pkg.leave_balances_report(l_d)',
'        when ''ATTENDANCE'' then noona_hr_pkg.attendance_report(l_d)',
'        when ''EXPIRING'' then noona_hr_pkg.expiring_report(90)',
'        when ''EOS'' then noona_pay_pkg.eos_liability_html(l_d)',
'        when ''LOANS'' then noona_pay_pkg.loans_report_html',
'        when ''REGISTER'' then case when :P60_RUN is not null then noona_pay_pkg.run_register_html(:P60_RUN) end',
'        when ''ELEMENTS'' then case when :P60_RUN is not null then noona_pay_pkg.element_summary_html(:P60_RUN) end',
'        when ''GOSI'' then case when :P60_RUN is not null then noona_pay_pkg.gosi_report_html(:P60_RUN) end',
'        when ''CC'' then case when :P60_RUN is not null then noona_pay_pkg.cost_center_html(:P60_RUN) end',
'    end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820272000000327)
,p_branch_action=>'f?p=&APP_ID.:60:&SESSION.::&DEBUG.:60:P60_REPORT,P60_RUN,P60_DATE:&P60_REPORT.,&P60_RUN.,&P60_DATE.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
