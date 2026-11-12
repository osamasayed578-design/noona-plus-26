from model.dsl import module, table

module(36, 'DST', 'التوزيع والمبيعات الميدانية', 'Distribution & Field Sales', 'NOONA_DST_PKG',
       'شركات التوزيع على المحلات: المندوبون وسيارات التوزيع (مستودع متنقل وعهدة نقدية)، خطوط السير والمناطق وأيام الزيارة، '
       'المحلات بمواقعها على الخريطة، خطة اليوم والزيارات بالموقع والوقت، البيع من السيارة وأوامر التوريد المسبقة، التحصيل '
       'بطرق الدفع ورقم المرجع (الإشعار البنكي، الشيك، العملية)، المرتجعات، أسباب عدم الشراء، تسوية نهاية اليوم، العمولات والأهداف.')

table('DST_REP', 'المندوبون', 'Field Sales Reps', scope='C', mix='code notes status', status='ACTIVE INACTIVE', cols='''
FULL_NAME       NAME NN          | الاسم
EMPLOYEE_ID     ID   >HR_EMPLOYEE | الموظف
USER_NAME       V128             | مستخدم النظام (للتطبيق الميداني)
PHONE           V30              | الجوال
VAN_WAREHOUSE_ID ID  NN >INV_WAREHOUSE | مستودع السيارة (المخزون المتنقل)
CASH_BOX_ID     ID   NN >CSH_CASH_BOX | عهدة النقد (صندوق المندوب)
VEHICLE_PLATE   V30              | لوحة سيارة التوزيع
CREDIT_ALLOWED  YN   NN D='Y'    | يبيع آجلاً ضمن حد المحل
COMMISSION_BASIS CODE NN D='SALES' IN:SALES,COLLECTION,VISIT,NONE | أساس العمولة
COMMISSION_RATE NUM              | نسبة العمولة %
COMMISSION_PER_VISIT AMT         | عمولة الزيارة المنفذة
MONTHLY_TARGET  AMT              | الهدف الشهري للمبيعات
''', uk=[('TENANT_ID', 'COMPANY_ID', 'USER_NAME')], area='setup')

table('DST_ROUTE', 'خطوط السير', 'Delivery Routes', scope='C', mix='code names notes status', status='ACTIVE INACTIVE', cols='''
REP_ID          ID   >DST_REP    | المندوب
REGION_NAME     V100             | المنطقة
VISIT_DAYS      V50              | أيام الزيارة (SUN,MON,TUE,WED,THU,FRI,SAT)
''', area='setup')

