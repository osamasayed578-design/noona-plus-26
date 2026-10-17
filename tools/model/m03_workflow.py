from model.dsl import module, table

module(3, 'WF', 'سير العمل والطلبات والاعتمادات والتفويض', 'Workflow, Requests, Approvals & Delegation',
       'NOONA_WORKFLOW_PKG',
       'محرك Workflow مركزي يفصل Definition/Version/Instance/Task/Action، وطبقة إدارة الطلبات والاستثناءات '
       'ومصفوفة السلطة وقوائم العمل وSLA، ومحرك التفويض المركزي (NOONA_DELEGATION_PKG) بنطاقه وحدوده '
       'وسجل التصرفات المنفذة بالنيابة.')

# =============================================================== Calendars & SLA
table('WF_BUSINESS_CALENDAR', 'تقويمات العمل', 'Business Calendars', scope='TO', mix='code names active', cols='''
COUNTRY_CODE    CTRY             | الدولة
COMPANY_ID      ID   >ORG_COMPANY | الشركة
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
TIMEZONE_CODE   V64  NN          | المنطقة الزمنية
WEEKEND_DAYS    V20  NN D='FRI,SAT' | أيام العطلة الأسبوعية
WORK_HOURS      JSON             | ساعات العمل لكل يوم
''', area='calendar')

table('WF_CALENDAR_HOLIDAY', 'العطلات الرسمية', 'Calendar Holidays', scope='TO', cols='''
CALENDAR_ID     ID   NN >WF_BUSINESS_CALENDAR | التقويم
HOLIDAY_DATE    DATE NN          | التاريخ
NAME_AR         NAME NN          | الاسم
NAME_EN         NAME             | Name
IS_HALF_DAY     YN   NN D='N'    | نصف يوم
''', uk=[('CALENDAR_ID', 'HOLIDAY_DATE')], area='calendar')

table('WF_SLA_POLICY', 'سياسات SLA', 'SLA Policies', scope='TO', mix='code names active', cols='''
CALENDAR_ID     ID   >WF_BUSINESS_CALENDAR | التقويم
PRIORITY_CODE   CODE IN:LOW,NORMAL,HIGH,URGENT,VERY_URGENT | الأولوية
RESPONSE_MINUTES INT             | مهلة الاستجابة بدقائق العمل
COMPLETION_MINUTES INT           | مهلة الإنجاز
WARN_BEFORE_MINUTES INT          | التنبيه قبل الموعد
ESCALATION_RULES JSON            | مستويات التصعيد
ALLOW_AUTO_APPROVE YN NN D='N'   | يسمح بالاعتماد التلقائي (ممنوع افتراضياً للمالية والقانونية)
''', area='calendar')

