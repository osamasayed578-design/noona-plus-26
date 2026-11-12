from model.dsl import module, table

module(20, 'PAY', 'الرواتب', 'Payroll', 'NOONA_PAYROLL_PKG',
       'سياسة رواتب مؤرخة حسب Country Pack، وعناصر الراتب وقواعدها بإصدارات (لا SQL حر)، ودورة التشغيل '
       'OPEN → INPUT_CUTOFF → CALCULATED → REVIEWED → APPROVED → PAYABLE → PAID → POSTED → CLOSED، والقروض '
       'والسلف وملفات البنك وقسائم الرواتب الآمنة وقيد الرواتب عبر المحرك المحاسبي.')

table('PAY_PAYROLL_GROUP', 'مجموعات الرواتب', 'Payroll Groups', scope='C', mix='code names active', cols='''
FREQUENCY       CODE NN D='MONTHLY' IN:MONTHLY,SEMI_MONTHLY,BIWEEKLY,WEEKLY | الدورية
CURRENCY_CODE   CUR  NN          | العملة
COUNTRY_PACK_ID ID   >LOC_COUNTRY_PACK | حزمة الدولة
CUTOFF_DAY      INT              | يوم إقفال المدخلات
PAY_DAY         INT              | يوم الصرف
BANK_ACCOUNT_ID ID   >CSH_BANK_ACCOUNT | حساب الصرف
''', area='setup')

table('PAY_PERIOD', 'فترات الرواتب', 'Payroll Periods', scope='C', mix='status', status='FUTURE OPEN CUTOFF CLOSED', cols='''
PAYROLL_GROUP_ID ID  NN >PAY_PAYROLL_GROUP | المجموعة
PERIOD_CODE     V20  NN          | الرمز
START_DATE      DATE NN          | البداية
END_DATE        DATE NN          | النهاية
CUTOFF_DATE     DATE             | إقفال المدخلات
PAY_DATE        DATE NN          | تاريخ الصرف
GL_PERIOD_ID    ID   >GL_PERIOD  | الفترة المحاسبية
''', uk=[('PAYROLL_GROUP_ID', 'PERIOD_CODE')], area='setup')

table('PAY_ELEMENT', 'عناصر الراتب', 'Pay Elements', scope='TO', mix='code names active sort', cols='''
COUNTRY_PACK_ID ID   >LOC_COUNTRY_PACK | حزمة الدولة
ELEMENT_TYPE    CODE NN IN:EARNING,DEDUCTION,EMPLOYER_CONTRIBUTION,EMPLOYEE_CONTRIBUTION,TAX,LOAN_REPAYMENT,INFORMATION,BENEFIT | النوع
CLASSIFICATION  CODE NN IN:BASE_SALARY,HOUSING,TRANSPORT,ALLOWANCE,OVERTIME,BONUS,COMMISSION,INSURANCE,SOCIAL_SECURITY,ABSENCE,PENALTY,ADVANCE,EOS,LEAVE_PAY,OTHER | التصنيف
IS_RECURRING    YN   NN D='Y'    | متكرر
IS_TAXABLE      YN   NN D='N'    | خاضع للضريبة
IS_PRORATED     YN   NN D='Y'    | يحتسب نسبياً عند منتصف الشهر
AFFECTS_EOS     YN   NN D='N'    | يدخل في أساس نهاية الخدمة
SHOW_ON_PAYSLIP YN   NN D='Y'    | يظهر في القسيمة
EXPENSE_ACCOUNT_ID ID >GL_ACCOUNT | حساب المصروف
LIABILITY_ACCOUNT_ID ID >GL_ACCOUNT | حساب الالتزام
''', area='setup')

table('PAY_ELEMENT_RULE', 'قواعد احتساب العناصر', 'Element Calculation Rules', scope='TO', mix='eff status', status='DRAFT APPROVED ACTIVE RETIRED', cols='''
ELEMENT_ID      ID   NN >PAY_ELEMENT | العنصر
VERSION_NO      INT  NN          | الإصدار (يثبت للنتيجة)
COMPANY_ID      ID   >ORG_COMPANY | الشركة
EMPLOYEE_CATEGORY CODE           | فئة الموظف
FORMULA_TYPE    CODE NN IN:FIXED,PCT_OF_ELEMENT,HOURLY,DAILY,TABLE,BRACKET,APPROVED_FUNCTION | نوع المعادلة
PARAMETERS      JSON             | المعاملات (النسب، الأساس، الحدود)
APPROVED_FUNCTION V128           | دالة PL/SQL معتمدة (لا صيغ SQL حرة)
MIN_AMOUNT      AMT              | الحد الأدنى
MAX_AMOUNT      AMT              | الحد الأعلى
COUNTRY_CODE    CTRY             | الدولة (القاعدة لكل شركات المؤسسة في هذه الدولة؛ فارغ = كل الدول)
IS_AUTO         YN   NN D='N'    | تطبق تلقائياً على كل موظفي النطاق (ما لم يحدد للموظف غيرها)
''', uk=[('ELEMENT_ID', 'VERSION_NO')], area='setup')

