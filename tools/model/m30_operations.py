from model.dsl import module, table

module(30, 'OPS', 'التشغيل والدعم والتطوير المستمر', 'Operations, Support & Continuous Improvement', 'NOONA_OPERATIONS_PKG',
       'الحوادث التشغيلية SEV-1..4 وخطها الزمني، ونوافذ الصيانة، وتذاكر الدعم، والمهام الخلفية بطوابير '
       'Interactive/Background/Critical لكل Tenant، والنسخ الاحتياطي واختبارات الاستعادة، وسجل القرارات '
       'وطلبات التغيير (Change Control).')

table('OPS_INCIDENT', 'الحوادث التشغيلية', 'Operational Incidents', scope='G', mix='status', status='OPEN INVESTIGATING MITIGATED RESOLVED POSTMORTEM CLOSED', cols='''
INCIDENT_NO     V50  NN U        | الرقم
SEVERITY        CODE NN IN:SEV1,SEV2,SEV3,SEV4 | الخطورة
TITLE           V500 NN          | العنوان
CELL_ID         ID   >PLT_CELL   | الخلية المتأثرة
AFFECTED_TENANTS INT             | عدد المؤسسات المتأثرة
STARTED_AT      TS   NN          | البداية
DETECTED_AT     TS               | الاكتشاف
RESOLVED_AT     TS               | الحل
ROOT_CAUSE      V4000            | السبب الجذري
CUSTOMER_SUMMARY V4000           | ملخص العميل (منفصل عن التقرير الفني)
''', area='incident')

table('OPS_INCIDENT_EVENT', 'الخط الزمني للحادث', 'Incident Timeline', scope='G', append=True, cols='''
INCIDENT_ID     ID   NN >OPS_INCIDENT | الحادث
EVENT_AT        TS   NN          | الوقت
EVENT_TEXT      V4000 NN         | الحدث/الإجراء
AUTHOR          USR              | الكاتب
''', area='incident')

table('OPS_INCIDENT_TENANT', 'المؤسسات المتأثرة بالحادث', 'Incident Affected Tenants', scope='T', cols='''
INCIDENT_ID     ID   NN >OPS_INCIDENT | الحادث
IMPACT_LEVEL    CODE NN IN:FULL_OUTAGE,DEGRADED,DATA_RISK,NONE | الأثر
NOTIFIED_AT     TS               | وقت الإخطار
''', uk=[('INCIDENT_ID', 'TENANT_ID')], area='incident')

table('OPS_MAINTENANCE_WINDOW', 'نوافذ الصيانة', 'Maintenance Windows', scope='G', mix='status', status='SCHEDULED NOTIFIED IN_PROGRESS COMPLETED CANCELLED', cols='''
CELL_ID         ID   >PLT_CELL   | الخلية
REGION_ID       ID   >PLT_REGION | المنطقة
STARTS_AT       TS   NN          | البداية
ENDS_AT         TS   NN          | النهاية
IS_EMERGENCY    YN   NN D='N'    | طارئة
DESCRIPTION     V2000            | الوصف
''', chk=['ENDS_AT > STARTS_AT'], area='maintenance')

table('OPS_SUPPORT_TICKET', 'تذاكر الدعم', 'Support Tickets', scope='T', mix='pub status', status='NEW OPEN WAITING_CUSTOMER IN_PROGRESS ESCALATED RESOLVED CLOSED', cols='''
TICKET_NO       V50  NN          | الرقم
REQUESTER_MEMBER_ID ID >SEC_USER_MEMBERSHIP | الطالب
CATEGORY        CODE NN          | الفئة
PRIORITY_CODE   CODE NN D='NORMAL' IN:LOW,NORMAL,HIGH,URGENT | الأولوية
SUBJECT         V500 NN          | الموضوع
DESCRIPTION     V4000            | الوصف
ASSIGNED_TO     USR              | مسؤول الدعم
SUPPORT_ACCESS_ID ID >PLT_SUPPORT_ACCESS | وصول الدعم الممنوح
SLA_DUE_AT      TS               | موعد SLA
RESOLVED_AT     TS               | وقت الحل
''', uk=[('TENANT_ID', 'TICKET_NO')], area='support')

table('OPS_TICKET_COMMENT', 'تعليقات التذاكر', 'Ticket Comments', scope='T', append=True, cols='''
TICKET_ID       ID   NN >OPS_SUPPORT_TICKET | التذكرة
IS_INTERNAL     YN   NN D='N'    | داخلي لفريق الدعم
COMMENT_TEXT    V4000 NN         | النص
''', area='support')

