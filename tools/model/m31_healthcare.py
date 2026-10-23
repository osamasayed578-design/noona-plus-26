from model.dsl import module, table

module(31, 'HIS', 'المستشفيات والمراكز الطبية', 'Hospital & Clinics', 'NOONA_HIS_PKG',
       'الأقسام والعيادات والمعامل والأشعة والصيدليات الداخلية والوحدات العلاجية كأقسام مستقلة بمستودعاتها ومراكز تكلفتها، '
       'الأطباء وساعات العمل، دليل الخدمات الطبية ومواد كل فحص، شركات التأمين والجهات المتعاقدة بفئاتها وأسعارها، '
       'المرضى والحجوزات والزيارات والطلبات الطبية ونتائجها، والفواتير بحصة المريض وحصة الجهة والقيد المحاسبي.')

# =============================================================== الهيكل الطبي
table('HIS_DEPARTMENT', 'الأقسام الطبية', 'Medical Departments', scope='C', mix='code names status', status='ACTIVE INACTIVE', cols='''
DEPT_TYPE       CODE NN IN:CLINIC,EMERGENCY,LAB,RADIOLOGY,CARDIO_DIAG,PHARMACY,INPATIENT_WARD,OPERATING_THEATER,PHYSIOTHERAPY,THERAPY_UNIT,DENTAL,DIALYSIS,NURSING,OTHER | النوع
SPECIALTY       V100             | التخصص (باطنة، أطفال، كيمياء حيوية، أمراض دم...)
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع القسم (مواد المعمل، الصيدلية الداخلية)
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
REVENUE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الإيراد (فارغ = حسب نوع الخدمة)
PHONE           V30              | الهاتف الداخلي
LOCATION_TEXT   V200             | الموقع (الدور، الجناح)
SORT_ORDER      INT  NN D=0      | الترتيب
''', area='setup', purpose='كل معمل (كيمياء، دم، أحياء دقيقة، أنسجة) وكل وحدة أشعة وصيدلية داخلية قسم مستقل بمستودعه ومركز تكلفته')

table('HIS_SERVICE', 'دليل الخدمات الطبية', 'Medical Services Catalogue', scope='C', mix='code names status', status='ACTIVE INACTIVE', cols='''
SERVICE_TYPE    CODE NN IN:CONSULTATION,FOLLOW_UP,EMERGENCY,LAB,RADIOLOGY,CARDIO_DIAG,PROCEDURE,MINOR_SURGERY,MAJOR_SURGERY,PHYSIOTHERAPY,THERAPY,NURSING,DENTAL,BED,MEDICATION,PACKAGE,OTHER | نوع الخدمة
MODALITY        CODE IN:XRAY,CT,MRI,ULTRASOUND,DOPPLER,MAMMOGRAPHY,FLUOROSCOPY,DEXA,NUCLEAR,PET,ECG,ECHO,STRESS_TEST,HOLTER,EEG,EMG,ENDOSCOPY | جهاز الأشعة/التشخيص
DEPARTMENT_ID   ID   >HIS_DEPARTMENT | القسم المنفذ
BILLING_CODE    V50              | رمز الفوترة (CPT / SBS)
PRICE           AMT  NN D=0      | السعر النقدي (قبل الضريبة)
DURATION_MIN    INT              | المدة بالدقائق
SAMPLE_TYPE     CODE IN:BLOOD,SERUM,PLASMA,URINE,STOOL,SWAB,CSF,TISSUE,SPUTUM,OTHER | نوع العينة (للمعامل)
TURNAROUND_HOURS INT             | زمن ظهور النتيجة بالساعات
NORMAL_RANGE    V500             | المعدل الطبيعي والوحدة (للمعامل)
NEEDS_APPROVAL  YN   NN D='N'    | يحتاج موافقة مسبقة من التأمين
ITEM_ID         ID   >INV_ITEM   | صنف الدواء/المستلزم (للصرف من الصيدلية)
''', ix=[('TENANT_ID', 'SERVICE_TYPE')], area='setup')

table('HIS_SERVICE_MATERIAL', 'مواد الخدمة المستهلكة', 'Service Consumables', scope='C', cols='''
SERVICE_ID      ID   NN >HIS_SERVICE | الخدمة
ITEM_ID         ID   NN >INV_ITEM | المادة (كاشف، أنابيب، أفلام، مستلزمات)
QUANTITY        QTY  NN          | الكمية لكل خدمة
''', uk=[('SERVICE_ID', 'ITEM_ID')], chk=['QUANTITY > 0'], area='setup', purpose='مواد المعمل والأشعة والعمليات تصرف من مستودع القسم عند إنجاز الخدمة')

