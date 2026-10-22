from model.dsl import module, table

module(19, 'HR', 'الموارد البشرية', 'Human Resources', 'NOONA_HR_PKG',
       'يفصل PERSON (Party) عن EMPLOYEE وعن EMPLOYMENT وعن ASSIGNMENT وعن المستخدم. يشمل العقود والحركات '
       'المؤرخة والتوظيف والدوام والإجازات والعمل الإضافي والتدريب والأداء والعهد ونهاية الخدمة، مع '
       'سرية مستقلة لبيانات الموظف عن المدير وHR والرواتب.')

table('HR_EMPLOYEE', 'الموظفون', 'Employees', scope='T', mix='pub status', status='CANDIDATE ACTIVE ON_LEAVE SUSPENDED TERMINATED RETIRED DECEASED', cols='''
PERSON_PARTY_ID ID   NN U >PTY_PARTY | الشخص
EMPLOYEE_NO     V50  NN U        | الرقم الوظيفي (لا يعاد استخدامه)
ORIGINAL_HIRE_DATE DATE          | تاريخ أول تعيين
WORK_EMAIL      V320 PII         | البريد الوظيفي
WORK_MOBILE     V40  PII         | جوال العمل
PHOTO_DOCUMENT_ID ID >DMS_DOCUMENT | الصورة
EMERGENCY_CONTACT JSON PII       | جهة اتصال الطوارئ
NATIONAL_ID     V30  PII         | رقم الهوية الوطنية / الإقامة
ID_EXPIRY_DATE  DATE             | انتهاء الهوية / الإقامة
NATIONALITY     CTRY             | الجنسية
GENDER          CODE IN:M,F      | الجنس
BIRTH_DATE      DATE PII         | تاريخ الميلاد
''', area='employee', sens='CONFIDENTIAL')

