prompt --application/pages/page_00016
begin
--   Manifest
--     PAGE: 00016
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>16
,p_name=>'Shops Map'
,p_alias=>'MAP'
,p_step_title=>'خريطة المحلات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () {',
'  function css(h) { var l = document.createElement(''link''); l.rel = ''stylesheet''; l.href = h; document.head.appendChild(l); }',
'  css(''https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'');',
'  var s = document.createElement(''script''); s.src = ''https://unpkg.com/leaflet@1.9.4/dist/leaflet.js'';',
'  function fallback(el, pts) {',
'    el.classList.remove(''nn-dst-map''); el.innerHTML = ''<p class="nn-hint">تعذر تحميل الخريطة؛ مواقع المحلات على خرائط Google:</p>'';',
'    pts.forEach(function (p) { var a = document.createElement(''a''); a.className = ''nn-dst-btn''; a.target = ''_blank''; a.rel = ''noopener'';',
'      a.href = ''https://www.google.com/maps?q='' + p.lat + '','' + p.lng; a.textContent = p.n; el.appendChild(a); });',
'  }',
'  s.onerror = function () { var el = document.getElementById(''dstMap''); if (el) fallback(el, JSON.parse(el.getAttribute(''data-geo'') || ''[]'')); };',
'  s.onload = function () {',
'    var el = document.getElementById(''dstMap''); if (!el) return;',
'    if (!window.L) { fallback(el, JSON.parse(el.getAttribute(''data-geo'') || ''[]'')); return; }',
'    var pts = JSON.parse(el.getAttribute(''data-geo'') || ''[]''), u = el.getAttribute(''data-url'');',
'    var m = L.map(el).setView(pts.length ? [pts[0].lat, pts[0].lng] : [24.7136, 46.6753], pts.length ? 12 : 6);',
'    L.tileLayer(''https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'', { maxZoom: 19, attribution: ''&copy; OpenStreetMap'' }).addTo(m);',
'    var b = [];',
'    pts.forEach(function (p) {',
'      var c = L.circleMarker([p.lat, p.lng], { radius: 9, weight: 2, color: ''#fff'', fillOpacity: .9, fillColor: p.s === ''A'' ? ''#16a34a'' : ''#f59e0b'' }).addTo(m);',
'      var a = document.createElement(''a''); a.href = u.replace(''XSHOPX'', p.id); a.textContent = p.n;',
'      var d = document.createElement(''div''); d.appendChild(a); if (p.r) { var r = document.createElement(''div''); r.textContent = p.r; d.appendChild(r); }',
'      c.bindPopup(d); b.push([p.lat, p.lng]);',
'    });',
'    if (b.length > 1) m.fitBounds(b, { padding: [30, 30] });',
'  };',
'  document.head.appendChild(s);',
'})();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000241)
,p_plug_name=>'المرشحات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000242)
,p_name=>'P16_ROUTE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000241)
,p_prompt=>'خط السير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.name_ar || nvl2(r.rep_id, '' · '' || noona_dst_pkg.rep_label(r.rep_id), '''') d, r.id r from dst_route r where r.company_id = noona_dst_pkg.company and r.status_code = ''ACTIVE'' order by r.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- كل الخطوط -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000243)
,p_plug_name=>'الخريطة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div id="dstMap" class="nn-dst-map" data-geo="'' || apex_escape.html_attribute(noona_dst_pkg.shops_geo_json(to_number(:P16_ROUTE))) || ''"''',
'    || '' data-url="'' || apex_page.get_url(p_page => 15, p_clear_cache => ''15'', p_items => ''P15_ID'', p_values => ''XSHOPX'') || ''"></div>''',
'    || ''<p class="nn-hint">الأخضر: اشترى خلال 14 يوماً، البرتقالي: راكد. المحلات بلا موقع لا تظهر حتى تُزار أول مرة أو يحدد موقعها.</p>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
