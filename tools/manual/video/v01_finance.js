/* فيديو 2: المالية - تجهيز الأستاذ العام والنقدية (المدير)، سند قبض لرأس المال وسند مصروفات وقيد استحقاق (المحاسبة)،
   ثم الاعتماد والترحيل من المدير (فصل المهام) ودفتر الصندوق وميزان المراجعة.
   PW_PATH=... NOONA_VADMIN=... NOONA_VACC=... NOONA_VPWD=... node tools/manual/video/v01_finance.js <outDir> */
'use strict';
const video = require('./vlib.js');
const coa = require('./coa_scene.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, ACC = process.env.NOONA_VACC, PWD = process.env.NOONA_VPWD;

(async () => {
  const v = await video('noona_fin', out, 'v01_finance');
  const { page } = v;
  const row = (i) => page.locator('.nn-je-table tbody tr').nth(i);
  async function line(i, acc, amt, txt, side) {
    if (await page.locator('.nn-je-table tbody tr').count() <= i) await v.click('.nn-je-add', null, false);
    await v.type(row(i).locator('.nn-je-acc'), acc);
    await page.keyboard.press('Tab'); await v.wait(300);
    await v.type(row(i).locator(side === 'cr' ? '.nn-je-cr' : side === 'dr' ? '.nn-je-dr' : '.nn-je-amt'), amt);
    if (txt) await v.type(row(i).locator('.nn-je-txt'), txt);
  }
  async function listOpen(sel, text, note) {
    await v.click(page.locator('.a-IRR-table tr').filter({ hasText: text }).locator('td a').first(), note);
  }

  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('المالية في نونا بلس', ['تجهيز الأستاذ العام والنقدية', 'سند قبض · سند مصروفات · قيد يومية · الاعتماد · التقارير'], 4500, 'الفيديو القصير 2 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) المدير: التجهيز
  await v.setStep('1 · تجهيز المالية (المدير)');
  await v.login(ADMIN, PWD, 'يدخل <b>أحمد مدير النور</b> ويفتح تطبيق <b>المالية</b>');
  await v.say('أول مرة لكل شركة: زرا التجهيز في لوحة المالية', 3500);
  await v.click(page.getByRole('button', { name: /تجهيز الأستاذ العام/ }).first(),
    '<b>تجهيز الأستاذ العام</b>: دليل حسابات قياسي ودفتر رئيسي وفترات السنة');
  await v.click(page.getByRole('button', { name: /تجهيز النقدية/ }).first(), '<b>تجهيز النقدية</b>: الصندوق الرئيسي وترقيم السندات');
  await v.say('تم التجهيز. لوحة المالية تعرض الأستاذ العام والصناديق', 3500);
  await v.nav('دليل الحسابات');
  await v.say('<b>دليل الحسابات</b> جاهز بمستوياته، ونضيف عليه يدوياً ومن ملف', 3500);
  await coa(v, process.env.LONG === '1');
  await v.setStep('1 · تجهيز المالية (المدير)');
  await v.nav('الفترات المحاسبية');
  await v.say('التجهيز أنشأ <b>السنة المالية 2026</b>: تقويم ميلادي و12 فترة شهرية مفتوحة للترحيل', 4500);
  await v.say('بعد مراجعة الشهر تقفل فترته من «تغيير حالة فترة»: <b>مقفلة مبدئياً</b> تمنع الترحيل فيها', 4000);
  await v.click('فتح السنة المالية التالية', 'قبل نهاية السنة: <b>فتح السنة المالية التالية</b>');
  await v.say('أضيفت <b>2027</b> بفتراتها، وترقيم جديد للقيود والسندات (JV-2027-...). ولا تفتح أكثر من سنة مقدماً', 4500);
  await v.nav('مراكز التكلفة');
  await v.say('<b>مراكز التكلفة</b> الافتراضية جاهزة أيضاً: تختار في سطور القيود والسندات', 3500);

  // ------------------------------------------------ 2) المحاسبة: السندات والقيد
  await v.logout();
  await v.setStep('2 · سند قبض (المحاسبة)');
  await v.login(ACC, PWD, 'تدخل <b>سارة</b> بدور <b>المدير المالي</b> (من إدارة المؤسسة ← الأدوار)');
  await v.nav('سند قبض جديد');
  await v.say('<b>سند قبض</b>: إيداع رأس المال في الصندوق الرئيسي', 3500);
  await v.type('[data-k="party"]', 'شركاء مجموعة النور', 'استلمنا من');
  await v.type('[data-k="desc"]', 'إيداع رأس المال المدفوع', 'وذلك عن');
  await line(0, '3101', '100000', 'رأس المال', null);
  await v.say('الحساب المقابل <b>3101 رأس المال</b> والمبلغ؛ الإجمالي يظهر أسفل السند', 3500);
  await v.click('.nn-doc-save[data-a="SUBMIT"]', '<b>حفظ وإرسال للاعتماد</b>');

  await v.setStep('3 · سند مصروفات');
  await v.nav('سند مصروفات جديد');
  await v.say('<b>سند مصروفات</b> بأكثر من بند في سند واحد', 3000);
  await v.type('[data-k="party"]', 'مؤسسة الأفق العقارية', 'صرفنا إلى');
  await v.type('[data-k="desc"]', 'إيجار المعرض وفاتورة الكهرباء', 'وذلك عن');
  await line(0, '5202', '6000', 'إيجار شهر', null);
  await line(1, '5203', '850', 'كهرباء المعرض', null);
  await v.click('.nn-doc-save[data-a="SUBMIT"]', '<b>حفظ وإرسال للاعتماد</b>');

  await v.setStep('4 · قيد يومية');
  await v.nav('قيد جديد');
  await v.say('<b>قيد يومية</b>: إثبات فاتورة كهرباء مستحقة لم تدفع بعد', 3500);
  await v.type('[data-k="desc"]', 'إثبات كهرباء مستحقة لشهر أكتوبر', 'البيان');
  await line(0, '5203', '1200', 'كهرباء مستحقة', 'dr');
  await line(1, '2103', '1200', 'مصروفات مستحقة', 'cr');
  await v.say('المدين = الدائن؛ الفرق يظهر أسفل القيد إن وجد', 3000);
  await v.click('.nn-doc-save[data-a="SUBMIT"]', '<b>حفظ وإرسال للاعتماد</b>');

  // ------------------------------------------------ 3) المدير: الاعتماد والتقارير
  await v.logout();
  await v.setStep('5 · الاعتماد (المدير)');
  await v.login(ADMIN, PWD, '<b>فصل المهام</b>: يعتمد المستند شخص غير منشئه. يدخل أحمد');
  await v.nav('السندات');
  await v.say('السندات بانتظار الاعتماد', 2500);
  await listOpen(null, 'قبض', 'نفتح <b>سند القبض</b>');
  await v.click('اعتماد وترحيل', '<b>اعتماد وترحيل</b>: يرحل القيد ويرفع رصيد الصندوق');
  await v.nav('السندات');
  await listOpen(null, 'مصروفات', 'ثم <b>سند المصروفات</b>');
  await v.click('اعتماد وترحيل', '<b>اعتماد وترحيل</b> (لا يصرف الصندوق فوق رصيده)');
  await v.nav('القيود اليومية');
  await listOpen(null, 'كهرباء مستحقة', 'ثم <b>القيد</b> بانتظار الاعتماد');
  await v.click('اعتماد وترحيل', '<b>اعتماد وترحيل</b>');
  await v.say('القيد مرحّل؛ يظهر زر <b>عكس القيد</b> للتصحيح بدل التعديل', 3500);
  console.log('approve: ' + await v.alerts());

  await v.setStep('6 · التقارير');
  await v.nav('دفتر الصندوق والبنك');
  await v.select('#P44_PLACE', 'الصندوق الرئيسي', 'نختار <b>الصندوق الرئيسي</b> والفترة');
  await v.click('عرض', '<b>دفتر الصندوق</b>: الحركة والرصيد التراكمي');
  await v.say('رصيد الصندوق بعد القبض والصرف: 100,000 − 6,850 = <b>93,150</b>', 4500);
  await v.nav('ميزان المراجعة');
  await v.say('<b>ميزان المراجعة</b>: إجمالي المدين = إجمالي الدائن', 4000);
  await v.click(page.locator('table a').filter({ hasText: '5203' }).first(), 'النقر على الحساب يفتح <b>كشف الحساب</b>');
  await v.say('كشف الحساب: كل حركة بتاريخها وقيدها والرصيد التراكمي؛ والنقر على القيد يفتحه', 4500);
  await v.nav('قائمة الربح أو الخسارة');
  await v.click('عرض', null).catch(() => {});
  await v.say('<b>قائمة الربح أو الخسارة</b>: المصروفات 8,050 (إيجار 6,000 + كهرباء 850 + 1,200 مستحقة)', 5000);
  await v.nav('قائمة المركز المالي');
  await v.click('عرض', null).catch(() => {});
  await v.say('<b>المركز المالي</b>: الصندوق 93,150 = مستحقات 1,200 + حقوق الملكية 91,950', 5500);
  await v.card('التالي', ['الفيديو 3: سلسلة الإمداد', 'الأصناف والأرصدة وفاتورة المشتريات'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
