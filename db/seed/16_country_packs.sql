-- =============================================================================
-- NOONA PLUS ERP | محتوى حزم الدول (TENANT_ID = NULL) - قابل لإعادة التشغيل
--   السعودية، الإمارات، البحرين، عُمان، قطر، الكويت، مصر، السودان:
--   الأشكال القانونية، أنواع التسجيلات بنمط التحقق، أنواع الضرائب وأكوادها ونسبها بإصدارات مؤرخة، خانات الإقرار
--   النسب والقواعد بيانات وليست ثوابت في الكود؛ تغيير النسبة إصدار جديد من تاريخ سريانه.
--   ملاحظة: المحتوى مرجعي ويجب أن يراجعه مختص محلي في كل دولة قبل الاعتماد عليه في الإقرارات الرسمية.
-- =============================================================================
SET DEFINE OFF
DECLARE
  PROCEDURE pack(p_cc VARCHAR2, p_ref VARCHAR2, p_cal VARCHAR2) IS
  BEGIN
    UPDATE loc_country_pack SET legal_reference = p_ref, display_calendar = p_cal, status_code = 'PUBLISHED',
                                published_at = NVL(published_at, SYSTIMESTAMP)
     WHERE country_code = p_cc AND version_no = 1;
    IF SQL%ROWCOUNT = 0 THEN
      INSERT INTO loc_country_pack (code, name_ar, name_en, country_code, version_no, effective_date, legal_reference, display_calendar,
                                    status_code, published_at)
      SELECT 'CP_' || country_code, 'حزمة ' || name_ar, name_en || ' Country Pack', country_code, 1, DATE '2026-01-01', p_ref, p_cal,
             'PUBLISHED', SYSTIMESTAMP FROM ref_country WHERE country_code = p_cc;
    END IF;
  END pack;
  FUNCTION pid(p_cc VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN SELECT MAX(id) INTO l FROM loc_country_pack WHERE country_code = p_cc; RETURN l; END pid;
  PROCEDURE form(p_cc VARCHAR2, p_code VARCHAR2, p_ar VARCHAR2, p_en VARCHAR2) IS
    l_pk NUMBER := pid(p_cc);
  BEGIN
    MERGE INTO loc_legal_form f USING (SELECT l_pk pk FROM dual) x ON (f.country_pack_id = x.pk AND f.code = p_code)
     WHEN MATCHED THEN UPDATE SET f.name_ar = p_ar, f.name_en = p_en
     WHEN NOT MATCHED THEN INSERT (country_pack_id, code, name_ar, name_en, is_active) VALUES (x.pk, p_code, p_ar, p_en, 'Y');
  END form;
  PROCEDURE reg(p_cc VARCHAR2, p_code VARCHAR2, p_ar VARCHAR2, p_en VARCHAR2, p_tax VARCHAR2, p_regex VARCHAR2, p_alert NUMBER,
                p_applies VARCHAR2 DEFAULT 'COMPANY') IS
    l_pk NUMBER := pid(p_cc);
  BEGIN
    MERGE INTO loc_registration_type r USING (SELECT l_pk pk FROM dual) x
       ON (r.tenant_id IS NULL AND r.country_pack_id = x.pk AND r.code = p_code)
     WHEN MATCHED THEN UPDATE SET r.name_ar = p_ar, r.name_en = p_en, r.is_tax_registration = p_tax, r.validation_regex = p_regex,
                                  r.expiry_alert_days = p_alert, r.applies_to = p_applies
     WHEN NOT MATCHED THEN INSERT (tenant_id, country_pack_id, code, name_ar, name_en, applies_to, is_mandatory, is_tax_registration,
                                   validation_regex, expiry_alert_days, is_active)
          VALUES (NULL, x.pk, p_code, p_ar, p_en, p_applies, 'N', p_tax, p_regex, p_alert, 'Y');
  END reg;
  PROCEDURE ttype(p_cc VARCHAR2, p_code VARCHAR2, p_ar VARCHAR2, p_en VARCHAR2, p_cat VARCHAR2) IS
    l_pk NUMBER := pid(p_cc);
  BEGIN
    MERGE INTO loc_tax_type t USING (SELECT l_pk pk FROM dual) x ON (t.tenant_id IS NULL AND t.code = p_code)
     WHEN MATCHED THEN UPDATE SET t.country_pack_id = x.pk, t.name_ar = p_ar, t.name_en = p_en, t.tax_category = p_cat
     WHEN NOT MATCHED THEN INSERT (tenant_id, country_pack_id, code, name_ar, name_en, tax_category, is_active, created_by)
          VALUES (NULL, x.pk, p_code, p_ar, p_en, p_cat, 'Y', 'SYSTEM');
  END ttype;
  PROCEDURE tcode(p_type VARCHAR2, p_code VARCHAR2, p_ar VARCHAR2, p_en VARCHAR2, p_nature VARCHAR2, p_box VARCHAR2, p_einv VARCHAR2,
                  p_show VARCHAR2 DEFAULT 'Y', p_recov NUMBER DEFAULT 100) IS
  BEGIN
    MERGE INTO loc_tax_code c USING (SELECT id type_id FROM loc_tax_type WHERE tenant_id IS NULL AND code = p_type) x
       ON (c.tenant_id IS NULL AND c.code = p_code)
     WHEN MATCHED THEN UPDATE SET c.tax_type_id = x.type_id, c.name_ar = p_ar, c.name_en = p_en, c.tax_nature = p_nature,
                                  c.report_box_code = p_box, c.einvoice_category = p_einv, c.show_on_invoice = p_show, c.status_code = 'ACTIVE'
     WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, tax_type_id, tax_nature, calc_method, is_inclusive_default,
                                   recoverable_pct, rounding_level, show_on_invoice, report_box_code, einvoice_category, status_code, created_by)
          VALUES (NULL, p_code, p_ar, p_en, x.type_id, p_nature, 'PERCENT', 'N', p_recov, 'LINE', p_show, p_box, p_einv, 'ACTIVE', 'SYSTEM');
  END tcode;
  -- إصدار نسبة: لا يعدل إصدار قائم (الفواتير المرحلة تبقى على نسبتها)
  PROCEDURE rate(p_code VARCHAR2, p_ver NUMBER, p_pct NUMBER, p_from DATE, p_to DATE DEFAULT NULL) IS
  BEGIN
    MERGE INTO loc_tax_rate r USING (SELECT id code_id FROM loc_tax_code WHERE tenant_id IS NULL AND code = p_code) x
       ON (r.tax_code_id = x.code_id AND r.version_no = p_ver)
     WHEN MATCHED THEN UPDATE SET r.effective_to = p_to
     WHEN NOT MATCHED THEN INSERT (tenant_id, tax_code_id, version_no, rate_pct, effective_from, effective_to, created_by)
          VALUES (NULL, x.code_id, p_ver, p_pct, p_from, p_to, 'SYSTEM');
  END rate;
  -- ضريبة قيمة مضافة قياسية بأكوادها الأربعة
  PROCEDURE vat(p_cc VARCHAR2, p_pfx VARCHAR2, p_pct NUMBER) IS
  BEGIN
    ttype(p_cc, p_pfx || 'VAT', 'ضريبة القيمة المضافة', 'Value Added Tax', 'VAT');
    tcode(p_pfx || 'VAT', p_pfx || 'VAT' || p_pct, 'ضريبة القيمة المضافة ' || p_pct || '%', 'VAT ' || p_pct || '%', 'STANDARD', 'STD', 'S');
    tcode(p_pfx || 'VAT', p_pfx || 'VAT0', 'نسبة صفرية', 'Zero rated', 'ZERO_RATED', 'ZERO', 'Z');
    tcode(p_pfx || 'VAT', p_pfx || 'VATEX', 'معفاة من الضريبة', 'Exempt', 'EXEMPT', 'EXEMPT', 'E');
    tcode(p_pfx || 'VAT', p_pfx || 'VATOS', 'خارج نطاق الضريبة', 'Out of scope', 'OUT_OF_SCOPE', 'OOS', 'O');
    tcode(p_pfx || 'VAT', p_pfx || 'VATRC', 'احتساب عكسي (استيراد خدمات)', 'Reverse charge', 'REVERSE_CHARGE', 'RCM', 'S');
    rate(p_pfx || 'VAT0', 1, 0, DATE '2000-01-01'); rate(p_pfx || 'VATEX', 1, 0, DATE '2000-01-01'); rate(p_pfx || 'VATOS', 1, 0, DATE '2000-01-01');
  END vat;
  PROCEDURE wht(p_cc VARCHAR2, p_pfx VARCHAR2, p_pct NUMBER, p_ar VARCHAR2, p_en VARCHAR2) IS
  BEGIN
    ttype(p_cc, p_pfx || 'WHT', 'ضريبة الاستقطاع', 'Withholding Tax', 'WITHHOLDING');
    tcode(p_pfx || 'WHT', p_pfx || 'WHT' || p_pct, p_ar || ' ' || p_pct || '%', p_en || ' ' || p_pct || '%', 'WITHHOLDING', 'WHT', NULL, 'N', 0);
    rate(p_pfx || 'WHT' || p_pct, 1, p_pct, DATE '2004-01-01');
  END wht;
