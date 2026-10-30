/* مشهد دليل الحسابات المشترك بين الفيديو القصير والمطول: إدخال يدوي (حساب رئيسي تجميعي ثم فرعي حركة تحته) ثم استيراد من ملف CSV
   بعضه صحيح وصف خاطئ عمداً ليظهر تقرير الرفض. long=true يضيف شرح الحقول وقواعد الملف. */
'use strict';
const fs = require('fs');
const os = require('os');
const path = require('path');
const CSV = path.join(__dirname, 'assets', 'coa_import.csv');

// في شركة فيها حسابات مضافة سابقاً: أول رموز خالية بدل الرموز الثابتة، وملف استيراد مولد بها
async function freeCodes(page) {
  // القائمة تعرض 50 صفاً فقط؛ الرموز المستخدمة من قائمتي الآباء والحسابات (تجميعي + حركة)
  const used = new Set(await page.evaluate(() => [...document.querySelectorAll('#P10_PARENT option, #P10_ACCOUNT option')]
    .map((o) => o.textContent.trim().split(/\s+-\s+|\s/)[0])));
  const pick = (list) => list.find((c) => !used.has(String(c)) && !used.has(c + '01'));
  const m = pick([5220, 5230, 5240, 5250, 5260, 5270, 5280, 5290]), a = pick([1150, 1160, 1170, 1180, 1190]), e = pick([53, 54, 55, 56, 57, 58, 59]);
  if (m === undefined || a === undefined || e === undefined) return null;
  const csv = fs.readFileSync(CSV, 'utf8').replace(/\b1150(\d*)/g, a + '$1').replace(/^53,/m, e + ',').replace(/\b53(0\d)\b/g, e + '$1').replace(/,53,/g, ',' + e + ',');
  const file = path.join(os.tmpdir(), 'coa_import_' + a + '.csv');
  fs.writeFileSync(file, csv);
  return { m: String(m), a: String(a), e: String(e), file };
}

