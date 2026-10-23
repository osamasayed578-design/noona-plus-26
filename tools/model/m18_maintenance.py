from model.dsl import module, table

module(18, 'MNT', 'الصيانة وإدارة المرافق', 'Maintenance & Facility Management', 'NOONA_MAINTENANCE_PKG',
       'بلاغات الصيانة من المستأجرين والنزلاء والموظفين، وأوامر العمل التصحيحية والوقائية، والفرق والفنيون '
       'والمواد والعمالة، وعقود الصيانة مع المقاولين، وفترات التوقف، مع قرار مستقل للرسملة أو المصروف.')

table('MNT_SERVICE_CATEGORY', 'فئات خدمات الصيانة', 'Service Categories', scope='T', mix='code names active', cols='''
PARENT_CATEGORY_ID ID >MNT_SERVICE_CATEGORY | الفئة الأم
DEFAULT_PRIORITY CODE IN:LOW,NORMAL,HIGH,URGENT,EMERGENCY | الأولوية الافتراضية
SLA_POLICY_ID   ID   >WF_SLA_POLICY | SLA
SLA_HOURS       INT              | زمن الإنجاز المستهدف بالساعات
ICON            V50              | الأيقونة
''', area='setup')

table('MNT_TEAM', 'فرق الصيانة', 'Maintenance Teams', scope='C', mix='code names active', cols='''
SUPERVISOR_EMPLOYEE_ID ID >HR_EMPLOYEE | المشرف
SUPPLIER_ACCOUNT_ID ID >AP_SUPPLIER_ACCOUNT | مقاول خارجي
QUEUE_ID        ID   >WF_QUEUE   | قائمة العمل
SPECIALTY       V200             | التخصص
PHONE           V30              | هاتف الفريق
''', area='setup')

table('MNT_TECHNICIAN', 'الفنيون', 'Technicians', scope='C', mix='active', cols='''
TEAM_ID         ID   NN >MNT_TEAM | الفريق
EMPLOYEE_ID     ID   >HR_EMPLOYEE | الموظف
EXTERNAL_NAME   NAME             | فني المقاول
SKILLS          V1000            | المهارات
HOURLY_COST     AMT              | تكلفة الساعة
''', area='setup')

table('MNT_SERVICE_CONTRACT', 'عقود الصيانة', 'Service Contracts (AMC)', scope='C', mix='pub doc cur eff status', status='DRAFT ACTIVE EXPIRED TERMINATED', cols='''
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | المقاول
PROPERTY_ID     ID   >RE_PROPERTY | العقار
SCOPE_TEXT      V4000            | النطاق
CONTRACT_VALUE  AMT              | القيمة
RESPONSE_SLA_HOURS INT           | زمن الاستجابة التعاقدي
DOCUMENT_ID     ID   >DMS_DOCUMENT | العقد
''', area='setup')

