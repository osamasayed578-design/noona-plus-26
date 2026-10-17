from model.dsl import module, table

module(12, 'PUR', 'المشتريات', 'Procurement', 'NOONA_PROCUREMENT_PKG',
       'Purchase Request → RFQ → Supplier Quotation → Evaluation/Award → Purchase Order → Receiving/'
       'Service Acceptance → Supplier Invoice → Payment مع كشف تجزئة الطلبات وفصل الصلاحيات والمرتجعات.')

PR_STATUS = 'DRAFT SUBMITTED APPROVED PARTIALLY_ORDERED ORDERED REJECTED CANCELLED CLOSED'

table('PUR_REQUISITION', 'طلبات الشراء', 'Purchase Requisitions', scope='C', mix='pub branch doc wf status', status=PR_STATUS, cols='''
REQUESTER_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | الطالب
ORG_UNIT_ID     ID   >ORG_UNIT   | الوحدة الطالبة
PURCHASE_TYPE   CODE NN D='GOODS' IN:GOODS,SERVICES,ASSET,PROJECT,URGENT,FRAMEWORK_CALL_OFF | النوع
REQUIRED_DATE   DATE             | التاريخ المطلوب
JUSTIFICATION   V4000            | المبرر
CURRENCY_CODE   CUR  NN          | العملة
ESTIMATED_TOTAL AMT              | الإجمالي التقديري
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
REVISION_NO     INT  NN D=1      | المراجعة
SPLIT_CHECK_FLAG YN  NN D='N' @SYS | اشتباه تجزئة لتجاوز حدود السلطة
''', area='requisition')

table('PUR_REQUISITION_LINE', 'أسطر طلبات الشراء', 'Requisition Lines', scope='C', mix='status', status='OPEN PARTIALLY_ORDERED ORDERED CANCELLED', cols='''
REQUISITION_ID  ID   NN >PUR_REQUISITION | الطلب
LINE_NO         INT  NN          | السطر
ITEM_ID         ID   >INV_ITEM   | الصنف
DESCRIPTION     V1000 NN         | الوصف
QUANTITY        QTY  NN          | الكمية
UOM_ID          ID   NN >INV_UOM | الوحدة
ESTIMATED_PRICE AMT              | السعر التقديري
WAREHOUSE_ID    ID   >INV_WAREHOUSE | مستودع التسليم
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
WBS_ID          ID   >PRJ_WBS    | بند العمل
BUDGET_LINE_ID  ID   >GL_BUDGET_LINE | بند الموازنة
ORDERED_QTY     QTY  NN D=0      | الكمية المطلوبة بأوامر
''', uk=[('REQUISITION_ID', 'LINE_NO')], area='requisition')

table('PUR_RFQ', 'طلبات عروض الأسعار', 'Requests for Quotation', scope='C', mix='doc wf conf status',
      status='DRAFT PUBLISHED CLOSED UNDER_EVALUATION AWARDED CANCELLED', cols='''
TITLE           V500 NN          | العنوان
RFQ_TYPE        CODE NN D='RFQ' IN:RFQ,RFP,TENDER,DIRECT | النوع
CLOSING_AT      TS   NN          | موعد الإغلاق (يمنع الاطلاع المبكر)
OPENED_AT       TS               | وقت فتح العروض
COMMITTEE_ID    ID   >ORG_COMMITTEE | لجنة العطاءات
CURRENCY_CODE   CUR  NN          | العملة
EVALUATION_METHOD CODE NN D='LOWEST_COMPLIANT' IN:LOWEST_COMPLIANT,WEIGHTED_SCORE,QUALITY_BASED | طريقة التقييم
''', area='sourcing')

table('PUR_RFQ_LINE', 'أسطر طلب العروض', 'RFQ Lines', scope='C', cols='''
RFQ_ID          ID   NN >PUR_RFQ | الطلب
LINE_NO         INT  NN          | السطر
REQUISITION_LINE_ID ID >PUR_REQUISITION_LINE | سطر طلب الشراء
ITEM_ID         ID   >INV_ITEM   | الصنف
DESCRIPTION     V1000 NN         | الوصف
QUANTITY        QTY  NN          | الكمية
UOM_ID          ID   NN >INV_UOM | الوحدة
''', uk=[('RFQ_ID', 'LINE_NO')], area='sourcing')

table('PUR_RFQ_SUPPLIER', 'الموردون المدعوون', 'RFQ Invited Suppliers', scope='C', mix='status', status='INVITED DECLINED RESPONDED DISQUALIFIED', cols='''
RFQ_ID          ID   NN >PUR_RFQ | الطلب
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | المورد
INVITED_AT      TS               | وقت الدعوة
''', uk=[('RFQ_ID', 'SUPPLIER_ACCOUNT_ID')], area='sourcing')

