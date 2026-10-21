-- =============================================================================
-- NOONA PLUS ERP | NOONA_GL_PKG - الأستاذ العام (المرحلة الأولى من تطبيق المالية)
--   * تجهيز بخطوة واحدة: دليل حسابات عربي قياسي + الدفتر الرئيسي + حالة الفترات
--   * القيود اليومية: مسودة -> إرسال -> اعتماد وترحيل (المعتمد غير المنشئ) -> عكس بقيد مقابل
--   * الرقم الرسمي للقيد يصدر عند الترحيل (تسلسل بلا فجوات GL_JOURNAL)
--   * الترحيل يحدث أرصدة GL_BALANCE؛ التقارير من القيود المرحلة مباشرة
-- كل العمليات على الشركة الحالية في الجلسة؛ صلاحيات GL_* وتدقيق.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_GL_PKG AUTHID DEFINER AS

  -- ---------------------------------------------------------- التجهيز
  -- دليل حسابات قياسي ودفتر رئيسي بعملة الشركة وفترات السنة المفتوحة مفتوحة؛ يعيد رقم الدفتر (Idempotent)
  FUNCTION quick_setup(p_company_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION add_account(p_coa_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_parent_code IN VARCHAR2,
                       p_type IN VARCHAR2 DEFAULT NULL, p_postable IN VARCHAR2 DEFAULT 'Y',
                       p_subledger IN VARCHAR2 DEFAULT NULL, p_normal IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE set_account_status(p_account_id IN NUMBER, p_status IN VARCHAR2);
  -- حالة الفترة في الدفتر: OPEN / SOFT_CLOSED / HARD_CLOSED
  PROCEDURE set_period_status(p_period_id IN NUMBER, p_status IN VARCHAR2);
  FUNCTION primary_ledger(p_company_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- مساعدات تستخدم داخل SQL: الشركة الحالية، فترة التاريخ المفتوحة، بداية السنة المالية
  FUNCTION company RETURN NUMBER;
  FUNCTION primary_coa RETURN NUMBER;
  FUNCTION period_for(p_date DATE) RETURN NUMBER;
  FUNCTION fy_start(p_date DATE) RETURN DATE;

  -- ---------------------------------------------------------- مراكز التكلفة
  FUNCTION create_cost_center(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_type IN VARCHAR2 DEFAULT 'COST',
                              p_parent_code IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE set_cost_center_status(p_cost_center_id IN NUMBER, p_status IN VARCHAR2);
  -- قاعدة مركز التكلفة لحساب: REQUIRED (إلزامي) / OPTIONAL / FORBIDDEN (ممنوع)
  PROCEDURE set_cc_rule(p_account_id IN NUMBER, p_rule IN VARCHAR2);
  FUNCTION cc_rule(p_account_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- للمحرك المحاسبي فقط (NOONA_ACE_PKG)
  TYPE t_line IS RECORD (account_id NUMBER, debit NUMBER, credit NUMBER, cost_center_id NUMBER, description VARCHAR2(1000));
  TYPE t_lines IS TABLE OF t_line;
  -- قيد نظامي من مستند مصدر معتمد: يتحقق من كل القواعد ويرحل مباشرة (يقبل حسابات المراقبة)
  FUNCTION post_system(p_source_code IN VARCHAR2, p_doc_date IN DATE, p_description IN VARCHAR2, p_currency IN VARCHAR2,
                       p_rate IN NUMBER, p_lines IN t_lines, p_reference IN VARCHAR2, p_event_id IN NUMBER,
                       p_branch_id IN NUMBER DEFAULT NULL) RETURN NUMBER ACCESSIBLE BY (PACKAGE NOONA_ACE_PKG);
  FUNCTION reverse_system(p_journal_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER
    ACCESSIBLE BY (PACKAGE NOONA_ACE_PKG);

  -- ---------------------------------------------------------- القيود
  FUNCTION create_journal(p_doc_date IN DATE, p_description IN VARCHAR2, p_currency IN VARCHAR2 DEFAULT NULL,
                          p_exchange_rate IN NUMBER DEFAULT NULL, p_reference IN VARCHAR2 DEFAULT NULL,
                          p_source_code IN VARCHAR2 DEFAULT 'MANUAL') RETURN NUMBER;
  PROCEDURE update_header(p_journal_id IN NUMBER, p_doc_date IN DATE, p_description IN VARCHAR2,
                          p_reference IN VARCHAR2 DEFAULT NULL);
  -- استبدال سطور المسودة من JSON: [{"a":"1101","d":100,"c":0,"cc":12,"t":"وصف"}, ...]
  PROCEDURE save_lines(p_journal_id IN NUMBER, p_lines IN CLOB);
  PROCEDURE submit_journal(p_journal_id IN NUMBER);
  PROCEDURE approve_journal(p_journal_id IN NUMBER, p_comment IN VARCHAR2 DEFAULT NULL);
  PROCEDURE reject_journal(p_journal_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE cancel_journal(p_journal_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION reverse_journal(p_journal_id IN NUMBER, p_reversal_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- الواجهة والتقارير (HTML)
  FUNCTION lines_json(p_journal_id IN NUMBER) RETURN CLOB;
  FUNCTION accounts_json RETURN CLOB;
  FUNCTION gl_summary(p_session IN VARCHAR2) RETURN CLOB;
  FUNCTION journal_header(p_journal_id IN NUMBER) RETURN CLOB;
  FUNCTION cost_centers_json RETURN CLOB;
  FUNCTION trial_balance(p_from IN DATE, p_to IN DATE, p_show_zero IN VARCHAR2 DEFAULT 'N',
                         p_cost_center_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION account_statement(p_account_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_cost_center_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- قائمة الدخل (اختيارياً لمركز تكلفة) والميزانية العمومية
  FUNCTION income_statement(p_from IN DATE, p_to IN DATE, p_cost_center_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION balance_sheet(p_as_of IN DATE) RETURN CLOB;
  -- تحليل الإيرادات أو المصروفات: p_type REVENUE/EXPENSE، p_by MONTH (شهري) / CC (مراكز التكلفة)
  FUNCTION analysis(p_from IN DATE, p_to IN DATE, p_type IN VARCHAR2, p_by IN VARCHAR2) RETURN CLOB;
END NOONA_GL_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_GL_PKG AS

  TYPE t_acc IS RECORD (code VARCHAR2(20), parent VARCHAR2(20), name VARCHAR2(200), typ VARCHAR2(20),
                        postable CHAR(1), sub VARCHAR2(20), normal VARCHAR2(10));
  TYPE t_accs IS TABLE OF t_acc;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;

  FUNCTION company RETURN NUMBER IS
  BEGIN
    RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  END company;

  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL OR p = 0 THEN '' ELSE TRIM(TO_CHAR(p, 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,''')) END;
  END fmt;

  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt0;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION get_journal(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN gl_journal%ROWTYPE IS
    l_j gl_journal%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l_j FROM gl_journal WHERE id = p_id FOR UPDATE;
    ELSE
      SELECT * INTO l_j FROM gl_journal WHERE id = p_id;
    END IF;
    RETURN l_j;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-GL-001', 'القيد غير موجود', 'Journal not found');
  END get_journal;

  -- ================================================================ التجهيز
  FUNCTION primary_ledger(p_company_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY CASE ledger_type WHEN 'PRIMARY' THEN 0 ELSE 1 END, id) INTO l_id
      FROM gl_ledger WHERE company_id = NVL(p_company_id, company) AND status_code IN ('DRAFT', 'ACTIVE');
    RETURN l_id;
  END primary_ledger;

  FUNCTION primary_coa RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT MAX(coa_id) INTO l_id FROM gl_ledger WHERE id = primary_ledger;
    RETURN l_id;
  END primary_coa;

  FUNCTION standard_chart RETURN t_accs IS
    l t_accs := t_accs();
    PROCEDURE a(c VARCHAR2, p VARCHAR2, n VARCHAR2, t VARCHAR2, post CHAR DEFAULT 'Y', s VARCHAR2 DEFAULT NULL,
                nb VARCHAR2 DEFAULT NULL) IS
    BEGIN
      l.EXTEND; l(l.COUNT).code := c; l(l.COUNT).parent := p; l(l.COUNT).name := n; l(l.COUNT).typ := t;
      l(l.COUNT).postable := post; l(l.COUNT).sub := s; l(l.COUNT).normal := nb;
    END;
  BEGIN
    a('1', NULL, 'الأصول', 'ASSET', 'N');
    a('11', '1', 'الأصول المتداولة', 'ASSET', 'N');
    a('1101', '11', 'النقدية في الصندوق', 'ASSET', 'Y', 'CASH');
    a('1102', '11', 'النقدية لدى البنوك', 'ASSET', 'Y', 'CASH');
    a('1103', '11', 'العملاء', 'ASSET', 'Y', 'AR');
    a('1104', '11', 'أوراق القبض', 'ASSET');
    a('1105', '11', 'المخزون', 'ASSET', 'Y', 'INV');
    a('1106', '11', 'مصروفات مدفوعة مقدماً', 'ASSET');
    a('1107', '11', 'ضريبة القيمة المضافة - مدخلات', 'ASSET', 'Y', 'TAX');
    a('1108', '11', 'سلف وعهد الموظفين', 'ASSET');
    a('12', '1', 'الأصول غير المتداولة', 'ASSET', 'N');
    a('1201', '12', 'الأراضي', 'ASSET', 'Y', 'FA');
    a('1202', '12', 'المباني', 'ASSET', 'Y', 'FA');
    a('1203', '12', 'الآلات والمعدات', 'ASSET', 'Y', 'FA');
    a('1204', '12', 'الأثاث والتجهيزات', 'ASSET', 'Y', 'FA');
    a('1205', '12', 'السيارات', 'ASSET', 'Y', 'FA');
    a('1206', '12', 'أجهزة الحاسب', 'ASSET', 'Y', 'FA');
    a('1209', '12', 'مجمع الإهلاك', 'ASSET', 'Y', 'FA', 'CREDIT');
    a('2', NULL, 'الخصوم', 'LIABILITY', 'N');
    a('21', '2', 'الخصوم المتداولة', 'LIABILITY', 'N');
    a('2101', '21', 'الموردون', 'LIABILITY', 'Y', 'AP');
    a('2102', '21', 'أوراق الدفع', 'LIABILITY');
    a('2103', '21', 'مصروفات مستحقة', 'LIABILITY');
    a('2104', '21', 'ضريبة القيمة المضافة - مخرجات', 'LIABILITY', 'Y', 'TAX');
    a('2105', '21', 'الزكاة المستحقة', 'LIABILITY');
    a('2106', '21', 'رواتب مستحقة', 'LIABILITY', 'Y', 'PAYROLL');
    a('2107', '21', 'إيرادات مقدمة', 'LIABILITY');
    a('22', '2', 'الخصوم غير المتداولة', 'LIABILITY', 'N');
    a('2201', '22', 'قروض طويلة الأجل', 'LIABILITY');
    a('2202', '22', 'مخصص مكافأة نهاية الخدمة', 'LIABILITY');
    a('3', NULL, 'حقوق الملكية', 'EQUITY', 'N');
    a('3101', '3', 'رأس المال', 'EQUITY');
    a('3102', '3', 'الاحتياطي النظامي', 'EQUITY');
    a('3103', '3', 'الأرباح المبقاة', 'EQUITY');
    a('3104', '3', 'جاري الشركاء', 'EQUITY');
    a('4', NULL, 'الإيرادات', 'REVENUE', 'N');
    a('4101', '4', 'إيرادات المبيعات', 'REVENUE');
    a('4102', '4', 'مردودات ومسموحات المبيعات', 'REVENUE', 'Y', NULL, 'DEBIT');
    a('4103', '4', 'خصم مسموح به', 'REVENUE', 'Y', NULL, 'DEBIT');
    a('4201', '4', 'إيرادات أخرى', 'REVENUE');
    a('4202', '4', 'أرباح فروق العملة', 'REVENUE');
    a('5', NULL, 'التكاليف والمصروفات', 'EXPENSE', 'N');
    a('51', '5', 'تكلفة المبيعات', 'EXPENSE', 'N');
    a('5101', '51', 'تكلفة البضاعة المباعة', 'EXPENSE');
    a('52', '5', 'المصروفات التشغيلية والإدارية', 'EXPENSE', 'N');
    a('5201', '52', 'الرواتب والأجور', 'EXPENSE');
    a('5202', '52', 'الإيجارات', 'EXPENSE');
    a('5203', '52', 'الكهرباء والمياه', 'EXPENSE');
    a('5204', '52', 'الاتصالات والإنترنت', 'EXPENSE');
    a('5205', '52', 'الصيانة والإصلاح', 'EXPENSE');
    a('5206', '52', 'مصروف الإهلاك', 'EXPENSE');
    a('5207', '52', 'القرطاسية والمطبوعات', 'EXPENSE');
    a('5208', '52', 'الدعاية والإعلان', 'EXPENSE');
    a('5209', '52', 'رسوم حكومية', 'EXPENSE');
    a('5210', '52', 'مصروفات بنكية', 'EXPENSE');
    a('5211', '52', 'خسائر فروق العملة', 'EXPENSE');
    a('5212', '52', 'الزكاة', 'EXPENSE');
    a('5299', '52', 'مصروفات متنوعة وفروق تقريب', 'EXPENSE');
    RETURN l;
  END standard_chart;

  FUNCTION add_account(p_coa_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_parent_code IN VARCHAR2,
                       p_type IN VARCHAR2 DEFAULT NULL, p_postable IN VARCHAR2 DEFAULT 'Y',
                       p_subledger IN VARCHAR2 DEFAULT NULL, p_normal IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_parent gl_account%ROWTYPE;
    l_type   VARCHAR2(20) := p_type;
    l_level  NUMBER := 1;
    l_id     NUMBER;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_ACCOUNT.CREATE');
    NOONA_CORE_PKG.assert(REGEXP_LIKE(p_code, '^[0-9A-Z][0-9A-Z.-]{0,19}$'), 'NOONA-GL-010',
      'رمز الحساب أرقام أو حروف إنجليزية', 'Invalid account code');
    IF p_parent_code IS NOT NULL THEN
      BEGIN
        SELECT * INTO l_parent FROM gl_account WHERE coa_id = p_coa_id AND account_code = p_parent_code;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-GL-011', 'الحساب الأب غير موجود: ' || p_parent_code, 'Parent account not found');
      END;
      NOONA_CORE_PKG.assert(l_parent.is_postable = 'N', 'NOONA-GL-012',
        'الحساب الأب حساب حركة؛ اختر حساباً رئيسياً (تجميعي)', 'Parent must be a summary account');
      l_type := NVL(l_type, l_parent.account_type);
      NOONA_CORE_PKG.assert(l_type = l_parent.account_type, 'NOONA-GL-013',
        'نوع الحساب يجب أن يطابق نوع الحساب الأب', 'Account type must match its parent');
      l_level := l_parent.account_level + 1;
    END IF;
    NOONA_CORE_PKG.assert(l_type IN ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE', 'STATISTICAL'), 'NOONA-GL-014',
      'حدد نوع الحساب الرئيسي', 'Account type is required');
    INSERT INTO gl_account (coa_id, account_code, name_ar, parent_account_id, account_level, account_type, normal_balance,
                            is_postable, is_control, subledger_code, allow_manual_posting, revalue_fx, cash_flow_category,
                            status_code, effective_from)
    VALUES (p_coa_id, p_code, p_name_ar, l_parent.id, l_level, l_type,
            NVL(p_normal, CASE WHEN l_type IN ('ASSET', 'EXPENSE') THEN 'DEBIT' ELSE 'CREDIT' END),
            NVL(p_postable, 'Y'), CASE WHEN p_subledger IN ('AR', 'AP', 'INV', 'FA') THEN 'Y' ELSE 'N' END, p_subledger,
            -- حسابات المراقبة (العملاء، الموردون، المخزون، الأصول) لا يرحل إليها يدوياً بل من أنظمتها الفرعية
            CASE WHEN p_subledger IN ('AR', 'AP', 'INV', 'FA') THEN 'N' ELSE 'Y' END, 'N',
            CASE WHEN p_subledger = 'CASH' THEN 'CASH' WHEN l_type IN ('REVENUE', 'EXPENSE') THEN 'OPERATING' ELSE 'NONE' END,
            'ACTIVE', DATE '2000-01-01')
    RETURNING id INTO l_id;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-GL-015', 'رمز الحساب مستخدم في الدليل: ' || p_code, 'Account code already exists');
  END add_account;

  PROCEDURE set_account_status(p_account_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('GL_ACCOUNT.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'BLOCKED', 'RETIRED'), 'NOONA-GL-016', 'حالة غير صالحة', 'Invalid status');
    UPDATE gl_account SET status_code = p_status WHERE id = p_account_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'GL_ACCOUNT', p_account_id, 'STATUS_' || p_status, 'SUCCESS');
  END set_account_status;

  FUNCTION quick_setup(p_company_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_co     org_company%ROWTYPE;
    l_coa    NUMBER;
    l_ledger NUMBER := primary_ledger(p_company_id);
    l_cal    NUMBER;
    l_id     NUMBER;
    l_chart  t_accs := standard_chart;
    l_re NUMBER; l_rnd NUMBER; l_gain NUMBER; l_loss NUMBER;
    FUNCTION acc(p_code VARCHAR2) RETURN NUMBER IS
      l NUMBER;
    BEGIN
      SELECT id INTO l FROM gl_account WHERE coa_id = l_coa AND account_code = p_code;
      RETURN l;
    END acc;
  BEGIN
    guard('GL_LEDGER.CREATE');
    SELECT * INTO l_co FROM org_company WHERE id = NVL(p_company_id, company);
    IF l_ledger IS NULL THEN
      SELECT MIN(id) INTO l_coa FROM gl_chart_of_accounts WHERE company_id = l_co.id AND status_code IN ('DRAFT', 'ACTIVE');
      IF l_coa IS NULL THEN
        INSERT INTO gl_chart_of_accounts (code, name_ar, name_en, owner_level, company_id, is_template, segment_separator, status_code)
        VALUES ('COA-' || l_co.code, 'دليل حسابات ' || NVL(l_co.trade_name_ar, l_co.legal_name_ar), 'Chart of accounts',
                'COMPANY', l_co.id, 'N', '.', 'ACTIVE')
        RETURNING id INTO l_coa;
        FOR i IN 1 .. l_chart.COUNT LOOP
          l_id := add_account(l_coa, l_chart(i).code, l_chart(i).name, l_chart(i).parent, l_chart(i).typ,
                              l_chart(i).postable, l_chart(i).sub, l_chart(i).normal);
        END LOOP;
      END IF;
      SELECT MIN(id) INTO l_cal FROM gl_fiscal_calendar WHERE company_id = l_co.id AND is_active = 'Y';
      NOONA_CORE_PKG.assert(l_cal IS NOT NULL, 'NOONA-GL-020',
        'لا يوجد تقويم مالي للشركة؛ أنشئ السنة المالية أولاً', 'No fiscal calendar for the company');
      l_re := acc('3103'); l_rnd := acc('5299'); l_gain := acc('4202'); l_loss := acc('5211');
      INSERT INTO gl_ledger (company_id, code, name_ar, name_en, ledger_type, coa_id, calendar_id, currency_code,
                             retained_earnings_account_id, rounding_account_id, suspense_account_id,
                             fx_gain_account_id, fx_loss_account_id, status_code)
      VALUES (l_co.id, 'PRIMARY', 'الدفتر الرئيسي', 'Primary ledger', 'PRIMARY', l_coa, l_cal, l_co.functional_currency,
              l_re, l_rnd, l_rnd, l_gain, l_loss, 'ACTIVE')
      RETURNING id INTO l_ledger;
      NOONA_AUDIT_PKG.log_event('CONFIG', 'GL_LEDGER', l_ledger, 'QUICK_SETUP', 'SUCCESS');
    END IF;
    -- تسلسل أرقام القيود (بلا فجوات) إن لم يوجد للسنة الحالية
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT l_co.id, 'GL_JOURNAL', EXTRACT(YEAR FROM SYSDATE), 'JV-', 1, 6, 'Y', 'YEARLY', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = l_co.id AND doc_type_code = 'GL_JOURNAL'
                         AND (fiscal_year = EXTRACT(YEAR FROM SYSDATE) OR fiscal_year IS NULL));
    -- فترات السنوات المفتوحة: مفتوحة للأستاذ العام
    INSERT INTO gl_period_status (company_id, period_id, ledger_id, module_code, status_code)
    SELECT l_co.id, p.id, l_ledger, 'GL', 'OPEN'
      FROM gl_period p JOIN gl_fiscal_year y ON y.id = p.fiscal_year_id
     WHERE y.company_id = l_co.id AND y.status_code = 'OPEN'
       AND NOT EXISTS (SELECT 1 FROM gl_period_status s WHERE s.period_id = p.id AND s.ledger_id = l_ledger AND s.module_code = 'GL');
    RETURN l_ledger;
  END quick_setup;

  PROCEDURE set_period_status(p_period_id IN NUMBER, p_status IN VARCHAR2) IS
    l_ledger NUMBER := primary_ledger;
    l_cur    VARCHAR2(30);
  BEGIN
    guard('GL_PERIOD_STATUS.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('OPEN', 'SOFT_CLOSED', 'HARD_CLOSED'), 'NOONA-GL-030', 'حالة غير صالحة', 'Invalid status');
    SELECT status_code INTO l_cur FROM gl_period_status WHERE period_id = p_period_id AND ledger_id = l_ledger AND module_code = 'GL';
    NOONA_CORE_PKG.assert(l_cur <> 'PERMANENTLY_CLOSED' AND NOT (l_cur = 'HARD_CLOSED' AND p_status = 'OPEN'
                          AND NOONA_APEX_PKG.is_tenant_admin <> 'Y'), 'NOONA-GL-031',
      'إعادة فتح فترة مقفلة نهائياً تتطلب مسؤول المؤسسة', 'Reopening a hard-closed period requires a tenant admin');
    UPDATE gl_period_status
       SET status_code = p_status,
           closed_by = CASE WHEN p_status <> 'OPEN' THEN NOONA_CTX_PKG.current_user_name END,
           closed_at = CASE WHEN p_status <> 'OPEN' THEN SYSTIMESTAMP END
     WHERE period_id = p_period_id AND ledger_id = l_ledger AND module_code = 'GL';
    NOONA_AUDIT_PKG.log_event('POSTING', 'GL_PERIOD', p_period_id, 'PERIOD_' || p_status, 'SUCCESS');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-GL-032', 'الفترة غير مهيأة في الدفتر؛ نفذ التجهيز', 'Period not set up in the ledger');
  END set_period_status;

  -- ================================================================ القيود
  FUNCTION period_for(p_date DATE) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT MIN(p.id) INTO l_id
      FROM gl_period p JOIN gl_fiscal_year y ON y.id = p.fiscal_year_id
     WHERE p.company_id = company AND p.period_type = 'NORMAL' AND TRUNC(p_date) BETWEEN p.start_date AND p.end_date
       AND y.status_code = 'OPEN';
    NOONA_CORE_PKG.assert(l_id IS NOT NULL, 'NOONA-GL-040',
      'لا توجد فترة مالية مفتوحة لتاريخ ' || TO_CHAR(p_date, 'YYYY-MM-DD'), 'No open fiscal period for this date');
    RETURN l_id;
  END period_for;

  PROCEDURE assert_period_open(p_period_id NUMBER, p_ledger_id NUMBER) IS
    l_st VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l_st FROM gl_period_status
     WHERE period_id = p_period_id AND ledger_id = p_ledger_id AND module_code = 'GL';
    NOONA_CORE_PKG.assert(l_st = 'OPEN', 'NOONA-GL-041', 'الفترة المحاسبية مقفلة (' || NVL(l_st, 'غير مهيأة') || ')',
                          'The accounting period is closed');
  END assert_period_open;

  FUNCTION create_journal(p_doc_date IN DATE, p_description IN VARCHAR2, p_currency IN VARCHAR2 DEFAULT NULL,
                          p_exchange_rate IN NUMBER DEFAULT NULL, p_reference IN VARCHAR2 DEFAULT NULL,
                          p_source_code IN VARCHAR2 DEFAULT 'MANUAL') RETURN NUMBER IS
    l_ledger gl_ledger%ROWTYPE;
    l_src    gl_journal_source%ROWTYPE;
    l_cur    VARCHAR2(3);
    l_id     NUMBER;
  BEGIN
    guard('GL_JOURNAL.CREATE');
    BEGIN
      SELECT * INTO l_ledger FROM gl_ledger WHERE id = primary_ledger;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-GL-042', 'الأستاذ العام غير مجهز لهذه الشركة؛ نفذ التجهيز أولاً', 'Ledger not set up');
    END;
    SELECT * INTO l_src FROM gl_journal_source WHERE code = p_source_code AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l_src.allow_manual = 'Y', 'NOONA-GL-043', 'هذا المصدر لا يقبل قيوداً يدوية', 'Source does not allow manual journals');
    NOONA_CORE_PKG.assert(p_description IS NOT NULL, 'NOONA-GL-044', 'البيان إلزامي', 'Description is required');
    l_cur := NVL(p_currency, l_ledger.currency_code);
    NOONA_CORE_PKG.assert(l_cur = l_ledger.currency_code OR p_exchange_rate > 0, 'NOONA-GL-045',
      'سعر الصرف إلزامي للقيود بعملة أجنبية', 'Exchange rate required for foreign currency');
    INSERT INTO gl_journal (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, rate_date, ledger_id, period_id,
                            posting_date, journal_source_id, journal_category, reference_no, description, is_opening,
                            is_adjustment, status_code)
    VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'DRAFT-' || RAWTOHEX(SYS_GUID()), TRUNC(p_doc_date), l_cur,
            CASE WHEN l_cur = l_ledger.currency_code THEN 1 ELSE p_exchange_rate END, TRUNC(p_doc_date), l_ledger.id,
            period_for(p_doc_date), TRUNC(p_doc_date), l_src.id, 'MANUAL', p_reference, p_description, 'N', 'N', 'DRAFT')
    RETURNING id INTO l_id;
    UPDATE gl_journal SET doc_no = 'مسودة-' || l_id WHERE id = l_id;
    RETURN l_id;
  END create_journal;

  PROCEDURE assert_draft(p_j gl_journal%ROWTYPE) IS
  BEGIN
    NOONA_CORE_PKG.assert(p_j.status_code = 'DRAFT', 'NOONA-GL-050', 'لا يعدل القيد بعد إرساله', 'Only draft journals can be edited');
  END assert_draft;

  PROCEDURE update_header(p_journal_id IN NUMBER, p_doc_date IN DATE, p_description IN VARCHAR2,
                          p_reference IN VARCHAR2 DEFAULT NULL) IS
    l_j gl_journal%ROWTYPE := get_journal(p_journal_id, TRUE);
  BEGIN
    guard('GL_JOURNAL.UPDATE');
    assert_draft(l_j);
    NOONA_CORE_PKG.assert(p_description IS NOT NULL, 'NOONA-GL-044', 'البيان إلزامي', 'Description is required');
    UPDATE gl_journal
       SET doc_date = TRUNC(p_doc_date), posting_date = TRUNC(p_doc_date), rate_date = TRUNC(p_doc_date),
           period_id = period_for(p_doc_date), description = p_description, reference_no = p_reference
     WHERE id = p_journal_id;
  END update_header;

  -- ================================================================ مراكز التكلفة
  FUNCTION cc_dimension RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT MIN(id) INTO l_id FROM gl_dimension WHERE code = 'COST_CENTER';
    IF l_id IS NULL THEN
      INSERT INTO gl_dimension (code, name_ar, name_en, dimension_kind, source_entity_type, is_active, sort_order)
      VALUES ('COST_CENTER', 'مركز التكلفة', 'Cost center', 'SYSTEM', 'GL_COST_CENTER', 'Y', 1)
      RETURNING id INTO l_id;
    END IF;
    RETURN l_id;
  END cc_dimension;

  FUNCTION create_cost_center(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_type IN VARCHAR2 DEFAULT 'COST',
                              p_parent_code IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_parent NUMBER;
    l_id     NUMBER;
  BEGIN
    guard('GL_COST_CENTER.CREATE');
    IF p_parent_code IS NOT NULL THEN
      SELECT MIN(id) INTO l_parent FROM gl_cost_center WHERE company_id = company AND code = UPPER(p_parent_code);
      NOONA_CORE_PKG.assert(l_parent IS NOT NULL, 'NOONA-GL-090', 'المركز الأب غير موجود', 'Parent cost center not found');
    END IF;
    INSERT INTO gl_cost_center (company_id, code, name_ar, center_type, parent_center_id, status_code, effective_from)
    VALUES (company, UPPER(TRIM(p_code)), p_name_ar, NVL(p_type, 'COST'), l_parent, 'ACTIVE', TRUNC(SYSDATE))
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'GL_COST_CENTER', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-GL-091', 'رمز مركز التكلفة مستخدم', 'Cost center code already exists');
  END create_cost_center;

  PROCEDURE set_cost_center_status(p_cost_center_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('GL_COST_CENTER.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'BLOCKED', 'CLOSED'), 'NOONA-GL-092', 'حالة غير صالحة', 'Invalid status');
    UPDATE gl_cost_center SET status_code = p_status WHERE id = p_cost_center_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'GL_COST_CENTER', p_cost_center_id, 'STATUS_' || p_status, 'SUCCESS');
  END set_cost_center_status;

  PROCEDURE set_cc_rule(p_account_id IN NUMBER, p_rule IN VARCHAR2) IS
    l_dim NUMBER;
  BEGIN
    guard('GL_ACCOUNT.UPDATE');
    NOONA_CORE_PKG.assert(p_rule IN ('REQUIRED', 'OPTIONAL', 'FORBIDDEN'), 'NOONA-GL-093', 'قاعدة غير صالحة', 'Invalid rule');
    l_dim := cc_dimension;
    DELETE FROM gl_account_dim_rule WHERE account_id = p_account_id AND dimension_id = l_dim;
    IF p_rule <> 'OPTIONAL' THEN
      INSERT INTO gl_account_dim_rule (account_id, dimension_id, rule_code, effective_from)
      VALUES (p_account_id, l_dim, p_rule, DATE '2000-01-01');
    END IF;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'GL_ACCOUNT', p_account_id, 'CC_RULE_' || p_rule, 'SUCCESS');
  END set_cc_rule;

  FUNCTION cc_rule(p_account_id IN NUMBER) RETURN VARCHAR2 IS
    l_rule VARCHAR2(20);
  BEGIN
    SELECT MAX(r.rule_code) INTO l_rule FROM gl_account_dim_rule r JOIN gl_dimension d ON d.id = r.dimension_id
     WHERE r.account_id = p_account_id AND d.code = 'COST_CENTER'
       AND TRUNC(SYSDATE) BETWEEN NVL(r.effective_from, DATE '2000-01-01') AND NVL(r.effective_to, DATE '9999-12-31');
    RETURN NVL(l_rule, 'OPTIONAL');
  END cc_rule;

  -- قواعد سطر القيد المشتركة (يدوي ونظامي): حساب حركة نشط، ومركز تكلفة صالح ومطابق لقاعدة الحساب
  PROCEDURE check_line(p_acc gl_account%ROWTYPE, p_cc NUMBER, p_no NUMBER, p_company NUMBER) IS
    l_rule VARCHAR2(20) := cc_rule(p_acc.id);
    l_n    NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(p_acc.is_postable = 'Y' AND p_acc.status_code = 'ACTIVE', 'NOONA-GL-052',
      'السطر ' || p_no || ': الحساب ' || p_acc.account_code || ' تجميعي أو موقوف', 'Account is not postable');
    NOONA_CORE_PKG.assert(NOT (l_rule = 'REQUIRED' AND p_cc IS NULL), 'NOONA-GL-055',
      'السطر ' || p_no || ': مركز التكلفة إلزامي للحساب ' || p_acc.account_code || ' - ' || p_acc.name_ar,
      'Cost center is required for this account');
    NOONA_CORE_PKG.assert(NOT (l_rule = 'FORBIDDEN' AND p_cc IS NOT NULL), 'NOONA-GL-056',
      'السطر ' || p_no || ': الحساب ' || p_acc.account_code || ' لا يقبل مركز تكلفة', 'Cost center not allowed for this account');
    IF p_cc IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM gl_cost_center WHERE id = p_cc AND company_id = p_company AND status_code = 'ACTIVE';
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-GL-057', 'السطر ' || p_no || ': مركز التكلفة غير صالح أو موقوف',
                            'Invalid or inactive cost center');
    END IF;
  END check_line;

  PROCEDURE save_lines(p_journal_id IN NUMBER, p_lines IN CLOB) IS
    l_j    gl_journal%ROWTYPE := get_journal(p_journal_id, TRUE);
    l_led  gl_ledger%ROWTYPE;
    l_acc  gl_account%ROWTYPE;
    l_no   PLS_INTEGER := 0;
    l_dr   NUMBER := 0;
    l_cr   NUMBER := 0;
    l_drf  NUMBER;
    l_crf  NUMBER;
  BEGIN
    guard('GL_JOURNAL.UPDATE');
    assert_draft(l_j);
    SELECT * INTO l_led FROM gl_ledger WHERE id = l_j.ledger_id;
    DELETE FROM gl_journal_line WHERE journal_id = p_journal_id;
    FOR r IN (SELECT * FROM JSON_TABLE(NVL(p_lines, '[]'), '$[*]' COLUMNS (
                acc VARCHAR2(50) PATH '$.a', dr NUMBER PATH '$.d', cr NUMBER PATH '$.c',
                cc NUMBER PATH '$.cc', txt VARCHAR2(500) PATH '$.t'))) LOOP
      CONTINUE WHEN r.acc IS NULL AND NVL(r.dr, 0) = 0 AND NVL(r.cr, 0) = 0;      -- سطر فارغ
      l_no := l_no + 1;
      BEGIN
        SELECT * INTO l_acc FROM gl_account WHERE coa_id = l_led.coa_id AND account_code = TRIM(r.acc);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-GL-051', 'السطر ' || l_no || ': الحساب غير موجود (' || r.acc || ')', 'Account not found');
      END;
      check_line(l_acc, r.cc, l_no, l_j.company_id);
      NOONA_CORE_PKG.assert(l_acc.allow_manual_posting = 'Y', 'NOONA-GL-053',
        'السطر ' || l_no || ': الحساب ' || l_acc.account_code || ' حساب مراقبة يرحل إليه من نظامه الفرعي فقط',
        'Control account: post from its subledger');
      NOONA_CORE_PKG.assert((NVL(r.dr, 0) > 0 AND NVL(r.cr, 0) = 0) OR (NVL(r.cr, 0) > 0 AND NVL(r.dr, 0) = 0), 'NOONA-GL-054',
        'السطر ' || l_no || ': أدخل مبلغاً مديناً أو دائناً موجباً (واحداً فقط)', 'Each line needs either a debit or a credit');
      l_drf := NOONA_REFERENCE_PKG.round_amount(NVL(r.dr, 0) * l_j.exchange_rate, l_led.currency_code);
      l_crf := NOONA_REFERENCE_PKG.round_amount(NVL(r.cr, 0) * l_j.exchange_rate, l_led.currency_code);
      INSERT INTO gl_journal_line (company_id, journal_id, line_no, account_id, account_code_snapshot, debit_amount, credit_amount,
                                   currency_code, exchange_rate, debit_func, credit_func, branch_id, cost_center_id, description)
      VALUES (l_j.company_id, p_journal_id, l_no, l_acc.id, l_acc.account_code, NVL(r.dr, 0), NVL(r.cr, 0), l_j.currency_code,
              l_j.exchange_rate, l_drf, l_crf, l_j.branch_id, r.cc, r.txt);
      l_dr := l_dr + l_drf; l_cr := l_cr + l_crf;
    END LOOP;
    UPDATE gl_journal SET total_debit_func = l_dr, total_credit_func = l_cr WHERE id = p_journal_id;
  END save_lines;

  PROCEDURE assert_balanced(p_journal_id NUMBER) IS
    l_n  NUMBER; l_dr NUMBER; l_cr NUMBER;
  BEGIN
    SELECT COUNT(*), NVL(SUM(debit_func), 0), NVL(SUM(credit_func), 0) INTO l_n, l_dr, l_cr
      FROM gl_journal_line WHERE journal_id = p_journal_id;
    NOONA_CORE_PKG.assert(l_n >= 2, 'NOONA-GL-060', 'القيد يحتاج سطرين على الأقل', 'A journal needs at least two lines');
    NOONA_CORE_PKG.assert(l_dr = l_cr AND l_dr > 0, 'NOONA-GL-061',
      'القيد غير متوازن: المدين ' || fmt0(l_dr) || ' والدائن ' || fmt0(l_cr), 'Journal is not balanced');
  END assert_balanced;

  PROCEDURE do_post(p_journal_id NUMBER) IS
    l_j   gl_journal%ROWTYPE := get_journal(p_journal_id, TRUE);
    l_no  VARCHAR2(100);
  BEGIN
    assert_balanced(p_journal_id);
    assert_period_open(l_j.period_id, l_j.ledger_id);
    l_no := NOONA_REFERENCE_PKG.next_doc_no('GL_JOURNAL', l_j.company_id, l_j.branch_id, l_j.doc_date, 'GL_JOURNAL', l_j.id);
    UPDATE gl_journal SET doc_no = l_no, status_code = 'POSTED', posted_at = SYSTIMESTAMP,
                          posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = p_journal_id;
    MERGE INTO gl_balance b
    USING (SELECT l_j.ledger_id ledger_id, l_j.period_id period_id, l.account_id, l.currency_code,
                  'B' || NVL(l.branch_id, 0) || '-C' || NVL(l.cost_center_id, 0) dim_key, MAX(l.branch_id) branch_id,
                  MAX(l.cost_center_id) cost_center_id, SUM(l.debit_func) drf, SUM(l.credit_func) crf,
                  SUM(l.debit_amount) drt, SUM(l.credit_amount) crt
             FROM gl_journal_line l WHERE l.journal_id = p_journal_id
            GROUP BY l.account_id, l.currency_code, 'B' || NVL(l.branch_id, 0) || '-C' || NVL(l.cost_center_id, 0)) s
       ON (b.ledger_id = s.ledger_id AND b.period_id = s.period_id AND b.account_id = s.account_id
           AND b.currency_code = s.currency_code AND b.dimension_key = s.dim_key)
     WHEN MATCHED THEN UPDATE SET b.period_dr_func = b.period_dr_func + s.drf, b.period_cr_func = b.period_cr_func + s.crf,
                                  b.period_dr_txn = b.period_dr_txn + s.drt, b.period_cr_txn = b.period_cr_txn + s.crt
     WHEN NOT MATCHED THEN INSERT (company_id, ledger_id, period_id, account_id, currency_code, dimension_key, branch_id,
                                   cost_center_id, opening_dr_func, opening_cr_func, period_dr_func, period_cr_func,
                                   period_dr_txn, period_cr_txn)
          VALUES (l_j.company_id, s.ledger_id, s.period_id, s.account_id, s.currency_code, s.dim_key, s.branch_id,
                  s.cost_center_id, 0, 0, s.drf, s.crf, s.drt, s.crt);
    NOONA_AUDIT_PKG.log_event('POSTING', 'GL_JOURNAL', p_journal_id, 'POST', 'SUCCESS',
      p_new_values => '{"doc_no":' || NOONA_CORE_PKG.json_text(l_no) || ',"amount":' || l_j.total_debit_func || '}');
  END do_post;

  PROCEDURE submit_journal(p_journal_id IN NUMBER) IS
    l_j   gl_journal%ROWTYPE := get_journal(p_journal_id, TRUE);
    l_req VARCHAR2(1);
  BEGIN
    guard('GL_JOURNAL.SUBMIT');
    assert_draft(l_j);
    assert_balanced(p_journal_id);
    assert_period_open(l_j.period_id, l_j.ledger_id);
    SELECT requires_approval INTO l_req FROM gl_journal_source WHERE id = l_j.journal_source_id;
    IF l_req = 'N' THEN
      NOONA_SECURITY_PKG.assert_permission('GL_JOURNAL.POST', l_j.company_id);
      do_post(p_journal_id);
    ELSE
      UPDATE gl_journal SET status_code = 'SUBMITTED' WHERE id = p_journal_id;
      NOONA_AUDIT_PKG.log_event('APPROVAL', 'GL_JOURNAL', p_journal_id, 'SUBMIT', 'SUCCESS');
    END IF;
  END submit_journal;

  PROCEDURE approve_journal(p_journal_id IN NUMBER, p_comment IN VARCHAR2 DEFAULT NULL) IS
    l_j gl_journal%ROWTYPE := get_journal(p_journal_id, TRUE);
  BEGIN
    guard('GL_JOURNAL.APPROVE');
    NOONA_SECURITY_PKG.assert_permission('GL_JOURNAL.POST', l_j.company_id);
    NOONA_CORE_PKG.assert(l_j.status_code = 'SUBMITTED', 'NOONA-GL-070', 'القيد ليس بانتظار الاعتماد', 'Journal is not pending approval');
    NOONA_CORE_PKG.assert(l_j.created_by <> NOONA_CTX_PKG.current_user_name, 'NOONA-GL-071',
      'لا يعتمد القيد من أنشأه (فصل المهام)', 'Maker cannot approve their own journal');
    UPDATE gl_journal SET approved_by = NOONA_CTX_PKG.current_user_name, status_code = 'APPROVED' WHERE id = p_journal_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'GL_JOURNAL', p_journal_id, 'APPROVE', 'SUCCESS', p_reason => p_comment);
    do_post(p_journal_id);
  END approve_journal;

  PROCEDURE reject_journal(p_journal_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_j gl_journal%ROWTYPE := get_journal(p_journal_id, TRUE);
  BEGIN
    guard('GL_JOURNAL.REJECT');
    NOONA_CORE_PKG.assert(l_j.status_code = 'SUBMITTED', 'NOONA-GL-070', 'القيد ليس بانتظار الاعتماد', 'Journal is not pending approval');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-GL-072', 'سبب الرفض إلزامي', 'Reason is required');
    UPDATE gl_journal SET status_code = 'DRAFT' WHERE id = p_journal_id;       -- يعود للمنشئ للتصحيح
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'GL_JOURNAL', p_journal_id, 'REJECT', 'SUCCESS', p_reason => p_reason);
  END reject_journal;

  PROCEDURE cancel_journal(p_journal_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_j gl_journal%ROWTYPE := get_journal(p_journal_id, TRUE);
  BEGIN
    guard('GL_JOURNAL.CANCEL');
    assert_draft(l_j);
    UPDATE gl_journal SET status_code = 'CANCELLED' WHERE id = p_journal_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'GL_JOURNAL', p_journal_id, 'CANCEL', 'SUCCESS', p_reason => p_reason);
  END cancel_journal;

  FUNCTION do_reverse(p_journal_id IN NUMBER, p_reversal_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_j   gl_journal%ROWTYPE := get_journal(p_journal_id, TRUE);
    l_new NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(l_j.status_code = 'POSTED' AND l_j.reversed_by_id IS NULL, 'NOONA-GL-080',
      'يعكس القيد المرحل غير المعكوس فقط', 'Only posted, non-reversed journals can be reversed');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-GL-081', 'سبب العكس إلزامي', 'Reason is required');
    NOONA_CORE_PKG.assert(TRUNC(NVL(p_reversal_date, SYSDATE)) >= l_j.doc_date, 'NOONA-GL-082',
      'تاريخ العكس لا يسبق تاريخ القيد', 'Reversal cannot precede the journal');
    INSERT INTO gl_journal (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, rate_date, ledger_id, period_id,
                            posting_date, journal_source_id, journal_category, reference_no, description, is_opening,
                            is_adjustment, reversal_of_id, status_code, approved_by)
    VALUES (l_j.company_id, l_j.branch_id, 'REV-' || RAWTOHEX(SYS_GUID()), TRUNC(NVL(p_reversal_date, SYSDATE)), l_j.currency_code,
            l_j.exchange_rate, l_j.rate_date, l_j.ledger_id, period_for(NVL(p_reversal_date, SYSDATE)),
            TRUNC(NVL(p_reversal_date, SYSDATE)), l_j.journal_source_id, 'REVERSAL', l_j.doc_no,
            'عكس القيد ' || l_j.doc_no || ': ' || p_reason, 'N', l_j.is_adjustment, l_j.id, 'APPROVED',
            NOONA_CTX_PKG.current_user_name)
    RETURNING id INTO l_new;
    INSERT INTO gl_journal_line (company_id, journal_id, line_no, account_id, account_code_snapshot, debit_amount, credit_amount,
                                 currency_code, exchange_rate, debit_func, credit_func, branch_id, cost_center_id, description)
    SELECT company_id, l_new, line_no, account_id, account_code_snapshot, credit_amount, debit_amount, currency_code,
           exchange_rate, credit_func, debit_func, branch_id, cost_center_id, description
      FROM gl_journal_line WHERE journal_id = p_journal_id;
    UPDATE gl_journal SET total_debit_func = l_j.total_credit_func, total_credit_func = l_j.total_debit_func WHERE id = l_new;
    do_post(l_new);
    UPDATE gl_journal SET status_code = 'REVERSED', reversed_by_id = l_new WHERE id = p_journal_id;
    NOONA_AUDIT_PKG.log_event('POSTING', 'GL_JOURNAL', p_journal_id, 'REVERSE', 'SUCCESS', p_reason => p_reason);
    RETURN l_new;
  END do_reverse;

  FUNCTION reverse_journal(p_journal_id IN NUMBER, p_reversal_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_manual VARCHAR2(1);
  BEGIN
    guard('GL_JOURNAL.REVERSE');
    SELECT s.allow_manual INTO l_manual FROM gl_journal j JOIN gl_journal_source s ON s.id = j.journal_source_id WHERE j.id = p_journal_id;
    NOONA_CORE_PKG.assert(l_manual = 'Y', 'NOONA-GL-083',
      'هذا قيد آلي من مستند مصدر (سند أو فاتورة)؛ يعكس بإلغاء المستند نفسه حتى يبقى الربط سليماً',
      'System journal: reverse its source document instead');
    RETURN do_reverse(p_journal_id, p_reversal_date, p_reason);
  END reverse_journal;

  FUNCTION reverse_system(p_journal_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER
    ACCESSIBLE BY (PACKAGE NOONA_ACE_PKG) IS
  BEGIN
    RETURN do_reverse(p_journal_id, p_date, p_reason);
  END reverse_system;

  FUNCTION post_system(p_source_code IN VARCHAR2, p_doc_date IN DATE, p_description IN VARCHAR2, p_currency IN VARCHAR2,
                       p_rate IN NUMBER, p_lines IN t_lines, p_reference IN VARCHAR2, p_event_id IN NUMBER,
                       p_branch_id IN NUMBER DEFAULT NULL) RETURN NUMBER ACCESSIBLE BY (PACKAGE NOONA_ACE_PKG) IS
    l_led gl_ledger%ROWTYPE;
    l_src NUMBER;
    l_id  NUMBER;
    l_acc gl_account%ROWTYPE;
    l_rate NUMBER;
    l_drf NUMBER; l_crf NUMBER; l_dr NUMBER := 0; l_cr NUMBER := 0;
  BEGIN
    BEGIN
      SELECT * INTO l_led FROM gl_ledger WHERE id = primary_ledger;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-GL-042', 'الأستاذ العام غير مجهز لهذه الشركة؛ نفذ التجهيز أولاً', 'Ledger not set up');
    END;
    SELECT id INTO l_src FROM gl_journal_source WHERE code = p_source_code;
    l_rate := CASE WHEN p_currency = l_led.currency_code THEN 1 ELSE p_rate END;
    NOONA_CORE_PKG.assert(l_rate > 0, 'NOONA-GL-045', 'سعر الصرف إلزامي للقيود بعملة أجنبية', 'Exchange rate required');
    INSERT INTO gl_journal (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, rate_date, ledger_id, period_id,
                            posting_date, journal_source_id, journal_category, accounting_event_id, reference_no, description,
                            is_opening, is_adjustment, status_code, approved_by)
    VALUES (l_led.company_id, p_branch_id, 'SYS-' || RAWTOHEX(SYS_GUID()), TRUNC(p_doc_date), p_currency, l_rate, TRUNC(p_doc_date),
            l_led.id, period_for(p_doc_date), TRUNC(p_doc_date), l_src, p_source_code, p_event_id, p_reference,
            p_description, 'N', 'N', 'APPROVED', NOONA_CTX_PKG.current_user_name)
    RETURNING id INTO l_id;
    FOR i IN 1 .. p_lines.COUNT LOOP
      SELECT * INTO l_acc FROM gl_account WHERE id = p_lines(i).account_id AND coa_id = l_led.coa_id;
      check_line(l_acc, p_lines(i).cost_center_id, i, l_led.company_id);
      NOONA_CORE_PKG.assert((NVL(p_lines(i).debit, 0) > 0 AND NVL(p_lines(i).credit, 0) = 0)
                            OR (NVL(p_lines(i).credit, 0) > 0 AND NVL(p_lines(i).debit, 0) = 0), 'NOONA-GL-054',
        'السطر ' || i || ': مبلغ مدين أو دائن موجب', 'Each line needs either a debit or a credit');
      l_drf := NOONA_REFERENCE_PKG.round_amount(NVL(p_lines(i).debit, 0) * l_rate, l_led.currency_code);
      l_crf := NOONA_REFERENCE_PKG.round_amount(NVL(p_lines(i).credit, 0) * l_rate, l_led.currency_code);
      INSERT INTO gl_journal_line (company_id, journal_id, line_no, account_id, account_code_snapshot, debit_amount, credit_amount,
                                   currency_code, exchange_rate, debit_func, credit_func, branch_id, cost_center_id, description)
      VALUES (l_led.company_id, l_id, i, l_acc.id, l_acc.account_code, NVL(p_lines(i).debit, 0), NVL(p_lines(i).credit, 0),
              p_currency, l_rate, l_drf, l_crf, p_branch_id, p_lines(i).cost_center_id, p_lines(i).description);
      l_dr := l_dr + l_drf; l_cr := l_cr + l_crf;
    END LOOP;
    UPDATE gl_journal SET total_debit_func = l_dr, total_credit_func = l_cr WHERE id = l_id;
    do_post(l_id);
    RETURN l_id;
  END post_system;

  -- ================================================================ الواجهة
  FUNCTION lines_json(p_journal_id IN NUMBER) RETURN CLOB IS
    l_out CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('a' VALUE account_code_snapshot,
                                     'd' VALUE CASE WHEN debit_amount <> 0 THEN debit_amount END,
                                     'c' VALUE CASE WHEN credit_amount <> 0 THEN credit_amount END,
                                     'cc' VALUE cost_center_id, 't' VALUE description) ORDER BY line_no RETURNING CLOB)
      INTO l_out FROM gl_journal_line WHERE journal_id = p_journal_id;
    RETURN NVL(l_out, '[]');
  END lines_json;

  FUNCTION accounts_json RETURN CLOB IS
    l_out CLOB;
    l_led NUMBER := primary_ledger;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('a' VALUE a.account_code, 'n' VALUE a.name_ar) ORDER BY a.account_code RETURNING CLOB)
      INTO l_out
      FROM gl_account a JOIN gl_ledger l ON l.coa_id = a.coa_id
     WHERE l.id = l_led AND a.is_postable = 'Y' AND a.status_code = 'ACTIVE' AND a.allow_manual_posting = 'Y';
    RETURN NVL(l_out, '[]');
  END accounts_json;

  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_class VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span>'
        || '<div><div class="nn-kpi-value">' || esc(p_value) || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION gl_summary(p_session IN VARCHAR2) RETURN CLOB IS
    l_led NUMBER := primary_ledger;
    l_draft NUMBER; l_sub NUMBER; l_month NUMBER; l_cnt NUMBER; l_period VARCHAR2(200);
  BEGIN
    IF l_led IS NULL THEN
      RETURN '<div class="nn-launch-empty"><span class="fa fa-calculator" aria-hidden="true"></span>'
          || '<b>الأستاذ العام غير مجهز لهذه الشركة</b><span>اضغط "تجهيز الأستاذ العام" لإنشاء دليل حسابات قياسي '
          || 'والدفتر الرئيسي وفتح فترات السنة المالية</span></div>';
    END IF;
    SELECT COUNT(CASE WHEN status_code = 'DRAFT' THEN 1 END), COUNT(CASE WHEN status_code = 'SUBMITTED' THEN 1 END),
           NVL(SUM(CASE WHEN status_code IN ('POSTED', 'REVERSED') AND doc_date >= TRUNC(SYSDATE, 'MM') THEN total_debit_func END), 0),
           COUNT(CASE WHEN status_code IN ('POSTED', 'REVERSED') AND doc_date >= TRUNC(SYSDATE, 'MM') THEN 1 END)
      INTO l_draft, l_sub, l_month, l_cnt
      FROM gl_journal WHERE ledger_id = l_led;
    SELECT MAX(p.name_ar) INTO l_period FROM gl_period p JOIN gl_period_status s ON s.period_id = p.id
     WHERE s.ledger_id = l_led AND s.module_code = 'GL' AND s.status_code = 'OPEN' AND TRUNC(SYSDATE) BETWEEN p.start_date AND p.end_date;
    RETURN '<div class="nn-hello"><div class="nn-hello-title">الأستاذ العام</div><div class="nn-hello-sub">'
        || '<span class="fa fa-building-o" aria-hidden="true"></span> ' || esc(NOONA_APEX_PKG.company_name)
        || ' &middot; ' || NVL(esc(l_period), 'لا توجد فترة مفتوحة لليوم') || '</div></div><div class="nn-kpis">'
        || kpi('قيود مسودة', l_draft, 'fa-pencil', 'is-muted')
        || kpi('بانتظار الاعتماد', l_sub, 'fa-hourglass-half', CASE WHEN l_sub > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('قيود مرحلة هذا الشهر', l_cnt, 'fa-check-circle', 'is-success')
        || kpi('إجمالي المرحل هذا الشهر', fmt0(l_month), 'fa-money', 'is-info')
        || '</div>';
  END gl_summary;

  FUNCTION journal_header(p_journal_id IN NUMBER) RETURN CLOB IS
    l_j   gl_journal%ROWTYPE := get_journal(p_journal_id);
    l_rev VARCHAR2(100);
  BEGIN
    IF l_j.reversal_of_id IS NOT NULL THEN
      SELECT doc_no INTO l_rev FROM gl_journal WHERE id = l_j.reversal_of_id;
    ELSIF l_j.reversed_by_id IS NOT NULL THEN
      SELECT doc_no INTO l_rev FROM gl_journal WHERE id = l_j.reversed_by_id;
    END IF;
    RETURN '<div class="nn-taskhead ' || CASE l_j.status_code WHEN 'POSTED' THEN 'is-success' WHEN 'SUBMITTED' THEN 'is-warning'
                                          WHEN 'REVERSED' THEN 'is-danger' ELSE '' END || '">'
        || '<div class="nn-taskhead-top"><div><div class="nn-taskhead-title">قيد يومية ' || esc(l_j.doc_no) || '</div>'
        || '<div class="nn-taskhead-sub">' || esc(l_j.description) || '</div></div>'
        || NOONA_UI_PKG.status_badge(l_j.status_code) || '</div><div class="nn-fields">'
        || '<div class="nn-field"><div class="nn-field-label">التاريخ</div><div class="nn-field-value">' || TO_CHAR(l_j.doc_date, 'YYYY-MM-DD') || '</div></div>'
        || '<div class="nn-field"><div class="nn-field-label">العملة</div><div class="nn-field-value">' || esc(l_j.currency_code)
        || CASE WHEN l_j.exchange_rate <> 1 THEN ' @ ' || l_j.exchange_rate END || '</div></div>'
        || '<div class="nn-field"><div class="nn-field-label">المدين</div><div class="nn-field-value">' || fmt0(l_j.total_debit_func) || '</div></div>'
        || '<div class="nn-field"><div class="nn-field-label">الدائن</div><div class="nn-field-value">' || fmt0(l_j.total_credit_func) || '</div></div>'
        || '<div class="nn-field"><div class="nn-field-label">المرجع</div><div class="nn-field-value">' || NVL(esc(l_j.reference_no), '-') || '</div></div>'
        || '<div class="nn-field"><div class="nn-field-label">أنشأه / اعتمده</div><div class="nn-field-value">' || esc(l_j.created_by)
        || CASE WHEN l_j.approved_by IS NOT NULL THEN ' / ' || esc(l_j.approved_by) END || '</div></div>'
        || CASE WHEN l_rev IS NOT NULL THEN '<div class="nn-field"><div class="nn-field-label">'
             || CASE WHEN l_j.reversal_of_id IS NOT NULL THEN 'عكس للقيد' ELSE 'معكوس بالقيد' END
             || '</div><div class="nn-field-value">' || esc(l_rev) || '</div></div>' END
        || '</div></div>';
  END journal_header;

  -- ================================================================ التقارير
  FUNCTION cc_title(p_cc NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(300);
  BEGIN
    IF p_cc IS NULL THEN RETURN NULL; END IF;
    SELECT ' - مركز التكلفة: ' || code || ' ' || name_ar INTO l FROM gl_cost_center WHERE id = p_cc;
    RETURN l;
  END cc_title;
  FUNCTION fy_start(p_date DATE) RETURN DATE IS
    l_d DATE;
  BEGIN
    SELECT MAX(start_date) INTO l_d FROM gl_fiscal_year WHERE company_id = company AND p_date BETWEEN start_date AND end_date;
    RETURN NVL(l_d, TRUNC(p_date, 'YYYY'));
  END fy_start;

  FUNCTION trial_balance(p_from IN DATE, p_to IN DATE, p_show_zero IN VARCHAR2 DEFAULT 'N',
                         p_cost_center_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_led  NUMBER := primary_ledger;
    l_fy   DATE := fy_start(p_from);
    l_html CLOB;
    l_t    NUMBER := 0;
    t_odr NUMBER := 0; t_ocr NUMBER := 0; t_pdr NUMBER := 0; t_pcr NUMBER := 0; t_cdr NUMBER := 0; t_ccr NUMBER := 0;
    l_grp  VARCHAR2(20);
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_BALANCE.VIEW', company);
    l_html := NOONA_BRAND_PKG.report_header('ميزان المراجعة من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD')
                                            || cc_title(p_cost_center_id))
           || '<table class="nn-rpt"><thead><tr><th rowspan="2">الحساب</th><th rowspan="2">اسم الحساب</th>'
           || '<th colspan="2">الرصيد الافتتاحي</th><th colspan="2">حركة الفترة</th><th colspan="2">الرصيد الختامي</th></tr>'
           || '<tr><th>مدين</th><th>دائن</th><th>مدين</th><th>دائن</th><th>مدين</th><th>دائن</th></tr></thead><tbody>';
    FOR r IN (
      WITH mv AS (
        SELECT l.account_id,
               -- الافتتاحي: الميزانية من البداية، والأرباح والخسائر من أول السنة المالية فقط
               SUM(CASE WHEN j.doc_date < p_from AND (a.account_type IN ('ASSET', 'LIABILITY', 'EQUITY') OR j.doc_date >= l_fy)
                        THEN l.debit_func - l.credit_func END) AS opening,
               SUM(CASE WHEN j.doc_date BETWEEN p_from AND p_to THEN l.debit_func END) AS pdr,
               SUM(CASE WHEN j.doc_date BETWEEN p_from AND p_to THEN l.credit_func END) AS pcr
          FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
         WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_to
           AND (p_cost_center_id IS NULL OR l.cost_center_id = p_cost_center_id)
         GROUP BY l.account_id)
      SELECT a.account_code, a.name_ar, a.account_type, NVL(m.opening, 0) opening, NVL(m.pdr, 0) pdr, NVL(m.pcr, 0) pcr
        FROM gl_account a JOIN gl_ledger g ON g.coa_id = a.coa_id AND g.id = l_led
        LEFT JOIN mv m ON m.account_id = a.id
       WHERE a.is_postable = 'Y'
         AND (p_show_zero = 'Y' OR NVL(m.opening, 0) <> 0 OR NVL(m.pdr, 0) <> 0 OR NVL(m.pcr, 0) <> 0)
       ORDER BY a.account_code) LOOP
      IF l_grp IS NULL OR l_grp <> r.account_type THEN
        l_grp := r.account_type;
        l_html := l_html || '<tr class="nn-rpt-group"><td colspan="8">' || esc(CASE r.account_type WHEN 'ASSET' THEN 'الأصول'
                  WHEN 'LIABILITY' THEN 'الخصوم' WHEN 'EQUITY' THEN 'حقوق الملكية' WHEN 'REVENUE' THEN 'الإيرادات'
                  WHEN 'EXPENSE' THEN 'التكاليف والمصروفات' ELSE r.account_type END) || '</td></tr>';
      END IF;
      l_t := r.opening + r.pdr - r.pcr;
      l_html := l_html || '<tr><td class="nn-num-code">' || esc(r.account_code) || '</td><td>' || esc(r.name_ar) || '</td>'
             || '<td>' || fmt(GREATEST(r.opening, 0)) || '</td><td>' || fmt(GREATEST(-r.opening, 0)) || '</td>'
             || '<td>' || fmt(r.pdr) || '</td><td>' || fmt(r.pcr) || '</td>'
             || '<td>' || fmt(GREATEST(l_t, 0)) || '</td><td>' || fmt(GREATEST(-l_t, 0)) || '</td></tr>';
      t_odr := t_odr + GREATEST(r.opening, 0); t_ocr := t_ocr + GREATEST(-r.opening, 0);
      t_pdr := t_pdr + r.pdr; t_pcr := t_pcr + r.pcr;
      t_cdr := t_cdr + GREATEST(l_t, 0); t_ccr := t_ccr + GREATEST(-l_t, 0);
    END LOOP;
    l_html := l_html || '</tbody><tfoot><tr><td colspan="2">الإجمالي</td><td>' || fmt0(t_odr) || '</td><td>' || fmt0(t_ocr)
           || '</td><td>' || fmt0(t_pdr) || '</td><td>' || fmt0(t_pcr) || '</td><td>' || fmt0(t_cdr) || '</td><td>' || fmt0(t_ccr)
           || '</td></tr></tfoot></table>'
           || CASE WHEN t_cdr = t_ccr THEN '<div class="nn-chain is-ok nn-rpt-check"><span class="fa fa-check-circle" aria-hidden="true"></span><div><b>الميزان متوازن</b></div></div>'
                   ELSE '<div class="nn-chain is-bad nn-rpt-check"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span><div><b>الميزان غير متوازن: الفرق '
                        || fmt0(t_cdr - t_ccr) || '</b></div></div>' END;
    RETURN l_html;
  END trial_balance;

  FUNCTION account_statement(p_account_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_cost_center_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_acc  gl_account%ROWTYPE;
    l_led  NUMBER := primary_ledger;
    l_open NUMBER;
    l_bal  NUMBER;
    l_html CLOB;
    l_sign NUMBER;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_BALANCE.VIEW', company);
    IF p_account_id IS NULL THEN
      RETURN '<div class="nn-empty">اختر الحساب والفترة</div>';
    END IF;
    SELECT * INTO l_acc FROM gl_account WHERE id = p_account_id;
    l_sign := CASE l_acc.normal_balance WHEN 'DEBIT' THEN 1 ELSE -1 END;
    SELECT NVL(SUM(l.debit_func - l.credit_func), 0) INTO l_open
      FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
     WHERE l.account_id = p_account_id AND j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date < p_from
       AND (p_cost_center_id IS NULL OR l.cost_center_id = p_cost_center_id)
       AND (l_acc.account_type IN ('ASSET', 'LIABILITY', 'EQUITY') OR j.doc_date >= fy_start(p_from));
    l_bal := l_open;
    l_html := NOONA_BRAND_PKG.report_header('كشف حساب ' || l_acc.account_code || ' - ' || l_acc.name_ar
                                            || ' من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD')
                                            || cc_title(p_cost_center_id))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>رقم القيد</th><th>البيان</th><th>مدين</th><th>دائن</th>'
           || '<th>الرصيد</th></tr></thead><tbody><tr class="nn-rpt-group"><td colspan="5">رصيد أول المدة</td><td>'
           || fmt0(l_open * l_sign) || '</td></tr>';
    FOR r IN (SELECT j.doc_date, j.doc_no, NVL(l.description, j.description) AS txt, l.debit_func, l.credit_func
                FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
               WHERE l.account_id = p_account_id AND j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED')
                 AND j.doc_date BETWEEN p_from AND p_to AND (p_cost_center_id IS NULL OR l.cost_center_id = p_cost_center_id)
               ORDER BY j.doc_date, j.posted_at, j.id, l.line_no) LOOP
      l_bal := l_bal + r.debit_func - r.credit_func;
      l_html := l_html || '<tr><td>' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') || '</td><td>' || esc(r.doc_no) || '</td><td class="nn-rpt-text">'
             || esc(r.txt) || '</td><td>' || fmt(r.debit_func) || '</td><td>' || fmt(r.credit_func) || '</td><td>' || fmt0(l_bal * l_sign) || '</td></tr>';
    END LOOP;
    RETURN l_html || '</tbody><tfoot><tr><td colspan="5">الرصيد الختامي (' || CASE l_acc.normal_balance WHEN 'DEBIT' THEN 'مدين' ELSE 'دائن' END
        || ' بطبيعته)</td><td>' || fmt0(l_bal * l_sign) || '</td></tr></tfoot></table>';
  END account_statement;

  FUNCTION cost_centers_json RETURN CLOB IS
    l_out CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'n' VALUE code || ' - ' || name_ar) ORDER BY code RETURNING CLOB)
      INTO l_out FROM gl_cost_center WHERE company_id = company AND status_code = 'ACTIVE';
    RETURN NVL(l_out, '[]');
  END cost_centers_json;

  -- مبالغ حسابات الأرباح والخسائر: الإيرادات دائن-مدين، المصروفات مدين-دائن؛ مجمعة تحت الحساب الرئيسي من المستوى الثاني
  FUNCTION income_statement(p_from IN DATE, p_to IN DATE, p_cost_center_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_led  NUMBER := primary_ledger;
    l_coa  NUMBER := primary_coa;
    l_html CLOB;
    l_rev  NUMBER := 0;
    l_exp  NUMBER := 0;
    l_grp  VARCHAR2(400);
    l_gsum NUMBER := 0;
    l_type VARCHAR2(20);
    PROCEDURE close_group IS
    BEGIN
      IF l_grp IS NOT NULL THEN
        l_html := l_html || '<tr class="nn-rpt-sub"><td colspan="2">إجمالي ' || esc(l_grp) || '</td><td>' || fmt0(l_gsum) || '</td></tr>';
      END IF;
    END close_group;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_BALANCE.VIEW', company);
    l_html := NOONA_BRAND_PKG.report_header('قائمة الدخل من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD')
                                            || cc_title(p_cost_center_id))
           || '<table class="nn-rpt nn-rpt-fs"><thead><tr><th>الحساب</th><th>البيان</th><th>المبلغ</th></tr></thead><tbody>';
    FOR r IN (
      WITH tree AS (
        SELECT a.id, a.account_code, a.name_ar, a.account_type, a.is_postable, LEVEL lvl,
               SYS_CONNECT_BY_PATH(a.id, '/') path
          FROM gl_account a WHERE a.coa_id = l_coa
         START WITH a.parent_account_id IS NULL CONNECT BY PRIOR a.id = a.parent_account_id),
      mv AS (
        SELECT l.account_id, SUM(l.debit_func - l.credit_func) net
          FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
         WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date BETWEEN p_from AND p_to
           AND (p_cost_center_id IS NULL OR l.cost_center_id = p_cost_center_id)
         GROUP BY l.account_id)
      SELECT t.account_code, t.name_ar, t.account_type,
             CASE WHEN t.account_type = 'REVENUE' THEN -m.net ELSE m.net END amount,
             g.account_code grp_code, g.name_ar grp_name
        FROM tree t JOIN mv m ON m.account_id = t.id
        JOIN gl_account g ON g.id = TO_NUMBER(REGEXP_SUBSTR(t.path, '[^/]+', 1, CASE WHEN t.lvl >= 3 THEN 2 ELSE 1 END))
       WHERE t.account_type IN ('REVENUE', 'EXPENSE') AND t.is_postable = 'Y' AND m.net <> 0
       ORDER BY CASE t.account_type WHEN 'REVENUE' THEN 0 ELSE 1 END, g.account_code, t.account_code) LOOP
      IF l_type IS NULL OR l_type <> r.account_type THEN
        close_group; l_grp := NULL;
        IF l_type = 'REVENUE' THEN
          l_html := l_html || '<tr class="nn-rpt-total"><td colspan="2">إجمالي الإيرادات</td><td>' || fmt0(l_rev) || '</td></tr>';
        END IF;
        l_type := r.account_type;
        l_html := l_html || '<tr class="nn-rpt-group"><td colspan="3">' || CASE r.account_type WHEN 'REVENUE' THEN 'الإيرادات'
                  ELSE 'التكاليف والمصروفات' END || '</td></tr>';
      END IF;
      IF l_grp IS NULL OR l_grp <> r.grp_code || ' ' || r.grp_name THEN
        close_group;
        l_grp := r.grp_code || ' ' || r.grp_name; l_gsum := 0;
        l_html := l_html || '<tr class="nn-rpt-head2"><td colspan="3">' || esc(l_grp) || '</td></tr>';
      END IF;
      l_html := l_html || '<tr><td class="nn-num-code">' || esc(r.account_code) || '</td><td>' || esc(r.name_ar) || '</td><td>'
             || fmt0(r.amount) || '</td></tr>';
      l_gsum := l_gsum + r.amount;
      IF r.account_type = 'REVENUE' THEN l_rev := l_rev + r.amount; ELSE l_exp := l_exp + r.amount; END IF;
    END LOOP;
    close_group;
    IF l_type = 'REVENUE' THEN
      l_html := l_html || '<tr class="nn-rpt-total"><td colspan="2">إجمالي الإيرادات</td><td>' || fmt0(l_rev) || '</td></tr>';
    END IF;
    l_html := l_html || '<tr class="nn-rpt-total"><td colspan="2">إجمالي التكاليف والمصروفات</td><td>' || fmt0(l_exp) || '</td></tr>'
           || '</tbody><tfoot><tr><td colspan="2">' || CASE WHEN l_rev - l_exp >= 0 THEN 'صافي الربح' ELSE 'صافي الخسارة' END
           || '</td><td>' || fmt0(ABS(l_rev - l_exp)) || '</td></tr></tfoot></table>';
    RETURN l_html;
  END income_statement;

  FUNCTION balance_sheet(p_as_of IN DATE) RETURN CLOB IS
    l_led  NUMBER := primary_ledger;
    l_fy   DATE := fy_start(p_as_of);
    l_html CLOB;
    l_tot  NUMBER := 0;
    l_sec  VARCHAR2(20);
    l_asst NUMBER := 0;
    l_le   NUMBER := 0;
    l_cur  NUMBER;
    l_prev NUMBER;
    PROCEDURE close_sec IS
    BEGIN
      IF l_sec IS NOT NULL THEN
        l_html := l_html || '<tr class="nn-rpt-total"><td colspan="2">إجمالي ' || CASE l_sec WHEN 'ASSET' THEN 'الأصول'
                  WHEN 'LIABILITY' THEN 'الخصوم' ELSE 'حقوق الملكية' END || '</td><td>' || fmt0(l_tot) || '</td></tr>';
      END IF;
    END close_sec;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_BALANCE.VIEW', company);
    -- أرباح الفترة الجارية وأرباح سنوات سابقة لم تقفل بعد في الأرباح المبقاة
    SELECT NVL(SUM(CASE WHEN j.doc_date >= l_fy THEN l.credit_func - l.debit_func END), 0),
           NVL(SUM(CASE WHEN j.doc_date < l_fy THEN l.credit_func - l.debit_func END), 0)
      INTO l_cur, l_prev
      FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_as_of
       AND a.account_type IN ('REVENUE', 'EXPENSE');
    l_html := NOONA_BRAND_PKG.report_header('الميزانية العمومية (قائمة المركز المالي) كما في ' || TO_CHAR(p_as_of, 'YYYY-MM-DD'))
           || '<table class="nn-rpt nn-rpt-fs"><thead><tr><th>الحساب</th><th>البيان</th><th>الرصيد</th></tr></thead><tbody>';
    FOR r IN (
      SELECT a.account_code, a.name_ar, a.account_type,
             SUM(CASE WHEN a.account_type = 'ASSET' THEN l.debit_func - l.credit_func ELSE l.credit_func - l.debit_func END) bal
        FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
       WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_as_of
         AND a.account_type IN ('ASSET', 'LIABILITY', 'EQUITY')
       GROUP BY a.account_code, a.name_ar, a.account_type
      HAVING SUM(l.debit_func - l.credit_func) <> 0
       ORDER BY CASE a.account_type WHEN 'ASSET' THEN 0 WHEN 'LIABILITY' THEN 1 ELSE 2 END, a.account_code) LOOP
      IF l_sec IS NULL OR l_sec <> r.account_type THEN
        close_sec;
        IF l_sec = 'ASSET' THEN l_asst := l_tot; ELSIF l_sec IS NOT NULL THEN l_le := l_le + l_tot; END IF;
        l_sec := r.account_type; l_tot := 0;
        l_html := l_html || '<tr class="nn-rpt-group"><td colspan="3">' || CASE r.account_type WHEN 'ASSET' THEN 'الأصول'
                  WHEN 'LIABILITY' THEN 'الخصوم' ELSE 'حقوق الملكية' END || '</td></tr>';
      END IF;
      l_html := l_html || '<tr><td class="nn-num-code">' || esc(r.account_code) || '</td><td>' || esc(r.name_ar) || '</td><td>'
             || fmt0(r.bal) || '</td></tr>';
      l_tot := l_tot + r.bal;
    END LOOP;
    -- حقوق الملكية تشمل أرباح الفترة دائماً (حتى لو لم توجد حسابات حقوق ملكية بأرصدة)
    IF l_sec = 'ASSET' THEN
      close_sec; l_asst := l_tot; l_sec := 'EQUITY'; l_tot := 0;
      l_html := l_html || '<tr class="nn-rpt-group"><td colspan="3">حقوق الملكية</td></tr>';
    ELSIF l_sec = 'LIABILITY' THEN
      close_sec; l_le := l_le + l_tot; l_sec := 'EQUITY'; l_tot := 0;
      l_html := l_html || '<tr class="nn-rpt-group"><td colspan="3">حقوق الملكية</td></tr>';
    END IF;
    IF l_prev <> 0 THEN
      l_html := l_html || '<tr><td></td><td>أرباح (خسائر) سنوات سابقة غير مرحلة</td><td>' || fmt0(l_prev) || '</td></tr>';
      l_tot := l_tot + l_prev;
    END IF;
    l_html := l_html || '<tr><td></td><td>' || CASE WHEN l_cur >= 0 THEN 'صافي ربح السنة الجارية' ELSE 'صافي خسارة السنة الجارية' END
           || '</td><td>' || fmt0(l_cur) || '</td></tr>';
    l_tot := l_tot + l_cur;
    close_sec;
    l_le := l_le + l_tot;
    l_html := l_html || '</tbody><tfoot><tr><td colspan="2">إجمالي الخصوم وحقوق الملكية</td><td>' || fmt0(l_le) || '</td></tr></tfoot></table>'
           || CASE WHEN ROUND(l_asst, 2) = ROUND(l_le, 2)
                   THEN '<div class="nn-chain is-ok nn-rpt-check"><span class="fa fa-check-circle" aria-hidden="true"></span><div><b>الميزانية متوازنة: الأصول = الخصوم + حقوق الملكية = '
                        || fmt0(l_asst) || '</b></div></div>'
                   ELSE '<div class="nn-chain is-bad nn-rpt-check"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span><div><b>الميزانية غير متوازنة: الفرق '
                        || fmt0(l_asst - l_le) || '</b></div></div>' END;
    RETURN l_html;
  END balance_sheet;

  -- تحليل مصفوفي: صفوف الحسابات وأعمدة الأشهر أو مراكز التكلفة
  FUNCTION analysis(p_from IN DATE, p_to IN DATE, p_type IN VARCHAR2, p_by IN VARCHAR2) RETURN CLOB IS
    TYPE t_cols IS TABLE OF VARCHAR2(200) INDEX BY PLS_INTEGER;
    TYPE t_keys IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
    TYPE t_amt IS TABLE OF NUMBER INDEX BY VARCHAR2(200);
    l_led   NUMBER := primary_ledger;
    l_cols  t_cols;
    l_keys  t_keys;
    l_amt   t_amt;
    l_coltot t_amt;
    l_html  CLOB;
    l_n     PLS_INTEGER := 0;
    l_rowt  NUMBER;
    l_grand NUMBER := 0;
    l_sign  NUMBER := CASE p_type WHEN 'REVENUE' THEN -1 ELSE 1 END;
    l_m     DATE := TRUNC(p_from, 'MM');
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_BALANCE.VIEW', company);
    NOONA_CORE_PKG.assert(p_type IN ('REVENUE', 'EXPENSE') AND p_by IN ('MONTH', 'CC'), 'NOONA-GL-100', 'معايير غير صالحة', 'Invalid criteria');
    IF p_by = 'MONTH' THEN
      WHILE l_m <= p_to AND l_n < 24 LOOP
        l_n := l_n + 1; l_keys(l_n) := TO_CHAR(l_m, 'YYYY-MM'); l_cols(l_n) := TO_CHAR(l_m, 'YYYY-MM');
        l_m := ADD_MONTHS(l_m, 1);
      END LOOP;
    ELSE
      FOR c IN (SELECT id, code, name_ar FROM gl_cost_center WHERE company_id = company ORDER BY code) LOOP
        l_n := l_n + 1; l_keys(l_n) := TO_CHAR(c.id); l_cols(l_n) := c.code || ' ' || c.name_ar;
      END LOOP;
      l_n := l_n + 1; l_keys(l_n) := '0'; l_cols(l_n) := 'بدون مركز';
    END IF;
    FOR r IN (SELECT a.account_code, CASE WHEN p_by = 'MONTH' THEN TO_CHAR(j.doc_date, 'YYYY-MM')
                                           ELSE TO_CHAR(NVL(l.cost_center_id, 0)) END k,
                     SUM(l.debit_func - l.credit_func) net
                FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
               WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date BETWEEN p_from AND p_to
                 AND a.account_type = p_type
               GROUP BY a.account_code, CASE WHEN p_by = 'MONTH' THEN TO_CHAR(j.doc_date, 'YYYY-MM') ELSE TO_CHAR(NVL(l.cost_center_id, 0)) END) LOOP
      l_amt(r.account_code || '|' || r.k) := r.net * l_sign;
    END LOOP;
    l_html := NOONA_BRAND_PKG.report_header('تحليل ' || CASE p_type WHEN 'REVENUE' THEN 'الإيرادات' ELSE 'المصروفات' END
                || CASE p_by WHEN 'MONTH' THEN ' حسب الشهر' ELSE ' حسب مراكز التكلفة' END
                || ' من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<div class="nn-rpt-scroll"><table class="nn-rpt nn-rpt-matrix"><thead><tr><th>الحساب</th><th>البيان</th>';
    FOR i IN 1 .. l_n LOOP l_html := l_html || '<th>' || esc(l_cols(i)) || '</th>'; END LOOP;
    l_html := l_html || '<th>الإجمالي</th><th>النسبة</th></tr></thead><tbody>';
    -- الإجمالي العام أولاً لحساب النسب
    FOR a IN (SELECT a.account_code FROM gl_account a WHERE a.coa_id = primary_coa AND a.account_type = p_type AND a.is_postable = 'Y') LOOP
      FOR i IN 1 .. l_n LOOP
        IF l_amt.EXISTS(a.account_code || '|' || l_keys(i)) THEN l_grand := l_grand + l_amt(a.account_code || '|' || l_keys(i)); END IF;
      END LOOP;
    END LOOP;
    FOR a IN (SELECT a.account_code, a.name_ar FROM gl_account a
               WHERE a.coa_id = primary_coa AND a.account_type = p_type AND a.is_postable = 'Y' ORDER BY a.account_code) LOOP
      l_rowt := 0;
      FOR i IN 1 .. l_n LOOP
        IF l_amt.EXISTS(a.account_code || '|' || l_keys(i)) THEN l_rowt := l_rowt + l_amt(a.account_code || '|' || l_keys(i)); END IF;
      END LOOP;
      IF l_rowt <> 0 THEN
        l_html := l_html || '<tr><td class="nn-num-code">' || esc(a.account_code) || '</td><td>' || esc(a.name_ar) || '</td>';
        FOR i IN 1 .. l_n LOOP
          IF l_amt.EXISTS(a.account_code || '|' || l_keys(i)) THEN
            l_html := l_html || '<td>' || fmt(l_amt(a.account_code || '|' || l_keys(i))) || '</td>';
            l_coltot(l_keys(i)) := CASE WHEN l_coltot.EXISTS(l_keys(i)) THEN l_coltot(l_keys(i)) ELSE 0 END + l_amt(a.account_code || '|' || l_keys(i));
          ELSE
            l_html := l_html || '<td></td>';
          END IF;
        END LOOP;
        l_html := l_html || '<td class="nn-rpt-rowtot">' || fmt0(l_rowt) || '</td><td>'
               || CASE WHEN l_grand <> 0 THEN TO_CHAR(ROUND(l_rowt * 100 / l_grand, 1), 'FM990.0') || '%' END || '</td></tr>';
      END IF;
    END LOOP;
    l_html := l_html || '</tbody><tfoot><tr><td colspan="2">الإجمالي</td>';
    FOR i IN 1 .. l_n LOOP
      l_html := l_html || '<td>' || fmt0(CASE WHEN l_coltot.EXISTS(l_keys(i)) THEN l_coltot(l_keys(i)) ELSE 0 END) || '</td>';
    END LOOP;
    RETURN l_html || '<td>' || fmt0(l_grand) || '</td><td>100%</td></tr></tfoot></table></div>';
  END analysis;

END NOONA_GL_PKG;
/
