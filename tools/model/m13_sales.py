from model.dsl import module, table

module(13, 'SAL', 'المبيعات ونقاط البيع', 'Sales & Point of Sale', 'NOONA_SALES_PKG',
       'Quotation → Sales Order → Reservation → Delivery → Sales Invoice → Collection → Accounting، مع '
       'لقطات السعر والضريبة وسعر الصرف، والمرتجعات بإشعار دائن؛ ونقاط البيع POS بالوردية والدرج والدفع '
       'المختلط و Offline Mode مضبوط بمزامنة Idempotent.')

table('SAL_PRICE_LIST', 'قوائم الأسعار', 'Price Lists', scope='C', mix='code names eff status', status='DRAFT ACTIVE RETIRED', cols='''
CURRENCY_CODE   CUR  NN          | العملة
SALES_CHANNEL   CODE IN:DIRECT,RETAIL,WHOLESALE,ONLINE,POS,PROJECT,GOVERNMENT | القناة
CUSTOMER_CLASS  CODE             | فئة العملاء
PRICES_INCLUDE_TAX YN NN D='N'   | الأسعار شاملة الضريبة
PRIORITY_NO     INT  NN D=100    | الأولوية عند التعارض
''', area='pricing')

table('SAL_PRICE_LIST_LINE', 'أسعار الأصناف', 'Price List Lines', scope='C', mix='eff', cols='''
PRICE_LIST_ID   ID   NN >SAL_PRICE_LIST | القائمة
ITEM_ID         ID   NN >INV_ITEM | الصنف
UOM_ID          ID   NN >INV_UOM | الوحدة
MIN_QTY         QTY  NN D=0      | من كمية
UNIT_PRICE      AMT  NN          | السعر
MIN_PRICE       AMT              | أدنى سعر مسموح دون موافقة
''', uk=[('PRICE_LIST_ID', 'ITEM_ID', 'UOM_ID', 'MIN_QTY', 'EFFECTIVE_FROM')], chk=['UNIT_PRICE >= 0'], area='pricing')

table('SAL_DISCOUNT_RULE', 'قواعد الخصومات والعروض', 'Discount & Promotion Rules', scope='C', mix='code names eff status', status='DRAFT ACTIVE EXPIRED CANCELLED', cols='''
RULE_TYPE       CODE NN IN:LINE_PCT,LINE_AMOUNT,DOC_PCT,BUY_X_GET_Y,BUNDLE,COUPON,LOYALTY | النوع
CONDITIONS      JSON NN          | الشروط (صنف، فئة، عميل، كمية، قناة، فرع)
DISCOUNT_VALUE  AMT  NN          | القيمة
MAX_DISCOUNT_PCT PCT             | أقصى خصم دون موافقة
STACKABLE       YN   NN D='N'    | قابل للجمع
COUPON_CODE     V50              | كود الكوبون
''', area='pricing')

