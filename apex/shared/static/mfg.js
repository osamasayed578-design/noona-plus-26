// شاشات التصنيع: محرر قائمة المواد (#nnBom)، محرر مسار التصنيع (#nnRt)، منضدة أمر الإنتاج (#nnMo)، تخطيط الاحتياجات (#nnMrp).
// البيانات JSON في #nnMfgData والقوائم في #nnMfgLists؛ كل إجراء طلب AJAX واحد يعيد {ok,msg,url} ثم يعاد تحميل الصفحة.
(function () {
    var data = function (id) { var el = document.getElementById(id); try { return JSON.parse(el ? el.textContent : 'null'); } catch (e) { return null; } };
    var d = data('nnMfgData') || {}, lists = data('nnMfgLists') || {};
    var co = (document.querySelector('.nn-mfg[data-co]') || {dataset: {}}).dataset.co || '';
    var esc = function (s) { return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'}[c]; }); };
    var num = function (v) { var n = parseFloat(v); return isNaN(n) ? 0 : n; };
    var money = function (v) { return v == null || v === '' ? '' : num(v).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}); };
    var qty = function (v) { return v == null || v === '' ? '' : num(v).toLocaleString('en-US', {maximumFractionDigits: 3}); };
    var opt = function (v, t, sel) { return '<option value="' + esc(v) + '"' + (String(v) === String(sel == null ? '' : sel) ? ' selected' : '') + '>' + esc(t) + '</option>'; };
    var options = function (arr, sel, blank) { return (blank ? opt('', blank) : '') + (arr || []).map(function (e) { return opt(e.v, e.n, sel); }).join(''); };
    var badge = function (st, txt) {
        var c = /CLOSED|COMPLETED|PUBLISHED|PASSED|ACCEPTED|POSTED/.test(st) ? 'is-success' : /CANCELLED|OBSOLETE|FAILED|REJECTED/.test(st) ? 'is-danger'
              : /HOLD|PENDING_QUALITY|CONDITIONAL/.test(st) ? 'is-warning' : /PROGRESS|PARTIALLY|RELEASED/.test(st) ? 'is-info' : '';
        return '<span class="nn-badge ' + c + '">' + esc(txt || st) + '</span>';
    };
    // طلب AJAX موحد: عند النجاح يعاد التحميل (أو الانتقال للرابط المعاد)
    function call(root, proc, args, okText) {
        var msg = root.querySelector('.nn-doc-msg'), btns = root.querySelectorAll('button');
        var fail = function (t) { if (msg) { msg.className = 'nn-doc-msg is-bad'; msg.textContent = t; } btns.forEach(function (b) { b.disabled = false; }); };
        if (msg) { msg.className = 'nn-doc-msg'; msg.textContent = 'جار التنفيذ...'; }
        btns.forEach(function (b) { b.disabled = true; });
        return apex.server.process(proc, args, {dataType: 'json'}).done(function (r) {
            if (r && r.ok !== false) {
                if (msg) { msg.className = 'nn-doc-msg is-ok'; msg.textContent = okText || 'تم'; }
                if (r.url) window.location.href = r.url; else window.location.reload();
            } else { fail((r && r.msg) || 'تعذر التنفيذ'); }
        }).fail(function () { fail('تعذر الاتصال بالخادم'); });
    }
    // بحث الأصناف (رقم، كود، باركود، اسم) لإضافة مكون أو بديل
    function itemSearch(input, box, onPick) {
        var found = [];
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { box.hidden = true; return; }
            if (e.key !== 'Enter') return;
            e.preventDefault();
            var term = input.value.trim(); if (!term) return;
            apex.server.process('FIND_ITEMS', {x01: term, x02: 'ALL'}, {dataType: 'json'}).done(function (r) {
                found = r || [];
                if (found.length === 1) { onPick(found[0]); input.value = ''; box.hidden = true; return; }
                box.innerHTML = found.length ? found.map(function (x, k) {
                    return '<button type="button" data-pick="' + k + '"><b>' + esc(x.no) + '</b> ' + esc(x.n) + '<em>' + (x.st === 'Y' ? 'الرصيد ' + esc(x.q) : 'خدمة') + '</em></button>';
                }).join('') : '<div class="nn-td-none">لا توجد أصناف مطابقة</div>';
                box.hidden = false;
            });
        });
        box.addEventListener('click', function (e) {
            var b = e.target.closest('[data-pick]'); if (!b) return;
            onPick(found[+b.dataset.pick]); input.value = ''; box.hidden = true;
        });
    }
    function head(title, no, status, statusName, extra) {
        return '<div class="nn-doc-head"><div class="nn-doc-co">' + esc(document.body.dataset.co || '') + '</div>'
             + '<div class="nn-doc-title">' + esc(title) + '<small>' + (status ? badge(status, statusName) : '') + (extra || '') + '</small></div>'
             + '<div class="nn-doc-no"><span>الرقم</span><b>' + esc(no || 'جديد') + '</b></div></div>';
    }
    function foot(actions) {
        return '<div class="nn-doc-foot"><div class="nn-doc-msg" role="alert"></div><div class="nn-doc-actions">'
             + actions.map(function (a) { return '<button type="button" class="t-Button' + (a.hot ? ' t-Button--hot' : '') + '" data-a="' + a.a + '"'
                 + (a.confirm ? ' data-confirm="' + esc(a.confirm) + '"' : '') + '>' + esc(a.n) + '</button>'; }).join('') + '</div></div>';
    }
    function versions(list, cur, page, item) {
        if (!list || list.length < 2) return '';
        return '<div class="nn-mfg-vers"><span>الإصدارات:</span>' + list.map(function (v) {
            return '<a class="' + (String(v.id) === String(cur) ? 'is-cur' : '') + '" href="f?p=' + $v('pFlowId') + ':' + page + ':' + $v('pInstance')
                 + '::NO::' + item + ':' + v.id + '">v' + v.v + ' ' + badge(v.st, v.sn) + (v.def === 'Y' ? ' ★' : '') + '</a>';
        }).join('') + '</div>';
    }
    function confirmed(btn) { return !btn.dataset.confirm || window.confirm(btn.dataset.confirm); }

    // ================================================================ محرر قائمة المواد
    (function () {
        var root = document.getElementById('nnBom'); if (!root) return;
        var ro = d.inUse === 'Y' || d.status === 'OBSOLETE';
        var lines = (d.lines || []).map(function (l) { return Object.assign({subs: []}, l); });
        var types = [{v: 'PRODUCTION', n: 'إنتاج'}, {v: 'PHANTOM', n: 'وهمية (تفك في القائمة الأم)'}, {v: 'KIT', n: 'طقم'}, {v: 'ENGINEERING', n: 'هندسية'}];
        var products = lists.items || [];
        var h = head('قائمة المواد', d.id ? (d.code || '') + ' v' + (d.version || 1) : null, d.id ? d.status : null, d.statusName,
                     d['default'] === 'Y' ? ' <span class="nn-badge is-success">الافتراضية</span>' : '')
              + (ro && d.id ? '<div class="nn-mfg-note">' + (d.inUse === 'Y' ? 'هذا الإصدار مستخدم في أوامر إنتاج فلا يعدل؛ أنشئ إصداراً جديداً منه.' : 'الإصدار ملغى الاستخدام.') + '</div>' : '')
              + versions(d.versions, d.id, 21, 'P21_ID')
              + '<div class="nn-doc-fields">'
              + '<label class="nn-doc-f"><span>المنتج *</span>' + (d.id ? '<b class="nn-doc-v">' + esc(d.itemName) + '</b>'
                   : '<select data-k="item">' + options(products, d.item, '- اختر المنتج -') + '</select>') + '</label>'
              + '<label class="nn-doc-f"><span>اسم القائمة</span>' + (ro ? '<b class="nn-doc-v">' + esc(d.name) + '</b>' : '<input data-k="name" value="' + esc(d.name || '') + '">') + '</label>'
              + '<label class="nn-doc-f"><span>النوع</span>' + (ro ? '<b class="nn-doc-v">' + esc((types.filter(function (t) { return t.v === d.type; })[0] || {}).n) + '</b>'
                   : '<select data-k="type">' + options(types, d.type || 'PRODUCTION') + '</select>') + '</label>'
              + '<label class="nn-doc-f"><span>الكمية المرجعية (المكونات لكل)</span>' + (ro ? '<b class="nn-doc-v">' + qty(d.base) + '</b>'
                   : '<input data-k="base" type="number" step="any" value="' + esc(d.base || 1) + '">') + '</label></div>'
              + (ro ? '' : '<div class="nn-td-scan"><span class="fa fa-search" aria-hidden="true"></span><input type="search" class="nn-td-find nn-mfg-find" placeholder="أضف مكوناً: رقم الصنف أو الكود أو الباركود أو الاسم ثم Enter" autocomplete="off"><div class="nn-td-results" hidden></div></div>')
              + '<div class="nn-td-wrap"><table class="nn-td-table"><thead><tr><th>#</th><th>المكون</th><th>الكمية</th><th>هالك %</th><th>العملية</th>'
              + '<th>منتج مشترك</th><th>البدائل</th><th>تكلفة الوحدة</th><th>التكلفة</th><th>الرصيد</th>' + (ro ? '' : '<th></th>') + '</tr></thead><tbody></tbody><tfoot></tfoot></table></div>'
              + foot(ro ? (d.id ? [{a: 'NEWVER', n: 'إصدار جديد للتعديل', hot: true}] : [])
                        : [{a: 'SAVE', n: 'حفظ مسودة'}, {a: 'PUBLISH', n: 'حفظ ونشر', hot: true, confirm: 'النشر يجعل هذا الإصدار الافتراضي لأوامر الإنتاج الجديدة. متابعة؟'}]
                          .concat(d.id ? [{a: 'NEWVER', n: 'نسخة جديدة'}, {a: 'OBSOLETE', n: 'إلغاء الاستخدام', confirm: 'إلغاء استخدام هذا الإصدار؟'}] : []));
        root.innerHTML = h;
        var tb = root.querySelector('tbody'), tf = root.querySelector('tfoot');
        function render() {
            var total = 0;
            tb.innerHTML = lines.map(function (l, i) {
                var cost = num(l.q) * (1 + (l.co === 'Y' ? 0 : num(l.s) / 100)) * num(l.c) / Math.max(num(val('base')) || 1, 0.000001);
                total += l.co === 'Y' ? -cost : cost;
                var subs = (l.subs || []).map(function (s, k) { return '<span class="nn-chip">' + esc(s.n) + (s.f && num(s.f) !== 1 ? ' ×' + qty(s.f) : '')
                    + (ro ? '' : ' <button type="button" class="nn-chip-x" data-sx="' + i + ':' + k + '" title="حذف">×</button>') + '</span>'; }).join('');
                return '<tr' + (l.co === 'Y' ? ' class="nn-mfg-co"' : '') + '><td>' + (i + 1) + '</td><td class="nn-td-item"><b>' + esc(l.n) + '</b>'
                    + (l.mk === 'Y' ? ' <span class="nn-badge is-info">مصنع</span>' : '') + '</td>'
                    + (ro ? '<td>' + qty(l.q) + '</td><td>' + qty(l.s) + '</td><td>' + esc(l.op || '') + '</td><td>' + (l.co === 'Y' ? 'نعم' : '') + '</td>'
                          : '<td><input type="number" step="any" data-l="' + i + '" data-c="q" value="' + esc(l.q) + '"></td>'
                          + '<td><input type="number" step="any" data-l="' + i + '" data-c="s" value="' + esc(l.s || 0) + '"></td>'
                          + '<td><input type="number" step="1" data-l="' + i + '" data-c="op" value="' + esc(l.op || '') + '"></td>'
                          + '<td><input type="checkbox" data-l="' + i + '" data-c="co"' + (l.co === 'Y' ? ' checked' : '') + '></td>')
                    + '<td class="nn-mfg-subs">' + subs + (ro || l.co === 'Y' ? '' : '<button type="button" class="nn-link" data-sub="' + i + '">+ بديل</button>') + '</td>'
                    + '<td>' + money(l.c) + '</td><td>' + money(l.co === 'Y' ? -cost : cost) + '</td><td>' + qty(l.oh) + '</td>'
                    + (ro ? '' : '<td><button type="button" class="nn-je-del" data-del="' + i + '" title="حذف">×</button></td>') + '</tr>';
            }).join('') || '<tr><td colspan="11" class="nn-empty">أضف مكونات القائمة بالبحث أعلاه</td></tr>';
            tf.innerHTML = '<tr><td colspan="8">تكلفة الخامات لكل ' + qty(val('base') || 1) + ' (المتوسط المرجح أو التكلفة المجمعة للمصنع)</td><td>' + money(total) + '</td><td colspan="2"></td></tr>';
        }
        function val(k) { var e = root.querySelector('[data-k="' + k + '"]'); return e ? e.value : d[k]; }
        var subFor = null;
        if (!ro) {
            itemSearch(root.querySelector('.nn-mfg-find'), root.querySelector('.nn-td-results'), function (x) {
                if (subFor != null) {
                    var l = lines[subFor];
                    if (x.id !== l.i && !l.subs.some(function (s) { return s.i === x.id; })) l.subs.push({i: x.id, n: x.no + ' - ' + x.n, f: 1});
                    subFor = null; root.querySelector('.nn-mfg-find').placeholder = 'أضف مكوناً: رقم الصنف أو الكود أو الباركود أو الاسم ثم Enter';
                } else {
                    lines.push({i: x.id, n: x.no + ' - ' + x.n, q: 1, s: 0, c: x.c != null ? x.c : null, oh: x.q, subs: []});
                }
                render();
            });
            root.addEventListener('input', function (e) {
                var t = e.target; if (t.dataset.l == null) { if (t.dataset.k === 'base') render(); return; }
                var l = lines[+t.dataset.l];
                l[t.dataset.c] = t.type === 'checkbox' ? (t.checked ? 'Y' : 'N') : t.value;
                if (t.dataset.c === 'co' || t.dataset.c === 'q' || t.dataset.c === 's') render();
            });
            root.addEventListener('click', function (e) {
                var b = e.target.closest('[data-del],[data-sub],[data-sx]'); if (!b) return;
                if (b.dataset.del != null) lines.splice(+b.dataset.del, 1);
                if (b.dataset.sx != null) { var p = b.dataset.sx.split(':'); lines[+p[0]].subs.splice(+p[1], 1); }
                if (b.dataset.sub != null) {
                    subFor = +b.dataset.sub;
                    var f = root.querySelector('.nn-mfg-find'); f.placeholder = 'ابحث عن البديل لـ ' + lines[subFor].n + ' ثم Enter'; f.focus(); return;
                }
                render();
            });
        }
        root.querySelector('.nn-doc-actions').addEventListener('click', function (e) {
            var b = e.target.closest('[data-a]'); if (!b || !confirmed(b)) return;
            var a = b.dataset.a;
            if (a === 'SAVE' || a === 'PUBLISH') {
                var doc = {id: d.id || null, item: d.id ? d.item : num(val('item')) || null, name: val('name'), type: val('type'), base: num(val('base')) || 1, action: a,
                           lines: lines.map(function (l) { return {i: l.i, q: num(l.q), s: num(l.s), op: l.op ? num(l.op) : null, co: l.co === 'Y' ? 'Y' : 'N',
                                                                   subs: (l.subs || []).map(function (s) { return {i: s.i, f: num(s.f) || 1}; })}; })};
                call(root, 'SAVE_BOM', {p_clob_01: JSON.stringify(doc)}, 'تم الحفظ');
            } else {
                call(root, 'ACT', {x01: a, x02: d.id});
            }
        });
        render();
    })();

    // ================================================================ محرر مسار التصنيع
    (function () {
        var root = document.getElementById('nnRt'); if (!root) return;
        var ro = d.inUse === 'Y' || d.status === 'OBSOLETE';
        var ops = (d.ops || []).map(function (o) { return Object.assign({}, o); });
        var wcs = lists.wcs || [], products = lists.items || [];
        var rate = function (wc) { var w = wcs.filter(function (x) { return String(x.v) === String(wc); })[0]; return w ? num(w.r) : 0; };
        root.innerHTML = head('مسار التصنيع', d.id ? (d.code || '') + ' v' + (d.version || 1) : null, d.id ? d.status : null, d.statusName)
            + (ro && d.id ? '<div class="nn-mfg-note">' + (d.inUse === 'Y' ? 'المسار مستخدم في أوامر إنتاج فلا يعدل؛ أنشئ إصداراً جديداً منه.' : 'الإصدار ملغى الاستخدام.') + '</div>' : '')
            + versions(d.versions, d.id, 23, 'P23_ID')
            + '<div class="nn-doc-fields"><label class="nn-doc-f"><span>المنتج *</span>' + (d.id ? '<b class="nn-doc-v">' + esc(d.itemName) + '</b>'
                : '<select data-k="item">' + options(products, d.item, '- اختر المنتج -') + '</select>') + '</label>'
            + '<label class="nn-doc-f is-wide"><span>اسم المسار</span>' + (ro ? '<b class="nn-doc-v">' + esc(d.name) + '</b>' : '<input data-k="name" value="' + esc(d.name || '') + '">') + '</label>'
            + '<label class="nn-doc-f"><span>كمية حساب الزمن</span><input data-k="lot" type="number" step="any" value="1"></label></div>'
            + '<div class="nn-td-wrap"><table class="nn-td-table"><thead><tr><th>التسلسل</th><th>العملية</th><th>مركز العمل</th><th>إعداد (دقيقة)</th>'
            + '<th>تشغيل للوحدة (دقيقة)</th><th>فحص جودة</th><th>معدل الساعة</th><th>تكلفة الوحدة</th>' + (ro ? '' : '<th></th>') + '</tr></thead><tbody></tbody><tfoot></tfoot></table></div>'
            + (ro ? '' : '<button type="button" class="t-Button nn-je-add" data-add="1"><span class="fa fa-plus" aria-hidden="true"></span> عملية</button>')
            + foot(ro ? (d.id ? [{a: 'NEWVER', n: 'إصدار جديد للتعديل', hot: true}] : [])
                      : [{a: 'SAVE', n: 'حفظ مسودة'}, {a: 'PUBLISH', n: 'حفظ ونشر', hot: true}].concat(d.id ? [{a: 'NEWVER', n: 'نسخة جديدة'},
                         {a: 'OBSOLETE', n: 'إلغاء الاستخدام', confirm: 'إلغاء استخدام هذا المسار؟'}] : []));
        var tb = root.querySelector('tbody'), tf = root.querySelector('tfoot');
        var lot = function () { var e = root.querySelector('[data-k="lot"]'); return Math.max(num(e && e.value) || 1, 1); };
        function render() {
            var tot = 0, mins = 0;
            tb.innerHTML = ops.map(function (o, i) {
                var m = num(o.setup) / lot() + num(o.run), c = m / 60 * rate(o.wc);
                tot += c; mins += m;
                if (ro) return '<tr><td>' + esc(o.seq) + '</td><td class="nn-td-item">' + esc(o.d) + '</td><td>' + esc(o.wcn) + '</td><td>' + qty(o.setup) + '</td><td>'
                             + qty(o.run) + '</td><td>' + (o.qc === 'Y' ? '✔' : '') + '</td><td>' + money(rate(o.wc)) + '</td><td>' + money(c) + '</td></tr>';
                return '<tr><td><input type="number" step="1" data-l="' + i + '" data-c="seq" value="' + esc(o.seq) + '"></td>'
                     + '<td><input data-l="' + i + '" data-c="d" value="' + esc(o.d || '') + '" placeholder="قص، لحام، تجميع، تعبئة..."></td>'
                     + '<td><select data-l="' + i + '" data-c="wc">' + options(wcs, o.wc, '- اختر -') + '</select></td>'
                     + '<td><input type="number" step="any" data-l="' + i + '" data-c="setup" value="' + esc(o.setup || 0) + '"></td>'
                     + '<td><input type="number" step="any" data-l="' + i + '" data-c="run" value="' + esc(o.run || 0) + '"></td>'
                     + '<td><input type="checkbox" data-l="' + i + '" data-c="qc"' + (o.qc === 'Y' ? ' checked' : '') + '></td>'
                     + '<td>' + money(rate(o.wc)) + '</td><td>' + money(c) + '</td><td><button type="button" class="nn-je-del" data-del="' + i + '">×</button></td></tr>';
            }).join('') || '<tr><td colspan="9" class="nn-empty">أضف عمليات التصنيع بالترتيب</td></tr>';
            tf.innerHTML = '<tr><td colspan="3">الزمن والتكلفة للوحدة (الإعداد موزع على ' + qty(lot()) + ')</td><td colspan="2">' + qty(mins) + ' دقيقة</td><td colspan="2"></td><td>'
                         + money(tot) + '</td>' + (ro ? '' : '<td></td>') + '</tr>';
        }
        root.addEventListener('input', function (e) {
            var t = e.target; if (t.dataset.k === 'lot') { render(); return; } if (t.dataset.l == null) return;
            ops[+t.dataset.l][t.dataset.c] = t.type === 'checkbox' ? (t.checked ? 'Y' : 'N') : t.value;
            if (t.dataset.c !== 'd') render();
        });
        root.addEventListener('click', function (e) {
            var b = e.target.closest('[data-del],[data-add]'); if (!b) return;
            if (b.dataset.del != null) ops.splice(+b.dataset.del, 1);
            else { var last = ops.length ? num(ops[ops.length - 1].seq) : 0; ops.push({seq: last + 10, d: '', wc: wcs.length ? wcs[0].v : null, setup: 0, run: 0, qc: 'N'}); }
            render();
        });
        root.querySelector('.nn-doc-actions').addEventListener('click', function (e) {
            var b = e.target.closest('[data-a]'); if (!b || !confirmed(b)) return;
            var a = b.dataset.a, v = function (k) { var x = root.querySelector('[data-k="' + k + '"]'); return x ? x.value : null; };
            if (a === 'SAVE' || a === 'PUBLISH') {
                call(root, 'SAVE_RT', {p_clob_01: JSON.stringify({id: d.id || null, item: d.id ? d.item : num(v('item')) || null, name: v('name'), action: a,
                    ops: ops.map(function (o) { return {seq: num(o.seq), wc: num(o.wc) || null, d: o.d, setup: num(o.setup), run: num(o.run), qc: o.qc === 'Y' ? 'Y' : 'N'}; })})}, 'تم الحفظ');
            } else { call(root, 'ACT', {x01: a, x02: d.id}); }
        });
        render();
    })();

    // ================================================================ منضدة أمر الإنتاج
    (function () {
        var root = document.getElementById('nnMo'); if (!root) return;
        var acts = String(d.actions || '').split(','), can = function (a) { return acts.indexOf(a) >= 0; };
        var editable = !d.id || can('SAVE');
        var products = lists.products || [], whs = lists.whs || [], ccs = lists.ccs || [];
        var prio = [{v: 'LOW', n: 'منخفضة'}, {v: 'NORMAL', n: 'عادية'}, {v: 'HIGH', n: 'عالية'}, {v: 'URGENT', n: 'عاجلة'}];
        var today = new Date().toISOString().slice(0, 10);
        var f = function (k, label, html, wide) { return '<label class="nn-doc-f' + (wide ? ' is-wide' : '') + '"><span>' + label + '</span>' + html + '</label>'; };
        var ro = function (v) { return '<b class="nn-doc-v">' + esc(v == null ? '' : v) + '</b>'; };
        var lbl = function (arr, v) { var x = (arr || []).filter(function (e) { return String(e.v) === String(v); })[0]; return x ? x.n : ''; };
        var h = head('أمر إنتاج', d.no, d.id ? d.status : null, d.statusName,
                     d.id ? ' <span class="nn-mfg-prog"><i style="width:' + num(d.progress) + '%"></i></span> ' + num(d.progress) + '%' : '');
        if (d.hold) h += '<div class="nn-mfg-note">' + esc(d.status === 'CANCELLED' ? 'سبب الإلغاء: ' : 'سبب الإيقاف: ') + esc(d.hold) + '</div>';
        h += '<div class="nn-doc-fields">'
           + f('item', 'المنتج *', d.id ? ro(d.itemName) : '<select data-k="item">' + options(products, d.item, '- اختر المنتج -') + '</select>')
           + f('qty', 'الكمية المخططة *', editable ? '<input data-k="qty" type="number" step="any" value="' + esc(d.qty || '') + '">' : ro(qty(d.qty)))
           + f('date', 'تاريخ الأمر', editable ? '<input data-k="date" type="date" value="' + esc(d.date || today) + '">' : ro(d.date))
           + f('start', 'البداية المخططة', editable ? '<input data-k="start" type="date" value="' + esc(d.start || '') + '">' : ro(d.start))
           + f('end', 'النهاية المخططة', editable ? '<input data-k="end" type="date" value="' + esc(d.end || '') + '">' : ro(d.end))
           + f('priority', 'الأولوية', editable ? '<select data-k="priority">' + options(prio, d.priority || 'NORMAL') + '</select>' : ro(lbl(prio, d.priority)))
           + f('wh', 'مستودع استلام الإنتاج', editable ? '<select data-k="wh">' + options(whs, d.wh) + '</select>' : ro(lbl(whs, d.wh)))
           + f('swh', 'مستودع صرف الخامات', editable ? '<select data-k="swh">' + options(whs, d.swh || d.wh) + '</select>' : ro(lbl(whs, d.swh)))
           + f('cc', 'مركز التكلفة', editable ? '<select data-k="cc">' + options(ccs, d.cc, 'من مركز العمل') + '</select>' : ro(lbl(ccs, d.cc)))
           + f('lot', 'دفعة المنتج', editable ? '<input data-k="lot" value="' + esc(d.lot || '') + '" placeholder="افتراضياً رقم الأمر">' : ro(d.lot))
           + f('exp', 'انتهاء الصلاحية', editable ? '<input data-k="exp" type="date" value="' + esc(d.exp || '') + '">' : ro(d.exp))
           + f('qc', 'فحص جودة قبل الاستلام', editable ? '<select data-k="qc">' + options([{v: 'N', n: 'حسب المسار'}, {v: 'Y', n: 'إلزامي'}], d.qc === 'Y' ? 'Y' : 'N') + '</select>'
                                                   : ro(d.qc === 'Y' ? 'نعم' : 'لا'))
           + f('notes', 'ملاحظات', editable ? '<input data-k="notes" value="' + esc(d.notes || '') + '">' : ro(d.notes), true)
           + '</div>';
        if (d.id) {
            h += '<div class="nn-mfg-sum">'
               + '<div><span>قائمة المواد</span><b>' + esc(d.bomName || '') + '</b></div><div><span>المسار</span><b>' + esc(d.routingName || 'بدون') + '</b></div>'
               + '<div><span>المقبول / الهالك</span><b>' + qty(d.done) + ' / ' + qty(d.scrap) + '</b></div>'
               + '<div><span>التكلفة المعيارية للوحدة</span><b>' + money(d.stdUnit) + '</b></div>'
               + '<div><span>التقديرية</span><b>' + money(d.estimated) + '</b></div><div><span>الفعلية</span><b>' + money(d.actual) + '</b></div></div>';
            var tabs = [['mat', 'الخامات'], ['ops', 'العمليات'], ['out', 'الإنتاج والجودة'], ['cost', 'التكلفة والقيود']];
            h += '<div class="nn-mfg-tabs" role="tablist">' + tabs.map(function (t, i) { return '<button type="button" role="tab" data-tab="' + t[0] + '"' + (i === 0 ? ' class="is-on"' : '') + '>' + t[1] + '</button>'; }).join('') + '</div>';
            // الخامات
            var canMove = can('ISSUE'), canRet = can('RETURN');
            h += '<div class="nn-mfg-pane" data-pane="mat"><div class="nn-td-wrap"><table class="nn-td-table"><thead><tr><th>المادة</th><th>العملية</th><th>المطلوب</th>'
               + '<th>المصروف</th><th>المرتجع</th><th>المتبقي</th><th>الرصيد بالمستودع</th><th>التكلفة الفعلية</th>' + (canMove ? '<th>صرف</th>' : '') + (canRet ? '<th>إرجاع</th>' : '')
               + '</tr></thead><tbody>' + (d.materials || []).map(function (m) {
                   var short = num(m.rem) > num(m.oh);
                   return '<tr' + (short ? ' class="nn-rpt-warn"' : '') + '><td class="nn-td-item"><b>' + esc(m.n) + '</b>' + (m.sub === 'Y' ? ' <span class="nn-badge is-info">بديل</span>' : '')
                        + (canMove && m.subs && num(m.rem) > 0 ? ' <select class="nn-mfg-subsel" data-m="' + m.id + '">' + opt('', 'استبدال بـ...') + m.subs.map(function (s) {
                              return opt(s.i, s.n + ' (رصيد ' + qty(s.oh) + ')'); }).join('') + '</select>' : '') + '</td>'
                        + '<td>' + esc(m.op || '') + '</td><td>' + qty(m.req) + '</td><td>' + qty(m.iss) + '</td><td>' + qty(m.ret) + '</td><td><b>' + qty(m.rem) + '</b></td>'
                        + '<td>' + qty(m.oh) + (short ? ' <span class="nn-badge is-danger">نقص</span>' : '') + '</td><td>' + money(m.cost) + '</td>'
                        + (canMove ? '<td><input type="number" step="any" min="0" class="nn-mfg-q" data-iss="' + m.id + '" value="' + (num(m.rem) > 0 ? esc(Math.min(num(m.rem), Math.max(num(m.oh), 0))) : '') + '"></td>' : '')
                        + (canRet ? '<td><input type="number" step="any" min="0" class="nn-mfg-q" data-ret="' + m.id + '" placeholder="0"' + (num(m.iss) - num(m.ret) > 0 ? '' : ' disabled') + '></td>' : '')
                        + '</tr>'; }).join('') + '</tbody></table></div>'
               + (canMove || canRet ? '<div class="nn-mfg-bar"><label class="nn-doc-f"><span>تاريخ الحركة</span><input type="date" data-k="mdate" value="' + today + '"></label>'
                    + (canMove ? '<button type="button" class="t-Button t-Button--hot" data-do="ISSUE">صرف الكميات المحددة</button>' : '')
                    + (canRet ? '<button type="button" class="t-Button" data-do="RETURN">إرجاع الكميات المحددة</button>' : '') + '</div>' : '')
               + '</div>';
            // العمليات
            var canOp = can('OPERATION');
            h += '<div class="nn-mfg-pane" data-pane="ops" hidden><div class="nn-td-wrap"><table class="nn-td-table"><thead><tr><th>العملية</th><th>مركز العمل</th><th>المخطط (دقيقة)</th>'
               + '<th>الفعلي</th><th>المقبول</th><th>الهالك</th><th>الحالة</th></tr></thead><tbody>' + (d.operations || []).map(function (o) {
                   return '<tr><td class="nn-td-item"><b>' + esc(o.seq) + ' - ' + esc(o.d) + '</b>' + (o.qc === 'Y' ? ' <span class="nn-badge is-warning">جودة</span>' : '') + '</td><td>'
                        + esc(o.wcn) + '</td><td>' + qty(o.plan) + '</td><td>' + qty(o.act) + '</td><td>' + qty(o.good) + '</td><td>' + qty(o.scrap) + '</td><td>' + badge(o.st, o.sn) + '</td></tr>';
               }).join('') + '</tbody></table></div>';
            var openOps = (d.operations || []).filter(function (o) { return o.st === 'PENDING' || o.st === 'IN_PROGRESS'; });
            if (canOp && openOps.length) {
                h += '<div class="nn-mfg-form"><b>تسجيل تنفيذ عملية</b><div class="nn-doc-fields">'
                   + f('op', 'العملية', '<select data-k="op">' + openOps.map(function (o) { return opt(o.id, o.seq + ' - ' + o.d + ' (' + o.wcn + ')'); }).join('') + '</select>')
                   + f('odate', 'التاريخ', '<input type="date" data-k="odate" value="' + today + '">')
                   + f('setup', 'زمن الإعداد (دقيقة)', '<input type="number" step="any" data-k="setup" value="0">')
                   + f('run', 'زمن التشغيل (دقيقة)', '<input type="number" step="any" data-k="run">')
                   + f('good', 'الكمية المقبولة', '<input type="number" step="any" data-k="good">')
                   + f('oscrap', 'الهالك', '<input type="number" step="any" data-k="oscrap" value="0">')
                   + f('rework', 'إعادة تشغيل', '<input type="number" step="any" data-k="rework" value="0">')
                   + f('down', 'التوقف (دقيقة)', '<input type="number" step="any" data-k="down" value="0">')
                   + f('done', 'إنهاء العملية', '<select data-k="done">' + opt('N', 'لا، تقرير جزئي') + opt('Y', 'نعم، العملية منتهية') + '</select>')
                   + '</div><button type="button" class="t-Button t-Button--hot" data-do="OP">تسجيل وترحيل التكلفة</button></div>';
            }
            h += '</div>';
            // الإنتاج والجودة
            var canOut = can('OUTPUT');
            h += '<div class="nn-mfg-pane" data-pane="out" hidden><div class="nn-td-wrap"><table class="nn-td-table"><thead><tr><th>التاريخ</th><th>الكمية</th>'
               + '<th>الدفعة</th><th>المقبول</th><th>المرفوض</th><th>التكلفة</th><th>حركة المخزون</th><th>الحالة</th><th></th></tr></thead><tbody>' + (d.outputs || []).map(function (t) {
                   return '<tr><td>' + esc(t.date) + '</td><td>' + qty(t.q) + '</td><td>' + esc(t.lot || '') + '</td><td>' + qty(t.pass) + '</td><td>' + qty(t.fail) + '</td><td>'
                        + money(t.cost) + '</td><td>' + esc(t.txn || '') + '</td><td>' + badge(t.st, t.sn) + '</td><td>'
                        + (t.st === 'PENDING_QUALITY' ? '<button type="button" class="t-Button t-Button--small t-Button--hot" data-qc="' + t.id + '" data-qq="' + t.q + '">فحص الجودة</button>' : '')
                        + '</td></tr>'; }).join('') + '</tbody></table></div>';
            if (canOut) {
                h += '<div class="nn-mfg-form"><b>استلام إنتاج تام</b>' + (d.qc === 'Y' ? ' <span class="nn-badge is-warning">يحفظ بانتظار فحص الجودة قبل دخول المخزون</span>' : '')
                   + '<div class="nn-doc-fields">'
                   + f('oqty', 'الكمية المنتجة', '<input type="number" step="any" data-k="oqty" value="' + esc(Math.max(num(d.qty) - num(d.done), 0) || '') + '">')
                   + f('osc', 'هالك نهائي (لا يستلم)', '<input type="number" step="any" data-k="osc" value="0">')
                   + f('tdate', 'التاريخ', '<input type="date" data-k="tdate" value="' + today + '">')
                   + f('olot', 'رقم الدفعة', '<input data-k="olot" value="' + esc(d.lot || '') + '" placeholder="افتراضياً دفعة الأمر">')
                   + f('oexp', 'الانتهاء', '<input type="date" data-k="oexp" value="' + esc(d.exp || '') + '">')
                   + '</div><button type="button" class="t-Button t-Button--hot" data-do="OUTPUT">تسجيل الاستلام</button></div>';
            }
            h += '<div class="nn-mfg-form" data-qcform hidden><b>نتيجة فحص الجودة</b><div class="nn-doc-fields">'
               + f('qpass', 'المقبول', '<input type="number" step="any" data-k="qpass">') + f('qfail', 'المرفوض', '<input type="number" step="any" data-k="qfail" value="0">')
               + f('qdate', 'تاريخ الفحص', '<input type="date" data-k="qdate" value="' + today + '">')
               + f('qnotes', 'ملاحظات الفاحص', '<input data-k="qnotes">', true)
               + '</div><button type="button" class="t-Button t-Button--hot" data-do="INSPECT">اعتماد النتيجة</button></div></div>';
            // التكلفة
            h += '<div class="nn-mfg-pane" data-pane="cost" hidden><div class="nn-td-wrap"><table class="nn-td-table"><thead><tr><th>العنصر</th><th>المعياري للوحدة</th>'
               + '<th>المحمل</th><th>المخفض بالإنتاج</th><th>الانحراف المقفل</th><th>الرصيد تحت التشغيل</th></tr></thead><tbody>';
            var std = d.std || {}, tw = {charge: 0, relief: 0, 'var': 0, bal: 0};
            ['MATERIAL', 'LABOR', 'MACHINE', 'OVERHEAD'].forEach(function (el) {
                var w = (d.wip || []).filter(function (x) { return x.el === el; })[0] || {};
                ['charge', 'relief', 'var', 'bal'].forEach(function (k) { tw[k] += num(w[k]); });
                h += '<tr><td class="nn-td-item">' + esc({MATERIAL: 'الخامات', LABOR: 'العمالة', MACHINE: 'الآلات', OVERHEAD: 'التحميل الصناعي'}[el]) + '</td><td>' + money(std[el])
                   + '</td><td>' + money(w.charge) + '</td><td>' + money(w.relief) + '</td><td>' + money(w['var']) + '</td><td>' + money(w.bal) + '</td></tr>';
            });
            h += '</tbody><tfoot><tr><td>الإجمالي</td><td>' + money(d.stdUnit) + '</td><td>' + money(tw.charge) + '</td><td>' + money(tw.relief) + '</td><td>' + money(tw['var'])
               + '</td><td>' + money(tw.bal) + '</td></tr></tfoot></table></div>'
               + '<h4 class="nn-mfg-h">القيود المحاسبية للأمر</h4><div class="nn-td-wrap"><table class="nn-td-table"><thead><tr><th>القيد</th><th>التاريخ</th><th>البيان</th><th>المبلغ</th></tr></thead><tbody>'
               + ((d.journals || []).map(function (j) { return '<tr><td>' + esc(j.no) + '</td><td>' + esc(j.date) + '</td><td class="nn-td-item">' + esc(j.d) + '</td><td>' + money(j.amt) + '</td></tr>'; }).join('')
                  || '<tr><td colspan="4" class="nn-empty">لا توجد قيود بعد</td></tr>') + '</tbody></table></div></div>';
        } else if (d.item == null) {
            h += '<div class="nn-mfg-note">اختر المنتج والكمية؛ تحسب الاحتياجات من قائمة المواد المنشورة والعمليات من مسار التصنيع وتظهر بعد الحفظ.</div>';
        }
        var acts2 = [];
        if (editable) acts2.push({a: 'SAVE', n: 'حفظ'});
        if (can('APPROVE')) acts2.push({a: 'APPROVE', n: 'اعتماد'});
        if (!d.id || can('RELEASE')) acts2.push({a: 'RELEASE', n: 'اعتماد وإطلاق للتنفيذ', hot: true, confirm: 'الإطلاق يثبت قائمة المواد والمسار والتكلفة المعيارية ولا يعدل الأمر بعدها. متابعة؟'});
        if (can('HOLD')) acts2.push({a: 'HOLD', n: 'إيقاف'});
        if (can('RESUME')) acts2.push({a: 'RESUME', n: 'استئناف', hot: true});
        if (can('COMPLETE')) acts2.push({a: 'COMPLETE', n: 'إكمال الأمر', confirm: 'لن يقبل الأمر إنتاجاً إضافياً بعد الإكمال. متابعة؟'});
        if (can('CLOSE')) acts2.push({a: 'CLOSE', n: 'إقفال وتسوية الانحرافات', hot: !can('OUTPUT'), confirm: 'يرحل رصيد الإنتاج تحت التشغيل كانحرافات ويقفل الأمر نهائياً. متابعة؟'});
        if (can('CANCEL')) acts2.push({a: 'CANCEL', n: 'إلغاء الأمر'});
        h += foot(acts2);
        root.innerHTML = h;
        var v = function (k) { var x = root.querySelector('[data-k="' + k + '"]'); return x ? x.value : null; };
        // التبويبات
        root.querySelectorAll('[data-tab]').forEach(function (b) {
            b.addEventListener('click', function () {
                root.querySelectorAll('[data-tab]').forEach(function (x) { x.classList.toggle('is-on', x === b); });
                root.querySelectorAll('[data-pane]').forEach(function (p) { p.hidden = p.dataset.pane !== b.dataset.tab; });
            });
        });
        var tab = (window.location.hash || '').replace('#', '');
        if (tab) { var tb = root.querySelector('[data-tab="' + tab + '"]'); if (tb) tb.click(); }
        var go = function (pane) { return function () { if (pane) window.location.hash = pane; }; };
        // الاستبدال بالبديل
        root.querySelectorAll('.nn-mfg-subsel').forEach(function (s) {
            s.addEventListener('change', function () {
                if (!s.value || !window.confirm('استبدال الكمية المتبقية بالبديل المختار؟')) { s.value = ''; return; }
                go('mat')(); call(root, 'SUBST', {x01: s.dataset.m, x02: s.value});
            });
        });
        root.addEventListener('click', function (e) {
            var q = e.target.closest('[data-qc]');
            if (q) { var fm = root.querySelector('[data-qcform]'); fm.hidden = false; fm.dataset.out = q.dataset.qc; fm.querySelector('[data-k="qpass"]').value = q.dataset.qq; fm.scrollIntoView({behavior: 'smooth'}); return; }
            var b = e.target.closest('[data-do]'); if (!b) return;
            var k = b.dataset.do, doc;
            if (k === 'ISSUE' || k === 'RETURN') {
                var attr = k === 'ISSUE' ? 'data-iss' : 'data-ret', ls = [];
                root.querySelectorAll('[' + attr + ']').forEach(function (i) { if (num(i.value) > 0) ls.push({m: num(i.getAttribute(attr)), q: num(i.value)}); });
                if (!ls.length) { var m = root.querySelector('.nn-doc-msg'); m.className = 'nn-doc-msg is-bad'; m.textContent = 'أدخل الكميات أولاً'; return; }
                doc = {order: d.id, date: v('mdate'), lines: ls}; go('mat')();
            } else if (k === 'OP') {
                doc = {order: d.id, op: num(v('op')), date: v('odate'), setup: num(v('setup')), run: num(v('run')), good: num(v('good')), scrap: num(v('oscrap')),
                       rework: num(v('rework')), down: num(v('down')), done: v('done')}; go('ops')();
            } else if (k === 'OUTPUT') {
                doc = {order: d.id, qty: num(v('oqty')), scrap: num(v('osc')), date: v('tdate'), lot: v('olot') || null, exp: v('oexp') || null,
                       key: d.id + '-' + Date.now()}; go('out')();
            } else if (k === 'INSPECT') {
                doc = {output: num(root.querySelector('[data-qcform]').dataset.out), passed: num(v('qpass')), failed: num(v('qfail')), date: v('qdate'), notes: v('qnotes')};
                go('out')();
            }
            call(root, 'POST', {x01: k, p_clob_01: JSON.stringify(doc)}, 'تم الترحيل');
        });
        root.querySelector('.nn-doc-actions').addEventListener('click', function (e) {
            var b = e.target.closest('[data-a]'); if (!b || !confirmed(b)) return;
            var a = b.dataset.a;
            if (a === 'SAVE' || (a === 'RELEASE' && editable) || (a === 'APPROVE' && editable)) {
                call(root, 'SAVE_MO', {p_clob_01: JSON.stringify({id: d.id || null, item: d.id ? d.item : num(v('item')) || null, qty: num(v('qty')), date: v('date'),
                    start: v('start') || null, end: v('end') || null, priority: v('priority'), wh: num(v('wh')) || null, swh: num(v('swh')) || null, cc: num(v('cc')) || null,
                    lot: v('lot') || null, exp: v('exp') || null, qc: v('qc'), notes: v('notes'), action: a})}, 'تم الحفظ');
                return;
            }
            var reason = null;
            if (a === 'HOLD' || a === 'CANCEL') { reason = window.prompt(a === 'HOLD' ? 'سبب الإيقاف:' : 'سبب الإلغاء:'); if (!reason) return; }
            call(root, 'ACT', {x01: a, x02: d.id, x03: reason});
        });
    })();

    // ================================================================ تخطيط احتياجات المواد
    (function () {
        var root = document.getElementById('nnMrp'); if (!root) return;
        var rows = Array.isArray(d) ? d : [];
        root.innerHTML = '<div class="nn-mfg-note">الطلب = أوامر البيع المفتوحة + احتياجات أوامر الإنتاج + الوصول لحد الطلب الأعلى. الوارد = الرصيد + أوامر الإنتاج والشراء وطلبات الشراء المفتوحة. '
            + 'المصنع ينفجر على مكوناته مستوى بمستوى. حدد المقترحات وعدل الكميات ثم نفذ: تنشأ أوامر إنتاج مخططة وطلب شراء مسودة.</div>'
            + '<div class="nn-td-wrap"><table class="nn-td-table"><thead><tr><th><input type="checkbox" data-all checked></th><th>المستوى</th><th>الصنف</th><th>الإجراء</th>'
            + '<th>الرصيد</th><th>الوارد</th><th>الطلب</th><th>حد الطلب</th><th>صافي الاحتياج</th><th>الكمية المنفذة</th><th>التكلفة التقديرية</th></tr></thead><tbody>'
            + (rows.map(function (r, i) {
                return '<tr><td><input type="checkbox" data-pick="' + i + '" checked></td><td>' + r.lvl + '</td><td class="nn-td-item"><b>' + esc(r.n) + '</b></td><td>'
                     + (r.t === 'MAKE' ? '<span class="nn-badge is-info">تصنيع</span>' : '<span class="nn-badge is-warning">شراء</span>') + '</td><td>' + qty(r.oh) + '</td><td>' + qty(r.sup)
                     + '</td><td>' + qty(r.gross) + '</td><td>' + qty(r.min) + '</td><td><b>' + qty(r.net) + '</b></td><td><input type="number" step="any" data-q="' + i + '" value="'
                     + esc(r.net) + '"></td><td>' + money(num(r.net) * num(r.c)) + '</td></tr>';
            }).join('') || '<tr><td colspan="11" class="nn-empty">لا توجد احتياجات: الأرصدة والوارد يغطيان الطلب</td></tr>')
            + '</tbody></table></div>' + foot(rows.length ? [{a: 'EXEC', n: 'تنفيذ المقترحات المحددة', hot: true, confirm: 'إنشاء أوامر إنتاج مخططة وطلب شراء بالمحدد؟'}] : []);
        var all = root.querySelector('[data-all]');
        if (all) all.addEventListener('change', function () { root.querySelectorAll('[data-pick]').forEach(function (c) { c.checked = all.checked; }); });
        var acts = root.querySelector('.nn-doc-actions');
        if (acts) acts.addEventListener('click', function (e) {
            var b = e.target.closest('[data-a]'); if (!b || !confirmed(b)) return;
            var ls = [];
            root.querySelectorAll('[data-pick]').forEach(function (c) {
                if (!c.checked) return; var r = rows[+c.dataset.pick], q = num(root.querySelector('[data-q="' + c.dataset.pick + '"]').value);
                if (q > 0) ls.push({i: r.i, q: q, t: r.t});
            });
            if (!ls.length) return;
            call(root, 'EXEC', {p_clob_01: JSON.stringify({lines: ls})}, 'تم التنفيذ');
        });
    })();
})();
