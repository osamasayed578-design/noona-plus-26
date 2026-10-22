from model.dsl import module, table

module(9, 'AP', 'الموردون والحسابات الدائنة', 'Suppliers & Accounts Payable', 'NOONA_AP_PKG',
       'المورد دور على Party المركزي مع حساب لكل شركة؛ الفواتير والمستخلصات والالتزامات، والمطابقة الثلاثية، '
       'وجدولة الدفع والحجوزات والضمانات والاستقطاع، مع Maker-Checker على بيانات البنك.')

table('AP_SUPPLIER', 'الموردون', 'Suppliers', scope='T', mix='pub status', status='PROSPECT PENDING_APPROVAL ACTIVE ON_HOLD BLOCKED INACTIVE', cols='''
PARTY_ID        ID   NN U >PTY_PARTY | الطرف
SUPPLIER_NO     V50  NN U        | رقم المورد
SUPPLIER_TYPE   CODE NN D='GOODS' IN:GOODS,SERVICES,CONTRACTOR,SUBCONTRACTOR,CONSULTANT,UTILITY,GOVERNMENT,EMPLOYEE | النوع
SUPPLIER_CLASS  CODE             | التصنيف
IS_LOCAL        YN   NN D='Y'    | محلي
''', area='supplier')

table('AP_SUPPLIER_ACCOUNT', 'حسابات الموردين لكل شركة', 'Supplier Accounts', scope='C', mix='status', status='PENDING_APPROVAL ACTIVE ON_HOLD BLOCKED CLOSED', cols='''
SUPPLIER_ID     ID   NN >AP_SUPPLIER | المورد
ACCOUNT_NO      V50  NN          | رقم الحساب
CURRENCY_CODE   CUR  NN          | العملة
PAYMENT_TERM_ID ID   >REF_PAYMENT_TERM | شروط الدفع
PAYABLE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الدائنين الرقابي
PREPAYMENT_ACCOUNT_ID ID >GL_ACCOUNT | حساب الدفعات المقدمة
DEFAULT_BANK_ACCOUNT_ID ID >PTY_BANK_ACCOUNT | الحساب البنكي المعتمد
WITHHOLDING_TAX_CODE_ID ID >LOC_TAX_CODE | ضريبة الاستقطاع
DEFAULT_TAX_CODE_ID ID >LOC_TAX_CODE | ضريبة المدخلات
MATCH_POLICY    CODE NN D='THREE_WAY' IN:NONE,TWO_WAY,THREE_WAY,CONTRACT | سياسة المطابقة
REQUIRED_DOCS_OK YN  NN D='N'    | المستندات المطلوبة سارية
APPROVED_BY     USR              | المعتمد (لا يكون من أنشأه)
''', uk=[('TENANT_ID', 'COMPANY_ID', 'ACCOUNT_NO'), ('TENANT_ID', 'COMPANY_ID', 'SUPPLIER_ID')], area='supplier')

table('AP_SUPPLIER_SITE', 'مواقع المورد', 'Supplier Sites', scope='C', mix='active', cols='''
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | الحساب
SITE_USE        CODE NN IN:PURCHASING,PAYMENT,BOTH | الاستخدام
ADDRESS_ID      ID   NN >REF_ADDRESS | العنوان
IS_PRIMARY      YN   NN D='N'    | الرئيسي
''', area='supplier')

table('AP_INVOICE', 'فواتير الموردين', 'Supplier Invoices', scope='C', mix='pub branch doc cur wf posted status',
      status='DRAFT SUBMITTED MATCH_EXCEPTION ON_HOLD APPROVED POSTED PARTIALLY_PAID PAID CANCELLED', cols='''
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | الحساب
INVOICE_TYPE    CODE NN D='STANDARD' IN:STANDARD,CREDIT_MEMO,DEBIT_MEMO,PREPAYMENT,PROGRESS_CLAIM,EXPENSE,RENT,UTILITY | النوع
SUPPLIER_INVOICE_NO V100 NN      | رقم فاتورة المورد
SUPPLIER_INVOICE_DATE DATE NN    | تاريخ فاتورة المورد
GL_DATE         DATE NN          | التاريخ المحاسبي
PURCHASE_ORDER_ID ID >PUR_ORDER  | أمر الشراء
PROJECT_CONTRACT_ID ID >PRJ_CONTRACT | عقد المشروع/المقاول
PROGRESS_CLAIM_ID ID >PRJ_PROGRESS_CLAIM | المستخلص
ORIGINAL_INVOICE_ID ID >AP_INVOICE | الفاتورة الأصلية للإشعار
PAYMENT_TERM_ID ID   >REF_PAYMENT_TERM | شروط الدفع
SUBTOTAL        AMT  NN D=0      | قبل الضريبة
TAX_AMOUNT      AMT  NN D=0      | الضريبة
WITHHOLDING_AMOUNT AMT NN D=0    | الاستقطاع
RETENTION_AMOUNT AMT NN D=0      | المحتجز (Retention)
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي
MATCH_STATUS    CODE NN D='NOT_REQUIRED' IN:NOT_REQUIRED,PENDING,MATCHED,EXCEPTION,OVERRIDDEN | حالة المطابقة
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع الاستلام المباشر
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة المخزون
PAYMENT_MODE    CODE NN D='CREDIT' IN:CREDIT,CASH | آجل أو نقدي
SETTLE_PLACE    V30              | الصندوق/البنك للفاتورة النقدية (BOX:n / BANK:n)
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة الافتراضي
DUPLICATE_CHECK_KEY V200 @CALC   | مفتاح كشف التكرار (المورد + الرقم المعياري + السنة)
''', uk=[('TENANT_ID', 'COMPANY_ID', 'SUPPLIER_ACCOUNT_ID', 'SUPPLIER_INVOICE_NO', 'INVOICE_TYPE')],
      ix=[('TENANT_ID', 'DUPLICATE_CHECK_KEY'), ('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE')], area='invoice')

