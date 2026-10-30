from model.dsl import module, table

module(5, 'COR', 'المراسلات والإشعارات والتدقيق', 'Correspondence, Notifications & Audit',
       'NOONA_CORRESPONDENCE_PKG',
       'المراسلات الواردة والصادرة والداخلية مع فصل الجهة المقصودة عن المستلم الفعلي، وسجل تسليم مستقل '
       'لكل مستلم بأبعاد التسليم/الاطلاع/الإجراء/العرض، والتداول والتعليمات والأولوية؛ ومحرك الإشعارات '
       'المركزي (NOONA_NOTIFICATION_PKG)؛ وسجل التدقيق المركزي غير القابل للتعديل (NOONA_AUDIT_PKG).')

COR_STATUS = ('DRAFT REGISTERED VALIDATED UNDER_REVIEW APPROVED READY_TO_SEND SENT RECEIVED DISTRIBUTED '
              'IN_PROGRESS RETURNED_FOR_INFO DELIVERED DELIVERY_FAILED COMPLETED CLOSED ARCHIVED REJECTED CANCELLED')

# =============================================================== Correspondence
table('COR_INSTRUCTION', 'قاموس تعليمات المراسلات', 'Correspondence Instructions', scope='TO', mix='code names eff active sort', codeuk=False, cols='''
VERSION_NO      INT  NN D=1      | الإصدار (المهام التاريخية تحفظ نسختها)
REQUIRES_REPLY  YN   NN D='N'    | يتطلب رداً
REQUIRES_DECISION YN NN D='N'    | يتطلب قراراً
REQUIRES_ATTACHMENT YN NN D='N'  | يتطلب مرفقاً
DEFAULT_SLA_POLICY_ID ID >WF_SLA_POLICY | المهلة الافتراضية
RESULTING_TASK_TYPE CODE IN:NONE,INFO,REVIEW,STUDY,ACTION,EXECUTE,OPINION,REPORT,FILE | نوع المهمة الناتجة
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='setup',
      purpose='للعلم، للمراجعة، للدراسة، لاتخاذ اللازم، للتنفيذ، لإبداء الرأي، للإفادة، للحفظ (25.1)')

table('COR_TYPE', 'أنواع المراسلات', 'Correspondence Types', scope='TO', mix='code names active', cols='''
DIRECTION       CODE NN IN:INCOMING,OUTGOING,INTERNAL | الاتجاه
REQUIRES_APPROVAL YN NN D='N'    | يتطلب اعتماداً قبل الإرسال
DEFAULT_CONFIDENTIALITY CODE NN D='INTERNAL' IN:PUBLIC,INTERNAL,CONFIDENTIAL,SECRET,HIGHLY_RESTRICTED | السرية الافتراضية
WF_DEFINITION_ID ID  >WF_DEFINITION | مسار الاعتماد
RETENTION_POLICY_ID ID >DMS_RETENTION_POLICY | الاحتفاظ
ACK_POLICY      CODE NN D='NONE' IN:NONE,ALL,CATEGORY,MAJORITY,MANDATORY_RECIPIENT | سياسة الإقرار
MAX_AUDIENCE    INT              | الحد الأقصى للجمهور
''', area='setup')

table('COR_PRIORITY_POLICY', 'سياسات الأولوية والمهل', 'Priority Policies', scope='TO', mix='eff', cols='''
COR_TYPE_ID     ID   >COR_TYPE   | النوع
PRIORITY_CODE   CODE NN IN:LOW,NORMAL,HIGH,URGENT,VERY_URGENT | الأولوية
SLA_POLICY_ID   ID   NN >WF_SLA_POLICY | المهل والتصعيد
ALLOWED_CHANNELS V200            | القنوات المسموحة للتنبيه
''', uk=[('TENANT_ID', 'COR_TYPE_ID', 'PRIORITY_CODE', 'EFFECTIVE_FROM')], area='setup')

table('COR_CORRESPONDENCE', 'المراسلات', 'Correspondence', scope='T', mix='pub branch conf status', status=COR_STATUS, cols='''
COMPANY_ID      ID   NN >ORG_COMPANY | الشركة
COR_TYPE_ID     ID   NN >COR_TYPE | النوع
DIRECTION       CODE NN IN:INCOMING,OUTGOING,INTERNAL | الاتجاه
CORRESPONDENCE_NO V50            | الرقم الداخلي (يخصص عند المرحلة المناسبة)
NUMBERING_YEAR  INT              | سنة الترقيم
EXTERNAL_NO     V100             | الرقم الخارجي (ليس مفتاحاً)
SUBJECT         V1000 NN         | الموضوع
SUMMARY         V4000            | الملخص
BODY_TEXT       CLOB             | نص المراسلة
LANGUAGE_CODE   LANG             | اللغة
OWNER_UNIT_ID   ID   >ORG_UNIT   | الوحدة المالكة
AUTHOR_MEMBER_ID ID  >SEC_USER_MEMBERSHIP | المنشئ
LETTER_DATE     DATE             | تاريخ الخطاب
RECEIVED_AT     TS               | وقت الاستلام
SENT_AT         TS               | وقت الإرسال
TIMEZONE_CODE   V64              | المنطقة الزمنية
PRIORITY_CODE   CODE NN D='NORMAL' IN:LOW,NORMAL,HIGH,URGENT,VERY_URGENT | الأولوية
DUE_AT          TS               | موعد المراسلة
INBOUND_CHANNEL CODE IN:MANUAL,EMAIL,PORTAL,API,SCAN,INTEGRATION | قناة الورود
EXTERNAL_PARTY_ID ID >PTY_PARTY  | الجهة الخارجية
THREAD_ID       ID   >COR_CORRESPONDENCE | السلسلة (الجذر)
PARENT_ID       ID   >COR_CORRESPONDENCE | الرسالة الأم المباشرة
ORIGINAL_ID     ID   >COR_CORRESPONDENCE | الأصل
RELATION_TYPE   CODE IN:REPLY,REPLY_ALL,FORWARD,REFER,CORRECTION,FOLLOW_UP | نوع العلاقة
IS_INCOMPLETE   YN   NN D='N'    | بيانات ناقصة (وارد بلا رقم خارجي)
CLOSED_BY       USR              | من أغلق
CLOSE_REASON    V1000            | سبب الإغلاق
CORRELATION_ID  V64              | معرف الارتباط
DELIVERY_METHOD CODE IN:PRINT,EMAIL,BOTH | طريقة إيصال الصادر الخارجي: طباعة وتسليم، بريد إلكتروني، أو الاثنان
AUTHOR_STARRED  YN   NN D='N'    | مميزة بنجمة لدى المرسل
''', nuk=[('TENANT_ID', 'COMPANY_ID', 'CORRESPONDENCE_NO')],
      ix=[('TENANT_ID', 'THREAD_ID'), ('TENANT_ID', 'STATUS_CODE', 'DUE_AT'), ('TENANT_ID', 'EXTERNAL_NO')],
      chk=['PARENT_ID IS NULL OR PARENT_ID <> ID'], area='correspondence', sens='CONFIDENTIAL',
      purpose='حالة الرأس مستقلة عن حالات المستلمين ومهام Workflow والتسليم التقني (20.4)')

table('COR_PARTY', 'أطراف المراسلة الخارجية', 'Correspondence External Parties', scope='T', cols='''
CORRESPONDENCE_ID ID NN >COR_CORRESPONDENCE | المراسلة
PARTY_ROLE      CODE NN IN:SENDER,RECIPIENT,CC,ON_BEHALF_OF | الدور
PARTY_ID        ID   >PTY_PARTY  | الطرف المركزي
NAME_SNAPSHOT   NAME NN          | الاسم وقت المراسلة
ADDRESS_SNAPSHOT V1000           | العنوان وقت المراسلة
EMAIL           V320 PII         | البريد
''', area='correspondence')

table('COR_ADDRESSEE', 'الجهات المخاطبة', 'Intended Addressees', scope='T', mix='sort', cols='''
CORRESPONDENCE_ID ID NN >COR_CORRESPONDENCE | المراسلة
TARGET_TYPE     CODE NN IN:USER,EMPLOYEE,POSITION,ORG_UNIT,BRANCH,COMPANY,COMMITTEE,GROUP,EXPRESSION | نوع الجهة
TARGET_ID       ID               | معرف الجهة
TARGET_NAME_SNAPSHOT NAME NN     | الاسم كما اختاره المرسل
ADDRESSEE_ROLE  CODE NN D='TO' IN:TO,CC,BCC,FYI | الدور
RESOLUTION_POLICY CODE IN:HEAD,OFFICE,AUTHORIZED_MEMBERS,ALL_MEMBERS,CHAIR,ALL_COMMITTEE | سياسة الحل للوحدات واللجان
INSTRUCTION_ID  ID   >COR_INSTRUCTION | التعليمة
PRIORITY_CODE   CODE IN:LOW,NORMAL,HIGH,URGENT,VERY_URGENT | أولوية التكليف
DUE_AT          TS               | مهلة الجهة
IS_MANDATORY    YN   NN D='N'    | مستلم إلزامي
RESOLVED_COUNT  INT  @SYS        | عدد المستلمين الفعليين
''', area='correspondence', purpose='العنوان المقصود كما اختاره المرسل؛ يحفظ حتى لو تغير الهيكل (21.1)')

table('COR_RECIPIENT', 'سجلات تسليم المستلمين', 'Recipient Delivery Records', scope='T', cols='''
CORRESPONDENCE_ID ID NN >COR_CORRESPONDENCE | المراسلة
ADDRESSEE_ID    ID   NN >COR_ADDRESSEE | الجهة المقصودة
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستلم الفعلي
RECIPIENT_ROLE  CODE NN IN:TO,CC,BCC,FYI | الدور
POSITION_ID     ID   >ORG_POSITION | المنصب وقت الحل
DELEGATION_ID   ID   >DLG_DELEGATION | البديل بالتفويض
ORIGINAL_MEMBER_ID ID >SEC_USER_MEMBERSHIP | صاحب المنصب الأصلي
DELIVERY_STATUS CODE NN D='PENDING' IN:PENDING,DELIVERED,FAILED,RETURNED | بعد التسليم
READ_STATUS     CODE NN D='UNREAD' IN:UNREAD,READ | بعد الاطلاع
ACTION_STATUS   CODE NN D='NONE' IN:NONE,ACKNOWLEDGED,FORWARDED,ACTIONED,CLOSED | بعد الإجراء
VIEW_STATUS     CODE NN D='ACTIVE' IN:ACTIVE,ARCHIVED,RESTORED | العرض الشخصي (Inbox)
DELIVERED_AT    TS               | وقت التسليم
FIRST_READ_AT   TS               | أول قراءة فعلية
LAST_READ_AT    TS               | آخر اطلاع
ACKNOWLEDGED_AT TS               | وقت الإقرار
INSTRUCTION_ID  ID   >COR_INSTRUCTION | التعليمة
INSTRUCTION_SNAPSHOT JSON        | لقطة التعليمة ومعناها التنفيذي
DUE_AT          TS               | مهلة المستلم
RESOLUTION_SNAPSHOT JSON         | لقطة الهيكل والقاعدة والصفة وقت الحل
IDEMPOTENCY_KEY V100 NN          | منع إنشاء تسليم مكرر عند Retry
IS_STARRED      YN   NN D='N'    | مميزة بنجمة لدى المستلم
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY')],
      ix=[('TENANT_ID', 'MEMBERSHIP_ID', 'VIEW_STATUS', 'READ_STATUS'), ('TENANT_ID', 'CORRESPONDENCE_ID')],
      area='delivery', purpose='لكل مستلم حالة قراءة وإجراء مستقلة (BR-003)', ret='حسب سياسة المراسلة؛ مرشح للتقسيم')

