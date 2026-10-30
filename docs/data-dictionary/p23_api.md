# قاموس البيانات — الحزمة 23: ORDS وواجهات API والتكاملات

**ORDS, APIs & Integrations** · الحزمة البرمجية المالكة `NOONA_API_PKG` · ملف DDL `db/ddl/p23_api.sql` · [ERD](../erd/p23_api.md)

Integration Matrix، وعملاء API وأسرارهم بمراجع Vault، وسجل نقاط النهاية بإصداراتها، وسجل الطلبات، ومفاتيح Idempotency، و Outbox/Inbox للأحداث الصادرة والواردة مع Retry و Dead-Letter، والـWebhooks.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`API_INTEGRATION`](#api_integration) | مصفوفة التكاملات | Integration Matrix | TO | INTERNAL |
| [`API_INTEGRATION_CONFIG`](#api_integration_config) | إعدادات التكامل للمؤسسة | Tenant Integration Config | T | INTERNAL |
| [`API_CLIENT`](#api_client) | عملاء API | API Clients | T | INTERNAL |
| [`API_CLIENT_SECRET`](#api_client_secret) | أسرار عملاء API | API Client Secrets | T | HIGHLY_RESTRICTED |
| [`API_ACCESS_TOKEN`](#api_access_token) | رموز الدخول | API Access Tokens | T | HIGHLY_RESTRICTED |
| [`API_ENDPOINT`](#api_endpoint) | نقاط النهاية | API Endpoints | G | INTERNAL |
| [`API_REQUEST_LOG`](#api_request_log) | سجل طلبات API | API Request Log | TO | INTERNAL |
| [`API_IDEMPOTENCY_KEY`](#api_idempotency_key) | مفاتيح منع التكرار | Idempotency Keys | T | INTERNAL |
| [`API_OUTBOX`](#api_outbox) | صندوق الأحداث الصادرة | Transactional Outbox | TO | INTERNAL |
| [`API_INBOX`](#api_inbox) | صندوق الرسائل الواردة | Inbound Message Inbox | TO | INTERNAL |
| [`API_WEBHOOK_SUBSCRIPTION`](#api_webhook_subscription) | اشتراكات Webhook | Webhook Subscriptions | T | INTERNAL |
| [`API_WEBHOOK_DELIVERY`](#api_webhook_delivery) | تسليمات Webhook | Webhook Deliveries | T | INTERNAL |
| [`API_IMPORT_JOB`](#api_import_job) | مهام الاستيراد | Import Jobs | T | INTERNAL |

## API_INTEGRATION

| البند | القيمة |
|---|---|
| الاسم العربي | مصفوفة التكاملات |
| English | Integration Matrix |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا يعتمد أي تكامل قبل تحديد مالك البيانات و Idempotency (7.5) |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `PROVIDER_NAME` | نص | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الطرف/المزود |
| 7 | `INTEGRATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PAYMENT_GATEWAY, BANK, EMAIL, SMS, WHATSAPP, PUSH, E_INVOICE, E_SIGNATURE, GOVERNMENT, PARTNER, AI, OCR, STORAGE, IDENTITY, OTHER | إدخال المستخدم |  | النوع |
| 8 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 9 | `OWNER_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المالك الداخلي |
| 10 | `DIRECTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | OUTBOUND, INBOUND, BIDIRECTIONAL | إدخال المستخدم |  | اتجاه البيانات |
| 11 | `CONTRACT_VERSION` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | إصدار العقد/الواجهة |
| 12 | `AUTH_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | API_KEY, OAUTH2, MTLS, BASIC, JWT, HMAC, CERTIFICATE | إدخال المستخدم |  | طريقة المصادقة |
| 13 | `HANDLES_PII` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتضمن بيانات شخصية |
| 14 | `DATA_RESIDENCY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | إقامة البيانات |
| 15 | `SLA_INFO` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | SLA |
| 16 | `FAILURE_POLICY` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سياسة الفشل والتراجع |
| 17 | `IDEMPOTENCY_STRATEGY` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | استراتيجية منع التكرار (إلزامية قبل الاعتماد) |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, SANDBOX, ACTIVE, SUSPENDED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_INTEGRATION_CONFIG

| البند | القيمة |
|---|---|
| الاسم العربي | إعدادات التكامل للمؤسسة |
| English | Tenant Integration Config |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, INTEGRATION_ID, COMPANY_ID, ENVIRONMENT) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `INTEGRATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→API_INTEGRATION UK1 |  | إدخال المستخدم |  | التكامل |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY UK1 |  | إدخال المستخدم |  | الشركة |
| 5 | `ENVIRONMENT` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SANDBOX' | UK1 | SANDBOX, PRODUCTION | إدخال المستخدم |  | البيئة |
| 6 | `CONFIG_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الإعدادات غير السرية |
| 7 | `SECRET_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع الأسرار في Vault (لا تظهر بعد الحفظ) |
| 8 | `LAST_TESTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر اختبار |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, DISABLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_CLIENT

| البند | القيمة |
|---|---|
| الاسم العربي | عملاء API |
| English | API Clients |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (CLIENT_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `CLIENT_ID` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | معرف العميل |
| 7 | `SERVICE_USER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER |  | إدخال المستخدم |  | حساب الخدمة المرتبط |
| 8 | `OWNER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | مالك الأعمال |
| 9 | `SCOPES` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النطاقات المسموحة |
| 10 | `IP_ALLOWLIST` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | عناوين IP المسموحة |
| 11 | `RATE_LIMIT_PER_MIN` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | حد المعدل |
| 12 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 13 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة التي يعمل فيها العميل |
| 14 | `ROLE_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_ROLE |  | إدخال المستخدم |  | الدور (صلاحيات العميل) |
| 15 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف والاستخدام |
| 16 | `TOKEN_TTL_MIN` | عدد صحيح | `NUMBER(10)` | ✔ | 60 |  |  | إدخال المستخدم |  | صلاحية رمز الدخول بالدقائق |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, SUSPENDED, REVOKED, EXPIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_CLIENT_SECRET

| البند | القيمة |
|---|---|
| الاسم العربي | أسرار عملاء API |
| English | API Client Secrets |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `API_CLIENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→API_CLIENT |  | إدخال المستخدم |  | العميل |
| 4 | `SECRET_HASH` | نص | `VARCHAR2(512 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | Hash السر فقط |
| 5 | `SECRET_HINT` | نص | `VARCHAR2(10 CHAR)` |  |  |  |  | إدخال المستخدم |  | آخر أحرف للتعرف |
| 6 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 7 | `LAST_USED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر استخدام |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, ROTATING, REVOKED, EXPIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_ACCESS_TOKEN

| البند | القيمة |
|---|---|
| الاسم العربي | رموز الدخول |
| English | API Access Tokens |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TOKEN_HASH) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `API_CLIENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→API_CLIENT |  | إدخال المستخدم |  | العميل |
| 4 | `TOKEN_HASH` | نص | `VARCHAR2(128 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | Hash الرمز فقط |
| 5 | `SESSION_REF` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | مرجع جلسة الخدمة |
| 6 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الانتهاء |
| 7 | `REVOKED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الإلغاء |
| 8 | `CLIENT_IP` | نص | `VARCHAR2(45 CHAR)` |  |  |  |  | إدخال المستخدم |  | IP |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_ENDPOINT

| البند | القيمة |
|---|---|
| الاسم العربي | نقاط النهاية |
| English | API Endpoints |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (API_VERSION, HTTP_METHOD, PATH_TEMPLATE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحزمة |
| 3 | `API_VERSION` | نص | `VARCHAR2(10 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الإصدار (v1...) |
| 4 | `HTTP_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | GET, POST, PUT, PATCH, DELETE | إدخال المستخدم |  | الطريقة |
| 5 | `PATH_TEMPLATE` | نص | `VARCHAR2(500 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | المسار |
| 6 | `PERMISSION_CODE` | نص | `VARCHAR2(100 CHAR)` |  |  | FK→SEC_PERMISSION |  | إدخال المستخدم |  | الصلاحية المطلوبة |
| 7 | `HANDLER_API` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | حزمة الأعمال المستدعاة (لا SQL مكرر) |
| 8 | `REQUIRES_IDEMPOTENCY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب Idempotency-Key |
| 9 | `DEPRECATED_AT` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإيقاف المعلن |
| 10 | `SUNSET_AT` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التقاعد |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_REQUEST_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل طلبات API |
| English | API Request Log |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الاحتفاظ | 90 يوماً افتراضياً |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `REQUEST_ID` | نص | `VARCHAR2(64 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | معرف الطلب |
| 4 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 5 | `API_CLIENT_ID` | معرف | `NUMBER(19)` |  |  | FK→API_CLIENT |  | إدخال المستخدم |  | العميل |
| 6 | `ENDPOINT_ID` | معرف | `NUMBER(19)` |  |  | FK→API_ENDPOINT |  | إدخال المستخدم |  | النقطة |
| 7 | `HTTP_STATUS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | رمز الاستجابة |
| 8 | `DURATION_MS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | المدة |
| 9 | `REQUEST_SIZE` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الحجم |
| 10 | `CLIENT_IP` | نص | `VARCHAR2(45 CHAR)` |  |  |  |  | إدخال المستخدم |  | IP |
| 11 | `ERROR_CODE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رمز الخطأ (بدون Tokens أو بيانات حساسة) |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## API_IDEMPOTENCY_KEY

| البند | القيمة |
|---|---|
| الاسم العربي | مفاتيح منع التكرار |
| English | Idempotency Keys |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, SCOPE_CODE, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(200 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | المفتاح |
| 4 | `SCOPE_CODE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | العملية |
| 5 | `REQUEST_HASH` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | Hash الطلب (رفض نفس المفتاح بطلب مختلف) |
| 6 | `RESPONSE_STATUS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الاستجابة المخزنة |
| 7 | `RESPONSE_BODY` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | جسم الاستجابة |
| 8 | `RESULT_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | الكيان الناتج |
| 9 | `RESULT_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرفه |
| 10 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الانتهاء |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_OUTBOX

| البند | القيمة |
|---|---|
| الاسم العربي | صندوق الأحداث الصادرة |
| English | Transactional Outbox |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يكتب مع المعاملة نفسها ثم ينشر لاحقاً؛ يضمن عدم فقد الأحداث |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `AGGREGATE_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | نوع الكيان |
| 4 | `AGGREGATE_ID` | معرف | `NUMBER(19)` | ✔ |  |  |  | إدخال المستخدم |  | معرفه |
| 5 | `EVENT_TYPE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحدث (SAL_INVOICE.POSTED...) |
| 6 | `EVENT_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | إصدار المخطط |
| 7 | `PAYLOAD` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | الحمولة (بدون أسرار) |
| 8 | `DESTINATION` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوجهة (POSTING، NOTIFICATION، WEBHOOK، EINVOICE، AI_INDEX...) |
| 9 | `PRIORITY_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 5 |  |  | إدخال المستخدم |  | الأولوية |
| 10 | `ATTEMPTS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحاولات |
| 11 | `NEXT_ATTEMPT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | المحاولة التالية (Backoff) |
| 12 | `LAST_ERROR` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | آخر خطأ |
| 13 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 14 | `PROCESSED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت المعالجة |
| 15 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, PROCESSING, SENT, FAILED, DEAD, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_INBOX

| البند | القيمة |
|---|---|
| الاسم العربي | صندوق الرسائل الواردة |
| English | Inbound Message Inbox |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (SOURCE_SYSTEM, MESSAGE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `SOURCE_SYSTEM` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | المصدر |
| 4 | `MESSAGE_ID` | نص | `VARCHAR2(200 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | معرف الرسالة لدى المصدر |
| 5 | `MESSAGE_TYPE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النوع |
| 6 | `SIGNATURE_VALID` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | التحقق من التوقيع |
| 7 | `PAYLOAD` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الحمولة |
| 8 | `ATTEMPTS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحاولات |
| 9 | `LAST_ERROR` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 10 | `PROCESSED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت المعالجة |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'RECEIVED' |  | RECEIVED, PROCESSING, PROCESSED, DUPLICATE, FAILED, DEAD | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_WEBHOOK_SUBSCRIPTION

| البند | القيمة |
|---|---|
| الاسم العربي | اشتراكات Webhook |
| English | Webhook Subscriptions |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `API_CLIENT_ID` | معرف | `NUMBER(19)` |  |  | FK→API_CLIENT |  | إدخال المستخدم |  | العميل |
| 4 | `EVENT_TYPE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحدث |
| 5 | `TARGET_URL` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 6 | `SIGNING_SECRET_REF` | نص | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | مرجع سر التوقيع |
| 7 | `FAILURE_COUNT` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإخفاقات المتتالية |
| 8 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 9 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 10 | `LAST_DELIVERY_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر تسليم |
| 11 | `LAST_HTTP_STATUS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | آخر استجابة |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, PAUSED, DISABLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_WEBHOOK_DELIVERY

| البند | القيمة |
|---|---|
| الاسم العربي | تسليمات Webhook |
| English | Webhook Deliveries |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `SUBSCRIPTION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→API_WEBHOOK_SUBSCRIPTION |  | إدخال المستخدم |  | الاشتراك |
| 4 | `OUTBOX_ID` | معرف | `NUMBER(19)` |  |  | FK→API_OUTBOX |  | إدخال المستخدم |  | الحدث |
| 5 | `ATTEMPT_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | المحاولة |
| 6 | `HTTP_STATUS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الاستجابة |
| 7 | `DURATION_MS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | المدة |
| 8 | `NEXT_RETRY_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | المحاولة التالية |
| 9 | `EVENT_TYPE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحدث |
| 10 | `RESPONSE_SNIPPET` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | بداية الاستجابة أو الخطأ |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, DELIVERED, FAILED, DEAD | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## API_IMPORT_JOB

| البند | القيمة |
|---|---|
| الاسم العربي | مهام الاستيراد |
| English | Import Jobs |
| الحزمة المالكة | 23 — `NOONA_API_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | استيراد دفعي بأخطاء لكل سطر دون إيقاف الباقي |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 4 | `IMPORT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CUSTOMERS, SUPPLIERS, ITEMS, ACCOUNTS, BANK_STATEMENT, ORDERS | إدخال المستخدم |  | النوع |
| 5 | `FILE_NAME` | نص | `VARCHAR2(300 CHAR)` |  |  |  |  | إدخال المستخدم |  | الملف |
| 6 | `TOTAL_ROWS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الأسطر |
| 7 | `OK_ROWS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الناجحة |
| 8 | `FAILED_ROWS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الفاشلة |
| 9 | `ERRORS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | أخطاء الأسطر |
| 10 | `RESULT_REF` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | الناتج (رقم الكشف...) |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'RUNNING' |  | RUNNING, COMPLETED, PARTIAL, FAILED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

