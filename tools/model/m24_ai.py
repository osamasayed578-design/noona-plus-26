from model.dsl import module, table

module(24, 'AI', 'الذكاء الاصطناعي و RAG والوكلاء', 'AI, RAG & Agents', 'NOONA_AI_PKG',
       'بنية جاهزة لإضافة AI لاحقاً: المزودون والنماذج وإعدادات المؤسسة، ومصادر المعرفة والقطع المفهرسة '
       '(Embeddings تخزن BLOB على 21c وتنقل إلى VECTOR عند الترقية إلى 23ai/26ai)، والمحادثات والاسترجاع '
       'والاقتباسات، والأدوات READ/DRAFT/SUBMIT، والاستهلاك والتقييم. كل استرجاع يسبقه فحص Tenant والصلاحية.')

table('AI_PROVIDER', 'مزودو الذكاء الاصطناعي', 'AI Providers', scope='TO', mix='code names status', status='DRAFT ACTIVE DISABLED', cols='''
PROVIDER_TYPE   CODE NN IN:CLOUD_API,PRIVATE_HOSTED,ORACLE_OCI_GENAI,ON_PREMISES | النوع
ENDPOINT_REF    V200             | مرجع نقطة الاتصال
SECRET_REF      V200             | مرجع المفتاح في Vault
PROCESSING_REGION V100           | مكان معالجة البيانات
DATA_RETENTION_DAYS INT          | احتفاظ المزود بالبيانات
TRAINING_OPT_OUT YN  NN D='Y'    | منع التدريب على بيانات العميل
''', area='setup')

table('AI_MODEL', 'النماذج', 'AI Models', scope='TO', mix='code names status', status='ACTIVE DEPRECATED DISABLED', cols='''
PROVIDER_ID     ID   NN >AI_PROVIDER | المزود
MODEL_KIND      CODE NN IN:CHAT,EMBEDDING,RERANK,OCR,CLASSIFIER | النوع
MODEL_IDENTIFIER V200 NN         | المعرف لدى المزود
MODEL_VERSION   V50              | الإصدار
EMBEDDING_DIM   INT              | أبعاد المتجه
MAX_CONTEXT_TOKENS INT           | أقصى سياق
COST_PER_1K_INPUT AMT            | التكلفة لكل 1000 Token إدخال
COST_PER_1K_OUTPUT AMT           | التكلفة لكل 1000 Token إخراج
''', area='setup')

table('AI_TENANT_SETTING', 'إعدادات AI للمؤسسة', 'Tenant AI Settings', scope='T', cols='''
IS_ENABLED      YN   NN D='N'    | مفعل (يمكن تعطيله كلياً)
MODE_CODE       CODE NN D='CLOUD' IN:CLOUD,PRIVATE,DISABLED | النمط
CHAT_MODEL_ID   ID   >AI_MODEL   | نموذج المحادثة
EMBEDDING_MODEL_ID ID >AI_MODEL  | نموذج التضمين
ALLOWED_FEATURES V500            | الوظائف المسموحة (SEARCH، SUMMARIZE، QA، DRAFT)
REDACTION_POLICY JSON            | سياسة إخفاء البيانات قبل الإرسال الخارجي
CONVERSATION_RETENTION_DAYS INT NN D=90 | الاحتفاظ بالمحادثات
MONTHLY_TOKEN_QUOTA NUM          | الحصة الشهرية
MAX_CONFIDENTIALITY CODE NN D='INTERNAL' IN:PUBLIC,INTERNAL,CONFIDENTIAL,SECRET,HIGHLY_RESTRICTED | أعلى سرية يسمح بفهرستها
''', uk=[('TENANT_ID',)], area='setup')

table('AI_KNOWLEDGE_SOURCE', 'مصادر المعرفة', 'Knowledge Sources', scope='T', mix='code names status', status='DRAFT INDEXING ACTIVE PAUSED FAILED', cols='''
SOURCE_TYPE     CODE NN IN:DMS_DOCUMENT_TYPE,CORRESPONDENCE_TYPE,ERP_VIEW,POLICY_LIBRARY | النوع
SOURCE_REF      V200             | المرجع (نوع المستند، View...)
COMPANY_ID      ID   >ORG_COMPANY | الشركة
LAST_INDEXED_AT TS               | آخر فهرسة
''', area='rag')

