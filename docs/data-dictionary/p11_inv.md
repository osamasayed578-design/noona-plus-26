# قاموس البيانات — الحزمة 11: المخزون والبيانات السلعية

**Inventory & Item Master** · الحزمة البرمجية المالكة `NOONA_INVENTORY_PKG` · ملف DDL `db/ddl/p11_inv.sql` · [ERD](../erd/p11_inv.md)

الأصناف والوحدات وتحويلاتها المؤرخة، والمستودعات والمواقع، وتتبع Lot/Serial/Expiry، وحركات المخزون غير القابلة للتعديل (تصحح بعكس)، والحجوزات، وطبقات تكلفة FIFO والمتوسط المرجح، والجرد.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`INV_UOM_CLASS`](#inv_uom_class) | فئات وحدات القياس | UOM Classes | TO | INTERNAL |
| [`INV_UOM`](#inv_uom) | وحدات القياس | Units of Measure | TO | INTERNAL |
| [`INV_UOM_CONVERSION`](#inv_uom_conversion) | تحويلات الوحدات | UOM Conversions | T | INTERNAL |
| [`INV_ITEM_CATEGORY`](#inv_item_category) | فئات الأصناف | Item Categories | T | INTERNAL |
| [`INV_ITEM`](#inv_item) | الأصناف | Items | T | INTERNAL |
| [`INV_ITEM_BARCODE`](#inv_item_barcode) | باركود الأصناف | Item Barcodes | T | INTERNAL |
| [`INV_ITEM_COMPANY`](#inv_item_company) | إعدادات الصنف لكل شركة | Item Company Settings | C | INTERNAL |
| [`INV_WAREHOUSE`](#inv_warehouse) | المستودعات | Warehouses | C | INTERNAL |
| [`INV_LOCATION`](#inv_location) | مواقع التخزين | Storage Locations | C | INTERNAL |
| [`INV_LOT`](#inv_lot) | الدفعات | Lots / Batches | T | INTERNAL |
| [`INV_SERIAL`](#inv_serial) | الأرقام التسلسلية | Serial Numbers | T | INTERNAL |
| [`INV_TXN_TYPE`](#inv_txn_type) | أنواع الحركات المخزنية | Inventory Transaction Types | TO | INTERNAL |
| [`INV_TRANSACTION`](#inv_transaction) | حركات المخزون | Inventory Transactions | C | INTERNAL |
| [`INV_TRANSACTION_LINE`](#inv_transaction_line) | أسطر حركات المخزون | Inventory Transaction Lines | C | INTERNAL |
| [`INV_ONHAND`](#inv_onhand) | الأرصدة المتاحة | On-hand Balances | C | INTERNAL |
| [`INV_RESERVATION`](#inv_reservation) | الحجوزات | Reservations | C | INTERNAL |
| [`INV_COST_LAYER`](#inv_cost_layer) | طبقات التكلفة FIFO | FIFO Cost Layers | C | INTERNAL |
| [`INV_ITEM_COST`](#inv_item_cost) | متوسط تكلفة الصنف | Item Average Cost | C | INTERNAL |
| [`INV_COST_ADJUSTMENT`](#inv_cost_adjustment) | تسويات التكلفة | Cost Adjustments & Landed Cost | C | INTERNAL |
| [`INV_TRANSFER_ORDER`](#inv_transfer_order) | أوامر التحويل بين المستودعات | Transfer Orders | C | INTERNAL |
| [`INV_TRANSFER_ORDER_LINE`](#inv_transfer_order_line) | أسطر أوامر التحويل | Transfer Order Lines | C | INTERNAL |
| [`INV_COUNT`](#inv_count) | عمليات الجرد | Physical Counts | C | INTERNAL |
| [`INV_COUNT_LINE`](#inv_count_line) | أسطر الجرد | Count Lines | C | INTERNAL |

## INV_UOM_CLASS

| البند | القيمة |
|---|---|
| الاسم العربي | فئات وحدات القياس |
| English | UOM Classes |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
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
| 6 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_UOM

| البند | القيمة |
|---|---|
| الاسم العربي | وحدات القياس |
| English | Units of Measure |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
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
| 6 | `UOM_CLASS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM_CLASS |  | إدخال المستخدم |  | الفئة (وزن، طول، عدد...) |
| 7 | `IS_BASE_OF_CLASS` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | الوحدة الأساسية للفئة |
| 8 | `DECIMAL_PLACES` | عدد صحيح | `NUMBER(10)` | ✔ | 2 |  |  | إدخال المستخدم |  | الدقة |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_UOM_CONVERSION

| البند | القيمة |
|---|---|
| الاسم العربي | تحويلات الوحدات |
| English | UOM Conversions |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, ITEM_ID, FROM_UOM_ID, TO_UOM_ID, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>FACTOR > 0<br>FROM_UOM_ID <> TO_UOM_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM UK2 |  | إدخال المستخدم |  | الصنف (فارغ = تحويل عام) |
| 4 | `FROM_UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM UK2 |  | إدخال المستخدم |  | من وحدة |
| 5 | `TO_UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM UK2 |  | إدخال المستخدم |  | إلى وحدة |
| 6 | `FACTOR` | سعر/معدل | `NUMBER(28,12)` | ✔ |  |  |  | إدخال المستخدم |  | المعامل |
| 7 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK2 |  | إدخال المستخدم |  | الإصدار (لا يتغير معامل استعمل تاريخياً) |
| 8 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 9 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_ITEM_CATEGORY

| البند | القيمة |
|---|---|
| الاسم العربي | فئات الأصناف |
| English | Item Categories |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
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
| 6 | `PARENT_CATEGORY_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM_CATEGORY |  | إدخال المستخدم |  | الفئة الأم |
| 7 | `DEFAULT_COSTING_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | FIFO, WEIGHTED_AVERAGE, STANDARD | إدخال المستخدم |  | طريقة التكلفة الافتراضية |
| 8 | `DEFAULT_TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الضريبة الافتراضية |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_ITEM

| البند | القيمة |
|---|---|
| الاسم العربي | الأصناف |
| English | Items |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, ITEM_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 7 | `ITEM_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الصنف |
| 8 | `ITEM_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | STOCK, NON_STOCK, SERVICE, RAW_MATERIAL, SEMI_FINISHED, FINISHED_GOOD, CONSUMABLE, SPARE_PART, KIT, ASSET, REAL_ESTATE_UNIT | إدخال المستخدم |  | النوع |
| 9 | `CATEGORY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM_CATEGORY |  | إدخال المستخدم |  | الفئة |
| 10 | `BASE_UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة الأساسية |
| 11 | `TRACKING_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NONE' |  | NONE, LOT, SERIAL, LOT_AND_SERIAL | إدخال المستخدم |  | التتبع |
| 12 | `TRACK_EXPIRY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تتبع الصلاحية |
| 13 | `SHELF_LIFE_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة الصلاحية |
| 14 | `OWNERSHIP_SCOPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'TENANT_SHARED' |  | TENANT_SHARED, GROUP_SHARED, COMPANY_OWNED | إدخال المستخدم |  | نطاق الملكية |
| 15 | `OWNER_COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المالكة |
| 16 | `IS_SELLABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | قابل للبيع |
| 17 | `IS_PURCHASABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | قابل للشراء |
| 18 | `IS_MANUFACTURED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مصنع داخلياً |
| 19 | `ALLOW_NEGATIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بالرصيد السالب (ممنوع افتراضياً) |
| 20 | `WEIGHT_KG` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الوزن |
| 21 | `TAX_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الفئة الضريبية |
| 22 | `STORAGE_REQUIREMENTS` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | متطلبات التخزين (حرارة، جودة) |
| 23 | `ATTRIBUTES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | خصائص إضافية |
| 24 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, INACTIVE, OBSOLETE, BLOCKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 25 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 26 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 27 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 28 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 29 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_ITEM_BARCODE

| البند | القيمة |
|---|---|
| الاسم العربي | باركود الأصناف |
| English | Item Barcodes |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, BARCODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 4 | `BARCODE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الباركود |
| 5 | `UOM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 6 | `BARCODE_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | EAN13, EAN8, UPC, CODE128, QR, INTERNAL, SCALE | إدخال المستخدم |  | النوع |
| 7 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_ITEM_COMPANY

| البند | القيمة |
|---|---|
| الاسم العربي | إعدادات الصنف لكل شركة |
| English | Item Company Settings |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, ITEM_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM UK1 |  | إدخال المستخدم |  | الصنف |
| 5 | `COSTING_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'WEIGHTED_AVERAGE' |  | FIFO, WEIGHTED_AVERAGE, STANDARD | إدخال المستخدم |  | طريقة التكلفة (مؤرخة عبر Migration فقط) |
| 6 | `INVENTORY_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب المخزون |
| 7 | `COGS_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب تكلفة المبيعات |
| 8 | `REVENUE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الإيراد |
| 9 | `PURCHASE_TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | ضريبة الشراء |
| 10 | `SALES_TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | ضريبة البيع |
| 11 | `MIN_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأدنى |
| 12 | `MAX_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأعلى |
| 13 | `REORDER_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | كمية إعادة الطلب |
| 14 | `LEAD_TIME_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة التوريد |
| 15 | `STANDARD_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة المعيارية |
| 16 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_WAREHOUSE

| البند | القيمة |
|---|---|
| الاسم العربي | المستودعات |
| English | Warehouses |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 8 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | الموقع |
| 9 | `WAREHOUSE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MAIN' |  | MAIN, STORE, TRANSIT, QUARANTINE, CONSIGNMENT, PROJECT_SITE, PRODUCTION, VIRTUAL, DAMAGED | إدخال المستخدم |  | النوع |
| 10 | `MANAGER_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | أمين المستودع |
| 11 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع (مستودع موقع) |
| 12 | `ALLOW_NEGATIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بالسالب |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, BLOCKED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 15 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_LOCATION

| البند | القيمة |
|---|---|
| الاسم العربي | مواقع التخزين |
| English | Storage Locations |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (WAREHOUSE_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE UK2 |  | إدخال المستخدم |  | المستودع |
| 8 | `PARENT_LOCATION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOCATION |  | إدخال المستخدم |  | الموقع الأب (منطقة/ممر/رف) |
| 9 | `LOCATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'STORAGE' |  | RECEIVING, STORAGE, QUALITY, PICKING, SHIPPING, DAMAGED, STAGING | إدخال المستخدم |  | النوع |
| 10 | `DEFAULT_STOCK_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'AVAILABLE' |  | AVAILABLE, QUALITY, DAMAGED, BLOCKED | إدخال المستخدم |  | الحالة الافتراضية للمخزون |
| 11 | `CAPACITY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | السعة |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_LOT

| البند | القيمة |
|---|---|
| الاسم العربي | الدفعات |
| English | Lots / Batches |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, ITEM_ID, LOT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM UK2 |  | إدخال المستخدم |  | الصنف |
| 4 | `LOT_NO` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الدفعة |
| 5 | `SUPPLIER_LOT_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم دفعة المورد |
| 6 | `MANUFACTURE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإنتاج |
| 7 | `EXPIRY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الانتهاء |
| 8 | `ORIGIN_COUNTRY` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | بلد المنشأ |
| 9 | `QUALITY_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, ACCEPTED, REJECTED | إدخال المستخدم |  | الجودة |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, QUARANTINE, EXPIRED, BLOCKED, CONSUMED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_SERIAL

| البند | القيمة |
|---|---|
| الاسم العربي | الأرقام التسلسلية |
| English | Serial Numbers |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, ITEM_ID, SERIAL_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM UK2 |  | إدخال المستخدم |  | الصنف |
| 4 | `SERIAL_NO` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرقم التسلسلي |
| 5 | `LOT_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOT |  | إدخال المستخدم |  | الدفعة |
| 6 | `OWNER_COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المالكة |
| 7 | `CURRENT_WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | المستودع الحالي |
| 8 | `CURRENT_LOCATION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOCATION |  | إدخال المستخدم |  | الموقع الحالي |
| 9 | `WARRANTY_END` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | نهاية الضمان |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'IN_STOCK' |  | IN_STOCK, RESERVED, ISSUED, SOLD, RETURNED, SCRAPPED, IN_TRANSIT | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_TXN_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع الحركات المخزنية |
| English | Inventory Transaction Types |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |
| قيود أعمال | QTY_SIGN IN (-1, 0, 1) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `TXN_CLASS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | RECEIPT, ISSUE, TRANSFER_OUT, TRANSFER_IN, ADJUSTMENT_IN, ADJUSTMENT_OUT, COUNT_ADJUSTMENT, RETURN_IN, RETURN_OUT, MFG_ISSUE, MFG_RETURN, MFG_RECEIPT, SCRAP, STATUS_CHANGE, COST_ADJUSTMENT | إدخال المستخدم |  | الفئة |
| 7 | `QTY_SIGN` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | أثر الكمية (+1/-1/0) |
| 8 | `REQUIRES_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب اعتماداً |
| 9 | `DEFAULT_REASON_REQUIRED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب سبباً |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_TRANSACTION

| البند | القيمة |
|---|---|
| الاسم العربي | حركات المخزون |
| English | Inventory Transactions |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تعدل حركة مثبتة؛ تنشأ حركة عكس أو تصحيح |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |
| مفاتيح فريدة مشروطة | NUK1: (TENANT_ID, IDEMPOTENCY_KEY) عند عدم فراغ IDEMPOTENCY_KEY |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 7 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 8 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE |
| 9 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة) |
| 10 | `TXN_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_TXN_TYPE |  | إدخال المستخدم |  | النوع |
| 11 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | المستودع |
| 12 | `TO_WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | المستودع المستلم (التحويل) |
| 13 | `TRANSFER_ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSFER_ORDER |  | إدخال المستخدم |  | أمر التحويل |
| 14 | `ACCOUNTING_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ المحاسبي (منفصل عن الواقعي) |
| 15 | `REASON_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 16 | `REVERSAL_OF_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | الحركة المعكوسة |
| 17 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` |  |  | NUK1 |  | إدخال المستخدم |  | منع ازدواج حركة مصدرها حدث متكرر |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, POSTED, REVERSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 20 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 21 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 22 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 23 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 24 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 25 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 26 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 27 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_TRANSACTION_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر حركات المخزون |
| English | Inventory Transaction Lines |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الاحتفاظ | دائم؛ مرشح للتقسيم السنوي |
| مفاتيح فريدة | UK2: (TRANSACTION_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TRANSACTION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_TRANSACTION UK2 |  | إدخال المستخدم |  | الحركة |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
| 6 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 7 | `LOCATION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOCATION |  | إدخال المستخدم |  | الموقع |
| 8 | `LOT_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOT |  | إدخال المستخدم |  | الدفعة |
| 9 | `SERIAL_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_SERIAL |  | إدخال المستخدم |  | الرقم التسلسلي |
| 10 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية بوحدة الحركة |
| 11 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 12 | `CONVERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_UOM_CONVERSION |  | إدخال المستخدم |  | إصدار التحويل المستخدم |
| 13 | `BASE_QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية بالوحدة الأساسية (موقعة +/-) |
| 14 | `UNIT_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تكلفة الوحدة |
| 15 | `TOTAL_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة الإجمالية |
| 16 | `STOCK_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'AVAILABLE' |  | AVAILABLE, QUALITY, DAMAGED, BLOCKED, IN_TRANSIT, CONSIGNMENT | إدخال المستخدم |  | حالة المخزون |
| 17 | `OWNERSHIP_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OWNED' |  | OWNED, CONSIGNMENT_IN, CONSIGNMENT_OUT, THIRD_PARTY | إدخال المستخدم |  | الملكية |
| 18 | `COST_LAYER_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_COST_LAYER |  | إدخال المستخدم |  | طبقة FIFO المستهلكة/المنشأة |
| 19 | `SOURCE_LINE_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع سطر المستند المصدر |
| 20 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_ONHAND

| البند | القيمة |
|---|---|
| الاسم العربي | الأرصدة المتاحة |
| English | On-hand Balances |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | رصيد مشتق يعاد بناؤه من الحركات؛ يقفل الصف عند الصرف المتزامن |
| مفاتيح فريدة | UK1: (TENANT_ID, ITEM_ID, WAREHOUSE_ID, LOCATION_ID, LOT_ID, SERIAL_ID, STOCK_STATUS) |
| قيود أعمال | RESERVED_QTY >= 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM UK1 |  | إدخال المستخدم |  | الصنف |
| 5 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE UK1 |  | إدخال المستخدم |  | المستودع |
| 6 | `LOCATION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOCATION UK1 |  | إدخال المستخدم |  | الموقع |
| 7 | `LOT_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOT UK1 |  | إدخال المستخدم |  | الدفعة |
| 8 | `SERIAL_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_SERIAL UK1 |  | إدخال المستخدم |  | الرقم التسلسلي |
| 9 | `STOCK_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'AVAILABLE' | UK1 | AVAILABLE, QUALITY, DAMAGED, BLOCKED, IN_TRANSIT, CONSIGNMENT | إدخال المستخدم |  | الحالة |
| 10 | `ON_HAND_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الموجود |
| 11 | `RESERVED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحجوز |
| 12 | `LAST_TXN_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION_LINE |  | إدخال المستخدم |  | آخر حركة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_RESERVATION

| البند | القيمة |
|---|---|
| الاسم العربي | الحجوزات |
| English | Reservations |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | RESERVED_QTY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE |
| 5 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة) |
| 6 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 7 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | المستودع |
| 8 | `LOT_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOT |  | إدخال المستخدم |  | الدفعة |
| 9 | `SERIAL_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_SERIAL |  | إدخال المستخدم |  | الرقم التسلسلي |
| 10 | `RESERVED_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية (بالأساسية) |
| 11 | `CONSUMED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المستهلك |
| 12 | `PRIORITY_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 100 |  |  | إدخال المستخدم |  | الأولوية |
| 13 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 14 | `OWNER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | صاحب الطلب |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, PARTIALLY_CONSUMED, CONSUMED, RELEASED, EXPIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_COST_LAYER

| البند | القيمة |
|---|---|
| الاسم العربي | طبقات التكلفة FIFO |
| English | FIFO Cost Layers |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | REMAINING_QTY >= 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 5 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | المستودع (حسب مستوى التكلفة) |
| 6 | `RECEIPT_TXN_LINE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_TRANSACTION_LINE |  | إدخال المستخدم |  | حركة الاستلام المنشئة |
| 7 | `LAYER_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ الطبقة |
| 8 | `ORIGINAL_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية الأصلية |
| 9 | `REMAINING_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المتبقي |
| 10 | `UNIT_COST` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | تكلفة الوحدة |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, EXHAUSTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_ITEM_COST

| البند | القيمة |
|---|---|
| الاسم العربي | متوسط تكلفة الصنف |
| English | Item Average Cost |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, ITEM_ID, WAREHOUSE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM UK1 |  | إدخال المستخدم |  | الصنف |
| 5 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE UK1 |  | إدخال المستخدم |  | المستودع |
| 6 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة الوظيفية |
| 7 | `ON_HAND_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الكمية |
| 8 | `TOTAL_VALUE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | القيمة |
| 9 | `AVERAGE_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المتوسط المرجح |
| 10 | `LAST_TXN_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION_LINE |  | إدخال المستخدم |  | آخر حركة مؤثرة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_COST_ADJUSTMENT

| البند | القيمة |
|---|---|
| الاسم العربي | تسويات التكلفة |
| English | Cost Adjustments & Landed Cost |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
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
| 6 | `ADJUSTMENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | LANDED_COST, PRICE_VARIANCE, REVALUATION, CORRECTION | إدخال المستخدم |  | النوع |
| 7 | `RECEIPT_TXN_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | الاستلام المعني |
| 8 | `AP_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_INVOICE |  | إدخال المستخدم |  | فاتورة الشحن/الرسوم |
| 9 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 10 | `ALLOCATION_BASIS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | VALUE, QUANTITY, WEIGHT, VOLUME, MANUAL | إدخال المستخدم |  | أساس التوزيع |
| 11 | `DETAILS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | التوزيع على الأسطر |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, POSTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 14 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 15 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 16 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_TRANSFER_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر التحويل بين المستودعات |
| English | Transfer Orders |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO) |
| قيود أعمال | FROM_WAREHOUSE_ID <> TO_WAREHOUSE_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `FROM_WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | من |
| 7 | `TO_WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | إلى |
| 8 | `TO_COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المستلمة (يعالج Intercompany) |
| 9 | `TRANSIT_WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع العبور |
| 10 | `REQUIRED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التاريخ المطلوب |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SHIPPED, IN_TRANSIT, PARTIALLY_RECEIVED, RECEIVED, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_TRANSFER_ORDER_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر أوامر التحويل |
| English | Transfer Order Lines |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TRANSFER_ORDER_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TRANSFER_ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_TRANSFER_ORDER UK1 |  | إدخال المستخدم |  | الأمر |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | السطر |
| 6 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 7 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 8 | `REQUESTED_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المطلوب |
| 9 | `SHIPPED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرسل |
| 10 | `RECEIVED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المستلم |
| 11 | `DAMAGED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | العجز/التالف |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_COUNT

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات الجرد |
| English | Physical Counts |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
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
| 6 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | المستودع |
| 7 | `COUNT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PERIODIC, CYCLE, BLIND, SPOT | إدخال المستخدم |  | النوع |
| 8 | `SNAPSHOT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت تجميد الأرصدة |
| 9 | `SCOPE_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | النطاق (فئات، مواقع) |
| 10 | `COUNTER_TEAM` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | فريق العد (منفصل عن معتمد الفروق) |
| 11 | `VARIANCE_TXN_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | حركة التسوية |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, FROZEN, COUNTING, RECOUNT, REVIEW, APPROVED, POSTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 14 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 15 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 16 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## INV_COUNT_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر الجرد |
| English | Count Lines |
| الحزمة المالكة | 11 — `NOONA_INVENTORY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `COUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_COUNT |  | إدخال المستخدم |  | الجرد |
| 5 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 6 | `LOCATION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOCATION |  | إدخال المستخدم |  | الموقع |
| 7 | `LOT_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOT |  | إدخال المستخدم |  | الدفعة |
| 8 | `SERIAL_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_SERIAL |  | إدخال المستخدم |  | الرقم التسلسلي |
| 9 | `SYSTEM_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | كمية النظام (مخفية في الجرد الأعمى) |
| 10 | `COUNTED_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المعدود |
| 11 | `RECOUNT_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | إعادة العد |
| 12 | `VARIANCE_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | محسوب |  | الفرق |
| 13 | `VARIANCE_VALUE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | محسوب |  | قيمة الفرق |
| 14 | `REASON_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الفرق |
| 15 | `COUNTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | العاد |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

