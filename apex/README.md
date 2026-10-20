# تطبيقات Oracle APEX 24.2 - NOONA PLUS

Workspace: **`NOONAPLUS`** · Parsing Schema: **`NOONA_APP`** (كل التطبيقات في نفس الـ Workspace لتشترك في الجلسة).

كل تطبيق في مجلد باسمه المستعار (Alias). **أرقام التطبيقات لا تستخدم في الكود أبداً**؛
الروابط بين التطبيقات تبنى بالاسم المستعار للتطبيق والصفحة:

```sql
APEX_PAGE.GET_URL(p_application => 'NOONA_PORTAL', p_page => 'TASK', p_items => 'P_TASK_ID', p_values => :ID)
-- أو: f?p=NOONA_PORTAL:TASK:&SESSION.::NO::P_TASK_ID:123
```

## التطبيقات والأسماء المستعارة

| Alias | التطبيق | ملاحظات |
|---|---|---|
| `NOONA_MASTER` | المكونات المشتركة (Master) | لا يدخله المستخدم؛ باقي التطبيقات تشترك (Subscribe) في مكوناته |
| `NOONA_PORTAL` | البوابة | الدخول، المنصة الرئيسية، صندوق المهام (صفحة alias `TASK` وعنصر `P_TASK_ID`)، الإشعارات |
| `NOONA_ADMIN` | إدارة المؤسسة | PLT, SEC/ORG, WF, DLG, REF, LOC, التدقيق |
| `NOONA_FIN` | المالية | GL, AR, AP, CSH, FA |
| `NOONA_SCM` | سلسلة الإمداد | INV, PUR, SAL |
| `NOONA_POS` | نقاط البيع | |
| `NOONA_PRJ` | المشروعات والعقار | PRJ, RE, PRP, MNT |
| `NOONA_HR` | الموارد البشرية | HR, PAY |
| `NOONA_MFG` | التصنيع | MFG |
| `NOONA_DOC` | المستندات والمراسلات | DMS, COR |
| `NOONA_BI` | التقارير والذكاء الاصطناعي | BI, AI |
| `NOONA_PLATFORM` | لوحة المنصة | لمسؤول المنصة فقط؛ مصادقة و MFA منفصلان |

## إعدادات التطبيق الأساسي `NOONA_MASTER` قبل التصدير

1. **Create Application**: الاسم `NOONA Master`، الرقم حسب المتاح لديك، Alias = `NOONA_MASTER`،
   Parsing Schema = `NOONA_APP`، Theme = Universal Theme 42، Primary Language = Arabic (ar)
   (يعكس الاتجاه RTL تلقائياً)، Date format = `DD/MM/YYYY`.
2. **Authentication Scheme** باسم `NOONA Auth` (مؤقتاً Oracle APEX Accounts)، وفي Session Sharing:
   Type = Custom، Cookie Name = `NOONA_SESSION`. نفس الاسم في كل التطبيقات = دخول واحد.
   (لا تكتب Post-Authentication الآن؛ سأضيفه في الملف المصدر.)
3. **Security Attributes**: Initialization PL/SQL و Cleanup PL/SQL اتركهما فارغين؛ سأضيفهما.
4. اترك الباقي افتراضياً. لا حاجة لصفحات غير الصفحة الرئيسية وصفحة الدخول.

## طريقة التصدير

App Builder ← التطبيق ← Export/Import ← **Export**:

| الخيار | القيمة |
|---|---|
| Export As | Zip File |
| Split into Multiple Files | Yes |
| Export Format | SQL (ويمكن إضافة Readable YAML للمراجعة) |
| Supporting Object Definitions | No (قاعدة البيانات تثبت من `db/install.sql`) |
| Export Comments / Translations | Yes |

ثم فك الضغط داخل `apex/NOONA_MASTER/` وارفعه على GitHub (أو أرسل ملف zip هنا).

## الاشتراك في التطبيقات التالية

عند إنشاء كل تطبيق جديد: Shared Components ← Authentication Schemes ← Create ← **As a Copy of an
Existing Scheme** من `NOONA_MASTER` مع تفعيل **Subscribe**. وبالمثل لقواعد الصلاحيات (Authorization
Schemes) والقوائم المشتركة (LOVs) وقوالب الثيم. أي تعديل لاحق في Master ينشر بزر **Publish**.

## NOONA_MASTER (التطبيق 115) - ما أضيف على التصدير

