# قاموس البيانات — الحزمة 33: النقل والشحن والترحيل

**Transport & Logistics** · الحزمة البرمجية المالكة `NOONA_TRN_PKG` · ملف DDL `db/ddl/p33_trn.sql` · [ERD](../erd/p33_trn.md)

أسطول الشاحنات والعربات والسائقين، المدن والمواقع والمسارات والمسافات، أنواع الشحنات، تعرفة الترحيل بالطن المتري والطن القصير والطويل والكيلوجرام والمتر المكعب والكيلومتر والطن-كيلومتر والرحلة والحاوية، أوامر الشحن، الرحلات بمواعيدها وزمن الوصول المتوقع ونقاط التوقف، التسليم والتفريغ والعجز، مصروفات الرحلة، والأعطال والبلاغات وزمن الاستجابة، وفوترة الترحيل في المبيعات.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`TRN_LOCATION`](#trn_location) | المدن والمواقع | Cities & Locations | C | INTERNAL |
| [`TRN_ROUTE`](#trn_route) | المسارات والمسافات | Routes & Distances | C | INTERNAL |
| [`TRN_CARGO_TYPE`](#trn_cargo_type) | أنواع الشحنات | Cargo Types | C | INTERNAL |
| [`TRN_VEHICLE`](#trn_vehicle) | العربات والشاحنات | Fleet Vehicles | C | INTERNAL |
| [`TRN_DRIVER`](#trn_driver) | السائقون | Drivers | C | INTERNAL |
| [`TRN_RATE`](#trn_rate) | تعرفة الترحيل | Freight Rates | C | INTERNAL |
| [`TRN_ORDER`](#trn_order) | أوامر الشحن | Shipment Orders | C | INTERNAL |
| [`TRN_TRIP`](#trn_trip) | الرحلات | Trips | C | INTERNAL |
| [`TRN_TRIP_ORDER`](#trn_trip_order) | شحنات الرحلة | Trip Shipments | C | INTERNAL |
| [`TRN_TRIP_STOP`](#trn_trip_stop) | نقاط التوقف | Trip Stops | C | INTERNAL |
| [`TRN_TRIP_EXPENSE`](#trn_trip_expense) | مصروفات الرحلة | Trip Expenses | C | INTERNAL |
| [`TRN_INCIDENT`](#trn_incident) | الأعطال والبلاغات | Road Incidents & Reports | C | INTERNAL |
| [`TRN_MAINT_PLAN`](#trn_maint_plan) | برامج الصيانة الدورية للأسطول | Fleet Service Programs | C | INTERNAL |
| [`TRN_MAINT_ORDER`](#trn_maint_order) | أوامر صيانة العربات | Vehicle Maintenance Orders | C | INTERNAL |
| [`TRN_MAINT_LINE`](#trn_maint_line) | بنود أمر الصيانة | Maintenance Order Lines | C | INTERNAL |

## TRN_LOCATION

| البند | القيمة |
|---|---|
| الاسم العربي | المدن والمواقع |
| English | Cities & Locations |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
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
| 7 | `LOCATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CITY' |  | CITY, PORT, WAREHOUSE, FACTORY, BORDER, CHECKPOINT, FUEL_STATION, REST_AREA, CUSTOMER_SITE, OTHER | إدخال المستخدم |  | النوع |
| 8 | `CITY_NAME` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المدينة |
| 9 | `REGION_NAME` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المنطقة/الولاية |
| 10 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 11 | `ADDRESS_TEXT` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان |
| 12 | `LATITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط العرض |
| 13 | `LONGITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط الطول |
| 14 | `CONTACT_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | جهة الاتصال |
| 15 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الهاتف |
| 16 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_ROUTE

| البند | القيمة |
|---|---|
| الاسم العربي | المسارات والمسافات |
| English | Routes & Distances |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |
| قيود أعمال | DISTANCE_KM > 0<br>STANDARD_HOURS > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `FROM_LOCATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_LOCATION |  | إدخال المستخدم |  | من |
| 8 | `TO_LOCATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_LOCATION |  | إدخال المستخدم |  | إلى |
| 9 | `DISTANCE_KM` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | المسافة (كم) |
| 10 | `STANDARD_HOURS` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | زمن الرحلة القياسي (ساعة) |
| 11 | `TOLL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | رسوم الطرق المعتادة |
| 12 | `ROAD_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  | 'HIGHWAY' |  | HIGHWAY, PAVED, UNPAVED, MIXED | إدخال المستخدم |  | نوع الطريق |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_CARGO_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع الشحنات |
| English | Cargo Types |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
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
| 7 | `CARGO_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GENERAL' |  | GENERAL, BULK, LIQUID, REFRIGERATED, HAZARDOUS, CONTAINER, VEHICLES, LIVESTOCK, FRAGILE, OVERSIZED | إدخال المستخدم |  | الفئة |
| 8 | `DEFAULT_UNIT` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'METRIC_TON' |  | METRIC_TON, SHORT_TON, LONG_TON, KG, M3, LITER, CONTAINER, PALLET, PIECE, TRIP | إدخال المستخدم |  | وحدة القياس الافتراضية |
| 9 | `REQUIRED_VEHICLE_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | TRUCK, TRAILER, TANKER, REFRIGERATED, FLATBED, CONTAINER_CARRIER, TIPPER, LOWBED, PICKUP, VAN | إدخال المستخدم |  | نوع العربة المطلوب |
| 10 | `HAZARD_CLASS` | نص | `VARCHAR2(20 CHAR)` |  |  |  |  | إدخال المستخدم |  | فئة الخطورة (UN) |
| 11 | `HANDLING_NOTES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | تعليمات المناولة والتفريغ |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_VEHICLE

| البند | القيمة |
|---|---|
| الاسم العربي | العربات والشاحنات |
| English | Fleet Vehicles |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE)<br>UK3: (TENANT_ID, COMPANY_ID, PLATE_NO) |
| قيود أعمال | CAPACITY_TONS > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `PLATE_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم اللوحة |
| 6 | `VEHICLE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'TRUCK' |  | TRUCK, TRAILER, TANKER, REFRIGERATED, FLATBED, CONTAINER_CARRIER, TIPPER, LOWBED, PICKUP, VAN | إدخال المستخدم |  | النوع |
| 7 | `MAKE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الشركة المصنعة |
| 8 | `MODEL` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الطراز |
| 9 | `MODEL_YEAR` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | سنة الصنع |
| 10 | `CAPACITY_TONS` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | الحمولة القصوى (طن متري) |
| 11 | `CAPACITY_M3` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | السعة (متر مكعب) |
| 12 | `ODOMETER_KM` | رقم | `NUMBER` | ✔ | 0 |  |  | إدخال المستخدم |  | عداد المسافة (كم) |
| 13 | `FUEL_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  | 'DIESEL' |  | DIESEL, GASOLINE, GAS, ELECTRIC | إدخال المستخدم |  | الوقود |
| 14 | `FUEL_L_PER_100KM` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | استهلاك الوقود (لتر/100 كم) |
| 15 | `LICENSE_EXPIRY` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | انتهاء الترخيص |
| 16 | `INSURANCE_EXPIRY` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | انتهاء التأمين |
| 17 | `OWNERSHIP` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OWNED' |  | OWNED, RENTED, LEASED | إدخال المستخدم |  | الملكية (مملوكة تضاف للأصول الثابتة) |
| 18 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل الثابت |
| 19 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'AVAILABLE' |  | AVAILABLE, ON_TRIP, MAINTENANCE, OUT_OF_SERVICE, SOLD | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_DRIVER

| البند | القيمة |
|---|---|
| الاسم العربي | السائقون |
| English | Drivers |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
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
| 5 | `FULL_NAME` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم |
| 6 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 7 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجوال |
| 8 | `NATIONAL_ID` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الهوية |
| 9 | `LICENSE_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | رقم رخصة القيادة |
| 10 | `LICENSE_CLASS` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | فئة الرخصة |
| 11 | `LICENSE_EXPIRY` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | انتهاء الرخصة |
| 12 | `HAZMAT_CERTIFIED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مؤهل لنقل المواد الخطرة |
| 13 | `TRIP_ALLOWANCE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | بدل الرحلة الافتراضي |
| 14 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'AVAILABLE' |  | AVAILABLE, ON_TRIP, OFF_DUTY, SUSPENDED, LEFT | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_RATE

| البند | القيمة |
|---|---|
| الاسم العربي | تعرفة الترحيل |
| English | Freight Rates |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>RATE_AMOUNT >= 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | العميل (فارغ = كل العملاء) |
| 8 | `ROUTE_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_ROUTE |  | إدخال المستخدم |  | المسار (فارغ = كل المسارات) |
| 9 | `CARGO_TYPE_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_CARGO_TYPE |  | إدخال المستخدم |  | نوع الشحنة (فارغ = الكل) |
| 10 | `RATE_BASIS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PER_METRIC_TON, PER_SHORT_TON, PER_LONG_TON, PER_KG, PER_M3, PER_LITER, PER_KM, PER_TON_KM, PER_TRIP, PER_CONTAINER, PER_PALLET, PER_PIECE | إدخال المستخدم |  | أساس الحساب |
| 11 | `RATE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر |
| 12 | `MIN_CHARGE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأدنى للترحيل |
| 13 | `PRIORITY_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 100 |  |  | إدخال المستخدم |  | الأولوية |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 16 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر الشحن |
| English | Shipment Orders |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |
| قيود أعمال | QUANTITY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 7 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 8 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | العميل |
| 9 | `CUSTOMER_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع العميل |
| 10 | `FROM_LOCATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_LOCATION |  | إدخال المستخدم |  | مكان التحميل |
| 11 | `TO_LOCATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_LOCATION |  | إدخال المستخدم |  | مكان التفريغ |
| 12 | `ROUTE_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_ROUTE |  | إدخال المستخدم |  | المسار |
| 13 | `CARGO_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_CARGO_TYPE |  | إدخال المستخدم |  | نوع الشحنة |
| 14 | `CARGO_DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | وصف البضاعة |
| 15 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية |
| 16 | `UOM_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | METRIC_TON, SHORT_TON, LONG_TON, KG, M3, LITER, CONTAINER, PALLET, PIECE, TRIP | إدخال المستخدم |  | الوحدة |
| 17 | `WEIGHT_KG` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الوزن بالكيلوجرام (محسوب أو مدخل) |
| 18 | `VOLUME_M3` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الحجم بالمتر المكعب |
| 19 | `PACKAGES_COUNT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدد الطرود |
| 20 | `DECLARED_VALUE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | القيمة المصرح بها |
| 21 | `RATE_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_RATE |  | إدخال المستخدم |  | التعرفة المطبقة |
| 22 | `RATE_BASIS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | PER_METRIC_TON, PER_SHORT_TON, PER_LONG_TON, PER_KG, PER_M3, PER_LITER, PER_KM, PER_TON_KM, PER_TRIP, PER_CONTAINER, PER_PALLET, PER_PIECE | إدخال المستخدم |  | أساس الحساب |
| 23 | `RATE_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | السعر |
| 24 | `FREIGHT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | قيمة الترحيل |
| 25 | `OTHER_CHARGES` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | رسوم أخرى (تحميل، تفريغ، انتظار) |
| 26 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي قبل الضريبة |
| 27 | `PICKUP_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التحميل المطلوب |
| 28 | `REQUIRED_DELIVERY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التسليم المطلوب |
| 29 | `DELIVERED_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الكمية المسلمة |
| 30 | `SHORTAGE_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | العجز |
| 31 | `DAMAGE_NOTES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الأضرار |
| 32 | `RECEIVER_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المستلم |
| 33 | `DELIVERED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التسليم |
| 34 | `POD_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | إثبات التسليم |
| 35 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | فاتورة الترحيل |
| 36 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, CONFIRMED, PLANNED, IN_TRANSIT, DELIVERED, INVOICED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 37 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 38 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 39 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 40 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 41 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 42 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_TRIP

| البند | القيمة |
|---|---|
| الاسم العربي | الرحلات |
| English | Trips |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
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
| 8 | `VEHICLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_VEHICLE |  | إدخال المستخدم |  | العربة |
| 9 | `DRIVER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_DRIVER |  | إدخال المستخدم |  | السائق |
| 10 | `CO_DRIVER_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_DRIVER |  | إدخال المستخدم |  | السائق المساعد |
| 11 | `ROUTE_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_ROUTE |  | إدخال المستخدم |  | المسار |
| 12 | `FROM_LOCATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_LOCATION |  | إدخال المستخدم |  | من |
| 13 | `TO_LOCATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_LOCATION |  | إدخال المستخدم |  | إلى |
| 14 | `PLANNED_DEPARTURE` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | موعد التحرك المخطط |
| 15 | `ACTUAL_DEPARTURE` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التحرك الفعلي |
| 16 | `ETA` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | زمن الوصول المتوقع |
| 17 | `ACTUAL_ARRIVAL` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الوصول الفعلي |
| 18 | `PLANNED_DISTANCE_KM` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | المسافة المخططة |
| 19 | `ODOMETER_START` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | العداد عند التحرك |
| 20 | `ODOMETER_END` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | العداد عند العودة |
| 21 | `ACTUAL_DISTANCE_KM` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | المسافة الفعلية |
| 22 | `LOAD_KG` | رقم | `NUMBER` | ✔ | 0 |  |  | إدخال المستخدم |  | الحمولة (كجم) |
| 23 | `DELAY_MINUTES` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | التأخير المضاف من الأعطال والتوقفات (دقيقة) |
| 24 | `FUEL_LITERS` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الوقود (لتر) |
| 25 | `REVENUE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | إيراد الرحلة |
| 26 | `EXPENSE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | مصروفات الرحلة |
| 27 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, DISPATCHED, IN_TRANSIT, ARRIVED, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 28 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 29 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 30 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 31 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 32 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 33 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_TRIP_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | شحنات الرحلة |
| English | Trip Shipments |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TRIP_ID, ORDER_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TRIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_TRIP UK1 |  | إدخال المستخدم |  | الرحلة |
| 5 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_ORDER UK1 |  | إدخال المستخدم |  | أمر الشحن |
| 6 | `LOADED_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية المحملة |
| 7 | `LOADED_KG` | رقم | `NUMBER` | ✔ | 0 |  |  | إدخال المستخدم |  | الوزن المحمل (كجم) |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_TRIP_STOP

| البند | القيمة |
|---|---|
| الاسم العربي | نقاط التوقف |
| English | Trip Stops |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TRIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_TRIP |  | إدخال المستخدم |  | الرحلة |
| 5 | `LOCATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_LOCATION |  | إدخال المستخدم |  | الموقع |
| 6 | `STOP_PURPOSE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CHECKPOINT' |  | LOADING, UNLOADING, REST, FUEL, CHECKPOINT, CUSTOMS, BORDER, WEIGHBRIDGE, REPAIR, OTHER | إدخال المستخدم |  | الغرض |
| 7 | `PLANNED_MINUTES` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | مدة التوقف المخططة (دقيقة) |
| 8 | `PLANNED_ARRIVAL` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الوصول المخطط |
| 9 | `ACTUAL_ARRIVAL` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الوصول الفعلي |
| 10 | `ACTUAL_DEPARTURE` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | المغادرة الفعلية |
| 11 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 12 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_TRIP_EXPENSE

| البند | القيمة |
|---|---|
| الاسم العربي | مصروفات الرحلة |
| English | Trip Expenses |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | AMOUNT >= 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TRIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_TRIP |  | إدخال المستخدم |  | الرحلة |
| 5 | `EXPENSE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FUEL, TOLL, DRIVER_ALLOWANCE, LOADING, UNLOADING, PARKING, REPAIR, TIRES, FINE, WEIGHBRIDGE, CUSTOMS, OTHER | إدخال المستخدم |  | النوع |
| 6 | `EXPENSE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 7 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 8 | `LITERS` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | اللترات (للوقود) |
| 9 | `REFERENCE_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الإيصال |
| 10 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_INCIDENT

| البند | القيمة |
|---|---|
| الاسم العربي | الأعطال والبلاغات |
| English | Road Incidents & Reports |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
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
| 7 | `TRIP_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_TRIP |  | إدخال المستخدم |  | الرحلة |
| 8 | `VEHICLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_VEHICLE |  | إدخال المستخدم |  | العربة |
| 9 | `DRIVER_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_DRIVER |  | إدخال المستخدم |  | السائق |
| 10 | `INCIDENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BREAKDOWN, TIRE, ACCIDENT, DELAY, CARGO_DAMAGE, THEFT, POLICE, WEATHER, ROAD_CLOSURE, MEDICAL, BORDER_HOLD, OTHER | إدخال المستخدم |  | النوع |
| 11 | `SEVERITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MEDIUM' |  | LOW, MEDIUM, HIGH, CRITICAL | إدخال المستخدم |  | الخطورة |
| 12 | `REPORTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | وقت البلاغ |
| 13 | `REPORTED_BY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المبلّغ |
| 14 | `LOCATION_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_LOCATION |  | إدخال المستخدم |  | أقرب موقع |
| 15 | `LOCATION_TEXT` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | وصف المكان |
| 16 | `DESCRIPTION` | نص | `VARCHAR2(2000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 17 | `ASSIGNED_TO` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المكلّف بالاستجابة |
| 18 | `ACKNOWLEDGED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاستلام |
| 19 | `RESPONDED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت بدء الاستجابة |
| 20 | `RESOLVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الحل |
| 21 | `RESPONSE_ACTION` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | إجراء الاستجابة |
| 22 | `DOWNTIME_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة التوقف (دقيقة) |
| 23 | `COST_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة |
| 24 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REPORTED' |  | REPORTED, ACKNOWLEDGED, IN_PROGRESS, RESOLVED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 25 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 26 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 27 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 28 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 29 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 30 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_MAINT_PLAN

| البند | القيمة |
|---|---|
| الاسم العربي | برامج الصيانة الدورية للأسطول |
| English | Fleet Service Programs |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EVERY_KM > 0 OR EVERY_DAYS > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SERVICE_NAME` | نص | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الخدمة (تغيير زيت، إطارات، فرامل، فحص دوري...) |
| 5 | `VEHICLE_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_VEHICLE |  | إدخال المستخدم |  | العربة (فارغ = كل عربات النوع) |
| 6 | `VEHICLE_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع العربات (فارغ = كل الأنواع) |
| 7 | `EVERY_KM` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | كل (كم) |
| 8 | `EVERY_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | كل (يوم) |
| 9 | `ESTIMATED_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة التقديرية |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, PAUSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_MAINT_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر صيانة العربات |
| English | Vehicle Maintenance Orders |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
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
| 8 | `VEHICLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_VEHICLE |  | إدخال المستخدم |  | العربة |
| 9 | `PLAN_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_MAINT_PLAN |  | إدخال المستخدم |  | البرنامج الدوري |
| 10 | `INCIDENT_ID` | معرف | `NUMBER(19)` |  |  | FK→TRN_INCIDENT |  | إدخال المستخدم |  | البلاغ (العطل) |
| 11 | `MAINT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CORRECTIVE' |  | PREVENTIVE, CORRECTIVE, OVERHAUL, INSPECTION, ACCIDENT, TIRES, UPGRADE | إدخال المستخدم |  | النوع |
| 12 | `WORKSHOP` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | INTERNAL, EXTERNAL | إدخال المستخدم |  | الورشة |
| 13 | `VENDOR_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الورشة الخارجية / المورد |
| 14 | `DESCRIPTION` | نص | `VARCHAR2(2000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | وصف العمل |
| 15 | `OPENED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | دخول الصيانة |
| 16 | `COMPLETED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الخروج من الصيانة |
| 17 | `ODOMETER_KM` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | العداد عند الصيانة |
| 18 | `DOWNTIME_HOURS` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | مدة التوقف (ساعة) |
| 19 | `PARTS_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | قطع الغيار |
| 20 | `LABOR_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | العمالة |
| 21 | `OTHER_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | أخرى |
| 22 | `VAT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة |
| 23 | `TOTAL_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي دون الضريبة |
| 24 | `TREATMENT` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'EXPENSE' |  | EXPENSE, CAPITALIZE | إدخال المستخدم |  | المعالجة المحاسبية |
| 25 | `LIFE_EXTENSION_MONTHS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | تمديد عمر العربة (شهر) |
| 26 | `PREV_STATUS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | حالة العربة قبل الصيانة |
| 27 | `FA_MAINTENANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_MAINTENANCE |  | إدخال المستخدم |  | قيد الصيانة في الأصول |
| 28 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, IN_PROGRESS, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 29 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 30 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 31 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 32 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 33 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 34 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## TRN_MAINT_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | بنود أمر الصيانة |
| English | Maintenance Order Lines |
| الحزمة المالكة | 33 — `NOONA_TRN_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | QUANTITY > 0<br>UNIT_COST >= 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→TRN_MAINT_ORDER |  | إدخال المستخدم |  | أمر الصيانة |
| 5 | `LINE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PART' |  | PART, LABOR, OIL, TIRE, OTHER | إدخال المستخدم |  | النوع |
| 6 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | البيان |
| 7 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف (قطعة الغيار) |
| 8 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ | 1 |  |  | إدخال المستخدم |  | الكمية |
| 9 | `UNIT_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | تكلفة الوحدة |
| 10 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المبلغ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

