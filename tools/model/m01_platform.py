from model.dsl import module, table

module(1, 'PLT', 'نواة المنصة والمؤسسات والترخيص', 'Platform Core, Tenancy, Licensing & Companies',
       'NOONA_PLATFORM_PKG',
       'Control Plane للمنصة: دليل المؤسسات والخلايا الإقليمية ودورة حياة Tenant والإعدادات الهرمية '
       'وكتالوج المنتجات والباقات والعقود والاشتراكات والاستحقاقات والفوترة والتحصيل وترخيص On-Premises، '
       'إضافة إلى الهيكل القانوني Tenant → Business Group → Company → Branch → Business Site.')

TENANT_STATUS = 'PROSPECT TRIAL PENDING_ACTIVATION ACTIVE GRACE_PERIOD READ_ONLY SUSPENDED ARCHIVED CLOSED'

# =============================================================== Tenancy & control plane
table('PLT_REGION', 'المناطق الإقليمية للاستضافة', 'Hosting Regions', scope='G', mix='code names active', cols='''
COUNTRY_CODE    CTRY             | دولة الاستضافة
RESIDENCY_ZONE  V50              | نطاق إقامة البيانات
''', area='tenancy')

table('PLT_CELL', 'الخلايا الإقليمية', 'Regional Cells', scope='G', mix='code names status', status='PLANNED ACTIVE DRAINING MAINTENANCE RETIRED', cols='''
REGION_ID       ID   NN >PLT_REGION | المنطقة
CELL_TYPE       CODE NN D='SHARED' IN:SHARED,DEDICATED,GOVERNMENT | نوع الخلية
DB_SERVICE_NAME V128             | خدمة قاعدة البيانات (لا تعرض للمتصفح)
CAPACITY_TENANTS INT             | السعة التصميمية من Tenants
ROLLOUT_CHANNEL CODE NN D='GENERAL' IN:INTERNAL,PILOT,LIMITED,GENERAL | قناة الإصدار
''', purpose='Data Plane مقسم إلى Regional Cells (10.11)')

table('PLT_TENANT', 'المؤسسات المشتركة', 'Tenants', scope='G', mix='pub names status', status=TENANT_STATUS, cols='''
TENANT_CODE     V30  NN U        | الرمز التجاري الفريد (ثابت بعد التفعيل)
TENANT_SLUG     V63  NN U        | عنوان الدخول (يتغير بضوابط)
EXTERNAL_REF    V100             | مرجع خارجي للتكاملات
ISOLATION_TIER  CODE NN D='SHARED' IN:SHARED,ENHANCED_SHARED,DEDICATED_PDB,DEDICATED_DB,ON_PREMISES | مستوى العزل المتدرج (10.2)
DEPLOYMENT_MODEL CODE NN D='SAAS' IN:SAAS,PRIVATE_CLOUD,ON_PREMISES | نموذج النشر
HOME_REGION_ID  ID   >PLT_REGION | منطقة إقامة البيانات
CELL_ID         ID   >PLT_CELL   | الخلية المستضيفة
COUNTRY_CODE    CTRY NN          | دولة المؤسسة / Country Pack الأساسي
DEFAULT_LANGUAGE LANG NN D='ar'  | اللغة الافتراضية
DEFAULT_TIMEZONE V64 NN D='Asia/Riyadh' | المنطقة الزمنية
BASE_CURRENCY   CUR  NN          | عملة المؤسسة الافتراضية
LEGAL_HOLD      YN   NN D='N'    | حجز قانوني يمنع الأرشفة والحذف
AI_ENABLED      YN   NN D='N'    | تفعيل AI على مستوى المؤسسة
ACTIVATED_AT    TS               | وقت التفعيل
SUSPENDED_AT    TS               | وقت التعليق
CLOSED_AT       TS               | وقت الإغلاق
''', ix=[('STATUS_CODE',)], area='tenancy', sens='CONFIDENTIAL',
      purpose='المفتاح TENANT_ID ثابت ولا يعاد استخدامه؛ التعليق لا يحذف البيانات (BR-006)')

table('PLT_TENANT_DOMAIN', 'نطاقات دخول المؤسسة', 'Tenant Domains', scope='T', mix='status', status='PENDING_VERIFICATION VERIFIED ACTIVE DISABLED', cols='''
DOMAIN_NAME     V253 NN          | النطاق الفرعي أو المخصص (فريد على مستوى المنصة)
DOMAIN_TYPE     CODE NN IN:SUBDOMAIN,CUSTOM | نوع النطاق
VERIFICATION_TOKEN_HASH HASH     | Hash رمز إثبات الملكية
VERIFIED_AT     TS               | وقت الإثبات
IS_PRIMARY      YN   NN D='N'    | النطاق الرئيسي
''', uk=[('DOMAIN_NAME',)], area='tenancy', purpose='النطاق يرشح Tenant ولا يثبت الصلاحية؛ يجب التحقق من العضوية')

table('PLT_TENANT_STATUS_HIST', 'سجل حالات المؤسسة', 'Tenant Status History', scope='T', append=True, cols='''
FROM_STATUS     CODE             | الحالة السابقة
TO_STATUS       CODE NN          | الحالة الجديدة
REASON          V1000 NN         | السبب
APPROVED_BY     USR              | المعتمد
EFFECTIVE_AT    TS   NN D=SYSTIMESTAMP | وقت السريان
''', area='tenancy')

table('PLT_PROVISIONING_RUN', 'عمليات تجهيز المؤسسة', 'Tenant Provisioning Runs', scope='T', mix='status',
      status='PENDING RUNNING WAITING_INPUT FAILED COMPLETED CANCELLED', cols='''
RUN_TYPE        CODE NN IN:CREATE,ACTIVATE,MOVE_CELL,UPGRADE_TIER,RESTORE,DECOMMISSION | نوع العملية
IDEMPOTENCY_KEY V100 NN U        | مفتاح منع التكرار (العملية قابلة للاستئناف)
LAST_STEP_NO    INT              | آخر خطوة سليمة
STARTED_AT      TS               | البداية
FINISHED_AT     TS               | النهاية
ERROR_MESSAGE   V4000            | رسالة الخطأ (بدون أسرار)
''', area='tenancy', purpose='Provisioning آلي Idempotent قابل للاستئناف من آخر خطوة سليمة (10.4)')

table('PLT_PROVISIONING_STEP', 'خطوات التجهيز', 'Provisioning Steps', scope='T', mix='status', status='PENDING RUNNING DONE FAILED SKIPPED', cols='''
RUN_ID          ID   NN >PLT_PROVISIONING_RUN | العملية
STEP_NO         INT  NN          | الترتيب
STEP_CODE       V50  NN          | الخطوة (RESERVE_CODE، CREATE_COMPANY، CREATE_ADMIN، SEED_REFERENCE...)
ATTEMPTS        INT  NN D=0      | عدد المحاولات
STARTED_AT      TS               | البداية
FINISHED_AT     TS               | النهاية
RESULT_INFO     JSON             | نتيجة الخطوة
''', uk=[('RUN_ID', 'STEP_NO')], area='tenancy')

table('PLT_ENVIRONMENT', 'بيئات المؤسسة', 'Tenant Environments', scope='T', mix='code status', status='REQUESTED ACTIVE EXPIRED DECOMMISSIONED', cols='''
ENV_TYPE        CODE NN IN:PRODUCTION,SANDBOX,TRAINING,UAT,SUPPORT_RECOVERY | نوع البيئة
SOURCE_ENV_ID   ID   >PLT_ENVIRONMENT | البيئة المصدر للنسخ
DATA_MODE       CODE NN D='EMPTY' IN:EMPTY,DEMO,CONFIG_ONLY,MASKED_COPY | نوع البيانات (BR-012)
IS_MASKED       YN   NN D='N'    | تم إخفاء البيانات الحساسة
INTEGRATIONS_DISABLED YN NN D='Y' | التكاملات الحقيقية معطلة
EXPIRES_AT      TS               | تاريخ الانتهاء
APPROVED_BY     USR              | المعتمد
''', area='tenancy')

