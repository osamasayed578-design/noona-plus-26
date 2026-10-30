from model.dsl import module, table

module(23, 'API', 'ORDS وواجهات API والتكاملات', 'ORDS, APIs & Integrations', 'NOONA_API_PKG',
       'Integration Matrix، وعملاء API وأسرارهم بمراجع Vault، وسجل نقاط النهاية بإصداراتها، وسجل الطلبات، '
       'ومفاتيح Idempotency، و Outbox/Inbox للأحداث الصادرة والواردة مع Retry و Dead-Letter، والـWebhooks.')

table('API_INTEGRATION', 'مصفوفة التكاملات', 'Integration Matrix', scope='TO', mix='code names status', status='PLANNED SANDBOX ACTIVE SUSPENDED RETIRED', cols='''
PROVIDER_NAME   V200 NN          | الطرف/المزود
INTEGRATION_TYPE CODE NN IN:PAYMENT_GATEWAY,BANK,EMAIL,SMS,WHATSAPP,PUSH,E_INVOICE,E_SIGNATURE,GOVERNMENT,PARTNER,AI,OCR,STORAGE,IDENTITY,OTHER | النوع
COUNTRY_CODE    CTRY             | الدولة
OWNER_NAME      V200             | المالك الداخلي
DIRECTION       CODE NN IN:OUTBOUND,INBOUND,BIDIRECTIONAL | اتجاه البيانات
CONTRACT_VERSION V50             | إصدار العقد/الواجهة
AUTH_METHOD     CODE IN:API_KEY,OAUTH2,MTLS,BASIC,JWT,HMAC,CERTIFICATE | طريقة المصادقة
HANDLES_PII     YN   NN D='N'    | يتضمن بيانات شخصية
DATA_RESIDENCY  V200             | إقامة البيانات
SLA_INFO        V500             | SLA
FAILURE_POLICY  V1000            | سياسة الفشل والتراجع
IDEMPOTENCY_STRATEGY V500        | استراتيجية منع التكرار (إلزامية قبل الاعتماد)
''', area='registry', purpose='لا يعتمد أي تكامل قبل تحديد مالك البيانات و Idempotency (7.5)')

table('API_INTEGRATION_CONFIG', 'إعدادات التكامل للمؤسسة', 'Tenant Integration Config', scope='T', mix='status', status='DRAFT ACTIVE DISABLED', cols='''
INTEGRATION_ID  ID   NN >API_INTEGRATION | التكامل
COMPANY_ID      ID   >ORG_COMPANY | الشركة
ENVIRONMENT     CODE NN D='SANDBOX' IN:SANDBOX,PRODUCTION | البيئة
CONFIG_INFO     JSON             | الإعدادات غير السرية
SECRET_REF      V200             | مرجع الأسرار في Vault (لا تظهر بعد الحفظ)
LAST_TESTED_AT  TS               | آخر اختبار
''', uk=[('TENANT_ID', 'INTEGRATION_ID', 'COMPANY_ID', 'ENVIRONMENT')], area='registry')

table('API_CLIENT', 'عملاء API', 'API Clients', scope='T', mix='pub names status', status='ACTIVE SUSPENDED REVOKED EXPIRED', cols='''
CLIENT_ID       V100 NN          | معرف العميل
SERVICE_USER_ID ID   >SEC_USER   | حساب الخدمة المرتبط
OWNER_MEMBER_ID ID   >SEC_USER_MEMBERSHIP | مالك الأعمال
SCOPES          V2000            | النطاقات المسموحة
IP_ALLOWLIST    V2000            | عناوين IP المسموحة
RATE_LIMIT_PER_MIN INT           | حد المعدل
EXPIRES_AT      TS               | الانتهاء
COMPANY_ID      ID   >ORG_COMPANY | الشركة التي يعمل فيها العميل
ROLE_ID         ID   >SEC_ROLE   | الدور (صلاحيات العميل)
DESCRIPTION     V500             | الوصف والاستخدام
TOKEN_TTL_MIN   INT  NN D=60     | صلاحية رمز الدخول بالدقائق
''', uk=[('CLIENT_ID',)], area='security')

