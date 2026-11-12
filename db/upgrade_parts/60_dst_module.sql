-- وحدة التوزيع والمبيعات الميدانية في سجل الوحدات (قبل أنواع الكيانات والصلاحيات) - قابل لإعادة التشغيل
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO plt_module m
  USING (SELECT 'DST' code FROM dual) x ON (m.module_code = x.code)
   WHEN NOT MATCHED THEN INSERT (module_code, package_no, plsql_package, name_ar, name_en, is_core, sort_order)
        VALUES ('DST', 36, 'NOONA_DST_PKG', 'التوزيع والمبيعات الميدانية', 'Distribution & Field Sales', 'N', 36);
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
