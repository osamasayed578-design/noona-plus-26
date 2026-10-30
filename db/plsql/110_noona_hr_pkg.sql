-- =============================================================================
-- NOONA PLUS ERP | NOONA_HR_PKG - الموارد البشرية
--   * ملف الموظف: الشخص (Party) والموظف وعلاقة التوظيف والعقد وهيكل الراتب، برقم وظيفي على مستوى المؤسسة
--   * الحركات الوظيفية المؤرخة: تعيين، تعديل راتب، نقل (الإدارة، الفرع، مركز التكلفة، المسمى، المدير)
--   * الإجازات حسب نظام العمل السعودي: 21 يوماً سنوياً و30 بعد خمس سنوات، استحقاق يومي، رصيد مرحل، تداخل ممنوع
--   * الحضور اليدوي (دخول/خروج) بحساب التأخير والخروج المبكر والإضافي حسب الوردية، والغياب، وطلبات العمل الإضافي
--   * تقارير: لوحة الموارد البشرية، القوى العاملة ونسبة التوطين، أرصدة الإجازات، الحضور الشهري، الهويات المنتهية
-- الرواتب في NOONA_PAY_PKG (يقرأ الغياب والإضافي والإجازات غير المدفوعة من هنا).
-- =============================================================================
CREATE OR REPLACE PACKAGE NOONA_HR_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  FUNCTION esc(p IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION fnum(p IN NUMBER, p_dec IN PLS_INTEGER DEFAULT 2) RETURN VARCHAR2;
  PROCEDURE ensure_sequence(p_type IN VARCHAR2, p_prefix IN VARCHAR2);

  -- ---------------------------------------------------------- ملف الموظف
  -- JSON: id (علاقة التوظيف للتعديل)، name_ar, name_en, national_id, id_expiry, nationality, gender, birth_date, mobile, email,
  -- hire_date, type, job_title, unit, branch, cost_center, manager, bank, iban, gosi_no, leave_days, probation_end,
  -- contract_type, contract_end, salary:{BASIC: مبلغ, <رمز أي عنصر>: مبلغ أو {"method":"PERCENT","value":25,"basis":"BASIC"}} ؛
  -- يعيد رقم علاقة التوظيف. البدلات غير المذكورة تطبق عليها سياسة الشركة التلقائية إن وجدت.
  FUNCTION save_employee(p_doc IN CLOB) RETURN NUMBER;
  -- تعديل الراتب بحركة مؤرخة (يغلق العناصر السابقة يوم قبل السريان)
  FUNCTION change_salary(p_employment_id IN NUMBER, p_effective IN DATE, p_basic IN NUMBER, p_housing IN NUMBER,
                         p_transport IN NUMBER, p_other IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER;
  -- نقل: الإدارة والفرع ومركز التكلفة والمسمى والمدير (الفارغ لا يتغير)
  FUNCTION transfer(p_employment_id IN NUMBER, p_effective IN DATE, p_unit IN NUMBER, p_branch IN NUMBER,
                    p_cost_center IN NUMBER, p_job_title IN VARCHAR2, p_manager IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER;
  FUNCTION employee_name(p_employee_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION employment_label(p_employment_id IN NUMBER) RETURN VARCHAR2;
  -- فئة الموظف بالنسبة لدولة الشركة: مواطن أو وافد (في السعودية تسمى SAUDI / NON_SAUDI، وفي غيرها CITIZEN / EXPAT)
  FUNCTION category(p_employment_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION category_for(p_nationality IN VARCHAR2, p_country IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION is_citizen(p_category IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION category_label(p_category IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION company_country RETURN VARCHAR2;
  -- تعديل عنصر واحد من هيكل الراتب بحركة مؤرخة: p_method FIXED (مبلغ) / PERCENT (نسبة من p_basis، افتراضياً الأساسي)
  -- / POLICY (حسب سياسة الشركة) / EXCLUDED (لا يستحق رغم السياسة)
  FUNCTION set_element(p_employment_id IN NUMBER, p_code IN VARCHAR2, p_method IN VARCHAR2, p_value IN NUMBER,
                       p_basis IN VARCHAR2 DEFAULT NULL, p_effective IN DATE DEFAULT NULL, p_reason IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION service_years(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION element_id(p_code IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- الإجازات
  FUNCTION leave_type_id(p_code IN VARCHAR2) RETURN NUMBER;
  -- الرصيد المتاح في تاريخ (السنوية: المرحل + المستحق حتى التاريخ + التسويات - المستخدم - المصروف)
  FUNCTION leave_available(p_employee_id IN NUMBER, p_type_code IN VARCHAR2 DEFAULT 'ANNUAL',
                           p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  -- JSON: employee, type, start, end, start_time, end_time, reason, substitute ؛ يرسل للاعتماد مباشرة
  FUNCTION request_leave(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE approve_leave(p_id IN NUMBER);
  PROCEDURE reject_leave(p_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE cancel_leave(p_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE adjust_leave(p_employee_id IN NUMBER, p_type_code IN VARCHAR2, p_days IN NUMBER, p_reason IN VARCHAR2);
  -- أيام الإجازات غير المدفوعة المعتمدة داخل فترة (تستخدم في الرواتب)
  FUNCTION unpaid_leave_days(p_employee_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER;

  -- ---------------------------------------------------------- الحضور والإضافي
  FUNCTION record_attendance(p_employee_id IN NUMBER, p_date IN DATE, p_in IN VARCHAR2, p_out IN VARCHAR2) RETURN NUMBER;
  FUNCTION mark_absent(p_employee_id IN NUMBER, p_date IN DATE, p_note IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION absent_days(p_employee_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER;
  FUNCTION late_minutes(p_employee_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER;
  FUNCTION request_overtime(p_employee_id IN NUMBER, p_date IN DATE, p_hours IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER;
  PROCEDURE approve_overtime(p_id IN NUMBER, p_actual_hours IN NUMBER DEFAULT NULL);
  PROCEDURE reject_overtime(p_id IN NUMBER);
  FUNCTION overtime_hours(p_employee_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER;

  -- ---------------------------------------------------------- التقارير
  FUNCTION hr_summary RETURN CLOB;
  FUNCTION employee_card(p_employment_id IN NUMBER) RETURN CLOB;
  FUNCTION headcount_report RETURN CLOB;
  FUNCTION leave_balances_report(p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN CLOB;
  FUNCTION attendance_report(p_month IN DATE) RETURN CLOB;
  FUNCTION expiring_report(p_days IN NUMBER DEFAULT 60) RETURN CLOB;
END NOONA_HR_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_HR_PKG AS

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p IN VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END jt;

  FUNCTION fnum(p IN NUMBER, p_dec IN PLS_INTEGER DEFAULT 2) RETURN VARCHAR2 IS
  BEGIN
    IF p IS NULL THEN RETURN NULL; END IF;
    RETURN TO_CHAR(ROUND(p, p_dec), 'FM999G999G999G990' || CASE WHEN p_dec > 0 THEN 'D' || RPAD('0', p_dec, '0') END,
                   'NLS_NUMERIC_CHARACTERS=''.,''');
  END fnum;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  PROCEDURE ensure_sequence(p_type IN VARCHAR2, p_prefix IN VARCHAR2) IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
  END ensure_sequence;

  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'ACTIVE' THEN 'على رأس العمل' WHEN 'ON_LEAVE' THEN 'في إجازة' WHEN 'SUSPENDED' THEN 'موقوف'
      WHEN 'NOTICE_PERIOD' THEN 'فترة إشعار' WHEN 'TERMINATED' THEN 'منتهية خدمته' WHEN 'PENDING' THEN 'بانتظار المباشرة'
      WHEN 'SUBMITTED' THEN 'بانتظار الاعتماد' WHEN 'APPROVED' THEN 'معتمد' WHEN 'REJECTED' THEN 'مرفوض'
      WHEN 'CANCELLED' THEN 'ملغى' WHEN 'TAKEN' THEN 'مستخدمة' WHEN 'DRAFT' THEN 'مسودة' WHEN 'PAID' THEN 'مصروف'
      ELSE p_status END;
  END status_label;

  FUNCTION employee_name(p_employee_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(300);
  BEGIN
    SELECT MAX(p.display_name_ar) INTO l FROM hr_employee e JOIN pty_party p ON p.id = e.person_party_id WHERE e.id = p_employee_id;
    RETURN l;
  END employee_name;

  FUNCTION employment_label(p_employment_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(e.employee_no || ' - ' || p.display_name_ar) INTO l
      FROM hr_employment m JOIN hr_employee e ON e.id = m.employee_id JOIN pty_party p ON p.id = e.person_party_id
     WHERE m.id = p_employment_id;
    RETURN l;
  END employment_label;

  FUNCTION company_country RETURN VARCHAR2 IS
    l VARCHAR2(2);
  BEGIN
    SELECT MAX(country_code) INTO l FROM org_company WHERE id = company;
    RETURN NVL(l, 'SA');
  END company_country;

  FUNCTION category_for(p_nationality IN VARCHAR2, p_country IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    l_c VARCHAR2(2) := NVL(p_country, company_country);
  BEGIN
    RETURN CASE WHEN NVL(p_nationality, l_c) = l_c THEN CASE WHEN l_c = 'SA' THEN 'SAUDI' ELSE 'CITIZEN' END
                ELSE CASE WHEN l_c = 'SA' THEN 'NON_SAUDI' ELSE 'EXPAT' END END;
  END category_for;

  FUNCTION is_citizen(p_category IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN NVL(p_category, 'CITIZEN') IN ('SAUDI', 'CITIZEN') THEN 'Y' ELSE 'N' END;
  END is_citizen;

  FUNCTION category_label(p_category IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_category WHEN 'SAUDI' THEN 'سعودي' WHEN 'NON_SAUDI' THEN 'غير سعودي' WHEN 'CITIZEN' THEN 'مواطن' WHEN 'EXPAT' THEN 'وافد'
                ELSE 'الكل' END;
  END category_label;

  FUNCTION category(p_employment_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(NVL(m.employee_category, category_for(e.nationality, c.country_code))) INTO l
      FROM hr_employment m JOIN hr_employee e ON e.id = m.employee_id JOIN org_company c ON c.id = m.company_id WHERE m.id = p_employment_id;
    RETURN l;
  END category;

  FUNCTION service_years(p_employment_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l_start DATE;
  BEGIN
    SELECT MAX(start_date) INTO l_start FROM hr_employment WHERE id = p_employment_id;
    RETURN GREATEST(0, (p_date - l_start + 1) / 365);
  END service_years;

  FUNCTION emp_row(p_id NUMBER) RETURN hr_employment%ROWTYPE IS
    l hr_employment%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM hr_employment WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HR-001', 'الموظف غير موجود في الشركة الحالية', 'Employment not found');
  END emp_row;

  FUNCTION employment_of(p_employee_id NUMBER) RETURN hr_employment%ROWTYPE IS
    l hr_employment%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM (SELECT * FROM hr_employment WHERE employee_id = p_employee_id AND company_id = company
                           ORDER BY CASE WHEN status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED') THEN 0 ELSE 1 END, start_date DESC)
     WHERE ROWNUM = 1;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HR-001', 'الموظف غير موجود في الشركة الحالية', 'Employment not found');
  END employment_of;

  FUNCTION element_id(p_code IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) INTO l
      FROM pay_element WHERE code = p_code AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-HR-002', 'عنصر الراتب غير معرف: ' || p_code, 'Unknown pay element');
    RETURN l;
  END element_id;

  PROCEDURE action(p_employment NUMBER, p_type VARCHAR2, p_date DATE, p_old VARCHAR2, p_new VARCHAR2, p_reason VARCHAR2,
                   p_id OUT NUMBER) IS
  BEGIN
    ensure_sequence('HR_EMPLOYEE_ACTION', 'HA-');
    INSERT INTO hr_employee_action (doc_no, doc_date, employment_id, action_type, effective_date, old_values, new_values, reason, status_code)
    VALUES (NOONA_REFERENCE_PKG.next_doc_no('HR_EMPLOYEE_ACTION', company, NULL, TRUNC(SYSDATE), 'HR_EMPLOYEE_ACTION', NULL),
            TRUNC(SYSDATE), p_employment, p_type, p_date, p_old, NVL(p_new, '{}'), SUBSTR(p_reason, 1, 1000), 'EFFECTIVE')
    RETURNING id INTO p_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HR_EMPLOYEE_ACTION', p_id, p_type, 'SUCCESS', p_new_values => p_new);
  END action;

  FUNCTION salary_json(p_employment NUMBER, p_date DATE) RETURN VARCHAR2 IS
    l VARCHAR2(4000) := '{';
  BEGIN
    FOR r IN (SELECT e.code, MAX(x.calc_method) m, SUM(x.amount) amt, MAX(x.percentage) pct, MAX(x.basis_code) basis
                FROM pay_employee_element x JOIN pay_element e ON e.id = x.element_id
               WHERE x.employment_id = p_employment AND p_date BETWEEN x.effective_from AND NVL(x.effective_to, DATE '9999-12-31')
               GROUP BY e.code ORDER BY MIN(e.sort_order)) LOOP
      l := l || CASE WHEN l <> '{' THEN ',' END || jt(r.code) || ':'
        || CASE NVL(r.m, 'FIXED') WHEN 'FIXED' THEN TO_CHAR(r.amt, 'FM9999999990.00', 'NLS_NUMERIC_CHARACTERS=''.,''')
                WHEN 'PERCENT' THEN '{"pct":' || TO_CHAR(r.pct, 'FM9990.99', 'NLS_NUMERIC_CHARACTERS=''.,''') || ',"of":' || jt(r.basis) || '}'
                ELSE jt(r.m) END;
    END LOOP;
    RETURN l || '}';
  END salary_json;

  PROCEDURE set_salary(p_employment NUMBER, p_from DATE, p_code VARCHAR2, p_amount NUMBER) IS
  BEGIN
    IF NVL(p_amount, 0) = 0 THEN RETURN; END IF;
    NOONA_CORE_PKG.assert(p_amount > 0, 'NOONA-HR-003', 'مبالغ الراتب والبدلات يجب أن تكون موجبة', 'Salary amounts must be positive');
    INSERT INTO pay_employee_element (employment_id, element_id, amount, calc_method, effective_from)
    VALUES (p_employment, element_id(p_code), ROUND(p_amount, 2), 'FIXED', p_from);
  END set_salary;

  PROCEDURE put_element(p_employment NUMBER, p_from DATE, p_code VARCHAR2, p_method VARCHAR2, p_value NUMBER, p_basis VARCHAR2) IS
    l_basis VARCHAR2(50) := CASE WHEN p_method = 'PERCENT' THEN NVL(p_basis, 'BASIC') END;
    l_n     NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(p_method IN ('FIXED', 'PERCENT', 'POLICY', 'EXCLUDED'), 'NOONA-HR-030', 'طريقة احتساب غير صالحة', 'Invalid method');
    NOONA_CORE_PKG.assert(p_method NOT IN ('FIXED', 'PERCENT') OR NVL(p_value, 0) > 0, 'NOONA-HR-031',
      'أدخل المبلغ أو النسبة (قيمة موجبة)', 'Amount or percentage must be positive');
    NOONA_CORE_PKG.assert(p_method <> 'PERCENT' OR p_value <= 1000, 'NOONA-HR-032', 'النسبة غير منطقية', 'Percentage too high');
    NOONA_CORE_PKG.assert(p_code <> 'BASIC' OR p_method = 'FIXED', 'NOONA-HR-034', 'الراتب الأساسي مبلغ ثابت', 'Basic salary must be a fixed amount');
    NOONA_CORE_PKG.assert(p_method <> 'PERCENT' OR l_basis <> p_code, 'NOONA-HR-033', 'لا يحسب العنصر نسبة من نفسه',
      'An element cannot be a percentage of itself');
    IF l_basis IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM pay_element WHERE code = l_basis AND is_active = 'Y';
      NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-HR-035', 'العنصر الأساس للنسبة غير معرف: ' || l_basis, 'Unknown basis element');
    END IF;
    INSERT INTO pay_employee_element (employment_id, element_id, amount, percentage, calc_method, basis_code, effective_from)
    VALUES (p_employment, element_id(p_code), CASE WHEN p_method = 'FIXED' THEN ROUND(p_value, 2) END,
            CASE WHEN p_method = 'PERCENT' THEN p_value END, p_method, l_basis, p_from);
  END put_element;

  FUNCTION num(p_o JSON_OBJECT_T, p_key VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_key) AND NOT p_o.get(p_key).is_null THEN p_o.get_number(p_key) END;
  END num;
  FUNCTION str(p_o JSON_OBJECT_T, p_key VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_key) AND NOT p_o.get(p_key).is_null THEN TRIM(p_o.get_string(p_key)) END;
  END str;
  FUNCTION dat(p_o JSON_OBJECT_T, p_key VARCHAR2) RETURN DATE IS
  BEGIN
    RETURN TO_DATE(str(p_o, p_key), 'YYYY-MM-DD');
  END dat;

  -- ================================================================ ملف الموظف
  FUNCTION save_employee(p_doc IN CLOB) RETURN NUMBER IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_sal    JSON_OBJECT_T;
    l_id     NUMBER := num(l_o, 'id');
    l_name   VARCHAR2(300) := str(l_o, 'name_ar');
    l_cc     VARCHAR2(2) := company_country;
    l_nat    VARCHAR2(2) := UPPER(NVL(str(l_o, 'nationality'), l_cc));
    l_hire   DATE := NVL(dat(l_o, 'hire_date'), TRUNC(SYSDATE));
    l_nid    VARCHAR2(30) := REPLACE(str(l_o, 'national_id'), ' ');
    l_iban   VARCHAR2(34) := UPPER(REPLACE(str(l_o, 'iban'), ' '));
    l_party  NUMBER;
    l_emp    NUMBER;
    l_no     VARCHAR2(50);
    l_n      NUMBER;
    l_act    NUMBER;
    l_cat    VARCHAR2(30);
    l_m      hr_employment%ROWTYPE;
    l_days   NUMBER := NVL(num(l_o, 'leave_days'), 21);
    v_name_en VARCHAR2(300) := str(l_o, 'name_en');
    v_gender  VARCHAR2(1) := str(l_o, 'gender');
    v_birth   DATE := dat(l_o, 'birth_date');
    v_email   VARCHAR2(320) := str(l_o, 'email');
    v_mobile  VARCHAR2(40) := str(l_o, 'mobile');
    v_idexp   DATE := dat(l_o, 'id_expiry');
    v_branch  NUMBER := num(l_o, 'branch');
    v_type    VARCHAR2(30) := str(l_o, 'type');
    v_prob    DATE := dat(l_o, 'probation_end');
    v_mgr     NUMBER := num(l_o, 'manager');
    v_gosi    VARCHAR2(50) := str(l_o, 'gosi_no');
    v_job     VARCHAR2(200) := str(l_o, 'job_title');
    v_unit    NUMBER := num(l_o, 'unit');
    v_cc      NUMBER := num(l_o, 'cost_center');
    v_bank    NUMBER := num(l_o, 'bank');
    v_ctype   VARCHAR2(30) := str(l_o, 'contract_type');
    v_cend    DATE := dat(l_o, 'contract_end');
    v_basic   NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'HR_EMPLOYEE.CREATE' ELSE 'HR_EMPLOYEE.UPDATE' END);
    NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-HR-010', 'اسم الموظف إلزامي', 'Employee name is required');
    NOONA_CORE_PKG.assert(l_nid IS NULL OR l_nat <> 'SA' OR l_cc <> 'SA' OR REGEXP_LIKE(l_nid, '^1[0-9]{9}$'), 'NOONA-HR-011',
      'رقم الهوية الوطنية 10 أرقام يبدأ بالرقم 1', 'Saudi national ID must be 10 digits starting with 1');
    NOONA_CORE_PKG.assert(l_nid IS NULL OR l_nat = 'SA' OR l_cc <> 'SA' OR REGEXP_LIKE(l_nid, '^2[0-9]{9}$'), 'NOONA-HR-012',
      'رقم الإقامة 10 أرقام يبدأ بالرقم 2', 'Iqama number must be 10 digits starting with 2');
    NOONA_CORE_PKG.assert(l_iban IS NULL OR (l_cc = 'SA' AND REGEXP_LIKE(l_iban, '^SA[0-9]{22}$'))
                          OR (l_cc <> 'SA' AND REGEXP_LIKE(l_iban, '^[A-Z]{2}[0-9]{2}[A-Z0-9]{10,30}$')), 'NOONA-HR-013',
      CASE WHEN l_cc = 'SA' THEN 'الآيبان السعودي 24 خانة يبدأ بـ SA' ELSE 'رقم الآيبان غير صحيح' END, 'Invalid IBAN');
    -- الحد الأدنى للإجازة السنوية حسب نظام العمل: 21 يوماً في السعودية؛ غيرها حسب ما تحدده الشركة
    NOONA_CORE_PKG.assert(l_days BETWEEN CASE WHEN l_cc = 'SA' THEN 21 ELSE 0 END AND 60, 'NOONA-HR-014',
      'الإجازة السنوية لا تقل عن 21 يوماً', 'Annual leave must be at least 21 days');
    l_cat := category_for(l_nat, l_cc);
    IF l_nid IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM hr_employee e
       WHERE e.national_id = l_nid
         AND (l_id IS NULL OR e.id <> (SELECT m.employee_id FROM hr_employment m WHERE m.id = l_id));
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HR-015', 'رقم الهوية مسجل لموظف آخر', 'National ID already registered');
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO pty_party (party_no, party_type, display_name_ar, display_name_en, ownership_scope, owner_company_id, country_code, status_code)
      VALUES ('NEW-' || RAWTOHEX(SYS_GUID()), 'PERSON', l_name, v_name_en, 'TENANT_SHARED', company, l_nat, 'ACTIVE')
      RETURNING id INTO l_party;
      UPDATE pty_party SET party_no = 'P-' || LPAD(l_party, 6, '0') WHERE id = l_party;
      INSERT INTO pty_person (party_id, first_name_ar, gender, birth_date, nationality)
      VALUES (l_party, l_name, v_gender, v_birth, l_nat);
      SELECT NVL(MAX(TO_NUMBER(SUBSTR(employee_no, 2))), 1000) + 1 INTO l_n FROM hr_employee WHERE REGEXP_LIKE(employee_no, '^E[0-9]{4,6}$');
      l_no := 'E' || l_n;
      INSERT INTO hr_employee (person_party_id, employee_no, original_hire_date, work_email, work_mobile, national_id, id_expiry_date,
                               nationality, gender, birth_date, status_code)
      VALUES (l_party, l_no, l_hire, v_email, v_mobile, l_nid, v_idexp, l_nat, v_gender,
              v_birth, 'ACTIVE')
      RETURNING id INTO l_emp;
      INSERT INTO hr_employment (employee_id, company_id, branch_id, employment_type, employee_category, start_date, probation_end_date,
                                 manager_employee_id, gosi_no, job_title, org_unit_id, cost_center_id, bank_id, iban, annual_leave_days,
                                 status_code)
      VALUES (l_emp, company, NVL(v_branch, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID'))), NVL(v_type, 'PERMANENT'),
              l_cat, l_hire, NVL(v_prob, l_hire + 89), v_mgr, v_gosi, v_job,
              v_unit, v_cc, v_bank, l_iban, l_days, 'ACTIVE')
      RETURNING id INTO l_id;
      l_sal := l_o.get_object('salary');
      v_basic := CASE WHEN l_sal IS NOT NULL THEN num(l_sal, 'BASIC') END;
      NOONA_CORE_PKG.assert(NVL(v_basic, 0) > 0, 'NOONA-HR-016', 'الراتب الأساسي إلزامي', 'Basic salary is required');
      -- أي عنصر: رقم = مبلغ ثابت، أو كائن {"method":"PERCENT|POLICY|EXCLUDED","value":..,"basis":..}
      DECLARE
        l_keys JSON_KEY_LIST := l_sal.get_keys;
        l_v    JSON_ELEMENT_T;
        l_eo   JSON_OBJECT_T;
      BEGIN
        FOR i IN 1 .. l_keys.COUNT LOOP
          l_v := l_sal.get(l_keys(i));
          IF l_v.is_null THEN NULL;
          ELSIF l_v.is_object THEN
            l_eo := TREAT(l_v AS JSON_OBJECT_T);
            put_element(l_id, l_hire, UPPER(l_keys(i)), UPPER(NVL(str(l_eo, 'method'), 'FIXED')), num(l_eo, 'value'), UPPER(str(l_eo, 'basis')));
          ELSE
            set_salary(l_id, l_hire, UPPER(l_keys(i)), l_sal.get_number(l_keys(i)));
          END IF;
        END LOOP;
      END;
      INSERT INTO hr_contract (employment_id, contract_no, version_no, contract_type, start_date, end_date, working_hours_week, basic_salary,
                               annual_leave_days, notice_days, currency_code, status_code)
      VALUES (l_id, 'C-' || l_no, 1, NVL(v_ctype, CASE WHEN is_citizen(l_cat) = 'Y' THEN 'UNLIMITED' ELSE 'FIXED_TERM' END),
              l_hire, v_cend, 48, v_basic, l_days, 60, NOONA_GL_PKG.ledger_currency, 'ACTIVE');
      action(l_id, 'HIRE', l_hire, NULL, '{"employee_no":' || jt(l_no) || ',"salary":' || salary_json(l_id, l_hire) || '}',
             'تعيين', l_act);
    ELSE
      l_m := emp_row(l_id);
      SELECT person_party_id INTO l_party FROM hr_employee WHERE id = l_m.employee_id;
      UPDATE pty_party SET display_name_ar = l_name, display_name_en = v_name_en, country_code = l_nat WHERE id = l_party;
      UPDATE pty_person SET first_name_ar = l_name, gender = v_gender, birth_date = v_birth, nationality = l_nat
       WHERE party_id = l_party;
      UPDATE hr_employee SET work_email = v_email, work_mobile = v_mobile, national_id = l_nid,
                             id_expiry_date = v_idexp, nationality = l_nat, gender = v_gender,
                             birth_date = v_birth
       WHERE id = l_m.employee_id;
      -- المسمى والإدارة والمدير والفرع ومركز التكلفة تتغير بحركة نقل؛ هنا بيانات الملف فقط
      UPDATE hr_employment SET employee_category = l_cat, gosi_no = v_gosi, bank_id = v_bank, iban = l_iban,
                               annual_leave_days = l_days, employment_type = NVL(v_type, employment_type),
                               probation_end_date = NVL(v_prob, probation_end_date)
       WHERE id = l_id;
      NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HR_EMPLOYMENT', l_id, 'UPDATE', 'SUCCESS');
    END IF;
    -- رصيد الإجازة السنوية للسنة الحالية
    MERGE INTO hr_leave_balance b
    USING (SELECT l_m.employee_id e FROM dual WHERE l_m.employee_id IS NOT NULL
           UNION ALL SELECT l_emp FROM dual WHERE l_emp IS NOT NULL) x
       ON (b.employee_id = x.e AND b.leave_type_id = leave_type_id('ANNUAL') AND b.balance_year = EXTRACT(YEAR FROM SYSDATE))
     WHEN NOT MATCHED THEN INSERT (employee_id, leave_type_id, balance_year, opening_balance, accrued, taken, adjusted, encashed)
          VALUES (x.e, leave_type_id('ANNUAL'), EXTRACT(YEAR FROM SYSDATE), 0, 0, 0, 0, 0);
    RETURN l_id;
  END save_employee;

  FUNCTION change_salary(p_employment_id IN NUMBER, p_effective IN DATE, p_basic IN NUMBER, p_housing IN NUMBER,
                         p_transport IN NUMBER, p_other IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_m   hr_employment%ROWTYPE := emp_row(p_employment_id);
    l_old VARCHAR2(4000);
    l_act NUMBER;
    l_eff DATE := NVL(TRUNC(p_effective), TRUNC(SYSDATE));
    l_n   NUMBER;
  BEGIN
    guard('HR_EMPLOYEE_ACTION.CREATE');
    NOONA_CORE_PKG.assert(l_m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED'), 'NOONA-HR-020', 'الموظف ليس على رأس العمل',
      'Employee is not active');
    NOONA_CORE_PKG.assert(NVL(p_basic, 0) > 0, 'NOONA-HR-016', 'الراتب الأساسي إلزامي', 'Basic salary is required');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-HR-021', 'سبب تعديل الراتب إلزامي', 'Reason is required');
    NOONA_CORE_PKG.assert(l_eff >= l_m.start_date, 'NOONA-HR-022', 'تاريخ السريان يسبق تاريخ التعيين', 'Effective date precedes hire date');
    -- لا يعدل راتب فترة رحلت رواتبها
    SELECT COUNT(*) INTO l_n FROM pay_run_employee re JOIN pay_run r ON r.id = re.run_id JOIN pay_period p ON p.id = r.period_id
     WHERE re.employment_id = p_employment_id AND r.status_code IN ('POSTED', 'PAID', 'CLOSED') AND p.end_date >= l_eff;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HR-023', 'توجد رواتب مرحلة بعد تاريخ السريان؛ اجعل السريان من الفترة التالية',
      'Payroll already posted after the effective date');
    l_old := salary_json(p_employment_id, l_eff);
    -- العناصر الأربعة فقط (البدلات الأخرى ونسبها تعدل من هيكل الراتب ولا تمس هنا)
    DELETE FROM pay_employee_element
     WHERE employment_id = p_employment_id AND effective_from >= l_eff
       AND element_id IN (SELECT id FROM pay_element WHERE code IN ('BASIC', 'HOUSING', 'TRANSPORT', 'OTHER_ALLOW'));
    UPDATE pay_employee_element SET effective_to = l_eff - 1
     WHERE employment_id = p_employment_id AND (effective_to IS NULL OR effective_to >= l_eff)
       AND element_id IN (SELECT id FROM pay_element WHERE code IN ('BASIC', 'HOUSING', 'TRANSPORT', 'OTHER_ALLOW'));
    set_salary(p_employment_id, l_eff, 'BASIC', p_basic);
    set_salary(p_employment_id, l_eff, 'HOUSING', p_housing);
    set_salary(p_employment_id, l_eff, 'TRANSPORT', p_transport);
    set_salary(p_employment_id, l_eff, 'OTHER_ALLOW', p_other);
    UPDATE hr_contract SET basic_salary = p_basic WHERE employment_id = p_employment_id AND status_code = 'ACTIVE';
    action(p_employment_id, 'SALARY_CHANGE', l_eff, l_old, salary_json(p_employment_id, l_eff), p_reason, l_act);
    RETURN l_act;
  END change_salary;

  FUNCTION set_element(p_employment_id IN NUMBER, p_code IN VARCHAR2, p_method IN VARCHAR2, p_value IN NUMBER,
                       p_basis IN VARCHAR2 DEFAULT NULL, p_effective IN DATE DEFAULT NULL, p_reason IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_m    hr_employment%ROWTYPE := emp_row(p_employment_id);
    l_eff  DATE := NVL(TRUNC(p_effective), GREATEST(TRUNC(SYSDATE), l_m.start_date));
    l_code VARCHAR2(50) := UPPER(TRIM(p_code));
    l_old  VARCHAR2(4000);
    l_eid  NUMBER;
    l_sp   BOOLEAN := FALSE;
    l_act  NUMBER;
    l_n    NUMBER;
  BEGIN
    guard('HR_EMPLOYEE_ACTION.CREATE');
    NOONA_CORE_PKG.assert(l_m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED'), 'NOONA-HR-020', 'الموظف ليس على رأس العمل',
      'Employee is not active');
    NOONA_CORE_PKG.assert(l_eff >= l_m.start_date, 'NOONA-HR-022', 'تاريخ السريان يسبق تاريخ التعيين', 'Effective date precedes hire date');
    SELECT COUNT(*) INTO l_n FROM pay_run_employee re JOIN pay_run r ON r.id = re.run_id JOIN pay_period p ON p.id = r.period_id
     WHERE re.employment_id = p_employment_id AND r.status_code IN ('POSTED', 'PAID', 'CLOSED') AND p.end_date >= l_eff;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HR-023', 'توجد رواتب مرحلة بعد تاريخ السريان؛ اجعل السريان من الفترة التالية',
      'Payroll already posted after the effective date');
    l_eid := element_id(l_code);
    l_old := salary_json(p_employment_id, l_eff);
    SAVEPOINT hr_set_element;                                     -- رفض القيمة لا يترك العنصر محذوفاً
    l_sp := TRUE;
    DELETE FROM pay_employee_element WHERE employment_id = p_employment_id AND element_id = l_eid AND effective_from >= l_eff;
    UPDATE pay_employee_element SET effective_to = l_eff - 1
     WHERE employment_id = p_employment_id AND element_id = l_eid AND (effective_to IS NULL OR effective_to >= l_eff);
    put_element(p_employment_id, l_eff, l_code, UPPER(p_method), p_value, UPPER(TRIM(p_basis)));
    IF l_code = 'BASIC' THEN
      UPDATE hr_contract SET basic_salary = p_value WHERE employment_id = p_employment_id AND status_code = 'ACTIVE';
    END IF;
    action(p_employment_id, 'SALARY_CHANGE', l_eff, l_old, salary_json(p_employment_id, l_eff), NVL(p_reason, 'تعديل ' || l_code), l_act);
    RETURN l_act;
  EXCEPTION WHEN OTHERS THEN
    IF l_sp THEN ROLLBACK TO hr_set_element; END IF;
    RAISE;
  END set_element;

  FUNCTION transfer(p_employment_id IN NUMBER, p_effective IN DATE, p_unit IN NUMBER, p_branch IN NUMBER,
                    p_cost_center IN NUMBER, p_job_title IN VARCHAR2, p_manager IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_m   hr_employment%ROWTYPE := emp_row(p_employment_id);
    l_act NUMBER;
  BEGIN
    guard('HR_EMPLOYEE_ACTION.CREATE');
    NOONA_CORE_PKG.assert(p_manager IS NULL OR p_manager <> l_m.employee_id, 'NOONA-HR-024', 'لا يكون الموظف مديراً لنفسه',
      'An employee cannot manage himself');
    UPDATE hr_employment SET org_unit_id = NVL(p_unit, org_unit_id), branch_id = NVL(p_branch, branch_id),
                             cost_center_id = NVL(p_cost_center, cost_center_id), job_title = NVL(TRIM(p_job_title), job_title),
                             manager_employee_id = NVL(p_manager, manager_employee_id)
     WHERE id = p_employment_id;
    action(p_employment_id, CASE WHEN p_job_title IS NOT NULL AND p_unit IS NULL AND p_branch IS NULL THEN 'POSITION_CHANGE' ELSE 'TRANSFER' END,
           NVL(p_effective, TRUNC(SYSDATE)),
           '{"unit":' || NVL(TO_CHAR(l_m.org_unit_id), 'null') || ',"branch":' || NVL(TO_CHAR(l_m.branch_id), 'null')
             || ',"cost_center":' || NVL(TO_CHAR(l_m.cost_center_id), 'null') || ',"job_title":' || jt(l_m.job_title)
             || ',"manager":' || NVL(TO_CHAR(l_m.manager_employee_id), 'null') || '}',
           '{"unit":' || NVL(TO_CHAR(p_unit), 'null') || ',"branch":' || NVL(TO_CHAR(p_branch), 'null')
             || ',"cost_center":' || NVL(TO_CHAR(p_cost_center), 'null') || ',"job_title":' || jt(p_job_title)
             || ',"manager":' || NVL(TO_CHAR(p_manager), 'null') || '}', p_reason, l_act);
    RETURN l_act;
  END transfer;

  -- ================================================================ الإجازات
  FUNCTION leave_type_id(p_code IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) INTO l
      FROM hr_leave_type WHERE code = p_code AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-HR-030', 'نوع الإجازة غير معرف: ' || p_code, 'Unknown leave type');
    RETURN l;
  END leave_type_id;

  FUNCTION annual_days(p_m hr_employment%ROWTYPE, p_date DATE) RETURN NUMBER IS
  BEGIN
    -- 21 يوماً، و30 يوماً متى أكمل خمس سنوات (المادة 109)
    RETURN CASE WHEN (p_date - p_m.start_date) / 365 >= 5 THEN GREATEST(30, NVL(p_m.annual_leave_days, 21))
                ELSE NVL(p_m.annual_leave_days, 21) END;
  END annual_days;

  FUNCTION leave_available(p_employee_id IN NUMBER, p_type_code IN VARCHAR2 DEFAULT 'ANNUAL',
                           p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l_m     hr_employment%ROWTYPE;
    l_b     hr_leave_balance%ROWTYPE;
    l_y0    DATE := TRUNC(p_date, 'YYYY');
    l_acc   NUMBER;
    l_taken NUMBER;
    l_max   NUMBER;
  BEGIN
    SELECT * INTO l_m FROM (SELECT * FROM hr_employment WHERE employee_id = p_employee_id
                             ORDER BY CASE WHEN status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED') THEN 0 ELSE 1 END, start_date DESC)
     WHERE ROWNUM = 1;
    IF p_type_code = 'ANNUAL' THEN
      BEGIN
        SELECT * INTO l_b FROM hr_leave_balance
         WHERE employee_id = p_employee_id AND leave_type_id = leave_type_id('ANNUAL') AND balance_year = EXTRACT(YEAR FROM p_date);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_b.opening_balance := 0; l_b.adjusted := 0; l_b.taken := 0; l_b.encashed := 0;
      END;
      l_acc := annual_days(l_m, p_date) * GREATEST(0, p_date - GREATEST(l_y0, l_m.start_date) + 1) / 365;
      RETURN ROUND(l_b.opening_balance + l_acc + l_b.adjusted - l_b.taken - l_b.encashed, 2);
    END IF;
    -- الأنواع الأخرى: الحد السنوي ناقص المعتمد في السنة
    SELECT MAX(max_per_year) INTO l_max FROM hr_leave_type WHERE id = leave_type_id(p_type_code);
    IF l_max IS NULL THEN RETURN NULL; END IF;
    SELECT NVL(SUM(duration), 0) INTO l_taken FROM hr_leave_request
     WHERE employee_id = p_employee_id AND leave_type_id = leave_type_id(p_type_code)
       AND status_code IN ('SUBMITTED', 'APPROVED', 'TAKEN') AND start_date >= l_y0 AND start_date < ADD_MONTHS(l_y0, 12);
    RETURN l_max - l_taken;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN 0;
  END leave_available;

  FUNCTION request_leave(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_emp  NUMBER := num(l_o, 'employee');
    l_code VARCHAR2(50) := NVL(str(l_o, 'type'), 'ANNUAL');
    l_from DATE := dat(l_o, 'start');
    l_to   DATE := NVL(dat(l_o, 'end'), dat(l_o, 'start'));
    l_type hr_leave_type%ROWTYPE;
    l_m    hr_employment%ROWTYPE;
    l_dur  NUMBER;
    l_n    NUMBER;
    l_av   NUMBER;
    l_id   NUMBER;
    l_t1   VARCHAR2(100) := str(l_o, 'start_time');
    l_t2   VARCHAR2(100) := str(l_o, 'end_time');
    l_sub  NUMBER := num(l_o, 'substitute');
    l_why  VARCHAR2(1000) := SUBSTR(str(l_o, 'reason'), 1, 1000);
  BEGIN
    NOONA_CORE_PKG.assert((l_t1 IS NULL OR REGEXP_LIKE(l_t1, '^([01]?\d|2[0-3]):[0-5]\d$'))
      AND (l_t2 IS NULL OR REGEXP_LIKE(l_t2, '^([01]?\d|2[0-3]):[0-5]\d$')), 'NOONA-HR-050', 'الوقت بصيغة HH:MI', 'Time must be HH:MI');
    l_t1 := LPAD(l_t1, 5, '0'); l_t2 := LPAD(l_t2, 5, '0');
    guard('HR_LEAVE_REQUEST.CREATE');
    l_m := employment_of(l_emp);
    SELECT * INTO l_type FROM hr_leave_type WHERE id = leave_type_id(l_code);
    NOONA_CORE_PKG.assert(l_from IS NOT NULL AND l_to >= l_from, 'NOONA-HR-031', 'تاريخ النهاية يسبق تاريخ البداية',
      'End date precedes start date');
    NOONA_CORE_PKG.assert(l_m.status_code IN ('ACTIVE', 'NOTICE_PERIOD'), 'NOONA-HR-020', 'الموظف ليس على رأس العمل', 'Employee is not active');
    NOONA_CORE_PKG.assert(l_from >= l_m.start_date, 'NOONA-HR-032', 'الإجازة تسبق تاريخ التعيين', 'Leave precedes hire date');
    IF l_type.unit_code = 'HOUR' THEN
      NOONA_CORE_PKG.assert(l_t1 IS NOT NULL AND l_t2 IS NOT NULL AND l_t2 > l_t1 AND l_to = l_from, 'NOONA-HR-033',
        'الاستئذان في يوم واحد بساعة بداية ونهاية', 'Permission needs one day with start and end time');
      l_dur := ROUND((TO_DATE(l_t2, 'HH24:MI') - TO_DATE(l_t1, 'HH24:MI')) * 24, 2);
    ELSE
      l_dur := l_to - l_from + 1;
      SELECT COUNT(*) INTO l_n FROM hr_leave_request r JOIN hr_leave_type t ON t.id = r.leave_type_id
       WHERE r.employee_id = l_emp AND r.status_code IN ('SUBMITTED', 'APPROVED', 'TAKEN') AND t.unit_code = 'DAY'
         AND r.start_date <= l_to AND r.end_date >= l_from;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HR-034', 'توجد إجازة أخرى في نفس الفترة', 'Overlapping leave request');
    END IF;
    l_av := leave_available(l_emp, l_code, l_to);
    NOONA_CORE_PKG.assert(l_av IS NULL OR l_dur <= l_av, 'NOONA-HR-035',
      'الرصيد المتاح ' || fnum(l_av, 1) || ' ' || CASE l_type.unit_code WHEN 'HOUR' THEN 'ساعة' ELSE 'يوم' END
      || ' أقل من المطلوب ' || fnum(l_dur, 1), 'Insufficient leave balance');
    ensure_sequence('HR_LEAVE_REQUEST', 'LV-');
    INSERT INTO hr_leave_request (doc_no, doc_date, employee_id, leave_type_id, start_date, end_date, start_time, end_time, duration,
                                  substitute_employee_id, reason, status_code)
    VALUES (NOONA_REFERENCE_PKG.next_doc_no('HR_LEAVE_REQUEST', company, NULL, TRUNC(SYSDATE), 'HR_LEAVE_REQUEST', NULL), TRUNC(SYSDATE),
            l_emp, l_type.id, l_from, l_to, l_t1, l_t2, l_dur, l_sub, l_why, 'SUBMITTED')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HR_LEAVE_REQUEST', l_id, 'SUBMIT', 'SUCCESS');
    RETURN l_id;
  END request_leave;

  PROCEDURE balance_taken(p_r hr_leave_request%ROWTYPE, p_sign NUMBER) IS
    l_code VARCHAR2(50);
  BEGIN
    SELECT code INTO l_code FROM hr_leave_type WHERE id = p_r.leave_type_id;
    IF l_code <> 'ANNUAL' THEN RETURN; END IF;
    MERGE INTO hr_leave_balance b
    USING (SELECT p_r.employee_id e, p_r.leave_type_id t, EXTRACT(YEAR FROM p_r.start_date) y FROM dual) x
       ON (b.employee_id = x.e AND b.leave_type_id = x.t AND b.balance_year = x.y)
     WHEN MATCHED THEN UPDATE SET b.taken = b.taken + p_sign * p_r.duration
     WHEN NOT MATCHED THEN INSERT (employee_id, leave_type_id, balance_year, opening_balance, accrued, taken, adjusted, encashed)
          VALUES (x.e, x.t, x.y, 0, 0, p_sign * p_r.duration, 0, 0);
  END balance_taken;

  FUNCTION leave_row(p_id NUMBER) RETURN hr_leave_request%ROWTYPE IS
    l hr_leave_request%ROWTYPE;
  BEGIN
    SELECT r.* INTO l FROM hr_leave_request r WHERE r.id = p_id
       AND EXISTS (SELECT 1 FROM hr_employment m WHERE m.employee_id = r.employee_id AND m.company_id = company)
       FOR UPDATE;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HR-036', 'طلب الإجازة غير موجود', 'Leave request not found');
  END leave_row;

  PROCEDURE approve_leave(p_id IN NUMBER) IS
    l_r hr_leave_request%ROWTYPE;
  BEGIN
    guard('HR_LEAVE_REQUEST.APPROVE');
    l_r := leave_row(p_id);
    NOONA_CORE_PKG.assert(l_r.status_code = 'SUBMITTED', 'NOONA-HR-037', 'الطلب ليس بانتظار الاعتماد', 'Request is not pending');
    UPDATE hr_leave_request SET status_code = 'APPROVED' WHERE id = p_id;
    balance_taken(l_r, 1);
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'HR_LEAVE_REQUEST', p_id, 'APPROVE', 'SUCCESS');
  END approve_leave;

  PROCEDURE reject_leave(p_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_r hr_leave_request%ROWTYPE;
  BEGIN
    guard('HR_LEAVE_REQUEST.REJECT');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-HR-038', 'سبب الرفض إلزامي', 'Reason is required');
    l_r := leave_row(p_id);
    NOONA_CORE_PKG.assert(l_r.status_code = 'SUBMITTED', 'NOONA-HR-037', 'الطلب ليس بانتظار الاعتماد', 'Request is not pending');
    UPDATE hr_leave_request SET status_code = 'REJECTED', reason = SUBSTR(reason || ' | الرفض: ' || p_reason, 1, 1000) WHERE id = p_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'HR_LEAVE_REQUEST', p_id, 'REJECT', 'SUCCESS', p_reason => p_reason);
  END reject_leave;

  PROCEDURE cancel_leave(p_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_r hr_leave_request%ROWTYPE;
    l_n NUMBER;
  BEGIN
    guard('HR_LEAVE_REQUEST.CANCEL');
    l_r := leave_row(p_id);
    NOONA_CORE_PKG.assert(l_r.status_code IN ('SUBMITTED', 'APPROVED'), 'NOONA-HR-039', 'لا يلغى هذا الطلب', 'Request cannot be cancelled');
    -- لا تلغى إجازة غير مدفوعة دخلت في رواتب مرحلة
    SELECT COUNT(*) INTO l_n FROM pay_run r JOIN pay_period p ON p.id = r.period_id
     WHERE r.company_id = company AND r.status_code IN ('POSTED', 'PAID', 'CLOSED') AND p.end_date >= l_r.start_date
       AND p.start_date <= l_r.end_date;
    NOONA_CORE_PKG.assert(l_n = 0 OR l_r.status_code = 'SUBMITTED', 'NOONA-HR-040', 'دخلت الإجازة في رواتب مرحلة؛ لا تلغى',
      'Leave already included in posted payroll');
    IF l_r.status_code = 'APPROVED' THEN balance_taken(l_r, -1); END IF;
    UPDATE hr_leave_request SET status_code = 'CANCELLED', reason = SUBSTR(reason || ' | الإلغاء: ' || p_reason, 1, 1000) WHERE id = p_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HR_LEAVE_REQUEST', p_id, 'CANCEL', 'SUCCESS', p_reason => p_reason);
  END cancel_leave;

  PROCEDURE adjust_leave(p_employee_id IN NUMBER, p_type_code IN VARCHAR2, p_days IN NUMBER, p_reason IN VARCHAR2) IS
    l_m hr_employment%ROWTYPE;
  BEGIN
    guard('HR_LEAVE_REQUEST.APPROVE');
    l_m := employment_of(p_employee_id);
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL AND NVL(p_days, 0) <> 0, 'NOONA-HR-041', 'أدخل الأيام وسبب التسوية',
      'Days and reason are required');
    MERGE INTO hr_leave_balance b
    USING (SELECT p_employee_id e, leave_type_id(NVL(p_type_code, 'ANNUAL')) t, EXTRACT(YEAR FROM SYSDATE) y FROM dual) x
       ON (b.employee_id = x.e AND b.leave_type_id = x.t AND b.balance_year = x.y)
     WHEN MATCHED THEN UPDATE SET b.adjusted = b.adjusted + p_days
     WHEN NOT MATCHED THEN INSERT (employee_id, leave_type_id, balance_year, opening_balance, accrued, taken, adjusted, encashed)
          VALUES (x.e, x.t, x.y, 0, 0, 0, p_days, 0);
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HR_LEAVE_BALANCE', p_employee_id, 'ADJUST', 'SUCCESS', p_reason => p_reason,
      p_new_values => '{"days":' || TO_CHAR(p_days, 'FM99990.99', 'NLS_NUMERIC_CHARACTERS=''.,''') || '}');
  END adjust_leave;

  FUNCTION unpaid_leave_days(p_employee_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(LEAST(r.end_date, p_to) - GREATEST(r.start_date, p_from) + 1), 0) INTO l
      FROM hr_leave_request r JOIN hr_leave_type t ON t.id = r.leave_type_id
     WHERE r.employee_id = p_employee_id AND t.is_paid = 'N' AND t.unit_code = 'DAY' AND r.status_code IN ('APPROVED', 'TAKEN')
       AND r.start_date <= p_to AND r.end_date >= p_from;
    RETURN l;
  END unpaid_leave_days;

  -- ================================================================ الحضور
  FUNCTION shift_row RETURN hr_shift%ROWTYPE IS
    l hr_shift%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM (SELECT * FROM hr_shift WHERE company_id = company AND is_active = 'Y' ORDER BY id) WHERE ROWNUM = 1;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l.start_time := '08:00'; l.end_time := '17:00'; l.break_minutes := 60; l.grace_minutes := 15;
    RETURN l;
  END shift_row;

  FUNCTION record_attendance(p_employee_id IN NUMBER, p_date IN DATE, p_in IN VARCHAR2, p_out IN VARCHAR2) RETURN NUMBER IS
    l_s    hr_shift%ROWTYPE := shift_row;
    l_m    hr_employment%ROWTYPE;
    l_d    DATE := TRUNC(p_date);
    l_in   DATE;
    l_out  DATE;
    l_ss   DATE;
    l_se   DATE;
    l_work NUMBER;
    l_req  NUMBER;
    l_id   NUMBER;
  BEGIN
    guard('HR_ATTENDANCE.CREATE');
    l_m := employment_of(p_employee_id);
    NOONA_CORE_PKG.assert(REGEXP_LIKE(p_in, '^[0-2][0-9]:[0-5][0-9]$') AND (p_out IS NULL OR REGEXP_LIKE(p_out, '^[0-2][0-9]:[0-5][0-9]$')),
      'NOONA-HR-050', 'الوقت بصيغة HH:MI', 'Time must be HH:MI');
    l_in := TO_DATE(TO_CHAR(l_d, 'YYYY-MM-DD') || ' ' || p_in, 'YYYY-MM-DD HH24:MI');
    l_out := CASE WHEN p_out IS NOT NULL THEN TO_DATE(TO_CHAR(l_d, 'YYYY-MM-DD') || ' ' || p_out, 'YYYY-MM-DD HH24:MI') END;
    IF l_out < l_in THEN l_out := l_out + 1; END IF;
    l_ss := TO_DATE(TO_CHAR(l_d, 'YYYY-MM-DD') || ' ' || l_s.start_time, 'YYYY-MM-DD HH24:MI');
    l_se := TO_DATE(TO_CHAR(l_d, 'YYYY-MM-DD') || ' ' || l_s.end_time, 'YYYY-MM-DD HH24:MI');
    l_req := ROUND((l_se - l_ss) * 1440) - NVL(l_s.break_minutes, 0);
    l_work := CASE WHEN l_out IS NOT NULL THEN ROUND((l_out - l_in) * 1440) - NVL(l_s.break_minutes, 0) END;
    DELETE FROM hr_attendance WHERE employee_id = p_employee_id AND work_date = l_d AND source_code = 'MANUAL';
    INSERT INTO hr_attendance (company_id, employee_id, work_date, shift_id, check_in_at, check_out_at, source_code, worked_minutes,
                               late_minutes, early_leave_minutes, overtime_minutes, status_code)
    VALUES (company, p_employee_id, l_d, l_s.id, CAST(l_in AS TIMESTAMP), CAST(l_out AS TIMESTAMP), 'MANUAL', GREATEST(l_work, 0),
            -- التأخير بعد فترة السماح يحتسب كاملاً من بداية الوردية
            CASE WHEN l_in > l_ss + NVL(l_s.grace_minutes, 0) / 1440 THEN ROUND((l_in - l_ss) * 1440) ELSE 0 END,
            CASE WHEN l_out IS NOT NULL AND l_out < l_se THEN ROUND((l_se - l_out) * 1440) ELSE 0 END,
            CASE WHEN l_work > l_req THEN l_work - l_req ELSE 0 END, 'PROCESSED')
    RETURNING id INTO l_id;
    RETURN l_id;
  END record_attendance;

  FUNCTION mark_absent(p_employee_id IN NUMBER, p_date IN DATE, p_note IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_m  hr_employment%ROWTYPE;
    l_id NUMBER;
  BEGIN
    guard('HR_ATTENDANCE.CREATE');
    l_m := employment_of(p_employee_id);
    DELETE FROM hr_attendance WHERE employee_id = p_employee_id AND work_date = TRUNC(p_date) AND source_code = 'MANUAL';
    INSERT INTO hr_attendance (company_id, employee_id, work_date, source_code, worked_minutes, absence_type, status_code)
    VALUES (company, p_employee_id, TRUNC(p_date), 'MANUAL', 0, 'ABSENT', 'PROCESSED')
    RETURNING id INTO l_id;
    RETURN l_id;
  END mark_absent;

  FUNCTION absent_days(p_employee_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT COUNT(DISTINCT work_date) INTO l FROM hr_attendance
     WHERE employee_id = p_employee_id AND work_date BETWEEN p_from AND p_to AND absence_type = 'ABSENT' AND status_code <> 'EXCEPTION';
    RETURN l;
  END absent_days;

  FUNCTION late_minutes(p_employee_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(late_minutes + early_leave_minutes), 0) INTO l FROM hr_attendance
     WHERE employee_id = p_employee_id AND work_date BETWEEN p_from AND p_to AND status_code <> 'EXCEPTION';
    RETURN l;
  END late_minutes;

  FUNCTION request_overtime(p_employee_id IN NUMBER, p_date IN DATE, p_hours IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_m  hr_employment%ROWTYPE;
    l_id NUMBER;
  BEGIN
    guard('HR_ATTENDANCE.CREATE');
    l_m := employment_of(p_employee_id);
    NOONA_CORE_PKG.assert(p_hours > 0 AND p_hours <= 12, 'NOONA-HR-051', 'ساعات الإضافي بين 0 و12 في اليوم', 'Overtime hours 0-12');
    INSERT INTO hr_overtime_request (company_id, employee_id, work_date, planned_hours, rate_multiplier, reason, status_code)
    VALUES (company, p_employee_id, TRUNC(p_date), p_hours, 1.5, SUBSTR(p_reason, 1, 1000), 'SUBMITTED')
    RETURNING id INTO l_id;
    RETURN l_id;
  END request_overtime;

  PROCEDURE approve_overtime(p_id IN NUMBER, p_actual_hours IN NUMBER DEFAULT NULL) IS
    l_n NUMBER;
  BEGIN
    guard('HR_ATTENDANCE.APPROVE');
    UPDATE hr_overtime_request SET status_code = 'APPROVED', actual_hours = NVL(p_actual_hours, planned_hours)
     WHERE id = p_id AND company_id = company AND status_code = 'SUBMITTED';
    l_n := SQL%ROWCOUNT;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-HR-052', 'الطلب ليس بانتظار الاعتماد', 'Request is not pending');
  END approve_overtime;

  PROCEDURE reject_overtime(p_id IN NUMBER) IS
  BEGIN
    guard('HR_ATTENDANCE.REJECT');
    UPDATE hr_overtime_request SET status_code = 'REJECTED' WHERE id = p_id AND company_id = company AND status_code = 'SUBMITTED';
  END reject_overtime;

  FUNCTION overtime_hours(p_employee_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(NVL(actual_hours, planned_hours)), 0) INTO l FROM hr_overtime_request
     WHERE employee_id = p_employee_id AND work_date BETWEEN p_from AND p_to AND status_code = 'APPROVED';
    RETURN l;
  END overtime_hours;

  -- ================================================================ التقارير
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION hr_summary RETURN CLOB IS
    l_head NUMBER; l_sa NUMBER; l_new NUMBER; l_leave NUMBER; l_pend NUMBER; l_exp NUMBER; l_prob NUMBER;
  BEGIN
    SELECT COUNT(*), NVL(SUM(CASE WHEN is_citizen(employee_category) = 'Y' THEN 1 ELSE 0 END), 0),
           NVL(SUM(CASE WHEN start_date >= TRUNC(SYSDATE, 'MM') THEN 1 ELSE 0 END), 0),
           NVL(SUM(CASE WHEN probation_end_date >= TRUNC(SYSDATE) THEN 1 ELSE 0 END), 0)
      INTO l_head, l_sa, l_new, l_prob
      FROM hr_employment WHERE company_id = company AND status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED');
    SELECT COUNT(DISTINCT r.employee_id) INTO l_leave FROM hr_leave_request r JOIN hr_employment m ON m.employee_id = r.employee_id
     WHERE m.company_id = company AND r.status_code IN ('APPROVED', 'TAKEN') AND TRUNC(SYSDATE) BETWEEN r.start_date AND r.end_date;
    SELECT COUNT(*) INTO l_pend FROM hr_leave_request r JOIN hr_employment m ON m.employee_id = r.employee_id
     WHERE m.company_id = company AND r.status_code = 'SUBMITTED';
    SELECT COUNT(*) INTO l_exp FROM hr_employee e JOIN hr_employment m ON m.employee_id = e.id
     WHERE m.company_id = company AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD') AND e.id_expiry_date < TRUNC(SYSDATE) + 60;
    RETURN '<div class="nn-kpis">'
        || kpi('الموظفون على رأس العمل', l_head, 'fa-users')
        || kpi('نسبة التوطين', CASE WHEN l_head > 0 THEN ROUND(l_sa * 100 / l_head, 1) ELSE 0 END || '%', 'fa-flag', 'is-success')
        || kpi('في إجازة اليوم', l_leave, 'fa-plane', 'is-info')
        || kpi('طلبات إجازة بانتظار الاعتماد', l_pend, 'fa-inbox', CASE WHEN l_pend > 0 THEN 'is-warning' ELSE 'is-info' END)
        || kpi('تعيينات هذا الشهر', l_new, 'fa-user-plus', 'is-success')
        || kpi('في فترة التجربة', l_prob, 'fa-hourglass-half', 'is-info')
        || kpi('هويات / إقامات تنتهي خلال 60 يوماً', l_exp, 'fa-id-card', CASE WHEN l_exp > 0 THEN 'is-danger' ELSE 'is-info' END)
        || '</div>';
  END hr_summary;

  FUNCTION employee_card(p_employment_id IN NUMBER) RETURN CLOB IS
    l_m    hr_employment%ROWTYPE := emp_row(p_employment_id);
    l_e    hr_employee%ROWTYPE;
    l_name VARCHAR2(300);
    l_unit VARCHAR2(300);
    l_mgr  VARCHAR2(300);
    l_html CLOB;
    l_tot  NUMBER := 0;
  BEGIN
    SELECT * INTO l_e FROM hr_employee WHERE id = l_m.employee_id;
    l_name := employee_name(l_m.employee_id);
    SELECT MAX(name_ar) INTO l_unit FROM org_unit WHERE id = l_m.org_unit_id;
    l_mgr := employee_name(l_m.manager_employee_id);
    l_html := '<div class="nn-hr-card"><div class="nn-hr-av">' || esc(SUBSTR(l_name, 1, 1)) || '</div><div class="nn-hr-id"><b>'
           || esc(l_name) || '</b><span>' || esc(l_e.employee_no) || ' · ' || esc(NVL(l_m.job_title, '-')) || CASE WHEN l_unit IS NOT NULL
              THEN ' · ' || esc(l_unit) END || '</span><span>' || category_label(NVL(l_m.employee_category, category(p_employment_id))) || CASE WHEN is_citizen(l_m.employee_category) = 'N' THEN ' (' || esc(l_e.nationality) || ')' END
           || ' · التعيين ' || TO_CHAR(l_m.start_date, 'YYYY-MM-DD') || ' · الخدمة ' || fnum(service_years(p_employment_id), 1) || ' سنة'
           || CASE WHEN l_mgr IS NOT NULL THEN ' · المدير: ' || esc(l_mgr) END || '</span></div><span class="nn-badge '
           || CASE l_m.status_code WHEN 'ACTIVE' THEN 'is-success' WHEN 'TERMINATED' THEN 'is-danger' ELSE 'is-warning' END || '">'
           || status_label(l_m.status_code) || '</span></div><div class="nn-hr-grid"><div><h4>هيكل الراتب الحالي</h4><table class="nn-rpt">';
    -- المبالغ بعد احتساب النسب وسياسة الشركة (الاستحقاقات الثابتة فقط)
    DECLARE
      l_st NOONA_PAY_PKG.t_lines := NOONA_PAY_PKG.structure(p_employment_id, GREATEST(TRUNC(SYSDATE), l_m.start_date));
    BEGIN
      FOR i IN 1 .. l_st.COUNT LOOP
        IF l_st(i).etype = 'EARNING' AND l_st(i).recurring = 'Y' AND NVL(l_st(i).amount, 0) <> 0 THEN
          l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(l_st(i).name) || '</td><td>' || fnum(l_st(i).amount) || '</td></tr>'));
          l_tot := l_tot + l_st(i).amount;
        END IF;
      END LOOP;
    END;
    l_html := l_html || (('<tr class="nn-rpt-total"><td class="nn-rpt-text">الإجمالي الشهري</td><td>' || fnum(l_tot) || '</td></tr></table></div>'
           || '<div><h4>الإجازات</h4><table class="nn-rpt"><tr><td class="nn-rpt-text">رصيد الإجازة السنوية المتاح</td><td>'
           || fnum(leave_available(l_m.employee_id, 'ANNUAL'), 1) || ' يوم</td></tr><tr><td class="nn-rpt-text">الاستحقاق السنوي</td><td>'
           || annual_days(l_m, TRUNC(SYSDATE)) || ' يوم</td></tr></table><h4>الحركات الوظيفية</h4><table class="nn-rpt">'));
    FOR a IN (SELECT * FROM (SELECT doc_no, action_type, effective_date, reason FROM hr_employee_action
                              WHERE employment_id = p_employment_id ORDER BY effective_date DESC, id DESC) WHERE ROWNUM <= 6) LOOP
      l_html := l_html || (('<tr><td>' || TO_CHAR(a.effective_date, 'YYYY-MM-DD') || '</td><td class="nn-rpt-text">'
             || CASE a.action_type WHEN 'HIRE' THEN 'تعيين' WHEN 'SALARY_CHANGE' THEN 'تعديل راتب' WHEN 'TRANSFER' THEN 'نقل'
                  WHEN 'POSITION_CHANGE' THEN 'تغيير مسمى' WHEN 'TERMINATION' THEN 'إنهاء خدمة' ELSE a.action_type END
             || ' · ' || esc(a.doc_no) || '</td><td class="nn-rpt-text">' || esc(a.reason) || '</td></tr>'));
    END LOOP;
    RETURN l_html || ('</table></div></div>');
  END employee_card;

  FUNCTION headcount_report RETURN CLOB IS
    l_html CLOB := '<table class="nn-rpt"><thead><tr><th>الإدارة</th><th>' || CASE WHEN company_country = 'SA' THEN 'سعودي' ELSE 'مواطن' END
                   || '</th><th>' || CASE WHEN company_country = 'SA' THEN 'غير سعودي' ELSE 'وافد' END || '</th><th>الإجمالي</th><th>نسبة التوطين</th></tr></thead><tbody>';
    l_s NUMBER := 0; l_n NUMBER := 0;
  BEGIN
    FOR r IN (SELECT NVL(u.name_ar, 'غير محدد') unit, SUM(CASE WHEN is_citizen(m.employee_category) = 'Y' THEN 1 ELSE 0 END) sa,
                     SUM(CASE WHEN is_citizen(m.employee_category) = 'N' THEN 1 ELSE 0 END) ns
                FROM hr_employment m LEFT JOIN org_unit u ON u.id = m.org_unit_id
               WHERE m.company_id = company AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED')
               GROUP BY NVL(u.name_ar, 'غير محدد') ORDER BY 1) LOOP
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(r.unit) || '</td><td>' || r.sa || '</td><td>' || r.ns || '</td><td>'
             || (r.sa + r.ns) || '</td><td>' || ROUND(r.sa * 100 / (r.sa + r.ns), 1) || '%</td></tr>'));
      l_s := l_s + r.sa; l_n := l_n + r.ns;
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td class="nn-rpt-text">الإجمالي</td><td>' || l_s || '</td><td>' || l_n || '</td><td>' || (l_s + l_n)
        || '</td><td>' || CASE WHEN l_s + l_n > 0 THEN ROUND(l_s * 100 / (l_s + l_n), 1) ELSE 0 END || '%</td></tr></tfoot></table>'));
  END headcount_report;

  FUNCTION leave_balances_report(p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN CLOB IS
    l_html CLOB := '<table class="nn-rpt"><thead><tr><th>الموظف</th><th>الاستحقاق السنوي</th><th>المرحل</th><th>المستخدم</th>'
                || '<th>التسويات</th><th>المتاح</th></tr></thead><tbody>';
  BEGIN
    FOR r IN (SELECT m.id, m.employee_id, m.annual_leave_days, m.start_date, NVL(b.opening_balance, 0) ob, NVL(b.taken, 0) tk, NVL(b.adjusted, 0) adj
                FROM hr_employment m
                LEFT JOIN hr_leave_balance b ON b.employee_id = m.employee_id AND b.balance_year = EXTRACT(YEAR FROM p_date)
                     AND b.leave_type_id = NOONA_HR_PKG.leave_type_id('ANNUAL')
               WHERE m.company_id = company AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED') ORDER BY m.id) LOOP
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(employment_label(r.id)) || '</td><td>'
             || CASE WHEN (p_date - r.start_date) / 365 >= 5 THEN GREATEST(30, r.annual_leave_days) ELSE r.annual_leave_days END || '</td><td>'
             || fnum(r.ob, 1) || '</td><td>' || fnum(r.tk, 1) || '</td><td>' || fnum(r.adj, 1) || '</td><td><b>'
             || fnum(leave_available(r.employee_id, 'ANNUAL', p_date), 1) || '</b></td></tr>'));
    END LOOP;
    RETURN l_html || ('</tbody></table>');
  END leave_balances_report;

  FUNCTION attendance_report(p_month IN DATE) RETURN CLOB IS
    l_from DATE := TRUNC(NVL(p_month, SYSDATE), 'MM');
    l_to   DATE := LAST_DAY(TRUNC(NVL(p_month, SYSDATE), 'MM'));
    l_html CLOB := '<table class="nn-rpt"><thead><tr><th>الموظف</th><th>أيام الحضور</th><th>الغياب</th><th>دقائق التأخير والخروج المبكر</th>'
                || '<th>إضافي معتمد (ساعة)</th><th>إجازة غير مدفوعة</th></tr></thead><tbody>';
  BEGIN
    FOR r IN (SELECT m.id, m.employee_id,
                     (SELECT COUNT(DISTINCT a.work_date) FROM hr_attendance a WHERE a.employee_id = m.employee_id
                         AND a.work_date BETWEEN l_from AND l_to AND a.absence_type IS NULL) present
                FROM hr_employment m WHERE m.company_id = company AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED')
               ORDER BY m.id) LOOP
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(employment_label(r.id)) || '</td><td>' || r.present || '</td><td>'
             || absent_days(r.employee_id, l_from, l_to) || '</td><td>' || late_minutes(r.employee_id, l_from, l_to) || '</td><td>'
             || fnum(overtime_hours(r.employee_id, l_from, l_to), 1) || '</td><td>' || unpaid_leave_days(r.employee_id, l_from, l_to)
             || '</td></tr>'));
    END LOOP;
    RETURN l_html || ('</tbody></table>');
  END attendance_report;

  FUNCTION expiring_report(p_days IN NUMBER DEFAULT 60) RETURN CLOB IS
    l_html CLOB := '<table class="nn-rpt"><thead><tr><th>الموظف</th><th>المستند</th><th>الرقم</th><th>ينتهي في</th><th>الحالة</th></tr></thead><tbody>';
    l_n    NUMBER := 0;
  BEGIN
    FOR r IN (SELECT m.id, 'الهوية / الإقامة' doc, e.national_id no, e.id_expiry_date d
                FROM hr_employee e JOIN hr_employment m ON m.employee_id = e.id
               WHERE m.company_id = company AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD') AND e.id_expiry_date < TRUNC(SYSDATE) + p_days
              UNION ALL
              SELECT m.id, 'عقد العمل', c.contract_no, c.end_date
                FROM hr_contract c JOIN hr_employment m ON m.id = c.employment_id
               WHERE m.company_id = company AND m.status_code IN ('ACTIVE', 'NOTICE_PERIOD') AND c.status_code = 'ACTIVE'
                 AND c.end_date < TRUNC(SYSDATE) + p_days
              UNION ALL
              SELECT m.id, 'نهاية فترة التجربة', NULL, m.probation_end_date
                FROM hr_employment m
               WHERE m.company_id = company AND m.status_code = 'ACTIVE' AND m.probation_end_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + p_days
               ORDER BY 4) LOOP
      l_n := l_n + 1;
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(employment_label(r.id)) || '</td><td class="nn-rpt-text">' || r.doc
             || '</td><td>' || esc(r.no) || '</td><td>' || TO_CHAR(r.d, 'YYYY-MM-DD') || '</td><td>'
             || CASE WHEN r.d < TRUNC(SYSDATE) THEN '<span class="nn-badge is-danger">منتهي</span>'
                     ELSE '<span class="nn-badge is-warning">بعد ' || (r.d - TRUNC(SYSDATE)) || ' يوم</span>' END || '</td></tr>'));
    END LOOP;
    IF l_n = 0 THEN
      l_html := l_html || ('<tr><td colspan="5" class="nn-rpt-text">لا توجد مستندات منتهية أو قريبة الانتهاء</td></tr>');
    END IF;
    RETURN l_html || ('</tbody></table>');
  END expiring_report;

END NOONA_HR_PKG;
/
