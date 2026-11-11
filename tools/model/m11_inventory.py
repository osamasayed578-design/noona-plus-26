from model.dsl import module, table

module(11, 'INV', 'المخزون والبيانات السلعية', 'Inventory & Item Master', 'NOONA_INVENTORY_PKG',
       'الأصناف والوحدات وتحويلاتها المؤرخة، والمستودعات والمواقع، وتتبع Lot/Serial/Expiry، وحركات '
       'المخزون غير القابلة للتعديل (تصحح بعكس)، والحجوزات، وطبقات تكلفة FIFO والمتوسط المرجح، والجرد.')

table('INV_UOM_CLASS', 'فئات وحدات القياس', 'UOM Classes', scope='TO', mix='code names active', area='uom')

table('INV_UOM', 'وحدات القياس', 'Units of Measure', scope='TO', mix='code names active', cols='''
UOM_CLASS_ID    ID   NN >INV_UOM_CLASS | الفئة (وزن، طول، عدد...)
IS_BASE_OF_CLASS YN  NN D='N'    | الوحدة الأساسية للفئة
DECIMAL_PLACES  INT  NN D=2      | الدقة
''', area='uom')

table('INV_UOM_CONVERSION', 'تحويلات الوحدات', 'UOM Conversions', scope='T', mix='eff', cols='''
ITEM_ID         ID   >INV_ITEM   | الصنف (فارغ = تحويل عام)
FROM_UOM_ID     ID   NN >INV_UOM | من وحدة
TO_UOM_ID       ID   NN >INV_UOM | إلى وحدة
FACTOR          RATE NN          | المعامل
VERSION_NO      INT  NN D=1      | الإصدار (لا يتغير معامل استعمل تاريخياً)
''', uk=[('TENANT_ID', 'ITEM_ID', 'FROM_UOM_ID', 'TO_UOM_ID', 'VERSION_NO')], chk=['FACTOR > 0', 'FROM_UOM_ID <> TO_UOM_ID'],
      area='uom')

table('INV_ITEM_CATEGORY', 'فئات الأصناف', 'Item Categories', scope='T', mix='code names active', cols='''
PARENT_CATEGORY_ID ID >INV_ITEM_CATEGORY | الفئة الأم
DEFAULT_COSTING_METHOD CODE IN:FIFO,WEIGHTED_AVERAGE,STANDARD | طريقة التكلفة الافتراضية
DEFAULT_TAX_CODE_ID ID >LOC_TAX_CODE | الضريبة الافتراضية
PRODUCT_PROFILE CODE NN D='GENERAL' IN:GENERAL,AUTO_PART,PHARMA,FOOD,ELECTRONICS,APPAREL,RAW_MATERIAL | ملف الأصناف الافتراضي
INVENTORY_ACCOUNT_ID ID >GL_ACCOUNT | حساب المخزون الافتراضي للفئة
COGS_ACCOUNT_ID ID   >GL_ACCOUNT | حساب تكلفة المبيعات
REVENUE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الإيراد
EXPENSE_ACCOUNT_ID ID >GL_ACCOUNT | حساب المصروف (الأصناف غير المخزنية والخدمات)
''', area='item')

