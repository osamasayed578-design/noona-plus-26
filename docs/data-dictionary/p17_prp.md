# قاموس البيانات — الحزمة 17: إدارة الأملاك والإيجارات والضيافة

**Property Management, Leasing & Hospitality** · الحزمة البرمجية المالكة `NOONA_PROPERTY_PKG` · ملف DDL `db/ddl/p17_prp.sql` · [ERD](../erd/p17_prp.md)

دورة الإيجار Lease → Rent Schedule → Move-in/out مع التأمينات والعدادات وكشوف الملاك؛ وموديول NOONA Hospitality المستقل Reservation → Stay → Folio → Check-in/out → Night Audit مع مخزون غرف زمني و Housekeeping و Unified Front Desk Room Rack، مع مشاركة العملاء والنقدية وPOS والصيانة والمحاسبة.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`PRP_MANAGEMENT_AGREEMENT`](#prp_management_agreement) | اتفاقيات إدارة الأملاك | Property Management Agreements | C | INTERNAL |
| [`PRP_LEASE`](#prp_lease) | عقود الإيجار | Leases | C | INTERNAL |
| [`PRP_LEASE_UNIT`](#prp_lease_unit) | وحدات عقد الإيجار | Lease Units | C | INTERNAL |
| [`PRP_LEASE_CHARGE`](#prp_lease_charge) | بنود رسوم الإيجار | Lease Charges | C | INTERNAL |
| [`PRP_RENT_SCHEDULE`](#prp_rent_schedule) | جدول استحقاقات الإيجار | Rent Schedule | C | INTERNAL |
| [`PRP_LEASE_EVENT`](#prp_lease_event) | أحداث عقد الإيجار | Lease Events | C | INTERNAL |
| [`PRP_SECURITY_DEPOSIT`](#prp_security_deposit) | التأمينات | Security Deposits | C | INTERNAL |
| [`PRP_INSPECTION`](#prp_inspection) | معاينات الوحدات | Unit Inspections | C | INTERNAL |
| [`PRP_METER`](#prp_meter) | العدادات | Utility Meters | C | INTERNAL |
| [`PRP_METER_READING`](#prp_meter_reading) | قراءات العدادات | Meter Readings | C | INTERNAL |
| [`PRP_OWNER_STATEMENT`](#prp_owner_statement) | كشوف حسابات الملاك | Owner Statements | C | INTERNAL |
| [`HSP_ROOM_TYPE`](#hsp_room_type) | أنواع الغرف | Room Types | C | INTERNAL |
| [`HSP_ROOM`](#hsp_room) | الغرف والشقق الفندقية | Rooms | C | INTERNAL |
| [`HSP_RATE_PLAN`](#hsp_rate_plan) | خطط الأسعار | Rate Plans | C | INTERNAL |
| [`HSP_RATE`](#hsp_rate) | أسعار الغرف | Room Rates | C | INTERNAL |
| [`HSP_RESERVATION`](#hsp_reservation) | حجوزات الضيافة | Hospitality Reservations | C | INTERNAL |
| [`HSP_RESERVATION_ROOM`](#hsp_reservation_room) | غرف الحجز | Reservation Rooms | C | INTERNAL |
| [`HSP_ROOM_BLOCK`](#hsp_room_block) | مخزون الغرف الزمني | Room Inventory Blocks | C | INTERNAL |
| [`HSP_STAY`](#hsp_stay) | الإقامات | Stays | C | INTERNAL |
| [`HSP_STAY_GUEST`](#hsp_stay_guest) | نزلاء الإقامة | Stay Guests | C | HIGHLY_RESTRICTED |
| [`HSP_FOLIO`](#hsp_folio) | فواتير النزلاء المفتوحة | Guest Folios | C | INTERNAL |
| [`HSP_FOLIO_LINE`](#hsp_folio_line) | حركات الفوليو | Folio Lines | C | INTERNAL |
| [`HSP_NIGHT_AUDIT`](#hsp_night_audit) | التدقيق الليلي | Night Audits | C | INTERNAL |
| [`HSP_HOUSEKEEPING_TASK`](#hsp_housekeeping_task) | مهام التدبير الفندقي | Housekeeping Tasks | C | INTERNAL |
| [`HSP_ROOM_DISCREPANCY`](#hsp_room_discrepancy) | اختلافات حالة الغرف | Room Status Discrepancies | C | INTERNAL |

## PRP_MANAGEMENT_AGREEMENT

| البند | القيمة |
|---|---|
| الاسم العربي | اتفاقيات إدارة الأملاك |
| English | Property Management Agreements |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
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
| 7 | `OWNER_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المالك |
| 8 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 9 | `FEE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PCT_OF_COLLECTION, PCT_OF_RENT, FIXED_MONTHLY, MIXED | إدخال المستخدم |  | أساس الأتعاب |
| 10 | `FEE_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | النسبة |
| 11 | `FEE_FIXED` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ الثابت |
| 12 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 13 | `REMIT_FREQUENCY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MONTHLY' |  | MONTHLY, QUARTERLY | إدخال المستخدم |  | دورية التحويل للمالك |
| 14 | `OWNER_BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_BANK_ACCOUNT |  | إدخال المستخدم |  | حساب المالك |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, SUSPENDED, TERMINATED, EXPIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 17 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 18 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_LEASE

| البند | القيمة |
|---|---|
| الاسم العربي | عقود الإيجار |
| English | Leases |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |
| قيود أعمال | END_DATE > START_DATE |

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
| 11 | `LEASE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | RESIDENTIAL, COMMERCIAL, RETAIL, INDUSTRIAL, LAND, PARKING | إدخال المستخدم |  | النوع |
| 12 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 13 | `LESSEE_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المستأجر |
| 14 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | حساب المستأجر |
| 15 | `MANAGEMENT_AGREEMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRP_MANAGEMENT_AGREEMENT |  | إدخال المستخدم |  | اتفاقية الإدارة (أملاك الغير) |
| 16 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 17 | `END_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 18 | `BILLING_FREQUENCY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MONTHLY' |  | MONTHLY, QUARTERLY, SEMI_ANNUAL, ANNUAL, UPFRONT | إدخال المستخدم |  | دورية الفوترة |
| 19 | `BILLING_IN_ADVANCE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | فوترة مقدمة |
| 20 | `ANNUAL_RENT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الإيجار السنوي |
| 21 | `DEPOSIT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | التأمين |
| 22 | `ESCALATION_RULE` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | قاعدة الزيادة السنوية |
| 23 | `NOTICE_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة الإشعار |
| 24 | `GRACE_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | فترة السماح للسداد |
| 25 | `REGISTRATION_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم التوثيق الحكومي (إيجار/Ejari) |
| 26 | `PREVIOUS_LEASE_ID` | معرف | `NUMBER(19)` |  |  | FK→PRP_LEASE |  | إدخال المستخدم |  | العقد السابق (التجديد) |
| 27 | `MOVE_IN_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الاستلام |
| 28 | `MOVE_OUT_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإخلاء |
| 29 | `SIGNED_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | العقد الموقع |
| 30 | `TERMINATION_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإنهاء |
| 31 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SIGNED, ACTIVE, RENEWAL_PENDING, RENEWED, EXPIRED, TERMINATED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 32 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 33 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 34 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 35 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 36 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 37 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_LEASE_UNIT

| البند | القيمة |
|---|---|
| الاسم العربي | وحدات عقد الإيجار |
| English | Lease Units |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يمنع تأجير الوحدة لعقدين نشطين متداخلين (يفحص في الحزمة) |
| مفاتيح فريدة | UK1: (LEASE_ID, UNIT_ID) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `LEASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRP_LEASE UK1 |  | إدخال المستخدم |  | العقد |
| 5 | `UNIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_UNIT UK1 |  | إدخال المستخدم |  | الوحدة |
| 6 | `RENT_SHARE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | حصة الوحدة من الإيجار |
| 7 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 8 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_LEASE_CHARGE

| البند | القيمة |
|---|---|
| الاسم العربي | بنود رسوم الإيجار |
| English | Lease Charges |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `LEASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRP_LEASE |  | إدخال المستخدم |  | العقد |
| 5 | `CHARGE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | RENT, SERVICE_CHARGE, UTILITIES, PARKING, MAINTENANCE, MANAGEMENT_FEE, PENALTY, OTHER | إدخال المستخدم |  | النوع |
| 6 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ للفترة |
| 7 | `FREQUENCY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MONTHLY, QUARTERLY, SEMI_ANNUAL, ANNUAL, ONE_TIME, METERED | إدخال المستخدم |  | التكرار |
| 8 | `TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الضريبة |
| 9 | `REVENUE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الإيراد |
| 10 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 11 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_RENT_SCHEDULE

| البند | القيمة |
|---|---|
| الاسم العربي | جدول استحقاقات الإيجار |
| English | Rent Schedule |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `LEASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRP_LEASE |  | إدخال المستخدم |  | العقد |
| 5 | `CHARGE_ID` | معرف | `NUMBER(19)` |  |  | FK→PRP_LEASE_CHARGE |  | إدخال المستخدم |  | البند |
| 6 | `PERIOD_FROM` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | من |
| 7 | `PERIOD_TO` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | إلى |
| 8 | `DUE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | الاستحقاق |
| 9 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 10 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة |
| 11 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 12 | `AR_OPEN_ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_OPEN_ITEM |  | إدخال المستخدم |  | الذمة |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SCHEDULED' |  | SCHEDULED, INVOICED, PARTIALLY_PAID, PAID, OVERDUE, WAIVED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_LEASE_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | أحداث عقد الإيجار |
| English | Lease Events |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `LEASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRP_LEASE |  | إدخال المستخدم |  | العقد |
| 5 | `EVENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | AMENDMENT, RENEWAL, ESCALATION, RENT_FREE, TERMINATION_NOTICE, EARLY_TERMINATION, MOVE_IN, MOVE_OUT, EVICTION, TRANSFER | إدخال المستخدم |  | النوع |
| 6 | `EFFECTIVE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | السريان |
| 7 | `CHANGES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | التغييرات |
| 8 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 9 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, EFFECTIVE, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_SECURITY_DEPOSIT

| البند | القيمة |
|---|---|
| الاسم العربي | التأمينات |
| English | Security Deposits |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 5 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 6 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 7 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 8 | `LEASE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRP_LEASE |  | إدخال المستخدم |  | العقد |
| 9 | `RECEIVED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المستلم |
| 10 | `DEDUCTED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الخصومات |
| 11 | `REFUNDED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المردود |
| 12 | `RECEIPT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_RECEIPT |  | إدخال المستخدم |  | إيصال الاستلام |
| 13 | `REFUND_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_REFUND |  | إدخال المستخدم |  | الرد |
| 14 | `DEDUCTION_DETAILS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | تفاصيل الخصومات |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'HELD' |  | HELD, PARTIALLY_REFUNDED, REFUNDED, FORFEITED, APPLIED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_INSPECTION

| البند | القيمة |
|---|---|
| الاسم العربي | معاينات الوحدات |
| English | Unit Inspections |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `UNIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 5 | `LEASE_ID` | معرف | `NUMBER(19)` |  |  | FK→PRP_LEASE |  | إدخال المستخدم |  | العقد |
| 6 | `INSPECTION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MOVE_IN, MOVE_OUT, PERIODIC, COMPLAINT | إدخال المستخدم |  | النوع |
| 7 | `INSPECTION_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 8 | `INSPECTOR_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | المعاين |
| 9 | `CONDITION_REPORT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | تقرير الحالة |
| 10 | `REPORT_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | التقرير والصور |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SCHEDULED' |  | SCHEDULED, DONE, DISPUTED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_METER

| البند | القيمة |
|---|---|
| الاسم العربي | العدادات |
| English | Utility Meters |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, METER_TYPE, METER_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة |
| 6 | `PROPERTY_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | أو العقار (عداد مشترك) |
| 7 | `METER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 | ELECTRICITY, WATER, GAS, CHILLED_WATER | إدخال المستخدم |  | النوع |
| 8 | `METER_NO` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم العداد |
| 9 | `UTILITY_ACCOUNT_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم حساب المرفق |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, REPLACED, REMOVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_METER_READING

| البند | القيمة |
|---|---|
| الاسم العربي | قراءات العدادات |
| English | Meter Readings |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (METER_ID, READING_DATE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `METER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRP_METER UK1 |  | إدخال المستخدم |  | العداد |
| 5 | `READING_DATE` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | التاريخ |
| 6 | `READING_VALUE` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | القراءة |
| 7 | `CONSUMPTION` | كمية | `NUMBER(24,6)` |  |  |  |  | محسوب |  | الاستهلاك |
| 8 | `SOURCE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MANUAL' |  | MANUAL, IMPORT, HANDOVER, MOVE_OUT | إدخال المستخدم |  | المصدر |
| 9 | `RENT_SCHEDULE_ID` | معرف | `NUMBER(19)` |  |  | FK→PRP_RENT_SCHEDULE |  | إدخال المستخدم |  | الفوترة الناتجة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRP_OWNER_STATEMENT

| البند | القيمة |
|---|---|
| الاسم العربي | كشوف حسابات الملاك |
| English | Owner Statements |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
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
| 6 | `MANAGEMENT_AGREEMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRP_MANAGEMENT_AGREEMENT |  | إدخال المستخدم |  | الاتفاقية |
| 7 | `PERIOD_FROM` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | من |
| 8 | `PERIOD_TO` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | إلى |
| 9 | `COLLECTIONS` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحصل |
| 10 | `EXPENSES` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المصروفات |
| 11 | `MANAGEMENT_FEE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الأتعاب |
| 12 | `NET_TO_OWNER` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الصافي للمالك |
| 13 | `AP_PAYMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_PAYMENT |  | إدخال المستخدم |  | التحويل للمالك |
| 14 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الكشف |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SENT, REMITTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_ROOM_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع الغرف |
| English | Room Types |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
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
| 7 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | الفندق/المبنى |
| 8 | `MAX_ADULTS` | عدد صحيح | `NUMBER(10)` | ✔ | 2 |  |  | إدخال المستخدم |  | أقصى بالغين |
| 9 | `MAX_CHILDREN` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | أقصى أطفال |
| 10 | `BED_CONFIG` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الأسرة |
| 11 | `BASE_RATE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | السعر الأساسي |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_ROOM

| البند | القيمة |
|---|---|
| الاسم العربي | الغرف والشقق الفندقية |
| English | Rooms |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PROPERTY_ID, ROOM_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY UK2 |  | إدخال المستخدم |  | الفندق |
| 6 | `ROOM_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_ROOM_TYPE |  | إدخال المستخدم |  | النوع |
| 7 | `UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة في السجل العقاري |
| 8 | `ROOM_NO` | نص | `VARCHAR2(20 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الغرفة |
| 9 | `FLOOR_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_FLOOR |  | إدخال المستخدم |  | الطابق |
| 10 | `FRONT_DESK_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'VACANT' |  | VACANT, OCCUPIED, DUE_OUT, DUE_IN, RESERVED, BLOCKED | إدخال المستخدم |  | حالة الاستقبال |
| 11 | `HOUSEKEEPING_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CLEAN' |  | CLEAN, DIRTY, INSPECTED, IN_PROGRESS, OUT_OF_ORDER | إدخال المستخدم |  | حالة النظافة |
| 12 | `CONNECTED_ROOM_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_ROOM |  | إدخال المستخدم |  | غرفة متصلة |
| 13 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات الغرفة |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, OUT_OF_ORDER, OUT_OF_SERVICE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_RATE_PLAN

| البند | القيمة |
|---|---|
| الاسم العربي | خطط الأسعار |
| English | Rate Plans |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
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
| 11 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | الفندق |
| 12 | `MEAL_PLAN` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | ROOM_ONLY, BREAKFAST, HALF_BOARD, FULL_BOARD, ALL_INCLUSIVE | إدخال المستخدم |  | الوجبات |
| 13 | `CANCELLATION_POLICY` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سياسة الإلغاء |
| 14 | `STAY_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DAILY' |  | DAILY, WEEKLY, MONTHLY | إدخال المستخدم |  | نوع الإقامة (يومي/أسبوعي/شهري مفروش) |
| 15 | `INCLUDES_TAX` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | شامل الضريبة |
| 16 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 17 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 18 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_RATE

| البند | القيمة |
|---|---|
| الاسم العربي | أسعار الغرف |
| English | Room Rates |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (RATE_PLAN_ID, ROOM_TYPE_ID, DATE_FROM) |
| قيود أعمال | DATE_TO >= DATE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RATE_PLAN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_RATE_PLAN UK1 |  | إدخال المستخدم |  | الخطة |
| 5 | `ROOM_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_ROOM_TYPE UK1 |  | إدخال المستخدم |  | النوع |
| 6 | `DATE_FROM` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | من |
| 7 | `DATE_TO` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | إلى |
| 8 | `RATE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر لليلة/الفترة |
| 9 | `EXTRA_ADULT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | بالغ إضافي |
| 10 | `MIN_STAY_NIGHTS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | أقل مدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_RESERVATION

| البند | القيمة |
|---|---|
| الاسم العربي | حجوزات الضيافة |
| English | Hospitality Reservations |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |
| قيود أعمال | DEPARTURE_DATE > ARRIVAL_DATE |

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
| 11 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | الفندق |
| 12 | `GUEST_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الضيف الرئيسي |
| 13 | `COMPANY_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الشركة/الجهة الحاجزة |
| 14 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | حساب الفوترة (City Ledger) |
| 15 | `CHANNEL_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'WALK_IN' |  | WALK_IN, PHONE, EMAIL, WEBSITE, OTA, CORPORATE, TRAVEL_AGENT | إدخال المستخدم |  | القناة |
| 16 | `CHANNEL_REFERENCE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع القناة |
| 17 | `ARRIVAL_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | الوصول |
| 18 | `DEPARTURE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | المغادرة |
| 19 | `ADULTS` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | البالغون |
| 20 | `CHILDREN` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الأطفال |
| 21 | `RATE_PLAN_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_RATE_PLAN |  | إدخال المستخدم |  | خطة السعر |
| 22 | `TOTAL_ESTIMATE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي التقديري |
| 23 | `DEPOSIT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | العربون |
| 24 | `SPECIAL_REQUESTS` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الطلبات الخاصة |
| 25 | `CANCELLED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإلغاء |
| 26 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'TENTATIVE' |  | TENTATIVE, CONFIRMED, GUARANTEED, CHECKED_IN, CHECKED_OUT, NO_SHOW, CANCELLED, WAITLIST | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 27 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 28 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 29 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 30 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 31 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_RESERVATION_ROOM

| البند | القيمة |
|---|---|
| الاسم العربي | غرف الحجز |
| English | Reservation Rooms |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | DEPARTURE_DATE > ARRIVAL_DATE |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RESERVATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_RESERVATION |  | إدخال المستخدم |  | الحجز |
| 5 | `ROOM_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_ROOM_TYPE |  | إدخال المستخدم |  | النوع المطلوب |
| 6 | `ROOM_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_ROOM |  | إدخال المستخدم |  | الغرفة المسندة |
| 7 | `ARRIVAL_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | الوصول |
| 8 | `DEPARTURE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | المغادرة |
| 9 | `NIGHTLY_RATE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | السعر لليلة (Snapshot) |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, ASSIGNED, CHECKED_IN, CHECKED_OUT, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_ROOM_BLOCK

| البند | القيمة |
|---|---|
| الاسم العربي | مخزون الغرف الزمني |
| English | Room Inventory Blocks |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | صف لكل غرفة/ليلة يمنع الحجز المزدوج بالقيد الفريد؛ Overbooking يعالج بخطة معتمدة |
| مفاتيح فريدة | UK1: (ROOM_ID, STAY_DATE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ROOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_ROOM UK1 |  | إدخال المستخدم |  | الغرفة |
| 5 | `STAY_DATE` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | الليلة |
| 6 | `BLOCK_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | RESERVATION, STAY, MAINTENANCE, OWNER_USE, OUT_OF_ORDER, HOLD | إدخال المستخدم |  | سبب الإشغال |
| 7 | `RESERVATION_ROOM_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_RESERVATION_ROOM |  | إدخال المستخدم |  | الحجز |
| 8 | `STAY_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_STAY |  | إدخال المستخدم |  | الإقامة |
| 9 | `MAINTENANCE_WO_ID` | معرف | `NUMBER(19)` |  |  | FK→MNT_WORK_ORDER |  | إدخال المستخدم |  | أمر الصيانة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_STAY

| البند | القيمة |
|---|---|
| الاسم العربي | الإقامات |
| English | Stays |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RESERVATION_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_RESERVATION |  | إدخال المستخدم |  | الحجز (فارغ = Walk-in مباشر) |
| 5 | `RESERVATION_ROOM_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_RESERVATION_ROOM |  | إدخال المستخدم |  | غرفة الحجز |
| 6 | `ROOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_ROOM |  | إدخال المستخدم |  | الغرفة |
| 7 | `CHECK_IN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | وقت الدخول |
| 8 | `EXPECTED_CHECK_OUT` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | المغادرة المتوقعة |
| 9 | `CHECK_OUT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الخروج |
| 10 | `CHECKED_IN_BY_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | موظف الاستقبال |
| 11 | `PREVIOUS_STAY_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_STAY |  | إدخال المستخدم |  | الإقامة السابقة عند تغيير الغرفة |
| 12 | `NIGHTLY_RATE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | سعر الليلة المطبق |
| 13 | `LAST_CHARGED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | آخر ليلة رحلت رسومها |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'IN_HOUSE' |  | IN_HOUSE, CHECKED_OUT, ROOM_MOVED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_STAY_GUEST

| البند | القيمة |
|---|---|
| الاسم العربي | نزلاء الإقامة |
| English | Stay Guests |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `STAY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_STAY |  | إدخال المستخدم |  | الإقامة |
| 5 | `GUEST_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | النزيل |
| 6 | `IDENTIFICATION_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_IDENTIFICATION |  | إدخال المستخدم |  | وثيقة الهوية/الجواز |
| 7 | `IS_PRIMARY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | النزيل الرئيسي |
| 8 | `GOV_REPORT_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع إبلاغ الجهات (شموس/طوارئ) |
| 9 | `ID_DATA_PURGE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ إتلاف بيانات الهوية (احتفاظ محدود) |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_FOLIO

| البند | القيمة |
|---|---|
| الاسم العربي | فواتير النزلاء المفتوحة |
| English | Guest Folios |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, COMPANY_ID, FOLIO_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 6 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 7 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 8 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 9 | `FOLIO_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الحساب |
| 10 | `STAY_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_STAY |  | إدخال المستخدم |  | الإقامة |
| 11 | `RESERVATION_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_RESERVATION |  | إدخال المستخدم |  | الحجز |
| 12 | `FOLIO_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GUEST' |  | GUEST, COMPANY, GROUP_MASTER, NON_GUEST | إدخال المستخدم |  | النوع |
| 13 | `PAYER_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الدافع |
| 14 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | التحويل إلى City Ledger |
| 15 | `BALANCE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | محسوب |  | الرصيد |
| 16 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | الفاتورة الضريبية النهائية |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, SETTLED, CLOSED, TRANSFERRED, VOID | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_FOLIO_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | حركات الفوليو |
| English | Folio Lines |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الغرض | لا تعدل الحركات؛ التصحيح بسطر عكسي |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `FOLIO_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_FOLIO |  | إدخال المستخدم |  | الحساب |
| 5 | `BUSINESS_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ العمل الفندقي |
| 6 | `LINE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ROOM_CHARGE, TAX, SERVICE_CHARGE, F_AND_B, LAUNDRY, MINIBAR, POS_CHARGE, OTHER_CHARGE, PAYMENT, ADJUSTMENT, TRANSFER | إدخال المستخدم |  | النوع |
| 7 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | البيان |
| 8 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ (مدين موجب / دفعة سالب) |
| 9 | `TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الضريبة |
| 10 | `POS_SALE_ID` | معرف | `NUMBER(19)` |  |  | FK→POS_SALE |  | إدخال المستخدم |  | بيع POS المحمل |
| 11 | `CASH_TRANSACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_TRANSACTION |  | إدخال المستخدم |  | الدفعة |
| 12 | `NIGHT_AUDIT_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_NIGHT_AUDIT |  | إدخال المستخدم |  | التدقيق الليلي المرحل |
| 13 | `REVERSAL_OF_ID` | معرف | `NUMBER(19)` |  |  | FK→HSP_FOLIO_LINE |  | إدخال المستخدم |  | السطر المعكوس |
| 14 | `PAYMENT_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | CASH, CARD, BANK_TRANSFER, CITY_LEDGER | إدخال المستخدم |  | طريقة السداد |
| 15 | `REFERENCE_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع (رقم العملية/الإيصال) |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## HSP_NIGHT_AUDIT

| البند | القيمة |
|---|---|
| الاسم العربي | التدقيق الليلي |
| English | Night Audits |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PROPERTY_ID, BUSINESS_DATE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PROPERTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→RE_PROPERTY UK2 |  | إدخال المستخدم |  | الفندق |
| 5 | `BUSINESS_DATE` | تاريخ | `DATE` | ✔ |  | UK2 |  | إدخال المستخدم |  | تاريخ العمل المقفل |
| 6 | `ROOM_REVENUE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | إيراد الغرف |
| 7 | `OCCUPANCY_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة الإشغال |
| 8 | `ADR` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | متوسط سعر الغرفة |
| 9 | `NO_SHOWS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدم الحضور |
| 10 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | إدخال المستخدم |  | الحدث المحاسبي |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'RUNNING' |  | RUNNING, COMPLETED, FAILED, ROLLED_BACK | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_HOUSEKEEPING_TASK

| البند | القيمة |
|---|---|
| الاسم العربي | مهام التدبير الفندقي |
| English | Housekeeping Tasks |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ROOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_ROOM |  | إدخال المستخدم |  | الغرفة |
| 5 | `TASK_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 6 | `TASK_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DEPARTURE_CLEAN, STAYOVER, DEEP_CLEAN, TURNDOWN, INSPECTION | إدخال المستخدم |  | النوع |
| 7 | `ASSIGNED_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | العامل |
| 8 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 9 | `COMPLETED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 10 | `INSPECTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المفتش |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, ASSIGNED, IN_PROGRESS, DONE, INSPECTED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HSP_ROOM_DISCREPANCY

| البند | القيمة |
|---|---|
| الاسم العربي | اختلافات حالة الغرف |
| English | Room Status Discrepancies |
| الحزمة المالكة | 17 — `NOONA_PROPERTY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | مطابقة اختلاف Front Desk مقابل Housekeeping (Skip/Sleep) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ROOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HSP_ROOM |  | إدخال المستخدم |  | الغرفة |
| 5 | `FRONT_DESK_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | حالة الاستقبال |
| 6 | `HOUSEKEEPING_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | حالة التدبير |
| 7 | `DETECTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت الاكتشاف |
| 8 | `RESOLUTION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعالجة |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, RESOLVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

