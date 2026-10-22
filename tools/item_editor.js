// بطاقة الصنف: البيانات الأساسية والأسعار والباركود المتعدد، وأقسام حسب ملف الصنف:
// قطع الغيار (رقم OEM، العلامة، التوافق مع المركبات، البدائل)، الأدوية (المادة الفعالة، التركيز، الشكل، الوصفة، التسجيل)،
// والحفظ بطلب واحد SAVE_DOC بكائن JSON يطابق NOONA_INV_PKG.save_item
(function () {
    var root = document.getElementById('nnItem'); if (!root) return;
    var data = function (id) { var el = document.getElementById(id); try { return JSON.parse(el ? el.textContent : 'null'); } catch (e) { return null; } };
    var d = data('nnItemData') || {}, L = data('nnTdLists') || {};
    var esc = function (s) { return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'}[c]; }); };
    var opt = function (v, t, sel) { return '<option value="' + esc(v) + '"' + (String(v) === String(sel == null ? '' : sel) ? ' selected' : '') + '>' + esc(t) + '</option>'; };
    var sel = function (k, opts, v, blank) { return '<select data-k="' + k + '">' + (blank ? opt('', blank) : '') + opts.map(function (o) { return opt(o.v, o.n, v); }).join('') + '</select>'; };
    var inp = function (k, v, type, ph) { return '<input data-k="' + k + '" type="' + (type || 'text') + '" value="' + esc(v) + '"' + (type === 'number' ? ' step="any"' : '') + (ph ? ' placeholder="' + esc(ph) + '"' : '') + '>'; };
    var f = function (label, html, cls) { return '<label class="nn-doc-f ' + (cls || '') + '"><span>' + label + '</span>' + html + '</label>'; };
    var yn = [{v: 'N', n: 'لا'}, {v: 'Y', n: 'نعم'}];
    var types = [{v: 'STOCK', n: 'سلعة مخزنية'}, {v: 'SPARE_PART', n: 'قطعة غيار'}, {v: 'RAW_MATERIAL', n: 'خامة / مادة أولية'},
                 {v: 'SEMI_FINISHED', n: 'منتج نصف مصنع'}, {v: 'FINISHED_GOOD', n: 'منتج تام مصنع'}, {v: 'CONSUMABLE', n: 'مستهلكات'},
                 {v: 'SERVICE', n: 'خدمة'}, {v: 'NON_STOCK', n: 'صنف غير مخزني'}];
    var forms = [{v: 'TABLET', n: 'أقراص'}, {v: 'CAPSULE', n: 'كبسولات'}, {v: 'SYRUP', n: 'شراب'}, {v: 'INJECTION', n: 'حقن'},
                 {v: 'CREAM', n: 'كريم / مرهم'}, {v: 'DROPS', n: 'قطرة'}, {v: 'INHALER', n: 'بخاخ'}, {v: 'SACHET', n: 'أكياس'}, {v: 'OTHER', n: 'أخرى'}];
    var alts = [{v: 'SUBSTITUTE', n: 'بديل'}, {v: 'OEM_EQUIVALENT', n: 'مكافئ أصلي OEM'}, {v: 'GENERIC_EQUIVALENT', n: 'مثيل (نفس المادة)'}, {v: 'UPGRADE', n: 'ترقية'}];
    var status = [{v: 'ACTIVE', n: 'نشط'}, {v: 'INACTIVE', n: 'موقوف'}, {v: 'DRAFT', n: 'مسودة'}, {v: 'OBSOLETE', n: 'متقادم'}];
    var cats = L.cats || [], profOf = function (c) { var x = cats.filter(function (k) { return String(k.v) === String(c); })[0]; return x ? x.p : 'GENERAL'; };
    var bars = (d.barcodes || []).slice(), fit = (d.fitment || []).slice(), alt = (d.alternates || []).slice();

    var h = '<div class="nn-doc-head"><div class="nn-doc-co">' + esc(root.dataset.co) + '</div><div class="nn-doc-title">بطاقة صنف<small>'
          + esc(d.id ? 'الرصيد ' + (d.onhand || 0) + ' | متوسط التكلفة ' + (d.avg || 0) : 'صنف جديد') + '</small></div>'
          + '<div class="nn-doc-no"><span>رقم الصنف</span><b>' + esc(d.no || 'تلقائي') + '</b></div></div>'
          + '<h3 class="nn-sec">البيانات الأساسية</h3><div class="nn-doc-fields">'
          + f('اسم الصنف *', inp('name', d.name), 'is-wide') + f('الاسم بالإنجليزية', inp('nameEn', d.nameEn))
          + f('رقم الصنف (يترك فارغاً للترقيم الآلي)', inp('no', d.no)) + f('الكود / الرمز المختصر', inp('code', d.code))
          + f('نوع الصنف', sel('type', types, d.type || 'STOCK')) + f('الفئة', sel('cat', cats, d.cat, '- اختر -'))
          + f('وحدة القياس', sel('uom', L.uoms || [], d.uom)) + f('الحالة', sel('status', status, d.status || 'ACTIVE'))
          + f('تتبع الدفعات', sel('tracking', [{v: 'NONE', n: 'بدون'}, {v: 'LOT', n: 'برقم الدفعة'}], d.tracking || 'NONE'), 'nn-it-trk')
          + f('تتبع تاريخ الانتهاء', sel('expiry', yn, d.expiry || 'N'), 'nn-it-trk') + f('العلامة التجارية', inp('brand', d.brand))
          + f('صلاحية الصنف بالأيام', inp('shelf', d.shelf, 'number'), 'nn-it-trk') + '</div>'
          + '<h3 class="nn-sec">الباركود</h3><div class="nn-it-bars"></div>'
          + '<div class="nn-it-baradd"><input class="nn-it-bar" placeholder="امسح أو اكتب باركود ثم Enter"><button type="button" class="t-Button nn-it-gen">توليد باركود داخلي</button></div>'
          + '<h3 class="nn-sec">الأسعار والضريبة والربط</h3><div class="nn-doc-fields">'
          + f('سعر البيع', inp('price', d.price, 'number')) + f('السعر شامل الضريبة', sel('incl', yn, d.incl || 'N'))
          + f('الحد الأدنى لسعر البيع', inp('minPrice', d.minPrice, 'number')) + f('ضريبة المبيعات', sel('tax', L.taxes || [], d.tax || 'VAT15'))
          + f('ضريبة المشتريات', sel('ptax', L.taxes || [], d.ptax || d.tax || 'VAT15')) + f('التكلفة المعيارية', inp('cost', d.cost, 'number'))
          + f('مركز التكلفة الافتراضي', sel('cc', L.ccs || [], d.cc, '- من المستودع -')) + f('المستودع الافتراضي', sel('wh', L.whs || [], d.wh, '- الرئيسي -'))
          + f('الحد الأدنى للمخزون', inp('min', d.min, 'number')) + f('الحد الأعلى', inp('max', d.max, 'number')) + f('كمية إعادة الطلب', inp('reorder', d.reorder, 'number'))
          + '</div>'
          + '<div class="nn-it-auto"><h3 class="nn-sec">قطع غيار السيارات</h3><div class="nn-doc-fields">'
          + f('رقم القطعة الأصلي OEM', inp('mpn', d.mpn)) + f('الشركة المصنعة', inp('mfr', d.mfr)) + '</div>'
          + '<h4>التوافق مع المركبات</h4><table class="nn-td-table nn-it-fit"><thead><tr><th>الشركة</th><th>الطراز</th><th>من سنة</th><th>إلى سنة</th><th>المحرك</th><th></th></tr></thead><tbody></tbody></table>'
          + '<button type="button" class="t-Button nn-it-addfit">إضافة مركبة</button>'
          + '<h4>البدائل</h4><table class="nn-td-table nn-it-alt"><thead><tr><th>رقم الصنف / الكود / OEM للبديل</th><th>نوع البدل</th><th></th></tr></thead><tbody></tbody></table>'
          + '<button type="button" class="t-Button nn-it-addalt">إضافة بديل</button></div>'
          + '<div class="nn-it-pharma"><h3 class="nn-sec">الأدوية والمستحضرات</h3><div class="nn-doc-fields">'
          + f('المادة الفعالة (الاسم العلمي)', inp('generic', d.generic)) + f('التركيز', inp('strength', d.strength, 'text', '500mg'))
          + f('الشكل الصيدلاني', sel('form', forms, d.form, '-')) + f('يصرف بوصفة طبية', sel('rx', yn, d.rx || 'N'))
          + f('رقم التسجيل (الهيئة العامة للغذاء والدواء)', inp('reg', d.reg)) + '</div>'
          + '<p class="nn-hint">الأدوية تتبع بالدفعات وتاريخ الانتهاء إلزامياً؛ لا تباع دفعة منتهية، ويصرف الأقرب انتهاءً أولاً.</p></div>'
          + '<div class="nn-doc-foot"><div class="nn-doc-msg" role="alert"></div><div class="nn-doc-actions">'
          + '<button type="button" class="t-Button t-Button--hot nn-it-save">حفظ الصنف</button></div></div>';
    root.innerHTML = h;
    var q = function (k) { return root.querySelector('[data-k="' + k + '"]'); };

    function drawBars() {
        root.querySelector('.nn-it-bars').innerHTML = bars.length ? bars.map(function (b, i) {
            return '<span class="nn-chip">' + esc(b) + '<button type="button" data-bar="' + i + '" aria-label="حذف">×</button></span>'; }).join('')
            : '<em class="nn-hint">لا يوجد باركود؛ يمكن البيع برقم الصنف أو الكود</em>';
    }
    function drawFit() {
        root.querySelector('.nn-it-fit tbody').innerHTML = fit.map(function (r, i) {
            return '<tr>' + ['make', 'model', 'from', 'to', 'engine'].map(function (k) {
                return '<td><input data-fit="' + i + '" data-c="' + k + '" value="' + esc(r[k]) + '"' + (k === 'from' || k === 'to' ? ' type="number"' : '') + '></td>'; }).join('')
                + '<td><button type="button" class="nn-td-del" data-delfit="' + i + '">×</button></td></tr>'; }).join('');
    }
    function drawAlt() {
        root.querySelector('.nn-it-alt tbody').innerHTML = alt.map(function (r, i) {
            return '<tr><td><input data-alt="' + i + '" data-c="no" value="' + esc(r.no) + '"></td><td><select data-alt="' + i + '" data-c="type">'
                 + alts.map(function (a) { return opt(a.v, a.n, r.type || 'SUBSTITUTE'); }).join('') + '</select></td>'
                 + '<td><button type="button" class="nn-td-del" data-delalt="' + i + '">×</button></td></tr>'; }).join('');
    }
    function sync() {
        var p = profOf(q('cat').value || d.cat), t = q('type').value;
        root.querySelector('.nn-it-auto').style.display = (p === 'AUTO_PART' || t === 'SPARE_PART') ? '' : 'none';
        root.querySelector('.nn-it-pharma').style.display = p === 'PHARMA' ? '' : 'none';
        root.querySelectorAll('.nn-it-trk').forEach(function (el) { el.style.display = p === 'PHARMA' || t === 'SERVICE' ? 'none' : ''; });
    }
    drawBars(); drawFit(); drawAlt(); sync();
    root.addEventListener('change', function (e) { if (e.target.dataset.k === 'cat' || e.target.dataset.k === 'type') sync(); });
    root.addEventListener('input', function (e) {
        var t = e.target;
        if (t.dataset.fit != null) fit[+t.dataset.fit][t.dataset.c] = t.value;
        if (t.dataset.alt != null) alt[+t.dataset.alt][t.dataset.c] = t.value;
    });
    var bar = root.querySelector('.nn-it-bar');
    bar.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        e.preventDefault();
        var v = bar.value.trim();
        if (v && bars.indexOf(v) < 0) bars.push(v);
        bar.value = ''; drawBars();
    });
    root.addEventListener('click', function (e) {
        var t = e.target;
        if (t.dataset.bar != null) { bars.splice(+t.dataset.bar, 1); drawBars(); return; }
        if (t.dataset.delfit != null) { fit.splice(+t.dataset.delfit, 1); drawFit(); return; }
        if (t.dataset.delalt != null) { alt.splice(+t.dataset.delalt, 1); drawAlt(); return; }
        if (t.closest('.nn-it-addfit')) { fit.push({make: '', model: ''}); drawFit(); return; }
        if (t.closest('.nn-it-addalt')) { alt.push({no: '', type: 'SUBSTITUTE'}); drawAlt(); return; }
        if (t.closest('.nn-it-gen')) {
            // باركود داخلي EAN-13 يبدأ بـ 20 (نطاق الاستخدام الداخلي) مع رقم التحقق
            var s = '20' + String(Date.now()).slice(-10), sum = 0;
            for (var i = 0; i < 12; i++) sum += (+s[i]) * (i % 2 ? 3 : 1);
            s += (10 - sum % 10) % 10;
            if (bars.indexOf(s) < 0) bars.push(s);
            drawBars(); return;
        }
        if (!t.closest('.nn-it-save')) return;
        var doc = {id: d.id || null, barcodes: bars, fitment: fit.filter(function (r) { return r.make; }), alternates: alt.filter(function (r) { return r.no; })};
        root.querySelectorAll('[data-k]').forEach(function (el) {
            var v = el.value === '' ? null : el.value;
            doc[el.dataset.k] = v != null && (el.type === 'number' || /^(cat|uom|cc|wh)$/.test(el.dataset.k)) ? parseFloat(v) : v;
        });
        fit.forEach(function (r) { r.from = r.from ? +r.from : null; r.to = r.to ? +r.to : null; });
        var msg = root.querySelector('.nn-doc-msg'), btn = root.querySelector('.nn-it-save');
        msg.className = 'nn-doc-msg'; msg.textContent = 'جار الحفظ...'; btn.disabled = true;
        apex.server.process('SAVE_DOC', {p_clob_01: JSON.stringify(doc)}, {dataType: 'json'}).done(function (r) {
            if (r && r.ok) { msg.className = 'nn-doc-msg is-ok'; msg.textContent = 'تم حفظ الصنف'; window.location.href = r.url; }
            else { msg.className = 'nn-doc-msg is-bad'; msg.textContent = (r && r.msg) || 'تعذر الحفظ'; btn.disabled = false; }
        }).fail(function () { msg.className = 'nn-doc-msg is-bad'; msg.textContent = 'تعذر الاتصال بالخادم'; btn.disabled = false; });
    });
})();
