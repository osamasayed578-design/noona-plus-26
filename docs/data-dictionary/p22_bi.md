# قاموس البيانات — الحزمة 22: التقارير وذكاء الأعمال

**Reporting & Business Intelligence** · الحزمة البرمجية المالكة `NOONA_BI_PKG` · ملف DDL `db/ddl/p22_bi.sql` · [ERD](../erd/p22_bi.md)

طبقة تعريف المقاييس KPIs بإصدارات، وكتالوج التقارير ولوحات المعلومات، وسجل التصدير، وجدولة التقارير، ومتابعة تحديث الملخصات؛ مع تطبيق Tenant و Data Scope على المصدر والتصدير.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`BI_KPI`](#bi_kpi) | تعريفات المؤشرات | KPI Definitions | TO | INTERNAL |
| [`BI_KPI_VALUE`](#bi_kpi_value) | قيم المؤشرات | KPI Snapshots | T | INTERNAL |
| [`BI_REPORT`](#bi_report) | كتالوج التقارير | Report Catalog | TO | INTERNAL |
| [`BI_DASHBOARD`](#bi_dashboard) | لوحات المعلومات | Dashboards | TO | INTERNAL |
| [`BI_DASHBOARD_WIDGET`](#bi_dashboard_widget) | عناصر اللوحات | Dashboard Widgets | TO | INTERNAL |
| [`BI_REPORT_SCHEDULE`](#bi_report_schedule) | جدولة التقارير | Report Schedules | T | INTERNAL |
| [`BI_EXPORT_LOG`](#bi_export_log) | سجل التصدير | Export Log | T | INTERNAL |
| [`BI_REFRESH_LOG`](#bi_refresh_log) | سجل تحديث الملخصات | Summary Refresh Log | G | INTERNAL |

## BI_KPI

| البند | القيمة |
|---|---|
| الاسم العربي | تعريفات المؤشرات |
| English | KPI Definitions |
| الحزمة المالكة | 22 — `NOONA_BI_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تعريفات مختلفة لنفس «صافي المبيعات» دون تسمية وفارق موثقين |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 7 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحزمة |
| 8 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 9 | `OWNER_ROLE_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_ROLE |  | إدخال المستخدم |  | المالك |
| 10 | `FORMULA_TEXT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الصيغة الموثقة |
| 11 | `SOURCE_OBJECT` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المصدر (View/MV) |
| 12 | `UNIT_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | وحدة القياس |
| 13 | `PERIOD_SEMANTICS` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | معنى الفترة وتاريخ القطع |
| 14 | `CURRENCY_RULE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | قاعدة العملة |
| 15 | `REFRESH_FREQUENCY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | REALTIME, HOURLY, DAILY, WEEKLY, MONTHLY | إدخال المستخدم |  | التحديث |
| 16 | `DRILL_TARGET` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | وجهة Drill Down |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## BI_KPI_VALUE

| البند | القيمة |
|---|---|
| الاسم العربي | قيم المؤشرات |
| English | KPI Snapshots |
| الحزمة المالكة | 22 — `NOONA_BI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `KPI_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→BI_KPI |  | إدخال المستخدم |  | المؤشر |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `PERIOD_CODE` | نص | `VARCHAR2(20 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الفترة |
| 7 | `AS_OF_TS` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ القطع |
| 8 | `VALUE_NUMBER` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | القيمة |
| 9 | `TARGET_NUMBER` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | المستهدف |
| 10 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## BI_REPORT

| البند | القيمة |
|---|---|
| الاسم العربي | كتالوج التقارير |
| English | Report Catalog |
| الحزمة المالكة | 22 — `NOONA_BI_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 7 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحزمة |
| 8 | `REPORT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | OPERATIONAL, FINANCIAL, MANAGEMENT, REGULATORY, ANALYTICAL | إدخال المستخدم |  | النوع |
| 9 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 10 | `PERMISSION_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_PERMISSION |  | إدخال المستخدم |  | الصلاحية المطلوبة |
| 11 | `APEX_PAGE_ID` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | صفحة APEX |
| 12 | `OUTPUT_FORMATS` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الصيغ المتاحة |
| 13 | `MANDATORY_FILTERS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الفلاتر الإلزامية للأحجام الكبيرة |
| 14 | `IS_AS_OF_CAPABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يدعم «كما كان» تاريخياً |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## BI_DASHBOARD

| البند | القيمة |
|---|---|
| الاسم العربي | لوحات المعلومات |
| English | Dashboards |
| الحزمة المالكة | 22 — `NOONA_BI_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `AUDIENCE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PLATFORM, TENANT_ADMIN, EXECUTIVE, FINANCE, OPERATIONS, HR, PROJECTS, PROPERTY, PERSONAL | إدخال المستخدم |  | الجمهور |
| 7 | `APEX_PAGE_ID` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | صفحة APEX |
| 8 | `LAYOUT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | التخطيط |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## BI_DASHBOARD_WIDGET

| البند | القيمة |
|---|---|
| الاسم العربي | عناصر اللوحات |
| English | Dashboard Widgets |
| الحزمة المالكة | 22 — `NOONA_BI_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `DASHBOARD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→BI_DASHBOARD |  | إدخال المستخدم |  | اللوحة |
| 4 | `KPI_ID` | معرف | `NUMBER(19)` |  |  | FK→BI_KPI |  | إدخال المستخدم |  | المؤشر |
| 5 | `REPORT_ID` | معرف | `NUMBER(19)` |  |  | FK→BI_REPORT |  | إدخال المستخدم |  | التقرير |
| 6 | `WIDGET_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | KPI_CARD, CHART, TABLE, LIST, MAP, GAUGE | إدخال المستخدم |  | النوع |
| 7 | `CONFIG` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الإعداد |
| 8 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## BI_REPORT_SCHEDULE

| البند | القيمة |
|---|---|
| الاسم العربي | جدولة التقارير |
| English | Report Schedules |
| الحزمة المالكة | 22 — `NOONA_BI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `REPORT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→BI_REPORT |  | إدخال المستخدم |  | التقرير |
| 4 | `OWNER_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المالك (يعمل بصلاحياته) |
| 5 | `CRON_EXPRESSION` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | التوقيت |
| 6 | `PARAMETERS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | المعاملات |
| 7 | `OUTPUT_FORMAT` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PDF' |  | PDF, XLSX, CSV, HTML | إدخال المستخدم |  | الصيغة |
| 8 | `RECIPIENTS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | المستلمون (يعاد فحص صلاحياتهم) |
| 9 | `NEXT_RUN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | التشغيل التالي |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, PAUSED, ENDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## BI_EXPORT_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل التصدير |
| English | Export Log |
| الحزمة المالكة | 22 — `NOONA_BI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `REPORT_ID` | معرف | `NUMBER(19)` |  |  | FK→BI_REPORT |  | إدخال المستخدم |  | التقرير |
| 4 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 5 | `EXPORT_FORMAT` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الصيغة |
| 6 | `ROW_COUNT` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | عدد السجلات |
| 7 | `FILTERS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | المرشحات المستخدمة |
| 8 | `REPORT_VERSION` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | إصدار التعريف |
| 9 | `WATERMARKED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | بعلامة مائية |
| 10 | `FILE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الملف الناتج |
| 11 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | انتهاء رابط التنزيل |
| 12 | `REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب (للبيانات الحساسة) |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## BI_REFRESH_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل تحديث الملخصات |
| English | Summary Refresh Log |
| الحزمة المالكة | 22 — `NOONA_BI_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `OBJECT_NAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الكائن (MV/جدول ملخص) |
| 3 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 4 | `FINISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 5 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SUCCESS, FAILED, PARTIAL | إدخال المستخدم |  | النتيجة |
| 6 | `DATA_CUTOFF_TS` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت قطع البيانات المعروض للمستخدم |
| 7 | `ERROR_MESSAGE` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

