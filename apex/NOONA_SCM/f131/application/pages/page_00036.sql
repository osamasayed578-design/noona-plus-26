prompt --application/pages/page_00036
begin
--   Manifest
--     PAGE: 00036
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
 p_id=>36
,p_name=>'Purchase Return'
,p_alias=>'PURCHASE-RETURN'
,p_step_title=>'مرتجع مشتريات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820268000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// مستند تجاري موحد (فاتورة مشتريات/مبيعات، أمر شراء، مستند مخزون، مرتجع، قائمة مواد):',
'// رأس من إعداد nnTdConf، وسطور أصناف تضاف بالباركود أو البحث (رقم الصنف، الكود، رقم OEM، الاسم، المادة الفعالة)،',
'// حساب الصافي والضريبة لحظياً، والحفظ بطلب AJAX واحد SAVE_DOC (المستند JSON) ثم فتح المستند المحفوظ.',
'(function () {',
'    var root = document.getElementById(''nnTd''); if (!root) return;',
'    var data = function (id) { var el = document.getElementById(id); try { return JSON.parse(el ? el.textContent : ''null''); } catch (e) { return null; } };',
'    var d = data(''nnTdData'') || {}, cf = data(''nnTdConf'') || {}, lists = data(''nnTdLists'') || {};',
'    var ro = root.dataset.ro === ''Y'', kind = cf.kind || ''PI'', ret = kind === ''RET'';',
'    var esc = function (s) { return String(s == null ? '''' : s).replace(/[&<>"]/g, function (c) { return {''&'': ''&amp;'', ''<'': ''&lt;'', ''>'': ''&gt;'', ''"'': ''&quot;''}[c]; }); };',
'    var num = function (v) { var n = parseFloat(v); return isNaN(n) ? 0 : n; };',
'    var money = function (v) { return num(v).toLocaleString(''en-US'', {minimumFractionDigits: 2, maximumFractionDigits: 2}); };',
'    var list = function (o) { return typeof o === ''string'' ? (lists[o] || []) : (o || []); };',
'    var taxes = list(''taxes''), rateOf = function (c) { var t = taxes.filter(function (x) { return x.v === c; })[0]; return t ? num(t.r) : 0; };',
'    var cols = cf.cols || [''q'', ''p'', ''disc'', ''tc''];',
'    var has = function (c) { return cols.indexOf(c) >= 0; };',
'    var stl = {DRAFT: ''مسودة'', APPROVED: ''معتمد'', POSTED: ''مرحل'', PAID: ''مسدد'', PARTIALLY_PAID: ''مسدد جزئياً'', CANCELLED: ''ملغى'',',
'               PARTIALLY_RECEIVED: ''مستلم جزئياً'', RECEIVED: ''مستلم'', CREDITED: ''مرتجع''};',
'    var lines = (d.lines || []).map(function (l) { return Object.assign({}, l); });',
'    // المرتجع: السطور من القابل للإرجاع (المباع، المرتجع سابقاً) والكمية المطلوبة تبدأ صفراً',
'    if (ret) lines = lines.map(function (l) { return {l: l.l, i: l.i, n: l.d, sold: l.q, done: l.r, q: 0, p: l.p}; });',
'    var opt = function (v, t, sel) { return ''<option value="'' + esc(v) + ''"'' + (String(v) === String(sel == null ? '''' : sel) ? '' selected'' : '''') + ''>'' + esc(t) + ''</option>''; };',
'    var labelOf = function (o, v) { var x = list(o).filter(function (e) { return String(e.v) === String(v); })[0]; return x ? x.n : (v == null ? '''' : v); };',
'',
'    // ------------------------------------------------------------ الرأس',
'    function headerField(f) {',
'        var v = d[f.k] == null ? (f.def == null ? '''' : f.def) : d[f.k], inp;',
'        if (ro || f.ro) {',
'            inp = ''<b class="nn-doc-v">'' + esc(f.t === ''select'' ? labelOf(f.o, v) : v) + ''</b>'';',
'        } else if (f.t === ''select'') {',
'            inp = ''<select data-k="'' + f.k + ''">'' + (f.req ? '''' : opt('''', f.ph || ''-'')) + list(f.o).map(function (e) { return opt(e.v, e.n, v); }).join('''') + ''</select>'';',
'        } else if (f.t === ''textarea'') {',
'            inp = ''<textarea data-k="'' + f.k + ''" rows="2">'' + esc(v) + ''</textarea>'';',
'        } else {',
'            inp = ''<input data-k="'' + f.k + ''" type="'' + (f.t || ''text'') + ''" value="'' + esc(v) + ''"'' + (f.t === ''number'' ? '' step="any"'' : '''') + (f.ph ? '' placeholder="'' + esc(f.ph) + ''"'' : '''') + ''>'';',
'        }',
'        return ''<label class="nn-doc-f'' + (f.w ? '' is-wide'' : '''') + ''" data-f="'' + f.k + ''"'' + (f.show ? '' data-show="'' + esc(f.show) + ''"'' : '''') + ''><span>'' + esc(f.l) + (f.req && !ro ? '' *'' : '''') + ''</span>'' + inp + ''</label>'';',
'    }',
'    var h = ''<div class="nn-doc-head"><div class="nn-doc-co">'' + esc(root.dataset.co) + ''</div>''',
'          + ''<div class="nn-doc-title">'' + esc(d.title || cf.title || '''') + ''<small>'' + esc(stl[d.status] || d.status || '''') + ''</small></div>''',
'          + ''<div class="nn-doc-no"><span>الرقم</span><b>'' + esc(d.no || ''جديد'') + ''</b></div></div>''',
'          + ''<div class="nn-doc-fields">'' + (cf.header || []).map(headerField).join('''') + ''</div>'';',
'    if (!ro && !ret && cf.search !== false) {',
'        h += ''<div class="nn-td-scan"><span class="fa fa-barcode" aria-hidden="true"></span>''',
'           + ''<input type="search" class="nn-td-find" placeholder="امسح الباركود أو اكتب رقم الصنف / الكود / رقم القطعة / الاسم / المادة الفعالة ثم Enter" autocomplete="off">''',
'           + (cf.free ? ''<button type="button" class="t-Button nn-td-free">بند بدون صنف (خدمة / مصروف)</button>'' : '''')',
'           + (cf.promo ? ''<input class="nn-td-coupon" placeholder="كوبون" autocomplete="off"><button type="button" class="t-Button nn-td-promo">''',
'                       + ''<span class="fa fa-percent" aria-hidden="true"></span> تطبيق العروض</button>'' : '''')',
'           + ''<div class="nn-td-results" hidden></div></div>'';',
'    }',
'    h += ''<div class="nn-td-wrap"><table class="nn-td-table"><thead></thead><tbody></tbody><tfoot></tfoot></table></div>''',
'       + ''<div class="nn-doc-foot"><div class="nn-td-totals"></div><div class="nn-doc-msg" role="alert"></div>''',
'       + (ro ? '''' : ''<div class="nn-doc-actions">'' + (cf.actions || []).map(function (a) {',
'             return ''<button type="button" class="t-Button nn-doc-save'' + (a.hot ? '' t-Button--hot'' : '''') + ''" data-a="'' + a.a + ''"'' + (a.confirm ? '' data-confirm="'' + esc(a.confirm) + ''"'' : '''') + ''>'' + esc(a.n) + ''</button>''; }).join('''') + ''</div>'')',
'       + ''</div>'';',
'    root.innerHTML = h;',
'    var tb = root.querySelector(''tbody''), th = root.querySelector(''thead''), tf = root.querySelector(''tfoot'');',
'    var q = function (k) { return root.querySelector(''[data-k="'' + k + ''"]''); };',
'    var val = function (k) { var e = q(k); return e ? e.value : d[k]; };',
'',
'    // إظهار الحقول المشروطة (مثال: الصندوق للفاتورة النقدية فقط)',
'    function syncShow() {',
'        root.querySelectorAll(''[data-show]'').forEach(function (el) {',
'            var c = el.dataset.show.split(''=''), ok = c[1].split(''|'').indexOf(String(val(c[0]) || '''')) >= 0;',
'            el.style.display = ok ? '''' : ''none'';',
'        });',
'    }',
'',
'    // ------------------------------------------------------------ السطور',
'    var heads = {item: ''الصنف'', d: ''الوصف'', q: ret ? ''كمية المرتجع'' : ''الكمية'', p: ''السعر'', inc: ''شامل الضريبة'', disc: ''الخصم'', tc: ''الضريبة'',',
'                 acc: ''الحساب'', cc: ''مركز التكلفة'', lot: ''الدفعة'', exp: ''الانتهاء'', c: ''تكلفة الوحدة'', s: ''هالك %'', sold: ''المباع'', done: ''المرتجع سابقاً'',',
'                 oh: ''الرصيد''};',
'    function lineCalc(l) {',
'        if (!has(''p'')) return {net: num(l.q) * num(l.c), tax: 0};',
'        var gross = num(l.q) * num(l.p), disc = num(l.disc), r = rateOf(l.tc), net, tax;',
'        if (l.inc === ''Y'') { net = (gross - disc) / (1 + r / 100); tax = gross - disc - net; }',
'        else { net = gross - disc; tax = net * r / 100; }',
'        return {net: Math.round(net * 100) / 100, tax: Math.round(tax * 100) / 100};',
'    }',
'    function cell(l, i, c) {',
'        var v = l[c] == null ? '''' : l[c];',
'        if (c === ''item'') return ''<td class="nn-td-item">'' + (l.i ? ''<b>'' + esc(l.n || l.d) + ''</b>'' + (l.trk === ''LOT'' ? '' <span class="nn-badge is-warning">دفعات</span>'' : '''')',
'                                                          + (l.rx === ''Y'' ? '' <span class="nn-badge is-danger">وصفة</span>'' : '''') : ''<em>بند حر</em>'') + ''</td>'';',
'        if (ro || (ret && c !== ''q'')) {',
'            var shown = c === ''tc'' ? labelOf(''taxes'', v) : c === ''acc'' ? labelOf(''accts'', v) : c === ''cc'' ? labelOf(''ccs'', v) : c === ''inc'' ? (v === ''Y'' ? ''نعم'' : '''')',
'                      : (c === ''p'' || c === ''disc'' || c === ''c'') ? (v === '''' ? '''' : money(v)) : v;',
'            return ''<td>'' + esc(shown) + ''</td>'';',
'        }',
'        if (c === ''tc'' || c === ''acc'' || c === ''cc'') {',
'            var o = c === ''tc'' ? ''taxes'' : c === ''acc'' ? ''accts'' : ''ccs'';',
'            if (c === ''acc'' && l.i) return ''<td></td>'';',
'            return ''<td><select data-l="'' + i + ''" data-c="'' + c + ''">'' + (c === ''tc'' ? '''' : opt('''', ''-'')) + list(o).map(function (e) { return opt(e.v, e.n, v); }).join('''') + ''</select></td>'';',
'        }',
'        if (c === ''inc'') return ''<td><input type="checkbox" data-l="'' + i + ''" data-c="inc"'' + (v === ''Y'' ? '' checked'' : '''') + ''></td>'';',
'        if (c === ''d'') return l.i ? ''<td></td>'' : ''<td><input data-l="'' + i + ''" data-c="d" value="'' + esc(v) + ''" placeholder="وصف البند" class="is-wide"></td>'';',
'        if (c === ''exp'') return ''<td><input type="date" data-l="'' + i + ''" data-c="exp" value="'' + esc(v) + ''"></td>'';',
'        if (c === ''lot'') return ''<td><input data-l="'' + i + ''" data-c="lot" value="'' + esc(v) + ''"'' + (l.trk === ''LOT'' ? '' class="is-req" placeholder="إلزامي"'' : '''') + ''></td>'';',
'        if (c === ''oh'' || c === ''sold'' || c === ''done'') return ''<td>'' + esc(v) + ''</td>'';',
'        return ''<td><input type="number" step="any" min="0" data-l="'' + i + ''" data-c="'' + c + ''" value="'' + esc(v) + ''"></td>'';',
'    }',
'    function render() {',
'        // الدفعة والانتهاء تظهران عند وجود صنف يتتبع بالدفعات فقط',
'        var lotty = cf.lots !== false && lines.some(function (l) { return l.trk === ''LOT'' || l.lot; });',
'        var show = cols.filter(function (c) { return !(c === ''lot'' || c === ''exp'') || lotty; });',
'        th.innerHTML = ''<tr><th>#</th><th>'' + heads.item + ''</th>'' + show.map(function (c) { return ''<th>'' + heads[c] + ''</th>''; }).join('''')',
'                     + (has(''p'') ? ''<th>الصافي</th><th>الضريبة</th><th>الإجمالي</th>'' : (has(''c'') ? ''<th>القيمة</th>'' : '''')) + (ro || ret ? '''' : ''<th></th>'') + ''</tr>'';',
'        var sub = 0, tax = 0;',
'        tb.innerHTML = lines.map(function (l, i) {',
'            var k = lineCalc(l); sub += k.net; tax += k.tax;',
'            return ''<tr>'' + ''<td>'' + (i + 1) + ''</td>'' + cell(l, i, ''item'') + show.map(function (c) { return cell(l, i, c); }).join('''')',
'                 + (has(''p'') ? ''<td class="nn-td-n">'' + money(k.net) + ''</td><td class="nn-td-t">'' + money(k.tax) + ''</td><td class="nn-td-g"><b>'' + money(k.net + k.tax) + ''</b></td>''',
'                             : (has(''c'') ? ''<td class="nn-td-n">'' + money(k.net) + ''</td>'' : ''''))',
'                 + (ro || ret ? '''' : ''<td><button type="button" class="nn-td-del" data-del="'' + i + ''" title="حذف" aria-label="حذف">×</button></td>'') + ''</tr>'';',
'        }).join('''') || ''<tr><td colspan="20" class="nn-td-empty">'' + (ret ? ''لا توجد بنود قابلة للإرجاع'' : ''أضف الأصناف بالباركود أو البحث أعلاه'') + ''</td></tr>'';',
'        totals(sub, tax);',
'    }',
'    function totals(sub, tax) {',
'        if (sub == null) {',
'            sub = 0; tax = 0;',
'            lines.forEach(function (l) { var k = lineCalc(l); sub += k.net; tax += k.tax; });',
'        }',
'        var tot = root.querySelector(''.nn-td-totals'');',
'        if (has(''p'')) tot.innerHTML = ''<span>الصافي <b>'' + money(sub) + ''</b></span><span>الضريبة <b>'' + money(tax) + ''</b></span><span class="is-grand">الإجمالي <b>'' + money(sub + tax) + ''</b></span>''',
'                                    + (d.open != null && ro ? ''<span>المتبقي <b>'' + money(d.open) + ''</b></span>'' : '''');',
'        else if (has(''c'')) tot.innerHTML = ''<span class="is-grand">إجمالي القيمة <b>'' + money(sub) + ''</b></span>'';',
'        else tot.innerHTML = '''';',
'    }',
'    render();',
'    syncShow();',
'    if (ro) return;',
'',
'    // ------------------------------------------------------------ البحث وإضافة الأصناف',
'    var find = root.querySelector(''.nn-td-find''), res = root.querySelector(''.nn-td-results''), found = [];',
'    function addItem(it) {',
'        var same = lines.filter(function (l) { return l.i === it.id && !l.lot; })[0];',
'        if (same && !has(''lot'')) { same.q = num(same.q) + 1; }',
'        else {',
'            var l = {i: it.id, n: it.no + '' - '' + it.n, q: 1, trk: it.trk, rx: it.rx};',
'            if (has(''p'')) {',
'                l.p = cf.purpose === ''SALE'' ? it.p : (it.c != null ? it.c : '''');',
'                l.inc = cf.purpose === ''SALE'' ? (it.inc || ''N'') : ''N'';',
'                l.tc = it.tc || ''VAT15'';',
'            }',
'            if (has(''c'')) l.c = '''';',
'            if (has(''oh'')) l.oh = it.q;',
'            lines.push(l);',
'        }',
'        render();',
'        if (find) { find.value = ''''; find.focus(); }',
'        res.hidden = true;',
'    }',
'    function search(term) {',
'        if (!term) return;',
'        apex.server.process(''FIND_ITEMS'', {x01: term, x02: cf.purpose || ''ALL''}, {dataType: ''json''}).done(function (r) {',
'            found = r || [];',
'            var t = term.toUpperCase();',
'            var exact = found.filter(function (x) { return String(x.b || '''').split('' '').indexOf(term) >= 0 || x.no === term || x.code === term || String(x.mpn || '''').toUpperCase() === t; });',
'            if (exact.length === 1) { addItem(exact[0]); return; }',
'            if (found.length === 1) { addItem(found[0]); return; }',
'            res.innerHTML = found.length ? found.map(function (x, k) {',
'                return ''<button type="button" data-pick="'' + k + ''"><b>'' + esc(x.no) + ''</b> '' + esc(x.n) + (x.mpn ? '' <small>OEM '' + esc(x.mpn) + ''</small>'' : '''')',
'                     + (x.g ? '' <small>'' + esc(x.g) + ''</small>'' : '''') + ''<em>'' + (x.st === ''Y'' ? ''الرصيد '' + esc(x.q) : ''خدمة'') + (x.p != null ? '' | '' + money(x.p) : '''') + ''</em></button>''; }).join('''')',
'                : ''<div class="nn-td-none">لا توجد أصناف مطابقة</div>'';',
'            res.hidden = false;',
'        });',
'    }',
'    if (find) {',
'        find.addEventListener(''keydown'', function (e) { if (e.key === ''Enter'') { e.preventDefault(); search(find.value.trim()); } if (e.key === ''Escape'') res.hidden = true; });',
'        res.addEventListener(''click'', function (e) { var b = e.target.closest(''[data-pick]''); if (b) addItem(found[+b.dataset.pick]); });',
'        find.focus();',
'    }',
'    var free = root.querySelector(''.nn-td-free'');',
'    if (free) free.addEventListener(''click'', function () { lines.push({i: null, d: '''', q: 1, p: '''', tc: ''VAT15'', inc: ''N'', acc: cf.defAcc || ''''}); render(); });',
'    // العروض من محرك التسعير: خصم كل سطر صنف، ثم عرض قيمة الفاتورة موزعاً على الأسطر بنسبة صافيها',
'    var promoBtn = root.querySelector(''.nn-td-promo''), state_cpn = null;',
'    if (promoBtn) promoBtn.addEventListener(''click'', function () {',
'        var msg = root.querySelector(''.nn-doc-msg''), cpn = root.querySelector(''.nn-td-coupon'');',
'        var idx = [], req = {coupon: (cpn && cpn.value.trim()) || null, lines: []};',
'        lines.forEach(function (l, i) { if (l.i) { idx.push(i); req.lines.push({k: i, t: ''ITEM'', id: l.i, q: num(l.q), p: num(l.p)}); } });',
'        if (!req.lines.length) return;',
'        apex.server.process(''QUOTE'', {p_clob_01: JSON.stringify(req)}, {dataType: ''json''}).done(function (r) {',
'            if (!r || r.ok === false) { msg.className = ''nn-doc-msg is-bad''; msg.textContent = (r && r.msg) || ''تعذر حساب العروض''; return; }',
'            var names = [];',
'            (r.lines || []).forEach(function (x) { lines[x.k].disc = num(x.disc) ? num(x.disc).toFixed(2) : ''''; lines[x.k].sh = 0; if (x.promo && names.indexOf(x.promo) < 0) names.push(x.promo); });',
'            state_cpn = req.coupon;',
'            var dd = num(r.docDisc);',
'            if (dd > 0) {',
'                var base = idx.map(function (i) { return Math.max(num(lines[i].q) * num(lines[i].p) - num(lines[i].disc), 0); }), sum = 0, done = 0;',
'                base.forEach(function (b) { sum += b; });',
'                idx.forEach(function (i, k) {',
'                    var v = k === idx.length - 1 ? Math.round((dd - done) * 100) / 100 : Math.round(dd * base[k] / sum * 100) / 100;',
'                    done += v; lines[i].disc = (num(lines[i].disc) + v).toFixed(2); lines[i].sh = v;',
'                });',
'                names.push(r.doc.name);',
'            }',
'            render();',
'            msg.className = ''nn-doc-msg is-ok'';',
'            msg.textContent = names.length ? ''تم تطبيق: '' + names.join(''، '') + '' - إجمالي الخصم '' + money(num(r.lineDisc) + dd) : ''لا توجد عروض سارية على هذه الأصناف'';',
'        });',
'    });',
'    root.addEventListener(''input'', function (e) {',
'        var c = e.target.dataset.c; if (c == null || e.target.dataset.l == null) return;',
'        var l = lines[+e.target.dataset.l];',
'        l[c] = c === ''inc'' ? (e.target.checked ? ''Y'' : ''N'') : e.target.value;',
'        // تحديث مبالغ السطر والمجاميع دون إعادة بناء الجدول: إعادة البناء تنقل المؤشر لأول الحقل الرقمي فتنعكس الأرقام (40 تصبح 04)',
'        var k = lineCalc(l), tr = e.target.closest(''tr''), set = function (cls, v) { var td = tr && tr.querySelector(''.'' + cls); if (td) td.innerHTML = v; };',
'        set(''nn-td-n'', money(k.net)); set(''nn-td-t'', money(k.tax)); set(''nn-td-g'', ''<b>'' + money(k.net + k.tax) + ''</b>'');',
'        totals();',
'    });',
'    root.addEventListener(''change'', function (e) {',
'        if (e.target.dataset.k) syncShow();',
'        if (e.target.dataset.c === ''tc'' || e.target.dataset.c === ''acc'' || e.target.dataset.c === ''cc'') {',
'            lines[+e.target.dataset.l][e.target.dataset.c] = e.target.value; render();',
'        }',
'    });',
'    root.addEventListener(''click'', function (e) {',
'        var del = e.target.closest(''[data-del]'');',
'        if (del) { lines.splice(+del.dataset.del, 1); render(); return; }',
'        var b = e.target.closest(''.nn-doc-save''); if (!b) return;',
'        if (b.dataset.confirm && !window.confirm(b.dataset.confirm)) return;',
'        var doc = {id: d.id || null, action: b.dataset.a};',
'        Object.keys(cf.fixed || {}).forEach(function (k) { doc[k] = cf.fixed[k]; });',
'        (cf.carry || []).forEach(function (k) { if (d[k] != null) doc[k] = d[k]; });',
'        root.querySelectorAll(''[data-k]'').forEach(function (el) {',
'            var v = el.value === '''' ? null : el.value;',
'            doc[el.dataset.k] = (v != null && el.type === ''number'') ? num(v) : (v != null && /^(sup|cust|wh|toWh|cc|po|inv)$/.test(el.dataset.k) ? +v : v);',
'        });',
'        if (state_cpn) doc.coupon = state_cpn;',
'        doc.lines = lines.filter(function (l) { return !ret || num(l.q) > 0; }).map(function (l) {',
'            var o = {};',
'            if (ret) { o.l = l.l; o.q = num(l.q); return o; }',
'            o.i = l.i; o.q = num(l.q);',
'            [''d'', ''p'', ''disc'', ''tc'', ''inc'', ''acc'', ''cc'', ''lot'', ''exp'', ''c'', ''s'', ''pol'', ''sh''].forEach(function (k) {',
'                if (l[k] !== undefined && l[k] !== '''' && l[k] !== null) o[k] = (k === ''p'' || k === ''disc'' || k === ''c'' || k === ''s'' || k === ''cc'' || k === ''pol'' || k === ''sh'') ? num(l[k]) : l[k];',
'            });',
'            return o;',
'        });',
'        var msg = root.querySelector(''.nn-doc-msg''), btns = root.querySelectorAll(''.nn-doc-save'');',
'        var fail = function (t) { msg.className = ''nn-doc-msg is-bad''; msg.textContent = t; btns.forEach(function (x) { x.disabled = false; }); };',
'        msg.className = ''nn-doc-msg''; msg.textContent = ''جار الحفظ...'';',
'        btns.forEach(function (x) { x.disabled = true; });',
'        apex.server.process(''SAVE_DOC'', {p_clob_01: JSON.stringify(doc)}, {dataType: ''json''}).done(function (r) {',
'            if (r && r.ok) { msg.className = ''nn-doc-msg is-ok''; msg.textContent = ''تم الحفظ''; window.location.href = r.url; }',
'            else { fail((r && r.msg) || ''تعذر الحفظ''); }',
'        }).fail(function () { fail(''تعذر الاتصال بالخادم''); });',
'    });',
'})();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000253)
,p_plug_name=>'المرتجع'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820268000000254)
,p_name=>'P36_INV'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820268000000253)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820268000000255)
,p_plug_name=>'مرتجع المشتريات'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_ro varchar2(1) := ''N'';',
'    function js(p clob) return clob is begin return replace(p, ''</'', ''<\/''); end;',
'begin',
'    return ''<script type="application/json" id="nnTdData">'' || js(noona_pur_pkg.return_doc_json(:P36_INV)) || ''</script>''',
'        || ''<script type="application/json" id="nnTdConf">'' || js(q''~{"kind": "RET", "title": "مرتجع مشتريات (إشعار مدين للمورد)", "cols": ["sold", "done", "q", "p"], "carry": ["inv"], "search": false, "header": [{"k": "date", "l": "التاريخ", "t": "date"}, {"k": "reason", "l": "سبب المرتجع", "t": "text", "req": true, "w": true}], "actions": [{"a": "POST", "n": "ترحيل المرتجع", "hot": true, "confirm": "سيتم إخراج الكميات من المخزون وتخفيض حساب المورد. متابعة؟"}]}~'') || ''</script>''',
'        || ''<script type="application/json" id="nnTdLists">'' || js(noona_inv_pkg.lists_json(''taxes'')) || ''</script>''',
'        || ''<div id="nnTd" class="nn-doc nn-td" data-ro="'' || l_ro || ''" data-co="''',
'        || apex_escape.html_attribute(noona_apex_pkg.company_name) || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820268000000256)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SAVE_DOC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'begin',
'    l_id := noona_pur_pkg.post_return(apex_application.g_clob_01);',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    apex_json.write(''url'', apex_page.get_url(p_page => 35, p_clear_cache => ''35'', p_items => ''P35_ID'', p_values => l_id));',
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
,p_internal_uid=>91820268000000256
);

wwv_flow_imp.component_end;
end;
/