BEGIN
  NOONA_CORE_PKG.begin_system;
  UPDATE ref_country SET localization_rank = 8 WHERE country_code = 'EG' AND localization_rank IS NULL;

  -- ============================================================== السعودية
  pack('SA', 'نظام ضريبة القيمة المضافة ولائحته، نظام ضريبة الدخل (الاستقطاع)، لائحة الفوترة الإلكترونية (هيئة الزكاة والضريبة والجمارك)', 'BOTH');
  form('SA', 'LLC', 'شركة ذات مسؤولية محدودة', 'Limited Liability Company');
  form('SA', 'SJSC', 'شركة مساهمة مبسطة', 'Simplified Joint Stock Company');
  form('SA', 'JSC', 'شركة مساهمة', 'Joint Stock Company');
  form('SA', 'SOLE', 'مؤسسة فردية', 'Sole Proprietorship');
  form('SA', 'BRANCH', 'فرع شركة أجنبية', 'Foreign Company Branch');
  reg('SA', 'SA_CR', 'السجل التجاري', 'Commercial Registration', 'N', '^[0-9]{10}$', 60);
  reg('SA', 'SA_VAT', 'الرقم الضريبي (ضريبة القيمة المضافة)', 'VAT Registration Number', 'Y', '^3[0-9]{13}3$', NULL);
  reg('SA', 'SA_TIN', 'الرقم المميز (الزكاة والدخل)', 'Zakat & Income Tax TIN', 'N', '^[0-9]{10}$', NULL);
  reg('SA', 'SA_MUN', 'رخصة البلدية', 'Municipal License', 'N', NULL, 30);
  reg('SA', 'SA_CHAMBER', 'عضوية الغرفة التجارية', 'Chamber of Commerce Membership', 'N', NULL, 30);
  reg('SA', 'SA_GOSI', 'رقم اشتراك التأمينات الاجتماعية', 'GOSI Registration', 'N', '^[0-9]{6,12}$', NULL);
  -- نوع الضريبة القائم VAT (أكواده VAT15/VAT0/VATEX/VATOS مستخدمة في الفواتير السابقة) يصبح ضمن حزمة السعودية
  ttype('SA', 'VAT', 'ضريبة القيمة المضافة', 'Value Added Tax', 'VAT');
  tcode('VAT', 'VAT15', 'ضريبة القيمة المضافة 15%', 'VAT 15%', 'STANDARD', 'STD', 'S');
  tcode('VAT', 'VAT0', 'نسبة صفرية', 'Zero rated', 'ZERO_RATED', 'ZERO', 'Z');
  tcode('VAT', 'VATEX', 'معفاة من الضريبة', 'Exempt', 'EXEMPT', 'EXEMPT', 'E');
  tcode('VAT', 'VATOS', 'خارج نطاق الضريبة', 'Out of scope', 'OUT_OF_SCOPE', 'OOS', 'O');
  tcode('VAT', 'VATRC', 'احتساب عكسي (استيراد خدمات)', 'Reverse charge', 'REVERSE_CHARGE', 'RCM', 'S');
  rate('VAT15', 1, 15, DATE '2020-07-01');
  rate('VATRC', 1, 15, DATE '2020-07-01');
  ttype('SA', 'SA_WHT', 'ضريبة الاستقطاع', 'Withholding Tax', 'WITHHOLDING');
  tcode('SA_WHT', 'SA_WHT5', 'استقطاع 5% (إيجار، خدمات فنية واستشارية، تذاكر، شحن، اتصالات دولية، أرباح، تأمين)', 'WHT 5%', 'WITHHOLDING', 'WHT5', NULL, 'N', 0);
  tcode('SA_WHT', 'SA_WHT15', 'استقطاع 15% (إتاوات وريع، خدمات من المركز الرئيسي أو طرف مرتبط)', 'WHT 15%', 'WITHHOLDING', 'WHT15', NULL, 'N', 0);
  tcode('SA_WHT', 'SA_WHT20', 'استقطاع 20% (أتعاب إدارة)', 'WHT 20% management fees', 'WITHHOLDING', 'WHT20', NULL, 'N', 0);
  rate('SA_WHT5', 1, 5, DATE '2004-01-01'); rate('SA_WHT15', 1, 15, DATE '2004-01-01'); rate('SA_WHT20', 1, 20, DATE '2004-01-01');
  ttype('SA', 'SA_ZAKAT', 'الزكاة', 'Zakat', 'ZAKAT');
  tcode('SA_ZAKAT', 'SA_ZAKAT25', 'الزكاة 2.5% من الوعاء', 'Zakat 2.5%', 'CUSTOM', 'ZAKAT', NULL, 'N', 0);
  rate('SA_ZAKAT25', 1, 2.5, DATE '2000-01-01');

  -- ============================================================== الإمارات
  pack('AE', 'المرسوم بقانون اتحادي رقم 8 لسنة 2017 بشأن ضريبة القيمة المضافة، المرسوم بقانون رقم 47 لسنة 2022 بشأن ضريبة الشركات (الهيئة الاتحادية للضرائب)', 'GREGORIAN');
  form('AE', 'LLC', 'شركة ذات مسؤولية محدودة', 'Limited Liability Company');
  form('AE', 'FZE', 'منشأة منطقة حرة', 'Free Zone Establishment');
  form('AE', 'FZCO', 'شركة منطقة حرة', 'Free Zone Company');
  form('AE', 'SOLE', 'مؤسسة فردية', 'Sole Establishment');
  form('AE', 'BRANCH', 'فرع شركة أجنبية', 'Foreign Branch');
  reg('AE', 'AE_TL', 'الرخصة التجارية', 'Trade License', 'N', NULL, 60);
  reg('AE', 'AE_TRN', 'رقم التسجيل الضريبي TRN', 'Tax Registration Number', 'Y', '^100[0-9]{12}$', NULL);
  reg('AE', 'AE_CT', 'رقم تسجيل ضريبة الشركات', 'Corporate Tax Registration', 'N', '^[0-9]{15}$', NULL);
  vat('AE', 'AE_', 5);
  rate('AE_VAT5', 1, 5, DATE '2018-01-01'); rate('AE_VATRC', 1, 5, DATE '2018-01-01');
  ttype('AE', 'AE_CIT', 'ضريبة الشركات', 'Corporate Tax', 'OTHER');
  tcode('AE_CIT', 'AE_CIT9', 'ضريبة الشركات 9% (على ما يزيد عن 375,000 درهم)', 'Corporate tax 9%', 'CUSTOM', 'CIT', NULL, 'N', 0);
  rate('AE_CIT9', 1, 9, DATE '2023-06-01');

  -- ============================================================== البحرين (النسبة ارتفعت من 5% إلى 10% في 2022)
  pack('BH', 'المرسوم بقانون رقم 48 لسنة 2018 بشأن ضريبة القيمة المضافة وتعديله 2021 (الجهاز الوطني للإيرادات)', 'GREGORIAN');
  form('BH', 'WLL', 'شركة ذات مسؤولية محدودة (W.L.L)', 'With Limited Liability');
  form('BH', 'SPC', 'شركة الشخص الواحد', 'Single Person Company');
  form('BH', 'BSC', 'شركة مساهمة بحرينية', 'Bahraini Shareholding Company');
  reg('BH', 'BH_CR', 'السجل التجاري', 'Commercial Registration', 'N', '^[0-9]{3,6}(-[0-9]{1,3})?$', 60);
  reg('BH', 'BH_VAT', 'رقم حساب ضريبة القيمة المضافة', 'VAT Account Number', 'Y', '^2[0-9]{14}$', NULL);
  vat('BH', 'BH_', 10);
  rate('BH_VAT10', 1, 5, DATE '2019-01-01', DATE '2021-12-31');
  rate('BH_VAT10', 2, 10, DATE '2022-01-01');
  rate('BH_VATRC', 1, 5, DATE '2019-01-01', DATE '2021-12-31'); rate('BH_VATRC', 2, 10, DATE '2022-01-01');

  -- ============================================================== عُمان
  pack('OM', 'قانون ضريبة القيمة المضافة الصادر بالمرسوم السلطاني 121/2020 (جهاز الضرائب)', 'GREGORIAN');
  form('OM', 'LLC', 'شركة محدودة المسؤولية', 'Limited Liability Company');
  form('OM', 'SAOC', 'شركة مساهمة مقفلة', 'Closed Joint Stock Company');
  form('OM', 'SOLE', 'مؤسسة فردية', 'Sole Proprietorship');
  reg('OM', 'OM_CR', 'السجل التجاري', 'Commercial Registration', 'N', '^[0-9]{7}$', 60);
  reg('OM', 'OM_VAT', 'رقم التسجيل الضريبي (VATIN)', 'VAT Identification Number', 'Y', '^OM[0-9]{10}$', NULL);
  vat('OM', 'OM_', 5);
  rate('OM_VAT5', 1, 5, DATE '2021-04-16'); rate('OM_VATRC', 1, 5, DATE '2021-04-16');
  wht('OM', 'OM_', 10, 'استقطاع على غير المقيمين', 'WHT non-residents');

  -- ============================================================== قطر (لا ضريبة قيمة مضافة)
  pack('QA', 'قانون ضريبة الدخل رقم 24 لسنة 2018 (الهيئة العامة للضرائب)؛ لا تطبق ضريبة القيمة المضافة', 'GREGORIAN');
  form('QA', 'WLL', 'شركة ذات مسؤولية محدودة', 'With Limited Liability');
  form('QA', 'QPSC', 'شركة مساهمة عامة', 'Public Shareholding Company');
  reg('QA', 'QA_CR', 'السجل التجاري', 'Commercial Registration', 'N', '^[0-9]{4,6}$', 60);
  reg('QA', 'QA_TIN', 'الرقم الضريبي', 'Tax Identification Number', 'Y', '^[0-9]{10}$', NULL);
  ttype('QA', 'QA_VAT', 'لا تطبق ضريبة قيمة مضافة', 'No VAT', 'VAT');
  tcode('QA_VAT', 'QA_NOVAT', 'لا ضريبة قيمة مضافة', 'No VAT', 'OUT_OF_SCOPE', 'OOS', 'O', 'N');
  rate('QA_NOVAT', 1, 0, DATE '2000-01-01');
  wht('QA', 'QA_', 5, 'استقطاع على غير المقيمين', 'WHT non-residents');

  -- ============================================================== الكويت (لا ضريبة قيمة مضافة)
  pack('KW', 'لا تطبق ضريبة القيمة المضافة؛ ضريبة الدخل على الشركات الأجنبية والزكاة ودعم العمالة الوطنية للشركات المساهمة', 'GREGORIAN');
  form('KW', 'WLL', 'شركة ذات مسؤولية محدودة', 'With Limited Liability');
  form('KW', 'KSC', 'شركة مساهمة كويتية', 'Kuwaiti Shareholding Company');
  reg('KW', 'KW_CR', 'السجل التجاري', 'Commercial Registration', 'N', '^[0-9]{3,8}$', 60);
  reg('KW', 'KW_LICENSE', 'الترخيص التجاري', 'Commercial License', 'N', NULL, 60);
  ttype('KW', 'KW_VAT', 'لا تطبق ضريبة قيمة مضافة', 'No VAT', 'VAT');
  tcode('KW_VAT', 'KW_NOVAT', 'لا ضريبة قيمة مضافة', 'No VAT', 'OUT_OF_SCOPE', 'OOS', 'O', 'N');
  rate('KW_NOVAT', 1, 0, DATE '2000-01-01');

  -- ============================================================== مصر
  pack('EG', 'قانون الضريبة على القيمة المضافة رقم 67 لسنة 2016، قانون الضريبة على الدخل (الخصم تحت حساب الضريبة)، منظومة الفاتورة الإلكترونية (مصلحة الضرائب المصرية)', 'GREGORIAN');
  form('EG', 'LLC', 'شركة ذات مسؤولية محدودة', 'Limited Liability Company');
  form('EG', 'SAE', 'شركة مساهمة مصرية', 'Egyptian Joint Stock Company');
  form('EG', 'SOLE', 'منشأة فردية', 'Sole Proprietorship');
  reg('EG', 'EG_CR', 'السجل التجاري', 'Commercial Registry', 'N', NULL, 60);
  reg('EG', 'EG_TRN', 'رقم التسجيل الضريبي', 'Tax Registration Number', 'Y', '^[0-9]{9}$', NULL);
  vat('EG', 'EG_', 14);
  rate('EG_VAT14', 1, 13, DATE '2016-09-08', DATE '2017-06-30');
  rate('EG_VAT14', 2, 14, DATE '2017-07-01');
  rate('EG_VATRC', 1, 14, DATE '2017-07-01');
  ttype('EG', 'EG_WHT', 'الخصم تحت حساب الضريبة', 'Withholding (WHT)', 'WITHHOLDING');
  tcode('EG_WHT', 'EG_WHT1', 'خصم تحت حساب الضريبة 1% (توريدات ومقاولات)', 'WHT 1% supplies', 'WITHHOLDING', 'WHT1', NULL, 'N', 0);
  tcode('EG_WHT', 'EG_WHT3', 'خصم تحت حساب الضريبة 3% (خدمات)', 'WHT 3% services', 'WITHHOLDING', 'WHT3', NULL, 'N', 0);
  tcode('EG_WHT', 'EG_WHT5', 'خصم تحت حساب الضريبة 5% (مهن حرة وعمولات)', 'WHT 5% professional', 'WITHHOLDING', 'WHT5', NULL, 'N', 0);
  rate('EG_WHT1', 1, 1, DATE '2005-01-01'); rate('EG_WHT3', 1, 3, DATE '2005-01-01'); rate('EG_WHT5', 1, 5, DATE '2005-01-01');

  -- ============================================================== السودان
  pack('SD', 'قانون الضريبة على القيمة المضافة (ديوان الضرائب)', 'GREGORIAN');
  form('SD', 'LLC', 'شركة خاصة محدودة', 'Private Limited Company');
  form('SD', 'SOLE', 'اسم عمل', 'Business Name');
  reg('SD', 'SD_CR', 'السجل التجاري', 'Commercial Registration', 'N', NULL, 60);
  reg('SD', 'SD_TIN', 'الرقم التعريفي الضريبي', 'Tax Identification Number', 'Y', '^[0-9]{9,12}$', NULL);
  vat('SD', 'SD_', 17);
  rate('SD_VAT17', 1, 17, DATE '2000-01-01'); rate('SD_VATRC', 1, 17, DATE '2000-01-01');

  -- ============================================================== قيود الضرائب
  MERGE INTO ace_event_class e
  USING (SELECT x0.* FROM (SELECT 'LOC_VAT_RETURN_APPROVED' code, 'تسوية إقرار ضريبة القيمة المضافة' name_ar, 'VAT return settlement' name_en, 'LOC_TAX_RETURN' ent FROM dual
         UNION ALL SELECT 'LOC_TAX_PAYMENT', 'سداد ضريبة للجهة الحكومية', 'Tax payment to authority', 'LOC_TAX_RETURN_LINE' FROM dual
         UNION ALL SELECT 'LOC_WHT_WITHHELD', 'استقطاع ضريبة من مورد', 'Tax withheld from supplier', 'LOC_WITHHOLDING_CERT' FROM dual) x0
          JOIN ref_entity_type r ON r.entity_type_code = x0.ent) x
     ON (e.code = x.code)
   WHEN MATCHED THEN UPDATE SET e.name_ar = x.name_ar, e.name_en = x.name_en
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, event_family, source_entity_type, posting_mode, is_active, created_by)
        VALUES (x.code, x.name_ar, x.name_en, 'TAX', x.ent, 'OUTBOX', 'Y', 'SYSTEM');
  MERGE INTO gl_journal_type t
  USING (SELECT 'TAX' code, 'قيد ضرائب' name_ar, 'Tax' name_en, 950 o, 'تسوية الإقرارات الضريبية وسدادها والاستقطاع' dsc FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN MATCHED THEN UPDATE SET t.name_ar = x.name_ar, t.name_en = x.name_en, t.sort_order = x.o, t.description = x.dsc
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, type_group, module_code, allow_manual, is_opening, is_adjustment,
                                 auto_reverse, exclude_from_pl, requires_reference, is_active, sort_order, description, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'SYSTEM', 'LOC', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', x.o, x.dsc, 'SYSTEM');
  MERGE INTO gl_journal_source s
  USING (SELECT 'TAX' code, 'الضرائب' name_ar, 'Tax' name_en FROM dual) x
     ON (s.tenant_id IS NULL AND s.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, module_code, allow_manual, requires_approval, is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'LOC', 'N', 'N', 'Y', 'SYSTEM');

  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  ROLLBACK;
  RAISE;
END;
/
