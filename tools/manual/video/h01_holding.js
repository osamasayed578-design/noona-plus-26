/* الشركة القابضة من البداية حتى القوائم الموحدة - إدخال يدوي مصور بترتيب أولوية الإعداد:
   1 تسجيل المؤسسة والشركة القابضة (مسؤول المنصة) ← 2 مجموعة الأعمال وربط القابضة وبيانات اتصالها وفرعها
   ← 3 الشركتان التابعتان وفروعهما ← 4 الهيكل التنظيمي (الوحدات والوظائف والمناصب) ← 5 دور «المدير المالي» ومستخدم المحاسب
   ← 6 الأرشيف (تجهيز وأرشفة مستند بأصله) ← 7 المراسلات (مذكرة بتعليمة ومهلة) ← 8 المالية لكل شركة (دليل خاص للقابضة،
   ودليل المجموعة الموحد للتابعتين، حسابات الجاري بين الشركات، القيود) ← 9 المحاسب: الرد على المذكرة واعتماد القيود في الشركات الثلاث
   ← 10 مجموعة التجميع والقوائم الموحدة (المركز المالي والدخل والميزان) واعتماد التجميع.
   LONG=1 شرح مفصل لكل حقل (الفيديو المطول)، وبدونه الفيديو القصير.
   PW_PATH=... NOONA_PORT=8091 NOONA_PWD_PLATFORM=... [LONG=1] node tools/manual/video/h01_holding.js <outDir> */
'use strict';
const path = require('path');
const video = require('./vlib.js');
const out = process.argv[2];
const LONG = process.env.LONG === '1';
const PORT = process.env.NOONA_PORT || 8090;
const BASE = 'http://localhost:' + PORT + '/ords/r/noonaplus/';
const sfx = String(Date.now()).slice(-4);
const T = { code: 'RYD' + sfx, slug: 'ryd' + sfx, admin: 'RYD_ADMIN' + sfx, acc: 'RYD_FIN' + sfx, pwd: 'Riyada#2026x', bg: 'RYD' + sfx };
const day = (n) => { const d = new Date(Date.now() + n * 864e5); return d.toISOString().slice(0, 10); };
console.log('USERS ' + T.admin + ' ' + T.acc);

