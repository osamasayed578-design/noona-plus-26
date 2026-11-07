/* فيديو 7: المستندات والمراسلات - تجهيز الأرشيف، أرشفة مستند بملفه وصلاحيته، المنتهية والقريبة الانتهاء، البحث،
   ثم مذكرة داخلية بتعليمة ومهلة لموظفة، تستلمها وترد عليها.
   PW_PATH=... NOONA_VADMIN=... NOONA_VACC=... NOONA_VPWD=... node tools/manual/video/v06_documents.js <outDir> */
'use strict';
const path = require('path');
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, ACC = process.env.NOONA_VACC, PWD = process.env.NOONA_VPWD;
const day = (n) => new Date(Date.now() + n * 864e5).toISOString().slice(0, 10);

(async () => {
  const v = await video('noona_doc', out, 'v06_documents');
  const { page } = v;

  await page.goto('http://localhost:' + (process.env.NOONA_PORT || 8090) + '/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('المستندات والمراسلات', ['الأرشيف الإلكتروني وصلاحية المستندات', 'المراسلات الداخلية بالتعليمات والمهل'], 4500, 'الفيديو القصير 7 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) الأرشيف
  await v.setStep('1 · تجهيز الأرشيف');
  await v.login(ADMIN, PWD, 'يفتح أحمد تطبيق <b>المستندات والمراسلات</b>');
  if (await page.getByRole('button', { name: 'تجهيز الأرشيف' }).count()) {
    await v.click('تجهيز الأرشيف', '<b>تجهيز الأرشيف</b>: أنواع المستندات وقواعد الأرشفة (مثل: سند الصرف يتطلب أصله)');
  }

  await v.setStep('2 · أرشفة مستند');
  await v.nav('أرشفة مستند');
  await v.select('#P12_TYPE', 'السجل التجاري', 'نوع المستند: يحدد السرية والصلاحية المطلوبة');
  await v.type('#P12_TITLE', 'السجل التجاري - شركة النور للتجارة', 'العنوان والرقم المرجعي');
  await v.type('#P12_REF', '1010123456');
  await v.type('#P12_LOC', 'الخزنة الرئيسية - ملف 3', '<b>مكان الأصل الورقي</b>');
  await v.type('#P12_DATE_input', day(-345), 'تاريخ المستند');
  await page.keyboard.press('Escape');
  await v.select('#P12_CONF', 'داخلي', 'درجة السرية');
  await v.type('#P12_VFROM_input', day(-345), '<b>الصلاحية</b>: من وإلى؛ ينبه النظام قبل الانتهاء');
  await v.type('#P12_VTO_input', day(20));
  await page.keyboard.press('Escape'); await page.locator('#P12_LOC').click(); await v.wait(400);
  await v.say('الملف: PDF أو صورة؛ يحفظ في قاعدة البيانات أو في مكان الحفظ الخارجي للشركة', 3500);
  await page.locator('#P12_FILE_input').setInputFiles(path.join(__dirname, 'assets', 'cr_sample.pdf'));
  await v.wait(800);
  await v.click('أرشفة', '<b>أرشفة</b>');
  console.log('archive: ' + await v.alerts());

  await v.setStep('3 · الصلاحية والبحث');
  await v.nav('المنتهية والقريبة الانتهاء');
  await v.say('السجل التجاري ينتهي خلال 20 يوماً فيظهر هنا وفي تنبيهات «مهامي»', 4500);
  await v.nav('البحث في الأرشيف');
  await v.say('<b>البحث في الأرشيف</b>: بالنوع والرقم والعنوان والطرف؛ ويفتح الملف في عارض داخل النظام', 4500);

  // ------------------------------------------------ 2) المراسلات
  await v.setStep('4 · مذكرة داخلية');
  await v.nav('المراسلات');
  await v.say('<b>المراسلات</b>: صندوق وارد بأسلوب البريد، والمطلوب مني، وسجلا الوارد والصادر الرسمي', 4000);
  await v.click('.nn-mail-compose', '<b>إنشاء</b>', false);
  await v.wait(800);
  const to = page.locator('.nn-mail-composers .nn-mail-rcp input').first();
  await v.type(to, 'سارة', 'إلى: بحث بالاسم (موظف أو إدارة)');
  await v.wait(1200);
  await v.click(page.locator('.nn-mail-sug .nn-mail-sg').first(), null, false);
  await v.type('.nn-mail-subj', 'مراجعة فواتير الموردين لشهر أكتوبر', 'الموضوع');
  await v.select('.nn-mail-prio', 'مهمة', 'الأولوية والتعليمة والمهلة: تصبح مهمة على المستلم');
  await v.select('.nn-mail-ins', 'لاتخاذ اللازم');
  await page.locator('.nn-mail-due').fill(day(3)); await v.wait(500);
  await v.type('.nn-mail-txt', 'نأمل مراجعة فواتير الموردين المستحقة هذا الشهر وتجهيز جدول السداد.', 'نص المذكرة');
  await v.click('.nn-mail-send', '<b>إرسال</b>: تأخذ رقماً مسلسلاً وتسجل في سجل المراسلات', false);
  await v.wait(2500);

  await v.logout();
  await v.setStep('5 · الاستلام والرد');
  await v.login(ACC, PWD, 'تدخل <b>سارة</b>: تظهر المذكرة في الوارد و<b>المطلوب مني</b> بمهلتها');
  await v.nav('المراسلات');
  await v.click(page.locator('.nn-mail-nav, .nn-mail-side').locator('text=المطلوب مني').first(), '<b>المطلوب مني</b>', false);
  await v.wait(1500);
  await v.click(page.locator('.nn-mail-row, .nn-mail-item').first(), 'نفتح المذكرة: التعليمة والمهلة', false);
  await v.wait(1500);
  await v.say('من هنا: رد، تحويل، أو <b>إحالة</b> لموظف آخر بتعليمة ومهلة جديدة', 3500);
  const doneBtn = page.locator('button').filter({ hasText: 'تم الإنجاز' }).first();
  if (await doneBtn.count()) {
    await v.click(doneBtn, '<b>تم الإنجاز</b>: تغلق المهمة ويرى المرسل أنها أنجزت، ثم نرد عليه', false);
    await v.wait(800);
    await v.type('.nn-mail-note', 'تمت مراجعة 6 فواتير وإعداد جدول السداد', 'ما الذي تم؟ (ملاحظة الإنجاز)');
    await v.click(page.getByRole('button', { name: 'تأكيد الإنجاز' }), '<b>تأكيد الإنجاز</b>', false);
    await v.wait(2000);
  }
  await v.click(page.locator('[data-a="reply"]').first(), '<b>رد</b>', false);
  await v.wait(1000);
  await v.type(page.locator('.nn-mail-composers .nn-mail-txt').last(), 'تمت المراجعة، وجدول السداد مرفق في المالية.', 'نص الرد');
  await v.click(page.locator('.nn-mail-composers .nn-mail-send').last(), '<b>إرسال</b>', false);
  await v.wait(2500);
  await v.say('الرد يصل لأحمد مرتبطاً بالمذكرة الأصلية، ويظهر تسلسل المراسلة كاملاً', 4000);
  await v.card('التالي', ['الفيديو 8: العقارات والضيافة', 'الوحدات والعقود والحجوزات'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
