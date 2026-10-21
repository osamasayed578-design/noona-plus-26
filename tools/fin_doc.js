// المستند الورقي (قيد يومية أو سند): رأس وتذييل يبنيان من JSON مضمن؛ السطور في nnJe (شبكة GRID_JS)؛
// الحفظ والإرسال: كائن JSON واحد (رأس + سطور) بعملية AJAX واحدة SAVE_DOC دون إعادة تحميل الصفحة عند الخطأ
(function () {
    var root = document.getElementById('nnDoc'); if (!root) return;
    var data = function (id) { var el = document.getElementById(id); try { return JSON.parse(el ? el.textContent : 'null'); } catch (e) { return null; } };
    var d = data('nnDocData') || {}, curs = data('nnDocCurs') || [], places = data('nnDocPlaces') || [], types = data('nnDocTypes') || [];
    var je = root.dataset.kind === 'JE', ro = root.dataset.ro === 'Y', fc = root.dataset.fc;
    var esc = function (s) { return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'}[c]; }); };
    var titles = {RECEIPT: 'سند قبض', PAYMENT: 'سند صرف', EXPENSE: 'سند مصروفات'};
    var stl = {DRAFT: 'مسودة', SUBMITTED: 'بانتظار الاعتماد', APPROVED: 'معتمد', POSTED: 'مرحل', SETTLED: 'مرحل', REVERSED: 'معكوس', CANCELLED: 'ملغى'};
    var typeOf = function (c) { return types.filter(function (t) { return t.c === c; })[0] || null; };
    var title = je ? (d.typeName || (typeOf(d.type) || {}).n || 'قيد يومية') : (titles[d.type] || 'سند');
    var rateOf = function (c) { if (!c || c === fc) return 1; var x = curs.filter(function (k) { return k.c === c; })[0]; return x ? x.r : null; };
    var placeOf = function (v) { return places.filter(function (p) { return p.v === v; })[0] || null; };
    var opt = function (v, t, sel) { return '<option value="' + esc(v) + '"' + (String(v) === String(sel == null ? '' : sel) ? ' selected' : '') + '>' + esc(t) + '</option>'; };
    var field = function (cls, label, input, wide) { return '<label class="nn-doc-f ' + cls + (wide ? ' is-wide' : '') + '"><span>' + label + '</span>' + input + '</label>'; };
    var inp = function (k, v, type, extra) {
        return ro ? '<b class="nn-doc-v">' + esc(v) + '</b>'
                  : '<input data-k="' + k + '" type="' + (type || 'text') + '" value="' + esc(v) + '"' + (extra || '') + '>';
    };
    var h = '<div class="nn-doc-head"><div class="nn-doc-co">' + esc(root.dataset.co) + '</div>'
          + '<div class="nn-doc-title">' + title + '<small>' + esc(stl[d.status] || d.status || '') + '</small></div>'
          + '<div class="nn-doc-no"><span>الرقم</span><b>' + esc(d.no || 'جديد') + '</b></div></div><div class="nn-doc-fields">';
    h += field('', 'التاريخ', inp('date', d.date, 'date'));
    if (je) {
        // نوع القيد: يحدد قواعده (افتتاحي، مرجع إلزامي، عكس آلي للاستحقاقات)
        var ts = ro ? '<b class="nn-doc-v">' + esc(d.typeName || d.type) + '</b>'
                    : '<select data-k="type">' + types.map(function (t) { return opt(t.c, t.n, d.type || 'GENERAL'); }).join('') + '</select>';
        h += field('nn-doc-type', 'نوع القيد', ts);
        h += field('nn-doc-rev', 'يعكس آلياً في', inp('rev', d.rev, 'date'));
        var cs = ro ? '<b class="nn-doc-v">' + esc(d.cur) + '</b>'
                    : '<select data-k="cur">' + curs.map(function (c) { return opt(c.c, c.c + ' - ' + c.n, d.cur); }).join('') + '</select>';
        h += field('', 'العملة', cs) + field('nn-doc-rate', 'سعر الصرف', inp('rate', d.rate, 'number', ' step="0.000001" min="0"'));
        h += field('nn-doc-refbox', 'المرجع', inp('ref', d.ref)) + field('', 'البيان', inp('desc', d.desc), true);
        h += '<div class="nn-doc-typehint" aria-live="polite"></div>';
    } else {
        var ps = ro ? '<b class="nn-doc-v">' + esc((placeOf(d.place) || {}).n || '') + '</b>'
                    : '<select data-k="place">' + places.map(function (p) {
                          return opt(p.v, (p.k === 'BOX' ? 'صندوق: ' : 'بنك: ') + p.n + ' (' + p.c + ')', d.place); }).join('') + '</select>';
        var chs = [['BANK_TRANSFER', 'تحويل بنكي'], ['CHEQUE', 'شيك'], ['CARD', 'بطاقة'], ['WALLET', 'محفظة إلكترونية'], ['GATEWAY', 'بوابة دفع'], ['DIRECT_DEBIT', 'خصم مباشر']];
        var ch = ro ? '<b class="nn-doc-v">' + esc((chs.filter(function (c) { return c[0] === d.channel; })[0] || ['', 'نقداً'])[1]) + '</b>'
                    : '<select data-k="channel">' + chs.map(function (c) { return opt(c[0], c[1], d.channel); }).join('') + '</select>';
        h += field('', d.type === 'RECEIPT' ? 'الصندوق / البنك المستلم' : 'الصرف من', ps) + field('nn-doc-ch', 'طريقة الدفع', ch);
        h += field('', d.type === 'RECEIPT' ? 'استلمنا من السيد/السادة' : 'صرفنا إلى السيد/السادة', inp('party', d.party), true);
        h += field('', 'المرجع (شيك / حوالة / فاتورة)', inp('ref', d.ref))
           + field('nn-doc-rate', 'سعر الصرف', inp('rate', d.rate, 'number', ' step="0.000001" min="0"'));
        h += field('', 'وذلك عن', inp('desc', d.desc), true);
    }
    h += '</div><div id="nnJe" class="nn-je" data-kind="' + (je ? 'JE' : 'CV') + '" data-readonly="' + (ro ? 'Y' : 'N') + '"></div>';
    h += '<div class="nn-doc-foot">'
       + (je ? '' : '<div class="nn-doc-total"><span>المبلغ</span><b id="nnCvTotal"></b><em>' + esc(d.cur || '') + '</em></div>')
       + (d.words ? '<div class="nn-words">' + esc(d.words) + '</div>' : '')
       + '<div class="nn-doc-msg" role="alert"></div>'
       + (ro ? '' : '<div class="nn-doc-actions"><button type="button" class="t-Button nn-doc-save" data-a="SAVE">حفظ</button>'
                  + '<button type="button" class="t-Button t-Button--hot nn-doc-save" data-a="SUBMIT">حفظ وإرسال للاعتماد</button></div>')
       + '</div>';
    root.innerHTML = h;
    var lines = document.getElementById('nnJeLines');
    if (!lines) { lines = document.createElement('script'); lines.type = 'application/json'; lines.id = 'nnJeLines'; document.body.appendChild(lines); }
    lines.textContent = JSON.stringify(d.lines || []);
    var q = function (k) { return root.querySelector('[data-k="' + k + '"]'); };
    function syncRate(force) {
        var place = (q('place') || {}).value || d.place || '';
        var c = je ? ((q('cur') || {}).value || d.cur) : ((placeOf(place) || {}).c || d.cur || fc);
        var box = root.querySelector('.nn-doc-rate');
        if (box) box.style.display = c === fc ? 'none' : '';
        var r = q('rate');
        if (r) {
            if (c === fc) { r.value = ''; }
            else if (force || !r.value) { var v = rateOf(c); r.value = v == null ? '' : v; r.placeholder = v == null ? 'لا يوجد سعر معتمد - أدخله' : ''; }
        }
        var chb = root.querySelector('.nn-doc-ch');
        if (chb && !je) chb.style.display = place.indexOf('BANK:') === 0 ? '' : 'none';
        var cur = root.querySelector('.nn-doc-total em'); if (cur) cur.textContent = c;
    }
    // إظهار تاريخ العكس الآلي ووصف النوع حسب النوع المختار
    function syncType() {
        if (!je) return;
        var t = typeOf((q('type') || {}).value || d.type) || {};
        var rb = root.querySelector('.nn-doc-rev');
        if (rb) rb.style.display = (t.rev === 'Y' || (ro && d.rev)) ? '' : 'none';
        var ref = root.querySelector('.nn-doc-refbox > span');
        if (ref) ref.textContent = t.ref === 'Y' ? 'المرجع (إلزامي لهذا النوع)' : 'المرجع';
        var hint = root.querySelector('.nn-doc-typehint');
        if (hint) hint.textContent = ro ? '' : (t.d || '') + (t.rev === 'Y' ? ' - يترك تاريخ العكس فارغاً ليكون أول يوم في الفترة التالية' : '')
                                           + (t.opn === 'Y' ? ' - تاريخه في الفترة الأولى من السنة المالية' : '');
        var tt = root.querySelector('.nn-doc-title');
        if (tt && t.n) tt.firstChild.nodeValue = t.n;
    }
    syncRate(false);
    syncType();
    if (ro) return;
    root.addEventListener('change', function (e) {
        if (e.target.dataset.k === 'cur' || e.target.dataset.k === 'place') syncRate(true);
        if (e.target.dataset.k === 'type') syncType();
    });
    root.addEventListener('click', function (e) {
        var b = e.target.closest('.nn-doc-save'); if (!b) return;
        var doc = {id: d.id || null, action: b.dataset.a, lines: window.nnGrid ? window.nnGrid.collect() : []};
        root.querySelectorAll('[data-k]').forEach(function (el) { doc[el.dataset.k] = el.value === '' ? null : el.value; });
        if (doc.rate != null) doc.rate = parseFloat(doc.rate);
        if (!je) doc.type = d.type;
        var msg = root.querySelector('.nn-doc-msg'), btns = root.querySelectorAll('.nn-doc-save');
        var fail = function (t) { msg.className = 'nn-doc-msg is-bad'; msg.textContent = t; btns.forEach(function (x) { x.disabled = false; }); };
        msg.className = 'nn-doc-msg'; msg.textContent = 'جار الحفظ...';
        btns.forEach(function (x) { x.disabled = true; });
        apex.server.process('SAVE_DOC', {p_clob_01: JSON.stringify(doc)}, {dataType: 'json'}).done(function (r) {
            if (r && r.ok) {
                msg.className = 'nn-doc-msg is-ok'; msg.textContent = b.dataset.a === 'SUBMIT' ? 'تم الحفظ والإرسال للاعتماد' : 'تم الحفظ';
                window.location.href = r.url;
            } else { fail((r && r.msg) || 'تعذر الحفظ'); }
        }).fail(function () { fail('تعذر الاتصال بالخادم'); });
    });
})();
