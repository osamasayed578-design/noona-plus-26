# قاموس البيانات — الحزمة 31: المستشفيات والمراكز الطبية

**Hospital & Clinics** · الحزمة البرمجية المالكة `NOONA_HIS_PKG` · ملف DDL `db/ddl/p31_his.sql` · [ERD](../erd/p31_his.md)

الأقسام والعيادات والمعامل والأشعة والصيدليات الداخلية والوحدات العلاجية كأقسام مستقلة بمستودعاتها ومراكز تكلفتها، الأطباء وساعات العمل، دليل الخدمات الطبية ومواد كل فحص، شركات التأمين والجهات المتعاقدة بفئاتها وأسعارها، المرضى والحجوزات والزيارات والطلبات الطبية ونتائجها، والفواتير بحصة المريض وحصة الجهة والقيد المحاسبي.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`HIS_DEPARTMENT`](#his_department) | الأقسام الطبية | Medical Departments | C | INTERNAL |
| [`HIS_SERVICE`](#his_service) | دليل الخدمات الطبية | Medical Services Catalogue | C | INTERNAL |
| [`HIS_SERVICE_MATERIAL`](#his_service_material) | مواد الخدمة المستهلكة | Service Consumables | C | INTERNAL |
| [`HIS_DOCTOR`](#his_doctor) | الأطباء والممارسون | Doctors & Practitioners | C | INTERNAL |
| [`HIS_DOCTOR_SCHEDULE`](#his_doctor_schedule) | ساعات عمل الأطباء | Doctor Working Hours | C | INTERNAL |
| [`HIS_PAYER`](#his_payer) | شركات التأمين والجهات المتعاقدة | Insurers & Contracted Companies | C | INTERNAL |
| [`HIS_PAYER_PLAN`](#his_payer_plan) | فئات التغطية | Coverage Plans / Classes | C | INTERNAL |
| [`HIS_PAYER_PRICE`](#his_payer_price) | أسعار العقود | Contract Prices | C | INTERNAL |
| [`HIS_PATIENT`](#his_patient) | المرضى | Patients | C | CONFIDENTIAL |
| [`HIS_APPOINTMENT`](#his_appointment) | المواعيد والحجوزات | Appointments | C | INTERNAL |
| [`HIS_VISIT`](#his_visit) | الزيارات | Visits / Encounters | C | CONFIDENTIAL |
| [`HIS_INVOICE`](#his_invoice) | فواتير الزيارات | Visit Invoices | C | INTERNAL |
| [`HIS_ORDER`](#his_order) | الطلبات والخدمات الطبية | Medical Orders | C | CONFIDENTIAL |

## HIS_DEPARTMENT

| البند | القيمة |
|---|---|
| الاسم العربي | الأقسام الطبية |
| English | Medical Departments |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | كل معمل (كيمياء، دم، أحياء دقيقة، أنسجة) وكل وحدة أشعة وصيدلية داخلية قسم مستقل بمستودعه ومركز تكلفته |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `DEPT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CLINIC, EMERGENCY, LAB, RADIOLOGY, CARDIO_DIAG, PHARMACY, INPATIENT_WARD, OPERATING_THEATER, PHYSIOTHERAPY, THERAPY_UNIT, DENTAL, DIALYSIS, NURSING, OTHER | إدخال المستخدم |  | النوع |
| 8 | `SPECIALTY` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | التخصص (باطنة، أطفال، كيمياء حيوية، أمراض دم...) |
| 9 | `WAREHOUSE_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_WAREHOUSE |  | إدخال المستخدم |  | مستودع القسم (مواد المعمل، الصيدلية الداخلية) |
| 10 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة |
| 11 | `REVENUE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الإيراد (فارغ = حسب نوع الخدمة) |
| 12 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الهاتف الداخلي |
| 13 | `LOCATION_TEXT` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الموقع (الدور، الجناح) |
| 14 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الترتيب |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_SERVICE

| البند | القيمة |
|---|---|
| الاسم العربي | دليل الخدمات الطبية |
| English | Medical Services Catalogue |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
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
| 7 | `SERVICE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CONSULTATION, FOLLOW_UP, EMERGENCY, LAB, RADIOLOGY, CARDIO_DIAG, PROCEDURE, MINOR_SURGERY, MAJOR_SURGERY, PHYSIOTHERAPY, THERAPY, NURSING, DENTAL, BED, MEDICATION, PACKAGE, OTHER | إدخال المستخدم |  | نوع الخدمة |
| 8 | `MODALITY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | XRAY, CT, MRI, ULTRASOUND, DOPPLER, MAMMOGRAPHY, FLUOROSCOPY, DEXA, NUCLEAR, PET, ECG, ECHO, STRESS_TEST, HOLTER, EEG, EMG, ENDOSCOPY | إدخال المستخدم |  | جهاز الأشعة/التشخيص |
| 9 | `DEPARTMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | القسم المنفذ |
| 10 | `BILLING_CODE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رمز الفوترة (CPT / SBS) |
| 11 | `PRICE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | السعر النقدي (قبل الضريبة) |
| 12 | `DURATION_MIN` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | المدة بالدقائق |
| 13 | `SAMPLE_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | BLOOD, SERUM, PLASMA, URINE, STOOL, SWAB, CSF, TISSUE, SPUTUM, OTHER | إدخال المستخدم |  | نوع العينة (للمعامل) |
| 14 | `TURNAROUND_HOURS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | زمن ظهور النتيجة بالساعات |
| 15 | `NORMAL_RANGE` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعدل الطبيعي والوحدة (للمعامل) |
| 16 | `NEEDS_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يحتاج موافقة مسبقة من التأمين |
| 17 | `ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_ITEM |  | إدخال المستخدم |  | صنف الدواء/المستلزم (للصرف من الصيدلية) |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_SERVICE_MATERIAL

| البند | القيمة |
|---|---|
| الاسم العربي | مواد الخدمة المستهلكة |
| English | Service Consumables |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | مواد المعمل والأشعة والعمليات تصرف من مستودع القسم عند إنجاز الخدمة |
| مفاتيح فريدة | UK1: (SERVICE_ID, ITEM_ID) |
| قيود أعمال | QUANTITY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SERVICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_SERVICE UK1 |  | إدخال المستخدم |  | الخدمة |
| 5 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM UK1 |  | إدخال المستخدم |  | المادة (كاشف، أنابيب، أفلام، مستلزمات) |
| 6 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية لكل خدمة |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_DOCTOR

| البند | القيمة |
|---|---|
| الاسم العربي | الأطباء والممارسون |
| English | Doctors & Practitioners |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
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
| 7 | `DEPARTMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | القسم |
| 8 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف (للرواتب والدوام) |
| 9 | `TITLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SPECIALIST' |  | CONSULTANT, SPECIALIST, RESIDENT, GP, DENTIST, SURGEON, ANESTHETIST, RADIOLOGIST, PATHOLOGIST, PHYSIOTHERAPIST, TECHNICIAN, NURSE, PHARMACIST | إدخال المستخدم |  | الدرجة/الوظيفة |
| 10 | `SPECIALTY` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | التخصص |
| 11 | `LICENSE_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الترخيص المهني (الهيئة السعودية للتخصصات الصحية) |
| 12 | `LICENSE_EXPIRY` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | انتهاء الترخيص |
| 13 | `MOBILE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | الجوال |
| 14 | `CONSULT_SERVICE_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_SERVICE |  | إدخال المستخدم |  | خدمة الكشف الافتراضية |
| 15 | `COMMISSION_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة الطبيب من الإيراد |
| 16 | `USER_NAME` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | مستخدم الدخول (لقائمة مرضاه) |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, ON_LEAVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_DOCTOR_SCHEDULE

| البند | القيمة |
|---|---|
| الاسم العربي | ساعات عمل الأطباء |
| English | Doctor Working Hours |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>WEEKDAY BETWEEN 1 AND 7<br>TO_TIME > FROM_TIME |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOCTOR_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الطبيب |
| 5 | `WEEKDAY` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | اليوم (1 الأحد ... 7 السبت) |
| 6 | `FROM_TIME` | نص | `VARCHAR2(5 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | من (HH24:MI) |
| 7 | `TO_TIME` | نص | `VARCHAR2(5 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | إلى (HH24:MI) |
| 8 | `SLOT_MINUTES` | عدد صحيح | `NUMBER(10)` | ✔ | 15 |  |  | إدخال المستخدم |  | مدة الموعد بالدقائق |
| 9 | `DEPARTMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | العيادة/القسم |
| 10 | `ROOM` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | الغرفة |
| 11 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 12 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_PAYER

| البند | القيمة |
|---|---|
| الاسم العربي | شركات التأمين والجهات المتعاقدة |
| English | Insurers & Contracted Companies |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
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
| 7 | `PAYER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INSURANCE, TPA, CORPORATE, GOVERNMENT, CHARITY | إدخال المستخدم |  | النوع |
| 8 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | حساب الذمة (المطالبات) |
| 9 | `DISCOUNT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | الخصم العام على الأسعار النقدية |
| 10 | `CLAIM_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مهلة سداد المطالبات بالأيام |
| 11 | `CONTRACT_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم العقد |
| 12 | `CONTRACT_FROM` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | بداية العقد |
| 13 | `CONTRACT_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | نهاية العقد |
| 14 | `PHONE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الهاتف |
| 15 | `EMAIL` | نص | `VARCHAR2(320 CHAR)` |  |  |  |  | إدخال المستخدم |  | البريد |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, SUSPENDED, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_PAYER_PLAN

| البند | القيمة |
|---|---|
| الاسم العربي | فئات التغطية |
| English | Coverage Plans / Classes |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PAYER_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `PAYER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PAYER UK2 |  | إدخال المستخدم |  | الجهة |
| 8 | `PATIENT_SHARE_PCT` | نسبة | `NUMBER(9,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | نسبة تحمل المريض |
| 9 | `MAX_PATIENT_SHARE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأعلى لتحمل المريض في الزيارة |
| 10 | `APPROVAL_LIMIT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الخدمة التي تتجاوز هذا المبلغ تحتاج موافقة |
| 11 | `EXCLUDED_TYPES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | أنواع خدمات غير مغطاة (مفصولة بفواصل) |
| 12 | `ANNUAL_LIMIT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد السنوي للمستفيد |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_PAYER_PRICE

| البند | القيمة |
|---|---|
| الاسم العربي | أسعار العقود |
| English | Contract Prices |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PAYER_ID, SERVICE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PAYER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PAYER UK1 |  | إدخال المستخدم |  | الجهة |
| 5 | `SERVICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_SERVICE UK1 |  | إدخال المستخدم |  | الخدمة |
| 6 | `PRICE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | سعر العقد (فارغ = السعر النقدي بعد الخصم العام) |
| 7 | `IS_COVERED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | مغطاة |
| 8 | `NEEDS_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تحتاج موافقة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_PATIENT

| البند | القيمة |
|---|---|
| الاسم العربي | المرضى |
| English | Patients |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, COMPANY_ID, MRN) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `MRN` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | الرقم الطبي |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم | ✔ | الاسم |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | الاسم بالإنجليزية |
| 8 | `GENDER` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | M, F | إدخال المستخدم |  | الجنس |
| 9 | `BIRTH_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم | ✔ | تاريخ الميلاد |
| 10 | `ID_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | NATIONAL_ID, IQAMA, PASSPORT, BORDER_NO, BIRTH_CERT | إدخال المستخدم |  | نوع الهوية |
| 11 | `ID_NO` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | رقم الهوية |
| 12 | `NATIONALITY` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الجنسية (السعودي معفى من ضريبة الخدمات الصحية) |
| 13 | `MOBILE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | الجوال |
| 14 | `BLOOD_GROUP` | نص | `VARCHAR2(5 CHAR)` |  |  |  |  | إدخال المستخدم |  | فصيلة الدم |
| 15 | `ALLERGIES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحساسية |
| 16 | `CHRONIC_DISEASES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الأمراض المزمنة |
| 17 | `PAYER_PLAN_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_PAYER_PLAN |  | إدخال المستخدم |  | التأمين/الجهة وفئة التغطية |
| 18 | `MEMBER_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم العضوية |
| 19 | `POLICY_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الوثيقة |
| 20 | `INSURANCE_EXPIRY` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | انتهاء التأمين |
| 21 | `CUSTOMER_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→AR_CUSTOMER_ACCOUNT |  | إدخال المستخدم |  | حساب المريض (المتبقي عليه) |
| 22 | `ADDRESS` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | العنوان |
| 23 | `EMERGENCY_CONTACT` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | جهة الاتصال للطوارئ |
| 24 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE, DECEASED, MERGED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 25 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 26 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 27 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 28 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 29 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_APPOINTMENT

| البند | القيمة |
|---|---|
| الاسم العربي | المواعيد والحجوزات |
| English | Appointments |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, APPT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `APPT_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الحجز |
| 5 | `PATIENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PATIENT |  | إدخال المستخدم |  | المريض |
| 6 | `DOCTOR_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الطبيب |
| 7 | `DEPARTMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | العيادة/القسم |
| 8 | `SERVICE_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_SERVICE |  | إدخال المستخدم |  | الخدمة (كشف، أشعة، جلسة...) |
| 9 | `APPT_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 10 | `START_TIME` | نص | `VARCHAR2(5 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوقت |
| 11 | `END_TIME` | نص | `VARCHAR2(5 CHAR)` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 12 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PHONE' |  | WALK_IN, PHONE, WEB, APP, REFERRAL | إدخال المستخدم |  | القناة |
| 13 | `VISIT_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | الزيارة الناتجة |
| 14 | `CANCEL_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإلغاء |
| 15 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'BOOKED' |  | BOOKED, CONFIRMED, ARRIVED, COMPLETED, NO_SHOW, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_VISIT

| البند | القيمة |
|---|---|
| الاسم العربي | الزيارات |
| English | Visits / Encounters |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, COMPANY_ID, VISIT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `VISIT_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الزيارة |
| 7 | `VISIT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OUTPATIENT' |  | OUTPATIENT, EMERGENCY, INPATIENT, DAY_CASE, REFERRAL_IN | إدخال المستخدم |  | النوع |
| 8 | `PATIENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PATIENT |  | إدخال المستخدم |  | المريض |
| 9 | `DEPARTMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | القسم |
| 10 | `DOCTOR_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الطبيب المعالج |
| 11 | `APPOINTMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_APPOINTMENT |  | إدخال المستخدم |  | الموعد |
| 12 | `VISIT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت الزيارة |
| 13 | `CLOSED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإقفال |
| 14 | `BILL_TO` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CASH' |  | CASH, PAYER | إدخال المستخدم |  | الدفع (نقدي أو جهة) |
| 15 | `PAYER_PLAN_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_PAYER_PLAN |  | إدخال المستخدم |  | فئة التغطية المثبتة للزيارة |
| 16 | `APPROVAL_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الموافقة |
| 17 | `CHIEF_COMPLAINT` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الشكوى |
| 18 | `DIAGNOSIS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | التشخيص |
| 19 | `ICD10` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رمز التشخيص ICD-10 |
| 20 | `VITALS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | العلامات الحيوية |
| 21 | `DOCTOR_NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات الطبيب |
| 22 | `GROSS_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي قبل الخصم |
| 23 | `PATIENT_TOTAL` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المستحق على المريض (شامل الضريبة) |
| 24 | `PAYER_TOTAL` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المستحق على الجهة (شامل الضريبة) |
| 25 | `PAID_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المدفوع من المريض |
| 26 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 27 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 28 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 29 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 30 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 31 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_INVOICE

| البند | القيمة |
|---|---|
| الاسم العربي | فواتير الزيارات |
| English | Visit Invoices |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
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
| 8 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 9 | `PATIENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PATIENT |  | إدخال المستخدم |  | المريض |
| 10 | `PAYER_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_PAYER |  | إدخال المستخدم |  | الجهة |
| 11 | `GROSS_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي قبل الخصم |
| 12 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | خصم العقد |
| 13 | `PATIENT_NET` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | حصة المريض قبل الضريبة |
| 14 | `PATIENT_VAT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | ضريبة حصة المريض |
| 15 | `PAYER_NET` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | حصة الجهة قبل الضريبة |
| 16 | `PAYER_VAT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | ضريبة حصة الجهة |
| 17 | `PATIENT_TOTAL` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المطلوب من المريض |
| 18 | `PAYER_TOTAL` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المطالبة على الجهة |
| 19 | `PAID_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المدفوع |
| 20 | `PAYMENT_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | طريقة الدفع |
| 21 | `PAYMENT_PLACE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الصندوق/البنك (BOX:n / BANK:n) |
| 22 | `PAYMENT_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع الدفع |
| 23 | `CLAIM_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NONE' |  | NONE, PENDING, SUBMITTED, PAID, PARTIAL, REJECTED | إدخال المستخدم |  | حالة المطالبة |
| 24 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'POSTED' |  | POSTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 25 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 26 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 27 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 28 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 29 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 30 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 31 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 32 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_ORDER

| البند | القيمة |
|---|---|
| الاسم العربي | الطلبات والخدمات الطبية |
| English | Medical Orders |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (VISIT_ID, LINE_NO) |
| قيود أعمال | QUANTITY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT UK1 |  | إدخال المستخدم |  | الزيارة |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | السطر |
| 6 | `SERVICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_SERVICE |  | إدخال المستخدم |  | الخدمة |
| 7 | `DEPARTMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | القسم المنفذ (المعمل/الأشعة/العيادة) |
| 8 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ | 1 |  |  | إدخال المستخدم |  | الكمية |
| 9 | `ORDERED_BY_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الطبيب الطالب |
| 10 | `PERFORMED_BY_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | المنفذ |
| 11 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | سعر الوحدة (نقدي أو سعر العقد) |
| 12 | `GROSS_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الإجمالي |
| 13 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | خصم العقد |
| 14 | `PATIENT_NET` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | حصة المريض قبل الضريبة |
| 15 | `PAYER_NET` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | حصة الجهة قبل الضريبة |
| 16 | `VAT_RATE` | نسبة | `NUMBER(9,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | نسبة الضريبة |
| 17 | `PATIENT_VAT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | ضريبة حصة المريض |
| 18 | `PAYER_VAT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | ضريبة حصة الجهة |
| 19 | `COVERED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مغطاة من الجهة |
| 20 | `APPROVAL_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم موافقة التأمين |
| 21 | `INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 22 | `SAMPLE_NO` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم العينة |
| 23 | `SAMPLE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت سحب العينة |
| 24 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | بدء التنفيذ |
| 25 | `COMPLETED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الإنجاز |
| 26 | `RESULT_TEXT` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | النتيجة / التقرير |
| 27 | `RESULT_FLAG` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | NORMAL, ABNORMAL, CRITICAL | إدخال المستخدم |  | تقييم النتيجة |
| 28 | `RESULT_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | معتمد النتيجة |
| 29 | `MATERIAL_TXN_ID` | معرف | `NUMBER(19)` |  |  | FK→INV_TRANSACTION |  | إدخال المستخدم |  | حركة صرف المواد |
| 30 | `MATERIAL_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تكلفة المواد |
| 31 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات الطلب |
| 32 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ORDERED' |  | ORDERED, APPROVAL_PENDING, IN_PROGRESS, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 33 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 34 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 35 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 36 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 37 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

