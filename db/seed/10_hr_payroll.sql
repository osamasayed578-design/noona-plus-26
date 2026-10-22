-- =============================================================================
-- NOONA PLUS ERP | بيانات المنصة للموارد البشرية والرواتب (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   * أنواع الإجازات حسب نظام العمل السعودي
--   * عناصر الراتب (الأساسي والبدلات والإضافي والمكافآت والخصومات والتأمينات ونهاية الخدمة)
--   * قواعد التأمينات الاجتماعية (GOSI) للسعودي وغير السعودي بنسب قابلة للتعديل
--   * فئات الأحداث المحاسبية للرواتب
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  -- جنسيات العمالة الشائعة (تستخدم في ملف الموظف والتأمينات ونسبة التوطين)
  MERGE INTO ref_country t
  USING (SELECT 'IN' c, 'IND' i3, 'الهند' ar, 'India' en FROM dual
         UNION ALL SELECT 'PK', 'PAK', 'باكستان', 'Pakistan' FROM dual
         UNION ALL SELECT 'BD', 'BGD', 'بنغلاديش', 'Bangladesh' FROM dual
         UNION ALL SELECT 'PH', 'PHL', 'الفلبين', 'Philippines' FROM dual
         UNION ALL SELECT 'NP', 'NPL', 'نيبال', 'Nepal' FROM dual
         UNION ALL SELECT 'LK', 'LKA', 'سريلانكا', 'Sri Lanka' FROM dual
         UNION ALL SELECT 'ID', 'IDN', 'إندونيسيا', 'Indonesia' FROM dual
         UNION ALL SELECT 'YE', 'YEM', 'اليمن', 'Yemen' FROM dual
         UNION ALL SELECT 'JO', 'JOR', 'الأردن', 'Jordan' FROM dual
         UNION ALL SELECT 'SY', 'SYR', 'سوريا', 'Syria' FROM dual
         UNION ALL SELECT 'LB', 'LBN', 'لبنان', 'Lebanon' FROM dual
         UNION ALL SELECT 'PS', 'PSE', 'فلسطين', 'Palestine' FROM dual
         UNION ALL SELECT 'IQ', 'IRQ', 'العراق', 'Iraq' FROM dual
         UNION ALL SELECT 'MA', 'MAR', 'المغرب', 'Morocco' FROM dual
         UNION ALL SELECT 'TN', 'TUN', 'تونس', 'Tunisia' FROM dual
         UNION ALL SELECT 'DZ', 'DZA', 'الجزائر', 'Algeria' FROM dual
         UNION ALL SELECT 'ET', 'ETH', 'إثيوبيا', 'Ethiopia' FROM dual
         UNION ALL SELECT 'KE', 'KEN', 'كينيا', 'Kenya' FROM dual
         UNION ALL SELECT 'UG', 'UGA', 'أوغندا', 'Uganda' FROM dual
         UNION ALL SELECT 'TR', 'TUR', 'تركيا', 'Turkey' FROM dual
         UNION ALL SELECT 'GB', 'GBR', 'المملكة المتحدة', 'United Kingdom' FROM dual
         UNION ALL SELECT 'FR', 'FRA', 'فرنسا', 'France' FROM dual
         UNION ALL SELECT 'DE', 'DEU', 'ألمانيا', 'Germany' FROM dual
         UNION ALL SELECT 'CA', 'CAN', 'كندا', 'Canada' FROM dual
         UNION ALL SELECT 'AU', 'AUS', 'أستراليا', 'Australia' FROM dual
         UNION ALL SELECT 'CN', 'CHN', 'الصين', 'China' FROM dual
         UNION ALL SELECT 'AF', 'AFG', 'أفغانستان', 'Afghanistan' FROM dual
         UNION ALL SELECT 'MY', 'MYS', 'ماليزيا', 'Malaysia' FROM dual) x
     ON (t.country_code = x.c)
   WHEN NOT MATCHED THEN INSERT (country_code, iso3_code, name_ar, name_en, show_hijri, is_active, sort_order, created_by)
        VALUES (x.c, x.i3, x.ar, x.en, 'N', 'Y', 100, 'SYSTEM');
  MERGE INTO hr_leave_type t
  USING (SELECT 'ANNUAL' code, 'إجازة سنوية' name_ar, 'Annual leave' name_en, 'Y' paid, 'DAY' unit, 30 mx, 'N' doc, 'N' sens, 1 o FROM dual
         UNION ALL SELECT 'SICK', 'إجازة مرضية', 'Sick leave', 'Y', 'DAY', 120, 'Y', 'Y', 2 FROM dual
         UNION ALL SELECT 'UNPAID', 'إجازة بدون راتب', 'Unpaid leave', 'N', 'DAY', NULL, 'N', 'N', 3 FROM dual
         UNION ALL SELECT 'HAJJ', 'إجازة الحج', 'Hajj leave', 'Y', 'DAY', 15, 'N', 'N', 4 FROM dual
         UNION ALL SELECT 'MARRIAGE', 'إجازة زواج', 'Marriage leave', 'Y', 'DAY', 5, 'Y', 'N', 5 FROM dual
         UNION ALL SELECT 'BEREAVEMENT', 'إجازة وفاة', 'Bereavement leave', 'Y', 'DAY', 5, 'N', 'N', 6 FROM dual
         UNION ALL SELECT 'MATERNITY', 'إجازة وضع', 'Maternity leave', 'Y', 'DAY', 84, 'Y', 'Y', 7 FROM dual
         UNION ALL SELECT 'PATERNITY', 'إجازة مولود', 'Paternity leave', 'Y', 'DAY', 3, 'Y', 'N', 8 FROM dual
         UNION ALL SELECT 'EXAM', 'إجازة امتحان', 'Exam leave', 'Y', 'DAY', NULL, 'Y', 'N', 9 FROM dual
         UNION ALL SELECT 'PERMISSION', 'استئذان', 'Short permission', 'Y', 'HOUR', NULL, 'N', 'N', 10 FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, country_code, is_paid, unit_code, max_per_year,
                                 requires_document, is_sensitive, is_active, accrual_rule, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'SA', x.paid, x.unit, x.mx, x.doc, x.sens, 'Y',
                CASE x.code WHEN 'ANNUAL' THEN '{"days_per_year":21,"days_after_5_years":30,"carry_forward":true}' END, 'SYSTEM');

  MERGE INTO pay_element e
  USING (SELECT 'BASIC' code, 'الراتب الأساسي' name_ar, 'Basic salary' name_en, 'EARNING' typ, 'BASE_SALARY' cls, 'Y' rec, 'Y' pro, 'Y' eos, 10 o FROM dual
         UNION ALL SELECT 'HOUSING', 'بدل السكن', 'Housing allowance', 'EARNING', 'HOUSING', 'Y', 'Y', 'Y', 20 FROM dual
         UNION ALL SELECT 'TRANSPORT', 'بدل النقل', 'Transport allowance', 'EARNING', 'TRANSPORT', 'Y', 'Y', 'Y', 30 FROM dual
         UNION ALL SELECT 'OTHER_ALLOW', 'بدلات أخرى', 'Other allowances', 'EARNING', 'ALLOWANCE', 'Y', 'Y', 'N', 40 FROM dual
         UNION ALL SELECT 'OVERTIME', 'العمل الإضافي', 'Overtime', 'EARNING', 'OVERTIME', 'N', 'N', 'N', 50 FROM dual
         UNION ALL SELECT 'BONUS', 'مكافأة', 'Bonus', 'EARNING', 'BONUS', 'N', 'N', 'N', 60 FROM dual
         UNION ALL SELECT 'COMMISSION', 'عمولة', 'Commission', 'EARNING', 'COMMISSION', 'N', 'N', 'N', 70 FROM dual
         UNION ALL SELECT 'EOS', 'مكافأة نهاية الخدمة', 'End of service award', 'EARNING', 'EOS', 'N', 'N', 'N', 80 FROM dual
         UNION ALL SELECT 'LEAVE_PAY', 'بدل الإجازات المستحقة', 'Leave encashment', 'EARNING', 'LEAVE_PAY', 'N', 'N', 'N', 90 FROM dual
         UNION ALL SELECT 'ABSENCE', 'خصم الغياب والإجازة غير المدفوعة', 'Absence deduction', 'DEDUCTION', 'ABSENCE', 'N', 'N', 'N', 110 FROM dual
         UNION ALL SELECT 'PENALTY', 'جزاءات', 'Penalties', 'DEDUCTION', 'PENALTY', 'N', 'N', 'N', 120 FROM dual
         UNION ALL SELECT 'OTHER_DED', 'خصومات أخرى', 'Other deductions', 'DEDUCTION', 'OTHER', 'N', 'N', 'N', 130 FROM dual
         UNION ALL SELECT 'LOAN', 'قسط سلفة / قرض', 'Loan installment', 'LOAN_REPAYMENT', 'ADVANCE', 'N', 'N', 'N', 140 FROM dual
         UNION ALL SELECT 'GOSI_EE', 'التأمينات الاجتماعية - حصة الموظف', 'GOSI employee share', 'EMPLOYEE_CONTRIBUTION', 'SOCIAL_SECURITY', 'Y', 'N', 'N', 150 FROM dual
         UNION ALL SELECT 'GOSI_ER', 'التأمينات الاجتماعية - حصة المنشأة', 'GOSI employer share', 'EMPLOYER_CONTRIBUTION', 'SOCIAL_SECURITY', 'Y', 'N', 'N', 160 FROM dual) x
     ON (e.tenant_id IS NULL AND e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en, e.sort_order = x.o
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, element_type, classification, is_recurring, is_taxable, is_prorated,
                                 affects_eos, show_on_payslip, is_active, sort_order, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.typ, x.cls, x.rec, 'N', x.pro, x.eos,
                CASE WHEN x.code = 'GOSI_ER' THEN 'N' ELSE 'Y' END, 'Y', x.o, 'SYSTEM');

  -- التأمينات الاجتماعية: الأساس (الأساسي + السكن) بحد أدنى 1500 وأعلى 45000؛ السعودي 9.75% موظف و11.75% منشأة،
  -- وغير السعودي 2% منشأة (الأخطار المهنية). النسب تعدل بإصدار جديد للقاعدة دون تغيير التشغيلات السابقة.
  MERGE INTO pay_element_rule r
  USING (SELECT e.id element_id, x.cat, x.ver, x.prm
           FROM (SELECT 'GOSI_EE' code, 'SAUDI' cat, 1 ver, '{"pct":9.75,"base":["BASIC","HOUSING"],"min":1500,"max":45000}' prm FROM dual
                 UNION ALL SELECT 'GOSI_EE', 'NON_SAUDI', 2, '{"pct":0,"base":["BASIC","HOUSING"],"min":1500,"max":45000}' FROM dual
                 UNION ALL SELECT 'GOSI_ER', 'SAUDI', 1, '{"pct":11.75,"base":["BASIC","HOUSING"],"min":1500,"max":45000}' FROM dual
                 UNION ALL SELECT 'GOSI_ER', 'NON_SAUDI', 2, '{"pct":2,"base":["BASIC","HOUSING"],"min":1500,"max":45000}' FROM dual
                 UNION ALL SELECT 'OVERTIME', NULL, 1, '{"hours_per_day":8,"days_per_month":30,"premium_pct_of_basic":50}' FROM dual) x
           JOIN pay_element e ON e.tenant_id IS NULL AND e.code = x.code) x
     ON (r.element_id = x.element_id AND r.version_no = x.ver)
   WHEN NOT MATCHED THEN INSERT (tenant_id, element_id, version_no, employee_category, formula_type, parameters, status_code,
                                 effective_from, created_by)
        VALUES (NULL, x.element_id, x.ver, x.cat, 'APPROVED_FUNCTION', x.prm, 'ACTIVE', DATE '2020-01-01', 'SYSTEM');

  MERGE INTO ace_event_class e
  USING (SELECT 'PAY_ACCRUAL_POSTED' code, 'مخصصات نهاية الخدمة والإجازات' name_ar, 'Payroll accruals posted' name_en, 'PAY_RUN' ent FROM dual
         UNION ALL SELECT 'PAY_RUN_PAID', 'صرف الرواتب', 'Payroll paid', 'PAY_BANK_FILE' FROM dual
         UNION ALL SELECT 'PAY_LOAN_DISBURSED', 'صرف سلفة أو قرض لموظف', 'Employee loan disbursed', 'PAY_LOAN' FROM dual) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, 'PAYROLL', x.ent, 'OUTBOX', 'Y', 'SYSTEM');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
