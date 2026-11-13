/* NOONA PLUS | الفيديو القصير لمعرض LEAP (دقيقتان إلى ثلاث): مسار العرض الثابت بشرح عربي على الشاشة.
   جزء المندوب يسجل بمقاس الجوال وجزء المحاسب والمدير والقابضة بمقاس الشاشة، ثم يركبان بـ ffmpeg (tools/demo/leap_video.sh).
   PW_PATH=playwright NOONA_PORT=8091 DST_USER=.. DST_PWD=.. RYD_USER=.. RYD_PWD=.. node tools/demo/leap_video.js <مجلد> mobile|desktop */
'use strict';
const video = require('../manual/video/vlib.js');
const [out, part] = process.argv.slice(2);
const E = process.env;

async function mobile() {
  const v = await video('noona_dst', out, 'leap_mobile', { width: 390, height: 844, typeDelay: 25,
    context: { permissions: ['geolocation'], geolocation: { latitude: 24.6840, longitude: 46.6850 }, locale: 'ar-SA' } });
  const { page } = v;
  await page.goto(`http://localhost:${E.NOONA_PORT || 8090}/ords/r/noonaplus/noona_dst/home`).catch(() => {});
  await v.card('المندوب في الميدان', ['من جواله: يزور ويبيع ويحصّل'], 2600, 'نونا بلس · التوزيع والمبيعات الميدانية');
  await v.login(E.DST_USER, E.DST_PWD);
  await v.go('home');
  await v.say('خطة اليوم: محلات المندوب <b>مرتبة على خط السير</b> مع الملاحة', 3600);
  await v.click(page.locator('.nn-dst-stop .nn-dst-go').first(), 'يفتح زيارة المحل الأول');
  await v.say('رصيد المحل وآخر مشترياته أمامه قبل البيع', 3000);
  await v.click('.nn-dst-checkin', 'يسجل حضوره <b>بالموقع</b>', false); await v.wait(2500); await v.settle();
  const plus = page.locator('[data-item="P2_LINES"] .nn-dst-item:visible .nn-dst-plus');
  await v.click(plus.first(), 'يبيع من <b>مخزون سيارته</b>', false); await plus.first().click(); await plus.first().click();
  if (await plus.count() > 1) { await v.click(plus.nth(1), null, false); await plus.nth(1).click(); }
  await v.click('.nn-dst-fill', 'الدفع نقداً', false);
  await v.click(page.getByRole('button', { name: 'إصدار الفاتورة', exact: true }), 'ضغطة واحدة: <b>فاتورة ضريبية</b>، خصم مخزون، وقيد محاسبي');
  await v.say('صدرت الفاتورة، وترسل للمحل <b>بواتساب</b>', 3200);
  await page.selectOption('#P2_CM', 'BANK_TRANSFER'); await v.wait(300);
  await v.type('#P2_CAMT', '50', 'تحصيل <b>بتحويل بنكي</b>');
  await v.type('#P2_CREF', 'LEAP' + String(Date.now()).slice(-7), 'برقم إشعار التحويل');
  await v.click(page.getByRole('button', { name: 'تسجيل التحصيل', exact: true }));
  await v.say('التحويل ينتظر <b>تأكيد المحاسب</b> قبل أن يخفض الرصيد', 3600);
  await v.click(page.getByRole('button', { name: 'إنهاء الزيارة والمغادرة', exact: true }), 'ينهي الزيارة وينتقل للمحل التالي');
  await v.wait(1500);
  console.log('saved ' + await v.done());
}

async function desktop() {
  const v = await video('noona_dst', out, 'leap_desktop', { typeDelay: 25 });
  const { page } = v;
  await page.goto(`http://localhost:${E.NOONA_PORT || 8090}/ords/r/noonaplus/noona_dst/home`).catch(() => {});
  await v.card('في المكتب', ['المحاسب يؤكد، والدفاتر تتحدث وحدها، والمدير يرى كل شيء'], 2800, 'نونا بلس');
  await v.login(E.DST_USER, E.DST_PWD);
  await v.go('collections');
  await v.say('المحاسب: تحصيلات المندوبين <b>بانتظار التأكيد</b>', 3000);
  await v.click(page.locator('.a-IRR-table tr', { hasText: 'LEAP' }).first().locator('a').first(), 'يفتح التحويل ويطابقه مع البنك');
  await v.click(page.getByRole('button', { name: 'تأكيد وترحيل', exact: true }), 'يؤكد: يرحّل للبنك و<b>ينخفض رصيد المحل</b>');
  await v.wait(1500);
  await v.switchApp('noona_fin'); await v.go('journal-register');
  await v.say('<b>لم يدخل أحد قيداً بيده</b>: كل ما فعله المندوب وصل إلى الدفاتر تلقائياً', 4600);
  await v.switchApp('noona_dst'); await v.go('map'); await v.wait(2000);
  await v.say('مدير المبيعات: المحلات <b>على الخريطة</b>', 3000);
  await v.go('performance');
  await v.say('وأداء كل مندوب مقابل هدفه', 3000);
  await v.switchApp('noona_hub'); await v.go('home');
  await v.say('المالك: النقد اليوم، المبيعات، والتنبيهات في <b>لوحة واحدة</b>', 3800);
  await v.go('forecast');
  await v.say('و<b>التنبؤ النقدي</b> لتسعين يوماً: يرى المشكلة قبل وقوعها', 4200);
  await v.switchApp('noona_bi'); await v.go('analytics'); await v.wait(1500);
  await v.say('تحليلات جاهزة لكل نظام', 2800);
  // القابضة
  await v.logout();
  await page.goto(`http://localhost:${E.NOONA_PORT || 8090}/ords/r/noonaplus/noona_master/home`).catch(() => {});
  await v.card('والمجموعة القابضة', ['ثلاث شركات في قائمة موحدة واحدة'], 2600, 'نونا بلس · المالية');
  await v.switchApp('noona_master');
  await v.login(E.RYD_USER, E.RYD_PWD);
  await page.goto(`http://localhost:${E.NOONA_PORT || 8090}/ords/r/noonaplus/noona_fin/consolidated?session=${v.sess}`); await v.settle();
  await v.say('<b>القوائم المالية الموحدة</b>: عمود لكل شركة، والاستبعادات، والموحد', 4200);
  await page.evaluate(() => window.scrollTo({ top: 420, behavior: 'smooth' })); await v.wait(2600);
  await v.card('نونا بلس', ['نظام واحد يشغّل المجموعة متعددة الأنشطة', 'من جوال المندوب حتى القوائم الموحدة', 'مصنع · عقار · فندق · مستشفى · نقل · توزيع · صيدلية'], 5200, 'NOONA PLUS ERP');
  console.log('saved ' + await v.done());
}
(part === 'mobile' ? mobile() : desktop()).catch((e) => { console.error('ERR', e.message.split('\n')[0]); process.exit(1); });
