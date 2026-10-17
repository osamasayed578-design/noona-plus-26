from model.dsl import module, table

module(6, 'REF', 'البيانات المرجعية المشتركة والأطراف', 'Shared Reference Data & Global Party Model',
       'NOONA_REFERENCE_PKG',
       'اللغات والدول والعملات وأسعار الصرف والتسلسلات والقيم المرجعية القابلة للإعداد (BR-008)، '
       'ونموذج الطرف الموحد Global Party الذي يمنع تكرار الأشخاص والجهات بين العملاء والموردين والموظفين.')

# ---------------------------------------------------------------- Platform-wide reference
table('REF_LANGUAGE', 'اللغات', 'Languages', scope='G', mix='names active sort', cols='''
LANGUAGE_CODE   V10  NN U        | رمز اللغة (ar, en ...)
DIRECTION       CODE NN D='RTL' IN:RTL,LTR | اتجاه الكتابة
IS_FULL_UI      YN   NN D='N'    | لغة واجهة كاملة؟ (العربية والإنجليزية في V1)
''', purpose='اللغات المدعومة؛ العربية والإنجليزية كاملتان والبنية تسمح بلغات إضافية')

table('REF_CURRENCY', 'العملات', 'Currencies', scope='G', mix='names active', cols='''
CURRENCY_CODE   V3   NN U        | رمز ISO 4217
NUMERIC_CODE    V3               | الرمز الرقمي ISO
SYMBOL          V10              | الرمز المرئي
DECIMAL_PLACES  INT  NN D=2      | عدد المنازل العشرية (0 لـJPY، 3 لـKWD/BHD/OMR)
MINOR_UNIT_AR   V50              | اسم الوحدة الفرعية بالعربية
MINOR_UNIT_EN   V50              | اسم الوحدة الفرعية بالإنجليزية
ROUNDING_METHOD CODE NN D='HALF_UP' IN:HALF_UP,HALF_EVEN,UP,DOWN | طريقة التقريب
MIN_AMOUNT      AMT              | أقل مبلغ متداول
''', chk=['DECIMAL_PLACES BETWEEN 0 AND 6'],
      purpose='تعريف العملات والدقة؛ لا يفترض النظام منزلتين عشريتين (12.9)')

table('REF_COUNTRY', 'الدول', 'Countries', scope='G', mix='names active sort', cols='''
COUNTRY_CODE        V2   NN U    | رمز ISO 3166-1 alpha-2
ISO3_CODE           V3   NN U    | رمز ISO alpha-3
DEFAULT_CURRENCY    CUR          | العملة الافتراضية للدولة
DEFAULT_LANGUAGE    LANG         | اللغة الافتراضية
DEFAULT_TIMEZONE    V64          | المنطقة الزمنية الافتراضية IANA
PHONE_PREFIX        V10          | مفتاح الاتصال الدولي
SHOW_HIJRI          YN   NN D='N' | عرض التاريخ الهجري افتراضياً
LOCALIZATION_RANK   INT          | ترتيب بناء Country Pack المعتمد (1=السعودية ... 7=السودان)
''')

table('REF_CITY', 'المدن والمناطق', 'Cities / Regions', scope='G', mix='code names active', codeuk=False, cols='''
COUNTRY_CODE    CTRY NN          | الدولة
PARENT_CITY_ID  ID   >REF_CITY   | المنطقة/المحافظة الأم
LEVEL_CODE      CODE NN D='CITY' IN:REGION,PROVINCE,CITY,DISTRICT | مستوى التقسيم الإداري
''', uk=[('COUNTRY_CODE', 'CODE')])

table('REF_TIMEZONE', 'المناطق الزمنية', 'Time Zones', scope='G', mix='active', cols='''
TIMEZONE_CODE   V64  NN U        | اسم IANA مثل Asia/Riyadh
NAME_AR         NAME             | الاسم العربي
UTC_OFFSET      V6               | الإزاحة القياسية (للعرض فقط)
''')

table('REF_ENTITY_TYPE', 'سجل أنواع الكيانات', 'Entity Type Registry', scope='G', mix='names active', cols='''
ENTITY_TYPE_CODE  V50  NN U      | رمز نوع الكيان الثابت (مثل SAL_INVOICE)
MODULE_CODE       CODE NN        | الحزمة المالكة
TABLE_NAME        V128 NN        | الجدول الفعلي
VALIDATION_API    V128           | دالة التحقق الخادمي من وجود الكيان وصلاحيته
ALLOW_DMS_LINK    YN   NN D='Y'  | يقبل ربط مستندات؟
ALLOW_COR_LINK    YN   NN D='Y'  | يقبل ربط مراسلات؟
HAS_COMPANY       YN   NN D='Y'  | الكيان مقيد بشركة؟
''', purpose='Entity Type Registry (المرحلة 10): لا تقبل قيم ENTITY_TYPE حرة؛ كل ربط عام يرجع لهذا السجل')

