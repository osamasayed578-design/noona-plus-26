from model.dsl import module, table

module(21, 'MFG', 'التصنيع', 'Manufacturing', 'NOONA_MANUFACTURING_PKG',
       'قوائم المواد BOM ومسارات التصنيع بإصدارات غير قابلة للتعديل بعد الاستخدام، وأوامر الإنتاج المثبتة '
       'على نسخة BOM/Routing، وصرف المواد والإنتاج والجودة والهالك، والعمل تحت التشغيل WIP والتكلفة '
       'والانحرافات، باستخدام طبقة المخزون المعتمدة دون سجلات موازية.')

table('MFG_WORK_CENTER', 'مراكز العمل', 'Work Centers', scope='C', mix='code names branch active', cols='''
SITE_ID         ID   >ORG_BUSINESS_SITE | المصنع
CAPACITY_HOURS_DAY QTY           | الطاقة اليومية بالساعات
LABOR_RATE      AMT              | معدل العمالة/ساعة
OVERHEAD_RATE   AMT              | معدل التحميل/ساعة
MACHINE_RATE    AMT              | معدل الآلات/ساعة
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
ASSET_ID        ID   >FA_ASSET   | الأصل/الآلة
''', area='setup')

table('MFG_BOM', 'قوائم المواد', 'Bills of Materials', scope='C', mix='code names eff status', codeuk=False,
      status='DRAFT APPROVED PUBLISHED OBSOLETE', cols='''
ITEM_ID         ID   NN >INV_ITEM | المنتج
VERSION_NO      INT  NN          | الإصدار (لا يعدل بعد استخدامه في أمر)
BOM_TYPE        CODE NN D='PRODUCTION' IN:PRODUCTION,ENGINEERING,KIT,PHANTOM | النوع
BASE_QUANTITY   QTY  NN D=1      | الكمية المرجعية
UOM_ID          ID   NN >INV_UOM | الوحدة
IS_DEFAULT      YN   NN D='N'    | الافتراضية
''', uk=[('TENANT_ID', 'COMPANY_ID', 'CODE', 'VERSION_NO')], area='engineering')

table('MFG_BOM_LINE', 'مكونات قائمة المواد', 'BOM Components', scope='C', mix='sort', cols='''
BOM_ID          ID   NN >MFG_BOM | القائمة
LINE_NO         INT  NN          | السطر
COMPONENT_ITEM_ID ID NN >INV_ITEM | المكون
QUANTITY        QTY  NN          | الكمية لكل كمية مرجعية
UOM_ID          ID   NN >INV_UOM | الوحدة
SCRAP_PCT       PCT  NN D=0      | الهالك المسموح
OPERATION_SEQ   INT              | العملية المستهلكة
IS_CO_PRODUCT   YN   NN D='N'    | منتج مشترك/ثانوي (مخرج)
SUBSTITUTE_GROUP V30             | مجموعة البدائل
''', uk=[('BOM_ID', 'LINE_NO')], chk=['QUANTITY > 0'], area='engineering',
      purpose='تمنع دورات مكون → منتج في الوصفات متعددة المستويات (تفحص في الحزمة)')

table('MFG_BOM_SUBSTITUTE', 'بدائل المكونات', 'Component Substitutes', scope='C', cols='''
BOM_LINE_ID     ID   NN >MFG_BOM_LINE | المكون
SUBSTITUTE_ITEM_ID ID NN >INV_ITEM | البديل
CONVERSION_FACTOR RATE NN D=1    | معامل الاستبدال
PRIORITY_NO     INT  NN D=1      | الأولوية
REQUIRES_APPROVAL YN NN D='Y'    | يتطلب موافقة
''', uk=[('BOM_LINE_ID', 'SUBSTITUTE_ITEM_ID')], area='engineering')

table('MFG_ROUTING', 'مسارات التصنيع', 'Routings', scope='C', mix='code names eff status', codeuk=False, status='DRAFT APPROVED PUBLISHED OBSOLETE', cols='''
ITEM_ID         ID   NN >INV_ITEM | المنتج
VERSION_NO      INT  NN          | الإصدار
''', uk=[('TENANT_ID', 'COMPANY_ID', 'CODE', 'VERSION_NO')], area='engineering')

table('MFG_ROUTING_OPERATION', 'عمليات المسار', 'Routing Operations', scope='C', cols='''
ROUTING_ID      ID   NN >MFG_ROUTING | المسار
OPERATION_SEQ   INT  NN          | التسلسل
WORK_CENTER_ID  ID   NN >MFG_WORK_CENTER | مركز العمل
DESCRIPTION     V500 NN          | الوصف
SETUP_MINUTES   QTY  NN D=0      | زمن الإعداد
RUN_MINUTES_PER_UNIT QTY NN D=0  | زمن التشغيل للوحدة
QUALITY_CHECK   YN   NN D='N'    | نقطة فحص جودة
''', uk=[('ROUTING_ID', 'OPERATION_SEQ')], area='engineering')

