prompt --application/pages/page_00075
begin
--   Manifest
--     PAGE: 00075
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>141
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>75
,p_name=>'Nurse Station'
,p_alias=>'NURSE-STATION'
,p_step_title=>'محطة التمريض'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.addEventListener(''click'', function (e) {',
'  var b = e.target.closest(''.nn-his-pt[data-visit]''); if (!b) return;',
'  location.href = ''f?p='' + apex.env.APP_ID + '':76:'' + apex.env.APP_SESSION + ''::NO:RP,76:P76_VISIT:'' + b.dataset.visit;',
'});',
'var nnSeen = {}, nnSound = false;',
'try { nnSound = localStorage.getItem(''nnNurseSound'') === ''Y''; } catch (e) {}',
'window.nnNurseEnable = function () {',
'  nnSound = true; try { localStorage.setItem(''nnNurseSound'', ''Y''); } catch (e) {}',
'  if (window.Notification && Notification.permission === ''default'') Notification.requestPermission();',
'  nnBeep(); apex.message.showPageSuccess(''تم تفعيل التنبيه الصوتي وتنبيهات المتصفح'');',
'};',
'function nnBeep() {',
'  try { var c = new (window.AudioContext || window.webkitAudioContext)(), o = c.createOscillator(), g = c.createGain();',
'    o.frequency.value = 880; o.connect(g); g.connect(c.destination); g.gain.value = 0.15; o.start(); setTimeout(function () { o.stop(); c.close(); }, 450);',
'  } catch (e) {}',
'}',
'function nnPoll() {',
'  var w = $v(''P75_WARD''); if (!w) return;',
'  apex.server.process(''ALERTS'', { x01: w }, { dataType: ''json'' }).then(function (d) {',
'    var box = document.getElementById(''nnNurseAlerts''); if (!box) return;',
'    var fresh = 0, html = '''';',
'    (d.items || []).forEach(function (it) {',
'      if (!nnSeen[it.k + it.late]) { nnSeen[it.k + it.late] = 1; fresh++;',
'        if (nnSound && window.Notification && Notification.permission === ''granted'')',
'          new Notification((it.late === ''Y'' ? ''متأخرة: '' : ''حان الموعد: '') + it.what, { body: it.bed + '' - '' + it.patient + '' ('' + it.at + '')'' }); }',
'      html += ''<span class="nn-his-alert'' + (it.late === ''Y'' ? '' is-late'' : '''') + ''"><b>'' + apex.util.escapeHTML(it.at) + ''</b> ''',
'            + apex.util.escapeHTML(it.bed + '' · '' + it.patient) + ''<br><small dir="ltr">'' + apex.util.escapeHTML(it.what) + ''</small></span>'';',
'    });',
'    box.innerHTML = html ? ''<div class="hd">'' + (d.overdue ? d.overdue + '' متأخرة · '' : '''') + d.due + '' حان موعدها</div>'' + html',
'                         : ''<div class="hd ok">لا توجد جرعات أو متابعات مستحقة الآن</div>'';',
'    if (fresh && nnSound) nnBeep();',
'  });',
'}',
'nnPoll(); setInterval(nnPoll, 60000);',
'setTimeout(function () { location.reload(); }, 600000);'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001094)
,p_plug_name=>'الجناح'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>3
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001095)
,p_name=>'P75_WARD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000001094)
,p_prompt=>'الجناح'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_department where company_id = noona_his_pkg.company and dept_type in (''INPATIENT_WARD'', ''EMERGENCY'', ''NURSING'') order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000001096)
,p_name=>'P75_HOURS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000001094)
,p_prompt=>'المستحق خلال'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:ساعة;1,ساعتين;2,4 ساعات;4,8 ساعات;8,24 ساعة;24'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000001097)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000001094)
,p_button_name=>'ENABLE_SOUND'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تفعيل تنبيه الصوت والمتصفح'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:nnNurseEnable();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001098)
,p_process_sequence=>2
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P75_HOURS := nvl(:P75_HOURS, ''2'');',
'    if :P75_WARD is null then select min(id) into :P75_WARD from his_department where company_id = noona_his_pkg.company and dept_type = ''INPATIENT_WARD''; end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000001098
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001099)
,p_plug_name=>'التنبيهات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>4
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P75_WARD is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div id="nnNurseAlerts" class="nn-his-alerts"></div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001100)
,p_plug_name=>'المناوبون'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P75_WARD is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_nurse_pkg.on_duty_html(:P75_WARD);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001101)
,p_plug_name=>'المرضى'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P75_WARD is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_nurse_pkg.station_html(:P75_WARD);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000001102)
,p_plug_name=>'المستحق من الجرعات والمتابعة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P75_WARD is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_nurse_pkg.due_html(:P75_WARD, to_number(:P75_HOURS));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000001103)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'ALERTS'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob := noona_his_nurse_pkg.alerts_json(to_number(apex_application.g_x01)); i pls_integer := 1;',
'begin',
'    while i <= dbms_lob.getlength(l) loop',
'        htp.prn(dbms_lob.substr(l, 8000, i));',
'        i := i + 8000;',
'    end loop;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000001103
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000001104)
,p_branch_action=>'f?p=&APP_ID.:75:&SESSION.::&DEBUG.::P75_WARD,P75_HOURS:&P75_WARD.,&P75_HOURS.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