table('AP_INVOICE_LINE', 'أسطر فواتير الموردين', 'Supplier Invoice Lines', scope='C', cols='''
INVOICE_ID      ID   NN >AP_INVOICE | الفاتورة
LINE_NO         INT  NN          | السطر
LINE_TYPE       CODE NN D='ITEM' IN:ITEM,SERVICE,EXPENSE,FREIGHT,ASSET,TAX_ADJ,RETENTION,ADVANCE_RECOVERY | النوع
ITEM_ID         ID   >INV_ITEM   | الصنف
DESCRIPTION     V1000 NN         | الوصف
QUANTITY        QTY              | الكمية
UOM_ID          ID   >INV_UOM    | الوحدة
UNIT_PRICE      AMT              | السعر
LINE_AMOUNT     AMT  NN          | المبلغ
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
EXPENSE_ACCOUNT_ID ID >GL_ACCOUNT | حساب المصروف
PO_LINE_ID      ID   >PUR_ORDER_LINE | سطر أمر الشراء
RECEIPT_LINE_ID ID   >PUR_RECEIPT_LINE | سطر الاستلام
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
WBS_ID          ID   >PRJ_WBS    | بند العمل
ASSET_ID        ID   >FA_ASSET   | الأصل (رسملة)
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
TAX_AMOUNT      AMT  NN D=0      | الضريبة
LOT_NO          V100             | رقم الدفعة المستلمة
EXPIRY_DATE     DATE             | تاريخ الانتهاء
ORIGINAL_LINE_ID ID  >AP_INVOICE_LINE | سطر الفاتورة الأصلية (للمرتجع)
''', uk=[('INVOICE_ID', 'LINE_NO')], area='invoice')

table('AP_INVOICE_MATCH', 'نتائج المطابقة الثلاثية', 'Three-Way Match Results', scope='C', mix='status', status='MATCHED VARIANCE OVERRIDDEN REJECTED', cols='''
INVOICE_LINE_ID ID   NN >AP_INVOICE_LINE | سطر الفاتورة
PO_LINE_ID      ID   >PUR_ORDER_LINE | سطر الأمر
RECEIPT_LINE_ID ID   >PUR_RECEIPT_LINE | سطر الاستلام
QTY_VARIANCE    QTY              | فرق الكمية
PRICE_VARIANCE  AMT              | فرق السعر
TAX_VARIANCE    AMT              | فرق الضريبة
OVERRIDE_EXCEPTION_ID ID >WF_EXCEPTION | الاستثناء المعتمد
''', area='invoice')

table('AP_HOLD', 'حجوزات الدفع', 'Payment Holds', scope='C', mix='status', status='ACTIVE RELEASED', cols='''
INVOICE_ID      ID   >AP_INVOICE | الفاتورة
SUPPLIER_ACCOUNT_ID ID >AP_SUPPLIER_ACCOUNT | أو المورد كاملاً
HOLD_REASON     CODE NN IN:MATCH_EXCEPTION,DISPUTE,MISSING_DOCUMENT,EXPIRED_REGISTRATION,BANK_CHANGE,BUDGET,MANUAL | السبب
NOTES           V1000            | ملاحظات
RELEASED_BY     USR              | رافع الحجز
RELEASED_AT     TS               | الوقت
''', chk=['INVOICE_ID IS NOT NULL OR SUPPLIER_ACCOUNT_ID IS NOT NULL'], area='payment')

