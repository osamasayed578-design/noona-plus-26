SET DEFINE OFF
-- وحدة مركز الإدارة والتواصل في سجل الوحدات (أساسية لكل المؤسسات) ونوع إشعار التنبيه المبكر - قابل لإعادة التشغيل
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO plt_module m
  USING (SELECT 'ENG' code FROM dual) x ON (m.module_code = x.code)
   WHEN NOT MATCHED THEN INSERT (module_code, package_no, plsql_package, name_ar, name_en, is_core, sort_order)
        VALUES ('ENG', 37, 'NOONA_ENG_PKG', 'مركز الإدارة والتواصل', 'Management & Engagement Hub', 'Y', 37);
  MERGE INTO ntf_event_type n
  USING (SELECT 'ENG_ALERT' code, 'تنبيه إنذار مبكر' name_ar, 'Early-warning alert' name_en FROM dual) x
     ON (n.code = x.code)
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, module_code, category, is_mandatory, default_channels)
        VALUES (x.code, x.name_ar, x.name_en, 'ENG', 'REMINDER', 'N', 'IN_APP,EMAIL');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
