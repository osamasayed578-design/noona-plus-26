from model.dsl import module, table

module(27, 'MIG', 'ترحيل البيانات', 'Data Migration', 'NOONA_MIGRATION_PKG',
       'تحميل بيانات العملاء من الأنظمة السابقة عبر Staging بحمولة JSON، وتعيين الحقول، والتحقق والمعاينة '
       'وتقرير الأخطاء قبل الاعتماد، ثم المطابقة (عدد السجلات والأرصدة) مع إمكانية الإلغاء.')

table('MIG_PROJECT', 'مشروعات الترحيل', 'Migration Projects', scope='T', mix='code names status', status='PLANNED IN_PROGRESS VALIDATED COMPLETED CANCELLED', cols='''
SOURCE_SYSTEM   V200 NN          | النظام المصدر
COMPANY_ID      ID   >ORG_COMPANY | الشركة الهدف
CUTOVER_DATE    DATE             | تاريخ التحويل
OWNER_MEMBER_ID ID   >SEC_USER_MEMBERSHIP | المسؤول
''', area='migration')

table('MIG_MAPPING', 'تعيين الحقول', 'Field Mappings', scope='T', mix='status', status='DRAFT APPROVED', cols='''
PROJECT_ID      ID   NN >MIG_PROJECT | المشروع
TARGET_ENTITY   V50  NN >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | الكيان الهدف
VERSION_NO      INT  NN D=1      | الإصدار
MAPPING_RULES   JSON NN          | قواعد التعيين والتحويل والقيم المرجعية
''', uk=[('PROJECT_ID', 'TARGET_ENTITY', 'VERSION_NO')], area='migration')

table('MIG_BATCH', 'دفعات الترحيل', 'Migration Batches', scope='T', mix='status', status='UPLOADED STAGED VALIDATING VALIDATED LOADING LOADED RECONCILED ROLLED_BACK FAILED', cols='''
PROJECT_ID      ID   NN >MIG_PROJECT | المشروع
MAPPING_ID      ID   NN >MIG_MAPPING | التعيين
TARGET_ENTITY   V50  NN >REF_ENTITY_TYPE.ENTITY_TYPE_CODE | الكيان
SOURCE_DOCUMENT_ID ID >DMS_DOCUMENT | الملف المصدر (Excel/CSV)
IS_DRY_RUN      YN   NN D='Y'    | تشغيل تجريبي
TOTAL_ROWS      INT              | الإجمالي
VALID_ROWS      INT              | الصالحة
ERROR_ROWS      INT              | الأخطاء
LOADED_ROWS     INT              | المحملة
APPROVED_BY     USR              | المعتمد
''', area='migration')

table('MIG_STAGING_ROW', 'سجلات التجهيز', 'Staging Rows', scope='T', mix='status', status='NEW VALID INVALID LOADED SKIPPED', cols='''
BATCH_ID        ID   NN >MIG_BATCH | الدفعة
ROW_NO          INT  NN          | رقم السطر
SOURCE_KEY      V200             | مفتاح المصدر
PAYLOAD         JSON NN          | البيانات الأصلية
TRANSFORMED     JSON             | بعد التحويل
TARGET_ID       ID               | المعرف الناتج
''', uk=[('BATCH_ID', 'ROW_NO')], area='migration')

table('MIG_ERROR', 'أخطاء الترحيل', 'Migration Errors', scope='T', append=True, cols='''
STAGING_ROW_ID  ID   NN >MIG_STAGING_ROW | السطر
FIELD_NAME      V128             | الحقل
ERROR_CODE      V50  NN          | الرمز
MESSAGE_AR      V1000 NN         | الرسالة
''', area='migration')

table('MIG_RECONCILIATION', 'مطابقة الترحيل', 'Migration Reconciliation', scope='T', mix='status', status='MATCHED DIFFERENCES ACCEPTED', cols='''
BATCH_ID        ID   NN >MIG_BATCH | الدفعة
CHECK_CODE      V50  NN          | الفحص (عدد، أرصدة، مجاميع)
SOURCE_VALUE    NUM              | قيمة المصدر
TARGET_VALUE    NUM              | قيمة الهدف
DIFFERENCE      NUM              | الفرق
EXPLANATION     V1000            | التفسير
''', area='migration')