table('PAY_EMPLOYEE_ELEMENT', 'عناصر رواتب الموظفين', 'Employee Element Entries', scope='T', mix='eff', cols='''
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
ELEMENT_ID      ID   NN >PAY_ELEMENT | العنصر
AMOUNT          AMT              | المبلغ
PERCENTAGE      PCT              | النسبة
CALC_METHOD     CODE NN D='FIXED' IN:FIXED,PERCENT,POLICY,EXCLUDED | طريقة الاحتساب: مبلغ ثابت، نسبة، حسب سياسة الشركة، مستثنى
BASIS_CODE      CODE             | العنصر الأساس للنسبة (افتراضياً الأساسي BASIC)
SOURCE_ACTION_ID ID  >HR_EMPLOYEE_ACTION | الحركة المصدر
''', ix=[('TENANT_ID', 'EMPLOYMENT_ID')], area='employee', sens='HIGHLY_RESTRICTED')

table('PAY_EMPLOYEE_PAYMENT_METHOD', 'طرق صرف رواتب الموظفين', 'Employee Payment Methods', scope='T', mix='eff', cols='''
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
METHOD_CODE     CODE NN IN:BANK_TRANSFER,CASH,CHEQUE,WPS,PAYCARD | الطريقة
BANK_ACCOUNT_ID ID   >PTY_BANK_ACCOUNT | الحساب البنكي (Maker-Checker)
SPLIT_PCT       PCT  NN D=100    | نسبة التوزيع
''', area='employee', sens='HIGHLY_RESTRICTED')

table('PAY_INPUT', 'المدخلات المتغيرة', 'Variable Payroll Inputs', scope='C', mix='src status', status='PENDING VALIDATED APPLIED REJECTED', cols='''
PERIOD_ID       ID   NN >PAY_PERIOD | الفترة
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
ELEMENT_ID      ID   NN >PAY_ELEMENT | العنصر
QUANTITY        QTY              | الكمية (ساعات/أيام)
AMOUNT          AMT              | المبلغ
''', ix=[('TENANT_ID', 'PERIOD_ID', 'EMPLOYMENT_ID')], area='run')

table('PAY_RUN', 'تشغيلات الرواتب', 'Payroll Runs', scope='C', mix='pub wf posted status',
      status='OPEN INPUT_CUTOFF CALCULATED REVIEWED APPROVED PAYABLE PAID POSTED CLOSED FAILED REOPENED', cols='''
RUN_NO          V50  NN          | رقم التشغيل
PAYROLL_GROUP_ID ID  NN >PAY_PAYROLL_GROUP | المجموعة
PERIOD_ID       ID   NN >PAY_PERIOD | الفترة
RUN_TYPE        CODE NN D='REGULAR' IN:REGULAR,OFF_CYCLE,ADJUSTMENT,RETRO,FINAL_SETTLEMENT,BONUS | النوع
ADJUSTS_RUN_ID  ID   >PAY_RUN    | التشغيل المصحح (لا يمحى السابق)
EMPLOYEE_COUNT  INT              | عدد الموظفين
TOTAL_GROSS     AMT              | الإجمالي
TOTAL_DEDUCTIONS AMT             | الخصومات
TOTAL_NET       AMT              | الصافي
TOTAL_EMPLOYER_COST AMT          | تكلفة صاحب العمل
ANOMALY_REPORT  JSON             | الحالات الشاذة والمقارنة بالفترة السابقة
CALCULATED_AT   TS               | وقت الحساب
''', uk=[('TENANT_ID', 'COMPANY_ID', 'RUN_NO')], area='run', sens='HIGHLY_RESTRICTED')

