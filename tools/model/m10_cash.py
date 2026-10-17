from model.dsl import module, table

module(10, 'CSH', 'النقدية والبنوك', 'Cash & Banks', 'NOONA_CASH_PKG',
       'حسابات الشركة البنكية والصناديق والعهد، وسندات القبض والصرف والتحويلات والشيكات، واستيراد كشوف '
       'البنوك والتسوية البنكية مع فصل اعتماد الطلب عن نجاح التسوية.')

table('CSH_BANK_ACCOUNT', 'حسابات الشركة البنكية', 'Company Bank Accounts', scope='C', mix='code names branch eff status',
      status='DRAFT ACTIVE FROZEN CLOSED', cols='''
BANK_ID         ID   NN >REF_BANK | البنك
BANK_BRANCH     V200             | فرع البنك
ACCOUNT_NO_MASKED V40 NN         | رقم الحساب مقنعاً
IBAN_MASKED     V40              | IBAN مقنعاً
IBAN_ENC_REF    V200             | مرجع القيمة المشفرة
CURRENCY_CODE   CUR  NN          | العملة
GL_ACCOUNT_ID   ID   NN >GL_ACCOUNT | حساب الأستاذ
CLEARING_ACCOUNT_ID ID >GL_ACCOUNT | الحساب الوسيط (شيكات/تحويلات معلقة)
MAX_PAYMENT_AMOUNT AMT           | حد العملية الواحدة
SIGNATORY_RULES JSON             | قواعد المفوضين بالتوقيع
STATEMENT_FORMAT CODE IN:MT940,CAMT053,CSV,API | صيغة الكشف
''', area='account', sens='CONFIDENTIAL')

table('CSH_CASH_BOX', 'الصناديق والعهد', 'Cash Boxes & Petty Cash', scope='C', mix='code names branch status', status='ACTIVE CLOSED SUSPENDED', cols='''
BOX_TYPE        CODE NN IN:MAIN,PETTY_CASH,POS_DRAWER,FRONT_DESK,CUSTODY | النوع
CURRENCY_CODE   CUR  NN          | العملة
CUSTODIAN_EMPLOYEE_ID ID >HR_EMPLOYEE | أمين الصندوق/صاحب العهدة
GL_ACCOUNT_ID   ID   NN >GL_ACCOUNT | حساب الأستاذ
MAX_BALANCE     AMT              | السقف
REPLENISH_LEVEL AMT              | حد إعادة التعزيز
''', area='account')

table('CSH_TRANSACTION', 'حركات النقدية والبنوك', 'Cash & Bank Transactions', scope='C', mix='pub branch doc src cur wf posted status',
      status='DRAFT APPROVED SUBMITTED_TO_BANK SETTLED FAILED REVERSED CANCELLED', cols='''
TXN_TYPE        CODE NN IN:RECEIPT,PAYMENT,TRANSFER_OUT,TRANSFER_IN,BANK_CHARGE,INTEREST,FX_ADJUSTMENT,ADJUSTMENT,REPLENISHMENT | النوع
CHANNEL         CODE NN IN:CASH,BANK_TRANSFER,CHEQUE,CARD,WALLET,GATEWAY,DIRECT_DEBIT | القناة
BANK_ACCOUNT_ID ID   >CSH_BANK_ACCOUNT | الحساب البنكي
CASH_BOX_ID     ID   >CSH_CASH_BOX | الصندوق
COUNTERPARTY_PARTY_ID ID >PTY_PARTY | الطرف المقابل
COUNTERPARTY_NAME NAME           | اسم المستفيد/الدافع
AMOUNT          AMT  NN          | المبلغ
AMOUNT_FUNC     AMT              | الوظيفي
VALUE_DATE      DATE             | تاريخ القيمة
EXTERNAL_REFERENCE V200          | المرجع البنكي
TRANSFER_ID     ID   >CSH_TRANSFER | التحويل الداخلي
CHEQUE_ID       ID   >CSH_CHEQUE | الشيك
IS_RECONCILED   YN   NN D='N'    | مسوى بنكياً
SETTLED_AT      TS               | وقت التسوية الفعلية
''', chk=['BANK_ACCOUNT_ID IS NOT NULL OR CASH_BOX_ID IS NOT NULL', 'AMOUNT > 0'],
      ix=[('TENANT_ID', 'BANK_ACCOUNT_ID', 'DOC_DATE'), ('TENANT_ID', 'CASH_BOX_ID', 'DOC_DATE')], area='transaction',
      purpose='اعتماد طلب الدفع لا يعني نجاح البنك (35.2)')

