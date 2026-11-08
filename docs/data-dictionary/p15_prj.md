# قاموس البيانات — الحزمة 15: المشروعات والمقاولات والإنشاءات

**Projects, Contracting & Construction** · الحزمة البرمجية المالكة `NOONA_PROJECTS_PKG` · ملف DDL `db/ddl/p15_prj.sql` · [ERD](../erd/p15_prj.md)

المشروع وهيكل تقسيم العمل WBS والموازنات وخط الأساس، وعقود العملاء والمقاولين الفرعيين، وجداول الكميات BOQ، وأوامر التغيير، والمستخلصات بالمحتجز واسترداد الدفعة المقدمة، والتكاليف الفعلية، ونسب الإنجاز وخطابات الضمان.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`PRJ_PROJECT`](#prj_project) | المشروعات | Projects | C | INTERNAL |
| [`PRJ_WBS`](#prj_wbs) | هيكل تقسيم العمل | Work Breakdown Structure | C | INTERNAL |
| [`PRJ_BUDGET`](#prj_budget) | موازنات المشروعات | Project Budgets | C | INTERNAL |
| [`PRJ_BUDGET_LINE`](#prj_budget_line) | أسطر موازنة المشروع | Project Budget Lines | C | INTERNAL |
| [`PRJ_CONTRACT`](#prj_contract) | عقود المشروعات | Project Contracts | C | INTERNAL |
| [`PRJ_BOQ_ITEM`](#prj_boq_item) | جداول الكميات | Bill of Quantities | C | INTERNAL |
| [`PRJ_VARIATION_ORDER`](#prj_variation_order) | أوامر التغيير | Variation Orders | C | INTERNAL |
| [`PRJ_VARIATION_LINE`](#prj_variation_line) | أسطر أوامر التغيير | Variation Order Lines | C | INTERNAL |
| [`PRJ_PROGRESS_CLAIM`](#prj_progress_claim) | المستخلصات | Progress Claims / Payment Certificates | C | INTERNAL |
| [`PRJ_PROGRESS_CLAIM_LINE`](#prj_progress_claim_line) | أسطر المستخلص | Progress Claim Lines | C | INTERNAL |
| [`PRJ_MILESTONE`](#prj_milestone) | المعالم | Milestones | C | INTERNAL |
| [`PRJ_COST_LINE`](#prj_cost_line) | التكاليف الفعلية للمشروع | Project Actual Costs | C | INTERNAL |
| [`PRJ_PROGRESS_UPDATE`](#prj_progress_update) | تحديثات نسب الإنجاز | Progress Updates | C | INTERNAL |
| [`PRJ_TIMESHEET`](#prj_timesheet) | سجلات ساعات العمل | Timesheets | C | INTERNAL |
| [`PRJ_GUARANTEE`](#prj_guarantee) | خطابات الضمان | Letters of Guarantee | C | INTERNAL |
| [`PRJ_REVENUE_RUN`](#prj_revenue_run) | الاعتراف بإيراد العقود حسب نسبة الإنجاز | Contract Revenue Recognition (WIP) Runs | C | INTERNAL |
| [`PRJ_EQUIPMENT`](#prj_equipment) | معدات المشروعات | Project Equipment | C | INTERNAL |
| [`PRJ_EQUIPMENT_USAGE`](#prj_equipment_usage) | تشغيل المعدات على المشروعات | Equipment Usage | C | INTERNAL |

## PRJ_PROJECT

| البند | القيمة |
|---|---|
| الاسم العربي | المشروعات |
| English | Projects |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
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
| 9 | `PROJECT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CONSTRUCTION, CLIENT_CONTRACT, INTERNAL, REAL_ESTATE_DEVELOPMENT, MAINTENANCE, CAPEX, PROGRAM, PORTFOLIO | إدخال المستخدم |  | النوع |
| 10 | `PARENT_PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | البرنامج/المحفظة الأم |
| 11 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | موقع المشروع |
| 12 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | العميل |
| 13 | `MANAGER_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | مدير المشروع |
| 14 | `MANAGER_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | منصب مدير المشروع |
| 15 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 16 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المشروع |
| 17 | `PLANNED_START` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | البداية المخططة |
| 18 | `PLANNED_END` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية المخططة |
| 19 | `ACTUAL_START` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | البداية الفعلية |
| 20 | `ACTUAL_END` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية الفعلية |
| 21 | `CONTRACT_VALUE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | قيمة العقد الرئيسي |
| 22 | `BUDGET_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الموازنة المعتمدة |
| 23 | `PERCENT_COMPLETE` | نسبة | `NUMBER(9,6)` |  |  |  |  | محسوب |  | نسبة الإنجاز |
| 24 | `REVENUE_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | MILESTONE, PERCENT_COMPLETE, COST_TO_COST, BILLING, COMPLETED_CONTRACT | إدخال المستخدم |  | طريقة الاعتراف بالإيراد |
| 25 | `ESTIMATED_TOTAL_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة المتوقعة عند الإنجاز (آخر تقدير) |
| 26 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, APPROVED, ACTIVE, ON_HOLD, COMPLETED, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 27 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 28 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 29 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 30 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 31 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 32 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 33 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_WBS

| البند | القيمة |
|---|---|
| الاسم العربي | هيكل تقسيم العمل |
| English | Work Breakdown Structure |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PROJECT_ID, CODE) |
| قيود أعمال | PARENT_WBS_ID IS NULL OR PARENT_WBS_ID <> ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT UK2 |  | إدخال المستخدم |  | المشروع |
| 8 | `PARENT_WBS_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_WBS |  | إدخال المستخدم |  | العنصر الأب |
| 9 | `WBS_LEVEL` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | المستوى |
| 10 | `WEIGHT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | الوزن في الإنجاز |
| 11 | `PLANNED_START` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 12 | `PLANNED_END` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 13 | `IS_BILLABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | قابل للفوترة |
| 14 | `IS_CHARGEABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يقبل تحميل التكاليف |
| 15 | `PERCENT_COMPLETE` | نسبة | `NUMBER(9,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | نسبة الإنجاز الحالية |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, ACTIVE, COMPLETED, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_BUDGET

| البند | القيمة |
|---|---|
| الاسم العربي | موازنات المشروعات |
| English | Project Budgets |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PROJECT_ID, BUDGET_TYPE, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT UK2 |  | إدخال المستخدم |  | المشروع |
| 5 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الإصدار |
| 6 | `BUDGET_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'COST' | UK2 | COST, REVENUE, CASH_FLOW | إدخال المستخدم |  | النوع |
| 7 | `IS_BASELINE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | خط الأساس المعتمد |
| 8 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي |
| 9 | `CHANGE_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب المراجعة |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, BASELINE, SUPERSEDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_BUDGET_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر موازنة المشروع |
| English | Project Budget Lines |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BUDGET_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_BUDGET |  | إدخال المستخدم |  | الموازنة |
| 5 | `WBS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 6 | `COST_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MATERIAL, LABOR, EQUIPMENT, SUBCONTRACT, OVERHEAD, OTHER, REVENUE | إدخال المستخدم |  | نوع التكلفة |
| 7 | `PERIOD_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_PERIOD |  | إدخال المستخدم |  | الفترة |
| 8 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 9 | `QUANTITY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الكمية |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_CONTRACT

| البند | القيمة |
|---|---|
| الاسم العربي | عقود المشروعات |
| English | Project Contracts |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, COMPANY_ID, CONTRACT_NO) |

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
| 9 | `CONTRACT_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم العقد |
| 10 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 11 | `CONTRACT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MAIN_CONTRACT, SUBCONTRACT, CONSULTANCY, SUPPLY, LABOR_ONLY, DESIGN_BUILD | إدخال المستخدم |  | النوع |
| 12 | `PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف (العميل أو المقاول) |
| 13 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | حساب العميل (عقد رئيسي) |
| 14 | `SUPPLIER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AP_SUPPLIER_ACCOUNT |  | إدخال المستخدم |  | حساب المقاول (عقد باطن) |
| 15 | `PARENT_CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_CONTRACT |  | إدخال المستخدم |  | العقد الرئيسي لعقد الباطن |
| 16 | `PRICING_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REMEASURED' |  | LUMP_SUM, REMEASURED, COST_PLUS, UNIT_RATE, TIME_MATERIAL | إدخال المستخدم |  | التسعير |
| 17 | `ORIGINAL_VALUE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | القيمة الأصلية |
| 18 | `CURRENT_VALUE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | محسوب |  | القيمة بعد أوامر التغيير |
| 19 | `RETENTION_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة المحتجز |
| 20 | `RETENTION_CAP_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | سقف المحتجز |
| 21 | `ADVANCE_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة الدفعة المقدمة |
| 22 | `ADVANCE_RECOVERY_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة استرداد المقدم من كل مستخلص |
| 23 | `START_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 24 | `END_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 25 | `DEFECTS_LIABILITY_MONTHS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | فترة الضمان |
| 26 | `SIGNED_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | العقد الموقع |
| 27 | `DELAY_PENALTY_PER_DAY` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | غرامة التأخير اليومية |
| 28 | `PENALTY_CAP_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | سقف الغرامات % من قيمة العقد |
| 29 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, SIGNED, ACTIVE, SUSPENDED, COMPLETED, CLOSED, TERMINATED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 30 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 31 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 32 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 33 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 34 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 35 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_BOQ_ITEM

| البند | القيمة |
|---|---|
| الاسم العربي | جداول الكميات |
| English | Bill of Quantities |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (CONTRACT_ID, ITEM_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CONTRACT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_CONTRACT UK2 |  | إدخال المستخدم |  | العقد |
| 5 | `WBS_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 6 | `PARENT_BOQ_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_BOQ_ITEM |  | إدخال المستخدم |  | البند الأب (قسم) |
| 7 | `ITEM_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم البند |
| 8 | `DESCRIPTION_AR` | نص | `VARCHAR2(2000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 9 | `DESCRIPTION_EN` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | Description |
| 10 | `UOM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_UOM |  | إدخال المستخدم |  | الوحدة |
| 11 | `CONTRACT_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الكمية التعاقدية |
| 12 | `UNIT_RATE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | سعر الوحدة |
| 13 | `AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | محسوب |  | القيمة |
| 14 | `VARIATION_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | النظام/الحزمة |  | كميات أوامر التغيير |
| 15 | `EXECUTED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | النظام/الحزمة |  | المنفذ حتى تاريخه |
| 16 | `IS_PROVISIONAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مبلغ احتياطي |
| 17 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_VARIATION_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | أوامر التغيير |
| English | Variation Orders |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
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
| 6 | `CONTRACT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_CONTRACT |  | إدخال المستخدم |  | العقد |
| 7 | `VARIATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ADDITION, OMISSION, SUBSTITUTION, TIME_EXTENSION, PRICE_ADJUSTMENT | إدخال المستخدم |  | النوع |
| 8 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 9 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الأثر المالي |
| 10 | `TIME_IMPACT_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الأثر الزمني |
| 11 | `CLIENT_APPROVAL_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع موافقة العميل |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, UNDER_REVIEW, APPROVED, REJECTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_VARIATION_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر أوامر التغيير |
| English | Variation Order Lines |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VARIATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_VARIATION_ORDER |  | إدخال المستخدم |  | الأمر |
| 5 | `BOQ_ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_BOQ_ITEM |  | إدخال المستخدم |  | البند القائم |
| 6 | `NEW_ITEM_CODE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | بند جديد |
| 7 | `DESCRIPTION` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 8 | `QTY_CHANGE` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | تغير الكمية |
| 9 | `UNIT_RATE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر |
| 10 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | القيمة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_PROGRESS_CLAIM

| البند | القيمة |
|---|---|
| الاسم العربي | المستخلصات |
| English | Progress Claims / Payment Certificates |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO)<br>UK3: (PUBLIC_ID)<br>UK4: (CONTRACT_ID, CLAIM_NO) |

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
| 11 | `CONTRACT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_CONTRACT UK4 |  | إدخال المستخدم |  | العقد |
| 12 | `CLAIM_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK4 |  | إدخال المستخدم |  | رقم المستخلص التسلسلي |
| 13 | `CLAIM_DIRECTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | RECEIVABLE, PAYABLE | إدخال المستخدم |  | لنا من العميل أو علينا للمقاول |
| 14 | `CLAIM_KIND` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PROGRESS' |  | PROGRESS, ADVANCE, RETENTION_RELEASE | إدخال المستخدم |  | مستخلص أعمال، دفعة مقدمة، أو إفراج عن المحتجز |
| 15 | `PERIOD_FROM` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | من |
| 16 | `PERIOD_TO` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | إلى |
| 17 | `GROSS_TO_DATE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي التراكمي |
| 18 | `PREVIOUS_CERTIFIED` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المعتمد سابقاً |
| 19 | `CURRENT_GROSS` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | قيمة الفترة |
| 20 | `RETENTION_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحتجز |
| 21 | `ADVANCE_RECOVERY` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | استرداد الدفعة المقدمة |
| 22 | `OTHER_DEDUCTIONS` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | خصومات أخرى |
| 23 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة |
| 24 | `NET_PAYABLE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الصافي |
| 25 | `CERTIFIED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد/الاستشاري |
| 26 | `CERTIFICATE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | شهادة الإنجاز |
| 27 | `SALES_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SAL_INVOICE |  | إدخال المستخدم |  | الفاتورة الناتجة (عميل) |
| 28 | `PENALTY_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | أيام التأخير المحتسبة |
| 29 | `PENALTY_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | غرامة التأخير |
| 30 | `MOS_TO_DATE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | قيمة المواد المشونة بالموقع حتى تاريخه |
| 31 | `MOS_PREVIOUS` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المواد المشونة في المستخلص السابق |
| 32 | `IS_FINAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | المستخلص الختامي |
| 33 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, CERTIFIED, APPROVED, INVOICED, PAID, REJECTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 34 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 35 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 36 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 37 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 38 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 39 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 40 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 41 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 42 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_PROGRESS_CLAIM_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر المستخلص |
| English | Progress Claim Lines |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CLAIM_ID, BOQ_ITEM_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CLAIM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROGRESS_CLAIM UK1 |  | إدخال المستخدم |  | المستخلص |
| 5 | `BOQ_ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_BOQ_ITEM UK1 |  | إدخال المستخدم |  | البند |
| 6 | `QTY_TO_DATE` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية التراكمية |
| 7 | `PREVIOUS_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | السابقة |
| 8 | `CURRENT_QTY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الحالية |
| 9 | `UNIT_RATE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر |
| 10 | `AMOUNT_TO_DATE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | القيمة التراكمية |
| 11 | `CURRENT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | قيمة الفترة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_MILESTONE

| البند | القيمة |
|---|---|
| الاسم العربي | المعالم |
| English | Milestones |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 7 | `CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_CONTRACT |  | إدخال المستخدم |  | العقد |
| 8 | `WBS_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 9 | `PLANNED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | المخطط |
| 10 | `ACHIEVED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | المحقق |
| 11 | `BILLING_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة الفوترة |
| 12 | `BILLING_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ |
| 13 | `EVIDENCE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الإثبات |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, ACHIEVED, CERTIFIED, INVOICED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_COST_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | التكاليف الفعلية للمشروع |
| English | Project Actual Costs |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
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
| 6 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 7 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 8 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 9 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 10 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 11 | `WBS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 12 | `COST_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MATERIAL, LABOR, EQUIPMENT, SUBCONTRACT, OVERHEAD, OTHER | إدخال المستخدم |  | نوع التكلفة |
| 13 | `COST_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 14 | `QUANTITY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الكمية |
| 15 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 16 | `AMOUNT_FUNC` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الوظيفي |
| 17 | `GL_JOURNAL_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL_LINE |  | إدخال المستخدم |  | سطر القيد |
| 18 | `IS_COMMITMENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | التزام (أمر شراء) لا تكلفة فعلية |
| 19 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | البيان |
| 20 | `REFERENCE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع |
| 21 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'POSTED' |  | POSTED, REVERSED | إدخال المستخدم |  | الحالة |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_PROGRESS_UPDATE

| البند | القيمة |
|---|---|
| الاسم العربي | تحديثات نسب الإنجاز |
| English | Progress Updates |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 5 | `WBS_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 6 | `AS_OF_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | حتى تاريخ |
| 7 | `PERCENT_COMPLETE` | نسبة | `NUMBER(9,6)` | ✔ |  |  |  | إدخال المستخدم |  | النسبة |
| 8 | `METHOD_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PHYSICAL, COST_TO_COST, MILESTONE, MANUAL | إدخال المستخدم |  | الطريقة |
| 9 | `REMARKS` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 10 | `EVIDENCE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الإثبات |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## PRJ_TIMESHEET

| البند | القيمة |
|---|---|
| الاسم العربي | سجلات ساعات العمل |
| English | Timesheets |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | HOURS > 0 AND HOURS <= 24 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 5 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 6 | `WBS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 7 | `WORK_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 8 | `HOURS` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الساعات |
| 9 | `COST_RATE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | معدل التكلفة |
| 10 | `IS_BILLABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | قابل للفوترة |
| 11 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, REJECTED, POSTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_GUARANTEE

| البند | القيمة |
|---|---|
| الاسم العربي | خطابات الضمان |
| English | Letters of Guarantee |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, GUARANTEE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 5 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 6 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 7 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 8 | `GUARANTEE_NO` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم الخطاب |
| 9 | `GUARANTEE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BID, PERFORMANCE, ADVANCE_PAYMENT, RETENTION, MAINTENANCE, CUSTOMS | إدخال المستخدم |  | النوع |
| 10 | `DIRECTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ISSUED_BY_US, RECEIVED_FROM_PARTY | إدخال المستخدم |  | صادر منا أو وارد لنا |
| 11 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 12 | `CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_CONTRACT |  | إدخال المستخدم |  | العقد |
| 13 | `BANK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→REF_BANK |  | إدخال المستخدم |  | البنك |
| 14 | `BENEFICIARY_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المستفيد |
| 15 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 16 | `ISSUE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | الإصدار |
| 17 | `EXPIRY_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | الانتهاء (تنبيه قبله) |
| 18 | `MARGIN_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الغطاء النقدي |
| 19 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | صورة الخطاب |
| 20 | `MARGIN_JOURNAL_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL |  | إدخال المستخدم |  | قيد تجنيب الغطاء |
| 21 | `RELEASE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإفراج |
| 22 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 23 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REQUESTED' |  | REQUESTED, ISSUED, ACTIVE, EXTENDED, REDUCED, RELEASED, LIQUIDATED, EXPIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 24 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 25 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 26 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 27 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 28 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_REVENUE_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | الاعتراف بإيراد العقود حسب نسبة الإنجاز |
| English | Contract Revenue Recognition (WIP) Runs |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PROJECT_ID, PERIOD_END) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT UK1 |  | إدخال المستخدم |  | المشروع |
| 5 | `PERIOD_END` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | نهاية الفترة |
| 6 | `REVENUE_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | طريقة نسبة الإنجاز (التكلفة أو الإنجاز الفعلي) |
| 7 | `CONTRACT_VALUE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | قيمة العقد الحالية |
| 8 | `ESTIMATED_TOTAL_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | التكلفة المتوقعة عند الإنجاز |
| 9 | `COST_TO_DATE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | التكلفة الفعلية حتى تاريخه |
| 10 | `POC_PCT` | نسبة | `NUMBER(9,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | نسبة الإنجاز |
| 11 | `REVENUE_TO_DATE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإيراد المستحق حتى تاريخه |
| 12 | `BILLED_TO_DATE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإيراد المفوتر بالمستخلصات |
| 13 | `CONTRACT_ASSET` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | أصول العقود (إيراد غير مفوتر) |
| 14 | `CONTRACT_LIABILITY` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | التزامات العقود (فوترة تتجاوز الإنجاز) |
| 15 | `EXPECTED_LOSS` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الخسارة المتوقعة للعقد |
| 16 | `LOSS_PROVISION` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | مخصص الخسارة المتبقية |
| 17 | `GL_JOURNAL_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_JOURNAL |  | إدخال المستخدم |  | قيد التسوية |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'POSTED' |  | POSTED, REVERSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_EQUIPMENT

| البند | القيمة |
|---|---|
| الاسم العربي | معدات المشروعات |
| English | Project Equipment |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
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
| 7 | `EQUIPMENT_TYPE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | النوع (حفار، رافعة، خلاطة...) |
| 8 | `OWNERSHIP` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OWNED' |  | OWNED, RENTED | إدخال المستخدم |  | مملوكة أو مستأجرة |
| 9 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل الثابت المرتبط |
| 10 | `HOURLY_RATE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | تكلفة الساعة المحملة |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PRJ_EQUIPMENT_USAGE

| البند | القيمة |
|---|---|
| الاسم العربي | تشغيل المعدات على المشروعات |
| English | Equipment Usage |
| الحزمة المالكة | 15 — `NOONA_PROJECTS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `EQUIPMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_EQUIPMENT |  | إدخال المستخدم |  | المعدة |
| 5 | `PROJECT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 6 | `WBS_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PRJ_WBS |  | إدخال المستخدم |  | بند العمل |
| 7 | `USAGE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 8 | `HOURS` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الساعات |
| 9 | `RATE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | تكلفة الساعة |
| 10 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | التكلفة |
| 11 | `COST_LINE_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_COST_LINE |  | إدخال المستخدم |  | حركة التكلفة |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, POSTED, REVERSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

