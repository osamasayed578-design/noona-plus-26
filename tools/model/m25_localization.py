from model.dsl import module, table

module(25, 'LOC', 'حزم الدول والتوطين والضرائب', 'Country Packs, Localization & Tax Engine', 'NOONA_LOCALIZATION_PKG',
       'Country Pack لكل دولة بإصدارات مؤرخة (السعودية، الإمارات، قطر، عمان، البحرين، الكويت، السودان)، '
       'ومحرك الضرائب المركزي (تحديد ← قواعد ← احتساب ← محاسبة ← إقرار/فاتورة إلكترونية) وطبقة الفوترة '
       'الإلكترونية بمحولات مستقلة لكل دولة. القواعد إعدادات ذات إصدارات وليست قيماً ثابتة في PL/SQL.')

table('LOC_COUNTRY_PACK', 'حزم الدول', 'Country Packs', scope='G', mix='code names status',
      status='DRAFT CONFIGURING TESTING UAT APPROVED PUBLISHED RETIRED', codeuk=False, cols='''
COUNTRY_CODE    CTRY NN          | الدولة
VERSION_NO      INT  NN          | الإصدار
EFFECTIVE_DATE  DATE NN          | تاريخ السريان
LEGAL_REFERENCE V1000            | المرجع القانوني
DISPLAY_CALENDAR CODE NN D='GREGORIAN' IN:GREGORIAN,HIJRI_UMM_ALQURA,BOTH | تقويم العرض الرسمي
REVIEWED_BY_EXPERT V200          | المختص المحلي المراجع (شرط قبل الإنتاج)
PUBLISHED_AT    TS               | وقت النشر
''', uk=[('COUNTRY_CODE', 'VERSION_NO')], area='pack')

table('LOC_LEGAL_FORM', 'الأشكال القانونية', 'Legal Entity Forms', scope='G', mix='code names active', codeuk=False, cols='''
COUNTRY_PACK_ID ID   NN >LOC_COUNTRY_PACK | الحزمة
''', uk=[('COUNTRY_PACK_ID', 'CODE')], area='pack')

table('LOC_REGISTRATION_TYPE', 'أنواع التسجيلات القانونية', 'Registration Types', scope='TO', mix='code names active', codeuk=False, cols='''
COUNTRY_PACK_ID ID   >LOC_COUNTRY_PACK | الحزمة
APPLIES_TO      CODE NN D='COMPANY' IN:COMPANY,BRANCH,PARTY,PROPERTY,PROJECT | ينطبق على
IS_MANDATORY    YN   NN D='N'    | إلزامي قبل التفعيل
IS_TAX_REGISTRATION YN NN D='N'  | تسجيل ضريبي
VALIDATION_REGEX V200            | نمط التحقق من الرقم
EXPIRY_ALERT_DAYS INT            | التنبيه قبل الانتهاء
''', uk=[('TENANT_ID', 'COUNTRY_PACK_ID', 'CODE')], area='pack')

table('LOC_TAX_TYPE', 'أنواع الضرائب', 'Tax Types', scope='TO', mix='code names active', codeuk=False, cols='''
COUNTRY_PACK_ID ID   >LOC_COUNTRY_PACK | الحزمة
TAX_CATEGORY    CODE NN IN:VAT,SALES,EXCISE,WITHHOLDING,CUSTOMS,ZAKAT,MUNICIPAL,STAMP,PAYROLL,REAL_ESTATE,SERVICE,OTHER | الفئة
''', uk=[('TENANT_ID', 'COUNTRY_PACK_ID', 'CODE')], area='tax')

