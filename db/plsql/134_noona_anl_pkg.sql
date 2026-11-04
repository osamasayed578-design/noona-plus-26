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
  FUNCTION metrics_json(p_module IN VARCHAR2 DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION metric_name(p_metric IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION is_allowed(p_metric IN VARCHAR2) RETURN VARCHAR2;
  -- قيمة المؤشر لفترة (رصيد لحظي لمؤشرات الأرصدة)
  FUNCTION kpi(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- {metric, name, value, previous, changePct, unit, from, to}
  FUNCTION kpi_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- [{p:'2026-01', v:123}] بكل الفترات (الفارغة صفر)؛ p_grain: MONTH, WEEK, DAY
  FUNCTION series_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_grain IN VARCHAR2 DEFAULT 'MONTH',
                       p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- التنبؤ الشهري: {metric, name, method, history:[{p,v}], forecast:[{p,v,lo,hi}], rmse, trendPct}
  FUNCTION forecast_json(p_metric IN VARCHAR2, p_periods IN NUMBER DEFAULT 3, p_history_months IN NUMBER DEFAULT 24,
                         p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- لوحة موديول: مؤشرات الشهر الحالي مقابل السابق {module, name, kpis:[...]}
  FUNCTION dashboard_json(p_module IN VARCHAR2, p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- أكبر الانحرافات في آخر شهر مكتمل لكل المؤشرات المسموحة: [{metric, name, value, mean, z, direction}]
  FUNCTION anomalies_json(p_months IN NUMBER DEFAULT 12, p_z IN NUMBER DEFAULT 2, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- شاشة التحليلات: لكل موديول مسموح من القائمة (FIN,SAL...) مؤشرات الشهر الحالي مع سلسلة 12 شهراً مصغرة، والفروع للمرشح
  --   {"asOf","branches":[{id,name}],"modules":[{code,name,kpis:[{metric,name,unit,kind,value,previous,changePct,spark:[..]}]}]}
  FUNCTION view_json(p_modules IN VARCHAR2, p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- رسم مؤشر: شهري مع التنبؤ، أو أسبوعي/يومي بلا تنبؤ {metric,name,unit,grain,history:[{p,v}],forecast:[...]}
  FUNCTION chart_json(p_metric IN VARCHAR2, p_grain IN VARCHAR2 DEFAULT 'MONTH', p_periods IN NUMBER DEFAULT 3,
                      p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- المجموعة (الشركة القابضة): p_scope = 'GROUP' يجمع كل الشركات التي يصلها المستخدم وله فيها صلاحية المؤشر
  --   (المدير العام ومسؤول المؤسسة: كل الشركات والفروع)؛ الافتراضي الشركة الحالية
  FUNCTION can_group RETURN VARCHAR2;
  -- توزيع مؤشر على شركات المجموعة لفترة: [{id,name,currency,value,sharePct}]
  FUNCTION companies_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE) RETURN CLOB;
  -- مقارنة السنوات: أشهر كل سنة متقابلة (يناير..ديسمبر) لآخر p_years سنوات حتى الشهر الحالي، مع إجمالي السنة
  --   والمنقضي منها (YTD) حتى الشهر نفسه ونمو كل سنة عن سابقتها
  --   {metric,name,unit,kind,ytdMonth,years:[{year,months:[12 قيمة، المستقبل null],total,ytd,growthPct,ytdGrowthPct}]}
  FUNCTION years_json(p_metric IN VARCHAR2, p_years IN NUMBER DEFAULT 3, p_branch IN NUMBER DEFAULT NULL,
                      p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- أرقام السنوات السابقة (BI_HISTORY_VALUE): أرقام شهرية من النظام السابق قبل بدء العمل على نونا تضاف للسلاسل
  -- الشهرية والمؤشرات فتظهر في مقارنة السنوات والتنبؤ؛ لا تقبل لشهر فيه بيانات فعلية في النظام (منعاً للازدواج)
  --   {metric,name,unit,kind,module,year,branch,months:[{m,value,actual,locked,source,notes}],canEdit}
  FUNCTION history_json(p_metric IN VARCHAR2, p_year IN NUMBER, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- p_values: JSON بمصفوفة 12 قيمة (null = حذف قيمة الشهر)؛ يعيد عدد الأشهر المحفوظة
  FUNCTION save_history(p_metric IN VARCHAR2, p_year IN NUMBER, p_branch IN NUMBER, p_values IN CLOB,
                        p_source IN VARCHAR2 DEFAULT 'MANUAL', p_notes IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- ملخص ما أدخل: [{metric,name,module,moduleName,unit,years:[{year,months,total}]}]
  FUNCTION history_summary_json RETURN CLOB;
  -- استيراد CSV: metric,yyyy-mm,value[,branch_code] سطر لكل شهر ← {saved, errors:[{line,msg}]}
  FUNCTION import_history_csv(p_csv IN CLOB, p_source IN VARCHAR2 DEFAULT 'IMPORT') RETURN CLOB;
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
  TYPE t_cos IS TABLE OF SYS.ODCINUMBERLIST INDEX BY VARCHAR2(100);
  g_scope VARCHAR2(10) := 'COMPANY';
  g_cos   t_cos;      -- شركات المجموعة المسموحة لكل صلاحية (يصفر مع كل طلب)

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
                  WHEN 'AUT' THEN 'خدمة السيارات' WHEN 'TRN' THEN 'النقل والشحن' WHEN 'HSP' THEN 'الضيافة والفنادق' WHEN 'RE' THEN 'العقارات' WHEN 'RST' THEN 'المطاعم'
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
    c_gl CONSTANT VARCHAR2(500) := ' gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id'
                                || ' WHERE j.company_id = :co AND j.status_code = ''POSTED'' AND NVL(j.journal_category, ''-'') <> ''CLOSING''';
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
    -- النقل والشحن
    def('TRN_REVENUE', 'إيرادات الترحيل', 'TRN', 'AMOUNT', 'FLOW', 'TRN_ORDER.VIEW', 'CAST(o.delivered_at AS DATE)', 'SUM(o.total_amount)',
        ' trn_order o WHERE o.company_id = :co AND o.status_code IN (''DELIVERED'', ''INVOICED'')', 'o.branch_id');
    def('TRN_TONNAGE', 'الأطنان المنقولة', 'TRN', 'QTY', 'FLOW', 'TRN_ORDER.VIEW', 'CAST(o.delivered_at AS DATE)',
        'SUM(o.weight_kg * NVL(o.delivered_qty, o.quantity) / NULLIF(o.quantity, 0) / 1000)',
        ' trn_order o WHERE o.company_id = :co AND o.status_code IN (''DELIVERED'', ''INVOICED'')', 'o.branch_id');
    def('TRN_TRIPS', 'الرحلات المكتملة', 'TRN', 'COUNT', 'FLOW', 'TRN_TRIP.VIEW', 'CAST(t.actual_arrival AS DATE)', 'COUNT(*)',
        ' trn_trip t WHERE t.company_id = :co AND t.status_code = ''COMPLETED''', 't.branch_id');
    def('TRN_DISTANCE', 'الكيلومترات المقطوعة', 'TRN', 'QTY', 'FLOW', 'TRN_TRIP.VIEW', 'CAST(t.actual_arrival AS DATE)', 'SUM(t.actual_distance_km)',
        ' trn_trip t WHERE t.company_id = :co AND t.status_code = ''COMPLETED''', 't.branch_id');
    def('TRN_INCIDENTS', 'الأعطال والبلاغات', 'TRN', 'COUNT', 'FLOW', 'TRN_INCIDENT.VIEW', 'CAST(i.reported_at AS DATE)', 'COUNT(*)',
        ' trn_incident i WHERE i.company_id = :co');
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

  PROCEDURE scope(p VARCHAR2) IS
  BEGIN
    g_scope := CASE WHEN UPPER(p) = 'GROUP' THEN 'GROUP' ELSE 'COMPANY' END;
    g_cos.DELETE;
  END scope;

  -- الشركات التي يجمع منها المؤشر: الحالية، أو في المجموعة كل شركة نشطة يصلها المستخدم وله فيها صلاحية المؤشر
  FUNCTION cos(d t_def) RETURN SYS.ODCINUMBERLIST IS
    l SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
  BEGIN
    IF g_scope <> 'GROUP' THEN RETURN SYS.ODCINUMBERLIST(company); END IF;
    IF g_cos.EXISTS(d.perm) THEN RETURN g_cos(d.perm); END IF;
    FOR c IN (SELECT id FROM org_company WHERE tenant_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID'))
                 AND (status_code = 'ACTIVE' OR id = company) ORDER BY id) LOOP
      IF NOONA_SECURITY_PKG.can_access_company(c.id) = 'Y' AND NOONA_SECURITY_PKG.has_permission(d.perm, c.id) = 'Y' THEN
        l.EXTEND; l(l.COUNT) := c.id;
      END IF;
    END LOOP;
    g_cos(d.perm) := l;
    RETURN l;
  END cos;

  FUNCTION src(d t_def) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(d.src, '= :co', 'IN (SELECT column_value FROM TABLE(:co))');
  END src;

  FUNCTION allowed(d t_def) RETURN BOOLEAN IS
  BEGIN
    IF g_scope = 'GROUP' THEN RETURN cos(d).COUNT > 0; END IF;
    RETURN NOONA_SECURITY_PKG.has_permission(d.perm, company) = 'Y';
  EXCEPTION WHEN OTHERS THEN RETURN FALSE;
  END allowed;

  FUNCTION can_group RETURN VARCHAR2 IS
    l_n NUMBER := 0;
  BEGIN
    FOR c IN (SELECT id FROM org_company WHERE tenant_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID')) AND status_code = 'ACTIVE') LOOP
      IF NOONA_SECURITY_PKG.can_access_company(c.id) = 'Y' THEN l_n := l_n + 1; END IF;
      EXIT WHEN l_n > 1;
    END LOOP;
    RETURN CASE WHEN l_n > 1 THEN 'Y' ELSE 'N' END;
  END can_group;

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

  FUNCTION metrics_json(p_module IN VARCHAR2 DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l CLOB := '[';
    l_first BOOLEAN := TRUE;
  BEGIN
    scope(p_scope);
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
        || CASE WHEN g_scope = 'COMPANY' AND p_branch IS NOT NULL AND d.br IS NOT NULL THEN ' AND ' || d.br || ' = ' || TO_CHAR(TRUNC(p_branch)) END;
  END where_period;

  -- مجموع أرقام السنوات السابقة لأشهر كاملة داخل الفترة (للأرصدة: رصيد شهر نهاية الفترة)
  FUNCTION hist_sum(d t_def, p_cos SYS.ODCINUMBERLIST, p_from DATE, p_to DATE, p_branch NUMBER) RETURN NUMBER IS
    l NUMBER;
    l_b NUMBER := CASE WHEN g_scope = 'COMPANY' THEN p_branch END;
  BEGIN
    IF d.kind = 'BALANCE' THEN
      SELECT SUM(h.value_amount) INTO l FROM bi_history_value h
       WHERE h.metric_code = d.code AND h.company_id IN (SELECT column_value FROM TABLE(p_cos))
         AND (l_b IS NULL OR h.branch_id = l_b) AND h.period_month = TRUNC(p_to, 'MM');
    ELSE
      SELECT SUM(h.value_amount) INTO l FROM bi_history_value h
       WHERE h.metric_code = d.code AND h.company_id IN (SELECT column_value FROM TABLE(p_cos))
         AND (l_b IS NULL OR h.branch_id = l_b)
         AND h.period_month >= TRUNC(p_from) AND LAST_DAY(h.period_month) <= TRUNC(p_to);
    END IF;
    RETURN NVL(l, 0);
  END hist_sum;

  FUNCTION kpi_val(d t_def, p_cos SYS.ODCINUMBERLIST, p_from DATE, p_to DATE, p_branch NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF d.kind = 'BALANCE' THEN
      EXECUTE IMMEDIATE 'SELECT ' || d.val || ' FROM' || src(d) || where_period(d, p_branch) INTO l USING p_cos, p_to;
    ELSE
      EXECUTE IMMEDIATE 'SELECT ' || d.val || ' FROM' || src(d) || where_period(d, p_branch) INTO l USING p_cos, TRUNC(p_from), TRUNC(p_to);
    END IF;
    RETURN ROUND(NVL(l, 0) + hist_sum(d, p_cos, p_from, p_to, p_branch), 2);
  END kpi_val;

  FUNCTION kpi(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    d t_def := find(p_metric);
  BEGIN
    scope(p_scope);
    guard(d);
    RETURN kpi_val(d, cos(d), p_from, p_to, p_branch);
  END kpi;

  FUNCTION kpi_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    d     t_def := find(p_metric);
    l_len NUMBER := TRUNC(p_to) - TRUNC(p_from) + 1;
    l_cur NUMBER;
    l_prv NUMBER;
  BEGIN
    l_cur := kpi(p_metric, p_from, p_to, p_branch, p_scope);
    l_prv := kpi(p_metric, TRUNC(p_from) - l_len, TRUNC(p_from) - 1, p_branch, p_scope);
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
    l_cs  SYS.ODCINUMBERLIST;
    l_hb  DATE := TRUNC(p_from, 'MM');
  BEGIN
    IF d.kind = 'BALANCE' THEN
      EXECUTE IMMEDIATE 'SELECT ' || d.val || ' FROM' || src(d) || ' AND ' || d.dt || ' < :b'
        || CASE WHEN g_scope = 'COMPANY' AND p_branch IS NOT NULL AND d.br IS NOT NULL THEN ' AND ' || d.br || ' = ' || TO_CHAR(TRUNC(p_branch)) END
        INTO l_open USING cos(d), l_b;
      l_open := NVL(l_open, 0);
    END IF;
    EXECUTE IMMEDIATE 'SELECT TRUNC(' || d.dt || ', ''' || l_g || '''), ' || d.val || ' FROM' || src(d) || ' AND ' || d.dt
      || ' >= :b AND ' || d.dt || ' < :e'
      || CASE WHEN g_scope = 'COMPANY' AND p_branch IS NOT NULL AND d.br IS NOT NULL THEN ' AND ' || d.br || ' = ' || TO_CHAR(TRUNC(p_branch)) END
      || ' GROUP BY TRUNC(' || d.dt || ', ''' || l_g || ''') ORDER BY 1'
      BULK COLLECT INTO l_ds, l_vs
      USING cos(d), l_b, CASE p_grain WHEN 'DAY' THEN l_e + 1 WHEN 'WEEK' THEN l_e + 7 ELSE ADD_MONTHS(l_e, 1) END;
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
    -- أرقام السنوات السابقة تضاف للعرض الشهري
    IF p_grain = 'MONTH' AND l_k > 0 THEN
      l_cs := cos(d);
      FOR h IN (SELECT TO_NUMBER(TO_CHAR(period_month, 'J')) j, SUM(value_amount) v FROM bi_history_value
                 WHERE metric_code = d.code AND company_id IN (SELECT column_value FROM TABLE(l_cs))
                   AND (g_scope <> 'COMPANY' OR p_branch IS NULL OR branch_id = p_branch)
                   AND period_month BETWEEN l_hb AND l_e
                 GROUP BY period_month) LOOP
        FOR i IN 1 .. l_k LOOP
          IF o_p(i) = h.j THEN o_v(i) := o_v(i) + h.v; END IF;
        END LOOP;
      END LOOP;
    END IF;
  END series;

  FUNCTION plabel(p_j NUMBER, p_grain VARCHAR2) RETURN VARCHAR2 IS
    l DATE := TO_DATE(TO_CHAR(p_j), 'J');
  BEGIN
    RETURN CASE p_grain WHEN 'MONTH' THEN TO_CHAR(l, 'YYYY-MM') ELSE TO_CHAR(l, 'YYYY-MM-DD') END;
  END plabel;

  FUNCTION series_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_grain IN VARCHAR2 DEFAULT 'MONTH',
                       p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    d   t_def := find(p_metric);
    l_p t_nums; l_v t_nums;
    l   CLOB := '[';
    l_g VARCHAR2(10) := NVL(UPPER(p_grain), 'MONTH');
  BEGIN
    scope(p_scope);
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
                         p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    d    t_def := find(p_metric);
    l_p  t_nums; l_v t_nums;
    l_to DATE := TRUNC(SYSDATE, 'MM') - 1;      -- آخر شهر مكتمل
    l_h  PLS_INTEGER := LEAST(GREATEST(NVL(p_periods, 3), 1), 24);
    l_m  PLS_INTEGER := LEAST(GREATEST(NVL(p_history_months, 24), 3), 120);
  BEGIN
    scope(p_scope);
    guard(d);
    series(d, ADD_MONTHS(TRUNC(l_to, 'MM'), 1 - l_m), l_to, 'MONTH', p_branch, l_p, l_v);
    RETURN '{"metric":"' || d.code || '","name":' || jt(d.name) || ',"unit":"' || d.unit || '",'
        || forecast_body(l_v, l_p, l_h, 12, 'MONTH', d.unit <> 'AMOUNT' OR d.code NOT IN ('NET_PROFIT', 'CASH_BALANCE')) || '}';
  END forecast_json;

  -- ---------------------------------------------------------------- اللوحات والتنبيهات
  FUNCTION dashboard_json(p_module IN VARCHAR2, p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l CLOB := '[';
    l_first BOOLEAN := TRUE;
    l_from DATE := TRUNC(SYSDATE, 'MM');
  BEGIN
    scope(p_scope);
    load_defs;
    FOR i IN 1 .. g_defs.COUNT LOOP
      IF g_defs(i).module = UPPER(p_module) AND allowed(g_defs(i)) THEN
        l := l || CASE WHEN NOT l_first THEN ',' END || kpi_json(g_defs(i).code, l_from, TRUNC(SYSDATE), p_branch, p_scope);
        l_first := FALSE;
      END IF;
    END LOOP;
    RETURN '{"module":"' || UPPER(p_module) || '","name":' || jt(module_name(UPPER(p_module))) || ',"kpis":' || l || ']}';
  END dashboard_json;

  FUNCTION anomalies_json(p_months IN NUMBER DEFAULT 12, p_z IN NUMBER DEFAULT 2, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l CLOB := '[';
    l_first BOOLEAN := TRUE;
    l_p t_nums; l_v t_nums;
    l_to DATE := TRUNC(SYSDATE, 'MM') - 1;
    l_n PLS_INTEGER; l_mean NUMBER; l_sd NUMBER; l_z NUMBER;
  BEGIN
    scope(p_scope);
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

  -- ---------------------------------------------------------------- الشاشات
  FUNCTION view_json(p_modules IN VARCHAR2, p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l       CLOB;
    l_mods  CLOB;
    l_kpis  CLOB;
    l_sp    VARCHAR2(4000);
    l_p     t_nums; l_v t_nums;
    l_to    DATE := TRUNC(SYSDATE);
    l_mlist VARCHAR2(400) := ',' || REPLACE(UPPER(NVL(p_modules, 'FIN,SAL,SCM,HR,MFG,HIS,AUT,TRN,HSP,RE,RST')), ' ', '') || ',';
    l_first BOOLEAN := TRUE;
    l_kf    BOOLEAN;
    l_n     PLS_INTEGER := 0;
  BEGIN
    NOONA_CORE_PKG.assert(company IS NOT NULL, 'NOONA-ANL-002', 'اختر الشركة أولاً', 'No company context');
    scope(p_scope);
    load_defs;
    FOR m IN (SELECT REGEXP_SUBSTR(l_mlist, '[^,]+', 1, LEVEL) code, LEVEL o FROM dual
               CONNECT BY REGEXP_SUBSTR(l_mlist, '[^,]+', 1, LEVEL) IS NOT NULL ORDER BY 2) LOOP
      l_kpis := NULL; l_kf := TRUE;
      FOR i IN 1 .. g_defs.COUNT LOOP
        IF g_defs(i).module = m.code AND allowed(g_defs(i)) THEN
          series(g_defs(i), ADD_MONTHS(TRUNC(l_to, 'MM'), -11), l_to, 'MONTH', p_branch, l_p, l_v);
          l_sp := NULL;
          FOR k IN 1 .. l_v.COUNT LOOP l_sp := l_sp || CASE WHEN k > 1 THEN ',' END || num(ROUND(l_v(k), 2)); END LOOP;
          l_p.DELETE; l_v.DELETE;
          l_kpis := l_kpis || CASE WHEN NOT l_kf THEN ',' END
                 || RTRIM(kpi_json(g_defs(i).code, TRUNC(l_to, 'MM'), l_to, p_branch, g_scope), '}') || ',"spark":[' || l_sp || ']}';
          l_kf := FALSE; l_n := l_n + 1;
        END IF;
      END LOOP;
      IF l_kpis IS NOT NULL THEN
        l_mods := l_mods || CASE WHEN NOT l_first THEN ',' END || '{"code":"' || m.code || '","name":' || jt(module_name(m.code))
               || ',"kpis":[' || l_kpis || ']}';
        l_first := FALSE;
      END IF;
    END LOOP;
    l := '{"asOf":"' || TO_CHAR(l_to, 'YYYY-MM-DD') || '","from":"' || TO_CHAR(TRUNC(l_to, 'MM'), 'YYYY-MM-DD') || '","count":' || l_n
      || ',"scope":"' || g_scope || '","canGroup":"' || can_group || '","companies":[';
    l_first := TRUE;
    IF g_scope = 'GROUP' THEN
      FOR c IN (SELECT id, NVL(trade_name_ar, legal_name_ar) nm, functional_currency cur FROM org_company
                 WHERE tenant_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID')) AND (status_code = 'ACTIVE' OR id = company) ORDER BY id) LOOP
        IF NOONA_SECURITY_PKG.can_access_company(c.id) = 'Y' THEN
          l := l || CASE WHEN NOT l_first THEN ',' END || '{"id":' || c.id || ',"name":' || jt(c.nm) || ',"currency":"' || c.cur || '"}';
          l_first := FALSE;
        END IF;
      END LOOP;
    END IF;
    l := l || '],"branch":' || CASE WHEN g_scope = 'GROUP' THEN 'null' ELSE NVL(TO_CHAR(p_branch), 'null') END || ',"branches":[';
    l_first := TRUE;
    FOR b IN (SELECT id, name_ar FROM org_branch WHERE company_id = company AND status_code = 'ACTIVE' AND g_scope = 'COMPANY'
               ORDER BY is_head_office DESC, name_ar) LOOP
      l := l || CASE WHEN NOT l_first THEN ',' END || '{"id":' || b.id || ',"name":' || jt(b.name_ar) || '}';
      l_first := FALSE;
    END LOOP;
    RETURN l || '],"modules":[' || l_mods || ']}';
  END view_json;

  FUNCTION chart_json(p_metric IN VARCHAR2, p_grain IN VARCHAR2 DEFAULT 'MONTH', p_periods IN NUMBER DEFAULT 3,
                      p_branch IN NUMBER DEFAULT NULL, p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    d   t_def := find(p_metric);
    l_g VARCHAR2(10) := NVL(UPPER(p_grain), 'MONTH');
  BEGIN
    IF l_g = 'MONTH' THEN
      RETURN RTRIM(forecast_json(p_metric, p_periods, 24, p_branch, p_scope), '}') || ',"grain":"MONTH","kind":"' || d.kind
          || '","scope":"' || g_scope || '"}';
    END IF;
    RETURN '{"metric":"' || d.code || '","name":' || jt(d.name) || ',"unit":"' || d.unit || '","kind":"' || d.kind || '","grain":"' || l_g
        || '","history":' || series_json(p_metric, CASE l_g WHEN 'WEEK' THEN TRUNC(SYSDATE, 'IW') - 7 * 25 ELSE TRUNC(SYSDATE) - 59 END,
                                         TRUNC(SYSDATE), l_g, p_branch, p_scope)
        || ',"forecast":[],"scope":"' || g_scope || '"}';
  END chart_json;

  FUNCTION years_json(p_metric IN VARCHAR2, p_years IN NUMBER DEFAULT 3, p_branch IN NUMBER DEFAULT NULL,
                      p_scope IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    d      t_def := find(p_metric);
    l_n    PLS_INTEGER := LEAST(GREATEST(NVL(TRUNC(p_years), 3), 2), 6);
    l_m    PLS_INTEGER := TO_NUMBER(TO_CHAR(SYSDATE, 'MM'));
    l_y    PLS_INTEGER := TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'));
    l_p    t_nums;
    l_v    t_nums;
    l      CLOB;
    l_tot  t_nums;
    l_ytd  t_nums;
    l_last t_nums;   -- قيمة آخر شهر في السنة (للأرصدة: الإجمالي هو رصيد نهاية الفترة)
    k      PLS_INTEGER;
    l_yr   PLS_INTEGER;
  BEGIN
    scope(p_scope);
    guard(d);
    series(d, TO_DATE((l_y - l_n + 1) || '-01-01', 'YYYY-MM-DD'), TRUNC(SYSDATE, 'MM'), 'MONTH', p_branch, l_p, l_v);
    l := '{"metric":"' || d.code || '","name":' || jt(d.name) || ',"unit":"' || d.unit || '","kind":"' || d.kind
      || '","ytdMonth":' || l_m || ',"scope":"' || g_scope || '","years":[';
    FOR i IN 1 .. l_n LOOP
      l_yr := l_y - l_n + i;
      l_tot(i) := 0; l_ytd(i) := 0; l_last(i) := NULL;
      l := l || CASE WHEN i > 1 THEN ',' END || '{"year":' || l_yr || ',"months":[';
      FOR m IN 1 .. 12 LOOP
        k := (i - 1) * 12 + m;
        IF k <= l_v.COUNT THEN
          l := l || CASE WHEN m > 1 THEN ',' END || num(l_v(k));
          IF d.kind = 'BALANCE' THEN
            l_last(i) := l_v(k);
            IF m = l_m THEN l_ytd(i) := l_v(k); END IF;
          ELSE
            l_tot(i) := l_tot(i) + l_v(k);
            IF m <= l_m THEN l_ytd(i) := l_ytd(i) + l_v(k); END IF;
          END IF;
        ELSE
          l := l || CASE WHEN m > 1 THEN ',' END || 'null';
        END IF;
      END LOOP;
      IF d.kind = 'BALANCE' THEN l_tot(i) := l_last(i); END IF;
      l := l || '],"total":' || num(l_tot(i)) || ',"ytd":' || num(l_ytd(i))
        || ',"growthPct":' || num(CASE WHEN i > 1 AND i < l_n AND l_tot(i - 1) <> 0
                                       THEN ROUND((l_tot(i) - l_tot(i - 1)) / ABS(l_tot(i - 1)) * 100, 1) END)
        || ',"ytdGrowthPct":' || num(CASE WHEN i > 1 AND l_ytd(i - 1) <> 0
                                          THEN ROUND((l_ytd(i) - l_ytd(i - 1)) / ABS(l_ytd(i - 1)) * 100, 1) END)
        || ',"partial":' || CASE WHEN i = l_n THEN 'true' ELSE 'false' END || '}';
    END LOOP;
    RETURN l || ']}';
  END years_json;

  -- ---------------------------------------------------------------- أرقام السنوات السابقة
  -- القيمة الفعلية من النظام لشهر (بلا أرقام السنوات السابقة)
  FUNCTION actual_month(d t_def, p_month DATE, p_branch NUMBER) RETURN NUMBER IS
    l NUMBER;
    l_to DATE := LAST_DAY(p_month);
  BEGIN
    IF d.kind = 'BALANCE' THEN
      EXECUTE IMMEDIATE 'SELECT ' || d.val || ' FROM' || src(d) || where_period(d, p_branch) INTO l USING SYS.ODCINUMBERLIST(company), l_to;
    ELSE
      EXECUTE IMMEDIATE 'SELECT ' || d.val || ' FROM' || src(d) || where_period(d, p_branch) INTO l USING SYS.ODCINUMBERLIST(company), p_month, l_to;
    END IF;
    RETURN ROUND(NVL(l, 0), 2);
  END actual_month;

  FUNCTION history_json(p_metric IN VARCHAR2, p_year IN NUMBER, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB IS
    d     t_def := find(p_metric);
    l     CLOB;
    l_m   DATE;
    l_act NUMBER;
    l_val NUMBER;
    l_src VARCHAR2(30);
    l_nt  VARCHAR2(4000);
    l_can VARCHAR2(1) := NOONA_SECURITY_PKG.has_permission('BI_HISTORY_VALUE.CREATE', company);
  BEGIN
    scope('COMPANY');
    guard(d);
    NOONA_SECURITY_PKG.assert_permission('BI_HISTORY_VALUE.VIEW', company);
    NOONA_CORE_PKG.assert(p_year BETWEEN 1990 AND TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')), 'NOONA-ANL-010', 'السنة غير صحيحة', 'Invalid year');
    l := '{"metric":"' || d.code || '","name":' || jt(d.name) || ',"unit":"' || d.unit || '","kind":"' || d.kind
      || '","module":"' || d.module || '","moduleName":' || jt(module_name(d.module)) || ',"year":' || TRUNC(p_year)
      || ',"branch":' || NVL(TO_CHAR(p_branch), 'null') || ',"canEdit":' || CASE WHEN l_can = 'Y' THEN 'true' ELSE 'false' END
      || ',"branchApplies":' || CASE WHEN d.br IS NOT NULL THEN 'true' ELSE 'false' END || ',"months":[';
    FOR m IN 1 .. 12 LOOP
      l_m := TO_DATE(TRUNC(p_year) || '-' || LPAD(m, 2, '0') || '-01', 'YYYY-MM-DD');
      l_val := NULL; l_src := NULL; l_nt := NULL;
      BEGIN
        SELECT value_amount, source_code, notes INTO l_val, l_src, l_nt FROM bi_history_value
         WHERE company_id = company AND metric_code = d.code AND period_month = l_m
           AND (branch_id = p_branch OR (branch_id IS NULL AND p_branch IS NULL));
      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      END;
      l_act := CASE WHEN l_m <= SYSDATE THEN actual_month(d, l_m, p_branch) END;
      l := l || CASE WHEN m > 1 THEN ',' END || '{"m":' || m || ',"value":' || num(l_val) || ',"actual":' || num(l_act)
        || ',"locked":' || CASE WHEN l_m > TRUNC(SYSDATE, 'MM') OR (NVL(l_act, 0) <> 0 AND l_val IS NULL) THEN 'true' ELSE 'false' END
        || ',"future":' || CASE WHEN l_m > TRUNC(SYSDATE, 'MM') THEN 'true' ELSE 'false' END
        || ',"source":' || CASE WHEN l_src IS NULL THEN 'null' ELSE '"' || l_src || '"' END || ',"notes":' || jt(l_nt) || '}';
    END LOOP;
    RETURN l || ']}';
  END history_json;

  FUNCTION put_history(d t_def, p_month DATE, p_branch NUMBER, p_value NUMBER, p_source VARCHAR2, p_notes VARCHAR2) RETURN NUMBER IS
    l_act NUMBER;
  BEGIN
    IF p_value IS NULL THEN
      DELETE FROM bi_history_value WHERE company_id = company AND metric_code = d.code AND period_month = p_month
         AND (branch_id = p_branch OR (branch_id IS NULL AND p_branch IS NULL));
      RETURN 0;
    END IF;
    NOONA_CORE_PKG.assert(p_month <= TRUNC(SYSDATE, 'MM'), 'NOONA-ANL-011', 'لا تدخل أرقاماً لشهر لم يأت بعد: ' || TO_CHAR(p_month, 'YYYY-MM'),
      'Future month');
    l_act := actual_month(d, p_month, p_branch);
    NOONA_CORE_PKG.assert(l_act = 0, 'NOONA-ANL-012',
      'شهر ' || TO_CHAR(p_month, 'YYYY-MM') || ' فيه بيانات فعلية في النظام (' || TO_CHAR(l_act) || ')؛ أرقام السنوات السابقة للأشهر قبل بدء العمل فقط',
      'Month has actual data');
    NOONA_CORE_PKG.assert(d.unit = 'AMOUNT' OR p_value >= 0, 'NOONA-ANL-013', 'القيمة لا تكون سالبة لهذا المؤشر', 'Negative value');
    MERGE INTO bi_history_value t
    USING (SELECT company c, d.code mc, p_month pm, p_branch br FROM dual) s
       ON (t.company_id = s.c AND t.metric_code = s.mc AND t.period_month = s.pm AND (t.branch_id = s.br OR (t.branch_id IS NULL AND s.br IS NULL)))
     WHEN MATCHED THEN UPDATE SET t.value_amount = p_value, t.source_code = NVL(p_source, 'MANUAL'), t.notes = NVL(p_notes, t.notes)
     WHEN NOT MATCHED THEN INSERT (tenant_id, company_id, metric_code, period_month, branch_id, value_amount, source_code, notes)
          VALUES (TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID')), s.c, s.mc, s.pm, s.br, p_value, NVL(p_source, 'MANUAL'), p_notes);
    RETURN 1;
  END put_history;

  PROCEDURE check_branch(d t_def, p_branch NUMBER) IS
    l_n NUMBER;
  BEGIN
    IF p_branch IS NULL THEN RETURN; END IF;
    NOONA_CORE_PKG.assert(d.br IS NOT NULL, 'NOONA-ANL-014', 'هذا المؤشر لا يفصل بالفروع؛ أدخله للشركة كلها', 'Metric has no branch');
    SELECT COUNT(*) INTO l_n FROM org_branch WHERE id = p_branch AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-ANL-015', 'الفرع غير موجود في الشركة الحالية', 'Branch not in company');
  END check_branch;

  FUNCTION save_history(p_metric IN VARCHAR2, p_year IN NUMBER, p_branch IN NUMBER, p_values IN CLOB,
                        p_source IN VARCHAR2 DEFAULT 'MANUAL', p_notes IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    d    t_def := find(p_metric);
    l_n  NUMBER := 0;
    l_v  NUMBER;
    l_tx VARCHAR2(100);
    l_ar JSON_ARRAY_T;
  BEGIN
    scope('COMPANY');
    guard(d);
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('BI_HISTORY_VALUE.CREATE', company);
    NOONA_CORE_PKG.assert(p_year BETWEEN 1990 AND TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')), 'NOONA-ANL-010', 'السنة غير صحيحة', 'Invalid year');
    check_branch(d, p_branch);
    l_ar := JSON_ARRAY_T.parse(p_values);
    NOONA_CORE_PKG.assert(l_ar.get_size = 12, 'NOONA-ANL-016', 'المطلوب 12 قيمة شهرية', '12 values expected');
    FOR m IN 1 .. 12 LOOP
      l_v := NULL;
      IF NOT l_ar.get(m - 1).is_null THEN
        l_tx := TRIM(REPLACE(l_ar.get(m - 1).to_string, '"'));
        IF l_tx IS NOT NULL THEN
          BEGIN
            l_v := TO_NUMBER(REPLACE(l_tx, ','), '99999999999999990D9999', 'NLS_NUMERIC_CHARACTERS=''.,''');
          EXCEPTION WHEN VALUE_ERROR OR INVALID_NUMBER THEN
            NOONA_CORE_PKG.raise_error('NOONA-ANL-017', 'قيمة غير رقمية لشهر ' || m || ': ' || l_tx, 'Not a number');
          END;
        END IF;
      END IF;
      l_n := l_n + put_history(d, TO_DATE(TRUNC(p_year) || '-' || LPAD(m, 2, '0') || '-01', 'YYYY-MM-DD'), p_branch, l_v, p_source, p_notes);
    END LOOP;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'BI_HISTORY_VALUE', NULL, 'SAVE_HISTORY ' || d.code || ' ' || TRUNC(p_year), 'SUCCESS');
    RETURN l_n;
  END save_history;

  FUNCTION history_summary_json RETURN CLOB IS
    l     CLOB := '[';
    l_cur VARCHAR2(40);
    l_d   t_def;
    l_fy  BOOLEAN := TRUE;
  BEGIN
    scope('COMPANY');
    NOONA_SECURITY_PKG.assert_permission('BI_HISTORY_VALUE.VIEW', company);
    FOR r IN (SELECT metric_code, EXTRACT(YEAR FROM period_month) yr, COUNT(DISTINCT period_month) n, SUM(value_amount) tot,
                     MAX(source_code) src
                FROM bi_history_value WHERE company_id = company
               GROUP BY metric_code, EXTRACT(YEAR FROM period_month) ORDER BY metric_code, yr) LOOP
      IF l_cur IS NULL OR l_cur <> r.metric_code THEN
        IF l_cur IS NOT NULL THEN l := l || ']}'; END IF;
        l_d := find(r.metric_code);
        l := l || CASE WHEN l_cur IS NOT NULL THEN ',' END || '{"metric":"' || l_d.code || '","name":' || jt(l_d.name)
          || ',"module":"' || l_d.module || '","moduleName":' || jt(module_name(l_d.module)) || ',"unit":"' || l_d.unit
          || '","kind":"' || l_d.kind || '","years":[';
        l_cur := r.metric_code; l_fy := TRUE;
      END IF;
      l := l || CASE WHEN NOT l_fy THEN ',' END || '{"year":' || r.yr || ',"months":' || r.n || ',"total":' || num(r.tot) || '}';
      l_fy := FALSE;
    END LOOP;
    IF l_cur IS NOT NULL THEN l := l || ']}'; END IF;
    RETURN l || ']';
  END history_summary_json;

  FUNCTION import_history_csv(p_csv IN CLOB, p_source IN VARCHAR2 DEFAULT 'IMPORT') RETURN CLOB IS
    l_line  VARCHAR2(4000);
    l_pos   PLS_INTEGER := 1;
    l_nl    PLS_INTEGER;
    l_no    PLS_INTEGER := 0;
    l_ok    PLS_INTEGER := 0;
    l_err   CLOB := '[';
    l_ne    PLS_INTEGER := 0;
    l_len   PLS_INTEGER := NVL(DBMS_LOB.getlength(p_csv), 0);
    l_f1    VARCHAR2(100);
    l_f2    VARCHAR2(100);
    l_f3    VARCHAR2(100);
    l_f4    VARCHAR2(100);
    l_br    NUMBER;
    l_d     t_def;
    l_month DATE;
    l_val   NUMBER;
  BEGIN
    scope('COMPANY');
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('BI_HISTORY_VALUE.CREATE', company);
    WHILE l_pos <= l_len AND l_no < 20000 LOOP
      l_nl := DBMS_LOB.instr(p_csv, CHR(10), l_pos);
      IF l_nl = 0 THEN l_nl := l_len + 1; END IF;
      l_line := TRIM(REPLACE(DBMS_LOB.substr(p_csv, LEAST(l_nl - l_pos, 4000), l_pos), CHR(13)));
      l_pos := l_nl + 1;
      l_no := l_no + 1;
      CONTINUE WHEN l_line IS NULL OR (l_no = 1 AND UPPER(l_line) LIKE 'METRIC%');
      BEGIN
        l_line := REPLACE(l_line, ';', ',');
        l_f1 := UPPER(TRIM(REGEXP_SUBSTR(l_line, '[^,]*', 1, 1)));
        l_f2 := TRIM(REGEXP_SUBSTR(l_line, '[^,]*', 1, 3));
        l_f3 := TRIM(REGEXP_SUBSTR(l_line, '[^,]*', 1, 5));
        l_f4 := TRIM(REGEXP_SUBSTR(l_line, '[^,]*', 1, 7));
        l_d := find(l_f1);
        guard(l_d);
        BEGIN
          l_month := TO_DATE(SUBSTR(REPLACE(l_f2, '/', '-'), 1, 7) || '-01', 'YYYY-MM-DD');
        EXCEPTION WHEN OTHERS THEN
          NOONA_CORE_PKG.raise_error('NOONA-ANL-018', 'الشهر يكتب YYYY-MM: ' || l_f2, 'Month format YYYY-MM');
        END;
        BEGIN
          l_val := TO_NUMBER(l_f3, '99999999999999990D9999', 'NLS_NUMERIC_CHARACTERS=''.,''');
        EXCEPTION WHEN OTHERS THEN
          NOONA_CORE_PKG.raise_error('NOONA-ANL-017', 'قيمة غير رقمية: ' || l_f3, 'Not a number');
        END;
        l_br := NULL;
        IF l_f4 IS NOT NULL THEN
          BEGIN
            SELECT id INTO l_br FROM org_branch WHERE company_id = company AND UPPER(code) = UPPER(l_f4);
          EXCEPTION WHEN NO_DATA_FOUND THEN
            NOONA_CORE_PKG.raise_error('NOONA-ANL-015', 'رمز الفرع غير موجود: ' || l_f4, 'Unknown branch');
          END;
          check_branch(l_d, l_br);
        END IF;
        l_ok := l_ok + put_history(l_d, l_month, l_br, l_val, NVL(p_source, 'IMPORT'), NULL);
      EXCEPTION WHEN OTHERS THEN
        IF l_ne < 200 THEN
          l_err := l_err || CASE WHEN l_ne > 0 THEN ',' END || '{"line":' || l_no || ',"msg":'
            || jt(NVL(REGEXP_SUBSTR(SQLERRM, 'NOONA-[A-Z]+-[0-9]+: [^' || CHR(10) || ']+'), SQLERRM)) || '}';
        END IF;
        l_ne := l_ne + 1;
      END;
    END LOOP;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'BI_HISTORY_VALUE', NULL, 'IMPORT_HISTORY ' || l_ok, 'SUCCESS');
    RETURN '{"saved":' || l_ok || ',"errorCount":' || l_ne || ',"errors":' || l_err || ']}';
  END import_history_csv;

  FUNCTION companies_json(p_metric IN VARCHAR2, p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    d     t_def := find(p_metric);
    l_cs  SYS.ODCINUMBERLIST;
    l     CLOB := '[';
    l_tot NUMBER := 0;
    TYPE t_v IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    l_v   t_v;
    l_nm  VARCHAR2(400);
    l_cur VARCHAR2(10);
  BEGIN
    scope('GROUP');
    guard(d);
    l_cs := cos(d);
    FOR i IN 1 .. l_cs.COUNT LOOP
      l_v(i) := kpi_val(d, SYS.ODCINUMBERLIST(l_cs(i)), p_from, p_to, NULL);
      l_tot := l_tot + ABS(l_v(i));
    END LOOP;
    FOR i IN 1 .. l_cs.COUNT LOOP
      SELECT NVL(trade_name_ar, legal_name_ar), functional_currency INTO l_nm, l_cur FROM org_company WHERE id = l_cs(i);
      l := l || CASE WHEN i > 1 THEN ',' END || '{"id":' || l_cs(i) || ',"name":' || jt(l_nm) || ',"currency":"' || l_cur
             || '","value":' || num(l_v(i)) || ',"sharePct":' || num(CASE WHEN l_tot <> 0 THEN ROUND(ABS(l_v(i)) / l_tot * 100, 1) END) || '}';
    END LOOP;
    RETURN l || ']';
  END companies_json;
END NOONA_ANL_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_ANL_PKG
