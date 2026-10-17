from model.dsl import module, table

module(26, 'QA', 'الاختبار الشامل وضمان الجودة', 'Quality Assurance & Traceability', 'NOONA_QA_PKG',
       'سجل المتطلبات وقواعد الأعمال (FR/NFR/BR) وربطها بحالات الاختبار وتشغيلاتها والعيوب، لتحقيق '
       'Traceability من المتطلب إلى الاختبار إلى الإصدار.')

table('QA_REQUIREMENT', 'سجل المتطلبات', 'Requirements Register', scope='G', mix='code status', status='PROPOSED APPROVED IMPLEMENTED VERIFIED DEFERRED REJECTED', cols='''
REQ_TYPE        CODE NN IN:FUNCTIONAL,NON_FUNCTIONAL,BUSINESS_RULE,DECISION,RISK | النوع (FR/NFR/BR/Decision/Risk)
TITLE_AR        V1000 NN         | العنوان
DESCRIPTION     V4000            | الوصف
PRIORITY_CODE   CODE IN:CRITICAL,HIGH,MEDIUM,LOW | الأولوية
MODULE_CODE     CODE             | الحزمة
SOURCE_REF      V200             | المرجع في الوثيقة (القسم)
OWNER_NAME      V200             | المالك
ACCEPTANCE_CRITERIA V4000        | معيار القبول
RELEASE_TARGET  V20              | الإصدار المستهدف
''', area='traceability', purpose='FR-001..015، NFR-001..010، BR-001..012 ومخرجات المراحل')

table('QA_TEST_SUITE', 'مجموعات الاختبار', 'Test Suites', scope='G', mix='code names', cols='''
MODULE_CODE     CODE             | الحزمة
TEST_LEVEL      CODE NN IN:UNIT,MODULE,INTEGRATION,ACCOUNTING,WORKFLOW,SECURITY,PERFORMANCE,UAT,REGRESSION | المستوى
''', area='testing')

table('QA_TEST_CASE', 'حالات الاختبار', 'Test Cases', scope='G', mix='code status', status='DRAFT READY OBSOLETE', cols='''
SUITE_ID        ID   NN >QA_TEST_SUITE | المجموعة
TITLE_AR        V1000 NN         | العنوان
PRECONDITIONS   V4000            | المتطلبات المسبقة
STEPS           CLOB             | الخطوات
EXPECTED_RESULT V4000 NN         | النتيجة المتوقعة
TEST_DATA_REF   V500             | بيانات الاختبار
IS_AUTOMATED    YN   NN D='N'    | مؤتمت (utPLSQL/Playwright)
''', area='testing')

table('QA_TRACE_LINK', 'روابط التتبع', 'Traceability Links', scope='G', cols='''
REQUIREMENT_ID  ID   NN >QA_REQUIREMENT | المتطلب
TEST_CASE_ID    ID   NN >QA_TEST_CASE | الحالة
''', uk=[('REQUIREMENT_ID', 'TEST_CASE_ID')], area='traceability')

table('QA_TEST_RUN', 'تشغيلات الاختبار', 'Test Runs', scope='G', mix='status', status='PLANNED RUNNING COMPLETED ABORTED', cols='''
RUN_NAME        V200 NN          | الاسم
ENVIRONMENT_CODE CODE NN IN:DEV,TEST,UAT,PREPROD | البيئة
RELEASE_VERSION V30              | الإصدار المختبر
STARTED_AT      TS               | البداية
FINISHED_AT     TS               | النهاية
''', area='testing')

table('QA_TEST_RESULT', 'نتائج الاختبار', 'Test Results', scope='G', append=True, cols='''
RUN_ID          ID   NN >QA_TEST_RUN | التشغيل
TEST_CASE_ID    ID   NN >QA_TEST_CASE | الحالة
RESULT_CODE     CODE NN IN:PASS,FAIL,BLOCKED,SKIPPED | النتيجة
ACTUAL_RESULT   V4000            | النتيجة الفعلية
EVIDENCE_REF    V500             | الدليل
EXECUTED_BY     USR              | المنفذ
''', area='testing')

table('QA_DEFECT', 'العيوب', 'Defects', scope='G', mix='code status', status='NEW TRIAGED IN_PROGRESS FIXED RETEST VERIFIED CLOSED REJECTED', cols='''
TITLE           V1000 NN         | العنوان
SEVERITY        CODE NN IN:CRITICAL,HIGH,MEDIUM,LOW | الخطورة
TEST_RESULT_ID  ID   >QA_TEST_RESULT | النتيجة المكتشف فيها
REQUIREMENT_ID  ID   >QA_REQUIREMENT | المتطلب
MODULE_CODE     CODE             | الحزمة
FIX_VERSION     V30              | إصدار الإصلاح
ACCEPTED_BY     USR              | قبول مالك العملية
''', area='testing', purpose='لا انتقال للإنتاج مع ثغرة حرجة/عالية مفتوحة دون استثناء موثق')