table('LOC_TAX_CODE', 'أكواد الضرائب', 'Tax Codes', scope='TO', mix='code names status', status='DRAFT ACTIVE RETIRED', codeuk=False, cols='''
TAX_TYPE_ID     ID   NN >LOC_TAX_TYPE | نوع الضريبة
TAX_NATURE      CODE NN IN:STANDARD,ZERO_RATED,EXEMPT,OUT_OF_SCOPE,REVERSE_CHARGE,WITHHOLDING,CUSTOM | الطبيعة
CALC_METHOD     CODE NN D='PERCENT' IN:PERCENT,FIXED_AMOUNT,PER_UNIT,COMPOUND | طريقة الحساب
IS_INCLUSIVE_DEFAULT YN NN D='N' | مضمنة في السعر افتراضياً
RECOVERABLE_PCT PCT  NN D=100    | نسبة الاسترداد للمشتريات
ROUNDING_LEVEL  CODE NN D='LINE' IN:LINE,TAX,DOCUMENT | مستوى التقريب
SHOW_ON_INVOICE YN   NN D='Y'    | يظهر في الفاتورة
REPORT_BOX_CODE V30              | خانة الإقرار
EINVOICE_CATEGORY V10            | فئة الفاتورة الإلكترونية (S/Z/E/O...)
''', uk=[('TENANT_ID', 'TAX_TYPE_ID', 'CODE')], area='tax')

table('LOC_TAX_RATE', 'إصدارات نسب الضرائب', 'Tax Rate Versions', scope='TO', mix='eff', cols='''
TAX_CODE_ID     ID   NN >LOC_TAX_CODE | الكود
VERSION_NO      INT  NN          | الإصدار (لا تعدل القاعدة القديمة)
RATE_PCT        PCT              | النسبة
FIXED_AMOUNT    AMT              | المبلغ الثابت
MIN_BASE        AMT              | الحد الأدنى للأساس
MAX_BASE        AMT              | الحد الأعلى
APPROVED_BY     USR              | المعتمد
''', uk=[('TAX_CODE_ID', 'VERSION_NO')], area='tax',
      purpose='الفواتير المرحلة تبقى على القاعدة السارية وقت الإصدار')