table('SAL_QUOTATION', 'عروض الأسعار', 'Sales Quotations', scope='C', mix='pub branch doc cur wf status',
      status='DRAFT SUBMITTED APPROVED SENT ACCEPTED REJECTED EXPIRED CONVERTED CANCELLED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | العميل
PRICE_LIST_ID   ID   >SAL_PRICE_LIST | قائمة الأسعار
VALID_UNTIL     DATE NN          | الصلاحية
REVISION_NO     INT  NN D=1      | المراجعة
SALES_REP_EMPLOYEE_ID ID >HR_EMPLOYEE | المندوب
SUBTOTAL        AMT  NN D=0      | قبل الضريبة
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
TAX_AMOUNT      AMT  NN D=0      | الضريبة
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي
MARGIN_PCT      PCT  @CALC       | الهامش المتوقع (يظهر قبل الاعتماد)
''', area='quote')

table('SAL_QUOTATION_LINE', 'أسطر عروض الأسعار', 'Quotation Lines', scope='C', cols='''
QUOTATION_ID    ID   NN >SAL_QUOTATION | العرض
LINE_NO         INT  NN          | السطر
ITEM_ID         ID   >INV_ITEM   | الصنف
DESCRIPTION     V1000 NN         | الوصف
QUANTITY        QTY  NN          | الكمية
UOM_ID          ID   NN >INV_UOM | الوحدة
LIST_PRICE      AMT  NN          | سعر القائمة
UNIT_PRICE      AMT  NN          | سعر البيع
DISCOUNT_PCT    PCT              | الخصم
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
LINE_AMOUNT     AMT  NN          | المبلغ
''', uk=[('QUOTATION_ID', 'LINE_NO')], area='quote')

table('SAL_ORDER', 'أوامر البيع', 'Sales Orders', scope='C', mix='pub branch doc cur wf status',
      status='DRAFT SUBMITTED APPROVED ON_HOLD PARTIALLY_FULFILLED FULFILLED PARTIALLY_INVOICED INVOICED CLOSED CANCELLED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | العميل
BILL_TO_SITE_ID ID   >AR_CUSTOMER_SITE | موقع الفوترة
SHIP_TO_SITE_ID ID   >AR_CUSTOMER_SITE | موقع الشحن
QUOTATION_ID    ID   >SAL_QUOTATION | العرض المصدر
PRICE_LIST_ID   ID   >SAL_PRICE_LIST | قائمة الأسعار
PAYMENT_TERM_ID ID   >REF_PAYMENT_TERM | شروط الدفع
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع الصرف
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
SALES_REP_EMPLOYEE_ID ID >HR_EMPLOYEE | المندوب
CUSTOMER_PO_NO  V100             | رقم أمر العميل
REVISION_NO     INT  NN D=0      | المراجعة
CREDIT_CHECK_STATUS CODE NN D='PENDING' IN:PENDING,PASSED,FAILED,OVERRIDDEN | فحص الائتمان
CREDIT_OVERRIDE_ID ID >AR_CREDIT_OVERRIDE | تجاوز الائتمان المعتمد
SUBTOTAL        AMT  NN D=0      | قبل الضريبة
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
TAX_AMOUNT      AMT  NN D=0      | الضريبة
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي
REQUESTED_DATE  DATE             | التاريخ المطلوب
''', ix=[('TENANT_ID', 'COMPANY_ID', 'CUSTOMER_ACCOUNT_ID', 'STATUS_CODE')], area='order')

table('SAL_ORDER_LINE', 'أسطر أوامر البيع', 'Sales Order Lines', scope='C', mix='status', status='OPEN RESERVED PARTIALLY_DELIVERED DELIVERED INVOICED CLOSED CANCELLED', cols='''
ORDER_ID        ID   NN >SAL_ORDER | الأمر
LINE_NO         INT  NN          | السطر
ITEM_ID         ID   >INV_ITEM   | الصنف
DESCRIPTION     V1000 NN         | الوصف
QUANTITY        QTY  NN          | الكمية
UOM_ID          ID   NN >INV_UOM | الوحدة
LIST_PRICE      AMT              | سعر القائمة (Snapshot)
UNIT_PRICE      AMT  NN          | سعر البيع (Snapshot)
DISCOUNT_PCT    PCT              | الخصم
DISCOUNT_RULE_ID ID  >SAL_DISCOUNT_RULE | قاعدة الخصم
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
LINE_AMOUNT     AMT  NN          | المبلغ
RESERVATION_ID  ID   >INV_RESERVATION | الحجز
DELIVERED_QTY   QTY  NN D=0      | المسلم
INVOICED_QTY    QTY  NN D=0      | المفوتر
RETURNED_QTY    QTY  NN D=0      | المرتجع
''', uk=[('ORDER_ID', 'LINE_NO')], area='order')

