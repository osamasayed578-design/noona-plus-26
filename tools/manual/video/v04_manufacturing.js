/* فيديو 5: التصنيع - تجهيز التصنيع، مركز عمل بتكلفة الساعة، قائمة مواد ومسار تصنيع، أمر إنتاج: صرف الخامات، تسجيل العملية،
   استلام المنتج، الإقفال والانحرافات، وبطاقة التكلفة. يتطلب prep_mfg.js قبله (فلتر بمخزون ومنتج «طقم الصيانة الدورية»).
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v04_manufacturing.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;

(async () => {
  const v = await video('noona_mfg', out, 'v04_manufacturing');
  const { page } = v;
  const K = (k) => page.locator(`[data-k="${k}"], #${k}`).first();
  const tab = (t) => page.locator('button').filter({ hasText: new RegExp('^\\s*' + t + '\\s*$') }).first();

  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('التصنيع في نونا بلس', ['مركز العمل · قائمة المواد · مسار التصنيع', 'أمر الإنتاج: صرف، تشغيل، استلام، تكلفة فعلية وانحرافات'], 4500, 'الفيديو القصير 5 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) التجهيز
  await v.setStep('1 · تجهيز التصنيع');
  await v.login(ADMIN, PWD, 'المنتج: <b>طقم الصيانة الدورية</b> = عبوة زيت + فلتر، يجمع ويغلف في الورشة');
  await v.click(page.getByRole('button', { name: /تجهيز التصنيع/ }).first(),
    '<b>تجهيز التصنيع</b>: حسابات الإنتاج تحت التشغيل والعمالة والأعباء المحملة والانحرافات، وترقيم الأوامر');

  // ------------------------------------------------ 2) مركز العمل
  await v.setStep('2 · مركز العمل');
  await v.nav('مراكز العمل');
  await v.click('مركز عمل جديد', '<b>مركز عمل جديد</b>');
  await v.type('#P11_CODE', 'WC-PACK', 'رمز المركز واسمه');
  await v.type('#P11_NAME', 'خط تجميع الأطقم');
  await v.type('#P11_CAP', '8', 'الطاقة: ساعات العمل اليومية');
  await v.type('#P11_LABOR', '60', '<b>تكلفة الساعة</b>: عمالة 60 وأعباء 20 (تحمل على المنتج)');
  await v.type('#P11_OVERHEAD', '20');
  await v.click('حفظ', '<b>حفظ</b>');

  // ------------------------------------------------ 3) قائمة المواد
  await v.setStep('3 · قائمة المواد');
  await v.nav('قوائم المواد');
  await v.click('قائمة مواد جديدة', '<b>قائمة مواد جديدة</b>');
  await v.select(K('item'), 'طقم الصيانة', 'المنتج التام');
  await v.type(K('base'), '1', 'الكميات لكل 1 طقم');
  await v.type('.nn-mfg-find', 'زيت محرك', 'المكونات: بحث بالاسم أو الباركود ثم Enter');
  await page.keyboard.press('Enter'); await v.wait(1500);
  await v.type('.nn-mfg-find', 'فلتر زيت');
  await page.keyboard.press('Enter'); await v.wait(1500);
  await v.say('لكل مكون: الكمية، نسبة الهالك، العملية التي يصرف لها، والبدائل؛ وتكلفته بالمتوسط المرجح', 4500);
  await v.click(page.getByRole('button', { name: 'حفظ ونشر' }), '<b>حفظ ونشر</b>: الإصدار v1 يصبح الافتراضي لأوامر الإنتاج', false);
  await v.wait(2500);

  // ------------------------------------------------ 4) المسار
  await v.setStep('4 · مسار التصنيع');
  await v.nav('مسارات التصنيع');
  await v.click('مسار جديد', '<b>مسار جديد</b>: العمليات بالترتيب ومراكزها وأزمنتها');
  await v.select(K('item'), 'طقم الصيانة', 'المنتج');
  await v.type(K('lot'), '10', 'حجم الدفعة المعتاد (يوزع عليه زمن الإعداد)');
  await v.click('.nn-je-add', '<b>+ عملية</b>', false);
  const r = page.locator('.nn-mfg tbody tr').first();
  await v.type(r.locator('[data-c="d"]'), 'تجميع وتغليف الطقم', 'وصف العملية');
  await v.select(r.locator('[data-c="wc"]'), 'WC-PACK', 'مركز العمل');
  await v.type(r.locator('[data-c="setup"]'), '15', 'زمن الإعداد 15 دقيقة للدفعة، وزمن التشغيل 6 دقائق للطقم');
  await v.type(r.locator('[data-c="run"]'), '6');
  await v.say('التكلفة المعيارية للعملية تحسب فوراً من تكلفة ساعة المركز', 3500);
  await v.click(page.getByRole('button', { name: 'حفظ ونشر' }), '<b>حفظ ونشر</b>', false);
  await v.wait(2500);

  // ------------------------------------------------ 5) أمر الإنتاج
  await v.setStep('5 · أمر إنتاج');
  await v.nav('أمر إنتاج جديد');
  await v.select(K('item'), 'طقم الصيانة', 'المنتج: يأخذ قائمة المواد والمسار المنشورين');
  await v.type(K('qty'), '10', 'الكمية المخططة: 10 أطقم');
  await v.say('مستودع صرف الخامات ومستودع استلام المنتج، والأولوية وتواريخ التنفيذ', 3500);
  await v.click(page.getByRole('button', { name: /اعتماد وإطلاق/ }), '<b>اعتماد وإطلاق للتنفيذ</b>', false);
  await v.wait(3000); await v.settle();
  await v.say('MO-000001: التكلفة المعيارية للطقم والتقديرية للأمر؛ وتبويبات التنفيذ', 4500);

  await v.setStep('6 · صرف الخامات');
  await v.say('<b>الخامات</b>: المطلوب والمصروف والمتبقي ورصيد المستودع؛ الكمية المقترحة = المتبقي', 4000);
  await v.click(page.getByRole('button', { name: /صرف الكميات المحددة/ }), '<b>صرف الكميات المحددة</b> بالمتوسط المرجح', false);
  await v.wait(3000);

  await v.setStep('7 · تسجيل العملية');
  await v.click(tab('العمليات'), 'تبويب <b>العمليات</b>', false);
  await v.type(K('setup'), '15', 'الزمن الفعلي: إعداد 15 وتشغيل 65 دقيقة');
  await v.type(K('run'), '65');
  await v.type(K('good'), '10', 'الكمية السليمة 10');
  await v.select(K('done'), 'منتهية', 'العملية منتهية');
  await v.click(page.getByRole('button', { name: /تسجيل وترحيل التكلفة/ }), '<b>تسجيل وترحيل التكلفة</b>: عمالة وأعباء على الإنتاج تحت التشغيل', false);
  await v.wait(3000);

  await v.setStep('8 · استلام المنتج');
  await v.click(tab('الإنتاج والجودة'), 'تبويب <b>الإنتاج والجودة</b>', false);
  await v.type(K('oqty'), '10', 'الكمية المستلمة للمستودع');
  await v.click(page.getByRole('button', { name: /تسجيل الاستلام/ }), '<b>تسجيل الاستلام</b>: يدخل المنتج المخزون بتكلفته', false);
  await v.wait(3000);

  await v.setStep('9 · التكلفة والإقفال');
  await v.click(tab('التكلفة والقيود'), 'تبويب <b>التكلفة والقيود</b>', false);
  await v.say('المعياري مقابل الفعلي لكل عنصر: خامات، عمالة، أعباء', 4000);
  const close = page.getByRole('button', { name: /إقفال/ }).first();
  if (await close.count()) {
    await v.click(close, '<b>إقفال الأمر</b>: يرحل الانحرافات ويغلق الإنتاج تحت التشغيل', false);
    await v.wait(3000);
  }
  console.log('order: ' + (await page.locator('.nn-mfg-msg, .nn-msg, #t_Alert_Success, #t_Alert_Notification').allInnerTexts()).join('|').replace(/\s+/g, ' ').slice(0, 300));
  await v.click('بطاقة التكلفة', '<b>بطاقة التكلفة</b>: تقرير الأمر للطباعة');
  await v.say('تكلفة الطقم الفعلية = الخامات + العمالة + الأعباء، والانحراف عن المعياري', 5000);

  await v.setStep('10 · التقارير');
  await v.nav('التقارير');
  await v.say('<b>تقارير التصنيع</b>: أوامر الإنتاج وتكلفتها، الانحرافات، استهلاك الخامات، أحمال المراكز', 4500);
  await v.card('التالي', ['الفيديو 6: الموارد البشرية والرواتب', 'الموظف والعقد ومسير الرواتب'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
