from model.dsl import module, table

module(7, 'GL', 'المحاسبة العامة والمحرك المحاسبي', 'General Ledger & Accounting Engine', 'NOONA_GL_PKG',
       'الدفاتر ودليل الحسابات الهرمي والتقويم المالي والفترات وحالتها حسب الوحدة، والقيود والأرصدة '
       'والأبعاد ومراكز التكلفة والموازنات والتجميع؛ والمحرك المحاسبي المركزي (NOONA_POSTING_PKG): '
       'Business Transaction → Accounting Event → Posting Rule → Journal → GL مع Idempotency ومنع الازدواج.')

MODULES_PERIOD = 'GL,AR,AP,INV,SALES,PURCHASE,CASH,FA,PAYROLL,PROJECT,REAL_ESTATE,LEASING,MFG'

# =============================================================== Ledgers & chart of accounts
table('GL_CHART_OF_ACCOUNTS', 'أدلة الحسابات', 'Charts of Accounts', scope='T', mix='code names status', status='DRAFT ACTIVE LOCKED RETIRED', cols='''
OWNER_LEVEL     CODE NN D='COMPANY' IN:TENANT,BUSINESS_GROUP,COMPANY | مستوى الملكية
BUSINESS_GROUP_ID ID >ORG_BUSINESS_GROUP | المجموعة
COMPANY_ID      ID   >ORG_COMPANY | الشركة
IS_TEMPLATE     YN   NN D='N'    | قالب
SOURCE_TEMPLATE_ID ID >GL_CHART_OF_ACCOUNTS | القالب المصدر
SEGMENT_SEPARATOR V1 D='-'       | فاصل المقاطع
''', area='coa')

table('GL_ACCOUNT', 'الحسابات', 'GL Accounts', scope='T', mix='names eff status', status='ACTIVE BLOCKED RETIRED', cols='''
COA_ID          ID   NN >GL_CHART_OF_ACCOUNTS | دليل الحسابات
ACCOUNT_CODE    V50  NN          | رقم الحساب
PARENT_ACCOUNT_ID ID >GL_ACCOUNT | الحساب الأب
ACCOUNT_LEVEL   INT  NN D=1      | المستوى
ACCOUNT_TYPE    CODE NN IN:ASSET,LIABILITY,EQUITY,REVENUE,EXPENSE,STATISTICAL | النوع
NORMAL_BALANCE  CODE NN IN:DEBIT,CREDIT | الطبيعة
IS_POSTABLE     YN   NN D='Y'    | قابل للترحيل (لا ترحيل على حساب عنوان)
IS_CONTROL      YN   NN D='N'    | حساب رقابي لدفتر فرعي
SUBLEDGER_CODE  CODE IN:AR,AP,INV,FA,CASH,PAYROLL,TAX,INTERCOMPANY,PROJECT | الدفتر الفرعي
ALLOW_MANUAL_POSTING YN NN D='Y' | يسمح بالقيد اليدوي (يمنع على الحسابات الرقابية)
CURRENCY_RESTRICTION CUR         | عملة مقيدة
REVALUE_FX      YN   NN D='N'    | يعاد تقييمه بالعملة الأجنبية
CASH_FLOW_CATEGORY CODE IN:OPERATING,INVESTING,FINANCING,CASH,NONE | تصنيف التدفق النقدي
''', uk=[('TENANT_ID', 'COA_ID', 'ACCOUNT_CODE')], chk=['PARENT_ACCOUNT_ID IS NULL OR PARENT_ACCOUNT_ID <> ID'],
      ix=[('TENANT_ID', 'PARENT_ACCOUNT_ID')], area='coa')

table('GL_FISCAL_CALENDAR', 'التقويمات المالية', 'Fiscal Calendars', scope='C', mix='code names active', cols='''
PERIOD_PATTERN  CODE NN D='MONTHLY_12' IN:MONTHLY_12,PERIODS_13,PATTERN_445,PATTERN_454,PATTERN_544,WEEKLY,CUSTOM | نمط الفترات
ADJUSTMENT_PERIODS INT NN D=1    | عدد فترات التسوية
''', area='calendar')

