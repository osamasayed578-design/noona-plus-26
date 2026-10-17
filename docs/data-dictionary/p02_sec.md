# قاموس البيانات — الحزمة 02: الهيكل التنظيمي والهوية والأمن

**Organization Structure, Identity & Security** · الحزمة البرمجية المالكة `NOONA_SECURITY_PKG` · ملف DDL `db/ddl/p02_sec.sql` · [ERD](../erd/p02_sec.md)

الشجرة التنظيمية غير محدودة المستويات والوظائف والمناصب والتعيينات واللجان، ثم الهوية والعضوية والجلسات والأدوار والصلاحيات الذرية RESOURCE.ACTION ونطاق البيانات وفصل المهام والوصول المؤقت. القرار: Explicit Deny → Classification → SoD → Context → Allow → Default Deny.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`ORG_STRUCTURE`](#org_structure) | الهياكل التنظيمية | Organizational Structures | C | INTERNAL |
| [`ORG_STRUCTURE_VERSION`](#org_structure_version) | إصدارات الهيكل التنظيمي | Structure Versions | C | INTERNAL |
| [`ORG_UNIT`](#org_unit) | الوحدات التنظيمية | Organizational Units | C | INTERNAL |
| [`ORG_JOB_FAMILY`](#org_job_family) | العائلات الوظيفية | Job Families | T | INTERNAL |
| [`ORG_GRADE`](#org_grade) | الدرجات الوظيفية | Grades | T | CONFIDENTIAL |
| [`ORG_JOB`](#org_job) | الدليل الوظيفي | Job Catalog | T | INTERNAL |
| [`ORG_POSITION`](#org_position) | المناصب | Positions | C | INTERNAL |
| [`ORG_POSITION_ASSIGNMENT`](#org_position_assignment) | تعيينات المناصب | Position Assignments | T | INTERNAL |
| [`ORG_COMMITTEE`](#org_committee) | اللجان والمجالس وفرق العمل | Committees & Councils | T | INTERNAL |
| [`ORG_COMMITTEE_MEMBER`](#org_committee_member) | أعضاء اللجان | Committee Members | T | INTERNAL |
| [`ORG_DYNAMIC_GROUP`](#org_dynamic_group) | المجموعات الديناميكية | Dynamic Groups | T | INTERNAL |
| [`ORG_RESTRUCTURE`](#org_restructure) | طلبات إعادة الهيكلة | Restructuring Requests | C | INTERNAL |
| [`SEC_USER`](#sec_user) | حسابات المستخدمين | User Accounts | G | CONFIDENTIAL |
| [`SEC_LOGIN_NAME_HIST`](#sec_login_name_hist) | سجل أسماء الدخول | Login Name History | G | INTERNAL |
| [`SEC_AUTH_PROVIDER`](#sec_auth_provider) | مزودو المصادقة | Authentication Providers | TO | INTERNAL |
| [`SEC_CREDENTIAL`](#sec_credential) | بيانات الاعتماد المحلية | Local Credentials | G | HIGHLY_RESTRICTED |
| [`SEC_MFA_FACTOR`](#sec_mfa_factor) | عوامل التحقق المتعدد | MFA Factors | G | HIGHLY_RESTRICTED |
| [`SEC_DEVICE`](#sec_device) | الأجهزة الموثوقة | Trusted Devices | G | INTERNAL |
| [`SEC_USER_MEMBERSHIP`](#sec_user_membership) | عضوية المستخدمين في المؤسسات | User Tenant Memberships | T | INTERNAL |
| [`SEC_SESSION`](#sec_session) | جلسات المستخدمين | User Sessions | TO | INTERNAL |
| [`SEC_LOGIN_ATTEMPT`](#sec_login_attempt) | محاولات الدخول | Login Attempts | G | INTERNAL |
| [`SEC_PERMISSION`](#sec_permission) | الصلاحيات الذرية | Permissions | G | INTERNAL |
| [`SEC_ROLE`](#sec_role) | الأدوار | Roles | TO | INTERNAL |
| [`SEC_ROLE_PERMISSION`](#sec_role_permission) | صلاحيات الأدوار | Role Permissions | TO | INTERNAL |
| [`SEC_ROLE_COMPOSITE`](#sec_role_composite) | الأدوار المركبة | Composite Roles | TO | INTERNAL |
| [`SEC_ROLE_GRANT`](#sec_role_grant) | منح الأدوار | Role Grants | T | INTERNAL |
| [`SEC_DATA_SCOPE`](#sec_data_scope) | نطاقات البيانات | Data Scopes | T | INTERNAL |
| [`SEC_FIELD_POLICY`](#sec_field_policy) | سياسات حماية الحقول | Field Protection Policies | TO | INTERNAL |
| [`SEC_SOD_RULE`](#sec_sod_rule) | قواعد فصل المهام | Segregation of Duties Rules | TO | INTERNAL |
| [`SEC_SOD_VIOLATION`](#sec_sod_violation) | مخالفات فصل المهام | SoD Violations | T | INTERNAL |
| [`SEC_ACCESS_REQUEST`](#sec_access_request) | طلبات الوصول المؤقت | Access Requests | T | INTERNAL |
| [`SEC_ACCESS_REVIEW`](#sec_access_review) | حملات مراجعة الصلاحيات | Access Certification Campaigns | T | INTERNAL |
| [`SEC_ACCESS_REVIEW_ITEM`](#sec_access_review_item) | بنود مراجعة الصلاحيات | Access Review Items | T | INTERNAL |
| [`SEC_BREAK_GLASS`](#sec_break_glass) | وصول الطوارئ | Break-Glass Access | T | CONFIDENTIAL |
| [`SEC_RISK`](#sec_risk) | سجل المخاطر الأمنية | Security Risk Register | TO | INTERNAL |
| [`SEC_INCIDENT`](#sec_incident) | الحوادث الأمنية | Security Incidents | TO | INTERNAL |
| [`SEC_DATA_SUBJECT_REQUEST`](#sec_data_subject_request) | طلبات أصحاب البيانات | Data Subject Requests | T | CONFIDENTIAL |

## ORG_STRUCTURE

| البند | القيمة |
|---|---|
| الاسم العربي | الهياكل التنظيمية |
| English | Organizational Structures |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
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
| 7 | `STRUCTURE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ADMINISTRATIVE, FINANCIAL, OPERATIONAL, PROJECT, CORRESPONDENCE, REPORTING, MATRIX | إدخال المستخدم |  | نوع الهيكل |
| 8 | `IS_PRIMARY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | الهيكل الإداري الأساسي (واحد فعال لكل شركة) |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_STRUCTURE_VERSION

| البند | القيمة |
|---|---|
| الاسم العربي | إصدارات الهيكل التنظيمي |
| English | Structure Versions |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يمكن إعداد الهيكل المستقبلي واختباره قبل تفعيله ولا يمحى السابق |
| مفاتيح فريدة | UK2: (STRUCTURE_ID, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `STRUCTURE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_STRUCTURE UK2 |  | إدخال المستخدم |  | الهيكل |
| 5 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الإصدار |
| 6 | `CHANGE_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب إعادة الهيكلة |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, SCHEDULED, ACTIVE, SUPERSEDED, ARCHIVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 9 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 10 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_UNIT

| البند | القيمة |
|---|---|
| الاسم العربي | الوحدات التنظيمية |
| English | Organizational Units |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, STRUCTURE_VERSION_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>PARENT_UNIT_ID IS NULL OR PARENT_UNIT_ID <> ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `STRUCTURE_VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_STRUCTURE_VERSION UK2 |  | إدخال المستخدم |  | إصدار الهيكل |
| 8 | `PARENT_UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_UNIT |  | إدخال المستخدم |  | الوحدة الأم (شجرة غير محدودة؛ يمنع Self-Parent والدورات) |
| 9 | `UNIT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النوع من Lookup (Sector، Directorate، Department، Section، Unit، Office، Team...) |
| 10 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع عند الحاجة |
| 11 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | الموقع |
| 12 | `HEAD_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | منصب رئيس الوحدة (لا يخزن اسم موظف) |
| 13 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة الافتراضي (الوحدة ليست مركز تكلفة) |
| 14 | `HIER_PATH` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | النظام/الحزمة |  | المسار الكامل المحسوب للأداء |
| 15 | `HIER_LEVEL` | عدد صحيح | `NUMBER(10)` |  |  |  |  | النظام/الحزمة |  | المستوى في الشجرة |
| 16 | `RECEIVES_CORRESPONDENCE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | تستقبل مراسلات |
| 17 | `HAS_BUDGET` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تملك موازنة |
| 18 | `CHANGE_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب آخر تغيير |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, FROZEN, MERGED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 21 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 22 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 23 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 24 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 25 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 26 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 27 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_JOB_FAMILY

| البند | القيمة |
|---|---|
| الاسم العربي | العائلات الوظيفية |
| English | Job Families |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
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
| 6 | `PARENT_FAMILY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_JOB_FAMILY |  | إدخال المستخدم |  | العائلة الأم |
| 7 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_GRADE

| البند | القيمة |
|---|---|
| الاسم العربي | الدرجات الوظيفية |
| English | Grades |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `GRADE_LEVEL` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | المستوى |
| 7 | `MIN_SALARY` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأدنى للراتب |
| 8 | `MID_SALARY` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | منتصف السلم |
| 9 | `MAX_SALARY` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأعلى |
| 10 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 11 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 12 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_JOB

| البند | القيمة |
|---|---|
| الاسم العربي | الدليل الوظيفي |
| English | Job Catalog |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | JOB تعريف عام لا يرتبط بموظف بعينه |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 7 | `JOB_FAMILY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_JOB_FAMILY |  | إدخال المستخدم |  | العائلة الوظيفية |
| 8 | `JOB_LEVEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | المستوى (Junior، Senior، Lead، Manager...) |
| 9 | `GRADE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_GRADE |  | إدخال المستخدم |  | الدرجة المرجعية |
| 10 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | تخصيص لشركة (فارغ = كل المؤسسة) |
| 11 | `QUALIFICATIONS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المؤهلات والخبرة |
| 12 | `RESPONSIBILITIES` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | المهام والمسؤوليات |
| 13 | `IS_CRITICAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | وظيفة حرجة (تخطيط التعاقب) |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 16 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_POSITION

| البند | القيمة |
|---|---|
| الاسم العربي | المناصب |
| English | Positions |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | POSITION مقعد معتمد داخل وحدة (13.1) |
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
| 7 | `ORG_UNIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_UNIT |  | إدخال المستخدم |  | الوحدة |
| 8 | `JOB_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_JOB |  | إدخال المستخدم |  | الوظيفة |
| 9 | `GRADE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_GRADE |  | إدخال المستخدم |  | الدرجة |
| 10 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 11 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | الموقع |
| 12 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 13 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 14 | `REPORTS_TO_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب الأعلى (خط الإدارة) |
| 15 | `CAPACITY_FTE` | رقم | `NUMBER` | ✔ | 1 |  |  | إدخال المستخدم |  | السعة FTE |
| 16 | `IS_HEAD` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | منصب رئاسة الوحدة |
| 17 | `BUDGETED_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة المعتمدة في الموازنة |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, APPROVED, VACANT, OCCUPIED, FROZEN, TEMPORARILY_FILLED, CANCELLED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 20 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_POSITION_ASSIGNMENT

| البند | القيمة |
|---|---|
| الاسم العربي | تعيينات المناصب |
| English | Position Assignments |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Person → Employment → Position Assignment → Position → Unit (13.3) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 4 | `POSITION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب |
| 5 | `ASSIGNMENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PRIMARY, ADDITIONAL, ACTING, SECONDMENT, TEMPORARY | إدخال المستخدم |  | نوع التكليف |
| 6 | `FTE_PCT` | نسبة | `NUMBER(9,6)` | ✔ | 100 |  |  | إدخال المستخدم |  | نسبة الوقت |
| 7 | `IS_PERMANENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | دائم |
| 8 | `SALARY_SOURCE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | THIS_POSITION, PRIMARY_POSITION, NONE | إدخال المستخدم |  | مصدر الراتب |
| 9 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 10 | `DECISION_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم القرار |
| 11 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, SCHEDULED, EFFECTIVE, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 14 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_COMMITTEE

| البند | القيمة |
|---|---|
| الاسم العربي | اللجان والمجالس وفرق العمل |
| English | Committees & Councils |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `COMMITTEE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BOARD, COUNCIL, STANDING, TEMPORARY, PROJECT_TEAM, INVENTORY, TENDER, RECEIVING, INVESTIGATION, OTHER | إدخال المستخدم |  | النوع |
| 7 | `OWNER_COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المالكة |
| 8 | `DECISION_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | قرار التشكيل |
| 9 | `QUORUM_RULE` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | قاعدة النصاب والتصويت |
| 10 | `MANDATE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الصلاحيات والنطاق |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, ACTIVE, SUSPENDED, EXPIRED, DISSOLVED, ARCHIVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_COMMITTEE_MEMBER

| البند | القيمة |
|---|---|
| الاسم العربي | أعضاء اللجان |
| English | Committee Members |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>EMPLOYEE_ID IS NOT NULL OR POSITION_ID IS NOT NULL OR EXTERNAL_PARTY_ID IS NOT NULL |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMMITTEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMMITTEE |  | إدخال المستخدم |  | اللجنة |
| 4 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 5 | `POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب (عضوية بالصفة) |
| 6 | `EXTERNAL_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | عضو خارجي |
| 7 | `MEMBER_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CHAIR, VICE_CHAIR, MEMBER, SECRETARY, ALTERNATE, OBSERVER | إدخال المستخدم |  | الدور |
| 8 | `ALTERNATE_FOR_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMMITTEE_MEMBER |  | إدخال المستخدم |  | بديل عن عضو |
| 9 | `HAS_VOTE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | له حق التصويت |
| 10 | `COI_STATUS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | NO_CONFLICT, DISCLOSED, RECUSED, EXCLUDED, REVIEW_REQUIRED | إدخال المستخدم |  | تعارض المصالح |
| 11 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 12 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_DYNAMIC_GROUP

| البند | القيمة |
|---|---|
| الاسم العربي | المجموعات الديناميكية |
| English | Dynamic Groups |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | مثل «جميع مديري الفروع»؛ تحل من قاعدة منشورة ومعتمدة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `RULE_DEFINITION` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | قاعدة الحل المعتمدة (ليست SQL حراً) |
| 7 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | الإصدار |
| 8 | `MAX_MEMBERS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الحد الأقصى للجمهور |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_RESTRUCTURE

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات إعادة الهيكلة |
| English | Restructuring Requests |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, REQUEST_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `REQUEST_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم الطلب |
| 5 | `FROM_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_STRUCTURE_VERSION |  | إدخال المستخدم |  | الإصدار الحالي |
| 6 | `TO_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_STRUCTURE_VERSION |  | إدخال المستخدم |  | الإصدار المستهدف |
| 7 | `EFFECTIVE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ السريان |
| 8 | `IMPACT_ANALYSIS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | أثر على الموظفين والمناصب والتفويضات والصلاحيات وWorkflow... |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, IMPACT_ANALYSIS, APPROVED, SCHEDULED, EXECUTED, VALIDATED, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_USER

| البند | القيمة |
|---|---|
| الاسم العربي | حسابات المستخدمين |
| English | User Accounts |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | USER_ID معرف داخلي ثابت؛ ليس كل موظف مستخدماً ولا كل مستخدم موظفاً (14.1) |
| مفاتيح فريدة | UK1: (PUBLIC_ID)<br>UK2: (USERNAME) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK1 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `USERNAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | اسم الدخول الحالي (مستقل عن USER_ID الثابت) |
| 4 | `EMAIL` | نص | `VARCHAR2(320 CHAR)` | ✔ |  |  |  | إدخال المستخدم | ✔ | البريد الإلكتروني |
| 5 | `MOBILE` | نص | `VARCHAR2(40 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | الجوال (ليس معرفاً ثابتاً) |
| 6 | `DISPLAY_NAME` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم المعروض |
| 7 | `USER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | EMPLOYEE, TENANT_ADMIN, EXTERNAL, CUSTOMER, SUPPLIER, CONTRACTOR, CONSULTANT, AUDITOR, REGULATOR, SERVICE, INTEGRATION, SUPPORT, BREAK_GLASS, PLATFORM_ADMIN | إدخال المستخدم |  | نوع الحساب |
| 8 | `AUTH_PROVIDER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_AUTH_PROVIDER |  | إدخال المستخدم |  | مزود المصادقة الافتراضي |
| 9 | `EXTERNAL_SUBJECT` | نص | `VARCHAR2(256 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعرف لدى مزود الهوية (SSO) |
| 10 | `PREFERRED_LANGUAGE` | رمز لغة | `VARCHAR2(10 CHAR)` | ✔ | 'ar' | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة |
| 11 | `TIMEZONE_CODE` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | المنطقة الزمنية |
| 12 | `MFA_REQUIRED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | MFA إلزامي |
| 13 | `RISK_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | LOW, NORMAL, HIGH, CRITICAL | إدخال المستخدم |  | مستوى المخاطر |
| 14 | `SPONSOR_USER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER |  | إدخال المستخدم |  | الراعي (إلزامي للحسابات الخارجية) |
| 15 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | تاريخ الانتهاء (إلزامي للمؤقت والخارجي) |
| 16 | `LAST_LOGIN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | آخر دخول |
| 17 | `FAILED_LOGINS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | النظام/الحزمة |  | محاولات الدخول الفاشلة المتتالية |
| 18 | `LOCKED_UNTIL` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | مقفل حتى |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REQUESTED' |  | REQUESTED, UNDER_REVIEW, APPROVED, PROVISIONED, INVITED, ACTIVE, LOCKED, PASSWORD_EXPIRED, PENDING_MFA, DORMANT, COMPROMISED, SUSPENDED, DISABLED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_LOGIN_NAME_HIST

| البند | القيمة |
|---|---|
| الاسم العربي | سجل أسماء الدخول |
| English | Login Name History |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `USER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER |  | إدخال المستخدم |  | المستخدم |
| 3 | `OLD_USERNAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم السابق |
| 4 | `NEW_USERNAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم الجديد |
| 5 | `REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## SEC_AUTH_PROVIDER

| البند | القيمة |
|---|---|
| الاسم العربي | مزودو المصادقة |
| English | Authentication Providers |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
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
| 6 | `PROVIDER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | APEX_ACCOUNTS, LOCAL_DB, ENTRA_ID, LDAP, SAML, OIDC, OAUTH2, PASSKEY, CERTIFICATE | إدخال المستخدم |  | النوع |
| 7 | `CONFIG_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الإعدادات غير السرية |
| 8 | `SECRET_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع الأسرار في Vault |
| 9 | `ENFORCE_MFA` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | فرض MFA |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, DISABLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_CREDENTIAL

| البند | القيمة |
|---|---|
| الاسم العربي | بيانات الاعتماد المحلية |
| English | Local Credentials |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `USER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER |  | إدخال المستخدم |  | المستخدم |
| 3 | `CREDENTIAL_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PASSWORD' |  | PASSWORD, RECOVERY_CODE | إدخال المستخدم |  | النوع |
| 4 | `SECRET_HASH` | نص | `VARCHAR2(512 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | Hash آمن فقط (لا نص صريح ولا تشفير قابل للعكس) |
| 5 | `HASH_ALGORITHM` | نص | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الخوارزمية (PBKDF2/Argon2...) |
| 6 | `SALT` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | الملح |
| 7 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 8 | `LAST_CHANGED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر تغيير |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, EXPIRED, REVOKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_MFA_FACTOR

| البند | القيمة |
|---|---|
| الاسم العربي | عوامل التحقق المتعدد |
| English | MFA Factors |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `USER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER |  | إدخال المستخدم |  | المستخدم |
| 3 | `FACTOR_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | TOTP, PASSKEY, SECURITY_KEY, PUSH, SMS, EMAIL_OTP, RECOVERY_CODES, CERTIFICATE | إدخال المستخدم |  | النوع |
| 4 | `FACTOR_LABEL` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف (جهاز...) |
| 5 | `SECRET_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع السر في Vault |
| 6 | `CREDENTIAL_ID` | نص | `VARCHAR2(512 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف Passkey/WebAuthn |
| 7 | `LAST_USED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر استخدام |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, ACTIVE, DISABLED, REVOKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_DEVICE

| البند | القيمة |
|---|---|
| الاسم العربي | الأجهزة الموثوقة |
| English | Trusted Devices |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (USER_ID, DEVICE_FINGERPRINT) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `USER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER UK1 |  | إدخال المستخدم |  | المستخدم |
| 3 | `DEVICE_FINGERPRINT` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | بصمة الجهاز |
| 4 | `DEVICE_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | النوع |
| 5 | `OS_INFO` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | النظام |
| 6 | `LAST_USED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر استخدام |
| 7 | `TRUST_EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | انتهاء الثقة |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'TRUSTED' |  | TRUSTED, UNTRUSTED, BLOCKED, EXPIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_USER_MEMBERSHIP

| البند | القيمة |
|---|---|
| الاسم العربي | عضوية المستخدمين في المؤسسات |
| English | User Tenant Memberships |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | USER → USER_TENANT_MEMBERSHIP → TENANT؛ كل جلسة تعمل في سياق Tenant واحد (10.3) |
| مفاتيح فريدة | UK2: (TENANT_ID, USER_ID) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `USER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER UK2 |  | إدخال المستخدم |  | المستخدم |
| 4 | `PERSON_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الشخص |
| 5 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف (اختياري) |
| 6 | `DEFAULT_COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة الافتراضية |
| 7 | `DEFAULT_BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع الافتراضي |
| 8 | `CLEARANCE_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | مستوى التصريح الأمني |
| 9 | `IS_TENANT_ADMIN` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مسؤول المؤسسة |
| 10 | `SECURITY_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | النظام/الحزمة |  | إصدار أمني لإبطال Cache الصلاحيات فوراً |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INVITED' |  | INVITED, ACTIVE, SUSPENDED, ENDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_SESSION

| البند | القيمة |
|---|---|
| الاسم العربي | جلسات المستخدمين |
| English | User Sessions |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `USER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER |  | إدخال المستخدم |  | المستخدم |
| 4 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | العضوية النشطة |
| 5 | `APEX_SESSION_ID` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | جلسة APEX |
| 6 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة النشطة |
| 7 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع النشط |
| 8 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة |
| 9 | `AUTH_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | طريقة المصادقة |
| 10 | `MFA_LEVEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | مستوى MFA المحقق |
| 11 | `IP_ADDRESS` | نص | `VARCHAR2(45 CHAR)` |  |  |  |  | إدخال المستخدم |  | عنوان IP |
| 12 | `USER_AGENT` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | المتصفح |
| 13 | `DEVICE_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_DEVICE |  | إدخال المستخدم |  | الجهاز |
| 14 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | البداية |
| 15 | `LAST_ACTIVITY_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر نشاط |
| 16 | `ENDED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 17 | `END_REASON` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإنهاء |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, ENDED, EXPIRED, TERMINATED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_LOGIN_ATTEMPT

| البند | القيمة |
|---|---|
| الاسم العربي | محاولات الدخول |
| English | Login Attempts |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الاحتفاظ | سنة على الأقل |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `USERNAME_TRIED` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم المستخدم في المحاولة |
| 3 | `USER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER |  | إدخال المستخدم |  | المستخدم إن وجد |
| 4 | `TENANT_HINT` | نص | `VARCHAR2(63 CHAR)` |  |  |  |  | إدخال المستخدم |  | Tenant المرشح من النطاق |
| 5 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SUCCESS, FAILED, LOCKED, MFA_REQUIRED, MFA_FAILED, DENIED | إدخال المستخدم |  | النتيجة |
| 6 | `ADAPTIVE_DECISION` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | ALLOW, STEP_UP_MFA, LIMIT_SESSION, DENY, REQUIRE_REVIEW | إدخال المستخدم |  | قرار المصادقة التكيفية |
| 7 | `IP_ADDRESS` | نص | `VARCHAR2(45 CHAR)` |  |  |  |  | إدخال المستخدم |  | IP |
| 8 | `USER_AGENT` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | المتصفح |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## SEC_PERMISSION

| البند | القيمة |
|---|---|
| الاسم العربي | الصلاحيات الذرية |
| English | Permissions |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تستخدم FULL_ACCESS في التشغيل اليومي (14.2) |
| مفاتيح فريدة | UK1: (PERMISSION_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 3 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 4 | `PERMISSION_CODE` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | RESOURCE.ACTION مثل SALES_INVOICE.APPROVE |
| 5 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحزمة |
| 6 | `RESOURCE_CODE` | نص | `VARCHAR2(60 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المورد |
| 7 | `ACTION_CODE` | نص | `VARCHAR2(40 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الإجراء (VIEW، CREATE، UPDATE، DELETE، SUBMIT، APPROVE، POST، REVERSE، CANCEL، PRINT، EXPORT، ARCHIVE، CONFIGURE...) |
| 8 | `RISK_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | LOW, NORMAL, HIGH, CRITICAL | إدخال المستخدم |  | الخطورة |
| 9 | `REQUIRES_MFA` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب إعادة تحقق |
| 10 | `IS_DELEGABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | قابل للتفويض |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_ROLE

| البند | القيمة |
|---|---|
| الاسم العربي | الأدوار |
| English | Roles |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
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
| 7 | `ROLE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PLATFORM, TENANT, COMPANY, BRANCH, FUNCTIONAL, JOB, POSITION, PROJECT, COMMITTEE, TEMPORARY, EXTERNAL, SUPPORT, EMERGENCY | إدخال المستخدم |  | نوع الدور |
| 8 | `IS_TEMPLATE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | قالب قياسي من NOONA |
| 9 | `SOURCE_TEMPLATE_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_ROLE |  | إدخال المستخدم |  | القالب المنسوخ منه (لا تنتشر تحديثاته تلقائياً) |
| 10 | `IS_PRIVILEGED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | دور مميز يتطلب MFA وتدقيقاً موسعاً |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_ROLE_PERMISSION

| البند | القيمة |
|---|---|
| الاسم العربي | صلاحيات الأدوار |
| English | Role Permissions |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (ROLE_ID, PERMISSION_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `ROLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_ROLE UK1 |  | إدخال المستخدم |  | الدور |
| 4 | `PERMISSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_PERMISSION UK1 |  | إدخال المستخدم |  | الصلاحية |
| 5 | `EFFECT` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ALLOW' |  | ALLOW, DENY | إدخال المستخدم |  | الأثر (Explicit Deny يتقدم) |
| 6 | `CONDITION_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | شروط ABAC إضافية (المبلغ، الحالة...) |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_ROLE_COMPOSITE

| البند | القيمة |
|---|---|
| الاسم العربي | الأدوار المركبة |
| English | Composite Roles |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PARENT_ROLE_ID, CHILD_ROLE_ID) |
| قيود أعمال | PARENT_ROLE_ID <> CHILD_ROLE_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `PARENT_ROLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_ROLE UK1 |  | إدخال المستخدم |  | الدور المركب |
| 4 | `CHILD_ROLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_ROLE UK1 |  | إدخال المستخدم |  | الدور المتضمن |
| 5 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 8 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 9 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_ROLE_GRANT

| البند | القيمة |
|---|---|
| الاسم العربي | منح الأدوار |
| English | Role Grants |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يحفظ المصدر والنطاق والسريان والسبب؛ يدعم شاشتي Why/What can this user access |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | العضوية |
| 4 | `ROLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_ROLE |  | إدخال المستخدم |  | الدور |
| 5 | `GRANT_SOURCE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | POSITION, JOB, ORG_UNIT, ASSIGNMENT, PROJECT, COMMITTEE, MANUAL, DELEGATION, EMERGENCY, ACCESS_REQUEST | إدخال المستخدم |  | مصدر المنح |
| 6 | `SOURCE_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف المصدر (منصب، مشروع...) |
| 7 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 8 | `REQUESTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | الطالب |
| 9 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 10 | `LAST_USED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | آخر استخدام |
| 11 | `NEXT_REVIEW_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | المراجعة الدورية التالية |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REQUESTED' |  | REQUESTED, APPROVED, ACTIVE, EXPIRED, REVOKED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 14 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_DATA_SCOPE

| البند | القيمة |
|---|---|
| الاسم العربي | نطاقات البيانات |
| English | Data Scopes |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | المستخدم قد يملك نطاقات مختلفة في كل شركة وفرع ومشروع |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `ROLE_GRANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_ROLE_GRANT |  | إدخال المستخدم |  | المنح |
| 4 | `SCOPE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | OWN, ASSIGNED, ORG_UNIT, ORG_UNIT_TREE, BRANCH, COMPANY, BUSINESS_GROUP, PROJECT, PROPERTY, WAREHOUSE, COST_CENTER, CUSTOMER_PORTFOLIO, SUPPLIER_PORTFOLIO, REGION, ALL_TENANT | إدخال المستخدم |  | نوع النطاق |
| 5 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 6 | `SCOPE_VALUE_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف القيمة (فرع، وحدة، مشروع...) |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_FIELD_POLICY

| البند | القيمة |
|---|---|
| الاسم العربي | سياسات حماية الحقول |
| English | Field Protection Policies |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, TABLE_NAME, COLUMN_NAME, ROLE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `TABLE_NAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الجدول |
| 4 | `COLUMN_NAME` | نص | `VARCHAR2(128 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | العمود |
| 5 | `ROLE_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_ROLE UK1 |  | إدخال المستخدم |  | الدور (فارغ = الافتراضي) |
| 6 | `PROTECTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | VISIBLE, MASKED, REDACTED, HIDDEN, READ_ONLY | إدخال المستخدم |  | مستوى الحماية |
| 7 | `MASK_PATTERN` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | نمط الإخفاء |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_SOD_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد فصل المهام |
| English | Segregation of Duties Rules |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |
| قيود أعمال | PERMISSION_A_ID <> PERMISSION_B_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `PERMISSION_A_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_PERMISSION |  | إدخال المستخدم |  | الصلاحية الأولى |
| 7 | `PERMISSION_B_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_PERMISSION |  | إدخال المستخدم |  | الصلاحية المتعارضة |
| 8 | `SEVERITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PROHIBITED, HIGH_RISK, REVIEW_REQUIRED, MONITORED | إدخال المستخدم |  | الخطورة |
| 9 | `SAME_RECORD_ONLY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | التعارض على نفس السجل فقط (مثل إنشاء واعتماد نفس الفاتورة) |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_SOD_VIOLATION

| البند | القيمة |
|---|---|
| الاسم العربي | مخالفات فصل المهام |
| English | SoD Violations |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `SOD_RULE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_SOD_RULE |  | إدخال المستخدم |  | القاعدة |
| 4 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 5 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | السجل المعني |
| 6 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | المعرف |
| 7 | `DETECTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت الاكتشاف |
| 8 | `EXCEPTION_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_EXCEPTION |  | إدخال المستخدم |  | الاستثناء المعتمد |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DETECTED' |  | DETECTED, UNDER_REVIEW, ACCEPTED, MITIGATED, RESOLVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_ACCESS_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات الوصول المؤقت |
| English | Access Requests |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | REQUESTED_TO > REQUESTED_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستفيد |
| 4 | `ROLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_ROLE |  | إدخال المستخدم |  | الدور المطلوب |
| 5 | `SCOPE_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | النطاق المطلوب |
| 6 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 7 | `REQUESTED_FROM` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | من |
| 8 | `REQUESTED_TO` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | إلى (انتهاء تلقائي) |
| 9 | `ROLE_GRANT_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_ROLE_GRANT |  | إدخال المستخدم |  | المنح الناتج |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, UNDER_REVIEW, APPROVED, PROVISIONED, REJECTED, EXPIRED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_ACCESS_REVIEW

| البند | القيمة |
|---|---|
| الاسم العربي | حملات مراجعة الصلاحيات |
| English | Access Certification Campaigns |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
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
| 6 | `REVIEW_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PERIODIC, SENSITIVE, TRANSFER, MANAGER_CHANGE, PROJECT_END, SERVICE_ACCOUNT | إدخال المستخدم |  | النوع |
| 7 | `DUE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | الموعد |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, IN_PROGRESS, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_ACCESS_REVIEW_ITEM

| البند | القيمة |
|---|---|
| الاسم العربي | بنود مراجعة الصلاحيات |
| English | Access Review Items |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `ACCESS_REVIEW_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_ACCESS_REVIEW |  | إدخال المستخدم |  | الحملة |
| 4 | `ROLE_GRANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_ROLE_GRANT |  | إدخال المستخدم |  | المنح |
| 5 | `REVIEWER_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المراجع |
| 6 | `DECISION_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت القرار |
| 7 | `COMMENTS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, CONFIRMED, REDUCED, REVOKED, EXPLANATION_REQUESTED, EXTENDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_BREAK_GLASS

| البند | القيمة |
|---|---|
| الاسم العربي | وصول الطوارئ |
| English | Break-Glass Access |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | محدود ومبرر ومدقق مع تنبيه فوري (6.10.10) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 4 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المبرر |
| 5 | `INCIDENT_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحادث المرتبط |
| 6 | `STARTS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 7 | `ENDS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 8 | `REVIEWED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المراجع اللاحق |
| 9 | `REVIEW_RESULT` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | نتيجة المراجعة |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REQUESTED' |  | REQUESTED, ACTIVE, ENDED, REVIEWED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_RISK

| البند | القيمة |
|---|---|
| الاسم العربي | سجل المخاطر الأمنية |
| English | Security Risk Register |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `TITLE` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 5 | `LIKELIHOOD` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الاحتمال (1-5) |
| 6 | `IMPACT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الأثر (1-5) |
| 7 | `OWNER_USER` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المالك |
| 8 | `TREATMENT_PLAN` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | خطة المعالجة |
| 9 | `REVIEW_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | المراجعة التالية |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'IDENTIFIED' |  | IDENTIFIED, ASSESSED, TREATMENT_PLANNED, IN_PROGRESS, MITIGATED, ACCEPTED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_INCIDENT

| البند | القيمة |
|---|---|
| الاسم العربي | الحوادث الأمنية |
| English | Security Incidents |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, INCIDENT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `INCIDENT_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم الحادث |
| 4 | `SEVERITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SEV1, SEV2, SEV3, SEV4 | إدخال المستخدم |  | الخطورة |
| 5 | `CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | التصنيف |
| 6 | `DETECTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | وقت الاكتشاف |
| 7 | `SUMMARY` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الملخص |
| 8 | `CONTAINMENT` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | إجراءات الاحتواء |
| 9 | `ROOT_CAUSE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب الجذري |
| 10 | `NOTIFICATION_REQUIRED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب إخطاراً قانونياً/تعاقدياً |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NEW' |  | NEW, TRIAGED, INVESTIGATING, CONTAINED, RESOLVED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## SEC_DATA_SUBJECT_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات أصحاب البيانات |
| English | Data Subject Requests |
| الحزمة المالكة | 02 — `NOONA_SECURITY_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, REQUEST_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `REQUEST_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم الطلب |
| 4 | `PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | صاحب البيانات |
| 5 | `REQUEST_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ACCESS, CORRECTION, DELETION, RESTRICTION, PORTABILITY, OBJECTION | إدخال المستخدم |  | النوع |
| 6 | `DUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | المهلة النظامية |
| 7 | `DECISION_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب القرار |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REQUESTED' |  | REQUESTED, IDENTITY_VERIFIED, UNDER_REVIEW, APPROVED, REJECTED, EXECUTED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

