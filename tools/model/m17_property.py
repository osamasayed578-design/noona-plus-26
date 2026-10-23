from model.dsl import module, table

module(17, 'PRP', 'إدارة الأملاك والإيجارات والضيافة', 'Property Management, Leasing & Hospitality', 'NOONA_PROPERTY_PKG',
       'دورة الإيجار Lease → Rent Schedule → Move-in/out مع التأمينات والعدادات وكشوف الملاك؛ وموديول '
       'NOONA Hospitality المستقل Reservation → Stay → Folio → Check-in/out → Night Audit مع مخزون غرف '
       'زمني و Housekeeping و Unified Front Desk Room Rack، مع مشاركة العملاء والنقدية وPOS والصيانة والمحاسبة.')

# =============================================================== Leasing
table('PRP_MANAGEMENT_AGREEMENT', 'اتفاقيات إدارة الأملاك', 'Property Management Agreements', scope='C', mix='pub doc eff wf status',
      status='DRAFT ACTIVE SUSPENDED TERMINATED EXPIRED', cols='''
OWNER_PARTY_ID  ID   NN >PTY_PARTY | المالك
PROPERTY_ID     ID   NN >RE_PROPERTY | العقار
FEE_TYPE        CODE NN IN:PCT_OF_COLLECTION,PCT_OF_RENT,FIXED_MONTHLY,MIXED | أساس الأتعاب
FEE_PCT         PCT              | النسبة
FEE_FIXED       AMT              | المبلغ الثابت
CURRENCY_CODE   CUR  NN          | العملة
REMIT_FREQUENCY CODE NN D='MONTHLY' IN:MONTHLY,QUARTERLY | دورية التحويل للمالك
OWNER_BANK_ACCOUNT_ID ID >PTY_BANK_ACCOUNT | حساب المالك
''', area='leasing')

