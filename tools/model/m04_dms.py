from model.dsl import module, table

module(4, 'DMS', 'إدارة المستندات والأرشفة', 'Document Management & Archive', 'NOONA_DMS_PKG',
       'محرك DMS مركزي (BR-004): المستند سجل عمل وهوية ثابتة، والإصدارات 1..n غير قابلة للمحو، والمحتوى '
       'الثنائي في SecureFiles أو Object Storage، والربط بكيانات ERP عبر Document Link منضبط بسجل الأنواع، '
       'مع ACL والسرية والاحتفاظ والحجز القانوني والتوقيع.')

DOC_STATUS = ('DRAFT UPLOADING QUARANTINED AVAILABLE UNDER_REVIEW APPROVED ACTIVE ARCHIVED DISPOSED '
              'REJECTED EXPIRED SUPERSEDED UPLOAD_FAILED BLOCKED')

table('DMS_CATEGORY', 'فئات المستندات', 'Document Categories', scope='TO', mix='code names active sort', cols='''
PARENT_CATEGORY_ID ID >DMS_CATEGORY | الفئة الأم
''', area='classification')

table('DMS_RETENTION_POLICY', 'سياسات الاحتفاظ', 'Retention Policies', scope='TO', mix='code names eff status', status='DRAFT ACTIVE RETIRED', cols='''
COUNTRY_CODE    CTRY             | الدولة (Country Pack)
TRIGGER_EVENT   CODE NN IN:CREATION,TRANSACTION_CLOSE,CONTRACT_END,EMPLOYMENT_END,PROJECT_CLOSE,FISCAL_YEAR_END | الحدث المرجعي
RETENTION_MONTHS INT NN          | مدة الاحتفاظ بالأشهر
END_ACTION      CODE NN D='REVIEW' IN:REVIEW,ARCHIVE,DISPOSE,TRANSFER | الإجراء عند الانتهاء
LEGAL_REFERENCE V500             | المرجع القانوني
VERSION_NO      INT  NN D=1      | الإصدار
''', area='retention')

table('DMS_DOCUMENT_TYPE', 'أنواع المستندات وسياساتها', 'Document Types & Policies', scope='TO', mix='code names desc active', cols='''
CATEGORY_ID     ID   >DMS_CATEGORY | الفئة
DEFAULT_CONFIDENTIALITY CODE NN D='INTERNAL' IN:PUBLIC,INTERNAL,CONFIDENTIAL,SECRET,HIGHLY_RESTRICTED | السرية الافتراضية
ALLOWED_MIME_TYPES V1000         | أنواع الملفات المسموحة
MAX_FILE_MB     INT              | أقصى حجم بالميجابايت
NAMING_RULE     V200             | قاعدة التسمية
RETENTION_POLICY_ID ID >DMS_RETENTION_POLICY | سياسة الاحتفاظ
REQUIRES_REVIEW YN   NN D='N'    | يتطلب مراجعة قبل الاعتماد
REQUIRES_SIGNATURE YN NN D='N'   | يتطلب توقيعاً
SIGNATURE_LEVEL CODE IN:INTERNAL_CONFIRM,SIMPLE,ADVANCED_MFA,DIGITAL_CERT,ORG_SEAL | مستوى التوقيع
ALLOW_OCR       YN   NN D='Y'    | يسمح بـOCR
ALLOW_AI_INDEX  YN   NN D='N'    | يسمح بالفهرسة لـRAG
ALLOW_EXPORT    YN   NN D='Y'    | يسمح بالتصدير
REQUIRES_CHECKOUT YN NN D='N'    | يتطلب Check-out قبل التعديل
EXPIRY_ALERT_DAYS INT            | التنبيه قبل الانتهاء
''', area='classification')