(async () => {
  const v = await video('noona_platform', out, LONG ? 'h01_holding_long' : 'h01_holding_short');
  const { page } = v;
  const say = (t, ms) => v.say(t, LONG ? ms : Math.round(ms * 0.6));
  const sayL = (t, ms) => (LONG ? v.say(t, ms) : Promise.resolve());          // شرح المطول فقط
  const n = (longNote, shortNote) => (LONG ? longNote : (shortNote === undefined ? null : shortNote));
  const log = (m) => console.log(m);
  const msg = async (step) => { const a = await v.alerts(); log(step + ': ' + (a || '(no message)')); if (/ORA-|NOONA-|خطأ|حدث/.test(a)) log('ERR ' + step); return a; };
  const app = (alias, pageAlias, clear) => page.goto(BASE + alias + '/' + pageAlias + '?session=' + v.sess + (clear ? '&clear=' + clear : '')).then(() => v.settle());
  async function openRow(text, note) {
    const a = page.locator('.a-IRR-table tr').filter({ hasText: text }).locator('a').first();
    if (await a.count()) await v.click(a, note); else log('ERR row not found: ' + text);
  }
  async function switchCompany(name, note) {
    const back = page.url().match(/\/r\/noonaplus\/([^/]+)\//)[1];
    await app('noona_portal', 'company');
    await v.select('#P3_COMPANY_ID', name, note);
    await v.click('تبديل', null);
    await v.switchApp(back);
  }
  const row = (i) => page.locator('.nn-je-table tbody tr').nth(i);
  async function line(i, acc, amt, txt, side) {
    if (await page.locator('.nn-je-table tbody tr').count() <= i) await v.click('.nn-je-add', null, false);
    await v.type(row(i).locator('.nn-je-acc'), acc);
    await page.keyboard.press('Tab'); await v.wait(300);
    await v.type(row(i).locator(side === 'cr' ? '.nn-je-cr' : '.nn-je-dr'), amt);
    if (txt) await v.type(row(i).locator('.nn-je-txt'), txt);
  }
  async function journal(desc, lines, note) {
    await v.nav('قيد جديد');
    await v.type('[data-k="desc"]', desc, note || n('<b>البيان</b>: وصف القيد', null));
    for (let i = 0; i < lines.length; i++) await line(i, ...lines[i]);
    await v.click('.nn-doc-save[data-a="SUBMIT"]', n('<b>حفظ وإرسال للاعتماد</b>: يعتمده شخص غير منشئه (فصل المهام)', '<b>إرسال للاعتماد</b>'));
    await msg('journal ' + desc);
    // قاعدة الأرشفة: المرجع الورقي للقيد قبل اعتماده
    jvn += 1;
    if (await page.locator('#P21_ARC_REF').count()) {
      await v.type('#P21_ARC_REF', 'ORG-' + sfx + '-' + jvn, jvn === 1 ? n('<b>قاعدة الأرشفة</b>: رقم <b>الأصل الورقي</b> وموقعه قبل الاعتماد (أو صورته)', 'المرجع الورقي للقيد') : null);
      await v.type('#P21_ARC_LOC', 'ملف القيود ' + new Date().getFullYear());
      await v.click('أرشفة', null);
      await msg('archive ref ' + desc);
    } else log('ERR no archive panel for ' + desc);
  }
  let jvn = 0;
  async function account(code, name, parent, sub, note) {
    await v.select('#P10_PARENT', parent, n('<b>تحت الحساب الرئيسي</b>: الحساب الأب في الدليل', null));
    await v.type('#P10_CODE', code, note);
    await v.type('#P10_NAME', name);
    if (sub) await v.select('#P10_SUB', 'جاري بين شركات', n('<b>تصنيف خاص: جاري بين شركات المجموعة</b> ← يستبعد تلقائياً في القوائم الموحدة', '<b>جاري بين الشركات</b>: يستبعد في الموحد'));
    await v.click('إضافة الحساب', null);
    await msg('account ' + code);
  }

  await page.goto(BASE + 'noona_master/home'); await v.settle();
  await v.card('الشركة القابضة في نونا بلس', ['من تسجيل المؤسسة حتى القوائم المالية الموحدة',
    'الهيكل التنظيمي · الأرشيف · المراسلات · المالية لكل شركة · التجميع'], 5500,
    LONG ? 'الفيديو المطول · إدخال حقيقي مع شرح الحقول' : 'الفيديو القصير · إدخال حقيقي');

  // ================================================================ 1) تسجيل المؤسسة والشركة القابضة
  await v.setStep('1 · تسجيل المؤسسة');
  await v.login('PLATFORM', process.env.NOONA_PWD_PLATFORM, n('مسؤول المنصة (<b>PLATFORM</b>) يسجل المؤسسة المشتركة الجديدة', 'مسؤول المنصة يسجل المؤسسة'));
  await sayL('المؤسسة = العميل المشترك. تحتها <b>شركة قابضة</b> وشركاتها التابعة وفروع كل شركة', 5000);
  await v.go('PROVISION');
  await v.type('#P4_CODE', T.code, n('<b>رمز المؤسسة</b>: نص قصير بالإنجليزية بلا مسافات', 'رمز المؤسسة واسمها'));
  await v.type('#P4_SLUG', T.slug, n('<b>المعرف في الروابط</b>: حروف إنجليزية صغيرة', null));
  await v.type('#P4_NAME_AR', 'مجموعة الريادة القابضة', n('<b>اسم المؤسسة</b> بالعربية والإنجليزية (نص)', null));
  await v.type('#P4_NAME_EN', 'Al Riyada Holding Group');
  await v.select('#P4_COUNTRY', 'السعودية', n('<b>الدولة</b> (قائمة): تحدد الضرائب والسجلات؛ و<b>العملة</b> الوظيفية للشركة الأولى', null));
  await v.select('#P4_CURRENCY', 'SAR');
  await v.type('#P4_COMPANY_CODE', 'RYD-HQ', n('<b>الشركة الأولى = الشركة القابضة</b>: رمزها واسمها القانوني', 'الشركة الأولى: <b>الشركة القابضة</b>'));
  await v.type('#P4_COMPANY_NAME', 'شركة الريادة القابضة');
  await v.type('#P4_MAX_USERS', '50', n('<b>حدود الاشتراك</b> (أرقام): المستخدمون والفروع والشركات', null));
  await v.type('#P4_MAX_BRANCHES', '20');
  await v.type('#P4_MAX_COMPANIES', '5');
  await v.type('#P4_ADMIN_USER', T.admin, n('<b>مسؤول المؤسسة</b>: اسم الدخول والاسم والبريد وكلمة مرور أولى', 'مسؤول المؤسسة'));
  await v.type('#P4_ADMIN_NAME', 'خالد مدير الريادة');
  await v.type('#P4_ADMIN_EMAIL', 'admin@riyada.example');
  await v.type('#P4_ADMIN_PASSWORD', T.pwd);
  await v.click('تجهيز المؤسسة', '<b>تجهيز المؤسسة</b>');
  await msg('provision');
  const mods = page.locator('.nn-mod-cb');
  await mods.first().scrollIntoViewIfNeeded().catch(() => {});
  await say('<b>الأنظمة المشترك فيها</b>: نشترك في كل الأنظمة', 3000);
  const nm = await mods.count();
  for (let i = 0; i < nm; i++) if (!(await mods.nth(i).isChecked())) await v.click(mods.nth(i), null, false);
  await v.click('حفظ الاشتراك', '<b>حفظ الاشتراك</b>');
  await msg('subscription');

  // ================================================================ 2) مجموعة الأعمال والقابضة
  await v.logout();
  await v.setStep('2 · مجموعة الأعمال (القابضة)');
  await v.switchApp('noona_admin');
  await v.login(T.admin, T.pwd, n('يدخل <b>مسؤول المؤسسة</b> بكلمة المرور الأولى إلى <b>إدارة المؤسسة</b>', 'دخول مسؤول المؤسسة'));
  await v.nav('مجموعات الأعمال (القابضة)');
  await say('<b>مجموعة الأعمال</b> = الشركة القابضة وما يتبعها؛ أنشأها التجهيز تلقائياً وربط بها الشركة القابضة', 5000);
  await openRow('MAIN', n('نفتحها ونكمل بياناتها', 'نفتح المجموعة'));
  await v.type('#P15_NAME_AR', 'مجموعة الريادة', n('<b>اسم المجموعة</b> (نص)', null));
  await v.type('#P15_NAME_EN', 'Al Riyada Group');
  await v.select('#P15_CURRENCY', 'SAR', n('<b>عملة التجميع</b> (قائمة): عملة القوائم الموحدة؛ الشركات بعملات أخرى تحول بسعر الإقفال', 'عملة التجميع'));
  await sayL('<b>المجموعة الأم</b> (اختياري): لمجموعات متعددة المستويات', 3000);
  await v.click('حفظ', '<b>حفظ</b>');
  await msg('business group');
  await say('أسفلها <b>شركات المجموعة</b>: الشركة القابضة الآن، ونوع دليل حساباتها بعد تجهيز ماليتها', 4000);

  await v.setStep('3 · بطاقة الشركة القابضة');
  await v.nav('الشركات');
  await openRow('RYD-HQ', 'نفتح <b>الشركة القابضة</b>');
  await sayL('<b>مجموعة الأعمال</b> (قائمة) مختارة بالفعل: الشركة القابضة', 3000);
  await v.type('#P11_TRADE_NAME_AR', 'الريادة القابضة', n('<b>الاسم التجاري</b>: يظهر في الشاشات', null));
  await v.click('حفظ التعديلات', '<b>حفظ التعديلات</b>');
  await msg('holding save');
  await v.type('#P11_ADDRESS', 'الرياض، حي الملقا، طريق أنس بن مالك، مبنى 2210', n('<b>العنوان ووسائل الاتصال</b>: تظهر في ترويسة التقارير والفواتير', 'العنوان ووسائل الاتصال (للترويسة)'));
  await v.type('#P11_POSTAL', '13521');
  await v.type('#P11_PHONE', '+966 11 410 5500', n('<b>الهاتف والجوال</b> (نص)', null));
  await v.type('#P11_MOBILE', '+966 50 410 5500');
  await v.type('#P11_EMAIL', 'info@riyada.example', n('<b>البريد</b>: يتحقق النظام من صيغته', null));
  await v.click('حفظ بيانات الاتصال', '<b>حفظ بيانات الاتصال</b>');
  await msg('holding contact');
  await sayL('<b>فحوص التفعيل</b> أسفل البطاقة: ما ينقص الشركة قبل تفعيلها', 3500);
  await v.click('فرع جديد', n('من بطاقة الشركة: <b>فرع جديد</b> (المركز الرئيسي أنشئ مع الشركة)', '<b>فرع جديد</b> للقابضة'));
  await v.type('#P13_CODE', 'HQ-JED', n('<b>رمز الفرع</b> و<b>اسمه</b>', null));
  await v.type('#P13_NAME_AR', 'مكتب الريادة - جدة');
  await v.select('#P13_BRANCH_TYPE', 'فرع', n('<b>نوع الفرع</b> (قائمة): مركز رئيسي، فرع، مستودع، معرض، مصنع، مكتب موقع', null));
  await v.click('إنشاء الفرع', '<b>إنشاء الفرع</b>');
  await msg('holding branch');

  // ================================================================ 3) الشركتان التابعتان
  const subs = [
    { code: 'RYD-TRD', name: 'شركة الريادة للتجارة', hq: ['TRD-HQ', 'المركز الرئيسي - التجارة'], br: ['TRD-DMM', 'فرع الدمام'] },
    { code: 'RYD-CON', name: 'شركة الريادة للمقاولات', hq: ['CON-HQ', 'المركز الرئيسي - المقاولات'], br: null }];
  for (const [k, s] of subs.entries()) {
    await v.setStep('4 · شركة تابعة ' + (k + 1));
    await v.nav('الشركات');
    await v.click('شركة جديدة', k === 0 ? n('<b>شركة تابعة</b>: كيان قانوني مستقل بدفاتره، ضمن المجموعة', '<b>شركة تابعة جديدة</b>') : '<b>شركة تابعة ثانية</b>');
    await v.type('#P11_CODE', s.code, n('<b>الرمز</b> و<b>الاسم القانوني</b>', null));
    await v.type('#P11_LEGAL_NAME_AR', s.name);
    await v.select('#P11_COUNTRY_CODE', 'السعودية', n('<b>الدولة</b> و<b>العملة الوظيفية</b> للشركة', null));
    await v.select('#P11_FUNCTIONAL_CURRENCY', 'SAR');
    await v.select('#P11_BUSINESS_GROUP_ID', 'مجموعة الريادة', '<b>مجموعة الأعمال</b>: تتبع الريادة القابضة');
    await v.click('إنشاء الشركة', '<b>إنشاء الشركة</b>');
    await msg('company ' + s.code);
    await v.click('فرع جديد', 'المركز الرئيسي للشركة');
    await v.type('#P13_CODE', s.hq[0]);
    await v.type('#P13_NAME_AR', s.hq[1]);
    await v.select('#P13_BRANCH_TYPE', 'مركز رئيسي');
    await v.select('#P13_IS_HEAD_OFFICE', 'نعم', n('<b>مركز رئيسي للشركة</b> = نعم لفرع واحد فقط', null));
    await v.click('إنشاء الفرع', null);
    await msg('branch ' + s.hq[0]);
    if (s.br) {
      await v.nav('الشركات');
      await openRow(s.code, null);
      await v.click('فرع جديد', 'فرع ثان للتجارة');
      await v.type('#P13_CODE', s.br[0]);
      await v.type('#P13_NAME_AR', s.br[1]);
      await v.select('#P13_BRANCH_TYPE', 'فرع');
      await v.click('إنشاء الفرع', null);
      await msg('branch ' + s.br[0]);
    }
  }
  await v.nav('مجموعات الأعمال (القابضة)');
  await openRow('مجموعة الريادة', '<b>المجموعة</b> الآن: القابضة والتابعتان');
  await say('<b>شركات المجموعة</b>: لكل شركة عملتها ودليل حساباتها (يحدد عند تجهيز ماليتها)', 4000);

  // ================================================================ 4) الهيكل التنظيمي
  await v.setStep('5 · الهيكل التنظيمي');
  await v.nav('الهياكل والإصدارات');
  await sayL('<b>الهيكل التنظيمي</b> بإصدارات مؤرخة: تعدل مسودة ثم تفعل فتنتقل المناصب لوحداتها الجديدة', 5000);
  await v.select('#P20_COMPANY_ID', 'الريادة القابضة', n('<b>الشركة</b> (قائمة)', 'هيكل الشركة القابضة'));
  await v.type('#P20_CODE', 'ORG-HQ', n('<b>الرمز</b> و<b>الاسم</b>', null));
  await v.type('#P20_NAME_AR', 'الهيكل الإداري للريادة القابضة');
  await v.select('#P20_TYPE', 'إداري', n('<b>النوع</b>: إداري، مالي، تشغيلي، مشروعات...', null));
  await v.select('#P20_IS_PRIMARY', 'نعم', n('<b>الهيكل الإداري الأساسي</b>: تعتمد عليه مسارات الاعتماد والمراسلات', null));
  await v.click('إنشاء الهيكل', '<b>إنشاء الهيكل</b> (الإصدار الأول مسودة)');
  await msg('structure');
  const units = [['BOARD', 'الإدارة العليا', '=إدارة عليا', null], ['FIN', 'الإدارة المالية', '=إدارة', 'الإدارة العليا'],
    ['ADM', 'الشؤون الإدارية والأرشيف', '=إدارة', 'الإدارة العليا'], ['ACC', 'قسم الحسابات', '=قسم', 'الإدارة المالية']];
  for (const [i, u] of units.entries()) {
    await v.type('#P21_UNIT_CODE', u[0], i === 0 ? n('<b>الوحدات</b>: الرمز والاسم والنوع والوحدة الأم (شجرة)', 'إضافة الوحدات') : null);
    await v.type('#P21_UNIT_NAME', u[1]);
    await v.select('#P21_UNIT_TYPE', u[2]);
    if (u[3]) await v.select('#P21_PARENT_CODE', u[3]);
    await v.click('إضافة الوحدة', null);
    await msg('unit ' + u[0]);
  }
  await v.click('تفعيل هذا الإصدار', '<b>تفعيل هذا الإصدار</b>: يصبح الهيكل الساري');
  await msg('activate structure');

  await v.setStep('6 · الوظائف والمناصب');
  await v.nav('المناصب والوظائف');
  await sayL('<b>الوظيفة</b> مسمى عام (محاسب)، و<b>المنصب</b> كرسي محدد في وحدة (رئيس الحسابات) يعين عليه موظف', 5000);
  await v.type('#P22_JOB_CODE', 'ACCT', n('نضيف <b>وظيفة</b> أولاً: رمز واسم', 'وظيفة ثم منصب'));
  await v.type('#P22_JOB_NAME', 'محاسب');
  await v.click('إضافة الوظيفة', null);
  await msg('job');
  await v.select('#P22_UNIT_ID', 'قسم الحسابات', n('<b>المنصب</b>: الوحدة والوظيفة', null));
  await v.select('#P22_JOB_ID', 'محاسب');
  await v.type('#P22_CODE', 'POS-ACC-HEAD', n('رمز المنصب واسمه', null));
  await v.type('#P22_NAME_AR', 'رئيس الحسابات');
  await v.select('#P22_IS_HEAD', 'نعم', n('<b>رئيس الوحدة</b>: تذهب إليه موافقات وحدته', null));
  await v.click('إنشاء المنصب', '<b>إنشاء المنصب</b>');
  await msg('position');
  await sayL('تعيين الموظفين على المناصب من «تعيين الموظفين» بعد إضافتهم في الموارد البشرية', 3500);

  // ================================================================ 5) دور المدير المالي ومستخدم المحاسب
  await v.setStep('7 · الأدوار والمستخدمون');
  await v.nav('الأدوار والصلاحيات');
  await sayL('<b>الدور</b> مجموعة صلاحيات (عرض، إنشاء، اعتماد...) لكل وحدة، يمنح للمستخدم في نطاق شركة أو فرع', 5000);
  await v.type('#P32_CODE', 'FIN_MANAGER', n('<b>دور جديد</b>: الرمز والاسم', 'دور <b>المدير المالي</b>'));
  await v.type('#P32_NAME_AR', 'المدير المالي');
  await v.click('إنشاء الدور', null);
  await msg('role');
  if (!(await page.locator('#P33_MODULE').count())) await openRow('المدير المالي', null);
  for (const mod of ['GL - ', 'CSH - ']) {
    await v.select('#P33_MODULE', mod, n('<b>الوحدة</b> ثم خانات صلاحياتها (عرض، إنشاء، تعديل، إرسال، اعتماد، ترحيل...)', mod === 'GL - ' ? 'صلاحيات المحاسبة العامة والنقدية' : null));
    await v.settle();
    const nchk = await page.evaluate(() => {
      const reg = [...document.querySelectorAll('.t-Region')].find((r) => /خانات الصلاحيات/.test((r.querySelector('.t-Region-title') || {}).textContent || ''));
      let k = 0; (reg || document).querySelectorAll('input[type=checkbox]').forEach((c) => { if (!c.checked) { c.checked = true; c.dispatchEvent(new Event('change', { bubbles: true })); k++; } });
      return k;
    });
    log('perms checked ' + mod + nchk);
    await v.wait(900);
    await v.click('حفظ الصلاحيات', null);
    await msg('perms ' + mod);
  }
  await v.nav('المستخدمون');
  await v.click('مستخدم جديد', '<b>مستخدم جديد</b>: المحاسب');
  await v.type('#P31_USERNAME', T.acc, n('<b>اسم الدخول</b> (لاتيني)، <b>الاسم</b>، <b>البريد</b>', null));
  await v.type('#P31_DISPLAY_NAME', 'سامي المحاسب');
  await v.type('#P31_EMAIL', 'sami@riyada.example');
  await v.select('#P31_COMPANY_ID', 'الريادة القابضة', n('<b>الشركة الافتراضية</b>', null));
  await v.type('#P31_PASSWORD', T.pwd, n('<b>كلمة المرور</b>: 10 أحرف بحرف كبير وصغير ورقم', null));
  await v.click('إنشاء المستخدم', null);
  await msg('user');
  for (const co of ['الريادة القابضة', 'الريادة للتجارة', 'الريادة للمقاولات']) {
    await v.select('#P31_ROLE_ID', 'المدير المالي', co === 'الريادة القابضة' ? n('نمنحه <b>المدير المالي</b> في كل شركة من شركات المجموعة', 'منح الدور في الشركات الثلاث') : null);
    await v.select('#P31_SCOPE_COMPANY', co);
    await v.click('منح الدور', null);
    await msg('grant ' + co);
  }

  // ================================================================ 6) الأرشيف
  await v.setStep('8 · الأرشيف');
  await v.switchApp('noona_doc');
  if (await page.getByRole('button', { name: 'تجهيز الأرشيف' }).count()) {
    await v.click('تجهيز الأرشيف', n('<b>تجهيز الأرشيف</b>: أنواع المستندات وقواعد الأرشفة الافتراضية', '<b>تجهيز الأرشيف</b>'));
    await msg('dms setup');
  }
  await v.nav('أرشفة مستند');
  await v.select('#P12_TYPE', 'السجل التجاري', n('<b>نوع المستند</b> (قائمة): يحدد السرية والصلاحية والملفات المقبولة', 'أرشفة السجل التجاري'));
  await v.type('#P12_TITLE', 'السجل التجاري - شركة الريادة القابضة', n('<b>العنوان</b> و<b>المرجع الورقي</b> (رقم الأصل)', null));
  await v.type('#P12_REF', '1010778899');
  await v.type('#P12_LOC', 'خزنة الإدارة - ملف 1', n('<b>موقع الأصل</b>: الملف أو الرف أو الصندوق', null));
  await v.select('#P12_CONF', 'داخلي', n('<b>السرية</b>: عام، داخلي، سري...', null));
  await v.type('#P12_VFROM_input', day(-200), n('<b>الصلاحية</b> (تواريخ): ينبه النظام قبل الانتهاء', null));
  await v.type('#P12_VTO_input', day(165));
  await page.keyboard.press('Escape'); await page.locator('#P12_LOC').click(); await v.wait(300);
  await page.locator('#P12_FILE_input').setInputFiles(path.join(__dirname, 'assets', 'cr_sample.pdf')).catch(() => log('ERR file'));
  await v.wait(700);
  await v.click('أرشفة', '<b>أرشفة</b>: يحفظ الملف ويأخذ رقم أرشيف');
  await msg('archive');
  await v.nav('البحث في الأرشيف');
  await say('<b>البحث في الأرشيف</b>: بالنوع والرقم والعنوان، ويفتح الملف في عارض داخل النظام', 4000);

  // ================================================================ 7) المراسلات
  await v.setStep('9 · المراسلات');
  await v.nav('المراسلات');
  await sayL('<b>المراسلات</b>: وارد وصادر داخلي وخارجي بأرقام مسلسلة، و«المطلوب مني» بالمهل', 4000);
  await v.click('.nn-mail-compose', '<b>إنشاء مذكرة</b>', false);
  await v.wait(800);
  await v.type(page.locator('.nn-mail-composers .nn-mail-rcp input').first(), 'سامي', n('<b>إلى</b>: بحث باسم الموظف أو الإدارة', null));
  await v.wait(1200);
  await v.click(page.locator('.nn-mail-sug .nn-mail-sg').first(), null, false);
  await v.type('.nn-mail-subj', 'إثبات قرض الريادة القابضة للريادة للتجارة', n('<b>الموضوع</b>', 'مذكرة للمحاسب'));
  await v.select('.nn-mail-prio', 'مهمة', n('<b>الأولوية</b> و<b>التعليمة</b> و<b>المهلة</b>: تصبح مهمة على المستلم', null));
  await v.select('.nn-mail-ins', 'لاتخاذ اللازم');
  await page.locator('.nn-mail-due').fill(day(2)); await v.wait(400);
  await v.type('.nn-mail-txt', 'نأمل اعتماد قيود القرض بين الشركتين (300,000) والتأكد من تطابق الجاري بينهما قبل إعداد القوائم الموحدة.', n('<b>نص المذكرة</b>', null));
  await v.click('.nn-mail-send', '<b>إرسال</b>', false);
  await v.wait(2500);

  // ================================================================ 8) المالية لكل شركة
  await v.setStep('10 · مالية القابضة (دليل خاص)');
  await v.switchApp('noona_fin');
  await sayL('لكل شركة دفترها. نختار عند التجهيز: <b>دليل خاص بالشركة</b> أو <b>دليل المجموعة الموحد</b>', 4500);
  await v.select('#P1_COA_MODE', 'خاص بالشركة', n('القابضة: <b>دليل حسابات خاص بها</b> (حساباتها على حدة)', '<b>دليل خاص</b> للقابضة'));
  await v.click(page.getByRole('button', { name: /تجهيز الأستاذ العام/ }).first(), '<b>تجهيز الأستاذ العام</b>');
  await msg('gl setup holding');
  await v.click(page.getByRole('button', { name: /تجهيز النقدية/ }).first(), '<b>تجهيز النقدية</b>');
  await msg('cash setup holding');
  await v.nav('دليل الحسابات');
  await account('1190', 'جاري الشركات التابعة', 'الأصول المتداولة', true, n('حساب <b>جاري الشركات التابعة</b> (أصل)', 'حساب الجاري بين الشركات'));
  await account('4190', 'رسوم إدارة من الشركات التابعة', 'الإيرادات', false, null);
  await journal('رأس مال الشركة القابضة', [['1102', '2000000', 'إيداع رأس المال', 'dr'], ['3101', '2000000', null, 'cr']], '<b>قيد رأس المال</b>');
  await journal('قرض للريادة للتجارة', [['1190', '300000', 'قرض للتابعة', 'dr'], ['1102', '300000', null, 'cr']], '<b>قرض للتابعة</b>: مدين جاري الشركات التابعة');
  await journal('رسوم إدارة من الريادة للتجارة', [['1102', '40000', null, 'dr'], ['4190', '40000', null, 'cr']], '<b>رسوم إدارة</b> من التابعة');

  await v.setStep('11 · مالية التابعة (دليل المجموعة)');
  await switchCompany('الريادة للتجارة', n('<b>تبديل الشركة</b> من البوابة: الريادة للتجارة', 'تبديل إلى الريادة للتجارة'));
  await v.select('#P1_COA_MODE', 'المجموعة الموحد', n('التابعة: <b>دليل المجموعة الموحد</b>: ينشأ مرة واحدة وتشترك فيه التابعتان', '<b>دليل المجموعة الموحد</b>'));
  await v.click(page.getByRole('button', { name: /تجهيز الأستاذ العام/ }).first(), '<b>تجهيز الأستاذ العام</b>');
  await msg('gl setup trading');
  await v.click(page.getByRole('button', { name: /تجهيز النقدية/ }).first(), null);
  await msg('cash setup trading');
  await v.nav('دليل الحسابات');
  await account('2190', 'جاري الشركة القابضة', 'الخصوم المتداولة', true, n('حساب <b>جاري الشركة القابضة</b> (التزام) في دليل المجموعة', 'جاري القابضة'));
  await account('5290', 'رسوم إدارة للشركة القابضة', 'المصروفات', false, null);
  await journal('قرض من الريادة القابضة', [['1102', '300000', null, 'dr'], ['2190', '300000', null, 'cr']], '<b>القرض</b> عند التابعة: دائن جاري القابضة');
  await journal('رسوم إدارة للريادة القابضة', [['5290', '40000', null, 'dr'], ['1102', '40000', null, 'cr']], null);
  await journal('مبيعات نقدية', [['1102', '180000', null, 'dr'], ['4101', '180000', null, 'cr']], '<b>مبيعات</b> للعملاء');

  await v.setStep('12 · مالية التابعة الثانية');
  await switchCompany('الريادة للمقاولات', 'تبديل إلى <b>الريادة للمقاولات</b>');
  await v.select('#P1_COA_MODE', 'المجموعة الموحد', n('نفس <b>دليل المجموعة</b>: حساب جاري القابضة موجود فيه بالفعل', null));
  await v.click(page.getByRole('button', { name: /تجهيز الأستاذ العام/ }).first(), null);
  await msg('gl setup contracting');
  await v.click(page.getByRole('button', { name: /تجهيز النقدية/ }).first(), null);
  await journal('رأس مال الريادة للمقاولات', [['1102', '500000', null, 'dr'], ['3101', '500000', null, 'cr']], '<b>رأس المال</b>');
  await journal('مصروفات تشغيل', [['5202', '35000', null, 'dr'], ['1102', '35000', null, 'cr']], '<b>مصروفات</b>');

  // ================================================================ 9) المحاسب: الرد والاعتماد
  await v.logout();
  await v.setStep('13 · المحاسب: المذكرة والاعتماد');
  await v.switchApp('noona_doc');
  await v.login(T.acc, T.pwd, n('يدخل <b>سامي المحاسب</b>: المذكرة في «المطلوب مني» بمهلتها', 'دخول المحاسب'));
  await v.nav('المراسلات');
  await v.click(page.locator('.nn-mail-row, .nn-mail-item').first(), 'نفتح المذكرة: التعليمة والمهلة', false);
  await v.wait(1500);
  await v.click(page.locator('[data-a="reply"]').first(), '<b>رد</b>', false);
  await v.wait(900);
  await v.type(page.locator('.nn-mail-composers .nn-mail-txt').last(), 'سيتم الاعتماد الآن ومطابقة الجاري في القوائم الموحدة.', null);
  await v.click(page.locator('.nn-mail-composers .nn-mail-send').last(), '<b>إرسال الرد</b>', false);
  await v.wait(2000);
  await v.switchApp('noona_fin');
  for (const co of ['الريادة القابضة', 'الريادة للتجارة', 'الريادة للمقاولات']) {
    await switchCompany(co, 'اعتماد قيود <b>' + co + '</b>');
    await v.nav('القيود اليومية');
    for (let k = 0; k < 4; k++) {
      const r = page.locator('.a-IRR-table tr').filter({ hasText: /بانتظار|مرسل|SUBMITTED/ }).locator('td a').first();
      if (!(await r.count())) break;
      await v.click(r, k === 0 ? n('القيد بانتظار الاعتماد: نفتحه', null) : null);
      await v.click('اعتماد وترحيل', k === 0 ? '<b>اعتماد وترحيل</b>' : null);
      await msg('approve ' + co + ' ' + k);
      await v.nav('القيود اليومية');
    }
  }

  // ================================================================ 10) التجميع والقوائم الموحدة
  await v.setStep('14 · القوائم الموحدة');
  await v.nav('مجموعات التجميع');
  await sayL('<b>مجموعة التجميع</b>: الشركات المشمولة (مجموعة الأعمال) وعملة التجميع وحسابات الاستبعاد', 4500);
  await v.click('مجموعة تجميع جديدة', '<b>مجموعة تجميع جديدة</b>');
  await v.type('#P53_CODE', 'CONS-RYD', n('الرمز والاسم', null));
  await v.type('#P53_NAME_AR', 'القوائم الموحدة لمجموعة الريادة');
  await v.select('#P53_BG', 'مجموعة الريادة', n('<b>مجموعة الأعمال</b>: تشمل القابضة والتابعتين', '<b>مجموعة الريادة</b>'));
  await v.select('#P53_CURRENCY', 'SAR');
  await v.type('#P53_ELIM', '4190, 5290', n('<b>حسابات استبعاد إضافية</b>: رسوم الإدارة بين الشركات (الجاري يستبعد بتصنيفه)', 'استبعاد رسوم الإدارة بين الشركات'));
  await v.click('حفظ', null);
  await msg('consolidation group');
  await say('<b>الشركات المشمولة</b> تظهر أسفل النموذج', 3000);
  await v.nav('القوائم المالية الموحدة');
  await v.select('#P54_GROUP', 'مجموعة الريادة');
  await v.select('#P54_KIND', 'المركز المالي', n('<b>القائمة</b>: المركز المالي، الدخل، أو الميزان؛ و<b>عمود لكل شركة</b>', null));
  await v.click('عرض', '<b>المركز المالي الموحد</b>');
  await page.evaluate(() => { const t = document.querySelector('.nn-cns'); if (t) t.scrollIntoView({ block: 'start', behavior: 'smooth' }); });
  await say('عمود لكل شركة، ثم <b>الاستبعاد</b> (القرض 300,000 بين الشركات) ثم <b>الموحد</b>؛ والمركز متوازن', 6500);
  await v.select('#P54_KIND', 'الدخل');
  await v.click('عرض', '<b>قائمة الدخل الموحدة</b>');
  await page.evaluate(() => { const t = document.querySelector('.nn-cns'); if (t) t.scrollIntoView({ block: 'start', behavior: 'smooth' }); });
  await say('رسوم الإدارة 40,000 تستبعد من الإيراد والمصروف؛ <b>صافي الربح الموحد</b> = 180,000 − 35,000 = 145,000', 6500);
  await v.select('#P54_KIND', 'ميزان');
  await v.click('عرض', '<b>ميزان المراجعة الموحد</b>');
  await say('الميزان الموحد متوازن', 3000);
  await v.select('#P54_KIND', 'المركز المالي');
  await v.click('اعتماد التجميع للفترة', '<b>اعتماد التجميع</b>: يحفظ نتائج الفترة (لا يعتمد إن لم يتوازن)');
  await msg('approve consolidation');
  await v.setStep('');
  await v.card('مجموعة الريادة', ['مؤسسة ← قابضة وتابعتان وفروع ← هيكل ومناصب ← مستخدمون وأدوار',
    'أرشيف ومراسلات ← مالية لكل شركة ← قوائم موحدة معتمدة'], 5000, 'نونا بلس');
  log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
