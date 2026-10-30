prompt --application/pages/page_00033
begin
--   Manifest
--     PAGE: 00033
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>33
,p_name=>'Receipt'
,p_alias=>'RECEIPT'
,p_step_title=>'إيصال'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.body.classList.add(''nn-receipt-page'');',
'(function () {',
'    var els = document.querySelectorAll(''.nn-qr[data-qr]''); if (!els.length) return;',
'    var draw = function () { els.forEach(function (el) { var q = qrcode(0, ''M''); q.addData(el.dataset.qr); q.make();',
'        el.innerHTML = q.createSvgTag({cellSize: 3, margin: 2, scalable: true}); }); };',
'    if (window.qrcode) { draw(); return; }',
'    var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''qrcode.js''; s.onload = draw; document.head.appendChild(s);',
'})();',
'if ($v(''P33_AUTO'') === ''Y'') { setTimeout(function () { window.print(); }, 700); }'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000183)
,p_plug_name=>'الإيصال'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000184)
,p_name=>'P33_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820269000000183)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000185)
,p_name=>'P33_AUTO'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820269000000183)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000186)
,p_plug_name=>'الإيصال'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P33_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_pos_pkg.receipt_html(:P33_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