table('INV_ITEM', 'الأصناف', 'Items', scope='T', mix='pub names desc status', status='DRAFT ACTIVE INACTIVE OBSOLETE BLOCKED', cols='''
ITEM_NO         V50  NN U        | رقم الصنف
ITEM_TYPE       CODE NN IN:STOCK,NON_STOCK,SERVICE,RAW_MATERIAL,SEMI_FINISHED,FINISHED_GOOD,CONSUMABLE,SPARE_PART,KIT,ASSET,REAL_ESTATE_UNIT | النوع
CATEGORY_ID     ID   NN >INV_ITEM_CATEGORY | الفئة
BASE_UOM_ID     ID   NN >INV_UOM | الوحدة الأساسية
TRACKING_MODE   CODE NN D='NONE' IN:NONE,LOT,SERIAL,LOT_AND_SERIAL | التتبع
TRACK_EXPIRY    YN   NN D='N'    | تتبع الصلاحية
SHELF_LIFE_DAYS INT              | مدة الصلاحية
SERVICE_LIFE_KM NUM              | عمر الاستبدال بالكيلومتر (قطع الغيار والزيوت والإطارات)
SERVICE_LIFE_DAYS INT            | عمر الاستبدال بالأيام
OWNERSHIP_SCOPE CODE NN D='TENANT_SHARED' IN:TENANT_SHARED,GROUP_SHARED,COMPANY_OWNED | نطاق الملكية
OWNER_COMPANY_ID ID  >ORG_COMPANY | الشركة المالكة
IS_SELLABLE     YN   NN D='Y'    | قابل للبيع
IS_PURCHASABLE  YN   NN D='Y'    | قابل للشراء
IS_MANUFACTURED YN   NN D='N'    | مصنع داخلياً
ALLOW_NEGATIVE  YN   NN D='N'    | يسمح بالرصيد السالب (ممنوع افتراضياً)
WEIGHT_KG       QTY              | الوزن
TAX_CATEGORY    CODE             | الفئة الضريبية
STORAGE_REQUIREMENTS V500        | متطلبات التخزين (حرارة، جودة)
ATTRIBUTES      JSON             | خصائص إضافية
ITEM_CODE       V50              | الكود المختصر (داخلي/SKU)
PRODUCT_PROFILE CODE NN D='GENERAL' IN:GENERAL,AUTO_PART,PHARMA,FOOD,ELECTRONICS,APPAREL,RAW_MATERIAL | ملف الصنف (يحدد الحقول الخاصة)
BRAND           V100             | العلامة التجارية
MANUFACTURER    V200             | الشركة المصنعة
MANUFACTURER_PART_NO V100        | رقم القطعة لدى المصنع (OEM)
GENERIC_NAME    V200             | المادة الفعالة / الاسم العلمي
STRENGTH        V100             | التركيز
DOSAGE_FORM     V100             | الشكل الصيدلاني
REQUIRES_PRESCRIPTION YN NN D='N' | يصرف بوصفة طبية
REGULATORY_REG_NO V100           | رقم التسجيل لدى الجهة الرقابية
''', ix=[('TENANT_ID', 'CATEGORY_ID'), ('TENANT_ID', 'NAME_AR'), ('TENANT_ID', 'MANUFACTURER_PART_NO'), ('TENANT_ID', 'GENERIC_NAME')],
      nuk=[('TENANT_ID', 'ITEM_CODE')], area='item')

table('INV_ITEM_FITMENT', 'توافق قطع الغيار مع المركبات', 'Spare Part Vehicle Fitment', scope='T', cols='''
ITEM_ID         ID   NN >INV_ITEM | القطعة
VEHICLE_MAKE    V100 NN          | الشركة المصنعة للمركبة
VEHICLE_MODEL   V100             | الطراز
YEAR_FROM       INT              | من سنة
YEAR_TO         INT              | إلى سنة
ENGINE          V100             | المحرك
NOTES           V500             | ملاحظات
''', ix=[('TENANT_ID', 'VEHICLE_MAKE', 'VEHICLE_MODEL')], area='item')

table('INV_ITEM_ALTERNATE', 'البدائل والأصناف المكافئة', 'Item Alternates', scope='T', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
ALT_ITEM_ID     ID   NN >INV_ITEM | البديل
ALT_TYPE        CODE NN D='SUBSTITUTE' IN:SUBSTITUTE,OEM_EQUIVALENT,GENERIC_EQUIVALENT,UPGRADE | نوع البدل
NOTES           V500             | ملاحظات
''', uk=[('ITEM_ID', 'ALT_ITEM_ID')], chk=['ITEM_ID <> ALT_ITEM_ID'], area='item')

table('INV_ITEM_BARCODE', 'باركود الأصناف', 'Item Barcodes', scope='T', mix='active', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
BARCODE         V100 NN          | الباركود
UOM_ID          ID   >INV_UOM    | الوحدة
BARCODE_TYPE    CODE IN:EAN13,EAN8,UPC,CODE128,QR,INTERNAL,SCALE | النوع
''', uk=[('TENANT_ID', 'BARCODE')], area='item')