table('GL_LEDGER', 'الدفاتر', 'Ledgers', scope='C', mix='code names status', status='DRAFT ACTIVE CLOSED', cols='''
LEDGER_TYPE     CODE NN D='PRIMARY' IN:PRIMARY,SECONDARY,TAX,IFRS,LOCAL_GAAP,CONSOLIDATION | النوع
COA_ID          ID   NN >GL_CHART_OF_ACCOUNTS | دليل الحسابات
CALENDAR_ID     ID   NN >GL_FISCAL_CALENDAR | التقويم
CURRENCY_CODE   CUR  NN          | العملة الوظيفية للدفتر
RETAINED_EARNINGS_ACCOUNT_ID ID >GL_ACCOUNT | حساب الأرباح المحتجزة
ROUNDING_ACCOUNT_ID ID >GL_ACCOUNT | حساب فروق التقريب
SUSPENSE_ACCOUNT_ID ID >GL_ACCOUNT | الحساب المعلق
FX_GAIN_ACCOUNT_ID ID >GL_ACCOUNT | أرباح العملة المحققة
FX_LOSS_ACCOUNT_ID ID >GL_ACCOUNT | خسائر العملة المحققة
UNREALIZED_FX_ACCOUNT_ID ID >GL_ACCOUNT | فروق التقييم غير المحققة
''', area='ledger')

table('GL_FISCAL_YEAR', 'السنوات المالية', 'Fiscal Years', scope='C', mix='code names status', status='FUTURE OPEN CLOSING CLOSED PERMANENTLY_CLOSED', codeuk=False, cols='''
CALENDAR_ID     ID   NN >GL_FISCAL_CALENDAR | التقويم
START_DATE      DATE NN          | البداية
END_DATE        DATE NN          | النهاية
IS_SHORT_YEAR   YN   NN D='N'    | سنة قصيرة/انتقالية
PREVIOUS_YEAR_ID ID  >GL_FISCAL_YEAR | السنة السابقة
''', uk=[('TENANT_ID', 'CALENDAR_ID', 'CODE')], chk=['END_DATE > START_DATE'], area='calendar')

table('GL_PERIOD', 'الفترات المالية', 'Accounting Periods', scope='C', mix='names', cols='''
FISCAL_YEAR_ID  ID   NN >GL_FISCAL_YEAR | السنة
PERIOD_NO       INT  NN          | رقم الفترة
PERIOD_CODE     V20  NN          | الرمز (2026-01)
PERIOD_TYPE     CODE NN D='NORMAL' IN:OPENING,NORMAL,ADJUSTMENT,CLOSING | النوع
START_DATE      DATE NN          | البداية
END_DATE        DATE NN          | النهاية
''', uk=[('FISCAL_YEAR_ID', 'PERIOD_NO'), ('TENANT_ID', 'COMPANY_ID', 'PERIOD_CODE')], chk=['END_DATE >= START_DATE'],
      area='calendar')

table('GL_PERIOD_STATUS', 'حالة الفترة حسب الوحدة', 'Period Status by Module', scope='C', mix='status',
      status='FUTURE OPEN SOFT_CLOSED HARD_CLOSED PERMANENTLY_CLOSED', cols=f'''
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
LEDGER_ID       ID   NN >GL_LEDGER | الدفتر
MODULE_CODE     CODE NN IN:{MODULES_PERIOD} | الوحدة
CLOSED_BY       USR              | من أغلق
CLOSED_AT       TS               | وقت الإغلاق
CLOSE_SNAPSHOT_ID ID >GL_CLOSE_SNAPSHOT | لقطة الإغلاق
''', uk=[('PERIOD_ID', 'LEDGER_ID', 'MODULE_CODE')], area='calendar',
      purpose='SOFT_CLOSED يعاد فتحه بصلاحية؛ HARD_CLOSED باعتماد أعلى؛ PERMANENTLY_CLOSED يصحح بقيود لاحقة')

table('GL_PERIOD_REOPEN', 'طلبات إعادة فتح الفترة', 'Period Reopen Requests', scope='C', mix='wf status',
      status='DRAFT SUBMITTED APPROVED REOPENED RECLOSED REJECTED', cols=f'''
PERIOD_STATUS_ID ID  NN >GL_PERIOD_STATUS | الفترة/الوحدة
MODULE_CODE     CODE NN IN:{MODULES_PERIOD} | الوحدة
REASON          V4000 NN         | السبب الإلزامي
REOPEN_UNTIL    TS   NN          | المدة
ALLOWED_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المستخدم المسموح
BEFORE_SNAPSHOT JSON             | الأرصدة قبل
AFTER_SNAPSHOT  JSON             | الأرصدة بعد
''', area='calendar')

# =============================================================== Dimensions & cost centers
table('GL_COST_CENTER', 'مراكز التكلفة والربحية', 'Cost & Profit Centers', scope='C', mix='code names eff status', status='ACTIVE BLOCKED CLOSED', cols='''
CENTER_TYPE     CODE NN D='COST' IN:COST,PROFIT,REVENUE,INVESTMENT | النوع
PARENT_CENTER_ID ID  >GL_COST_CENTER | المركز الأب
MANAGER_POSITION_ID ID >ORG_POSITION | منصب المسؤول
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
''', chk=['PARENT_CENTER_ID IS NULL OR PARENT_CENTER_ID <> ID'], area='dimension')

