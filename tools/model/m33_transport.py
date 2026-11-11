from model.dsl import module, table

module(33, 'TRN', 'النقل والشحن والترحيل', 'Transport & Logistics', 'NOONA_TRN_PKG',
       'أسطول الشاحنات والعربات والسائقين، المدن والمواقع والمسارات والمسافات، أنواع الشحنات، تعرفة الترحيل بالطن المتري '
       'والطن القصير والطويل والكيلوجرام والمتر المكعب والكيلومتر والطن-كيلومتر والرحلة والحاوية، أوامر الشحن، الرحلات '
       'بمواعيدها وزمن الوصول المتوقع ونقاط التوقف، التسليم والتفريغ والعجز، مصروفات الرحلة، والأعطال والبلاغات وزمن الاستجابة، '
       'وفوترة الترحيل في المبيعات.')

table('TRN_LOCATION', 'المدن والمواقع', 'Cities & Locations', scope='C', mix='code names active', cols='''
LOCATION_TYPE   CODE NN D='CITY' IN:CITY,PORT,WAREHOUSE,FACTORY,BORDER,CHECKPOINT,FUEL_STATION,REST_AREA,CUSTOMER_SITE,OTHER | النوع
CITY_NAME       V100             | المدينة
REGION_NAME     V100             | المنطقة/الولاية
COUNTRY_CODE    CTRY             | الدولة
ADDRESS_TEXT    V500             | العنوان
LATITUDE        NUM              | خط العرض
LONGITUDE       NUM              | خط الطول
CONTACT_NAME    V200             | جهة الاتصال
PHONE           V30              | الهاتف
''', area='setup')

table('TRN_ROUTE', 'المسارات والمسافات', 'Routes & Distances', scope='C', mix='code names active', cols='''
FROM_LOCATION_ID ID  NN >TRN_LOCATION | من
TO_LOCATION_ID  ID   NN >TRN_LOCATION | إلى
DISTANCE_KM     NUM  NN          | المسافة (كم)
STANDARD_HOURS  NUM  NN          | زمن الرحلة القياسي (ساعة)
TOLL_AMOUNT     AMT              | رسوم الطرق المعتادة
ROAD_TYPE       CODE D='HIGHWAY' IN:HIGHWAY,PAVED,UNPAVED,MIXED | نوع الطريق
''', chk=['DISTANCE_KM > 0', 'STANDARD_HOURS > 0'], area='setup')

table('TRN_CARGO_TYPE', 'أنواع الشحنات', 'Cargo Types', scope='C', mix='code names active', cols='''
CARGO_CATEGORY  CODE NN D='GENERAL' IN:GENERAL,BULK,LIQUID,REFRIGERATED,HAZARDOUS,CONTAINER,VEHICLES,LIVESTOCK,FRAGILE,OVERSIZED | الفئة
DEFAULT_UNIT    CODE NN D='METRIC_TON' IN:METRIC_TON,SHORT_TON,LONG_TON,KG,M3,LITER,CONTAINER,PALLET,PIECE,TRIP | وحدة القياس الافتراضية
REQUIRED_VEHICLE_TYPE CODE IN:TRUCK,TRAILER,TANKER,REFRIGERATED,FLATBED,CONTAINER_CARRIER,TIPPER,LOWBED,PICKUP,VAN | نوع العربة المطلوب
HAZARD_CLASS    V20              | فئة الخطورة (UN)
HANDLING_NOTES  V1000            | تعليمات المناولة والتفريغ
''', area='setup')

