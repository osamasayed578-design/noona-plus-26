-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة للمشروعات والمقاولات (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   * أحداث محاسبية: مستخلص العميل، مستخلص مقاول الباطن، تكلفة مباشرة على المشروع، تحميل العمالة
--   * نوع قيد ومصدر قيود المشروعات
-- الحسابات (المحتجزات والدفعات المقدمة وإيرادات العقود وتكاليف المشروعات) تنشأ لكل شركة عند أول استخدام.
-- =============================================================================
SET DEFINE OFF
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO ace_event_class e
  USING (SELECT x0.* FROM (SELECT 'PRJ_CLAIM_RECEIVABLE' code, 'مستخلص عميل' name_ar, 'Customer progress claim' name_en, 'PRJ_PROGRESS_CLAIM' ent FROM dual
         UNION ALL SELECT 'PRJ_CLAIM_PAYABLE', 'مستخلص مقاول باطن', 'Subcontractor progress claim', 'PRJ_PROGRESS_CLAIM' FROM dual
         UNION ALL SELECT 'PRJ_COST_POSTED', 'تكلفة مباشرة على مشروع', 'Project direct cost', 'PRJ_COST_LINE' FROM dual
         UNION ALL SELECT 'PRJ_LABOR_POSTED', 'تحميل عمالة على مشروع', 'Project labor charge', 'PRJ_TIMESHEET' FROM dual) x0
          JOIN ref_entity_type r ON r.entity_type_code = x0.ent) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, 'PRJ', x.ent, 'OUTBOX', 'Y', 'SYSTEM');

  MERGE INTO gl_journal_type t
  USING (SELECT 'PROJECTS' code, 'قيد مشروعات ومقاولات' name_ar, 'Projects & contracting' name_en, 940 o,
                'المستخلصات (العملاء ومقاولو الباطن) والدفعات المقدمة والمحتجزات وتكاليف المشروعات' dsc FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en, t.sort_order = x.o, t.description = x.dsc
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, type_group, module_code, allow_manual, is_opening, is_adjustment,
                                 auto_reverse, exclude_from_pl, requires_reference, is_active, sort_order, description, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'SYSTEM', 'PRJ', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', x.o, x.dsc, 'SYSTEM');

  MERGE INTO gl_journal_source s
  USING (SELECT 'PROJECTS' code, 'المشروعات والمقاولات' name_ar, 'Projects & contracting' name_en, 'PRJ' mdl FROM dual) x
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