table('GL_DIMENSION', 'الأبعاد المحاسبية', 'Accounting Dimensions', scope='T', mix='code names active sort', cols='''
DIMENSION_KIND  CODE NN IN:SYSTEM,CUSTOM | نظامي أو مخصص
SLOT_NO         INT              | رقم الخانة في سطر القيد (DIM1..DIM5) للأبعاد المخصصة
SOURCE_ENTITY_TYPE V50 >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | مصدر القيم للأبعاد النظامية
''', area='dimension')

table('GL_DIMENSION_VALUE', 'قيم الأبعاد المخصصة', 'Dimension Values', scope='T', mix='code names eff active', codeuk=False, cols='''
DIMENSION_ID    ID   NN >GL_DIMENSION | البعد
COMPANY_ID      ID   >ORG_COMPANY | الشركة
PARENT_VALUE_ID ID   >GL_DIMENSION_VALUE | القيمة الأم
''', uk=[('TENANT_ID', 'DIMENSION_ID', 'CODE')], area='dimension')

table('GL_ACCOUNT_DIM_RULE', 'قواعد الأبعاد للحسابات', 'Account Dimension Rules', scope='T', mix='eff', cols='''
ACCOUNT_ID      ID   NN >GL_ACCOUNT | الحساب
DIMENSION_ID    ID   NN >GL_DIMENSION | البعد
RULE_CODE       CODE NN IN:REQUIRED,OPTIONAL,FORBIDDEN | القاعدة
''', uk=[('ACCOUNT_ID', 'DIMENSION_ID', 'EFFECTIVE_FROM')], area='dimension')

# =============================================================== Journals & balances
table('GL_JOURNAL_SOURCE', 'مصادر القيود', 'Journal Sources', scope='TO', mix='code names active', cols='''
MODULE_CODE     CODE NN          | الحزمة
ALLOW_MANUAL    YN   NN D='N'    | يسمح بالإدخال اليدوي
REQUIRES_APPROVAL YN NN D='Y'    | يتطلب اعتماداً
''', area='journal')

table('GL_JOURNAL_TYPE', 'أنواع القيود', 'Journal Types', scope='TO', mix='code names active sort', cols='''
TYPE_GROUP      CODE NN IN:MANUAL,SYSTEM | المجموعة: يدوي يدخله المحاسب، أو آلي من مستند مصدر
MODULE_CODE     CODE NN          | الوحدة المصدرة
ALLOW_MANUAL    YN   NN D='N'    | يسمح بالإدخال اليدوي
IS_OPENING      YN   NN D='N'    | قيد افتتاحي (أول فترة في السنة المالية)
IS_ADJUSTMENT   YN   NN D='N'    | قيد تسوية
AUTO_REVERSE    YN   NN D='N'    | يعكس آلياً في أول يوم من الفترة التالية (الاستحقاقات)
EXCLUDE_FROM_PL YN   NN D='N'    | يستبعد من قائمة الدخل (قيد الإقفال)
REQUIRES_REFERENCE YN NN D='N'   | يتطلب رقماً مرجعياً
DESCRIPTION     V1000            | الوصف ومتى يستخدم
''', area='journal', purpose='نوع القيد يحدد قواعد إدخاله وظهوره في التقارير؛ GL_JOURNAL.JOURNAL_CATEGORY يحمل رمز النوع')

table('GL_JOURNAL', 'القيود', 'Journal Entries', scope='C', mix='pub branch doc cur wf conf status',
      status='DRAFT SUBMITTED APPROVED POSTED REVERSED CANCELLED', cols='''
LEDGER_ID       ID   NN >GL_LEDGER | الدفتر
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
POSTING_DATE    DATE NN          | تاريخ القيد (قد يختلف عن تاريخ المعاملة)
JOURNAL_SOURCE_ID ID NN >GL_JOURNAL_SOURCE | المصدر
JOURNAL_CATEGORY CODE            | نوع القيد (رمز من GL_JOURNAL_TYPE)
ACCOUNTING_EVENT_ID ID >ACE_ACCOUNTING_EVENT | الحدث المحاسبي المولد
RULE_VERSION_ID ID   >ACE_POSTING_RULE_VERSION | إصدار قاعدة الترحيل
REFERENCE_NO    V100             | المرجع
DESCRIPTION     V1000            | البيان
IS_OPENING      YN   NN D='N'    | قيد افتتاحي
IS_ADJUSTMENT   YN   NN D='N'    | قيد تسوية
REVERSAL_OF_ID  ID   >GL_JOURNAL | القيد المعكوس
REVERSED_BY_ID  ID   >GL_JOURNAL | قيد العكس
AUTO_REVERSE_DATE DATE           | تاريخ العكس الآلي
TOTAL_DEBIT_FUNC AMT NN D=0 @CALC | إجمالي المدين بالعملة الوظيفية
TOTAL_CREDIT_FUNC AMT NN D=0 @CALC | إجمالي الدائن بالعملة الوظيفية
INTERCOMPANY_TXN_ID ID >GL_INTERCOMPANY_TXN | معاملة بين الشركات
APPROVED_BY     USR              | المعتمد (لا يكون المنشئ - SoD)
POSTED_AT       TS   @SYS        | وقت الترحيل
POSTED_BY       USR  @SYS        | منفذ الترحيل
''', ix=[('TENANT_ID', 'LEDGER_ID', 'PERIOD_ID', 'STATUS_CODE'), ('TENANT_ID', 'ACCOUNTING_EVENT_ID')],
      chk=["STATUS_CODE <> 'POSTED' OR TOTAL_DEBIT_FUNC = TOTAL_CREDIT_FUNC"], area='journal',
      purpose='القيد المرحل لا يعدل ولا يمحى؛ يصحح بعكس أو تسوية (BR-007)', ret='دائم حسب القانون')

