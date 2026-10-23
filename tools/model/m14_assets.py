from model.dsl import module, table

module(14, 'FA', 'الأصول الثابتة', 'Fixed Assets', 'NOONA_ASSETS_PKG',
       'الفئات والدفاتر المالية والضريبية، والأصل ومكوناته، والاقتناء والرسملة، وجداول الإهلاك لكل '
       'أصل/دفتر/فترة، والنقل وإعادة التقييم والانخفاض والاستبعاد والجرد، مع منع الرسملة المكررة.')

table('FA_BOOK', 'دفاتر الأصول', 'Asset Books', scope='C', mix='code names active', cols='''
BOOK_TYPE       CODE NN D='FINANCIAL' IN:FINANCIAL,TAX,IFRS,LOCAL | النوع
LEDGER_ID       ID   >GL_LEDGER  | الدفتر المحاسبي
CALENDAR_ID     ID   >GL_FISCAL_CALENDAR | التقويم
''', area='setup')

table('FA_CATEGORY', 'فئات الأصول', 'Asset Categories', scope='C', mix='code names active', cols='''
PARENT_CATEGORY_ID ID >FA_CATEGORY | الفئة الأم
DEPRECIATION_METHOD CODE NN D='STRAIGHT_LINE' IN:STRAIGHT_LINE,DECLINING_BALANCE,DOUBLE_DECLINING,UNITS_OF_PRODUCTION,NONE | الطريقة
USEFUL_LIFE_MONTHS INT           | العمر الإنتاجي
RESIDUAL_PCT    PCT              | القيمة المتبقية %
CAPITALIZATION_THRESHOLD AMT     | الحد الأدنى للرسملة
PRORATE_CONVENTION CODE NN D='DAILY' IN:DAILY,FULL_MONTH,MID_MONTH,NEXT_MONTH | قاعدة احتساب الجزء
ASSET_ACCOUNT_ID ID  >GL_ACCOUNT | حساب الأصل
ACCUM_DEPR_ACCOUNT_ID ID >GL_ACCOUNT | مجمع الإهلاك
DEPR_EXPENSE_ACCOUNT_ID ID >GL_ACCOUNT | مصروف الإهلاك
CIP_ACCOUNT_ID  ID   >GL_ACCOUNT | مشروعات تحت التنفيذ
GAIN_LOSS_ACCOUNT_ID ID >GL_ACCOUNT | أرباح/خسائر الاستبعاد
POLICY_VERSION  INT  NN D=1      | إصدار السياسة
''', area='setup')

table('FA_ASSET', 'الأصول', 'Fixed Assets', scope='C', mix='pub branch names status',
      status='DRAFT CIP CAPITALIZED IN_SERVICE SUSPENDED FULLY_DEPRECIATED DISPOSED RETIRED', cols='''
ASSET_NO        V50  NN          | رقم الأصل الثابت
TAG_NO          V100             | رقم الملصق/الباركود
CATEGORY_ID     ID   NN >FA_CATEGORY | الفئة
PARENT_ASSET_ID ID   >FA_ASSET   | الأصل الأم (المكونات)
SITE_ID         ID   >ORG_BUSINESS_SITE | الموقع
LOCATION_TEXT   V500             | الموقع التفصيلي
CUSTODIAN_EMPLOYEE_ID ID >HR_EMPLOYEE | المسؤول/العهدة
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
PROPERTY_ID     ID   >RE_PROPERTY | العقار
UNIT_ID         ID   >RE_UNIT    | الوحدة العقارية
ACQUISITION_DATE DATE            | تاريخ الاقتناء
IN_SERVICE_DATE DATE             | تاريخ التشغيل/بدء الإهلاك
ORIGINAL_COST   AMT              | التكلفة الأصلية
CURRENCY_CODE   CUR              | العملة
SUPPLIER_ACCOUNT_ID ID >AP_SUPPLIER_ACCOUNT | المورد
AP_INVOICE_LINE_ID ID >AP_INVOICE_LINE | سطر الفاتورة المرسملة (يمنع الرسملة مرتين)
SERIAL_NO       V100             | الرقم التسلسلي
MANUFACTURER    V200             | الصانع
MODEL_NO        V100             | الموديل
WARRANTY_END    DATE             | نهاية الضمان
CONTRACT_DOCUMENT_ID ID >DMS_DOCUMENT | العقد/المستند
''', uk=[('TENANT_ID', 'COMPANY_ID', 'ASSET_NO')], nuk=[('TENANT_ID', 'AP_INVOICE_LINE_ID')], area='asset')

table('FA_ASSET_BOOK', 'الأصل في الدفاتر', 'Asset Book Values', scope='C', mix='status', status='ACTIVE FULLY_DEPRECIATED DISPOSED', cols='''
ASSET_ID        ID   NN >FA_ASSET | الأصل
BOOK_ID         ID   NN >FA_BOOK | الدفتر
COST            AMT  NN          | التكلفة
RESIDUAL_VALUE  AMT  NN D=0      | القيمة المتبقية
DEPRECIATION_METHOD CODE NN IN:STRAIGHT_LINE,DECLINING_BALANCE,DOUBLE_DECLINING,UNITS_OF_PRODUCTION,NONE | الطريقة
USEFUL_LIFE_MONTHS INT           | العمر
DEPR_START_DATE DATE NN          | بداية الإهلاك
ACCUMULATED_DEPR AMT NN D=0 @SYS | مجمع الإهلاك
NET_BOOK_VALUE  AMT  NN D=0 @CALC | صافي القيمة الدفترية
LAST_DEPR_PERIOD_ID ID >GL_PERIOD | آخر فترة إهلاك
DEPRECIATED_TO  DATE             | مهلك حتى تاريخ (آخر فترة أو رصيد افتتاحي أو تاريخ الاستبعاد)
''', uk=[('ASSET_ID', 'BOOK_ID')], area='asset')