table('SAL_DELIVERY', 'التسليمات', 'Deliveries', scope='C', mix='pub branch doc status',
      status='DRAFT PICKED SHIPPED DELIVERED ACCEPTED PARTIALLY_INVOICED INVOICED CANCELLED', cols='''
ORDER_ID        ID   >SAL_ORDER  | الأمر
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | العميل
DELIVERY_TYPE   CODE NN D='GOODS' IN:GOODS,SERVICE_ACCEPTANCE | النوع
WAREHOUSE_ID    ID   >INV_WAREHOUSE | المستودع
SHIP_TO_SITE_ID ID   >AR_CUSTOMER_SITE | موقع الشحن
CARRIER         V200             | الناقل
PROOF_DOCUMENT_ID ID >DMS_DOCUMENT | إثبات الاستلام/التوقيع
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة الصرف
DELIVERED_AT    TS               | وقت التسليم
''', area='delivery')

table('SAL_DELIVERY_LINE', 'أسطر التسليم', 'Delivery Lines', scope='C', cols='''
DELIVERY_ID     ID   NN >SAL_DELIVERY | التسليم
LINE_NO         INT  NN          | السطر
ORDER_LINE_ID   ID   >SAL_ORDER_LINE | سطر الأمر
ITEM_ID         ID   >INV_ITEM   | الصنف
QUANTITY        QTY  NN          | الكمية
UOM_ID          ID   NN >INV_UOM | الوحدة
LOCATION_ID     ID   >INV_LOCATION | الموقع
LOT_ID          ID   >INV_LOT    | الدفعة
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
INVOICED_QTY    QTY  NN D=0      | المفوتر
''', uk=[('DELIVERY_ID', 'LINE_NO')], area='delivery')

table('SAL_INVOICE', 'فواتير المبيعات', 'Sales Invoices', scope='C', mix='pub branch doc cur wf posted status',
      status='DRAFT SUBMITTED APPROVED ISSUED POSTED PARTIALLY_PAID PAID CANCELLED CREDITED', cols='''
DOC_TYPE        CODE NN D='INVOICE' IN:INVOICE,SIMPLIFIED_INVOICE,CREDIT_NOTE,DEBIT_NOTE,PROFORMA | النوع
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | العميل
ORDER_ID        ID   >SAL_ORDER  | الأمر
ORIGINAL_INVOICE_ID ID >SAL_INVOICE | الفاتورة الأصلية للإشعار
RETURN_AUTH_ID  ID   >SAL_RETURN_AUTH | ترخيص المرتجع
PAYMENT_TERM_ID ID   >REF_PAYMENT_TERM | شروط الدفع
DUE_DATE        DATE             | الاستحقاق
SUPPLY_DATE     DATE             | تاريخ التوريد
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
CUSTOMER_NAME_SNAPSHOT NAME NN   | اسم العميل وقت الإصدار
CUSTOMER_TAX_NO_SNAPSHOT V50     | الرقم الضريبي للعميل وقت الإصدار
CUSTOMER_ADDRESS_SNAPSHOT V1000  | عنوان العميل وقت الإصدار
SELLER_TAX_REG_ID ID >ORG_LEGAL_REGISTRATION | تسجيل البائع الضريبي المستخدم
SUBTOTAL        AMT  NN D=0      | قبل الضريبة
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
TAX_AMOUNT      AMT  NN D=0      | الضريبة
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي
TOTAL_FUNC      AMT              | الإجمالي الوظيفي
EINVOICE_STATUS CODE NN D='NOT_REQUIRED' IN:NOT_REQUIRED,PENDING,SUBMITTED,ACCEPTED,CLEARED,REJECTED,FAILED | حالة الفوترة الإلكترونية
EINVOICE_SUBMISSION_ID ID >LOC_EINVOICE_SUBMISSION | الإرسال
LEGAL_DOCUMENT_ID ID >DMS_DOCUMENT | النسخة القانونية المحفوظة
ISSUED_AT       TS               | وقت الإصدار
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع الصرف
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة الصرف
PAYMENT_MODE    CODE NN D='CREDIT' IN:CREDIT,CASH | آجل أو نقدي
SETTLE_PLACE    V30              | الصندوق/البنك للفاتورة النقدية (BOX:n / BANK:n)
COGS_AMOUNT     AMT  NN D=0      | تكلفة البضاعة المباعة
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز الربحية
PRESCRIPTION_NO V50              | رقم الوصفة الطبية (للأدوية الوصفية)
''', ix=[('TENANT_ID', 'COMPANY_ID', 'CUSTOMER_ACCOUNT_ID', 'STATUS_CODE'), ('TENANT_ID', 'COMPANY_ID', 'DOC_DATE')],
      area='invoice', purpose='POSTED_AT يملؤه محرك الترحيل لا نموذج APEX؛ لا تعدل الفاتورة المرسلة (45.1)')

