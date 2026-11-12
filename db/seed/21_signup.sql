-- =============================================================================
-- NOONA PLUS ERP | بيانات التسجيل الذاتي (قابل لإعادة التشغيل؛ لا يغير الأسعار بعد تعديلها من لوحة المنصة)
--   * الأنظمة المعروضة للعميل ووحداتها وأسعارها الشهرية الابتدائية (ريال) ومتطلباتها
--   * خصم المدة لكل خطة، وإعدادات التسجيل (وضع الرموز، سعر المستخدم، الضريبة، بيانات التحويل)
-- الأسعار هنا افتراضية للعرض؛ يعدلها مسؤول المنصة من «لوحة المنصة ← التسجيل الذاتي والأسعار».
-- =============================================================================
SET DEFINE OFF
DECLARE
  l_ai NUMBER;
BEGIN
  NOONA_CORE_PKG.begin_system;
  SELECT COUNT(*) INTO l_ai FROM user_objects WHERE object_name = 'NOONA_AI_PKG' AND object_type = 'PACKAGE';
  -- وحدات اشتراك مستقلة داخل تطبيقات قائمة: الفنادق والضيافة (في 139) والمطاعم والكافتيريا (في 133)
  MERGE INTO plt_module m
  USING (SELECT 'HSP' code, 34 no, 'NOONA_HSP_PKG' pkg, 'الفنادق والشقق الفندقية والضيافة' n, 'Hotels & Hospitality' e FROM dual
         UNION ALL SELECT 'RST', 35, 'NOONA_RST_PKG', 'المطاعم والكافتيريا', 'Restaurants & Cafeterias' FROM dual) x
     ON (m.module_code = x.code)
   WHEN NOT MATCHED THEN INSERT (module_code, package_no, plsql_package, name_ar, name_en, is_core, sort_order)
        VALUES (x.code, x.no, x.pkg, x.n, x.e, 'N', x.no);
  MERGE INTO plt_offering o
  USING (SELECT 'FIN' code, 'المالية والمحاسبة' n, 'Finance & Accounting' e, 'دليل الحسابات والقيود والسندات والعملاء والموردين والأصول والضريبة والتقارير' d,
                'fa-calculator' i, 'GL,AR,AP,CSH,FA,BI' m, 299 p, NULL rq, 10 s FROM dual
         UNION ALL SELECT 'SCM', 'المخزون والمشتريات', 'Inventory & Purchasing', 'الأصناف والمستودعات وأوامر الشراء والاستلام وفواتير الموردين', 'fa-truck', 'INV,PUR', 199, 'FIN', 20 FROM dual
         UNION ALL SELECT 'POS', 'المبيعات ونقاط البيع', 'Sales & POS', 'عروض الأسعار وفواتير المبيعات والفاتورة الإلكترونية ونقاط البيع', 'fa-shopping-cart', 'SAL', 199, 'FIN,SCM', 30 FROM dual
         UNION ALL SELECT 'HR', 'الموارد البشرية والرواتب', 'HR & Payroll', 'ملفات الموظفين والعقود والإجازات ومسير الرواتب وحماية الأجور', 'fa-users', 'HR,PAY', 199, NULL, 40 FROM dual
         UNION ALL SELECT 'RST', 'المطاعم والكافتيريا', 'Restaurants & Cafeterias', 'الصالة والطاولات والطلبات وشاشة المطبخ والقائمة والعملاء الآجلون', 'fa-cutlery', 'RST', 149, 'FIN,SCM,POS', 35 FROM dual
         UNION ALL SELECT 'RE', 'العقارات والإيجارات وبيع الوحدات', 'Real Estate & Leasing', 'السجل العقاري وعقود الإيجار والتحصيل وبيع الوحدات والأقساط والصيانة', 'fa-building', 'RE,PRP,MNT', 249, 'FIN', 50 FROM dual
         UNION ALL SELECT 'HSP', 'الفنادق والشقق الفندقية', 'Hotels & Hospitality', 'لوحة الاستقبال والحجوزات والنزلاء والتدبير الفندقي والتدقيق الليلي والصيانة', 'fa-bed', 'HSP,MNT', 249, 'FIN', 52 FROM dual
         UNION ALL SELECT 'PRJ', 'المشاريع والمقاولات', 'Projects & Contracting', 'المشاريع والميزانيات والمستخلصات ونسبة الإنجاز والضمانات والمعدات', 'fa-road', 'PRJ', 299, 'FIN', 55 FROM dual
         UNION ALL SELECT 'HIS', 'المستشفيات والمراكز الطبية', 'Hospital & Clinics', 'المواعيد والعيادات والتنويم والمختبر والصيدلية ومطالبات التأمين', 'fa-hospital-o', 'HIS', 599, 'FIN,SCM', 60 FROM dual
         UNION ALL SELECT 'AUTO', 'مراكز خدمة السيارات', 'Auto Service Centers', 'بطاقات العمل وقطع الغيار والفنيين ومطالبات التأمين', 'fa-car', 'AUT', 249, 'FIN,SCM,POS', 70 FROM dual
         UNION ALL SELECT 'TRN', 'النقل والشحن', 'Transport & Logistics', 'الأسطول والرحلات والشحنات والسائقين', 'fa-truck', 'TRN', 249, 'FIN', 80 FROM dual
         UNION ALL SELECT 'MFG', 'التصنيع', 'Manufacturing', 'قوائم المواد ومسارات التصنيع وأوامر الإنتاج والجودة والتكاليف', 'fa-industry', 'MFG,QA', 349, 'FIN,SCM', 90 FROM dual
         UNION ALL SELECT 'API', 'التكاملات وواجهات API', 'Integrations & API', 'واجهات REST وWebhooks والمتجر الإلكتروني وكشوف البنوك', 'fa-plug', 'API', 149, 'FIN', 100 FROM dual
         UNION ALL SELECT 'AI', 'مساعد نونا الذكي', 'Noona AI Assistant', 'اسأل نونا والملخص الذكي والتحليلات والتنبؤات', 'fa-magic', 'AI', 199, NULL, 110 FROM dual WHERE l_ai > 0
         UNION ALL SELECT 'DOC', 'الأرشيف والمراسلات', 'Documents & Correspondence', 'الأرشيف الإلكتروني والمراسلات الصادرة والواردة (مشمول)', 'fa-folder-open', 'DMS,COR', 0, NULL, 120 FROM dual) x
     ON (o.code = x.code)
   WHEN MATCHED THEN UPDATE SET o.name_ar = x.n, o.name_en = x.e, o.description = x.d, o.icon = x.i, o.module_codes = x.m, o.requires_codes = x.rq, o.sort_order = x.s
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, description, icon, module_codes, monthly_price, currency_code, requires_codes, sort_order, is_active, created_by)
        VALUES (x.code, x.n, x.e, x.d, x.i, x.m, x.p, 'SAR', x.rq, x.s, 'Y', 'SYSTEM');

  -- خصم المدة (يطبق مرة عند الإنشاء)
  UPDATE plt_plan SET discount_pct = CASE code WHEN 'QUARTERLY' THEN 5 WHEN 'SEMI_ANNUAL' THEN 10 WHEN 'ANNUAL' THEN 20 ELSE 0 END
   WHERE discount_pct = 0 AND code IN ('QUARTERLY', 'SEMI_ANNUAL', 'ANNUAL');

  MERGE INTO plt_setting_def d
  USING (SELECT 'SIGNUP.ENABLED' k, 'BOOLEAN' t, 'Y' v, 'تفعيل التسجيل الذاتي' n FROM dual
         UNION ALL SELECT 'SIGNUP.OTP_MODE', 'STRING', 'DEMO', 'وضع رموز التحقق: DEMO يعرض الرمز على الشاشة، EMAIL يرسله بالبريد' FROM dual
         UNION ALL SELECT 'SIGNUP.MAIL_FROM', 'STRING', 'no-reply@noona.local', 'بريد المرسل لرموز التحقق' FROM dual
         UNION ALL SELECT 'SIGNUP.USER_PRICE', 'NUMBER', '39', 'سعر المستخدم الشهري (ريال)' FROM dual
         UNION ALL SELECT 'SIGNUP.FREE_USERS', 'NUMBER', '2', 'عدد المستخدمين المشمولين مجاناً' FROM dual
         UNION ALL SELECT 'SIGNUP.VAT_PCT', 'NUMBER', '15', 'نسبة ضريبة القيمة المضافة على الاشتراك' FROM dual
         UNION ALL SELECT 'LOGIN.WHATS_NEW', 'STRING', 'صيانة الأسطول: أوامر صيانة وورشة داخلية تصرف من المخزون|'
                          || 'تنبيهات الاستبدال: الإطارات بالمسافة والمدة والبطاريات بالمدة|'
                          || 'الصرف بطريقة FIFO: لكل صنف أو فئة|'
                          || 'تقارير الأداء: مصروفات قطع الغيار لكل عربة وسائق|'
                          || 'الشاحنات في الأصول الثابتة: إضافة تلقائية وتمديد العمر',
                          'ما الجديد في صفحة الدخول (البنود مفصولة بـ | والعنوان قبل :)' FROM dual
         UNION ALL SELECT 'SIGNUP.BANK_DETAILS', 'STRING', 'اسم المستفيد: نونا بلس - البنك: ... - الآيبان: SA00 0000 0000 0000 0000 0000',
                          'بيانات التحويل البنكي المعروضة للعميل' FROM dual) x
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
