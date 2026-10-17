from model.dsl import module, table

module(15, 'PRJ', 'المشروعات والمقاولات والإنشاءات', 'Projects, Contracting & Construction', 'NOONA_PROJECTS_PKG',
       'المشروع وهيكل تقسيم العمل WBS والموازنات وخط الأساس، وعقود العملاء والمقاولين الفرعيين، وجداول '
       'الكميات BOQ، وأوامر التغيير، والمستخلصات بالمحتجز واسترداد الدفعة المقدمة، والتكاليف الفعلية، '
       'ونسب الإنجاز وخطابات الضمان.')

table('PRJ_PROJECT', 'المشروعات', 'Projects', scope='C', mix='pub code names branch conf wf status',
      status='PLANNED APPROVED ACTIVE ON_HOLD COMPLETED CLOSED CANCELLED', cols='''
PROJECT_TYPE    CODE NN IN:CONSTRUCTION,CLIENT_CONTRACT,INTERNAL,REAL_ESTATE_DEVELOPMENT,MAINTENANCE,CAPEX,PROGRAM,PORTFOLIO | النوع
PARENT_PROJECT_ID ID >PRJ_PROJECT | البرنامج/المحفظة الأم
SITE_ID         ID   >ORG_BUSINESS_SITE | موقع المشروع
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | العميل
MANAGER_EMPLOYEE_ID ID >HR_EMPLOYEE | مدير المشروع
MANAGER_POSITION_ID ID >ORG_POSITION | منصب مدير المشروع
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
CURRENCY_CODE   CUR  NN          | عملة المشروع
PLANNED_START   DATE             | البداية المخططة
PLANNED_END     DATE             | النهاية المخططة
ACTUAL_START    DATE             | البداية الفعلية
ACTUAL_END      DATE             | النهاية الفعلية
CONTRACT_VALUE  AMT              | قيمة العقد الرئيسي
BUDGET_AMOUNT   AMT              | الموازنة المعتمدة
PERCENT_COMPLETE PCT @CALC       | نسبة الإنجاز
REVENUE_METHOD  CODE IN:MILESTONE,PERCENT_COMPLETE,COST_TO_COST,BILLING,COMPLETED_CONTRACT | طريقة الاعتراف بالإيراد
''', area='project')

table('PRJ_WBS', 'هيكل تقسيم العمل', 'Work Breakdown Structure', scope='C', mix='code names status', codeuk=False,
      status='PLANNED ACTIVE COMPLETED CLOSED CANCELLED', cols='''
PROJECT_ID      ID   NN >PRJ_PROJECT | المشروع
PARENT_WBS_ID   ID   >PRJ_WBS    | العنصر الأب
WBS_LEVEL       INT  NN D=1      | المستوى
WEIGHT_PCT      PCT              | الوزن في الإنجاز
PLANNED_START   DATE             | البداية
PLANNED_END     DATE             | النهاية
IS_BILLABLE     YN   NN D='Y'    | قابل للفوترة
IS_CHARGEABLE   YN   NN D='Y'    | يقبل تحميل التكاليف
''', uk=[('PROJECT_ID', 'CODE')], chk=['PARENT_WBS_ID IS NULL OR PARENT_WBS_ID <> ID'], area='project')

table('PRJ_BUDGET', 'موازنات المشروعات', 'Project Budgets', scope='C', mix='wf status', status='DRAFT SUBMITTED APPROVED BASELINE SUPERSEDED', cols='''
PROJECT_ID      ID   NN >PRJ_PROJECT | المشروع
VERSION_NO      INT  NN          | الإصدار
BUDGET_TYPE     CODE NN D='COST' IN:COST,REVENUE,CASH_FLOW | النوع
IS_BASELINE     YN   NN D='N'    | خط الأساس المعتمد
TOTAL_AMOUNT    AMT              | الإجمالي
CHANGE_REASON   V1000            | سبب المراجعة
''', uk=[('PROJECT_ID', 'BUDGET_TYPE', 'VERSION_NO')], area='budget')

