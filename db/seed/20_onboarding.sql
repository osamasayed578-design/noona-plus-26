-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة لنقل البيانات والأرصدة الافتتاحية (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   * حدث محاسبي لدفعة الأرصدة الافتتاحية (الحسابات والنقدية والعملاء والموردون)، ومصدر قيود «نقل البيانات»
--   * القيد يرحل بنوع «قيد افتتاحي» فيظهر في عمود الرصيد الافتتاحي بميزان المراجعة
-- =============================================================================
SET DEFINE OFF
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO ace_event_class e
  USING (SELECT 'GL_OPENING_BALANCE' code, 'أرصدة افتتاحية مستوردة' name_ar, 'Imported opening balances' name_en,
                'GL_OPENING_BATCH' ent FROM dual) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, 'GL', x.ent, 'OUTBOX', 'Y', 'SYSTEM');

  MERGE INTO gl_journal_source s
  USING (SELECT 'MIGRATION' code, 'نقل البيانات والأرصدة الافتتاحية' name_ar, 'Data migration & opening balances' name_en, 'GL' mdl FROM dual) x
     ON (s.tenant_id IS NULL AND s.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, module_code, allow_manual, requires_approval, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.mdl, 'N', 'N', 'Y', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  ROLLBACK;
  RAISE;
END;
/
