/* فيديو 4: المبيعات ونقاط البيع - تجهيز المبيعات، عميل آجل بحد ائتمان، فاتورة مبيعات آجلة، التحصيل، البيع السريع في نقطة البيع
   (فتح الوردية، المسح، الدفع والباقي)، إقفال الوردية، وتقرير المبيعات ومجمل الربح. يكمل مؤسسة الفيديو 3 (الصنف بالمخزون).
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v03_sales_pos.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;

(async () => {
  const v = await video('noona_pos', out, 'v03_sales_pos');
  const { page } = v;

  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('المبيعات ونقاط البيع', ['عميل آجل · فاتورة مبيعات · التحصيل', 'البيع السريع · إقفال الوردية · مجمل الربح'], 4500, 'الفيديو القصير 4 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) التجهيز
  await v.setStep('1 · تجهيز المبيعات');
  await v.login(ADMIN, PWD, 'يفتح أحمد تطبيق <b>المبيعات ونقاط البيع</b>');
  await v.click(page.getByRole('button', { name: /تجهيز المبيعات/ }).first(),
    '<b>تجهيز</b> مرة واحدة: العميل النقدي، طرق الدفع (نقدي، مدى، بطاقات، Apple Pay...)، نقطة بيع بدرج نقدي، الترقيم');

  // ------------------------------------------------ 2) العميل
  await v.setStep('2 · عميل آجل');
  await v.nav('العملاء');
  await v.click('عميل جديد', 'العملاء ← <b>عميل جديد</b>');
  await v.type('#P11_NAME', 'ورشة الأمانة للصيانة', 'اسم العميل');
  await v.select('#P11_PERSON', 'منشأة', 'منشأة أو فرد');
  await v.type('#P11_TAX', '311111111111113', 'الرقم الضريبي (يظهر في الفاتورة الضريبية)');
  await v.type('#P11_PHONE', '0559876543', 'الجوال');
  await v.select('#P11_TERM', 'صافي 30', 'شروط الدفع');
  await v.type('#P11_LIMIT', '5000', '<b>حد الائتمان</b>: يمنع البيع الآجل فوقه');
  await v.click('حفظ', '<b>حفظ</b>');

  // ------------------------------------------------ 3) فاتورة المبيعات
  await v.setStep('3 · فاتورة مبيعات آجلة');
  await v.nav('فاتورة مبيعات جديدة');
  await v.select('[data-k="cust"]', 'الأمانة', 'العميل');
  await v.select('[data-k="mode"]', 'آجل', 'طريقة الدفع: <b>آجل</b> على حساب العميل');
  await v.select('[data-k="wh"]', 'المستودع الرئيسي', 'مستودع الصرف');
  await v.type('.nn-td-find', 'زيت', 'امسح الباركود أو اكتب الاسم ثم Enter: السعر يأتي من بطاقة الصنف');
  await page.keyboard.press('Enter'); await v.wait(1500);
  await v.type(page.locator('.nn-td-table tbody tr').first().locator('input').nth(0), '10', 'الكمية 10');
  await page.keyboard.press('Tab'); await v.wait(400);
  await v.say('10 × 120 + ضريبة 15% = <b>1,380</b>', 3500);
  await v.click('.nn-doc-save.t-Button--hot', '<b>ترحيل الفاتورة</b>');
  await v.say('الفاتورة رحلت: صرف 10 عبوات بمتوسط التكلفة، والقيد: العميل مدين / المبيعات والضريبة دائن، والتكلفة / المخزون', 5500);
  console.log('invoice: ' + await v.alerts());

  // ------------------------------------------------ 4) التحصيل
  await v.setStep('4 · التحصيل من العميل');
  await v.nav('التحصيل من العملاء');
  await v.click('تحصيل جديد', '<b>تحصيل جديد</b>');
  await v.select('#P24_CUST', 'الأمانة', 'العميل: تظهر فواتيره المفتوحة أسفل الشاشة');
  await v.type('#P24_AMOUNT', '1380', 'المبلغ');
  await v.select('#P24_PLACE', 'الحساب الجاري', 'إلى <b>البنك</b>');
  await v.select('#P24_METHOD', 'مدى', 'طريقة الدفع');
  await v.click(page.getByRole('button', { name: /تنفيذ التحصيل/ }).first(), '<b>تنفيذ التحصيل</b>: يخصص على الفواتير الأقدم');
  console.log('collect: ' + await v.alerts());
  await v.say('رصيد العميل صفر، وزاد رصيد البنك 1,380', 3000);

  // ------------------------------------------------ 5) نقطة البيع
  await v.setStep('5 · نقطة البيع');
  await v.nav('نقطة البيع');
  await v.click(page.locator('text=بدء البيع').first(), 'نختار نقطة البيع ← <b>بدء البيع</b>');
  await v.type('.nn-pos-float', '500', '<b>فتح الوردية</b> بالنقد الافتتاحي في الدرج');
  await v.click(page.getByRole('button', { name: 'فتح الوردية' }), null, false);
  await v.wait(1500);
  await v.type('#nnPosScan', 'زيت', 'امسح الباركود (أو اكتب الاسم) ثم Enter');
  await page.keyboard.press('Enter'); await v.wait(1500);
  await v.click(page.locator('.nn-pos-cart button').filter({ hasText: '+' }).first(), 'زيادة الكمية بزر <b>+</b>', false);
  await v.say('الإجمالي يحسب فوراً شاملاً الضريبة: 2 × 138 = <b>276</b>', 3000);
  await page.keyboard.press('F9'); await v.wait(1000);
  await v.say('<b>الدفع (F9)</b>: أكثر من طريقة في نفس البيع (نقدي + مدى...)', 3500);
  const cash = page.locator('.nn-pos-modal input[type="number"], .nn-pos-dlg input[type="number"]').first();
  await v.type(cash, '300', 'العميل دفع 300 نقداً');
  await v.say('<b>الباقي للعميل</b> يظهر تلقائياً: 24', 3000);
  const ap = page.locator('.nn-pos-autoprint'); if (await ap.count()) await ap.uncheck().catch(() => {});
  await v.click(page.getByRole('button', { name: /تأكيد البيع/ }), '<b>تأكيد البيع (Enter)</b> ويطبع الإيصال', false);
  await v.wait(2000);
  await v.say('تم البيع: إيصال برقم مسلسل ورمز QR للفاتورة المبسطة', 3500);

  // ------------------------------------------------ 6) إقفال الوردية
  await v.setStep('6 · إقفال الوردية');
  await v.click(page.getByRole('button', { name: /تقرير X/ }), 'نهاية اليوم: <b>تقرير X / إقفال الوردية</b>');
  await v.select('#P32_SHIFT', 'نقطة البيع 1', 'الوردية المفتوحة');
  await v.click('عرض التقرير', '<b>تقرير X</b>: المبيعات حسب طريقة الدفع والنقد المتوقع في الدرج');
  await v.say('النقد المتوقع = 500 افتتاحي + 276 مبيعات = <b>776</b>', 4000);
  await v.type('#P32_COUNTED', '776', 'يعد الكاشير النقد ويدخله؛ أي فرق يقيد عجزاً أو زيادة');
  await v.click(page.getByRole('button', { name: /إقفال الوردية وترحيل/ }), '<b>إقفال الوردية وترحيل القيد</b>');
  console.log('close: ' + await v.alerts());

  // ------------------------------------------------ 7) التقارير
  await v.setStep('7 · التقارير');
  await v.nav('التقارير');
  await v.select('#P50_REPORT', 'سجل المبيعات', '<b>سجل المبيعات ومجمل الربح</b>');
  await v.click('عرض');
  await v.say('لكل فاتورة: الصافي والتكلفة ومجمل الربح (120 − 85 = 35 للعبوة)', 5000);
  await v.select('#P50_REPORT', 'مبيعات نقاط البيع', 'و<b>مبيعات نقاط البيع والورديات</b>');
  await v.click('عرض');
  await v.say('كل وردية بكاشيرها وطرق الدفع والفروقات؛ وأيضاً كشف حساب العميل وأعمار الديون', 5000);
  await v.card('التالي', ['الفيديو 5: التصنيع', 'قائمة المواد وأمر الإنتاج وتكلفته'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
