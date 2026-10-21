-- =============================================================================
-- NOONA PLUS ERP | البنوك المحلية (بيانات مشتركة للمنصة TENANT_ID = NULL) - قابل لإعادة التشغيل
-- يشغل بحساب NOONA_OWNER؛ يمكن للمؤسسة إضافة بنوكها الخاصة لاحقاً.
-- =============================================================================
BEGIN
  -- صفوف المنصة المشتركة: وضع النظام لتجاوز سياسة VPD عند التشغيل بعد تفعيلها
  NOONA_CORE_PKG.begin_system;
MERGE INTO ref_bank b
USING (SELECT 'SA-RJHI' code, 'مصرف الراجحي' name_ar, 'Al Rajhi Bank' name_en, 'RJHISARI' swift, '80' lc FROM dual
       UNION ALL SELECT 'SA-NCB', 'البنك الأهلي السعودي', 'Saudi National Bank', 'NCBKSAJE', '10' FROM dual
       UNION ALL SELECT 'SA-RIBL', 'بنك الرياض', 'Riyad Bank', 'RIBLSARI', '20' FROM dual
       UNION ALL SELECT 'SA-SABB', 'البنك السعودي البريطاني (ساب)', 'SAB', 'SABBSARI', '45' FROM dual
       UNION ALL SELECT 'SA-BSFR', 'البنك السعودي الفرنسي', 'Banque Saudi Fransi', 'BSFRSARI', '55' FROM dual
       UNION ALL SELECT 'SA-ARNB', 'البنك العربي الوطني', 'Arab National Bank', 'ARNBSARI', '30' FROM dual
       UNION ALL SELECT 'SA-ALBI', 'بنك البلاد', 'Bank Albilad', 'ALBISARI', '15' FROM dual
       UNION ALL SELECT 'SA-BJAZ', 'بنك الجزيرة', 'Bank AlJazira', 'BJAZSAJE', '60' FROM dual
       UNION ALL SELECT 'SA-INMA', 'مصرف الإنماء', 'Alinma Bank', 'INMASARI', '05' FROM dual
       UNION ALL SELECT 'SA-SIBC', 'البنك السعودي للاستثمار', 'Saudi Investment Bank', 'SIBCSARI', '65' FROM dual
       UNION ALL SELECT 'SA-GULF', 'بنك الخليج الدولي - السعودية', 'Gulf International Bank', 'GULFSARI', '90' FROM dual) s
   ON (b.tenant_id IS NULL AND b.code = s.code)
 WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, country_code, swift_bic, local_bank_code, is_active, created_by)
      VALUES (NULL, s.code, s.name_ar, s.name_en, 'SA', s.swift, s.lc, 'Y', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