table('DMS_METADATA_FIELD', 'حقول البيانات الوصفية', 'Metadata Field Definitions', scope='TO', mix='names sort', cols='''
DOCUMENT_TYPE_ID ID  NN >DMS_DOCUMENT_TYPE | نوع المستند
FIELD_CODE      V50  NN          | رمز الحقل
DATA_TYPE       CODE NN IN:TEXT,NUMBER,DATE,LOV,PARTY,AMOUNT,BOOLEAN | النوع
IS_MANDATORY    YN   NN D='N'    | إلزامي
IS_SEARCHABLE   YN   NN D='Y'    | قابل للبحث
LOOKUP_TYPE     V50              | القائمة المرجعية
VERSION_NO      INT  NN D=1      | إصدار التعريف
''', uk=[('DOCUMENT_TYPE_ID', 'FIELD_CODE', 'VERSION_NO')], area='classification')

table('DMS_TAG', 'الوسوم', 'Tags', scope='T', mix='code names', area='classification',
      purpose='لا تخزن بيانات حساسة في الوسوم العامة')

table('DMS_DOCUMENT', 'المستندات', 'Documents', scope='T', mix='pub branch conf status', status=DOC_STATUS, cols='''
COMPANY_ID      ID   >ORG_COMPANY | الشركة
DOCUMENT_TYPE_ID ID  NN >DMS_DOCUMENT_TYPE | النوع
REFERENCE_NO    V100             | الرقم المرجعي الاختياري
TITLE           V500 NN          | العنوان
DESCRIPTION     V4000            | الوصف
LANGUAGE_CODE   LANG             | لغة المستند
ORIGIN_TYPE     CODE NN D='AUTHENTIC' IN:AUTHENTIC,COPY,DERIVED,SYSTEM_GENERATED,EXTERNAL_INBOUND | الأصالة (يقرر مرة واحدة)
OWNER_MEMBER_ID ID   >SEC_USER_MEMBERSHIP | المالك
OWNER_UNIT_ID   ID   >ORG_UNIT   | الوحدة المالكة
CURRENT_VERSION_ID ID >DMS_DOCUMENT_VERSION | الإصدار الساري (مؤشر صريح)
DOCUMENT_DATE   DATE             | تاريخ المستند
VALID_FROM      DATE             | السريان من
VALID_TO        DATE             | الانتهاء
LEGAL_HOLD      YN   NN D='N'    | تحت حجز قانوني
RETENTION_POLICY_ID ID >DMS_RETENTION_POLICY | سياسة الاحتفاظ المطبقة
RETENTION_TRIGGER_DATE DATE      | تاريخ الحدث المرجعي
RETENTION_END_DATE DATE @CALC    | نهاية الاحتفاظ المحسوبة
CHECKED_OUT_BY_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المستخدم الحاجز (Check-out)
CHECKED_OUT_AT  TS               | وقت الحجز
CHECKOUT_EXPIRES_AT TS           | انتهاء الحجز
SOURCE_TEMPLATE_ID ID >DMS_TEMPLATE | القالب المولد منه
IS_DELETED      YN   NN D='N'    | حذف منطقي قابل للاستعادة
''', ix=[('TENANT_ID', 'DOCUMENT_TYPE_ID', 'STATUS_CODE'), ('TENANT_ID', 'RETENTION_END_DATE'), ('TENANT_ID', 'VALID_TO')],
      area='document', sens='CONFIDENTIAL',
      purpose='المستند سجل عمل بهوية ثابتة؛ الاسم أو المسار لا يمنح حق الوصول (17.1)')

table('DMS_FILE_CONTENT', 'محتوى الملفات', 'File Content', scope='T', mix='status', status='PENDING STORED VERIFIED MISSING CORRUPTED PURGED', cols='''
STORAGE_MEDIUM  CODE NN IN:SECUREFILE,OBJECT_STORAGE,NAS,S3_COMPATIBLE | وسيط التخزين
STORAGE_KEY     V1000            | المفتاح الداخلي في الوسيط (لا يعرض للمستخدم)
STORAGE_BUCKET_REF V200          | مرجع الحاوية
CONTENT_BLOB    BLOB             | المحتوى عند SecureFiles
FILE_NAME       V500 NN          | اسم الملف الأصلي
FILE_SIZE_BYTES NUM  NN          | الحجم
DECLARED_MIME   V200             | النوع المعلن
DETECTED_MIME   V200             | النوع الفعلي المكتشف
HASH_ALGORITHM  V20  NN D='SHA256' | خوارزمية Hash
HASH_VALUE      HASH NN          | قيمة Hash
SCAN_STATUS     CODE NN D='PENDING' IN:PENDING,CLEAN,INFECTED,FAILED,SKIPPED | فحص البرمجيات الضارة
SCANNED_AT      TS               | وقت الفحص
ENCRYPTION_KEY_REF V200          | مرجع مفتاح التشفير
LAST_VERIFIED_AT TS              | آخر تحقق دوري من Hash
''', ix=[('TENANT_ID', 'HASH_VALUE')], area='document', sens='CONFIDENTIAL',
      purpose='Dedupe اختياري داخل Tenant فقط ولا يكشف وجود الملف بين Tenants')

