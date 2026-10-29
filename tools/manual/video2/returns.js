/* مشاهد الإدخال الحقيقي داخل الجولة الشاملة: المرتجعات (مشتريات، مبيعات، نقطة البيع، مواد التصنيع).
   كل مشهد يأخذ (v, screen, tools) ويُستدعى بدلاً من العرض العادي لشاشته. */
'use strict';

// يفتح أول فاتورة مرحّلة (ليست مرتجعاً) من قائمة الفواتير
async function openPostedInvoice(v, listAlias, note) {
  const { page } = v;
  await v.go(listAlias);
  const href = await page.evaluate(() => {
    const rows = [...document.querySelectorAll('.a-IRR-table tr')].filter((r) => r.querySelector('td a'));
    // فاتورة آجلة أولاً: المرتجع يخفض رصيد الطرف دون صرف نقدي
    const ok = (x) => !/مرتجع|ملغ|مسودة/.test(x.textContent);
    const r = rows.find((x) => ok(x) && /آجل/.test(x.textContent)) || rows.find(ok) || rows[0];
    if (!r) return null;
    const a = r.querySelector('td a'); a.classList.add('nnv-hl'); a.scrollIntoView({ block: 'center' }); return a.href;
  });
  if (!href) return false;
  await v.say(note, 3800);
  await page.goto(href); await v.settle();
  return true;
}

async function tradeReturn(v, s, t, o) {
  const { page } = v;
  await v.say(`<b>${s.title}</b>: ${s.purpose}`);
  await v.say(o.why, 4500);
  if (!await openPostedInvoice(v, o.list, `من <b>${o.listName}</b> نفتح فاتورة مرحّلة`)) { await t.open(s); await t.explain(s); return; }
  await v.say('الفاتورة الأصلية للقراءة فقط بعد الترحيل؛ المرتجع يتم بمستند مستقل مرتبط بها', 3800);
  const btn = page.getByRole('button', { name: 'مرتجع من الفاتورة' }).or(page.getByRole('link', { name: 'مرتجع من الفاتورة' })).first();
  if (!await btn.count()) { await v.say('هذه الفاتورة ليس لها كمية قابلة للإرجاع؛ نعرض شاشة المرتجع', 3000); await t.open(s); await t.explain(s); return; }
  await v.click(btn, 'زر <b>مرتجع من الفاتورة</b> يفتح المرتجع بسطور الفاتورة');
  await v.wait(1500);
  await v.say('لكل سطر: <b>الكمية المباعة</b>، و<b>المرتجع سابقاً</b>، و<b>كمية المرتجع الآن</b> (لا تتجاوز المتبقي)، والسعر من الفاتورة', 5000);
  const reason = page.locator('[data-k="reason"]').first();
  if (await reason.count()) await v.type(reason, o.reason, '<b>سبب المرتجع</b> إلزامي ويظهر في المستند والقيد');
  const q = page.locator('input[data-c="q"]').first();
  if (await q.count()) {
    await v.type(q, '1', 'نرجع <b>وحدة واحدة</b> من السطر الأول');
    await page.keyboard.press('Tab'); await v.wait(1200);
    await v.say('الإجماليات والضريبة تحسب فوراً بنفس سعر وضريبة الفاتورة الأصلية', 3800);
  }
  const post = page.locator('[data-a="POST"]').first();
  if (await post.count()) {
    await v.click(post, `<b>ترحيل المرتجع</b>: ${o.post}`, false);
    await v.wait(3000); await v.settle();
    const msg = (await page.locator('.nn-doc-msg, #t_Alert_Success, #t_Alert_Notification').allInnerTexts().catch(() => [])).join(' ').replace(/\s+/g, ' ').slice(0, 160);
    console.log('  return: ' + msg + ' | ' + page.url().replace(/session=\d+/, ''));
    await v.say(`تم ترحيل المرتجع برقم مستقل؛ ${o.after}`, 5000);
  }
  if (o.check) await o.check(v);
}

