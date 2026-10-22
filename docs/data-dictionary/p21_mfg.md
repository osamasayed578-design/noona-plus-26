# قاموس البيانات — الحزمة 21: التصنيع

**Manufacturing** · الحزمة البرمجية المالكة `NOONA_MANUFACTURING_PKG` · ملف DDL `db/ddl/p21_mfg.sql` · [ERD](../erd/p21_mfg.md)

قوائم المواد BOM ومسارات التصنيع بإصدارات غير قابلة للتعديل بعد الاستخدام، وأوامر الإنتاج المثبتة على نسخة BOM/Routing، وصرف المواد والإنتاج والجودة والهالك، والعمل تحت التشغيل WIP والتكلفة والانحرافات، باستخدام طبقة المخزون المعتمدة دون سجلات موازية.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`MFG_WORK_CENTER`](#mfg_work_center) | مراكز العمل | Work Centers | C | INTERNAL |
| [`MFG_BOM`](#mfg_bom) | قوائم المواد | Bills of Materials | C | INTERNAL |
| [`MFG_BOM_LINE`](#mfg_bom_line) | مكونات قائمة المواد | BOM Components | C | INTERNAL |
| [`MFG_BOM_SUBSTITUTE`](#mfg_bom_substitute) | بدائل المكونات | Component Substitutes | C | INTERNAL |
| [`MFG_ROUTING`](#mfg_routing) | مسارات التصنيع | Routings | C | INTERNAL |
| [`MFG_ROUTING_OPERATION`](#mfg_routing_operation) | عمليات المسار | Routing Operations | C | INTERNAL |
| [`MFG_PRODUCTION_ORDER`](#mfg_production_order) | أوامر الإنتاج | Production Orders | C | INTERNAL |
| [`MFG_ORDER_MATERIAL`](#mfg_order_material) | مواد أمر الإنتاج | Order Material Requirements | C | INTERNAL |
| [`MFG_ORDER_OPERATION`](#mfg_order_operation) | عمليات أمر الإنتاج | Order Operations | C | INTERNAL |
| [`MFG_ORDER_OUTPUT`](#mfg_order_output) | استلام الإنتاج | Production Output Receipts | C | INTERNAL |
| [`MFG_QUALITY_INSPECTION`](#mfg_quality_inspection) | فحوصات الجودة | Quality Inspections | C | INTERNAL |
| [`MFG_WIP_COST`](#mfg_wip_cost) | تكاليف العمل تحت التشغيل | WIP Cost Accumulation | C | INTERNAL |
| [`MFG_VARIANCE`](#mfg_variance) | انحرافات التكلفة | Production Variances | C | INTERNAL |

## MFG_WORK_CENTER

| البند | القيمة |
|---|---|
| الاسم العربي | مراكز العمل |
| English | Work Centers |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 8 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | المصنع |
| 9 | `CAPACITY_HOURS_DAY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الطاقة اليومية بالساعات |
| 10 | `LABOR_RATE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | معدل العمالة/ساعة |
| 11 | `OVERHEAD_RATE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | معدل التحميل/ساعة |
| 12 | `MACHINE_RATE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | معدل الآلات/ساعة |
| 13 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 14 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل/الآلة |
| 15 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_BOM

| البند | القيمة |
|---|---|
| الاسم العربي | قوائم المواد |
| English | Bills of Materials |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | المنتج |
| 8 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الإصدار (لا يعدل بعد استخدامه في أمر) |
| 9 | `BOM_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PRODUCTION' |  | PRODUCTION, ENGINEERING, KIT, PHANTOM | إدخال المستخدم |  | النوع |
| 10 | `BASE_QUANTITY` | كمية | `NUMBER(24,6)` | ✔ | 1 |  |  | إدخال المستخدم |  | الكمية المرجعية |
| 11 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 12 | `IS_DEFAULT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | الافتراضية |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, PUBLISHED, OBSOLETE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 15 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_BOM_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | مكونات قائمة المواد |
| English | BOM Components |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | تمنع دورات مكون → منتج في الوصفات متعددة المستويات (تفحص في الحزمة) |
| مفاتيح فريدة | UK2: (BOM_ID, LINE_NO) |
| قيود أعمال | QUANTITY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_BOM UK2 |  | إدخال المستخدم |  | القائمة |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
| 6 | `COMPONENT_ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | المكون |
| 7 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية لكل كمية مرجعية |
| 8 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 9 | `SCRAP_PCT` | نسبة | `NUMBER(9,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الهالك المسموح |
| 10 | `OPERATION_SEQ` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | العملية المستهلكة |
| 11 | `IS_CO_PRODUCT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | منتج مشترك/ثانوي (مخرج) |
| 12 | `SUBSTITUTE_GROUP` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | مجموعة البدائل |
| 13 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_BOM_SUBSTITUTE

| البند | القيمة |
|---|---|
| الاسم العربي | بدائل المكونات |
| English | Component Substitutes |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (BOM_LINE_ID, SUBSTITUTE_ITEM_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BOM_LINE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_BOM_LINE UK1 |  | إدخال المستخدم |  | المكون |
| 5 | `SUBSTITUTE_ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM UK1 |  | إدخال المستخدم |  | البديل |
| 6 | `CONVERSION_FACTOR` | سعر/معدل | `NUMBER(28,12)` | ✔ | 1 |  |  | إدخال المستخدم |  | معامل الاستبدال |
| 7 | `PRIORITY_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | الأولوية |
| 8 | `REQUIRES_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يتطلب موافقة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_ROUTING

| البند | القيمة |
|---|---|
| الاسم العربي | مسارات التصنيع |
| English | Routings |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | المنتج |
| 8 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الإصدار |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, PUBLISHED, OBSOLETE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 11 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_ROUTING_OPERATION

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات المسار |
| English | Routing Operations |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (ROUTING_ID, OPERATION_SEQ) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ROUTING_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_ROUTING UK1 |  | إدخال المستخدم |  | المسار |
| 5 | `OPERATION_SEQ` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | التسلسل |
| 6 | `WORK_CENTER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_WORK_CENTER |  | إدخال المستخدم |  | مركز العمل |
| 7 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 8 | `SETUP_MINUTES` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | زمن الإعداد |
| 9 | `RUN_MINUTES_PER_UNIT` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | زمن التشغيل للوحدة |
| 10 | `QUALITY_CHECK` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | نقطة فحص جودة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_PRODUCTION_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر الإنتاج |
| English | Production Orders |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
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
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 7 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 8 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | المنتج |
| 9 | `BOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_BOM |  | إدخال المستخدم |  | نسخة BOM المثبتة |
| 10 | `ROUTING_ID` | معرف | `NUMBER(19)` |  |  | FK→MFG_ROUTING |  | إدخال المستخدم |  | نسخة المسار المثبتة |
| 11 | `PLANNED_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية المخططة |
| 12 | `COMPLETED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المنتج المقبول |
| 13 | `SCRAPPED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الهالك |
| 14 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 15 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع الاستلام |
| 16 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | المصنع |
| 17 | `SALES_ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_ORDER |  | إدخال المستخدم |  | أمر البيع المصدر |
| 18 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 19 | `PLANNED_START` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية المخططة |
| 20 | `PLANNED_END` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية المخططة |
| 21 | `ACTUAL_START` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية الفعلية |
| 22 | `ACTUAL_END` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية الفعلية |
| 23 | `ESTIMATED_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة التقديرية |
| 24 | `ACTUAL_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | محسوب |  | التكلفة الفعلية |
| 25 | `HOLD_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإيقاف/الإلغاء |
| 26 | `SOURCE_WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع صرف الخامات |
| 27 | `LOT_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | دفعة المنتج |
| 28 | `EXPIRY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | انتهاء صلاحية المنتج |
| 29 | `PRIORITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | LOW, NORMAL, HIGH, URGENT | إدخال المستخدم |  | الأولوية |
| 30 | `REQUIRES_QC` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب فحص جودة قبل الاستلام |
| 31 | `PARENT_ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→MFG_PRODUCTION_ORDER |  | إدخال المستخدم |  | الأمر الأب (مكون نصف مصنع) |
| 32 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 33 | `STD_UNIT_COST` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | التكلفة المعيارية للوحدة عند الإطلاق |
| 34 | `STD_COST_DETAIL` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | التكلفة المعيارية للوحدة لكل عنصر |
| 35 | `NOTES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 36 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, APPROVED, RELEASED, IN_PROGRESS, PARTIALLY_COMPLETED, COMPLETED, CLOSED, ON_HOLD, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 37 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 38 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 39 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 40 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 41 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 42 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 43 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 44 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 45 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_ORDER_MATERIAL

| البند | القيمة |
|---|---|
| الاسم العربي | مواد أمر الإنتاج |
| English | Order Material Requirements |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_PRODUCTION_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `BOM_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→MFG_BOM_LINE |  | إدخال المستخدم |  | سطر BOM |
| 6 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | المادة (أو البديل المعتمد) |
| 7 | `REQUIRED_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المطلوب |
| 8 | `RESERVED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحجوز |
| 9 | `ISSUED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المصروف |
| 10 | `RETURNED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرتجع |
| 11 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 12 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع الصرف |
| 13 | `IS_SUBSTITUTE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | بديل معتمد |
| 14 | `STD_UNIT_COST` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | التكلفة المعيارية للوحدة عند الإطلاق |
| 15 | `ISSUED_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | تكلفة المصروف الفعلية |
| 16 | `OPERATION_SEQ` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | العملية المستهلكة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_ORDER_OPERATION

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات أمر الإنتاج |
| English | Order Operations |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (ORDER_ID, OPERATION_SEQ) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_PRODUCTION_ORDER UK1 |  | إدخال المستخدم |  | الأمر |
| 5 | `OPERATION_SEQ` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | التسلسل |
| 6 | `WORK_CENTER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_WORK_CENTER |  | إدخال المستخدم |  | مركز العمل |
| 7 | `PLANNED_MINUTES` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المخطط |
| 8 | `ACTUAL_MINUTES` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الفعلي |
| 9 | `GOOD_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المقبول |
| 10 | `REWORK_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | إعادة العمل |
| 11 | `DOWNTIME_MINUTES` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | التوقف |
| 12 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | وصف العملية |
| 13 | `SETUP_MINUTES` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | زمن الإعداد المخطط |
| 14 | `RUN_MINUTES_PER_UNIT` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | زمن التشغيل للوحدة |
| 15 | `SCRAP_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الهالك |
| 16 | `QUALITY_CHECK` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | نقطة فحص جودة |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, IN_PROGRESS, COMPLETED, SKIPPED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_ORDER_OUTPUT

| البند | القيمة |
|---|---|
| الاسم العربي | استلام الإنتاج |
| English | Production Output Receipts |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | المنتج تحت الفحص لا يعد متاحاً للبيع قبل قبول الجودة |
| مفاتيح فريدة | UK2: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_PRODUCTION_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | المنتج/المنتج المشترك |
| 6 | `OUTPUT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MAIN' |  | MAIN, CO_PRODUCT, BY_PRODUCT, SCRAP | إدخال المستخدم |  | النوع |
| 7 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية |
| 8 | `LOT_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOT |  | إدخال المستخدم |  | الدفعة |
| 9 | `INV_TRANSACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | حركة الاستلام |
| 10 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | منع مضاعفة الحركة عند إعادة الإرسال |
| 11 | `OUTPUT_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإنتاج |
| 12 | `LOT_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الدفعة |
| 13 | `EXPIRY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 14 | `UNIT_COST` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | تكلفة الوحدة |
| 15 | `TOTAL_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING_QUALITY' |  | PENDING_QUALITY, ACCEPTED, REJECTED, POSTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_QUALITY_INSPECTION

| البند | القيمة |
|---|---|
| الاسم العربي | فحوصات الجودة |
| English | Quality Inspections |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→MFG_PRODUCTION_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `OUTPUT_ID` | معرف | `NUMBER(19)` |  |  | FK→MFG_ORDER_OUTPUT |  | إدخال المستخدم |  | الإنتاج |
| 6 | `PUR_RECEIPT_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_RECEIPT_LINE |  | إدخال المستخدم |  | أو استلام مشتريات |
| 7 | `INSPECTED_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المفحوص |
| 8 | `PASSED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الناجح |
| 9 | `FAILED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرفوض |
| 10 | `RESULTS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نتائج القياسات |
| 11 | `INSPECTION_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الفحص |
| 12 | `NOTES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات الفاحص |
| 13 | `INSPECTOR_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الفاحص |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, PASSED, FAILED, CONDITIONAL | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_WIP_COST

| البند | القيمة |
|---|---|
| الاسم العربي | تكاليف العمل تحت التشغيل |
| English | WIP Cost Accumulation |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE |
| 5 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة) |
| 6 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_PRODUCTION_ORDER |  | إدخال المستخدم |  | الأمر |
| 7 | `OPERATION_SEQ` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | العملية |
| 8 | `COST_ELEMENT` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MATERIAL, LABOR, MACHINE, OVERHEAD, SUBCONTRACT, SCRAP | إدخال المستخدم |  | عنصر التكلفة |
| 9 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 10 | `COST_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 11 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | إدخال المستخدم |  | الحدث المحاسبي |
| 12 | `ENTRY_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CHARGE' |  | CHARGE, RELIEF, VARIANCE | إدخال المستخدم |  | تحميل على الأمر / تخفيض بالإنتاج المستلم / تسوية الانحراف |
| 13 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 14 | `QUANTITY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الكمية |
| 15 | `MINUTES` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الدقائق |
| 16 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | البيان |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## MFG_VARIANCE

| البند | القيمة |
|---|---|
| الاسم العربي | انحرافات التكلفة |
| English | Production Variances |
| الحزمة المالكة | 21 — `NOONA_MANUFACTURING_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→MFG_PRODUCTION_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `VARIANCE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MATERIAL_USAGE, MATERIAL_PRICE, LABOR_EFFICIENCY, LABOR_RATE, OVERHEAD, YIELD, SCRAP_ABNORMAL | إدخال المستخدم |  | النوع |
| 6 | `STANDARD_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المعياري |
| 7 | `ACTUAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الفعلي |
| 8 | `VARIANCE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الانحراف |
| 9 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 10 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 11 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

