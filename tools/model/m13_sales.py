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

# =============================================================== التسعير الموحد: التكلفة، سياسات سعر البيع، إعادة التسعير، العروض، الباقات
# الهدف (TARGET_TYPE): صنف، فئة أصناف، خدمة طبية، نوع خدمة طبية، خدمة سيارات، فئة خدمات سيارات، الكل
table('SAL_COST_ELEMENT', 'عناصر تكلفة الخدمة', 'Service Cost Elements', scope='C', mix='sort', cols='''
TARGET_TYPE     CODE NN IN:HIS_SERVICE,AUT_SERVICE,ITEM | الخدمة أو الصنف
TARGET_ID       ID   NN          | المعرف
ELEMENT_TYPE    CODE NN IN:MATERIAL,LABOR,OVERHEAD_AMOUNT,OVERHEAD_PCT,OTHER | نوع العنصر
DESCRIPTION     V200             | البيان
ITEM_ID         ID   >INV_ITEM   | المادة (للمواد)
QUANTITY        QTY              | الكمية (للمواد)
MINUTES         NUM              | الدقائق (للعمالة)
HOURLY_RATE     AMT              | تكلفة الساعة (للعمالة)
AMOUNT          AMT              | المبلغ (أعباء ثابتة وأخرى)
PCT             PCT              | النسبة من التكلفة المباشرة (أعباء نسبية)
''', ix=[('TENANT_ID', 'COMPANY_ID', 'TARGET_TYPE', 'TARGET_ID')], chk=['NVL(QUANTITY, 0) >= 0', 'NVL(AMOUNT, 0) >= 0'], area='pricing',
      purpose='تكلفة الخدمة = مواد الخدمة المعرفة في موديولها + هذه العناصر (مواد إضافية، عمالة بالدقائق، أعباء ثابتة أو نسبة)')

table('SAL_PRICING_POLICY', 'سياسات التسعير', 'Pricing Policies', scope='C', mix='code names eff status', status='ACTIVE INACTIVE', cols='''
TARGET_TYPE     CODE NN IN:ITEM,ITEM_CATEGORY,ALL_ITEMS,HIS_SERVICE,HIS_SERVICE_TYPE,ALL_HIS,AUT_SERVICE,AUT_CATEGORY,ALL_AUT | ينطبق على
TARGET_ID       ID               | الصنف/الفئة/الخدمة
TARGET_CODE     V50              | النوع (لأنواع الخدمات الطبية)
COST_BASIS      CODE NN D='AVERAGE' IN:AVERAGE,LAST_PURCHASE,STANDARD,COST_SHEET | أساس التكلفة
METHOD          CODE NN D='MARKUP_PCT' IN:MARKUP_PCT,MARGIN_PCT,FIXED_AMOUNT,MULTIPLIER | طريقة حساب سعر البيع
METHOD_VALUE    NUM  NN          | النسبة أو المبلغ أو المعامل
MIN_MARGIN_PCT  PCT              | أدنى هامش (يحدد أدنى سعر بيع دون موافقة)
ROUNDING        CODE NN D='NONE' IN:NONE,R005,R025,R050,R1,R5,R10,END99 | التقريب
PRIORITY_NO     INT  NN D=100    | الأولوية (الأصغر أولاً عند التعارض)
''', chk=['METHOD_VALUE >= 0', "METHOD <> 'MARGIN_PCT' OR METHOD_VALUE < 100"], area='pricing')

table('SAL_PRICE_RUN', 'تشغيلات إعادة التسعير', 'Repricing Runs', scope='C', mix='doc status', status='DRAFT APPLIED CANCELLED', cols='''
SCOPE_TYPE      CODE NN IN:ITEMS,HIS,AUT,ALL | النطاق
ONLY_CHANGED    YN   NN D='Y'    | الأسطر التي يتغير سعرها فقط
LINES_COUNT     INT  NN D=0      | عدد الأسطر
APPLIED_COUNT   INT  NN D=0      | المطبق
APPLIED_BY      USR              | طبقها
APPLIED_AT      TS               | وقت التطبيق
''', area='pricing')