table('GL_JOURNAL_LINE', 'أسطر القيود', 'Journal Lines', scope='C', cols='''
JOURNAL_ID      ID   NN >GL_JOURNAL | القيد
LINE_NO         INT  NN          | رقم السطر
ACCOUNT_ID      ID   NN >GL_ACCOUNT | الحساب
ACCOUNT_CODE_SNAPSHOT V50 NN     | رمز الحساب التاريخي
DEBIT_AMOUNT    AMT  NN D=0      | مدين بعملة المعاملة
CREDIT_AMOUNT   AMT  NN D=0      | دائن بعملة المعاملة
CURRENCY_CODE   CUR  NN          | عملة المعاملة
EXCHANGE_RATE   RATE NN D=1      | السعر المستخدم
DEBIT_FUNC      AMT  NN D=0      | مدين بالعملة الوظيفية
CREDIT_FUNC     AMT  NN D=0      | دائن بالعملة الوظيفية
DEBIT_REPORTING AMT              | مدين بعملة التقارير
CREDIT_REPORTING AMT             | دائن بعملة التقارير
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
ORG_UNIT_ID     ID   >ORG_UNIT   | الوحدة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
WBS_ID          ID   >PRJ_WBS    | بند هيكل العمل
PROPERTY_ID     ID   >RE_PROPERTY | العقار
UNIT_ID         ID   >RE_UNIT    | الوحدة العقارية
PARTY_ID        ID   >PTY_PARTY  | الطرف
ITEM_ID         ID   >INV_ITEM   | الصنف
ASSET_ID        ID   >FA_ASSET   | الأصل
DIM1_VALUE_ID   ID   >GL_DIMENSION_VALUE | بعد مخصص 1
DIM2_VALUE_ID   ID   >GL_DIMENSION_VALUE | بعد مخصص 2
DIM3_VALUE_ID   ID   >GL_DIMENSION_VALUE | بعد مخصص 3
TAX_CODE_ID     ID   >LOC_TAX_CODE | كود الضريبة
DESCRIPTION     V1000            | البيان
SOURCE_LINE_REF V100             | مرجع سطر المصدر
RECONCILIATION_REF V100          | مرجع المطابقة
''', uk=[('JOURNAL_ID', 'LINE_NO')], chk=['DEBIT_AMOUNT >= 0 AND CREDIT_AMOUNT >= 0',
                                          'NOT (DEBIT_AMOUNT > 0 AND CREDIT_AMOUNT > 0)'],
      ix=[('TENANT_ID', 'ACCOUNT_ID')], area='journal', ret='دائم؛ مرشح للتقسيم حسب السنة')

table('GL_BALANCE', 'أرصدة الحسابات', 'Account Balances', scope='C', cols='''
LEDGER_ID       ID   NN >GL_LEDGER | الدفتر
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
ACCOUNT_ID      ID   NN >GL_ACCOUNT | الحساب
CURRENCY_CODE   CUR  NN          | العملة
DIMENSION_KEY   V200 NN D='-'    | مفتاح تجميع الأبعاد
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
OPENING_DR_FUNC AMT  NN D=0      | رصيد أول المدة مدين
OPENING_CR_FUNC AMT  NN D=0      | رصيد أول المدة دائن
PERIOD_DR_FUNC  AMT  NN D=0      | حركة مدين
PERIOD_CR_FUNC  AMT  NN D=0      | حركة دائن
PERIOD_DR_TXN   AMT  NN D=0      | حركة مدين بعملة المعاملة
PERIOD_CR_TXN   AMT  NN D=0      | حركة دائن بعملة المعاملة
LAST_REBUILT_AT TS               | آخر إعادة بناء من الحركات
''', uk=[('LEDGER_ID', 'PERIOD_ID', 'ACCOUNT_ID', 'CURRENCY_CODE', 'DIMENSION_KEY')], area='balance',
      purpose='رصيد مشتق يعاد بناؤه من GL_JOURNAL_LINE المرحلة؛ مصدر الحقيقة هو القيود')