table('PRJ_BUDGET_LINE', 'أسطر موازنة المشروع', 'Project Budget Lines', scope='C', cols='''
BUDGET_ID       ID   NN >PRJ_BUDGET | الموازنة
WBS_ID          ID   NN >PRJ_WBS | بند العمل
COST_TYPE       CODE NN IN:MATERIAL,LABOR,EQUIPMENT,SUBCONTRACT,OVERHEAD,OTHER,REVENUE | نوع التكلفة
PERIOD_ID       ID   >GL_PERIOD  | الفترة
AMOUNT          AMT  NN          | المبلغ
QUANTITY        QTY              | الكمية
''', area='budget')

table('PRJ_CONTRACT', 'عقود المشروعات', 'Project Contracts', scope='C', mix='pub cur wf status',
      status='DRAFT UNDER_REVIEW APPROVED SIGNED ACTIVE SUSPENDED COMPLETED CLOSED TERMINATED', cols='''
CONTRACT_NO     V50  NN          | رقم العقد
PROJECT_ID      ID   NN >PRJ_PROJECT | المشروع
CONTRACT_TYPE   CODE NN IN:MAIN_CONTRACT,SUBCONTRACT,CONSULTANCY,SUPPLY,LABOR_ONLY,DESIGN_BUILD | النوع
PARTY_ID        ID   NN >PTY_PARTY | الطرف (العميل أو المقاول)
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | حساب العميل (عقد رئيسي)
SUPPLIER_ACCOUNT_ID ID >AP_SUPPLIER_ACCOUNT | حساب المقاول (عقد باطن)
PARENT_CONTRACT_ID ID >PRJ_CONTRACT | العقد الرئيسي لعقد الباطن
PRICING_TYPE    CODE NN D='REMEASURED' IN:LUMP_SUM,REMEASURED,COST_PLUS,UNIT_RATE,TIME_MATERIAL | التسعير
ORIGINAL_VALUE  AMT  NN          | القيمة الأصلية
CURRENT_VALUE   AMT  @CALC       | القيمة بعد أوامر التغيير
RETENTION_PCT   PCT              | نسبة المحتجز
RETENTION_CAP_PCT PCT            | سقف المحتجز
ADVANCE_PCT     PCT              | نسبة الدفعة المقدمة
ADVANCE_RECOVERY_PCT PCT         | نسبة استرداد المقدم من كل مستخلص
START_DATE      DATE             | البداية
END_DATE        DATE             | النهاية
DEFECTS_LIABILITY_MONTHS INT     | فترة الضمان
SIGNED_DOCUMENT_ID ID >DMS_DOCUMENT | العقد الموقع
''', uk=[('TENANT_ID', 'COMPANY_ID', 'CONTRACT_NO')], area='contract')

table('PRJ_BOQ_ITEM', 'جداول الكميات', 'Bill of Quantities', scope='C', mix='sort', cols='''
CONTRACT_ID     ID   NN >PRJ_CONTRACT | العقد
WBS_ID          ID   >PRJ_WBS    | بند العمل
PARENT_BOQ_ID   ID   >PRJ_BOQ_ITEM | البند الأب (قسم)
ITEM_CODE       V50  NN          | رقم البند
DESCRIPTION_AR  V2000 NN         | الوصف
DESCRIPTION_EN  V2000            | Description
UOM_ID          ID   >INV_UOM    | الوحدة
CONTRACT_QTY    QTY  NN D=0      | الكمية التعاقدية
UNIT_RATE       AMT  NN D=0      | سعر الوحدة
AMOUNT          AMT  @CALC       | القيمة
VARIATION_QTY   QTY  NN D=0 @SYS | كميات أوامر التغيير
EXECUTED_QTY    QTY  NN D=0 @SYS | المنفذ حتى تاريخه
IS_PROVISIONAL  YN   NN D='N'    | مبلغ احتياطي
''', uk=[('CONTRACT_ID', 'ITEM_CODE')], area='contract')

table('PRJ_VARIATION_ORDER', 'أوامر التغيير', 'Variation Orders', scope='C', mix='doc wf status',
      status='DRAFT SUBMITTED UNDER_REVIEW APPROVED REJECTED CANCELLED', cols='''
CONTRACT_ID     ID   NN >PRJ_CONTRACT | العقد
VARIATION_TYPE  CODE NN IN:ADDITION,OMISSION,SUBSTITUTION,TIME_EXTENSION,PRICE_ADJUSTMENT | النوع
DESCRIPTION     V4000 NN         | الوصف
AMOUNT          AMT  NN D=0      | الأثر المالي
TIME_IMPACT_DAYS INT             | الأثر الزمني
CLIENT_APPROVAL_REF V100         | مرجع موافقة العميل
''', area='contract')