table('HR_EMPLOYMENT', 'علاقات التوظيف', 'Employments', scope='T', mix='status', status='PENDING ACTIVE SUSPENDED NOTICE_PERIOD TERMINATED', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
COMPANY_ID      ID   NN >ORG_COMPANY | الشركة الموظِّفة
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
EMPLOYMENT_TYPE CODE NN IN:PERMANENT,FIXED_TERM,PART_TIME,TEMPORARY,SECONDED_IN,INTERN,CONSULTANT | النوع
EMPLOYEE_CATEGORY CODE           | الفئة (مواطن، مقيم...)
START_DATE      DATE NN          | البداية
PROBATION_END_DATE DATE          | نهاية التجربة
END_DATE        DATE             | النهاية
TERMINATION_TYPE CODE IN:RESIGNATION,END_OF_CONTRACT,TERMINATION,RETIREMENT,DEATH,TRANSFER,OTHER | سبب الانتهاء
TERMINATION_REASON V1000         | التفاصيل
MANAGER_EMPLOYEE_ID ID >HR_EMPLOYEE | المدير المباشر
PAYROLL_GROUP_ID ID  >PAY_PAYROLL_GROUP | مجموعة الرواتب
WORK_SCHEDULE_ID ID  >HR_WORK_SCHEDULE | جدول الدوام
GOSI_NO         V50  PII         | رقم التأمينات الاجتماعية
JOB_TITLE       V200             | المسمى الوظيفي
ORG_UNIT_ID     ID   >ORG_UNIT   | الإدارة / القسم
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة (توزيع الرواتب)
BANK_ID         ID   >REF_BANK   | بنك الراتب
IBAN            V34  PII         | رقم الآيبان
ANNUAL_LEAVE_DAYS INT NN D=21    | الإجازة السنوية (21 يوماً، و30 بعد خمس سنوات)
''', ix=[('TENANT_ID', 'EMPLOYEE_ID'), ('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE')], area='employee',
      purpose='يمكن للشخص امتلاك تعيينات قانونية متعاقبة دون إعادة استخدام معرف')

table('HR_CONTRACT', 'عقود العمل', 'Employment Contracts', scope='T', mix='cur status', status='DRAFT APPROVED SIGNED ACTIVE RENEWED EXPIRED TERMINATED', cols='''
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
CONTRACT_NO     V50  NN          | رقم العقد
VERSION_NO      INT  NN D=1      | الإصدار
CONTRACT_TYPE   CODE NN IN:UNLIMITED,FIXED_TERM,PART_TIME,TEMPORARY | النوع
START_DATE      DATE NN          | البداية
END_DATE        DATE             | النهاية
WORKING_HOURS_WEEK QTY           | ساعات العمل الأسبوعية
BASIC_SALARY    AMT              | الراتب الأساسي المرجعي
ANNUAL_LEAVE_DAYS INT            | الإجازة السنوية التعاقدية
NOTICE_DAYS     INT              | مدة الإشعار
GOV_CONTRACT_REF V100            | التوثيق الحكومي (قوى/مدد)
SIGNED_DOCUMENT_ID ID >DMS_DOCUMENT | العقد الموقع
''', uk=[('TENANT_ID', 'CONTRACT_NO', 'VERSION_NO')], area='employee', sens='CONFIDENTIAL')

table('HR_EMPLOYEE_ACTION', 'الحركات الوظيفية', 'Employee Actions', scope='T', mix='doc wf status', docuk=False,
      status='DRAFT UNDER_REVIEW APPROVED SCHEDULED EFFECTIVE COMPLETED REJECTED CANCELLED', cols='''
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
ACTION_TYPE     CODE NN IN:HIRE,TRANSFER,PROMOTION,DEMOTION,GRADE_CHANGE,SALARY_CHANGE,POSITION_CHANGE,SECONDMENT,CONTRACT_CHANGE,SUSPENSION,REINSTATEMENT,TERMINATION,CORRECTION | النوع
EFFECTIVE_DATE  DATE NN          | تاريخ السريان
OLD_VALUES      JSON             | القيم السابقة
NEW_VALUES      JSON NN          | القيم الجديدة
IMPACT_ANALYSIS JSON             | الأثر على المنصب والتفويض والصلاحيات والرواتب
IS_RETROACTIVE  YN   NN D='N'    | بأثر رجعي (ينشئ تصحيحاً مؤرخاً)
REASON          V1000            | السبب
''', uk=[('TENANT_ID', 'DOC_NO')], ix=[('TENANT_ID', 'EMPLOYMENT_ID', 'EFFECTIVE_DATE')], area='movement',
      purpose='الأحداث المؤرخة التي يستهلكها Payroll ونظام الصلاحيات (Joiner-Mover-Leaver)')

table('HR_DEPENDENT', 'المعالون', 'Dependents', scope='T', mix='status', status='ACTIVE INACTIVE', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
PERSON_PARTY_ID ID   NN >PTY_PARTY | المعال
RELATIONSHIP    CODE NN IN:SPOUSE,SON,DAUGHTER,FATHER,MOTHER,OTHER | الصلة
IS_INSURED      YN   NN D='N'    | مشمول بالتأمين
IS_TICKET_ELIGIBLE YN NN D='N'   | يستحق تذكرة
''', area='employee', sens='HIGHLY_RESTRICTED')

