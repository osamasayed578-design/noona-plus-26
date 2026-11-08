/* NOONA PLUS | تحسينات وصول عامة لكل التطبيقات (تعمل عند التحميل وبعد تحديث أي منطقة):
   - حقل التاريخ في APEX: ربطه بتسميته وخاصية aria-expanded المطلوبة لدور combobox
   - حقول وقوائم بلا تسمية داخل الجداول والمحررات: تسمية من رأس العمود أو النص النائب
   - مناطق التمرير: تصلها لوحة المفاتيح (tabindex) باسم المنطقة */
(function () {
    'use strict';
    function colHeader(el) {
        var td = el.closest('td'); if (!td) return '';
        var tbl = td.closest('table'); if (!tbl) return '';
        var th = tbl.querySelectorAll('thead th')[td.cellIndex];
        return th ? th.textContent.trim() : '';
    }
    function hasName(el) {
        if (el.getAttribute('aria-label') || el.getAttribute('aria-labelledby') || el.title) return true;
        if (el.id && document.querySelector('label[for="' + el.id + '"]')) return true;
        return !!el.closest('label');
    }
    function fix(root) {
        root = root || document;
        // حقول التاريخ: التسمية مرتبطة بعنصر a-date-picker لا بحقل الإدخال
        root.querySelectorAll('input.apex-item-datepicker[id$="_input"], a-date-picker input[id$="_input"]').forEach(function (i) {
            var base = i.id.replace(/_input$/, '');
            var lab = document.getElementById(base + '_LABEL');
            if (lab && !i.getAttribute('aria-labelledby')) i.setAttribute('aria-labelledby', lab.id);
            if (i.getAttribute('role') === 'combobox' && !i.hasAttribute('aria-expanded')) i.setAttribute('aria-expanded', 'false');
        });
        // حقول وقوائم بلا تسمية (سطور المستندات والمحررات)
        root.querySelectorAll('input:not([type=hidden]):not([type=button]):not([type=submit]), select, textarea').forEach(function (el) {
            if (hasName(el)) return;
            var t = colHeader(el) || el.placeholder || (el.dataset && (el.dataset.c || el.dataset.f || el.dataset.k)) || '';
            if (t) el.setAttribute('aria-label', t);
        });
        // مناطق التمرير الأفقي أو الرأسي
        root.querySelectorAll('.t-Region-body, .nn-print-area, pre').forEach(function (r) {
            if (r.hasAttribute('tabindex')) return;
            var s = getComputedStyle(r);
            // منطقة مصممة للتمرير (t-Region--scrollBody) تأخذ التركيز دائماً؛ غيرها حين يفيض محتواها فعلاً
            var designed = !!r.closest('.t-Region--scrollBody') && r.classList.contains('t-Region-body');
            if (designed || ((/(auto|scroll)/.test(s.overflowX + s.overflowY)) && (r.scrollWidth > r.clientWidth + 2 || r.scrollHeight > r.clientHeight + 2))) {
                r.setAttribute('tabindex', '0');
                if (!r.getAttribute('aria-label')) {
                    var reg = r.closest('.t-Region'), h = reg && reg.querySelector('.t-Region-title');
                    r.setAttribute('role', 'region');
                    r.setAttribute('aria-label', h ? h.textContent.trim() : 'محتوى قابل للتمرير');
                }
            }
        });
    }
    var timer;
    function later() { clearTimeout(timer); timer = setTimeout(function () { fix(document); }, 120); }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', later); else later();
    window.addEventListener('load', later);
    window.addEventListener('resize', later);
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(later);
    document.addEventListener('apexafterrefresh', later);
    if (window.MutationObserver) new MutationObserver(later).observe(document.documentElement, { childList: true, subtree: true });
    window.noonaA11y = fix;
})();