# ---------------------------------------------------------------- Configurable lookups (BR-008)
table('REF_LOOKUP_TYPE', 'أنواع القوائم المرجعية', 'Lookup Types', scope='TO', mix='names desc', cols='''
LOOKUP_TYPE     V50  NN          | رمز نوع القائمة
MODULE_CODE     CODE             | الحزمة
IS_SYSTEM       YN   NN D='N'    | قيم نظامية لا يعدلها Tenant
IS_EXTENSIBLE   YN   NN D='Y'    | يسمح للمؤسسة بإضافة قيم
''', uk=[('TENANT_ID', 'LOOKUP_TYPE')])

table('REF_LOOKUP_VALUE', 'قيم القوائم المرجعية', 'Lookup Values', scope='TO', mix='names eff active sort', cols='''
LOOKUP_TYPE     V50  NN          | نوع القائمة
LOOKUP_CODE     V50  NN          | رمز القيمة (السلوك يرتبط بالرمز لا بالنص)
PARENT_VALUE_ID ID   >REF_LOOKUP_VALUE | قيمة أم (قوائم هرمية)
ATTRIBUTES      JSON             | خصائص إضافية للقيمة
''', uk=[('TENANT_ID', 'LOOKUP_TYPE', 'LOOKUP_CODE')],
      purpose='القيم القابلة لاختلاف المؤسسة تحفظ كـLookups (BR-008)؛ TENANT_ID فارغ = قيمة منصة')

table('REF_TRANSLATION', 'الترجمات الإضافية', 'Translations', scope='TO', cols='''
TABLE_NAME      V128 NN          | الجدول
ROW_ID          ID   NN          | معرف الصف
COLUMN_NAME     V128 NN          | العمود
LANGUAGE_CODE   LANG NN          | اللغة
TRANSLATED_TEXT V4000 NN         | النص المترجم
''', uk=[('TENANT_ID', 'TABLE_NAME', 'ROW_ID', 'COLUMN_NAME', 'LANGUAGE_CODE')],
      purpose='لغات إضافية مستقبلية دون تغيير الجداول (العربية/الإنجليزية في أعمدة NAME_AR/NAME_EN)')

# ---------------------------------------------------------------- Exchange rates
table('REF_RATE_TYPE', 'أنواع أسعار الصرف', 'Exchange Rate Types', scope='T', mix='code names active', cols='''
RATE_CATEGORY   CODE NN IN:OFFICIAL,CENTRAL_BANK,BANK,BUY,SELL,MARKET,CONTRACT,CUSTOMS,AVERAGE,CLOSING,CONSOLIDATION,MANUAL | فئة السعر
REQUIRES_APPROVAL YN NN D='N'    | يحتاج اعتماد قبل الاستخدام
MAX_DEVIATION_PCT PCT            | أقصى انحراف مسموح عن السعر السابق قبل التنبيه
''', purpose='يسمح بأكثر من نوع سعر وأكثر من سعر في اليوم (احتياج السودان)')

table('REF_EXCHANGE_RATE', 'أسعار الصرف', 'Exchange Rates', scope='T', mix='status', status='DRAFT APPROVED SUPERSEDED REJECTED', cols='''
RATE_TYPE_ID    ID   NN >REF_RATE_TYPE | نوع السعر
FROM_CURRENCY   CUR  NN          | من عملة
TO_CURRENCY     CUR  NN          | إلى عملة
RATE_DATE       DATE NN          | تاريخ السعر
EFFECTIVE_AT    TS   NN          | وقت السريان (يسمح بأكثر من سعر في اليوم)
RATE            RATE NN          | السعر (الاتجاه الرئيسي المعتمد للمؤسسة)
INVERSE_RATE    RATE @CALC       | السعر العكسي المحسوب
SOURCE_CODE     CODE NN D='MANUAL' IN:MANUAL,IMPORT,API | مصدر السعر
APPROVED_BY     USR              | المعتمد
REASON          V1000            | سبب الإدخال/التعديل اليدوي
''', uk=[('TENANT_ID', 'RATE_TYPE_ID', 'FROM_CURRENCY', 'TO_CURRENCY', 'EFFECTIVE_AT')],
      chk=['RATE > 0', 'FROM_CURRENCY <> TO_CURRENCY'],
      purpose='لا تتغير المعاملات القديمة عند تعديل الجدول؛ المعاملة تحفظ سعرها')

