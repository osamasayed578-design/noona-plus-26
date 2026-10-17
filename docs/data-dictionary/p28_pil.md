# قاموس البيانات — الحزمة 28: الإطلاق التجريبي

**Pilot Launch** · الحزمة البرمجية المالكة `NOONA_PILOT_PKG` · ملف DDL `db/ddl/p28_pil.sql` · [ERD](../erd/p28_pil.md)

إدارة الإطلاق التجريبي لعميل مؤسس: النطاق والمستخدمون ومعايير النجاح والملاحظات والقياس وقرار الانتقال إلى الإنتاج ومصير البيانات.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`PIL_PILOT`](#pil_pilot) | المشروعات التجريبية | Pilots | T | INTERNAL |
| [`PIL_SUCCESS_CRITERION`](#pil_success_criterion) | معايير النجاح | Success Criteria | T | INTERNAL |
| [`PIL_FEEDBACK`](#pil_feedback) | ملاحظات المستخدمين | Pilot Feedback | T | INTERNAL |
| [`PIL_USAGE_METRIC`](#pil_usage_metric) | مقاييس الاستخدام التجريبي | Pilot Usage Metrics | T | INTERNAL |

## PIL_PILOT

| البند | القيمة |
|---|---|
| الاسم العربي | المشروعات التجريبية |
| English | Pilots |
| الحزمة المالكة | 28 — `NOONA_PILOT_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `TRIAL_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TRIAL |  | إدخال المستخدم |  | التجربة المرتبطة |
| 7 | `SCOPE_MODULES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوحدات المشمولة |
| 8 | `USER_LIMIT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدد المستخدمين |
| 9 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 10 | `END_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 11 | `SPONSOR_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | راعي العميل |
| 12 | `DATA_FATE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | KEEP, EXPORT_AND_ARCHIVE, PURGE_AFTER_RETENTION | إدخال المستخدم |  | مصير البيانات |
| 13 | `GO_LIVE_DECISION` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | GO, NO_GO, EXTEND | إدخال المستخدم |  | قرار الانتقال للإنتاج |
| 14 | `DECISION_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ القرار |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, ACTIVE, EXTENDED, SUCCEEDED, FAILED, CONVERTED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PIL_SUCCESS_CRITERION

| البند | القيمة |
|---|---|
| الاسم العربي | معايير النجاح |
| English | Success Criteria |
| الحزمة المالكة | 28 — `NOONA_PILOT_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PILOT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PIL_PILOT |  | إدخال المستخدم |  | التجربة |
| 4 | `CRITERION_TEXT` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المعيار |
| 5 | `TARGET_VALUE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المستهدف |
| 6 | `ACTUAL_VALUE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الفعلي |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, MET, NOT_MET, WAIVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PIL_FEEDBACK

| البند | القيمة |
|---|---|
| الاسم العربي | ملاحظات المستخدمين |
| English | Pilot Feedback |
| الحزمة المالكة | 28 — `NOONA_PILOT_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PILOT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PIL_PILOT |  | إدخال المستخدم |  | التجربة |
| 4 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 5 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوحدة |
| 6 | `FEEDBACK_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BUG, USABILITY, FEATURE_REQUEST, PERFORMANCE, PRAISE | إدخال المستخدم |  | النوع |
| 7 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 8 | `DEFECT_ID` | معرف | `NUMBER(19)` |  |  | FK→QA_DEFECT |  | إدخال المستخدم |  | العيب المرتبط |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NEW' |  | NEW, ACCEPTED, PLANNED, DONE, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PIL_USAGE_METRIC

| البند | القيمة |
|---|---|
| الاسم العربي | مقاييس الاستخدام التجريبي |
| English | Pilot Usage Metrics |
| الحزمة المالكة | 28 — `NOONA_PILOT_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PILOT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PIL_PILOT |  | إدخال المستخدم |  | التجربة |
| 4 | `METRIC_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | اليوم |
| 5 | `METRIC_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المقياس (مستخدمون نشطون، معاملات، أخطاء...) |
| 6 | `METRIC_VALUE` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | القيمة |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

