/* NOONA PLUS | hist.js - أرقام السنوات السابقة للمقارنة (BI_HISTORY_VALUE عبر NOONA_ANL_PKG)
 * عملية AJAX «HIST» في الصفحة:
 *   x01=META                                   ← المؤشرات المسموحة، الفروع، ملخص ما أدخل
 *   x01=GET  x02=المؤشر x03=السنة x04=الفرع     ← أشهر السنة: الرقم المدخل والفعلي في النظام وحالة القفل
 *   x01=SAVE x02..x04 x05=[12 قيمة] x06=ملاحظة   ← حفظ (الفارغ يحذف)
 *   x01=IMPORT f01=نص CSV مقسم                   ← استيراد metric,yyyy-mm,value[,branch_code]
 * الأشهر التي فيها بيانات فعلية في النظام مقفلة: أرقام السنوات السابقة للفترة قبل بدء العمل على نونا فقط.
 */
(function () {
    'use strict';
    var root = document.getElementById('nnHist');
    if (!root) return;
    var MONTHS = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    var nf = new Intl.NumberFormat('ar-u-nu-latn', {maximumFractionDigits: 2});
    var state = {meta: null, data: null, dirty: false};
    var Y = new Date().getFullYear();

    function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c]; }); }
    function months(n) { return n === 1 ? 'شهر واحد' : n === 2 ? 'شهرين' : n >= 3 && n <= 10 ? n + ' أشهر' : n + ' شهراً'; }
    function fmt(v) { return v == null || isNaN(v) ? '—' : nf.format(v); }
    function call(x) {
        return new Promise(function (ok, bad) {
            apex.server.process('HIST', x, {dataType: 'text'}).done(function (t) {
                var d; try { d = JSON.parse(t); } catch (e) { bad('تعذر قراءة البيانات'); return; }
                if (d && d.ok === false) bad(d.msg || 'تعذر تنفيذ الطلب'); else ok(d);
            }).fail(function () { bad('تعذر الاتصال بالخادم'); });
        });
    }
    function msg(t, isErr) {
        apex.message.clearErrors();
        if (isErr) apex.message.showErrors([{type: 'error', location: 'page', message: t, unsafe: false}]);
        else apex.message.showPageSuccess(t);
    }
    function num(s) {
        s = String(s == null ? '' : s).trim().replace(/[٠-٩]/g, function (d) { return '٠١٢٣٤٥٦٧٨٩'.indexOf(d); }).replace(/[,\s٬]/g, '').replace('٫', '.');
        return s === '' ? null : s;
    }

    var years = '';
    for (var y = Y; y >= Y - 15; y--) years += '<option value="' + y + '"' + (y === Y - 1 ? ' selected' : '') + '>' + y + '</option>';
    root.innerHTML =
        '<div class="nn-hist-intro"><span class="fa fa-history" aria-hidden="true"></span><div><b>أرقام السنوات السابقة</b>' +
        '<p>أدخل الأرقام الشهرية من نظامك السابق لأي مؤشر في أي موديول، فتظهر في «مقارنة السنوات» والتنبؤ بجانب أرقام نونا. ' +
        'الأشهر التي فيها حركة فعلية في النظام مقفلة منعاً لتكرار الأرقام. للمالية يمكنك بدلاً من ذلك فتح السنة المالية السابقة وترحيل قيودها.</p></div></div>' +
        '<div class="nn-hist-bar">' +
        '  <label class="nn-anl-ctl">المؤشر <select class="nn-hist-metric"><option value="">جار التحميل...</option></select></label>' +
        '  <label class="nn-anl-ctl">السنة <select class="nn-hist-year">' + years + '</select></label>' +
        '  <label class="nn-anl-ctl">الفرع <select class="nn-hist-branch"><option value="">الشركة كلها</option></select></label>' +
        '</div>' +
        '<div class="nn-hist-grid"></div>' +
        '<div class="nn-hist-actions" hidden>' +
        '  <label class="nn-anl-ctl nn-hist-notes-l">ملاحظة <input type="text" class="nn-hist-notes" maxlength="400" placeholder="مثال: من النظام السابق - تقرير المبيعات الشهري"></label>' +
        '  <button type="button" class="t-Button t-Button--hot nn-hist-save"><span class="fa fa-save" aria-hidden="true"></span> حفظ</button>' +
        '  <button type="button" class="t-Button nn-hist-clear"><span class="fa fa-eraser" aria-hidden="true"></span> مسح السنة</button>' +
        '  <a class="t-Button nn-hist-cmp" href="#"><span class="fa fa-line-chart" aria-hidden="true"></span> عرض مقارنة السنوات</a>' +
        '</div>' +
        '<details class="nn-hist-import"><summary><span class="fa fa-upload" aria-hidden="true"></span> استيراد من ملف CSV</summary>' +
        '  <p>سطر لكل شهر: <code>رمز المؤشر,الشهر YYYY-MM,القيمة[,رمز الفرع]</code> — مثال: <code>SALES_INVOICED,2024-01,185000</code>. يقبل الفاصل المنقوط، والسطر الأول عنوان اختياري.</p>' +
        '  <div class="nn-hist-imp-row"><input type="file" accept=".csv,.txt,text/csv" class="nn-hist-file" aria-label="ملف CSV">' +
        '  <button type="button" class="t-Button t-Button--small nn-hist-tpl"><span class="fa fa-download" aria-hidden="true"></span> قالب للمؤشر المختار</button></div>' +
        '  <textarea class="nn-hist-csv" rows="6" dir="ltr" placeholder="metric,month,value,branch"></textarea>' +
        '  <button type="button" class="t-Button nn-hist-imp"><span class="fa fa-check" aria-hidden="true"></span> استيراد</button>' +
        '  <div class="nn-hist-imp-res"></div></details>' +
        '<h3 class="nn-rh-h"><span class="fa fa-list-alt" aria-hidden="true"></span> ما أدخل من سنوات سابقة</h3><div class="nn-hist-sum"></div>';
    var $ = function (s) { return root.querySelector(s); };
    var grid = $('.nn-hist-grid');

    function metricDef() {
        var c = $('.nn-hist-metric').value;
        return (state.meta.metrics || []).filter(function (m) { return m.code === c; })[0];
    }
    function renderSummary() {
        var s = state.meta.summary || [];
        $('.nn-hist-sum').innerHTML = s.length ? '<table class="nn-tbl"><thead><tr><th>الموديول</th><th>المؤشر</th><th>السنوات (عدد الأشهر · الإجمالي)</th></tr></thead><tbody>' +
            s.map(function (m) {
                return '<tr><td>' + esc(m.moduleName) + '</td><td>' + esc(m.name) + '</td><td>' + m.years.map(function (y) {
                    return '<button type="button" class="nn-hist-chip" data-m="' + m.metric + '" data-y="' + y.year + '">' + y.year + ' · ' + months(y.months) + ' · ' + fmt(y.total) + '</button>';
                }).join(' ') + '</td></tr>';
            }).join('') + '</tbody></table>' : '<div class="nn-empty">لم تدخل أرقام سنوات سابقة بعد</div>';
    }
    function loadMeta() {
        return call({x01: 'META'}).then(function (m) {
            state.meta = m;
            var sel = $('.nn-hist-metric'), groups = {};
            (m.metrics || []).forEach(function (x) { (groups[x.moduleName] = groups[x.moduleName] || []).push(x); });
            sel.innerHTML = Object.keys(groups).map(function (g) {
                return '<optgroup label="' + esc(g) + '">' + groups[g].map(function (x) { return '<option value="' + x.code + '">' + esc(x.name) + '</option>'; }).join('') + '</optgroup>';
            }).join('');
            var bs = $('.nn-hist-branch');
            (m.branches || []).forEach(function (b) { bs.add(new Option(b.name, b.id)); });
            renderSummary();
            if (sel.value) load();
        }).catch(function (e) { grid.innerHTML = '<div class="nn-anl-err">' + esc(e) + '</div>'; });
    }
    function load() {
        var d = metricDef();
        if (!d) return;
        var bs = $('.nn-hist-branch');
        grid.innerHTML = '<div class="nn-anl-loading">جار التحميل...</div>';
        return call({x01: 'GET', x02: d.code, x03: $('.nn-hist-year').value, x04: bs.disabled ? '' : bs.value}).then(function (h) {
            state.data = h; state.dirty = false;
            bs.disabled = !h.branchApplies;
            if (!h.branchApplies && bs.value) { bs.value = ''; return load(); }
            render();
        }).catch(function (e) { grid.innerHTML = '<div class="nn-anl-err">' + esc(e) + '</div>'; });
    }
    function render() {
        var h = state.data, ro = !h.canEdit;
        grid.innerHTML = '<table class="nn-tbl nn-hist-tbl"><thead><tr><th>الشهر</th><th>المسجل في النظام</th><th>رقم السنة السابقة</th><th>الحالة</th></tr></thead><tbody>' +
            h.months.map(function (m, i) {
                var st = m.future ? '<span class="nn-badge">لم يأت بعد</span>' :
                    m.locked ? '<span class="nn-badge is-warning" title="الشهر فيه حركة فعلية في النظام">فيه بيانات فعلية</span>' :
                    m.value != null ? '<span class="nn-badge is-success">' + (m.source === 'IMPORT' ? 'مستورد' : m.source === 'LEGACY' ? 'ترحيل' : 'مدخل') + '</span>' : '';
                return '<tr><td>' + MONTHS[i] + ' ' + h.year + '</td><td class="nn-num">' + fmt(m.actual) + '</td>' +
                    '<td><input type="text" inputmode="decimal" class="nn-hist-in" data-i="' + i + '" dir="ltr" aria-label="' + MONTHS[i] + '" value="' +
                    (m.value == null ? '' : m.value) + '"' + (m.locked || ro ? ' disabled' : '') + '></td><td>' + st + '</td></tr>';
            }).join('') +
            '<tr class="nn-hist-tot"><td>الإجمالي</td><td class="nn-num">' + fmt(h.months.reduce(function (s, m) { return s + (m.actual || 0); }, 0)) +
            '</td><td class="nn-num nn-hist-total"></td><td></td></tr></tbody></table>' +
            (h.kind === 'BALANCE' ? '<p class="nn-hist-note">هذا مؤشر رصيد: أدخل رصيد نهاية كل شهر.</p>' : '');
        $('.nn-hist-actions').hidden = ro;
        $('.nn-hist-notes').value = (h.months.filter(function (m) { return m.notes; })[0] || {}).notes || '';
        total();
    }
    function values() {
        return Array.prototype.map.call(grid.querySelectorAll('.nn-hist-in'), function (i) { return i.disabled ? null : num(i.value); });
    }
    function total() {
        var t = 0, any = false;
        values().forEach(function (v) { if (v != null && !isNaN(v)) { t += +v; any = true; } });
        var c = grid.querySelector('.nn-hist-total');
        if (c) c.textContent = any ? (state.data.kind === 'BALANCE' ? '—' : fmt(t)) : '';
    }
    function save(clear) {
        var d = metricDef(), v = clear ? values().map(function () { return null; }) : values();
        if (v.some(function (x) { return x != null && isNaN(x); })) { msg('بعض القيم ليست أرقاماً', true); return; }
        var bs = $('.nn-hist-branch');
        call({x01: 'SAVE', x02: d.code, x03: $('.nn-hist-year').value, x04: bs.disabled ? '' : bs.value, x05: JSON.stringify(v), x06: $('.nn-hist-notes').value})
            .then(function (r) { msg(clear ? 'مسحت أرقام السنة' : 'حفظت أرقام ' + months(r.saved)); return Promise.all([load(), call({x01: 'META'}).then(function (m) { state.meta.summary = m.summary; renderSummary(); })]); })
            .catch(function (e) { msg(e, true); });
    }

    grid.addEventListener('input', function (e) { if (e.target.classList.contains('nn-hist-in')) { state.dirty = true; total(); } });
    // لصق عمود من Excel في أي خلية يوزعه على الأشهر التالية
    grid.addEventListener('paste', function (e) {
        var t = e.target;
        if (!t.classList.contains('nn-hist-in')) return;
        var txt = (e.clipboardData || window.clipboardData).getData('text');
        var parts = txt.split(/\r?\n|\t/).filter(function (x) { return x.trim() !== ''; });
        if (parts.length < 2) return;
        e.preventDefault();
        var ins = grid.querySelectorAll('.nn-hist-in'), k = +t.dataset.i;
        parts.forEach(function (p) { while (k < 12 && ins[k].disabled) k++; if (k < 12) { ins[k].value = p.trim(); k++; } });
        state.dirty = true; total();
    });
    root.addEventListener('change', function (e) {
        if (e.target.matches('.nn-hist-metric, .nn-hist-year, .nn-hist-branch')) {
            if (state.dirty && !window.confirm('توجد تعديلات لم تحفظ. المتابعة دون حفظ؟')) return;
            load();
        }
        if (e.target.classList.contains('nn-hist-file') && e.target.files[0]) {
            var r = new FileReader();
            r.onload = function () { $('.nn-hist-csv').value = String(r.result).replace(/^﻿/, ''); };
            r.readAsText(e.target.files[0], 'UTF-8');
        }
    });
    root.addEventListener('click', function (e) {
        var c = e.target.closest('.nn-hist-chip');
        if (c) { $('.nn-hist-metric').value = c.dataset.m; $('.nn-hist-year').value = c.dataset.y; load(); root.scrollIntoView({behavior: 'smooth'}); return; }
        if (e.target.closest('.nn-hist-save')) { save(false); return; }
        if (e.target.closest('.nn-hist-clear')) {
            apex.message.confirm('مسح كل أرقام هذه السنة لهذا المؤشر؟', function (ok) { if (ok) save(true); }); return;
        }
        if (e.target.closest('.nn-hist-cmp')) {
            e.preventDefault();
            try { localStorage.setItem('nnAnlYears', metricDef().code); } catch (x) { /* */ }
            window.location.href = root.dataset.cmpUrl; return;
        }
        if (e.target.closest('.nn-hist-tpl')) {
            var d = metricDef(), yr = $('.nn-hist-year').value, lines = ['metric,month,value'];
            for (var i = 1; i <= 12; i++) lines.push(d.code + ',' + yr + '-' + (i < 10 ? '0' : '') + i + ',');
            $('.nn-hist-csv').value = lines.join('\n'); $('.nn-hist-csv').focus(); return;
        }
        if (e.target.closest('.nn-hist-imp')) {
            var txt = $('.nn-hist-csv').value, res = $('.nn-hist-imp-res');
            if (!txt.trim()) { msg('ألصق أسطر CSV أو اختر ملفاً', true); return; }
            var chunks = []; for (var p = 0; p < txt.length; p += 8000) chunks.push(txt.substr(p, 8000));
            res.innerHTML = '<div class="nn-anl-loading">جار الاستيراد...</div>';
            call({x01: 'IMPORT', f01: chunks}).then(function (r) {
                res.innerHTML = '<p><b>حفظت أرقام ' + months(r.saved) + '</b>' + (r.errorCount ? ' · ' + r.errorCount + ' سطر به خطأ' : '') + '</p>' +
                    (r.errors.length ? '<table class="nn-tbl"><thead><tr><th>السطر</th><th>الخطأ</th></tr></thead><tbody>' +
                        r.errors.map(function (x) { return '<tr><td>' + x.line + '</td><td>' + esc(x.msg) + '</td></tr>'; }).join('') + '</tbody></table>' : '');
                return Promise.all([load(), call({x01: 'META'}).then(function (m) { state.meta.summary = m.summary; renderSummary(); })]);
            }).catch(function (x) { res.innerHTML = '<div class="nn-anl-err">' + esc(x) + '</div>'; });
        }
    });
    window.addEventListener('beforeunload', function (e) { if (state.dirty) { e.preventDefault(); e.returnValue = ''; } });
    loadMeta();
})();
