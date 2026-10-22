-- =============================================================================
-- NOONA PLUS ERP | NOONA_REFDATA_PKG - إدارة البيانات المرجعية للمؤسسة
--   * أنواع وأسعار الصرف (مع اعتماد بأربع أعين عند طلب نوع السعر ذلك)
--   * شروط الدفع وأقساطها
--   * تسلسلات المستندات (لا يرجع الرقم التالي للخلف حتى لا تتكرر الأرقام)
-- كل عملية: صلاحية + حالة المؤسسة قابلة للكتابة + تدقيق.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_REFDATA_PKG AUTHID DEFINER AS

  FUNCTION create_rate_type(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_category IN VARCHAR2 DEFAULT 'MANUAL',
                            p_requires_approval IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;
  -- سعر الصرف للشركة الحالية (لكل شركة أسعارها): معتمد مباشرة، أو مسودة إن تطلب نوع السعر الاعتماد
  FUNCTION add_rate(p_rate_type_id IN NUMBER, p_from IN VARCHAR2, p_to IN VARCHAR2, p_rate_date IN DATE,
                    p_rate IN NUMBER, p_reason IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- اعتماد سعر مسودة: لا يعتمده من أدخله (NOONA-REF-104)، ولا يعتمد سعر شركة أخرى (NOONA-REF-109)
  PROCEDURE approve_rate(p_rate_id IN NUMBER);
  PROCEDURE reject_rate(p_rate_id IN NUMBER, p_reason IN VARCHAR2);

  FUNCTION create_payment_term(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_base_rule IN VARCHAR2 DEFAULT 'DOC_DATE',
                               p_due_days IN NUMBER DEFAULT 0, p_discount_pct IN NUMBER DEFAULT NULL,
                               p_discount_days IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- قسط: نسبة من المبلغ تستحق بعد عدد أيام؛ مجموع النسب لا يتجاوز 100
  PROCEDURE add_installment(p_term_id IN NUMBER, p_due_pct IN NUMBER, p_due_days IN NUMBER);
  PROCEDURE set_term_active(p_term_id IN NUMBER, p_active IN VARCHAR2);

  FUNCTION create_doc_sequence(p_company_id IN NUMBER, p_doc_type IN VARCHAR2, p_fiscal_year IN NUMBER,
                               p_prefix IN VARCHAR2, p_branch_id IN NUMBER DEFAULT NULL, p_padding IN NUMBER DEFAULT 6,
                               p_gapless IN VARCHAR2 DEFAULT 'N', p_reset IN VARCHAR2 DEFAULT 'YEARLY') RETURN NUMBER;
  PROCEDURE update_doc_sequence(p_sequence_id IN NUMBER, p_prefix IN VARCHAR2, p_next_number IN NUMBER,
                                p_active IN VARCHAR2);
  -- معاينة الرقم التالي كما سيصدر
  FUNCTION preview_doc_no(p_sequence_id IN NUMBER) RETURN VARCHAR2;
END NOONA_REFDATA_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_REFDATA_PKG AS

  PROCEDURE guard(p_permission VARCHAR2, p_company_id NUMBER DEFAULT NULL) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, p_company_id);
  END guard;

  -- أسعار الصرف خاصة بكل شركة: لا يعتمد أو يرفض سعر شركة غير الشركة الحالية
  PROCEDURE same_company(p_company_id NUMBER) IS
  BEGIN
    NOONA_CORE_PKG.assert(NVL(p_company_id = NOONA_CTX_PKG.company_id, FALSE), 'NOONA-REF-109', 'السعر يخص شركة أخرى',
      'The rate belongs to another company');
  END same_company;

  PROCEDURE assert_currency(p_code VARCHAR2) IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM ref_currency WHERE currency_code = p_code AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-REF-101', 'العملة غير معرفة أو غير فعالة: ' || p_code, 'Unknown currency');
  END assert_currency;

  -- ---------------------------------------------------------------- أسعار الصرف
  FUNCTION create_rate_type(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_category IN VARCHAR2 DEFAULT 'MANUAL',
                            p_requires_approval IN VARCHAR2 DEFAULT 'N') RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    guard('REF_RATE_TYPE.CREATE');
    INSERT INTO ref_rate_type (code, name_ar, rate_category, requires_approval, is_active)
    VALUES (UPPER(TRIM(p_code)), p_name_ar, NVL(p_category, 'MANUAL'), NVL(p_requires_approval, 'N'), 'Y')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'REF_RATE_TYPE', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-REF-100', 'رمز نوع السعر مستخدم', 'Rate type code already exists');
  END create_rate_type;

  FUNCTION add_rate(p_rate_type_id IN NUMBER, p_from IN VARCHAR2, p_to IN VARCHAR2, p_rate_date IN DATE,
                    p_rate IN NUMBER, p_reason IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_type ref_rate_type%ROWTYPE;
    l_id   NUMBER;
    l_co   NUMBER := NOONA_CTX_PKG.company_id;
  BEGIN
    NOONA_CORE_PKG.assert(l_co IS NOT NULL, 'NOONA-REF-108', 'اختر الشركة أولاً: أسعار الصرف خاصة بكل شركة',
      'Select a company first: exchange rates are per company');
    guard('REF_EXCHANGE_RATE.CREATE', l_co);
    SELECT * INTO l_type FROM ref_rate_type WHERE id = p_rate_type_id;
    assert_currency(p_from);
    assert_currency(p_to);
    NOONA_CORE_PKG.assert(p_from <> p_to, 'NOONA-REF-102', 'العملتان متطابقتان', 'Currencies must differ');
    NOONA_CORE_PKG.assert(p_rate > 0, 'NOONA-REF-103', 'السعر يجب أن يكون أكبر من صفر', 'Rate must be positive');
    INSERT INTO ref_exchange_rate (company_id, rate_type_id, from_currency, to_currency, rate_date, effective_at, rate,
                                   inverse_rate, source_code, reason, status_code, approved_by)
    VALUES (l_co, p_rate_type_id, p_from, p_to, TRUNC(p_rate_date), CAST(TRUNC(p_rate_date) AS TIMESTAMP), p_rate,
            ROUND(1 / p_rate, 10), 'MANUAL', p_reason,
            CASE l_type.requires_approval WHEN 'Y' THEN 'DRAFT' ELSE 'APPROVED' END,
            CASE l_type.requires_approval WHEN 'Y' THEN NULL ELSE NOONA_CTX_PKG.current_user_name END)
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'REF_EXCHANGE_RATE', l_id, 'CREATE', 'SUCCESS',
      p_new_values => '{"pair":"' || p_from || '/' || p_to || '","rate":' ||
                      TO_CHAR(p_rate, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''') || '}');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-REF-105', 'يوجد سعر لنفس العملتين والنوع في هذا التاريخ',
                               'A rate already exists for this pair, type and date');
  END add_rate;

  PROCEDURE approve_rate(p_rate_id IN NUMBER) IS
    l_r ref_exchange_rate%ROWTYPE;
  BEGIN
    SELECT * INTO l_r FROM ref_exchange_rate WHERE id = p_rate_id FOR UPDATE;
    same_company(l_r.company_id);
    guard('REF_EXCHANGE_RATE.APPROVE', l_r.company_id);
    NOONA_CORE_PKG.assert(l_r.status_code = 'DRAFT', 'NOONA-REF-106', 'السعر ليس بانتظار الاعتماد', 'Rate is not pending');
    NOONA_CORE_PKG.assert(l_r.created_by <> NOONA_CTX_PKG.current_user_name, 'NOONA-REF-104',
      'لا يعتمد السعر من أدخله', 'Maker cannot approve their own rate');
    UPDATE ref_exchange_rate SET status_code = 'APPROVED', approved_by = NOONA_CTX_PKG.current_user_name WHERE id = p_rate_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'REF_EXCHANGE_RATE', p_rate_id, 'APPROVE', 'SUCCESS');
  END approve_rate;

  PROCEDURE reject_rate(p_rate_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_r ref_exchange_rate%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-REF-107', 'سبب الرفض إلزامي', 'Reason is required');
    SELECT * INTO l_r FROM ref_exchange_rate WHERE id = p_rate_id FOR UPDATE;
    same_company(l_r.company_id);
    guard('REF_EXCHANGE_RATE.REJECT', l_r.company_id);
    NOONA_CORE_PKG.assert(l_r.status_code = 'DRAFT', 'NOONA-REF-106', 'السعر ليس بانتظار الاعتماد', 'Rate is not pending');
    UPDATE ref_exchange_rate SET status_code = 'REJECTED', reason = SUBSTR(p_reason, 1, 500) WHERE id = p_rate_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'REF_EXCHANGE_RATE', p_rate_id, 'REJECT', 'SUCCESS', p_reason => p_reason);
  END reject_rate;

  -- ---------------------------------------------------------------- شروط الدفع
  FUNCTION create_payment_term(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_base_rule IN VARCHAR2 DEFAULT 'DOC_DATE',
                               p_due_days IN NUMBER DEFAULT 0, p_discount_pct IN NUMBER DEFAULT NULL,
                               p_discount_days IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    guard('REF_PAYMENT_TERM.CREATE');
    NOONA_CORE_PKG.assert(NVL(p_due_days, 0) >= 0, 'NOONA-REF-110', 'أيام الاستحقاق لا تكون سالبة', 'Due days cannot be negative');
    NOONA_CORE_PKG.assert(p_discount_pct IS NULL OR (p_discount_pct > 0 AND p_discount_pct < 100 AND p_discount_days >= 0
                          AND p_discount_days <= NVL(p_due_days, 0)), 'NOONA-REF-111',
      'خصم السداد المبكر: نسبة بين 0 و100 وأيام لا تتجاوز أيام الاستحقاق', 'Invalid early-payment discount');
    INSERT INTO ref_payment_term (code, name_ar, base_date_rule, due_days, early_discount_pct, early_discount_days,
                                  is_installment, is_active)
    VALUES (UPPER(TRIM(p_code)), p_name_ar, NVL(p_base_rule, 'DOC_DATE'), NVL(p_due_days, 0), p_discount_pct,
            p_discount_days, 'N', 'Y')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'REF_PAYMENT_TERM', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-REF-112', 'رمز شرط الدفع مستخدم', 'Payment term code already exists');
  END create_payment_term;

  PROCEDURE add_installment(p_term_id IN NUMBER, p_due_pct IN NUMBER, p_due_days IN NUMBER) IS
    l_total NUMBER;
    l_line  NUMBER;
  BEGIN
    guard('REF_PAYMENT_TERM.UPDATE');
    SELECT NVL(SUM(due_pct), 0), NVL(MAX(line_no), 0) + 1 INTO l_total, l_line
      FROM ref_payment_term_line WHERE payment_term_id = p_term_id;
    NOONA_CORE_PKG.assert(p_due_pct > 0 AND l_total + p_due_pct <= 100, 'NOONA-REF-113',
      'مجموع نسب الأقساط لا يتجاوز 100% (الحالي ' || l_total || '%)', 'Installments cannot exceed 100%');
    NOONA_CORE_PKG.assert(NVL(p_due_days, -1) >= 0, 'NOONA-REF-110', 'أيام الاستحقاق لا تكون سالبة', 'Due days cannot be negative');
    INSERT INTO ref_payment_term_line (payment_term_id, line_no, due_pct, due_days) VALUES (p_term_id, l_line, p_due_pct, p_due_days);
    UPDATE ref_payment_term SET is_installment = 'Y' WHERE id = p_term_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'REF_PAYMENT_TERM', p_term_id, 'ADD_INSTALLMENT', 'SUCCESS');
  END add_installment;

  PROCEDURE set_term_active(p_term_id IN NUMBER, p_active IN VARCHAR2) IS
  BEGIN
    guard('REF_PAYMENT_TERM.UPDATE');
    UPDATE ref_payment_term SET is_active = CASE p_active WHEN 'Y' THEN 'Y' ELSE 'N' END WHERE id = p_term_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'REF_PAYMENT_TERM', p_term_id, CASE p_active WHEN 'Y' THEN 'ACTIVATE' ELSE 'DEACTIVATE' END, 'SUCCESS');
  END set_term_active;

  -- ---------------------------------------------------------------- تسلسلات المستندات
  FUNCTION create_doc_sequence(p_company_id IN NUMBER, p_doc_type IN VARCHAR2, p_fiscal_year IN NUMBER,
                               p_prefix IN VARCHAR2, p_branch_id IN NUMBER DEFAULT NULL, p_padding IN NUMBER DEFAULT 6,
                               p_gapless IN VARCHAR2 DEFAULT 'N', p_reset IN VARCHAR2 DEFAULT 'YEARLY') RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    guard('REF_DOC_SEQUENCE.CREATE', p_company_id);
    NOONA_CORE_PKG.assert(REGEXP_LIKE(UPPER(p_doc_type), '^[A-Z][A-Z0-9_]{1,29}$'), 'NOONA-REF-120',
      'رمز نوع المستند حروف إنجليزية وأرقام', 'Invalid document type code');
    NOONA_CORE_PKG.assert(NVL(p_padding, 6) BETWEEN 3 AND 12, 'NOONA-REF-121', 'عدد الخانات بين 3 و12', 'Padding must be 3-12');
    INSERT INTO ref_doc_sequence (company_id, branch_id, doc_type_code, fiscal_year, prefix, next_number, padding,
                                  is_gapless, reset_policy, is_active)
    VALUES (p_company_id, p_branch_id, UPPER(p_doc_type), p_fiscal_year, p_prefix, 1, NVL(p_padding, 6),
            NVL(p_gapless, 'N'), NVL(p_reset, 'YEARLY'), 'Y')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'REF_DOC_SEQUENCE', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-REF-122', 'يوجد تسلسل لنفس الشركة والفرع ونوع المستند والسنة',
                               'Sequence already exists');
  END create_doc_sequence;

  PROCEDURE update_doc_sequence(p_sequence_id IN NUMBER, p_prefix IN VARCHAR2, p_next_number IN NUMBER,
                                p_active IN VARCHAR2) IS
    l_s ref_doc_sequence%ROWTYPE;
  BEGIN
    SELECT * INTO l_s FROM ref_doc_sequence WHERE id = p_sequence_id FOR UPDATE;
    guard('REF_DOC_SEQUENCE.UPDATE', l_s.company_id);
    NOONA_CORE_PKG.assert(NVL(p_next_number, l_s.next_number) >= l_s.next_number, 'NOONA-REF-123',
      'لا يرجع الرقم التالي للخلف (' || l_s.next_number || ') حتى لا تتكرر أرقام المستندات',
      'Next number cannot move backwards');
    UPDATE ref_doc_sequence
       SET prefix = p_prefix, next_number = NVL(p_next_number, next_number), is_active = NVL(p_active, is_active)
     WHERE id = p_sequence_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'REF_DOC_SEQUENCE', p_sequence_id, 'UPDATE', 'SUCCESS',
      p_old_values => '{"prefix":' || NOONA_CORE_PKG.json_text(l_s.prefix) || ',"next":' || l_s.next_number || '}',
      p_new_values => '{"prefix":' || NOONA_CORE_PKG.json_text(p_prefix) || ',"next":' || NVL(p_next_number, l_s.next_number) || '}');
  END update_doc_sequence;

  FUNCTION preview_doc_no(p_sequence_id IN NUMBER) RETURN VARCHAR2 IS
    l_s ref_doc_sequence%ROWTYPE;
  BEGIN
    SELECT * INTO l_s FROM ref_doc_sequence WHERE id = p_sequence_id;
    -- نفس صيغة NOONA_REFERENCE_PKG.next_doc_no
    RETURN l_s.prefix || CASE WHEN l_s.reset_policy = 'YEARLY' AND l_s.fiscal_year IS NOT NULL THEN l_s.fiscal_year || '-' END
        || LPAD(l_s.next_number, l_s.padding, '0') || l_s.suffix;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END preview_doc_no;

END NOONA_REFDATA_PKG;
/
