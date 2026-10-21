# قاموس البيانات — الحزمة 07: المحاسبة العامة والمحرك المحاسبي

**General Ledger & Accounting Engine** · الحزمة البرمجية المالكة `NOONA_GL_PKG` · ملف DDL `db/ddl/p07_gl.sql` · [ERD](../erd/p07_gl.md)

الدفاتر ودليل الحسابات الهرمي والتقويم المالي والفترات وحالتها حسب الوحدة، والقيود والأرصدة والأبعاد ومراكز التكلفة والموازنات والتجميع؛ والمحرك المحاسبي المركزي (NOONA_POSTING_PKG): Business Transaction → Accounting Event → Posting Rule → Journal → GL مع Idempotency ومنع الازدواج.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`GL_CHART_OF_ACCOUNTS`](#gl_chart_of_accounts) | أدلة الحسابات | Charts of Accounts | T | INTERNAL |
| [`GL_ACCOUNT`](#gl_account) | الحسابات | GL Accounts | T | INTERNAL |
| [`GL_FISCAL_CALENDAR`](#gl_fiscal_calendar) | التقويمات المالية | Fiscal Calendars | C | INTERNAL |
| [`GL_LEDGER`](#gl_ledger) | الدفاتر | Ledgers | C | INTERNAL |
| [`GL_FISCAL_YEAR`](#gl_fiscal_year) | السنوات المالية | Fiscal Years | C | INTERNAL |
| [`GL_PERIOD`](#gl_period) | الفترات المالية | Accounting Periods | C | INTERNAL |
| [`GL_PERIOD_STATUS`](#gl_period_status) | حالة الفترة حسب الوحدة | Period Status by Module | C | INTERNAL |
| [`GL_PERIOD_REOPEN`](#gl_period_reopen) | طلبات إعادة فتح الفترة | Period Reopen Requests | C | INTERNAL |
| [`GL_COST_CENTER`](#gl_cost_center) | مراكز التكلفة والربحية | Cost & Profit Centers | C | INTERNAL |
| [`GL_DIMENSION`](#gl_dimension) | الأبعاد المحاسبية | Accounting Dimensions | T | INTERNAL |
| [`GL_DIMENSION_VALUE`](#gl_dimension_value) | قيم الأبعاد المخصصة | Dimension Values | T | INTERNAL |
| [`GL_ACCOUNT_DIM_RULE`](#gl_account_dim_rule) | قواعد الأبعاد للحسابات | Account Dimension Rules | T | INTERNAL |
| [`GL_JOURNAL_SOURCE`](#gl_journal_source) | مصادر القيود | Journal Sources | TO | INTERNAL |
| [`GL_JOURNAL_TYPE`](#gl_journal_type) | أنواع القيود | Journal Types | TO | INTERNAL |
| [`GL_JOURNAL`](#gl_journal) | القيود | Journal Entries | C | INTERNAL |
| [`GL_JOURNAL_LINE`](#gl_journal_line) | أسطر القيود | Journal Lines | C | INTERNAL |
| [`GL_BALANCE`](#gl_balance) | أرصدة الحسابات | Account Balances | C | INTERNAL |
| [`GL_OPENING_BATCH`](#gl_opening_batch) | دفعات الأرصدة الافتتاحية | Opening Balance Batches | C | INTERNAL |
| [`GL_OPENING_LINE`](#gl_opening_line) | أسطر الأرصدة الافتتاحية | Opening Balance Lines | C | INTERNAL |
| [`GL_RECURRING_JOURNAL`](#gl_recurring_journal) | القيود الدورية | Recurring Journals | C | INTERNAL |
| [`GL_ALLOCATION_RULE`](#gl_allocation_rule) | قواعد توزيع التكاليف | Cost Allocation Rules | C | INTERNAL |
| [`GL_REVALUATION_RUN`](#gl_revaluation_run) | عمليات إعادة تقييم العملات | FX Revaluation Runs | C | INTERNAL |
| [`GL_REVALUATION_LINE`](#gl_revaluation_line) | أسطر إعادة التقييم | FX Revaluation Lines | C | INTERNAL |
| [`GL_CLOSE_TASK`](#gl_close_task) | مهام الإقفال | Period Close Checklist | C | INTERNAL |
| [`GL_CLOSE_SNAPSHOT`](#gl_close_snapshot) | لقطات الإقفال | Closing Snapshots | C | INTERNAL |
| [`GL_FIN_STATEMENT`](#gl_fin_statement) | تعريفات القوائم المالية | Financial Statement Definitions | TO | INTERNAL |
| [`GL_FIN_STATEMENT_LINE`](#gl_fin_statement_line) | أسطر القوائم المالية | Financial Statement Lines | TO | INTERNAL |
| [`GL_INTERCOMPANY_TXN`](#gl_intercompany_txn) | المعاملات بين الشركات | Intercompany Transactions | T | INTERNAL |
| [`GL_CONSOLIDATION_GROUP`](#gl_consolidation_group) | مجموعات التجميع | Consolidation Groups | T | INTERNAL |
| [`GL_CONSOLIDATION_RUN`](#gl_consolidation_run) | عمليات التجميع | Consolidation Runs | T | INTERNAL |
| [`GL_ELIMINATION_RULE`](#gl_elimination_rule) | قواعد الاستبعاد | Elimination Rules | T | INTERNAL |
| [`GL_BUDGET`](#gl_budget) | الموازنات | Budgets | C | INTERNAL |
| [`GL_BUDGET_LINE`](#gl_budget_line) | أسطر الموازنة | Budget Lines | C | INTERNAL |
| [`ACE_EVENT_CLASS`](#ace_event_class) | أصناف الأحداث المحاسبية | Accounting Event Classes | G | INTERNAL |
| [`ACE_ACCOUNTING_EVENT`](#ace_accounting_event) | الأحداث المحاسبية | Accounting Events | C | INTERNAL |
| [`ACE_POSTING_RULE`](#ace_posting_rule) | قواعد الترحيل | Posting Rules | TO | INTERNAL |
| [`ACE_POSTING_RULE_VERSION`](#ace_posting_rule_version) | إصدارات قواعد الترحيل | Posting Rule Versions | TO | INTERNAL |
| [`ACE_POSTING_RULE_LINE`](#ace_posting_rule_line) | أسطر قاعدة الترحيل | Posting Rule Lines | TO | INTERNAL |
| [`ACE_ACCOUNT_MAPPING`](#ace_account_mapping) | جداول اشتقاق الحسابات | Account Derivation Mappings | C | INTERNAL |
| [`ACE_EXCEPTION`](#ace_exception) | قائمة استثناءات الترحيل | Posting Exception Queue | C | INTERNAL |
| [`ACE_RECONCILIATION`](#ace_reconciliation) | مطابقة المصدر مع الأستاذ | Source-to-GL Reconciliation | C | INTERNAL |

## GL_CHART_OF_ACCOUNTS

| البند | القيمة |
|---|---|
| الاسم العربي | أدلة الحسابات |
| English | Charts of Accounts |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
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
| 6 | `OWNER_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'COMPANY' |  | TENANT, BUSINESS_GROUP, COMPANY | إدخال المستخدم |  | مستوى الملكية |
| 7 | `BUSINESS_GROUP_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_GROUP |  | إدخال المستخدم |  | المجموعة |
| 8 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 9 | `IS_TEMPLATE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | قالب |
| 10 | `SOURCE_TEMPLATE_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_CHART_OF_ACCOUNTS |  | إدخال المستخدم |  | القالب المصدر |
| 11 | `SEGMENT_SEPARATOR` | نص | `VARCHAR2(1 CHAR)` |  | '-' |  |  | إدخال المستخدم |  | فاصل المقاطع |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, LOCKED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_ACCOUNT

| البند | القيمة |
|---|---|
| الاسم العربي | الحسابات |
| English | GL Accounts |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COA_ID, ACCOUNT_CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>PARENT_ACCOUNT_ID IS NULL OR PARENT_ACCOUNT_ID <> ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `COA_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_CHART_OF_ACCOUNTS UK2 |  | إدخال المستخدم |  | دليل الحسابات |
| 6 | `ACCOUNT_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الحساب |
| 7 | `PARENT_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب الأب |
| 8 | `ACCOUNT_LEVEL` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | المستوى |
| 9 | `ACCOUNT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE, STATISTICAL | إدخال المستخدم |  | النوع |
| 10 | `NORMAL_BALANCE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DEBIT, CREDIT | إدخال المستخدم |  | الطبيعة |
| 11 | `IS_POSTABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | قابل للترحيل (لا ترحيل على حساب عنوان) |
| 12 | `IS_CONTROL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | حساب رقابي لدفتر فرعي |
| 13 | `SUBLEDGER_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | AR, AP, INV, FA, CASH, PAYROLL, TAX, INTERCOMPANY, PROJECT | إدخال المستخدم |  | الدفتر الفرعي |
| 14 | `ALLOW_MANUAL_POSTING` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يسمح بالقيد اليدوي (يمنع على الحسابات الرقابية) |
| 15 | `CURRENCY_RESTRICTION` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة مقيدة |
| 16 | `REVALUE_FX` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يعاد تقييمه بالعملة الأجنبية |
| 17 | `CASH_FLOW_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | OPERATING, INVESTING, FINANCING, CASH, NONE | إدخال المستخدم |  | تصنيف التدفق النقدي |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, BLOCKED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 20 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_FISCAL_CALENDAR

| البند | القيمة |
|---|---|
| الاسم العربي | التقويمات المالية |
| English | Fiscal Calendars |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
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
| 7 | `PERIOD_PATTERN` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MONTHLY_12' |  | MONTHLY_12, PERIODS_13, PATTERN_445, PATTERN_454, PATTERN_544, WEEKLY, CUSTOM | إدخال المستخدم |  | نمط الفترات |
| 8 | `ADJUSTMENT_PERIODS` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | عدد فترات التسوية |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_LEDGER

| البند | القيمة |
|---|---|
| الاسم العربي | الدفاتر |
| English | Ledgers |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
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
| 7 | `LEDGER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PRIMARY' |  | PRIMARY, SECONDARY, TAX, IFRS, LOCAL_GAAP, CONSOLIDATION | إدخال المستخدم |  | النوع |
| 8 | `COA_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_CHART_OF_ACCOUNTS |  | إدخال المستخدم |  | دليل الحسابات |
| 9 | `CALENDAR_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_FISCAL_CALENDAR |  | إدخال المستخدم |  | التقويم |
| 10 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة الوظيفية للدفتر |
| 11 | `RETAINED_EARNINGS_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الأرباح المحتجزة |
| 12 | `ROUNDING_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب فروق التقريب |
| 13 | `SUSPENSE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب المعلق |
| 14 | `FX_GAIN_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | أرباح العملة المحققة |
| 15 | `FX_LOSS_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | خسائر العملة المحققة |
| 16 | `UNREALIZED_FX_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | فروق التقييم غير المحققة |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_FISCAL_YEAR

| البند | القيمة |
|---|---|
| الاسم العربي | السنوات المالية |
| English | Fiscal Years |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, CALENDAR_ID, CODE) |
| قيود أعمال | END_DATE > START_DATE |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `CALENDAR_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_FISCAL_CALENDAR UK2 |  | إدخال المستخدم |  | التقويم |
| 8 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 9 | `END_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 10 | `IS_SHORT_YEAR` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | سنة قصيرة/انتقالية |
| 11 | `PREVIOUS_YEAR_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_FISCAL_YEAR |  | إدخال المستخدم |  | السنة السابقة |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'FUTURE' |  | FUTURE, OPEN, CLOSING, CLOSED, PERMANENTLY_CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_PERIOD

| البند | القيمة |
|---|---|
| الاسم العربي | الفترات المالية |
| English | Accounting Periods |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (FISCAL_YEAR_ID, PERIOD_NO)<br>UK3: (TENANT_ID, COMPANY_ID, PERIOD_CODE) |
| قيود أعمال | END_DATE >= START_DATE |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `FISCAL_YEAR_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_FISCAL_YEAR UK2 |  | إدخال المستخدم |  | السنة |
| 7 | `PERIOD_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الفترة |
| 8 | `PERIOD_CODE` | نص | `VARCHAR2(20 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | الرمز (2026-01) |
| 9 | `PERIOD_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | OPENING, NORMAL, ADJUSTMENT, CLOSING | إدخال المستخدم |  | النوع |
| 10 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 11 | `END_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_PERIOD_STATUS

| البند | القيمة |
|---|---|
| الاسم العربي | حالة الفترة حسب الوحدة |
| English | Period Status by Module |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | SOFT_CLOSED يعاد فتحه بصلاحية؛ HARD_CLOSED باعتماد أعلى؛ PERMANENTLY_CLOSED يصحح بقيود لاحقة |
| مفاتيح فريدة | UK2: (PERIOD_ID, LEDGER_ID, MODULE_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD UK2 |  | إدخال المستخدم |  | الفترة |
| 5 | `LEDGER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_LEDGER UK2 |  | إدخال المستخدم |  | الدفتر |
| 6 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 | GL, AR, AP, INV, SALES, PURCHASE, CASH, FA, PAYROLL, PROJECT, REAL_ESTATE, LEASING, MFG | إدخال المستخدم |  | الوحدة |
| 7 | `CLOSED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | من أغلق |
| 8 | `CLOSED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإغلاق |
| 9 | `CLOSE_SNAPSHOT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_CLOSE_SNAPSHOT |  | إدخال المستخدم |  | لقطة الإغلاق |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'FUTURE' |  | FUTURE, OPEN, SOFT_CLOSED, HARD_CLOSED, PERMANENTLY_CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_PERIOD_REOPEN

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات إعادة فتح الفترة |
| English | Period Reopen Requests |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PERIOD_STATUS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD_STATUS |  | إدخال المستخدم |  | الفترة/الوحدة |
| 5 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | GL, AR, AP, INV, SALES, PURCHASE, CASH, FA, PAYROLL, PROJECT, REAL_ESTATE, LEASING, MFG | إدخال المستخدم |  | الوحدة |
| 6 | `REASON` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب الإلزامي |
| 7 | `REOPEN_UNTIL` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | المدة |
| 8 | `ALLOWED_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم المسموح |
| 9 | `BEFORE_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الأرصدة قبل |
| 10 | `AFTER_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الأرصدة بعد |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, REOPENED, RECLOSED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_COST_CENTER

| البند | القيمة |
|---|---|
| الاسم العربي | مراكز التكلفة والربحية |
| English | Cost & Profit Centers |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>PARENT_CENTER_ID IS NULL OR PARENT_CENTER_ID <> ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `CENTER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'COST' |  | COST, PROFIT, REVENUE, INVESTMENT | إدخال المستخدم |  | النوع |
| 8 | `PARENT_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | المركز الأب |
| 9 | `MANAGER_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | منصب المسؤول |
| 10 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, BLOCKED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_DIMENSION

| البند | القيمة |
|---|---|
| الاسم العربي | الأبعاد المحاسبية |
| English | Accounting Dimensions |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
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
| 6 | `DIMENSION_KIND` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SYSTEM, CUSTOM | إدخال المستخدم |  | نظامي أو مخصص |
| 7 | `SLOT_NO` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | رقم الخانة في سطر القيد (DIM1..DIM5) للأبعاد المخصصة |
| 8 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | مصدر القيم للأبعاد النظامية |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_DIMENSION_VALUE

| البند | القيمة |
|---|---|
| الاسم العربي | قيم الأبعاد المخصصة |
| English | Dimension Values |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, DIMENSION_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `DIMENSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_DIMENSION UK2 |  | إدخال المستخدم |  | البعد |
| 7 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 8 | `PARENT_VALUE_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_DIMENSION_VALUE |  | إدخال المستخدم |  | القيمة الأم |
| 9 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 10 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_ACCOUNT_DIM_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد الأبعاد للحسابات |
| English | Account Dimension Rules |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (ACCOUNT_ID, DIMENSION_ID, EFFECTIVE_FROM) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_ACCOUNT UK1 |  | إدخال المستخدم |  | الحساب |
| 4 | `DIMENSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_DIMENSION UK1 |  | إدخال المستخدم |  | البعد |
| 5 | `RULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | REQUIRED, OPTIONAL, FORBIDDEN | إدخال المستخدم |  | القاعدة |
| 6 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) | UK1 |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 7 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_JOURNAL_SOURCE

| البند | القيمة |
|---|---|
| الاسم العربي | مصادر القيود |
| English | Journal Sources |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
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
| 6 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحزمة |
| 7 | `ALLOW_MANUAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بالإدخال اليدوي |
| 8 | `REQUIRES_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يتطلب اعتماداً |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_JOURNAL_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع القيود |
| English | Journal Types |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | نوع القيد يحدد قواعد إدخاله وظهوره في التقارير؛ GL_JOURNAL.JOURNAL_CATEGORY يحمل رمز النوع |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `TYPE_GROUP` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MANUAL, SYSTEM | إدخال المستخدم |  | المجموعة: يدوي يدخله المحاسب، أو آلي من مستند مصدر |
| 7 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوحدة المصدرة |
| 8 | `ALLOW_MANUAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بالإدخال اليدوي |
| 9 | `IS_OPENING` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | قيد افتتاحي (أول فترة في السنة المالية) |
| 10 | `IS_ADJUSTMENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | قيد تسوية |
| 11 | `AUTO_REVERSE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يعكس آلياً في أول يوم من الفترة التالية (الاستحقاقات) |
| 12 | `EXCLUDE_FROM_PL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يستبعد من قائمة الدخل (قيد الإقفال) |
| 13 | `REQUIRES_REFERENCE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب رقماً مرجعياً |
| 14 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف ومتى يستخدم |
| 15 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 16 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_JOURNAL

| البند | القيمة |
|---|---|
| الاسم العربي | القيود |
| English | Journal Entries |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | القيد المرحل لا يعدل ولا يمحى؛ يصحح بعكس أو تسوية (BR-007) |
| الاحتفاظ | دائم حسب القانون |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID) |
| قيود أعمال | STATUS_CODE <> 'POSTED' OR TOTAL_DEBIT_FUNC = TOTAL_CREDIT_FUNC |

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
| 12 | `LEDGER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_LEDGER |  | إدخال المستخدم |  | الدفتر |
| 13 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD |  | إدخال المستخدم |  | الفترة |
| 14 | `POSTING_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ القيد (قد يختلف عن تاريخ المعاملة) |
| 15 | `JOURNAL_SOURCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_JOURNAL_SOURCE |  | إدخال المستخدم |  | المصدر |
| 16 | `JOURNAL_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع القيد (رمز من GL_JOURNAL_TYPE) |
| 17 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | إدخال المستخدم |  | الحدث المحاسبي المولد |
| 18 | `RULE_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_POSTING_RULE_VERSION |  | إدخال المستخدم |  | إصدار قاعدة الترحيل |
| 19 | `REFERENCE_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع |
| 20 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | البيان |
| 21 | `IS_OPENING` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | قيد افتتاحي |
| 22 | `IS_ADJUSTMENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | قيد تسوية |
| 23 | `REVERSAL_OF_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL |  | إدخال المستخدم |  | القيد المعكوس |
| 24 | `REVERSED_BY_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL |  | إدخال المستخدم |  | قيد العكس |
| 25 | `AUTO_REVERSE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ العكس الآلي |
| 26 | `TOTAL_DEBIT_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | محسوب |  | إجمالي المدين بالعملة الوظيفية |
| 27 | `TOTAL_CREDIT_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | محسوب |  | إجمالي الدائن بالعملة الوظيفية |
| 28 | `INTERCOMPANY_TXN_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_INTERCOMPANY_TXN |  | إدخال المستخدم |  | معاملة بين الشركات |
| 29 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد (لا يكون المنشئ - SoD) |
| 30 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل |
| 31 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 32 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, POSTED, REVERSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 33 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 34 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 35 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 36 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 37 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 38 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 39 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_JOURNAL_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر القيود |
| English | Journal Lines |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الاحتفاظ | دائم؛ مرشح للتقسيم حسب السنة |
| مفاتيح فريدة | UK2: (JOURNAL_ID, LINE_NO) |
| قيود أعمال | DEBIT_AMOUNT >= 0 AND CREDIT_AMOUNT >= 0<br>NOT (DEBIT_AMOUNT > 0 AND CREDIT_AMOUNT > 0) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `JOURNAL_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_JOURNAL UK2 |  | إدخال المستخدم |  | القيد |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم السطر |
| 6 | `ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب |
| 7 | `ACCOUNT_CODE_SNAPSHOT` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | رمز الحساب التاريخي |
| 8 | `DEBIT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | مدين بعملة المعاملة |
| 9 | `CREDIT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | دائن بعملة المعاملة |
| 10 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 11 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` | ✔ | 1 |  |  | إدخال المستخدم |  | السعر المستخدم |
| 12 | `DEBIT_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | مدين بالعملة الوظيفية |
| 13 | `CREDIT_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | دائن بالعملة الوظيفية |
| 14 | `DEBIT_REPORTING` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | مدين بعملة التقارير |
| 15 | `CREDIT_REPORTING` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | دائن بعملة التقارير |
| 16 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 17 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 18 | `ORG_UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_UNIT |  | إدخال المستخدم |  | الوحدة |
| 19 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 20 | `WBS_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند هيكل العمل |
| 21 | `PROPERTY_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_PROPERTY |  | إدخال المستخدم |  | العقار |
| 22 | `UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→RE_UNIT |  | إدخال المستخدم |  | الوحدة العقارية |
| 23 | `PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف |
| 24 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 25 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 26 | `DIM1_VALUE_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_DIMENSION_VALUE |  | إدخال المستخدم |  | بعد مخصص 1 |
| 27 | `DIM2_VALUE_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_DIMENSION_VALUE |  | إدخال المستخدم |  | بعد مخصص 2 |
| 28 | `DIM3_VALUE_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_DIMENSION_VALUE |  | إدخال المستخدم |  | بعد مخصص 3 |
| 29 | `TAX_CODE_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_TAX_CODE |  | إدخال المستخدم |  | كود الضريبة |
| 30 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | البيان |
| 31 | `SOURCE_LINE_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع سطر المصدر |
| 32 | `RECONCILIATION_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع المطابقة |
| 33 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 34 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 35 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 36 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 37 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_BALANCE

| البند | القيمة |
|---|---|
| الاسم العربي | أرصدة الحسابات |
| English | Account Balances |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | رصيد مشتق يعاد بناؤه من GL_JOURNAL_LINE المرحلة؛ مصدر الحقيقة هو القيود |
| مفاتيح فريدة | UK1: (LEDGER_ID, PERIOD_ID, ACCOUNT_ID, CURRENCY_CODE, DIMENSION_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `LEDGER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_LEDGER UK1 |  | إدخال المستخدم |  | الدفتر |
| 5 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD UK1 |  | إدخال المستخدم |  | الفترة |
| 6 | `ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_ACCOUNT UK1 |  | إدخال المستخدم |  | الحساب |
| 7 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY UK1 |  | إدخال المستخدم |  | العملة |
| 8 | `DIMENSION_KEY` | نص | `VARCHAR2(200 CHAR)` | ✔ | '-' | UK1 |  | إدخال المستخدم |  | مفتاح تجميع الأبعاد |
| 9 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 10 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 11 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 12 | `OPENING_DR_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | رصيد أول المدة مدين |
| 13 | `OPENING_CR_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | رصيد أول المدة دائن |
| 14 | `PERIOD_DR_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | حركة مدين |
| 15 | `PERIOD_CR_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | حركة دائن |
| 16 | `PERIOD_DR_TXN` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | حركة مدين بعملة المعاملة |
| 17 | `PERIOD_CR_TXN` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | حركة دائن بعملة المعاملة |
| 18 | `LAST_REBUILT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر إعادة بناء من الحركات |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_OPENING_BATCH

| البند | القيمة |
|---|---|
| الاسم العربي | دفعات الأرصدة الافتتاحية |
| English | Opening Balance Batches |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يمنع التحميل المكرر لنفس النطاق والفترة دون خطة إلغاء واعتماد |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, LEDGER_ID, PERIOD_ID, SCOPE_CODE, BATCH_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BATCH_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرقم |
| 5 | `LEDGER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_LEDGER UK2 |  | إدخال المستخدم |  | الدفتر |
| 6 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD UK2 |  | إدخال المستخدم |  | فترة الافتتاح |
| 7 | `SCOPE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 | GL, AR, AP, INV, FA, CASH | إدخال المستخدم |  | النطاق |
| 8 | `SOURCE_SYSTEM` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | النظام المصدر |
| 9 | `JOURNAL_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL |  | إدخال المستخدم |  | القيد الناتج |
| 10 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | ملف المصدر |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, VALIDATED, APPROVED, POSTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_OPENING_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر الأرصدة الافتتاحية |
| English | Opening Balance Lines |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (BATCH_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 5 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 6 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 7 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 8 | `BATCH_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_OPENING_BATCH UK1 |  | إدخال المستخدم |  | الدفعة |
| 9 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | السطر |
| 10 | `SOURCE_ACCOUNT` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحساب في النظام المصدر |
| 11 | `ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب |
| 12 | `DEBIT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | مدين |
| 13 | `CREDIT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | دائن |
| 14 | `DEBIT_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | مدين وظيفي |
| 15 | `CREDIT_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | دائن وظيفي |
| 16 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 17 | `PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_RECURRING_JOURNAL

| البند | القيمة |
|---|---|
| الاسم العربي | القيود الدورية |
| English | Recurring Journals |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `LEDGER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_LEDGER |  | إدخال المستخدم |  | الدفتر |
| 8 | `FREQUENCY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MONTHLY, QUARTERLY, YEARLY | إدخال المستخدم |  | التكرار |
| 9 | `TEMPLATE_LINES` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | الأسطر النموذجية |
| 10 | `LAST_GENERATED_PERIOD_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_PERIOD |  | إدخال المستخدم |  | آخر فترة ولدت |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, SUSPENDED, ENDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_ALLOCATION_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد توزيع التكاليف |
| English | Cost Allocation Rules |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `SOURCE_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب المصدر |
| 8 | `SOURCE_COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | المركز المصدر |
| 9 | `BASIS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FIXED_PCT, HEADCOUNT, AREA, REVENUE, HOURS, STATISTICAL | إدخال المستخدم |  | أساس التوزيع |
| 10 | `TARGETS` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | المراكز المستهدفة ونسبها |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_REVALUATION_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات إعادة تقييم العملات |
| English | FX Revaluation Runs |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `LEDGER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_LEDGER |  | إدخال المستخدم |  | الدفتر |
| 5 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD |  | إدخال المستخدم |  | الفترة |
| 6 | `RATE_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→REF_RATE_TYPE |  | إدخال المستخدم |  | نوع السعر |
| 7 | `RATE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ السعر |
| 8 | `SCOPE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | GL, AR, AP, CASH, ALL | إدخال المستخدم |  | النطاق |
| 9 | `JOURNAL_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL |  | إدخال المستخدم |  | القيد الناتج |
| 10 | `AUTO_REVERSE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | عكس آلي أول الفترة التالية |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, CALCULATED, POSTED, REVERSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_REVALUATION_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر إعادة التقييم |
| English | FX Revaluation Lines |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RUN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_REVALUATION_RUN |  | إدخال المستخدم |  | العملية |
| 5 | `ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب |
| 6 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة الأجنبية |
| 7 | `PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف |
| 8 | `FOREIGN_BALANCE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الرصيد الأجنبي |
| 9 | `BOOK_FUNC_BALANCE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الرصيد الدفتري الوظيفي |
| 10 | `NEW_RATE` | سعر/معدل | `NUMBER(28,12)` | ✔ |  |  |  | إدخال المستخدم |  | السعر الجديد |
| 11 | `REVALUED_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الرصيد المقيم |
| 12 | `DIFFERENCE_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الفرق |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_CLOSE_TASK

| البند | القيمة |
|---|---|
| الاسم العربي | مهام الإقفال |
| English | Period Close Checklist |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PERIOD_ID, TASK_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD UK1 |  | إدخال المستخدم |  | الفترة |
| 5 | `TASK_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | المهمة (ترحيل المستندات، إقفال المخزون، تقييم العملات، مطابقة البنوك...) |
| 6 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوحدة |
| 7 | `OWNER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المسؤول |
| 8 | `COMPLETED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الإنجاز |
| 9 | `EVIDENCE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الدليل |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, IN_PROGRESS, DONE, WAIVED, BLOCKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_CLOSE_SNAPSHOT

| البند | القيمة |
|---|---|
| الاسم العربي | لقطات الإقفال |
| English | Closing Snapshots |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD |  | إدخال المستخدم |  | الفترة |
| 5 | `LEDGER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_LEDGER |  | إدخال المستخدم |  | الدفتر |
| 6 | `TRIAL_BALANCE` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | ميزان المراجعة وقت الإقفال |
| 7 | `CHECKS_RESULT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نتائج المطابقات |
| 8 | `SIGNED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | الموقع |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## GL_FIN_STATEMENT

| البند | القيمة |
|---|---|
| الاسم العربي | تعريفات القوائم المالية |
| English | Financial Statement Definitions |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `STATEMENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BALANCE_SHEET, INCOME_STATEMENT, CASH_FLOW, EQUITY_CHANGES, TRIAL_BALANCE, CUSTOM | إدخال المستخدم |  | النوع |
| 7 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 8 | `COA_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_CHART_OF_ACCOUNTS |  | إدخال المستخدم |  | دليل الحسابات |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_FIN_STATEMENT_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر القوائم المالية |
| English | Financial Statement Lines |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (STATEMENT_ID, LINE_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `STATEMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_FIN_STATEMENT UK1 |  | إدخال المستخدم |  | القائمة |
| 4 | `LINE_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز السطر |
| 5 | `LABEL_AR` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان بالعربية |
| 6 | `LABEL_EN` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان بالإنجليزية |
| 7 | `PARENT_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_FIN_STATEMENT_LINE |  | إدخال المستخدم |  | السطر الأب |
| 8 | `LINE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | HEADER, ACCOUNTS, FORMULA, TOTAL | إدخال المستخدم |  | النوع |
| 9 | `ACCOUNT_RANGES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نطاقات الحسابات |
| 10 | `FORMULA` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعادلة |
| 11 | `SIGN_REVERSE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | عكس الإشارة |
| 12 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_INTERCOMPANY_TXN

| البند | القيمة |
|---|---|
| الاسم العربي | المعاملات بين الشركات |
| English | Intercompany Transactions |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, IC_REFERENCE) |
| قيود أعمال | FROM_COMPANY_ID <> TO_COMPANY_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 4 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 5 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 6 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 7 | `IC_REFERENCE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | المرجع الموحد بين المستندين |
| 8 | `FROM_COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المصدرة |
| 9 | `TO_COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المقابلة |
| 10 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 11 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | المستند المصدر |
| 12 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرفه |
| 13 | `CONFIRMED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | مؤكد الطرف الثاني |
| 14 | `MATCH_DIFFERENCE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | فرق المطابقة |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SENT, CONFIRMED, POSTED_BOTH, MATCHED, DISPUTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_CONSOLIDATION_GROUP

| البند | القيمة |
|---|---|
| الاسم العربي | مجموعات التجميع |
| English | Consolidation Groups |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
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
| 6 | `BUSINESS_GROUP_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_GROUP |  | إدخال المستخدم |  | مجموعة الأعمال |
| 7 | `CONSOLIDATION_CURRENCY` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة التجميع |
| 8 | `COA_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_CHART_OF_ACCOUNTS |  | إدخال المستخدم |  | دليل حسابات التجميع |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_CONSOLIDATION_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات التجميع |
| English | Consolidation Runs |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا يغير التجميع دفاتر الشركات القانونية |
| مفاتيح فريدة | UK1: (GROUP_ID, PERIOD_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `GROUP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_CONSOLIDATION_GROUP UK1 |  | إدخال المستخدم |  | المجموعة |
| 4 | `PERIOD_CODE` | نص | `VARCHAR2(20 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الفترة |
| 5 | `CLOSING_RATE_TYPE_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_RATE_TYPE |  | إدخال المستخدم |  | سعر الإقفال |
| 6 | `AVERAGE_RATE_TYPE_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_RATE_TYPE |  | إدخال المستخدم |  | السعر المتوسط |
| 7 | `RESULT_DATA` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | النتائج والترجمة وفروقها |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, TRANSLATED, ELIMINATED, APPROVED, PUBLISHED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_ELIMINATION_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد الاستبعاد |
| English | Elimination Rules |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `GROUP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_CONSOLIDATION_GROUP |  | إدخال المستخدم |  | المجموعة |
| 7 | `RULE_DEFINITION` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | الحسابات المتقابلة وطريقة الاستبعاد |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_BUDGET

| البند | القيمة |
|---|---|
| الاسم العربي | الموازنات |
| English | Budgets |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
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
| 7 | `LEDGER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_LEDGER |  | إدخال المستخدم |  | الدفتر |
| 8 | `FISCAL_YEAR_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_FISCAL_YEAR |  | إدخال المستخدم |  | السنة |
| 9 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | الإصدار |
| 10 | `CONTROL_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'WARN' |  | NONE, WARN, BLOCK | إدخال المستخدم |  | مستوى الرقابة على الموازنة |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, ACTIVE, FROZEN, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## GL_BUDGET_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر الموازنة |
| English | Budget Lines |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BUDGET_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_BUDGET |  | إدخال المستخدم |  | الموازنة |
| 5 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD |  | إدخال المستخدم |  | الفترة |
| 6 | `ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب |
| 7 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 8 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 9 | `BUDGET_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ المعتمد |
| 10 | `COMMITTED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | النظام/الحزمة |  | الالتزامات (طلبات/أوامر) |
| 11 | `ACTUAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | النظام/الحزمة |  | الفعلي |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ACE_EVENT_CLASS

| البند | القيمة |
|---|---|
| الاسم العربي | أصناف الأحداث المحاسبية |
| English | Accounting Event Classes |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `EVENT_FAMILY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العائلة (SALES، PURCHASE، INVENTORY، CASH، FA، PAYROLL، MFG، PROJECT، RE، LEASE) |
| 6 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع المستند المصدر |
| 7 | `POSTING_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OUTBOX' |  | SAME_TRANSACTION, OUTBOX | إدخال المستخدم |  | الترحيل في نفس المعاملة أو عبر Outbox |
| 8 | `MAX_DELAY_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | أقصى تأخر مقبول |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ACE_ACCOUNTING_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | الأحداث المحاسبية |
| English | Accounting Events |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا يسمح بترحيل الأثر نفسه مرتين حتى عند Retry (29.4) |
| مفاتيح فريدة | UK2: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE |
| 5 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة) |
| 6 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 7 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 8 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 9 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 10 | `EVENT_CLASS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ACE_EVENT_CLASS |  | إدخال المستخدم |  | الصنف |
| 11 | `LEDGER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_LEDGER |  | إدخال المستخدم |  | الدفتر |
| 12 | `SOURCE_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | إصدار المصدر |
| 13 | `EVENT_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ السريان |
| 14 | `ACCOUNTING_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ القيد |
| 15 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ |
| 16 | `EVENT_DATA` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | لقطة قيم المصدر (المبالغ والأبعاد ومراجع الضرائب) |
| 17 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(200 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | Tenant + نوع الحدث + المصدر + الإصدار + نوع الأثر |
| 18 | `ATTEMPTS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحاولات |
| 19 | `LAST_ERROR` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | آخر خطأ |
| 20 | `JOURNAL_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL |  | إدخال المستخدم |  | القيد الناتج |
| 21 | `REVERSAL_OF_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | إدخال المستخدم |  | الحدث المعكوس |
| 22 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 23 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NEW' |  | NEW, VALIDATING, READY, POSTED, FAILED, REVERSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 24 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 25 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 26 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 27 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 28 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ACE_POSTING_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد الترحيل |
| English | Posting Rules |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
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
| 6 | `EVENT_CLASS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ACE_EVENT_CLASS |  | إدخال المستخدم |  | صنف الحدث |
| 7 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 8 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة (فارغ = كل الشركات) |
| 9 | `LEDGER_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع الدفتر |
| 10 | `CONDITION_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نطاق المنتج/المشروع/الفئة |
| 11 | `PRIORITY_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 100 |  |  | إدخال المستخدم |  | الأولوية |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ACE_POSTING_RULE_VERSION

| البند | القيمة |
|---|---|
| الاسم العربي | إصدارات قواعد الترحيل |
| English | Posting Rule Versions |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (POSTING_RULE_ID, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `POSTING_RULE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ACE_POSTING_RULE UK1 |  | إدخال المستخدم |  | القاعدة |
| 4 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الإصدار (لا يعدل بعد الاعتماد) |
| 5 | `SIMULATION_RESULT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نتيجة المحاكاة |
| 6 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, TESTED, APPROVED, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 9 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ACE_POSTING_RULE_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر قاعدة الترحيل |
| English | Posting Rule Lines |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `RULE_VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ACE_POSTING_RULE_VERSION |  | إدخال المستخدم |  | الإصدار |
| 4 | `SIDE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DEBIT, CREDIT | إدخال المستخدم |  | الجانب |
| 5 | `AMOUNT_SOURCE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | مصدر المبلغ من بيانات الحدث (NET، TAX، COST...) |
| 6 | `ACCOUNT_SOURCE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FIXED, MAPPING, PARTY_ACCOUNT, ITEM_CATEGORY, TAX_CODE, BANK_ACCOUNT, ASSET_CATEGORY, PAYROLL_ELEMENT, PROJECT | إدخال المستخدم |  | مصدر الحساب |
| 7 | `ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب الثابت |
| 8 | `MAPPING_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع جدول الاشتقاق |
| 9 | `DIMENSION_MAP` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | ربط الأبعاد |
| 10 | `DESCRIPTION_TEMPLATE` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | قالب البيان |
| 11 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ACE_ACCOUNT_MAPPING

| البند | القيمة |
|---|---|
| الاسم العربي | جداول اشتقاق الحسابات |
| English | Account Derivation Mappings |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, MAPPING_TYPE, KEY_VALUE, EFFECTIVE_FROM) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `MAPPING_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | النوع (ITEM_CATEGORY_INVENTORY، CUSTOMER_CLASS_AR...) |
| 5 | `KEY_VALUE` | نص | `VARCHAR2(200 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | المفتاح |
| 6 | `ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | الحساب الناتج |
| 7 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) | UK1 |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 8 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ACE_EXCEPTION

| البند | القيمة |
|---|---|
| الاسم العربي | قائمة استثناءات الترحيل |
| English | Posting Exception Queue |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ACE_ACCOUNTING_EVENT |  | إدخال المستخدم |  | الحدث |
| 5 | `EXCEPTION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | NO_RULE, AMBIGUOUS_RULE, CLOSED_PERIOD, INVALID_ACCOUNT, UNBALANCED, MISSING_RATE, MISSING_DIMENSION, TECHNICAL | إدخال المستخدم |  | النوع |
| 6 | `MESSAGE` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرسالة |
| 7 | `ASSIGNED_TO` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المكلف |
| 8 | `RESOLVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الحل |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, RETRYING, RESOLVED, IGNORED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ACE_RECONCILIATION

| البند | القيمة |
|---|---|
| الاسم العربي | مطابقة المصدر مع الأستاذ |
| English | Source-to-GL Reconciliation |
| الحزمة المالكة | 07 — `NOONA_GL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→GL_PERIOD |  | إدخال المستخدم |  | الفترة |
| 5 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوحدة |
| 6 | `SOURCE_COUNT` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | عدد أحداث المصدر |
| 7 | `POSTED_COUNT` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | المرحل |
| 8 | `SOURCE_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | قيمة المصدر |
| 9 | `GL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | قيمة الأستاذ |
| 10 | `DIFFERENCE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الفرق |
| 11 | `DETAILS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | غير المرحل والمكرر واليتيم |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'RUNNING' |  | RUNNING, MATCHED, DIFFERENCES, APPROVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