# =============================================================== Definitions
table('WF_RULE', 'قواعد الشروط', 'Workflow Rules', scope='TO', mix='code names status', status='DRAFT TESTED PUBLISHED RETIRED', codeuk=False, cols='''
VERSION_NO      INT  NN D=1      | الإصدار
RULE_EXPRESSION JSON NN          | تعبير Rule Builder (حقول وعوامل مسموحة فقط؛ لا SQL حر)
PLSQL_FUNCTION  V128             | دالة معتمدة للقواعد المعقدة
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='definition')

table('WF_DEFINITION', 'تعريفات المسارات', 'Workflow Definitions', scope='TO', mix='code names desc active', cols='''
OBJECT_TYPE     V50  >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | نوع الكائن المعتمد
REQUEST_TYPE_ID ID   >WF_REQUEST_TYPE | نوع الطلب
SCOPE_LEVEL     CODE NN D='TENANT' IN:PLATFORM,COUNTRY,TENANT,BUSINESS_GROUP,COMPANY,BRANCH,ORG_UNIT,PROJECT,PROPERTY | مستوى التعريف (الأكثر تحديداً يتقدم)
SCOPE_ID        ID               | معرف النطاق
COUNTRY_CODE    CTRY             | الدولة عند COUNTRY
WORKFLOW_KIND   CODE NN D='APPROVAL' IN:APPROVAL,REVIEW,ROUTING,TASK,NOTIFICATION,DOCUMENT,CASE,STATE_MACHINE,CHECKLIST | النوع
''', area='definition')

table('WF_DEFINITION_VERSION', 'إصدارات المسارات', 'Workflow Definition Versions', scope='TO', mix='eff status',
      status='DRAFT UNDER_REVIEW APPROVED PUBLISHED ACTIVE RETIRED ARCHIVED', cols='''
DEFINITION_ID   ID   NN >WF_DEFINITION | التعريف
VERSION_NO      INT  NN          | الإصدار (لا يعدل بعد النشر)
DEFINITION_JSON JSON             | التمثيل الكامل للمسار
PUBLISHED_BY    USR              | الناشر
PUBLISHED_AT    TS               | وقت النشر
''', uk=[('DEFINITION_ID', 'VERSION_NO')], area='definition')

table('WF_STEP_DEF', 'خطوات المسار', 'Workflow Step Definitions', scope='TO', mix='names', cols='''
VERSION_ID      ID   NN >WF_DEFINITION_VERSION | إصدار المسار
STEP_CODE       V50  NN          | رمز الخطوة
STEP_TYPE       CODE NN IN:START,END,USER_TASK,APPROVAL,REVIEW,SYSTEM,NOTIFICATION,TIMER,DECISION,PARALLEL_SPLIT,PARALLEL_JOIN,SUB_WORKFLOW,INTEGRATION,DOC_GENERATION,VALIDATION,POSTING,MANUAL_CONFIRMATION,COMPENSATION,SIGNATURE | نوع الخطوة
ASSIGNEE_RULE   CODE IN:USER,REQUESTER,MANAGER,HEAD_POSITION,POSITION,ROLE,ORG_UNIT,COMMITTEE,APPROVAL_GROUP,PROJECT_MANAGER,PROPERTY_MANAGER,COST_CENTER_OWNER,BUDGET_OWNER,DATA_OWNER,SECURITY_ADMIN,QUEUE,AUTHORITY_MATRIX | قاعدة الإسناد
ASSIGNEE_REF_ID ID               | معرف الجهة المسندة
QUEUE_ID        ID   >WF_QUEUE   | قائمة العمل المشتركة
JOIN_POLICY     CODE IN:ALL,COUNT,PERCENT,ANY,MAJORITY,MANDATORY_PARTY | سياسة الدمج للتوازي
JOIN_VALUE      NUM              | العدد/النسبة
SLA_POLICY_ID   ID   >WF_SLA_POLICY | SLA
SUB_DEFINITION_ID ID >WF_DEFINITION | المسار الفرعي
ACTION_HANDLER  V128             | الإجراء الآلي (حزمة معتمدة)
EDITABLE_FIELDS JSON             | الحقول القابلة للتعديل عند الإرجاع
ALLOW_SELF_APPROVAL YN NN D='N'  | يسمح باعتماد الطالب لنفسه (ممنوع افتراضياً)
''', uk=[('VERSION_ID', 'STEP_CODE')], area='definition')

table('WF_TRANSITION_DEF', 'انتقالات المسار', 'Workflow Transitions', scope='TO', mix='sort', cols='''
VERSION_ID      ID   NN >WF_DEFINITION_VERSION | الإصدار
FROM_STEP_ID    ID   NN >WF_STEP_DEF | من خطوة
TO_STEP_ID      ID   NN >WF_STEP_DEF | إلى خطوة
OUTCOME_CODE    CODE             | نتيجة القرار المسببة للانتقال
RULE_ID         ID   >WF_RULE    | شرط الانتقال
IS_DEFAULT      YN   NN D='N'    | الانتقال الافتراضي
''', area='definition')

table('WF_QUEUE', 'قوائم العمل المشتركة', 'Work Queues', scope='T', mix='code names active', cols='''
COMPANY_ID      ID   >ORG_COMPANY | الشركة
CLAIM_POLICY    CODE NN D='FIFO' IN:FIFO,ROLE,LEAST_LOAD,SKILL,BRANCH,SUPERVISOR | سياسة الاستلام
SUPERVISOR_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المشرف
''', area='definition')

table('WF_QUEUE_MEMBER', 'أعضاء قوائم العمل', 'Queue Members', scope='T', mix='eff', cols='''
QUEUE_ID        ID   NN >WF_QUEUE | القائمة
MEMBERSHIP_ID   ID   >SEC_USER_MEMBERSHIP | المستخدم
ROLE_ID         ID   >SEC_ROLE   | الدور
POSITION_ID     ID   >ORG_POSITION | المنصب
''', area='definition')

table('WF_AUTHORITY_MATRIX', 'مصفوفة السلطة', 'Authority Matrix', scope='T', mix='eff status', status='DRAFT APPROVED ACTIVE RETIRED', cols='''
COMPANY_ID      ID   >ORG_COMPANY | الشركة
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
TRANSACTION_TYPE V50 NN >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | نوع المعاملة
ACTION_CODE     V40  NN D='APPROVE' | الإجراء
POSITION_ID     ID   >ORG_POSITION | المنصب
JOB_ID          ID   >ORG_JOB    | الوظيفة
GRADE_ID        ID   >ORG_GRADE  | الدرجة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
MAX_AMOUNT      AMT              | الحد الأعلى للمبلغ
CURRENCY_CODE   CUR              | العملة
''', chk=['POSITION_ID IS NOT NULL OR JOB_ID IS NOT NULL OR GRADE_ID IS NOT NULL'], area='definition',
      purpose='حدود السلطة حسب المنصب والمعاملة والمبلغ والعملة؛ يرفع للمستوى الأعلى إن لم يكف الحد')

# =============================================================== Runtime
table('WF_INSTANCE', 'مسارات قيد التشغيل', 'Workflow Instances', scope='T', mix='status',
      status='CREATED RUNNING WAITING COMPLETED SUSPENDED CANCELLED FAILED TERMINATED EXPIRED COMPENSATING', cols='''
VERSION_ID      ID   NN >WF_DEFINITION_VERSION | الإصدار الذي بدأ عليه (يكمل عليه)
COMPANY_ID      ID   >ORG_COMPANY | الشركة
OBJECT_TYPE     V50  NN >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | نوع الكائن
OBJECT_ID       ID   NN          | معرف الكائن
REQUEST_ID      ID   >WF_REQUEST | الطلب
PARENT_INSTANCE_ID ID >WF_INSTANCE | المسار الأب (Sub-Workflow)
BUSINESS_EVENT_ID V100           | معرف الحدث المسبب
IDEMPOTENCY_KEY V100 NN          | منع بدء المسار مرتين
INITIATOR_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المنشئ
CONTEXT_SNAPSHOT JSON            | لقطة السياق (المبلغ، العملة، الطرف، القاعدة...)
OUTCOME_CODE    CODE             | النتيجة النهائية
STARTED_AT      TS   NN D=SYSTIMESTAMP | البداية
COMPLETED_AT    TS               | الاكتمال
CORRELATION_ID  V64              | معرف الارتباط
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY')], ix=[('TENANT_ID', 'OBJECT_TYPE', 'OBJECT_ID'), ('TENANT_ID', 'STATUS_CODE')],
      area='runtime', purpose='حالة المعاملة مستقلة عن حالة Workflow')