table('COR_RECIPIENT_EVENT', 'أحداث المستلمين', 'Recipient Events', scope='T', append=True, cols='''
RECIPIENT_ID    ID   NN >COR_RECIPIENT | سجل التسليم
EVENT_CODE      CODE NN IN:RESOLVED,DELIVERED,DELIVERY_FAILED,OPENED,ACKNOWLEDGED,FORWARDED,ACTIONED,ARCHIVED,RESTORED,ACCESS_REVOKED | الحدث
ACTOR_MEMBER_ID ID   >SEC_USER_MEMBERSHIP | الفاعل
DELEGATION_ID   ID   >DLG_DELEGATION | بالتفويض
SESSION_ID      ID   >SEC_SESSION | الجلسة
EVENT_INFO      JSON             | تفاصيل
''', ix=[('TENANT_ID', 'RECIPIENT_ID')], area='delivery')

table('COR_CIRCULATION', 'محطات تداول المراسلة', 'Circulation Stations', scope='T', mix='status',
      status='ASSIGNED RECEIVED ACCEPTED INFO_REQUESTED RETURNED REFERRED FORWARDED COMPLETED ESCALATED CANCELLED', cols='''
CORRESPONDENCE_ID ID NN >COR_CORRESPONDENCE | المراسلة
PARENT_CIRCULATION_ID ID >COR_CIRCULATION | المحطة السابقة
FROM_MEMBER_ID  ID   >SEC_USER_MEMBERSHIP | من
TO_TARGET_TYPE  CODE NN IN:USER,POSITION,ORG_UNIT,COMMITTEE,QUEUE | نوع الجهة المحال إليها
TO_TARGET_ID    ID   NN          | معرفها
TO_MEMBER_ID    ID   >SEC_USER_MEMBERSHIP | الشخص الفعلي المحلول
INSTRUCTION_ID  ID   >COR_INSTRUCTION | التعليمة
REQUIRED_ACTION V1000            | الإجراء المطلوب
DUE_AT          TS               | المهلة
ENTERED_AT      TS   NN D=SYSTIMESTAMP | وقت الوصول للمحطة
LEFT_AT         TS               | وقت الخروج منها
DWELL_MINUTES   INT  @CALC       | زمن البقاء بدقائق العمل
WF_TASK_ID      ID   >WF_TASK    | المهمة المرتبطة
IS_PARALLEL     YN   NN D='N'    | فرع متوازٍ
RESULT_ENTITY_TYPE V50 >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | معاملة ناتجة
RESULT_ENTITY_ID ID              | معرفها
''', ix=[('TENANT_ID', 'CORRESPONDENCE_ID'), ('TENANT_ID', 'TO_MEMBER_ID', 'STATUS_CODE')], area='routing')