table('HIS_DOCTOR', 'الأطباء والممارسون', 'Doctors & Practitioners', scope='C', mix='code names status', status='ACTIVE ON_LEAVE INACTIVE', cols='''
DEPARTMENT_ID   ID   NN >HIS_DEPARTMENT | القسم
EMPLOYEE_ID     ID   >HR_EMPLOYEE | الموظف (للرواتب والدوام)
TITLE           CODE NN D='SPECIALIST' IN:CONSULTANT,SPECIALIST,RESIDENT,GP,DENTIST,SURGEON,ANESTHETIST,RADIOLOGIST,PATHOLOGIST,PHYSIOTHERAPIST,TECHNICIAN,NURSE,PHARMACIST | الدرجة/الوظيفة
SPECIALTY       V100             | التخصص
LICENSE_NO      V50              | رقم الترخيص المهني (الهيئة السعودية للتخصصات الصحية)
LICENSE_EXPIRY  DATE             | انتهاء الترخيص
MOBILE          V30  PII         | الجوال
CONSULT_SERVICE_ID ID >HIS_SERVICE | خدمة الكشف الافتراضية
COMMISSION_PCT  PCT              | نسبة الطبيب من الإيراد
USER_NAME       USR              | مستخدم الدخول (لقائمة مرضاه)
''', area='setup')

table('HIS_DOCTOR_SCHEDULE', 'ساعات عمل الأطباء', 'Doctor Working Hours', scope='C', mix='eff', cols='''
DOCTOR_ID       ID   NN >HIS_DOCTOR | الطبيب
WEEKDAY         INT  NN          | اليوم (1 الأحد ... 7 السبت)
FROM_TIME       V5   NN          | من (HH24:MI)
TO_TIME         V5   NN          | إلى (HH24:MI)
SLOT_MINUTES    INT  NN D=15     | مدة الموعد بالدقائق
DEPARTMENT_ID   ID   >HIS_DEPARTMENT | العيادة/القسم
ROOM            V50              | الغرفة
''', chk=['WEEKDAY BETWEEN 1 AND 7', 'TO_TIME > FROM_TIME'], ix=[('TENANT_ID', 'DOCTOR_ID', 'WEEKDAY')], area='setup')

# =============================================================== التأمين والجهات المتعاقدة
table('HIS_PAYER', 'شركات التأمين والجهات المتعاقدة', 'Insurers & Contracted Companies', scope='C', mix='code names status',
      status='ACTIVE SUSPENDED INACTIVE', cols='''
PAYER_TYPE      CODE NN IN:INSURANCE,TPA,CORPORATE,GOVERNMENT,CHARITY | النوع
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | حساب الذمة (المطالبات)
DISCOUNT_PCT    PCT              | الخصم العام على الأسعار النقدية
CLAIM_DAYS      INT              | مهلة سداد المطالبات بالأيام
CONTRACT_NO     V50              | رقم العقد
CONTRACT_FROM   DATE             | بداية العقد
CONTRACT_TO     DATE             | نهاية العقد
PHONE           V30              | الهاتف
EMAIL           V320             | البريد
''', area='payer')

table('HIS_PAYER_PLAN', 'فئات التغطية', 'Coverage Plans / Classes', scope='C', mix='code names active', codeuk=False, cols='''
PAYER_ID        ID   NN >HIS_PAYER | الجهة
PATIENT_SHARE_PCT PCT NN D=0     | نسبة تحمل المريض
MAX_PATIENT_SHARE AMT            | الحد الأعلى لتحمل المريض في الزيارة
APPROVAL_LIMIT  AMT              | الخدمة التي تتجاوز هذا المبلغ تحتاج موافقة
EXCLUDED_TYPES  V500             | أنواع خدمات غير مغطاة (مفصولة بفواصل)
ANNUAL_LIMIT    AMT              | الحد السنوي للمستفيد
''', uk=[('PAYER_ID', 'CODE')], area='payer')

table('HIS_PAYER_PRICE', 'أسعار العقود', 'Contract Prices', scope='C', cols='''
PAYER_ID        ID   NN >HIS_PAYER | الجهة
SERVICE_ID      ID   NN >HIS_SERVICE | الخدمة
PRICE           AMT              | سعر العقد (فارغ = السعر النقدي بعد الخصم العام)
IS_COVERED      YN   NN D='Y'    | مغطاة
NEEDS_APPROVAL  YN   NN D='N'    | تحتاج موافقة
''', uk=[('PAYER_ID', 'SERVICE_ID')], area='payer')

