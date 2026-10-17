from model.dsl import module, table

module(2, 'SEC', 'الهيكل التنظيمي والهوية والأمن', 'Organization Structure, Identity & Security',
       'NOONA_SECURITY_PKG',
       'الشجرة التنظيمية غير محدودة المستويات والوظائف والمناصب والتعيينات واللجان، ثم الهوية والعضوية '
       'والجلسات والأدوار والصلاحيات الذرية RESOURCE.ACTION ونطاق البيانات وفصل المهام والوصول المؤقت. '
       'القرار: Explicit Deny → Classification → SoD → Context → Allow → Default Deny.')

# =============================================================== Organization structure
table('ORG_STRUCTURE', 'الهياكل التنظيمية', 'Organizational Structures', scope='C', mix='code names active', cols='''
STRUCTURE_TYPE  CODE NN IN:ADMINISTRATIVE,FINANCIAL,OPERATIONAL,PROJECT,CORRESPONDENCE,REPORTING,MATRIX | نوع الهيكل
IS_PRIMARY      YN   NN D='N'    | الهيكل الإداري الأساسي (واحد فعال لكل شركة)
''', area='org')

table('ORG_STRUCTURE_VERSION', 'إصدارات الهيكل التنظيمي', 'Structure Versions', scope='C', mix='eff status wf',
      status='DRAFT UNDER_REVIEW APPROVED SCHEDULED ACTIVE SUPERSEDED ARCHIVED', cols='''
STRUCTURE_ID    ID   NN >ORG_STRUCTURE | الهيكل
VERSION_NO      INT  NN          | رقم الإصدار
CHANGE_REASON   V1000            | سبب إعادة الهيكلة
''', uk=[('STRUCTURE_ID', 'VERSION_NO')], area='org', purpose='يمكن إعداد الهيكل المستقبلي واختباره قبل تفعيله ولا يمحى السابق')

table('ORG_UNIT', 'الوحدات التنظيمية', 'Organizational Units', scope='C', mix='code names eff status conf', codeuk=False,
      status='DRAFT ACTIVE FROZEN MERGED CLOSED', cols='''
STRUCTURE_VERSION_ID ID NN >ORG_STRUCTURE_VERSION | إصدار الهيكل
PARENT_UNIT_ID  ID   >ORG_UNIT   | الوحدة الأم (شجرة غير محدودة؛ يمنع Self-Parent والدورات)
UNIT_TYPE       CODE NN          | النوع من Lookup (Sector، Directorate، Department، Section، Unit، Office، Team...)
BRANCH_ID       ID   >ORG_BRANCH  | الفرع عند الحاجة
SITE_ID         ID   >ORG_BUSINESS_SITE | الموقع
HEAD_POSITION_ID ID  >ORG_POSITION | منصب رئيس الوحدة (لا يخزن اسم موظف)
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة الافتراضي (الوحدة ليست مركز تكلفة)
HIER_PATH       V4000 @SYS       | المسار الكامل المحسوب للأداء
HIER_LEVEL      INT  @SYS        | المستوى في الشجرة
RECEIVES_CORRESPONDENCE YN NN D='Y' | تستقبل مراسلات
HAS_BUDGET      YN   NN D='N'    | تملك موازنة
CHANGE_REASON   V1000            | سبب آخر تغيير
''', uk=[('TENANT_ID', 'STRUCTURE_VERSION_ID', 'CODE')], chk=['PARENT_UNIT_ID IS NULL OR PARENT_UNIT_ID <> ID'],
      ix=[('TENANT_ID', 'PARENT_UNIT_ID')], area='org')

table('ORG_JOB_FAMILY', 'العائلات الوظيفية', 'Job Families', scope='T', mix='code names active', cols='''
PARENT_FAMILY_ID ID  >ORG_JOB_FAMILY | العائلة الأم
''', area='org')

table('ORG_GRADE', 'الدرجات الوظيفية', 'Grades', scope='T', mix='code names eff active sort', cols='''
GRADE_LEVEL     INT              | المستوى
MIN_SALARY      AMT              | الحد الأدنى للراتب
MID_SALARY      AMT              | منتصف السلم
MAX_SALARY      AMT              | الحد الأعلى
CURRENCY_CODE   CUR              | العملة
''', area='org', sens='CONFIDENTIAL')

