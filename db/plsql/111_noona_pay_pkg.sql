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
  FUNCTION element_amount(p_employment_id IN NUMBER, p_code IN VARCHAR2, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
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
  FUNCTION pay_run(p_run_id IN NUMBER, p_bank_account_id IN NUMBER DEFAULT NULL, p_date IN DATE DEFAULT NULL) RETURN NUMBER;
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
  BEGIN
    SELECT MAX(r.parameters) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN r.company_id = company THEN 0 WHEN r.tenant_id IS NOT NULL THEN 1 ELSE 2 END,
                                   r.effective_from DESC, r.version_no DESC)
      INTO l_p
      FROM pay_element_rule r JOIN pay_element e ON e.id = r.element_id
     WHERE e.code = p_code AND r.status_code = 'ACTIVE' AND NVL(r.employee_category, NVL(p_category, '-')) = NVL(p_category, '-')
       AND TRUNC(SYSDATE) BETWEEN r.effective_from AND NVL(r.effective_to, DATE '9999-12-31');
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

  FUNCTION ensure_periods(p_group_id IN NUMBER, p_year IN NUMBER) RETURN NUMBER IS
    l_g pay_payroll_group%ROWTYPE;
    l_n NUMBER := 0;
    l_s DATE;
  BEGIN
    SELECT * INTO l_g FROM pay_payroll_group WHERE id = p_group_id AND company_id = company;
    FOR m IN 1 .. 12 LOOP
      l_s := ADD_MONTHS(TO_DATE(p_year || '-01-01', 'YYYY-MM-DD'), m - 1);
      INSERT INTO pay_period (company_id, payroll_group_id, period_code, start_date, end_date, cutoff_date, pay_date, gl_period_id, status_code)
      SELECT company, p_group_id, TO_CHAR(l_s, 'YYYY-MM'), l_s, LAST_DAY(l_s),
             LEAST(l_s + NVL(l_g.cutoff_day, 25) - 1, LAST_DAY(l_s)), LEAST(l_s + NVL(l_g.pay_day, 27) - 1, LAST_DAY(l_s)),
             NOONA_GL_PKG.period_for(LAST_DAY(l_s)), 'OPEN'
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
  FUNCTION element_amount(p_employment_id IN NUMBER, p_code IN VARCHAR2, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(x.amount), 0) INTO l FROM pay_employee_element x JOIN pay_element e ON e.id = x.element_id
     WHERE x.employment_id = p_employment_id AND e.code = p_code
       AND p_date BETWEEN x.effective_from AND NVL(x.effective_to, DATE '9999-12-31');
    RETURN l;
  END element_amount;

  FUNCTION monthly_wage(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(x.amount), 0) INTO l FROM pay_employee_element x JOIN pay_element e ON e.id = x.element_id
     WHERE x.employment_id = p_employment_id AND e.element_type = 'EARNING' AND e.is_recurring = 'Y'
       AND p_date BETWEEN x.effective_from AND NVL(x.effective_to, DATE '9999-12-31');
    RETURN l;
  END monthly_wage;

  FUNCTION eos_wage(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(x.amount), 0) INTO l FROM pay_employee_element x JOIN pay_element e ON e.id = x.element_id
     WHERE x.employment_id = p_employment_id AND e.affects_eos = 'Y'
       AND p_date BETWEEN x.effective_from AND NVL(x.effective_to, DATE '9999-12-31');
    RETURN l;
  END eos_wage;

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
    VALUES (company, p_period_id, p_employment_id, element_id(p_element_code), p_quantity, ROUND(p_amount, 2), 'PENDING')
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
    VALUES (company, p_re, element_id(p_code), p_qty, p_rate, ROUND(p_amount, 2), p_info);
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
      -- العناصر الثابتة بالتناسب مع أيام الاستحقاق ومع تغير الراتب داخل الفترة
      FOR e IN (SELECT el.code, el.is_prorated, x.amount, GREATEST(x.effective_from, l_es) f, LEAST(NVL(x.effective_to, l_ee), l_ee) t
                  FROM pay_employee_element x JOIN pay_element el ON el.id = x.element_id
                 WHERE x.employment_id = p_m.id AND el.element_type = 'EARNING' AND el.is_recurring = 'Y'
                   AND x.effective_from <= l_ee AND NVL(x.effective_to, l_ee) >= l_es
                 ORDER BY el.sort_order, x.effective_from) LOOP
        l_amt := CASE WHEN e.is_prorated = 'Y' THEN e.amount * (e.t - e.f + 1) / l_pdays ELSE e.amount END;
        result(l_re, e.code, ROUND(c_days * (e.t - e.f + 1) / l_pdays, 2), e.amount, l_amt);
        l_gross := l_gross + ROUND(l_amt, 2);
      END LOOP;
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
        l_base := LEAST(GREATEST(l_basic + element_amount(p_m.id, 'HOUSING', l_ee), pnum(l_prm, 'min', 0)), pnum(l_prm, 'max', 1e12));
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
    l_ids   SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
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
        MERGE INTO pay_accrual a
        USING (SELECT p_p.id pid, e.employment_id eid, t.typ typ FROM dual) x
           ON (a.period_id = x.pid AND a.employment_id = x.eid AND a.accrual_type = x.typ)
         WHEN MATCHED THEN UPDATE SET a.opening_balance = l_open, a.period_amount = l_close - l_open, a.closing_balance = l_close,
                                      a.posted_at = SYSTIMESTAMP, a.posted_by = NOONA_CTX_PKG.current_user_name
         WHEN NOT MATCHED THEN INSERT (company_id, period_id, employment_id, accrual_type, opening_balance, period_amount, closing_balance,
                                       calc_info, posted_at, posted_by)
              VALUES (company, p_p.id, e.employment_id, t.typ, l_open, l_close - l_open, l_close,
                      '{"years":' || jn(NOONA_HR_PKG.service_years(e.employment_id, p_p.end_date)) || ',"wage":'
                      || jn(eos_wage(e.employment_id, p_p.end_date)) || ',"leave_days":' || jn(l_days) || '}',
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

  FUNCTION pay_run(p_run_id IN NUMBER, p_bank_account_id IN NUMBER DEFAULT NULL, p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
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
  END pay_run;

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
      l_out := l_out || (r.employee_no || ',"' || REPLACE(r.nm, '"', '') || '",' || r.national_id || ',' || r.bank || ',' || r.iban || ','
            || TO_CHAR(NVL((SELECT SUM(rr.amount) FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
                             WHERE rr.run_employee_id = r.id AND el.code = 'BASIC'), 0), 'FM9999999990.00') || ','
            || TO_CHAR(NVL((SELECT SUM(rr.amount) FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
                             WHERE rr.run_employee_id = r.id AND el.code = 'HOUSING'), 0), 'FM9999999990.00') || ','
            || TO_CHAR(r.gross_amount - NVL((SELECT SUM(rr.amount) FROM pay_run_result rr JOIN pay_element el ON el.id = rr.element_id
                             WHERE rr.run_employee_id = r.id AND el.code IN ('BASIC', 'HOUSING')), 0), 'FM9999999990.00') || ','
            || TO_CHAR(r.deduction_amount, 'FM9999999990.00') || ',' || TO_CHAR(r.net_amount, 'FM9999999990.00') || CHR(13) || CHR(10));
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
    -- لا يتجاوز القسط نصف الأجر الشهري (المادة 92)
    NOONA_CORE_PKG.assert(l_ins <= monthly_wage(p_employment_id) / 2, 'NOONA-PAY-042',
      'القسط ' || fnum(l_ins) || ' يتجاوز نصف الأجر الشهري؛ زد عدد الأقساط', 'Installment exceeds half of the monthly wage');
    SELECT * INTO l_p FROM pay_period WHERE id = NVL(p_start_period_id, period_for(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), 1))) AND company_id = company;
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
    INSERT INTO hr_end_of_service (company_id, doc_no, doc_date, employment_id, last_working_date, clearance_checklist, eos_amount,
                                   leave_encashment, deductions, net_settlement, status_code)
    VALUES (company, NOONA_REFERENCE_PKG.next_doc_no('HR_END_OF_SERVICE', company, NULL, TRUNC(SYSDATE), 'HR_END_OF_SERVICE', NULL),
            TRUNC(SYSDATE), p_employment_id, p_last_day,
            '{"type":' || jt(p_type) || ',"reason":' || jt(p_reason) || ',"years":' || jn(NOONA_HR_PKG.service_years(p_employment_id, p_last_day))
            || ',"wage":' || jn(eos_wage(p_employment_id, p_last_day)) || ',"leave_days":' || jn(l_days) || ',"open_custody":' || l_cust || '}',
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
      l_out := l_out || '<div class="nn-hr-anom"><b>تنبيهات المراجعة</b><ul>';
      FOR i IN 0 .. l_an.get_size - 1 LOOP
        l_o := TREAT(l_an.get(i) AS JSON_OBJECT_T);
        l_out := l_out || '<li class="' || CASE WHEN l_o.get_string('error') = 'Y' THEN 'is-err' END || '">' || esc(l_o.get_string('name'))
              || ': ' || esc(l_o.get_string('msg')) || '</li>';
      END LOOP;
      l_out := l_out || '</ul></div>';
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
      l_out := l_out || ('<tr' || CASE WHEN r.status_code = 'ERROR' THEN ' class="is-err"' END || '><td class="nn-rpt-text">'
            || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(NOONA_HR_PKG.employment_label(r.employment_id)) || '</a>'
                    ELSE esc(NOONA_HR_PKG.employment_label(r.employment_id)) END
            || CASE WHEN r.error_message IS NOT NULL THEN '<div class="nn-hr-err">' || esc(r.error_message) || '</div>' END
            || '</td><td>' || fnum(r.payable_days, 1) || CASE WHEN r.absence_days > 0 THEN '<small> (غياب ' || fnum(r.absence_days, 1) || ')</small>' END || '</td>');
      FOR i IN 1 .. 14 LOOP
        l_out := l_out || ('<td' || CASE WHEN i IN (8, 13) THEN ' class="nn-hr-strong"' END || '>' || CASE WHEN v(i) <> 0 THEN fnum(v(i)) END || '</td>');
        t(i) := t(i) + v(i);
      END LOOP;
      l_out := l_out || '</tr>';
    END LOOP;
    l_out := l_out || '</tbody><tfoot><tr><td class="nn-rpt-text">الإجمالي (' || NVL(l_r.employee_count, 0) || ')</td><td></td>';
    FOR i IN 1 .. 14 LOOP
      l_out := l_out || ('<td>' || fnum(t(i)) || '</td>');
    END LOOP;
    RETURN l_out || '</tr></tfoot></table></div>';
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
        l_ear := l_ear || '<tr><td class="nn-rpt-text">' || esc(x.name_ar)
              || CASE WHEN x.code = 'OVERTIME' THEN ' (' || fnum(x.quantity, 1) || ' ساعة)' END || '</td><td>' || fnum(x.amount) || '</td></tr>';
      ELSE
        l_ded := l_ded || '<tr><td class="nn-rpt-text">' || esc(x.name_ar)
              || CASE WHEN x.code = 'ABSENCE' THEN ' (' || fnum(x.quantity, 1) || ' يوم)' END || '</td><td>' || fnum(x.amount) || '</td></tr>';
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
      l_out := l_out || ('<tr><td class="nn-rpt-text">' || esc(x.name_ar) || '</td><td class="nn-rpt-text">'
            || CASE x.element_type WHEN 'EARNING' THEN 'استحقاق' WHEN 'EMPLOYER_CONTRIBUTION' THEN 'على المنشأة' ELSE 'استقطاع' END
            || '</td><td>' || x.n || '</td><td>' || fnum(x.amt) || '</td></tr>');
    END LOOP;
    RETURN l_out || '</tbody></table>';
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
      l_out := l_out || ('<tr><td class="nn-rpt-text">' || esc(NOONA_HR_PKG.employment_label(r.employment_id)) || '</td><td>' || esc(r.nationality)
            || '</td><td>' || esc(r.gosi_no) || '</td><td>' || fnum(q) || '</td><td>' || fnum(a) || '</td><td>' || fnum(b) || '</td><td>' || fnum(a + b) || '</td></tr>');
      l_ee := l_ee + a; l_er := l_er + b;
    END LOOP;
    RETURN l_out || ('</tbody><tfoot><tr><td class="nn-rpt-text">الإجمالي</td><td></td><td></td><td></td><td>' || fnum(l_ee) || '</td><td>' || fnum(l_er)
        || '</td><td>' || fnum(l_ee + l_er) || '</td></tr></tfoot></table>');
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
      l_out := l_out || ('<tr><td class="nn-rpt-text">' || esc(NOONA_HR_PKG.employment_label(m.id)) || '</td><td>' || TO_CHAR(m.start_date, 'YYYY-MM-DD')
            || '</td><td>' || fnum(NOONA_HR_PKG.service_years(m.id, p_date), 2) || '</td><td>' || fnum(eos_wage(m.id, p_date)) || '</td><td>' || fnum(a)
            || '</td><td>' || fnum(b) || '</td><td>' || fnum(c) || '</td></tr>');
      l_t1 := l_t1 + a; l_t2 := l_t2 + b; l_t3 := l_t3 + c;
    END LOOP;
    RETURN l_out || ('</tbody><tfoot><tr><td class="nn-rpt-text">الإجمالي</td><td></td><td></td><td></td><td>' || fnum(l_t1) || '</td><td>' || fnum(l_t2)
        || '</td><td>' || fnum(l_t3) || '</td></tr></tfoot></table>');
  END eos_liability_html;

  FUNCTION loans_report_html RETURN CLOB IS
    l_out CLOB := '<table class="nn-rpt"><thead><tr><th>السلفة</th><th>الموظف</th><th>المبلغ</th><th>القسط</th><th>المخصوم</th><th>القائم</th>'
               || '<th>الأقساط الباقية</th><th>الحالة</th></tr></thead><tbody>';
    l_n NUMBER;
  BEGIN
    FOR l IN (SELECT * FROM pay_loan WHERE company_id = company AND status_code IN ('APPROVED', 'ACTIVE') ORDER BY doc_date DESC) LOOP
      SELECT COUNT(*) INTO l_n FROM pay_loan_installment WHERE loan_id = l.id AND status_code IN ('SCHEDULED', 'DEFERRED');
      l_out := l_out || ('<tr><td>' || esc(l.doc_no) || '</td><td class="nn-rpt-text">' || esc(NOONA_HR_PKG.employment_label(l.employment_id))
            || '</td><td>' || fnum(l.principal_amount) || '</td><td>' || fnum(l.installment_amount) || '</td><td>'
            || fnum(l.principal_amount - l.outstanding_balance) * CASE WHEN l.status_code = 'ACTIVE' THEN 1 ELSE 0 END || '</td><td>'
            || fnum(l.outstanding_balance) || '</td><td>' || l_n || '</td><td>' || status_label(l.status_code) || '</td></tr>');
    END LOOP;
    RETURN l_out || '</tbody></table>';
  END loans_report_html;

  FUNCTION cost_center_html(p_run_id IN NUMBER) RETURN CLOB IS
    l_r   pay_run%ROWTYPE := run_row(p_run_id);
    l_out CLOB := '<table class="nn-rpt"><thead><tr><th>مركز التكلفة</th><th>الموظفون</th><th>الإجمالي</th><th>حصة المنشأة في التأمينات</th>'
               || '<th>التكلفة على المنشأة</th></tr></thead><tbody>';
  BEGIN
    FOR x IN (SELECT NVL(c.code || ' - ' || c.name_ar, 'غير محدد') cc, COUNT(*) n, SUM(re.gross_amount) g,
                     SUM(re.employer_cost - re.gross_amount) er, SUM(re.employer_cost) t
                FROM pay_run_employee re JOIN hr_employment m ON m.id = re.employment_id LEFT JOIN gl_cost_center c ON c.id = m.cost_center_id
               WHERE re.run_id = l_r.id GROUP BY NVL(c.code || ' - ' || c.name_ar, 'غير محدد') ORDER BY 1) LOOP
      l_out := l_out || ('<tr><td class="nn-rpt-text">' || esc(x.cc) || '</td><td>' || x.n || '</td><td>' || fnum(x.g) || '</td><td>' || fnum(x.er)
            || '</td><td>' || fnum(x.t) || '</td></tr>');
    END LOOP;
    RETURN l_out || '</tbody></table>';
  END cost_center_html;

END NOONA_PAY_PKG;
/
