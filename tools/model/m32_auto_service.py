from model.dsl import module, table

module(32, 'AUT', 'مراكز خدمة السيارات', 'Auto Service Centers', 'NOONA_AUT_PKG',
       'المركبات وملاكها، كتالوج الخدمات ككروت مع قطعها الافتراضية، الرافعات والفنيون، الحجوزات، أوامر الإصلاح بالخدمات '
       'وقطع الغيار والفني المنفذ ومدة البقاء، فاتورة واحدة تصرف القطع من المخزون، ومطالبات شركات التأمين وتحمل العميل.')

table('AUT_SERVICE_CATEGORY', 'فئات خدمات السيارات', 'Service Categories', scope='C', mix='code names active sort', cols='''
ICON            V50              | الأيقونة
COLOR           V20              | لون الكرت
''', area='setup')

table('AUT_SERVICE', 'خدمات السيارات', 'Auto Services', scope='C', mix='code names desc active sort', cols='''
CATEGORY_ID     ID   NN >AUT_SERVICE_CATEGORY | الفئة
PRICE           AMT  NN D=0      | السعر
PRICE_INCLUDES_TAX YN NN D='N'   | السعر شامل الضريبة
STANDARD_MINUTES INT             | الوقت القياسي بالدقائق
WARRANTY_DAYS   INT              | ضمان العمل بالأيام
WARRANTY_KM     INT              | ضمان العمل بالكيلومتر
NEXT_SERVICE_DAYS INT            | الخدمة التالية بعد (يوم)
NEXT_SERVICE_KM INT              | الخدمة التالية بعد (كم)
ICON            V50              | الأيقونة
''', area='setup')

table('AUT_SERVICE_PART', 'القطع الافتراضية للخدمة', 'Service Default Parts', scope='C', cols='''
SERVICE_ID      ID   NN >AUT_SERVICE | الخدمة
ITEM_ID         ID   NN >INV_ITEM | القطعة
QUANTITY        QTY  NN D=1      | الكمية
IS_OPTIONAL     YN   NN D='N'    | اختيارية (تقترح ولا تضاف تلقائياً)
''', uk=[('SERVICE_ID', 'ITEM_ID')], area='setup')

table('AUT_BAY', 'الرافعات ومواقع العمل', 'Service Bays', scope='C', mix='code names active sort', cols='''
BAY_TYPE        CODE NN D='LIFT' IN:LIFT,FLOOR,WASH,PAINT,ALIGNMENT,DIAGNOSTIC,TIRE | النوع
''', area='setup')

table('AUT_TECHNICIAN', 'الفنيون', 'Technicians', scope='C', mix='code names active', cols='''
EMPLOYEE_ID     ID   >HR_EMPLOYEE | الموظف
SPECIALTY       V200             | التخصص
PHONE           V30              | الجوال
HOURLY_COST     AMT              | تكلفة الساعة
USER_NAME       V128             | مستخدم النظام (شاشة الفني على الهاتف)
EARNINGS_METHOD CODE NN D='PAYROLL' IN:PAYROLL,CASH,BANK_TRANSFER,NONE | صرف المستحقات (مع الراتب، نقداً، تحويل، لا يستحق)
COMMISSION_PCT  PCT              | نسبة العمولة من الخدمات
JOB_BONUS       AMT              | بونص ثابت لكل أمر إصلاح منجز
''', area='setup')

table('AUT_INSURER', 'شركات التأمين', 'Insurers', scope='C', mix='code names status', status='ACTIVE SUSPENDED INACTIVE', cols='''
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | حساب الذمة (المطالبات)
LABOR_DISCOUNT_PCT PCT           | خصم الخدمات المتفق عليه
PARTS_DISCOUNT_PCT PCT           | خصم القطع المتفق عليه
DEFAULT_DEDUCTIBLE AMT           | تحمل العميل الافتراضي
CLAIM_DAYS      INT              | مهلة سداد المطالبات بالأيام
CONTACT_NAME    V200             | مسؤول التواصل
PHONE           V30              | الهاتف
EMAIL           V320             | البريد
''', area='setup')

