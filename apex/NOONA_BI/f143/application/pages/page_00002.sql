prompt --application/pages/page_00002
begin
--   Manifest
--     PAGE: 00002
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
 p_id=>2
,p_name=>'Module Reports'
,p_alias=>'MODULE'
,p_step_title=>'تقارير الوحدة'
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
'function nnFilter() {',
'  var q = s.value.trim().toLowerCase(), n = 0;',
'  document.querySelectorAll(''.nn-rh-rep'').forEach(function (c) {',
'    var on = !q || c.textContent.toLowerCase().indexOf(q) >= 0; c.style.display = on ? '''' : ''none''; if (on) n++; });',
'  var em = document.getElementById(''nnRhNone'');',
'  if (!n && !em) { em = document.createElement(''div''); em.id = ''nnRhNone''; em.className = ''nn-empty''; em.textContent = ''لا توجد تقارير مطابقة'';',
'    var g = document.querySelector(''.nn-rh-reps''); if (g) g.after(em); }',
'  if (em) em.style.display = n ? ''none'' : '''';',
'}',
'if (s) { s.addEventListener(''input'', nnFilter); s.addEventListener(''keydown'', function (e) { if (e.key === ''Escape'') { s.value = ''''; nnFilter(); } }); s.focus(); }'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820277000000013)
,p_plug_name=>'التقارير'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_apps varchar2(4000);',
'begin',
'    select listagg(alias, '','') within group (order by alias) into l_apps from apex_applications;',
'    return noona_bi_pkg.module_html(:P2_MODULE, :APP_SESSION, l_apps, :P2_TYPE);',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820277000000014)
,p_name=>'P2_MODULE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820277000000013)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820277000000015)
,p_name=>'P2_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820277000000013)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820277000000016)
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
,p_internal_uid=>91820277000000016
);

wwv_flow_imp.component_end;
end;
/
