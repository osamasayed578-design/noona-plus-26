-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة لسلسلة الإمداد والمبيعات (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   أنواع حركات المخزون، ضريبة القيمة المضافة (أساسية 15%، صفرية، معفاة، خارج النطاق)، فئات الأحداث المحاسبية
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO inv_txn_type t
  USING (SELECT 'OPENING' code, 'رصيد افتتاحي للمخزون' name_ar, 'Opening stock' name_en, 'ADJUSTMENT_IN' cls, 1 sg, 'N' rsn FROM dual
         UNION ALL SELECT 'PURCHASE_RECEIPT', 'استلام مشتريات', 'Purchase receipt', 'RECEIPT', 1, 'N' FROM dual
         UNION ALL SELECT 'PURCHASE_RETURN', 'مرتجع مشتريات', 'Purchase return', 'RETURN_OUT', -1, 'Y' FROM dual
         UNION ALL SELECT 'SALES_ISSUE', 'صرف مبيعات', 'Sales issue', 'ISSUE', -1, 'N' FROM dual
         UNION ALL SELECT 'SALES_RETURN', 'مرتجع مبيعات', 'Sales return', 'RETURN_IN', 1, 'Y' FROM dual
         UNION ALL SELECT 'POS_ISSUE', 'صرف نقطة بيع', 'POS issue', 'ISSUE', -1, 'N' FROM dual
         UNION ALL SELECT 'POS_RETURN', 'مرتجع نقطة بيع', 'POS return', 'RETURN_IN', 1, 'Y' FROM dual
         UNION ALL SELECT 'ADJ_IN', 'تسوية بالزيادة', 'Adjustment in', 'ADJUSTMENT_IN', 1, 'Y' FROM dual
         UNION ALL SELECT 'ADJ_OUT', 'تسوية بالنقص (عجز)', 'Adjustment out', 'ADJUSTMENT_OUT', -1, 'Y' FROM dual
         UNION ALL SELECT 'SCRAP', 'إتلاف أو تالف', 'Scrap', 'SCRAP', -1, 'Y' FROM dual
         UNION ALL SELECT 'CONSUMPTION', 'صرف مخزني لمركز تكلفة', 'Issue to cost center', 'ISSUE', -1, 'N' FROM dual
         UNION ALL SELECT 'TRANSFER_OUT', 'تحويل صادر', 'Transfer out', 'TRANSFER_OUT', -1, 'N' FROM dual
         UNION ALL SELECT 'TRANSFER_IN', 'تحويل وارد', 'Transfer in', 'TRANSFER_IN', 1, 'N' FROM dual
         UNION ALL SELECT 'MFG_ISSUE', 'صرف خامات للإنتاج', 'Material issue to production', 'MFG_ISSUE', -1, 'N' FROM dual
         UNION ALL SELECT 'MFG_RECEIPT', 'استلام إنتاج تام', 'Production receipt', 'MFG_RECEIPT', 1, 'N' FROM dual
         UNION ALL SELECT 'MAINT_ISSUE', 'صرف قطع غيار وزيوت للصيانة', 'Issue to maintenance', 'ISSUE', -1, 'N' FROM dual
         UNION ALL SELECT 'MAINT_RETURN', 'مرتجع من الصيانة', 'Return from maintenance', 'RETURN_IN', 1, 'N' FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, txn_class, qty_sign, requires_approval, default_reason_required,
                                 is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.cls, x.sg, 'N', x.rsn, 'Y', 'SYSTEM');

  -- وحدات القياس
  MERGE INTO inv_uom_class c
  USING (SELECT 'COUNT' code, 'العدد' name_ar, 'Count' name_en FROM dual
         UNION ALL SELECT 'WEIGHT', 'الوزن', 'Weight' FROM dual
         UNION ALL SELECT 'VOLUME', 'الحجم', 'Volume' FROM dual
         UNION ALL SELECT 'LENGTH', 'الطول', 'Length' FROM dual
         UNION ALL SELECT 'TIME', 'الوقت', 'Time' FROM dual) x
     ON (c.tenant_id IS NULL AND c.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'Y', 'SYSTEM');
  MERGE INTO inv_uom u
  USING (SELECT x.*, (SELECT id FROM inv_uom_class WHERE tenant_id IS NULL AND code = x.cls) class_id
           FROM (SELECT 'PCS' code, 'قطعة' name_ar, 'Piece' name_en, 'COUNT' cls, 'Y' base, 0 dp FROM dual
                 UNION ALL SELECT 'BOX', 'علبة', 'Box', 'COUNT', 'N', 0 FROM dual
                 UNION ALL SELECT 'CTN', 'كرتون', 'Carton', 'COUNT', 'N', 0 FROM dual
                 UNION ALL SELECT 'PKT', 'باكيت', 'Packet', 'COUNT', 'N', 0 FROM dual
                 UNION ALL SELECT 'STRIP', 'شريط', 'Strip', 'COUNT', 'N', 0 FROM dual
                 UNION ALL SELECT 'BTL', 'عبوة / زجاجة', 'Bottle', 'COUNT', 'N', 0 FROM dual
                 UNION ALL SELECT 'SET', 'طقم', 'Set', 'COUNT', 'N', 0 FROM dual
                 UNION ALL SELECT 'PAIR', 'زوج', 'Pair', 'COUNT', 'N', 0 FROM dual
                 UNION ALL SELECT 'KG', 'كيلوجرام', 'Kilogram', 'WEIGHT', 'Y', 3 FROM dual
                 UNION ALL SELECT 'G', 'جرام', 'Gram', 'WEIGHT', 'N', 2 FROM dual
                 UNION ALL SELECT 'TON', 'طن', 'Ton', 'WEIGHT', 'N', 3 FROM dual
                 UNION ALL SELECT 'L', 'لتر', 'Litre', 'VOLUME', 'Y', 3 FROM dual
                 UNION ALL SELECT 'ML', 'مليلتر', 'Millilitre', 'VOLUME', 'N', 0 FROM dual
                 UNION ALL SELECT 'M', 'متر', 'Metre', 'LENGTH', 'Y', 2 FROM dual
                 UNION ALL SELECT 'HR', 'ساعة', 'Hour', 'TIME', 'Y', 2 FROM dual
                 UNION ALL SELECT 'SRV', 'خدمة', 'Service', 'COUNT', 'N', 0 FROM dual) x) x
     ON (u.tenant_id IS NULL AND u.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, uom_class_id, is_base_of_class, decimal_places, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.class_id, x.base, x.dp, 'Y', 'SYSTEM');

  -- ضريبة القيمة المضافة
  MERGE INTO loc_tax_type t
  USING (SELECT 'VAT' code FROM dual) x ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, tax_category, is_active, created_by)
        VALUES (NULL, 'VAT', 'ضريبة القيمة المضافة', 'Value Added Tax', 'VAT', 'Y', 'SYSTEM');
  MERGE INTO loc_tax_code c
  USING (SELECT x.*, (SELECT id FROM loc_tax_type WHERE tenant_id IS NULL AND code = 'VAT') type_id
           FROM (SELECT 'VAT15' code, 'ضريبة القيمة المضافة 15%' name_ar, 'VAT 15%' name_en, 'STANDARD' nat, 'S' cat, 15 pct FROM dual
                 UNION ALL SELECT 'VAT0', 'نسبة صفرية', 'Zero rated', 'ZERO_RATED', 'Z', 0 FROM dual
                 UNION ALL SELECT 'VATEX', 'معفاة من الضريبة', 'Exempt', 'EXEMPT', 'E', 0 FROM dual
                 UNION ALL SELECT 'VATOS', 'خارج نطاق الضريبة', 'Out of scope', 'OUT_OF_SCOPE', 'O', 0 FROM dual) x) x
     ON (c.tenant_id IS NULL AND c.tax_type_id = x.type_id AND c.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, tax_type_id, tax_nature, calc_method, is_inclusive_default,
                                 recoverable_pct, rounding_level, show_on_invoice, einvoice_category, status_code, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.type_id, x.nat, 'PERCENT', 'N', 100, 'LINE', 'Y', x.cat, 'ACTIVE', 'SYSTEM');
  MERGE INTO loc_tax_rate r
  USING (SELECT c.id tax_code_id, DECODE(c.code, 'VAT15', 15, 0) pct
           FROM loc_tax_code c WHERE c.tenant_id IS NULL AND c.code IN ('VAT15', 'VAT0', 'VATEX', 'VATOS')) x
     ON (r.tax_code_id = x.tax_code_id AND r.version_no = 1)
   WHEN NOT MATCHED THEN INSERT (tenant_id, tax_code_id, version_no, rate_pct, effective_from, created_by)
        VALUES (NULL, x.tax_code_id, 1, x.pct, DATE '2020-07-01', 'SYSTEM');

  -- أحداث محاسبية إضافية
  MERGE INTO ace_event_class e
  USING (SELECT 'POS_SHIFT_CLOSED' code, 'إقفال وردية نقطة بيع' name_ar, 'POS shift closed' name_en, 'SALES' fam, 'POS_SHIFT' ent FROM dual
         UNION ALL SELECT 'PUR_RETURN_POSTED', 'ترحيل مرتجع مشتريات', 'Purchase return posted', 'PURCHASE', 'AP_INVOICE' FROM dual
         UNION ALL SELECT 'MFG_PRODUCTION_POSTED', 'ترحيل إنتاج', 'Production posted', 'MFG', 'INV_TRANSACTION' FROM dual) x
     ON (e.code = x.code)
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, x.fam, x.ent, 'OUTBOX', 'Y', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