module.exports = async function coa(v, long) {
  const { page } = v;
  const k = (await freeCodes(page)) || { m: k.m, a: '1150', e: '53', file: CSV };
  const say = (t, ms) => v.say(t, ms);
  // بحث القائمة التفاعلية برمز الحساب ليظهر هو وما تحته
  async function find(code) {
    const box = page.locator('.a-IRR-search-field, input[id$="_search_field"]').first();
    if (!await box.count()) return;
    // إزالة بحث سابق حتى لا تتراكم الفلاتر
    for (let i = 0; i < 5; i++) {
      const x = page.locator('.a-IRR-controls .a-IRR-button--remove, button.a-IRR-button--remove').first();
      if (!await x.count()) break;
      await x.click().catch(() => {}); await v.wait(1200); await v.settle();
    }
    await v.type(box, code, `البحث في الدليل برمز <b>${code}</b>`);
    await page.keyboard.press('Enter'); await v.wait(1500); await v.settle();
    await page.evaluate(() => { const t = document.querySelector('.a-IRR-table'); if (t) t.scrollIntoView({ block: 'center', behavior: 'smooth' }); });
  }
  await v.say('<b>دليل الحسابات</b>: شجرة بمستويات؛ الحساب <b>التجميعي</b> يجمع أرصدة ما تحته، و<b>حساب الحركة</b> هو الذي تقيد عليه القيود', long ? 6000 : 4500);
  if (long) {
    await say('الأعمدة: الرمز، الحساب (بإزاحة حسب المستوى)، النوع، الطبيعة مدين/دائن، تجميعي/حركة، النظام الفرعي، القيد اليدوي، الحالة', 6500);
    await say('الحسابات المرتبطة بنظام فرعي (العملاء، الموردون، المخزون، النقدية) تقيد آلياً من مستنداتها ولا تقيد يدوياً', 5500);
  }
  // ---------------- إدخال يدوي
  await v.setStep('دليل الحسابات · إدخال يدوي');
  await page.locator('#P10_PARENT').scrollIntoViewIfNeeded().catch(() => {});
  await say('<b>أولاً: الإدخال اليدوي</b> من نموذج «حساب جديد» أسفل الدليل', 3500);
  await v.select('#P10_PARENT', '52 - ', long ? '<b>تحت الحساب الرئيسي</b>: قائمة بالحسابات التجميعية فقط؛ نختار <b>52 المصروفات التشغيلية والإدارية</b>' : 'نختار الأب: <b>52 المصروفات التشغيلية</b>');
  await v.type('#P10_CODE', k.m, long ? '<b>رمز الحساب</b>: فريد في الدليل، ويبدأ عادة برمز أبيه' : 'رمز الحساب الرئيسي الجديد');
  await v.type('#P10_NAME', 'مصروفات السيارات', '<b>اسم الحساب</b> بالعربي');
  await v.select('#P10_POSTABLE', 'تجميعي', long ? '<b>نوع الحساب</b>: <b>تجميعي</b> لأنه سيضم حسابات فرعية؛ النوع والطبيعة يرثهما من الأب' : 'نوعه <b>تجميعي</b> ليضم حسابات فرعية');
  await v.click('إضافة الحساب', '<b>إضافة الحساب</b>');
  await say(`أضيف الحساب الرئيسي <b>${k.m} مصروفات السيارات</b> وصار يظهر في قائمة الآباء`, 3500);
  await page.locator('#P10_PARENT').scrollIntoViewIfNeeded().catch(() => {});
  await v.select('#P10_PARENT', k.m + ' - ', `ثم حساب <b>فرعي</b> تحته: الأب <b>${k.m}</b>`);
  await v.type('#P10_CODE', k.m + '01', null);
  await v.type('#P10_NAME', 'وقود السيارات', null);
  await v.select('#P10_POSTABLE', 'حركة', '<b>حساب حركة</b>: تقيد عليه القيود والسندات');
  await v.click('إضافة الحساب', '<b>إضافة الحساب</b>');
  await find(k.m);
  await say(`في الدليل: <b>${k.m}</b> تجميعي و<b>${k.m}01 وقود السيارات</b> حساب حركة بإزاحة تحت أبيه`, 4500);
  if (long) await say('الرمز المكرر أو الأب غير التجميعي يرفضان برسالة واضحة؛ والحساب الذي عليه حركة لا يحذف بل يوقف من «إيقاف أو تفعيل حساب»', 6000);
  // ---------------- الاستيراد من ملف
  await v.setStep('دليل الحسابات · استيراد من ملف');
  await page.locator('#P10_FILE').scrollIntoViewIfNeeded().catch(() => {});
  await page.evaluate(() => { const e = document.querySelector('.nn-csv'); if (e) e.scrollIntoView({ block: 'center', behavior: 'smooth' }); });
  await say('<b>ثانياً: الاستيراد من ملف خارجي</b> (CSV، أو Excel محفوظ باسم CSV UTF-8) لإدخال حسابات كثيرة دفعة واحدة', 5000);
  await say('الأعمدة: <b>رمز الحساب، اسم الحساب، الحساب الأب، النوع، حساب حركة</b> (نعم/لا) بالعربي أو الإنجليزي', 5000);
  if (long) {
    await say('<b>النوع</b> يكفي للحساب الأعلى (أصول، خصوم، حقوق ملكية، إيرادات، مصروفات)، والفرعي يأخذ نوع أبيه', 5500);
    await say('الأب يكون موجوداً في الدليل أو في الملف نفسه بأي ترتيب؛ وكل صف مستقل: الخاطئ يرفض ولا يوقف الباقي', 5500);
  }
  await say(`ملفنا: <b>${k.a}</b> العهد وتحته عهدتان، ثم <b>${k.e}</b> مصروفات البيع وتحته 3 حسابات، أحدها بأب غير موجود (9999) عمداً`, 6000);
  const inp = page.locator('#P10_FILE input[type=file], input[type=file][name="P10_FILE"]').first();
  await inp.setInputFiles(k.file);
  await v.wait(900);
  await v.click('استيراد الحسابات', '<b>استيراد الحسابات</b>');
  console.log('coa import: ' + await v.alerts());
  await page.evaluate(() => { const r = [...document.querySelectorAll('.t-Region')].filter((x) => /نتيجة استيراد/.test((x.querySelector('.t-Region-title') || x).textContent)).pop();
    if (r) { r.scrollIntoView({ block: 'start', behavior: 'smooth' }); r.classList.add('nnv-hl'); } });
  await say('النتيجة: <b>تم استيراد 6 حسابات ورفض 1</b>، وتقرير المهمة يبين رقم الصف وسبب الرفض: الحساب الأب 9999 غير موجود', 6500);
  if (long) await say('نصحح الصف المرفوض في الملف ونعيد استيراده وحده؛ وسجل كل عمليات الاستيراد في مركز التكاملات ← الاستيراد', 5500);
  await find(k.a);
  await say(`الحسابات المستوردة ظهرت في الشجرة بمستوياتها تحت آبائها: <b>${k.a}</b> ← ${k.a}01، ${k.a}02 ، ثم <b>${k.e}</b> ← ${k.e}01، ${k.e}02`, 5500);
  await page.evaluate(() => window.scrollTo({ top: 0, behavior: 'smooth' }));
};