table('ORG_JOB', 'الدليل الوظيفي', 'Job Catalog', scope='T', mix='code names desc eff status', status='DRAFT ACTIVE RETIRED', cols='''
JOB_FAMILY_ID   ID   >ORG_JOB_FAMILY | العائلة الوظيفية
JOB_LEVEL       CODE             | المستوى (Junior، Senior، Lead، Manager...)
GRADE_ID        ID   >ORG_GRADE  | الدرجة المرجعية
COMPANY_ID      ID   >ORG_COMPANY | تخصيص لشركة (فارغ = كل المؤسسة)
QUALIFICATIONS  V4000            | المؤهلات والخبرة
RESPONSIBILITIES CLOB            | المهام والمسؤوليات
IS_CRITICAL     YN   NN D='N'    | وظيفة حرجة (تخطيط التعاقب)
''', area='org', purpose='JOB تعريف عام لا يرتبط بموظف بعينه')

table('ORG_POSITION', 'المناصب', 'Positions', scope='C', mix='code names eff status',
      status='PLANNED APPROVED VACANT OCCUPIED FROZEN TEMPORARILY_FILLED CANCELLED CLOSED', cols='''
ORG_UNIT_ID     ID   NN >ORG_UNIT | الوحدة
JOB_ID          ID   NN >ORG_JOB | الوظيفة
GRADE_ID        ID   >ORG_GRADE  | الدرجة
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
SITE_ID         ID   >ORG_BUSINESS_SITE | الموقع
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
REPORTS_TO_POSITION_ID ID >ORG_POSITION | المنصب الأعلى (خط الإدارة)
CAPACITY_FTE    NUM  NN D=1      | السعة FTE
IS_HEAD         YN   NN D='N'    | منصب رئاسة الوحدة
BUDGETED_COST   AMT              | التكلفة المعتمدة في الموازنة
''', ix=[('TENANT_ID', 'ORG_UNIT_ID')], area='org', purpose='POSITION مقعد معتمد داخل وحدة (13.1)')

table('ORG_POSITION_ASSIGNMENT', 'تعيينات المناصب', 'Position Assignments', scope='T', mix='eff status',
      status='DRAFT UNDER_REVIEW APPROVED SCHEDULED EFFECTIVE COMPLETED CANCELLED', cols='''
EMPLOYMENT_ID   ID   NN >HR_EMPLOYMENT | علاقة التوظيف
POSITION_ID     ID   NN >ORG_POSITION | المنصب
ASSIGNMENT_TYPE CODE NN IN:PRIMARY,ADDITIONAL,ACTING,SECONDMENT,TEMPORARY | نوع التكليف
FTE_PCT         PCT  NN D=100    | نسبة الوقت
IS_PERMANENT    YN   NN D='Y'    | دائم
SALARY_SOURCE   CODE IN:THIS_POSITION,PRIMARY_POSITION,NONE | مصدر الراتب
REASON          V1000            | السبب
DECISION_REF    V100             | رقم القرار
APPROVED_BY     USR              | المعتمد
''', ix=[('TENANT_ID', 'POSITION_ID', 'EFFECTIVE_FROM')], area='org',
      purpose='Person → Employment → Position Assignment → Position → Unit (13.3)')

table('ORG_COMMITTEE', 'اللجان والمجالس وفرق العمل', 'Committees & Councils', scope='T', mix='code names eff status conf',
      status='DRAFT UNDER_REVIEW APPROVED ACTIVE SUSPENDED EXPIRED DISSOLVED ARCHIVED', cols='''
COMMITTEE_TYPE  CODE NN IN:BOARD,COUNCIL,STANDING,TEMPORARY,PROJECT_TEAM,INVENTORY,TENDER,RECEIVING,INVESTIGATION,OTHER | النوع
OWNER_COMPANY_ID ID  >ORG_COMPANY | الشركة المالكة
DECISION_REF    V100             | قرار التشكيل
QUORUM_RULE     JSON             | قاعدة النصاب والتصويت
MANDATE         V4000            | الصلاحيات والنطاق
''', area='org')