table('WF_TASK', 'المهام', 'Workflow Tasks', scope='T', mix='status conf',
      status='PENDING CLAIMED IN_PROGRESS WAITING_INFO COMPLETED RETURNED CANCELLED EXPIRED ESCALATED REASSIGNED FAILED', cols='''
INSTANCE_ID     ID   NN >WF_INSTANCE | المسار
STEP_ID         ID   NN >WF_STEP_DEF | الخطوة
TASK_TYPE       CODE NN          | نوع المهمة
ASSIGNEE_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المستلم الحالي
ORIGINAL_MEMBER_ID ID >SEC_USER_MEMBERSHIP | صاحب المسؤولية الأصلي
ASSIGNEE_POSITION_ID ID >ORG_POSITION | المنصب وقت الإسناد
QUEUE_ID        ID   >WF_QUEUE   | قائمة العمل
DELEGATION_ID   ID   >DLG_DELEGATION | سند التفويض المستخدم
PRIORITY_CODE   CODE NN D='NORMAL' IN:LOW,NORMAL,HIGH,URGENT,VERY_URGENT | الأولوية
DUE_AT          TS               | الموعد
WARN_AT         TS               | وقت التنبيه
CLAIMED_AT      TS               | وقت الاستلام
COMPLETED_AT    TS               | وقت الإنجاز
OUTCOME_CODE    CODE             | القرار
RESOLUTION_SNAPSHOT JSON         | لقطة قرار حل المستلم (لماذا وجهت المهمة له)
SLA_PAUSED_MINUTES INT NN D=0    | دقائق إيقاف SLA الموثقة
''', ix=[('TENANT_ID', 'ASSIGNEE_MEMBER_ID', 'STATUS_CODE'), ('TENANT_ID', 'STATUS_CODE', 'DUE_AT')],
      area='runtime')

