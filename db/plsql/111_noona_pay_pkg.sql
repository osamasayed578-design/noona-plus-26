-- =============================================================================
-- NOONA PLUS ERP | NOONA_PAY_PKG - الرواتب
--   * التجهيز: حسابات الرواتب والتأمينات والمخصصات، مجموعة رواتب شهرية وفترات السنة، الوردية الافتراضية والترقيم
--   * التشغيل: OPEN → CALCULATED → APPROVED → POSTED → PAID ؛ الحساب على أساس 30 يوماً مع التناسب للمعين والمنتهي
--     ولتغير الراتب داخل الفترة، وخصم الغياب والإجازة غير المدفوعة، والإضافي (المادة 107: الأجر + 50% من الأساسي)،
--     والمكافآت والعمولات والجزاءات، والتأمينات الاجتماعية حسب الجنسية وبحد أدنى وأعلى، وأقساط السلف
--   * الترحيل عبر المحرك المحاسبي (قيد رواتب) مع مخصص نهاية الخدمة والإجازات للفترة؛ الصرف بملف تحويل (WPS)
--   * السلف والقروض بأقساط على الفترات؛ مخالصة نهاية الخدمة (المادتان 84 و85) ببدل الإجازات وخصم السلف
--   * قسيمة الراتب، ومسير الرواتب، وملخص العناصر، وتقرير التأمينات، والتزام نهاية الخدمة، والسلف
-- =============================================================================
CREATE OR REPLACE PACKAGE NOONA_PAY_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  FUNCTION ensure_periods(p_group_id IN NUMBER, p_year IN NUMBER) RETURN NUMBER;
  FUNCTION default_group RETURN NUMBER;
  FUNCTION period_for(p_date IN DATE, p_group_id IN NUMBER DEFAULT NULL) RETURN NUMBER;

  -- مبلغ عنصر ثابت للموظف في تاريخ، والراتب الشهري الثابت، وأجر نهاية الخدمة (الأساسي والسكن والنقل)
  -- ---------------------------------------------------------- هيكل الراتب والبدلات
  -- لكل عنصر: مبلغ ثابت للموظف، أو نسبة من عنصر آخر (افتراضياً الأساسي)، أو حسب سياسة الشركة، أو مستثنى.
  -- سياسة البدلات (PAY_ELEMENT_RULE بنوع FIXED أو PCT_OF_ELEMENT): لكل شركة، أو لكل شركات المؤسسة في دولة،
  -- بحد أدنى وأعلى وفئة موظف، والتلقائية منها تطبق على كل الموظفين ما لم يحدد للموظف غيرها.
  TYPE t_line IS RECORD (code VARCHAR2(50), name VARCHAR2(200), etype VARCHAR2(30), recurring CHAR(1), prorated CHAR(1), eos CHAR(1),
                         method VARCHAR2(20), pct NUMBER, basis VARCHAR2(50), amount NUMBER, rule_id NUMBER, sort_order NUMBER, done CHAR(1));
  TYPE t_lines IS TABLE OF t_line INDEX BY PLS_INTEGER;
  FUNCTION structure(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN t_lines;
  FUNCTION structure_html(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN CLOB;
  FUNCTION element_amount(p_employment_id IN NUMBER, p_code IN VARCHAR2, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  -- عناصر المؤسسة (بدلات واستقطاعات خاصة بها)؛ يعيد المعرف
  FUNCTION save_element(p_id IN NUMBER, p_code IN VARCHAR2, p_name IN VARCHAR2, p_type IN VARCHAR2, p_recurring IN VARCHAR2 DEFAULT 'Y',
                        p_prorated IN VARCHAR2 DEFAULT 'Y', p_eos IN VARCHAR2 DEFAULT 'N', p_taxable IN VARCHAR2 DEFAULT 'N',
                        p_sort IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- قاعدة بدل: p_scope COMPANY (الشركة الحالية) أو COUNTRY (كل شركات المؤسسة في p_country)؛ p_method FIXED (p_value مبلغ)
  -- أو PERCENT (p_value نسبة من p_basis)؛ تحل محل القاعدة السابقة لنفس النطاق والفئة من تاريخ السريان
  FUNCTION save_allowance_rule(p_element_code IN VARCHAR2, p_scope IN VARCHAR2, p_country IN VARCHAR2, p_method IN VARCHAR2,
                               p_value IN NUMBER, p_basis IN VARCHAR2 DEFAULT 'BASIC', p_min IN NUMBER DEFAULT NULL, p_max IN NUMBER DEFAULT NULL,
                               p_category IN VARCHAR2 DEFAULT NULL, p_auto IN VARCHAR2 DEFAULT 'Y', p_from IN DATE DEFAULT NULL) RETURN NUMBER;
  PROCEDURE end_rule(p_rule_id IN NUMBER, p_last_day IN DATE DEFAULT NULL);
  FUNCTION rule_text(p_rule_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION monthly_wage(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  FUNCTION eos_wage(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  -- مكافأة نهاية الخدمة: نصف أجر شهر عن كل سنة من الخمس الأولى وأجر شهر عن كل سنة بعدها؛ الاستقالة:
  -- أقل من سنتين لا شيء، من 2 إلى 5 الثلث، من 5 إلى 10 الثلثان، 10 فأكثر كاملة
  FUNCTION eos_amount(p_employment_id IN NUMBER, p_date IN DATE, p_type IN VARCHAR2 DEFAULT 'END_OF_CONTRACT') RETURN NUMBER;

  -- المدخلات المتغيرة للفترة: OVERTIME (ساعات أو مبلغ)، BONUS، COMMISSION، PENALTY، OTHER_DED، ABSENCE (أيام)
  FUNCTION add_input(p_period_id IN NUMBER, p_employment_id IN NUMBER, p_element_code IN VARCHAR2, p_quantity IN NUMBER,
                     p_amount IN NUMBER) RETURN NUMBER;
  PROCEDURE delete_input(p_id IN NUMBER);

  -- التشغيل
  FUNCTION create_run(p_period_id IN NUMBER, p_type IN VARCHAR2 DEFAULT 'REGULAR') RETURN NUMBER;
  FUNCTION calculate(p_run_id IN NUMBER) RETURN NUMBER;
  PROCEDURE approve_run(p_run_id IN NUMBER);
  FUNCTION post_run(p_run_id IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER;
  -- الصرف: ملف تحويل بصافي الرواتب وقيد الصرف من حساب البنك؛ يعيد رقم الملف
  FUNCTION pay_out(p_run_id IN NUMBER, p_bank_account_id IN NUMBER DEFAULT NULL, p_date IN DATE DEFAULT NULL) RETURN NUMBER;
  PROCEDURE delete_run(p_run_id IN NUMBER);
  FUNCTION bank_file_csv(p_file_id IN NUMBER) RETURN CLOB;

  -- السلف والقروض
  FUNCTION create_loan(p_employment_id IN NUMBER, p_type IN VARCHAR2, p_principal IN NUMBER, p_installments IN NUMBER,
                       p_start_period_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  FUNCTION disburse_loan(p_loan_id IN NUMBER, p_bank_account_id IN NUMBER DEFAULT NULL, p_cash_box_id IN NUMBER DEFAULT NULL,
                         p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  PROCEDURE defer_installment(p_loan_id IN NUMBER, p_installment_no IN NUMBER);
  FUNCTION loan_outstanding(p_employment_id IN NUMBER) RETURN NUMBER;

  -- مخالصة نهاية الخدمة: الحساب ثم الاعتماد (ينشئ تشغيل تسوية نهائية يعتمد ويرحل ويصرف كالمعتاد)
  FUNCTION calc_settlement(p_employment_id IN NUMBER, p_last_day IN DATE, p_type IN VARCHAR2, p_reason IN VARCHAR2) RETURN NUMBER;
  FUNCTION approve_settlement(p_settlement_id IN NUMBER) RETURN NUMBER;
  FUNCTION settlement_html(p_settlement_id IN NUMBER) RETURN CLOB;

  -- العرض والتقارير
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION run_status(p_run_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION run_file(p_run_id IN NUMBER) RETURN NUMBER;
  FUNCTION pay_summary RETURN CLOB;
  FUNCTION run_header_html(p_run_id IN NUMBER) RETURN CLOB;
  FUNCTION run_register_html(p_run_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION payslip_html(p_run_employee_id IN NUMBER) RETURN CLOB;
  FUNCTION element_summary_html(p_run_id IN NUMBER) RETURN CLOB;
  FUNCTION gosi_report_html(p_run_id IN NUMBER) RETURN CLOB;
  FUNCTION eos_liability_html(p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN CLOB;
  FUNCTION loans_report_html RETURN CLOB;
  FUNCTION cost_center_html(p_run_id IN NUMBER) RETURN CLOB;
END NOONA_PAY_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PAY_PKG AS

  c_days CONSTANT NUMBER := 30;
  FUNCTION res(p_re NUMBER, p_codes VARCHAR2) RETURN NUMBER;

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END jt;
  FUNCTION fnum(p NUMBER, p_dec PLS_INTEGER DEFAULT 2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_HR_PKG.fnum(p, p_dec); END fnum;
  -- رقم JSON
  FUNCTION jn(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN 'null' ELSE RTRIM(RTRIM(TO_CHAR(ROUND(p, 4), 'FM999999999990.9999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.') END;
  END jn;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION acc(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = p_code;
    RETURN l;
  END acc;

  FUNCTION need_acc(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER := acc(p_code);
  BEGIN
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-PAY-001', 'الحساب ' || p_code || ' غير موجود؛ نفذ «تجهيز الرواتب»',
      'Account ' || p_code || ' missing; run payroll setup');
    RETURN l;
  END need_acc;

  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER := acc(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type, 'Y', NULL);
    END IF;
    RETURN l;
  END ensure_account;

  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'OPEN' THEN 'مفتوح' WHEN 'CALCULATED' THEN 'محسوب - للمراجعة' WHEN 'APPROVED' THEN 'معتمد'
      WHEN 'POSTED' THEN 'مرحل - بانتظار الصرف' WHEN 'PAID' THEN 'مصروف' WHEN 'CLOSED' THEN 'مقفل'
      WHEN 'ERROR' THEN 'خطأ' WHEN 'ACTIVE' THEN 'قائم' WHEN 'SETTLED' THEN 'مسدد' WHEN 'SCHEDULED' THEN 'مجدول'
      WHEN 'DEDUCTED' THEN 'مخصوم' WHEN 'DEFERRED' THEN 'مؤجل' WHEN 'SETTLEMENT_CALCULATED' THEN 'محسوبة'
      ELSE NOONA_HR_PKG.status_label(p_status) END;
  END status_label;

  FUNCTION element_id(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) INTO l
      FROM pay_element WHERE code = p_code AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-PAY-002', 'عنصر الراتب غير معرف: ' || p_code, 'Unknown pay element');
    RETURN l;
  END element_id;

  FUNCTION rule_params(p_code VARCHAR2, p_category VARCHAR2) RETURN JSON_OBJECT_T IS
    l_p CLOB;
    ctry VARCHAR2(2) := NOONA_HR_PKG.company_country;
  BEGIN
    BEGIN
      SELECT parameters INTO l_p FROM (
        SELECT r.parameters FROM pay_element_rule r JOIN pay_element e ON e.id = r.element_id
         WHERE e.code = p_code AND r.status_code = 'ACTIVE' AND NVL(r.employee_category, NVL(p_category, '-')) = NVL(p_category, '-')
           AND TRUNC(SYSDATE) BETWEEN r.effective_from AND NVL(r.effective_to, DATE '9999-12-31')
           -- قاعدة الشركة، أو قاعدة المؤسسة/النظام لدولة الشركة أو لكل الدول (التأمينات السعودية لا تطبق على شركة في مصر)
           AND (r.company_id = NOONA_PAY_PKG.company OR (r.company_id IS NULL AND NVL(r.country_code, ctry) = ctry))
         ORDER BY CASE WHEN r.company_id = NOONA_PAY_PKG.company THEN 0 WHEN r.tenant_id IS NOT NULL THEN 1 ELSE 2 END,
                  CASE WHEN r.country_code IS NOT NULL THEN 0 ELSE 1 END, r.effective_from DESC, r.version_no DESC)
       WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN l_p := NULL;
    END;
    RETURN JSON_OBJECT_T.parse(NVL(l_p, '{}'));
  END rule_params;

  FUNCTION pnum(p_o JSON_OBJECT_T, p_key VARCHAR2, p_default NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_key) THEN p_o.get_number(p_key) ELSE p_default END;
  END pnum;

  -- ================================================================ التجهيز
  FUNCTION default_group RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM pay_payroll_group WHERE company_id = company AND is_active = 'Y';
    RETURN l;
  END default_group;

  -- الفترة المحاسبية إن كانت السنة المالية مفتوحة (فترات الرواتب المستقبلية تنشأ قبل فتح سنتها)
  FUNCTION gl_period(p_date DATE) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_GL_PKG.period_for(p_date);
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END gl_period;

  FUNCTION ensure_periods(p_group_id IN NUMBER, p_year IN NUMBER) RETURN NUMBER IS
    l_g pay_payroll_group%ROWTYPE;
    l_gp NUMBER;
    l_n NUMBER := 0;
    l_s DATE;
  BEGIN
    SELECT * INTO l_g FROM pay_payroll_group WHERE id = p_group_id AND company_id = company;
    FOR m IN 1 .. 12 LOOP
      l_s := ADD_MONTHS(TO_DATE(p_year || '-01-01', 'YYYY-MM-DD'), m - 1);
      l_gp := gl_period(LAST_DAY(l_s));
      INSERT INTO pay_period (company_id, payroll_group_id, period_code, start_date, end_date, cutoff_date, pay_date, gl_period_id, status_code)
      SELECT company, p_group_id, TO_CHAR(l_s, 'YYYY-MM'), l_s, LAST_DAY(l_s),
             LEAST(l_s + NVL(l_g.cutoff_day, 25) - 1, LAST_DAY(l_s)), LEAST(l_s + NVL(l_g.pay_day, 27) - 1, LAST_DAY(l_s)),
             l_gp, 'OPEN'
        FROM dual
       WHERE NOT EXISTS (SELECT 1 FROM pay_period WHERE payroll_group_id = p_group_id AND period_code = TO_CHAR(l_s, 'YYYY-MM'));
      l_n := l_n + SQL%ROWCOUNT;
    END LOOP;
    RETURN l_n;
  END ensure_periods;

  FUNCTION period_for(p_date IN DATE, p_group_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
    l_g NUMBER := NVL(p_group_id, default_group);
  BEGIN
    SELECT MIN(id) INTO l FROM pay_period WHERE payroll_group_id = l_g AND p_date BETWEEN start_date AND end_date;
    IF l IS NULL AND l_g IS NOT NULL THEN
      l := ensure_periods(l_g, EXTRACT(YEAR FROM p_date));
      SELECT MIN(id) INTO l FROM pay_period WHERE payroll_group_id = l_g AND p_date BETWEEN start_date AND end_date;
    END IF;
    RETURN l;
  END period_for;

  FUNCTION quick_setup RETURN NUMBER IS
    l_id  NUMBER;
    l_g   NUMBER;
    l_bk  NUMBER;
    l_n   NUMBER := 0;
  BEGIN
    guard('PAY_PAYROLL_GROUP.CREATE');
    IF NOONA_GL_PKG.primary_ledger IS NULL THEN
      l_id := NOONA_GL_PKG.quick_setup;
    END IF;
    l_id := ensure_account('2108', 'التأمينات الاجتماعية المستحقة', '21', 'LIABILITY');
    l_id := ensure_account('2109', 'مخصص الإجازات المستحقة', '21', 'LIABILITY');
    l_id := ensure_account('5214', 'حصة المنشأة في التأمينات الاجتماعية', '52', 'EXPENSE');
    l_id := ensure_account('5215', 'مصروف مكافأة نهاية الخدمة', '52', 'EXPENSE');
    l_id := ensure_account('5216', 'مصروف الإجازات', '52', 'EXPENSE');
    l_id := ensure_account('2202', 'مخصص مكافأة نهاية الخدمة', '22', 'LIABILITY');
    l_id := ensure_account('1108', 'سلف وعهد الموظفين', '11', 'ASSET');
    NOONA_HR_PKG.ensure_sequence('HR_EMPLOYEE_ACTION', 'HA-');
    NOONA_HR_PKG.ensure_sequence('HR_LEAVE_REQUEST', 'LV-');
    NOONA_HR_PKG.ensure_sequence('HR_END_OF_SERVICE', 'EOS-');
    NOONA_HR_PKG.ensure_sequence('PAY_LOAN', 'LN-');
    INSERT INTO hr_shift (company_id, code, name_ar, start_time, end_time, break_minutes, crosses_midnight, grace_minutes, is_active)
    SELECT company, 'DAY', 'الدوام الرسمي', '08:00', '17:00', 60, 'N', 15, 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM hr_shift WHERE company_id = company);
    l_g := default_group;
    IF l_g IS NULL THEN
      SELECT MIN(id) INTO l_bk FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE';
      INSERT INTO pay_payroll_group (company_id, code, name_ar, frequency, currency_code, cutoff_day, pay_day, bank_account_id, is_active)
      VALUES (company, 'MAIN', 'الرواتب الشهرية', 'MONTHLY', NOONA_GL_PKG.ledger_currency, 25, 27, l_bk, 'Y')
      RETURNING id INTO l_g;
      l_n := l_n + 1;
    END IF;
    l_n := l_n + ensure_periods(l_g, EXTRACT(YEAR FROM SYSDATE));
    IF EXTRACT(MONTH FROM SYSDATE) >= 11 THEN
      l_n := l_n + ensure_periods(l_g, EXTRACT(YEAR FROM SYSDATE) + 1);
    END IF;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PAY_PAYROLL_GROUP', l_g, 'QUICK_SETUP', 'SUCCESS');
    RETURN l_n;
  END quick_setup;

  FUNCTION is_ready RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN default_group IS NOT NULL AND acc('2108') IS NOT NULL AND acc('5214') IS NOT NULL THEN 'Y' ELSE 'N' END;
  END is_ready;

  -- ================================================================ الأجور
  -- ================================================================ هيكل الراتب
  -- أفضل قاعدة بدل نافذة للعنصر: الشركة ← المؤسسة لدولة الشركة ← المؤسسة لكل الدول ← النظام لدولة الشركة ← النظام
  FUNCTION policy_rule(p_element_id NUMBER, p_company NUMBER, p_country VARCHAR2, p_category VARCHAR2, p_date DATE,
                       p_auto_only BOOLEAN) RETURN pay_element_rule%ROWTYPE IS
    l pay_element_rule%ROWTYPE;
    l_auto VARCHAR2(1) := CASE WHEN p_auto_only THEN 'Y' END;
  BEGIN
    SELECT * INTO l FROM (
      SELECT r.* FROM pay_element_rule r
       WHERE r.element_id = p_element_id AND r.status_code = 'ACTIVE' AND r.formula_type IN ('FIXED', 'PCT_OF_ELEMENT')
         AND p_date BETWEEN r.effective_from AND NVL(r.effective_to, DATE '9999-12-31')
         AND (l_auto IS NULL OR r.is_auto = 'Y')
         AND (r.employee_category IS NULL OR r.employee_category = p_category)
         AND (r.company_id = p_company OR (r.company_id IS NULL AND NVL(r.country_code, p_country) = p_country))
       ORDER BY CASE WHEN r.company_id IS NOT NULL THEN 0 WHEN r.tenant_id IS NOT NULL AND r.country_code IS NOT NULL THEN 1
                     WHEN r.tenant_id IS NOT NULL THEN 2 WHEN r.country_code IS NOT NULL THEN 3 ELSE 4 END,
                CASE WHEN r.employee_category IS NOT NULL THEN 0 ELSE 1 END, r.effective_from DESC, r.version_no DESC)
     WHERE ROWNUM = 1;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN l;
  END policy_rule;

  FUNCTION structure(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN t_lines IS
    l      t_lines;
    l_co   NUMBER;
    l_cc   VARCHAR2(2);
    l_cat  VARCHAR2(30) := NOONA_HR_PKG.category(p_employment_id);
    l_r    pay_element_rule%ROWTYPE;
    l_n    PLS_INTEGER := 0;
    TYPE t_idx IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(50);
    l_ix   t_idx;
    FUNCTION val(p_code VARCHAR2, p_depth PLS_INTEGER) RETURN NUMBER;
    -- مبلغ العنصر بعد الاحتساب (النسبة تحسب من مبلغ أساسها؛ عمق 4 يمنع الدوران)
    PROCEDURE calc(i PLS_INTEGER, p_depth PLS_INTEGER) IS
      l_prm JSON_OBJECT_T;
      l_amt NUMBER;
    BEGIN
      IF l(i).done = 'Y' OR p_depth > 4 THEN RETURN; END IF;
      IF l(i).method = 'FIXED' THEN
        l_amt := NVL(l(i).amount, 0);
      ELSIF l(i).method = 'PERCENT' THEN
        l_amt := l(i).pct / 100 * val(NVL(l(i).basis, 'BASIC'), p_depth + 1);
      ELSIF l(i).method = 'POLICY' AND l(i).rule_id IS NOT NULL THEN
        SELECT * INTO l_r FROM pay_element_rule WHERE id = l(i).rule_id;
        l_prm := JSON_OBJECT_T.parse(NVL(l_r.parameters, '{}'));
        IF l_r.formula_type = 'FIXED' THEN
          l_amt := pnum(l_prm, 'amount', 0);
        ELSE
          l(i).pct := pnum(l_prm, 'pct', 0);
          l(i).basis := CASE WHEN l_prm.has('of') THEN l_prm.get_string('of') ELSE 'BASIC' END;
          l_amt := l(i).pct / 100 * val(l(i).basis, p_depth + 1);
        END IF;
        l_amt := LEAST(GREATEST(l_amt, NVL(l_r.min_amount, l_amt)), NVL(l_r.max_amount, l_amt));
      ELSE
        l_amt := 0;                                               -- مستثنى أو سياسة بلا قاعدة نافذة
      END IF;
      l(i).amount := ROUND(l_amt, 2);
      l(i).done := 'Y';
    END calc;
    FUNCTION val(p_code VARCHAR2, p_depth PLS_INTEGER) RETURN NUMBER IS
    BEGIN
      IF NOT l_ix.EXISTS(p_code) THEN RETURN 0; END IF;
      calc(l_ix(p_code), p_depth);
      RETURN NVL(l(l_ix(p_code)).amount, 0);
    END val;
  BEGIN
    SELECT m.company_id, c.country_code INTO l_co, l_cc FROM hr_employment m JOIN org_company c ON c.id = m.company_id WHERE m.id = p_employment_id;
    l_cc := NVL(l_cc, 'SA');
    -- عناصر الموظف النافذة في التاريخ
    FOR x IN (SELECT e.id eid, e.code, e.name_ar, e.element_type, e.is_recurring, e.is_prorated, e.affects_eos, e.sort_order,
                     NVL(x.calc_method, 'FIXED') m, x.amount, x.percentage, x.basis_code
                FROM pay_employee_element x JOIN pay_element e ON e.id = x.element_id
               WHERE x.employment_id = p_employment_id AND p_date BETWEEN x.effective_from AND NVL(x.effective_to, DATE '9999-12-31')
               ORDER BY e.sort_order, x.effective_from DESC) LOOP
      IF NOT l_ix.EXISTS(x.code) THEN
        l_n := l_n + 1;
        l(l_n).code := x.code; l(l_n).name := x.name_ar; l(l_n).etype := x.element_type; l(l_n).recurring := x.is_recurring;
        l(l_n).prorated := x.is_prorated; l(l_n).eos := x.affects_eos; l(l_n).sort_order := x.sort_order;
        l(l_n).method := x.m; l(l_n).amount := x.amount; l(l_n).pct := x.percentage; l(l_n).basis := x.basis_code; l(l_n).done := 'N';
        IF x.m = 'POLICY' THEN
          l_r := policy_rule(x.eid, l_co, l_cc, l_cat, p_date, FALSE);
          l(l_n).rule_id := l_r.id;
        END IF;
        l_ix(x.code) := l_n;
      END IF;
    END LOOP;
    -- البدلات التلقائية في سياسة الشركة أو الدولة لمن لم يحدد له العنصر
    FOR e IN (SELECT DISTINCT e.id eid, e.code, e.name_ar, e.element_type, e.is_recurring, e.is_prorated, e.affects_eos, e.sort_order
                FROM pay_element_rule r JOIN pay_element e ON e.id = r.element_id
               WHERE r.is_auto = 'Y' AND r.status_code = 'ACTIVE' AND r.formula_type IN ('FIXED', 'PCT_OF_ELEMENT') AND e.is_active = 'Y'
                 AND p_date BETWEEN r.effective_from AND NVL(r.effective_to, DATE '9999-12-31')
                 AND (r.company_id = l_co OR (r.company_id IS NULL AND NVL(r.country_code, l_cc) = l_cc))) LOOP
      IF NOT l_ix.EXISTS(e.code) THEN
        l_r := policy_rule(e.eid, l_co, l_cc, l_cat, p_date, TRUE);
        IF l_r.id IS NOT NULL THEN
          l_n := l_n + 1;
          l(l_n).code := e.code; l(l_n).name := e.name_ar; l(l_n).etype := e.element_type; l(l_n).recurring := e.is_recurring;
          l(l_n).prorated := e.is_prorated; l(l_n).eos := e.affects_eos; l(l_n).sort_order := e.sort_order;
          l(l_n).method := 'POLICY'; l(l_n).rule_id := l_r.id; l(l_n).done := 'N';
          l_ix(e.code) := l_n;
        END IF;
      END IF;
    END LOOP;
    FOR i IN 1 .. l_n LOOP calc(i, 0); END LOOP;
    RETURN l;
  END structure;

  FUNCTION element_amount(p_employment_id IN NUMBER, p_code IN VARCHAR2, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l t_lines := structure(p_employment_id, p_date);
  BEGIN
    FOR i IN 1 .. l.COUNT LOOP
      IF l(i).code = p_code THEN RETURN NVL(l(i).amount, 0); END IF;
    END LOOP;
    RETURN 0;
  END element_amount;

  FUNCTION monthly_wage(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l t_lines := structure(p_employment_id, p_date);
    t NUMBER := 0;
  BEGIN
    FOR i IN 1 .. l.COUNT LOOP
      IF l(i).etype = 'EARNING' AND l(i).recurring = 'Y' THEN t := t + NVL(l(i).amount, 0); END IF;
    END LOOP;
    RETURN t;
  END monthly_wage;

  FUNCTION eos_wage(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l t_lines := structure(p_employment_id, p_date);
    t NUMBER := 0;
  BEGIN
    FOR i IN 1 .. l.COUNT LOOP
      IF l(i).etype = 'EARNING' AND l(i).eos = 'Y' THEN t := t + NVL(l(i).amount, 0); END IF;
    END LOOP;
    RETURN t;
  END eos_wage;

  FUNCTION pct(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN RTRIM(TO_CHAR(p, 'FM9999990.99'), '.') || '%'; END pct;

  FUNCTION ename(p_code VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(200);
  BEGIN
    SELECT MAX(name_ar) INTO l FROM pay_element WHERE code = p_code;
    RETURN NVL(l, p_code);
  END ename;

  FUNCTION method_text(p_line t_line) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_line.method WHEN 'FIXED' THEN 'مبلغ ثابت'
                WHEN 'PERCENT' THEN pct(p_line.pct) || ' من ' || ename(p_line.basis)
                WHEN 'POLICY' THEN 'حسب سياسة الشركة' || CASE WHEN p_line.pct IS NOT NULL THEN ': ' || pct(p_line.pct) || ' من '
                                   || ename(p_line.basis) END
                WHEN 'EXCLUDED' THEN 'مستثنى' END;
  END method_text;

  FUNCTION structure_html(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN CLOB IS
    l    t_lines := structure(p_employment_id, p_date);
    l_h  CLOB;
    l_e  NUMBER := 0;
    l_d  NUMBER := 0;
  BEGIN
    l_h := '<table class="nn-rpt"><thead><tr><th>العنصر</th><th>طريقة الاحتساب</th><th>استحقاق</th><th>استقطاع</th><th>يدخل في نهاية الخدمة</th></tr></thead><tbody>';
    FOR i IN 1 .. l.COUNT LOOP
      IF l(i).recurring = 'Y' THEN
        l_h := l_h || ('<tr><td class="nn-rpt-text">' || esc(l(i).name) || '</td><td class="nn-rpt-text">' || esc(method_text(l(i)))
            || CASE WHEN l(i).method = 'POLICY' AND l(i).rule_id IS NULL THEN ' <span class="nn-badge is-warning">لا توجد قاعدة نافذة</span>' END
            || '</td><td>' || CASE WHEN l(i).etype = 'EARNING' THEN fnum(l(i).amount) END || '</td><td>'
            || CASE WHEN l(i).etype <> 'EARNING' THEN fnum(l(i).amount) END || '</td><td>' || CASE WHEN l(i).eos = 'Y' THEN 'نعم' ELSE '-' END || '</td></tr>');
        IF l(i).etype = 'EARNING' THEN l_e := l_e + NVL(l(i).amount, 0); ELSE l_d := l_d + NVL(l(i).amount, 0); END IF;
      END IF;
    END LOOP;
    RETURN l_h || ('</tbody><tfoot><tr><td colspan="2">الإجمالي الشهري الثابت</td><td>' || fnum(l_e) || '</td><td>' || fnum(l_d)
        || '</td><td>صافي ' || fnum(l_e - l_d) || '</td></tr></tfoot></table>');
  END structure_html;

  -- ================================================================ عناصر وسياسة البدلات
  FUNCTION save_element(p_id IN NUMBER, p_code IN VARCHAR2, p_name IN VARCHAR2, p_type IN VARCHAR2, p_recurring IN VARCHAR2 DEFAULT 'Y',
                        p_prorated IN VARCHAR2 DEFAULT 'Y', p_eos IN VARCHAR2 DEFAULT 'N', p_taxable IN VARCHAR2 DEFAULT 'N',
                        p_sort IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_code VARCHAR2(50) := UPPER(TRIM(p_code));
    l_id   NUMBER := p_id;
    l_n    NUMBER;
  BEGIN
    guard('PAY_ELEMENT.UPDATE');
    NOONA_CORE_PKG.assert(REGEXP_LIKE(l_code, '^[A-Z][A-Z0-9_]{1,29}$'), 'NOONA-PAY-060', 'الرمز حروف إنجليزية كبيرة وأرقام (مثل: MEAL_ALLOW)',
      'Code must be uppercase letters and digits');
    NOONA_CORE_PKG.assert(TRIM(p_name) IS NOT NULL, 'NOONA-PAY-061', 'اسم العنصر إلزامي', 'Name is required');
    NOONA_CORE_PKG.assert(p_type IN ('EARNING', 'DEDUCTION'), 'NOONA-PAY-062', 'النوع استحقاق أو استقطاع', 'Type must be earning or deduction');
    IF l_id IS NULL THEN
      SELECT COUNT(*) INTO l_n FROM pay_element WHERE code = l_code;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PAY-063', 'الرمز مستخدم: ' || l_code, 'Code already used');
      INSERT INTO pay_element (code, name_ar, name_en, element_type, classification, is_recurring, is_taxable, is_prorated, affects_eos,
                               show_on_payslip, is_active, sort_order)
      VALUES (l_code, TRIM(p_name), l_code, p_type, CASE WHEN p_type = 'EARNING' THEN 'ALLOWANCE' ELSE 'OTHER' END, NVL(p_recurring, 'Y'),
              NVL(p_taxable, 'N'), NVL(p_prorated, 'Y'), CASE WHEN p_type = 'EARNING' THEN NVL(p_eos, 'N') ELSE 'N' END, 'Y', 'Y', NVL(p_sort, 45))
      RETURNING id INTO l_id;
    ELSE
      UPDATE pay_element SET name_ar = TRIM(p_name), is_recurring = NVL(p_recurring, 'Y'), is_prorated = NVL(p_prorated, 'Y'),
                             affects_eos = CASE WHEN element_type = 'EARNING' THEN NVL(p_eos, 'N') ELSE 'N' END, is_taxable = NVL(p_taxable, 'N'),
                             sort_order = NVL(p_sort, sort_order)
       WHERE id = l_id AND tenant_id IS NOT NULL;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PAY-064', 'عناصر النظام الأساسية لا تعدل؛ أضف عنصراً خاصاً بالمؤسسة',
        'System elements cannot be changed');
    END IF;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PAY_ELEMENT', l_id, 'SAVE', 'SUCCESS', p_new_values => '{"code":' || jt(l_code) || '}');
    RETURN l_id;
  END save_element;

  FUNCTION save_allowance_rule(p_element_code IN VARCHAR2, p_scope IN VARCHAR2, p_country IN VARCHAR2, p_method IN VARCHAR2,
                               p_value IN NUMBER, p_basis IN VARCHAR2 DEFAULT 'BASIC', p_min IN NUMBER DEFAULT NULL, p_max IN NUMBER DEFAULT NULL,
                               p_category IN VARCHAR2 DEFAULT NULL, p_auto IN VARCHAR2 DEFAULT 'Y', p_from IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_eid   NUMBER := element_id(UPPER(TRIM(p_element_code)));
    l_from  DATE := NVL(TRUNC(p_from), TRUNC(SYSDATE, 'MM'));
    l_co    NUMBER := CASE WHEN p_scope = 'COMPANY' THEN company END;
    l_cc    VARCHAR2(2) := CASE WHEN p_scope = 'COUNTRY' THEN UPPER(NVL(p_country, NOONA_HR_PKG.company_country)) END;
    l_basis VARCHAR2(50) := UPPER(NVL(TRIM(p_basis), 'BASIC'));
    l_ver   NUMBER;
    l_id    NUMBER;
    l_n     NUMBER;
    l_etype VARCHAR2(30);
    l_prm   VARCHAR2(400);
  BEGIN
    guard('PAY_ELEMENT.UPDATE');
    SELECT element_type INTO l_etype FROM pay_element WHERE id = l_eid;
    NOONA_CORE_PKG.assert(l_etype IN ('EARNING', 'DEDUCTION') AND UPPER(p_element_code) <> 'BASIC', 'NOONA-PAY-065',
      'السياسة للبدلات والاستقطاعات الثابتة (لا للراتب الأساسي أو التأمينات)', 'Rules are for allowances and fixed deductions');
    NOONA_CORE_PKG.assert(p_scope IN ('COMPANY', 'COUNTRY'), 'NOONA-PAY-066', 'النطاق: الشركة أو الدولة', 'Scope must be company or country');
    NOONA_CORE_PKG.assert(p_method IN ('FIXED', 'PERCENT') AND NVL(p_value, 0) > 0, 'NOONA-PAY-067',
      'حدد مبلغاً ثابتاً أو نسبة موجبة', 'Fixed amount or positive percentage required');
    NOONA_CORE_PKG.assert(p_method <> 'PERCENT' OR (p_value <= 1000 AND l_basis <> UPPER(p_element_code)), 'NOONA-PAY-068',
      'النسبة غير صالحة أو من العنصر نفسه', 'Invalid percentage');
    NOONA_CORE_PKG.assert(p_min IS NULL OR p_max IS NULL OR p_min <= p_max, 'NOONA-PAY-069', 'الحد الأدنى أكبر من الأعلى', 'Min exceeds max');
    IF l_cc IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM ref_country WHERE country_code = l_cc;
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-PAY-070', 'الدولة غير معرفة: ' || l_cc, 'Unknown country');
    END IF;
    -- القاعدة السابقة لنفس النطاق والفئة تنتهي قبل السريان (تبقى للفترات السابقة)
    UPDATE pay_element_rule SET effective_to = l_from - 1
     WHERE element_id = l_eid AND tenant_id IS NOT NULL AND formula_type IN ('FIXED', 'PCT_OF_ELEMENT') AND status_code = 'ACTIVE'
       AND NVL(company_id, -1) = NVL(l_co, -1) AND NVL(country_code, '-') = NVL(l_cc, '-') AND NVL(employee_category, '-') = NVL(p_category, '-')
       AND (effective_to IS NULL OR effective_to >= l_from) AND effective_from < l_from;
    DELETE FROM pay_element_rule
     WHERE element_id = l_eid AND tenant_id IS NOT NULL AND formula_type IN ('FIXED', 'PCT_OF_ELEMENT')
       AND NVL(company_id, -1) = NVL(l_co, -1) AND NVL(country_code, '-') = NVL(l_cc, '-') AND NVL(employee_category, '-') = NVL(p_category, '-')
       AND effective_from >= l_from;
    l_prm := CASE p_method WHEN 'FIXED' THEN '{"amount":' || jn(p_value) || '}' ELSE '{"pct":' || jn(p_value) || ',"of":' || jt(l_basis) || '}' END;
    -- رقم الإصدار فريد لكل عنصر على مستوى النظام كله
    NOONA_CORE_PKG.begin_system;
    SELECT NVL(MAX(version_no), 0) + 1 INTO l_ver FROM pay_element_rule WHERE element_id = l_eid;
    NOONA_CORE_PKG.end_system;
    INSERT INTO pay_element_rule (element_id, version_no, company_id, country_code, employee_category, formula_type, parameters,
                                  min_amount, max_amount, is_auto, status_code, effective_from)
    VALUES (l_eid, l_ver, l_co, l_cc, p_category, CASE p_method WHEN 'FIXED' THEN 'FIXED' ELSE 'PCT_OF_ELEMENT' END,
            l_prm,
            p_min, p_max, NVL(p_auto, 'Y'), 'ACTIVE', l_from)
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PAY_ELEMENT_RULE', l_id, 'SAVE', 'SUCCESS', p_new_values => '{"element":' || jt(p_element_code) || '}');
    RETURN l_id;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END save_allowance_rule;

  PROCEDURE end_rule(p_rule_id IN NUMBER, p_last_day IN DATE DEFAULT NULL) IS
  BEGIN
    guard('PAY_ELEMENT.UPDATE');
    UPDATE pay_element_rule SET effective_to = GREATEST(effective_from, NVL(TRUNC(p_last_day), TRUNC(SYSDATE)))
     WHERE id = p_rule_id AND tenant_id IS NOT NULL AND formula_type IN ('FIXED', 'PCT_OF_ELEMENT');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PAY-071', 'قاعدة المؤسسة غير موجودة', 'Rule not found');
  END end_rule;

  FUNCTION rule_text(p_rule_id IN NUMBER) RETURN VARCHAR2 IS
    l pay_element_rule%ROWTYPE;
    l_prm JSON_OBJECT_T;
  BEGIN
    SELECT * INTO l FROM pay_element_rule WHERE id = p_rule_id;
    l_prm := JSON_OBJECT_T.parse(NVL(l.parameters, '{}'));
    RETURN CASE l.formula_type WHEN 'FIXED' THEN 'مبلغ ثابت ' || fnum(pnum(l_prm, 'amount', 0))
                WHEN 'PCT_OF_ELEMENT' THEN pct(pnum(l_prm, 'pct', 0)) || ' من '
                     || ename(CASE WHEN l_prm.has('of') THEN l_prm.get_string('of') ELSE 'BASIC' END)
                ELSE 'قاعدة نظامية' END
        || CASE WHEN l.min_amount IS NOT NULL THEN ' · حد أدنى ' || fnum(l.min_amount) END
        || CASE WHEN l.max_amount IS NOT NULL THEN ' · حد أعلى ' || fnum(l.max_amount) END;
  END rule_text;

  FUNCTION eos_amount(p_employment_id IN NUMBER, p_date IN DATE, p_type IN VARCHAR2 DEFAULT 'END_OF_CONTRACT') RETURN NUMBER IS
    l_y    NUMBER := NOONA_HR_PKG.service_years(p_employment_id, p_date);
    l_w    NUMBER := eos_wage(p_employment_id, p_date);
    l_full NUMBER;
  BEGIN
    l_full := l_w * (0.5 * LEAST(l_y, 5) + GREATEST(l_y - 5, 0));
    IF p_type = 'RESIGNATION' THEN
      RETURN ROUND(l_full * CASE WHEN l_y < 2 THEN 0 WHEN l_y < 5 THEN 1 / 3 WHEN l_y < 10 THEN 2 / 3 ELSE 1 END, 2);
    END IF;
    RETURN ROUND(l_full, 2);
  END eos_amount;

  FUNCTION loan_outstanding(p_employment_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(outstanding_balance), 0) INTO l FROM pay_loan WHERE employment_id = p_employment_id AND status_code = 'ACTIVE';
    RETURN l;
  END loan_outstanding;

  -- ================================================================ المدخلات
  FUNCTION add_input(p_period_id IN NUMBER, p_employment_id IN NUMBER, p_element_code IN VARCHAR2, p_quantity IN NUMBER,
                     p_amount IN NUMBER) RETURN NUMBER IS
    l_p  pay_period%ROWTYPE;
    l_n  NUMBER;
    l_id NUMBER;
  BEGIN
    guard('PAY_INPUT.CREATE');
    SELECT * INTO l_p FROM pay_period WHERE id = p_period_id AND company_id = company;
    SELECT COUNT(*) INTO l_n FROM hr_employment WHERE id = p_employment_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-PAY-010', 'الموظف غير موجود في الشركة الحالية', 'Employment not found');
    NOONA_CORE_PKG.assert(p_element_code IN ('OVERTIME', 'BONUS', 'COMMISSION', 'PENALTY', 'OTHER_DED', 'ABSENCE', 'OTHER_ALLOW'),
      'NOONA-PAY-011', 'العنصر لا يقبل إدخالاً متغيراً', 'Element does not accept variable input');
    NOONA_CORE_PKG.assert(NVL(p_quantity, 0) > 0 OR NVL(p_amount, 0) > 0, 'NOONA-PAY-012', 'أدخل الكمية أو المبلغ', 'Quantity or amount required');
    SELECT COUNT(*) INTO l_n FROM pay_run WHERE period_id = p_period_id AND status_code IN ('POSTED', 'PAID', 'CLOSED') AND run_type = 'REGULAR';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PAY-013', 'رواتب الفترة مرحلة؛ أدخلها في الفترة التالية', 'Period payroll already posted');
    INSERT INTO pay_input (company_id, period_id, employment_id, element_id, quantity, amount, status_code)
    VALUES (company, p_period_id, p_employment_id, NOONA_HR_PKG.element_id(p_element_code), p_quantity, ROUND(p_amount, 2), 'PENDING')
    RETURNING id INTO l_id;
    RETURN l_id;
  END add_input;

  PROCEDURE delete_input(p_id IN NUMBER) IS
  BEGIN
    guard('PAY_INPUT.DELETE');
    DELETE FROM pay_input WHERE id = p_id AND company_id = company AND status_code IN ('PENDING', 'VALIDATED');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PAY-014', 'المدخل مطبق في رواتب مرحلة؛ لا يحذف', 'Input already applied');
  END delete_input;

  -- ================================================================ التشغيل
  FUNCTION run_row(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN pay_run%ROWTYPE IS
    l pay_run%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM pay_run WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM pay_run WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PAY-020', 'تشغيل الرواتب غير موجود', 'Payroll run not found');
  END run_row;

  FUNCTION create_run(p_period_id IN NUMBER, p_type IN VARCHAR2 DEFAULT 'REGULAR') RETURN NUMBER IS
    l_p  pay_period%ROWTYPE;
    l_n  NUMBER;
    l_id NUMBER;
  BEGIN
    guard('PAY_RUN.CREATE');
    SELECT * INTO l_p FROM pay_period WHERE id = p_period_id AND company_id = company;
    IF NVL(p_type, 'REGULAR') = 'REGULAR' THEN
      SELECT COUNT(*) INTO l_n FROM pay_run WHERE period_id = p_period_id AND run_type = 'REGULAR' AND status_code <> 'FAILED';
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PAY-021', 'يوجد تشغيل رواتب للفترة ' || l_p.period_code, 'A regular run already exists for the period');
    END IF;
    SELECT COUNT(*) INTO l_n FROM pay_run WHERE period_id = p_period_id;
    INSERT INTO pay_run (company_id, run_no, payroll_group_id, period_id, run_type, status_code)
    VALUES (company, 'PR-' || l_p.period_code || CASE WHEN NVL(p_type, 'REGULAR') <> 'REGULAR' THEN '-' || SUBSTR(p_type, 1, 2) || (l_n + 1) END,
            l_p.payroll_group_id, p_period_id, NVL(p_type, 'REGULAR'), 'OPEN')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PAY_RUN', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  END create_run;

  PROCEDURE result(p_re NUMBER, p_code VARCHAR2, p_qty NUMBER, p_rate NUMBER, p_amount NUMBER, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF ROUND(NVL(p_amount, 0), 2) = 0 THEN RETURN; END IF;
    INSERT INTO pay_run_result (company_id, run_employee_id, element_id, quantity, rate, amount, source_info)
    VALUES (company, p_re, NOONA_HR_PKG.element_id(p_code), p_qty, p_rate, ROUND(p_amount, 2), p_info);
  END result;

  -- حساب موظف واحد في تشغيل؛ p_eos تسوية نهائية (مكافأة وبدل إجازات وسداد كامل السلف)
  PROCEDURE calc_employee(p_run pay_run%ROWTYPE, p_p pay_period%ROWTYPE, p_m hr_employment%ROWTYPE,
                          p_eos hr_end_of_service%ROWTYPE, p_salary BOOLEAN) IS
    l_re     NUMBER;
    l_es     DATE := GREATEST(p_m.start_date, p_p.start_date);
    l_ee     DATE := LEAST(NVL(p_m.end_date, p_p.end_date), p_p.end_date);
    l_pdays  NUMBER := p_p.end_date - p_p.start_date + 1;
    l_payd   NUMBER;
    l_abs    NUMBER := 0;
    l_ot     NUMBER := 0;
    l_wage   NUMBER;
    l_basic  NUMBER;
    l_cat    VARCHAR2(30) := NOONA_HR_PKG.category(p_m.id);
    l_prm    JSON_OBJECT_T;
    l_base   NUMBER;
    l_gross  NUMBER := 0;
    l_ded    NUMBER := 0;
    l_er     NUMBER := 0;
    l_loan   NUMBER;
    l_amt    NUMBER;
    l_status VARCHAR2(30) := 'CALCULATED';
    l_err    VARCHAR2(1000);
  BEGIN
    IF l_ee < l_es THEN RETURN; END IF;
    l_payd := CASE WHEN p_salary THEN ROUND(c_days * (l_ee - l_es + 1) / l_pdays, 2) ELSE 0 END;
    INSERT INTO pay_run_employee (company_id, run_id, employment_id, payable_days, status_code)
    VALUES (company, p_run.id, p_m.id, l_payd, 'INCLUDED')
    RETURNING id INTO l_re;
    l_wage := monthly_wage(p_m.id, l_ee);
    l_basic := element_amount(p_m.id, 'BASIC', l_ee);
    IF p_salary THEN
      -- العناصر الثابتة (مبالغ أو نسب أو حسب السياسة) بالتناسب مع أيام الاستحقاق؛ الفترة تقسم عند كل تغير
      -- في عناصر الموظف أو في قواعد السياسة داخلها، ويحسب هيكل الراتب لكل جزء
      DECLARE
        TYPE t_dates IS TABLE OF DATE INDEX BY PLS_INTEGER;
        l_b   t_dates;
        l_st  t_lines;
        l_seg DATE;
        l_end DATE;
        l_cnt PLS_INTEGER := 0;
        TYPE t_acc IS RECORD (code VARCHAR2(50), etype VARCHAR2(30), rate NUMBER, qty NUMBER, amt NUMBER, info VARCHAR2(400));
        TYPE t_accs IS TABLE OF t_acc INDEX BY VARCHAR2(100);
        l_acc t_accs;
        l_key VARCHAR2(100);
      BEGIN
        FOR d IN (SELECT DISTINCT d FROM (
                    SELECT l_es d FROM dual
                    UNION ALL SELECT x.effective_from FROM pay_employee_element x WHERE x.employment_id = p_m.id
                    UNION ALL SELECT x.effective_to + 1 FROM pay_employee_element x WHERE x.employment_id = p_m.id AND x.effective_to IS NOT NULL
                    UNION ALL SELECT r.effective_from FROM pay_element_rule r WHERE r.formula_type IN ('FIXED', 'PCT_OF_ELEMENT') AND r.status_code = 'ACTIVE'
                    UNION ALL SELECT r.effective_to + 1 FROM pay_element_rule r WHERE r.formula_type IN ('FIXED', 'PCT_OF_ELEMENT')
                                                                                AND r.status_code = 'ACTIVE' AND r.effective_to IS NOT NULL)
                   WHERE d BETWEEN l_es AND l_ee ORDER BY d) LOOP
          l_cnt := l_cnt + 1; l_b(l_cnt) := d.d;
        END LOOP;
        FOR k IN 1 .. l_cnt LOOP
          l_seg := l_b(k);
          l_end := CASE WHEN k < l_cnt THEN l_b(k + 1) - 1 ELSE l_ee END;
          l_st := structure(p_m.id, l_seg);
          FOR i IN 1 .. l_st.COUNT LOOP
            IF l_st(i).recurring = 'Y' AND l_st(i).etype IN ('EARNING', 'DEDUCTION') AND NVL(l_st(i).amount, 0) > 0
               AND (l_st(i).prorated = 'Y' OR k = l_cnt) THEN
              l_amt := CASE WHEN l_st(i).prorated = 'Y' THEN l_st(i).amount * (l_end - l_seg + 1) / l_pdays ELSE l_st(i).amount END;
              -- سطر واحد لكل عنصر بنفس المبلغ الشهري (تجزئة الفترة لا تكرر البند في القسيمة)
              l_key := l_st(i).code || '|' || l_st(i).amount;
              IF NOT l_acc.EXISTS(l_key) THEN
                l_acc(l_key).code := l_st(i).code; l_acc(l_key).etype := l_st(i).etype; l_acc(l_key).rate := l_st(i).amount;
                l_acc(l_key).qty := 0; l_acc(l_key).amt := 0;
                l_acc(l_key).info := CASE WHEN l_st(i).method <> 'FIXED' THEN '{"method":' || jt(l_st(i).method) || ',"pct":' || jn(l_st(i).pct)
                                          || ',"of":' || jt(l_st(i).basis) || '}' END;
              END IF;
              l_acc(l_key).qty := l_acc(l_key).qty + c_days * (l_end - l_seg + 1) / l_pdays;
              l_acc(l_key).amt := l_acc(l_key).amt + l_amt;
            END IF;
          END LOOP;
        END LOOP;
        l_key := l_acc.FIRST;
        WHILE l_key IS NOT NULL LOOP
          result(l_re, l_acc(l_key).code, ROUND(l_acc(l_key).qty, 2), l_acc(l_key).rate, l_acc(l_key).amt, l_acc(l_key).info);
          IF l_acc(l_key).etype = 'EARNING' THEN l_gross := l_gross + ROUND(l_acc(l_key).amt, 2);
          ELSE l_ded := l_ded + ROUND(l_acc(l_key).amt, 2); END IF;
          l_key := l_acc.NEXT(l_key);
        END LOOP;
      END;
      -- الغياب والإجازة غير المدفوعة والأيام المدخلة: الأجر اليومي (الثابت / 30)
      l_abs := NOONA_HR_PKG.absent_days(p_m.employee_id, l_es, l_ee) + NOONA_HR_PKG.unpaid_leave_days(p_m.employee_id, l_es, l_ee);
      SELECT l_abs + NVL(SUM(i.quantity), 0) INTO l_abs FROM pay_input i JOIN pay_element el ON el.id = i.element_id
       WHERE i.period_id = p_p.id AND i.employment_id = p_m.id AND el.code = 'ABSENCE' AND i.status_code IN ('PENDING', 'VALIDATED');
      l_abs := LEAST(l_abs, l_payd);
      IF l_abs > 0 THEN
        l_amt := ROUND(l_abs * l_wage / c_days, 2);
        result(l_re, 'ABSENCE', l_abs, ROUND(l_wage / c_days, 4), l_amt, '{"days":' || jn(l_abs) || '}');
        l_ded := l_ded + l_amt;
      END IF;
      -- الإضافي: ساعة الأجر الفعلي + 50% من ساعة الأجر الأساسي (المادة 107)
      l_prm := rule_params('OVERTIME', NULL);
      l_ot := NOONA_HR_PKG.overtime_hours(p_m.employee_id, l_es, l_ee);
      SELECT l_ot + NVL(SUM(i.quantity), 0) INTO l_ot FROM pay_input i JOIN pay_element el ON el.id = i.element_id
       WHERE i.period_id = p_p.id AND i.employment_id = p_m.id AND el.code = 'OVERTIME' AND i.status_code IN ('PENDING', 'VALIDATED');
      IF l_ot > 0 THEN
        l_amt := l_ot * (l_wage / pnum(l_prm, 'days_per_month', 30) / pnum(l_prm, 'hours_per_day', 8)
                         + pnum(l_prm, 'premium_pct_of_basic', 50) / 100 * l_basic / pnum(l_prm, 'days_per_month', 30) / pnum(l_prm, 'hours_per_day', 8));
        result(l_re, 'OVERTIME', l_ot, ROUND(l_amt / l_ot, 4), l_amt, '{"hours":' || jn(l_ot) || '}');
        l_gross := l_gross + ROUND(l_amt, 2);
      END IF;
      -- المدخلات بالمبالغ
      FOR i IN (SELECT el.code, el.element_type, SUM(i.amount) amt, SUM(i.quantity) qty
                  FROM pay_input i JOIN pay_element el ON el.id = i.element_id
                 WHERE i.period_id = p_p.id AND i.employment_id = p_m.id AND i.status_code IN ('PENDING', 'VALIDATED')
                   AND el.code NOT IN ('ABSENCE', 'OVERTIME') AND NVL(i.amount, 0) <> 0
                 GROUP BY el.code, el.element_type) LOOP
        result(l_re, i.code, i.qty, NULL, i.amt, '{"source":"input"}');
        IF i.element_type = 'EARNING' THEN l_gross := l_gross + ROUND(i.amt, 2); ELSE l_ded := l_ded + ROUND(i.amt, 2); END IF;
      END LOOP;
      -- التأمينات الاجتماعية على (الأساسي + السكن) بحد أدنى وأعلى، بنسبة أيام الاستحقاق
      FOR g IN (SELECT 'GOSI_EE' code FROM dual UNION ALL SELECT 'GOSI_ER' FROM dual) LOOP
        l_prm := rule_params(g.code, l_cat);
        -- أساس الاشتراك من القاعدة («base»: عناصر الأجر الخاضعة)، افتراضياً الأساسي + السكن
        l_base := 0;
        IF l_prm.has('base') THEN
          DECLARE l_arr JSON_ARRAY_T := l_prm.get_array('base');
          BEGIN
            FOR k IN 0 .. l_arr.get_size - 1 LOOP l_base := l_base + element_amount(p_m.id, l_arr.get_string(k), l_ee); END LOOP;
          END;
        ELSE
          l_base := l_basic + element_amount(p_m.id, 'HOUSING', l_ee);
        END IF;
        l_base := LEAST(GREATEST(l_base, pnum(l_prm, 'min', 0)), pnum(l_prm, 'max', 1e12));
        l_amt := ROUND(l_base * l_payd / c_days * pnum(l_prm, 'pct', 0) / 100, 2);
        IF l_amt > 0 THEN
          result(l_re, g.code, ROUND(l_base * l_payd / c_days, 2), pnum(l_prm, 'pct', 0), l_amt, '{"category":' || jt(l_cat) || '}');
          IF g.code = 'GOSI_EE' THEN l_ded := l_ded + l_amt; ELSE l_er := l_er + l_amt; END IF;
        END IF;
      END LOOP;
    END IF;
    -- التسوية النهائية
    IF p_eos.id IS NOT NULL THEN
      IF NVL(p_eos.eos_amount, 0) > 0 THEN
        result(l_re, 'EOS', ROUND(NOONA_HR_PKG.service_years(p_m.id, p_eos.last_working_date), 4), NULL, p_eos.eos_amount);
        l_gross := l_gross + p_eos.eos_amount;
      END IF;
      IF NVL(p_eos.leave_encashment, 0) > 0 THEN
        result(l_re, 'LEAVE_PAY', JSON_VALUE(p_eos.clearance_checklist, '$.leave_days' RETURNING NUMBER), NULL, p_eos.leave_encashment);
        l_gross := l_gross + p_eos.leave_encashment;
      END IF;
    END IF;
    -- أقساط السلف المستحقة حتى نهاية الفترة (والرصيد كاملاً في التسوية النهائية)
    IF p_eos.id IS NOT NULL THEN
      l_loan := loan_outstanding(p_m.id);
    ELSE
      SELECT NVL(SUM(LEAST(i.amount - i.deducted_amount, l.outstanding_balance)), 0) INTO l_loan
        FROM pay_loan_installment i JOIN pay_loan l ON l.id = i.loan_id JOIN pay_period p ON p.id = i.period_id
       WHERE l.employment_id = p_m.id AND l.status_code = 'ACTIVE' AND i.status_code = 'SCHEDULED' AND p.start_date <= p_p.end_date;
    END IF;
    IF l_loan > 0 THEN
      result(l_re, 'LOAN', NULL, NULL, l_loan);
      l_ded := l_ded + ROUND(l_loan, 2);
    END IF;
    IF l_gross - l_ded < 0 THEN
      l_status := 'ERROR';
      l_err := 'الخصومات (' || fnum(l_ded) || ') تتجاوز المستحقات (' || fnum(l_gross) || ')';
    ELSIF p_m.iban IS NULL AND l_gross - l_ded > 0 THEN
      l_err := 'لا يوجد آيبان للموظف';
    END IF;
    UPDATE pay_run_employee
       SET gross_amount = ROUND(l_gross, 2), deduction_amount = ROUND(l_ded, 2), net_amount = ROUND(l_gross - l_ded, 2),
           employer_cost = ROUND(l_gross + l_er, 2), absence_days = l_abs, overtime_hours = l_ot, status_code = l_status,
           error_message = l_err,
           cost_allocation = '{"cost_center":' || NVL(TO_CHAR(p_m.cost_center_id), 'null') || '}'
     WHERE id = l_re;
  END calc_employee;

  FUNCTION calculate(p_run_id IN NUMBER) RETURN NUMBER IS
    l_r    pay_run%ROWTYPE := run_row(p_run_id, TRUE);
    l_p    pay_period%ROWTYPE;
    l_eos  hr_end_of_service%ROWTYPE;
    l_none hr_end_of_service%ROWTYPE;
    l_n    NUMBER := 0;
    l_an   VARCHAR2(32767) := '[';
    l_prev NUMBER;
    l_reg  NUMBER;
  BEGIN
    guard('PAY_RUN.CREATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('OPEN', 'CALCULATED'), 'NOONA-PAY-022', 'لا يعاد حساب تشغيل معتمد أو مرحل',
      'Only open or calculated runs can be calculated');
    SELECT * INTO l_p FROM pay_period WHERE id = l_r.period_id;
    DELETE FROM pay_run_result WHERE run_employee_id IN (SELECT id FROM pay_run_employee WHERE run_id = p_run_id);
    DELETE FROM pay_run_employee WHERE run_id = p_run_id;
    IF l_r.run_type = 'FINAL_SETTLEMENT' THEN
      SELECT * INTO l_eos FROM hr_end_of_service WHERE payroll_run_id = p_run_id;
      -- راتب الأيام الأخيرة إلا إذا صرفت رواتب الفترة بتشغيل عادي
      SELECT COUNT(*) INTO l_reg FROM pay_run_employee re JOIN pay_run r ON r.id = re.run_id
       WHERE r.period_id = l_r.period_id AND r.run_type = 'REGULAR' AND re.employment_id = l_eos.employment_id
         AND r.status_code IN ('POSTED', 'PAID', 'CLOSED');
      FOR m IN (SELECT * FROM hr_employment WHERE id = l_eos.employment_id) LOOP
        calc_employee(l_r, l_p, m, l_eos, l_reg = 0);
        l_n := l_n + 1;
      END LOOP;
    ELSE
      FOR m IN (SELECT * FROM hr_employment m
                 WHERE m.company_id = company AND NVL(m.payroll_group_id, l_r.payroll_group_id) = l_r.payroll_group_id
                   AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED', 'TERMINATED')
                   AND m.start_date <= l_p.end_date AND NVL(m.end_date, l_p.end_date) >= l_p.start_date
                   -- من سويت خدمته بتسوية نهائية في الفترة لا يدخل التشغيل العادي
                   AND NOT EXISTS (SELECT 1 FROM hr_end_of_service s JOIN pay_run fr ON fr.id = s.payroll_run_id
                                    WHERE s.employment_id = m.id AND fr.period_id = l_p.id)
                   AND NOT (m.status_code = 'TERMINATED' AND m.end_date < l_p.start_date)
                   -- من لا هيكل راتب له (عضوية أو تعيين تنظيمي فقط) لا يدخل الرواتب
                   AND EXISTS (SELECT 1 FROM pay_employee_element x WHERE x.employment_id = m.id)
                 ORDER BY m.id) LOOP
        calc_employee(l_r, l_p, m, l_none, TRUE);
        l_n := l_n + 1;
      END LOOP;
    END IF;
    -- المقارنة بالفترة السابقة: تغير الصافي أكثر من 20% أو أخطاء أو نقص آيبان
    FOR a IN (SELECT re.employment_id, re.net_amount, re.status_code, re.error_message FROM pay_run_employee re WHERE re.run_id = p_run_id) LOOP
      SELECT MAX(pe.net_amount) KEEP (DENSE_RANK FIRST ORDER BY pp.start_date DESC) INTO l_prev
        FROM pay_run_employee pe JOIN pay_run pr ON pr.id = pe.run_id JOIN pay_period pp ON pp.id = pr.period_id
       WHERE pe.employment_id = a.employment_id AND pr.run_type = 'REGULAR' AND pr.status_code IN ('POSTED', 'PAID', 'CLOSED')
         AND pp.start_date < l_p.start_date;
      IF a.error_message IS NOT NULL OR (l_prev > 0 AND ABS(a.net_amount - l_prev) / l_prev > 0.2) THEN
        l_an := l_an || CASE WHEN l_an <> '[' THEN ',' END || '{"emp":' || a.employment_id || ',"name":'
             || jt(NOONA_HR_PKG.employment_label(a.employment_id)) || ',"msg":'
             || jt(NVL(a.error_message, 'الصافي ' || fnum(a.net_amount) || ' مقابل ' || fnum(l_prev) || ' في الفترة السابقة')) || ',"error":'
             || jt(CASE WHEN a.status_code = 'ERROR' THEN 'Y' ELSE 'N' END) || '}';
      END IF;
    END LOOP;
    UPDATE pay_run r
       SET (employee_count, total_gross, total_deductions, total_net, total_employer_cost) =
           (SELECT COUNT(*), NVL(SUM(gross_amount), 0), NVL(SUM(deduction_amount), 0), NVL(SUM(net_amount), 0), NVL(SUM(employer_cost), 0)
              FROM pay_run_employee WHERE run_id = p_run_id),
           anomaly_report = l_an || ']', calculated_at = SYSTIMESTAMP, status_code = 'CALCULATED'
     WHERE id = p_run_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PAY_RUN', p_run_id, 'CALCULATE', 'SUCCESS', p_new_values => '{"employees":' || l_n || '}');
    RETURN l_n;
  END calculate;

  PROCEDURE approve_run(p_run_id IN NUMBER) IS
    l_r pay_run%ROWTYPE := run_row(p_run_id, TRUE);
    l_n NUMBER;
  BEGIN
    guard('PAY_RUN.APPROVE');
    NOONA_CORE_PKG.assert(l_r.status_code = 'CALCULATED', 'NOONA-PAY-023', 'التشغيل ليس محسوباً بانتظار الاعتماد', 'Run is not calculated');
    SELECT COUNT(*) INTO l_n FROM pay_run_employee WHERE run_id = p_run_id AND status_code = 'ERROR';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PAY-024', 'يوجد ' || l_n || ' موظف بأخطاء؛ عالجها وأعد الحساب', 'Run has employees in error');
    SELECT COUNT(*) INTO l_n FROM pay_run_employee WHERE run_id = p_run_id;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-PAY-025', 'لا يوجد موظفون في التشغيل', 'Run has no employees');
    UPDATE pay_run SET status_code = 'APPROVED' WHERE id = p_run_id;
    UPDATE pay_run_employee SET status_code = 'APPROVED' WHERE run_id = p_run_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'PAY_RUN', p_run_id, 'APPROVE', 'SUCCESS');
  END approve_run;

  PROCEDURE delete_run(p_run_id IN NUMBER) IS
    l_r pay_run%ROWTYPE := run_row(p_run_id, TRUE);
  BEGIN
    guard('PAY_RUN.DELETE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('OPEN', 'CALCULATED', 'APPROVED'), 'NOONA-PAY-026', 'لا يحذف تشغيل مرحل', 'Posted runs cannot be deleted');
    DELETE FROM pay_run_result WHERE run_employee_id IN (SELECT id FROM pay_run_employee WHERE run_id = p_run_id);
    DELETE FROM pay_run_employee WHERE run_id = p_run_id;
    UPDATE hr_end_of_service SET payroll_run_id = NULL, status_code = 'SETTLEMENT_CALCULATED' WHERE payroll_run_id = p_run_id;
    DELETE FROM pay_run WHERE id = p_run_id;
  END delete_run;

  -- سطور القيد مجمعة بالحساب ومركز التكلفة
  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_cc NUMBER, p_desc VARCHAR2) IS
    l_amt NUMBER := ROUND(NVL(p_dr, 0) - NVL(p_cr, 0), 2);
  BEGIN
    IF l_amt = 0 THEN RETURN; END IF;
    FOR i IN 1 .. p_lines.COUNT LOOP
      IF p_lines(i).account_id = p_acc AND NVL(p_lines(i).cost_center_id, -1) = NVL(p_cc, -1) THEN
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
  END add_line;

  FUNCTION provision_balance(p_employment NUMBER, p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(MAX(a.closing_balance) KEEP (DENSE_RANK FIRST ORDER BY p.start_date DESC), 0) INTO l
      FROM pay_accrual a JOIN pay_period p ON p.id = a.period_id
     WHERE a.employment_id = p_employment AND a.accrual_type = p_type AND a.posted_at IS NOT NULL;
    RETURN l;
  END provision_balance;

  -- المخصصات: الالتزام في نهاية الفترة ناقص الرصيد السابق (مكافأة نهاية الخدمة كاملة، والإجازات المتاحة × الأجر اليومي)
  FUNCTION post_accruals(p_r pay_run%ROWTYPE, p_p pay_period%ROWTYPE, p_date DATE) RETURN NUMBER IS
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_open  NUMBER;
    l_close NUMBER;
    l_days  NUMBER;
    l_j     NUMBER;
    l_info  VARCHAR2(1000);
  BEGIN
    FOR e IN (SELECT re.employment_id, m.employee_id, m.cost_center_id FROM pay_run_employee re JOIN hr_employment m ON m.id = re.employment_id
               WHERE re.run_id = p_r.id) LOOP
      FOR t IN (SELECT 'END_OF_SERVICE' typ FROM dual UNION ALL SELECT 'LEAVE_PAY' FROM dual) LOOP
        l_open := provision_balance(e.employment_id, t.typ);
        IF t.typ = 'END_OF_SERVICE' THEN
          l_close := eos_amount(e.employment_id, p_p.end_date, 'END_OF_CONTRACT');
        ELSE
          l_days := GREATEST(NOONA_HR_PKG.leave_available(e.employee_id, 'ANNUAL', p_p.end_date), 0);
          l_close := ROUND(l_days * eos_wage(e.employment_id, p_p.end_date) / c_days, 2);
        END IF;
        l_info := '{"years":' || jn(NOONA_HR_PKG.service_years(e.employment_id, p_p.end_date)) || ',"wage":'
               || jn(eos_wage(e.employment_id, p_p.end_date)) || ',"leave_days":' || jn(l_days) || '}';
        MERGE INTO pay_accrual a
        USING (SELECT p_p.id pid, e.employment_id eid, t.typ typ FROM dual) x
           ON (a.period_id = x.pid AND a.employment_id = x.eid AND a.accrual_type = x.typ)
         WHEN MATCHED THEN UPDATE SET a.opening_balance = l_open, a.period_amount = l_close - l_open, a.closing_balance = l_close,
                                      a.posted_at = SYSTIMESTAMP, a.posted_by = NOONA_CTX_PKG.current_user_name
         WHEN NOT MATCHED THEN INSERT (company_id, period_id, employment_id, accrual_type, opening_balance, period_amount, closing_balance,
                                       calc_info, posted_at, posted_by)
              VALUES (company, p_p.id, e.employment_id, t.typ, l_open, l_close - l_open, l_close,
                      l_info,
                      SYSTIMESTAMP, NOONA_CTX_PKG.current_user_name);
        IF t.typ = 'END_OF_SERVICE' THEN
          add_line(l_lines, need_acc('5215'), l_close - l_open, 0, e.cost_center_id, 'مخصص نهاية الخدمة');
          add_line(l_lines, need_acc('2202'), 0, l_close - l_open, NULL, 'مخصص نهاية الخدمة');
        ELSE
          add_line(l_lines, need_acc('5216'), l_close - l_open, 0, e.cost_center_id, 'مخصص الإجازات');
          add_line(l_lines, need_acc('2109'), 0, l_close - l_open, NULL, 'مخصص الإجازات');
        END IF;
      END LOOP;
    END LOOP;
    IF l_lines.COUNT = 0 THEN RETURN NULL; END IF;
    l_j := NOONA_ACE_PKG.post_source('PAY_ACCRUAL_POSTED', 'PAYROLL', 'PAY_ACCRUAL', p_r.id, p_date,
             'مخصصات نهاية الخدمة والإجازات ' || p_p.period_code, NOONA_GL_PKG.ledger_currency, 1, l_lines, p_r.run_no, NULL, 'PAYROLL');
    RETURN l_j;
  END post_accruals;

  FUNCTION post_run(p_run_id IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_r     pay_run%ROWTYPE := run_row(p_run_id, TRUE);
    l_p     pay_period%ROWTYPE;
    l_date  DATE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_aj    NUMBER;
    l_ev    NUMBER;
    l_left  NUMBER;
    l_use   NUMBER;
    l_eos   hr_end_of_service%ROWTYPE;
  BEGIN
    guard('PAY_RUN.POST');
    NOONA_CORE_PKG.assert(l_r.status_code = 'APPROVED', 'NOONA-PAY-027', 'التشغيل غير معتمد', 'Run is not approved');
    SELECT * INTO l_p FROM pay_period WHERE id = l_r.period_id;
    l_date := NVL(p_date, l_p.end_date);
    FOR x IN (SELECT re.employment_id, m.cost_center_id, el.code, el.classification, el.element_type, SUM(rr.amount) amt
                FROM pay_run_employee re JOIN hr_employment m ON m.id = re.employment_id
                JOIN pay_run_result rr ON rr.run_employee_id = re.id JOIN pay_element el ON el.id = rr.element_id
               WHERE re.run_id = p_run_id
               GROUP BY re.employment_id, m.cost_center_id, el.code, el.classification, el.element_type) LOOP
      IF x.code = 'EOS' THEN
        l_use := LEAST(x.amt, GREATEST(provision_balance(x.employment_id, 'END_OF_SERVICE'), 0));
        add_line(l_lines, need_acc('2202'), l_use, 0, NULL, 'مكافأة نهاية الخدمة من المخصص');
        add_line(l_lines, need_acc('5215'), x.amt - l_use, 0, x.cost_center_id, 'مكافأة نهاية الخدمة');
      ELSIF x.code = 'LEAVE_PAY' THEN
        l_use := LEAST(x.amt, GREATEST(provision_balance(x.employment_id, 'LEAVE_PAY'), 0));
        add_line(l_lines, need_acc('2109'), l_use, 0, NULL, 'بدل الإجازات من المخصص');
        add_line(l_lines, need_acc('5216'), x.amt - l_use, 0, x.cost_center_id, 'بدل الإجازات');
      ELSIF x.element_type = 'EARNING' THEN
        add_line(l_lines, need_acc('5201'), x.amt, 0, x.cost_center_id, 'الرواتب والأجور ' || l_p.period_code);
      ELSIF x.code = 'ABSENCE' THEN
        add_line(l_lines, need_acc('5201'), 0, x.amt, x.cost_center_id, 'خصم الغياب ' || l_p.period_code);
      ELSIF x.code = 'GOSI_EE' THEN
        add_line(l_lines, need_acc('2108'), 0, x.amt, NULL, 'التأمينات الاجتماعية - حصة الموظفين');
      ELSIF x.code = 'GOSI_ER' THEN
        add_line(l_lines, need_acc('5214'), x.amt, 0, x.cost_center_id, 'التأمينات الاجتماعية - حصة المنشأة');
        add_line(l_lines, need_acc('2108'), 0, x.amt, NULL, 'التأمينات الاجتماعية - حصة المنشأة');
      ELSIF x.code = 'LOAN' THEN
        add_line(l_lines, need_acc('1108'), 0, x.amt, NULL, 'استرداد سلف الموظفين');
      ELSE
        add_line(l_lines, need_acc('4201'), 0, x.amt, NULL, 'جزاءات وخصومات الموظفين');
      END IF;
    END LOOP;
    add_line(l_lines, need_acc('2106'), 0, NVL(l_r.total_net, 0), NULL, 'صافي الرواتب المستحقة ' || l_p.period_code);
    l_j := NOONA_ACE_PKG.post_source('PAY_RUN_POSTED', 'PAYROLL', 'PAY_RUN', p_run_id, l_date,
             CASE l_r.run_type WHEN 'FINAL_SETTLEMENT' THEN 'مخالصة نهاية خدمة ' ELSE 'رواتب ' END || l_p.period_code || ' (' || l_r.run_no || ')',
             NOONA_GL_PKG.ledger_currency, 1, l_lines, l_r.run_no, NULL, 'PAYROLL');
    SELECT MAX(id) INTO l_ev FROM ace_accounting_event
     WHERE source_entity_type = 'PAY_RUN' AND source_entity_id = p_run_id AND status_code = 'POSTED' AND reversal_of_event_id IS NULL;
    -- المدخلات والسلف
    UPDATE pay_input SET status_code = 'APPLIED'
     WHERE period_id = l_r.period_id AND status_code IN ('PENDING', 'VALIDATED')
       AND employment_id IN (SELECT employment_id FROM pay_run_employee WHERE run_id = p_run_id);
    FOR re IN (SELECT re.id, re.employment_id, rr.amount, rr.id rid FROM pay_run_employee re
                 JOIN pay_run_result rr ON rr.run_employee_id = re.id JOIN pay_element el ON el.id = rr.element_id
                WHERE re.run_id = p_run_id AND el.code = 'LOAN') LOOP
      l_left := re.amount;
      FOR i IN (SELECT i.id, i.loan_id, i.amount - i.deducted_amount due FROM pay_loan_installment i JOIN pay_loan l ON l.id = i.loan_id
                  LEFT JOIN pay_period p ON p.id = i.period_id
                 WHERE l.employment_id = re.employment_id AND l.status_code = 'ACTIVE' AND i.status_code IN ('SCHEDULED', 'DEFERRED')
                 ORDER BY p.start_date NULLS LAST, i.installment_no) LOOP
        EXIT WHEN l_left <= 0;
        UPDATE pay_loan_installment SET deducted_amount = deducted_amount + LEAST(i.due, l_left), run_result_id = re.rid,
                                        status_code = CASE WHEN LEAST(i.due, l_left) >= i.due THEN 'DEDUCTED' ELSE status_code END
         WHERE id = i.id;
        UPDATE pay_loan SET outstanding_balance = outstanding_balance - LEAST(i.due, l_left) WHERE id = i.loan_id;
        l_left := l_left - LEAST(i.due, l_left);
      END LOOP;
      UPDATE pay_loan SET status_code = 'SETTLED' WHERE employment_id = re.employment_id AND status_code = 'ACTIVE' AND outstanding_balance <= 0;
      UPDATE pay_loan_installment SET status_code = 'SETTLED'
       WHERE status_code IN ('SCHEDULED', 'DEFERRED') AND loan_id IN (SELECT id FROM pay_loan WHERE employment_id = re.employment_id AND status_code = 'SETTLED');
    END LOOP;
    IF l_r.run_type = 'REGULAR' THEN
      l_aj := post_accruals(l_r, l_p, l_date);
    ELSIF l_r.run_type = 'FINAL_SETTLEMENT' THEN
      SELECT * INTO l_eos FROM hr_end_of_service WHERE payroll_run_id = p_run_id;
      UPDATE hr_employment SET status_code = 'TERMINATED', end_date = l_eos.last_working_date WHERE id = l_eos.employment_id;
      UPDATE hr_employee SET status_code = 'TERMINATED'
       WHERE id = (SELECT employee_id FROM hr_employment WHERE id = l_eos.employment_id)
         AND NOT EXISTS (SELECT 1 FROM hr_employment m2 WHERE m2.employee_id = hr_employee.id AND m2.id <> l_eos.employment_id
                            AND m2.status_code IN ('ACTIVE', 'NOTICE_PERIOD'));
      UPDATE hr_leave_balance SET encashed = encashed + NVL(JSON_VALUE(l_eos.clearance_checklist, '$.leave_days' RETURNING NUMBER), 0)
       WHERE employee_id = (SELECT employee_id FROM hr_employment WHERE id = l_eos.employment_id)
         AND balance_year = EXTRACT(YEAR FROM l_eos.last_working_date) AND leave_type_id = NOONA_HR_PKG.leave_type_id('ANNUAL');
      -- إقفال المخصصات للموظف
      UPDATE pay_accrual SET closing_balance = 0
       WHERE employment_id = l_eos.employment_id AND posted_at IS NOT NULL
         AND period_id = (SELECT MAX(a.period_id) KEEP (DENSE_RANK FIRST ORDER BY p.start_date DESC) FROM pay_accrual a
                            JOIN pay_period p ON p.id = a.period_id WHERE a.employment_id = l_eos.employment_id);
      UPDATE hr_end_of_service SET status_code = 'APPROVED' WHERE id = l_eos.id;
    END IF;
    UPDATE pay_run SET status_code = 'POSTED', accounting_event_id = l_ev, posted_at = SYSTIMESTAMP,
                       posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = p_run_id;
    RETURN l_j;
  END post_run;

  FUNCTION pay_out(p_run_id IN NUMBER, p_bank_account_id IN NUMBER DEFAULT NULL, p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_r     pay_run%ROWTYPE := run_row(p_run_id, TRUE);
    l_p     pay_period%ROWTYPE;
    l_bank  csh_bank_account%ROWTYPE;
    l_bid   NUMBER;
    l_file  NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_cnt   NUMBER;
    l_hash  VARCHAR2(128);
  BEGIN
    guard('PAY_BANK_FILE.CREATE');
    NOONA_CORE_PKG.assert(l_r.status_code = 'POSTED', 'NOONA-PAY-030', 'يصرف التشغيل بعد ترحيله', 'Run must be posted before payment');
    SELECT * INTO l_p FROM pay_period WHERE id = l_r.period_id;
    SELECT NVL(p_bank_account_id, MAX(g.bank_account_id)) INTO l_bid FROM pay_payroll_group g WHERE g.id = l_r.payroll_group_id;
    IF l_bid IS NULL THEN
      SELECT MIN(id) INTO l_bid FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE';
    END IF;
    NOONA_CORE_PKG.assert(l_bid IS NOT NULL, 'NOONA-PAY-031', 'حدد الحساب البنكي لصرف الرواتب', 'Bank account required');
    SELECT * INTO l_bank FROM csh_bank_account WHERE id = l_bid AND company_id = company;
    SELECT COUNT(*) INTO l_cnt FROM pay_run_employee WHERE run_id = p_run_id AND net_amount > 0;
    l_hash := LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(l_r.run_no || ':' || l_r.total_net || ':' || l_cnt), DBMS_CRYPTO.HASH_SH256)));
    INSERT INTO pay_bank_file (company_id, run_id, bank_account_id, file_format, total_amount, record_count, file_hash, sent_at,
                               confirmed_at, status_code)
    VALUES (company, p_run_id, l_bid, 'WPS_CSV', l_r.total_net, l_cnt, l_hash, SYSTIMESTAMP, SYSTIMESTAMP, 'PAYMENT_CONFIRMED')
    RETURNING id INTO l_file;
    INSERT INTO pay_bank_file_line (company_id, bank_file_id, run_employee_id, amount, status_code)
    SELECT company, l_file, id, net_amount, 'PAID' FROM pay_run_employee WHERE run_id = p_run_id AND net_amount > 0;
    add_line(l_lines, need_acc('2106'), l_r.total_net, 0, NULL, 'صرف الرواتب ' || l_p.period_code);
    add_line(l_lines, l_bank.gl_account_id, 0, l_r.total_net, NULL, 'تحويل الرواتب - ' || l_bank.name_ar);
    l_j := NOONA_ACE_PKG.post_source('PAY_RUN_PAID', 'PAYROLL', 'PAY_BANK_FILE', l_file, NVL(p_date, GREATEST(l_p.pay_date, TRUNC(SYSDATE))),
             'صرف رواتب ' || l_p.period_code || ' (' || l_r.run_no || ')', NOONA_GL_PKG.ledger_currency, 1, l_lines, l_r.run_no, NULL, 'PAYROLL');
    UPDATE pay_run SET status_code = 'PAID' WHERE id = p_run_id;
    UPDATE pay_run_employee SET status_code = 'PAID' WHERE run_id = p_run_id;
    INSERT INTO pay_payslip (company_id, run_employee_id, published_at, status_code)
    SELECT company, id, SYSTIMESTAMP, 'PUBLISHED' FROM pay_run_employee re WHERE run_id = p_run_id
       AND NOT EXISTS (SELECT 1 FROM pay_payslip s WHERE s.run_employee_id = re.id);
    UPDATE hr_end_of_service SET status_code = 'PAID' WHERE payroll_run_id = p_run_id;
    RETURN l_file;
  END pay_out;

  FUNCTION bank_file_csv(p_file_id IN NUMBER) RETURN CLOB IS
    l_f   pay_bank_file%ROWTYPE;
    l_out CLOB;
    l_co  VARCHAR2(400);
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('PAY_BANK_FILE.VIEW', company);
    SELECT * INTO l_f FROM pay_bank_file WHERE id = p_file_id AND company_id = company;
    SELECT MAX(NVL(trade_name_ar, legal_name_ar)) INTO l_co FROM org_company WHERE id = company;
    l_out := 'Employee No,Name,National ID,Bank,IBAN,Basic Salary,Housing,Other Earnings,Deductions,Net Salary' || CHR(13) || CHR(10);
    FOR r IN (SELECT e.employee_no, p.display_name_ar nm, e.national_id, b.code bank, m.iban, re.net_amount, re.deduction_amount,
                     re.gross_amount, re.id
                FROM pay_bank_file_line l JOIN pay_run_employee re ON re.id = l.run_employee_id
                JOIN hr_employment m ON m.id = re.employment_id JOIN hr_employee e ON e.id = m.employee_id
                JOIN pty_party p ON p.id = e.person_party_id LEFT JOIN ref_bank b ON b.id = m.bank_id
               WHERE l.bank_file_id = p_file_id ORDER BY e.employee_no) LOOP
      l_out := l_out || ((r.employee_no || ',"' || REPLACE(r.nm, '"', '') || '",' || r.national_id || ',' || r.bank || ',' || r.iban || ','
            || TO_CHAR(res(r.id, 'BASIC'), 'FM9999999990.00') || ',' || TO_CHAR(res(r.id, 'HOUSING'), 'FM9999999990.00') || ','
            || TO_CHAR(r.gross_amount - res(r.id, 'BASIC,HOUSING'), 'FM9999999990.00') || ','
            || TO_CHAR(r.deduction_amount, 'FM9999999990.00') || ',' || TO_CHAR(r.net_amount, 'FM9999999990.00') || CHR(13) || CHR(10)));
    END LOOP;
    NOONA_AUDIT_PKG.log_event('EXPORT', 'PAY_BANK_FILE', p_file_id, 'EXPORT', 'SUCCESS');
    RETURN l_out;
  END bank_file_csv;

  -- ================================================================ السلف
  FUNCTION create_loan(p_employment_id IN NUMBER, p_type IN VARCHAR2, p_principal IN NUMBER, p_installments IN NUMBER,
                       p_start_period_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l_m   hr_employment%ROWTYPE;
    l_p   pay_period%ROWTYPE;
    l_id  NUMBER;
    l_ins NUMBER;
    l_pid NUMBER;
    l_d   DATE;
  BEGIN
    guard('PAY_LOAN.CREATE');
    SELECT * INTO l_m FROM hr_employment WHERE id = p_employment_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_m.status_code IN ('ACTIVE', 'NOTICE_PERIOD'), 'NOONA-PAY-040', 'الموظف ليس على رأس العمل', 'Employee is not active');
    NOONA_CORE_PKG.assert(p_principal > 0 AND p_installments BETWEEN 1 AND 60, 'NOONA-PAY-041', 'المبلغ موجب والأقساط من 1 إلى 60',
      'Positive amount and 1-60 installments');
    l_ins := ROUND(p_principal / p_installments, 2);
    SELECT * INTO l_p FROM pay_period WHERE id = NVL(p_start_period_id, period_for(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), 1))) AND company_id = company;
    -- لا يتجاوز القسط نصف الأجر الشهري (المادة 92) في فترة بداية الخصم
    NOONA_CORE_PKG.assert(l_ins <= monthly_wage(p_employment_id, GREATEST(l_p.end_date, l_m.start_date)) / 2, 'NOONA-PAY-042',
      'القسط ' || fnum(l_ins) || ' يتجاوز نصف الأجر الشهري؛ زد عدد الأقساط', 'Installment exceeds half of the monthly wage');
    NOONA_HR_PKG.ensure_sequence('PAY_LOAN', 'LN-');
    INSERT INTO pay_loan (company_id, doc_no, doc_date, currency_code, exchange_rate, rate_date, employment_id, loan_type, principal_amount,
                          installment_amount, installments_count, start_period_id, outstanding_balance, status_code)
    VALUES (company, NOONA_REFERENCE_PKG.next_doc_no('PAY_LOAN', company, NULL, p_date, 'PAY_LOAN', NULL), p_date,
            NOONA_GL_PKG.ledger_currency, 1, p_date, p_employment_id, NVL(p_type, 'SALARY_ADVANCE'), ROUND(p_principal, 2), l_ins,
            p_installments, l_p.id, 0, 'APPROVED')
    RETURNING id INTO l_id;
    FOR i IN 1 .. p_installments LOOP
      l_d := ADD_MONTHS(l_p.start_date, i - 1);
      l_pid := period_for(l_d, l_p.payroll_group_id);
      INSERT INTO pay_loan_installment (company_id, loan_id, installment_no, period_id, amount, deducted_amount, status_code)
      VALUES (company, l_id, i, l_pid, CASE WHEN i = p_installments THEN ROUND(p_principal, 2) - l_ins * (p_installments - 1) ELSE l_ins END,
              0, 'SCHEDULED');
    END LOOP;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PAY_LOAN', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  END create_loan;

  FUNCTION disburse_loan(p_loan_id IN NUMBER, p_bank_account_id IN NUMBER DEFAULT NULL, p_cash_box_id IN NUMBER DEFAULT NULL,
                         p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l_l     pay_loan%ROWTYPE;
    l_acc   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
  BEGIN
    guard('PAY_LOAN.APPROVE');
    SELECT * INTO l_l FROM pay_loan WHERE id = p_loan_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_l.status_code = 'APPROVED', 'NOONA-PAY-043', 'السلفة ليست معتمدة بانتظار الصرف', 'Loan is not pending disbursement');
    IF p_cash_box_id IS NOT NULL THEN
      SELECT gl_account_id INTO l_acc FROM csh_cash_box WHERE id = p_cash_box_id AND company_id = company;
    ELSE
      SELECT gl_account_id INTO l_acc FROM csh_bank_account
       WHERE id = NVL(p_bank_account_id, (SELECT MIN(id) FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE'))
         AND company_id = company;
    END IF;
    add_line(l_lines, need_acc('1108'), l_l.principal_amount, 0, NULL, 'سلفة موظف ' || l_l.doc_no);
    add_line(l_lines, l_acc, 0, l_l.principal_amount, NULL, 'صرف سلفة ' || NOONA_HR_PKG.employment_label(l_l.employment_id));
    l_j := NOONA_ACE_PKG.post_source('PAY_LOAN_DISBURSED', 'PAYROLL', 'PAY_LOAN', p_loan_id, p_date,
             'صرف سلفة ' || l_l.doc_no || ' - ' || NOONA_HR_PKG.employment_label(l_l.employment_id), NOONA_GL_PKG.ledger_currency, 1,
             l_lines, l_l.doc_no, NULL, 'PAYROLL');
    UPDATE pay_loan SET status_code = 'ACTIVE', outstanding_balance = principal_amount WHERE id = p_loan_id;
    RETURN l_j;
  END disburse_loan;

  PROCEDURE defer_installment(p_loan_id IN NUMBER, p_installment_no IN NUMBER) IS
    l_i   pay_loan_installment%ROWTYPE;
    l_max NUMBER;
    l_d   DATE;
  BEGIN
    guard('PAY_LOAN.UPDATE');
    SELECT * INTO l_i FROM pay_loan_installment WHERE loan_id = p_loan_id AND installment_no = p_installment_no AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_i.status_code = 'SCHEDULED' AND l_i.deducted_amount = 0, 'NOONA-PAY-044', 'القسط ليس مجدولاً', 'Installment not scheduled');
    -- يؤجل لما بعد آخر قسط
    SELECT MAX(p.start_date) INTO l_d FROM pay_loan_installment i JOIN pay_period p ON p.id = i.period_id WHERE i.loan_id = p_loan_id;
    SELECT MAX(installment_no) INTO l_max FROM pay_loan_installment WHERE loan_id = p_loan_id;
    UPDATE pay_loan_installment SET status_code = 'DEFERRED', period_id = period_for(ADD_MONTHS(l_d, 1))
     WHERE loan_id = p_loan_id AND installment_no = p_installment_no;
    UPDATE pay_loan_installment SET status_code = 'SCHEDULED' WHERE loan_id = p_loan_id AND installment_no = p_installment_no;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PAY_LOAN', p_loan_id, 'DEFER', 'SUCCESS', p_new_values => '{"installment":' || p_installment_no || '}');
  END defer_installment;

  -- ================================================================ نهاية الخدمة
  FUNCTION calc_settlement(p_employment_id IN NUMBER, p_last_day IN DATE, p_type IN VARCHAR2, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_m     hr_employment%ROWTYPE;
    l_eos   NUMBER;
    l_days  NUMBER;
    l_leave NUMBER;
    l_loan  NUMBER;
    l_cust  NUMBER;
    l_id    NUMBER;
    l_n     NUMBER;
    l_info  VARCHAR2(2000);
  BEGIN
    guard('HR_END_OF_SERVICE.CREATE');
    SELECT * INTO l_m FROM hr_employment WHERE id = p_employment_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED'), 'NOONA-PAY-050', 'الموظف ليس على رأس العمل',
      'Employee is not active');
    NOONA_CORE_PKG.assert(p_last_day >= l_m.start_date, 'NOONA-PAY-051', 'آخر يوم عمل يسبق تاريخ التعيين', 'Last day precedes hire date');
    NOONA_CORE_PKG.assert(p_type IN ('RESIGNATION', 'END_OF_CONTRACT', 'TERMINATION', 'RETIREMENT', 'DEATH', 'OTHER'), 'NOONA-PAY-052',
      'سبب انتهاء الخدمة غير صحيح', 'Invalid termination type');
    SELECT COUNT(*) INTO l_n FROM hr_end_of_service WHERE employment_id = p_employment_id AND status_code NOT IN ('CLOSED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PAY-053', 'توجد مخالصة قائمة للموظف', 'A settlement already exists');
    -- الفصل لسبب مشروع (المادة 80) لا مكافأة له؛ يعالج كـ OTHER بمكافأة صفرية يدخلها المستخدم بالتسوية
    l_eos := CASE WHEN p_type = 'OTHER' THEN 0 ELSE eos_amount(p_employment_id, p_last_day, p_type) END;
    l_days := GREATEST(NOONA_HR_PKG.leave_available(l_m.employee_id, 'ANNUAL', p_last_day), 0);
    l_leave := ROUND(l_days * eos_wage(p_employment_id, p_last_day) / c_days, 2);
    l_loan := loan_outstanding(p_employment_id);
    SELECT COUNT(*) INTO l_cust FROM hr_custody WHERE employee_id = l_m.employee_id AND status_code = 'ASSIGNED';
    NOONA_HR_PKG.ensure_sequence('HR_END_OF_SERVICE', 'EOS-');
    l_info := '{"type":' || jt(p_type) || ',"reason":' || jt(p_reason) || ',"years":' || jn(NOONA_HR_PKG.service_years(p_employment_id, p_last_day))
            || ',"wage":' || jn(eos_wage(p_employment_id, p_last_day)) || ',"leave_days":' || jn(l_days) || ',"open_custody":' || l_cust || '}';
    INSERT INTO hr_end_of_service (company_id, doc_no, doc_date, employment_id, last_working_date, clearance_checklist, eos_amount,
                                   leave_encashment, deductions, net_settlement, status_code)
    VALUES (company, NOONA_REFERENCE_PKG.next_doc_no('HR_END_OF_SERVICE', company, NULL, TRUNC(SYSDATE), 'HR_END_OF_SERVICE', NULL),
            TRUNC(SYSDATE), p_employment_id, p_last_day,
            l_info,
            l_eos, l_leave, l_loan, l_eos + l_leave - l_loan, 'SETTLEMENT_CALCULATED')
    RETURNING id INTO l_id;
    UPDATE hr_employment SET status_code = 'NOTICE_PERIOD', end_date = p_last_day, termination_type = p_type,
                             termination_reason = SUBSTR(p_reason, 1, 1000)
     WHERE id = p_employment_id;
    RETURN l_id;
  END calc_settlement;

  FUNCTION approve_settlement(p_settlement_id IN NUMBER) RETURN NUMBER IS
    l_s   hr_end_of_service%ROWTYPE;
    l_cnt NUMBER;
    l_run NUMBER;
    l_n   NUMBER;
  BEGIN
    guard('HR_END_OF_SERVICE.APPROVE');
    SELECT * INTO l_s FROM hr_end_of_service WHERE id = p_settlement_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_s.status_code = 'SETTLEMENT_CALCULATED' AND l_s.payroll_run_id IS NULL, 'NOONA-PAY-054',
      'المخالصة ليست بانتظار الاعتماد', 'Settlement is not pending approval');
    l_cnt := JSON_VALUE(l_s.clearance_checklist, '$.open_custody' RETURNING NUMBER);
    NOONA_CORE_PKG.assert(NVL(l_cnt, 0) = 0, 'NOONA-PAY-055', 'لدى الموظف عهد لم تسلم؛ أخل طرفه أولاً', 'Open custody items');
    l_run := create_run(period_for(l_s.last_working_date), 'FINAL_SETTLEMENT');
    UPDATE hr_end_of_service SET payroll_run_id = l_run, status_code = 'CLEARANCE_IN_PROGRESS' WHERE id = p_settlement_id;
    l_n := calculate(l_run);
    UPDATE hr_end_of_service SET status_code = 'SETTLEMENT_CALCULATED' WHERE id = p_settlement_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'HR_END_OF_SERVICE', p_settlement_id, 'APPROVE', 'SUCCESS');
    RETURN l_run;
  END approve_settlement;

  FUNCTION settlement_html(p_settlement_id IN NUMBER) RETURN CLOB IS
    l_s hr_end_of_service%ROWTYPE;
    l_t VARCHAR2(30);
  BEGIN
    SELECT * INTO l_s FROM hr_end_of_service WHERE id = p_settlement_id AND company_id = company;
    l_t := JSON_VALUE(l_s.clearance_checklist, '$.type');
    RETURN '<table class="nn-rpt"><tbody><tr><td class="nn-rpt-text">الموظف</td><td class="nn-rpt-text">' || esc(NOONA_HR_PKG.employment_label(l_s.employment_id))
        || '</td></tr><tr><td class="nn-rpt-text">آخر يوم عمل</td><td>' || TO_CHAR(l_s.last_working_date, 'YYYY-MM-DD')
        || '</td></tr><tr><td class="nn-rpt-text">سبب الانتهاء</td><td class="nn-rpt-text">'
        || CASE l_t WHEN 'RESIGNATION' THEN 'استقالة' WHEN 'END_OF_CONTRACT' THEN 'انتهاء العقد' WHEN 'TERMINATION' THEN 'إنهاء من صاحب العمل'
                    WHEN 'RETIREMENT' THEN 'تقاعد' WHEN 'DEATH' THEN 'وفاة' ELSE 'أخرى' END
        || '</td></tr><tr><td class="nn-rpt-text">مدة الخدمة</td><td>' || fnum(JSON_VALUE(l_s.clearance_checklist, '$.years' RETURNING NUMBER), 2)
        || ' سنة</td></tr><tr><td class="nn-rpt-text">أجر احتساب المكافأة (الأساسي والسكن والنقل)</td><td>'
        || fnum(JSON_VALUE(l_s.clearance_checklist, '$.wage' RETURNING NUMBER)) || '</td></tr><tr><td class="nn-rpt-text">مكافأة نهاية الخدمة</td><td>'
        || fnum(l_s.eos_amount) || '</td></tr><tr><td class="nn-rpt-text">بدل الإجازات (' || fnum(JSON_VALUE(l_s.clearance_checklist, '$.leave_days' RETURNING NUMBER), 1)
        || ' يوم)</td><td>' || fnum(l_s.leave_encashment) || '</td></tr><tr><td class="nn-rpt-text">السلف القائمة (تخصم)</td><td>'
        || fnum(l_s.deductions) || '</td></tr><tr class="nn-rpt-total"><td class="nn-rpt-text">صافي المخالصة (دون راتب الأيام الأخيرة)</td><td>'
        || fnum(l_s.net_settlement) || '</td></tr></tbody></table>';
  END settlement_html;

  FUNCTION run_status(p_run_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM pay_run WHERE id = p_run_id AND company_id = company;
    RETURN l;
  END run_status;

  FUNCTION run_file(p_run_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM pay_bank_file WHERE run_id = p_run_id AND company_id = company;
    RETURN l;
  END run_file;

  -- ================================================================ التقارير
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION pay_summary RETURN CLOB IS
    l_r    pay_run%ROWTYPE;
    l_eos  NUMBER;
    l_loan NUMBER;
    l_pend NUMBER;
    l_per  VARCHAR2(20);
  BEGIN
    BEGIN
      SELECT * INTO l_r FROM (SELECT r.* FROM pay_run r JOIN pay_period p ON p.id = r.period_id
                               WHERE r.company_id = company AND r.run_type = 'REGULAR' AND r.status_code IN ('POSTED', 'PAID', 'CLOSED')
                               ORDER BY p.start_date DESC) WHERE ROWNUM = 1;
      SELECT period_code INTO l_per FROM pay_period WHERE id = l_r.period_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    SELECT NVL(SUM(eos_amount(m.id, TRUNC(SYSDATE))), 0) INTO l_eos FROM hr_employment m
     WHERE m.company_id = company AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED');
    SELECT NVL(SUM(outstanding_balance), 0) INTO l_loan FROM pay_loan WHERE company_id = company AND status_code = 'ACTIVE';
    SELECT COUNT(*) INTO l_pend FROM pay_run WHERE company_id = company AND status_code IN ('CALCULATED', 'APPROVED', 'POSTED');
    RETURN '<div class="nn-kpis">'
        || kpi('صافي آخر رواتب مرحلة' || CASE WHEN l_per IS NOT NULL THEN ' (' || l_per || ')' END, NVL(fnum(l_r.total_net), '-'), 'fa-money', 'is-success')
        || kpi('إجمالي تكلفة الرواتب على المنشأة', NVL(fnum(l_r.total_employer_cost), '-'), 'fa-building', 'is-info')
        || kpi('التزام مكافأة نهاية الخدمة اليوم', fnum(l_eos), 'fa-shield', 'is-warning')
        || kpi('السلف القائمة', fnum(l_loan), 'fa-credit-card', 'is-info')
        || kpi('تشغيلات بانتظار إجراء', l_pend, 'fa-hourglass-half', CASE WHEN l_pend > 0 THEN 'is-warning' ELSE 'is-info' END)
        || '</div>';
  END pay_summary;

  FUNCTION run_header_html(p_run_id IN NUMBER) RETURN CLOB IS
    l_r   pay_run%ROWTYPE := run_row(p_run_id);
    l_p   pay_period%ROWTYPE;
    l_an  JSON_ARRAY_T;
    l_o   JSON_OBJECT_T;
    l_out CLOB;
  BEGIN
    SELECT * INTO l_p FROM pay_period WHERE id = l_r.period_id;
    l_out := '<div class="nn-kpis">' || kpi('الموظفون', NVL(l_r.employee_count, 0), 'fa-users')
          || kpi('الإجمالي', fnum(NVL(l_r.total_gross, 0)), 'fa-plus-circle', 'is-info')
          || kpi('الخصومات', fnum(NVL(l_r.total_deductions, 0)), 'fa-minus-circle', 'is-warning')
          || kpi('الصافي', fnum(NVL(l_r.total_net, 0)), 'fa-money', 'is-success')
          || kpi('تكلفة المنشأة', fnum(NVL(l_r.total_employer_cost, 0)), 'fa-building', 'is-info') || '</div>'
          || '<div class="nn-hr-runbar"><b>' || esc(l_r.run_no) || '</b> · الفترة ' || l_p.period_code || ' (' || TO_CHAR(l_p.start_date, 'YYYY-MM-DD')
          || ' – ' || TO_CHAR(l_p.end_date, 'YYYY-MM-DD') || ') · ' || CASE l_r.run_type WHEN 'FINAL_SETTLEMENT' THEN 'مخالصة نهاية خدمة'
             ELSE 'رواتب شهرية' END || ' · <span class="nn-badge ' || CASE WHEN l_r.status_code IN ('PAID', 'CLOSED') THEN 'is-success'
             WHEN l_r.status_code IN ('POSTED', 'APPROVED') THEN 'is-info' ELSE 'is-warning' END || '">' || status_label(l_r.status_code) || '</span></div>';
    IF l_r.anomaly_report IS NOT NULL AND l_r.anomaly_report <> '[]' THEN
      l_an := JSON_ARRAY_T.parse(l_r.anomaly_report);
      l_out := l_out || ('<div class="nn-hr-anom"><b>تنبيهات المراجعة</b><ul>');
      FOR i IN 0 .. l_an.get_size - 1 LOOP
        l_o := TREAT(l_an.get(i) AS JSON_OBJECT_T);
        l_out := l_out || ('<li class="' || CASE WHEN l_o.get_string('error') = 'Y' THEN 'is-err' END || '">' || esc(l_o.get_string('name'))
              || ': ' || esc(l_o.get_string('msg')) || '</li>');
      END LOOP;
      l_out := l_out || ('</ul></div>');
    END IF;
    RETURN l_out;
  END run_header_html;

  FUNCTION res(p_re NUMBER, p_codes VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(rr.amount), 0) INTO l FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
     WHERE rr.run_employee_id = p_re AND INSTR(',' || p_codes || ',', ',' || el.code || ',') > 0;
    RETURN l;
  END res;

  FUNCTION run_register_html(p_run_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_r   pay_run%ROWTYPE := run_row(p_run_id);
    l_out CLOB := '<div class="nn-rpt-wrap"><table class="nn-rpt nn-hr-reg"><thead><tr><th>الموظف</th><th>الأيام</th><th>الأساسي</th><th>السكن</th>'
               || '<th>النقل</th><th>بدلات أخرى</th><th>الإضافي</th><th>مكافآت وعمولات</th><th>نهاية الخدمة والإجازات</th><th>الإجمالي</th>'
               || '<th>الغياب</th><th>التأمينات</th><th>السلف</th><th>خصومات أخرى</th><th>الصافي</th><th>تكلفة المنشأة</th></tr></thead><tbody>';
    t     SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    v     SYS.ODCINUMBERLIST;
  BEGIN
    FOR r IN (SELECT re.* FROM pay_run_employee re JOIN hr_employment m ON m.id = re.employment_id JOIN hr_employee e ON e.id = m.employee_id
               WHERE re.run_id = p_run_id ORDER BY e.employee_no) LOOP
      v := SYS.ODCINUMBERLIST(res(r.id, 'BASIC'), res(r.id, 'HOUSING'), res(r.id, 'TRANSPORT'), res(r.id, 'OTHER_ALLOW'), res(r.id, 'OVERTIME'),
                              res(r.id, 'BONUS,COMMISSION'), res(r.id, 'EOS,LEAVE_PAY'), r.gross_amount, res(r.id, 'ABSENCE'), res(r.id, 'GOSI_EE'),
                              res(r.id, 'LOAN'), res(r.id, 'PENALTY,OTHER_DED'), r.net_amount, r.employer_cost);
      l_out := l_out || (('<tr' || CASE WHEN r.status_code = 'ERROR' THEN ' class="is-err"' END || '><td class="nn-rpt-text">'
            || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(NOONA_HR_PKG.employment_label(r.employment_id)) || '</a>'
                    ELSE esc(NOONA_HR_PKG.employment_label(r.employment_id)) END
            || CASE WHEN r.error_message IS NOT NULL THEN '<div class="nn-hr-err">' || esc(r.error_message) || '</div>' END
            || '</td><td>' || fnum(r.payable_days, 1) || CASE WHEN r.absence_days > 0 THEN '<small> (غياب ' || fnum(r.absence_days, 1) || ')</small>' END || '</td>'));
      FOR i IN 1 .. 14 LOOP
        l_out := l_out || (('<td' || CASE WHEN i IN (8, 13) THEN ' class="nn-hr-strong"' END || '>' || CASE WHEN v(i) <> 0 THEN fnum(v(i)) END || '</td>'));
        t(i) := t(i) + v(i);
      END LOOP;
      l_out := l_out || ('</tr>');
    END LOOP;
    l_out := l_out || ('</tbody><tfoot><tr><td class="nn-rpt-text">الإجمالي (' || NVL(l_r.employee_count, 0) || ')</td><td></td>');
    FOR i IN 1 .. 14 LOOP
      l_out := l_out || (('<td>' || fnum(t(i)) || '</td>'));
    END LOOP;
    RETURN l_out || ('</tr></tfoot></table></div>');
  END run_register_html;

  FUNCTION payslip_html(p_run_employee_id IN NUMBER) RETURN CLOB IS
    l_re  pay_run_employee%ROWTYPE;
    l_r   pay_run%ROWTYPE;
    l_p   pay_period%ROWTYPE;
    l_m   hr_employment%ROWTYPE;
    l_e   hr_employee%ROWTYPE;
    l_co  VARCHAR2(400);
    l_bk  VARCHAR2(200);
    l_out CLOB;
    l_ear CLOB := '';
    l_ded CLOB := '';
  BEGIN
    SELECT * INTO l_re FROM pay_run_employee WHERE id = p_run_employee_id AND company_id = company;
    l_r := run_row(l_re.run_id);
    SELECT * INTO l_p FROM pay_period WHERE id = l_r.period_id;
    SELECT * INTO l_m FROM hr_employment WHERE id = l_re.employment_id;
    SELECT * INTO l_e FROM hr_employee WHERE id = l_m.employee_id;
    SELECT MAX(NVL(trade_name_ar, legal_name_ar)) INTO l_co FROM org_company WHERE id = company;
    SELECT MAX(name_ar) INTO l_bk FROM ref_bank WHERE id = l_m.bank_id;
    FOR x IN (SELECT el.name_ar, el.element_type, rr.quantity, rr.amount, el.code FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
               WHERE rr.run_employee_id = p_run_employee_id AND el.show_on_payslip = 'Y' ORDER BY el.sort_order, rr.id) LOOP
      IF x.element_type = 'EARNING' THEN
        l_ear := l_ear || ('<tr><td class="nn-rpt-text">' || esc(x.name_ar)
              || CASE WHEN x.code = 'OVERTIME' THEN ' (' || fnum(x.quantity, 1) || ' ساعة)' END || '</td><td>' || fnum(x.amount) || '</td></tr>');
      ELSE
        l_ded := l_ded || ('<tr><td class="nn-rpt-text">' || esc(x.name_ar)
              || CASE WHEN x.code = 'ABSENCE' THEN ' (' || fnum(x.quantity, 1) || ' يوم)' END || '</td><td>' || fnum(x.amount) || '</td></tr>');
      END IF;
    END LOOP;
    l_out := '<div class="nn-payslip"><div class="nn-payslip-h"><div><b>' || esc(l_co) || '</b><span>قسيمة راتب '
          || CASE l_r.run_type WHEN 'FINAL_SETTLEMENT' THEN '- مخالصة نهاية الخدمة ' END || 'لشهر ' || l_p.period_code || '</span></div><div class="nn-payslip-net"><span>الصافي</span><b>'
          || fnum(l_re.net_amount) || '</b><small>' || esc(NOONA_GL_PKG.ledger_currency) || '</small></div></div>'
          || '<div class="nn-payslip-id"><div><span>الموظف</span><b>' || esc(NOONA_HR_PKG.employee_name(l_e.id)) || '</b></div><div><span>الرقم الوظيفي</span><b>'
          || esc(l_e.employee_no) || '</b></div><div><span>المسمى</span><b>' || esc(NVL(l_m.job_title, '-')) || '</b></div><div><span>أيام الاستحقاق</span><b>'
          || fnum(l_re.payable_days, 1) || '</b></div><div><span>البنك / الآيبان</span><b dir="ltr">' || esc(l_bk) || ' ' || esc(l_m.iban)
          || '</b></div><div><span>رصيد الإجازة السنوية</span><b>' || fnum(NOONA_HR_PKG.leave_available(l_e.id, 'ANNUAL', l_p.end_date), 1) || ' يوم</b></div></div>'
          || '<div class="nn-payslip-cols"><table class="nn-rpt"><thead><tr><th colspan="2">المستحقات</th></tr></thead><tbody>' || l_ear
          || '</tbody><tfoot><tr><td class="nn-rpt-text">إجمالي المستحقات</td><td>' || fnum(l_re.gross_amount) || '</td></tr></tfoot></table>'
          || '<table class="nn-rpt"><thead><tr><th colspan="2">الاستقطاعات</th></tr></thead><tbody>' || NVL(l_ded, '<tr><td colspan="2" class="nn-rpt-text">لا توجد</td></tr>')
          || '</tbody><tfoot><tr><td class="nn-rpt-text">إجمالي الاستقطاعات</td><td>' || fnum(l_re.deduction_amount) || '</td></tr></tfoot></table></div></div>';
    UPDATE pay_payslip SET viewed_at = NVL(viewed_at, SYSTIMESTAMP), status_code = 'VIEWED'
     WHERE run_employee_id = p_run_employee_id AND viewed_at IS NULL;
    RETURN l_out;
  END payslip_html;

  FUNCTION element_summary_html(p_run_id IN NUMBER) RETURN CLOB IS
    l_r   pay_run%ROWTYPE := run_row(p_run_id);
    l_out CLOB := '<table class="nn-rpt"><thead><tr><th>العنصر</th><th>النوع</th><th>عدد الموظفين</th><th>المبلغ</th></tr></thead><tbody>';
  BEGIN
    FOR x IN (SELECT el.name_ar, el.element_type, COUNT(DISTINCT re.id) n, SUM(rr.amount) amt
                FROM pay_run_employee re JOIN pay_run_result rr ON rr.run_employee_id = re.id JOIN pay_element el ON el.id = rr.element_id
               WHERE re.run_id = l_r.id GROUP BY el.name_ar, el.element_type, el.sort_order ORDER BY el.sort_order) LOOP
      l_out := l_out || (('<tr><td class="nn-rpt-text">' || esc(x.name_ar) || '</td><td class="nn-rpt-text">'
            || CASE x.element_type WHEN 'EARNING' THEN 'استحقاق' WHEN 'EMPLOYER_CONTRIBUTION' THEN 'على المنشأة' ELSE 'استقطاع' END
            || '</td><td>' || x.n || '</td><td>' || fnum(x.amt) || '</td></tr>'));
    END LOOP;
    RETURN l_out || ('</tbody></table>');
  END element_summary_html;

  FUNCTION gosi_report_html(p_run_id IN NUMBER) RETURN CLOB IS
    l_r   pay_run%ROWTYPE := run_row(p_run_id);
    l_out CLOB := '<table class="nn-rpt"><thead><tr><th>الموظف</th><th>الجنسية</th><th>رقم التأمينات</th><th>الأجر الخاضع</th>'
               || '<th>حصة الموظف</th><th>حصة المنشأة</th><th>الإجمالي</th></tr></thead><tbody>';
    l_ee  NUMBER := 0; l_er NUMBER := 0;
    a     NUMBER; b NUMBER; q NUMBER;
  BEGIN
    FOR r IN (SELECT re.id, re.employment_id, m.gosi_no, e.nationality FROM pay_run_employee re JOIN hr_employment m ON m.id = re.employment_id
                JOIN hr_employee e ON e.id = m.employee_id WHERE re.run_id = l_r.id ORDER BY e.employee_no) LOOP
      a := res(r.id, 'GOSI_EE'); b := res(r.id, 'GOSI_ER');
      SELECT MAX(rr.quantity) INTO q FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
       WHERE rr.run_employee_id = r.id AND el.code IN ('GOSI_EE', 'GOSI_ER');
      l_out := l_out || (('<tr><td class="nn-rpt-text">' || esc(NOONA_HR_PKG.employment_label(r.employment_id)) || '</td><td>' || esc(r.nationality)
            || '</td><td>' || esc(r.gosi_no) || '</td><td>' || fnum(q) || '</td><td>' || fnum(a) || '</td><td>' || fnum(b) || '</td><td>' || fnum(a + b) || '</td></tr>'));
      l_ee := l_ee + a; l_er := l_er + b;
    END LOOP;
    RETURN l_out || (('</tbody><tfoot><tr><td class="nn-rpt-text">الإجمالي</td><td></td><td></td><td></td><td>' || fnum(l_ee) || '</td><td>' || fnum(l_er)
        || '</td><td>' || fnum(l_ee + l_er) || '</td></tr></tfoot></table>'));
  END gosi_report_html;

  FUNCTION eos_liability_html(p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN CLOB IS
    l_out CLOB := '<table class="nn-rpt"><thead><tr><th>الموظف</th><th>تاريخ التعيين</th><th>مدة الخدمة (سنة)</th><th>أجر الاحتساب</th>'
               || '<th>المكافأة الكاملة</th><th>عند الاستقالة</th><th>رصيد المخصص المرحل</th></tr></thead><tbody>';
    l_t1 NUMBER := 0; l_t2 NUMBER := 0; l_t3 NUMBER := 0;
    a NUMBER; b NUMBER; c NUMBER;
  BEGIN
    FOR m IN (SELECT m.id, m.start_date FROM hr_employment m WHERE m.company_id = company AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED')
               ORDER BY m.start_date) LOOP
      a := eos_amount(m.id, p_date); b := eos_amount(m.id, p_date, 'RESIGNATION'); c := provision_balance(m.id, 'END_OF_SERVICE');
      l_out := l_out || (('<tr><td class="nn-rpt-text">' || esc(NOONA_HR_PKG.employment_label(m.id)) || '</td><td>' || TO_CHAR(m.start_date, 'YYYY-MM-DD')
            || '</td><td>' || fnum(NOONA_HR_PKG.service_years(m.id, p_date), 2) || '</td><td>' || fnum(eos_wage(m.id, p_date)) || '</td><td>' || fnum(a)
            || '</td><td>' || fnum(b) || '</td><td>' || fnum(c) || '</td></tr>'));
      l_t1 := l_t1 + a; l_t2 := l_t2 + b; l_t3 := l_t3 + c;
    END LOOP;
    RETURN l_out || (('</tbody><tfoot><tr><td class="nn-rpt-text">الإجمالي</td><td></td><td></td><td></td><td>' || fnum(l_t1) || '</td><td>' || fnum(l_t2)
        || '</td><td>' || fnum(l_t3) || '</td></tr></tfoot></table>'));
  END eos_liability_html;

  FUNCTION loans_report_html RETURN CLOB IS
    l_out CLOB := '<table class="nn-rpt"><thead><tr><th>السلفة</th><th>الموظف</th><th>المبلغ</th><th>القسط</th><th>المخصوم</th><th>القائم</th>'
               || '<th>الأقساط الباقية</th><th>الحالة</th></tr></thead><tbody>';
    l_n NUMBER;
  BEGIN
    FOR l IN (SELECT * FROM pay_loan WHERE company_id = company AND status_code IN ('APPROVED', 'ACTIVE') ORDER BY doc_date DESC) LOOP
      SELECT COUNT(*) INTO l_n FROM pay_loan_installment WHERE loan_id = l.id AND status_code IN ('SCHEDULED', 'DEFERRED');
      l_out := l_out || (('<tr><td>' || esc(l.doc_no) || '</td><td class="nn-rpt-text">' || esc(NOONA_HR_PKG.employment_label(l.employment_id))
            || '</td><td>' || fnum(l.principal_amount) || '</td><td>' || fnum(l.installment_amount) || '</td><td>'
            || fnum((l.principal_amount - l.outstanding_balance) * CASE WHEN l.status_code = 'ACTIVE' THEN 1 ELSE 0 END) || '</td><td>'
            || fnum(l.outstanding_balance) || '</td><td>' || l_n || '</td><td>' || status_label(l.status_code) || '</td></tr>'));
    END LOOP;
    RETURN l_out || ('</tbody></table>');
  END loans_report_html;

  FUNCTION cost_center_html(p_run_id IN NUMBER) RETURN CLOB IS
    l_r   pay_run%ROWTYPE := run_row(p_run_id);
    l_out CLOB := '<table class="nn-rpt"><thead><tr><th>مركز التكلفة</th><th>الموظفون</th><th>الإجمالي</th><th>حصة المنشأة في التأمينات</th>'
               || '<th>التكلفة على المنشأة</th></tr></thead><tbody>';
  BEGIN
    FOR x IN (SELECT CASE WHEN c.id IS NULL THEN 'غير محدد' ELSE c.code || ' - ' || c.name_ar END cc, COUNT(*) n, SUM(re.gross_amount) g,
                     SUM(re.employer_cost - re.gross_amount) er, SUM(re.employer_cost) t
                FROM pay_run_employee re JOIN hr_employment m ON m.id = re.employment_id LEFT JOIN gl_cost_center c ON c.id = m.cost_center_id
               WHERE re.run_id = l_r.id GROUP BY CASE WHEN c.id IS NULL THEN 'غير محدد' ELSE c.code || ' - ' || c.name_ar END ORDER BY 1) LOOP
      l_out := l_out || (('<tr><td class="nn-rpt-text">' || esc(x.cc) || '</td><td>' || x.n || '</td><td>' || fnum(x.g) || '</td><td>' || fnum(x.er)
            || '</td><td>' || fnum(x.t) || '</td></tr>'));
    END LOOP;
    RETURN l_out || ('</tbody></table>');
  END cost_center_html;

END NOONA_PAY_PKG;
/
