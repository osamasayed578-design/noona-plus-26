-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة للتصنيع (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   نوع حركة إرجاع الخامات من الإنتاج، وفئات الأحداث المحاسبية لدورة أمر الإنتاج
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO inv_txn_type t
  USING (SELECT 'MFG_RETURN' code, 'إرجاع خامات من الإنتاج' name_ar, 'Material return from production' name_en, 'MFG_RETURN' cls, 1 sg FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, txn_class, qty_sign, requires_approval, default_reason_required,
                                 is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.cls, x.sg, 'N', 'N', 'Y', 'SYSTEM');

  MERGE INTO ace_event_class e
  USING (SELECT 'MFG_MATERIAL_ISSUED' code, 'صرف خامات لأمر إنتاج' name_ar, 'Material issued to production' name_en, 'INV_TRANSACTION' ent FROM dual
         UNION ALL SELECT 'MFG_MATERIAL_RETURNED', 'إرجاع خامات من أمر إنتاج', 'Material returned from production', 'INV_TRANSACTION' FROM dual
         UNION ALL SELECT 'MFG_OPERATION_REPORTED', 'تحميل عمالة وأعباء عملية إنتاج', 'Operation labor and overhead absorbed', 'MFG_WIP_COST' FROM dual
         UNION ALL SELECT 'MFG_OUTPUT_RECEIVED', 'استلام إنتاج تام', 'Production output received', 'MFG_ORDER_OUTPUT' FROM dual
         UNION ALL SELECT 'MFG_QUALITY_INSPECTED', 'نتيجة فحص جودة الإنتاج', 'Production quality inspection', 'MFG_QUALITY_INSPECTION' FROM dual
         UNION ALL SELECT 'MFG_ORDER_CLOSED', 'إقفال أمر إنتاج وتسوية الانحرافات', 'Production order closed', 'MFG_PRODUCTION_ORDER' FROM dual) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, 'MFG', x.ent, 'OUTBOX', 'Y', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