table('DMS_DOCUMENT_VERSION', 'إصدارات المستندات', 'Document Versions', scope='T', mix='status',
      status='PENDING_UPLOAD QUARANTINED READY_FOR_REVIEW CURRENT SUPERSEDED REJECTED UPLOAD_FAILED WITHDRAWN', cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
VERSION_NO      INT  NN          | رقم الإصدار المتسلسل
CONTENT_ID      ID   >DMS_FILE_CONTENT | المحتوى
CHANGE_TYPE     CODE NN D='INITIAL' IN:INITIAL,REVISION,CORRECTION,RESTORE,DERIVED,OCR,REDACTED,SIGNED | نوع التغيير
CHANGE_REASON   V1000            | سبب التغيير
SOURCE_VERSION_ID ID >DMS_DOCUMENT_VERSION | الإصدار المصدر (الاسترجاع/الاشتقاق)
UPLOADED_BY_MEMBER_ID ID >SEC_USER_MEMBERSHIP | الرافع
UPLOADED_AT     TS               | وقت الرفع
APPROVED_BY     USR              | المعتمد
CONFIDENTIALITY_LEVEL CODE IN:PUBLIC,INTERNAL,CONFIDENTIAL,SECRET,HIGHLY_RESTRICTED | سرية الإصدار إن اختلفت
IS_SIGNED       YN   NN D='N'    | موقع
''', uk=[('DOCUMENT_ID', 'VERSION_NO')], area='document',
      purpose='الاسترجاع ينشئ إصداراً جديداً ولا يعيد كتابة التاريخ (19.4)')

table('DMS_METADATA_VALUE', 'قيم البيانات الوصفية', 'Document Metadata Values', scope='T', cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
FIELD_ID        ID   NN >DMS_METADATA_FIELD | الحقل
VALUE_TEXT      V4000            | القيمة النصية
VALUE_NUMBER    NUM              | القيمة الرقمية
VALUE_DATE      DATE             | قيمة التاريخ
''', uk=[('DOCUMENT_ID', 'FIELD_ID')], area='document')

table('DMS_METADATA_REVISION', 'سجل تعديل البيانات الوصفية', 'Metadata Revisions', scope='T', append=True, cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
CHANGED_FIELDS  JSON NN          | الحقول القديمة والجديدة
REASON          V1000            | السبب
''', area='document')

table('DMS_DOCUMENT_TAG', 'وسوم المستند', 'Document Tags', scope='T', cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
TAG_ID          ID   NN >DMS_TAG | الوسم
''', uk=[('DOCUMENT_ID', 'TAG_ID')], area='document')

