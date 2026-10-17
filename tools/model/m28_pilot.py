from model.dsl import module, table

module(28, 'PIL', 'الإطلاق التجريبي', 'Pilot Launch', 'NOONA_PILOT_PKG',
       'إدارة الإطلاق التجريبي لعميل مؤسس: النطاق والمستخدمون ومعايير النجاح والملاحظات والقياس وقرار '
       'الانتقال إلى الإنتاج ومصير البيانات.')

table('PIL_PILOT', 'المشروعات التجريبية', 'Pilots', scope='T', mix='code names status', status='PLANNED ACTIVE EXTENDED SUCCEEDED FAILED CONVERTED CLOSED', cols='''
TRIAL_ID        ID   >PLT_TRIAL  | التجربة المرتبطة
SCOPE_MODULES   V1000            | الوحدات المشمولة
USER_LIMIT      INT              | عدد المستخدمين
START_DATE      DATE NN          | البداية
END_DATE        DATE NN          | النهاية
SPONSOR_NAME    V200             | راعي العميل
DATA_FATE       CODE IN:KEEP,EXPORT_AND_ARCHIVE,PURGE_AFTER_RETENTION | مصير البيانات
GO_LIVE_DECISION CODE IN:GO,NO_GO,EXTEND | قرار الانتقال للإنتاج
DECISION_DATE   DATE             | تاريخ القرار
''', area='pilot')

table('PIL_SUCCESS_CRITERION', 'معايير النجاح', 'Success Criteria', scope='T', mix='sort status', status='PENDING MET NOT_MET WAIVED', cols='''
PILOT_ID        ID   NN >PIL_PILOT | التجربة
CRITERION_TEXT  V1000 NN         | المعيار
TARGET_VALUE    V200             | المستهدف
ACTUAL_VALUE    V200             | الفعلي
''', area='pilot')

table('PIL_FEEDBACK', 'ملاحظات المستخدمين', 'Pilot Feedback', scope='T', mix='status', status='NEW ACCEPTED PLANNED DONE REJECTED', cols='''
PILOT_ID        ID   NN >PIL_PILOT | التجربة
MEMBERSHIP_ID   ID   >SEC_USER_MEMBERSHIP | المستخدم
MODULE_CODE     CODE             | الوحدة
FEEDBACK_TYPE   CODE NN IN:BUG,USABILITY,FEATURE_REQUEST,PERFORMANCE,PRAISE | النوع
DESCRIPTION     V4000 NN         | الوصف
DEFECT_ID       ID   >QA_DEFECT  | العيب المرتبط
''', area='pilot')

table('PIL_USAGE_METRIC', 'مقاييس الاستخدام التجريبي', 'Pilot Usage Metrics', scope='T', append=True, cols='''
PILOT_ID        ID   NN >PIL_PILOT | التجربة
METRIC_DATE     DATE NN          | اليوم
METRIC_CODE     V50  NN          | المقياس (مستخدمون نشطون، معاملات، أخطاء...)
METRIC_VALUE    NUM  NN          | القيمة
''', area='pilot')
