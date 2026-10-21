prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>22
,p_name=>'Journal View'
,p_alias=>'JOURNAL-VIEW'
,p_step_title=>'عرض القيد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// عارض المستندات: بطاقات .nn-dv-card (data-kind pdf|img|office|paper) تعرض في إطار المعاينة داخل الصفحة',
'(function () {',
'    var esc = function (s) { return String(s == null ? '''' : s).replace(/[&<>"'']/g, function (c) { return {''&'': ''&amp;'', ''<'': ''&lt;'', ''>'': ''&gt;'', ''"'': ''&quot;'', "''": ''&#39;''}[c]; }); };',
'    document.querySelectorAll(''.nn-dv'').forEach(function (dv) {',
'        var view = dv.querySelector(''.nn-dv-view'');',
'        function show(card) {',
'            dv.querySelectorAll(''.nn-dv-card'').forEach(function (c) { c.classList.toggle(''is-active'', c === card); });',
'            var k = card.dataset.kind, u = card.dataset.view, t = card.dataset.title;',
'            var h = ''<div class="nn-dv-bar"><b>'' + esc(t) + ''</b>'' + (u ? ''<span><a href="'' + esc(u) + ''" target="_blank" rel="noopener">''',
'                  + ''<span class="fa fa-external-link" aria-hidden="true"></span> فتح في نافذة</a><a href="'' + esc(card.dataset.dl) + ''">''',
'                  + ''<span class="fa fa-download" aria-hidden="true"></span> تنزيل</a></span>'' : '''') + ''</div>'';',
'            if (k === ''pdf'') h += ''<iframe class="nn-dv-frame" src="'' + esc(u) + ''" title="'' + esc(t) + ''"></iframe>'';',
'            else if (k === ''img'') h += ''<div class="nn-dv-img"><img src="'' + esc(u) + ''" alt="'' + esc(t) + ''"></div>'';',
'            else if (k === ''office'') h += ''<div class="nn-dv-msg"><span class="fa fa-file-text-o" aria-hidden="true"></span>لا تتوفر معاينة لمستندات Word/Excel داخل الصفحة؛ ''',
'                                        + ''<a href="'' + esc(card.dataset.dl) + ''">نزّل الملف</a></div>'';',
'            else h += ''<div class="nn-dv-msg"><span class="fa fa-archive" aria-hidden="true"></span><b>أصل ورقي فقط (لا توجد صورة)</b>'' + esc(card.dataset.paper) + ''</div>'';',
'            view.innerHTML = h;',
'        }',
'        dv.addEventListener(''click'', function (e) {',
'            if (e.target.closest(''a'')) return;',
'            var img = e.target.closest(''.nn-dv-img''); if (img) { img.classList.toggle(''is-zoom''); return; }',
'            var c = e.target.closest(''.nn-dv-card''); if (c) show(c);',
'        });',
'        dv.addEventListener(''keydown'', function (e) { if (e.key === ''Enter'') { var c = e.target.closest(''.nn-dv-card''); if (c) show(c); } });',
'        if (dv.dataset.auto === ''Y'') {',
'            var first = dv.querySelector(''.nn-dv-card[data-kind="pdf"], .nn-dv-card[data-kind="img"]'') || dv.querySelector(''.nn-dv-card'');',
'            if (first) show(first);',
'        }',
'    });',
'})();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000303)
,p_plug_name=>'القيد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000304)
,p_name=>'P22_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000303)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000305)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000303)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'طباعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.print();'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000306)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000303)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:history.back();'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000307)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820266000000303)
,p_button_name=>'OPEN'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'فتح القيد للإجراءات'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_ID:&P22_ID.'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000308)
,p_plug_name=>'القيد ومستند المصدر'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_fin_rpt_pkg.journal_view(:P22_ID, replace(apex_page.get_url(p_page => 49, p_items => ''P49_DOC'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