# =============================================================== المرضى والمواعيد والزيارات
table('HIS_PATIENT', 'المرضى', 'Patients', scope='C', mix='pub status', status='ACTIVE INACTIVE DECEASED MERGED', cols='''
MRN             V30  NN          | الرقم الطبي
NAME_AR         NAME NN PII      | الاسم
NAME_EN         NAME PII         | الاسم بالإنجليزية
GENDER          CODE NN IN:M,F   | الجنس
BIRTH_DATE      DATE PII         | تاريخ الميلاد
ID_TYPE         CODE IN:NATIONAL_ID,IQAMA,PASSPORT,BORDER_NO,BIRTH_CERT | نوع الهوية
ID_NO           V30  PII         | رقم الهوية
NATIONALITY     CTRY             | الجنسية (السعودي معفى من ضريبة الخدمات الصحية)
MOBILE          V30  PII         | الجوال
BLOOD_GROUP     V5               | فصيلة الدم
ALLERGIES       V1000            | الحساسية
CHRONIC_DISEASES V1000           | الأمراض المزمنة
PAYER_PLAN_ID   ID   >HIS_PAYER_PLAN | التأمين/الجهة وفئة التغطية
MEMBER_NO       V50              | رقم العضوية
POLICY_NO       V50              | رقم الوثيقة
INSURANCE_EXPIRY DATE            | انتهاء التأمين
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | حساب المريض (المتبقي عليه)
ADDRESS         V500 PII         | العنوان
EMERGENCY_CONTACT V200 PII       | جهة الاتصال للطوارئ
''', uk=[('TENANT_ID', 'COMPANY_ID', 'MRN')], ix=[('TENANT_ID', 'ID_NO'), ('TENANT_ID', 'MOBILE')], area='patient', sens='CONFIDENTIAL')

table('HIS_APPOINTMENT', 'المواعيد والحجوزات', 'Appointments', scope='C', mix='status',
      status='BOOKED CONFIRMED ARRIVED COMPLETED NO_SHOW CANCELLED', cols='''
APPT_NO         V30  NN          | رقم الحجز
PATIENT_ID      ID   NN >HIS_PATIENT | المريض
DOCTOR_ID       ID   >HIS_DOCTOR | الطبيب
DEPARTMENT_ID   ID   NN >HIS_DEPARTMENT | العيادة/القسم
SERVICE_ID      ID   >HIS_SERVICE | الخدمة (كشف، أشعة، جلسة...)
APPT_DATE       DATE NN          | التاريخ
START_TIME      V5   NN          | الوقت
END_TIME        V5               | النهاية
CHANNEL         CODE NN D='PHONE' IN:WALK_IN,PHONE,WEB,APP,REFERRAL | القناة
VISIT_ID        ID               | الزيارة الناتجة
CANCEL_REASON   V500             | سبب الإلغاء
NOTES           V500             | ملاحظات
''', uk=[('TENANT_ID', 'COMPANY_ID', 'APPT_NO')], ix=[('TENANT_ID', 'DOCTOR_ID', 'APPT_DATE'), ('TENANT_ID', 'DEPARTMENT_ID', 'APPT_DATE')], area='visit')

table('HIS_VISIT', 'الزيارات', 'Visits / Encounters', scope='C', mix='pub branch status', status='OPEN CLOSED CANCELLED', cols='''
VISIT_NO        V30  NN          | رقم الزيارة
VISIT_TYPE      CODE NN D='OUTPATIENT' IN:OUTPATIENT,EMERGENCY,INPATIENT,DAY_CASE,REFERRAL_IN | النوع
PATIENT_ID      ID   NN >HIS_PATIENT | المريض
DEPARTMENT_ID   ID   NN >HIS_DEPARTMENT | القسم
DOCTOR_ID       ID   >HIS_DOCTOR | الطبيب المعالج
APPOINTMENT_ID  ID   >HIS_APPOINTMENT | الموعد
VISIT_AT        TS   NN D=SYSTIMESTAMP | وقت الزيارة
CLOSED_AT       TS               | وقت الإقفال
BILL_TO         CODE NN D='CASH' IN:CASH,PAYER | الدفع (نقدي أو جهة)
PAYER_PLAN_ID   ID   >HIS_PAYER_PLAN | فئة التغطية المثبتة للزيارة
APPROVAL_NO     V50              | رقم الموافقة
CHIEF_COMPLAINT V1000            | الشكوى
DIAGNOSIS       V1000            | التشخيص
ICD10           V100             | رمز التشخيص ICD-10
VITALS          V1000            | العلامات الحيوية
DOCTOR_NOTES    TXT              | ملاحظات الطبيب
GROSS_AMOUNT    AMT  NN D=0      | الإجمالي قبل الخصم
PATIENT_TOTAL   AMT  NN D=0      | المستحق على المريض (شامل الضريبة)
PAYER_TOTAL     AMT  NN D=0      | المستحق على الجهة (شامل الضريبة)
PAID_AMOUNT     AMT  NN D=0      | المدفوع من المريض
''', uk=[('TENANT_ID', 'COMPANY_ID', 'VISIT_NO')], ix=[('TENANT_ID', 'PATIENT_ID'), ('TENANT_ID', 'DEPARTMENT_ID', 'STATUS_CODE')], area='visit',
      sens='CONFIDENTIAL')