table('INV_ITEM_COMPANY', 'إعدادات الصنف لكل شركة', 'Item Company Settings', scope='C', mix='active', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
COSTING_METHOD  CODE NN D='WEIGHTED_AVERAGE' IN:FIFO,WEIGHTED_AVERAGE,STANDARD | طريقة التكلفة (مؤرخة عبر Migration فقط)
INVENTORY_ACCOUNT_ID ID >GL_ACCOUNT | حساب المخزون
COGS_ACCOUNT_ID ID   >GL_ACCOUNT | حساب تكلفة المبيعات
REVENUE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الإيراد
PURCHASE_TAX_CODE_ID ID >LOC_TAX_CODE | ضريبة الشراء
SALES_TAX_CODE_ID ID >LOC_TAX_CODE | ضريبة البيع
MIN_QTY         QTY              | الحد الأدنى
MAX_QTY         QTY              | الحد الأعلى
REORDER_QTY     QTY              | كمية إعادة الطلب
LEAD_TIME_DAYS  INT              | مدة التوريد
STANDARD_COST   AMT              | التكلفة المعيارية
EXPENSE_ACCOUNT_ID ID >GL_ACCOUNT | حساب المصروف (غير المخزني والخدمات)
DEFAULT_COST_CENTER_ID ID >GL_COST_CENTER | مركز التكلفة الافتراضي
DEFAULT_WAREHOUSE_ID ID >INV_WAREHOUSE | المستودع الافتراضي
SALE_PRICE      AMT              | سعر البيع
MIN_SALE_PRICE  AMT              | أدنى سعر بيع دون موافقة
LAST_PURCHASE_PRICE AMT          | آخر سعر شراء
PRICES_INCLUDE_TAX YN NN D='N'   | سعر البيع شامل الضريبة
''', uk=[('TENANT_ID', 'COMPANY_ID', 'ITEM_ID')], area='item')

table('INV_WAREHOUSE', 'المستودعات', 'Warehouses', scope='C', mix='code names branch eff status', status='ACTIVE BLOCKED CLOSED', cols='''
SITE_ID         ID   >ORG_BUSINESS_SITE | الموقع
WAREHOUSE_TYPE  CODE NN D='MAIN' IN:MAIN,STORE,TRANSIT,QUARANTINE,CONSIGNMENT,PROJECT_SITE,PRODUCTION,VIRTUAL,DAMAGED | النوع
MANAGER_EMPLOYEE_ID ID >HR_EMPLOYEE | أمين المستودع
PROJECT_ID      ID   >PRJ_PROJECT | المشروع (مستودع موقع)
ALLOW_NEGATIVE  YN   NN D='N'    | يسمح بالسالب
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
''', area='location')

table('INV_LOCATION', 'مواقع التخزين', 'Storage Locations', scope='C', mix='code names active', codeuk=False, cols='''
WAREHOUSE_ID    ID   NN >INV_WAREHOUSE | المستودع
PARENT_LOCATION_ID ID >INV_LOCATION | الموقع الأب (منطقة/ممر/رف)
LOCATION_TYPE   CODE NN D='STORAGE' IN:RECEIVING,STORAGE,QUALITY,PICKING,SHIPPING,DAMAGED,STAGING | النوع
DEFAULT_STOCK_STATUS CODE NN D='AVAILABLE' IN:AVAILABLE,QUALITY,DAMAGED,BLOCKED | الحالة الافتراضية للمخزون
CAPACITY        QTY              | السعة
''', uk=[('WAREHOUSE_ID', 'CODE')], area='location')

table('INV_LOT', 'الدفعات', 'Lots / Batches', scope='T', mix='status', status='ACTIVE QUARANTINE EXPIRED BLOCKED CONSUMED', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
LOT_NO          V100 NN          | رقم الدفعة
SUPPLIER_LOT_NO V100             | رقم دفعة المورد
MANUFACTURE_DATE DATE            | تاريخ الإنتاج
EXPIRY_DATE     DATE             | تاريخ الانتهاء
ORIGIN_COUNTRY  CTRY             | بلد المنشأ
QUALITY_STATUS  CODE NN D='PENDING' IN:PENDING,ACCEPTED,REJECTED | الجودة
''', uk=[('TENANT_ID', 'ITEM_ID', 'LOT_NO')], ix=[('TENANT_ID', 'EXPIRY_DATE')], area='tracking')

