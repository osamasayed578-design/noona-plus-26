// عارض المستندات: بطاقات .nn-dv-card (data-kind pdf|img|office|paper) تعرض في إطار المعاينة داخل الصفحة
(function () {
    var esc = function (s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c]; }); };
    document.querySelectorAll('.nn-dv').forEach(function (dv) {
        var view = dv.querySelector('.nn-dv-view');
        function show(card) {
            dv.querySelectorAll('.nn-dv-card').forEach(function (c) { c.classList.toggle('is-active', c === card); });
            var k = card.dataset.kind, u = card.dataset.view, t = card.dataset.title;
            var h = '<div class="nn-dv-bar"><b>' + esc(t) + '</b>' + (u ? '<span><a href="' + esc(u) + '" target="_blank" rel="noopener">'
                  + '<span class="fa fa-external-link" aria-hidden="true"></span> فتح في نافذة</a><a href="' + esc(card.dataset.dl) + '">'
                  + '<span class="fa fa-download" aria-hidden="true"></span> تنزيل</a></span>' : '') + '</div>';
            if (k === 'pdf') h += '<iframe class="nn-dv-frame" src="' + esc(u) + '" title="' + esc(t) + '"></iframe>';
            else if (k === 'img') h += '<div class="nn-dv-img"><img src="' + esc(u) + '" alt="' + esc(t) + '"></div>';
            else if (k === 'office') h += '<div class="nn-dv-msg"><span class="fa fa-file-text-o" aria-hidden="true"></span>لا تتوفر معاينة لمستندات Word/Excel داخل الصفحة؛ '
                                        + '<a href="' + esc(card.dataset.dl) + '">نزّل الملف</a></div>';
            else h += '<div class="nn-dv-msg"><span class="fa fa-archive" aria-hidden="true"></span><b>أصل ورقي فقط (لا توجد صورة)</b>' + esc(card.dataset.paper) + '</div>';
            view.innerHTML = h;
        }
        dv.addEventListener('click', function (e) {
            if (e.target.closest('a')) return;
            var img = e.target.closest('.nn-dv-img'); if (img) { img.classList.toggle('is-zoom'); return; }
            var c = e.target.closest('.nn-dv-card'); if (c) show(c);
        });
        dv.addEventListener('keydown', function (e) { if (e.key === 'Enter') { var c = e.target.closest('.nn-dv-card'); if (c) show(c); } });
        if (dv.dataset.auto === 'Y') {
            var first = dv.querySelector('.nn-dv-card[data-kind="pdf"], .nn-dv-card[data-kind="img"]') || dv.querySelector('.nn-dv-card');
            if (first) show(first);
        }
    });
})();
