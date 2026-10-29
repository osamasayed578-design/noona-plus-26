-- =============================================================================
-- NOONA PLUS ERP | NOONA_REFERENCE_PKG
-- تخصيص أرقام المستندات من REF_DOC_SEQUENCE بقفل الصف (آمن تحت التزامن، بدون فجوات
-- للتسلسلات القانونية لأن الرقم يثبت أو يلغى مع معاملة المستند نفسها)، وأسعار الصرف.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_REFERENCE_PKG AUTHID DEFINER AS
  FUNCTION next_doc_no(
    p_doc_type    IN VARCHAR2,
    p_company_id  IN NUMBER   DEFAULT NULL,
    p_branch_id   IN NUMBER   DEFAULT NULL,
    p_doc_date    IN DATE     DEFAULT TRUNC(SYSDATE),
    p_entity_type IN VARCHAR2 DEFAULT NULL,
    p_entity_id   IN NUMBER   DEFAULT NULL) RETURN VARCHAR2;

  PROCEDURE void_doc_no(p_sequence_id IN NUMBER, p_doc_no IN VARCHAR2);

  -- السعر الساري لزوج عملات ونوع سعر في وقت محدد من أسعار الشركة (الحالية افتراضياً)؛ NULL إن لم يوجد
  FUNCTION get_rate(
    p_from_currency IN VARCHAR2,
    p_to_currency   IN VARCHAR2,
    p_rate_type_id  IN NUMBER,
    p_at            IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT SYSTIMESTAMP,
    p_company_id    IN NUMBER DEFAULT NULL) RETURN NUMBER;

  FUNCTION round_amount(p_amount IN NUMBER, p_currency IN VARCHAR2) RETURN NUMBER RESULT_CACHE;