table('API_CLIENT_SECRET', 'أسرار عملاء API', 'API Client Secrets', scope='T', mix='status', status='ACTIVE ROTATING REVOKED EXPIRED', cols='''
API_CLIENT_ID   ID   NN >API_CLIENT | العميل
SECRET_HASH     V512 NN          | Hash السر فقط
SECRET_HINT     V10              | آخر أحرف للتعرف
EXPIRES_AT      TS               | الانتهاء
LAST_USED_AT    TS               | آخر استخدام
''', area='security', sens='HIGHLY_RESTRICTED')

table('API_ACCESS_TOKEN', 'رموز الدخول', 'API Access Tokens', scope='T', cols='''
API_CLIENT_ID   ID   NN >API_CLIENT | العميل
TOKEN_HASH      V128 NN          | Hash الرمز فقط
SESSION_REF     NUM  NN          | مرجع جلسة الخدمة
EXPIRES_AT      TS   NN          | الانتهاء
REVOKED_AT      TS               | الإلغاء
CLIENT_IP       V45              | IP
''', uk=[('TOKEN_HASH',)], ix=[('API_CLIENT_ID', 'EXPIRES_AT')], area='security', sens='HIGHLY_RESTRICTED')

table('API_ENDPOINT', 'نقاط النهاية', 'API Endpoints', scope='G', mix='active', cols='''
MODULE_CODE     CODE NN          | الحزمة
API_VERSION     V10  NN          | الإصدار (v1...)
HTTP_METHOD     CODE NN IN:GET,POST,PUT,PATCH,DELETE | الطريقة
PATH_TEMPLATE   V500 NN          | المسار
PERMISSION_CODE V100 >SEC_PERMISSION.PERMISSION_CODE | الصلاحية المطلوبة
HANDLER_API     V128 NN          | حزمة الأعمال المستدعاة (لا SQL مكرر)
REQUIRES_IDEMPOTENCY YN NN D='N' | يتطلب Idempotency-Key
DEPRECATED_AT   DATE             | تاريخ الإيقاف المعلن
SUNSET_AT       DATE             | تاريخ التقاعد
''', uk=[('API_VERSION', 'HTTP_METHOD', 'PATH_TEMPLATE')], area='registry')

table('API_REQUEST_LOG', 'سجل طلبات API', 'API Request Log', scope='TO', append=True, cols='''
REQUEST_ID      V64  NN          | معرف الطلب
CORRELATION_ID  V64              | معرف الارتباط
API_CLIENT_ID   ID   >API_CLIENT | العميل
ENDPOINT_ID     ID   >API_ENDPOINT | النقطة
HTTP_STATUS     INT              | رمز الاستجابة
DURATION_MS     INT              | المدة
REQUEST_SIZE    INT              | الحجم
CLIENT_IP       V45              | IP
ERROR_CODE      V50              | رمز الخطأ (بدون Tokens أو بيانات حساسة)
''', ix=[('TENANT_ID', 'CREATED_AT'), ('CORRELATION_ID',)], area='operations', ret='90 يوماً افتراضياً')

table('API_IDEMPOTENCY_KEY', 'مفاتيح منع التكرار', 'Idempotency Keys', scope='T', cols='''
IDEMPOTENCY_KEY V200 NN          | المفتاح
SCOPE_CODE      V100 NN          | العملية
REQUEST_HASH    HASH NN          | Hash الطلب (رفض نفس المفتاح بطلب مختلف)
RESPONSE_STATUS INT              | الاستجابة المخزنة
RESPONSE_BODY   CLOB             | جسم الاستجابة
RESULT_ENTITY_TYPE V50 >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | الكيان الناتج
RESULT_ENTITY_ID ID              | معرفه
EXPIRES_AT      TS   NN          | الانتهاء
''', uk=[('TENANT_ID', 'SCOPE_CODE', 'IDEMPOTENCY_KEY')], area='reliability')