table('PRJ_VARIATION_LINE', 'أسطر أوامر التغيير', 'Variation Order Lines', scope='C', cols='''
VARIATION_ID    ID   NN >PRJ_VARIATION_ORDER | الأمر
BOQ_ITEM_ID     ID   >PRJ_BOQ_ITEM | البند القائم
NEW_ITEM_CODE   V50              | بند جديد
DESCRIPTION     V2000            | الوصف
QTY_CHANGE      QTY  NN          | تغير الكمية
UNIT_RATE       AMT  NN          | السعر
AMOUNT          AMT  NN          | القيمة
''', area='contract')

table('PRJ_PROGRESS_CLAIM', 'المستخلصات', 'Progress Claims / Payment Certificates', scope='C', mix='pub doc cur wf posted status',
      status='DRAFT SUBMITTED CERTIFIED APPROVED INVOICED PAID REJECTED CANCELLED', cols='''
CONTRACT_ID     ID   NN >PRJ_CONTRACT | العقد
CLAIM_NO        INT  NN          | رقم المستخلص التسلسلي
CLAIM_DIRECTION CODE NN IN:RECEIVABLE,PAYABLE | لنا من العميل أو علينا للمقاول
PERIOD_FROM     DATE NN          | من
PERIOD_TO       DATE NN          | إلى
GROSS_TO_DATE   AMT  NN D=0      | الإجمالي التراكمي
PREVIOUS_CERTIFIED AMT NN D=0    | المعتمد سابقاً
CURRENT_GROSS   AMT  NN D=0      | قيمة الفترة
RETENTION_AMOUNT AMT NN D=0      | المحتجز
ADVANCE_RECOVERY AMT NN D=0      | استرداد الدفعة المقدمة
OTHER_DEDUCTIONS AMT NN D=0      | خصومات أخرى
TAX_AMOUNT      AMT  NN D=0      | الضريبة
NET_PAYABLE     AMT  NN D=0      | الصافي
CERTIFIED_BY    USR              | المعتمد/الاستشاري
CERTIFICATE_DOCUMENT_ID ID >DMS_DOCUMENT | شهادة الإنجاز
SALES_INVOICE_ID ID  >SAL_INVOICE | الفاتورة الناتجة (عميل)
''', uk=[('CONTRACT_ID', 'CLAIM_NO')], area='billing')

table('PRJ_PROGRESS_CLAIM_LINE', 'أسطر المستخلص', 'Progress Claim Lines', scope='C', cols='''
CLAIM_ID        ID   NN >PRJ_PROGRESS_CLAIM | المستخلص
BOQ_ITEM_ID     ID   NN >PRJ_BOQ_ITEM | البند
QTY_TO_DATE     QTY  NN          | الكمية التراكمية
PREVIOUS_QTY    QTY  NN D=0      | السابقة
CURRENT_QTY     QTY  NN          | الحالية
UNIT_RATE       AMT  NN          | السعر
AMOUNT_TO_DATE  AMT  NN          | القيمة التراكمية
CURRENT_AMOUNT  AMT  NN          | قيمة الفترة
''', uk=[('CLAIM_ID', 'BOQ_ITEM_ID')], area='billing')

table('PRJ_MILESTONE', 'المعالم', 'Milestones', scope='C', mix='names status', status='PLANNED ACHIEVED CERTIFIED INVOICED CANCELLED', cols='''
PROJECT_ID      ID   NN >PRJ_PROJECT | المشروع
CONTRACT_ID     ID   >PRJ_CONTRACT | العقد
WBS_ID          ID   >PRJ_WBS    | بند العمل
PLANNED_DATE    DATE             | المخطط
ACHIEVED_DATE   DATE             | المحقق
BILLING_PCT     PCT              | نسبة الفوترة
BILLING_AMOUNT  AMT              | المبلغ
EVIDENCE_DOCUMENT_ID ID >DMS_DOCUMENT | الإثبات
''', area='project')

