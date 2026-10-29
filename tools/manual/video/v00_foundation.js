/* فيديو 1: التأسيس - تجهيز المؤسسة والشركة الأم من لوحة المنصة، ثم دخول مسؤول المؤسسة وإضافة فرع، وشركة ثانية بفرعها، ومستخدم بدوره.
   PW_PATH=... NOONA_PWD_PLATFORM=... node tools/manual/video/v00_foundation.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const sfx = String(Date.now()).slice(-4);
const T = { code: 'NOOR' + sfx, slug: 'noor' + sfx, admin: 'NOOR_ADMIN' + sfx, pwd: 'NoorDemo#2026', user: 'NOOR_ACC' + sfx };
console.log('USERS ' + T.admin + ' ' + T.user);

(async () => {
  const v = await video('noona_platform', out, 'v00_foundation');
  const { page } = v;
  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('التأسيس في نونا بلس', ['تسجيل المؤسسة والشركة الأم', 'ثم الفروع والشركة الثانية والمستخدمين'], 4500, 'فيديو 1 · إدخال حقيقي');

  // ------------------------------------------------ 1) مسؤول المنصة
  await v.setStep('1 · لوحة المنصة');
  await v.login('PLATFORM', process.env.NOONA_PWD_PLATFORM, 'الدخول بحساب <b>مسؤول المنصة PLATFORM</b> من شاشة الدخول الموحد');
  await v.say('لوحة المنصة: كل المؤسسات المشتركة واشتراكاتها. نبدأ بتجهيز مؤسسة جديدة', 4500);
  await v.go('PROVISION');
  await v.setStep('2 · تجهيز المؤسسة والشركة الأم');
  await v.say('شاشة واحدة تنشئ <b>المؤسسة</b> و<b>الشركة الأم</b> وفرعها الرئيسي ودفترها و<b>مسؤول المؤسسة</b>', 5000);
  await v.type('#P4_CODE', T.code, 'رمز المؤسسة: مختصر بالإنجليزية');
  await v.type('#P4_SLUG', T.slug, 'المعرف في الروابط: حروف إنجليزية صغيرة');
  await v.type('#P4_NAME_AR', 'مجموعة النور التجارية', 'اسم المؤسسة بالعربية والإنجليزية');
  await v.type('#P4_NAME_EN', 'Al Noor Group');
  await v.select('#P4_COUNTRY', 'السعودية', 'الدولة والعملة الأساسية (عملة الشركة الأم)');
  await v.select('#P4_CURRENCY', 'SAR');
  await v.type('#P4_COMPANY_CODE', 'NOOR-HQ', 'رمز واسم <b>الشركة الأولى = الشركة الأم</b>');
  await v.type('#P4_COMPANY_NAME', 'شركة النور للتجارة');
  await v.type('#P4_MAX_USERS', '25', 'حدود الاشتراك: المستخدمون والفروع والشركات (فارغ = بلا حد)');
  await v.type('#P4_MAX_BRANCHES', '10');
  await v.type('#P4_MAX_COMPANIES', '3');
  await v.type('#P4_ADMIN_USER', T.admin, 'مسؤول المؤسسة: اسم الدخول والاسم والبريد وكلمة مرور أولى');
  await v.type('#P4_ADMIN_NAME', 'أحمد مدير النور');
  await v.type('#P4_ADMIN_EMAIL', 'admin@noor.example');
  await v.type('#P4_ADMIN_PASSWORD', T.pwd);
  await v.click('تجهيز المؤسسة', 'نضغط <b>تجهيز المؤسسة</b>');
  await v.say('تم التجهيز. ننتقل لبطاقة المؤسسة: الحالة والحدود والاشتراك', 4000);
  await v.setStep('3 · الوحدات المشترك فيها');
  const mods = page.locator('.nn-mod-cb');
  await mods.first().scrollIntoViewIfNeeded().catch(() => {});
  await v.say('نحدد <b>الأنظمة المشترك فيها</b>: تظهر لمستخدمي المؤسسة في شاشة الأنظمة', 4000);
  const n = await mods.count();
  for (let i = 0; i < Math.min(n, 6); i++) {
    if (!(await mods.nth(i).isChecked())) await v.click(mods.nth(i), null, false);
  }
  await v.click('حفظ الاشتراك', 'ثم <b>حفظ الاشتراك</b>');

  // ------------------------------------------------ 2) مسؤول المؤسسة
  await v.logout();
  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.setStep('4 · دخول مسؤول المؤسسة');
  await v.type('#P9999_USERNAME', T.admin, 'مسؤول المؤسسة يدخل بكلمة المرور الأولى (ويغيرها من قائمة المستخدم)');
  await v.type('#P9999_PASSWORD', T.pwd);
  await v.click(page.getByRole('button').filter({ hasText: /Sign In|تسجيل الدخول|دخول/ }).first());
  await v.say('شاشة الأنظمة: بطاقة لكل نظام مشترك فيه. نفتح <b>إدارة المؤسسة</b>', 4500);
  const sess = new URL(page.url()).searchParams.get('session');
  await v.click(page.locator('a').filter({ hasText: 'إدارة المؤسسة' }).first());
  if (!page.url().includes('noona_admin')) { await page.goto('http://localhost:8090/ords/r/noonaplus/noona_admin/home?session=' + sess); await v.settle(); }
  const adm = (alias, clear) => page.goto('http://localhost:8090/ords/r/noonaplus/noona_admin/' + alias + '?session=' + sess + (clear ? '&clear=' + clear : '')).then(() => v.settle());

  await v.setStep('5 · الشركة الأم');
  await adm('companies');
  await v.say('الشركات: الشركة الأم أنشئت بالتجهيز. نفتح بطاقتها', 3500);
  await v.click(page.locator('.a-IRR-table td a').first());
  await v.say('بطاقة الشركة: البيانات القانونية، الشعار، <b>فحوص التفعيل</b>، وفروع الشركة', 5000);
  await v.click('فرع جديد', 'نضيف فرعاً للشركة الأم من بطاقتها: <b>فرع جديد</b>');
  await v.setStep('6 · فرع جديد');
  await v.type('#P13_CODE', 'JED', 'رمز الفرع واسمه ونوعه');
  await v.type('#P13_NAME_AR', 'فرع جدة');
  await v.select('#P13_BRANCH_TYPE', 'معرض');
  await v.click('إنشاء الفرع', '<b>إنشاء الفرع</b> (المركز الرئيسي أنشئ مع الشركة)');
  console.log('branch: ' + await v.alerts());

  await v.setStep('7 · الشركة الثانية');
  await adm('companies');
  await v.click('شركة جديدة', 'من الشركات ← <b>شركة جديدة</b>');
  await v.say('<b>شركة ثانية</b> في نفس المؤسسة: مستقلة محاسبياً وتشترك في المستخدمين والأصناف', 5000);
  await v.type('#P11_CODE', 'NOOR-CON', 'الرمز والاسم القانوني');
  await v.type('#P11_LEGAL_NAME_AR', 'شركة النور للمقاولات');
  await v.select('#P11_COUNTRY_CODE', 'السعودية', 'الدولة والعملة الوظيفية للشركة');
  await v.select('#P11_FUNCTIONAL_CURRENCY', 'SAR');
  await v.click('إنشاء الشركة', '<b>إنشاء الشركة</b>');
  console.log('company: ' + await v.alerts());
  await v.click('فرع جديد', 'ثم فرعها الرئيسي');
  await v.say('الشركة مختارة تلقائياً من بطاقتها', 2500);
  await v.type('#P13_CODE', 'CON-HQ', 'المركز الرئيسي للشركة الثانية');
  await v.type('#P13_NAME_AR', 'المركز الرئيسي - المقاولات');
  await v.select('#P13_BRANCH_TYPE', 'مركز رئيسي');
  await v.select('#P13_IS_HEAD_OFFICE', 'نعم', '«مركز رئيسي للشركة» = نعم لفرع واحد فقط');
  await v.click('إنشاء الفرع');
  console.log('branch2: ' + await v.alerts());

  await v.setStep('8 · مستخدم ودوره');
  await adm('users');
  await v.click('مستخدم جديد', 'المستخدمون ← <b>مستخدم جديد</b>');
  await v.say('مستخدم جديد بكلمة مرور أولى، ثم نمنحه دوراً في نطاق شركة', 4000);
  await v.type('#P31_USERNAME', T.user, 'اسم الدخول والاسم والبريد');
  await v.type('#P31_DISPLAY_NAME', 'سارة المحاسبة');
  await v.type('#P31_EMAIL', 'sara@noor.example');
  await v.select('#P31_COMPANY_ID', 'النور للتجارة', 'الشركة الافتراضية للمستخدم');
  await v.type('#P31_PASSWORD', T.pwd, 'كلمة المرور: 10 أحرف بحرف كبير وصغير ورقم');
  await v.click('إنشاء المستخدم', '<b>إنشاء المستخدم</b>');
  console.log('user: ' + await v.alerts());
  const roleOpt = await page.locator('#P31_ROLE_ID option').evaluateAll((os) => (os.find((o) => /محاسب|ACCOUNT/i.test(o.textContent)) || os[1] || {}).textContent || '');
  await v.select('#P31_ROLE_ID', roleOpt.trim().slice(0, 12), 'نختار <b>الدور</b> (مجموعة صلاحيات)');
  await v.select('#P31_SCOPE_COMPANY', 'النور للتجارة', 'ونطاقه: شركة محددة أو فرع؛ يمكن منحه لأكثر من شركة');
  await v.click('منح الدور', '<b>منح الدور</b>');
  console.log('grant: ' + await v.alerts());
  await v.say('اكتمل التأسيس: المؤسسة، الشركة الأم وفرعها، شركة ثانية بفرعها، ومستخدم بدوره', 5000);
  await v.card('التالي', ['الفيديو 2: المالية', 'تجهيز الأستاذ العام ثم القيد والسندات'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch(async (e) => { console.error('ERR', e.message); process.exit(1); });