table('SAL_PRICE_RUN_LINE', 'أسطر إعادة التسعير', 'Repricing Run Lines', scope='C', cols='''
RUN_ID          ID   NN >SAL_PRICE_RUN | التشغيل
TARGET_TYPE     CODE NN IN:ITEM,HIS_SERVICE,AUT_SERVICE | النوع
TARGET_ID       ID   NN          | المعرف
POLICY_ID       ID   >SAL_PRICING_POLICY | السياسة
COST_AMOUNT     AMT              | التكلفة
OLD_PRICE       AMT              | السعر الحالي
NEW_PRICE       AMT              | السعر المقترح
NEW_MIN_PRICE   AMT              | أدنى سعر مقترح
MARGIN_PCT      PCT              | الهامش بالسعر المقترح
IS_SELECTED     YN   NN D='Y'    | يطبق
''', uk=[('RUN_ID', 'TARGET_TYPE', 'TARGET_ID')], area='pricing')

table('SAL_PRICE_HISTORY', 'سجل تغيير الأسعار', 'Price Change History', scope='C', append=True, cols='''
TARGET_TYPE     CODE NN IN:ITEM,HIS_SERVICE,AUT_SERVICE | النوع
TARGET_ID       ID   NN          | المعرف
OLD_PRICE       AMT              | السعر السابق
NEW_PRICE       AMT              | السعر الجديد
COST_AMOUNT     AMT              | التكلفة وقت التغيير
SOURCE_CODE     CODE NN IN:RUN,MANUAL | المصدر
RUN_ID          ID   >SAL_PRICE_RUN | تشغيل إعادة التسعير
''', ix=[('TENANT_ID', 'COMPANY_ID', 'TARGET_TYPE', 'TARGET_ID')], area='pricing')

table('SAL_PROMOTION', 'العروض والتخفيضات', 'Promotions & Discounts', scope='C', mix='code names eff status',
      status='DRAFT ACTIVE PAUSED EXPIRED CANCELLED', cols='''
PROMO_TYPE      CODE NN IN:PCT_OFF,AMOUNT_OFF,FIXED_PRICE,BUY_X_GET_Y,SPEND_PCT,SPEND_AMOUNT | النوع
PROMO_VALUE     NUM  NN D=0      | النسبة أو المبلغ أو السعر الخاص
BUY_QTY         QTY              | اشتر (كمية)
GET_QTY         QTY              | واحصل مجاناً على (كمية)
MIN_QTY         QTY              | أدنى كمية للسطر
MIN_AMOUNT      AMT              | أدنى قيمة للفاتورة (لعروض قيمة الشراء)
MAX_DISCOUNT    AMT              | أقصى خصم للعملية
CHANNELS        V200             | القنوات (POS,SALES,HIS,AUT,RST) فارغ = الكل
BRANCH_ID       ID   >ORG_BRANCH | الفرع (فارغ = كل الفروع)
DAYS_OF_WEEK    V20              | أيام الأسبوع 1-7 (1 = الأحد) فارغ = كل الأيام
HOUR_FROM       INT              | من الساعة
HOUR_TO         INT              | إلى الساعة
COUPON_CODE     V50              | كود الكوبون (فارغ = تلقائي)
PRIORITY_NO     INT  NN D=100    | الأولوية
STACKABLE       YN   NN D='N'    | يجمع مع عروض أخرى
DAYS_OF_MONTH   V100             | أيام الشهر (1-5,25-31) فارغ = كل الأيام
EXCLUDED_DATES  V1000            | تواريخ مستثناة (عطلات) YYYY-MM-DD مفصولة بفواصل
BRANCH_IDS      V400             | الفروع (معرفات مفصولة بفواصل) فارغ = كل الفروع
CUSTOMER_SCOPE  CODE NN D='ALL' IN:ALL,REGISTERED,NEW,LIST | العملاء: الكل، المسجلون، الجدد (أول شراء)، عملاء محددون
CUSTOMER_IDS    V1000            | حسابات العملاء المحددين (مفصولة بفواصل)
MAX_USES        INT              | أقصى عدد استخدامات للعرض (فواتير)
MAX_USES_PER_CUSTOMER INT        | أقصى استخدام لكل عميل
''', chk=['PROMO_VALUE >= 0', 'MAX_USES IS NULL OR MAX_USES > 0', 'MAX_USES_PER_CUSTOMER IS NULL OR MAX_USES_PER_CUSTOMER > 0', "PROMO_TYPE NOT IN ('PCT_OFF','SPEND_PCT') OR PROMO_VALUE <= 100",
            "PROMO_TYPE <> 'BUY_X_GET_Y' OR (BUY_QTY > 0 AND GET_QTY > 0)", 'HOUR_FROM IS NULL OR HOUR_FROM BETWEEN 0 AND 23',
            'HOUR_TO IS NULL OR HOUR_TO BETWEEN 0 AND 24'], area='pricing')