table('HR_QUALIFICATION', 'المؤهلات والشهادات', 'Qualifications & Certifications', scope='T', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
QUAL_TYPE       CODE NN IN:DEGREE,DIPLOMA,CERTIFICATE,LICENSE,SKILL,LANGUAGE | النوع
TITLE           V500 NN          | المسمى
INSTITUTION     V500             | الجهة
OBTAINED_DATE   DATE             | التاريخ
EXPIRY_DATE     DATE             | الانتهاء
DOCUMENT_ID     ID   >DMS_DOCUMENT | الشهادة
''', area='employee')

table('HR_REQUISITION', 'طلبات التوظيف', 'Job Requisitions', scope='C', mix='doc wf status', status='DRAFT SUBMITTED APPROVED OPEN FILLED CANCELLED CLOSED', cols='''
POSITION_ID     ID   NN >ORG_POSITION | المنصب الشاغر
OPENINGS        INT  NN D=1      | العدد
JUSTIFICATION   V2000            | المبرر
TARGET_DATE     DATE             | التاريخ المستهدف
''', area='recruitment')

table('HR_APPLICANT', 'المتقدمون', 'Applicants', scope='C', mix='status', status='NEW SCREENING INTERVIEW OFFERED HIRED REJECTED WITHDRAWN', cols='''
REQUISITION_ID  ID   NN >HR_REQUISITION | الطلب
PERSON_PARTY_ID ID   NN >PTY_PARTY | الشخص
SOURCE_CODE     CODE             | المصدر
CV_DOCUMENT_ID  ID   >DMS_DOCUMENT | السيرة الذاتية
EVALUATION      JSON             | التقييمات
''', area='recruitment', sens='CONFIDENTIAL')

table('HR_OFFER', 'عروض التوظيف', 'Job Offers', scope='C', mix='cur wf status', status='DRAFT APPROVED SENT ACCEPTED DECLINED EXPIRED', cols='''
APPLICANT_ID    ID   NN >HR_APPLICANT | المتقدم
POSITION_ID     ID   NN >ORG_POSITION | المنصب
OFFERED_SALARY  AMT  NN          | الراتب المعروض
PACKAGE_DETAILS JSON             | البدلات والمزايا
START_DATE      DATE             | تاريخ المباشرة
EXPIRES_ON      DATE             | صلاحية العرض
EMPLOYMENT_ID   ID   >HR_EMPLOYMENT | التعيين الناتج
''', area='recruitment', sens='CONFIDENTIAL')

table('HR_SHIFT', 'الورديات', 'Shifts', scope='C', mix='code names active', cols='''
START_TIME      V5   NN          | البداية HH24:MI
END_TIME        V5   NN          | النهاية HH24:MI
BREAK_MINUTES   INT  NN D=0      | الاستراحة
CROSSES_MIDNIGHT YN  NN D='N'    | تمتد بعد منتصف الليل
GRACE_MINUTES   INT  NN D=0      | سماحية التأخير
''', area='time')

table('HR_WORK_SCHEDULE', 'جداول الدوام', 'Work Schedules', scope='C', mix='code names active', cols='''
CALENDAR_ID     ID   >WF_BUSINESS_CALENDAR | تقويم العطلات
PATTERN         JSON NN          | نمط الورديات لكل يوم
HOURS_PER_WEEK  QTY              | الساعات الأسبوعية
''', area='time')

table('HR_ATTENDANCE_DEVICE', 'أجهزة الحضور', 'Attendance Devices', scope='C', mix='code names branch status', status='ACTIVE INACTIVE', cols='''
SITE_ID         ID   >ORG_BUSINESS_SITE | الموقع
DEVICE_TYPE     CODE NN IN:BIOMETRIC,CARD,MOBILE_GEO,KIOSK | النوع
SERIAL_NO       V100             | الرقم التسلسلي
''', area='time')

table('HR_ATTENDANCE', 'سجلات الحضور', 'Attendance Records', scope='C', mix='status', status='RAW PROCESSED APPROVED EXCEPTION LOCKED', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
WORK_DATE       DATE NN          | تاريخ العمل
SHIFT_ID        ID   >HR_SHIFT   | الوردية
CHECK_IN_AT     TS               | الدخول
CHECK_OUT_AT    TS               | الخروج
SOURCE_CODE     CODE NN IN:DEVICE,MOBILE,MANUAL,IMPORT,CORRECTION | المصدر
DEVICE_ID       ID   >HR_ATTENDANCE_DEVICE | الجهاز
WORKED_MINUTES  INT  @CALC       | الدقائق الفعلية
LATE_MINUTES    INT  @CALC       | التأخير
EARLY_LEAVE_MINUTES INT @CALC    | الخروج المبكر
OVERTIME_MINUTES INT @CALC       | الإضافي
ABSENCE_TYPE    CODE             | نوع الغياب
CORRECTION_OF_ID ID  >HR_ATTENDANCE | السجل المصحح (لا يعدل المقفل بصمت)
''', uk=[('TENANT_ID', 'EMPLOYEE_ID', 'WORK_DATE', 'SOURCE_CODE', 'CHECK_IN_AT')],
      ix=[('TENANT_ID', 'COMPANY_ID', 'WORK_DATE')], area='time')