table('WF_TASK_ACTION', 'قرارات المهام', 'Task Actions / Decisions', scope='T', append=True, cols='''
TASK_ID         ID   NN >WF_TASK | المهمة
ACTION_CODE     CODE NN IN:CLAIM,APPROVE,REJECT,RETURN,REQUEST_INFO,PROVIDE_INFO,FORWARD,REASSIGN,ABSTAIN,DELEGATE,ESCALATE,CANCEL,APPROVE_WITH_CONDITIONS,ACKNOWLEDGE,COMMENT,SIGN,SYSTEM | الإجراء
ACTOR_MEMBER_ID ID   NN >SEC_USER_MEMBERSHIP | المنفذ الفعلي
ON_BEHALF_MEMBER_ID ID >SEC_USER_MEMBERSHIP | صاحب السلطة الأصلي عند التفويض
DELEGATION_ID   ID   >DLG_DELEGATION | سند التفويض
ACTOR_POSITION_ID ID >ORG_POSITION | المنصب وقت القرار
ACTING_CAPACITY CODE IN:SELF,DELEGATE,ACTING,ADMIN,SYSTEM | الصفة
TARGET_MEMBER_ID ID  >SEC_USER_MEMBERSHIP | المحول إليه
COMMENTS        V4000            | التعليق
VALUES_SNAPSHOT JSON             | القيم وقت القرار
SIGNATURE_ID    ID   >DMS_SIGNATURE | التوقيع
SESSION_ID      ID   >SEC_SESSION | الجلسة
''', ix=[('TENANT_ID', 'TASK_ID')], area='runtime', purpose='لا تمحى الموافقات عند الإرجاع؛ سجل تراكمي')

table('WF_ESCALATION', 'التصعيدات', 'Escalations', scope='T', append=True, cols='''
TASK_ID         ID   NN >WF_TASK | المهمة
LEVEL_NO        INT  NN          | مستوى التصعيد
ESCALATION_TYPE CODE NN IN:REMINDER,MANAGER,REASSIGN,ADD_APPROVER,HIGHER_LEVEL,SUSPEND,AUTO_REJECT,INCIDENT | النوع
TARGET_MEMBER_ID ID  >SEC_USER_MEMBERSHIP | الجهة المصعد إليها
''', area='runtime')

