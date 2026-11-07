-- =============================================================================
-- NOONA PLUS ERP | NOONA_FIN_RPT_PKG - تقارير المالية (قراءة فقط)
--   * الأستاذ: دفتر الأستاذ لمدى حسابات، يومية القيود (المرحلة/غير المرحلة/المعكوسة)، عرض القيد ومستند مصدره
--   * القوائم: التدفقات النقدية (الطريقة المباشرة)، التغيرات في حقوق الملكية
--   * التحليل: مقارنة فترتين، النسب المالية
--   * الرقابة: مطابقة الأستاذ مع الأرصدة والنقدية، مستندات دون قيد، آثار مكررة، حالة الإقفال
--   * التدقيق: سجل إنشاء واعتماد وترحيل وعكس المستندات، تغييرات الإعدادات، الصلاحيات الحساسة
-- كل تقرير: ترويسة الشركة، أساس الاحتساب ونطاقه ووقت الاستخراج، ومجاميع يتحقق من تطابقها مع التفاصيل.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_FIN_RPT_PKG AUTHID DEFINER AS
  -- p_link: رابط التفصيل؛ #ID# يستبدل برقم القيد
  -- p_link: رابط صفحة ملف المستند (#ID#) لمعاينة المستندات المؤرشفة
  FUNCTION journal_view(p_journal_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION general_ledger(p_from IN DATE, p_to IN DATE, p_acc_from IN VARCHAR2 DEFAULT NULL, p_acc_to IN VARCHAR2 DEFAULT NULL,
                          p_cost_center_id IN NUMBER DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- p_status: POSTED (المرحلة) / UNPOSTED (غير المرحلة) / REVERSED (المعكوسة وقيود عكسها) / ALL
  -- p_type: نوع القيد (فارغ = كل الأنواع)
  FUNCTION journal_register(p_from IN DATE, p_to IN DATE, p_status IN VARCHAR2 DEFAULT 'POSTED',
                            p_link IN VARCHAR2 DEFAULT NULL, p_type IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- ملخص القيود حسب النوع: العدد والمبالغ لكل نوع (المرحلة) مع تفصيل غير المرحلة
  FUNCTION journal_type_summary(p_from IN DATE, p_to IN DATE, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION cash_flow(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION equity_changes(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION income_compare(p_from IN DATE, p_to IN DATE, p_from2 IN DATE, p_to2 IN DATE) RETURN CLOB;
  -- قائمة الدخل لعدة سنوات: عمود لكل سنة (2 إلى 6) حتى السنة الحالية، ونمو آخر سنة عن سابقتها؛
  -- p_same_period = 'Y' يقارن الفترة نفسها من كل سنة (من يناير حتى اليوم والشهر الحاليين)
  FUNCTION income_years(p_years IN NUMBER DEFAULT 3, p_same_period IN VARCHAR2 DEFAULT 'N') RETURN CLOB;
  FUNCTION ratios(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION controls(p_as_of IN DATE DEFAULT NULL) RETURN CLOB;
  -- p_scope: ALL / GL_JOURNAL / CSH_TRANSACTION / CONFIG
  FUNCTION audit_log(p_from IN DATE, p_to IN DATE, p_scope IN VARCHAR2 DEFAULT 'ALL') RETURN CLOB;
  -- رقم تحقق للاختبارات: عدد الفحوص غير المطابقة في تقرير الرقابة
  FUNCTION control_failures RETURN NUMBER;
END NOONA_FIN_RPT_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_FIN_RPT_PKG AS

  g_fail NUMBER := 0;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;

  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL OR p = 0 THEN '' ELSE TRIM(TO_CHAR(p, 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,''')) END;
  END fmt;

  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt0;

  FUNCTION pct(p_num NUMBER, p_den NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN NVL(p_den, 0) = 0 THEN '-' ELSE TO_CHAR(ROUND(p_num * 100 / p_den, 1), 'FM999990.0') || '%' END;
  END pct;

  FUNCTION drill(p_link VARCHAR2, p_id NUMBER, p_text VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_link IS NULL OR p_id IS NULL THEN esc(p_text)
                ELSE '<a class="nn-drill" href="' || esc(REPLACE(p_link, '#ID#', p_id)) || '">' || esc(p_text) || '</a>' END;
  END drill;

  FUNCTION period_text(p_from DATE, p_to DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN ' من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD');
  END period_text;

  FUNCTION check_box(p_ok BOOLEAN, p_ok_text VARCHAR2, p_bad_text VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_ok
      THEN '<div class="nn-chain is-ok nn-rpt-check"><span class="fa fa-check-circle" aria-hidden="true"></span><div><b>' || esc(p_ok_text) || '</b></div></div>'
      ELSE '<div class="nn-chain is-bad nn-rpt-check"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span><div><b>' || esc(p_bad_text) || '</b></div></div>' END;
  END check_box;

  FUNCTION status_name(p_code VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'DRAFT' THEN 'مسودة' WHEN 'SUBMITTED' THEN 'مرسل' WHEN 'APPROVED' THEN 'معتمد غير مرحل'
                       WHEN 'POSTED' THEN 'مرحل' WHEN 'REVERSED' THEN 'معكوس' WHEN 'CANCELLED' THEN 'ملغى' ELSE p_code END;
  END status_name;

  PROCEDURE view_guard IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_BALANCE.VIEW', NOONA_GL_PKG.company);
  END view_guard;

  -- ================================================================ عرض القيد ومستند المصدر
  FUNCTION journal_view(p_journal_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_j    gl_journal%ROWTYPE;
    l_html CLOB;
    l_src  VARCHAR2(200);
    l_ev   ace_accounting_event%ROWTYPE;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_JOURNAL.VIEW', NOONA_GL_PKG.company);
    IF p_journal_id IS NULL THEN RETURN '<div class="nn-empty">اختر قيداً</div>'; END IF;
    BEGIN
      SELECT * INTO l_j FROM gl_journal WHERE id = p_journal_id AND company_id = NOONA_GL_PKG.company;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-GL-001', 'القيد غير موجود', 'Journal not found');
    END;
    SELECT name_ar INTO l_src FROM gl_journal_source WHERE id = l_j.journal_source_id;
    l_html := NOONA_GL_PKG.journal_header(p_journal_id)
           || '<table class="nn-rpt"><thead><tr><th>#</th><th>الحساب</th><th>مركز التكلفة</th><th>البيان</th><th>مدين</th><th>دائن</th></tr></thead><tbody>';
    FOR r IN (SELECT l.line_no, l.account_code_snapshot || ' - ' || a.name_ar acc, c.code || ' ' || c.name_ar cc,
                     NVL(l.description, l_j.description) txt, l.debit_func, l.credit_func
                FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id LEFT JOIN gl_cost_center c ON c.id = l.cost_center_id
               WHERE l.journal_id = p_journal_id ORDER BY l.line_no) LOOP
      l_html := l_html || (('<tr><td>' || r.line_no || '</td><td class="nn-rpt-text">' || esc(r.acc) || '</td><td class="nn-rpt-text">'
             || esc(r.cc) || '</td><td class="nn-rpt-text">' || esc(r.txt) || '</td><td>' || fmt(r.debit_func) || '</td><td>'
             || fmt(r.credit_func) || '</td></tr>'));
    END LOOP;
    l_html := l_html || (('</tbody><tfoot><tr><td colspan="4">الإجمالي</td><td>' || fmt0(l_j.total_debit_func) || '</td><td>'
           || fmt0(l_j.total_credit_func) || '</td></tr></tfoot></table>'
           || check_box(l_j.total_debit_func = l_j.total_credit_func, 'القيد متوازن', 'القيد غير متوازن')));
    -- مستند المصدر
    l_html := l_html || (('<h3 class="nn-rpt-h">مستند المصدر: ' || esc(l_src) || '</h3>'));
    IF l_j.accounting_event_id IS NOT NULL THEN
      SELECT * INTO l_ev FROM ace_accounting_event WHERE id = l_j.accounting_event_id;
      l_html := l_html || (('<div class="nn-rpt-foot"><span><b>الحدث المحاسبي:</b> ' || l_ev.id || ' - ' || esc(l_ev.idempotency_key)
             || '</span><span><b>الحالة:</b> ' || esc(status_name(l_ev.status_code)) || '</span></div>'));
      IF l_ev.source_entity_type = 'CSH_TRANSACTION' THEN
        l_html := l_html || (('<div class="nn-rpt-source">' || NOONA_CSH_PKG.voucher_print(l_ev.source_entity_id) || '</div>'));
      END IF;
    ELSIF l_j.reversal_of_id IS NOT NULL THEN
      l_html := l_html || ('<div class="nn-empty">قيد عكسي؛ المستند الأصلي هو القيد المعكوس المذكور في الأعلى</div>');
    ELSE
      l_html := l_html || (('<div class="nn-empty">قيد يومية مباشر (المستند هو القيد نفسه)</div>'));
    END IF;
    -- المستندات المؤرشفة (المرجع الورقي)
    l_html := l_html || (('<h3 class="nn-rpt-h">المستندات المؤرشفة</h3>'
           || NOONA_DMS_PKG.attachments_html(CASE WHEN l_ev.source_entity_type = 'CSH_TRANSACTION' THEN 'CSH_TRANSACTION' ELSE 'GL_JOURNAL' END,
                                             CASE WHEN l_ev.source_entity_type = 'CSH_TRANSACTION' THEN l_ev.source_entity_id ELSE p_journal_id END,
                                             p_link, 'Y')));
    -- مسار المستند
    l_html := l_html || (('<h3 class="nn-rpt-h">مسار القيد</h3><table class="nn-rpt"><thead><tr><th>الوقت</th><th>الإجراء</th>'
           || '<th>المستخدم</th><th>السبب / الملاحظة</th></tr></thead><tbody>'
           || '<tr><td>' || TO_CHAR(l_j.created_at, 'YYYY-MM-DD HH24:MI') || '</td><td class="nn-rpt-text">إنشاء</td><td>'
           || esc(l_j.created_by) || '</td><td></td></tr>'));
    FOR r IN (SELECT e.occurred_at, e.action_code, NVL(u.username, e.created_by) who, e.reason
                FROM aud_event e LEFT JOIN sec_user u ON u.id = e.actor_user_id
               WHERE e.entity_type = 'GL_JOURNAL' AND e.entity_id = p_journal_id ORDER BY e.occurred_at, e.id) LOOP
      l_html := l_html || (('<tr><td>' || TO_CHAR(r.occurred_at, 'YYYY-MM-DD HH24:MI') || '</td><td class="nn-rpt-text">'
             || esc(CASE r.action_code WHEN 'SUBMIT' THEN 'إرسال للاعتماد' WHEN 'APPROVE' THEN 'اعتماد' WHEN 'POST' THEN 'ترحيل'
                                      WHEN 'REJECT' THEN 'رفض' WHEN 'REVERSE' THEN 'عكس' WHEN 'CANCEL' THEN 'إلغاء' ELSE r.action_code END)
             || '</td><td>' || esc(r.who) || '</td><td class="nn-rpt-text">' || esc(r.reason) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody></table>' || NOONA_GL_PKG.report_footer('القيد كما هو مسجل في الدفتر')));
  END journal_view;

  -- ================================================================ دفتر الأستاذ
  FUNCTION general_ledger(p_from IN DATE, p_to IN DATE, p_acc_from IN VARCHAR2 DEFAULT NULL, p_acc_to IN VARCHAR2 DEFAULT NULL,
                          p_cost_center_id IN NUMBER DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_coa  NUMBER := NOONA_GL_PKG.primary_coa;
    l_fy   DATE := NOONA_GL_PKG.fy_start(p_from);
    l_html CLOB;
    l_bal  NUMBER;
    l_dr   NUMBER; l_cr NUMBER;
    t_dr   NUMBER := 0; t_cr NUMBER := 0;
    l_cnt  PLS_INTEGER := 0;
    l_buf  VARCHAR2(32767);
    -- السطور تتجمع في نص قصير ثم تلحق بالـ CLOB دفعة واحدة: الإلحاق بالـ CLOB لكل سطر بطيء مع آلاف الحركات
    PROCEDURE add(p_s IN VARCHAR2) IS
    BEGIN
      IF LENGTHB(l_buf) + LENGTHB(p_s) > 30000 THEN
        DBMS_LOB.WRITEAPPEND(l_html, LENGTH(l_buf), l_buf); l_buf := NULL;
      END IF;
      l_buf := l_buf || p_s;
    END add;
  BEGIN
    view_guard;
    l_html := NOONA_BRAND_PKG.report_header('دفتر الأستاذ' || period_text(p_from, p_to)
                || CASE WHEN p_acc_from IS NOT NULL OR p_acc_to IS NOT NULL
                        THEN ' - الحسابات ' || NVL(p_acc_from, 'الأول') || ' إلى ' || NVL(p_acc_to, 'الأخير') END)
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>رقم القيد</th><th>البيان</th><th>مدين</th><th>دائن</th>'
           || '<th>الرصيد</th></tr></thead><tbody>';
    FOR a IN (
      SELECT a.id, a.account_code, a.name_ar, a.account_type,
             NVL(SUM(CASE WHEN j.doc_date < p_from AND (a.account_type IN ('ASSET', 'LIABILITY', 'EQUITY') OR j.doc_date >= l_fy)
                          THEN l.debit_func - l.credit_func END), 0) opening,
             COUNT(CASE WHEN j.doc_date BETWEEN p_from AND p_to THEN 1 END) moves
        FROM gl_account a
        JOIN gl_journal_line l ON l.account_id = a.id AND (p_cost_center_id IS NULL OR l.cost_center_id = p_cost_center_id)
        JOIN gl_journal j ON j.id = l.journal_id AND j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_to
       WHERE a.coa_id = l_coa AND a.is_postable = 'Y'
         AND (p_acc_from IS NULL OR a.account_code >= p_acc_from) AND (p_acc_to IS NULL OR a.account_code <= p_acc_to)
       GROUP BY a.id, a.account_code, a.name_ar, a.account_type
      HAVING NVL(SUM(CASE WHEN j.doc_date < p_from AND (a.account_type IN ('ASSET', 'LIABILITY', 'EQUITY') OR j.doc_date >= l_fy)
                          THEN l.debit_func - l.credit_func END), 0) <> 0
          OR COUNT(CASE WHEN j.doc_date BETWEEN p_from AND p_to THEN 1 END) > 0
       ORDER BY a.account_code) LOOP
      l_cnt := l_cnt + 1;
      l_bal := a.opening; l_dr := 0; l_cr := 0;
      add('<tr class="nn-rpt-group"><td colspan="6">' || esc(a.account_code || ' - ' || a.name_ar) || '</td></tr>'
             || '<tr class="nn-rpt-head2"><td colspan="5">رصيد أول المدة</td><td>' || fmt0(l_bal) || '</td></tr>');
      FOR r IN (SELECT j.id, j.doc_date, j.doc_no, NVL(l.description, j.description) txt, l.debit_func, l.credit_func
                  FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
                 WHERE l.account_id = a.id AND j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED')
                   AND j.doc_date BETWEEN p_from AND p_to AND (p_cost_center_id IS NULL OR l.cost_center_id = p_cost_center_id)
                 ORDER BY j.doc_date, j.posted_at, j.id, l.line_no) LOOP
        l_bal := l_bal + r.debit_func - r.credit_func;
        l_dr := l_dr + r.debit_func; l_cr := l_cr + r.credit_func;
        add('<tr><td>' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') || '</td><td>' || drill(p_link, r.id, r.doc_no)
               || '</td><td class="nn-rpt-text">' || esc(r.txt) || '</td><td>' || fmt(r.debit_func) || '</td><td>' || fmt(r.credit_func)
               || '</td><td>' || fmt0(l_bal) || '</td></tr>');
      END LOOP;
      add('<tr class="nn-rpt-sub"><td colspan="3">مجموع الحركة والرصيد الختامي (موجب = مدين)</td><td>' || fmt0(l_dr)
             || '</td><td>' || fmt0(l_cr) || '</td><td>' || fmt0(l_bal) || '</td></tr>');
      t_dr := t_dr + l_dr; t_cr := t_cr + l_cr;
    END LOOP;
    IF l_cnt = 0 THEN
      add('<tr><td colspan="6" class="nn-rpt-text">لا توجد حركات في هذا النطاق</td></tr>');
    END IF;
    IF l_buf IS NOT NULL THEN
      DBMS_LOB.WRITEAPPEND(l_html, LENGTH(l_buf), l_buf);
    END IF;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="3">إجمالي حركة الحسابات المعروضة</td><td>' || fmt0(t_dr) || '</td><td>'
        || fmt0(t_cr) || '</td><td></td></tr></tfoot></table>'
        || CASE WHEN p_acc_from IS NULL AND p_acc_to IS NULL AND p_cost_center_id IS NULL
                THEN check_box(t_dr = t_cr, 'مجموع المدين = مجموع الدائن لكل حسابات الفترة', 'مجموع الحركة غير متوازن: الفرق ' || fmt0(t_dr - t_cr)) END
        || NOONA_GL_PKG.report_footer));
  END general_ledger;

  -- ================================================================ يومية القيود
  FUNCTION journal_register(p_from IN DATE, p_to IN DATE, p_status IN VARCHAR2 DEFAULT 'POSTED',
                            p_link IN VARCHAR2 DEFAULT NULL, p_type IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_html CLOB;
    t_dr   NUMBER := 0; t_cr NUMBER := 0;
    l_cnt  PLS_INTEGER := 0;
    l_st   VARCHAR2(20) := NVL(p_status, 'POSTED');
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_JOURNAL.VIEW', NOONA_GL_PKG.company);
    l_html := NOONA_BRAND_PKG.report_header('يومية القيود - ' || CASE l_st WHEN 'POSTED' THEN 'المرحلة' WHEN 'UNPOSTED' THEN 'غير المرحلة'
                WHEN 'REVERSED' THEN 'المعكوسة وقيود عكسها' ELSE 'كل القيود' END
                || CASE WHEN p_type IS NOT NULL THEN ' - ' || NOONA_GL_PKG.type_label(p_type) END || period_text(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>الحساب</th><th>اسم الحساب</th><th>مركز التكلفة</th><th>البيان</th><th>مدين</th>'
           || '<th>دائن</th></tr></thead><tbody>';
    FOR j IN (SELECT j.id, j.doc_no, j.doc_date, j.description, j.status_code, j.created_by, j.approved_by,
                     NOONA_GL_PKG.type_label(j.journal_category) src,
                     j.total_debit_func, j.total_credit_func, j.reversal_of_id, j.reversed_by_id
                FROM gl_journal j
               WHERE j.ledger_id = l_led AND j.doc_date BETWEEN p_from AND p_to
                 AND (p_type IS NULL OR j.journal_category = p_type)
                 AND ((l_st = 'POSTED' AND j.status_code IN ('POSTED', 'REVERSED'))
                   OR (l_st = 'UNPOSTED' AND j.status_code IN ('DRAFT', 'SUBMITTED', 'APPROVED'))
                   OR (l_st = 'REVERSED' AND (j.status_code = 'REVERSED' OR j.reversal_of_id IS NOT NULL))
                   OR (l_st = 'ALL' AND j.status_code <> 'CANCELLED'))
               ORDER BY j.doc_date, j.id) LOOP
      l_cnt := l_cnt + 1;
      l_html := l_html || (('<tr class="nn-rpt-group"><td colspan="6">' || drill(p_link, j.id, j.doc_no) || ' &middot; '
             || TO_CHAR(j.doc_date, 'YYYY-MM-DD') || ' &middot; ' || esc(j.description) || ' &middot; ' || esc(j.src)
             || ' &middot; ' || esc(status_name(j.status_code)) || ' &middot; ' || esc(j.created_by)
             || CASE WHEN j.approved_by IS NOT NULL THEN ' / ' || esc(j.approved_by) END || '</td></tr>'));
      FOR l IN (SELECT l.account_code_snapshot code, a.name_ar, c.code cc, l.description, l.debit_func, l.credit_func
                  FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id LEFT JOIN gl_cost_center c ON c.id = l.cost_center_id
                 WHERE l.journal_id = j.id ORDER BY l.line_no) LOOP
        l_html := l_html || (('<tr><td class="nn-num-code">' || esc(l.code) || '</td><td>' || esc(l.name_ar) || '</td><td>' || esc(l.cc)
               || '</td><td class="nn-rpt-text">' || esc(l.description) || '</td><td>' || fmt(l.debit_func) || '</td><td>'
               || fmt(l.credit_func) || '</td></tr>'));
      END LOOP;
      t_dr := t_dr + NVL(j.total_debit_func, 0); t_cr := t_cr + NVL(j.total_credit_func, 0);
    END LOOP;
    IF l_cnt = 0 THEN
      l_html := l_html || ('<tr><td colspan="6" class="nn-rpt-text">لا توجد قيود</td></tr>');
    END IF;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="4">الإجمالي (' || l_cnt || ' قيد)</td><td>' || fmt0(t_dr) || '</td><td>'
        || fmt0(t_cr) || '</td></tr></tfoot></table>'
        || check_box(t_dr = t_cr, 'مجموع المدين = مجموع الدائن', 'اليومية غير متوازنة: الفرق ' || fmt0(t_dr - t_cr))
        || NOONA_GL_PKG.report_footer(CASE l_st WHEN 'UNPOSTED' THEN 'القيود المسودة والمرسلة والمعتمدة غير المرحلة (لا تؤثر في الأرصدة)'
                                          WHEN 'ALL' THEN 'كل القيود عدا الملغاة' END)));
  END journal_register;

  FUNCTION journal_type_summary(p_from IN DATE, p_to IN DATE, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_html CLOB;
    t_n NUMBER := 0; t_dr NUMBER := 0; t_un NUMBER := 0;
    l_grp  VARCHAR2(20);
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('GL_JOURNAL.VIEW', NOONA_GL_PKG.company);
    l_html := NOONA_BRAND_PKG.report_header('القيود حسب النوع' || period_text(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>نوع القيد</th><th>المصدر</th><th>عدد المرحلة</th><th>إجمالي المبالغ المرحلة</th>'
           || '<th>منها معكوسة</th><th>غير مرحلة</th><th>تعكس آلياً ولم تعكس</th></tr></thead><tbody>';
    FOR r IN (WITH t AS (SELECT code, name_ar, type_group, sort_order,
                                ROW_NUMBER() OVER (PARTITION BY code ORDER BY tenant_id NULLS LAST) rn FROM gl_journal_type),
                   j AS (SELECT NVL(journal_category, 'GENERAL') code,
                                SUM(CASE WHEN status_code IN ('POSTED', 'REVERSED') THEN 1 ELSE 0 END) posted,
                                SUM(CASE WHEN status_code IN ('POSTED', 'REVERSED') THEN total_debit_func ELSE 0 END) amt,
                                SUM(CASE WHEN status_code = 'REVERSED' THEN 1 ELSE 0 END) reversed,
                                SUM(CASE WHEN status_code IN ('DRAFT', 'SUBMITTED', 'APPROVED') THEN 1 ELSE 0 END) unposted,
                                SUM(CASE WHEN status_code = 'POSTED' AND auto_reverse_date IS NOT NULL AND reversed_by_id IS NULL THEN 1 ELSE 0 END) due
                           FROM gl_journal WHERE ledger_id = l_led AND doc_date BETWEEN p_from AND p_to
                          GROUP BY NVL(journal_category, 'GENERAL'))
              SELECT j.code, NVL(t.name_ar, NOONA_GL_PKG.type_label(j.code)) name_ar, NVL(t.type_group, 'MANUAL') grp, j.posted, j.amt,
                     j.reversed, j.unposted, j.due
                FROM j LEFT JOIN t ON t.code = j.code AND t.rn = 1
               ORDER BY CASE NVL(t.type_group, 'MANUAL') WHEN 'MANUAL' THEN 1 ELSE 2 END, t.sort_order NULLS LAST, j.code) LOOP
      IF l_grp IS NULL OR l_grp <> r.grp THEN
        l_grp := r.grp;
        l_html := l_html || ('<tr class="nn-rpt-group"><td colspan="7">'
               || CASE r.grp WHEN 'MANUAL' THEN 'القيود اليدوية' ELSE 'القيود الآلية من المستندات' END || '</td></tr>');
      END IF;
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(r.name_ar) || '</td><td>'
             || CASE r.grp WHEN 'MANUAL' THEN 'يدوي' ELSE 'آلي' END || '</td><td>'
             || CASE WHEN p_link IS NOT NULL AND r.posted > 0
                     THEN '<a href="' || REPLACE(p_link, '#ID#', r.code) || '">' || r.posted || '</a>' ELSE TO_CHAR(r.posted) END
             || '</td><td>' || fmt(r.amt) || '</td><td>' || NULLIF(r.reversed, 0) || '</td><td>' || NULLIF(r.unposted, 0)
             || '</td><td>' || NULLIF(r.due, 0) || '</td></tr>'));
      t_n := t_n + r.posted; t_dr := t_dr + r.amt; t_un := t_un + r.unposted;
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="2">الإجمالي</td><td>' || t_n || '</td><td>' || fmt0(t_dr) || '</td><td></td><td>'
        || NULLIF(t_un, 0) || '</td><td></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('حسب تاريخ القيد؛ المبالغ بالعملة الوظيفية (المدين = الدائن لكل قيد)')));
  END journal_type_summary;

  -- ================================================================ التدفقات النقدية (الطريقة المباشرة)
  -- كل قيد يمس حسابات النقدية: سطوره غير النقدية تمثل مصدر التدفق (دائن - مدين)، وتصنف حسب الحساب المقابل
  FUNCTION cash_flow(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_coa  NUMBER := NOONA_GL_PKG.primary_coa;
    l_html CLOB;
    l_open NUMBER; l_close NUMBER;
    l_cat  VARCHAR2(20);
    l_sub  NUMBER := 0;
    l_net  NUMBER := 0;
    PROCEDURE close_cat IS
    BEGIN
      IF l_cat IS NOT NULL THEN
        l_html := l_html || (('<tr class="nn-rpt-total"><td colspan="2">صافي التدفق من الأنشطة ' || CASE l_cat WHEN 'OPERATING' THEN 'التشغيلية'
                  WHEN 'INVESTING' THEN 'الاستثمارية' ELSE 'التمويلية' END || '</td><td>' || fmt0(l_sub) || '</td></tr>'));
      END IF;
    END close_cat;
  BEGIN
    view_guard;
    SELECT NVL(SUM(CASE WHEN j.doc_date < p_from THEN l.debit_func - l.credit_func END), 0), NVL(SUM(l.debit_func - l.credit_func), 0)
      INTO l_open, l_close
      FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_to
       AND a.coa_id = l_coa AND a.subledger_code = 'CASH';
    l_html := NOONA_BRAND_PKG.report_header('قائمة التدفقات النقدية (الطريقة المباشرة)' || period_text(p_from, p_to))
           || '<table class="nn-rpt nn-rpt-fs"><thead><tr><th>الحساب المقابل</th><th>البيان</th><th>المبلغ</th></tr></thead><tbody>';
    -- الترتيب: التشغيلية ثم الاستثمارية ثم التمويلية
    FOR c IN (SELECT 'OPERATING' cat, 1 o FROM dual UNION ALL SELECT 'INVESTING', 2 FROM dual UNION ALL SELECT 'FINANCING', 3 FROM dual
              ORDER BY 2) LOOP
      l_cat := c.cat; l_sub := 0;
      l_html := l_html || ('<tr class="nn-rpt-group"><td colspan="3">التدفقات النقدية من الأنشطة ' || CASE c.cat WHEN 'OPERATING' THEN 'التشغيلية'
                WHEN 'INVESTING' THEN 'الاستثمارية' ELSE 'التمويلية' END || '</td></tr>');
      FOR r IN (
        WITH cj AS (
          SELECT DISTINCT j.id FROM gl_journal j JOIN gl_journal_line l ON l.journal_id = j.id JOIN gl_account a ON a.id = l.account_id
           WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date BETWEEN p_from AND p_to
             AND a.subledger_code = 'CASH'),
        x AS (
          SELECT a.account_code, a.name_ar, l.credit_func - l.debit_func amt,
                 CASE WHEN a.cash_flow_category IN ('INVESTING', 'FINANCING') THEN a.cash_flow_category
                      WHEN a.subledger_code = 'FA' OR p.account_code = '12' THEN 'INVESTING'
                      WHEN a.account_type = 'EQUITY' OR p.account_code = '22' THEN 'FINANCING'
                      ELSE 'OPERATING' END cat
            FROM cj JOIN gl_journal_line l ON l.journal_id = cj.id JOIN gl_account a ON a.id = l.account_id
            LEFT JOIN gl_account p ON p.id = a.parent_account_id
           WHERE NVL(a.subledger_code, '-') <> 'CASH')
        SELECT account_code, name_ar, SUM(amt) amt FROM x WHERE cat = c.cat
         GROUP BY account_code, name_ar HAVING SUM(amt) <> 0 ORDER BY account_code) LOOP
        l_html := l_html || (('<tr><td class="nn-num-code">' || esc(r.account_code) || '</td><td>'
               || esc(CASE WHEN r.amt > 0 THEN 'مقبوضات - ' ELSE 'مدفوعات - ' END || r.name_ar) || '</td><td>' || fmt0(r.amt) || '</td></tr>'));
        l_sub := l_sub + r.amt;
      END LOOP;
      close_cat;
      l_net := l_net + l_sub;
    END LOOP;
    l_html := l_html || (('<tr class="nn-rpt-total"><td colspan="2">صافي التغير في النقدية</td><td>' || fmt0(l_net) || '</td></tr>'
           || '<tr><td></td><td>النقدية في بداية الفترة</td><td>' || fmt0(l_open) || '</td></tr>'
           || '</tbody><tfoot><tr><td colspan="2">النقدية في نهاية الفترة</td><td>' || fmt0(l_open + l_net) || '</td></tr></tfoot></table>'));
    RETURN l_html || ((check_box(ROUND(l_open + l_net, 2) = ROUND(l_close, 2),
                               'تتطابق مع أرصدة حسابات النقدية في الأستاذ (' || fmt0(l_close) || ')',
                               'لا تتطابق مع رصيد النقدية في الأستاذ ' || fmt0(l_close))
        || NOONA_GL_PKG.report_footer('القيود المرحلة التي تمس حسابات النقدية؛ يصنف التدفق حسب الحساب المقابل')));
  END cash_flow;

  -- ================================================================ التغيرات في حقوق الملكية
  FUNCTION equity_changes(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    TYPE t_num IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_txt IS TABLE OF VARCHAR2(300) INDEX BY PLS_INTEGER;
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_coa  NUMBER := NOONA_GL_PKG.primary_coa;
    l_ids  t_num; l_names t_txt;
    l_n    PLS_INTEGER := 0;
    o t_num; inc t_num; dec t_num; cls t_num; c t_num;
    r_open NUMBER; r_profit NUMBER; r_close NUMBER;
    l_html CLOB;
    l_tot  NUMBER;
    l_assets NUMBER; l_liab NUMBER;
    FUNCTION row_html(p_label VARCHAR2, p_vals t_num, p_res NUMBER, p_class VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
      l VARCHAR2(32767);
      s NUMBER := NVL(p_res, 0);
    BEGIN
      l := '<tr' || CASE WHEN p_class IS NOT NULL THEN ' class="' || p_class || '"' END || '><td class="nn-rpt-text">' || p_label || '</td>';
      FOR i IN 1 .. l_n LOOP
        l := l || ('<td>' || fmt(p_vals(i)) || '</td>'); s := s + NVL(p_vals(i), 0);
      END LOOP;
      RETURN l || ('<td>' || fmt(p_res) || '</td><td class="nn-rpt-rowtot">' || fmt0(s) || '</td></tr>');
    END row_html;
  BEGIN
    view_guard;
    FOR a IN (SELECT a.id, a.account_code || ' ' || a.name_ar nm FROM gl_account a
               WHERE a.coa_id = l_coa AND a.account_type = 'EQUITY' AND a.is_postable = 'Y' ORDER BY a.account_code) LOOP
      l_n := l_n + 1; l_ids(l_n) := a.id; l_names(l_n) := a.nm;
      SELECT NVL(SUM(CASE WHEN j.doc_date < p_from THEN l.credit_func - l.debit_func END), 0),
             NVL(SUM(CASE WHEN j.doc_date >= p_from AND NVL(j.journal_category, '-') <> 'CLOSING' THEN l.credit_func END), 0),
             NVL(SUM(CASE WHEN j.doc_date >= p_from AND NVL(j.journal_category, '-') <> 'CLOSING' THEN -l.debit_func END), 0),
             NVL(SUM(CASE WHEN j.doc_date >= p_from AND j.journal_category = 'CLOSING' THEN l.credit_func - l.debit_func END), 0),
             NVL(SUM(l.credit_func - l.debit_func), 0)
        INTO o(l_n), inc(l_n), dec(l_n), cls(l_n), c(l_n)
        FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
       WHERE l.account_id = a.id AND j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_to;
    END LOOP;
    -- نتيجة الأعمال: المتراكم قبل الفترة (غير المقفل)، ربح الفترة، وما أقفل منها في الأرباح المبقاة
    SELECT NVL(SUM(CASE WHEN j.doc_date < p_from THEN l.credit_func - l.debit_func END), 0),
           NVL(SUM(CASE WHEN j.doc_date >= p_from AND NVL(j.journal_category, '-') <> 'CLOSING' THEN l.credit_func - l.debit_func END), 0),
           NVL(SUM(l.credit_func - l.debit_func), 0)
      INTO r_open, r_profit, r_close
      FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_to
       AND a.coa_id = l_coa AND a.account_type IN ('REVENUE', 'EXPENSE');
    l_html := NOONA_BRAND_PKG.report_header('قائمة التغيرات في حقوق الملكية' || period_text(p_from, p_to))
           || '<div class="nn-rpt-scroll" tabindex="0" role="region" aria-label="جدول التقرير"><table class="nn-rpt nn-rpt-matrix"><thead><tr><th>البيان</th>';
    FOR i IN 1 .. l_n LOOP l_html := l_html || (('<th>' || esc(l_names(i)) || '</th>')); END LOOP;
    l_html := l_html || (('<th>نتيجة الأعمال غير المقفلة</th><th>الإجمالي</th></tr></thead><tbody>'
           || row_html('الرصيد في ' || TO_CHAR(p_from, 'YYYY-MM-DD'), o, r_open, 'nn-rpt-head2')));
    DECLARE z t_num;
    BEGIN
      FOR i IN 1 .. l_n LOOP z(i) := NULL; END LOOP;
      l_html := l_html || ((row_html(CASE WHEN r_profit >= 0 THEN 'صافي ربح الفترة' ELSE 'صافي خسارة الفترة' END, z, r_profit)
             || row_html('زيادات (إيداعات وتحويلات دائنة)', inc, NULL)
             || row_html('تخفيضات (مسحوبات وتوزيعات)', dec, NULL)
             || row_html('إقفال نتيجة السنة في الأرباح المبقاة', cls, r_close - r_open - r_profit)));
    END;
    l_html := l_html || (('</tbody><tfoot>' || row_html('الرصيد في ' || TO_CHAR(p_to, 'YYYY-MM-DD'), c, r_close) || '</tfoot></table></div>'));
    l_tot := r_close;
    FOR i IN 1 .. l_n LOOP l_tot := l_tot + c(i); END LOOP;
    -- التحقق: إجمالي حقوق الملكية = الأصول - الخصوم في نهاية الفترة
    SELECT NVL(SUM(CASE WHEN a.account_type = 'ASSET' THEN l.debit_func - l.credit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type = 'LIABILITY' THEN l.credit_func - l.debit_func END), 0)
      INTO l_assets, l_liab
      FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_to AND a.coa_id = l_coa;
    RETURN l_html || ((check_box(ROUND(l_tot, 2) = ROUND(l_assets - l_liab, 2),
                               'إجمالي حقوق الملكية = الأصول - الخصوم = ' || fmt0(l_tot),
                               'لا يطابق صافي الأصول ' || fmt0(l_assets - l_liab))
        || NOONA_GL_PKG.report_footer('القيود المرحلة على حسابات حقوق الملكية ونتيجة الأعمال')));
  END equity_changes;

  -- ================================================================ مقارنة فترتين
  FUNCTION income_compare(p_from IN DATE, p_to IN DATE, p_from2 IN DATE, p_to2 IN DATE) RETURN CLOB IS
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_coa  NUMBER := NOONA_GL_PKG.primary_coa;
    l_html CLOB;
    l_type VARCHAR2(20);
    r1 NUMBER := 0; r2 NUMBER := 0; e1 NUMBER := 0; e2 NUMBER := 0;
    PROCEDURE total_row(p_label VARCHAR2, a NUMBER, b NUMBER, p_class VARCHAR2 DEFAULT 'nn-rpt-total') IS
    BEGIN
      l_html := l_html || (('<tr class="' || p_class || '"><td colspan="2">' || p_label || '</td><td>' || fmt0(a) || '</td><td>' || fmt0(b)
             || '</td><td>' || fmt0(a - b) || '</td><td>' || pct(a - b, ABS(b)) || '</td></tr>'));
    END total_row;
  BEGIN
    view_guard;
    l_html := NOONA_BRAND_PKG.report_header('قائمة الدخل المقارنة')
           || '<table class="nn-rpt"><thead><tr><th>الحساب</th><th>البيان</th><th>' || TO_CHAR(p_from, 'YYYY-MM-DD') || '<br>'
           || TO_CHAR(p_to, 'YYYY-MM-DD') || '</th><th>' || TO_CHAR(p_from2, 'YYYY-MM-DD') || '<br>' || TO_CHAR(p_to2, 'YYYY-MM-DD')
           || '</th><th>التغير</th><th>نسبة التغير</th></tr></thead><tbody>';
    FOR r IN (
      SELECT a.account_code, a.name_ar, a.account_type,
             NVL(SUM(CASE WHEN j.doc_date BETWEEN p_from AND p_to THEN l.credit_func - l.debit_func END), 0)
               * CASE a.account_type WHEN 'REVENUE' THEN 1 ELSE -1 END v1,
             NVL(SUM(CASE WHEN j.doc_date BETWEEN p_from2 AND p_to2 THEN l.credit_func - l.debit_func END), 0)
               * CASE a.account_type WHEN 'REVENUE' THEN 1 ELSE -1 END v2
        FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
       WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND NVL(j.journal_category, '-') <> 'CLOSING'
         AND a.coa_id = l_coa AND a.account_type IN ('REVENUE', 'EXPENSE')
         AND (j.doc_date BETWEEN p_from AND p_to OR j.doc_date BETWEEN p_from2 AND p_to2)
       GROUP BY a.account_code, a.name_ar, a.account_type
      HAVING SUM(CASE WHEN j.doc_date BETWEEN p_from AND p_to THEN l.credit_func - l.debit_func END) <> 0
          OR SUM(CASE WHEN j.doc_date BETWEEN p_from2 AND p_to2 THEN l.credit_func - l.debit_func END) <> 0
       ORDER BY CASE a.account_type WHEN 'REVENUE' THEN 0 ELSE 1 END, a.account_code) LOOP
      IF l_type IS NULL OR l_type <> r.account_type THEN
        IF l_type = 'REVENUE' THEN total_row('إجمالي الإيرادات', r1, r2); END IF;
        l_type := r.account_type;
        l_html := l_html || ('<tr class="nn-rpt-group"><td colspan="6">' || CASE r.account_type WHEN 'REVENUE' THEN 'الإيرادات'
                  ELSE 'التكاليف والمصروفات' END || '</td></tr>');
      END IF;
      l_html := l_html || (('<tr><td class="nn-num-code">' || esc(r.account_code) || '</td><td>' || esc(r.name_ar) || '</td><td>'
             || fmt0(r.v1) || '</td><td>' || fmt0(r.v2) || '</td><td>' || fmt0(r.v1 - r.v2) || '</td><td>' || pct(r.v1 - r.v2, ABS(r.v2)) || '</td></tr>'));
      IF r.account_type = 'REVENUE' THEN r1 := r1 + r.v1; r2 := r2 + r.v2; ELSE e1 := e1 + r.v1; e2 := e2 + r.v2; END IF;
    END LOOP;
    IF l_type = 'REVENUE' THEN total_row('إجمالي الإيرادات', r1, r2); END IF;
    total_row('إجمالي التكاليف والمصروفات', e1, e2);
    l_html := l_html || ('</tbody><tfoot>');
    total_row('صافي الربح (الخسارة)', r1 - e1, r2 - e2, 'nn-rpt-net');
    RETURN l_html || (('</tfoot></table>' || NOONA_GL_PKG.report_footer('القيود المرحلة بتاريخ القيد دون قيود إقفال السنة')));
  END income_compare;

  FUNCTION income_years(p_years IN NUMBER DEFAULT 3, p_same_period IN VARCHAR2 DEFAULT 'N') RETURN CLOB IS
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_coa  NUMBER := NOONA_GL_PKG.primary_coa;
    l_n    PLS_INTEGER := LEAST(GREATEST(NVL(TRUNC(p_years), 3), 2), 6);
    l_y    PLS_INTEGER := EXTRACT(YEAR FROM SYSDATE);
    l_y0   PLS_INTEGER := EXTRACT(YEAR FROM SYSDATE) - LEAST(GREATEST(NVL(TRUNC(p_years), 3), 2), 6) + 1;
    l_same BOOLEAN := NVL(p_same_period, 'N') = 'Y';
    l_sm   VARCHAR2(1) := CASE WHEN NVL(p_same_period, 'N') = 'Y' THEN 'Y' ELSE 'N' END;
    l_md   VARCHAR2(5) := TO_CHAR(SYSDATE, 'MM-DD');
    l_html CLOB;
    l_type VARCHAR2(20);
    TYPE t_n IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    l_r t_n; l_e t_n; l_v t_n;
    FUNCTION cells(p t_n) RETURN VARCHAR2 IS
      l VARCHAR2(4000);
    BEGIN
      FOR i IN 1 .. l_n LOOP l := l || '<td>' || fmt0(p(i)) || '</td>'; END LOOP;
      RETURN l || '<td>' || pct(p(l_n) - p(l_n - 1), ABS(p(l_n - 1))) || '</td>';
    END cells;
    PROCEDURE total_row(p_label VARCHAR2, p t_n, p_class VARCHAR2 DEFAULT 'nn-rpt-total') IS
    BEGIN
      l_html := l_html || ('<tr class="' || p_class || '"><td colspan="2">' || p_label || '</td>' || cells(p) || '</tr>');
    END total_row;
  BEGIN
    view_guard;
    FOR i IN 1 .. l_n LOOP l_r(i) := 0; l_e(i) := 0; END LOOP;
    l_html := NOONA_BRAND_PKG.report_header('قائمة الدخل لعدة سنوات'
                || CASE WHEN l_same THEN ' (من يناير حتى ' || TO_CHAR(SYSDATE, 'DD/MM') || ' من كل سنة)' END)
           || '<table class="nn-rpt"><thead><tr><th>الحساب</th><th>البيان</th>';
    FOR i IN 1 .. l_n LOOP
      l_html := l_html || '<th>' || (l_y0 + i - 1) || CASE WHEN l_y0 + i - 1 = l_y AND NOT l_same THEN '<br><small>حتى تاريخه</small>' END || '</th>';
    END LOOP;
    l_html := l_html || '<th>نمو ' || l_y || ' عن ' || (l_y - 1) || '</th></tr></thead><tbody>';
    -- صف لكل حساب بأعمدة السنوات
    FOR a IN (
      SELECT a.account_code, a.name_ar, a.account_type
        FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
       WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND NVL(j.journal_category, '-') <> 'CLOSING'
         AND a.coa_id = l_coa AND a.account_type IN ('REVENUE', 'EXPENSE')
         AND j.doc_date >= TO_DATE(l_y0 || '-01-01', 'YYYY-MM-DD') AND j.doc_date < TO_DATE((l_y + 1) || '-01-01', 'YYYY-MM-DD')
       GROUP BY a.account_code, a.name_ar, a.account_type
       ORDER BY CASE a.account_type WHEN 'REVENUE' THEN 0 ELSE 1 END, a.account_code) LOOP
      FOR i IN 1 .. l_n LOOP
        SELECT NVL(SUM(l.credit_func - l.debit_func), 0) * CASE a.account_type WHEN 'REVENUE' THEN 1 ELSE -1 END INTO l_v(i)
          FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account x ON x.id = l.account_id
         WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND NVL(j.journal_category, '-') <> 'CLOSING'
           AND x.coa_id = l_coa AND x.account_code = a.account_code
           AND j.doc_date >= TO_DATE((l_y0 + i - 1) || '-01-01', 'YYYY-MM-DD')
           AND j.doc_date < CASE WHEN l_sm = 'Y' THEN ADD_MONTHS(TRUNC(SYSDATE), -12 * (l_n - i)) + 1
                                 ELSE TO_DATE((l_y0 + i) || '-01-01', 'YYYY-MM-DD') END;
      END LOOP;
      CONTINUE WHEN l_v.COUNT = 0;
      IF l_type IS NULL OR l_type <> a.account_type THEN
        IF l_type = 'REVENUE' THEN total_row('إجمالي الإيرادات', l_r); END IF;
        l_type := a.account_type;
        l_html := l_html || ('<tr class="nn-rpt-group"><td colspan="' || (l_n + 3) || '">' || CASE a.account_type WHEN 'REVENUE' THEN 'الإيرادات'
                  ELSE 'التكاليف والمصروفات' END || '</td></tr>');
      END IF;
      l_html := l_html || ('<tr><td class="nn-num-code">' || esc(a.account_code) || '</td><td>' || esc(a.name_ar) || '</td>' || cells(l_v) || '</tr>');
      FOR i IN 1 .. l_n LOOP
        IF a.account_type = 'REVENUE' THEN l_r(i) := l_r(i) + l_v(i); ELSE l_e(i) := l_e(i) + l_v(i); END IF;
      END LOOP;
    END LOOP;
    IF l_type = 'REVENUE' THEN total_row('إجمالي الإيرادات', l_r); END IF;
    total_row('إجمالي التكاليف والمصروفات', l_e);
    FOR i IN 1 .. l_n LOOP l_v(i) := l_r(i) - l_e(i); END LOOP;
    l_html := l_html || '</tbody><tfoot>';
    total_row('صافي الربح (الخسارة)', l_v, 'nn-rpt-net');
    FOR i IN 1 .. l_n LOOP l_v(i) := CASE WHEN l_r(i) <> 0 THEN ROUND((l_r(i) - l_e(i)) / l_r(i) * 100, 1) END; END LOOP;
    l_html := l_html || '<tr class="nn-rpt-total"><td colspan="2">هامش صافي الربح %</td>';
    FOR i IN 1 .. l_n LOOP l_html := l_html || '<td>' || CASE WHEN l_v(i) IS NULL THEN '-' ELSE TO_CHAR(l_v(i), 'FM9990.0') || '%' END || '</td>'; END LOOP;
    l_html := l_html || '<td></td></tr>';
    RETURN l_html || (('</tfoot></table>' || NOONA_GL_PKG.report_footer('القيود المرحلة بتاريخ القيد دون قيود إقفال السنة؛ السنوات السابقة تفتح من «فتح السنة السابقة»')));
  END income_years;

  -- ================================================================ النسب المالية
  FUNCTION ratios(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_led NUMBER := NOONA_GL_PKG.primary_ledger;
    l_coa NUMBER := NOONA_GL_PKG.primary_coa;
    ca NUMBER; nca NUMBER; cl NUMBER; ncl NUMBER; inv NUMBER; cash NUMBER; eq NUMBER; pl_all NUMBER;
    rev NUMBER; cogs NUMBER; exp NUMBER; np NUMBER; ta NUMBER; tl NUMBER; te NUMBER;
    l_html CLOB;
    FUNCTION ratio(a NUMBER, b NUMBER) RETURN VARCHAR2 IS
    BEGIN
      RETURN CASE WHEN NVL(b, 0) = 0 THEN '-' ELSE TO_CHAR(ROUND(a / b, 2), 'FM999990.00') END;
    END ratio;
    FUNCTION r(p_group VARCHAR2, p_name VARCHAR2, p_formula VARCHAR2, p_value VARCHAR2, p_hint VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN '<tr><td class="nn-rpt-text">' || p_group || '</td><td class="nn-rpt-text"><b>' || p_name || '</b></td><td class="nn-rpt-text">'
          || p_formula || '</td><td><b>' || p_value || '</b></td><td class="nn-rpt-text">' || p_hint || '</td></tr>';
    END r;
  BEGIN
    view_guard;
    SELECT NVL(SUM(CASE WHEN a.account_type = 'ASSET' AND p.account_code = '11' THEN l.debit_func - l.credit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type = 'ASSET' AND NVL(p.account_code, '-') <> '11' THEN l.debit_func - l.credit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type = 'LIABILITY' AND p.account_code = '21' THEN l.credit_func - l.debit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type = 'LIABILITY' AND NVL(p.account_code, '-') <> '21' THEN l.credit_func - l.debit_func END), 0),
           NVL(SUM(CASE WHEN a.subledger_code = 'INV' THEN l.debit_func - l.credit_func END), 0),
           NVL(SUM(CASE WHEN a.subledger_code = 'CASH' THEN l.debit_func - l.credit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type = 'EQUITY' THEN l.credit_func - l.debit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type IN ('REVENUE', 'EXPENSE') THEN l.credit_func - l.debit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type = 'REVENUE' AND j.doc_date >= p_from AND NVL(j.journal_category, '-') <> 'CLOSING'
                        THEN l.credit_func - l.debit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type = 'EXPENSE' AND p.account_code = '51' AND j.doc_date >= p_from AND NVL(j.journal_category, '-') <> 'CLOSING'
                        THEN l.debit_func - l.credit_func END), 0),
           NVL(SUM(CASE WHEN a.account_type = 'EXPENSE' AND j.doc_date >= p_from AND NVL(j.journal_category, '-') <> 'CLOSING'
                        THEN l.debit_func - l.credit_func END), 0)
      INTO ca, nca, cl, ncl, inv, cash, eq, pl_all, rev, cogs, exp
      FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
      LEFT JOIN gl_account p ON p.id = a.parent_account_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= p_to AND a.coa_id = l_coa;
    np := rev - exp; ta := ca + nca; tl := cl + ncl; te := eq + pl_all;
    l_html := NOONA_BRAND_PKG.report_header('النسب المالية' || period_text(p_from, p_to))
           || '<div class="nn-fields">'
           || '<div class="nn-field"><div class="nn-field-label">الأصول المتداولة</div><div class="nn-field-value">' || fmt0(ca) || '</div></div>'
           || '<div class="nn-field"><div class="nn-field-label">إجمالي الأصول</div><div class="nn-field-value">' || fmt0(ta) || '</div></div>'
           || '<div class="nn-field"><div class="nn-field-label">الخصوم المتداولة</div><div class="nn-field-value">' || fmt0(cl) || '</div></div>'
           || '<div class="nn-field"><div class="nn-field-label">إجمالي الخصوم</div><div class="nn-field-value">' || fmt0(tl) || '</div></div>'
           || '<div class="nn-field"><div class="nn-field-label">حقوق الملكية (مع نتيجة الأعمال)</div><div class="nn-field-value">' || fmt0(te) || '</div></div>'
           || '<div class="nn-field"><div class="nn-field-label">الإيرادات / صافي الربح للفترة</div><div class="nn-field-value">' || fmt0(rev)
           || ' / ' || fmt0(np) || '</div></div></div>'
           || '<table class="nn-rpt"><thead><tr><th>المجموعة</th><th>النسبة</th><th>طريقة الاحتساب</th><th>القيمة</th><th>القراءة</th></tr></thead><tbody>'
           || r('السيولة', 'نسبة التداول', 'الأصول المتداولة ÷ الخصوم المتداولة', ratio(ca, cl), 'أكبر من 1 تعني قدرة على سداد الالتزامات القصيرة')
           || r('السيولة', 'النسبة السريعة', '(الأصول المتداولة - المخزون) ÷ الخصوم المتداولة', ratio(ca - inv, cl), 'السيولة دون الاعتماد على بيع المخزون')
           || r('السيولة', 'نسبة النقدية', 'النقدية ÷ الخصوم المتداولة', ratio(cash, cl), 'التغطية بالنقد الحاضر فقط')
           || r('الربحية', 'هامش مجمل الربح', '(الإيرادات - تكلفة المبيعات) ÷ الإيرادات', pct(rev - cogs, rev), 'كفاءة التسعير وتكلفة البضاعة')
           || r('الربحية', 'هامش صافي الربح', 'صافي الربح ÷ الإيرادات', pct(np, rev), 'ما يبقى من كل ريال إيراد')
           || r('الربحية', 'العائد على الأصول', 'صافي الربح ÷ إجمالي الأصول', pct(np, ta), 'كفاءة استخدام الأصول')
           || r('الربحية', 'العائد على حقوق الملكية', 'صافي الربح ÷ حقوق الملكية', pct(np, te), 'عائد الملاك')
           || r('الرفع المالي', 'نسبة المديونية', 'إجمالي الخصوم ÷ إجمالي الأصول', pct(tl, ta), 'نسبة تمويل الأصول بالديون')
           || r('الرفع المالي', 'الديون إلى حقوق الملكية', 'إجمالي الخصوم ÷ حقوق الملكية', ratio(tl, te), 'كلما ارتفعت زادت المخاطر')
           || r('الرفع المالي', 'نسبة الملكية', 'حقوق الملكية ÷ إجمالي الأصول', pct(te, ta), 'نسبة تمويل الأصول من الملاك')
           || '</tbody></table>'
           || check_box(ROUND(ta, 2) = ROUND(tl + te, 2), 'الأصول = الخصوم + حقوق الملكية', 'المعادلة المحاسبية لا تتحقق: الفرق ' || fmt0(ta - tl - te))
           || NOONA_GL_PKG.report_footer('الأرصدة المرحلة كما في نهاية الفترة، والإيرادات والمصروفات للفترة؛ التصنيف حسب مجموعات الدليل 11/21/51');
    RETURN l_html;
  END ratios;

  -- ================================================================ الرقابة والتسويات
  FUNCTION ctl_row(p_name VARCHAR2, p_value VARCHAR2, p_ok BOOLEAN, p_detail VARCHAR2, p_warn BOOLEAN DEFAULT FALSE) RETURN VARCHAR2 IS
  BEGIN
    IF NOT p_ok AND NOT p_warn THEN g_fail := g_fail + 1; END IF;
    RETURN '<tr><td class="nn-rpt-text"><b>' || p_name || '</b></td><td>' || p_value || '</td><td>'
        || CASE WHEN p_ok THEN '<span class="nn-badge is-success">مطابق</span>'
                WHEN p_warn THEN '<span class="nn-badge is-warning">للمراجعة</span>'
                ELSE '<span class="nn-badge is-danger">غير مطابق</span>' END
        || '</td><td class="nn-rpt-text">' || p_detail || '</td></tr>';
  END ctl_row;

  FUNCTION controls(p_as_of IN DATE DEFAULT NULL) RETURN CLOB IS
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_co   NUMBER := NOONA_GL_PKG.company;
    l_to   DATE := NVL(p_as_of, TRUNC(SYSDATE));
    l_html CLOB;
    l_n    NUMBER; l_d NUMBER; l_x NUMBER;
    l_txt  VARCHAR2(4000);
  BEGIN
    view_guard;
    g_fail := 0;
    l_html := NOONA_BRAND_PKG.report_header('الرقابة والتسويات المحاسبية كما في ' || TO_CHAR(l_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>الفحص</th><th>النتيجة</th><th>الحالة</th><th>التفاصيل</th></tr></thead><tbody>'
           || '<tr class="nn-rpt-group"><td colspan="4">سلامة الأستاذ العام</td></tr>';
    -- 1) توازن القيود المرحلة
    SELECT COUNT(*) INTO l_n FROM (
      SELECT j.id FROM gl_journal j JOIN gl_journal_line l ON l.journal_id = j.id
       WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= l_to
       GROUP BY j.id HAVING SUM(l.debit_func) <> SUM(l.credit_func));
    l_html := l_html || ((ctl_row('توازن كل قيد مرحل', l_n || ' قيد غير متوازن', l_n = 0, 'مجموع المدين = مجموع الدائن في كل قيد')));
    -- 2) إجماليات الرأس = مجموع السطور
    SELECT COUNT(*) INTO l_n FROM gl_journal j
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= l_to
       AND (NVL(j.total_debit_func, 0) <> (SELECT NVL(SUM(debit_func), 0) FROM gl_journal_line WHERE journal_id = j.id)
         OR NVL(j.total_credit_func, 0) <> (SELECT NVL(SUM(credit_func), 0) FROM gl_journal_line WHERE journal_id = j.id));
    l_html := l_html || ((ctl_row('إجماليات رأس القيد = مجموع سطوره', l_n || ' اختلاف', l_n = 0, 'الملخص يطابق التفاصيل')));
    -- 3) جدول الأرصدة يطابق القيود (لكل الفترات)
    SELECT COUNT(*), NVL(SUM(ABS(d)), 0) INTO l_n, l_d FROM (
      SELECT account_id, SUM(v) d FROM (
        SELECT b.account_id, b.period_dr_func - b.period_cr_func v FROM gl_balance b WHERE b.ledger_id = l_led
        UNION ALL
        SELECT l.account_id, -(l.debit_func - l.credit_func) FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
         WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED'))
       GROUP BY account_id HAVING SUM(v) <> 0);
    l_html := l_html || ((ctl_row('أرصدة الحسابات المحفوظة = حركة القيود', l_n || ' حساب / فرق ' || fmt0(l_d), l_n = 0,
                                'مطابقة جدول الأرصدة GL_BALANCE مع سطور القيود المرحلة')));
    -- 4) ميزان المراجعة
    SELECT NVL(SUM(l.debit_func - l.credit_func), 0) INTO l_d FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= l_to;
    l_html := l_html || ((ctl_row('ميزان المراجعة متوازن', 'الفرق ' || fmt0(l_d), l_d = 0, 'إجمالي المدين = إجمالي الدائن حتى التاريخ')));
    -- 5) القيود اليدوية على حسابات المراقبة
    SELECT COUNT(*) INTO l_n FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
      JOIN gl_journal_source s ON s.id = j.journal_source_id JOIN gl_account a ON a.id = l.account_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND s.allow_manual = 'Y' AND j.reversal_of_id IS NULL
       AND a.allow_manual_posting = 'N';
    l_html := l_html || ((ctl_row('قيود يدوية على حسابات المراقبة', l_n || ' سطر', l_n = 0, 'حسابات العملاء والموردين والمخزون والأصول ترحل من أنظمتها فقط')));

    l_html := l_html || ('<tr class="nn-rpt-group"><td colspan="4">المحرك المحاسبي والمستندات</td></tr>');
    -- 6) مستندات مرحلة دون قيد
    SELECT COUNT(*) INTO l_n FROM csh_transaction t
     WHERE t.company_id = l_co AND t.status_code IN ('SETTLED', 'REVERSED')
       AND NOT EXISTS (SELECT 1 FROM ace_accounting_event e JOIN gl_journal j ON j.id = e.journal_id
                        WHERE ((e.source_entity_type = 'CSH_TRANSACTION' AND e.source_entity_id = t.id)
                               OR (NVL(t.source_entity_type, 'CSH_TRANSACTION') <> 'CSH_TRANSACTION' AND e.id = t.accounting_event_id))
                          AND j.status_code IN ('POSTED', 'REVERSED'));
    l_html := l_html || ((ctl_row('سندات معتمدة دون قيد', l_n || ' سند', l_n = 0, 'كل سند معتمد له قيد مرحل مرتبط')));
    -- 7) آثار مكررة
    SELECT COUNT(*) INTO l_n FROM (
      SELECT source_entity_type, source_entity_id FROM ace_accounting_event
       WHERE company_id = l_co AND status_code = 'POSTED' AND reversal_of_event_id IS NULL
       GROUP BY source_entity_type, source_entity_id HAVING COUNT(*) > 1);
    l_html := l_html || ((ctl_row('مستندات مرحلة أكثر من مرة', l_n || ' مستند', l_n = 0, 'منع الترحيل المكرر بمفتاح الحدث المحاسبي')));
    -- 8) أحداث معلقة أو فاشلة
    SELECT COUNT(*) INTO l_n FROM ace_accounting_event WHERE company_id = l_co AND status_code NOT IN ('POSTED', 'REVERSED');
    l_html := l_html || ((ctl_row('أحداث محاسبية معلقة أو فاشلة', l_n || ' حدث', l_n = 0, 'أحداث لم تتحول إلى قيود')));
    -- 9) قيود نظامية دون مستند
    SELECT COUNT(*) INTO l_n FROM gl_journal j JOIN gl_journal_source s ON s.id = j.journal_source_id
     WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND s.allow_manual = 'N'
       AND s.code NOT IN ('YEAR_END', 'OPENING') AND j.accounting_event_id IS NULL AND j.reversal_of_id IS NULL;
    l_html := l_html || ((ctl_row('قيود آلية دون مستند مصدر', l_n || ' قيد', l_n = 0, 'كل قيد آلي مرتبط بحدث ومستند')));
    -- 10) مستندات معلقة
    SELECT COUNT(*) INTO l_n FROM gl_journal WHERE ledger_id = l_led AND status_code IN ('DRAFT', 'SUBMITTED', 'APPROVED');
    SELECT COUNT(*) INTO l_x FROM csh_transaction WHERE company_id = l_co AND status_code IN ('DRAFT', 'SUBMITTED');
    l_html := l_html || ((ctl_row('مستندات غير مرحلة', l_n || ' قيد / ' || l_x || ' سند', l_n + l_x = 0,
                                'لا تؤثر في الأرصدة حتى ترحل؛ راجعها قبل إقفال الفترة', TRUE)));

    l_html := l_html || ('<tr class="nn-rpt-group"><td colspan="4">مطابقة الأستاذ مع الأنظمة الفرعية</td></tr>');
    -- 11) النقدية: رصيد الحساب في الأستاذ = أرصدة الصناديق والبنوك المرتبطة به
    FOR r IN (SELECT a.id, a.account_code, a.name_ar FROM gl_account a
               WHERE a.coa_id = NOONA_GL_PKG.primary_coa AND a.subledger_code = 'CASH' AND a.is_postable = 'Y' ORDER BY a.account_code) LOOP
      SELECT NVL(SUM(l.debit_func - l.credit_func), 0) INTO l_d FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
       WHERE l.account_id = r.id AND j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= l_to;
      SELECT NVL(SUM(CASE WHEN t.txn_type = 'RECEIPT' THEN 1 ELSE -1 END * t.amount_func
                     * CASE WHEN e.reversal_of_event_id IS NULL THEN 1 ELSE -1 END), 0)
        INTO l_x
        FROM csh_transaction t
        JOIN ace_accounting_event e ON ((e.source_entity_type = 'CSH_TRANSACTION' AND e.source_entity_id = t.id)
                                        OR (NVL(t.source_entity_type, 'CSH_TRANSACTION') <> 'CSH_TRANSACTION'
                                            AND (e.id = t.accounting_event_id OR e.reversal_of_event_id = t.accounting_event_id)))
                                       AND e.journal_id IS NOT NULL
        LEFT JOIN csh_cash_box b ON b.id = t.cash_box_id LEFT JOIN csh_bank_account k ON k.id = t.bank_account_id
       WHERE t.company_id = l_co AND NVL(b.gl_account_id, k.gl_account_id) = r.id AND e.accounting_date <= l_to;
      l_html := l_html || ((ctl_row('النقدية: ' || esc(r.account_code || ' ' || r.name_ar),
                                  'الأستاذ ' || fmt0(l_d) || ' / السندات ' || fmt0(l_x), l_d = l_x,
                                  CASE WHEN l_d = l_x THEN 'مطابق' ELSE 'الفرق ' || fmt0(l_d - l_x) || ': قيود يومية مباشرة على حساب النقدية (افتتاحي أو تحويل)' END,
                                  TRUE)));
    END LOOP;
    -- 12) الموردون والعملاء والمخزون: رصيد حساب المراقبة = رصيد النظام الفرعي
    FOR r IN (SELECT 'الموردون: ' || a.account_code || ' ' || a.name_ar lbl, a.id, -1 sg,
                     (SELECT NVL(SUM(NOONA_PUR_PKG.supplier_balance(x.id, l_to)), 0) FROM ap_supplier_account x
                       WHERE x.company_id = l_co AND NVL(x.payable_account_id, a.id) = a.id) sub
                FROM gl_account a WHERE a.coa_id = NOONA_GL_PKG.primary_coa AND a.account_code = '2101'
              UNION ALL
              SELECT 'العملاء: ' || a.account_code || ' ' || a.name_ar, a.id, 1,
                     (SELECT NVL(SUM(NOONA_SAL_PKG.customer_balance(x.id, l_to)), 0) FROM ar_customer_account x
                       WHERE x.company_id = l_co AND NVL(x.receivable_account_id, a.id) = a.id)
                FROM gl_account a WHERE a.coa_id = NOONA_GL_PKG.primary_coa AND a.account_code = '1103'
              UNION ALL
              SELECT 'المخزون: ' || a.account_code || ' ' || a.name_ar, a.id, 1,
                     (SELECT NVL(SUM(c.total_value), 0) FROM inv_item_cost c JOIN inv_item i ON i.id = c.item_id
                       WHERE c.company_id = l_co AND c.warehouse_id IS NULL AND NOONA_INV_PKG.account_for(i.id, 'INVENTORY') = a.id)
                FROM gl_account a WHERE a.coa_id = NOONA_GL_PKG.primary_coa
                 AND a.id IN (SELECT NVL(inventory_account_id, NOONA_INV_PKG.acc_id('1105')) FROM inv_item_category)
              UNION ALL
              SELECT 'الإنتاج تحت التشغيل: ' || a.account_code || ' ' || a.name_ar, a.id, 1,
                     (SELECT NVL(SUM(CASE w.entry_type WHEN 'CHARGE' THEN w.amount ELSE -w.amount END), 0) FROM mfg_wip_cost w
                       WHERE w.company_id = l_co AND w.accounting_event_id IS NOT NULL AND w.cost_date <= l_to)
                FROM gl_account a WHERE a.coa_id = NOONA_GL_PKG.primary_coa AND a.account_code = '1110') LOOP
      SELECT r.sg * NVL(SUM(l.debit_func - l.credit_func), 0) INTO l_d FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
       WHERE l.account_id = r.id AND j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND j.doc_date <= l_to;
      l_html := l_html || ((ctl_row(esc(r.lbl), 'الأستاذ ' || fmt0(l_d) || ' / النظام الفرعي ' || fmt0(r.sub), ROUND(l_d - r.sub, 2) = 0,
                                  CASE WHEN ROUND(l_d - r.sub, 2) = 0 THEN 'مطابق'
                                       ELSE 'الفرق ' || fmt0(l_d - r.sub) || ': قيود يومية مباشرة على حساب المراقبة أو أرصدة افتتاحية غير مسجلة في النظام الفرعي' END,
                                  TRUE)));
    END LOOP;

    l_html := l_html || ('<tr class="nn-rpt-group"><td colspan="4">حالة إقفال الفترات</td></tr>');
    l_txt := NULL;
    FOR r IN (SELECT y.name_ar yname, y.status_code ys,
                     COUNT(CASE WHEN s.status_code = 'OPEN' THEN 1 END) op, COUNT(CASE WHEN s.status_code <> 'OPEN' THEN 1 END) cl
                FROM gl_fiscal_year y JOIN gl_period p ON p.fiscal_year_id = y.id
                LEFT JOIN gl_period_status s ON s.period_id = p.id AND s.ledger_id = l_led AND s.module_code = 'GL'
               WHERE y.company_id = l_co GROUP BY y.name_ar, y.status_code, y.start_date ORDER BY y.start_date) LOOP
      l_html := l_html || ((ctl_row('السنة ' || esc(r.yname), esc(NOONA_UI_PKG.status_label(r.ys)), TRUE,
                                  r.op || ' فترة مفتوحة، ' || r.cl || ' فترة مقفلة')));
    END LOOP;
    RETURN l_html || (('</tbody></table>'
        || check_box(g_fail = 0, 'كل الفحوص الإلزامية مطابقة', g_fail || ' فحص غير مطابق؛ راجع التفاصيل')
        || NOONA_GL_PKG.report_footer('القيود المرحلة والسندات المعتمدة حتى تاريخ التقرير')));
  END controls;

  FUNCTION control_failures RETURN NUMBER IS
    l CLOB;
  BEGIN
    l := controls(TRUNC(SYSDATE));
    RETURN g_fail;
  END control_failures;

  -- ================================================================ التدقيق
  FUNCTION audit_log(p_from IN DATE, p_to IN DATE, p_scope IN VARCHAR2 DEFAULT 'ALL') RETURN CLOB IS
    l_co   NUMBER := NOONA_GL_PKG.company;
    l_html CLOB;
    l_cnt  PLS_INTEGER := 0;
    l_sc   VARCHAR2(30) := NVL(p_scope, 'ALL');
  BEGIN
    NOONA_CORE_PKG.assert(NOONA_APEX_PKG.is_tenant_admin = 'Y'
                          OR NOONA_SECURITY_PKG.has_permission('GL_JOURNAL.APPROVE', l_co) = 'Y'
                          OR NOONA_SECURITY_PKG.has_permission('CSH_TRANSACTION.APPROVE', l_co) = 'Y',
      'NOONA-SEC-010', 'سجل التدقيق المالي للمعتمدين ومسؤول المؤسسة', 'Not authorized');
    l_html := NOONA_BRAND_PKG.report_header('سجل التدقيق المالي' || period_text(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>الوقت</th><th>المستند</th><th>الإجراء</th><th>النتيجة</th><th>المستخدم</th>'
           || '<th>السبب / الملاحظة</th></tr></thead><tbody>';
    FOR r IN (SELECT e.occurred_at, e.entity_type, e.entity_id, e.action_code, e.result_code, NVL(u.username, e.created_by) who, e.reason,
                     CASE e.entity_type
                       WHEN 'GL_JOURNAL' THEN (SELECT 'قيد ' || doc_no FROM gl_journal WHERE id = e.entity_id)
                       WHEN 'CSH_TRANSACTION' THEN (SELECT NOONA_CSH_PKG.type_label(txn_type) || ' ' || doc_no FROM csh_transaction WHERE id = e.entity_id)
                       WHEN 'GL_FISCAL_YEAR' THEN (SELECT 'السنة ' || name_ar FROM gl_fiscal_year WHERE id = e.entity_id)
                       WHEN 'GL_PERIOD' THEN (SELECT 'الفترة ' || name_ar FROM gl_period WHERE id = e.entity_id)
                       WHEN 'GL_ACCOUNT' THEN (SELECT 'الحساب ' || account_code || ' ' || name_ar FROM gl_account WHERE id = e.entity_id)
                       ELSE e.entity_type || ' ' || e.entity_id END doc
                FROM aud_event e LEFT JOIN sec_user u ON u.id = e.actor_user_id
               WHERE (e.company_id = l_co OR e.company_id IS NULL)
                 AND e.occurred_at >= CAST(p_from AS TIMESTAMP) AND e.occurred_at < CAST(p_to + 1 AS TIMESTAMP)
                 AND e.entity_type IN ('GL_JOURNAL', 'CSH_TRANSACTION', 'GL_FISCAL_YEAR', 'GL_PERIOD', 'GL_LEDGER', 'GL_ACCOUNT',
                                       'GL_COST_CENTER', 'CSH_CASH_BOX', 'CSH_BANK_ACCOUNT', 'REF_DOC_SEQUENCE', 'REF_EXCHANGE_RATE')
                 AND (l_sc = 'ALL' OR (l_sc = 'CONFIG' AND e.event_category = 'CONFIG') OR e.entity_type = l_sc)
               ORDER BY e.occurred_at DESC, e.id DESC
               FETCH FIRST 500 ROWS ONLY) LOOP
      l_cnt := l_cnt + 1;
      l_html := l_html || (('<tr><td>' || TO_CHAR(r.occurred_at, 'YYYY-MM-DD HH24:MI') || '</td><td class="nn-rpt-text">' || esc(r.doc)
             || '</td><td class="nn-rpt-text">' || esc(CASE r.action_code WHEN 'CREATE' THEN 'إنشاء' WHEN 'SUBMIT' THEN 'إرسال'
                  WHEN 'APPROVE' THEN 'اعتماد' WHEN 'APPROVE_POST' THEN 'اعتماد وترحيل' WHEN 'POST' THEN 'ترحيل' WHEN 'REJECT' THEN 'رفض'
                  WHEN 'REVERSE' THEN 'عكس' WHEN 'CANCEL' THEN 'إلغاء' WHEN 'YEAR_CLOSE' THEN 'إقفال السنة' WHEN 'YEAR_REOPEN' THEN 'إعادة فتح السنة'
                  WHEN 'QUICK_SETUP' THEN 'تجهيز' ELSE r.action_code END)
             || '</td><td>' || NOONA_UI_PKG.status_badge(r.result_code) || '</td><td>' || esc(r.who) || '</td><td class="nn-rpt-text">'
             || esc(r.reason) || '</td></tr>'));
    END LOOP;
    IF l_cnt = 0 THEN l_html := l_html || ('<tr><td colspan="6" class="nn-rpt-text">لا توجد أحداث</td></tr>'); END IF;
    l_html := l_html || ('</tbody></table>');
    -- الصلاحيات الحساسة في المالية
    l_html := l_html || ('<h3 class="nn-rpt-h">المستخدمون أصحاب الصلاحيات الحساسة في المالية</h3>'
           || '<table class="nn-rpt"><thead><tr><th>المستخدم</th><th>الدور</th><th>الصلاحيات</th></tr></thead><tbody>');
    FOR r IN (SELECT u.username, ro.name_ar role_name,
                     LISTAGG(DISTINCT p.permission_code, '، ') WITHIN GROUP (ORDER BY p.permission_code) perms
                FROM sec_role_grant g JOIN sec_user_membership m ON m.id = g.membership_id JOIN sec_user u ON u.id = m.user_id
                JOIN sec_role ro ON ro.id = g.role_id JOIN sec_role_permission rp ON rp.role_id = g.role_id AND rp.effect = 'ALLOW'
                JOIN sec_permission p ON p.id = rp.permission_id
               WHERE g.status_code = 'ACTIVE' AND m.status_code = 'ACTIVE'
                 AND p.permission_code IN ('GL_JOURNAL.APPROVE', 'GL_JOURNAL.POST', 'GL_JOURNAL.REVERSE', 'GL_PERIOD_STATUS.UPDATE',
                                           'GL_FISCAL_YEAR.UPDATE', 'CSH_TRANSACTION.APPROVE', 'CSH_TRANSACTION.POST',
                                           'CSH_TRANSACTION.REVERSE', 'CSH_BANK_ACCOUNT.CREATE')
               GROUP BY u.username, ro.name_ar ORDER BY u.username) LOOP
      l_html := l_html || (('<tr><td>' || esc(r.username) || '</td><td class="nn-rpt-text">' || esc(r.role_name) || '</td><td class="nn-rpt-text">'
             || esc(r.perms) || '</td></tr>'));
    END LOOP;
    FOR r IN (SELECT u.username FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
               WHERE m.is_tenant_admin = 'Y' AND m.status_code = 'ACTIVE' ORDER BY u.username) LOOP
      l_html := l_html || (('<tr><td>' || esc(r.username) || '</td><td class="nn-rpt-text">مسؤول المؤسسة</td><td class="nn-rpt-text">كل الصلاحيات</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody></table>' || NOONA_GL_PKG.report_footer('سجل التدقيق الموقع بسلسلة التحقق (آخر 500 حدث في النطاق)')));
  END audit_log;

END NOONA_FIN_RPT_PKG;
/
