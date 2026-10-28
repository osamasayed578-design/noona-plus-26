-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة للتطوير العقاري وبيع الوحدات وإدارة الأملاك (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   * أنواع كيانات إضافية للقيود التي تتكرر على نفس المستند (تطبيق العربون، فسخ العقد، سداد العمولة، تسوية التأمين، تحويل المالك)
--   * أحداث محاسبية: العربون ومصادرته، تطبيق العربون على العقد، الاعتراف بالإيراد والتكلفة عند التسليم، فسخ العقد،
--     عمولة الوسيط وسدادها، رسملة تكاليف التطوير، تأمين المستأجر وتسويته، أتعاب الإدارة والتحويل للمالك
--   * نوع قيد ومصدر قيود العقارات
-- الحسابات (العربون والدفعات المقدمة والإيرادات والتأمينات ومستحقات الملاك) تنشأ لكل شركة عند أول استخدام.
-- =============================================================================
SET DEFINE OFF
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO ref_entity_type e
  USING (SELECT 'RE_DEPOSIT_APPLIED' code, 'RE' mdl, 'RE_SALE_CONTRACT' tbl, 'تطبيق عربون الحجز على العقد' name_ar, 'Reservation deposit applied' name_en FROM dual
         UNION ALL SELECT 'RE_CONTRACT_TERMINATION', 'RE', 'RE_SALE_CONTRACT', 'فسخ عقد بيع وحدة', 'Sale contract termination' FROM dual
         UNION ALL SELECT 'RE_COMMISSION_PAYMENT', 'RE', 'RE_BROKER_COMMISSION', 'سداد عمولة وسيط', 'Broker commission payment' FROM dual
         UNION ALL SELECT 'PRP_DEPOSIT_SETTLEMENT', 'PRP', 'PRP_SECURITY_DEPOSIT', 'تسوية تأمين مستأجر', 'Security deposit settlement' FROM dual
         UNION ALL SELECT 'PRP_OWNER_REMITTANCE', 'PRP', 'PRP_OWNER_STATEMENT', 'تحويل صافي المالك', 'Owner remittance' FROM dual) x
     ON (e.entity_type_code = x.code)
   WHEN NOT MATCHED THEN INSERT (entity_type_code, module_code, table_name, name_ar, name_en, allow_dms_link, allow_cor_link, has_company)
        VALUES (x.code, x.mdl, x.tbl, x.name_ar, x.name_en, 'N', 'N', 'Y');

  MERGE INTO ace_event_class e
  USING (SELECT x0.* FROM (SELECT 'RE_RESERVATION_DEPOSIT' code, 'عربون حجز وحدة' name_ar, 'Unit reservation deposit' name_en, 'RE_RESERVATION' ent, 'RE' fam FROM dual
         UNION ALL SELECT 'RE_RESERVATION_FORFEIT', 'مصادرة عربون حجز ملغى', 'Forfeited reservation deposit', 'RE_RESERVATION', 'RE' FROM dual
         UNION ALL SELECT 'RE_DEPOSIT_APPLIED', 'تطبيق العربون على عقد البيع', 'Deposit applied to sale contract', 'RE_DEPOSIT_APPLIED', 'RE' FROM dual
         UNION ALL SELECT 'RE_REVENUE_RECOGNIZED', 'الاعتراف بإيراد وتكلفة وحدة مباعة', 'Unit sale revenue and cost recognized', 'RE_HANDOVER', 'RE' FROM dual
         UNION ALL SELECT 'RE_CONTRACT_TERMINATED', 'فسخ عقد بيع وحدة', 'Unit sale contract terminated', 'RE_CONTRACT_TERMINATION', 'RE' FROM dual
         UNION ALL SELECT 'RE_COMMISSION_ACCRUED', 'استحقاق عمولة وسيط', 'Broker commission accrued', 'RE_BROKER_COMMISSION', 'RE' FROM dual
         UNION ALL SELECT 'RE_COMMISSION_PAID', 'سداد عمولة وسيط', 'Broker commission paid', 'RE_COMMISSION_PAYMENT', 'RE' FROM dual
         UNION ALL SELECT 'RE_COST_CAPITALIZED', 'رسملة تكاليف التطوير على الوحدات', 'Development cost capitalized to units', 'RE_COST_ALLOCATION', 'RE' FROM dual
         UNION ALL SELECT 'PRP_DEPOSIT_RECEIVED', 'استلام تأمين مستأجر', 'Tenant security deposit received', 'PRP_SECURITY_DEPOSIT', 'PRP' FROM dual
         UNION ALL SELECT 'PRP_DEPOSIT_SETTLED', 'رد وخصم تأمين مستأجر', 'Tenant security deposit settled', 'PRP_DEPOSIT_SETTLEMENT', 'PRP' FROM dual
         UNION ALL SELECT 'PRP_OWNER_FEE', 'أتعاب إدارة أملاك', 'Property management fee', 'PRP_OWNER_STATEMENT', 'PRP' FROM dual
         UNION ALL SELECT 'PRP_OWNER_REMITTED', 'تحويل صافي إيرادات المالك', 'Owner net remittance', 'PRP_OWNER_REMITTANCE', 'PRP' FROM dual) x0
          JOIN ref_entity_type r ON r.entity_type_code = x0.ent) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, x.fam, x.ent, 'OUTBOX', 'Y', 'SYSTEM');

  MERGE INTO gl_journal_type t
  USING (SELECT 'REAL_ESTATE' code, 'قيد عقارات وأملاك' name_ar, 'Real estate & property' name_en, 945 o,
                'عربون الحجز وعقود بيع الوحدات والاعتراف بالإيراد والعمولات وتأمينات المستأجرين وحسابات الملاك' dsc FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en, t.sort_order = x.o, t.description = x.dsc
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, type_group, module_code, allow_manual, is_opening, is_adjustment,
                                 auto_reverse, exclude_from_pl, requires_reference, is_active, sort_order, description, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'SYSTEM', 'RE', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', x.o, x.dsc, 'SYSTEM');

  MERGE INTO gl_journal_source s
  USING (SELECT 'REAL_ESTATE' code, 'العقارات وإدارة الأملاك' name_ar, 'Real estate & property' name_en, 'RE' mdl FROM dual) x
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
