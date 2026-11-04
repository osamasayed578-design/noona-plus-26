-- =============================================================================
-- NOONA PLUS ERP | NOONA_ANL_PKG - محرك التحليلات والتنبؤ لكل الموديولات
--   * كتالوج مؤشرات لكل موديول (المالية، المبيعات، نقاط البيع، المشتريات، المخزون، الموارد البشرية، التصنيع، المستشفيات،
--     خدمة السيارات، الضيافة، العقارات، المطاعم)؛ كل مؤشر بصلاحية العرض الخاصة بموديوله، ومحصور بالشركة الحالية
--     (عزل البيانات) وبالفرع عند تحديده
--   * سلاسل زمنية يومية أو أسبوعية أو شهرية، وقيمة المؤشر لفترة مع المقارنة بالفترة السابقة
--   * التنبؤ الإحصائي: Holt-Winters الجمعي بموسمية 12 شهراً عند توفر 24 نقطة فأكثر، وإلا Holt الخطي؛ المعاملات تختار
--     بأقل خطأ على التاريخ، ونطاق ثقة 95% من خطأ التنبؤ؛ الأرقام تحسب داخل القاعدة لا من نموذج لغوي
--   * كشف القيم الشاذة: آخر نقطة مقارنة بمتوسط وانحراف السلسلة
--   * يعمل على 21c و26ai؛ يستخدمه المساعد الذكي (نسخة 26) أدواتٍ لجلب الأرقام
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_ANL_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- [{code, name, module, moduleName, unit, kind}] للموديول (فارغ = كل ما يملك المستخدم صلاحيته)
  FUNCTION metrics_json(p_module IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION metric_name(p_metric IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION is_allowed(p_metric IN VARCHAR2) RETURN VARCHAR2;
  -- قيمة المؤشر لفترة (رصيد لحظي لمؤشرات الأرصدة)
  FUNCTION kpi(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_branch IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- {metric, name, value, previous, changePct, unit, from, to}
  FUNCTION kpi_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- [{p:'2026-01', v:123}] بكل الفترات (الفارغة صفر)؛ p_grain: MONTH, WEEK, DAY
  FUNCTION series_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_grain IN VARCHAR2 DEFAULT 'MONTH',
                       p_branch IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- التنبؤ الشهري: {metric, name, method, history:[{p,v}], forecast:[{p,v,lo,hi}], rmse, trendPct}
  FUNCTION forecast_json(p_metric IN VARCHAR2, p_periods IN NUMBER DEFAULT 3, p_history_months IN NUMBER DEFAULT 24,
                         p_branch IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- لوحة موديول: مؤشرات الشهر الحالي مقابل السابق {module, name, kpis:[...]}
  FUNCTION dashboard_json(p_module IN VARCHAR2, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- أكبر الانحرافات في آخر شهر مكتمل لكل المؤشرات المسموحة: [{metric, name, value, mean, z, direction}]
  FUNCTION anomalies_json(p_months IN NUMBER DEFAULT 12, p_z IN NUMBER DEFAULT 2) RETURN CLOB;
  -- الحساب الإحصائي (عام لاختباره منفرداً): السلسلة مفصولة بفواصل ← JSON التنبؤ
  FUNCTION forecast_values(p_values IN VARCHAR2, p_periods IN NUMBER, p_season IN NUMBER DEFAULT 12) RETURN CLOB;
END NOONA_ANL_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_ANL_PKG AS

  TYPE t_def IS RECORD (code VARCHAR2(40), name VARCHAR2(200), module VARCHAR2(10), unit VARCHAR2(10), kind VARCHAR2(10),
                        perm VARCHAR2(100), dt VARCHAR2(400), val VARCHAR2(400), src VARCHAR2(4000), br VARCHAR2(100));
  TYPE t_defs IS TABLE OF t_def INDEX BY PLS_INTEGER;
  TYPE t_nums IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  g_defs t_defs;

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END jt;
  FUNCTION num(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN 'null' ELSE RTRIM(TO_CHAR(ROUND(p, 4), 'FM99999999999990.9999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '.') END;
  END num;

  FUNCTION module_name(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p WHEN 'FIN' THEN 'المالية' WHEN 'SAL' THEN 'المبيعات ونقاط البيع' WHEN 'SCM' THEN 'المشتريات والمخزون'
                  WHEN 'HR' THEN 'الموارد البشرية والرواتب' WHEN 'MFG' THEN 'التصنيع' WHEN 'HIS' THEN 'المستشفيات'
                  WHEN 'AUT' THEN 'خدمة السيارات' WHEN 'HSP' THEN 'الضيافة والفنادق' WHEN 'RE' THEN 'العقارات' WHEN 'RST' THEN 'المطاعم'
                  ELSE p END;
  END module_name;

  -- ---------------------------------------------------------------- الكتالوج
  -- dt: عمود التاريخ، val: القيمة المجمعة، src: FROM و WHERE (بربط :co الشركة)، br: عمود الفرع إن وجد
  -- kind: FLOW (مجموع فترة) أو BALANCE (رصيد لحظي حتى نهاية الفترة)
  PROCEDURE def(p_code VARCHAR2, p_name VARCHAR2, p_module VARCHAR2, p_unit VARCHAR2, p_kind VARCHAR2, p_perm VARCHAR2,
                p_dt VARCHAR2, p_val VARCHAR2, p_src VARCHAR2, p_br VARCHAR2 DEFAULT NULL) IS
    l t_def;
  BEGIN
    l.code := p_code; l.name := p_name; l.module := p_module; l.unit := p_unit; l.kind := p_kind; l.perm := p_perm;
    l.dt := p_dt; l.val := p_val; l.src := p_src; l.br := p_br;
    g_defs(g_defs.COUNT + 1) := l;
  END def;

  PROCEDURE load_defs IS
    c_gl CONSTANT VARCHAR2(400) := ' gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id'
                                || ' WHERE j.company_id = :co AND j.status_code = ''POSTED''';
  BEGIN
    IF g_defs.COUNT > 0 THEN RETURN; END IF;
    -- المالية (من القيود المرحلة: كل الموديولات تقيد في الأستاذ العام)
    def('REVENUE', 'الإيرادات', 'FIN', 'AMOUNT', 'FLOW', 'GL_JOURNAL.VIEW', 'j.posting_date', 'SUM(l.credit_func - l.debit_func)',
        c_gl || ' AND a.account_type = ''REVENUE''', 'l.branch_id');
    def('EXPENSES', 'المصروفات والتكاليف', 'FIN', 'AMOUNT', 'FLOW', 'GL_JOURNAL.VIEW', 'j.posting_date', 'SUM(l.debit_func - l.credit_func)',
        c_gl || ' AND a.account_type = ''EXPENSE''', 'l.branch_id');
    def('NET_PROFIT', 'صافي الربح', 'FIN', 'AMOUNT', 'FLOW', 'GL_JOURNAL.VIEW', 'j.posting_date',
        'SUM(l.credit_func - l.debit_func)',
        c_gl || ' AND a.account_type IN (''REVENUE'', ''EXPENSE'')', 'l.branch_id');
    def('CASH_BALANCE', 'رصيد النقدية والبنوك', 'FIN', 'AMOUNT', 'BALANCE', 'GL_JOURNAL.VIEW', 'j.posting_date',
        'SUM(l.debit_func - l.credit_func)', c_gl || ' AND a.subledger_code = ''CASH''', 'l.branch_id');
    def('AR_BALANCE', 'المستحق على العملاء', 'FIN', 'AMOUNT', 'BALANCE', 'GL_JOURNAL.VIEW', 'j.posting_date',
        'SUM(l.debit_func - l.credit_func)', c_gl || ' AND a.subledger_code = ''AR''', 'l.branch_id');
    def('AP_BALANCE', 'المستحق للموردين', 'FIN', 'AMOUNT', 'BALANCE', 'GL_JOURNAL.VIEW', 'j.posting_date',
        'SUM(l.credit_func - l.debit_func)', c_gl || ' AND a.subledger_code = ''AP''', 'l.branch_id');
    -- المبيعات ونقاط البيع
    def('SALES_INVOICED', 'مبيعات الفواتير', 'SAL', 'AMOUNT', 'FLOW', 'SAL_INVOICE.VIEW', 's.doc_date',
        'SUM(CASE WHEN s.doc_type = ''CREDIT_NOTE'' THEN -s.total_amount ELSE s.total_amount END)',
        ' sal_invoice s WHERE s.company_id = :co AND s.status_code IN (''POSTED'', ''PARTIALLY_PAID'', ''PAID'', ''CREDITED'')', 's.branch_id');
    def('POS_SALES', 'مبيعات نقاط البيع', 'SAL', 'AMOUNT', 'FLOW', 'POS_SALE.VIEW', 'CAST(s.sale_at AS DATE)',
        'SUM(CASE WHEN s.sale_type = ''RETURN'' THEN -s.total_amount ELSE s.total_amount END)',
        ' pos_sale s WHERE s.company_id = :co AND s.status_code IN (''COMPLETED'', ''RETURNED'', ''PARTIALLY_RETURNED'')', 's.branch_id');
    def('POS_TICKETS', 'عدد إيصالات نقاط البيع', 'SAL', 'COUNT', 'FLOW', 'POS_SALE.VIEW', 'CAST(s.sale_at AS DATE)', 'COUNT(*)',
        ' pos_sale s WHERE s.company_id = :co AND s.sale_type = ''SALE'' AND s.status_code <> ''VOIDED''', 's.branch_id');
    -- المشتريات والمخزون
    def('PURCHASES', 'المشتريات', 'SCM', 'AMOUNT', 'FLOW', 'AP_INVOICE.VIEW', 'NVL(s.gl_date, s.doc_date)', 'SUM(CASE WHEN s.invoice_type = ''CREDIT_MEMO'' THEN -s.total_amount ELSE s.total_amount END)',
        ' ap_invoice s WHERE s.company_id = :co AND s.status_code IN (''POSTED'', ''PARTIALLY_PAID'', ''PAID'')', 's.branch_id');
    def('INVENTORY_VALUE', 'قيمة المخزون', 'SCM', 'AMOUNT', 'BALANCE', 'GL_JOURNAL.VIEW', 'j.posting_date',
        'SUM(l.debit_func - l.credit_func)', c_gl || ' AND a.subledger_code = ''INV''', 'l.branch_id');
    -- الموارد البشرية
    def('PAYROLL_COST', 'تكلفة الرواتب', 'HR', 'AMOUNT', 'FLOW', 'PAY_RUN.VIEW', 'p.end_date', 'SUM(r.total_employer_cost + r.total_gross)',
        ' pay_run r JOIN pay_period p ON p.id = r.period_id WHERE r.company_id = :co AND r.status_code IN (''APPROVED'', ''PAYABLE'', ''PAID'', ''POSTED'', ''CLOSED'')');
    def('HIRES', 'التعيينات الجديدة', 'HR', 'COUNT', 'FLOW', 'HR_EMPLOYEE.VIEW', 'e.original_hire_date', 'COUNT(*)',
        ' hr_employee e WHERE e.tenant_id = SYS_CONTEXT(''NOONA_CTX'', ''TENANT_ID'') AND EXISTS (SELECT 1 FROM hr_employment x WHERE x.employee_id = e.id AND x.company_id = :co)');
    -- التصنيع
    def('PRODUCTION_QTY', 'الكمية المنتجة', 'MFG', 'QTY', 'FLOW', 'MFG_PRODUCTION_ORDER.VIEW', 'CAST(NVL(o.actual_end, o.posted_at) AS DATE)',
        'SUM(o.completed_qty)', ' mfg_production_order o WHERE o.company_id = :co AND o.status_code IN (''COMPLETED'', ''CLOSED'')', 'o.branch_id');
    def('PRODUCTION_ORDERS', 'أوامر الإنتاج المقفلة', 'MFG', 'COUNT', 'FLOW', 'MFG_PRODUCTION_ORDER.VIEW', 'CAST(o.posted_at AS DATE)',
        'COUNT(*)', ' mfg_production_order o WHERE o.company_id = :co AND o.status_code = ''CLOSED''', 'o.branch_id');
    -- المستشفيات
    def('HIS_VISITS', 'زيارات المرضى', 'HIS', 'COUNT', 'FLOW', 'HIS_VISIT.VIEW', 'CAST(v.visit_at AS DATE)', 'COUNT(*)',
        ' his_visit v WHERE v.company_id = :co AND v.status_code <> ''CANCELLED''', 'v.branch_id');
    def('HIS_REVENUE', 'إيرادات المستشفى', 'HIS', 'AMOUNT', 'FLOW', 'HIS_INVOICE.VIEW', 'i.doc_date',
        'SUM(i.patient_total + i.payer_total)', ' his_invoice i WHERE i.company_id = :co AND i.status_code <> ''CANCELLED''', 'i.branch_id');
    -- خدمة السيارات
    def('AUT_JOBS', 'أوامر الإصلاح', 'AUT', 'COUNT', 'FLOW', 'AUT_JOB_CARD.VIEW', 'CAST(j.checkin_at AS DATE)', 'COUNT(*)',
        ' aut_job_card j WHERE j.company_id = :co AND j.status_code <> ''CANCELLED''');
    def('AUT_REVENUE', 'إيرادات خدمة السيارات', 'AUT', 'AMOUNT', 'FLOW', 'AUT_JOB_CARD.VIEW', 'CAST(NVL(j.completed_at, j.checkin_at) AS DATE)',
        'SUM(j.total_amount)', ' aut_job_card j WHERE j.company_id = :co AND j.status_code IN (''INVOICED'', ''DELIVERED'')');
    -- الضيافة والعقارات والمطاعم
    def('HOTEL_CHECKINS', 'نزلاء الفندق (تسجيل دخول)', 'HSP', 'COUNT', 'FLOW', 'HSP_RESERVATION.VIEW', 'CAST(s.check_in_at AS DATE)', 'COUNT(*)',
        ' hsp_stay s WHERE s.company_id = :co AND s.status_code <> ''CANCELLED'' AND s.previous_stay_id IS NULL');
    def('RE_SALES', 'مبيعات الوحدات العقارية', 'RE', 'AMOUNT', 'FLOW', 'RE_SALE_CONTRACT.VIEW', 'c.signed_date', 'SUM(c.total_amount)',
        ' re_sale_contract c WHERE c.company_id = :co AND c.status_code NOT IN (''DRAFT'', ''CANCELLED'', ''TERMINATED'')');
    def('RST_SALES', 'مبيعات المطاعم', 'RST', 'AMOUNT', 'FLOW', 'RST_ORDER.VIEW', 'CAST(o.closed_at AS DATE)', 'SUM(o.total_amount)',
        ' rst_order o WHERE o.company_id = :co AND o.status_code IN (''PAID'', ''CHARGED'')', 'o.branch_id');
  END load_defs;

  FUNCTION find(p_metric VARCHAR2) RETURN t_def IS
    l t_def;
  BEGIN
    load_defs;
    FOR i IN 1 .. g_defs.COUNT LOOP
      IF g_defs(i).code = UPPER(p_metric) THEN RETURN g_defs(i); END IF;
    END LOOP;
    NOONA_CORE_PKG.raise_error('NOONA-ANL-001', 'المؤشر غير معروف: ' || p_metric, 'Unknown metric');
    RETURN l;
  END find;

  FUNCTION allowed(d t_def) RETURN BOOLEAN IS
  BEGIN
    RETURN NOONA_SECURITY_PKG.has_permission(d.perm, company) = 'Y';
  EXCEPTION WHEN OTHERS THEN RETURN FALSE;
  END allowed;

  FUNCTION is_allowed(p_metric IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN allowed(find(p_metric)) THEN 'Y' ELSE 'N' END;
  END is_allowed;

  PROCEDURE guard(d t_def) IS
  BEGIN
    NOONA_CORE_PKG.assert(company IS NOT NULL, 'NOONA-ANL-002', 'اختر الشركة أولاً', 'No company context');
    NOONA_CORE_PKG.assert(allowed(d), 'NOONA-ANL-003', 'لا تملك صلاحية عرض مؤشر «' || d.name || '»', 'Not allowed to view this metric');
  END guard;

  FUNCTION metric_name(p_metric IN VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN find(p_metric).name; END metric_name;

  FUNCTION metrics_json(p_module IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l CLOB := '[';
    l_first BOOLEAN := TRUE;
  BEGIN
    load_defs;
    FOR i IN 1 .. g_defs.COUNT LOOP
      IF (p_module IS NULL OR g_defs(i).module = UPPER(p_module)) AND allowed(g_defs(i)) THEN
        l := l || CASE WHEN NOT l_first THEN ',' END || '{"code":"' || g_defs(i).code || '","name":' || jt(g_defs(i).name)
               || ',"module":"' || g_defs(i).module || '","moduleName":' || jt(module_name(g_defs(i).module)) || ',"unit":"'
               || g_defs(i).unit || '","kind":"' || g_defs(i).kind || '"}';
        l_first := FALSE;
      END IF;
    END LOOP;
    RETURN l || ']';
  END metrics_json;

  -- ---------------------------------------------------------------- الاستعلام
  FUNCTION where_period(d t_def, p_branch NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN d.kind = 'BALANCE' THEN ' AND ' || d.dt || ' <= :t' ELSE ' AND ' || d.dt || ' BETWEEN :f AND :t' END
        || CASE WHEN p_branch IS NOT NULL AND d.br IS NOT NULL THEN ' AND ' || d.br || ' = ' || TO_CHAR(TRUNC(p_branch)) END;
  END where_period;

  FUNCTION kpi(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_branch IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    d t_def := find(p_metric);
    l NUMBER;
  BEGIN
    guard(d);
    IF d.kind = 'BALANCE' THEN
      EXECUTE IMMEDIATE 'SELECT ' || d.val || ' FROM' || d.src || where_period(d, p_branch) INTO l USING company, p_to;
    ELSE
      EXECUTE IMMEDIATE 'SELECT ' || d.val || ' FROM' || d.src || where_period(d, p_branch) INTO l USING company, TRUNC(p_from), TRUNC(p_to);
    END IF;
    RETURN ROUND(NVL(l, 0), 2);
  END kpi;

  FUNCTION kpi_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB IS
    d     t_def := find(p_metric);
    l_len NUMBER := TRUNC(p_to) - TRUNC(p_from) + 1;
    l_cur NUMBER;
    l_prv NUMBER;
  BEGIN
    l_cur := kpi(p_metric, p_from, p_to, p_branch);
    l_prv := kpi(p_metric, TRUNC(p_from) - l_len, TRUNC(p_from) - 1, p_branch);
    RETURN '{"metric":"' || d.code || '","name":' || jt(d.name) || ',"unit":"' || d.unit || '","kind":"' || d.kind
        || '","value":' || num(l_cur) || ',"previous":' || num(l_prv)
        || ',"changePct":' || num(CASE WHEN l_prv <> 0 THEN ROUND((l_cur - l_prv) / ABS(l_prv) * 100, 1) END)
        || ',"from":"' || TO_CHAR(p_from, 'YYYY-MM-DD') || '","to":"' || TO_CHAR(p_to, 'YYYY-MM-DD') || '"}';
  END kpi_json;

  FUNCTION bucket(p_d DATE, p_grain VARCHAR2) RETURN DATE IS
  BEGIN
    RETURN CASE p_grain WHEN 'DAY' THEN TRUNC(p_d) WHEN 'WEEK' THEN TRUNC(p_d, 'IW') ELSE TRUNC(p_d, 'MM') END;
  END bucket;

  -- قيم السلسلة لكل فترة من البداية للنهاية (الفارغة صفر؛ الأرصدة تراكمية)
  PROCEDURE series(d t_def, p_from DATE, p_to DATE, p_grain VARCHAR2, p_branch NUMBER, o_p OUT t_nums, o_v OUT t_nums) IS
    TYPE t_dates IS TABLE OF DATE;
    TYPE t_vals IS TABLE OF NUMBER;
    l_ds  t_dates;
    l_vs  t_vals;
    l_b   DATE := bucket(p_from, p_grain);
    l_e   DATE := bucket(p_to, p_grain);
    l_k   PLS_INTEGER := 0;
    l_open NUMBER := 0;
    l_g   VARCHAR2(10) := CASE p_grain WHEN 'DAY' THEN 'DD' WHEN 'WEEK' THEN 'IW' ELSE 'MM' END;
  BEGIN
    IF d.kind = 'BALANCE' THEN
      EXECUTE IMMEDIATE 'SELECT ' || d.val || ' FROM' || d.src || ' AND ' || d.dt || ' < :b'
        || CASE WHEN p_branch IS NOT NULL AND d.br IS NOT NULL THEN ' AND ' || d.br || ' = ' || TO_CHAR(TRUNC(p_branch)) END
        INTO l_open USING company, l_b;
      l_open := NVL(l_open, 0);
    END IF;
    EXECUTE IMMEDIATE 'SELECT TRUNC(' || d.dt || ', ''' || l_g || '''), ' || d.val || ' FROM' || d.src || ' AND ' || d.dt
      || ' >= :b AND ' || d.dt || ' < :e'
      || CASE WHEN p_branch IS NOT NULL AND d.br IS NOT NULL THEN ' AND ' || d.br || ' = ' || TO_CHAR(TRUNC(p_branch)) END
      || ' GROUP BY TRUNC(' || d.dt || ', ''' || l_g || ''') ORDER BY 1'
      BULK COLLECT INTO l_ds, l_vs
      USING company, l_b, CASE p_grain WHEN 'DAY' THEN l_e + 1 WHEN 'WEEK' THEN l_e + 7 ELSE ADD_MONTHS(l_e, 1) END;
    WHILE l_b <= l_e LOOP
      l_k := l_k + 1;
      o_p(l_k) := TO_NUMBER(TO_CHAR(l_b, 'J'));
      o_v(l_k) := 0;
      FOR i IN 1 .. l_ds.COUNT LOOP
        IF l_ds(i) = l_b THEN o_v(l_k) := NVL(l_vs(i), 0); END IF;
      END LOOP;
      IF d.kind = 'BALANCE' THEN l_open := l_open + o_v(l_k); o_v(l_k) := l_open; END IF;
      l_b := CASE p_grain WHEN 'DAY' THEN l_b + 1 WHEN 'WEEK' THEN l_b + 7 ELSE ADD_MONTHS(l_b, 1) END;
    END LOOP;
  END series;

  FUNCTION plabel(p_j NUMBER, p_grain VARCHAR2) RETURN VARCHAR2 IS
    l DATE := TO_DATE(TO_CHAR(p_j), 'J');
  BEGIN
    RETURN CASE p_grain WHEN 'MONTH' THEN TO_CHAR(l, 'YYYY-MM') ELSE TO_CHAR(l, 'YYYY-MM-DD') END;
  END plabel;

  FUNCTION series_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_grain IN VARCHAR2 DEFAULT 'MONTH',
                       p_branch IN NUMBER DEFAULT NULL) RETURN CLOB IS
    d   t_def := find(p_metric);
    l_p t_nums; l_v t_nums;
    l   CLOB := '[';
    l_g VARCHAR2(10) := NVL(UPPER(p_grain), 'MONTH');
  BEGIN
    guard(d);
    NOONA_CORE_PKG.assert(l_g IN ('DAY', 'WEEK', 'MONTH'), 'NOONA-ANL-004', 'الفترة يوم أو أسبوع أو شهر', 'Grain must be DAY, WEEK or MONTH');
    NOONA_CORE_PKG.assert(p_to >= p_from AND p_to - p_from <= 3700, 'NOONA-ANL-005', 'المدى بين يوم وعشر سنوات', 'Range 1 day to 10 years');
    series(d, p_from, p_to, l_g, p_branch, l_p, l_v);
    FOR i IN 1 .. l_p.COUNT LOOP
      l := l || CASE WHEN i > 1 THEN ',' END || '{"p":"' || plabel(l_p(i), l_g) || '","v":' || num(ROUND(l_v(i), 2)) || '}';
    END LOOP;
    RETURN l || ']';
  END series_json;

  -- ---------------------------------------------------------------- التنبؤ
  -- Holt-Winters الجمعي (أو Holt الخطي بلا موسمية): يعيد مجموع مربعات أخطاء التنبؤ خطوة واحدة والتنبؤات
  PROCEDURE hw(p_y t_nums, p_n PLS_INTEGER, p_m PLS_INTEGER, p_a NUMBER, p_b NUMBER, p_g NUMBER, p_h PLS_INTEGER,
               o_sse OUT NUMBER, o_f OUT t_nums) IS
    l_l NUMBER; l_t NUMBER; l_s t_nums; l_lp NUMBER; l_e NUMBER; l_k PLS_INTEGER := 0;
  BEGIN
    o_sse := 0;
    IF p_m > 0 THEN
      l_l := 0; FOR i IN 1 .. p_m LOOP l_l := l_l + p_y(i); END LOOP; l_l := l_l / p_m;
      l_t := 0; FOR i IN 1 .. p_m LOOP l_t := l_t + (p_y(p_m + i) - p_y(i)) / p_m; END LOOP; l_t := l_t / p_m;
      FOR i IN 1 .. p_m LOOP l_s(i) := p_y(i) - l_l; END LOOP;
      FOR i IN p_m + 1 .. p_n LOOP
        l_e := p_y(i) - (l_l + l_t + l_s(i - p_m));
        o_sse := o_sse + l_e * l_e; l_k := l_k + 1;
        l_lp := l_l;
        l_l := p_a * (p_y(i) - l_s(i - p_m)) + (1 - p_a) * (l_l + l_t);
        l_t := p_b * (l_l - l_lp) + (1 - p_b) * l_t;
        l_s(i) := p_g * (p_y(i) - l_l) + (1 - p_g) * l_s(i - p_m);
      END LOOP;
      FOR h IN 1 .. p_h LOOP o_f(h) := l_l + h * l_t + l_s(p_n - p_m + MOD(h - 1, p_m) + 1); END LOOP;
    ELSE
      l_l := p_y(1); l_t := CASE WHEN p_n > 1 THEN p_y(2) - p_y(1) ELSE 0 END;
      FOR i IN 2 .. p_n LOOP
        l_e := p_y(i) - (l_l + l_t);
        o_sse := o_sse + l_e * l_e; l_k := l_k + 1;
        l_lp := l_l;
        l_l := p_a * p_y(i) + (1 - p_a) * (l_l + l_t);
        l_t := p_b * (l_l - l_lp) + (1 - p_b) * l_t;
      END LOOP;
      FOR h IN 1 .. p_h LOOP o_f(h) := l_l + h * l_t; END LOOP;
    END IF;
    o_sse := o_sse / GREATEST(l_k, 1);
  END hw;

  PROCEDURE fit(p_y t_nums, p_h PLS_INTEGER, p_season PLS_INTEGER, o_f OUT t_nums, o_rmse OUT NUMBER, o_method OUT VARCHAR2) IS
    l_n   PLS_INTEGER := p_y.COUNT;
    l_m   PLS_INTEGER := CASE WHEN p_season > 1 AND l_n >= 2 * p_season THEN p_season ELSE 0 END;
    l_best NUMBER;
    l_sse NUMBER;
    l_f   t_nums;
    l_a   NUMBER; l_b NUMBER; l_g NUMBER;
  BEGIN
    IF l_n < 3 THEN
      -- بيانات قليلة: المتوسط
      l_sse := 0; FOR i IN 1 .. l_n LOOP l_sse := l_sse + p_y(i); END LOOP;
      FOR h IN 1 .. p_h LOOP o_f(h) := CASE WHEN l_n > 0 THEN l_sse / l_n ELSE 0 END; END LOOP;
      o_rmse := NULL; o_method := 'AVERAGE';
      RETURN;
    END IF;
    FOR ai IN 1 .. 9 LOOP
      FOR bi IN 1 .. 5 LOOP
        FOR gi IN 1 .. CASE WHEN l_m > 0 THEN 5 ELSE 1 END LOOP
          hw(p_y, l_n, l_m, ai / 10, bi / 10, gi / 10, p_h, l_sse, l_f);
          IF l_best IS NULL OR l_sse < l_best THEN l_best := l_sse; o_f := l_f; l_a := ai; l_b := bi; l_g := gi; END IF;
        END LOOP;
      END LOOP;
    END LOOP;
    o_rmse := SQRT(l_best);
    o_method := CASE WHEN l_m > 0 THEN 'HOLT_WINTERS' ELSE 'HOLT' END;
  END fit;

  FUNCTION forecast_body(p_y t_nums, p_labels t_nums, p_h PLS_INTEGER, p_season PLS_INTEGER, p_grain VARCHAR2,
                         p_nonneg BOOLEAN) RETURN CLOB IS
    l_f    t_nums;
    l_rmse NUMBER;
    l_meth VARCHAR2(30);
    l      CLOB := '"history":[';
    l_last DATE;
    l_tot0 NUMBER := 0; l_tot1 NUMBER := 0;
    l_band NUMBER;
    l_v    NUMBER;
  BEGIN
    fit(p_y, p_h, p_season, l_f, l_rmse, l_meth);
    FOR i IN 1 .. p_y.COUNT LOOP
      l := l || CASE WHEN i > 1 THEN ',' END || '{"p":"' || CASE WHEN p_labels.EXISTS(i) THEN plabel(p_labels(i), p_grain) ELSE TO_CHAR(i) END
             || '","v":' || num(ROUND(p_y(i), 2)) || '}';
    END LOOP;
    l := l || '],"forecast":[';
    l_last := CASE WHEN p_labels.EXISTS(p_y.COUNT) THEN TO_DATE(TO_CHAR(p_labels(p_y.COUNT)), 'J') END;
    FOR h IN 1 .. p_h LOOP
      l_v := CASE WHEN p_nonneg THEN GREATEST(l_f(h), 0) ELSE l_f(h) END;
      l_band := CASE WHEN l_rmse IS NOT NULL THEN 1.96 * l_rmse * SQRT(h) END;
      l := l || CASE WHEN h > 1 THEN ',' END || '{"p":"' || CASE WHEN l_last IS NOT NULL THEN TO_CHAR(ADD_MONTHS(l_last, h), 'YYYY-MM') ELSE '+' || h END
             || '","v":' || num(ROUND(l_v, 2)) || ',"lo":' || num(ROUND(CASE WHEN p_nonneg THEN GREATEST(l_v - l_band, 0) ELSE l_v - l_band END, 2))
             || ',"hi":' || num(ROUND(l_v + l_band, 2)) || '}';
      l_tot1 := l_tot1 + l_v;
    END LOOP;
    FOR i IN GREATEST(p_y.COUNT - p_h + 1, 1) .. p_y.COUNT LOOP l_tot0 := l_tot0 + p_y(i); END LOOP;
    RETURN l || '],"method":"' || l_meth || '","rmse":' || num(ROUND(l_rmse, 2))
        || ',"trendPct":' || num(CASE WHEN l_tot0 <> 0 THEN ROUND((l_tot1 - l_tot0) / ABS(l_tot0) * 100, 1) END);
  END forecast_body;

  FUNCTION forecast_values(p_values IN VARCHAR2, p_periods IN NUMBER, p_season IN NUMBER DEFAULT 12) RETURN CLOB IS
    l_y t_nums;
    l_l t_nums;
    l_i PLS_INTEGER := 0;
  BEGIN
    FOR r IN (SELECT TO_NUMBER(TRIM(REGEXP_SUBSTR(p_values, '[^,]+', 1, LEVEL))) v FROM dual
               CONNECT BY REGEXP_SUBSTR(p_values, '[^,]+', 1, LEVEL) IS NOT NULL) LOOP
      l_i := l_i + 1; l_y(l_i) := r.v;
    END LOOP;
    RETURN '{' || forecast_body(l_y, l_l, NVL(p_periods, 3), NVL(p_season, 12), 'MONTH', FALSE) || '}';
  END forecast_values;

  FUNCTION forecast_json(p_metric IN VARCHAR2, p_periods IN NUMBER DEFAULT 3, p_history_months IN NUMBER DEFAULT 24,
                         p_branch IN NUMBER DEFAULT NULL) RETURN CLOB IS
    d    t_def := find(p_metric);
    l_p  t_nums; l_v t_nums;
    l_to DATE := TRUNC(SYSDATE, 'MM') - 1;      -- آخر شهر مكتمل
    l_h  PLS_INTEGER := LEAST(GREATEST(NVL(p_periods, 3), 1), 24);
    l_m  PLS_INTEGER := LEAST(GREATEST(NVL(p_history_months, 24), 3), 120);
  BEGIN
    guard(d);
    series(d, ADD_MONTHS(TRUNC(l_to, 'MM'), 1 - l_m), l_to, 'MONTH', p_branch, l_p, l_v);
    RETURN '{"metric":"' || d.code || '","name":' || jt(d.name) || ',"unit":"' || d.unit || '",'
        || forecast_body(l_v, l_p, l_h, 12, 'MONTH', d.unit <> 'AMOUNT' OR d.code NOT IN ('NET_PROFIT', 'CASH_BALANCE')) || '}';
  END forecast_json;

  -- ---------------------------------------------------------------- اللوحات والتنبيهات
  FUNCTION dashboard_json(p_module IN VARCHAR2, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l CLOB := '[';
    l_first BOOLEAN := TRUE;
    l_from DATE := TRUNC(SYSDATE, 'MM');
  BEGIN
    load_defs;
    FOR i IN 1 .. g_defs.COUNT LOOP
      IF g_defs(i).module = UPPER(p_module) AND allowed(g_defs(i)) THEN
        l := l || CASE WHEN NOT l_first THEN ',' END || kpi_json(g_defs(i).code, l_from, TRUNC(SYSDATE), p_branch);
        l_first := FALSE;
      END IF;
    END LOOP;
    RETURN '{"module":"' || UPPER(p_module) || '","name":' || jt(module_name(UPPER(p_module))) || ',"kpis":' || l || ']}';
  END dashboard_json;

  FUNCTION anomalies_json(p_months IN NUMBER DEFAULT 12, p_z IN NUMBER DEFAULT 2) RETURN CLOB IS
    l CLOB := '[';
    l_first BOOLEAN := TRUE;
    l_p t_nums; l_v t_nums;
    l_to DATE := TRUNC(SYSDATE, 'MM') - 1;
    l_n PLS_INTEGER; l_mean NUMBER; l_sd NUMBER; l_z NUMBER;
  BEGIN
    load_defs;
    FOR i IN 1 .. g_defs.COUNT LOOP
      IF g_defs(i).kind = 'FLOW' AND allowed(g_defs(i)) THEN
        series(g_defs(i), ADD_MONTHS(TRUNC(l_to, 'MM'), 1 - NVL(p_months, 12)), l_to, 'MONTH', NULL, l_p, l_v);
        l_n := l_v.COUNT - 1;
        IF l_n >= 3 THEN
          l_mean := 0; FOR k IN 1 .. l_n LOOP l_mean := l_mean + l_v(k); END LOOP; l_mean := l_mean / l_n;
          l_sd := 0; FOR k IN 1 .. l_n LOOP l_sd := l_sd + POWER(l_v(k) - l_mean, 2); END LOOP; l_sd := SQRT(l_sd / l_n);
          l_z := CASE WHEN l_sd > 0 THEN (l_v(l_v.COUNT) - l_mean) / l_sd END;
          IF ABS(l_z) >= NVL(p_z, 2) THEN
            l := l || CASE WHEN NOT l_first THEN ',' END || '{"metric":"' || g_defs(i).code || '","name":' || jt(g_defs(i).name)
                   || ',"module":"' || g_defs(i).module || '","month":"' || TO_CHAR(l_to, 'YYYY-MM') || '","value":' || num(ROUND(l_v(l_v.COUNT), 2))
                   || ',"mean":' || num(ROUND(l_mean, 2)) || ',"z":' || num(ROUND(l_z, 2)) || ',"direction":"'
                   || CASE WHEN l_z > 0 THEN 'UP' ELSE 'DOWN' END || '"}';
            l_first := FALSE;
          END IF;
        END IF;
        l_p.DELETE; l_v.DELETE;
      END IF;
    END LOOP;
    RETURN l || ']';
  END anomalies_json;
END NOONA_ANL_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_ANL_PKG
