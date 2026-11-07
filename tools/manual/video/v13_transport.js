/* فيديو النقل والشحن والترحيل (قصير): أمر شحن لعميل بالتسعير من التعرفة ← تأكيد ← رحلة جديدة بعربة وسائق وتحميل الأمر ←
   تحرك ← وصول ← تسليم بالكمية والمستلم ← إقفال الرحلة ← فوترة الترحيل ← لوحة الحركة والتقارير والتحليلات.
   يعمل على مؤسسة فيها إعداد النقل (مدن ومسارات وعربات وسائقون وتعرفة)، مثل المؤسسة التجريبية بعد demo_transport.
   PW_PATH=... NOONA_VADMIN=ADMIN NOONA_VPWD=... node tools/manual/video/v13_transport.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN || 'ADMIN', PWD = process.env.NOONA_VPWD;

(async () => {
  const v = await video('noona_trn', out, 'v13_transport');
  const { page } = v;
  const opts = (sel) => page.locator(sel + ' option').evaluateAll((os) => os.map((o) => ({ v: o.value, t: o.textContent.trim() })).filter((o) => o.v));
  async function pickOpt(sel, pred, note) {
    const o = (await opts(sel)).find(pred);
    if (o) await v.select(sel, o.t, note);
    return o;
  }
  const log = (m) => console.log(m);
  const msg = async (step) => { const a = await v.alerts(); log(`${step}: ${a || '(no message)'}`); if (/ORA-|NOONA-|خطأ/.test(a)) log('ERR ' + step); return a; };

  await page.goto('http://localhost:' + (process.env.NOONA_PORT || 8090) + '/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('النقل والشحن والترحيل', ['أمر الشحن بالتسعير من التعرفة · الرحلة بالعربة والسائق',
    'الحركة والتسليم والعجز · فوترة الترحيل بقيد تلقائي · التقارير والتحليلات'], 5000, 'الفيديو القصير · إدخال حقيقي سريع · نونا بلس');
  await v.setStep('1 · لوحة الحركة');
  await v.login(ADMIN, PWD, 'الدخول إلى تطبيق <b>النقل والشحن</b>');
  await v.say('<b>لوحة الحركة</b>: الرحلات الجارية والعربات والسائقون والبلاغات المفتوحة، وإجراءات سريعة', 4500);

  // ------------------------------------------------ 1) أمر الشحن
  await v.setStep('2 · أمر شحن جديد');
  await v.click('أمر شحن جديد', '<b>أمر شحن جديد</b>');
  await pickOpt('#P11_CUST', () => true, '<b>العميل</b>');
  await v.type('#P11_REF', 'PO-7781', 'مرجع العميل (رقم طلبه)');
  const from = await pickOpt('#P11_FROM', () => true, '<b>مكان التحميل</b>');
  await pickOpt('#P11_TO', (o) => !from || o.v !== from.v, '<b>مكان التفريغ</b>');
  await pickOpt('#P11_CARGO', (o) => /عامة/.test(o.t), '<b>نوع الشحنة</b>: بضائع عامة');
  await v.type('#P11_DESC', 'مواد غذائية معبأة', 'وصف البضاعة');
  await v.type('#P11_QTY', '12', '<b>الكمية</b>: 12');
  await v.say('السعر يطبق تلقائياً من <b>أخص تعرفة سارية</b>: للعميل، ثم للمسار، ثم لنوع الشحنة', 4500);
  await v.click('حفظ وتسعير', '<b>حفظ وتسعير</b>');
  await msg('save order');
  await page.locator('#P11_PRICE').scrollIntoViewIfNeeded().catch(() => {});
  await v.say('<b>الترحيل المحسوب</b>: الأساس × السعر + الرسوم الأخرى', 4000);
  await v.click('تأكيد الأمر', '<b>تأكيد الأمر</b>: يصبح جاهزاً للتحميل على رحلة');
  await msg('confirm order');

  // ------------------------------------------------ 2) الرحلة
  await v.setStep('3 · رحلة جديدة');
  await v.nav('رحلة جديدة');
  await v.say('يتحقق النظام من توفر العربة والسائق وسريان الرخص والتأمين، ومن الحمولة لكل شحنة', 4500);
  await pickOpt('#P22_VEH', (o) => /متاح/.test(o.t) && !/رحلة/.test(o.t), '<b>العربة</b> المتاحة (الحمولة والنوع والحالة)');
  await pickOpt('#P22_DRV', (o) => /متاح/.test(o.t) && !/رحلة/.test(o.t), '<b>السائق</b> المتاح');
  await pickOpt('#P22_ROUTE', () => true, '<b>المسار</b>: يحدد الزمن القياسي وموعد الوصول المتوقع');
  // الأمر الذي أنشأناه: أعلى رقم شحنة بين المؤكدة
  const no = await page.locator('#P22_ORDERS label').evaluateAll((ls) => ls.map((l) => (l.textContent.match(/SHP-\d+/) || [''])[0])
    .filter(Boolean).sort().pop() || '');
  const cb = page.locator('#P22_ORDERS label').filter({ hasText: no }).first();
  if (no && await cb.count()) await v.click(cb, '<b>الشحنات المؤكدة</b>: نختار الأمر الذي أنشأناه ' + no, false);
  else log('ERR order checkbox not found');
  await v.click('إنشاء الرحلة', '<b>إنشاء الرحلة</b>');
  await msg('create trip');
  await v.say('شاشة <b>الرحلة</b>: الشحنات المحملة، ونقاط التوقف، وحركة الرحلة، والتسليم، والمصروفات', 4500);

  // ------------------------------------------------ 3) الحركة والتسليم
  await v.setStep('4 · الحركة والتسليم');
  await v.say('<b>قراءة العداد</b> مقترحة من آخر قراءة للعربة', 3500);
  await v.click('تحرك الرحلة', '<b>تحرك الرحلة</b>: العربة والسائق مشغولان والشحنات في الطريق');
  await msg('depart');
  await v.click('وصلت الرحلة', '<b>وصلت الرحلة</b>: يحسب التأخير عن الموعد المتوقع');
  await msg('arrive');
  if (await page.locator('#P21_DLV_ORDER').count()) {
    await pickOpt('#P21_DLV_ORDER', () => true, '<b>التسليم</b>: الشحنة');
    await v.type('#P21_DLV_QTY', '11.5', '<b>الكمية المسلمة</b> 11.5 من 12: الفرق يسجل <b>عجزاً</b>');
    await v.type('#P21_DLV_RCV', 'مستودع العميل - خالد', '<b>المستلم</b>');
    await v.click('تسجيل التسليم', '<b>تسجيل التسليم</b>');
    await msg('deliver');
  }
  const odo0 = Number(String(await page.locator('#P21_ODO').inputValue().catch(() => '')).replace(/[^\d.]/g, '')) || 0;
  if (odo0) await v.type('#P21_ODO', String(odo0 + 410), '<b>قراءة العداد عند العودة</b>: مقترحة من قراءة التحرك، نعدلها (410 كم)');
  await v.type('#P21_FUEL', '160', 'إجمالي الوقود (لتر)');
  await v.click('إقفال الرحلة', '<b>إقفال الرحلة</b>: العربة والسائق متاحان، وتحسب المسافة والاستهلاك');
  await msg('complete');

  // ------------------------------------------------ 4) الفوترة
  await v.setStep('5 · فوترة الترحيل');
  await v.nav('فوترة الترحيل');
  const c = await pickOpt('#P55_CUST', () => true, '<b>العميل</b> وعدد أوامره المسلمة غير المفوترة');
  if (c) {
    await v.settle();
    const first = page.locator('#P55_ORDERS label').first();
    if (await first.count()) await v.click(first, 'نختار الأوامر المسلمة', false);
    await v.click('إصدار الفاتورة', '<b>إصدار الفاتورة</b>: فاتورة مبيعات آجلة مرحلة على إيرادات النقل (4170) بقيد تلقائي');
    await msg('invoice');
  }
  await page.evaluate(() => { const t = document.querySelector('.a-IRR-table'); if (t) t.scrollIntoView({ block: 'center', behavior: 'smooth' }); });
  await v.say('الأوامر المفوترة برقم الفاتورة وتاريخها؛ والفاتورة تظهر في ذمة العميل والإقرار الضريبي', 4500);

  // ------------------------------------------------ 5) التقارير والتحليلات
  await v.setStep('6 · التقارير والتحليلات');
  await v.nav('استغلال الأسطول وربحية العربات');
  await v.say('<b>استغلال الأسطول وربحية العربات</b>: الرحلات والكيلومترات والإيراد والمصروفات والربح لكل عربة', 5000);
  await v.nav('التحليلات والتنبؤ');
  await v.wait(2500);
  await v.say('<b>التحليلات والتنبؤ</b>: مؤشرات الشهر مقارنة بالفترة المماثلة، والرسم الشهري مع التنبؤ للأشهر القادمة', 5500);
  const yr = page.locator('.nn-anl button, .nn-anl [role=tab], .nn-anl a').filter({ hasText: 'مقارنة السنوات' }).first();
  if (await yr.count()) { await v.click(yr, '<b>مقارنة السنوات</b>: نفس المؤشر لكل سنة سابقة شهراً بشهر', false); await v.wait(3000); }
  await v.setStep('');
  await v.card('النقل والشحن والترحيل', ['أمر شحن ← رحلة ← تسليم ← فاتورة ترحيل بقيد تلقائي', 'الفيديو المطول يشرح كل شاشة وحقل'], 4500, 'نونا بلس');
  log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
