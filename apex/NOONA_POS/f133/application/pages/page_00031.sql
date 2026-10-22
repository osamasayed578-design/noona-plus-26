prompt --application/pages/page_00031
begin
--   Manifest
--     PAGE: 00031
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
 p_id=>31
,p_name=>'POS'
,p_alias=>'POS'
,p_step_title=>'نقطة البيع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// شاشة نقطة البيع السريعة: الأصناف والأسعار والباركودات محملة مرة واحدة (بحث فوري في المتصفح بلا انتظار)،',
'// البيع بطلب واحد بمفتاح منع تكرار (إعادة الإرسال آمنة عند انقطاع الشبكة)، سداد مختلط، العميل العام افتراضياً،',
'// مرتجع بالإيصال، طباعة الإيصال الحراري برمز ZATCA. اختصارات: Enter إضافة، F2 الكمية، F4 العميل، F8 مرتجع، F9 الدفع، Esc إلغاء.',
'(function () {',
'    var root = document.getElementById(''nnPos''); if (!root) return;',
'    var boot; try { boot = JSON.parse(document.getElementById(''nnPosBoot'').textContent); } catch (e) { boot = {}; }',
'    var esc = function (s) { return String(s == null ? '''' : s).replace(/[&<>"]/g, function (c) { return {''&'': ''&amp;'', ''<'': ''&lt;'', ''>'': ''&gt;'', ''"'': ''&quot;''}[c]; }); };',
'    var num = function (v) { var n = parseFloat(v); return isNaN(n) ? 0 : n; };',
'    var r2 = function (v) { return Math.round(v * 100) / 100; };',
'    var money = function (v) { return num(v).toLocaleString(''en-US'', {minimumFractionDigits: 2, maximumFractionDigits: 2}); };',
'    var items = boot.items || [], methods = boot.methods || [], idx = {};',
'    items.forEach(function (it) {',
'        String(it.b || '''').split('' '').forEach(function (b) { if (b) idx[b] = it; });',
'        if (it.no) idx[it.no] = idx[it.no] || it;',
'        if (it.c) idx[it.c] = idx[it.c] || it;',
'    });',
'    var state = {cart: [], cust: boot.walkIn, custName: boot.walkInName, rx: '''', key: null, pays: {}, mode: ''SALE'', ret: null};',
'    var newKey = function () { return (window.crypto && crypto.randomUUID) ? crypto.randomUUID() : ''K'' + Date.now() + Math.random().toString(16).slice(2); };',
'',
'    root.innerHTML =',
'        ''<div class="nn-pos-top"><div class="nn-pos-term"><b>'' + esc((boot.terminal || {}).n) + ''</b><small>'' + esc(boot.seller || '''') + ''</small></div>''',
'      + ''<div class="nn-pos-scan"><span class="fa fa-barcode" aria-hidden="true"></span><input id="nnPosScan" autocomplete="off" placeholder="امسح الباركود أو اكتب الاسم / رقم الصنف / رقم القطعة / المادة الفعالة"></div>''',
'      + ''<button type="button" class="t-Button nn-pos-cust" title="F4"><span class="fa fa-user"></span> <span class="nn-pos-custname"></span></button>''',
'      + ''<button type="button" class="t-Button nn-pos-retbtn" title="F8"><span class="fa fa-undo"></span> مرتجع</button></div>''',
'      + ''<div class="nn-pos-body"><div class="nn-pos-cart"><table><thead><tr><th>الصنف</th><th>الكمية</th><th>السعر</th><th>الخصم</th><th>الإجمالي</th><th></th></tr></thead><tbody></tbody></table>''',
'      + ''<div class="nn-pos-rx" hidden><label>رقم الوصفة الطبية <input class="nn-pos-rxno" autocomplete="off"></label></div></div>''',
'      + ''<div class="nn-pos-side"><div class="nn-pos-results"></div><div class="nn-pos-sum"></div>''',
'      + ''<button type="button" class="t-Button t-Button--hot t-Button--large nn-pos-pay" title="F9">الدفع (F9)</button>''',
'      + ''<button type="button" class="t-Button nn-pos-clear">إلغاء السلة</button></div></div>''',
'      + ''<div class="nn-pos-modal" hidden><div class="nn-pos-dlg"></div></div>''',
'      + ''<iframe class="nn-pos-print" title="طباعة الإيصال" aria-hidden="true"></iframe>'';',
'    var $ = function (s) { return root.querySelector(s); };',
'    var scan = $(''#nnPosScan''), tbody = $(''.nn-pos-cart tbody''), modal = $(''.nn-pos-modal''), dlg = $(''.nn-pos-dlg'');',
'',
'    function priceOf(l) {',
'        var gross = l.q * l.p, disc = num(l.disc), net, tax;',
'        if (l.inc === ''Y'') { net = r2((gross - disc) / (1 + l.t / 100)); tax = r2(gross - disc - net); }',
'        else { net = r2(gross - disc); tax = r2(net * l.t / 100); }',
'        return {net: net, tax: tax, total: r2(net + tax)};',
'    }',
'    function totals() {',
'        var s = {net: 0, tax: 0, total: 0, qty: 0};',
'        state.cart.forEach(function (l) { var p = priceOf(l); s.net += p.net; s.tax += p.tax; s.total += p.total; s.qty += l.q; });',
'        s.net = r2(s.net); s.tax = r2(s.tax); s.total = r2(s.total);',
'        return s;',
'    }',
'    function draw() {',
'        tbody.innerHTML = state.cart.map(function (l, i) {',
'            var p = priceOf(l);',
'            return ''<tr'' + (i === state.cart.length - 1 ? '' class="is-last"'' : '''') + ''><td><b>'' + esc(l.n) + ''</b>'' + (l.rx === ''Y'' ? '' <span class="nn-badge is-danger">وصفة</span>'' : '''')',
'                 + (l.st === ''Y'' && l.q > l.oh ? '' <span class="nn-badge is-warning">الرصيد '' + l.oh + ''</span>'' : '''') + ''</td>''',
'                 + ''<td class="nn-pos-qty"><button type="button" data-dec="'' + i + ''">−</button><input type="number" step="any" min="0" data-q="'' + i + ''" value="'' + l.q + ''"><button type="button" data-inc="'' + i + ''">+</button></td>''',
'                 + ''<td>'' + money(l.p) + ''</td><td><input type="number" step="any" min="0" class="nn-pos-disc" data-disc="'' + i + ''" value="'' + (l.disc || '''') + ''"></td>''',
'                 + ''<td><b>'' + money(p.total) + ''</b></td><td><button type="button" class="nn-td-del" data-del="'' + i + ''" aria-label="حذف">×</button></td></tr>'';',
'        }).join('''') || ''<tr><td colspan="6" class="nn-td-empty">السلة فارغة - امسح الباركود للبدء</td></tr>'';',
'        var t = totals();',
'        $(''.nn-pos-sum'').innerHTML = ''<div><span>عدد القطع</span><b>'' + t.qty + ''</b></div><div><span>قبل الضريبة</span><b>'' + money(t.net) + ''</b></div>''',
'            + ''<div><span>الضريبة</span><b>'' + money(t.tax) + ''</b></div><div class="is-grand"><span>الإجمالي</span><b>'' + money(t.total) + ''</b></div>'';',
'        $(''.nn-pos-custname'').textContent = state.custName || ''عميل نقدي عام'';',
'        var needRx = state.cart.some(function (l) { return l.rx === ''Y''; });',
'        $(''.nn-pos-rx'').hidden = !needRx;',
'    }',
'    function add(it, qty) {',
'        if (!it) return;',
'        var l = state.cart.filter(function (x) { return x.i === it.id && !x.disc; })[0];',
'        if (l) { l.q = r2(l.q + (qty || 1)); state.cart.splice(state.cart.indexOf(l), 1); state.cart.push(l); }',
'        else state.cart.push({i: it.id, n: it.n, q: qty || 1, p: num(it.p), inc: it.inc || ''N'', t: num(it.t), rx: it.rx, st: it.st, oh: num(it.q), b: it._b});',
'        draw();',
'    }',
'    function results(term) {',
'        var t = term.toUpperCase(), out = [];',
'        if (t.length >= 2) {',
'            for (var i = 0; i < items.length && out.length < 30; i++) {',
'                var it = items[i];',
'                if ((it.n || '''').toUpperCase().indexOf(t) >= 0 || (it.g || '''').toUpperCase().indexOf(t) >= 0 || (it.mpn || '''').toUpperCase().indexOf(t) >= 0',
'                    || (it.no || '''').toUpperCase().indexOf(t) >= 0 || (it.c || '''').toUpperCase().indexOf(t) >= 0) out.push(it);',
'            }',
'        }',
'        $(''.nn-pos-results'').innerHTML = out.map(function (it) {',
'            return ''<button type="button" data-item="'' + it.id + ''"><b>'' + esc(it.n) + ''</b><span>'' + money(it.p) + (it.st === ''Y'' ? '' | الرصيد '' + it.q : '''') + ''</span></button>'';',
'        }).join('''');',
'        return out;',
'    }',
'    var byId = function (id) { return items.filter(function (x) { return String(x.id) === String(id); })[0]; };',
'    // الباركود: مطابقة تامة فورية؛ يدعم الكمية بالصيغة 3*باركود',
'    scan.addEventListener(''keydown'', function (e) {',
'        if (e.key !== ''Enter'') return;',
'        e.preventDefault();',
'        var v = scan.value.trim(), qty = 1, m = v.match(/^(\d+(?:\.\d+)?)\*(.+)$/);',
'        if (m) { qty = num(m[1]); v = m[2]; }',
'        if (!v) { if (state.cart.length) openPay(); return; }',
'        var it = idx[v];',
'        if (!it) { var r = results(v); if (r.length === 1) it = r[0]; }',
'        if (it) { it._b = v; add(it, qty); scan.value = ''''; $(''.nn-pos-results'').innerHTML = ''''; }',
'        else { scan.classList.add(''is-bad''); setTimeout(function () { scan.classList.remove(''is-bad''); }, 600); }',
'    });',
'    scan.addEventListener(''input'', function () { results(scan.value.trim()); });',
'    root.addEventListener(''click'', function (e) {',
'        var t = e.target.closest(''button''); if (!t) return;',
'        if (t.dataset.item) { add(byId(t.dataset.item)); scan.value = ''''; $(''.nn-pos-results'').innerHTML = ''''; scan.focus(); }',
'        else if (t.dataset.inc != null) { state.cart[+t.dataset.inc].q = r2(state.cart[+t.dataset.inc].q + 1); draw(); }',
'        else if (t.dataset.dec != null) { var l = state.cart[+t.dataset.dec]; l.q = r2(l.q - 1); if (l.q <= 0) state.cart.splice(+t.dataset.dec, 1); draw(); }',
'        else if (t.dataset.del != null) { state.cart.splice(+t.dataset.del, 1); draw(); }',
'        else if (t.classList.contains(''nn-pos-pay'')) openPay();',
'        else if (t.classList.contains(''nn-pos-clear'')) { if (!state.cart.length || confirm(''إلغاء السلة؟'')) reset(); }',
'        else if (t.classList.contains(''nn-pos-cust'')) openCust();',
'        else if (t.classList.contains(''nn-pos-retbtn'')) openReturn();',
'    });',
'    tbody.addEventListener(''change'', function (e) {',
'        var t = e.target;',
'        if (t.dataset.q != null) { var q = num(t.value); if (q <= 0) state.cart.splice(+t.dataset.q, 1); else state.cart[+t.dataset.q].q = q; draw(); }',
'        if (t.dataset.disc != null) { state.cart[+t.dataset.disc].disc = num(t.value); draw(); }',
'    });',
'    $(''.nn-pos-rxno'').addEventListener(''input'', function (e) { state.rx = e.target.value; });',
'    function reset() {',
'        state.cart = []; state.pays = {}; state.key = null; state.rx = ''''; state.cust = boot.walkIn; state.custName = boot.walkInName;',
'        $(''.nn-pos-rxno'').value = ''''; draw(); scan.focus();',
'    }',
'    function close() { modal.hidden = true; scan.focus(); }',
'    function show(html) { dlg.oninput = null; dlg.onclick = null; dlg.innerHTML = html; modal.hidden = false; }',
'    function fail(msg) { var m = dlg.querySelector(''.nn-pos-msg''); if (m) { m.className = ''nn-pos-msg is-bad''; m.textContent = msg; } }',
'    function call(proc, payload) {',
'        return new Promise(function (ok, no) {',
'            apex.server.process(proc, payload, {dataType: ''json''}).done(function (r) { if (r && r.ok !== false) ok(r); else no((r && r.msg) || ''تعذر التنفيذ''); })',
'                .fail(function () { no(''NET''); });',
'        });',
'    }',
'',
'    // ------------------------------------------------------------ الدفع',
'    function openPay() {',
'        if (!state.cart.length) return;',
'        if (!boot.shift) { openShift(); return; }',
'        if (state.cart.some(function (l) { return l.rx === ''Y''; }) && !state.rx) { $(''.nn-pos-rxno'').focus(); alert(''أدخل رقم الوصفة الطبية''); return; }',
'        var t = totals();',
'        state.key = state.key || newKey();',
'        if (!Object.keys(state.pays).length) state.pays = {CASH: t.total};',
'        var cash = [t.total, Math.ceil(t.total / 10) * 10, Math.ceil(t.total / 50) * 50, Math.ceil(t.total / 100) * 100, 500]',
'            .filter(function (v, i, a) { return v >= t.total && a.indexOf(v) === i; }).slice(0, 4);',
'        show(''<h3>الدفع - الإجمالي <b>'' + money(t.total) + ''</b></h3><div class="nn-pos-methods">''',
'            + methods.map(function (m) {',
'                return ''<label class="nn-pos-m"><span><i class="fa '' + esc(m.i || ''fa-money'') + ''"></i> '' + esc(m.n) + ''</span>''',
'                     + ''<input type="number" step="any" min="0" data-pm="'' + esc(m.c) + ''" value="'' + (state.pays[m.c] || '''') + ''">''',
'                     + (m.r === ''Y'' ? ''<input class="nn-pos-ref" data-ref="'' + esc(m.c) + ''" placeholder="رقم العملية / آخر 4 أرقام">'' : '''') + ''</label>'';',
'            }).join('''') + ''</div>''',
'            + ''<div class="nn-pos-quick">'' + cash.map(function (v) { return ''<button type="button" class="t-Button" data-cash="'' + v + ''">نقداً '' + money(v) + ''</button>''; }).join('''')',
'            + ''<button type="button" class="t-Button" data-all="MADA">الكل مدى</button></div>''',
'            + ''<div class="nn-pos-change"></div><div class="nn-pos-msg" role="alert"></div>''',
'            + ''<div class="nn-pos-actions"><button type="button" class="t-Button t-Button--hot t-Button--large" data-do="pay">تأكيد البيع (Enter)</button>''',
'            + ''<label class="nn-pos-autoprint"><input type="checkbox" data-print checked> طباعة الإيصال</label>''',
'            + ''<button type="button" class="t-Button" data-do="close">رجوع (Esc)</button></div>'');',
'        var upd = function () {',
'            var paid = 0, cashPaid = 0;',
'            dlg.querySelectorAll(''[data-pm]'').forEach(function (el) { var v = num(el.value); paid += v; if (el.dataset.pm === ''CASH'') cashPaid += v; state.pays[el.dataset.pm] = v; });',
'            var ch = r2(paid - t.total);',
'            dlg.querySelector(''.nn-pos-change'').innerHTML = ch >= 0 ? ''الباقي للعميل: <b>'' + money(ch) + ''</b>'' + (ch > cashPaid ? '' <em class="is-bad">الباقي يرد من النقد فقط</em>'' : '''')',
'                                                                  : ''المتبقي: <b class="is-bad">'' + money(-ch) + ''</b>'';',
'        };',
'        dlg.oninput = upd; upd();',
'        var first = dlg.querySelector(''[data-pm="CASH"]'') || dlg.querySelector(''[data-pm]''); if (first) first.select();',
'        dlg.onclick = function (e) {',
'            var b = e.target.closest(''button''); if (!b) return;',
'            if (b.dataset.cash) { dlg.querySelectorAll(''[data-pm]'').forEach(function (el) { el.value = el.dataset.pm === ''CASH'' ? b.dataset.cash : ''''; }); upd(); }',
'            if (b.dataset.all) { dlg.querySelectorAll(''[data-pm]'').forEach(function (el) { el.value = el.dataset.pm === b.dataset.all ? t.total : ''''; }); upd(); }',
'            if (b.dataset.do === ''close'') close();',
'            if (b.dataset.do === ''pay'') pay();',
'        };',
'    }',
'    function pay() {',
'        var refs = {}, pays = [];',
'        dlg.querySelectorAll(''[data-ref]'').forEach(function (el) { refs[el.dataset.ref] = el.value; });',
'        Object.keys(state.pays).forEach(function (m) { if (num(state.pays[m]) > 0) pays.push({m: m, a: r2(num(state.pays[m])), ref: refs[m] || null}); });',
'        var doc = {key: state.key, shift: boot.shift, cust: state.cust === boot.walkIn ? null : state.cust, rx: state.rx || null, pays: pays,',
'                   lines: state.cart.map(function (l) { return {i: l.i, q: l.q, disc: num(l.disc) || 0, b: l.b || null}; })};',
'        var btn = dlg.querySelector(''[data-do="pay"]''), print = (dlg.querySelector(''[data-print]'') || {}).checked;',
'        btn.disabled = true;',
'        call(''SALE'', {p_clob_01: JSON.stringify(doc)}).then(function (r) {',
'            state.cart.forEach(function (l) { var it = byId(l.i); if (it && it.st === ''Y'') it.q = r2(num(it.q) - l.q); });',
'            show(''<div class="nn-pos-done"><span class="fa fa-check-circle"></span><h3>تم البيع - إيصال '' + esc(r.no) + ''</h3><p>الإجمالي '' + money(r.total)',
'                + (num(r.change) > 0 ? '' | <b>الباقي '' + money(r.change) + ''</b>'' : '''') + ''</p><button type="button" class="t-Button t-Button--hot" data-do="next">بيع جديد (Enter)</button>''',
'                + '' <button type="button" class="t-Button" data-do="reprint">طباعة الإيصال</button></div>'');',
'            var id = r.id;',
'            dlg.onclick = function (e) { var b = e.target.closest(''button''); if (!b) return; if (b.dataset.do === ''next'') { close(); reset(); } if (b.dataset.do === ''reprint'') printReceipt(id); };',
'            if (print) printReceipt(id);',
'            reset(); modal.hidden = false;',
'            dlg.querySelector(''[data-do="next"]'').focus();',
'        }, function (m) {',
'            btn.disabled = false;',
'            // انقطاع: نفس المفتاح عند الإعادة فلا يتكرر البيع',
'            fail(m === ''NET'' ? ''انقطع الاتصال؛ اضغط تأكيد البيع مرة أخرى (لن يتكرر البيع)'' : m);',
'        });',
'    }',
'    function printReceipt(id) {',
'        var f = root.querySelector(''.nn-pos-print'');',
'        f.src = ''f?p='' + apex.env.APP_ID + '':33:'' + apex.env.APP_SESSION + ''::NO:RP,33:P33_ID,P33_AUTO:'' + id + '',Y'';',
'    }',
'',
'    // ------------------------------------------------------------ العميل',
'    function openCust() {',
'        show(''<h3>العميل</h3><input class="nn-pos-csearch" placeholder="ابحث بالاسم أو الجوال أو الرقم الضريبي"><div class="nn-pos-clist"></div>''',
'            + ''<div class="nn-pos-msg"></div><div class="nn-pos-actions"><button type="button" class="t-Button" data-walk>العميل النقدي العام</button>''',
'            + ''<button type="button" class="t-Button" data-do="close">رجوع</button></div>'');',
'        var s = dlg.querySelector(''.nn-pos-csearch''), timer;',
'        s.focus();',
'        s.oninput = function () {',
'            clearTimeout(timer);',
'            timer = setTimeout(function () {',
'                call(''FIND_CUST'', {x01: s.value}).then(function (r) {',
'                    dlg.querySelector(''.nn-pos-clist'').innerHTML = (r.list || []).map(function (c) {',
'                        return ''<button type="button" data-cust="'' + c.id + ''">'' + esc(c.n) + (c.ph ? '' <small>'' + esc(c.ph) + ''</small>'' : '''') + ''</button>''; }).join('''');',
'                }, fail);',
'            }, 250);',
'        };',
'        dlg.onclick = function (e) {',
'            var b = e.target.closest(''button''); if (!b) return;',
'            if (b.dataset.cust) { state.cust = +b.dataset.cust; state.custName = b.textContent; close(); draw(); }',
'            if (b.hasAttribute(''data-walk'')) { state.cust = boot.walkIn; state.custName = boot.walkInName; close(); draw(); }',
'            if (b.dataset.do === ''close'') close();',
'        };',
'    }',
'',
'    // ------------------------------------------------------------ المرتجع',
'    function openReturn() {',
'        if (!boot.shift) { openShift(); return; }',
'        show(''<h3>مرتجع بالإيصال</h3><input class="nn-pos-rno" placeholder="رقم الإيصال ثم Enter"><div class="nn-pos-rlines"></div><div class="nn-pos-msg"></div>''',
'            + ''<div class="nn-pos-actions"><button type="button" class="t-Button t-Button--hot" data-do="refund" disabled>تنفيذ المرتجع ورد المبلغ (نقداً، أو على الحساب للبيع الآجل)</button>''',
'            + ''<button type="button" class="t-Button" data-do="close">رجوع</button></div>'');',
'        var inp = dlg.querySelector(''.nn-pos-rno''), rec = null;',
'        inp.focus();',
'        inp.onkeydown = function (e) {',
'            if (e.key !== ''Enter'') return;',
'            call(''FIND_RECEIPT'', {x01: inp.value.trim()}).then(function (r) {',
'                rec = r;',
'                dlg.querySelector(''.nn-pos-rlines'').innerHTML = ''<p>'' + esc(r.at) + '' | '' + esc(r.cust || '''') + '' | الإجمالي '' + money(r.total) + ''</p><table><tr><th>الصنف</th><th>المباع</th><th>المرتجع سابقاً</th><th>للإرجاع</th></tr>''',
'                    + (r.lines || []).map(function (l) { return ''<tr><td>'' + esc(l.n) + ''</td><td>'' + l.q + ''</td><td>'' + l.r + ''</td><td><input type="number" min="0" step="any" max="'' + (l.q - l.r) + ''" data-rl="'' + l.l + ''" data-u="'' + l.u + ''" value="0"></td></tr>''; }).join('''') + ''</table>'';',
'                dlg.querySelector(''[data-do="refund"]'').disabled = false;',
'            }, fail);',
'        };',
'        dlg.onclick = function (e) {',
'            var b = e.target.closest(''button''); if (!b) return;',
'            if (b.dataset.do === ''close'') close();',
'            if (b.dataset.do === ''refund'' && rec) {',
'                var lines = [];',
'                dlg.querySelectorAll(''[data-rl]'').forEach(function (el) { if (num(el.value) > 0) lines.push({l: +el.dataset.rl, q: num(el.value)}); });',
'                if (!lines.length) { fail(''حدد كمية مرتجعة''); return; }',
'                b.disabled = true;',
'                var key = state.retKey = state.retKey || newKey();',
'                call(''RETURN'', {p_clob_01: JSON.stringify({key: key, shift: boot.shift, orig: rec.id, lines: lines, pays: []})}).then(function (r) {',
'                    state.retKey = null;',
'                    show(''<div class="nn-pos-done"><span class="fa fa-check-circle"></span><h3>تم المرتجع '' + esc(r.no) + ''</h3><p>المبلغ المردود '' + money(r.total)',
'                        + ''</p><button type="button" class="t-Button t-Button--hot" data-do="close">تم</button></div>'');',
'                    dlg.onclick = function (ev) { if (ev.target.closest(''[data-do="close"]'')) close(); };',
'                    printReceipt(r.id);',
'                }, function (m) { b.disabled = false; fail(m === ''NET'' ? ''انقطع الاتصال؛ أعد المحاولة'' : m); });',
'            }',
'        };',
'    }',
'',
'    // ------------------------------------------------------------ فتح الوردية',
'    function openShift() {',
'        show(''<h3>فتح وردية</h3><label>النقد الافتتاحي في الدرج <input type="number" step="any" min="0" class="nn-pos-float" value="0"></label>''',
'            + ''<div class="nn-pos-msg"></div><div class="nn-pos-actions"><button type="button" class="t-Button t-Button--hot" data-do="open">فتح الوردية</button></div>'');',
'        dlg.onclick = function (e) {',
'            if (!e.target.closest(''[data-do="open"]'')) return;',
'            call(''OPEN_SHIFT'', {x01: dlg.querySelector(''.nn-pos-float'').value, x02: (boot.terminal || {}).id}).then(function (r) { boot.shift = r.shift; close(); }, fail);',
'        };',
'    }',
'',
'    document.addEventListener(''keydown'', function (e) {',
'        if (e.key === ''F9'') { e.preventDefault(); if (modal.hidden) openPay(); else if (dlg.querySelector(''[data-do="pay"]'')) pay(); }',
'        else if (e.key === ''F4'') { e.preventDefault(); openCust(); }',
'        else if (e.key === ''F8'') { e.preventDefault(); openReturn(); }',
'        else if (e.key === ''F2'') { e.preventDefault(); var q = tbody.querySelector(''tr.is-last [data-q]''); if (q) q.select(); }',
'        else if (e.key === ''Escape'' && !modal.hidden) { e.preventDefault(); close(); }',
'        else if (e.key === ''Enter'' && !modal.hidden && e.target.tagName !== ''TEXTAREA'') {',
'            var p = dlg.querySelector(''[data-do="pay"]''), n = dlg.querySelector(''[data-do="next"]'');',
'            if (n) { e.preventDefault(); n.click(); } else if (p && e.target.dataset.pm != null) { e.preventDefault(); p.click(); }',
'        }',
'    });',
'    modal.addEventListener(''click'', function (e) { if (e.target === modal) close(); });',
'    draw();',
'    if (!boot.shift) openShift(); else scan.focus();',
'})();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000158)
,p_plug_name=>'المحطة'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000159)
,p_name=>'P31_TERM'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820269000000158)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000160)
,p_plug_name=>'نقطة البيع'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P31_TERM is null then return ''<div class="nn-empty">اختر نقطة البيع من قائمة نقاط البيع</div>''; end if;',
'    return ''<script type="application/json" id="nnPosBoot">'' || replace(noona_pos_pkg.boot_json(:P31_TERM), ''</'', ''<\/'') || ''</script>''',
'        || ''<div id="nnPos" class="nn-pos"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000161)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SALE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    apex_util.prn(noona_pos_pkg.sale(apex_application.g_clob_01), false);',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000161
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000162)
,p_process_sequence=>2
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'RETURN'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    apex_util.prn(noona_pos_pkg.return_sale(apex_application.g_clob_01), false);',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000162
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000163)
,p_process_sequence=>3
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'FIND_RECEIPT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    apex_util.prn(noona_pos_pkg.find_receipt(apex_application.g_x01), false);',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000163
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000164)
,p_process_sequence=>4
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'FIND_CUST'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    apex_util.prn(''{"list":'' || noona_sal_pkg.customers_json(apex_application.g_x01) || ''}'', false);',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000164
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000165)
,p_process_sequence=>5
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'OPEN_SHIFT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    apex_util.prn(''{"shift":'' || noona_pos_pkg.open_shift(to_number(apex_application.g_x02), to_number(nvl(apex_application.g_x01, ''0''))) || ''}'', false);',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000165
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000166)
,p_plug_name=>'الوردية'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P31_TERM is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820269000000167)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820269000000166)
,p_button_name=>'CLOSE_SHIFT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تقرير X / إقفال الوردية'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:RP,32:P32_TERM:&P31_TERM.'
);

wwv_flow_imp.component_end;
end;
/