table('PLT_SUPPORT_ACCESS', 'وصول الدعم المؤقت', 'Support Access Grants', scope='T', mix='status',
      status='REQUESTED APPROVED ACTIVE EXPIRED REVOKED REJECTED', cols='''
SUPPORT_USER_ID ID   NN >SEC_USER | موظف دعم NOONA
REASON          V1000 NN         | السبب
TICKET_REF      V100             | رقم التذكرة
SCOPE_INFO      JSON             | النطاق المسموح
APPROVED_BY_MEMBER_ID ID >SEC_USER_MEMBERSHIP | معتمد المؤسسة
STARTS_AT       TS   NN          | البداية
ENDS_AT         TS   NN          | النهاية (ينتهي تلقائياً)
ALLOW_SENSITIVE YN   NN D='N'    | يسمح بالبيانات الحساسة للضرورة
''', chk=['ENDS_AT > STARTS_AT'], area='tenancy', sens='CONFIDENTIAL',
      purpose='وصول الدعم مؤقت بسبب وموافقة وينتهي تلقائياً ويرى العميل سجله (10.3)')

# =============================================================== Settings & feature flags
table('PLT_SETTING_DEF', 'تعريفات الإعدادات', 'Setting Definitions', scope='G', mix='names desc', cols='''
SETTING_KEY     V100 NN U        | مفتاح الإعداد
MODULE_CODE     CODE             | الحزمة
DATA_TYPE       CODE NN IN:STRING,NUMBER,BOOLEAN,DATE,JSON,LOV,SECRET_REF | نوع القيمة
DEFAULT_VALUE   V4000            | القيمة الافتراضية للمنصة
ALLOWED_VALUES  JSON             | القيم المسموحة
MIN_LEVEL       CODE NN D='PLATFORM' IN:PLATFORM,COUNTRY,PLAN,TENANT,COMPANY,BRANCH,USER | أعلى مستوى يمكنه التعديل
MAX_LEVEL       CODE NN D='TENANT' IN:PLATFORM,COUNTRY,PLAN,TENANT,COMPANY,BRANCH,USER | أدنى مستوى يمكنه التجاوز
REQUIRES_APPROVAL YN NN D='N'    | يحتاج موافقة
IS_SENSITIVE    YN   NN D='N'    | حساس (لا يعرض كاملاً)
''', area='settings', purpose='هرم الإعدادات Platform → Country → Plan → Tenant → Company → Branch → User (10.5)')

table('PLT_SETTING_VALUE', 'قيم الإعدادات', 'Setting Values', scope='TO', mix='eff', cols='''
SETTING_DEF_ID  ID   NN >PLT_SETTING_DEF | الإعداد
LEVEL_CODE      CODE NN IN:PLATFORM,COUNTRY,PLAN,TENANT,COMPANY,BRANCH,USER | مستوى القيمة
COUNTRY_CODE    CTRY             | الدولة عند COUNTRY
PLAN_VERSION_ID ID   >PLT_PLAN_VERSION | الباقة عند PLAN
COMPANY_ID      ID   >ORG_COMPANY | الشركة عند COMPANY
BRANCH_ID       ID   >ORG_BRANCH  | الفرع عند BRANCH
USER_ID         ID   >SEC_USER   | المستخدم عند USER
SETTING_VALUE   V4000            | القيمة (الأسرار تخزن كمرجع Vault فقط)
APPROVED_BY     USR              | المعتمد
''', area='settings')

table('PLT_FEATURE_FLAG', 'مفاتيح الخصائص', 'Feature Flags', scope='G', mix='code names desc', cols='''
MODULE_CODE     CODE             | الحزمة
FLAG_STATE      CODE NN D='DISABLED' IN:DISABLED,INTERNAL,PILOT,PERCENT_ROLLOUT,PLAN_ENABLED,TENANT_ENABLED,GA,DEPRECATED | الحالة
ROLLOUT_PCT     PCT              | نسبة الإطلاق التدريجي
''', area='settings')

table('PLT_FEATURE_FLAG_TENANT', 'تفعيل الخاصية للمؤسسة', 'Tenant Feature Flags', scope='T', mix='eff', cols='''
FEATURE_FLAG_ID ID   NN >PLT_FEATURE_FLAG | الخاصية
IS_ENABLED      YN   NN D='Y'    | مفعلة
REASON          V1000            | السبب
''', uk=[('TENANT_ID', 'FEATURE_FLAG_ID')], area='settings')

# =============================================================== Product catalog
table('PLT_MODULE', 'وحدات المنتج', 'Product Modules', scope='G', mix='names sort active', cols='''
MODULE_CODE     CODE NN U        | رمز الحزمة (PLT، GL، AR...)
PACKAGE_NO      INT  NN U        | رقم الحزمة في السجل الموحد (01..30)
PLSQL_PACKAGE   V128             | الحزمة البرمجية المالكة
IS_CORE         YN   NN D='N'    | نواة إلزامية
''', area='catalog', purpose='السجل الموحد للحزم الثلاثين')

table('PLT_FEATURE', 'خصائص الوحدات', 'Module Features', scope='G', mix='code names', cols='''
MODULE_ID       ID   NN >PLT_MODULE | الوحدة
IS_METERED      YN   NN D='N'    | خاصية مقاسة الاستهلاك
''', area='catalog')

table('PLT_USAGE_METRIC', 'مقاييس الاستهلاك', 'Usage Metrics', scope='G', mix='code names', cols='''
UNIT_CODE       CODE NN          | الوحدة (USER، GB، CALL، TOKEN، PAGE...)
AGGREGATION     CODE NN D='MAX' IN:SUM,MAX,LAST,COUNT_DISTINCT | طريقة التجميع للفترة
''', area='catalog', purpose='مستخدمون، فروع، شركات، تخزين، AI، OCR، API، رسائل...')

table('PLT_PRODUCT', 'المنتجات', 'Products', scope='G', mix='code names desc active', cols='''
PRODUCT_TYPE    CODE NN IN:SAAS,ON_PREMISES,PRIVATE_CLOUD,SERVICE,USAGE | نوع المنتج
''', area='catalog')

table('PLT_EDITION', 'الإصدارات التجارية', 'Editions', scope='G', mix='code names sort active', cols='''
PRODUCT_ID      ID   NN >PLT_PRODUCT | المنتج
SEGMENT_CODE    CODE NN IN:STARTER,BUSINESS,ENTERPRISE,GOVERNMENT,ONPREM_ENTERPRISE | الشريحة
TARGET_AVAILABILITY PCT          | التوفر المستهدف
RPO_MINUTES     INT              | RPO المستهدف بالدقائق
RTO_MINUTES     INT              | RTO المستهدف بالدقائق
''', area='catalog')

table('PLT_PLAN', 'الباقات', 'Plans', scope='G', mix='code names active', cols='''
EDITION_ID      ID   NN >PLT_EDITION | الإصدار
BILLING_CYCLE   CODE NN IN:MONTHLY,QUARTERLY,SEMI_ANNUAL,ANNUAL,MULTI_YEAR,ONE_TIME,CONTRACT | دورة الفوترة
DISCOUNT_PCT    PCT  NN D=0      | خصم المدة على السعر الشهري (التسجيل الذاتي)
SELF_SERVICE    YN   NN D='Y'    | تظهر في صفحة التسجيل الذاتي
''', area='catalog')