table('ORG_COMMITTEE_MEMBER', 'أعضاء اللجان', 'Committee Members', scope='T', mix='eff', cols='''
COMMITTEE_ID    ID   NN >ORG_COMMITTEE | اللجنة
EMPLOYEE_ID     ID   >HR_EMPLOYEE | الموظف
POSITION_ID     ID   >ORG_POSITION | المنصب (عضوية بالصفة)
EXTERNAL_PARTY_ID ID >PTY_PARTY  | عضو خارجي
MEMBER_ROLE     CODE NN IN:CHAIR,VICE_CHAIR,MEMBER,SECRETARY,ALTERNATE,OBSERVER | الدور
ALTERNATE_FOR_ID ID  >ORG_COMMITTEE_MEMBER | بديل عن عضو
HAS_VOTE        YN   NN D='Y'    | له حق التصويت
COI_STATUS      CODE IN:NO_CONFLICT,DISCLOSED,RECUSED,EXCLUDED,REVIEW_REQUIRED | تعارض المصالح
''', chk=['EMPLOYEE_ID IS NOT NULL OR POSITION_ID IS NOT NULL OR EXTERNAL_PARTY_ID IS NOT NULL'], area='org')

table('ORG_DYNAMIC_GROUP', 'المجموعات الديناميكية', 'Dynamic Groups', scope='T', mix='code names status', status='DRAFT PUBLISHED RETIRED', cols='''
RULE_DEFINITION JSON NN          | قاعدة الحل المعتمدة (ليست SQL حراً)
VERSION_NO      INT  NN D=1      | الإصدار
MAX_MEMBERS     INT              | الحد الأقصى للجمهور
''', area='org', purpose='مثل «جميع مديري الفروع»؛ تحل من قاعدة منشورة ومعتمدة')

table('ORG_RESTRUCTURE', 'طلبات إعادة الهيكلة', 'Restructuring Requests', scope='C', mix='wf status',
      status='DRAFT IMPACT_ANALYSIS APPROVED SCHEDULED EXECUTED VALIDATED COMPLETED CANCELLED', cols='''
REQUEST_NO      V50  NN          | رقم الطلب
FROM_VERSION_ID ID   >ORG_STRUCTURE_VERSION | الإصدار الحالي
TO_VERSION_ID   ID   >ORG_STRUCTURE_VERSION | الإصدار المستهدف
EFFECTIVE_DATE  DATE             | تاريخ السريان
IMPACT_ANALYSIS JSON             | أثر على الموظفين والمناصب والتفويضات والصلاحيات وWorkflow...
''', uk=[('TENANT_ID', 'REQUEST_NO')], area='org')

# =============================================================== Identity & accounts
table('SEC_USER', 'حسابات المستخدمين', 'User Accounts', scope='G', mix='pub status',
      status='REQUESTED UNDER_REVIEW APPROVED PROVISIONED INVITED ACTIVE LOCKED PASSWORD_EXPIRED PENDING_MFA DORMANT COMPROMISED SUSPENDED DISABLED CLOSED', cols='''
USERNAME        V128 NN U        | اسم الدخول الحالي (مستقل عن USER_ID الثابت)
EMAIL           V320 NN PII      | البريد الإلكتروني
MOBILE          V40  PII         | الجوال (ليس معرفاً ثابتاً)
DISPLAY_NAME    NAME NN          | الاسم المعروض
USER_TYPE       CODE NN IN:EMPLOYEE,TENANT_ADMIN,EXTERNAL,CUSTOMER,SUPPLIER,CONTRACTOR,CONSULTANT,AUDITOR,REGULATOR,SERVICE,INTEGRATION,SUPPORT,BREAK_GLASS,PLATFORM_ADMIN | نوع الحساب
AUTH_PROVIDER_ID ID  >SEC_AUTH_PROVIDER | مزود المصادقة الافتراضي
EXTERNAL_SUBJECT V256            | المعرف لدى مزود الهوية (SSO)
PREFERRED_LANGUAGE LANG NN D='ar' | اللغة
TIMEZONE_CODE   V64              | المنطقة الزمنية
MFA_REQUIRED    YN   NN D='N'    | MFA إلزامي
RISK_LEVEL      CODE NN D='NORMAL' IN:LOW,NORMAL,HIGH,CRITICAL | مستوى المخاطر
SPONSOR_USER_ID ID   >SEC_USER   | الراعي (إلزامي للحسابات الخارجية)
EXPIRES_AT      TS               | تاريخ الانتهاء (إلزامي للمؤقت والخارجي)
LAST_LOGIN_AT   TS   @SYS        | آخر دخول
FAILED_LOGINS   INT  NN D=0 @SYS | محاولات الدخول الفاشلة المتتالية
LOCKED_UNTIL    TS   @SYS        | مقفل حتى
''', ix=[('EMAIL',)], area='identity', sens='CONFIDENTIAL',
      purpose='USER_ID معرف داخلي ثابت؛ ليس كل موظف مستخدماً ولا كل مستخدم موظفاً (14.1)')

