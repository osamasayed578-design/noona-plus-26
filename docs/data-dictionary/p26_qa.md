# قاموس البيانات — الحزمة 26: الاختبار الشامل وضمان الجودة

**Quality Assurance & Traceability** · الحزمة البرمجية المالكة `NOONA_QA_PKG` · ملف DDL `db/ddl/p26_qa.sql` · [ERD](../erd/p26_qa.md)

سجل المتطلبات وقواعد الأعمال (FR/NFR/BR) وربطها بحالات الاختبار وتشغيلاتها والعيوب، لتحقيق Traceability من المتطلب إلى الاختبار إلى الإصدار.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`QA_REQUIREMENT`](#qa_requirement) | سجل المتطلبات | Requirements Register | G | INTERNAL |
| [`QA_TEST_SUITE`](#qa_test_suite) | مجموعات الاختبار | Test Suites | G | INTERNAL |
| [`QA_TEST_CASE`](#qa_test_case) | حالات الاختبار | Test Cases | G | INTERNAL |
| [`QA_TRACE_LINK`](#qa_trace_link) | روابط التتبع | Traceability Links | G | INTERNAL |
| [`QA_TEST_RUN`](#qa_test_run) | تشغيلات الاختبار | Test Runs | G | INTERNAL |
| [`QA_TEST_RESULT`](#qa_test_result) | نتائج الاختبار | Test Results | G | INTERNAL |
| [`QA_DEFECT`](#qa_defect) | العيوب | Defects | G | INTERNAL |

## QA_REQUIREMENT

| البند | القيمة |
|---|---|
| الاسم العربي | سجل المتطلبات |
| English | Requirements Register |
| الحزمة المالكة | 26 — `NOONA_QA_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | FR-001..015، NFR-001..010، BR-001..012 ومخرجات المراحل |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `REQ_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FUNCTIONAL, NON_FUNCTIONAL, BUSINESS_RULE, DECISION, RISK | إدخال المستخدم |  | النوع (FR/NFR/BR/Decision/Risk) |
| 4 | `TITLE_AR` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 5 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 6 | `PRIORITY_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | CRITICAL, HIGH, MEDIUM, LOW | إدخال المستخدم |  | الأولوية |
| 7 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحزمة |
| 8 | `SOURCE_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع في الوثيقة (القسم) |
| 9 | `OWNER_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المالك |
| 10 | `ACCEPTANCE_CRITERIA` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | معيار القبول |
| 11 | `RELEASE_TARGET` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | الإصدار المستهدف |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PROPOSED' |  | PROPOSED, APPROVED, IMPLEMENTED, VERIFIED, DEFERRED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## QA_TEST_SUITE

| البند | القيمة |
|---|---|
| الاسم العربي | مجموعات الاختبار |
| English | Test Suites |
| الحزمة المالكة | 26 — `NOONA_QA_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحزمة |
| 6 | `TEST_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | UNIT, MODULE, INTEGRATION, ACCOUNTING, WORKFLOW, SECURITY, PERFORMANCE, UAT, REGRESSION | إدخال المستخدم |  | المستوى |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## QA_TEST_CASE

| البند | القيمة |
|---|---|
| الاسم العربي | حالات الاختبار |
| English | Test Cases |
| الحزمة المالكة | 26 — `NOONA_QA_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `SUITE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→QA_TEST_SUITE |  | إدخال المستخدم |  | المجموعة |
| 4 | `TITLE_AR` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 5 | `PRECONDITIONS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المتطلبات المسبقة |
| 6 | `STEPS` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | الخطوات |
| 7 | `EXPECTED_RESULT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النتيجة المتوقعة |
| 8 | `TEST_DATA_REF` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | بيانات الاختبار |
| 9 | `IS_AUTOMATED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مؤتمت (utPLSQL/Playwright) |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, READY, OBSOLETE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## QA_TRACE_LINK

| البند | القيمة |
|---|---|
| الاسم العربي | روابط التتبع |
| English | Traceability Links |
| الحزمة المالكة | 26 — `NOONA_QA_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (REQUIREMENT_ID, TEST_CASE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `REQUIREMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→QA_REQUIREMENT UK1 |  | إدخال المستخدم |  | المتطلب |
| 3 | `TEST_CASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→QA_TEST_CASE UK1 |  | إدخال المستخدم |  | الحالة |
| 4 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 5 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 6 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 7 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 8 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## QA_TEST_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | تشغيلات الاختبار |
| English | Test Runs |
| الحزمة المالكة | 26 — `NOONA_QA_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `RUN_NAME` | نص | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم |
| 3 | `ENVIRONMENT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DEV, TEST, UAT, PREPROD | إدخال المستخدم |  | البيئة |
| 4 | `RELEASE_VERSION` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الإصدار المختبر |
| 5 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 6 | `FINISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, RUNNING, COMPLETED, ABORTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## QA_TEST_RESULT

| البند | القيمة |
|---|---|
| الاسم العربي | نتائج الاختبار |
| English | Test Results |
| الحزمة المالكة | 26 — `NOONA_QA_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `RUN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→QA_TEST_RUN |  | إدخال المستخدم |  | التشغيل |
| 3 | `TEST_CASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→QA_TEST_CASE |  | إدخال المستخدم |  | الحالة |
| 4 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PASS, FAIL, BLOCKED, SKIPPED | إدخال المستخدم |  | النتيجة |
| 5 | `ACTUAL_RESULT` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النتيجة الفعلية |
| 6 | `EVIDENCE_REF` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الدليل |
| 7 | `EXECUTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المنفذ |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## QA_DEFECT

| البند | القيمة |
|---|---|
| الاسم العربي | العيوب |
| English | Defects |
| الحزمة المالكة | 26 — `NOONA_QA_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا انتقال للإنتاج مع ثغرة حرجة/عالية مفتوحة دون استثناء موثق |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `TITLE` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 4 | `SEVERITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CRITICAL, HIGH, MEDIUM, LOW | إدخال المستخدم |  | الخطورة |
| 5 | `TEST_RESULT_ID` | معرف | `NUMBER(19)` |  |  | FK→QA_TEST_RESULT |  | إدخال المستخدم |  | النتيجة المكتشف فيها |
| 6 | `REQUIREMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→QA_REQUIREMENT |  | إدخال المستخدم |  | المتطلب |
| 7 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحزمة |
| 8 | `FIX_VERSION` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | إصدار الإصلاح |
| 9 | `ACCEPTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | قبول مالك العملية |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NEW' |  | NEW, TRIAGED, IN_PROGRESS, FIXED, RETEST, VERIFIED, CLOSED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