table('HR_LEAVE_TYPE', 'أنواع الإجازات', 'Leave Types', scope='TO', mix='code names active', cols='''
COUNTRY_CODE    CTRY             | الدولة
IS_PAID         YN   NN D='Y'    | مدفوعة
UNIT_CODE       CODE NN D='DAY' IN:DAY,HOUR | الوحدة (الاستئذان بالساعة)
ACCRUAL_RULE    JSON             | قاعدة الاستحقاق والترحيل
MAX_PER_YEAR    QTY              | الحد السنوي
REQUIRES_DOCUMENT YN NN D='N'    | يتطلب مستنداً (مرضية...)
IS_SENSITIVE    YN   NN D='N'    | سبب حساس (طبي) بخصوصية مقيدة
''', area='leave')

table('HR_LEAVE_BALANCE', 'أرصدة الإجازات', 'Leave Balances', scope='T', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
LEAVE_TYPE_ID   ID   NN >HR_LEAVE_TYPE | النوع
BALANCE_YEAR    INT  NN          | السنة
OPENING_BALANCE QTY  NN D=0      | الرصيد الافتتاحي/المرحل
ACCRUED         QTY  NN D=0      | المستحق
TAKEN           QTY  NN D=0      | المستخدم
ADJUSTED        QTY  NN D=0      | التسويات
ENCASHED        QTY  NN D=0      | المصروف نقداً
''', uk=[('TENANT_ID', 'EMPLOYEE_ID', 'LEAVE_TYPE_ID', 'BALANCE_YEAR')], area='leave')

table('HR_LEAVE_REQUEST', 'طلبات الإجازات', 'Leave Requests', scope='T', mix='doc wf status', docuk=False,
      status='DRAFT SUBMITTED APPROVED REJECTED CANCELLED TAKEN RETURNED_EARLY', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
LEAVE_TYPE_ID   ID   NN >HR_LEAVE_TYPE | النوع
START_DATE      DATE NN          | البداية
END_DATE        DATE NN          | النهاية
START_TIME      V5               | ساعة البداية (الاستئذان)
END_TIME        V5               | ساعة النهاية
DURATION        QTY  NN          | المدة بالوحدة
SUBSTITUTE_EMPLOYEE_ID ID >HR_EMPLOYEE | البديل (لا يمنح سلطة دون تفويض)
REASON          V1000            | السبب (مقيد الاطلاع)
SUPPORTING_DOCUMENT_ID ID >DMS_DOCUMENT | المستند
ACTUAL_RETURN_DATE DATE          | تاريخ المباشرة الفعلي
''', uk=[('TENANT_ID', 'DOC_NO')], chk=['END_DATE >= START_DATE'], ix=[('TENANT_ID', 'EMPLOYEE_ID', 'START_DATE')],
      area='leave')

table('HR_OVERTIME_REQUEST', 'طلبات العمل الإضافي', 'Overtime Requests', scope='C', mix='wf status', status='DRAFT SUBMITTED APPROVED REJECTED PAID', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
WORK_DATE       DATE NN          | التاريخ
PLANNED_HOURS   QTY  NN          | المخطط
ACTUAL_HOURS    QTY              | الفعلي
RATE_MULTIPLIER NUM  NN D=1.5    | معامل الأجر
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
REASON          V1000            | السبب
''', area='time')

table('HR_TRAINING_COURSE', 'الدورات التدريبية', 'Training Courses', scope='T', mix='code names active', cols='''
PROVIDER        V200             | الجهة المقدمة
DURATION_HOURS  QTY              | المدة
COST            AMT              | التكلفة
''', area='development')

table('HR_TRAINING_RECORD', 'سجل التدريب', 'Training Records', scope='T', mix='status', status='PLANNED ENROLLED COMPLETED FAILED CANCELLED', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
COURSE_ID       ID   NN >HR_TRAINING_COURSE | الدورة
START_DATE      DATE             | البداية
END_DATE        DATE             | النهاية
SCORE           NUM              | النتيجة
CERTIFICATE_DOCUMENT_ID ID >DMS_DOCUMENT | الشهادة
''', area='development')