table('SAL_INVOICE_LINE', 'أسطر فواتير المبيعات', 'Sales Invoice Lines', scope='C', cols='''
INVOICE_ID      ID   NN >SAL_INVOICE | الفاتورة
LINE_NO         INT  NN          | السطر
LINE_TYPE       CODE NN D='ITEM' IN:ITEM,SERVICE,FREIGHT,CHARGE,DISCOUNT,ADVANCE_DEDUCTION,RETENTION | النوع
ITEM_ID         ID   >INV_ITEM   | الصنف
DESCRIPTION     V1000 NN         | الوصف
QUANTITY        QTY  NN          | الكمية
UOM_ID          ID   >INV_UOM    | الوحدة
UNIT_PRICE      AMT  NN          | السعر
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
NET_AMOUNT      AMT  NN          | الصافي
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
TAX_AMOUNT      AMT  NN D=0      | مبلغ الضريبة
ORDER_LINE_ID   ID   >SAL_ORDER_LINE | سطر الأمر
DELIVERY_LINE_ID ID  >SAL_DELIVERY_LINE | سطر التسليم
ORIGINAL_LINE_ID ID  >SAL_INVOICE_LINE | السطر الأصلي للإشعار
REVENUE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الإيراد
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
WBS_ID          ID   >PRJ_WBS    | بند العمل
UNIT_COST       AMT              | تكلفة الوحدة (للهامش)
''', uk=[('INVOICE_ID', 'LINE_NO')], area='invoice')