table('PRJ_COST_LINE', 'التكاليف الفعلية للمشروع', 'Project Actual Costs', scope='C', mix='src cur', cols='''
PROJECT_ID      ID   NN >PRJ_PROJECT | المشروع
WBS_ID          ID   NN >PRJ_WBS | بند العمل
COST_TYPE       CODE NN IN:MATERIAL,LABOR,EQUIPMENT,SUBCONTRACT,OVERHEAD,OTHER | نوع التكلفة
COST_DATE       DATE NN          | التاريخ
QUANTITY        QTY              | الكمية
AMOUNT          AMT  NN          | المبلغ
AMOUNT_FUNC     AMT  NN          | الوظيفي
GL_JOURNAL_LINE_ID ID >GL_JOURNAL_LINE | سطر القيد
IS_COMMITMENT   YN   NN D='N'    | التزام (أمر شراء) لا تكلفة فعلية
''', ix=[('TENANT_ID', 'PROJECT_ID', 'WBS_ID'), ('TENANT_ID', 'SOURCE_ENTITY_TYPE', 'SOURCE_ENTITY_ID')], area='cost')

table('PRJ_PROGRESS_UPDATE', 'تحديثات نسب الإنجاز', 'Progress Updates', scope='C', append=True, cols='''
PROJECT_ID      ID   NN >PRJ_PROJECT | المشروع
WBS_ID          ID   >PRJ_WBS    | بند العمل
AS_OF_DATE      DATE NN          | حتى تاريخ
PERCENT_COMPLETE PCT NN          | النسبة
METHOD_CODE     CODE NN IN:PHYSICAL,COST_TO_COST,MILESTONE,MANUAL | الطريقة
REMARKS         V2000            | ملاحظات
EVIDENCE_DOCUMENT_ID ID >DMS_DOCUMENT | الإثبات
''', area='project')

table('PRJ_TIMESHEET', 'سجلات ساعات العمل', 'Timesheets', scope='C', mix='status', status='DRAFT SUBMITTED APPROVED REJECTED POSTED', cols='''
EMPLOYEE_ID     ID   NN >HR_EMPLOYEE | الموظف
PROJECT_ID      ID   NN >PRJ_PROJECT | المشروع
WBS_ID          ID   NN >PRJ_WBS | بند العمل
WORK_DATE       DATE NN          | التاريخ
HOURS           QTY  NN          | الساعات
COST_RATE       AMT              | معدل التكلفة
IS_BILLABLE     YN   NN D='Y'    | قابل للفوترة
APPROVED_BY     USR              | المعتمد
''', ix=[('TENANT_ID', 'EMPLOYEE_ID', 'WORK_DATE')], chk=['HOURS > 0 AND HOURS <= 24'], area='cost')

table('PRJ_GUARANTEE', 'خطابات الضمان', 'Letters of Guarantee', scope='C', mix='cur status',
      status='REQUESTED ISSUED ACTIVE EXTENDED REDUCED RELEASED LIQUIDATED EXPIRED', cols='''
GUARANTEE_NO    V100 NN          | رقم الخطاب
GUARANTEE_TYPE  CODE NN IN:BID,PERFORMANCE,ADVANCE_PAYMENT,RETENTION,MAINTENANCE,CUSTOMS | النوع
DIRECTION       CODE NN IN:ISSUED_BY_US,RECEIVED_FROM_PARTY | صادر منا أو وارد لنا
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
CONTRACT_ID     ID   >PRJ_CONTRACT | العقد
BANK_ID         ID   NN >REF_BANK | البنك
BENEFICIARY_PARTY_ID ID >PTY_PARTY | المستفيد
AMOUNT          AMT  NN          | المبلغ
ISSUE_DATE      DATE NN          | الإصدار
EXPIRY_DATE     DATE NN          | الانتهاء (تنبيه قبله)
MARGIN_AMOUNT   AMT              | الغطاء النقدي
DOCUMENT_ID     ID   >DMS_DOCUMENT | صورة الخطاب
''', uk=[('TENANT_ID', 'COMPANY_ID', 'GUARANTEE_NO')], ix=[('TENANT_ID', 'EXPIRY_DATE')], area='contract')