table('TRN_VEHICLE', 'العربات والشاحنات', 'Fleet Vehicles', scope='C', mix='code notes status', status='AVAILABLE ON_TRIP MAINTENANCE OUT_OF_SERVICE SOLD', cols='''
PLATE_NO        V30  NN          | رقم اللوحة
VEHICLE_TYPE    CODE NN D='TRUCK' IN:TRUCK,TRAILER,TANKER,REFRIGERATED,FLATBED,CONTAINER_CARRIER,TIPPER,LOWBED,PICKUP,VAN | النوع
MAKE            V100             | الشركة المصنعة
MODEL           V100             | الطراز
MODEL_YEAR      INT              | سنة الصنع
CAPACITY_TONS   NUM  NN          | الحمولة القصوى (طن متري)
CAPACITY_M3     NUM              | السعة (متر مكعب)
ODOMETER_KM     NUM  NN D=0      | عداد المسافة (كم)
FUEL_TYPE       CODE D='DIESEL' IN:DIESEL,GASOLINE,GAS,ELECTRIC | الوقود
FUEL_L_PER_100KM NUM             | استهلاك الوقود (لتر/100 كم)
LICENSE_EXPIRY  DATE             | انتهاء الترخيص
INSURANCE_EXPIRY DATE            | انتهاء التأمين
OWNERSHIP       CODE NN D='OWNED' IN:OWNED,RENTED,LEASED | الملكية (مملوكة تضاف للأصول الثابتة)
ASSET_ID        ID   >FA_ASSET   | الأصل الثابت
BRANCH_ID       ID   >ORG_BRANCH | الفرع
''', uk=[('TENANT_ID', 'COMPANY_ID', 'PLATE_NO')], chk=['CAPACITY_TONS > 0'], area='fleet')

table('TRN_DRIVER', 'السائقون', 'Drivers', scope='C', mix='code notes status', status='AVAILABLE ON_TRIP OFF_DUTY SUSPENDED LEFT', cols='''
FULL_NAME       NAME NN          | الاسم
EMPLOYEE_ID     ID   >HR_EMPLOYEE | الموظف
PHONE           V30              | الجوال
NATIONAL_ID     V30              | رقم الهوية
LICENSE_NO      V50  NN          | رقم رخصة القيادة
LICENSE_CLASS   V30              | فئة الرخصة
LICENSE_EXPIRY  DATE NN          | انتهاء الرخصة
HAZMAT_CERTIFIED YN  NN D='N'    | مؤهل لنقل المواد الخطرة
TRIP_ALLOWANCE  AMT              | بدل الرحلة الافتراضي
BRANCH_ID       ID   >ORG_BRANCH | الفرع
''', area='fleet')

table('TRN_RATE', 'تعرفة الترحيل', 'Freight Rates', scope='C', mix='code names eff status', status='ACTIVE INACTIVE', cols='''
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | العميل (فارغ = كل العملاء)
ROUTE_ID        ID   >TRN_ROUTE  | المسار (فارغ = كل المسارات)
CARGO_TYPE_ID   ID   >TRN_CARGO_TYPE | نوع الشحنة (فارغ = الكل)
RATE_BASIS      CODE NN IN:PER_METRIC_TON,PER_SHORT_TON,PER_LONG_TON,PER_KG,PER_M3,PER_LITER,PER_KM,PER_TON_KM,PER_TRIP,PER_CONTAINER,PER_PALLET,PER_PIECE | أساس الحساب
RATE_AMOUNT     AMT  NN          | السعر
MIN_CHARGE      AMT              | الحد الأدنى للترحيل
PRIORITY_NO     INT  NN D=100    | الأولوية
''', chk=['RATE_AMOUNT >= 0'], area='pricing')

