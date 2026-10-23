from model.dsl import module, table

module(16, 'RE', 'التطوير العقاري وبيع الوحدات', 'Real Estate Development & Unit Sales', 'NOONA_REAL_ESTATE_PKG',
       'السجل العقاري الموحد (الأرض ← العقار/المجمع ← المبنى ← الطابق ← الوحدة) المشترك مع الإيجارات '
       'والضيافة والصيانة، وقوائم أسعار الوحدات وخطط السداد والحجز وعقود البيع والأقساط والتسليم '
       'والإفراغ وعمولات الوسطاء. معرف العقار لا يتغير بتغير مالكه.')

UNIT_STATUS = 'PLANNED UNDER_CONSTRUCTION AVAILABLE RESERVED SOLD HANDED_OVER LEASED OCCUPIED UNDER_MAINTENANCE BLOCKED'

table('RE_LAND', 'الأراضي', 'Land Plots', scope='C', mix='pub code names status', status='OWNED UNDER_ACQUISITION UNDER_DEVELOPMENT DEVELOPED SOLD', cols='''
PLOT_NO         V100             | رقم القطعة
DEED_NO         V100             | رقم الصك
AREA_SQM        QTY              | المساحة م2
ZONING_CODE     CODE             | التصنيف/الاستخدام
CITY_ID         ID   >REF_CITY   | المدينة
LATITUDE        NUM              | خط العرض
LONGITUDE       NUM              | خط الطول
ACQUISITION_COST AMT             | تكلفة الاقتناء
ASSET_ID        ID   >FA_ASSET   | الأصل المرتبط
DEED_DOCUMENT_ID ID  >DMS_DOCUMENT | الصك
''', area='registry')

table('RE_PROPERTY', 'العقارات والمجمعات', 'Properties / Compounds', scope='C', mix='pub code names branch status',
      status='PLANNED UNDER_DEVELOPMENT OPERATIONAL UNDER_RENOVATION SOLD_OUT INACTIVE', cols='''
PROPERTY_TYPE   CODE NN IN:COMPOUND,TOWER,BUILDING,VILLA_COMPOUND,MALL,OFFICE_PARK,HOTEL,SERVICED_APARTMENTS,WAREHOUSE_PARK,LAND_SUBDIVISION | النوع
LAND_ID         ID   >RE_LAND    | الأرض
PROJECT_ID      ID   >PRJ_PROJECT | مشروع التطوير
SITE_ID         ID   >ORG_BUSINESS_SITE | الموقع التشغيلي
OWNER_PARTY_ID  ID   >PTY_PARTY  | المالك (عند إدارة أملاك الغير)
MANAGEMENT_MODE CODE NN D='OWNED' IN:OWNED,MANAGED_FOR_OWNER,JOINT | الملكية/الإدارة
USAGE_MIX       V200             | الاستخدامات (سكني، تجاري، فندقي)
TOTAL_AREA_SQM  QTY              | المساحة الكلية
CITY_ID         ID   >REF_CITY   | المدينة
ADDRESS_TEXT    V500             | العنوان التفصيلي
PHONE           V30              | هاتف الاستقبال/الإدارة
DESCRIPTION     V2000            | الوصف والمرافق
STAR_RATING     INT              | التصنيف (نجوم الفندق)
TOURISM_LICENSE_NO V100          | ترخيص السياحة
CHECKIN_TIME    V5               | وقت الدخول (HH24:MI)
CHECKOUT_TIME   V5               | وقت المغادرة (HH24:MI)
BUSINESS_DATE   DATE             | تاريخ العمل الفندقي الحالي (يتقدم بالتدقيق الليلي)
''', area='registry')