END NOONA_REFERENCE_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_REFERENCE_PKG AS

  FUNCTION next_doc_no(
    p_doc_type    IN VARCHAR2,
    p_company_id  IN NUMBER   DEFAULT NULL,
    p_branch_id   IN NUMBER   DEFAULT NULL,
    p_doc_date    IN DATE     DEFAULT TRUNC(SYSDATE),
    p_entity_type IN VARCHAR2 DEFAULT NULL,
    p_entity_id   IN NUMBER   DEFAULT NULL) RETURN VARCHAR2 IS
    l_company NUMBER := NVL(p_company_id, NOONA_CTX_PKG.company_id);
    l_year    NUMBER := EXTRACT(YEAR FROM NVL(p_doc_date, SYSDATE));
    l_seq     ref_doc_sequence%ROWTYPE;
    l_no      VARCHAR2(80);
  BEGIN
    -- سنة بلا تسلسل وللمستند تسلسل سنوي في سنة أخرى: ينشأ تسلسل السنة من إعداداته ويبدأ من 1
    INSERT INTO ref_doc_sequence (company_id, branch_id, doc_type_code, fiscal_year, prefix, suffix, next_number, padding,
                                  is_gapless, reset_policy, is_active)
    SELECT s.company_id, s.branch_id, s.doc_type_code, l_year, s.prefix, s.suffix, 1, s.padding, s.is_gapless, s.reset_policy, 'Y'
      FROM (SELECT x.* FROM ref_doc_sequence x
             WHERE x.company_id = l_company AND x.doc_type_code = p_doc_type AND x.is_active = 'Y'
               AND x.reset_policy = 'YEARLY' AND x.fiscal_year IS NOT NULL AND x.branch_id IS NULL
             ORDER BY x.fiscal_year DESC) s
     WHERE ROWNUM = 1
       AND NOT EXISTS (SELECT 1 FROM ref_doc_sequence y
                        WHERE y.company_id = l_company AND y.doc_type_code = p_doc_type AND y.is_active = 'Y'
                          AND (y.fiscal_year = l_year OR y.fiscal_year IS NULL)
                          AND (y.branch_id = p_branch_id OR y.branch_id IS NULL));
    -- أولوية: تسلسل الفرع والسنة، ثم الفرع، ثم الشركة والسنة، ثم الشركة
    SELECT * INTO l_seq
      FROM (SELECT s.*
              FROM ref_doc_sequence s
             WHERE s.company_id = l_company
               AND s.doc_type_code = p_doc_type
               AND s.is_active = 'Y'
               AND (s.branch_id = p_branch_id OR s.branch_id IS NULL)
               AND (s.fiscal_year = l_year OR s.fiscal_year IS NULL)
             ORDER BY CASE WHEN s.branch_id IS NULL THEN 1 ELSE 0 END,
                      CASE WHEN s.fiscal_year IS NULL THEN 1 ELSE 0 END)
     WHERE ROWNUM = 1;

    SELECT * INTO l_seq FROM ref_doc_sequence WHERE id = l_seq.id FOR UPDATE;

    l_no := l_seq.prefix ||
            CASE WHEN l_seq.reset_policy = 'YEARLY' AND l_seq.fiscal_year IS NOT NULL THEN l_year || '-' END ||
            LPAD(l_seq.next_number, l_seq.padding, '0') || l_seq.suffix;

    UPDATE ref_doc_sequence SET next_number = next_number + 1 WHERE id = l_seq.id;

    INSERT INTO ref_doc_number_log (sequence_id, allocated_no, entity_type, entity_id, allocation_status)
    VALUES (l_seq.id, l_no, p_entity_type, p_entity_id, 'USED');

    RETURN l_no;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20200, 'NOONA-REF-001: No active document sequence for ' || p_doc_type);
  END next_doc_no;

  PROCEDURE void_doc_no(p_sequence_id IN NUMBER, p_doc_no IN VARCHAR2) IS
  BEGIN
    -- الأرقام الملغاة لا يعاد استخدامها؛ يسجل إلغاؤها كسجل جديد في السجل التراكمي
    INSERT INTO ref_doc_number_log (sequence_id, allocated_no, allocation_status)
    VALUES (p_sequence_id, p_doc_no || '#VOID', 'VOIDED');
  END void_doc_no;

  FUNCTION get_rate(
    p_from_currency IN VARCHAR2,
    p_to_currency   IN VARCHAR2,
    p_rate_type_id  IN NUMBER,
    p_at            IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT SYSTIMESTAMP,
    p_company_id    IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_rate NUMBER;
    l_co   NUMBER := NVL(p_company_id, NOONA_CTX_PKG.company_id);
  BEGIN
    IF p_from_currency = p_to_currency THEN
      RETURN 1;
    END IF;
    BEGIN
      SELECT rate INTO l_rate
        FROM (SELECT rate FROM ref_exchange_rate
               WHERE company_id = l_co AND from_currency = p_from_currency AND to_currency = p_to_currency
                 AND rate_type_id = p_rate_type_id AND status_code = 'APPROVED' AND effective_at <= p_at
               ORDER BY effective_at DESC)
       WHERE ROWNUM = 1;
      RETURN l_rate;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      -- الاتجاه العكسي محسوب تلقائياً بدقة مضبوطة (12.9)
      SELECT ROUND(1 / rate, 12) INTO l_rate
        FROM (SELECT rate FROM ref_exchange_rate
               WHERE company_id = l_co AND from_currency = p_to_currency AND to_currency = p_from_currency
                 AND rate_type_id = p_rate_type_id AND status_code = 'APPROVED' AND effective_at <= p_at
               ORDER BY effective_at DESC)
       WHERE ROWNUM = 1;
      RETURN l_rate;
    END;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END get_rate;

  FUNCTION round_amount(p_amount IN NUMBER, p_currency IN VARCHAR2) RETURN NUMBER RESULT_CACHE IS
    l_dec NUMBER;
  BEGIN
    SELECT decimal_places INTO l_dec FROM ref_currency WHERE currency_code = p_currency;
    RETURN ROUND(p_amount, l_dec);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN ROUND(p_amount, 2);
  END round_amount;

END NOONA_REFERENCE_PKG;
/
