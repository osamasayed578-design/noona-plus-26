# قاموس البيانات — الحزمة 14: الأصول الثابتة

**Fixed Assets** · الحزمة البرمجية المالكة `NOONA_ASSETS_PKG` · ملف DDL `db/ddl/p14_fa.sql` · [ERD](../erd/p14_fa.md)

الفئات والدفاتر المالية والضريبية، والأصل ومكوناته، والاقتناء والرسملة، وجداول الإهلاك لكل أصل/دفتر/فترة، والنقل وإعادة التقييم والانخفاض والاستبعاد والجرد، مع منع الرسملة المكررة.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`FA_BOOK`](#fa_book) | دفاتر الأصول | Asset Books | C | INTERNAL |
| [`FA_CATEGORY`](#fa_category) | فئات الأصول | Asset Categories | C | INTERNAL |
| [`FA_ASSET`](#fa_asset) | الأصول | Fixed Assets | C | INTERNAL |
| [`FA_ASSET_BOOK`](#fa_asset_book) | الأصل في الدفاتر | Asset Book Values | C | INTERNAL |
| [`FA_TRANSACTION`](#fa_transaction) | حركات الأصول | Asset Transactions | C | INTERNAL |
| [`FA_DEPRECIATION_RUN`](#fa_depreciation_run) | عمليات الإهلاك | Depreciation Runs | C | INTERNAL |
| [`FA_DEPRECIATION_LINE`](#fa_depreciation_line) | أسطر الإهلاك | Depreciation Lines | C | INTERNAL |
| [`FA_TRANSFER`](#fa_transfer) | نقل الأصول | Asset Transfers | C | INTERNAL |
| [`FA_DISPOSAL`](#fa_disposal) | استبعاد الأصول | Asset Disposals | C | INTERNAL |
| [`FA_COUNT`](#fa_count) | جرد الأصول | Asset Physical Counts | C | INTERNAL |
| [`FA_COUNT_LINE`](#fa_count_line) | أسطر جرد الأصول | Asset Count Lines | C | INTERNAL |

## FA_BOOK

| البند | القيمة |
|---|---|
| الاسم العربي | دفاتر الأصول |
| English | Asset Books |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
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
| 7 | `BOOK_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'FINANCIAL' |  | FINANCIAL, TAX, IFRS, LOCAL | إدخال المستخدم |  | النوع |
| 8 | `LEDGER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_LEDGER |  | إدخال المستخدم |  | الدفتر المحاسبي |
| 9 | `CALENDAR_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_FISCAL_CALENDAR |  | إدخال المستخدم |  | التقويم |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_CATEGORY

| البند | القيمة |
|---|---|
| الاسم العربي | فئات الأصول |
| English | Asset Categories |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
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
| 7 | `PARENT_CATEGORY_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_CATEGORY |  | إدخال المستخدم |  | الفئة الأم |
| 8 | `DEPRECIATION_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'STRAIGHT_LINE' |  | STRAIGHT_LINE, DECLINING_BALANCE, DOUBLE_DECLINING, UNITS_OF_PRODUCTION, NONE | إدخال المستخدم |  | الطريقة |
| 9 | `USEFUL_LIFE_MONTHS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | العمر الإنتاجي |
| 10 | `RESIDUAL_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | القيمة المتبقية % |
| 11 | `CAPITALIZATION_THRESHOLD` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأدنى للرسملة |
| 12 | `PRORATE_CONVENTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DAILY' |  | DAILY, FULL_MONTH, MID_MONTH, NEXT_MONTH | إدخال المستخدم |  | قاعدة احتساب الجزء |
| 13 | `ASSET_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الأصل |
| 14 | `ACCUM_DEPR_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | مجمع الإهلاك |
| 15 | `DEPR_EXPENSE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | مصروف الإهلاك |
| 16 | `CIP_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | مشروعات تحت التنفيذ |
| 17 | `GAIN_LOSS_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | أرباح/خسائر الاستبعاد |
| 18 | `POLICY_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | إصدار السياسة |
| 19 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_ASSET

| البند | القيمة |
|---|---|
| الاسم العربي | الأصول |
| English | Fixed Assets |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, COMPANY_ID, ASSET_NO) |
| مفاتيح فريدة مشروطة | NUK1: (TENANT_ID, AP_INVOICE_LINE_ID) عند عدم فراغ AP_INVOICE_LINE_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 8 | `ASSET_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الأصل الثابت |
| 9 | `TAG_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الملصق/الباركود |
| 10 | `CATEGORY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_CATEGORY |  | إدخال المستخدم |  | الفئة |
| 11 | `PARENT_ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل الأم (المكونات) |
| 12 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | الموقع |
| 13 | `LOCATION_TEXT` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الموقع التفصيلي |
| 14 | `CUSTODIAN_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | المسؤول/العهدة |
| 15 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 16 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 17 | `PROPERTY_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 18 | `UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة العقارية |
| 19 | `ACQUISITION_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الاقتناء |
| 20 | `IN_SERVICE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التشغيل/بدء الإهلاك |
| 21 | `ORIGINAL_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة الأصلية |
| 22 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 23 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | المورد |
| 24 | `AP_INVOICE_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_INVOICE_LINE NUK1 |  | إدخال المستخدم |  | سطر الفاتورة المرسملة (يمنع الرسملة مرتين) |
| 25 | `SERIAL_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرقم التسلسلي |
| 26 | `MANUFACTURER` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الصانع |
| 27 | `MODEL_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الموديل |
| 28 | `WARRANTY_END` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | نهاية الضمان |
| 29 | `CONTRACT_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | العقد/المستند |
| 30 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, CIP, CAPITALIZED, IN_SERVICE, SUSPENDED, FULLY_DEPRECIATED, DISPOSED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 31 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 32 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 33 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 34 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 35 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_ASSET_BOOK

| البند | القيمة |
|---|---|
| الاسم العربي | الأصل في الدفاتر |
| English | Asset Book Values |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (ASSET_ID, BOOK_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ASSET_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_ASSET UK2 |  | إدخال المستخدم |  | الأصل |
| 5 | `BOOK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_BOOK UK2 |  | إدخال المستخدم |  | الدفتر |
| 6 | `COST` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | التكلفة |
| 7 | `RESIDUAL_VALUE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | القيمة المتبقية |
| 8 | `DEPRECIATION_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | STRAIGHT_LINE, DECLINING_BALANCE, DOUBLE_DECLINING, UNITS_OF_PRODUCTION, NONE | إدخال المستخدم |  | الطريقة |
| 9 | `USEFUL_LIFE_MONTHS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | العمر |
| 10 | `DEPR_START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | بداية الإهلاك |
| 11 | `ACCUMULATED_DEPR` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | النظام/الحزمة |  | مجمع الإهلاك |
| 12 | `NET_BOOK_VALUE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | محسوب |  | صافي القيمة الدفترية |
| 13 | `LAST_DEPR_PERIOD_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_PERIOD |  | إدخال المستخدم |  | آخر فترة إهلاك |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, FULLY_DEPRECIATED, DISPOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_TRANSACTION

| البند | القيمة |
|---|---|
| الاسم العربي | حركات الأصول |
| English | Asset Transactions |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, DOC_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `ASSET_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 7 | `BOOK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_BOOK |  | إدخال المستخدم |  | الدفتر |
| 8 | `TXN_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ADDITION, CAPITALIZATION, COST_ADJUSTMENT, LIFE_CHANGE, TRANSFER, REVALUATION, IMPAIRMENT, PARTIAL_RETIREMENT, DISPOSAL, REINSTATEMENT | إدخال المستخدم |  | النوع |
| 9 | `TXN_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ الحركة |
| 10 | `AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ |
| 11 | `OLD_VALUES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | القيم السابقة |
| 12 | `NEW_VALUES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | القيم الجديدة |
| 13 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 14 | `EXPERT_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | تقرير الخبير (إعادة التقييم) |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, POSTED, REVERSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 17 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 18 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 19 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_DEPRECIATION_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات الإهلاك |
| English | Depreciation Runs |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يرفض التشغيل المكرر لنفس الفترة |
| مفاتيح فريدة | UK2: (BOOK_ID, PERIOD_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BOOK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_BOOK UK2 |  | إدخال المستخدم |  | الدفتر |
| 5 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD UK2 |  | إدخال المستخدم |  | الفترة |
| 6 | `METHOD_VERSION` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | إصدار طريقة الحساب |
| 7 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي |
| 8 | `JOURNAL_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL |  | إدخال المستخدم |  | القيد |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, CALCULATED, POSTED, REVERSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_DEPRECIATION_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر الإهلاك |
| English | Depreciation Lines |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (ASSET_BOOK_ID, PERIOD_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RUN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_DEPRECIATION_RUN |  | إدخال المستخدم |  | العملية |
| 5 | `ASSET_BOOK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_ASSET_BOOK UK1 |  | إدخال المستخدم |  | الأصل/الدفتر |
| 6 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD UK1 |  | إدخال المستخدم |  | الفترة |
| 7 | `DEPRECIATION_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | إهلاك الفترة |
| 8 | `ACCUMULATED_AFTER` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المجمع بعد |
| 9 | `NBV_AFTER` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الصافي بعد |
| 10 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_TRANSFER

| البند | القيمة |
|---|---|
| الاسم العربي | نقل الأصول |
| English | Asset Transfers |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, DOC_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `ASSET_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 7 | `FROM_BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | من فرع |
| 8 | `TO_BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | إلى فرع |
| 9 | `FROM_SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | من موقع |
| 10 | `TO_SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | إلى موقع |
| 11 | `FROM_CUSTODIAN_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | من عهدة |
| 12 | `TO_CUSTODIAN_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | إلى عهدة |
| 13 | `TO_COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | إلى شركة (معاملة قانونية ومحاسبية) |
| 14 | `TRANSFER_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 15 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_DISPOSAL

| البند | القيمة |
|---|---|
| الاسم العربي | استبعاد الأصول |
| English | Asset Disposals |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, DOC_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `ASSET_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 7 | `DISPOSAL_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SALE, DONATION, SCRAP, LOSS, THEFT, TRADE_IN | إدخال المستخدم |  | الطريقة |
| 8 | `DISPOSAL_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 9 | `PROCEEDS` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المتحصلات |
| 10 | `NBV_AT_DISPOSAL` | مبلغ | `NUMBER(24,6)` |  |  |  |  | محسوب |  | الصافي عند الاستبعاد |
| 11 | `GAIN_LOSS` | مبلغ | `NUMBER(24,6)` |  |  |  |  | محسوب |  | الربح/الخسارة |
| 12 | `BUYER_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المشتري |
| 13 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | فاتورة البيع |
| 14 | `EVIDENCE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الإثبات |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, POSTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 17 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 18 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 19 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_COUNT

| البند | القيمة |
|---|---|
| الاسم العربي | جرد الأصول |
| English | Asset Physical Counts |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 7 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | الموقع |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, IN_PROGRESS, REVIEW, APPROVED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## FA_COUNT_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر جرد الأصول |
| English | Asset Count Lines |
| الحزمة المالكة | 14 — `NOONA_ASSETS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `COUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→FA_COUNT |  | إدخال المستخدم |  | الجرد |
| 5 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 6 | `SCANNED_TAG` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرمز الممسوح |
| 7 | `FOUND_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FOUND, NOT_FOUND, FOUND_ELSEWHERE, UNREGISTERED, DAMAGED, NOT_IN_USE | إدخال المستخدم |  | النتيجة |
| 8 | `OBSERVED_LOCATION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الموقع الفعلي |
| 9 | `NOTES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