table('OPS_JOB_DEFINITION', 'تعريفات المهام الخلفية', 'Background Job Definitions', scope='G', mix='code names active', cols='''
QUEUE_CLASS     CODE NN IN:INTERACTIVE,BACKGROUND,CRITICAL | فئة الطابور
HANDLER_API     V128 NN          | الإجراء المنفذ
MAX_CONCURRENT_PER_TENANT INT NN D=2 | الحد المتزامن لكل Tenant (منع Noisy Neighbor)
MAX_RUNTIME_MINUTES INT          | أقصى مدة
SCHEDULE_EXPR   V200             | الجدولة
''', area='jobs')

table('OPS_JOB_RUN', 'تشغيلات المهام الخلفية', 'Background Job Runs', scope='TO', mix='status', status='QUEUED RUNNING SUCCEEDED FAILED CANCELLED TIMED_OUT', cols='''
JOB_DEFINITION_ID ID NN >OPS_JOB_DEFINITION | التعريف
REQUESTED_BY_MEMBER_ID ID >SEC_USER_MEMBERSHIP | الطالب
PARAMETERS      JSON             | المعاملات
STARTED_AT      TS               | البداية
FINISHED_AT     TS               | النهاية
PROGRESS_PCT    PCT              | التقدم
RESULT_INFO     JSON             | النتيجة
ERROR_MESSAGE   V4000            | الخطأ
CORRELATION_ID  V64              | معرف الارتباط
''', ix=[('STATUS_CODE', 'CREATED_AT'), ('TENANT_ID', 'STATUS_CODE')], area='jobs')

table('OPS_BACKUP_RUN', 'عمليات النسخ الاحتياطي', 'Backup Runs', scope='G', append=True, cols='''
CELL_ID         ID   >PLT_CELL   | الخلية
BACKUP_TYPE     CODE NN IN:RMAN_FULL,RMAN_INCREMENTAL,ARCHIVELOG,DATAPUMP_TENANT,FILE_STORAGE,CONFIG | النوع
STARTED_AT      TS   NN          | البداية
FINISHED_AT     TS               | النهاية
RESULT_CODE     CODE NN IN:SUCCESS,FAILED,PARTIAL | النتيجة
SIZE_BYTES      NUM              | الحجم
LOCATION_REF    V500             | الموقع (خارجي)
''', area='backup')

table('OPS_RESTORE_TEST', 'اختبارات الاستعادة', 'Restore Tests', scope='TO', mix='status', status='PLANNED RUNNING PASSED FAILED', cols='''
TEST_TYPE       CODE NN IN:CELL_RESTORE,TENANT_RESTORE,DOCUMENT_RESTORE,PITR,DR_FAILOVER | النوع
BACKUP_RUN_ID   ID   >OPS_BACKUP_RUN | النسخة المختبرة
TARGET_RPO_MIN  INT              | RPO المستهدف
TARGET_RTO_MIN  INT              | RTO المستهدف
ACTUAL_DATA_LOSS_MIN INT         | الفقد الفعلي
ACTUAL_DURATION_MIN INT          | المدة الفعلية
FINDINGS        V4000            | الملاحظات والثغرات
''', area='backup', purpose='نجاح النسخ وحده لا يثبت القدرة على التعافي')

table('OPS_DECISION_LOG', 'سجل القرارات', 'Decision Log', scope='G', mix='code status', status='PROPOSED APPROVED SUPERSEDED REJECTED', cols='''
TITLE           V1000 NN         | القرار
RATIONALE       V4000            | المبرر
DECIDED_ON      DATE             | التاريخ
DECIDED_BY      V200             | صاحب القرار
SOURCE_REF      V200             | المرجع في الوثيقة
SUPERSEDED_BY_ID ID  >OPS_DECISION_LOG | القرار البديل
''', area='governance')

table('OPS_CHANGE_REQUEST', 'طلبات التغيير', 'Change Requests', scope='G', mix='code status', status='DRAFT SUBMITTED IMPACT_ANALYSIS APPROVED REJECTED IMPLEMENTED CLOSED', cols='''
TITLE           V1000 NN         | العنوان
CHANGE_TYPE     CODE NN IN:BASELINE,SCOPE,DESIGN,SCHEMA,SECURITY,COUNTRY_PACK,OPERATIONAL | النوع
DESCRIPTION     V4000            | الوصف
IMPACT_ANALYSIS V4000            | تحليل الأثر
DECISION_ID     ID   >OPS_DECISION_LOG | القرار المرتبط
RELEASE_ID      ID   >DEP_RELEASE | الإصدار المنفذ فيه
''', area='governance', purpose='أي تعديل في Baseline يمر عبر Change Control')
