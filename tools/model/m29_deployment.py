from model.dsl import module, table

module(29, 'DEP', 'النشر الإنتاجي والإصدارات', 'Deployment & Release Management', 'NOONA_DEPLOYMENT_PKG',
       'سجل الإصدارات وقنوات النشر Internal → Pilot → Early Access → GA → On-Premises، وسجل ترحيلات المخطط '
       '(Migration Scripts مرقمة لا تعدل بعد النشر)، ونشر كل بيئة/خلية وفحوص الصحة وإصدارات مكونات كل Tenant.')

table('DEP_RELEASE', 'الإصدارات', 'Releases', scope='G', mix='status', status='PLANNED BUILT TESTED APPROVED ROLLING_OUT RELEASED ROLLED_BACK RETIRED', cols='''
VERSION_LABEL   V30  NN U        | رقم الإصدار (1.0.0)
RELEASE_TYPE    CODE NN IN:MAJOR,MINOR,PATCH,HOTFIX | النوع
CHANNEL         CODE NN D='INTERNAL' IN:INTERNAL,PILOT,EARLY_ACCESS,GENERAL_AVAILABILITY,ON_PREMISES_PACKAGE,LTS | القناة
RELEASE_NOTES   CLOB             | ملاحظات الإصدار
PACKAGE_SIGNATURE V4000          | توقيع الحزمة (On-Premises)
RELEASED_AT     TS               | تاريخ الإطلاق
''', area='release')

table('DEP_COMPONENT_VERSION', 'إصدارات المكونات', 'Release Component Versions', scope='G', cols='''
RELEASE_ID      ID   NN >DEP_RELEASE | الإصدار
COMPONENT_CODE  CODE NN IN:DB_SCHEMA,PLSQL,APEX_APP,ORDS,API,COUNTRY_PACK,AI_RAG,DOC_STORAGE | المكون
COMPONENT_VERSION V50 NN         | الإصدار
MIN_COMPATIBLE  V50              | أدنى إصدار متوافق
''', uk=[('RELEASE_ID', 'COMPONENT_CODE')], area='release')

table('DEP_SCHEMA_MIGRATION', 'سجل ترحيلات المخطط', 'Schema Migrations', scope='G', append=True, cols='''
SCRIPT_NAME     V200 NN U        | اسم السكربت المرقم
SCRIPT_VERSION  V30  NN          | الإصدار
CHECKSUM        HASH NN          | Hash المحتوى (لا يعدل بعد النشر)
RELEASE_ID      ID   >DEP_RELEASE | الإصدار
EXECUTION_MS    INT              | مدة التنفيذ
RESULT_CODE     CODE NN IN:SUCCESS,FAILED,ROLLED_BACK,FORWARD_FIXED | النتيجة
ERROR_MESSAGE   V4000            | الخطأ
ROLLBACK_SCRIPT V200             | سكربت الرجوع
''', area='release', purpose='يسجل كل ملف DDL/Migration ينفذ على البيئة')

table('DEP_DEPLOYMENT', 'عمليات النشر', 'Deployments', scope='G', mix='status', status='SCHEDULED IN_PROGRESS HEALTH_CHECK SUCCEEDED FAILED ROLLED_BACK', cols='''
RELEASE_ID      ID   NN >DEP_RELEASE | الإصدار
CELL_ID         ID   >PLT_CELL   | الخلية
ENVIRONMENT_CODE CODE NN IN:DEV,TEST,UAT,PREPROD,PROD,DR | البيئة
ROLLOUT_WAVE    CODE IN:INTERNAL,PILOT,LIMITED,GENERAL | الموجة
WINDOW_START    TS               | بداية النافذة
WINDOW_END      TS               | نهايتها
OWNER_NAME      V200             | المسؤول
ROLLBACK_PLAN   V4000            | خطة التراجع
STARTED_AT      TS               | البداية
FINISHED_AT     TS               | النهاية
''', area='deployment')

table('DEP_HEALTH_CHECK', 'فحوص الصحة', 'Health Checks', scope='G', append=True, cols='''
DEPLOYMENT_ID   ID   NN >DEP_DEPLOYMENT | النشر
CHECK_CODE      V50  NN          | الفحص
RESULT_CODE     CODE NN IN:PASS,FAIL,WARN | النتيجة
DETAILS         V4000            | التفاصيل
''', area='deployment')

table('DEP_TENANT_VERSION', 'إصدارات مكونات المؤسسة', 'Tenant Component Versions', scope='T', cols='''
COMPONENT_CODE  CODE NN IN:DB_SCHEMA,PLSQL,APEX_APP,ORDS,API,COUNTRY_PACK,AI_RAG,DOC_STORAGE | المكون
COMPONENT_VERSION V50 NN         | الإصدار الحالي
RELEASE_ID      ID   >DEP_RELEASE | الإصدار
UPGRADED_AT     TS               | تاريخ الترقية
''', uk=[('TENANT_ID', 'COMPONENT_CODE')], area='deployment', purpose='لا تشغل تركيبة غير مدعومة')
