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
INTEGRATION_ID  ID   >HIS_INTEGRATION | قناة الربط الإلكتروني (الأهلية والموافقات والمطالبات)
LINK_CODE       V100             | رمز الجهة لدى قناة الربط (Payer ID)
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
ELIGIBILITY_STATUS CODE IN:ELIGIBLE,NOT_ELIGIBLE,PENDING,ERROR | نتيجة التحقق من الأهلية
ELIGIBILITY_REF V100             | مرجع التحقق لدى الجهة
ELIGIBILITY_AT  TS               | وقت التحقق
TRIAGE_LEVEL    CODE IN:1,2,3,4,5 | مستوى الفرز في الطوارئ (CTAS: 1 إنعاش ... 5 غير عاجل)
TRIAGE_AT       TS               | وقت الفرز
TRIAGE_BY       USR              | منفذ الفرز
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
PREAUTH_STATUS  CODE IN:REQUESTED,PENDING,APPROVED,REJECTED,ERROR | حالة طلب الموافقة الإلكتروني
PREAUTH_REF     V100             | مرجع طلب الموافقة لدى الجهة
COMMISSION_ID   ID   >HIS_COMMISSION | تسوية عمولة الطبيب
''', uk=[('VISIT_ID', 'LINE_NO')], chk=['QUANTITY > 0'], ix=[('TENANT_ID', 'DEPARTMENT_ID', 'STATUS_CODE')], area='visit', sens='CONFIDENTIAL')

# =============================================================== المرحلة الثانية: المعامل التفصيلية وقوالب التقارير
table('HIS_LAB_PARAM', 'مكونات التحاليل والمعدلات', 'Lab Test Parameters', scope='C', mix='sort', cols='''
SERVICE_ID      ID   NN >HIS_SERVICE | التحليل
CODE            V30  NN          | رمز المكون (WBC، HB...)
NAME_AR         NAME NN          | اسم المكون
NAME_EN         NAME             | Parameter name (English)
UNIT            V30              | الوحدة
GENDER          CODE IN:M,F      | للجنس (فارغ = الكل)
AGE_FROM        NUM              | من عمر (سنة)
AGE_TO          NUM              | إلى عمر (سنة)
REF_LOW         NUM              | الحد الأدنى الطبيعي
REF_HIGH        NUM              | الحد الأعلى الطبيعي
CRIT_LOW        NUM              | حرج أقل من
CRIT_HIGH       NUM              | حرج أعلى من
REF_TEXT        V200             | المعدل الطبيعي نصاً (للنتائج الوصفية)
''', ix=[('TENANT_ID', 'SERVICE_ID')], area='lab')

table('HIS_LAB_RESULT', 'نتائج مكونات التحاليل', 'Lab Results', scope='C', cols='''
ORDER_ID        ID   NN >HIS_ORDER | الطلب
PARAM_ID        ID   NN >HIS_LAB_PARAM | المكون
VALUE_NUM       NUM              | القيمة الرقمية
VALUE_TEXT      V200             | القيمة الوصفية
FLAG            CODE IN:N,L,H,LL,HH | التقييم (طبيعي، منخفض، مرتفع، حرج)
''', uk=[('ORDER_ID', 'PARAM_ID')], area='lab', sens='CONFIDENTIAL')

table('HIS_REPORT_TEMPLATE', 'قوالب التقارير', 'Report Templates', scope='C', mix='code names active', cols='''
SERVICE_ID      ID   >HIS_SERVICE | الخدمة
MODALITY        CODE             | الجهاز (لكل خدمات الجهاز)
BODY            TXT  NN          | نص القالب
''', area='lab')

# =============================================================== الصيدلية الداخلية
table('HIS_PRESCRIPTION', 'الوصفات الطبية', 'Prescriptions', scope='C', mix='status', status='ACTIVE PARTIAL DISPENSED EXTERNAL EXPIRED CANCELLED', cols='''
RX_NO           V30  NN          | رقم الوصفة
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
DOCTOR_ID       ID   >HIS_DOCTOR | الطبيب
PHARMACY_ID     ID   >HIS_DEPARTMENT | الصيدلية
RX_AT           TS   NN D=SYSTIMESTAMP | الوقت
NOTES           V500             | ملاحظات
EXPIRES_ON      DATE             | صلاحية الوصفة للصرف
ERX_NO          V50              | رقم الوصفة في منصة الوصفات الإلكترونية
ERX_STATUS      CODE IN:SENT,ACCEPTED,REJECTED,ERROR,CANCELLED | حالة الإرسال للمنصة
CLOSE_REASON    V500             | سبب الإقفال دون صرف (صرف خارجي، لم يستلم)
''', uk=[('TENANT_ID', 'COMPANY_ID', 'RX_NO')], ix=[('TENANT_ID', 'VISIT_ID')], area='pharmacy', sens='CONFIDENTIAL')

table('HIS_PRESCRIPTION_LINE', 'أصناف الوصفة', 'Prescription Lines', scope='C', cols='''
PRESCRIPTION_ID ID   NN >HIS_PRESCRIPTION | الوصفة
LINE_NO         INT  NN          | السطر
ITEM_ID         ID   NN >INV_ITEM | الدواء
DOSE            V100             | الجرعة
FREQUENCY       V100             | التكرار (مرتين يومياً...)
DURATION_DAYS   INT              | المدة بالأيام
QUANTITY        QTY  NN          | الكمية المطلوبة
DISPENSED_QTY   QTY  NN D=0      | الكمية المصروفة
INSTRUCTIONS    V500             | تعليمات الاستعمال
ORDER_ID        ID   >HIS_ORDER  | طلب الفوترة
''', uk=[('PRESCRIPTION_ID', 'LINE_NO')], chk=['QUANTITY > 0'], area='pharmacy')

# =============================================================== التنويم
table('HIS_BED', 'الأسرة', 'Beds', scope='C', mix='status', status='AVAILABLE OCCUPIED CLEANING BLOCKED', cols='''
WARD_ID         ID   NN >HIS_DEPARTMENT | الجناح
BED_NO          V30  NN          | رقم السرير
ROOM_NO         V30              | الغرفة
BED_CLASS       CODE NN D='WARD' IN:WARD,SEMI_PRIVATE,PRIVATE,SUITE,ICU,NICU,ISOLATION | الفئة
DAY_SERVICE_ID  ID   >HIS_SERVICE | خدمة يوم السرير
''', uk=[('TENANT_ID', 'COMPANY_ID', 'BED_NO')], area='inpatient')

table('HIS_ADMISSION', 'التنويم', 'Admissions', scope='C', mix='status', status='ADMITTED DISCHARGED CANCELLED', cols='''
ADMISSION_NO    V30  NN          | رقم التنويم
VISIT_ID        ID   NN U >HIS_VISIT | الزيارة
BED_ID          ID   >HIS_BED    | السرير الحالي
DOCTOR_ID       ID   >HIS_DOCTOR | الطبيب المعالج
ADMIT_AT        TS   NN          | الدخول
DISCHARGE_AT    TS               | الخروج
CHARGED_TO      DATE             | آخر يوم محمل
ADMIT_REASON    V1000            | سبب التنويم
DISCHARGE_TYPE  CODE IN:HOME,TRANSFER,AGAINST_ADVICE,DECEASED | نوع الخروج
DISCHARGE_SUMMARY TXT            | ملخص الخروج
''', uk=[('TENANT_ID', 'COMPANY_ID', 'ADMISSION_NO')], area='inpatient', sens='CONFIDENTIAL')

table('HIS_BED_MOVE', 'حركات الأسرة', 'Bed Movements', scope='C', append=True, cols='''
ADMISSION_ID    ID   NN >HIS_ADMISSION | التنويم
FROM_BED_ID     ID   >HIS_BED    | من سرير
TO_BED_ID       ID   NN >HIS_BED | إلى سرير
MOVED_AT        TS   NN          | الوقت
REASON          V500             | السبب
''', area='inpatient')

# =============================================================== العمليات والعلاج الطبيعي
table('HIS_SURGERY', 'جدول العمليات', 'Surgery Schedule', scope='C', mix='status', status='SCHEDULED IN_PROGRESS DONE CANCELLED', cols='''
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
ORDER_ID        ID   >HIS_ORDER  | طلب العملية
SERVICE_ID      ID   NN >HIS_SERVICE | العملية
THEATER         V30  NN          | غرفة العمليات
SURGEON_ID      ID   NN >HIS_DOCTOR | الجراح
ANESTHETIST_ID  ID   >HIS_DOCTOR | طبيب التخدير
ANESTHESIA      CODE IN:GENERAL,SPINAL,LOCAL,SEDATION | نوع التخدير
START_AT        TS   NN          | البداية المجدولة
DURATION_MIN    INT  NN D=60     | المدة بالدقائق
ACTUAL_START    TS               | البداية الفعلية
ACTUAL_END      TS               | النهاية الفعلية
OPERATIVE_NOTES TXT              | تقرير العملية
''', ix=[('TENANT_ID', 'THEATER', 'START_AT'), ('TENANT_ID', 'SURGEON_ID', 'START_AT')], area='or', sens='CONFIDENTIAL')

table('HIS_THERAPY_PLAN', 'خطط العلاج والجلسات', 'Therapy Plans', scope='C', mix='status', status='ACTIVE COMPLETED CANCELLED', cols='''
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
SERVICE_ID      ID   NN >HIS_SERVICE | الجلسة
ORDER_ID        ID   >HIS_ORDER  | طلب الفوترة
THERAPIST_ID    ID   >HIS_DOCTOR | المعالج
SESSIONS_TOTAL  INT  NN          | عدد الجلسات
SESSIONS_DONE   INT  NN D=0      | المنفذ
FREQUENCY       V100             | التكرار (3 أسبوعياً...)
GOALS           V1000            | الأهداف
''', chk=['SESSIONS_TOTAL > 0'], area='therapy')

table('HIS_THERAPY_SESSION', 'الجلسات المنفذة', 'Therapy Sessions', scope='C', append=True, cols='''
PLAN_ID         ID   NN >HIS_THERAPY_PLAN | الخطة
SESSION_NO      INT  NN          | الجلسة
SESSION_AT      TS   NN          | الوقت
THERAPIST_ID    ID   >HIS_DOCTOR | المعالج
NOTES           V1000            | الملاحظات والتقدم
''', uk=[('PLAN_ID', 'SESSION_NO')], area='therapy')

# =============================================================== الأجهزة الطبية
table('HIS_DEVICE', 'الأجهزة الطبية', 'Medical Devices', scope='C', mix='code names status', status='IN_SERVICE OUT_OF_SERVICE RETIRED', cols='''
DEPARTMENT_ID   ID   NN >HIS_DEPARTMENT | القسم
MODALITY        CODE             | الجهاز (أشعة، رنين، تحاليل...)
MANUFACTURER    V100             | الشركة المصنعة
MODEL           V100             | الطراز
SERIAL_NO       V100             | الرقم التسلسلي
FA_ASSET_ID     ID   >FA_ASSET   | الأصل الثابت
INSTALLED_ON    DATE             | التركيب
WARRANTY_TO     DATE             | نهاية الضمان
CALIBRATION_DAYS INT             | دورية المعايرة بالأيام
LAST_CALIBRATION DATE            | آخر معايرة
NEXT_CALIBRATION DATE            | المعايرة القادمة
''', area='device')

table('HIS_DEVICE_LOG', 'سجل صيانة ومعايرة الأجهزة', 'Device Service Log', scope='C', append=True, cols='''
DEVICE_ID       ID   NN >HIS_DEVICE | الجهاز
LOG_TYPE        CODE NN IN:CALIBRATION,PREVENTIVE,REPAIR,BREAKDOWN,RETURN_TO_SERVICE | النوع
LOG_DATE        DATE NN          | التاريخ
VENDOR          V200             | الجهة المنفذة
COST            AMT              | التكلفة
NOTES           V1000            | الملاحظات
''', area='device')

# =============================================================== المطالبات
table('HIS_CLAIM_BATCH', 'دفعات المطالبات', 'Claim Batches', scope='C', mix='pub doc posted status', status='DRAFT SUBMITTED PARTIAL SETTLED CANCELLED', cols='''
PAYER_ID        ID   NN >HIS_PAYER | الجهة
PERIOD_FROM     DATE NN          | من
PERIOD_TO       DATE NN          | إلى
CLAIMED_AMOUNT  AMT  NN D=0      | المطالب به
APPROVED_AMOUNT AMT  NN D=0      | المقبول
REJECTED_AMOUNT AMT  NN D=0      | المرفوض
SUBMITTED_AT    TS               | الإرسال
REFERENCE_NO    V100             | رقم الإرسال لدى الجهة
''', area='claims')

table('HIS_CLAIM_LINE', 'فواتير الدفعة', 'Claim Lines', scope='C', cols='''
BATCH_ID        ID   NN >HIS_CLAIM_BATCH | الدفعة
INVOICE_ID      ID   NN >HIS_INVOICE | الفاتورة
CLAIMED_AMOUNT  AMT  NN          | المطالب به
APPROVED_AMOUNT AMT              | المقبول
REJECTED_AMOUNT AMT  NN D=0      | المرفوض
REJECT_REASON   V500             | سبب الرفض
''', uk=[('BATCH_ID', 'INVOICE_ID')], area='claims')

# =============================================================== المرحلة الثالثة: الربط الإلكتروني
table('HIS_INTEGRATION', 'قنوات الربط الإلكتروني', 'Integration Channels', scope='C', mix='code names status', status='ACTIVE INACTIVE', cols='''
KIND            CODE NN IN:INSURANCE,ERX | النوع (تأمين: أهلية وموافقات ومطالبات، أو منصة وصفات إلكترونية)
LINK_MODE       CODE NN D='SIMULATOR' IN:SIMULATOR,REST,EMAIL | طريقة الربط (محاكاة للتجربة، REST، بريد)
BASE_URL        V1000            | عنوان الخدمة (REST)
AUTH_TYPE       CODE NN D='NONE' IN:NONE,BASIC,BEARER,API_KEY | المصادقة
USERNAME        V200             | المستخدم أو معرف العميل
SECRET_ENC      V2000            | كلمة المرور أو المفتاح (مشفرة)
KEY_HEADER      V100             | اسم ترويسة المفتاح (API_KEY)
PROVIDER_CODE   V100             | رمز المنشأة لدى القناة (Provider ID / ترخيص)
EMAIL           V320             | البريد (طريقة البريد)
TIMEOUT_SEC     INT  NN D=30     | مهلة الاتصال بالثواني
WALLET_PATH     V500             | مسار محفظة الشهادات (HTTPS) إن لم تكن محفظة APEX
LAST_OK_AT      TS               | آخر اتصال ناجح
LAST_ERROR      V1000            | آخر خطأ
''', area='link')

table('HIS_LINK_MESSAGE', 'رسائل الربط الإلكتروني', 'Integration Messages', scope='C', mix='status',
      status='QUEUED SENT ACCEPTED PENDING REJECTED ERROR', cols='''
