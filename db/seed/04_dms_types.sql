-- =============================================================================
-- NOONA PLUS ERP | فئات وأنواع المستندات الافتراضية للأرشيف (بيانات منصة مشتركة TENANT_ID = NULL) - قابل لإعادة التشغيل
-- يشغل بحساب NOONA_OWNER؛ يمكن للمؤسسة إضافة أنواعها الخاصة من تطبيق المستندات.
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO dms_category c
  USING (SELECT 'FIN' code, 'المالية والمحاسبة' name_ar, 'Finance' name_en, 1 o FROM dual
         UNION ALL SELECT 'PUR', 'المشتريات والموردون', 'Purchasing', 2 FROM dual
         UNION ALL SELECT 'SAL', 'المبيعات والعملاء', 'Sales', 3 FROM dual
         UNION ALL SELECT 'HR', 'الموارد البشرية', 'Human Resources', 4 FROM dual
         UNION ALL SELECT 'ADM', 'الإدارة والشؤون القانونية', 'Administration & Legal', 5 FROM dual
         UNION ALL SELECT 'COR', 'المراسلات', 'Correspondence', 6 FROM dual) x
     ON (c.tenant_id IS NULL AND c.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, is_active, sort_order, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'Y', x.o, 'SYSTEM');
  MERGE INTO dms_document_type t
  USING (SELECT x.code, x.name_ar, x.name_en, c.id category_id, x.mime, x.mb, x.conf
           FROM (SELECT 'RECEIPT_VOUCHER' code, 'أصل سند قبض' name_ar, 'Receipt voucher' name_en, 'FIN' cat, 'P' mime, 20 mb, 'INTERNAL' conf FROM dual
                 UNION ALL SELECT 'PAYMENT_VOUCHER', 'أصل سند صرف ومؤيداته', 'Payment voucher', 'FIN', 'P', 20, 'INTERNAL' FROM dual
                 UNION ALL SELECT 'EXPENSE_VOUCHER', 'فاتورة أو إيصال مصروف', 'Expense receipt', 'FIN', 'P', 20, 'INTERNAL' FROM dual
                 UNION ALL SELECT 'JOURNAL_SUPPORT', 'مستند مؤيد لقيد يومية', 'Journal support', 'FIN', 'O', 20, 'INTERNAL' FROM dual
                 UNION ALL SELECT 'BANK_STATEMENT', 'كشف حساب بنكي', 'Bank statement', 'FIN', 'O', 30, 'CONFIDENTIAL' FROM dual
                 UNION ALL SELECT 'SUPPLIER_INVOICE', 'فاتورة مورد', 'Supplier invoice', 'PUR', 'P', 20, 'INTERNAL' FROM dual
                 UNION ALL SELECT 'PURCHASE_ORDER', 'أمر شراء معتمد', 'Purchase order', 'PUR', 'P', 20, 'INTERNAL' FROM dual
                 UNION ALL SELECT 'CUSTOMER_INVOICE', 'فاتورة عميل', 'Customer invoice', 'SAL', 'P', 20, 'INTERNAL' FROM dual
                 UNION ALL SELECT 'CONTRACT', 'عقد', 'Contract', 'ADM', 'O', 50, 'CONFIDENTIAL' FROM dual
                 UNION ALL SELECT 'HR_RECORD', 'مستند موظف', 'Employee document', 'HR', 'O', 20, 'CONFIDENTIAL' FROM dual
                 UNION ALL SELECT 'INCOMING_LETTER', 'خطاب وارد', 'Incoming letter', 'COR', 'O', 20, 'INTERNAL' FROM dual
                 UNION ALL SELECT 'OUTGOING_LETTER', 'خطاب صادر', 'Outgoing letter', 'COR', 'O', 20, 'INTERNAL' FROM dual
                 UNION ALL SELECT 'GENERAL', 'مستند عام', 'General document', 'ADM', 'O', 20, 'INTERNAL' FROM dual) x
           JOIN dms_category c ON c.tenant_id IS NULL AND c.code = x.cat) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, category_id, default_confidentiality, allowed_mime_types,
                                 max_file_mb, allow_ocr, allow_ai_index, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.category_id, x.conf,
                CASE x.mime WHEN 'P' THEN 'application/pdf,image/png,image/jpeg,image/tiff,image/webp'
                     ELSE 'application/pdf,image/png,image/jpeg,image/tiff,image/webp,'
                       || 'application/vnd.openxmlformats-officedocument.wordprocessingml.document,'
                       || 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' END,
                x.mb, 'N', 'N', 'Y', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