table('AI_DOCUMENT_CHUNK', 'قطع المعرفة المفهرسة', 'Indexed Knowledge Chunks', scope='T', mix='conf status', status='ACTIVE STALE REVOKED PURGED', cols='''
SOURCE_ID       ID   >AI_KNOWLEDGE_SOURCE | المصدر
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند
VERSION_ID      ID   >DMS_DOCUMENT_VERSION | الإصدار المفهرس
CORRESPONDENCE_ID ID >COR_CORRESPONDENCE | المراسلة
COMPANY_ID      ID   >ORG_COMPANY | الشركة المالكة
CHUNK_NO        INT  NN          | رقم القطعة
CHUNK_TEXT      CLOB NN          | النص
LANGUAGE_CODE   LANG             | اللغة
TOKEN_COUNT     INT              | عدد الرموز
ACL_FINGERPRINT HASH             | بصمة الصلاحيات وقت الفهرسة (يعاد التحقق عند الإجابة)
EMBEDDING_MODEL_ID ID >AI_MODEL  | نموذج التضمين
EMBEDDING_DIM   INT              | الأبعاد
EMBEDDING       BLOB             | المتجه (FLOAT32 ثنائي) - يتحول إلى VECTOR في 23ai/26ai
CONTENT_HASH    HASH             | Hash النص
''', ix=[('TENANT_ID', 'DOCUMENT_ID'), ('TENANT_ID', 'CORRESPONDENCE_ID')], area='rag',
      purpose='لا تدخل وثيقة معزولة أو غير مفحوصة؛ يزال من الفهرس عند سحب الإذن أو الإتلاف', sens='CONFIDENTIAL')

table('AI_INDEX_JOB', 'مهام الفهرسة', 'Indexing Jobs', scope='T', mix='status', status='QUEUED RUNNING DONE FAILED CANCELLED', cols='''
JOB_TYPE        CODE NN IN:INDEX,REINDEX,REMOVE,REVALIDATE_ACL | النوع
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند
VERSION_ID      ID   >DMS_DOCUMENT_VERSION | الإصدار
CORRESPONDENCE_ID ID >COR_CORRESPONDENCE | المراسلة
ATTEMPTS        INT  NN D=0      | المحاولات
ERROR_MESSAGE   V2000            | الخطأ
''', ix=[('STATUS_CODE', 'CREATED_AT')], area='rag')

table('AI_CONVERSATION', 'المحادثات', 'Conversations', scope='T', mix='status', status='ACTIVE CLOSED PURGED', cols='''
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستخدم
COMPANY_ID      ID   >ORG_COMPANY | سياق الشركة
TITLE           V500             | العنوان
CONTEXT_SNAPSHOT JSON            | الدور والنطاق والتفويض وقت البدء
PURGE_AFTER     DATE             | تاريخ الإتلاف حسب الاحتفاظ
''', area='assistant')

table('AI_MESSAGE', 'رسائل المحادثة', 'Conversation Messages', scope='T', append=True, cols='''
CONVERSATION_ID ID   NN >AI_CONVERSATION | المحادثة
MESSAGE_ROLE    CODE NN IN:USER,ASSISTANT,TOOL,SYSTEM | الدور
CONTENT_REDACTED CLOB            | المحتوى بعد الإخفاء
MODEL_ID        ID   >AI_MODEL   | النموذج
INPUT_TOKENS    INT              | رموز الإدخال
OUTPUT_TOKENS   INT              | رموز الإخراج
SAFETY_FLAGS    JSON             | نتائج الفحص (Prompt Injection...)
UNCERTAINTY_NOTE V1000           | درجة عدم اليقين المعروضة
''', ix=[('TENANT_ID', 'CONVERSATION_ID')], area='assistant')

table('AI_RETRIEVAL', 'سجل الاسترجاع', 'Retrieval Log', scope='T', append=True, cols='''
MESSAGE_ID      ID   NN >AI_MESSAGE | الرسالة
CHUNK_ID        ID   NN >AI_DOCUMENT_CHUNK | القطعة
SIMILARITY      NUM              | درجة التشابه
PERMITTED_AT_ANSWER YN NN        | الصلاحية أعيد فحصها وقت الإجابة
USED_IN_ANSWER  YN   NN D='N'    | استخدمت في الإجابة
CITED           YN   NN D='N'    | ظهرت كاقتباس
''', ix=[('TENANT_ID', 'MESSAGE_ID')], area='assistant')