| المكون | القيمة |
|---|---|
| Alias / اللغة | `NOONA_MASTER` / `ar` (RTL) |
| Authentication | `NOONA Auth` (APEX Accounts)، Cookie `NOONA_SESSION`، Post-Auth = `noona_apex_pkg.post_auth` |
| Initialization PL/SQL | `noona_apex_pkg.init_request(:APP_USER, :APP_SESSION)` |
| Cleanup PL/SQL | `noona_apex_pkg.cleanup_request` |
| صلاحية التطبيق | `NOONA - Authenticated` |
| Authorization Schemes | `NOONA - Authenticated`، `NOONA - Tenant User`، `NOONA - Tenant Admin`، `NOONA - Platform Admin` |
| LOVs | `NOONA_COMPANIES`، `NOONA_BRANCHES` (فروع الشركة الحالية)، `NOONA_CURRENCIES`، `NOONA_COUNTRIES` |

صلاحية لعملية محددة داخل أي صفحة: Authorization Scheme من نوع PL/SQL Function Body:
`return noona_apex_pkg.allow('ORG_COMPANY.CREATE') = 'Y';`

### الاستيراد
1. قاعدة البيانات أولاً (من مجلد `db`): `upgrade_01_apex_layer.sql` بحساب NOONA_OWNER ثم
   `security/41_synonyms_noona_app.sql` بحساب NOONA_APP.
2. App Builder ← Import ← ملف `f115_NOONA_MASTER.zip` ← Install: Reuse Application ID 115،
   Parsing Schema `NOONA_APP`.
3. مستخدمو الدخول: Administration ← Manage Users ← أنشئ حسابات APEX بنفس أسماء `SEC_USER`
   (مثل `ADMIN` لمسؤول المؤسسة التجريبية و `PLATFORM` لمسؤول المنصة).

## NOONA_PORTAL (التطبيق 119)

نفس أمان `NOONA_MASTER` (المصادقة والكوكي المشترك و Initialization/Cleanup وقواعد الصلاحيات و LOVs وتحقق شاشة الدخول)، إضافة إلى:

| الصفحة | Alias | المحتوى |
|---|---|---|
| 1 | `HOME` | سياق العمل (المستخدم، المؤسسة، الشركة، عدد المهام والإشعارات)، تطبيقاتي (روابط للتطبيقات المنشأة، والباقي "قيد الإنشاء")، مهامي، الإشعارات + تعليم الكل كمقروء |
| 2 | `TASK` | تفاصيل المهمة (`P2_TASK_ID`)، الملاحظات، أزرار: اعتماد، رفض، إرجاع، طلب معلومات، رجوع؛ وسجل المسار |
| 3 | `COMPANY` | تبديل الشركة الحالية |

مصادر البيانات: `NOONA_V_MY_TASKS`، `NOONA_V_TASK_HISTORY`، `NOONA_V_MY_NOTIFICATIONS`، `NOONA_V_APPS`، والحزمة `NOONA_PORTAL_PKG`.
روابط الإشعارات: `f?p=NOONA_PORTAL:TASK:::NO::P2_TASK_ID:<id>`.

### الاستيراد
1. قاعدة البيانات (من مجلد `db`): `upgrade_02_portal.sql` بحساب NOONA_OWNER ثم `security/41_synonyms_noona_app.sql` بحساب NOONA_APP
   ثم الاختبار `tests/test_portal.sql` بحساب NOONA_APP (16 حالة).
2. App Builder ← Import ← `NOONA_PORTAL/f119_NOONA_PORTAL.zip` ← Reuse Application ID 119، Parsing Schema `NOONA_APP`.

## الاختبار على APEX فعلي

كل تطبيق يُستورد ويُجرب قبل التسليم على APEX 24.2 + ORDS في بيئة التطوير:
استيراد التطبيقين بدون أخطاء، ثم `tools/ui_tests/portal_test.js` (Playwright): رفض حساب غير مسجل برسالة عربية،
دخول ADMIN، ظهور المناطق الأربع، فتح مهمة، منع الرفض بلا سبب، الاعتماد ورسالة النجاح ونقص المهام، صفحة تبديل الشركة.

معالجة الأخطاء: كل التطبيقات تستخدم `noona_owner.noona_apex_error` (ترقية `db/upgrade_03_apex_error.sql`) فتظهر
رسالة NOONA فقط بدون `ORA-20500` ورمز المتابعة.