/* NOONA PLUS | المظهر: قياسي (فاتح) أو داكن أو تلقائي يتبع إعداد الجهاز؛ قائمة في الترويسة تحفظ الاختيار على هذا الجهاز */
(function () {
    'use strict';
    var KEY = 'nnTheme', root = document.documentElement;
    var MODES = [['light', 'قياسي (فاتح)', 'is-light'], ['dark', 'داكن', 'is-dark'], ['auto', 'تلقائي حسب الجهاز', 'is-auto']];
    function saved() { try { return localStorage.getItem(KEY); } catch (e) { return null; } }
    function mode() { var m = saved(); return m === 'light' || m === 'dark' ? m : 'auto'; }
    function system() { return window.matchMedia && matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'; }
    function apply() {
        var m = mode(), t = m === 'auto' ? system() : m;
        root.setAttribute('data-theme', t);
        var b = document.querySelector('.nn-theme-toggle');
        if (b) {
            b.title = 'المظهر: ' + MODES.filter(function (x) { return x[0] === m; })[0][1];
            b.setAttribute('aria-label', b.title);
            b.firstElementChild.className = 'fa ' + (m === 'auto' ? 'fa-adjust' : t === 'dark' ? 'fa-moon-o' : 'fa-sun-o');
        }
        document.querySelectorAll('.nn-theme-menu button[data-m]').forEach(function (x) { x.setAttribute('aria-checked', x.dataset.m === m); });
    }
    function set(m) {
        try { if (m === 'auto') localStorage.removeItem(KEY); else localStorage.setItem(KEY, m); } catch (e) { /* التخزين غير متاح */ }
        apply();
    }
    apply();
    if (window.matchMedia) matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function () { if (mode() === 'auto') apply(); });
    window.addEventListener('storage', function (e) { if (e.key === KEY) apply(); });
    function addButton() {
        if (document.querySelector('.nn-theme-toggle')) return;
        var bar = document.querySelector('.t-NavigationBar, .t-Header-navBar');
        if (!bar) return;
        var b = document.createElement('button');
        b.type = 'button'; b.className = 'nn-theme-toggle'; b.setAttribute('aria-haspopup', 'menu'); b.setAttribute('aria-expanded', 'false');
        b.innerHTML = '<span class="fa fa-adjust" aria-hidden="true"></span>';
        var menu = document.createElement('div');
        menu.className = 'nn-theme-menu'; menu.setAttribute('role', 'menu'); menu.hidden = true;
        menu.innerHTML = '<div class="nn-tm-h">المظهر</div>' + MODES.map(function (x) {
            return '<button type="button" role="menuitemradio" data-m="' + x[0] + '"><span class="nn-tm-sw ' + x[2] + '" aria-hidden="true"></span>' + x[1] + '</button>';
        }).join('');
        document.body.appendChild(menu);
        function close() { menu.hidden = true; b.setAttribute('aria-expanded', 'false'); }
        b.addEventListener('click', function (e) {
            e.stopPropagation();
            if (!menu.hidden) { close(); return; }
            var r = b.getBoundingClientRect();
            menu.hidden = false;
            menu.style.top = (r.bottom + window.scrollY + 6) + 'px';
            menu.style.left = Math.max(8, Math.min(r.left + window.scrollX, window.innerWidth - menu.offsetWidth - 8)) + 'px';
            b.setAttribute('aria-expanded', 'true');
            var cur = menu.querySelector('[aria-checked="true"]') || menu.querySelector('button'); cur.focus();
        });
        menu.addEventListener('click', function (e) { var x = e.target.closest('button[data-m]'); if (x) { set(x.dataset.m); close(); b.focus(); } });
        menu.addEventListener('keydown', function (e) {
            var items = [].slice.call(menu.querySelectorAll('button')), i = items.indexOf(document.activeElement);
            if (e.key === 'Escape') { close(); b.focus(); }
            else if (e.key === 'ArrowDown') { e.preventDefault(); items[(i + 1) % items.length].focus(); }
            else if (e.key === 'ArrowUp') { e.preventDefault(); items[(i - 1 + items.length) % items.length].focus(); }
        });
        document.addEventListener('click', function (e) { if (!menu.hidden && !menu.contains(e.target)) close(); });
        bar.insertBefore(b, bar.firstChild);
        apply();
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', addButton); else addButton();
})();

/* NOONA PLUS | أرقام المؤشرات الرقمية: عداد متحرك عند ظهور المؤشر، ومن القيمة السابقة إلى الجديدة عند تغيرها
   (تغيير الفرع أو الفترة أو التقرير أو تحديث المنطقة) مع تمييز البطاقة بالأخضر أو الأحمر حسب الاتجاه */
(function () {
    'use strict';
    var SEL = '.nn-kpi-value, .nn-anl-kpi-val, .nn-trn-kpi b, .nn-rst-kpi b, .nn-hist-total';
    var CARD = '.nn-kpi, .nn-anl-kpi, .nn-trn-kpi, .nn-rst-kpi';
    var still = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
    var last = {};
    var NUM = /[-−]?\d[\d,٬]*(?:[.٫]\d+)?/;
    function textNode(el) {
        var w = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null), n;
        while ((n = w.nextNode())) if (NUM.test(n.nodeValue)) return n;
        return null;
    }
    function parse(t) {
        var m = t.match(NUM); if (!m) return null;
        var raw = m[0], dec = raw.match(/[.٫](\d+)$/);
        var v = parseFloat(raw.replace(/[,٬]/g, '').replace('٫', '.').replace('−', '-'));
        return isNaN(v) ? null : { v: v, pre: t.slice(0, m.index), post: t.slice(m.index + raw.length), d: dec ? dec[1].length : 0,
            g: /[,٬]/.test(raw) || Math.abs(v) >= 10000, minus: raw.charAt(0) === '−' };
    }
    function fmt(p, v) {
        var s = Math.abs(v).toLocaleString('en-US', { minimumFractionDigits: p.d, maximumFractionDigits: p.d, useGrouping: p.g });
        return (v < 0 ? (p.minus ? '−' : '-') : '') + s;
    }
    function keyOf(el) {
        var c = el.closest('[data-m]'); if (c) return 'm:' + c.dataset.m;
        var card = el.closest(CARD), lab = card && card.querySelector('.nn-kpi-label, .nn-anl-kpi-name, span:not(.fa)');
        return 'l:' + location.pathname + ':' + (lab ? lab.textContent.trim() : el.textContent.trim().slice(0, 20));
    }
    function run(el) {
        var n = textNode(el); if (!n) return;
        var p = parse(n.nodeValue); if (!p) return;
        var sig = n.nodeValue;
        if (el.dataset.nnNum === sig) return;                       // عرضه العداد مسبقاً
        var k = keyOf(el), had = k in last, from = had ? last[k] : 0, to = p.v;
        last[k] = to; el.dataset.nnNum = sig;
        var card = el.closest(CARD);
        if (card && had && from !== to) {
            card.classList.remove('nn-num-up', 'nn-num-down'); void card.offsetWidth;
            card.classList.add(to > from ? 'nn-num-up' : 'nn-num-down');
        }
        if (still || from === to) return;
        var t0 = null, dur = Math.min(1400, 650 + Math.log10(Math.abs(to - from) + 1) * 90);
        function step(ts) {
            if (t0 === null) t0 = ts;
            var x = Math.min(1, (ts - t0) / dur), e = 1 - Math.pow(1 - x, 3);
            n.nodeValue = p.pre + fmt(p, from + (to - from) * e) + p.post;
            if (x < 1) requestAnimationFrame(step); else { n.nodeValue = sig; el.dataset.nnNum = sig; }
        }
        requestAnimationFrame(step);
    }
    var timer;
    function scan() { clearTimeout(timer); timer = setTimeout(function () { document.querySelectorAll(SEL).forEach(run); }, 60); }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', scan); else scan();
    document.addEventListener('apexafterrefresh', scan);
    if (window.MutationObserver) new MutationObserver(function (ms) {
        for (var i = 0; i < ms.length; i++) if (ms[i].type === 'childList' && ms[i].addedNodes.length) { scan(); return; }
    }).observe(document.documentElement, { childList: true, subtree: true });
})();
