/* NOONA PLUS 26 | ai.js - «مساعد نونا» في كل صفحة من كل الأنظمة (APEX 26.2 + NOONA_AI_PKG)
 * زر عائم يفتح لوحة محادثة؛ يرسل سؤال المستخدم مع سياق الصفحة (التطبيق، الصفحة، العنوان، نص مختصر مما يراه) إلى
 * عملية التطبيق NOONA_AI؛ الإجابات بأرقام من أدوات قاعدة البيانات بصلاحيات المستخدم وشركته. محادثات لكل مستخدم.
 * في اللوحة الموحدة يضيف «الملخص التنفيذي بالذكاء الاصطناعي».
 */
(function () {
    'use strict';
    if (window.nnAi || !window.apex || !apex.server) return;
    var MOD = {NOONA_FIN: 'FIN', NOONA_POS: 'SAL', NOONA_SCM: 'SCM', NOONA_HR: 'HR', NOONA_MFG: 'MFG', NOONA_HIS: 'HIS',
        NOONA_PRJ: 'HSP', NOONA_AUTO: 'AUT', NOONA_BI: '', NOONA_DOC: '', NOONA_ADMIN: '', NOONA_MASTER: ''};
    var SUGGEST = {
        FIN: ['كم الإيرادات هذا الشهر مقارنة بالسابق؟', 'ما توقع صافي الربح للأشهر الثلاثة القادمة؟', 'كم رصيد النقدية والبنوك الآن؟'],
        SAL: ['كم مبيعات نقاط البيع هذا الأسبوع؟', 'ما اتجاه مبيعات الفواتير آخر 6 أشهر؟', 'توقع المبيعات للشهر القادم'],
        SCM: ['كم قيمة المخزون الآن؟', 'ما المشتريات هذا الشهر مقارنة بالسابق؟'],
        HR: ['كم تكلفة الرواتب هذا العام؟', 'كم تعييناً جديداً هذا العام؟'],
        MFG: ['كم الكمية المنتجة هذا الشهر؟', 'توقع الإنتاج للأشهر القادمة'],
        HIS: ['كم زيارة للمرضى هذا الشهر؟', 'ما توقع إيرادات المستشفى؟'],
        AUT: ['كم أمر إصلاح هذا الشهر؟', 'ما إيرادات خدمة السيارات هذا العام؟'],
        HSP: ['كم نزيلاً سجل دخولاً هذا الشهر؟', 'ما مبيعات الوحدات العقارية هذا العام؟'],
        '': ['ما المؤشرات غير المعتادة هذا الشهر؟', 'لخص أداء الشركة هذا الشهر', 'ما الذي في هذه الصفحة؟']
    };
    var CSS = [
        '.nn-ai-fab{position:fixed;bottom:20px;inset-inline-start:20px;z-index:900;display:inline-flex;align-items:center;gap:8px;padding:12px 18px;border:0;border-radius:999px;',
        'background:linear-gradient(135deg,#0067c0,#6250d6);color:#fff;font:inherit;font-weight:700;box-shadow:0 8px 24px rgba(0,103,192,.35);cursor:pointer}',
        '.nn-ai-fab:hover{filter:brightness(1.08)}.nn-ai-fab:focus-visible{outline:3px solid #ffbf47;outline-offset:2px}',
        '.nn-ai-panel{position:fixed;bottom:80px;inset-inline-start:20px;z-index:901;width:min(420px,calc(100vw - 32px));height:min(620px,calc(100vh - 110px));',
        'display:flex;flex-direction:column;background:var(--nn-surface,#fff);border:1px solid var(--nn-border,#dde3ea);border-radius:16px;box-shadow:0 18px 48px rgba(16,24,40,.22);overflow:hidden}',
        '.nn-ai-panel[hidden]{display:none}',
        '.nn-ai-head{display:flex;align-items:center;gap:10px;padding:12px 14px;background:linear-gradient(135deg,#0067c0,#6250d6);color:#fff}',
        '.nn-ai-head>div{flex:1;display:flex;flex-direction:column}.nn-ai-head small{opacity:.85;font-size:.78rem}',
        '.nn-ai-ic{all:unset;cursor:pointer;width:32px;height:32px;border-radius:8px;display:inline-flex;align-items:center;justify-content:center}',
        '.nn-ai-ic:hover,.nn-ai-ic:focus-visible{background:rgba(255,255,255,.18)}',
        '.nn-ai-convs{max-height:45%;overflow:auto;border-bottom:1px solid var(--nn-border,#dde3ea);background:#f7f9fc}',
        '.nn-ai-conv{display:flex;align-items:center;border-bottom:1px solid var(--nn-border,#dde3ea)}',
        '.nn-ai-open{all:unset;cursor:pointer;flex:1;padding:9px 14px;display:flex;flex-direction:column;font-size:.88rem}.nn-ai-open small{color:var(--nn-muted,#4b5563)}',
        '.nn-ai-open:hover{background:#eef4fb}.nn-ai-del{all:unset;cursor:pointer;padding:8px 12px;color:#c42b1c}',
        '.nn-ai-msgs{flex:1;overflow:auto;padding:14px;display:flex;flex-direction:column;gap:10px;background:var(--nn-bg,#f3f6fa)}',
        '.nn-ai-msg{max-width:88%;padding:10px 12px;border-radius:14px;line-height:1.7;font-size:.92rem;word-wrap:break-word}',
        '.nn-ai-msg p{margin:0 0 4px}.nn-ai-msg ul{margin:4px 0;padding-inline-start:18px}',
        '.nn-ai-msg.is-user{align-self:flex-start;background:#0067c0;color:#fff;border-end-start-radius:4px}',
        '.nn-ai-msg.is-assistant{align-self:flex-end;background:var(--nn-surface,#fff);border:1px solid var(--nn-border,#dde3ea);border-end-end-radius:4px}',
        '.nn-ai-msg.is-err{border-color:#f3c7c2;background:#fdecea;color:#8a1c12}',
        '.nn-ai-fb{display:flex;gap:4px;margin-top:6px}.nn-ai-fb button{all:unset;cursor:pointer;padding:2px 6px;border-radius:6px;color:var(--nn-muted,#4b5563)}',
        '.nn-ai-fb button:hover{background:#eef4fb;color:#0067c0}',
        '.nn-ai-hello{display:flex;flex-direction:column;gap:8px;padding:6px;color:var(--nn-muted,#4b5563)}.nn-ai-hello b{color:var(--nn-text,#111827);font-size:1.05rem}',
        '.nn-ai-sugs{display:flex;flex-direction:column;gap:6px;margin-top:6px}',
        '.nn-ai-sug{all:unset;cursor:pointer;padding:8px 12px;border:1px solid var(--nn-border,#dde3ea);border-radius:10px;background:var(--nn-surface,#fff);color:var(--nn-text,#111827);font-size:.88rem}',
        '.nn-ai-sug:hover,.nn-ai-sug:focus-visible{border-color:#0067c0;color:#0067c0}',
        '.nn-ai-form{display:flex;gap:8px;padding:10px;border-top:1px solid var(--nn-border,#dde3ea);background:var(--nn-surface,#fff)}',
        '.nn-ai-input{flex:1;resize:none;border:1px solid var(--nn-border,#dde3ea);border-radius:10px;padding:8px 10px;font:inherit;max-height:120px}',
        '.nn-ai-input:focus{outline:none;border-color:#0067c0;box-shadow:0 0 0 3px #d4e7fa}',
        '.nn-ai-send{border:0;border-radius:10px;width:44px;background:#0067c0;color:#fff;cursor:pointer}.nn-ai-send:hover{background:#00539c}',
        '.nn-ai-foot{font-size:.72rem;color:var(--nn-muted,#4b5563);padding:0 12px 8px;background:var(--nn-surface,#fff)}',
        '.nn-ai-wait{padding:12px 14px;color:var(--nn-muted,#4b5563);font-size:.88rem}',
        '.nn-ai-dots{display:inline-flex;gap:3px;vertical-align:middle}.nn-ai-dots i{width:6px;height:6px;border-radius:50%;background:#6250d6;animation:nnAiB 1s infinite}',
        '.nn-ai-dots i:nth-child(2){animation-delay:.15s}.nn-ai-dots i:nth-child(3){animation-delay:.3s}',
        '@keyframes nnAiB{0%,80%,100%{opacity:.25}40%{opacity:1}}',
        '@media (prefers-reduced-motion:reduce){.nn-ai-dots i{animation:none}}',
        '.nn-ai-sum{background:linear-gradient(135deg,#f3f0ff,#eaf3fc);border:1px solid #d9d2fb;border-radius:12px;padding:14px 16px;margin-bottom:16px}',
        '.nn-ai-sum-h{display:flex;align-items:center;gap:8px;flex-wrap:wrap}.nn-ai-sum-h b{flex:1}.nn-ai-sum-h .fa{color:#6250d6}',
        '.nn-ai-sum-b{margin-top:8px;line-height:1.8}.nn-ai-sum-b ul{padding-inline-start:20px}.nn-ai-sum-at{display:block;color:var(--nn-muted,#4b5563);margin-top:6px}',
        '@media (max-width:640px){.nn-ai-fab-t{display:none}.nn-ai-panel{inset-inline-start:8px;bottom:72px;width:calc(100vw - 16px)}}'
    ].join('');
    var st = document.createElement('style'); st.textContent = CSS; document.head.appendChild(st);
    var app = ((location.pathname.match(/\/r\/[^/]+\/([^/?]+)/) || [])[1] || '').toUpperCase(), module = MOD[app] != null ? MOD[app] : '';
    var KEY = 'nnAiConv:' + app;
    var conv = null, busy = false, panel, list, input;
    try { conv = +sessionStorage.getItem(KEY) || null; } catch (e) { /* التخزين غير متاح */ }

    function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c]; }); }
    // تنسيق مختصر آمن: **عريض**، قوائم - و1.، أسطر
    function md(t) {
        var lines = esc(t).split('\n'), out = [], inList = false;
        lines.forEach(function (l) {
            var m = l.match(/^\s*(?:[-•*]|\d+[.)])\s+(.*)$/);
            if (m) { if (!inList) { out.push('<ul>'); inList = true; } out.push('<li>' + m[1] + '</li>'); return; }
            if (inList) { out.push('</ul>'); inList = false; }
            out.push(l.trim() ? '<p>' + l + '</p>' : '');
        });
        if (inList) out.push('</ul>');
        return out.join('').replace(/\*\*(.+?)\*\*/g, '<b>$1</b>');
    }
    function call(x, clob) {
        var data = x; if (clob != null) data.p_clob_01 = clob;
        return new Promise(function (ok, bad) {
            apex.server.process('NOONA_AI', data, {dataType: 'text'}).done(function (t) {
                var d; try { d = JSON.parse(t); } catch (e) { bad('استجابة غير متوقعة'); return; }
                if (d && d.ok === false) bad(d.msg || 'تعذر التنفيذ'); else ok(d);
            }).fail(function () { bad('تعذر الاتصال بالخادم'); });
        });
    }
    function pageContext() {
        var h = document.querySelector('.t-Breadcrumb-item.is-active .t-Breadcrumb-label, .t-Body-title .t-Breadcrumb-label');
        var main = document.querySelector('.t-Body-contentInner') || document.body;
        var txt = (main.innerText || '').replace(/\s+/g, ' ').trim();
        return {title: document.title || (h && h.innerText.trim()) || '', text: txt.slice(0, 3000), page: (apex.env && apex.env.APP_PAGE_ID) || ''};
    }

    // ------------------------------------------------------------------ الواجهة
    function build() {
        var btn = document.createElement('button');
        btn.type = 'button'; btn.className = 'nn-ai-fab'; btn.setAttribute('aria-label', 'مساعد نونا'); btn.title = 'مساعد نونا (الذكاء الاصطناعي)';
        btn.innerHTML = '<span class="fa fa-magic" aria-hidden="true"></span><span class="nn-ai-fab-t">اسأل نونا</span>';
        panel = document.createElement('section');
        panel.className = 'nn-ai-panel'; panel.hidden = true; panel.setAttribute('role', 'dialog'); panel.setAttribute('aria-label', 'مساعد نونا');
        panel.innerHTML =
            '<header class="nn-ai-head"><span class="fa fa-magic" aria-hidden="true"></span><div><b>مساعد نونا</b><small>يجيب من بيانات النظام بصلاحياتك</small></div>' +
            '<button type="button" class="nn-ai-ic nn-ai-hist" title="المحادثات السابقة" aria-label="المحادثات السابقة"><span class="fa fa-history" aria-hidden="true"></span></button>' +
            '<button type="button" class="nn-ai-ic nn-ai-new" title="محادثة جديدة" aria-label="محادثة جديدة"><span class="fa fa-plus" aria-hidden="true"></span></button>' +
            '<button type="button" class="nn-ai-ic nn-ai-close" title="إغلاق" aria-label="إغلاق"><span class="fa fa-times" aria-hidden="true"></span></button></header>' +
            '<div class="nn-ai-convs" hidden></div>' +
            '<div class="nn-ai-msgs" aria-live="polite"></div>' +
            '<form class="nn-ai-form"><textarea class="nn-ai-input" rows="2" maxlength="4000" placeholder="اسأل عن الأرقام والتنبؤات أو عن هذه الصفحة..." aria-label="سؤالك"></textarea>' +
            '<button type="submit" class="nn-ai-send" aria-label="إرسال"><span class="fa fa-send" aria-hidden="true"></span></button></form>' +
            '<div class="nn-ai-foot">قد يخطئ المساعد في الصياغة؛ الأرقام من النظام مباشرة. لا ينفذ عمليات.</div>';
        document.body.appendChild(btn); document.body.appendChild(panel);
        list = panel.querySelector('.nn-ai-msgs'); input = panel.querySelector('.nn-ai-input');
        btn.addEventListener('click', function () { panel.hidden = !panel.hidden; if (!panel.hidden) { open(); input.focus(); } });
        panel.querySelector('.nn-ai-close').addEventListener('click', function () { panel.hidden = true; btn.focus(); });
        panel.querySelector('.nn-ai-new').addEventListener('click', function () { setConv(null); welcome(); input.focus(); });
        panel.querySelector('.nn-ai-hist').addEventListener('click', history);
        panel.addEventListener('keydown', function (e) { if (e.key === 'Escape') { panel.hidden = true; btn.focus(); } });
        panel.querySelector('.nn-ai-form').addEventListener('submit', function (e) { e.preventDefault(); send(input.value); });
        input.addEventListener('keydown', function (e) { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send(input.value); } });
        list.addEventListener('click', function (e) {
            var s = e.target.closest('.nn-ai-sug'); if (s) { send(s.textContent); return; }
            var f = e.target.closest('.nn-ai-fb button');
            if (f) {
                call({x01: 'FB', x02: f.parentNode.dataset.id, x03: f.dataset.r}).then(function () {
                    f.parentNode.innerHTML = '<small>شكراً لتقييمك</small>';
                }).catch(function () {});
            }
        });
    }
    function setConv(id) { conv = id; try { if (id) sessionStorage.setItem(KEY, id); else sessionStorage.removeItem(KEY); } catch (e) { /* */ } }
    function welcome() {
        list.innerHTML = '<div class="nn-ai-hello"><b>مرحباً! كيف أساعدك؟</b><span>أجيب عن مؤشرات الأداء والتنبؤات والصفحة التي أمامك، من بيانات شركتك وبصلاحياتك.</span>' +
            '<div class="nn-ai-sugs">' + (SUGGEST[module] || SUGGEST['']).concat(module ? ['ما الذي في هذه الصفحة؟'] : []).map(function (q) {
                return '<button type="button" class="nn-ai-sug">' + esc(q) + '</button>'; }).join('') + '</div></div>';
    }
    function bubble(role, text, id) {
        var d = document.createElement('div');
        d.className = 'nn-ai-msg is-' + role;
        d.innerHTML = role === 'assistant' ? md(text) + (id ? '<div class="nn-ai-fb" data-id="' + id + '"><button type="button" data-r="1" aria-label="إجابة مفيدة" title="مفيدة"><span class="fa fa-thumbs-o-up" aria-hidden="true"></span></button>' +
            '<button type="button" data-r="-1" aria-label="إجابة غير مفيدة" title="غير مفيدة"><span class="fa fa-thumbs-o-down" aria-hidden="true"></span></button></div>' : '') : esc(text);
        var h = list.querySelector('.nn-ai-hello'); if (h) h.remove();
        list.appendChild(d); list.scrollTop = list.scrollHeight;
        return d;
    }
    function open() {
        if (!conv) { if (!list.children.length) welcome(); return; }
        if (list.children.length && !list.querySelector('.nn-ai-hello')) return;
        call({x01: 'MSGS', x02: conv}).then(function (ms) {
            list.innerHTML = ''; if (!ms.length) welcome();
            ms.forEach(function (m) { bubble(m.role, m.text, m.role === 'assistant' ? m.id : null); });
        }).catch(function () { setConv(null); welcome(); });
    }
    function history() {
        var box = panel.querySelector('.nn-ai-convs');
        if (!box.hidden) { box.hidden = true; return; }
        box.hidden = false; box.innerHTML = '<div class="nn-ai-wait">جار التحميل...</div>';
        call({x01: 'CONVS'}).then(function (cs) {
            box.innerHTML = cs.length ? cs.map(function (c) {
                return '<div class="nn-ai-conv"><button type="button" class="nn-ai-open" data-id="' + c.id + '">' + esc(c.title) + '<small>' + esc(c.at) + '</small></button>' +
                    '<button type="button" class="nn-ai-del" data-id="' + c.id + '" aria-label="حذف المحادثة" title="حذف"><span class="fa fa-trash-o" aria-hidden="true"></span></button></div>';
            }).join('') : '<div class="nn-ai-wait">لا توجد محادثات سابقة</div>';
        }).catch(function (m) { box.innerHTML = '<div class="nn-ai-wait">' + esc(m) + '</div>'; });
        box.onclick = function (e) {
            var o = e.target.closest('.nn-ai-open'), d = e.target.closest('.nn-ai-del');
            if (o) { setConv(+o.dataset.id); list.innerHTML = ''; box.hidden = true; open(); }
            if (d) call({x01: 'DEL', x02: d.dataset.id}).then(function () {
                if (+d.dataset.id === conv) { setConv(null); welcome(); }
                d.closest('.nn-ai-conv').remove();
            }).catch(function () {});
        };
    }
    function send(q) {
        q = (q || '').trim();
        if (!q || busy) return;
        busy = true; input.value = '';
        bubble('user', q);
        var w = bubble('assistant', ''); w.classList.add('is-wait'); w.innerHTML = '<span class="nn-ai-dots"><i></i><i></i><i></i></span> جار البحث في بيانات النظام...';
        var ctx = pageContext();
        call({x01: 'CHAT'}, JSON.stringify({conversationId: conv, question: q, app: app, page: String(ctx.page), pageTitle: ctx.title,
            module: module, pageText: ctx.text})).then(function (r) {
            setConv(r.conversationId);
            w.remove(); bubble('assistant', r.answer, r.messageId);
        }).catch(function (m) {
            w.classList.remove('is-wait'); w.classList.add('is-err'); w.textContent = m;
        }).then(function () { busy = false; input.focus(); });
    }

    // ------------------------------------------------------------------ الملخص التنفيذي في اللوحة الموحدة
    function summaryCard() {
        var host = document.querySelector('#nnAnl[data-unified="Y"]');
        if (!host) return;
        var card = document.createElement('section');
        card.className = 'nn-ai-sum';
        card.innerHTML = '<div class="nn-ai-sum-h"><span class="fa fa-magic" aria-hidden="true"></span> <b>الملخص التنفيذي بالذكاء الاصطناعي</b>' +
            '<button type="button" class="t-Button t-Button--small t-Button--hot nn-ai-sum-go">إنشاء الملخص</button></div><div class="nn-ai-sum-b">' +
            '<small>يقرأ المساعد مؤشرات كل الموديولات المتاحة لك والقيم غير المعتادة ويكتب أبرز التغيرات والمخاطر والتوصيات.</small></div>';
        host.insertBefore(card, host.children[1] || null);
        card.querySelector('.nn-ai-sum-go').addEventListener('click', function (e) {
            var b = card.querySelector('.nn-ai-sum-b'), go = e.currentTarget;
            go.disabled = true; b.innerHTML = '<span class="nn-ai-dots"><i></i><i></i><i></i></span> جار التحليل...';
            var br = host.querySelector('.nn-anl-branch');
            call({x01: 'SUMMARY', x02: br ? br.value : ''}).then(function (r) {
                b.innerHTML = md(r.summary) + '<small class="nn-ai-sum-at">أنشئ في ' + esc(r.asOf) + ' · الأرقام من النظام والصياغة بالذكاء الاصطناعي</small>';
            }).catch(function (m) { b.innerHTML = '<div class="nn-anl-err">' + esc(m) + '</div>'; }).then(function () { go.disabled = false; go.textContent = 'تحديث الملخص'; });
        });
    }

    window.nnAi = {send: function (q) { panel.hidden = false; open(); send(q); }};
    call({x01: 'STATE'}).then(function (s) {
        if (s.available !== 'Y') return;
        build();
        // يظهر بعد بناء لوحة التحليلات
        var tries = 0, t = setInterval(function () { if (document.querySelector('.nn-anl-bar') || ++tries > 20) { clearInterval(t); summaryCard(); } }, 300);
    }).catch(function () { /* المساعد غير متاح: لا شيء يظهر */ });
})();
