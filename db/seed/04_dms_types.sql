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
         UNION ALL SELECT 'COR', 'المراسلات', 'Correspondence', 6 FROM dual
         UNION ALL SELECT 'PTY', 'مستندات وشهادات الأطراف', 'Party documents & certificates', 7 FROM dual) x
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
  -- مستندات وشهادات الموردين والعملاء: لها تاريخ انتهاء وتنبيه قبل الانتهاء
  MERGE INTO dms_document_type t
  USING (SELECT x.code, x.name_ar, x.name_en, c.id category_id, x.days
           FROM (SELECT 'COMMERCIAL_REGISTER' code, 'السجل التجاري' name_ar, 'Commercial registration' name_en, 30 days FROM dual
                 UNION ALL SELECT 'VAT_CERTIFICATE', 'شهادة التسجيل في ضريبة القيمة المضافة', 'VAT certificate', 30 FROM dual
                 UNION ALL SELECT 'ZAKAT_CERTIFICATE', 'شهادة الزكاة والدخل', 'Zakat certificate', 30 FROM dual
                 UNION ALL SELECT 'GOSI_CERTIFICATE', 'شهادة التأمينات الاجتماعية', 'GOSI certificate', 30 FROM dual
                 UNION ALL SELECT 'SAUDIZATION_CERTIFICATE', 'شهادة السعودة (نطاقات)', 'Saudization certificate', 30 FROM dual
                 UNION ALL SELECT 'CHAMBER_CERTIFICATE', 'شهادة الغرفة التجارية', 'Chamber of commerce', 30 FROM dual
                 UNION ALL SELECT 'MUNICIPAL_LICENSE', 'رخصة البلدية', 'Municipal license', 30 FROM dual
                 UNION ALL SELECT 'BANK_LETTER', 'خطاب الحساب البنكي (الآيبان)', 'Bank account letter', NULL FROM dual
                 UNION ALL SELECT 'NATIONAL_ADDRESS', 'العنوان الوطني', 'National address', NULL FROM dual
                 UNION ALL SELECT 'ISO_CERTIFICATE', 'شهادة جودة (ISO)', 'Quality certificate', 60 FROM dual
                 UNION ALL SELECT 'ID_COPY', 'صورة الهوية / الإقامة', 'ID copy', 30 FROM dual
                 UNION ALL SELECT 'AUTHORIZATION_LETTER', 'خطاب تفويض بالتوقيع', 'Signing authorization', 30 FROM dual) x
           JOIN dms_category c ON c.tenant_id IS NULL AND c.code = 'PTY') x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, category_id, default_confidentiality, allowed_mime_types,
                                 max_file_mb, expiry_alert_days, allow_ocr, allow_ai_index, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.category_id, 'CONFIDENTIAL',
                'application/pdf,image/png,image/jpeg,image/tiff,image/webp', 20, x.days, 'N', 'N', 'Y', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
