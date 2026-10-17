from model.dsl import module, table

module(8, 'AR', 'العملاء والحسابات المدينة', 'Customers & Accounts Receivable', 'NOONA_AR_PKG',
       'العميل دور على Party المركزي، وحساب العميل مستقل لكل شركة. الذمم تنشأ من الفواتير والإيجارات '
       'والأقساط بعد الترحيل، والتحصيل يخصص بما لا يتجاوز المتاح، والرصيد يحسب من حركات موثقة.')

table('AR_CUSTOMER', 'العملاء', 'Customers', scope='T', mix='pub status', status='PROSPECT ACTIVE ON_HOLD BLOCKED INACTIVE', cols='''
PARTY_ID        ID   NN U >PTY_PARTY | الطرف
CUSTOMER_NO     V50  NN U        | رقم العميل
CUSTOMER_CLASS  CODE             | الفئة
CUSTOMER_GROUP_PARTY_ID ID >PTY_PARTY | مجموعة العميل (للحدود المجمعة)
IS_WALK_IN      YN   NN D='N'    | عميل عام (نقاط البيع)
''', area='customer')

table('AR_CUSTOMER_ACCOUNT', 'حسابات العملاء لكل شركة', 'Customer Accounts', scope='C', mix='status', status='ACTIVE ON_HOLD BLOCKED CLOSED', cols='''
CUSTOMER_ID     ID   NN >AR_CUSTOMER | العميل
ACCOUNT_NO      V50  NN          | رقم الحساب
CURRENCY_CODE   CUR  NN          | العملة الافتراضية
PAYMENT_TERM_ID ID   >REF_PAYMENT_TERM | شروط الدفع
RECEIVABLE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الذمم الرقابي
ADVANCE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الدفعات المقدمة
PRICE_LIST_ID   ID   >SAL_PRICE_LIST | قائمة الأسعار
SALES_REP_EMPLOYEE_ID ID >HR_EMPLOYEE | مندوب المبيعات
DEFAULT_TAX_CODE_ID ID >LOC_TAX_CODE | الضريبة الافتراضية
RISK_CLASS      CODE             | تصنيف المخاطر
DUNNING_LEVEL_ID ID  >AR_DUNNING_LEVEL | مستوى التحصيل الحالي
''', uk=[('TENANT_ID', 'COMPANY_ID', 'ACCOUNT_NO'), ('TENANT_ID', 'COMPANY_ID', 'CUSTOMER_ID')], area='customer',
      purpose='لا تختلط ديون شركتين في رصيد واحد')

table('AR_CUSTOMER_SITE', 'مواقع العميل', 'Customer Sites', scope='C', mix='active', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
SITE_USE        CODE NN IN:BILL_TO,SHIP_TO,BOTH | الاستخدام
ADDRESS_ID      ID   NN >REF_ADDRESS | العنوان
TAX_REGISTRATION_NO V50          | الرقم الضريبي للموقع
IS_PRIMARY      YN   NN D='N'    | الرئيسي
''', area='customer')

table('AR_CREDIT_LIMIT', 'حدود الائتمان', 'Credit Limits', scope='C', mix='eff', cols='''
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | الحساب
CUSTOMER_GROUP_PARTY_ID ID >PTY_PARTY | أو المجموعة
CURRENCY_CODE   CUR  NN          | العملة
CREDIT_LIMIT    AMT  NN          | الحد
MAX_OVERDUE_DAYS INT             | أقصى أيام تأخير قبل الإيقاف
EXPOSURE_RULES  JSON             | ما يدخل في التعرض (فواتير، أوامر معتمدة، شيكات مؤجلة...)
REVIEW_DATE     DATE             | المراجعة التالية
APPROVED_BY     USR              | المعتمد
''', chk=['CUSTOMER_ACCOUNT_ID IS NOT NULL OR CUSTOMER_GROUP_PARTY_ID IS NOT NULL'], area='credit')

table('AR_CREDIT_OVERRIDE', 'تجاوزات حد الائتمان', 'Credit Limit Overrides', scope='C', mix='wf status', status='REQUESTED APPROVED ACTIVE EXPIRED REJECTED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
SALES_ORDER_ID  ID   >SAL_ORDER  | الأمر المعني
EXTRA_AMOUNT    AMT  NN          | المبلغ الإضافي
CURRENCY_CODE   CUR  NN          | العملة
REASON          V1000 NN         | السبب
EXPIRES_AT      TS   NN          | الانتهاء
''', area='credit')

