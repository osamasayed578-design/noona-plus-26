# قاموس البيانات — الحزمة 37: مركز الإدارة والتواصل

**Management & Engagement Hub** · الحزمة البرمجية المالكة `NOONA_ENG_PKG` · ملف DDL `db/ddl/p37_eng.sql` · [ERD](../erd/p37_eng.md)

بوابة العملاء والمحلات برابط آمن (الفواتير، الرصيد، كشف الحساب، تتبع الشحنات)، محرك واتساب (Cloud API أو روابط wa.me) بالقوالب وسجل الرسائل، توقع النقد 90 يوماً، قواعد الإنذار المبكر وتنبيهاتها، لوحة المدير على الهاتف، مركز المساعدة لكل شاشة، تصدير البيانات إلى Excel، وسجل التغييرات المقروء.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`ENG_PORTAL_LINK`](#eng_portal_link) | روابط بوابة العملاء | Customer Portal Links | C | INTERNAL |
| [`ENG_WA_SETTING`](#eng_wa_setting) | إعدادات واتساب | WhatsApp Settings | C | INTERNAL |
| [`ENG_WA_TEMPLATE`](#eng_wa_template) | قوالب الرسائل | Message Templates | C | INTERNAL |
| [`ENG_MESSAGE`](#eng_message) | سجل الرسائل | Message Log | C | INTERNAL |
| [`ENG_ALERT_RULE`](#eng_alert_rule) | قواعد الإنذار المبكر | Early-warning Rules | C | INTERNAL |
| [`ENG_ALERT`](#eng_alert) | تنبيهات الإنذار المبكر | Early-warning Alerts | C | INTERNAL |
| [`ENG_HELP`](#eng_help) | مساعدة الشاشات | Screen Help | TO | INTERNAL |
| [`ENG_CHANGE_LOG`](#eng_change_log) | سجل التغييرات | Change Log | T | INTERNAL |

## ENG_PORTAL_LINK

| البند | القيمة |
|---|---|
| الاسم العربي | روابط بوابة العملاء |
| English | Customer Portal Links |
| الحزمة المالكة | 37 — `NOONA_ENG_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TOKEN_HASH) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | حساب العميل |
| 5 | `TOKEN_HASH` | نص | `VARCHAR2(64 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | بصمة الرمز (لا يخزن الرمز نصاً) |
| 6 | `TOKEN_ENC` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرمز مشفراً (لإعادة إرسال الرابط) |
| 7 | `TOKEN_HINT` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | آخر أحرف الرمز |
| 8 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | ينتهي في |
| 9 | `LAST_ACCESS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر دخول |
| 10 | `ACCESS_COUNT` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | مرات الدخول |
| 11 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | جوال الإرسال |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, REVOKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ENG_WA_SETTING

| البند | القيمة |
|---|---|
| الاسم العربي | إعدادات واتساب |
| English | WhatsApp Settings |
| الحزمة المالكة | 37 — `NOONA_ENG_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PROVIDER` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'LINK' |  | LINK, CLOUD_API | إدخال المستخدم |  | الطريقة (روابط wa.me أو WhatsApp Cloud API) |
| 5 | `PHONE_NUMBER_ID` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف رقم الإرسال (Cloud API) |
| 6 | `BUSINESS_ACCOUNT_ID` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف حساب الأعمال |
| 7 | `API_VERSION` | نص | `VARCHAR2(10 CHAR)` | ✔ | 'v21.0' |  |  | إدخال المستخدم |  | إصدار الواجهة |
| 8 | `TOKEN_ENC` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | رمز الوصول مشفراً (يدخله المسؤول ولا يعرض) |
| 9 | `DEFAULT_CC` | نص | `VARCHAR2(5 CHAR)` | ✔ | '966' |  |  | إدخال المستخدم |  | رمز الدولة الافتراضي |
| 10 | `SENDER_PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الإرسال للعرض |
| 11 | `IS_ENABLED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | مفعل |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ENG_WA_TEMPLATE

| البند | القيمة |
|---|---|
| الاسم العربي | قوالب الرسائل |
| English | Message Templates |
| الحزمة المالكة | 37 — `NOONA_ENG_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `EVENT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GENERAL' |  | INVOICE, STATEMENT, PAYMENT, REMINDER, PORTAL, ORDER, ALERT, GENERAL | إدخال المستخدم |  | المناسبة |
| 8 | `BODY_TEXT` | نص | `VARCHAR2(2000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النص ({customer} {amount} {invoice} {date} {balance} {link} {company}) |
| 9 | `CLOUD_TEMPLATE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | اسم القالب المعتمد في Meta (للرسائل التي يبدؤها النظام) |
| 10 | `LANGUAGE_CODE` | نص | `VARCHAR2(10 CHAR)` | ✔ | 'ar' |  |  | إدخال المستخدم |  | لغة القالب |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ENG_MESSAGE

| البند | القيمة |
|---|---|
| الاسم العربي | سجل الرسائل |
| English | Message Log |
| الحزمة المالكة | 37 — `NOONA_ENG_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'WHATSAPP' |  | WHATSAPP, SMS, EMAIL | إدخال المستخدم |  | القناة |
| 5 | `TO_PHONE` | نص | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | إلى |
| 6 | `TEMPLATE_ID` | معرف | `NUMBER(19)` |  |  | FK→ENG_WA_TEMPLATE |  | إدخال المستخدم |  | القالب |
| 7 | `BODY_TEXT` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النص |
| 8 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | الكيان المرتبط |
| 9 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرفه |
| 10 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | العميل |
| 11 | `PROVIDER_MSG_ID` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الرسالة لدى المزود |
| 12 | `ERROR_TEXT` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 13 | `SENT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإرسال |
| 14 | `LINK_URL` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | رابط wa.me (عند الإرسال اليدوي) |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'QUEUED' |  | QUEUED, SENT, DELIVERED, READ, FAILED, LINK | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ENG_ALERT_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد الإنذار المبكر |
| English | Early-warning Rules |
| الحزمة المالكة | 37 — `NOONA_ENG_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `METRIC` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CASH_LOW, FORECAST_NEGATIVE, AR_OVERDUE, OVER_CREDIT_LIMIT, STOCK_BELOW_MIN, SALES_DROP, PENDING_COLLECTIONS, CHEQUES_DUE, AP_DUE | إدخال المستخدم |  | المؤشر |
| 8 | `THRESHOLD` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الحد |
| 9 | `DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الأيام |
| 10 | `SEVERITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MEDIUM' |  | LOW, MEDIUM, HIGH, CRITICAL | إدخال المستخدم |  | الخطورة |
| 11 | `NOTIFY_WHATSAPP` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | واتساب المدير (اختياري) |
| 12 | `LAST_RUN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر فحص |
| 13 | `LAST_VALUE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | آخر قيمة |
| 14 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ENG_ALERT

| البند | القيمة |
|---|---|
| الاسم العربي | تنبيهات الإنذار المبكر |
| English | Early-warning Alerts |
| الحزمة المالكة | 37 — `NOONA_ENG_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, RULE_ID, ALERT_DATE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RULE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ENG_ALERT_RULE UK1 |  | إدخال المستخدم |  | القاعدة |
| 5 | `ALERT_DATE` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | اليوم |
| 6 | `SEVERITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الخطورة |
| 7 | `TITLE` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 8 | `DETAIL` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | التفاصيل |
| 9 | `METRIC_VALUE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | القيمة |
| 10 | `ACK_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | استلمه |
| 11 | `ACK_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاستلام |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, ACKNOWLEDGED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ENG_HELP

| البند | القيمة |
|---|---|
| الاسم العربي | مساعدة الشاشات |
| English | Screen Help |
| الحزمة المالكة | 37 — `NOONA_ENG_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `APP_ALIAS` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | التطبيق |
| 4 | `PAGE_ID` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | الصفحة |
| 5 | `TITLE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان |
| 6 | `PURPOSE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الغرض من الشاشة |
| 7 | `STEPS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | خطوات العمل (سطر لكل خطوة) |
| 8 | `TIPS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | تنبيهات ونصائح |
| 9 | `VIDEO_URL` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | رابط فيديو الشرح |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ENG_CHANGE_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل التغييرات |
| English | Change Log |
| الحزمة المالكة | 37 — `NOONA_ENG_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | الشركة |
| 4 | `TABLE_NAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الجدول |
| 5 | `ROW_ID` | معرف | `NUMBER(19)` | ✔ |  |  |  | إدخال المستخدم |  | السجل |
| 6 | `ACTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INSERT, UPDATE, DELETE | إدخال المستخدم |  | الإجراء |
| 7 | `CHANGES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الحقول المتغيرة [{c,o,n}] |
| 8 | `CHANGED_BY` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | بواسطة |
| 9 | `CHANGED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | الوقت |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

