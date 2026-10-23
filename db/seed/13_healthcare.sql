-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة للمستشفيات والمراكز الطبية (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   * فئة الحدث المحاسبي لفاتورة الزيارة (حصة المريض وحصة الجهة والضريبة والإيراد حسب نوع الخدمة) ورفض المطالبات
--   * نوع قيد ومصدر قيود الخدمات الطبية
-- الأقسام والخدمات والجهات والأسعار خاصة بالمؤسسة وتنشأ عند «تجهيز المستشفى».
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO ace_event_class e
  USING (SELECT 'HIS_INVOICE_POSTED' code, 'فاتورة زيارة طبية' name_ar, 'Medical visit invoice' name_en, 'HIS_INVOICE' ent FROM dual
         UNION ALL SELECT 'HIS_INVOICE_CANCELLED', 'إلغاء فاتورة زيارة طبية', 'Medical invoice cancelled', 'HIS_INVOICE' FROM dual
         UNION ALL SELECT 'HIS_CLAIM_REJECTION', 'رفض مطالبات التأمين', 'Insurance claim rejection', 'HIS_CLAIM_BATCH' FROM dual
         UNION ALL SELECT 'HIS_COMMISSION_ACCRUED', 'استحقاق عمولات الأطباء', 'Doctor commission accrual', 'HIS_COMMISSION' FROM dual) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, 'HIS', x.ent, 'OUTBOX', 'Y', 'SYSTEM');

  MERGE INTO gl_journal_type t
  USING (SELECT 'MEDICAL' code, 'قيد خدمات طبية' name_ar, 'Medical services' name_en, 930 o,
                'فواتير الزيارات: حصة المريض وحصة شركات التأمين والجهات المتعاقدة والإيرادات الطبية' dsc FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en, t.sort_order = x.o, t.description = x.dsc
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, type_group, module_code, allow_manual, is_opening, is_adjustment,
                                 auto_reverse, exclude_from_pl, requires_reference, is_active, sort_order, description, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'SYSTEM', 'HIS', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', x.o, x.dsc, 'SYSTEM');

  MERGE INTO gl_journal_source s
  USING (SELECT 'MEDICAL' code, 'الخدمات الطبية' name_ar, 'Medical services' name_en, 'HIS' mdl FROM dual) x
     ON (s.tenant_id IS NULL AND s.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, module_code, allow_manual, requires_approval, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.mdl, 'N', 'N', 'Y', 'SYSTEM');
  -- تنبيهات التمريض: موعد الجرعة ومهام المتابعة للممرضين المناوبين
  MERGE INTO ntf_event_type n
  USING (SELECT 'HIS_DOSE_DUE' code, 'موعد جرعة دواء لمريض منوم' name_ar, 'Medication dose due' name_en FROM dual
         UNION ALL SELECT 'HIS_CARE_DUE', 'موعد متابعة تمريضية', 'Nursing care task due' FROM dual) x
     ON (n.code = x.code)
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, module_code, category, is_mandatory, default_channels)
        VALUES (x.code, x.name_ar, x.name_en, 'HIS', 'ACTION_REQUIRED', 'N', 'IN_APP');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