table('MFG_PRODUCTION_ORDER', 'أوامر الإنتاج', 'Production Orders', scope='C', mix='pub branch doc wf posted status',
      status='PLANNED APPROVED RELEASED IN_PROGRESS PARTIALLY_COMPLETED COMPLETED CLOSED ON_HOLD CANCELLED', cols='''
ITEM_ID         ID   NN >INV_ITEM | المنتج
BOM_ID          ID   NN >MFG_BOM | نسخة BOM المثبتة
ROUTING_ID      ID   >MFG_ROUTING | نسخة المسار المثبتة
PLANNED_QTY     QTY  NN          | الكمية المخططة
COMPLETED_QTY   QTY  NN D=0      | المنتج المقبول
SCRAPPED_QTY    QTY  NN D=0      | الهالك
UOM_ID          ID   NN >INV_UOM | الوحدة
WAREHOUSE_ID    ID   NN >INV_WAREHOUSE | مستودع الاستلام
SITE_ID         ID   >ORG_BUSINESS_SITE | المصنع
SALES_ORDER_ID  ID   >SAL_ORDER  | أمر البيع المصدر
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
PLANNED_START   TS               | البداية المخططة
PLANNED_END     TS               | النهاية المخططة
ACTUAL_START    TS               | البداية الفعلية
ACTUAL_END      TS               | النهاية الفعلية
ESTIMATED_COST  AMT              | التكلفة التقديرية
ACTUAL_COST     AMT  @CALC       | التكلفة الفعلية
HOLD_REASON     V1000            | سبب الإيقاف/الإلغاء
SOURCE_WAREHOUSE_ID ID >INV_WAREHOUSE | مستودع صرف الخامات
LOT_NO          V100             | دفعة المنتج
EXPIRY_DATE     DATE             | انتهاء صلاحية المنتج
PRIORITY        CODE NN D='NORMAL' IN:LOW,NORMAL,HIGH,URGENT | الأولوية
REQUIRES_QC     YN   NN D='N'    | يتطلب فحص جودة قبل الاستلام
PARENT_ORDER_ID ID   >MFG_PRODUCTION_ORDER | الأمر الأب (مكون نصف مصنع)
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
STD_UNIT_COST   RATE             | التكلفة المعيارية للوحدة عند الإطلاق
STD_COST_DETAIL JSON             | التكلفة المعيارية للوحدة لكل عنصر
NOTES           V1000            | ملاحظات
''', ix=[('TENANT_ID', 'COMPANY_ID', 'STATUS_CODE')], area='execution')

table('MFG_ORDER_MATERIAL', 'مواد أمر الإنتاج', 'Order Material Requirements', scope='C', cols='''
ORDER_ID        ID   NN >MFG_PRODUCTION_ORDER | الأمر
BOM_LINE_ID     ID   >MFG_BOM_LINE | سطر BOM
ITEM_ID         ID   NN >INV_ITEM | المادة (أو البديل المعتمد)
REQUIRED_QTY    QTY  NN          | المطلوب
RESERVED_QTY    QTY  NN D=0      | المحجوز
ISSUED_QTY      QTY  NN D=0      | المصروف
RETURNED_QTY    QTY  NN D=0      | المرتجع
UOM_ID          ID   NN >INV_UOM | الوحدة
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع الصرف
IS_SUBSTITUTE   YN   NN D='N'    | بديل معتمد
STD_UNIT_COST   RATE             | التكلفة المعيارية للوحدة عند الإطلاق
ISSUED_COST     AMT  NN D=0      | تكلفة المصروف الفعلية
OPERATION_SEQ   INT              | العملية المستهلكة
''', ix=[('TENANT_ID', 'ORDER_ID')], area='execution')

table('MFG_ORDER_OPERATION', 'عمليات أمر الإنتاج', 'Order Operations', scope='C', mix='status', status='PENDING IN_PROGRESS COMPLETED SKIPPED', cols='''
ORDER_ID        ID   NN >MFG_PRODUCTION_ORDER | الأمر
OPERATION_SEQ   INT  NN          | التسلسل
WORK_CENTER_ID  ID   NN >MFG_WORK_CENTER | مركز العمل
PLANNED_MINUTES QTY              | المخطط
ACTUAL_MINUTES  QTY  NN D=0      | الفعلي
GOOD_QTY        QTY  NN D=0      | المقبول
REWORK_QTY      QTY  NN D=0      | إعادة العمل
DOWNTIME_MINUTES QTY NN D=0      | التوقف
DESCRIPTION     V500             | وصف العملية
SETUP_MINUTES   QTY  NN D=0      | زمن الإعداد المخطط
RUN_MINUTES_PER_UNIT QTY NN D=0  | زمن التشغيل للوحدة
SCRAP_QTY       QTY  NN D=0      | الهالك
QUALITY_CHECK   YN   NN D='N'    | نقطة فحص جودة
''', uk=[('ORDER_ID', 'OPERATION_SEQ')], area='execution')

