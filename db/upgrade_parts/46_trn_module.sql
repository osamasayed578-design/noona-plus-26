-- وحدة النقل والشحن والترحيل في سجل الوحدات (قبل أنواع الكيانات والصلاحيات التي تشير إليها) - قابل لإعادة التشغيل
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO plt_module m
  USING (SELECT 'TRN' code FROM dual) x ON (m.module_code = x.code)
   WHEN NOT MATCHED THEN INSERT (module_code, package_no, plsql_package, name_ar, name_en, is_core, sort_order)
        VALUES ('TRN', 33, 'NOONA_TRN_PKG', 'النقل والشحن والترحيل', 'Transport & Logistics', 'N', 33);
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
