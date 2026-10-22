# قاموس البيانات — الحزمة 06: البيانات المرجعية المشتركة والأطراف

**Shared Reference Data & Global Party Model** · الحزمة البرمجية المالكة `NOONA_REFERENCE_PKG` · ملف DDL `db/ddl/p06_ref.sql` · [ERD](../erd/p06_ref.md)

اللغات والدول والعملات وأسعار الصرف والتسلسلات والقيم المرجعية القابلة للإعداد (BR-008)، ونموذج الطرف الموحد Global Party الذي يمنع تكرار الأشخاص والجهات بين العملاء والموردين والموظفين.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`REF_LANGUAGE`](#ref_language) | اللغات | Languages | G | INTERNAL |
| [`REF_CURRENCY`](#ref_currency) | العملات | Currencies | G | INTERNAL |
| [`REF_COUNTRY`](#ref_country) | الدول | Countries | G | INTERNAL |
| [`REF_CITY`](#ref_city) | المدن والمناطق | Cities / Regions | G | INTERNAL |
| [`REF_TIMEZONE`](#ref_timezone) | المناطق الزمنية | Time Zones | G | INTERNAL |
| [`REF_ENTITY_TYPE`](#ref_entity_type) | سجل أنواع الكيانات | Entity Type Registry | G | INTERNAL |
| [`REF_LOOKUP_TYPE`](#ref_lookup_type) | أنواع القوائم المرجعية | Lookup Types | TO | INTERNAL |
| [`REF_LOOKUP_VALUE`](#ref_lookup_value) | قيم القوائم المرجعية | Lookup Values | TO | INTERNAL |
| [`REF_TRANSLATION`](#ref_translation) | الترجمات الإضافية | Translations | TO | INTERNAL |
| [`REF_RATE_TYPE`](#ref_rate_type) | أنواع أسعار الصرف | Exchange Rate Types | T | INTERNAL |
| [`REF_EXCHANGE_RATE`](#ref_exchange_rate) | أسعار الصرف | Exchange Rates | T | INTERNAL |
| [`REF_DOC_SEQUENCE`](#ref_doc_sequence) | تسلسلات ترقيم المستندات | Document Sequences | C | INTERNAL |
| [`REF_DOC_NUMBER_LOG`](#ref_doc_number_log) | سجل الأرقام المخصصة | Document Number Allocation Log | T | INTERNAL |
| [`REF_PAYMENT_TERM`](#ref_payment_term) | شروط الدفع | Payment Terms | T | INTERNAL |
| [`REF_PAYMENT_TERM_LINE`](#ref_payment_term_line) | أقساط شرط الدفع | Payment Term Installments | T | INTERNAL |
| [`REF_PAYMENT_METHOD`](#ref_payment_method) | طرق الدفع | Payment Methods | T | INTERNAL |
| [`REF_BANK`](#ref_bank) | البنوك | Banks | TO | INTERNAL |
| [`PTY_PARTY`](#pty_party) | الأطراف (الهوية الموحدة) | Party | T | CONFIDENTIAL |
| [`PTY_PERSON`](#pty_person) | بيانات الشخص الطبيعي | Person | T | CONFIDENTIAL |
| [`PTY_ORGANIZATION`](#pty_organization) | بيانات الجهة الاعتبارية | Organization | T | INTERNAL |
| [`PTY_IDENTIFICATION`](#pty_identification) | وثائق هوية الطرف | Party Identifications | T | HIGHLY_RESTRICTED |
| [`PTY_PARTY_ROLE`](#pty_party_role) | أدوار الطرف | Party Roles | T | INTERNAL |
| [`PTY_RELATIONSHIP`](#pty_relationship) | العلاقات بين الأطراف | Party Relationships | T | INTERNAL |
| [`PTY_ALIAS`](#pty_alias) | الأسماء البديلة للطرف | Party Aliases | T | INTERNAL |
| [`PTY_MERGE_REQUEST`](#pty_merge_request) | طلبات دمج الأطراف | Party Merge Requests | T | INTERNAL |
| [`PTY_BANK_ACCOUNT`](#pty_bank_account) | الحسابات البنكية للأطراف | Party Bank Accounts | T | HIGHLY_RESTRICTED |
| [`REF_ADDRESS`](#ref_address) | العناوين | Addresses | T | INTERNAL |
| [`REF_CONTACT`](#ref_contact) | جهات ووسائل الاتصال | Contacts | T | CONFIDENTIAL |
| [`REF_RECORD_SHARE`](#ref_record_share) | مشاركة البيانات الأساسية بين الشركات | Master Data Sharing | T | INTERNAL |

## REF_LANGUAGE

| البند | القيمة |
|---|---|
| الاسم العربي | اللغات |
| English | Languages |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | اللغات المدعومة؛ العربية والإنجليزية كاملتان والبنية تسمح بلغات إضافية |
| مفاتيح فريدة | UK1: (LANGUAGE_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 3 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 4 | `LANGUAGE_CODE` | نص | `VARCHAR2(10 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز اللغة (ar, en ...) |
| 5 | `DIRECTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'RTL' |  | RTL, LTR | إدخال المستخدم |  | اتجاه الكتابة |
| 6 | `IS_FULL_UI` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | لغة واجهة كاملة؟ (العربية والإنجليزية في V1) |
| 7 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 8 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_CURRENCY

| البند | القيمة |
|---|---|
| الاسم العربي | العملات |
| English | Currencies |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | تعريف العملات والدقة؛ لا يفترض النظام منزلتين عشريتين (12.9) |
| مفاتيح فريدة | UK1: (CURRENCY_CODE) |
| قيود أعمال | DECIMAL_PLACES BETWEEN 0 AND 6 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 3 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 4 | `CURRENCY_CODE` | نص | `VARCHAR2(3 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز ISO 4217 |
| 5 | `NUMERIC_CODE` | نص | `VARCHAR2(3 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرمز الرقمي ISO |
| 6 | `SYMBOL` | نص | `VARCHAR2(10 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرمز المرئي |
| 7 | `DECIMAL_PLACES` | عدد صحيح | `NUMBER(10)` | ✔ | 2 |  |  | إدخال المستخدم |  | عدد المنازل العشرية (0 لـJPY، 3 لـKWD/BHD/OMR) |
| 8 | `MINOR_UNIT_AR` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | اسم الوحدة الفرعية بالعربية |
| 9 | `MINOR_UNIT_EN` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | اسم الوحدة الفرعية بالإنجليزية |
| 10 | `ROUNDING_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'HALF_UP' |  | HALF_UP, HALF_EVEN, UP, DOWN | إدخال المستخدم |  | طريقة التقريب |
| 11 | `MIN_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | أقل مبلغ متداول |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_COUNTRY

| البند | القيمة |
|---|---|
| الاسم العربي | الدول |
| English | Countries |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (COUNTRY_CODE)<br>UK2: (ISO3_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 3 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 4 | `COUNTRY_CODE` | نص | `VARCHAR2(2 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز ISO 3166-1 alpha-2 |
| 5 | `ISO3_CODE` | نص | `VARCHAR2(3 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رمز ISO alpha-3 |
| 6 | `DEFAULT_CURRENCY` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة الافتراضية للدولة |
| 7 | `DEFAULT_LANGUAGE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة الافتراضية |
| 8 | `DEFAULT_TIMEZONE` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | المنطقة الزمنية الافتراضية IANA |
| 9 | `PHONE_PREFIX` | نص | `VARCHAR2(10 CHAR)` |  |  |  |  | إدخال المستخدم |  | مفتاح الاتصال الدولي |
| 10 | `SHOW_HIJRI` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | عرض التاريخ الهجري افتراضياً |
| 11 | `LOCALIZATION_RANK` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب بناء Country Pack المعتمد (1=السعودية ... 7=السودان) |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_CITY

| البند | القيمة |
|---|---|
| الاسم العربي | المدن والمناطق |
| English | Cities / Regions |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (COUNTRY_CODE, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` | ✔ |  | FK→REF_COUNTRY UK1 |  | إدخال المستخدم |  | الدولة |
| 6 | `PARENT_CITY_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_CITY |  | إدخال المستخدم |  | المنطقة/المحافظة الأم |
| 7 | `LEVEL_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CITY' |  | REGION, PROVINCE, CITY, DISTRICT | إدخال المستخدم |  | مستوى التقسيم الإداري |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_TIMEZONE

| البند | القيمة |
|---|---|
| الاسم العربي | المناطق الزمنية |
| English | Time Zones |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TIMEZONE_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TIMEZONE_CODE` | نص | `VARCHAR2(64 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | اسم IANA مثل Asia/Riyadh |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم العربي |
| 4 | `UTC_OFFSET` | نص | `VARCHAR2(6 CHAR)` |  |  |  |  | إدخال المستخدم |  | الإزاحة القياسية (للعرض فقط) |
| 5 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 6 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 9 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 10 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_ENTITY_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | سجل أنواع الكيانات |
| English | Entity Type Registry |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Entity Type Registry (المرحلة 10): لا تقبل قيم ENTITY_TYPE حرة؛ كل ربط عام يرجع لهذا السجل |
| مفاتيح فريدة | UK1: (ENTITY_TYPE_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 3 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 4 | `ENTITY_TYPE_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز نوع الكيان الثابت (مثل SAL_INVOICE) |
| 5 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحزمة المالكة |
| 6 | `TABLE_NAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الجدول الفعلي |
| 7 | `VALIDATION_API` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | دالة التحقق الخادمي من وجود الكيان وصلاحيته |
| 8 | `ALLOW_DMS_LINK` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يقبل ربط مستندات؟ |
| 9 | `ALLOW_COR_LINK` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يقبل ربط مراسلات؟ |
| 10 | `HAS_COMPANY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | الكيان مقيد بشركة؟ |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_LOOKUP_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع القوائم المرجعية |
| English | Lookup Types |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, LOOKUP_TYPE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 6 | `LOOKUP_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز نوع القائمة |
| 7 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحزمة |
| 8 | `IS_SYSTEM` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | قيم نظامية لا يعدلها Tenant |
| 9 | `IS_EXTENSIBLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يسمح للمؤسسة بإضافة قيم |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_LOOKUP_VALUE

| البند | القيمة |
|---|---|
| الاسم العربي | قيم القوائم المرجعية |
| English | Lookup Values |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | القيم القابلة لاختلاف المؤسسة تحفظ كـLookups (BR-008)؛ TENANT_ID فارغ = قيمة منصة |
| مفاتيح فريدة | UK1: (TENANT_ID, LOOKUP_TYPE, LOOKUP_CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `LOOKUP_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | نوع القائمة |
| 6 | `LOOKUP_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز القيمة (السلوك يرتبط بالرمز لا بالنص) |
| 7 | `PARENT_VALUE_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_LOOKUP_VALUE |  | إدخال المستخدم |  | قيمة أم (قوائم هرمية) |
| 8 | `ATTRIBUTES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | خصائص إضافية للقيمة |
| 9 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 10 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_TRANSLATION

| البند | القيمة |
|---|---|
| الاسم العربي | الترجمات الإضافية |
| English | Translations |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لغات إضافية مستقبلية دون تغيير الجداول (العربية/الإنجليزية في أعمدة NAME_AR/NAME_EN) |
| مفاتيح فريدة | UK1: (TENANT_ID, TABLE_NAME, ROW_ID, COLUMN_NAME, LANGUAGE_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `TABLE_NAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الجدول |
| 4 | `ROW_ID` | معرف | `NUMBER(19)` | ✔ |  | UK1 |  | إدخال المستخدم |  | معرف الصف |
| 5 | `COLUMN_NAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | العمود |
| 6 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` | ✔ |  | FK→REF_LANGUAGE UK1 |  | إدخال المستخدم |  | اللغة |
| 7 | `TRANSLATED_TEXT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النص المترجم |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_RATE_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع أسعار الصرف |
| English | Exchange Rate Types |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يسمح بأكثر من نوع سعر وأكثر من سعر في اليوم (احتياج السودان) |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `RATE_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | OFFICIAL, CENTRAL_BANK, BANK, BUY, SELL, MARKET, CONTRACT, CUSTOMS, AVERAGE, CLOSING, CONSOLIDATION, MANUAL | إدخال المستخدم |  | فئة السعر |
| 7 | `REQUIRES_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يحتاج اعتماد قبل الاستخدام |
| 8 | `MAX_DEVIATION_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | أقصى انحراف مسموح عن السعر السابق قبل التنبيه |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_EXCHANGE_RATE

| البند | القيمة |
|---|---|
| الاسم العربي | أسعار الصرف |
| English | Exchange Rates |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تتغير المعاملات القديمة عند تعديل الجدول؛ المعاملة تحفظ سعرها |
| مفاتيح فريدة | UK1: (TENANT_ID, RATE_TYPE_ID, FROM_CURRENCY, TO_CURRENCY, EFFECTIVE_AT) |
| قيود أعمال | RATE > 0<br>FROM_CURRENCY <> TO_CURRENCY |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `RATE_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→REF_RATE_TYPE UK1 |  | إدخال المستخدم |  | نوع السعر |
| 4 | `FROM_CURRENCY` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY UK1 |  | إدخال المستخدم |  | من عملة |
| 5 | `TO_CURRENCY` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY UK1 |  | إدخال المستخدم |  | إلى عملة |
| 6 | `RATE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ السعر |
| 7 | `EFFECTIVE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  | UK1 |  | إدخال المستخدم |  | وقت السريان (يسمح بأكثر من سعر في اليوم) |
| 8 | `RATE` | سعر/معدل | `NUMBER(28,12)` | ✔ |  |  |  | إدخال المستخدم |  | السعر (الاتجاه الرئيسي المعتمد للمؤسسة) |
| 9 | `INVERSE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | محسوب |  | السعر العكسي المحسوب |
| 10 | `SOURCE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MANUAL' |  | MANUAL, IMPORT, API | إدخال المستخدم |  | مصدر السعر |
| 11 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 12 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإدخال/التعديل اليدوي |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SUPERSEDED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_DOC_SEQUENCE

| البند | القيمة |
|---|---|
| الاسم العربي | تسلسلات ترقيم المستندات |
| English | Document Sequences |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | تسلسلات مستقلة لكل شركة/فرع/نوع/سنة؛ تخصيص الرقم عبر NOONA_REFERENCE_PKG مع قفل الصف |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, BRANCH_ID, DOC_TYPE_CODE, FISCAL_YEAR) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH UK2 |  | إدخال المستخدم |  | الفرع |
| 5 | `DOC_TYPE_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | نوع المستند (SAL_INVOICE، GL_JOURNAL...) |
| 6 | `FISCAL_YEAR` | عدد صحيح | `NUMBER(10)` |  |  | UK2 |  | إدخال المستخدم |  | السنة المالية (فارغ = تسلسل مستمر) |
| 7 | `PREFIX` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | البادئة |
| 8 | `SUFFIX` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | اللاحقة |
| 9 | `NEXT_NUMBER` | رقم | `NUMBER` | ✔ | 1 |  |  | إدخال المستخدم |  | الرقم التالي |
| 10 | `PADDING` | عدد صحيح | `NUMBER(10)` | ✔ | 6 |  |  | إدخال المستخدم |  | عدد خانات الرقم |
| 11 | `IS_GAPLESS` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تسلسل قانوني بدون فجوات (الفواتير الضريبية) |
| 12 | `RESET_POLICY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'YEARLY' |  | NEVER, YEARLY, MONTHLY | إدخال المستخدم |  | سياسة إعادة البدء |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_DOC_NUMBER_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل الأرقام المخصصة |
| English | Document Number Allocation Log |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| مفاتيح فريدة | UK1: (TENANT_ID, SEQUENCE_ID, ALLOCATED_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `SEQUENCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→REF_DOC_SEQUENCE UK1 |  | إدخال المستخدم |  | التسلسل |
| 4 | `ALLOCATED_NO` | نص | `VARCHAR2(80 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرقم المخصص |
| 5 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع الكيان |
| 6 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف الكيان |
| 7 | `ALLOCATION_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'USED' |  | USED, VOIDED | إدخال المستخدم |  | حالة الرقم (الأرقام الملغاة لا يعاد استخدامها) |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## REF_PAYMENT_TERM

| البند | القيمة |
|---|---|
| الاسم العربي | شروط الدفع |
| English | Payment Terms |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
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
| 6 | `BASE_DATE_RULE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DOC_DATE' |  | DOC_DATE, DELIVERY_DATE, END_OF_MONTH, RECEIPT_DATE | إدخال المستخدم |  | تاريخ الأساس |
| 7 | `DUE_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | أيام الاستحقاق (للدفعة الواحدة) |
| 8 | `EARLY_DISCOUNT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | خصم السداد المبكر |
| 9 | `EARLY_DISCOUNT_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مهلة خصم السداد المبكر |
| 10 | `IS_INSTALLMENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | شرط أقساط |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_PAYMENT_TERM_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أقساط شرط الدفع |
| English | Payment Term Installments |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PAYMENT_TERM_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PAYMENT_TERM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→REF_PAYMENT_TERM UK1 |  | إدخال المستخدم |  | شرط الدفع |
| 4 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم القسط |
| 5 | `DUE_PCT` | نسبة | `NUMBER(9,6)` | ✔ |  |  |  | إدخال المستخدم |  | نسبة القسط من الإجمالي |
| 6 | `DUE_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | الأيام من تاريخ الأساس |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_PAYMENT_METHOD

| البند | القيمة |
|---|---|
| الاسم العربي | طرق الدفع |
| English | Payment Methods |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
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
| 6 | `METHOD_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CASH, BANK_TRANSFER, CHEQUE, CARD, WALLET, GATEWAY, DIRECT_DEBIT, OFFSET, CREDIT | إدخال المستخدم |  | نوع الطريقة |
| 7 | `REQUIRES_REFERENCE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب مرجعاً خارجياً |
| 8 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض في نقطة البيع |
| 9 | `ICON_CLASS` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | أيقونة الزر |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_BANK

| البند | القيمة |
|---|---|
| الاسم العربي | البنوك |
| English | Banks |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
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
| 6 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` | ✔ |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | دولة البنك |
| 7 | `SWIFT_BIC` | نص | `VARCHAR2(11 CHAR)` |  |  |  |  | إدخال المستخدم |  | رمز SWIFT/BIC |
| 8 | `LOCAL_BANK_CODE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرمز المحلي |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_PARTY

| البند | القيمة |
|---|---|
| الاسم العربي | الأطراف (الهوية الموحدة) |
| English | Party |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Global Party Model: هوية واحدة لكل شخص/جهة مع أدوار متعددة (عميل/مورد/موظف/مالك/مستأجر...) |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, PARTY_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `PARTY_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الطرف داخل المؤسسة |
| 5 | `PARTY_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PERSON, ORGANIZATION | إدخال المستخدم |  | شخص طبيعي أو جهة |
| 6 | `DISPLAY_NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم المعروض بالعربية |
| 7 | `DISPLAY_NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم المعروض بالإنجليزية |
| 8 | `OWNERSHIP_SCOPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'TENANT_SHARED' |  | TENANT_SHARED, GROUP_SHARED, COMPANY_OWNED, BRANCH_OWNED | إدخال المستخدم |  | نطاق ملكية السجل (12.6) |
| 9 | `OWNER_GROUP_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_GROUP |  | إدخال المستخدم |  | المجموعة المالكة عند GROUP_SHARED |
| 10 | `OWNER_COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المالكة عند COMPANY_OWNED |
| 11 | `OWNER_BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع المالك عند BRANCH_OWNED |
| 12 | `TAX_NUMBER` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | الرقم الضريبي الرئيسي (لكشف التكرار) |
| 13 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | دولة الطرف |
| 14 | `PREFERRED_LANGUAGE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | لغة التواصل |
| 15 | `RISK_CLASS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | تصنيف المخاطر |
| 16 | `MERGED_INTO_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | السجل الباقي Survivor بعد الدمج |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE, BLOCKED, MERGED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_PERSON

| البند | القيمة |
|---|---|
| الاسم العربي | بيانات الشخص الطبيعي |
| English | Person |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, PARTY_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY UK1 |  | إدخال المستخدم |  | الطرف |
| 4 | `FIRST_NAME_AR` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم | ✔ | الاسم الأول بالعربية |
| 5 | `SECOND_NAME_AR` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | اسم الأب |
| 6 | `THIRD_NAME_AR` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | اسم الجد |
| 7 | `LAST_NAME_AR` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | اسم العائلة |
| 8 | `FIRST_NAME_EN` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | First name |
| 9 | `LAST_NAME_EN` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | Last name |
| 10 | `GENDER` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | M, F | إدخال المستخدم |  | الجنس |
| 11 | `BIRTH_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم | ✔ | تاريخ الميلاد |
| 12 | `NATIONALITY` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الجنسية |
| 13 | `MARITAL_STATUS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | الحالة الاجتماعية |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_ORGANIZATION

| البند | القيمة |
|---|---|
| الاسم العربي | بيانات الجهة الاعتبارية |
| English | Organization |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, PARTY_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY UK1 |  | إدخال المستخدم |  | الطرف |
| 4 | `LEGAL_NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم القانوني بالعربية |
| 5 | `LEGAL_NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم القانوني بالإنجليزية |
| 6 | `TRADE_NAME_AR` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم التجاري |
| 7 | `ORG_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع الجهة (شركة، حكومية، جمعية...) |
| 8 | `CR_NUMBER` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | السجل التجاري |
| 9 | `INDUSTRY_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | النشاط/القطاع |
| 10 | `IS_GOVERNMENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | جهة حكومية |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_IDENTIFICATION

| البند | القيمة |
|---|---|
| الاسم العربي | وثائق هوية الطرف |
| English | Party Identifications |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, ID_TYPE_CODE, ID_NUMBER_HASH) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف |
| 4 | `ID_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 | NATIONAL_ID, IQAMA, PASSPORT, CR, TAX, VAT, DRIVING_LICENSE, OTHER | إدخال المستخدم |  | نوع الوثيقة |
| 5 | `ID_NUMBER_MASKED` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرقم مقنعاً للعرض |
| 6 | `ID_NUMBER_HASH` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | Hash للمطابقة وكشف التكرار دون كشف الرقم |
| 7 | `ID_NUMBER_ENC` | GUID | `RAW(16)` |  |  |  |  | إدخال المستخدم |  | مرجع القيمة المشفرة في المخزن الآمن |
| 8 | `ISSUING_COUNTRY` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | دولة الإصدار |
| 9 | `ISSUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإصدار |
| 10 | `EXPIRY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الانتهاء (يولد تنبيهاً) |
| 11 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | صورة الوثيقة في DMS |
| 12 | `IS_PRIMARY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | الوثيقة الرئيسية |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, EXPIRED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_PARTY_ROLE

| البند | القيمة |
|---|---|
| الاسم العربي | أدوار الطرف |
| English | Party Roles |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, PARTY_ID, ROLE_CODE, COMPANY_ID) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY UK1 |  | إدخال المستخدم |  | الطرف |
| 4 | `ROLE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | CUSTOMER, SUPPLIER, EMPLOYEE, OWNER, TENANT_CONTACT, CONTRACTOR, PARTNER, LANDLORD, LESSEE, GUEST, BUYER, BROKER, BANK, GOVERNMENT_AUTHORITY, OTHER | إدخال المستخدم |  | الدور |
| 5 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY UK1 |  | إدخال المستخدم |  | الشركة التي ينطبق فيها الدور (فارغ = كل المؤسسة) |
| 6 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, SUSPENDED, ENDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 7 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 8 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_RELATIONSHIP

| البند | القيمة |
|---|---|
| الاسم العربي | العلاقات بين الأطراف |
| English | Party Relationships |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>FROM_PARTY_ID <> TO_PARTY_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `FROM_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف الأول |
| 4 | `TO_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف الثاني |
| 5 | `RELATION_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | نوع العلاقة (موظف لدى، ممثل عن، كفيل...) |
| 6 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 7 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_ALIAS

| البند | القيمة |
|---|---|
| الاسم العربي | الأسماء البديلة للطرف |
| English | Party Aliases |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف |
| 4 | `ALIAS_NAME` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم البديل/السابق |
| 5 | `ALIAS_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FORMER_NAME, TRADE_NAME, MERGED_RECORD, TRANSLITERATION | إدخال المستخدم |  | نوع الاسم |
| 6 | `SOURCE_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | السجل المدموج الأصلي |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_MERGE_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات دمج الأطراف |
| English | Party Merge Requests |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | الدمج يقترح ولا ينفذ تلقائياً؛ يحتاج Workflow ولا يكسر المراجع التاريخية |
| قيود أعمال | SURVIVOR_PARTY_ID <> MERGED_PARTY_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `SURVIVOR_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | السجل الباقي |
| 4 | `MERGED_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | السجل المدموج |
| 5 | `MATCH_SCORE` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | درجة التطابق المقترحة |
| 6 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 7 | `EXECUTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التنفيذ |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, EXECUTED, REJECTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PTY_BANK_ACCOUNT

| البند | القيمة |
|---|---|
| الاسم العربي | الحسابات البنكية للأطراف |
| English | Party Bank Accounts |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | بيانات بنك الموردين والموظفين؛ تغييرها يتطلب Maker-Checker وتنبيه الحركات القريبة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | صاحب الحساب |
| 4 | `BANK_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_BANK |  | إدخال المستخدم |  | البنك |
| 5 | `ACCOUNT_NAME` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم | ✔ | اسم صاحب الحساب |
| 6 | `IBAN_MASKED` | نص | `VARCHAR2(40 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | IBAN مقنع للعرض |
| 7 | `IBAN_HASH` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | Hash لكشف التكرار |
| 8 | `IBAN_ENC_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع القيمة المشفرة في Vault (لا تخزن القيمة الصريحة) |
| 9 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة الحساب |
| 10 | `VERIFIED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المتحقق (Maker-Checker: لا يكون نفس المنشئ) |
| 11 | `VERIFIED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التحقق |
| 12 | `VERIFICATION_CHANNEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | قناة التحقق المستقلة |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING_VERIFICATION' |  | PENDING_VERIFICATION, VERIFIED, ACTIVE, SUSPENDED, REJECTED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 15 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_ADDRESS

| البند | القيمة |
|---|---|
| الاسم العربي | العناوين |
| English | Addresses |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | عناوين مؤرخة متعددة الأنواع (قوس حصري: شركة أو فرع أو موقع أو طرف) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>(CASE WHEN COMPANY_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN BRANCH_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN SITE_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN PARTY_ID IS NOT NULL THEN 1 ELSE 0 END) = 1 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | عنوان شركة |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | عنوان فرع |
| 5 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | عنوان موقع |
| 6 | `PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | عنوان طرف |
| 7 | `ADDRESS_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | LEGAL, CORRESPONDENCE, BILLING, SHIPPING, TAX, OPERATING, HOME, OTHER | إدخال المستخدم |  | نوع العنوان |
| 8 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` | ✔ |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 9 | `CITY_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_CITY |  | إدخال المستخدم |  | المدينة |
| 10 | `DISTRICT` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحي |
| 11 | `STREET` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الشارع |
| 12 | `BUILDING_NO` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم المبنى |
| 13 | `ADDITIONAL_NO` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرقم الإضافي (العنوان الوطني) |
| 14 | `POSTAL_CODE` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرمز البريدي |
| 15 | `ADDRESS_LINE_AR` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان الكامل بالعربية |
| 16 | `ADDRESS_LINE_EN` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان الكامل بالإنجليزية |
| 17 | `LATITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط العرض |
| 18 | `LONGITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط الطول |
| 19 | `IS_PRIMARY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | العنوان الرئيسي لنوعه |
| 20 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 21 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_CONTACT

| البند | القيمة |
|---|---|
| الاسم العربي | جهات ووسائل الاتصال |
| English | Contacts |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>(CASE WHEN COMPANY_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN BRANCH_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN SITE_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN PARTY_ID IS NOT NULL THEN 1 ELSE 0 END) = 1 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | جهة اتصال لشركة |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | جهة اتصال لفرع |
| 5 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | جهة اتصال لموقع |
| 6 | `PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | جهة اتصال لطرف |
| 7 | `CONTACT_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | LEGAL, FINANCIAL, TECHNICAL, EMERGENCY, MANAGEMENT, SALES, GENERAL | إدخال المستخدم |  | صفة الاتصال |
| 8 | `CONTACT_NAME` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | اسم الشخص |
| 9 | `JOB_TITLE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الصفة الوظيفية |
| 10 | `DEPARTMENT` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | القسم |
| 11 | `EMAIL` | نص | `VARCHAR2(320 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | البريد الإلكتروني |
| 12 | `PHONE` | نص | `VARCHAR2(40 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | الهاتف |
| 13 | `MOBILE` | نص | `VARCHAR2(40 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | الجوال |
| 14 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | لغة التواصل |
| 15 | `NOTIFY_CONSENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | موافقة على استقبال الإشعارات |
| 16 | `IS_PRIMARY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | جهة الاتصال الرئيسية |
| 17 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 18 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## REF_RECORD_SHARE

| البند | القيمة |
|---|---|
| الاسم العربي | مشاركة البيانات الأساسية بين الشركات |
| English | Master Data Sharing |
| الحزمة المالكة | 06 — `NOONA_REFERENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | المشاركة لا تمنح حق التعديل تلقائياً، ولا تتجاوز حدود Tenant (12.6) |
| مفاتيح فريدة | UK1: (TENANT_ID, ENTITY_TYPE, ENTITY_ID, COMPANY_ID) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | FK→REF_ENTITY_TYPE UK1 |  | إدخال المستخدم |  | نوع السجل المشترك (PTY_PARTY، INV_ITEM...) |
| 4 | `ENTITY_ID` | معرف | `NUMBER(19)` | ✔ |  | UK1 |  | إدخال المستخدم |  | معرف السجل |
| 5 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | إدخال المستخدم |  | الشركة الممنوحة |
| 6 | `CAN_READ` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | قراءة |
| 7 | `CAN_USE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | استخدام في المعاملات |
| 8 | `CAN_EDIT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تعديل (لا تمنح تلقائياً) |
| 9 | `ALLOW_LOCAL_COPY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بنسخة محلية |
| 10 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 11 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 12 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