table('DMS_DOCUMENT_LINK', 'روابط المستندات بكيانات ERP', 'Document Links', scope='T', mix='status', status='ACTIVE DETACHED TOMBSTONED', cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
ENTITY_TYPE     V50  NN >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | نوع الكيان (من السجل فقط)
ENTITY_ID       ID   NN          | معرف الكيان (يتحقق خادمياً)
COMPANY_ID      ID   >ORG_COMPANY | شركة الكيان
LINK_ROLE       CODE NN          | الغرض (أصل فاتورة، إثبات تسليم، عقد، سند دفع، امتثال...)
PINNED_VERSION_ID ID >DMS_DOCUMENT_VERSION | الإصدار المثبت للأدلة المعتمدة
PINNED_HASH     HASH             | Hash المثبت
ADDED_METHOD    CODE NN D='MANUAL' IN:MANUAL,SYSTEM,INTEGRATION,EMAIL,SCAN | طريقة الإضافة
DETACHED_AT     TS               | وقت الفصل
DETACH_REASON   V1000            | سبب الفصل
''', uk=[('TENANT_ID', 'DOCUMENT_ID', 'ENTITY_TYPE', 'ENTITY_ID', 'LINK_ROLE')],
      ix=[('TENANT_ID', 'ENTITY_TYPE', 'ENTITY_ID')], area='links',
      purpose='Document Link كيان مستقل؛ لا ON DELETE CASCADE على الأدلة (18.2-18.3)')

table('DMS_ACL', 'قوائم التحكم في الوصول', 'Document ACL', scope='T', cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
PRINCIPAL_TYPE  CODE NN IN:USER,ROLE,POSITION,ORG_UNIT,COMMITTEE,GROUP | نوع الجهة
PRINCIPAL_ID    ID   NN          | معرف الجهة
PERMISSION_CODE CODE NN IN:LIST,VIEW_METADATA,PREVIEW,READ,DOWNLOAD,PRINT,EXPORT,UPLOAD,REPLACE_VERSION,CLASSIFY,SHARE,FORWARD,APPROVE,ARCHIVE,RESTORE,DISPOSE,MANAGE_HOLD,RECLASSIFY | الصلاحية
EFFECT          CODE NN D='ALLOW' IN:ALLOW,DENY | الأثر
VALID_UNTIL     TS               | صالح حتى
GRANTED_BY      USR              | المانح
''', uk=[('DOCUMENT_ID', 'PRINCIPAL_TYPE', 'PRINCIPAL_ID', 'PERMISSION_CODE')], area='security',
      purpose='ACL لا تتجاوز السرية الإلزامية أو عزل Tenant')

table('DMS_SHARE', 'مشاركات المستندات', 'Document Shares', scope='T', mix='status', status='ACTIVE EXPIRED REVOKED', cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
VERSION_ID      ID   >DMS_DOCUMENT_VERSION | الإصدار المشارك
SHARE_TYPE      CODE NN IN:INTERNAL,EXTERNAL | النوع
RECIPIENT_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المستلم الداخلي
RECIPIENT_EMAIL V320 PII         | المستلم الخارجي
TOKEN_HASH      HASH NN          | Hash رمز الرابط (لا يخزن الرمز)
REQUIRES_OTP    YN   NN D='Y'    | تحقق هوية
VIEW_ONLY       YN   NN D='Y'    | عرض فقط
WATERMARK       YN   NN D='Y'    | علامة مائية
MAX_DOWNLOADS   INT              | حد التنزيل
DOWNLOAD_COUNT  INT  NN D=0      | عدد التنزيلات
EXPIRES_AT      TS   NN          | الانتهاء (لا روابط عامة دائمة)
REVOKED_AT      TS               | وقت الإلغاء
''', uk=[('TOKEN_HASH',)], area='security')

table('DMS_COMMENT', 'تعليقات المستندات', 'Document Comments', scope='T', mix='conf', cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
VERSION_ID      ID   >DMS_DOCUMENT_VERSION | الإصدار
PARENT_COMMENT_ID ID >DMS_COMMENT | التعليق الأب
AUTHOR_MEMBER_ID ID  NN >SEC_USER_MEMBERSHIP | الكاتب
COMMENT_TEXT    V4000 NN         | النص (لا يصبح جزءاً من المستند الموقع)
''', area='collaboration')