table('HIS_INVOICE', 'فواتير الزيارات', 'Visit Invoices', scope='C', mix='pub branch doc posted status', status='POSTED CANCELLED', cols='''
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
PATIENT_ID      ID   NN >HIS_PATIENT | المريض
PAYER_ID        ID   >HIS_PAYER  | الجهة
GROSS_AMOUNT    AMT  NN D=0      | الإجمالي قبل الخصم
DISCOUNT_AMOUNT AMT  NN D=0      | خصم العقد
PATIENT_NET     AMT  NN D=0      | حصة المريض قبل الضريبة
PATIENT_VAT     AMT  NN D=0      | ضريبة حصة المريض
PAYER_NET       AMT  NN D=0      | حصة الجهة قبل الضريبة
PAYER_VAT       AMT  NN D=0      | ضريبة حصة الجهة
PATIENT_TOTAL   AMT  NN D=0      | المطلوب من المريض
PAYER_TOTAL     AMT  NN D=0      | المطالبة على الجهة
PAID_AMOUNT     AMT  NN D=0      | المدفوع
PAYMENT_METHOD  CODE             | طريقة الدفع
PAYMENT_PLACE   V30              | الصندوق/البنك (BOX:n / BANK:n)
PAYMENT_REF     V100             | مرجع الدفع
CLAIM_STATUS    CODE NN D='NONE' IN:NONE,PENDING,SUBMITTED,PAID,PARTIAL,REJECTED | حالة المطالبة
''', area='billing')

table('HIS_ORDER', 'الطلبات والخدمات الطبية', 'Medical Orders', scope='C', mix='status',
      status='ORDERED APPROVAL_PENDING IN_PROGRESS COMPLETED CANCELLED', cols='''
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
LINE_NO         INT  NN          | السطر
SERVICE_ID      ID   NN >HIS_SERVICE | الخدمة
DEPARTMENT_ID   ID   NN >HIS_DEPARTMENT | القسم المنفذ (المعمل/الأشعة/العيادة)
QUANTITY        QTY  NN D=1      | الكمية
ORDERED_BY_ID   ID   >HIS_DOCTOR | الطبيب الطالب
PERFORMED_BY_ID ID   >HIS_DOCTOR | المنفذ
UNIT_PRICE      AMT  NN          | سعر الوحدة (نقدي أو سعر العقد)
GROSS_AMOUNT    AMT  NN          | الإجمالي
DISCOUNT_AMOUNT AMT  NN D=0      | خصم العقد
PATIENT_NET     AMT  NN D=0      | حصة المريض قبل الضريبة
PAYER_NET       AMT  NN D=0      | حصة الجهة قبل الضريبة
VAT_RATE        PCT  NN D=0      | نسبة الضريبة
PATIENT_VAT     AMT  NN D=0      | ضريبة حصة المريض
PAYER_VAT       AMT  NN D=0      | ضريبة حصة الجهة
COVERED         YN   NN D='N'    | مغطاة من الجهة
APPROVAL_NO     V50              | رقم موافقة التأمين
INVOICE_ID      ID   >HIS_INVOICE | الفاتورة
SAMPLE_NO       V30              | رقم العينة
SAMPLE_AT       TS               | وقت سحب العينة
STARTED_AT      TS               | بدء التنفيذ
COMPLETED_AT    TS               | الإنجاز
RESULT_TEXT     CLOB             | النتيجة / التقرير
RESULT_FLAG     CODE IN:NORMAL,ABNORMAL,CRITICAL | تقييم النتيجة
RESULT_BY       USR              | معتمد النتيجة
MATERIAL_TXN_ID ID   >INV_TRANSACTION | حركة صرف المواد
MATERIAL_COST   AMT              | تكلفة المواد
NOTES           V500             | ملاحظات الطلب
''', uk=[('VISIT_ID', 'LINE_NO')], chk=['QUANTITY > 0'], ix=[('TENANT_ID', 'DEPARTMENT_ID', 'STATUS_CODE')], area='visit', sens='CONFIDENTIAL')
