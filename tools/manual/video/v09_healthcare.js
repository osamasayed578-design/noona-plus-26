/* فيديو 10: المستشفيات والمراكز الطبية - تجهيز، طبيب وساعات عمله، ملف مريض، موعد، زيارة: كشف وطلب تحليل،
   الفاتورة والتحصيل، تنفيذ التحليل في المعمل وإدخال النتيجة، والتقارير.
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v09_healthcare.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;
const NEXT = new Date(Date.now() + 7 * 864e5).toISOString().slice(0, 10);
const DAY = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'][new Date().getDay()];

(async () => {
  const v = await video('noona_his', out, 'v09_healthcare');
  const { page } = v;

  await page.goto('http://localhost:' + (process.env.NOONA_PORT || 8090) + '/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('المستشفيات والمراكز الطبية', ['الطبيب · المريض · الموعد', 'الكشف والطلبات · الفاتورة · المعمل والنتيجة'], 4500, 'الفيديو القصير 10 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) التجهيز والطبيب
  await v.setStep('1 · التجهيز');
  await v.login(ADMIN, PWD, 'يفتح أحمد تطبيق <b>المستشفيات والمراكز الطبية</b>');
  const setup = page.getByRole('button', { name: /تجهيز المستشفى/ });
  if (await setup.count()) await v.click(setup.first(), '<b>تجهيز المستشفى</b>: الأقسام والعيادات والمعامل، ودليل الخدمات بأسعارها، والحسابات');

  await v.setStep('2 · الطبيب وساعات عمله');
  await v.nav('الأطباء وساعات العمل');
  await v.type('#P62_NAME', 'د. سامي الحربي', 'الطبيب: الاسم والقسم واللقب والتخصص والترخيص');
  await v.select('#P62_DEPT', 'عيادة الباطنة');
  await v.select('#P62_TITLE', 'استشاري');
  await v.type('#P62_SPEC', 'الأمراض الباطنية');
  await v.type('#P62_LIC', '13-R-0045871');
  await v.select('#P62_CONSULT', 'كشف استشاري', '<b>خدمة الكشف</b> وسعرها، ونسبة عمولة الطبيب');
  await v.type('#P62_COMM', '30');
  await v.click('حفظ', '<b>حفظ</b>');
  await v.select('#P62_DAY', DAY, '<b>ساعات العمل</b>: اليوم والفترة ومدة الموعد والعيادة');
  await v.type('#P62_FROM', '08:00');
  await v.type('#P62_TO', '16:00');
  await v.type('#P62_SLOT', '20');
  await v.type('#P62_ROOM', 'عيادة 3');
  await v.click('حفظ الفترة', '<b>حفظ الفترة</b>');

  // ------------------------------------------------ 2) المريض والموعد
  await v.setStep('3 · ملف المريض');
  await v.nav('المرضى');
  await v.click('مريض جديد', '<b>مريض جديد</b>');
  await v.type('#P11_NAME', 'منى إبراهيم السالم', 'البيانات: الاسم والجنس والميلاد والهوية والجوال');
  await v.select('#P11_GENDER', 'أنثى');
  await v.type('#P11_BIRTH_input', '1988-04-12');
  await page.keyboard.press('Escape');
  await v.select('#P11_ID_TYPE', 'هوية وطنية');
  await v.type('#P11_ID_NO', '10' + String(Date.now()).slice(-8));
  await v.type('#P11_MOBILE', '0567778899');
  await v.select('#P11_BLOOD', 'O+', 'فصيلة الدم والحساسية والأمراض المزمنة: تظهر للطبيب في كل زيارة');
  await v.type('#P11_ALLERGY', 'حساسية من البنسلين');
  await v.click('حفظ', '<b>حفظ</b>: رقم طبي تلقائي MRN');
  await v.say('مواطن بهوية وطنية: خدماته الصحية بنسبة ضريبة صفر تلقائياً', 3500);

  await v.setStep('4 · حجز موعد');
  await v.nav('حجز موعد');
  await v.select('#P21_PATIENT', 'منى', 'موعد متابعة الأسبوع القادم: المريض والطبيب واليوم');
  await v.select('#P21_DOCTOR', 'سامي');
  await v.type('#P21_DATE_input', NEXT);
  await page.keyboard.press('Tab'); await v.wait(2500);
  const times = await page.locator('#P21_TIME option').allInnerTexts();
  if (times.length > 1) await v.select('#P21_TIME', times[times.length > 3 ? 3 : 1].trim(), 'الأوقات المتاحة من ساعات عمل الطبيب');
  await v.click('حجز', '<b>حجز</b>');
  console.log('appt: ' + await v.alerts());

  // ------------------------------------------------ 3) الزيارة
  await v.setStep('5 · الزيارة والكشف');
  await v.nav('زيارة جديدة');
  await v.select('#P32_PATIENT', 'منى', 'وصلت المريضة: <b>زيارة جديدة</b> (أو من لوحة المواعيد)');
  await v.select('#P32_DOCTOR', 'سامي');
  await v.type('#P32_COMPLAINT', 'صداع وإرهاق منذ أسبوع', 'سبب الزيارة');
  await v.click('فتح الزيارة', '<b>فتح الزيارة</b>: يضاف الكشف تلقائياً');
  await v.type('#P31_VITALS', 'BP 120/80, T 36.8, P 82, SpO2 98%', 'الطبيب: العلامات الحيوية والتشخيص');
  await v.type('#P31_DIAG', 'Suspected iron deficiency anemia');
  await v.type('#P31_ICD', 'D50.9');
  await v.click('حفظ الكشف', '<b>حفظ الكشف</b>');
  await v.select('#P31_SERVICE', 'CBC', '<b>طلب تحليل</b>: صورة دم كاملة (من دليل الخدمات)');
  await v.click('إضافة الطلب', '<b>إضافة الطلب</b>: يظهر في قائمة المعمل');
  await v.say('ومن الزيارة أيضاً: الوصفة، التقرير الطبي والإجازة، التنويم، جدولة عملية', 3500);

  await v.setStep('6 · الفاتورة والتحصيل');
  await v.select('#P31_METHOD', 'مدى', 'طريقة الدفع');
  await v.click(page.getByRole('button', { name: /إصدار الفاتورة والتحصيل/ }), '<b>إصدار الفاتورة والتحصيل</b>');
  await v.say('الفاتورة الضريبية: كشف 300 + تحليل 60، ضريبة صفر للمواطنة، ومحصلة بالكامل', 5000);

  // ------------------------------------------------ 4) المعمل
  await v.setStep('7 · المعمل والنتيجة');
  await v.nav('قوائم المعامل والأشعة والأقسام');
  await v.say('<b>قائمة المعمل</b>: الطلبات المطلوبة والجارية، وهل سُددت', 3500);
  await v.click(page.locator('.a-IRR-table td a').first(), 'نفتح الطلب');
  await v.click('سحب العينة', '<b>سحب العينة</b>: رقم عينة وملصق، ويبدأ التنفيذ');
  await v.say('مكونات التحليل بقيمها المرجعية حسب العمر والجنس؛ تلون القيم خارج المدى', 3500);
  const vals = page.locator('input[name="f01"]');
  const n = await vals.count();
  const sample = ['10.8', '4.2', '6.5', '33', '78', '25', '32', '250'];
  for (let i = 0; i < Math.min(n, sample.length); i++) await vals.nth(i).fill(sample[i]);
  if (n) await v.say('القيم أُدخلت (أو تصل من جهاز المعمل بالربط)', 3000);
  await v.select('#P51_FLAG', 'غير طبيعي', 'التقييم');
  await v.type('#P51_RESULT', 'Low hemoglobin consistent with mild anemia.', 'التعليق');
  const rel = page.getByRole('button', { name: /اعتماد النتائج وإصدارها/ });
  if (await rel.count()) await v.click(rel.first(), '<b>اعتماد النتائج وإصدارها</b>: تظهر للطبيب في ملف المريض');
  else await v.click(page.getByRole('button', { name: /حفظ النتيجة وإنجاز الطلب/ }), '<b>حفظ النتيجة وإنجاز الطلب</b>: تظهر للطبيب في ملف المريض');
  console.log('lab: ' + await v.alerts());

  await v.setStep('8 · التقارير');
  await v.nav('التقارير والمطالبات');
  await v.say('<b>التقارير</b>: الزيارات والإيرادات حسب الطبيب والقسم، عمولات الأطباء، ومطالبات التأمين الإلكترونية', 5000);
  await v.card('التالي', ['الفيديو 11: مراكز خدمة السيارات', 'استقبال المركبة وأمر العمل والفاتورة'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
