/* NOONA PLUS | المطاعم والكافتريا - تطبيق المبيعات ونقاط البيع 133
   شاشة الصالة والطلب (pos)، شاشة المطبخ (kitchen)، العملاء الآجلون والتحصيل (credit).
   البيانات من NOONA_RST_PKG عبر عملية AJAX واحدة (RST) والعملية في x01. */
(function () {
  'use strict';
  var root = document.getElementById('nnRst');
  if (!root || root.dataset.ready) return;
  root.dataset.ready = '1';
  var MODE = root.dataset.mode || 'pos';
  var TERM = root.dataset.term;
  var BOOT = null;
  var bootEl = document.getElementById('nnRstBoot');
  if (bootEl) { try { BOOT = JSON.parse(bootEl.textContent); } catch (e) { BOOT = null; } }

  var K = { NEW: ['جديد', 'fa-pencil'], SENT: ['في المطبخ', 'fa-fire'], READY: ['جاهز', 'fa-bell'], SERVED: ['قدم', 'fa-check'], VOID: ['ملغى', 'fa-ban'] };
  var S = { view: 'floor', area: null, floor: null, order: null, cat: null, q: '', note: '', timer: null };

  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  function icon(n) { return '<span class="fa ' + n + '" aria-hidden="true"></span>'; }
  function money(v) { return Number(v || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }
  function qty(v) { return String(Math.round(Number(v || 0) * 1000) / 1000); }
  function uuid() {
    if (window.crypto && crypto.randomUUID) return crypto.randomUUID();
    return 'r' + Date.now().toString(36) + Math.random().toString(36).slice(2, 12);
  }
  function call(op, args, clob) {
    var d = { x01: op };
    (args || []).forEach(function (v, i) { d['x0' + (i + 2)] = v == null ? '' : String(v); });
    if (clob != null) d.p_clob_01 = typeof clob === 'string' ? clob : JSON.stringify(clob);
    return apex.server.process('RST', d).then(function (r) {
      if (r && r.err) { toast(r.err, true); throw new Error(r.err); }
      return r;
    }, function (x) { toast('تعذر الاتصال بالخادم؛ أعد المحاولة', true); throw x; });
  }
  var toastEl = document.createElement('div');
  toastEl.className = 'nn-fd-toast';
  toastEl.setAttribute('role', 'status');
  toastEl.setAttribute('aria-live', 'polite');
  document.body.appendChild(toastEl);
  var tt;
  function toast(msg, err) {
    toastEl.textContent = msg; toastEl.classList.toggle('is-err', !!err); toastEl.classList.add('is-on');
    clearTimeout(tt); tt = setTimeout(function () { toastEl.classList.remove('is-on'); }, err ? 6000 : 2500);
  }

  // ------------------------------------------------------------ نافذة منبثقة (خارج نموذج الصفحة)
  var dlg = document.createElement('div');
  dlg.className = 'nn-rst-dlg';
  dlg.innerHTML = '<div class="nn-rst-dlg-box" role="dialog" aria-modal="true"><button type="button" class="nn-rst-x" data-close title="إغلاق">'
    + icon('fa-times') + '</button><div class="nn-rst-dlg-body"></div></div>';
  document.body.appendChild(dlg);
  var dlgBody = dlg.querySelector('.nn-rst-dlg-body');
  function show(html) { dlgBody.innerHTML = html; dlg.classList.add('is-open'); var f = dlgBody.querySelector('input,select,button'); if (f) f.focus(); }
  function hide() { dlg.classList.remove('is-open'); dlgBody.innerHTML = ''; }
  dlg.addEventListener('click', function (e) { if (e.target === dlg || e.target.closest('[data-close]')) hide(); });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && dlg.classList.contains('is-open')) hide(); });

  var printFrame = document.createElement('iframe');
  printFrame.className = 'nn-pos-print';
  printFrame.setAttribute('aria-hidden', 'true');
  document.body.appendChild(printFrame);
  function printReceipt(id) {
    printFrame.removeAttribute('srcdoc');
    printFrame.src = 'f?p=' + apex.env.APP_ID + ':33:' + apex.env.APP_SESSION + '::NO:RP,33:P33_ID,P33_AUTO:' + id + ',Y';
  }
  function printHtml(html) {
    var css = Array.prototype.map.call(document.querySelectorAll('link[rel="stylesheet"]'), function (l) {
      return l.href.indexOf('noona') >= 0 ? '<link rel="stylesheet" href="' + esc(l.href) + '">' : '';
    }).join('');
    printFrame.removeAttribute('src');
    printFrame.srcdoc = '<!doctype html><html dir="rtl" lang="ar"><head><meta charset="utf-8">' + css
      + '<style>@page{margin:0}body{margin:0;font-family:Cairo,Tahoma,sans-serif}</style></head><body>' + html
      + '<script>setTimeout(function(){window.print();},400);<\/script></body></html>';
  }

  // ================================================================ الصالة والطلب
  function startPos() {
    if (!BOOT) { root.innerHTML = '<div class="nn-empty">تعذر تحميل بيانات نقطة البيع</div>'; return; }
    var items = BOOT.items || [];
    var byId = {};
    items.forEach(function (i) { byId[i.id] = i; });
    var methods = (BOOT.methods || []).filter(function (m) { return m.c; });
    S.area = BOOT.areas && BOOT.areas.length ? BOOT.areas[0].id : null;

    root.innerHTML =
      '<div class="nn-rst-top"><div class="nn-rst-tabs"><button type="button" data-view="floor" class="is-on">' + icon('fa-th-large')
      + ' الصالة</button><button type="button" data-view="list">' + icon('fa-shopping-bag') + ' سفري وتوصيل <b class="nn-rst-cnt"></b></button></div>'
      + '<div class="nn-rst-new"><button type="button" class="t-Button t-Button--hot" data-new="TAKEAWAY">' + icon('fa-plus') + ' طلب سفري</button>'
      + '<button type="button" class="t-Button" data-new="DELIVERY">' + icon('fa-motorcycle') + ' توصيل</button>'
      + '<button type="button" class="t-Button" data-new="CREDIT">' + icon('fa-user') + ' طلب لعميل (آجل)</button></div>'
      + '<span class="nn-rst-shift"></span><button type="button" class="nn-fd-ib" data-a="refresh" title="تحديث">' + icon('fa-refresh') + '</button></div>'
      + '<div class="nn-rst-main"></div>';
    var main = root.querySelector('.nn-rst-main');

    function setShift(id) {
      root.querySelector('.nn-rst-shift').innerHTML = id ? icon('fa-unlock') + ' وردية ' + id + ' · ' + esc(BOOT.user || '')
        : icon('fa-lock') + ' لا توجد وردية مفتوحة (تفتح تلقائياً مع أول سداد)';
    }
    setShift(BOOT.shift);

    function loadFloor() {
      return call('FLOOR', [TERM]).then(function (r) {
        S.floor = r;
        setShift(r.shift);
        var n = (r.orders || []).filter(function (o) { return !o.table; }).length;
        root.querySelector('.nn-rst-cnt').textContent = n ? n : '';
        if (S.view === 'floor' || S.view === 'list') drawFloor();
      });
    }
    function tick() {
      clearInterval(S.timer);
      S.timer = setInterval(function () { if ((S.view === 'floor' || S.view === 'list') && !dlg.classList.contains('is-open')) loadFloor(); }, 20000);
    }

    function drawFloor() {
      var f = S.floor || { tables: [], orders: [] };
      root.querySelectorAll('[data-view]').forEach(function (b) { b.classList.toggle('is-on', b.dataset.view === S.view); });
      if (S.view === 'list') {
        var list = (f.orders || []).filter(function (o) { return !o.table; });
        main.innerHTML = '<div class="nn-rst-olist">' + (list.length ? list.map(function (o) {
          return '<button type="button" class="nn-rst-ocard is-' + o.st.toLowerCase() + '" data-order="' + o.id + '"><b>' + esc(o.no) + '</b><span class="nn-rst-chip">'
            + esc(o.tl) + '</span><span>' + esc(o.name || '') + (o.phone ? ' · ' + esc(o.phone) : '') + '</span><span class="nn-rst-amt">' + money(o.total)
            + '</span><small>' + icon('fa-clock-o') + ' ' + o.min + ' د</small></button>';
        }).join('') : '<p class="nn-hint">لا توجد طلبات سفري أو توصيل مفتوحة</p>') + '</div>';
        return;
      }
      var areas = BOOT.areas || [];
      var tabs = areas.length > 1 ? '<div class="nn-rst-areas">' + areas.map(function (a) {
        return '<button type="button" data-area="' + a.id + '" class="' + (a.id === S.area ? 'is-on' : '') + '">' + esc(a.n) + '</button>';
      }).join('') + '</div>' : '';
      var tbls = (f.tables || []).filter(function (t) { return !S.area || t.area === S.area || areas.length < 2; });
      var cnt = { FREE: 0, OPEN: 0, BILLED: 0 };
      tbls.forEach(function (t) { cnt[t.state]++; });
      main.innerHTML = tabs + '<div class="nn-rst-legend"><span class="is-free">متاحة ' + cnt.FREE + '</span><span class="is-open">مشغولة ' + cnt.OPEN
        + '</span><span class="is-billed">طبع الحساب ' + cnt.BILLED + '</span></div><div class="nn-rst-floor">' + tbls.map(function (t) {
          return '<button type="button" class="nn-rst-table is-' + t.state.toLowerCase() + ' sh-' + (t.shape || 'SQUARE').toLowerCase() + '" data-table="' + t.id + '">'
            + '<b>' + esc(t.code) + '</b><small>' + t.seats + ' ' + icon('fa-user') + '</small>'
            + (t.state !== 'FREE' ? '<span class="nn-rst-amt">' + money(t.total) + '</span><small>' + icon('fa-clock-o') + ' ' + (t.min || 0) + ' د'
              + (t.orders > 1 ? ' · ' + t.orders + ' حسابات' : '') + '</small>' : '<span class="nn-rst-free">متاحة</span>')
            + (t.ready ? '<i class="nn-rst-bell" title="أصناف جاهزة للتقديم">' + icon('fa-bell') + '</i>' : '') + '</button>';
        }).join('') + (tbls.length ? '' : '<p class="nn-hint">لا توجد طاولات؛ أضفها من «إعداد المطعم»</p>') + '</div>';
    }

    function openTable(id) {
      var t = (S.floor.tables || []).filter(function (x) { return String(x.id) === String(id); })[0];
      if (t && t.state !== 'FREE') { loadOrder(t.first); return; }
      show('<h3>' + icon('fa-cutlery') + ' فتح طاولة ' + esc(t ? t.code : '') + '</h3><label>عدد الأشخاص<input type="number" min="1" name="guests" value="'
        + (t ? Math.min(2, t.seats) : 2) + '" class="nn-rst-in"></label><label>النادل<input name="waiter" class="nn-rst-in" value="' + esc(BOOT.user || '')
        + '"></label><div class="nn-rst-acts"><button type="button" class="t-Button t-Button--hot" data-go>فتح الطلب</button></div>');
      dlgBody.querySelector('[data-go]').onclick = function () {
        var doc = { table: Number(id), guests: Number(dlgBody.querySelector('[name=guests]').value || 0) || null,
                    waiter: dlgBody.querySelector('[name=waiter]').value };
        call('OPEN', [], doc).then(function (r) { hide(); loadOrder(r.id); });
      };
    }

    function newOrder(kind) {
      if (kind === 'TAKEAWAY') {
        call('OPEN', [], { type: 'TAKEAWAY', terminal: Number(TERM) }).then(function (r) { loadOrder(r.id); });
        return;
      }
      if (kind === 'CREDIT') {
        pickCustomer(function (c) {
          call('OPEN', [], { type: 'TAKEAWAY', terminal: Number(TERM), cust: c.id, name: c.n }).then(function (r) { loadOrder(r.id); });
        });
        return;
      }
      show('<h3>' + icon('fa-motorcycle') + ' طلب توصيل</h3><label>اسم العميل<input name="name" class="nn-rst-in"></label>'
        + '<label>الجوال<input name="phone" class="nn-rst-in" inputmode="tel"></label><label>العنوان<textarea name="addr" class="nn-rst-in" rows="2"></textarea></label>'
        + '<div class="nn-rst-acts"><button type="button" class="t-Button t-Button--hot" data-go>فتح الطلب</button></div>');
      dlgBody.querySelector('[data-go]').onclick = function () {
        var g = function (n) { return dlgBody.querySelector('[name=' + n + ']').value; };
        call('OPEN', [], { type: 'DELIVERY', terminal: Number(TERM), name: g('name'), phone: g('phone'), addr: g('addr') })
          .then(function (r) { hide(); loadOrder(r.id); });
      };
    }

    // ------------------------------------------------------------ شاشة الطلب
    function loadOrder(id) {
      return call('ORDER', [id]).then(function (o) { S.order = o; S.view = 'order'; drawOrder(); });
    }
    function setOrder(o) { S.order = o; drawOrder(); }

    function drawOrder() {
      var o = S.order;
      root.querySelectorAll('[data-view]').forEach(function (b) { b.classList.remove('is-on'); });
      var cats = BOOT.cats || [];
      main.innerHTML = '<div class="nn-rst-order"><section class="nn-rst-menu"><div class="nn-rst-msearch">' + icon('fa-search')
        + '<input type="search" placeholder="ابحث في القائمة" aria-label="بحث في القائمة" value="' + esc(S.q) + '"></div>'
        + '<div class="nn-rst-cats"><button type="button" data-cat="" class="' + (!S.cat ? 'is-on' : '') + '">الكل</button>' + cats.map(function (c) {
          return '<button type="button" data-cat="' + c.id + '" class="' + (String(S.cat) === String(c.id) ? 'is-on' : '') + '">' + esc(c.n) + '</button>';
        }).join('') + '</div><div class="nn-rst-note"><input placeholder="ملاحظة للصنف التالي (بدون بصل، حار...)" value="' + esc(S.note) + '"></div>'
        + '<div class="nn-rst-items"></div></section><section class="nn-rst-ticket"></section></div>';
      drawItems();
      drawTicket();
      main.querySelector('.nn-rst-msearch input').addEventListener('input', function (e) { S.q = e.target.value.trim().toLowerCase(); drawItems(); });
      main.querySelector('.nn-rst-note input').addEventListener('input', function (e) { S.note = e.target.value; });
    }
    function drawItems() {
      var box = main.querySelector('.nn-rst-items');
      var list = items.filter(function (i) {
        return (!S.cat || String(i.c) === String(S.cat)) && (!S.q || (i.n + ' ' + (i.no || '')).toLowerCase().indexOf(S.q) >= 0);
      });
      box.innerHTML = list.length ? list.map(function (i) {
        return '<button type="button" class="nn-rst-item" data-item="' + i.id + '"><span>' + esc(i.n) + '</span><b>' + money(i.p) + '</b></button>';
      }).join('') : '<p class="nn-hint">لا توجد أصناف</p>';
    }
    function drawTicket() {
      var o = S.order;
      var box = main.querySelector('.nn-rst-ticket');
      var editable = o.st === 'OPEN' || o.st === 'BILLED';
      var lines = (o.lines || []);
      var hasNew = lines.some(function (l) { return l.k === 'NEW'; });
      var sib = o.siblings || [];
      box.innerHTML = '<div class="nn-rst-th"><button type="button" class="nn-fd-ib" data-a="back" title="رجوع للصالة">' + icon('fa-arrow-right') + '</button>'
        + '<div><b>' + esc(o.no) + '</b> <span class="nn-rst-chip">' + esc(o.tl) + (o.tcode ? ' · ' + esc(o.tcode) : '') + '</span> <span class="nn-rst-chip is-'
        + o.st.toLowerCase() + '">' + esc(o.sl) + '</span><br><small>' + esc(o.at) + (o.guests ? ' · ' + o.guests + ' أشخاص' : '') + ' · ' + esc(o.waiter || '')
        + (o.name ? ' · ' + icon('fa-user') + ' ' + esc(o.name) : '') + (o.phone ? ' · ' + esc(o.phone) : '') + '</small></div></div>'
        + (sib.length ? '<div class="nn-rst-sib">حسابات أخرى على الطاولة: ' + sib.map(function (s) {
          return '<button type="button" data-order="' + s.id + '">' + esc(s.no) + ' (' + money(s.total) + ')</button>';
        }).join('') + '</div>' : '')
        + '<div class="nn-rst-lines">' + (lines.length ? lines.map(function (l) {
          var k = K[l.k] || [l.k, ''];
          return '<div class="nn-rst-line k-' + l.k.toLowerCase() + '"><div class="nn-rst-ln"><b>' + esc(l.n) + '</b>' + (l.nt ? '<small>' + esc(l.nt) + '</small>' : '')
            + '<small class="nn-rst-k">' + icon(k[1]) + ' ' + k[0] + (l.r ? ' · دفعة ' + l.r : '') + '</small></div>'
            + (l.k === 'NEW' && editable ? '<div class="nn-rst-qty"><button type="button" data-q="' + l.id + '" data-v="' + (Number(l.q) - 1) + '" aria-label="إنقاص">−</button><span>'
              + qty(l.q) + '</span><button type="button" data-q="' + l.id + '" data-v="' + (Number(l.q) + 1) + '" aria-label="زيادة">+</button></div>'
              : '<div class="nn-rst-qty"><span>' + qty(l.q) + '</span></div>')
            + '<span class="nn-rst-lt">' + money(l.t) + '</span>'
            + (editable && l.k !== 'VOID' ? '<button type="button" class="nn-rst-void" data-void="' + l.id + '" data-k="' + l.k + '" title="إلغاء الصنف">' + icon('fa-trash-o') + '</button>' : '<span></span>')
            + '</div>';
        }).join('') : '<p class="nn-hint">اختر الأصناف من القائمة</p>') + '</div>'
        + '<div class="nn-rst-tot">' + (o.disc ? '<div><span>خصم ' + o.disc + '%</span><span></span></div>' : '')
        + '<div><span>منها الضريبة</span><span>' + money(o.tax) + '</span></div><div class="g"><span>الإجمالي</span><span>' + money(o.total) + '</span></div></div>'
        + (editable ? '<div class="nn-rst-acts nn-rst-main-acts">'
          + '<button type="button" class="t-Button" data-a="send"' + (hasNew ? '' : ' disabled') + '>' + icon('fa-fire') + ' إرسال للمطبخ</button>'
          + '<button type="button" class="t-Button" data-a="bill">' + icon('fa-print') + ' الحساب</button>'
          + '<button type="button" class="t-Button t-Button--hot nn-rst-pay" data-a="pay">' + icon('fa-money') + ' دفع</button></div>'
          + '<div class="nn-rst-more"><button type="button" data-a="guests">' + icon('fa-users') + ' الأشخاص</button>'
          + '<button type="button" data-a="cust">' + icon('fa-user') + ' العميل</button>'
          + '<button type="button" data-a="split">' + icon('fa-columns') + ' تقسيم</button>'
          + '<button type="button" data-a="move">' + icon('fa-exchange') + ' نقل</button>'
          + '<button type="button" data-a="merge">' + icon('fa-compress') + ' دمج</button>'
          + '<button type="button" data-a="cancel" class="is-danger">' + icon('fa-ban') + ' إلغاء الطلب</button></div>'
          : '<div class="nn-rst-acts">' + (o.sale ? '<button type="button" class="t-Button" data-a="reprint">' + icon('fa-print') + ' إعادة طباعة الإيصال</button>' : '')
          + '<button type="button" class="t-Button" data-a="back">رجوع للصالة</button></div>');
    }

    function addItem(id) {
      var o = S.order;
      if (!(o.st === 'OPEN' || o.st === 'BILLED')) return;
      var note = S.note.trim();
      call('ADD', [o.id], [{ i: Number(id), q: 1, n: note || null }]).then(function (r) {
        S.note = ''; var ni = main.querySelector('.nn-rst-note input'); if (ni) ni.value = '';
        S.order = r; drawTicket();
      });
    }

    function backToFloor() {
      S.view = S.order && S.order.table ? 'floor' : (S.order && S.order.st !== 'OPEN' && S.order.st !== 'BILLED' ? S.view : 'list');
      if (S.order && S.order.table) S.view = 'floor';
      if (S.view === 'order') S.view = 'floor';
      S.order = null;
      loadFloor();
    }

    // ------------------------------------------------------------ العميل
    function pickCustomer(cb) {
      show('<h3>' + icon('fa-user') + ' العميل الآجل</h3><input class="nn-rst-in" data-cs placeholder="ابحث بالاسم أو الجوال أو رقم العميل">'
        + '<div class="nn-rst-clist"></div><details class="nn-rst-newc"><summary>' + icon('fa-plus') + ' عميل جديد</summary>'
        + '<label>الاسم<input class="nn-rst-in" name="cn"></label><label>الجوال<input class="nn-rst-in" name="cp" inputmode="tel"></label>'
        + '<label>حد الائتمان (اختياري)<input class="nn-rst-in" name="cl" type="number" min="0"></label>'
        + '<button type="button" class="t-Button t-Button--hot" data-addc>إضافة واختيار</button></details>');
      var listEl = dlgBody.querySelector('.nn-rst-clist');
      var q = dlgBody.querySelector('[data-cs]');
      var t;
      function load() {
        call('CUSTS', [q.value.trim()]).then(function (r) {
          var l = r.list || [];
          listEl.innerHTML = l.length ? l.slice(0, 40).map(function (c) {
            return '<button type="button" class="nn-rst-crow" data-c="' + c.id + '"><b>' + esc(c.n) + '</b><span>' + esc(c.ph || '') + ' · ' + esc(c.no)
              + '</span><span class="' + (c.bal > 0 ? 'nn-neg' : '') + '">الرصيد ' + money(c.bal) + (c.lim != null ? ' / الحد ' + money(c.lim) : '') + '</span></button>';
          }).join('') : '<p class="nn-hint">لا يوجد عملاء مطابقون؛ أضف عميلاً جديداً</p>';
          listEl.querySelectorAll('[data-c]').forEach(function (b) {
            b.onclick = function () { var c = l.filter(function (x) { return String(x.id) === b.dataset.c; })[0]; hide(); cb(c); };
          });
        });
      }
      q.addEventListener('input', function () { clearTimeout(t); t = setTimeout(load, 300); });
      dlgBody.querySelector('[data-addc]').onclick = function () {
        var n = dlgBody.querySelector('[name=cn]').value.trim(), p = dlgBody.querySelector('[name=cp]').value.trim(),
            lim = dlgBody.querySelector('[name=cl]').value;
        if (!n) { toast('أدخل اسم العميل', true); return; }
        call('NEWCUST', [n, p, lim]).then(function (r) { hide(); cb({ id: r.id, n: n, bal: 0 }); });
      };
      load();
    }

    // ------------------------------------------------------------ الدفع
    function openPay() {
      var o = S.order;
      var sib = o.siblings || [];
      var st = { scope: sib.length ? 'table' : 'order', disc: o.disc || 0, cust: o.cust ? { id: o.cust, n: o.name } : null, pays: [], due: 0 };
      function ids() { return st.scope === 'table' ? [o.id].concat(sib.map(function (s) { return s.id; })) : [o.id]; }
      function refreshDue() {
        return call('DUE', [ids().join(',')]).then(function (r) { st.due = Number(r.due || 0); draw(); });
      }
      function paid() { return st.pays.reduce(function (a, p) { return a + Number(p.a || 0); }, 0); }
      function draw() {
        var rest = Math.round((st.due - paid()) * 100) / 100;
        dlgBody.innerHTML = '<h3>' + icon('fa-money') + ' الدفع · ' + esc(o.no) + (o.tcode ? ' · طاولة ' + esc(o.tcode) : '') + '</h3>'
          + (sib.length ? '<div class="nn-rst-seg"><button type="button" data-scope="table" class="' + (st.scope === 'table' ? 'is-on' : '') + '">حساب الطاولة كاملة ('
            + (sib.length + 1) + ' حسابات)</button><button type="button" data-scope="order" class="' + (st.scope === 'order' ? 'is-on' : '') + '">هذا الحساب فقط</button></div>' : '')
          + '<div class="nn-rst-due"><span>المطلوب</span><b>' + money(st.due) + '</b></div>'
          + '<label class="nn-rst-dl">خصم %<input type="number" min="0" max="100" step="1" class="nn-rst-in" data-disc value="' + (st.disc || '') + '"></label>'
          + '<div class="nn-rst-methods">' + methods.map(function (m) {
            return '<button type="button" data-m="' + esc(m.c) + '" class="' + (m.t === 'CREDIT' ? 'is-credit' : '') + '">' + (m.i ? icon(m.i) + ' ' : '') + esc(m.n) + '</button>';
          }).join('') + '</div>'
          + '<div class="nn-rst-pays">' + st.pays.map(function (p, k) {
            return '<div class="nn-rst-prow"><span>' + esc(p.n) + '</span><input type="number" step="0.01" min="0" class="nn-rst-in" data-pa="' + k + '" value="' + p.a + '">'
              + (p.t !== 'CASH' && p.t !== 'CREDIT' ? '<input class="nn-rst-in" placeholder="رقم العملية" data-pr="' + k + '" value="' + esc(p.ref || '') + '">' : '<span></span>')
              + '<button type="button" class="nn-rst-void" data-pdel="' + k + '" title="حذف">' + icon('fa-times') + '</button></div>';
          }).join('') + '</div>'
          + (st.pays.some(function (p) { return p.t === 'CREDIT'; }) ? '<div class="nn-rst-cust">' + icon('fa-user') + ' العميل الآجل: <b>'
            + (st.cust ? esc(st.cust.n) : 'لم يحدد') + '</b> <button type="button" class="t-Button t-Button--small" data-pc>اختيار العميل</button></div>' : '')
          + '<div class="nn-rst-due ' + (rest > 0 ? 'is-rest' : 'is-change') + '"><span>' + (rest > 0 ? 'المتبقي' : 'الباقي للعميل') + '</span><b>' + money(Math.abs(rest)) + '</b></div>'
          + '<div class="nn-rst-acts"><button type="button" class="t-Button t-Button--hot t-Button--large" data-ok' + (rest > 0 ? ' disabled' : '') + '>'
          + icon('fa-check') + ' تأكيد السداد وطباعة الفاتورة</button></div>';
        bind();
      }
      function bind() {
        dlgBody.querySelectorAll('[data-scope]').forEach(function (b) { b.onclick = function () { st.scope = b.dataset.scope; refreshDue(); }; });
        var di = dlgBody.querySelector('[data-disc]');
        di.onchange = function () {
          var v = Number(di.value || 0);
          Promise.all(ids().map(function (id) { return call('UPD', [], { id: id, disc: v }); })).then(function () { st.disc = v; st.pays = []; refreshDue(); });
        };
        dlgBody.querySelectorAll('[data-m]').forEach(function (b) {
          b.onclick = function () {
            var m = methods.filter(function (x) { return x.c === b.dataset.m; })[0];
            var rest = Math.max(0, Math.round((st.due - paid()) * 100) / 100);
            if (!rest && m.t !== 'CASH') return;
            st.pays.push({ m: m.c, n: m.n, t: m.t, a: rest });
            if (m.t === 'CREDIT' && !st.cust) { pickCustomer(function (c) { st.cust = c; show(''); draw(); }); return; }
            draw();
          };
        });
        dlgBody.querySelectorAll('[data-pa]').forEach(function (i) { i.onchange = function () { st.pays[+i.dataset.pa].a = Number(i.value || 0); draw(); }; });
        dlgBody.querySelectorAll('[data-pr]').forEach(function (i) { i.oninput = function () { st.pays[+i.dataset.pr].ref = i.value; }; });
        dlgBody.querySelectorAll('[data-pdel]').forEach(function (b) { b.onclick = function () { st.pays.splice(+b.dataset.pdel, 1); draw(); }; });
        var pc = dlgBody.querySelector('[data-pc]');
        if (pc) pc.onclick = function () { pickCustomer(function (c) { st.cust = c; show(''); draw(); }); };
        dlgBody.querySelector('[data-ok]').onclick = function (e) {
          var btn = e.currentTarget;
          btn.disabled = true;
          var doc = { key: st.key || (st.key = uuid()), pays: st.pays.map(function (p) { return { m: p.m, a: Number(p.a), ref: p.ref || null }; }) };
          if (st.scope === 'table' && o.table) doc.table = o.table; else doc.orders = ids();
          if (st.cust) doc.cust = st.cust.id;
          call('SETTLE', [], doc).then(function (r) {
            hide();
            toast('تم السداد · إيصال ' + r.no + (Number(r.change) > 0 ? ' · الباقي ' + money(r.change) : ''));
            printReceipt(r.id);
            S.order = null; S.view = o.table ? 'floor' : 'list';
            loadFloor();
          }, function () { btn.disabled = false; });
        };
      }
      show('<p class="nn-hint">جاري احتساب المطلوب...</p>');
      refreshDue();
    }

    // ------------------------------------------------------------ تقسيم ونقل ودمج
    function openSplit() {
      var o = S.order;
      var lines = (o.lines || []).filter(function (l) { return l.k !== 'VOID'; });
      show('<h3>' + icon('fa-columns') + ' تقسيم الحساب</h3><p class="nn-hint">حدد الكميات التي تنتقل إلى حساب مستقل على نفس الطاولة</p>'
        + '<div class="nn-rst-split">' + lines.map(function (l) {
          return '<label><span>' + esc(l.n) + ' <small>(' + qty(l.q) + ')</small></span><input type="number" min="0" max="' + l.q + '" step="1" value="0" class="nn-rst-in" data-l="'
            + l.id + '"></label>';
        }).join('') + '</div><div class="nn-rst-acts"><button type="button" class="t-Button t-Button--hot" data-go>إنشاء الحساب المستقل</button></div>');
      dlgBody.querySelector('[data-go]').onclick = function () {
        var sel = Array.prototype.map.call(dlgBody.querySelectorAll('[data-l]'), function (i) { return { l: Number(i.dataset.l), q: Number(i.value || 0) }; })
          .filter(function (x) { return x.q > 0; });
        if (!sel.length) { toast('حدد كمية صنف واحد على الأقل', true); return; }
        call('SPLIT', [o.id], sel).then(function (r) { hide(); toast('تم إنشاء حساب مستقل'); loadOrder(r.id); });
      };
    }
    function pickTable(title, cb, busyOnly) {
      call('FLOOR', [TERM]).then(function (f) {
        S.floor = f;
        var t = (f.tables || []).filter(function (x) { return (!S.order || String(x.id) !== String(S.order.table)) && (!busyOnly || x.state !== 'FREE'); });
        show('<h3>' + title + '</h3><div class="nn-rst-floor is-pick">' + (t.length ? t.map(function (x) {
          return '<button type="button" class="nn-rst-table is-' + x.state.toLowerCase() + '" data-t="' + x.id + '"><b>' + esc(x.code) + '</b>'
            + (x.state !== 'FREE' ? '<span class="nn-rst-amt">' + money(x.total) + '</span>' : '<span class="nn-rst-free">متاحة</span>') + '</button>';
        }).join('') : '<p class="nn-hint">لا توجد طاولات مناسبة</p>') + '</div>');
        dlgBody.querySelectorAll('[data-t]').forEach(function (b) {
          b.onclick = function () { cb(t.filter(function (x) { return String(x.id) === b.dataset.t; })[0]); };
        });
      });
    }

    // ------------------------------------------------------------ الأحداث
    root.addEventListener('click', function (e) {
      var b;
      if ((b = e.target.closest('[data-view]'))) { S.view = b.dataset.view; S.order = null; drawFloor(); loadFloor(); return; }
      if ((b = e.target.closest('[data-area]'))) { S.area = Number(b.dataset.area); drawFloor(); return; }
      if ((b = e.target.closest('[data-table]'))) { openTable(b.dataset.table); return; }
      if ((b = e.target.closest('[data-order]'))) { loadOrder(b.dataset.order); return; }
      if ((b = e.target.closest('[data-new]'))) { newOrder(b.dataset.new); return; }
      if ((b = e.target.closest('[data-cat]'))) { S.cat = b.dataset.cat || null; main.querySelectorAll('[data-cat]').forEach(function (x) { x.classList.toggle('is-on', x === b); }); drawItems(); return; }
      if ((b = e.target.closest('[data-item]'))) { addItem(b.dataset.item); return; }
      if ((b = e.target.closest('[data-q]'))) { call('QTY', [b.dataset.q, b.dataset.v, S.order.id]).then(setOrder); return; }
      if ((b = e.target.closest('[data-void]'))) {
        if (b.dataset.k === 'NEW') { call('QTY', [b.dataset.void, 0, S.order.id]).then(setOrder); return; }
        var why = window.prompt('سبب إلغاء صنف أرسل للمطبخ');
        if (why) call('VOID', [b.dataset.void, why, S.order.id]).then(setOrder);
        return;
      }
      if (!(b = e.target.closest('[data-a]'))) return;
      var o = S.order;
      switch (b.dataset.a) {
        case 'refresh': if (S.view === 'order' && o) loadOrder(o.id); else loadFloor(); break;
        case 'back': backToFloor(); break;
        case 'send': call('SEND', [o.id]).then(function (r) { setOrder(r); toast('أرسلت الدفعة ' + r.round + ' للمطبخ'); }); break;
        case 'bill': call('BILL', [o.id, (o.siblings || []).length && window.confirm('طباعة حساب الطاولة كاملة؟') ? o.table : '']).then(function (r) {
          printHtml(r.html); loadOrder(o.id);
        }); break;
        case 'pay': openPay(); break;
        case 'reprint': printReceipt(o.sale); break;
        case 'split': openSplit(); break;
        case 'guests': var g = window.prompt('عدد الأشخاص', o.guests || ''); if (g) call('UPD', [], { id: o.id, guests: Number(g) }).then(setOrder); break;
        case 'cust': pickCustomer(function (c) { call('UPD', [], { id: o.id, cust: c.id, name: c.n }).then(setOrder); }); break;
        case 'move': pickTable(icon('fa-exchange') + ' نقل الطلب إلى طاولة', function (t) {
          call('MOVE', [o.id, t.id]).then(function (r) { hide(); toast('نقل الطلب إلى ' + t.code); setOrder(r); });
        }); break;
        case 'merge': pickTable(icon('fa-compress') + ' دمج الطلب في حساب طاولة أخرى', function (t) {
          call('MERGE', [o.id, t.first]).then(function (r) { hide(); toast('تم الدمج في حساب ' + t.code); setOrder(r); });
        }, true); break;
        case 'cancel':
          var r = window.prompt('سبب إلغاء الطلب (إلزامي إن أرسلت أصناف للمطبخ)', '');
          if (r !== null) call('CANCEL', [o.id, r]).then(function () { toast('ألغي الطلب'); backToFloor(); });
          break;
      }
    });
    loadFloor();
    tick();
  }

  // ================================================================ شاشة المطبخ
  function startKitchen() {
    root.innerHTML = '<div class="nn-rst-top"><b>' + icon('fa-fire') + ' شاشة المطبخ</b><span class="nn-rst-shift">تحديث تلقائي كل 15 ثانية</span>'
      + '<button type="button" class="nn-fd-ib" data-a="refresh" title="تحديث">' + icon('fa-refresh') + '</button></div><div class="nn-rst-kds"></div>';
    var box = root.querySelector('.nn-rst-kds');
    function load() {
      call('KITCHEN', [TERM]).then(function (r) {
        var l = r.list || [];
        box.innerHTML = l.length ? l.map(function (t) {
          var late = t.ready !== 'Y' && t.min >= 20 ? ' is-late' : (t.ready !== 'Y' && t.min >= 10 ? ' is-warn' : '');
          return '<article class="nn-rst-kt' + (t.ready === 'Y' ? ' is-ready' : '') + late + '"><header><b>' + (t.table ? 'طاولة ' + esc(t.table) : esc(t.tl))
            + '</b><span>' + esc(t.no) + ' · دفعة ' + t.r + '</span><span class="nn-rst-min">' + icon('fa-clock-o') + ' ' + t.min + ' د</span></header><ul>'
            + (t.lines || []).map(function (x) {
              return '<li class="' + (x.k === 'VOID' ? 'is-void' : '') + '"><b>' + qty(x.q) + '×</b> ' + esc(x.n) + (x.nt ? '<small>' + esc(x.nt) + '</small>' : '') + '</li>';
            }).join('') + '</ul><footer>' + (t.name ? '<small>' + esc(t.name) + '</small>' : '') + (t.ready === 'Y'
              ? '<button type="button" class="t-Button" data-served="' + t.id + '">' + icon('fa-check') + ' تم التقديم</button>'
              : '<button type="button" class="t-Button t-Button--hot" data-ready="' + t.id + '" data-r="' + t.r + '">' + icon('fa-bell') + ' جاهز</button>')
            + '</footer></article>';
        }).join('') : '<p class="nn-hint nn-rst-idle">' + icon('fa-coffee') + ' لا توجد طلبات تحت التحضير</p>';
      });
    }
    root.addEventListener('click', function (e) {
      var b;
      if ((b = e.target.closest('[data-ready]'))) call('KREADY', [b.dataset.ready, b.dataset.r]).then(load);
      else if ((b = e.target.closest('[data-served]'))) call('KSERVED', [b.dataset.served]).then(load);
      else if (e.target.closest('[data-a="refresh"]')) load();
    });
    load();
    setInterval(load, 15000);
  }

  // ================================================================ العملاء الآجلون والتحصيل
  function startCredit() {
    var methods = [['CASH', 'نقداً'], ['MADA', 'مدى / شبكة'], ['BANK_APP', 'تطبيق بنكي / تحويل']];
    root.innerHTML = '<div class="nn-rst-top"><div class="nn-fd-search">' + icon('fa-search')
      + '<input type="search" placeholder="ابحث بالاسم أو الجوال أو رقم العميل" aria-label="بحث"></div>'
      + '<button type="button" class="nn-fd-ib" data-a="refresh" title="تحديث">' + icon('fa-refresh') + '</button></div><div class="nn-rst-credit"></div>';
    var box = root.querySelector('.nn-rst-credit');
    var q = root.querySelector('input[type=search]');
    var t;
    function load() { call('CREDIT', [q.value.trim()]).then(function (r) { box.innerHTML = r.html; }); }
    q.addEventListener('input', function () { clearTimeout(t); t = setTimeout(load, 300); });
    root.addEventListener('click', function (e) {
      var b;
      if ((b = e.target.closest('[data-collect]'))) {
        var id = b.dataset.collect;
        show('<h3>' + icon('fa-money') + ' تحصيل من ' + esc(b.dataset.name) + '</h3><div class="nn-rst-due"><span>الرصيد المستحق</span><b>' + money(b.dataset.bal)
          + '</b></div><label>المبلغ<input type="number" step="0.01" min="0" class="nn-rst-in" name="amt" value="' + b.dataset.bal + '"></label>'
          + '<label>طريقة التحصيل<select class="nn-rst-in" name="m">' + methods.map(function (m) { return '<option value="' + m[0] + '">' + m[1] + '</option>'; }).join('')
          + '</select></label><label>المرجع<input class="nn-rst-in" name="ref"></label><label>ملاحظات<input class="nn-rst-in" name="notes"></label>'
          + '<div class="nn-rst-acts"><button type="button" class="t-Button t-Button--hot" data-go>' + icon('fa-check') + ' تسجيل التحصيل</button></div>');
        dlgBody.querySelector('[data-go]').onclick = function (ev) {
          var g = function (n) { return dlgBody.querySelector('[name=' + n + ']').value; };
          ev.currentTarget.disabled = true;
          call('COLLECT', [], { cust: Number(id), amount: Number(g('amt')), method: g('m'), ref: g('ref') || null, notes: g('notes') || null})
            .then(function (r) { hide(); toast('تم تسجيل سند التحصيل ' + (r.no || '')); load(); }, function () { ev.currentTarget.disabled = false; });
        };
        return;
      }
      if ((b = e.target.closest('[data-stmt]'))) {
        var to = new Date().toISOString().slice(0, 10);
        var fr = new Date(Date.now() - 90 * 864e5).toISOString().slice(0, 10);
        call('STMT', [b.dataset.stmt, fr, to]).then(function (r) {
          show('<h3>' + icon('fa-file-text-o') + ' كشف حساب العميل (آخر 90 يوماً)</h3><div class="nn-rst-stmt">' + r.html + '</div>');
        });
        return;
      }
      if (e.target.closest('[data-a="refresh"]')) load();
    });
    load();
  }

  if (MODE === 'kitchen') startKitchen();
  else if (MODE === 'credit') startCredit();
  else startPos();
})();
