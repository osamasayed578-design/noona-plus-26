-- =============================================================================
-- NOONA PLUS ERP | أنواع المراسلات ونوع مرفق المراسلة (بيانات منصة مشتركة TENANT_ID = NULL) - قابل لإعادة التشغيل
-- يشغل بحساب NOONA_OWNER
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO cor_type t
  USING (SELECT 'INTERNAL_MEMO' code, 'مذكرة داخلية' name_ar, 'Internal memo' name_en, 'INTERNAL' dir FROM dual
         UNION ALL SELECT 'CIRCULAR', 'تعميم', 'Circular', 'INTERNAL' FROM dual
         UNION ALL SELECT 'INCOMING_LETTER', 'خطاب وارد', 'Incoming letter', 'INCOMING' FROM dual
         UNION ALL SELECT 'OUTGOING_LETTER', 'خطاب صادر', 'Outgoing letter', 'OUTGOING' FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, direction, requires_approval, default_confidentiality,
                                 ack_policy, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.dir, 'N', 'INTERNAL', 'NONE', 'Y', 'SYSTEM');
  MERGE INTO dms_document_type t
  USING (SELECT c.id category_id FROM dms_category c WHERE c.tenant_id IS NULL AND c.code = 'COR') x
     ON (t.tenant_id IS NULL AND t.code = 'MAIL_ATTACHMENT')
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, category_id, default_confidentiality, allowed_mime_types,
                                 max_file_mb, allow_ocr, allow_ai_index, is_active, created_by)
        VALUES (NULL, 'MAIL_ATTACHMENT', 'مرفق مراسلة', 'Correspondence attachment', x.category_id, 'INTERNAL', NULL,
                20, 'N', 'N', 'Y', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
