-- =============================================================================
-- NOONA PLUS ERP | NOONA_PRJ_CTR_PKG - محاسبة عقود المقاولات (مكملة لـ NOONA_PRJ_PKG)
--   * الاعتراف بالإيراد حسب نسبة الإنجاز (IFRS 15): بالتكلفة (التكلفة الفعلية ÷ التكلفة المتوقعة) أو بالإنجاز الفعلي لبنود العمل؛
--     الإيراد المستحق = نسبة الإنجاز × (قيمة العقد − الغرامات)، ويقارن بالمفوتر بالمستخلصات:
--     الزيادة «أصول عقود» (إيراد غير مفوتر) والنقص «التزامات عقود» (فوترة تتجاوز الإنجاز)، بقيد تسوية للفرق عن آخر تشغيل
--   * التكلفة المتوقعة عند الإنجاز وربحية العقد المتوقعة، ومخصص الخسارة المتبقية للعقد الخاسر فور توقعها
--   * المعدات: بطاقة المعدة بتكلفة الساعة، وتسجيل التشغيل على المشروعات وتحميله بقيد (تكلفة المشروع / تكلفة المعدات المحملة)
--   * خطابات الضمان (ابتدائي، نهائي، دفعة مقدمة، محتجز، صيانة): الإصدار بغطاء نقدي، التمديد، التخفيض، الإفراج، التسييل،
--     والتنبيه قبل الانتهاء
--   * الحساب الختامي للعقد: القيمة الأصلية وأوامر التغيير والمنفذ والمستخلصات والغرامات والمحتجز والدفعة المقدمة والمحصل والرصيد
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_PRJ_CTR_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- ---------------------------------------------------------- الاعتراف بالإيراد
  -- معاينة دون ترحيل (JSON) وتشغيل الاعتراف لنهاية فترة (يعيد رقم التشغيل)؛ p_eac فارغ = آخر تقدير محفوظ للمشروع
  FUNCTION preview_json(p_project_id IN NUMBER, p_period_end IN DATE, p_eac IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION run_revenue(p_project_id IN NUMBER, p_period_end IN DATE, p_eac IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- عكس آخر تشغيل للمشروع (لتصحيح التقدير ثم إعادة التشغيل)
  PROCEDURE reverse_run(p_run_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION is_poc(p_project_id IN NUMBER) RETURN VARCHAR2;
  -- كشف الأعمال تحت التنفيذ لكل المشروعات بطريقة نسبة الإنجاز في تاريخ
  FUNCTION wip_html(p_period_end IN DATE DEFAULT NULL) RETURN CLOB;
  -- ربحية العقد المتوقعة للمشروع (بطاقة في مساحة عمل المشروع)
  FUNCTION forecast_html(p_project_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- المعدات
  -- {"id","code","name","type","ownership":"OWNED|RENTED","asset","rate","status"}
  FUNCTION save_equipment(p_doc IN CLOB) RETURN NUMBER;
  -- {"equipment","project","wbs","date","hours","rate"}
  FUNCTION log_usage(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION post_usage(p_project_id IN NUMBER, p_upto IN DATE DEFAULT NULL) RETURN NUMBER;
  FUNCTION equipment_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;

  -- ---------------------------------------------------------- خطابات الضمان
  -- {"id","no","type","direction","project","contract","bank","beneficiary","amount","issue","expiry","margin","notes"}
  FUNCTION save_guarantee(p_doc IN CLOB) RETURN NUMBER;
  -- ISSUE (بغطاء من p_place) | EXTEND (p_expiry) | REDUCE (p_amount) | RELEASE (يعود الغطاء) | LIQUIDATE (تسييل) | EXPIRE
  PROCEDURE guarantee_action(p_id IN NUMBER, p_action IN VARCHAR2, p_date IN DATE DEFAULT NULL, p_amount IN NUMBER DEFAULT NULL,
                             p_expiry IN DATE DEFAULT NULL, p_place IN VARCHAR2 DEFAULT NULL, p_reason IN VARCHAR2 DEFAULT NULL);
  FUNCTION guarantees_html(p_days IN NUMBER DEFAULT 60) RETURN CLOB;
  FUNCTION expiring_count(p_days IN NUMBER DEFAULT 30) RETURN NUMBER;
  FUNCTION guarantee_status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION guarantee_type_label(p_type IN VARCHAR2) RETURN VARCHAR2;

  -- ---------------------------------------------------------- الحساب الختامي
  FUNCTION final_account_html(p_contract_id IN NUMBER) RETURN CLOB;
END NOONA_PRJ_CTR_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PRJ_CTR_PKG AS

  c_run   CONSTANT VARCHAR2(30) := 'PRJ_REVENUE_RUN';
  c_use   CONSTANT VARCHAR2(30) := 'PRJ_EQUIPMENT_USAGE';
  c_guar  CONSTANT VARCHAR2(30) := 'PRJ_GUARANTEE';

  TYPE t_calc IS RECORD (
    method VARCHAR2(30), cv NUMBER, penalties NUMBER, eac NUMBER, cost NUMBER, poc NUMBER, revenue NUMBER, billed NUMBER,
    asset NUMBER, liab NUMBER, loss NUMBER, provision NUMBER, profit NUMBER);

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p < 0 THEN '(' || TO_CHAR(-p, 'FM999,999,999,990.00') || ')' ELSE TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00') END;
  END fmt;
  FUNCTION pct(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(NVL(p, 0), 'FM990.0') || '%'; END pct;
  FUNCTION ds(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END ds;
  FUNCTION d(p VARCHAR2) RETURN DATE IS BEGIN RETURN TO_DATE(p, 'YYYY-MM-DD'); END d;

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
    IF NVL(ROUND(p_dr, 2), 0) = 0 AND NVL(ROUND(p_cr, 2), 0) = 0 THEN RETURN; END IF;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := ROUND(NVL(p_dr, 0), 2);
    p_lines(p_lines.COUNT).credit := ROUND(NVL(p_cr, 0), 2);
    p_lines(p_lines.COUNT).cost_center_id := p_cc;
    p_lines(p_lines.COUNT).party_id := p_party;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
  END add_line;
  -- سطر بفرق موجب أو سالب: الموجب في جانب p_side ('D' أو 'C') والسالب في الجانب الآخر
  PROCEDURE add_delta(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_delta NUMBER, p_side VARCHAR2, p_cc NUMBER, p_desc VARCHAR2) IS
  BEGIN
    IF p_side = 'D' THEN add_line(p_lines, p_acc, GREATEST(p_delta, 0), GREATEST(-p_delta, 0), p_cc, NULL, p_desc);
    ELSE add_line(p_lines, p_acc, GREATEST(-p_delta, 0), GREATEST(p_delta, 0), p_cc, NULL, p_desc); END IF;
  END add_delta;

  FUNCTION project(p_id NUMBER) RETURN prj_project%ROWTYPE IS
    l prj_project%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM prj_project WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-010', 'المشروع غير موجود', 'Project not found');
  END project;

  -- ================================================================ الاعتراف بالإيراد
  FUNCTION is_poc(p_project_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(revenue_method) INTO l FROM prj_project WHERE id = p_project_id;
    RETURN CASE WHEN l IN ('COST_TO_COST', 'PERCENT_COMPLETE') THEN 'Y' ELSE 'N' END;
  END is_poc;

  FUNCTION calc(p prj_project%ROWTYPE, p_period_end DATE, p_eac NUMBER) RETURN t_calc IS
    r t_calc;
  BEGIN
    r.method := p.revenue_method;
    SELECT NVL(SUM(NOONA_PRJ_PKG.contract_value(c.id)), 0) INTO r.cv FROM prj_contract c
     WHERE c.project_id = p.id AND c.contract_type = 'MAIN_CONTRACT' AND c.status_code IN ('ACTIVE', 'COMPLETED');
    -- المفوتر من الإيراد: قيمة مستخلصات الأعمال المعتمدة ناقص الخصومات والغرامات (حتى نهاية الفترة)
    SELECT NVL(SUM(cl.penalty_amount), 0), NVL(SUM(cl.current_gross - cl.other_deductions - cl.penalty_amount), 0)
      INTO r.penalties, r.billed
      FROM prj_progress_claim cl JOIN prj_contract c ON c.id = cl.contract_id
     WHERE c.project_id = p.id AND cl.claim_direction = 'RECEIVABLE' AND cl.claim_kind = 'PROGRESS'
       AND cl.status_code IN ('APPROVED', 'PAID') AND cl.doc_date <= p_period_end;
    SELECT NVL(SUM(amount_func), 0) INTO r.cost FROM prj_cost_line
     WHERE project_id = p.id AND status_code = 'POSTED' AND is_commitment = 'N' AND cost_date <= p_period_end;
    r.eac := NVL(p_eac, p.estimated_total_cost);
    r.poc := CASE WHEN p.revenue_method = 'PERCENT_COMPLETE' THEN NOONA_PRJ_PKG.project_progress(p.id)
                  WHEN NVL(r.eac, 0) > 0 THEN LEAST(ROUND(r.cost / r.eac * 100, 4), 100) ELSE 0 END;
    r.revenue := ROUND((r.cv - r.penalties) * r.poc / 100, 2);
    r.asset := GREATEST(r.revenue - r.billed, 0);
    r.liab := GREATEST(r.billed - r.revenue, 0);
    r.profit := (r.cv - r.penalties) - NVL(r.eac, 0);
    r.loss := GREATEST(-r.profit, 0);
    -- الخسارة المتوقعة كلها تثبت فوراً: ما لم يظهر منها بعد في الإيراد والتكلفة حتى تاريخه يكون مخصصاً
    r.provision := ROUND(r.loss * (1 - r.poc / 100), 2);
    RETURN r;
  END calc;

  FUNCTION preview_json(p_project_id IN NUMBER, p_period_end IN DATE, p_eac IN NUMBER DEFAULT NULL) RETURN CLOB IS
    r t_calc := calc(project(p_project_id), NVL(p_period_end, TRUNC(SYSDATE)), p_eac);
    l CLOB;
  BEGIN
    SELECT JSON_OBJECT('method' VALUE r.method, 'contractValue' VALUE r.cv, 'penalties' VALUE r.penalties, 'eac' VALUE r.eac,
                       'costToDate' VALUE r.cost, 'poc' VALUE r.poc, 'revenueToDate' VALUE r.revenue, 'billedToDate' VALUE r.billed,
                       'contractAsset' VALUE r.asset, 'contractLiability' VALUE r.liab, 'expectedProfit' VALUE r.profit,
                       'lossProvision' VALUE r.provision RETURNING CLOB) INTO l FROM dual;
    RETURN l;
  END preview_json;

  FUNCTION run_revenue(p_project_id IN NUMBER, p_period_end IN DATE, p_eac IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    p      prj_project%ROWTYPE := project(p_project_id);
    l_end  DATE := TRUNC(NVL(p_period_end, SYSDATE));
    r      t_calc;
    l_prev prj_revenue_run%ROWTYPE;
    l_n    NUMBER;
    l_id   NUMBER;
    l_j    NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_desc VARCHAR2(500);
  BEGIN
    guard('PRJ_REVENUE_RUN.CREATE');
    NOONA_CORE_PKG.assert(is_poc(p.id) = 'Y', 'NOONA-PRJ-120',
      'طريقة الاعتراف بإيراد المشروع ليست نسبة الإنجاز؛ اخترها في بيانات المشروع (بالتكلفة أو بالإنجاز الفعلي)',
      'Project revenue method is not percentage of completion');
    r := calc(p, l_end, p_eac);
    NOONA_CORE_PKG.assert(r.cv > 0, 'NOONA-PRJ-121', 'لا يوجد عقد رئيسي معتمد للمشروع', 'No approved main contract');
    NOONA_CORE_PKG.assert(NVL(r.eac, 0) > 0, 'NOONA-PRJ-122', 'أدخل التكلفة المتوقعة عند الإنجاز للمشروع', 'Estimated total cost is required');
    SELECT COUNT(*) INTO l_n FROM prj_revenue_run WHERE project_id = p.id AND status_code = 'POSTED' AND period_end >= l_end;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRJ-123', 'يوجد اعتراف مرحل لهذه الفترة أو بعدها؛ اعكسه أولاً لإعادة التشغيل',
                          'A later or same-period run exists; reverse it first');
    BEGIN
      SELECT * INTO l_prev FROM (SELECT * FROM prj_revenue_run WHERE project_id = p.id AND status_code = 'POSTED'
                                  ORDER BY period_end DESC) WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_prev.contract_asset := 0; l_prev.contract_liability := 0; l_prev.loss_provision := 0;
    END;
    UPDATE prj_project SET estimated_total_cost = r.eac WHERE id = p.id;
    -- إعادة تشغيل فترة معكوسة: يحل التشغيل الجديد محل القديم
    DELETE FROM prj_revenue_run WHERE project_id = p.id AND period_end = l_end AND status_code = 'REVERSED';
    INSERT INTO prj_revenue_run (company_id, project_id, period_end, revenue_method, contract_value, estimated_total_cost, cost_to_date, poc_pct,
                                 revenue_to_date, billed_to_date, contract_asset, contract_liability, expected_loss, loss_provision, status_code)
    VALUES (company, p.id, l_end, r.method, r.cv, r.eac, r.cost, r.poc, r.revenue, r.billed, r.asset, r.liab, r.loss, r.provision, 'POSTED')
    RETURNING id INTO l_id;
    l_desc := 'الاعتراف بإيراد العقد حسب نسبة الإنجاز ' || pct(r.poc) || ' - ' || p.code || ' - ' || ds(l_end);
    -- الفرق عن آخر تشغيل: أصول العقود (مدين)، التزامات العقود (دائن)، وتسوية الإيراد بالصافي
    add_delta(l_lines, NOONA_PRJ_PKG.acc('CONTRACT_ASSET'), r.asset - l_prev.contract_asset, 'D', NULL, l_desc);
    add_delta(l_lines, NOONA_PRJ_PKG.acc('CONTRACT_LIAB'), r.liab - l_prev.contract_liability, 'C', NULL, l_desc);
    add_delta(l_lines, NOONA_PRJ_PKG.acc('REV_ADJ'), (r.asset - r.liab) - (l_prev.contract_asset - l_prev.contract_liability), 'C',
              p.cost_center_id, l_desc);
    -- مخصص الخسارة المتبقية
    add_delta(l_lines, NOONA_PRJ_PKG.acc('LOSS_EXP'), r.provision - l_prev.loss_provision, 'D', p.cost_center_id, 'مخصص خسارة العقد ' || l_desc);
    add_delta(l_lines, NOONA_PRJ_PKG.acc('LOSS_PROV'), r.provision - l_prev.loss_provision, 'C', NULL, 'مخصص خسارة العقد ' || l_desc);
    IF l_lines.COUNT > 0 THEN
      l_j := NOONA_ACE_PKG.post_source('PRJ_REVENUE_RECOGNITION', 'PROJECTS', c_run, l_id, l_end, l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                       l_lines, 'WIP-' || p.code || '-' || TO_CHAR(l_end, 'YYYYMMDD'), NULL, 'PROJECTS');
      UPDATE prj_revenue_run SET gl_journal_id = l_j WHERE id = l_id;
    END IF;
    NOONA_AUDIT_PKG.log_event('POSTING', c_run, l_id, 'RUN', 'SUCCESS');
    RETURN l_id;
  END run_revenue;

  PROCEDURE reverse_run(p_run_id IN NUMBER, p_reason IN VARCHAR2) IS
    l   prj_revenue_run%ROWTYPE;
    l_n NUMBER;
    l_j NUMBER;
  BEGIN
    guard('PRJ_REVENUE_RUN.UPDATE');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-PRJ-124', 'اكتب سبب العكس', 'Reason is required');
    SELECT * INTO l FROM prj_revenue_run WHERE id = p_run_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'POSTED', 'NOONA-PRJ-125', 'التشغيل معكوس سابقاً', 'Run already reversed');
    SELECT COUNT(*) INTO l_n FROM prj_revenue_run WHERE project_id = l.project_id AND status_code = 'POSTED' AND period_end > l.period_end;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRJ-126', 'يعكس آخر تشغيل للمشروع أولاً', 'Reverse the latest run first');
    IF l.gl_journal_id IS NOT NULL THEN
      l_j := NOONA_ACE_PKG.reverse_source(c_run, p_run_id, l.period_end, p_reason);
    END IF;
    UPDATE prj_revenue_run SET status_code = 'REVERSED' WHERE id = p_run_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-127', 'التشغيل غير موجود', 'Run not found');
  END reverse_run;

  FUNCTION wip_html(p_period_end IN DATE DEFAULT NULL) RETURN CLOB IS
    l_end DATE := TRUNC(NVL(p_period_end, SYSDATE));
    l     CLOB;
    r     t_calc;
    n     PLS_INTEGER := 0;
    t_cv NUMBER := 0; t_eac NUMBER := 0; t_cost NUMBER := 0; t_rev NUMBER := 0; t_bil NUMBER := 0; t_as NUMBER := 0; t_li NUMBER := 0;
    t_pr NUMBER := 0; t_pv NUMBER := 0;
    l_last VARCHAR2(30);
    p      prj_project%ROWTYPE;
  BEGIN
    guard('PRJ_REVENUE_RUN.VIEW');
    l := NOONA_BRAND_PKG.report_header('كشف الأعمال تحت التنفيذ (الاعتراف بالإيراد حسب نسبة الإنجاز) في ' || ds(l_end))
      || '<table class="nn-rpt nn-prj-wip"><thead><tr><th>المشروع</th><th>الطريقة</th><th>قيمة العقد</th><th>التكلفة المتوقعة</th>'
      || '<th>التكلفة حتى تاريخه</th><th>الإنجاز</th><th>الإيراد المستحق</th><th>المفوتر</th><th>أصول العقود</th><th>التزامات العقود</th>'
      || '<th>الربح المتوقع</th><th>مخصص الخسارة</th><th>آخر اعتراف</th></tr></thead><tbody>';
    FOR x IN (SELECT id FROM prj_project WHERE company_id = company AND revenue_method IN ('COST_TO_COST', 'PERCENT_COMPLETE')
                 AND status_code NOT IN ('CANCELLED') ORDER BY code) LOOP
      p := project(x.id);
      r := calc(p, l_end, NULL);
      SELECT MAX(TO_CHAR(period_end, 'YYYY-MM-DD')) INTO l_last FROM prj_revenue_run WHERE project_id = p.id AND status_code = 'POSTED';
      n := n + 1;
      l := l || '<tr' || CASE WHEN r.profit < 0 THEN ' class="is-bad"' END || '><td>' || esc(p.code || ' - ' || p.name_ar) || '</td><td>'
        || CASE p.revenue_method WHEN 'COST_TO_COST' THEN 'بالتكلفة' ELSE 'بالإنجاز الفعلي' END || '</td><td>' || fmt(r.cv - r.penalties)
        || '</td><td>' || fmt(r.eac) || '</td><td>' || fmt(r.cost) || '</td><td>' || pct(r.poc) || '</td><td>' || fmt(r.revenue)
        || '</td><td>' || fmt(r.billed) || '</td><td>' || fmt(r.asset) || '</td><td>' || fmt(r.liab) || '</td><td>' || fmt(r.profit)
        || '</td><td>' || fmt(r.provision) || '</td><td>' || NVL(l_last, '-') || '</td></tr>';
      t_cv := t_cv + r.cv - r.penalties; t_eac := t_eac + NVL(r.eac, 0); t_cost := t_cost + r.cost; t_rev := t_rev + r.revenue;
      t_bil := t_bil + r.billed; t_as := t_as + r.asset; t_li := t_li + r.liab; t_pr := t_pr + r.profit; t_pv := t_pv + r.provision;
    END LOOP;
    IF n = 0 THEN
      RETURN '<div class="nn-empty">لا توجد مشروعات بطريقة نسبة الإنجاز؛ اخترها في «بيانات المشروع» (طريقة الاعتراف بالإيراد)</div>';
    END IF;
    RETURN l || '</tbody><tfoot><tr><td colspan="2">الإجمالي</td><td>' || fmt(t_cv) || '</td><td>' || fmt(t_eac) || '</td><td>' || fmt(t_cost)
      || '</td><td></td><td>' || fmt(t_rev) || '</td><td>' || fmt(t_bil) || '</td><td>' || fmt(t_as) || '</td><td>' || fmt(t_li) || '</td><td>'
      || fmt(t_pr) || '</td><td>' || fmt(t_pv) || '</td><td></td></tr></tfoot></table>'
      || '<p class="nn-hint">الإيراد المستحق = نسبة الإنجاز × (قيمة العقد − غرامات التأخير). أصول العقود: إيراد تحقق ولم يفوتر بعد؛ '
      || 'التزامات العقود: مستخلصات تتجاوز الإنجاز. العقد الخاسر يثبت مخصص لكامل خسارته المتبقية فور توقعها. '
      || 'الأرقام هنا معاينة بالتقدير الحالي؛ يرحل الفرق بزر «اعتراف بالإيراد» لكل مشروع.</p>' || NOONA_GL_PKG.report_footer;
  END wip_html;

  FUNCTION forecast_html(p_project_id IN NUMBER) RETURN CLOB IS
    p      prj_project%ROWTYPE := project(p_project_id);
    r      t_calc := calc(p, TRUNC(SYSDATE), NVL(p.estimated_total_cost, NULLIF(p.budget_amount, 0)));
    l_last prj_revenue_run%ROWTYPE;
    l_m    NUMBER;
  BEGIN
    BEGIN
      SELECT * INTO l_last FROM (SELECT * FROM prj_revenue_run WHERE project_id = p.id AND status_code = 'POSTED' ORDER BY period_end DESC)
       WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL; END;
    l_m := CASE WHEN r.cv - r.penalties > 0 THEN ROUND(r.profit / (r.cv - r.penalties) * 100, 1) END;
    RETURN '<div class="nn-prj-fc' || CASE WHEN r.profit < 0 THEN ' is-loss' END || '">'
      || '<div><small>قيمة العقد (بعد الغرامات)</small><b>' || fmt(r.cv - r.penalties) || '</b></div>'
      || '<div><small>التكلفة المتوقعة عند الإنجاز' || CASE WHEN p.estimated_total_cost IS NULL THEN ' (الموازنة)' END || '</small><b>' || fmt(r.eac) || '</b></div>'
      || '<div><small>التكلفة حتى تاريخه</small><b>' || fmt(r.cost) || '</b></div>'
      || '<div><small>المتبقي حتى الإنجاز</small><b>' || fmt(GREATEST(NVL(r.eac, 0) - r.cost, 0)) || '</b></div>'
      || '<div><small>الربح المتوقع</small><b>' || fmt(r.profit) || CASE WHEN l_m IS NOT NULL THEN ' <i>' || TO_CHAR(l_m, 'FM990.0') || '%</i>' END || '</b></div>'
      || '<div><small>نسبة الإنجاز للاعتراف</small><b>' || CASE WHEN is_poc(p.id) = 'Y' THEN pct(r.poc) ELSE 'بالفوترة' END || '</b></div>'
      || CASE WHEN l_last.id IS NOT NULL THEN '<div><small>آخر اعتراف بالإيراد</small><b>' || ds(l_last.period_end) || '</b></div>' END
      || CASE WHEN r.profit < 0 THEN '<p class="nn-prj-fc-warn">عقد خاسر متوقع بخسارة ' || fmt(r.loss) || '؛ يثبت مخصصها عند الاعتراف بالإيراد</p>' END
      || '</div>';
  END forecast_html;

  -- ================================================================ المعدات
  FUNCTION save_equipment(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id NUMBER := jn(l_o, 'id');
    l_rt NUMBER := jn(l_o, 'rate');
    l_ow VARCHAR2(30) := NVL(js(l_o, 'ownership'), 'OWNED');
    l_cd VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_nm VARCHAR2(200) := js(l_o, 'name');
    l_tp VARCHAR2(100) := js(l_o, 'type');
    l_as NUMBER := jn(l_o, 'asset');
    l_st VARCHAR2(30) := js(l_o, 'status');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'PRJ_EQUIPMENT.CREATE' ELSE 'PRJ_EQUIPMENT.UPDATE' END);
    NOONA_CORE_PKG.assert(js(l_o, 'code') IS NOT NULL AND js(l_o, 'name') IS NOT NULL, 'NOONA-PRJ-130', 'رمز المعدة واسمها مطلوبان', 'Code and name are required');
    NOONA_CORE_PKG.assert(NVL(l_rt, 0) > 0, 'NOONA-PRJ-131', 'تكلفة الساعة موجبة', 'Hourly rate must be positive');
    NOONA_CORE_PKG.assert(l_ow IN ('OWNED', 'RENTED'), 'NOONA-PRJ-132', 'الملكية: مملوكة أو مستأجرة', 'Invalid ownership');
    IF l_id IS NULL THEN
      INSERT INTO prj_equipment (company_id, code, name_ar, name_en, equipment_type, ownership, asset_id, hourly_rate, status_code)
      VALUES (company, l_cd, l_nm, l_nm, l_tp, l_ow, l_as, l_rt, 'ACTIVE')
      RETURNING id INTO l_id;
    ELSE
      UPDATE prj_equipment SET code = l_cd, name_ar = l_nm, equipment_type = l_tp, ownership = l_ow,
                               asset_id = l_as, hourly_rate = l_rt, status_code = NVL(l_st, status_code)
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-133', 'رمز المعدة مستخدم', 'Equipment code already used');
  END save_equipment;

  FUNCTION log_usage(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_eq  prj_equipment%ROWTYPE;
    p     prj_project%ROWTYPE := project(jn(l_o, 'project'));
    l_h   NUMBER := jn(l_o, 'hours');
    l_r   NUMBER;
    l_w   NUMBER := jn(l_o, 'wbs');
    l_id  NUMBER;
    l_eid NUMBER := jn(l_o, 'equipment');
    l_dt  DATE := NVL(d(js(l_o, 'date')), TRUNC(SYSDATE));
  BEGIN
    guard('PRJ_EQUIPMENT_USAGE.CREATE');
    BEGIN
      SELECT * INTO l_eq FROM prj_equipment WHERE id = l_eid AND company_id = company;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-PRJ-134', 'اختر المعدة', 'Equipment is required');
    END;
    NOONA_CORE_PKG.assert(l_eq.status_code = 'ACTIVE', 'NOONA-PRJ-135', 'المعدة غير نشطة', 'Equipment is inactive');
    NOONA_CORE_PKG.assert(p.status_code NOT IN ('CLOSED', 'CANCELLED', 'COMPLETED'), 'NOONA-PRJ-016', 'المشروع مغلق', 'Project is closed');
    NOONA_CORE_PKG.assert(l_h > 0 AND l_h <= 24, 'NOONA-PRJ-136', 'ساعات التشغيل بين 0 و 24', 'Hours must be between 0 and 24');
    l_r := NVL(jn(l_o, 'rate'), l_eq.hourly_rate);
    IF l_w IS NULL THEN
      SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN code = 'GEN' THEN 0 ELSE 1 END, code) INTO l_w
        FROM prj_wbs WHERE project_id = p.id AND status_code <> 'CANCELLED';
    END IF;
    INSERT INTO prj_equipment_usage (company_id, equipment_id, project_id, wbs_id, usage_date, hours, rate, amount, status_code)
    VALUES (company, l_eq.id, p.id, l_w, l_dt, l_h, l_r, ROUND(l_h * l_r, 2), 'DRAFT')
    RETURNING id INTO l_id;
    RETURN l_id;
  END log_usage;

  FUNCTION post_usage(p_project_id IN NUMBER, p_upto IN DATE DEFAULT NULL) RETURN NUMBER IS
    p       prj_project%ROWTYPE := project(p_project_id);
    l_n     NUMBER := 0;
    l_lines NOONA_GL_PKG.t_lines;
    l_j     NUMBER;
    l_c     NUMBER;
    l_desc  VARCHAR2(1000);
  BEGIN
    guard('PRJ_EQUIPMENT_USAGE.UPDATE');
    FOR u IN (SELECT x.*, e.code eq_code, e.name_ar eq_name FROM prj_equipment_usage x JOIN prj_equipment e ON e.id = x.equipment_id
               WHERE x.project_id = p.id AND x.status_code = 'DRAFT' AND x.usage_date <= NVL(p_upto, TRUNC(SYSDATE))
               ORDER BY x.usage_date, x.id FOR UPDATE OF x.status_code) LOOP
      l_desc := 'تشغيل معدة ' || u.eq_code || ' - ' || u.eq_name || ' ' || u.hours || ' ساعة ' || ds(u.usage_date) || ' - مشروع ' || p.code;
      l_lines := NOONA_GL_PKG.t_lines();
      add_line(l_lines, NOONA_PRJ_PKG.acc('COST'), u.amount, 0, p.cost_center_id, NULL, l_desc);
      add_line(l_lines, NOONA_PRJ_PKG.acc('EQUIP_APPLIED'), 0, u.amount, NULL, NULL, l_desc);
      l_j := NOONA_ACE_PKG.post_source('PRJ_EQUIPMENT_POSTED', 'PROJECTS', c_use, u.id, u.usage_date, l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                       l_lines, u.eq_code, NULL, 'PROJECTS');
      l_c := NOONA_PRJ_PKG.add_cost(p.id, u.wbs_id, 'EQUIPMENT', u.usage_date, u.amount, u.hours, l_desc, u.eq_code, c_use, u.id);
      UPDATE prj_equipment_usage SET status_code = 'POSTED', cost_line_id = l_c WHERE id = u.id;
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-PRJ-137', 'لا يوجد تشغيل معدات غير محمل', 'No pending equipment usage');
    RETURN l_n;
  END post_usage;

  FUNCTION equipment_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l   CLOB;
    n   PLS_INTEGER := 0;
    t_h NUMBER := 0; t_a NUMBER := 0;
    l_days NUMBER := GREATEST(TRUNC(NVL(p_to, SYSDATE)) - TRUNC(NVL(p_from, SYSDATE)) + 1, 1);
  BEGIN
    guard('PRJ_EQUIPMENT.VIEW');
    l := NOONA_BRAND_PKG.report_header('تشغيل المعدات على المشروعات من ' || ds(p_from) || ' إلى ' || ds(p_to))
      || '<table class="nn-rpt"><thead><tr><th>المعدة</th><th>النوع</th><th>الملكية</th><th>تكلفة الساعة</th><th>الساعات</th>'
      || '<th>الاستغلال (من 8 ساعات يومياً)</th><th>التكلفة المحملة</th><th>المشروعات</th><th>بانتظار التحميل</th></tr></thead><tbody>';
    FOR e IN (SELECT e.code, e.name_ar, e.equipment_type, e.ownership, e.hourly_rate,
                     NVL(SUM(CASE WHEN u.status_code = 'POSTED' THEN u.hours END), 0) hrs,
                     NVL(SUM(CASE WHEN u.status_code = 'POSTED' THEN u.amount END), 0) amt,
                     COUNT(DISTINCT CASE WHEN u.status_code = 'POSTED' THEN u.project_id END) prj,
                     NVL(SUM(CASE WHEN u.status_code = 'DRAFT' THEN u.hours END), 0) pend
                FROM prj_equipment e LEFT JOIN prj_equipment_usage u ON u.equipment_id = e.id AND u.usage_date BETWEEN p_from AND p_to
               WHERE e.company_id = company GROUP BY e.code, e.name_ar, e.equipment_type, e.ownership, e.hourly_rate ORDER BY e.code) LOOP
      n := n + 1; t_h := t_h + e.hrs; t_a := t_a + e.amt;
      l := l || '<tr><td>' || esc(e.code || ' - ' || e.name_ar) || '</td><td>' || esc(e.equipment_type) || '</td><td>'
        || CASE e.ownership WHEN 'RENTED' THEN 'مستأجرة' ELSE 'مملوكة' END || '</td><td>' || fmt(e.hourly_rate) || '</td><td>' || e.hrs
        || '</td><td>' || pct(e.hrs / (l_days * 8) * 100) || '</td><td>' || fmt(e.amt) || '</td><td>' || e.prj || '</td><td>'
        || CASE WHEN e.pend > 0 THEN e.pend || ' ساعة' ELSE '-' END || '</td></tr>';
    END LOOP;
    IF n = 0 THEN RETURN '<div class="nn-empty">لا توجد معدات؛ أضفها من «المعدات وتشغيلها»</div>'; END IF;
    RETURN l || '</tbody><tfoot><tr><td colspan="4">الإجمالي</td><td>' || t_h || '</td><td></td><td>' || fmt(t_a) || '</td><td colspan="2"></td></tr></tfoot></table>';
  END equipment_html;

  -- ================================================================ خطابات الضمان
  FUNCTION guarantee_status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'REQUESTED' THEN 'مطلوب' WHEN 'ISSUED' THEN 'صادر' WHEN 'ACTIVE' THEN 'ساري' WHEN 'EXTENDED' THEN 'ممدد'
      WHEN 'REDUCED' THEN 'مخفض' WHEN 'RELEASED' THEN 'مفرج عنه' WHEN 'LIQUIDATED' THEN 'مسيل' WHEN 'EXPIRED' THEN 'منتهٍ' ELSE p_status END;
  END guarantee_status_label;
  FUNCTION guarantee_type_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'BID' THEN 'ابتدائي (عطاء)' WHEN 'PERFORMANCE' THEN 'نهائي (حسن تنفيذ)' WHEN 'ADVANCE_PAYMENT' THEN 'دفعة مقدمة'
      WHEN 'RETENTION' THEN 'بدل محتجز' WHEN 'MAINTENANCE' THEN 'صيانة' WHEN 'CUSTOMS' THEN 'جمركي' ELSE p_type END;
  END guarantee_type_label;

  FUNCTION save_guarantee(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id  NUMBER := jn(l_o, 'id');
    l_tp  VARCHAR2(30) := js(l_o, 'type');
    l_dir VARCHAR2(30) := NVL(js(l_o, 'direction'), 'ISSUED_BY_US');
    l_amt NUMBER := jn(l_o, 'amount');
    l_mg  NUMBER := jn(l_o, 'margin');
    l_is  DATE := d(js(l_o, 'issue'));
    l_ex  DATE := d(js(l_o, 'expiry'));
    l_st  VARCHAR2(30);
    l_prj NUMBER := jn(l_o, 'project');
    l_no  VARCHAR2(100) := js(l_o, 'no');
    l_ct  NUMBER := jn(l_o, 'contract');
    l_bk  NUMBER := jn(l_o, 'bank');
    l_bn  NUMBER := jn(l_o, 'beneficiary');
    l_nt  VARCHAR2(500) := SUBSTR(js(l_o, 'notes'), 1, 500);
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'PRJ_GUARANTEE.CREATE' ELSE 'PRJ_GUARANTEE.UPDATE' END);
    NOONA_CORE_PKG.assert(js(l_o, 'no') IS NOT NULL, 'NOONA-PRJ-140', 'رقم خطاب الضمان مطلوب', 'Guarantee number is required');
    NOONA_CORE_PKG.assert(l_tp IN ('BID', 'PERFORMANCE', 'ADVANCE_PAYMENT', 'RETENTION', 'MAINTENANCE', 'CUSTOMS'), 'NOONA-PRJ-141',
                          'اختر نوع الخطاب', 'Invalid guarantee type');
    NOONA_CORE_PKG.assert(l_dir IN ('ISSUED_BY_US', 'RECEIVED_FROM_PARTY'), 'NOONA-PRJ-142', 'اتجاه غير صالح', 'Invalid direction');
    NOONA_CORE_PKG.assert(NVL(l_amt, 0) > 0 AND NVL(l_mg, 0) >= 0 AND NVL(l_mg, 0) <= l_amt, 'NOONA-PRJ-143',
                          'المبلغ موجب والغطاء النقدي بين صفر ومبلغ الخطاب', 'Invalid amount or margin');
    NOONA_CORE_PKG.assert(l_is IS NOT NULL AND l_ex > l_is, 'NOONA-PRJ-144', 'تاريخ الانتهاء بعد تاريخ الإصدار', 'Expiry must follow issue date');
    NOONA_CORE_PKG.assert(jn(l_o, 'bank') IS NOT NULL, 'NOONA-PRJ-145', 'اختر البنك المصدر', 'Bank is required');
    IF l_prj IS NULL AND l_ct IS NOT NULL THEN
      SELECT project_id INTO l_prj FROM prj_contract WHERE id = l_ct;
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO prj_guarantee (company_id, currency_code, exchange_rate, guarantee_no, guarantee_type, direction, project_id, contract_id, bank_id,
                                 beneficiary_party_id, amount, issue_date, expiry_date, margin_amount, notes, status_code)
      VALUES (company, NOONA_GL_PKG.ledger_currency, 1, l_no, l_tp, l_dir, l_prj, l_ct, l_bk, l_bn, l_amt, l_is, l_ex, l_mg, l_nt, 'REQUESTED')
      RETURNING id INTO l_id;
    ELSE
      SELECT status_code INTO l_st FROM prj_guarantee WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st = 'REQUESTED', 'NOONA-PRJ-146', 'الخطاب صادر؛ عدله بالتمديد أو التخفيض', 'Issued guarantee: use extend or reduce');
      UPDATE prj_guarantee SET guarantee_no = l_no, guarantee_type = l_tp, direction = l_dir, project_id = l_prj,
                               contract_id = l_ct, bank_id = l_bk, beneficiary_party_id = l_bn,
                               amount = l_amt, issue_date = l_is, expiry_date = l_ex, margin_amount = l_mg, notes = l_nt
       WHERE id = l_id;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-147', 'رقم الخطاب مستخدم', 'Guarantee number already used');
  END save_guarantee;

  PROCEDURE guarantee_action(p_id IN NUMBER, p_action IN VARCHAR2, p_date IN DATE DEFAULT NULL, p_amount IN NUMBER DEFAULT NULL,
                             p_expiry IN DATE DEFAULT NULL, p_place IN VARCHAR2 DEFAULT NULL, p_reason IN VARCHAR2 DEFAULT NULL) IS
    g       prj_guarantee%ROWTYPE;
    l_dt    DATE := TRUNC(NVL(p_date, SYSDATE));
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_x     NUMBER;
    l_desc  VARCHAR2(500);
    l_cc    NUMBER;
    l_live  BOOLEAN;
    l_party VARCHAR2(400);
  BEGIN
    guard('PRJ_GUARANTEE.UPDATE');
    SELECT * INTO g FROM prj_guarantee WHERE id = p_id AND company_id = company FOR UPDATE;
    l_live := g.status_code IN ('ISSUED', 'ACTIVE', 'EXTENDED', 'REDUCED');
    SELECT MAX(cost_center_id) INTO l_cc FROM prj_project WHERE id = g.project_id;
    SELECT MAX(display_name_ar) INTO l_party FROM pty_party WHERE id = g.beneficiary_party_id;
    l_desc := 'خطاب ضمان ' || guarantee_type_label(g.guarantee_type) || ' رقم ' || g.guarantee_no;
    CASE UPPER(p_action)
    WHEN 'ISSUE' THEN
      NOONA_CORE_PKG.assert(g.status_code = 'REQUESTED', 'NOONA-PRJ-150', 'الخطاب صادر سابقاً', 'Already issued');
      IF g.direction = 'ISSUED_BY_US' AND NVL(g.margin_amount, 0) > 0 THEN
        NOONA_CORE_PKG.assert(p_place IS NOT NULL, 'NOONA-PRJ-151', 'اختر البنك الذي يخصم منه الغطاء النقدي', 'Choose the bank for the margin');
        add_line(l_lines, NOONA_PRJ_PKG.acc('GUAR_MARGIN'), g.margin_amount, 0, NULL, g.beneficiary_party_id, 'غطاء ' || l_desc);
        add_line(l_lines, NOONA_CSH_PKG.place_account(p_place), 0, g.margin_amount, NULL, NULL, 'غطاء ' || l_desc);
        l_j := NOONA_ACE_PKG.post_source('PRJ_GUARANTEE_MARGIN', 'PROJECTS', c_guar, g.id, l_dt, 'غطاء ' || l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                         l_lines, g.guarantee_no, NULL, 'PROJECTS');
        SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
        l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', p_place, l_dt, g.margin_amount, g.beneficiary_party_id, l_party, c_guar, g.id,
                                               'LG-' || g.guarantee_no, 'غطاء ' || l_desc, l_ev);
        UPDATE prj_guarantee SET margin_journal_id = l_j WHERE id = g.id;
      END IF;
      UPDATE prj_guarantee SET status_code = 'ACTIVE', issue_date = NVL(p_date, issue_date) WHERE id = g.id;
    WHEN 'EXTEND' THEN
      NOONA_CORE_PKG.assert(l_live AND p_expiry > g.expiry_date, 'NOONA-PRJ-152', 'التمديد لتاريخ بعد الانتهاء الحالي لخطاب ساري',
                            'Extension must be later than the current expiry');
      l_desc := SUBSTR(g.notes || ' | تمديد إلى ' || ds(p_expiry) || NVL2(p_reason, ': ' || p_reason, ''), 1, 500);
      UPDATE prj_guarantee SET expiry_date = p_expiry, status_code = 'EXTENDED', notes = l_desc WHERE id = g.id;
    WHEN 'REDUCE' THEN
      NOONA_CORE_PKG.assert(l_live AND p_amount > 0 AND p_amount < g.amount AND p_amount >= NVL(g.margin_amount, 0), 'NOONA-PRJ-153',
                            'المبلغ الجديد أقل من الحالي ولا يقل عن الغطاء النقدي', 'Invalid reduced amount');
      l_desc := SUBSTR(g.notes || ' | تخفيض من ' || fmt(g.amount) || NVL2(p_reason, ': ' || p_reason, ''), 1, 500);
      UPDATE prj_guarantee SET amount = p_amount, status_code = 'REDUCED', notes = l_desc WHERE id = g.id;
    WHEN 'RELEASE' THEN
      NOONA_CORE_PKG.assert(l_live, 'NOONA-PRJ-154', 'الخطاب غير ساري', 'Guarantee is not active');
      IF g.margin_journal_id IS NOT NULL THEN
        NOONA_CORE_PKG.assert(p_place IS NOT NULL, 'NOONA-PRJ-155', 'اختر البنك الذي يعود إليه الغطاء النقدي', 'Choose the bank for the margin');
        -- عكس قيد الغطاء يعيده للبنك ويظهر في دفتر النقدية تلقائياً (عكس حركة الصرف)
        l_j := NOONA_ACE_PKG.reverse_source(c_guar, g.id, l_dt, 'إفراج عن ' || l_desc);
      END IF;
      UPDATE prj_guarantee SET status_code = 'RELEASED', release_date = l_dt WHERE id = g.id;
    WHEN 'LIQUIDATE' THEN
      NOONA_CORE_PKG.assert(l_live, 'NOONA-PRJ-154', 'الخطاب غير ساري', 'Guarantee is not active');
      NOONA_CORE_PKG.assert(p_place IS NOT NULL, 'NOONA-PRJ-156', 'اختر البنك', 'Choose the bank');
      NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-PRJ-157', 'اكتب سبب التسييل', 'Reason is required');
      IF g.direction = 'ISSUED_BY_US' THEN
        -- سيله المستفيد: يعود الغطاء (عكس قيده) ثم يخصم البنك كامل المبلغ؛ الخسارة على المشروع
        IF g.margin_journal_id IS NOT NULL THEN
          l_j := NOONA_ACE_PKG.reverse_source(c_guar, g.id, l_dt, 'تسييل ' || l_desc);
        END IF;
        add_line(l_lines, NOONA_PRJ_PKG.acc('GUAR_LOSS'), g.amount, 0, l_cc, g.beneficiary_party_id, 'تسييل ' || l_desc || ': ' || p_reason);
        add_line(l_lines, NOONA_CSH_PKG.place_account(p_place), 0, g.amount, NULL, NULL, 'تسييل ' || l_desc);
        l_j := NOONA_ACE_PKG.post_source('PRJ_GUARANTEE_MARGIN', 'PROJECTS', c_guar, g.id, l_dt, 'تسييل ' || l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                         l_lines, g.guarantee_no, NULL, 'PROJECTS');
        SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
        l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', p_place, l_dt, g.amount, g.beneficiary_party_id, l_party, c_guar, g.id,
                                               'LGL-' || g.guarantee_no, 'تسييل ' || l_desc, l_ev);
      ELSE
        -- سيلناه على مقاول الباطن: يقبض البنك المبلغ كإيراد غرامات
        add_line(l_lines, NOONA_CSH_PKG.place_account(p_place), g.amount, 0, NULL, NULL, 'تسييل ' || l_desc);
        add_line(l_lines, NOONA_PRJ_PKG.acc('PENALTY_INC'), 0, g.amount, l_cc, g.beneficiary_party_id, 'تسييل ' || l_desc || ': ' || p_reason);
        l_j := NOONA_ACE_PKG.post_source('PRJ_GUARANTEE_MARGIN', 'PROJECTS', c_guar, g.id, l_dt, 'تسييل ' || l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                         l_lines, g.guarantee_no, NULL, 'PROJECTS');
        SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
        l_x := NOONA_CSH_PKG.record_settlement('RECEIPT', p_place, l_dt, g.amount, g.beneficiary_party_id, l_party, c_guar, g.id,
                                               'LGL-' || g.guarantee_no, 'تسييل ' || l_desc, l_ev);
      END IF;
      UPDATE prj_guarantee SET status_code = 'LIQUIDATED', release_date = l_dt,
                               notes = SUBSTR(notes || ' | تسييل: ' || p_reason, 1, 500) WHERE id = g.id;
    WHEN 'EXPIRE' THEN
      NOONA_CORE_PKG.assert(l_live AND g.margin_journal_id IS NULL, 'NOONA-PRJ-158', 'أفرج عن الغطاء النقدي أولاً (إفراج)', 'Release the margin first');
      UPDATE prj_guarantee SET status_code = 'EXPIRED' WHERE id = g.id;
    ELSE
      NOONA_CORE_PKG.raise_error('NOONA-PRJ-159', 'إجراء غير معروف', 'Unknown action');
    END CASE;
    NOONA_AUDIT_PKG.log_event('CONFIG', c_guar, g.id, UPPER(p_action), 'SUCCESS');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-160', 'خطاب الضمان غير موجود', 'Guarantee not found');
  END guarantee_action;

  FUNCTION expiring_count(p_days IN NUMBER DEFAULT 30) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM prj_guarantee WHERE company_id = company AND status_code IN ('ISSUED', 'ACTIVE', 'EXTENDED', 'REDUCED')
       AND expiry_date <= TRUNC(SYSDATE) + NVL(p_days, 30);
    RETURN l;
  END expiring_count;

  FUNCTION guarantees_html(p_days IN NUMBER DEFAULT 60) RETURN CLOB IS
    l   CLOB;
    n   PLS_INTEGER := 0;
    t_o NUMBER := 0; t_i NUMBER := 0; t_m NUMBER := 0;
    l_left NUMBER;
  BEGIN
    guard('PRJ_GUARANTEE.VIEW');
    l := '<table class="nn-rpt nn-prj-lg"><thead><tr><th>الرقم</th><th>النوع</th><th>الاتجاه</th><th>المشروع</th><th>المستفيد</th><th>البنك</th>'
      || '<th>المبلغ</th><th>الغطاء</th><th>الإصدار</th><th>الانتهاء</th><th>المتبقي</th><th>الحالة</th></tr></thead><tbody>';
    FOR g IN (SELECT g.*, (SELECT code FROM prj_project WHERE id = g.project_id) prj, (SELECT display_name_ar FROM pty_party WHERE id = g.beneficiary_party_id) ben,
                     (SELECT name_ar FROM ref_bank WHERE id = g.bank_id) bank
                FROM prj_guarantee g WHERE g.company_id = company
               ORDER BY CASE WHEN g.status_code IN ('RELEASED', 'LIQUIDATED', 'EXPIRED') THEN 1 ELSE 0 END, g.expiry_date) LOOP
      n := n + 1;
      l_left := g.expiry_date - TRUNC(SYSDATE);
      IF g.status_code IN ('ISSUED', 'ACTIVE', 'EXTENDED', 'REDUCED') THEN
        IF g.direction = 'ISSUED_BY_US' THEN t_o := t_o + g.amount; t_m := t_m + NVL(CASE WHEN g.margin_journal_id IS NOT NULL THEN g.margin_amount END, 0);
        ELSE t_i := t_i + g.amount; END IF;
      END IF;
      l := l || '<tr' || CASE WHEN g.status_code IN ('ISSUED', 'ACTIVE', 'EXTENDED', 'REDUCED') AND l_left <= NVL(p_days, 60) THEN ' class="is-bad"' END
        || '><td>' || esc(g.guarantee_no) || '</td><td>' || guarantee_type_label(g.guarantee_type) || '</td><td>'
        || CASE g.direction WHEN 'ISSUED_BY_US' THEN 'صادر منا' ELSE 'وارد لنا' END || '</td><td>' || esc(g.prj) || '</td><td>' || esc(g.ben)
        || '</td><td>' || esc(g.bank) || '</td><td>' || fmt(g.amount) || '</td><td>' || fmt(g.margin_amount) || '</td><td>' || ds(g.issue_date)
        || '</td><td>' || ds(g.expiry_date) || '</td><td>'
        || CASE WHEN g.status_code IN ('ISSUED', 'ACTIVE', 'EXTENDED', 'REDUCED') THEN CASE WHEN l_left < 0 THEN 'منتهٍ منذ ' || -l_left || ' يوم'
                ELSE l_left || ' يوم' END ELSE '-' END || '</td><td>' || guarantee_status_label(g.status_code) || '</td></tr>';
    END LOOP;
    IF n = 0 THEN RETURN '<div class="nn-empty">لا توجد خطابات ضمان</div>'; END IF;
    RETURN '<div class="nn-prj-chips"><span>صادرة منا سارية: ' || fmt(t_o) || '</span><span>الغطاء النقدي المحجوز: ' || fmt(t_m)
      || '</span><span>واردة لنا سارية: ' || fmt(t_i) || '</span><span>تنتهي خلال ' || NVL(p_days, 60) || ' يوماً: ' || expiring_count(p_days) || '</span></div>'
      || l || '</tbody></table>';
  END guarantees_html;

  -- ================================================================ الحساب الختامي
  FUNCTION final_account_html(p_contract_id IN NUMBER) RETURN CLOB IS
    c       prj_contract%ROWTYPE;
    p       prj_project%ROWTYPE;
    l_vo    NUMBER; l_exec NUMBER; l_prog NUMBER; l_mos NUMBER; l_pen NUMBER; l_oth NUMBER; l_ret NUMBER; l_rel NUMBER;
    l_adv   NUMBER; l_rec NUMBER; l_tax NUMBER; l_net NUMBER; l_open NUMBER; l_party VARCHAR2(400); l_final VARCHAR2(50);
    l_dir   VARCHAR2(30);
    FUNCTION rw(p_label VARCHAR2, p_amt NUMBER, p_cls VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    BEGIN RETURN '<tr' || CASE WHEN p_cls IS NOT NULL THEN ' class="' || p_cls || '"' END || '><th>' || p_label || '</th><td>' || fmt(p_amt) || '</td></tr>'; END;
  BEGIN
    guard('PRJ_CONTRACT.VIEW');
    SELECT * INTO c FROM prj_contract WHERE id = p_contract_id AND company_id = company;
    p := project(c.project_id);
    l_dir := CASE WHEN c.contract_type = 'MAIN_CONTRACT' THEN 'RECEIVABLE' ELSE 'PAYABLE' END;
    SELECT NVL(SUM(amount), 0) INTO l_vo FROM prj_variation_order WHERE contract_id = c.id AND status_code = 'APPROVED';
    SELECT NVL(SUM(ROUND(executed_qty * unit_rate, 2)), 0) INTO l_exec FROM prj_boq_item WHERE contract_id = c.id;
    SELECT NVL(SUM(CASE WHEN claim_kind = 'PROGRESS' THEN current_gross END), 0),
           NVL(MAX(mos_to_date) KEEP (DENSE_RANK LAST ORDER BY CASE WHEN claim_kind = 'PROGRESS' THEN claim_no END NULLS FIRST), 0),
           NVL(SUM(penalty_amount), 0), NVL(SUM(other_deductions), 0), NVL(SUM(retention_amount), 0),
           NVL(SUM(CASE WHEN claim_kind = 'RETENTION_RELEASE' THEN current_gross END), 0),
           NVL(SUM(CASE WHEN claim_kind = 'ADVANCE' THEN current_gross END), 0), NVL(SUM(advance_recovery), 0), NVL(SUM(tax_amount), 0),
           NVL(SUM(net_payable), 0), MAX(CASE WHEN is_final = 'Y' THEN doc_no END)
      INTO l_prog, l_mos, l_pen, l_oth, l_ret, l_rel, l_adv, l_rec, l_tax, l_net, l_final
      FROM prj_progress_claim WHERE contract_id = c.id AND status_code IN ('APPROVED', 'PAID');
    IF l_dir = 'RECEIVABLE' THEN
      SELECT NVL(SUM(o.open_amount), 0) INTO l_open FROM ar_open_item o JOIN prj_progress_claim cl ON cl.id = o.source_entity_id
       WHERE o.source_entity_type = 'PRJ_PROGRESS_CLAIM' AND cl.contract_id = c.id AND o.status_code <> 'CANCELLED';
      l_party := NOONA_SAL_PKG.customer_label(c.customer_account_id);
    ELSE
      SELECT NVL(SUM(o.open_amount), 0) INTO l_open FROM ap_open_item o JOIN prj_progress_claim cl ON cl.doc_no = o.doc_no AND cl.contract_id = c.id
       WHERE o.supplier_account_id = c.supplier_account_id AND o.status_code <> 'CANCELLED';
      l_party := NOONA_PUR_PKG.supplier_label(c.supplier_account_id);
    END IF;
    RETURN NOONA_BRAND_PKG.report_header('الحساب الختامي للعقد ' || c.contract_no)
      || '<div class="nn-prj-chips"><span>المشروع: ' || esc(p.code || ' - ' || p.name_ar) || '</span><span>'
      || CASE WHEN l_dir = 'RECEIVABLE' THEN 'المالك: ' ELSE 'مقاول الباطن: ' END || esc(l_party) || '</span><span>الحالة: '
      || CASE c.status_code WHEN 'COMPLETED' THEN 'منتهٍ' || NVL2(l_final, ' بالمستخلص الختامي ' || l_final, '') WHEN 'ACTIVE' THEN 'قيد التنفيذ (حساب مؤقت)' ELSE c.status_code END
      || '</span></div>'
      || '<table class="nn-prj-cert-sum nn-prj-final">'
      || rw('القيمة الأصلية للعقد', c.original_value)
      || rw('أوامر التغيير المعتمدة', l_vo)
      || rw('قيمة العقد بعد أوامر التغيير', NOONA_PRJ_PKG.contract_value(c.id), 'is-sub')
      || rw('قيمة الأعمال المنفذة (الكميات المعتمدة × الأسعار)', l_exec)
      || rw('إجمالي مستخلصات الأعمال', l_prog)
      || rw('مواد مشونة بالموقع قائمة', l_mos)
      || rw('يخصم: غرامات التأخير', -l_pen)
      || rw('يخصم: خصومات أخرى', -l_oth)
      || rw('الدفعة المقدمة المصروفة', l_adv)
      || rw('يخصم: المسترد من الدفعة المقدمة', -l_rec)
      || rw('المتبقي من الدفعة المقدمة', l_adv - l_rec)
      || rw('المحتجز المستقطع', l_ret)
      || rw('المفرج عنه من المحتجز', l_rel)
      || rw('المحتجز القائم', l_ret - l_rel, 'is-sub')
      || rw('ضريبة القيمة المضافة', l_tax)
      || rw('صافي المستخلصات المعتمدة (شامل الضريبة)', l_net, 'is-sub')
      || rw(CASE WHEN l_dir = 'RECEIVABLE' THEN 'المحصل' ELSE 'المسدد' END, l_net - l_open)
      || rw('الرصيد المستحق ' || CASE WHEN l_dir = 'RECEIVABLE' THEN 'لنا على المالك' ELSE 'علينا للمقاول' END, l_open, 'is-total')
      || rw('يضاف عند الإفراج: المحتجز القائم', l_ret - l_rel)
      || '</table><p class="nn-hint">الحساب الختامي يجمع حركة العقد كلها؛ يصبح نهائياً بعد المستخلص الختامي، ويبقى المحتجز حتى نهاية فترة الضمان ('
      || NVL(c.defects_liability_months, 0) || ' شهراً).</p>'
      || '<div class="nn-prj-cert-sign"><div>مدير المشروع<br><br>..................</div><div>الاستشاري<br><br>..................</div>'
      || '<div>' || CASE WHEN l_dir = 'RECEIVABLE' THEN 'المالك' ELSE 'المقاول' END || '<br><br>..................</div></div>';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRJ-030', 'العقد غير موجود', 'Contract not found');
  END final_account_html;

END NOONA_PRJ_CTR_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_PRJ_CTR_PKG
