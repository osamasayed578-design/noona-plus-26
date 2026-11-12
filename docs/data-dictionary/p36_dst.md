# قاموس البيانات — الحزمة 36: التوزيع والمبيعات الميدانية

**Distribution & Field Sales** · الحزمة البرمجية المالكة `NOONA_DST_PKG` · ملف DDL `db/ddl/p36_dst.sql` · [ERD](../erd/p36_dst.md)

شركات التوزيع على المحلات: المندوبون وسيارات التوزيع (مستودع متنقل وعهدة نقدية)، خطوط السير والمناطق وأيام الزيارة، المحلات بمواقعها على الخريطة، خطة اليوم والزيارات بالموقع والوقت، البيع من السيارة وأوامر التوريد المسبقة، التحصيل بطرق الدفع ورقم المرجع (الإشعار البنكي، الشيك، العملية)، المرتجعات، أسباب عدم الشراء، تسوية نهاية اليوم، العمولات والأهداف.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`DST_REP`](#dst_rep) | المندوبون | Field Sales Reps | C | INTERNAL |
| [`DST_ROUTE`](#dst_route) | خطوط السير | Delivery Routes | C | INTERNAL |
| [`DST_SHOP`](#dst_shop) | المحلات | Shops & Outlets | C | INTERNAL |
| [`DST_VISIT`](#dst_visit) | الزيارات | Shop Visits | C | INTERNAL |
| [`DST_LOAD`](#dst_load) | تحميل وتفريغ السيارات | Van Loads | C | INTERNAL |
| [`DST_ORDER`](#dst_order) | أوامر التوريد | Pre-sale Orders | C | INTERNAL |
| [`DST_ORDER_LINE`](#dst_order_line) | أسطر أوامر التوريد | Pre-sale Order Lines | C | INTERNAL |
| [`DST_COLLECTION`](#dst_collection) | تحصيلات المندوبين | Field Collections | C | INTERNAL |
| [`DST_SETTLEMENT`](#dst_settlement) | تسويات نهاية اليوم | Daily Rep Settlements | C | INTERNAL |
| [`DST_COMMISSION`](#dst_commission) | عمولات المندوبين | Rep Commissions | C | INTERNAL |

## DST_REP

| البند | القيمة |
|---|---|
| الاسم العربي | المندوبون |
| English | Field Sales Reps |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE)<br>UK3: (TENANT_ID, COMPANY_ID, USER_NAME) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `FULL_NAME` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم |
| 6 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 7 | `USER_NAME` | نص | `VARCHAR2(128 CHAR)` |  |  | UK3 |  | إدخال المستخدم |  | مستخدم النظام (للتطبيق الميداني) |
| 8 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجوال |
| 9 | `VAN_WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع السيارة (المخزون المتنقل) |
| 10 | `CASH_BOX_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→CSH_CASH_BOX |  | إدخال المستخدم |  | عهدة النقد (صندوق المندوب) |
| 11 | `VEHICLE_PLATE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | لوحة سيارة التوزيع |
| 12 | `CREDIT_ALLOWED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يبيع آجلاً ضمن حد المحل |
| 13 | `COMMISSION_BASIS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SALES' |  | SALES, COLLECTION, VISIT, NONE | إدخال المستخدم |  | أساس العمولة |
| 14 | `COMMISSION_RATE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | نسبة العمولة % |
| 15 | `COMMISSION_PER_VISIT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | عمولة الزيارة المنفذة |
| 16 | `MONTHLY_TARGET` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الهدف الشهري للمبيعات |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_ROUTE

| البند | القيمة |
|---|---|
| الاسم العربي | خطوط السير |
| English | Delivery Routes |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
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
| 7 | `REP_ID` | معرف | `NUMBER(19)` |  |  | FK→DST_REP |  | إدخال المستخدم |  | المندوب |
| 8 | `REGION_NAME` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المنطقة |
| 9 | `VISIT_DAYS` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | أيام الزيارة (SUN,MON,TUE,WED,THU,FRI,SAT) |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_SHOP

| البند | القيمة |
|---|---|
| الاسم العربي | المحلات |
| English | Shops & Outlets |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CUSTOMER_ACCOUNT_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AR_CUSTOMER_ACCOUNT UK2 |  | إدخال المستخدم |  | حساب العميل |
| 5 | `SHOP_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GROCERY' |  | GROCERY, SUPERMARKET, PHARMACY, RESTAURANT, CAFE, WHOLESALE, KIOSK, STATION, OTHER | إدخال المستخدم |  | النوع |
| 6 | `OWNER_NAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | صاحب المحل |
| 7 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجوال |
| 8 | `WHATSAPP` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | واتساب |
| 9 | `ROUTE_ID` | معرف | `NUMBER(19)` |  |  | FK→DST_ROUTE |  | إدخال المستخدم |  | خط السير |
| 10 | `ROUTE_SEQ` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب الزيارة في الخط |
| 11 | `VISIT_DAYS` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | أيام الزيارة (إن اختلفت عن الخط) |
| 12 | `LATITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط العرض |
| 13 | `LONGITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط الطول |
| 14 | `LOCATION_SET_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت حفظ الموقع |
| 15 | `ADDRESS_TEXT` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان |
| 16 | `LANDMARK` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | علامة مميزة |
| 17 | `LAST_VISIT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر زيارة |
| 18 | `LAST_SALE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر شراء |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE, BLOCKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_VISIT

| البند | القيمة |
|---|---|
| الاسم العربي | الزيارات |
| English | Shop Visits |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
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
| 6 | `REP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_REP |  | إدخال المستخدم |  | المندوب |
| 7 | `SHOP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_SHOP |  | إدخال المستخدم |  | المحل |
| 8 | `ROUTE_ID` | معرف | `NUMBER(19)` |  |  | FK→DST_ROUTE |  | إدخال المستخدم |  | خط السير |
| 9 | `CHECKIN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الوصول |
| 10 | `CHECKOUT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | المغادرة |
| 11 | `LATITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | موقع الوصول (عرض) |
| 12 | `LONGITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | موقع الوصول (طول) |
| 13 | `DISTANCE_M` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | البعد عن موقع المحل (متر) |
| 14 | `OUTCOME` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | SALE, ORDER, COLLECTION, RETURN, NO_SALE, MIXED | إدخال المستخدم |  | النتيجة |
| 15 | `NO_SALE_REASON` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | CLOSED, STOCKED, NO_CASH, OWNER_ABSENT, COMPETITOR, PRICE, OTHER | إدخال المستخدم |  | سبب عدم الشراء |
| 16 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | فاتورة البيع |
| 17 | `SALES_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المبيعات |
| 18 | `COLLECTED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحصل |
| 19 | `RETURNS_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرتجعات |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_LOAD

| البند | القيمة |
|---|---|
| الاسم العربي | تحميل وتفريغ السيارات |
| English | Van Loads |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
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
| 6 | `REP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_REP |  | إدخال المستخدم |  | المندوب |
| 7 | `DIRECTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'LOAD' |  | LOAD, UNLOAD | إدخال المستخدم |  | تحميل أو تفريغ |
| 8 | `FROM_WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | من مستودع |
| 9 | `TO_WAREHOUSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | إلى مستودع |
| 10 | `INV_TXN_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | حركة التحويل |
| 11 | `ITEMS_COUNT` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الأصناف |
| 12 | `TOTAL_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الكمية |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'POSTED' |  | POSTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر التوريد |
| English | Pre-sale Orders |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
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
| 6 | `REP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_REP |  | إدخال المستخدم |  | المندوب |
| 7 | `SHOP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_SHOP |  | إدخال المستخدم |  | المحل |
| 8 | `VISIT_ID` | معرف | `NUMBER(19)` |  |  | FK→DST_VISIT |  | إدخال المستخدم |  | الزيارة |
| 9 | `DELIVERY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التسليم المطلوب |
| 10 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي (شامل الضريبة) |
| 11 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | فاتورة التسليم |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SUBMITTED' |  | SUBMITTED, APPROVED, INVOICED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_ORDER_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر أوامر التوريد |
| English | Pre-sale Order Lines |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | QUANTITY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 6 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية |
| 7 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | السعر |
| 8 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المبلغ |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_COLLECTION

| البند | القيمة |
|---|---|
| الاسم العربي | تحصيلات المندوبين |
| English | Field Collections |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, DOC_NO) |
| قيود أعمال | AMOUNT > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `REP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_REP |  | إدخال المستخدم |  | المندوب |
| 7 | `SHOP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_SHOP |  | إدخال المستخدم |  | المحل |
| 8 | `VISIT_ID` | معرف | `NUMBER(19)` |  |  | FK→DST_VISIT |  | إدخال المستخدم |  | الزيارة |
| 9 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 10 | `PAYMENT_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CASH' |  | CASH, BANK_TRANSFER, CHEQUE, CARD, WALLET | إدخال المستخدم |  | طريقة الدفع |
| 11 | `REFERENCE_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم المرجع (رقم الإشعار البنكي، الشيك، العملية) |
| 12 | `BANK_NAME` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | البنك |
| 13 | `CHEQUE_DUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ استحقاق الشيك |
| 14 | `BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_BANK_ACCOUNT |  | إدخال المستخدم |  | حساب الشركة المحول إليه |
| 15 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | الفاتورة المسددة |
| 16 | `AR_RECEIPT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_RECEIPT |  | إدخال المستخدم |  | سند القبض |
| 17 | `SETTLEMENT_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | تسوية اليوم |
| 18 | `VERIFIED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المحاسب المؤكد |
| 19 | `VERIFIED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التأكيد |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING_VERIFY' |  | PENDING_VERIFY, POSTED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_SETTLEMENT

| البند | القيمة |
|---|---|
| الاسم العربي | تسويات نهاية اليوم |
| English | Daily Rep Settlements |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK2: (TENANT_ID, COMPANY_ID, REP_ID, SETTLE_DATE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `REP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_REP UK2 |  | إدخال المستخدم |  | المندوب |
| 7 | `SETTLE_DATE` | تاريخ | `DATE` | ✔ |  | UK2 |  | إدخال المستخدم |  | اليوم |
| 8 | `VISITS_PLANNED` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الزيارات المخططة |
| 9 | `VISITS_DONE` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الزيارات المنفذة |
| 10 | `SALES_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المبيعات |
| 11 | `CREDIT_SALES` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | منها آجل |
| 12 | `RETURNS_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرتجعات |
| 13 | `CASH_EXPECTED` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | النقد المتوقع |
| 14 | `CASH_COUNTED` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | النقد المسلم |
| 15 | `CASH_DIFF` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | العجز (-) أو الزيادة (+) |
| 16 | `TRANSFERS_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | إشعارات التحويل |
| 17 | `CHEQUES_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الشيكات |
| 18 | `CARDS_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الشبكة والمحافظ |
| 19 | `DEPOSIT_BOX_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_CASH_BOX |  | إدخال المستخدم |  | الصندوق المورد إليه |
| 20 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 21 | `APPROVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاعتماد |
| 22 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SUBMITTED' |  | SUBMITTED, APPROVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 23 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 24 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 25 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 26 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 27 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 28 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DST_COMMISSION

| البند | القيمة |
|---|---|
| الاسم العربي | عمولات المندوبين |
| English | Rep Commissions |
| الحزمة المالكة | 36 — `NOONA_DST_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, REP_ID, PERIOD_START) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `REP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DST_REP UK1 |  | إدخال المستخدم |  | المندوب |
| 5 | `PERIOD_START` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | بداية الشهر |
| 6 | `BASIS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SALES, COLLECTION, VISIT, NONE | إدخال المستخدم |  | الأساس |
| 7 | `BASE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المبلغ الأساس |
| 8 | `VISITS_COUNT` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الزيارات |
| 9 | `TARGET_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الهدف |
| 10 | `ACHIEVEMENT_PCT` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | نسبة الإنجاز |
| 11 | `COMMISSION_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | العمولة |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CALCULATED' |  | CALCULATED, APPROVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