table('DST_SHOP', 'المحلات', 'Shops & Outlets', scope='C', mix='notes status', status='ACTIVE INACTIVE BLOCKED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | حساب العميل
SHOP_TYPE       CODE NN D='GROCERY' IN:GROCERY,SUPERMARKET,PHARMACY,RESTAURANT,CAFE,WHOLESALE,KIOSK,STATION,OTHER | النوع
OWNER_NAME      V200             | صاحب المحل
PHONE           V30              | الجوال
WHATSAPP        V30              | واتساب
ROUTE_ID        ID   >DST_ROUTE  | خط السير
ROUTE_SEQ       INT              | ترتيب الزيارة في الخط
VISIT_DAYS      V50              | أيام الزيارة (إن اختلفت عن الخط)
LATITUDE        NUM              | خط العرض
LONGITUDE       NUM              | خط الطول
LOCATION_SET_AT TS               | وقت حفظ الموقع
ADDRESS_TEXT    V500             | العنوان
LANDMARK        V500             | علامة مميزة
LAST_VISIT_AT   TS               | آخر زيارة
LAST_SALE_AT    TS               | آخر شراء
''', uk=[('TENANT_ID', 'COMPANY_ID', 'CUSTOMER_ACCOUNT_ID')], ix=[('TENANT_ID', 'ROUTE_ID')], area='setup')

table('DST_VISIT', 'الزيارات', 'Shop Visits', scope='C', mix='doc notes status', status='OPEN CLOSED CANCELLED', cols='''
REP_ID          ID   NN >DST_REP | المندوب
SHOP_ID         ID   NN >DST_SHOP | المحل
ROUTE_ID        ID   >DST_ROUTE  | خط السير
CHECKIN_AT      TS   NN          | الوصول
CHECKOUT_AT     TS               | المغادرة
LATITUDE        NUM              | موقع الوصول (عرض)
LONGITUDE       NUM              | موقع الوصول (طول)
DISTANCE_M      NUM              | البعد عن موقع المحل (متر)
OUTCOME         CODE IN:SALE,ORDER,COLLECTION,RETURN,NO_SALE,MIXED | النتيجة
NO_SALE_REASON  CODE IN:CLOSED,STOCKED,NO_CASH,OWNER_ABSENT,COMPETITOR,PRICE,OTHER | سبب عدم الشراء
SALES_INVOICE_ID ID  >SAL_INVOICE | فاتورة البيع
SALES_AMOUNT    AMT  NN D=0      | المبيعات
COLLECTED_AMOUNT AMT NN D=0      | المحصل
RETURNS_AMOUNT  AMT  NN D=0      | المرتجعات
''', ix=[('TENANT_ID', 'REP_ID', 'DOC_DATE'), ('TENANT_ID', 'SHOP_ID')], area='operations')

table('DST_LOAD', 'تحميل وتفريغ السيارات', 'Van Loads', scope='C', mix='doc notes status', status='POSTED CANCELLED', cols='''
REP_ID          ID   NN >DST_REP | المندوب
DIRECTION       CODE NN D='LOAD' IN:LOAD,UNLOAD | تحميل أو تفريغ
FROM_WAREHOUSE_ID ID NN >INV_WAREHOUSE | من مستودع
TO_WAREHOUSE_ID ID   NN >INV_WAREHOUSE | إلى مستودع
INV_TXN_ID      ID   >INV_TRANSACTION | حركة التحويل
ITEMS_COUNT     INT  NN D=0      | الأصناف
TOTAL_QTY       QTY  NN D=0      | الكمية
''', area='operations')

table('DST_ORDER', 'أوامر التوريد', 'Pre-sale Orders', scope='C', mix='doc notes status',
      status='SUBMITTED APPROVED INVOICED CANCELLED', cols='''
REP_ID          ID   NN >DST_REP | المندوب
SHOP_ID         ID   NN >DST_SHOP | المحل
VISIT_ID        ID   >DST_VISIT  | الزيارة
DELIVERY_DATE   DATE             | تاريخ التسليم المطلوب
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي (شامل الضريبة)
SALES_INVOICE_ID ID  >SAL_INVOICE | فاتورة التسليم
''', area='operations')

table('DST_ORDER_LINE', 'أسطر أوامر التوريد', 'Pre-sale Order Lines', scope='C', cols='''
ORDER_ID        ID   NN >DST_ORDER | الأمر
ITEM_ID         ID   NN >INV_ITEM | الصنف
QUANTITY        QTY  NN          | الكمية
UNIT_PRICE      AMT  NN D=0      | السعر
AMOUNT          AMT  NN D=0      | المبلغ
''', chk=['QUANTITY > 0'], area='operations')

table('DST_COLLECTION', 'تحصيلات المندوبين', 'Field Collections', scope='C', mix='doc notes status',
      status='PENDING_VERIFY POSTED REJECTED', cols='''
REP_ID          ID   NN >DST_REP | المندوب
SHOP_ID         ID   NN >DST_SHOP | المحل
VISIT_ID        ID   >DST_VISIT  | الزيارة
AMOUNT          AMT  NN          | المبلغ
PAYMENT_METHOD  CODE NN D='CASH' IN:CASH,BANK_TRANSFER,CHEQUE,CARD,WALLET | طريقة الدفع
REFERENCE_NO    V100             | رقم المرجع (رقم الإشعار البنكي، الشيك، العملية)
BANK_NAME       V100             | البنك
CHEQUE_DUE_DATE DATE             | تاريخ استحقاق الشيك
BANK_ACCOUNT_ID ID   >CSH_BANK_ACCOUNT | حساب الشركة المحول إليه
SALES_INVOICE_ID ID  >SAL_INVOICE | الفاتورة المسددة
AR_RECEIPT_ID   ID   >AR_RECEIPT | سند القبض
SETTLEMENT_ID   ID               | تسوية اليوم
VERIFIED_BY     USR              | المحاسب المؤكد
VERIFIED_AT     TS               | وقت التأكيد
''', chk=['AMOUNT > 0'], ix=[('TENANT_ID', 'REP_ID', 'DOC_DATE'), ('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE')], area='operations')

table('DST_SETTLEMENT', 'تسويات نهاية اليوم', 'Daily Rep Settlements', scope='C', mix='doc notes status',
      status='SUBMITTED APPROVED', cols='''
REP_ID          ID   NN >DST_REP | المندوب
SETTLE_DATE     DATE NN          | اليوم
VISITS_PLANNED  INT  NN D=0      | الزيارات المخططة
VISITS_DONE     INT  NN D=0      | الزيارات المنفذة
SALES_AMOUNT    AMT  NN D=0      | المبيعات
CREDIT_SALES    AMT  NN D=0      | منها آجل
RETURNS_AMOUNT  AMT  NN D=0      | المرتجعات
CASH_EXPECTED   AMT  NN D=0      | النقد المتوقع
CASH_COUNTED    AMT  NN D=0      | النقد المسلم
CASH_DIFF       AMT  NN D=0      | العجز (-) أو الزيادة (+)
TRANSFERS_AMOUNT AMT NN D=0      | إشعارات التحويل
CHEQUES_AMOUNT  AMT  NN D=0      | الشيكات
CARDS_AMOUNT    AMT  NN D=0      | الشبكة والمحافظ
DEPOSIT_BOX_ID  ID   >CSH_CASH_BOX | الصندوق المورد إليه
APPROVED_BY     USR              | المعتمد
APPROVED_AT     TS               | وقت الاعتماد
''', uk=[('TENANT_ID', 'COMPANY_ID', 'REP_ID', 'SETTLE_DATE')], area='operations')

table('DST_COMMISSION', 'عمولات المندوبين', 'Rep Commissions', scope='C', mix='status', status='CALCULATED APPROVED', cols='''
REP_ID          ID   NN >DST_REP | المندوب
PERIOD_START    DATE NN          | بداية الشهر
BASIS           CODE NN IN:SALES,COLLECTION,VISIT,NONE | الأساس
BASE_AMOUNT     AMT  NN D=0      | المبلغ الأساس
VISITS_COUNT    INT  NN D=0      | الزيارات
TARGET_AMOUNT   AMT              | الهدف
ACHIEVEMENT_PCT NUM              | نسبة الإنجاز
COMMISSION_AMOUNT AMT NN D=0     | العمولة
''', uk=[('TENANT_ID', 'COMPANY_ID', 'REP_ID', 'PERIOD_START')], area='operations')
