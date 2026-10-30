/* فيديو التسعير والعروض والباقات (قصير، أو مطول بـ LONG=1): سياسة سعر البيع من التكلفة، إعادة التسعير بالمراجعة ثم التطبيق،
   بطاقة تكلفة، عرض بنسبة على صنف وكوبون على قيمة الفاتورة، باقة بخصم من مجموع مكوناتها، ثم البيع في نقطة البيع بالعرض
   التلقائي والكوبون والباقة، وتطبيق العروض في فاتورة المبيعات. يكمل مؤسسة الفيديوهات القصيرة (أصناف بمخزون ونقطة بيع).
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... [LONG=1] node tools/manual/video/v12_pricing.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;
const LONG = process.env.LONG === '1';
const K = LONG ? '2' : '';      // رموز مختلفة للفيديو المطول على نفس المؤسسة

(async () => {
  const v = await video('noona_pos', out, LONG ? 'v12_pricing_long' : 'v12_pricing');
  const { page } = v;
  const L = async (html, ms) => { if (LONG) await v.say(html, ms); };     // شرح إضافي في الفيديو المطول فقط
  const opts = (sel) => page.locator(sel + ' option').evaluateAll((os) => os.map((o) => ({ v: o.value, t: o.textContent.trim() })).filter((o) => o.v));
  async function pickOpt(sel, pred, note) {
    const o = (await opts(sel)).find(pred);
    if (o) await v.select(sel, o.t, note);
    return o;
  }

  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('التسعير والعروض والباقات', ['سعر البيع من التكلفة بنسبة أو هامش أو مبلغ · إعادة التسعير',
    'العروض والتخفيضات والكوبونات · الباقات · البيع بها في نقطة البيع والفاتورة'], 5000,
    LONG ? 'الفيديو المطول · شرح تفصيلي بالعربية · نونا بلس' : 'الفيديو القصير · إدخال حقيقي سريع · مجموعة النور');
  await v.setStep('1 · سياسة التسعير');
  await v.login(ADMIN, PWD, 'يفتح أحمد تطبيق <b>المبيعات ونقاط البيع</b> ← قائمة <b>التسعير والعروض</b>');
  await L('التسعير موحد لكل الأنظمة: نفس الشاشات في المبيعات، وفي المستشفيات للخدمات الطبية، وفي خدمة السيارات لخدماتها وقطعها', 6000);

  // ------------------------------------------------ 1) سياسة سعر البيع من التكلفة
  await v.nav('سياسات التسعير');
  await v.say('<b>سياسة التسعير</b>: كيف يحسب سعر البيع من التكلفة', 3500);
  await L('التكلفة: متوسط التكلفة المرجح للصنف من المشتريات، أو آخر سعر شراء، أو التكلفة المعيارية، أو بطاقة تكلفة الخدمة', 6000);
  await v.type('#P80_CODE', 'MARKUP35' + K, 'رمز السياسة واسمها');
  await v.type('#P80_NAME', 'هامش 35% على كل الأصناف');
  await pickOpt('#P80_TARGET', (o) => o.t.includes('كل الأصناف'), '<b>تنطبق على</b>: كل الأصناف (أو فئة أو صنف محدد؛ الأخص يطبق أولاً)');
  await v.select('#P80_BASIS', 'متوسط التكلفة', '<b>أساس التكلفة</b>: المتوسط المرجح');
  await v.select('#P80_METHOD', 'نسبة فوق التكلفة', '<b>الطريقة</b>: نسبة فوق التكلفة (Markup)');
  await L('الطرق الأخرى: <b>هامش من سعر البيع</b> (تكلفة 100 بهامش 20% = 125)، <b>مبلغ ثابت</b> فوق التكلفة، أو <b>معامل</b> (التكلفة × 1.5)', 7000);
  await v.type('#P80_VALUE', '35', 'النسبة: <b>35%</b> فوق التكلفة');
  await v.type('#P80_MINM', '10', '<b>أدنى هامش 10%</b>: يحدد أدنى سعر بيع لا يتجاوزه الخصم دون موافقة');
  await v.select('#P80_ROUND', '1', '<b>التقريب لأعلى</b> لأقرب 1 (أو 0.05، 0.25، 0.50، 5، 10، أو ينتهي بـ .99)');
  await v.click('حفظ السياسة', '<b>حفظ السياسة</b>');

  // ------------------------------------------------ 2) إعادة التسعير
  await v.setStep('2 · إعادة التسعير');
  await v.nav('إعادة التسعير والهوامش');
  await v.say('<b>إعادة التسعير</b>: يحسب السعر المقترح لكل صنف من تكلفته وسياسته، ويعرضه أمام السعر الحالي قبل أي تغيير', 5000);
  await v.click('احسب الأسعار المقترحة', '<b>احسب الأسعار المقترحة</b>');
  await page.evaluate(() => { const t = document.querySelector('.a-IRR-table'); if (t) t.scrollIntoView({ block: 'center', behavior: 'smooth' }); });
  await v.say('لكل صنف: <b>التكلفة، السعر الحالي، السعر المقترح، أدنى سعر، الهامش، ونسبة التغير</b>', 5000);
  if (await page.locator('#P82_LINE option').count() > 1) {
    await pickOpt('#P82_LINE', () => true, 'للمراجعة: نختار سطراً');
    await L('يمكن تعديل السعر المقترح لسطر، أو استبعاده من التطبيق', 4000);
    await v.select('#P82_SEL', 'نعم', 'يطبق: نعم');
    await v.click('تعديل السطر', null);
  }
  await v.click('تطبيق الأسعار', '<b>تطبيق الأسعار</b>: تحدث أسعار البيع وأدنى أسعارها، ويسجل كل تغيير');
  await page.evaluate(() => { const r = [...document.querySelectorAll('.t-Region')].filter((x) => /سجل تغيير الأسعار/.test(x.textContent)).pop(); if (r) r.scrollIntoView({ block: 'start', behavior: 'smooth' }); });
  await v.say('<b>سجل تغيير الأسعار</b>: السعر السابق والجديد والتكلفة ومن غيره ومتى', 4500);
  await L('و<b>تقرير الهوامش</b> يبين كل صنف وخدمة بتكلفته وسعره وهامشه، ويبرز بالأحمر ما يباع بأقل من تكلفته', 5500);

  // ------------------------------------------------ 3) بطاقة التكلفة (المطول)
  if (LONG) {
    await v.setStep('3 · بطاقة التكلفة');
    await v.nav('بطاقات التكلفة');
    await v.say('<b>بطاقة التكلفة</b>: للخدمات (كشف، تحليل، صيانة) والمنتجات المجمعة: مواد + عمالة + أعباء', 5000);
    const t = await pickOpt('#P81_TARGET', () => true, 'نختار الصنف أو الخدمة');
    if (t) {
      await v.settle();
      await v.select('#P81_ET', 'عمالة', 'عنصر <b>عمالة</b>: الدقائق × تكلفة الساعة');
      await v.type('#P81_DESC', 'تجهيز وتغليف');
      await v.type('#P81_MIN', '15', '15 دقيقة');
      await v.type('#P81_RATE', '40', 'بتكلفة 40 للساعة = 10');
      await v.click('إضافة العنصر', '<b>إضافة العنصر</b>');
      await v.select('#P81_ET', 'أعباء نسبة', 'و<b>أعباء نسبة</b> من التكلفة المباشرة (إيجار، كهرباء، إدارة)');
      await v.type('#P81_PCT', '10', '10%');
      await v.click('إضافة العنصر', null);
      await page.evaluate(() => { const r = [...document.querySelectorAll('.t-Region')].find((x) => /بطاقة التكلفة/.test(x.textContent)); if (r) r.scrollIntoView({ block: 'start', behavior: 'smooth' }); });
      await v.say('البطاقة تجمع المواد والعمالة والأعباء إلى <b>تكلفة الوحدة</b>؛ وسياسة بأساس «بطاقة التكلفة» تسعر منها', 6000);
    }
  }

  // ------------------------------------------------ 4) العروض والتخفيضات
  await v.setStep((LONG ? '4' : '3') + ' · العروض والتخفيضات');
  await v.nav('العروض والتخفيضات');
  await v.say('<b>العروض والتخفيضات</b>: تطبق تلقائياً في نقطة البيع والفاتورة حسب الصنف والفترة والقناة', 4500);
  await v.type('#P83_CODE', 'OIL15' + K, 'عرض جديد');
  await v.type('#P83_NAME', 'خصم 15% على الزيوت');
  await v.select('#P83_TYPE', 'خصم نسبة', '<b>النوع</b>: خصم نسبة');
  await L('الأنواع: نسبة، مبلغ للوحدة، <b>سعر خاص</b>، <b>اشتر X واحصل على Y مجاناً</b>، أو خصم على قيمة الفاتورة', 6000);
  await v.type('#P83_VALUE', '15', '15%');
  const item = await pickOpt('#P83_TARGET', (o) => o.t.startsWith('صنف:') && /زيت/.test(o.t), '<b>يشمل</b>: الصنف (أو فئة أو كل الأصناف)')
            || await pickOpt('#P83_TARGET', (o) => o.t.startsWith('صنف:'), 'يشمل: الصنف');
  await page.locator('#P83_CH input[value="POS"]').check().catch(() => {});
  await page.locator('#P83_CH input[value="SALES"]').check().catch(() => {});
  await v.say('<b>القنوات</b>: نقاط البيع وفواتير المبيعات', 3000);
  await L('ويحدد العرض بأيام الأسبوع وساعات (عرض الساعة السعيدة)، وأقصى خصم، وأدنى كمية، وأولوية، وهل يجمع مع غيره', 6000);
  await v.click('حفظ العرض', '<b>حفظ العرض</b>');
  await v.type('#P83_CODE', 'WELCOME' + K, 'عرض ثانٍ: <b>كوبون</b> على قيمة الفاتورة');
  await v.type('#P83_NAME', 'كوبون ترحيب 20');
  await v.select('#P83_TYPE', 'خصم مبلغ على قيمة الفاتورة', 'خصم مبلغ على الفاتورة');
  await v.type('#P83_VALUE', '20', '20 ريال');
  await v.type('#P83_MINA', '100', 'عند الشراء بـ 100 فأكثر');
  await v.type('#P83_COUPON', 'WELCOME', 'بكود الكوبون <b>WELCOME</b>');
  await v.click('حفظ العرض', '<b>حفظ</b>');
  await page.evaluate(() => { const t = document.querySelector('.a-IRR-table'); if (t) t.scrollIntoView({ block: 'center', behavior: 'smooth' }); });
  await v.say('العروض السارية بشروطها؛ ومن «إدارة عرض» يضاف له صنف أو يوقف مؤقتاً أو يلغى', 4500);

  // ------------------------------------------------ 5) الباقات
  await v.setStep((LONG ? '5' : '4') + ' · الباقات');
  await v.nav('الباقات');
  await v.say('<b>الباقة</b>: أصناف و/أو خدمات تباع معاً بسعر ثابت أو بخصم من مجموعها', 4000);
  await v.type('#P84_CODE', 'PACK10' + K, 'باقة جديدة');
  await v.type('#P84_NAME', 'باقة الصيانة الموفرة');
  await v.select('#P84_METHOD', 'خصم نسبة', 'السعر: <b>خصم 10%</b> من مجموع أسعار المكونات');
  await v.type('#P84_VALUE', '10');
  const comps = (await opts('#P84_C1')).slice(0, 2);
  if (comps.length === 2) {
    await v.select('#P84_C1', comps[0].t, 'المكون الأول');
    await v.select('#P84_C2', comps[1].t, 'والثاني (ويضاف غيرهما بعد الحفظ)');
    await page.locator('#P84_CH input[value="POS"]').check().catch(() => {});
    await v.click('حفظ الباقة', '<b>حفظ الباقة</b>');
    await page.evaluate(() => { const r = [...document.querySelectorAll('.t-Region')].filter((x) => /توزيع سعرها/.test(x.textContent)).pop(); if (r) r.scrollIntoView({ block: 'start', behavior: 'smooth' }); });
    await v.say('سعر الباقة <b>يوزع على مكوناتها</b> بنسبة أسعارها: يظهر التوفير، والإيراد والضريبة صحيحان لكل صنف', 5500);
  }
  await L('في المستشفيات: <b>باقة فحص شامل</b> تضاف للزيارة بخدماتها، وفي خدمة السيارات: <b>باقة صيانة</b> من تبويب الباقات في أمر الإصلاح', 6500);

  // ------------------------------------------------ 6) البيع في نقطة البيع
  await v.setStep((LONG ? '6' : '5') + ' · البيع بالعروض في نقطة البيع');
  await v.nav('نقطة البيع');
  await v.click(page.locator('.a-IRR-table a').filter({ hasText: 'بدء البيع' }).first(), 'نفتح <b>نقطة البيع</b>');
  if (await page.locator('.nn-pos-float').isVisible().catch(() => false)) {
    await v.type('.nn-pos-float', '200', 'فتح الوردية برصيد افتتاحي');
    await v.click('[data-do="open"]', null, false);
  }
  const bar = await page.evaluate((id) => { const its = JSON.parse(document.getElementById('nnPosBoot').textContent).items;
    const x = its.find((i) => String(i.id) === String(id)) || its.find((i) => i.b); return x ? (String(x.b || '').split(' ')[0] || x.no) : null; },
    item ? item.v.replace('ITEM-', '') : null);
  if (bar) {
    await v.type('#nnPosScan', '2*' + bar, 'نمسح الصنف بكمية 2');
    await page.keyboard.press('Enter'); await v.wait(1800);
    await page.locator('.nn-pos-cart .nn-badge.is-success').first().evaluate((e) => e.classList.add('nnv-hl')).catch(() => {});
    await v.say('<b>العرض طبق تلقائياً</b>: شارة باسم العرض وخصمه في عمود الخصم دون أي تدخل من الكاشير', 5000);
  }
  await v.type('.nn-pos-coupon', 'WELCOME', 'العميل معه <b>كوبون</b>: يكتب في خانة الكوبون');
  await page.keyboard.press('Tab'); await v.wait(1800);
  await v.say('خصم الكوبون يظهر في الملخص إذا تحققت أدنى قيمة الشراء', 4000);
  if (await page.locator('.nn-pos-bundles').count()) {
    await v.click('.nn-pos-bundles', '<b>الباقات</b>', false);
    await v.wait(800);
    await v.click(page.locator('[data-bundle]').first(), 'نختار الباقة: تضاف مكوناتها بسعرها الموزع', false);
    await v.wait(1500);
  }
  await v.say('الإجمالي بعد العروض والكوبون والباقة؛ والضريبة محسوبة بعد الخصم', 4000);
  await page.keyboard.press('F9'); await v.wait(800);
  await page.locator('[data-print]').uncheck().catch(() => {});
  await v.click('[data-do="pay"]', '<b>تأكيد البيع</b>', false);
  await page.locator('.nn-pos-done').waitFor({ timeout: 15000 }).catch(() => {});
  await v.say('تم البيع؛ الإيصال يبين خصم كل صنف', 3500);
  await page.keyboard.press('Enter').catch(() => {});

  // ------------------------------------------------ 7) الفاتورة
  if (LONG) {
    await v.setStep('7 · العروض في فاتورة المبيعات');
    await v.nav('فاتورة مبيعات جديدة');
    await v.say('وفي <b>فاتورة المبيعات</b>: بعد إضافة الأصناف زر <b>تطبيق العروض</b> يحسب خصم كل سطر وعرض قيمة الفاتورة', 6000);
    if (bar) {
      await v.type('.nn-td-find', bar, 'نضيف الصنف');
      await page.keyboard.press('Enter'); await v.wait(1500);
      const pick = page.locator('[data-pick]').first();
      if (await pick.count()) await v.click(pick, null, false);
      await v.click('.nn-td-promo', '<b>تطبيق العروض</b>', false);
      await v.wait(2000);
      await v.say('الخصم في عمود الخصم ورسالة باسم العرض؛ ويمكن تعديله يدوياً قبل الحفظ', 4500);
    }
  }
  await v.setStep('');
  await v.card('التسعير والعروض والباقات', ['سعر البيع من التكلفة · إعادة التسعير بالمراجعة', 'عروض تلقائية · كوبونات · باقات في كل الأنظمة'], 4000, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