# =============================================================== Requests, exceptions, attestations
table('WF_REQUEST_TYPE', 'أنواع الطلبات', 'Request Types', scope='TO', mix='code names desc eff status', status='DRAFT ACTIVE RETIRED', codeuk=False, cols='''
MODULE_CODE     CODE             | الحزمة
VERSION_NO      INT  NN D=1      | الإصدار
RISK_LEVEL      CODE NN D='NORMAL' IN:LOW,NORMAL,HIGH,CRITICAL | الخطورة
FORM_SCHEMA     JSON             | تعريف النموذج الديناميكي (لا SQL ولا JavaScript حر)
REQUIRED_DOC_TYPES V1000         | المستندات الإلزامية
EXECUTION_HANDLER V128           | إجراء التنفيذ بعد الاعتماد (Idempotent)
COUNTRY_CODE    CTRY             | الدولة
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='requests')

table('WF_REQUEST', 'الطلبات', 'Requests', scope='T', mix='pub branch conf status',
      status='DRAFT SUBMITTED UNDER_REVIEW RETURNED APPROVED EXECUTION_PENDING EXECUTED PARTIALLY_EXECUTED COMPLETED REJECTED CANCELLED WITHDRAWN EXPIRED FAILED', cols='''
REQUEST_NO      V50  NN          | رقم الطلب
REQUEST_TYPE_ID ID   NN >WF_REQUEST_TYPE | النوع (الإصدار المثبت)
COMPANY_ID      ID   >ORG_COMPANY | الشركة
REQUESTER_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | الطالب
REQUESTER_POSITION_ID ID >ORG_POSITION | منصب الطالب
SUBJECT         V500 NN          | الموضوع
FORM_DATA       JSON             | بيانات النموذج
SUBMIT_SNAPSHOT JSON             | لقطة عند الإرسال
AMOUNT          AMT              | المبلغ
CURRENCY_CODE   CUR              | العملة
PARENT_REQUEST_ID ID >WF_REQUEST | الطلب الأصل (سلاسل الطلبات)
REVISION_NO     INT  NN D=1      | رقم المراجعة عند إعادة التقديم
RESULT_ENTITY_TYPE V50 >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | المعاملة الناتجة
RESULT_ENTITY_ID ID              | معرفها
SUBMITTED_AT    TS               | وقت الإرسال
''', uk=[('TENANT_ID', 'REQUEST_NO')], ix=[('TENANT_ID', 'REQUESTER_MEMBER_ID', 'STATUS_CODE')], area='requests')

table('WF_APPROVAL_CONDITION', 'شروط الموافقة', 'Conditional Approval Obligations', scope='T', mix='status',
      status='OPEN FULFILLED WAIVED BREACHED', cols='''
INSTANCE_ID     ID   NN >WF_INSTANCE | المسار
TASK_ACTION_ID  ID   >WF_TASK_ACTION | قرار الموافقة المشروطة
CONDITION_TYPE  CODE NN IN:REDUCE_AMOUNT,GUARANTEE,DOCUMENT,MODIFICATION,ADDITIONAL_APPROVAL,EXECUTION_CAP,OTHER | النوع
DESCRIPTION     V1000 NN         | الشرط
IS_MANDATORY    YN   NN D='Y'    | يمنع الإغلاق قبل استيفائه
DUE_DATE        DATE             | الموعد
''', area='requests')

table('WF_EXCEPTION', 'سجل الاستثناءات', 'Policy Exceptions', scope='T', mix='wf status',
      status='DRAFT RISK_REVIEW PENDING_APPROVAL APPROVED ACTIVE EXPIRED CLOSED REJECTED REVOKED BREACHED', cols='''
EXCEPTION_NO    V50  NN          | الرقم
POLICY_CODE     V100 NN          | السياسة المخالفة
REASON          V4000 NN         | السبب
RISK_ASSESSMENT V4000            | المخاطر
COMPENSATING_CONTROLS V4000      | الضوابط التعويضية
OWNER_MEMBER_ID ID   NN >SEC_USER_MEMBERSHIP | المالك
ENTITY_TYPE     V50  >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | المعاملة
ENTITY_ID       ID               | معرفها
STARTS_AT       TS               | البداية
EXPIRES_AT      TS   NN          | الانتهاء (لا تجدد تلقائياً)
''', uk=[('TENANT_ID', 'EXCEPTION_NO')], area='requests', purpose='يمنع الاستثناء الدائم ولا يستخدم لتجاوز عزل Tenant')

table('WF_ATTESTATION', 'الإقرارات', 'Attestations', scope='T', append=True, cols='''
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المقر
ATTESTATION_TYPE CODE NN IN:CONFLICT_OF_INTEREST,DATA_ACCURACY,RECEIPT,COMPLETION,REVIEW,RESPONSIBILITY,CONSENT,CONFIDENTIALITY | النوع
TEXT_VERSION    V50  NN          | إصدار نص الإقرار
ATTESTATION_TEXT V4000 NN        | النص كما ظهر
ENTITY_TYPE     V50  >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | السياق
ENTITY_ID       ID               | المعرف
RESPONSE_CODE   CODE NN IN:ACCEPTED,DECLINED,DISCLOSED | الاستجابة
''', area='requests')

# =============================================================== Delegation engine
table('DLG_POLICY', 'سياسات التفويض', 'Delegation Policies', scope='TO', mix='code names eff active', cols='''
COUNTRY_CODE    CTRY             | الدولة
MAX_DURATION_DAYS INT            | أقصى مدة
ALLOW_REDELEGATION YN NN D='N'   | السماح بإعادة التفويض
NON_DELEGABLE_PERMISSIONS JSON   | العمليات غير القابلة للتفويض
REQUIRES_APPROVAL YN NN D='Y'    | يحتاج اعتماداً
REVIEW_EVERY_DAYS INT            | دورية المراجعة للتفويض المفتوح
''', area='delegation')

table('DLG_TEMPLATE', 'قوالب التفويض', 'Delegation Templates', scope='TO', mix='code names status', status='DRAFT ACTIVE RETIRED', codeuk=False, cols='''
POLICY_ID       ID   >DLG_POLICY | السياسة
DELEGATION_TYPE CODE NN IN:OPERATIONAL,APPROVAL,FINANCIAL,ADMINISTRATIVE,CORRESPONDENCE,SIGNATURE,ACCESS,EMERGENCY,ACTING | النوع
VERSION_NO      INT  NN D=1      | الإصدار
TEMPLATE_DATA   JSON             | الحقول الإلزامية والنطاق الافتراضي
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='delegation')