table('PLT_OFFERING', 'أنظمة الاشتراك وأسعارها', 'Subscription Offerings', scope='G', mix='code names desc sort active', cols='''
ICON            V60              | الأيقونة
MODULE_CODES    V400 NN          | رموز الوحدات المشمولة (مفصولة بفاصلة)
MONTHLY_PRICE   AMT  NN D=0      | السعر الشهري
CURRENCY_CODE   CUR  NN D='SAR'  | العملة
REQUIRES_CODES  V200             | أنظمة يتطلبها (مثل المالية للمخزون)
''', area='catalog', purpose='ما يختاره العميل في التسجيل الذاتي: نظام = مجموعة وحدات بسعر شهري')

table('PLT_SIGNUP', 'طلبات التسجيل الذاتي', 'Self-Service Signups', scope='G', mix='status',
      status='STARTED VERIFIED DETAILS PROVISIONED PAYMENT_PENDING PAID REJECTED EXPIRED', cols='''
FULL_NAME       NAME NN          | الاسم الكامل
EMAIL           V320 NN PII      | البريد الإلكتروني
MOBILE          V40  NN PII      | الجوال
USERNAME        V128 NN          | اسم الدخول المطلوب
PASSWORD_HASH   V200 NN          | كلمة المرور (PBKDF2)
PASSWORD_SALT   V64  NN          | الملح
TOKEN_HASH      HASH NN U        | بصمة رمز الجلسة
EMAIL_OTP_HASH  HASH             | بصمة رمز البريد
MOBILE_OTP_HASH HASH             | بصمة رمز الجوال
OTP_EXPIRES_AT  TS               | انتهاء الرمز
OTP_SENT_COUNT  INT  NN D=0      | مرات الإرسال
OTP_FAILED      INT  NN D=0      | المحاولات الخاطئة
LAST_SENT_AT    TS               | آخر إرسال
EMAIL_VERIFIED_AT TS             | تحقق البريد
MOBILE_VERIFIED_AT TS            | تحقق الجوال
TERMS_VERSION   V20  NN          | إصدار الشروط الموافق عليها
TERMS_ACCEPTED_AT TS NN          | وقت الموافقة
IP_ADDRESS      V64              | عنوان IP
ORG_NAME_AR     NAME             | اسم المؤسسة
ORG_NAME_EN     NAME             | الاسم بالإنجليزية
COUNTRY_CODE    CTRY             | الدولة
CURRENCY_CODE   CUR              | العملة
CR_NO           V50              | السجل التجاري
VAT_NO          V50              | الرقم الضريبي
CITY            V100             | المدينة
OFFERINGS       V400             | الأنظمة المختارة
USER_COUNT      INT              | عدد المستخدمين
PLAN_CODE       CODE             | الخطة
PAYMENT_METHOD  CODE IN:NONE,BANK_TRANSFER,CARD | طريقة الدفع
PAYMENT_REF     V200             | مرجع التحويل
QUOTE           JSON             | تفاصيل السعر وقت الطلب
AMOUNT_DUE      AMT              | المبلغ المستحق شاملاً الضريبة
TENANT_ID       ID   >PLT_TENANT | المؤسسة المنشأة
DECIDED_BY      USR              | قرار مسؤول المنصة
DECISION_NOTE   V1000            | ملاحظة القرار
''', ix=[('EMAIL',), ('MOBILE',), ('STATUS_CODE',)], area='catalog',
      purpose='تسجيل العميل بنفسه: التحقق بالرمز، المؤسسة، الأنظمة والخطة، ثم التجهيز الآلي؛ والدفع بالتحويل يعتمده مسؤول المنصة')

table('PLT_PLAN_VERSION', 'إصدارات الباقة', 'Plan Versions', scope='G', mix='eff status', status='DRAFT PUBLISHED RETIRED', cols='''
PLAN_ID         ID   NN >PLT_PLAN | الباقة
VERSION_NO      INT  NN          | رقم الإصدار
TRIAL_DAYS      INT              | مدة التجربة
GRACE_DAYS      INT  NN D=15     | فترة السماح
READ_ONLY_DAYS  INT  NN D=30     | فترة القراءة فقط
SLA_INFO        JSON             | مستوى الخدمة والدعم
IS_LOCKED       YN   NN D='N'    | مقفلة بعد استخدامها في عقد (لا تعدل)
''', uk=[('PLAN_ID', 'VERSION_NO')], area='catalog',
      purpose='لا تعدل Plan Version بعد استخدامها في عقد؛ تنشأ نسخة جديدة (11.2)')

table('PLT_PLAN_MODULE', 'وحدات إصدار الباقة', 'Plan Version Modules', scope='G', cols='''
PLAN_VERSION_ID ID   NN >PLT_PLAN_VERSION | إصدار الباقة
MODULE_ID       ID   NN >PLT_MODULE | الوحدة
FEATURE_ID      ID   >PLT_FEATURE | الخاصية (فارغ = الوحدة كاملة)
INCLUSION_TYPE  CODE NN IN:INCLUDED,OPTIONAL_ADDON,TRIAL,NOT_AVAILABLE,CONTRACT_ONLY | نوع الإتاحة
''', uk=[('PLAN_VERSION_ID', 'MODULE_ID', 'FEATURE_ID')], area='catalog')

table('PLT_PLAN_LIMIT', 'حدود إصدار الباقة', 'Plan Version Limits', scope='G', cols='''
PLAN_VERSION_ID ID   NN >PLT_PLAN_VERSION | إصدار الباقة
METRIC_ID       ID   NN >PLT_USAGE_METRIC | المقياس
INCLUDED_QTY    QTY              | الكمية المشمولة
SOFT_LIMIT      QTY              | الحد المرن (تنبيه مراقب)
HARD_LIMIT      QTY              | الحد الصلب (منع)
''', uk=[('PLAN_VERSION_ID', 'METRIC_ID')], area='catalog')

table('PLT_ADDON', 'الإضافات', 'Add-ons', scope='G', mix='code names active', cols='''
ADDON_TYPE      CODE NN IN:USERS,BRANCHES,COMPANIES,TENANT_SLOT,STORAGE,AI,OCR,API,SANDBOX,PREMIUM_SUPPORT,DEDICATED_CELL,COUNTRY_PACK,TRAINING,IMPLEMENTATION | نوع الإضافة
METRIC_ID       ID   >PLT_USAGE_METRIC | المقياس المرتبط
MODULE_ID       ID   >PLT_MODULE | الوحدة المرتبطة
''', area='catalog')

table('PLT_PRICE_BOOK', 'دفاتر الأسعار', 'Price Books', scope='G', mix='code names eff status', status='DRAFT ACTIVE RETIRED', cols='''
COUNTRY_CODE    CTRY             | الدولة
CURRENCY_CODE   CUR  NN          | العملة
SALES_CHANNEL   CODE NN D='DIRECT' IN:DIRECT,PARTNER,RESELLER,ONLINE,GOVERNMENT | قناة البيع
CUSTOMER_CLASS  CODE             | فئة العميل
''', area='catalog', purpose='الأسعار منفصلة عن تعريف الباقة؛ تغييرها لا يمس العقود القائمة')

table('PLT_PRICE_BOOK_ENTRY', 'أسعار دفتر الأسعار', 'Price Book Entries', scope='G', mix='eff', cols='''
PRICE_BOOK_ID   ID   NN >PLT_PRICE_BOOK | دفتر الأسعار
PLAN_VERSION_ID ID   >PLT_PLAN_VERSION | إصدار الباقة
ADDON_ID        ID   >PLT_ADDON  | الإضافة
METRIC_ID       ID   >PLT_USAGE_METRIC | المقياس (تسعير الاستهلاك)
PRICING_MODEL   CODE NN IN:FLAT,PER_UNIT,TIERED,VOLUME,PACKAGE,OVERAGE,MINIMUM | نموذج التسعير
UNIT_PRICE      AMT              | سعر الوحدة
TIERS           JSON             | شرائح التسعير
MIN_PRICE       AMT              | الحد الأدنى للسعر
''', chk=['(CASE WHEN PLAN_VERSION_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN ADDON_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN METRIC_ID IS NOT NULL THEN 1 ELSE 0 END) = 1'],
      area='catalog')