module.exports = {
  // ---------------------------------------------------------------- مرتجع المشتريات
  'scm-preturn': (v, s, t) => tradeReturn(v, s, t, {
    list: 'PURCHASES', listName: 'فواتير المشتريات والمرتجعات',
    why: 'مرتجع المشتريات = <b>إشعار مدين</b> للمورد: تخرج الكمية من المخزون بتكلفتها، ويخفض رصيد المورد والضريبة المستردة',
    reason: 'صنف تالف عند الاستلام', post: 'يخرج الكميات من المخزون ويخفض حساب المورد ويعكس ضريبة المدخلات',
    after: 'يظهر في قائمة الفواتير بنوع «مرتجع»، وفي كشف حساب المورد وبطاقة الصنف وسجل الضريبة',
    check: async (v) => {
      await v.go('PURCHASES');
      await v.say('في القائمة: المرتجع بنوع <b>مرتجع</b> وبمبلغه، مرتبطاً بالفاتورة الأصلية', 4000);
    },
  }),
  // ---------------------------------------------------------------- مرتجع المبيعات
  'pos-return': (v, s, t) => tradeReturn(v, s, t, {
    list: 'INVOICES', listName: 'فواتير المبيعات والمرتجعات',
    why: 'مرتجع المبيعات = <b>إشعار دائن</b> للعميل: تعود الأصناف للمخزون بتكلفة البيع الأصلية، ويخفض رصيد العميل والإيراد والضريبة',
    reason: 'العميل أعاد عبوة غير مطابقة', post: 'يعيد الأصناف للمخزون ويخفض حساب العميل (أو يرد له نقداً) ويعكس ضريبة المخرجات',
    after: 'يصدر إشعاراً دائناً إلكترونياً برقم مستقل ورمز QR (فاتورة إلكترونية) مرتبطاً بالفاتورة الأصلية',
    check: async (v) => {
      await v.go('INVOICES');
      await v.say('في القائمة: الإشعار الدائن بنوع <b>مرتجع</b>؛ ويخفض المتبقي على العميل في كشف حسابه وأعمار ديونه', 4500);
    },
  }),
  // ---------------------------------------------------------------- مرتجع نقطة البيع (F8) بعد بيع حقيقي
  'pos-screen': async (v, s, t) => {
    const { page } = v;
    await t.open(s);
    await v.say(`<b>شاشة البيع</b>: ${s.purpose}`);
    const shiftBtn = page.getByRole('button', { name: 'فتح الوردية' });
    if (await shiftBtn.count()) {
      await v.type('.nn-pos-float', '300', '<b>فتح الوردية</b> بالنقد الافتتاحي');
      await v.click(shiftBtn, null, false); await v.wait(1500);
    }
    await v.type('#nnPosScan', 'زيت', 'نبيع أولاً: امسح الباركود أو اكتب الاسم ثم Enter');
    await page.keyboard.press('Enter'); await v.wait(1800);
    const pick = page.locator('.nn-pos-results button, .nn-pos-res button').first();
    if (await pick.count()) { await v.click(pick, 'نختار الصنف من النتائج', false); await v.wait(1000); }
    await v.click(page.locator('.nn-pos-cart button').filter({ hasText: '+' }).first(), 'كمية <b>2</b> بزر +', false);
    await page.keyboard.press('F9'); await v.wait(1200);
    await v.say('<b>الدفع (F9)</b>: نقدي', 2500);
    const ap = page.locator('.nn-pos-autoprint'); if (await ap.count()) await ap.uncheck().catch(() => {});
    await v.click(page.getByRole('button', { name: /تأكيد البيع/ }), '<b>تأكيد البيع</b>', false);
    await v.wait(2500);
    const rno = await page.evaluate(() => { const m = document.body.innerText.match(/إيصال\s*([A-Z]{1,5}-[\d-]*\d)/); return m ? m[1] : null; });
    console.log('  receipt: ' + rno);
    await v.say(`تم البيع بإيصال رقم <b>${rno || ''}</b>`, 3000);
    const okb = page.locator('.nn-pos-done [data-do="close"], .nn-pos-done button').first();
    if (await okb.count()) await okb.click().catch(() => {});
    await v.wait(800);
    // المرتجع
    await v.setStep('مرتجع نقطة البيع (F8)');
    await v.say('العميل أعاد صنفاً: <b>المرتجع (F8)</b> برقم الإيصال؛ يرد المبلغ من درج الوردية', 4500);
    await page.keyboard.press('F8'); await v.wait(1200);
    if (rno) {
      await v.type('.nn-pos-rno', rno, 'رقم الإيصال (أو امسح الرمز من الإيصال) ثم Enter');
      await page.keyboard.press('Enter'); await v.wait(2000);
      await v.say('سطور الإيصال: المباع، والمرتجع سابقاً، والكمية المرتجعة الآن', 3800);
      const rl = page.locator('[data-rl]').first();
      if (await rl.count()) await v.type(rl, '1', 'نرجع <b>عبوة واحدة</b>');
      await v.click(page.getByRole('button', { name: /تنفيذ المرتجع/ }), '<b>تنفيذ المرتجع ورد المبلغ</b>: نقداً من الدرج (أو على الحساب للبيع الآجل)', false);
      await v.wait(2500);
      const res = await page.evaluate(() => { const d = document.querySelector('.nn-pos-done'); return d ? d.textContent.replace(/\s+/g, ' ').trim() : (document.querySelector('.nn-pos-msg') || {}).textContent; });
      console.log('  pos return: ' + res);
      await v.say('تم المرتجع: إيصال مرتجع برقم مستقل، والمخزون عاد، والنقد المردود يخصم من النقد المتوقع في تقرير الوردية', 5500);
      const ok2 = page.locator('.nn-pos-done [data-do="close"]').first(); if (await ok2.count()) await ok2.click().catch(() => {});
    }
    await t.explain({ ...s, steps: null, notes: s.notes, alt: s.alt });
  },
  // ---------------------------------------------------------------- إرجاع خامات أمر إنتاج للمستودع
  'mfg-order': async (v, s, t) => {
    const { page } = v;
    await v.go('ORDERS');
    const href = await page.evaluate(() => {
      const rows = [...document.querySelectorAll('.a-IRR-table tr')].filter((r) => r.querySelector('td a'));
      const r = rows.find((x) => /قيد التنفيذ|مطلق|IN_PROGRESS|RELEASED/.test(x.textContent)) || rows[0];
      if (!r) return null; const a = r.querySelector('td a'); a.classList.add('nnv-hl'); a.scrollIntoView({ block: 'center' }); return a.href;
    });
    if (!href) { await t.open(s); await t.explain(s); return; }
    await v.say('من <b>أوامر الإنتاج</b> نفتح أمراً قيد التنفيذ', 3200);
    await page.goto(href); await v.settle();
    await v.say(`<b>${s.title}</b>: ${s.purpose}`);
    await v.say('تبويب <b>الخامات</b>: المطلوب والمصروف والمرتجع والمتبقي ورصيد المستودع والتكلفة الفعلية لكل مادة', 4500);
    const ret = page.locator('input[data-ret]:not([disabled])').first();
    if (await ret.count()) {
      await v.say('<b>مرتجع الخامات</b>: ما زاد عن حاجة الأمر يعاد للمستودع بنفس تكلفة صرفه، ويخفض تكلفة الأمر', 4800);
      const retCell = async () => page.evaluate(() => { const i = document.querySelector('input[data-ret]:not([disabled])'); const tr = i && i.closest('tr');
        return tr ? tr.children[4].textContent.trim() : null; });
      const before = await retCell();
      await v.type(ret, '1', 'كمية الإرجاع في عمود <b>إرجاع</b>');
      await v.click(page.locator('[data-do="RETURN"]').first(), '<b>إرجاع الكميات المحددة</b>', false);
      await v.wait(2500); await v.settle();
      await page.evaluate(() => { const t = document.querySelector('[data-pane="mat"] table'); if (t) t.scrollIntoView({ block: 'center' }); });
      const after = await retCell();
      console.log('  mfg return: ret ' + before + ' -> ' + after);
      await page.evaluate(() => { const i = document.querySelector('input[data-ret]'); const tr = i && i.closest('tr'); if (tr) tr.children[4].classList.add('nnv-hl'); });
      await v.say('تم: عمود <b>المرتجع</b> زاد والمتبقي عاد، وقيد عكسي يخفض حساب الإنتاج تحت التشغيل', 4500);
    } else {
      await v.say('لا توجد كمية مصروفة قابلة للإرجاع في هذا الأمر؛ الإرجاع يتاح بعد الصرف', 3500);
    }
    for (const [tab, note] of [['ops', '<b>العمليات</b>: تسجيل وقت الإعداد والتشغيل والكمية الجيدة والهالك لكل عملية'],
      ['out', '<b>الإنتاج والجودة</b>: استلام المنتج التام وفحص الجودة (قبول، رفض، قبول بشرط)'],
      ['cost', '<b>التكلفة والقيود</b>: المعيارية مقابل الفعلية والانحرافات وقيود الأمر']]) {
      const b = page.locator(`[data-tab="${tab}"]`).first();
      if (await b.count()) { await v.click(b, note, false); await v.wait(2500); }
    }
    for (const [n, d] of Object.entries(s.buttons || {})) await v.say(`زر <b>${n}</b>: ${d}`);
  },
};
