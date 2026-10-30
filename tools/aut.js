/* NOONA PLUS | مراكز خدمة السيارات - التطبيق 145
   شاشة أمر الإصلاح (job): كروت الخدمات حسب الفئة، بحث القطع (الاسم/الباركود/رقم القطعة/التوافق/البدائل)، البنود والفني
   وبدء/انتهاء العمل، الحالة والفاتورة والتسليم والطباعة؛ وأزرار الحجوزات والمطالبات واللوحة في بقية الصفحات.
   البيانات من NOONA_AUT_PKG عبر عملية AJAX واحدة (AUT) والعملية في x01. */
(function () {
  'use strict';
  if (window.nnAutReady) return;
  window.nnAutReady = true;
  var JOB_PAGE = 3;

  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  function icon(n) { return '<span class="fa ' + n + '" aria-hidden="true"></span>'; }
  function money(v) { return Number(v || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }
  function qty(v) { return String(Math.round(Number(v || 0) * 1000) / 1000); }
  function jobUrl(id) {
    return 'f?p=' + apex.env.APP_ID + ':' + JOB_PAGE + ':' + apex.env.APP_SESSION + '::NO:RP,' + JOB_PAGE + ':P' + JOB_PAGE + '_ID:' + id;
  }
  function call(op, args, clob) {
    var d = { x01: op };
    (args || []).forEach(function (v, i) { d['x0' + (i + 2)] = v == null ? '' : String(v); });
    if (clob != null) d.p_clob_01 = typeof clob === 'string' ? clob : JSON.stringify(clob);
    return apex.server.process('AUT', d).then(function (r) {
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

  // ------------------------------------------------------------ نافذة منبثقة
  var dlg = document.createElement('div');
  dlg.className = 'nn-rst-dlg';
  dlg.innerHTML = '<div class="nn-rst-dlg-box" role="dialog" aria-modal="true"><button type="button" class="nn-rst-x" data-close title="إغلاق">'
    + icon('fa-times') + '</button><div class="nn-rst-dlg-body"></div></div>';
  document.body.appendChild(dlg);
  var dlgBody = dlg.querySelector('.nn-rst-dlg-body');
  var onOk = null;
  function show(title, html, okLabel, cb) {
    dlgBody.innerHTML = '<h3>' + esc(title) + '</h3><div class="nn-aut-form">' + html + '</div><div class="nn-aut-dlg-act">'
      + '<button type="button" class="t-Button t-Button--hot" data-ok>' + esc(okLabel || 'تأكيد') + '</button>'
      + '<button type="button" class="t-Button" data-close>إلغاء</button></div>';
    onOk = cb; dlg.classList.add('is-open');
    var f = dlgBody.querySelector('input,select,textarea'); if (f) f.focus();
  }
  function hide() { dlg.classList.remove('is-open'); dlgBody.innerHTML = ''; onOk = null; }
  function val(id) { var e = document.getElementById(id); return e ? e.value.trim() : ''; }
  dlg.addEventListener('click', function (e) {
    if (e.target === dlg || e.target.closest('[data-close]')) { hide(); return; }
    if (e.target.closest('[data-ok]') && onOk) {
      var b = e.target.closest('[data-ok]'); b.disabled = true;
      Promise.resolve(onOk()).then(function (keep) { if (!keep) hide(); else b.disabled = false; }, function () { b.disabled = false; });
    }
  });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && dlg.classList.contains('is-open')) hide(); });
  function field(label, input) { return '<label class="nn-aut-f"><span>' + esc(label) + '</span>' + input + '</label>'; }

  var printFrame = document.createElement('iframe');
  printFrame.className = 'nn-pos-print';
  printFrame.setAttribute('aria-hidden', 'true');
  document.body.appendChild(printFrame);
  function printHtml(html) {
    var css = Array.prototype.map.call(document.querySelectorAll('link[rel="stylesheet"]'), function (l) {
      return l.href.indexOf('noona') >= 0 ? '<link rel="stylesheet" href="' + esc(l.href) + '">' : '';
    }).join('');
    printFrame.srcdoc = '<!doctype html><html dir="rtl" lang="ar"><head><meta charset="utf-8">' + css
      + '<style>body{margin:12px;font-family:Cairo,Tahoma,sans-serif}</style></head><body>' + html
      + '<script>setTimeout(function(){window.print();},400);<\/script></body></html>';
  }

  // ------------------------------------------------------------ نقرات عامة: فتح الأمر، الحجوزات، المطالبات
  document.addEventListener('click', function (e) {
    if (dlg.contains(e.target)) return;
    var a = e.target.closest('[data-act]');
    if (a && a.closest('.nn-aut-appts')) { e.preventDefault(); apptAction(a.dataset.act, a.dataset.id); return; }
    if (a && a.closest('.nn-aut-claims')) {
      e.preventDefault();
      call('JOB', [a.dataset.id]).then(function (r) { claimDialog(a.dataset.id, r.job); });
      return;
    }
    var j = e.target.closest('[data-job]');
    if (j && !j.closest('#nnAut')) { e.preventDefault(); window.location.href = jobUrl(j.dataset.job); }
  });

  function apptAction(act, id) {
    if (act === 'CHECKIN') {
      show('استلام السيارة من الحجز', field('قراءة العداد (كم)', '<input type="number" id="nnAutOdo" min="0" class="text_field">')
        + field('الشركة المصنعة والطراز (للمركبة غير المسجلة)', '<input type="text" id="nnAutMake" class="text_field" placeholder="Toyota Camry">')
        + field('مستوى الوقود', '<select id="nnAutFuel" class="selectlist"><option value="">-</option><option value="EMPTY">فارغ</option>'
          + '<option value="QUARTER">ربع</option><option value="HALF">نصف</option><option value="THREE_QUARTERS">ثلاثة أرباع</option>'
          + '<option value="FULL">ممتلئ</option></select>'), 'فتح أمر الإصلاح', function () {
        var doc = {}; if (val('nnAutOdo')) doc.odometer = Number(val('nnAutOdo')); if (val('nnAutFuel')) doc.fuel = val('nnAutFuel');
        var mk = val('nnAutMake').split(/\s+/); if (mk[0]) { doc.make = mk[0]; if (mk.length > 1) doc.model = mk.slice(1).join(' '); }
        return call('CHECKIN', [id], doc).then(function (r) { window.location.href = jobUrl(r.id); return true; });
      });
      return;
    }
    if (act === 'CANCEL') {
      show('إلغاء الحجز', field('سبب الإلغاء', '<input type="text" id="nnAutWhy" class="text_field" maxlength="500">'), 'إلغاء الحجز', function () {
        return call('APPT', [id, 'CANCELLED', val('nnAutWhy')]).then(function () { apex.submit('REFRESH'); });
      });
      return;
    }
    call('APPT', [id, act === 'CONFIRM' ? 'CONFIRMED' : 'NO_SHOW']).then(function () { apex.submit('REFRESH'); });
  }

  var CLAIM_ST = [['NOT_SUBMITTED', 'لم تقدم'], ['SUBMITTED', 'مقدمة'], ['APPROVED', 'معتمدة'], ['PARTIALLY_APPROVED', 'معتمدة جزئياً'],
    ['REJECTED', 'مرفوضة'], ['PAID', 'مدفوعة']];
  function stOptions(cur) {
    return CLAIM_ST.map(function (s) { return '<option value="' + s[0] + '"' + (s[0] === cur ? ' selected' : '') + '>' + s[1] + '</option>'; }).join('');
  }
  function claimDialog(jobId, j, after) {
    j = j || {};
    show('تحديث المطالبة', field('رقم المطالبة', '<input type="text" id="nnAutClm" class="text_field" value="' + esc(j.claim || '') + '">')
      + field('الحالة', '<select id="nnAutCst" class="selectlist">' + stOptions(j.claimStatus) + '</select>')
      + field('المبلغ المعتمد قبل الضريبة (يترك فارغاً قبل الاعتماد)', '<input type="number" step="0.01" id="nnAutApr" class="text_field" value="'
        + (j.approved == null ? '' : j.approved) + '">'), 'حفظ', function () {
      var d = { job: Number(jobId), claimStatus: val('nnAutCst') };
      if (val('nnAutClm')) d.claim = val('nnAutClm');
      if (val('nnAutApr') !== '') d.approved = Number(val('nnAutApr'));
      return call('CLAIM', [], d).then(function (r) { toast('تم تحديث المطالبة'); if (after) after(r); else apex.submit('REFRESH'); });
    });
  }

  // ================================================================ شاشة أمر الإصلاح
  var root = document.getElementById('nnAut');
  if (!root) return;
  var BOOT = {};
  try { BOOT = JSON.parse(document.getElementById('nnAutBoot').textContent); } catch (e) { BOOT = {}; }
  var JOB = Number(root.dataset.job);
  var S = { data: null, cat: null, q: '', timer: null };
  if (BOOT.cats && BOOT.cats.length) S.cat = BOOT.cats[0].id;

  var FUEL = { EMPTY: 'فارغ', QUARTER: 'ربع', HALF: 'نصف', THREE_QUARTERS: 'ثلاثة أرباع', FULL: 'ممتلئ' };
  var LST = { PENDING: 'بالانتظار', IN_PROGRESS: 'قيد العمل', DONE: 'منجز' };

  root.innerHTML = '<div class="nn-aut-head"></div><div class="nn-aut-acts"></div><div class="nn-aut-main"><section class="nn-aut-cat"></section>'
    + '<section class="nn-aut-work"><div class="nn-aut-lines"></div><div class="nn-aut-totals"></div><div class="nn-aut-notes"></div></section></div>';
  var head = root.querySelector('.nn-aut-head'), acts = root.querySelector('.nn-aut-acts'), cat = root.querySelector('.nn-aut-cat');
  var lines = root.querySelector('.nn-aut-lines'), totals = root.querySelector('.nn-aut-totals'), notes = root.querySelector('.nn-aut-notes');

  function load(r) {
    if (r) { S.data = r; draw(); return Promise.resolve(r); }
    return call('JOB', [JOB]).then(function (x) { S.data = x; draw(); return x; });
  }
  function editable() { return S.data && S.data.job.editable === 'Y'; }

  function draw() {
    var j = S.data.job, v = S.data.vehicle || {};
    head.innerHTML = '<div class="nn-aut-plate">' + esc(v.plate) + '</div><div class="nn-aut-hv"><b>' + esc(j.no) + '</b> · '
      + esc([v.make, v.model, v.year, v.color].filter(Boolean).join(' ')) + '<br><span>' + icon('fa-user') + ' ' + esc(j.custName || '')
      + (j.phone ? ' · <span dir="ltr">' + esc(j.phone) + '</span>' : '') + '</span></div>'
      + '<div class="nn-aut-hm"><span class="nn-badge is-info">' + esc(j.statusLabel) + '</span>'
      + (j.late === 'Y' ? ' <span class="nn-badge is-danger">متأخر عن الموعد</span>' : '')
      + (j.payer === 'INSURANCE' ? ' <span class="nn-badge is-warning">' + icon('fa-shield') + ' ' + esc(j.insurerName || 'تأمين')
        + (j.claim ? ' · ' + esc(j.claim) : '') + '</span>' : j.payer === 'WARRANTY' ? ' <span class="nn-badge is-success">ضمان</span>' : '')
      + '<div class="nn-aut-times">' + icon('fa-sign-in') + ' ' + esc(j.checkin) + (j.promised ? ' · ' + icon('fa-flag-checkered') + ' ' + esc(j.promised) : '')
      + ' · ' + icon('fa-clock-o') + ' ' + j.hours + ' ساعة · ' + icon('fa-tachometer') + ' ' + (j.odoIn || '-') + ' كم'
      + (j.fuel ? ' · ' + icon('fa-tint') + ' ' + esc(FUEL[j.fuel] || j.fuel) : '') + '</div></div>';
    drawActs(j);
    drawCatalog();
    drawLines();
    drawTotals(j);
    drawNotes(j);
  }

  function btn(a, label, ic, cls) {
    return '<button type="button" class="t-Button ' + (cls || '') + '" data-a="' + a + '">' + icon(ic) + ' ' + esc(label) + '</button>';
  }
  function drawActs(j) {
    var h = '';
    if (j.status === 'OPEN' || j.status === 'IN_PROGRESS') h += btn('WAIT', 'بانتظار قطع', 'fa-pause') + btn('COMPLETE', 'اكتمل العمل', 'fa-check', 't-Button--success');
    if (j.status === 'WAITING_PARTS') h += btn('RESUME', 'استئناف العمل', 'fa-play') + btn('COMPLETE', 'اكتمل العمل', 'fa-check', 't-Button--success');
    if (j.status === 'COMPLETED') h += btn('INVOICE', 'إصدار الفاتورة', 'fa-file-text-o', 't-Button--hot') + btn('RESUME', 'إعادة فتح العمل', 'fa-undo');
    if (j.status === 'INVOICED') h += btn('DELIVER', 'تسليم السيارة للعميل', 'fa-key', 't-Button--hot');
    if (j.payer === 'INSURANCE') h += btn('CLAIM', 'المطالبة', 'fa-shield');
    h += btn('PRINT', 'طباعة أمر الإصلاح', 'fa-print');
    if (j.invoiceNo) h += '<span class="nn-badge is-success">' + icon('fa-file-text') + ' فاتورة العميل ' + esc(j.invoiceNo) + '</span>';
    if (j.insInvoiceNo) h += '<span class="nn-badge is-warning">' + icon('fa-file-text') + ' فاتورة التأمين ' + esc(j.insInvoiceNo) + '</span>';
    if (['OPEN', 'IN_PROGRESS', 'WAITING_PARTS', 'COMPLETED'].indexOf(j.status) >= 0) h += btn('CANCEL', 'إلغاء الأمر', 'fa-ban', 't-Button--danger t-Button--simple');
    acts.innerHTML = h;
  }

  // ------------------------------------------------------------ الكتالوج: كروت الخدمات وبحث القطع
  function drawCatalog() {
    if (!editable()) {
      cat.innerHTML = '<div class="nn-empty">' + icon('fa-lock') + ' الأمر ' + esc(S.data.job.statusLabel) + '؛ لا تعديل على البنود</div>';
      return;
    }
    if (cat.dataset.built) return;
    cat.dataset.built = '1';
    var cats = BOOT.cats || [];
    cat.innerHTML = '<div class="nn-aut-search"><span class="fa fa-search" aria-hidden="true"></span><input type="search" id="nnAutQ" '
      + 'placeholder="ابحث عن قطعة: جزء من الاسم، الباركود، رقم القطعة، الماركة، الطراز..." autocomplete="off" aria-label="بحث القطع">'
      + '<button type="button" class="t-Button t-Button--small" data-a="SUBLET" title="عمل خارجي أو بند حر">' + icon('fa-external-link') + ' بند خارجي</button></div>'
      + '<div class="nn-aut-results" hidden></div>'
      + '<div class="nn-aut-tabs">' + cats.map(function (c) {
        return '<button type="button" data-cat="' + c.id + '" class="' + (c.id === S.cat ? 'is-on' : '') + '">' + icon(c.icon || 'fa-wrench') + ' ' + esc(c.name) + '</button>';
      }).join('') + ((BOOT.bundles || []).length ? '<button type="button" data-cat="-1" class="' + (S.cat === -1 ? 'is-on' : '') + '">' + icon('fa-gift') + ' الباقات</button>' : '')
      + '</div><div class="nn-aut-cards"></div>';
    drawCards();
    var q = cat.querySelector('#nnAutQ');
    q.addEventListener('input', function () {
      clearTimeout(S.timer);
      S.timer = setTimeout(function () { search(q.value.trim()); }, 300);
    });
    q.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') {          // قارئ الباركود يرسل Enter: يضاف أول نتيجة مطابقة مباشرة
        e.preventDefault(); clearTimeout(S.timer);
        search(q.value.trim()).then(function (list) {
          if (list && list.length === 1) { addPart(list[0].id, 1); q.value = ''; hideResults(); }
        });
      }
      if (e.key === 'Escape') { q.value = ''; hideResults(); }
    });
  }
  function drawCards() {
    var c = (BOOT.cats || []).filter(function (x) { return x.id === S.cat; })[0];
    var box = cat.querySelector('.nn-aut-cards');
    // الباقات من التسعير الموحد: خدمات وقطع بسعر الباقة
    if (S.cat === -1) {
      box.innerHTML = (BOOT.bundles || []).map(function (b) {
        return '<button type="button" class="nn-aut-card" style="--c:#16a34a" data-bnd="' + b.id + '">' + icon('fa-gift') + '<b>' + esc(b.name) + '</b><span>'
          + money(b.price) + '</span><small>' + (Number(b.listTotal) > Number(b.price) ? 'بدلاً من ' + money(b.listTotal) : '') + '</small></button>';
      }).join('');
      return;
    }
    if (!c) { box.innerHTML = '<div class="nn-empty">لا توجد خدمات؛ أضفها من إعداد الخدمات</div>'; return; }
    box.innerHTML = (c.services || []).map(function (s) {
      return '<button type="button" class="nn-aut-card" style="--c:' + esc(c.color || '#0067c0') + '" data-svc="' + s.id + '">' + icon(s.icon || 'fa-wrench')
        + '<b>' + esc(s.name) + '</b><span>' + money(s.price) + (s.inc === 'Y' ? ' شامل' : '') + '</span><small>'
        + (s.minutes ? icon('fa-clock-o') + ' ' + s.minutes + ' د' : '') + (s.parts ? ' · ' + icon('fa-cogs') + ' ' + s.parts + ' قطع' : '') + '</small></button>';
    }).join('') || '<div class="nn-empty">لا توجد خدمات في هذه الفئة</div>';
  }
  function hideResults() { var r = cat.querySelector('.nn-aut-results'); if (r) { r.hidden = true; r.innerHTML = ''; } }
  function search(q) {
    S.q = q;
    if (q.length < 2) { hideResults(); return Promise.resolve([]); }
    return call('PARTS', [q, JOB]).then(function (r) {
      if (S.q !== q) return [];
      var list = r.list || [], box = cat.querySelector('.nn-aut-results');
      box.hidden = false;
      box.innerHTML = list.length ? list.map(function (p) {
        var stock = Number(p.onHand || 0);
        return '<button type="button" class="nn-aut-part' + (stock <= 0 ? ' is-out' : '') + '" data-part="' + p.id + '"><span class="nn-aut-pn"><b>'
          + esc(p.name) + '</b><small dir="ltr">' + esc([p.no, p.mpn, p.brand].filter(Boolean).join(' · ')) + '</small></span>'
          + (p.fits === 'Y' ? '<span class="nn-badge is-success">يناسب المركبة</span>' : p.fits === 'N' ? '<span class="nn-badge is-danger">غير مطابق للمركبة</span>' : '')
          + (p.alt === 'Y' ? '<span class="nn-badge is-info">بديل</span>' : '')
          + '<span class="nn-aut-stock">' + icon('fa-cubes') + ' ' + qty(stock) + '</span><span class="nn-aut-price">' + money(p.price) + '</span></button>';
      }).join('') : '<div class="nn-empty">لا توجد قطع مطابقة لـ «' + esc(q) + '»</div>';
      return list;
    });
  }
  function addPart(id, q) {
    return call('ADDPART', [JOB, id, q || 1]).then(function (r) { load(r); toast('أضيفت القطعة'); });
  }

  // ------------------------------------------------------------ البنود
  function techOptions(cur) {
    return '<option value="">- الفني -</option>' + (BOOT.techs || []).map(function (t) {
      return '<option value="' + t.id + '"' + (t.id === cur ? ' selected' : '') + '>' + esc(t.name) + '</option>';
    }).join('');
  }
  function payerOptions(cur) {
    return [['CUSTOMER', 'العميل'], ['INSURANCE', 'التأمين'], ['WARRANTY', 'الضمان']].map(function (p) {
      return '<option value="' + p[0] + '"' + (p[0] === cur ? ' selected' : '') + '>' + p[1] + '</option>';
    }).join('');
  }
  function drawLines() {
    var ls = S.data.lines || [], ed = editable(), ins = S.data.job.payer !== 'CUSTOMER';
    if (!ls.length) { lines.innerHTML = '<div class="nn-empty">' + icon('fa-hand-pointer-o') + ' اختر الخدمات من الكروت أو ابحث عن القطع لإضافتها</div>'; return; }
    lines.innerHTML = '<table class="nn-prj-t nn-aut-lt"><thead><tr><th>البند</th><th>الفني / الحالة</th><th class="n">الكمية</th><th class="n">السعر</th>'
      + '<th class="n">الصافي</th>' + (ins ? '<th>على</th>' : '') + '<th></th></tr></thead><tbody>' + ls.map(function (l) {
        var svc = l.type !== 'PART', dis = ed ? '' : ' disabled';
        var st = svc ? '<select class="selectlist" data-f="tech" data-line="' + l.id + '"' + dis + '>' + techOptions(l.tech) + '</select>'
          + '<div class="nn-aut-ls is-' + String(l.status).toLowerCase() + '">' + esc(LST[l.status] || l.status)
          + (l.minutes ? ' · ' + l.minutes + ' د' : '') + (ed ? (l.status === 'PENDING' ? ' <button type="button" class="nn-aut-mini" data-la="START" data-line="' + l.id + '">' + icon('fa-play') + ' بدء</button>'
            : l.status === 'IN_PROGRESS' ? ' <button type="button" class="nn-aut-mini is-ok" data-la="DONE" data-line="' + l.id + '">' + icon('fa-check') + ' تم</button>'
              : ' <button type="button" class="nn-aut-mini" data-la="RESET" data-line="' + l.id + '" title="إعادة البند">' + icon('fa-undo') + '</button>') : '') + '</div>'
          : (l.onHand != null ? '<small class="' + (Number(l.onHand) < Number(l.qty) ? 'nn-aut-low' : '') + '">' + icon('fa-cubes') + ' المتوفر ' + qty(l.onHand) + '</small>' : '');
        return '<tr class="' + (l.parent ? 'is-child' : '') + '"><td><span class="nn-aut-lt-t">' + icon(l.type === 'SERVICE' ? 'fa-wrench' : l.type === 'PART' ? 'fa-cog' : 'fa-external-link')
          + ' ' + esc(l.desc) + '</span></td><td>' + st + '</td><td class="n">' + (svc && l.type === 'SERVICE' ? qty(l.qty)
            : '<input type="number" class="nn-aut-num" min="0.001" step="any" data-f="qty" data-line="' + l.id + '" value="' + qty(l.qty) + '"' + dis + '>')
          + '</td><td class="n"><input type="number" class="nn-aut-num" min="0" step="0.01" data-f="price" data-line="' + l.id + '" value="' + Number(l.price || 0) + '"' + dis + '>'
          + (Number(l.disc) ? '<small>خصم ' + money(l.disc) + '</small>' : '') + '</td><td class="n">' + money(l.net) + '</td>'
          + (ins ? '<td><select class="selectlist" data-f="payer" data-line="' + l.id + '"' + dis + '>' + payerOptions(l.payer) + '</select></td>' : '')
          + '<td>' + (ed ? '<button type="button" class="nn-fd-ib" data-del="' + l.id + '" title="حذف البند">' + icon('fa-trash-o') + '</button>' : '') + '</td></tr>';
      }).join('') + '</tbody></table>';
  }
  function drawTotals(j) {
    totals.innerHTML = '<div><span>الخدمات</span><b>' + money(j.services) + '</b></div><div><span>القطع</span><b>' + money(j.parts) + '</b></div>'
      + (Number(j.discount) ? '<div><span>الخصم</span><b>' + money(j.discount) + '</b></div>' : '')
      + '<div><span>الضريبة</span><b>' + money(j.tax) + '</b></div><div class="is-total"><span>الإجمالي</span><b>' + money(j.total) + '</b></div>'
      + (j.payer === 'INSURANCE' ? '<div class="is-ins"><span>حصة التأمين قبل الضريبة</span><b>' + money(j.insurerShare) + '</b></div>'
        + '<div class="is-ins"><span>تحمل العميل</span><b>' + money(j.deductible) + '</b></div>' : '');
  }
  function drawNotes(j) {
    var dis = editable() ? '' : ' disabled';
    notes.innerHTML = '<details' + (j.diagnosis || j.complaint ? ' open' : '') + '><summary>' + icon('fa-stethoscope') + ' الشكوى والتشخيص والتوصيات</summary>'
      + '<div class="nn-aut-form">' + field('شكوى العميل', '<textarea id="nnAutComp" rows="2"' + dis + '>' + esc(j.complaint) + '</textarea>')
      + field('التشخيص', '<textarea id="nnAutDiag" rows="2"' + dis + '>' + esc(j.diagnosis) + '</textarea>')
      + field('توصيات للعميل', '<textarea id="nnAutRec" rows="2"' + dis + '>' + esc(j.recommendations) + '</textarea>')
      + field('الموعد المتوقع للتسليم', '<input type="datetime-local" id="nnAutProm" value="' + esc((j.promised || '').replace(' ', 'T')) + '"' + dis + '>')
      + (editable() ? '<button type="button" class="t-Button" data-a="SAVENOTES">' + icon('fa-save') + ' حفظ</button>' : '') + '</div></details>'
      + (j.nextDate || j.nextKm ? '<p class="nn-hint">' + icon('fa-bell') + ' الخدمة التالية: ' + esc(j.nextDate || '') + (j.nextKm ? ' أو عند ' + j.nextKm + ' كم' : '') + '</p>' : '');
  }

  // ------------------------------------------------------------ الأحداث
  root.addEventListener('click', function (e) {
    var t;
    if ((t = e.target.closest('[data-cat]'))) {
      S.cat = Number(t.dataset.cat);
      cat.querySelectorAll('[data-cat]').forEach(function (b) { b.classList.toggle('is-on', b === t); });
      drawCards(); return;
    }
    if ((t = e.target.closest('[data-svc]'))) {
      t.disabled = true;
      call('ADDSVC', [JOB, t.dataset.svc]).then(function (r) { t.disabled = false; load(r); toast('أضيفت الخدمة وقطعها'); }, function () { t.disabled = false; });
      return;
    }
    if ((t = e.target.closest('[data-bnd]'))) {
      t.disabled = true;
      call('ADDBND', [JOB, t.dataset.bnd]).then(function (r) { t.disabled = false; load(r); toast('أضيفت الباقة بخدماتها وقطعها'); }, function () { t.disabled = false; });
      return;
    }
    if ((t = e.target.closest('[data-part]'))) { addPart(t.dataset.part, 1); return; }
    if ((t = e.target.closest('[data-la]'))) { call('LACT', [t.dataset.line, t.dataset.la, JOB]).then(load); return; }
    if ((t = e.target.closest('[data-del]'))) {
      if (!window.confirm('حذف البند؟ (حذف الخدمة يحذف قطعها الافتراضية)')) return;
      call('DELLINE', [t.dataset.del, JOB]).then(load); return;
    }
    if ((t = e.target.closest('[data-a]'))) action(t.dataset.a);
  });
  root.addEventListener('change', function (e) {
    var t = e.target.closest('[data-f]');
    if (!t) return;
    var d = { id: Number(t.dataset.line) };
    d[t.dataset.f] = t.dataset.f === 'payer' ? t.value : t.value === '' ? null : Number(t.value);
    call('UPDLINE', [JOB], d).then(load, function () { load(); });
  });

  function status(st, reason) { return call('STATUS', [JOB, st, reason]).then(load); }
  function action(a) {
    var j = S.data.job;
    if (a === 'WAIT') status('WAITING_PARTS');
    else if (a === 'RESUME') status('IN_PROGRESS');
    else if (a === 'COMPLETE') status('COMPLETED').then(function () { toast('اكتمل العمل؛ السيارة جاهزة للفوترة'); });
    else if (a === 'CANCEL') {
      show('إلغاء أمر الإصلاح', field('سبب الإلغاء', '<input type="text" id="nnAutWhy" class="text_field" maxlength="500">'), 'إلغاء الأمر', function () {
        return status('CANCELLED', val('nnAutWhy'));
      });
    } else if (a === 'INVOICE') {
      var places = (BOOT.places || []).map(function (p) { return '<option value="' + esc(p.v) + '">' + esc(p.n) + '</option>'; }).join('');
      var methods = (BOOT.methods || []).map(function (m) { return '<option value="' + esc(m.c) + '">' + esc(m.n) + '</option>'; }).join('');
      show('إصدار فاتورة أمر الإصلاح ' + j.no, '<p class="nn-hint">فاتورة واحدة بالخدمات والقطع تصرف القطع من المخزون'
        + (j.payer === 'INSURANCE' ? '، وفاتورة آجلة لشركة التأمين بحصتها (' + money(j.insurerShare) + ' قبل الضريبة)' : '') + '.</p>'
        + field('السداد', '<select id="nnAutPlace" class="selectlist"><option value="">آجل على حساب العميل</option>' + places + '</select>')
        + field('طريقة الدفع', '<select id="nnAutMeth" class="selectlist">' + methods + '</select>'), 'إصدار الفاتورة', function () {
        var d = {}; if (val('nnAutPlace')) { d.place = val('nnAutPlace'); d.method = val('nnAutMeth') || 'CASH'; }
        return call('INVOICE', [JOB], d).then(function (r) { load(r); toast('صدرت الفاتورة ' + (r.job.invoiceNo || '')); });
      });
      var pl = document.getElementById('nnAutPlace'); if (pl && BOOT.places && BOOT.places.length) pl.value = BOOT.places[0].v;
    } else if (a === 'DELIVER') {
      show('تسليم السيارة', field('قراءة العداد عند التسليم (كم)', '<input type="number" id="nnAutOdo" min="0" class="text_field" value="' + (j.odoIn || '') + '">'),
        'تم التسليم', function () {
          return call('DELIVER', [JOB, val('nnAutOdo')]).then(function (r) { load(r); toast('سلمت السيارة للعميل'); });
        });
    } else if (a === 'CLAIM') claimDialog(JOB, j, function (r) { load(r); });
    else if (a === 'PRINT') call('PRINT', [JOB]).then(function (r) { printHtml(r.html); });
    else if (a === 'SUBLET') {
      show('بند خارجي / عمل حر', field('البيان', '<input type="text" id="nnAutDesc" class="text_field" maxlength="1000">')
        + field('الكمية', '<input type="number" id="nnAutQty" class="text_field" value="1" min="0.001" step="any">')
        + field('السعر', '<input type="number" id="nnAutPrice" class="text_field" min="0" step="0.01">')
        + field('الفني', '<select id="nnAutTech" class="selectlist">' + techOptions(null) + '</select>'), 'إضافة', function () {
        var d = { job: JOB, type: 'SUBLET', desc: val('nnAutDesc'), qty: Number(val('nnAutQty') || 1), price: Number(val('nnAutPrice') || 0) };
        if (val('nnAutTech')) d.tech = Number(val('nnAutTech'));
        return call('ADDLINE', [JOB], d).then(load);
      });
    } else if (a === 'SAVENOTES') {
      var d = { id: JOB, complaint: val('nnAutComp'), diagnosis: val('nnAutDiag'), recommendations: val('nnAutRec') };
      if (val('nnAutProm')) d.promised = val('nnAutProm');
      call('UPDJOB', [], d).then(function (r) { load(r); toast('تم الحفظ'); });
    }
  }

  load();
})();