table('SEC_LOGIN_NAME_HIST', 'سجل أسماء الدخول', 'Login Name History', scope='G', append=True, cols='''
USER_ID         ID   NN >SEC_USER | المستخدم
OLD_USERNAME    V128 NN          | الاسم السابق
NEW_USERNAME    V128 NN          | الاسم الجديد
REASON          V500             | السبب
''', area='identity')

table('SEC_AUTH_PROVIDER', 'مزودو المصادقة', 'Authentication Providers', scope='TO', mix='code names status', status='ACTIVE DISABLED', cols='''
PROVIDER_TYPE   CODE NN IN:APEX_ACCOUNTS,LOCAL_DB,ENTRA_ID,LDAP,SAML,OIDC,OAUTH2,PASSKEY,CERTIFICATE | النوع
CONFIG_INFO     JSON             | الإعدادات غير السرية
SECRET_REF      V200             | مرجع الأسرار في Vault
ENFORCE_MFA     YN   NN D='N'    | فرض MFA
''', area='identity')

table('SEC_CREDENTIAL', 'بيانات الاعتماد المحلية', 'Local Credentials', scope='G', mix='status', status='ACTIVE EXPIRED REVOKED', cols='''
USER_ID         ID   NN >SEC_USER | المستخدم
CREDENTIAL_TYPE CODE NN D='PASSWORD' IN:PASSWORD,RECOVERY_CODE | النوع
SECRET_HASH     V512 NN          | Hash آمن فقط (لا نص صريح ولا تشفير قابل للعكس)
HASH_ALGORITHM  V30  NN          | الخوارزمية (PBKDF2/Argon2...)
SALT            V128             | الملح
EXPIRES_AT      TS               | الانتهاء
LAST_CHANGED_AT TS               | آخر تغيير
''', area='identity', sens='HIGHLY_RESTRICTED')

table('SEC_MFA_FACTOR', 'عوامل التحقق المتعدد', 'MFA Factors', scope='G', mix='status', status='PENDING ACTIVE DISABLED REVOKED', cols='''
USER_ID         ID   NN >SEC_USER | المستخدم
FACTOR_TYPE     CODE NN IN:TOTP,PASSKEY,SECURITY_KEY,PUSH,SMS,EMAIL_OTP,RECOVERY_CODES,CERTIFICATE | النوع
FACTOR_LABEL    V100             | الوصف (جهاز...)
SECRET_REF      V200             | مرجع السر في Vault
CREDENTIAL_ID   V512             | معرف Passkey/WebAuthn
LAST_USED_AT    TS               | آخر استخدام
''', area='identity', sens='HIGHLY_RESTRICTED')