table('TRN_ORDER', 'أوامر الشحن', 'Shipment Orders', scope='C', mix='pub doc branch status notes',
      status='DRAFT CONFIRMED PLANNED IN_TRANSIT DELIVERED INVOICED CANCELLED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | العميل
CUSTOMER_REF    V100             | مرجع العميل
FROM_LOCATION_ID ID  NN >TRN_LOCATION | مكان التحميل
TO_LOCATION_ID  ID   NN >TRN_LOCATION | مكان التفريغ
ROUTE_ID        ID   >TRN_ROUTE  | المسار
CARGO_TYPE_ID   ID   NN >TRN_CARGO_TYPE | نوع الشحنة
CARGO_DESCRIPTION V1000          | وصف البضاعة
QUANTITY        QTY  NN          | الكمية
UOM_CODE        CODE NN IN:METRIC_TON,SHORT_TON,LONG_TON,KG,M3,LITER,CONTAINER,PALLET,PIECE,TRIP | الوحدة
WEIGHT_KG       NUM              | الوزن بالكيلوجرام (محسوب أو مدخل)
VOLUME_M3       NUM              | الحجم بالمتر المكعب
PACKAGES_COUNT  INT              | عدد الطرود
DECLARED_VALUE  AMT              | القيمة المصرح بها
RATE_ID         ID   >TRN_RATE   | التعرفة المطبقة
RATE_BASIS      CODE IN:PER_METRIC_TON,PER_SHORT_TON,PER_LONG_TON,PER_KG,PER_M3,PER_LITER,PER_KM,PER_TON_KM,PER_TRIP,PER_CONTAINER,PER_PALLET,PER_PIECE | أساس الحساب
RATE_AMOUNT     AMT              | السعر
FREIGHT_AMOUNT  AMT  NN D=0      | قيمة الترحيل
OTHER_CHARGES   AMT  NN D=0      | رسوم أخرى (تحميل، تفريغ، انتظار)
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي قبل الضريبة
PICKUP_DATE     DATE             | تاريخ التحميل المطلوب
REQUIRED_DELIVERY_DATE DATE      | تاريخ التسليم المطلوب
DELIVERED_QTY   QTY              | الكمية المسلمة
SHORTAGE_QTY    QTY              | العجز
DAMAGE_NOTES    V1000            | الأضرار
RECEIVER_NAME   V200             | المستلم
DELIVERED_AT    TS               | وقت التسليم
POD_DOCUMENT_ID ID   >DMS_DOCUMENT | إثبات التسليم
SALES_INVOICE_ID ID  >SAL_INVOICE | فاتورة الترحيل
''', ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE'), ('TENANT_ID', 'COMPANY_ID', 'CUSTOMER_ACCOUNT_ID')],
      chk=['QUANTITY > 0'], area='operations')

table('TRN_TRIP', 'الرحلات', 'Trips', scope='C', mix='pub doc branch status notes',
      status='PLANNED DISPATCHED IN_TRANSIT ARRIVED COMPLETED CANCELLED', cols='''
VEHICLE_ID      ID   NN >TRN_VEHICLE | العربة
DRIVER_ID       ID   NN >TRN_DRIVER | السائق
CO_DRIVER_ID    ID   >TRN_DRIVER | السائق المساعد
ROUTE_ID        ID   >TRN_ROUTE  | المسار
FROM_LOCATION_ID ID  NN >TRN_LOCATION | من
TO_LOCATION_ID  ID   NN >TRN_LOCATION | إلى
PLANNED_DEPARTURE TS NN          | موعد التحرك المخطط
ACTUAL_DEPARTURE TS              | وقت التحرك الفعلي
ETA             TS               | زمن الوصول المتوقع
ACTUAL_ARRIVAL  TS               | وقت الوصول الفعلي
PLANNED_DISTANCE_KM NUM          | المسافة المخططة
ODOMETER_START  NUM              | العداد عند التحرك
ODOMETER_END    NUM              | العداد عند العودة
ACTUAL_DISTANCE_KM NUM           | المسافة الفعلية
LOAD_KG         NUM  NN D=0      | الحمولة (كجم)
DELAY_MINUTES   INT  NN D=0      | التأخير المضاف من الأعطال والتوقفات (دقيقة)
FUEL_LITERS     NUM              | الوقود (لتر)
REVENUE_AMOUNT  AMT  NN D=0      | إيراد الرحلة
EXPENSE_AMOUNT  AMT  NN D=0      | مصروفات الرحلة
''', ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE'), ('TENANT_ID', 'VEHICLE_ID'), ('TENANT_ID', 'DRIVER_ID')], area='operations')

table('TRN_TRIP_ORDER', 'شحنات الرحلة', 'Trip Shipments', scope='C', cols='''
TRIP_ID         ID   NN >TRN_TRIP | الرحلة
ORDER_ID        ID   NN >TRN_ORDER | أمر الشحن
LOADED_QTY      QTY  NN          | الكمية المحملة
LOADED_KG       NUM  NN D=0      | الوزن المحمل (كجم)
''', uk=[('TRIP_ID', 'ORDER_ID')], area='operations')

table('TRN_TRIP_STOP', 'نقاط التوقف', 'Trip Stops', scope='C', mix='sort notes', cols='''
TRIP_ID         ID   NN >TRN_TRIP | الرحلة
LOCATION_ID     ID   NN >TRN_LOCATION | الموقع
STOP_PURPOSE    CODE NN D='CHECKPOINT' IN:LOADING,UNLOADING,REST,FUEL,CHECKPOINT,CUSTOMS,BORDER,WEIGHBRIDGE,REPAIR,OTHER | الغرض
PLANNED_MINUTES INT  NN D=0      | مدة التوقف المخططة (دقيقة)
PLANNED_ARRIVAL TS               | الوصول المخطط
ACTUAL_ARRIVAL  TS               | الوصول الفعلي
ACTUAL_DEPARTURE TS              | المغادرة الفعلية
''', area='operations')

table('TRN_TRIP_EXPENSE', 'مصروفات الرحلة', 'Trip Expenses', scope='C', mix='notes', cols='''
TRIP_ID         ID   NN >TRN_TRIP | الرحلة
EXPENSE_TYPE    CODE NN IN:FUEL,TOLL,DRIVER_ALLOWANCE,LOADING,UNLOADING,PARKING,REPAIR,TIRES,FINE,WEIGHBRIDGE,CUSTOMS,OTHER | النوع
EXPENSE_DATE    DATE NN          | التاريخ
AMOUNT          AMT  NN          | المبلغ
LITERS          NUM              | اللترات (للوقود)
REFERENCE_NO    V100             | رقم الإيصال
''', chk=['AMOUNT >= 0'], area='operations')

table('TRN_INCIDENT', 'الأعطال والبلاغات', 'Road Incidents & Reports', scope='C', mix='pub doc status notes',
      status='REPORTED ACKNOWLEDGED IN_PROGRESS RESOLVED CLOSED', cols='''
TRIP_ID         ID   >TRN_TRIP   | الرحلة
VEHICLE_ID      ID   NN >TRN_VEHICLE | العربة
DRIVER_ID       ID   >TRN_DRIVER | السائق
INCIDENT_TYPE   CODE NN IN:BREAKDOWN,TIRE,ACCIDENT,DELAY,CARGO_DAMAGE,THEFT,POLICE,WEATHER,ROAD_CLOSURE,MEDICAL,BORDER_HOLD,OTHER | النوع
SEVERITY        CODE NN D='MEDIUM' IN:LOW,MEDIUM,HIGH,CRITICAL | الخطورة
REPORTED_AT     TS   NN          | وقت البلاغ
REPORTED_BY     V200             | المبلّغ
LOCATION_ID     ID   >TRN_LOCATION | أقرب موقع
LOCATION_TEXT   V500             | وصف المكان
DESCRIPTION     V2000 NN         | الوصف
ASSIGNED_TO     V200             | المكلّف بالاستجابة
ACKNOWLEDGED_AT TS               | وقت الاستلام
RESPONDED_AT    TS               | وقت بدء الاستجابة
RESOLVED_AT     TS               | وقت الحل
RESPONSE_ACTION V2000            | إجراء الاستجابة
DOWNTIME_MINUTES INT             | مدة التوقف (دقيقة)
COST_AMOUNT     AMT              | التكلفة
''', ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE'), ('TENANT_ID', 'TRIP_ID')], area='operations')

# ---------------------------------------------------------------- صيانة الأسطول
table('TRN_MAINT_PLAN', 'برامج الصيانة الدورية للأسطول', 'Fleet Service Programs', scope='C', mix='notes status',
      status='ACTIVE PAUSED', cols='''
SERVICE_NAME    V200 NN          | الخدمة (تغيير زيت، إطارات، فرامل، فحص دوري...)
VEHICLE_ID      ID   >TRN_VEHICLE | العربة (فارغ = كل عربات النوع)
VEHICLE_TYPE    CODE             | نوع العربات (فارغ = كل الأنواع)
EVERY_KM        NUM              | كل (كم)
EVERY_DAYS      INT              | كل (يوم)
ESTIMATED_COST  AMT              | التكلفة التقديرية
''', chk=['EVERY_KM > 0 OR EVERY_DAYS > 0'], area='fleet')

table('TRN_MAINT_ORDER', 'أوامر صيانة العربات', 'Vehicle Maintenance Orders', scope='C', mix='pub doc branch status notes',
      status='OPEN IN_PROGRESS COMPLETED CANCELLED', cols='''
VEHICLE_ID      ID   NN >TRN_VEHICLE | العربة
PLAN_ID         ID   >TRN_MAINT_PLAN | البرنامج الدوري
INCIDENT_ID     ID   >TRN_INCIDENT | البلاغ (العطل)
MAINT_TYPE      CODE NN D='CORRECTIVE' IN:PREVENTIVE,CORRECTIVE,OVERHAUL,INSPECTION,ACCIDENT,TIRES,UPGRADE | النوع
WORKSHOP        CODE NN D='INTERNAL' IN:INTERNAL,EXTERNAL | الورشة
VENDOR_PARTY_ID ID   >PTY_PARTY  | الورشة الخارجية / المورد
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع قطع الغيار والزيوت (للصرف من المخزون)
DESCRIPTION     V2000 NN         | وصف العمل
OPENED_AT       TS   NN          | دخول الصيانة
COMPLETED_AT    TS               | الخروج من الصيانة
ODOMETER_KM     NUM              | العداد عند الصيانة
DOWNTIME_HOURS  NUM              | مدة التوقف (ساعة)
PARTS_COST      AMT  NN D=0      | قطع الغيار
LABOR_COST      AMT  NN D=0      | العمالة
OTHER_COST      AMT  NN D=0      | أخرى
STOCK_COST      AMT  NN D=0      | منها مصروف من المخزون
VAT_AMOUNT      AMT  NN D=0      | الضريبة
TOTAL_COST      AMT  NN D=0      | الإجمالي دون الضريبة
TREATMENT       CODE NN D='EXPENSE' IN:EXPENSE,CAPITALIZE | المعالجة المحاسبية
LIFE_EXTENSION_MONTHS INT NN D=0 | تمديد عمر العربة (شهر)
PREV_STATUS     CODE             | حالة العربة قبل الصيانة
FA_MAINTENANCE_ID ID >FA_MAINTENANCE | قيد الصيانة في الأصول
''', ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE'), ('TENANT_ID', 'VEHICLE_ID')], area='fleet')

table('TRN_MAINT_LINE', 'بنود أمر الصيانة', 'Maintenance Order Lines', scope='C', cols='''
ORDER_ID        ID   NN >TRN_MAINT_ORDER | أمر الصيانة
LINE_TYPE       CODE NN D='PART' IN:PART,LABOR,OIL,TIRE,OTHER | النوع
DESCRIPTION     V500 NN          | البيان
ITEM_ID         ID   >INV_ITEM   | الصنف (قطعة الغيار)
QUANTITY        QTY  NN D=1      | الكمية
UNIT_COST       AMT  NN D=0      | تكلفة الوحدة
AMOUNT          AMT  NN D=0      | المبلغ
FROM_STOCK      YN   NN D='N'    | مصروف من المخزون
LIFE_KM         NUM              | عمر الاستبدال (كم)
LIFE_DAYS       INT              | عمر الاستبدال (يوم)
NEXT_DUE_KM     NUM              | الاستبدال التالي عند العداد
NEXT_DUE_DATE   DATE             | الاستبدال التالي بتاريخ
INV_TXN_ID      ID   >INV_TRANSACTION | حركة الصرف المخزني
''', chk=['QUANTITY > 0', 'UNIT_COST >= 0'], area='fleet')
