/* فيديو 8: العقارات والإيجارات - تجهيز، معالج العقار (مبنى ووحداته)، عقد إيجار بجدول استحقاقاته، فوترة المستحق،
   استلام التأمين، تحصيل الإيجار من المستأجر، ولوحة الإيجارات.
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v07_real_estate.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;
const now = new Date();
const ymd = (d) => d.toISOString().slice(0, 10);
const START = ymd(new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)));
const END = ymd(new Date(Date.UTC(now.getUTCFullYear() + 1, now.getUTCMonth(), 0)));

(async () => {
  const v = await video('noona_prj', out, 'v07_real_estate');
  const { page } = v;

  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('العقارات والإيجارات', ['العقار ومبانيه ووحداته', 'عقد الإيجار · الاستحقاقات · الفوترة · التأمين · التحصيل'], 4500, 'الفيديو القصير 8 · إدخال حقيقي سريع · مجموعة النور');

  // ------------------------------------------------ 1) التجهيز
  await v.setStep('1 · التجهيز');
  await v.login(ADMIN, PWD, 'يفتح أحمد تطبيق <b>العقارات والضيافة والمشروعات</b>');
  const setup = page.getByRole('button', { name: /تجهيز الضيافة/ });
  if (await setup.count()) await v.click(setup.first(), '<b>تجهيز</b>: حسابات الإيرادات والتأمينات، وفئات الصيانة وفريقها');

  // ------------------------------------------------ 2) العقار
  await v.setStep('2 · معالج العقار');
  await v.nav('إضافة عقار');
  await v.say('<b>معالج العقار</b>: العقار ومبانيه ووحداته في شاشة واحدة', 3500);
  await v.type('#P11_NAME', 'برج النور السكني', 'اسم العقار ونوعه ومدينته');
  await v.select('#P11_TYPE', 'عمارة سكنية');
  await v.select('#P11_CITY', 'الرياض');
  await v.type('#P11_ADDRESS', 'حي النرجس - طريق أنس بن مالك');
  await v.select('#P11_MGMT', 'مملوك', 'الإدارة: مملوك للمنشأة، أو مدار لصالح مالك (بعمولة وكشف للمالك)');
  await v.type('#P11_B1_NAME', 'المبنى أ', 'المبنى وعدد أدواره');
  await v.type('#P11_B1_FLOORS', '3');
  await v.type('#P11_PER_FLOOR', '2', 'وحدتان في كل دور: تتولد 6 شقق مرقمة 101 … 302');
  await v.select('#P11_UTYPE', 'شقة', 'نوع الوحدات واستخدامها ومواصفاتها');
  await v.select('#P11_USAGE', 'للتأجير');
  await v.type('#P11_BEDS', '3');
  await v.type('#P11_AREA', '140');
  await v.type('#P11_PRICE', '45000', 'الإيجار السنوي الافتراضي للوحدة');
  await v.click('إنشاء العقار ووحداته', '<b>إنشاء العقار ووحداته</b>');
  await v.say('بطاقة العقار: مبانيه ووحداته وحالة كل وحدة، ويمكن إضافة مبنى آخر من هنا', 4000);

  // ------------------------------------------------ 3) عقد الإيجار
  await v.setStep('3 · عقد إيجار');
  await v.nav('عقد إيجار جديد');
  await v.select('#P41_PROPERTY', 'برج النور', 'العقار ثم نوع العقد والوحدات المتاحة');
  await v.wait(1200);
  await v.select('#P41_TYPE', 'سكني');
  await v.click('#P41_UNITS_0', 'الوحدة <b>101</b> (يمكن أكثر من وحدة في عقد واحد)', false);
  await v.type('#P41_TENANT_NAME', 'فهد سعد القحطاني', 'المستأجر: جديد أو من العملاء');
  await v.type('#P41_PHONE', '0554443322');
  await v.type('#P41_START_input', START, 'مدة العقد');
  await v.type('#P41_END_input', END);
  await page.keyboard.press('Escape');
  await v.type('#P41_RENT', '45000', 'الإيجار السنوي ودورية السداد');
  await v.select('#P41_FREQ', 'ربع سنوي');
  await v.type('#P41_DEPOSIT', '3000', 'التأمين المسترد');
  await v.click('حفظ وتفعيل العقد', '<b>حفظ وتفعيل العقد</b>');
  await v.say('<b>جدول الاستحقاقات</b>: 4 دفعات × 11,250؛ السكني معفى من الضريبة والتجاري يخضع لها تلقائياً', 5000);

  await v.setStep('4 · الفوترة والتأمين');
  await v.click('فوترة المستحق', '<b>فوترة المستحق</b>: فاتورة الدفعة الأولى على حساب المستأجر');
  await v.select('#P42_PLACE', 'الصندوق الرئيسي', 'التأمين: يستلم في صندوق أو بنك ويقيد التزاماً للمستأجر');
  await v.click('استلام التأمين', '<b>استلام التأمين</b>');
  await v.say('عند الإخلاء: يرد التأمين بعد الخصومات، والتجديد ينشئ عقداً جديداً بالإيجار الجديد', 4000);

  // ------------------------------------------------ 4) التحصيل
  await v.setStep('5 · تحصيل الإيجار');
  await v.switchApp('noona_pos');
  await v.nav('التحصيل من العملاء');
  await v.click('تحصيل جديد', 'التحصيل من تطبيق المبيعات: <b>تحصيل جديد</b>');
  await v.select('#P24_CUST', 'فهد', 'المستأجر عميل في النظام: فاتورة الإيجار مفتوحة أسفل الشاشة');
  await v.type('#P24_AMOUNT', '11250', 'المبلغ');
  await v.select('#P24_PLACE', 'الحساب الجاري', 'إلى البنك');
  await v.select('#P24_METHOD', 'تحويل', 'تحويل بنكي');
  await v.click(page.getByRole('button', { name: /تنفيذ التحصيل/ }).first(), '<b>تنفيذ التحصيل</b>');
  console.log('collect: ' + await v.alerts());

  await v.setStep('6 · لوحة الإيجارات');
  await v.switchApp('noona_prj');
  await v.nav('لوحة الإيجارات');
  await v.say('<b>لوحة الإيجارات</b>: الإشغال، المستحق والمتأخر، العقود القريبة الانتهاء؛ وفوترة كل المستحق دفعة واحدة', 5000);
  await v.nav('العقود وقائمة الإيجارات');
  await v.say('قائمة العقود والإيجارات بحالة كل دفعة؛ وإدارة أملاك الغير بكشوف الملاك والعدادات', 4500);
  await v.card('التالي', ['الفيديو 9: الضيافة والفنادق', 'الحجز والتسكين والفاتورة والمغادرة'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