table('GL_OPENING_BATCH', 'دفعات الأرصدة الافتتاحية', 'Opening Balance Batches', scope='C', mix='wf status',
      status='DRAFT VALIDATED APPROVED POSTED CANCELLED', cols='''
BATCH_NO        V50  NN          | الرقم
LEDGER_ID       ID   NN >GL_LEDGER | الدفتر
PERIOD_ID       ID   NN >GL_PERIOD | فترة الافتتاح
SCOPE_CODE      CODE NN IN:GL,AR,AP,INV,FA,CASH | النطاق
SOURCE_SYSTEM   V100             | النظام المصدر
JOURNAL_ID      ID   >GL_JOURNAL | القيد الناتج
DOCUMENT_ID     ID   >DMS_DOCUMENT | ملف المصدر
''', uk=[('TENANT_ID', 'COMPANY_ID', 'LEDGER_ID', 'PERIOD_ID', 'SCOPE_CODE', 'BATCH_NO')], area='journal',
      purpose='يمنع التحميل المكرر لنفس النطاق والفترة دون خطة إلغاء واعتماد')

table('GL_OPENING_LINE', 'أسطر الأرصدة الافتتاحية', 'Opening Balance Lines', scope='C', mix='cur', cols='''
BATCH_ID        ID   NN >GL_OPENING_BATCH | الدفعة
LINE_NO         INT  NN          | السطر
SOURCE_ACCOUNT  V100             | الحساب في النظام المصدر
ACCOUNT_ID      ID   NN >GL_ACCOUNT | الحساب
DEBIT_AMOUNT    AMT  NN D=0      | مدين
CREDIT_AMOUNT   AMT  NN D=0      | دائن
DEBIT_FUNC      AMT  NN D=0      | مدين وظيفي
CREDIT_FUNC     AMT  NN D=0      | دائن وظيفي
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
PARTY_ID        ID   >PTY_PARTY  | الطرف
''', uk=[('BATCH_ID', 'LINE_NO')], area='journal')

table('GL_RECURRING_JOURNAL', 'القيود الدورية', 'Recurring Journals', scope='C', mix='code names eff status', status='ACTIVE SUSPENDED ENDED', cols='''
LEDGER_ID       ID   NN >GL_LEDGER | الدفتر
FREQUENCY       CODE NN IN:MONTHLY,QUARTERLY,YEARLY | التكرار
TEMPLATE_LINES  JSON NN          | الأسطر النموذجية
LAST_GENERATED_PERIOD_ID ID >GL_PERIOD | آخر فترة ولدت
''', area='journal')

table('GL_ALLOCATION_RULE', 'قواعد توزيع التكاليف', 'Cost Allocation Rules', scope='C', mix='code names eff status', status='DRAFT ACTIVE RETIRED', cols='''
SOURCE_ACCOUNT_ID ID NN >GL_ACCOUNT | الحساب المصدر
SOURCE_COST_CENTER_ID ID >GL_COST_CENTER | المركز المصدر
BASIS_CODE      CODE NN IN:FIXED_PCT,HEADCOUNT,AREA,REVENUE,HOURS,STATISTICAL | أساس التوزيع
TARGETS         JSON NN          | المراكز المستهدفة ونسبها
''', area='journal')

table('GL_REVALUATION_RUN', 'عمليات إعادة تقييم العملات', 'FX Revaluation Runs', scope='C', mix='status', status='DRAFT CALCULATED POSTED REVERSED', cols='''
LEDGER_ID       ID   NN >GL_LEDGER | الدفتر
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
RATE_TYPE_ID    ID   NN >REF_RATE_TYPE | نوع السعر
RATE_DATE       DATE NN          | تاريخ السعر
SCOPE_CODE      CODE NN IN:GL,AR,AP,CASH,ALL | النطاق
JOURNAL_ID      ID   >GL_JOURNAL | القيد الناتج
AUTO_REVERSE    YN   NN D='Y'    | عكس آلي أول الفترة التالية
''', area='fx')

