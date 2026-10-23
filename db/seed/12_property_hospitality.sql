-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة للعقارات والضيافة والصيانة (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   * فئات الأحداث المحاسبية للضيافة: رسوم الغرف بالتدقيق الليلي، رسوم وخدمات الفوليو، دفعات النزلاء، التحويل لحساب الشركات
--   * نوع قيد ومصدر قيود الضيافة
--   * إشعار إسناد بلاغ الصيانة
-- فئات خدمات الصيانة خاصة بالمؤسسة (TENANT) وتنشأ عند «تجهيز الصيانة».
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  -- حركات الفوليو مصدر محاسبي لكل سطر (رسوم أو دفعة)
  MERGE INTO ref_entity_type t
  USING (SELECT 'HSP_FOLIO_LINE' code FROM dual) x
     ON (t.entity_type_code = x.code)
   WHEN NOT MATCHED THEN INSERT (entity_type_code, module_code, table_name, name_ar, name_en, allow_dms_link, allow_cor_link, has_company)
        VALUES ('HSP_FOLIO_LINE', 'PRP', 'HSP_FOLIO_LINE', 'حركات الفوليو', 'Folio Lines', 'N', 'N', 'Y');
  MERGE INTO ace_event_class e
  USING (SELECT 'HSP_ROOM_CHARGE' code, 'رسوم الغرف (التدقيق الليلي)' name_ar, 'Room charges (night audit)' name_en, 'HSP_NIGHT_AUDIT' ent FROM dual
         UNION ALL SELECT 'HSP_FOLIO_CHARGE', 'رسوم وخدمات على حساب النزيل', 'Folio charge', 'HSP_FOLIO_LINE' FROM dual
         UNION ALL SELECT 'HSP_FOLIO_PAYMENT', 'دفعة أو استرداد على حساب النزيل', 'Folio payment', 'HSP_FOLIO_LINE' FROM dual
         UNION ALL SELECT 'HSP_FOLIO_TRANSFER', 'تحويل رصيد النزيل لحساب الشركة', 'Folio transfer to city ledger', 'HSP_FOLIO' FROM dual) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, 'PRP', x.ent, 'OUTBOX', 'Y', 'SYSTEM');

  MERGE INTO gl_journal_type t
  USING (SELECT 'HOSPITALITY' code, 'قيد ضيافة' name_ar, 'Hospitality' name_en, 920 o,
                'رسوم الغرف والخدمات ودفعات النزلاء والتحويل لحسابات الشركات' dsc FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en, t.sort_order = x.o, t.description = x.dsc
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, type_group, module_code, allow_manual, is_opening, is_adjustment,
                                 auto_reverse, exclude_from_pl, requires_reference, is_active, sort_order, description, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'SYSTEM', 'PRP', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', x.o, x.dsc, 'SYSTEM');

  MERGE INTO gl_journal_source s
  USING (SELECT 'HOSPITALITY' code, 'الضيافة' name_ar, 'Hospitality' name_en, 'PRP' mdl FROM dual) x
     ON (s.tenant_id IS NULL AND s.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, module_code, allow_manual, requires_approval, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.mdl, 'N', 'N', 'Y', 'SYSTEM');

  MERGE INTO ntf_event_type n
  USING (SELECT 'MNT_ASSIGNED' code, 'بلاغ صيانة مسند' name_ar, 'Maintenance request assigned' name_en FROM dual) x
     ON (n.code = x.code)
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, module_code, category, is_mandatory, default_channels)
        VALUES (x.code, x.name_ar, x.name_en, 'MNT', 'ACTION_REQUIRED', 'N', 'IN_APP');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