table('CSH_TRANSACTION_LINE', 'توزيع الحركة على الحسابات', 'Transaction GL Distribution', scope='C', cols='''
TRANSACTION_ID  ID   NN >CSH_TRANSACTION | الحركة
LINE_NO         INT  NN          | السطر
ACCOUNT_ID      ID   NN >GL_ACCOUNT | الحساب
AMOUNT          AMT  NN          | المبلغ
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
DESCRIPTION     V1000            | البيان
''', uk=[('TRANSACTION_ID', 'LINE_NO')], area='transaction')

table('CSH_TRANSFER', 'التحويلات الداخلية', 'Internal Transfers', scope='T', mix='cur wf status', status='DRAFT APPROVED IN_TRANSIT COMPLETED FAILED CANCELLED', cols='''
TRANSFER_NO     V50  NN          | الرقم
FROM_COMPANY_ID ID   NN >ORG_COMPANY | الشركة المحولة
TO_COMPANY_ID   ID   NN >ORG_COMPANY | الشركة المستلمة (قد تختلف: Intercompany)
FROM_BANK_ACCOUNT_ID ID >CSH_BANK_ACCOUNT | من حساب
FROM_CASH_BOX_ID ID  >CSH_CASH_BOX | من صندوق
TO_BANK_ACCOUNT_ID ID >CSH_BANK_ACCOUNT | إلى حساب
TO_CASH_BOX_ID  ID   >CSH_CASH_BOX | إلى صندوق
AMOUNT          AMT  NN          | المبلغ
TRANSIT_ACCOUNT_ID ID >GL_ACCOUNT | حساب النقدية العابرة
INTERCOMPANY_TXN_ID ID >GL_INTERCOMPANY_TXN | معاملة بين الشركات
''', uk=[('TENANT_ID', 'TRANSFER_NO')], area='transaction')

table('CSH_CHEQUE_BOOK', 'دفاتر الشيكات', 'Cheque Books', scope='C', mix='status', status='ACTIVE EXHAUSTED CANCELLED', cols='''
BANK_ACCOUNT_ID ID   NN >CSH_BANK_ACCOUNT | الحساب
FROM_NUMBER     NUM  NN          | من رقم
TO_NUMBER       NUM  NN          | إلى رقم
NEXT_NUMBER     NUM  NN          | التالي
''', chk=['TO_NUMBER >= FROM_NUMBER'], area='cheque')

table('CSH_CHEQUE', 'الشيكات', 'Cheques', scope='C', mix='cur status',
      status='ISSUED DELIVERED RECEIVED DEPOSITED UNDER_COLLECTION CLEARED BOUNCED RETURNED CANCELLED ON_HOLD', cols='''
DIRECTION       CODE NN IN:ISSUED,RECEIVED | صادر أو وارد
CHEQUE_BOOK_ID  ID   >CSH_CHEQUE_BOOK | الدفتر
BANK_ACCOUNT_ID ID   >CSH_BANK_ACCOUNT | الحساب
DRAWEE_BANK_ID  ID   >REF_BANK   | البنك المسحوب عليه (الوارد)
CHEQUE_NO       V30  NN          | رقم الشيك
CHEQUE_DATE     DATE NN          | تاريخ الشيك
DUE_DATE        DATE NN          | تاريخ الاستحقاق
PARTY_ID        ID   >PTY_PARTY  | الطرف
AMOUNT          AMT  NN          | المبلغ
BOUNCE_REASON   V500             | سبب الارتداد
CLEARED_AT      TS               | وقت التحصيل
''', ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE', 'DUE_DATE')], area='cheque',
      purpose='الشيك غير المحصل لا يحسب نقداً متاحاً إلا وفق سياسة معلنة')

table('CSH_BANK_STATEMENT', 'كشوف البنوك', 'Bank Statements', scope='C', mix='status', status='IMPORTED VALIDATED RECONCILING RECONCILED REJECTED', cols='''
BANK_ACCOUNT_ID ID   NN >CSH_BANK_ACCOUNT | الحساب
STATEMENT_NO    V50              | رقم الكشف
FROM_DATE       DATE NN          | من
TO_DATE         DATE NN          | إلى
OPENING_BALANCE AMT  NN          | الرصيد الافتتاحي
CLOSING_BALANCE AMT  NN          | الرصيد الختامي
SOURCE_CODE     CODE NN IN:FILE,API,MANUAL | المصدر
FILE_HASH       HASH             | Hash الملف (منع الاستيراد المكرر)
DOCUMENT_ID     ID   >DMS_DOCUMENT | الملف الأصلي
''', nuk=[('TENANT_ID', 'BANK_ACCOUNT_ID', 'FILE_HASH')], area='reconciliation',
      purpose='لا يعاد كتابة كشف وارد من البنك')

