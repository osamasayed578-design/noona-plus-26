/* NOONA PLUS | لوحة الاستقبال (Room Rack) ومخطط الحجوزات والتدبير الفندقي - تطبيق العقارات والضيافة 139
   البيانات من NOONA_HSP_PKG عبر عملية AJAX واحدة (FD) والعملية في x01.
   data-mode: rack (الاستقبال) أو hk (التدبير الفندقي). */
(function () {
  'use strict';
  var root = document.getElementById('nnFd');
  if (!root || root.dataset.ready) return;
  root.dataset.ready = '1';
  var MODE = root.dataset.mode || 'rack';
  var PROP = root.dataset.property;
  var S = { data: null, filter: 'ALL', q: '', tab: 'rack', chartFrom: null, sel: null, types: null };

  var FD = { VACANT: 'شاغرة', OCCUPIED: 'مشغولة', DUE_OUT: 'مغادرة اليوم', DUE_IN: 'وصول اليوم', OOO: 'خارج الخدمة' };
  var HK = { CLEAN: 'نظيفة', DIRTY: 'تحتاج تنظيف', INSPECTED: 'نظيفة ومفحوصة', IN_PROGRESS: 'جاري التنظيف', OUT_OF_ORDER: 'خارج الخدمة' };
  var FILTERS = MODE === 'hk'
    ? [['ALL', 'كل الغرف'], ['H_DIRTY', 'تحتاج تنظيف'], ['H_PROG', 'جاري التنظيف'], ['H_CLEAN', 'نظيفة'], ['H_INSP', 'مفحوصة'], ['OOO', 'خارج الخدمة']]
    : [['ALL', 'الكل'], ['V_CLEAN', 'شاغرة جاهزة'], ['V_DIRTY', 'شاغرة تحت التنظيف'], ['OCCUPIED', 'مشغولة'], ['DUE_IN', 'وصول اليوم'],
       ['DUE_OUT', 'مغادرة اليوم'], ['OOO', 'خارج الخدمة']];
  var CHARGES = [['LAUNDRY', 'مغسلة'], ['MINIBAR', 'ميني بار'], ['F_AND_B', 'مطعم وخدمة غرف'], ['SERVICE_CHARGE', 'خدمات إضافية'],
                 ['OTHER_CHARGE', 'رسوم أخرى'], ['ADJUSTMENT', 'خصم / تسوية (مبلغ سالب)']];
  var PAYS = [['CASH', 'نقداً'], ['CARD', 'شبكة / بطاقة'], ['BANK_TRANSFER', 'تحويل بنكي']];

  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  function icon(n) { return '<span class="fa ' + n + '" aria-hidden="true"></span>'; }
  function money(v) { return Number(v || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }
  function addDays(iso, n) { var d = new Date(iso + 'T00:00:00Z'); d.setUTCDate(d.getUTCDate() + n); return d.toISOString().slice(0, 10); }
  function dayName(iso) { return ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'][new Date(iso + 'T00:00:00Z').getUTCDay()]; }
  function opts(list, sel) { return list.map(function (o) { return '<option value="' + esc(o[0]) + '"' + (o[0] === sel ? ' selected' : '') + '>' + esc(o[1]) + '</option>'; }).join(''); }

  function call(op, args, clob) {
    var d = { x01: op };
    (args || []).forEach(function (v, i) { d['x0' + (i + 2)] = v == null ? '' : String(v); });
    if (clob != null) d.p_clob_01 = clob;
    return apex.server.process('FD', d).then(function (r) {
      if (r && r.err) { toast(r.err, true); throw new Error(r.err); }
      return r;
    }, function (x) { toast('تعذر الاتصال بالخادم', true); throw x; });
  }
  var tt;
  function toast(msg, err) {
    var t = toastEl;
    t.textContent = msg; t.classList.toggle('is-err', !!err); t.classList.add('is-on');
    clearTimeout(tt); tt = setTimeout(function () { t.classList.remove('is-on'); }, err ? 6000 : 3000);
  }
  function fv(f, n) { var e = f.querySelector('[name="' + n + '"]'); return e ? (e.type === 'checkbox' ? (e.checked ? e.value : '') : e.value) : ''; }
  function fset(f, n, v) { var e = f.querySelector('[name="' + n + '"]'); if (e) e.value = v; }
  function url(attr, id) { return (root.dataset[attr] || '').replace('990000000001', id); }

  // ------------------------------------------------------------ الهيكل
  root.innerHTML =
    '<div class="nn-fd-bar"><div class="nn-fd-tabs">' +
    (MODE === 'rack' ? '<button type="button" data-tab="rack" class="is-on">' + icon('fa-th') + ' حالة الغرف</button>' +
      '<button type="button" data-tab="chart">' + icon('fa-calendar') + ' مخطط الحجوزات</button>' : '') +
    '</div><div class="nn-fd-search">' + icon('fa-search') + '<input type="search" placeholder="رقم الغرفة أو اسم النزيل" aria-label="بحث"></div>' +
    '<span class="nn-fd-bd"></span><button type="button" class="nn-fd-ib" data-a="refresh" title="تحديث">' + icon('fa-refresh') + '</button></div>' +
    '<div class="nn-fd-filters"></div><div class="nn-fd-main"></div>' +
    '<aside class="nn-fd-drawer" aria-hidden="true"><div class="nn-fd-dh"><b></b><button type="button" class="nn-fd-ib" data-a="close" title="إغلاق">' +
    icon('fa-times') + '</button></div><div class="nn-fd-db"></div></aside><div class="nn-fd-toast" role="status" aria-live="polite"></div>';
  var main = root.querySelector('.nn-fd-main');
  var drawer = root.querySelector('.nn-fd-drawer');
  var toastEl = root.querySelector('.nn-fd-toast');
  // خارج حاوية المنطقة حتى يعمل الموضع الثابت، وخارج نموذج الصفحة
  document.body.appendChild(drawer);
  document.body.appendChild(toastEl);

  function state(r) {
    if (MODE === 'hk') return r.fd === 'OOO' ? 'OOO' : r.hk;
    return r.fd;
  }
  function match(r) {
    var f = S.filter, q = S.q;
    if (q && (r.no + ' ' + (r.guest || '')).toLowerCase().indexOf(q) < 0) return false;
    if (f === 'ALL') return true;
    if (f === 'V_CLEAN') return r.fd === 'VACANT' && (r.hk === 'CLEAN' || r.hk === 'INSPECTED');
    if (f === 'V_DIRTY') return r.fd === 'VACANT' && (r.hk === 'DIRTY' || r.hk === 'IN_PROGRESS');
    if (f === 'OCCUPIED') return r.fd === 'OCCUPIED' || r.fd === 'DUE_OUT';
    if (f === 'H_DIRTY') return r.hk === 'DIRTY' && r.fd !== 'OOO';
    if (f === 'H_PROG') return r.hk === 'IN_PROGRESS';
    if (f === 'H_CLEAN') return r.hk === 'CLEAN';
    if (f === 'H_INSP') return r.hk === 'INSPECTED';
    return r.fd === f;
  }
  function count(f) { var c = 0, s = S.filter; S.filter = f; (S.data.rooms || []).forEach(function (r) { if (match(r)) c++; }); S.filter = s; return c; }

  function renderFilters() {
    var box = root.querySelector('.nn-fd-filters');
    box.innerHTML = FILTERS.map(function (f) {
      return '<button type="button" data-f="' + f[0] + '" class="nn-fd-chip nn-fd-c-' + f[0].toLowerCase() + (S.filter === f[0] ? ' is-on' : '') + '">' +
        esc(f[1]) + ' <b>' + count(f[0]) + '</b></button>';
    }).join('');
  }

  function tile(r) {
    var st = state(r), cls = 'nn-fd-t nn-fd-' + (r.fd === 'VACANT' ? (r.hk === 'CLEAN' || r.hk === 'INSPECTED' ? 'vclean' : 'vdirty') : r.fd.toLowerCase());
    if (MODE === 'hk') cls = 'nn-fd-t nn-fd-hk-' + String(st).toLowerCase();
    var html = '<button type="button" class="' + cls + '" data-room="' + r.id + '"><div class="nn-fd-tt"><b>' + esc(r.no) + '</b>' +
      (r.mnt ? '<span class="nn-fd-mnt" title="بلاغ صيانة مفتوح">' + icon('fa-wrench') + '</span>' : '') +
      '<span class="nn-fd-hk" title="' + esc(HK[r.hk] || r.hk) + '">' + icon(r.hk === 'DIRTY' ? 'fa-paint-brush' : r.hk === 'IN_PROGRESS' ? 'fa-spinner' :
        r.hk === 'INSPECTED' ? 'fa-check-circle' : r.hk === 'OUT_OF_ORDER' ? 'fa-ban' : 'fa-check') + '</span></div>' +
      '<div class="nn-fd-ty">' + esc(r.type) + '</div>';
    if (MODE === 'hk') {
      html += '<div class="nn-fd-st">' + esc(r.fd === 'OOO' ? 'خارج الخدمة' : HK[r.hk]) + '</div><div class="nn-fd-g">' +
        esc(r.fd === 'OCCUPIED' || r.fd === 'DUE_OUT' ? 'مشغولة' + (r.fd === 'DUE_OUT' ? ' - مغادرة اليوم' : '') : r.fd === 'DUE_IN' ? 'وصول اليوم' : '') + '</div>';
    } else if (r.guest) {
      html += '<div class="nn-fd-g">' + esc(r.guest) + '</div><div class="nn-fd-d">' + (r.fd === 'DUE_IN' ? 'وصول اليوم' : 'حتى ' + esc(r.dep)) +
        (r.stay && r.bal ? ' · <span class="' + (r.bal > 0 ? 'is-due' : 'is-cr') + '">' + money(r.bal) + '</span>' : '') + '</div>';
    } else {
      html += '<div class="nn-fd-st">' + esc(r.fd === 'OOO' ? 'خارج الخدمة' : (HK[r.hk] || '')) + '</div>';
    }
    return html + '</button>';
  }

  function renderRack() {
    var rooms = (S.data.rooms || []).filter(match), floors = {}, order = [];
    rooms.forEach(function (r) { var k = r.floor || 'بدون طابق'; if (!floors[k]) { floors[k] = []; order.push(k); } floors[k].push(r); });
    main.innerHTML = rooms.length ? order.map(function (k) {
      return '<section class="nn-fd-floor"><h4>' + esc(k) + ' <small>' + floors[k].length + '</small></h4><div class="nn-fd-grid">' +
        floors[k].map(tile).join('') + '</div></section>';
    }).join('') : '<div class="nn-empty">لا توجد غرف مطابقة</div>';
  }

  function renderChart(c) {
    var days = c.days, from = c.from, byRoom = {};
    (c.blocks || []).forEach(function (b) { (byRoom[b.room] = byRoom[b.room] || {})[b.d] = b; });
    var h = '<div class="nn-fd-chartbar"><button type="button" class="nn-fd-ib" data-a="prev" title="السابق">' + icon('fa-chevron-right') +
      '</button><b>' + esc(from) + ' ← ' + esc(addDays(from, days - 1)) + '</b><button type="button" class="nn-fd-ib" data-a="next" title="التالي">' +
      icon('fa-chevron-left') + '</button><button type="button" class="nn-fd-btn" data-a="today">اليوم</button>' +
      '<a class="nn-fd-btn is-hot" href="' + esc(url('res', '')) + '">' + icon('fa-plus') + ' حجز جديد</a></div>' +
      '<div class="nn-fd-chart"><table><thead><tr><th class="nn-fd-rh">الغرفة</th>';
    for (var i = 0; i < days; i++) {
      var di = addDays(from, i);
      h += '<th class="' + (di === S.data.business_date ? 'is-today' : '') + '"><small>' + dayName(di) + '</small>' + di.slice(5) + '</th>';
    }
    h += '</tr></thead><tbody>';
    (c.rooms || []).forEach(function (r) {
      if (S.q && r.no.toLowerCase().indexOf(S.q) < 0) return;
      h += '<tr><th class="nn-fd-rh">' + esc(r.no) + '<small>' + esc(r.type) + '</small></th>';
      var row = byRoom[r.id] || {};
      for (var d = 0; d < days;) {
        var b = row[d];
        if (!b) { h += '<td class="nn-fd-free" data-room="' + r.id + '" data-d="' + addDays(from, d) + '"></td>'; d++; continue; }
        var span = 1, key = b.t + ':' + (b.res || '') + ':' + (b.stay || '');
        while (d + span < days && row[d + span] && (row[d + span].t + ':' + (row[d + span].res || '') + ':' + (row[d + span].stay || '')) === key) span++;
        var cls = b.t === 'STAY' ? 'is-stay' : b.t === 'RESERVATION' ? 'is-res' : 'is-ooo';
        h += '<td colspan="' + span + '"><button type="button" class="nn-fd-bar-b ' + cls + '" data-res="' + (b.res || '') + '" data-stay="' + (b.stay || '') +
          '" title="' + esc((b.g || '') + ' ' + (b.no || '')) + '">' + esc(b.t === 'OUT_OF_ORDER' || b.t === 'MAINTENANCE' ? 'صيانة / خارج الخدمة' : (b.g || b.no || '')) +
          '</button></td>';
        d += span;
      }
      h += '</tr>';
    });
    main.innerHTML = h + '</tbody></table></div><div class="nn-fd-legend"><span class="is-stay">مقيم</span><span class="is-res">محجوز</span>' +
      '<span class="is-ooo">خارج الخدمة</span><span>انقر خانة فارغة لحجز الغرفة</span></div>';
  }

  function load() {
    return call('RACK', [PROP]).then(function (d) {
      S.data = d;
      root.querySelector('.nn-fd-bd').innerHTML = icon('fa-calendar') + ' تاريخ العمل <b>' + esc(d.business_date) + '</b>';
      if (!S.chartFrom) S.chartFrom = d.business_date;
      renderFilters();
      if (S.tab === 'chart') return call('CHART', [PROP, S.chartFrom, 14]).then(renderChart);
      renderRack();
      if (S.sel) { var r = find(S.sel); if (r && drawer.classList.contains('is-open')) open(r); }
    });
  }
  function find(id) { return (S.data.rooms || []).filter(function (r) { return String(r.id) === String(id); })[0]; }

  // ------------------------------------------------------------ اللوحة الجانبية
  function show(title, html) {
    drawer.querySelector('.nn-fd-dh b').innerHTML = title;
    drawer.querySelector('.nn-fd-db').innerHTML = html;
    drawer.classList.add('is-open'); drawer.setAttribute('aria-hidden', 'false');
  }
  function close() { drawer.classList.remove('is-open'); drawer.setAttribute('aria-hidden', 'true'); S.sel = null; }
  function sec(t, body) { return '<div class="nn-fd-sec"><h5>' + t + '</h5>' + body + '</div>'; }
  function hkButtons(r) {
    return sec('حالة النظافة: ' + esc(HK[r.hk] || r.hk), '<div class="nn-fd-acts">' +
      [['DIRTY', 'تحتاج تنظيف', 'fa-paint-brush'], ['IN_PROGRESS', 'جاري التنظيف', 'fa-spinner'], ['CLEAN', 'نظيفة', 'fa-check'],
       ['INSPECTED', 'مفحوصة وجاهزة', 'fa-check-circle']].map(function (h) {
        return '<button type="button" class="nn-fd-btn' + (r.hk === h[0] ? ' is-on' : '') + '" data-a="hk" data-v="' + h[0] + '">' + icon(h[2]) + ' ' + h[1] + '</button>';
      }).join('') + '</div>');
  }
  function mntLink(r) {
    return '<a class="nn-fd-btn" href="' + esc(url('req', r.id)) + '">' + icon('fa-wrench') + ' بلاغ صيانة' + (r.mnt ? ' (' + r.mnt + ' مفتوح)' : '') + '</a>';
  }

  function open(r) {
    S.sel = r.id;
    var title = 'غرفة ' + esc(r.no) + ' <small>' + esc(r.type) + ' · ' + esc(r.fd === 'OOO' ? 'خارج الخدمة' : FD[r.fd]) + '</small>';
    if (MODE === 'hk') {
      return show(title, r.fd === 'OOO' ? sec('خارج الخدمة', '<p>' + esc(r.notes || '') + '</p><div class="nn-fd-acts">' +
        '<button type="button" class="nn-fd-btn is-hot" data-a="rts">' + icon('fa-undo') + ' إعادة للخدمة</button>' + mntLink(r) + '</div>') : hkButtons(r) +
        sec('', '<div class="nn-fd-acts">' + mntLink(r) + '</div>'));
    }
    if (r.fd === 'OOO') {
      return show(title, sec('خارج الخدمة', '<p>' + esc(r.notes || '') + '</p><div class="nn-fd-acts"><button type="button" class="nn-fd-btn is-hot" data-a="rts">' +
        icon('fa-undo') + ' إعادة للخدمة (للتنظيف)</button>' + mntLink(r) + '</div>'));
    }
    if (r.fd === 'DUE_IN') {
      return show(title, sec('وصول متوقع', '<p><b>' + esc(r.guest) + '</b><br>حتى ' + esc(r.dep) + '</p>' +
        (r.hk !== 'CLEAN' && r.hk !== 'INSPECTED' ? '<p class="nn-fd-warn">' + icon('fa-exclamation-triangle') + ' الغرفة ' + esc(HK[r.hk]) + '</p>' : '') +
        '<div class="nn-fd-acts"><button type="button" class="nn-fd-btn is-hot" data-a="checkin" data-res="' + r.res + '">' + icon('fa-sign-in') +
        ' تسجيل الدخول</button><button type="button" class="nn-fd-btn" data-a="noshow" data-res="' + r.res + '">' + icon('fa-user-times') +
        ' لم يحضر</button><a class="nn-fd-btn" href="' + esc(url('resv', r.res)) + '">' + icon('fa-external-link') + ' فتح الحجز</a></div>') + hkButtons(r));
    }
    if (r.stay) return openStay(r);
    // شاغرة: دخول سريع
    show(title, sec('دخول سريع (Walk-in)', walkForm(r)) + '<div class="nn-fd-acts"><a class="nn-fd-btn" href="' + esc(url('res', r.id)) + '">' +
      icon('fa-calendar-plus-o') + ' حجز مستقبلي لهذه الغرفة</a>' + mntLink(r) + '</div>' + hkButtons(r));
    typesFor(r);
  }

  function walkForm(r) {
    return '<div class="nn-fd-form" data-form="walkin" data-room="' + r.id + '">' +
      '<label>اسم النزيل<input name="guest_name" required></label><label>الجوال<input name="phone" inputmode="tel"></label>' +
      '<label>نوع الهوية<select name="id_type">' + opts([['NATIONAL_ID', 'هوية وطنية'], ['IQAMA', 'إقامة'], ['PASSPORT', 'جواز سفر']], 'NATIONAL_ID') +
      '</select></label><label>رقم الهوية<input name="id_no"></label>' +
      '<label>عدد الليالي<input name="nights" type="number" min="1" value="1"></label>' +
      '<label>سعر الليلة<input name="rate" type="number" step="0.01"></label>' +
      '<label>البالغون<input name="adults" type="number" min="1" value="1"></label>' +
      '<label>دفعة مقدمة<input name="pay" type="number" step="0.01"></label><label>طريقة السداد<select name="pay_method">' + opts(PAYS, 'CASH') + '</select></label>' +
      (r.hk !== 'CLEAN' && r.hk !== 'INSPECTED' ? '<label class="nn-fd-chk"><input type="checkbox" name="force" value="Y"> الدخول رغم أن الغرفة ' + esc(HK[r.hk]) + '</label>' : '') +
      '<div class="nn-fd-total"></div><button type="button" data-submit="1" class="nn-fd-btn is-hot">' + icon('fa-key') + ' تسجيل الدخول</button></div>';
  }
  function typesFor(r) {
    var go = function (t) {
      var x = (t.types || []).filter(function (y) { return String(y.id) === String(r.type_id); })[0];
      var f = drawer.querySelector('[data-form="walkin"]');
      if (x && f && !fv(f, 'rate')) { fset(f, 'rate', x.rate || ''); total(f); }
    };
    if (S.types) return go(S.types);
    call('TYPES', [PROP]).then(function (t) { S.types = t; go(t); });
  }
  function total(f) {
    var n = +fv(f, 'nights') || 0, rate = +fv(f, 'rate') || 0, sub = n * rate;
    f.querySelector('.nn-fd-total').innerHTML = n && rate ? 'الإجمالي التقديري: <b>' + money(sub * 1.15) + '</b> شامل ضريبة 15% (' + money(sub) + ' + ' + money(sub * 0.15) + ')' : '';
  }

  function openStay(r) {
    call('STAY', [r.stay]).then(function (s) {
      var lines = (s.lines || []).map(function (l) {
        return '<tr><td>' + esc(l.d) + '</td><td>' + esc(l.x) + '</td><td class="' + (l.a < 0 ? 'is-cr' : '') + '">' + money(l.a) + '</td></tr>';
      }).join('');
      var bal = s.balance || 0, due = Math.round((bal + (s.pending || 0)) * 100) / 100;
      show('غرفة ' + esc(s.room) + ' <small>' + esc(s.guest) + '</small>',
        '<div class="nn-fd-guest"><div><span>النزيل</span><b>' + esc(s.guest) + '</b></div><div><span>الجوال</span>' + esc(s.phone || '-') +
        '</div><div><span>الدخول</span>' + esc(s.since) + '</div><div><span>المغادرة</span>' + esc(s.dep) + '</div><div><span>سعر الليلة</span>' + money(s.rate) +
        '</div><div><span>الحجز</span>' + esc(s.res_no) + ' · ' + esc(s.channel) + '</div></div>' +
        (s.requests ? '<p class="nn-fd-note">' + icon('fa-comment-o') + ' ' + esc(s.requests) + '</p>' : '') +
        sec('حساب النزيل ' + esc(s.folio_no) + ' · الرصيد <b class="' + (bal > 0 ? 'is-due' : 'is-cr') + '">' + money(bal) + '</b>',
          '<div class="nn-fd-lines"><table><tbody>' + (lines || '<tr><td colspan="3">لا حركات بعد</td></tr>') + '</tbody></table></div>' +
          (s.pending ? '<p class="nn-fd-note">' + icon('fa-moon-o') + ' رسوم ليالٍ لم ترحل بعد (ترحل بالتدقيق الليلي أو عند المغادرة): <b>' +
            money(s.pending) + '</b> · المستحق عند المغادرة <b class="' + (due > 0 ? 'is-due' : 'is-cr') + '">' + money(due) + '</b></p>' : '') +
          '<a class="nn-fd-btn" target="_blank" href="' + esc(url('folio', s.folio)) + '">' + icon('fa-print') + ' طباعة الفاتورة</a>') +
        sec('دفعة / استرداد', '<div class="nn-fd-form is-row" data-form="pay"><input name="amount" type="number" step="0.01" placeholder="المبلغ" value="' +
          (due > 0 ? due.toFixed(2) : '') + '" required><select name="method">' + opts(PAYS, 'CASH') + '</select><input name="ref" placeholder="المرجع">' +
          '<button type="button" data-submit="1" class="nn-fd-btn is-hot">' + icon('fa-money') + ' تسجيل</button></div>') +
        sec('خدمة أو رسوم', '<div class="nn-fd-form is-row" data-form="charge"><select name="type">' + opts(CHARGES, 'LAUNDRY') + '</select>' +
          '<input name="desc" placeholder="البيان" required><input name="amount" type="number" step="0.01" placeholder="قبل الضريبة" required>' +
          '<button type="button" data-submit="1" class="nn-fd-btn">' + icon('fa-plus') + ' إضافة</button></div>') +
        sec('تمديد أو تقصير الإقامة', '<div class="nn-fd-form is-row" data-form="extend"><input name="dep" type="date" value="' + esc(addDays(s.dep, 1)) +
          '" required><button type="button" data-submit="1" class="nn-fd-btn">' + icon('fa-calendar') + ' تغيير المغادرة</button></div>') +
        sec('نقل لغرفة أخرى', '<div class="nn-fd-form is-row" data-form="move"><select name="room" required><option value="">جاري التحميل...</option></select>' +
          '<input name="reason" placeholder="السبب" required><button type="button" data-submit="1" class="nn-fd-btn">' + icon('fa-exchange') + ' نقل</button></div>') +
        sec('المغادرة', '<div class="nn-fd-form" data-form="checkout">' + (due > 0 ? '<p class="nn-fd-warn">' + icon('fa-exclamation-triangle') +
          ' على النزيل ' + money(due) + '؛ سجّل الدفعة أعلاه أو حوّل الرصيد لحساب شركة:</p><label>حساب الشركة<select name="party"><option value="">-</option></select></label>' : '') +
          '<button type="button" data-submit="1" class="nn-fd-btn is-hot">' + icon('fa-sign-out') + ' تسجيل المغادرة</button></div>') +
        '<div class="nn-fd-acts">' + mntLink(r) + '</div>');
      drawer.dataset.stay = s.id; drawer.dataset.folio = s.folio;
      call('FREE', [PROP, S.data.business_date, s.dep]).then(function (rs) {
        var sel = drawer.querySelector('[data-form="move"] select');
        if (sel) sel.innerHTML = '<option value="">اختر الغرفة</option>' + (rs || []).filter(function (x) { return String(x.id) !== String(r.id); }).map(function (x) {
          return '<option value="' + x.id + '">' + esc(x.no + ' - ' + x.type + ' · ' + (HK[x.hk] || '')) + '</option>';
        }).join('');
      });
      if (due > 0) call('PARTIES', []).then(function (ps) {
        var sel = drawer.querySelector('[data-form="checkout"] select');
        if (sel) sel.innerHTML = '<option value="">- بلا تحويل -</option>' + (ps || []).map(function (x) { return '<option value="' + x.id + '">' + esc(x.name) + '</option>'; }).join('');
      });
    });
  }

  function kpis() {
    var k = document.getElementById('nnFdKpi');
    if (k) apex.server.process('FD', { x01: 'SUMMARY', x02: PROP }, { dataType: 'text' }).then(function (h) { if (h && h.charAt(0) === '<') k.innerHTML = h; });
  }
  function after(msg) { toast(msg); S.types = null; kpis(); return load(); }

  // ------------------------------------------------------------ الأحداث
  function onClick(e) {
    var sb = e.target.closest('[data-submit]');
    if (sb) { submit(sb.closest('[data-form]'), sb); return; }
    var t = e.target.closest('[data-tab],[data-f],[data-room],[data-a],[data-res],[data-stay]');
    if (!t || !(root.contains(t) || drawer.contains(t))) return;
    if (t.dataset.tab) {
      S.tab = t.dataset.tab;
      root.querySelectorAll('[data-tab]').forEach(function (b) { b.classList.toggle('is-on', b === t); });
      root.querySelector('.nn-fd-filters').style.display = S.tab === 'chart' ? 'none' : '';
      close(); load(); return;
    }
    if (t.dataset.f) { S.filter = t.dataset.f; renderFilters(); renderRack(); return; }
    var a = t.dataset.a;
    if (a === 'refresh') { load(); return; }
    if (a === 'close') { close(); return; }
    if (a === 'prev' || a === 'next' || a === 'today') {
      S.chartFrom = a === 'today' ? S.data.business_date : addDays(S.chartFrom, a === 'prev' ? -7 : 7);
      call('CHART', [PROP, S.chartFrom, 14]).then(renderChart); return;
    }
    var r = S.sel ? find(S.sel) : null;
    if (a === 'hk') { call('HK', [S.sel, t.dataset.v]).then(function () { return after('تم تحديث حالة النظافة'); }); return; }
    if (a === 'rts') { call('RTS', [S.sel]).then(function () { return after('أعيدت الغرفة للخدمة وأنشئت مهمة تنظيف'); }); return; }
    if (a === 'checkin') {
      call('CHECKIN', [t.dataset.res, '', 'N']).then(function () { return after('تم تسجيل الدخول'); }).then(function () { var x = find(S.sel); if (x) open(x); });
      return;
    }
    if (a === 'noshow') { if (confirm('تسجيل عدم حضور النزيل وتحرير الغرفة؟')) call('NOSHOW', [t.dataset.res]).then(function () { close(); return after('سجل عدم الحضور'); }); return; }
    if (t.classList.contains('nn-fd-free')) { window.location.href = url('res', t.dataset.room); return; }
    if (t.classList.contains('nn-fd-bar-b')) {
      if (t.dataset.stay) { var rr = (S.data.rooms || []).filter(function (x) { return String(x.stay) === t.dataset.stay; })[0]; if (rr) { open(rr); return; } }
      if (t.dataset.res) window.location.href = url('resv', t.dataset.res);
      return;
    }
    if (t.dataset.room && t.classList.contains('nn-fd-t')) { var x = find(t.dataset.room); if (x) open(x); }
  }
  root.addEventListener('click', onClick);
  drawer.addEventListener('click', onClick);
  function onInput(e) {
    if (e.target.matches('.nn-fd-search input')) {
      S.q = e.target.value.trim().toLowerCase();
      if (S.tab === 'chart') call('CHART', [PROP, S.chartFrom, 14]).then(renderChart); else { renderFilters(); renderRack(); }
    }
    var f = e.target.closest('[data-form]');
    if (f && f.dataset.form === 'walkin') total(f);
  }
  root.addEventListener('input', onInput);
  drawer.addEventListener('input', onInput);
  drawer.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && e.target.matches('input')) { e.preventDefault(); var f = e.target.closest('[data-form]'); if (f) submit(f, f.querySelector('[data-submit]')); }
  });
  function submit(f, btn) {
    var k = f && f.dataset.form;
    if (!k) return;
    var miss = Array.prototype.filter.call(f.querySelectorAll('[required]'), function (x) { return !x.value; })[0];
    if (miss) { miss.focus(); toast('أكمل الحقول المطلوبة', true); return; }
    btn.disabled = true;
    var done = function () { btn.disabled = false; };
    var stay = drawer.dataset.stay, folio = drawer.dataset.folio, p;
    if (k === 'walkin') {
      var r = find(f.dataset.room);
      p = call('WALKIN', [], JSON.stringify({ property: PROP, room: f.dataset.room, room_type: r && r.type_id, guest_name: fv(f, 'guest_name'),
        phone: fv(f, 'phone'), id_type: fv(f, 'id_type'), id_no: fv(f, 'id_no'), nights: fv(f, 'nights'), rate: fv(f, 'rate') || null,
        adults: fv(f, 'adults'), pay: fv(f, 'pay') || 0, pay_method: fv(f, 'pay_method'), force: fv(f, 'force') || 'N' }))
        .then(function () { return after('تم تسجيل دخول النزيل'); }).then(function () { var x = find(S.sel); if (x) open(x); });
    } else if (k === 'pay') {
      p = call('PAY', [folio, fv(f, 'amount'), fv(f, 'method'), fv(f, 'ref')]).then(function () { return after('تم تسجيل الدفعة'); })
        .then(function () { var x = find(S.sel); if (x) open(x); });
    } else if (k === 'charge') {
      p = call('CHARGE', [folio, fv(f, 'type'), fv(f, 'desc'), fv(f, 'amount')]).then(function () { return after('أضيفت الرسوم لحساب النزيل'); })
        .then(function () { var x = find(S.sel); if (x) open(x); });
    } else if (k === 'extend') {
      p = call('EXTEND', [stay, fv(f, 'dep')]).then(function () { return after('تم تغيير تاريخ المغادرة'); }).then(function () { var x = find(S.sel); if (x) open(x); });
    } else if (k === 'move') {
      var to = fv(f, 'room');
      p = call('MOVE', [stay, to, fv(f, 'reason')]).then(function () { S.sel = to; return after('تم نقل النزيل'); })
        .then(function () { var x = find(S.sel); if (x) open(x); });
    } else if (k === 'checkout') {
      p = call('CHECKOUT', [stay, fv(f, 'party')]).then(function (res) {
        close(); toast('تمت المغادرة؛ الغرفة الآن تحتاج تنظيف'); kpis();
        if (res && res.folio) window.open(url('folio', res.folio), '_blank');
        return load();
      });
    }
    if (p) p.then(done, done); else done();
  }
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
  load();
  setInterval(function () { if (!drawer.classList.contains('is-open') && document.visibilityState === 'visible') load(); }, 60000);
})();