table('PUR_QUOTATION', 'عروض الموردين', 'Supplier Quotations', scope='C', mix='cur conf status',
      status='RECEIVED SEALED OPENED COMPLIANT NON_COMPLIANT AWARDED REJECTED WITHDRAWN', cols='''
RFQ_ID          ID   NN >PUR_RFQ | الطلب
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | المورد
QUOTATION_NO    V100             | رقم عرض المورد
RECEIVED_AT     TS   NN          | وقت الاستلام
VALID_UNTIL     DATE             | الصلاحية
TOTAL_AMOUNT    AMT              | الإجمالي
DELIVERY_DAYS   INT              | مدة التوريد
DOCUMENT_ID     ID   >DMS_DOCUMENT | المستند
IS_LATE         YN   NN D='N'    | وصل بعد الإغلاق
''', uk=[('RFQ_ID', 'SUPPLIER_ACCOUNT_ID')], area='sourcing')

table('PUR_QUOTATION_LINE', 'أسطر عروض الموردين', 'Quotation Lines', scope='C', cols='''
QUOTATION_ID    ID   NN >PUR_QUOTATION | العرض
RFQ_LINE_ID     ID   NN >PUR_RFQ_LINE | سطر الطلب
UNIT_PRICE      AMT  NN          | السعر
QUANTITY        QTY  NN          | الكمية
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
REMARKS         V1000            | ملاحظات
''', uk=[('QUOTATION_ID', 'RFQ_LINE_ID')], area='sourcing')

table('PUR_EVALUATION_CRITERION', 'معايير التقييم', 'Evaluation Criteria', scope='C', mix='sort', cols='''
RFQ_ID          ID   NN >PUR_RFQ | الطلب
CRITERION_TYPE  CODE NN IN:TECHNICAL,FINANCIAL,COMPLIANCE,DELIVERY,QUALITY,LOCAL_CONTENT | النوع
NAME_AR         NAME NN          | المعيار
WEIGHT_PCT      PCT  NN          | الوزن (يحدد قبل فتح العروض)
''', area='sourcing')

table('PUR_EVALUATION_SCORE', 'درجات التقييم', 'Evaluation Scores', scope='C', append=True, cols='''
QUOTATION_ID    ID   NN >PUR_QUOTATION | العرض
CRITERION_ID    ID   NN >PUR_EVALUATION_CRITERION | المعيار
EVALUATOR_MEMBER_ID ID NN >SEC_USER_MEMBERSHIP | المقيم
SCORE           NUM  NN          | الدرجة
COMMENTS        V1000            | الملاحظات
''', area='sourcing')

table('PUR_AWARD', 'قرارات الترسية', 'Award Decisions', scope='C', mix='wf status', status='DRAFT APPROVED REJECTED CANCELLED', cols='''
RFQ_ID          ID   NN >PUR_RFQ | الطلب
QUOTATION_ID    ID   NN >PUR_QUOTATION | العرض الفائز
JUSTIFICATION   V4000 NN         | سبب الاختيار (أقل سعر ليس ترسية تلقائية)
AWARDED_AMOUNT  AMT  NN          | قيمة الترسية
DECIDED_AT      TS               | تاريخ القرار
''', area='sourcing')

table('PUR_ORDER', 'أوامر الشراء', 'Purchase Orders', scope='C', mix='pub branch doc cur wf status',
      status='DRAFT SUBMITTED APPROVED ISSUED ACKNOWLEDGED PARTIALLY_RECEIVED RECEIVED INVOICED CLOSED CANCELLED', cols='''
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | المورد
ORDER_TYPE      CODE NN D='STANDARD' IN:STANDARD,BLANKET,CONTRACT,SERVICE,CALL_OFF | النوع
PARENT_ORDER_ID ID   >PUR_ORDER  | اتفاقية الإطار الأم
AWARD_ID        ID   >PUR_AWARD  | الترسية
PAYMENT_TERM_ID ID   >REF_PAYMENT_TERM | شروط الدفع
DELIVERY_WAREHOUSE_ID ID >INV_WAREHOUSE | مستودع التسليم
PROJECT_ID      ID   >PRJ_PROJECT | المشروع
REVISION_NO     INT  NN D=0      | رقم المراجعة (Amendment)
SUBTOTAL        AMT  NN D=0      | قبل الضريبة
TAX_AMOUNT      AMT  NN D=0      | الضريبة
TOTAL_AMOUNT    AMT  NN D=0      | الإجمالي
MAX_TOTAL_AMOUNT AMT             | سقف اتفاقية الإطار
RETENTION_PCT   PCT              | نسبة المحتجز
PROMISED_DATE   DATE             | تاريخ التوريد المتفق
''', ix=[('TENANT_ID', 'COMPANY_ID', 'SUPPLIER_ACCOUNT_ID', 'STATUS_CODE')], area='order')

