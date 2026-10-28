-- =============================================================================
-- NOONA PLUS ERP | NOONA_LOC_PKG - حزم الدول والتوطين والضرائب (أساسية لكل مؤسسة)
--   * حزمة الدولة للشركة: أكواد الضرائب ونسبها بإصدارات مؤرخة، التسجيلات القانونية والتحقق من أرقامها، حسابات الضرائب
--   * السجل الضريبي الموحد NOONA_V_TAX_REGISTER من كل الوحدات (المبيعات، نقاط البيع، المشتريات، المستشفى، الفنادق،
--     المستخلصات، بيع الأصول) ويبنى منه إقرار ضريبة القيمة المضافة بخانات الدولة
--   * الإقرار: احتساب ← مراجعة ← اعتماد (قيد تسوية المخرجات والمدخلات) ← تقديم (مرجع الجهة) ← سداد
--   * ضريبة الاستقطاع على مدفوعات غير المقيمين: شهادة، قيد، تخفيض ذمة المورد، إقرار شهري وسداده
-- =============================================================================
SET DEFINE OFF

-- ---------------------------------------------------------------- السجل الضريبي الموحد
CREATE OR REPLACE VIEW NOONA_V_TAX_REGISTER AS
-- فواتير المبيعات والإشعارات الدائنة (التصدير: نسبة صفرية لعميل من دولة أخرى)
SELECT i.company_id, i.doc_date, 'SALE' direction, 'SAL_INVOICE' source_type, i.id source_id, i.doc_no,
       i.customer_name_snapshot party_name, i.customer_tax_no_snapshot party_tax_no, l.tax_code_id,
       CASE WHEN pc.country_code IS NOT NULL AND pc.country_code <> co.country_code AND NVL(c.tax_nature, 'ZERO_RATED') IN ('ZERO_RATED', 'OUT_OF_SCOPE')
            THEN 'EXPORT' ELSE NVL(c.tax_nature, CASE WHEN l.tax_amount <> 0 THEN 'STANDARD' ELSE 'OUT_OF_SCOPE' END) END nature,
       CASE WHEN i.doc_type = 'CREDIT_NOTE' THEN -1 ELSE 1 END * l.net_amount taxable_amount,
       CASE WHEN i.doc_type = 'CREDIT_NOTE' THEN -1 ELSE 1 END * NVL(l.tax_amount, 0) tax_amount
  FROM sal_invoice i JOIN sal_invoice_line l ON l.invoice_id = i.id JOIN org_company co ON co.id = i.company_id
  LEFT JOIN loc_tax_code c ON c.id = l.tax_code_id
  LEFT JOIN ar_customer_account a ON a.id = i.customer_account_id LEFT JOIN ar_customer cu ON cu.id = a.customer_id
  LEFT JOIN pty_party pc ON pc.id = cu.party_id
 WHERE i.status_code IN ('ISSUED', 'POSTED', 'PARTIALLY_PAID', 'PAID', 'CREDITED')
   AND i.doc_type IN ('INVOICE', 'SIMPLIFIED_INVOICE', 'CREDIT_NOTE', 'DEBIT_NOTE')
UNION ALL
-- نقاط البيع (المبيعات غير المحولة لفاتورة) والمرتجعات
SELECT s.company_id, TRUNC(CAST(s.sale_at AS DATE)), 'SALE', 'POS_SALE', s.id, s.receipt_no, NULL, NULL, l.tax_code_id,
       NVL(c.tax_nature, CASE WHEN l.tax_amount <> 0 THEN 'STANDARD' ELSE 'OUT_OF_SCOPE' END),
       CASE WHEN s.sale_type = 'RETURN' THEN -1 ELSE 1 END * (l.line_total - NVL(l.tax_amount, 0)),
       CASE WHEN s.sale_type = 'RETURN' THEN -1 ELSE 1 END * NVL(l.tax_amount, 0)
  FROM pos_sale s JOIN pos_sale_line l ON l.sale_id = s.id LEFT JOIN loc_tax_code c ON c.id = l.tax_code_id
 WHERE s.status_code IN ('COMPLETED', 'RETURNED', 'PARTIALLY_RETURNED') AND s.sales_invoice_id IS NULL
UNION ALL
-- فواتير الموردين والإشعارات
SELECT i.company_id, NVL(i.gl_date, i.doc_date), 'PURCHASE', 'AP_INVOICE', i.id, i.doc_no, p.display_name_ar, p.tax_number, l.tax_code_id,
       NVL(c.tax_nature, CASE WHEN l.tax_amount <> 0 THEN 'STANDARD' ELSE 'OUT_OF_SCOPE' END),
       CASE WHEN i.invoice_type = 'CREDIT_MEMO' THEN -1 ELSE 1 END * l.line_amount,
       CASE WHEN i.invoice_type = 'CREDIT_MEMO' THEN -1 ELSE 1 END * NVL(l.tax_amount, 0)
  FROM ap_invoice i JOIN ap_invoice_line l ON l.invoice_id = i.id LEFT JOIN loc_tax_code c ON c.id = l.tax_code_id
  LEFT JOIN ap_supplier_account a ON a.id = i.supplier_account_id LEFT JOIN ap_supplier su ON su.id = a.supplier_id
  LEFT JOIN pty_party p ON p.id = su.party_id
 WHERE i.status_code IN ('APPROVED', 'POSTED', 'PARTIALLY_PAID', 'PAID')
UNION ALL
-- المستشفى: حصة المريض (الصحة الخاصة للمواطن السعودي بنسبة صفرية)
SELECT h.company_id, h.doc_date, 'SALE', 'HIS_INVOICE', h.id, h.doc_no, NULL, NULL, NULL,
       CASE WHEN h.patient_vat <> 0 THEN 'STANDARD' WHEN pt.nationality = co.country_code THEN 'CITIZEN' ELSE 'ZERO_RATED' END,
       h.patient_net, h.patient_vat
  FROM his_invoice h JOIN org_company co ON co.id = h.company_id LEFT JOIN his_patient pt ON pt.id = h.patient_id
 WHERE h.status_code = 'POSTED' AND h.patient_net <> 0
UNION ALL
-- المستشفى: حصة شركة التأمين أو الجهة
SELECT h.company_id, h.doc_date, 'SALE', 'HIS_INVOICE', h.id, h.doc_no, NULL, NULL, NULL,
       CASE WHEN h.payer_vat <> 0 THEN 'STANDARD' WHEN pt.nationality = co.country_code THEN 'CITIZEN' ELSE 'ZERO_RATED' END,
       h.payer_net, h.payer_vat
  FROM his_invoice h JOIN org_company co ON co.id = h.company_id LEFT JOIN his_patient pt ON pt.id = h.patient_id
 WHERE h.status_code = 'POSTED' AND h.payer_net <> 0
UNION ALL
-- الفنادق: أسطر الضريبة في كشوف النزلاء (الأساس من النسبة السارية يوم العمل)
SELECT f.company_id, f.business_date, 'SALE', 'HSP_FOLIO_LINE', f.id, fo.folio_no, NULL, NULL, NULL, 'STANDARD',
       ROUND(f.amount * 100 / NULLIF(NOONA_INV_PKG.tax_rate(NOONA_INV_PKG.tax_id('VAT15'), f.business_date), 0), 2), f.amount
  FROM hsp_folio_line f JOIN hsp_folio fo ON fo.id = f.folio_id
 WHERE f.line_type = 'TAX'
UNION ALL
-- المستخلصات: للعميل (مبيعات) ومن مقاولي الباطن (مشتريات)
SELECT k.company_id, k.doc_date, CASE k.claim_direction WHEN 'RECEIVABLE' THEN 'SALE' ELSE 'PURCHASE' END, 'PRJ_PROGRESS_CLAIM', k.id, k.doc_no,
       NULL, NULL, NULL, CASE WHEN k.tax_amount <> 0 THEN 'STANDARD' ELSE 'ZERO_RATED' END,
       CASE k.claim_kind WHEN 'ADVANCE' THEN k.current_gross ELSE k.current_gross - k.advance_recovery - k.other_deductions END, k.tax_amount
  FROM prj_progress_claim k
 WHERE k.status_code IN ('APPROVED', 'PAID') AND k.claim_kind <> 'RETENTION_RELEASE'
UNION ALL
-- بيع الأصول الثابتة
SELECT d.company_id, d.doc_date, 'SALE', 'FA_DISPOSAL', d.id, d.doc_no, NULL, NULL, NULL,
       CASE WHEN NVL(d.vat_amount, 0) <> 0 THEN 'STANDARD' ELSE 'EXEMPT' END, d.proceeds, NVL(d.vat_amount, 0)
  FROM fa_disposal d
 WHERE d.status_code = 'POSTED' AND NVL(d.proceeds, 0) <> 0;