table('MFG_ORDER_OUTPUT', 'استلام الإنتاج', 'Production Output Receipts', scope='C', mix='status', status='PENDING_QUALITY ACCEPTED REJECTED POSTED', cols='''
ORDER_ID        ID   NN >MFG_PRODUCTION_ORDER | الأمر
ITEM_ID         ID   NN >INV_ITEM | المنتج/المنتج المشترك
OUTPUT_TYPE     CODE NN D='MAIN' IN:MAIN,CO_PRODUCT,BY_PRODUCT,SCRAP | النوع
QUANTITY        QTY  NN          | الكمية
LOT_ID          ID   >INV_LOT    | الدفعة
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة الاستلام
IDEMPOTENCY_KEY V100 NN          | منع مضاعفة الحركة عند إعادة الإرسال
OUTPUT_DATE     DATE             | تاريخ الإنتاج
LOT_NO          V100             | رقم الدفعة
EXPIRY_DATE     DATE             | الانتهاء
UNIT_COST       RATE             | تكلفة الوحدة
TOTAL_COST      AMT              | التكلفة
''', uk=[('TENANT_ID', 'IDEMPOTENCY_KEY')], area='execution',
      purpose='المنتج تحت الفحص لا يعد متاحاً للبيع قبل قبول الجودة')

table('MFG_QUALITY_INSPECTION', 'فحوصات الجودة', 'Quality Inspections', scope='C', mix='status', status='PENDING PASSED FAILED CONDITIONAL', cols='''
ORDER_ID        ID   >MFG_PRODUCTION_ORDER | الأمر
OUTPUT_ID       ID   >MFG_ORDER_OUTPUT | الإنتاج
PUR_RECEIPT_LINE_ID ID >PUR_RECEIPT_LINE | أو استلام مشتريات
INSPECTED_QTY   QTY  NN          | المفحوص
PASSED_QTY      QTY  NN D=0      | الناجح
FAILED_QTY      QTY  NN D=0      | المرفوض
RESULTS         JSON             | نتائج القياسات
INSPECTION_DATE DATE             | تاريخ الفحص
NOTES           V1000            | ملاحظات الفاحص
INSPECTOR_EMPLOYEE_ID ID >HR_EMPLOYEE | الفاحص
''', area='quality')

table('MFG_WIP_COST', 'تكاليف العمل تحت التشغيل', 'WIP Cost Accumulation', scope='C', mix='src', cols='''
ORDER_ID        ID   NN >MFG_PRODUCTION_ORDER | الأمر
OPERATION_SEQ   INT              | العملية
COST_ELEMENT    CODE NN IN:MATERIAL,LABOR,MACHINE,OVERHEAD,SUBCONTRACT,SCRAP | عنصر التكلفة
AMOUNT          AMT  NN          | المبلغ
COST_DATE       DATE NN          | التاريخ
ACCOUNTING_EVENT_ID ID >ACE_ACCOUNTING_EVENT | الحدث المحاسبي
ENTRY_TYPE      CODE NN D='CHARGE' IN:CHARGE,RELIEF,VARIANCE | تحميل على الأمر / تخفيض بالإنتاج المستلم / تسوية الانحراف
ITEM_ID         ID   >INV_ITEM   | الصنف
QUANTITY        QTY              | الكمية
MINUTES         QTY              | الدقائق
DESCRIPTION     V500             | البيان
''', ix=[('TENANT_ID', 'ORDER_ID')], area='costing')

table('MFG_VARIANCE', 'انحرافات التكلفة', 'Production Variances', scope='C', mix='posted', cols='''
ORDER_ID        ID   NN >MFG_PRODUCTION_ORDER | الأمر
VARIANCE_TYPE   CODE NN IN:MATERIAL_USAGE,MATERIAL_PRICE,LABOR_EFFICIENCY,LABOR_RATE,OVERHEAD,YIELD,SCRAP_ABNORMAL | النوع
STANDARD_AMOUNT AMT              | المعياري
ACTUAL_AMOUNT   AMT              | الفعلي
VARIANCE_AMOUNT AMT  NN          | الانحراف
''', area='costing')