table('LOC_TAX_RULE', 'قواعد تحديد الضريبة', 'Tax Determination Rules', scope='TO', mix='code names eff status', status='DRAFT TESTED ACTIVE RETIRED', codeuk=False, cols='''
COUNTRY_PACK_ID ID   >LOC_COUNTRY_PACK | الحزمة
VERSION_NO      INT  NN D=1      | الإصدار
PRIORITY_NO     INT  NN D=100    | الأولوية
TRANSACTION_CLASS CODE NN IN:SALES,PURCHASE,REAL_ESTATE,PROJECT,ASSET,EXPENSE,PAYROLL,IMPORT,EXPORT | فئة المعاملة
CONDITIONS      JSON NN          | الشروط (الدولة، مكان التوريد، تسجيل الأطراف، المنتج، المشروع...)
RESULT_TAX_CODE_ID ID NN >LOC_TAX_CODE | الكود الناتج
EXPLANATION_AR  V1000            | سبب الاختيار المعروض للمستخدم
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='tax')

table('LOC_TAX_ACCOUNT', 'حسابات الضرائب للشركة', 'Company Tax Accounts', scope='C', mix='eff', cols='''
TAX_CODE_ID     ID   NN >LOC_TAX_CODE | الكود
PAYABLE_ACCOUNT_ID ID >GL_ACCOUNT | ضريبة مستحقة الدفع
RECOVERABLE_ACCOUNT_ID ID >GL_ACCOUNT | ضريبة قابلة للاسترداد
NON_RECOVERABLE_ACCOUNT_ID ID >GL_ACCOUNT | ضريبة غير مستردة
WITHHOLDING_ACCOUNT_ID ID >GL_ACCOUNT | ضريبة مستقطعة
ROUNDING_ACCOUNT_ID ID >GL_ACCOUNT | فروق التقريب
''', uk=[('TENANT_ID', 'COMPANY_ID', 'TAX_CODE_ID', 'EFFECTIVE_FROM')], area='tax')

table('LOC_TAX_EXEMPTION', 'شهادات الإعفاء الضريبي', 'Tax Exemption Certificates', scope='T', mix='eff status wf',
      status='DRAFT UNDER_REVIEW ACTIVE EXPIRED REVOKED', cols='''
CERTIFICATE_NO  V100 NN          | رقم الشهادة
EXEMPTION_TYPE  CODE NN IN:PARTY,PRODUCT,SERVICE,PROJECT,CONTRACT,GOVERNMENT,TEMPORAL | النوع
PARTY_ID        ID   >PTY_PARTY  | الطرف
ITEM_ID         ID   >INV_ITEM   | الصنف
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
TAX_CODE_ID     ID   NN >LOC_TAX_CODE | الكود البديل المطبق
ISSUING_AUTHORITY V200           | الجهة
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند
''', area='tax', purpose='لا يطبق إعفاء منتهٍ على معاملة جديدة')

table('LOC_TAX_LINE', 'أسطر الضرائب المحتسبة', 'Tax Lines (Engine Output)', scope='C', mix='src', cols='''
SOURCE_LINE_ID  ID               | سطر المصدر
TAX_CODE_ID     ID   NN >LOC_TAX_CODE | الكود
TAX_RATE_ID     ID   >LOC_TAX_RATE | إصدار النسبة المطبق
TAX_RULE_ID     ID   >LOC_TAX_RULE | القاعدة المطبقة
EXEMPTION_ID    ID   >LOC_TAX_EXEMPTION | الإعفاء
TAX_DATE        DATE NN          | تاريخ الضريبة
CURRENCY_CODE   CUR  NN          | العملة
TAXABLE_AMOUNT  AMT  NN          | الأساس
TAX_AMOUNT      AMT  NN          | الضريبة
TAX_AMOUNT_FUNC AMT              | بالعملة الوظيفية
RECOVERABLE_AMOUNT AMT           | القابل للاسترداد
IS_INCLUSIVE    YN   NN D='N'    | مضمنة
IS_MANUAL_OVERRIDE YN NN D='N'   | تعديل يدوي (يتطلب صلاحية وسبباً)
OVERRIDE_REASON V1000            | السبب
TAX_RETURN_ID   ID   >LOC_TAX_RETURN | الإقرار الذي شملها
''', ix=[('TENANT_ID', 'SOURCE_ENTITY_TYPE', 'SOURCE_ENTITY_ID'), ('TENANT_ID', 'COMPANY_ID', 'TAX_DATE')],
      area='tax', purpose='محرك واحد لكل الوحدات؛ تحفظ القاعدة والسبب لإعادة الإنتاج')

table('LOC_TAX_RETURN', 'الإقرارات الضريبية', 'Tax Returns', scope='C', mix='wf status',
      status='DRAFT REVIEWED APPROVED FILED PAID CLOSED REOPENED', cols='''
TAX_TYPE_ID     ID   NN >LOC_TAX_TYPE | نوع الضريبة
REGISTRATION_ID ID   >ORG_LEGAL_REGISTRATION | التسجيل الضريبي
PERIOD_START    DATE NN          | بداية الفترة
PERIOD_END      DATE NN          | نهاية الفترة
OUTPUT_TAX      AMT              | ضريبة المخرجات
INPUT_TAX       AMT              | ضريبة المدخلات
NET_PAYABLE     AMT              | الصافي
CARRY_FORWARD   AMT              | المرحل
FILED_AT        TS               | وقت التقديم
GOV_REFERENCE   V200             | مرجع الجهة الحكومية
FILING_DOCUMENT_ID ID >DMS_DOCUMENT | نسخة الإقرار
''', uk=[('TENANT_ID', 'COMPANY_ID', 'TAX_TYPE_ID', 'PERIOD_START')], area='tax')

table('LOC_TAX_RETURN_LINE', 'خانات الإقرار', 'Tax Return Boxes', scope='T', cols='''
TAX_RETURN_ID   ID   NN >LOC_TAX_RETURN | الإقرار
BOX_CODE        V30  NN          | الخانة
BASE_AMOUNT     AMT              | الأساس
TAX_AMOUNT      AMT              | الضريبة
ADJUSTMENT_AMOUNT AMT            | التعديلات
''', uk=[('TAX_RETURN_ID', 'BOX_CODE')], area='tax')

table('LOC_WITHHOLDING_CERT', 'شهادات الاستقطاع', 'Withholding Certificates', scope='C', mix='status', status='DRAFT ISSUED PAID CANCELLED', cols='''
CERTIFICATE_NO  V50  NN          | الرقم
PARTY_ID        ID   NN >PTY_PARTY | المورد/المقاول
TAX_CODE_ID     ID   NN >LOC_TAX_CODE | الكود
BASE_AMOUNT     AMT  NN          | الأساس
WITHHELD_AMOUNT AMT  NN          | المستقطع
CURRENCY_CODE   CUR  NN          | العملة
DUE_DATE        DATE             | تاريخ استحقاق التوريد
DOCUMENT_ID     ID   >DMS_DOCUMENT | الشهادة
''', uk=[('TENANT_ID', 'COMPANY_ID', 'CERTIFICATE_NO')], area='tax')

table('LOC_EINVOICE_PROFILE', 'إعدادات الفوترة الإلكترونية', 'E-Invoicing Profiles', scope='C', mix='branch status', status='DRAFT ONBOARDING ACTIVE SUSPENDED', cols='''
COUNTRY_PACK_ID ID   NN >LOC_COUNTRY_PACK | الحزمة
ADAPTER_CODE    V50  NN          | المحول (ZATCA، FTA...)
INTEGRATION_MODE CODE NN IN:REPORTING,CLEARANCE,REALTIME,BATCH | النمط
DEVICE_ID       V200             | معرف الجهاز/الحل المسجل
CERTIFICATE_REF V200             | مرجع الشهادة في Vault
ENDPOINT_REF    V200             | مرجع نقطة الاتصال
IS_SANDBOX      YN   NN D='Y'    | بيئة اختبار
''', area='einvoice')

table('LOC_EINVOICE_SUBMISSION', 'إرسالات الفوترة الإلكترونية', 'E-Invoice Submissions', scope='C', mix='src status',
      status='DRAFT VALIDATED READY_TO_SUBMIT SUBMITTED ACCEPTED CLEARED REJECTED VALIDATION_FAILED SUBMISSION_FAILED PENDING_RETRY CANCELLED', cols='''
PROFILE_ID      ID   NN >LOC_EINVOICE_PROFILE | الإعداد
INVOICE_UUID    V64  NN          | UUID الفاتورة
INVOICE_COUNTER NUM              | العداد التسلسلي (ICV)
INVOICE_HASH    HASH             | Hash الفاتورة
PREVIOUS_HASH   HASH             | Hash الفاتورة السابقة (سلسلة)
QR_PAYLOAD      V4000            | محتوى QR
GOV_REFERENCE   V200             | المرجع الحكومي
ATTEMPTS        INT  NN D=0      | المحاولات
NEXT_RETRY_AT   TS               | المحاولة التالية
IDEMPOTENCY_KEY V100 NN          | منع الإرسال المكرر
REQUEST_DOCUMENT_ID ID >DMS_DOCUMENT | الطلب المرسل كما هو (XML)
RESPONSE_DOCUMENT_ID ID >DMS_DOCUMENT | الاستجابة كما وردت
LEGAL_DOCUMENT_ID ID >DMS_DOCUMENT | النسخة القانونية المعتمدة (لا يعاد توليدها)
ERROR_INFO      JSON             | أخطاء التحقق/الرفض
SUBMITTED_AT    TS               | وقت الإرسال
RESPONDED_AT    TS               | وقت الاستجابة
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY'), ('TENANT_ID', 'INVOICE_UUID')],
      ix=[('TENANT_ID', 'STATUS_CODE', 'NEXT_RETRY_AT')], area='einvoice')