table('PRP_LEASE', 'عقود الإيجار', 'Leases', scope='C', mix='pub doc cur wf status',
      status='DRAFT APPROVED SIGNED ACTIVE RENEWAL_PENDING RENEWED EXPIRED TERMINATED CANCELLED', cols='''
LEASE_TYPE      CODE NN IN:RESIDENTIAL,COMMERCIAL,RETAIL,INDUSTRIAL,LAND,PARKING | النوع
PROPERTY_ID     ID   NN >RE_PROPERTY | العقار
LESSEE_PARTY_ID ID   NN >PTY_PARTY | المستأجر
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | حساب المستأجر
MANAGEMENT_AGREEMENT_ID ID >PRP_MANAGEMENT_AGREEMENT | اتفاقية الإدارة (أملاك الغير)
START_DATE      DATE NN          | البداية
END_DATE        DATE NN          | النهاية
BILLING_FREQUENCY CODE NN D='MONTHLY' IN:MONTHLY,QUARTERLY,SEMI_ANNUAL,ANNUAL,UPFRONT | دورية الفوترة
BILLING_IN_ADVANCE YN NN D='Y'   | فوترة مقدمة
ANNUAL_RENT     AMT  NN          | الإيجار السنوي
DEPOSIT_AMOUNT  AMT  NN D=0      | التأمين
ESCALATION_RULE JSON             | قاعدة الزيادة السنوية
NOTICE_DAYS     INT              | مدة الإشعار
GRACE_DAYS      INT              | فترة السماح للسداد
REGISTRATION_NO V100             | رقم التوثيق الحكومي (إيجار/Ejari)
PREVIOUS_LEASE_ID ID >PRP_LEASE  | العقد السابق (التجديد)
MOVE_IN_DATE    DATE             | تاريخ الاستلام
MOVE_OUT_DATE   DATE             | تاريخ الإخلاء
SIGNED_DOCUMENT_ID ID >DMS_DOCUMENT | العقد الموقع
TERMINATION_REASON V1000         | سبب الإنهاء
''', chk=['END_DATE > START_DATE'], ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE', 'END_DATE')], area='leasing')

table('PRP_LEASE_UNIT', 'وحدات عقد الإيجار', 'Lease Units', scope='C', mix='eff', cols='''
LEASE_ID        ID   NN >PRP_LEASE | العقد
UNIT_ID         ID   NN >RE_UNIT | الوحدة
RENT_SHARE      AMT              | حصة الوحدة من الإيجار
''', uk=[('LEASE_ID', 'UNIT_ID')], ix=[('TENANT_ID', 'UNIT_ID')], area='leasing',
      purpose='يمنع تأجير الوحدة لعقدين نشطين متداخلين (يفحص في الحزمة)')

table('PRP_LEASE_CHARGE', 'بنود رسوم الإيجار', 'Lease Charges', scope='C', mix='eff', cols='''
LEASE_ID        ID   NN >PRP_LEASE | العقد
CHARGE_TYPE     CODE NN IN:RENT,SERVICE_CHARGE,UTILITIES,PARKING,MAINTENANCE,MANAGEMENT_FEE,PENALTY,OTHER | النوع
AMOUNT          AMT  NN          | المبلغ للفترة
FREQUENCY       CODE NN IN:MONTHLY,QUARTERLY,SEMI_ANNUAL,ANNUAL,ONE_TIME,METERED | التكرار
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
REVENUE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الإيراد
''', area='leasing')

table('PRP_RENT_SCHEDULE', 'جدول استحقاقات الإيجار', 'Rent Schedule', scope='C', mix='status',
      status='SCHEDULED INVOICED PARTIALLY_PAID PAID OVERDUE WAIVED CANCELLED', cols='''
LEASE_ID        ID   NN >PRP_LEASE | العقد
CHARGE_ID       ID   >PRP_LEASE_CHARGE | البند
PERIOD_FROM     DATE NN          | من
PERIOD_TO       DATE NN          | إلى
DUE_DATE        DATE NN          | الاستحقاق
AMOUNT          AMT  NN          | المبلغ
TAX_AMOUNT      AMT  NN D=0      | الضريبة
SALES_INVOICE_ID ID  >SAL_INVOICE | الفاتورة
AR_OPEN_ITEM_ID ID   >AR_OPEN_ITEM | الذمة
''', ix=[('TENANT_ID', 'LEASE_ID'), ('TENANT_ID', 'DUE_DATE', 'STATUS_CODE')], area='leasing')

table('PRP_LEASE_EVENT', 'أحداث عقد الإيجار', 'Lease Events', scope='C', mix='wf status', status='DRAFT APPROVED EFFECTIVE CANCELLED', cols='''
LEASE_ID        ID   NN >PRP_LEASE | العقد
EVENT_TYPE      CODE NN IN:AMENDMENT,RENEWAL,ESCALATION,RENT_FREE,TERMINATION_NOTICE,EARLY_TERMINATION,MOVE_IN,MOVE_OUT,EVICTION,TRANSFER | النوع
EFFECTIVE_DATE  DATE NN          | السريان
CHANGES         JSON             | التغييرات
REASON          V1000            | السبب
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند
''', area='leasing')

table('PRP_SECURITY_DEPOSIT', 'التأمينات', 'Security Deposits', scope='C', mix='cur status', status='HELD PARTIALLY_REFUNDED REFUNDED FORFEITED APPLIED', cols='''
LEASE_ID        ID   NN >PRP_LEASE | العقد
RECEIVED_AMOUNT AMT  NN          | المستلم
DEDUCTED_AMOUNT AMT  NN D=0      | الخصومات
REFUNDED_AMOUNT AMT  NN D=0      | المردود
RECEIPT_ID      ID   >AR_RECEIPT | إيصال الاستلام
REFUND_ID       ID   >AR_REFUND  | الرد
DEDUCTION_DETAILS JSON           | تفاصيل الخصومات
''', area='leasing')

table('PRP_INSPECTION', 'معاينات الوحدات', 'Unit Inspections', scope='C', mix='status', status='SCHEDULED DONE DISPUTED CLOSED', cols='''
UNIT_ID         ID   NN >RE_UNIT | الوحدة
LEASE_ID        ID   >PRP_LEASE  | العقد
INSPECTION_TYPE CODE NN IN:MOVE_IN,MOVE_OUT,PERIODIC,COMPLAINT | النوع
INSPECTION_DATE DATE NN          | التاريخ
INSPECTOR_EMPLOYEE_ID ID >HR_EMPLOYEE | المعاين
CONDITION_REPORT JSON            | تقرير الحالة
REPORT_DOCUMENT_ID ID >DMS_DOCUMENT | التقرير والصور
''', area='leasing')

table('PRP_METER', 'العدادات', 'Utility Meters', scope='C', mix='code status', status='ACTIVE REPLACED REMOVED', codeuk=False, cols='''
UNIT_ID         ID   >RE_UNIT    | الوحدة
PROPERTY_ID     ID   >RE_PROPERTY | أو العقار (عداد مشترك)
METER_TYPE      CODE NN IN:ELECTRICITY,WATER,GAS,CHILLED_WATER | النوع
METER_NO        V100 NN          | رقم العداد
UTILITY_ACCOUNT_NO V100          | رقم حساب المرفق
''', uk=[('TENANT_ID', 'METER_TYPE', 'METER_NO')], area='utilities')

table('PRP_METER_READING', 'قراءات العدادات', 'Meter Readings', scope='C', cols='''
METER_ID        ID   NN >PRP_METER | العداد
READING_DATE    DATE NN          | التاريخ
READING_VALUE   QTY  NN          | القراءة
CONSUMPTION     QTY  @CALC       | الاستهلاك
SOURCE_CODE     CODE NN D='MANUAL' IN:MANUAL,IMPORT,HANDOVER,MOVE_OUT | المصدر
RENT_SCHEDULE_ID ID  >PRP_RENT_SCHEDULE | الفوترة الناتجة
''', uk=[('METER_ID', 'READING_DATE')], area='utilities')

table('PRP_OWNER_STATEMENT', 'كشوف حسابات الملاك', 'Owner Statements', scope='C', mix='doc status', status='DRAFT APPROVED SENT REMITTED', cols='''
MANAGEMENT_AGREEMENT_ID ID NN >PRP_MANAGEMENT_AGREEMENT | الاتفاقية
PERIOD_FROM     DATE NN          | من
PERIOD_TO       DATE NN          | إلى
COLLECTIONS     AMT  NN D=0      | المحصل
EXPENSES        AMT  NN D=0      | المصروفات
MANAGEMENT_FEE  AMT  NN D=0      | الأتعاب
NET_TO_OWNER    AMT  NN D=0      | الصافي للمالك
AP_PAYMENT_ID   ID   >AP_PAYMENT | التحويل للمالك
DOCUMENT_ID     ID   >DMS_DOCUMENT | الكشف
''', area='leasing')

# =============================================================== Hospitality
table('HSP_ROOM_TYPE', 'أنواع الغرف', 'Room Types', scope='C', mix='code names active', cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | الفندق/المبنى
MAX_ADULTS      INT  NN D=2      | أقصى بالغين
MAX_CHILDREN    INT  NN D=0      | أقصى أطفال
BED_CONFIG      V100             | الأسرة
BASE_RATE       AMT              | السعر الأساسي
''', area='hospitality')

table('HSP_ROOM', 'الغرف والشقق الفندقية', 'Rooms', scope='C', mix='code status', codeuk=False,
      status='ACTIVE OUT_OF_ORDER OUT_OF_SERVICE INACTIVE', cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | الفندق
ROOM_TYPE_ID    ID   NN >HSP_ROOM_TYPE | النوع
UNIT_ID         ID   >RE_UNIT    | الوحدة في السجل العقاري
ROOM_NO         V20  NN          | رقم الغرفة
FLOOR_ID        ID   >RE_FLOOR   | الطابق
FRONT_DESK_STATUS CODE NN D='VACANT' IN:VACANT,OCCUPIED,DUE_OUT,DUE_IN,RESERVED,BLOCKED | حالة الاستقبال
HOUSEKEEPING_STATUS CODE NN D='CLEAN' IN:CLEAN,DIRTY,INSPECTED,IN_PROGRESS,OUT_OF_ORDER | حالة النظافة
CONNECTED_ROOM_ID ID >HSP_ROOM   | غرفة متصلة
NOTES           V500             | ملاحظات الغرفة
''', uk=[('PROPERTY_ID', 'ROOM_NO')], area='hospitality')

table('HSP_RATE_PLAN', 'خطط الأسعار', 'Rate Plans', scope='C', mix='code names cur eff active', cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | الفندق
MEAL_PLAN       CODE IN:ROOM_ONLY,BREAKFAST,HALF_BOARD,FULL_BOARD,ALL_INCLUSIVE | الوجبات
CANCELLATION_POLICY V1000        | سياسة الإلغاء
STAY_TYPE       CODE NN D='DAILY' IN:DAILY,WEEKLY,MONTHLY | نوع الإقامة (يومي/أسبوعي/شهري مفروش)
INCLUDES_TAX    YN   NN D='N'    | شامل الضريبة
''', area='hospitality')

table('HSP_RATE', 'أسعار الغرف', 'Room Rates', scope='C', cols='''
RATE_PLAN_ID    ID   NN >HSP_RATE_PLAN | الخطة
ROOM_TYPE_ID    ID   NN >HSP_ROOM_TYPE | النوع
DATE_FROM       DATE NN          | من
DATE_TO         DATE NN          | إلى
RATE_AMOUNT     AMT  NN          | السعر لليلة/الفترة
EXTRA_ADULT     AMT              | بالغ إضافي
MIN_STAY_NIGHTS INT              | أقل مدة
''', uk=[('RATE_PLAN_ID', 'ROOM_TYPE_ID', 'DATE_FROM')], chk=['DATE_TO >= DATE_FROM'], area='hospitality')

table('HSP_RESERVATION', 'حجوزات الضيافة', 'Hospitality Reservations', scope='C', mix='pub doc cur status',
      status='TENTATIVE CONFIRMED GUARANTEED CHECKED_IN CHECKED_OUT NO_SHOW CANCELLED WAITLIST', cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | الفندق
GUEST_PARTY_ID  ID   NN >PTY_PARTY | الضيف الرئيسي
COMPANY_PARTY_ID ID  >PTY_PARTY  | الشركة/الجهة الحاجزة
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | حساب الفوترة (City Ledger)
CHANNEL_CODE    CODE NN D='WALK_IN' IN:WALK_IN,PHONE,EMAIL,WEBSITE,OTA,CORPORATE,TRAVEL_AGENT | القناة
CHANNEL_REFERENCE V100           | مرجع القناة
ARRIVAL_DATE    DATE NN          | الوصول
DEPARTURE_DATE  DATE NN          | المغادرة
ADULTS          INT  NN D=1      | البالغون
CHILDREN        INT  NN D=0      | الأطفال
RATE_PLAN_ID    ID   >HSP_RATE_PLAN | خطة السعر
TOTAL_ESTIMATE  AMT              | الإجمالي التقديري
DEPOSIT_AMOUNT  AMT  NN D=0      | العربون
SPECIAL_REQUESTS V2000           | الطلبات الخاصة
CANCELLED_AT    TS               | وقت الإلغاء
''', chk=['DEPARTURE_DATE > ARRIVAL_DATE'], ix=[('TENANT_ID', 'PROPERTY_ID', 'ARRIVAL_DATE')], area='hospitality')

table('HSP_RESERVATION_ROOM', 'غرف الحجز', 'Reservation Rooms', scope='C', mix='status', status='PENDING ASSIGNED CHECKED_IN CHECKED_OUT CANCELLED', cols='''
RESERVATION_ID  ID   NN >HSP_RESERVATION | الحجز
ROOM_TYPE_ID    ID   NN >HSP_ROOM_TYPE | النوع المطلوب
ROOM_ID         ID   >HSP_ROOM   | الغرفة المسندة
ARRIVAL_DATE    DATE NN          | الوصول
DEPARTURE_DATE  DATE NN          | المغادرة
NIGHTLY_RATE    AMT              | السعر لليلة (Snapshot)
''', chk=['DEPARTURE_DATE > ARRIVAL_DATE'], area='hospitality')

table('HSP_ROOM_BLOCK', 'مخزون الغرف الزمني', 'Room Inventory Blocks', scope='C', cols='''
ROOM_ID         ID   NN >HSP_ROOM | الغرفة
STAY_DATE       DATE NN          | الليلة
BLOCK_TYPE      CODE NN IN:RESERVATION,STAY,MAINTENANCE,OWNER_USE,OUT_OF_ORDER,HOLD | سبب الإشغال
RESERVATION_ROOM_ID ID >HSP_RESERVATION_ROOM | الحجز
STAY_ID         ID   >HSP_STAY   | الإقامة
MAINTENANCE_WO_ID ID >MNT_WORK_ORDER | أمر الصيانة
''', uk=[('ROOM_ID', 'STAY_DATE')], area='hospitality',
      purpose='صف لكل غرفة/ليلة يمنع الحجز المزدوج بالقيد الفريد؛ Overbooking يعالج بخطة معتمدة')

table('HSP_STAY', 'الإقامات', 'Stays', scope='C', mix='status', status='IN_HOUSE CHECKED_OUT ROOM_MOVED CANCELLED', cols='''
RESERVATION_ID  ID   >HSP_RESERVATION | الحجز (فارغ = Walk-in مباشر)
RESERVATION_ROOM_ID ID >HSP_RESERVATION_ROOM | غرفة الحجز
ROOM_ID         ID   NN >HSP_ROOM | الغرفة
CHECK_IN_AT     TS   NN          | وقت الدخول
EXPECTED_CHECK_OUT DATE NN       | المغادرة المتوقعة
CHECK_OUT_AT    TS               | وقت الخروج
CHECKED_IN_BY_MEMBER_ID ID >SEC_USER_MEMBERSHIP | موظف الاستقبال
PREVIOUS_STAY_ID ID  >HSP_STAY   | الإقامة السابقة عند تغيير الغرفة
NIGHTLY_RATE    AMT              | سعر الليلة المطبق
LAST_CHARGED_DATE DATE           | آخر ليلة رحلت رسومها
''', ix=[('TENANT_ID', 'ROOM_ID', 'STATUS_CODE')], area='hospitality')

table('HSP_STAY_GUEST', 'نزلاء الإقامة', 'Stay Guests', scope='C', cols='''
STAY_ID         ID   NN >HSP_STAY | الإقامة
GUEST_PARTY_ID  ID   NN >PTY_PARTY | النزيل
IDENTIFICATION_ID ID >PTY_IDENTIFICATION | وثيقة الهوية/الجواز
IS_PRIMARY      YN   NN D='N'    | النزيل الرئيسي
GOV_REPORT_REF  V100             | مرجع إبلاغ الجهات (شموس/طوارئ)
ID_DATA_PURGE_DATE DATE          | تاريخ إتلاف بيانات الهوية (احتفاظ محدود)
''', area='hospitality', sens='HIGHLY_RESTRICTED')

table('HSP_FOLIO', 'فواتير النزلاء المفتوحة', 'Guest Folios', scope='C', mix='pub cur status', status='OPEN SETTLED CLOSED TRANSFERRED VOID', cols='''
FOLIO_NO        V50  NN          | رقم الحساب
STAY_ID         ID   >HSP_STAY   | الإقامة
RESERVATION_ID  ID   >HSP_RESERVATION | الحجز
FOLIO_TYPE      CODE NN D='GUEST' IN:GUEST,COMPANY,GROUP_MASTER,NON_GUEST | النوع
PAYER_PARTY_ID  ID   >PTY_PARTY  | الدافع
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | التحويل إلى City Ledger
BALANCE         AMT  NN D=0 @CALC | الرصيد
SALES_INVOICE_ID ID  >SAL_INVOICE | الفاتورة الضريبية النهائية
''', uk=[('TENANT_ID', 'COMPANY_ID', 'FOLIO_NO')], area='hospitality')

table('HSP_FOLIO_LINE', 'حركات الفوليو', 'Folio Lines', scope='C', append=True, cols='''
FOLIO_ID        ID   NN >HSP_FOLIO | الحساب
BUSINESS_DATE   DATE NN          | تاريخ العمل الفندقي
LINE_TYPE       CODE NN IN:ROOM_CHARGE,TAX,SERVICE_CHARGE,F_AND_B,LAUNDRY,MINIBAR,POS_CHARGE,OTHER_CHARGE,PAYMENT,ADJUSTMENT,TRANSFER | النوع
DESCRIPTION     V500 NN          | البيان
AMOUNT          AMT  NN          | المبلغ (مدين موجب / دفعة سالب)
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
POS_SALE_ID     ID   >POS_SALE   | بيع POS المحمل
CASH_TRANSACTION_ID ID >CSH_TRANSACTION | الدفعة
NIGHT_AUDIT_ID  ID   >HSP_NIGHT_AUDIT | التدقيق الليلي المرحل
REVERSAL_OF_ID  ID   >HSP_FOLIO_LINE | السطر المعكوس
PAYMENT_METHOD  CODE IN:CASH,CARD,BANK_TRANSFER,CITY_LEDGER | طريقة السداد
REFERENCE_NO    V100             | المرجع (رقم العملية/الإيصال)
''', ix=[('TENANT_ID', 'FOLIO_ID')], area='hospitality', purpose='لا تعدل الحركات؛ التصحيح بسطر عكسي')

table('HSP_NIGHT_AUDIT', 'التدقيق الليلي', 'Night Audits', scope='C', mix='status', status='RUNNING COMPLETED FAILED ROLLED_BACK', cols='''
PROPERTY_ID     ID   NN >RE_PROPERTY | الفندق
BUSINESS_DATE   DATE NN          | تاريخ العمل المقفل
ROOM_REVENUE    AMT              | إيراد الغرف
OCCUPANCY_PCT   PCT              | نسبة الإشغال
ADR             AMT              | متوسط سعر الغرفة
NO_SHOWS        INT              | عدم الحضور
ACCOUNTING_EVENT_ID ID >ACE_ACCOUNTING_EVENT | الحدث المحاسبي
''', uk=[('PROPERTY_ID', 'BUSINESS_DATE')], area='hospitality')

table('HSP_HOUSEKEEPING_TASK', 'مهام التدبير الفندقي', 'Housekeeping Tasks', scope='C', mix='status',
      status='PENDING ASSIGNED IN_PROGRESS DONE INSPECTED REJECTED', cols='''
ROOM_ID         ID   NN >HSP_ROOM | الغرفة
TASK_DATE       DATE NN          | التاريخ
TASK_TYPE       CODE NN IN:DEPARTURE_CLEAN,STAYOVER,DEEP_CLEAN,TURNDOWN,INSPECTION | النوع
ASSIGNED_EMPLOYEE_ID ID >HR_EMPLOYEE | العامل
STARTED_AT      TS               | البداية
COMPLETED_AT    TS               | الانتهاء
INSPECTED_BY    USR              | المفتش
''', ix=[('TENANT_ID', 'TASK_DATE', 'STATUS_CODE')], area='hospitality')

table('HSP_ROOM_DISCREPANCY', 'اختلافات حالة الغرف', 'Room Status Discrepancies', scope='C', mix='status', status='OPEN RESOLVED', cols='''
ROOM_ID         ID   NN >HSP_ROOM | الغرفة
FRONT_DESK_STATUS CODE NN        | حالة الاستقبال
HOUSEKEEPING_STATUS CODE NN      | حالة التدبير
DETECTED_AT     TS   NN D=SYSTIMESTAMP | وقت الاكتشاف
RESOLUTION      V1000            | المعالجة
''', area='hospitality', purpose='مطابقة اختلاف Front Desk مقابل Housekeeping (Skip/Sleep)')