CREATE OR REPLACE PACKAGE NOONA_LOC_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  FUNCTION company_country RETURN VARCHAR2;
  FUNCTION company_pack RETURN NUMBER;
  FUNCTION nature_label(p_nature IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  -- النسبة السارية لكود في تاريخ
  FUNCTION rate_on(p_tax_code_id IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER;

  -- ---------------------------------------------------------- حزمة الدولة للشركة
  -- يربط الشركة بحزمة دولتها ويجهز حسابات الضرائب (المخرجات 2104، المدخلات 1107، الاستقطاع 2106، تسوية الإقرار 2107)
  FUNCTION setup_company RETURN NUMBER;
  -- نسبة جديدة (إصدار) من تاريخ سريان؛ الإصدار السابق ينتهي قبله. للمنصة فقط (النسب نظامية لكل المشتركين)
  FUNCTION set_rate(p_tax_code_id IN NUMBER, p_rate IN NUMBER, p_from IN DATE) RETURN NUMBER;
  -- يتحقق من رقم حسب نمط نوع التسجيل في حزمة الدولة: Y/N
  FUNCTION valid_number(p_reg_type_id IN NUMBER, p_number IN VARCHAR2) RETURN VARCHAR2;
  -- الرقم الضريبي لعميل أو مورد حسب دولة (نوع التسجيل الضريبي في حزمتها)
  FUNCTION valid_tax_number(p_country IN VARCHAR2, p_number IN VARCHAR2) RETURN VARCHAR2;
  -- تسجيل قانوني للشركة: {"id","type","number","authority","issue","expiry","primary":"Y"}
  FUNCTION save_registration(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE end_registration(p_registration_id IN NUMBER);
  -- الرقم الضريبي للشركة (للفواتير)
  FUNCTION company_tax_number RETURN VARCHAR2;

  -- ---------------------------------------------------------- الإقرار الضريبي
  -- إقرار جديد (مسودة) محسوب: p_kind = VAT | WHT
  FUNCTION new_return(p_kind IN VARCHAR2, p_from IN DATE, p_to IN DATE) RETURN NUMBER;
  PROCEDURE recalc_return(p_return_id IN NUMBER);
  -- تصحيحات الفترات السابقة (خانة التصحيح) أو تعديل خانة
  PROCEDURE set_adjustment(p_return_id IN NUMBER, p_box IN VARCHAR2, p_amount IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL);
  PROCEDURE review_return(p_return_id IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL);
  -- الاعتماد: قيد تسوية (ضريبة القيمة المضافة) ويقفل الإقرار
  PROCEDURE approve_return(p_return_id IN NUMBER);
  PROCEDURE file_return(p_return_id IN NUMBER, p_reference IN VARCHAR2, p_filed_at IN DATE DEFAULT NULL);
  -- السداد للجهة من صندوق أو بنك
  PROCEDURE pay_return(p_return_id IN NUMBER, p_place IN VARCHAR2, p_date IN DATE DEFAULT NULL);
  PROCEDURE reopen_return(p_return_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION box_label(p_country IN VARCHAR2, p_box IN VARCHAR2) RETURN VARCHAR2;

  -- ---------------------------------------------------------- الاستقطاع
  -- {"supplier","code":"SA_WHT5","base","date","service"} يخفض ذمة المورد ويقيد الاستقطاع المستحق
  FUNCTION withhold(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE cancel_withholding(p_cert_id IN NUMBER, p_reason IN VARCHAR2);
  -- Y إذا كان المورد غير مقيم (دولته غير دولة الشركة)
  FUNCTION is_non_resident(p_supplier_account_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- الشاشات
  FUNCTION summary_html RETURN CLOB;
  FUNCTION pack_html(p_country IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION registrations_html RETURN CLOB;
  FUNCTION return_html(p_return_id IN NUMBER) RETURN CLOB;
  FUNCTION returns_html(p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION register_html(p_from IN DATE, p_to IN DATE, p_direction IN VARCHAR2 DEFAULT NULL, p_nature IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION withholding_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION certificate_html(p_cert_id IN NUMBER) RETURN CLOB;
  -- مدفوعات لموردين غير مقيمين بلا شهادة استقطاع في الفترة (تنبيه)
  FUNCTION wht_due_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION return_status(p_return_id IN NUMBER) RETURN VARCHAR2;
END NOONA_LOC_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_LOC_PKG AS

  c_ret  CONSTANT VARCHAR2(30) := 'LOC_TAX_RETURN';
  c_line CONSTANT VARCHAR2(30) := 'LOC_TAX_RETURN_LINE';
  c_wht  CONSTANT VARCHAR2(30) := 'LOC_WITHHOLDING_CERT';

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  FUNCTION ds(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END ds;
  FUNCTION pct(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TO_CHAR(NVL(p, 0), 'FM990.99', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.') || '%';
  END pct;

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

  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_party NUMBER, p_desc VARCHAR2) IS
  BEGIN
    IF NVL(p_dr, 0) = 0 AND NVL(p_cr, 0) = 0 THEN RETURN; END IF;
    FOR i IN 1 .. p_lines.COUNT LOOP
      IF p_lines(i).account_id = p_acc AND NVL(p_lines(i).party_id, 0) = NVL(p_party, 0)
         AND ((NVL(p_dr, 0) > 0 AND p_lines(i).debit > 0) OR (NVL(p_cr, 0) > 0 AND p_lines(i).credit > 0)) THEN
        p_lines(i).debit := p_lines(i).debit + NVL(p_dr, 0);
        p_lines(i).credit := p_lines(i).credit + NVL(p_cr, 0);
        RETURN;
      END IF;
    END LOOP;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := NVL(p_dr, 0);
    p_lines(p_lines.COUNT).credit := NVL(p_cr, 0);
    p_lines(p_lines.COUNT).party_id := p_party;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
  END add_line;

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
      WHEN 'OUTPUT' THEN ensure_account('2104', 'ضريبة القيمة المضافة - المخرجات', '21', 'LIABILITY')
      WHEN 'INPUT' THEN ensure_account('1107', 'ضريبة القيمة المضافة - المدخلات', '11', 'ASSET')
      WHEN 'WHT' THEN ensure_account('2106', 'ضريبة الاستقطاع المستحقة', '21', 'LIABILITY')
      WHEN 'SETTLE' THEN ensure_account('2107', 'ضريبة القيمة المضافة المستحقة للجهة (تسوية الإقرار)', '21', 'LIABILITY') END;
  END acc;

  FUNCTION company_country RETURN VARCHAR2 IS
    l VARCHAR2(2);
  BEGIN
    SELECT MAX(country_code) INTO l FROM org_company WHERE id = company;
    RETURN l;
  END company_country;

  FUNCTION company_pack RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(country_pack_id) INTO l FROM org_company WHERE id = company;
    RETURN l;
  END company_pack;

  FUNCTION rate_on(p_tax_code_id IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_INV_PKG.tax_rate(p_tax_code_id, NVL(p_date, TRUNC(SYSDATE)));
  END rate_on;

  FUNCTION nature_label(p_nature IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_nature WHEN 'STANDARD' THEN 'خاضعة بالنسبة الأساسية' WHEN 'ZERO_RATED' THEN 'نسبة صفرية' WHEN 'EXEMPT' THEN 'معفاة'
      WHEN 'OUT_OF_SCOPE' THEN 'خارج النطاق' WHEN 'REVERSE_CHARGE' THEN 'احتساب عكسي' WHEN 'EXPORT' THEN 'صادرات'
      WHEN 'CITIZEN' THEN 'صحة/تعليم خاص للمواطنين' WHEN 'WITHHOLDING' THEN 'استقطاع' ELSE p_nature END;
  END nature_label;

  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'DRAFT' THEN 'مسودة' WHEN 'REVIEWED' THEN 'تمت المراجعة' WHEN 'APPROVED' THEN 'معتمد' WHEN 'FILED' THEN 'مقدم للجهة'
      WHEN 'PAID' THEN 'مسدد' WHEN 'CLOSED' THEN 'مقفل' WHEN 'REOPENED' THEN 'معاد فتحه' WHEN 'ISSUED' THEN 'صادرة' WHEN 'CANCELLED' THEN 'ملغاة'
      ELSE p_status END;
  END status_label;

  FUNCTION badge(p_status VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p_status IN ('PAID', 'CLOSED', 'FILED', 'ISSUED') THEN 'is-success'
                                            WHEN p_status IN ('APPROVED', 'REVIEWED') THEN 'is-info'
                                            WHEN p_status IN ('CANCELLED') THEN 'is-danger' ELSE 'is-warning' END || '">'
        || esc(status_label(p_status)) || '</span>';
  END badge;

  -- ================================================================ حزمة الدولة
  FUNCTION setup_company RETURN NUMBER IS
    l_cc   VARCHAR2(2) := company_country;
    l_pack NUMBER;
    l_n    NUMBER := 0;
    l_out  NUMBER;
    l_in   NUMBER;
    l_wht  NUMBER;
  BEGIN
    guard('LOC_TAX_ACCOUNT.CREATE');
    SELECT MAX(id) INTO l_pack FROM loc_country_pack WHERE country_code = l_cc AND status_code = 'PUBLISHED';
    NOONA_CORE_PKG.assert(l_pack IS NOT NULL, 'NOONA-LOC-001', 'لا توجد حزمة منشورة لدولة الشركة ' || l_cc, 'No published country pack');
    UPDATE org_company SET country_pack_id = l_pack WHERE id = company AND NVL(country_pack_id, -1) <> l_pack;
    l_out := acc('OUTPUT'); l_in := acc('INPUT'); l_wht := acc('WHT'); l_n := acc('SETTLE');
    l_n := 0;
    FOR c IN (SELECT c.id, t.tax_category FROM loc_tax_code c JOIN loc_tax_type t ON t.id = c.tax_type_id
               WHERE t.country_pack_id = l_pack AND c.status_code = 'ACTIVE' AND t.tax_category IN ('VAT', 'WITHHOLDING')) LOOP
      INSERT INTO loc_tax_account (company_id, tax_code_id, payable_account_id, recoverable_account_id, withholding_account_id, effective_from)
      SELECT company, c.id, CASE WHEN c.tax_category = 'VAT' THEN l_out END, CASE WHEN c.tax_category = 'VAT' THEN l_in END,
             CASE WHEN c.tax_category = 'WITHHOLDING' THEN l_wht END, DATE '2000-01-01' FROM dual
       WHERE NOT EXISTS (SELECT 1 FROM loc_tax_account WHERE company_id = company AND tax_code_id = c.id);
      l_n := l_n + SQL%ROWCOUNT;
    END LOOP;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_COMPANY', company, 'APPLY_COUNTRY_PACK', 'SUCCESS',
                              p_new_values => JSON_OBJECT('country' VALUE l_cc, 'pack' VALUE l_pack));
    RETURN l_n;
  END setup_company;

  FUNCTION set_rate(p_tax_code_id IN NUMBER, p_rate IN NUMBER, p_from IN DATE) RETURN NUMBER IS
    l_last DATE;
    l_ver  NUMBER;
    l_id   NUMBER;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(p_rate BETWEEN 0 AND 100 AND p_from IS NOT NULL, 'NOONA-LOC-010', 'النسبة بين 0 و 100 وتاريخ السريان مطلوب',
                          'Rate 0-100 and an effective date are required');
    SELECT MAX(effective_from), NVL(MAX(version_no), 0) INTO l_last, l_ver FROM loc_tax_rate WHERE tax_code_id = p_tax_code_id;
    NOONA_CORE_PKG.assert(l_last IS NULL OR p_from > l_last, 'NOONA-LOC-011',
                          'تاريخ السريان بعد آخر إصدار (' || ds(l_last) || '): لا تعدل النسب السابقة فالفواتير المرحلة عليها',
                          'The new version must start after the last one');
    NOONA_CORE_PKG.begin_system;
    UPDATE loc_tax_rate SET effective_to = p_from - 1 WHERE tax_code_id = p_tax_code_id AND effective_to IS NULL;
    INSERT INTO loc_tax_rate (tenant_id, tax_code_id, version_no, rate_pct, effective_from, approved_by)
    VALUES (NULL, p_tax_code_id, l_ver + 1, p_rate, p_from, NOONA_CTX_PKG.current_user_name)
    RETURNING id INTO l_id;
    NOONA_CORE_PKG.end_system;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'LOC_TAX_RATE', l_id, 'NEW_RATE_VERSION', 'SUCCESS',
                              p_new_values => JSON_OBJECT('rate' VALUE p_rate, 'from' VALUE ds(p_from)));
    RETURN l_id;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END set_rate;

  FUNCTION valid_number(p_reg_type_id IN NUMBER, p_number IN VARCHAR2) RETURN VARCHAR2 IS
    l_rx VARCHAR2(200);
  BEGIN
    SELECT MAX(validation_regex) INTO l_rx FROM loc_registration_type WHERE id = p_reg_type_id;
    RETURN CASE WHEN TRIM(p_number) IS NULL THEN 'N' WHEN l_rx IS NULL OR REGEXP_LIKE(TRIM(p_number), l_rx) THEN 'Y' ELSE 'N' END;
  END valid_number;

  FUNCTION valid_tax_number(p_country IN VARCHAR2, p_number IN VARCHAR2) RETURN VARCHAR2 IS
    l_rx VARCHAR2(200);
  BEGIN
    SELECT MAX(r.validation_regex) INTO l_rx FROM loc_registration_type r JOIN loc_country_pack p ON p.id = r.country_pack_id
     WHERE p.country_code = p_country AND r.is_tax_registration = 'Y' AND r.is_active = 'Y';
    RETURN CASE WHEN TRIM(p_number) IS NULL THEN 'N' WHEN l_rx IS NULL OR REGEXP_LIKE(TRIM(p_number), l_rx) THEN 'Y' ELSE 'N' END;
  END valid_tax_number;

  FUNCTION save_registration(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jn(l_o, 'id');
    l_type NUMBER := jn(l_o, 'type');
    l_no   VARCHAR2(100) := UPPER(REPLACE(js(l_o, 'number'), ' '));
    l_auth VARCHAR2(200) := js(l_o, 'authority');
    l_iss  DATE := TO_DATE(js(l_o, 'issue'), 'YYYY-MM-DD');
    l_exp  DATE := TO_DATE(js(l_o, 'expiry'), 'YYYY-MM-DD');
    l_pri  VARCHAR2(1) := NVL(js(l_o, 'primary'), 'Y');
    l_name VARCHAR2(400);
    l_cc   VARCHAR2(2) := company_country;
    l_co   NUMBER := company;
  BEGIN
    guard('ORG_LEGAL_REGISTRATION.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    SELECT MAX(name_ar) INTO l_name FROM loc_registration_type WHERE id = l_type;
    NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-LOC-020', 'اختر نوع التسجيل', 'Registration type is required');
    NOONA_CORE_PKG.assert(valid_number(l_type, l_no) = 'Y', 'NOONA-LOC-021', 'الرقم لا يطابق صيغة ' || l_name || ' في دولة الشركة',
                          'Number does not match the registration format');
    NOONA_CORE_PKG.assert(l_exp IS NULL OR l_iss IS NULL OR l_exp > l_iss, 'NOONA-LOC-022', 'تاريخ الانتهاء بعد الإصدار', 'Expiry must be after issue');
    IF l_pri = 'Y' THEN
      UPDATE org_legal_registration SET is_primary = 'N' WHERE company_id = l_co AND reg_type_id = l_type AND NVL(id, -1) <> NVL(l_id, -2);
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO org_legal_registration (company_id, reg_type_id, reg_number, issuing_authority, country_code, issue_date, expiry_date,
                                          is_primary, status_code, effective_from)
      VALUES (l_co, l_type, l_no, l_auth, l_cc, l_iss, l_exp, l_pri,
              CASE WHEN l_exp < TRUNC(SYSDATE) THEN 'EXPIRED' ELSE 'ACTIVE' END, NVL(l_iss, TRUNC(SYSDATE)))
      RETURNING id INTO l_id;
    ELSE
      UPDATE org_legal_registration SET reg_number = l_no, issuing_authority = l_auth, issue_date = l_iss, expiry_date = l_exp, is_primary = l_pri,
                                        status_code = CASE WHEN l_exp < TRUNC(SYSDATE) THEN 'EXPIRED' ELSE 'ACTIVE' END
       WHERE id = l_id AND company_id = l_co;
    END IF;
    RETURN l_id;
  END save_registration;

  PROCEDURE end_registration(p_registration_id IN NUMBER) IS
  BEGIN
    guard('ORG_LEGAL_REGISTRATION.UPDATE');
    UPDATE org_legal_registration SET status_code = 'CANCELLED', effective_to = TRUNC(SYSDATE), is_primary = 'N'
     WHERE id = p_registration_id AND company_id = company;
  END end_registration;

  FUNCTION company_tax_number RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT MAX(r.reg_number) KEEP (DENSE_RANK FIRST ORDER BY r.is_primary DESC NULLS LAST, r.id) INTO l
      FROM org_legal_registration r JOIN loc_registration_type t ON t.id = r.reg_type_id
     WHERE r.company_id = company AND t.is_tax_registration = 'Y' AND r.status_code IN ('ACTIVE', 'EXPIRING');
    RETURN l;
  END company_tax_number;

  -- ================================================================ الإقرار
  FUNCTION box_label(p_country IN VARCHAR2, p_box IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_country = 'SA' THEN
      RETURN CASE p_box
        WHEN '1' THEN '1 - المبيعات الخاضعة للنسبة الأساسية' WHEN '2' THEN '2 - المبيعات للمواطنين (الخدمات الصحية والتعليم الخاص)'
        WHEN '3' THEN '3 - المبيعات المحلية الخاضعة للنسبة الصفرية' WHEN '4' THEN '4 - الصادرات' WHEN '5' THEN '5 - المبيعات المعفاة'
        WHEN '6' THEN '6 - إجمالي المبيعات' WHEN '7' THEN '7 - المشتريات الخاضعة للنسبة الأساسية'
        WHEN '8' THEN '8 - الاستيرادات الخاضعة للضريبة المسددة في الجمارك' WHEN '9' THEN '9 - الاستيرادات الخاضعة للاحتساب العكسي'
        WHEN '10' THEN '10 - المشتريات الخاضعة للنسبة الصفرية' WHEN '11' THEN '11 - المشتريات المعفاة' WHEN '12' THEN '12 - إجمالي المشتريات'
        WHEN '13' THEN '13 - إجمالي ضريبة القيمة المضافة المستحقة للفترة' WHEN '14' THEN '14 - تصحيحات من الفترات السابقة'
        WHEN '15' THEN '15 - ضريبة مرحلة من الفترة السابقة' WHEN '16' THEN '16 - صافي الضريبة المستحقة (أو القابلة للاسترداد)' ELSE p_box END;
    END IF;
    RETURN CASE p_box
      WHEN '1' THEN '1 - التوريدات الخاضعة للنسبة الأساسية' WHEN '2' THEN '2 - التوريدات الخاضعة للنسبة الصفرية والصادرات'
      WHEN '3' THEN '3 - التوريدات المعفاة' WHEN '6' THEN '4 - إجمالي التوريدات (ضريبة المخرجات)'
      WHEN '7' THEN '5 - المشتريات والمصروفات الخاضعة للنسبة الأساسية' WHEN '9' THEN '6 - الاستيرادات بالاحتساب العكسي'
      WHEN '12' THEN '7 - إجمالي المشتريات (ضريبة المدخلات)' WHEN '13' THEN '8 - صافي الضريبة للفترة'
      WHEN '14' THEN '9 - تصحيحات الفترات السابقة' WHEN '15' THEN '10 - رصيد مرحل من الفترة السابقة'
      WHEN '16' THEN '11 - صافي الضريبة المستحقة (أو القابلة للاسترداد)' ELSE p_box END;
  END box_label;

  FUNCTION get_return(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN loc_tax_return%ROWTYPE IS
    l loc_tax_return%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM loc_tax_return WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM loc_tax_return WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-LOC-030', 'الإقرار غير موجود', 'Return not found');
  END get_return;

  FUNCTION return_kind(p_type_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT tax_category INTO l FROM loc_tax_type WHERE id = p_type_id;
    RETURN l;
  END return_kind;

  FUNCTION return_status(p_return_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM loc_tax_return WHERE id = p_return_id AND company_id = company;
    RETURN l;
  END return_status;

  PROCEDURE put_box(p_ret NUMBER, p_box VARCHAR2, p_base NUMBER, p_tax NUMBER) IS
  BEGIN
    MERGE INTO loc_tax_return_line l USING (SELECT p_ret r, p_box b FROM dual) x ON (l.tax_return_id = x.r AND l.box_code = x.b)
     WHEN MATCHED THEN UPDATE SET l.base_amount = ROUND(NVL(p_base, 0), 2), l.tax_amount = ROUND(NVL(p_tax, 0), 2)
     WHEN NOT MATCHED THEN INSERT (tax_return_id, box_code, base_amount, tax_amount, adjustment_amount)
          VALUES (p_ret, p_box, ROUND(NVL(p_base, 0), 2), ROUND(NVL(p_tax, 0), 2), 0);
  END put_box;

  PROCEDURE recalc_return(p_return_id IN NUMBER) IS
    r      loc_tax_return%ROWTYPE := get_return(p_return_id, TRUE);
    l_co   NUMBER := company;
    l_out  NUMBER;
    l_in   NUMBER;
    l_adj  NUMBER;
    l_cf   NUMBER;
    l_rc   NUMBER;
    l_net  NUMBER;
  BEGIN
    guard('LOC_TAX_RETURN.UPDATE');
    NOONA_CORE_PKG.assert(r.status_code IN ('DRAFT', 'REOPENED'), 'NOONA-LOC-031', 'الإقرار معتمد؛ أعد فتحه للتعديل', 'Return is locked');
    IF return_kind(r.tax_type_id) = 'WITHHOLDING' THEN
      DELETE FROM loc_tax_return_line WHERE tax_return_id = p_return_id AND box_code <> 'PAID';
      UPDATE loc_withholding_cert SET tax_return_id = NULL WHERE tax_return_id = p_return_id;
      UPDATE loc_withholding_cert SET tax_return_id = p_return_id
       WHERE company_id = l_co AND status_code = 'ISSUED' AND tax_return_id IS NULL AND NVL(payment_date, created_at) BETWEEN r.period_start AND r.period_end;
      FOR b IN (SELECT c.code, SUM(w.base_amount) base, SUM(w.withheld_amount) tax FROM loc_withholding_cert w JOIN loc_tax_code c ON c.id = w.tax_code_id
                 WHERE w.tax_return_id = p_return_id GROUP BY c.code) LOOP
        put_box(p_return_id, b.code, b.base, b.tax);
      END LOOP;
      SELECT NVL(SUM(withheld_amount), 0) INTO l_net FROM loc_withholding_cert WHERE tax_return_id = p_return_id;
      UPDATE loc_tax_return SET output_tax = l_net, input_tax = 0, net_payable = l_net, carry_forward = 0 WHERE id = p_return_id;
      RETURN;
    END IF;
    -- ضريبة القيمة المضافة: من السجل الموحد حسب الطبيعة والاتجاه
    DELETE FROM loc_tax_return_line WHERE tax_return_id = p_return_id AND box_code NOT IN ('14', 'PAID');
    FOR b IN (SELECT CASE WHEN direction = 'SALE' THEN
                            CASE nature WHEN 'STANDARD' THEN '1' WHEN 'CITIZEN' THEN '2' WHEN 'ZERO_RATED' THEN '3' WHEN 'EXPORT' THEN '4'
                                        WHEN 'EXEMPT' THEN '5' WHEN 'REVERSE_CHARGE' THEN '1' ELSE NULL END
                          ELSE CASE nature WHEN 'STANDARD' THEN '7' WHEN 'REVERSE_CHARGE' THEN '9' WHEN 'ZERO_RATED' THEN '10'
                                           WHEN 'EXEMPT' THEN '11' ELSE NULL END END box,
                     SUM(taxable_amount) base, SUM(tax_amount) tax
                FROM noona_v_tax_register
               WHERE company_id = l_co AND doc_date BETWEEN r.period_start AND r.period_end
               GROUP BY CASE WHEN direction = 'SALE' THEN
                            CASE nature WHEN 'STANDARD' THEN '1' WHEN 'CITIZEN' THEN '2' WHEN 'ZERO_RATED' THEN '3' WHEN 'EXPORT' THEN '4'
                                        WHEN 'EXEMPT' THEN '5' WHEN 'REVERSE_CHARGE' THEN '1' ELSE NULL END
                          ELSE CASE nature WHEN 'STANDARD' THEN '7' WHEN 'REVERSE_CHARGE' THEN '9' WHEN 'ZERO_RATED' THEN '10'
                                           WHEN 'EXEMPT' THEN '11' ELSE NULL END END) LOOP
      CONTINUE WHEN b.box IS NULL;
      put_box(p_return_id, b.box, b.base, b.tax);
    END LOOP;
    -- الاحتساب العكسي: ضريبة مخرجات ومدخلات معاً (أثره صفر على الصافي)
    SELECT NVL(SUM(CASE WHEN box_code IN ('1', '2', '3', '4', '5') THEN tax_amount END), 0),
           NVL(SUM(CASE WHEN box_code = '9' THEN tax_amount END), 0),
           NVL(SUM(CASE WHEN box_code IN ('7', '8', '9', '10', '11') THEN tax_amount END), 0)
      INTO l_out, l_rc, l_in FROM loc_tax_return_line WHERE tax_return_id = p_return_id;
    put_box(p_return_id, '6', NULL, l_out);
    l_out := l_out + l_rc;
    UPDATE loc_tax_return_line SET base_amount = (SELECT NVL(SUM(base_amount), 0) FROM loc_tax_return_line WHERE tax_return_id = p_return_id
                                                    AND box_code IN ('1', '2', '3', '4', '5'))
     WHERE tax_return_id = p_return_id AND box_code = '6';
    put_box(p_return_id, '12', NULL, l_in);
    UPDATE loc_tax_return_line SET base_amount = (SELECT NVL(SUM(base_amount), 0) FROM loc_tax_return_line WHERE tax_return_id = p_return_id
                                                    AND box_code IN ('7', '8', '9', '10', '11'))
     WHERE tax_return_id = p_return_id AND box_code = '12';
    put_box(p_return_id, '13', NULL, l_out - l_in);
    SELECT NVL(MAX(adjustment_amount), 0) INTO l_adj FROM loc_tax_return_line WHERE tax_return_id = p_return_id AND box_code = '14';
    put_box(p_return_id, '14', NULL, l_adj);
    -- الرصيد الدائن المرحل من آخر إقرار معتمد سابق (إن كان مستحقاً للاسترداد)
    SELECT NVL(MIN(net_payable) KEEP (DENSE_RANK LAST ORDER BY period_end), 0) INTO l_cf FROM loc_tax_return
     WHERE company_id = l_co AND tax_type_id = r.tax_type_id AND period_end < r.period_start AND status_code IN ('APPROVED', 'FILED', 'PAID', 'CLOSED');
    l_cf := GREATEST(-l_cf, 0);
    put_box(p_return_id, '15', NULL, l_cf);
    l_net := l_out - l_in + l_adj - l_cf;
    put_box(p_return_id, '16', NULL, l_net);
    UPDATE loc_tax_return SET output_tax = l_out, input_tax = l_in, carry_forward = l_cf, net_payable = l_net WHERE id = p_return_id;
  END recalc_return;

  FUNCTION new_return(p_kind IN VARCHAR2, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    l_type NUMBER;
    l_id   NUMBER;
    l_n    NUMBER;
    l_co   NUMBER := company;
    l_pack NUMBER := company_pack;
    l_reg  NUMBER;
  BEGIN
    guard('LOC_TAX_RETURN.CREATE');
    NOONA_CORE_PKG.assert(p_kind IN ('VAT', 'WHT'), 'NOONA-LOC-032', 'نوع الإقرار VAT أو WHT', 'Kind must be VAT or WHT');
    NOONA_CORE_PKG.assert(p_from IS NOT NULL AND p_to >= p_from, 'NOONA-LOC-033', 'حدد فترة صحيحة', 'Invalid period');
    NOONA_CORE_PKG.assert(p_to < TRUNC(SYSDATE) + 1, 'NOONA-LOC-034', 'لا يعد إقرار لفترة مستقبلية', 'Period cannot be in the future');
    SELECT MIN(t.id) INTO l_type FROM loc_tax_type t
     WHERE (t.country_pack_id = l_pack OR (l_pack IS NULL AND t.code = 'VAT'))
       AND t.tax_category = CASE p_kind WHEN 'VAT' THEN 'VAT' ELSE 'WITHHOLDING' END AND t.is_active = 'Y';
    NOONA_CORE_PKG.assert(l_type IS NOT NULL, 'NOONA-LOC-035', 'لا توجد ضريبة من هذا النوع في حزمة دولة الشركة', 'Tax type not in the country pack');
    SELECT COUNT(*) INTO l_n FROM loc_tax_return
     WHERE company_id = l_co AND tax_type_id = l_type AND period_start <= p_to AND period_end >= p_from AND status_code <> 'REOPENED';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-LOC-036', 'يوجد إقرار يغطي جزءاً من هذه الفترة', 'A return already covers this period');
    SELECT MIN(r.id) INTO l_reg FROM org_legal_registration r JOIN loc_registration_type t ON t.id = r.reg_type_id
     WHERE r.company_id = l_co AND t.is_tax_registration = 'Y' AND r.status_code = 'ACTIVE';
    INSERT INTO loc_tax_return (company_id, tax_type_id, registration_id, period_start, period_end, output_tax, input_tax, net_payable, carry_forward,
                                status_code)
    VALUES (l_co, l_type, l_reg, p_from, p_to, 0, 0, 0, 0, 'DRAFT')
    RETURNING id INTO l_id;
    recalc_return(l_id);
    RETURN l_id;
  END new_return;

  PROCEDURE set_adjustment(p_return_id IN NUMBER, p_box IN VARCHAR2, p_amount IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL) IS
    r loc_tax_return%ROWTYPE := get_return(p_return_id, TRUE);
  BEGIN
    guard('LOC_TAX_RETURN.UPDATE');
    NOONA_CORE_PKG.assert(r.status_code IN ('DRAFT', 'REOPENED'), 'NOONA-LOC-031', 'الإقرار معتمد؛ أعد فتحه للتعديل', 'Return is locked');
    NOONA_CORE_PKG.assert(p_box = '14' OR return_kind(r.tax_type_id) = 'VAT', 'NOONA-LOC-037', 'التعديل على خانة التصحيحات فقط',
                          'Only the corrections box can be adjusted');
    NOONA_CORE_PKG.assert(TRIM(p_note) IS NOT NULL, 'NOONA-LOC-038', 'اكتب سبب التصحيح ومرجعه', 'Explain the correction');
    MERGE INTO loc_tax_return_line l USING (SELECT p_return_id r, p_box b FROM dual) x ON (l.tax_return_id = x.r AND l.box_code = x.b)
     WHEN MATCHED THEN UPDATE SET l.adjustment_amount = ROUND(p_amount, 2)
     WHEN NOT MATCHED THEN INSERT (tax_return_id, box_code, base_amount, tax_amount, adjustment_amount) VALUES (p_return_id, p_box, 0, 0, ROUND(p_amount, 2));
    UPDATE loc_tax_return SET notes = SUBSTR(TRIM(notes || CHR(10) || 'تصحيح خانة ' || p_box || ': ' || p_note), 1, 2000) WHERE id = p_return_id;
    recalc_return(p_return_id);
  END set_adjustment;

  PROCEDURE review_return(p_return_id IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL) IS
    r loc_tax_return%ROWTYPE := get_return(p_return_id, TRUE);
  BEGIN
    guard('LOC_TAX_RETURN.UPDATE');
    NOONA_CORE_PKG.assert(r.status_code IN ('DRAFT', 'REOPENED'), 'NOONA-LOC-031', 'الإقرار ليس مسودة', 'Return is not a draft');
    recalc_return(p_return_id);
    UPDATE loc_tax_return SET status_code = 'REVIEWED',
                              notes = CASE WHEN TRIM(p_note) IS NOT NULL THEN SUBSTR(TRIM(notes || CHR(10) || 'مراجعة: ' || p_note), 1, 2000) ELSE notes END
     WHERE id = p_return_id;
  END review_return;

  PROCEDURE approve_return(p_return_id IN NUMBER) IS
    r       loc_tax_return%ROWTYPE := get_return(p_return_id, TRUE);
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_desc  VARCHAR2(400);
    l_j     NUMBER;
    l_ev    NUMBER;
    l_adj   NUMBER;
  BEGIN
    guard('LOC_TAX_RETURN.APPROVE');
    NOONA_CORE_PKG.assert(r.status_code = 'REVIEWED', 'NOONA-LOC-039', 'راجع الإقرار قبل اعتماده (مراجعة ثم اعتماد)', 'Review the return first');
    IF return_kind(r.tax_type_id) = 'VAT' THEN
      l_desc := 'تسوية إقرار ضريبة القيمة المضافة ' || ds(r.period_start) || ' - ' || ds(r.period_end);
      SELECT NVL(MAX(adjustment_amount), 0) INTO l_adj FROM loc_tax_return_line WHERE tax_return_id = p_return_id AND box_code = '14';
      -- إقفال ضريبة المخرجات والمدخلات للفترة في حساب التسوية المستحق للجهة
      add_line(l_lines, acc('OUTPUT'), r.output_tax, 0, NULL, l_desc);
      add_line(l_lines, acc('INPUT'), 0, r.input_tax, NULL, l_desc);
      IF l_adj > 0 THEN add_line(l_lines, acc('OUTPUT'), l_adj, 0, NULL, 'تصحيحات فترات سابقة'); END IF;
      IF l_adj < 0 THEN add_line(l_lines, acc('INPUT'), 0, -l_adj, NULL, 'تصحيحات فترات سابقة'); END IF;
      IF r.output_tax + l_adj - r.input_tax > 0 THEN
        add_line(l_lines, acc('SETTLE'), 0, r.output_tax + l_adj - r.input_tax, NULL, l_desc);
      ELSIF r.output_tax + l_adj - r.input_tax < 0 THEN
        add_line(l_lines, acc('SETTLE'), r.input_tax - r.output_tax - l_adj, 0, NULL, l_desc);
      END IF;
      IF l_lines.COUNT >= 2 THEN
        l_j := NOONA_ACE_PKG.post_source('LOC_VAT_RETURN_APPROVED', 'TAX', c_ret, p_return_id, r.period_end, l_desc,
                                         NOONA_GL_PKG.ledger_currency, 1, l_lines, 'VAT-' || TO_CHAR(r.period_end, 'YYYYMM'), NULL, 'TAX');
        SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
      END IF;
    END IF;
    UPDATE loc_tax_return SET status_code = 'APPROVED', accounting_event_id = l_ev WHERE id = p_return_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_ret, p_return_id, 'APPROVE', 'SUCCESS');
  END approve_return;

  PROCEDURE file_return(p_return_id IN NUMBER, p_reference IN VARCHAR2, p_filed_at IN DATE DEFAULT NULL) IS
    r loc_tax_return%ROWTYPE := get_return(p_return_id, TRUE);
  BEGIN
    guard('LOC_TAX_RETURN.APPROVE');
    NOONA_CORE_PKG.assert(r.status_code = 'APPROVED', 'NOONA-LOC-040', 'اعتمد الإقرار قبل تسجيل تقديمه', 'Approve the return first');
    NOONA_CORE_PKG.assert(TRIM(p_reference) IS NOT NULL, 'NOONA-LOC-041', 'أدخل رقم الإقرار أو مرجع التقديم في بوابة الجهة', 'Filing reference is required');
    UPDATE loc_tax_return SET status_code = CASE WHEN net_payable <= 0 THEN 'CLOSED' ELSE 'FILED' END, gov_reference = TRIM(p_reference),
                              filed_at = CAST(NVL(p_filed_at, SYSDATE) AS TIMESTAMP)
     WHERE id = p_return_id;
  END file_return;

  PROCEDURE pay_return(p_return_id IN NUMBER, p_place IN VARCHAR2, p_date IN DATE DEFAULT NULL) IS
    r       loc_tax_return%ROWTYPE := get_return(p_return_id, TRUE);
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_line  NUMBER;
    l_desc  VARCHAR2(400);
    l_j     NUMBER;
    l_ev    NUMBER;
    l_x     NUMBER;
    l_kind  VARCHAR2(30) := return_kind(r.tax_type_id);
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
  BEGIN
    guard('LOC_TAX_RETURN.APPROVE');
    NOONA_CORE_PKG.assert(r.status_code IN ('FILED', 'APPROVED') AND r.net_payable > 0, 'NOONA-LOC-042',
                          'يسدد الإقرار المعتمد أو المقدم الذي عليه مبلغ مستحق', 'Only an approved or filed return with an amount due is paid');
    NOONA_CORE_PKG.assert(p_place IS NOT NULL, 'NOONA-LOC-043', 'اختر البنك أو الصندوق المسدد منه', 'Choose the bank or cash box');
    l_desc := CASE l_kind WHEN 'VAT' THEN 'سداد ضريبة القيمة المضافة ' ELSE 'سداد ضريبة الاستقطاع ' END || ds(r.period_start) || ' - ' || ds(r.period_end)
           || NVL2(r.gov_reference, ' - ' || r.gov_reference, '');
    MERGE INTO loc_tax_return_line l USING (SELECT p_return_id rid FROM dual) x ON (l.tax_return_id = x.rid AND l.box_code = 'PAID')
     WHEN MATCHED THEN UPDATE SET l.tax_amount = r.net_payable
     WHEN NOT MATCHED THEN INSERT (tax_return_id, box_code, base_amount, tax_amount, adjustment_amount) VALUES (p_return_id, 'PAID', 0, r.net_payable, 0);
    SELECT id INTO l_line FROM loc_tax_return_line WHERE tax_return_id = p_return_id AND box_code = 'PAID';
    add_line(l_lines, CASE l_kind WHEN 'VAT' THEN acc('SETTLE') ELSE acc('WHT') END, r.net_payable, 0, NULL, l_desc);
    add_line(l_lines, NOONA_CSH_PKG.place_account(p_place), 0, r.net_payable, NULL, l_desc);
    l_j := NOONA_ACE_PKG.post_source('LOC_TAX_PAYMENT', 'TAX', c_line, l_line, l_date, l_desc, NOONA_GL_PKG.ledger_currency, 1, l_lines,
                                     r.gov_reference, NULL, 'TAX');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', p_place, l_date, r.net_payable, NULL,
                                           CASE l_kind WHEN 'VAT' THEN 'هيئة الضرائب - ضريبة القيمة المضافة' ELSE 'هيئة الضرائب - الاستقطاع' END,
                                           c_line, l_line, 'TX-' || l_line, l_desc, l_ev);
    UPDATE loc_tax_return SET status_code = 'PAID', paid_amount = r.net_payable, paid_at = CAST(l_date AS TIMESTAMP), payment_event_id = l_ev
     WHERE id = p_return_id;
  END pay_return;

  PROCEDURE reopen_return(p_return_id IN NUMBER, p_reason IN VARCHAR2) IS
    r   loc_tax_return%ROWTYPE := get_return(p_return_id, TRUE);
    l_j NUMBER;
  BEGIN
    guard('LOC_TAX_RETURN.APPROVE');
    NOONA_CORE_PKG.assert(r.status_code IN ('REVIEWED', 'APPROVED'), 'NOONA-LOC-044',
                          'يعاد فتح الإقرار قبل تقديمه فقط؛ بعد التقديم تصحح الفروق في خانة تصحيحات الإقرار التالي',
                          'Only a return not yet filed can be reopened');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-LOC-045', 'اكتب سبب إعادة الفتح', 'Reason is required');
    IF r.accounting_event_id IS NOT NULL THEN
      l_j := NOONA_ACE_PKG.reverse_source(c_ret, p_return_id, TRUNC(SYSDATE), p_reason);
    END IF;
    UPDATE loc_tax_return SET status_code = 'DRAFT', accounting_event_id = NULL,
                              notes = SUBSTR(TRIM(notes || CHR(10) || 'إعادة فتح: ' || p_reason), 1, 2000)
     WHERE id = p_return_id;
  END reopen_return;

  -- ================================================================ الاستقطاع
  FUNCTION is_non_resident(p_supplier_account_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(2);
  BEGIN
    SELECT MAX(p.country_code) INTO l FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
     WHERE a.id = p_supplier_account_id;
    RETURN CASE WHEN l IS NOT NULL AND l <> company_country THEN 'Y' ELSE 'N' END;
  END is_non_resident;

  FUNCTION withhold(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_sup   NUMBER := jn(l_o, 'supplier');
    l_code  VARCHAR2(50) := js(l_o, 'code');
    l_base  NUMBER := ROUND(jn(l_o, 'base'), 2);
    l_date  DATE := NVL(TO_DATE(js(l_o, 'date'), 'YYYY-MM-DD'), TRUNC(SYSDATE));
    l_srv   VARCHAR2(500) := js(l_o, 'service');
    l_tc    NUMBER;
    l_rate  NUMBER;
    l_amt   NUMBER;
    l_party NUMBER;
    l_pname VARCHAR2(400);
    l_ap    NUMBER;
    l_open  NUMBER;
    l_left  NUMBER;
    l_id    NUMBER;
    l_no    VARCHAR2(50);
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_co    NUMBER := company;
    l_cur   VARCHAR2(3) := NOONA_GL_PKG.ledger_currency;
    l_x     NUMBER;
  BEGIN
    guard('LOC_WITHHOLDING_CERT.CREATE');
    NOONA_CORE_PKG.assert(l_sup IS NOT NULL AND NVL(l_base, 0) > 0, 'NOONA-LOC-050', 'اختر المورد والمبلغ الخاضع للاستقطاع', 'Supplier and base are required');
    SELECT MIN(c.id) INTO l_tc FROM loc_tax_code c JOIN loc_tax_type t ON t.id = c.tax_type_id
     WHERE c.code = l_code AND t.tax_category = 'WITHHOLDING' AND c.status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(l_tc IS NOT NULL, 'NOONA-LOC-051', 'كود الاستقطاع غير معروف', 'Unknown withholding code');
    l_rate := rate_on(l_tc, l_date);
    l_amt := ROUND(l_base * l_rate / 100, 2);
    SELECT s.party_id, p.display_name_ar, NVL(a.payable_account_id, NOONA_INV_PKG.acc_id('2101'))
      INTO l_party, l_pname, l_ap
      FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
     WHERE a.id = l_sup AND a.company_id = l_co;
    -- الاستقطاع يخصم مما يستحق للمورد: يكفيه رصيد ذممه المفتوحة
    SELECT NVL(SUM(open_amount), 0) INTO l_open FROM ap_open_item
     WHERE supplier_account_id = l_sup AND company_id = l_co AND item_type = 'INVOICE' AND open_amount > 0;
    NOONA_CORE_PKG.assert(l_open >= l_amt, 'NOONA-LOC-052', 'المستحق للمورد (' || fmt(l_open) || ') أقل من مبلغ الاستقطاع (' || fmt(l_amt)
                          || '): سجل فاتورته أولاً ثم استقطع عند السداد', 'Supplier balance is less than the withholding');
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT l_co, 'LOC_WHT', NULL, 'WHT-', 1, 5, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = l_co AND doc_type_code = 'LOC_WHT');
    l_no := NOONA_REFERENCE_PKG.next_doc_no('LOC_WHT', l_co, NULL, l_date, c_wht, NULL);
    INSERT INTO loc_withholding_cert (company_id, certificate_no, party_id, supplier_account_id, tax_code_id, base_amount, rate_pct, withheld_amount,
                                      currency_code, payment_date, due_date, service_desc, status_code)
    VALUES (l_co, l_no, l_party, l_sup, l_tc, l_base, l_rate, l_amt, l_cur, l_date,
            LAST_DAY(l_date) + 10, l_srv, 'ISSUED')
    RETURNING id INTO l_id;
    -- القيد: يخفض الدائنين ويقيد الاستقطاع المستحق للجهة
    add_line(l_lines, l_ap, l_amt, 0, l_party, 'استقطاع ' || l_no || ' - ' || l_pname);
    add_line(l_lines, acc('WHT'), 0, l_amt, NULL, 'استقطاع ' || pct(l_rate) || ' من ' || l_pname || ' - ' || l_no || NVL2(l_srv, ' - ' || l_srv, ''));
    l_j := NOONA_ACE_PKG.post_source('LOC_WHT_WITHHELD', 'TAX', c_wht, l_id, l_date, 'استقطاع ' || l_no || ' - ' || l_pname, l_cur, 1, l_lines,
                                     l_no, NULL, 'TAX');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    UPDATE loc_withholding_cert SET accounting_event_id = l_ev WHERE id = l_id;
    -- تخفيض أقدم ذمم المورد بالمبلغ المستقطع
    l_left := l_amt;
    FOR oi IN (SELECT id, open_amount FROM ap_open_item WHERE supplier_account_id = l_sup AND company_id = l_co AND item_type = 'INVOICE'
                  AND open_amount > 0 ORDER BY due_date, id FOR UPDATE) LOOP
      EXIT WHEN l_left <= 0;
      l_x := LEAST(oi.open_amount, l_left);
      UPDATE ap_open_item SET open_amount = open_amount - l_x, open_func = open_func - l_x,
                              status_code = CASE WHEN open_amount - l_x = 0 THEN 'PAID' ELSE 'PARTIALLY_PAID' END
       WHERE id = oi.id;
      l_left := l_left - l_x;
    END LOOP;
    RETURN l_id;
  END withhold;

  PROCEDURE cancel_withholding(p_cert_id IN NUMBER, p_reason IN VARCHAR2) IS
    l  loc_withholding_cert%ROWTYPE;
    l_j NUMBER;
  BEGIN
    guard('LOC_WITHHOLDING_CERT.UPDATE');
    SELECT * INTO l FROM loc_withholding_cert WHERE id = p_cert_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'ISSUED', 'NOONA-LOC-053', 'الشهادة ملغاة سابقاً', 'Certificate already cancelled');
    NOONA_CORE_PKG.assert(l.tax_return_id IS NULL OR return_status(l.tax_return_id) IN ('DRAFT', 'REOPENED'), 'NOONA-LOC-054',
                          'الشهادة ضمن إقرار استقطاع معتمد', 'Certificate is in an approved return');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-LOC-045', 'اكتب سبب الإلغاء', 'Reason is required');
    l_j := NOONA_ACE_PKG.reverse_source(c_wht, p_cert_id, TRUNC(SYSDATE), p_reason);
    -- يعود المبلغ مستحقاً للمورد
    INSERT INTO ap_open_item (company_id, currency_code, exchange_rate, supplier_account_id, item_type, doc_no, due_date, installment_no,
                              original_amount, open_amount, original_func, open_func, status_code)
    VALUES (company, l.currency_code, 1, l.supplier_account_id, 'INVOICE', l.certificate_no || '-R', TRUNC(SYSDATE), 1,
            l.withheld_amount, l.withheld_amount, l.withheld_amount, l.withheld_amount, 'OPEN');
    UPDATE loc_withholding_cert SET status_code = 'CANCELLED', tax_return_id = NULL WHERE id = p_cert_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-LOC-055', 'الشهادة غير موجودة', 'Certificate not found');
  END cancel_withholding;

  -- ================================================================ الشاشات
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION summary_html RETURN CLOB IS
    l_cc   VARCHAR2(2) := company_country;
    l_name VARCHAR2(200);
    l_pack VARCHAR2(200);
    l_std  NUMBER;
    l_trn  VARCHAR2(100) := company_tax_number;
    l_out  NUMBER; l_in NUMBER;
    l_open NUMBER;
    l_wht  NUMBER;
    l_co   NUMBER := company;
    l_from DATE := TRUNC(SYSDATE, 'Q');
  BEGIN
    guard('LOC_TAX_RETURN.VIEW');
    SELECT MAX(c.name_ar), MAX(p.name_ar) INTO l_name, l_pack FROM ref_country c LEFT JOIN loc_country_pack p ON p.id = company_pack WHERE c.country_code = l_cc;
    l_std := rate_on(NOONA_INV_PKG.tax_id('VAT15'));
    SELECT NVL(SUM(CASE WHEN direction = 'SALE' THEN tax_amount END), 0), NVL(SUM(CASE WHEN direction = 'PURCHASE' THEN tax_amount END), 0)
      INTO l_out, l_in FROM noona_v_tax_register WHERE company_id = l_co AND doc_date >= l_from;
    SELECT COUNT(*) INTO l_open FROM loc_tax_return WHERE company_id = l_co AND status_code IN ('DRAFT', 'REVIEWED', 'APPROVED', 'FILED', 'REOPENED');
    SELECT NVL(SUM(withheld_amount), 0) INTO l_wht FROM loc_withholding_cert WHERE company_id = l_co AND status_code = 'ISSUED' AND tax_return_id IS NULL;
    RETURN '<div class="nn-prj-chips"><span>الدولة: ' || esc(l_name) || '</span><span>' || esc(NVL(l_pack, 'لم تطبق حزمة الدولة بعد')) || '</span>'
        || '<span>ضريبة القيمة المضافة الأساسية: ' || pct(l_std) || '</span><span>الرقم الضريبي: ' || esc(NVL(l_trn, 'غير مسجل')) || '</span></div>'
        || '<div class="nn-kpis">'
        || kpi('ضريبة المخرجات (هذا الربع)', fmt(l_out), 'fa-arrow-up', 'is-warning')
        || kpi('ضريبة المدخلات (هذا الربع)', fmt(l_in), 'fa-arrow-down', 'is-success')
        || kpi('الصافي التقديري', fmt(l_out - l_in), 'fa-balance-scale', 'is-info')
        || kpi('إقرارات غير مسددة/مقفلة', l_open, 'fa-file-text-o', CASE WHEN l_open > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('استقطاع غير مدرج في إقرار', fmt(l_wht), 'fa-scissors', CASE WHEN l_wht > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || '</div>';
  END summary_html;

  FUNCTION pack_html(p_country IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_cc   VARCHAR2(2) := NVL(p_country, company_country);
    l_h    CLOB;
    l_pk   loc_country_pack%ROWTYPE;
    l_hist VARCHAR2(4000);
  BEGIN
    BEGIN
      SELECT * INTO l_pk FROM loc_country_pack WHERE country_code = l_cc AND version_no = (SELECT MAX(version_no) FROM loc_country_pack WHERE country_code = l_cc);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN '<div class="nn-empty">لا توجد حزمة لهذه الدولة</div>';
    END;
    l_h := '<div class="nn-prj-chips"><span>' || esc(l_pk.name_ar) || ' - الإصدار ' || l_pk.version_no || '</span><span>التقويم: '
        || CASE l_pk.display_calendar WHEN 'BOTH' THEN 'ميلادي وهجري (أم القرى)' WHEN 'HIJRI_UMM_ALQURA' THEN 'هجري' ELSE 'ميلادي' END || '</span>'
        || badge(CASE l_pk.status_code WHEN 'PUBLISHED' THEN 'ISSUED' ELSE 'DRAFT' END) || '</div>'
        || '<p class="nn-hint">' || esc(l_pk.legal_reference) || '</p>'
        || '<table class="nn-prj-t"><thead><tr><th>الضريبة</th><th>الكود</th><th>الطبيعة</th><th>النسبة السارية</th><th>تاريخ الإصدارات</th>'
        || '<th>فئة الفاتورة الإلكترونية</th></tr></thead><tbody>';
    FOR c IN (SELECT t.name_ar tname, c.id, c.code, c.name_ar, c.tax_nature, c.einvoice_category FROM loc_tax_code c JOIN loc_tax_type t ON t.id = c.tax_type_id
               WHERE t.country_pack_id = l_pk.id AND c.status_code = 'ACTIVE' ORDER BY t.tax_category DESC, t.code, c.code) LOOP
      SELECT LISTAGG('v' || version_no || ': ' || RTRIM(RTRIM(TO_CHAR(rate_pct, 'FM990.99', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.') || '% من '
                     || TO_CHAR(effective_from, 'YYYY-MM-DD') || NVL2(effective_to, ' إلى ' || TO_CHAR(effective_to, 'YYYY-MM-DD'), ''), ' · ')
             WITHIN GROUP (ORDER BY version_no)
        INTO l_hist FROM loc_tax_rate WHERE tax_code_id = c.id;
      l_h := l_h || '<tr><td>' || esc(c.tname) || '</td><td><b>' || esc(c.code) || '</b><br><small>' || esc(c.name_ar) || '</small></td><td>'
          || esc(nature_label(c.tax_nature)) || '</td><td class="n">' || pct(rate_on(c.id)) || '</td><td><small>' || esc(l_hist) || '</small></td><td>'
          || esc(c.einvoice_category) || '</td></tr>';
    END LOOP;
    l_h := l_h || '</tbody></table><h4 class="nn-prj-h">التسجيلات القانونية</h4><table class="nn-prj-t"><thead><tr><th>التسجيل</th><th>ضريبي</th>'
        || '<th>صيغة الرقم</th><th>تنبيه قبل الانتهاء</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM loc_registration_type WHERE country_pack_id = l_pk.id AND is_active = 'Y' ORDER BY is_tax_registration DESC, code) LOOP
      l_h := l_h || '<tr><td>' || esc(r.name_ar) || '</td><td>' || CASE WHEN r.is_tax_registration = 'Y' THEN 'نعم' END || '</td><td dir="ltr">'
          || esc(r.validation_regex) || '</td><td>' || CASE WHEN r.expiry_alert_days IS NOT NULL THEN r.expiry_alert_days || ' يوم' END || '</td></tr>';
    END LOOP;
    l_h := l_h || '</tbody></table><h4 class="nn-prj-h">الأشكال القانونية</h4><p>';
    FOR f IN (SELECT name_ar FROM loc_legal_form WHERE country_pack_id = l_pk.id AND is_active = 'Y' ORDER BY code) LOOP
      l_h := l_h || '<span class="nn-badge is-muted">' || esc(f.name_ar) || '</span> ';
    END LOOP;
    RETURN l_h || '</p>';
  END pack_html;

  FUNCTION registrations_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('ORG_LEGAL_REGISTRATION.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>التسجيل</th><th>الرقم</th><th>الجهة</th><th>الإصدار</th><th>الانتهاء</th><th>رئيسي</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT g.*, t.name_ar tname, t.expiry_alert_days FROM org_legal_registration g JOIN loc_registration_type t ON t.id = g.reg_type_id
               WHERE g.company_id = company AND g.status_code <> 'CANCELLED' ORDER BY t.is_tax_registration DESC, t.code) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr><td>' || esc(r.tname) || '</td><td dir="ltr"><b>' || esc(r.reg_number) || '</b></td><td>' || esc(r.issuing_authority) || '</td><td>'
          || ds(r.issue_date) || '</td><td' || CASE WHEN r.expiry_date < TRUNC(SYSDATE) + NVL(r.expiry_alert_days, 30) THEN ' class="is-over"' END || '>'
          || ds(r.expiry_date) || '</td><td>' || CASE WHEN r.is_primary = 'Y' THEN 'نعم' END || '</td><td>'
          || CASE WHEN r.expiry_date < TRUNC(SYSDATE) THEN '<span class="nn-badge is-danger">منتهي</span>'
                  WHEN r.expiry_date < TRUNC(SYSDATE) + NVL(r.expiry_alert_days, 30) THEN '<span class="nn-badge is-warning">قريب الانتهاء</span>'
                  ELSE '<span class="nn-badge is-success">ساري</span>' END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد تسجيلات؛ أضف السجل التجاري والرقم الضريبي للشركة</div>' ELSE l_h || '</tbody></table>' END;
  END registrations_html;

  FUNCTION return_html(p_return_id IN NUMBER) RETURN CLOB IS
    r      loc_tax_return%ROWTYPE := get_return(p_return_id);
    l_kind VARCHAR2(30) := return_kind(r.tax_type_id);
    l_cc   VARCHAR2(2) := company_country;
    l_h    CLOB;
    l_tn   VARCHAR2(200);
    l_late NUMBER;
    l_co   NUMBER := company;
  BEGIN
    guard('LOC_TAX_RETURN.VIEW');
    SELECT name_ar INTO l_tn FROM loc_tax_type WHERE id = r.tax_type_id;
    l_h := '<div class="nn-prj-chips"><span>' || esc(l_tn) || '</span><span>الفترة ' || ds(r.period_start) || ' إلى ' || ds(r.period_end) || '</span>'
        || '<span>الرقم الضريبي ' || esc(NVL(company_tax_number, '—')) || '</span>' || badge(r.status_code)
        || CASE WHEN r.gov_reference IS NOT NULL THEN '<span>مرجع الجهة ' || esc(r.gov_reference) || '</span>' END || '</div>'
        || '<table class="nn-prj-t nn-loc-ret"><thead><tr><th>الخانة</th><th class="n">المبلغ (الأساس)</th><th class="n">التعديلات</th>'
        || '<th class="n">مبلغ الضريبة</th></tr></thead><tbody>';
    IF l_kind = 'WITHHOLDING' THEN
      FOR b IN (SELECT l.*, c.name_ar FROM loc_tax_return_line l LEFT JOIN loc_tax_code c ON c.code = l.box_code AND c.tenant_id IS NULL
                 WHERE l.tax_return_id = p_return_id AND l.box_code <> 'PAID' ORDER BY l.box_code) LOOP
        l_h := l_h || '<tr><td>' || esc(NVL(b.name_ar, b.box_code)) || '</td><td class="n">' || fmt(b.base_amount) || '</td><td class="n"></td><td class="n">'
            || fmt(b.tax_amount) || '</td></tr>';
      END LOOP;
      l_h := l_h || '<tr class="is-total"><td>إجمالي الاستقطاع المستحق للتوريد</td><td></td><td></td><td class="n">' || fmt(r.net_payable) || '</td></tr>';
    ELSE
      FOR b IN (SELECT column_value box FROM TABLE(sys.odcivarchar2list('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16'))) LOOP
        CONTINUE WHEN l_cc <> 'SA' AND b.box IN ('2', '4', '5', '8', '10', '11');
        FOR x IN (SELECT NVL(MAX(base_amount), 0) base, NVL(MAX(tax_amount), 0) tax, NVL(MAX(adjustment_amount), 0) adj FROM loc_tax_return_line
                   WHERE tax_return_id = p_return_id AND box_code = b.box) LOOP
          l_h := l_h || '<tr' || CASE WHEN b.box IN ('6', '12') THEN ' class="is-sub"' WHEN b.box IN ('13', '16') THEN ' class="is-total"' END || '><td>'
              || esc(box_label(l_cc, b.box)) || '</td><td class="n">' || CASE WHEN TO_NUMBER(b.box) <= 12 THEN fmt(x.base) END || '</td><td class="n">'
              || CASE WHEN b.box = '14' THEN fmt(x.adj) END || '</td><td class="n">' || fmt(x.tax) || '</td></tr>';
        END LOOP;
      END LOOP;
    END IF;
    l_h := l_h || '</tbody></table>';
    IF l_kind = 'VAT' AND r.status_code IN ('APPROVED', 'FILED', 'PAID', 'CLOSED') THEN
      -- مستندات أضيفت أو عدلت للفترة بعد الاعتماد: تصحح في الإقرار التالي
      SELECT NVL(SUM(CASE WHEN direction = 'SALE' THEN tax_amount ELSE -tax_amount END), 0) INTO l_late FROM noona_v_tax_register
       WHERE company_id = l_co AND doc_date BETWEEN r.period_start AND r.period_end;
      IF ROUND(l_late - (r.output_tax - r.input_tax), 2) <> 0 THEN
        l_h := l_h || '<div class="nn-empty is-warning">تغير صافي ضريبة الفترة في السجل بعد اعتماد الإقرار بمقدار '
            || fmt(l_late - (r.output_tax - r.input_tax)) || ' (مستندات بتاريخ الفترة رحلت بعده): أدرجه في خانة التصحيحات في الإقرار التالي</div>';
      END IF;
    END IF;
    IF r.notes IS NOT NULL THEN
      l_h := l_h || '<p class="nn-hint">' || REPLACE(esc(r.notes), CHR(10), '<br>') || '</p>';
    END IF;
    RETURN l_h;
  END return_html;

  FUNCTION returns_html(p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('LOC_TAX_RETURN.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الإقرار</th><th>الفترة</th><th class="n">المخرجات</th><th class="n">المدخلات</th><th class="n">الصافي</th>'
        || '<th>مرجع الجهة</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT x.*, t.name_ar tname FROM loc_tax_return x JOIN loc_tax_type t ON t.id = x.tax_type_id
               WHERE x.company_id = company ORDER BY x.period_end DESC, x.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(r.tname) || '</a>' ELSE esc(r.tname) END
          || '</td><td>' || ds(r.period_start) || ' &larr; ' || ds(r.period_end) || '</td><td class="n">' || fmt(r.output_tax) || '</td><td class="n">'
          || fmt(r.input_tax) || '</td><td class="n"><b>' || fmt(r.net_payable) || '</b></td><td>' || esc(r.gov_reference) || '</td><td>' || badge(r.status_code)
          || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد إقرارات بعد</div>' ELSE l_h || '</tbody></table>' END;
  END returns_html;

  FUNCTION register_html(p_from IN DATE, p_to IN DATE, p_direction IN VARCHAR2 DEFAULT NULL, p_nature IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    t_b NUMBER := 0; t_t NUMBER := 0;
    l_co NUMBER := company;
  BEGIN
    guard('LOC_TAX_RETURN.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>التاريخ</th><th>المصدر</th><th>المستند</th><th>الطرف</th><th>الرقم الضريبي</th><th>النوع</th>'
        || '<th>الطبيعة</th><th class="n">الأساس</th><th class="n">الضريبة</th></tr></thead><tbody>';
    FOR r IN (SELECT doc_date, source_type, doc_no, party_name, party_tax_no, direction, nature, SUM(taxable_amount) base, SUM(tax_amount) tax
                FROM noona_v_tax_register
               WHERE company_id = l_co AND doc_date BETWEEN p_from AND p_to AND (p_direction IS NULL OR direction = p_direction)
                 AND (p_nature IS NULL OR nature = p_nature)
               GROUP BY doc_date, source_type, source_id, doc_no, party_name, party_tax_no, direction, nature
               ORDER BY doc_date, source_type, doc_no FETCH FIRST 2000 ROWS ONLY) LOOP
      l_n := l_n + 1;
      t_b := t_b + r.base; t_t := t_t + r.tax;
      l_h := l_h || '<tr><td>' || ds(r.doc_date) || '</td><td>' || CASE r.source_type WHEN 'SAL_INVOICE' THEN 'فاتورة مبيعات' WHEN 'POS_SALE' THEN 'نقطة بيع'
             WHEN 'AP_INVOICE' THEN 'فاتورة مورد' WHEN 'HIS_INVOICE' THEN 'فاتورة طبية' WHEN 'HSP_FOLIO_LINE' THEN 'كشف نزيل'
             WHEN 'PRJ_PROGRESS_CLAIM' THEN 'مستخلص' WHEN 'FA_DISPOSAL' THEN 'بيع أصل' ELSE r.source_type END || '</td><td>' || esc(r.doc_no) || '</td><td>'
          || esc(r.party_name) || '</td><td dir="ltr">' || esc(r.party_tax_no) || '</td><td>' || CASE r.direction WHEN 'SALE' THEN 'مخرجات' ELSE 'مدخلات' END
          || '</td><td>' || esc(nature_label(r.nature)) || '</td><td class="n">' || fmt(r.base) || '</td><td class="n">' || fmt(r.tax) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد مستندات ضريبية في الفترة</div>'
                ELSE l_h || '</tbody><tfoot><tr><td colspan="7">الإجمالي (' || l_n || ')</td><td class="n">' || fmt(t_b) || '</td><td class="n">' || fmt(t_t)
                    || '</td></tr></tfoot></table>' END;
  END register_html;

  FUNCTION withholding_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('LOC_WITHHOLDING_CERT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الشهادة</th><th>التاريخ</th><th>المورد</th><th>الكود</th><th>الخدمة</th><th class="n">الأساس</th>'
        || '<th class="n">النسبة</th><th class="n">المستقطع</th><th>موعد التوريد</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT w.*, p.display_name_ar pname, c.code tcode FROM loc_withholding_cert w JOIN pty_party p ON p.id = w.party_id JOIN loc_tax_code c ON c.id = w.tax_code_id
               WHERE w.company_id = company AND w.payment_date BETWEEN p_from AND p_to ORDER BY w.payment_date DESC, w.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr' || CASE WHEN r.status_code = 'CANCELLED' THEN ' class="is-void"' END || '><td data-cert="' || r.id || '"><b>' || esc(r.certificate_no) || '</b></td><td>'
          || ds(r.payment_date) || '</td><td>' || esc(r.pname) || '</td><td>' || esc(r.tcode) || '</td><td>' || esc(r.service_desc) || '</td><td class="n">'
          || fmt(r.base_amount) || '</td><td class="n">' || pct(r.rate_pct) || '</td><td class="n">' || fmt(r.withheld_amount) || '</td><td>' || ds(r.due_date)
          || '</td><td>' || badge(r.status_code) || CASE WHEN r.tax_return_id IS NOT NULL THEN ' <span class="nn-badge is-muted">ضمن إقرار</span>' END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد شهادات استقطاع في الفترة</div>' ELSE l_h || '</tbody></table>' END;
  END withholding_html;

  FUNCTION certificate_html(p_cert_id IN NUMBER) RETURN CLOB IS
    l    loc_withholding_cert%ROWTYPE;
    l_p  pty_party%ROWTYPE;
    l_cn VARCHAR2(400);
  BEGIN
    guard('LOC_WITHHOLDING_CERT.VIEW');
    SELECT * INTO l FROM loc_withholding_cert WHERE id = p_cert_id AND company_id = company;
    SELECT * INTO l_p FROM pty_party WHERE id = l.party_id;
    SELECT name_ar INTO l_cn FROM loc_tax_code WHERE id = l.tax_code_id;
    RETURN '<div class="nn-prj-cert"><div class="nn-prj-cert-head"><div><b>' || esc(NOONA_APEX_PKG.company_name) || '</b><div>الرقم الضريبي '
        || esc(company_tax_number) || '</div></div><div class="nn-prj-cert-no">شهادة استقطاع ضريبي<small>' || esc(l.certificate_no) || '</small></div></div>'
        || '<table class="nn-prj-cert-info"><tr><th>المستفيد (المورد)</th><td>' || esc(l_p.display_name_ar) || '</td><th>الدولة</th><td>' || esc(l_p.country_code)
        || '</td></tr><tr><th>الرقم الضريبي للمستفيد</th><td>' || esc(l_p.tax_number) || '</td><th>تاريخ الدفع</th><td>' || ds(l.payment_date) || '</td></tr>'
        || '<tr><th>طبيعة الخدمة</th><td colspan="3">' || esc(l.service_desc) || '</td></tr></table>'
        || '<table class="nn-prj-cert-sum"><tr><th>المبلغ المدفوع (الأساس)</th><td>' || fmt(l.base_amount) || ' ' || esc(l.currency_code) || '</td></tr>'
        || '<tr><th>' || esc(l_cn) || '</th><td>' || pct(l.rate_pct) || '</td></tr>'
        || '<tr class="is-total"><th>الضريبة المستقطعة</th><td>' || fmt(l.withheld_amount) || '</td></tr></table>'
        || '<p class="nn-hint">تورد الضريبة المستقطعة للجهة الضريبية خلال المهلة النظامية (حتى ' || ds(l.due_date) || ').</p>'
        || CASE WHEN l.status_code = 'CANCELLED' THEN '<div class="nn-prj-draft">ملغاة</div>' END || '</div>';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">الشهادة غير موجودة</div>';
  END certificate_html;

  FUNCTION wht_due_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h  CLOB;
    l_n  PLS_INTEGER := 0;
    l_cc VARCHAR2(2) := company_country;
  BEGIN
    guard('LOC_WITHHOLDING_CERT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>السداد</th><th>التاريخ</th><th>المورد</th><th>الدولة</th><th class="n">المبلغ</th><th>شهادات الاستقطاع</th></tr></thead><tbody>';
    FOR r IN (SELECT y.doc_no, y.doc_date, y.amount, p.display_name_ar pname, p.country_code, y.supplier_account_id,
                     (SELECT COUNT(*) FROM loc_withholding_cert w WHERE w.supplier_account_id = y.supplier_account_id AND w.status_code = 'ISSUED'
                         AND w.payment_date BETWEEN p_from AND p_to) certs
                FROM ap_payment y JOIN ap_supplier_account a ON a.id = y.supplier_account_id JOIN ap_supplier s ON s.id = a.supplier_id
                JOIN pty_party p ON p.id = s.party_id
               WHERE y.company_id = company AND y.doc_date BETWEEN p_from AND p_to AND y.status_code NOT IN ('DRAFT', 'CANCELLED', 'REVERSED')
                 AND p.country_code IS NOT NULL AND p.country_code <> l_cc ORDER BY y.doc_date) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr><td>' || esc(r.doc_no) || '</td><td>' || ds(r.doc_date) || '</td><td>' || esc(r.pname) || '</td><td>' || esc(r.country_code) || '</td><td class="n">'
          || fmt(r.amount) || '</td><td>' || CASE WHEN r.certs > 0 THEN '<span class="nn-badge is-success">' || r.certs || ' شهادة</span>'
                                                 ELSE '<span class="nn-badge is-warning">لا توجد شهادة</span>' END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد مدفوعات لموردين غير مقيمين في الفترة</div>' ELSE l_h || '</tbody></table>' END;
  END wht_due_html;
END NOONA_LOC_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_LOC_PKG
