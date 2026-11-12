SET DEFINE OFF
-- =============================================================================
-- NOONA_WRK_PKG: العاملون الميدانيون (السائقون، المندوبون، الفنيون) ومستحقاتهم
--   * العامل موظف في الموارد البشرية ويختار في وحدته (النقل، التوزيع، مراكز السيارات)
--   * المستحقات الشهرية: بدل الرحلات، عمولة المبيعات أو التحصيل أو الزيارات، عمولة الخدمات، مكافآت يدوية
--   * الصرف حسب العامل: مع الراتب (مدخل متغير في مسير الشهر) أو نقداً أو تحويلاً (سند مصروفات بالاعتماد)
-- =============================================================================
CREATE OR REPLACE PACKAGE NOONA_WRK_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- {"name","phone","nationalId","employeeNo","employment"} من ملف الموظف
  FUNCTION employee_json(p_employee_id IN NUMBER) RETURN CLOB;
  FUNCTION employee_name(p_employee_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION employment_of(p_employee_id IN NUMBER) RETURN NUMBER;
  -- p_kind: DRIVER | REP | TECH ؛ p_method: PAYROLL | CASH | BANK_TRANSFER | NONE
  PROCEDURE set_worker(p_kind IN VARCHAR2, p_id IN NUMBER, p_employee_id IN NUMBER, p_method IN VARCHAR2 DEFAULT NULL);

  -- يجمع مستحقات الشهر من الوحدات (لا يكرر ما جمع)؛ يعيد عدد الأسطر الجديدة
  FUNCTION collect(p_month IN DATE) RETURN NUMBER;
  -- {"employee","type","amount","month":"YYYY-MM-DD","method","notes","ref"}
  FUNCTION add_manual(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_method(p_id IN NUMBER, p_method IN VARCHAR2);
  PROCEDURE approve(p_id IN NUMBER);
  FUNCTION approve_month(p_month IN DATE) RETURN NUMBER;
  PROCEDURE cancel(p_id IN NUMBER, p_reason IN VARCHAR2 DEFAULT NULL);
  -- يرحل المعتمد: مع الراتب إلى مسير الشهر، والنقدي والتحويل في سند مصروفات لكل عامل (يعتمده المالي)
  FUNCTION settle(p_month IN DATE, p_place IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- يحدث المصروف نقداً بعد اعتماد سنده
  FUNCTION sync_paid RETURN NUMBER;
  FUNCTION summary_html(p_month IN DATE) RETURN CLOB;
  FUNCTION unlinked_html RETURN CLOB;
  FUNCTION type_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION method_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2;
END NOONA_WRK_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_WRK_PKG AS

  FUNCTION company RETURN NUMBER IS BEGIN RETURN NOONA_CTX_PKG.company_id; END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  PROCEDURE guard(p VARCHAR2) IS BEGIN NOONA_SECURITY_PKG.assert_permission(p, company); END guard;
  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jn(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN p_o.get_number(p_k) END;
  EXCEPTION WHEN OTHERS THEN RETURN TO_NUMBER(REPLACE(p_o.get_string(p_k), ',', ''));
  END jn;

  FUNCTION type_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'TRIP_ALLOWANCE' THEN 'بدل رحلات' WHEN 'SALES_COMMISSION' THEN 'عمولة مبيعات'
      WHEN 'COLLECTION_COMMISSION' THEN 'عمولة تحصيل' WHEN 'VISIT_COMMISSION' THEN 'عمولة زيارات' WHEN 'SERVICE_COMMISSION' THEN 'عمولة خدمات'
      WHEN 'BONUS' THEN 'مكافأة' WHEN 'OTHER' THEN 'أخرى' ELSE p_code END;
  END type_label;

  FUNCTION method_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'PAYROLL' THEN 'مع الراتب' WHEN 'CASH' THEN 'نقداً' WHEN 'BANK_TRANSFER' THEN 'تحويل بنكي'
      WHEN 'NONE' THEN 'لا يستحق' ELSE p_code END;
  END method_label;

  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p_code IN ('PAID', 'IN_PAYROLL') THEN 'is-success' WHEN p_code IN ('PENDING') THEN 'is-warning'
                                             WHEN p_code = 'CANCELLED' THEN 'is-danger' ELSE 'is-info' END || '">'
        || CASE p_code WHEN 'PENDING' THEN 'بانتظار الاعتماد' WHEN 'APPROVED' THEN 'معتمد' WHEN 'IN_PAYROLL' THEN 'في مسير الرواتب'
                       WHEN 'IN_VOUCHER' THEN 'في سند صرف' WHEN 'PAID' THEN 'مصروف' WHEN 'CANCELLED' THEN 'ملغى' ELSE p_code END || '</span>';
  END badge;

  -- ================================================================ الموظف
  FUNCTION employment_of(p_employee_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK LAST ORDER BY start_date) INTO l FROM hr_employment
     WHERE employee_id = p_employee_id AND company_id = company AND status_code IN ('ACTIVE', 'NOTICE_PERIOD');
    RETURN l;
  END employment_of;

  FUNCTION employee_name(p_employee_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(p.display_name_ar) INTO l FROM hr_employee e JOIN pty_party p ON p.id = e.person_party_id WHERE e.id = p_employee_id;
    RETURN l;
  END employee_name;

  FUNCTION employee_json(p_employee_id IN NUMBER) RETURN CLOB IS
    l JSON_OBJECT_T := JSON_OBJECT_T();
  BEGIN
    FOR e IN (SELECT e.employee_no, e.work_mobile, e.national_id, p.display_name_ar nm FROM hr_employee e JOIN pty_party p ON p.id = e.person_party_id
               WHERE e.id = p_employee_id) LOOP
      l.put('name', e.nm); l.put('phone', e.work_mobile); l.put('nationalId', e.national_id); l.put('employeeNo', e.employee_no);
      l.put('employment', employment_of(p_employee_id));
    END LOOP;
    RETURN l.to_clob;
  END employee_json;

  PROCEDURE set_worker(p_kind IN VARCHAR2, p_id IN NUMBER, p_employee_id IN NUMBER, p_method IN VARCHAR2 DEFAULT NULL) IS
    l_x NUMBER;
    l_m VARCHAR2(30) := NVL(p_method, 'PAYROLL');
  BEGIN
    NOONA_CORE_PKG.assert(l_m IN ('PAYROLL', 'CASH', 'BANK_TRANSFER', 'NONE'), 'NOONA-WRK-001', 'طريقة صرف المستحقات غير صحيحة', 'Invalid method');
    IF p_employee_id IS NOT NULL THEN
      NOONA_CORE_PKG.assert(employment_of(p_employee_id) IS NOT NULL, 'NOONA-WRK-002',
        'الموظف ليس على رأس العمل في هذه الشركة (راجع علاقة التوظيف في الموارد البشرية)', 'Employee has no active employment');
    END IF;
    IF p_kind = 'DRIVER' THEN
      guard('TRN_DRIVER.UPDATE');
      IF p_employee_id IS NOT NULL THEN
        SELECT COUNT(*) INTO l_x FROM trn_driver WHERE company_id = company AND employee_id = p_employee_id AND id <> p_id;
        NOONA_CORE_PKG.assert(l_x = 0, 'NOONA-WRK-005', 'الموظف مربوط بسائق آخر', 'Employee linked to another driver');
      END IF;
      UPDATE trn_driver SET employee_id = p_employee_id, earnings_method = l_m WHERE id = p_id AND company_id = company;
    ELSIF p_kind = 'REP' THEN
      guard('DST_REP.UPDATE');
      IF p_employee_id IS NOT NULL THEN
        SELECT COUNT(*) INTO l_x FROM dst_rep WHERE company_id = company AND employee_id = p_employee_id AND id <> p_id;
        NOONA_CORE_PKG.assert(l_x = 0, 'NOONA-WRK-005', 'الموظف مربوط بمندوب آخر', 'Employee linked to another rep');
      END IF;
      UPDATE dst_rep SET employee_id = p_employee_id, earnings_method = l_m WHERE id = p_id AND company_id = company;
    ELSIF p_kind = 'TECH' THEN
      guard('AUT_TECHNICIAN.UPDATE');
      IF p_employee_id IS NOT NULL THEN
        SELECT COUNT(*) INTO l_x FROM aut_technician WHERE company_id = company AND employee_id = p_employee_id AND id <> p_id;
        NOONA_CORE_PKG.assert(l_x = 0, 'NOONA-WRK-005', 'الموظف مربوط بفني آخر', 'Employee linked to another technician');
      END IF;
      UPDATE aut_technician SET employee_id = p_employee_id, earnings_method = l_m WHERE id = p_id AND company_id = company;
    ELSE
      NOONA_CORE_PKG.raise_error('NOONA-WRK-006', 'نوع العامل غير صحيح', 'Invalid worker kind');
    END IF;
  END set_worker;

  -- ================================================================ جمع المستحقات
  FUNCTION put(p_emp NUMBER, p_mod VARCHAR2, p_type VARCHAR2, p_month DATE, p_ent VARCHAR2, p_ent_id NUMBER, p_ref VARCHAR2,
               p_base NUMBER, p_amt NUMBER, p_method VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF NVL(p_amt, 0) <= 0 OR p_emp IS NULL OR NVL(p_method, 'PAYROLL') = 'NONE' THEN RETURN 0; END IF;
    INSERT INTO pay_field_earning (company_id, employee_id, employment_id, source_module, earning_type, period_month, source_entity_type,
                                   source_entity_id, source_ref, base_amount, amount, pay_method, status_code)
    VALUES (company, p_emp, employment_of(p_emp), p_mod, p_type, p_month, p_ent, p_ent_id, SUBSTR(p_ref, 1, 200), p_base, ROUND(p_amt, 2),
            NVL(p_method, 'PAYROLL'), 'PENDING');
    RETURN 1;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    -- يعاد الحساب لما لم يعتمد بعد (تصحيح عمولة الشهر مثلاً)
    UPDATE pay_field_earning SET amount = ROUND(p_amt, 2), base_amount = p_base
     WHERE company_id = company AND source_entity_type = p_ent AND source_entity_id = p_ent_id AND earning_type = p_type
       AND period_month = p_month AND status_code = 'PENDING';
    RETURN 0;
  END put;

  FUNCTION collect(p_month IN DATE) RETURN NUMBER IS
    l_m  DATE := TRUNC(NVL(p_month, SYSDATE), 'MM');
    l_e  DATE := ADD_MONTHS(TRUNC(NVL(p_month, SYSDATE), 'MM'), 1);
    l_n  NUMBER := 0;
    l_x  NUMBER;
  BEGIN
    guard('PAY_INPUT.CREATE');
    -- التوزيع: عمولات الشهر المحسوبة في وحدة التوزيع
    BEGIN l_x := NOONA_DST_PKG.calc_commissions(l_m); EXCEPTION WHEN OTHERS THEN NULL; END;
    FOR c IN (SELECT c.id, c.rep_id, c.basis, c.base_amount, c.commission_amount, r.employee_id, r.earnings_method, r.full_name
                FROM dst_commission c JOIN dst_rep r ON r.id = c.rep_id
               WHERE c.company_id = company AND c.period_start = l_m AND c.commission_amount > 0 AND r.employee_id IS NOT NULL) LOOP
      l_n := l_n + put(c.employee_id, 'DST', CASE c.basis WHEN 'COLLECTION' THEN 'COLLECTION_COMMISSION' WHEN 'VISIT' THEN 'VISIT_COMMISSION'
                       ELSE 'SALES_COMMISSION' END, l_m, 'DST_COMMISSION', c.id, 'عمولة ' || TO_CHAR(l_m, 'YYYY-MM') || ' - ' || c.full_name,
                       c.base_amount, c.commission_amount, c.earnings_method);
    END LOOP;
    -- النقل: بدل الرحلة لكل رحلة مقفلة في الشهر لم يسجل لها بدل سائق في مصروفاتها
    FOR t IN (SELECT t.id, t.doc_no, d.employee_id, d.earnings_method, d.trip_allowance
                FROM trn_trip t JOIN trn_driver d ON d.id = t.driver_id
               WHERE t.company_id = company AND t.status_code = 'COMPLETED' AND d.employee_id IS NOT NULL AND NVL(d.trip_allowance, 0) > 0
                 AND CAST(NVL(t.actual_arrival, t.updated_at) AS DATE) >= l_m AND CAST(NVL(t.actual_arrival, t.updated_at) AS DATE) < l_e
                 AND NOT EXISTS (SELECT 1 FROM trn_trip_expense x WHERE x.trip_id = t.id AND x.expense_type = 'DRIVER_ALLOWANCE')) LOOP
      l_n := l_n + put(t.employee_id, 'TRN', 'TRIP_ALLOWANCE', l_m, 'TRN_TRIP', t.id, 'بدل الرحلة ' || t.doc_no, NULL, t.trip_allowance, t.earnings_method);
    END LOOP;
    -- مراكز السيارات: نسبة الفني من صافي الخدمات المنجزة في أوامر مفوترة أو مسلمة خلال الشهر
    FOR k IN (SELECT tc.id, tc.employee_id, tc.earnings_method, tc.commission_pct, tc.name_ar, SUM(NVL(l.net_amount, 0)) base
                FROM aut_job_line l JOIN aut_job_card j ON j.id = l.job_card_id JOIN aut_technician tc ON tc.id = l.technician_id
               WHERE j.company_id = company AND j.status_code IN ('INVOICED', 'DELIVERED') AND l.line_type IN ('SERVICE', 'SUBLET')
                 AND l.line_status = 'DONE' AND NVL(tc.commission_pct, 0) > 0 AND tc.employee_id IS NOT NULL
                 AND CAST(l.done_at AS DATE) >= l_m AND CAST(l.done_at AS DATE) < l_e
               GROUP BY tc.id, tc.employee_id, tc.earnings_method, tc.commission_pct, tc.name_ar) LOOP
      l_n := l_n + put(k.employee_id, 'AUT', 'SERVICE_COMMISSION', l_m, 'AUT_TECHNICIAN', k.id,
                       'عمولة خدمات ' || TO_CHAR(l_m, 'YYYY-MM') || ' - ' || k.name_ar, k.base, k.base * k.commission_pct / 100, k.earnings_method);
    END LOOP;
    RETURN l_n;
  END collect;

  FUNCTION add_manual(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_emp NUMBER := jn(l_o, 'employee');
    l_tp  VARCHAR2(30) := NVL(js(l_o, 'type'), 'BONUS');
    l_amt NUMBER := jn(l_o, 'amount');
    l_mo  DATE := TRUNC(NVL(TO_DATE(SUBSTR(js(l_o, 'month'), 1, 10), 'YYYY-MM-DD'), SYSDATE), 'MM');
    l_me  VARCHAR2(30) := NVL(js(l_o, 'method'), 'PAYROLL');
    l_ref VARCHAR2(200) := js(l_o, 'ref');
    l_nt  VARCHAR2(4000) := js(l_o, 'notes');
    l_em  NUMBER;
    l_id  NUMBER;
  BEGIN
    guard('PAY_INPUT.CREATE');
    NOONA_CORE_PKG.assert(l_emp IS NOT NULL AND NVL(l_amt, 0) > 0, 'NOONA-WRK-010', 'اختر الموظف وأدخل المبلغ', 'Employee and amount required');
    NOONA_CORE_PKG.assert(l_me IN ('PAYROLL', 'CASH', 'BANK_TRANSFER'), 'NOONA-WRK-001', 'طريقة الصرف غير صحيحة', 'Invalid method');
    l_em := employment_of(l_emp);
    NOONA_CORE_PKG.assert(l_em IS NOT NULL, 'NOONA-WRK-002', 'الموظف ليس على رأس العمل في هذه الشركة', 'No active employment');
    INSERT INTO pay_field_earning (company_id, employee_id, employment_id, source_module, earning_type, period_month, source_ref, amount,
                                   pay_method, notes, status_code)
    VALUES (company, l_emp, l_em, 'OTHER', l_tp, l_mo, l_ref, ROUND(l_amt, 2), l_me, l_nt, 'PENDING')
    RETURNING id INTO l_id;
    RETURN l_id;
  END add_manual;

  PROCEDURE set_method(p_id IN NUMBER, p_method IN VARCHAR2) IS
  BEGIN
    guard('PAY_INPUT.UPDATE');
    NOONA_CORE_PKG.assert(p_method IN ('PAYROLL', 'CASH', 'BANK_TRANSFER'), 'NOONA-WRK-001', 'طريقة الصرف غير صحيحة', 'Invalid method');
    UPDATE pay_field_earning SET pay_method = p_method WHERE id = p_id AND company_id = company AND status_code IN ('PENDING', 'APPROVED');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-WRK-011', 'لا يمكن تغيير طريقة صرف مستحق مرحل', 'Already settled');
  END set_method;

  PROCEDURE approve(p_id IN NUMBER) IS
  BEGIN
    guard('PAY_INPUT.UPDATE');
    UPDATE pay_field_earning SET status_code = 'APPROVED', approved_by = NOONA_CTX_PKG.current_user_name, approved_at = SYSTIMESTAMP
     WHERE id = p_id AND company_id = company AND status_code = 'PENDING';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-WRK-012', 'المستحق ليس بانتظار الاعتماد', 'Not pending');
  END approve;

  FUNCTION approve_month(p_month IN DATE) RETURN NUMBER IS
  BEGIN
    guard('PAY_INPUT.UPDATE');
    UPDATE pay_field_earning SET status_code = 'APPROVED', approved_by = NOONA_CTX_PKG.current_user_name, approved_at = SYSTIMESTAMP
     WHERE company_id = company AND period_month = TRUNC(p_month, 'MM') AND status_code = 'PENDING';
    RETURN SQL%ROWCOUNT;
  END approve_month;

  PROCEDURE cancel(p_id IN NUMBER, p_reason IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    guard('PAY_INPUT.UPDATE');
    UPDATE pay_field_earning SET status_code = 'CANCELLED', notes = SUBSTR(TRIM(notes || ' ' || p_reason), 1, 4000)
     WHERE id = p_id AND company_id = company AND status_code IN ('PENDING', 'APPROVED');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-WRK-013', 'لا يلغى مستحق مرحل (يعدل من المسير أو السند)', 'Already settled');
  END cancel;

  -- ================================================================ الصرف
  -- حساب المصروف: بدلات الرحلات 5217، العمولات 5301، المكافآت 5201 (ينشأ الحساب إن لم يوجد)
  FUNCTION expense_account(p_type VARCHAR2) RETURN VARCHAR2 IS
    l_code VARCHAR2(10) := CASE WHEN p_type = 'TRIP_ALLOWANCE' THEN '5217' WHEN p_type IN ('BONUS', 'OTHER') THEN '5201' ELSE '5301' END;
    l_id   NUMBER;
  BEGIN
    SELECT MIN(id) INTO l_id FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = l_code;
    IF l_id IS NULL THEN
      l_id := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, l_code,
                CASE l_code WHEN '5217' THEN 'بدلات رحلات السائقين' WHEN '5301' THEN 'عمولات المندوبين والعاملين' ELSE 'الرواتب والأجور' END,
                SUBSTR(l_code, 1, 2), 'EXPENSE', 'Y', NULL);
    END IF;
    RETURN l_code;
  EXCEPTION WHEN OTHERS THEN
    RETURN '5201';
  END expense_account;

  FUNCTION settle(p_month IN DATE, p_place IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_m   DATE := TRUNC(p_month, 'MM');
    l_per NUMBER;
    l_in  NUMBER;
    l_n   NUMBER := 0;
    l_doc JSON_OBJECT_T;
    l_ln  JSON_ARRAY_T;
    l_x   JSON_OBJECT_T;
    l_v   NUMBER;
    l_place VARCHAR2(50);
  BEGIN
    guard('PAY_INPUT.CREATE');
    -- مع الراتب: مدخل متغير في فترة الشهر (عمولة أو بدلات أخرى)
    FOR e IN (SELECT * FROM pay_field_earning WHERE company_id = company AND period_month = l_m AND status_code = 'APPROVED'
                 AND pay_method = 'PAYROLL' ORDER BY id) LOOP
      NOONA_CORE_PKG.assert(e.employment_id IS NOT NULL, 'NOONA-WRK-020', 'لا توجد علاقة توظيف نشطة للموظف ' || employee_name(e.employee_id),
                            'No employment');
      l_per := NOONA_PAY_PKG.period_for(LAST_DAY(l_m));
      NOONA_CORE_PKG.assert(l_per IS NOT NULL, 'NOONA-WRK-021', 'جهز الرواتب وفتراتها أولاً (الموارد البشرية ← الرواتب)', 'Payroll not ready');
      l_in := NOONA_PAY_PKG.add_input(l_per, e.employment_id,
                                      CASE WHEN e.earning_type IN ('TRIP_ALLOWANCE', 'OTHER') THEN 'OTHER_ALLOW'
                                           WHEN e.earning_type = 'BONUS' THEN 'BONUS' ELSE 'COMMISSION' END, NULL, e.amount);
      UPDATE pay_input SET source_entity_type = 'PAY_FIELD_EARNING', source_entity_id = e.id WHERE id = l_in;
      UPDATE pay_field_earning SET status_code = 'IN_PAYROLL', pay_input_id = l_in WHERE id = e.id;
      l_n := l_n + 1;
    END LOOP;
    -- نقداً أو تحويلاً: سند مصروفات لكل عامل وطريقة، يرسل للاعتماد المالي
    FOR g IN (SELECT employee_id, pay_method, SUM(amount) amt, COUNT(*) cnt FROM pay_field_earning
               WHERE company_id = company AND period_month = l_m AND status_code = 'APPROVED' AND pay_method IN ('CASH', 'BANK_TRANSFER')
               GROUP BY employee_id, pay_method) LOOP
      l_place := p_place;
      IF l_place IS NULL OR (g.pay_method = 'CASH' AND l_place NOT LIKE 'BOX:%') OR (g.pay_method = 'BANK_TRANSFER' AND l_place NOT LIKE 'BANK:%') THEN
        IF g.pay_method = 'CASH' THEN
          SELECT 'BOX:' || MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(box_type, 'MAIN', 0, 1), id) INTO l_place
            FROM csh_cash_box WHERE company_id = company AND status_code = 'ACTIVE' AND box_type IN ('MAIN', 'PETTY_CASH');
        ELSE
          SELECT 'BANK:' || MIN(id) INTO l_place FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE';
        END IF;
      END IF;
      NOONA_CORE_PKG.assert(l_place NOT IN ('BOX:', 'BANK:'), 'NOONA-WRK-022', 'لا يوجد صندوق أو حساب بنكي للصرف', 'No cash box or bank account');
      l_ln := JSON_ARRAY_T();
      FOR e IN (SELECT earning_type, SUM(amount) amt, LISTAGG(source_ref, '، ') WITHIN GROUP (ORDER BY id) refs FROM pay_field_earning
                 WHERE company_id = company AND period_month = l_m AND status_code = 'APPROVED' AND employee_id = g.employee_id
                   AND pay_method = g.pay_method GROUP BY earning_type) LOOP
        l_x := JSON_OBJECT_T(); l_x.put('a', expense_account(e.earning_type)); l_x.put('m', ROUND(e.amt, 2));
        l_x.put('t', SUBSTR(type_label(e.earning_type) || ' ' || TO_CHAR(l_m, 'YYYY-MM') || ' - ' || e.refs, 1, 400));
        l_ln.append(l_x);
      END LOOP;
      l_doc := JSON_OBJECT_T();
      l_doc.put('type', 'EXPENSE'); l_doc.put('date', TO_CHAR(SYSDATE, 'YYYY-MM-DD')); l_doc.put('place', l_place);
      l_doc.put('channel', CASE g.pay_method WHEN 'CASH' THEN 'CASH' ELSE 'BANK_TRANSFER' END);
      l_doc.put('party', employee_name(g.employee_id));
      l_doc.put('desc', 'مستحقات ' || TO_CHAR(l_m, 'YYYY-MM') || ' - ' || employee_name(g.employee_id) || ' (' || g.cnt || ' بند)');
      l_doc.put('ref', 'WRK-' || TO_CHAR(l_m, 'YYYYMM') || '-' || g.employee_id);
      l_doc.put('action', 'SUBMIT'); l_doc.put('lines', l_ln);
      l_v := NOONA_CSH_PKG.save_voucher_doc(l_doc.to_clob);
      UPDATE pay_field_earning SET status_code = 'IN_VOUCHER', cash_txn_id = l_v
       WHERE company_id = company AND period_month = l_m AND status_code = 'APPROVED' AND employee_id = g.employee_id AND pay_method = g.pay_method;
      l_n := l_n + g.cnt;
    END LOOP;
    RETURN l_n;
  END settle;

  FUNCTION sync_paid RETURN NUMBER IS
  BEGIN
    UPDATE pay_field_earning e SET status_code = 'PAID',
           paid_at = (SELECT NVL(t.updated_at, SYSTIMESTAMP) FROM csh_transaction t WHERE t.id = e.cash_txn_id)
     WHERE e.company_id = company AND e.status_code = 'IN_VOUCHER'
       AND EXISTS (SELECT 1 FROM csh_transaction t WHERE t.id = e.cash_txn_id AND t.status_code IN ('APPROVED', 'SETTLED'));
    RETURN SQL%ROWCOUNT;
  END sync_paid;

  -- ================================================================ التقارير
  FUNCTION summary_html(p_month IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_t NUMBER := 0;
  BEGIN
    FOR r IN (SELECT employee_id, pay_method,
                     SUM(CASE WHEN earning_type = 'TRIP_ALLOWANCE' THEN amount ELSE 0 END) trip,
                     SUM(CASE WHEN earning_type LIKE '%COMMISSION' THEN amount ELSE 0 END) comm,
                     SUM(CASE WHEN earning_type IN ('BONUS', 'OTHER') THEN amount ELSE 0 END) other,
                     SUM(amount) total, MIN(status_code) KEEP (DENSE_RANK FIRST ORDER BY DECODE(status_code, 'PENDING', 0, 'APPROVED', 1, 2)) st
                FROM pay_field_earning WHERE company_id = company AND period_month = TRUNC(p_month, 'MM') AND status_code <> 'CANCELLED'
               GROUP BY employee_id, pay_method ORDER BY 6 DESC) LOOP
      l_t := l_t + r.total;
      l_h := l_h || '<tr><td>' || esc(employee_name(r.employee_id)) || '</td><td>' || method_label(r.pay_method) || '</td><td>' || fmt(r.trip)
          || '</td><td>' || fmt(r.comm) || '</td><td>' || fmt(r.other) || '</td><td><b>' || fmt(r.total) || '</b></td><td>' || badge(r.st) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا مستحقات لهذا الشهر بعد؛ اضغط «جمع المستحقات».</p>'
           ELSE '<table class="nn-table"><thead><tr><th>الموظف</th><th>الصرف</th><th>بدل الرحلات</th><th>العمولات</th><th>أخرى</th><th>الإجمالي</th>'
             || '<th>الحالة</th></tr></thead><tbody>' || l_h || '</tbody><tfoot><tr><th colspan="5">الإجمالي</th><th>' || fmt(l_t)
             || '</th><th></th></tr></tfoot></table>' END;
  END summary_html;

  FUNCTION unlinked_html RETURN CLOB IS
    l_h CLOB;
  BEGIN
    FOR r IN (SELECT 'سائق' k, full_name n FROM trn_driver WHERE company_id = company AND employee_id IS NULL AND status_code <> 'LEFT'
              UNION ALL SELECT 'مندوب', full_name FROM dst_rep WHERE company_id = company AND employee_id IS NULL AND status_code = 'ACTIVE'
              UNION ALL SELECT 'فني', name_ar FROM aut_technician WHERE company_id = company AND employee_id IS NULL AND is_active = 'Y') LOOP
      l_h := l_h || '<span class="nn-badge is-warning">' || r.k || ': ' || esc(r.n) || '</span> ';
    END LOOP;
    RETURN CASE WHEN l_h IS NOT NULL THEN '<p class="nn-hint">عاملون غير مربوطين بموظف في الموارد البشرية (لا تحسب مستحقاتهم حتى يربطوا من شاشاتهم): </p><p>'
                || l_h || '</p>' END;
  END unlinked_html;

END NOONA_WRK_PKG;
/