table('RE_BUILDING', 'المباني', 'Buildings', scope='C', mix='code names status', codeuk=False, status='PLANNED UNDER_CONSTRUCTION COMPLETED OPERATIONAL', cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | العقار
FLOORS_COUNT    INT              | عدد الطوابق
COMPLETION_DATE DATE             | تاريخ الإنجاز
BUILDING_PERMIT_NO V100          | رخصة البناء
''', uk=[('PROPERTY_ID', 'CODE')], area='registry')

table('RE_FLOOR', 'الطوابق', 'Floors', scope='C', mix='code names sort', codeuk=False, cols='''
BUILDING_ID     ID   NN >RE_BUILDING | المبنى
FLOOR_NO        INT  NN          | رقم الطابق
''', uk=[('BUILDING_ID', 'FLOOR_NO')], area='registry')

table('RE_UNIT', 'الوحدات العقارية', 'Real Estate Units', scope='C', mix='pub code names status', codeuk=False, status=UNIT_STATUS, cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | العقار
BUILDING_ID     ID   >RE_BUILDING | المبنى
FLOOR_ID        ID   >RE_FLOOR   | الطابق
UNIT_TYPE       CODE NN IN:APARTMENT,VILLA,TOWNHOUSE,OFFICE,SHOP,SHOWROOM,WAREHOUSE,ROOM,SUITE,STUDIO,PARKING,STORAGE,LAND_PLOT | النوع
USAGE_TYPE      CODE NN D='SALE' IN:SALE,LEASE,HOSPITALITY,MIXED,OWNER_USE | الاستخدام
NET_AREA_SQM    QTY              | المساحة الصافية
GROSS_AREA_SQM  QTY              | المساحة الإجمالية
BEDROOMS        INT              | غرف النوم
BATHROOMS       INT              | دورات المياه
VIEW_CODE       CODE             | الإطلالة
FURNISHING      CODE IN:UNFURNISHED,SEMI_FURNISHED,FURNISHED | التأثيث
OWNER_PARTY_ID  ID   >PTY_PARTY  | المالك الحالي (بعد البيع)
TITLE_DEED_NO   V100             | رقم صك الوحدة
LIST_PRICE      AMT              | السعر الحالي
ITEM_ID         ID   >INV_ITEM   | الصنف (عند البيع كمخزون عقاري)
ASSET_ID        ID   >FA_ASSET   | الأصل (عند الاحتفاظ للتأجير)
AMENITIES       V1000            | التجهيزات والمرافق
NOTES           V1000            | ملاحظات
''', uk=[('TENANT_ID', 'PROPERTY_ID', 'CODE')], ix=[('TENANT_ID', 'PROPERTY_ID', 'STATUS_CODE')], area='registry',
      purpose='السجل الموحد للوحدات يستخدمه البيع والتأجير والضيافة والصيانة دون تكرار')

table('RE_UNIT_OWNERSHIP', 'سجل ملكية الوحدات', 'Unit Ownership History', scope='C', mix='eff', cols='''
UNIT_ID         ID   NN >RE_UNIT | الوحدة
OWNER_PARTY_ID  ID   >PTY_PARTY  | المالك الطرف
OWNER_COMPANY_ID ID  >ORG_COMPANY | أو شركة من المجموعة
OWNERSHIP_PCT   PCT  NN D=100    | النسبة
SOURCE_CONTRACT_ID ID >RE_SALE_CONTRACT | عقد البيع المصدر
''', area='registry')

