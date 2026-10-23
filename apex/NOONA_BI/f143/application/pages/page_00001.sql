prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>143
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'مركز التقارير'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820277000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.addEventListener(''click'', function (e) {',
'  var b = e.target.closest(''.nn-rh-fav''); if (!b) return;',
'  e.preventDefault(); b.disabled = true;',
'  apex.server.process(''FAV'', { x01: b.dataset.id }, { dataType: ''json'' }).then(function (d) {',
'    b.disabled = false;',
'    if (!d.ok) { apex.message.clearErrors(); apex.message.showErrors([{ type: ''error'', location: ''page'', message: d.msg, unsafe: false }]); return; }',
'    var on = d.fav === ''Y'';',
'    document.querySelectorAll(''.nn-rh-fav[data-id="'' + b.dataset.id + ''"]'').forEach(function (x) {',
'      x.classList.toggle(''is-on'', on); x.title = on ? ''إزالة من المفضلة'' : ''إضافة للمفضلة'';',
'      x.firstElementChild.className = ''fa '' + (on ? ''fa-star'' : ''fa-star-o''); });',
'    apex.message.showPageSuccess(on ? ''أضيف التقرير إلى المفضلة'' : ''أزيل التقرير من المفضلة'');',
'  }, function () { b.disabled = false; });',
'});',
'var s = document.getElementById(''nnRhSearch'');',
'if (s) {',
'  s.addEventListener(''keydown'', function (e) {',
'    if (e.key === ''Enter'') { e.preventDefault(); $s(''P1_SEARCH'', s.value.trim()); apex.submit(''SEARCH''); }',
'    if (e.key === ''Escape'' && $v(''P1_SEARCH'')) { $s(''P1_SEARCH'', ''''); apex.submit(''SEARCH''); } });',
'  if (!s.value) s.focus();',
'}'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820277000000009)
,p_plug_name=>'مركز التقارير'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_apps varchar2(4000);',
'begin',
'    select listagg(alias, '','') within group (order by alias) into l_apps from apex_applications;',
'    return noona_bi_pkg.home_html(:APP_SESSION, l_apps, :P1_SEARCH);',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820277000000010)
,p_name=>'P1_SEARCH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820277000000009)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820277000000011)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'FAV'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_fav varchar2(1);',
'begin',
'    l_fav := noona_bi_pkg.toggle_favorite(to_number(apex_application.g_x01));',
'    apex_json.open_object; apex_json.write(''ok'', true); apex_json.write(''fav'', l_fav); apex_json.close_object;',
'exception when others then',
'    apex_json.open_object; apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', regexp_replace(sqlerrm, ''^ORA-[0-9]+: '', '''')); apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820277000000011
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820277000000012)
,p_branch_action=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
