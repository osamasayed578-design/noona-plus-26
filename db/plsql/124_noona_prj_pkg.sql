-- =============================================================================
-- NOONA PLUS ERP | NOONA_PRJ_PKG - المشروعات والمقاولات والإنشاءات (داخل التطبيق 139 NOONA_PRJ)
--   * مشروعات عامة بأنواعها (عميل، مقاولات، داخلي، تطوير عقاري، صيانة، رأسمالي) ومركز تكلفة لكل مشروع
--   * هيكل تقسيم العمل WBS بأوزان ونسب إنجاز، والموازنة حسب البند ونوع التكلفة، والتكاليف الفعلية
--     (مصروفات مباشرة من الصندوق/البنك، صرف مواد من المخزون، ساعات العمل بتكلفة الموظف)
--   * العقود (الرئيسي مع العميل وعقود الباطن) وجدول الكميات BOQ وأوامر التغيير
--   * المستخلصات بالكميات التراكمية والمحتجز وسقفه واسترداد الدفعة المقدمة والضريبة، والدفعة المقدمة،
--     والإفراج عن المحتجز؛ تعتمد بقيد وذمة على العميل أو للمقاول (تحصل وتسدد من شاشات التحصيل والسداد)
--   * التخصيص العقاري: ربط المشروع بالعقار وتوزيع تكلفة التطوير على الوحدات حسب المساحة أو السعر أو العدد
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_PRJ_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- حسابات المشروعات للشركة (المحتجزات، الدفعات المقدمة، إيرادات العقود، التكاليف)؛ يعيد عدد المنشأ
  FUNCTION setup_accounts RETURN NUMBER;

  FUNCTION type_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION cost_type_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION kind_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION project_label(p_project_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- المشروع
  -- {"id","code","name","nameEn","type","customer":acct,"manager":emp,"parent","start","end","contract","budget","method","property","status","cc"}
  FUNCTION save_project(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_status(p_project_id IN NUMBER, p_status IN VARCHAR2);
  -- {"id","project","parent","code","name","weight","start","end","billable"}
  FUNCTION save_wbs(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE delete_wbs(p_wbs_id IN NUMBER);
  PROCEDURE update_progress(p_wbs_id IN NUMBER, p_pct IN NUMBER, p_remarks IN VARCHAR2 DEFAULT NULL);
  -- نسبة إنجاز المشروع: متوسط مرجح بأوزان البنود الفرعية (أو بالتساوي)
  FUNCTION project_progress(p_project_id IN NUMBER) RETURN NUMBER;
  -- موازنة جديدة تصبح خط الأساس: [{"w":wbs,"t":"MATERIAL","a":1000}]
  FUNCTION save_budget(p_project_id IN NUMBER, p_lines IN CLOB, p_reason IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION budget_json(p_project_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- التكاليف الفعلية
  -- {"project","wbs","type","date","amount","place":"BOX:1|BANK:2","desc","ref"}
  FUNCTION post_expense(p_doc IN CLOB) RETURN NUMBER;
  -- صرف مواد من المخزون على المشروع: {"project","wbs","wh","date","desc","lines":[{"i","q"}]}
  FUNCTION issue_material(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","employee","project","wbs","date","hours","rate","billable"}
  FUNCTION save_timesheet(p_doc IN CLOB) RETURN NUMBER;
  -- يعتمد ويحمل ساعات العمل حتى تاريخ على المشروع؛ يعيد عدد السجلات
  FUNCTION post_timesheets(p_project_id IN NUMBER, p_upto IN DATE DEFAULT NULL) RETURN NUMBER;
  PROCEDURE reverse_cost(p_cost_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION hourly_rate(p_employee_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- العقود
  -- {"id","project","type":"MAIN_CONTRACT|SUBCONTRACT","no","customer","supplier","pricing","value","ret","retCap","adv","advRec","start","end","dlp"}
  FUNCTION save_contract(p_doc IN CLOB) RETURN NUMBER;
  -- جدول الكميات: [{"id","code","d","u":uom,"q","r","w":wbs}] - البنود غير المرسلة تحذف إن لم تستخدم في مستخلص
  FUNCTION save_boq(p_contract_id IN NUMBER, p_lines IN CLOB) RETURN NUMBER;
  FUNCTION boq_json(p_contract_id IN NUMBER) RETURN CLOB;
  PROCEDURE activate_contract(p_contract_id IN NUMBER);
  PROCEDURE close_contract(p_contract_id IN NUMBER);
  -- أمر تغيير: {"contract","type","desc","ref","days","lines":[{"b":boqId,"code","d","u","q","r"}]}
  FUNCTION save_variation(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE approve_variation(p_variation_id IN NUMBER);
  FUNCTION contract_value(p_contract_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- المستخلصات
  -- مستخلص جديد (مسودة) بالكميات السابقة؛ النوع PROGRESS / ADVANCE / RETENTION_RELEASE
  FUNCTION new_claim(p_contract_id IN NUMBER, p_kind IN VARCHAR2 DEFAULT 'PROGRESS', p_from IN DATE DEFAULT NULL,
                     p_to IN DATE DEFAULT NULL) RETURN NUMBER;
  -- {"id","from","to","date","other","amount","lines":[{"b":boqId,"q":qtyToDate}]}
  PROCEDURE save_claim(p_doc IN CLOB);
  FUNCTION claim_json(p_claim_id IN NUMBER) RETURN CLOB;
  PROCEDURE approve_claim(p_claim_id IN NUMBER);
  PROCEDURE cancel_claim(p_claim_id IN NUMBER, p_reason IN VARCHAR2);
  -- المحتجز القائم والدفعة المقدمة غير المستردة للعقد
  FUNCTION retention_held(p_contract_id IN NUMBER) RETURN NUMBER;
  FUNCTION advance_open(p_contract_id IN NUMBER) RETURN NUMBER;

  -- شروط الشاشات (تعبيرات PL/SQL بلا استعلام)
  FUNCTION contract_status(p_contract_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION claim_status(p_claim_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION has_property(p_project_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION draft_variations(p_contract_id IN NUMBER) RETURN NUMBER;
  FUNCTION can_advance(p_contract_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- التطوير العقاري
  PROCEDURE link_property(p_project_id IN NUMBER, p_property_id IN NUMBER);

  -- ---------------------------------------------------------- الشاشات والتقارير
  FUNCTION summary_html RETURN CLOB;
  FUNCTION project_card_html(p_project_id IN NUMBER) RETURN CLOB;
  FUNCTION wbs_html(p_project_id IN NUMBER) RETURN CLOB;
  FUNCTION budget_html(p_project_id IN NUMBER) RETURN CLOB;
  FUNCTION costs_html(p_project_id IN NUMBER, p_limit IN PLS_INTEGER DEFAULT 50) RETURN CLOB;
  FUNCTION contracts_html(p_project_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION contract_html(p_contract_id IN NUMBER) RETURN CLOB;
  FUNCTION claims_html(p_contract_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- شهادة المستخلص للطباعة
  FUNCTION claim_print(p_claim_id IN NUMBER) RETURN CLOB;
  FUNCTION portfolio_html(p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION claims_register_html(p_from IN DATE, p_to IN DATE, p_direction IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION retention_html RETURN CLOB;
  FUNCTION cost_report_html(p_from IN DATE, p_to IN DATE, p_project_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- توزيع تكلفة التطوير على وحدات العقار: AREA / SALE_VALUE / UNIT_COUNT
  FUNCTION unit_costs_html(p_project_id IN NUMBER, p_basis IN VARCHAR2 DEFAULT 'AREA') RETURN CLOB;
END NOONA_PRJ_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PRJ_PKG AS

  c_prj   CONSTANT VARCHAR2(30) := 'PRJ_PROJECT';
  c_claim CONSTANT VARCHAR2(30) := 'PRJ_PROGRESS_CLAIM';
  c_cost  CONSTANT VARCHAR2(30) := 'PRJ_COST_LINE';
  c_ts    CONSTANT VARCHAR2(30) := 'PRJ_TIMESHEET';

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  FUNCTION fq(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,990.999', 'NLS_NUMERIC_CHARACTERS=''.,''')), '0'), '.');
  END fq;
  FUNCTION pct(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM990.0', 'NLS_NUMERIC_CHARACTERS=''.,''')) || '%';
  END pct;
  FUNCTION d(p VARCHAR2) RETURN DATE IS BEGIN RETURN TO_DATE(p, 'YYYY-MM-DD'); END d;
  FUNCTION ds(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END ds;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    IF p_permission NOT LIKE '%.VIEW' THEN
      NOONA_CORE_PKG.assert_tenant_writable;
    END IF;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jn(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN p_o.get_number(p_k) END;
  EXCEPTION WHEN OTHERS THEN
    RETURN TO_NUMBER(p_o.get_string(p_k));
  END jn;

  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_cc NUMBER,
                     p_party NUMBER, p_desc VARCHAR2) IS
  BEGIN
    IF NVL(p_dr, 0) = 0 AND NVL(p_cr, 0) = 0 THEN RETURN; END IF;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := NVL(p_dr, 0);
    p_lines(p_lines.COUNT).credit := NVL(p_cr, 0);
    p_lines(p_lines.COUNT).cost_center_id := p_cc;
    p_lines(p_lines.COUNT).party_id := p_party;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
  END add_line;

  -- ================================================================ الحسابات
  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER := NOONA_INV_PKG.acc_id(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type, 'Y', NULL);
    END IF;
    RETURN l;
  END ensure_account;

  FUNCTION acc(p_kind VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE p_kind
      WHEN 'RET_REC' THEN ensure_account('1140', 'محتجزات لدى عملاء المشروعات', '11', 'ASSET')
      WHEN 'ADV_PAID' THEN ensure_account('1141', 'دفعات مقدمة لمقاولي الباطن', '11', 'ASSET')
      WHEN 'ADV_RCVD' THEN ensure_account('2140', 'دفعات مقدمة من عملاء المشروعات', '21', 'LIABILITY')
      WHEN 'RET_PAY' THEN ensure_account('2141', 'محتجزات مقاولي الباطن', '21', 'LIABILITY')
      WHEN 'REVENUE' THEN ensure_account('4130', 'إيرادات عقود المشروعات', '4', 'REVENUE')
      WHEN 'COST' THEN ensure_account('5150', 'تكاليف المشروعات', '51', 'EXPENSE')
      WHEN 'LABOR_APPLIED' THEN ensure_account('5159', 'تكلفة العمالة المحملة على المشروعات', '51', 'EXPENSE') END;
  END acc;

  FUNCTION setup_accounts RETURN NUMBER IS
    l_n NUMBER := 0;
    l_x NUMBER;
  BEGIN
    guard('PRJ_PROJECT.CREATE');
    FOR k IN (SELECT column_value c FROM TABLE(sys.odcivarchar2list('RET_REC', 'ADV_PAID', 'ADV_RCVD', 'RET_PAY', 'REVENUE', 'COST', 'LABOR_APPLIED'))) LOOP
      l_x := acc(k.c);
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END setup_accounts;

  FUNCTION vat_code RETURN NUMBER IS BEGIN RETURN NOONA_INV_PKG.tax_id('VAT15'); END vat_code;

  -- ================================================================ المسميات
  FUNCTION type_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'CONSTRUCTION' THEN 'مقاولات وإنشاءات' WHEN 'CLIENT_CONTRACT' THEN 'مشروع لعميل' WHEN 'INTERNAL' THEN 'داخلي'
      WHEN 'REAL_ESTATE_DEVELOPMENT' THEN 'تطوير عقاري' WHEN 'MAINTENANCE' THEN 'صيانة' WHEN 'CAPEX' THEN 'رأسمالي'
      WHEN 'PROGRAM' THEN 'برنامج' WHEN 'PORTFOLIO' THEN 'محفظة' ELSE p_code END;
  END type_label;

  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'PLANNED' THEN 'مخطط' WHEN 'APPROVED' THEN 'معتمد' WHEN 'ACTIVE' THEN 'قيد التنفيذ' WHEN 'ON_HOLD' THEN 'متوقف مؤقتاً'
      WHEN 'COMPLETED' THEN 'منجز' WHEN 'CLOSED' THEN 'مغلق' WHEN 'CANCELLED' THEN 'ملغى' WHEN 'DRAFT' THEN 'مسودة'
      WHEN 'SIGNED' THEN 'موقع' WHEN 'SUSPENDED' THEN 'معلق' WHEN 'TERMINATED' THEN 'منهي' WHEN 'PAID' THEN 'مسدد'
      WHEN 'INVOICED' THEN 'مفوتر' WHEN 'REJECTED' THEN 'مرفوض' WHEN 'SUBMITTED' THEN 'مقدم' WHEN 'POSTED' THEN 'مرحل'
      WHEN 'REVERSED' THEN 'معكوس' ELSE p_code END;
  END status_label;

  FUNCTION cost_type_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'MATERIAL' THEN 'مواد' WHEN 'LABOR' THEN 'عمالة' WHEN 'EQUIPMENT' THEN 'معدات' WHEN 'SUBCONTRACT' THEN 'مقاولو باطن'
      WHEN 'OVERHEAD' THEN 'مصروفات غير مباشرة' WHEN 'OTHER' THEN 'أخرى' WHEN 'REVENUE' THEN 'إيراد' ELSE p_code END;
  END cost_type_label;

  FUNCTION kind_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'PROGRESS' THEN 'مستخلص أعمال' WHEN 'ADVANCE' THEN 'دفعة مقدمة' WHEN 'RETENTION_RELEASE' THEN 'إفراج عن المحتجز'
      ELSE p_code END;
  END kind_label;

  FUNCTION badge(p_status VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p_status IN ('ACTIVE', 'APPROVED', 'PAID', 'COMPLETED', 'POSTED') THEN 'is-success'
                                            WHEN p_status IN ('ON_HOLD', 'DRAFT', 'PLANNED', 'SUBMITTED', 'SUSPENDED') THEN 'is-warning'
                                            WHEN p_status IN ('CANCELLED', 'REJECTED', 'TERMINATED', 'REVERSED') THEN 'is-danger'
                                            ELSE 'is-muted' END || '">' || esc(status_label(p_status)) || '</span>';
  END badge;

  FUNCTION bar(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-prj-bar" title="' || pct(p) || '"><i style="width:' || LEAST(GREATEST(ROUND(NVL(p, 0)), 0), 100) || '%"></i></span> '
        || pct(p);
  END bar;

  FUNCTION get_project(p_id NUMBER) RETURN prj_project%ROWTYPE IS
    l prj_project%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM prj_project WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-001', 'المشروع غير موجود', 'Project not found');
  END get_project;

  FUNCTION get_contract(p_id NUMBER) RETURN prj_contract%ROWTYPE IS
    l prj_contract%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM prj_contract WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-030', 'العقد غير موجود', 'Contract not found');
  END get_contract;

  FUNCTION project_label(p_project_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT code || ' - ' || name_ar INTO l FROM prj_project WHERE id = p_project_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END project_label;

  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 5, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE),
             CASE WHEN p_type LIKE 'PRJ_CLAIM%' THEN c_claim WHEN p_type = 'PRJ_VARIATION' THEN 'PRJ_VARIATION_ORDER' ELSE p_type END, NULL);
  END next_no;

  -- ================================================================ المشروع
  FUNCTION default_wbs(p_project_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY wbs_level, code) INTO l FROM prj_wbs
     WHERE project_id = p_project_id AND is_chargeable = 'Y' AND status_code NOT IN ('CLOSED', 'CANCELLED');
    IF l IS NULL THEN
      INSERT INTO prj_wbs (company_id, project_id, code, name_ar, wbs_level, weight_pct, status_code)
      VALUES (company, p_project_id, 'GEN', 'أعمال عامة', 1, NULL, 'ACTIVE')
      RETURNING id INTO l;
    END IF;
    RETURN l;
  END default_wbs;

  FUNCTION save_project(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jn(l_o, 'id');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_name VARCHAR2(400) := js(l_o, 'name');
    l_type VARCHAR2(30) := NVL(js(l_o, 'type'), 'CLIENT_CONTRACT');
    l_cc   NUMBER := jn(l_o, 'cc');
    l_prop NUMBER := jn(l_o, 'property');
    l_en   VARCHAR2(400) := js(l_o, 'nameEn');
    l_par  NUMBER := jn(l_o, 'parent');
    l_cust NUMBER := jn(l_o, 'customer');
    l_mgr  NUMBER := jn(l_o, 'manager');
    l_from DATE := d(js(l_o, 'start'));
    l_to   DATE := d(js(l_o, 'end'));
    l_cv   NUMBER := jn(l_o, 'contract');
    l_bud  NUMBER := jn(l_o, 'budget');
    l_meth VARCHAR2(30) := js(l_o, 'method');
    l_st   VARCHAR2(30) := NVL(js(l_o, 'status'), 'PLANNED');
    l_br   NUMBER := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID'));
    l_co   NUMBER := company;
    l_cur  VARCHAR2(3) := NOONA_GL_PKG.ledger_currency;
    l_n    NUMBER;
    l_x    NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'PRJ_PROJECT.CREATE' ELSE 'PRJ_PROJECT.UPDATE' END);
    NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-PRJ-002', 'اكتب اسم المشروع', 'Project name is required');
    NOONA_CORE_PKG.assert(l_to IS NULL OR l_from IS NULL OR l_to >= l_from,
                          'NOONA-PRJ-003', 'تاريخ النهاية قبل البداية', 'End date is before start date');
    NOONA_CORE_PKG.assert(l_type <> 'REAL_ESTATE_DEVELOPMENT' OR l_prop IS NOT NULL OR l_id IS NOT NULL, 'NOONA-PRJ-004',
                          'مشروع التطوير العقاري يرتبط بعقار؛ اختر العقار أو أنشئه من السجل العقاري', 'Choose the property for a development project');
    IF l_id IS NULL THEN
      IF l_code IS NULL THEN
        l_code := next_no('PRJ_PROJECT', 'PRJ-');
      END IF;
      SELECT COUNT(*) INTO l_n FROM prj_project WHERE company_id = l_co AND code = l_code;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRJ-005', 'رمز المشروع مستخدم: ' || l_code, 'Project code already used');
      -- مركز تكلفة لكل مشروع (تحمل عليه التكاليف والإيرادات في الأستاذ)
      IF l_cc IS NULL THEN
        SELECT MIN(id) INTO l_cc FROM gl_cost_center WHERE company_id = l_co AND code = l_code;
        IF l_cc IS NULL THEN
          l_cc := NOONA_GL_PKG.create_cost_center(l_code, 'مشروع: ' || l_name, 'PROFIT');
        END IF;
      END IF;
      INSERT INTO prj_project (company_id, branch_id, code, name_ar, name_en, project_type, parent_project_id, customer_account_id,
                               manager_employee_id, cost_center_id, currency_code, planned_start, planned_end, contract_value, budget_amount,
                               percent_complete, revenue_method, status_code)
      VALUES (l_co, l_br, l_code, l_name, l_en, l_type, l_par, l_cust, l_mgr, l_cc, l_cur, l_from, l_to, l_cv, l_bud, 0,
              NVL(l_meth, 'BILLING'), l_st)
      RETURNING id INTO l_id;
      l_x := default_wbs(l_id);
      NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_prj, l_id, 'CREATE', 'SUCCESS');
    ELSE
      UPDATE prj_project SET name_ar = l_name, name_en = l_en, project_type = l_type, parent_project_id = l_par,
                             customer_account_id = l_cust, manager_employee_id = l_mgr, planned_start = l_from, planned_end = l_to,
                             contract_value = NVL(l_cv, contract_value), budget_amount = NVL(l_bud, budget_amount),
                             revenue_method = NVL(l_meth, revenue_method), cost_center_id = NVL(l_cc, cost_center_id)
       WHERE id = l_id AND company_id = l_co;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRJ-001', 'المشروع غير موجود', 'Project not found');
    END IF;
    IF l_prop IS NOT NULL THEN
      link_property(l_id, l_prop);
    END IF;
    RETURN l_id;
  END save_project;

  PROCEDURE set_status(p_project_id IN NUMBER, p_status IN VARCHAR2) IS
    l prj_project%ROWTYPE := get_project(p_project_id);
  BEGIN
    guard('PRJ_PROJECT.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('PLANNED', 'APPROVED', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'CLOSED', 'CANCELLED'), 'NOONA-PRJ-006',
                          'حالة غير صالحة', 'Invalid status');
    NOONA_CORE_PKG.assert(l.status_code NOT IN ('CLOSED', 'CANCELLED') OR p_status = l.status_code, 'NOONA-PRJ-007',
                          'المشروع مغلق أو ملغى', 'Project is closed or cancelled');
    UPDATE prj_project SET status_code = p_status,
                           actual_start = CASE WHEN p_status = 'ACTIVE' THEN NVL(actual_start, TRUNC(SYSDATE)) ELSE actual_start END,
                           actual_end = CASE WHEN p_status IN ('COMPLETED', 'CLOSED') THEN NVL(actual_end, TRUNC(SYSDATE)) ELSE actual_end END
     WHERE id = p_project_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_prj, p_project_id, 'STATUS_' || p_status, 'SUCCESS');
  END set_status;

  PROCEDURE assert_open(p_project_id NUMBER) IS
    l prj_project%ROWTYPE := get_project(p_project_id);
  BEGIN
    NOONA_CORE_PKG.assert(l.status_code NOT IN ('CLOSED', 'CANCELLED'), 'NOONA-PRJ-007', 'المشروع مغلق أو ملغى', 'Project is closed or cancelled');
  END assert_open;

  FUNCTION save_wbs(p_doc IN CLOB) RETURN NUMBER IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id     NUMBER := jn(l_o, 'id');
    l_prj    NUMBER := jn(l_o, 'project');
    l_parent NUMBER := jn(l_o, 'parent');
    l_level  NUMBER := 1;
    l_code   VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_name   VARCHAR2(400) := js(l_o, 'name');
    l_w      NUMBER := jn(l_o, 'weight');
    l_from   DATE := d(js(l_o, 'start'));
    l_to     DATE := d(js(l_o, 'end'));
    l_bill   VARCHAR2(1) := js(l_o, 'billable');
    l_co     NUMBER := company;
    l_n      NUMBER;
  BEGIN
    guard('PRJ_PROJECT.UPDATE');
    IF l_id IS NOT NULL THEN
      SELECT project_id INTO l_prj FROM prj_wbs WHERE id = l_id AND company_id = l_co;
    END IF;
    assert_open(l_prj);
    NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-PRJ-010', 'اكتب اسم البند', 'Name is required');
    NOONA_CORE_PKG.assert(NVL(l_w, 0) BETWEEN 0 AND 100, 'NOONA-PRJ-011', 'الوزن بين 0 و 100', 'Weight must be 0-100');
    IF l_parent IS NOT NULL THEN
      SELECT wbs_level + 1 INTO l_level FROM prj_wbs WHERE id = l_parent AND project_id = l_prj;
      NOONA_CORE_PKG.assert(l_id IS NULL OR l_parent <> l_id, 'NOONA-PRJ-012', 'البند لا يكون أباً لنفسه', 'An item cannot be its own parent');
    END IF;
    IF l_code IS NULL THEN
      SELECT COUNT(*) + 1 INTO l_n FROM prj_wbs WHERE project_id = l_prj;
      l_code := LPAD(l_n, 2, '0');
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO prj_wbs (company_id, project_id, parent_wbs_id, code, name_ar, wbs_level, weight_pct, planned_start, planned_end,
                           is_billable, status_code)
      VALUES (l_co, l_prj, l_parent, l_code, l_name, l_level, l_w, l_from, l_to, NVL(l_bill, 'Y'), 'PLANNED')
      RETURNING id INTO l_id;
    ELSE
      UPDATE prj_wbs SET parent_wbs_id = l_parent, code = l_code, name_ar = l_name, wbs_level = l_level, weight_pct = l_w,
                         planned_start = l_from, planned_end = l_to, is_billable = NVL(l_bill, is_billable)
       WHERE id = l_id;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-013', 'رمز البند مستخدم في المشروع', 'WBS code already used');
  END save_wbs;

  PROCEDURE delete_wbs(p_wbs_id IN NUMBER) IS
    l_n NUMBER;
  BEGIN
    guard('PRJ_PROJECT.UPDATE');
    SELECT (SELECT COUNT(*) FROM prj_cost_line WHERE wbs_id = p_wbs_id) + (SELECT COUNT(*) FROM prj_wbs WHERE parent_wbs_id = p_wbs_id)
         + (SELECT COUNT(*) FROM prj_timesheet WHERE wbs_id = p_wbs_id) + (SELECT COUNT(*) FROM prj_budget_line WHERE wbs_id = p_wbs_id)
         + (SELECT COUNT(*) FROM prj_boq_item WHERE wbs_id = p_wbs_id)
      INTO l_n FROM dual;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRJ-014', 'البند عليه تكاليف أو بنود فرعية أو موازنة؛ أغلقه بدلاً من حذفه',
                          'Item is in use; close it instead');
    DELETE FROM prj_progress_update WHERE wbs_id = p_wbs_id;
    DELETE FROM prj_wbs WHERE id = p_wbs_id AND company_id = company;
  END delete_wbs;

  FUNCTION project_progress(p_project_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    -- البنود الطرفية فقط؛ البند بلا وزن يأخذ نصيباً متساوياً
    SELECT CASE WHEN SUM(NVL(w.weight_pct, 0)) > 0
                THEN SUM(w.percent_complete * NVL(w.weight_pct, 0)) / SUM(NVL(w.weight_pct, 0))
                ELSE AVG(w.percent_complete) END
      INTO l FROM prj_wbs w
     WHERE w.project_id = p_project_id AND w.status_code <> 'CANCELLED'
       AND NOT EXISTS (SELECT 1 FROM prj_wbs c WHERE c.parent_wbs_id = w.id AND c.status_code <> 'CANCELLED');
    RETURN ROUND(NVL(l, 0), 2);
  END project_progress;

  PROCEDURE update_progress(p_wbs_id IN NUMBER, p_pct IN NUMBER, p_remarks IN VARCHAR2 DEFAULT NULL) IS
    l_prj NUMBER;
    l_p   NUMBER;
  BEGIN
    guard('PRJ_PROJECT.UPDATE');
    NOONA_CORE_PKG.assert(p_pct BETWEEN 0 AND 100, 'NOONA-PRJ-015', 'نسبة الإنجاز بين 0 و 100', 'Progress must be 0-100');
    SELECT project_id INTO l_prj FROM prj_wbs WHERE id = p_wbs_id AND company_id = company;
    assert_open(l_prj);
    UPDATE prj_wbs SET percent_complete = p_pct,
                       status_code = CASE WHEN p_pct = 100 THEN 'COMPLETED' WHEN p_pct > 0 THEN 'ACTIVE' ELSE status_code END
     WHERE id = p_wbs_id;
    INSERT INTO prj_progress_update (company_id, project_id, wbs_id, as_of_date, percent_complete, method_code, remarks)
    VALUES (company, l_prj, p_wbs_id, TRUNC(SYSDATE), p_pct, 'PHYSICAL', p_remarks);
    l_p := project_progress(l_prj);
    UPDATE prj_project SET percent_complete = l_p,
                           status_code = CASE WHEN status_code IN ('PLANNED', 'APPROVED') AND l_p > 0 THEN 'ACTIVE' ELSE status_code END,
                           actual_start = CASE WHEN l_p > 0 THEN NVL(actual_start, TRUNC(SYSDATE)) ELSE actual_start END
     WHERE id = l_prj;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-016', 'البند غير موجود', 'WBS item not found');
  END update_progress;

  FUNCTION save_budget(p_project_id IN NUMBER, p_lines IN CLOB, p_reason IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_id  NUMBER;
    l_ver NUMBER;
    l_tot NUMBER := 0;
    l_n   NUMBER := 0;
    l_w   NUMBER;
  BEGIN
    guard('PRJ_PROJECT.UPDATE');
    assert_open(p_project_id);
    SELECT NVL(MAX(version_no), 0) + 1 INTO l_ver FROM prj_budget WHERE project_id = p_project_id AND budget_type = 'COST';
    UPDATE prj_budget SET is_baseline = 'N', status_code = 'SUPERSEDED'
     WHERE project_id = p_project_id AND budget_type = 'COST' AND is_baseline = 'Y';
    INSERT INTO prj_budget (company_id, project_id, version_no, budget_type, is_baseline, total_amount, change_reason, status_code)
    VALUES (company, p_project_id, l_ver, 'COST', 'Y', 0, NVL(p_reason, CASE WHEN l_ver = 1 THEN 'الموازنة الأصلية' END), 'BASELINE')
    RETURNING id INTO l_id;
    FOR r IN (SELECT * FROM JSON_TABLE(p_lines, '$[*]' COLUMNS (w NUMBER PATH '$.w', t VARCHAR2(30) PATH '$.t', a NUMBER PATH '$.a',
                                                                  q NUMBER PATH '$.q'))) LOOP
      CONTINUE WHEN NVL(r.a, 0) = 0;
      NOONA_CORE_PKG.assert(r.a > 0, 'NOONA-PRJ-020', 'مبالغ الموازنة موجبة', 'Budget amounts must be positive');
      NOONA_CORE_PKG.assert(r.t IN ('MATERIAL', 'LABOR', 'EQUIPMENT', 'SUBCONTRACT', 'OVERHEAD', 'OTHER'), 'NOONA-PRJ-021',
                            'نوع تكلفة غير صالح: ' || r.t, 'Invalid cost type');
      l_w := NVL(r.w, default_wbs(p_project_id));
      INSERT INTO prj_budget_line (company_id, budget_id, wbs_id, cost_type, amount, quantity)
      VALUES (company, l_id, l_w, r.t, ROUND(r.a, 2), r.q);
      l_tot := l_tot + ROUND(r.a, 2);
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-PRJ-022', 'أدخل سطراً واحداً على الأقل في الموازنة', 'Add at least one budget line');
    UPDATE prj_budget SET total_amount = l_tot WHERE id = l_id;
    UPDATE prj_project SET budget_amount = l_tot WHERE id = p_project_id;
    RETURN l_id;
  END save_budget;

  FUNCTION budget_json(p_project_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('w' VALUE bl.wbs_id, 't' VALUE bl.cost_type, 'a' VALUE bl.amount, 'q' VALUE bl.quantity)
                         ORDER BY bl.wbs_id, bl.cost_type RETURNING CLOB)
      INTO l FROM prj_budget b JOIN prj_budget_line bl ON bl.budget_id = b.id
     WHERE b.project_id = p_project_id AND b.budget_type = 'COST' AND b.is_baseline = 'Y';
    RETURN NVL(l, TO_CLOB('[]'));
  END budget_json;

  -- ================================================================ التكاليف
  FUNCTION wbs_of(p_project_id NUMBER, p_wbs NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF p_wbs IS NULL THEN
      RETURN default_wbs(p_project_id);
    END IF;
    SELECT id INTO l FROM prj_wbs WHERE id = p_wbs AND project_id = p_project_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-016', 'البند لا يتبع المشروع', 'WBS item does not belong to the project');
  END wbs_of;

  FUNCTION add_cost(p_project NUMBER, p_wbs NUMBER, p_type VARCHAR2, p_date DATE, p_amount NUMBER, p_qty NUMBER, p_desc VARCHAR2,
                    p_ref VARCHAR2, p_src_type VARCHAR2, p_src_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    INSERT INTO prj_cost_line (company_id, project_id, wbs_id, cost_type, cost_date, quantity, amount, amount_func, currency_code,
                               exchange_rate, description, reference, source_entity_type, source_entity_id, status_code)
    VALUES (company, p_project, p_wbs, p_type, p_date, p_qty, p_amount, p_amount, NOONA_GL_PKG.ledger_currency, 1, SUBSTR(p_desc, 1, 500),
            SUBSTR(p_ref, 1, 100), p_src_type, p_src_id, 'POSTED')
    RETURNING id INTO l;
    RETURN l;
  END add_cost;

  FUNCTION post_expense(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_prj   prj_project%ROWTYPE := get_project(jn(l_o, 'project'));
    l_wbs   NUMBER;
    l_type  VARCHAR2(30) := NVL(js(l_o, 'type'), 'OTHER');
    l_date  DATE := NVL(d(js(l_o, 'date')), TRUNC(SYSDATE));
    l_amt   NUMBER := ROUND(jn(l_o, 'amount'), 2);
    l_place VARCHAR2(30) := js(l_o, 'place');
    l_desc  VARCHAR2(500) := js(l_o, 'desc');
    l_id    NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_x     NUMBER;
  BEGIN
    guard('PRJ_COST_LINE.CREATE');
    assert_open(l_prj.id);
    NOONA_CORE_PKG.assert(NVL(l_amt, 0) > 0, 'NOONA-PRJ-040', 'المبلغ يجب أن يكون موجباً', 'Amount must be positive');
    NOONA_CORE_PKG.assert(l_place IS NOT NULL, 'NOONA-PRJ-041', 'اختر الصندوق أو البنك المدفوع منه', 'Choose the cash box or bank');
    NOONA_CORE_PKG.assert(l_desc IS NOT NULL, 'NOONA-PRJ-042', 'اكتب بيان المصروف', 'Description is required');
    NOONA_CORE_PKG.assert(l_type IN ('MATERIAL', 'LABOR', 'EQUIPMENT', 'SUBCONTRACT', 'OVERHEAD', 'OTHER'), 'NOONA-PRJ-021',
                          'نوع تكلفة غير صالح', 'Invalid cost type');
    l_wbs := wbs_of(l_prj.id, jn(l_o, 'wbs'));
    l_id := add_cost(l_prj.id, l_wbs, l_type, l_date, l_amt, NULL, l_desc, js(l_o, 'ref'), NULL, NULL);
    UPDATE prj_cost_line SET source_entity_type = c_cost, source_entity_id = l_id WHERE id = l_id;
    l_desc := 'مشروع ' || l_prj.code || ': ' || l_desc;
    add_line(l_lines, acc('COST'), l_amt, 0, l_prj.cost_center_id, NULL, l_desc);
    add_line(l_lines, NOONA_CSH_PKG.place_account(l_place), 0, l_amt, NULL, NULL, l_desc);
    l_j := NOONA_ACE_PKG.post_source('PRJ_COST_POSTED', 'PROJECTS', c_cost, l_id, l_date, l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                     l_lines, js(l_o, 'ref'), NULL, 'PROJECTS');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', l_place, l_date, l_amt, NULL, l_prj.name_ar, c_cost, l_id, 'PC-' || l_id,
                                           l_desc || NVL2(js(l_o, 'ref'), ' - مرجع ' || js(l_o, 'ref'), ''), l_ev);
    RETURN l_id;
  END post_expense;

  FUNCTION issue_material(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_prj  prj_project%ROWTYPE := get_project(jn(l_o, 'project'));
    l_wbs  NUMBER;
    l_date DATE := NVL(d(js(l_o, 'date')), TRUNC(SYSDATE));
    l_txn  NUMBER;
    l_tot  NUMBER;
    l_doc  JSON_OBJECT_T := JSON_OBJECT_T();
    l_no   VARCHAR2(50);
  BEGIN
    guard('PRJ_COST_LINE.CREATE');
    assert_open(l_prj.id);
    l_wbs := wbs_of(l_prj.id, jn(l_o, 'wbs'));
    l_doc.put('type', 'CONSUMPTION');
    l_doc.put('date', ds(l_date));
    IF jn(l_o, 'wh') IS NOT NULL THEN l_doc.put('wh', jn(l_o, 'wh')); END IF;
    l_doc.put('cc', l_prj.cost_center_id);
    l_doc.put('reason', 'PROJECT');
    l_doc.put('desc', 'صرف مواد لمشروع ' || l_prj.code || NVL2(js(l_o, 'desc'), ': ' || js(l_o, 'desc'), ''));
    l_doc.put('action', 'POST');
    l_doc.put('lines', l_o.get_array('lines'));
    l_txn := NOONA_INV_PKG.save_stock_doc(l_doc.to_clob);
    UPDATE inv_transaction_line SET project_id = l_prj.id WHERE transaction_id = l_txn;
    SELECT NVL(SUM(total_cost), 0) INTO l_tot FROM inv_transaction_line WHERE transaction_id = l_txn;
    SELECT doc_no INTO l_no FROM inv_transaction WHERE id = l_txn;
    RETURN add_cost(l_prj.id, l_wbs, 'MATERIAL', l_date, ROUND(l_tot, 2), NULL, 'صرف مواد من المخزون ' || l_no || NVL2(js(l_o, 'desc'), ': ' || js(l_o, 'desc'), ''),
                    l_no, 'INV_TRANSACTION', l_txn);
  END issue_material;

  FUNCTION hourly_rate(p_employee_id IN NUMBER) RETURN NUMBER IS
    l_emp NUMBER;
    l_w   NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK LAST ORDER BY start_date) INTO l_emp FROM hr_employment WHERE employee_id = p_employee_id;
    IF l_emp IS NULL THEN RETURN 0; END IF;
    l_w := NOONA_PAY_PKG.monthly_wage(l_emp);
    -- 30 يوماً × 8 ساعات
    RETURN ROUND(NVL(l_w, 0) / 240, 2);
  END hourly_rate;

  FUNCTION save_timesheet(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id  NUMBER := jn(l_o, 'id');
    l_prj NUMBER := jn(l_o, 'project');
    l_emp NUMBER := jn(l_o, 'employee');
    l_h   NUMBER := jn(l_o, 'hours');
    l_dt  DATE := d(js(l_o, 'date'));
    l_r   NUMBER := jn(l_o, 'rate');
    l_bl  VARCHAR2(1) := NVL(js(l_o, 'billable'), 'Y');
    l_w   NUMBER;
    l_st  VARCHAR2(30);
  BEGIN
    guard('PRJ_TIMESHEET.CREATE');
    assert_open(l_prj);
    l_w := wbs_of(l_prj, jn(l_o, 'wbs'));
    NOONA_CORE_PKG.assert(l_emp IS NOT NULL, 'NOONA-PRJ-050', 'اختر الموظف', 'Employee is required');
    NOONA_CORE_PKG.assert(l_h > 0 AND l_h <= 24, 'NOONA-PRJ-051', 'الساعات بين 0 و 24', 'Hours must be between 0 and 24');
    IF l_id IS NULL THEN
      INSERT INTO prj_timesheet (company_id, employee_id, project_id, wbs_id, work_date, hours, cost_rate, is_billable, status_code)
      VALUES (company, l_emp, l_prj, l_w, NVL(l_dt, TRUNC(SYSDATE)), l_h, NVL(l_r, hourly_rate(l_emp)), l_bl, 'SUBMITTED')
      RETURNING id INTO l_id;
    ELSE
      SELECT status_code INTO l_st FROM prj_timesheet WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st IN ('DRAFT', 'SUBMITTED'), 'NOONA-PRJ-052', 'السجل محمل على المشروع', 'Timesheet already posted');
      UPDATE prj_timesheet SET employee_id = l_emp, project_id = l_prj, wbs_id = l_w,
                               work_date = NVL(l_dt, work_date), hours = l_h, cost_rate = NVL(l_r, cost_rate)
       WHERE id = l_id;
    END IF;
    RETURN l_id;
  END save_timesheet;

  FUNCTION post_timesheets(p_project_id IN NUMBER, p_upto IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_prj   prj_project%ROWTYPE := get_project(p_project_id);
    l_n     NUMBER := 0;
    l_amt   NUMBER;
    l_lines NOONA_GL_PKG.t_lines;
    l_j     NUMBER;
    l_c     NUMBER;
    l_desc  VARCHAR2(1000);
  BEGIN
    guard('PRJ_TIMESHEET.APPROVE');
    assert_open(p_project_id);
    FOR t IN (SELECT * FROM prj_timesheet WHERE project_id = p_project_id AND status_code IN ('DRAFT', 'SUBMITTED')
                 AND work_date <= NVL(p_upto, TRUNC(SYSDATE)) ORDER BY work_date, id FOR UPDATE) LOOP
      l_amt := ROUND(t.hours * NVL(t.cost_rate, 0), 2);
      l_desc := 'عمالة ' || NOONA_HR_PKG.employee_name(t.employee_id) || ' ' || fq(t.hours) || ' ساعة ' || ds(t.work_date) || ' - مشروع ' || l_prj.code;
      IF l_amt > 0 THEN
        l_lines := NOONA_GL_PKG.t_lines();
        add_line(l_lines, acc('COST'), l_amt, 0, l_prj.cost_center_id, NULL, l_desc);
        add_line(l_lines, acc('LABOR_APPLIED'), 0, l_amt, NULL, NULL, l_desc);
        l_j := NOONA_ACE_PKG.post_source('PRJ_LABOR_POSTED', 'PROJECTS', c_ts, t.id, t.work_date, l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                         l_lines, NULL, NULL, 'PROJECTS');
      END IF;
      l_c := add_cost(p_project_id, t.wbs_id, 'LABOR', t.work_date, l_amt, t.hours, l_desc, NULL, c_ts, t.id);
      UPDATE prj_timesheet SET status_code = 'POSTED', approved_by = NOONA_CTX_PKG.current_user_name WHERE id = t.id;
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-PRJ-053', 'لا توجد ساعات عمل غير محملة', 'No pending timesheets');
    RETURN l_n;
  END post_timesheets;

  PROCEDURE reverse_cost(p_cost_id IN NUMBER, p_reason IN VARCHAR2) IS
    l prj_cost_line%ROWTYPE;
    l_j NUMBER;
  BEGIN
    guard('PRJ_COST_LINE.UPDATE');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-PRJ-043', 'اكتب سبب العكس', 'Reason is required');
    SELECT * INTO l FROM prj_cost_line WHERE id = p_cost_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'POSTED', 'NOONA-PRJ-044', 'التكلفة معكوسة سابقاً', 'Cost already reversed');
    NOONA_CORE_PKG.assert(l.source_entity_type IN (c_cost, c_ts), 'NOONA-PRJ-045',
                          'تكلفة المستخلصات والمواد تعكس من مستندها (إلغاء المستخلص أو مستند المخزون)', 'Reverse it from its source document');
    l_j := NOONA_ACE_PKG.reverse_source(l.source_entity_type, l.source_entity_id, TRUNC(SYSDATE), p_reason);
    UPDATE prj_cost_line SET status_code = 'REVERSED' WHERE id = p_cost_id;
    IF l.source_entity_type = c_ts THEN
      UPDATE prj_timesheet SET status_code = 'REJECTED' WHERE id = l.source_entity_id;
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-046', 'سطر التكلفة غير موجود', 'Cost line not found');
  END reverse_cost;

  -- ================================================================ العقود
  FUNCTION contract_value(p_contract_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(ROUND((contract_qty + variation_qty) * unit_rate, 2)), 0) INTO l FROM prj_boq_item WHERE contract_id = p_contract_id;
    IF l = 0 THEN
      SELECT NVL(current_value, original_value) INTO l FROM prj_contract WHERE id = p_contract_id;
    END IF;
    RETURN l;
  END contract_value;

  FUNCTION save_contract(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id    NUMBER := jn(l_o, 'id');
    l_prj   NUMBER := jn(l_o, 'project');
    l_type  VARCHAR2(30) := NVL(js(l_o, 'type'), 'MAIN_CONTRACT');
    l_cust  NUMBER := jn(l_o, 'customer');
    l_sup   NUMBER := jn(l_o, 'supplier');
    l_party NUMBER;
    l_no    VARCHAR2(50) := js(l_o, 'no');
    l_st    VARCHAR2(30);
    l_val   NUMBER := NVL(jn(l_o, 'value'), 0);
    l_pr    VARCHAR2(30) := js(l_o, 'pricing');
    l_ret   NUMBER := jn(l_o, 'ret');
    l_cap   NUMBER := jn(l_o, 'retCap');
    l_adv   NUMBER := jn(l_o, 'adv');
    l_rec   NUMBER := jn(l_o, 'advRec');
    l_from  DATE := d(js(l_o, 'start'));
    l_to    DATE := d(js(l_o, 'end'));
    l_dlp   NUMBER := jn(l_o, 'dlp');
    l_cur   VARCHAR2(3) := NOONA_GL_PKG.ledger_currency;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'PRJ_CONTRACT.CREATE' ELSE 'PRJ_CONTRACT.UPDATE' END);
    IF l_id IS NOT NULL THEN
      SELECT project_id, status_code INTO l_prj, l_st FROM prj_contract WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-PRJ-031', 'العقد معتمد؛ التعديل بأمر تغيير', 'Approved contract: use a variation order');
    END IF;
    assert_open(l_prj);
    NOONA_CORE_PKG.assert(l_type IN ('MAIN_CONTRACT', 'SUBCONTRACT', 'CONSULTANCY', 'SUPPLY', 'LABOR_ONLY', 'DESIGN_BUILD'), 'NOONA-PRJ-032',
                          'نوع عقد غير صالح', 'Invalid contract type');
    IF l_type = 'MAIN_CONTRACT' THEN
      IF l_cust IS NULL THEN
        SELECT customer_account_id INTO l_cust FROM prj_project WHERE id = l_prj;
      END IF;
      NOONA_CORE_PKG.assert(l_cust IS NOT NULL, 'NOONA-PRJ-033', 'اختر العميل (المالك) للعقد الرئيسي', 'Customer is required');
      l_party := NOONA_SAL_PKG.customer_party(l_cust);
      l_sup := NULL;
    ELSE
      NOONA_CORE_PKG.assert(l_sup IS NOT NULL, 'NOONA-PRJ-034', 'اختر المقاول (المورد) لعقد الباطن', 'Subcontractor is required');
      SELECT s.party_id INTO l_party FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id WHERE a.id = l_sup;
      l_cust := NULL;
    END IF;
    NOONA_CORE_PKG.assert(NVL(l_ret, 0) BETWEEN 0 AND 50 AND NVL(l_adv, 0) BETWEEN 0 AND 100 AND NVL(l_rec, 0) BETWEEN 0 AND 100, 'NOONA-PRJ-035', 'نسب المحتجز والدفعة المقدمة غير منطقية',
                          'Invalid retention or advance percentages');
    IF l_id IS NULL THEN
      IF l_no IS NULL THEN l_no := next_no('PRJ_CONTRACT', 'CT-'); END IF;
      INSERT INTO prj_contract (company_id, currency_code, exchange_rate, contract_no, project_id, contract_type, party_id, customer_account_id,
                                supplier_account_id, pricing_type, original_value, current_value, retention_pct, retention_cap_pct, advance_pct,
                                advance_recovery_pct, start_date, end_date, defects_liability_months, status_code)
      VALUES (company, l_cur, 1, l_no, l_prj, l_type, l_party, l_cust, l_sup, NVL(l_pr, 'REMEASURED'),
              l_val, l_val, l_ret, l_cap, l_adv, l_rec, l_from, l_to, l_dlp, 'DRAFT')
      RETURNING id INTO l_id;
    ELSE
      UPDATE prj_contract SET contract_no = NVL(l_no, contract_no), contract_type = l_type, party_id = l_party, customer_account_id = l_cust,
                              supplier_account_id = l_sup, pricing_type = NVL(l_pr, pricing_type), original_value = l_val,
                              current_value = l_val, retention_pct = l_ret, retention_cap_pct = l_cap, advance_pct = l_adv,
                              advance_recovery_pct = l_rec, start_date = l_from, end_date = l_to, defects_liability_months = l_dlp
       WHERE id = l_id;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-036', 'رقم العقد مستخدم', 'Contract number already used');
  END save_contract;

  FUNCTION save_boq(p_contract_id IN NUMBER, p_lines IN CLOB) RETURN NUMBER IS
    l_c    prj_contract%ROWTYPE := get_contract(p_contract_id);
    l_keep VARCHAR2(32767) := ',';
    l_n    NUMBER := 0;
    l_id   NUMBER;
    l_used NUMBER;
    l_tot  NUMBER;
  BEGIN
    guard('PRJ_CONTRACT.UPDATE');
    assert_open(l_c.project_id);
    FOR r IN (SELECT * FROM JSON_TABLE(p_lines, '$[*]' COLUMNS (id NUMBER PATH '$.id', code VARCHAR2(50) PATH '$.code',
                d VARCHAR2(2000) PATH '$.d', u NUMBER PATH '$.u', q NUMBER PATH '$.q', r NUMBER PATH '$.r', w NUMBER PATH '$.w'))) LOOP
      CONTINUE WHEN TRIM(r.code) IS NULL AND TRIM(r.d) IS NULL;
      NOONA_CORE_PKG.assert(TRIM(r.code) IS NOT NULL AND TRIM(r.d) IS NOT NULL, 'NOONA-PRJ-060', 'لكل بند رقم ووصف', 'Each item needs a code and description');
      NOONA_CORE_PKG.assert(NVL(r.q, 0) >= 0 AND NVL(r.r, 0) >= 0, 'NOONA-PRJ-061', 'الكمية والسعر لا يكونان سالبين', 'Quantity and rate cannot be negative');
      l_n := l_n + 1;
      IF r.id IS NOT NULL THEN
        SELECT COUNT(*) INTO l_used FROM prj_progress_claim_line WHERE boq_item_id = r.id;
        IF l_c.status_code <> 'DRAFT' THEN
          -- بعد اعتماد العقد: يعدل الوصف والبند فقط؛ الكميات والأسعار بأمر تغيير
          UPDATE prj_boq_item SET description_ar = TRIM(r.d), wbs_id = r.w, uom_id = NVL(r.u, uom_id), sort_order = l_n
           WHERE id = r.id AND contract_id = p_contract_id;
        ELSE
          UPDATE prj_boq_item SET item_code = TRIM(r.code), description_ar = TRIM(r.d), uom_id = r.u, contract_qty = NVL(r.q, 0),
                                  unit_rate = NVL(r.r, 0), amount = ROUND(NVL(r.q, 0) * NVL(r.r, 0), 2), wbs_id = r.w, sort_order = l_n
           WHERE id = r.id AND contract_id = p_contract_id;
        END IF;
        l_id := r.id;
      ELSE
        NOONA_CORE_PKG.assert(l_c.status_code = 'DRAFT', 'NOONA-PRJ-062', 'إضافة بند لعقد معتمد تكون بأمر تغيير',
                              'New items on an approved contract need a variation order');
        INSERT INTO prj_boq_item (company_id, contract_id, wbs_id, item_code, description_ar, uom_id, contract_qty, unit_rate, amount, sort_order)
        VALUES (company, p_contract_id, r.w, TRIM(r.code), TRIM(r.d), r.u, NVL(r.q, 0), NVL(r.r, 0), ROUND(NVL(r.q, 0) * NVL(r.r, 0), 2), l_n)
        RETURNING id INTO l_id;
      END IF;
      l_keep := l_keep || l_id || ',';
    END LOOP;
    FOR x IN (SELECT id FROM prj_boq_item WHERE contract_id = p_contract_id AND INSTR(l_keep, ',' || id || ',') = 0) LOOP
      SELECT COUNT(*) INTO l_used FROM prj_progress_claim_line WHERE boq_item_id = x.id;
      NOONA_CORE_PKG.assert(l_used = 0 AND l_c.status_code = 'DRAFT', 'NOONA-PRJ-063', 'لا يحذف بند ورد في مستخلص أو في عقد معتمد',
                            'Item is used in a claim or the contract is approved');
      DELETE FROM prj_boq_item WHERE id = x.id;
    END LOOP;
    IF l_c.status_code = 'DRAFT' THEN
      SELECT NVL(SUM(amount), 0) INTO l_tot FROM prj_boq_item WHERE contract_id = p_contract_id;
      IF l_tot > 0 THEN
        UPDATE prj_contract SET original_value = l_tot, current_value = l_tot WHERE id = p_contract_id;
      END IF;
    END IF;
    RETURN l_n;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-064', 'رقم بند مكرر في جدول الكميات', 'Duplicate BOQ item code');
  END save_boq;

  FUNCTION boq_json(p_contract_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE b.id, 'code' VALUE b.item_code, 'd' VALUE b.description_ar, 'u' VALUE b.uom_id,
             'q' VALUE b.contract_qty, 'vq' VALUE b.variation_qty, 'r' VALUE b.unit_rate, 'w' VALUE b.wbs_id, 'x' VALUE b.executed_qty)
             ORDER BY b.sort_order, b.item_code RETURNING CLOB)
      INTO l FROM prj_boq_item b WHERE b.contract_id = p_contract_id;
    RETURN NVL(l, TO_CLOB('[]'));
  END boq_json;

  PROCEDURE activate_contract(p_contract_id IN NUMBER) IS
    l_c   prj_contract%ROWTYPE := get_contract(p_contract_id);
    l_val NUMBER;
  BEGIN
    guard('PRJ_CONTRACT.APPROVE');
    NOONA_CORE_PKG.assert(l_c.status_code = 'DRAFT', 'NOONA-PRJ-031', 'العقد معتمد سابقاً', 'Contract already approved');
    l_val := contract_value(p_contract_id);
    NOONA_CORE_PKG.assert(l_val > 0, 'NOONA-PRJ-037', 'أدخل جدول الكميات أو قيمة العقد قبل الاعتماد', 'Enter the BOQ or the contract value first');
    UPDATE prj_contract SET status_code = 'ACTIVE', original_value = l_val, current_value = l_val WHERE id = p_contract_id;
    IF l_c.contract_type = 'MAIN_CONTRACT' THEN
      UPDATE prj_project SET contract_value = (SELECT SUM(current_value) FROM prj_contract WHERE project_id = l_c.project_id
                                                 AND contract_type = 'MAIN_CONTRACT' AND status_code NOT IN ('DRAFT', 'TERMINATED')),
                             customer_account_id = NVL(customer_account_id, l_c.customer_account_id),
                             status_code = CASE WHEN status_code = 'PLANNED' THEN 'APPROVED' ELSE status_code END
       WHERE id = l_c.project_id;
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PRJ_CONTRACT', p_contract_id, 'APPROVE', 'SUCCESS');
  END activate_contract;

  PROCEDURE close_contract(p_contract_id IN NUMBER) IS
    l_n NUMBER;
  BEGIN
    guard('PRJ_CONTRACT.UPDATE');
    SELECT COUNT(*) INTO l_n FROM prj_progress_claim WHERE contract_id = p_contract_id AND status_code = 'DRAFT';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRJ-038', 'اعتمد أو ألغ المستخلصات المسودة أولاً', 'Approve or cancel draft claims first');
    UPDATE prj_contract SET status_code = 'COMPLETED' WHERE id = p_contract_id AND company_id = company AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRJ-039', 'العقد غير نشط', 'Contract is not active');
  END close_contract;

  FUNCTION save_variation(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_c   prj_contract%ROWTYPE := get_contract(jn(l_o, 'contract'));
    l_id  NUMBER;
    l_tot NUMBER := 0;
    l_n   NUMBER := 0;
    l_r   NUMBER;
    l_no  VARCHAR2(50);
    l_dt  DATE := NVL(d(js(l_o, 'date')), TRUNC(SYSDATE));
    l_vt  VARCHAR2(30) := NVL(js(l_o, 'type'), 'ADDITION');
    l_ds  VARCHAR2(4000) := js(l_o, 'desc');
    l_dy  NUMBER := jn(l_o, 'days');
    l_ref VARCHAR2(100) := js(l_o, 'ref');
  BEGIN
    guard('PRJ_CONTRACT.UPDATE');
    NOONA_CORE_PKG.assert(l_c.status_code = 'ACTIVE', 'NOONA-PRJ-070', 'أوامر التغيير على العقود المعتمدة فقط', 'Variations need an approved contract');
    NOONA_CORE_PKG.assert(l_ds IS NOT NULL, 'NOONA-PRJ-071', 'اكتب وصف أمر التغيير', 'Description is required');
    l_no := next_no('PRJ_VARIATION', 'VO-');
    INSERT INTO prj_variation_order (company_id, doc_no, doc_date, contract_id, variation_type, description, amount, time_impact_days,
                                     client_approval_ref, status_code)
    VALUES (company, l_no, l_dt, l_c.id, l_vt, l_ds, 0, l_dy, l_ref, 'DRAFT')
    RETURNING id INTO l_id;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (b NUMBER PATH '$.b', code VARCHAR2(50) PATH '$.code',
                d VARCHAR2(2000) PATH '$.d', q NUMBER PATH '$.q', r NUMBER PATH '$.r'))) LOOP
      CONTINUE WHEN NVL(r.q, 0) = 0;
      IF r.b IS NOT NULL THEN
        SELECT NVL(r.r, unit_rate) INTO l_r FROM prj_boq_item WHERE id = r.b AND contract_id = l_c.id;
      ELSE
        NOONA_CORE_PKG.assert(TRIM(r.code) IS NOT NULL AND TRIM(r.d) IS NOT NULL AND r.q > 0, 'NOONA-PRJ-072',
                              'البند الجديد يحتاج رقماً ووصفاً وكمية موجبة', 'A new item needs a code, description and positive quantity');
        l_r := NVL(r.r, 0);
      END IF;
      INSERT INTO prj_variation_line (company_id, variation_id, boq_item_id, new_item_code, description, qty_change, unit_rate, amount)
      VALUES (company, l_id, r.b, TRIM(r.code), TRIM(r.d), r.q, l_r, ROUND(r.q * l_r, 2));
      l_tot := l_tot + ROUND(r.q * l_r, 2);
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0 OR NVL(l_dy, 0) > 0, 'NOONA-PRJ-073', 'أدخل بنداً أو أثراً زمنياً', 'Add a line or a time impact');
    UPDATE prj_variation_order SET amount = l_tot WHERE id = l_id;
    RETURN l_id;
  END save_variation;

  PROCEDURE approve_variation(p_variation_id IN NUMBER) IS
    l_v   prj_variation_order%ROWTYPE;
    l_c   prj_contract%ROWTYPE;
    l_ord NUMBER;
    l_val NUMBER;
  BEGIN
    guard('PRJ_CONTRACT.APPROVE');
    SELECT * INTO l_v FROM prj_variation_order WHERE id = p_variation_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_v.status_code = 'DRAFT', 'NOONA-PRJ-074', 'أمر التغيير معتمد أو ملغى', 'Variation already processed');
    l_c := get_contract(l_v.contract_id);
    FOR r IN (SELECT * FROM prj_variation_line WHERE variation_id = p_variation_id) LOOP
      IF r.boq_item_id IS NOT NULL THEN
        UPDATE prj_boq_item SET variation_qty = variation_qty + r.qty_change WHERE id = r.boq_item_id;
      ELSE
        SELECT NVL(MAX(sort_order), 0) + 1 INTO l_ord FROM prj_boq_item WHERE contract_id = l_c.id;
        INSERT INTO prj_boq_item (company_id, contract_id, item_code, description_ar, contract_qty, unit_rate, amount, variation_qty, sort_order)
        VALUES (company, l_c.id, r.new_item_code, r.description, 0, r.unit_rate, 0, r.qty_change, l_ord)
        RETURNING id INTO l_ord;
        UPDATE prj_variation_line SET boq_item_id = l_ord WHERE id = r.id;
      END IF;
    END LOOP;
    l_val := contract_value(l_c.id);
    UPDATE prj_contract SET current_value = l_val,
                            end_date = CASE WHEN end_date IS NOT NULL THEN end_date + NVL(l_v.time_impact_days, 0) END
     WHERE id = l_c.id;
    UPDATE prj_variation_order SET status_code = 'APPROVED' WHERE id = p_variation_id;
    IF l_c.contract_type = 'MAIN_CONTRACT' THEN
      UPDATE prj_project SET contract_value = (SELECT SUM(current_value) FROM prj_contract WHERE project_id = l_c.project_id
                                                 AND contract_type = 'MAIN_CONTRACT' AND status_code NOT IN ('DRAFT', 'TERMINATED')),
                             planned_end = CASE WHEN planned_end IS NOT NULL THEN planned_end + NVL(l_v.time_impact_days, 0) END
       WHERE id = l_c.project_id;
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-075', 'أمر التغيير غير موجود', 'Variation not found');
  END approve_variation;

  -- ================================================================ المستخلصات
  FUNCTION retention_held(p_contract_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE claim_kind WHEN 'PROGRESS' THEN retention_amount WHEN 'RETENTION_RELEASE' THEN -current_gross ELSE 0 END), 0)
      INTO l FROM prj_progress_claim WHERE contract_id = p_contract_id AND status_code IN ('APPROVED', 'PAID');
    RETURN l;
  END retention_held;

  FUNCTION advance_open(p_contract_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE claim_kind WHEN 'ADVANCE' THEN current_gross WHEN 'PROGRESS' THEN -advance_recovery ELSE 0 END), 0)
      INTO l FROM prj_progress_claim WHERE contract_id = p_contract_id AND status_code IN ('APPROVED', 'PAID');
    RETURN l;
  END advance_open;

  -- يعيد حساب المستخلص من كمياته ونسب العقد
  PROCEDURE recalc(p_claim_id NUMBER) IS
    l_cl    prj_progress_claim%ROWTYPE;
    l_c     prj_contract%ROWTYPE;
    l_gross NUMBER;
    l_prev  NUMBER;
    l_cur   NUMBER;
    l_ret   NUMBER := 0;
    l_rec   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_held  NUMBER;
    l_cap   NUMBER;
    l_rate  NUMBER := NOONA_INV_PKG.tax_rate(vat_code);
  BEGIN
    SELECT * INTO l_cl FROM prj_progress_claim WHERE id = p_claim_id;
    l_c := get_contract(l_cl.contract_id);
    IF l_cl.claim_kind = 'PROGRESS' THEN
      UPDATE prj_progress_claim_line SET current_qty = qty_to_date - previous_qty, amount_to_date = ROUND(qty_to_date * unit_rate, 2),
                                         current_amount = ROUND(qty_to_date * unit_rate, 2) - ROUND(previous_qty * unit_rate, 2)
       WHERE claim_id = p_claim_id;
      SELECT NVL(SUM(amount_to_date), 0) INTO l_gross FROM prj_progress_claim_line WHERE claim_id = p_claim_id;
      SELECT NVL(SUM(current_gross), 0) INTO l_prev FROM prj_progress_claim
       WHERE contract_id = l_cl.contract_id AND claim_kind = 'PROGRESS' AND status_code IN ('APPROVED', 'PAID') AND id <> p_claim_id;
      l_cur := l_gross - l_prev;
      -- المحتجز بنسبته حتى سقفه من قيمة العقد الحالية
      l_ret := ROUND(l_cur * NVL(l_c.retention_pct, 0) / 100, 2);
      IF l_c.retention_cap_pct IS NOT NULL THEN
        SELECT NVL(SUM(retention_amount), 0) INTO l_held FROM prj_progress_claim
         WHERE contract_id = l_cl.contract_id AND claim_kind = 'PROGRESS' AND status_code IN ('APPROVED', 'PAID') AND id <> p_claim_id;
        l_cap := ROUND(contract_value(l_c.id) * l_c.retention_cap_pct / 100, 2);
        l_ret := GREATEST(LEAST(l_ret, l_cap - l_held), 0);
      END IF;
      -- استرداد الدفعة المقدمة بنسبته من قيمة الفترة دون تجاوز المتبقي منها
      l_rec := GREATEST(LEAST(ROUND(l_cur * NVL(l_c.advance_recovery_pct, 0) / 100, 2), advance_open(l_c.id)), 0);
      l_tax := ROUND((l_cur - l_rec - l_cl.other_deductions) * l_rate / 100, 2);
      UPDATE prj_progress_claim SET gross_to_date = l_gross, previous_certified = l_prev, current_gross = l_cur, retention_amount = l_ret,
                                    advance_recovery = l_rec, tax_amount = l_tax,
                                    net_payable = l_cur - l_ret - l_rec - other_deductions + l_tax
       WHERE id = p_claim_id;
    ELSIF l_cl.claim_kind = 'ADVANCE' THEN
      l_tax := ROUND(l_cl.current_gross * l_rate / 100, 2);
      UPDATE prj_progress_claim SET gross_to_date = current_gross, tax_amount = l_tax, net_payable = current_gross + l_tax,
                                    retention_amount = 0, advance_recovery = 0, other_deductions = 0 WHERE id = p_claim_id;
    ELSE
      -- الإفراج عن المحتجز: ضريبته احتسبت مع المستخلصات
      UPDATE prj_progress_claim SET gross_to_date = current_gross, tax_amount = 0, net_payable = current_gross,
                                    retention_amount = 0, advance_recovery = 0, other_deductions = 0 WHERE id = p_claim_id;
    END IF;
  END recalc;

  FUNCTION new_claim(p_contract_id IN NUMBER, p_kind IN VARCHAR2 DEFAULT 'PROGRESS', p_from IN DATE DEFAULT NULL,
                     p_to IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_c    prj_contract%ROWTYPE := get_contract(p_contract_id);
    l_id   NUMBER;
    l_no   NUMBER;
    l_n    NUMBER;
    l_from DATE;
    l_amt  NUMBER := 0;
  BEGIN
    guard('PRJ_PROGRESS_CLAIM.CREATE');
    assert_open(l_c.project_id);
    NOONA_CORE_PKG.assert(l_c.status_code = 'ACTIVE', 'NOONA-PRJ-080', 'المستخلصات على العقود المعتمدة (النشطة) فقط', 'The contract must be active');
    NOONA_CORE_PKG.assert(p_kind IN ('PROGRESS', 'ADVANCE', 'RETENTION_RELEASE'), 'NOONA-PRJ-081', 'نوع مستخلص غير صالح', 'Invalid claim kind');
    SELECT COUNT(*) INTO l_n FROM prj_progress_claim WHERE contract_id = p_contract_id AND status_code = 'DRAFT';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRJ-082', 'يوجد مستخلص مسودة لهذا العقد؛ اعتمده أو ألغه أولاً', 'A draft claim already exists');
    IF p_kind = 'ADVANCE' THEN
      SELECT COUNT(*) INTO l_n FROM prj_progress_claim WHERE contract_id = p_contract_id AND claim_kind = 'ADVANCE' AND status_code IN ('APPROVED', 'PAID');
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRJ-083', 'صرفت الدفعة المقدمة لهذا العقد', 'Advance already issued');
      l_amt := ROUND(contract_value(p_contract_id) * NVL(l_c.advance_pct, 0) / 100, 2);
      NOONA_CORE_PKG.assert(l_amt > 0, 'NOONA-PRJ-084', 'حدد نسبة الدفعة المقدمة في العقد', 'Set the advance percentage on the contract');
    ELSIF p_kind = 'RETENTION_RELEASE' THEN
      l_amt := retention_held(p_contract_id);
      NOONA_CORE_PKG.assert(l_amt > 0, 'NOONA-PRJ-085', 'لا يوجد محتجز قائم على العقد', 'No retention held');
    END IF;
    -- الرقم التسلسلي لا يعاد استخدامه بعد الإلغاء؛ بداية الفترة بعد آخر مستخلص قائم
    SELECT NVL(MAX(claim_no), 0) + 1, MAX(CASE WHEN status_code <> 'CANCELLED' THEN period_to END) + 1 INTO l_no, l_from
      FROM prj_progress_claim WHERE contract_id = p_contract_id;
    INSERT INTO prj_progress_claim (company_id, doc_no, doc_date, currency_code, exchange_rate, contract_id, claim_no, claim_direction, claim_kind,
                                    period_from, period_to, current_gross, status_code)
    VALUES (company, 'DRAFT-' || RAWTOHEX(SYS_GUID()), TRUNC(SYSDATE), l_c.currency_code, 1, p_contract_id, l_no,
            CASE WHEN l_c.contract_type = 'MAIN_CONTRACT' THEN 'RECEIVABLE' ELSE 'PAYABLE' END, p_kind,
            NVL(p_from, NVL(l_from, NVL(l_c.start_date, TRUNC(SYSDATE, 'MM')))), NVL(p_to, TRUNC(SYSDATE)), l_amt, 'DRAFT')
    RETURNING id INTO l_id;
    UPDATE prj_progress_claim SET doc_no = 'مسودة-' || l_id WHERE id = l_id;
    IF p_kind = 'PROGRESS' THEN
      -- الكميات السابقة من آخر مستخلص معتمد
      INSERT INTO prj_progress_claim_line (company_id, claim_id, boq_item_id, qty_to_date, previous_qty, current_qty, unit_rate, amount_to_date,
                                           current_amount)
      SELECT company, l_id, b.id, b.executed_qty, b.executed_qty, 0, b.unit_rate, ROUND(b.executed_qty * b.unit_rate, 2), 0
        FROM prj_boq_item b WHERE b.contract_id = p_contract_id;
    END IF;
    recalc(l_id);
    RETURN l_id;
  END new_claim;

  PROCEDURE save_claim(p_doc IN CLOB) IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id  NUMBER := jn(l_o, 'id');
    l_cl  prj_progress_claim%ROWTYPE;
    l_max NUMBER;
    l_prv NUMBER;
    l_cd  VARCHAR2(50);
    l_f   DATE := d(js(l_o, 'from'));
    l_t   DATE := d(js(l_o, 'to'));
    l_dt  DATE := d(js(l_o, 'date'));
    l_oth NUMBER := jn(l_o, 'other');
    l_by  VARCHAR2(200) := js(l_o, 'certifiedBy');
  BEGIN
    guard('PRJ_PROGRESS_CLAIM.UPDATE');
    SELECT * INTO l_cl FROM prj_progress_claim WHERE id = l_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_cl.status_code = 'DRAFT', 'NOONA-PRJ-086', 'المستخلص معتمد؛ لا يعدل', 'Claim is not a draft');
    NOONA_CORE_PKG.assert(NVL(l_oth, 0) >= 0 AND (l_t IS NULL OR l_f IS NULL OR l_t >= l_f), 'NOONA-PRJ-087',
                          'الخصومات لا تكون سالبة ونهاية الفترة بعد بدايتها', 'Invalid deductions or period');
    UPDATE prj_progress_claim SET period_from = NVL(l_f, period_from), period_to = NVL(l_t, period_to), doc_date = NVL(l_dt, doc_date),
                                  other_deductions = NVL(l_oth, other_deductions), certified_by = NVL(l_by, certified_by)
     WHERE id = l_id;
    IF l_cl.claim_kind = 'PROGRESS' THEN
      FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (b NUMBER PATH '$.b', q NUMBER PATH '$.q'))) LOOP
        SELECT b.contract_qty + b.variation_qty, l.previous_qty, b.item_code INTO l_max, l_prv, l_cd
          FROM prj_progress_claim_line l JOIN prj_boq_item b ON b.id = l.boq_item_id
         WHERE l.claim_id = l_id AND l.boq_item_id = r.b;
        NOONA_CORE_PKG.assert(NVL(r.q, 0) >= l_prv, 'NOONA-PRJ-088', 'البند ' || l_cd || ': الكمية التراكمية أقل من المعتمد سابقاً',
                              'Cumulative quantity is below the previously certified');
        NOONA_CORE_PKG.assert(NVL(r.q, 0) <= l_max * 1.0001 OR l_max = 0, 'NOONA-PRJ-089',
                              'البند ' || l_cd || ': الكمية التراكمية (' || fq(r.q) || ') تتجاوز كمية العقد وأوامر التغيير (' || fq(l_max) || ')',
                              'Quantity exceeds the contract quantity; issue a variation order');
        UPDATE prj_progress_claim_line SET qty_to_date = NVL(r.q, 0) WHERE claim_id = l_id AND boq_item_id = r.b;
      END LOOP;
    ELSIF jn(l_o, 'amount') IS NOT NULL THEN
      l_max := ROUND(jn(l_o, 'amount'), 2);
      NOONA_CORE_PKG.assert(jn(l_o, 'amount') > 0 AND (l_cl.claim_kind <> 'RETENTION_RELEASE' OR jn(l_o, 'amount') <= retention_held(l_cl.contract_id)),
                            'NOONA-PRJ-090', 'المبلغ يتجاوز المتاح', 'Amount exceeds what is available');
      UPDATE prj_progress_claim SET current_gross = l_max WHERE id = l_id;
    END IF;
    recalc(l_id);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-091', 'المستخلص أو البند غير موجود', 'Claim or item not found');
  END save_claim;

  FUNCTION claim_json(p_claim_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_OBJECT('id' VALUE c.id, 'no' VALUE c.doc_no, 'claimNo' VALUE c.claim_no, 'kind' VALUE c.claim_kind, 'dir' VALUE c.claim_direction,
             'status' VALUE c.status_code, 'from' VALUE TO_CHAR(c.period_from, 'YYYY-MM-DD'), 'to' VALUE TO_CHAR(c.period_to, 'YYYY-MM-DD'),
             'gross' VALUE c.gross_to_date, 'prev' VALUE c.previous_certified, 'cur' VALUE c.current_gross, 'ret' VALUE c.retention_amount,
             'rec' VALUE c.advance_recovery, 'other' VALUE c.other_deductions, 'tax' VALUE c.tax_amount, 'net' VALUE c.net_payable,
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('b' VALUE b.id, 'code' VALUE b.item_code, 'd' VALUE b.description_ar,
                              'max' VALUE b.contract_qty + b.variation_qty, 'prev' VALUE l.previous_qty, 'q' VALUE l.qty_to_date, 'r' VALUE l.unit_rate,
                              'cur' VALUE l.current_amount) ORDER BY b.sort_order, b.item_code RETURNING CLOB)
                              FROM prj_progress_claim_line l JOIN prj_boq_item b ON b.id = l.boq_item_id WHERE l.claim_id = c.id)
             RETURNING CLOB)
      INTO l FROM prj_progress_claim c WHERE c.id = p_claim_id AND c.company_id = company;
    RETURN l;
  END claim_json;

  PROCEDURE approve_claim(p_claim_id IN NUMBER) IS
    l_cl    prj_progress_claim%ROWTYPE;
    l_c     prj_contract%ROWTYPE;
    l_p     prj_project%ROWTYPE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_desc  VARCHAR2(1000);
    l_party VARCHAR2(400);
    l_ar    NUMBER;
    l_ap    NUMBER;
    l_tax   NUMBER;
    l_j     NUMBER;
    l_ev    NUMBER;
    l_x     NUMBER;
    l_due   NUMBER;
    l_cost  NUMBER;
  BEGIN
    guard('PRJ_PROGRESS_CLAIM.APPROVE');
    SELECT * INTO l_cl FROM prj_progress_claim WHERE id = p_claim_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_cl.status_code = 'DRAFT', 'NOONA-PRJ-086', 'المستخلص معتمد أو ملغى', 'Claim is not a draft');
    recalc(p_claim_id);
    SELECT * INTO l_cl FROM prj_progress_claim WHERE id = p_claim_id;
    l_c := get_contract(l_cl.contract_id);
    l_p := get_project(l_c.project_id);
    NOONA_CORE_PKG.assert(l_cl.current_gross > 0 AND l_cl.net_payable > 0, 'NOONA-PRJ-092', 'لا توجد أعمال جديدة في المستخلص', 'Nothing to certify');
    l_cl.doc_no := next_no(CASE WHEN l_cl.claim_direction = 'RECEIVABLE' THEN 'PRJ_CLAIM_AR' ELSE 'PRJ_CLAIM_AP' END,
                           CASE WHEN l_cl.claim_direction = 'RECEIVABLE' THEN 'IPC-' ELSE 'SPC-' END);
    UPDATE prj_progress_claim SET doc_no = l_cl.doc_no WHERE id = p_claim_id;
    l_tax := CASE WHEN l_cl.tax_amount > 0 THEN NOONA_INV_PKG.tax_account(vat_code, CASE WHEN l_cl.claim_direction = 'RECEIVABLE' THEN 'SALE' ELSE 'PURCHASE' END) END;
    IF l_cl.claim_direction = 'RECEIVABLE' THEN
      l_party := NOONA_SAL_PKG.customer_label(l_c.customer_account_id);
      l_desc := kind_label(l_cl.claim_kind) || ' رقم ' || l_cl.claim_no || ' (' || l_cl.doc_no || ') - ' || l_c.contract_no || ' - ' || l_p.name_ar;
      SELECT NVL(receivable_account_id, NOONA_INV_PKG.acc_id('1103')) INTO l_ar FROM ar_customer_account WHERE id = l_c.customer_account_id;
      add_line(l_lines, l_ar, l_cl.net_payable, 0, NULL, l_c.party_id, l_desc);
      IF l_cl.claim_kind = 'PROGRESS' THEN
        add_line(l_lines, acc('RET_REC'), l_cl.retention_amount, 0, NULL, l_c.party_id, 'محتجز ' || l_desc);
        add_line(l_lines, acc('ADV_RCVD'), l_cl.advance_recovery, 0, NULL, l_c.party_id, 'استرداد دفعة مقدمة ' || l_desc);
        add_line(l_lines, acc('REVENUE'), 0, l_cl.current_gross - l_cl.other_deductions, l_p.cost_center_id, NULL, l_desc);
      ELSIF l_cl.claim_kind = 'ADVANCE' THEN
        add_line(l_lines, acc('ADV_RCVD'), 0, l_cl.current_gross, NULL, l_c.party_id, l_desc);
      ELSE
        add_line(l_lines, acc('RET_REC'), 0, l_cl.current_gross, NULL, l_c.party_id, l_desc);
      END IF;
      add_line(l_lines, l_tax, 0, l_cl.tax_amount, NULL, NULL, 'ضريبة مخرجات ' || l_cl.doc_no);
      l_j := NOONA_ACE_PKG.post_source('PRJ_CLAIM_RECEIVABLE', 'PROJECTS', c_claim, p_claim_id, l_cl.doc_date, l_desc, l_cl.currency_code, 1,
                                       l_lines, l_cl.doc_no, NULL, 'PROJECTS');
      SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
      SELECT NVL(MAX(t.due_days), 0) INTO l_due FROM ar_customer_account a LEFT JOIN ref_payment_term t ON t.id = a.payment_term_id
       WHERE a.id = l_c.customer_account_id;
      INSERT INTO ar_open_item (company_id, source_entity_type, source_entity_id, currency_code, exchange_rate, customer_account_id, item_type,
                                doc_no, doc_date, due_date, installment_no, original_amount, open_amount, original_func, open_func, tax_amount,
                                gl_journal_id, status_code)
      VALUES (company, c_claim, p_claim_id, l_cl.currency_code, 1, l_c.customer_account_id, 'INVOICE', l_cl.doc_no, l_cl.doc_date,
              l_cl.doc_date + l_due, 1, l_cl.net_payable, l_cl.net_payable, l_cl.net_payable, l_cl.net_payable, l_cl.tax_amount, l_j, 'OPEN');
    ELSE
      l_party := NOONA_PUR_PKG.supplier_label(l_c.supplier_account_id);
      l_desc := kind_label(l_cl.claim_kind) || ' مقاول ' || l_party || ' رقم ' || l_cl.claim_no || ' (' || l_cl.doc_no || ') - ' || l_c.contract_no
             || ' - ' || l_p.name_ar;
      SELECT NVL(payable_account_id, NOONA_INV_PKG.acc_id('2101')) INTO l_ap FROM ap_supplier_account WHERE id = l_c.supplier_account_id;
      IF l_cl.claim_kind = 'PROGRESS' THEN
        l_cost := l_cl.current_gross - l_cl.other_deductions;
        add_line(l_lines, acc('COST'), l_cost, 0, l_p.cost_center_id, NULL, l_desc);
        add_line(l_lines, acc('RET_PAY'), 0, l_cl.retention_amount, NULL, l_c.party_id, 'محتجز ' || l_desc);
        add_line(l_lines, acc('ADV_PAID'), 0, l_cl.advance_recovery, NULL, l_c.party_id, 'استرداد دفعة مقدمة ' || l_desc);
      ELSIF l_cl.claim_kind = 'ADVANCE' THEN
        add_line(l_lines, acc('ADV_PAID'), l_cl.current_gross, 0, NULL, l_c.party_id, l_desc);
      ELSE
        add_line(l_lines, acc('RET_PAY'), l_cl.current_gross, 0, NULL, l_c.party_id, l_desc);
      END IF;
      add_line(l_lines, l_tax, l_cl.tax_amount, 0, NULL, NULL, 'ضريبة مدخلات ' || l_cl.doc_no);
      add_line(l_lines, l_ap, 0, l_cl.net_payable, NULL, l_c.party_id, l_desc);
      l_j := NOONA_ACE_PKG.post_source('PRJ_CLAIM_PAYABLE', 'PROJECTS', c_claim, p_claim_id, l_cl.doc_date, l_desc, l_cl.currency_code, 1,
                                       l_lines, l_cl.doc_no, NULL, 'PROJECTS');
      SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
      SELECT NVL(MAX(t.due_days), 0) INTO l_due FROM ap_supplier_account a LEFT JOIN ref_payment_term t ON t.id = a.payment_term_id
       WHERE a.id = l_c.supplier_account_id;
      INSERT INTO ap_open_item (company_id, currency_code, exchange_rate, supplier_account_id, item_type, doc_no, due_date, installment_no,
                                original_amount, open_amount, original_func, open_func, status_code)
      VALUES (company, l_cl.currency_code, 1, l_c.supplier_account_id, 'INVOICE', l_cl.doc_no, l_cl.doc_date + l_due, 1,
              l_cl.net_payable, l_cl.net_payable, l_cl.net_payable, l_cl.net_payable, 'OPEN');
      IF l_cl.claim_kind = 'PROGRESS' THEN
        l_x := add_cost(l_p.id, default_wbs(l_p.id), 'SUBCONTRACT', l_cl.doc_date, l_cost, NULL, l_desc, l_cl.doc_no, c_claim, p_claim_id);
      END IF;
    END IF;
    -- الكميات المنفذة حتى تاريخه
    IF l_cl.claim_kind = 'PROGRESS' THEN
      FOR r IN (SELECT boq_item_id, qty_to_date FROM prj_progress_claim_line WHERE claim_id = p_claim_id) LOOP
        UPDATE prj_boq_item SET executed_qty = r.qty_to_date WHERE id = r.boq_item_id;
      END LOOP;
    END IF;
    UPDATE prj_progress_claim SET status_code = 'APPROVED', accounting_event_id = l_ev, posted_at = SYSTIMESTAMP,
                                  posted_by = NOONA_CTX_PKG.current_user_name, certified_by = NVL(certified_by, NOONA_CTX_PKG.current_user_name)
     WHERE id = p_claim_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_claim, p_claim_id, 'APPROVE', 'SUCCESS');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-091', 'المستخلص غير موجود', 'Claim not found');
  END approve_claim;

  PROCEDURE cancel_claim(p_claim_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_cl   prj_progress_claim%ROWTYPE;
    l_c    prj_contract%ROWTYPE;
    l_last NUMBER;
    l_open NUMBER;
    l_orig NUMBER;
    l_j    NUMBER;
  BEGIN
    guard('PRJ_PROGRESS_CLAIM.CANCEL');
    SELECT * INTO l_cl FROM prj_progress_claim WHERE id = p_claim_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_cl.status_code IN ('DRAFT', 'APPROVED'), 'NOONA-PRJ-093', 'المستخلص ملغى أو مسدد', 'Claim cannot be cancelled');
    IF l_cl.status_code = 'APPROVED' THEN
      NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-PRJ-094', 'اكتب سبب إلغاء المستخلص', 'Reason is required');
      l_c := get_contract(l_cl.contract_id);
      SELECT MAX(claim_no) INTO l_last FROM prj_progress_claim WHERE contract_id = l_cl.contract_id AND status_code IN ('APPROVED', 'PAID', 'DRAFT');
      NOONA_CORE_PKG.assert(l_last = l_cl.claim_no, 'NOONA-PRJ-095', 'يلغى آخر مستخلص للعقد أولاً', 'Cancel the latest claim first');
      IF l_cl.claim_direction = 'RECEIVABLE' THEN
        SELECT NVL(SUM(open_amount), 0), NVL(SUM(original_amount), 0) INTO l_open, l_orig FROM ar_open_item
         WHERE source_entity_type = c_claim AND source_entity_id = p_claim_id;
      ELSE
        SELECT NVL(SUM(open_amount), 0), NVL(SUM(original_amount), 0) INTO l_open, l_orig FROM ap_open_item
         WHERE supplier_account_id = l_c.supplier_account_id AND doc_no = l_cl.doc_no AND item_type = 'INVOICE';
      END IF;
      NOONA_CORE_PKG.assert(l_open = l_orig, 'NOONA-PRJ-096', 'حصل أو سدد جزء من المستخلص؛ اعكس التحصيل أو السداد أولاً',
                            'The claim is partly settled; reverse the receipt or payment first');
      l_j := NOONA_ACE_PKG.reverse_source(c_claim, p_claim_id, TRUNC(SYSDATE), p_reason);
      IF l_cl.claim_direction = 'RECEIVABLE' THEN
        UPDATE ar_open_item SET open_amount = 0, open_func = 0, status_code = 'CANCELLED' WHERE source_entity_type = c_claim AND source_entity_id = p_claim_id;
      ELSE
        UPDATE ap_open_item SET open_amount = 0, open_func = 0, status_code = 'CANCELLED'
         WHERE supplier_account_id = l_c.supplier_account_id AND doc_no = l_cl.doc_no AND item_type = 'INVOICE';
        UPDATE prj_cost_line SET status_code = 'REVERSED' WHERE source_entity_type = c_claim AND source_entity_id = p_claim_id;
      END IF;
      IF l_cl.claim_kind = 'PROGRESS' THEN
        FOR r IN (SELECT boq_item_id, previous_qty FROM prj_progress_claim_line WHERE claim_id = p_claim_id) LOOP
          UPDATE prj_boq_item SET executed_qty = r.previous_qty WHERE id = r.boq_item_id;
        END LOOP;
      END IF;
    END IF;
    UPDATE prj_progress_claim SET status_code = 'CANCELLED' WHERE id = p_claim_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_claim, p_claim_id, 'CANCEL', 'SUCCESS', p_new_values => JSON_OBJECT('reason' VALUE p_reason));
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-091', 'المستخلص غير موجود', 'Claim not found');
  END cancel_claim;

  -- ================================================================ شروط الشاشات
  FUNCTION contract_status(p_contract_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM prj_contract WHERE id = p_contract_id AND company_id = company;
    RETURN l;
  END contract_status;

  FUNCTION claim_status(p_claim_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM prj_progress_claim WHERE id = p_claim_id AND company_id = company;
    RETURN l;
  END claim_status;

  FUNCTION has_property(p_project_id IN NUMBER) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM re_property WHERE project_id = p_project_id AND ROWNUM = 1;
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END has_property;

  FUNCTION draft_variations(p_contract_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM prj_variation_order WHERE contract_id = p_contract_id AND status_code = 'DRAFT';
    RETURN l;
  END draft_variations;

  FUNCTION can_advance(p_contract_id IN NUMBER) RETURN VARCHAR2 IS
    l_pct NUMBER;
    l_n   NUMBER;
  BEGIN
    SELECT MAX(advance_pct) INTO l_pct FROM prj_contract WHERE id = p_contract_id AND status_code = 'ACTIVE';
    SELECT COUNT(*) INTO l_n FROM prj_progress_claim WHERE contract_id = p_contract_id AND claim_kind = 'ADVANCE' AND status_code IN ('APPROVED', 'PAID');
    RETURN CASE WHEN NVL(l_pct, 0) > 0 AND l_n = 0 THEN 'Y' ELSE 'N' END;
  END can_advance;

  -- ================================================================ التطوير العقاري
  PROCEDURE link_property(p_project_id IN NUMBER, p_property_id IN NUMBER) IS
    l_other NUMBER;
  BEGIN
    guard('PRJ_PROJECT.UPDATE');
    SELECT project_id INTO l_other FROM re_property WHERE id = p_property_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_other IS NULL OR l_other = p_project_id, 'NOONA-PRJ-100', 'العقار مرتبط بمشروع آخر', 'Property is linked to another project');
    UPDATE re_property SET project_id = NULL WHERE project_id = p_project_id AND id <> p_property_id;
    UPDATE re_property SET project_id = p_project_id WHERE id = p_property_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-101', 'العقار غير موجود', 'Property not found');
  END link_property;

  -- ================================================================ الأرقام المجمعة
  FUNCTION actual_cost(p_project_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(amount_func), 0) INTO l FROM prj_cost_line WHERE project_id = p_project_id AND status_code = 'POSTED' AND is_commitment = 'N';
    RETURN l;
  END actual_cost;

  FUNCTION billed(p_project_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(c.current_gross - c.other_deductions), 0) INTO l
      FROM prj_progress_claim c JOIN prj_contract k ON k.id = c.contract_id
     WHERE k.project_id = p_project_id AND c.claim_direction = 'RECEIVABLE' AND c.claim_kind = 'PROGRESS' AND c.status_code IN ('APPROVED', 'PAID');
    RETURN l;
  END billed;

  FUNCTION collected(p_project_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(o.original_amount - o.open_amount), 0) INTO l
      FROM ar_open_item o JOIN prj_progress_claim c ON o.source_entity_type = 'PRJ_PROGRESS_CLAIM' AND o.source_entity_id = c.id
      JOIN prj_contract k ON k.id = c.contract_id
     WHERE k.project_id = p_project_id AND o.status_code <> 'CANCELLED';
    RETURN l;
  END collected;

  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  -- ================================================================ الشاشات
  FUNCTION summary_html RETURN CLOB IS
    l_act NUMBER; l_val NUMBER; l_cost NUMBER; l_bill NUMBER; l_ret NUMBER; l_rec NUMBER; l_late NUMBER;
  BEGIN
    guard('PRJ_PROJECT.VIEW');
    SELECT COUNT(CASE WHEN status_code IN ('APPROVED', 'ACTIVE') THEN 1 END),
           NVL(SUM(CASE WHEN status_code NOT IN ('CANCELLED') THEN contract_value END), 0),
           COUNT(CASE WHEN status_code = 'ACTIVE' AND planned_end < TRUNC(SYSDATE) AND NVL(percent_complete, 0) < 100 THEN 1 END)
      INTO l_act, l_val, l_late FROM prj_project WHERE company_id = company;
    SELECT NVL(SUM(amount_func), 0) INTO l_cost FROM prj_cost_line WHERE company_id = company AND status_code = 'POSTED';
    SELECT NVL(SUM(CASE WHEN claim_direction = 'RECEIVABLE' AND claim_kind = 'PROGRESS' THEN current_gross - other_deductions END), 0),
           NVL(SUM(CASE WHEN claim_direction = 'RECEIVABLE' THEN CASE claim_kind WHEN 'PROGRESS' THEN retention_amount
                                                                                WHEN 'RETENTION_RELEASE' THEN -current_gross END END), 0)
      INTO l_bill, l_ret FROM prj_progress_claim WHERE company_id = company AND status_code IN ('APPROVED', 'PAID');
    SELECT NVL(SUM(o.open_amount), 0) INTO l_rec FROM ar_open_item o
     WHERE o.company_id = company AND o.source_entity_type = 'PRJ_PROGRESS_CLAIM' AND o.open_amount > 0;
    RETURN '<div class="nn-kpis">'
        || kpi('مشروعات قيد التنفيذ', l_act, 'fa-briefcase')
        || kpi('قيمة العقود', fmt(l_val), 'fa-file-text-o', 'is-success')
        || kpi('المستخلصات المعتمدة', fmt(l_bill), 'fa-check-square-o', 'is-success')
        || kpi('التكاليف الفعلية', fmt(l_cost), 'fa-money', 'is-warning')
        || kpi('مستحق على العملاء', fmt(l_rec), 'fa-hourglass-half', CASE WHEN l_rec > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('محتجزات لدى العملاء', fmt(l_ret), 'fa-lock', 'is-info')
        || kpi('مشروعات متأخرة', l_late, 'fa-exclamation-triangle', CASE WHEN l_late > 0 THEN 'is-danger' ELSE 'is-muted' END)
        || '</div>';
  END summary_html;

  FUNCTION project_card_html(p_project_id IN NUMBER) RETURN CLOB IS
    l    prj_project%ROWTYPE := get_project(p_project_id);
    l_ac NUMBER;
    l_bl NUMBER;
    l_cl NUMBER;
    l_pr VARCHAR2(400);
    l_cu VARCHAR2(400);
    l_mg VARCHAR2(400);
    l_ex NUMBER;
    l_ep NUMBER;
  BEGIN
    guard('PRJ_PROJECT.VIEW');
    l_ac := actual_cost(p_project_id);
    l_bl := billed(p_project_id);
    l_cl := collected(p_project_id);
    SELECT MAX(code || ' - ' || name_ar) INTO l_pr FROM re_property WHERE project_id = p_project_id;
    l_cu := CASE WHEN l.customer_account_id IS NOT NULL THEN NOONA_SAL_PKG.customer_label(l.customer_account_id) END;
    l_mg := CASE WHEN l.manager_employee_id IS NOT NULL THEN NOONA_HR_PKG.employee_name(l.manager_employee_id) END;
    -- الإنجاز المتوقع زمنياً للمقارنة
    l_ex := CASE WHEN l.planned_start IS NOT NULL AND l.planned_end > l.planned_start
                 THEN LEAST(GREATEST((TRUNC(SYSDATE) - l.planned_start) / (l.planned_end - l.planned_start) * 100, 0), 100) END;
    l_ep := CASE WHEN l.budget_amount > 0 THEN l_ac / l.budget_amount * 100 END;
    RETURN '<div class="nn-prj-card"><div class="nn-prj-head"><div><div class="nn-prj-code">' || esc(l.code) || ' &middot; ' || esc(type_label(l.project_type))
        || '</div><div class="nn-prj-name">' || esc(l.name_ar) || '</div><div class="nn-prj-meta">'
        || CASE WHEN l_cu IS NOT NULL THEN '<span><span class="fa fa-user" aria-hidden="true"></span> ' || esc(l_cu) || '</span>' END
        || CASE WHEN l_mg IS NOT NULL THEN '<span><span class="fa fa-id-badge" aria-hidden="true"></span> مدير المشروع: ' || esc(l_mg) || '</span>' END
        || CASE WHEN l_pr IS NOT NULL THEN '<span><span class="fa fa-building" aria-hidden="true"></span> العقار: ' || esc(l_pr) || '</span>' END
        || '<span><span class="fa fa-calendar" aria-hidden="true"></span> ' || NVL(ds(l.planned_start), '؟') || ' &larr; ' || NVL(ds(l.planned_end), '؟') || '</span>'
        || '</div></div><div>' || badge(l.status_code) || '</div></div>'
        || '<div class="nn-prj-progress"><div><b>الإنجاز الفعلي</b> ' || bar(l.percent_complete) || '</div>'
        || CASE WHEN l_ex IS NOT NULL THEN '<div><b>المخطط زمنياً</b> ' || bar(l_ex) || '</div>' END
        || CASE WHEN l_ep IS NOT NULL THEN '<div><b>المصروف من الموازنة</b> ' || bar(l_ep) || '</div>' END || '</div>'
        || '<div class="nn-kpis">'
        || kpi('قيمة العقد', fmt(l.contract_value), 'fa-file-text-o')
        || kpi('الموازنة', fmt(l.budget_amount), 'fa-pie-chart')
        || kpi('التكلفة الفعلية', fmt(l_ac), 'fa-money', CASE WHEN l.budget_amount > 0 AND l_ac > l.budget_amount THEN 'is-danger' ELSE 'is-warning' END)
        || kpi('المفوتر للعميل', fmt(l_bl), 'fa-check-square-o', 'is-success')
        || kpi('المحصل', fmt(l_cl), 'fa-download', 'is-success')
        || kpi('الربح حتى تاريخه', fmt(l_bl - l_ac), 'fa-line-chart', CASE WHEN l_bl - l_ac < 0 THEN 'is-danger' ELSE 'is-success' END)
        || '</div></div>';
  END project_card_html;

  FUNCTION wbs_html(p_project_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('PRJ_PROJECT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>البند</th><th>الاسم</th><th class="n">الوزن</th><th>المدة</th><th>الإنجاز</th>'
        || '<th class="n">الموازنة</th><th class="n">الفعلي</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT w.id, w.code, w.name_ar, w.wbs_level, w.weight_pct, w.planned_start, w.planned_end, w.percent_complete, w.status_code,
                     (SELECT NVL(SUM(bl.amount), 0) FROM prj_budget_line bl JOIN prj_budget b ON b.id = bl.budget_id
                       WHERE bl.wbs_id = w.id AND b.is_baseline = 'Y') budget,
                     (SELECT NVL(SUM(c.amount_func), 0) FROM prj_cost_line c WHERE c.wbs_id = w.id AND c.status_code = 'POSTED') actual
                FROM prj_wbs w WHERE w.project_id = p_project_id
               START WITH w.parent_wbs_id IS NULL AND w.project_id = p_project_id
               CONNECT BY PRIOR w.id = w.parent_wbs_id
               ORDER SIBLINGS BY w.code) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr data-wbs="' || r.id || '"><td>' || esc(r.code) || '</td><td style="padding-inline-start:' || (r.wbs_level * 14) || 'px">'
          || esc(r.name_ar) || '</td><td class="n">' || CASE WHEN r.weight_pct IS NOT NULL THEN pct(r.weight_pct) END || '</td><td>'
          || ds(r.planned_start) || CASE WHEN r.planned_end IS NOT NULL THEN ' &larr; ' || ds(r.planned_end) END || '</td><td>' || bar(r.percent_complete)
          || '</td><td class="n">' || fmt(r.budget) || '</td><td class="n' || CASE WHEN r.budget > 0 AND r.actual > r.budget THEN ' is-over' END || '">'
          || fmt(r.actual) || '</td><td>' || badge(r.status_code) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد بنود عمل</div>' ELSE l_h || '</tbody></table>' END;
  END wbs_html;

  FUNCTION budget_html(p_project_id IN NUMBER) RETURN CLOB IS
    l_h  CLOB;
    l_tb NUMBER := 0;
    l_ta NUMBER := 0;
  BEGIN
    guard('PRJ_PROJECT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>نوع التكلفة</th><th class="n">الموازنة</th><th class="n">الفعلي</th><th class="n">الانحراف</th>'
        || '<th>المستهلك</th></tr></thead><tbody>';
    FOR r IN (SELECT t.cost_type,
                     NVL((SELECT SUM(bl.amount) FROM prj_budget_line bl JOIN prj_budget b ON b.id = bl.budget_id
                           WHERE b.project_id = p_project_id AND b.is_baseline = 'Y' AND bl.cost_type = t.cost_type), 0) budget,
                     NVL((SELECT SUM(c.amount_func) FROM prj_cost_line c WHERE c.project_id = p_project_id AND c.status_code = 'POSTED'
                           AND c.cost_type = t.cost_type), 0) actual
                FROM (SELECT column_value cost_type FROM TABLE(sys.odcivarchar2list('MATERIAL', 'LABOR', 'EQUIPMENT', 'SUBCONTRACT', 'OVERHEAD', 'OTHER'))) t) LOOP
      CONTINUE WHEN r.budget = 0 AND r.actual = 0;
      l_tb := l_tb + r.budget;
      l_ta := l_ta + r.actual;
      l_h := l_h || '<tr><td>' || esc(cost_type_label(r.cost_type)) || '</td><td class="n">' || fmt(r.budget) || '</td><td class="n">' || fmt(r.actual)
          || '</td><td class="n' || CASE WHEN r.actual > r.budget THEN ' is-over' END || '">' || fmt(r.budget - r.actual) || '</td><td>'
          || CASE WHEN r.budget > 0 THEN bar(r.actual / r.budget * 100) ELSE '<span class="nn-badge is-warning">بلا موازنة</span>' END || '</td></tr>';
    END LOOP;
    RETURN l_h || '</tbody><tfoot><tr><td>الإجمالي</td><td class="n">' || fmt(l_tb) || '</td><td class="n">' || fmt(l_ta) || '</td><td class="n'
        || CASE WHEN l_ta > l_tb THEN ' is-over' END || '">' || fmt(l_tb - l_ta) || '</td><td>'
        || CASE WHEN l_tb > 0 THEN bar(l_ta / l_tb * 100) END || '</td></tr></tfoot></table>';
  END budget_html;

  FUNCTION costs_html(p_project_id IN NUMBER, p_limit IN PLS_INTEGER DEFAULT 50) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('PRJ_PROJECT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>التاريخ</th><th>النوع</th><th>البند</th><th>البيان</th><th>المرجع</th><th class="n">الكمية</th>'
        || '<th class="n">المبلغ</th><th>الحالة</th><th></th></tr></thead><tbody>';
    FOR r IN (SELECT c.id, c.cost_date, c.cost_type, w.code wbs, c.description, c.reference, c.quantity, c.amount_func, c.status_code, c.source_entity_type
                FROM prj_cost_line c JOIN prj_wbs w ON w.id = c.wbs_id
               WHERE c.project_id = p_project_id ORDER BY c.cost_date DESC, c.id DESC FETCH FIRST p_limit ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr' || CASE WHEN r.status_code = 'REVERSED' THEN ' class="is-void"' END || '><td>' || ds(r.cost_date) || '</td><td>'
          || esc(cost_type_label(r.cost_type)) || '</td><td>' || esc(r.wbs) || '</td><td>' || esc(r.description) || '</td><td>' || esc(r.reference)
          || '</td><td class="n">' || CASE WHEN r.quantity IS NOT NULL THEN fq(r.quantity) END || '</td><td class="n">' || fmt(r.amount_func)
          || '</td><td>' || badge(r.status_code) || '</td><td>'
          || CASE WHEN r.status_code = 'POSTED' AND r.source_entity_type IN ('PRJ_COST_LINE', 'PRJ_TIMESHEET')
                  THEN '<button type="button" class="nn-prj-rev t-Button t-Button--small t-Button--danger t-Button--simple" data-id="' || r.id
                       || '">عكس</button>' END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد تكاليف مسجلة</div>' ELSE l_h || '</tbody></table>' END;
  END costs_html;

  FUNCTION contracts_html(p_project_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_p VARCHAR2(400);
  BEGIN
    guard('PRJ_CONTRACT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العقد</th><th>النوع</th><th>الطرف</th><th class="n">القيمة الحالية</th><th class="n">المعتمد</th>'
        || '<th>المنفذ</th><th class="n">المحتجز القائم</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT k.id, k.contract_no, k.contract_type, k.customer_account_id, k.supplier_account_id, k.current_value, k.status_code,
                     (SELECT NVL(SUM(c.current_gross), 0) FROM prj_progress_claim c WHERE c.contract_id = k.id AND c.claim_kind = 'PROGRESS'
                         AND c.status_code IN ('APPROVED', 'PAID')) certified
                FROM prj_contract k WHERE k.project_id = p_project_id ORDER BY CASE k.contract_type WHEN 'MAIN_CONTRACT' THEN 0 ELSE 1 END, k.id) LOOP
      l_n := l_n + 1;
      l_p := CASE WHEN r.customer_account_id IS NOT NULL THEN NOONA_SAL_PKG.customer_label(r.customer_account_id)
                  ELSE NOONA_PUR_PKG.supplier_label(r.supplier_account_id) END;
      l_h := l_h || '<tr><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(r.contract_no) || '</a>'
                                       ELSE esc(r.contract_no) END
          || '</td><td>' || CASE r.contract_type WHEN 'MAIN_CONTRACT' THEN 'رئيسي (العميل)' WHEN 'SUBCONTRACT' THEN 'مقاول باطن' ELSE esc(r.contract_type) END
          || '</td><td>' || esc(l_p) || '</td><td class="n">' || fmt(r.current_value) || '</td><td class="n">' || fmt(r.certified) || '</td><td>'
          || bar(CASE WHEN r.current_value > 0 THEN r.certified / r.current_value * 100 END) || '</td><td class="n">' || fmt(retention_held(r.id))
          || '</td><td>' || badge(r.status_code) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد عقود؛ أضف العقد الرئيسي مع العميل وعقود مقاولي الباطن</div>'
                ELSE l_h || '</tbody></table>' END;
  END contracts_html;

  FUNCTION contract_html(p_contract_id IN NUMBER) RETURN CLOB IS
    l_c  prj_contract%ROWTYPE := get_contract(p_contract_id);
    l_h  CLOB;
    l_t  NUMBER := 0;
    l_x  NUMBER := 0;
    l_p  VARCHAR2(400);
  BEGIN
    guard('PRJ_CONTRACT.VIEW');
    l_p := CASE WHEN l_c.customer_account_id IS NOT NULL THEN 'العميل: ' || NOONA_SAL_PKG.customer_label(l_c.customer_account_id)
                ELSE 'المقاول: ' || NOONA_PUR_PKG.supplier_label(l_c.supplier_account_id) END;
    l_h := '<div class="nn-prj-chips"><span>' || esc(l_p) || '</span><span>القيمة الأصلية ' || fmt(l_c.original_value) || '</span><span>الحالية '
        || fmt(contract_value(l_c.id)) || '</span><span>المحتجز ' || pct(l_c.retention_pct)
        || CASE WHEN l_c.retention_cap_pct IS NOT NULL THEN ' (سقف ' || pct(l_c.retention_cap_pct) || ')' END || '</span>'
        || CASE WHEN l_c.advance_pct > 0 THEN '<span>دفعة مقدمة ' || pct(l_c.advance_pct) || ' تسترد ' || pct(l_c.advance_recovery_pct)
                                             || ' &middot; المتبقي ' || fmt(advance_open(l_c.id)) || '</span>' END
        || '<span>المحتجز القائم ' || fmt(retention_held(l_c.id)) || '</span>' || badge(l_c.status_code) || '</div>'
        || '<table class="nn-prj-t"><thead><tr><th>البند</th><th>الوصف</th><th>الوحدة</th><th class="n">كمية العقد</th><th class="n">التغيير</th>'
        || '<th class="n">السعر</th><th class="n">القيمة</th><th class="n">المنفذ</th><th>نسبة التنفيذ</th></tr></thead><tbody>';
    FOR r IN (SELECT b.*, u.name_ar uom FROM prj_boq_item b LEFT JOIN inv_uom u ON u.id = b.uom_id
               WHERE b.contract_id = p_contract_id ORDER BY b.sort_order, b.item_code) LOOP
      l_t := l_t + ROUND((r.contract_qty + r.variation_qty) * r.unit_rate, 2);
      l_x := l_x + ROUND(r.executed_qty * r.unit_rate, 2);
      l_h := l_h || '<tr><td>' || esc(r.item_code) || '</td><td>' || esc(r.description_ar) || '</td><td>' || esc(r.uom) || '</td><td class="n">'
          || fq(r.contract_qty) || '</td><td class="n">' || CASE WHEN r.variation_qty <> 0 THEN fq(r.variation_qty) END || '</td><td class="n">'
          || fmt(r.unit_rate) || '</td><td class="n">' || fmt((r.contract_qty + r.variation_qty) * r.unit_rate) || '</td><td class="n">'
          || fq(r.executed_qty) || '</td><td>' || bar(CASE WHEN r.contract_qty + r.variation_qty > 0 THEN r.executed_qty / (r.contract_qty + r.variation_qty) * 100 END)
          || '</td></tr>';
    END LOOP;
    l_h := l_h || '</tbody><tfoot><tr><td colspan="6">الإجمالي</td><td class="n">' || fmt(l_t) || '</td><td class="n">' || fmt(l_x) || '</td><td>'
        || bar(CASE WHEN l_t > 0 THEN l_x / l_t * 100 END) || '</td></tr></tfoot></table>';
    FOR v IN (SELECT doc_no, doc_date, variation_type, description, amount, time_impact_days, status_code FROM prj_variation_order
               WHERE contract_id = p_contract_id ORDER BY doc_date, id) LOOP
      IF v.doc_no IS NOT NULL AND INSTR(l_h, 'nn-prj-vo') = 0 THEN
        l_h := l_h || '<h4 class="nn-prj-h">أوامر التغيير</h4><table class="nn-prj-t nn-prj-vo"><thead><tr><th>الرقم</th><th>التاريخ</th><th>الوصف</th>'
            || '<th class="n">الأثر المالي</th><th class="n">الأثر الزمني</th><th>الحالة</th></tr></thead><tbody>';
      END IF;
      l_h := l_h || '<tr><td>' || esc(v.doc_no) || '</td><td>' || ds(v.doc_date) || '</td><td>' || esc(v.description) || '</td><td class="n">'
          || fmt(v.amount) || '</td><td class="n">' || CASE WHEN v.time_impact_days > 0 THEN v.time_impact_days || ' يوم' END || '</td><td>'
          || badge(v.status_code) || '</td></tr>';
    END LOOP;
    IF INSTR(l_h, 'nn-prj-vo') > 0 THEN l_h := l_h || '</tbody></table>'; END IF;
    RETURN l_h;
  END contract_html;

  FUNCTION claims_html(p_contract_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h  CLOB;
    l_n  PLS_INTEGER := 0;
    l_op NUMBER;
  BEGIN
    guard('PRJ_PROGRESS_CLAIM.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>#</th><th>الرقم</th><th>النوع</th><th>الفترة</th><th class="n">قيمة الفترة</th><th class="n">المحتجز</th>'
        || '<th class="n">استرداد المقدم</th><th class="n">الضريبة</th><th class="n">الصافي</th><th class="n">المتبقي</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT c.*, k.supplier_account_id FROM prj_progress_claim c JOIN prj_contract k ON k.id = c.contract_id
               WHERE c.contract_id = p_contract_id ORDER BY c.claim_no DESC) LOOP
      l_n := l_n + 1;
      IF r.status_code IN ('APPROVED', 'PAID') THEN
        IF r.claim_direction = 'RECEIVABLE' THEN
          SELECT NVL(SUM(open_amount), 0) INTO l_op FROM ar_open_item WHERE source_entity_type = c_claim AND source_entity_id = r.id;
        ELSE
          SELECT NVL(SUM(open_amount), 0) INTO l_op FROM ap_open_item WHERE supplier_account_id = r.supplier_account_id AND doc_no = r.doc_no;
        END IF;
      ELSE
        l_op := NULL;
      END IF;
      l_h := l_h || '<tr' || CASE WHEN r.status_code = 'CANCELLED' THEN ' class="is-void"' END || '><td>' || r.claim_no || '</td><td>'
          || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(r.doc_no) || '</a>' ELSE esc(r.doc_no) END
          || '</td><td>' || esc(kind_label(r.claim_kind)) || '</td><td>' || ds(r.period_from) || ' &larr; ' || ds(r.period_to) || '</td><td class="n">'
          || fmt(r.current_gross) || '</td><td class="n">' || fmt(r.retention_amount) || '</td><td class="n">' || fmt(r.advance_recovery)
          || '</td><td class="n">' || fmt(r.tax_amount) || '</td><td class="n"><b>' || fmt(r.net_payable) || '</b></td><td class="n">'
          || CASE WHEN l_op IS NOT NULL THEN fmt(l_op) END || '</td><td>'
          || CASE WHEN l_op = 0 AND r.status_code = 'APPROVED' THEN badge('PAID') ELSE badge(r.status_code) END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد مستخلصات لهذا العقد</div>' ELSE l_h || '</tbody></table>' END;
  END claims_html;

  FUNCTION claim_print(p_claim_id IN NUMBER) RETURN CLOB IS
    l_cl prj_progress_claim%ROWTYPE;
    l_c  prj_contract%ROWTYPE;
    l_p  prj_project%ROWTYPE;
    l_h  CLOB;
    l_pt VARCHAR2(400);
    l_co VARCHAR2(400);
  BEGIN
    guard('PRJ_PROGRESS_CLAIM.VIEW');
    SELECT * INTO l_cl FROM prj_progress_claim WHERE id = p_claim_id AND company_id = company;
    l_c := get_contract(l_cl.contract_id);
    l_p := get_project(l_c.project_id);
    l_pt := CASE WHEN l_c.customer_account_id IS NOT NULL THEN NOONA_SAL_PKG.customer_label(l_c.customer_account_id)
                 ELSE NOONA_PUR_PKG.supplier_label(l_c.supplier_account_id) END;
    l_co := NOONA_APEX_PKG.company_name;
    l_h := '<div class="nn-prj-cert"><div class="nn-prj-cert-head"><div><b>' || esc(l_co) || '</b><div>شهادة ' || esc(kind_label(l_cl.claim_kind))
        || CASE WHEN l_cl.claim_direction = 'RECEIVABLE' THEN ' للعميل' ELSE ' لمقاول الباطن' END || '</div></div><div class="nn-prj-cert-no">'
        || 'رقم ' || l_cl.claim_no || '<small>' || esc(l_cl.doc_no) || '</small></div></div>'
        || '<table class="nn-prj-cert-info"><tr><th>المشروع</th><td>' || esc(l_p.code || ' - ' || l_p.name_ar) || '</td><th>العقد</th><td>'
        || esc(l_c.contract_no) || '</td></tr><tr><th>' || CASE WHEN l_cl.claim_direction = 'RECEIVABLE' THEN 'العميل' ELSE 'المقاول' END
        || '</th><td>' || esc(l_pt) || '</td><th>الفترة</th><td>' || ds(l_cl.period_from) || ' إلى ' || ds(l_cl.period_to) || '</td></tr>'
        || '<tr><th>قيمة العقد الحالية</th><td>' || fmt(contract_value(l_c.id)) || '</td><th>التاريخ</th><td>' || ds(l_cl.doc_date) || '</td></tr></table>';
    IF l_cl.claim_kind = 'PROGRESS' THEN
      l_h := l_h || '<table class="nn-prj-t"><thead><tr><th>البند</th><th>الوصف</th><th class="n">كمية العقد</th><th class="n">السابقة</th>'
          || '<th class="n">الحالية</th><th class="n">التراكمية</th><th class="n">السعر</th><th class="n">القيمة التراكمية</th><th class="n">قيمة الفترة</th>'
          || '</tr></thead><tbody>';
      FOR r IN (SELECT b.item_code, b.description_ar, b.contract_qty + b.variation_qty q, l.previous_qty, l.current_qty, l.qty_to_date, l.unit_rate,
                       l.amount_to_date, l.current_amount
                  FROM prj_progress_claim_line l JOIN prj_boq_item b ON b.id = l.boq_item_id
                 WHERE l.claim_id = p_claim_id AND (l.qty_to_date > 0) ORDER BY b.sort_order, b.item_code) LOOP
        l_h := l_h || '<tr><td>' || esc(r.item_code) || '</td><td>' || esc(r.description_ar) || '</td><td class="n">' || fq(r.q) || '</td><td class="n">'
            || fq(r.previous_qty) || '</td><td class="n">' || fq(r.current_qty) || '</td><td class="n">' || fq(r.qty_to_date) || '</td><td class="n">'
            || fmt(r.unit_rate) || '</td><td class="n">' || fmt(r.amount_to_date) || '</td><td class="n">' || fmt(r.current_amount) || '</td></tr>';
      END LOOP;
      l_h := l_h || '</tbody></table>';
    END IF;
    l_h := l_h || '<table class="nn-prj-cert-sum">'
        || CASE WHEN l_cl.claim_kind = 'PROGRESS' THEN
             '<tr><th>إجمالي الأعمال المنفذة حتى تاريخه</th><td>' || fmt(l_cl.gross_to_date) || '</td></tr>'
             || '<tr><th>يخصم: المعتمد في المستخلصات السابقة</th><td>(' || fmt(l_cl.previous_certified) || ')</td></tr>' END
        || '<tr><th>قيمة ' || esc(kind_label(l_cl.claim_kind)) || '</th><td>' || fmt(l_cl.current_gross) || '</td></tr>'
        || CASE WHEN l_cl.retention_amount > 0 THEN '<tr><th>يخصم: المحتجز (' || pct(l_c.retention_pct) || ')</th><td>(' || fmt(l_cl.retention_amount) || ')</td></tr>' END
        || CASE WHEN l_cl.advance_recovery > 0 THEN '<tr><th>يخصم: استرداد الدفعة المقدمة</th><td>(' || fmt(l_cl.advance_recovery) || ')</td></tr>' END
        || CASE WHEN l_cl.other_deductions > 0 THEN '<tr><th>يخصم: خصومات وغرامات</th><td>(' || fmt(l_cl.other_deductions) || ')</td></tr>' END
        || '<tr><th>ضريبة القيمة المضافة</th><td>' || fmt(l_cl.tax_amount) || '</td></tr>'
        || '<tr class="is-total"><th>الصافي المستحق</th><td>' || fmt(l_cl.net_payable) || '</td></tr></table>'
        || '<div class="nn-prj-cert-sign"><div>المهندس المشرف<br><br>..................</div><div>الاستشاري / ' || esc(l_cl.certified_by)
        || '<br><br>..................</div><div>الاعتماد المالي<br><br>..................</div></div>'
        || CASE WHEN l_cl.status_code = 'DRAFT' THEN '<div class="nn-prj-draft">مسودة - غير معتمدة</div>'
                WHEN l_cl.status_code = 'CANCELLED' THEN '<div class="nn-prj-draft">ملغى</div>' END || '</div>';
    RETURN l_h;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">المستخلص غير موجود</div>';
  END claim_print;

  FUNCTION portfolio_html(p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h  CLOB;
    l_n  PLS_INTEGER := 0;
    l_ac NUMBER; l_bl NUMBER; l_cl NUMBER;
    t_cv NUMBER := 0; t_bg NUMBER := 0; t_ac NUMBER := 0; t_bl NUMBER := 0; t_cl NUMBER := 0;
  BEGIN
    guard('PRJ_PROJECT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>المشروع</th><th>النوع</th><th>الإنجاز</th><th>النهاية</th><th class="n">قيمة العقد</th>'
        || '<th class="n">الموازنة</th><th class="n">التكلفة الفعلية</th><th class="n">المفوتر</th><th class="n">المحصل</th><th class="n">الربح</th>'
        || '<th class="n">الهامش</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM prj_project WHERE company_id = company AND (p_status IS NULL OR status_code = p_status)
                 AND (p_status IS NOT NULL OR status_code <> 'CANCELLED') ORDER BY code) LOOP
      l_n := l_n + 1;
      l_ac := actual_cost(r.id); l_bl := billed(r.id); l_cl := collected(r.id);
      t_cv := t_cv + NVL(r.contract_value, 0); t_bg := t_bg + NVL(r.budget_amount, 0); t_ac := t_ac + l_ac; t_bl := t_bl + l_bl; t_cl := t_cl + l_cl;
      l_h := l_h || '<tr><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' END || esc(r.code || ' - ' || r.name_ar)
          || CASE WHEN p_link IS NOT NULL THEN '</a>' END || '</td><td>' || esc(type_label(r.project_type)) || '</td><td>' || bar(r.percent_complete)
          || '</td><td' || CASE WHEN r.planned_end < TRUNC(SYSDATE) AND r.status_code = 'ACTIVE' AND NVL(r.percent_complete, 0) < 100 THEN ' class="is-over"' END
          || '>' || ds(r.planned_end) || '</td><td class="n">' || fmt(r.contract_value) || '</td><td class="n">' || fmt(r.budget_amount)
          || '</td><td class="n' || CASE WHEN r.budget_amount > 0 AND l_ac > r.budget_amount THEN ' is-over' END || '">' || fmt(l_ac) || '</td><td class="n">'
          || fmt(l_bl) || '</td><td class="n">' || fmt(l_cl) || '</td><td class="n' || CASE WHEN l_bl - l_ac < 0 THEN ' is-over' END || '">' || fmt(l_bl - l_ac)
          || '</td><td class="n">' || CASE WHEN l_bl > 0 THEN pct((l_bl - l_ac) / l_bl * 100) END || '</td><td>' || badge(r.status_code) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد مشروعات</div>'
                ELSE l_h || '</tbody><tfoot><tr><td colspan="4">الإجمالي (' || l_n || ')</td><td class="n">' || fmt(t_cv) || '</td><td class="n">' || fmt(t_bg)
                    || '</td><td class="n">' || fmt(t_ac) || '</td><td class="n">' || fmt(t_bl) || '</td><td class="n">' || fmt(t_cl) || '</td><td class="n">'
                    || fmt(t_bl - t_ac) || '</td><td class="n">' || CASE WHEN t_bl > 0 THEN pct((t_bl - t_ac) / t_bl * 100) END || '</td><td></td></tr></tfoot></table>' END;
  END portfolio_html;

  FUNCTION claims_register_html(p_from IN DATE, p_to IN DATE, p_direction IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    t_g NUMBER := 0; t_r NUMBER := 0; t_a NUMBER := 0; t_t NUMBER := 0; t_n NUMBER := 0;
    l_pt VARCHAR2(400);
  BEGIN
    guard('PRJ_PROGRESS_CLAIM.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>التاريخ</th><th>الرقم</th><th>المشروع</th><th>العقد</th><th>الطرف</th><th>النوع</th>'
        || '<th class="n">قيمة الفترة</th><th class="n">المحتجز</th><th class="n">استرداد المقدم</th><th class="n">الضريبة</th><th class="n">الصافي</th></tr></thead><tbody>';
    FOR r IN (SELECT c.*, k.contract_no, k.customer_account_id, k.supplier_account_id, p.code pcode
                FROM prj_progress_claim c JOIN prj_contract k ON k.id = c.contract_id JOIN prj_project p ON p.id = k.project_id
               WHERE c.company_id = company AND c.status_code IN ('APPROVED', 'PAID') AND c.doc_date BETWEEN p_from AND p_to
                 AND (p_direction IS NULL OR c.claim_direction = p_direction) ORDER BY c.doc_date, c.doc_no) LOOP
      l_n := l_n + 1;
      l_pt := CASE WHEN r.customer_account_id IS NOT NULL THEN NOONA_SAL_PKG.customer_label(r.customer_account_id)
                   ELSE NOONA_PUR_PKG.supplier_label(r.supplier_account_id) END;
      t_g := t_g + r.current_gross; t_r := t_r + r.retention_amount; t_a := t_a + r.advance_recovery; t_t := t_t + r.tax_amount; t_n := t_n + r.net_payable;
      l_h := l_h || '<tr><td>' || ds(r.doc_date) || '</td><td>' || esc(r.doc_no) || '</td><td>' || esc(r.pcode) || '</td><td>' || esc(r.contract_no)
          || '</td><td>' || esc(l_pt) || '</td><td>' || esc(kind_label(r.claim_kind)) || CASE WHEN r.claim_direction = 'PAYABLE' THEN ' (باطن)' END
          || '</td><td class="n">' || fmt(r.current_gross) || '</td><td class="n">' || fmt(r.retention_amount) || '</td><td class="n">' || fmt(r.advance_recovery)
          || '</td><td class="n">' || fmt(r.tax_amount) || '</td><td class="n">' || fmt(r.net_payable) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد مستخلصات معتمدة في الفترة</div>'
                ELSE l_h || '</tbody><tfoot><tr><td colspan="6">الإجمالي (' || l_n || ')</td><td class="n">' || fmt(t_g) || '</td><td class="n">' || fmt(t_r)
                    || '</td><td class="n">' || fmt(t_a) || '</td><td class="n">' || fmt(t_t) || '</td><td class="n">' || fmt(t_n) || '</td></tr></tfoot></table>' END;
  END claims_register_html;

  FUNCTION retention_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_r NUMBER;
    l_pt VARCHAR2(400);
    l_rel DATE;
  BEGIN
    guard('PRJ_PROGRESS_CLAIM.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>المشروع</th><th>العقد</th><th>الطرف</th><th>الاتجاه</th><th class="n">المحتجز القائم</th>'
        || '<th class="n">الدفعة المقدمة غير المستردة</th><th>نهاية العقد</th><th>نهاية فترة الضمان (موعد الإفراج)</th></tr></thead><tbody>';
    FOR k IN (SELECT k.*, p.code pcode FROM prj_contract k JOIN prj_project p ON p.id = k.project_id
               WHERE k.company_id = company AND k.status_code IN ('ACTIVE', 'COMPLETED') ORDER BY p.code, k.contract_no) LOOP
      l_r := retention_held(k.id);
      CONTINUE WHEN l_r = 0 AND advance_open(k.id) = 0;
      l_n := l_n + 1;
      l_pt := CASE WHEN k.customer_account_id IS NOT NULL THEN NOONA_SAL_PKG.customer_label(k.customer_account_id)
                   ELSE NOONA_PUR_PKG.supplier_label(k.supplier_account_id) END;
      l_rel := CASE WHEN k.end_date IS NOT NULL THEN ADD_MONTHS(k.end_date, NVL(k.defects_liability_months, 12)) END;
      l_h := l_h || '<tr><td>' || esc(k.pcode) || '</td><td>' || esc(k.contract_no) || '</td><td>' || esc(l_pt) || '</td><td>'
          || CASE WHEN k.contract_type = 'MAIN_CONTRACT' THEN 'لدى العميل (لنا)' ELSE 'لمقاول الباطن (علينا)' END || '</td><td class="n">' || fmt(l_r)
          || '</td><td class="n">' || fmt(advance_open(k.id)) || '</td><td>' || ds(k.end_date) || '</td><td'
          || CASE WHEN l_rel <= TRUNC(SYSDATE) THEN ' class="is-over"' END || '>' || ds(l_rel) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد محتجزات أو دفعات مقدمة قائمة</div>' ELSE l_h || '</tbody></table>' END;
  END retention_html;

  FUNCTION cost_report_html(p_from IN DATE, p_to IN DATE, p_project_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_t NUMBER := 0;
  BEGIN
    guard('PRJ_COST_LINE.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>المشروع</th><th>نوع التكلفة</th><th class="n">عدد الحركات</th><th class="n">المبلغ</th></tr></thead><tbody>';
    FOR r IN (SELECT p.code || ' - ' || p.name_ar prj, c.cost_type, COUNT(*) n, SUM(c.amount_func) a
                FROM prj_cost_line c JOIN prj_project p ON p.id = c.project_id
               WHERE c.company_id = company AND c.status_code = 'POSTED' AND c.cost_date BETWEEN p_from AND p_to
                 AND (p_project_id IS NULL OR c.project_id = p_project_id)
               GROUP BY p.code || ' - ' || p.name_ar, c.cost_type ORDER BY 1, 2) LOOP
      l_n := l_n + 1;
      l_t := l_t + r.a;
      l_h := l_h || '<tr><td>' || esc(r.prj) || '</td><td>' || esc(cost_type_label(r.cost_type)) || '</td><td class="n">' || r.n || '</td><td class="n">'
          || fmt(r.a) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد تكاليف في الفترة</div>'
                ELSE l_h || '</tbody><tfoot><tr><td colspan="3">الإجمالي</td><td class="n">' || fmt(l_t) || '</td></tr></tfoot></table>' END;
  END cost_report_html;

  FUNCTION unit_costs_html(p_project_id IN NUMBER, p_basis IN VARCHAR2 DEFAULT 'AREA') RETURN CLOB IS
    l_prop  NUMBER;
    l_cost  NUMBER;
    l_base  NUMBER;
    l_h     CLOB;
    l_share NUMBER;
    l_basis VARCHAR2(30) := NVL(p_basis, 'AREA');
    l_tp    NUMBER := 0;
  BEGIN
    guard('PRJ_PROJECT.VIEW');
    SELECT MIN(id) INTO l_prop FROM re_property WHERE project_id = p_project_id;
    IF l_prop IS NULL THEN
      RETURN '<div class="nn-empty">اربط المشروع بعقار من السجل العقاري لتوزيع تكلفة التطوير على وحداته</div>';
    END IF;
    l_cost := actual_cost(p_project_id);
    SELECT NVL(SUM(CASE l_basis WHEN 'AREA' THEN NVL(NVL(net_area_sqm, gross_area_sqm), 0) WHEN 'SALE_VALUE' THEN NVL(list_price, 0) ELSE 1 END), 0)
      INTO l_base FROM re_unit WHERE property_id = l_prop AND status_code <> 'CANCELLED';
    IF l_base = 0 THEN
      RETURN '<div class="nn-empty">لا توجد وحدات بقيمة لأساس التوزيع المختار (المساحة أو السعر)</div>';
    END IF;
    l_h := '<div class="nn-prj-chips"><span>العقار: ' || esc(NOONA_RE_PKG.property_name(l_prop)) || '</span><span>تكلفة التطوير حتى تاريخه '
        || fmt(l_cost) || '</span><span>أساس التوزيع: ' || CASE l_basis WHEN 'AREA' THEN 'المساحة' WHEN 'SALE_VALUE' THEN 'سعر البيع' ELSE 'عدد الوحدات' END
        || '</span><span>' || CASE l_basis WHEN 'AREA' THEN 'تكلفة المتر ' || fmt(l_cost / l_base) WHEN 'SALE_VALUE' THEN 'نسبة التكلفة للسعر ' || pct(l_cost / l_base * 100)
                                          ELSE 'تكلفة الوحدة ' || fmt(l_cost / l_base) END || '</span></div>'
        || '<table class="nn-prj-t"><thead><tr><th>الوحدة</th><th>النوع</th><th class="n">المساحة</th><th class="n">سعر البيع</th><th class="n">نصيبها من التكلفة</th>'
        || '<th class="n">الهامش المتوقع</th><th>الحالة</th></tr></thead><tbody>';
    FOR u IN (SELECT id, code, unit_type, NVL(net_area_sqm, gross_area_sqm) area, list_price, status_code FROM re_unit
               WHERE property_id = l_prop AND status_code <> 'CANCELLED' ORDER BY code) LOOP
      l_share := ROUND(l_cost * CASE l_basis WHEN 'AREA' THEN NVL(u.area, 0) WHEN 'SALE_VALUE' THEN NVL(u.list_price, 0) ELSE 1 END / l_base, 2);
      l_tp := l_tp + NVL(u.list_price, 0);
      l_h := l_h || '<tr><td>' || esc(NOONA_RE_PKG.unit_label(u.id)) || '</td><td>' || esc(NOONA_RE_PKG.unit_type_label(u.unit_type)) || '</td><td class="n">'
          || fq(u.area) || '</td><td class="n">' || fmt(u.list_price) || '</td><td class="n">' || fmt(l_share) || '</td><td class="n'
          || CASE WHEN u.list_price < l_share THEN ' is-over' END || '">' || CASE WHEN u.list_price > 0 THEN fmt(u.list_price - l_share) END || '</td><td>'
          || esc(NOONA_RE_PKG.unit_status_label(u.status_code)) || '</td></tr>';
    END LOOP;
    RETURN l_h || '</tbody><tfoot><tr><td colspan="3">الإجمالي</td><td class="n">' || fmt(l_tp) || '</td><td class="n">' || fmt(l_cost) || '</td><td class="n">'
        || CASE WHEN l_tp > 0 THEN fmt(l_tp - l_cost) END || '</td><td></td></tr></tfoot></table>';
  END unit_costs_html;
END NOONA_PRJ_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_PRJ_PKG
