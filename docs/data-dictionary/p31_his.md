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
| [`HIS_LAB_PARAM`](#his_lab_param) | مكونات التحاليل والمعدلات | Lab Test Parameters | C | INTERNAL |
| [`HIS_LAB_RESULT`](#his_lab_result) | نتائج مكونات التحاليل | Lab Results | C | CONFIDENTIAL |
| [`HIS_REPORT_TEMPLATE`](#his_report_template) | قوالب التقارير | Report Templates | C | INTERNAL |
| [`HIS_PRESCRIPTION`](#his_prescription) | الوصفات الطبية | Prescriptions | C | CONFIDENTIAL |
| [`HIS_PRESCRIPTION_LINE`](#his_prescription_line) | أصناف الوصفة | Prescription Lines | C | INTERNAL |
| [`HIS_BED`](#his_bed) | الأسرة | Beds | C | INTERNAL |
| [`HIS_ADMISSION`](#his_admission) | التنويم | Admissions | C | CONFIDENTIAL |
| [`HIS_BED_MOVE`](#his_bed_move) | حركات الأسرة | Bed Movements | C | INTERNAL |
| [`HIS_SURGERY`](#his_surgery) | جدول العمليات | Surgery Schedule | C | CONFIDENTIAL |
| [`HIS_THERAPY_PLAN`](#his_therapy_plan) | خطط العلاج والجلسات | Therapy Plans | C | INTERNAL |
| [`HIS_THERAPY_SESSION`](#his_therapy_session) | الجلسات المنفذة | Therapy Sessions | C | INTERNAL |
| [`HIS_DEVICE`](#his_device) | الأجهزة الطبية | Medical Devices | C | INTERNAL |
| [`HIS_DEVICE_LOG`](#his_device_log) | سجل صيانة ومعايرة الأجهزة | Device Service Log | C | INTERNAL |
| [`HIS_CLAIM_BATCH`](#his_claim_batch) | دفعات المطالبات | Claim Batches | C | INTERNAL |
| [`HIS_CLAIM_LINE`](#his_claim_line) | فواتير الدفعة | Claim Lines | C | INTERNAL |
| [`HIS_INTEGRATION`](#his_integration) | قنوات الربط الإلكتروني | Integration Channels | C | INTERNAL |
| [`HIS_LINK_MESSAGE`](#his_link_message) | رسائل الربط الإلكتروني | Integration Messages | C | CONFIDENTIAL |
| [`HIS_VITAL_SIGN`](#his_vital_sign) | العلامات الحيوية | Vital Signs | C | CONFIDENTIAL |
| [`HIS_CLINICAL_NOTE`](#his_clinical_note) | الملاحظات السريرية | Clinical Notes | C | CONFIDENTIAL |
| [`HIS_MED_ADMIN`](#his_med_admin) | سجل إعطاء الأدوية | Medication Administration Record | C | CONFIDENTIAL |
| [`HIS_CERTIFICATE`](#his_certificate) | التقارير الطبية والإجازات | Medical Certificates & Reports | C | CONFIDENTIAL |
| [`HIS_COMMISSION`](#his_commission) | تسويات عمولات الأطباء | Doctor Commission Settlements | C | INTERNAL |
| [`HIS_NURSE_SHIFT`](#his_nurse_shift) | ورديات التمريض | Nursing Shifts | C | INTERNAL |
| [`HIS_NURSE_ROSTER`](#his_nurse_roster) | جدول مناوبات التمريض | Nursing Duty Roster | C | INTERNAL |
| [`HIS_MED_SCHEDULE`](#his_med_schedule) | جدول جرعات المنومين | Inpatient Dose Schedule | C | CONFIDENTIAL |
| [`HIS_CARE_TASK`](#his_care_task) | مهام المتابعة التمريضية | Nursing Care Tasks | C | CONFIDENTIAL |
| [`HIS_CARE_LOG`](#his_care_log) | سجل تنفيذ مهام المتابعة | Care Task Log | C | CONFIDENTIAL |

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
| 16 | `INTEGRATION_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_INTEGRATION |  | إدخال المستخدم |  | قناة الربط الإلكتروني (الأهلية والموافقات والمطالبات) |
| 17 | `LINK_CODE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رمز الجهة لدى قناة الربط (Payer ID) |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, SUSPENDED, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

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
| 26 | `ELIGIBILITY_STATUS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | ELIGIBLE, NOT_ELIGIBLE, PENDING, ERROR | إدخال المستخدم |  | نتيجة التحقق من الأهلية |
| 27 | `ELIGIBILITY_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع التحقق لدى الجهة |
| 28 | `ELIGIBILITY_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التحقق |
| 29 | `TRIAGE_LEVEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | 1, 2, 3, 4, 5 | إدخال المستخدم |  | مستوى الفرز في الطوارئ (CTAS: 1 إنعاش ... 5 غير عاجل) |
| 30 | `TRIAGE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الفرز |
| 31 | `TRIAGE_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | منفذ الفرز |
| 32 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, CLOSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 33 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 34 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 35 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 36 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 37 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

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
| مفاتيح فريدة | UK2: (VISIT_ID, LINE_NO) |
| قيود أعمال | QUANTITY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT UK2 |  | إدخال المستخدم |  | الزيارة |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
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
| 32 | `PREAUTH_STATUS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | REQUESTED, PENDING, APPROVED, REJECTED, ERROR | إدخال المستخدم |  | حالة طلب الموافقة الإلكتروني |
| 33 | `PREAUTH_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع طلب الموافقة لدى الجهة |
| 34 | `COMMISSION_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_COMMISSION |  | إدخال المستخدم |  | تسوية عمولة الطبيب |
| 35 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ORDERED' |  | ORDERED, APPROVAL_PENDING, IN_PROGRESS, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 36 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 37 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 38 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 39 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 40 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_LAB_PARAM

| البند | القيمة |
|---|---|
| الاسم العربي | مكونات التحاليل والمعدلات |
| English | Lab Test Parameters |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SERVICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_SERVICE |  | إدخال المستخدم |  | التحليل |
| 5 | `CODE` | نص | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | رمز المكون (WBC، HB...) |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | اسم المكون |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | Parameter name (English) |
| 8 | `UNIT` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوحدة |
| 9 | `GENDER` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | M, F | إدخال المستخدم |  | للجنس (فارغ = الكل) |
| 10 | `AGE_FROM` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | من عمر (سنة) |
| 11 | `AGE_TO` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | إلى عمر (سنة) |
| 12 | `REF_LOW` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الحد الأدنى الطبيعي |
| 13 | `REF_HIGH` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الحد الأعلى الطبيعي |
| 14 | `CRIT_LOW` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | حرج أقل من |
| 15 | `CRIT_HIGH` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | حرج أعلى من |
| 16 | `REF_TEXT` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعدل الطبيعي نصاً (للنتائج الوصفية) |
| 17 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_LAB_RESULT

| البند | القيمة |
|---|---|
| الاسم العربي | نتائج مكونات التحاليل |
| English | Lab Results |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (ORDER_ID, PARAM_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ORDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_ORDER UK1 |  | إدخال المستخدم |  | الطلب |
| 5 | `PARAM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_LAB_PARAM UK1 |  | إدخال المستخدم |  | المكون |
| 6 | `VALUE_NUM` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | القيمة الرقمية |
| 7 | `VALUE_TEXT` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | القيمة الوصفية |
| 8 | `FLAG` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | N, L, H, LL, HH | إدخال المستخدم |  | التقييم (طبيعي، منخفض، مرتفع، حرج) |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_REPORT_TEMPLATE

| البند | القيمة |
|---|---|
| الاسم العربي | قوالب التقارير |
| English | Report Templates |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `SERVICE_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_SERVICE |  | إدخال المستخدم |  | الخدمة |
| 8 | `MODALITY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجهاز (لكل خدمات الجهاز) |
| 9 | `BODY` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | نص القالب |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_PRESCRIPTION

| البند | القيمة |
|---|---|
| الاسم العربي | الوصفات الطبية |
| English | Prescriptions |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, RX_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RX_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الوصفة |
| 5 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 6 | `DOCTOR_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الطبيب |
| 7 | `PHARMACY_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | الصيدلية |
| 8 | `RX_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | الوقت |
| 9 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 10 | `EXPIRES_ON` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | صلاحية الوصفة للصرف |
| 11 | `ERX_NO` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الوصفة في منصة الوصفات الإلكترونية |
| 12 | `ERX_STATUS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | SENT, ACCEPTED, REJECTED, ERROR, CANCELLED | إدخال المستخدم |  | حالة الإرسال للمنصة |
| 13 | `CLOSE_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإقفال دون صرف (صرف خارجي، لم يستلم) |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, PARTIAL, DISPENSED, EXTERNAL, EXPIRED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_PRESCRIPTION_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أصناف الوصفة |
| English | Prescription Lines |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PRESCRIPTION_ID, LINE_NO) |
| قيود أعمال | QUANTITY > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PRESCRIPTION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PRESCRIPTION UK2 |  | إدخال المستخدم |  | الوصفة |
| 5 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | السطر |
| 6 | `ITEM_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→INV_ITEM |  | إدخال المستخدم |  | الدواء |
| 7 | `DOSE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجرعة |
| 8 | `FREQUENCY` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | التكرار (مرتين يومياً...) |
| 9 | `DURATION_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | المدة بالأيام |
| 10 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية المطلوبة |
| 11 | `DISPENSED_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الكمية المصروفة |
| 12 | `INSTRUCTIONS` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | تعليمات الاستعمال |
| 13 | `ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_ORDER |  | إدخال المستخدم |  | طلب الفوترة |
| 14 | `ROUTE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | ORAL, IV, IM, SC, INHALED, TOPICAL, RECTAL, OTHER | إدخال المستخدم |  | طريقة الإعطاء |
| 15 | `DOSE_TIMES` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | أوقات الجرعات المحددة (08:00,20:00) بدل أوقات التكرار القياسية |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_BED

| البند | القيمة |
|---|---|
| الاسم العربي | الأسرة |
| English | Beds |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, BED_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `WARD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | الجناح |
| 5 | `BED_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم السرير |
| 6 | `ROOM_NO` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الغرفة |
| 7 | `BED_CLASS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'WARD' |  | WARD, SEMI_PRIVATE, PRIVATE, SUITE, ICU, NICU, ISOLATION | إدخال المستخدم |  | الفئة |
| 8 | `DAY_SERVICE_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_SERVICE |  | إدخال المستخدم |  | خدمة يوم السرير |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'AVAILABLE' |  | AVAILABLE, OCCUPIED, CLEANING, BLOCKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_ADMISSION

| البند | القيمة |
|---|---|
| الاسم العربي | التنويم |
| English | Admissions |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, VISIT_ID)<br>UK3: (TENANT_ID, COMPANY_ID, ADMISSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ADMISSION_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم التنويم |
| 5 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT UK2 |  | إدخال المستخدم |  | الزيارة |
| 6 | `BED_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_BED |  | إدخال المستخدم |  | السرير الحالي |
| 7 | `DOCTOR_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الطبيب المعالج |
| 8 | `ADMIT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الدخول |
| 9 | `DISCHARGE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الخروج |
| 10 | `CHARGED_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | آخر يوم محمل |
| 11 | `ADMIT_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب التنويم |
| 12 | `DISCHARGE_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | HOME, TRANSFER, AGAINST_ADVICE, DECEASED | إدخال المستخدم |  | نوع الخروج |
| 13 | `DISCHARGE_SUMMARY` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملخص الخروج |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ADMITTED' |  | ADMITTED, DISCHARGED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_BED_MOVE

| البند | القيمة |
|---|---|
| الاسم العربي | حركات الأسرة |
| English | Bed Movements |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `ADMISSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_ADMISSION |  | إدخال المستخدم |  | التنويم |
| 5 | `FROM_BED_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_BED |  | إدخال المستخدم |  | من سرير |
| 6 | `TO_BED_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_BED |  | إدخال المستخدم |  | إلى سرير |
| 7 | `MOVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الوقت |
| 8 | `REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## HIS_SURGERY

| البند | القيمة |
|---|---|
| الاسم العربي | جدول العمليات |
| English | Surgery Schedule |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 5 | `ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_ORDER |  | إدخال المستخدم |  | طلب العملية |
| 6 | `SERVICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_SERVICE |  | إدخال المستخدم |  | العملية |
| 7 | `THEATER` | نص | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | غرفة العمليات |
| 8 | `SURGEON_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الجراح |
| 9 | `ANESTHETIST_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | طبيب التخدير |
| 10 | `ANESTHESIA` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | GENERAL, SPINAL, LOCAL, SEDATION | إدخال المستخدم |  | نوع التخدير |
| 11 | `START_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية المجدولة |
| 12 | `DURATION_MIN` | عدد صحيح | `NUMBER(10)` | ✔ | 60 |  |  | إدخال المستخدم |  | المدة بالدقائق |
| 13 | `ACTUAL_START` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية الفعلية |
| 14 | `ACTUAL_END` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية الفعلية |
| 15 | `OPERATIVE_NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | تقرير العملية |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SCHEDULED' |  | SCHEDULED, IN_PROGRESS, DONE, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_THERAPY_PLAN

| البند | القيمة |
|---|---|
| الاسم العربي | خطط العلاج والجلسات |
| English | Therapy Plans |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | SESSIONS_TOTAL > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 5 | `SERVICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_SERVICE |  | إدخال المستخدم |  | الجلسة |
| 6 | `ORDER_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_ORDER |  | إدخال المستخدم |  | طلب الفوترة |
| 7 | `THERAPIST_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | المعالج |
| 8 | `SESSIONS_TOTAL` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | عدد الجلسات |
| 9 | `SESSIONS_DONE` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | المنفذ |
| 10 | `FREQUENCY` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | التكرار (3 أسبوعياً...) |
| 11 | `GOALS` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الأهداف |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_THERAPY_SESSION

| البند | القيمة |
|---|---|
| الاسم العربي | الجلسات المنفذة |
| English | Therapy Sessions |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| مفاتيح فريدة | UK1: (PLAN_ID, SESSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PLAN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_THERAPY_PLAN UK1 |  | إدخال المستخدم |  | الخطة |
| 5 | `SESSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الجلسة |
| 6 | `SESSION_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الوقت |
| 7 | `THERAPIST_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | المعالج |
| 8 | `NOTES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الملاحظات والتقدم |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## HIS_DEVICE

| البند | القيمة |
|---|---|
| الاسم العربي | الأجهزة الطبية |
| English | Medical Devices |
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
| 8 | `MODALITY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجهاز (أشعة، رنين، تحاليل...) |
| 9 | `MANUFACTURER` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الشركة المصنعة |
| 10 | `MODEL` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الطراز |
| 11 | `SERIAL_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرقم التسلسلي |
| 12 | `FA_ASSET_ID` | معرف | `NUMBER(19)` |  |  | FK→FA_ASSET |  | إدخال المستخدم |  | الأصل الثابت |
| 13 | `INSTALLED_ON` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التركيب |
| 14 | `WARRANTY_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | نهاية الضمان |
| 15 | `CALIBRATION_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | دورية المعايرة بالأيام |
| 16 | `LAST_CALIBRATION` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | آخر معايرة |
| 17 | `NEXT_CALIBRATION` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | المعايرة القادمة |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'IN_SERVICE' |  | IN_SERVICE, OUT_OF_SERVICE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_DEVICE_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل صيانة ومعايرة الأجهزة |
| English | Device Service Log |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DEVICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DEVICE |  | إدخال المستخدم |  | الجهاز |
| 5 | `LOG_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CALIBRATION, PREVENTIVE, REPAIR, BREAKDOWN, RETURN_TO_SERVICE | إدخال المستخدم |  | النوع |
| 6 | `LOG_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ |
| 7 | `VENDOR` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجهة المنفذة |
| 8 | `COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة |
| 9 | `NOTES` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الملاحظات |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## HIS_CLAIM_BATCH

| البند | القيمة |
|---|---|
| الاسم العربي | دفعات المطالبات |
| English | Claim Batches |
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
| 5 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 6 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 7 | `PAYER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PAYER |  | إدخال المستخدم |  | الجهة |
| 8 | `PERIOD_FROM` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | من |
| 9 | `PERIOD_TO` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | إلى |
| 10 | `CLAIMED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المطالب به |
| 11 | `APPROVED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المقبول |
| 12 | `REJECTED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرفوض |
| 13 | `SUBMITTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الإرسال |
| 14 | `REFERENCE_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم الإرسال لدى الجهة |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, PARTIAL, SETTLED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 17 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 18 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_CLAIM_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | فواتير الدفعة |
| English | Claim Lines |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (BATCH_ID, INVOICE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BATCH_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_CLAIM_BATCH UK1 |  | إدخال المستخدم |  | الدفعة |
| 5 | `INVOICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_INVOICE UK1 |  | إدخال المستخدم |  | الفاتورة |
| 6 | `CLAIMED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المطالب به |
| 7 | `APPROVED_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المقبول |
| 8 | `REJECTED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المرفوض |
| 9 | `REJECT_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الرفض |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_INTEGRATION

| البند | القيمة |
|---|---|
| الاسم العربي | قنوات الربط الإلكتروني |
| English | Integration Channels |
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
| 7 | `KIND` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INSURANCE, ERX | إدخال المستخدم |  | النوع (تأمين: أهلية وموافقات ومطالبات، أو منصة وصفات إلكترونية) |
| 8 | `LINK_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SIMULATOR' |  | SIMULATOR, REST, EMAIL | إدخال المستخدم |  | طريقة الربط (محاكاة للتجربة، REST، بريد) |
| 9 | `BASE_URL` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | عنوان الخدمة (REST) |
| 10 | `AUTH_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NONE' |  | NONE, BASIC, BEARER, API_KEY | إدخال المستخدم |  | المصادقة |
| 11 | `USERNAME` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المستخدم أو معرف العميل |
| 12 | `SECRET_ENC` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | كلمة المرور أو المفتاح (مشفرة) |
| 13 | `KEY_HEADER` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | اسم ترويسة المفتاح (API_KEY) |
| 14 | `PROVIDER_CODE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رمز المنشأة لدى القناة (Provider ID / ترخيص) |
| 15 | `EMAIL` | نص | `VARCHAR2(320 CHAR)` |  |  |  |  | إدخال المستخدم |  | البريد (طريقة البريد) |
| 16 | `TIMEOUT_SEC` | عدد صحيح | `NUMBER(10)` | ✔ | 30 |  |  | إدخال المستخدم |  | مهلة الاتصال بالثواني |
| 17 | `WALLET_PATH` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | مسار محفظة الشهادات (HTTPS) إن لم تكن محفظة APEX |
| 18 | `LAST_OK_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر اتصال ناجح |
| 19 | `LAST_ERROR` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | آخر خطأ |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_LINK_MESSAGE

| البند | القيمة |
|---|---|
| الاسم العربي | رسائل الربط الإلكتروني |
| English | Integration Messages |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, MSG_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `MSG_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم الرسالة |
| 5 | `MSG_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ELIGIBILITY, PREAUTH, PREAUTH_STATUS, CLAIM, CLAIM_STATUS, PRESCRIPTION, PRESCRIPTION_CANCEL, PING | إدخال المستخدم |  | النوع |
| 6 | `INTEGRATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_INTEGRATION |  | إدخال المستخدم |  | القناة |
| 7 | `PAYER_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_PAYER |  | إدخال المستخدم |  | الجهة |
| 8 | `ENTITY_TYPE` | نص | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الكيان (زيارة، طلب، دفعة، وصفة) |
| 9 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف الكيان |
| 10 | `SENT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإرسال |
| 11 | `HTTP_STATUS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | رمز الاستجابة |
| 12 | `ATTEMPTS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحاولات |
| 13 | `EXTERNAL_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع لدى الجهة |
| 14 | `OUTCOME` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخلاصة |
| 15 | `REQUEST_BODY` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | الطلب |
| 16 | `RESPONSE_BODY` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | الاستجابة |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'QUEUED' |  | QUEUED, SENT, ACCEPTED, PENDING, REJECTED, ERROR | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_VITAL_SIGN

| البند | القيمة |
|---|---|
| الاسم العربي | العلامات الحيوية |
| English | Vital Signs |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 5 | `TAKEN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | الوقت |
| 6 | `BP_SYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الضغط الانقباضي |
| 7 | `BP_DIA` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الضغط الانبساطي |
| 8 | `PULSE` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | النبض |
| 9 | `TEMPERATURE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الحرارة |
| 10 | `RESP_RATE` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | التنفس |
| 11 | `SPO2` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | تشبع الأكسجين |
| 12 | `WEIGHT` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الوزن (كجم) |
| 13 | `HEIGHT` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الطول (سم) |
| 14 | `PAIN_SCORE` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الألم (0-10) |
| 15 | `GLUCOSE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | سكر الدم |
| 16 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## HIS_CLINICAL_NOTE

| البند | القيمة |
|---|---|
| الاسم العربي | الملاحظات السريرية |
| English | Clinical Notes |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 5 | `NOTE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | NURSING, PROGRESS, CONSULTATION, PROCEDURE, DISCHARGE | إدخال المستخدم |  | النوع |
| 6 | `NOTE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | الوقت |
| 7 | `AUTHOR_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الكاتب (طبيب أو ممرض) |
| 8 | `NOTE_TEXT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الملاحظة (English) |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## HIS_MED_ADMIN

| البند | القيمة |
|---|---|
| الاسم العربي | سجل إعطاء الأدوية |
| English | Medication Administration Record |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 5 | `LINE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PRESCRIPTION_LINE |  | إدخال المستخدم |  | الدواء الموصوف |
| 6 | `GIVEN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | الوقت |
| 7 | `DOSE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجرعة المعطاة |
| 8 | `ROUTE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ORAL' |  | ORAL, IV, IM, SC, INHALED, TOPICAL, RECTAL, OTHER | إدخال المستخدم |  | طريقة الإعطاء |
| 9 | `OUTCOME` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GIVEN' |  | GIVEN, HELD, REFUSED, MISSED | إدخال المستخدم |  | النتيجة |
| 10 | `NURSE_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الممرض |
| 11 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## HIS_CERTIFICATE

| البند | القيمة |
|---|---|
| الاسم العربي | التقارير الطبية والإجازات |
| English | Medical Certificates & Reports |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PUBLIC_ID)<br>UK2: (TENANT_ID, COMPANY_ID, CERT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK1 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `CERT_NO` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرقم |
| 6 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 7 | `CERT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SICK_LEAVE, MEDICAL_REPORT, REFERRAL, FITNESS, COMPANION | إدخال المستخدم |  | النوع |
| 8 | `ISSUED_ON` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ الإصدار |
| 9 | `FROM_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | من |
| 10 | `TO_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | إلى |
| 11 | `DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الأيام |
| 12 | `REFERRAL_TO` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | جهة التحويل |
| 13 | `BODY` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النص (English) |
| 14 | `DOCTOR_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الطبيب |
| 15 | `VERIFY_CODE` | نص | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | رمز التحقق |
| 16 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ISSUED' |  | ISSUED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_COMMISSION

| البند | القيمة |
|---|---|
| الاسم العربي | تسويات عمولات الأطباء |
| English | Doctor Commission Settlements |
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
| 5 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 6 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 7 | `DOCTOR_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الطبيب |
| 8 | `PERIOD_FROM` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | من |
| 9 | `PERIOD_TO` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | إلى |
| 10 | `BASE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الإيراد الأساس (صافي الخدمات المفوترة) |
| 11 | `COMMISSION_PCT` | نسبة | `NUMBER(9,6)` | ✔ |  |  |  | إدخال المستخدم |  | النسبة |
| 12 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | العمولة |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'POSTED' |  | POSTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 15 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 16 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_NURSE_SHIFT

| البند | القيمة |
|---|---|
| الاسم العربي | ورديات التمريض |
| English | Nursing Shifts |
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
| 7 | `START_TIME` | نص | `VARCHAR2(5 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | البداية (HH24:MI) |
| 8 | `END_TIME` | نص | `VARCHAR2(5 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النهاية (تتجاوز منتصف الليل إن كانت أصغر) |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_NURSE_ROSTER

| البند | القيمة |
|---|---|
| الاسم العربي | جدول مناوبات التمريض |
| English | Nursing Duty Roster |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, DUTY_DATE, SHIFT_ID, NURSE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DUTY_DATE` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | تاريخ الوردية (تاريخ بدايتها) |
| 5 | `SHIFT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_NURSE_SHIFT UK1 |  | إدخال المستخدم |  | الوردية |
| 6 | `WARD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DEPARTMENT |  | إدخال المستخدم |  | الجناح أو القسم |
| 7 | `NURSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_DOCTOR UK1 |  | إدخال المستخدم |  | الممرض |
| 8 | `DUTY_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'STAFF' |  | CHARGE, STAFF, ASSISTANT | إدخال المستخدم |  | الدور (مسؤول الوردية، ممرض، مساعد) |
| 9 | `ROOMS` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الغرف المسندة (فارغ = كل الجناح) |
| 10 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_MED_SCHEDULE

| البند | القيمة |
|---|---|
| الاسم العربي | جدول جرعات المنومين |
| English | Inpatient Dose Schedule |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (LINE_ID, DUE_AT) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 5 | `LINE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_PRESCRIPTION_LINE UK1 |  | إدخال المستخدم |  | الدواء الموصوف |
| 6 | `DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  | UK1 |  | إدخال المستخدم |  | موعد الجرعة |
| 7 | `DOSE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجرعة |
| 8 | `ROUTE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | طريقة الإعطاء |
| 9 | `ADMIN_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_MED_ADMIN |  | إدخال المستخدم |  | سجل الإعطاء |
| 10 | `DONE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التنفيذ |
| 11 | `NURSE_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | الممرض المنفذ |
| 12 | `ALERT_LEVEL` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | التنبيه المرسل (0 لا، 1 حان الموعد، 2 متأخرة) |
| 13 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DUE' |  | DUE, GIVEN, HELD, REFUSED, MISSED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_CARE_TASK

| البند | القيمة |
|---|---|
| الاسم العربي | مهام المتابعة التمريضية |
| English | Nursing Care Tasks |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EVERY_HOURS > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 5 | `TASK_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | VITALS, BLOOD_SUGAR, TURNING, WOUND_CARE, INTAKE_OUTPUT, DOCTOR_ROUND, OBSERVATION, OTHER | إدخال المستخدم |  | النوع |
| 6 | `DESCRIPTION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف (English) |
| 7 | `EVERY_HOURS` | رقم | `NUMBER` | ✔ |  |  |  | إدخال المستخدم |  | التكرار بالساعات |
| 8 | `NEXT_DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الموعد القادم |
| 9 | `END_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | حتى |
| 10 | `LAST_DONE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر تنفيذ |
| 11 | `ALERT_LEVEL` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | التنبيه المرسل للموعد القادم |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, STOPPED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## HIS_CARE_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل تنفيذ مهام المتابعة |
| English | Care Task Log |
| الحزمة المالكة | 31 — `NOONA_HIS_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `TASK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_CARE_TASK |  | إدخال المستخدم |  | المهمة |
| 5 | `VISIT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HIS_VISIT |  | إدخال المستخدم |  | الزيارة |
| 6 | `DONE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | الوقت |
| 7 | `NURSE_ID` | معرف | `NUMBER(19)` |  |  | FK→HIS_DOCTOR |  | إدخال المستخدم |  | المنفذ |
| 8 | `RESULT_VALUE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | القيمة (مثل: سكر 140، المدخلات 500 مل) |
| 9 | `NOTES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

