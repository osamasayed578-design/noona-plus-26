/* فيديو 9: الضيافة والفنادق - فندق بغرفه ونوع غرفه من المعالج، خطة سعر، حجز بعربون، تسجيل الدخول، لوحة الاستقبال:
   حساب النزيل وخدمة إضافية والسداد وتسجيل المغادرة، ثم التدبير الفندقي والتقارير.
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v08_hospitality.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;
const day = (n) => new Date(Date.now() + n * 864e5).toISOString().slice(0, 10);

(async () => {
  const v = await video('noona_prj', out, 'v08_hospitality');
  const { page } = v;

  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('الضيافة والفنادق', ['الفندق والغرف وخطط الأسعار', 'الحجز · تسجيل الدخول · حساب النزيل · المغادرة'], 4500, 'الفيديو القصير 9 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) الفندق
  await v.setStep('1 · فندق جديد');
  await v.login(ADMIN, PWD, 'نفس تطبيق العقارات: الفندق عقار من نوع <b>فندق</b>');
  const setup = page.getByRole('button', { name: /تجهيز الضيافة/ });
  if (await setup.count()) await v.click(setup.first(), '<b>تجهيز الضيافة</b> مرة واحدة');
  await v.nav('إضافة عقار');
  await v.type('#P11_NAME', 'فندق النور', 'اسم الفندق ونوعه ومدينته وتصنيفه وترخيصه');
  await v.select('#P11_TYPE', 'فندق');
  await v.select('#P11_CITY', 'جدة');
  await v.type('#P11_STARS', '4');
  await v.type('#P11_LICENSE', 'TL-55821');
  await v.type('#P11_B1_NAME', 'البرج الرئيسي', 'دوران × 4 غرف = 8 غرف');
  await v.type('#P11_B1_FLOORS', '2');
  await v.type('#P11_PER_FLOOR', '4');
  await v.select('#P11_UTYPE', 'غرفة فندقية', 'الوحدات غرف فندقية للضيافة');
  await v.select('#P11_USAGE', 'ضيافة');
  await v.type('#P11_BEDS', '2');
  await v.type('#P11_AREA', '32');
  await v.select('#P11_HSP', 'نعم', '<b>نوع الغرفة</b> وسعر الليلة الأساسي يُنشآن مع الغرف');
  await v.type('#P11_RT_NAME', 'غرفة مزدوجة');
  await v.type('#P11_RT_RATE', '450');
  await v.type('#P11_RT_ADULTS', '2');
  await v.click('إنشاء العقار ووحداته', '<b>إنشاء العقار ووحداته</b>');

  // ------------------------------------------------ 2) خطة السعر
  await v.setStep('2 · خطة سعر');
  await v.nav('إعداد الضيافة');
  await v.select('#P27_PROPERTY', 'فندق النور', '<b>إعداد الضيافة</b>: أنواع الغرف، خطط الأسعار، أسعار المواسم، الغرف');
  await v.wait(1000);
  await v.type('#P27_PL_CODE', 'BB', 'خطة <b>مع الإفطار</b>: يومية، والسعر شامل الضريبة أو لا');
  await v.type('#P27_PL_NAME', 'مع الإفطار');
  await v.select('#P27_PL_MEAL', 'إفطار');
  await v.click('إضافة الخطة', '<b>إضافة الخطة</b>');

  // ------------------------------------------------ 3) الحجز
  await v.setStep('3 · الحجز');
  await v.nav('حجز جديد');
  await v.type('#P22_GUEST', 'عبدالرحمن محمد الزهراني', 'النزيل: الاسم والجوال والهوية');
  await v.type('#P22_PHONE', '0533332211');
  await v.type('#P22_IDNO', '1098765432');
  await v.type('#P22_ARR_input', day(0), 'الوصول اليوم والمغادرة بعد ليلتين');
  await v.type('#P22_DEP_input', day(2));
  await page.keyboard.press('Escape');
  await v.select('#P22_RT', 'غرفة مزدوجة', 'نوع الغرفة (بعدد المتاح) والخطة');
  await v.select('#P22_PLAN', 'مع الإفطار');
  await v.type('#P22_ADULTS', '2');
  await v.select('#P22_CHANNEL', 'هاتف', 'قناة الحجز');
  await v.type('#P22_DEPOSIT', '500', '<b>العربون</b> وطريقته والصندوق');
  await v.select('#P22_BOX', 'الصندوق الرئيسي');
  await v.click('تأكيد الحجز', '<b>تأكيد الحجز</b>');
  await v.click('تسجيل الدخول', 'وصل النزيل: <b>تسجيل الدخول</b> (تسند أول غرفة نظيفة أو نختار غرفة)');

  // ------------------------------------------------ 4) لوحة الاستقبال
  await v.setStep('4 · لوحة الاستقبال');
  await v.nav('لوحة الاستقبال');
  await v.say('<b>لوحة الاستقبال</b>: الإشغال والوصول والمغادرة، وحالة كل غرفة بلونها', 4000);
  await v.click(page.locator('.nn-fd-t').filter({ hasText: 'الزهراني' }).first(), 'الغرفة المشغولة: يفتح <b>حساب النزيل</b>', false);
  await v.wait(1500);
  await v.say('العربون 500 دائن، والليالي ترحل بالتدقيق الليلي أو عند المغادرة', 4000);
  const chg = page.locator('select').filter({ has: page.locator('option', { hasText: 'ميني بار' }) }).first();
  await v.select(chg, 'مطعم', '<b>خدمة إضافية</b>: مطعم وخدمة غرف');
  await v.type(page.getByPlaceholder('البيان'), 'عشاء في الغرفة');
  await v.type(page.getByPlaceholder('قبل الضريبة'), '120');
  await v.click(page.locator('.nn-fd-btn').filter({ hasText: 'إضافة' }).first(), '<b>إضافة</b> على حساب النزيل', false);
  await v.wait(2000);
  await v.say('المستحق عند المغادرة يظهر تلقائياً في خانة الدفعة', 3000);
  await v.click(page.locator('.nn-fd-btn').filter({ hasText: 'تسجيل' }).first(), 'النزيل يسدد الباقي: <b>تسجيل</b> الدفعة', false);
  await v.wait(2000);
  await v.click(page.locator('.nn-fd-btn').filter({ hasText: 'تسجيل المغادرة' }).first(), '<b>تسجيل المغادرة</b>: ترحل الليالي والفاتورة الضريبية', false);
  await v.wait(2500);
  console.log('checkout: ' + (await page.locator('.nn-fd-msg, .nn-fd-toast, #t_Alert_Success, #t_Alert_Notification').allInnerTexts()).join('|').slice(0, 200));
  await v.say('الغرفة أصبحت <b>شاغرة تحت التنظيف</b> حتى يجهزها التدبير الفندقي', 3500);

  // ------------------------------------------------ 5) التدبير والتقارير
  await v.setStep('5 · التدبير الفندقي والتقارير');
  await v.nav('التدبير الفندقي');
  await v.say('<b>التدبير الفندقي</b>: الغرف تحت التنظيف ومهام العاملين، وتعليم الغرفة نظيفة', 4000);
  await v.nav('تقارير الضيافة');
  await v.say('<b>تقارير الضيافة</b>: الإشغال ومتوسط سعر الليلة والإيراد لكل غرفة متاحة، والقنوات؛ و<b>التدقيق الليلي</b> يرحل الليالي يومياً', 5500);
  await v.card('التالي', ['الفيديو 10: المستشفيات والمراكز الطبية', 'التسجيل والموعد والكشف والفوترة'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
