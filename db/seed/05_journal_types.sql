-- =============================================================================
-- NOONA PLUS ERP | أنواع القيود الافتراضية (بيانات منصة مشتركة TENANT_ID = NULL) - قابل لإعادة التشغيل
-- يدوي: يختاره المحاسب في شاشة القيد. آلي: تولده المستندات المصدر (سندات، فواتير، مخزون، نقاط بيع...)
-- يمكن للمؤسسة إضافة أنواع يدوية خاصة بها من شاشة أنواع القيود.
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO gl_journal_type t
  USING (SELECT 'GENERAL' code, 'قيد يومية عام' name_ar, 'General journal' name_en, 'MANUAL' grp, 'GL' mdl,
                'Y' man, 'N' opn, 'N' adj, 'N' rev, 'N' xpl, 'N' ref, 10 o,
                'القيود اليدوية العادية التي لا تندرج تحت نوع آخر' dsc FROM dual
         UNION ALL SELECT 'OPENING', 'قيد افتتاحي', 'Opening entry', 'MANUAL', 'GL', 'Y', 'Y', 'N', 'N', 'N', 'N', 20,
                'الأرصدة الافتتاحية؛ تاريخه في الفترة الأولى من السنة المالية' FROM dual
         UNION ALL SELECT 'ADJUSTMENT', 'قيد تسوية', 'Adjusting entry', 'MANUAL', 'GL', 'Y', 'N', 'Y', 'N', 'N', 'N', 30,
                'تسويات نهاية الفترة: تصحيح الأرصدة وتحميل الإيرادات والمصروفات على فتراتها' FROM dual
         UNION ALL SELECT 'ACCRUAL', 'قيد استحقاق', 'Accrual', 'MANUAL', 'GL', 'Y', 'N', 'Y', 'Y', 'N', 'N', 40,
                'مصروفات مستحقة وإيرادات مستحقة؛ يعكس آلياً في أول يوم من الفترة التالية' FROM dual
         UNION ALL SELECT 'PREPAYMENT', 'قيد مقدمات وتأجيل', 'Prepayment / deferral', 'MANUAL', 'GL', 'Y', 'N', 'Y', 'N', 'N', 'N', 50,
                'إطفاء المصروفات المقدمة والإيرادات المؤجلة' FROM dual
         UNION ALL SELECT 'DEPRECIATION', 'قيد إهلاك', 'Depreciation', 'MANUAL', 'GL', 'Y', 'N', 'Y', 'N', 'N', 'N', 60,
                'إهلاك الأصول الثابتة وإطفاء غير الملموسة' FROM dual
         UNION ALL SELECT 'PROVISION', 'قيد مخصصات', 'Provision', 'MANUAL', 'GL', 'Y', 'N', 'Y', 'N', 'N', 'N', 70,
                'مخصص الديون المشكوك فيها، مخصص المخزون الراكد، مكافأة نهاية الخدمة' FROM dual
         UNION ALL SELECT 'RECLASS', 'قيد إعادة تبويب وتصحيح', 'Reclassification', 'MANUAL', 'GL', 'Y', 'N', 'Y', 'N', 'N', 'Y', 80,
                'نقل مبلغ بين حسابات أو مراكز تكلفة، وتصحيح خطأ قيد سابق؛ يتطلب رقم القيد المصحح في المرجع' FROM dual
         UNION ALL SELECT 'FX_REVALUATION', 'قيد إعادة تقييم عملات', 'FX revaluation', 'MANUAL', 'GL', 'Y', 'N', 'Y', 'Y', 'N', 'N', 90,
                'فروق تقييم الأرصدة بالعملات الأجنبية في نهاية الفترة؛ يعكس آلياً في بداية الفترة التالية' FROM dual
         UNION ALL SELECT 'ALLOCATION', 'قيد توزيع تكاليف', 'Cost allocation', 'MANUAL', 'GL', 'Y', 'N', 'Y', 'N', 'N', 'N', 100,
                'توزيع التكاليف المشتركة على مراكز التكلفة' FROM dual
         UNION ALL SELECT 'INTERCOMPANY', 'قيد بين الشركات', 'Intercompany', 'MANUAL', 'GL', 'Y', 'N', 'N', 'N', 'N', 'Y', 110,
                'المعاملات مع الشركات الشقيقة داخل المجموعة' FROM dual
         -- آلية من المستندات المصدر
         UNION ALL SELECT 'REVERSAL', 'قيد عكسي', 'Reversal', 'SYSTEM', 'GL', 'N', 'N', 'N', 'N', 'N', 'Y', 200,
                'يولد عند عكس قيد مرحل؛ يحمل رقم القيد المعكوس' FROM dual
         UNION ALL SELECT 'CLOSING', 'قيد إقفال السنة', 'Year-end closing', 'SYSTEM', 'GL', 'N', 'N', 'Y', 'N', 'Y', 'N', 210,
                'إقفال الإيرادات والمصروفات في الأرباح المبقاة' FROM dual
         UNION ALL SELECT 'RECEIPT', 'سند قبض', 'Receipt voucher', 'SYSTEM', 'CSH', 'N', 'N', 'N', 'N', 'N', 'N', 300,
                'من سندات القبض النقدية والبنكية' FROM dual
         UNION ALL SELECT 'PAYMENT', 'سند صرف', 'Payment voucher', 'SYSTEM', 'CSH', 'N', 'N', 'N', 'N', 'N', 'N', 310,
                'من سندات الصرف' FROM dual
         UNION ALL SELECT 'EXPENSE', 'سند مصروفات', 'Expense voucher', 'SYSTEM', 'CSH', 'N', 'N', 'N', 'N', 'N', 'N', 320,
                'من سندات المصروفات المباشرة' FROM dual
         UNION ALL SELECT 'TRANSFER', 'تحويل نقدي', 'Cash transfer', 'SYSTEM', 'CSH', 'N', 'N', 'N', 'N', 'N', 'N', 330,
                'التحويل بين الصناديق والحسابات البنكية' FROM dual
         UNION ALL SELECT 'SALES_INVOICE', 'فاتورة مبيعات', 'Sales invoice', 'SYSTEM', 'SAL', 'N', 'N', 'N', 'N', 'N', 'N', 400,
                'الإيراد وذمة العميل والضريبة' FROM dual
         UNION ALL SELECT 'SALES_RETURN', 'مرتجع مبيعات', 'Sales return', 'SYSTEM', 'SAL', 'N', 'N', 'N', 'N', 'N', 'N', 410,
                'إشعار دائن للعميل' FROM dual
         UNION ALL SELECT 'POS_SALE', 'مبيعات نقاط البيع', 'POS sales', 'SYSTEM', 'SAL', 'N', 'N', 'N', 'N', 'N', 'N', 420,
                'مبيعات نقاط البيع وتحصيلها بطرق السداد المختلفة' FROM dual
         UNION ALL SELECT 'CUSTOMER_RECEIPT', 'تحصيل من عميل', 'Customer receipt', 'SYSTEM', 'SAL', 'N', 'N', 'N', 'N', 'N', 'N', 430,
                'سداد فواتير العملاء' FROM dual
         UNION ALL SELECT 'PURCHASE_INVOICE', 'فاتورة مشتريات', 'Purchase invoice', 'SYSTEM', 'PUR', 'N', 'N', 'N', 'N', 'N', 'N', 500,
                'المشتريات وذمة المورد والضريبة' FROM dual
         UNION ALL SELECT 'PURCHASE_RETURN', 'مرتجع مشتريات', 'Purchase return', 'SYSTEM', 'PUR', 'N', 'N', 'N', 'N', 'N', 'N', 510,
                'إشعار مدين للمورد' FROM dual
         UNION ALL SELECT 'SUPPLIER_PAYMENT', 'سداد لمورد', 'Supplier payment', 'SYSTEM', 'PUR', 'N', 'N', 'N', 'N', 'N', 'N', 520,
                'سداد فواتير الموردين' FROM dual
         UNION ALL SELECT 'INVENTORY', 'حركة مخزون', 'Inventory movement', 'SYSTEM', 'INV', 'N', 'N', 'N', 'N', 'N', 'N', 600,
                'استلام وصرف وتسويات وجرد المخزون وتكلفة المبيعات' FROM dual
         UNION ALL SELECT 'MANUFACTURING', 'قيد إنتاج', 'Manufacturing', 'SYSTEM', 'MFG', 'N', 'N', 'N', 'N', 'N', 'N', 700,
                'صرف الخامات للإنتاج واستلام المنتج التام' FROM dual
         UNION ALL SELECT 'PAYROLL', 'قيد رواتب', 'Payroll', 'SYSTEM', 'PAY', 'N', 'N', 'N', 'N', 'N', 'N', 800,
                'استحقاق الرواتب والبدلات والاستقطاعات' FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en, t.type_group = x.grp, t.module_code = x.mdl,
                                t.allow_manual = x.man, t.is_opening = x.opn, t.is_adjustment = x.adj, t.auto_reverse = x.rev,
                                t.exclude_from_pl = x.xpl, t.requires_reference = x.ref, t.sort_order = x.o, t.description = x.dsc
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, type_group, module_code, allow_manual, is_opening, is_adjustment,
                                 auto_reverse, exclude_from_pl, requires_reference, is_active, sort_order, description, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.grp, x.mdl, x.man, x.opn, x.adj, x.rev, x.xpl, x.ref, 'Y', x.o, x.dsc, 'SYSTEM');
  -- مصادر القيود للوحدات الجديدة
  MERGE INTO gl_journal_source s
  USING (SELECT 'INVENTORY' code, 'المخزون' name_ar, 'Inventory' name_en, 'INV' mdl FROM dual
         UNION ALL SELECT 'POS', 'نقاط البيع', 'Point of sale', 'SAL' FROM dual
         UNION ALL SELECT 'MANUFACTURING', 'التصنيع', 'Manufacturing', 'MFG' FROM dual) x
     ON (s.tenant_id IS NULL AND s.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, module_code, allow_manual, requires_approval, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.mdl, 'N', 'N', 'Y', 'SYSTEM');
  -- القيود السابقة: المصنفة MANUAL أو بلا نوع تصبح «قيد يومية عام»، وقيود السندات تأخذ نوع السند
  UPDATE gl_journal SET journal_category = 'GENERAL' WHERE journal_category = 'MANUAL' OR journal_category IS NULL;
  UPDATE gl_journal j
     SET journal_category = (SELECT CASE t.txn_type WHEN 'RECEIPT' THEN 'RECEIPT' WHEN 'PAYMENT' THEN 'PAYMENT'
                                                    WHEN 'EXPENSE' THEN 'EXPENSE' ELSE 'TRANSFER' END
                               FROM csh_transaction t WHERE t.accounting_event_id = j.accounting_event_id AND ROWNUM = 1)
   WHERE j.journal_category = 'CASH' AND j.accounting_event_id IS NOT NULL
     AND EXISTS (SELECT 1 FROM csh_transaction t WHERE t.accounting_event_id = j.accounting_event_id);
  -- عكس قيد سند: نوعه «قيد عكسي»
  UPDATE gl_journal SET journal_category = 'REVERSAL' WHERE journal_category = 'CASH' AND reversal_of_id IS NOT NULL;
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
