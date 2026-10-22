-- =============================================================================
-- NOONA PLUS ERP | NOONA_CSH_PKG - النقدية والبنوك (سندات القبض والصرف والمصروفات)
--   * الصناديق والحسابات البنكية مرتبطة بحسابات نقدية (حسابات مراقبة لا تقبل قيوداً يدوية)
--   * السند رأس وتفاصيل يحفظ في عملية واحدة (JSON)؛ مبلغ السند = مجموع سطوره
--   * مسودة -> إرسال -> اعتماد (غير المنشئ) = ترحيل عبر المحرك المحاسبي (قيد نظامي مرتبط بالسند)
--   * لا يصرف من الصندوق أكثر من رصيده، ولا من البنك فوق حد الدفع للحساب
--   * الرقم الرسمي للسند يصدر عند الاعتماد (RV- قبض، PV- صرف، EV- مصروفات) بلا فجوات
--   * التصحيح بعكس السند (قيد عكسي) لا بتعديله
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_CSH_PKG AUTHID DEFINER AS

  -- ---------------------------------------------------------- التجهيز
  -- صندوق رئيسي وتسلسلات السندات (Idempotent)؛ يعيد رقم الصندوق الرئيسي
  FUNCTION quick_setup RETURN NUMBER;
  -- Y إن جهزت النقدية للشركة الحالية (يوجد صندوق)
  FUNCTION is_ready RETURN VARCHAR2;
  FUNCTION create_cash_box(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_account_code IN VARCHAR2 DEFAULT '1101',
                           p_box_type IN VARCHAR2 DEFAULT 'MAIN', p_max_balance IN NUMBER DEFAULT NULL,
                           p_currency IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION create_bank_account(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_bank_id IN NUMBER, p_account_no IN VARCHAR2,
                               p_iban IN VARCHAR2 DEFAULT NULL, p_account_code IN VARCHAR2 DEFAULT '1102',
                               p_max_payment IN NUMBER DEFAULT NULL, p_currency IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- تعديل بيانات حساب بنكي (رقم الحساب يحفظ مقنعاً؛ يبقى كما هو إن ترك فارغاً)
  PROCEDURE update_bank_account(p_bank_account_id IN NUMBER, p_name_ar IN VARCHAR2, p_bank_id IN NUMBER,
                                p_account_no IN VARCHAR2 DEFAULT NULL, p_iban IN VARCHAR2 DEFAULT NULL,
                                p_max_payment IN NUMBER DEFAULT NULL);
  -- صندوق العهد النثرية وحساب بنكي افتراضي (إن لم توجد)؛ يعيد عدد ما أضيف
  FUNCTION seed_defaults RETURN NUMBER;
  PROCEDURE set_box_status(p_box_id IN NUMBER, p_status IN VARCHAR2);
  PROCEDURE set_bank_status(p_bank_account_id IN NUMBER, p_status IN VARCHAR2);

  -- ---------------------------------------------------------- السندات
  -- p_type: RECEIPT (قبض) / PAYMENT (صرف) / EXPENSE (مصروفات: حسابات مصروفات فقط)
  -- p_lines: [{"a":"5202","m":1500,"cc":12,"t":"إيجار شهر"}, ...]؛ p_id NULL = سند جديد
  FUNCTION save_voucher(p_id IN NUMBER, p_type IN VARCHAR2, p_date IN DATE, p_box_id IN NUMBER, p_bank_id IN NUMBER,
                        p_channel IN VARCHAR2, p_party IN VARCHAR2, p_description IN VARCHAR2, p_reference IN VARCHAR2,
                        p_lines IN CLOB, p_rate IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE submit_voucher(p_id IN NUMBER);
  -- مستند السند كاملاً من شاشة HTML في استدعاء واحد:
  -- {"id":null,"type":"RECEIPT","date":"2026-10-21","place":"BOX:1","channel":"CASH","party":"...","desc":"...",
  --  "ref":"...","rate":null,"action":"SAVE|SUBMIT","lines":[{"a":"4201","m":100,"cc":3,"t":"..."}]}
  FUNCTION save_voucher_doc(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION voucher_doc_json(p_id IN NUMBER, p_type IN VARCHAR2 DEFAULT 'RECEIPT') RETURN CLOB;
  -- الصناديق والحسابات البنكية النشطة: [{"v":"BOX:1","n":"...","c":"SAR","k":"BOX"}]
  FUNCTION places_json RETURN CLOB;
  PROCEDURE approve_voucher(p_id IN NUMBER, p_comment IN VARCHAR2 DEFAULT NULL);
  PROCEDURE reject_voucher(p_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE cancel_voucher(p_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION reverse_voucher(p_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER;

  -- حركة نقدية من مستند مصدر (فاتورة نقدية، سداد مورد، تحصيل عميل، نقاط البيع): قيدها في المستند المصدر،
  -- وتسجل هنا لتظهر في رصيد الصندوق أو البنك ودفتره. p_place: BOX:n أو BANK:n
  FUNCTION record_settlement(p_type IN VARCHAR2, p_place IN VARCHAR2, p_date IN DATE, p_amount IN NUMBER, p_party_id IN NUMBER,
                             p_party_name IN VARCHAR2, p_source_type IN VARCHAR2, p_source_id IN NUMBER, p_doc_no IN VARCHAR2,
                             p_description IN VARCHAR2, p_event_id IN NUMBER, p_channel IN VARCHAR2 DEFAULT NULL) RETURN NUMBER
    ACCESSIBLE BY (PACKAGE NOONA_PUR_PKG, PACKAGE NOONA_SAL_PKG, PACKAGE NOONA_POS_PKG);
  -- حساب الأستاذ للصندوق أو البنك
  FUNCTION place_account(p_place IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- الأرصدة والواجهة
  -- رصيد صندوق أو حساب بنكي بعملته حتى تاريخ (السندات المرحلة)
  FUNCTION balance(p_box_id IN NUMBER, p_bank_id IN NUMBER, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER;
  FUNCTION amount_words(p_amount IN NUMBER, p_currency IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
  FUNCTION accounts_json(p_type IN VARCHAR2) RETURN CLOB;
  FUNCTION lines_json(p_id IN NUMBER) RETURN CLOB;
  FUNCTION summary(p_session IN VARCHAR2) RETURN CLOB;
  FUNCTION balances_html RETURN CLOB;
  FUNCTION voucher_header(p_id IN NUMBER) RETURN CLOB;
  FUNCTION voucher_print(p_id IN NUMBER) RETURN CLOB;
  FUNCTION cash_book(p_box_id IN NUMBER, p_bank_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB;
END NOONA_CSH_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_CSH_PKG AS

  c_entity CONSTANT VARCHAR2(30) := 'CSH_TRANSACTION';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;

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
    NOONA_SECURITY_PKG.assert_permission(p_permission, NOONA_GL_PKG.company);
  END guard;

  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN CASE p_type WHEN 'RECEIPT' THEN 'سند قبض' WHEN 'PAYMENT' THEN 'سند صرف' WHEN 'EXPENSE' THEN 'سند مصروفات'
                       ELSE p_type END;
  END type_label;

  FUNCTION get_txn(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN csh_transaction%ROWTYPE IS
    l_t csh_transaction%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l_t FROM csh_transaction WHERE id = p_id AND company_id = NOONA_GL_PKG.company FOR UPDATE;
    ELSE
      SELECT * INTO l_t FROM csh_transaction WHERE id = p_id AND company_id = NOONA_GL_PKG.company;
    END IF;
    RETURN l_t;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-CSH-001', 'السند غير موجود', 'Voucher not found');
  END get_txn;

  FUNCTION ledger_currency RETURN VARCHAR2 IS
    l VARCHAR2(3);
  BEGIN
    SELECT MAX(currency_code) INTO l FROM gl_ledger WHERE id = NOONA_GL_PKG.primary_ledger;
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-GL-042', 'الأستاذ العام غير مجهز لهذه الشركة؛ نفذ التجهيز أولاً', 'Ledger not set up');
    RETURN l;
  END ledger_currency;

  -- حساب نقدية صالح للصندوق أو البنك: حساب تفصيلي نشط من نوع النقدية
  FUNCTION cash_account(p_code VARCHAR2) RETURN NUMBER IS
    l_acc gl_account%ROWTYPE;
  BEGIN
    SELECT * INTO l_acc FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = TRIM(p_code);
    NOONA_CORE_PKG.assert(l_acc.is_postable = 'Y' AND l_acc.status_code = 'ACTIVE' AND l_acc.subledger_code = 'CASH',
      'NOONA-CSH-010', 'الحساب ' || p_code || ' ليس حساب نقدية تفصيلياً نشطاً (نوع النظام الفرعي: نقدية)',
      'Account must be an active postable cash account');
    RETURN l_acc.id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-CSH-011', 'الحساب غير موجود: ' || p_code, 'Account not found');
  END cash_account;

  FUNCTION currency_or_ledger(p_currency VARCHAR2) RETURN VARCHAR2 IS
    l_n NUMBER;
  BEGIN
    IF p_currency IS NULL THEN RETURN ledger_currency; END IF;
    SELECT COUNT(*) INTO l_n FROM ref_currency WHERE currency_code = UPPER(p_currency) AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-CSH-019', 'العملة غير معرفة أو غير نشطة: ' || p_currency, 'Unknown currency');
    RETURN UPPER(p_currency);
  END currency_or_ledger;

  -- ================================================================ التجهيز
  FUNCTION create_cash_box(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_account_code IN VARCHAR2 DEFAULT '1101',
                           p_box_type IN VARCHAR2 DEFAULT 'MAIN', p_max_balance IN NUMBER DEFAULT NULL,
                           p_currency IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_id  NUMBER;
    l_acc NUMBER;
    l_cur VARCHAR2(3);
  BEGIN
    guard('CSH_CASH_BOX.CREATE');
    NOONA_CORE_PKG.assert(p_code IS NOT NULL AND p_name_ar IS NOT NULL, 'NOONA-CSH-012', 'الرمز والاسم إلزاميان', 'Code and name are required');
    l_acc := cash_account(p_account_code);
    l_cur := currency_or_ledger(p_currency);
    INSERT INTO csh_cash_box (company_id, branch_id, code, name_ar, box_type, currency_code, gl_account_id, max_balance, status_code)
    VALUES (NOONA_GL_PKG.company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), UPPER(TRIM(p_code)), p_name_ar, NVL(p_box_type, 'MAIN'),
            l_cur, l_acc, p_max_balance, 'ACTIVE')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'CSH_CASH_BOX', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-CSH-013', 'رمز الصندوق مستخدم', 'Cash box code already exists');
  END create_cash_box;

  FUNCTION create_bank_account(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_bank_id IN NUMBER, p_account_no IN VARCHAR2,
                               p_iban IN VARCHAR2 DEFAULT NULL, p_account_code IN VARCHAR2 DEFAULT '1102',
                               p_max_payment IN NUMBER DEFAULT NULL, p_currency IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_id  NUMBER;
    l_no  VARCHAR2(100) := REPLACE(TRIM(p_account_no), ' ');
    l_ib  VARCHAR2(100) := UPPER(REPLACE(TRIM(p_iban), ' '));
    l_acc NUMBER;
    l_cur VARCHAR2(3);
  BEGIN
    guard('CSH_BANK_ACCOUNT.CREATE');
    NOONA_CORE_PKG.assert(p_code IS NOT NULL AND p_name_ar IS NOT NULL AND p_bank_id IS NOT NULL AND l_no IS NOT NULL,
      'NOONA-CSH-014', 'الرمز والاسم والبنك ورقم الحساب إلزامية', 'Code, name, bank and account number are required');
    NOONA_CORE_PKG.assert(l_ib IS NULL OR REGEXP_LIKE(l_ib, '^[A-Z]{2}[0-9]{2}[A-Z0-9]{10,30}$'), 'NOONA-CSH-015',
      'رقم الآيبان غير صالح', 'Invalid IBAN');
    l_acc := cash_account(p_account_code);
    l_cur := currency_or_ledger(p_currency);
    -- لا يخزن الرقم الكامل: آخر 4 أرقام فقط
    INSERT INTO csh_bank_account (company_id, branch_id, code, name_ar, bank_id, account_no_masked, iban_masked, currency_code,
                                  gl_account_id, max_payment_amount, status_code)
    VALUES (NOONA_GL_PKG.company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), UPPER(TRIM(p_code)), p_name_ar, p_bank_id,
            '****' || SUBSTR(l_no, -4), CASE WHEN l_ib IS NOT NULL THEN SUBSTR(l_ib, 1, 4) || '****' || SUBSTR(l_ib, -4) END,
            l_cur, l_acc, p_max_payment, 'ACTIVE')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'CSH_BANK_ACCOUNT', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-CSH-016', 'رمز الحساب البنكي مستخدم', 'Bank account code already exists');
  END create_bank_account;

  PROCEDURE set_box_status(p_box_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('CSH_CASH_BOX.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'SUSPENDED', 'CLOSED'), 'NOONA-CSH-017', 'حالة غير صالحة', 'Invalid status');
    NOONA_CORE_PKG.assert(p_status <> 'CLOSED' OR balance(p_box_id, NULL) = 0, 'NOONA-CSH-018',
      'لا يغلق الصندوق ورصيده غير صفري', 'Cannot close a cash box with a balance');
    UPDATE csh_cash_box SET status_code = p_status WHERE id = p_box_id AND company_id = NOONA_GL_PKG.company;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'CSH_CASH_BOX', p_box_id, 'STATUS_' || p_status, 'SUCCESS');
  END set_box_status;

  PROCEDURE set_bank_status(p_bank_account_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('CSH_BANK_ACCOUNT.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'FROZEN', 'CLOSED'), 'NOONA-CSH-017', 'حالة غير صالحة', 'Invalid status');
    NOONA_CORE_PKG.assert(p_status <> 'CLOSED' OR balance(NULL, p_bank_account_id) = 0, 'NOONA-CSH-018',
      'لا يغلق الحساب البنكي ورصيده غير صفري', 'Cannot close a bank account with a balance');
    UPDATE csh_bank_account SET status_code = p_status WHERE id = p_bank_account_id AND company_id = NOONA_GL_PKG.company;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'CSH_BANK_ACCOUNT', p_bank_account_id, 'STATUS_' || p_status, 'SUCCESS');
  END set_bank_status;

  PROCEDURE update_bank_account(p_bank_account_id IN NUMBER, p_name_ar IN VARCHAR2, p_bank_id IN NUMBER,
                                p_account_no IN VARCHAR2 DEFAULT NULL, p_iban IN VARCHAR2 DEFAULT NULL,
                                p_max_payment IN NUMBER DEFAULT NULL) IS
    l_no VARCHAR2(100) := REPLACE(TRIM(p_account_no), ' ');
    l_ib VARCHAR2(100) := UPPER(REPLACE(TRIM(p_iban), ' '));
  BEGIN
    guard('CSH_BANK_ACCOUNT.UPDATE');
    NOONA_CORE_PKG.assert(p_name_ar IS NOT NULL AND p_bank_id IS NOT NULL, 'NOONA-CSH-014', 'الاسم والبنك إلزاميان',
                          'Name and bank are required');
    NOONA_CORE_PKG.assert(l_ib IS NULL OR REGEXP_LIKE(l_ib, '^[A-Z]{2}[0-9]{2}[A-Z0-9]{10,30}$'), 'NOONA-CSH-015',
      'رقم الآيبان غير صالح', 'Invalid IBAN');
    UPDATE csh_bank_account
       SET name_ar = p_name_ar, bank_id = p_bank_id,
           account_no_masked = CASE WHEN l_no IS NOT NULL THEN '****' || SUBSTR(l_no, -4) ELSE account_no_masked END,
           iban_masked = CASE WHEN l_ib IS NOT NULL THEN SUBSTR(l_ib, 1, 4) || '****' || SUBSTR(l_ib, -4) ELSE iban_masked END,
           max_payment_amount = p_max_payment
     WHERE id = p_bank_account_id AND company_id = NOONA_GL_PKG.company;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'CSH_BANK_ACCOUNT', p_bank_account_id, 'UPDATE', 'SUCCESS');
  END update_bank_account;

  FUNCTION seed_defaults RETURN NUMBER IS
    l_n    NUMBER := 0;
    l_c    NUMBER;
    l_id   NUMBER;
    l_bank NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_c FROM csh_cash_box WHERE company_id = NOONA_GL_PKG.company AND box_type = 'PETTY_CASH';
    IF l_c = 0 THEN
      l_id := create_cash_box('PETTY-01', 'صندوق العهد النثرية', '1101', 'PETTY_CASH', 5000);
      l_n := l_n + 1;
    END IF;
    SELECT COUNT(*) INTO l_c FROM csh_bank_account WHERE company_id = NOONA_GL_PKG.company;
    IF l_c = 0 THEN
      SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY CASE code WHEN 'SA-RJHI' THEN 0 ELSE 1 END, id) INTO l_bank
        FROM ref_bank WHERE is_active = 'Y';
      IF l_bank IS NOT NULL THEN
        l_id := create_bank_account('BNK-01', 'الحساب الجاري الرئيسي (عدّل رقم الحساب)', l_bank, '0000', NULL, '1102');
        l_n := l_n + 1;
      END IF;
    END IF;
    RETURN l_n;
  END seed_defaults;

  FUNCTION is_ready RETURN VARCHAR2 IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM csh_cash_box WHERE company_id = NOONA_GL_PKG.company AND ROWNUM = 1;
    RETURN CASE WHEN l_n > 0 THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION quick_setup RETURN NUMBER IS
    l_box NUMBER;
  BEGIN
    guard('CSH_CASH_BOX.CREATE');
    NOONA_CORE_PKG.assert(NOONA_GL_PKG.primary_ledger IS NOT NULL, 'NOONA-GL-042',
      'الأستاذ العام غير مجهز لهذه الشركة؛ نفذ تجهيز الأستاذ العام أولاً', 'Ledger not set up');
    FOR s IN (SELECT 'CSH_RECEIPT' t, 'RV-' p FROM dual UNION ALL SELECT 'CSH_PAYMENT', 'PV-' FROM dual
              UNION ALL SELECT 'CSH_EXPENSE', 'EV-' FROM dual) LOOP
      INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
      SELECT NOONA_GL_PKG.company, s.t, EXTRACT(YEAR FROM SYSDATE), s.p, 1, 6, 'Y', 'YEARLY', 'Y' FROM dual
       WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = NOONA_GL_PKG.company AND doc_type_code = s.t
                           AND (fiscal_year = EXTRACT(YEAR FROM SYSDATE) OR fiscal_year IS NULL));
    END LOOP;
    SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = NOONA_GL_PKG.company AND status_code = 'ACTIVE';
    IF l_box IS NULL THEN
      l_box := create_cash_box('BOX-01', 'الصندوق الرئيسي', '1101', 'MAIN');
    END IF;
    IF seed_defaults >= 0 THEN NULL; END IF;
    RETURN l_box;
  END quick_setup;

  -- ================================================================ الأرصدة
  -- حركة السند على الصندوق: القبض موجب والصرف سالب؛ العكس يقابل الأصل في تاريخ العكس
  FUNCTION balance(p_box_id IN NUMBER, p_bank_id IN NUMBER, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
    l_to DATE := NVL(p_as_of, DATE '9999-12-31');
  BEGIN
    SELECT NVL(SUM(CASE WHEN t.txn_type = 'RECEIPT' THEN 1 ELSE -1 END * t.amount
                   * CASE WHEN e.reversal_of_event_id IS NULL THEN 1 ELSE -1 END), 0)
      INTO l
      FROM csh_transaction t
      JOIN ace_accounting_event e ON ((e.source_entity_type = c_entity AND e.source_entity_id = t.id)
                 OR (t.source_entity_type <> c_entity AND (e.id = t.accounting_event_id OR e.reversal_of_event_id = t.accounting_event_id)))
                AND e.journal_id IS NOT NULL
     WHERE t.company_id = NOONA_GL_PKG.company
       AND ((p_box_id IS NOT NULL AND t.cash_box_id = p_box_id) OR (p_bank_id IS NOT NULL AND t.bank_account_id = p_bank_id))
       AND e.accounting_date <= l_to;
    RETURN l;
  END balance;

  FUNCTION place_account(p_place IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF p_place LIKE 'BOX:%' THEN
      SELECT MAX(gl_account_id) INTO l FROM csh_cash_box
       WHERE id = TO_NUMBER(SUBSTR(p_place, 5)) AND company_id = NOONA_GL_PKG.company AND status_code = 'ACTIVE';
    ELSIF p_place LIKE 'BANK:%' THEN
      SELECT MAX(gl_account_id) INTO l FROM csh_bank_account
       WHERE id = TO_NUMBER(SUBSTR(p_place, 6)) AND company_id = NOONA_GL_PKG.company AND status_code = 'ACTIVE';
    END IF;
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-CSH-070', 'اختر صندوقاً أو حساباً بنكياً نشطاً للسداد', 'Choose an active cash box or bank account');
    RETURN l;
  END place_account;

  FUNCTION record_settlement(p_type IN VARCHAR2, p_place IN VARCHAR2, p_date IN DATE, p_amount IN NUMBER, p_party_id IN NUMBER,
                             p_party_name IN VARCHAR2, p_source_type IN VARCHAR2, p_source_id IN NUMBER, p_doc_no IN VARCHAR2,
                             p_description IN VARCHAR2, p_event_id IN NUMBER, p_channel IN VARCHAR2 DEFAULT NULL) RETURN NUMBER
    ACCESSIBLE BY (PACKAGE NOONA_PUR_PKG, PACKAGE NOONA_SAL_PKG, PACKAGE NOONA_POS_PKG) IS
    l_id  NUMBER;
    l_box NUMBER;
    l_bnk NUMBER;
    l_cur VARCHAR2(3);
    l_acc NUMBER;
  BEGIN
    l_acc := place_account(p_place);
    IF p_place LIKE 'BOX:%' THEN
      l_box := TO_NUMBER(SUBSTR(p_place, 5));
      SELECT currency_code INTO l_cur FROM csh_cash_box WHERE id = l_box;
    ELSE
      l_bnk := TO_NUMBER(SUBSTR(p_place, 6));
      SELECT currency_code INTO l_cur FROM csh_bank_account WHERE id = l_bnk;
    END IF;
    INSERT INTO csh_transaction (company_id, branch_id, doc_no, doc_date, source_entity_type, source_entity_id, currency_code, exchange_rate,
                                 txn_type, channel, bank_account_id, cash_box_id, counterparty_party_id, counterparty_name, amount, amount_func,
                                 value_date, description, settled_at, status_code, accounting_event_id, posted_at, posted_by)
    VALUES (NOONA_GL_PKG.company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), p_doc_no, TRUNC(p_date), p_source_type, p_source_id,
            l_cur, 1, p_type, NVL(p_channel, CASE WHEN l_box IS NOT NULL THEN 'CASH' ELSE 'BANK_TRANSFER' END), l_bnk, l_box, p_party_id,
            p_party_name, ROUND(p_amount, 2), ROUND(p_amount, 2), TRUNC(p_date), SUBSTR(p_description, 1, 1000), SYSTIMESTAMP, 'SETTLED',
            p_event_id, SYSTIMESTAMP, NOONA_CTX_PKG.current_user_name)
    RETURNING id INTO l_id;
    RETURN l_id;
  END record_settlement;

  -- ================================================================ التفقيط
  FUNCTION words_999(n PLS_INTEGER) RETURN VARCHAR2 IS
    TYPE t_w IS TABLE OF VARCHAR2(40) INDEX BY PLS_INTEGER;
    o t_w; tn t_w; h t_w;
    l_h PLS_INTEGER := TRUNC(n / 100);
    l_r PLS_INTEGER := MOD(n, 100);
    l_s VARCHAR2(400);
    l_t VARCHAR2(200);
  BEGIN
    o(1) := 'واحد'; o(2) := 'اثنان'; o(3) := 'ثلاثة'; o(4) := 'أربعة'; o(5) := 'خمسة'; o(6) := 'ستة'; o(7) := 'سبعة';
    o(8) := 'ثمانية'; o(9) := 'تسعة'; o(10) := 'عشرة'; o(11) := 'أحد عشر'; o(12) := 'اثنا عشر';
    tn(2) := 'عشرون'; tn(3) := 'ثلاثون'; tn(4) := 'أربعون'; tn(5) := 'خمسون'; tn(6) := 'ستون'; tn(7) := 'سبعون';
    tn(8) := 'ثمانون'; tn(9) := 'تسعون';
    h(1) := 'مائة'; h(2) := 'مائتان'; h(3) := 'ثلاثمائة'; h(4) := 'أربعمائة'; h(5) := 'خمسمائة'; h(6) := 'ستمائة';
    h(7) := 'سبعمائة'; h(8) := 'ثمانمائة'; h(9) := 'تسعمائة';
    IF l_h > 0 THEN l_s := h(l_h); END IF;
    IF l_r BETWEEN 1 AND 12 THEN l_t := o(l_r);
    ELSIF l_r BETWEEN 13 AND 19 THEN l_t := o(l_r - 10) || ' عشر';
    ELSIF l_r >= 20 THEN
      l_t := CASE WHEN MOD(l_r, 10) > 0 THEN o(MOD(l_r, 10)) || ' و' END || tn(TRUNC(l_r / 10));
    END IF;
    RETURN CASE WHEN l_s IS NOT NULL AND l_t IS NOT NULL THEN l_s || ' و' || l_t ELSE NVL(l_s, l_t) END;
  END words_999;

  FUNCTION group_words(n PLS_INTEGER, p_one VARCHAR2, p_two VARCHAR2, p_few VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN n = 1 THEN p_one WHEN n = 2 THEN p_two WHEN n BETWEEN 3 AND 10 THEN words_999(n) || ' ' || p_few
                ELSE words_999(n) || ' ' || p_one END;
  END group_words;

  FUNCTION amount_words(p_amount IN NUMBER, p_currency IN VARCHAR2) RETURN VARCHAR2 IS
    l_int  NUMBER := TRUNC(ABS(p_amount));
    l_frac PLS_INTEGER := ROUND((ABS(p_amount) - TRUNC(ABS(p_amount))) * 100);
    l_b PLS_INTEGER := TRUNC(l_int / 1e9);
    l_m PLS_INTEGER := TRUNC(MOD(l_int, 1e9) / 1e6);
    l_k PLS_INTEGER := TRUNC(MOD(l_int, 1e6) / 1e3);
    l_u PLS_INTEGER := MOD(l_int, 1e3);
    l_s VARCHAR2(2000);
    l_cur  VARCHAR2(200);
    l_minor VARCHAR2(50);
    PROCEDURE add(p VARCHAR2) IS
    BEGIN
      IF p IS NOT NULL THEN l_s := CASE WHEN l_s IS NULL THEN p ELSE l_s || ' و' || p END; END IF;
    END add;
  BEGIN
    IF p_amount IS NULL THEN RETURN NULL; END IF;
    SELECT MAX(name_ar), MAX(minor_unit_ar) INTO l_cur, l_minor FROM ref_currency WHERE currency_code = p_currency;
    IF l_b > 0 THEN add(group_words(l_b, 'مليار', 'ملياران', 'مليارات')); END IF;
    IF l_m > 0 THEN add(group_words(l_m, 'مليون', 'مليونان', 'ملايين')); END IF;
    IF l_k > 0 THEN add(group_words(l_k, 'ألف', 'ألفان', 'آلاف')); END IF;
    IF l_u > 0 THEN add(words_999(l_u)); END IF;
    l_s := 'فقط ' || NVL(l_s, 'صفر') || ' ' || NVL(l_cur, p_currency);
    IF l_frac > 0 THEN
      l_s := l_s || ' و' || words_999(l_frac) || ' ' || NVL(l_minor, 'من مائة');
    END IF;
    RETURN l_s || ' لا غير';
  END amount_words;

  -- ================================================================ السندات
  PROCEDURE assert_draft(p_t csh_transaction%ROWTYPE) IS
  BEGIN
    NOONA_CORE_PKG.assert(p_t.status_code = 'DRAFT', 'NOONA-CSH-020', 'لا يعدل السند بعد إرساله', 'Only draft vouchers can be edited');
  END assert_draft;

  FUNCTION save_voucher(p_id IN NUMBER, p_type IN VARCHAR2, p_date IN DATE, p_box_id IN NUMBER, p_bank_id IN NUMBER,
                        p_channel IN VARCHAR2, p_party IN VARCHAR2, p_description IN VARCHAR2, p_reference IN VARCHAR2,
                        p_lines IN CLOB, p_rate IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    TYPE t_ln IS RECORD (acc NUMBER, amt NUMBER, cc NUMBER, txt VARCHAR2(1000));
    TYPE t_lns IS TABLE OF t_ln;
    l_lines t_lns := t_lns();
    l_t     csh_transaction%ROWTYPE;
    l_id    NUMBER := p_id;
    l_acc   gl_account%ROWTYPE;
    l_cur   VARCHAR2(3);
    l_led   VARCHAR2(3) := ledger_currency;
    l_rate  NUMBER;
    l_st    VARCHAR2(30);
    l_rule  VARCHAR2(20);
    l_total NUMBER := 0;
    l_n     NUMBER;
    l_no    PLS_INTEGER := 0;
    l_cash  NUMBER;
  BEGIN
    IF p_id IS NULL THEN
      guard('CSH_TRANSACTION.CREATE');
    ELSE
      guard('CSH_TRANSACTION.UPDATE');
      l_t := get_txn(p_id, TRUE);
      assert_draft(l_t);
      NOONA_CORE_PKG.assert(l_t.txn_type = p_type, 'NOONA-CSH-021', 'لا يغير نوع السند بعد إنشائه', 'Voucher type cannot change');
    END IF;
    NOONA_CORE_PKG.assert(p_type IN ('RECEIPT', 'PAYMENT', 'EXPENSE'), 'NOONA-CSH-022', 'نوع السند غير صالح', 'Invalid voucher type');
    NOONA_CORE_PKG.assert(p_description IS NOT NULL, 'NOONA-CSH-023', 'بيان السند إلزامي', 'Description is required');
    NOONA_CORE_PKG.assert((p_box_id IS NULL) <> (p_bank_id IS NULL), 'NOONA-CSH-024',
      'اختر الصندوق أو الحساب البنكي (واحداً فقط)', 'Choose a cash box or a bank account');
    IF p_box_id IS NOT NULL THEN
      SELECT MAX(currency_code), MAX(status_code), MAX(gl_account_id) INTO l_cur, l_st, l_cash
        FROM csh_cash_box WHERE id = p_box_id AND company_id = NOONA_GL_PKG.company;
    ELSE
      SELECT MAX(currency_code), MAX(status_code), MAX(gl_account_id) INTO l_cur, l_st, l_cash
        FROM csh_bank_account WHERE id = p_bank_id AND company_id = NOONA_GL_PKG.company;
    END IF;
    NOONA_CORE_PKG.assert(l_st = 'ACTIVE', 'NOONA-CSH-025', 'الصندوق أو الحساب البنكي غير نشط', 'Cash box or bank account is not active');
    l_rate := CASE WHEN l_cur = l_led THEN 1 ELSE NVL(p_rate, NOONA_GL_PKG.rate_for(l_cur, p_date)) END;
    NOONA_CORE_PKG.assert(l_rate > 0, 'NOONA-GL-045',
      'لا يوجد سعر صرف معتمد للعملة ' || l_cur || ' في هذا التاريخ؛ أدخل السعر أو أضفه في أسعار الصرف', 'Exchange rate required');
    l_n := NOONA_GL_PKG.period_for(p_date);                   -- يتحقق من وجود فترة مفتوحة للتاريخ

    -- السطور
    FOR r IN (SELECT * FROM JSON_TABLE(NVL(p_lines, '[]'), '$[*]' COLUMNS (
                acc VARCHAR2(50) PATH '$.a', amt NUMBER PATH '$.m', cc NUMBER PATH '$.cc', txt VARCHAR2(1000) PATH '$.t'))) LOOP
      CONTINUE WHEN r.acc IS NULL AND NVL(r.amt, 0) = 0;
      l_no := l_no + 1;
      BEGIN
        SELECT * INTO l_acc FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = TRIM(r.acc);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-GL-051', 'السطر ' || l_no || ': الحساب غير موجود (' || r.acc || ')', 'Account not found');
      END;
      NOONA_CORE_PKG.assert(l_acc.is_postable = 'Y' AND l_acc.status_code = 'ACTIVE', 'NOONA-GL-052',
        'السطر ' || l_no || ': الحساب ' || l_acc.account_code || ' تجميعي أو موقوف', 'Account is not postable');
      NOONA_CORE_PKG.assert(l_acc.allow_manual_posting = 'Y', 'NOONA-GL-053',
        'السطر ' || l_no || ': الحساب ' || l_acc.account_code || ' حساب مراقبة يرحل إليه من نظامه الفرعي فقط',
        'Control account: post from its subledger');
      NOONA_CORE_PKG.assert(l_acc.id <> l_cash, 'NOONA-CSH-029',
        'السطر ' || l_no || ': لا يستخدم حساب الصندوق أو البنك نفسه في سطور السند', 'Line cannot use the voucher cash account');
      NOONA_CORE_PKG.assert(p_type <> 'EXPENSE' OR l_acc.account_type = 'EXPENSE', 'NOONA-CSH-026',
        'السطر ' || l_no || ': سند المصروفات يقبل حسابات المصروفات فقط', 'Expense vouchers accept expense accounts only');
      NOONA_CORE_PKG.assert(NVL(r.amt, 0) > 0, 'NOONA-CSH-027', 'السطر ' || l_no || ': المبلغ يجب أن يكون موجباً',
                            'Line amount must be positive');
      l_rule := NOONA_GL_PKG.cc_rule(l_acc.id);
      NOONA_CORE_PKG.assert(NOT (l_rule = 'REQUIRED' AND r.cc IS NULL), 'NOONA-GL-055',
        'السطر ' || l_no || ': مركز التكلفة إلزامي للحساب ' || l_acc.account_code || ' - ' || l_acc.name_ar,
        'Cost center is required for this account');
      NOONA_CORE_PKG.assert(NOT (l_rule = 'FORBIDDEN' AND r.cc IS NOT NULL), 'NOONA-GL-056',
        'السطر ' || l_no || ': الحساب ' || l_acc.account_code || ' لا يقبل مركز تكلفة', 'Cost center not allowed');
      IF r.cc IS NOT NULL THEN
        SELECT COUNT(*) INTO l_n FROM gl_cost_center WHERE id = r.cc AND company_id = NOONA_GL_PKG.company AND status_code = 'ACTIVE';
        NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-GL-057', 'السطر ' || l_no || ': مركز التكلفة غير صالح أو موقوف', 'Invalid cost center');
      END IF;
      l_lines.EXTEND;
      l_lines(l_lines.COUNT).acc := l_acc.id;
      l_lines(l_lines.COUNT).amt := NOONA_REFERENCE_PKG.round_amount(r.amt, l_cur);
      l_lines(l_lines.COUNT).cc := r.cc;
      l_lines(l_lines.COUNT).txt := r.txt;
      l_total := l_total + l_lines(l_lines.COUNT).amt;
    END LOOP;
    NOONA_CORE_PKG.assert(l_lines.COUNT > 0 AND l_total > 0, 'NOONA-CSH-028', 'أدخل سطراً واحداً على الأقل بمبلغ',
                          'At least one line with an amount is required');

    IF l_id IS NULL THEN
      INSERT INTO csh_transaction (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, rate_date, txn_type, channel,
                                   bank_account_id, cash_box_id, counterparty_name, amount, amount_func, external_reference,
                                   description, status_code)
      VALUES (NOONA_GL_PKG.company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'DRAFT-' || RAWTOHEX(SYS_GUID()), TRUNC(p_date), l_cur,
              l_rate, TRUNC(p_date), p_type, CASE WHEN p_box_id IS NOT NULL THEN 'CASH' ELSE NVL(p_channel, 'BANK_TRANSFER') END,
              p_bank_id, p_box_id, p_party, l_total, NOONA_REFERENCE_PKG.round_amount(l_total * l_rate, l_led), p_reference,
              p_description, 'DRAFT')
      RETURNING id INTO l_id;
      UPDATE csh_transaction SET doc_no = 'مسودة-' || l_id WHERE id = l_id;
    ELSE
      UPDATE csh_transaction
         SET doc_date = TRUNC(p_date), rate_date = TRUNC(p_date), exchange_rate = l_rate, currency_code = l_cur,
             channel = CASE WHEN p_box_id IS NOT NULL THEN 'CASH' ELSE NVL(p_channel, 'BANK_TRANSFER') END,
             bank_account_id = p_bank_id, cash_box_id = p_box_id, counterparty_name = p_party, amount = l_total,
             amount_func = NOONA_REFERENCE_PKG.round_amount(l_total * l_rate, l_led), external_reference = p_reference,
             description = p_description
       WHERE id = l_id;
      DELETE FROM csh_transaction_line WHERE transaction_id = l_id;
    END IF;
    FOR i IN 1 .. l_lines.COUNT LOOP
      INSERT INTO csh_transaction_line (company_id, transaction_id, line_no, account_id, amount, cost_center_id, description)
      VALUES (NOONA_GL_PKG.company, l_id, i, l_lines(i).acc, l_lines(i).amt, l_lines(i).cc, l_lines(i).txt);
    END LOOP;
    RETURN l_id;
  END save_voucher;

  PROCEDURE submit_voucher(p_id IN NUMBER) IS
    l_t csh_transaction%ROWTYPE := get_txn(p_id, TRUE);
  BEGIN
    guard('CSH_TRANSACTION.SUBMIT');
    assert_draft(l_t);
    UPDATE csh_transaction SET status_code = 'SUBMITTED' WHERE id = p_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', c_entity, p_id, 'SUBMIT', 'SUCCESS');
  END submit_voucher;

  PROCEDURE approve_voucher(p_id IN NUMBER, p_comment IN VARCHAR2 DEFAULT NULL) IS
    l_t     csh_transaction%ROWTYPE := get_txn(p_id, TRUE);
    l_cash  NUMBER;
    l_max   NUMBER;
    l_st    VARCHAR2(30);
    l_bal   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_no    VARCHAR2(100);
    l_j     NUMBER;
    l_ev    NUMBER;
    l_in    BOOLEAN := l_t.txn_type = 'RECEIPT';
  BEGIN
    guard('CSH_TRANSACTION.APPROVE');
    NOONA_SECURITY_PKG.assert_permission('CSH_TRANSACTION.POST', l_t.company_id);
    NOONA_CORE_PKG.assert(l_t.status_code = 'SUBMITTED', 'NOONA-CSH-030', 'السند ليس بانتظار الاعتماد', 'Voucher is not pending approval');
    NOONA_CORE_PKG.assert(l_t.created_by <> NOONA_CTX_PKG.current_user_name, 'NOONA-CSH-031',
      'لا يعتمد السند من أنشأه (فصل المهام)', 'Maker cannot approve their own voucher');
    NOONA_DMS_PKG.assert_reference(c_entity, p_id);            -- المرجع الورقي حسب قاعدة الأرشفة
    IF l_t.cash_box_id IS NOT NULL THEN
      SELECT gl_account_id, status_code INTO l_cash, l_st FROM csh_cash_box WHERE id = l_t.cash_box_id FOR UPDATE;
    ELSE
      SELECT gl_account_id, status_code, max_payment_amount INTO l_cash, l_st, l_max
        FROM csh_bank_account WHERE id = l_t.bank_account_id FOR UPDATE;
    END IF;
    NOONA_CORE_PKG.assert(l_st = 'ACTIVE', 'NOONA-CSH-025', 'الصندوق أو الحساب البنكي غير نشط', 'Cash box or bank account is not active');
    IF NOT l_in THEN
      IF l_t.cash_box_id IS NOT NULL THEN
        -- الصندوق مقفول (FOR UPDATE) فلا يصرف سندان متزامنان أكثر من الرصيد
        l_bal := balance(l_t.cash_box_id, NULL);
        NOONA_CORE_PKG.assert(l_bal >= l_t.amount, 'NOONA-CSH-040',
          'رصيد الصندوق (' || fmt0(l_bal) || ') لا يكفي لصرف ' || fmt0(l_t.amount), 'Insufficient cash box balance');
      ELSE
        NOONA_CORE_PKG.assert(l_max IS NULL OR l_t.amount <= l_max, 'NOONA-CSH-041',
          'المبلغ يتجاوز حد الدفع للحساب البنكي (' || fmt0(l_max) || ')', 'Amount exceeds the bank account payment limit');
      END IF;
    END IF;
    -- القيد: القبض مدين النقدية ودائن السطور، والصرف عكسه
    l_lines.EXTEND;
    l_lines(1).account_id := l_cash;
    l_lines(1).debit := CASE WHEN l_in THEN l_t.amount ELSE 0 END;
    l_lines(1).credit := CASE WHEN l_in THEN 0 ELSE l_t.amount END;
    l_lines(1).description := l_t.description;
    FOR r IN (SELECT * FROM csh_transaction_line WHERE transaction_id = p_id ORDER BY line_no) LOOP
      l_lines.EXTEND;
      l_lines(l_lines.COUNT).account_id := r.account_id;
      l_lines(l_lines.COUNT).debit := CASE WHEN l_in THEN 0 ELSE r.amount END;
      l_lines(l_lines.COUNT).credit := CASE WHEN l_in THEN r.amount ELSE 0 END;
      l_lines(l_lines.COUNT).cost_center_id := r.cost_center_id;
      l_lines(l_lines.COUNT).description := NVL(r.description, l_t.description);
    END LOOP;
    l_no := NOONA_REFERENCE_PKG.next_doc_no('CSH_' || l_t.txn_type, l_t.company_id, l_t.branch_id, l_t.doc_date, c_entity, p_id);
    UPDATE csh_transaction SET doc_no = l_no WHERE id = p_id;
    l_j := NOONA_ACE_PKG.post_source('CSH_TXN_SETTLED', 'CASH', c_entity, p_id, l_t.doc_date,
                                     type_label(l_t.txn_type) || ' ' || l_no || ': ' || l_t.description,
                                     l_t.currency_code, l_t.exchange_rate, l_lines, l_no, l_t.branch_id,
                                     CASE l_t.txn_type WHEN 'RECEIPT' THEN 'RECEIPT' WHEN 'PAYMENT' THEN 'PAYMENT'
                                                       WHEN 'EXPENSE' THEN 'EXPENSE' ELSE 'TRANSFER' END);
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    UPDATE csh_transaction
       SET status_code = 'SETTLED', settled_at = SYSTIMESTAMP, posted_at = SYSTIMESTAMP,
           posted_by = NOONA_CTX_PKG.current_user_name, accounting_event_id = l_ev
     WHERE id = p_id;
    NOONA_AUDIT_PKG.log_event('PAYMENT', c_entity, p_id, 'APPROVE_POST', 'SUCCESS', p_reason => p_comment,
      p_new_values => '{"doc_no":' || NOONA_CORE_PKG.json_text(l_no) || ',"amount":' || l_t.amount || '}');
  END approve_voucher;

  PROCEDURE reject_voucher(p_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_t csh_transaction%ROWTYPE := get_txn(p_id, TRUE);
  BEGIN
    guard('CSH_TRANSACTION.REJECT');
    NOONA_CORE_PKG.assert(l_t.status_code = 'SUBMITTED', 'NOONA-CSH-030', 'السند ليس بانتظار الاعتماد', 'Voucher is not pending approval');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-CSH-032', 'سبب الرفض إلزامي', 'Reason is required');
    UPDATE csh_transaction SET status_code = 'DRAFT' WHERE id = p_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', c_entity, p_id, 'REJECT', 'SUCCESS', p_reason => p_reason);
  END reject_voucher;

  PROCEDURE cancel_voucher(p_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_t csh_transaction%ROWTYPE := get_txn(p_id, TRUE);
  BEGIN
    guard('CSH_TRANSACTION.CANCEL');
    assert_draft(l_t);
    UPDATE csh_transaction SET status_code = 'CANCELLED' WHERE id = p_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_entity, p_id, 'CANCEL', 'SUCCESS', p_reason => p_reason);
  END cancel_voucher;

  FUNCTION reverse_voucher(p_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_t   csh_transaction%ROWTYPE := get_txn(p_id, TRUE);
    l_rev NUMBER;
    l_bal NUMBER;
  BEGIN
    guard('CSH_TRANSACTION.REVERSE');
    NOONA_CORE_PKG.assert(l_t.status_code = 'SETTLED', 'NOONA-CSH-033', 'يعكس السند المرحل فقط', 'Only posted vouchers can be reversed');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-GL-081', 'سبب العكس إلزامي', 'Reason is required');
    -- عكس سند قبض نقدي يخفض الصندوق: لا يسمح برصيد سالب
    IF l_t.txn_type = 'RECEIPT' AND l_t.cash_box_id IS NOT NULL THEN
      l_bal := balance(l_t.cash_box_id, NULL);
      NOONA_CORE_PKG.assert(l_bal >= l_t.amount, 'NOONA-CSH-040',
        'رصيد الصندوق (' || fmt0(l_bal) || ') لا يكفي لعكس القبض', 'Insufficient cash box balance');
    END IF;
    l_rev := NOONA_ACE_PKG.reverse_source(c_entity, p_id, p_date, p_reason);
    UPDATE csh_transaction SET status_code = 'REVERSED' WHERE id = p_id;
    NOONA_AUDIT_PKG.log_event('PAYMENT', c_entity, p_id, 'REVERSE', 'SUCCESS', p_reason => p_reason);
    RETURN l_rev;
  END reverse_voucher;

  -- ================================================================ مستند السند (HTML + JSON)
  FUNCTION save_voucher_doc(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_place VARCHAR2(50) := l_o.get_string('place');
    l_ln    JSON_ARRAY_T := l_o.get_array('lines');
    l_id    NUMBER;
  BEGIN
    l_id := save_voucher(
      p_id => l_o.get_number('id'), p_type => l_o.get_string('type'), p_date => TO_DATE(l_o.get_string('date'), 'YYYY-MM-DD'),
      p_box_id => CASE WHEN l_place LIKE 'BOX:%' THEN TO_NUMBER(SUBSTR(l_place, 5)) END,
      p_bank_id => CASE WHEN l_place LIKE 'BANK:%' THEN TO_NUMBER(SUBSTR(l_place, 6)) END,
      p_channel => l_o.get_string('channel'), p_party => l_o.get_string('party'), p_description => l_o.get_string('desc'),
      p_reference => l_o.get_string('ref'), p_lines => CASE WHEN l_ln IS NULL THEN '[]' ELSE l_ln.to_clob END,
      p_rate => l_o.get_number('rate'));
    IF l_o.get_string('action') = 'SUBMIT' THEN
      submit_voucher(l_id);
    END IF;
    RETURN l_id;
  END save_voucher_doc;

  FUNCTION voucher_doc_json(p_id IN NUMBER, p_type IN VARCHAR2 DEFAULT 'RECEIPT') RETURN CLOB IS
    l_t csh_transaction%ROWTYPE;
  BEGIN
    IF p_id IS NULL THEN
      RETURN '{"id":null,"type":' || NOONA_CORE_PKG.json_text(CASE WHEN p_type IN ('RECEIPT', 'PAYMENT', 'EXPENSE') THEN p_type ELSE 'RECEIPT' END)
          || ',"status":"DRAFT","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","lines":[]}';
    END IF;
    l_t := get_txn(p_id);
    RETURN '{"id":' || l_t.id || ',"type":' || NOONA_CORE_PKG.json_text(l_t.txn_type) || ',"no":' || NOONA_CORE_PKG.json_text(l_t.doc_no)
        || ',"status":' || NOONA_CORE_PKG.json_text(l_t.status_code) || ',"date":"' || TO_CHAR(l_t.doc_date, 'YYYY-MM-DD') || '"'
        || ',"place":' || NOONA_CORE_PKG.json_text(CASE WHEN l_t.cash_box_id IS NOT NULL THEN 'BOX:' || l_t.cash_box_id ELSE 'BANK:' || l_t.bank_account_id END)
        || ',"channel":' || NOONA_CORE_PKG.json_text(l_t.channel) || ',"party":' || NOONA_CORE_PKG.json_text(l_t.counterparty_name)
        || ',"desc":' || NOONA_CORE_PKG.json_text(l_t.description) || ',"ref":' || NOONA_CORE_PKG.json_text(l_t.external_reference)
        || ',"cur":' || NOONA_CORE_PKG.json_text(l_t.currency_code)
        || ',"rate":' || TO_CHAR(l_t.exchange_rate, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''')
        || ',"words":' || NOONA_CORE_PKG.json_text(amount_words(l_t.amount, l_t.currency_code))
        || ',"lines":' || lines_json(p_id) || '}';
  END voucher_doc_json;

  FUNCTION places_json RETURN CLOB IS
    l_out CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('v' VALUE v, 'n' VALUE n, 'c' VALUE c, 'k' VALUE k) ORDER BY o, n RETURNING CLOB) INTO l_out
      FROM (SELECT 'BOX:' || id v, name_ar n, currency_code c, 'BOX' k, 1 o FROM csh_cash_box
             WHERE company_id = NOONA_GL_PKG.company AND status_code = 'ACTIVE'
            UNION ALL
            SELECT 'BANK:' || id, name_ar || ' ' || account_no_masked, currency_code, 'BANK', 2 FROM csh_bank_account
             WHERE company_id = NOONA_GL_PKG.company AND status_code = 'ACTIVE');
    RETURN NVL(l_out, '[]');
  END places_json;

  -- ================================================================ الواجهة
  FUNCTION accounts_json(p_type IN VARCHAR2) RETURN CLOB IS
    l_out CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('a' VALUE a.account_code, 'n' VALUE a.name_ar,
                                     'r' VALUE NVL(NOONA_GL_PKG.cc_rule(a.id), 'OPTIONAL')) ORDER BY a.account_code RETURNING CLOB)
      INTO l_out
      FROM gl_account a
     WHERE a.coa_id = NOONA_GL_PKG.primary_coa AND a.is_postable = 'Y' AND a.status_code = 'ACTIVE'
       AND a.allow_manual_posting = 'Y' AND (NVL(p_type, 'X') <> 'EXPENSE' OR a.account_type = 'EXPENSE');
    RETURN NVL(l_out, '[]');
  END accounts_json;

  FUNCTION lines_json(p_id IN NUMBER) RETURN CLOB IS
    l_out CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('a' VALUE a.account_code, 'm' VALUE l.amount, 'cc' VALUE l.cost_center_id,
                                     't' VALUE l.description) ORDER BY l.line_no RETURNING CLOB)
      INTO l_out
      FROM csh_transaction_line l JOIN gl_account a ON a.id = l.account_id
     WHERE l.transaction_id = p_id AND l.company_id = NOONA_GL_PKG.company;
    RETURN NVL(l_out, '[]');
  END lines_json;

  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_class VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span>'
        || '<div><div class="nn-kpi-value">' || esc(p_value) || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION summary(p_session IN VARCHAR2) RETURN CLOB IS
    l_sub NUMBER; l_draft NUMBER; l_in NUMBER; l_out NUMBER; l_cash NUMBER := 0; l_boxes NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_boxes FROM csh_cash_box WHERE company_id = NOONA_GL_PKG.company;
    IF l_boxes = 0 THEN
      RETURN '<div class="nn-launch-empty"><span class="fa fa-money" aria-hidden="true"></span>'
          || '<b>النقدية غير مجهزة لهذه الشركة</b><span>اضغط "تجهيز النقدية" لإنشاء الصندوق الرئيسي وتسلسلات السندات '
          || '(يتطلب تجهيز الأستاذ العام)</span></div>';
    END IF;
    SELECT COUNT(CASE WHEN status_code = 'DRAFT' THEN 1 END), COUNT(CASE WHEN status_code = 'SUBMITTED' THEN 1 END),
           NVL(SUM(CASE WHEN status_code IN ('SETTLED', 'REVERSED') AND txn_type = 'RECEIPT' AND doc_date >= TRUNC(SYSDATE, 'MM') THEN amount_func END), 0),
           NVL(SUM(CASE WHEN status_code IN ('SETTLED', 'REVERSED') AND txn_type <> 'RECEIPT' AND doc_date >= TRUNC(SYSDATE, 'MM') THEN amount_func END), 0)
      INTO l_draft, l_sub, l_in, l_out
      FROM csh_transaction WHERE company_id = NOONA_GL_PKG.company AND txn_type IN ('RECEIPT', 'PAYMENT', 'EXPENSE');
    FOR b IN (SELECT id FROM csh_cash_box WHERE company_id = NOONA_GL_PKG.company AND status_code = 'ACTIVE') LOOP
      l_cash := l_cash + balance(b.id, NULL);
    END LOOP;
    RETURN '<div class="nn-kpis">'
        || kpi('رصيد الصناديق', fmt0(l_cash), 'fa-archive', 'is-info')
        || kpi('مقبوضات هذا الشهر', fmt0(l_in), 'fa-arrow-down', 'is-success')
        || kpi('مدفوعات هذا الشهر', fmt0(l_out), 'fa-arrow-up', 'is-danger')
        || kpi('سندات بانتظار الاعتماد', l_sub, 'fa-hourglass-half', CASE WHEN l_sub > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('سندات مسودة', l_draft, 'fa-pencil', 'is-muted')
        || '</div>';
  END summary;

  FUNCTION balances_html RETURN CLOB IS
    l_html CLOB;
    l_tot  NUMBER := 0;
    l_b    NUMBER;
  BEGIN
    l_html := '<table class="nn-rpt"><thead><tr><th>النوع</th><th>الرمز</th><th>الاسم</th><th>الحساب</th><th>الحالة</th>'
           || '<th>الرصيد</th></tr></thead><tbody>';
    FOR r IN (SELECT 'صندوق' k, b.id box_id, NULL bank_id, b.code, b.name_ar, a.account_code || ' ' || a.name_ar acc, b.status_code
                FROM csh_cash_box b JOIN gl_account a ON a.id = b.gl_account_id WHERE b.company_id = NOONA_GL_PKG.company
              UNION ALL
              SELECT 'بنك', NULL, b.id, b.code, b.name_ar || ' ' || b.account_no_masked, a.account_code || ' ' || a.name_ar, b.status_code
                FROM csh_bank_account b JOIN gl_account a ON a.id = b.gl_account_id WHERE b.company_id = NOONA_GL_PKG.company
              ORDER BY 1 DESC, 4) LOOP
      l_b := balance(r.box_id, r.bank_id);
      l_tot := l_tot + l_b;
      l_html := l_html || '<tr><td>' || r.k || '</td><td>' || esc(r.code) || '</td><td class="nn-rpt-text">' || esc(r.name_ar)
             || '</td><td class="nn-rpt-text">' || esc(r.acc) || '</td><td>' || NOONA_UI_PKG.status_badge(r.status_code)
             || '</td><td>' || fmt0(l_b) || '</td></tr>';
    END LOOP;
    RETURN l_html || '</tbody><tfoot><tr><td colspan="5">إجمالي النقدية</td><td>' || fmt0(l_tot) || '</td></tr></tfoot></table>';
  END balances_html;

  FUNCTION place_name(p_t csh_transaction%ROWTYPE) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    IF p_t.cash_box_id IS NOT NULL THEN
      SELECT 'الصندوق: ' || name_ar INTO l FROM csh_cash_box WHERE id = p_t.cash_box_id;
    ELSE
      SELECT 'البنك: ' || name_ar || ' ' || account_no_masked INTO l FROM csh_bank_account WHERE id = p_t.bank_account_id;
    END IF;
    RETURN l;
  END place_name;

  FUNCTION journal_no(p_t csh_transaction%ROWTYPE) RETURN VARCHAR2 IS
    l VARCHAR2(200);
  BEGIN
    SELECT LISTAGG(j.doc_no, ' / ') WITHIN GROUP (ORDER BY j.id) INTO l
      FROM ace_accounting_event e JOIN gl_journal j ON j.id = e.journal_id
     WHERE e.source_entity_type = c_entity AND e.source_entity_id = p_t.id;
    RETURN l;
  END journal_no;

  FUNCTION field(p_label VARCHAR2, p_value VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-field"><div class="nn-field-label">' || p_label || '</div><div class="nn-field-value">'
        || NVL(p_value, '-') || '</div></div>';
  END field;

  FUNCTION voucher_header(p_id IN NUMBER) RETURN CLOB IS
    l_t csh_transaction%ROWTYPE := get_txn(p_id);
  BEGIN
    RETURN '<div class="nn-taskhead ' || CASE l_t.status_code WHEN 'SETTLED' THEN 'is-success' WHEN 'SUBMITTED' THEN 'is-warning'
                                          WHEN 'REVERSED' THEN 'is-danger' ELSE '' END || '">'
        || '<div class="nn-taskhead-top"><div><div class="nn-taskhead-title">' || type_label(l_t.txn_type) || ' ' || esc(l_t.doc_no)
        || '</div><div class="nn-taskhead-sub">' || esc(l_t.description) || '</div></div>'
        || NOONA_UI_PKG.status_badge(l_t.status_code) || '</div><div class="nn-fields">'
        || field('التاريخ', TO_CHAR(l_t.doc_date, 'YYYY-MM-DD'))
        || field('المبلغ', fmt0(l_t.amount) || ' ' || esc(l_t.currency_code))
        || field(CASE l_t.txn_type WHEN 'RECEIPT' THEN 'استلمنا من' ELSE 'صرفنا إلى' END, esc(l_t.counterparty_name))
        || field('الصندوق / البنك', esc(place_name(l_t)))
        || field('أنشأه / اعتمده', esc(l_t.created_by) || CASE WHEN l_t.posted_by IS NOT NULL THEN ' / ' || esc(l_t.posted_by) END)
        || field('القيد المحاسبي', esc(journal_no(l_t)))
        || '</div></div>';
  END voucher_header;

  FUNCTION voucher_print(p_id IN NUMBER) RETURN CLOB IS
    l_t    csh_transaction%ROWTYPE := get_txn(p_id);
    l_html CLOB;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('CSH_TRANSACTION.VIEW', NOONA_GL_PKG.company);
    l_html := NOONA_BRAND_PKG.report_header(type_label(l_t.txn_type) || ' رقم ' || l_t.doc_no)
           || '<div class="nn-fields">'
           || field('التاريخ', TO_CHAR(l_t.doc_date, 'YYYY-MM-DD'))
           || field(CASE l_t.txn_type WHEN 'RECEIPT' THEN 'استلمنا من السيد/السادة' ELSE 'صرفنا إلى السيد/السادة' END,
                    esc(l_t.counterparty_name))
           || field('المبلغ', '<b>' || fmt0(l_t.amount) || ' ' || esc(l_t.currency_code) || '</b>')
           || field('طريقة الدفع', esc(NOONA_UI_PKG.code_label(l_t.channel)) || ' - ' || esc(place_name(l_t)))
           || field('المرجع', esc(l_t.external_reference))
           || field('القيد المحاسبي', esc(journal_no(l_t)))
           || field('مرجع الأرشيف', esc(NOONA_DMS_PKG.refs_text(c_entity, l_t.id)))
           || '</div><div class="nn-words">' || esc(amount_words(l_t.amount, l_t.currency_code)) || '</div>'
           || '<div class="nn-words-sub">وذلك عن: ' || esc(l_t.description) || '</div>'
           || '<table class="nn-rpt"><thead><tr><th>#</th><th>الحساب</th><th>مركز التكلفة</th><th>البيان</th><th>المبلغ</th></tr></thead><tbody>';
    FOR r IN (SELECT l.line_no, a.account_code || ' - ' || a.name_ar acc, c.code || ' ' || c.name_ar cc,
                     NVL(l.description, l_t.description) description, l.amount
                FROM csh_transaction_line l JOIN gl_account a ON a.id = l.account_id
                LEFT JOIN gl_cost_center c ON c.id = l.cost_center_id
               WHERE l.transaction_id = p_id ORDER BY l.line_no) LOOP
      l_html := l_html || '<tr><td>' || r.line_no || '</td><td class="nn-rpt-text">' || esc(r.acc) || '</td><td class="nn-rpt-text">'
             || esc(r.cc) || '</td><td class="nn-rpt-text">' || esc(r.description) || '</td><td>' || fmt0(r.amount) || '</td></tr>';
    END LOOP;
    RETURN l_html || '</tbody><tfoot><tr><td colspan="4">الإجمالي</td><td>' || fmt0(l_t.amount) || '</td></tr></tfoot></table>'
        || '<div class="nn-sign"><div>المحاسب<br><span>' || esc(l_t.created_by) || '</span></div><div>المعتمد<br><span>'
        || esc(l_t.posted_by) || '</span></div><div>' || CASE l_t.txn_type WHEN 'RECEIPT' THEN 'أمين الصندوق' ELSE 'المستلم' END
        || '<br><span>&nbsp;</span></div></div>';
  END voucher_print;

  FUNCTION cash_book(p_box_id IN NUMBER, p_bank_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_open NUMBER;
    l_bal  NUMBER;
    l_in   NUMBER := 0;
    l_out  NUMBER := 0;
    l_name VARCHAR2(400);
    l_html CLOB;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('CSH_TRANSACTION.VIEW', NOONA_GL_PKG.company);
    IF p_box_id IS NULL AND p_bank_id IS NULL THEN
      RETURN '<div class="nn-empty">اختر الصندوق أو الحساب البنكي والفترة</div>';
    END IF;
    IF p_box_id IS NOT NULL THEN
      SELECT 'الصندوق ' || name_ar INTO l_name FROM csh_cash_box WHERE id = p_box_id AND company_id = NOONA_GL_PKG.company;
    ELSE
      SELECT 'البنك ' || name_ar || ' ' || account_no_masked INTO l_name FROM csh_bank_account WHERE id = p_bank_id AND company_id = NOONA_GL_PKG.company;
    END IF;
    l_open := balance(p_box_id, p_bank_id, p_from - 1);
    l_bal := l_open;
    l_html := NOONA_BRAND_PKG.report_header('دفتر ' || l_name || ' من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى '
                                            || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>رقم السند</th><th>النوع</th><th>الطرف</th><th>البيان</th>'
           || '<th>مقبوضات</th><th>مدفوعات</th><th>الرصيد</th></tr></thead><tbody><tr class="nn-rpt-group"><td colspan="7">'
           || 'رصيد أول المدة</td><td>' || fmt0(l_open) || '</td></tr>';
    FOR r IN (SELECT e.accounting_date d, t.doc_no, t.txn_type, t.counterparty_name, t.description,
                     CASE WHEN e.reversal_of_event_id IS NULL THEN 'N' ELSE 'Y' END is_rev,
                     CASE WHEN t.txn_type = 'RECEIPT' THEN 1 ELSE -1 END * t.amount
                       * CASE WHEN e.reversal_of_event_id IS NULL THEN 1 ELSE -1 END amt
                FROM csh_transaction t
                JOIN ace_accounting_event e ON ((e.source_entity_type = c_entity AND e.source_entity_id = t.id)
                 OR (t.source_entity_type <> c_entity AND (e.id = t.accounting_event_id OR e.reversal_of_event_id = t.accounting_event_id)))
                AND e.journal_id IS NOT NULL
               WHERE t.company_id = NOONA_GL_PKG.company
                 AND ((p_box_id IS NOT NULL AND t.cash_box_id = p_box_id) OR (p_bank_id IS NOT NULL AND t.bank_account_id = p_bank_id))
                 AND e.accounting_date BETWEEN p_from AND p_to
               ORDER BY e.accounting_date, e.id) LOOP
      l_bal := l_bal + r.amt;
      IF r.amt > 0 THEN l_in := l_in + r.amt; ELSE l_out := l_out - r.amt; END IF;
      l_html := l_html || '<tr><td>' || TO_CHAR(r.d, 'YYYY-MM-DD') || '</td><td>' || esc(r.doc_no) || '</td><td>'
             || type_label(r.txn_type) || CASE WHEN r.is_rev = 'Y' THEN ' (عكس)' END || '</td><td class="nn-rpt-text">'
             || esc(r.counterparty_name) || '</td><td class="nn-rpt-text">' || esc(r.description) || '</td><td>'
             || fmt(GREATEST(r.amt, 0)) || '</td><td>' || fmt(GREATEST(-r.amt, 0)) || '</td><td>' || fmt0(l_bal) || '</td></tr>';
    END LOOP;
    RETURN l_html || '</tbody><tfoot><tr><td colspan="5">الإجمالي والرصيد الختامي</td><td>' || fmt0(l_in) || '</td><td>'
        || fmt0(l_out) || '</td><td>' || fmt0(l_bal) || '</td></tr></tfoot></table>';
  END cash_book;

END NOONA_CSH_PKG;
/
