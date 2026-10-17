# قاموس البيانات — الحزمة 16: التطوير العقاري وبيع الوحدات

**Real Estate Development & Unit Sales** · الحزمة البرمجية المالكة `NOONA_REAL_ESTATE_PKG` · ملف DDL `db/ddl/p16_re.sql` · [ERD](../erd/p16_re.md)

السجل العقاري الموحد (الأرض ← العقار/المجمع ← المبنى ← الطابق ← الوحدة) المشترك مع الإيجارات والضيافة والصيانة، وقوائم أسعار الوحدات وخطط السداد والحجز وعقود البيع والأقساط والتسليم والإفراغ وعمولات الوسطاء. معرف العقار لا يتغير بتغير مالكه.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`RE_LAND`](#re_land) | الأراضي | Land Plots | C | INTERNAL |
| [`RE_PROPERTY`](#re_property) | العقارات والمجمعات | Properties / Compounds | C | INTERNAL |
| [`RE_BUILDING`](#re_building) | المباني | Buildings | C | INTERNAL |
| [`RE_FLOOR`](#re_floor) | الطوابق | Floors | C | INTERNAL |
| [`RE_UNIT`](#re_unit) | الوحدات العقارية | Real Estate Units | C | INTERNAL |
| [`RE_UNIT_OWNERSHIP`](#re_unit_ownership) | سجل ملكية الوحدات | Unit Ownership History | C | INTERNAL |
| [`RE_PRICE_LIST`](#re_price_list) | قوائم أسعار الوحدات | Unit Price Lists | C | INTERNAL |
| [`RE_PRICE_LIST_LINE`](#re_price_list_line) | أسعار الوحدات | Unit Prices | C | INTERNAL |
| [`RE_PAYMENT_PLAN`](#re_payment_plan) | خطط السداد | Payment Plan Templates | C | INTERNAL |
| [`RE_PAYMENT_PLAN_LINE`](#re_payment_plan_line) | أسطر خطط السداد | Payment Plan Lines | C | INTERNAL |
| [`RE_RESERVATION`](#re_reservation) | حجوزات الوحدات | Unit Reservations | C | INTERNAL |
| [`RE_SALE_CONTRACT`](#re_sale_contract) | عقود بيع الوحدات | Unit Sale Contracts | C | INTERNAL |
| [`RE_SALE_INSTALLMENT`](#re_sale_installment) | أقساط عقود البيع | Sale Installments | C | INTERNAL |
| [`RE_HANDOVER`](#re_handover) | تسليم الوحدات | Unit Handovers | C | INTERNAL |
| [`RE_TITLE_TRANSFER`](#re_title_transfer) | إفراغ الملكية | Title Transfers | C | INTERNAL |
| [`RE_BROKER_COMMISSION`](#re_broker_commission) | عمولات الوسطاء | Broker Commissions | C | INTERNAL |
| [`RE_COST_ALLOCATION`](#re_cost_allocation) | توزيع تكاليف التطوير | Development Cost Allocation | C | INTERNAL |

## RE_LAND

| البند | القيمة |
|---|---|
| الاسم العربي | الأراضي |
| English | Land Plots |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE)<br>UK3: (PUBLIC_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 8 | `PLOT_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم القطعة |
| 9 | `DEED_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الصك |
| 10 | `AREA_SQM` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المساحة م2 |
| 11 | `ZONING_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | التصنيف/الاستخدام |
| 12 | `CITY_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_CITY |  | إدخال المستخدم |  | المدينة |
| 13 | `LATITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط العرض |
| 14 | `LONGITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط الطول |
| 15 | `ACQUISITION_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تكلفة الاقتناء |
| 16 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل المرتبط |
| 17 | `DEED_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الصك |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OWNED' |  | OWNED, UNDER_ACQUISITION, UNDER_DEVELOPMENT, DEVELOPED, SOLD | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_PROPERTY

| البند | القيمة |
|---|---|
| الاسم العربي | العقارات والمجمعات |
| English | Properties / Compounds |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE)<br>UK3: (PUBLIC_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 7 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 8 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 9 | `PROPERTY_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | COMPOUND, TOWER, BUILDING, VILLA_COMPOUND, MALL, OFFICE_PARK, HOTEL, SERVICED_APARTMENTS, WAREHOUSE_PARK, LAND_SUBDIVISION | إدخال المستخدم |  | النوع |
| 10 | `LAND_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_LAND |  | إدخال المستخدم |  | الأرض |
| 11 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | مشروع التطوير |
| 12 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | الموقع التشغيلي |
| 13 | `OWNER_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المالك (عند إدارة أملاك الغير) |
| 14 | `MANAGEMENT_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OWNED' |  | OWNED, MANAGED_FOR_OWNER, JOINT | إدخال المستخدم |  | الملكية/الإدارة |
| 15 | `USAGE_MIX` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاستخدامات (سكني، تجاري، فندقي) |
| 16 | `TOTAL_AREA_SQM` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المساحة الكلية |
| 17 | `CITY_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_CITY |  | إدخال المستخدم |  | المدينة |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, UNDER_DEVELOPMENT, OPERATIONAL, UNDER_RENOVATION, SOLD_OUT, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_BUILDING

| البند | القيمة |
|---|---|
| الاسم العربي | المباني |
| English | Buildings |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PROPERTY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY UK2 |  | إدخال المستخدم |  | العقار |
| 8 | `FLOORS_COUNT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدد الطوابق |
| 9 | `COMPLETION_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإنجاز |
| 10 | `BUILDING_PERMIT_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رخصة البناء |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, UNDER_CONSTRUCTION, COMPLETED, OPERATIONAL | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_FLOOR

| البند | القيمة |
|---|---|
| الاسم العربي | الطوابق |
| English | Floors |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (BUILDING_ID, FLOOR_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `BUILDING_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_BUILDING UK2 |  | إدخال المستخدم |  | المبنى |
| 8 | `FLOOR_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الطابق |
| 9 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_UNIT

| البند | القيمة |
|---|---|
| الاسم العربي | الوحدات العقارية |
| English | Real Estate Units |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | السجل الموحد للوحدات يستخدمه البيع والتأجير والضيافة والصيانة دون تكرار |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, PROPERTY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 8 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY UK3 |  | إدخال المستخدم |  | العقار |
| 9 | `BUILDING_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_BUILDING |  | إدخال المستخدم |  | المبنى |
| 10 | `FLOOR_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_FLOOR |  | إدخال المستخدم |  | الطابق |
| 11 | `UNIT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | APARTMENT, VILLA, TOWNHOUSE, OFFICE, SHOP, SHOWROOM, WAREHOUSE, ROOM, SUITE, STUDIO, PARKING, STORAGE, LAND_PLOT | إدخال المستخدم |  | النوع |
| 12 | `USAGE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SALE' |  | SALE, LEASE, HOSPITALITY, MIXED, OWNER_USE | إدخال المستخدم |  | الاستخدام |
| 13 | `NET_AREA_SQM` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المساحة الصافية |
| 14 | `GROSS_AREA_SQM` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المساحة الإجمالية |
| 15 | `BEDROOMS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | غرف النوم |
| 16 | `BATHROOMS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | دورات المياه |
| 17 | `VIEW_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الإطلالة |
| 18 | `FURNISHING` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | UNFURNISHED, SEMI_FURNISHED, FURNISHED | إدخال المستخدم |  | التأثيث |
| 19 | `OWNER_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المالك الحالي (بعد البيع) |
| 20 | `TITLE_DEED_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم صك الوحدة |
| 21 | `LIST_PRICE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | السعر الحالي |
| 22 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف (عند البيع كمخزون عقاري) |
| 23 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل (عند الاحتفاظ للتأجير) |
| 24 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, UNDER_CONSTRUCTION, AVAILABLE, RESERVED, SOLD, HANDED_OVER, LEASED, OCCUPIED, UNDER_MAINTENANCE, BLOCKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 25 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 26 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 27 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 28 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 29 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_UNIT_OWNERSHIP

| البند | القيمة |
|---|---|
| الاسم العربي | سجل ملكية الوحدات |
| English | Unit Ownership History |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `UNIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 5 | `OWNER_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المالك الطرف |
| 6 | `OWNER_COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | أو شركة من المجموعة |
| 7 | `OWNERSHIP_PCT` | نسبة | `NUMBER(9,6)` | ✔ | 100 |  |  | إدخال المستخدم |  | النسبة |
| 8 | `SOURCE_CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_SALE_CONTRACT |  | إدخال المستخدم |  | عقد البيع المصدر |
| 9 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 10 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_PRICE_LIST

| البند | القيمة |
|---|---|
| الاسم العربي | قوائم أسعار الوحدات |
| English | Unit Price Lists |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
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
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 8 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 9 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 10 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 11 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 12 | `PHASE_CODE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرحلة |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 15 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 16 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_PRICE_LIST_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسعار الوحدات |
| English | Unit Prices |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PRICE_LIST_ID, UNIT_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PRICE_LIST_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PRICE_LIST UK1 |  | إدخال المستخدم |  | القائمة |
| 5 | `UNIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_UNIT UK1 |  | إدخال المستخدم |  | الوحدة |
| 6 | `BASE_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر الأساسي |
| 7 | `PRICE_PER_SQM` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | سعر المتر |
| 8 | `MIN_PRICE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | أدنى سعر دون موافقة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_PAYMENT_PLAN

| البند | القيمة |
|---|---|
| الاسم العربي | خطط السداد |
| English | Payment Plan Templates |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
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
| 7 | `PROPERTY_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 8 | `DOWN_PAYMENT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | الدفعة الأولى % |
| 9 | `INSTALLMENTS_COUNT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدد الأقساط |
| 10 | `FREQUENCY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | MONTHLY, QUARTERLY, SEMI_ANNUAL, ANNUAL, MILESTONE | إدخال المستخدم |  | التكرار |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_PAYMENT_PLAN_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر خطط السداد |
| English | Payment Plan Lines |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PAYMENT_PLAN_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PAYMENT_PLAN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PAYMENT_PLAN UK1 |  | إدخال المستخدم |  | الخطة |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | السطر |
| 6 | `DUE_PCT` | نسبة | `NUMBER(9,6)` | ✔ |  |  |  | إدخال المستخدم |  | النسبة |
| 7 | `DUE_TRIGGER` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ON_SIGNING, MONTHS_AFTER_SIGNING, CONSTRUCTION_MILESTONE, ON_HANDOVER, POST_HANDOVER | إدخال المستخدم |  | الاستحقاق |
| 8 | `OFFSET_MONTHS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الأشهر |
| 9 | `MILESTONE_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_MILESTONE |  | إدخال المستخدم |  | معلم الإنشاء |
| 10 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_RESERVATION

| البند | القيمة |
|---|---|
| الاسم العربي | حجوزات الوحدات |
| English | Unit Reservations |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يمنع حجزين نشطين لنفس الوحدة (يفحص في الحزمة مع قفل الوحدة) |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |

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
| 11 | `UNIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 12 | `BUYER_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المشتري |
| 13 | `BROKER_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الوسيط |
| 14 | `QUOTED_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر المعروض |
| 15 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الخصم (بموافقة حسب الحد) |
| 16 | `DEPOSIT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | العربون |
| 17 | `DEPOSIT_RECEIPT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_RECEIPT |  | إدخال المستخدم |  | إيصال العربون |
| 18 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | انتهاء الحجز |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, CONVERTED, EXPIRED, CANCELLED, REFUNDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_SALE_CONTRACT

| البند | القيمة |
|---|---|
| الاسم العربي | عقود بيع الوحدات |
| English | Unit Sale Contracts |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
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
| 7 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 8 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 9 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 10 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 11 | `UNIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 12 | `RESERVATION_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_RESERVATION |  | إدخال المستخدم |  | الحجز |
| 13 | `BUYER_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المشتري الرئيسي |
| 14 | `CO_BUYERS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | المشترون الإضافيون ونسبهم |
| 15 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | حساب العميل |
| 16 | `PAYMENT_PLAN_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_PAYMENT_PLAN |  | إدخال المستخدم |  | خطة السداد |
| 17 | `SALE_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | سعر البيع |
| 18 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الخصم |
| 19 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة/الرسوم |
| 20 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الإجمالي |
| 21 | `SIGNED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التوقيع |
| 22 | `REGISTRATION_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم التسجيل الحكومي (مثل Oqood/Ejar) |
| 23 | `EXPECTED_HANDOVER` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التسليم المتوقع |
| 24 | `REVENUE_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | POINT_IN_TIME, OVER_TIME | إدخال المستخدم |  | الاعتراف بالإيراد |
| 25 | `SIGNED_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | العقد الموقع |
| 26 | `CANCEL_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإلغاء |
| 27 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SIGNED, REGISTERED, UNDER_CONSTRUCTION, READY_FOR_HANDOVER, HANDED_OVER, TITLE_TRANSFERRED, CANCELLED, TERMINATED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 28 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 29 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 30 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 31 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 32 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 33 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_SALE_INSTALLMENT

| البند | القيمة |
|---|---|
| الاسم العربي | أقساط عقود البيع |
| English | Sale Installments |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CONTRACT_ID, INSTALLMENT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CONTRACT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_SALE_CONTRACT UK1 |  | إدخال المستخدم |  | العقد |
| 5 | `INSTALLMENT_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم القسط |
| 6 | `DUE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | الاستحقاق |
| 7 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 8 | `PAID_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | النظام/الحزمة |  | المحصل |
| 9 | `AR_OPEN_ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_OPEN_ITEM |  | إدخال المستخدم |  | الذمة الناتجة |
| 10 | `MILESTONE_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_MILESTONE |  | إدخال المستخدم |  | المعلم المرتبط |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SCHEDULED' |  | SCHEDULED, DUE, INVOICED, PARTIALLY_PAID, PAID, OVERDUE, WAIVED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_HANDOVER

| البند | القيمة |
|---|---|
| الاسم العربي | تسليم الوحدات |
| English | Unit Handovers |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
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
| 6 | `CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_SALE_CONTRACT |  | إدخال المستخدم |  | عقد البيع |
| 7 | `UNIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 8 | `SCHEDULED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | الموعد |
| 9 | `HANDOVER_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التسليم الفعلي |
| 10 | `SNAG_LIST` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الملاحظات والعيوب |
| 11 | `METER_READINGS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | قراءات العدادات |
| 12 | `KEYS_COUNT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدد المفاتيح |
| 13 | `ACCEPTANCE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | محضر الاستلام الموقع |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SCHEDULED' |  | SCHEDULED, INSPECTION, SNAGS_OPEN, ACCEPTED, HANDED_OVER | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_TITLE_TRANSFER

| البند | القيمة |
|---|---|
| الاسم العربي | إفراغ الملكية |
| English | Title Transfers |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CONTRACT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_SALE_CONTRACT |  | إدخال المستخدم |  | العقد |
| 5 | `AUTHORITY_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع الجهة |
| 6 | `TRANSFER_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التاريخ |
| 7 | `FEES_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الرسوم |
| 8 | `NEW_DEED_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الصك الجديد |
| 9 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الصك |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, SUBMITTED, COMPLETED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_BROKER_COMMISSION

| البند | القيمة |
|---|---|
| الاسم العربي | عمولات الوسطاء |
| English | Broker Commissions |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CONTRACT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_SALE_CONTRACT |  | إدخال المستخدم |  | العقد |
| 5 | `BROKER_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الوسيط |
| 6 | `COMMISSION_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | النسبة |
| 7 | `COMMISSION_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 8 | `ELIGIBILITY_RULE` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | شرط الاستحقاق (نسبة تحصيل...) |
| 9 | `AP_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_INVOICE |  | إدخال المستخدم |  | فاتورة الوسيط |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACCRUED' |  | ACCRUED, ELIGIBLE, APPROVED, PAID, REVERSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## RE_COST_ALLOCATION

| البند | القيمة |
|---|---|
| الاسم العربي | توزيع تكاليف التطوير |
| English | Development Cost Allocation |
| الحزمة المالكة | 16 — `NOONA_REAL_ESTATE_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 5 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD |  | إدخال المستخدم |  | الفترة |
| 6 | `ALLOCATION_BASIS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | AREA, SALE_VALUE, UNIT_COUNT, MANUAL | إدخال المستخدم |  | الأساس |
| 7 | `TOTAL_COST` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | التكلفة الموزعة |
| 8 | `DETAILS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | التوزيع على الوحدات |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, CALCULATED, POSTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 11 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 12 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