table('INV_SERIAL', 'الأرقام التسلسلية', 'Serial Numbers', scope='T', mix='status', status='IN_STOCK RESERVED ISSUED SOLD RETURNED SCRAPPED IN_TRANSIT', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
SERIAL_NO       V100 NN          | الرقم التسلسلي
LOT_ID          ID   >INV_LOT    | الدفعة
OWNER_COMPANY_ID ID  >ORG_COMPANY | الشركة المالكة
CURRENT_WAREHOUSE_ID ID >INV_WAREHOUSE | المستودع الحالي
CURRENT_LOCATION_ID ID >INV_LOCATION | الموقع الحالي
WARRANTY_END    DATE             | نهاية الضمان
''', uk=[('TENANT_ID', 'ITEM_ID', 'SERIAL_NO')], area='tracking')

table('INV_TXN_TYPE', 'أنواع الحركات المخزنية', 'Inventory Transaction Types', scope='TO', mix='code names active', cols='''
TXN_CLASS       CODE NN IN:RECEIPT,ISSUE,TRANSFER_OUT,TRANSFER_IN,ADJUSTMENT_IN,ADJUSTMENT_OUT,COUNT_ADJUSTMENT,RETURN_IN,RETURN_OUT,MFG_ISSUE,MFG_RETURN,MFG_RECEIPT,SCRAP,STATUS_CHANGE,COST_ADJUSTMENT | الفئة
QTY_SIGN        INT  NN          | أثر الكمية (+1/-1/0)
REQUIRES_APPROVAL YN NN D='N'    | يتطلب اعتماداً
DEFAULT_REASON_REQUIRED YN NN D='N' | يتطلب سبباً
''', chk=['QTY_SIGN IN (-1, 0, 1)'], area='transaction')

table('INV_TRANSACTION', 'حركات المخزون', 'Inventory Transactions', scope='C', mix='pub branch doc src wf posted status',
      status='DRAFT APPROVED POSTED REVERSED CANCELLED', cols='''
TXN_TYPE_ID     ID   NN >INV_TXN_TYPE | النوع
WAREHOUSE_ID    ID   NN >INV_WAREHOUSE | المستودع
TO_WAREHOUSE_ID ID   >INV_WAREHOUSE | المستودع المستلم (التحويل)
TRANSFER_ORDER_ID ID >INV_TRANSFER_ORDER | أمر التحويل
ACCOUNTING_DATE DATE NN          | التاريخ المحاسبي (منفصل عن الواقعي)
REASON_CODE     CODE             | السبب
REVERSAL_OF_ID  ID   >INV_TRANSACTION | الحركة المعكوسة
IDEMPOTENCY_KEY V100             | منع ازدواج حركة مصدرها حدث متكرر
''', nuk=[('TENANT_ID', 'IDEMPOTENCY_KEY')],
      ix=[('TENANT_ID', 'WAREHOUSE_ID', 'DOC_DATE'), ('TENANT_ID', 'SOURCE_ENTITY_TYPE', 'SOURCE_ENTITY_ID')], area='transaction',
      purpose='لا تعدل حركة مثبتة؛ تنشأ حركة عكس أو تصحيح')

table('INV_TRANSACTION_LINE', 'أسطر حركات المخزون', 'Inventory Transaction Lines', scope='C', cols='''
TRANSACTION_ID  ID   NN >INV_TRANSACTION | الحركة
LINE_NO         INT  NN          | السطر
ITEM_ID         ID   NN >INV_ITEM | الصنف
LOCATION_ID     ID   >INV_LOCATION | الموقع
LOT_ID          ID   >INV_LOT    | الدفعة
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
QUANTITY        QTY  NN          | الكمية بوحدة الحركة
UOM_ID          ID   NN >INV_UOM | الوحدة
CONVERSION_ID   ID   >INV_UOM_CONVERSION | إصدار التحويل المستخدم
BASE_QUANTITY   QTY  NN          | الكمية بالوحدة الأساسية (موقعة +/-)
UNIT_COST       AMT              | تكلفة الوحدة
TOTAL_COST      AMT              | التكلفة الإجمالية
STOCK_STATUS    CODE NN D='AVAILABLE' IN:AVAILABLE,QUALITY,DAMAGED,BLOCKED,IN_TRANSIT,CONSIGNMENT | حالة المخزون
OWNERSHIP_TYPE  CODE NN D='OWNED' IN:OWNED,CONSIGNMENT_IN,CONSIGNMENT_OUT,THIRD_PARTY | الملكية
COST_LAYER_ID   ID   >INV_COST_LAYER | طبقة FIFO المستهلكة/المنشأة
SOURCE_LINE_REF V100             | مرجع سطر المستند المصدر
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
''', uk=[('TRANSACTION_ID', 'LINE_NO')], ix=[('TENANT_ID', 'ITEM_ID')], area='transaction', ret='دائم؛ مرشح للتقسيم السنوي')

table('INV_ONHAND', 'الأرصدة المتاحة', 'On-hand Balances', scope='C', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
WAREHOUSE_ID    ID   NN >INV_WAREHOUSE | المستودع
LOCATION_ID     ID   >INV_LOCATION | الموقع
LOT_ID          ID   >INV_LOT    | الدفعة
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
STOCK_STATUS    CODE NN D='AVAILABLE' IN:AVAILABLE,QUALITY,DAMAGED,BLOCKED,IN_TRANSIT,CONSIGNMENT | الحالة
ON_HAND_QTY     QTY  NN D=0      | الموجود
RESERVED_QTY    QTY  NN D=0      | المحجوز
LAST_TXN_LINE_ID ID  >INV_TRANSACTION_LINE | آخر حركة
''', uk=[('TENANT_ID', 'ITEM_ID', 'WAREHOUSE_ID', 'LOCATION_ID', 'LOT_ID', 'SERIAL_ID', 'STOCK_STATUS')],
      chk=['RESERVED_QTY >= 0'], area='balance', purpose='رصيد مشتق يعاد بناؤه من الحركات؛ يقفل الصف عند الصرف المتزامن')