table('CSH_BANK_STATEMENT_LINE', 'أسطر كشف البنك', 'Bank Statement Lines', scope='C', mix='status', status='UNMATCHED SUGGESTED MATCHED EXPLAINED IGNORED', cols='''
STATEMENT_ID    ID   NN >CSH_BANK_STATEMENT | الكشف
LINE_NO         INT  NN          | السطر
TXN_DATE        DATE NN          | التاريخ
VALUE_DATE      DATE             | تاريخ القيمة
AMOUNT          AMT  NN          | المبلغ (موجب إيداع / سالب سحب)
BANK_REFERENCE  V200             | مرجع البنك
COUNTERPARTY    V500             | الطرف حسب البنك
NARRATIVE       V2000            | البيان
LINE_HASH       HASH NN          | Hash السطر لمنع التكرار
''', uk=[('TENANT_ID', 'LINE_HASH'), ('STATEMENT_ID', 'LINE_NO')], area='reconciliation')

table('CSH_RECON_RULE', 'قواعد المطابقة البنكية', 'Bank Matching Rules', scope='C', mix='code names active sort', cols='''
BANK_ACCOUNT_ID ID   >CSH_BANK_ACCOUNT | الحساب
MATCH_CRITERIA  JSON NN          | المبلغ والتاريخ والمرجع والمقابل
AUTO_MATCH_MIN_CONFIDENCE PCT    | أدنى ثقة للمطابقة الآلية (الملتبس لا يطابق آلياً)
''', area='reconciliation')

table('CSH_RECONCILIATION', 'التسويات البنكية', 'Bank Reconciliations', scope='C', mix='wf status', status='DRAFT IN_PROGRESS SUBMITTED APPROVED REOPENED', cols='''
BANK_ACCOUNT_ID ID   NN >CSH_BANK_ACCOUNT | الحساب
CUTOFF_DATE     DATE NN          | تاريخ القطع
BANK_BALANCE    AMT  NN          | رصيد البنك
BOOK_BALANCE    AMT  NN          | رصيد الدفاتر
OUTSTANDING_CHEQUES AMT          | شيكات غير مصروفة
DEPOSITS_IN_TRANSIT AMT          | إيداعات في الطريق
UNEXPLAINED_DIFF AMT             | فرق غير مفسر
PREPARED_BY     USR              | المعد
APPROVED_BY     USR              | المعتمد (فصل عن المعد)
''', uk=[('TENANT_ID', 'BANK_ACCOUNT_ID', 'CUTOFF_DATE')], area='reconciliation')

table('CSH_RECON_MATCH', 'مطابقات أسطر الكشف', 'Reconciliation Matches', scope='C', mix='status', status='SUGGESTED CONFIRMED REJECTED UNDONE', cols='''
RECONCILIATION_ID ID >CSH_RECONCILIATION | التسوية
STATEMENT_LINE_ID ID NN >CSH_BANK_STATEMENT_LINE | سطر الكشف
TRANSACTION_ID  ID   >CSH_TRANSACTION | حركة الدفاتر
MATCH_METHOD    CODE NN IN:AUTO,MANUAL,RULE,CREATED_FROM_LINE | طريقة المطابقة
CONFIDENCE_PCT  PCT              | درجة الثقة
MATCHED_AMOUNT  AMT  NN          | المبلغ المطابق
''', ix=[('TENANT_ID', 'STATEMENT_LINE_ID'), ('TENANT_ID', 'TRANSACTION_ID')], area='reconciliation')

table('CSH_PETTY_CASH_CLAIM', 'مطالبات العهد النثرية', 'Petty Cash Claims', scope='C', mix='doc wf posted status',
      status='DRAFT SUBMITTED APPROVED REIMBURSED REJECTED', cols='''
CASH_BOX_ID     ID   NN >CSH_CASH_BOX | العهدة
EMPLOYEE_ID     ID   >HR_EMPLOYEE | الموظف
TOTAL_AMOUNT    AMT  NN          | الإجمالي
CURRENCY_CODE   CUR  NN          | العملة
DETAILS         JSON             | البنود والمرفقات
''', area='transaction')