table('PAY_RUN_EMPLOYEE', 'موظفو تشغيل الرواتب', 'Payroll Run Employees', scope='C', mix='status', status='INCLUDED CALCULATED ERROR EXCLUDED APPROVED PAID', cols='''
RUN_ID          ID   NN >PAY_RUN | التشغيل
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
PAYABLE_DAYS    QTY              | الأيام المستحقة
ABSENCE_DAYS    QTY              | أيام الغياب والإجازة غير المدفوعة
OVERTIME_HOURS  QTY              | ساعات العمل الإضافي
GROSS_AMOUNT    AMT  NN D=0      | الإجمالي
DEDUCTION_AMOUNT AMT NN D=0      | الخصومات
NET_AMOUNT      AMT  NN D=0      | الصافي
EMPLOYER_COST   AMT  NN D=0      | تكلفة صاحب العمل
COST_ALLOCATION JSON             | التوزيع على المشاريع ومراكز التكلفة
ERROR_MESSAGE   V1000            | الخطأ
''', uk=[('RUN_ID', 'EMPLOYMENT_ID')], area='run', sens='HIGHLY_RESTRICTED')

table('PAY_RUN_RESULT', 'نتائج عناصر الراتب', 'Payroll Run Results', scope='C', cols='''
RUN_EMPLOYEE_ID ID   NN >PAY_RUN_EMPLOYEE | الموظف في التشغيل
ELEMENT_ID      ID   NN >PAY_ELEMENT | العنصر
RULE_ID         ID   >PAY_ELEMENT_RULE | إصدار القاعدة المطبق
QUANTITY        QTY              | الكمية
RATE            RATE             | المعدل
AMOUNT          AMT  NN          | المبلغ
SOURCE_INFO     JSON             | مصدر المبلغ (حضور، إجازة، عقد)
''', ix=[('TENANT_ID', 'RUN_EMPLOYEE_ID')], area='run', sens='HIGHLY_RESTRICTED')

table('PAY_LOAN', 'القروض والسلف', 'Employee Loans & Advances', scope='C', mix='doc cur wf status',
      status='DRAFT APPROVED ACTIVE SUSPENDED SETTLED WRITTEN_OFF CANCELLED', cols='''
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
LOAN_TYPE       CODE NN IN:LOAN,SALARY_ADVANCE,HOUSING_ADVANCE,OTHER | النوع
PRINCIPAL_AMOUNT AMT NN          | أصل المبلغ
INSTALLMENT_AMOUNT AMT NN        | القسط
INSTALLMENTS_COUNT INT NN        | عدد الأقساط
START_PERIOD_ID ID   >PAY_PERIOD | فترة بدء الخصم
OUTSTANDING_BALANCE AMT NN D=0 @SYS | الرصيد القائم
CASH_TRANSACTION_ID ID >CSH_TRANSACTION | الصرف
''', area='loan', sens='CONFIDENTIAL')

table('PAY_LOAN_INSTALLMENT', 'أقساط القروض', 'Loan Installments', scope='C', mix='status', status='SCHEDULED DEDUCTED DEFERRED SETTLED', cols='''
LOAN_ID         ID   NN >PAY_LOAN | القرض
INSTALLMENT_NO  INT  NN          | الرقم
PERIOD_ID       ID   >PAY_PERIOD | الفترة
AMOUNT          AMT  NN          | المبلغ
DEDUCTED_AMOUNT AMT  NN D=0      | المخصوم فعلياً
RUN_RESULT_ID   ID   >PAY_RUN_RESULT | نتيجة الخصم
''', uk=[('LOAN_ID', 'INSTALLMENT_NO')], area='loan')

table('PAY_BANK_FILE', 'ملفات تحويل الرواتب', 'Payroll Bank Files', scope='C', mix='status',
      status='GENERATED APPROVED FILE_SENT PAYMENT_CONFIRMED PARTIALLY_RETURNED FAILED CANCELLED', cols='''
RUN_ID          ID   NN >PAY_RUN | التشغيل
BANK_ACCOUNT_ID ID   NN >CSH_BANK_ACCOUNT | حساب الصرف
FILE_FORMAT     CODE NN          | الصيغة (WPS/SIF...)
TOTAL_AMOUNT    AMT  NN          | الإجمالي (يطابق صافي التشغيل)
RECORD_COUNT    INT  NN          | عدد السجلات
FILE_HASH       HASH             | Hash الملف
FILE_DOCUMENT_ID ID  >DMS_DOCUMENT | الملف (سري)
SENT_AT         TS               | وقت الإرسال
CONFIRMED_AT    TS               | تأكيد البنك
''', area='payment', sens='HIGHLY_RESTRICTED', purpose='يفصل FILE_SENT عن PAYMENT_CONFIRMED ويمنع الدفع المكرر')