table('API_OUTBOX', 'صندوق الأحداث الصادرة', 'Transactional Outbox', scope='TO', mix='status',
      status='PENDING PROCESSING SENT FAILED DEAD CANCELLED', cols='''
AGGREGATE_TYPE  V50  NN          | نوع الكيان
AGGREGATE_ID    ID   NN          | معرفه
EVENT_TYPE      V100 NN          | الحدث (SAL_INVOICE.POSTED...)
EVENT_VERSION   INT  NN D=1      | إصدار المخطط
PAYLOAD         JSON NN          | الحمولة (بدون أسرار)
DESTINATION     V100 NN          | الوجهة (POSTING، NOTIFICATION، WEBHOOK، EINVOICE، AI_INDEX...)
PRIORITY_NO     INT  NN D=5      | الأولوية
ATTEMPTS        INT  NN D=0      | المحاولات
NEXT_ATTEMPT_AT TS   NN D=SYSTIMESTAMP | المحاولة التالية (Backoff)
LAST_ERROR      V4000            | آخر خطأ
CORRELATION_ID  V64              | معرف الارتباط
PROCESSED_AT    TS               | وقت المعالجة
COMPANY_ID      ID   >ORG_COMPANY | الشركة
''', ix=[('STATUS_CODE', 'NEXT_ATTEMPT_AT'), ('TENANT_ID', 'AGGREGATE_TYPE', 'AGGREGATE_ID')], area='reliability',
      purpose='يكتب مع المعاملة نفسها ثم ينشر لاحقاً؛ يضمن عدم فقد الأحداث')

table('API_INBOX', 'صندوق الرسائل الواردة', 'Inbound Message Inbox', scope='TO', mix='status', status='RECEIVED PROCESSING PROCESSED DUPLICATE FAILED DEAD', cols='''
SOURCE_SYSTEM   V100 NN          | المصدر
MESSAGE_ID      V200 NN          | معرف الرسالة لدى المصدر
MESSAGE_TYPE    V100 NN          | النوع
SIGNATURE_VALID YN   NN D='N'    | التحقق من التوقيع
PAYLOAD         JSON             | الحمولة
ATTEMPTS        INT  NN D=0      | المحاولات
LAST_ERROR      V4000            | الخطأ
PROCESSED_AT    TS               | وقت المعالجة
''', uk=[('SOURCE_SYSTEM', 'MESSAGE_ID')], area='reliability')

table('API_WEBHOOK_SUBSCRIPTION', 'اشتراكات Webhook', 'Webhook Subscriptions', scope='T', mix='status', status='ACTIVE PAUSED DISABLED', cols='''
API_CLIENT_ID   ID   >API_CLIENT | العميل
EVENT_TYPE      V100 NN          | الحدث
TARGET_URL      V1000 NN         | العنوان
SIGNING_SECRET_REF V200 NN       | مرجع سر التوقيع
FAILURE_COUNT   INT  NN D=0      | الإخفاقات المتتالية
COMPANY_ID      ID   >ORG_COMPANY | الشركة
DESCRIPTION     V500             | الوصف
LAST_DELIVERY_AT TS              | آخر تسليم
LAST_HTTP_STATUS INT             | آخر استجابة
''', area='webhook')

table('API_WEBHOOK_DELIVERY', 'تسليمات Webhook', 'Webhook Deliveries', scope='T', mix='status', status='PENDING DELIVERED FAILED DEAD', cols='''
SUBSCRIPTION_ID ID   NN >API_WEBHOOK_SUBSCRIPTION | الاشتراك
OUTBOX_ID       ID   >API_OUTBOX | الحدث
ATTEMPT_NO      INT  NN D=1      | المحاولة
HTTP_STATUS     INT              | الاستجابة
DURATION_MS     INT              | المدة
NEXT_RETRY_AT   TS               | المحاولة التالية
EVENT_TYPE      V100             | الحدث
RESPONSE_SNIPPET V1000           | بداية الاستجابة أو الخطأ
''', area='webhook')

table('API_IMPORT_JOB', 'مهام الاستيراد', 'Import Jobs', scope='T', mix='status', status='RUNNING COMPLETED PARTIAL FAILED', cols='''
COMPANY_ID      ID   >ORG_COMPANY | الشركة
IMPORT_TYPE     CODE NN IN:CUSTOMERS,SUPPLIERS,ITEMS,ACCOUNTS,BANK_STATEMENT,ORDERS | النوع
FILE_NAME       V300             | الملف
TOTAL_ROWS      INT  NN D=0      | الأسطر
OK_ROWS         INT  NN D=0      | الناجحة
FAILED_ROWS     INT  NN D=0      | الفاشلة
ERRORS          JSON             | أخطاء الأسطر
RESULT_REF      ID               | الناتج (رقم الكشف...)
''', area='connectors', purpose='استيراد دفعي بأخطاء لكل سطر دون إيقاف الباقي')