MSG_NO          V30  NN          | رقم الرسالة
MSG_TYPE        CODE NN IN:ELIGIBILITY,PREAUTH,PREAUTH_STATUS,CLAIM,CLAIM_STATUS,PRESCRIPTION,PRESCRIPTION_CANCEL,PING | النوع
INTEGRATION_ID  ID   NN >HIS_INTEGRATION | القناة
PAYER_ID        ID   >HIS_PAYER  | الجهة
ENTITY_TYPE     V30              | الكيان (زيارة، طلب، دفعة، وصفة)
ENTITY_ID       ID               | معرف الكيان
SENT_AT         TS               | وقت الإرسال
HTTP_STATUS     INT              | رمز الاستجابة
ATTEMPTS        INT  NN D=0      | المحاولات
EXTERNAL_REF    V100             | المرجع لدى الجهة
OUTCOME         V1000            | الخلاصة
REQUEST_BODY    CLOB             | الطلب
RESPONSE_BODY   CLOB             | الاستجابة
''', uk=[('TENANT_ID', 'COMPANY_ID', 'MSG_NO')], ix=[('TENANT_ID', 'ENTITY_TYPE', 'ENTITY_ID'), ('TENANT_ID', 'INTEGRATION_ID', 'STATUS_CODE')],
      area='link', sens='CONFIDENTIAL')

# =============================================================== التمريض والسجل السريري
table('HIS_VITAL_SIGN', 'العلامات الحيوية', 'Vital Signs', scope='C', append=True, cols='''
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
TAKEN_AT        TS   NN D=SYSTIMESTAMP | الوقت
BP_SYS          INT              | الضغط الانقباضي
BP_DIA          INT              | الضغط الانبساطي
PULSE           INT              | النبض
TEMPERATURE     NUM              | الحرارة
RESP_RATE       INT              | التنفس
SPO2            INT              | تشبع الأكسجين
WEIGHT          NUM              | الوزن (كجم)
HEIGHT          NUM              | الطول (سم)
PAIN_SCORE      INT              | الألم (0-10)
GLUCOSE         NUM              | سكر الدم
NOTES           V500             | ملاحظات
''', ix=[('TENANT_ID', 'VISIT_ID')], area='nursing', sens='CONFIDENTIAL')

table('HIS_CLINICAL_NOTE', 'الملاحظات السريرية', 'Clinical Notes', scope='C', append=True, cols='''
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
NOTE_TYPE       CODE NN IN:NURSING,PROGRESS,CONSULTATION,PROCEDURE,DISCHARGE | النوع
NOTE_AT         TS   NN D=SYSTIMESTAMP | الوقت
AUTHOR_ID       ID   >HIS_DOCTOR | الكاتب (طبيب أو ممرض)
NOTE_TEXT       TXT  NN          | الملاحظة (English)
''', ix=[('TENANT_ID', 'VISIT_ID')], area='nursing', sens='CONFIDENTIAL')

table('HIS_MED_ADMIN', 'سجل إعطاء الأدوية', 'Medication Administration Record', scope='C', append=True, cols='''
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
LINE_ID         ID   NN >HIS_PRESCRIPTION_LINE | الدواء الموصوف
GIVEN_AT        TS   NN D=SYSTIMESTAMP | الوقت
DOSE            V100             | الجرعة المعطاة
ROUTE           CODE NN D='ORAL' IN:ORAL,IV,IM,SC,INHALED,TOPICAL,RECTAL,OTHER | طريقة الإعطاء
OUTCOME         CODE NN D='GIVEN' IN:GIVEN,HELD,REFUSED,MISSED | النتيجة
NURSE_ID        ID   >HIS_DOCTOR | الممرض
NOTES           V500             | ملاحظات
''', ix=[('TENANT_ID', 'VISIT_ID')], area='nursing', sens='CONFIDENTIAL')

table('HIS_CERTIFICATE', 'التقارير الطبية والإجازات', 'Medical Certificates & Reports', scope='C', mix='pub status', status='ISSUED CANCELLED', cols='''
CERT_NO         V30  NN          | الرقم
VISIT_ID        ID   NN >HIS_VISIT | الزيارة
CERT_TYPE       CODE NN IN:SICK_LEAVE,MEDICAL_REPORT,REFERRAL,FITNESS,COMPANION | النوع
ISSUED_ON       DATE NN D=TRUNC(SYSDATE) | تاريخ الإصدار
FROM_DATE       DATE             | من
TO_DATE         DATE             | إلى
DAYS            INT              | الأيام
REFERRAL_TO     V200             | جهة التحويل
BODY            TXT              | النص (English)
DOCTOR_ID       ID   >HIS_DOCTOR | الطبيب
VERIFY_CODE     V30  NN          | رمز التحقق
''', uk=[('TENANT_ID', 'COMPANY_ID', 'CERT_NO')], ix=[('TENANT_ID', 'VISIT_ID')], area='nursing', sens='CONFIDENTIAL')

# =============================================================== عمولات الأطباء
table('HIS_COMMISSION', 'تسويات عمولات الأطباء', 'Doctor Commission Settlements', scope='C', mix='pub doc posted status', status='POSTED CANCELLED', cols='''
DOCTOR_ID       ID   NN >HIS_DOCTOR | الطبيب
PERIOD_FROM     DATE NN          | من
PERIOD_TO       DATE NN          | إلى
BASE_AMOUNT     AMT  NN          | الإيراد الأساس (صافي الخدمات المفوترة)
COMMISSION_PCT  PCT  NN          | النسبة
AMOUNT          AMT  NN          | العمولة
''', area='billing')