# ---------------------------------------------------------------- Numbering, payment terms
table('REF_DOC_SEQUENCE', 'تسلسلات ترقيم المستندات', 'Document Sequences', scope='C', mix='branch active', cols='''
DOC_TYPE_CODE   V50  NN          | نوع المستند (SAL_INVOICE، GL_JOURNAL...)
FISCAL_YEAR     INT              | السنة المالية (فارغ = تسلسل مستمر)
PREFIX          V30              | البادئة
SUFFIX          V30              | اللاحقة
NEXT_NUMBER     NUM  NN D=1      | الرقم التالي
PADDING         INT  NN D=6      | عدد خانات الرقم
IS_GAPLESS      YN   NN D='N'    | تسلسل قانوني بدون فجوات (الفواتير الضريبية)
RESET_POLICY    CODE NN D='YEARLY' IN:NEVER,YEARLY,MONTHLY | سياسة إعادة البدء
''', uk=[('TENANT_ID', 'COMPANY_ID', 'BRANCH_ID', 'DOC_TYPE_CODE', 'FISCAL_YEAR')],
      purpose='تسلسلات مستقلة لكل شركة/فرع/نوع/سنة؛ تخصيص الرقم عبر NOONA_REFERENCE_PKG مع قفل الصف')

table('REF_DOC_NUMBER_LOG', 'سجل الأرقام المخصصة', 'Document Number Allocation Log', scope='T', append=True, cols='''
SEQUENCE_ID     ID   NN >REF_DOC_SEQUENCE | التسلسل
ALLOCATED_NO    V80  NN          | الرقم المخصص
ENTITY_TYPE     V50  >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | نوع الكيان
ENTITY_ID       ID               | معرف الكيان
ALLOCATION_STATUS CODE NN D='USED' IN:USED,VOIDED | حالة الرقم (الأرقام الملغاة لا يعاد استخدامها)
''', uk=[('TENANT_ID', 'SEQUENCE_ID', 'ALLOCATED_NO')])

table('REF_PAYMENT_TERM', 'شروط الدفع', 'Payment Terms', scope='T', mix='code names active', cols='''
BASE_DATE_RULE  CODE NN D='DOC_DATE' IN:DOC_DATE,DELIVERY_DATE,END_OF_MONTH,RECEIPT_DATE | تاريخ الأساس
DUE_DAYS        INT  NN D=0      | أيام الاستحقاق (للدفعة الواحدة)
EARLY_DISCOUNT_PCT PCT           | خصم السداد المبكر
EARLY_DISCOUNT_DAYS INT          | مهلة خصم السداد المبكر
IS_INSTALLMENT  YN   NN D='N'    | شرط أقساط
''')

table('REF_PAYMENT_TERM_LINE', 'أقساط شرط الدفع', 'Payment Term Installments', scope='T', cols='''
PAYMENT_TERM_ID ID   NN >REF_PAYMENT_TERM | شرط الدفع
LINE_NO         INT  NN          | رقم القسط
DUE_PCT         PCT  NN          | نسبة القسط من الإجمالي
DUE_DAYS        INT  NN          | الأيام من تاريخ الأساس
''', uk=[('PAYMENT_TERM_ID', 'LINE_NO')])

table('REF_PAYMENT_METHOD', 'طرق الدفع', 'Payment Methods', scope='T', mix='code names active', cols='''
METHOD_TYPE     CODE NN IN:CASH,BANK_TRANSFER,CHEQUE,CARD,WALLET,GATEWAY,DIRECT_DEBIT,OFFSET | نوع الطريقة
REQUIRES_REFERENCE YN NN D='N'   | يتطلب مرجعاً خارجياً
''')

table('REF_BANK', 'البنوك', 'Banks', scope='TO', mix='code names active', cols='''
COUNTRY_CODE    CTRY NN          | دولة البنك
SWIFT_BIC       V11              | رمز SWIFT/BIC
LOCAL_BANK_CODE V30              | الرمز المحلي
''')

