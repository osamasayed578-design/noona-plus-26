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
