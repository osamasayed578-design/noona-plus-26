# قاموس البيانات — الحزمة 04: إدارة المستندات والأرشفة

**Document Management & Archive** · الحزمة البرمجية المالكة `NOONA_DMS_PKG` · ملف DDL `db/ddl/p04_dms.sql` · [ERD](../erd/p04_dms.md)

محرك DMS مركزي (BR-004): المستند سجل عمل وهوية ثابتة، والإصدارات 1..n غير قابلة للمحو، والمحتوى الثنائي في SecureFiles أو Object Storage، والربط بكيانات ERP عبر Document Link منضبط بسجل الأنواع، مع ACL والسرية والاحتفاظ والحجز القانوني والتوقيع.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`DMS_CATEGORY`](#dms_category) | فئات المستندات | Document Categories | TO | INTERNAL |
| [`DMS_RETENTION_POLICY`](#dms_retention_policy) | سياسات الاحتفاظ | Retention Policies | TO | INTERNAL |
| [`DMS_DOCUMENT_TYPE`](#dms_document_type) | أنواع المستندات وسياساتها | Document Types & Policies | TO | INTERNAL |
| [`DMS_METADATA_FIELD`](#dms_metadata_field) | حقول البيانات الوصفية | Metadata Field Definitions | TO | INTERNAL |
| [`DMS_TAG`](#dms_tag) | الوسوم | Tags | T | INTERNAL |
| [`DMS_ARCHIVE_RULE`](#dms_archive_rule) | قواعد الأرشفة | Archiving Rules | C | INTERNAL |
| [`DMS_REQUIRED_DOCUMENT`](#dms_required_document) | المستندات المطلوبة للأطراف | Required Party Documents | C | INTERNAL |
| [`DMS_STORAGE_AGENT`](#dms_storage_agent) | وكلاء التخزين المحلي | Local Storage Agents | C | INTERNAL |
| [`DMS_AGENT_JOB`](#dms_agent_job) | مهام وكيل التخزين | Storage Agent Jobs | T | INTERNAL |
| [`DMS_STORAGE_PROFILE`](#dms_storage_profile) | إعدادات تخزين الملفات | File Storage Profiles | C | INTERNAL |
| [`DMS_DOCUMENT`](#dms_document) | المستندات | Documents | T | CONFIDENTIAL |
| [`DMS_FILE_CONTENT`](#dms_file_content) | محتوى الملفات | File Content | T | CONFIDENTIAL |
| [`DMS_DOCUMENT_VERSION`](#dms_document_version) | إصدارات المستندات | Document Versions | T | INTERNAL |
| [`DMS_METADATA_VALUE`](#dms_metadata_value) | قيم البيانات الوصفية | Document Metadata Values | T | INTERNAL |
| [`DMS_METADATA_REVISION`](#dms_metadata_revision) | سجل تعديل البيانات الوصفية | Metadata Revisions | T | INTERNAL |
| [`DMS_DOCUMENT_TAG`](#dms_document_tag) | وسوم المستند | Document Tags | T | INTERNAL |
| [`DMS_DOCUMENT_LINK`](#dms_document_link) | روابط المستندات بكيانات ERP | Document Links | T | INTERNAL |
| [`DMS_ACL`](#dms_acl) | قوائم التحكم في الوصول | Document ACL | T | INTERNAL |
| [`DMS_SHARE`](#dms_share) | مشاركات المستندات | Document Shares | T | INTERNAL |
| [`DMS_COMMENT`](#dms_comment) | تعليقات المستندات | Document Comments | T | INTERNAL |
| [`DMS_OCR_TEXT`](#dms_ocr_text) | النص المستخرج OCR | Extracted Text (OCR) | T | INTERNAL |
| [`DMS_TEMPLATE`](#dms_template) | قوالب توليد المستندات | Document Templates | TO | INTERNAL |
| [`DMS_UPLOAD_SESSION`](#dms_upload_session) | جلسات الرفع | Upload Sessions | T | INTERNAL |
| [`DMS_SIGNATURE_REQUEST`](#dms_signature_request) | طلبات التوقيع | Signature Requests | T | INTERNAL |
| [`DMS_SIGNATURE`](#dms_signature) | التوقيعات | Signatures | T | INTERNAL |
| [`DMS_LEGAL_HOLD`](#dms_legal_hold) | الحجوزات القانونية | Legal Holds | T | INTERNAL |
| [`DMS_LEGAL_HOLD_ITEM`](#dms_legal_hold_item) | عناصر الحجز القانوني | Legal Hold Items | T | INTERNAL |
| [`DMS_DISPOSAL_BATCH`](#dms_disposal_batch) | دفعات الإتلاف | Disposal Batches | T | INTERNAL |
| [`DMS_DISPOSAL_ITEM`](#dms_disposal_item) | عناصر الإتلاف | Disposal Items | T | INTERNAL |
| [`DMS_ACCESS_LOG`](#dms_access_log) | سجل الوصول للمستندات | Document Access Log | T | INTERNAL |
| [`DMS_STORAGE_USAGE`](#dms_storage_usage) | استهلاك التخزين | Storage Usage | T | INTERNAL |

## DMS_CATEGORY

| البند | القيمة |
|---|---|
| الاسم العربي | فئات المستندات |
| English | Document Categories |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
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
| 6 | `PARENT_CATEGORY_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_CATEGORY |  | إدخال المستخدم |  | الفئة الأم |
| 7 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 8 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_RETENTION_POLICY

| البند | القيمة |
|---|---|
| الاسم العربي | سياسات الاحتفاظ |
| English | Retention Policies |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة (Country Pack) |
| 7 | `TRIGGER_EVENT` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CREATION, TRANSACTION_CLOSE, CONTRACT_END, EMPLOYMENT_END, PROJECT_CLOSE, FISCAL_YEAR_END | إدخال المستخدم |  | الحدث المرجعي |
| 8 | `RETENTION_MONTHS` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | مدة الاحتفاظ بالأشهر |
| 9 | `END_ACTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REVIEW' |  | REVIEW, ARCHIVE, DISPOSE, TRANSFER | إدخال المستخدم |  | الإجراء عند الانتهاء |
| 10 | `LEGAL_REFERENCE` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع القانوني |
| 11 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | الإصدار |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 14 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_DOCUMENT_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع المستندات وسياساتها |
| English | Document Types & Policies |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
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
| 6 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 7 | `CATEGORY_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_CATEGORY |  | إدخال المستخدم |  | الفئة |
| 8 | `DEFAULT_CONFIDENTIALITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | السرية الافتراضية |
| 9 | `ALLOWED_MIME_TYPES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | أنواع الملفات المسموحة |
| 10 | `MAX_FILE_MB` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | أقصى حجم بالميجابايت |
| 11 | `NAMING_RULE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | قاعدة التسمية |
| 12 | `RETENTION_POLICY_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_RETENTION_POLICY |  | إدخال المستخدم |  | سياسة الاحتفاظ |
| 13 | `REQUIRES_REVIEW` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب مراجعة قبل الاعتماد |
| 14 | `REQUIRES_SIGNATURE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب توقيعاً |
| 15 | `SIGNATURE_LEVEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | INTERNAL_CONFIRM, SIMPLE, ADVANCED_MFA, DIGITAL_CERT, ORG_SEAL | إدخال المستخدم |  | مستوى التوقيع |
| 16 | `ALLOW_OCR` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يسمح بـOCR |
| 17 | `ALLOW_AI_INDEX` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بالفهرسة لـRAG |
| 18 | `ALLOW_EXPORT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يسمح بالتصدير |
| 19 | `REQUIRES_CHECKOUT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب Check-out قبل التعديل |
| 20 | `EXPIRY_ALERT_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | التنبيه قبل الانتهاء |
| 21 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_METADATA_FIELD

| البند | القيمة |
|---|---|
| الاسم العربي | حقول البيانات الوصفية |
| English | Metadata Field Definitions |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (DOCUMENT_TYPE_ID, FIELD_CODE, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `DOCUMENT_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT_TYPE UK1 |  | إدخال المستخدم |  | نوع المستند |
| 6 | `FIELD_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز الحقل |
| 7 | `DATA_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | TEXT, NUMBER, DATE, LOV, PARTY, AMOUNT, BOOLEAN | إدخال المستخدم |  | النوع |
| 8 | `IS_MANDATORY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | إلزامي |
| 9 | `IS_SEARCHABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | قابل للبحث |
| 10 | `LOOKUP_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | القائمة المرجعية |
| 11 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | إصدار التعريف |
| 12 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_TAG

| البند | القيمة |
|---|---|
| الاسم العربي | الوسوم |
| English | Tags |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تخزن بيانات حساسة في الوسوم العامة |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 9 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 10 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_ARCHIVE_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد الأرشفة |
| English | Archiving Rules |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | كل إجراء مستندي له مرجع ورقي: تحدد القاعدة ما يلزم قبل اعتماد المستند |
| مفاتيح فريدة | UK1: (COMPANY_ID, ENTITY_TYPE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | نوع المستند الأصلي (مثل CSH_TRANSACTION، GL_JOURNAL) |
| 5 | `DOCUMENT_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT_TYPE |  | إدخال المستخدم |  | نوع المستند المؤرشف الافتراضي |
| 6 | `IS_REQUIRED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | المرجع الورقي إلزامي قبل الاعتماد |
| 7 | `REQUIRE_FILE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | صورة الأصل (ملف) إلزامية |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_REQUIRED_DOCUMENT

| البند | القيمة |
|---|---|
| الاسم العربي | المستندات المطلوبة للأطراف |
| English | Required Party Documents |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | مستندات وشهادات الموردين والعملاء (السجل التجاري، الضريبة، الزكاة...) وصلاحيتها |
| مفاتيح فريدة | UK1: (COMPANY_ID, ROLE_CODE, DOCUMENT_TYPE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ROLE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | SUPPLIER, CUSTOMER, CONTRACTOR, EMPLOYEE, LESSEE, PARTNER, OTHER | إدخال المستخدم |  | دور الطرف |
| 5 | `DOCUMENT_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT_TYPE UK1 |  | إدخال المستخدم |  | نوع المستند |
| 6 | `IS_MANDATORY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | إلزامي لاعتماد الطرف |
| 7 | `REQUIRES_VALIDITY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | له تاريخ انتهاء يجب أن يكون سارياً |
| 8 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الترتيب |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_STORAGE_AGENT

| البند | القيمة |
|---|---|
| الاسم العربي | وكلاء التخزين المحلي |
| English | Local Storage Agents |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | برنامج صغير يثبت عند الشركة ويحفظ ملفات الأرشيف على أجهزتها؛ يتصل هو بالنظام (لا يفتح منفذ في شبكة الشركة) |
| مفاتيح فريدة | UK2: (COMPANY_ID, NAME) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `NAME` | نص | `VARCHAR2(200 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | اسم الوكيل (الجهاز أو الخادم عند الشركة) |
| 5 | `KEY_HASH` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | بصمة مفتاح الوكيل SHA-256 (المفتاح نفسه لا يحفظ ويعرض مرة واحدة) |
| 6 | `KEY_HINT` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | آخر أحرف المفتاح للتعرف عليه |
| 7 | `HOST_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | اسم الجهاز كما يبلغه الوكيل |
| 8 | `AGENT_VERSION` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | إصدار برنامج الوكيل |
| 9 | `STORAGE_PATH` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | مسار الحفظ على جهاز الشركة كما يبلغه الوكيل |
| 10 | `LAST_SEEN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر اتصال |
| 11 | `FREE_BYTES` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | المساحة الحرة على قرص الوكيل |
| 12 | `STORED_FILES` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | عدد الملفات المحفوظة عنده |
| 13 | `STORED_BYTES` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | حجمها |
| 14 | `LAST_ERROR` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | آخر خطأ أبلغ عنه |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, DISABLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_AGENT_JOB

| البند | القيمة |
|---|---|
| الاسم العربي | مهام وكيل التخزين |
| English | Storage Agent Jobs |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | صف المهام بين النظام والوكيل: الوكيل يسحب مهامه دورياً وينفذها ويبلغ النتيجة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `AGENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_STORAGE_AGENT |  | إدخال المستخدم |  | الوكيل |
| 4 | `CONTENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_FILE_CONTENT |  | إدخال المستخدم |  | الملف |
| 5 | `JOB_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PUT, GET, RETURN, DELETE, TEST | إدخال المستخدم |  | المهمة: حفظ عند الوكيل، جلب للعرض، إعادة للقاعدة نهائياً، حذف، اختبار |
| 6 | `ATTEMPTS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | عدد المحاولات |
| 7 | `SENT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت تسليمها للوكيل |
| 8 | `DONE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت إنجازها |
| 9 | `ERROR_TEXT` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, SENT, DONE, FAILED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_STORAGE_PROFILE

| البند | القيمة |
|---|---|
| الاسم العربي | إعدادات تخزين الملفات |
| English | File Storage Profiles |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | مكان حفظ ملفات الأرشيف لكل شركة: داخل قاعدة البيانات أو مجلد على الخادم/NAS أو تخزين سحابي؛ الملفات السابقة تبقى في مكانها |
| مفاتيح فريدة | UK1: (COMPANY_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `STORAGE_MEDIUM` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DATABASE' |  | DATABASE, SERVER_FOLDER, OBJECT_STORAGE, LOCAL_AGENT | إدخال المستخدم |  | مكان الحفظ |
| 5 | `AGENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_STORAGE_AGENT |  | إدخال المستخدم |  | وكيل التخزين المحلي (عند LOCAL_AGENT) |
| 6 | `DIRECTORY_NAME` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | كائن Oracle DIRECTORY للمجلد (يخصصه مسؤول النظام للمؤسسة: NOONA_DMS_T<رقم المؤسسة>...) |
| 7 | `BASE_PATH` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | المسار الفعلي للمجلد (للعرض والتوثيق) |
| 8 | `FILE_PREFIX` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | بادئة أسماء الملفات |
| 9 | `BUCKET_URL` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | رابط حاوية التخزين السحابي (OCI/S3) |
| 10 | `CREDENTIAL_ID` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف بيانات اعتماد APEX للتخزين السحابي |
| 11 | `LAST_TEST_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر اختبار للاتصال |
| 12 | `LAST_TEST_RESULT` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | نتيجة آخر اختبار |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_DOCUMENT

| البند | القيمة |
|---|---|
| الاسم العربي | المستندات |
| English | Documents |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | المستند سجل عمل بهوية ثابتة؛ الاسم أو المسار لا يمنح حق الوصول (17.1) |
| مفاتيح فريدة | UK2: (PUBLIC_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 6 | `DOCUMENT_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT_TYPE |  | إدخال المستخدم |  | النوع |
| 7 | `REFERENCE_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الأرشيف (يصدر من تسلسل DMS_ARCHIVE ويكتب على الأصل الورقي) |
| 8 | `EXTERNAL_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع الورقي/الخارجي (رقم الفاتورة أو الشيك أو الخطاب) |
| 9 | `PHYSICAL_LOCATION` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | موقع الأصل الورقي (الملف/الرف/الصندوق) |
| 10 | `TITLE` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 11 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 12 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | لغة المستند |
| 13 | `ORIGIN_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'AUTHENTIC' |  | AUTHENTIC, COPY, DERIVED, SYSTEM_GENERATED, EXTERNAL_INBOUND | إدخال المستخدم |  | الأصالة (يقرر مرة واحدة) |
| 14 | `OWNER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المالك |
| 15 | `OWNER_UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_UNIT |  | إدخال المستخدم |  | الوحدة المالكة |
| 16 | `CURRENT_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار الساري (مؤشر صريح) |
| 17 | `DOCUMENT_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ المستند |
| 18 | `VALID_FROM` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | السريان من |
| 19 | `VALID_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 20 | `LEGAL_HOLD` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تحت حجز قانوني |
| 21 | `RETENTION_POLICY_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_RETENTION_POLICY |  | إدخال المستخدم |  | سياسة الاحتفاظ المطبقة |
| 22 | `RETENTION_TRIGGER_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الحدث المرجعي |
| 23 | `RETENTION_END_DATE` | تاريخ | `DATE` |  |  |  |  | محسوب |  | نهاية الاحتفاظ المحسوبة |
| 24 | `CHECKED_OUT_BY_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم الحاجز (Check-out) |
| 25 | `CHECKED_OUT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الحجز |
| 26 | `CHECKOUT_EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | انتهاء الحجز |
| 27 | `SOURCE_TEMPLATE_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_TEMPLATE |  | إدخال المستخدم |  | القالب المولد منه |
| 28 | `IS_DELETED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | حذف منطقي قابل للاستعادة |
| 29 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UPLOADING, QUARANTINED, AVAILABLE, UNDER_REVIEW, APPROVED, ACTIVE, ARCHIVED, DISPOSED, REJECTED, EXPIRED, SUPERSEDED, UPLOAD_FAILED, BLOCKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 30 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 31 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 32 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 33 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 34 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 35 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_FILE_CONTENT

| البند | القيمة |
|---|---|
| الاسم العربي | محتوى الملفات |
| English | File Content |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Dedupe اختياري داخل Tenant فقط ولا يكشف وجود الملف بين Tenants |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `STORAGE_MEDIUM` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SECUREFILE, OBJECT_STORAGE, NAS, S3_COMPATIBLE, AGENT | إدخال المستخدم |  | وسيط التخزين |
| 4 | `AGENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_STORAGE_AGENT |  | إدخال المستخدم |  | الوكيل الحافظ للملف (AGENT) |
| 5 | `CACHE_UNTIL` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | نسخة مؤقتة في القاعدة بعد الجلب من الوكيل حتى هذا الوقت |
| 6 | `STORAGE_KEY` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المفتاح الداخلي في الوسيط (لا يعرض للمستخدم) |
| 7 | `STORAGE_BUCKET_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع الحاوية |
| 8 | `CONTENT_BLOB` | ثنائي | `BLOB` |  |  |  |  | إدخال المستخدم |  | المحتوى عند SecureFiles |
| 9 | `FILE_NAME` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | اسم الملف الأصلي |
| 10 | `FILE_SIZE_BYTES` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | الحجم |
| 11 | `DECLARED_MIME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | النوع المعلن |
| 12 | `DETECTED_MIME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | النوع الفعلي المكتشف |
| 13 | `HASH_ALGORITHM` | نص | `VARCHAR2(20 CHAR)` | ✔ | 'SHA256' |  |  | إدخال المستخدم |  | خوارزمية Hash |
| 14 | `HASH_VALUE` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | قيمة Hash |
| 15 | `SCAN_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, CLEAN, INFECTED, FAILED, SKIPPED | إدخال المستخدم |  | فحص البرمجيات الضارة |
| 16 | `SCANNED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الفحص |
| 17 | `ENCRYPTION_KEY_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع مفتاح التشفير |
| 18 | `LAST_VERIFIED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر تحقق دوري من Hash |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, STORED, VERIFIED, MISSING, CORRUPTED, PURGED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_DOCUMENT_VERSION

| البند | القيمة |
|---|---|
| الاسم العربي | إصدارات المستندات |
| English | Document Versions |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | الاسترجاع ينشئ إصداراً جديداً ولا يعيد كتابة التاريخ (19.4) |
| مفاتيح فريدة | UK2: (DOCUMENT_ID, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT UK2 |  | إدخال المستخدم |  | المستند |
| 4 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الإصدار المتسلسل |
| 5 | `CONTENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_FILE_CONTENT |  | إدخال المستخدم |  | المحتوى |
| 6 | `CHANGE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INITIAL' |  | INITIAL, REVISION, CORRECTION, RESTORE, DERIVED, OCR, REDACTED, SIGNED | إدخال المستخدم |  | نوع التغيير |
| 7 | `CHANGE_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب التغيير |
| 8 | `SOURCE_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار المصدر (الاسترجاع/الاشتقاق) |
| 9 | `UPLOADED_BY_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الرافع |
| 10 | `UPLOADED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الرفع |
| 11 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 12 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | سرية الإصدار إن اختلفت |
| 13 | `IS_SIGNED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | موقع |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING_UPLOAD' |  | PENDING_UPLOAD, QUARANTINED, READY_FOR_REVIEW, CURRENT, SUPERSEDED, REJECTED, UPLOAD_FAILED, WITHDRAWN | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_METADATA_VALUE

| البند | القيمة |
|---|---|
| الاسم العربي | قيم البيانات الوصفية |
| English | Document Metadata Values |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (DOCUMENT_ID, FIELD_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT UK1 |  | إدخال المستخدم |  | المستند |
| 4 | `FIELD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_METADATA_FIELD UK1 |  | إدخال المستخدم |  | الحقل |
| 5 | `VALUE_TEXT` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | القيمة النصية |
| 6 | `VALUE_NUMBER` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | القيمة الرقمية |
| 7 | `VALUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | قيمة التاريخ |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_METADATA_REVISION

| البند | القيمة |
|---|---|
| الاسم العربي | سجل تعديل البيانات الوصفية |
| English | Metadata Revisions |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 4 | `CHANGED_FIELDS` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | الحقول القديمة والجديدة |
| 5 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## DMS_DOCUMENT_TAG

| البند | القيمة |
|---|---|
| الاسم العربي | وسوم المستند |
| English | Document Tags |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (DOCUMENT_ID, TAG_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT UK1 |  | إدخال المستخدم |  | المستند |
| 4 | `TAG_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_TAG UK1 |  | إدخال المستخدم |  | الوسم |
| 5 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 8 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 9 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_DOCUMENT_LINK

| البند | القيمة |
|---|---|
| الاسم العربي | روابط المستندات بكيانات ERP |
| English | Document Links |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Document Link كيان مستقل؛ لا ON DELETE CASCADE على الأدلة (18.2-18.3) |
| مفاتيح فريدة | UK1: (TENANT_ID, DOCUMENT_ID, ENTITY_TYPE, ENTITY_ID, LINK_ROLE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT UK1 |  | إدخال المستخدم |  | المستند |
| 4 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | FK→REF_ENTITY_TYPE UK1 |  | إدخال المستخدم |  | نوع الكيان (من السجل فقط) |
| 5 | `ENTITY_ID` | معرف | `NUMBER(19)` | ✔ |  | UK1 |  | إدخال المستخدم |  | معرف الكيان (يتحقق خادمياً) |
| 6 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | شركة الكيان |
| 7 | `LINK_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الغرض (أصل فاتورة، إثبات تسليم، عقد، سند دفع، امتثال...) |
| 8 | `PINNED_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار المثبت للأدلة المعتمدة |
| 9 | `PINNED_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash المثبت |
| 10 | `ADDED_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MANUAL' |  | MANUAL, SYSTEM, INTEGRATION, EMAIL, SCAN | إدخال المستخدم |  | طريقة الإضافة |
| 11 | `DETACHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الفصل |
| 12 | `DETACH_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الفصل |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, DETACHED, TOMBSTONED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_ACL

| البند | القيمة |
|---|---|
| الاسم العربي | قوائم التحكم في الوصول |
| English | Document ACL |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | ACL لا تتجاوز السرية الإلزامية أو عزل Tenant |
| مفاتيح فريدة | UK1: (DOCUMENT_ID, PRINCIPAL_TYPE, PRINCIPAL_ID, PERMISSION_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT UK1 |  | إدخال المستخدم |  | المستند |
| 4 | `PRINCIPAL_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | USER, ROLE, POSITION, ORG_UNIT, COMMITTEE, GROUP | إدخال المستخدم |  | نوع الجهة |
| 5 | `PRINCIPAL_ID` | معرف | `NUMBER(19)` | ✔ |  | UK1 |  | إدخال المستخدم |  | معرف الجهة |
| 6 | `PERMISSION_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | LIST, VIEW_METADATA, PREVIEW, READ, DOWNLOAD, PRINT, EXPORT, UPLOAD, REPLACE_VERSION, CLASSIFY, SHARE, FORWARD, APPROVE, ARCHIVE, RESTORE, DISPOSE, MANAGE_HOLD, RECLASSIFY | إدخال المستخدم |  | الصلاحية |
| 7 | `EFFECT` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ALLOW' |  | ALLOW, DENY | إدخال المستخدم |  | الأثر |
| 8 | `VALID_UNTIL` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | صالح حتى |
| 9 | `GRANTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المانح |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_SHARE

| البند | القيمة |
|---|---|
| الاسم العربي | مشاركات المستندات |
| English | Document Shares |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TOKEN_HASH) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 4 | `VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار المشارك |
| 5 | `SHARE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INTERNAL, EXTERNAL | إدخال المستخدم |  | النوع |
| 6 | `RECIPIENT_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستلم الداخلي |
| 7 | `RECIPIENT_EMAIL` | نص | `VARCHAR2(320 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | المستلم الخارجي |
| 8 | `TOKEN_HASH` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | Hash رمز الرابط (لا يخزن الرمز) |
| 9 | `REQUIRES_OTP` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | تحقق هوية |
| 10 | `VIEW_ONLY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | عرض فقط |
| 11 | `WATERMARK` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | علامة مائية |
| 12 | `MAX_DOWNLOADS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | حد التنزيل |
| 13 | `DOWNLOAD_COUNT` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | عدد التنزيلات |
| 14 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الانتهاء (لا روابط عامة دائمة) |
| 15 | `REVOKED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإلغاء |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, EXPIRED, REVOKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_COMMENT

| البند | القيمة |
|---|---|
| الاسم العربي | تعليقات المستندات |
| English | Document Comments |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 4 | `VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار |
| 5 | `PARENT_COMMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_COMMENT |  | إدخال المستخدم |  | التعليق الأب |
| 6 | `AUTHOR_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الكاتب |
| 7 | `COMMENT_TEXT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النص (لا يصبح جزءاً من المستند الموقع) |
| 8 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_OCR_TEXT

| البند | القيمة |
|---|---|
| الاسم العربي | النص المستخرج OCR |
| English | Extracted Text (OCR) |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يفهرس بـOracle Text؛ تطبق الصلاحيات قبل إظهار المقتطفات |
| مفاتيح فريدة | UK1: (VERSION_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT_VERSION UK1 |  | إدخال المستخدم |  | الإصدار |
| 4 | `ENGINE_CODE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | المحرك |
| 5 | `ENGINE_VERSION` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | إصدار المحرك |
| 6 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة |
| 7 | `QUALITY_SCORE` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | جودة الاستخراج |
| 8 | `EXTRACTED_TEXT` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | النص (مشتق؛ ليس بديلاً عن الأصل) |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, PROCESSING, DONE, FAILED, STALE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_TEMPLATE

| البند | القيمة |
|---|---|
| الاسم العربي | قوالب توليد المستندات |
| English | Document Templates |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
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
| 6 | `DOCUMENT_TYPE_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_TYPE |  | إدخال المستخدم |  | نوع المستند الناتج |
| 7 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 8 | `OUTPUT_FORMAT` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PDF' |  | PDF, DOCX, XLSX, HTML, XML, JSON | إدخال المستخدم |  | صيغة الإخراج |
| 9 | `LANGUAGE_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'BILINGUAL' |  | AR, EN, BILINGUAL | إدخال المستخدم |  | اللغة |
| 10 | `TEMPLATE_CONTENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_FILE_CONTENT |  | إدخال المستخدم |  | ملف القالب |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_UPLOAD_SESSION

| البند | القيمة |
|---|---|
| الاسم العربي | جلسات الرفع |
| English | Upload Sessions |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 4 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 5 | `MAX_SIZE_BYTES` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | السقف |
| 6 | `ALLOWED_MIME` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الأنواع المسموحة |
| 7 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | منع التكرار |
| 8 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | انتهاء الجلسة (قصيرة العمر) |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, COMPLETED, EXPIRED, FAILED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_SIGNATURE_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات التوقيع |
| English | Signature Requests |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار المطلوب توقيعه |
| 4 | `SIGNING_ORDER` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SEQUENTIAL' |  | SEQUENTIAL, PARALLEL, ANY_AUTHORIZED, ALL_PARTIES | إدخال المستخدم |  | ترتيب التوقيع |
| 5 | `REQUIRED_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INTERNAL_CONFIRM, SIMPLE, ADVANCED_MFA, DIGITAL_CERT, ORG_SEAL | إدخال المستخدم |  | المستوى (حسب Country Pack) |
| 6 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 7 | `WF_TASK_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_TASK |  | إدخال المستخدم |  | مهمة Workflow |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SENT, PARTIALLY_SIGNED, COMPLETED, DECLINED, EXPIRED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_SIGNATURE

| البند | القيمة |
|---|---|
| الاسم العربي | التوقيعات |
| English | Signatures |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الغرض | التوقيع مرتبط ببايتات نسخة بعينها؛ تغيير المحتوى يستلزم إصداراً وتوقيعاً جديدين |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `REQUEST_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_SIGNATURE_REQUEST |  | إدخال المستخدم |  | الطلب |
| 4 | `VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار الموقع |
| 5 | `SIGNED_HASH` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | Hash البايتات الموقعة |
| 6 | `SIGNER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الموقع الداخلي |
| 7 | `SIGNER_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الموقع الخارجي |
| 8 | `SIGNER_CAPACITY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | صفة الموقع |
| 9 | `DELEGATION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | التوقيع بالنيابة |
| 10 | `SIGNATURE_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INTERNAL_CONFIRM, SIMPLE, ADVANCED_MFA, DIGITAL_CERT, ORG_SEAL | إدخال المستخدم |  | الطريقة |
| 11 | `CERTIFICATE_REF` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع الشهادة |
| 12 | `TIMESTAMP_TOKEN` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ختم زمني موثوق |
| 13 | `VERIFICATION_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | طريقة التحقق (OTP، MFA...) |
| 14 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SIGNED, DECLINED, FAILED, REVOKED | إدخال المستخدم |  | النتيجة |
| 15 | `SESSION_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_SESSION |  | إدخال المستخدم |  | الجلسة |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## DMS_LEGAL_HOLD

| البند | القيمة |
|---|---|
| الاسم العربي | الحجوزات القانونية |
| English | Legal Holds |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, HOLD_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `HOLD_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرقم |
| 4 | `REASON` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب (نزاع، تحقيق، أمر قضائي) |
| 5 | `CASE_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع القضية |
| 6 | `RELEASED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | رافع الحجز (صلاحية مستقلة عبر Workflow) |
| 7 | `RELEASED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الرفع |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, RELEASED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_LEGAL_HOLD_ITEM

| البند | القيمة |
|---|---|
| الاسم العربي | عناصر الحجز القانوني |
| English | Legal Hold Items |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `LEGAL_HOLD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_LEGAL_HOLD |  | إدخال المستخدم |  | الحجز |
| 4 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 5 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | أو كيان كامل |
| 6 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرفه |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_DISPOSAL_BATCH

| البند | القيمة |
|---|---|
| الاسم العربي | دفعات الإتلاف |
| English | Disposal Batches |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, BATCH_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `BATCH_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرقم |
| 4 | `DISPOSAL_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | طريقة الإتلاف |
| 5 | `CERTIFICATE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | شهادة الإتلاف |
| 6 | `EXECUTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التنفيذ |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CANDIDATES' |  | CANDIDATES, UNDER_REVIEW, APPROVED, EXECUTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_DISPOSAL_ITEM

| البند | القيمة |
|---|---|
| الاسم العربي | عناصر الإتلاف |
| English | Disposal Items |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `BATCH_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DISPOSAL_BATCH |  | إدخال المستخدم |  | الدفعة |
| 4 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 5 | `EXCLUSION_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الاستبعاد (حجز، رابط ملزم، توقيع) |
| 6 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CANDIDATE' |  | CANDIDATE, APPROVED, EXCLUDED, DISPOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DMS_ACCESS_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل الوصول للمستندات |
| English | Document Access Log |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الاحتفاظ | حسب Country Pack؛ مرشح للتقسيم الشهري |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOCUMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 4 | `VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار |
| 5 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 6 | `ACCESS_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | LIST, VIEW_METADATA, PREVIEW, READ, DOWNLOAD, PRINT, EXPORT, SHARE, AI_RETRIEVAL | إدخال المستخدم |  | النوع |
| 7 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ALLOWED, DENIED | إدخال المستخدم |  | النتيجة |
| 8 | `DELEGATION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | بالتفويض |
| 9 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | APEX, ORDS, JOB, AI, SHARE_LINK | إدخال المستخدم |  | القناة |
| 10 | `SESSION_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_SESSION |  | إدخال المستخدم |  | الجلسة |
| 11 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## DMS_STORAGE_USAGE

| البند | القيمة |
|---|---|
| الاسم العربي | استهلاك التخزين |
| English | Storage Usage |
| الحزمة المالكة | 04 — `NOONA_DMS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | تجاوز الحصة يمنع رفع الجديد ولا يحذف الملفات الحالية |
| مفاتيح فريدة | UK1: (TENANT_ID, MEASURED_ON, STORAGE_MEDIUM) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MEASURED_ON` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | تاريخ القياس |
| 4 | `STORAGE_MEDIUM` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الوسيط |
| 5 | `FILE_COUNT` | رقم | `NUMBER` | ✔ | 0 |  |  | إدخال المستخدم |  | عدد الملفات |
| 6 | `TOTAL_BYTES` | رقم | `NUMBER` | ✔ | 0 |  |  | إدخال المستخدم |  | الحجم الكلي |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

