# قاموس البيانات — الحزمة 29: النشر الإنتاجي والإصدارات

**Deployment & Release Management** · الحزمة البرمجية المالكة `NOONA_DEPLOYMENT_PKG` · ملف DDL `db/ddl/p29_dep.sql` · [ERD](../erd/p29_dep.md)

سجل الإصدارات وقنوات النشر Internal → Pilot → Early Access → GA → On-Premises، وسجل ترحيلات المخطط (Migration Scripts مرقمة لا تعدل بعد النشر)، ونشر كل بيئة/خلية وفحوص الصحة وإصدارات مكونات كل Tenant.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`DEP_RELEASE`](#dep_release) | الإصدارات | Releases | G | INTERNAL |
| [`DEP_COMPONENT_VERSION`](#dep_component_version) | إصدارات المكونات | Release Component Versions | G | INTERNAL |
| [`DEP_SCHEMA_MIGRATION`](#dep_schema_migration) | سجل ترحيلات المخطط | Schema Migrations | G | INTERNAL |
| [`DEP_DEPLOYMENT`](#dep_deployment) | عمليات النشر | Deployments | G | INTERNAL |
| [`DEP_HEALTH_CHECK`](#dep_health_check) | فحوص الصحة | Health Checks | G | INTERNAL |
| [`DEP_TENANT_VERSION`](#dep_tenant_version) | إصدارات مكونات المؤسسة | Tenant Component Versions | T | INTERNAL |

## DEP_RELEASE

| البند | القيمة |
|---|---|
| الاسم العربي | الإصدارات |
| English | Releases |
| الحزمة المالكة | 29 — `NOONA_DEPLOYMENT_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (VERSION_LABEL) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `VERSION_LABEL` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم الإصدار (1.0.0) |
| 3 | `RELEASE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MAJOR, MINOR, PATCH, HOTFIX | إدخال المستخدم |  | النوع |
| 4 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | INTERNAL, PILOT, EARLY_ACCESS, GENERAL_AVAILABILITY, ON_PREMISES_PACKAGE, LTS | إدخال المستخدم |  | القناة |
| 5 | `RELEASE_NOTES` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | ملاحظات الإصدار |
| 6 | `PACKAGE_SIGNATURE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | توقيع الحزمة (On-Premises) |
| 7 | `RELEASED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإطلاق |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, BUILT, TESTED, APPROVED, ROLLING_OUT, RELEASED, ROLLED_BACK, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DEP_COMPONENT_VERSION

| البند | القيمة |
|---|---|
| الاسم العربي | إصدارات المكونات |
| English | Release Component Versions |
| الحزمة المالكة | 29 — `NOONA_DEPLOYMENT_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (RELEASE_ID, COMPONENT_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `RELEASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DEP_RELEASE UK1 |  | إدخال المستخدم |  | الإصدار |
| 3 | `COMPONENT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | DB_SCHEMA, PLSQL, APEX_APP, ORDS, API, COUNTRY_PACK, AI_RAG, DOC_STORAGE | إدخال المستخدم |  | المكون |
| 4 | `COMPONENT_VERSION` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الإصدار |
| 5 | `MIN_COMPATIBLE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | أدنى إصدار متوافق |
| 6 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 9 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 10 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DEP_SCHEMA_MIGRATION

| البند | القيمة |
|---|---|
| الاسم العربي | سجل ترحيلات المخطط |
| English | Schema Migrations |
| الحزمة المالكة | 29 — `NOONA_DEPLOYMENT_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الغرض | يسجل كل ملف DDL/Migration ينفذ على البيئة |
| مفاتيح فريدة | UK1: (SCRIPT_NAME) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `SCRIPT_NAME` | نص | `VARCHAR2(200 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | اسم السكربت المرقم |
| 3 | `SCRIPT_VERSION` | نص | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الإصدار |
| 4 | `CHECKSUM` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | Hash المحتوى (لا يعدل بعد النشر) |
| 5 | `RELEASE_ID` | معرف | `NUMBER(19)` |  |  | FK→DEP_RELEASE |  | إدخال المستخدم |  | الإصدار |
| 6 | `EXECUTION_MS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة التنفيذ |
| 7 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SUCCESS, FAILED, ROLLED_BACK, FORWARD_FIXED | إدخال المستخدم |  | النتيجة |
| 8 | `ERROR_MESSAGE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 9 | `ROLLBACK_SCRIPT` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | سكربت الرجوع |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## DEP_DEPLOYMENT

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات النشر |
| English | Deployments |
| الحزمة المالكة | 29 — `NOONA_DEPLOYMENT_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `RELEASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DEP_RELEASE |  | إدخال المستخدم |  | الإصدار |
| 3 | `CELL_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_CELL |  | إدخال المستخدم |  | الخلية |
| 4 | `ENVIRONMENT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DEV, TEST, UAT, PREPROD, PROD, DR | إدخال المستخدم |  | البيئة |
| 5 | `ROLLOUT_WAVE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | INTERNAL, PILOT, LIMITED, GENERAL | إدخال المستخدم |  | الموجة |
| 6 | `WINDOW_START` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | بداية النافذة |
| 7 | `WINDOW_END` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | نهايتها |
| 8 | `OWNER_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المسؤول |
| 9 | `ROLLBACK_PLAN` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | خطة التراجع |
| 10 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 11 | `FINISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SCHEDULED' |  | SCHEDULED, IN_PROGRESS, HEALTH_CHECK, SUCCEEDED, FAILED, ROLLED_BACK | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DEP_HEALTH_CHECK

| البند | القيمة |
|---|---|
| الاسم العربي | فحوص الصحة |
| English | Health Checks |
| الحزمة المالكة | 29 — `NOONA_DEPLOYMENT_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `DEPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DEP_DEPLOYMENT |  | إدخال المستخدم |  | النشر |
| 3 | `CHECK_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الفحص |
| 4 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PASS, FAIL, WARN | إدخال المستخدم |  | النتيجة |
| 5 | `DETAILS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | التفاصيل |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## DEP_TENANT_VERSION

| البند | القيمة |
|---|---|
| الاسم العربي | إصدارات مكونات المؤسسة |
| English | Tenant Component Versions |
| الحزمة المالكة | 29 — `NOONA_DEPLOYMENT_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تشغل تركيبة غير مدعومة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPONENT_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPONENT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | DB_SCHEMA, PLSQL, APEX_APP, ORDS, API, COUNTRY_PACK, AI_RAG, DOC_STORAGE | إدخال المستخدم |  | المكون |
| 4 | `COMPONENT_VERSION` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الإصدار الحالي |
| 5 | `RELEASE_ID` | معرف | `NUMBER(19)` |  |  | FK→DEP_RELEASE |  | إدخال المستخدم |  | الإصدار |
| 6 | `UPGRADED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | تاريخ الترقية |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