table('SEC_DEVICE', 'الأجهزة الموثوقة', 'Trusted Devices', scope='G', mix='status', status='TRUSTED UNTRUSTED BLOCKED EXPIRED', cols='''
USER_ID         ID   NN >SEC_USER | المستخدم
DEVICE_FINGERPRINT HASH NN       | بصمة الجهاز
DEVICE_TYPE     CODE             | النوع
OS_INFO         V200             | النظام
LAST_USED_AT    TS               | آخر استخدام
TRUST_EXPIRES_AT TS              | انتهاء الثقة
''', uk=[('USER_ID', 'DEVICE_FINGERPRINT')], area='identity')

table('SEC_USER_MEMBERSHIP', 'عضوية المستخدمين في المؤسسات', 'User Tenant Memberships', scope='T', mix='eff status',
      status='INVITED ACTIVE SUSPENDED ENDED', cols='''
USER_ID         ID   NN >SEC_USER | المستخدم
PERSON_PARTY_ID ID   >PTY_PARTY  | الشخص
EMPLOYEE_ID     ID   >HR_EMPLOYEE | الموظف (اختياري)
DEFAULT_COMPANY_ID ID >ORG_COMPANY | الشركة الافتراضية
DEFAULT_BRANCH_ID ID >ORG_BRANCH  | الفرع الافتراضي
CLEARANCE_LEVEL CODE NN D='INTERNAL' IN:PUBLIC,INTERNAL,CONFIDENTIAL,SECRET,HIGHLY_RESTRICTED | مستوى التصريح الأمني
IS_TENANT_ADMIN YN   NN D='N'    | مسؤول المؤسسة
SECURITY_VERSION INT NN D=1 @SYS | إصدار أمني لإبطال Cache الصلاحيات فوراً
''', uk=[('TENANT_ID', 'USER_ID')], area='identity',
      purpose='USER → USER_TENANT_MEMBERSHIP → TENANT؛ كل جلسة تعمل في سياق Tenant واحد (10.3)')

table('SEC_SESSION', 'جلسات المستخدمين', 'User Sessions', scope='TO', mix='status', status='ACTIVE ENDED EXPIRED TERMINATED', cols='''
USER_ID         ID   NN >SEC_USER | المستخدم
MEMBERSHIP_ID   ID   >SEC_USER_MEMBERSHIP | العضوية النشطة
APEX_SESSION_ID NUM              | جلسة APEX
COMPANY_ID      ID   >ORG_COMPANY | الشركة النشطة
BRANCH_ID       ID   >ORG_BRANCH  | الفرع النشط
LANGUAGE_CODE   LANG             | اللغة
AUTH_METHOD     CODE             | طريقة المصادقة
MFA_LEVEL       CODE             | مستوى MFA المحقق
IP_ADDRESS      V45              | عنوان IP
USER_AGENT      V500             | المتصفح
DEVICE_ID       ID   >SEC_DEVICE | الجهاز
STARTED_AT      TS   NN D=SYSTIMESTAMP | البداية
LAST_ACTIVITY_AT TS              | آخر نشاط
ENDED_AT        TS               | النهاية
END_REASON      CODE             | سبب الإنهاء
''', ix=[('USER_ID', 'STARTED_AT'), ('APEX_SESSION_ID',)], area='identity')

table('SEC_LOGIN_ATTEMPT', 'محاولات الدخول', 'Login Attempts', scope='G', append=True, cols='''
USERNAME_TRIED  V128 NN          | الاسم المستخدم في المحاولة
USER_ID         ID   >SEC_USER   | المستخدم إن وجد
TENANT_HINT     V63              | Tenant المرشح من النطاق
RESULT_CODE     CODE NN IN:SUCCESS,FAILED,LOCKED,MFA_REQUIRED,MFA_FAILED,DENIED | النتيجة
ADAPTIVE_DECISION CODE IN:ALLOW,STEP_UP_MFA,LIMIT_SESSION,DENY,REQUIRE_REVIEW | قرار المصادقة التكيفية
IP_ADDRESS      V45              | IP
USER_AGENT      V500             | المتصفح
''', ix=[('USER_ID', 'CREATED_AT'), ('IP_ADDRESS', 'CREATED_AT')], area='identity', ret='سنة على الأقل')

