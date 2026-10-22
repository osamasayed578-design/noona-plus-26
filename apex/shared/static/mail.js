/* NOONA PLUS | صندوق المراسلات (تصميم مشابه لـ Gmail بألوان النظام) - تطبيق المستندات والمراسلات 129
   البيانات من NOONA_COR_PKG عبر عملية AJAX واحدة (MAIL) والعملية في x01. */
(function () {
  'use strict';
  var root = document.getElementById('nnMail');
  if (!root || root.dataset.ready) return;
  root.dataset.ready = '1';

  var S = { folder: 'INBOX', q: '', off: 0, meta: null, counts: {}, rows: [], thread: null, view: 'list', more: false };
  var FOLDERS = [
    ['INBOX', 'الوارد', 'fa-inbox'], ['TASKS', 'المطلوب مني', 'fa-check-square-o'], ['STARRED', 'المميزة بنجمة', 'fa-star'],
    ['SENT', 'المرسلة', 'fa-paper-plane'], ['DRAFTS', 'المسودات', 'fa-file-text-o'], ['ARCHIVE', 'الأرشيف', 'fa-archive']];
  var REGS = [['INCOMING', 'سجل الوارد', 'fa-sign-in'], ['OUTGOING', 'سجل الصادر', 'fa-sign-out']];
  var KIND = { INTERNAL: 'داخلية', INCOMING: 'خطاب وارد', OUTGOING: 'خطاب صادر' };
  var PRIO = [['LOW', 'منخفضة'], ['NORMAL', 'عادية'], ['HIGH', 'مهمة'], ['URGENT', 'عاجلة'], ['VERY_URGENT', 'عاجلة جداً']];

  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  function el(tag, cls, html) { var e = document.createElement(tag); if (cls) e.className = cls; if (html != null) e.innerHTML = html; return e; }
  function icon(n) { return '<span class="fa ' + n + '" aria-hidden="true"></span>'; }
  function color(name) {
    var h = 0, s = String(name || '');
    for (var i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) % 360;
    return 'hsl(' + h + ',55%,42%)';
  }
  function avatar(name, ini) { return '<span class="nn-mail-av" style="background:' + color(name) + '">' + esc(ini || (name || '?').charAt(0)) + '</span>'; }

  function call(op, args, clob) {
    var d = { x01: op };
    (args || []).forEach(function (v, i) { d['x0' + (i + 2)] = v == null ? '' : String(v); });
    if (clob != null) d.p_clob_01 = clob;
    return apex.server.process('MAIL', d).then(function (r) {
      if (r && r.error) { toast(r.error, true); throw new Error(r.error); }
      return r;
    }, function (x) { toast('تعذر الاتصال بالخادم', true); throw x; });
  }
  function callText(op, args) {
    var d = { x01: op };
    (args || []).forEach(function (v, i) { d['x0' + (i + 2)] = v == null ? '' : String(v); });
    return apex.server.process('MAIL', d, { dataType: 'text' });
  }

  var toastTimer;
  function toast(msg, err) {
    var t = root.querySelector('.nn-mail-toast');
    t.textContent = msg; t.classList.toggle('is-err', !!err); t.classList.add('is-on');
    clearTimeout(toastTimer); toastTimer = setTimeout(function () { t.classList.remove('is-on'); }, err ? 6000 : 3500);
  }

  // ------------------------------------------------------------ الهيكل
  root.innerHTML =
    '<div class="nn-mail-top"><div class="nn-mail-search">' + icon('fa-search') +
    '<input type="search" placeholder="البحث في المراسلات (الموضوع، الرقم، النص، الجهة)" aria-label="بحث"></div>' +
    '<button type="button" class="nn-mail-ib" data-a="refresh" title="تحديث">' + icon('fa-refresh') + '</button></div>' +
    '<div class="nn-mail-body"><aside class="nn-mail-side"><button type="button" class="nn-mail-compose">' + icon('fa-pencil') +
    '<span>إنشاء</span></button><nav class="nn-mail-folders"></nav></aside><section class="nn-mail-main"></section></div>' +
    '<div class="nn-mail-composers"></div><div class="nn-mail-toast" role="status" aria-live="polite"></div>';
  var main = root.querySelector('.nn-mail-main');
  var search = root.querySelector('.nn-mail-search input');

  function renderFolders() {
    var nav = root.querySelector('.nn-mail-folders'), h = '';
    function f(x) {
      var n = S.counts[x[0]];
      h += '<a href="#" class="nn-mail-f' + (S.folder === x[0] ? ' is-on' : '') + (n ? ' has-n' : '') + '" data-f="' + x[0] + '">' +
        icon(x[2]) + '<span>' + x[1] + '</span>' + (n ? '<b>' + n + '</b>' : '') + '</a>';
    }
    FOLDERS.forEach(f);
    if (S.meta && S.meta.canView === 'Y') { h += '<div class="nn-mail-sep">الوارد والصادر الرسمي</div>'; REGS.forEach(f); }
    nav.innerHTML = h;
  }

  function loadCounts() { return call('FOLDERS').then(function (r) { S.counts = r; renderFolders(); }); }

  // ------------------------------------------------------------ القائمة
  function loadList(keep) {
    if (!keep) S.off = 0;
    S.view = 'list';
    main.innerHTML = '<div class="nn-mail-loading">' + icon('fa-circle-o-notch fa-spin') + '</div>';
    return call('LIST', [S.folder, S.q, S.off]).then(function (r) { S.rows = r.rows; S.more = r.more === 'Y'; renderList(); });
  }

  function folderName() {
    var all = FOLDERS.concat(REGS);
    for (var i = 0; i < all.length; i++) if (all[i][0] === S.folder) return all[i][1];
    return '';
  }

  function renderList() {
    var reg = S.folder === 'INCOMING' || S.folder === 'OUTGOING';
    var h = '<div class="nn-mail-bar"><b class="nn-mail-title">' + esc(S.q ? 'نتائج البحث: ' + S.q : folderName()) + '</b>' +
      '<span class="nn-mail-pager">' + (S.rows.length ? (S.off + 1) + '–' + (S.off + S.rows.length) : '0') +
      '<button type="button" class="nn-mail-ib" data-a="prev"' + (S.off ? '' : ' disabled') + ' title="الأحدث">' + icon('fa-chevron-right') + '</button>' +
      '<button type="button" class="nn-mail-ib" data-a="next"' + (S.more ? '' : ' disabled') + ' title="الأقدم">' + icon('fa-chevron-left') + '</button></span></div>';
    if (!S.rows.length) {
      h += '<div class="nn-mail-empty">' + icon(S.folder === 'TASKS' ? 'fa-check-circle' : 'fa-inbox') + '<div>' +
        (S.q ? 'لا توجد نتائج' : S.folder === 'TASKS' ? 'لا يوجد مطلوب منك الآن' : 'لا توجد مراسلات هنا') + '</div></div>';
      main.innerHTML = h; return;
    }
    h += '<div class="nn-mail-list" role="list">';
    S.rows.forEach(function (r, i) {
      var chips = '';
      if (r.k === 'INCOMING' || r.k === 'OUTGOING') chips += '<span class="nn-mail-chip is-' + r.k.toLowerCase() + '">' + (r.k === 'INCOMING' ? 'وارد' : 'صادر') + '</span>';
      if (r.p === 'URGENT' || r.p === 'VERY_URGENT') chips += '<span class="nn-mail-chip is-urgent">' + (r.p === 'URGENT' ? 'عاجلة' : 'عاجلة جداً') + '</span>';
      if (r.task === 'Y') chips += '<span class="nn-mail-chip ' + (r.late === 'Y' ? 'is-late' : 'is-task') + '">' + icon('fa-flag') +
        (r.due ? ' ' + esc(r.due) : ' مطلوب') + '</span>';
      if (r.draft === 'Y') chips += '<span class="nn-mail-chip is-draft">مسودة</span>';
      h += '<div class="nn-mail-row' + (r.u === 'Y' ? ' is-unread' : '') + '" role="listitem" data-i="' + i + '" tabindex="0">' +
        (reg || r.draft === 'Y' ? '<span class="nn-mail-star-x"></span>' :
          '<button type="button" class="nn-mail-star' + (r.st === 'Y' ? ' is-on' : '') + '" data-a="star" title="نجمة">' + icon(r.st === 'Y' ? 'fa-star' : 'fa-star-o') + '</button>') +
        '<span class="nn-mail-who">' + esc(r.who || '-') + (r.n > 1 ? ' <small>' + r.n + '</small>' : '') + '</span>' +
        '<span class="nn-mail-sub">' + chips + (r.no && reg ? '<span class="nn-mail-no">' + esc(r.no) + '</span>' : '') +
        '<b>' + esc(r.s) + '</b><span class="nn-mail-sn"> — ' + esc(r.sn) + '</span></span>' +
        '<span class="nn-mail-meta">' + (r.a === 'Y' ? icon('fa-paperclip') : '') + '<span class="nn-mail-date">' + esc(r.d) + '</span>' +
        (reg || r.draft === 'Y' ? '' : '<span class="nn-mail-hover"><button type="button" class="nn-mail-ib" data-a="' +
          (S.folder === 'ARCHIVE' ? 'restore' : 'archive') + '" title="' + (S.folder === 'ARCHIVE' ? 'نقل إلى الوارد' : 'أرشفة') + '">' +
          icon(S.folder === 'ARCHIVE' ? 'fa-inbox' : 'fa-archive') + '</button><button type="button" class="nn-mail-ib" data-a="unread" title="تعليم كغير مقروءة">' +
          icon('fa-envelope') + '</button></span>') + '</span></div>';
    });
    main.innerHTML = h + '</div>';
  }

  // ------------------------------------------------------------ السلسلة
  function openThread(id) {
    S.view = 'thread';
    main.innerHTML = '<div class="nn-mail-loading">' + icon('fa-circle-o-notch fa-spin') + '</div>';
    return call('THREAD', [id]).then(function (t) { S.thread = t; renderThread(); loadCounts(); },
      function () { loadList(); });
  }

  function fileUrl(m, d, mode) {
    // رابط ودي يولده الخادم بقيم مؤقتة تستبدل هنا
    return root.dataset.file.replace('990000000001', m).replace('990000000002', d).replace(/V$/, mode || 'V');
  }

  function renderThread() {
    var t = S.thread, last = t.msgs.length - 1;
    var h = '<div class="nn-mail-bar"><button type="button" class="nn-mail-ib" data-a="back" title="رجوع">' + icon('fa-arrow-right') + '</button>' +
      (t.inbox === 'Y' ? '<button type="button" class="nn-mail-ib" data-a="archive" title="أرشفة">' + icon('fa-archive') + '</button>'
        : '<button type="button" class="nn-mail-ib" data-a="restore" title="نقل إلى الوارد">' + icon('fa-inbox') + '</button>') +
      '<button type="button" class="nn-mail-ib" data-a="unread" title="تعليم كغير مقروءة">' + icon('fa-envelope') + '</button>' +
      '<button type="button" class="nn-mail-ib" data-a="print" title="طباعة الخطاب">' + icon('fa-print') + '</button></div>' +
      '<div class="nn-mail-thread"><div class="nn-mail-th"><h2>' + esc(t.subject) + '</h2>' +
      '<button type="button" class="nn-mail-star' + (t.star === 'Y' ? ' is-on' : '') + '" data-a="tstar" title="نجمة">' + icon(t.star === 'Y' ? 'fa-star' : 'fa-star-o') + '</button></div>';
    t.msgs.forEach(function (m, i) {
      var open = i === last || (m.my && m.my.unread === 'Y');
      var recip = (m.k === 'OUTGOING' ? 'إلى: ' + esc(m.party) + (m.to.length ? ' · نسخة داخلية: ' + esc(m.to.join('، ')) : '')
        : 'إلى: ' + esc(m.to.join('، ') || '-')) + (m.cc.length ? ' · نسخة: ' + esc(m.cc.join('، ')) : '') +
        (m.bcc.length ? ' · مخفية: ' + esc(m.bcc.join('، ')) : '') + (m.meBcc === 'Y' ? ' · <i>نسخة مخفية لك</i>' : '');
      h += '<article class="nn-mail-msg' + (open ? ' is-open' : '') + '" data-m="' + i + '"><header class="nn-mail-mh" data-a="toggle">' +
        avatar(m.from, m.fi) + '<div class="nn-mail-mf"><b>' + esc(m.from) + '</b>' + (m.by ? ' <small>(' + esc(m.by) + ')</small>' : '') +
        '<div class="nn-mail-to">' + recip + '</div><div class="nn-mail-snip">' + esc((m.body || '').slice(0, 140)) + '</div></div>' +
        '<div class="nn-mail-md">' + (m.att.length ? icon('fa-paperclip') + ' ' : '') + '<span title="' + esc(m.at) + '">' + esc(m.al) + '</span></div></header>' +
        '<div class="nn-mail-mb"><div class="nn-mail-tags">' +
        (m.no ? '<span class="nn-mail-chip">' + esc(m.typ || m.kl) + ' ' + esc(m.no) + '</span>' : '') +
        (m.k !== 'INTERNAL' && m.ext ? '<span class="nn-mail-chip">الرقم الخارجي ' + esc(m.ext) + (m.ld ? ' بتاريخ ' + esc(m.ld) : '') + '</span>' : '') +
        (m.p !== 'NORMAL' ? '<span class="nn-mail-chip' + (m.p === 'URGENT' || m.p === 'VERY_URGENT' ? ' is-urgent' : '') + '">الأولوية: ' + esc(m.pl) + '</span>' : '') +
        '<span class="nn-mail-chip is-muted">' + esc(m.at) + '</span></div>';
      if (m.my && m.my.ins) {
        var pending = m.my.task === 'Y' && (m.my.act === 'NONE' || m.my.act === 'ACKNOWLEDGED');
        h += '<div class="nn-mail-ask' + (m.my.late === 'Y' ? ' is-late' : pending ? '' : ' is-done') + '">' + icon(pending ? 'fa-flag' : 'fa-check') +
          '<span>مطلوب منك: <b>' + esc(m.my.ins) + '</b>' + (m.my.due ? ' · المهلة ' + esc(m.my.due) : '') +
          (m.my.act === 'ACTIONED' ? ' · تم الإنجاز' : m.my.act === 'FORWARDED' ? ' · أحلتها' : m.my.act === 'ACKNOWLEDGED' ? ' · تم الاطلاع' : '') + '</span>' +
          (pending ? '<span class="nn-mail-ask-b">' + (m.my.act === 'NONE' ? '<button type="button" data-a="ack">تم الاطلاع</button>' : '') +
            '<button type="button" data-a="done">تم الإنجاز</button><button type="button" data-a="refer">إحالة</button></span>' : '') + '</div>';
      }
      h += '<div class="nn-mail-text">' + esc(m.body) + '</div>';
      if (m.att.length) {
        h += '<div class="nn-mail-atts">';
        m.att.forEach(function (a) {
          h += '<a class="nn-mail-att" target="_blank" rel="noopener" href="' + fileUrl(m.id, a.d) + '">' +
            icon(/pdf/.test(a.m) ? 'fa-file-pdf-o' : /image/.test(a.m) ? 'fa-file-image-o' : /sheet/.test(a.m) ? 'fa-file-excel-o' : 'fa-file-word-o') +
            '<span>' + esc(a.n) + '</span><small>' + esc(a.s) + '</small></a>';
        });
        h += '</div>';
      }
      if (m.refs.length) {
        h += '<div class="nn-mail-refs">';
        m.refs.forEach(function (f) {
          h += '<div class="nn-mail-ref">' + icon('fa-share') + ' <b>' + esc(f.f) + '</b> أحالها إلى <b>' + esc(f.to) + '</b> ' +
            esc(f.ins) + (f.due ? ' · المهلة ' + esc(f.due) : '') + ' · ' + esc(f.at) + (f.done === 'Y' ? ' · <span class="nn-mail-ok">منجزة</span>' : '') +
            (f.note ? '<div class="nn-mail-ref-n">' + esc(f.note) + '</div>' : '') + '</div>';
        });
        h += '</div>';
      }
      h += '<div class="nn-mail-acts"><button type="button" data-a="reply">' + icon('fa-reply') + ' رد</button>' +
        '<button type="button" data-a="replyall">' + icon('fa-reply-all') + ' رد على الكل</button>' +
        '<button type="button" data-a="forward">' + icon('fa-share') + ' تحويل</button>' +
        (!m.my || m.my.task !== 'Y' ? '<button type="button" data-a="refer">' + icon('fa-random') + ' إحالة</button>' : '') + '</div></div></article>';
    });
    main.innerHTML = h + '</div>';
  }

  // ------------------------------------------------------------ نافذة الإنشاء
  var composers = root.querySelector('.nn-mail-composers');

  function recipientsField(c, role, label) {
    var w = el('div', 'nn-mail-rcp');
    w.innerHTML = '<label>' + label + '</label><div class="nn-mail-chips"></div><input type="text" autocomplete="off" aria-label="' + label + '">' +
      '<div class="nn-mail-sug" hidden></div>';
    var chips = w.querySelector('.nn-mail-chips'), inp = w.querySelector('input'), sug = w.querySelector('.nn-mail-sug');
    var timer, items = [], act = -1;
    function draw() {
      chips.innerHTML = '';
      c.doc[role].forEach(function (r, i) {
        var ch = el('span', 'nn-mail-pill' + (r.k === 'O' ? ' is-unit' : ''), avatar(r.n, r.k === 'O' ? '#' : null) + esc(r.n) +
          '<button type="button" title="إزالة" aria-label="إزالة">×</button>');
        ch.querySelector('button').onclick = function () { c.doc[role].splice(i, 1); draw(); c.dirty = true; };
        chips.appendChild(ch);
      });
    }
    function pick(r) {
      if (!c.doc[role].some(function (x) { return x.k === r.k && x.id === r.id; })) c.doc[role].push({ k: r.k, id: r.id, n: r.n });
      inp.value = ''; sug.hidden = true; draw(); c.dirty = true; inp.focus();
    }
    function show() {
      sug.innerHTML = items.map(function (r, i) {
        return '<div class="nn-mail-sg' + (i === act ? ' is-act' : '') + '" data-i="' + i + '">' + avatar(r.n, r.i) +
          '<span><b>' + esc(r.n) + '</b><small>' + esc(r.e || '') + '</small></span></div>';
      }).join('') || '<div class="nn-mail-sg is-none">لا نتائج</div>';
      sug.hidden = false;
    }
    inp.addEventListener('input', function () {
      clearTimeout(timer);
      var q = inp.value.trim();
      if (!q) { sug.hidden = true; return; }
      timer = setTimeout(function () { call('DIR', [q]).then(function (r) { items = r; act = r.length ? 0 : -1; show(); }); }, 220);
    });
    inp.addEventListener('keydown', function (e) {
      if (sug.hidden) { if (e.key === 'Backspace' && !inp.value && c.doc[role].length) { c.doc[role].pop(); draw(); } return; }
      if (e.key === 'ArrowDown') { act = Math.min(act + 1, items.length - 1); show(); e.preventDefault(); }
      else if (e.key === 'ArrowUp') { act = Math.max(act - 1, 0); show(); e.preventDefault(); }
      else if (e.key === 'Enter') { if (items[act]) pick(items[act]); e.preventDefault(); }
      else if (e.key === 'Escape') { sug.hidden = true; }
    });
    inp.addEventListener('blur', function () { setTimeout(function () { sug.hidden = true; }, 200); });
    sug.addEventListener('mousedown', function (e) {
      var d = e.target.closest('[data-i]'); if (d) { e.preventDefault(); pick(items[+d.dataset.i]); }
    });
    draw();
    return w;
  }

  function opts(list, v) {
    return list.map(function (o) { return '<option value="' + esc(o[0]) + '"' + (o[0] === v ? ' selected' : '') + '>' + esc(o[1]) + '</option>'; }).join('');
  }

  function compose(doc) {
    // نافذة واحدة لكل مسودة؛ وحد أقصى نافذتان مفتوحتان
    var open = composers.querySelectorAll('.nn-mail-cw');
    if (open.length >= 2) open[0].remove();
    doc = doc || {};
    var c = { doc: { id: doc.id || null, kind: doc.kind || 'INTERNAL', type: doc.type || null, to: doc.to || [], cc: doc.cc || [],
      bcc: doc.bcc || [], subject: doc.subject || '', body: doc.body || '', priority: doc.priority || 'NORMAL', instr: doc.instr || '',
      due: doc.due || '', parent: doc.parent || null, rel: doc.rel || null, ext_no: doc.ext_no || '', letter_date: doc.letter_date || '',
      party: doc.party || '', party_id: doc.party_id || null, conf: doc.conf || 'INTERNAL' }, att: doc.att || [], dirty: false, busy: false };
    var w = el('div', 'nn-mail-cw');
    var canReg = S.meta && S.meta.canReg === 'Y';
    var types = (S.meta ? S.meta.types : []);
    w.innerHTML = '<div class="nn-mail-cwh"><b>' + (c.doc.rel === 'FORWARD' ? 'تحويل' : c.doc.parent ? 'رد' : 'رسالة جديدة') + '</b>' +
      '<span><button type="button" data-c="min" title="تصغير">' + icon('fa-minus') + '</button><button type="button" data-c="max" title="تكبير">' +
      icon('fa-expand') + '</button><button type="button" data-c="close" title="حفظ وإغلاق">' + icon('fa-times') + '</button></span></div>' +
      '<div class="nn-mail-cwb">' +
      (canReg ? '<div class="nn-mail-kind" role="radiogroup">' + ['INTERNAL', 'INCOMING', 'OUTGOING'].map(function (k) {
        return '<button type="button" data-k="' + k + '" class="' + (c.doc.kind === k ? 'is-on' : '') + '">' + KIND[k] + '</button>';
      }).join('') + '<select class="nn-mail-type" aria-label="نوع المراسلة"></select></div>' : '') +
      '<div class="nn-mail-ext"><div class="nn-mail-line"><label>الجهة</label><input type="text" class="nn-mail-party" autocomplete="off" placeholder="اسم الجهة الخارجية">' +
      '<div class="nn-mail-sug" hidden></div></div><div class="nn-mail-line nn-mail-2"><label>الرقم الخارجي</label><input type="text" class="nn-mail-extno">' +
      '<label>تاريخ الخطاب</label><input type="date" class="nn-mail-ld"></div></div>' +
      '<div class="nn-mail-r-to"></div><div class="nn-mail-r-cc" hidden></div><div class="nn-mail-r-bcc" hidden></div>' +
      '<div class="nn-mail-line"><input type="text" class="nn-mail-subj" placeholder="الموضوع" aria-label="الموضوع" maxlength="1000">' +
      '<button type="button" class="nn-mail-lnk" data-c="cc">نسخة</button><button type="button" class="nn-mail-lnk" data-c="bcc">مخفية</button></div>' +
      '<div class="nn-mail-opts"><label>الأولوية <select class="nn-mail-prio">' + opts(PRIO, c.doc.priority) + '</select></label>' +
      '<label>التعليمة <select class="nn-mail-ins"><option value="">بدون</option>' +
      opts((S.meta ? S.meta.instr : []).map(function (i) { return [i.c, i.n]; }), c.doc.instr) + '</select></label>' +
      '<label>المهلة <input type="date" class="nn-mail-due"></label></div>' +
      '<textarea class="nn-mail-txt" placeholder="نص المراسلة" aria-label="نص المراسلة"></textarea>' +
      '<div class="nn-mail-catts"></div></div>' +
      '<div class="nn-mail-cwf"><button type="button" class="nn-mail-send" data-c="send">إرسال</button>' +
      '<label class="nn-mail-ib" title="إرفاق ملف (PDF، صور، Word، Excel حتى 20MB)">' + icon('fa-paperclip') +
      '<input type="file" multiple hidden accept=".pdf,.png,.jpg,.jpeg,.gif,.webp,.tif,.tiff,.docx,.xlsx"></label>' +
      '<span class="nn-mail-state"></span><button type="button" class="nn-mail-ib nn-mail-del" data-c="del" title="حذف المسودة">' + icon('fa-trash-o') + '</button></div>';
    composers.appendChild(w);
    var q = function (s) { return w.querySelector(s); };
    q('.nn-mail-r-to').appendChild(recipientsField(c, 'to', c.doc.kind === 'INCOMING' ? 'إحالة إلى' : 'إلى'));
    q('.nn-mail-r-cc').appendChild(recipientsField(c, 'cc', 'نسخة'));
    q('.nn-mail-r-bcc').appendChild(recipientsField(c, 'bcc', 'مخفية'));
    if (c.doc.cc.length) q('.nn-mail-r-cc').hidden = false;
    if (c.doc.bcc.length) q('.nn-mail-r-bcc').hidden = false;
    q('.nn-mail-subj').value = c.doc.subject;
    q('.nn-mail-txt').value = c.doc.body;
    q('.nn-mail-due').value = c.doc.due;
    q('.nn-mail-party').value = c.doc.party;
    q('.nn-mail-extno').value = c.doc.ext_no;
    q('.nn-mail-ld').value = c.doc.letter_date;

    function kindUi() {
      w.classList.toggle('is-ext', c.doc.kind !== 'INTERNAL');
      if (q('.nn-mail-type')) {
        q('.nn-mail-type').innerHTML = types.filter(function (t) { return t.k === c.doc.kind; }).map(function (t) {
          return '<option value="' + esc(t.c) + '"' + (t.c === c.doc.type ? ' selected' : '') + '>' + esc(t.n) + '</option>';
        }).join('');
        c.doc.type = q('.nn-mail-type').value || null;
        w.querySelectorAll('.nn-mail-kind button').forEach(function (b) { b.classList.toggle('is-on', b.dataset.k === c.doc.kind); });
      }
      q('.nn-mail-r-to label').textContent = c.doc.kind === 'INCOMING' ? 'إحالة إلى' : c.doc.kind === 'OUTGOING' ? 'نسخة داخلية' : 'إلى';
    }
    kindUi();
    renderAtts();

    function collect() {
      c.doc.subject = q('.nn-mail-subj').value; c.doc.body = q('.nn-mail-txt').value; c.doc.priority = q('.nn-mail-prio').value;
      c.doc.instr = q('.nn-mail-ins').value; c.doc.due = q('.nn-mail-due').value; c.doc.party = q('.nn-mail-party').value;
      c.doc.ext_no = q('.nn-mail-extno').value; c.doc.letter_date = q('.nn-mail-ld').value;
      if (q('.nn-mail-type')) c.doc.type = q('.nn-mail-type').value || null;
      return JSON.stringify(c.doc);
    }
    function state(t) { q('.nn-mail-state').textContent = t || ''; }
    function save() {
      collect();
      if (!c.doc.id && !c.dirty && !c.doc.subject && !c.doc.body && !c.doc.to.length) return $.Deferred().resolve().promise();
      state('جارٍ الحفظ…');
      return call('SAVE', [], JSON.stringify(c.doc)).then(function (r) { c.doc.id = r.id; c.dirty = false; state('حُفظت المسودة'); });
    }
    function renderAtts() {
      q('.nn-mail-catts').innerHTML = c.att.map(function (a, i) {
        return '<span class="nn-mail-catt">' + icon('fa-paperclip') + ' ' + esc(a.n) + (a.s ? ' <small>' + esc(a.s) + '</small>' : '') +
          '<button type="button" data-x="' + i + '" title="إزالة">×</button></span>';
      }).join('');
    }
    w.addEventListener('input', function () { c.dirty = true; state(''); });
    w.addEventListener('change', function (e) { if (e.target.matches('.nn-mail-type')) c.doc.type = e.target.value; });
    // اقتراح الجهات الخارجية
    (function () {
      var inp = q('.nn-mail-party'), sug = q('.nn-mail-ext .nn-mail-sug'), timer, items = [];
      inp.addEventListener('input', function () {
        c.doc.party_id = null; clearTimeout(timer);
        var v = inp.value.trim(); if (v.length < 2) { sug.hidden = true; return; }
        timer = setTimeout(function () {
          call('PARTY', [v]).then(function (r) {
            items = r; if (!r.length) { sug.hidden = true; return; }
            sug.innerHTML = r.map(function (p, i) { return '<div class="nn-mail-sg" data-i="' + i + '"><span><b>' + esc(p.n) + '</b></span></div>'; }).join('');
            sug.hidden = false;
          });
        }, 250);
      });
      inp.addEventListener('blur', function () { setTimeout(function () { sug.hidden = true; }, 200); });
      sug.addEventListener('mousedown', function (e) {
        var d = e.target.closest('[data-i]'); if (!d) return; e.preventDefault();
        var p = items[+d.dataset.i]; inp.value = p.n; c.doc.party_id = p.id; sug.hidden = true; c.dirty = true;
      });
    })();
    w.addEventListener('click', function (e) {
      var b = e.target.closest('[data-c],[data-k],[data-x]');
      if (!b) { if (w.classList.contains('is-min') && e.target.closest('.nn-mail-cwh')) w.classList.remove('is-min'); return; }
      if (b.dataset.k) { c.doc.kind = b.dataset.k; c.doc.type = null; kindUi(); c.dirty = true; return; }
      if (b.dataset.x != null) {
        var a = c.att[+b.dataset.x];
        call('UNATTACH', [c.doc.id, a.d]).then(function () { c.att.splice(+b.dataset.x, 1); renderAtts(); });
        return;
      }
      var cmd = b.dataset.c;
      if (cmd === 'min') w.classList.toggle('is-min');
      else if (cmd === 'max') w.classList.toggle('is-max');
      else if (cmd === 'cc' || cmd === 'bcc') { q('.nn-mail-r-' + cmd).hidden = false; q('.nn-mail-r-' + cmd + ' input').focus(); }
      else if (cmd === 'close') { save().then(function () { w.remove(); if (c.doc.id) { toast('حُفظت في المسودات'); refreshSoft(); } }); }
      else if (cmd === 'del') {
        if (!c.doc.id) { w.remove(); return; }
        call('DELDRAFT', [c.doc.id]).then(function () { w.remove(); toast('حُذفت المسودة'); refreshSoft(); });
      } else if (cmd === 'send') {
        if (c.busy) return; c.busy = true; collect(); state('جارٍ الإرسال…');
        call('SEND', [], JSON.stringify(c.doc)).then(function () {
          w.remove(); toast(c.doc.kind === 'INCOMING' ? 'سُجل الخطاب الوارد ووزع' : c.doc.kind === 'OUTGOING' ? 'سُجل الخطاب الصادر' : 'تم إرسال الرسالة');
          refreshSoft();
        }, function () { c.busy = false; state(''); });
      }
    });
    q('input[type=file]').addEventListener('change', function (e) {
      var files = Array.prototype.slice.call(e.target.files); e.target.value = '';
      save().then(function () {
        if (!c.doc.id) return call('SAVE', [], collect()).then(function (r) { c.doc.id = r.id; });
      }).then(function () {
        files.forEach(function (f) {
          if (f.size > 20 * 1048576) { toast('الملف ' + f.name + ' أكبر من 20MB', true); return; }
          var tmp = { n: f.name, s: 'جارٍ الرفع…' }; c.att.push(tmp); renderAtts();
          var rd = new FileReader();
          rd.onload = function () {
            var b64 = String(rd.result).split(',')[1];
            call('ATTACH', [c.doc.id, f.name, f.type || 'application/octet-stream'], b64).then(function (r) {
              tmp.d = r.doc; tmp.s = f.size < 1048576 ? Math.ceil(f.size / 1024) + ' KB' : (f.size / 1048576).toFixed(1) + ' MB'; renderAtts();
            }, function () { c.att.splice(c.att.indexOf(tmp), 1); renderAtts(); });
          };
          rd.readAsDataURL(f);
        });
      });
    });
    setTimeout(function () { (c.doc.to.length || c.doc.kind !== 'INTERNAL' ? q(c.doc.subject ? '.nn-mail-txt' : '.nn-mail-subj') : q('.nn-mail-r-to input')).focus(); }, 30);
    return c;
  }

  function quoteOf(m) {
    return '\n\n---------- ' + m.from + ' · ' + m.at + ' ----------\n' + (m.body || '');
  }

  function replyTo(m, all) {
    var t = S.thread;
    var subj = /^رد:/.test(t.subject) ? t.subject : 'رد: ' + t.subject;
    call('DRAFTSEED', [m.id, all ? 'Y' : 'N']).then(function (r) {
      var ext = m.k === 'INCOMING' && S.meta.canReg === 'Y';
      compose({ to: ext ? [] : r.to, cc: all ? r.cc : [], subject: subj, body: quoteOf(m), parent: m.id, rel: all ? 'REPLY_ALL' : 'REPLY',
        kind: ext ? 'OUTGOING' : 'INTERNAL', party: m.k === 'INCOMING' ? m.party : '' });
    });
  }

  // ------------------------------------------------------------ الحوارات
  function dialog(title, html, okText, onOk) {
    var d = el('div', 'nn-mail-dlg', '<div class="nn-mail-dlgb" role="dialog" aria-modal="true"><h3>' + esc(title) + '</h3>' + html +
      '<div class="nn-mail-dlgf"><button type="button" class="nn-mail-send" data-d="ok">' + esc(okText) + '</button>' +
      '<button type="button" data-d="cancel">إلغاء</button></div></div>');
    root.appendChild(d);
    d.addEventListener('click', function (e) {
      var b = e.target.closest('[data-d]');
      if (e.target === d || (b && b.dataset.d === 'cancel')) d.remove();
      else if (b && b.dataset.d === 'ok') onOk(d).then(function () { d.remove(); });
    });
    var f = d.querySelector('input,textarea'); if (f) f.focus();
    return d;
  }

  function referDialog(m) {
    var c = { doc: { to: [] }, dirty: false };
    var d = dialog('إحالة المراسلة', '<div class="nn-mail-dlg-r"></div><label>التعليمة <select class="nn-mail-ins">' +
      opts((S.meta.instr || []).map(function (i) { return [i.c, i.n]; }), 'ACTION') + '</select></label>' +
      '<label>المهلة <input type="date" class="nn-mail-due"></label><label>ملاحظة الإحالة<textarea class="nn-mail-note" rows="3"></textarea></label>',
      'إحالة', function (dd) {
        if (!c.doc.to.length) { toast('اختر الشخص المحال إليه', true); return $.Deferred().reject().promise(); }
        return call('REFER', [m.id, c.doc.to[0].id, dd.querySelector('.nn-mail-ins').value, dd.querySelector('.nn-mail-due').value,
          dd.querySelector('.nn-mail-note').value]).then(function () { toast('تمت الإحالة إلى ' + c.doc.to[0].n); openThread(m.id); });
      });
    var f = recipientsField(c, 'to', 'إلى'); d.querySelector('.nn-mail-dlg-r').appendChild(f);
    var orig = c.doc.to.push.bind(c.doc.to);
    c.doc.to.push = function (x) { c.doc.to.length = 0; return orig(x); };
    f.querySelector('input').focus();
  }

  // ------------------------------------------------------------ الأحداث
  function refreshSoft() { loadCounts(); if (S.view === 'list') loadList(true); else if (S.thread) openThread(S.thread.tid); }

  root.addEventListener('click', function (e) {
    var a = e.target.closest('[data-a],[data-f],.nn-mail-compose,.nn-mail-row');
    if (!a || e.target.closest('.nn-mail-cw,.nn-mail-dlg')) return;
    if (a.classList.contains('nn-mail-compose')) { compose(); return; }
    if (a.dataset.f) { e.preventDefault(); S.folder = a.dataset.f; S.q = ''; search.value = ''; renderFolders(); loadList(); return; }
    var act = a.dataset.a, row = e.target.closest('.nn-mail-row'), r = row ? S.rows[+row.dataset.i] : null;
    var msgEl = e.target.closest('.nn-mail-msg'), m = msgEl && S.thread ? S.thread.msgs[+msgEl.dataset.m] : null;
    if (!act && r) {
      if (r.draft === 'Y') call('DRAFT', [r.id]).then(function (d) { compose(d); });
      else openThread(r.id);
      return;
    }
    e.preventDefault();
    var id = r ? r.id : (m ? m.id : (S.thread ? S.thread.tid : null));
    switch (act) {
      case 'refresh': refreshSoft(); break;
      case 'prev': S.off = Math.max(0, S.off - 50); loadList(true); break;
      case 'next': S.off += 50; loadList(true); break;
      case 'back': loadList(true); break;
      case 'star': call('STAR', [r.id, r.st === 'Y' ? 'N' : 'Y']).then(function () { r.st = r.st === 'Y' ? 'N' : 'Y'; renderList(); }); break;
      case 'tstar': call('STAR', [id, S.thread.star === 'Y' ? 'N' : 'Y']).then(function () { S.thread.star = S.thread.star === 'Y' ? 'N' : 'Y'; renderThread(); }); break;
      case 'archive': call('ARCHIVE', [id]).then(function () { toast('نُقلت إلى الأرشيف'); loadCounts(); loadList(true); }); break;
      case 'restore': call('RESTORE', [id]).then(function () { toast('نُقلت إلى الوارد'); loadCounts(); loadList(true); }); break;
      case 'unread': call('UNREAD', [id]).then(function () { loadCounts(); loadList(true); }); break;
      case 'print': callText('LETTER', [S.thread.msgs[S.thread.msgs.length - 1].id]).then(function (html) {
        var wdw = window.open('', '_blank'); if (wdw) { wdw.document.open(); wdw.document.write(html); wdw.document.close(); }
      }); break;
      case 'toggle': msgEl.classList.toggle('is-open'); break;
      case 'ack': call('ACK', [m.id]).then(function () { toast('سُجل اطلاعك'); openThread(m.id); }); break;
      case 'done': dialog('تم الإنجاز', '<label>ما الذي تم؟ (اختياري)<textarea class="nn-mail-note" rows="3"></textarea></label>', 'تأكيد الإنجاز',
        function (dd) { return call('DONE', [m.id, dd.querySelector('.nn-mail-note').value]).then(function () { toast('سُجل الإنجاز'); openThread(m.id); }); });
        break;
      case 'refer': referDialog(m); break;
      case 'reply': replyTo(m, false); break;
      case 'replyall': replyTo(m, true); break;
      case 'forward': compose({ subject: /^تحويل:/.test(S.thread.subject) ? S.thread.subject : 'تحويل: ' + S.thread.subject,
        body: quoteOf(m), parent: m.id, rel: 'FORWARD' }); break;
    }
  });
  root.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && e.target.classList.contains('nn-mail-row')) e.target.click();
  });
  var st;
  search.addEventListener('input', function () {
    clearTimeout(st);
    st = setTimeout(function () { S.q = search.value.trim(); if (S.folder === 'DRAFTS' && S.q) S.folder = 'INBOX'; loadList(); }, 350);
  });

  // ------------------------------------------------------------ البدء
  call('META').then(function (m) {
    S.meta = m; renderFolders(); loadCounts();
    var open = root.dataset.open;
    if (open) openThread(open); else loadList();
  });
  // رسائل جديدة كل دقيقة
  setInterval(function () { if (!document.hidden) loadCounts().then(function () { if (S.view === 'list' && S.folder === 'INBOX' && !S.q && !S.off) loadList(true); }); }, 60000);
})();