table('AP_OPEN_ITEM', 'الذمم الدائنة', 'Payable Open Items', scope='C', mix='branch cur status',
      status='OPEN SCHEDULED PARTIALLY_PAID PAID ON_HOLD CANCELLED', cols='''
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | الحساب
INVOICE_ID      ID   >AP_INVOICE | الفاتورة
ITEM_TYPE       CODE NN IN:INVOICE,CREDIT_MEMO,PREPAYMENT,RETENTION,WITHHOLDING,ADJUSTMENT | النوع
DOC_NO          V50  NN          | رقم المستند
DUE_DATE        DATE NN          | الاستحقاق
INSTALLMENT_NO  INT              | القسط
ORIGINAL_AMOUNT AMT  NN          | الأصلي
OPEN_AMOUNT     AMT  NN          | المتبقي
ORIGINAL_FUNC   AMT  NN          | الأصلي الوظيفي
OPEN_FUNC       AMT  NN          | المتبقي الوظيفي
''', ix=[('TENANT_ID', 'COMPANY_ID', 'SUPPLIER_ACCOUNT_ID', 'STATUS_CODE'), ('TENANT_ID', 'COMPANY_ID', 'DUE_DATE')],
      chk=['OPEN_AMOUNT <= ORIGINAL_AMOUNT'], area='payable')

table('AP_PAYMENT_BATCH', 'دفعات السداد المقترحة', 'Payment Batches / Proposals', scope='C', mix='doc wf status',
      status='DRAFT PROPOSED APPROVED SUBMITTED COMPLETED CANCELLED', cols='''
PAYMENT_DATE    DATE NN          | تاريخ الدفع
BANK_ACCOUNT_ID ID   >CSH_BANK_ACCOUNT | حساب الشركة البنكي
CURRENCY_CODE   CUR  NN          | العملة
SELECTION_CRITERIA JSON          | معايير الاختيار
TOTAL_AMOUNT    AMT              | الإجمالي
BANK_FILE_DOCUMENT_ID ID >DMS_DOCUMENT | ملف البنك
''', area='payment')

table('AP_PAYMENT', 'مدفوعات الموردين', 'Supplier Payments', scope='C', mix='pub branch doc cur wf posted status',
      status='DRAFT APPROVED SUBMITTED_TO_BANK SETTLED FAILED REVERSED CANCELLED', cols='''
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | الحساب
BATCH_ID        ID   >AP_PAYMENT_BATCH | الدفعة
PAYMENT_METHOD_ID ID NN >REF_PAYMENT_METHOD | الطريقة
PAYEE_BANK_ACCOUNT_ID ID >PTY_BANK_ACCOUNT | الحساب البنكي المستخدم فعلياً (Snapshot)
PAYEE_IBAN_MASKED V40            | IBAN وقت الدفع مقنعاً
COMPANY_BANK_ACCOUNT_ID ID >CSH_BANK_ACCOUNT | حساب الشركة
CASH_BOX_ID     ID   >CSH_CASH_BOX | الصندوق
CASH_TRANSACTION_ID ID >CSH_TRANSACTION | حركة البنك/الصندوق
CHEQUE_ID       ID   >CSH_CHEQUE | الشيك
AMOUNT          AMT  NN          | المبلغ
AMOUNT_FUNC     AMT              | الوظيفي
UNAPPLIED_AMOUNT AMT NN D=0      | غير المخصص
FAILURE_REASON  V500             | سبب الفشل/الرد
''', area='payment', purpose='الذي عدل حساب البنك لا يعتمد الدفع (SoD)')

table('AP_PAYMENT_APPLICATION', 'تخصيص المدفوعات', 'Payment Applications', scope='C', mix='status', status='APPLIED UNAPPLIED', cols='''
PAYMENT_ID      ID   NN >AP_PAYMENT | الدفعة
OPEN_ITEM_ID    ID   NN >AP_OPEN_ITEM | الذمة
APPLIED_AMOUNT  AMT  NN          | المبلغ
DISCOUNT_TAKEN  AMT  NN D=0      | الخصم المكتسب
FX_GAIN_LOSS    AMT  NN D=0      | فرق العملة
APPLIED_DATE    DATE NN          | التاريخ
REVERSAL_OF_ID  ID   >AP_PAYMENT_APPLICATION | إلغاء تخصيص
ACCOUNTING_EVENT_ID ID >ACE_ACCOUNTING_EVENT | الحدث المحاسبي
''', ix=[('TENANT_ID', 'OPEN_ITEM_ID')], area='payment')

table('AP_RETENTION', 'المحتجزات والضمانات', 'Retention Balances', scope='C', mix='cur status', status='HELD PARTIALLY_RELEASED RELEASED FORFEITED', cols='''
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | المورد/المقاول
PROJECT_CONTRACT_ID ID >PRJ_CONTRACT | العقد
INVOICE_ID      ID   >AP_INVOICE | الفاتورة المصدر
RETAINED_AMOUNT AMT  NN          | المحتجز
RELEASED_AMOUNT AMT  NN D=0      | المفرج عنه
RELEASE_DUE_DATE DATE            | موعد الإفراج
''', area='payable')