table('GL_REVALUATION_LINE', 'أسطر إعادة التقييم', 'FX Revaluation Lines', scope='C', cols='''
RUN_ID          ID   NN >GL_REVALUATION_RUN | العملية
ACCOUNT_ID      ID   NN >GL_ACCOUNT | الحساب
CURRENCY_CODE   CUR  NN          | العملة الأجنبية
PARTY_ID        ID   >PTY_PARTY  | الطرف
FOREIGN_BALANCE AMT  NN          | الرصيد الأجنبي
BOOK_FUNC_BALANCE AMT NN         | الرصيد الدفتري الوظيفي
NEW_RATE        RATE NN          | السعر الجديد
REVALUED_FUNC   AMT  NN          | الرصيد المقيم
DIFFERENCE_FUNC AMT  NN          | الفرق
''', area='fx')

table('GL_CLOSE_TASK', 'مهام الإقفال', 'Period Close Checklist', scope='C', mix='status sort', status='PENDING IN_PROGRESS DONE WAIVED BLOCKED', cols='''
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
TASK_CODE       V50  NN          | المهمة (ترحيل المستندات، إقفال المخزون، تقييم العملات، مطابقة البنوك...)
MODULE_CODE     CODE             | الوحدة
OWNER_MEMBER_ID ID   >SEC_USER_MEMBERSHIP | المسؤول
COMPLETED_AT    TS               | الإنجاز
EVIDENCE_DOCUMENT_ID ID >DMS_DOCUMENT | الدليل
''', uk=[('PERIOD_ID', 'TASK_CODE')], area='close')

table('GL_CLOSE_SNAPSHOT', 'لقطات الإقفال', 'Closing Snapshots', scope='C', append=True, cols='''
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
LEDGER_ID       ID   NN >GL_LEDGER | الدفتر
TRIAL_BALANCE   JSON NN          | ميزان المراجعة وقت الإقفال
CHECKS_RESULT   JSON             | نتائج المطابقات
SIGNED_BY       USR              | الموقع
''', area='close')

