# قاموس البيانات — الحزمة 12: المشتريات

**Procurement** · الحزمة البرمجية المالكة `NOONA_PROCUREMENT_PKG` · ملف DDL `db/ddl/p12_pur.sql` · [ERD](../erd/p12_pur.md)

Purchase Request → RFQ → Supplier Quotation → Evaluation/Award → Purchase Order → Receiving/Service Acceptance → Supplier Invoice → Payment مع كشف تجزئة الطلبات وفصل الصلاحيات والمرتجعات.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`PUR_REQUISITION`](#pur_requisition) | طلبات الشراء | Purchase Requisitions | C | INTERNAL |
| [`PUR_REQUISITION_LINE`](#pur_requisition_line) | أسطر طلبات الشراء | Requisition Lines | C | INTERNAL |
| [`PUR_RFQ`](#pur_rfq) | طلبات عروض الأسعار | Requests for Quotation | C | INTERNAL |
| [`PUR_RFQ_LINE`](#pur_rfq_line) | أسطر طلب العروض | RFQ Lines | C | INTERNAL |
| [`PUR_RFQ_SUPPLIER`](#pur_rfq_supplier) | الموردون المدعوون | RFQ Invited Suppliers | C | INTERNAL |
| [`PUR_QUOTATION`](#pur_quotation) | عروض الموردين | Supplier Quotations | C | INTERNAL |
| [`PUR_QUOTATION_LINE`](#pur_quotation_line) | أسطر عروض الموردين | Quotation Lines | C | INTERNAL |
| [`PUR_EVALUATION_CRITERION`](#pur_evaluation_criterion) | معايير التقييم | Evaluation Criteria | C | INTERNAL |
| [`PUR_EVALUATION_SCORE`](#pur_evaluation_score) | درجات التقييم | Evaluation Scores | C | INTERNAL |
| [`PUR_AWARD`](#pur_award) | قرارات الترسية | Award Decisions | C | INTERNAL |
| [`PUR_ORDER`](#pur_order) | أوامر الشراء | Purchase Orders | C | INTERNAL |
| [`PUR_ORDER_LINE`](#pur_order_line) | أسطر أوامر الشراء | Purchase Order Lines | C | INTERNAL |
| [`PUR_ORDER_REVISION`](#pur_order_revision) | مراجعات أوامر الشراء | Purchase Order Revisions | C | INTERNAL |
| [`PUR_RECEIPT`](#pur_receipt) | الاستلام وقبول الخدمات | Receipts & Service Acceptance | C | INTERNAL |
| [`PUR_RECEIPT_LINE`](#pur_receipt_line) | أسطر الاستلام | Receipt Lines | C | INTERNAL |
| [`PUR_RETURN`](#pur_return) | مرتجعات المشتريات | Purchase Returns | C | INTERNAL |
| [`PUR_RETURN_LINE`](#pur_return_line) | أسطر مرتجعات المشتريات | Purchase Return Lines | C | INTERNAL |

## PUR_REQUISITION

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات الشراء |
| English | Purchase Requisitions |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
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
| 8 | `REQUESTER_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الطالب |
| 9 | `ORG_UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_UNIT |  | إدخال المستخدم |  | الوحدة الطالبة |
| 10 | `PURCHASE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GOODS' |  | GOODS, SERVICES, ASSET, PROJECT, URGENT, FRAMEWORK_CALL_OFF | إدخال المستخدم |  | النوع |
| 11 | `REQUIRED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التاريخ المطلوب |
| 12 | `JUSTIFICATION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المبرر |
| 13 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 14 | `ESTIMATED_TOTAL` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي التقديري |
| 15 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 16 | `REVISION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | المراجعة |
| 17 | `SPLIT_CHECK_FLAG` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | النظام/الحزمة |  | اشتباه تجزئة لتجاوز حدود السلطة |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, PARTIALLY_ORDERED, ORDERED, REJECTED, CANCELLED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_REQUISITION_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر طلبات الشراء |
| English | Requisition Lines |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (REQUISITION_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `REQUISITION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_REQUISITION UK2 |  | إدخال المستخدم |  | الطلب |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
| 6 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 7 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 8 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية |
| 9 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 10 | `ESTIMATED_PRICE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | السعر التقديري |
| 11 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع التسليم |
| 12 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 13 | `WBS_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 14 | `BUDGET_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_BUDGET_LINE |  | إدخال المستخدم |  | بند الموازنة |
| 15 | `ORDERED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الكمية المطلوبة بأوامر |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, PARTIALLY_ORDERED, ORDERED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_RFQ

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات عروض الأسعار |
| English | Requests for Quotation |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
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
| 6 | `TITLE` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 7 | `RFQ_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'RFQ' |  | RFQ, RFP, TENDER, DIRECT | إدخال المستخدم |  | النوع |
| 8 | `CLOSING_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | موعد الإغلاق (يمنع الاطلاع المبكر) |
| 9 | `OPENED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت فتح العروض |
| 10 | `COMMITTEE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMMITTEE |  | إدخال المستخدم |  | لجنة العطاءات |
| 11 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 12 | `EVALUATION_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'LOWEST_COMPLIANT' |  | LOWEST_COMPLIANT, WEIGHTED_SCORE, QUALITY_BASED | إدخال المستخدم |  | طريقة التقييم |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PUBLISHED, CLOSED, UNDER_EVALUATION, AWARDED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 15 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_RFQ_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر طلب العروض |
| English | RFQ Lines |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (RFQ_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RFQ_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RFQ UK2 |  | إدخال المستخدم |  | الطلب |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
| 6 | `REQUISITION_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_REQUISITION_LINE |  | إدخال المستخدم |  | سطر طلب الشراء |
| 7 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 8 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 9 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية |
| 10 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_RFQ_SUPPLIER

| البند | القيمة |
|---|---|
| الاسم العربي | الموردون المدعوون |
| English | RFQ Invited Suppliers |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (RFQ_ID, SUPPLIER_ACCOUNT_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RFQ_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RFQ UK1 |  | إدخال المستخدم |  | الطلب |
| 5 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT UK1 |  | إدخال المستخدم |  | المورد |
| 6 | `INVITED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الدعوة |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INVITED' |  | INVITED, DECLINED, RESPONDED, DISQUALIFIED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_QUOTATION

| البند | القيمة |
|---|---|
| الاسم العربي | عروض الموردين |
| English | Supplier Quotations |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (RFQ_ID, SUPPLIER_ACCOUNT_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 5 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 6 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 7 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 8 | `RFQ_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RFQ UK2 |  | إدخال المستخدم |  | الطلب |
| 9 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT UK2 |  | إدخال المستخدم |  | المورد |
| 10 | `QUOTATION_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم عرض المورد |
| 11 | `RECEIVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | وقت الاستلام |
| 12 | `VALID_UNTIL` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | الصلاحية |
| 13 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي |
| 14 | `DELIVERY_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة التوريد |
| 15 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 16 | `IS_LATE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | وصل بعد الإغلاق |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'RECEIVED' |  | RECEIVED, SEALED, OPENED, COMPLIANT, NON_COMPLIANT, AWARDED, REJECTED, WITHDRAWN | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_QUOTATION_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر عروض الموردين |
| English | Quotation Lines |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (QUOTATION_ID, RFQ_LINE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `QUOTATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_QUOTATION UK1 |  | إدخال المستخدم |  | العرض |
| 5 | `RFQ_LINE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RFQ_LINE UK1 |  | إدخال المستخدم |  | سطر الطلب |
| 6 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر |
| 7 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية |
| 8 | `TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الضريبة |
| 9 | `REMARKS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_EVALUATION_CRITERION

| البند | القيمة |
|---|---|
| الاسم العربي | معايير التقييم |
| English | Evaluation Criteria |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RFQ_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RFQ |  | إدخال المستخدم |  | الطلب |
| 5 | `CRITERION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | TECHNICAL, FINANCIAL, COMPLIANCE, DELIVERY, QUALITY, LOCAL_CONTENT | إدخال المستخدم |  | النوع |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المعيار |
| 7 | `WEIGHT_PCT` | نسبة | `NUMBER(9,6)` | ✔ |  |  |  | إدخال المستخدم |  | الوزن (يحدد قبل فتح العروض) |
| 8 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_EVALUATION_SCORE

| البند | القيمة |
|---|---|
| الاسم العربي | درجات التقييم |
| English | Evaluation Scores |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `QUOTATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_QUOTATION |  | إدخال المستخدم |  | العرض |
| 5 | `CRITERION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_EVALUATION_CRITERION |  | إدخال المستخدم |  | المعيار |
| 6 | `EVALUATOR_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المقيم |
| 7 | `SCORE` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | الدرجة |
| 8 | `COMMENTS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الملاحظات |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## PUR_AWARD

| البند | القيمة |
|---|---|
| الاسم العربي | قرارات الترسية |
| English | Award Decisions |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RFQ_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RFQ |  | إدخال المستخدم |  | الطلب |
| 5 | `QUOTATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_QUOTATION |  | إدخال المستخدم |  | العرض الفائز |
| 6 | `JUSTIFICATION` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | سبب الاختيار (أقل سعر ليس ترسية تلقائية) |
| 7 | `AWARDED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | قيمة الترسية |
| 8 | `DECIDED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | تاريخ القرار |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, REJECTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر الشراء |
| English | Purchase Orders |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
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
| 8 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 9 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 10 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 11 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 12 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | المورد |
| 13 | `ORDER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'STANDARD' |  | STANDARD, BLANKET, CONTRACT, SERVICE, CALL_OFF | إدخال المستخدم |  | النوع |
| 14 | `PARENT_ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_ORDER |  | إدخال المستخدم |  | اتفاقية الإطار الأم |
| 15 | `AWARD_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_AWARD |  | إدخال المستخدم |  | الترسية |
| 16 | `PAYMENT_TERM_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_PAYMENT_TERM |  | إدخال المستخدم |  | شروط الدفع |
| 17 | `DELIVERY_WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع التسليم |
| 18 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 19 | `REVISION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | رقم المراجعة (Amendment) |
| 20 | `SUBTOTAL` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | قبل الضريبة |
| 21 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة |
| 22 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي |
| 23 | `MAX_TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | سقف اتفاقية الإطار |
| 24 | `RETENTION_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة المحتجز |
| 25 | `PROMISED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التوريد المتفق |
| 26 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, ISSUED, ACKNOWLEDGED, PARTIALLY_RECEIVED, RECEIVED, INVOICED, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 27 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 28 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 29 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 30 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 31 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 32 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_ORDER_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر أوامر الشراء |
| English | Purchase Order Lines |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (ORDER_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_ORDER UK2 |  | إدخال المستخدم |  | الأمر |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
| 6 | `REQUISITION_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_REQUISITION_LINE |  | إدخال المستخدم |  | سطر الطلب |
| 7 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 8 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 9 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية |
| 10 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 11 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر |
| 12 | `DISCOUNT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | الخصم |
| 13 | `TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الضريبة |
| 14 | `LINE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 15 | `RECEIVED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المستلم |
| 16 | `ACCEPTED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المقبول |
| 17 | `INVOICED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المفوتر |
| 18 | `RETURNED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرتجع |
| 19 | `PRICE_TOLERANCE_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | سماحية السعر |
| 20 | `QTY_TOLERANCE_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | سماحية الكمية |
| 21 | `NEED_BY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الحاجة |
| 22 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 23 | `WBS_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 24 | `EXPENSE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب المصروف للخدمات |
| 25 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, PARTIALLY_RECEIVED, RECEIVED, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 26 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 27 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 28 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 29 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 30 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_ORDER_REVISION

| البند | القيمة |
|---|---|
| الاسم العربي | مراجعات أوامر الشراء |
| English | Purchase Order Revisions |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| مفاتيح فريدة | UK1: (ORDER_ID, REVISION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_ORDER UK1 |  | إدخال المستخدم |  | الأمر |
| 5 | `REVISION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | المراجعة |
| 6 | `CHANGE_REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 7 | `ORDER_SNAPSHOT` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | لقطة الأمر قبل التعديل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## PUR_RECEIPT

| البند | القيمة |
|---|---|
| الاسم العربي | الاستلام وقبول الخدمات |
| English | Receipts & Service Acceptance |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يفصل الاستلام المادي عن قبول الجودة وأثر المخزون |
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
| 8 | `ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_ORDER |  | إدخال المستخدم |  | الأمر |
| 9 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | المورد |
| 10 | `RECEIPT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GOODS' |  | GOODS, SERVICE, PROGRESS | إدخال المستخدم |  | النوع |
| 11 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | المستودع |
| 12 | `DELIVERY_NOTE_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم إذن التسليم |
| 13 | `INV_TRANSACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | حركة المخزون |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, RECEIVED, QUALITY_CHECK, ACCEPTED, PARTIALLY_ACCEPTED, REJECTED, POSTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_RECEIPT_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر الاستلام |
| English | Receipt Lines |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (RECEIPT_ID, LINE_NO) |
| قيود أعمال | ACCEPTED_QTY + REJECTED_QTY <= RECEIVED_QTY |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RECEIPT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RECEIPT UK2 |  | إدخال المستخدم |  | الاستلام |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
| 6 | `ORDER_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_ORDER_LINE |  | إدخال المستخدم |  | سطر الأمر |
| 7 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 8 | `RECEIVED_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المستلم |
| 9 | `ACCEPTED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المقبول |
| 10 | `REJECTED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرفوض |
| 11 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 12 | `LOCATION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOCATION |  | إدخال المستخدم |  | الموقع |
| 13 | `LOT_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOT |  | إدخال المستخدم |  | الدفعة |
| 14 | `QUALITY_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, PASSED, FAILED, WAIVED | إدخال المستخدم |  | الجودة |
| 15 | `REJECT_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الرفض |
| 16 | `INVOICED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المفوتر |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_RETURN

| البند | القيمة |
|---|---|
| الاسم العربي | مرتجعات المشتريات |
| English | Purchase Returns |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
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
| 6 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | المورد |
| 7 | `RECEIPT_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_RECEIPT |  | إدخال المستخدم |  | الاستلام الأصلي |
| 8 | `REASON_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 9 | `INV_TRANSACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | حركة المخزون |
| 10 | `AP_CREDIT_MEMO_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_INVOICE |  | إدخال المستخدم |  | الإشعار الدائن من المورد |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SHIPPED, CREDITED, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PUR_RETURN_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر مرتجعات المشتريات |
| English | Purchase Return Lines |
| الحزمة المالكة | 12 — `NOONA_PROCUREMENT_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (RETURN_ID, LINE_NO) |
| قيود أعمال | QUANTITY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RETURN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RETURN UK1 |  | إدخال المستخدم |  | المرتجع |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | السطر |
| 6 | `RECEIPT_LINE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PUR_RECEIPT_LINE |  | إدخال المستخدم |  | سطر الاستلام |
| 7 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية (لا تتجاوز المقبول بعد المرتجعات السابقة) |
| 8 | `UOM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 9 | `LOT_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_LOT |  | إدخال المستخدم |  | الدفعة |
| 10 | `SERIAL_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_SERIAL |  | إدخال المستخدم |  | الرقم التسلسلي |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

