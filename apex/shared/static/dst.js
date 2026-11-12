/* NOONA_DST: الشاشات الميدانية للمندوب (الهاتف أولاً)
   - بطاقات الأصناف بخانة كمية +/- وبحث وإجمالي، وتسلسل الأسطر JSON في العنصر المخفي المحدد بـ data-item قبل الإرسال
   - الموقع الجغرافي: زر تسجيل الوصول يأخذ الموقع ثم يرسل الصفحة، وزر «موقعي» يملأ خانتي العرض والطول
   - طريقة الدفع: إظهار رقم المرجع والبنك وتاريخ الشيك حسب الطريقة */
(function () {
  'use strict';
  var GEO = null;

  function num(v) { var n = parseFloat(String(v || '').replace(',', '.')); return isNaN(n) ? 0 : n; }
  function fmt(n) { return (Math.round(n * 100) / 100).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }

  // ------------------------------------------------------------ الأصناف
  function recalc(pk) {
    var sum = 0, cnt = 0;
    pk.querySelectorAll('.nn-dst-item').forEach(function (it) {
      var q = num(it.querySelector('input').value);
      it.classList.toggle('is-on', q > 0);
      if (q > 0) { cnt++; sum += q * num(it.getAttribute('data-p')); }
    });
    var s = pk.querySelector('.nn-dst-sum'), c = pk.querySelector('.nn-dst-cnt');
    if (s) s.textContent = fmt(sum);
    if (c) c.textContent = cnt;
    var pay = document.querySelector('[data-dst-total]');
    if (pay && pk.getAttribute('data-mode') === 'SALE') pay.setAttribute('data-dst-total', sum.toFixed(2));
  }

  function clamp(it, q) {
    var mx = it.getAttribute('data-max');
    if (mx !== null && mx !== '' && q > num(mx)) { q = num(mx); flash(it); }
    return q < 0 ? 0 : q;
  }

  function flash(it) { it.classList.add('is-max'); setTimeout(function () { it.classList.remove('is-max'); }, 700); }

  // القوائم الطويلة (الطلبية من كل الأصناف) تظهر بالبحث أو بزر «عرض الكل» حتى لا تطول شاشة الهاتف
  function filter(pk) {
    var f = pk.querySelector('.nn-dst-find'), t = f ? f.value.trim().toLowerCase() : '';
    var all = pk.getAttribute('data-all') === '1';
    pk.querySelectorAll('.nn-dst-item').forEach(function (it) {
      var hit = !t || (it.getAttribute('data-s') || '').indexOf(t) >= 0;
      var on = num(it.querySelector('input').value) > 0;
      it.style.display = (hit && (all || t || on)) || (t && hit) ? '' : 'none';
    });
  }

  function initPicker(pk) {
    if (pk.getAttribute('data-ready')) return;
    pk.setAttribute('data-ready', '1');
    var n = pk.querySelectorAll('.nn-dst-item').length;
    pk.setAttribute('data-all', n > 8 ? '0' : '1');
    if (n > 8) {
      var b = document.createElement('button');
      b.type = 'button'; b.className = 'nn-dst-btn nn-dst-showall'; b.textContent = 'عرض كل الأصناف (' + n + ')';
      b.addEventListener('click', function () {
        var all = pk.getAttribute('data-all') === '1';
        pk.setAttribute('data-all', all ? '0' : '1');
        b.textContent = all ? 'عرض كل الأصناف (' + n + ')' : 'إخفاء القائمة';
        filter(pk);
      });
      var f = pk.querySelector('.nn-dst-find');
      if (f) f.insertAdjacentElement('afterend', b); else pk.insertBefore(b, pk.firstChild);
      filter(pk);
    }
    pk.addEventListener('click', function (e) {
      var b = e.target.closest('.nn-dst-plus, .nn-dst-minus');
      if (!b) return;
      var it = b.closest('.nn-dst-item'), inp = it.querySelector('input');
      var q = num(inp.value) + (b.classList.contains('nn-dst-plus') ? 1 : -1);
      q = clamp(it, q);
      inp.value = q > 0 ? q : '';
      recalc(pk);
    });
    pk.addEventListener('input', function (e) {
      if (e.target.classList.contains('nn-dst-find')) { filter(pk); return; }
      var it = e.target.closest('.nn-dst-item');
      if (it) {
        var q = num(e.target.value), c = clamp(it, q);
        if (c !== q) e.target.value = c || '';
        recalc(pk);
      }
    });
    // الباركود: Enter في البحث يضيف واحداً للصنف الوحيد المطابق
    pk.addEventListener('keydown', function (e) {
      if (e.key !== 'Enter' || !e.target.classList.contains('nn-dst-find')) return;
      e.preventDefault();
      var vis = Array.prototype.filter.call(pk.querySelectorAll('.nn-dst-item'), function (it) { return it.style.display !== 'none'; });
      if (vis.length === 1) { vis[0].querySelector('.nn-dst-plus').click(); e.target.value = ''; e.target.dispatchEvent(new Event('input', { bubbles: true })); }
    });
    recalc(pk);
  }

  function serialize() {
    document.querySelectorAll('[data-item]').forEach(function (box) {
      var name = box.getAttribute('data-item'), lines = [];
      box.querySelectorAll('.nn-dst-item').forEach(function (it) {
        var q = num(it.querySelector('input').value);
        if (q <= 0) return;
        if (it.hasAttribute('data-l')) lines.push({ l: +it.getAttribute('data-l'), q: q });
        else lines.push({ i: +it.getAttribute('data-i'), q: q });
      });
      if (window.apex && apex.item(name).node) apex.item(name).setValue(JSON.stringify(lines));
    });
  }

  // ------------------------------------------------------------ الموقع
  function locate(cb) {
    if (!navigator.geolocation) { cb(null); return; }
    navigator.geolocation.getCurrentPosition(function (p) {
      GEO = { lat: p.coords.latitude, lng: p.coords.longitude, acc: p.coords.accuracy };
      cb(GEO);
    }, function () { cb(GEO); }, { enableHighAccuracy: true, timeout: 9000, maximumAge: 60000 });
  }

  function setGeo(latItem, lngItem, g) {
    if (!g) return false;
    apex.item(latItem).setValue(g.lat.toFixed(7));
    apex.item(lngItem).setValue(g.lng.toFixed(7));
    return true;
  }

  document.addEventListener('click', function (e) {
    var b = e.target.closest('.nn-dst-checkin');
    if (b) {
      e.preventDefault();
      b.disabled = true;
      b.innerHTML = '<span class="fa fa-spinner fa-spin"></span> جارٍ تحديد الموقع…';
      locate(function (g) {
        setGeo(b.getAttribute('data-lat'), b.getAttribute('data-lng'), g);
        if (!g && !confirm('تعذر تحديد الموقع. تسجيل الوصول بدون موقع؟')) {
          b.disabled = false; b.innerHTML = '<span class="fa fa-map-marker"></span> تسجيل الوصول'; return;
        }
        apex.submit(b.getAttribute('data-req') || 'CHECKIN');
      });
      return;
    }
    var m = e.target.closest('.nn-dst-mygeo');
    if (m) {
      e.preventDefault();
      m.classList.add('is-busy');
      locate(function (g) {
        m.classList.remove('is-busy');
        if (!setGeo(m.getAttribute('data-lat'), m.getAttribute('data-lng'), g)) apex.message.alert('تعذر تحديد الموقع: فعّل خدمة الموقع في المتصفح.');
        else apex.message.showPageSuccess('تم تحديد الموقع (دقة ' + Math.round(g.acc) + ' م)');
      });
      return;
    }
    var f = e.target.closest('.nn-dst-fill');
    if (f) {   // تعبئة مبلغ الدفع بإجمالي البيع
      e.preventDefault();
      var t = document.querySelector('[data-dst-total]');
      if (t) apex.item(f.getAttribute('data-target')).setValue(t.getAttribute('data-dst-total'));
    }
  });

  // ------------------------------------------------------------ طريقة الدفع
  function methodFields(sel) {
    var p = sel.id.replace(/_[A-Z]+$/, ''), suf = sel.getAttribute('data-dst-method') || '';
    var m = apex.item(sel.id).getValue() || 'CASH';
    function show(item, on) {
      var it = apex.item(item);
      if (!it.node) return;
      if (on) it.show(); else it.hide();
    }
    var refs = (sel.getAttribute('data-dst-ref') || '').split(','), bank = sel.getAttribute('data-dst-bank'), chq = sel.getAttribute('data-dst-chq');
    refs.forEach(function (r) { if (r) show(r, m !== 'CASH'); });
    if (bank) show(bank, m === 'BANK_TRANSFER' || m === 'CHEQUE');
    if (chq) show(chq, m === 'CHEQUE');
    var lab = document.getElementById((refs[0] || '') + '_LABEL');
    if (lab) lab.textContent = m === 'BANK_TRANSFER' ? 'رقم الإشعار البنكي' : m === 'CHEQUE' ? 'رقم الشيك' : 'رقم العملية';
  }

  function init() {
    document.querySelectorAll('.nn-dst-picker').forEach(initPicker);
    (window.DST_METHODS || []).forEach(function (cfg) {
      var sel = document.getElementById(cfg.item);
      if (!sel) return;
      sel.setAttribute('data-dst-ref', cfg.ref || '');
      if (cfg.bank) sel.setAttribute('data-dst-bank', cfg.bank);
      if (cfg.chq) sel.setAttribute('data-dst-chq', cfg.chq);
      sel.addEventListener('change', function () { methodFields(sel); });
      methodFields(sel);
    });
    if (window.apex && apex.jQuery) apex.jQuery(apex.gPageContext$).on('apexbeforepagesubmit', serialize);
    // تجهيز الموقع مبكراً لسرعة تسجيل الوصول
    if (document.querySelector('.nn-dst-checkin')) locate(function () {});
    // التطبيق المثبت على الشاشة الرئيسية
    if ('serviceWorker' in navigator && window.DST_SW) {
      try { navigator.serviceWorker.register(window.DST_SW); } catch (x) { /* اختياري */ }
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
  window.NN_DST = { init: init, serialize: serialize };
})();