table('INV_RESERVATION', 'الحجوزات', 'Reservations', scope='C', mix='src status', status='ACTIVE PARTIALLY_CONSUMED CONSUMED RELEASED EXPIRED', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
WAREHOUSE_ID    ID   NN >INV_WAREHOUSE | المستودع
LOT_ID          ID   >INV_LOT    | الدفعة
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
RESERVED_QTY    QTY  NN          | الكمية (بالأساسية)
CONSUMED_QTY    QTY  NN D=0      | المستهلك
PRIORITY_NO     INT  NN D=100    | الأولوية
EXPIRES_AT      TS               | الانتهاء
OWNER_MEMBER_ID ID   >SEC_USER_MEMBERSHIP | صاحب الطلب
''', ix=[('TENANT_ID', 'ITEM_ID', 'WAREHOUSE_ID', 'STATUS_CODE')], chk=['RESERVED_QTY > 0'], area='balance')

table('INV_COST_LAYER', 'طبقات التكلفة FIFO', 'FIFO Cost Layers', scope='C', mix='status', status='OPEN EXHAUSTED', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
WAREHOUSE_ID    ID   >INV_WAREHOUSE | المستودع (حسب مستوى التكلفة)
RECEIPT_TXN_LINE_ID ID >INV_TRANSACTION_LINE | حركة الاستلام المنشئة (فارغ لطبقة الرصيد القائم عند التحول إلى FIFO)
LAYER_DATE      DATE NN          | تاريخ الطبقة
ORIGINAL_QTY    QTY  NN          | الكمية الأصلية
REMAINING_QTY   QTY  NN          | المتبقي
UNIT_COST       AMT  NN          | تكلفة الوحدة
''', ix=[('TENANT_ID', 'ITEM_ID', 'STATUS_CODE', 'LAYER_DATE')], chk=['REMAINING_QTY >= 0'], area='costing')

table('INV_ITEM_COST', 'متوسط تكلفة الصنف', 'Item Average Cost', scope='C', cols='''
ITEM_ID         ID   NN >INV_ITEM | الصنف
WAREHOUSE_ID    ID   >INV_WAREHOUSE | المستودع
CURRENCY_CODE   CUR  NN          | العملة الوظيفية
ON_HAND_QTY     QTY  NN D=0      | الكمية
TOTAL_VALUE     AMT  NN D=0      | القيمة
AVERAGE_COST    AMT  NN D=0      | المتوسط المرجح
LAST_TXN_LINE_ID ID  >INV_TRANSACTION_LINE | آخر حركة مؤثرة
''', uk=[('TENANT_ID', 'COMPANY_ID', 'ITEM_ID', 'WAREHOUSE_ID')], area='costing')

