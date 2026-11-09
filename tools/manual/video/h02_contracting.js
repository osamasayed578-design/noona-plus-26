/* محاسبة عقود المقاولات على مشروع «برج الريادة السكني» (الريادة للمقاولات - المؤسسة التجريبية demo_holding):
   1 المشروع: طريقة الاعتراف بالإيراد والتكلفة المتوقعة وبطاقة الربحية ← 2 العقد: الغرامة اليومية وسقفها
   ← 3 مستخلص بالكميات والمواد المشونة وأيام التأخير ← 4 تشغيل المعدات وتحميلها ← 5 خطابات الضمان (جديد، إصدار، تمديد)
   ← 6 الاعتراف بالإيراد حسب نسبة الإنجاز (معاينة، عكس، إعادة بتقدير جديد) ← 7 التقارير ← 8 الحساب الختامي.
   LONG=1 شرح مفصل (الفيديو المطول)، وبدونه القصير.
   PW_PATH=... NOONA_PORT=8091 [LONG=1] NOONA_DEMO_PWD=... node tools/manual/video/h02_contracting.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const LONG = process.env.LONG === '1';
const PORT = process.env.NOONA_PORT || 8090;
const BASE = 'http://localhost:' + PORT + '/ords/r/noonaplus/';
const PWD = process.env.NOONA_DEMO_PWD || 'Riyada#2026x';
const day = (n) => { const d = new Date(Date.now() + n * 864e5); return d.toISOString().slice(0, 10); };

(async () => {
  const v = await video('noona_prj', out, LONG ? 'h02_contracting_long' : 'h02_contracting_short');
  const { page } = v;
  const say = (t, ms) => v.say(t, LONG ? ms : Math.round(ms * 0.6));
  const sayL = (t, ms) => (LONG ? v.say(t, ms) : Promise.resolve());
  const n = (longNote, shortNote) => (LONG ? longNote : (shortNote === undefined ? null : shortNote));
  const log = (m) => console.log(m);
  const msg = async (step) => { const a = await v.alerts(); log(step + ': ' + (a || '(no message)')); if (/ORA-|NOONA-|خطأ|حدث/.test(a)) log('ERR ' + step); return a; };
  const app = (alias, pageAlias) => page.goto(BASE + alias + '/' + pageAlias + '?session=' + v.sess).then(() => v.settle());
  const scrollTo = (sel) => page.evaluate((s) => { const e = document.querySelector(s); if (e) e.scrollIntoView({ block: 'start', behavior: 'smooth' }); }, sel);

  await v.login(process.env.NOONA_DEMO_USER || 'RYD_ADMIN', PWD, null);
  await v.card('محاسبة عقود المقاولات', ['المستخلصات بالمواد المشونة وغرامات التأخير · المعدات · خطابات الضمان',
    'الاعتراف بالإيراد حسب نسبة الإنجاز (IFRS 15) · مخصص خسائر العقود · الحساب الختامي'], 5500,
    LONG ? 'الفيديو المطول · مشروع برج الريادة السكني' : 'الفيديو القصير · مشروع برج الريادة السكني');
  // الشركة: الريادة للمقاولات
  await app('noona_portal', 'company');
  await v.select('#P3_COMPANY_ID', 'الريادة للمقاولات', n('نعمل في شركة <b>الريادة للمقاولات</b> (تابعة لمجموعة الريادة)', 'الريادة للمقاولات'));
  await v.click('تبديل', null);
  await v.switchApp('noona_prj');

  // ================================================================ 1) المشروع
  await v.setStep('1 · المشروع وربحيته المتوقعة');
  await v.nav('لوحة المشروعات');
  const prj = page.locator('.a-IRR-table tr').filter({ hasText: 'CON-TWR' }).locator('a').first();
  await v.click(prj, n('نفتح مشروع <b>برج الريادة السكني</b>', 'المشروع'));
  await scrollTo('.nn-prj-fc');
  await say('<b>ربحية العقد المتوقعة</b>: قيمة العقد، التكلفة المتوقعة عند الإنجاز، التكلفة حتى تاريخه، الربح المتوقع ونسبة الإنجاز', 6500);
  await v.click('تعديل البيانات', n('بيانات المشروع', null));
  await page.evaluate(() => { const e = document.getElementById('P82_METHOD'); if (e) e.scrollIntoView({ block: 'center', behavior: 'smooth' }); });
  await say('<b>طريقة الاعتراف بالإيراد</b>: نسبة الإنجاز بالتكلفة (IFRS 15)، و<b>التكلفة المتوقعة عند الإنجاز</b> آخر تقدير', 6000);
  await sayL('البدائل: بالفوترة (الإيراد عند اعتماد المستخلص)، أو بالإنجاز الفعلي لبنود العمل، أو بالمعالم', 5000);
  await page.goBack(); await v.settle();

  // ================================================================ 2) العقد والمستخلص
  await v.setStep('2 · العقد الرئيسي: الغرامة اليومية');
  const mc = page.locator('a').filter({ hasText: 'CON-TWR-MC' }).first();
  if (await mc.count()) await v.click(mc, n('العقد الرئيسي مع المالك', null)); else log('ERR main contract link');
  await say('العقد: المحتجز 10%، <b>غرامة التأخير 2,000 يومياً</b> بسقف 10% من قيمة العقد، وجدول الكميات', 5500);
  await v.setStep('3 · مستخلص: الكميات والمواد المشونة والغرامة');
  await v.click('مستخلص جديد', n('<b>مستخلص جديد</b>: يبدأ بالكميات المعتمدة سابقاً', '<b>مستخلص جديد</b>'));
  await v.wait(1500);
  const q = page.locator('.nn-prj-edit tbody tr').first().locator('.c-q');
  const prevQ = Number(await q.getAttribute('data-prev')) || 0;
  await v.type(q, String(prevQ + 400), n('<b>الكمية التراكمية</b> حتى تاريخه لبند الخرسانة: ' + (prevQ + 400) + ' م³ (السابق ' + prevQ + ')',
    'الكمية التراكمية ' + (prevQ + 400)));
  await v.type('.c-pdays', '3', n('<b>أيام التأخير</b>: تحسب الغرامة من الغرامة اليومية في العقد حتى سقفها', 'تأخير 3 أيام'));
  const prevM = Number(await page.locator('.c-mos').inputValue()) || 0;
  const newM = Math.max(prevM - 70000, 0);
  await v.type('.c-mos', String(newM), n('<b>المواد المشونة بالموقع</b> حتى تاريخه ' + newM.toLocaleString('en') + '؛ كانت ' + prevM.toLocaleString('en')
    + ' فيسترد الفرق بعد تركيبها في الأعمال', 'مواد مشونة ' + newM.toLocaleString('en')));
  await v.click('.nn-c-save', '<b>حساب وحفظ</b>', false);
  await v.wait(2000);
  await scrollTo('.nn-prj-cert-sum');
  await say('الصافي = قيمة الفترة − استرداد المواد المركبة − المحتجز − غرامة التأخير + الضريبة', 6500);
  await v.click('اعتماد وترحيل', n('<b>اعتماد وترحيل</b>: قيد المستخلص وذمة على المالك', '<b>اعتماد</b>'));
  await msg('approve claim');
  await sayL('القيد: الغرامة في حساب «غرامات تأخير على العقود» تخفض الإيراد، والمواد المشونة في «مبالغ مفوترة مقابل مواد مشونة» لا إيراد', 6500);

  // ================================================================ 3) المعدات
  await v.setStep('4 · تشغيل المعدات');
  await v.nav('المعدات وتشغيلها');
  await say('<b>المعدات</b>: مملوكة أو مستأجرة بتكلفة الساعة، ونسبة استغلال كل معدة هذا الشهر', 5000);
  await v.select('#P93_EQ', 'EQ-EXC', n('المعدة: الحفار', null));
  await v.select('#P93_PROJECT', 'CON-TWR', n('المشروع', null));
  await v.wait(1200);
  await v.type('#P93_HOURS', '9', n('<b>الساعات</b> اليوم؛ تكلفة الساعة من بطاقة المعدة (350)', 'تشغيل 9 ساعات'));
  await v.click('تسجيل التشغيل', null);
  await msg('log usage');
  await v.click('تحميل التشغيل على المشروع', n('<b>تحميل التشغيل</b>: قيد تكلفة المشروع مقابل «تكلفة المعدات المحملة»', '<b>تحميل على المشروع</b>'));
  await msg('post usage');

  // ================================================================ 4) خطابات الضمان
  await v.setStep('5 · خطابات الضمان');
  await v.nav('خطابات الضمان');
  await say('الخطابات الصادرة منا والواردة لنا، و<b>تنبيه</b> بما ينتهي خلال 60 يوماً (باللون الأحمر)', 5500);
  await v.type('#P92_NO', 'LG-' + String(Date.now()).slice(-6), n('<b>خطاب جديد</b>: الرقم', 'خطاب دفعة مقدمة'));
  await v.select('#P92_TYPE', 'دفعة مقدمة', n('<b>النوع</b>: ابتدائي، نهائي، دفعة مقدمة، بدل محتجز، صيانة', null));
  await v.select('#P92_CONTRACT', 'CON-TWR-MC', null);
  await v.select('#P92_BANK', 'البنك', null);
  await v.type('#P92_AMOUNT', '250000', n('<b>المبلغ</b>، و<b>الغطاء النقدي</b> إن طلبه البنك (يجنب من البنك عند الإصدار)', null));
  await v.type('#P92_EXPIRY_input', day(200), null);
  await v.click('حفظ الخطاب', null);
  await msg('save guarantee');
  await v.click('تنفيذ الإجراء', n('<b>إصدار</b> الخطاب', '<b>إصدار</b>'));
  await msg('issue guarantee');
  await v.select('#P92_G', 'LG-2026-0451', n('خطاب حسن التنفيذ ينتهي قريباً: نمدده', 'تمديد خطاب ينتهي قريباً'));
  await v.select('#P92_ACTION', 'تمديد', null);
  await v.type('#P92_NEWEXP_input', day(380), n('<b>تاريخ الانتهاء الجديد</b> حتى نهاية فترة الضمان', null));
  await v.type('#P92_REASON', 'حتى نهاية فترة الضمان', null);
  await v.click('تنفيذ الإجراء', null);
  await msg('extend guarantee');

  // ================================================================ 5) الاعتراف بالإيراد
  await v.setStep('6 · الاعتراف بالإيراد حسب نسبة الإنجاز');
  await v.nav('الاعتراف بالإيراد (نسبة الإنجاز)');
  await sayL('الإيراد المستحق = نسبة الإنجاز × (قيمة العقد − الغرامات)، ويقارن بالمفوتر بالمستخلصات', 5500);
  await v.select('#P91_PROJECT', 'CON-TWR', n('المشروع', null));
  await v.wait(1500);
  await v.select('#P91_RUN', 'CON-TWR', n('تحدث تقدير التكلفة: نعكس آخر اعتراف أولاً', '<b>عكس</b> آخر اعتراف لتحديث التقدير'));
  await v.type('#P91_REASON', 'تحديث التكلفة المتوقعة', null);
  await v.click('عكس الاعتراف', null);
  await msg('reverse run');
  await v.type('#P91_EAC', '3400000', n('<b>التكلفة المتوقعة الجديدة</b> 3,400,000', 'تكلفة متوقعة جديدة'));
  await v.click('معاينة', '<b>معاينة</b>');
  await v.wait(1500);
  await scrollTo('.nn-prj-fc');
  await say('نسبة الإنجاز بالتكلفة، الإيراد المستحق مقابل المفوتر، و<b>أصول العقود</b> (إيراد غير مفوتر)', 6500);
  await v.click('اعتراف بالإيراد وترحيل', n('<b>اعتراف بالإيراد وترحيل</b>: قيد الفرق عن آخر اعتراف', '<b>ترحيل</b>'));
  await msg('run revenue');
  await sayL('لو زادت التكلفة المتوقعة على قيمة العقد يثبت فوراً <b>مخصص خسائر العقود</b> لكامل الخسارة المتبقية', 5500);

  // ================================================================ 6) التقارير والحساب الختامي
  await v.setStep('7 · التقارير');
  await v.nav('تقارير المشروعات');
  await v.select('#P90_REPORT', 'الأعمال تحت التنفيذ', null);
  await v.wait(1500);
  await v.click('عرض', '<b>كشف الأعمال تحت التنفيذ</b>');
  await say('لكل مشروع: قيمة العقد، التكلفة المتوقعة، الإنجاز، الإيراد المستحق، المفوتر، أصول والتزامات العقود، والربح المتوقع', 6500);
  await v.select('#P90_REPORT', 'تشغيل المعدات', null);
  await v.wait(1500);
  await v.click('عرض', n('<b>تشغيل المعدات</b>: الساعات والاستغلال والتكلفة المحملة', null));
  await v.wait(2500);
  await v.setStep('8 · الحساب الختامي للعقد');
  await v.nav('لوحة المشروعات');
  await v.click(page.locator('.a-IRR-table tr').filter({ hasText: 'CON-TWR' }).locator('a').first(), null);
  const mc2 = page.locator('a').filter({ hasText: 'CON-TWR-MC' }).first();
  if (await mc2.count()) await v.click(mc2, null);
  await v.click('الحساب الختامي', '<b>الحساب الختامي</b> للعقد');
  await say('القيمة الأصلية وأوامر التغيير والمنفذ والمستخلصات والمواد المشونة والغرامات والمحتجز والدفعة المقدمة والمحصل والرصيد', 7000);
  await sayL('بعد «المستخلص الختامي» يصبح نهائياً ويغلق العقد؛ يبقى الإفراج عن المحتجز بعد فترة الضمان', 5000);
  await v.setStep('');
  await v.card('محاسبة المقاولات في نونا بلس', ['مستخلصات بالمواد المشونة والغرامات ← معدات ← خطابات ضمان',
    '← اعتراف بالإيراد حسب نسبة الإنجاز ومخصص الخسائر ← حساب ختامي'], 5000, 'نونا بلس');
  log('saved ' + await v.done());
})().catch((e) => { console.error('ERR ' + e.message); process.exit(1); });
