/* فيديو 11: مراكز خدمة السيارات - تجهيز (رافعات وفئات وخدمات افتراضية)، فني مرتبط بالموظف، استلام سيارة بخدماتها،
   أمر الإصلاح: قطع الغيار بالبحث، إسناد الفني والبدء والإنجاز، الفاتورة والتسليم، ثم التقارير.
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v10_auto_service.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;

(async () => {
  const v = await video('noona_auto', out, 'v10_auto_service');
  const { page } = v;

  await page.goto('http://localhost:' + (process.env.NOONA_PORT || 8090) + '/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('مراكز خدمة السيارات', ['استلام السيارة وأمر الإصلاح', 'القطع والفنيون · الفاتورة · التسليم · التقارير'], 4500, 'الفيديو القصير 11 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) التجهيز
  await v.setStep('1 · التجهيز');
  await v.login(ADMIN, PWD, 'يفتح أحمد تطبيق <b>مراكز خدمة السيارات</b>');
  const setup = page.getByRole('button', { name: /تجهيز مركز الخدمة/ });
  if (await setup.count()) await v.click(setup.first(), '<b>تجهيز</b>: الرافعات، وفئات وخدمات جاهزة بأسعارها (تعدل لاحقاً)، والترقيم');
  await v.go('services');
  await v.say('<b>الخدمات وقطعها</b>: لكل خدمة سعرها ومدتها وضمانها وموعد الصيانة التالية، وقطعها الافتراضية', 4500);

  await v.setStep('2 · الفني');
  await v.go('bays-technicians');
  await v.type('#P11_T_CODE', 'T' + String(Date.now()).slice(-2), '<b>فني</b>: مرتبط بملف الموظف في الموارد البشرية');
  await v.type('#P11_T_NAME', 'خالد العتيبي');
  await v.select('#P11_T_EMP', 'خالد');
  await v.type('#P11_T_SPEC', 'ميكانيكا وفرامل');
  await v.type('#P11_T_COST', '40', 'تكلفة الساعة ونسبة العمولة (لتقرير إنتاجية الفنيين)');
  await v.type('#P11_T_COMM', '10');
  await v.click('حفظ الفني', '<b>حفظ الفني</b>');

  // ------------------------------------------------ 2) الاستلام
  await v.setStep('3 · استلام السيارة');
  await v.go('check-in');
  await v.type('#P2_PLATE', 'ن و ر ' + String(Date.now()).slice(-4), 'رقم اللوحة ثم <b>بحث</b>: سيارة مسجلة تظهر بياناتها وتاريخها');
  await v.click('بحث', null);
  await v.say('سيارة جديدة: نكمل بياناتها وبيانات المالك', 2500);
  await v.type('#P2_MAKE', 'Toyota', 'الشركة والطراز والسنة واللون');
  await v.type('#P2_MODEL', 'Camry');
  await v.type('#P2_YEAR', '2021');
  await v.type('#P2_COLOR', 'أبيض');
  await v.type('#P2_OWNER', 'ماجد خالد الدوسري', 'المالك والجوال (عميل في المبيعات)');
  await v.type('#P2_PHONE', '0551239876');
  await v.type('#P2_ODO', '45200', 'عداد الكيلومترات ومستوى الوقود والرافعة');
  await v.select('#P2_FUEL', 'نصف');
  await v.select('#P2_BAY', 'رافعة 1');
  await v.type('#P2_COMPLAINT', 'تغيير زيت وصوت عند الفرملة', 'شكوى العميل');
  for (const s of ['تغيير زيت مع الفلتر', 'تغيير فحمات أمامية']) {
    const lb = page.locator('#P2_SERVICES label').filter({ hasText: s }).first();
    if (await lb.count()) await v.click(lb, 'الخدمات المطلوبة: <b>' + s + '</b>', false);
  }
  await v.click('فتح أمر الإصلاح', '<b>فتح أمر الإصلاح</b>');
  await page.waitForSelector('#nnAut .nn-aut-lt', { timeout: 15000 }).catch(() => {});
  await v.say('<b>أمر الإصلاح</b>: الخدمات بأسعارها، ونضيف القطع ونسند الفني', 3500);

  // ------------------------------------------------ 3) أمر الإصلاح
  await v.setStep('4 · القطع والفني');
  for (const q of ['زيت محرك', 'فلتر زيت']) {
    await v.type('#nnAutQ', q, 'بحث القطع: بالاسم أو الباركود أو رقم القطعة أو OEM، مع الرصيد');
    await v.wait(1800);
    const part = page.locator('.nn-aut-part').first();
    if (await part.count()) await v.click(part, null, false);
    await v.wait(1200);
  }
  for (let i = 0; i < 4; i++) {
    const sel = page.locator('.nn-aut-lt select[data-f=tech]').filter({ has: page.locator('option:checked[value=""]') }).first();
    if (!(await sel.count())) break;
    await v.select(sel, 'خالد', i ? null : 'إسناد <b>الفني</b> لكل خدمة');
    await v.wait(1000);
  }
  for (let i = 0; i < 4; i++) {
    const b = page.locator('[data-la=START]').first(); if (!(await b.count())) break;
    await v.click(b, i ? null : '<b>بدء</b> العمل: يحسب الوقت الفعلي للفني', false); await v.wait(900);
  }
  for (let i = 0; i < 4; i++) {
    const b = page.locator('[data-la=DONE]').first(); if (!(await b.count())) break;
    await v.click(b, i ? null : '<b>تم</b>: إنجاز الخدمة', false); await v.wait(900);
  }

  await v.setStep('5 · الفاتورة والتسليم');
  await v.click('[data-a=COMPLETE]', '<b>اكتمل الإصلاح</b>: تتحول السيارة إلى «جاهزة للفوترة»', false);
  await v.wait(1500);
  await v.click('[data-a=INVOICE]', '<b>الفاتورة</b>: خدمات وقطع في فاتورة ضريبية واحدة، وتصرف القطع من المخزون', false);
  await page.waitForSelector('#nnAutPlace').catch(() => {});
  await v.say('الدفع: نقدي إلى صندوق أو بنك، أو آجل على العميل أو شركة التأمين', 3000);
  await v.click('[data-ok]', null, false);
  await v.wait(2500);
  await v.click('[data-a=DELIVER]', '<b>التسليم</b>: عداد الخروج، وتذكير بموعد الصيانة التالية', false);
  await page.waitForSelector('#nnAutOdo').catch(() => {});
  await page.fill('#nnAutOdo', '45210');
  await v.click('[data-ok]', null, false);
  await v.wait(2500);

  await v.setStep('6 · اللوحة والتقارير');
  await v.go('home');
  await v.say('<b>لوحة الورشة</b>: السيارات حسب حالتها، والمتأخرة عن الموعد، ومبيعات اليوم', 4000);
  await v.go('reports', '&p12_kind=SUMMARY&p12_period=MONTH');
  await v.say('<b>التقارير</b>: الخدمات والقطع الأكثر طلباً، إنتاجية الفنيين، مدة البقاء، التأمين، والصيانة المستحقة', 5000);
  await v.card('التالي', ['الفيديو 12: مركز التقارير والتكاملات', 'كل التقارير في مكان واحد والربط مع الأنظمة الأخرى'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