table('FA_TRANSACTION', 'حركات الأصول', 'Asset Transactions', scope='C', mix='doc wf posted status',
      status='DRAFT APPROVED POSTED REVERSED CANCELLED', cols='''
ASSET_ID        ID   NN >FA_ASSET | الأصل
BOOK_ID         ID   NN >FA_BOOK | الدفتر
TXN_TYPE        CODE NN IN:ADDITION,CAPITALIZATION,COST_ADJUSTMENT,LIFE_CHANGE,TRANSFER,REVALUATION,IMPAIRMENT,PARTIAL_RETIREMENT,DISPOSAL,REINSTATEMENT | النوع
TXN_DATE        DATE NN          | تاريخ الحركة
AMOUNT          AMT              | المبلغ
OLD_VALUES      JSON             | القيم السابقة
NEW_VALUES      JSON             | القيم الجديدة
REASON          V1000            | السبب
EXPERT_DOCUMENT_ID ID >DMS_DOCUMENT | تقرير الخبير (إعادة التقييم)
''', area='transaction')

table('FA_DEPRECIATION_RUN', 'عمليات الإهلاك', 'Depreciation Runs', scope='C', mix='status', status='DRAFT CALCULATED POSTED REVERSED', cols='''
BOOK_ID         ID   NN >FA_BOOK | الدفتر
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
METHOD_VERSION  V20              | إصدار طريقة الحساب
TOTAL_AMOUNT    AMT              | الإجمالي
JOURNAL_ID      ID   >GL_JOURNAL | القيد
''', uk=[('BOOK_ID', 'PERIOD_ID')], area='depreciation', purpose='يرفض التشغيل المكرر لنفس الفترة')

table('FA_DEPRECIATION_LINE', 'أسطر الإهلاك', 'Depreciation Lines', scope='C', cols='''
RUN_ID          ID   NN >FA_DEPRECIATION_RUN | العملية
ASSET_BOOK_ID   ID   NN >FA_ASSET_BOOK | الأصل/الدفتر
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
DEPRECIATION_AMOUNT AMT NN       | إهلاك الفترة
ACCUMULATED_AFTER AMT NN         | المجمع بعد
NBV_AFTER       AMT  NN          | الصافي بعد
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
''', uk=[('ASSET_BOOK_ID', 'PERIOD_ID')], area='depreciation')

table('FA_TRANSFER', 'نقل الأصول', 'Asset Transfers', scope='C', mix='doc wf status', status='DRAFT APPROVED COMPLETED CANCELLED', cols='''
ASSET_ID        ID   NN >FA_ASSET | الأصل
FROM_BRANCH_ID  ID   >ORG_BRANCH  | من فرع
TO_BRANCH_ID    ID   >ORG_BRANCH  | إلى فرع
FROM_SITE_ID    ID   >ORG_BUSINESS_SITE | من موقع
TO_SITE_ID      ID   >ORG_BUSINESS_SITE | إلى موقع
FROM_CUSTODIAN_ID ID >HR_EMPLOYEE | من عهدة
TO_CUSTODIAN_ID ID   >HR_EMPLOYEE | إلى عهدة
TO_COMPANY_ID   ID   >ORG_COMPANY | إلى شركة (معاملة قانونية ومحاسبية)
TRANSFER_DATE   DATE NN          | التاريخ
REASON          V1000            | السبب
''', area='transaction')

table('FA_DISPOSAL', 'استبعاد الأصول', 'Asset Disposals', scope='C', mix='doc wf posted status', status='DRAFT APPROVED POSTED CANCELLED', cols='''
ASSET_ID        ID   NN >FA_ASSET | الأصل
DISPOSAL_METHOD CODE NN IN:SALE,DONATION,SCRAP,LOSS,THEFT,TRADE_IN | الطريقة
DISPOSAL_DATE   DATE NN          | التاريخ
PROCEEDS        AMT  NN D=0      | المتحصلات
NBV_AT_DISPOSAL AMT  @CALC       | الصافي عند الاستبعاد
GAIN_LOSS       AMT  @CALC       | الربح/الخسارة
BUYER_PARTY_ID  ID   >PTY_PARTY  | المشتري
SALES_INVOICE_ID ID  >SAL_INVOICE | فاتورة البيع
EVIDENCE_DOCUMENT_ID ID >DMS_DOCUMENT | الإثبات
VAT_AMOUNT      AMT  NN D=0      | ضريبة القيمة المضافة على البيع
REASON          V1000            | السبب والملاحظات
''', area='transaction')

table('FA_COUNT', 'جرد الأصول', 'Asset Physical Counts', scope='C', mix='doc status', status='PLANNED IN_PROGRESS REVIEW APPROVED CLOSED', cols='''
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
SITE_ID         ID   >ORG_BUSINESS_SITE | الموقع
''', area='count')

table('FA_COUNT_LINE', 'أسطر جرد الأصول', 'Asset Count Lines', scope='C', cols='''
COUNT_ID        ID   NN >FA_COUNT | الجرد
ASSET_ID        ID   >FA_ASSET   | الأصل
SCANNED_TAG     V100             | الرمز الممسوح
FOUND_STATUS    CODE NN IN:FOUND,NOT_FOUND,FOUND_ELSEWHERE,UNREGISTERED,DAMAGED,NOT_IN_USE | النتيجة
OBSERVED_LOCATION V500           | الموقع الفعلي
NOTES           V1000            | ملاحظات
''', area='count')
