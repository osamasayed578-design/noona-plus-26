prompt --application/pages/page_00042
begin
--   Manifest
--     PAGE: 00042
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
 p_id=>42
,p_name=>'Voucher'
,p_alias=>'VOUCHER'
,p_step_title=>'سند'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// المستند الورقي (قيد يومية أو سند): رأس وتذييل يبنيان من JSON مضمن؛ السطور في nnJe (شبكة GRID_JS)؛',
'// الحفظ والإرسال: كائن JSON واحد (رأس + سطور) بعملية AJAX واحدة SAVE_DOC دون إعادة تحميل الصفحة عند الخطأ',
'(function () {',
'    var root = document.getElementById(''nnDoc''); if (!root) return;',
'    var data = function (id) { var el = document.getElementById(id); try { return JSON.parse(el ? el.textContent : ''null''); } catch (e) { return null; } };',
'    var d = data(''nnDocData'') || {}, curs = data(''nnDocCurs'') || [], places = data(''nnDocPlaces'') || [];',
'    var je = root.dataset.kind === ''JE'', ro = root.dataset.ro === ''Y'', fc = root.dataset.fc;',
'    var esc = function (s) { return String(s == null ? '''' : s).replace(/[&<>"]/g, function (c) { return {''&'': ''&amp;'', ''<'': ''&lt;'', ''>'': ''&gt;'', ''"'': ''&quot;''}[c]; }); };',
'    var titles = {RECEIPT: ''سند قبض'', PAYMENT: ''سند صرف'', EXPENSE: ''سند مصروفات''};',
'    var stl = {DRAFT: ''مسودة'', SUBMITTED: ''بانتظار الاعتماد'', APPROVED: ''معتمد'', POSTED: ''مرحل'', SETTLED: ''مرحل'', REVERSED: ''معكوس'', CANCELLED: ''ملغى''};',
'    var title = je ? ''قيد يومية'' : (titles[d.type] || ''سند'');',
'    var rateOf = function (c) { if (!c || c === fc) return 1; var x = curs.filter(function (k) { return k.c === c; })[0]; return x ? x.r : null; };',
'    var placeOf = function (v) { return places.filter(function (p) { return p.v === v; })[0] || null; };',
'    var opt = function (v, t, sel) { return ''<option value="'' + esc(v) + ''"'' + (String(v) === String(sel == null ? '''' : sel) ? '' selected'' : '''') + ''>'' + esc(t) + ''</option>''; };',
'    var field = function (cls, label, input, wide) { return ''<label class="nn-doc-f '' + cls + (wide ? '' is-wide'' : '''') + ''"><span>'' + label + ''</span>'' + input + ''</label>''; };',
'    var inp = function (k, v, type, extra) {',
'        return ro ? ''<b class="nn-doc-v">'' + esc(v) + ''</b>''',
'                  : ''<input data-k="'' + k + ''" type="'' + (type || ''text'') + ''" value="'' + esc(v) + ''"'' + (extra || '''') + ''>'';',
'    };',
'    var h = ''<div class="nn-doc-head"><div class="nn-doc-co">'' + esc(root.dataset.co) + ''</div>''',
'          + ''<div class="nn-doc-title">'' + title + ''<small>'' + esc(stl[d.status] || d.status || '''') + ''</small></div>''',
'          + ''<div class="nn-doc-no"><span>الرقم</span><b>'' + esc(d.no || ''جديد'') + ''</b></div></div><div class="nn-doc-fields">'';',
'    h += field('''', ''التاريخ'', inp(''date'', d.date, ''date''));',
'    if (je) {',
'        var cs = ro ? ''<b class="nn-doc-v">'' + esc(d.cur) + ''</b>''',
'                    : ''<select data-k="cur">'' + curs.map(function (c) { return opt(c.c, c.c + '' - '' + c.n, d.cur); }).join('''') + ''</select>'';',
'        h += field('''', ''العملة'', cs) + field(''nn-doc-rate'', ''سعر الصرف'', inp(''rate'', d.rate, ''number'', '' step="0.000001" min="0"''));',
'        h += field('''', ''المرجع'', inp(''ref'', d.ref)) + field('''', ''البيان'', inp(''desc'', d.desc), true);',
'    } else {',
'        var ps = ro ? ''<b class="nn-doc-v">'' + esc((placeOf(d.place) || {}).n || '''') + ''</b>''',
'                    : ''<select data-k="place">'' + places.map(function (p) {',
'                          return opt(p.v, (p.k === ''BOX'' ? ''صندوق: '' : ''بنك: '') + p.n + '' ('' + p.c + '')'', d.place); }).join('''') + ''</select>'';',
'        var chs = [[''BANK_TRANSFER'', ''تحويل بنكي''], [''CHEQUE'', ''شيك''], [''CARD'', ''بطاقة''], [''WALLET'', ''محفظة إلكترونية''], [''GATEWAY'', ''بوابة دفع''], [''DIRECT_DEBIT'', ''خصم مباشر'']];',
'        var ch = ro ? ''<b class="nn-doc-v">'' + esc((chs.filter(function (c) { return c[0] === d.channel; })[0] || ['''', ''نقداً''])[1]) + ''</b>''',
'                    : ''<select data-k="channel">'' + chs.map(function (c) { return opt(c[0], c[1], d.channel); }).join('''') + ''</select>'';',
'        h += field('''', d.type === ''RECEIPT'' ? ''الصندوق / البنك المستلم'' : ''الصرف من'', ps) + field(''nn-doc-ch'', ''طريقة الدفع'', ch);',
'        h += field('''', d.type === ''RECEIPT'' ? ''استلمنا من السيد/السادة'' : ''صرفنا إلى السيد/السادة'', inp(''party'', d.party), true);',
'        h += field('''', ''المرجع (شيك / حوالة / فاتورة)'', inp(''ref'', d.ref))',
'           + field(''nn-doc-rate'', ''سعر الصرف'', inp(''rate'', d.rate, ''number'', '' step="0.000001" min="0"''));',
'        h += field('''', ''وذلك عن'', inp(''desc'', d.desc), true);',
'    }',
'    h += ''</div><div id="nnJe" class="nn-je" data-kind="'' + (je ? ''JE'' : ''CV'') + ''" data-readonly="'' + (ro ? ''Y'' : ''N'') + ''"></div>'';',
'    h += ''<div class="nn-doc-foot">''',
'       + (je ? '''' : ''<div class="nn-doc-total"><span>المبلغ</span><b id="nnCvTotal"></b><em>'' + esc(d.cur || '''') + ''</em></div>'')',
'       + (d.words ? ''<div class="nn-words">'' + esc(d.words) + ''</div>'' : '''')',
'       + ''<div class="nn-doc-msg" role="alert"></div>''',
'       + (ro ? '''' : ''<div class="nn-doc-actions"><button type="button" class="t-Button nn-doc-save" data-a="SAVE">حفظ</button>''',
'                  + ''<button type="button" class="t-Button t-Button--hot nn-doc-save" data-a="SUBMIT">حفظ وإرسال للاعتماد</button></div>'')',
'       + ''</div>'';',
'    root.innerHTML = h;',
'    var lines = document.getElementById(''nnJeLines'');',
'    if (!lines) { lines = document.createElement(''script''); lines.type = ''application/json''; lines.id = ''nnJeLines''; document.body.appendChild(lines); }',
'    lines.textContent = JSON.stringify(d.lines || []);',
'    var q = function (k) { return root.querySelector(''[data-k="'' + k + ''"]''); };',
'    function syncRate(force) {',
'        var place = (q(''place'') || {}).value || d.place || '''';',
'        var c = je ? ((q(''cur'') || {}).value || d.cur) : ((placeOf(place) || {}).c || d.cur || fc);',
'        var box = root.querySelector(''.nn-doc-rate'');',
'        if (box) box.style.display = c === fc ? ''none'' : '''';',
'        var r = q(''rate'');',
'        if (r) {',
'            if (c === fc) { r.value = ''''; }',
'            else if (force || !r.value) { var v = rateOf(c); r.value = v == null ? '''' : v; r.placeholder = v == null ? ''لا يوجد سعر معتمد - أدخله'' : ''''; }',
'        }',
'        var chb = root.querySelector(''.nn-doc-ch'');',
'        if (chb && !je) chb.style.display = place.indexOf(''BANK:'') === 0 ? '''' : ''none'';',
'        var cur = root.querySelector(''.nn-doc-total em''); if (cur) cur.textContent = c;',
'    }',
'    syncRate(false);',
'    if (ro) return;',
'    root.addEventListener(''change'', function (e) { if (e.target.dataset.k === ''cur'' || e.target.dataset.k === ''place'') syncRate(true); });',
'    root.addEventListener(''click'', function (e) {',
'        var b = e.target.closest(''.nn-doc-save''); if (!b) return;',
'        var doc = {id: d.id || null, action: b.dataset.a, lines: window.nnGrid ? window.nnGrid.collect() : []};',
'        root.querySelectorAll(''[data-k]'').forEach(function (el) { doc[el.dataset.k] = el.value === '''' ? null : el.value; });',
'        if (doc.rate != null) doc.rate = parseFloat(doc.rate);',
'        if (!je) doc.type = d.type;',
'        var msg = root.querySelector(''.nn-doc-msg''), btns = root.querySelectorAll(''.nn-doc-save'');',
'        var fail = function (t) { msg.className = ''nn-doc-msg is-bad''; msg.textContent = t; btns.forEach(function (x) { x.disabled = false; }); };',
'        msg.className = ''nn-doc-msg''; msg.textContent = ''جار الحفظ...'';',
'        btns.forEach(function (x) { x.disabled = true; });',
'        apex.server.process(''SAVE_DOC'', {p_clob_01: JSON.stringify(doc)}, {dataType: ''json''}).done(function (r) {',
'            if (r && r.ok) {',
'                msg.className = ''nn-doc-msg is-ok''; msg.textContent = b.dataset.a === ''SUBMIT'' ? ''تم الحفظ والإرسال للاعتماد'' : ''تم الحفظ'';',
'                window.location.href = r.url;',
'            } else { fail((r && r.msg) || ''تعذر الحفظ''); }',
'        }).fail(function () { fail(''تعذر الاتصال بالخادم''); });',
'    });',
'})();',
'// شبكة السطور: بحث الحساب بالرمز أو الاسم، مركز التكلفة، مجاميع مباشرة، Enter في آخر سطر يضيف سطراً',
'(function () {',
'    var box = document.getElementById(''nnJe''); if (!box) return;',
'    var ro = box.dataset.readonly === ''Y'', je = box.dataset.kind !== ''CV'', item = box.dataset.item;',
'    var data = function (id) { var el = document.getElementById(id); try { return JSON.parse(el ? el.textContent : ''[]'') || []; } catch (e) { return []; } };',
'    var lines = data(''nnJeLines''), accts = data(''nnJeAccts''), ccs = data(''nnJeCcs'');',
'    var names = {}, rules = {}, ccName = {};',
'    accts.forEach(function (a) { names[a.a] = a.n; rules[a.a] = a.r; });',
'    ccs.forEach(function (c) { ccName[c.id] = c.n; });',
'    var fmt = function (n) { return (Math.round((n || 0) * 100) / 100).toLocaleString(''en-US'', {minimumFractionDigits: 2}); };',
'    var esc = function (s) { return String(s == null ? '''' : s).replace(/[&<>"]/g, function (c) { return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;''}[c]; }); };',
'    var ccOpts = function (v) { return ''<option value="">-</option>'' + ccs.map(function (c) {',
'        return ''<option value="'' + c.id + ''"'' + (String(c.id) === String(v || '''') ? '' selected'' : '''') + ''>'' + esc(c.n) + ''</option>''; }).join(''''); };',
'    var amtHead = je ? ''<th>مدين</th><th>دائن</th>'' : ''<th>المبلغ</th>'';',
'    var html = ''<table class="nn-je-table"><thead><tr><th>#</th><th>الحساب</th>'' + amtHead + ''<th>مركز التكلفة</th><th>البيان</th>'' + (ro ? '''' : ''<th></th>'') + ''</tr></thead><tbody></tbody>''',
'        + ''<tfoot><tr><td></td><td>الإجمالي <span class="nn-je-diff"></span></td>'' + (je ? ''<td class="nn-je-tdr"></td><td class="nn-je-tcr"></td>'' : ''<td class="nn-je-tdr"></td>'')',
'        + ''<td colspan="'' + (ro ? 2 : 3) + ''"></td></tr></tfoot></table>''',
'        + (ro ? '''' : ''<datalist id="nnAccts">'' + accts.map(function (a) { return ''<option value="'' + esc(a.a) + ''">'' + esc(a.a + '' - '' + a.n) + ''</option>''; }).join('''') + ''</datalist>''',
'        + ''<button type="button" class="t-Button t-Button--small nn-je-add"><span class="fa fa-plus" aria-hidden="true"></span> إضافة سطر</button>'');',
'    box.innerHTML = html;',
'    var tbody = box.querySelector(''tbody'');',
'    var num = function (tr, cls, key) { var el = tr.querySelector(cls); return parseFloat(el ? el.value : tr.dataset[key]) || 0; };',
'    function totals() {',
'        var dr = 0, cr = 0;',
'        tbody.querySelectorAll(''tr'').forEach(function (tr) {',
'            if (je) { dr += num(tr, ''.nn-je-dr'', ''d''); cr += num(tr, ''.nn-je-cr'', ''c''); } else { dr += num(tr, ''.nn-je-amt'', ''m''); }',
'            if (!ro) {',
'                var a = tr.querySelector(''.nn-je-acc'').value.trim(), cc = tr.querySelector(''.nn-je-cc'');',
'                cc.classList.toggle(''is-required'', rules[a] === ''REQUIRED'' && !cc.value);',
'                cc.disabled = rules[a] === ''FORBIDDEN''; if (cc.disabled) cc.value = '''';',
'            }',
'        });',
'        box.querySelector(''.nn-je-tdr'').textContent = fmt(dr);',
'        var d = box.querySelector(''.nn-je-diff'');',
'        if (je) {',
'            box.querySelector(''.nn-je-tcr'').textContent = fmt(cr);',
'            var diff = Math.round((dr - cr) * 100) / 100;',
'            d.textContent = diff === 0 ? (dr > 0 ? ''✓ متوازن'' : '''') : ''(الفرق '' + fmt(Math.abs(diff)) + '')'';',
'            d.className = ''nn-je-diff '' + (diff === 0 ? ''is-ok'' : ''is-bad'');',
'        }',
'        var t = document.getElementById(''nnCvTotal''); if (t) t.textContent = fmt(dr);',
'    }',
'    function addRow(l) {',
'        l = l || {}; var tr = document.createElement(''tr''); var n = tbody.children.length + 1;',
'        if (ro) {',
'            tr.dataset.d = l.d || 0; tr.dataset.c = l.c || 0; tr.dataset.m = l.m || 0;',
'            tr.innerHTML = ''<td>'' + n + ''</td><td>'' + esc(l.a) + '' - '' + esc(names[l.a] || '''') + ''</td>''',
'                + (je ? ''<td>'' + (l.d ? fmt(l.d) : '''') + ''</td><td>'' + (l.c ? fmt(l.c) : '''') + ''</td>'' : ''<td>'' + fmt(l.m) + ''</td>'')',
'                + ''<td>'' + esc(ccName[l.cc] || '''') + ''</td><td>'' + esc(l.t) + ''</td>'';',
'        } else {',
'            var amt = je ? ''<td><input class="nn-je-dr" type="number" step="0.01" min="0" value="'' + (l.d || '''') + ''" aria-label="مدين"></td>''',
'                         + ''<td><input class="nn-je-cr" type="number" step="0.01" min="0" value="'' + (l.c || '''') + ''" aria-label="دائن"></td>''',
'                         : ''<td><input class="nn-je-amt" type="number" step="0.01" min="0" value="'' + (l.m || '''') + ''" aria-label="المبلغ"></td>'';',
'            tr.innerHTML = ''<td class="nn-je-no">'' + n + ''</td><td><input class="nn-je-acc" list="nnAccts" value="'' + esc(l.a) + ''" placeholder="رمز أو اسم الحساب" aria-label="الحساب">''',
'                + ''<small class="nn-je-name">'' + esc(names[l.a] || '''') + ''</small></td>'' + amt',
'                + ''<td><select class="nn-je-cc" aria-label="مركز التكلفة">'' + ccOpts(l.cc) + ''</select></td>''',
'                + ''<td><input class="nn-je-txt" value="'' + esc(l.t) + ''" aria-label="البيان"></td>''',
'                + ''<td><button type="button" class="t-Button t-Button--small t-Button--noUI nn-je-del" title="حذف السطر"><span class="fa fa-trash-o" aria-hidden="true"></span></button></td>'';',
'        }',
'        tbody.appendChild(tr); return tr;',
'    }',
'    if (lines.length) { lines.forEach(addRow); } else if (!ro) { addRow(); if (je) addRow(); }',
'    totals();',
'    if (ro) return;',
'    box.addEventListener(''input'', function (e) {',
'        var tr = e.target.closest(''tr''); if (!tr) return;',
'        if (e.target.classList.contains(''nn-je-acc'')) {',
'            var v = e.target.value.trim(), hit = names[v] ? v : null;',
'            if (!hit) { accts.some(function (a) { if (a.n === v) { hit = a.a; return true; } }); if (hit) e.target.value = hit; }',
'            tr.querySelector(''.nn-je-name'').textContent = hit ? names[hit] : '''';',
'        }',
'        if (e.target.classList.contains(''nn-je-dr'') && e.target.value) tr.querySelector(''.nn-je-cr'').value = '''';',
'        if (e.target.classList.contains(''nn-je-cr'') && e.target.value) tr.querySelector(''.nn-je-dr'').value = '''';',
'        totals();',
'    });',
'    box.addEventListener(''change'', totals);',
'    box.addEventListener(''click'', function (e) {',
'        if (e.target.closest(''.nn-je-add'')) { addRow().querySelector(''.nn-je-acc'').focus(); }',
'        if (e.target.closest(''.nn-je-del'')) { e.target.closest(''tr'').remove();',
'            tbody.querySelectorAll(''.nn-je-no'').forEach(function (td, i) { td.textContent = i + 1; }); totals(); }',
'    });',
'    box.addEventListener(''keydown'', function (e) {',
'        if (e.key === ''Enter'' && e.target.tagName === ''INPUT'') { e.preventDefault();',
'            var tr = e.target.closest(''tr'');',
'            if (!tr.nextElementSibling) addRow().querySelector(''.nn-je-acc'').focus(); else tr.nextElementSibling.querySelector(''.nn-je-acc'').focus(); }',
'    });',
'    function collect() {',
'        var out = [];',
'        tbody.querySelectorAll(''tr'').forEach(function (tr) {',
'            var a = tr.querySelector(''.nn-je-acc'').value.trim(), t = tr.querySelector(''.nn-je-txt'').value.trim(),',
'                cc = parseInt(tr.querySelector(''.nn-je-cc'').value, 10) || null;',
'            if (je) {',
'                var d = parseFloat(tr.querySelector(''.nn-je-dr'').value) || null, c = parseFloat(tr.querySelector(''.nn-je-cr'').value) || null;',
'                if (a || d || c) out.push({a: a, d: d, c: c, cc: cc, t: t || null});',
'            } else {',
'                var m = parseFloat(tr.querySelector(''.nn-je-amt'').value) || null;',
'                if (a || m) out.push({a: a, m: m, cc: cc, t: t || null});',
'            }',
'        });',
'        return out;',
'    }',
'    window.nnGrid = {collect: collect, totals: totals};',
'    if (item) $(document).on(''apexbeforepagesubmit'', function () { $s(item, JSON.stringify(collect())); });',
'})();'))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000225)
,p_plug_name=>'السند'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000226)
,p_name=>'P42_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000227)
,p_name=>'P42_STATUS'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000228)
,p_name=>'P42_TYPE'
,p_item_sequence=>3
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000229)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Voucher'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P42_ID is not null then',
'    select status_code, txn_type into :P42_STATUS, :P42_TYPE from csh_transaction',
'     where id = :P42_ID and company_id = noona_gl_pkg.company;',
'else',
'    :P42_TYPE := case when :P42_TYPE in (''RECEIPT'', ''PAYMENT'', ''EXPENSE'') then :P42_TYPE else ''RECEIPT'' end;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000229
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000230)
,p_plug_name=>'ملخص السند'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P42_ID is not null and :P42_STATUS <> ''DRAFT'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_csh_pkg.voucher_header(:P42_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000231)
,p_plug_name=>'مستند السند'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_ro varchar2(1) := case when :P42_ID is null or :P42_STATUS = ''DRAFT'' then ''N'' else ''Y'' end;',
'    function js(p clob) return clob is begin return replace(p, ''</'', ''<\/''); end;',
'begin',
'    return ''<!-- nn-doc -->''',
'        || ''<script type="application/json" id="nnDocData">'' || js(noona_csh_pkg.voucher_doc_json(:P42_ID, :P42_TYPE)) || ''</script>''',
'        || case when l_ro = ''N'' then ''<script type="application/json" id="nnJeAccts">'' || js(noona_csh_pkg.accounts_json(:P42_TYPE)) || ''</script>'' end',
'        || ''<script type="application/json" id="nnJeCcs">'' || js(noona_gl_pkg.cost_centers_json) || ''</script>''',
'        || ''<script type="application/json" id="nnDocCurs">'' || js(noona_gl_pkg.currencies_json) || ''</script>''',
'        || ''<script type="application/json" id="nnDocPlaces">'' || js(noona_csh_pkg.places_json) || ''</script>''',
'        || ''<div id="nnDoc" class="nn-doc" data-kind="CV" data-ro="'' || l_ro || ''" data-co="''',
'        || apex_escape.html_attribute(noona_apex_pkg.company_name) || ''" data-fc="'' || noona_gl_pkg.ledger_currency || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000232)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SAVE_DOC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'begin',
'    l_id := noona_csh_pkg.save_voucher_doc(apex_application.g_clob_01);',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    apex_json.write(''url'', apex_page.get_url(p_page => 42, p_clear_cache => ''42'', p_items => ''P42_ID'', p_values => l_id));',
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
,p_internal_uid=>91820266000000232
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000233)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P42_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000234)
,p_name=>'P42_REASON'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000233)
,p_prompt=>'الملاحظة أو السبب (إلزامي للرفض والعكس)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000235)
,p_name=>'P42_REV_DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000233)
,p_prompt=>'تاريخ العكس'
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
 p_id=>wwv_flow_imp.id(91820266000000236)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000233)