table('SAL_RETURN_AUTH', 'تراخيص المرتجعات', 'Return Authorizations (RMA)', scope='C', mix='doc wf status',
      status='DRAFT APPROVED RECEIVED INSPECTED CREDITED CLOSED REJECTED CANCELLED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | العميل
ORIGINAL_INVOICE_ID ID >SAL_INVOICE | الفاتورة الأصلية
REASON_CODE     CODE NN          | السبب
RESOLUTION      CODE NN D='CREDIT' IN:CREDIT,REPLACE,REPAIR,REFUND | المعالجة
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع الاستلام
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة المخزون
''', area='return')

table('SAL_RETURN_AUTH_LINE', 'أسطر تراخيص المرتجعات', 'RMA Lines', scope='C', cols='''
RETURN_AUTH_ID  ID   NN >SAL_RETURN_AUTH | الترخيص
LINE_NO         INT  NN          | السطر
INVOICE_LINE_ID ID   >SAL_INVOICE_LINE | سطر الفاتورة
ITEM_ID         ID   >INV_ITEM   | الصنف
QUANTITY        QTY  NN          | الكمية (لا تتجاوز المسلم بعد المرتجعات السابقة)
UOM_ID          ID   NN >INV_UOM | الوحدة
CONDITION_CODE  CODE IN:RESALEABLE,DAMAGED,DEFECTIVE,EXPIRED | حالة البضاعة
LOT_ID          ID   >INV_LOT    | الدفعة
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
''', uk=[('RETURN_AUTH_ID', 'LINE_NO')], chk=['QUANTITY > 0'], area='return')

# =============================================================== POS
table('POS_TERMINAL', 'محطات نقاط البيع', 'POS Terminals', scope='C', mix='code names branch status', status='ACTIVE SUSPENDED RETIRED', cols='''
SITE_ID         ID   >ORG_BUSINESS_SITE | المتجر/المعرض
WAREHOUSE_ID    ID   NN >INV_WAREHOUSE | مستودع الصرف
CASH_BOX_ID     ID   >CSH_CASH_BOX | درج النقد الافتراضي
BANK_ACCOUNT_ID ID   >CSH_BANK_ACCOUNT | حساب تسوية البطاقات والتطبيقات البنكية
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز الربحية
PRICE_LIST_ID   ID   >SAL_PRICE_LIST | قائمة الأسعار
DEVICE_FINGERPRINT HASH          | بصمة الجهاز
OFFLINE_ALLOWED YN   NN D='N'    | يسمح بالعمل دون اتصال
OFFLINE_MAX_HOURS INT            | أقصى مدة دون اتصال
OFFLINE_MAX_AMOUNT AMT           | أقصى مبيعات دون اتصال
LOCAL_NUMBER_PREFIX V20          | بادئة الترقيم المحلي الفريد
EINVOICE_PROFILE_ID ID >LOC_EINVOICE_PROFILE | إعداد الفوترة الإلكترونية
''', area='pos')

table('POS_SHIFT', 'ورديات نقاط البيع', 'POS Shifts', scope='C', mix='status', status='OPEN SUSPENDED CLOSING CLOSED RECONCILED', cols='''
TERMINAL_ID     ID   NN >POS_TERMINAL | المحطة
CASHIER_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | الكاشير
CASH_BOX_ID     ID   NN >CSH_CASH_BOX | الدرج
OPENED_AT       TS   NN D=SYSTIMESTAMP | الفتح
CLOSED_AT       TS               | الإغلاق
OPENING_FLOAT   AMT  NN D=0      | العهدة الافتتاحية
EXPECTED_CASH   AMT  @CALC       | النقد المتوقع
COUNTED_CASH    AMT              | النقد المعدود
VARIANCE_AMOUNT AMT  @CALC       | الفرق
SUPERVISOR_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المشرف المعتمد للإغلاق
SALES_TOTAL     AMT  NN D=0      | إجمالي المبيعات
GL_JOURNAL_ID   ID   >GL_JOURNAL | قيد الوردية
''', ix=[('TENANT_ID', 'TERMINAL_ID', 'STATUS_CODE')], area='pos')

table('POS_SALE', 'مبيعات نقاط البيع', 'POS Sales / Receipts', scope='C', mix='pub branch cur posted status',
      status='OPEN SUSPENDED COMPLETED VOIDED RETURNED PARTIALLY_RETURNED', cols='''
SHIFT_ID        ID   NN >POS_SHIFT | الوردية
TERMINAL_ID     ID   NN >POS_TERMINAL | المحطة
RECEIPT_NO      V50  NN          | رقم الإيصال
LOCAL_RECEIPT_NO V60             | الرقم المحلي الفريد (Offline)
SALE_TYPE       CODE NN D='SALE' IN:SALE,RETURN,EXCHANGE | النوع
ORIGINAL_SALE_ID ID  >POS_SALE   | البيع الأصلي للمرتجع
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | العميل المسجل (فارغ = عميل عام)
SALE_AT         TS   NN          | وقت البيع
IS_OFFLINE      YN   NN D='N'    | تم دون اتصال
SYNCED_AT       TS               | وقت المزامنة
SYNC_IDEMPOTENCY_KEY V100 NN     | مفتاح المزامنة (يمنع البيع المكرر)
SUBTOTAL        AMT  NN D=0      | قبل الضريبة
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
TAX_AMOUNT      AMT  NN D=0      | الضريبة
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي
PAID_AMOUNT     AMT  NN D=0      | المدفوع
CHANGE_AMOUNT   AMT  NN D=0      | الباقي
SALES_INVOICE_ID ID  >SAL_INVOICE | الفاتورة المبسطة/الضريبية
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة الصرف
PRESCRIPTION_NO V50              | رقم الوصفة الطبية
''', uk=[('TENANT_ID', 'COMPANY_ID', 'RECEIPT_NO'), ('TENANT_ID', 'SYNC_IDEMPOTENCY_KEY')],
      ix=[('TENANT_ID', 'SHIFT_ID')], area='pos')

table('POS_SALE_LINE', 'أسطر مبيعات نقاط البيع', 'POS Sale Lines', scope='C', cols='''
SALE_ID         ID   NN >POS_SALE | البيع
LINE_NO         INT  NN          | السطر
ITEM_ID         ID   NN >INV_ITEM | الصنف
BARCODE_SCANNED V100             | الباركود الممسوح
QUANTITY        QTY  NN          | الكمية (أو الوزن من الميزان)
UOM_ID          ID   NN >INV_UOM | الوحدة
UNIT_PRICE      AMT  NN          | السعر
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
DISCOUNT_RULE_ID ID  >SAL_DISCOUNT_RULE | قاعدة الخصم
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
TAX_AMOUNT      AMT  NN D=0      | الضريبة
LINE_TOTAL      AMT  NN          | الإجمالي
LOT_ID          ID   >INV_LOT    | الدفعة
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
UNIT_COST       AMT              | تكلفة الوحدة عند البيع
ORIGINAL_LINE_ID ID  >POS_SALE_LINE | سطر البيع الأصلي (للمرتجع)
''', uk=[('SALE_ID', 'LINE_NO')], area='pos')

table('POS_PAYMENT', 'مدفوعات نقاط البيع', 'POS Payments', scope='C', mix='status', status='PENDING APPROVED DECLINED REFUNDED', cols='''
SALE_ID         ID   NN >POS_SALE | البيع
PAYMENT_METHOD_ID ID NN >REF_PAYMENT_METHOD | الطريقة (نقد، بطاقة، محفظة، مختلط)
AMOUNT          AMT  NN          | المبلغ
CARD_TOKEN_REF  V200             | مرجع Token (لا تخزن بيانات البطاقة)
CARD_LAST4      V4               | آخر 4 أرقام
APPROVAL_CODE   V50              | رمز الموافقة
TERMINAL_REFERENCE V100          | مرجع جهاز الدفع
''', area='pos')

table('POS_CASH_MOVEMENT', 'حركات الدرج النقدية', 'Drawer Cash Movements', scope='C', append=True, cols='''
SHIFT_ID        ID   NN >POS_SHIFT | الوردية
MOVEMENT_TYPE   CODE NN IN:FLOAT_IN,CASH_IN,CASH_OUT,SAFE_DROP,PAYOUT | النوع
AMOUNT          AMT  NN          | المبلغ
REASON          V500             | السبب
APPROVED_BY_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المشرف
''', area='pos')

table('POS_OVERRIDE', 'موافقات المشرف السريعة', 'Supervisor Overrides', scope='C', append=True, cols='''
SALE_ID         ID   >POS_SALE   | البيع
SHIFT_ID        ID   NN >POS_SHIFT | الوردية
OVERRIDE_TYPE   CODE NN IN:PRICE_CHANGE,DISCOUNT_ABOVE_LIMIT,VOID_LINE,VOID_SALE,RETURN_NO_RECEIPT,NEGATIVE_STOCK,DRAWER_OPEN | النوع
SUPERVISOR_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | المشرف
REASON          V500 NN          | السبب
OLD_VALUE       V200             | القيمة السابقة
NEW_VALUE       V200             | القيمة الجديدة
''', area='pos', purpose='الاستثناءات الحساسة بموافقة مشرف موثقة بدل دورة أمر البيع')