table('AUT_VEHICLE', 'المركبات', 'Vehicles', scope='C', mix='pub notes status', status='ACTIVE INACTIVE', cols='''
PLATE_NO        V30  NN          | رقم اللوحة
PLATE_TYPE      CODE NN D='PRIVATE' IN:PRIVATE,COMMERCIAL,TAXI,TRANSPORT,MOTORCYCLE,TEMPORARY,DIPLOMATIC,EXPORT | نوع اللوحة
VIN             V30              | رقم الهيكل (VIN)
MAKE            V100 NN          | الشركة المصنعة
MODEL           V100             | الطراز
MODEL_YEAR      INT              | سنة الصنع
COLOR           V50              | اللون
ENGINE          V100             | المحرك
FUEL_TYPE       CODE IN:PETROL,DIESEL,HYBRID,ELECTRIC,GAS | الوقود
TRANSMISSION    CODE IN:AUTOMATIC,MANUAL,CVT | ناقل الحركة
ODOMETER        INT              | آخر قراءة للعداد
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | المالك (حساب العميل)
OWNER_NAME      NAME             | اسم المالك
OWNER_PHONE     V30              | جوال المالك
DRIVER_NAME     V200             | السائق
DRIVER_PHONE    V30              | جوال السائق
INSURER_ID      ID   >AUT_INSURER | شركة التأمين
POLICY_NO       V50              | رقم الوثيقة
POLICY_EXPIRY   DATE             | انتهاء التأمين
REGISTRATION_EXPIRY DATE         | انتهاء الاستمارة
NEXT_SERVICE_DATE DATE           | موعد الخدمة التالية
NEXT_SERVICE_KM INT              | عداد الخدمة التالية
LAST_VISIT_AT   TS               | آخر زيارة
''', uk=[('COMPANY_ID', 'PLATE_NO')], ix=[('TENANT_ID', 'VIN'), ('COMPANY_ID', 'CUSTOMER_ACCOUNT_ID')], area='vehicle')

table('AUT_APPOINTMENT', 'حجوزات الصيانة', 'Service Appointments', scope='C', mix='pub doc status',
      status='BOOKED CONFIRMED ARRIVED NO_SHOW CANCELLED', cols='''
VEHICLE_ID      ID   >AUT_VEHICLE | المركبة
PLATE_NO        V30              | اللوحة (مركبة جديدة)
CUSTOMER_NAME   NAME             | العميل
PHONE           V30              | الجوال
START_AT        TS   NN          | موعد الوصول
END_AT          TS   NN          | نهاية الحجز المتوقعة
BAY_ID          ID   >AUT_BAY    | الرافعة
TECHNICIAN_ID   ID   >AUT_TECHNICIAN | الفني
SERVICE_IDS     V1000            | الخدمات المطلوبة (أرقام مفصولة بفواصل)
COMPLAINT       V2000            | الشكوى
SOURCE_CODE     CODE NN D='PHONE' IN:PHONE,WALK_IN,WHATSAPP,WEB,APP | المصدر
JOB_CARD_ID     ID               | أمر الإصلاح الناتج
CANCEL_REASON   V500             | سبب الإلغاء
''', ix=[('COMPANY_ID', 'START_AT')], area='booking')

