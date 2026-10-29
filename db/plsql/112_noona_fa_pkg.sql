-- =============================================================================
-- NOONA PLUS ERP | NOONA_FA_PKG - الأصول الثابتة
--   * التجهيز: دفتر الأصول المالي، فئات افتراضية مربوطة بالدليل (أراض، مبان، آلات، أثاث، سيارات، حاسب)،
--     حسابات أرباح وخسائر الاستبعاد والانخفاض وذمم بيع/شراء الأصول، والترقيم
--   * الاقتناء والرسملة: من بنك أو صندوق أو مورد آجل أو حساب محدد أو رصيد افتتاحي (مع مجمع إهلاك منقول)،
--     وضريبة المدخلات؛ قيد: من ح/ الأصل (والضريبة) إلى ح/ مصدر التمويل (ومجمع الإهلاك الافتتاحي)
--   * الإهلاك الشهري: القسط الثابت والمتناقص (1.5) والمتناقص المضاعف (2) مع التحول للثابت، على العمر المتبقي
--     (المعالجة المستقبلية للإضافات وتغيير العمر)، واللحاق بالفترات الفائتة، وقواعد بداية الإهلاك
--     (يومي، شهر كامل، منتصف الشهر، الشهر التالي)؛ تشغيل واحد لكل دفتر وفترة، وعكس آخر تشغيل
--   * الإضافات الرأسمالية، والانخفاض في القيمة، وتغيير العمر والقيمة المتبقية، والنقل بين الفروع ومراكز التكلفة والعهد
--   * الاستبعاد: بيع (نقدي/بنكي/آجل مع ضريبة المخرجات) وتخريد وتبرع وفقد وسرقة واستبدال؛ يلحق الإهلاك حتى
--     تاريخ الاستبعاد ثم يقفل التكلفة والمجمع ويثبت الربح أو الخسارة؛ مع إمكانية عكس الاستبعاد
--   * التقارير: سجل الأصول، بطاقة الأصل، جدول الإهلاك المتوقع، حركة الأصول (تكلفة ومجمع) مع مطابقة الأستاذ،
--     الاستبعادات وأرباحها وخسائرها، وتفاصيل تشغيل الإهلاك ومعاينته
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_FA_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  -- مساعدات تستخدم داخل SQL
  FUNCTION acc(p_code IN VARCHAR2) RETURN NUMBER;
  FUNCTION next_no(p_type IN VARCHAR2, p_date IN DATE) RETURN VARCHAR2;
  FUNCTION depr_start(p_in_service IN DATE, p_prorate IN VARCHAR2) RETURN DATE;
  -- ---------------------------------------------------------- التجهيز
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  FUNCTION default_book RETURN NUMBER;
  FUNCTION save_category(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_method IN VARCHAR2, p_life_months IN NUMBER,
                         p_residual_pct IN NUMBER, p_prorate IN VARCHAR2, p_asset_acc IN NUMBER, p_accum_acc IN NUMBER,
                         p_expense_acc IN NUMBER, p_threshold IN NUMBER DEFAULT NULL) RETURN NUMBER;

  -- ---------------------------------------------------------- الأصل
  -- JSON: name_ar, category, branch, cost_center, custodian, location, tag, serial, manufacturer, model, warranty_end,
  --   acquisition_date, in_service_date, cost, residual (افتراضياً من نسبة الفئة), life_months, method, prorate,
  --   funding: BANK | CASH | PAYABLE | ACCOUNT | OPENING ، bank_account, cash_box, party, account, vat, opening_accum,
  --   reference, capitalize (Y: يرسمل ويرحل فوراً) ؛ يعيد رقم الأصل
  FUNCTION create_asset(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION capitalize(p_asset_id IN NUMBER) RETURN NUMBER;             -- رقم القيد
  -- البيانات الوصفية فقط: name_ar, tag, serial, manufacturer, model, warranty_end, location
  PROCEDURE update_info(p_asset_id IN NUMBER, p_doc IN CLOB);
  PROCEDURE delete_asset(p_asset_id IN NUMBER);                         -- المسودة فقط

  -- ---------------------------------------------------------- الإهلاك
  -- إهلاك الأصل/الدفتر من آخر تاريخ مهلك حتى التاريخ المحدد (لا يرحل شيئاً)
  FUNCTION depreciation_for(p_asset_book_id IN NUMBER, p_to IN DATE) RETURN NUMBER;
  FUNCTION run_depreciation(p_period_id IN NUMBER, p_book_id IN NUMBER DEFAULT NULL) RETURN NUMBER;   -- رقم التشغيل
  FUNCTION reverse_run(p_run_id IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER;                       -- قيد العكس
  -- أول فترة لم يشغل إهلاكها بعد آخر تشغيل مرحل (أو فترة اليوم)
  FUNCTION next_period RETURN NUMBER;

  -- ---------------------------------------------------------- الحركات
  FUNCTION add_cost(p_asset_id IN NUMBER, p_amount IN NUMBER, p_date IN DATE, p_funding IN VARCHAR2, p_bank_account_id IN NUMBER,
                    p_cash_box_id IN NUMBER, p_party_id IN NUMBER, p_account_id IN NUMBER, p_vat IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER;
  FUNCTION impair(p_asset_id IN NUMBER, p_amount IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER;
  FUNCTION change_life(p_asset_id IN NUMBER, p_life_months IN NUMBER, p_residual IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER;
  -- الفارغ لا يتغير
  FUNCTION transfer(p_asset_id IN NUMBER, p_date IN DATE, p_branch_id IN NUMBER, p_cost_center_id IN NUMBER, p_custodian_id IN NUMBER,
                    p_location IN VARCHAR2, p_reason IN VARCHAR2) RETURN NUMBER;
  -- p_method: SALE, SCRAP, DONATION, LOSS, THEFT, TRADE_IN ؛ p_receipt: BANK | CASH | RECEIVABLE ؛ يعيد رقم الاستبعاد
  FUNCTION dispose(p_asset_id IN NUMBER, p_method IN VARCHAR2, p_date IN DATE, p_proceeds IN NUMBER, p_vat IN NUMBER,
                   p_receipt IN VARCHAR2, p_bank_account_id IN NUMBER, p_cash_box_id IN NUMBER, p_party_id IN NUMBER,
                   p_reason IN VARCHAR2) RETURN NUMBER;
  FUNCTION reverse_disposal(p_disposal_id IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- المسميات والتقارير
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION method_label(p_method IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION disposal_label(p_method IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION txn_label(p_type IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION asset_label(p_asset_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION book_id_of(p_asset_id IN NUMBER) RETURN NUMBER;
  FUNCTION asset_status(p_asset_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION run_status(p_run_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION fa_summary RETURN CLOB;
  FUNCTION asset_card_html(p_asset_id IN NUMBER) RETURN CLOB;
  FUNCTION schedule_html(p_asset_id IN NUMBER) RETURN CLOB;
  FUNCTION register_html(p_category_id IN NUMBER DEFAULT NULL, p_branch_id IN NUMBER DEFAULT NULL,
                         p_show IN VARCHAR2 DEFAULT 'ACTIVE', p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION rollforward_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION disposals_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION run_html(p_run_id IN NUMBER) RETURN CLOB;
  FUNCTION preview_html(p_period_id IN NUMBER) RETURN CLOB;
END NOONA_FA_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_FA_PKG AS

  TYPE t_dep IS RECORD (amount NUMBER, months NUMBER);

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fnum(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN '' ELSE TO_CHAR(ROUND(p, 2), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END fnum;
  FUNCTION jn(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN 'null' ELSE RTRIM(RTRIM(TO_CHAR(ROUND(p, 4), 'FM999999999990.9999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.') END;
  END jn;
  FUNCTION fd(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END fd;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION acc(p_code IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = p_code;
    RETURN l;
  END acc;

  FUNCTION need_acc(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER := acc(p_code);
  BEGIN
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-FA-001', 'الحساب ' || p_code || ' غير موجود؛ نفذ «تجهيز الأصول الثابتة»',
      'Account ' || p_code || ' missing; run fixed assets setup');
    RETURN l;
  END need_acc;

  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2, p_sub VARCHAR2 DEFAULT NULL,
                          p_normal VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l NUMBER := acc(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type, 'Y', p_sub, p_normal);
    END IF;
    RETURN l;
  END ensure_account;

  PROCEDURE ensure_sequence(p_type VARCHAR2, p_prefix VARCHAR2) IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 5, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
  END ensure_sequence;

  FUNCTION next_no(p_type IN VARCHAR2, p_date IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, NVL(p_date, TRUNC(SYSDATE)), p_type, NULL);
  END next_no;

  -- ================================================================ المسميات
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'DRAFT' THEN 'مسودة' WHEN 'CIP' THEN 'تحت التنفيذ' WHEN 'CAPITALIZED' THEN 'مرسمل'
      WHEN 'IN_SERVICE' THEN 'في الخدمة' WHEN 'SUSPENDED' THEN 'موقوف' WHEN 'FULLY_DEPRECIATED' THEN 'مهلك بالكامل'
      WHEN 'DISPOSED' THEN 'مستبعد' WHEN 'RETIRED' THEN 'متقاعد' WHEN 'POSTED' THEN 'مرحل' WHEN 'REVERSED' THEN 'معكوس'
      WHEN 'CANCELLED' THEN 'ملغى' WHEN 'CALCULATED' THEN 'محسوب' WHEN 'APPROVED' THEN 'معتمد' WHEN 'COMPLETED' THEN 'منفذ'
      WHEN 'ACTIVE' THEN 'قائم' ELSE p_status END;
  END status_label;

  FUNCTION method_label(p_method IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_method WHEN 'STRAIGHT_LINE' THEN 'القسط الثابت' WHEN 'DECLINING_BALANCE' THEN 'القسط المتناقص'
      WHEN 'DOUBLE_DECLINING' THEN 'المتناقص المضاعف' WHEN 'UNITS_OF_PRODUCTION' THEN 'وحدات الإنتاج' WHEN 'NONE' THEN 'لا يهلك'
      ELSE p_method END;
  END method_label;

  FUNCTION disposal_label(p_method IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_method WHEN 'SALE' THEN 'بيع' WHEN 'SCRAP' THEN 'تخريد' WHEN 'DONATION' THEN 'تبرع' WHEN 'LOSS' THEN 'فقد أو تلف'
      WHEN 'THEFT' THEN 'سرقة' WHEN 'TRADE_IN' THEN 'استبدال' ELSE p_method END;
  END disposal_label;

  FUNCTION txn_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'CAPITALIZATION' THEN 'رسملة واقتناء' WHEN 'ADDITION' THEN 'إضافة رأسمالية' WHEN 'COST_ADJUSTMENT' THEN 'تعديل تكلفة'
      WHEN 'LIFE_CHANGE' THEN 'تغيير العمر الإنتاجي' WHEN 'TRANSFER' THEN 'نقل' WHEN 'REVALUATION' THEN 'إعادة تقييم'
      WHEN 'IMPAIRMENT' THEN 'انخفاض في القيمة' WHEN 'PARTIAL_RETIREMENT' THEN 'استبعاد جزئي' WHEN 'DISPOSAL' THEN 'استبعاد'
      WHEN 'REINSTATEMENT' THEN 'إعادة أصل مستبعد' ELSE p_type END;
  END txn_label;

  FUNCTION asset_label(p_asset_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(asset_no || ' - ' || name_ar) INTO l FROM fa_asset WHERE id = p_asset_id AND company_id = company;
    RETURN l;
  END asset_label;

  -- ================================================================ التجهيز
  FUNCTION default_book RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY CASE book_type WHEN 'FINANCIAL' THEN 0 ELSE 1 END, id) INTO l
      FROM fa_book WHERE company_id = company AND is_active = 'Y';
    RETURN l;
  END default_book;

  FUNCTION book_id_of(p_asset_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM fa_asset_book WHERE asset_id = p_asset_id AND book_id = default_book;
    RETURN l;
  END book_id_of;

  FUNCTION asset_status(p_asset_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM fa_asset WHERE id = p_asset_id AND company_id = company;
    RETURN l;
  END asset_status;

  FUNCTION run_status(p_run_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM fa_depreciation_run WHERE id = p_run_id AND company_id = company;
    RETURN l;
  END run_status;

  FUNCTION quick_setup RETURN NUMBER IS
    l_id  NUMBER;
    l_bk  NUMBER;
    l_acd NUMBER;
    l_exp NUMBER;
    l_gl  NUMBER;
    l_n   NUMBER := 0;
  BEGIN
    guard('FA_CATEGORY.CREATE');
    IF NOONA_GL_PKG.primary_ledger IS NULL THEN
      l_id := NOONA_GL_PKG.quick_setup;
    END IF;
    l_id := ensure_account('1109', 'مدينو بيع الأصول الثابتة', '11', 'ASSET');
    l_id := ensure_account('2110', 'دائنو شراء الأصول الثابتة', '21', 'LIABILITY');
    l_id := ensure_account('3105', 'الأرصدة الافتتاحية', '3', 'EQUITY');
    l_gl := ensure_account('4204', 'أرباح بيع واستبعاد الأصول الثابتة', '4', 'REVENUE');
    l_id := ensure_account('5217', 'خسائر بيع واستبعاد الأصول الثابتة', '52', 'EXPENSE');
    l_id := ensure_account('5218', 'خسائر الانخفاض في قيمة الأصول', '52', 'EXPENSE');
    l_acd := need_acc('1209');
    l_exp := need_acc('5206');
    l_bk := default_book;
    IF l_bk IS NULL THEN
      INSERT INTO fa_book (company_id, code, name_ar, name_en, book_type, ledger_id, is_active)
      VALUES (company, 'FIN', 'الدفتر المالي', 'Financial book', 'FINANCIAL', NOONA_GL_PKG.primary_ledger, 'Y')
      RETURNING id INTO l_bk;
      l_n := l_n + 1;
    END IF;
    FOR c IN (SELECT 'LAND' code, 'الأراضي' nm, '1201' ac, 'NONE' mt, NULL life, 0 rp FROM dual
              UNION ALL SELECT 'BUILDINGS', 'المباني والإنشاءات', '1202', 'STRAIGHT_LINE', 300, 5 FROM dual
              UNION ALL SELECT 'MACHINERY', 'الآلات والمعدات', '1203', 'STRAIGHT_LINE', 120, 5 FROM dual
              UNION ALL SELECT 'FURNITURE', 'الأثاث والتجهيزات المكتبية', '1204', 'STRAIGHT_LINE', 60, 0 FROM dual
              UNION ALL SELECT 'VEHICLES', 'السيارات ووسائل النقل', '1205', 'DECLINING_BALANCE', 60, 10 FROM dual
              UNION ALL SELECT 'COMPUTERS', 'أجهزة الحاسب والبرمجيات', '1206', 'STRAIGHT_LINE', 48, 0 FROM dual) LOOP
      INSERT INTO fa_category (company_id, code, name_ar, depreciation_method, useful_life_months, residual_pct, capitalization_threshold,
                               prorate_convention, asset_account_id, accum_depr_account_id, depr_expense_account_id, gain_loss_account_id,
                               policy_version, is_active)
      SELECT company, c.code, c.nm, c.mt, c.life, c.rp, 500, 'DAILY', acc(c.ac), CASE WHEN c.mt <> 'NONE' THEN l_acd END,
             CASE WHEN c.mt <> 'NONE' THEN l_exp END, l_gl, 1, 'Y'
        FROM dual WHERE NOT EXISTS (SELECT 1 FROM fa_category WHERE company_id = company AND code = c.code);
      l_n := l_n + SQL%ROWCOUNT;
    END LOOP;
    ensure_sequence('FA_ASSET', 'FA-');
    ensure_sequence('FA_TRANSACTION', 'FAT-');
    ensure_sequence('FA_DISPOSAL', 'FAD-');
    ensure_sequence('FA_TRANSFER', 'FAN-');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'FA_BOOK', l_bk, 'QUICK_SETUP', 'SUCCESS');
    RETURN l_n;
  END quick_setup;

  FUNCTION is_ready RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM fa_category WHERE company_id = company AND is_active = 'Y';
    RETURN CASE WHEN default_book IS NOT NULL AND l > 0 AND acc('4204') IS NOT NULL THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION save_category(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_method IN VARCHAR2, p_life_months IN NUMBER,
                         p_residual_pct IN NUMBER, p_prorate IN VARCHAR2, p_asset_acc IN NUMBER, p_accum_acc IN NUMBER,
                         p_expense_acc IN NUMBER, p_threshold IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER := p_id;
  BEGIN
    guard(CASE WHEN p_id IS NULL THEN 'FA_CATEGORY.CREATE' ELSE 'FA_CATEGORY.UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL AND p_asset_acc IS NOT NULL, 'NOONA-FA-002',
      'الرمز والاسم وحساب الأصل مطلوبة', 'Code, name and asset account are required');
    NOONA_CORE_PKG.assert(p_method = 'NONE' OR (p_life_months > 0 AND p_accum_acc IS NOT NULL AND p_expense_acc IS NOT NULL), 'NOONA-FA-003',
      'الفئة القابلة للإهلاك تتطلب العمر الإنتاجي وحسابي المجمع والمصروف', 'Depreciable category needs life and accounts');
    NOONA_CORE_PKG.assert(NVL(p_residual_pct, 0) BETWEEN 0 AND 99, 'NOONA-FA-004', 'نسبة القيمة المتبقية من 0 إلى 99', 'Residual 0-99%');
    IF l_id IS NULL THEN
      INSERT INTO fa_category (company_id, code, name_ar, depreciation_method, useful_life_months, residual_pct, capitalization_threshold,
                               prorate_convention, asset_account_id, accum_depr_account_id, depr_expense_account_id, gain_loss_account_id,
                               policy_version, is_active)
      VALUES (company, UPPER(TRIM(p_code)), TRIM(p_name_ar), p_method, p_life_months, NVL(p_residual_pct, 0), p_threshold,
              NVL(p_prorate, 'DAILY'), p_asset_acc, p_accum_acc, p_expense_acc, acc('4204'), 1, 'Y')
      RETURNING id INTO l_id;
    ELSE
      UPDATE fa_category SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), depreciation_method = p_method,
             useful_life_months = p_life_months, residual_pct = NVL(p_residual_pct, 0), capitalization_threshold = p_threshold,
             prorate_convention = NVL(p_prorate, 'DAILY'), asset_account_id = p_asset_acc, accum_depr_account_id = p_accum_acc,
             depr_expense_account_id = p_expense_acc, policy_version = policy_version + 1
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_category;

  -- ================================================================ حساب الإهلاك
  -- بداية الإهلاك الفعلية حسب قاعدة الفئة
  FUNCTION depr_start(p_in_service IN DATE, p_prorate IN VARCHAR2) RETURN DATE IS
  BEGIN
    RETURN CASE p_prorate
      WHEN 'FULL_MONTH' THEN TRUNC(p_in_service, 'MM')
      WHEN 'NEXT_MONTH' THEN ADD_MONTHS(TRUNC(p_in_service, 'MM'), 1)
      WHEN 'MID_MONTH' THEN CASE WHEN EXTRACT(DAY FROM p_in_service) <= 15 THEN TRUNC(p_in_service, 'MM')
                                 ELSE ADD_MONTHS(TRUNC(p_in_service, 'MM'), 1) END
      ELSE TRUNC(p_in_service) END;
  END depr_start;

  -- الأشهر المنقضية من بداية الإهلاك حتى نهاية يوم p_d (كسرية)، بحد أقصى العمر
  FUNCTION elapsed(p_start DATE, p_d DATE, p_life NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_d IS NULL OR p_d < p_start THEN RETURN 0; END IF;
    RETURN LEAST(GREATEST(MONTHS_BETWEEN(TRUNC(p_d) + 1, p_start), 0), p_life);
  END elapsed;

  -- إهلاك المدة (آخر تاريخ مهلك، p_to]: على العمر المتبقي فتعالج الإضافات وتغيير العمر مستقبلياً وتلحق الفترات الفائتة
  FUNCTION calc(p_cost NUMBER, p_residual NUMBER, p_accum NUMBER, p_method VARCHAR2, p_life NUMBER, p_start DATE,
                p_done_to DATE, p_to DATE) RETURN NUMBER IS
    l_from  DATE := GREATEST(NVL(p_done_to, p_start - 1), p_start - 1);
    l_e0    NUMBER;
    l_e1    NUMBER;
    l_rem   NUMBER := ROUND(p_cost - NVL(p_residual, 0) - NVL(p_accum, 0), 2);
    l_sl    NUMBER;
    l_db    NUMBER;
    l_d     NUMBER;
  BEGIN
    IF p_method = 'NONE' OR NVL(p_life, 0) <= 0 OR l_rem <= 0 OR p_to IS NULL OR p_to <= l_from OR p_to < p_start THEN
      RETURN 0;
    END IF;
    l_e0 := elapsed(p_start, l_from, p_life);
    l_e1 := elapsed(p_start, p_to, p_life);
    IF l_e1 >= p_life THEN
      RETURN l_rem;                                         -- نهاية العمر: يستكمل الباقي
    END IF;
    IF l_e1 <= l_e0 THEN RETURN 0; END IF;
    l_sl := l_rem * (l_e1 - l_e0) / (p_life - l_e0);
    IF p_method IN ('DECLINING_BALANCE', 'DOUBLE_DECLINING') THEN
      l_db := (p_cost - NVL(p_accum, 0)) * CASE p_method WHEN 'DOUBLE_DECLINING' THEN 2 ELSE 1.5 END / p_life * (l_e1 - l_e0);
      l_d := GREATEST(l_db, l_sl);                          -- يتحول للقسط الثابت عندما يصبح أكبر
    ELSE
      l_d := l_sl;
    END IF;
    RETURN LEAST(ROUND(l_d, 2), l_rem);
  END calc;

  FUNCTION calc_book(p_b fa_asset_book%ROWTYPE, p_to DATE) RETURN NUMBER IS
  BEGIN
    RETURN calc(p_b.cost, p_b.residual_value, p_b.accumulated_depr, p_b.depreciation_method, p_b.useful_life_months,
                p_b.depr_start_date, p_b.depreciated_to, p_to);
  END calc_book;

  FUNCTION depreciation_for(p_asset_book_id IN NUMBER, p_to IN DATE) RETURN NUMBER IS
    l_b fa_asset_book%ROWTYPE;
  BEGIN
    SELECT * INTO l_b FROM fa_asset_book WHERE id = p_asset_book_id AND company_id = company;
    IF l_b.status_code <> 'ACTIVE' THEN RETURN 0; END IF;
    RETURN calc_book(l_b, p_to);
  END depreciation_for;

  -- ================================================================ التمويل والسطور
  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_cc NUMBER,
                     p_desc VARCHAR2, p_party NUMBER DEFAULT NULL, p_merge BOOLEAN DEFAULT TRUE) IS
    l_amt NUMBER := ROUND(NVL(p_dr, 0) - NVL(p_cr, 0), 2);
  BEGIN
    IF l_amt = 0 THEN RETURN; END IF;
    FOR i IN 1 .. CASE WHEN p_merge THEN p_lines.COUNT ELSE 0 END LOOP
      IF p_lines(i).account_id = p_acc AND NVL(p_lines(i).cost_center_id, -1) = NVL(p_cc, -1)
         AND NVL(p_lines(i).party_id, -1) = NVL(p_party, -1) THEN
        l_amt := l_amt + NVL(p_lines(i).debit, 0) - NVL(p_lines(i).credit, 0);
        p_lines(i).debit := CASE WHEN l_amt > 0 THEN l_amt END;
        p_lines(i).credit := CASE WHEN l_amt < 0 THEN -l_amt END;
        RETURN;
      END IF;
    END LOOP;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := CASE WHEN l_amt > 0 THEN l_amt END;
    p_lines(p_lines.COUNT).credit := CASE WHEN l_amt < 0 THEN -l_amt END;
    p_lines(p_lines.COUNT).cost_center_id := p_cc;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
    p_lines(p_lines.COUNT).party_id := p_party;
  END add_line;

  -- حساب مصدر التمويل (الاقتناء) أو جهة التحصيل (البيع)
  FUNCTION source_account(p_kind VARCHAR2, p_bank NUMBER, p_box NUMBER, p_party NUMBER, p_account NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF p_kind = 'BANK' THEN
      SELECT MAX(gl_account_id) INTO l FROM csh_bank_account
       WHERE company_id = company AND status_code = 'ACTIVE'
         AND id = NVL(p_bank, (SELECT MIN(b2.id) FROM csh_bank_account b2 WHERE b2.company_id = company AND b2.status_code = 'ACTIVE'));
      NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-FA-010', 'حدد الحساب البنكي', 'Bank account required');
    ELSIF p_kind = 'CASH' THEN
      SELECT MAX(gl_account_id) INTO l FROM csh_cash_box
       WHERE company_id = company AND status_code = 'ACTIVE'
         AND id = NVL(p_box, (SELECT MIN(c2.id) FROM csh_cash_box c2 WHERE c2.company_id = company AND c2.status_code = 'ACTIVE'));
      NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-FA-011', 'حدد الصندوق', 'Cash box required');
    ELSIF p_kind IN ('PAYABLE', 'RECEIVABLE') THEN
      NOONA_CORE_PKG.assert(p_party IS NOT NULL, 'NOONA-FA-012', 'حدد الطرف (المورد أو المشتري) للمعاملة الآجلة',
        'Party required for credit transaction');
      l := need_acc(CASE p_kind WHEN 'PAYABLE' THEN '2110' ELSE '1109' END);
    ELSIF p_kind = 'OPENING' THEN
      l := need_acc('3105');
    ELSIF p_kind = 'ACCOUNT' THEN
      SELECT MAX(id) INTO l FROM gl_account WHERE id = p_account AND coa_id = NOONA_GL_PKG.primary_coa;
      NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-FA-013', 'حدد الحساب المقابل', 'Counter account required');
    ELSE
      NOONA_CORE_PKG.raise_error('NOONA-FA-014', 'مصدر التمويل غير صحيح: ' || p_kind, 'Invalid funding source');
    END IF;
    RETURN l;
  END source_account;

  FUNCTION asset_row(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN fa_asset%ROWTYPE IS
    l fa_asset%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM fa_asset WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM fa_asset WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-FA-015', 'الأصل غير موجود', 'Asset not found');
  END asset_row;

  FUNCTION book_row(p_asset NUMBER) RETURN fa_asset_book%ROWTYPE IS
    l fa_asset_book%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM fa_asset_book WHERE asset_id = p_asset AND book_id = default_book FOR UPDATE;
    RETURN l;
  END book_row;

  FUNCTION new_txn(p_asset NUMBER, p_book NUMBER, p_type VARCHAR2, p_date DATE, p_amount NUMBER, p_old VARCHAR2, p_new VARCHAR2,
                   p_reason VARCHAR2, p_status VARCHAR2 DEFAULT 'DRAFT') RETURN NUMBER IS
    l NUMBER;
  BEGIN
    ensure_sequence('FA_TRANSACTION', 'FAT-');
    INSERT INTO fa_transaction (company_id, doc_no, doc_date, asset_id, book_id, txn_type, txn_date, amount, old_values, new_values,
                                reason, status_code)
    VALUES (company, next_no('FA_TRANSACTION', p_date), p_date, p_asset, p_book, p_type, p_date, p_amount, p_old, p_new,
            SUBSTR(p_reason, 1, 1000), p_status)
    RETURNING id INTO l;
    RETURN l;
  END new_txn;

  PROCEDURE mark_posted(p_txn NUMBER) IS
    l_ev NUMBER;
  BEGIN
    SELECT MAX(id) INTO l_ev FROM ace_accounting_event
     WHERE source_entity_type = 'FA_TRANSACTION' AND source_entity_id = p_txn AND status_code = 'POSTED' AND reversal_of_event_id IS NULL;
    UPDATE fa_transaction SET status_code = 'POSTED', accounting_event_id = l_ev, posted_at = SYSTIMESTAMP,
                              posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = p_txn;
  END mark_posted;

  -- ================================================================ الأصل
  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jnum(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
    l VARCHAR2(100) := js(p_o, p_k);
  BEGIN
    RETURN CASE WHEN l IS NOT NULL THEN TO_NUMBER(REPLACE(l, ',', ''), '999999999999990.999999', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END jnum;
  FUNCTION jdate(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN DATE IS
    l VARCHAR2(30) := js(p_o, p_k);
  BEGIN
    RETURN CASE WHEN l IS NOT NULL THEN TO_DATE(SUBSTR(l, 1, 10), 'YYYY-MM-DD') END;
  END jdate;

  FUNCTION create_asset(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_c     fa_category%ROWTYPE;
    l_id    NUMBER;
    l_cost  NUMBER := ROUND(jnum(l_o, 'cost'), 2);
    l_res   NUMBER;
    l_life  NUMBER;
    l_meth  VARCHAR2(30);
    l_acq   DATE := NVL(jdate(l_o, 'acquisition_date'), TRUNC(SYSDATE));
    l_svc   DATE;
    l_open  NUMBER := NVL(ROUND(jnum(l_o, 'opening_accum'), 2), 0);
    l_fund  VARCHAR2(30) := NVL(js(l_o, 'funding'), 'BANK');
    l_name  VARCHAR2(400) := js(l_o, 'name_ar');
    l_cat   NUMBER := jnum(l_o, 'category');
    l_book  NUMBER;
    l_tx    NUMBER;
    l_j     NUMBER;
    l_new   VARCHAR2(4000);
    l_no    VARCHAR2(50);
    l_bank  NUMBER := jnum(l_o, 'bank_account');
    l_box   NUMBER := jnum(l_o, 'cash_box');
    l_party NUMBER := jnum(l_o, 'party');
    l_acct  NUMBER := jnum(l_o, 'account');
    l_vat   NUMBER := NVL(ROUND(jnum(l_o, 'vat'), 2), 0);
    l_ref   VARCHAR2(200) := js(l_o, 'reference');
    l_tag   VARCHAR2(100) := js(l_o, 'tag');
    l_branch NUMBER;
    l_cc    NUMBER;
    l_cust  NUMBER;
    l_en    VARCHAR2(400);
    l_loc   VARCHAR2(500);
    l_ser   VARCHAR2(100);
    l_man   VARCHAR2(200);
    l_mod   VARCHAR2(100);
    l_war   DATE;
    l_start DATE;
    l_cur   VARCHAR2(10);
  BEGIN
    guard('FA_ASSET.CREATE');
    l_book := default_book;
    NOONA_CORE_PKG.assert(l_book IS NOT NULL, 'NOONA-FA-016', 'نفذ «تجهيز الأصول الثابتة» أولاً', 'Run fixed assets setup first');
    NOONA_CORE_PKG.assert(l_name IS NOT NULL AND l_cat IS NOT NULL, 'NOONA-FA-017', 'اسم الأصل وفئته مطلوبان', 'Name and category are required');
    NOONA_CORE_PKG.assert(l_cost > 0, 'NOONA-FA-018', 'تكلفة الأصل يجب أن تكون موجبة', 'Cost must be positive');
    SELECT * INTO l_c FROM fa_category WHERE id = l_cat AND company_id = company AND is_active = 'Y';
    l_meth := NVL(js(l_o, 'method'), l_c.depreciation_method);
    l_life := NVL(jnum(l_o, 'life_months'), l_c.useful_life_months);
    l_res := NVL(ROUND(jnum(l_o, 'residual'), 2), ROUND(l_cost * NVL(l_c.residual_pct, 0) / 100, 2));
    l_svc := NVL(jdate(l_o, 'in_service_date'), l_acq);
    NOONA_CORE_PKG.assert(l_meth = 'NONE' OR l_life > 0, 'NOONA-FA-019', 'العمر الإنتاجي مطلوب للأصل القابل للإهلاك', 'Useful life required');
    NOONA_CORE_PKG.assert(l_res >= 0 AND l_res < l_cost AND l_open >= 0 AND l_open <= l_cost - l_res, 'NOONA-FA-020',
      'القيمة المتبقية ومجمع الإهلاك الافتتاحي يجب ألا يتجاوزا التكلفة', 'Residual/opening accumulated exceed cost');
    NOONA_CORE_PKG.assert(l_open = 0 OR l_fund = 'OPENING' OR l_fund = 'ACCOUNT', 'NOONA-FA-021',
      'مجمع الإهلاك المنقول يستخدم مع الرصيد الافتتاحي أو حساب محدد', 'Opening accumulated only with opening balance');
    ensure_sequence('FA_ASSET', 'FA-');
    l_no := next_no('FA_ASSET', l_acq);
    l_branch := jnum(l_o, 'branch');
    l_cc := jnum(l_o, 'cost_center');
    l_cust := jnum(l_o, 'custodian');
    l_en := js(l_o, 'name_en');
    l_loc := js(l_o, 'location');
    l_ser := js(l_o, 'serial');
    l_man := js(l_o, 'manufacturer');
    l_mod := js(l_o, 'model');
    l_war := jdate(l_o, 'warranty_end');
    l_start := depr_start(l_svc, NVL(js(l_o, 'prorate'), l_c.prorate_convention));
    l_cur := NOONA_GL_PKG.ledger_currency;
    INSERT INTO fa_asset (company_id, branch_id, name_ar, name_en, asset_no, tag_no, category_id, location_text, custodian_employee_id,
                          cost_center_id, acquisition_date, in_service_date, original_cost, currency_code, serial_no, manufacturer,
                          model_no, warranty_end, status_code)
    VALUES (company, l_branch, l_name, l_en, l_no, NVL(l_tag, l_no), l_cat, l_loc, l_cust, l_cc, l_acq, l_svc, l_cost, l_cur,
            l_ser, l_man, l_mod, l_war, 'DRAFT')
    RETURNING id INTO l_id;
    INSERT INTO fa_asset_book (company_id, asset_id, book_id, cost, residual_value, depreciation_method, useful_life_months,
                               depr_start_date, accumulated_depr, net_book_value, depreciated_to, status_code)
    VALUES (company, l_id, l_book, l_cost, l_res, l_meth, l_life, l_start, 0, l_cost, NULL, 'ACTIVE');
    l_new := '{"funding":"' || l_fund || '","bank":' || jn(l_bank) || ',"box":' || jn(l_box) || ',"party":' || jn(l_party)
          || ',"account":' || jn(l_acct) || ',"vat":' || jn(l_vat) || ',"opening_accum":' || jn(l_open)
          || ',"reference":' || NOONA_CORE_PKG.json_text(l_ref) || '}';
    l_tx := new_txn(l_id, l_book, 'CAPITALIZATION', l_acq, l_cost, NULL, l_new, 'اقتناء ' || l_name);
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'FA_ASSET', l_id, 'CREATE', 'SUCCESS');
    IF NVL(js(l_o, 'capitalize'), 'N') = 'Y' THEN
      l_j := capitalize(l_id);
    END IF;
    RETURN l_id;
  END create_asset;

  FUNCTION capitalize(p_asset_id IN NUMBER) RETURN NUMBER IS
    l_a     fa_asset%ROWTYPE := asset_row(p_asset_id, TRUE);
    l_b     fa_asset_book%ROWTYPE;
    l_c     fa_category%ROWTYPE;
    l_t     fa_transaction%ROWTYPE;
    l_o     JSON_OBJECT_T;
    l_fund  VARCHAR2(30);
    l_vat   NUMBER;
    l_open  NUMBER;
    l_party NUMBER;
    l_src   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
  BEGIN
    guard('FA_TRANSACTION.POST');
    NOONA_CORE_PKG.assert(l_a.status_code = 'DRAFT', 'NOONA-FA-022', 'الأصل مرسمل سابقاً', 'Asset already capitalized');
    l_b := book_row(p_asset_id);
    SELECT * INTO l_c FROM fa_category WHERE id = l_a.category_id;
    SELECT * INTO l_t FROM fa_transaction WHERE asset_id = p_asset_id AND txn_type = 'CAPITALIZATION' AND status_code = 'DRAFT' FOR UPDATE;
    l_o := JSON_OBJECT_T.parse(NVL(l_t.new_values, '{}'));
    l_fund := js(l_o, 'funding');
    l_vat := NVL(jnum(l_o, 'vat'), 0);
    l_open := NVL(jnum(l_o, 'opening_accum'), 0);
    l_party := jnum(l_o, 'party');
    l_src := source_account(l_fund, jnum(l_o, 'bank'), jnum(l_o, 'box'), l_party, jnum(l_o, 'account'));
    add_line(l_lines, l_c.asset_account_id, l_b.cost, 0, NULL, 'تكلفة الأصل ' || l_a.asset_no || ' - ' || l_a.name_ar);
    IF l_vat > 0 THEN
      add_line(l_lines, need_acc('1107'), l_vat, 0, NULL, 'ضريبة مدخلات شراء أصل ' || l_a.asset_no);
    END IF;
    IF l_open > 0 THEN
      add_line(l_lines, NVL(l_c.accum_depr_account_id, need_acc('1209')), 0, l_open, NULL, 'مجمع إهلاك منقول ' || l_a.asset_no);
    END IF;
    add_line(l_lines, l_src, 0, l_b.cost + l_vat - l_open, NULL,
             CASE l_fund WHEN 'OPENING' THEN 'رصيد افتتاحي للأصل ' WHEN 'PAYABLE' THEN 'مستحق لمورد عن شراء الأصل ' ELSE 'سداد قيمة الأصل ' END
             || l_a.asset_no, CASE WHEN l_fund = 'PAYABLE' THEN l_party END);
    l_j := NOONA_ACE_PKG.post_source('FA_ASSET_ACQUIRED', 'ASSETS', 'FA_TRANSACTION', l_t.id, l_t.txn_date,
             'اقتناء أصل ثابت ' || l_a.asset_no || ' - ' || l_a.name_ar, NOONA_GL_PKG.ledger_currency, 1, l_lines,
             NVL(js(l_o, 'reference'), l_a.asset_no), l_a.branch_id, 'FA_ACQUISITION');
    mark_posted(l_t.id);
    -- الرصيد الافتتاحي: المجمع المنقول يغطي حتى اليوم السابق لتاريخ الرسملة
    UPDATE fa_asset_book SET accumulated_depr = l_open, net_book_value = cost - l_open,
                             depreciated_to = CASE WHEN l_open > 0 THEN GREATEST(l_t.txn_date - 1, depr_start_date - 1) END,
                             status_code = CASE WHEN depreciation_method <> 'NONE' AND cost - l_open <= residual_value THEN 'FULLY_DEPRECIATED' ELSE 'ACTIVE' END
     WHERE id = l_b.id;
    UPDATE fa_asset SET status_code = CASE WHEN l_b.depreciation_method <> 'NONE' AND l_b.cost - l_open <= l_b.residual_value
                                           THEN 'FULLY_DEPRECIATED' ELSE 'IN_SERVICE' END
     WHERE id = p_asset_id;
    RETURN l_j;
  END capitalize;

  PROCEDURE update_info(p_asset_id IN NUMBER, p_doc IN CLOB) IS
    l_o JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_a fa_asset%ROWTYPE := asset_row(p_asset_id, TRUE);
    l_name VARCHAR2(400) := js(l_o, 'name_ar');
    l_tag  VARCHAR2(100) := js(l_o, 'tag');
    l_ser  VARCHAR2(100) := js(l_o, 'serial');
    l_man  VARCHAR2(200) := js(l_o, 'manufacturer');
    l_mod  VARCHAR2(100) := js(l_o, 'model');
    l_war  DATE := jdate(l_o, 'warranty_end');
    l_loc  VARCHAR2(500) := js(l_o, 'location');
  BEGIN
    guard('FA_ASSET.UPDATE');
    UPDATE fa_asset SET name_ar = NVL(l_name, name_ar), tag_no = NVL(l_tag, tag_no), serial_no = l_ser, manufacturer = l_man,
                        model_no = l_mod, warranty_end = l_war, location_text = NVL(l_loc, location_text)
     WHERE id = l_a.id;
  END update_info;

  PROCEDURE delete_asset(p_asset_id IN NUMBER) IS
    l_a fa_asset%ROWTYPE := asset_row(p_asset_id, TRUE);
  BEGIN
    guard('FA_ASSET.DELETE');
    NOONA_CORE_PKG.assert(l_a.status_code = 'DRAFT', 'NOONA-FA-023', 'يحذف الأصل المسودة فقط؛ الأصل المرسمل يستبعد', 'Only draft assets can be deleted');
    DELETE FROM fa_transaction WHERE asset_id = p_asset_id;
    DELETE FROM fa_asset_book WHERE asset_id = p_asset_id;
    DELETE FROM fa_asset WHERE id = p_asset_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'FA_ASSET', p_asset_id, 'DELETE', 'SUCCESS');
  END delete_asset;

  -- ================================================================ تشغيل الإهلاك
  FUNCTION next_period RETURN NUMBER IS
    l_end DATE;
    l     NUMBER;
  BEGIN
    SELECT MAX(p.end_date) INTO l_end FROM fa_depreciation_run r JOIN gl_period p ON p.id = r.period_id
     WHERE r.company_id = company AND r.book_id = default_book AND r.status_code = 'POSTED';
    SELECT MIN(p.id) KEEP (DENSE_RANK FIRST ORDER BY p.start_date) INTO l
      FROM gl_period p JOIN gl_fiscal_year y ON y.id = p.fiscal_year_id
     WHERE p.company_id = company AND p.period_type = 'NORMAL' AND y.status_code = 'OPEN'
       AND p.start_date > NVL(l_end, TRUNC(SYSDATE, 'MM') - 1);
    RETURN l;
  END next_period;

  -- تاريخ آخر إهلاك مرحل قبل فترة/تشغيل معين (أو تاريخ الرصيد الافتتاحي)
  FUNCTION prev_done_to(p_book NUMBER, p_asset NUMBER, p_exclude_run NUMBER, p_before DATE DEFAULT NULL) RETURN DATE IS
    l DATE;
  BEGIN
    SELECT MAX(p.end_date) INTO l FROM fa_depreciation_line l JOIN fa_depreciation_run r ON r.id = l.run_id
      JOIN gl_period p ON p.id = l.period_id
     WHERE l.asset_book_id = p_book AND r.status_code = 'POSTED' AND r.id <> NVL(p_exclude_run, -1)
       AND (p_before IS NULL OR p.start_date < p_before);
    IF l IS NULL THEN
      SELECT MAX(CASE WHEN NVL(JSON_VALUE(t.new_values, '$.opening_accum' RETURNING NUMBER), 0) > 0 THEN t.txn_date - 1 END) INTO l
        FROM fa_transaction t WHERE t.asset_id = p_asset AND t.txn_type = 'CAPITALIZATION' AND t.status_code = 'POSTED';
    END IF;
    RETURN l;
  END prev_done_to;

  FUNCTION run_depreciation(p_period_id IN NUMBER, p_book_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_book  NUMBER := NVL(p_book_id, default_book);
    l_p     gl_period%ROWTYPE;
    l_run   NUMBER;
    l_st    VARCHAR2(30);
    l_n     NUMBER;
    l_d     NUMBER;
    l_tot   NUMBER := 0;
    l_cnt   NUMBER := 0;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
  BEGIN
    guard('FA_DEPRECIATION_RUN.CREATE');
    NOONA_CORE_PKG.assert(l_book IS NOT NULL, 'NOONA-FA-016', 'نفذ «تجهيز الأصول الثابتة» أولاً', 'Run fixed assets setup first');
    BEGIN
      SELECT * INTO l_p FROM gl_period WHERE id = p_period_id AND company_id = company;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-FA-030', 'الفترة المحاسبية غير موجودة', 'Period not found');
    END;
    SELECT MAX(id), MAX(status_code) INTO l_run, l_st FROM fa_depreciation_run WHERE book_id = l_book AND period_id = p_period_id;
    NOONA_CORE_PKG.assert(NVL(l_st, '-') <> 'POSTED', 'NOONA-FA-031', 'تم تشغيل إهلاك هذه الفترة وترحيله؛ اعكسه أولاً لإعادة التشغيل',
      'Depreciation already posted for this period');
    SELECT COUNT(*) INTO l_n FROM fa_depreciation_run r JOIN gl_period p ON p.id = r.period_id
     WHERE r.book_id = l_book AND r.status_code = 'POSTED' AND p.start_date > l_p.start_date;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-FA-032', 'يوجد إهلاك مرحل لفترة لاحقة', 'Depreciation posted for a later period');
    IF l_run IS NULL THEN
      INSERT INTO fa_depreciation_run (company_id, book_id, period_id, method_version, total_amount, status_code)
      VALUES (company, l_book, p_period_id, 'RL-1', 0, 'CALCULATED')
      RETURNING id INTO l_run;
    ELSE
      DELETE FROM fa_depreciation_line WHERE run_id = l_run;
      UPDATE fa_depreciation_run SET status_code = 'CALCULATED', total_amount = 0, journal_id = NULL WHERE id = l_run;
    END IF;
    FOR b IN (SELECT ab.*, a.cost_center_id cc, a.asset_no, c.accum_depr_account_id accd, c.depr_expense_account_id expa
                FROM fa_asset_book ab JOIN fa_asset a ON a.id = ab.asset_id JOIN fa_category c ON c.id = a.category_id
               WHERE ab.book_id = l_book AND ab.company_id = company AND ab.status_code = 'ACTIVE'
                 AND a.status_code IN ('IN_SERVICE', 'CAPITALIZED') AND ab.depreciation_method <> 'NONE'
                 AND ab.depr_start_date <= l_p.end_date AND NVL(ab.depreciated_to, ab.depr_start_date - 1) < l_p.end_date
               ORDER BY a.asset_no FOR UPDATE OF ab.accumulated_depr) LOOP
      l_d := calc(b.cost, b.residual_value, b.accumulated_depr, b.depreciation_method, b.useful_life_months, b.depr_start_date,
                  b.depreciated_to, l_p.end_date);
      IF l_d > 0 THEN
        NOONA_CORE_PKG.assert(b.accd IS NOT NULL AND b.expa IS NOT NULL, 'NOONA-FA-033',
          'حسابات الإهلاك غير معرفة لفئة الأصل ' || b.asset_no, 'Depreciation accounts missing for category');
        INSERT INTO fa_depreciation_line (company_id, run_id, asset_book_id, period_id, depreciation_amount, accumulated_after, nbv_after,
                                          cost_center_id)
        VALUES (company, l_run, b.id, p_period_id, l_d, b.accumulated_depr + l_d, b.cost - b.accumulated_depr - l_d, b.cc);
        add_line(l_lines, b.expa, l_d, 0, b.cc, 'إهلاك ' || l_p.period_code);
        add_line(l_lines, b.accd, 0, l_d, NULL, 'مجمع إهلاك ' || l_p.period_code);
        l_tot := l_tot + l_d;
        l_cnt := l_cnt + 1;
      END IF;
      UPDATE fa_asset_book SET accumulated_depr = accumulated_depr + l_d, net_book_value = cost - accumulated_depr - l_d,
                               depreciated_to = l_p.end_date, last_depr_period_id = p_period_id,
                               status_code = CASE WHEN cost - accumulated_depr - l_d <= residual_value THEN 'FULLY_DEPRECIATED' ELSE 'ACTIVE' END
       WHERE id = b.id;
      UPDATE fa_asset SET status_code = 'FULLY_DEPRECIATED'
       WHERE id = b.asset_id AND b.cost - b.accumulated_depr - l_d <= b.residual_value;
    END LOOP;
    IF l_tot > 0 THEN
      l_j := NOONA_ACE_PKG.post_source('FA_DEPRECIATION', 'ASSETS', 'FA_DEPRECIATION_RUN', l_run, l_p.end_date,
               'إهلاك الأصول الثابتة لفترة ' || l_p.period_code || ' (' || l_cnt || ' أصل)', NOONA_GL_PKG.ledger_currency, 1, l_lines,
               'DEP-' || l_p.period_code, NULL, 'DEPRECIATION');
    END IF;
    UPDATE fa_depreciation_run SET status_code = 'POSTED', total_amount = l_tot, journal_id = l_j WHERE id = l_run;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'FA_DEPRECIATION_RUN', l_run, 'POST', 'SUCCESS');
    RETURN l_run;
  END run_depreciation;

  FUNCTION reverse_run(p_run_id IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_r   fa_depreciation_run%ROWTYPE;
    l_p   gl_period%ROWTYPE;
    l_n   NUMBER;
    l_j   NUMBER;
    l_to  DATE;
    l_pid NUMBER;
  BEGIN
    guard('FA_DEPRECIATION_RUN.UPDATE');
    SELECT * INTO l_r FROM fa_depreciation_run WHERE id = p_run_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_r.status_code = 'POSTED', 'NOONA-FA-034', 'التشغيل غير مرحل', 'Run is not posted');
    SELECT * INTO l_p FROM gl_period WHERE id = l_r.period_id;
    SELECT COUNT(*) INTO l_n FROM fa_depreciation_run r JOIN gl_period p ON p.id = r.period_id
     WHERE r.book_id = l_r.book_id AND r.status_code = 'POSTED' AND p.start_date > l_p.start_date;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-FA-035', 'يعكس آخر تشغيل إهلاك فقط', 'Only the latest run can be reversed');
    SELECT COUNT(*) INTO l_n FROM fa_depreciation_line l JOIN fa_asset_book b ON b.id = l.asset_book_id
     WHERE l.run_id = p_run_id AND b.status_code = 'DISPOSED';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-FA-036', 'استبعد أصل من أصول هذا التشغيل؛ اعكس الاستبعاد أولاً', 'Reverse the disposal first');
    IF l_r.journal_id IS NOT NULL THEN
      l_j := NOONA_ACE_PKG.reverse_source('FA_DEPRECIATION_RUN', p_run_id, l_p.end_date, NVL(p_reason, 'عكس إهلاك ' || l_p.period_code));
    END IF;
    FOR b IN (SELECT b.id, b.asset_id FROM fa_asset_book b
               WHERE b.book_id = l_r.book_id AND (b.last_depr_period_id = l_r.period_id
                     OR b.id IN (SELECT asset_book_id FROM fa_depreciation_line WHERE run_id = p_run_id))) LOOP
      -- آخر فترة مرحلة قبل هذا التشغيل، وإلا تاريخ الرصيد الافتتاحي
      BEGIN
        SELECT pid, edt INTO l_pid, l_to FROM (
          SELECT l.period_id pid, p.end_date edt FROM fa_depreciation_line l JOIN fa_depreciation_run r ON r.id = l.run_id
            JOIN gl_period p ON p.id = l.period_id
           WHERE l.asset_book_id = b.id AND r.status_code = 'POSTED' AND r.id <> p_run_id ORDER BY p.start_date DESC)
         WHERE ROWNUM = 1;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_pid := NULL;
        SELECT MAX(CASE WHEN NVL(JSON_VALUE(t.new_values, '$.opening_accum' RETURNING NUMBER), 0) > 0 THEN t.txn_date - 1 END) INTO l_to
          FROM fa_transaction t WHERE t.asset_id = b.asset_id AND t.txn_type = 'CAPITALIZATION' AND t.status_code = 'POSTED';
      END;
      SELECT NVL(SUM(depreciation_amount), 0) INTO l_n FROM fa_depreciation_line WHERE run_id = p_run_id AND asset_book_id = b.id;
      UPDATE fa_asset_book SET accumulated_depr = accumulated_depr - l_n, net_book_value = net_book_value + l_n,
                               depreciated_to = l_to, last_depr_period_id = l_pid, status_code = 'ACTIVE'
       WHERE id = b.id;
      UPDATE fa_asset SET status_code = 'IN_SERVICE' WHERE id = b.asset_id AND status_code = 'FULLY_DEPRECIATED';
    END LOOP;
    DELETE FROM fa_depreciation_line WHERE run_id = p_run_id;
    UPDATE fa_depreciation_run SET status_code = 'REVERSED', total_amount = 0 WHERE id = p_run_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'FA_DEPRECIATION_RUN', p_run_id, 'REVERSE', 'SUCCESS');
    RETURN l_j;
  END reverse_run;

  -- ================================================================ الحركات
  PROCEDURE assert_active(p_a fa_asset%ROWTYPE) IS
  BEGIN
    NOONA_CORE_PKG.assert(p_a.status_code IN ('IN_SERVICE', 'CAPITALIZED', 'FULLY_DEPRECIATED'), 'NOONA-FA-040',
      'الأصل ' || p_a.asset_no || ' ليس في الخدمة (' || status_label(p_a.status_code) || ')', 'Asset is not in service');
  END assert_active;

  FUNCTION add_cost(p_asset_id IN NUMBER, p_amount IN NUMBER, p_date IN DATE, p_funding IN VARCHAR2, p_bank_account_id IN NUMBER,
                    p_cash_box_id IN NUMBER, p_party_id IN NUMBER, p_account_id IN NUMBER, p_vat IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_a     fa_asset%ROWTYPE := asset_row(p_asset_id, TRUE);
    l_b     fa_asset_book%ROWTYPE;
    l_c     fa_category%ROWTYPE;
    l_amt   NUMBER := ROUND(p_amount, 2);
    l_vat   NUMBER := NVL(ROUND(p_vat, 2), 0);
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
    l_tx    NUMBER;
    l_src   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
  BEGIN
    guard('FA_TRANSACTION.POST');
    assert_active(l_a);
    NOONA_CORE_PKG.assert(l_amt > 0, 'NOONA-FA-041', 'مبلغ الإضافة يجب أن يكون موجباً', 'Amount must be positive');
    l_b := book_row(p_asset_id);
    SELECT * INTO l_c FROM fa_category WHERE id = l_a.category_id;
    l_src := source_account(NVL(p_funding, 'BANK'), p_bank_account_id, p_cash_box_id, p_party_id, p_account_id);
    l_tx := new_txn(p_asset_id, l_b.book_id, 'ADDITION', l_date, l_amt,
                    '{"cost":' || jn(l_b.cost) || '}', '{"cost":' || jn(l_b.cost + l_amt) || ',"funding":"' || NVL(p_funding, 'BANK')
                    || '","vat":' || jn(l_vat) || '}', p_reason);
    add_line(l_lines, l_c.asset_account_id, l_amt, 0, NULL, 'إضافة رأسمالية ' || l_a.asset_no || ' - ' || p_reason);
    IF l_vat > 0 THEN
      add_line(l_lines, need_acc('1107'), l_vat, 0, NULL, 'ضريبة مدخلات إضافة أصل ' || l_a.asset_no);
    END IF;
    add_line(l_lines, l_src, 0, l_amt + l_vat, NULL, 'إضافة على الأصل ' || l_a.asset_no, CASE WHEN p_funding = 'PAYABLE' THEN p_party_id END);
    l_j := NOONA_ACE_PKG.post_source('FA_ASSET_ADJUSTED', 'ASSETS', 'FA_TRANSACTION', l_tx, l_date,
             'إضافة رأسمالية على الأصل ' || l_a.asset_no || ' - ' || l_a.name_ar, NOONA_GL_PKG.ledger_currency, 1, l_lines,
             l_a.asset_no, l_a.branch_id, 'FA_ACQUISITION');
    mark_posted(l_tx);
    UPDATE fa_asset_book SET cost = cost + l_amt, net_book_value = net_book_value + l_amt,
                             status_code = CASE WHEN depreciation_method <> 'NONE' AND cost + l_amt - accumulated_depr <= residual_value
                                                THEN 'FULLY_DEPRECIATED' ELSE 'ACTIVE' END
     WHERE id = l_b.id;
    UPDATE fa_asset SET status_code = 'IN_SERVICE' WHERE id = p_asset_id AND status_code = 'FULLY_DEPRECIATED'
       AND l_b.cost + l_amt - l_b.accumulated_depr > l_b.residual_value;
    RETURN l_tx;
  END add_cost;

  FUNCTION impair(p_asset_id IN NUMBER, p_amount IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_a     fa_asset%ROWTYPE := asset_row(p_asset_id, TRUE);
    l_b     fa_asset_book%ROWTYPE;
    l_c     fa_category%ROWTYPE;
    l_amt   NUMBER := ROUND(p_amount, 2);
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
    l_tx    NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
  BEGIN
    guard('FA_TRANSACTION.POST');
    assert_active(l_a);
    l_b := book_row(p_asset_id);
    SELECT * INTO l_c FROM fa_category WHERE id = l_a.category_id;
    NOONA_CORE_PKG.assert(l_amt > 0 AND l_amt <= l_b.cost - l_b.accumulated_depr, 'NOONA-FA-042',
      'مبلغ الانخفاض موجب ولا يتجاوز صافي القيمة الدفترية ' || fnum(l_b.cost - l_b.accumulated_depr), 'Impairment exceeds NBV');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-FA-043', 'سبب الانخفاض مطلوب', 'Reason required');
    l_tx := new_txn(p_asset_id, l_b.book_id, 'IMPAIRMENT', l_date, l_amt, '{"nbv":' || jn(l_b.cost - l_b.accumulated_depr) || '}',
                    '{"nbv":' || jn(l_b.cost - l_b.accumulated_depr - l_amt) || '}', p_reason);
    add_line(l_lines, need_acc('5218'), l_amt, 0, l_a.cost_center_id, 'انخفاض قيمة الأصل ' || l_a.asset_no);
    add_line(l_lines, NVL(l_c.accum_depr_account_id, need_acc('1209')), 0, l_amt, NULL, 'انخفاض قيمة الأصل ' || l_a.asset_no);
    l_j := NOONA_ACE_PKG.post_source('FA_ASSET_ADJUSTED', 'ASSETS', 'FA_TRANSACTION', l_tx, l_date,
             'انخفاض في قيمة الأصل ' || l_a.asset_no || ' - ' || p_reason, NOONA_GL_PKG.ledger_currency, 1, l_lines,
             l_a.asset_no, l_a.branch_id, 'FA_ACQUISITION');
    mark_posted(l_tx);
    UPDATE fa_asset_book SET accumulated_depr = accumulated_depr + l_amt, net_book_value = cost - accumulated_depr - l_amt,
                             residual_value = LEAST(residual_value, cost - accumulated_depr - l_amt)
     WHERE id = l_b.id;
    RETURN l_tx;
  END impair;

  FUNCTION change_life(p_asset_id IN NUMBER, p_life_months IN NUMBER, p_residual IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_a  fa_asset%ROWTYPE := asset_row(p_asset_id, TRUE);
    l_b  fa_asset_book%ROWTYPE;
    l_tx NUMBER;
    l_e  NUMBER;
    l_r  NUMBER;
  BEGIN
    guard('FA_TRANSACTION.CREATE');
    assert_active(l_a);
    l_b := book_row(p_asset_id);
    l_r := NVL(ROUND(p_residual, 2), l_b.residual_value);
    l_e := elapsed(l_b.depr_start_date, l_b.depreciated_to, 100000);
    NOONA_CORE_PKG.assert(l_b.depreciation_method = 'NONE' OR p_life_months > l_e, 'NOONA-FA-044',
      'العمر الجديد يجب أن يتجاوز الأشهر المنقضية (' || ROUND(l_e, 1) || ')', 'New life must exceed elapsed months');
    NOONA_CORE_PKG.assert(l_r >= 0 AND l_r <= l_b.cost - l_b.accumulated_depr, 'NOONA-FA-045',
      'القيمة المتبقية لا تتجاوز صافي القيمة الدفترية', 'Residual exceeds NBV');
    l_tx := new_txn(p_asset_id, l_b.book_id, 'LIFE_CHANGE', NVL(p_date, TRUNC(SYSDATE)), NULL,
                    '{"life":' || jn(l_b.useful_life_months) || ',"residual":' || jn(l_b.residual_value) || '}',
                    '{"life":' || jn(p_life_months) || ',"residual":' || jn(l_r) || '}', p_reason, 'POSTED');
    UPDATE fa_asset_book SET useful_life_months = NVL(p_life_months, useful_life_months), residual_value = l_r,
                             status_code = CASE WHEN depreciation_method <> 'NONE' AND cost - accumulated_depr <= l_r THEN 'FULLY_DEPRECIATED' ELSE 'ACTIVE' END
     WHERE id = l_b.id;
    UPDATE fa_asset SET status_code = CASE WHEN l_b.depreciation_method <> 'NONE' AND l_b.cost - l_b.accumulated_depr <= l_r
                                           THEN 'FULLY_DEPRECIATED' ELSE 'IN_SERVICE' END
     WHERE id = p_asset_id;
    RETURN l_tx;
  END change_life;

  FUNCTION transfer(p_asset_id IN NUMBER, p_date IN DATE, p_branch_id IN NUMBER, p_cost_center_id IN NUMBER, p_custodian_id IN NUMBER,
                    p_location IN VARCHAR2, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_a  fa_asset%ROWTYPE := asset_row(p_asset_id, TRUE);
    l_tx NUMBER;
    l_d  DATE := NVL(p_date, TRUNC(SYSDATE));
  BEGIN
    guard('FA_TRANSFER.CREATE');
    assert_active(l_a);
    NOONA_CORE_PKG.assert(COALESCE(p_branch_id, p_cost_center_id, p_custodian_id) IS NOT NULL OR TRIM(p_location) IS NOT NULL,
      'NOONA-FA-046', 'حدد الفرع أو مركز التكلفة أو العهدة أو الموقع الجديد', 'Nothing to transfer');
    ensure_sequence('FA_TRANSFER', 'FAN-');
    INSERT INTO fa_transfer (company_id, doc_no, doc_date, asset_id, from_branch_id, to_branch_id, from_custodian_id, to_custodian_id,
                             transfer_date, reason, status_code)
    VALUES (company, next_no('FA_TRANSFER', l_d), l_d, p_asset_id, l_a.branch_id, NVL(p_branch_id, l_a.branch_id),
            l_a.custodian_employee_id, NVL(p_custodian_id, l_a.custodian_employee_id), l_d, SUBSTR(p_reason, 1, 1000), 'COMPLETED');
    l_tx := new_txn(p_asset_id, default_book, 'TRANSFER', l_d, NULL,
                    '{"branch":' || jn(l_a.branch_id) || ',"cost_center":' || jn(l_a.cost_center_id) || ',"custodian":'
                    || jn(l_a.custodian_employee_id) || ',"location":' || NOONA_CORE_PKG.json_text(l_a.location_text) || '}',
                    '{"branch":' || jn(NVL(p_branch_id, l_a.branch_id)) || ',"cost_center":' || jn(NVL(p_cost_center_id, l_a.cost_center_id))
                    || ',"custodian":' || jn(NVL(p_custodian_id, l_a.custodian_employee_id)) || ',"location":'
                    || NOONA_CORE_PKG.json_text(NVL(TRIM(p_location), l_a.location_text)) || '}', p_reason, 'POSTED');
    UPDATE fa_asset SET branch_id = NVL(p_branch_id, branch_id), cost_center_id = NVL(p_cost_center_id, cost_center_id),
                        custodian_employee_id = NVL(p_custodian_id, custodian_employee_id),
                        location_text = NVL(TRIM(p_location), location_text)
     WHERE id = p_asset_id;
    RETURN l_tx;
  END transfer;

  FUNCTION dispose(p_asset_id IN NUMBER, p_method IN VARCHAR2, p_date IN DATE, p_proceeds IN NUMBER, p_vat IN NUMBER,
                   p_receipt IN VARCHAR2, p_bank_account_id IN NUMBER, p_cash_box_id IN NUMBER, p_party_id IN NUMBER,
                   p_reason IN VARCHAR2) RETURN NUMBER IS
    l_a     fa_asset%ROWTYPE := asset_row(p_asset_id, TRUE);
    l_b     fa_asset_book%ROWTYPE;
    l_c     fa_category%ROWTYPE;
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
    l_proc  NUMBER := NVL(ROUND(p_proceeds, 2), 0);
    l_vat   NUMBER := NVL(ROUND(p_vat, 2), 0);
    l_catch NUMBER;
    l_last  NUMBER;
    l_pst   DATE;
    l_accum NUMBER;
    l_nbv   NUMBER;
    l_gl    NUMBER;
    l_src   NUMBER;
    l_id    NUMBER;
    l_tx    NUMBER;
    l_ev    NUMBER;
    l_no    VARCHAR2(50);
    l_party NUMBER;
    l_accd  NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
  BEGIN
    guard('FA_DISPOSAL.POST');
    assert_active(l_a);
    NOONA_CORE_PKG.assert(p_method IN ('SALE', 'SCRAP', 'DONATION', 'LOSS', 'THEFT', 'TRADE_IN'), 'NOONA-FA-050',
      'طريقة الاستبعاد غير صحيحة', 'Invalid disposal method');
    NOONA_CORE_PKG.assert(l_proc >= 0 AND l_vat >= 0, 'NOONA-FA-051', 'المتحصلات والضريبة لا تكون سالبة', 'Negative amounts');
    NOONA_CORE_PKG.assert(p_method IN ('SALE', 'SCRAP', 'TRADE_IN') OR (l_proc = 0 AND l_vat = 0), 'NOONA-FA-052',
      'التبرع والفقد والسرقة بلا متحصلات', 'Donation/loss/theft have no proceeds');
    NOONA_CORE_PKG.assert(p_method <> 'SALE' OR l_proc > 0, 'NOONA-FA-053', 'أدخل سعر البيع', 'Sale price required');
    l_b := book_row(p_asset_id);
    SELECT * INTO l_c FROM fa_category WHERE id = l_a.category_id;
    NOONA_CORE_PKG.assert(l_date >= l_a.acquisition_date, 'NOONA-FA-054', 'تاريخ الاستبعاد يسبق تاريخ اقتناء الأصل',
      'Disposal date precedes acquisition');
    IF l_b.depreciated_to IS NOT NULL AND l_date < l_b.depreciated_to THEN
      -- الاستبعاد داخل فترة مهلكة: يرد الجزء الزائد من إهلاك آخر فترة (لحاق سالب)
      BEGIN
        SELECT amt, pst INTO l_last, l_pst FROM (
          SELECT l.depreciation_amount amt, p.start_date pst FROM fa_depreciation_line l JOIN fa_depreciation_run r ON r.id = l.run_id
            JOIN gl_period p ON p.id = l.period_id
           WHERE l.asset_book_id = l_b.id AND r.status_code = 'POSTED' ORDER BY p.start_date DESC)
         WHERE ROWNUM = 1;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_last := 0; l_pst := l_b.depreciated_to;
      END;
      NOONA_CORE_PKG.assert(l_date >= l_pst - 1, 'NOONA-FA-054',
        'تاريخ الاستبعاد يسبق آخر فترة إهلاك مرحلة (' || fd(l_pst) || ')؛ اعكس تشغيلات الإهلاك اللاحقة أولاً',
        'Disposal date precedes the last posted depreciation period');
      l_catch := calc(l_b.cost, l_b.residual_value, l_b.accumulated_depr - l_last, l_b.depreciation_method, l_b.useful_life_months,
                      l_b.depr_start_date, prev_done_to(l_b.id, l_b.asset_id, NULL, l_pst), l_date) - l_last;
    ELSE
      -- لحاق الإهلاك حتى تاريخ الاستبعاد
      l_catch := calc_book(l_b, l_date);
    END IF;
    l_accum := l_b.accumulated_depr + l_catch;
    l_nbv := l_b.cost - l_accum;
    l_gl := l_proc - l_nbv;
    l_accd := NVL(l_c.accum_depr_account_id, need_acc('1209'));
    IF l_proc + l_vat > 0 THEN
      l_src := source_account(NVL(p_receipt, 'BANK'), p_bank_account_id, p_cash_box_id, p_party_id, NULL);
      l_party := CASE WHEN p_receipt = 'RECEIVABLE' THEN p_party_id END;
    END IF;
    ensure_sequence('FA_DISPOSAL', 'FAD-');
    l_no := next_no('FA_DISPOSAL', l_date);
    INSERT INTO fa_disposal (company_id, doc_no, doc_date, asset_id, disposal_method, disposal_date, proceeds, nbv_at_disposal, gain_loss,
                             buyer_party_id, vat_amount, reason, status_code)
    VALUES (company, l_no, l_date, p_asset_id, p_method, l_date, l_proc, l_nbv, l_gl, p_party_id, l_vat, SUBSTR(p_reason, 1, 1000), 'APPROVED')
    RETURNING id INTO l_id;
    l_tx := new_txn(p_asset_id, l_b.book_id, 'DISPOSAL', l_date, l_b.cost,
                    '{"accum":' || jn(l_b.accumulated_depr) || ',"nbv":' || jn(l_b.net_book_value) || ',"depreciated_to":'
                    || CASE WHEN l_b.depreciated_to IS NULL THEN 'null' ELSE '"' || fd(l_b.depreciated_to) || '"' END
                    || ',"book_status":"' || l_b.status_code || '","asset_status":"' || l_a.status_code || '"}',
                    '{"catchup":' || jn(l_catch) || ',"accum":' || jn(l_accum) || ',"disposal":' || l_id || '}',
                    disposal_label(p_method) || ' - ' || p_reason);
    IF l_catch <> 0 THEN
      add_line(l_lines, l_c.depr_expense_account_id, l_catch, 0, l_a.cost_center_id,
               CASE WHEN l_catch > 0 THEN 'إهلاك حتى تاريخ الاستبعاد ' ELSE 'رد إهلاك ما بعد تاريخ الاستبعاد ' END || l_a.asset_no);
      add_line(l_lines, l_accd, 0, l_catch, NULL, 'مجمع إهلاك حتى تاريخ الاستبعاد ' || l_a.asset_no, NULL, FALSE);
    END IF;
    add_line(l_lines, l_accd, l_accum, 0, NULL, 'إقفال مجمع إهلاك الأصل ' || l_a.asset_no, NULL, FALSE);
    IF l_proc + l_vat > 0 THEN
      add_line(l_lines, l_src, l_proc + l_vat, 0, NULL, disposal_label(p_method) || ' الأصل ' || l_a.asset_no, l_party);
    END IF;
    IF l_vat > 0 THEN
      add_line(l_lines, need_acc('2104'), 0, l_vat, NULL, 'ضريبة القيمة المضافة على بيع الأصل ' || l_a.asset_no);
    END IF;
    add_line(l_lines, l_c.asset_account_id, 0, l_b.cost, NULL, 'استبعاد تكلفة الأصل ' || l_a.asset_no);
    IF l_gl > 0 THEN
      add_line(l_lines, NVL(l_c.gain_loss_account_id, need_acc('4204')), 0, l_gl, NULL, 'ربح ' || disposal_label(p_method) || ' الأصل ' || l_a.asset_no);
    ELSIF l_gl < 0 THEN
      add_line(l_lines, need_acc('5217'), -l_gl, 0, l_a.cost_center_id, 'خسارة ' || disposal_label(p_method) || ' الأصل ' || l_a.asset_no);
    END IF;
    l_j := NOONA_ACE_PKG.post_source('FA_ASSET_DISPOSED', 'ASSETS', 'FA_DISPOSAL', l_id, l_date,
             disposal_label(p_method) || ' أصل ثابت ' || l_a.asset_no || ' - ' || l_a.name_ar, NOONA_GL_PKG.ledger_currency, 1, l_lines,
             l_no, l_a.branch_id, 'FA_DISPOSAL');
    SELECT MAX(id) INTO l_ev FROM ace_accounting_event
     WHERE source_entity_type = 'FA_DISPOSAL' AND source_entity_id = l_id AND status_code = 'POSTED' AND reversal_of_event_id IS NULL;
    UPDATE fa_disposal SET status_code = 'POSTED', accounting_event_id = l_ev, posted_at = SYSTIMESTAMP,
                           posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = l_id;
    UPDATE fa_transaction SET status_code = 'POSTED', accounting_event_id = l_ev, posted_at = SYSTIMESTAMP,
                              posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = l_tx;
    UPDATE fa_asset_book SET accumulated_depr = l_accum, net_book_value = 0, depreciated_to = l_date, status_code = 'DISPOSED' WHERE id = l_b.id;
    UPDATE fa_asset SET status_code = 'DISPOSED' WHERE id = p_asset_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'FA_DISPOSAL', l_id, 'POST', 'SUCCESS');
    RETURN l_id;
  END dispose;

  FUNCTION reverse_disposal(p_disposal_id IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_d   fa_disposal%ROWTYPE;
    l_t   fa_transaction%ROWTYPE;
    l_j   NUMBER;
    l_acc NUMBER;
    l_nbv NUMBER;
    l_to  VARCHAR2(30);
    l_bs  VARCHAR2(30);
    l_as  VARCHAR2(30);
  BEGIN
    guard('FA_DISPOSAL.REVERSE');
    SELECT * INTO l_d FROM fa_disposal WHERE id = p_disposal_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_d.status_code = 'POSTED', 'NOONA-FA-055', 'الاستبعاد غير مرحل', 'Disposal is not posted');
    SELECT * INTO l_t FROM fa_transaction WHERE asset_id = l_d.asset_id AND txn_type = 'DISPOSAL' AND status_code = 'POSTED'
       AND JSON_VALUE(new_values, '$.disposal' RETURNING NUMBER) = p_disposal_id FOR UPDATE;
    l_j := NOONA_ACE_PKG.reverse_source('FA_DISPOSAL', p_disposal_id, l_d.disposal_date, NVL(p_reason, 'عكس استبعاد ' || l_d.doc_no));
    SELECT JSON_VALUE(l_t.old_values, '$.accum' RETURNING NUMBER), JSON_VALUE(l_t.old_values, '$.nbv' RETURNING NUMBER),
           JSON_VALUE(l_t.old_values, '$.depreciated_to'), JSON_VALUE(l_t.old_values, '$.book_status'),
           JSON_VALUE(l_t.old_values, '$.asset_status')
      INTO l_acc, l_nbv, l_to, l_bs, l_as FROM dual;
    UPDATE fa_asset_book SET accumulated_depr = l_acc, net_book_value = l_nbv,
                             depreciated_to = CASE WHEN l_to IS NOT NULL THEN TO_DATE(l_to, 'YYYY-MM-DD') END, status_code = l_bs
     WHERE asset_id = l_d.asset_id AND book_id = l_t.book_id;
    UPDATE fa_asset SET status_code = l_as WHERE id = l_d.asset_id;
    UPDATE fa_transaction SET status_code = 'REVERSED' WHERE id = l_t.id;
    UPDATE fa_disposal SET status_code = 'CANCELLED', reason = SUBSTR(reason || ' | عكس: ' || p_reason, 1, 1000) WHERE id = p_disposal_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'FA_DISPOSAL', p_disposal_id, 'REVERSE', 'SUCCESS');
    RETURN l_j;
  END reverse_disposal;

  -- ================================================================ التقارير
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION fa_summary RETURN CLOB IS
    l_cnt  NUMBER;
    l_cost NUMBER;
    l_acc  NUMBER;
    l_yr   NUMBER;
    l_drf  NUMBER;
    l_last VARCHAR2(20);
    l_fy   DATE;
  BEGIN
    SELECT COUNT(*), NVL(SUM(b.cost), 0), NVL(SUM(b.accumulated_depr), 0) INTO l_cnt, l_cost, l_acc
      FROM fa_asset a JOIN fa_asset_book b ON b.asset_id = a.id AND b.book_id = default_book
     WHERE a.company_id = company AND a.status_code IN ('IN_SERVICE', 'CAPITALIZED', 'FULLY_DEPRECIATED', 'SUSPENDED');
    SELECT COUNT(*) INTO l_drf FROM fa_asset WHERE company_id = company AND status_code = 'DRAFT';
    BEGIN
      l_fy := NOONA_GL_PKG.fy_start(TRUNC(SYSDATE));
    EXCEPTION WHEN OTHERS THEN l_fy := TRUNC(SYSDATE, 'YYYY');
    END;
    SELECT NVL(SUM(l.depreciation_amount), 0), MAX(p.period_code) KEEP (DENSE_RANK LAST ORDER BY p.start_date) INTO l_yr, l_last
      FROM fa_depreciation_line l JOIN fa_depreciation_run r ON r.id = l.run_id AND r.status_code = 'POSTED'
      JOIN gl_period p ON p.id = l.period_id
     WHERE l.company_id = company AND p.start_date >= l_fy;
    RETURN '<div class="nn-kpis">'
        || kpi('الأصول في الخدمة', l_cnt, 'fa-cubes', 'is-info')
        || kpi('إجمالي التكلفة', fnum(l_cost), 'fa-building', 'is-info')
        || kpi('مجمع الإهلاك', fnum(l_acc), 'fa-line-chart', 'is-warning')
        || kpi('صافي القيمة الدفترية', fnum(l_cost - l_acc), 'fa-money', 'is-success')
        || kpi('إهلاك السنة' || CASE WHEN l_last IS NOT NULL THEN ' (حتى ' || l_last || ')' END, fnum(l_yr), 'fa-calendar', 'is-info')
        || kpi('أصول مسودة بانتظار الرسملة', l_drf, 'fa-hourglass-half', CASE WHEN l_drf > 0 THEN 'is-warning' ELSE 'is-info' END)
        || '</div>';
  END fa_summary;

  FUNCTION row2(p_k VARCHAR2, p_v VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<tr><td class="nn-rpt-text">' || esc(p_k) || '</td><td class="nn-rpt-text">' || p_v || '</td></tr>';
  END row2;

  FUNCTION asset_card_html(p_asset_id IN NUMBER) RETURN CLOB IS
    l_a   fa_asset%ROWTYPE := asset_row(p_asset_id);
    l_b   fa_asset_book%ROWTYPE;
    l_cat VARCHAR2(200);
    l_br  VARCHAR2(200);
    l_cc  VARCHAR2(200);
    l_cu  VARCHAR2(400);
    l_rem NUMBER;
    l_out CLOB;
  BEGIN
    SELECT * INTO l_b FROM fa_asset_book WHERE asset_id = p_asset_id AND book_id = default_book;
    SELECT MAX(name_ar) INTO l_cat FROM fa_category WHERE id = l_a.category_id;
    SELECT MAX(name_ar) INTO l_br FROM org_branch WHERE id = l_a.branch_id;
    SELECT MAX(code || ' - ' || name_ar) INTO l_cc FROM gl_cost_center WHERE id = l_a.cost_center_id;
    SELECT MAX(p.display_name_ar) INTO l_cu FROM hr_employee e JOIN pty_party p ON p.id = e.person_party_id WHERE e.id = l_a.custodian_employee_id;
    l_rem := CASE WHEN l_b.depreciation_method = 'NONE' OR l_b.status_code = 'DISPOSED' THEN NULL
                  ELSE GREATEST(l_b.useful_life_months - elapsed(l_b.depr_start_date, l_b.depreciated_to, l_b.useful_life_months), 0) END;
    l_out := '<div class="nn-kpis">' || kpi('التكلفة', fnum(l_b.cost), 'fa-building')
          || kpi('مجمع الإهلاك والانخفاض', fnum(l_b.accumulated_depr), 'fa-line-chart', 'is-warning')
          || kpi('صافي القيمة الدفترية', fnum(CASE WHEN l_b.status_code = 'DISPOSED' THEN 0 ELSE l_b.cost - l_b.accumulated_depr END), 'fa-money', 'is-success')
          || kpi('العمر المتبقي (شهر)', NVL(TO_CHAR(ROUND(l_rem, 1)), '-'), 'fa-hourglass-half') || '</div>'
          || '<div class="nn-fa-card"><table class="nn-rpt"><tbody>'
          || row2('رقم الأصل', esc(l_a.asset_no) || ' <span class="nn-badge ' || CASE WHEN l_a.status_code IN ('IN_SERVICE', 'CAPITALIZED') THEN 'is-success'
                  WHEN l_a.status_code = 'DISPOSED' THEN 'is-danger' ELSE 'is-warning' END || '">' || status_label(l_a.status_code) || '</span>')
          || row2('الاسم', esc(l_a.name_ar)) || row2('الفئة', esc(l_cat)) || row2('رقم الملصق', esc(l_a.tag_no))
          || row2('الفرع', esc(l_br)) || row2('مركز التكلفة', esc(l_cc)) || row2('العهدة', esc(l_cu)) || row2('الموقع', esc(l_a.location_text))
          || row2('الرقم التسلسلي / الصانع / الموديل', esc(NULLIF(l_a.serial_no || ' / ' || l_a.manufacturer || ' / ' || l_a.model_no, ' /  / ')))
          || row2('نهاية الضمان', fd(l_a.warranty_end))
          || '</tbody></table><table class="nn-rpt"><tbody>'
          || row2('تاريخ الاقتناء', fd(l_a.acquisition_date)) || row2('تاريخ التشغيل', fd(l_a.in_service_date))
          || row2('طريقة الإهلاك', method_label(l_b.depreciation_method))
          || row2('العمر الإنتاجي', CASE WHEN l_b.useful_life_months IS NOT NULL THEN l_b.useful_life_months || ' شهر ('
                  || ROUND(l_b.useful_life_months / 12, 1) || ' سنة)' END)
          || row2('بداية الإهلاك', fd(l_b.depr_start_date)) || row2('مهلك حتى', fd(l_b.depreciated_to))
          || row2('التكلفة الأصلية', fnum(l_a.original_cost)) || row2('القيمة المتبقية', fnum(l_b.residual_value))
          || row2('القسط الشهري الحالي التقريبي', fnum(CASE WHEN l_b.status_code = 'ACTIVE'
                  THEN calc_book(l_b, LAST_DAY(ADD_MONTHS(NVL(l_b.depreciated_to, GREATEST(l_b.depr_start_date, TRUNC(SYSDATE)) - 1), 1))) END))
          || '</tbody></table></div>';
    -- الحركات
    l_out := l_out || ('<h3 class="nn-fa-h">الحركات</h3><div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>المستند</th><th>التاريخ</th>'
          || '<th>الحركة</th><th>المبلغ</th><th>البيان</th><th>الحالة</th></tr></thead><tbody>');
    FOR t IN (SELECT doc_no, txn_date, txn_type, amount, reason, status_code FROM fa_transaction WHERE asset_id = p_asset_id
              ORDER BY txn_date, id) LOOP
      l_out := l_out || ('<tr><td>' || esc(t.doc_no) || '</td><td>' || fd(t.txn_date) || '</td><td class="nn-rpt-text">' || txn_label(t.txn_type)
            || '</td><td>' || fnum(t.amount) || '</td><td class="nn-rpt-text">' || esc(t.reason) || '</td><td class="nn-rpt-text">'
            || status_label(t.status_code) || '</td></tr>');
    END LOOP;
    FOR d IN (SELECT doc_no, disposal_date, disposal_method, proceeds, nbv_at_disposal, gain_loss, status_code FROM fa_disposal
               WHERE asset_id = p_asset_id ORDER BY id) LOOP
      l_out := l_out || ('<tr><td>' || esc(d.doc_no) || '</td><td>' || fd(d.disposal_date) || '</td><td class="nn-rpt-text">'
            || disposal_label(d.disposal_method) || '</td><td>' || fnum(d.proceeds) || '</td><td class="nn-rpt-text">صافي '
            || fnum(d.nbv_at_disposal) || ' · ' || CASE WHEN d.gain_loss >= 0 THEN 'ربح ' ELSE 'خسارة ' END || fnum(ABS(d.gain_loss))
            || '</td><td class="nn-rpt-text">' || status_label(d.status_code) || '</td></tr>');
    END LOOP;
    l_out := l_out || ('</tbody></table></div>');
    -- الإهلاك المرحل
    l_out := l_out || ('<h3 class="nn-fa-h">الإهلاك المرحل</h3><div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>الفترة</th>'
          || '<th>إهلاك الفترة</th><th>المجمع بعد</th><th>الصافي بعد</th></tr></thead><tbody>');
    FOR l IN (SELECT p.period_code, l.depreciation_amount, l.accumulated_after, l.nbv_after FROM fa_depreciation_line l
                JOIN gl_period p ON p.id = l.period_id JOIN fa_depreciation_run r ON r.id = l.run_id AND r.status_code = 'POSTED'
               WHERE l.asset_book_id = l_b.id ORDER BY p.start_date) LOOP
      l_out := l_out || ('<tr><td>' || l.period_code || '</td><td>' || fnum(l.depreciation_amount) || '</td><td>' || fnum(l.accumulated_after)
            || '</td><td>' || fnum(l.nbv_after) || '</td></tr>');
    END LOOP;
    RETURN l_out || ('</tbody></table></div>');
  END asset_card_html;

  FUNCTION schedule_html(p_asset_id IN NUMBER) RETURN CLOB IS
    l_b   fa_asset_book%ROWTYPE;
    l_d   DATE;
    l_m   NUMBER;
    l_tot NUMBER := 0;
    l_n   PLS_INTEGER := 0;
    l_yr  NUMBER;
    l_ysum NUMBER := 0;
    l_out CLOB := '<div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>الشهر</th><th>إهلاك الشهر</th><th>المجمع</th><th>الصافي</th></tr></thead><tbody>';
  BEGIN
    SELECT * INTO l_b FROM fa_asset_book WHERE asset_id = p_asset_id AND book_id = default_book AND company_id = company;
    IF l_b.status_code <> 'ACTIVE' OR l_b.depreciation_method = 'NONE' THEN
      RETURN '<div class="nn-empty">لا يوجد إهلاك متوقع: ' || CASE WHEN l_b.depreciation_method = 'NONE' THEN 'الأصل لا يهلك'
             ELSE status_label(l_b.status_code) END || '</div>';
    END IF;
    l_d := LAST_DAY(GREATEST(NVL(l_b.depreciated_to + 1, l_b.depr_start_date), l_b.depr_start_date));
    WHILE l_n < 720 AND l_b.cost - l_b.accumulated_depr > l_b.residual_value LOOP
      l_m := calc_book(l_b, l_d);
      l_yr := EXTRACT(YEAR FROM l_d);
      l_b.accumulated_depr := l_b.accumulated_depr + l_m;
      l_b.depreciated_to := l_d;
      l_tot := l_tot + l_m;
      l_ysum := l_ysum + l_m;
      l_out := l_out || ('<tr><td>' || TO_CHAR(l_d, 'YYYY-MM') || '</td><td>' || fnum(l_m) || '</td><td>' || fnum(l_b.accumulated_depr)
            || '</td><td>' || fnum(l_b.cost - l_b.accumulated_depr) || '</td></tr>');
      l_d := LAST_DAY(l_d + 1);
      IF EXTRACT(YEAR FROM l_d) <> l_yr OR l_b.cost - l_b.accumulated_depr <= l_b.residual_value THEN
        l_out := l_out || ('<tr class="nn-rpt-sub"><td>إجمالي ' || l_yr || '</td><td>' || fnum(l_ysum) || '</td><td></td><td></td></tr>');
        l_ysum := 0;
      END IF;
      l_n := l_n + 1;
    END LOOP;
    RETURN l_out || ('<tr class="nn-rpt-total"><td>إجمالي المتبقي</td><td>' || fnum(l_tot) || '</td><td></td><td></td></tr></tbody></table></div>');
  END schedule_html;

  FUNCTION register_html(p_category_id IN NUMBER DEFAULT NULL, p_branch_id IN NUMBER DEFAULT NULL,
                         p_show IN VARCHAR2 DEFAULT 'ACTIVE', p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_out CLOB := '<div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>رقم الأصل</th><th>الأصل</th><th>الفئة</th><th>الفرع</th>'
               || '<th>مركز التكلفة</th><th>تاريخ التشغيل</th><th>التكلفة</th><th>مجمع الإهلاك</th><th>الصافي</th><th>العمر المتبقي</th>'
               || '<th>الحالة</th></tr></thead><tbody>';
    l_c NUMBER := 0;
    l_a NUMBER := 0;
    l_n PLS_INTEGER := 0;
  BEGIN
    FOR r IN (SELECT a.id, a.asset_no, a.name_ar, c.name_ar cat, br.name_ar br, cc.name_ar cc, a.in_service_date, b.cost,
                     b.accumulated_depr, b.status_code bst, a.status_code, b.depreciation_method, b.useful_life_months,
                     b.depr_start_date, b.depreciated_to
                FROM fa_asset a JOIN fa_asset_book b ON b.asset_id = a.id AND b.book_id = NOONA_FA_PKG.default_book
                JOIN fa_category c ON c.id = a.category_id LEFT JOIN org_branch br ON br.id = a.branch_id
                LEFT JOIN gl_cost_center cc ON cc.id = a.cost_center_id
               WHERE a.company_id = NOONA_FA_PKG.company AND (p_category_id IS NULL OR a.category_id = p_category_id)
                 AND (p_branch_id IS NULL OR a.branch_id = p_branch_id)
                 AND (NVL(p_show, 'ACTIVE') = 'ALL' OR (p_show = 'DISPOSED' AND a.status_code = 'DISPOSED')
                      OR (NVL(p_show, 'ACTIVE') = 'ACTIVE' AND a.status_code NOT IN ('DISPOSED', 'RETIRED', 'DRAFT')))
               ORDER BY c.code, a.asset_no) LOOP
      l_out := l_out || ('<tr><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(r.asset_no) || '</a>'
                                           ELSE esc(r.asset_no) END
            || '</td><td class="nn-rpt-text">' || esc(r.name_ar) || '</td><td class="nn-rpt-text">' || esc(r.cat) || '</td><td class="nn-rpt-text">'
            || esc(r.br) || '</td><td class="nn-rpt-text">' || esc(r.cc) || '</td><td>' || fd(r.in_service_date) || '</td><td>' || fnum(r.cost)
            || '</td><td>' || fnum(r.accumulated_depr) || '</td><td>' || fnum(CASE WHEN r.bst = 'DISPOSED' THEN 0 ELSE r.cost - r.accumulated_depr END)
            || '</td><td>' || CASE WHEN r.depreciation_method = 'NONE' THEN '-' ELSE TO_CHAR(ROUND(GREATEST(r.useful_life_months
                  - elapsed(r.depr_start_date, r.depreciated_to, r.useful_life_months), 0), 1)) || ' شهر' END
            || '</td><td class="nn-rpt-text">' || status_label(r.status_code) || '</td></tr>');
      IF r.bst <> 'DISPOSED' THEN
        l_c := l_c + r.cost;
        l_a := l_a + r.accumulated_depr;
      END IF;
      l_n := l_n + 1;
    END LOOP;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty">لا توجد أصول مطابقة</div>';
    END IF;
    RETURN l_out || ('<tr class="nn-rpt-total"><td colspan="6" class="nn-rpt-text">الإجمالي (' || l_n || ' أصل)</td><td>' || fnum(l_c) || '</td><td>'
        || fnum(l_a) || '</td><td>' || fnum(l_c - l_a) || '</td><td></td><td></td></tr></tbody></table></div>');
  END register_html;

  FUNCTION gl_balance(p_accounts VARCHAR2, p_to DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(NVL(l.debit_func, 0) - NVL(l.credit_func, 0)), 0) INTO l
      FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
     WHERE j.company_id = company AND j.status_code = 'POSTED' AND j.doc_date <= p_to
       AND l.account_id IN (SELECT TO_NUMBER(COLUMN_VALUE) FROM TABLE(apex_string.split(p_accounts, ',')));
    RETURN l;
  END gl_balance;

  FUNCTION rollforward_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_out CLOB := '<div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th rowspan="2">الفئة</th><th colspan="4">التكلفة</th>'
               || '<th colspan="5">مجمع الإهلاك والانخفاض</th><th rowspan="2">صافي القيمة آخر المدة</th></tr><tr><th>أول المدة</th><th>إضافات</th>'
               || '<th>استبعادات</th><th>آخر المدة</th><th>أول المدة</th><th>إهلاك المدة</th><th>انخفاض وأرصدة منقولة</th><th>مجمع المستبعد</th>'
               || '<th>آخر المدة</th></tr></thead><tbody>';
    t SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(0, 0, 0, 0, 0, 0, 0, 0, 0);
    l_aacc VARCHAR2(4000);
    l_dacc VARCHAR2(4000);
    l_glc  NUMBER;
    l_gld  NUMBER;
  BEGIN
    FOR r IN (WITH mv AS (
                SELECT a.category_id, t.txn_date d,
                       CASE t.txn_type WHEN 'CAPITALIZATION' THEN t.amount WHEN 'ADDITION' THEN t.amount ELSE 0 END add_c,
                       CASE t.txn_type WHEN 'DISPOSAL' THEN t.amount ELSE 0 END dis_c,
                       CASE t.txn_type WHEN 'DISPOSAL' THEN NVL(JSON_VALUE(t.new_values, '$.catchup' RETURNING NUMBER), 0) ELSE 0 END dep,
                       CASE t.txn_type WHEN 'IMPAIRMENT' THEN t.amount
                                       WHEN 'CAPITALIZATION' THEN NVL(JSON_VALUE(t.new_values, '$.opening_accum' RETURNING NUMBER), 0) ELSE 0 END imp,
                       CASE t.txn_type WHEN 'DISPOSAL' THEN NVL(JSON_VALUE(t.new_values, '$.accum' RETURNING NUMBER), 0) ELSE 0 END dis_a
                  FROM fa_transaction t JOIN fa_asset a ON a.id = t.asset_id
                 WHERE t.company_id = NOONA_FA_PKG.company AND t.status_code = 'POSTED'
                   AND t.txn_type IN ('CAPITALIZATION', 'ADDITION', 'DISPOSAL', 'IMPAIRMENT')
                UNION ALL
                SELECT a.category_id, p.end_date, 0, 0, l.depreciation_amount, 0, 0
                  FROM fa_depreciation_line l JOIN fa_depreciation_run r ON r.id = l.run_id AND r.status_code = 'POSTED'
                  JOIN gl_period p ON p.id = l.period_id JOIN fa_asset_book b ON b.id = l.asset_book_id JOIN fa_asset a ON a.id = b.asset_id
                 WHERE l.company_id = NOONA_FA_PKG.company)
              SELECT c.code, c.name_ar,
                     NVL(SUM(CASE WHEN m.d < p_from THEN m.add_c - m.dis_c END), 0) oc,
                     NVL(SUM(CASE WHEN m.d BETWEEN p_from AND p_to THEN m.add_c END), 0) ad,
                     NVL(SUM(CASE WHEN m.d BETWEEN p_from AND p_to THEN m.dis_c END), 0) dc,
                     NVL(SUM(CASE WHEN m.d < p_from THEN m.dep + m.imp - m.dis_a END), 0) oa,
                     NVL(SUM(CASE WHEN m.d BETWEEN p_from AND p_to THEN m.dep END), 0) dp,
                     NVL(SUM(CASE WHEN m.d BETWEEN p_from AND p_to THEN m.imp END), 0) im,
                     NVL(SUM(CASE WHEN m.d BETWEEN p_from AND p_to THEN m.dis_a END), 0) da
                FROM fa_category c LEFT JOIN mv m ON m.category_id = c.id
               WHERE c.company_id = NOONA_FA_PKG.company
               GROUP BY c.code, c.name_ar ORDER BY c.code) LOOP
      CONTINUE WHEN r.oc = 0 AND r.ad = 0 AND r.dc = 0 AND r.oa = 0 AND r.dp = 0 AND r.im = 0;
      l_out := l_out || ('<tr><td class="nn-rpt-text">' || esc(r.name_ar) || '</td><td>' || fnum(r.oc) || '</td><td>' || fnum(r.ad) || '</td><td>'
            || fnum(r.dc) || '</td><td>' || fnum(r.oc + r.ad - r.dc) || '</td><td>' || fnum(r.oa) || '</td><td>' || fnum(r.dp) || '</td><td>'
            || fnum(r.im) || '</td><td>' || fnum(r.da) || '</td><td>' || fnum(r.oa + r.dp + r.im - r.da) || '</td><td>'
            || fnum(r.oc + r.ad - r.dc - (r.oa + r.dp + r.im - r.da)) || '</td></tr>');
      t(1) := t(1) + r.oc; t(2) := t(2) + r.ad; t(3) := t(3) + r.dc; t(4) := t(4) + r.oc + r.ad - r.dc;
      t(5) := t(5) + r.oa; t(6) := t(6) + r.dp; t(7) := t(7) + r.im; t(8) := t(8) + r.da; t(9) := t(9) + r.oa + r.dp + r.im - r.da;
    END LOOP;
    l_out := l_out || ('<tr class="nn-rpt-total"><td class="nn-rpt-text">الإجمالي</td>');
    FOR i IN 1 .. 9 LOOP
      l_out := l_out || ('<td>' || fnum(t(i)) || '</td>');
    END LOOP;
    l_out := l_out || ('<td>' || fnum(t(4) - t(9)) || '</td></tr></tbody></table></div>');
    -- مطابقة مع الأستاذ العام
    SELECT LISTAGG(DISTINCT asset_account_id, ',') WITHIN GROUP (ORDER BY asset_account_id),
           LISTAGG(DISTINCT accum_depr_account_id, ',') WITHIN GROUP (ORDER BY accum_depr_account_id)
      INTO l_aacc, l_dacc FROM fa_category WHERE company_id = company;
    l_glc := CASE WHEN l_aacc IS NOT NULL THEN gl_balance(l_aacc, p_to) ELSE 0 END;
    l_gld := CASE WHEN l_dacc IS NOT NULL THEN -gl_balance(l_dacc, p_to) ELSE 0 END;
    l_out := l_out || ('<h3 class="nn-fa-h">المطابقة مع الأستاذ العام في ' || fd(p_to) || '</h3><div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>البند</th>'
          || '<th>سجل الأصول</th><th>الأستاذ العام</th><th>الفرق</th></tr></thead><tbody><tr><td class="nn-rpt-text">تكلفة الأصول</td><td>' || fnum(t(4))
          || '</td><td>' || fnum(l_glc) || '</td><td class="' || CASE WHEN ROUND(t(4) - l_glc, 2) <> 0 THEN 'nn-neg' END || '">' || fnum(t(4) - l_glc)
          || '</td></tr><tr><td class="nn-rpt-text">مجمع الإهلاك والانخفاض</td><td>' || fnum(t(9)) || '</td><td>' || fnum(l_gld) || '</td><td class="'
          || CASE WHEN ROUND(t(9) - l_gld, 2) <> 0 THEN 'nn-neg' END || '">' || fnum(t(9) - l_gld) || '</td></tr></tbody></table></div>'
          || '<div class="nn-hint">الفرق ينتج عن قيود يدوية على حسابات الأصول أو أرصدة سابقة لم تسجل في سجل الأصول.</div>');
    RETURN l_out;
  END rollforward_html;

  FUNCTION disposals_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_out CLOB := '<div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>المستند</th><th>التاريخ</th><th>الأصل</th><th>الطريقة</th>'
               || '<th>الطرف</th><th>المتحصلات</th><th>الضريبة</th><th>الصافي عند الاستبعاد</th><th>ربح / (خسارة)</th><th>الحالة</th></tr></thead><tbody>';
    t SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(0, 0, 0, 0);
    l_n PLS_INTEGER := 0;
  BEGIN
    FOR d IN (SELECT d.doc_no, d.disposal_date, a.asset_no || ' - ' || a.name_ar asset, d.disposal_method, p.display_name_ar party,
                     d.proceeds, d.vat_amount, d.nbv_at_disposal, d.gain_loss, d.status_code
                FROM fa_disposal d JOIN fa_asset a ON a.id = d.asset_id LEFT JOIN pty_party p ON p.id = d.buyer_party_id
               WHERE d.company_id = company AND d.disposal_date BETWEEN p_from AND p_to
               ORDER BY d.disposal_date, d.id) LOOP
      l_out := l_out || ('<tr><td>' || esc(d.doc_no) || '</td><td>' || fd(d.disposal_date) || '</td><td class="nn-rpt-text">' || esc(d.asset)
            || '</td><td class="nn-rpt-text">' || disposal_label(d.disposal_method) || '</td><td class="nn-rpt-text">' || esc(d.party) || '</td><td>'
            || fnum(d.proceeds) || '</td><td>' || fnum(d.vat_amount) || '</td><td>' || fnum(d.nbv_at_disposal) || '</td><td class="'
            || CASE WHEN d.gain_loss < 0 THEN 'nn-neg' END || '">' || CASE WHEN d.gain_loss < 0 THEN '(' || fnum(-d.gain_loss) || ')' ELSE fnum(d.gain_loss) END
            || '</td><td class="nn-rpt-text">' || status_label(d.status_code) || '</td></tr>');
      IF d.status_code = 'POSTED' THEN
        t(1) := t(1) + d.proceeds; t(2) := t(2) + d.vat_amount; t(3) := t(3) + d.nbv_at_disposal; t(4) := t(4) + d.gain_loss;
      END IF;
      l_n := l_n + 1;
    END LOOP;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty">لا توجد استبعادات في الفترة</div>';
    END IF;
    RETURN l_out || ('<tr class="nn-rpt-total"><td colspan="5" class="nn-rpt-text">الإجمالي (المرحل)</td><td>' || fnum(t(1)) || '</td><td>' || fnum(t(2))
        || '</td><td>' || fnum(t(3)) || '</td><td>' || CASE WHEN t(4) < 0 THEN '(' || fnum(-t(4)) || ')' ELSE fnum(t(4)) END
        || '</td><td></td></tr></tbody></table></div>');
  END disposals_html;

  FUNCTION run_html(p_run_id IN NUMBER) RETURN CLOB IS
    l_r   fa_depreciation_run%ROWTYPE;
    l_p   gl_period%ROWTYPE;
    l_out CLOB;
    l_n   PLS_INTEGER := 0;
  BEGIN
    SELECT * INTO l_r FROM fa_depreciation_run WHERE id = p_run_id AND company_id = company;
    SELECT * INTO l_p FROM gl_period WHERE id = l_r.period_id;
    l_out := '<div class="nn-hr-runbar"><b>إهلاك ' || l_p.period_code || '</b> · ' || fd(l_p.start_date) || ' – ' || fd(l_p.end_date)
          || ' · الإجمالي ' || fnum(l_r.total_amount) || ' · <span class="nn-badge ' || CASE l_r.status_code WHEN 'POSTED' THEN 'is-success'
             ELSE 'is-warning' END || '">' || status_label(l_r.status_code) || '</span></div>'
          || '<div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>رقم الأصل</th><th>الأصل</th><th>مركز التكلفة</th><th>إهلاك الفترة</th>'
          || '<th>المجمع بعد</th><th>الصافي بعد</th></tr></thead><tbody>';
    FOR l IN (SELECT a.asset_no, a.name_ar, cc.name_ar cc, l.depreciation_amount, l.accumulated_after, l.nbv_after
                FROM fa_depreciation_line l JOIN fa_asset_book b ON b.id = l.asset_book_id JOIN fa_asset a ON a.id = b.asset_id
                LEFT JOIN gl_cost_center cc ON cc.id = l.cost_center_id
               WHERE l.run_id = p_run_id ORDER BY a.asset_no) LOOP
      l_out := l_out || ('<tr><td>' || esc(l.asset_no) || '</td><td class="nn-rpt-text">' || esc(l.name_ar) || '</td><td class="nn-rpt-text">'
            || esc(l.cc) || '</td><td>' || fnum(l.depreciation_amount) || '</td><td>' || fnum(l.accumulated_after) || '</td><td>'
            || fnum(l.nbv_after) || '</td></tr>');
      l_n := l_n + 1;
    END LOOP;
    RETURN l_out || ('<tr class="nn-rpt-total"><td colspan="3" class="nn-rpt-text">الإجمالي (' || l_n || ' أصل)</td><td>' || fnum(l_r.total_amount)
        || '</td><td></td><td></td></tr></tbody></table></div>');
  END run_html;

  FUNCTION preview_html(p_period_id IN NUMBER) RETURN CLOB IS
    l_p   gl_period%ROWTYPE;
    l_d   NUMBER;
    l_tot NUMBER := 0;
    l_n   PLS_INTEGER := 0;
    l_out CLOB := '<div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>رقم الأصل</th><th>الأصل</th><th>الطريقة</th><th>مهلك حتى</th>'
               || '<th>الإهلاك المتوقع</th><th>الصافي بعد</th></tr></thead><tbody>';
  BEGIN
    SELECT * INTO l_p FROM gl_period WHERE id = p_period_id AND company_id = company;
    FOR b IN (SELECT ab.*, a.asset_no, a.name_ar FROM fa_asset_book ab JOIN fa_asset a ON a.id = ab.asset_id
               WHERE ab.book_id = default_book AND ab.company_id = company AND ab.status_code = 'ACTIVE'
                 AND a.status_code IN ('IN_SERVICE', 'CAPITALIZED') AND ab.depreciation_method <> 'NONE'
                 AND ab.depr_start_date <= l_p.end_date ORDER BY a.asset_no) LOOP
      l_d := calc(b.cost, b.residual_value, b.accumulated_depr, b.depreciation_method, b.useful_life_months, b.depr_start_date,
                  b.depreciated_to, l_p.end_date);
      CONTINUE WHEN l_d = 0;
      l_out := l_out || ('<tr><td>' || esc(b.asset_no) || '</td><td class="nn-rpt-text">' || esc(b.name_ar) || '</td><td class="nn-rpt-text">'
            || method_label(b.depreciation_method) || '</td><td>' || NVL(fd(b.depreciated_to), '-') || '</td><td>' || fnum(l_d) || '</td><td>'
            || fnum(b.cost - b.accumulated_depr - l_d) || '</td></tr>');
      l_tot := l_tot + l_d;
      l_n := l_n + 1;
    END LOOP;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty">لا يوجد إهلاك مستحق لفترة ' || l_p.period_code || '</div>';
    END IF;
    RETURN l_out || ('<tr class="nn-rpt-total"><td colspan="4" class="nn-rpt-text">إجمالي إهلاك ' || l_p.period_code || ' (' || l_n || ' أصل)</td><td>'
        || fnum(l_tot) || '</td><td></td></tr></tbody></table></div>');
  END preview_html;

END NOONA_FA_PKG;
/