table('COR_CIRCULATION_NOTE', 'تعليقات التداول', 'Circulation Notes', scope='T', append=True, cols='''
CIRCULATION_ID  ID   NN >COR_CIRCULATION | المحطة
AUTHOR_MEMBER_ID ID  NN >SEC_USER_MEMBERSHIP | الكاتب
NOTE_TYPE       CODE NN D='COMMENT' IN:COMMENT,INSTRUCTION,CORRECTION_ADDENDUM,DECISION | النوع (التصحيح ملحق مؤرخ)
NOTE_TEXT       V4000 NN         | النص
''', area='routing')

table('COR_DUE_CHANGE', 'تغييرات المواعيد والأولوية', 'Due Date & Priority Changes', scope='T', append=True, cols='''
CORRESPONDENCE_ID ID NN >COR_CORRESPONDENCE | المراسلة
RECIPIENT_ID    ID   >COR_RECIPIENT | المستلم
CHANGE_TYPE     CODE NN IN:DUE_DATE,PRIORITY,SLA_PAUSE,SLA_RESUME,EXTENSION | النوع
OLD_VALUE       V200             | القيمة السابقة
NEW_VALUE       V200             | القيمة الجديدة
REASON          V1000 NN         | السبب
APPROVED_BY     USR              | المعتمد
''', area='routing', purpose='التمديد لا يمحو واقعة تأخر سابقة')