# =============================================================== Authorization
table('SEC_PERMISSION', 'الصلاحيات الذرية', 'Permissions', scope='G', mix='names active', cols='''
PERMISSION_CODE V100 NN U        | RESOURCE.ACTION مثل SALES_INVOICE.APPROVE
MODULE_CODE     CODE NN          | الحزمة
RESOURCE_CODE   V60  NN          | المورد
ACTION_CODE     V40  NN          | الإجراء (VIEW، CREATE، UPDATE، DELETE، SUBMIT، APPROVE، POST، REVERSE، CANCEL، PRINT، EXPORT، ARCHIVE، CONFIGURE...)
RISK_LEVEL      CODE NN D='NORMAL' IN:LOW,NORMAL,HIGH,CRITICAL | الخطورة
REQUIRES_MFA    YN   NN D='N'    | يتطلب إعادة تحقق
IS_DELEGABLE    YN   NN D='Y'    | قابل للتفويض
''', area='authz', purpose='لا تستخدم FULL_ACCESS في التشغيل اليومي (14.2)')

table('SEC_ROLE', 'الأدوار', 'Roles', scope='TO', mix='code names desc status', status='DRAFT ACTIVE RETIRED', cols='''
ROLE_TYPE       CODE NN IN:PLATFORM,TENANT,COMPANY,BRANCH,FUNCTIONAL,JOB,POSITION,PROJECT,COMMITTEE,TEMPORARY,EXTERNAL,SUPPORT,EMERGENCY | نوع الدور
IS_TEMPLATE     YN   NN D='N'    | قالب قياسي من NOONA
SOURCE_TEMPLATE_ID ID >SEC_ROLE  | القالب المنسوخ منه (لا تنتشر تحديثاته تلقائياً)
IS_PRIVILEGED   YN   NN D='N'    | دور مميز يتطلب MFA وتدقيقاً موسعاً
''', area='authz')

table('SEC_ROLE_PERMISSION', 'صلاحيات الأدوار', 'Role Permissions', scope='TO', cols='''
ROLE_ID         ID   NN >SEC_ROLE | الدور
PERMISSION_ID   ID   NN >SEC_PERMISSION | الصلاحية
EFFECT          CODE NN D='ALLOW' IN:ALLOW,DENY | الأثر (Explicit Deny يتقدم)
CONDITION_INFO  JSON             | شروط ABAC إضافية (المبلغ، الحالة...)
''', uk=[('ROLE_ID', 'PERMISSION_ID')], area='authz')

table('SEC_ROLE_COMPOSITE', 'الأدوار المركبة', 'Composite Roles', scope='TO', cols='''
PARENT_ROLE_ID  ID   NN >SEC_ROLE | الدور المركب
CHILD_ROLE_ID   ID   NN >SEC_ROLE | الدور المتضمن
''', uk=[('PARENT_ROLE_ID', 'CHILD_ROLE_ID')], chk=['PARENT_ROLE_ID <> CHILD_ROLE_ID'], area='authz')

table('SEC_ROLE_GRANT', 'منح الأدوار', 'Role Grants', scope='T', mix='eff status',
      status='REQUESTED APPROVED ACTIVE EXPIRED REVOKED REJECTED', cols='''
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | العضوية
ROLE_ID         ID   NN >SEC_ROLE | الدور
GRANT_SOURCE    CODE NN IN:POSITION,JOB,ORG_UNIT,ASSIGNMENT,PROJECT,COMMITTEE,MANUAL,DELEGATION,EMERGENCY,ACCESS_REQUEST | مصدر المنح
SOURCE_ID       ID               | معرف المصدر (منصب، مشروع...)
REASON          V1000            | السبب
REQUESTED_BY    USR              | الطالب
APPROVED_BY     USR              | المعتمد
LAST_USED_AT    TS   @SYS        | آخر استخدام
NEXT_REVIEW_DATE DATE            | المراجعة الدورية التالية
''', ix=[('TENANT_ID', 'MEMBERSHIP_ID'), ('TENANT_ID', 'ROLE_ID')], area='authz',
      purpose='يحفظ المصدر والنطاق والسريان والسبب؛ يدعم شاشتي Why/What can this user access')