# ---------------------------------------------------------------- Global Party Model
table('PTY_PARTY', 'الأطراف (الهوية الموحدة)', 'Party', scope='T', mix='pub status', status='ACTIVE INACTIVE BLOCKED MERGED', cols='''
PARTY_NO        V50  NN          | رقم الطرف داخل المؤسسة
PARTY_TYPE      CODE NN IN:PERSON,ORGANIZATION | شخص طبيعي أو جهة
DISPLAY_NAME_AR NAME NN          | الاسم المعروض بالعربية
DISPLAY_NAME_EN NAME             | الاسم المعروض بالإنجليزية
OWNERSHIP_SCOPE CODE NN D='TENANT_SHARED' IN:TENANT_SHARED,GROUP_SHARED,COMPANY_OWNED,BRANCH_OWNED | نطاق ملكية السجل (12.6)
OWNER_GROUP_ID  ID   >ORG_BUSINESS_GROUP | المجموعة المالكة عند GROUP_SHARED
OWNER_COMPANY_ID ID  >ORG_COMPANY | الشركة المالكة عند COMPANY_OWNED
OWNER_BRANCH_ID ID   >ORG_BRANCH  | الفرع المالك عند BRANCH_OWNED
TAX_NUMBER      V50  PII         | الرقم الضريبي الرئيسي (لكشف التكرار)
COUNTRY_CODE    CTRY             | دولة الطرف
PREFERRED_LANGUAGE LANG          | لغة التواصل
RISK_CLASS      CODE             | تصنيف المخاطر
MERGED_INTO_PARTY_ID ID >PTY_PARTY | السجل الباقي Survivor بعد الدمج
''', uk=[('TENANT_ID', 'PARTY_NO')], ix=[('TENANT_ID', 'TAX_NUMBER'), ('TENANT_ID', 'DISPLAY_NAME_AR')],
      purpose='Global Party Model: هوية واحدة لكل شخص/جهة مع أدوار متعددة (عميل/مورد/موظف/مالك/مستأجر...)',
      sens='CONFIDENTIAL')

table('PTY_PERSON', 'بيانات الشخص الطبيعي', 'Person', scope='T', cols='''
PARTY_ID        ID   NN U >PTY_PARTY | الطرف
FIRST_NAME_AR   V100 NN PII      | الاسم الأول بالعربية
SECOND_NAME_AR  V100 PII         | اسم الأب
THIRD_NAME_AR   V100 PII         | اسم الجد
LAST_NAME_AR    V100 PII         | اسم العائلة
FIRST_NAME_EN   V100 PII         | First name
LAST_NAME_EN    V100 PII         | Last name
GENDER          CODE IN:M,F      | الجنس
BIRTH_DATE      DATE PII         | تاريخ الميلاد
NATIONALITY     CTRY             | الجنسية
MARITAL_STATUS  CODE PII         | الحالة الاجتماعية
''', sens='CONFIDENTIAL')

table('PTY_ORGANIZATION', 'بيانات الجهة الاعتبارية', 'Organization', scope='T', cols='''
PARTY_ID        ID   NN U >PTY_PARTY | الطرف
LEGAL_NAME_AR   NAME NN          | الاسم القانوني بالعربية
LEGAL_NAME_EN   NAME             | الاسم القانوني بالإنجليزية
TRADE_NAME_AR   NAME             | الاسم التجاري
ORG_TYPE_CODE   CODE             | نوع الجهة (شركة، حكومية، جمعية...)
CR_NUMBER       V50              | السجل التجاري
INDUSTRY_CODE   CODE             | النشاط/القطاع
IS_GOVERNMENT   YN   NN D='N'    | جهة حكومية
''')

table('PTY_IDENTIFICATION', 'وثائق هوية الطرف', 'Party Identifications', scope='T', mix='status', status='ACTIVE EXPIRED CANCELLED', cols='''
PARTY_ID        ID   NN >PTY_PARTY | الطرف
ID_TYPE_CODE    CODE NN IN:NATIONAL_ID,IQAMA,PASSPORT,CR,TAX,VAT,DRIVING_LICENSE,OTHER | نوع الوثيقة
ID_NUMBER_MASKED V50 NN          | الرقم مقنعاً للعرض
ID_NUMBER_HASH  HASH NN          | Hash للمطابقة وكشف التكرار دون كشف الرقم
ID_NUMBER_ENC   RAW16            | مرجع القيمة المشفرة في المخزن الآمن
ISSUING_COUNTRY CTRY             | دولة الإصدار
ISSUE_DATE      DATE             | تاريخ الإصدار
EXPIRY_DATE     DATE             | تاريخ الانتهاء (يولد تنبيهاً)
DOCUMENT_ID     ID   >DMS_DOCUMENT | صورة الوثيقة في DMS
IS_PRIMARY      YN   NN D='N'    | الوثيقة الرئيسية
''', uk=[('TENANT_ID', 'ID_TYPE_CODE', 'ID_NUMBER_HASH')], sens='HIGHLY_RESTRICTED')