table('GL_FIN_STATEMENT', 'تعريفات القوائم المالية', 'Financial Statement Definitions', scope='TO', mix='code names status', status='DRAFT PUBLISHED RETIRED', codeuk=False, cols='''
STATEMENT_TYPE  CODE NN IN:BALANCE_SHEET,INCOME_STATEMENT,CASH_FLOW,EQUITY_CHANGES,TRIAL_BALANCE,CUSTOM | النوع
VERSION_NO      INT  NN D=1      | الإصدار
COA_ID          ID   >GL_CHART_OF_ACCOUNTS | دليل الحسابات
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='reporting')

table('GL_FIN_STATEMENT_LINE', 'أسطر القوائم المالية', 'Financial Statement Lines', scope='TO', mix='sort', cols='''
STATEMENT_ID    ID   NN >GL_FIN_STATEMENT | القائمة
LINE_CODE       V50  NN          | رمز السطر
LABEL_AR        V500 NN          | العنوان بالعربية
LABEL_EN        V500             | العنوان بالإنجليزية
PARENT_LINE_ID  ID   >GL_FIN_STATEMENT_LINE | السطر الأب
LINE_TYPE       CODE NN IN:HEADER,ACCOUNTS,FORMULA,TOTAL | النوع
ACCOUNT_RANGES  JSON             | نطاقات الحسابات
FORMULA         V1000            | المعادلة
SIGN_REVERSE    YN   NN D='N'    | عكس الإشارة
''', uk=[('STATEMENT_ID', 'LINE_CODE')], area='reporting')

table('GL_INTERCOMPANY_TXN', 'المعاملات بين الشركات', 'Intercompany Transactions', scope='T', mix='cur status',
      status='DRAFT SENT CONFIRMED POSTED_BOTH MATCHED DISPUTED CANCELLED', cols='''
IC_REFERENCE    V50  NN          | المرجع الموحد بين المستندين
FROM_COMPANY_ID ID   NN >ORG_COMPANY | الشركة المصدرة
TO_COMPANY_ID   ID   NN >ORG_COMPANY | الشركة المقابلة
AMOUNT          AMT  NN          | المبلغ
SOURCE_ENTITY_TYPE V50 >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | المستند المصدر
SOURCE_ENTITY_ID ID              | معرفه
CONFIRMED_BY    USR              | مؤكد الطرف الثاني
MATCH_DIFFERENCE AMT             | فرق المطابقة
''', uk=[('TENANT_ID', 'IC_REFERENCE')], chk=['FROM_COMPANY_ID <> TO_COMPANY_ID'], area='intercompany')

table('GL_CONSOLIDATION_GROUP', 'مجموعات التجميع', 'Consolidation Groups', scope='T', mix='code names active', cols='''
BUSINESS_GROUP_ID ID >ORG_BUSINESS_GROUP | مجموعة الأعمال
CONSOLIDATION_CURRENCY CUR NN    | عملة التجميع
COA_ID          ID   >GL_CHART_OF_ACCOUNTS | دليل حسابات التجميع
''', area='consolidation')

table('GL_CONSOLIDATION_RUN', 'عمليات التجميع', 'Consolidation Runs', scope='T', mix='status', status='DRAFT TRANSLATED ELIMINATED APPROVED PUBLISHED', cols='''
GROUP_ID        ID   NN >GL_CONSOLIDATION_GROUP | المجموعة
PERIOD_CODE     V20  NN          | الفترة
CLOSING_RATE_TYPE_ID ID >REF_RATE_TYPE | سعر الإقفال
AVERAGE_RATE_TYPE_ID ID >REF_RATE_TYPE | السعر المتوسط
RESULT_DATA     JSON             | النتائج والترجمة وفروقها
''', uk=[('GROUP_ID', 'PERIOD_CODE')], area='consolidation', purpose='لا يغير التجميع دفاتر الشركات القانونية')

table('GL_ELIMINATION_RULE', 'قواعد الاستبعاد', 'Elimination Rules', scope='T', mix='code names active', cols='''
GROUP_ID        ID   NN >GL_CONSOLIDATION_GROUP | المجموعة
RULE_DEFINITION JSON NN          | الحسابات المتقابلة وطريقة الاستبعاد
''', area='consolidation')

table('GL_BUDGET', 'الموازنات', 'Budgets', scope='C', mix='code names wf status', status='DRAFT SUBMITTED APPROVED ACTIVE FROZEN CLOSED', cols='''
LEDGER_ID       ID   NN >GL_LEDGER | الدفتر
FISCAL_YEAR_ID  ID   NN >GL_FISCAL_YEAR | السنة
VERSION_NO      INT  NN D=1      | الإصدار
CONTROL_LEVEL   CODE NN D='WARN' IN:NONE,WARN,BLOCK | مستوى الرقابة على الموازنة
''', area='budget')

table('GL_BUDGET_LINE', 'أسطر الموازنة', 'Budget Lines', scope='C', cols='''
BUDGET_ID       ID   NN >GL_BUDGET | الموازنة
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
ACCOUNT_ID      ID   NN >GL_ACCOUNT | الحساب
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
BUDGET_AMOUNT   AMT  NN          | المبلغ المعتمد
COMMITTED_AMOUNT AMT NN D=0 @SYS | الالتزامات (طلبات/أوامر)
ACTUAL_AMOUNT   AMT  NN D=0 @SYS | الفعلي
''', ix=[('TENANT_ID', 'BUDGET_ID', 'ACCOUNT_ID')], area='budget')

# =============================================================== Accounting engine
table('ACE_EVENT_CLASS', 'أصناف الأحداث المحاسبية', 'Accounting Event Classes', scope='G', mix='code names active', cols='''
EVENT_FAMILY    CODE NN          | العائلة (SALES، PURCHASE، INVENTORY، CASH، FA، PAYROLL، MFG، PROJECT، RE، LEASE)
SOURCE_ENTITY_TYPE V50 >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | نوع المستند المصدر
POSTING_MODE    CODE NN D='OUTBOX' IN:SAME_TRANSACTION,OUTBOX | الترحيل في نفس المعاملة أو عبر Outbox
MAX_DELAY_MINUTES INT            | أقصى تأخر مقبول
''', area='engine')

table('ACE_ACCOUNTING_EVENT', 'الأحداث المحاسبية', 'Accounting Events', scope='C', mix='src cur status',
      status='NEW VALIDATING READY POSTED FAILED REVERSED CANCELLED', cols='''
EVENT_CLASS_ID  ID   NN >ACE_EVENT_CLASS | الصنف
LEDGER_ID       ID   >GL_LEDGER  | الدفتر
SOURCE_VERSION  INT  NN D=1      | إصدار المصدر
EVENT_DATE      DATE NN          | تاريخ السريان
ACCOUNTING_DATE DATE NN          | تاريخ القيد
TOTAL_AMOUNT    AMT              | المبلغ
EVENT_DATA      JSON NN          | لقطة قيم المصدر (المبالغ والأبعاد ومراجع الضرائب)
IDEMPOTENCY_KEY V200 NN          | Tenant + نوع الحدث + المصدر + الإصدار + نوع الأثر
ATTEMPTS        INT  NN D=0      | المحاولات
LAST_ERROR      V4000            | آخر خطأ
JOURNAL_ID      ID   >GL_JOURNAL | القيد الناتج
REVERSAL_OF_EVENT_ID ID >ACE_ACCOUNTING_EVENT | الحدث المعكوس
CORRELATION_ID  V64              | معرف الارتباط
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY')],
      ix=[('TENANT_ID', 'STATUS_CODE', 'ACCOUNTING_DATE'), ('TENANT_ID', 'SOURCE_ENTITY_TYPE', 'SOURCE_ENTITY_ID')],
      area='engine', purpose='لا يسمح بترحيل الأثر نفسه مرتين حتى عند Retry (29.4)')

