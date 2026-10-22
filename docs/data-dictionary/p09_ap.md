# قاموس البيانات — الحزمة 09: الموردون والحسابات الدائنة

**Suppliers & Accounts Payable** · الحزمة البرمجية المالكة `NOONA_AP_PKG` · ملف DDL `db/ddl/p09_ap.sql` · [ERD](../erd/p09_ap.md)

المورد دور على Party المركزي مع حساب لكل شركة؛ الفواتير والمستخلصات والالتزامات، والمطابقة الثلاثية، وجدولة الدفع والحجوزات والضمانات والاستقطاع، مع Maker-Checker على بيانات البنك.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`AP_SUPPLIER`](#ap_supplier) | الموردون | Suppliers | T | INTERNAL |
| [`AP_SUPPLIER_ACCOUNT`](#ap_supplier_account) | حسابات الموردين لكل شركة | Supplier Accounts | C | INTERNAL |
| [`AP_SUPPLIER_SITE`](#ap_supplier_site) | مواقع المورد | Supplier Sites | C | INTERNAL |
| [`AP_INVOICE`](#ap_invoice) | فواتير الموردين | Supplier Invoices | C | INTERNAL |
| [`AP_INVOICE_LINE`](#ap_invoice_line) | أسطر فواتير الموردين | Supplier Invoice Lines | C | INTERNAL |
| [`AP_INVOICE_MATCH`](#ap_invoice_match) | نتائج المطابقة الثلاثية | Three-Way Match Results | C | INTERNAL |
| [`AP_HOLD`](#ap_hold) | حجوزات الدفع | Payment Holds | C | INTERNAL |
| [`AP_OPEN_ITEM`](#ap_open_item) | الذمم الدائنة | Payable Open Items | C | INTERNAL |
| [`AP_PAYMENT_BATCH`](#ap_payment_batch) | دفعات السداد المقترحة | Payment Batches / Proposals | C | INTERNAL |
| [`AP_PAYMENT`](#ap_payment) | مدفوعات الموردين | Supplier Payments | C | INTERNAL |
| [`AP_PAYMENT_APPLICATION`](#ap_payment_application) | تخصيص المدفوعات | Payment Applications | C | INTERNAL |
| [`AP_RETENTION`](#ap_retention) | المحتجزات والضمانات | Retention Balances | C | INTERNAL |

## AP_SUPPLIER

| البند | القيمة |
|---|---|
| الاسم العربي | الموردون |
| English | Suppliers |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, PARTY_ID)<br>UK4: (TENANT_ID, SUPPLIER_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 UK4 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY UK3 |  | إدخال المستخدم |  | الطرف |
| 5 | `SUPPLIER_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK4 |  | إدخال المستخدم |  | رقم المورد |
| 6 | `SUPPLIER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GOODS' |  | GOODS, SERVICES, CONTRACTOR, SUBCONTRACTOR, CONSULTANT, UTILITY, GOVERNMENT, EMPLOYEE | إدخال المستخدم |  | النوع |
| 7 | `SUPPLIER_CLASS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | التصنيف |
| 8 | `IS_LOCAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | محلي |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PROSPECT' |  | PROSPECT, PENDING_APPROVAL, ACTIVE, ON_HOLD, BLOCKED, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_SUPPLIER_ACCOUNT

| البند | القيمة |
|---|---|
| الاسم العربي | حسابات الموردين لكل شركة |
| English | Supplier Accounts |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, ACCOUNT_NO)<br>UK3: (TENANT_ID, COMPANY_ID, SUPPLIER_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SUPPLIER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER UK3 |  | إدخال المستخدم |  | المورد |
| 5 | `ACCOUNT_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الحساب |
| 6 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 7 | `PAYMENT_TERM_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_PAYMENT_TERM |  | إدخال المستخدم |  | شروط الدفع |
| 8 | `PAYABLE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الدائنين الرقابي |
| 9 | `PREPAYMENT_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الدفعات المقدمة |
| 10 | `DEFAULT_BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_BANK_ACCOUNT |  | إدخال المستخدم |  | الحساب البنكي المعتمد |
| 11 | `WITHHOLDING_TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | ضريبة الاستقطاع |
| 12 | `DEFAULT_TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | ضريبة المدخلات |
| 13 | `MATCH_POLICY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'THREE_WAY' |  | NONE, TWO_WAY, THREE_WAY, CONTRACT | إدخال المستخدم |  | سياسة المطابقة |
| 14 | `REQUIRED_DOCS_OK` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | المستندات المطلوبة سارية |
| 15 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد (لا يكون من أنشأه) |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING_APPROVAL' |  | PENDING_APPROVAL, ACTIVE, ON_HOLD, BLOCKED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_SUPPLIER_SITE

| البند | القيمة |
|---|---|
| الاسم العربي | مواقع المورد |
| English | Supplier Sites |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | الحساب |
| 5 | `SITE_USE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PURCHASING, PAYMENT, BOTH | إدخال المستخدم |  | الاستخدام |
| 6 | `ADDRESS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→REF_ADDRESS |  | إدخال المستخدم |  | العنوان |
| 7 | `IS_PRIMARY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | الرئيسي |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_INVOICE

| البند | القيمة |
|---|---|
| الاسم العربي | فواتير الموردين |
| English | Supplier Invoices |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID)<br>UK4: (TENANT_ID, COMPANY_ID, SUPPLIER_ACCOUNT_ID, SUPPLIER_INVOICE_NO, INVOICE_TYPE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 UK4 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 UK4 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 7 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 8 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 9 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 10 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 11 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 12 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT UK4 |  | إدخال المستخدم |  | الحساب |
| 13 | `INVOICE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'STANDARD' | UK4 | STANDARD, CREDIT_MEMO, DEBIT_MEMO, PREPAYMENT, PROGRESS_CLAIM, EXPENSE, RENT, UTILITY | إدخال المستخدم |  | النوع |
| 14 | `SUPPLIER_INVOICE_NO` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK4 |  | إدخال المستخدم |  | رقم فاتورة المورد |
| 15 | `SUPPLIER_INVOICE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ فاتورة المورد |
| 16 | `GL_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ المحاسبي |
| 17 | `PURCHASE_ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_ORDER |  | إدخال المستخدم |  | أمر الشراء |
| 18 | `PROJECT_CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_CONTRACT |  | إدخال المستخدم |  | عقد المشروع/المقاول |
| 19 | `PROGRESS_CLAIM_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROGRESS_CLAIM |  | إدخال المستخدم |  | المستخلص |
| 20 | `ORIGINAL_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_INVOICE |  | إدخال المستخدم |  | الفاتورة الأصلية للإشعار |
| 21 | `PAYMENT_TERM_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_PAYMENT_TERM |  | إدخال المستخدم |  | شروط الدفع |
| 22 | `SUBTOTAL` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | قبل الضريبة |
| 23 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة |
| 24 | `WITHHOLDING_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الاستقطاع |
| 25 | `RETENTION_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحتجز (Retention) |
| 26 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي |
| 27 | `MATCH_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NOT_REQUIRED' |  | NOT_REQUIRED, PENDING, MATCHED, EXCEPTION, OVERRIDDEN | إدخال المستخدم |  | حالة المطابقة |
| 28 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع الاستلام المباشر |
| 29 | `INV_TRANSACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | حركة المخزون |
| 30 | `PAYMENT_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CREDIT' |  | CREDIT, CASH | إدخال المستخدم |  | آجل أو نقدي |
| 31 | `SETTLE_PLACE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الصندوق/البنك للفاتورة النقدية (BOX:n / BANK:n) |
| 32 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة الافتراضي |
| 33 | `DUPLICATE_CHECK_KEY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | محسوب |  | مفتاح كشف التكرار (المورد + الرقم المعياري + السنة) |
| 34 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, MATCH_EXCEPTION, ON_HOLD, APPROVED, POSTED, PARTIALLY_PAID, PAID, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 35 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 36 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 37 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 38 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 39 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 40 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 41 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 42 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 43 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_INVOICE_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر فواتير الموردين |
| English | Supplier Invoice Lines |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (INVOICE_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `INVOICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_INVOICE UK2 |  | إدخال المستخدم |  | الفاتورة |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
| 6 | `LINE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ITEM' |  | ITEM, SERVICE, EXPENSE, FREIGHT, ASSET, TAX_ADJ, RETENTION, ADVANCE_RECOVERY | إدخال المستخدم |  | النوع |
| 7 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 8 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 9 | `QUANTITY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الكمية |
| 10 | `UOM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 11 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | السعر |
| 12 | `LINE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 13 | `TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | الضريبة |
| 14 | `EXPENSE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب المصروف |
| 15 | `PO_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_ORDER_LINE |  | إدخال المستخدم |  | سطر أمر الشراء |
| 16 | `RECEIPT_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_RECEIPT_LINE |  | إدخال المستخدم |  | سطر الاستلام |
| 17 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 18 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 19 | `WBS_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 20 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل (رسملة) |
| 21 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الخصم |
| 22 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة |
| 23 | `LOT_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الدفعة المستلمة |
| 24 | `EXPIRY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الانتهاء |
| 25 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 26 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 27 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 28 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 29 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_INVOICE_MATCH

| البند | القيمة |
|---|---|
| الاسم العربي | نتائج المطابقة الثلاثية |
| English | Three-Way Match Results |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `INVOICE_LINE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_INVOICE_LINE |  | إدخال المستخدم |  | سطر الفاتورة |
| 5 | `PO_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_ORDER_LINE |  | إدخال المستخدم |  | سطر الأمر |
| 6 | `RECEIPT_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PUR_RECEIPT_LINE |  | إدخال المستخدم |  | سطر الاستلام |
| 7 | `QTY_VARIANCE` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | فرق الكمية |
| 8 | `PRICE_VARIANCE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | فرق السعر |
| 9 | `TAX_VARIANCE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | فرق الضريبة |
| 10 | `OVERRIDE_EXCEPTION_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_EXCEPTION |  | إدخال المستخدم |  | الاستثناء المعتمد |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MATCHED' |  | MATCHED, VARIANCE, OVERRIDDEN, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_HOLD

| البند | القيمة |
|---|---|
| الاسم العربي | حجوزات الدفع |
| English | Payment Holds |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | INVOICE_ID IS NOT NULL OR SUPPLIER_ACCOUNT_ID IS NOT NULL |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 5 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | أو المورد كاملاً |
| 6 | `HOLD_REASON` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MATCH_EXCEPTION, DISPUTE, MISSING_DOCUMENT, EXPIRED_REGISTRATION, BANK_CHANGE, BUDGET, MANUAL | إدخال المستخدم |  | السبب |
| 7 | `NOTES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 8 | `RELEASED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | رافع الحجز |
| 9 | `RELEASED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الوقت |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, RELEASED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_OPEN_ITEM

| البند | القيمة |
|---|---|
| الاسم العربي | الذمم الدائنة |
| English | Payable Open Items |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | OPEN_AMOUNT <= ORIGINAL_AMOUNT |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 6 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 7 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 8 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 9 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | الحساب |
| 10 | `INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 11 | `ITEM_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INVOICE, CREDIT_MEMO, PREPAYMENT, RETENTION, WITHHOLDING, ADJUSTMENT | إدخال المستخدم |  | النوع |
| 12 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | رقم المستند |
| 13 | `DUE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | الاستحقاق |
| 14 | `INSTALLMENT_NO` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | القسط |
| 15 | `ORIGINAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الأصلي |
| 16 | `OPEN_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المتبقي |
| 17 | `ORIGINAL_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الأصلي الوظيفي |
| 18 | `OPEN_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المتبقي الوظيفي |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, SCHEDULED, PARTIALLY_PAID, PAID, ON_HOLD, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_PAYMENT_BATCH

| البند | القيمة |
|---|---|
| الاسم العربي | دفعات السداد المقترحة |
| English | Payment Batches / Proposals |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
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
| 6 | `PAYMENT_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ الدفع |
| 7 | `BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_BANK_ACCOUNT |  | إدخال المستخدم |  | حساب الشركة البنكي |
| 8 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 9 | `SELECTION_CRITERIA` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | معايير الاختيار |
| 10 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي |
| 11 | `BANK_FILE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | ملف البنك |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PROPOSED, APPROVED, SUBMITTED, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_PAYMENT

| البند | القيمة |
|---|---|
| الاسم العربي | مدفوعات الموردين |
| English | Supplier Payments |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | الذي عدل حساب البنك لا يعتمد الدفع (SoD) |
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
| 12 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | الحساب |
| 13 | `BATCH_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_PAYMENT_BATCH |  | إدخال المستخدم |  | الدفعة |
| 14 | `PAYMENT_METHOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→REF_PAYMENT_METHOD |  | إدخال المستخدم |  | الطريقة |
| 15 | `PAYEE_BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_BANK_ACCOUNT |  | إدخال المستخدم |  | الحساب البنكي المستخدم فعلياً (Snapshot) |
| 16 | `PAYEE_IBAN_MASKED` | نص | `VARCHAR2(40 CHAR)` |  |  |  |  | إدخال المستخدم |  | IBAN وقت الدفع مقنعاً |
| 17 | `COMPANY_BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_BANK_ACCOUNT |  | إدخال المستخدم |  | حساب الشركة |
| 18 | `CASH_BOX_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_CASH_BOX |  | إدخال المستخدم |  | الصندوق |
| 19 | `CASH_TRANSACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_TRANSACTION |  | إدخال المستخدم |  | حركة البنك/الصندوق |
| 20 | `CHEQUE_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_CHEQUE |  | إدخال المستخدم |  | الشيك |
| 21 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 22 | `AMOUNT_FUNC` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الوظيفي |
| 23 | `UNAPPLIED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | غير المخصص |
| 24 | `FAILURE_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الفشل/الرد |
| 25 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SUBMITTED_TO_BANK, SETTLED, FAILED, REVERSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 26 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 27 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 28 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 29 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 30 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 31 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 32 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 33 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 34 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_PAYMENT_APPLICATION

| البند | القيمة |
|---|---|
| الاسم العربي | تخصيص المدفوعات |
| English | Payment Applications |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PAYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_PAYMENT |  | إدخال المستخدم |  | الدفعة |
| 5 | `OPEN_ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_OPEN_ITEM |  | إدخال المستخدم |  | الذمة |
| 6 | `APPLIED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 7 | `DISCOUNT_TAKEN` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الخصم المكتسب |
| 8 | `FX_GAIN_LOSS` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | فرق العملة |
| 9 | `APPLIED_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 10 | `REVERSAL_OF_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_PAYMENT_APPLICATION |  | إدخال المستخدم |  | إلغاء تخصيص |
| 11 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | إدخال المستخدم |  | الحدث المحاسبي |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'APPLIED' |  | APPLIED, UNAPPLIED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AP_RETENTION

| البند | القيمة |
|---|---|
| الاسم العربي | المحتجزات والضمانات |
| English | Retention Balances |
| الحزمة المالكة | 09 — `NOONA_AP_PKG` |
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
| 8 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | المورد/المقاول |
| 9 | `PROJECT_CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_CONTRACT |  | إدخال المستخدم |  | العقد |
| 10 | `INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_INVOICE |  | إدخال المستخدم |  | الفاتورة المصدر |
| 11 | `RETAINED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المحتجز |
| 12 | `RELEASED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المفرج عنه |
| 13 | `RELEASE_DUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | موعد الإفراج |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'HELD' |  | HELD, PARTIALLY_RELEASED, RELEASED, FORFEITED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

