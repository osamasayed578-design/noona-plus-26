# قاموس البيانات — الحزمة 27: ترحيل البيانات

**Data Migration** · الحزمة البرمجية المالكة `NOONA_MIGRATION_PKG` · ملف DDL `db/ddl/p27_mig.sql` · [ERD](../erd/p27_mig.md)

تحميل بيانات العملاء من الأنظمة السابقة عبر Staging بحمولة JSON، وتعيين الحقول، والتحقق والمعاينة وتقرير الأخطاء قبل الاعتماد، ثم المطابقة (عدد السجلات والأرصدة) مع إمكانية الإلغاء.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`MIG_PROJECT`](#mig_project) | مشروعات الترحيل | Migration Projects | T | INTERNAL |
| [`MIG_MAPPING`](#mig_mapping) | تعيين الحقول | Field Mappings | T | INTERNAL |
| [`MIG_BATCH`](#mig_batch) | دفعات الترحيل | Migration Batches | T | INTERNAL |
| [`MIG_STAGING_ROW`](#mig_staging_row) | سجلات التجهيز | Staging Rows | T | INTERNAL |
| [`MIG_ERROR`](#mig_error) | أخطاء الترحيل | Migration Errors | T | INTERNAL |
| [`MIG_RECONCILIATION`](#mig_reconciliation) | مطابقة الترحيل | Migration Reconciliation | T | INTERNAL |

## MIG_PROJECT

| البند | القيمة |
|---|---|
| الاسم العربي | مشروعات الترحيل |
| English | Migration Projects |
| الحزمة المالكة | 27 — `NOONA_MIGRATION_PKG` |
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
| 6 | `SOURCE_SYSTEM` | نص | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النظام المصدر |
| 7 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة الهدف |
| 8 | `CUTOVER_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التحويل |
| 9 | `OWNER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المسؤول |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, IN_PROGRESS, VALIDATED, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MIG_MAPPING

| البند | القيمة |
|---|---|
| الاسم العربي | تعيين الحقول |
| English | Field Mappings |
| الحزمة المالكة | 27 — `NOONA_MIGRATION_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PROJECT_ID, TARGET_ENTITY, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MIG_PROJECT UK2 |  | إدخال المستخدم |  | المشروع |
| 4 | `TARGET_ENTITY` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | FK→REF_ENTITY_TYPE UK2 |  | إدخال المستخدم |  | الكيان الهدف |
| 5 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK2 |  | إدخال المستخدم |  | الإصدار |
| 6 | `MAPPING_RULES` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | قواعد التعيين والتحويل والقيم المرجعية |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MIG_BATCH

| البند | القيمة |
|---|---|
| الاسم العربي | دفعات الترحيل |
| English | Migration Batches |
| الحزمة المالكة | 27 — `NOONA_MIGRATION_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MIG_PROJECT |  | إدخال المستخدم |  | المشروع |
| 4 | `MAPPING_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MIG_MAPPING |  | إدخال المستخدم |  | التعيين |
| 5 | `TARGET_ENTITY` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | الكيان |
| 6 | `SOURCE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الملف المصدر (Excel/CSV) |
| 7 | `IS_DRY_RUN` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | تشغيل تجريبي |
| 8 | `TOTAL_ROWS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الإجمالي |
| 9 | `VALID_ROWS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الصالحة |
| 10 | `ERROR_ROWS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الأخطاء |
| 11 | `LOADED_ROWS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | المحملة |
| 12 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'UPLOADED' |  | UPLOADED, STAGED, VALIDATING, VALIDATED, LOADING, LOADED, RECONCILED, ROLLED_BACK, FAILED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MIG_STAGING_ROW

| البند | القيمة |
|---|---|
| الاسم العربي | سجلات التجهيز |
| English | Staging Rows |
| الحزمة المالكة | 27 — `NOONA_MIGRATION_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (BATCH_ID, ROW_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `BATCH_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MIG_BATCH UK2 |  | إدخال المستخدم |  | الدفعة |
| 4 | `ROW_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم السطر |
| 5 | `SOURCE_KEY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مفتاح المصدر |
| 6 | `PAYLOAD` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | البيانات الأصلية |
| 7 | `TRANSFORMED` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | بعد التحويل |
| 8 | `TARGET_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | المعرف الناتج |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NEW' |  | NEW, VALID, INVALID, LOADED, SKIPPED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MIG_ERROR

| البند | القيمة |
|---|---|
| الاسم العربي | أخطاء الترحيل |
| English | Migration Errors |
| الحزمة المالكة | 27 — `NOONA_MIGRATION_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `STAGING_ROW_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MIG_STAGING_ROW |  | إدخال المستخدم |  | السطر |
| 4 | `FIELD_NAME` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحقل |
| 5 | `ERROR_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرمز |
| 6 | `MESSAGE_AR` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرسالة |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## MIG_RECONCILIATION

| البند | القيمة |
|---|---|
| الاسم العربي | مطابقة الترحيل |
| English | Migration Reconciliation |
| الحزمة المالكة | 27 — `NOONA_MIGRATION_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `BATCH_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MIG_BATCH |  | إدخال المستخدم |  | الدفعة |
| 4 | `CHECK_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الفحص (عدد، أرصدة، مجاميع) |
| 5 | `SOURCE_VALUE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | قيمة المصدر |
| 6 | `TARGET_VALUE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | قيمة الهدف |
| 7 | `DIFFERENCE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الفرق |
| 8 | `EXPLANATION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | التفسير |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MATCHED' |  | MATCHED, DIFFERENCES, ACCEPTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