table('DLG_DELEGATION', 'التفويضات', 'Delegations', scope='T', mix='pub wf status',
      status='DRAFT SUBMITTED APPROVED SCHEDULED ACTIVE SUSPENDED EXPIRED REVOKED TERMINATED REJECTED CANCELLED', cols='''
DELEGATION_NO   V50  NN          | رقم التفويض
TEMPLATE_ID     ID   >DLG_TEMPLATE | القالب
DELEGATION_TYPE CODE NN IN:OPERATIONAL,APPROVAL,FINANCIAL,ADMINISTRATIVE,CORRESPONDENCE,SIGNATURE,ACCESS,EMERGENCY,ACTING | النوع
GRANTOR_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | المانح
GRANTOR_POSITION_ID ID >ORG_POSITION | الصفة التي صدر بها التفويض
DELEGATE_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | المفوض إليه
PARENT_DELEGATION_ID ID >DLG_DELEGATION | التفويض الأصل عند إعادة التفويض
VERSION_NO      INT  NN D=1      | إصدار التفويض (التعديل ينشئ إصداراً)
PREVIOUS_VERSION_ID ID >DLG_DELEGATION | الإصدار السابق
STARTS_AT       TS   NN          | البداية
ENDS_AT         TS               | النهاية (فارغ فقط لتفويض تنظيمي موثق)
TIMEZONE_CODE   V64  NN          | المنطقة الزمنية
REASON          V1000 NN         | السبب
ABSENCE_TYPE    CODE             | نوع الغياب أو الحاجة
LEAVE_REQUEST_ID ID  >HR_LEAVE_REQUEST | الإجازة المرتبطة
PRIORITY_NO     INT  NN D=1      | ترتيب الأولوية بين البدلاء
ALLOW_REDELEGATION YN NN D='N'   | يسمح بإعادة التفويض
OPEN_TASK_POLICY CODE NN D='KEEP' IN:KEEP,TRANSFER,RETURN,REVIEW | سياسة المهام المفتوحة
INCIDENT_REF    V100             | الحادث المرتبط (تفويض الطوارئ)
NEXT_REVIEW_DATE DATE            | المراجعة التالية
REVOKE_REASON   V1000            | سبب الإلغاء
''', uk=[('TENANT_ID', 'DELEGATION_NO', 'VERSION_NO')],
      chk=['GRANTOR_MEMBER_ID <> DELEGATE_MEMBER_ID', 'ENDS_AT IS NULL OR ENDS_AT > STARTS_AT'],
      ix=[('TENANT_ID', 'DELEGATE_MEMBER_ID', 'STATUS_CODE'), ('TENANT_ID', 'GRANTOR_MEMBER_ID', 'STATUS_CODE')],
      area='delegation', purpose='لا يعني مشاركة الحساب؛ ينفذ المفوض بهويته ويسجل أنه تصرف نيابة عن المانح (16.1)')