table('INV_COST_ADJUSTMENT', 'تسويات التكلفة', 'Cost Adjustments & Landed Cost', scope='C', mix='doc wf posted status',
      status='DRAFT APPROVED POSTED CANCELLED', cols='''
ADJUSTMENT_TYPE CODE NN IN:LANDED_COST,PRICE_VARIANCE,REVALUATION,CORRECTION | النوع
RECEIPT_TXN_ID  ID   >INV_TRANSACTION | الاستلام المعني
AP_INVOICE_ID   ID   >AP_INVOICE | فاتورة الشحن/الرسوم
TOTAL_AMOUNT    AMT  NN          | المبلغ
ALLOCATION_BASIS CODE IN:VALUE,QUANTITY,WEIGHT,VOLUME,MANUAL | أساس التوزيع
DETAILS         JSON             | التوزيع على الأسطر
''', area='costing')

table('INV_TRANSFER_ORDER', 'أوامر التحويل بين المستودعات', 'Transfer Orders', scope='C', mix='doc wf status',
      status='DRAFT APPROVED SHIPPED IN_TRANSIT PARTIALLY_RECEIVED RECEIVED CLOSED CANCELLED', cols='''
FROM_WAREHOUSE_ID ID NN >INV_WAREHOUSE | من
TO_WAREHOUSE_ID ID   NN >INV_WAREHOUSE | إلى
TO_COMPANY_ID   ID   >ORG_COMPANY | الشركة المستلمة (يعالج Intercompany)
TRANSIT_WAREHOUSE_ID ID >INV_WAREHOUSE | مستودع العبور
REQUIRED_DATE   DATE             | التاريخ المطلوب
''', chk=['FROM_WAREHOUSE_ID <> TO_WAREHOUSE_ID'], area='transfer')

table('INV_TRANSFER_ORDER_LINE', 'أسطر أوامر التحويل', 'Transfer Order Lines', scope='C', cols='''
TRANSFER_ORDER_ID ID NN >INV_TRANSFER_ORDER | الأمر
LINE_NO         INT  NN          | السطر
ITEM_ID         ID   NN >INV_ITEM | الصنف
UOM_ID          ID   NN >INV_UOM | الوحدة
REQUESTED_QTY   QTY  NN          | المطلوب
SHIPPED_QTY     QTY  NN D=0      | المرسل
RECEIVED_QTY    QTY  NN D=0      | المستلم
DAMAGED_QTY     QTY  NN D=0      | العجز/التالف
''', uk=[('TRANSFER_ORDER_ID', 'LINE_NO')], area='transfer')

table('INV_COUNT', 'عمليات الجرد', 'Physical Counts', scope='C', mix='doc wf posted status',
      status='PLANNED FROZEN COUNTING RECOUNT REVIEW APPROVED POSTED CANCELLED', cols='''
WAREHOUSE_ID    ID   NN >INV_WAREHOUSE | المستودع
COUNT_TYPE      CODE NN IN:PERIODIC,CYCLE,BLIND,SPOT | النوع
SNAPSHOT_AT     TS               | وقت تجميد الأرصدة
SCOPE_INFO      JSON             | النطاق (فئات، مواقع)
COUNTER_TEAM    V1000            | فريق العد (منفصل عن معتمد الفروق)
VARIANCE_TXN_ID ID   >INV_TRANSACTION | حركة التسوية
''', area='count')

table('INV_COUNT_LINE', 'أسطر الجرد', 'Count Lines', scope='C', cols='''
COUNT_ID        ID   NN >INV_COUNT | الجرد
ITEM_ID         ID   NN >INV_ITEM | الصنف
LOCATION_ID     ID   >INV_LOCATION | الموقع
LOT_ID          ID   >INV_LOT    | الدفعة
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
SYSTEM_QTY      QTY              | كمية النظام (مخفية في الجرد الأعمى)
COUNTED_QTY     QTY              | المعدود
RECOUNT_QTY     QTY              | إعادة العد
VARIANCE_QTY    QTY  @CALC       | الفرق
VARIANCE_VALUE  AMT  @CALC       | قيمة الفرق
REASON_CODE     CODE             | سبب الفرق
COUNTED_BY      USR              | العاد
''', ix=[('TENANT_ID', 'COUNT_ID')], area='count')