table('SAL_PROMOTION_USE', 'استخدامات العروض', 'Promotion Usage', scope='C', cols='''
PROMOTION_ID    ID   NN >SAL_PROMOTION | العرض
CHANNEL_CODE    CODE NN IN:POS,SALES,HIS,AUT,RST | القناة
DOC_TYPE        CODE NN          | نوع المستند
DOC_ID          ID   NN          | المستند
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | العميل
DISCOUNT_AMOUNT AMT  NN D=0      | قيمة الخصم
USED_AT         TS   NN D=SYSTIMESTAMP | وقت الاستخدام
''', uk=[('TENANT_ID', 'PROMOTION_ID', 'DOC_TYPE', 'DOC_ID')], ix=[('TENANT_ID', 'COMPANY_ID', 'PROMOTION_ID', 'CUSTOMER_ACCOUNT_ID')],
      area='pricing')

table('SAL_PROMOTION_TARGET', 'أصناف وخدمات العرض', 'Promotion Targets', scope='C', cols='''
PROMOTION_ID    ID   NN >SAL_PROMOTION | العرض
TARGET_TYPE     CODE NN IN:ITEM,ITEM_CATEGORY,ALL_ITEMS,HIS_SERVICE,HIS_SERVICE_TYPE,ALL_HIS,AUT_SERVICE,AUT_CATEGORY,ALL_AUT | النوع
TARGET_ID       ID               | المعرف
TARGET_CODE     V50              | النوع (لأنواع الخدمات الطبية)
''', ix=[('TENANT_ID', 'COMPANY_ID', 'PROMOTION_ID')], area='pricing')

table('SAL_BUNDLE', 'الباقات', 'Bundles & Packages', scope='C', mix='code names desc eff status', status='DRAFT ACTIVE INACTIVE', cols='''
CHANNELS        V200             | القنوات (POS,SALES,HIS,AUT,RST) فارغ = الكل
PRICING_METHOD  CODE NN D='FIXED_PRICE' IN:FIXED_PRICE,PCT_OFF,AMOUNT_OFF | طريقة سعر الباقة
PRICING_VALUE   NUM  NN          | السعر أو النسبة أو المبلغ
PRICE_INCLUDES_TAX YN NN D='N'   | السعر شامل الضريبة
''', chk=['PRICING_VALUE >= 0', "PRICING_METHOD <> 'PCT_OFF' OR PRICING_VALUE <= 100"], area='pricing')

table('SAL_BUNDLE_LINE', 'مكونات الباقة', 'Bundle Components', scope='C', mix='sort', cols='''
BUNDLE_ID       ID   NN >SAL_BUNDLE | الباقة
TARGET_TYPE     CODE NN IN:ITEM,HIS_SERVICE,AUT_SERVICE | النوع
TARGET_ID       ID   NN          | الصنف أو الخدمة
QUANTITY        QTY  NN D=1      | الكمية
''', uk=[('BUNDLE_ID', 'TARGET_TYPE', 'TARGET_ID')], chk=['QUANTITY > 0'], area='pricing')

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

