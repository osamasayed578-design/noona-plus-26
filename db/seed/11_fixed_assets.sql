-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة للأصول الثابتة (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   * فئات الأحداث المحاسبية: الاقتناء والإضافة والانخفاض والاستبعاد (الإهلاك FA_DEPRECIATION معرف سابقاً)
--   * أنواع قيود آلية للأصول: اقتناء/إضافة، استبعاد (بيع وتخريد وتبرع وفقد)
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO ace_event_class e
  USING (SELECT 'FA_ASSET_ACQUIRED' code, 'اقتناء ورسملة أصل ثابت' name_ar, 'Fixed asset acquired' name_en, 'FA_TRANSACTION' ent FROM dual
         UNION ALL SELECT 'FA_ASSET_ADJUSTED', 'إضافة أو انخفاض في قيمة أصل', 'Fixed asset adjusted', 'FA_TRANSACTION' FROM dual
         UNION ALL SELECT 'FA_ASSET_DISPOSED', 'بيع أو استبعاد أصل ثابت', 'Fixed asset disposed', 'FA_DISPOSAL' FROM dual) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, 'FA', x.ent, 'OUTBOX', 'Y', 'SYSTEM');

  MERGE INTO gl_journal_type t
  USING (SELECT 'FA_ACQUISITION' code, 'قيد اقتناء أصل' name_ar, 'Asset acquisition' name_en, 900 o,
                'رسملة الأصول الثابتة والإضافات عليها والانخفاض في قيمتها' dsc FROM dual
         UNION ALL SELECT 'FA_DISPOSAL', 'قيد استبعاد أصل', 'Asset disposal', 910,
                'بيع الأصول وتخريدها والتبرع بها وفقدها مع أرباح وخسائر الاستبعاد' FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en, t.sort_order = x.o, t.description = x.dsc
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, type_group, module_code, allow_manual, is_opening, is_adjustment,
                                 auto_reverse, exclude_from_pl, requires_reference, is_active, sort_order, description, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'SYSTEM', 'FA', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', x.o, x.dsc, 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
