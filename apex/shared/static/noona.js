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