table('PAY_BANK_FILE_LINE', 'أسطر ملف التحويل', 'Bank File Lines', scope='C', mix='status', status='PENDING PAID RETURNED REISSUED', cols='''
BANK_FILE_ID    ID   NN >PAY_BANK_FILE | الملف
RUN_EMPLOYEE_ID ID   NN >PAY_RUN_EMPLOYEE | الموظف
BANK_ACCOUNT_ID ID   >PTY_BANK_ACCOUNT | الحساب المستخدم
AMOUNT          AMT  NN          | المبلغ
RETURN_REASON   V500             | سبب الرد
''', area='payment', sens='HIGHLY_RESTRICTED')

table('PAY_PAYSLIP', 'قسائم الرواتب', 'Payslips', scope='C', mix='status', status='GENERATED PUBLISHED VIEWED', cols='''
RUN_EMPLOYEE_ID ID   NN U >PAY_RUN_EMPLOYEE | الموظف في التشغيل
DOCUMENT_ID     ID   >DMS_DOCUMENT | القسيمة (سرية عالية)
PUBLISHED_AT    TS               | النشر للموظف
VIEWED_AT       TS               | أول اطلاع
''', area='payment', sens='HIGHLY_RESTRICTED')

table('PAY_ACCRUAL', 'المخصصات والاستحقاقات', 'Payroll Accruals (EOS, Leave, Tickets)', scope='C', mix='posted', cols='''
PERIOD_ID       ID   NN >PAY_PERIOD | الفترة
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
ACCRUAL_TYPE    CODE NN IN:END_OF_SERVICE,LEAVE_PAY,AIR_TICKET,BONUS | النوع
OPENING_BALANCE AMT  NN D=0      | الرصيد السابق
PERIOD_AMOUNT   AMT  NN          | مخصص الفترة
CLOSING_BALANCE AMT  NN          | الرصيد
CALC_INFO       JSON             | أساس الحساب
''', uk=[('PERIOD_ID', 'EMPLOYMENT_ID', 'ACCRUAL_TYPE')], area='accrual', sens='HIGHLY_RESTRICTED')

table('PAY_FIELD_EARNING', 'مستحقات العاملين الميدانيين', 'Field Worker Earnings', scope='C', mix='src notes status',
      status='PENDING APPROVED IN_PAYROLL IN_VOUCHER PAID CANCELLED', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
EMPLOYMENT_ID   ID   >HR_EMPLOYMENT | علاقة التوظيف
SOURCE_MODULE   CODE NN IN:TRN,DST,AUT,OTHER | المصدر
EARNING_TYPE    CODE NN IN:TRIP_ALLOWANCE,SALES_COMMISSION,COLLECTION_COMMISSION,VISIT_COMMISSION,SERVICE_COMMISSION,BONUS,OTHER | النوع
PERIOD_MONTH    DATE NN          | الشهر
SOURCE_REF      V200             | المرجع (الرحلة، الشهر، أمر الإصلاح)
BASE_AMOUNT     AMT              | الأساس (مبيعات، تحصيل، خدمات)
AMOUNT          AMT  NN          | المستحق
PAY_METHOD      CODE NN D='PAYROLL' IN:PAYROLL,CASH,BANK_TRANSFER | طريقة الصرف
PAY_INPUT_ID    ID   >PAY_INPUT  | المدخل في مسير الرواتب
CASH_TXN_ID     ID   >CSH_TRANSACTION | سند الصرف
PAID_AT         TS               | وقت الصرف
APPROVED_BY     USR              | المعتمد
APPROVED_AT     TS               | وقت الاعتماد
''', uk=[('TENANT_ID', 'COMPANY_ID', 'SOURCE_ENTITY_TYPE', 'SOURCE_ENTITY_ID', 'EARNING_TYPE', 'PERIOD_MONTH')],
      ix=[('TENANT_ID', 'COMPANY_ID', 'PERIOD_MONTH', 'STATUS_CODE'), ('TENANT_ID', 'EMPLOYEE_ID')], chk=['AMOUNT > 0'], area='run')