table('PTY_PARTY_ROLE', 'أدوار الطرف', 'Party Roles', scope='T', mix='eff status', status='ACTIVE SUSPENDED ENDED', cols='''
PARTY_ID        ID   NN >PTY_PARTY | الطرف
ROLE_CODE       CODE NN IN:CUSTOMER,SUPPLIER,EMPLOYEE,OWNER,TENANT_CONTACT,CONTRACTOR,PARTNER,LANDLORD,LESSEE,GUEST,BUYER,BROKER,BANK,GOVERNMENT_AUTHORITY,OTHER | الدور
COMPANY_ID      ID   >ORG_COMPANY | الشركة التي ينطبق فيها الدور (فارغ = كل المؤسسة)
''', uk=[('TENANT_ID', 'PARTY_ID', 'ROLE_CODE', 'COMPANY_ID')])

table('PTY_RELATIONSHIP', 'العلاقات بين الأطراف', 'Party Relationships', scope='T', mix='eff', cols='''
FROM_PARTY_ID   ID   NN >PTY_PARTY | الطرف الأول
TO_PARTY_ID     ID   NN >PTY_PARTY | الطرف الثاني
RELATION_CODE   CODE NN          | نوع العلاقة (موظف لدى، ممثل عن، كفيل...)
''', chk=['FROM_PARTY_ID <> TO_PARTY_ID'])

table('PTY_ALIAS', 'الأسماء البديلة للطرف', 'Party Aliases', scope='T', cols='''
PARTY_ID        ID   NN >PTY_PARTY | الطرف
ALIAS_NAME      NAME NN          | الاسم البديل/السابق
ALIAS_TYPE      CODE NN IN:FORMER_NAME,TRADE_NAME,MERGED_RECORD,TRANSLITERATION | نوع الاسم
SOURCE_PARTY_ID ID   >PTY_PARTY  | السجل المدموج الأصلي
''')

table('PTY_MERGE_REQUEST', 'طلبات دمج الأطراف', 'Party Merge Requests', scope='T', mix='wf status', status='DRAFT SUBMITTED APPROVED EXECUTED REJECTED CANCELLED', cols='''
SURVIVOR_PARTY_ID ID NN >PTY_PARTY | السجل الباقي
MERGED_PARTY_ID ID   NN >PTY_PARTY | السجل المدموج
MATCH_SCORE     PCT              | درجة التطابق المقترحة
REASON          V1000 NN         | السبب
EXECUTED_AT     TS               | وقت التنفيذ
''', chk=['SURVIVOR_PARTY_ID <> MERGED_PARTY_ID'],
      purpose='الدمج يقترح ولا ينفذ تلقائياً؛ يحتاج Workflow ولا يكسر المراجع التاريخية')

table('PTY_BANK_ACCOUNT', 'الحسابات البنكية للأطراف', 'Party Bank Accounts', scope='T', mix='eff status',
      status='PENDING_VERIFICATION VERIFIED ACTIVE SUSPENDED REJECTED CLOSED', cols='''
PARTY_ID        ID   NN >PTY_PARTY | صاحب الحساب
BANK_ID         ID   >REF_BANK    | البنك
ACCOUNT_NAME    NAME NN PII      | اسم صاحب الحساب
IBAN_MASKED     V40  NN          | IBAN مقنع للعرض
IBAN_HASH       HASH NN          | Hash لكشف التكرار
IBAN_ENC_REF    V200             | مرجع القيمة المشفرة في Vault (لا تخزن القيمة الصريحة)
CURRENCY_CODE   CUR              | عملة الحساب
VERIFIED_BY     USR              | المتحقق (Maker-Checker: لا يكون نفس المنشئ)
VERIFIED_AT     TS               | وقت التحقق
VERIFICATION_CHANNEL CODE        | قناة التحقق المستقلة
''', ix=[('TENANT_ID', 'IBAN_HASH')], sens='HIGHLY_RESTRICTED',
      purpose='بيانات بنك الموردين والموظفين؛ تغييرها يتطلب Maker-Checker وتنبيه الحركات القريبة')

