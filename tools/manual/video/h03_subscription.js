/* الاشتراك وبدء التشغيل: عميل جديد يسجل بنفسه ← يتحقق بالرمز ← بيانات مؤسسته ← الأنظمة والسعر والتجربة المجانية
   ← يدخل ← ينقل عملاءه وأرصدتهم من Excel ← يطلب الاشتراك السنوي من «اشتراكي» ← مسؤول المنصة يؤكد التحويل فتصدر الفاتورة.
   LONG=1 شرح مفصل (الفيديو المطول)، وبدونه القصير.
   PW_PATH=... NOONA_PORT=8091 [LONG=1] NOONA_PWD_PLATFORM=... node tools/manual/video/h03_subscription.js <outDir> */
'use strict';
const video = require('./vlib.js');
const path = require('path');
const out = process.argv[2];
const LONG = process.env.LONG === '1';
const PORT = process.env.NOONA_PORT || 8090;
const BASE = 'http://localhost:' + PORT + '/ords/r/noonaplus/';
const ASSETS = path.join(__dirname, 'assets');
const SFX = String(Date.now() % 100000);
const USER = 'NKH' + SFX;
const PWD = 'Nokhba#2026x';

(async () => {
  const v = await video('noona_master', out, LONG ? 'h03_subscription_long' : 'h03_subscription_short');
  const { page } = v;
  const say = (t, ms) => v.say(t, LONG ? ms : Math.round(ms * 0.6));
  const sayL = (t, ms) => (LONG ? v.say(t, ms) : Promise.resolve());
  const n = (longNote, shortNote) => (LONG ? longNote : (shortNote === undefined ? null : shortNote));
  const log = (m) => console.log(m);
  const msg = async (step) => { const a = await v.alerts(); log(step + ': ' + (a || '(no message)')); if (/ORA-|NOONA-|خطأ|حدث/.test(a)) log('ERR ' + step); return a; };
  const scrollTo = (sel) => page.evaluate((s) => { const e = document.querySelector(s); if (e) e.scrollIntoView({ block: 'start', behavior: 'smooth' }); }, sel);
  const check = async (sel, note) => { const l = page.locator(sel).first(); if (note) await v.say(note, 1); await l.scrollIntoViewIfNeeded(); await l.check(); await v.wait(500); };

  await page.goto(BASE + 'noona_master/login'); await v.settle();
  await v.card('الاشتراك وبدء التشغيل', ['العميل يسجل بنفسه ويجرّب مجاناً 14 يوماً · ينقل بياناته من Excel',
    'يطلب اشتراكه من «اشتراكي» · تأكيد التحويل وفاتورة الاشتراك'], 5500,
    LONG ? 'الفيديو المطول · مؤسسة النخبة التجارية' : 'الفيديو القصير · مؤسسة النخبة التجارية');

  // ================================================================ 1) التسجيل الذاتي
  await v.setStep('1 · إنشاء الحساب');
  await say(n('عميل جديد لا يحتاج أن يتواصل معنا: من صفحة الدخول يضغط <b>أنشئ حساب مؤسستك</b>', 'من صفحة الدخول: <b>أنشئ حساب مؤسستك</b>'), 4500);
  const signupHref = await page.locator('.nn-sgn-login-link a').last().getAttribute('href');
  await page.locator('.nn-sgn-login-link a').last().scrollIntoViewIfNeeded();
  await page.goto('http://localhost:' + PORT + '/ords/' + signupHref); await v.settle();
  await sayL('خمس خطوات ظاهرة أعلى الصفحة: الحساب، التحقق، المؤسسة، الأنظمة والخطة، جاهز', 4500);
  await v.type('#P20_NAME', 'نواف الخالدي', n('الاسم الكامل لمسؤول المؤسسة'));
  await v.type('#P20_EMAIL', 'nawaf' + SFX + '@nokhba.sa', n('البريد يصله رمز التحقق والتنبيهات والفواتير'));
  await v.type('#P20_MOBILE', '0551' + SFX.padStart(6, '0'), n('الجوال يصله رمز تحقق ثانٍ'));
  await v.type('#P20_USERNAME', USER, n('اسم الدخول بالإنجليزية'));
  await v.type('#P20_PWD', PWD, n('كلمة مرور قوية: 10 أحرف فيها كبير وصغير ورقم'));
  await v.type('#P20_PWD2', PWD);
  await check('#P20_TERMS input[type=checkbox]', n('الموافقة على الشروط وسياسة الخصوصية وتسجل مع وقتها', 'الموافقة على الشروط'));
  await v.click('إنشاء الحساب وإرسال الرمز', n('نرسل الرمز للبريد والجوال', null));
  await msg('start');

  await v.setStep('2 · التحقق بالرمز');
  const demo = await page.locator('.nn-sgn-demo').innerText().catch(() => '');
  const e = (demo.match(/البريد (\d{6})/) || [])[1]; const m = (demo.match(/الجوال (\d{6})/) || [])[1];
  await say(n('في هذا الجهاز لا يوجد مزود رسائل، فيظهر الرمز على الشاشة (وضع تجريبي). على السيرفر يصل للبريد والجوال', 'الرمز يظهر هنا في الوضع التجريبي'), 5500);
  await v.type('#P20_ECODE', e || '', n('رمز البريد: 6 أرقام صالحة 10 دقائق'));
  await v.type('#P20_MCODE', m || '', n('ورمز الجوال'));
  await v.click('تحقق', null); await msg('verify');

  await v.setStep('3 · بيانات المؤسسة');
  await v.type('#P20_ORG', 'مؤسسة النخبة التجارية', n('البيانات الأساسية فقط؛ الباقي بعد الدخول'));
  await v.type('#P20_CR', '1010' + SFX.padStart(6, '0'), n('السجل التجاري 10 أرقام'));
  await v.type('#P20_VAT', '3101' + SFX.padStart(10, '0') + '3', n('الرقم الضريبي 15 رقماً يبدأ وينتهي بالرقم 3'));
  await v.type('#P20_CITY', 'الرياض');
  await v.click('التالي', null); await msg('org');

  await v.setStep('4 · الأنظمة والخطة والسعر');
  await sayL('كل نظام ببطاقة وسعره الشهري؛ والأرشيف والمراسلات مشمول', 4500);
  await scrollTo('#P20_OFF');
  await check('#P20_OFF input[value=SCM]', n('نختار المالية ومعها <b>المخزون والمشتريات</b>', 'المخزون والمشتريات'));
  await check('#P20_OFF input[value=POS]', n('و<b>المبيعات ونقاط البيع</b> (تتطلب المالية والمخزون)', 'المبيعات ونقاط البيع'));
  await v.type('#P20_USERS', '5', n('عدد المستخدمين: أول اثنين مجاناً'));
  await v.click('احسب السعر', null);
  await scrollTo('table.nn-sgn-q');
  await say(n('السعر يظهر فوراً: كل نظام والمستخدمون والإجمالي الشهري', 'السعر الشهري فوراً'), 5000);
  await scrollTo('#P20_PLAN');
  await v.select('#P20_PLAN', 'اشتراك سنوي', n('بالخطة السنوية: خصم 20% وضريبة القيمة المضافة', 'السنوي بخصم 20%')); await v.settle();
  await scrollTo('table.nn-sgn-q');
  await say(n('المستحق للسنة شاملاً الضريبة، وتظهر بيانات التحويل البنكي', 'المستحق للسنة شاملاً الضريبة'), 5000);
  await scrollTo('#P20_PLAN');
  await v.select('#P20_PLAN', 'تجربة مجانية', n('لكنه يبدأ بالتجربة المجانية 14 يوماً بلا دفع', 'نبدأ بالتجربة المجانية')); await v.settle();
  await v.click('إنشاء مؤسستي', n('تنشأ المؤسسة وشركتها وفرعها والمسؤول وتفعل الأنظمة المختارة فقط', null)); await msg('finish');
  await v.setStep('5 · جاهز');
  await say(n('مؤسسته جاهزة الآن؛ ويصله بريد ترحيب بخطوات البدء', 'المؤسسة جاهزة'), 4500);

  // ================================================================ 2) الدخول ونقل البيانات
  await page.goto('http://localhost:' + PORT + '/ords/' + await page.locator('.nn-sgn-done a').first().getAttribute('href')); await v.settle();
  await v.setStep('6 · الدخول');
  await v.type('#P9999_USERNAME', USER); await v.type('#P9999_PASSWORD', PWD);
  await v.click(page.getByRole('button').filter({ hasText: /Sign In|تسجيل الدخول|دخول/ }).first());
  await page.waitForURL(/session=\d+/, { timeout: 20000 }).catch(() => {}); await v.settle();
  const sess = new URL(page.url()).searchParams.get('session');
  await say(n('تظهر له الأنظمة التي اختارها فقط: المالية والمخزون والمبيعات وإدارة المؤسسة', 'تظهر الأنظمة المختارة فقط'), 5000);
  await page.goto(BASE + 'noona_admin/home?session=' + sess); await v.settle();
  await page.goto(BASE + 'noona_admin/onboarding?session=' + sess); await v.settle();
  await v.setStep('7 · نقل البيانات من Excel');
  await say(n('«بدء التشغيل ونقل البيانات»: الخطوات بالترتيب وحالة كل منها', 'بدء التشغيل ونقل البيانات'), 4500);
  await scrollTo('#P90_TYPE');
  await v.select('#P90_TYPE', 'العملاء', n('العملاء من ملف Excel مباشرة؛ العناوين بالعربي أو الإنجليزي')); await v.settle();
  await page.locator('#P90_FILE input[type=file]').setInputFiles(path.join(ASSETS, 'onb_customers.xlsx')); await v.wait(800);
  await v.click(page.getByRole('button', { name: 'استيراد', exact: true }), null); await msg('customers');
  await say(n('استورد العملاء الثلاثة', 'العملاء'), 3500);
  await scrollTo('#P90_TYPE');
  await v.select('#P90_TYPE', 'أرصدة العملاء', n('ثم أرصدتهم الافتتاحية: فاتورة مفتوحة لكل سطر بتاريخها', 'أرصدة العملاء')); await v.settle();
  await page.locator('#P90_FILE input[type=file]').setInputFiles(path.join(ASSETS, 'onb_ar.xlsx')); await v.wait(800);
  await v.click(page.getByRole('button', { name: 'استيراد', exact: true }), null); await msg('ar');
  await sayL('الملف يرحل كاملاً أو لا يرحل منه شيء؛ والأخطاء تظهر برقم الصف وسببها', 5000);
  await page.goto(BASE + 'noona_admin/onboarding?session=' + sess); await v.settle();
  await scrollTo('table.nn-onb');
  await say(n('الخطوات المكتملة، والمطابقة: حساب الأرصدة الافتتاحية يصبح صفراً عند اكتمال كل الملفات', 'الخطوات المكتملة والمطابقة'), 5500);

  // ================================================================ 3) اشتراكي
  await page.goto(BASE + 'noona_admin/my-subscription?session=' + sess); await v.settle();
  await v.setStep('8 · اشتراكي');
  await say(n('«اشتراكي»: الخطة ونهاية التجربة والأيام المتبقية والمستخدمون والأنظمة', 'اشتراكي: التجربة والأيام المتبقية'), 5000);
  await scrollTo('#P91_OFF');
  await check('#P91_OFF input[value=HR]', n('يضيف <b>الموارد البشرية والرواتب</b>', 'إضافة الموارد البشرية'));
  await v.type('#P91_USERS', '6', n('ويرفع المستخدمين إلى 6'));
  await v.click('احسب السعر', null);
  await scrollTo('table.nn-sgn-q');
  await say(n('السعر السنوي بالخصم والضريبة', 'السعر السنوي'), 4000);
  await scrollTo('#P91_REF');
  await v.type('#P91_REF', 'TRF-' + SFX, n('يحول المبلغ ويكتب مرجع التحويل'));
  await v.click('إرسال الطلب', null); await msg('request');
  await say(n('الطلب بانتظار تأكيد التحويل؛ ويصل تنبيه لمسؤول المنصة بالبريد', 'بانتظار التأكيد'), 4000);

  // ================================================================ 4) مسؤول المنصة
  await v.logout();
  await v.switchApp('noona_platform');
  await v.setStep('9 · تأكيد التحويل (مسؤول المنصة)');
  await v.login('PLATFORM', process.env.NOONA_PWD_PLATFORM || 'Platform#2026x', null);
  await page.goto(BASE + 'noona_platform/home?session=' + v.sess); await v.settle();
  await page.goto(BASE + 'noona_platform/signups?session=' + v.sess); await v.settle();
  await sayL('طلبات التسجيل الذاتي وطلبات «اشتراكي» من المؤسسات', 4000);
  await scrollTo('#P9_REQ');
  await v.select('#P9_REQ', 'TRF-' + SFX, n('يتأكد من وصول المبلغ بمرجعه'));
  await v.click('تأكيد التحويل وتنفيذ الطلب', n('فتفعل الأنظمة والمستخدمون والخطة السنوية، وتصدر فاتورة المبيعات وترسل للعميل', null)); await msg('confirm');
  await scrollTo('#P9_REQ');
  await say(n('الطلب منفذ برقم فاتورته: فاتورة مبيعات حقيقية في مؤسستك تمر بالفاتورة الإلكترونية وتقيد إيراداً', 'منفذ برقم الفاتورة'), 5500);

  await v.card('دورة العميل كاملة دون تدخل يدوي', ['تسجيل وتحقق · تجربة مجانية · نقل البيانات من Excel',
    'تجديد وترقية من «اشتراكي» · فاتورة بالبريد · تنبيهات قبل الانتهاء'], 5000);
  const f = await v.done();
  log('VIDEO ' + f);
})().catch((e) => { console.error('FAILED', e); process.exit(1); });