table('DMS_OCR_TEXT', 'النص المستخرج OCR', 'Extracted Text (OCR)', scope='T', mix='status', status='PENDING PROCESSING DONE FAILED STALE', cols='''
VERSION_ID      ID   NN >DMS_DOCUMENT_VERSION | الإصدار
ENGINE_CODE     V50              | المحرك
ENGINE_VERSION  V50              | إصدار المحرك
LANGUAGE_CODE   LANG             | اللغة
QUALITY_SCORE   PCT              | جودة الاستخراج
EXTRACTED_TEXT  CLOB             | النص (مشتق؛ ليس بديلاً عن الأصل)
''', uk=[('VERSION_ID',)], area='search', purpose='يفهرس بـOracle Text؛ تطبق الصلاحيات قبل إظهار المقتطفات')

table('DMS_TEMPLATE', 'قوالب توليد المستندات', 'Document Templates', scope='TO', mix='code names status', status='DRAFT APPROVED RETIRED', codeuk=False, cols='''
DOCUMENT_TYPE_ID ID  >DMS_DOCUMENT_TYPE | نوع المستند الناتج
VERSION_NO      INT  NN D=1      | الإصدار
OUTPUT_FORMAT   CODE NN D='PDF' IN:PDF,DOCX,XLSX,HTML,XML,JSON | صيغة الإخراج
LANGUAGE_MODE   CODE NN D='BILINGUAL' IN:AR,EN,BILINGUAL | اللغة
TEMPLATE_CONTENT_ID ID >DMS_FILE_CONTENT | ملف القالب
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='document')

table('DMS_UPLOAD_SESSION', 'جلسات الرفع', 'Upload Sessions', scope='T', mix='status', status='OPEN COMPLETED EXPIRED FAILED', cols='''
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستخدم
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند
MAX_SIZE_BYTES  NUM  NN          | السقف
ALLOWED_MIME    V1000            | الأنواع المسموحة
IDEMPOTENCY_KEY V100 NN          | منع التكرار
EXPIRES_AT      TS   NN          | انتهاء الجلسة (قصيرة العمر)
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY')], area='document')

table('DMS_SIGNATURE_REQUEST', 'طلبات التوقيع', 'Signature Requests', scope='T', mix='status',
      status='DRAFT SENT PARTIALLY_SIGNED COMPLETED DECLINED EXPIRED CANCELLED', cols='''
VERSION_ID      ID   NN >DMS_DOCUMENT_VERSION | الإصدار المطلوب توقيعه
SIGNING_ORDER   CODE NN D='SEQUENTIAL' IN:SEQUENTIAL,PARALLEL,ANY_AUTHORIZED,ALL_PARTIES | ترتيب التوقيع
REQUIRED_LEVEL  CODE NN IN:INTERNAL_CONFIRM,SIMPLE,ADVANCED_MFA,DIGITAL_CERT,ORG_SEAL | المستوى (حسب Country Pack)
EXPIRES_AT      TS               | الانتهاء
WF_TASK_ID      ID   >WF_TASK    | مهمة Workflow
''', area='signature')

table('DMS_SIGNATURE', 'التوقيعات', 'Signatures', scope='T', append=True, cols='''
REQUEST_ID      ID   >DMS_SIGNATURE_REQUEST | الطلب
VERSION_ID      ID   NN >DMS_DOCUMENT_VERSION | الإصدار الموقع
SIGNED_HASH     HASH NN          | Hash البايتات الموقعة
SIGNER_MEMBER_ID ID  >SEC_USER_MEMBERSHIP | الموقع الداخلي
SIGNER_PARTY_ID ID   >PTY_PARTY  | الموقع الخارجي
SIGNER_CAPACITY V200             | صفة الموقع
DELEGATION_ID   ID   >DLG_DELEGATION | التوقيع بالنيابة
SIGNATURE_METHOD CODE NN IN:INTERNAL_CONFIRM,SIMPLE,ADVANCED_MFA,DIGITAL_CERT,ORG_SEAL | الطريقة
CERTIFICATE_REF V500             | مرجع الشهادة
TIMESTAMP_TOKEN V4000            | ختم زمني موثوق
VERIFICATION_METHOD CODE         | طريقة التحقق (OTP، MFA...)
RESULT_CODE     CODE NN IN:SIGNED,DECLINED,FAILED,REVOKED | النتيجة
SESSION_ID      ID   >SEC_SESSION | الجلسة
''', area='signature', purpose='التوقيع مرتبط ببايتات نسخة بعينها؛ تغيير المحتوى يستلزم إصداراً وتوقيعاً جديدين')

table('DMS_LEGAL_HOLD', 'الحجوزات القانونية', 'Legal Holds', scope='T', mix='status', status='ACTIVE RELEASED', cols='''
HOLD_NO         V50  NN          | الرقم
REASON          V4000 NN         | السبب (نزاع، تحقيق، أمر قضائي)
CASE_REF        V200             | مرجع القضية
RELEASED_BY     USR              | رافع الحجز (صلاحية مستقلة عبر Workflow)
RELEASED_AT     TS               | وقت الرفع
''', uk=[('TENANT_ID', 'HOLD_NO')], area='retention')

table('DMS_LEGAL_HOLD_ITEM', 'عناصر الحجز القانوني', 'Legal Hold Items', scope='T', cols='''
LEGAL_HOLD_ID   ID   NN >DMS_LEGAL_HOLD | الحجز
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند
ENTITY_TYPE     V50  >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | أو كيان كامل
ENTITY_ID       ID               | معرفه
''', area='retention')

table('DMS_DISPOSAL_BATCH', 'دفعات الإتلاف', 'Disposal Batches', scope='T', mix='wf status', status='CANDIDATES UNDER_REVIEW APPROVED EXECUTED CANCELLED', cols='''
BATCH_NO        V50  NN          | الرقم
DISPOSAL_METHOD CODE             | طريقة الإتلاف
CERTIFICATE_DOCUMENT_ID ID >DMS_DOCUMENT | شهادة الإتلاف
EXECUTED_AT     TS               | وقت التنفيذ
''', uk=[('TENANT_ID', 'BATCH_NO')], area='retention')

table('DMS_DISPOSAL_ITEM', 'عناصر الإتلاف', 'Disposal Items', scope='T', mix='status', status='CANDIDATE APPROVED EXCLUDED DISPOSED', cols='''
BATCH_ID        ID   NN >DMS_DISPOSAL_BATCH | الدفعة
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
EXCLUSION_REASON V1000           | سبب الاستبعاد (حجز، رابط ملزم، توقيع)
''', area='retention')

table('DMS_ACCESS_LOG', 'سجل الوصول للمستندات', 'Document Access Log', scope='T', append=True, cols='''
DOCUMENT_ID     ID   NN >DMS_DOCUMENT | المستند
VERSION_ID      ID   >DMS_DOCUMENT_VERSION | الإصدار
MEMBERSHIP_ID   ID   >SEC_USER_MEMBERSHIP | المستخدم
ACCESS_TYPE     CODE NN IN:LIST,VIEW_METADATA,PREVIEW,READ,DOWNLOAD,PRINT,EXPORT,SHARE,AI_RETRIEVAL | النوع
RESULT_CODE     CODE NN IN:ALLOWED,DENIED | النتيجة
DELEGATION_ID   ID   >DLG_DELEGATION | بالتفويض
CHANNEL         CODE IN:APEX,ORDS,JOB,AI,SHARE_LINK | القناة
SESSION_ID      ID   >SEC_SESSION | الجلسة
CORRELATION_ID  V64              | معرف الارتباط
''', ix=[('TENANT_ID', 'DOCUMENT_ID', 'CREATED_AT')], area='security', ret='حسب Country Pack؛ مرشح للتقسيم الشهري')

table('DMS_STORAGE_USAGE', 'استهلاك التخزين', 'Storage Usage', scope='T', cols='''
MEASURED_ON     DATE NN          | تاريخ القياس
STORAGE_MEDIUM  CODE NN          | الوسيط
FILE_COUNT      NUM  NN D=0      | عدد الملفات
TOTAL_BYTES     NUM  NN D=0      | الحجم الكلي
''', uk=[('TENANT_ID', 'MEASURED_ON', 'STORAGE_MEDIUM')], area='operations',
      purpose='تجاوز الحصة يمنع رفع الجديد ولا يحذف الملفات الحالية')
