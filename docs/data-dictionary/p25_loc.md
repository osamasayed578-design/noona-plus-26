# قاموس البيانات — الحزمة 25: حزم الدول والتوطين والضرائب

**Country Packs, Localization & Tax Engine** · الحزمة البرمجية المالكة `NOONA_LOCALIZATION_PKG` · ملف DDL `db/ddl/p25_loc.sql` · [ERD](../erd/p25_loc.md)

Country Pack لكل دولة بإصدارات مؤرخة (السعودية، الإمارات، قطر، عمان، البحرين، الكويت، السودان)، ومحرك الضرائب المركزي (تحديد ← قواعد ← احتساب ← محاسبة ← إقرار/فاتورة إلكترونية) وطبقة الفوترة الإلكترونية بمحولات مستقلة لكل دولة. القواعد إعدادات ذات إصدارات وليست قيماً ثابتة في PL/SQL.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`LOC_COUNTRY_PACK`](#loc_country_pack) | حزم الدول | Country Packs | G | INTERNAL |
| [`LOC_LEGAL_FORM`](#loc_legal_form) | الأشكال القانونية | Legal Entity Forms | G | INTERNAL |
| [`LOC_REGISTRATION_TYPE`](#loc_registration_type) | أنواع التسجيلات القانونية | Registration Types | TO | INTERNAL |
| [`LOC_TAX_TYPE`](#loc_tax_type) | أنواع الضرائب | Tax Types | TO | INTERNAL |
| [`LOC_TAX_CODE`](#loc_tax_code) | أكواد الضرائب | Tax Codes | TO | INTERNAL |
| [`LOC_TAX_RATE`](#loc_tax_rate) | إصدارات نسب الضرائب | Tax Rate Versions | TO | INTERNAL |
| [`LOC_TAX_RULE`](#loc_tax_rule) | قواعد تحديد الضريبة | Tax Determination Rules | TO | INTERNAL |
| [`LOC_TAX_ACCOUNT`](#loc_tax_account) | حسابات الضرائب للشركة | Company Tax Accounts | C | INTERNAL |
| [`LOC_TAX_EXEMPTION`](#loc_tax_exemption) | شهادات الإعفاء الضريبي | Tax Exemption Certificates | T | INTERNAL |
| [`LOC_TAX_LINE`](#loc_tax_line) | أسطر الضرائب المحتسبة | Tax Lines (Engine Output) | C | INTERNAL |
| [`LOC_TAX_RETURN`](#loc_tax_return) | الإقرارات الضريبية | Tax Returns | C | INTERNAL |
| [`LOC_TAX_RETURN_LINE`](#loc_tax_return_line) | خانات الإقرار | Tax Return Boxes | T | INTERNAL |
| [`LOC_WITHHOLDING_CERT`](#loc_withholding_cert) | شهادات الاستقطاع | Withholding Certificates | C | INTERNAL |
| [`LOC_EINVOICE_PROFILE`](#loc_einvoice_profile) | إعدادات الفوترة الإلكترونية | E-Invoicing Profiles | C | INTERNAL |
| [`LOC_EINVOICE_SUBMISSION`](#loc_einvoice_submission) | إرسالات الفوترة الإلكترونية | E-Invoice Submissions | C | INTERNAL |

## LOC_COUNTRY_PACK

| البند | القيمة |
|---|---|
| الاسم العربي | حزم الدول |
| English | Country Packs |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (COUNTRY_CODE, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` | ✔ |  | FK→REF_COUNTRY UK1 |  | إدخال المستخدم |  | الدولة |
| 6 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الإصدار |
| 7 | `EFFECTIVE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ السريان |
| 8 | `LEGAL_REFERENCE` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع القانوني |
| 9 | `DISPLAY_CALENDAR` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GREGORIAN' |  | GREGORIAN, HIJRI_UMM_ALQURA, BOTH | إدخال المستخدم |  | تقويم العرض الرسمي |
| 10 | `REVIEWED_BY_EXPERT` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المختص المحلي المراجع (شرط قبل الإنتاج) |
| 11 | `PUBLISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت النشر |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, CONFIGURING, TESTING, UAT, APPROVED, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_LEGAL_FORM

| البند | القيمة |
|---|---|
| الاسم العربي | الأشكال القانونية |
| English | Legal Entity Forms |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (COUNTRY_PACK_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_COUNTRY_PACK UK1 |  | إدخال المستخدم |  | الحزمة |
| 6 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_REGISTRATION_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع التسجيلات القانونية |
| English | Registration Types |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COUNTRY_PACK_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_COUNTRY_PACK UK1 |  | إدخال المستخدم |  | الحزمة |
| 7 | `APPLIES_TO` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'COMPANY' |  | COMPANY, BRANCH, PARTY, PROPERTY, PROJECT | إدخال المستخدم |  | ينطبق على |
| 8 | `IS_MANDATORY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | إلزامي قبل التفعيل |
| 9 | `IS_TAX_REGISTRATION` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تسجيل ضريبي |
| 10 | `VALIDATION_REGEX` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | نمط التحقق من الرقم |
| 11 | `EXPIRY_ALERT_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | التنبيه قبل الانتهاء |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع الضرائب |
| English | Tax Types |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COUNTRY_PACK_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_COUNTRY_PACK UK1 |  | إدخال المستخدم |  | الحزمة |
| 7 | `TAX_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | VAT, SALES, EXCISE, WITHHOLDING, CUSTOMS, ZAKAT, MUNICIPAL, STAMP, PAYROLL, REAL_ESTATE, SERVICE, OTHER | إدخال المستخدم |  | الفئة |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_CODE

| البند | القيمة |
|---|---|
| الاسم العربي | أكواد الضرائب |
| English | Tax Codes |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, TAX_TYPE_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `TAX_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_TYPE UK1 |  | إدخال المستخدم |  | نوع الضريبة |
| 7 | `TAX_NATURE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | STANDARD, ZERO_RATED, EXEMPT, OUT_OF_SCOPE, REVERSE_CHARGE, WITHHOLDING, CUSTOM | إدخال المستخدم |  | الطبيعة |
| 8 | `CALC_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PERCENT' |  | PERCENT, FIXED_AMOUNT, PER_UNIT, COMPOUND | إدخال المستخدم |  | طريقة الحساب |
| 9 | `IS_INCLUSIVE_DEFAULT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مضمنة في السعر افتراضياً |
| 10 | `RECOVERABLE_PCT` | نسبة | `NUMBER(9,6)` | ✔ | 100 |  |  | إدخال المستخدم |  | نسبة الاسترداد للمشتريات |
| 11 | `ROUNDING_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'LINE' |  | LINE, TAX, DOCUMENT | إدخال المستخدم |  | مستوى التقريب |
| 12 | `SHOW_ON_INVOICE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يظهر في الفاتورة |
| 13 | `REPORT_BOX_CODE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | خانة الإقرار |
| 14 | `EINVOICE_CATEGORY` | نص | `VARCHAR2(10 CHAR)` |  |  |  |  | إدخال المستخدم |  | فئة الفاتورة الإلكترونية (S/Z/E/O...) |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_RATE

| البند | القيمة |
|---|---|
| الاسم العربي | إصدارات نسب الضرائب |
| English | Tax Rate Versions |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | الفواتير المرحلة تبقى على القاعدة السارية وقت الإصدار |
| مفاتيح فريدة | UK1: (TAX_CODE_ID, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `TAX_CODE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_CODE UK1 |  | إدخال المستخدم |  | الكود |
| 4 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الإصدار (لا تعدل القاعدة القديمة) |
| 5 | `RATE_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | النسبة |
| 6 | `FIXED_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ الثابت |
| 7 | `MIN_BASE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأدنى للأساس |
| 8 | `MAX_BASE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأعلى |
| 9 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 10 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 11 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد تحديد الضريبة |
| English | Tax Determination Rules |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_COUNTRY_PACK |  | إدخال المستخدم |  | الحزمة |
| 7 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 8 | `PRIORITY_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 100 |  |  | إدخال المستخدم |  | الأولوية |
| 9 | `TRANSACTION_CLASS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SALES, PURCHASE, REAL_ESTATE, PROJECT, ASSET, EXPENSE, PAYROLL, IMPORT, EXPORT | إدخال المستخدم |  | فئة المعاملة |
| 10 | `CONDITIONS` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | الشروط (الدولة، مكان التوريد، تسجيل الأطراف، المنتج، المشروع...) |
| 11 | `RESULT_TAX_CODE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الكود الناتج |
| 12 | `EXPLANATION_AR` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الاختيار المعروض للمستخدم |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, TESTED, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 15 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_ACCOUNT

| البند | القيمة |
|---|---|
| الاسم العربي | حسابات الضرائب للشركة |
| English | Company Tax Accounts |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, TAX_CODE_ID, EFFECTIVE_FROM) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TAX_CODE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_CODE UK1 |  | إدخال المستخدم |  | الكود |
| 5 | `PAYABLE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | ضريبة مستحقة الدفع |
| 6 | `RECOVERABLE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | ضريبة قابلة للاسترداد |
| 7 | `NON_RECOVERABLE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | ضريبة غير مستردة |
| 8 | `WITHHOLDING_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | ضريبة مستقطعة |
| 9 | `ROUNDING_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | فروق التقريب |
| 10 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) | UK1 |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 11 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_EXEMPTION

| البند | القيمة |
|---|---|
| الاسم العربي | شهادات الإعفاء الضريبي |
| English | Tax Exemption Certificates |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا يطبق إعفاء منتهٍ على معاملة جديدة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CERTIFICATE_NO` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | رقم الشهادة |
| 4 | `EXEMPTION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PARTY, PRODUCT, SERVICE, PROJECT, CONTRACT, GOVERNMENT, TEMPORAL | إدخال المستخدم |  | النوع |
| 5 | `PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف |
| 6 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 7 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 8 | `TAX_CODE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الكود البديل المطبق |
| 9 | `ISSUING_AUTHORITY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجهة |
| 10 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, ACTIVE, EXPIRED, REVOKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر الضرائب المحتسبة |
| English | Tax Lines (Engine Output) |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | محرك واحد لكل الوحدات؛ تحفظ القاعدة والسبب لإعادة الإنتاج |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE |
| 5 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة) |
| 6 | `SOURCE_LINE_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | سطر المصدر |
| 7 | `TAX_CODE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الكود |
| 8 | `TAX_RATE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_RATE |  | إدخال المستخدم |  | إصدار النسبة المطبق |
| 9 | `TAX_RULE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_RULE |  | إدخال المستخدم |  | القاعدة المطبقة |
| 10 | `EXEMPTION_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_EXEMPTION |  | إدخال المستخدم |  | الإعفاء |
| 11 | `TAX_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ الضريبة |
| 12 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 13 | `TAXABLE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الأساس |
| 14 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الضريبة |
| 15 | `TAX_AMOUNT_FUNC` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | بالعملة الوظيفية |
| 16 | `RECOVERABLE_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | القابل للاسترداد |
| 17 | `IS_INCLUSIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مضمنة |
| 18 | `IS_MANUAL_OVERRIDE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تعديل يدوي (يتطلب صلاحية وسبباً) |
| 19 | `OVERRIDE_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 20 | `TAX_RETURN_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_RETURN |  | إدخال المستخدم |  | الإقرار الذي شملها |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_RETURN

| البند | القيمة |
|---|---|
| الاسم العربي | الإقرارات الضريبية |
| English | Tax Returns |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, TAX_TYPE_ID, PERIOD_START) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TAX_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_TYPE UK2 |  | إدخال المستخدم |  | نوع الضريبة |
| 5 | `REGISTRATION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_LEGAL_REGISTRATION |  | إدخال المستخدم |  | التسجيل الضريبي |
| 6 | `PERIOD_START` | تاريخ | `DATE` | ✔ |  | UK2 |  | إدخال المستخدم |  | بداية الفترة |
| 7 | `PERIOD_END` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | نهاية الفترة |
| 8 | `OUTPUT_TAX` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | ضريبة المخرجات |
| 9 | `INPUT_TAX` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | ضريبة المدخلات |
| 10 | `NET_PAYABLE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الصافي |
| 11 | `CARRY_FORWARD` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المرحل |
| 12 | `FILED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التقديم |
| 13 | `GOV_REFERENCE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع الجهة الحكومية |
| 14 | `FILING_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | نسخة الإقرار |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, REVIEWED, APPROVED, FILED, PAID, CLOSED, REOPENED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_TAX_RETURN_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | خانات الإقرار |
| English | Tax Return Boxes |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TAX_RETURN_ID, BOX_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `TAX_RETURN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_RETURN UK1 |  | إدخال المستخدم |  | الإقرار |
| 4 | `BOX_CODE` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الخانة |
| 5 | `BASE_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الأساس |
| 6 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الضريبة |
| 7 | `ADJUSTMENT_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التعديلات |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_WITHHOLDING_CERT

| البند | القيمة |
|---|---|
| الاسم العربي | شهادات الاستقطاع |
| English | Withholding Certificates |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, CERTIFICATE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CERTIFICATE_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرقم |
| 5 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المورد/المقاول |
| 6 | `TAX_CODE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الكود |
| 7 | `BASE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الأساس |
| 8 | `WITHHELD_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المستقطع |
| 9 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 10 | `DUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ استحقاق التوريد |
| 11 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الشهادة |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ISSUED, PAID, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_EINVOICE_PROFILE

| البند | القيمة |
|---|---|
| الاسم العربي | إعدادات الفوترة الإلكترونية |
| English | E-Invoicing Profiles |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_COUNTRY_PACK |  | إدخال المستخدم |  | الحزمة |
| 6 | `ADAPTER_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المحول (ZATCA، FTA...) |
| 7 | `INTEGRATION_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | REPORTING, CLEARANCE, REALTIME, BATCH | إدخال المستخدم |  | النمط |
| 8 | `DEVICE_ID` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الجهاز/الحل المسجل |
| 9 | `CERTIFICATE_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع الشهادة في Vault |
| 10 | `ENDPOINT_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع نقطة الاتصال |
| 11 | `IS_SANDBOX` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | بيئة اختبار |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ONBOARDING, ACTIVE, SUSPENDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## LOC_EINVOICE_SUBMISSION

| البند | القيمة |
|---|---|
| الاسم العربي | إرسالات الفوترة الإلكترونية |
| English | E-Invoice Submissions |
| الحزمة المالكة | 25 — `NOONA_LOCALIZATION_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, IDEMPOTENCY_KEY)<br>UK3: (TENANT_ID, INVOICE_UUID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE |
| 5 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة) |
| 6 | `PROFILE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_EINVOICE_PROFILE |  | إدخال المستخدم |  | الإعداد |
| 7 | `INVOICE_UUID` | نص | `VARCHAR2(64 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | UUID الفاتورة |
| 8 | `INVOICE_COUNTER` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | العداد التسلسلي (ICV) |
| 9 | `INVOICE_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash الفاتورة |
| 10 | `PREVIOUS_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash الفاتورة السابقة (سلسلة) |
| 11 | `QR_PAYLOAD` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | محتوى QR |
| 12 | `GOV_REFERENCE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع الحكومي |
| 13 | `ATTEMPTS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحاولات |
| 14 | `NEXT_RETRY_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | المحاولة التالية |
| 15 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | منع الإرسال المكرر |
| 16 | `REQUEST_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الطلب المرسل كما هو (XML) |
| 17 | `RESPONSE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الاستجابة كما وردت |
| 18 | `LEGAL_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | النسخة القانونية المعتمدة (لا يعاد توليدها) |
| 19 | `ERROR_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | أخطاء التحقق/الرفض |
| 20 | `SUBMITTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإرسال |
| 21 | `RESPONDED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاستجابة |
| 22 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, VALIDATED, READY_TO_SUBMIT, SUBMITTED, ACCEPTED, CLEARED, REJECTED, VALIDATION_FAILED, SUBMISSION_FAILED, PENDING_RETRY, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 23 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 24 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 25 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 26 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 27 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