table('PLT_PARTNER', 'الشركاء والموزعون', 'Partners & Resellers', scope='G', mix='code names status', status='ACTIVE SUSPENDED TERMINATED', cols='''
PARTNER_TYPE    CODE NN IN:PARTNER,RESELLER,REFERRAL,IMPLEMENTER | النوع
COUNTRY_CODE    CTRY             | الدولة
COMMISSION_PCT  PCT              | نسبة العمولة الافتراضية
''', area='sales')

table('PLT_PROMOTION', 'العروض الترويجية', 'Promotions', scope='G', mix='code names eff status', status='DRAFT ACTIVE EXPIRED CANCELLED', cols='''
DISCOUNT_TYPE   CODE NN IN:PERCENT,FIXED,FREE_PERIOD,SETUP_WAIVER,CREDIT | نوع الخصم
DISCOUNT_VALUE  AMT  NN          | قيمة الخصم
COUPON_CODE     V50  U           | كود الخصم
MAX_REDEMPTIONS INT              | حد الاستخدام
SINGLE_USE      YN   NN D='N'    | استخدام مرة واحدة لكل عميل
SCOPE_RULES     JSON             | نطاق الدولة/الباقة/العملة/القطاع
STACKABLE       YN   NN D='N'    | قابل للجمع مع خصومات أخرى
''', area='sales')

# =============================================================== Quotes, contracts, subscriptions
table('PLT_QUOTE', 'عروض أسعار الاشتراك', 'Subscription Quotes', scope='T', mix='pub status cur', codeuk=False,
      status='DRAFT UNDER_REVIEW APPROVED SENT ACCEPTED REJECTED EXPIRED SUPERSEDED', cols='''
QUOTE_NO        V50  NN          | رقم العرض
REVISION_NO     INT  NN D=1      | رقم المراجعة (التعديل بعد الإرسال ينشئ Revision)
PREVIOUS_QUOTE_ID ID >PLT_QUOTE  | المراجعة السابقة
PRICE_BOOK_ID   ID   NN >PLT_PRICE_BOOK | دفتر الأسعار
PARTNER_ID      ID   >PLT_PARTNER | الشريك
VALID_UNTIL     DATE NN          | صلاحية العرض
TOTAL_BEFORE_DISCOUNT AMT        | الإجمالي قبل الخصم
DISCOUNT_AMOUNT AMT              | الخصم
ESTIMATED_TAX   AMT              | الضريبة التقديرية
TOTAL_AMOUNT    AMT              | الإجمالي
APPROVED_BY     USR              | معتمد الخصم (فصل واجبات عن المنشئ)
''', uk=[('QUOTE_NO', 'REVISION_NO')], area='sales')

table('PLT_QUOTE_LINE', 'بنود عرض الاشتراك', 'Subscription Quote Lines', scope='T', cols='''
QUOTE_ID        ID   NN >PLT_QUOTE | العرض
LINE_NO         INT  NN          | السطر
PLAN_VERSION_ID ID   >PLT_PLAN_VERSION | إصدار الباقة
ADDON_ID        ID   >PLT_ADDON  | الإضافة
QUANTITY        QTY  NN D=1      | الكمية
LIST_PRICE      AMT  NN          | السعر الأصلي
DISCOUNT_PCT    PCT              | نسبة الخصم
NET_PRICE       AMT  NN          | السعر النهائي
PROMOTION_ID    ID   >PLT_PROMOTION | العرض الترويجي
''', uk=[('QUOTE_ID', 'LINE_NO')], chk=['NET_PRICE >= 0'], area='sales')

table('PLT_CONTRACT', 'عقود المنصة', 'Platform Contracts', scope='T', mix='pub status cur',
      status='DRAFT UNDER_REVIEW APPROVED SIGNED ACTIVE EXPIRED TERMINATED RENEWED', cols='''
CONTRACT_NO     V50  NN U        | رقم العقد
QUOTE_ID        ID   >PLT_QUOTE  | العرض المصدر
LEGAL_PARTY_NAME NAME NN         | الجهة القانونية المتعاقدة
START_DATE      DATE NN          | البداية
END_DATE        DATE             | النهاية
AUTO_RENEW      YN   NN D='Y'    | تجديد تلقائي
GRACE_DAYS      INT  NN D=15     | فترة السماح التعاقدية
READ_ONLY_DAYS  INT  NN D=30     | فترة القراءة فقط التعاقدية
SIGNED_AT       TS               | وقت التوقيع
SIGNED_DOCUMENT_ID ID >DMS_DOCUMENT | نسخة العقد الموقعة
CURRENT_VERSION_NO INT NN D=1    | رقم آخر Amendment
TERMINATION_REASON V1000         | سبب الإنهاء
''', area='contracts', purpose='لا يعدل العقد الموقع مباشرة؛ تنشأ Amendment بإصدار مستقل (11.3)')

table('PLT_CONTRACT_VERSION', 'تعديلات العقد', 'Contract Amendments', scope='T', mix='status', status='DRAFT APPROVED SIGNED EFFECTIVE CANCELLED', cols='''
CONTRACT_ID     ID   NN >PLT_CONTRACT | العقد
VERSION_NO      INT  NN          | رقم الإصدار
AMENDMENT_TYPE  CODE NN IN:ORIGINAL,AMENDMENT,ADDENDUM,RENEWAL | النوع
EFFECTIVE_DATE  DATE NN          | تاريخ السريان
TERMS_SNAPSHOT  JSON NN          | لقطة الشروط والأسعار والحدود
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند
''', uk=[('CONTRACT_ID', 'VERSION_NO')], area='contracts')

table('PLT_SUBSCRIPTION', 'الاشتراكات', 'Subscriptions', scope='T', mix='pub status',
      status='PENDING TRIAL ACTIVE GRACE_PERIOD READ_ONLY SUSPENDED CANCELLED EXPIRED UPGRADE_PENDING DOWNGRADE_SCHEDULED', cols='''
SUBSCRIPTION_NO V50  NN U        | رقم الاشتراك
CONTRACT_ID     ID   >PLT_CONTRACT | العقد
PLAN_VERSION_ID ID   NN >PLT_PLAN_VERSION | إصدار الباقة المتعاقد عليه
BILLING_CYCLE   CODE NN IN:MONTHLY,QUARTERLY,SEMI_ANNUAL,ANNUAL,MULTI_YEAR,ONE_TIME,CONTRACT | دورة الفوترة
CURRENT_PERIOD_START DATE        | بداية الفترة الحالية
CURRENT_PERIOD_END DATE          | نهاية الفترة الحالية
NEXT_BILLING_DATE DATE           | تاريخ الفوترة التالي
GRACE_ENDS_AT   TS               | نهاية فترة السماح
READ_ONLY_ENDS_AT TS             | نهاية القراءة فقط
SCHEDULED_PLAN_VERSION_ID ID >PLT_PLAN_VERSION | الباقة المجدولة (Downgrade)
CANCEL_REASON   V1000            | سبب الإلغاء
''', ix=[('STATUS_CODE', 'NEXT_BILLING_DATE')], area='contracts')

