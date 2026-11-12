from model.dsl import module, table

module(37, 'ENG', 'مركز الإدارة والتواصل', 'Management & Engagement Hub', 'NOONA_ENG_PKG',
       'بوابة العملاء والمحلات برابط آمن (الفواتير، الرصيد، كشف الحساب، تتبع الشحنات)، محرك واتساب (Cloud API أو روابط wa.me) '
       'بالقوالب وسجل الرسائل، توقع النقد 90 يوماً، قواعد الإنذار المبكر وتنبيهاتها، لوحة المدير على الهاتف، مركز المساعدة لكل شاشة، '
       'تصدير البيانات إلى Excel، وسجل التغييرات المقروء.')

table('ENG_PORTAL_LINK', 'روابط بوابة العملاء', 'Customer Portal Links', scope='C', mix='notes status', status='ACTIVE REVOKED', cols='''
CUSTOMER_ACCOUNT_ID ID NN >AR_CUSTOMER_ACCOUNT | حساب العميل
TOKEN_HASH      V64  NN          | بصمة الرمز (لا يخزن الرمز نصاً)
TOKEN_ENC       V500             | الرمز مشفراً (لإعادة إرسال الرابط)
TOKEN_HINT      V20              | آخر أحرف الرمز
EXPIRES_AT      TS               | ينتهي في
LAST_ACCESS_AT  TS               | آخر دخول
ACCESS_COUNT    INT  NN D=0      | مرات الدخول
PHONE           V30              | جوال الإرسال
''', uk=[('TOKEN_HASH',)], ix=[('TENANT_ID', 'CUSTOMER_ACCOUNT_ID')], area='portal')

table('ENG_WA_SETTING', 'إعدادات واتساب', 'WhatsApp Settings', scope='C', cols='''
PROVIDER        CODE NN D='LINK' IN:LINK,CLOUD_API | الطريقة (روابط wa.me أو WhatsApp Cloud API)
PHONE_NUMBER_ID V50              | معرف رقم الإرسال (Cloud API)
BUSINESS_ACCOUNT_ID V50          | معرف حساب الأعمال
API_VERSION     V10  NN D='v21.0' | إصدار الواجهة
TOKEN_ENC       V2000            | رمز الوصول مشفراً (يدخله المسؤول ولا يعرض)
DEFAULT_CC      V5   NN D='966'  | رمز الدولة الافتراضي
SENDER_PHONE    V30              | رقم الإرسال للعرض
IS_ENABLED      YN   NN D='Y'    | مفعل
''', uk=[('TENANT_ID', 'COMPANY_ID')], area='whatsapp')

table('ENG_WA_TEMPLATE', 'قوالب الرسائل', 'Message Templates', scope='C', mix='code names active', cols='''
EVENT_CODE      CODE NN D='GENERAL' IN:INVOICE,STATEMENT,PAYMENT,REMINDER,PORTAL,ORDER,ALERT,GENERAL | المناسبة
BODY_TEXT       V2000 NN         | النص ({customer} {amount} {invoice} {date} {balance} {link} {company})
CLOUD_TEMPLATE  V100             | اسم القالب المعتمد في Meta (للرسائل التي يبدؤها النظام)
LANGUAGE_CODE   V10  NN D='ar'   | لغة القالب
''', area='whatsapp')

table('ENG_MESSAGE', 'سجل الرسائل', 'Message Log', scope='C', mix='status', status='QUEUED SENT DELIVERED READ FAILED LINK', cols='''
CHANNEL         CODE NN D='WHATSAPP' IN:WHATSAPP,SMS,EMAIL | القناة
TO_PHONE        V30  NN          | إلى
TEMPLATE_ID     ID   >ENG_WA_TEMPLATE | القالب
BODY_TEXT       V4000            | النص
ENTITY_TYPE     V50              | الكيان المرتبط
ENTITY_ID       ID               | معرفه
CUSTOMER_ACCOUNT_ID ID >AR_CUSTOMER_ACCOUNT | العميل
PROVIDER_MSG_ID V200             | معرف الرسالة لدى المزود
ERROR_TEXT      V1000            | الخطأ
SENT_AT         TS               | وقت الإرسال
LINK_URL        V4000            | رابط wa.me (عند الإرسال اليدوي)
''', ix=[('TENANT_ID', 'COMPANY_ID', 'CREATED_AT'), ('TENANT_ID', 'CUSTOMER_ACCOUNT_ID')], area='whatsapp')

table('ENG_ALERT_RULE', 'قواعد الإنذار المبكر', 'Early-warning Rules', scope='C', mix='code names active', cols='''
METRIC          CODE NN IN:CASH_LOW,FORECAST_NEGATIVE,AR_OVERDUE,OVER_CREDIT_LIMIT,STOCK_BELOW_MIN,SALES_DROP,PENDING_COLLECTIONS,CHEQUES_DUE,AP_DUE | المؤشر
THRESHOLD       NUM              | الحد
DAYS            INT              | الأيام
SEVERITY        CODE NN D='MEDIUM' IN:LOW,MEDIUM,HIGH,CRITICAL | الخطورة
NOTIFY_WHATSAPP V30              | واتساب المدير (اختياري)
LAST_RUN_AT     TS               | آخر فحص
LAST_VALUE      NUM              | آخر قيمة
''', area='alerts')

table('ENG_ALERT', 'تنبيهات الإنذار المبكر', 'Early-warning Alerts', scope='C', mix='status', status='OPEN ACKNOWLEDGED CLOSED', cols='''
RULE_ID         ID   NN >ENG_ALERT_RULE | القاعدة
ALERT_DATE      DATE NN          | اليوم
SEVERITY        CODE NN          | الخطورة
TITLE           V500 NN          | العنوان
DETAIL          V4000            | التفاصيل
METRIC_VALUE    NUM              | القيمة
ACK_BY          USR              | استلمه
ACK_AT          TS               | وقت الاستلام
''', uk=[('TENANT_ID', 'COMPANY_ID', 'RULE_ID', 'ALERT_DATE')], area='alerts')

table('ENG_HELP', 'مساعدة الشاشات', 'Screen Help', scope='TO', cols='''
APP_ALIAS       V50  NN          | التطبيق
PAGE_ID         INT  NN          | الصفحة
TITLE           V200             | العنوان
PURPOSE         V4000            | الغرض من الشاشة
STEPS           V4000            | خطوات العمل (سطر لكل خطوة)
TIPS            V4000            | تنبيهات ونصائح
VIDEO_URL       V500             | رابط فيديو الشرح
''', ix=[('APP_ALIAS', 'PAGE_ID')], area='help')

table('ENG_CHANGE_LOG', 'سجل التغييرات', 'Change Log', scope='T', append=True, cols='''
COMPANY_ID      ID               | الشركة
TABLE_NAME      V128 NN          | الجدول
ROW_ID          ID   NN          | السجل
ACTION          CODE NN IN:INSERT,UPDATE,DELETE | الإجراء
CHANGES         JSON             | الحقول المتغيرة [{c,o,n}]
CHANGED_BY      V128             | بواسطة
CHANGED_AT      TS   NN D=SYSTIMESTAMP | الوقت
''', ix=[('TENANT_ID', 'TABLE_NAME', 'ROW_ID'), ('TENANT_ID', 'CHANGED_AT')], area='history')
