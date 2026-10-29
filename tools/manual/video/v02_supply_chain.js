/* فيديو 3: سلسلة الإمداد - تجهيز المخزون والمشتريات، صنف بباركود، مورد، فاتورة مشتريات آجلة تستلم المخزون، سداد المورد من الصندوق،
   ثم تقرير أرصدة المخزون. يكمل مؤسسة الفيديو 2 (الأستاذ العام والنقدية مجهزان والصندوق به رصيد).
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v02_supply_chain.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;

(async () => {
  const v = await video('noona_scm', out, 'v02_supply_chain');
  const { page } = v;

  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('سلسلة الإمداد في نونا بلس', ['الأصناف والموردون', 'فاتورة مشتريات تستلم المخزون · سداد المورد · أرصدة المخزون'], 4500, 'فيديو 3 · إدخال حقيقي · مجموعة النور');

  // ------------------------------------------------ 1) التجهيز
  await v.setStep('1 · تجهيز المخزون والمشتريات');
  await v.login(ADMIN, PWD, 'يدخل <b>أحمد</b> ويفتح تطبيق <b>سلسلة الإمداد</b>');
  await v.click(page.getByRole('button', { name: /تجهيز المخزون/ }).first(),
    '<b>تجهيز</b> مرة واحدة: الفئات بحساباتها، المستودع الرئيسي، الضريبة، شروط الدفع، الترقيم');
  await v.say('الفئات جاهزة بحسابات المخزون والتكلفة والإيراد، والمستودع الرئيسي WH-01', 3500);

  // ------------------------------------------------ 2) الصنف
  await v.setStep('2 · صنف جديد');
  await v.nav('صنف جديد');
  await v.say('<b>بطاقة الصنف</b>: مشتركة لكل شركات المؤسسة، وأرصدتها لكل شركة ومستودع', 3500);
  await v.type('[data-k="name"]', 'زيت محرك 5W-30 (4 لتر)', 'اسم الصنف');
  await v.select('[data-k="type"]', 'قطعة غيار', 'النوع والفئة: الفئة تحدد حسابات القيد');
  await v.select('[data-k="cat"]', 'قطع غيار السيارات');
  await v.select('[data-k="uom"]', 'عبوة', 'وحدة القياس');
  await v.type('[data-k="brand"]', 'Mobil 1', 'العلامة التجارية');
  await v.click('.nn-it-gen', 'لا يوجد باركود؟ <b>توليد باركود داخلي</b> (أو امسح باركود المصنع بالقارئ)', false);
  await v.type('[data-k="price"]', '120', 'سعر البيع والضريبة (ضريبة الدولة فقط)');
  await v.type('[data-k="min"]', '10', '<b>الحد الأدنى</b> للتنبيه في تقرير «تحت حد الطلب»');
  await v.click('.nn-it-save', '<b>حفظ الصنف</b>: رقمه تلقائي ITM-000001');
  await v.say('تظهر أقسام قطع الغيار: رقم OEM، التوافق مع المركبات، والبدائل', 3500);

  // ------------------------------------------------ 3) المورد
  await v.setStep('3 · مورد جديد');
  await v.nav('الموردون');
  await v.click('مورد جديد', 'الموردون ← <b>مورد جديد</b>');
  await v.type('#P31_NAME', 'شركة الخليج لقطع الغيار', 'اسم المورد');
  await v.type('#P31_TAX', '300000000000003', 'الرقم الضريبي (يتحقق النظام من صيغته)');
  await v.type('#P31_PHONE', '0551234567', 'الجوال');
  await v.select('#P31_TERM', 'صافي 30', 'شروط الدفع: تحدد تاريخ استحقاق فواتيره');
  await v.click('حفظ', '<b>حفظ</b>');

  // ------------------------------------------------ 4) فاتورة المشتريات
  await v.setStep('4 · فاتورة مشتريات');
  await v.nav('فاتورة مشتريات جديدة');
  await v.say('<b>فاتورة المشتريات</b> تستلم البضاعة للمستودع وترحل القيد في خطوة واحدة', 3500);
  await v.select('[data-k="sup"]', 'الخليج', 'المورد');
  await v.type('[data-k="supInv"]', 'GLF-7781', 'رقم فاتورة المورد (يمنع إدخالها مرتين)');
  await v.select('[data-k="wh"]', 'المستودع الرئيسي', 'مستودع الاستلام');
  await v.select('[data-k="mode"]', 'آجل', 'طريقة الدفع: <b>آجل</b> على حساب المورد');
  await v.type('.nn-td-find', 'زيت', 'امسح الباركود أو اكتب الاسم ثم Enter');
  await page.keyboard.press('Enter'); await v.wait(1500);
  const r = page.locator('.nn-td-table tbody tr').first();
  await v.type(r.locator('input').nth(0), '40', 'الكمية');
  await v.type(r.locator('input').nth(1), '85', 'سعر الشراء');
  await page.keyboard.press('Tab'); await v.wait(400);
  await v.say('الضريبة 15% تحسب للسطر، والإجمالي <b>3,910</b> أسفل الفاتورة', 3500);
  await v.click('.nn-doc-save.t-Button--hot', '<b>ترحيل واستلام</b>');
  await v.say('رقم الفاتورة PI-000001: زاد المخزون 40 عبوة، وقيد: المخزون والضريبة مدين / المورد دائن', 4500);
  console.log('purchase: ' + await v.alerts());

  // ------------------------------------------------ 5) السداد
  await v.setStep('5 · سداد المورد');
  await v.click('سداد للمورد', 'من الفاتورة مباشرة: <b>سداد للمورد</b>');
  await v.select('#P38_SUP', 'الخليج', 'المورد');
  await v.type('#P38_AMOUNT', '3910', 'المبلغ');
  await v.select('#P38_PLACE', 'الصندوق الرئيسي', 'من <b>الصندوق الرئيسي</b> (لا يصرف فوق رصيده)');
  await v.select('#P38_METHOD', 'نقدي');
  await v.click(page.getByRole('button', { name: /تنفيذ السداد/ }).first(), '<b>تنفيذ السداد</b>: يخصص على الفواتير الأقدم استحقاقاً');
  console.log('pay: ' + await v.alerts());
  await v.say('تم السداد: رصيد المورد صفر، ونقص الصندوق 3,910', 3500);

  // ------------------------------------------------ 6) التقرير
  await v.setStep('6 · أرصدة المخزون');
  await v.nav('التقارير');
  await v.select('#P50_REPORT', 'أرصدة المخزون', 'التقارير: شاشة واحدة بمرشحات موحدة');
  await v.click('عرض', '<b>أرصدة المخزون وقيمته</b>');
  await v.say('40 عبوة بمتوسط تكلفة 85 = <b>3,400</b> (الضريبة لا تدخل التكلفة)', 5000);
  await v.select('#P50_REPORT', 'سجل المشتريات', 'ومن نفس الشاشة: <b>سجل المشتريات</b>');
  await v.click('عرض');
  await v.say('كل فاتورة بالمورد والصافي والضريبة؛ وتقارير أخرى: بطاقة الصنف، تحت حد الطلب، كشف حساب المورد', 5000);
  await v.nav('الأصناف');
  await v.say('<b>قائمة الأصناف</b>: بحث بالاسم أو الباركود أو رقم القطعة، مع الرصيد والسعر', 4000);
  await v.card('التالي', ['الفيديو 4: المبيعات ونقاط البيع', 'العملاء وفاتورة البيع والبيع السريع'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