table('PLT_SUBSCRIPTION_ITEM', 'بنود الاشتراك', 'Subscription Items', scope='T', mix='eff', cols='''
SUBSCRIPTION_ID ID   NN >PLT_SUBSCRIPTION | الاشتراك
ADDON_ID        ID   >PLT_ADDON  | الإضافة (فارغ = الباقة الأساسية)
QUANTITY        QTY  NN D=1      | الكمية
UNIT_PRICE      AMT  NN          | السعر المتعاقد
CURRENCY_CODE   CUR  NN          | العملة
PRICE_SNAPSHOT  JSON             | لقطة التسعير
''', area='contracts')

table('PLT_SUBSCRIPTION_SNAPSHOT', 'لقطات حقوق الاشتراك', 'Subscription Snapshots', scope='T', append=True, cols='''
SUBSCRIPTION_ID ID   NN >PLT_SUBSCRIPTION | الاشتراك
SNAPSHOT_REASON CODE NN IN:ACTIVATION,RENEWAL,UPGRADE,DOWNGRADE,AMENDMENT,REACTIVATION | سبب اللقطة
SNAPSHOT_DATA   JSON NN          | ما اشتراه العميل فعلياً (لا يتغير بتعديل الكتالوج)
''', area='contracts')

table('PLT_ENTITLEMENT', 'الاستحقاقات الفعلية', 'Effective Entitlements', scope='T', mix='eff', cols='''
MODULE_ID       ID   >PLT_MODULE | الوحدة
FEATURE_ID      ID   >PLT_FEATURE | الخاصية
METRIC_ID       ID   >PLT_USAGE_METRIC | المقياس
IS_ENABLED      YN   NN D='Y'    | مفعل
LIMIT_QTY       QTY              | الحد الفعلي
SOFT_LIMIT      QTY              | الحد المرن
HARD_LIMIT      QTY              | الحد الصلب
SOURCE_CODE     CODE NN IN:PLAN,ADDON,CONTRACT_OVERRIDE,TRIAL,EXCEPTION,SUSPENSION | مصدر الحق
SUBSCRIPTION_ID ID   >PLT_SUBSCRIPTION | الاشتراك
COMPUTED_AT     TS   NN D=SYSTIMESTAMP | وقت الحساب (Cache؛ المصدر الرسمي العقد)
''', ix=[('TENANT_ID', 'MODULE_ID'), ('TENANT_ID', 'METRIC_ID')], area='contracts',
      purpose='Plan + Add-ons + Overrides + Trial - Suspended = Effective Entitlements؛ يطبق في APEX وPL/SQL وORDS')

table('PLT_ENTITLEMENT_OVERRIDE', 'الاستثناءات التعاقدية للحقوق', 'Entitlement Overrides', scope='T', mix='eff status', status='DRAFT APPROVED ACTIVE EXPIRED REVOKED', cols='''
MODULE_ID       ID   >PLT_MODULE | الوحدة
FEATURE_ID      ID   >PLT_FEATURE | الخاصية
METRIC_ID       ID   >PLT_USAGE_METRIC | المقياس
OVERRIDE_TYPE   CODE NN IN:ENABLE,DISABLE,LIMIT,BURST,GRACE_EXTENSION,GOVERNMENT_EXEMPTION | النوع
LIMIT_QTY       QTY              | الحد الجديد
REASON          V1000 NN         | السبب
APPROVED_BY     USR              | المعتمد
''', area='contracts')

table('PLT_TRIAL', 'التجارب و Pilot', 'Trials & Pilots', scope='T', mix='status', status='ACTIVE EXTENDED CONVERTED EXPIRED READ_ONLY CLOSED', cols='''
TRIAL_TYPE      CODE NN IN:SELF_SERVICE,SALES_INVITE,PILOT,MODULE_TRIAL,ADDON_TRIAL,POC | نوع التجربة
PLAN_VERSION_ID ID   NN >PLT_PLAN_VERSION | الباقة المجربة
STARTS_ON       DATE NN          | البداية
ENDS_ON         DATE NN          | النهاية
IDENTITY_HASH   HASH             | Hash هوية المسجل لمنع التجارب المتكررة
CONVERTED_SUBSCRIPTION_ID ID >PLT_SUBSCRIPTION | الاشتراك الناتج بعد التحويل
SUCCESS_CRITERIA JSON            | معايير نجاح Pilot
DATA_FATE       CODE IN:KEEP,EXPORT_AND_ARCHIVE,PURGE_AFTER_RETENTION | مصير البيانات عند عدم التعاقد
''', area='contracts')