table('MNT_REQUEST', 'بلاغات الصيانة', 'Maintenance Requests', scope='C', mix='pub doc status',
      status='NEW TRIAGED ASSIGNED IN_PROGRESS ON_HOLD COMPLETED VERIFIED CLOSED CANCELLED REJECTED', cols='''
CATEGORY_ID     ID   NN >MNT_SERVICE_CATEGORY | الفئة
PRIORITY_CODE   CODE NN D='NORMAL' IN:LOW,NORMAL,HIGH,URGENT,EMERGENCY | الأولوية
REQUESTER_PARTY_ID ID >PTY_PARTY | المبلغ (مستأجر/نزيل)
REQUESTER_MEMBER_ID ID >SEC_USER_MEMBERSHIP | المبلغ (مستخدم)
CHANNEL_CODE    CODE NN D='PORTAL' IN:PORTAL,PHONE,EMAIL,FRONT_DESK,INSPECTION,PREVENTIVE,APP | القناة
PROPERTY_ID     ID   >RE_PROPERTY | العقار
UNIT_ID         ID   >RE_UNIT    | الوحدة
ROOM_ID         ID   >HSP_ROOM   | الغرفة الفندقية
ASSET_ID        ID   >FA_ASSET   | الأصل
SITE_ID         ID   >ORG_BUSINESS_SITE | الموقع
LEASE_ID        ID   >PRP_LEASE  | عقد الإيجار
DESCRIPTION     V4000 NN         | وصف المشكلة
DUE_AT          TS               | موعد SLA
CHARGEABLE_TO   CODE NN D='OWNER' IN:OWNER,LESSEE,WARRANTY,CONTRACTOR,INSURANCE | يحمل على
SATISFACTION_SCORE INT           | تقييم الرضا
TITLE           V200             | عنوان البلاغ
REPORTER_NAME   V200             | اسم المبلغ (هاتف/بوابة)
REPORTER_PHONE  V30              | جوال المبلغ
TEAM_ID         ID   >MNT_TEAM   | الفريق المكلف
TECHNICIAN_ID   ID   >MNT_TECHNICIAN | الفني المكلف
ROOM_OUT_OF_ORDER YN NN D='N'    | أوقف الغرفة حتى الإصلاح
RESPONDED_AT    TS               | وقت الاستجابة (الإسناد)
RESOLVED_AT     TS               | وقت الإنجاز
RESOLUTION_NOTES V2000           | ما تم عمله
''', ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE'), ('TENANT_ID', 'UNIT_ID')], area='request')

table('MNT_PM_PLAN', 'خطط الصيانة الوقائية', 'Preventive Maintenance Plans', scope='C', mix='code names status', status='ACTIVE SUSPENDED RETIRED', cols='''
ASSET_ID        ID   >FA_ASSET   | الأصل
PROPERTY_ID     ID   >RE_PROPERTY | العقار
CATEGORY_ID     ID   NN >MNT_SERVICE_CATEGORY | الفئة
FREQUENCY_TYPE  CODE NN IN:DAYS,WEEKS,MONTHS,METER,HOURS | نوع التكرار
FREQUENCY_VALUE INT  NN          | القيمة
NEXT_DUE_DATE   DATE             | الاستحقاق التالي
TEAM_ID         ID   >MNT_TEAM   | الفريق
SERVICE_CONTRACT_ID ID >MNT_SERVICE_CONTRACT | العقد
CHECKLIST       JSON             | قائمة الفحص
''', area='preventive')

table('MNT_WORK_ORDER', 'أوامر العمل', 'Work Orders', scope='C', mix='pub doc wf status',
      status='PLANNED APPROVED SCHEDULED IN_PROGRESS ON_HOLD COMPLETED VERIFIED CLOSED CANCELLED', cols='''
REQUEST_ID      ID   >MNT_REQUEST | البلاغ
PM_PLAN_ID      ID   >MNT_PM_PLAN | الخطة الوقائية
WO_TYPE         CODE NN IN:CORRECTIVE,PREVENTIVE,INSPECTION,EMERGENCY,PROJECT,FIT_OUT | النوع
TEAM_ID         ID   >MNT_TEAM   | الفريق
SUPPLIER_ACCOUNT_ID ID >AP_SUPPLIER_ACCOUNT | المقاول
ASSET_ID        ID   >FA_ASSET   | الأصل
UNIT_ID         ID   >RE_UNIT    | الوحدة
PLANNED_START   TS               | البداية المخططة
PLANNED_END     TS               | النهاية المخططة
ACTUAL_START    TS               | البداية الفعلية
ACTUAL_END      TS               | النهاية الفعلية
ESTIMATED_COST  AMT              | التكلفة التقديرية
ACTUAL_COST     AMT  @CALC       | التكلفة الفعلية
CAPITALIZE      YN   NN D='N'    | يرسمل على الأصل (قرار مستقل)
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
COMPLETION_NOTES V4000           | ملاحظات الإنجاز
''', ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE')], area='work_order')

table('MNT_WO_TASK', 'مهام أمر العمل', 'Work Order Tasks', scope='C', mix='sort status', status='PENDING DONE SKIPPED', cols='''
WORK_ORDER_ID   ID   NN >MNT_WORK_ORDER | الأمر
TASK_TEXT       V1000 NN         | المهمة
TECHNICIAN_ID   ID   >MNT_TECHNICIAN | الفني
RESULT_TEXT     V1000            | النتيجة
''', area='work_order')

table('MNT_WO_MATERIAL', 'مواد أمر العمل', 'Work Order Materials', scope='C', cols='''
WORK_ORDER_ID   ID   NN >MNT_WORK_ORDER | الأمر
ITEM_ID         ID   NN >INV_ITEM | الصنف
PLANNED_QTY     QTY              | المخطط
ISSUED_QTY      QTY  NN D=0      | المصروف
RETURNED_QTY    QTY  NN D=0      | المرتجع
UOM_ID          ID   NN >INV_UOM | الوحدة
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة الصرف
UNIT_COST       AMT              | التكلفة
''', area='work_order')

table('MNT_WO_LABOR', 'عمالة أمر العمل', 'Work Order Labor', scope='C', cols='''
WORK_ORDER_ID   ID   NN >MNT_WORK_ORDER | الأمر
TECHNICIAN_ID   ID   NN >MNT_TECHNICIAN | الفني
WORK_DATE       DATE NN          | التاريخ
HOURS           QTY  NN          | الساعات
COST_AMOUNT     AMT              | التكلفة
''', chk=['HOURS > 0'], area='work_order')

table('MNT_DOWNTIME', 'فترات التوقف', 'Asset Downtime', scope='C', cols='''
ASSET_ID        ID   >FA_ASSET   | الأصل
UNIT_ID         ID   >RE_UNIT    | الوحدة
WORK_ORDER_ID   ID   >MNT_WORK_ORDER | أمر العمل
STARTED_AT      TS   NN          | البداية
ENDED_AT        TS               | النهاية
REASON_CODE     CODE             | السبب
''', chk=['ENDED_AT IS NULL OR ENDED_AT >= STARTED_AT'], area='work_order')