table('REF_ADDRESS', 'العناوين', 'Addresses', scope='T', mix='eff', cols='''
COMPANY_ID      ID   >ORG_COMPANY | عنوان شركة
BRANCH_ID       ID   >ORG_BRANCH  | عنوان فرع
SITE_ID         ID   >ORG_BUSINESS_SITE | عنوان موقع
PARTY_ID        ID   >PTY_PARTY   | عنوان طرف
ADDRESS_TYPE    CODE NN IN:LEGAL,CORRESPONDENCE,BILLING,SHIPPING,TAX,OPERATING,HOME,OTHER | نوع العنوان
COUNTRY_CODE    CTRY NN          | الدولة
CITY_ID         ID   >REF_CITY   | المدينة
DISTRICT        V100             | الحي
STREET          V200             | الشارع
BUILDING_NO     V20              | رقم المبنى
ADDITIONAL_NO   V20              | الرقم الإضافي (العنوان الوطني)
POSTAL_CODE     V20              | الرمز البريدي
ADDRESS_LINE_AR V500             | العنوان الكامل بالعربية
ADDRESS_LINE_EN V500             | العنوان الكامل بالإنجليزية
LATITUDE        NUM              | خط العرض
LONGITUDE       NUM              | خط الطول
IS_PRIMARY      YN   NN D='N'    | العنوان الرئيسي لنوعه
''', chk=['(CASE WHEN COMPANY_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN BRANCH_ID IS NOT NULL THEN 1 ELSE 0 END '
          '+ CASE WHEN SITE_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN PARTY_ID IS NOT NULL THEN 1 ELSE 0 END) = 1'],
      purpose='عناوين مؤرخة متعددة الأنواع (قوس حصري: شركة أو فرع أو موقع أو طرف)')

table('REF_CONTACT', 'جهات ووسائل الاتصال', 'Contacts', scope='T', mix='eff', cols='''
COMPANY_ID      ID   >ORG_COMPANY | جهة اتصال لشركة
BRANCH_ID       ID   >ORG_BRANCH  | جهة اتصال لفرع
SITE_ID         ID   >ORG_BUSINESS_SITE | جهة اتصال لموقع
PARTY_ID        ID   >PTY_PARTY   | جهة اتصال لطرف
CONTACT_ROLE    CODE NN IN:LEGAL,FINANCIAL,TECHNICAL,EMERGENCY,MANAGEMENT,SALES,GENERAL | صفة الاتصال
CONTACT_NAME    NAME PII         | اسم الشخص
JOB_TITLE       V200             | الصفة الوظيفية
DEPARTMENT      V200             | القسم
EMAIL           V320 PII         | البريد الإلكتروني
PHONE           V40  PII         | الهاتف
MOBILE          V40  PII         | الجوال
LANGUAGE_CODE   LANG             | لغة التواصل
NOTIFY_CONSENT  YN   NN D='N'    | موافقة على استقبال الإشعارات
IS_PRIMARY      YN   NN D='N'    | جهة الاتصال الرئيسية
''', chk=['(CASE WHEN COMPANY_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN BRANCH_ID IS NOT NULL THEN 1 ELSE 0 END '
          '+ CASE WHEN SITE_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN PARTY_ID IS NOT NULL THEN 1 ELSE 0 END) = 1'],
      sens='CONFIDENTIAL')

table('REF_RECORD_SHARE', 'مشاركة البيانات الأساسية بين الشركات', 'Master Data Sharing', scope='T', mix='eff', cols='''
ENTITY_TYPE     V50  NN >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | نوع السجل المشترك (PTY_PARTY، INV_ITEM...)
ENTITY_ID       ID   NN          | معرف السجل
COMPANY_ID      ID   NN >ORG_COMPANY | الشركة الممنوحة
CAN_READ        YN   NN D='Y'    | قراءة
CAN_USE         YN   NN D='Y'    | استخدام في المعاملات
CAN_EDIT        YN   NN D='N'    | تعديل (لا تمنح تلقائياً)
ALLOW_LOCAL_COPY YN  NN D='N'    | يسمح بنسخة محلية
APPROVED_BY     USR              | المعتمد
''', uk=[('TENANT_ID', 'ENTITY_TYPE', 'ENTITY_ID', 'COMPANY_ID')],
      purpose='المشاركة لا تمنح حق التعديل تلقائياً، ولا تتجاوز حدود Tenant (12.6)')