table('HR_PERFORMANCE_CYCLE', 'دورات تقييم الأداء', 'Performance Cycles', scope='C', mix='code names status', status='PLANNED OPEN CALIBRATION CLOSED', cols='''
START_DATE      DATE NN          | البداية
END_DATE        DATE NN          | النهاية
TEMPLATE        JSON             | نموذج التقييم
''', area='development')

table('HR_PERFORMANCE_REVIEW', 'تقييمات الأداء', 'Performance Reviews', scope='C', mix='conf status', status='NOT_STARTED SELF_REVIEW MANAGER_REVIEW CALIBRATED ACKNOWLEDGED CLOSED', cols='''
CYCLE_ID        ID   NN >HR_PERFORMANCE_CYCLE | الدورة
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
REVIEWER_EMPLOYEE_ID ID >HR_EMPLOYEE | المقيم
OVERALL_RATING  NUM              | التقدير
GOALS_RESULT    JSON             | الأهداف والنتائج
COMMENTS        V4000            | الملاحظات
''', uk=[('CYCLE_ID', 'EMPLOYEE_ID')], area='development', sens='HIGHLY_RESTRICTED',
      purpose='لا تستخدم نتائج التقييم لتوسيع وصول AI أو التقارير دون سياسة واضحة')

table('HR_DISCIPLINARY_ACTION', 'الإجراءات التأديبية', 'Disciplinary Actions', scope='C', mix='doc wf conf status', status='DRAFT INVESTIGATION DECIDED APPEALED CLOSED', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
VIOLATION_CODE  CODE NN          | المخالفة
ACTION_CODE     CODE             | الجزاء
DEDUCTION_DAYS  QTY              | خصم بالأيام
DECISION_DOCUMENT_ID ID >DMS_DOCUMENT | القرار
''', area='relations', sens='HIGHLY_RESTRICTED')

table('HR_CUSTODY', 'العهد', 'Employee Custody Items', scope='C', mix='status', status='ASSIGNED RETURNED LOST DAMAGED', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
CUSTODY_TYPE    CODE NN IN:ASSET,ITEM,CASH_ADVANCE,CARD,KEY,VEHICLE,DOCUMENT | النوع
ASSET_ID        ID   >FA_ASSET   | الأصل
ITEM_ID         ID   >INV_ITEM   | الصنف
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
DESCRIPTION     V500             | الوصف
ASSIGNED_DATE   DATE NN          | تاريخ التسليم
RETURNED_DATE   DATE             | تاريخ الإرجاع
''', area='relations')

table('HR_END_OF_SERVICE', 'إنهاء الخدمة وإخلاء الطرف', 'End of Service & Clearance', scope='C', mix='doc wf status',
      status='INITIATED CLEARANCE_IN_PROGRESS SETTLEMENT_CALCULATED APPROVED PAID CLOSED', cols='''
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
LAST_WORKING_DATE DATE NN        | آخر يوم عمل
CLEARANCE_CHECKLIST JSON         | العهد والتفويضات والمهام والمستندات والصلاحيات
EOS_AMOUNT      AMT              | مكافأة نهاية الخدمة
LEAVE_ENCASHMENT AMT             | بدل الإجازات
DEDUCTIONS      AMT              | الخصومات (قروض/عهد)
NET_SETTLEMENT  AMT              | الصافي
PAYROLL_RUN_ID  ID   >PAY_RUN    | تشغيل التسوية النهائية
''', area='relations')
