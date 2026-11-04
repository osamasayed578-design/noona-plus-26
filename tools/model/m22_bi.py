from model.dsl import module, table

module(22, 'BI', 'التقارير وذكاء الأعمال', 'Reporting & Business Intelligence', 'NOONA_BI_PKG',
       'طبقة تعريف المقاييس KPIs بإصدارات، وكتالوج التقارير ولوحات المعلومات، وسجل التصدير، وجدولة '
       'التقارير، ومتابعة تحديث الملخصات؛ مع تطبيق Tenant و Data Scope على المصدر والتصدير.')

table('BI_KPI', 'تعريفات المؤشرات', 'KPI Definitions', scope='TO', mix='code names desc status', status='DRAFT PUBLISHED RETIRED', codeuk=False, cols='''
MODULE_CODE     CODE NN          | الحزمة
VERSION_NO      INT  NN D=1      | الإصدار
OWNER_ROLE_ID   ID   >SEC_ROLE   | المالك
FORMULA_TEXT    V4000 NN         | الصيغة الموثقة
SOURCE_OBJECT   V128             | المصدر (View/MV)
UNIT_CODE       CODE             | وحدة القياس
PERIOD_SEMANTICS V200            | معنى الفترة وتاريخ القطع
CURRENCY_RULE   V200             | قاعدة العملة
REFRESH_FREQUENCY CODE IN:REALTIME,HOURLY,DAILY,WEEKLY,MONTHLY | التحديث
DRILL_TARGET    V200             | وجهة Drill Down
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='semantic',
      purpose='لا تعريفات مختلفة لنفس «صافي المبيعات» دون تسمية وفارق موثقين')

table('BI_KPI_VALUE', 'قيم المؤشرات', 'KPI Snapshots', scope='T', append=True, cols='''
KPI_ID          ID   NN >BI_KPI  | المؤشر
COMPANY_ID      ID   >ORG_COMPANY | الشركة
BRANCH_ID       ID   >ORG_BRANCH  | الفرع
PERIOD_CODE     V20  NN          | الفترة
AS_OF_TS        TS   NN          | تاريخ القطع
VALUE_NUMBER    NUM              | القيمة
TARGET_NUMBER   NUM              | المستهدف
CURRENCY_CODE   CUR              | العملة
''', ix=[('TENANT_ID', 'KPI_ID', 'PERIOD_CODE')], area='semantic')

table('BI_REPORT', 'كتالوج التقارير', 'Report Catalog', scope='TO', mix='code names desc status', status='DRAFT PUBLISHED RETIRED', codeuk=False, cols='''
MODULE_CODE     CODE NN          | الحزمة
REPORT_TYPE     CODE NN IN:OPERATIONAL,FINANCIAL,MANAGEMENT,REGULATORY,ANALYTICAL | النوع
VERSION_NO      INT  NN D=1      | الإصدار
PERMISSION_ID   ID   >SEC_PERMISSION | الصلاحية المطلوبة
APEX_PAGE_ID    INT              | صفحة APEX
OUTPUT_FORMATS  V100             | الصيغ المتاحة
MANDATORY_FILTERS V1000          | الفلاتر الإلزامية للأحجام الكبيرة
IS_AS_OF_CAPABLE YN NN D='N'     | يدعم «كما كان» تاريخياً
APP_ALIAS       V50              | التطبيق الذي يعرض التقرير (Alias)
PAGE_ALIAS      V100             | صفحة التقرير (Alias)
PAGE_NO         INT              | رقم الصفحة (لمسح مرشحاتها السابقة عند الفتح)
PARAM_ITEM      V100             | عنصر اختيار التقرير في مركز تقارير الوحدة
PARAM_VALUE     V100             | قيمة الاختيار (رمز التقرير)
PERMISSION_CODE V100             | الصلاحية المطلوبة (فارغ = أي صلاحية في الوحدة)
ICON_CLASS      V50              | الأيقونة
SORT_ORDER      INT  NN D=0      | الترتيب داخل الوحدة
''', uk=[('TENANT_ID', 'CODE', 'VERSION_NO')], area='catalog',
      purpose='مركز التقارير الموحد: كل تقارير الوحدات في مكان واحد؛ يظهر التقرير متى اشتركت المؤسسة في وحدته وللمستخدم صلاحيته')

table('BI_REPORT_USER', 'تقارير المستخدم المفضلة والأخيرة', 'User Favourite & Recent Reports', scope='T', cols='''
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستخدم
REPORT_ID       ID   NN >BI_REPORT | التقرير
IS_FAVORITE     YN   NN D='N'    | مفضل
OPEN_COUNT      INT  NN D=0      | مرات الفتح
LAST_OPENED_AT  TS               | آخر فتح
''', uk=[('TENANT_ID', 'MEMBERSHIP_ID', 'REPORT_ID')], area='catalog')

table('BI_DASHBOARD', 'لوحات المعلومات', 'Dashboards', scope='TO', mix='code names status', status='DRAFT PUBLISHED RETIRED', cols='''
AUDIENCE        CODE NN IN:PLATFORM,TENANT_ADMIN,EXECUTIVE,FINANCE,OPERATIONS,HR,PROJECTS,PROPERTY,PERSONAL | الجمهور
APEX_PAGE_ID    INT              | صفحة APEX
LAYOUT          JSON             | التخطيط
''', area='catalog')

table('BI_DASHBOARD_WIDGET', 'عناصر اللوحات', 'Dashboard Widgets', scope='TO', mix='sort', cols='''
DASHBOARD_ID    ID   NN >BI_DASHBOARD | اللوحة
KPI_ID          ID   >BI_KPI     | المؤشر
REPORT_ID       ID   >BI_REPORT  | التقرير
WIDGET_TYPE     CODE NN IN:KPI_CARD,CHART,TABLE,LIST,MAP,GAUGE | النوع
CONFIG          JSON             | الإعداد
''', area='catalog')

table('BI_REPORT_SCHEDULE', 'جدولة التقارير', 'Report Schedules', scope='T', mix='status', status='ACTIVE PAUSED ENDED', cols='''
REPORT_ID       ID   NN >BI_REPORT | التقرير
OWNER_MEMBER_ID ID   NN >SEC_USER_MEMBERSHIP | المالك (يعمل بصلاحياته)
CRON_EXPRESSION V100 NN          | التوقيت
PARAMETERS      JSON             | المعاملات
OUTPUT_FORMAT   CODE NN D='PDF' IN:PDF,XLSX,CSV,HTML | الصيغة
RECIPIENTS      JSON             | المستلمون (يعاد فحص صلاحياتهم)
NEXT_RUN_AT     TS               | التشغيل التالي
''', area='delivery')

table('BI_EXPORT_LOG', 'سجل التصدير', 'Export Log', scope='T', append=True, cols='''
REPORT_ID       ID   >BI_REPORT  | التقرير
MEMBERSHIP_ID   ID   NN >SEC_USER_MEMBERSHIP | المستخدم
EXPORT_FORMAT   CODE NN          | الصيغة
ROW_COUNT       NUM              | عدد السجلات
FILTERS         JSON             | المرشحات المستخدمة
REPORT_VERSION  INT              | إصدار التعريف
WATERMARKED     YN   NN D='N'    | بعلامة مائية
FILE_DOCUMENT_ID ID  >DMS_DOCUMENT | الملف الناتج
EXPIRES_AT      TS               | انتهاء رابط التنزيل
REASON          V500             | السبب (للبيانات الحساسة)
''', ix=[('TENANT_ID', 'MEMBERSHIP_ID', 'CREATED_AT')], area='delivery')

table('BI_REFRESH_LOG', 'سجل تحديث الملخصات', 'Summary Refresh Log', scope='G', append=True, cols='''
OBJECT_NAME     V128 NN          | الكائن (MV/جدول ملخص)
STARTED_AT      TS   NN          | البداية
FINISHED_AT     TS               | النهاية
RESULT_CODE     CODE NN IN:SUCCESS,FAILED,PARTIAL | النتيجة
DATA_CUTOFF_TS  TS               | وقت قطع البيانات المعروض للمستخدم
ERROR_MESSAGE   V2000            | الخطأ
''', area='operations')

table('BI_HISTORY_VALUE', 'أرقام السنوات السابقة', 'Prior Years Figures', scope='C', mix='notes', cols='''
METRIC_CODE     CODE NN          | المؤشر (من كتالوج NOONA_ANL_PKG)
PERIOD_MONTH    DATE NN          | الشهر (أول يوم فيه)
BRANCH_ID       ID   >ORG_BRANCH | الفرع (فارغ = الشركة كلها)
VALUE_AMOUNT    NUM  NN          | القيمة الشهرية (للأرصدة: رصيد نهاية الشهر)
SOURCE_CODE     CODE NN D='MANUAL' IN:MANUAL,IMPORT,LEGACY | المصدر
''', uk=[('TENANT_ID', 'COMPANY_ID', 'METRIC_CODE', 'PERIOD_MONTH', 'BRANCH_ID')],
      purpose='أرقام شهرية من النظام السابق قبل بدء العمل على نونا، تضاف لسلاسل التحليلات للمقارنة بين السنوات في أي موديول',
      area='analytics')