table('AI_TOOL', 'أدوات الوكيل', 'AI Tools', scope='TO', mix='code names status', status='DISABLED ENABLED', cols='''
OPERATION_CLASS CODE NN IN:READ,DRAFT,SUBMIT | فئة العملية (V1: READ فقط)
PERMISSION_CODE V100 >SEC_PERMISSION.PERMISSION_CODE | الصلاحية المطلوبة من المستخدم نفسه
HANDLER_API     V128 NN          | خدمة الأعمال المستدعاة
INPUT_SCHEMA    JSON             | مخطط المدخلات
REQUIRES_HUMAN_CONFIRM YN NN D='Y' | يتطلب تأكيداً بشرياً
''', area='agent', purpose='لا ينشئ AI تفويضاً ضمنياً ولا يوقع أو يدفع بلا إجراء بشري مخول')

table('AI_TOOL_CALL', 'استدعاءات الأدوات', 'Tool Calls', scope='T', append=True, cols='''
MESSAGE_ID      ID   NN >AI_MESSAGE | الرسالة
TOOL_ID         ID   NN >AI_TOOL | الأداة
ACTOR_MEMBER_ID ID   NN >SEC_USER_MEMBERSHIP | المستخدم صاحب الصلاحية
PARAMETERS_REDACTED JSON         | المعاملات بعد الإخفاء
RESULT_CODE     CODE NN IN:SUCCESS,DENIED,FAILED,AWAITING_CONFIRMATION | النتيجة
DATA_CUTOFF_TS  TS               | تاريخ قطع البيانات المرجعة
CORRELATION_ID  V64              | معرف الارتباط
''', area='agent')

table('AI_PROMPT_TEMPLATE', 'قوالب التعليمات', 'Prompt Templates', scope='TO', mix='code names status', status='DRAFT ACTIVE RETIRED', codeuk=False, cols='''
VERSION_NO      INT  NN D=1      | الإصدار
PURPOSE_CODE    CODE NN IN:SEARCH,SUMMARIZE,QA,DRAFT,CLASSIFY,EXTRACT | الغرض
LANGUAGE_CODE   LANG             | اللغة
TEMPLATE_TEXT   CLOB NN          | النص
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='setup')

table('AI_USAGE', 'استهلاك AI', 'AI Usage', scope='T', cols='''
USAGE_DATE      DATE NN          | اليوم
MODEL_ID        ID   NN >AI_MODEL | النموذج
FEATURE_CODE    CODE NN          | الوظيفة
REQUEST_COUNT   INT  NN D=0      | الطلبات
INPUT_TOKENS    NUM  NN D=0      | رموز الإدخال
OUTPUT_TOKENS   NUM  NN D=0      | رموز الإخراج
COST_AMOUNT     AMT  NN D=0      | التكلفة
''', uk=[('TENANT_ID', 'USAGE_DATE', 'MODEL_ID', 'FEATURE_CODE')], area='operations')

table('AI_FEEDBACK', 'تقييم الإجابات', 'Answer Feedback', scope='T', append=True, cols='''
MESSAGE_ID      ID   NN >AI_MESSAGE | الرسالة
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستخدم
RATING          INT  NN          | التقييم (-1/1 أو 1-5)
COMMENT_TEXT    V2000            | التعليق
''', area='evaluation')

table('AI_EVAL_CASE', 'حالات تقييم AI', 'AI Evaluation Cases', scope='TO', mix='code status', status='ACTIVE RETIRED', cols='''
CATEGORY        CODE NN IN:CROSS_TENANT_LEAK,CONFIDENTIAL_ATTACHMENT,ROLE_CHANGE,PROMPT_INJECTION,BALANCE_ACCURACY,REVOKED_ACCESS,QUALITY | الفئة
INPUT_TEXT      CLOB NN          | السؤال/المدخل
EXPECTED_BEHAVIOR V4000 NN       | السلوك المتوقع
LAST_RESULT     CODE IN:PASS,FAIL,NOT_RUN | آخر نتيجة
LAST_RUN_AT     TS               | آخر تشغيل
''', area='evaluation', purpose='سيناريوهات اختبار المرحلة 34 قبل تفعيل أي نموذج')
