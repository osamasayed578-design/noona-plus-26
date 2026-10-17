# قاموس البيانات — الحزمة 19: الموارد البشرية

**Human Resources** · الحزمة البرمجية المالكة `NOONA_HR_PKG` · ملف DDL `db/ddl/p19_hr.sql` · [ERD](../erd/p19_hr.md)

يفصل PERSON (Party) عن EMPLOYEE وعن EMPLOYMENT وعن ASSIGNMENT وعن المستخدم. يشمل العقود والحركات المؤرخة والتوظيف والدوام والإجازات والعمل الإضافي والتدريب والأداء والعهد ونهاية الخدمة، مع سرية مستقلة لبيانات الموظف عن المدير وHR والرواتب.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`HR_EMPLOYEE`](#hr_employee) | الموظفون | Employees | T | CONFIDENTIAL |
| [`HR_EMPLOYMENT`](#hr_employment) | علاقات التوظيف | Employments | T | INTERNAL |
| [`HR_CONTRACT`](#hr_contract) | عقود العمل | Employment Contracts | T | CONFIDENTIAL |
| [`HR_EMPLOYEE_ACTION`](#hr_employee_action) | الحركات الوظيفية | Employee Actions | T | INTERNAL |
| [`HR_DEPENDENT`](#hr_dependent) | المعالون | Dependents | T | HIGHLY_RESTRICTED |
| [`HR_QUALIFICATION`](#hr_qualification) | المؤهلات والشهادات | Qualifications & Certifications | T | INTERNAL |
| [`HR_REQUISITION`](#hr_requisition) | طلبات التوظيف | Job Requisitions | C | INTERNAL |
| [`HR_APPLICANT`](#hr_applicant) | المتقدمون | Applicants | C | CONFIDENTIAL |
| [`HR_OFFER`](#hr_offer) | عروض التوظيف | Job Offers | C | CONFIDENTIAL |
| [`HR_SHIFT`](#hr_shift) | الورديات | Shifts | C | INTERNAL |
| [`HR_WORK_SCHEDULE`](#hr_work_schedule) | جداول الدوام | Work Schedules | C | INTERNAL |
| [`HR_ATTENDANCE_DEVICE`](#hr_attendance_device) | أجهزة الحضور | Attendance Devices | C | INTERNAL |
| [`HR_ATTENDANCE`](#hr_attendance) | سجلات الحضور | Attendance Records | C | INTERNAL |
| [`HR_LEAVE_TYPE`](#hr_leave_type) | أنواع الإجازات | Leave Types | TO | INTERNAL |
| [`HR_LEAVE_BALANCE`](#hr_leave_balance) | أرصدة الإجازات | Leave Balances | T | INTERNAL |
| [`HR_LEAVE_REQUEST`](#hr_leave_request) | طلبات الإجازات | Leave Requests | T | INTERNAL |
| [`HR_OVERTIME_REQUEST`](#hr_overtime_request) | طلبات العمل الإضافي | Overtime Requests | C | INTERNAL |
| [`HR_TRAINING_COURSE`](#hr_training_course) | الدورات التدريبية | Training Courses | T | INTERNAL |
| [`HR_TRAINING_RECORD`](#hr_training_record) | سجل التدريب | Training Records | T | INTERNAL |
| [`HR_PERFORMANCE_CYCLE`](#hr_performance_cycle) | دورات تقييم الأداء | Performance Cycles | C | INTERNAL |
| [`HR_PERFORMANCE_REVIEW`](#hr_performance_review) | تقييمات الأداء | Performance Reviews | C | HIGHLY_RESTRICTED |
| [`HR_DISCIPLINARY_ACTION`](#hr_disciplinary_action) | الإجراءات التأديبية | Disciplinary Actions | C | HIGHLY_RESTRICTED |
| [`HR_CUSTODY`](#hr_custody) | العهد | Employee Custody Items | C | INTERNAL |
| [`HR_END_OF_SERVICE`](#hr_end_of_service) | إنهاء الخدمة وإخلاء الطرف | End of Service & Clearance | C | INTERNAL |

## HR_EMPLOYEE

| البند | القيمة |
|---|---|
| الاسم العربي | الموظفون |
| English | Employees |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, PERSON_PARTY_ID)<br>UK4: (TENANT_ID, EMPLOYEE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 UK4 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `PERSON_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY UK3 |  | إدخال المستخدم |  | الشخص |
| 5 | `EMPLOYEE_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK4 |  | إدخال المستخدم |  | الرقم الوظيفي (لا يعاد استخدامه) |
| 6 | `ORIGINAL_HIRE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ أول تعيين |
| 7 | `WORK_EMAIL` | نص | `VARCHAR2(320 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | البريد الوظيفي |
| 8 | `WORK_MOBILE` | نص | `VARCHAR2(40 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | جوال العمل |
| 9 | `PHOTO_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الصورة |
| 10 | `EMERGENCY_CONTACT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم | ✔ | جهة اتصال الطوارئ |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CANDIDATE' |  | CANDIDATE, ACTIVE, ON_LEAVE, SUSPENDED, TERMINATED, RETIRED, DECEASED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_EMPLOYMENT

| البند | القيمة |
|---|---|
| الاسم العربي | علاقات التوظيف |
| English | Employments |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يمكن للشخص امتلاك تعيينات قانونية متعاقبة دون إعادة استخدام معرف |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة الموظِّفة |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `EMPLOYMENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PERMANENT, FIXED_TERM, PART_TIME, TEMPORARY, SECONDED_IN, INTERN, CONSULTANT | إدخال المستخدم |  | النوع |
| 7 | `EMPLOYEE_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الفئة (مواطن، مقيم...) |
| 8 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 9 | `PROBATION_END_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | نهاية التجربة |
| 10 | `END_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 11 | `TERMINATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | RESIGNATION, END_OF_CONTRACT, TERMINATION, RETIREMENT, DEATH, TRANSFER, OTHER | إدخال المستخدم |  | سبب الانتهاء |
| 12 | `TERMINATION_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | التفاصيل |
| 13 | `MANAGER_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | المدير المباشر |
| 14 | `PAYROLL_GROUP_ID` | معرف | `NUMBER(19)` |  |  | FK→PAY_PAYROLL_GROUP |  | إدخال المستخدم |  | مجموعة الرواتب |
| 15 | `WORK_SCHEDULE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_WORK_SCHEDULE |  | إدخال المستخدم |  | جدول الدوام |
| 16 | `GOSI_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | رقم التأمينات الاجتماعية |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, ACTIVE, SUSPENDED, NOTICE_PERIOD, TERMINATED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_CONTRACT

| البند | القيمة |
|---|---|
| الاسم العربي | عقود العمل |
| English | Employment Contracts |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CONTRACT_NO, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 4 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 5 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 6 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 7 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 8 | `CONTRACT_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم العقد |
| 9 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 10 | `CONTRACT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | UNLIMITED, FIXED_TERM, PART_TIME, TEMPORARY | إدخال المستخدم |  | النوع |
| 11 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 12 | `END_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 13 | `WORKING_HOURS_WEEK` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | ساعات العمل الأسبوعية |
| 14 | `BASIC_SALARY` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الراتب الأساسي المرجعي |
| 15 | `ANNUAL_LEAVE_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الإجازة السنوية التعاقدية |
| 16 | `NOTICE_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة الإشعار |
| 17 | `GOV_CONTRACT_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | التوثيق الحكومي (قوى/مدد) |
| 18 | `SIGNED_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | العقد الموقع |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SIGNED, ACTIVE, RENEWED, EXPIRED, TERMINATED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_EMPLOYEE_ACTION

| البند | القيمة |
|---|---|
| الاسم العربي | الحركات الوظيفية |
| English | Employee Actions |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | الأحداث المؤرخة التي يستهلكها Payroll ونظام الصلاحيات (Joiner-Mover-Leaver) |
| مفاتيح فريدة | UK2: (TENANT_ID, DOC_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 4 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 5 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 6 | `ACTION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | HIRE, TRANSFER, PROMOTION, DEMOTION, GRADE_CHANGE, SALARY_CHANGE, POSITION_CHANGE, SECONDMENT, CONTRACT_CHANGE, SUSPENSION, REINSTATEMENT, TERMINATION, CORRECTION | إدخال المستخدم |  | النوع |
| 7 | `EFFECTIVE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ السريان |
| 8 | `OLD_VALUES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | القيم السابقة |
| 9 | `NEW_VALUES` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | القيم الجديدة |
| 10 | `IMPACT_ANALYSIS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الأثر على المنصب والتفويض والصلاحيات والرواتب |
| 11 | `IS_RETROACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | بأثر رجعي (ينشئ تصحيحاً مؤرخاً) |
| 12 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, SCHEDULED, EFFECTIVE, COMPLETED, REJECTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_DEPENDENT

| البند | القيمة |
|---|---|
| الاسم العربي | المعالون |
| English | Dependents |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 4 | `PERSON_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | المعال |
| 5 | `RELATIONSHIP` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SPOUSE, SON, DAUGHTER, FATHER, MOTHER, OTHER | إدخال المستخدم |  | الصلة |
| 6 | `IS_INSURED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مشمول بالتأمين |
| 7 | `IS_TICKET_ELIGIBLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يستحق تذكرة |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_QUALIFICATION

| البند | القيمة |
|---|---|
| الاسم العربي | المؤهلات والشهادات |
| English | Qualifications & Certifications |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 4 | `QUAL_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DEGREE, DIPLOMA, CERTIFICATE, LICENSE, SKILL, LANGUAGE | إدخال المستخدم |  | النوع |
| 5 | `TITLE` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المسمى |
| 6 | `INSTITUTION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجهة |
| 7 | `OBTAINED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التاريخ |
| 8 | `EXPIRY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | الانتهاء |
| 9 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الشهادة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_REQUISITION

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات التوظيف |
| English | Job Requisitions |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
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
| 6 | `POSITION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب الشاغر |
| 7 | `OPENINGS` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | العدد |
| 8 | `JUSTIFICATION` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المبرر |
| 9 | `TARGET_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التاريخ المستهدف |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, OPEN, FILLED, CANCELLED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_APPLICANT

| البند | القيمة |
|---|---|
| الاسم العربي | المتقدمون |
| English | Applicants |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `REQUISITION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_REQUISITION |  | إدخال المستخدم |  | الطلب |
| 5 | `PERSON_PARTY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الشخص |
| 6 | `SOURCE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | المصدر |
| 7 | `CV_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | السيرة الذاتية |
| 8 | `EVALUATION` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | التقييمات |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NEW' |  | NEW, SCREENING, INTERVIEW, OFFERED, HIRED, REJECTED, WITHDRAWN | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_OFFER

| البند | القيمة |
|---|---|
| الاسم العربي | عروض التوظيف |
| English | Job Offers |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
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
| 8 | `APPLICANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_APPLICANT |  | إدخال المستخدم |  | المتقدم |
| 9 | `POSITION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب |
| 10 | `OFFERED_SALARY` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الراتب المعروض |
| 11 | `PACKAGE_DETAILS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | البدلات والمزايا |
| 12 | `START_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ المباشرة |
| 13 | `EXPIRES_ON` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | صلاحية العرض |
| 14 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | التعيين الناتج |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SENT, ACCEPTED, DECLINED, EXPIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_SHIFT

| البند | القيمة |
|---|---|
| الاسم العربي | الورديات |
| English | Shifts |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
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
| 7 | `START_TIME` | نص | `VARCHAR2(5 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | البداية HH24:MI |
| 8 | `END_TIME` | نص | `VARCHAR2(5 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النهاية HH24:MI |
| 9 | `BREAK_MINUTES` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الاستراحة |
| 10 | `CROSSES_MIDNIGHT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تمتد بعد منتصف الليل |
| 11 | `GRACE_MINUTES` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | سماحية التأخير |
| 12 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_WORK_SCHEDULE

| البند | القيمة |
|---|---|
| الاسم العربي | جداول الدوام |
| English | Work Schedules |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
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
| 7 | `CALENDAR_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_BUSINESS_CALENDAR |  | إدخال المستخدم |  | تقويم العطلات |
| 8 | `PATTERN` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | نمط الورديات لكل يوم |
| 9 | `HOURS_PER_WEEK` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الساعات الأسبوعية |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_ATTENDANCE_DEVICE

| البند | القيمة |
|---|---|
| الاسم العربي | أجهزة الحضور |
| English | Attendance Devices |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 8 | `SITE_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_SITE |  | إدخال المستخدم |  | الموقع |
| 9 | `DEVICE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BIOMETRIC, CARD, MOBILE_GEO, KIOSK | إدخال المستخدم |  | النوع |
| 10 | `SERIAL_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرقم التسلسلي |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_ATTENDANCE

| البند | القيمة |
|---|---|
| الاسم العربي | سجلات الحضور |
| English | Attendance Records |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, EMPLOYEE_ID, WORK_DATE, SOURCE_CODE, CHECK_IN_AT) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE UK2 |  | إدخال المستخدم |  | الموظف |
| 5 | `WORK_DATE` | تاريخ | `DATE` | ✔ |  | UK2 |  | إدخال المستخدم |  | تاريخ العمل |
| 6 | `SHIFT_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_SHIFT |  | إدخال المستخدم |  | الوردية |
| 7 | `CHECK_IN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  | UK2 |  | إدخال المستخدم |  | الدخول |
| 8 | `CHECK_OUT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الخروج |
| 9 | `SOURCE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 | DEVICE, MOBILE, MANUAL, IMPORT, CORRECTION | إدخال المستخدم |  | المصدر |
| 10 | `DEVICE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_ATTENDANCE_DEVICE |  | إدخال المستخدم |  | الجهاز |
| 11 | `WORKED_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | محسوب |  | الدقائق الفعلية |
| 12 | `LATE_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | محسوب |  | التأخير |
| 13 | `EARLY_LEAVE_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | محسوب |  | الخروج المبكر |
| 14 | `OVERTIME_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | محسوب |  | الإضافي |
| 15 | `ABSENCE_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع الغياب |
| 16 | `CORRECTION_OF_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_ATTENDANCE |  | إدخال المستخدم |  | السجل المصحح (لا يعدل المقفل بصمت) |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'RAW' |  | RAW, PROCESSED, APPROVED, EXCEPTION, LOCKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_LEAVE_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع الإجازات |
| English | Leave Types |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
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
| 7 | `IS_PAID` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | مدفوعة |
| 8 | `UNIT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DAY' |  | DAY, HOUR | إدخال المستخدم |  | الوحدة (الاستئذان بالساعة) |
| 9 | `ACCRUAL_RULE` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | قاعدة الاستحقاق والترحيل |
| 10 | `MAX_PER_YEAR` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد السنوي |
| 11 | `REQUIRES_DOCUMENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب مستنداً (مرضية...) |
| 12 | `IS_SENSITIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | سبب حساس (طبي) بخصوصية مقيدة |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_LEAVE_BALANCE

| البند | القيمة |
|---|---|
| الاسم العربي | أرصدة الإجازات |
| English | Leave Balances |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, EMPLOYEE_ID, LEAVE_TYPE_ID, BALANCE_YEAR) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE UK1 |  | إدخال المستخدم |  | الموظف |
| 4 | `LEAVE_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_LEAVE_TYPE UK1 |  | إدخال المستخدم |  | النوع |
| 5 | `BALANCE_YEAR` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | السنة |
| 6 | `OPENING_BALANCE` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الرصيد الافتتاحي/المرحل |
| 7 | `ACCRUED` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المستحق |
| 8 | `TAKEN` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المستخدم |
| 9 | `ADJUSTED` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | التسويات |
| 10 | `ENCASHED` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المصروف نقداً |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_LEAVE_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات الإجازات |
| English | Leave Requests |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, DOC_NO) |
| قيود أعمال | END_DATE >= START_DATE |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 4 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 5 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 6 | `LEAVE_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_LEAVE_TYPE |  | إدخال المستخدم |  | النوع |
| 7 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 8 | `END_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 9 | `START_TIME` | نص | `VARCHAR2(5 CHAR)` |  |  |  |  | إدخال المستخدم |  | ساعة البداية (الاستئذان) |
| 10 | `END_TIME` | نص | `VARCHAR2(5 CHAR)` |  |  |  |  | إدخال المستخدم |  | ساعة النهاية |
| 11 | `DURATION` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المدة بالوحدة |
| 12 | `SUBSTITUTE_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | البديل (لا يمنح سلطة دون تفويض) |
| 13 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب (مقيد الاطلاع) |
| 14 | `SUPPORTING_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 15 | `ACTUAL_RETURN_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ المباشرة الفعلي |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, REJECTED, CANCELLED, TAKEN, RETURNED_EARLY | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_OVERTIME_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات العمل الإضافي |
| English | Overtime Requests |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 5 | `WORK_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 6 | `PLANNED_HOURS` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المخطط |
| 7 | `ACTUAL_HOURS` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الفعلي |
| 8 | `RATE_MULTIPLIER` | رقم | `NUMBER` | ✔ | 1.5 |  |  | إدخال المستخدم |  | معامل الأجر |
| 9 | `PROJECT_ID` | معرف | `NUMBER(19)` |  |  | FK→PRJ_PROJECT |  | إدخال المستخدم |  | المشروع |
| 10 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, APPROVED, REJECTED, PAID | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_TRAINING_COURSE

| البند | القيمة |
|---|---|
| الاسم العربي | الدورات التدريبية |
| English | Training Courses |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
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
| 6 | `PROVIDER` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجهة المقدمة |
| 7 | `DURATION_HOURS` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المدة |
| 8 | `COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_TRAINING_RECORD

| البند | القيمة |
|---|---|
| الاسم العربي | سجل التدريب |
| English | Training Records |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 4 | `COURSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_TRAINING_COURSE |  | إدخال المستخدم |  | الدورة |
| 5 | `START_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 6 | `END_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 7 | `SCORE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | النتيجة |
| 8 | `CERTIFICATE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الشهادة |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, ENROLLED, COMPLETED, FAILED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_PERFORMANCE_CYCLE

| البند | القيمة |
|---|---|
| الاسم العربي | دورات تقييم الأداء |
| English | Performance Cycles |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
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
| 7 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 8 | `END_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 9 | `TEMPLATE` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نموذج التقييم |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, OPEN, CALIBRATION, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_PERFORMANCE_REVIEW

| البند | القيمة |
|---|---|
| الاسم العربي | تقييمات الأداء |
| English | Performance Reviews |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تستخدم نتائج التقييم لتوسيع وصول AI أو التقارير دون سياسة واضحة |
| مفاتيح فريدة | UK1: (CYCLE_ID, EMPLOYEE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CYCLE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_PERFORMANCE_CYCLE UK1 |  | إدخال المستخدم |  | الدورة |
| 5 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE UK1 |  | إدخال المستخدم |  | الموظف |
| 6 | `REVIEWER_EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | المقيم |
| 7 | `OVERALL_RATING` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | التقدير |
| 8 | `GOALS_RESULT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الأهداف والنتائج |
| 9 | `COMMENTS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الملاحظات |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NOT_STARTED' |  | NOT_STARTED, SELF_REVIEW, MANAGER_REVIEW, CALIBRATED, ACKNOWLEDGED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_DISCIPLINARY_ACTION

| البند | القيمة |
|---|---|
| الاسم العربي | الإجراءات التأديبية |
| English | Disciplinary Actions |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, DOC_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 7 | `VIOLATION_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المخالفة |
| 8 | `ACTION_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجزاء |
| 9 | `DEDUCTION_DAYS` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | خصم بالأيام |
| 10 | `DECISION_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | القرار |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, INVESTIGATION, DECIDED, APPEALED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 13 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_CUSTODY

| البند | القيمة |
|---|---|
| الاسم العربي | العهد |
| English | Employee Custody Items |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 5 | `CUSTODY_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ASSET, ITEM, CASH_ADVANCE, CARD, KEY, VEHICLE, DOCUMENT | إدخال المستخدم |  | النوع |
| 6 | `ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل |
| 7 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | الصنف |
| 8 | `SERIAL_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_SERIAL |  | إدخال المستخدم |  | الرقم التسلسلي |
| 9 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 10 | `ASSIGNED_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ التسليم |
| 11 | `RETURNED_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإرجاع |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ASSIGNED' |  | ASSIGNED, RETURNED, LOST, DAMAGED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HR_END_OF_SERVICE

| البند | القيمة |
|---|---|
| الاسم العربي | إنهاء الخدمة وإخلاء الطرف |
| English | End of Service & Clearance |
| الحزمة المالكة | 19 — `NOONA_HR_PKG` |
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
| 6 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 7 | `LAST_WORKING_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | آخر يوم عمل |
| 8 | `CLEARANCE_CHECKLIST` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | العهد والتفويضات والمهام والمستندات والصلاحيات |
| 9 | `EOS_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | مكافأة نهاية الخدمة |
| 10 | `LEAVE_ENCASHMENT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | بدل الإجازات |
| 11 | `DEDUCTIONS` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الخصومات (قروض/عهد) |
| 12 | `NET_SETTLEMENT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الصافي |
| 13 | `PAYROLL_RUN_ID` | معرف | `NUMBER(19)` |  |  | FK→PAY_RUN |  | إدخال المستخدم |  | تشغيل التسوية النهائية |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INITIATED' |  | INITIATED, CLEARANCE_IN_PROGRESS, SETTLEMENT_CALCULATED, APPROVED, PAID, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