table('RE_PRICE_LIST', 'قوائم أسعار الوحدات', 'Unit Price Lists', scope='C', mix='code names cur eff wf status', status='DRAFT APPROVED ACTIVE RETIRED', cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | العقار
PHASE_CODE      V50              | المرحلة
''', area='sales')

table('RE_PRICE_LIST_LINE', 'أسعار الوحدات', 'Unit Prices', scope='C', cols='''
PRICE_LIST_ID   ID   NN >RE_PRICE_LIST | القائمة
UNIT_ID         ID   NN >RE_UNIT | الوحدة
BASE_PRICE      AMT  NN          | السعر الأساسي
PRICE_PER_SQM   AMT              | سعر المتر
MIN_PRICE       AMT              | أدنى سعر دون موافقة
''', uk=[('PRICE_LIST_ID', 'UNIT_ID')], area='sales')

table('RE_PAYMENT_PLAN', 'خطط السداد', 'Payment Plan Templates', scope='C', mix='code names active', cols='''
PROPERTY_ID     ID   >RE_PROPERTY | العقار
DOWN_PAYMENT_PCT PCT             | الدفعة الأولى %
INSTALLMENTS_COUNT INT           | عدد الأقساط
FREQUENCY       CODE IN:MONTHLY,QUARTERLY,SEMI_ANNUAL,ANNUAL,MILESTONE | التكرار
''', area='sales')

table('RE_PAYMENT_PLAN_LINE', 'أسطر خطط السداد', 'Payment Plan Lines', scope='C', mix='sort', cols='''
PAYMENT_PLAN_ID ID   NN >RE_PAYMENT_PLAN | الخطة
LINE_NO         INT  NN          | السطر
DUE_PCT         PCT  NN          | النسبة
DUE_TRIGGER     CODE NN IN:ON_SIGNING,MONTHS_AFTER_SIGNING,CONSTRUCTION_MILESTONE,ON_HANDOVER,POST_HANDOVER | الاستحقاق
OFFSET_MONTHS   INT              | الأشهر
MILESTONE_ID    ID   >PRJ_MILESTONE | معلم الإنشاء
''', uk=[('PAYMENT_PLAN_ID', 'LINE_NO')], area='sales')

table('RE_RESERVATION', 'حجوزات الوحدات', 'Unit Reservations', scope='C', mix='pub doc cur wf status',
      status='DRAFT ACTIVE CONVERTED EXPIRED CANCELLED REFUNDED', cols='''
UNIT_ID         ID   NN >RE_UNIT | الوحدة
BUYER_PARTY_ID  ID   NN >PTY_PARTY | المشتري
BROKER_PARTY_ID ID   >PTY_PARTY  | الوسيط
QUOTED_PRICE    AMT  NN          | السعر المعروض
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم (بموافقة حسب الحد)
DEPOSIT_AMOUNT  AMT  NN D=0      | العربون
DEPOSIT_RECEIPT_ID ID >AR_RECEIPT | إيصال العربون
EXPIRES_AT      TS   NN          | انتهاء الحجز
''', ix=[('TENANT_ID', 'UNIT_ID', 'STATUS_CODE')], area='sales', purpose='يمنع حجزين نشطين لنفس الوحدة (يفحص في الحزمة مع قفل الوحدة)')

table('RE_SALE_CONTRACT', 'عقود بيع الوحدات', 'Unit Sale Contracts', scope='C', mix='pub doc cur wf status',
      status='DRAFT APPROVED SIGNED REGISTERED UNDER_CONSTRUCTION READY_FOR_HANDOVER HANDED_OVER TITLE_TRANSFERRED CANCELLED TERMINATED', cols='''
UNIT_ID         ID   NN >RE_UNIT | الوحدة
RESERVATION_ID  ID   >RE_RESERVATION | الحجز
BUYER_PARTY_ID  ID   NN >PTY_PARTY | المشتري الرئيسي
CO_BUYERS       JSON             | المشترون الإضافيون ونسبهم
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | حساب العميل
PAYMENT_PLAN_ID ID   >RE_PAYMENT_PLAN | خطة السداد
SALE_PRICE      AMT  NN          | سعر البيع
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
TAX_AMOUNT      AMT  NN D=0      | الضريبة/الرسوم
TOTAL_AMOUNT    AMT  NN          | الإجمالي
SIGNED_DATE     DATE             | تاريخ التوقيع
REGISTRATION_NO V100             | رقم التسجيل الحكومي (مثل Oqood/Ejar)
EXPECTED_HANDOVER DATE           | التسليم المتوقع
REVENUE_METHOD  CODE IN:POINT_IN_TIME,OVER_TIME | الاعتراف بالإيراد
SIGNED_DOCUMENT_ID ID >DMS_DOCUMENT | العقد الموقع
CANCEL_REASON   V1000            | سبب الإلغاء
''', ix=[('TENANT_ID', 'UNIT_ID')], area='sales')

table('RE_SALE_INSTALLMENT', 'أقساط عقود البيع', 'Sale Installments', scope='C', mix='status', status='SCHEDULED DUE INVOICED PARTIALLY_PAID PAID OVERDUE WAIVED CANCELLED', cols='''
CONTRACT_ID     ID   NN >RE_SALE_CONTRACT | العقد
INSTALLMENT_NO  INT  NN          | رقم القسط
DUE_DATE        DATE NN          | الاستحقاق
AMOUNT          AMT  NN          | المبلغ
PAID_AMOUNT     AMT  NN D=0 @SYS | المحصل
AR_OPEN_ITEM_ID ID   >AR_OPEN_ITEM | الذمة الناتجة
MILESTONE_ID    ID   >PRJ_MILESTONE | المعلم المرتبط
''', uk=[('CONTRACT_ID', 'INSTALLMENT_NO')], ix=[('TENANT_ID', 'DUE_DATE', 'STATUS_CODE')], area='sales')

table('RE_HANDOVER', 'تسليم الوحدات', 'Unit Handovers', scope='C', mix='doc status', status='SCHEDULED INSPECTION SNAGS_OPEN ACCEPTED HANDED_OVER', cols='''
CONTRACT_ID     ID   >RE_SALE_CONTRACT | عقد البيع
UNIT_ID         ID   NN >RE_UNIT | الوحدة
SCHEDULED_DATE  DATE             | الموعد
HANDOVER_DATE   DATE             | التسليم الفعلي
SNAG_LIST       JSON             | الملاحظات والعيوب
METER_READINGS  JSON             | قراءات العدادات
KEYS_COUNT      INT              | عدد المفاتيح
ACCEPTANCE_DOCUMENT_ID ID >DMS_DOCUMENT | محضر الاستلام الموقع
''', area='sales')

table('RE_TITLE_TRANSFER', 'إفراغ الملكية', 'Title Transfers', scope='C', mix='status', status='PENDING SUBMITTED COMPLETED REJECTED', cols='''
CONTRACT_ID     ID   NN >RE_SALE_CONTRACT | العقد
AUTHORITY_REF   V100             | مرجع الجهة
TRANSFER_DATE   DATE             | التاريخ
FEES_AMOUNT     AMT              | الرسوم
NEW_DEED_NO     V100             | رقم الصك الجديد
DOCUMENT_ID     ID   >DMS_DOCUMENT | الصك
''', area='sales')

table('RE_BROKER_COMMISSION', 'عمولات الوسطاء', 'Broker Commissions', scope='C', mix='status', status='ACCRUED ELIGIBLE APPROVED PAID REVERSED', cols='''
CONTRACT_ID     ID   NN >RE_SALE_CONTRACT | العقد
BROKER_PARTY_ID ID   NN >PTY_PARTY | الوسيط
COMMISSION_PCT  PCT              | النسبة
COMMISSION_AMOUNT AMT NN         | المبلغ
ELIGIBILITY_RULE V500            | شرط الاستحقاق (نسبة تحصيل...)
AP_INVOICE_ID   ID   >AP_INVOICE | فاتورة الوسيط
''', area='sales')

table('RE_COST_ALLOCATION', 'توزيع تكاليف التطوير', 'Development Cost Allocation', scope='C', mix='posted status', status='DRAFT CALCULATED POSTED', cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | العقار
PERIOD_ID       ID   NN >GL_PERIOD | الفترة
ALLOCATION_BASIS CODE NN IN:AREA,SALE_VALUE,UNIT_COUNT,MANUAL | الأساس
TOTAL_COST      AMT  NN          | التكلفة الموزعة
DETAILS         JSON             | التوزيع على الوحدات
''', area='cost')