table('ACE_POSTING_RULE', 'قواعد الترحيل', 'Posting Rules', scope='TO', mix='code names active', codeuk=False, cols='''
EVENT_CLASS_ID  ID   NN >ACE_EVENT_CLASS | صنف الحدث
COUNTRY_CODE    CTRY             | الدولة
COMPANY_ID      ID   >ORG_COMPANY | الشركة (فارغ = كل الشركات)
LEDGER_TYPE     CODE             | نوع الدفتر
CONDITION_INFO  JSON             | نطاق المنتج/المشروع/الفئة
PRIORITY_NO     INT  NN D=100    | الأولوية
''', uk=[('TENANT_ID', 'CODE')], area='engine')

table('ACE_POSTING_RULE_VERSION', 'إصدارات قواعد الترحيل', 'Posting Rule Versions', scope='TO', mix='eff status',
      status='DRAFT TESTED APPROVED ACTIVE RETIRED', cols='''
POSTING_RULE_ID ID   NN >ACE_POSTING_RULE | القاعدة
VERSION_NO      INT  NN          | الإصدار (لا يعدل بعد الاعتماد)
SIMULATION_RESULT JSON           | نتيجة المحاكاة
APPROVED_BY     USR              | المعتمد
''', uk=[('POSTING_RULE_ID', 'VERSION_NO')], area='engine')

table('ACE_POSTING_RULE_LINE', 'أسطر قاعدة الترحيل', 'Posting Rule Lines', scope='TO', mix='sort', cols='''
RULE_VERSION_ID ID   NN >ACE_POSTING_RULE_VERSION | الإصدار
SIDE            CODE NN IN:DEBIT,CREDIT | الجانب
AMOUNT_SOURCE   V100 NN          | مصدر المبلغ من بيانات الحدث (NET، TAX، COST...)
ACCOUNT_SOURCE  CODE NN IN:FIXED,MAPPING,PARTY_ACCOUNT,ITEM_CATEGORY,TAX_CODE,BANK_ACCOUNT,ASSET_CATEGORY,PAYROLL_ELEMENT,PROJECT | مصدر الحساب
ACCOUNT_ID      ID   >GL_ACCOUNT | الحساب الثابت
MAPPING_TYPE    V50              | نوع جدول الاشتقاق
DIMENSION_MAP   JSON             | ربط الأبعاد
DESCRIPTION_TEMPLATE V500        | قالب البيان
''', area='engine')

table('ACE_ACCOUNT_MAPPING', 'جداول اشتقاق الحسابات', 'Account Derivation Mappings', scope='C', mix='eff', cols='''
MAPPING_TYPE    V50  NN          | النوع (ITEM_CATEGORY_INVENTORY، CUSTOMER_CLASS_AR...)
KEY_VALUE       V200 NN          | المفتاح
ACCOUNT_ID      ID   NN >GL_ACCOUNT | الحساب الناتج
''', uk=[('TENANT_ID', 'COMPANY_ID', 'MAPPING_TYPE', 'KEY_VALUE', 'EFFECTIVE_FROM')], area='engine')

table('ACE_EXCEPTION', 'قائمة استثناءات الترحيل', 'Posting Exception Queue', scope='C', mix='status', status='OPEN RETRYING RESOLVED IGNORED', cols='''
ACCOUNTING_EVENT_ID ID NN >ACE_ACCOUNTING_EVENT | الحدث
EXCEPTION_TYPE  CODE NN IN:NO_RULE,AMBIGUOUS_RULE,CLOSED_PERIOD,INVALID_ACCOUNT,UNBALANCED,MISSING_RATE,MISSING_DIMENSION,TECHNICAL | النوع
MESSAGE         V4000 NN         | الرسالة
ASSIGNED_TO     USR              | المكلف
RESOLVED_AT     TS               | وقت الحل
''', area='engine')

table('ACE_RECONCILIATION', 'مطابقة المصدر مع الأستاذ', 'Source-to-GL Reconciliation', scope='C', mix='status', status='RUNNING MATCHED DIFFERENCES APPROVED', cols='''
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
MODULE_CODE     CODE NN          | الوحدة
SOURCE_COUNT    NUM              | عدد أحداث المصدر
POSTED_COUNT    NUM              | المرحل
SOURCE_AMOUNT   AMT              | قيمة المصدر
GL_AMOUNT       AMT              | قيمة الأستاذ
DIFFERENCE      AMT              | الفرق
DETAILS         JSON             | غير المرحل والمكرر واليتيم
''', area='engine')