table('PUR_ORDER_LINE', 'أسطر أوامر الشراء', 'Purchase Order Lines', scope='C', mix='status', status='OPEN PARTIALLY_RECEIVED RECEIVED CLOSED CANCELLED', cols='''
ORDER_ID        ID   NN >PUR_ORDER | الأمر
LINE_NO         INT  NN          | السطر
REQUISITION_LINE_ID ID >PUR_REQUISITION_LINE | سطر الطلب
ITEM_ID         ID   >INV_ITEM   | الصنف
DESCRIPTION     V1000 NN         | الوصف
QUANTITY        QTY  NN          | الكمية
UOM_ID          ID   NN >INV_UOM | الوحدة
UNIT_PRICE      AMT  NN          | السعر
DISCOUNT_PCT    PCT              | الخصم
TAX_CODE_ID     ID   >LOC_TAX_CODE | الضريبة
LINE_AMOUNT     AMT  NN          | المبلغ
RECEIVED_QTY    QTY  NN D=0      | المستلم
ACCEPTED_QTY    QTY  NN D=0      | المقبول
INVOICED_QTY    QTY  NN D=0      | المفوتر
RETURNED_QTY    QTY  NN D=0      | المرتجع
PRICE_TOLERANCE_PCT PCT          | سماحية السعر
QTY_TOLERANCE_PCT PCT            | سماحية الكمية
NEED_BY_DATE    DATE             | تاريخ الحاجة
COST_CENTER_ID  ID   >GL_COST_CENTER | مركز التكلفة
WBS_ID          ID   >PRJ_WBS    | بند العمل
EXPENSE_ACCOUNT_ID ID >GL_ACCOUNT | حساب المصروف للخدمات
''', uk=[('ORDER_ID', 'LINE_NO')], area='order')

table('PUR_ORDER_REVISION', 'مراجعات أوامر الشراء', 'Purchase Order Revisions', scope='C', append=True, cols='''
ORDER_ID        ID   NN >PUR_ORDER | الأمر
REVISION_NO     INT  NN          | المراجعة
CHANGE_REASON   V1000 NN         | السبب
ORDER_SNAPSHOT  JSON NN          | لقطة الأمر قبل التعديل
''', uk=[('ORDER_ID', 'REVISION_NO')], area='order')

table('PUR_RECEIPT', 'الاستلام وقبول الخدمات', 'Receipts & Service Acceptance', scope='C', mix='pub branch doc wf status',
      status='DRAFT RECEIVED QUALITY_CHECK ACCEPTED PARTIALLY_ACCEPTED REJECTED POSTED CANCELLED', cols='''
ORDER_ID        ID   >PUR_ORDER  | الأمر
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | المورد
RECEIPT_TYPE    CODE NN D='GOODS' IN:GOODS,SERVICE,PROGRESS | النوع
WAREHOUSE_ID    ID   >INV_WAREHOUSE | المستودع
DELIVERY_NOTE_NO V100            | رقم إذن التسليم
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة المخزون
''', area='receiving', purpose='يفصل الاستلام المادي عن قبول الجودة وأثر المخزون')

table('PUR_RECEIPT_LINE', 'أسطر الاستلام', 'Receipt Lines', scope='C', cols='''
RECEIPT_ID      ID   NN >PUR_RECEIPT | الاستلام
LINE_NO         INT  NN          | السطر
ORDER_LINE_ID   ID   >PUR_ORDER_LINE | سطر الأمر
ITEM_ID         ID   >INV_ITEM   | الصنف
RECEIVED_QTY    QTY  NN          | المستلم
ACCEPTED_QTY    QTY  NN D=0      | المقبول
REJECTED_QTY    QTY  NN D=0      | المرفوض
UOM_ID          ID   NN >INV_UOM | الوحدة
LOCATION_ID     ID   >INV_LOCATION | الموقع
LOT_ID          ID   >INV_LOT    | الدفعة
QUALITY_STATUS  CODE NN D='PENDING' IN:PENDING,PASSED,FAILED,WAIVED | الجودة
REJECT_REASON   V500             | سبب الرفض
INVOICED_QTY    QTY  NN D=0      | المفوتر
''', uk=[('RECEIPT_ID', 'LINE_NO')], chk=['ACCEPTED_QTY + REJECTED_QTY <= RECEIVED_QTY'], area='receiving')

table('PUR_RETURN', 'مرتجعات المشتريات', 'Purchase Returns', scope='C', mix='doc wf status', status='DRAFT APPROVED SHIPPED CREDITED CLOSED CANCELLED', cols='''
SUPPLIER_ACCOUNT_ID ID NN >AP_SUPPLIER_ACCOUNT | المورد
RECEIPT_ID      ID   >PUR_RECEIPT | الاستلام الأصلي
REASON_CODE     CODE NN          | السبب
INV_TRANSACTION_ID ID >INV_TRANSACTION | حركة المخزون
AP_CREDIT_MEMO_ID ID >AP_INVOICE | الإشعار الدائن من المورد
''', area='return')

table('PUR_RETURN_LINE', 'أسطر مرتجعات المشتريات', 'Purchase Return Lines', scope='C', cols='''
RETURN_ID       ID   NN >PUR_RETURN | المرتجع
LINE_NO         INT  NN          | السطر
RECEIPT_LINE_ID ID   NN >PUR_RECEIPT_LINE | سطر الاستلام
QUANTITY        QTY  NN          | الكمية (لا تتجاوز المقبول بعد المرتجعات السابقة)
UOM_ID          ID   NN >INV_UOM | الوحدة
LOT_ID          ID   >INV_LOT    | الدفعة
SERIAL_ID       ID   >INV_SERIAL | الرقم التسلسلي
''', uk=[('RETURN_ID', 'LINE_NO')], chk=['QUANTITY > 0'], area='return')
