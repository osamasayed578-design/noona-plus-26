/* NOONA PLUS | المشروعات والمقاولات: محررات جدول الكميات وأوامر التغيير ومصفوفة الموازنة وكميات المستخلص وعكس التكاليف.
   البيانات في <script type="application/json"> تولدها الصفحة؛ الحفظ بعملية AJAX واحدة اسمها PRJ (x01 = العملية). */
(function () {
  'use strict';
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };
  var esc = function (s) { return apex.util.escapeHTML(s == null ? '' : String(s)); };
  var num = function (v) { var n = parseFloat(String(v == null ? '' : v).replace(/,/g, '')); return isNaN(n) ? null : n; };
  var fmt = function (n) { return (n || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); };
  var data = function (id) { var e = document.getElementById(id); return e ? JSON.parse(e.textContent || 'null') : null; };

  function call(op, x, clob) {
    var p = { x01: op };
    Object.keys(x || {}).forEach(function (k) { p[k] = x[k]; });
    if (clob !== undefined) p.p_clob_01 = typeof clob === 'string' ? clob : JSON.stringify(clob);
    return apex.server.process('PRJ', p, { dataType: 'json' }).then(function (d) {
      if (d && d.err) { apex.message.clearErrors(); apex.message.showErrors([{ type: 'error', location: 'page', message: d.err, unsafe: false }]); throw d.err; }
      return d;
    });
  }
  function done(msg) {
    apex.message.showPageSuccess(msg);
    setTimeout(function () { location.reload(); }, 700);
  }
  function opts(list, val, empty) {
    return (empty ? '<option value="">' + esc(empty) + '</option>' : '') + (list || []).map(function (o) {
      return '<option value="' + o.v + '"' + (String(o.v) === String(val) ? ' selected' : '') + '>' + esc(o.n) + '</option>';
    }).join('');
  }

  // ------------------------------------------------------------------ جدول الكميات
  function boq() {
    var box = $('#nnPrjBoq'); if (!box) return;
    var d = data('nnPrjBoqData'), lists = data('nnPrjLists') || {}, locked = box.dataset.locked === 'Y';
    function row(r) {
      r = r || {};
      return '<tr data-id="' + (r.id || '') + '"><td><input class="b-code" value="' + esc(r.code) + '" size="6"' + (locked ? ' readonly' : '') + '></td>'
        + '<td><input class="b-d" value="' + esc(r.d) + '" size="40"></td>'
        + '<td><select class="b-u">' + opts(lists.uoms, r.u, '-') + '</select></td>'
        + '<td><input class="b-q n" value="' + (r.q == null ? '' : r.q) + '" size="8"' + (locked ? ' readonly' : '') + '></td>'
        + '<td><input class="b-r n" value="' + (r.r == null ? '' : r.r) + '" size="8"' + (locked ? ' readonly' : '') + '></td>'
        + '<td class="n b-a"></td><td><select class="b-w">' + opts(lists.wbs, r.w, '-') + '</select></td>'
        + '<td>' + (locked || r.x > 0 ? '' : '<button type="button" class="nn-prj-x" title="حذف">&times;</button>') + '</td></tr>';
    }
    box.innerHTML = '<table class="nn-prj-t nn-prj-edit"><thead><tr><th>البند</th><th>الوصف</th><th>الوحدة</th><th>الكمية</th><th>سعر الوحدة</th>'
      + '<th>القيمة</th><th>بند العمل</th><th></th></tr></thead><tbody>' + (d || []).map(row).join('') + '</tbody>'
      + '<tfoot><tr><td colspan="5">الإجمالي</td><td class="n b-t"></td><td colspan="2"></td></tr></tfoot></table>'
      + '<div class="nn-prj-actions">' + (locked ? '<span class="nn-hint">العقد معتمد: يعدل الوصف والوحدة وبند العمل فقط؛ الكميات والأسعار والبنود الجديدة بأمر تغيير</span>'
        : '<button type="button" class="t-Button nn-b-add">+ بند</button>') + ' <button type="button" class="t-Button t-Button--hot nn-b-save">حفظ جدول الكميات</button></div>';
    var tb = $('tbody', box);
    function total() {
      var t = 0;
      $$('tr', tb).forEach(function (tr) { var a = (num($('.b-q', tr).value) || 0) * (num($('.b-r', tr).value) || 0); t += a; $('.b-a', tr).textContent = fmt(a); });
      $('.b-t', box).textContent = fmt(t);
    }
    box.addEventListener('input', total);
    box.addEventListener('click', function (e) {
      if (e.target.classList.contains('nn-prj-x')) { e.target.closest('tr').remove(); total(); }
      if (e.target.classList.contains('nn-b-add')) { tb.insertAdjacentHTML('beforeend', row({})); $('tr:last-child .b-code', tb).focus(); }
      if (e.target.classList.contains('nn-b-save')) {
        var lines = $$('tr', tb).map(function (tr) {
          return { id: num(tr.dataset.id), code: $('.b-code', tr).value.trim(), d: $('.b-d', tr).value.trim(), u: num($('.b-u', tr).value),
                   q: num($('.b-q', tr).value), r: num($('.b-r', tr).value), w: num($('.b-w', tr).value) };
        });
        call('BOQ', { x02: box.dataset.contract }, lines).then(function () { done('تم حفظ جدول الكميات'); });
      }
    });
    total();
  }

  // ------------------------------------------------------------------ أمر التغيير
  function vo() {
    var box = $('#nnPrjVo'); if (!box) return;
    var items = data('nnPrjBoqData') || [];
    function row() {
      return '<tr><td><select class="v-b"><option value="">بند جديد</option>' + items.map(function (b) {
        return '<option value="' + b.id + '" data-r="' + b.r + '">' + esc(b.code + ' - ' + b.d) + '</option>'; }).join('') + '</select></td>'
        + '<td><input class="v-code" size="6" placeholder="رقم"></td><td><input class="v-d" size="30" placeholder="وصف البند الجديد"></td>'
        + '<td><input class="v-q n" size="8" placeholder="± الكمية"></td><td><input class="v-r n" size="8" placeholder="السعر"></td>'
        + '<td><button type="button" class="nn-prj-x">&times;</button></td></tr>';
    }
    box.innerHTML = '<div class="nn-prj-form"><label>الوصف <input class="v-desc" size="50"></label><label>النوع <select class="v-type">'
      + '<option value="ADDITION">إضافة</option><option value="OMISSION">حذف</option><option value="SUBSTITUTION">استبدال</option>'
      + '<option value="TIME_EXTENSION">تمديد مدة</option><option value="PRICE_ADJUSTMENT">تعديل سعر</option></select></label>'
      + '<label>الأثر الزمني (يوم) <input class="v-days n" size="5"></label><label>مرجع موافقة العميل <input class="v-ref" size="15"></label></div>'
      + '<table class="nn-prj-t nn-prj-edit"><thead><tr><th>البند</th><th>رقم جديد</th><th>الوصف</th><th>تغير الكمية</th><th>السعر</th><th></th></tr></thead>'
      + '<tbody>' + row() + '</tbody></table><div class="nn-prj-actions"><button type="button" class="t-Button nn-v-add">+ سطر</button> '
      + '<button type="button" class="t-Button t-Button--hot nn-v-save">تسجيل أمر التغيير</button></div>';
    var tb = $('tbody', box);
    box.addEventListener('change', function (e) {
      if (e.target.classList.contains('v-b')) {
        var tr = e.target.closest('tr'), o = e.target.selectedOptions[0];
        $('.v-code', tr).disabled = $('.v-d', tr).disabled = !!e.target.value;
        if (e.target.value && !$('.v-r', tr).value) $('.v-r', tr).value = o.dataset.r;
      }
    });
    box.addEventListener('click', function (e) {
      if (e.target.classList.contains('nn-prj-x')) e.target.closest('tr').remove();
      if (e.target.classList.contains('nn-v-add')) tb.insertAdjacentHTML('beforeend', row());
      if (e.target.classList.contains('nn-v-save')) {
        var doc = { contract: num(box.dataset.contract), desc: $('.v-desc', box).value.trim(), type: $('.v-type', box).value,
                    days: num($('.v-days', box).value), ref: $('.v-ref', box).value.trim(),
                    lines: $$('tr', tb).map(function (tr) {
                      return { b: num($('.v-b', tr).value), code: $('.v-code', tr).value.trim(), d: $('.v-d', tr).value.trim(),
                               q: num($('.v-q', tr).value), r: num($('.v-r', tr).value) }; }) };
        call('VO', {}, doc).then(function () { done('تم تسجيل أمر التغيير؛ اعتمده ليضاف للعقد'); });
      }
    });
  }

  // ------------------------------------------------------------------ مصفوفة الموازنة
  function budget() {
    var box = $('#nnPrjBudget'); if (!box) return;
    var lists = data('nnPrjLists') || {}, cur = data('nnPrjBudgetData') || [];
    var types = [['MATERIAL', 'مواد'], ['LABOR', 'عمالة'], ['EQUIPMENT', 'معدات'], ['SUBCONTRACT', 'مقاولو باطن'], ['OVERHEAD', 'غير مباشرة'], ['OTHER', 'أخرى']];
    var val = function (w, t) { var x = cur.filter(function (c) { return String(c.w) === String(w) && c.t === t; })[0]; return x ? x.a : ''; };
    box.innerHTML = '<table class="nn-prj-t nn-prj-edit"><thead><tr><th>بند العمل</th>' + types.map(function (t) { return '<th>' + t[1] + '</th>'; }).join('')
      + '<th>الإجمالي</th></tr></thead><tbody>' + (lists.wbs || []).map(function (w) {
        return '<tr data-w="' + w.v + '"><td>' + esc(w.n) + '</td>' + types.map(function (t) {
          return '<td><input class="n" data-t="' + t[0] + '" size="9" value="' + val(w.v, t[0]) + '"></td>'; }).join('') + '<td class="n r-t"></td></tr>';
      }).join('') + '</tbody><tfoot><tr><td>الإجمالي</td>' + types.map(function (t) { return '<td class="n c-' + t[0] + '"></td>'; }).join('')
      + '<td class="n g-t"></td></tr></tfoot></table><div class="nn-prj-form"><label>سبب المراجعة <input class="b-reason" size="40"></label></div>'
      + '<div class="nn-prj-actions"><button type="button" class="t-Button t-Button--hot nn-bu-save">اعتماد الموازنة (خط أساس جديد)</button></div>';
    function total() {
      var g = 0, cols = {};
      $$('tbody tr', box).forEach(function (tr) {
        var r = 0;
        $$('input', tr).forEach(function (i) { var v = num(i.value) || 0; r += v; cols[i.dataset.t] = (cols[i.dataset.t] || 0) + v; });
        $('.r-t', tr).textContent = fmt(r); g += r;
      });
      types.forEach(function (t) { $('.c-' + t[0], box).textContent = fmt(cols[t[0]]); });
      $('.g-t', box).textContent = fmt(g);
    }
    box.addEventListener('input', total);
    box.addEventListener('click', function (e) {
      if (!e.target.classList.contains('nn-bu-save')) return;
      var lines = [];
      $$('tbody tr', box).forEach(function (tr) {
        $$('input', tr).forEach(function (i) { var v = num(i.value); if (v) lines.push({ w: num(tr.dataset.w), t: i.dataset.t, a: v }); });
      });
      call('BUDGET', { x02: box.dataset.project, x03: $('.b-reason', box).value }, lines).then(function () { done('تم اعتماد الموازنة'); });
    });
    total();
  }

  // ------------------------------------------------------------------ كميات المستخلص
  function claim() {
    var box = $('#nnPrjClaim'); if (!box) return;
    var c = data('nnPrjClaimData'); if (!c) return;
    var edit = c.status === 'DRAFT';
    function summary(c) {
      var mos = (c.mos || 0) - (c.mosPrev || 0);
      var rows = [['قيمة الفترة', c.cur], [mos >= 0 ? 'مواد مشونة بالموقع' : 'استرداد مواد مشونة ركبت', mos], ['المحتجز', -c.ret],
                  ['استرداد الدفعة المقدمة', -c.rec], ['خصومات أخرى', -c.other],
                  ['غرامة تأخير' + (c.penaltyDays ? ' (' + c.penaltyDays + ' يوم)' : ''), -(c.penalty || 0)], ['الضريبة', c.tax]];
      return '<table class="nn-prj-cert-sum">' + (c.kind === 'PROGRESS' ? '<tr><th>التراكمي حتى تاريخه</th><td>' + fmt(c.gross) + '</td></tr><tr><th>المعتمد سابقاً</th><td>('
        + fmt(c.prev) + ')</td></tr>' : '') + rows.filter(function (r) { return r[1]; }).map(function (r) {
          return '<tr><th>' + r[0] + '</th><td>' + (r[1] < 0 ? '(' + fmt(-r[1]) + ')' : fmt(r[1])) + '</td></tr>'; }).join('')
        + '<tr class="is-total"><th>' + (c.final === 'Y' ? 'صافي المستخلص الختامي' : 'الصافي') + '</th><td>' + fmt(c.net) + '</td></tr></table>';
    }
    function render(c) {
      var h = '';
      if (c.kind === 'PROGRESS') {
        h += '<table class="nn-prj-t nn-prj-edit"><thead><tr><th>البند</th><th>الوصف</th><th>كمية العقد</th><th>السابقة</th><th>التراكمية حتى تاريخه</th>'
          + '<th>الحالية</th><th>السعر</th><th>قيمة الفترة</th></tr></thead><tbody>' + (c.lines || []).map(function (l) {
            return '<tr data-b="' + l.b + '"><td>' + esc(l.code) + '</td><td>' + esc(l.d) + '</td><td class="n">' + l.max + '</td><td class="n">' + l.prev + '</td><td>'
              + (edit ? '<input class="c-q n" size="9" value="' + l.q + '" data-prev="' + l.prev + '" data-max="' + l.max + '">' : l.q) + '</td><td class="n c-cur">'
              + Math.round((l.q - l.prev) * 1000) / 1000 + '</td><td class="n">' + fmt(l.r) + '</td><td class="n">' + fmt(l.cur) + '</td></tr>';
          }).join('') + '</tbody></table>';
      }
      h += '<div class="nn-prj-form">' + (edit ? '<label>من <input type="date" class="c-from" value="' + c.from + '"></label><label>إلى <input type="date" class="c-to" value="'
        + c.to + '"></label>' + (c.kind === 'PROGRESS'
          ? '<label>خصومات أخرى <input class="c-other n" size="9" value="' + (c.other || 0) + '"></label>'
            + '<label>أيام التأخير' + (c.dailyPenalty ? ' (' + fmt(c.dailyPenalty) + ' يومياً)' : '') + ' <input class="c-pdays n" size="5" value="' + (c.penaltyDays || '') + '"></label>'
            + '<label>أو مبلغ الغرامة <input class="c-pen n" size="9" value=""></label>'
            + '<label>المواد المشونة بالموقع حتى تاريخه <input class="c-mos n" size="10" value="' + (c.mos || 0) + '"></label>'
            + '<label class="nn-chk"><input type="checkbox" class="c-final"' + (c.final === 'Y' ? ' checked' : '') + '> المستخلص الختامي</label>'
          : '<label>المبلغ قبل الضريبة <input class="c-amount n" size="11" value="' + c.cur + '"></label>')
        + '<button type="button" class="t-Button nn-c-save">حساب وحفظ</button>' : '') + '</div>' + summary(c);
      box.innerHTML = h;
    }
    box.addEventListener('input', function (e) {
      if (!e.target.classList.contains('c-q')) return;
      var tr = e.target.closest('tr'), q = num(e.target.value) || 0;
      $('.c-cur', tr).textContent = Math.round((q - num(e.target.dataset.prev)) * 1000) / 1000;
      e.target.classList.toggle('is-bad', q < num(e.target.dataset.prev) || (num(e.target.dataset.max) > 0 && q > num(e.target.dataset.max)));
    });
    box.addEventListener('click', function (e) {
      if (!e.target.classList.contains('nn-c-save')) return;
      var doc = { id: c.id, from: $('.c-from', box).value, to: $('.c-to', box).value,
                  lines: $$('.nn-prj-edit tbody tr', box).map(function (tr) { return { b: num(tr.dataset.b), q: num($('.c-q', tr).value) }; }) };
      if ($('.c-other', box)) doc.other = num($('.c-other', box).value) || 0;
      if ($('.c-pdays', box)) doc.penaltyDays = num($('.c-pdays', box).value) || 0;
      if ($('.c-pen', box) && $('.c-pen', box).value !== '') doc.penalty = num($('.c-pen', box).value) || 0;
      if ($('.c-mos', box)) doc.mos = num($('.c-mos', box).value) || 0;
      if ($('.c-final', box)) doc.final = $('.c-final', box).checked ? 'Y' : 'N';
      if ($('.c-amount', box)) doc.amount = num($('.c-amount', box).value);
      call('CLAIM', {}, doc).then(function (d) { c = d; render(c); apex.message.showPageSuccess('تم حساب المستخلص وحفظه'); });
    });
    render(c);
  }

  // ------------------------------------------------------------------ عكس تكلفة
  document.addEventListener('click', function (e) {
    var b = e.target.closest('.nn-prj-rev'); if (!b) return;
    var r = window.prompt('سبب عكس التكلفة'); if (!r) return;
    call('REV', { x02: b.dataset.id, x03: r }).then(function () { done('تم عكس التكلفة وقيدها'); });
  });

  boq(); vo(); budget(); claim();
})();
