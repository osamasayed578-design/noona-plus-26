/* فيديو 12: مركز التقارير والتكاملات - مركز التقارير (الوحدات، البحث، فتح التقرير في نظامه)، ثم التكاملات في إدارة المؤسسة:
   لوحة التكاملات، عميل API، استيراد العملاء من CSV، ونقاط النهاية وتوثيقها.
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v11_reports_integrations.js <outDir> */
'use strict';
const path = require('path');
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;

(async () => {
  const v = await video('noona_bi', out, 'v11_reports_integrations');
  const { page } = v;

  await page.goto('http://localhost:' + (process.env.NOONA_PORT || 8090) + '/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('مركز التقارير والتكاملات', ['كل تقارير الأنظمة في مكان واحد', 'واجهة API · الاستيراد · الربط مع الأنظمة الأخرى'], 4500, 'الفيديو القصير 12 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) مركز التقارير
  await v.setStep('1 · مركز التقارير');
  await v.login(ADMIN, PWD, 'يفتح أحمد <b>مركز التقارير</b>');
  await v.say('<b>كل التقارير</b> مجمعة حسب الوحدة، وتظهر حسب اشتراك المؤسسة وصلاحيات المستخدم', 4500);
  await v.type('#nnRhSearch', 'ميزان', '<b>بحث</b> في كل التقارير بالاسم أو الوصف');
  await v.wait(1500);
  const hit = page.locator('a').filter({ hasText: 'ميزان المراجعة' }).first();
  if (await hit.count()) {
    await v.click(hit, 'النتيجة تظهر داخل وحدتها مع وصف كل تقرير');
    await v.wait(800);
    const card = page.getByText('ميزان المراجعة', { exact: true }).first();
    if (await card.count()) {
      await v.click(card, 'النقر على التقرير يفتحه في نظامه (المالية) مباشرة');
      await v.say('<b>ميزان المراجعة</b> بأرقام الفيديوهات السابقة', 4000);
      await page.goBack().catch(() => {}); await v.settle();
    }
  }
  await page.locator('#nnRhSearch').fill('').catch(() => {});
  await v.wait(800);
  const inv = page.locator('a, button').filter({ hasText: 'عرض التقارير' }).nth(3);
  if (await inv.count()) {
    await v.click(inv, 'أو نفتح <b>وحدة</b>: قائمة تقاريرها بوصف كل تقرير', false);
    await v.wait(1500);
    await v.say('النجمة تضيف التقرير إلى <b>المفضلة</b> لتظهر أعلى المركز', 3500);
  }

  // ------------------------------------------------ 2) التكاملات
  await v.setStep('2 · لوحة التكاملات');
  await v.switchApp('noona_admin');
  await v.nav('لوحة التكاملات');
  await v.say('<b>التكاملات</b> في إدارة المؤسسة: عملاء API، الاشتراكات (Webhooks)، الرسائل، الاستيراد', 4500);

  await v.setStep('3 · عميل API');
  await v.nav('عملاء API');
  await v.type('#P71_NAME', 'تطبيق المتجر الإلكتروني', 'عميل API لتطبيق خارجي (متجر، تطبيق جوال، نظام آخر)');
  await v.select('#P71_ROLE', '', 'دوره يحدد ما يصل إليه من البيانات');
  await page.locator('#P71_ROLE').selectOption({ index: 1 }).catch(() => {});
  await v.click('إنشاء العميل', '<b>إنشاء العميل</b>');
  await v.say('المعرف والسر يظهران <b>مرة واحدة</b> فقط: يحفظهما المطور؛ ويمكن إصدار سر جديد لاحقاً', 4500);

  await v.setStep('4 · استيراد البيانات');
  await v.nav('استيراد البيانات');
  await v.select('#P76_TYPE', 'العملاء', '<b>استيراد</b> العملاء أو الموردين أو الأصناف من ملف CSV');
  await page.locator('#P76_FILE input[type=file]').setInputFiles(path.join(__dirname, 'assets', 'customers_sample.csv'));
  await v.wait(800);
  await v.click('استيراد', '<b>استيراد</b>');
  console.log('import: ' + await v.alerts());
  await v.say('تقرير الاستيراد: الصفوف الناجحة، والخاطئة أو المكررة بسببها دون إيقاف الباقي', 4500);

  await v.setStep('5 · نقاط النهاية');
  await v.nav('نقاط النهاية والتوثيق');
  await v.say('<b>نقاط النهاية</b> وتوثيقها بصيغة OpenAPI: العملاء، الأصناف، الفواتير، التحصيل، ميزان المراجعة...', 5000);
  await v.card('اكتملت سلسلة الفيديوهات', ['التأسيس · المالية · سلسلة الإمداد · المبيعات · التصنيع · الموارد البشرية',
    'المستندات · العقارات · الضيافة · المستشفيات · خدمة السيارات · التقارير والتكاملات'], 6000, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