# =============================================================== المطاعم والكافتريا (على محرك نقاط البيع)
table('RST_AREA', 'صالات المطعم', 'Restaurant Dining Areas', scope='C', mix='code names status', status='ACTIVE INACTIVE', cols='''
TERMINAL_ID     ID   >POS_TERMINAL | نقطة البيع التي تحاسب طاولات الصالة
SORT_ORDER      INT  NN D=0      | الترتيب
''', area='rst')

table('RST_TABLE', 'طاولات المطعم', 'Restaurant Tables', scope='C', mix='code names status', status='ACTIVE INACTIVE', cols='''
AREA_ID         ID   NN >RST_AREA | الصالة
SEATS           INT  NN D=4      | عدد المقاعد
SHAPE           CODE NN D='SQUARE' IN:SQUARE,ROUND,LONG,BOOTH | الشكل
SORT_ORDER      INT  NN D=0      | الترتيب
''', ix=[('TENANT_ID', 'AREA_ID')], area='rst')

table('RST_ORDER', 'طلبات المطعم', 'Restaurant Orders', scope='C', mix='branch status', status='OPEN BILLED PAID CHARGED CANCELLED', cols='''
ORDER_NO        V50  NN          | رقم الطلب
ORDER_TYPE      CODE NN D='DINE_IN' IN:DINE_IN,TAKEAWAY,DELIVERY | النوع (صالة، سفري، توصيل)
TERMINAL_ID     ID   NN >POS_TERMINAL | نقطة البيع
TABLE_ID        ID   >RST_TABLE  | الطاولة
GUESTS          INT              | عدد الأشخاص
WAITER_NAME     V100             | النادل
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | العميل (للآجل)
CUSTOMER_NAME   V200             | اسم العميل/صاحب الطلب
CUSTOMER_PHONE  V30              | الجوال
DELIVERY_ADDRESS V500            | عنوان التوصيل
OPENED_AT       TS   NN D=SYSTIMESTAMP | وقت الفتح
BILLED_AT       TS               | وقت طباعة الحساب
CLOSED_AT       TS               | وقت السداد/الإقفال
KITCHEN_ROUND   INT  NN D=0      | آخر دفعة للمطبخ
DISCOUNT_PCT    PCT              | نسبة الخصم على الحساب
SUBTOTAL        AMT  NN D=0      | قبل الضريبة
TAX_AMOUNT      AMT  NN D=0      | الضريبة
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي
SETTLE_MODE     CODE IN:PAID,CREDIT,MIXED | طريقة الإقفال (مدفوع، آجل، مختلط)
POS_SALE_ID     ID   >POS_SALE   | إيصال نقطة البيع
CANCEL_REASON   V500             | سبب الإلغاء
NOTES           V500             | ملاحظات
''', uk=[('TENANT_ID', 'COMPANY_ID', 'ORDER_NO')], ix=[('TENANT_ID', 'TABLE_ID', 'STATUS_CODE'), ('TENANT_ID', 'POS_SALE_ID')], area='rst')

table('RST_ORDER_LINE', 'أصناف طلبات المطعم', 'Restaurant Order Lines', scope='C', cols='''
ORDER_ID        ID   NN >RST_ORDER | الطلب
LINE_NO         INT  NN          | السطر
ITEM_ID         ID   NN >INV_ITEM | الصنف
QUANTITY        QTY  NN          | الكمية
UNIT_PRICE      AMT  NN          | سعر الوحدة شامل الضريبة
LINE_TOTAL      AMT  NN          | الإجمالي شامل الضريبة
NOTES           V200             | ملاحظات التحضير (بدون بصل، حار...)
KITCHEN_STATUS  CODE NN D='NEW' IN:NEW,SENT,READY,SERVED,VOID | حالة المطبخ
ROUND_NO        INT              | دفعة الإرسال للمطبخ
SENT_AT         TS               | وقت الإرسال
READY_AT        TS               | وقت الجاهزية
VOID_REASON     V200             | سبب الإلغاء
''', uk=[('ORDER_ID', 'LINE_NO')], chk=['QUANTITY > 0'], area='rst')
