/* NOONA PLUS | anl.js - شاشة التحليلات والتنبؤ لكل موديول واللوحة الموحدة
 * البيانات من NOONA_ANL_PKG عبر عملية AJAX «ANL» في الصفحة:
 *   x01=VIEW  x02=الموديولات (FIN,SAL...) x03=الفرع            ← مؤشرات الشهر الحالي + سلسلة 12 شهراً مصغرة
 *   x01=CHART x02=المؤشر x03=الفرع x04=الفترة (MONTH/WEEK/DAY) x05=أشهر التنبؤ ← السلسلة والتنبؤ بنطاق الثقة
 *   x01=ANOM                                                    ← القيم غير المعتادة في آخر شهر مكتمل (اللوحة الموحدة)
 * الأرقام كلها تحسب داخل القاعدة بصلاحيات المستخدم وشركته وفرعه؛ الرسوم SVG بلا مكتبات خارجية.
 */
(function () {
    'use strict';
    var root = document.getElementById('nnAnl');
    if (!root) return;
    var MODULES = root.dataset.modules || '';
    var UNIFIED = root.dataset.unified === 'Y';
    var MONTHS = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    // اتجاه الأفضل: UP ارتفاعه جيد، DOWN انخفاضه جيد، غير ذلك محايد (لون النص العادي)
    var GOOD = {REVENUE: 'UP', NET_PROFIT: 'UP', CASH_BALANCE: 'UP', SALES_INVOICED: 'UP', POS_SALES: 'UP', POS_TICKETS: 'UP',
        PRODUCTION_QTY: 'UP', PRODUCTION_ORDERS: 'UP', HIS_VISITS: 'UP', HIS_REVENUE: 'UP', AUT_JOBS: 'UP', AUT_REVENUE: 'UP',
        HOTEL_CHECKINS: 'UP', RE_SALES: 'UP', RST_SALES: 'UP', EXPENSES: 'DOWN', AP_BALANCE: 'DOWN'};
    var state = {branch: '', metric: null, grain: 'MONTH', periods: 3, table: false, view: null, chart: null};
    var nf0 = new Intl.NumberFormat('ar-u-nu-latn', {maximumFractionDigits: 0});
    var nf2 = new Intl.NumberFormat('ar-u-nu-latn', {maximumFractionDigits: 2});
    var nfc = new Intl.NumberFormat('ar-u-nu-latn', {notation: 'compact', maximumFractionDigits: 1});

    function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c]; }); }
    function fmt(v, unit) {
        if (v == null || isNaN(v)) return '—';
        return (unit === 'AMOUNT' && Math.abs(v) < 1000 ? nf2 : nf0).format(v);
    }
    function plabel(p, grain, short) {
        if (!p || p.charAt(0) === '+') return p || '';
        var y = p.substr(0, 4), m = +p.substr(5, 2);
        if (grain === 'MONTH') return short ? MONTHS[m - 1].substr(0, 3) + ' ' + y.substr(2) : MONTHS[m - 1] + ' ' + y;
        return +p.substr(8, 2) + ' ' + MONTHS[m - 1].substr(0, 3);
    }
    function call(x) {
        return new Promise(function (ok, bad) {
            apex.server.process('ANL', x, {dataType: 'text'}).done(function (t) {
                var d; try { d = JSON.parse(t); } catch (e) { bad('تعذر قراءة البيانات'); return; }
                if (d && d.ok === false) bad(d.msg || 'تعذر جلب البيانات'); else ok(d);
            }).fail(function () { bad('تعذر الاتصال بالخادم'); });
        });
    }
    function err(host, msg) { host.innerHTML = '<div class="nn-anl-err"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span> ' + esc(msg) + '</div>'; }

    // ------------------------------------------------------------------ الهيكل
    root.innerHTML =
        '<div class="nn-anl-bar">' +
        '  <div class="nn-anl-title"><span class="fa fa-line-chart" aria-hidden="true"></span> ' + (UNIFIED ? 'لوحة الأداء الموحدة' : 'التحليلات والتنبؤ') +
        '    <span class="nn-anl-sub"></span></div>' +
        '  <label class="nn-anl-ctl">الفرع <select class="nn-anl-branch"><option value="">كل الفروع</option></select></label>' +
        '  <button type="button" class="t-Button t-Button--small nn-anl-refresh" title="تحديث"><span class="fa fa-refresh" aria-hidden="true"></span> تحديث</button>' +
        '</div>' +
        (UNIFIED ? '<div class="nn-anl-anom"></div>' : '') +
        '<div class="nn-anl-mods"><div class="nn-anl-loading">جار حساب المؤشرات...</div></div>' +
        '<div class="nn-anl-chart-card" hidden>' +
        '  <div class="nn-anl-chart-head"><div><div class="nn-anl-chart-title"></div><div class="nn-anl-chart-note"></div></div>' +
        '    <div class="nn-anl-seg" role="group" aria-label="الفترة">' +
        '      <button type="button" data-g="MONTH" aria-pressed="true">شهري</button><button type="button" data-g="WEEK" aria-pressed="false">أسبوعي</button>' +
        '      <button type="button" data-g="DAY" aria-pressed="false">يومي</button></div>' +
        '    <label class="nn-anl-ctl nn-anl-h">التنبؤ <select class="nn-anl-periods"><option value="3">3 أشهر</option><option value="6">6 أشهر</option><option value="12">12 شهراً</option></select></label>' +
        '    <button type="button" class="t-Button t-Button--small nn-anl-tbl" aria-pressed="false"><span class="fa fa-table" aria-hidden="true"></span> جدول</button>' +
        '  </div>' +
        '  <div class="nn-anl-plot"></div><div class="nn-anl-legend"></div><div class="nn-anl-table" hidden></div>' +
        '</div>';
    var $ = function (s) { return root.querySelector(s); };
    var card = $('.nn-anl-chart-card'), plot = $('.nn-anl-plot'), tbl = $('.nn-anl-table');
    // اللوحة الموحدة طويلة: الرسم أعلاها تحت التنبيهات فيبقى قريباً من المؤشر المختار
    if (UNIFIED) root.insertBefore(card, $('.nn-anl-mods'));

    // ------------------------------------------------------------------ المؤشرات
    function spark(vals) {
        var w = 120, h = 34, n = vals.length;
        if (n < 2) return '';
        var mn = Math.min.apply(null, vals), mx = Math.max.apply(null, vals), r = (mx - mn) || 1;
        var pts = vals.map(function (v, i) { return [(i / (n - 1)) * (w - 4) + 2, h - 3 - ((v - mn) / r) * (h - 6)]; });
        var d = pts.map(function (p, i) { return (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1); }).join(' ');
        var last = pts[n - 1];
        return '<svg class="nn-anl-spark" viewBox="0 0 ' + w + ' ' + h + '" width="' + w + '" height="' + h + '" aria-hidden="true" dir="ltr">' +
            '<path d="' + d + '"/><circle cx="' + last[0].toFixed(1) + '" cy="' + last[1].toFixed(1) + '" r="2.5"/></svg>';
    }
    function change(k) {
        if (k.changePct == null) return '<span class="nn-anl-chg">لا توجد فترة سابقة للمقارنة</span>';
        var up = k.changePct > 0, flat = k.changePct === 0, g = GOOD[k.metric];
        var tone = flat || !g ? '' : ((up && g === 'UP') || (!up && g === 'DOWN') ? ' is-good' : ' is-bad');
        return '<span class="nn-anl-chg' + tone + '"><span class="fa ' + (flat ? 'fa-minus' : up ? 'fa-arrow-up' : 'fa-arrow-down') + '" aria-hidden="true"></span> ' +
            (up ? '+' : '') + nf2.format(k.changePct) + '% عن الفترة المماثلة السابقة</span>';
    }
    function tile(k) {
        return '<button type="button" class="nn-anl-kpi" data-m="' + k.metric + '" aria-pressed="' + (state.metric === k.metric) + '">' +
            '<span class="nn-anl-kpi-name">' + esc(k.name) + (k.kind === 'BALANCE' ? ' <small>(الرصيد)</small>' : '') + '</span>' +
            '<span class="nn-anl-kpi-val">' + fmt(k.value, k.unit) + '</span>' + change(k) +
            '<span class="nn-anl-kpi-foot"><span>السابقة: ' + fmt(k.previous, k.unit) + '</span>' + spark(k.spark || []) + '</span></button>';
    }
    function loadView() {
        var mods = $('.nn-anl-mods');
        mods.innerHTML = '<div class="nn-anl-loading">جار حساب المؤشرات...</div>';
        return call({x01: 'VIEW', x02: MODULES, x03: state.branch}).then(function (v) {
            state.view = v;
            var sel = $('.nn-anl-branch');
            if (sel.options.length === 1) (v.branches || []).forEach(function (b) { sel.add(new Option(b.name, b.id)); });
            sel.closest('label').hidden = (v.branches || []).length < 2;
            $('.nn-anl-sub').textContent = 'من ' + v.from + ' إلى ' + v.asOf + ' مقارنة بالفترة المماثلة السابقة';
            if (!v.modules.length) {
                mods.innerHTML = '<div class="nn-launch-empty"><span class="fa fa-lock" aria-hidden="true"></span><b>لا توجد مؤشرات متاحة لك</b>' +
                    '<span>المؤشرات تظهر حسب صلاحيات العرض في كل موديول واشتراك المؤسسة</span></div>';
                card.hidden = true; return;
            }
            mods.innerHTML = v.modules.map(function (m) {
                return '<section class="nn-anl-mod" aria-label="' + esc(m.name) + '">' + (v.modules.length > 1 || UNIFIED ? '<h3 class="nn-rh-h">' + esc(m.name) + '</h3>' : '') +
                    '<div class="nn-anl-kpis">' + m.kpis.map(tile).join('') + '</div></section>';
            }).join('');
            var all = [].concat.apply([], v.modules.map(function (m) { return m.kpis; }));
            if (!state.metric || !all.some(function (k) { return k.metric === state.metric; })) state.metric = all[0].metric;
            mark(); return loadChart();
        }).catch(function (m) { err(mods, m); });
    }
    function mark() {
        root.querySelectorAll('.nn-anl-kpi').forEach(function (b) { b.setAttribute('aria-pressed', b.dataset.m === state.metric); });
    }

    // ------------------------------------------------------------------ الرسم الكبير
    function loadChart() {
        card.hidden = false;
        plot.innerHTML = '<div class="nn-anl-loading">جار الرسم...</div>';
        $('.nn-anl-h').hidden = state.grain !== 'MONTH';
        return call({x01: 'CHART', x02: state.metric, x03: state.branch, x04: state.grain, x05: state.periods}).then(function (c) {
            state.chart = c; draw(); table();
        }).catch(function (m) { err(plot, m); });
    }
    function nice(mn, mx) {
        if (mn === mx) { mx = mn + 1; }
        var span = mx - mn, step = Math.pow(10, Math.floor(Math.log10(span / 4))), f = span / 4 / step;
        step *= f > 5 ? 10 : f > 2 ? 5 : f > 1 ? 2 : 1;
        var a = Math.floor(mn / step) * step, b = Math.ceil(mx / step) * step, t = [];
        for (var x = a; x <= b + step / 2; x += step) t.push(+x.toFixed(10));
        return t;
    }
    function draw() {
        var c = state.chart, h = c.history || [], f = c.forecast || [], all = h.concat(f);
        $('.nn-anl-chart-title').textContent = c.name + (state.grain === 'MONTH' ? ' شهرياً' : state.grain === 'WEEK' ? ' أسبوعياً' : ' يومياً');
        var note = '';
        if (f.length) {
            var tot = f.reduce(function (s, x) { return s + x.v; }, 0);
            note = 'التنبؤ للـ' + f.length + ' ' + (f.length > 10 ? 'شهراً' : 'أشهر') + ' القادمة: ' + fmt(c.kind === 'BALANCE' ? f[f.length - 1].v : tot, c.unit) +
                (c.trendPct != null ? ' (' + (c.trendPct > 0 ? '+' : '') + nf2.format(c.trendPct) + '% عن الفترة المماثلة الأخيرة)' : '') +
                ' · الطريقة: ' + ({HOLT_WINTERS: 'Holt-Winters موسمي', HOLT: 'Holt خطي', AVERAGE: 'المتوسط (بيانات قليلة)'}[c.method] || c.method) +
                ' · نطاق ثقة 95%';
        } else if (state.grain !== 'MONTH') note = 'التنبؤ متاح في العرض الشهري';
        $('.nn-anl-chart-note').textContent = note;
        if (!all.length) { plot.innerHTML = '<div class="nn-empty">لا توجد بيانات</div>'; return; }
        var W = Math.max(plot.clientWidth, 320), H = 300, m = {t: 16, r: 16, b: 34, l: 64};
        var iw = W - m.l - m.r, ih = H - m.t - m.b, n = all.length;
        var lo = Math.min(0, Math.min.apply(null, all.map(function (x) { return x.lo != null ? Math.min(x.lo, x.v) : x.v; })));
        var hi = Math.max.apply(null, all.map(function (x) { return x.hi != null ? Math.max(x.hi, x.v) : x.v; }));
        var ticks = nice(lo, hi), y0 = ticks[0], y1 = ticks[ticks.length - 1];
        var X = function (i) { return m.l + (n === 1 ? iw / 2 : (i / (n - 1)) * iw); };
        var Y = function (v) { return m.t + ih - ((v - y0) / (y1 - y0 || 1)) * ih; };
        var s = '<svg class="nn-anl-svg" viewBox="0 0 ' + W + ' ' + H + '" width="100%" height="' + H + '" dir="ltr" role="img" aria-label="' + esc(c.name) + '">';
        ticks.forEach(function (t) {
            s += '<line class="nn-anl-grid' + (t === 0 ? ' is-zero' : '') + '" x1="' + m.l + '" x2="' + (W - m.r) + '" y1="' + Y(t) + '" y2="' + Y(t) + '"/>' +
                '<text class="nn-anl-axis" x="' + (m.l - 8) + '" y="' + (Y(t) + 4) + '" text-anchor="end">' + nfc.format(t) + '</text>';
        });
        var every = Math.ceil(n / Math.max(2, Math.floor(iw / 70)));
        all.forEach(function (p, i) {
            if (i % every === 0 || i === n - 1) s += '<text class="nn-anl-axis" x="' + X(i) + '" y="' + (H - 10) + '" text-anchor="middle">' + esc(plabel(p.p, state.grain, true)) + '</text>';
        });
        if (f.length) {
            var k0 = h.length - 1, band = 'M' + X(k0) + ' ' + Y(h[k0].v);
            f.forEach(function (p, i) { band += ' L' + X(k0 + 1 + i) + ' ' + Y(p.hi); });
            for (var i = f.length - 1; i >= 0; i--) band += ' L' + X(k0 + 1 + i) + ' ' + Y(f[i].lo);
            s += '<path class="nn-anl-band" d="' + band + ' Z"/>';
            s += '<line class="nn-anl-now" x1="' + X(k0) + '" x2="' + X(k0) + '" y1="' + m.t + '" y2="' + (m.t + ih) + '"/>' +
                '<text class="nn-anl-axis" x="' + (X(k0) + 6) + '" y="' + (m.t + 10) + '">تنبؤ ←</text>';
            s += '<path class="nn-anl-fc" d="M' + X(k0) + ' ' + Y(h[k0].v) + f.map(function (p, i) { return ' L' + X(k0 + 1 + i) + ' ' + Y(p.v); }).join('') + '"/>';
        }
        s += '<path class="nn-anl-line" d="' + h.map(function (p, i) { return (i ? 'L' : 'M') + X(i) + ' ' + Y(p.v); }).join(' ') + '"/>';
        if (h.length) s += '<circle class="nn-anl-last" cx="' + X(h.length - 1) + '" cy="' + Y(h[h.length - 1].v) + '" r="4"/>';
        s += '<line class="nn-anl-cross" y1="' + m.t + '" y2="' + (m.t + ih) + '" hidden/><circle class="nn-anl-dot" r="5" hidden/>' +
            '<rect class="nn-anl-hit" x="' + m.l + '" y="' + m.t + '" width="' + iw + '" height="' + ih + '"/></svg><div class="nn-anl-tip" hidden></div>';
        plot.innerHTML = s;
        $('.nn-anl-legend').innerHTML = '<span class="nn-anl-key"><i class="is-line"></i> الفعلي</span>' +
            (f.length ? '<span class="nn-anl-key"><i class="is-fc"></i> التنبؤ</span><span class="nn-anl-key"><i class="is-band"></i> نطاق الثقة</span>' : '');
        var svg = plot.querySelector('svg'), cross = svg.querySelector('.nn-anl-cross'), dot = svg.querySelector('.nn-anl-dot'), tip = plot.querySelector('.nn-anl-tip');
        function show(i) {
            var p = all[i], isF = i >= h.length;
            cross.setAttribute('x1', X(i)); cross.setAttribute('x2', X(i)); cross.hidden = false;
            dot.setAttribute('cx', X(i)); dot.setAttribute('cy', Y(p.v)); dot.hidden = false;
            tip.innerHTML = '<b>' + esc(plabel(p.p, state.grain)) + '</b>' + (isF ? ' <span class="nn-badge is-info">تنبؤ</span>' : '') +
                '<div>' + fmt(p.v, c.unit) + '</div>' + (isF ? '<small>المدى المتوقع: ' + fmt(p.lo, c.unit) + ' – ' + fmt(p.hi, c.unit) + '</small>' : '');
            tip.hidden = false;
            var r = svg.getBoundingClientRect(), px = X(i) / W * r.width;
            tip.style.left = Math.min(Math.max(px - tip.offsetWidth / 2, 0), r.width - tip.offsetWidth) + 'px';
            tip.style.top = (Y(p.v) / H * r.height - tip.offsetHeight - 12 < 0 ? Y(p.v) / H * r.height + 14 : Y(p.v) / H * r.height - tip.offsetHeight - 12) + 'px';
        }
        svg.querySelector('.nn-anl-hit').addEventListener('mousemove', function (e) {
            var r = svg.getBoundingClientRect(), x = (e.clientX - r.left) / r.width * W;
            show(Math.max(0, Math.min(n - 1, Math.round((x - m.l) / (iw || 1) * (n - 1)))));
        });
        svg.querySelector('.nn-anl-hit').addEventListener('mouseleave', function () { cross.hidden = true; dot.hidden = true; tip.hidden = true; });
    }
    function table() {
        var c = state.chart, rows = (c.history || []).map(function (p) { return [p, false]; }).concat((c.forecast || []).map(function (p) { return [p, true]; }));
        tbl.innerHTML = '<table class="nn-tbl"><thead><tr><th>الفترة</th><th>القيمة</th><th>الحد الأدنى المتوقع</th><th>الحد الأعلى المتوقع</th></tr></thead><tbody>' +
            rows.map(function (r) {
                var p = r[0];
                return '<tr' + (r[1] ? ' class="is-fc"' : '') + '><td>' + esc(plabel(p.p, state.grain)) + (r[1] ? ' (تنبؤ)' : '') + '</td><td>' + fmt(p.v, c.unit) +
                    '</td><td>' + (r[1] ? fmt(p.lo, c.unit) : '') + '</td><td>' + (r[1] ? fmt(p.hi, c.unit) : '') + '</td></tr>';
            }).join('') + '</tbody></table>';
        tbl.hidden = !state.table;
    }

    // ------------------------------------------------------------------ القيم غير المعتادة (اللوحة الموحدة)
    function loadAnom() {
        var host = $('.nn-anl-anom');
        if (!host) return;
        call({x01: 'ANOM'}).then(function (a) {
            if (!a.length) { host.innerHTML = ''; return; }
            host.innerHTML = '<h3 class="nn-rh-h"><span class="fa fa-bell-o" aria-hidden="true"></span> قيم غير معتادة في آخر شهر مكتمل</h3><div class="nn-anl-anoms">' +
                a.map(function (x) {
                    return '<button type="button" class="nn-anl-an" data-m="' + x.metric + '"><span class="fa ' + (x.direction === 'UP' ? 'fa-arrow-up' : 'fa-arrow-down') + '" aria-hidden="true"></span>' +
                        '<span><b>' + esc(x.name) + '</b> ' + (x.direction === 'UP' ? 'أعلى' : 'أقل') + ' من المعتاد في ' + esc(plabel(x.month, 'MONTH')) +
                        ': ' + fmt(x.value) + ' مقابل متوسط ' + fmt(x.mean) + '</span></button>';
                }).join('') + '</div>';
        }).catch(function () { host.innerHTML = ''; });
    }

    // ------------------------------------------------------------------ الأحداث
    root.addEventListener('click', function (e) {
        var k = e.target.closest('.nn-anl-kpi, .nn-anl-an');
        if (k) { state.metric = k.dataset.m; mark(); loadChart(); if (UNIFIED || k.classList.contains('nn-anl-an')) card.scrollIntoView({behavior: 'smooth', block: 'nearest'}); return; }
        var g = e.target.closest('.nn-anl-seg button');
        if (g) {
            state.grain = g.dataset.g;
            root.querySelectorAll('.nn-anl-seg button').forEach(function (b) { b.setAttribute('aria-pressed', b === g); });
            loadChart(); return;
        }
        if (e.target.closest('.nn-anl-tbl')) {
            state.table = !state.table; e.target.closest('.nn-anl-tbl').setAttribute('aria-pressed', state.table); tbl.hidden = !state.table; return;
        }
        if (e.target.closest('.nn-anl-refresh')) { loadView(); loadAnom(); }
    });
    $('.nn-anl-branch').addEventListener('change', function (e) { state.branch = e.target.value; loadView(); });
    $('.nn-anl-periods').addEventListener('change', function (e) { state.periods = +e.target.value; loadChart(); });
    var rt; window.addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(function () { if (state.chart) draw(); }, 150); });
    loadView(); loadAnom();
})();
