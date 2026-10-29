/* فيديو 6: الموارد البشرية والرواتب - تجهيز، ملف موظف بعقده وراتبه وحسابه البنكي، عمل إضافي يعتمد، تشغيل رواتب الشهر
   (الحساب، التأمينات الاجتماعية، الاعتماد، ترحيل القيد ومخصصات نهاية الخدمة، الصرف وملف التحويل)، والتقارير.
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/v05_hr_payroll.js <outDir> */
'use strict';
const video = require('./vlib.js');
const out = process.argv[2];
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;
const MONTH = new Date().toISOString().slice(0, 7);

(async () => {
  const v = await video('noona_hr', out, 'v05_hr_payroll');
  const { page } = v;

  await page.goto('http://localhost:8090/ords/r/noonaplus/noona_master/home'); await v.settle();
  await v.card('الموارد البشرية والرواتب', ['ملف الموظف والعقد والراتب', 'الإضافي · مسير الرواتب · التأمينات · القيد والصرف'], 4500, 'فيديو 6 · إدخال حقيقي · مجموعة النور');

  // ------------------------------------------------ 1) التجهيز
  await v.setStep('1 · التجهيز');
  await v.login(ADMIN, PWD, 'يفتح أحمد تطبيق <b>الموارد البشرية والرواتب</b>');
  await v.click(page.getByRole('button', { name: /تجهيز الموارد البشرية/ }).first(),
    '<b>تجهيز</b>: حسابات الرواتب والمستحقات ونهاية الخدمة، ومجموعة الرواتب الشهرية وفترات السنة');

  // ------------------------------------------------ 2) الموظف
  await v.setStep('2 · ملف موظف');
  await v.nav('موظف جديد');
  await v.type('#P11_NAME_AR', 'خالد عبدالله العتيبي', 'البيانات الشخصية: الاسم والجنسية والهوية');
  await v.select('#P11_NATIONALITY', 'السعودية');
  await v.type('#P11_NATIONAL_ID', '1012345678');
  await v.select('#P11_GENDER', 'ذكر');
  await v.type('#P11_MOBILE', '0501112233', 'الجوال');
  await v.type('#P11_HIRE_input', MONTH.slice(0, 4) + '-01-01', 'التعيين: التاريخ والوظيفة والفرع ومركز التكلفة');
  await v.type('#P11_JOB', 'فني صيانة');
  await v.select('#P11_BRANCH', 'المركز الرئيسي');
  await v.select('#P11_CC', 'CC-600', 'مركز التكلفة: يوزع عليه قيد الرواتب');
  await v.select('#P11_BANK', 'الأهلي', 'البنك والآيبان: لملف التحويل البنكي');
  await v.type('#P11_IBAN', 'SA0380000000608010167519');
  await v.select('#P11_CONTRACT_TYPE', 'غير محدد', 'العقد');
  await v.type('#P11_BASIC', '6000', '<b>الراتب</b>: الأساسي والسكن والنقل');
  await v.type('#P11_HOUSING', '1500');
  await v.type('#P11_TRANSPORT', '500');
  await v.click('حفظ الملف', '<b>حفظ الملف</b>: رقم الموظف تلقائي E1001');
  await v.say('بعد الحفظ: تعديل الراتب والنقل يعتمدان بتاريخ سريان ويحفظ تاريخهما', 4000);

  // ------------------------------------------------ 3) الإضافي
  await v.setStep('3 · عمل إضافي');
  await v.nav('الحضور والإضافي');
  await v.say('الحضور والانصراف والغياب، و<b>طلب الإضافي</b> واعتماده', 3000);
  await v.select('#P25_OT_EMP', 'خالد', 'طلب إضافي: الموظف والتاريخ والساعات');
  await v.type('#P25_OT_DATE_input', MONTH + '-15');
  await v.type('#P25_OT_HOURS', '4');
  await v.type('#P25_OT_REASON', 'إنهاء صيانة أسطول عميل');
  await v.click('طلب الإضافي', '<b>طلب الإضافي</b>');
  await v.select('#P25_OT_PENDING', 'خالد', 'الاعتماد: الطلب المعلق والساعات الفعلية');
  await v.type('#P25_OT_ACTUAL', '4');
  await v.click('اعتماد', '<b>اعتماد</b>: يدخل مسير الشهر: أجر الساعة + 50% من الأساسي (نظام العمل)');

  // ------------------------------------------------ 4) مسير الرواتب
  await v.setStep('4 · مسير الرواتب');
  await v.nav('تشغيلات الرواتب');
  await v.select('#P40_PERIOD', MONTH, 'نختار <b>فترة الشهر</b>');
  await v.click('إنشاء وحساب الرواتب', '<b>إنشاء وحساب الرواتب</b>');
  await v.say('المسير: الأساسي والبدلات والإضافي، وخصم <b>التأمينات</b> 9.75% وحصة المنشأة 11.75% للسعودي', 5500);
  await v.say('تنبيهات المراجعة تظهر أعلى المسير (مثل نقص بيانات الموظف) قبل الاعتماد', 3500);
  await v.click('اعتماد الرواتب', '<b>اعتماد الرواتب</b>');
  await v.click('ترحيل القيد', '<b>ترحيل القيد</b>: الرواتب حسب مركز التكلفة، ومخصص نهاية الخدمة والإجازات');
  await v.select('#P41_BANK', 'الحساب الجاري', 'الصرف: من البنك');
  await v.click(page.getByRole('button', { name: /صرف وإنشاء ملف التحويل/ }), '<b>صرف وإنشاء ملف التحويل</b> (حماية الأجور)');
  console.log('pay: ' + await v.alerts());
  await v.say('تم الصرف وترحيل قيده، وملف التحويل جاهز للرفع للبنك', 3500);

  // ------------------------------------------------ 5) التقارير
  await v.setStep('5 · التقارير');
  await v.nav('التقارير');
  await v.select('#P60_REPORT', 'التزام مكافأة نهاية الخدمة', '<b>التزام مكافأة نهاية الخدمة</b> لكل موظف حتى تاريخه');
  await v.click('عرض');
  await v.say('ومن نفس الشاشة: القوى العاملة والتوطين، أرصدة الإجازات، الحضور، الهويات القريبة الانتهاء، السلف', 5000);
  await v.card('التالي', ['الفيديو 7: المستندات والمراسلات', 'الأرشيف والبريد الداخلي'], 3500, 'نونا بلس');
  console.log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
