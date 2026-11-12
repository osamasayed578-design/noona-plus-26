/* NOONA: إثبات التسليم من هاتف السائق
   - صورة التسليم من الكاميرا (تصغر إلى 1280 بكسل JPEG قبل الإرسال)
   - توقيع المستلم بالإصبع على لوحة (PNG)
   - الموقع الحالي
   - الإرسال بـ AJAX (p_clob_01) لأن الصورة أكبر من حد عناصر الصفحة */
(function () {
  'use strict';
  var photo = null, signed = false, GEO = null;

  function locate() {
    if (!navigator.geolocation) return;
    navigator.geolocation.getCurrentPosition(function (p) { GEO = { lat: p.coords.latitude, lng: p.coords.longitude }; },
      function () {}, { enableHighAccuracy: true, timeout: 9000, maximumAge: 60000 });
  }

  function initPhoto() {
    var inp = document.getElementById('podPhoto'), prev = document.getElementById('podPreview');
    if (!inp) return;
    inp.addEventListener('change', function () {
      var f = inp.files && inp.files[0];
      if (!f) return;
      var img = new Image(), url = URL.createObjectURL(f);
      img.onload = function () {
        var max = 1280, w = img.width, h = img.height, k = Math.min(1, max / Math.max(w, h));
        var c = document.createElement('canvas'); c.width = Math.round(w * k); c.height = Math.round(h * k);
        c.getContext('2d').drawImage(img, 0, 0, c.width, c.height);
        photo = c.toDataURL('image/jpeg', 0.7);
        URL.revokeObjectURL(url);
        if (prev) { prev.src = photo; prev.style.display = 'block'; }
      };
      img.src = url;
    });
  }

  function initSign() {
    var c = document.getElementById('podSign');
    if (!c) return;
    var ctx = c.getContext('2d'), drawing = false, last = null;
    function size() {
      var r = c.getBoundingClientRect(), d = window.devicePixelRatio || 1;
      c.width = r.width * d; c.height = r.height * d;
      ctx.setTransform(d, 0, 0, d, 0, 0); ctx.lineWidth = 2.4; ctx.lineCap = 'round'; ctx.strokeStyle = '#111';
      ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, r.width, r.height);
      signed = false;
    }
    function pt(e) { var r = c.getBoundingClientRect(); return { x: e.clientX - r.left, y: e.clientY - r.top }; }
    c.addEventListener('pointerdown', function (e) { drawing = true; last = pt(e); c.setPointerCapture(e.pointerId); });
    c.addEventListener('pointermove', function (e) {
      if (!drawing) return;
      var p = pt(e); ctx.beginPath(); ctx.moveTo(last.x, last.y); ctx.lineTo(p.x, p.y); ctx.stroke(); last = p; signed = true;
    });
    ['pointerup', 'pointercancel', 'pointerleave'].forEach(function (t) { c.addEventListener(t, function () { drawing = false; }); });
    var clr = document.getElementById('podClear');
    if (clr) clr.addEventListener('click', size);
    size();
  }

  function save(btn) {
    var it = function (n) { return window.apex && apex.item(n).node ? apex.item(n).getValue() : null; };
    var c = document.getElementById('podSign');
    if (!photo && !signed) { apex.message.alert('التقط صورة التسليم أو خذ توقيع المستلم.'); return; }
    if (!it('P72_RECEIVER')) { apex.message.alert('اكتب اسم المستلم.'); return; }
    var doc = {
      trip: +it('P72_TRIP'), order: +it('P72_ORDER'), receiver: it('P72_RECEIVER'), phone: it('P72_PHONE'),
      qty: it('P72_QTY') ? +it('P72_QTY') : null, damage: it('P72_DAMAGE'), notes: it('P72_NOTES'),
      photo: photo, signature: signed ? c.toDataURL('image/png') : null, lat: GEO && GEO.lat, lng: GEO && GEO.lng
    };
    btn.disabled = true; btn.innerHTML = '<span class="fa fa-spinner fa-spin"></span> جارٍ الحفظ…';
    apex.server.process('POD', { p_clob_01: JSON.stringify(doc) }, { dataType: 'json' }).then(function (r) {
      if (r && r.err) { apex.message.alert(r.err); btn.disabled = false; btn.textContent = 'حفظ وتسليم'; return; }
      window.location.href = btn.getAttribute('data-back');
    }, function () { apex.message.alert('تعذر الحفظ؛ تحقق من الاتصال.'); btn.disabled = false; btn.textContent = 'حفظ وتسليم'; });
  }

  function init() {
    initPhoto(); initSign(); locate();
    var b = document.getElementById('podSave');
    if (b) b.addEventListener('click', function () { save(b); });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