table('AR_CREDIT_HOLD', 'إيقافات العملاء', 'Customer Holds', scope='C', mix='status', status='ACTIVE RELEASED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
HOLD_REASON     CODE NN IN:CREDIT_LIMIT,OVERDUE,LEGAL,MANUAL,FRAUD | السبب
NOTES           V1000            | ملاحظات
RELEASED_BY     USR              | رافع الإيقاف
RELEASED_AT     TS               | وقت الرفع
''', area='credit')

table('AR_OPEN_ITEM', 'الذمم المدينة', 'Receivable Open Items', scope='C', mix='branch src cur status',
      status='OPEN PARTIALLY_PAID PAID DISPUTED WRITTEN_OFF CANCELLED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
ITEM_TYPE       CODE NN IN:INVOICE,DEBIT_NOTE,CREDIT_NOTE,DEPOSIT,ADVANCE,RENT,INSTALLMENT,SERVICE_CHARGE,PENALTY,ADJUSTMENT | النوع
DOC_NO          V50  NN          | رقم المستند
DOC_DATE        DATE NN          | تاريخ المستند
DUE_DATE        DATE NN          | تاريخ الاستحقاق
INSTALLMENT_NO  INT              | رقم القسط
ORIGINAL_AMOUNT AMT  NN          | المبلغ الأصلي
OPEN_AMOUNT     AMT  NN          | المتبقي (يعاد بناؤه من التطبيقات)
ORIGINAL_FUNC   AMT  NN          | الأصلي بالعملة الوظيفية
OPEN_FUNC       AMT  NN          | المتبقي الوظيفي
TAX_AMOUNT      AMT              | الضريبة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
UNIT_ID         ID   >RE_UNIT    | الوحدة العقارية
CONTRACT_REF    V100             | مرجع العقد
DISPUTE_ID      ID   >AR_DISPUTE | النزاع القائم
GL_JOURNAL_ID   ID   >GL_JOURNAL | القيد
''', ix=[('TENANT_ID', 'COMPANY_ID', 'CUSTOMER_ACCOUNT_ID', 'STATUS_CODE'), ('TENANT_ID', 'COMPANY_ID', 'DUE_DATE'),
         ('TENANT_ID', 'SOURCE_ENTITY_TYPE', 'SOURCE_ENTITY_ID')], area='receivable',
      chk=['OPEN_AMOUNT <= ORIGINAL_AMOUNT'])

table('AR_RECEIPT', 'المقبوضات', 'Customer Receipts', scope='C', mix='pub branch doc cur posted status',
      status='DRAFT CONFIRMED PENDING_CLEARANCE CLEARED RETURNED REVERSED CANCELLED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
PAYMENT_METHOD_ID ID NN >REF_PAYMENT_METHOD | الطريقة
CASH_TRANSACTION_ID ID >CSH_TRANSACTION | حركة النقدية/البنك
CHEQUE_ID       ID   >CSH_CHEQUE | الشيك
AMOUNT          AMT  NN          | المبلغ
AMOUNT_FUNC     AMT              | المبلغ الوظيفي
UNAPPLIED_AMOUNT AMT NN D=0 @CALC | غير المخصص (UNAPPLIED CASH)
EXTERNAL_REFERENCE V100          | مرجع البنك/البوابة
RETURN_REASON   V500             | سبب الارتداد
''', area='receipt', purpose='إصدار الإيصال ليس نجاح التحصيل البنكي إذا كان معلقاً')

table('AR_RECEIPT_APPLICATION', 'تخصيص المقبوضات', 'Receipt Applications', scope='C', mix='status', status='APPLIED UNAPPLIED', cols='''
RECEIPT_ID      ID   NN >AR_RECEIPT | المقبوض
OPEN_ITEM_ID    ID   NN >AR_OPEN_ITEM | الذمة
APPLIED_AMOUNT  AMT  NN          | المبلغ المخصص بعملة الذمة
DISCOUNT_AMOUNT AMT  NN D=0      | خصم السداد المبكر
FX_GAIN_LOSS    AMT  NN D=0      | فرق العملة المحقق
APPLIED_DATE    DATE NN          | تاريخ التخصيص
REVERSAL_OF_ID  ID   >AR_RECEIPT_APPLICATION | إلغاء تخصيص سابق (سجل منفصل)
ACCOUNTING_EVENT_ID ID >ACE_ACCOUNTING_EVENT | الحدث المحاسبي
''', chk=['APPLIED_AMOUNT <> 0'], ix=[('TENANT_ID', 'OPEN_ITEM_ID')], area='receipt')

table('AR_ADJUSTMENT', 'تسويات الذمم والشطب', 'AR Adjustments & Write-offs', scope='C', mix='doc wf posted status',
      status='DRAFT SUBMITTED APPROVED POSTED REJECTED CANCELLED', cols='''
OPEN_ITEM_ID    ID   NN >AR_OPEN_ITEM | الذمة
ADJUSTMENT_TYPE CODE NN IN:WRITE_OFF,SMALL_DIFFERENCE,PENALTY,INTEREST,BAD_DEBT,CORRECTION | النوع
AMOUNT          AMT  NN          | المبلغ
REASON          V1000 NN         | السبب
EXPENSE_ACCOUNT_ID ID >GL_ACCOUNT | الحساب المقابل
''', area='receivable')

table('AR_DISPUTE', 'نزاعات العملاء', 'Customer Disputes', scope='C', mix='status', status='OPEN UNDER_REVIEW RESOLVED_CREDIT RESOLVED_NO_CHANGE CLOSED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
DISPUTED_AMOUNT AMT  NN          | المبلغ
REASON_CODE     CODE NN          | السبب
DESCRIPTION     V4000            | التفاصيل
OWNER_MEMBER_ID ID   >SEC_USER_MEMBERSHIP | المسؤول
RESOLUTION_DATE DATE             | تاريخ الحل
RESOLUTION      V1000            | النتيجة
''', area='collection')

