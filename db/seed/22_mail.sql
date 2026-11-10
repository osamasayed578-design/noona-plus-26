-- =============================================================================
-- NOONA PLUS ERP | إعدادات البريد والفوترة (قابل لإعادة التشغيل؛ لا يغير القيم بعد ضبطها)
--   MAIL.*     : يضبطها tools/vm/mail_setup.sh بعد نجاح رسالة التجربة (MAIL.ENABLED = Y)
--   PLATFORM.* : رابط النظام في الرسائل، وبريد تنبيه مسؤول المنصة بالطلبات الجديدة
--   BILLING.*  : فاتورة الاشتراك تصدر من مؤسسة صاحب المنصة باسم الدخول المحدد، بضريبة وحساب إيراد، ومكان التحصيل
-- =============================================================================
SET DEFINE OFF
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO plt_setting_def d
  USING (SELECT 'MAIL.ENABLED' k, 'BOOLEAN' t, 'N' v, 'تفعيل بريد النظام (بعد نجاح رسالة التجربة)' n FROM dual
         UNION ALL SELECT 'MAIL.FROM', 'STRING', 'no-reply@noona.local', 'بريد المرسل' FROM dual
         UNION ALL SELECT 'MAIL.FROM_NAME', 'STRING', 'نونا بلس', 'اسم المرسل' FROM dual
         UNION ALL SELECT 'MAIL.WORKSPACE', 'STRING', 'NOONAPLUS', 'مساحة عمل APEX للإرسال من الوظائف الخلفية' FROM dual
         UNION ALL SELECT 'PLATFORM.BASE_URL', 'STRING', NULL, 'رابط النظام حتى /ords (مثل https://erp.example.com/ords)' FROM dual
         UNION ALL SELECT 'PLATFORM.NOTIFY_EMAIL', 'STRING', NULL, 'بريد مسؤول المنصة لتنبيهات الطلبات الجديدة' FROM dual
         UNION ALL SELECT 'BILLING.SELLER_USERNAME', 'STRING', NULL, 'اسم دخول مسؤول مؤسسة صاحب المنصة (تصدر منها فواتير الاشتراك)' FROM dual
         UNION ALL SELECT 'BILLING.BANK_PLACE', 'STRING', NULL, 'مكان التحصيل للتحويلات المؤكدة (مثل BANK:1)؛ فارغ = فاتورة آجلة' FROM dual
         UNION ALL SELECT 'BILLING.TAX_CODE', 'STRING', 'VAT15', 'رمز ضريبة فاتورة الاشتراك' FROM dual
         UNION ALL SELECT 'BILLING.REVENUE_ACCOUNT', 'STRING', '4101', 'حساب إيراد الاشتراكات' FROM dual) x
     ON (d.setting_key = x.k)
   WHEN MATCHED THEN UPDATE SET d.name_ar = x.n
   WHEN NOT MATCHED THEN INSERT (setting_key, module_code, data_type, default_value, name_ar, min_level, max_level, created_by)
        VALUES (x.k, 'PLT', x.t, x.v, x.n, 'PLATFORM', 'PLATFORM', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  ROLLBACK;
  RAISE;
END;
/
