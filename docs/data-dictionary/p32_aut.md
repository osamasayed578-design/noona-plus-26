# قاموس البيانات — الحزمة 32: مراكز خدمة السيارات

**Auto Service Centers** · الحزمة البرمجية المالكة `NOONA_AUT_PKG` · ملف DDL `db/ddl/p32_aut.sql` · [ERD](../erd/p32_aut.md)

المركبات وملاكها، كتالوج الخدمات ككروت مع قطعها الافتراضية، الرافعات والفنيون، الحجوزات، أوامر الإصلاح بالخدمات وقطع الغيار والفني المنفذ ومدة البقاء، فاتورة واحدة تصرف القطع من المخزون، ومطالبات شركات التأمين وتحمل العميل.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`AUT_SERVICE_CATEGORY`](#aut_service_category) | فئات خدمات السيارات | Service Categories | C | INTERNAL |
| [`AUT_SERVICE`](#aut_service) | خدمات السيارات | Auto Services | C | INTERNAL |
| [`AUT_SERVICE_PART`](#aut_service_part) | القطع الافتراضية للخدمة | Service Default Parts | C | INTERNAL |
| [`AUT_BAY`](#aut_bay) | الرافعات ومواقع العمل | Service Bays | C | INTERNAL |
| [`AUT_TECHNICIAN`](#aut_technician) | الفنيون | Technicians | C | INTERNAL |
| [`AUT_INSURER`](#aut_insurer) | شركات التأمين | Insurers | C | INTERNAL |
| [`AUT_VEHICLE`](#aut_vehicle) | المركبات | Vehicles | C | INTERNAL |
| [`AUT_APPOINTMENT`](#aut_appointment) | حجوزات الصيانة | Service Appointments | C | INTERNAL |
| [`AUT_JOB_CARD`](#aut_job_card) | أوامر الإصلاح | Job Cards | C | INTERNAL |
| [`AUT_JOB_LINE`](#aut_job_line) | بنود أمر الإصلاح | Job Card Lines | C | INTERNAL |

## AUT_SERVICE_CATEGORY

| البند | القيمة |
|---|---|
| الاسم العربي | فئات خدمات السيارات |
| English | Service Categories |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
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
| 7 | `ICON` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | الأيقونة |
| 8 | `COLOR` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | لون الكرت |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_SERVICE

| البند | القيمة |
|---|---|
| الاسم العربي | خدمات السيارات |
| English | Auto Services |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
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
| 7 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 8 | `CATEGORY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AUT_SERVICE_CATEGORY |  | إدخال المستخدم |  | الفئة |
| 9 | `PRICE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | السعر |
| 10 | `PRICE_INCLUDES_TAX` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | السعر شامل الضريبة |
| 11 | `STANDARD_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الوقت القياسي بالدقائق |
| 12 | `WARRANTY_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ضمان العمل بالأيام |
| 13 | `WARRANTY_KM` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ضمان العمل بالكيلومتر |
| 14 | `NEXT_SERVICE_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الخدمة التالية بعد (يوم) |
| 15 | `NEXT_SERVICE_KM` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الخدمة التالية بعد (كم) |
| 16 | `ICON` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | الأيقونة |
| 17 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 18 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_SERVICE_PART

| البند | القيمة |
|---|---|
| الاسم العربي | القطع الافتراضية للخدمة |
| English | Service Default Parts |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (SERVICE_ID, ITEM_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SERVICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AUT_SERVICE UK1 |  | إدخال المستخدم |  | الخدمة |
| 5 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM UK1 |  | إدخال المستخدم |  | القطعة |
| 6 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ | 1 |  |  | إدخال المستخدم |  | الكمية |
| 7 | `IS_OPTIONAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | اختيارية (تقترح ولا تضاف تلقائياً) |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_BAY

| البند | القيمة |
|---|---|
| الاسم العربي | الرافعات ومواقع العمل |
| English | Service Bays |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
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
| 7 | `BAY_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'LIFT' |  | LIFT, FLOOR, WASH, PAINT, ALIGNMENT, DIAGNOSTIC, TIRE | إدخال المستخدم |  | النوع |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_TECHNICIAN

| البند | القيمة |
|---|---|
| الاسم العربي | الفنيون |
| English | Technicians |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
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
| 7 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 8 | `SPECIALTY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | التخصص |
| 9 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجوال |
| 10 | `HOURLY_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تكلفة الساعة |
| 11 | `COMMISSION_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة العمولة من الخدمات |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_INSURER

| البند | القيمة |
|---|---|
| الاسم العربي | شركات التأمين |
| English | Insurers |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
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
| 7 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | حساب الذمة (المطالبات) |
| 8 | `LABOR_DISCOUNT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | خصم الخدمات المتفق عليه |
| 9 | `PARTS_DISCOUNT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | خصم القطع المتفق عليه |
| 10 | `DEFAULT_DEDUCTIBLE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تحمل العميل الافتراضي |
| 11 | `CLAIM_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مهلة سداد المطالبات بالأيام |
| 12 | `CONTACT_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مسؤول التواصل |
| 13 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الهاتف |
| 14 | `EMAIL` | نص | `VARCHAR2(320 CHAR)` |  |  |  |  | إدخال المستخدم |  | البريد |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, SUSPENDED, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_VEHICLE

| البند | القيمة |
|---|---|
| الاسم العربي | المركبات |
| English | Vehicles |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (COMPANY_ID, PLATE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `PLATE_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم اللوحة |
| 6 | `PLATE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PRIVATE' |  | PRIVATE, COMMERCIAL, TAXI, TRANSPORT, MOTORCYCLE, TEMPORARY, DIPLOMATIC, EXPORT | إدخال المستخدم |  | نوع اللوحة |
| 7 | `VIN` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الهيكل (VIN) |
| 8 | `MAKE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الشركة المصنعة |
| 9 | `MODEL` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الطراز |
| 10 | `MODEL_YEAR` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | سنة الصنع |
| 11 | `COLOR` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | اللون |
| 12 | `ENGINE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المحرك |
| 13 | `FUEL_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | PETROL, DIESEL, HYBRID, ELECTRIC, GAS | إدخال المستخدم |  | الوقود |
| 14 | `TRANSMISSION` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | AUTOMATIC, MANUAL, CVT | إدخال المستخدم |  | ناقل الحركة |
| 15 | `ODOMETER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | آخر قراءة للعداد |
| 16 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | المالك (حساب العميل) |
| 17 | `OWNER_NAME` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | اسم المالك |
| 18 | `OWNER_PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | جوال المالك |
| 19 | `DRIVER_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | السائق |
| 20 | `DRIVER_PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | جوال السائق |
| 21 | `INSURER_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_INSURER |  | إدخال المستخدم |  | شركة التأمين |
| 22 | `POLICY_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الوثيقة |
| 23 | `POLICY_EXPIRY` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | انتهاء التأمين |
| 24 | `REGISTRATION_EXPIRY` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | انتهاء الاستمارة |
| 25 | `NEXT_SERVICE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | موعد الخدمة التالية |
| 26 | `NEXT_SERVICE_KM` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عداد الخدمة التالية |
| 27 | `LAST_VISIT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر زيارة |
| 28 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 29 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 30 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 31 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 32 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 33 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 34 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_APPOINTMENT

| البند | القيمة |
|---|---|
| الاسم العربي | حجوزات الصيانة |
| English | Service Appointments |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 6 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 7 | `VEHICLE_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_VEHICLE |  | إدخال المستخدم |  | المركبة |
| 8 | `PLATE_NO` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | اللوحة (مركبة جديدة) |
| 9 | `CUSTOMER_NAME` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | العميل |
| 10 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجوال |
| 11 | `START_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | موعد الوصول |
| 12 | `END_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | نهاية الحجز المتوقعة |
| 13 | `BAY_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_BAY |  | إدخال المستخدم |  | الرافعة |
| 14 | `TECHNICIAN_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_TECHNICIAN |  | إدخال المستخدم |  | الفني |
| 15 | `SERVICE_IDS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخدمات المطلوبة (أرقام مفصولة بفواصل) |
| 16 | `COMPLAINT` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الشكوى |
| 17 | `SOURCE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PHONE' |  | PHONE, WALK_IN, WHATSAPP, WEB, APP | إدخال المستخدم |  | المصدر |
| 18 | `JOB_CARD_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | أمر الإصلاح الناتج |
| 19 | `CANCEL_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإلغاء |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'BOOKED' |  | BOOKED, CONFIRMED, ARRIVED, NO_SHOW, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_JOB_CARD

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر الإصلاح |
| English | Job Cards |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 6 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 7 | `VEHICLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AUT_VEHICLE |  | إدخال المستخدم |  | المركبة |
| 8 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | العميل |
| 9 | `CUSTOMER_NAME` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | اسم العميل |
| 10 | `CUSTOMER_PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجوال |
| 11 | `APPOINTMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_APPOINTMENT |  | إدخال المستخدم |  | الحجز |
| 12 | `BAY_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_BAY |  | إدخال المستخدم |  | الرافعة |
| 13 | `ADVISOR_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مستشار الخدمة |
| 14 | `CHECKIN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | وقت الاستلام |
| 15 | `PROMISED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الموعد المتوقع للتسليم |
| 16 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | بدء العمل |
| 17 | `COMPLETED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | انتهاء العمل |
| 18 | `DELIVERED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | التسليم للعميل |
| 19 | `ODOMETER_IN` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | العداد عند الاستلام |
| 20 | `ODOMETER_OUT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | العداد عند التسليم |
| 21 | `FUEL_LEVEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | EMPTY, QUARTER, HALF, THREE_QUARTERS, FULL | إدخال المستخدم |  | مستوى الوقود |
| 22 | `COMPLAINT` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | شكوى العميل |
| 23 | `DIAGNOSIS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | التشخيص |
| 24 | `RECOMMENDATIONS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | توصيات للعميل |
| 25 | `INSPECTION` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | فحص الاستلام (الملاحظات والأضرار والمتعلقات) |
| 26 | `PAYER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CUSTOMER' |  | CUSTOMER, INSURANCE, WARRANTY, INTERNAL | إدخال المستخدم |  | جهة السداد |
| 27 | `INSURER_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_INSURER |  | إدخال المستخدم |  | شركة التأمين |
| 28 | `CLAIM_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم المطالبة |
| 29 | `POLICY_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الوثيقة |
| 30 | `ACCIDENT_REPORT_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم تقرير الحادث (نجم/المرور) |
| 31 | `CLAIM_STATUS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | NOT_SUBMITTED, SUBMITTED, APPROVED, PARTIALLY_APPROVED, REJECTED, PAID | إدخال المستخدم |  | حالة المطالبة |
| 32 | `APPROVED_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ المعتمد من التأمين (قبل الضريبة) |
| 33 | `DEDUCTIBLE_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تحمل العميل (قبل الضريبة) |
| 34 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع القطع |
| 35 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | فاتورة العميل |
| 36 | `INSURER_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | فاتورة شركة التأمين |
| 37 | `SERVICES_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | صافي الخدمات |
| 38 | `PARTS_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | صافي القطع |
| 39 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الخصم |
| 40 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الضريبة |
| 41 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي |
| 42 | `NEXT_SERVICE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | موعد الخدمة التالية |
| 43 | `NEXT_SERVICE_KM` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عداد الخدمة التالية |
| 44 | `CANCEL_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإلغاء |
| 45 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, IN_PROGRESS, WAITING_PARTS, COMPLETED, INVOICED, DELIVERED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 46 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 47 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 48 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 49 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 50 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 51 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUT_JOB_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | بنود أمر الإصلاح |
| English | Job Card Lines |
| الحزمة المالكة | 32 — `NOONA_AUT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (JOB_CARD_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `JOB_CARD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AUT_JOB_CARD UK2 |  | إدخال المستخدم |  | أمر الإصلاح |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم البند |
| 6 | `LINE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SERVICE, PART, SUBLET | إدخال المستخدم |  | النوع |
| 7 | `SERVICE_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_SERVICE |  | إدخال المستخدم |  | الخدمة |
| 8 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | القطعة |
| 9 | `PARENT_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_JOB_LINE |  | إدخال المستخدم |  | الخدمة التي أضيفت معها القطعة |
| 10 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | البيان |
| 11 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ | 1 |  |  | إدخال المستخدم |  | الكمية |
| 12 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | سعر الوحدة |
| 13 | `PRICE_INCLUDES_TAX` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | السعر شامل الضريبة |
| 14 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الخصم |
| 15 | `NET_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الصافي قبل الضريبة |
| 16 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الضريبة |
| 17 | `UNIT_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تكلفة الوحدة (القطع) |
| 18 | `PAYER` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CUSTOMER' |  | CUSTOMER, INSURANCE, WARRANTY | إدخال المستخدم |  | يحمل على |
| 19 | `TECHNICIAN_ID` | معرف | `NUMBER(19)` |  |  | FK→AUT_TECHNICIAN |  | إدخال المستخدم |  | الفني المنفذ |
| 20 | `WORK_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة العمل بالدقائق |
| 21 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | بدء البند |
| 22 | `DONE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | انتهاء البند |
| 23 | `LINE_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, IN_PROGRESS, DONE, CANCELLED | إدخال المستخدم |  | حالة البند |
| 24 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 25 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 26 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 27 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 28 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 29 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