table('COR_DISPATCH', 'محاولات الإرسال الخارجي', 'Outbound Dispatch Attempts', scope='T', mix='status',
      status='QUEUED SENDING SENT DELIVERED FAILED BOUNCED CANCELLED', cols='''
CORRESPONDENCE_ID ID NN >COR_CORRESPONDENCE | المراسلة
CHANNEL         CODE NN IN:IN_SYSTEM,EMAIL,PRINT_HANDOVER,COURIER,API,PORTAL | القناة
DESTINATION     V500             | العنوان المستهدف
ATTEMPT_NO      INT  NN D=1      | رقم المحاولة
PROVIDER_MESSAGE_ID V200         | معرف الرسالة لدى المزود
PROOF_DOCUMENT_ID ID >DMS_DOCUMENT | إثبات الإرسال/الاستلام
IDEMPOTENCY_KEY V100 NN          | منع الإرسال المكرر
ERROR_MESSAGE   V1000            | الخطأ
RECEIVED_BY     V200             | المستلم لدى الجهة (التسليم اليدوي)
DELIVERED_AT    TS               | وقت التسليم أو الإرسال الفعلي
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY')], area='delivery')

table('COR_POLICY', 'سياسة المراسلات الداخلية', 'Internal Correspondence Policy', scope='C', cols='''
RESTRICT_BY_HIERARCHY YN NN D='N' | تقييد المراسلات الداخلية بالهيكل التنظيمي (الأعلى المباشر، المرؤوسون، الزملاء؛ دون تجاوز)
ALLOW_REPLY_TO_SENDER YN NN D='Y' | الرد على من راسلك مسموح دائماً
''', uk=[('COMPANY_ID',)], area='correspondence',
      purpose='الاتصال حسب الهيكل: صلاحيات COR_CONTACT.UP / DOWN / PEER / ANY')

table('COR_MAIL_PROFILE', 'بريد الشركة للمراسلات الخارجية', 'Correspondence Mail Profile', scope='C', mix='active', cols='''
FROM_ADDRESS    V320 NN          | عنوان المرسل (بريد الشركة المعتمد في خادم البريد)
FROM_NAME       V200             | اسم المرسل الظاهر
REPLY_TO        V320             | عنوان الرد (صندوق الوارد الذي تتابعه الإدارة)
ARCHIVE_BCC     V320             | نسخة مخفية للأرشيف
SIGNATURE_TEXT  V1000            | التذييل
''', uk=[('COMPANY_ID',)], area='delivery',
      purpose='الصادر الخارجي بالبريد يرسل من بريد الشركة عبر خادم البريد المعرف في APEX (APEX_MAIL)')

table('COR_CASE_FILE', 'ملفات القضايا', 'Case Files', scope='T', mix='code names status conf', status='OPEN CLOSED ARCHIVED', cols='''
COMPANY_ID      ID   >ORG_COMPANY | الشركة
OWNER_UNIT_ID   ID   >ORG_UNIT   | الوحدة المالكة
''', area='correspondence')

table('COR_CASE_LINK', 'ربط المراسلات بالقضايا', 'Case File Links', scope='T', cols='''
CASE_FILE_ID    ID   NN >COR_CASE_FILE | الملف
CORRESPONDENCE_ID ID NN >COR_CORRESPONDENCE | المراسلة
LINK_REASON     V500             | السبب
''', uk=[('CASE_FILE_ID', 'CORRESPONDENCE_ID')], area='correspondence')

# =============================================================== Notifications
table('NTF_EVENT_TYPE', 'أنواع أحداث الإشعار', 'Notification Event Types', scope='TO', mix='code names active', cols='''
MODULE_CODE     CODE NN          | الحزمة المصدر
CATEGORY        CODE NN IN:ACTION_REQUIRED,INFO,REMINDER,ESCALATION,SECURITY,LEGAL,BILLING,SYSTEM | الفئة
IS_MANDATORY    YN   NN D='N'    | إلزامي لا يلغيه تفضيل المستخدم
DEFAULT_CHANNELS V200 NN D='IN_APP' | القنوات الافتراضية
ALLOW_DIGEST    YN   NN D='Y'    | يقبل التجميع اليومي
''', area='notification')

table('NTF_TEMPLATE', 'قوالب الإشعارات', 'Notification Templates', scope='TO', mix='status', status='DRAFT PUBLISHED RETIRED', cols='''
EVENT_TYPE_ID   ID   NN >NTF_EVENT_TYPE | الحدث
CHANNEL         CODE NN IN:IN_APP,EMAIL,SMS,PUSH,WHATSAPP | القناة
LANGUAGE_CODE   LANG NN          | اللغة
VERSION_NO      INT  NN D=1      | الإصدار
MAX_CONFIDENTIALITY CODE NN D='INTERNAL' IN:PUBLIC,INTERNAL,CONFIDENTIAL,SECRET,HIGHLY_RESTRICTED | أعلى سرية يسمح بعرض تفاصيلها
SUBJECT_TEMPLATE V1000           | الموضوع
BODY_TEMPLATE   CLOB NN          | النص بمتغيرات مسموحة فقط
ALLOWED_VARIABLES V2000          | المتغيرات المسموحة
''', uk=[('TENANT_ID', 'EVENT_TYPE_ID', 'CHANNEL', 'LANGUAGE_CODE', 'VERSION_NO')], area='notification')

table('NTF_RULE', 'قواعد الإشعار', 'Notification Rules', scope='T', mix='active', cols='''
EVENT_TYPE_ID   ID   NN >NTF_EVENT_TYPE | الحدث
COMPANY_ID      ID   >ORG_COMPANY | الشركة
RECIPIENT_RULE  CODE NN IN:ASSIGNEE,REQUESTER,OWNER,MANAGER,ROLE,POSITION,ORG_UNIT,GROUP,WATCHERS | قاعدة المستلم
RECIPIENT_REF_ID ID              | معرف الجهة
CHANNELS        V200             | القنوات
CONDITION_INFO  JSON             | الشروط
''', area='notification')

table('NTF_USER_PREFERENCE', 'تفضيلات الإشعار', 'Notification Preferences', scope='T', cols='''
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستخدم
EVENT_TYPE_ID   ID   >NTF_EVENT_TYPE | الحدث (فارغ = عام)
CHANNEL         CODE NN IN:IN_APP,EMAIL,SMS,PUSH,WHATSAPP | القناة
IS_ENABLED      YN   NN D='Y'    | مفعلة
QUIET_FROM      V5               | بداية فترة الهدوء HH24:MI
QUIET_TO        V5               | نهاية فترة الهدوء
DIGEST_MODE     CODE NN D='IMMEDIATE' IN:IMMEDIATE,DAILY_DIGEST | نمط الاستلام
''', uk=[('TENANT_ID', 'MEMBERSHIP_ID', 'EVENT_TYPE_ID', 'CHANNEL')], area='notification')

table('NTF_NOTIFICATION', 'الإشعارات', 'Notifications', scope='TO', mix='conf status',
      status='CREATED QUEUED SENT DELIVERED READ ACKNOWLEDGED FAILED CANCELLED', cols='''
EVENT_TYPE_ID   ID   NN >NTF_EVENT_TYPE | الحدث
MEMBERSHIP_ID   ID   >SEC_USER_MEMBERSHIP | المستلم
USER_ID         ID   >SEC_USER   | المستلم (إشعارات المنصة)
SOURCE_ENTITY_TYPE V50 >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | الكائن المصدر
SOURCE_ENTITY_ID ID              | معرفه
SOURCE_VERSION  INT              | إصدار الكائن
TITLE           V500 NN          | العنوان المنقح حسب السرية
BODY_TEXT       V4000            | النص المنقح
LINK_URL        V1000            | رابط الدخول (يفحص الصلاحية عند الفتح)
REASON_TEXT     V500             | سبب الإشعار
IDEMPOTENCY_KEY V200 NN          | الحدث + المستلم + النوع
TEMPLATE_ID     ID   >NTF_TEMPLATE | القالب المستخدم
READ_AT         TS               | وقت القراءة داخل التطبيق
DUE_AT          TS               | موعد الإجراء المطلوب
CORRELATION_ID  V64              | معرف الارتباط
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY')], ix=[('TENANT_ID', 'MEMBERSHIP_ID', 'STATUS_CODE')], area='notification')

table('NTF_DELIVERY', 'محاولات تسليم الإشعارات', 'Notification Deliveries', scope='TO', mix='status',
      status='PENDING QUEUED SENT DELIVERED FAILED BOUNCED CANCELLED', cols='''
NOTIFICATION_ID ID   NN >NTF_NOTIFICATION | الإشعار
CHANNEL         CODE NN IN:IN_APP,EMAIL,SMS,PUSH,WHATSAPP | القناة
DESTINATION_MASKED V200          | العنوان مقنعاً
ATTEMPT_NO      INT  NN D=1      | المحاولة
NEXT_RETRY_AT   TS               | المحاولة التالية (Backoff)
PROVIDER_CODE   CODE             | المزود
PROVIDER_MESSAGE_ID V200         | معرف المزود
RESPONSE_CODE   V100             | استجابة المزود
COST_AMOUNT     AMT              | تكلفة القناة
''', ix=[('STATUS_CODE', 'NEXT_RETRY_AT')], area='notification',
      purpose='قبول مزود الرسائل ليس دليل قراءة المستلم (27.3)')

# =============================================================== Audit trail
table('AUD_EVENT', 'سجل التدقيق المركزي', 'Audit Events', scope='TO', append=True, cols='''
EVENT_CATEGORY  CODE NN IN:AUTH,SECURITY,CONFIG,DATA_CHANGE,APPROVAL,POSTING,PAYMENT,INVENTORY,SIGNATURE,DOCUMENT,CORRESPONDENCE,AI,API,SUPPORT,DEPLOYMENT,EXPORT | الفئة
ENTITY_TYPE     V50  >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | الكيان
ENTITY_ID       ID               | المعرف
ACTION_CODE     V50  NN          | الإجراء
RESULT_CODE     CODE NN IN:SUCCESS,DENIED,FAILED | النتيجة
ACTOR_USER_ID   ID   >SEC_USER   | المستخدم الفعلي
MEMBERSHIP_ID   ID   >SEC_USER_MEMBERSHIP | العضوية
ON_BEHALF_MEMBER_ID ID >SEC_USER_MEMBERSHIP | صاحب السلطة عند التفويض
DELEGATION_ID   ID   >DLG_DELEGATION | سند التفويض
COMPANY_ID      ID   >ORG_COMPANY | الشركة
SESSION_ID      ID   >SEC_SESSION | الجلسة
CORRELATION_ID  V64              | معرف الارتباط APEX → PL/SQL → ORDS → التكامل
REQUEST_SOURCE  CODE IN:APEX,ORDS,JOB,SYSTEM,AI,INTEGRATION | مصدر الطلب
IP_ADDRESS      V45              | IP
OCCURRED_AT     TS   NN D=SYSTIMESTAMP | وقت وقوع الحدث (يخزن مع المنطقة الزمنية ويعرض UTC)
OLD_VALUES      JSON             | القيم السابقة (الحقول الحساسة مخفاة)
NEW_VALUES      JSON             | القيم الجديدة
REASON          V1000            | السبب
PREV_HASH       HASH             | Hash السجل السابق (سلسلة مقاومة للعبث)
ROW_HASH        HASH             | Hash السجل
''', ix=[('TENANT_ID', 'ENTITY_TYPE', 'ENTITY_ID'), ('TENANT_ID', 'CREATED_AT'), ('CORRELATION_ID',)],
      area='audit', sens='CONFIDENTIAL', ret='حسب Country Pack ونوع الحدث؛ تقسيم شهري مقترح؛ لا يعدل عبر التطبيق',
      purpose='Who/What/When/Object/Action/Old/New/Session/IP (المرحلة 32)')

table('AUD_HASH_ANCHOR', 'نقاط تثبيت سلسلة التدقيق', 'Audit Hash Anchors', scope='TO', append=True, cols='''
FROM_EVENT_ID   ID   NN          | أول حدث
TO_EVENT_ID     ID   NN          | آخر حدث
CHAIN_HASH      HASH NN          | Hash التجميعي
EXTERNAL_ANCHOR_REF V500         | مرجع التثبيت خارج نطاق كتابة التطبيق
''', area='audit')

table('AUD_ALERT_RULE', 'قواعد تنبيهات الرقابة', 'Audit Alert Rules', scope='TO', mix='code names active', cols='''
EVENT_CATEGORY  CODE NN          | الفئة
CONDITION_INFO  JSON NN          | الشرط (رفع صلاحيات، تغيير بنك، موافقة ذاتية، تنزيل متكرر...)
SEVERITY        CODE NN IN:LOW,MEDIUM,HIGH,CRITICAL | الخطورة
NOTIFY_ROLE_ID  ID   >SEC_ROLE   | الدور المبلغ
''', area='audit')

table('AUD_ALERT', 'تنبيهات الرقابة', 'Audit Alerts', scope='TO', mix='status', status='OPEN ACKNOWLEDGED INVESTIGATING CLOSED FALSE_POSITIVE', cols='''
ALERT_RULE_ID   ID   NN >AUD_ALERT_RULE | القاعدة
AUDIT_EVENT_ID  ID   >AUD_EVENT  | الحدث
SECURITY_INCIDENT_ID ID >SEC_INCIDENT | الحادث المفتوح
ASSIGNED_TO     USR              | المكلف
RESOLUTION      V1000            | النتيجة
''', area='audit')
