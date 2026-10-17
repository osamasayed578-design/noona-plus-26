# قاموس البيانات — الحزمة 03: سير العمل والطلبات والاعتمادات والتفويض

**Workflow, Requests, Approvals & Delegation** · الحزمة البرمجية المالكة `NOONA_WORKFLOW_PKG` · ملف DDL `db/ddl/p03_wf.sql` · [ERD](../erd/p03_wf.md)

محرك Workflow مركزي يفصل Definition/Version/Instance/Task/Action، وطبقة إدارة الطلبات والاستثناءات ومصفوفة السلطة وقوائم العمل وSLA، ومحرك التفويض المركزي (NOONA_DELEGATION_PKG) بنطاقه وحدوده وسجل التصرفات المنفذة بالنيابة.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`WF_BUSINESS_CALENDAR`](#wf_business_calendar) | تقويمات العمل | Business Calendars | TO | INTERNAL |
| [`WF_CALENDAR_HOLIDAY`](#wf_calendar_holiday) | العطلات الرسمية | Calendar Holidays | TO | INTERNAL |
| [`WF_SLA_POLICY`](#wf_sla_policy) | سياسات SLA | SLA Policies | TO | INTERNAL |
| [`WF_RULE`](#wf_rule) | قواعد الشروط | Workflow Rules | TO | INTERNAL |
| [`WF_DEFINITION`](#wf_definition) | تعريفات المسارات | Workflow Definitions | TO | INTERNAL |
| [`WF_DEFINITION_VERSION`](#wf_definition_version) | إصدارات المسارات | Workflow Definition Versions | TO | INTERNAL |
| [`WF_STEP_DEF`](#wf_step_def) | خطوات المسار | Workflow Step Definitions | TO | INTERNAL |
| [`WF_TRANSITION_DEF`](#wf_transition_def) | انتقالات المسار | Workflow Transitions | TO | INTERNAL |
| [`WF_QUEUE`](#wf_queue) | قوائم العمل المشتركة | Work Queues | T | INTERNAL |
| [`WF_QUEUE_MEMBER`](#wf_queue_member) | أعضاء قوائم العمل | Queue Members | T | INTERNAL |
| [`WF_AUTHORITY_MATRIX`](#wf_authority_matrix) | مصفوفة السلطة | Authority Matrix | T | INTERNAL |
| [`WF_INSTANCE`](#wf_instance) | مسارات قيد التشغيل | Workflow Instances | T | INTERNAL |
| [`WF_TASK`](#wf_task) | المهام | Workflow Tasks | T | INTERNAL |
| [`WF_TASK_ACTION`](#wf_task_action) | قرارات المهام | Task Actions / Decisions | T | INTERNAL |
| [`WF_ESCALATION`](#wf_escalation) | التصعيدات | Escalations | T | INTERNAL |
| [`WF_REQUEST_TYPE`](#wf_request_type) | أنواع الطلبات | Request Types | TO | INTERNAL |
| [`WF_REQUEST`](#wf_request) | الطلبات | Requests | T | INTERNAL |
| [`WF_APPROVAL_CONDITION`](#wf_approval_condition) | شروط الموافقة | Conditional Approval Obligations | T | INTERNAL |
| [`WF_EXCEPTION`](#wf_exception) | سجل الاستثناءات | Policy Exceptions | T | INTERNAL |
| [`WF_ATTESTATION`](#wf_attestation) | الإقرارات | Attestations | T | INTERNAL |
| [`DLG_POLICY`](#dlg_policy) | سياسات التفويض | Delegation Policies | TO | INTERNAL |
| [`DLG_TEMPLATE`](#dlg_template) | قوالب التفويض | Delegation Templates | TO | INTERNAL |
| [`DLG_DELEGATION`](#dlg_delegation) | التفويضات | Delegations | T | INTERNAL |
| [`DLG_SCOPE`](#dlg_scope) | نطاق التفويض | Delegation Scope | T | INTERNAL |
| [`DLG_LIMIT`](#dlg_limit) | حدود التفويض المالية | Delegation Limits | T | INTERNAL |
| [`DLG_EXERCISE_EVENT`](#dlg_exercise_event) | التصرفات المنفذة بالتفويض | Delegation Exercise Events | T | INTERNAL |
| [`DLG_REVIEW`](#dlg_review) | المراجعة اللاحقة للتفويض | Delegation Reviews | T | INTERNAL |

## WF_BUSINESS_CALENDAR

| البند | القيمة |
|---|---|
| الاسم العربي | تقويمات العمل |
| English | Business Calendars |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
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
| 6 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 7 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 8 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 9 | `TIMEZONE_CODE` | نص | `VARCHAR2(64 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المنطقة الزمنية |
| 10 | `WEEKEND_DAYS` | نص | `VARCHAR2(20 CHAR)` | ✔ | 'FRI,SAT' |  |  | إدخال المستخدم |  | أيام العطلة الأسبوعية |
| 11 | `WORK_HOURS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | ساعات العمل لكل يوم |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_CALENDAR_HOLIDAY

| البند | القيمة |
|---|---|
| الاسم العربي | العطلات الرسمية |
| English | Calendar Holidays |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CALENDAR_ID, HOLIDAY_DATE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CALENDAR_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_BUSINESS_CALENDAR UK1 |  | إدخال المستخدم |  | التقويم |
| 4 | `HOLIDAY_DATE` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | التاريخ |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | Name |
| 7 | `IS_HALF_DAY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | نصف يوم |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_SLA_POLICY

| البند | القيمة |
|---|---|
| الاسم العربي | سياسات SLA |
| English | SLA Policies |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
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
| 6 | `CALENDAR_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_BUSINESS_CALENDAR |  | إدخال المستخدم |  | التقويم |
| 7 | `PRIORITY_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | LOW, NORMAL, HIGH, URGENT, VERY_URGENT | إدخال المستخدم |  | الأولوية |
| 8 | `RESPONSE_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مهلة الاستجابة بدقائق العمل |
| 9 | `COMPLETION_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مهلة الإنجاز |
| 10 | `WARN_BEFORE_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | التنبيه قبل الموعد |
| 11 | `ESCALATION_RULES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | مستويات التصعيد |
| 12 | `ALLOW_AUTO_APPROVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بالاعتماد التلقائي (ممنوع افتراضياً للمالية والقانونية) |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد الشروط |
| English | Workflow Rules |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
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
| 6 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 7 | `RULE_EXPRESSION` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | تعبير Rule Builder (حقول وعوامل مسموحة فقط؛ لا SQL حر) |
| 8 | `PLSQL_FUNCTION` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | دالة معتمدة للقواعد المعقدة |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, TESTED, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_DEFINITION

| البند | القيمة |
|---|---|
| الاسم العربي | تعريفات المسارات |
| English | Workflow Definitions |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
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
| 6 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 7 | `OBJECT_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع الكائن المعتمد |
| 8 | `REQUEST_TYPE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_REQUEST_TYPE |  | إدخال المستخدم |  | نوع الطلب |
| 9 | `SCOPE_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'TENANT' |  | PLATFORM, COUNTRY, TENANT, BUSINESS_GROUP, COMPANY, BRANCH, ORG_UNIT, PROJECT, PROPERTY | إدخال المستخدم |  | مستوى التعريف (الأكثر تحديداً يتقدم) |
| 10 | `SCOPE_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف النطاق |
| 11 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة عند COUNTRY |
| 12 | `WORKFLOW_KIND` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'APPROVAL' |  | APPROVAL, REVIEW, ROUTING, TASK, NOTIFICATION, DOCUMENT, CASE, STATE_MACHINE, CHECKLIST | إدخال المستخدم |  | النوع |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_DEFINITION_VERSION

| البند | القيمة |
|---|---|
| الاسم العربي | إصدارات المسارات |
| English | Workflow Definition Versions |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (DEFINITION_ID, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `DEFINITION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_DEFINITION UK1 |  | إدخال المستخدم |  | التعريف |
| 4 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الإصدار (لا يعدل بعد النشر) |
| 5 | `DEFINITION_JSON` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | التمثيل الكامل للمسار |
| 6 | `PUBLISHED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | الناشر |
| 7 | `PUBLISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت النشر |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, PUBLISHED, ACTIVE, RETIRED, ARCHIVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 10 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_STEP_DEF

| البند | القيمة |
|---|---|
| الاسم العربي | خطوات المسار |
| English | Workflow Step Definitions |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (VERSION_ID, STEP_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_DEFINITION_VERSION UK1 |  | إدخال المستخدم |  | إصدار المسار |
| 6 | `STEP_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز الخطوة |
| 7 | `STEP_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | START, END, USER_TASK, APPROVAL, REVIEW, SYSTEM, NOTIFICATION, TIMER, DECISION, PARALLEL_SPLIT, PARALLEL_JOIN, SUB_WORKFLOW, INTEGRATION, DOC_GENERATION, VALIDATION, POSTING, MANUAL_CONFIRMATION, COMPENSATION, SIGNATURE | إدخال المستخدم |  | نوع الخطوة |
| 8 | `ASSIGNEE_RULE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | USER, REQUESTER, MANAGER, HEAD_POSITION, POSITION, ROLE, ORG_UNIT, COMMITTEE, APPROVAL_GROUP, PROJECT_MANAGER, PROPERTY_MANAGER, COST_CENTER_OWNER, BUDGET_OWNER, DATA_OWNER, SECURITY_ADMIN, QUEUE, AUTHORITY_MATRIX | إدخال المستخدم |  | قاعدة الإسناد |
| 9 | `ASSIGNEE_REF_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف الجهة المسندة |
| 10 | `QUEUE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_QUEUE |  | إدخال المستخدم |  | قائمة العمل المشتركة |
| 11 | `JOIN_POLICY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | ALL, COUNT, PERCENT, ANY, MAJORITY, MANDATORY_PARTY | إدخال المستخدم |  | سياسة الدمج للتوازي |
| 12 | `JOIN_VALUE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | العدد/النسبة |
| 13 | `SLA_POLICY_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_SLA_POLICY |  | إدخال المستخدم |  | SLA |
| 14 | `SUB_DEFINITION_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_DEFINITION |  | إدخال المستخدم |  | المسار الفرعي |
| 15 | `ACTION_HANDLER` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | الإجراء الآلي (حزمة معتمدة) |
| 16 | `EDITABLE_FIELDS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الحقول القابلة للتعديل عند الإرجاع |
| 17 | `ALLOW_SELF_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح باعتماد الطالب لنفسه (ممنوع افتراضياً) |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_TRANSITION_DEF

| البند | القيمة |
|---|---|
| الاسم العربي | انتقالات المسار |
| English | Workflow Transitions |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_DEFINITION_VERSION |  | إدخال المستخدم |  | الإصدار |
| 4 | `FROM_STEP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_STEP_DEF |  | إدخال المستخدم |  | من خطوة |
| 5 | `TO_STEP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_STEP_DEF |  | إدخال المستخدم |  | إلى خطوة |
| 6 | `OUTCOME_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نتيجة القرار المسببة للانتقال |
| 7 | `RULE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_RULE |  | إدخال المستخدم |  | شرط الانتقال |
| 8 | `IS_DEFAULT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | الانتقال الافتراضي |
| 9 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_QUEUE

| البند | القيمة |
|---|---|
| الاسم العربي | قوائم العمل المشتركة |
| English | Work Queues |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
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
| 6 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 7 | `CLAIM_POLICY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'FIFO' |  | FIFO, ROLE, LEAST_LOAD, SKILL, BRANCH, SUPERVISOR | إدخال المستخدم |  | سياسة الاستلام |
| 8 | `SUPERVISOR_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المشرف |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_QUEUE_MEMBER

| البند | القيمة |
|---|---|
| الاسم العربي | أعضاء قوائم العمل |
| English | Queue Members |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `QUEUE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_QUEUE |  | إدخال المستخدم |  | القائمة |
| 4 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 5 | `ROLE_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_ROLE |  | إدخال المستخدم |  | الدور |
| 6 | `POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب |
| 7 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 8 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_AUTHORITY_MATRIX

| البند | القيمة |
|---|---|
| الاسم العربي | مصفوفة السلطة |
| English | Authority Matrix |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | حدود السلطة حسب المنصب والمعاملة والمبلغ والعملة؛ يرفع للمستوى الأعلى إن لم يكف الحد |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>POSITION_ID IS NOT NULL OR JOB_ID IS NOT NULL OR GRADE_ID IS NOT NULL |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `TRANSACTION_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع المعاملة |
| 6 | `ACTION_CODE` | نص | `VARCHAR2(40 CHAR)` | ✔ | 'APPROVE' |  |  | إدخال المستخدم |  | الإجراء |
| 7 | `POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب |
| 8 | `JOB_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_JOB |  | إدخال المستخدم |  | الوظيفة |
| 9 | `GRADE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_GRADE |  | إدخال المستخدم |  | الدرجة |
| 10 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 11 | `MAX_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأعلى للمبلغ |
| 12 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 15 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_INSTANCE

| البند | القيمة |
|---|---|
| الاسم العربي | مسارات قيد التشغيل |
| English | Workflow Instances |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | حالة المعاملة مستقلة عن حالة Workflow |
| مفاتيح فريدة | UK2: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_DEFINITION_VERSION |  | إدخال المستخدم |  | الإصدار الذي بدأ عليه (يكمل عليه) |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 5 | `OBJECT_TYPE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع الكائن |
| 6 | `OBJECT_ID` | معرف | `NUMBER(19)` | ✔ |  |  |  | إدخال المستخدم |  | معرف الكائن |
| 7 | `REQUEST_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_REQUEST |  | إدخال المستخدم |  | الطلب |
| 8 | `PARENT_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | إدخال المستخدم |  | المسار الأب (Sub-Workflow) |
| 9 | `BUSINESS_EVENT_ID` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الحدث المسبب |
| 10 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | منع بدء المسار مرتين |
| 11 | `INITIATOR_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المنشئ |
| 12 | `CONTEXT_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | لقطة السياق (المبلغ، العملة، الطرف، القاعدة...) |
| 13 | `OUTCOME_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | النتيجة النهائية |
| 14 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | البداية |
| 15 | `COMPLETED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الاكتمال |
| 16 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CREATED' |  | CREATED, RUNNING, WAITING, COMPLETED, SUSPENDED, CANCELLED, FAILED, TERMINATED, EXPIRED, COMPENSATING | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_TASK

| البند | القيمة |
|---|---|
| الاسم العربي | المهام |
| English | Workflow Tasks |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `INSTANCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_INSTANCE |  | إدخال المستخدم |  | المسار |
| 4 | `STEP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_STEP_DEF |  | إدخال المستخدم |  | الخطوة |
| 5 | `TASK_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | نوع المهمة |
| 6 | `ASSIGNEE_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستلم الحالي |
| 7 | `ORIGINAL_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | صاحب المسؤولية الأصلي |
| 8 | `ASSIGNEE_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب وقت الإسناد |
| 9 | `QUEUE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_QUEUE |  | إدخال المستخدم |  | قائمة العمل |
| 10 | `DELEGATION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | سند التفويض المستخدم |
| 11 | `PRIORITY_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | LOW, NORMAL, HIGH, URGENT, VERY_URGENT | إدخال المستخدم |  | الأولوية |
| 12 | `DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الموعد |
| 13 | `WARN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التنبيه |
| 14 | `CLAIMED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاستلام |
| 15 | `COMPLETED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإنجاز |
| 16 | `OUTCOME_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | القرار |
| 17 | `RESOLUTION_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | لقطة قرار حل المستلم (لماذا وجهت المهمة له) |
| 18 | `SLA_PAUSED_MINUTES` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | دقائق إيقاف SLA الموثقة |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, CLAIMED, IN_PROGRESS, WAITING_INFO, COMPLETED, RETURNED, CANCELLED, EXPIRED, ESCALATED, REASSIGNED, FAILED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_TASK_ACTION

| البند | القيمة |
|---|---|
| الاسم العربي | قرارات المهام |
| English | Task Actions / Decisions |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الغرض | لا تمحى الموافقات عند الإرجاع؛ سجل تراكمي |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `TASK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_TASK |  | إدخال المستخدم |  | المهمة |
| 4 | `ACTION_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CLAIM, APPROVE, REJECT, RETURN, REQUEST_INFO, PROVIDE_INFO, FORWARD, REASSIGN, ABSTAIN, DELEGATE, ESCALATE, CANCEL, APPROVE_WITH_CONDITIONS, ACKNOWLEDGE, COMMENT, SIGN, SYSTEM | إدخال المستخدم |  | الإجراء |
| 5 | `ACTOR_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المنفذ الفعلي |
| 6 | `ON_BEHALF_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | صاحب السلطة الأصلي عند التفويض |
| 7 | `DELEGATION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | سند التفويض |
| 8 | `ACTOR_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب وقت القرار |
| 9 | `ACTING_CAPACITY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | SELF, DELEGATE, ACTING, ADMIN, SYSTEM | إدخال المستخدم |  | الصفة |
| 10 | `TARGET_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المحول إليه |
| 11 | `COMMENTS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | التعليق |
| 12 | `VALUES_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | القيم وقت القرار |
| 13 | `SIGNATURE_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_SIGNATURE |  | إدخال المستخدم |  | التوقيع |
| 14 | `SESSION_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_SESSION |  | إدخال المستخدم |  | الجلسة |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## WF_ESCALATION

| البند | القيمة |
|---|---|
| الاسم العربي | التصعيدات |
| English | Escalations |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `TASK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_TASK |  | إدخال المستخدم |  | المهمة |
| 4 | `LEVEL_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | مستوى التصعيد |
| 5 | `ESCALATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | REMINDER, MANAGER, REASSIGN, ADD_APPROVER, HIGHER_LEVEL, SUSPEND, AUTO_REJECT, INCIDENT | إدخال المستخدم |  | النوع |
| 6 | `TARGET_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الجهة المصعد إليها |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## WF_REQUEST_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع الطلبات |
| English | Request Types |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 7 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحزمة |
| 8 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 9 | `RISK_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | LOW, NORMAL, HIGH, CRITICAL | إدخال المستخدم |  | الخطورة |
| 10 | `FORM_SCHEMA` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | تعريف النموذج الديناميكي (لا SQL ولا JavaScript حر) |
| 11 | `REQUIRED_DOC_TYPES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المستندات الإلزامية |
| 12 | `EXECUTION_HANDLER` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | إجراء التنفيذ بعد الاعتماد (Idempotent) |
| 13 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 16 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | الطلبات |
| English | Requests |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, REQUEST_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `REQUEST_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الطلب |
| 6 | `REQUEST_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_REQUEST_TYPE |  | إدخال المستخدم |  | النوع (الإصدار المثبت) |
| 7 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 8 | `REQUESTER_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الطالب |
| 9 | `REQUESTER_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | منصب الطالب |
| 10 | `SUBJECT` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الموضوع |
| 11 | `FORM_DATA` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | بيانات النموذج |
| 12 | `SUBMIT_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | لقطة عند الإرسال |
| 13 | `AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ |
| 14 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 15 | `PARENT_REQUEST_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_REQUEST |  | إدخال المستخدم |  | الطلب الأصل (سلاسل الطلبات) |
| 16 | `REVISION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | رقم المراجعة عند إعادة التقديم |
| 17 | `RESULT_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | المعاملة الناتجة |
| 18 | `RESULT_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرفها |
| 19 | `SUBMITTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإرسال |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, UNDER_REVIEW, RETURNED, APPROVED, EXECUTION_PENDING, EXECUTED, PARTIALLY_EXECUTED, COMPLETED, REJECTED, CANCELLED, WITHDRAWN, EXPIRED, FAILED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_APPROVAL_CONDITION

| البند | القيمة |
|---|---|
| الاسم العربي | شروط الموافقة |
| English | Conditional Approval Obligations |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `INSTANCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_INSTANCE |  | إدخال المستخدم |  | المسار |
| 4 | `TASK_ACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_TASK_ACTION |  | إدخال المستخدم |  | قرار الموافقة المشروطة |
| 5 | `CONDITION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | REDUCE_AMOUNT, GUARANTEE, DOCUMENT, MODIFICATION, ADDITIONAL_APPROVAL, EXECUTION_CAP, OTHER | إدخال المستخدم |  | النوع |
| 6 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الشرط |
| 7 | `IS_MANDATORY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يمنع الإغلاق قبل استيفائه |
| 8 | `DUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | الموعد |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, FULFILLED, WAIVED, BREACHED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_EXCEPTION

| البند | القيمة |
|---|---|
| الاسم العربي | سجل الاستثناءات |
| English | Policy Exceptions |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يمنع الاستثناء الدائم ولا يستخدم لتجاوز عزل Tenant |
| مفاتيح فريدة | UK2: (TENANT_ID, EXCEPTION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EXCEPTION_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرقم |
| 4 | `POLICY_CODE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السياسة المخالفة |
| 5 | `REASON` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 6 | `RISK_ASSESSMENT` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المخاطر |
| 7 | `COMPENSATING_CONTROLS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الضوابط التعويضية |
| 8 | `OWNER_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المالك |
| 9 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | المعاملة |
| 10 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرفها |
| 11 | `STARTS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 12 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الانتهاء (لا تجدد تلقائياً) |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, RISK_REVIEW, PENDING_APPROVAL, APPROVED, ACTIVE, EXPIRED, CLOSED, REJECTED, REVOKED, BREACHED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## WF_ATTESTATION

| البند | القيمة |
|---|---|
| الاسم العربي | الإقرارات |
| English | Attestations |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المقر |
| 4 | `ATTESTATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CONFLICT_OF_INTEREST, DATA_ACCURACY, RECEIPT, COMPLETION, REVIEW, RESPONSIBILITY, CONSENT, CONFIDENTIALITY | إدخال المستخدم |  | النوع |
| 5 | `TEXT_VERSION` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | إصدار نص الإقرار |
| 6 | `ATTESTATION_TEXT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النص كما ظهر |
| 7 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | السياق |
| 8 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | المعرف |
| 9 | `RESPONSE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ACCEPTED, DECLINED, DISCLOSED | إدخال المستخدم |  | الاستجابة |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## DLG_POLICY

| البند | القيمة |
|---|---|
| الاسم العربي | سياسات التفويض |
| English | Delegation Policies |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 7 | `MAX_DURATION_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | أقصى مدة |
| 8 | `ALLOW_REDELEGATION` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | السماح بإعادة التفويض |
| 9 | `NON_DELEGABLE_PERMISSIONS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | العمليات غير القابلة للتفويض |
| 10 | `REQUIRES_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يحتاج اعتماداً |
| 11 | `REVIEW_EVERY_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | دورية المراجعة للتفويض المفتوح |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DLG_TEMPLATE

| البند | القيمة |
|---|---|
| الاسم العربي | قوالب التفويض |
| English | Delegation Templates |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
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
| 6 | `POLICY_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_POLICY |  | إدخال المستخدم |  | السياسة |
| 7 | `DELEGATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | OPERATIONAL, APPROVAL, FINANCIAL, ADMINISTRATIVE, CORRESPONDENCE, SIGNATURE, ACCESS, EMERGENCY, ACTING | إدخال المستخدم |  | النوع |
| 8 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 9 | `TEMPLATE_DATA` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الحقول الإلزامية والنطاق الافتراضي |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DLG_DELEGATION

| البند | القيمة |
|---|---|
| الاسم العربي | التفويضات |
| English | Delegations |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا يعني مشاركة الحساب؛ ينفذ المفوض بهويته ويسجل أنه تصرف نيابة عن المانح (16.1) |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, DELEGATION_NO, VERSION_NO) |
| قيود أعمال | GRANTOR_MEMBER_ID <> DELEGATE_MEMBER_ID<br>ENDS_AT IS NULL OR ENDS_AT > STARTS_AT |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `DELEGATION_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم التفويض |
| 5 | `TEMPLATE_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_TEMPLATE |  | إدخال المستخدم |  | القالب |
| 6 | `DELEGATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | OPERATIONAL, APPROVAL, FINANCIAL, ADMINISTRATIVE, CORRESPONDENCE, SIGNATURE, ACCESS, EMERGENCY, ACTING | إدخال المستخدم |  | النوع |
| 7 | `GRANTOR_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المانح |
| 8 | `GRANTOR_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | الصفة التي صدر بها التفويض |
| 9 | `DELEGATE_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المفوض إليه |
| 10 | `PARENT_DELEGATION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | التفويض الأصل عند إعادة التفويض |
| 11 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK3 |  | إدخال المستخدم |  | إصدار التفويض (التعديل ينشئ إصداراً) |
| 12 | `PREVIOUS_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | الإصدار السابق |
| 13 | `STARTS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 14 | `ENDS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية (فارغ فقط لتفويض تنظيمي موثق) |
| 15 | `TIMEZONE_CODE` | نص | `VARCHAR2(64 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المنطقة الزمنية |
| 16 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 17 | `ABSENCE_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع الغياب أو الحاجة |
| 18 | `LEAVE_REQUEST_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_LEAVE_REQUEST |  | إدخال المستخدم |  | الإجازة المرتبطة |
| 19 | `PRIORITY_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | ترتيب الأولوية بين البدلاء |
| 20 | `ALLOW_REDELEGATION` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بإعادة التفويض |
| 21 | `OPEN_TASK_POLICY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'KEEP' |  | KEEP, TRANSFER, RETURN, REVIEW | إدخال المستخدم |  | سياسة المهام المفتوحة |
| 22 | `INCIDENT_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحادث المرتبط (تفويض الطوارئ) |
| 23 | `NEXT_REVIEW_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | المراجعة التالية |
| 24 | `REVOKE_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإلغاء |
| 25 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, SCHEDULED, ACTIVE, SUSPENDED, EXPIRED, REVOKED, TERMINATED, REJECTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 26 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 27 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 28 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 29 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 30 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 31 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DLG_SCOPE

| البند | القيمة |
|---|---|
| الاسم العربي | نطاق التفويض |
| English | Delegation Scope |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | أقل نطاق لازم؛ لا تفويض شامل غير محدد |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DELEGATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | التفويض |
| 4 | `DIMENSION_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BUSINESS_GROUP, COMPANY, BRANCH, ORG_UNIT, PROJECT, PROPERTY, MODULE, PROCESS, REQUEST_TYPE, WORKFLOW, WORKFLOW_STEP, DOC_TYPE, CORRESPONDENCE_TYPE, TRANSACTION_TYPE, ACTION, PERMISSION, MAX_CONFIDENTIALITY, WORK_HOURS | إدخال المستخدم |  | البعد |
| 5 | `VALUE_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف القيمة |
| 6 | `VALUE_CODE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رمز القيمة |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DLG_LIMIT

| البند | القيمة |
|---|---|
| الاسم العربي | حدود التفويض المالية |
| English | Delegation Limits |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يطبق أقل حد بين سلطة المانح والتفويض والمنصب وCountry Pack وSoD |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DELEGATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | التفويض |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 5 | `MAX_PER_TRANSACTION` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد للمعاملة الواحدة |
| 6 | `MAX_CUMULATIVE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد التراكمي |
| 7 | `USED_CUMULATIVE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | النظام/الحزمة |  | المستخدم تراكمياً |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## DLG_EXERCISE_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | التصرفات المنفذة بالتفويض |
| English | Delegation Exercise Events |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DELEGATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | سند التفويض |
| 4 | `ACTOR_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المنفذ الفعلي |
| 5 | `AUTHORITY_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | صاحب السلطة الأصلي |
| 6 | `ACTION_CODE` | نص | `VARCHAR2(40 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الإجراء |
| 7 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | الكائن |
| 8 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | المعرف |
| 9 | `TASK_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_TASK |  | إدخال المستخدم |  | المهمة |
| 10 | `AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ |
| 11 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 12 | `FX_RATE_USED` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر التحويل لمقارنة السقف |
| 13 | `POLICY_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | لقطة السند والسياسة والحدود وقت القرار |
| 14 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | EXECUTED, REJECTED_OUT_OF_SCOPE, REJECTED_LIMIT, REJECTED_SOD | إدخال المستخدم |  | النتيجة |
| 15 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## DLG_REVIEW

| البند | القيمة |
|---|---|
| الاسم العربي | المراجعة اللاحقة للتفويض |
| English | Delegation Reviews |
| الحزمة المالكة | 03 — `NOONA_WORKFLOW_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DELEGATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | التفويض |
| 4 | `REVIEW_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | EMERGENCY_POST_REVIEW, PERIODIC, MISUSE_SUSPICION, RENEWAL | إدخال المستخدم |  | النوع |
| 5 | `REVIEWER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المراجع |
| 6 | `DUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | المهلة |
| 7 | `FINDINGS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النتائج |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, IN_REVIEW, CONFIRMED, CORRECTIVE_ACTION, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

