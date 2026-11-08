-- =============================================================================
-- NOONA PLUS ERP | NOONA_CONSOL_PKG - القوائم المالية الموحدة للشركة القابضة (مجموعة الأعمال)
--   * مجموعة التجميع (GL_CONSOLIDATION_GROUP): مجموعة أعمال (وما تحتها من مجموعات) أو كل شركات المؤسسة، وعملة التجميع
--   * الشركات: كل شركة في المجموعة لها دفترها؛ دليل الحسابات خاص بكل شركة (المطابقة برقم الحساب)
--     أو دليل المجموعة الموحد (NOONA_GL_PKG.quick_setup بخيار GROUP) فتتطابق الحسابات تلقائياً
--   * الاستبعاد: أرصدة وحركات الحسابات المصنفة «بين الشركات» (SUBLEDGER_CODE = INTERCOMPANY) والحسابات المضافة
--     في قاعدة الاستبعاد (GL_ELIMINATION_RULE: {"accounts":["1150","2150"]}) تستبعد بالكامل من الموحد
--   * الترجمة: مبالغ كل شركة بعملتها الوظيفية تحول لعملة التجميع بسعر الإقفال (سعر الصرف المحاسبي في تاريخ نهاية الفترة)
--   * التقارير: ميزان مراجعة موحد، قائمة دخل موحدة، مركز مالي موحد؛ بعمود لكل شركة وعمود الاستبعاد والموحد
--   * لا يغير التجميع دفاتر الشركات؛ «اعتماد التجميع» يحفظ نسخة من النتائج للفترة (GL_CONSOLIDATION_RUN)
--   * الصلاحية: عرض أرصدة الأستاذ (GL_BALANCE.VIEW) في كل شركة مشمولة؛ الشركات التي لا يصلها المستخدم لا تدخل وتذكر
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_CONSOL_PKG AUTHID DEFINER AS
  -- مجموعة الأعمال (الشركة القابضة): إنشاء أو تعديل، وربط شركة بها (NULL يفك الربط)
  FUNCTION save_business_group(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_currency IN VARCHAR2,
                               p_parent_id IN NUMBER DEFAULT NULL, p_name_en IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE set_company_group(p_company_id IN NUMBER, p_business_group_id IN NUMBER);
  -- إنشاء أو تعديل مجموعة التجميع؛ p_elim_accounts أرقام حسابات مفصولة بفواصل تستبعد إضافة لحسابات «بين الشركات»
  FUNCTION save_group(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_business_group_id IN NUMBER,
                      p_currency IN VARCHAR2, p_elim_accounts IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION elim_accounts(p_group_id IN NUMBER) RETURN VARCHAR2;
  -- أسماء الشركات المشمولة (للعرض)
  FUNCTION members_text(p_group_id IN NUMBER) RETURN VARCHAR2;
  -- p_kind: TB ميزان المراجعة | IS قائمة الدخل | BS المركز المالي ؛ p_by_company: Y عمود لكل شركة
  FUNCTION report(p_group_id IN NUMBER, p_kind IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_by_company IN VARCHAR2 DEFAULT 'Y') RETURN CLOB;
  -- اعتماد التجميع للفترة (شهر نهاية الفترة): يحفظ الإجماليات والتحقق؛ يعيد رقم العملية
  FUNCTION approve(p_group_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER;
END NOONA_CONSOL_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_CONSOL_PKG AS

  TYPE t_num   IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  TYPE t_vc    IS TABLE OF VARCHAR2(400) INDEX BY PLS_INTEGER;
  TYPE t_amt   IS TABLE OF NUMBER INDEX BY VARCHAR2(80);     -- المفتاح: رقم الحساب|ترتيب الشركة
  TYPE t_acc   IS RECORD (code VARCHAR2(50), name VARCHAR2(400), typ VARCHAR2(20), elim BOOLEAN);
  TYPE t_accs  IS TABLE OF t_acc INDEX BY VARCHAR2(50);

  g_co     t_num;     -- الشركات المشمولة
  g_cname  t_vc;      -- أسماؤها المختصرة
  g_rate   t_num;     -- سعر التحويل لعملة التجميع
  g_skip   VARCHAR2(4000);
  g_acc    t_accs;
  g_amt    t_amt;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;

  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF p IS NULL OR ROUND(p, 2) = 0 THEN RETURN ''; END IF;
    RETURN CASE WHEN p < 0 THEN '(' END || TRIM(TO_CHAR(ABS(p), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,''')) || CASE WHEN p < 0 THEN ')' END;
  END fmt;

  FUNCTION grp(p_id NUMBER) RETURN gl_consolidation_group%ROWTYPE IS
    l gl_consolidation_group%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM gl_consolidation_group WHERE id = p_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-CNS-001', 'مجموعة التجميع غير موجودة؛ أنشئها من «مجموعات التجميع»', 'Consolidation group not found');
  END grp;

  FUNCTION elim_accounts(p_group_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(jt.code, ',') WITHIN GROUP (ORDER BY jt.code) INTO l
      FROM gl_elimination_rule r,
           JSON_TABLE(r.rule_definition, '$.accounts[*]' COLUMNS (code VARCHAR2(50) PATH '$')) jt
     WHERE r.group_id = p_group_id AND r.is_active = 'Y';
    RETURN l;
  END elim_accounts;

  FUNCTION save_business_group(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_currency IN VARCHAR2,
                               p_parent_id IN NUMBER DEFAULT NULL, p_name_en IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER := p_id;
    l_n  NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(CASE WHEN p_id IS NULL THEN 'ORG_BUSINESS_GROUP.CREATE' ELSE 'ORG_BUSINESS_GROUP.UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-CNS-002', 'الرمز والاسم مطلوبان', 'Code and name are required');
    IF p_parent_id IS NOT NULL AND p_id IS NOT NULL THEN
      -- لا تكون المجموعة أماً لنفسها أو لمجموعة فوقها
      SELECT COUNT(*) INTO l_n FROM org_business_group WHERE id = p_parent_id
       START WITH id = p_id CONNECT BY PRIOR id = parent_group_id;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-CNS-011', 'المجموعة الأم لا تكون المجموعة نفسها أو من تحتها', 'Invalid parent group');
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO org_business_group (code, name_ar, name_en, consolidation_currency, parent_group_id, status_code, effective_from)
      VALUES (UPPER(TRIM(p_code)), TRIM(p_name_ar), NVL(TRIM(p_name_en), TRIM(p_name_ar)), p_currency, p_parent_id, 'ACTIVE', TRUNC(SYSDATE))
      RETURNING id INTO l_id;
    ELSE
      UPDATE org_business_group SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), name_en = NVL(TRIM(p_name_en), TRIM(p_name_ar)),
             consolidation_currency = p_currency, parent_group_id = p_parent_id WHERE id = l_id;
    END IF;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_BUSINESS_GROUP', l_id, 'SAVE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-CNS-012', 'رمز مجموعة الأعمال مستخدم', 'Business group code already exists');
  END save_business_group;

  PROCEDURE set_company_group(p_company_id IN NUMBER, p_business_group_id IN NUMBER) IS
    l_old NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.UPDATE', p_company_id);
    SELECT business_group_id INTO l_old FROM org_company WHERE id = p_company_id;
    -- شركة تستخدم دليل مجموعتها الموحد لا تنقل لمجموعة أخرى
    IF NOONA_GL_PKG.coa_mode(p_company_id) = 'GROUP' AND NVL(p_business_group_id, -1) <> NVL(l_old, -1) THEN
      NOONA_CORE_PKG.raise_error('NOONA-CNS-013', 'الشركة تستخدم دليل حسابات المجموعة الموحد؛ لا تنقل لمجموعة أخرى', 'Company uses the group chart');
    END IF;
    UPDATE org_company SET business_group_id = p_business_group_id WHERE id = p_company_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_COMPANY', p_company_id, 'SET_BUSINESS_GROUP', 'SUCCESS');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-CNS-014', 'الشركة غير موجودة', 'Company not found');
  END set_company_group;

  FUNCTION save_group(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_business_group_id IN NUMBER,
                      p_currency IN VARCHAR2, p_elim_accounts IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_id   NUMBER := p_id;
    l_json VARCHAR2(4000) := '{"accounts":[';
    l_n    PLS_INTEGER := 0;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(CASE WHEN p_id IS NULL THEN 'GL_CONSOLIDATION_GROUP.CREATE' ELSE 'GL_CONSOLIDATION_GROUP.UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-CNS-002', 'الرمز والاسم مطلوبان', 'Code and name are required');
    NOONA_CORE_PKG.assert(p_currency IS NOT NULL, 'NOONA-CNS-004', 'اختر عملة التجميع', 'Consolidation currency is required');
    IF l_id IS NULL THEN
      INSERT INTO gl_consolidation_group (code, name_ar, name_en, business_group_id, consolidation_currency, is_active)
      VALUES (UPPER(TRIM(p_code)), TRIM(p_name_ar), TRIM(p_name_ar), p_business_group_id, p_currency, 'Y')
      RETURNING id INTO l_id;
    ELSE
      UPDATE gl_consolidation_group SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), business_group_id = p_business_group_id,
             consolidation_currency = p_currency WHERE id = l_id;
    END IF;
    FOR r IN (SELECT DISTINCT TRIM(REGEXP_SUBSTR(p_elim_accounts, '[^,;[:space:]]+', 1, LEVEL)) c FROM dual
               CONNECT BY REGEXP_SUBSTR(p_elim_accounts, '[^,;[:space:]]+', 1, LEVEL) IS NOT NULL) LOOP
      IF r.c IS NOT NULL THEN
        NOONA_CORE_PKG.assert(REGEXP_LIKE(r.c, '^[0-9A-Z][0-9A-Z.-]{0,19}$'), 'NOONA-CNS-005', 'رقم حساب غير صالح: ' || r.c, 'Invalid account code');
        l_json := l_json || CASE WHEN l_n > 0 THEN ',' END || '"' || r.c || '"'; l_n := l_n + 1;
      END IF;
    END LOOP;
    l_json := l_json || ']}';
    MERGE INTO gl_elimination_rule t
    USING (SELECT l_id gid FROM dual) s ON (t.group_id = s.gid AND t.code = 'DEFAULT')
    WHEN MATCHED THEN UPDATE SET t.rule_definition = l_json, t.is_active = 'Y'
    WHEN NOT MATCHED THEN INSERT (group_id, code, name_ar, name_en, rule_definition, is_active)
      VALUES (l_id, 'DEFAULT', 'حسابات الاستبعاد', 'Elimination accounts', l_json, 'Y');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'GL_CONSOLIDATION_GROUP', l_id, 'SAVE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-CNS-006', 'رمز المجموعة مستخدم', 'Group code already exists');
  END save_group;

  -- الشركات المشمولة: مجموعة الأعمال وما تحتها، أو كل شركات المؤسسة إن لم تحدد؛ مع سعر التحويل لعملة التجميع
  PROCEDURE load_members(g gl_consolidation_group%ROWTYPE, p_to DATE) IS
    l_type NUMBER;
    l_cur  VARCHAR2(3);
    l_r    NUMBER;
  BEGIN
    g_co.DELETE; g_cname.DELETE; g_rate.DELETE; g_skip := NULL;
    SELECT MIN(id) INTO l_type FROM ref_rate_type WHERE code = 'ACCOUNTING';
    FOR c IN (SELECT id, code, NVL(trade_name_ar, legal_name_ar) nm FROM org_company
               WHERE status_code NOT IN ('CLOSED', 'ARCHIVED')
                 AND (g.business_group_id IS NULL
                      OR business_group_id IN (SELECT id FROM org_business_group START WITH id = g.business_group_id
                                               CONNECT BY PRIOR id = parent_group_id))
               ORDER BY id) LOOP                                   -- الشركة القابضة (أول شركة في المجموعة) أولاً
      IF NOONA_GL_PKG.primary_ledger(c.id) IS NULL THEN
        g_skip := g_skip || CASE WHEN g_skip IS NOT NULL THEN '، ' END || c.nm || ' (لم يجهز أستاذها العام)';
      ELSIF NOONA_SECURITY_PKG.can_access_company(c.id) <> 'Y' OR NOONA_SECURITY_PKG.has_permission('GL_BALANCE.VIEW', c.id) <> 'Y' THEN
        g_skip := g_skip || CASE WHEN g_skip IS NOT NULL THEN '، ' END || c.nm || ' (لا صلاحية)';
      ELSE
        SELECT currency_code INTO l_cur FROM gl_ledger WHERE id = NOONA_GL_PKG.primary_ledger(c.id);
        IF l_cur = g.consolidation_currency THEN l_r := 1;
        ELSE
          l_r := CASE WHEN l_type IS NOT NULL THEN NOONA_REFERENCE_PKG.get_rate(l_cur, g.consolidation_currency, l_type,
                        CAST(TRUNC(p_to) + 1 - 1/86400 AS TIMESTAMP)) END;
          NOONA_CORE_PKG.assert(l_r IS NOT NULL, 'NOONA-CNS-003', 'لا يوجد سعر صرف من ' || l_cur || ' إلى ' || g.consolidation_currency
            || ' في ' || TO_CHAR(p_to, 'YYYY-MM-DD') || ' (أسعار الصرف في المالية)', 'Missing exchange rate');
        END IF;
        g_co(g_co.COUNT + 1) := c.id; g_cname(g_co.COUNT) := c.nm; g_rate(g_co.COUNT) := l_r;
      END IF;
    END LOOP;
    NOONA_CORE_PKG.assert(g_co.COUNT > 0, 'NOONA-CNS-007', 'لا توجد شركات مشمولة يمكنك عرضها في هذه المجموعة', 'No accessible companies');
  END load_members;

  FUNCTION members_text(p_group_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    load_members(grp(p_group_id), SYSDATE);
    FOR i IN 1 .. g_co.COUNT LOOP l := l || CASE WHEN i > 1 THEN '، ' END || g_cname(i); END LOOP;
    RETURN l || CASE WHEN g_skip IS NOT NULL THEN ' — غير مشمولة: ' || g_skip END;
  EXCEPTION WHEN OTHERS THEN RETURN SQLERRM;
  END members_text;

  FUNCTION fy_start(p_company NUMBER, p_date DATE) RETURN DATE IS
    l DATE;
  BEGIN
    SELECT MAX(start_date) INTO l FROM gl_fiscal_year WHERE company_id = p_company AND p_date BETWEEN start_date AND end_date;
    RETURN NVL(l, TRUNC(p_date, 'YYYY'));
  END fy_start;

  -- يجمع المبالغ (مدين - دائن بعملة التجميع) لكل حساب ولكل شركة
  --   TB/BS: أرصدة الميزانية حتى نهاية الفترة، وحسابات النتيجة من أول السنة المالية (TB) أو تراكمياً غير مقفل (BS)
  --   IS: حركة حسابات النتيجة خلال الفترة دون قيود الإقفال
  PROCEDURE collect(g gl_consolidation_group%ROWTYPE, p_kind VARCHAR2, p_from DATE, p_to DATE) IS
    l_elim VARCHAR2(4000) := ',' || elim_accounts(g.id) || ',';
    l_fy   DATE;
  BEGIN
    g_acc.DELETE; g_amt.DELETE;
    FOR i IN 1 .. g_co.COUNT LOOP
      l_fy := fy_start(g_co(i), p_to);
      FOR r IN (
        SELECT a.account_code code, MAX(a.name_ar) name, MAX(a.account_type) typ, MAX(a.subledger_code) sub,
               SUM(l.debit_func - l.credit_func) net
          FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
         WHERE j.ledger_id = NOONA_GL_PKG.primary_ledger(g_co(i)) AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_to
           AND CASE
                 WHEN p_kind = 'IS' THEN CASE WHEN a.account_type IN ('REVENUE', 'EXPENSE') AND j.doc_date >= p_from
                                               AND NVL(j.journal_category, '-') <> 'CLOSING' THEN 1 ELSE 0 END
                 WHEN p_kind = 'TB' THEN CASE WHEN a.account_type IN ('ASSET', 'LIABILITY', 'EQUITY') OR j.doc_date >= l_fy THEN 1 ELSE 0 END
                 ELSE 1 END = 1
           AND a.account_type <> 'STATISTICAL'
         GROUP BY a.account_code
        HAVING SUM(l.debit_func - l.credit_func) <> 0) LOOP
        IF NOT g_acc.EXISTS(r.code) THEN
          g_acc(r.code).code := r.code; g_acc(r.code).name := r.name; g_acc(r.code).typ := r.typ;
          g_acc(r.code).elim := NVL(r.sub, '-') = 'INTERCOMPANY' OR INSTR(l_elim, ',' || r.code || ',') > 0;
        ELSIF NVL(r.sub, '-') = 'INTERCOMPANY' THEN
          g_acc(r.code).elim := TRUE;
        END IF;
        g_amt(r.code || '|' || i) := ROUND(r.net * g_rate(i), 2);
      END LOOP;
      -- TB: نتيجة سنوات سابقة غير مقفلة تظهر كرصيد أرباح مبقاة ليتوازن الميزان
      IF p_kind = 'TB' THEN
        FOR r IN (SELECT SUM(l.debit_func - l.credit_func) net
                    FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
                   WHERE j.ledger_id = NOONA_GL_PKG.primary_ledger(g_co(i)) AND j.status_code IN ('POSTED', 'REVERSED')
                     AND j.doc_date < l_fy AND a.account_type IN ('REVENUE', 'EXPENSE')
                  HAVING SUM(l.debit_func - l.credit_func) <> 0) LOOP
          IF NOT g_acc.EXISTS('~PRIOR') THEN
            g_acc('~PRIOR').code := ''; g_acc('~PRIOR').name := 'نتيجة سنوات سابقة غير مقفلة'; g_acc('~PRIOR').typ := 'EQUITY'; g_acc('~PRIOR').elim := FALSE;
          END IF;
          g_amt('~PRIOR|' || i) := ROUND(r.net * g_rate(i), 2);
        END LOOP;
      END IF;
    END LOOP;
  END collect;

  FUNCTION amt(p_code VARCHAR2, i PLS_INTEGER) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN g_amt.EXISTS(p_code || '|' || i) THEN g_amt(p_code || '|' || i) ELSE 0 END;
  END amt;

  FUNCTION total(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER := 0;
  BEGIN
    FOR i IN 1 .. g_co.COUNT LOOP l := l + amt(p_code, i); END LOOP;
    RETURN l;
  END total;

  FUNCTION type_name(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p WHEN 'ASSET' THEN 'الأصول' WHEN 'LIABILITY' THEN 'الخصوم' WHEN 'EQUITY' THEN 'حقوق الملكية'
                  WHEN 'REVENUE' THEN 'الإيرادات' WHEN 'EXPENSE' THEN 'التكاليف والمصروفات' ELSE p END;
  END type_name;

  FUNCTION report(p_group_id IN NUMBER, p_kind IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_by_company IN VARCHAR2 DEFAULT 'Y') RETURN CLOB IS
    g      gl_consolidation_group%ROWTYPE := grp(p_group_id);
    l_kind VARCHAR2(2) := UPPER(NVL(p_kind, 'BS'));
    l_by   BOOLEAN := NVL(p_by_company, 'Y') = 'Y';
    l_html CLOB;
    l_k    VARCHAR2(50);
    l_cols PLS_INTEGER;
    l_sign NUMBER;
    l_v    NUMBER; l_e NUMBER; l_c NUMBER;
    t_co   t_num;  t_e NUMBER := 0; t_c NUMBER := 0;          -- إجماليات القسم
    s_co   t_num;  s_e NUMBER := 0; s_c NUMBER := 0;          -- إجماليات عامة
    e_pl   NUMBER := 0; e_bs NUMBER := 0;                      -- مجموع الاستبعاد في حسابات النتيجة والميزانية
    tdr    NUMBER := 0; tcr NUMBER := 0;
    TYPE t_sec IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    sec_c  t_sec;   -- الموحد لكل نوع
    sec_co t_amt;   -- لكل نوع|شركة
    l_title VARCHAR2(400);
    l_types SYS.ODCIVARCHAR2LIST;
    FUNCTION cells(p_vals t_num, p_e NUMBER, p_c NUMBER, p_class VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
      l VARCHAR2(4000);
    BEGIN
      IF l_by THEN
        FOR i IN 1 .. g_co.COUNT LOOP l := l || '<td>' || fmt(CASE WHEN p_vals.EXISTS(i) THEN p_vals(i) END) || '</td>'; END LOOP;
        l := l || '<td class="nn-cns-elim">' || fmt(p_e) || '</td>';
      END IF;
      RETURN l || '<td class="' || NVL(p_class, 'nn-cns-total') || '">' || fmt(p_c) || '</td>';
    END cells;
    PROCEDURE head_row IS
    BEGIN
      l_html := l_html || '<table class="nn-rpt nn-cns"><thead><tr><th>الحساب</th><th>اسم الحساب</th>';
      IF l_by THEN
        FOR i IN 1 .. g_co.COUNT LOOP l_html := l_html || '<th>' || esc(g_cname(i)) || '</th>'; END LOOP;
        l_html := l_html || '<th>الاستبعاد</th>';
      END IF;
      l_html := l_html || '<th>الموحد</th></tr></thead><tbody>';
    END head_row;
    PROCEDURE section(p_type VARCHAR2) IS
      l_any BOOLEAN := FALSE;
    BEGIN
      t_co.DELETE; t_e := 0; t_c := 0;
      FOR i IN 1 .. g_co.COUNT LOOP t_co(i) := 0; END LOOP;
      l_sign := CASE WHEN p_type IN ('ASSET', 'EXPENSE') OR l_kind = 'TB' THEN 1 ELSE -1 END;
      l_k := g_acc.FIRST;
      WHILE l_k IS NOT NULL LOOP
        IF g_acc(l_k).typ = p_type THEN
          IF NOT l_any THEN
            l_html := l_html || '<tr class="nn-rpt-group"><td colspan="' || l_cols || '">' || type_name(p_type) || '</td></tr>';
            l_any := TRUE;
          END IF;
          DECLARE v t_num; BEGIN
            l_v := total(l_k);
            l_e := CASE WHEN g_acc(l_k).elim THEN -l_v ELSE 0 END;
            l_c := l_v + l_e;
            FOR i IN 1 .. g_co.COUNT LOOP v(i) := amt(l_k, i) * l_sign; t_co(i) := t_co(i) + v(i); END LOOP;
            t_e := t_e + l_e * l_sign; t_c := t_c + l_c * l_sign;
            IF g_acc(l_k).elim THEN
              IF p_type IN ('REVENUE', 'EXPENSE') THEN e_pl := e_pl + l_e; ELSE e_bs := e_bs + l_e; END IF;
            END IF;
            IF l_kind = 'TB' THEN tdr := tdr + GREATEST(l_c, 0); tcr := tcr + GREATEST(-l_c, 0); END IF;
            l_html := l_html || '<tr' || CASE WHEN g_acc(l_k).elim THEN ' class="nn-cns-ic" title="حساب بين الشركات: يستبعد في الموحد"' END
                   || '><td class="nn-num-code">' || esc(g_acc(l_k).code) || '</td><td>' || esc(g_acc(l_k).name)
                   || CASE WHEN g_acc(l_k).elim THEN ' <small class="nn-cns-tag">بين الشركات</small>' END || '</td>'
                   || cells(v, l_e * l_sign, l_c * l_sign) || '</tr>';
          END;
        END IF;
        l_k := g_acc.NEXT(l_k);
      END LOOP;
      sec_c(p_type) := t_c;
      FOR i IN 1 .. g_co.COUNT LOOP sec_co(p_type || '|' || i) := t_co(i); END LOOP;
      IF l_any AND l_kind <> 'TB' THEN
        l_html := l_html || '<tr class="nn-rpt-total"><td></td><td>إجمالي ' || type_name(p_type) || '</td>' || cells(t_co, t_e, t_c) || '</tr>';
      END IF;
    END section;
    FUNCTION sco(p_type VARCHAR2, i PLS_INTEGER) RETURN NUMBER IS
    BEGIN RETURN CASE WHEN sec_co.EXISTS(p_type || '|' || i) THEN sec_co(p_type || '|' || i) ELSE 0 END; END sco;
    FUNCTION sc(p_type VARCHAR2) RETURN NUMBER IS BEGIN RETURN CASE WHEN sec_c.EXISTS(p_type) THEN sec_c(p_type) ELSE 0 END; END sc;
    PROCEDURE check_box(p_ok BOOLEAN, p_ok_text VARCHAR2, p_bad_text VARCHAR2) IS
    BEGIN
      l_html := l_html || '<div class="nn-chain ' || CASE WHEN p_ok THEN 'is-ok' ELSE 'is-bad' END || ' nn-rpt-check"><span class="fa '
             || CASE WHEN p_ok THEN 'fa-check-circle' ELSE 'fa-exclamation-triangle' END || '" aria-hidden="true"></span><div><b>'
             || CASE WHEN p_ok THEN p_ok_text ELSE p_bad_text END || '</b></div></div>';
    END check_box;
  BEGIN
    NOONA_CORE_PKG.assert(l_kind IN ('TB', 'IS', 'BS'), 'NOONA-CNS-008', 'نوع التقرير غير صالح', 'Invalid report type');
    NOONA_CORE_PKG.assert(p_to IS NOT NULL AND (l_kind = 'BS' OR p_from <= p_to), 'NOONA-CNS-009', 'حدد الفترة', 'Invalid period');
    load_members(g, p_to);
    collect(g, l_kind, p_from, p_to);
    l_cols := 3 + CASE WHEN l_by THEN g_co.COUNT + 1 ELSE 0 END;
    l_title := CASE l_kind WHEN 'TB' THEN 'ميزان المراجعة الموحد في ' || TO_CHAR(p_to, 'YYYY-MM-DD')
                           WHEN 'IS' THEN 'قائمة الدخل الموحدة من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD')
                           ELSE 'قائمة المركز المالي الموحدة في ' || TO_CHAR(p_to, 'YYYY-MM-DD') END
               || ' - ' || g.name_ar;
    -- الترويسة باسم الشركة القابضة (أول شركة مشمولة) لا الشركة الحالية للمستخدم
    l_html := NOONA_BRAND_PKG.report_header(l_title, g_co(1))
           || '<div class="nn-cns-info"><span><b>الشركات:</b> ';
    FOR i IN 1 .. g_co.COUNT LOOP
      l_html := l_html || CASE WHEN i > 1 THEN '، ' END || esc(g_cname(i)) || CASE WHEN g_rate(i) <> 1 THEN ' <small>(سعر ' || g_rate(i) || ')</small>' END;
    END LOOP;
    l_html := l_html || '</span><span><b>العملة:</b> ' || esc(g.consolidation_currency) || '</span>'
           || CASE WHEN g_skip IS NOT NULL THEN '<span class="nn-cns-skip"><b>غير مشمولة:</b> ' || esc(g_skip) || '</span>' END || '</div>';
    head_row;
    IF l_kind = 'IS' THEN
      l_types := SYS.ODCIVARCHAR2LIST('REVENUE', 'EXPENSE');
    ELSE
      l_types := SYS.ODCIVARCHAR2LIST('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE');
    END IF;
    IF l_kind = 'BS' THEN l_types := SYS.ODCIVARCHAR2LIST('ASSET', 'LIABILITY', 'EQUITY'); END IF;
    FOR t IN 1 .. l_types.COUNT LOOP section(l_types(t)); END LOOP;

    IF l_kind = 'TB' THEN
      l_html := l_html || '</tbody><tfoot><tr><td colspan="' || (l_cols - 1) || '">الموحد: مدين ' || fmt(tdr) || ' · دائن ' || fmt(tcr)
             || '</td><td>' || fmt(tdr - tcr) || '</td></tr></tfoot></table>';
      check_box(ROUND(tdr - tcr, 2) = 0, 'الميزان الموحد متوازن', 'الميزان الموحد غير متوازن: الفرق ' || fmt(tdr - tcr));
    ELSIF l_kind = 'IS' THEN
      DECLARE v t_num; BEGIN
        FOR i IN 1 .. g_co.COUNT LOOP v(i) := sco('REVENUE', i) - sco('EXPENSE', i); END LOOP;
        l_html := l_html || '<tr class="nn-rpt-total nn-cns-net"><td></td><td>صافي الربح (الخسارة)</td>'
               || cells(v, NULL, sc('REVENUE') - sc('EXPENSE')) || '</tr></tbody></table>';
      END;
    ELSE
      -- المركز المالي: رصيد حسابات النتيجة المتبقي حتى التاريخ (بعد قيود الإقفال) = نتيجة غير مقفلة، ضمن حقوق الملكية
      DECLARE
        v t_num; pl t_num; l_pl NUMBER := 0; l_diff NUMBER; l_none t_num;
      BEGIN
        FOR i IN 1 .. g_co.COUNT LOOP pl(i) := 0; END LOOP;
        l_k := g_acc.FIRST;
        WHILE l_k IS NOT NULL LOOP
          IF g_acc(l_k).typ IN ('REVENUE', 'EXPENSE') THEN
            FOR i IN 1 .. g_co.COUNT LOOP pl(i) := pl(i) - amt(l_k, i); END LOOP;
            IF NOT g_acc(l_k).elim THEN l_pl := l_pl - total(l_k); END IF;
          END IF;
          l_k := g_acc.NEXT(l_k);
        END LOOP;
        l_html := l_html || '<tr><td></td><td>الأرباح المبقاة ونتيجة الفترة غير المقفلة</td>' || cells(pl, NULL, l_pl, 'nn-cns-total') || '</tr>';
        FOR i IN 1 .. g_co.COUNT LOOP v(i) := sco('LIABILITY', i) + sco('EQUITY', i) + pl(i); END LOOP;
        l_diff := sc('ASSET') - (sc('LIABILITY') + sc('EQUITY') + l_pl);
        IF ROUND(l_diff, 2) <> 0 THEN
          l_html := l_html || '<tr class="nn-cns-ic"><td></td><td>فرق مطابقة المعاملات بين الشركات</td>' || cells(l_none, NULL, l_diff) || '</tr>';
        END IF;
        l_html := l_html || '<tr class="nn-rpt-total"><td></td><td>إجمالي الخصوم وحقوق الملكية</td>'
               || cells(v, NULL, sc('LIABILITY') + sc('EQUITY') + l_pl + l_diff) || '</tr></tbody></table>';
        check_box(ROUND(l_diff, 2) = 0, 'المركز المالي الموحد متوازن، والأرصدة بين الشركات متطابقة',
                  'الأرصدة بين الشركات غير متطابقة بفرق ' || fmt(l_diff) || ': راجع حسابات الجاري بين الشركات قبل الاعتماد');
      END;
    END IF;
    IF l_kind IN ('IS', 'TB') AND ROUND(e_pl, 2) <> 0 THEN
      check_box(FALSE, NULL, 'الإيرادات والمصروفات بين الشركات غير متطابقة بفرق ' || fmt(e_pl) || ' (أثر على الربح الموحد)');
    END IF;
    RETURN l_html || '<p class="nn-cns-note">التجميع لا يغير دفاتر الشركات. الحسابات المعلّمة «بين الشركات» تستبعد بالكامل، '
        || 'والمبالغ محولة لعملة التجميع بسعر الإقفال. الأرقام بين قوسين دائنة/سالبة.</p>' || NOONA_GL_PKG.report_footer;
  END report;

  FUNCTION approve(p_group_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    g     gl_consolidation_group%ROWTYPE := grp(p_group_id);
    l_id  NUMBER;
    l_per VARCHAR2(20) := TO_CHAR(p_to, 'YYYY-MM');
    l_doc CLOB;
    l_type NUMBER;
    l_cnt  NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('GL_CONSOLIDATION_RUN.APPROVE');
    l_doc := report(p_group_id, 'BS', p_from, p_to, 'Y');
    l_cnt := g_co.COUNT;
    NOONA_CORE_PKG.assert(INSTR(l_doc, 'is-bad') = 0, 'NOONA-CNS-010',
      'لا يعتمد التجميع والمركز الموحد غير متوازن أو الأرصدة بين الشركات غير متطابقة', 'Consolidation does not balance');
    SELECT MIN(id) INTO l_type FROM ref_rate_type WHERE code = 'ACCOUNTING';
    MERGE INTO gl_consolidation_run t USING (SELECT p_group_id gid, l_per per FROM dual) s
       ON (t.group_id = s.gid AND t.period_code = s.per)
    WHEN MATCHED THEN UPDATE SET t.status_code = 'APPROVED', t.result_data = JSON_OBJECT('from' VALUE TO_CHAR(p_from, 'YYYY-MM-DD'),
         'to' VALUE TO_CHAR(p_to, 'YYYY-MM-DD'), 'companies' VALUE l_cnt, 'approvedBy' VALUE SYS_CONTEXT('NOONA_CTX', 'USERNAME'))
    WHEN NOT MATCHED THEN INSERT (group_id, period_code, closing_rate_type_id, average_rate_type_id, result_data, status_code)
      VALUES (p_group_id, l_per, l_type, l_type, JSON_OBJECT('from' VALUE TO_CHAR(p_from, 'YYYY-MM-DD'), 'to' VALUE TO_CHAR(p_to, 'YYYY-MM-DD'),
              'companies' VALUE l_cnt, 'approvedBy' VALUE SYS_CONTEXT('NOONA_CTX', 'USERNAME')), 'APPROVED');
    SELECT id INTO l_id FROM gl_consolidation_run WHERE group_id = p_group_id AND period_code = l_per;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'GL_CONSOLIDATION_RUN', l_id, 'APPROVE', 'SUCCESS');
    RETURN l_id;
  END approve;

END NOONA_CONSOL_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_CONSOL_PKG
