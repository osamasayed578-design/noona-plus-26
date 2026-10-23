# قاموس البيانات — الحزمة 18: الصيانة وإدارة المرافق

**Maintenance & Facility Management** · الحزمة البرمجية المالكة `NOONA_MAINTENANCE_PKG` · ملف DDL `db/ddl/p18_mnt.sql` · [ERD](../erd/p18_mnt.md)

بلاغات الصيانة من المستأجرين والنزلاء والموظفين، وأوامر العمل التصحيحية والوقائية، والفرق والفنيون والمواد والعمالة، وعقود الصيانة مع المقاولين، وفترات التوقف، مع قرار مستقل للرسملة أو المصروف.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`MNT_SERVICE_CATEGORY`](#mnt_service_category) | فئات خدمات الصيانة | Service Categories | T | INTERNAL |
| [`MNT_TEAM`](#mnt_team) | فرق الصيانة | Maintenance Teams | C | INTERNAL |
| [`MNT_TECHNICIAN`](#mnt_technician) | الفنيون | Technicians | C | INTERNAL |
| [`MNT_SERVICE_CONTRACT`](#mnt_service_contract) | عقود الصيانة | Service Contracts (AMC) | C | INTERNAL |
| [`MNT_REQUEST`](#mnt_request) | بلاغات الصيانة | Maintenance Requests | C | INTERNAL |
| [`MNT_PM_PLAN`](#mnt_pm_plan) | خطط الصيانة الوقائية | Preventive Maintenance Plans | C | INTERNAL |
| [`MNT_WORK_ORDER`](#mnt_work_order) | أوامر العمل | Work Orders | C | INTERNAL |
| [`MNT_WO_TASK`](#mnt_wo_task) | مهام أمر العمل | Work Order Tasks | C | INTERNAL |
| [`MNT_WO_MATERIAL`](#mnt_wo_material) | مواد أمر العمل | Work Order Materials | C | INTERNAL |
| [`MNT_WO_LABOR`](#mnt_wo_labor) | عمالة أمر العمل | Work Order Labor | C | INTERNAL |
| [`MNT_DOWNTIME`](#mnt_downtime) | فترات التوقف | Asset Downtime | C | INTERNAL |

## MNT_SERVICE_CATEGORY

| البند | القيمة |
|---|---|
| الاسم العربي | فئات خدمات الصيانة |
| English | Service Categories |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
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
| 6 | `PARENT_CATEGORY_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_SERVICE_CATEGORY |  | إدخال المستخدم |  | الفئة الأم |
| 7 | `DEFAULT_PRIORITY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | LOW, NORMAL, HIGH, URGENT, EMERGENCY | إدخال المستخدم |  | الأولوية الافتراضية |
| 8 | `SLA_POLICY_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_SLA_POLICY |  | إدخال المستخدم |  | SLA |
| 9 | `SLA_HOURS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | زمن الإنجاز المستهدف بالساعات |
| 10 | `ICON` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | الأيقونة |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_TEAM

| البند | القيمة |
|---|---|
| الاسم العربي | فرق الصيانة |
| English | Maintenance Teams |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
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
| 7 | `SUPERVISOR_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | المشرف |
| 8 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | مقاول خارجي |
| 9 | `QUEUE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_QUEUE |  | إدخال المستخدم |  | قائمة العمل |
| 10 | `SPECIALTY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | التخصص |
| 11 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | هاتف الفريق |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_TECHNICIAN

| البند | القيمة |
|---|---|
| الاسم العربي | الفنيون |
| English | Technicians |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TEAM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MNT_TEAM |  | إدخال المستخدم |  | الفريق |
| 5 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 6 | `EXTERNAL_NAME` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | فني المقاول |
| 7 | `SKILLS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المهارات |
| 8 | `HOURLY_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تكلفة الساعة |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_SERVICE_CONTRACT

| البند | القيمة |
|---|---|
| الاسم العربي | عقود الصيانة |
| English | Service Contracts (AMC) |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 6 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 7 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 8 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 9 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 10 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 11 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | المقاول |
| 12 | `PROPERTY_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 13 | `SCOPE_TEXT` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النطاق |
| 14 | `CONTRACT_VALUE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | القيمة |
| 15 | `RESPONSE_SLA_HOURS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | زمن الاستجابة التعاقدي |
| 16 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | العقد |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, EXPIRED, TERMINATED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 19 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | بلاغات الصيانة |
| English | Maintenance Requests |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
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
| 7 | `CATEGORY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MNT_SERVICE_CATEGORY |  | إدخال المستخدم |  | الفئة |
| 8 | `PRIORITY_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | LOW, NORMAL, HIGH, URGENT, EMERGENCY | إدخال المستخدم |  | الأولوية |
| 9 | `REQUESTER_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المبلغ (مستأجر/نزيل) |
| 10 | `REQUESTER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المبلغ (مستخدم) |
| 11 | `CHANNEL_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PORTAL' |  | PORTAL, PHONE, EMAIL, FRONT_DESK, INSPECTION, PREVENTIVE, APP | إدخال المستخدم |  | القناة |
| 12 | `PROPERTY_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 13 | `UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 14 | `ROOM_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_ROOM |  | إدخال المستخدم |  | الغرفة الفندقية |
| 15 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 16 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | الموقع |
| 17 | `LEASE_ID` | معرف | `NUMBER(19)` |  |  | FK→PRP_LEASE |  | إدخال المستخدم |  | عقد الإيجار |
| 18 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | وصف المشكلة |
| 19 | `DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | موعد SLA |
| 20 | `CHARGEABLE_TO` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OWNER' |  | OWNER, LESSEE, WARRANTY, CONTRACTOR, INSURANCE | إدخال المستخدم |  | يحمل على |
| 21 | `SATISFACTION_SCORE` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | تقييم الرضا |
| 22 | `TITLE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | عنوان البلاغ |
| 23 | `REPORTER_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | اسم المبلغ (هاتف/بوابة) |
| 24 | `REPORTER_PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | جوال المبلغ |
| 25 | `TEAM_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_TEAM |  | إدخال المستخدم |  | الفريق المكلف |
| 26 | `TECHNICIAN_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_TECHNICIAN |  | إدخال المستخدم |  | الفني المكلف |
| 27 | `ROOM_OUT_OF_ORDER` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | أوقف الغرفة حتى الإصلاح |
| 28 | `RESPONDED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاستجابة (الإسناد) |
| 29 | `RESOLVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإنجاز |
| 30 | `RESOLUTION_NOTES` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ما تم عمله |
| 31 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NEW' |  | NEW, TRIAGED, ASSIGNED, IN_PROGRESS, ON_HOLD, COMPLETED, VERIFIED, CLOSED, CANCELLED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 32 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 33 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 34 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 35 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 36 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_PM_PLAN

| البند | القيمة |
|---|---|
| الاسم العربي | خطط الصيانة الوقائية |
| English | Preventive Maintenance Plans |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
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
| 7 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 8 | `PROPERTY_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 9 | `CATEGORY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MNT_SERVICE_CATEGORY |  | إدخال المستخدم |  | الفئة |
| 10 | `FREQUENCY_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DAYS, WEEKS, MONTHS, METER, HOURS | إدخال المستخدم |  | نوع التكرار |
| 11 | `FREQUENCY_VALUE` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | القيمة |
| 12 | `NEXT_DUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | الاستحقاق التالي |
| 13 | `TEAM_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_TEAM |  | إدخال المستخدم |  | الفريق |
| 14 | `SERVICE_CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_SERVICE_CONTRACT |  | إدخال المستخدم |  | العقد |
| 15 | `CHECKLIST` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | قائمة الفحص |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, SUSPENDED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_WORK_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر العمل |
| English | Work Orders |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
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
| 7 | `REQUEST_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_REQUEST |  | إدخال المستخدم |  | البلاغ |
| 8 | `PM_PLAN_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_PM_PLAN |  | إدخال المستخدم |  | الخطة الوقائية |
| 9 | `WO_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CORRECTIVE, PREVENTIVE, INSPECTION, EMERGENCY, PROJECT, FIT_OUT | إدخال المستخدم |  | النوع |
| 10 | `TEAM_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_TEAM |  | إدخال المستخدم |  | الفريق |
| 11 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | المقاول |
| 12 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 13 | `UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 14 | `PLANNED_START` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية المخططة |
| 15 | `PLANNED_END` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية المخططة |
| 16 | `ACTUAL_START` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية الفعلية |
| 17 | `ACTUAL_END` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية الفعلية |
| 18 | `ESTIMATED_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة التقديرية |
| 19 | `ACTUAL_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | محسوب |  | التكلفة الفعلية |
| 20 | `CAPITALIZE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يرسمل على الأصل (قرار مستقل) |
| 21 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 22 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 23 | `COMPLETION_NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات الإنجاز |
| 24 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, APPROVED, SCHEDULED, IN_PROGRESS, ON_HOLD, COMPLETED, VERIFIED, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 25 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 26 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 27 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 28 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 29 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 30 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_WO_TASK

| البند | القيمة |
|---|---|
| الاسم العربي | مهام أمر العمل |
| English | Work Order Tasks |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `WORK_ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MNT_WORK_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `TASK_TEXT` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المهمة |
| 6 | `TECHNICIAN_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_TECHNICIAN |  | إدخال المستخدم |  | الفني |
| 7 | `RESULT_TEXT` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النتيجة |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, DONE, SKIPPED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_WO_MATERIAL

| البند | القيمة |
|---|---|
| الاسم العربي | مواد أمر العمل |
| English | Work Order Materials |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `WORK_ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MNT_WORK_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 6 | `PLANNED_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المخطط |
| 7 | `ISSUED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المصروف |
| 8 | `RETURNED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرتجع |
| 9 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 10 | `INV_TRANSACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | حركة الصرف |
| 11 | `UNIT_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_WO_LABOR

| البند | القيمة |
|---|---|
| الاسم العربي | عمالة أمر العمل |
| English | Work Order Labor |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | HOURS > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `WORK_ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MNT_WORK_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `TECHNICIAN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MNT_TECHNICIAN |  | إدخال المستخدم |  | الفني |
| 6 | `WORK_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 7 | `HOURS` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الساعات |
| 8 | `COST_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MNT_DOWNTIME

| البند | القيمة |
|---|---|
| الاسم العربي | فترات التوقف |
| English | Asset Downtime |
| الحزمة المالكة | 18 — `NOONA_MAINTENANCE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | ENDED_AT IS NULL OR ENDED_AT >= STARTED_AT |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 5 | `UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 6 | `WORK_ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_WORK_ORDER |  | إدخال المستخدم |  | أمر العمل |
| 7 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 8 | `ENDED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 9 | `REASON_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

