-- =============================================================================
-- ترقية 53: فصل الاشتراكات — الفنادق (HSP) والمطاعم والكافتيريا (RST) وحدتان مستقلتان،
-- والعقارات والمشاريع عروض منفصلة. المشتركون الحاليون يحتفظون بما كان ظاهراً لهم:
--   HSP يتبع اشتراكهم في PRP (الضيافة كانت ضمن الأملاك)، وRST يتبع اشتراكهم في SAL (المطعم كان ضمن المبيعات)
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO plt_module m
  USING (SELECT 'HSP' code, 34 no, 'NOONA_HSP_PKG' pkg, 'الفنادق والشقق الفندقية والضيافة' n, 'Hotels & Hospitality' e FROM dual
         UNION ALL SELECT 'RST', 35, 'NOONA_RST_PKG', 'المطاعم والكافتيريا', 'Restaurants & Cafeterias' FROM dual) x
     ON (m.module_code = x.code)
   WHEN NOT MATCHED THEN INSERT (module_code, package_no, plsql_package, name_ar, name_en, is_core, sort_order)
        VALUES (x.code, x.no, x.pkg, x.n, x.e, 'N', x.no);
  FOR r IN (SELECT n.id new_id, e.tenant_id, e.is_enabled, e.effective_from, e.effective_to
              FROM plt_entitlement e
              JOIN plt_module o ON o.id = e.module_id
              JOIN plt_module n ON n.module_code = CASE o.module_code WHEN 'PRP' THEN 'HSP' WHEN 'SAL' THEN 'RST' END
             WHERE o.module_code IN ('PRP', 'SAL') AND e.feature_id IS NULL AND e.metric_id IS NULL
               AND TRUNC(SYSDATE) BETWEEN e.effective_from AND NVL(e.effective_to, DATE '9999-12-31')
               AND NOT EXISTS (SELECT 1 FROM plt_entitlement x WHERE x.tenant_id = e.tenant_id AND x.module_id = n.id
                                  AND x.feature_id IS NULL AND x.metric_id IS NULL)) LOOP
    INSERT INTO plt_entitlement (tenant_id, module_id, is_enabled, source_code, effective_from, effective_to)
    VALUES (r.tenant_id, r.new_id, r.is_enabled, 'CONTRACT_OVERRIDE', r.effective_from, r.effective_to);
  END LOOP;
  -- العرض القديم «العقارات والضيافة والمقاولات» صار «المشاريع والمقاولات» فقط: سعره الافتراضي إن لم يعدله مسؤول المنصة
  UPDATE plt_offering SET monthly_price = 299 WHERE code = 'PRJ' AND monthly_price = 349;
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  ROLLBACK;
  RAISE;
END;
/