table('SEC_DATA_SCOPE', 'نطاقات البيانات', 'Data Scopes', scope='T', cols='''
ROLE_GRANT_ID   ID   NN >SEC_ROLE_GRANT | المنح
SCOPE_TYPE      CODE NN IN:OWN,ASSIGNED,ORG_UNIT,ORG_UNIT_TREE,BRANCH,COMPANY,BUSINESS_GROUP,PROJECT,PROPERTY,WAREHOUSE,COST_CENTER,CUSTOMER_PORTFOLIO,SUPPLIER_PORTFOLIO,REGION,ALL_TENANT | نوع النطاق
COMPANY_ID      ID   >ORG_COMPANY | الشركة
SCOPE_VALUE_ID  ID               | معرف القيمة (فرع، وحدة، مشروع...)
''', ix=[('TENANT_ID', 'ROLE_GRANT_ID')], area='authz',
      purpose='المستخدم قد يملك نطاقات مختلفة في كل شركة وفرع ومشروع')

table('SEC_FIELD_POLICY', 'سياسات حماية الحقول', 'Field Protection Policies', scope='TO', mix='active', cols='''
TABLE_NAME      V128 NN          | الجدول
COLUMN_NAME     V128 NN          | العمود
ROLE_ID         ID   >SEC_ROLE   | الدور (فارغ = الافتراضي)
PROTECTION      CODE NN IN:VISIBLE,MASKED,REDACTED,HIDDEN,READ_ONLY | مستوى الحماية
MASK_PATTERN    V100             | نمط الإخفاء
''', uk=[('TENANT_ID', 'TABLE_NAME', 'COLUMN_NAME', 'ROLE_ID')], area='authz')

table('SEC_SOD_RULE', 'قواعد فصل المهام', 'Segregation of Duties Rules', scope='TO', mix='code names active', cols='''
PERMISSION_A_ID ID   NN >SEC_PERMISSION | الصلاحية الأولى
PERMISSION_B_ID ID   NN >SEC_PERMISSION | الصلاحية المتعارضة
SEVERITY        CODE NN IN:PROHIBITED,HIGH_RISK,REVIEW_REQUIRED,MONITORED | الخطورة
SAME_RECORD_ONLY YN  NN D='Y'    | التعارض على نفس السجل فقط (مثل إنشاء واعتماد نفس الفاتورة)
''', chk=['PERMISSION_A_ID <> PERMISSION_B_ID'], area='authz')

table('SEC_SOD_VIOLATION', 'مخالفات فصل المهام', 'SoD Violations', scope='T', mix='status', status='DETECTED UNDER_REVIEW ACCEPTED MITIGATED RESOLVED', cols='''
SOD_RULE_ID     ID   NN >SEC_SOD_RULE | القاعدة
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستخدم
ENTITY_TYPE     V50  >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | السجل المعني
ENTITY_ID       ID               | المعرف
DETECTED_AT     TS   NN D=SYSTIMESTAMP | وقت الاكتشاف
EXCEPTION_ID    ID   >WF_EXCEPTION | الاستثناء المعتمد
''', area='authz')

table('SEC_ACCESS_REQUEST', 'طلبات الوصول المؤقت', 'Access Requests', scope='T', mix='wf status',
      status='DRAFT SUBMITTED UNDER_REVIEW APPROVED PROVISIONED REJECTED EXPIRED CANCELLED', cols='''
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستفيد
ROLE_ID         ID   NN >SEC_ROLE | الدور المطلوب
SCOPE_INFO      JSON             | النطاق المطلوب
REASON          V1000 NN         | السبب
REQUESTED_FROM  TS   NN          | من
REQUESTED_TO    TS   NN          | إلى (انتهاء تلقائي)
ROLE_GRANT_ID   ID   >SEC_ROLE_GRANT | المنح الناتج
''', chk=['REQUESTED_TO > REQUESTED_FROM'], area='authz')