# =============================================================== Usage & billing
table('PLT_USAGE_EVENT', 'أحداث الاستهلاك', 'Usage Events', scope='T', append=True, cols='''
METRIC_ID       ID   NN >PLT_USAGE_METRIC | المقياس
QUANTITY        QTY  NN          | الكمية
OCCURRED_AT     TS   NN          | وقت الحدث
IDEMPOTENCY_KEY V100 NN          | مفتاح منع التكرار
SOURCE_MODULE   CODE             | الوحدة المصدر
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY')], ix=[('TENANT_ID', 'METRIC_ID', 'OCCURRED_AT')], area='billing',
      ret='حسب سياسة الفوترة؛ تقسيم مقترح بالشهر')

table('PLT_USAGE_SUMMARY', 'ملخص الاستهلاك للفترة', 'Usage Summary', scope='T', mix='status', status='OPEN LOCKED BILLED', cols='''
METRIC_ID       ID   NN >PLT_USAGE_METRIC | المقياس
PERIOD_START    DATE NN          | بداية الفترة
PERIOD_END      DATE NN          | نهاية الفترة
TOTAL_QTY       QTY  NN D=0      | الإجمالي
INCLUDED_QTY    QTY              | المشمول
BILLABLE_QTY    QTY              | القابل للفوترة
ALERT_LEVEL_PCT PCT              | آخر عتبة تنبيه (70/85/100)
''', uk=[('TENANT_ID', 'METRIC_ID', 'PERIOD_START')], area='billing')

table('PLT_BILLING_PERIOD', 'فترات الفوترة', 'Billing Periods', scope='G', mix='status', status='OPEN CLOSING CLOSED REOPENED', cols='''
PERIOD_CODE     V20  NN U        | رمز الفترة (YYYY-MM)
START_DATE      DATE NN          | البداية
END_DATE        DATE NN          | النهاية
CLOSED_BY       USR              | منفذ الإقفال
CLOSED_AT       TS               | وقت الإقفال
''', area='billing')

table('PLT_BILLING_INVOICE', 'فواتير المنصة', 'Platform Invoices', scope='T', mix='pub status cur',
      status='DRAFT CALCULATED REVIEWED APPROVED ISSUED PARTIALLY_PAID PAID VOID OVERDUE DISPUTED CREDITED WRITTEN_OFF', cols='''
INVOICE_NO      V50  NN U        | رقم الفاتورة
DOC_TYPE        CODE NN D='INVOICE' IN:INVOICE,CREDIT_NOTE,DEBIT_NOTE | النوع
ORIGINAL_INVOICE_ID ID >PLT_BILLING_INVOICE | الفاتورة الأصلية للإشعار
SUBSCRIPTION_ID ID   >PLT_SUBSCRIPTION | الاشتراك
BILLING_PERIOD_ID ID >PLT_BILLING_PERIOD | فترة الفوترة
INVOICE_DATE    DATE NN          | تاريخ الإصدار
DUE_DATE        DATE NN          | تاريخ الاستحقاق
SUBTOTAL        AMT  NN D=0      | قبل الضريبة والخصم
DISCOUNT_AMOUNT AMT  NN D=0      | الخصم
TAX_AMOUNT      AMT  NN D=0      | الضريبة
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي
PAID_AMOUNT     AMT  NN D=0      | المدفوع
TAX_SNAPSHOT    JSON             | لقطة الضريبة
IDEMPOTENCY_KEY V100 U           | منع إصدار الفاتورة مرتين
ISSUED_AT       TS               | وقت الإصدار (لا تعدل بعده)
''', ix=[('TENANT_ID', 'STATUS_CODE', 'DUE_DATE')], area='billing',
      purpose='Platform Billing مستقل عن محاسبة أعمال Tenant (11.4)')

table('PLT_BILLING_INVOICE_LINE', 'بنود فواتير المنصة', 'Platform Invoice Lines', scope='T', cols='''
INVOICE_ID      ID   NN >PLT_BILLING_INVOICE | الفاتورة
LINE_NO         INT  NN          | السطر
LINE_TYPE       CODE NN IN:SUBSCRIPTION,ADDON,USAGE,PRORATION,SETUP,SERVICE,DISCOUNT,ADJUSTMENT | نوع البند
SUBSCRIPTION_ITEM_ID ID >PLT_SUBSCRIPTION_ITEM | بند الاشتراك
METRIC_ID       ID   >PLT_USAGE_METRIC | المقياس
DESCRIPTION     V1000 NN         | الوصف
QUANTITY        QTY  NN D=1      | الكمية
UNIT_PRICE      AMT  NN          | السعر
LINE_AMOUNT     AMT  NN          | المبلغ
TAX_AMOUNT      AMT  NN D=0      | الضريبة
CALC_INFO       JSON             | معادلة الحساب (Proration/Usage)
''', uk=[('INVOICE_ID', 'LINE_NO')], area='billing')

table('PLT_BILLING_PAYMENT', 'مدفوعات المنصة', 'Platform Payments', scope='T', mix='pub status cur',
      status='PENDING PENDING_VERIFICATION CONFIRMED REJECTED FAILED REFUNDED PARTIALLY_REFUNDED CHARGEBACK', cols='''
PAYMENT_NO      V50  NN U        | رقم الدفعة
PAYMENT_METHOD  CODE NN IN:GATEWAY,BANK_TRANSFER,CHEQUE,CASH,MANUAL | طريقة الدفع
PROVIDER_CODE   CODE             | مزود الدفع
PROVIDER_REFERENCE V200          | مرجع المزود (فريد مع المزود لمنع التكرار)
IDEMPOTENCY_KEY V100 U           | مفتاح Webhook
AMOUNT          AMT  NN          | المبلغ
UNALLOCATED_AMOUNT AMT NN D=0    | غير المخصص
RECEIVED_AT     TS               | وقت الاستلام
RECEIPT_DOCUMENT_ID ID >DMS_DOCUMENT | إيصال التحويل البنكي
VERIFIED_BY     USR              | المطابق (فصل واجبات عن المدخل)
VERIFIED_AT     TS               | وقت المطابقة
REJECT_REASON   V1000            | سبب الرفض
''', nuk=[('PROVIDER_CODE', 'PROVIDER_REFERENCE')], area='billing')

table('PLT_BILLING_ALLOCATION', 'تخصيص مدفوعات المنصة', 'Platform Payment Allocations', scope='T', mix='status', status='APPLIED REVERSED', cols='''
PAYMENT_ID      ID   NN >PLT_BILLING_PAYMENT | الدفعة
INVOICE_ID      ID   NN >PLT_BILLING_INVOICE | الفاتورة
AMOUNT          AMT  NN          | المبلغ المخصص
APPLIED_AT      TS   NN D=SYSTIMESTAMP | وقت التخصيص
''', chk=['AMOUNT > 0'], area='billing')

table('PLT_REFUND', 'الاسترداد ورد المبالغ المتنازع عليها', 'Refunds & Chargebacks', scope='T', mix='status',
      status='REQUESTED APPROVED PROCESSED REJECTED DISPUTED', cols='''
PAYMENT_ID      ID   NN >PLT_BILLING_PAYMENT | الدفعة الأصلية
REFUND_TYPE     CODE NN IN:REFUND,PARTIAL_REFUND,CHARGEBACK | النوع
AMOUNT          AMT  NN          | المبلغ
REASON          V1000 NN         | السبب
PROVIDER_REFERENCE V200          | مرجع المزود
APPROVED_BY     USR              | المعتمد
''', chk=['AMOUNT > 0'], area='billing')

table('PLT_DUNNING_POLICY', 'سياسات التحصيل', 'Dunning Policies', scope='G', mix='code names active', cols='''
EDITION_ID      ID   >PLT_EDITION | الإصدار
REMINDER_DAYS   V100 NN D='30,15,7,3' | أيام التنبيه قبل الاستحقاق
GRACE_DAYS      INT  NN D=15     | فترة السماح
READ_ONLY_DAYS  INT  NN D=30     | فترة القراءة فقط
CHANNELS        V200 NN D='IN_APP,EMAIL' | قنوات التنبيه
''', area='billing')

table('PLT_DUNNING_EVENT', 'أحداث التحصيل', 'Dunning Events', scope='T', append=True, cols='''
INVOICE_ID      ID   >PLT_BILLING_INVOICE | الفاتورة
SUBSCRIPTION_ID ID   >PLT_SUBSCRIPTION | الاشتراك
EVENT_TYPE      CODE NN IN:REMINDER,OVERDUE_NOTICE,GRACE_STARTED,READ_ONLY_STARTED,SUSPENDED,REACTIVATED,HOLD_APPLIED | الحدث
CHANNEL         CODE             | القناة
NOTIFICATION_ID ID   >NTF_NOTIFICATION | الإشعار المرسل
''', area='billing')

table('PLT_BILLING_DISPUTE', 'نزاعات الفوترة', 'Billing Disputes', scope='T', mix='status', status='OPEN UNDER_REVIEW RESOLVED_CREDIT RESOLVED_NO_CHANGE CLOSED', cols='''
INVOICE_ID      ID   NN >PLT_BILLING_INVOICE | الفاتورة
DISPUTED_AMOUNT AMT  NN          | المبلغ المتنازع عليه
REASON          V1000 NN         | السبب
SUSPEND_DUNNING YN   NN D='Y'    | تعليق التحصيل للمبلغ
OWNER_USER      USR              | المسؤول
RESOLUTION      V1000            | النتيجة
CREDIT_NOTE_ID  ID   >PLT_BILLING_INVOICE | الإشعار الدائن الناتج
''', area='billing')

table('PLT_PAYMENT_PROMISE', 'وعود الدفع', 'Payment Promises', scope='T', mix='status', status='OPEN KEPT BROKEN CANCELLED', cols='''
INVOICE_ID      ID   NN >PLT_BILLING_INVOICE | الفاتورة
PROMISED_AMOUNT AMT  NN          | المبلغ
PROMISED_DATE   DATE NN          | التاريخ المتوقع
PAYMENT_METHOD  CODE             | الطريقة
STOPS_SUSPENSION YN  NN D='N'    | يوقف التعليق (يتطلب موافقة)
APPROVED_BY     USR              | المعتمد
''', area='billing')

table('PLT_COMMISSION', 'العمولات', 'Commissions', scope='T', mix='status', status='ACCRUED ELIGIBLE APPROVED PAID REVERSED', cols='''
PARTNER_ID      ID   NN >PLT_PARTNER | الشريك
CONTRACT_ID     ID   >PLT_CONTRACT | العقد
INVOICE_ID      ID   >PLT_BILLING_INVOICE | الفاتورة
BASE_AMOUNT     AMT  NN          | أساس العمولة
COMMISSION_PCT  PCT  NN          | النسبة
COMMISSION_AMOUNT AMT NN         | المبلغ
''', area='billing', purpose='لا تستحق نهائياً قبل تحقق شروط التحصيل، وتعكس عند الاسترداد')

# =============================================================== On-Premises licensing
table('PLT_ONPREM_LICENSE', 'تراخيص On-Premises', 'On-Premises Licenses', scope='G', mix='pub status',
      status='DRAFT ISSUED ACTIVE GRACE READ_ONLY EXPIRED REVOKED SUPERSEDED', cols='''
LICENSE_NO      V50  NN U        | رقم الترخيص
CUSTOMER_NAME   NAME NN          | العميل
LICENSE_TYPE    CODE NN IN:ANNUAL,PERPETUAL,ENTERPRISE_CONTRACT,GOVERNMENT_CONTRACT | نوع الترخيص
MAX_TENANTS     INT  NN          | الحد الأقصى للمؤسسات (لا يحرر التعليق Slot - BR-010)
MAX_USERS       INT              | المستخدمون
MAX_COMPANIES   INT              | الشركات
MAX_BRANCHES    INT              | الفروع
ENVIRONMENTS    JSON             | حدود البيئات Production/DR/UAT/Test...
MODULES         JSON             | الوحدات المرخصة
VALID_FROM      DATE NN          | البداية
VALID_TO        DATE             | النهاية (فارغ للدائم)
MAINTENANCE_EXPIRY DATE          | نهاية الصيانة والدعم
GRACE_DAYS      INT  NN D=30     | فترة السماح
ENV_FINGERPRINT HASH             | بصمة البيئة
LICENSE_VERSION INT  NN D=1      | إصدار صيغة الترخيص
SIGNED_PAYLOAD  CLOB NN          | ملف الترخيص الموقع رقمياً
SIGNATURE       V4000 NN         | التوقيع
PREVIOUS_LICENSE_ID ID >PLT_ONPREM_LICENSE | الترخيص السابق
''', area='license', sens='CONFIDENTIAL')

table('PLT_LICENSE_ACTIVATION', 'تفعيلات الترخيص', 'License Activations', scope='G', mix='status', status='ACTIVE DEACTIVATED TRANSFERRED RECOVERED', cols='''
LICENSE_ID      ID   NN >PLT_ONPREM_LICENSE | الترخيص
ACTIVATION_MODE CODE NN IN:ONLINE,OFFLINE | نمط التفعيل
SERVER_FINGERPRINT HASH NN       | بصمة الخادم
ACTIVATED_AT    TS   NN D=SYSTIMESTAMP | وقت التفعيل
DEACTIVATED_AT  TS               | وقت إلغاء التفعيل (النقل لخادم جديد)
''', area='license')

# =============================================================== Legal structure (Company/Branch/Site)
table('ORG_BUSINESS_GROUP', 'مجموعات الأعمال', 'Business Groups', scope='T', mix='code names eff status', status='ACTIVE INACTIVE', cols='''
CONSOLIDATION_CURRENCY CUR       | عملة التجميع
PARENT_GROUP_ID ID   >ORG_BUSINESS_GROUP | المجموعة الأم
''', area='legal', purpose='مجموعة قابضة اختيارية لتنظيم شركات مرتبطة (12.2)')

COMPANY_STATUS = ('DRAFT UNDER_CONFIGURATION READY_FOR_REVIEW ACTIVE SUSPENDED INACTIVE CLOSURE_REQUESTED '
                  'UNDER_LIQUIDATION TRANSACTIONS_BLOCKED FINANCIALLY_CLOSED LEGALLY_CLOSED CLOSED ARCHIVED')

table('ORG_COMPANY', 'الشركات (الكيانات القانونية)', 'Companies / Legal Entities', scope='T', mix='pub code status', status=COMPANY_STATUS, cols='''
BUSINESS_GROUP_ID ID >ORG_BUSINESS_GROUP | مجموعة الأعمال
LEGAL_NAME_AR   NAME NN          | الاسم القانوني بالعربية
LEGAL_NAME_EN   NAME             | الاسم القانوني بالإنجليزية
TRADE_NAME_AR   NAME             | الاسم التجاري بالعربية
TRADE_NAME_EN   NAME             | الاسم التجاري بالإنجليزية
LEGAL_FORM_CODE CODE             | الشكل القانوني (من Country Pack)
COUNTRY_CODE    CTRY NN          | دولة التسجيل
COUNTRY_PACK_ID ID   >LOC_COUNTRY_PACK | حزمة الدولة المطبقة
INCORPORATION_DATE DATE          | تاريخ التأسيس
FUNCTIONAL_CURRENCY CUR NN       | العملة الوظيفية الحالية (التغيير Migration مالية)
REPORTING_CURRENCY CUR           | عملة التقارير
DEFAULT_LANGUAGE LANG NN D='ar'  | اللغة
TIMEZONE_CODE   V64  NN D='Asia/Riyadh' | المنطقة الزمنية
INDUSTRY_CODE   CODE             | النشاط/القطاع
LOGO_DOCUMENT_ID ID  >DMS_DOCUMENT | الشعار
SEAL_DOCUMENT_ID ID  >DMS_DOCUMENT | الختم
ACTIVATED_AT    TS               | وقت التفعيل
ACTIVATED_BY    USR              | المفعل
CONFIG_LOCKED   YN   NN D='N'    | الإعدادات الجوهرية مقفلة بعد أول معاملة
''', area='legal', purpose='كيان قانوني مستقل له تسجيل وضرائب ودفاتر وعملة؛ تغيير الاسم لا يغير COMPANY_ID')

table('ORG_COMPANY_CURRENCY', 'تاريخ عملات الشركة', 'Company Currency History', scope='C', mix='eff', cols='''
CURRENCY_ROLE   CODE NN IN:FUNCTIONAL,REPORTING,CONSOLIDATION | دور العملة
CURRENCY_CODE   CUR  NN          | العملة
CHANGE_EVENT_ID ID   >ORG_LEGAL_EVENT | حدث التغيير المعتمد
''', area='legal')

table('ORG_BRANCH', 'الفروع', 'Branches', scope='C', mix='pub code names eff status', status='DRAFT ACTIVE SUSPENDED CLOSING CLOSED', cols='''
BRANCH_TYPE     CODE NN          | نوع الفرع (Lookup: HEAD_OFFICE، REGIONAL، SALES، PROJECT...)
INDEPENDENCE_LEVEL CODE NN D='OPERATIONAL' IN:OPERATIONAL,COST_CENTER,PROFIT_CENTER,SEPARATE_SEQUENCE,SEPARATE_TAX | مستوى الاستقلال
IS_HEAD_OFFICE  YN   NN D='N'    | الفرع الرئيسي
COUNTRY_CODE    CTRY NN          | الدولة
CITY_ID         ID   >REF_CITY   | المدينة
TIMEZONE_CODE   V64              | المنطقة الزمنية
CURRENCY_CODE   CUR              | عملة الفرع (عادة عملة الشركة)
MANAGER_POSITION_ID ID >ORG_POSITION | منصب مدير الفرع
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة الافتراضي
COUNTRY_PACK_ID ID   >LOC_COUNTRY_PACK | حزمة الدولة
''', area='legal')

table('ORG_BUSINESS_SITE', 'المواقع التشغيلية', 'Business Sites', scope='C', mix='code names eff status', status='ACTIVE INACTIVE CLOSED', cols='''
BRANCH_ID       ID   >ORG_BRANCH  | الفرع المدير للموقع
SITE_TYPE       CODE NN          | نوع الموقع (مكتب، متجر، مصنع، ورشة، موقع مشروع، عقار، مركز بيانات...)
OWNERSHIP_TYPE  CODE IN:OWNED,LEASED,MANAGED,TEMPORARY | الملكية
MANAGER_POSITION_ID ID >ORG_POSITION | منصب المدير
WORKING_HOURS   JSON             | ساعات العمل
LATITUDE        NUM              | خط العرض
LONGITUDE       NUM              | خط الطول
''', area='legal', purpose='الموقع لا يحل محل المستودع أو المشروع أو الوحدة العقارية (12.4)')

table('ORG_LEGAL_REGISTRATION', 'التسجيلات القانونية', 'Legal Registrations', scope='T', mix='eff status',
      status='DRAFT UNDER_REVIEW ACTIVE EXPIRING EXPIRED SUSPENDED CANCELLED', cols='''
COMPANY_ID      ID   NN >ORG_COMPANY | الشركة
BRANCH_ID       ID   >ORG_BRANCH  | الفرع (فارغ = على مستوى الشركة)
REG_TYPE_ID     ID   NN >LOC_REGISTRATION_TYPE | نوع التسجيل (سجل تجاري، ضريبي، VAT، زكاة، بلدي...)
REG_NUMBER      V100 NN          | الرقم
ISSUING_AUTHORITY V200           | جهة الإصدار
COUNTRY_CODE    CTRY NN          | الدولة
REGION_CODE     V50              | المنطقة
ISSUE_DATE      DATE             | تاريخ الإصدار
EXPIRY_DATE     DATE             | تاريخ الانتهاء
IS_PRIMARY      YN   NN D='N'    | التسجيل الرئيسي لنوعه
PREVIOUS_REG_ID ID   >ORG_LEGAL_REGISTRATION | التسجيل السابق (لا يستبدل؛ ينتهي سريانه)
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند المثبت
''', ix=[('TENANT_ID', 'REG_NUMBER'), ('TENANT_ID', 'EXPIRY_DATE')], area='legal')

table('ORG_OWNERSHIP', 'سجل الملكية بين الشركات', 'Company Ownership', scope='T', mix='eff status wf', status='DRAFT APPROVED ACTIVE ENDED', cols='''
OWNER_COMPANY_ID ID  NN >ORG_COMPANY | الشركة المالكة
OWNED_COMPANY_ID ID  NN >ORG_COMPANY | الشركة المملوكة
OWNERSHIP_PCT   PCT  NN          | نسبة الملكية
VOTING_PCT      PCT              | نسبة التصويت/السيطرة
RELATION_TYPE   CODE NN IN:PARENT_SUBSIDIARY,SISTER,JOINT_VENTURE,ASSOCIATE,FOREIGN_BRANCH,MANAGEMENT_ONLY,CONSOLIDATION_ONLY,COMMERCIAL | نوع العلاقة
CONSOLIDATION_METHOD CODE IN:FULL,PROPORTIONAL,EQUITY,NONE | طريقة التجميع
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند القانوني
''', chk=['OWNER_COMPANY_ID <> OWNED_COMPANY_ID', 'OWNERSHIP_PCT BETWEEN 0 AND 100'], area='legal',
      purpose='لا تتجاوز الملكية الفعالة 100% للفترة نفسها ولا تحذف العلاقة القديمة (12.5)')

table('ORG_INTERCOMPANY_RULE', 'قواعد التعامل بين الشركات', 'Intercompany Rules', scope='T', mix='eff active', cols='''
FROM_COMPANY_ID ID   NN >ORG_COMPANY | الشركة المصدرة
TO_COMPANY_ID   ID   NN >ORG_COMPANY | الشركة المقابلة
RECEIVABLE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الذمم بين الشركات
PAYABLE_ACCOUNT_ID ID >GL_ACCOUNT | حساب الدائنين بين الشركات
PAYMENT_TERM_ID ID   >REF_PAYMENT_TERM | شروط الدفع
CURRENCY_CODE   CUR              | العملة
PRICING_POLICY  V200             | سياسة التسعير الداخلي
REQUIRES_CONFIRMATION YN NN D='Y' | يحتاج تأكيد الطرف الثاني
''', uk=[('TENANT_ID', 'FROM_COMPANY_ID', 'TO_COMPANY_ID', 'EFFECTIVE_FROM')],
      chk=['FROM_COMPANY_ID <> TO_COMPANY_ID'], area='legal')

table('ORG_LEGAL_EVENT', 'أحداث التغيير القانوني', 'Legal Entity Change Events', scope='T', mix='wf status',
      status='DRAFT UNDER_REVIEW APPROVED SCHEDULED IN_PROGRESS VALIDATED COMPLETED REJECTED CANCELLED ROLLED_BACK PARTIALLY_COMPLETED', cols='''
EVENT_NO        V50  NN U        | رقم الحدث
EVENT_TYPE      CODE NN IN:MERGER,ACQUISITION,SPLIT,GROUP_TRANSFER,LEGAL_FORM_CHANGE,RENAME,OWNERSHIP_CHANGE,BRANCH_TO_COMPANY,COMPANY_TO_BRANCH,CURRENCY_CHANGE,SUSPENSION,LIQUIDATION,CLOSURE | نوع العملية
DECISION_DATE   DATE             | تاريخ القرار
LEGAL_EFFECTIVE_DATE DATE        | السريان القانوني
ACCOUNTING_EFFECTIVE_DATE DATE   | السريان المحاسبي
REASON          V4000            | السبب
ISSUING_AUTHORITY V200           | الجهة المصدرة
IMPACT_ANALYSIS JSON             | تحليل الأثر
TRANSFER_PLAN   JSON             | خطة التحويل
DRY_RUN_RESULT  JSON             | نتيجة المحاكاة
VALIDATION_RESULT JSON           | نتائج التحقق والمطابقة
''', area='legal', purpose='Legal Entity Change Engine مع Dry Run و Validation و Rollback (12.8)')

table('ORG_LEGAL_EVENT_ENTITY', 'أطراف حدث التغيير القانوني', 'Legal Event Entities', scope='T', cols='''
LEGAL_EVENT_ID  ID   NN >ORG_LEGAL_EVENT | الحدث
COMPANY_ID      ID   >ORG_COMPANY | الشركة
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
ROLE_CODE       CODE NN IN:SOURCE,TARGET,SUCCESSOR,AFFECTED | دور الطرف
''', area='legal')

table('ORG_COMPANY_CHECK', 'فحوصات ما قبل تفعيل الشركة', 'Company Activation Checks', scope='C', mix='status', status='PENDING PASSED FAILED WAIVED', cols='''
CHECK_CODE      V50  NN          | الفحص (LEGAL_REG، CURRENCY، FISCAL_YEAR، COA، TAX، HEAD_BRANCH، ADMIN، SEQUENCES، LICENSE...)
CHECKED_AT      TS               | وقت الفحص
RESULT_INFO     V4000            | النتيجة
WAIVED_BY       USR              | معتمد الاستثناء
''', uk=[('TENANT_ID', 'COMPANY_ID', 'CHECK_CODE')], area='legal')

table('ORG_CONFIG_SNAPSHOT', 'لقطات إعدادات الشركة', 'Configuration Snapshots', scope='C', append=True, cols='''
SNAPSHOT_TYPE   CODE NN IN:ACTIVATION,PERIOD_CLOSE,CURRENCY_CHANGE,LEGAL_EVENT,MANUAL | سبب اللقطة
SNAPSHOT_DATA   JSON NN          | الإعدادات المعتمدة
''', area='legal')

table('ORG_COMPANY_TEMPLATE', 'قوالب إنشاء الشركات', 'Company Templates', scope='TO', mix='code names status', status='DRAFT APPROVED RETIRED', cols='''
COUNTRY_CODE    CTRY             | الدولة
VERSION_NO      INT  NN D=1      | الإصدار
TEMPLATE_DATA   JSON NN          | دليل الحسابات والضرائب والتسلسلات والأدوار وWorkflow
''', area='legal', purpose='لا تنسخ المعاملات أو المستخدمين أو الحسابات البنكية أو الأسرار')