table('AR_PAYMENT_PROMISE', 'وعود الدفع', 'Promises to Pay', scope='C', mix='status', status='OPEN KEPT PARTIALLY_KEPT BROKEN CANCELLED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
PROMISED_AMOUNT AMT  NN          | المبلغ
PROMISED_DATE   DATE NN          | التاريخ
COLLECTOR_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المحصل
NOTES           V1000            | ملاحظات
''', area='collection')

table('AR_DUNNING_LEVEL', 'مستويات التحصيل', 'Dunning Levels', scope='C', mix='code names sort active', cols='''
DAYS_OVERDUE    INT  NN          | أيام التأخير
ACTION_CODE     CODE NN IN:REMINDER,LETTER,CALL,HOLD,LEGAL | الإجراء
NTF_TEMPLATE_CODE V50            | قالب الرسالة
FEE_AMOUNT      AMT              | رسوم التأخير
''', area='collection')

table('AR_DUNNING_RUN', 'عمليات التحصيل', 'Dunning Runs', scope='C', mix='status', status='DRAFT EXECUTED CANCELLED', cols='''
RUN_DATE        DATE NN          | تاريخ التشغيل
CUTOFF_DATE     DATE NN          | تاريخ القطع
LETTERS_COUNT   INT              | عدد الرسائل
''', area='collection')

table('AR_DUNNING_LETTER', 'رسائل المطالبة', 'Dunning Letters', scope='C', mix='status', status='GENERATED SENT FAILED CANCELLED', cols='''
DUNNING_RUN_ID  ID   NN >AR_DUNNING_RUN | العملية
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
DUNNING_LEVEL_ID ID  NN >AR_DUNNING_LEVEL | المستوى
OVERDUE_AMOUNT  AMT  NN          | المتأخر
CORRESPONDENCE_ID ID >COR_CORRESPONDENCE | المراسلة الصادرة
NOTIFICATION_ID ID   >NTF_NOTIFICATION | الإشعار
''', area='collection')

table('AR_AGING_BUCKET', 'شرائح الأعمار', 'Aging Buckets', scope='TO', mix='code names sort', codeuk=False, cols='''
BUCKET_SET      V30  NN D='DEFAULT' | مجموعة الشرائح
FROM_DAYS       INT  NN          | من يوم
TO_DAYS         INT              | إلى يوم (فارغ = فأكثر)
''', uk=[('TENANT_ID', 'BUCKET_SET', 'CODE')], area='reporting')

table('AR_STATEMENT_RUN', 'كشوف حساب العملاء', 'Customer Statement Runs', scope='C', mix='status', status='GENERATED SENT FAILED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
FROM_DATE       DATE NN          | من
TO_DATE         DATE NN          | إلى
CLOSING_BALANCE AMT              | الرصيد الختامي
DOCUMENT_ID     ID   >DMS_DOCUMENT | الكشف
''', area='reporting')

table('AR_PROVISION', 'مخصصات الديون المشكوك فيها', 'Doubtful Debt Provisions', scope='C', mix='posted status', status='DRAFT APPROVED POSTED REVERSED', cols='''
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
METHOD_CODE     CODE NN IN:AGING_MATRIX,SPECIFIC,ECL | الطريقة
PROVISION_AMOUNT AMT NN          | المخصص
CALC_DETAILS    JSON             | تفاصيل الاحتساب
''', area='receivable')

table('AR_REFUND', 'ردود المبالغ للعملاء', 'Customer Refunds', scope='C', mix='doc wf posted status', status='DRAFT APPROVED PAID CANCELLED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | الحساب
RECEIPT_ID      ID   >AR_RECEIPT | المقبوض الأصلي
CREDIT_ITEM_ID  ID   >AR_OPEN_ITEM | الرصيد الدائن
AMOUNT          AMT  NN          | المبلغ
CURRENCY_CODE   CUR  NN          | العملة
CASH_TRANSACTION_ID ID >CSH_TRANSACTION | حركة الصرف
''', area='receipt')