table('SEC_ACCESS_REVIEW', 'حملات مراجعة الصلاحيات', 'Access Certification Campaigns', scope='T', mix='code names status',
      status='PLANNED IN_PROGRESS COMPLETED CANCELLED', cols='''
REVIEW_TYPE     CODE NN IN:PERIODIC,SENSITIVE,TRANSFER,MANAGER_CHANGE,PROJECT_END,SERVICE_ACCOUNT | النوع
DUE_DATE        DATE NN          | الموعد
''', area='authz')

table('SEC_ACCESS_REVIEW_ITEM', 'بنود مراجعة الصلاحيات', 'Access Review Items', scope='T', mix='status',
      status='PENDING CONFIRMED REDUCED REVOKED EXPLANATION_REQUESTED EXTENDED', cols='''
ACCESS_REVIEW_ID ID  NN >SEC_ACCESS_REVIEW | الحملة
ROLE_GRANT_ID   ID   NN >SEC_ROLE_GRANT | المنح
REVIEWER_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | المراجع
DECISION_AT     TS               | وقت القرار
COMMENTS        V1000            | ملاحظات
''', area='authz')

table('SEC_BREAK_GLASS', 'وصول الطوارئ', 'Break-Glass Access', scope='T', mix='status', status='REQUESTED ACTIVE ENDED REVIEWED', cols='''
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستخدم
REASON          V1000 NN         | المبرر
INCIDENT_REF    V100             | الحادث المرتبط
STARTS_AT       TS   NN          | البداية
ENDS_AT         TS   NN          | النهاية
REVIEWED_BY     USR              | المراجع اللاحق
REVIEW_RESULT   V1000            | نتيجة المراجعة
''', area='authz', sens='CONFIDENTIAL', purpose='محدود ومبرر ومدقق مع تنبيه فوري (6.10.10)')

# =============================================================== Security governance & privacy
table('SEC_RISK', 'سجل المخاطر الأمنية', 'Security Risk Register', scope='TO', mix='code status',
      status='IDENTIFIED ASSESSED TREATMENT_PLANNED IN_PROGRESS MITIGATED ACCEPTED CLOSED', cols='''
TITLE           V500 NN          | العنوان
LIKELIHOOD      INT              | الاحتمال (1-5)
IMPACT          INT              | الأثر (1-5)
OWNER_USER      USR              | المالك
TREATMENT_PLAN  V4000            | خطة المعالجة
REVIEW_DATE     DATE             | المراجعة التالية
''', area='governance')

table('SEC_INCIDENT', 'الحوادث الأمنية', 'Security Incidents', scope='TO', mix='status conf',
      status='NEW TRIAGED INVESTIGATING CONTAINED RESOLVED CLOSED', cols='''
INCIDENT_NO     V50  NN          | رقم الحادث
SEVERITY        CODE NN IN:SEV1,SEV2,SEV3,SEV4 | الخطورة
CATEGORY        CODE NN          | التصنيف
DETECTED_AT     TS   NN          | وقت الاكتشاف
SUMMARY         V4000 NN         | الملخص
CONTAINMENT     V4000            | إجراءات الاحتواء
ROOT_CAUSE      V4000            | السبب الجذري
NOTIFICATION_REQUIRED YN NN D='N' | يتطلب إخطاراً قانونياً/تعاقدياً
''', uk=[('TENANT_ID', 'INCIDENT_NO')], area='governance')

table('SEC_DATA_SUBJECT_REQUEST', 'طلبات أصحاب البيانات', 'Data Subject Requests', scope='T', mix='status',
      status='REQUESTED IDENTITY_VERIFIED UNDER_REVIEW APPROVED REJECTED EXECUTED CLOSED', cols='''
REQUEST_NO      V50  NN          | رقم الطلب
PARTY_ID        ID   >PTY_PARTY  | صاحب البيانات
REQUEST_TYPE    CODE NN IN:ACCESS,CORRECTION,DELETION,RESTRICTION,PORTABILITY,OBJECTION | النوع
DUE_DATE        DATE             | المهلة النظامية
DECISION_REASON V1000            | سبب القرار
''', uk=[('TENANT_ID', 'REQUEST_NO')], area='governance', sens='CONFIDENTIAL')