table('AUT_JOB_CARD', 'أوامر الإصلاح', 'Job Cards', scope='C', mix='pub doc notes status',
      status='OPEN IN_PROGRESS WAITING_PARTS COMPLETED INVOICED DELIVERED CANCELLED', cols='''
VEHICLE_ID      ID   NN >AUT_VEHICLE | المركبة
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | العميل
CUSTOMER_NAME   NAME             | اسم العميل
CUSTOMER_PHONE  V30              | الجوال
APPOINTMENT_ID  ID   >AUT_APPOINTMENT | الحجز
BAY_ID          ID   >AUT_BAY    | الرافعة
ADVISOR_NAME    V200             | مستشار الخدمة
CHECKIN_AT      TS   NN          | وقت الاستلام
PROMISED_AT     TS               | الموعد المتوقع للتسليم
STARTED_AT      TS               | بدء العمل
COMPLETED_AT    TS               | انتهاء العمل
DELIVERED_AT    TS               | التسليم للعميل
ODOMETER_IN     INT              | العداد عند الاستلام
ODOMETER_OUT    INT              | العداد عند التسليم
FUEL_LEVEL      CODE IN:EMPTY,QUARTER,HALF,THREE_QUARTERS,FULL | مستوى الوقود
COMPLAINT       V4000            | شكوى العميل
DIAGNOSIS       V4000            | التشخيص
RECOMMENDATIONS V4000            | توصيات للعميل
INSPECTION      JSON             | فحص الاستلام (الملاحظات والأضرار والمتعلقات)
PAYER_TYPE      CODE NN D='CUSTOMER' IN:CUSTOMER,INSURANCE,WARRANTY,INTERNAL | جهة السداد
INSURER_ID      ID   >AUT_INSURER | شركة التأمين
CLAIM_NO        V50              | رقم المطالبة
POLICY_NO       V50              | رقم الوثيقة
ACCIDENT_REPORT_NO V50           | رقم تقرير الحادث (نجم/المرور)
CLAIM_STATUS    CODE IN:NOT_SUBMITTED,SUBMITTED,APPROVED,PARTIALLY_APPROVED,REJECTED,PAID | حالة المطالبة
APPROVED_AMOUNT AMT              | المبلغ المعتمد من التأمين (قبل الضريبة)
DEDUCTIBLE_AMOUNT AMT            | تحمل العميل (قبل الضريبة)
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع القطع
SALES_INVOICE_ID ID  >SAL_INVOICE | فاتورة العميل
INSURER_INVOICE_ID ID >SAL_INVOICE | فاتورة شركة التأمين
SERVICES_AMOUNT AMT              | صافي الخدمات
PARTS_AMOUNT    AMT              | صافي القطع
DISCOUNT_AMOUNT AMT              | الخصم
TAX_AMOUNT      AMT              | الضريبة
TOTAL_AMOUNT    AMT              | الإجمالي
NEXT_SERVICE_DATE DATE           | موعد الخدمة التالية
NEXT_SERVICE_KM INT              | عداد الخدمة التالية
CANCEL_REASON   V500             | سبب الإلغاء
''', ix=[('COMPANY_ID', 'VEHICLE_ID'), ('COMPANY_ID', 'STATUS_CODE'), ('COMPANY_ID', 'CHECKIN_AT')], area='job')

table('AUT_JOB_LINE', 'بنود أمر الإصلاح', 'Job Card Lines', scope='C', cols='''
JOB_CARD_ID     ID   NN >AUT_JOB_CARD | أمر الإصلاح
LINE_NO         INT  NN          | رقم البند
LINE_TYPE       CODE NN IN:SERVICE,PART,SUBLET | النوع
SERVICE_ID      ID   >AUT_SERVICE | الخدمة
ITEM_ID         ID   >INV_ITEM   | القطعة
PARENT_LINE_ID  ID   >AUT_JOB_LINE | الخدمة التي أضيفت معها القطعة
DESCRIPTION     V1000 NN         | البيان
QUANTITY        QTY  NN D=1      | الكمية
UNIT_PRICE      AMT  NN D=0      | سعر الوحدة
PRICE_INCLUDES_TAX YN NN D='N'   | السعر شامل الضريبة
DISCOUNT_AMOUNT AMT              | الخصم
NET_AMOUNT      AMT              | الصافي قبل الضريبة
TAX_AMOUNT      AMT              | الضريبة
UNIT_COST       AMT              | تكلفة الوحدة (القطع)
PAYER           CODE NN D='CUSTOMER' IN:CUSTOMER,INSURANCE,WARRANTY | يحمل على
TECHNICIAN_ID   ID   >AUT_TECHNICIAN | الفني المنفذ
WORK_MINUTES    INT              | مدة العمل بالدقائق
STARTED_AT      TS               | بدء البند
DONE_AT         TS               | انتهاء البند
LINE_STATUS     CODE NN D='PENDING' IN:PENDING,IN_PROGRESS,DONE,CANCELLED | حالة البند
NOTES           V500             | ملاحظات
''', uk=[('JOB_CARD_ID', 'LINE_NO')], ix=[('COMPANY_ID', 'SERVICE_ID'), ('COMPANY_ID', 'ITEM_ID'), ('COMPANY_ID', 'TECHNICIAN_ID')], area='job')