,p_button_name=>'APPROVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد وترحيل'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_STATUS = ''SUBMITTED'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000237)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000233)
,p_button_name=>'REJECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض وإعادة للمنشئ'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_STATUS = ''SUBMITTED'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000238)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820266000000233)
,p_button_name=>'REVERSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عكس السند'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_STATUS = ''SETTLED'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000239)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820266000000233)
,p_button_name=>'CANCEL_VOUCHER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء المسودة'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_STATUS = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000240)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820266000000233)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة السند'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:43:&SESSION.::&DEBUG.:RP,43:P43_ID:&P42_ID.'
,p_button_condition=>':P42_STATUS in (''SETTLED'', ''REVERSED'', ''SUBMITTED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000241)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820266000000233)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000242)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_csh_pkg.approve_voucher(:P42_ID, :P42_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000236)
,p_process_success_message=>'تم اعتماد السند وترحيل قيده'
,p_internal_uid=>91820266000000242
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000243)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_csh_pkg.reject_voucher(:P42_ID, :P42_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000237)
,p_process_success_message=>'تم رفض السند وإعادته للمنشئ'
,p_internal_uid=>91820266000000243
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000244)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reverse'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_csh_pkg.reverse_voucher(:P42_ID, nvl(to_date(:P42_REV_DATE, ''YYYY-MM-DD''), trunc(sysdate)), :P42_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000238)
,p_process_success_message=>'تم عكس السند بقيد مقابل مرحل'
,p_internal_uid=>91820266000000244
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000245)
,p_process_sequence=>70
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_csh_pkg.cancel_voucher(:P42_ID, :P42_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000239)
,p_process_success_message=>'تم إلغاء المسودة'
,p_internal_uid=>91820266000000245
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000246)
,p_branch_action=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:42:P42_ID:&P42_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