table('DLG_SCOPE', 'نطاق التفويض', 'Delegation Scope', scope='T', cols='''
DELEGATION_ID   ID   NN >DLG_DELEGATION | التفويض
DIMENSION_CODE  CODE NN IN:BUSINESS_GROUP,COMPANY,BRANCH,ORG_UNIT,PROJECT,PROPERTY,MODULE,PROCESS,REQUEST_TYPE,WORKFLOW,WORKFLOW_STEP,DOC_TYPE,CORRESPONDENCE_TYPE,TRANSACTION_TYPE,ACTION,PERMISSION,MAX_CONFIDENTIALITY,WORK_HOURS | البعد
VALUE_ID        ID               | معرف القيمة
VALUE_CODE      V100             | رمز القيمة
''', ix=[('TENANT_ID', 'DELEGATION_ID')], area='delegation', purpose='أقل نطاق لازم؛ لا تفويض شامل غير محدد')

table('DLG_LIMIT', 'حدود التفويض المالية', 'Delegation Limits', scope='T', cols='''
DELEGATION_ID   ID   NN >DLG_DELEGATION | التفويض
CURRENCY_CODE   CUR  NN          | العملة
MAX_PER_TRANSACTION AMT          | الحد للمعاملة الواحدة
MAX_CUMULATIVE  AMT              | الحد التراكمي
USED_CUMULATIVE AMT  NN D=0 @SYS | المستخدم تراكمياً
''', area='delegation', purpose='يطبق أقل حد بين سلطة المانح والتفويض والمنصب وCountry Pack وSoD')

table('DLG_EXERCISE_EVENT', 'التصرفات المنفذة بالتفويض', 'Delegation Exercise Events', scope='T', append=True, cols='''
DELEGATION_ID   ID   NN >DLG_DELEGATION | سند التفويض
ACTOR_MEMBER_ID ID   NN >SEC_USER_MEMBERSHIP | المنفذ الفعلي
AUTHORITY_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | صاحب السلطة الأصلي
ACTION_CODE     V40  NN          | الإجراء
ENTITY_TYPE     V50  >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | الكائن
ENTITY_ID       ID               | المعرف
TASK_ID         ID   >WF_TASK    | المهمة
AMOUNT          AMT              | المبلغ
CURRENCY_CODE   CUR              | العملة
FX_RATE_USED    RATE             | سعر التحويل لمقارنة السقف
POLICY_SNAPSHOT JSON             | لقطة السند والسياسة والحدود وقت القرار
RESULT_CODE     CODE NN IN:EXECUTED,REJECTED_OUT_OF_SCOPE,REJECTED_LIMIT,REJECTED_SOD | النتيجة
CORRELATION_ID  V64              | معرف الارتباط
''', ix=[('TENANT_ID', 'DELEGATION_ID')], area='delegation')

table('DLG_REVIEW', 'المراجعة اللاحقة للتفويض', 'Delegation Reviews', scope='T', mix='status', status='OPEN IN_REVIEW CONFIRMED CORRECTIVE_ACTION CLOSED', cols='''
DELEGATION_ID   ID   NN >DLG_DELEGATION | التفويض
REVIEW_TYPE     CODE NN IN:EMERGENCY_POST_REVIEW,PERIODIC,MISUSE_SUSPICION,RENEWAL | النوع
REVIEWER_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المراجع
DUE_DATE        DATE             | المهلة
FINDINGS        V4000            | النتائج
''', area='delegation')
