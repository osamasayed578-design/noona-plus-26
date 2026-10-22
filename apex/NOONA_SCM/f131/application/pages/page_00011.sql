prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>131
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Item'
,p_alias=>'ITEM'
,p_step_title=>'بطاقة صنف'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// بطاقة الصنف: البيانات الأساسية والأسعار والباركود المتعدد، وأقسام حسب ملف الصنف:',
'// قطع الغيار (رقم OEM، العلامة، التوافق مع المركبات، البدائل)، الأدوية (المادة الفعالة، التركيز، الشكل، الوصفة، التسجيل)،',
'// والحفظ بطلب واحد SAVE_DOC بكائن JSON يطابق NOONA_INV_PKG.save_item',
'(function () {',
'    var root = document.getElementById(''nnItem''); if (!root) return;',
'    var data = function (id) { var el = document.getElementById(id); try { return JSON.parse(el ? el.textContent : ''null''); } catch (e) { return null; } };',
'    var d = data(''nnItemData'') || {}, L = data(''nnTdLists'') || {};',
'    var esc = function (s) { return String(s == null ? '''' : s).replace(/[&<>"]/g, function (c) { return {''&'': ''&amp;'', ''<'': ''&lt;'', ''>'': ''&gt;'', ''"'': ''&quot;''}[c]; }); };',
'    var opt = function (v, t, sel) { return ''<option value="'' + esc(v) + ''"'' + (String(v) === String(sel == null ? '''' : sel) ? '' selected'' : '''') + ''>'' + esc(t) + ''</option>''; };',
'    var sel = function (k, opts, v, blank) { return ''<select data-k="'' + k + ''">'' + (blank ? opt('''', blank) : '''') + opts.map(function (o) { return opt(o.v, o.n, v); }).join('''') + ''</select>''; };',
'    var inp = function (k, v, type, ph) { return ''<input data-k="'' + k + ''" type="'' + (type || ''text'') + ''" value="'' + esc(v) + ''"'' + (type === ''number'' ? '' step="any"'' : '''') + (ph ? '' placeholder="'' + esc(ph) + ''"'' : '''') + ''>''; };',
'    var f = function (label, html, cls) { return ''<label class="nn-doc-f '' + (cls || '''') + ''"><span>'' + label + ''</span>'' + html + ''</label>''; };',
'    var yn = [{v: ''N'', n: ''لا''}, {v: ''Y'', n: ''نعم''}];',
'    var types = [{v: ''STOCK'', n: ''سلعة مخزنية''}, {v: ''SPARE_PART'', n: ''قطعة غيار''}, {v: ''RAW_MATERIAL'', n: ''خامة / مادة أولية''},',
'                 {v: ''SEMI_FINISHED'', n: ''منتج نصف مصنع''}, {v: ''FINISHED_GOOD'', n: ''منتج تام مصنع''}, {v: ''CONSUMABLE'', n: ''مستهلكات''},',
'                 {v: ''SERVICE'', n: ''خدمة''}, {v: ''NON_STOCK'', n: ''صنف غير مخزني''}];',
'    var forms = [{v: ''TABLET'', n: ''أقراص''}, {v: ''CAPSULE'', n: ''كبسولات''}, {v: ''SYRUP'', n: ''شراب''}, {v: ''INJECTION'', n: ''حقن''},',
'                 {v: ''CREAM'', n: ''كريم / مرهم''}, {v: ''DROPS'', n: ''قطرة''}, {v: ''INHALER'', n: ''بخاخ''}, {v: ''SACHET'', n: ''أكياس''}, {v: ''OTHER'', n: ''أخرى''}];',
'    var alts = [{v: ''SUBSTITUTE'', n: ''بديل''}, {v: ''OEM_EQUIVALENT'', n: ''مكافئ أصلي OEM''}, {v: ''GENERIC_EQUIVALENT'', n: ''مثيل (نفس المادة)''}, {v: ''UPGRADE'', n: ''ترقية''}];',
'    var status = [{v: ''ACTIVE'', n: ''نشط''}, {v: ''INACTIVE'', n: ''موقوف''}, {v: ''DRAFT'', n: ''مسودة''}, {v: ''OBSOLETE'', n: ''متقادم''}];',
'    var cats = L.cats || [], profOf = function (c) { var x = cats.filter(function (k) { return String(k.v) === String(c); })[0]; return x ? x.p : ''GENERAL''; };',
'    var bars = (d.barcodes || []).slice(), fit = (d.fitment || []).slice(), alt = (d.alternates || []).slice();',
'',
'    var h = ''<div class="nn-doc-head"><div class="nn-doc-co">'' + esc(root.dataset.co) + ''</div><div class="nn-doc-title">بطاقة صنف<small>''',
'          + esc(d.id ? ''الرصيد '' + (d.onhand || 0) + '' | متوسط التكلفة '' + (d.avg || 0) : ''صنف جديد'') + ''</small></div>''',
'          + ''<div class="nn-doc-no"><span>رقم الصنف</span><b>'' + esc(d.no || ''تلقائي'') + ''</b></div></div>''',
'          + ''<h3 class="nn-sec">البيانات الأساسية</h3><div class="nn-doc-fields">''',
'          + f(''اسم الصنف *'', inp(''name'', d.name), ''is-wide'') + f(''الاسم بالإنجليزية'', inp(''nameEn'', d.nameEn))',
'          + f(''رقم الصنف (يترك فارغاً للترقيم الآلي)'', inp(''no'', d.no)) + f(''الكود / الرمز المختصر'', inp(''code'', d.code))',
'          + f(''نوع الصنف'', sel(''type'', types, d.type || ''STOCK'')) + f(''الفئة'', sel(''cat'', cats, d.cat, ''- اختر -''))',
'          + f(''وحدة القياس'', sel(''uom'', L.uoms || [], d.uom)) + f(''الحالة'', sel(''status'', status, d.status || ''ACTIVE''))',
'          + f(''تتبع الدفعات'', sel(''tracking'', [{v: ''NONE'', n: ''بدون''}, {v: ''LOT'', n: ''برقم الدفعة''}], d.tracking || ''NONE''), ''nn-it-trk'')',
'          + f(''تتبع تاريخ الانتهاء'', sel(''expiry'', yn, d.expiry || ''N''), ''nn-it-trk'') + f(''العلامة التجارية'', inp(''brand'', d.brand))',
'          + f(''صلاحية الصنف بالأيام'', inp(''shelf'', d.shelf, ''number''), ''nn-it-trk'') + ''</div>''',
'          + ''<h3 class="nn-sec">الباركود</h3><div class="nn-it-bars"></div>''',
'          + ''<div class="nn-it-baradd"><input class="nn-it-bar" placeholder="امسح أو اكتب باركود ثم Enter"><button type="button" class="t-Button nn-it-gen">توليد باركود داخلي</button></div>''',
'          + ''<h3 class="nn-sec">الأسعار والضريبة والربط</h3><div class="nn-doc-fields">''',
'          + f(''سعر البيع'', inp(''price'', d.price, ''number'')) + f(''السعر شامل الضريبة'', sel(''incl'', yn, d.incl || ''N''))',
'          + f(''الحد الأدنى لسعر البيع'', inp(''minPrice'', d.minPrice, ''number'')) + f(''ضريبة المبيعات'', sel(''tax'', L.taxes || [], d.tax || ''VAT15''))',
'          + f(''ضريبة المشتريات'', sel(''ptax'', L.taxes || [], d.ptax || d.tax || ''VAT15'')) + f(''التكلفة المعيارية'', inp(''cost'', d.cost, ''number''))',
'          + f(''مركز التكلفة الافتراضي'', sel(''cc'', L.ccs || [], d.cc, ''- من المستودع -'')) + f(''المستودع الافتراضي'', sel(''wh'', L.whs || [], d.wh, ''- الرئيسي -''))',
'          + f(''الحد الأدنى للمخزون'', inp(''min'', d.min, ''number'')) + f(''الحد الأعلى'', inp(''max'', d.max, ''number'')) + f(''كمية إعادة الطلب'', inp(''reorder'', d.reorder, ''number''))',
'          + ''</div>''',
'          + ''<div class="nn-it-auto"><h3 class="nn-sec">قطع غيار السيارات</h3><div class="nn-doc-fields">''',
'          + f(''رقم القطعة الأصلي OEM'', inp(''mpn'', d.mpn)) + f(''الشركة المصنعة'', inp(''mfr'', d.mfr)) + ''</div>''',
'          + ''<h4>التوافق مع المركبات</h4><table class="nn-td-table nn-it-fit"><thead><tr><th>الشركة</th><th>الطراز</th><th>من سنة</th><th>إلى سنة</th><th>المحرك</th><th></th></tr></thead><tbody></tbody></table>''',
'          + ''<button type="button" class="t-Button nn-it-addfit">إضافة مركبة</button>''',
'          + ''<h4>البدائل</h4><table class="nn-td-table nn-it-alt"><thead><tr><th>رقم الصنف / الكود / OEM للبديل</th><th>نوع البدل</th><th></th></tr></thead><tbody></tbody></table>''',
'          + ''<button type="button" class="t-Button nn-it-addalt">إضافة بديل</button></div>''',
'          + ''<div class="nn-it-pharma"><h3 class="nn-sec">الأدوية والمستحضرات</h3><div class="nn-doc-fields">''',
'          + f(''المادة الفعالة (الاسم العلمي)'', inp(''generic'', d.generic)) + f(''التركيز'', inp(''strength'', d.strength, ''text'', ''500mg''))',
'          + f(''الشكل الصيدلاني'', sel(''form'', forms, d.form, ''-'')) + f(''يصرف بوصفة طبية'', sel(''rx'', yn, d.rx || ''N''))',
'          + f(''رقم التسجيل (الهيئة العامة للغذاء والدواء)'', inp(''reg'', d.reg)) + ''</div>''',
'          + ''<p class="nn-hint">الأدوية تتبع بالدفعات وتاريخ الانتهاء إلزامياً؛ لا تباع دفعة منتهية، ويصرف الأقرب انتهاءً أولاً.</p></div>''',
'          + ''<div class="nn-doc-foot"><div class="nn-doc-msg" role="alert"></div><div class="nn-doc-actions">''',
'          + ''<button type="button" class="t-Button t-Button--hot nn-it-save">حفظ الصنف</button></div></div>'';',
'    root.innerHTML = h;',
'    var q = function (k) { return root.querySelector(''[data-k="'' + k + ''"]''); };',
'',
'    function drawBars() {',
'        root.querySelector(''.nn-it-bars'').innerHTML = bars.length ? bars.map(function (b, i) {',
'            return ''<span class="nn-chip">'' + esc(b) + ''<button type="button" data-bar="'' + i + ''" aria-label="حذف">×</button></span>''; }).join('''')',
'            : ''<em class="nn-hint">لا يوجد باركود؛ يمكن البيع برقم الصنف أو الكود</em>'';',
'    }',
'    function drawFit() {',
'        root.querySelector(''.nn-it-fit tbody'').innerHTML = fit.map(function (r, i) {',
'            return ''<tr>'' + [''make'', ''model'', ''from'', ''to'', ''engine''].map(function (k) {',
'                return ''<td><input data-fit="'' + i + ''" data-c="'' + k + ''" value="'' + esc(r[k]) + ''"'' + (k === ''from'' || k === ''to'' ? '' type="number"'' : '''') + ''></td>''; }).join('''')',
'                + ''<td><button type="button" class="nn-td-del" data-delfit="'' + i + ''">×</button></td></tr>''; }).join('''');',
'    }',
'    function drawAlt() {',
'        root.querySelector(''.nn-it-alt tbody'').innerHTML = alt.map(function (r, i) {',
'            return ''<tr><td><input data-alt="'' + i + ''" data-c="no" value="'' + esc(r.no) + ''"></td><td><select data-alt="'' + i + ''" data-c="type">''',
'                 + alts.map(function (a) { return opt(a.v, a.n, r.type || ''SUBSTITUTE''); }).join('''') + ''</select></td>''',
'                 + ''<td><button type="button" class="nn-td-del" data-delalt="'' + i + ''">×</button></td></tr>''; }).join('''');',
'    }',
'    function sync() {',
'        var p = profOf(q(''cat'').value || d.cat), t = q(''type'').value;',
'        root.querySelector(''.nn-it-auto'').style.display = (p === ''AUTO_PART'' || t === ''SPARE_PART'') ? '''' : ''none'';',
'        root.querySelector(''.nn-it-pharma'').style.display = p === ''PHARMA'' ? '''' : ''none'';',
'        root.querySelectorAll(''.nn-it-trk'').forEach(function (el) { el.style.display = p === ''PHARMA'' || t === ''SERVICE'' ? ''none'' : ''''; });',
'    }',
'    drawBars(); drawFit(); drawAlt(); sync();',
'    root.addEventListener(''change'', function (e) { if (e.target.dataset.k === ''cat'' || e.target.dataset.k === ''type'') sync(); });',
'    root.addEventListener(''input'', function (e) {',
'        var t = e.target;',
'        if (t.dataset.fit != null) fit[+t.dataset.fit][t.dataset.c] = t.value;',
'        if (t.dataset.alt != null) alt[+t.dataset.alt][t.dataset.c] = t.value;',
'    });',
'    var bar = root.querySelector(''.nn-it-bar'');',
'    bar.addEventListener(''keydown'', function (e) {',
'        if (e.key !== ''Enter'') return;',
'        e.preventDefault();',
'        var v = bar.value.trim();',
'        if (v && bars.indexOf(v) < 0) bars.push(v);',
'        bar.value = ''''; drawBars();',
'    });',
'    root.addEventListener(''click'', function (e) {',
'        var t = e.target;',
'        if (t.dataset.bar != null) { bars.splice(+t.dataset.bar, 1); drawBars(); return; }',
'        if (t.dataset.delfit != null) { fit.splice(+t.dataset.delfit, 1); drawFit(); return; }',
'        if (t.dataset.delalt != null) { alt.splice(+t.dataset.delalt, 1); drawAlt(); return; }',
'        if (t.closest(''.nn-it-addfit'')) { fit.push({make: '''', model: ''''}); drawFit(); return; }',
'        if (t.closest(''.nn-it-addalt'')) { alt.push({no: '''', type: ''SUBSTITUTE''}); drawAlt(); return; }',
'        if (t.closest(''.nn-it-gen'')) {',
'            // باركود داخلي EAN-13 يبدأ بـ 20 (نطاق الاستخدام الداخلي) مع رقم التحقق',
'            var s = ''20'' + String(Date.now()).slice(-10), sum = 0;',
'            for (var i = 0; i < 12; i++) sum += (+s[i]) * (i % 2 ? 3 : 1);',
'            s += (10 - sum % 10) % 10;',
'            if (bars.indexOf(s) < 0) bars.push(s);',
'            drawBars(); return;',
'        }',
'        if (!t.closest(''.nn-it-save'')) return;',
'        var doc = {id: d.id || null, barcodes: bars, fitment: fit.filter(function (r) { return r.make; }), alternates: alt.filter(function (r) { return r.no; })};',
'        root.querySelectorAll(''[data-k]'').forEach(function (el) {',
'            var v = el.value === '''' ? null : el.value;',
'            doc[el.dataset.k] = v != null && (el.type === ''number'' || /^(cat|uom|cc|wh)$/.test(el.dataset.k)) ? parseFloat(v) : v;',
'        });',
'        fit.forEach(function (r) { r.from = r.from ? +r.from : null; r.to = r.to ? +r.to : null; });',
'        var msg = root.querySelector(''.nn-doc-msg''), btn = root.querySelector(''.nn-it-save'');',
'        msg.className = ''nn-doc-msg''; msg.textContent = ''جار الحفظ...''; btn.disabled = true;',
'        apex.server.process(''SAVE_DOC'', {p_clob_01: JSON.stringify(doc)}, {dataType: ''json''}).done(function (r) {',
'            if (r && r.ok) { msg.className = ''nn-doc-msg is-ok''; msg.textContent = ''تم حفظ الصنف''; window.location.href = r.url; }',
'            else { msg.className = ''nn-doc-msg is-bad''; msg.textContent = (r && r.msg) || ''تعذر الحفظ''; btn.disabled = false; }',
'        }).fail(function () { msg.className = ''nn-doc-msg is-bad''; msg.textContent = ''تعذر الاتصال بالخادم''; btn.disabled = false; });',
'    });',
'})();'))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000052)
,p_plug_name=>'الصنف'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000053)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820268000000052)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000054)
,p_plug_name=>'بطاقة الصنف'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_ro varchar2(1) := ''N'';',
'    function js(p clob) return clob is begin return replace(p, ''</'', ''<\/''); end;',
'begin',
'    return ''<script type="application/json" id="nnItemData">'' || js(noona_inv_pkg.item_json(:P11_ID)) || ''</script>''',
'        || ''<script type="application/json" id="nnTdConf">'' || js(q''~{}~'') || ''</script>''',
'        || ''<script type="application/json" id="nnTdLists">'' || js(noona_inv_pkg.lists_json(''cats,uoms,taxes,whs,ccs'')) || ''</script>''',
'        || ''<div id="nnItem" class="nn-doc nn-td" data-ro="'' || l_ro || ''" data-co="''',
'        || apex_escape.html_attribute(noona_apex_pkg.company_name) || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820268000000055)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SAVE_DOC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'begin',
'    l_id := noona_inv_pkg.save_item(apex_application.g_clob_01);',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    apex_json.write(''url'', apex_page.get_url(p_page => 11, p_clear_cache => ''11'', p_items => ''P11_ID'', p_values => l_id));',
'    apex_json.close_object;',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820268000000055
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000056)
,p_plug_name=>'الرصيد حسب المستودع والدفعة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select w.code || '' - '' || w.name_ar as warehouse, l.lot_no, to_char(l.expiry_date, ''YYYY-MM-DD'') as expiry_date, o.on_hand_qty',
'  from inv_onhand o join inv_warehouse w on w.id = o.warehouse_id left join inv_lot l on l.id = o.lot_id',
' where o.item_id = :P11_ID and o.company_id = noona_inv_pkg.company and o.on_hand_qty <> 0 order by l.expiry_date nulls last'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الرصيد حسب المستودع والدفعة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820268000000057)
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
,p_internal_uid=>91820268000000057
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000059)
,p_db_column_name=>'WAREHOUSE'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'المستودع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000060)
,p_db_column_name=>'LOT_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الدفعة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000061)
,p_db_column_name=>'EXPIRY_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الانتهاء'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820268000000062)
,p_db_column_name=>'ON_HAND_QTY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820268000000058)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'58'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'WAREHOUSE:LOT_NO:EXPIRY_DATE:ON_HAND_QTY'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000063)
,p_plug_name=>'بطاقة الحركة (آخر 90 يوماً)'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P11_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_inv_pkg.item_card(:P11_ID, trunc(sysdate) - 90, trunc(sysdate));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
