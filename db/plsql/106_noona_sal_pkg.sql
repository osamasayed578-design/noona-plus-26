-- =============================================================================
-- NOONA PLUS ERP | العملاء والمبيعات: NOONA_SAL_PKG
--   العملاء (طرف موحد + حساب عميل لكل شركة + حد ائتمان) والعميل النقدي العام للبيع المباشر،
--   فاتورة المبيعات (آجل/نقدي) مع صرف المخزون بالأقدم انتهاءً وتكلفة المبيعات بالمتوسط، الوصفة الطبية للأدوية،
--   الحد الأدنى للسعر، المرتجع (إشعار دائن)، التحصيل من العملاء، كشف الحساب وأعمار الديون وتقارير المبيعات والربحية،
--   رمز الاستجابة السريعة للفاتورة الضريبية المبسطة (ZATCA TLV).
-- =============================================================================

CREATE OR REPLACE PACKAGE NOONA_SAL_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;

  -- ---------------------------------------------------------- العملاء
  -- {"id":accountId,"name","nameEn","person":"Y","tax","cr","phone","email","address","term":"NET30","limit":5000,"status"}
  FUNCTION save_customer(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION customer_json(p_account_id IN NUMBER) RETURN CLOB;
  FUNCTION customers_json(p_term IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION customer_label(p_account_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION customer_party(p_account_id IN NUMBER) RETURN NUMBER;
  -- حساب العميل في الشركة لطرف قائم (مشتري وحدة، مستأجر...)؛ ينشأ إن لم يوجد
  FUNCTION party_account(p_party_id IN NUMBER) RETURN NUMBER;
  FUNCTION customer_balance(p_account_id IN NUMBER, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER;
  FUNCTION credit_limit(p_account_id IN NUMBER) RETURN NUMBER;
  -- يتحقق من حد الائتمان عند إضافة مبلغ آجل
  PROCEDURE check_credit(p_account_id IN NUMBER, p_amount IN NUMBER);
  -- العميل النقدي العام للشركة (ينشأ عند الحاجة)
  FUNCTION walk_in_customer RETURN NUMBER;
  FUNCTION is_walk_in(p_account_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- التسعير والضريبة (مشترك مع نقاط البيع)
  -- يحسب صافي وضريبة سطر: السعر شامل الضريبة أو غير شامل
  PROCEDURE price_line(p_item_id IN NUMBER, p_qty IN NUMBER, p_price IN OUT NUMBER, p_disc IN NUMBER, p_incl IN OUT VARCHAR2,
                       p_tax_code IN OUT NUMBER, p_date IN DATE, p_net OUT NUMBER, p_tax OUT NUMBER);
  FUNCTION seller_vat RETURN VARCHAR2;
  FUNCTION seller_name RETURN VARCHAR2;
  -- رمز ZATCA (المرحلة الأولى): البائع، الرقم الضريبي، الوقت، الإجمالي، الضريبة بترميز TLV ثم Base64
  FUNCTION zatca_qr(p_at IN TIMESTAMP, p_total IN NUMBER, p_vat IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- فاتورة المبيعات
  -- {"id","cust","date","wh","mode":"CREDIT|CASH","place":"BOX:1","method":"CASH","cc","name","taxNo","rx","notes","action":"SAVE|POST",
  --  "lines":[{"i","d","q","p","inc":"Y","disc","tc","acc","cc"}]}
  FUNCTION save_invoice(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION invoice_json(p_invoice_id IN NUMBER) RETURN CLOB;
  PROCEDURE post_invoice(p_invoice_id IN NUMBER);
  PROCEDURE cancel_invoice(p_invoice_id IN NUMBER);
  -- المرتجع: {"inv","date","reason","place","lines":[{"l":lineId,"q"}]}
  FUNCTION post_return(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION returnable_json(p_invoice_id IN NUMBER) RETURN CLOB;
  -- شاشة المرتجع: {"inv","no","date","lines":[...]}
  FUNCTION return_doc_json(p_invoice_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- التحصيل
  -- {"cust","date","amount","place","method":"CASH|MADA|BANK_APP...","ref","notes","alloc":[{"inv":id,"a":100}]}
  FUNCTION receive(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION reverse_receipt(p_receipt_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER;
  FUNCTION open_items_json(p_account_id IN NUMBER) RETURN CLOB;
  -- تخفيض الذمم المفتوحة لمستند (مرتجع آجل من نقاط البيع)؛ يعيد المتبقي غير المسوى
  FUNCTION settle_open(p_source_type IN VARCHAR2, p_source_id IN NUMBER, p_amount IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- التقارير
  FUNCTION sal_summary RETURN CLOB;
  FUNCTION customer_statement(p_account_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION ar_aging(p_as_of IN DATE DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION sales_register(p_from IN DATE, p_to IN DATE, p_account_id IN NUMBER DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- المبيعات والربحية حسب الصنف (الفواتير ونقاط البيع)
  FUNCTION sales_by_item(p_from IN DATE, p_to IN DATE, p_category_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION invoice_print(p_invoice_id IN NUMBER) RETURN CLOB;
  FUNCTION mode_label(p_mode IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
END NOONA_SAL_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_SAL_PKG AS

  c_inv CONSTANT VARCHAR2(30) := 'SAL_INVOICE';
  c_rcp CONSTANT VARCHAR2(30) := 'AR_RECEIPT';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL OR p = 0 THEN '' ELSE TO_CHAR(p, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END fmt;
  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(NVL(p, 0), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END fmt0;
  FUNCTION fqty(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(TO_CHAR(NVL(p, 0), 'FM999G999G999G990D999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '.');
  END fqty;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;
  FUNCTION d(p VARCHAR2) RETURN DATE IS BEGIN RETURN TO_DATE(p, 'YYYY-MM-DD'); END;

  FUNCTION mode_label(p_mode IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_mode WHEN 'CASH' THEN 'نقدي' WHEN 'CREDIT' THEN 'آجل' ELSE p_mode END;
  END mode_label;

  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'DRAFT' THEN 'مسودة' WHEN 'POSTED' THEN 'مرحلة' WHEN 'PARTIALLY_PAID' THEN 'محصلة جزئياً'
                         WHEN 'PAID' THEN 'محصلة' WHEN 'CANCELLED' THEN 'ملغاة' WHEN 'CREDITED' THEN 'مرتجعة' WHEN 'CONFIRMED' THEN 'مؤكد'
                         WHEN 'REVERSED' THEN 'معكوس' WHEN 'ACTIVE' THEN 'نشط' ELSE p_status END;
  END status_label;

  -- ================================================================ التجهيز
  FUNCTION is_ready RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM ref_doc_sequence WHERE company_id = company AND doc_type_code IN ('SAL_INVOICE', 'AR_RECEIPT', 'AR_CUSTOMER');
    RETURN CASE WHEN l = 3 AND NOONA_INV_PKG.is_ready = 'Y' THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n NUMBER;
    l_x NUMBER;
  BEGIN
    guard('AR_CUSTOMER.CREATE');
    l_n := NOONA_INV_PKG.quick_setup;
    NOONA_INV_PKG.ensure_sequence('AR_CUSTOMER', 'CUS-');
    NOONA_INV_PKG.ensure_sequence('SAL_INVOICE', 'SI-');
    NOONA_INV_PKG.ensure_sequence('SAL_CREDIT_NOTE', 'SR-');
    NOONA_INV_PKG.ensure_sequence('AR_RECEIPT', 'RC-');
    SELECT COUNT(*) INTO l_x FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
     WHERE a.company_id = company AND c.is_walk_in = 'Y';
    IF l_x = 0 THEN
      l_x := walk_in_customer;
      l_n := l_n + 1;
    END IF;
    RETURN l_n;
  END quick_setup;

  FUNCTION term_id(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM ref_payment_term WHERE code = NVL(p_code, 'NET0') AND is_active = 'Y';
    RETURN l;
  END term_id;

  FUNCTION method_id(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM ref_payment_method WHERE code = NVL(p_code, 'CASH') AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-SAL-060', 'طريقة السداد غير معرفة: ' || p_code, 'Unknown payment method');
    RETURN l;
  END method_id;

  -- ================================================================ العملاء
  FUNCTION get_account(p_account_id NUMBER) RETURN ar_customer_account%ROWTYPE IS
    l ar_customer_account%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM ar_customer_account WHERE id = p_account_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SAL-001', 'العميل غير موجود في هذه الشركة', 'Customer not found');
  END get_account;

  FUNCTION customer_party(p_account_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT c.party_id INTO l FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id WHERE a.id = p_account_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END customer_party;

  FUNCTION customer_label(p_account_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT c.customer_no || ' - ' || p.display_name_ar INTO l
      FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
     WHERE a.id = p_account_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END customer_label;

  FUNCTION is_walk_in(p_account_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(1);
  BEGIN
    SELECT c.is_walk_in INTO l FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id WHERE a.id = p_account_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'N';
  END is_walk_in;

  FUNCTION receivable_account(p_acc ar_customer_account%ROWTYPE) RETURN NUMBER IS
  BEGIN
    RETURN NVL(p_acc.receivable_account_id, NOONA_INV_PKG.acc_id('1103'));
  END receivable_account;

  PROCEDURE upsert_contact(p_party NUMBER, p_phone VARCHAR2, p_email VARCHAR2, p_address VARCHAR2) IS
    l NUMBER;
  BEGIN
    IF p_phone IS NOT NULL OR p_email IS NOT NULL THEN
      SELECT MIN(id) INTO l FROM ref_contact WHERE party_id = p_party AND is_primary = 'Y';
      IF l IS NULL THEN
        INSERT INTO ref_contact (party_id, contact_role, mobile, email, is_primary) VALUES (p_party, 'GENERAL', p_phone, p_email, 'Y');
      ELSE
        UPDATE ref_contact SET mobile = p_phone, email = p_email WHERE id = l;
      END IF;
    END IF;
    IF p_address IS NOT NULL THEN
      SELECT MIN(id) INTO l FROM ref_address WHERE party_id = p_party AND address_type = 'BILLING';
      IF l IS NULL THEN
        INSERT INTO ref_address (party_id, address_type, country_code, address_line_ar, is_primary) VALUES (p_party, 'BILLING', 'SA', p_address, 'Y');
      ELSE
        UPDATE ref_address SET address_line_ar = p_address WHERE id = l;
      END IF;
    END IF;
  END upsert_contact;

  PROCEDURE set_limit(p_account NUMBER, p_limit NUMBER) IS
  BEGIN
    UPDATE ar_credit_limit SET effective_to = TRUNC(SYSDATE) - 1
     WHERE customer_account_id = p_account AND company_id = company AND effective_to IS NULL AND effective_from < TRUNC(SYSDATE);
    DELETE FROM ar_credit_limit WHERE customer_account_id = p_account AND company_id = company AND effective_from >= TRUNC(SYSDATE);
    IF p_limit IS NOT NULL THEN
      INSERT INTO ar_credit_limit (company_id, customer_account_id, currency_code, credit_limit, effective_from)
      VALUES (company, p_account, NOONA_GL_PKG.ledger_currency, p_limit, TRUNC(SYSDATE));
    END IF;
  END set_limit;

  FUNCTION create_account(p_party NUMBER, p_walk_in VARCHAR2, p_term NUMBER, p_status VARCHAR2) RETURN NUMBER IS
    l_cus NUMBER;
    l_id  NUMBER;
    l_no  VARCHAR2(50);
  BEGIN
    l_no := NOONA_REFERENCE_PKG.next_doc_no('AR_CUSTOMER', company, NULL, TRUNC(SYSDATE), 'AR_CUSTOMER', NULL);
    INSERT INTO ar_customer (party_id, customer_no, customer_class, is_walk_in, status_code)
    VALUES (p_party, l_no, CASE WHEN p_walk_in = 'Y' THEN 'WALK_IN' ELSE 'STANDARD' END, p_walk_in, 'ACTIVE')
    RETURNING id INTO l_cus;
    INSERT INTO ar_customer_account (company_id, customer_id, account_no, currency_code, payment_term_id, receivable_account_id,
                                     default_tax_code_id, status_code)
    VALUES (company, l_cus, l_no, NOONA_GL_PKG.ledger_currency, p_term, NOONA_INV_PKG.acc_id('1103'), NOONA_INV_PKG.tax_id('VAT15'),
            NVL(p_status, 'ACTIVE'))
    RETURNING id INTO l_id;
    RETURN l_id;
  END create_account;

  FUNCTION party_account(p_party_id IN NUMBER) RETURN NUMBER IS
    l_id  NUMBER;
    l_term NUMBER;
    l_cus NUMBER;
    l_no  VARCHAR2(50);
  BEGIN
    SELECT MIN(a.id) INTO l_id FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
     WHERE a.company_id = company AND c.party_id = p_party_id AND c.is_walk_in = 'N';
    IF l_id IS NOT NULL THEN
      RETURN l_id;
    END IF;
    SELECT MIN(id) INTO l_cus FROM ar_customer WHERE party_id = p_party_id AND is_walk_in = 'N';
    IF l_cus IS NULL THEN
      RETURN create_account(p_party_id, 'N', term_id('NET30'), 'ACTIVE');
    END IF;
    SELECT customer_no INTO l_no FROM ar_customer WHERE id = l_cus;
    l_term := term_id('NET30');
    INSERT INTO ar_customer_account (company_id, customer_id, account_no, currency_code, payment_term_id, receivable_account_id,
                                     default_tax_code_id, status_code)
    VALUES (company, l_cus, l_no, NOONA_GL_PKG.ledger_currency, l_term, NOONA_INV_PKG.acc_id('1103'), NOONA_INV_PKG.tax_id('VAT15'), 'ACTIVE')
    RETURNING id INTO l_id;
    RETURN l_id;
  END party_account;

  FUNCTION walk_in_customer RETURN NUMBER IS
    l     NUMBER;
    l_pty NUMBER;
  BEGIN
    SELECT MIN(a.id) INTO l FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
     WHERE a.company_id = company AND c.is_walk_in = 'Y' AND a.status_code = 'ACTIVE';
    IF l IS NULL THEN
      l_pty := NOONA_PTY_PKG.create_party('PERSON', 'عميل نقدي عام', 'CUSTOMER', 'Walk-in customer');
      l := create_account(l_pty, 'Y', term_id('NET0'), 'ACTIVE');
    END IF;
    RETURN l;
  END walk_in_customer;

  FUNCTION save_customer(p_doc IN CLOB) RETURN NUMBER IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id     NUMBER := l_o.get_number('id');
    l_name   VARCHAR2(400) := TRIM(l_o.get_string('name'));
    l_name_en VARCHAR2(400) := l_o.get_string('nameEn');
    l_person VARCHAR2(1) := NVL(l_o.get_string('person'), 'Y');
    l_tax    VARCHAR2(50) := l_o.get_string('tax');
    l_cr     VARCHAR2(50) := l_o.get_string('cr');
    l_phone  VARCHAR2(50) := l_o.get_string('phone');
    l_email  VARCHAR2(200) := l_o.get_string('email');
    l_addr   VARCHAR2(500) := l_o.get_string('address');
    l_term   NUMBER := term_id(NVL(l_o.get_string('term'), 'NET30'));
    l_limit  NUMBER := l_o.get_number('limit');
    l_status VARCHAR2(30) := NVL(l_o.get_string('status'), 'ACTIVE');
    l_party  NUMBER;
    l_cus    NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-SAL-002', 'اسم العميل إلزامي', 'Customer name is required');
    IF l_id IS NULL THEN
      guard('AR_CUSTOMER.CREATE');
      l_party := NOONA_PTY_PKG.create_party(CASE WHEN l_person = 'Y' AND l_cr IS NULL THEN 'PERSON' ELSE 'ORGANIZATION' END, l_name,
                                            'CUSTOMER', l_name_en, l_tax, l_cr);
      l_id := create_account(l_party, 'N', l_term, l_status);
      SELECT customer_id INTO l_cus FROM ar_customer_account WHERE id = l_id;
    ELSE
      guard('AR_CUSTOMER.UPDATE');
      SELECT c.party_id, c.id INTO l_party, l_cus FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
       WHERE a.id = l_id AND a.company_id = company;
      UPDATE pty_party SET display_name_ar = l_name, display_name_en = l_name_en,
                           tax_number = NVL(REPLACE(TRIM(l_tax), ' '), tax_number) WHERE id = l_party;
      UPDATE ar_customer_account SET payment_term_id = l_term, status_code = l_status WHERE id = l_id;
    END IF;
    upsert_contact(l_party, l_phone, l_email, l_addr);
    set_limit(l_id, l_limit);
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'AR_CUSTOMER', l_cus, 'SAVE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SAL-001', 'العميل غير موجود في هذه الشركة', 'Customer not found');
  END save_customer;

  FUNCTION credit_limit(p_account_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(credit_limit) INTO l FROM ar_credit_limit
     WHERE customer_account_id = p_account_id AND company_id = company AND effective_from <= TRUNC(SYSDATE)
       AND (effective_to IS NULL OR effective_to >= TRUNC(SYSDATE));
    RETURN l;
  END credit_limit;

  -- الرصيد المدين للعميل (له علينا بالسالب): الذمم الأصلية - الإشعارات الدائنة - التحصيلات
  FUNCTION customer_balance(p_account_id IN NUMBER, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_items NUMBER; l_rcp NUMBER;
    l_to    DATE := NVL(p_as_of, DATE '9999-12-31');
  BEGIN
    SELECT NVL(SUM(CASE WHEN item_type = 'CREDIT_NOTE' THEN -original_amount ELSE original_amount END), 0) INTO l_items
      FROM ar_open_item WHERE customer_account_id = p_account_id AND company_id = company AND status_code <> 'CANCELLED' AND doc_date <= l_to;
    SELECT NVL(SUM(amount), 0) INTO l_rcp FROM ar_receipt
     WHERE customer_account_id = p_account_id AND company_id = company AND status_code = 'CONFIRMED' AND doc_date <= l_to;
    RETURN l_items - l_rcp;
  END customer_balance;

  PROCEDURE check_credit(p_account_id IN NUMBER, p_amount IN NUMBER) IS
    l_lim NUMBER;
    l_bal NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(is_walk_in(p_account_id) = 'N', 'NOONA-SAL-032', 'العميل النقدي العام لا يباع له آجلاً؛ اختر عميلاً مسجلاً',
                          'Walk-in customer cannot buy on credit');
    l_lim := credit_limit(p_account_id);
    IF l_lim IS NOT NULL THEN
      l_bal := customer_balance(p_account_id);
      NOONA_CORE_PKG.assert(l_bal + p_amount <= l_lim, 'NOONA-SAL-031',
        'تجاوز حد الائتمان: الرصيد ' || fmt0(l_bal) || ' + ' || fmt0(p_amount) || ' > الحد ' || fmt0(l_lim), 'Credit limit exceeded');
    END IF;
  END check_credit;

  FUNCTION customer_json(p_account_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    IF p_account_id IS NULL THEN
      RETURN '{"id":null,"person":"Y","term":"NET30","status":"ACTIVE"}';
    END IF;
    SELECT JSON_OBJECT('id' VALUE a.id, 'no' VALUE c.customer_no, 'name' VALUE p.display_name_ar, 'nameEn' VALUE p.display_name_en,
             'person' VALUE CASE WHEN p.party_type = 'PERSON' THEN 'Y' ELSE 'N' END, 'tax' VALUE p.tax_number,
             'cr' VALUE (SELECT cr_number FROM pty_organization WHERE party_id = p.id),
             'phone' VALUE (SELECT MAX(mobile) FROM ref_contact WHERE party_id = p.id AND is_primary = 'Y'),
             'email' VALUE (SELECT MAX(email) FROM ref_contact WHERE party_id = p.id AND is_primary = 'Y'),
             'address' VALUE (SELECT MAX(address_line_ar) FROM ref_address WHERE party_id = p.id AND address_type = 'BILLING'),
             'term' VALUE (SELECT code FROM ref_payment_term WHERE id = a.payment_term_id), 'status' VALUE a.status_code,
             'walkIn' VALUE c.is_walk_in, 'limit' VALUE credit_limit(a.id), 'balance' VALUE customer_balance(a.id), 'party' VALUE p.id)
      INTO l
      FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
     WHERE a.id = p_account_id AND a.company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SAL-001', 'العميل غير موجود في هذه الشركة', 'Customer not found');
  END customer_json;

  FUNCTION customers_json(p_term IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l   CLOB;
    l_t VARCHAR2(210) := '%' || UPPER(TRIM(p_term)) || '%';
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE a.id, 'n' VALUE c.customer_no || ' - ' || p.display_name_ar, 'tax' VALUE p.tax_number,
                                     'w' VALUE c.is_walk_in,
                                     'ph' VALUE (SELECT MAX(mobile) FROM ref_contact WHERE party_id = p.id AND is_primary = 'Y'))
                         ORDER BY c.is_walk_in DESC, p.display_name_ar RETURNING CLOB)
      INTO l
      FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
     WHERE a.company_id = company AND a.status_code = 'ACTIVE'
       AND (p_term IS NULL OR UPPER(p.display_name_ar) LIKE l_t OR UPPER(p.display_name_en) LIKE l_t OR c.customer_no LIKE l_t
            OR p.tax_number LIKE l_t
            OR EXISTS (SELECT 1 FROM ref_contact x WHERE x.party_id = p.id AND x.mobile LIKE l_t));
    RETURN NVL(l, '[]');
  END customers_json;

  -- ================================================================ التسعير والضريبة
  PROCEDURE price_line(p_item_id IN NUMBER, p_qty IN NUMBER, p_price IN OUT NUMBER, p_disc IN NUMBER, p_incl IN OUT VARCHAR2,
                       p_tax_code IN OUT NUMBER, p_date IN DATE, p_net OUT NUMBER, p_tax OUT NUMBER) IS
    l_sale NUMBER;
    l_min  NUMBER;
    l_inc  VARCHAR2(1);
    l_rate NUMBER;
    l_gross NUMBER;
    l_unit NUMBER;
  BEGIN
    IF p_item_id IS NOT NULL THEN
      SELECT MAX(sale_price), MAX(min_sale_price), MAX(prices_include_tax) INTO l_sale, l_min, l_inc
        FROM inv_item_company WHERE item_id = p_item_id AND company_id = company;
      IF p_price IS NULL THEN
        p_price := l_sale;
        p_incl := NVL(p_incl, NVL(l_inc, 'N'));
      END IF;
      p_tax_code := NVL(p_tax_code, NOONA_INV_PKG.item_tax_code(p_item_id, 'SALE'));
    END IF;
    p_incl := NVL(p_incl, 'N');
    p_tax_code := NVL(p_tax_code, NOONA_INV_PKG.tax_id('VAT15'));
    NOONA_CORE_PKG.assert(NVL(p_qty, 0) > 0, 'NOONA-SAL-012', 'الكمية يجب أن تكون موجبة', 'Quantity must be positive');
    NOONA_CORE_PKG.assert(p_price IS NOT NULL AND p_price >= 0, 'NOONA-SAL-013', 'لا يوجد سعر بيع للصنف ' || NOONA_INV_PKG.item_label(p_item_id),
                          'No sale price');
    l_gross := ROUND(p_qty * p_price, 2);
    NOONA_CORE_PKG.assert(NVL(p_disc, 0) >= 0 AND NVL(p_disc, 0) <= l_gross, 'NOONA-SAL-014', 'الخصم أكبر من قيمة البند',
                          'Discount exceeds line value');
    l_rate := NOONA_INV_PKG.tax_rate(p_tax_code, p_date);
    IF p_incl = 'Y' THEN
      p_net := ROUND((l_gross - NVL(p_disc, 0)) / (1 + l_rate / 100), 2);
      p_tax := ROUND(l_gross - NVL(p_disc, 0) - p_net, 2);
    ELSE
      p_net := ROUND(l_gross - NVL(p_disc, 0), 2);
      p_tax := ROUND(p_net * l_rate / 100, 2);
    END IF;
    -- الحد الأدنى للسعر بنفس أساس سعر الصنف
    IF l_min IS NOT NULL THEN
      l_unit := (l_gross - NVL(p_disc, 0)) / p_qty;
      IF NVL(l_inc, 'N') = 'Y' AND p_incl = 'N' THEN l_unit := l_unit * (1 + l_rate / 100);
      ELSIF NVL(l_inc, 'N') = 'N' AND p_incl = 'Y' THEN l_unit := l_unit / (1 + l_rate / 100);
      END IF;
      NOONA_CORE_PKG.assert(ROUND(l_unit, 2) >= l_min, 'NOONA-SAL-015',
        'سعر البيع بعد الخصم أقل من الحد الأدنى (' || fmt0(l_min) || ') للصنف ' || NOONA_INV_PKG.item_label(p_item_id), 'Below minimum price');
    END IF;
  END price_line;

  FUNCTION seller_vat RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT MAX(r.reg_number) KEEP (DENSE_RANK FIRST ORDER BY r.is_primary DESC NULLS LAST, r.id) INTO l
      FROM org_legal_registration r JOIN loc_registration_type t ON t.id = r.reg_type_id
     WHERE r.company_id = company AND t.is_tax_registration = 'Y' AND r.status_code IN ('ACTIVE', 'EXPIRING');
    RETURN l;
  END seller_vat;

  FUNCTION seller_name RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT NVL(trade_name_ar, legal_name_ar) INTO l FROM org_company WHERE id = company;
    RETURN l;
  END seller_name;

  FUNCTION zatca_qr(p_at IN TIMESTAMP, p_total IN NUMBER, p_vat IN NUMBER) RETURN VARCHAR2 IS
    l_raw RAW(2000);
    PROCEDURE tlv(p_tag PLS_INTEGER, p_val VARCHAR2) IS
      l_v RAW(1000) := UTL_I18N.STRING_TO_RAW(NVL(p_val, ' '), 'AL32UTF8');
    BEGIN
      l_raw := UTL_RAW.CONCAT(l_raw, UTL_RAW.CONCAT(HEXTORAW(LPAD(TRIM(TO_CHAR(p_tag, 'XX')), 2, '0')),
                                                    HEXTORAW(LPAD(TRIM(TO_CHAR(UTL_RAW.LENGTH(l_v), 'XX')), 2, '0')), l_v));
    END tlv;
  BEGIN
    tlv(1, seller_name);
    tlv(2, NVL(seller_vat, '000000000000000'));
    tlv(3, TO_CHAR(SYS_EXTRACT_UTC(CAST(p_at AS TIMESTAMP WITH TIME ZONE)), 'YYYY-MM-DD"T"HH24:MI:SS"Z"'));
    tlv(4, TO_CHAR(p_total, 'FM999999999990D00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
    tlv(5, TO_CHAR(p_vat, 'FM999999999990D00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
    RETURN REPLACE(REPLACE(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(l_raw)), CHR(13)), CHR(10));
  END zatca_qr;

  -- ================================================================ فاتورة المبيعات
  FUNCTION save_invoice(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id    NUMBER := l_o.get_number('id');
    l_cust  NUMBER := NVL(l_o.get_number('cust'), walk_in_customer);
    l_date  DATE := NVL(d(l_o.get_string('date')), TRUNC(SYSDATE));
    l_wh    NUMBER := NVL(l_o.get_number('wh'), NOONA_INV_PKG.default_warehouse);
    l_mode  VARCHAR2(30) := NVL(l_o.get_string('mode'), 'CREDIT');
    l_place VARCHAR2(30) := l_o.get_string('place');
    l_cc    NUMBER := l_o.get_number('cc');
    l_name  VARCHAR2(400) := TRIM(l_o.get_string('name'));
    l_taxno VARCHAR2(50) := TRIM(l_o.get_string('taxNo'));
    l_rx    VARCHAR2(50) := TRIM(l_o.get_string('rx'));
    l_act   VARCHAR2(30) := NVL(l_o.get_string('action'), 'SAVE');
    l_acc   ar_customer_account%ROWTYPE;
    l_st    VARCHAR2(30);
    l_no    PLS_INTEGER := 0;
    l_sub   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_dis   NUMBER := 0;
    l_net   NUMBER;
    l_tx    NUMBER;
    l_tc    NUMBER;
    l_p     NUMBER;
    l_inc   VARCHAR2(1);
    l_uom   NUMBER;
    l_desc  VARCHAR2(1000);
    l_type  VARCHAR2(30);
    l_rev   NUMBER;
    l_party NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'SAL_INVOICE.CREATE' ELSE 'SAL_INVOICE.UPDATE' END);
    l_acc := get_account(l_cust);
    NOONA_CORE_PKG.assert(l_acc.status_code = 'ACTIVE', 'NOONA-SAL-003', 'العميل غير نشط أو موقوف', 'Customer is not active');
    IF is_walk_in(l_cust) = 'Y' THEN l_mode := 'CASH'; END IF;
    NOONA_CORE_PKG.assert(l_mode IN ('CREDIT', 'CASH'), 'NOONA-SAL-020', 'طريقة الفاتورة: آجل أو نقدي', 'Mode must be CREDIT or CASH');
    NOONA_CORE_PKG.assert(l_mode = 'CREDIT' OR l_place IS NOT NULL, 'NOONA-SAL-021', 'اختر الصندوق أو البنك للفاتورة النقدية',
                          'Choose the cash box or bank for a cash invoice');
    l_party := customer_party(l_cust);
    IF l_name IS NULL THEN
      SELECT display_name_ar, NVL(l_taxno, tax_number) INTO l_name, l_taxno FROM pty_party WHERE id = l_party;
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO sal_invoice (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, doc_type, customer_account_id,
                               payment_term_id, supply_date, customer_name_snapshot, customer_tax_no_snapshot, einvoice_status,
                               warehouse_id, payment_mode, settle_place, cost_center_id, prescription_no, status_code)
      VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'DRAFT-' || RAWTOHEX(SYS_GUID()), l_date,
              NOONA_GL_PKG.ledger_currency, 1, CASE WHEN l_taxno IS NOT NULL THEN 'INVOICE' ELSE 'SIMPLIFIED_INVOICE' END, l_cust,
              l_acc.payment_term_id, l_date, l_name, l_taxno, 'NOT_REQUIRED', l_wh, l_mode, CASE WHEN l_mode = 'CASH' THEN l_place END,
              l_cc, l_rx, 'DRAFT')
      RETURNING id INTO l_id;
      UPDATE sal_invoice SET doc_no = 'مسودة-' || l_id WHERE id = l_id;
    ELSE
      SELECT status_code INTO l_st FROM sal_invoice WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-SAL-022', 'لا تعدل فاتورة مرحلة؛ استخدم المرتجع', 'Only draft invoices can be edited');
      UPDATE sal_invoice SET customer_account_id = l_cust, doc_date = l_date, supply_date = l_date, customer_name_snapshot = l_name,
                             customer_tax_no_snapshot = l_taxno, doc_type = CASE WHEN l_taxno IS NOT NULL THEN 'INVOICE' ELSE 'SIMPLIFIED_INVOICE' END,
                             warehouse_id = l_wh, payment_mode = l_mode, settle_place = CASE WHEN l_mode = 'CASH' THEN l_place END,
                             cost_center_id = l_cc, prescription_no = l_rx, payment_term_id = l_acc.payment_term_id
       WHERE id = l_id;
      DELETE FROM sal_invoice_line WHERE invoice_id = l_id;
    END IF;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', ds VARCHAR2(1000) PATH '$.d',
                q NUMBER PATH '$.q', p NUMBER PATH '$.p', inc VARCHAR2(1) PATH '$.inc', disc NUMBER PATH '$.disc',
                tc VARCHAR2(30) PATH '$.tc', acc VARCHAR2(30) PATH '$.acc', cc NUMBER PATH '$.cc'))) LOOP
      CONTINUE WHEN r.i IS NULL AND TRIM(r.ds) IS NULL;
      l_p := r.p; l_inc := r.inc; l_tc := CASE WHEN r.tc IS NOT NULL THEN NOONA_INV_PKG.tax_id(r.tc) END;
      price_line(r.i, r.q, l_p, r.disc, l_inc, l_tc, l_date, l_net, l_tx);
      IF r.i IS NOT NULL THEN
        SELECT base_uom_id, name_ar, CASE WHEN item_type IN ('SERVICE', 'NON_STOCK') THEN 'SERVICE' ELSE 'ITEM' END
          INTO l_uom, l_desc, l_type FROM inv_item WHERE id = r.i;
        l_rev := NOONA_INV_PKG.account_for(r.i, 'REVENUE');
      ELSE
        l_uom := NULL; l_desc := NULL; l_type := 'CHARGE';
        l_rev := NOONA_INV_PKG.acc_id(NVL(r.acc, '4201'));
        NOONA_CORE_PKG.assert(l_rev IS NOT NULL, 'NOONA-SAL-024', 'حساب الإيراد غير موجود: ' || r.acc, 'Revenue account not found');
      END IF;
      l_no := l_no + 1;
      INSERT INTO sal_invoice_line (company_id, invoice_id, line_no, line_type, item_id, description, quantity, uom_id, unit_price,
                                    discount_amount, net_amount, tax_code_id, tax_amount, revenue_account_id, cost_center_id)
      VALUES (company, l_id, l_no, l_type, r.i, NVL(TRIM(r.ds), l_desc), r.q, l_uom,
              CASE WHEN l_inc = 'Y' THEN ROUND((l_net + NVL(r.disc, 0) * l_net / NULLIF(l_net + l_tx, 0)) / r.q, 6) ELSE l_p END,
              CASE WHEN l_inc = 'Y' THEN ROUND(NVL(r.disc, 0) * l_net / NULLIF(l_net + l_tx, 0), 2) ELSE NVL(r.disc, 0) END,
              l_net, l_tc, l_tx, l_rev, NVL(r.cc, l_cc));
      l_sub := l_sub + l_net;
      l_tax := l_tax + l_tx;
      l_dis := l_dis + NVL(r.disc, 0);
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-SAL-016', 'أضف بنداً واحداً على الأقل', 'Add at least one line');
    UPDATE sal_invoice SET subtotal = l_sub, discount_amount = l_dis, tax_amount = l_tax, total_amount = l_sub + l_tax, total_func = l_sub + l_tax
     WHERE id = l_id;
    IF l_act = 'POST' THEN
      post_invoice(l_id);
    END IF;
    RETURN l_id;
  END save_invoice;

  FUNCTION invoice_json(p_invoice_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    IF p_invoice_id IS NULL THEN
      RETURN '{"id":null,"status":"DRAFT","mode":"CASH","cust":' || walk_in_customer || ',"custName":'
          || NOONA_CORE_PKG.json_text(customer_label(walk_in_customer)) || ',"date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":'
          || NVL(TO_CHAR(NOONA_INV_PKG.default_warehouse), 'null') || ',"lines":[]}';
    END IF;
    SELECT JSON_OBJECT('id' VALUE i.id, 'no' VALUE i.doc_no, 'status' VALUE i.status_code, 'type' VALUE i.doc_type,
             'cust' VALUE i.customer_account_id, 'custName' VALUE customer_label(i.customer_account_id), 'name' VALUE i.customer_name_snapshot,
             'taxNo' VALUE i.customer_tax_no_snapshot, 'date' VALUE TO_CHAR(i.doc_date, 'YYYY-MM-DD'), 'wh' VALUE i.warehouse_id,
             'mode' VALUE i.payment_mode, 'place' VALUE i.settle_place, 'cc' VALUE i.cost_center_id, 'rx' VALUE i.prescription_no,
             'orig' VALUE i.original_invoice_id, 'subtotal' VALUE i.subtotal, 'disc' VALUE i.discount_amount, 'tax' VALUE i.tax_amount,
             'total' VALUE i.total_amount, 'cogs' VALUE i.cogs_amount,
             'open' VALUE (SELECT SUM(open_amount) FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = i.id),
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE l.id, 'i' VALUE l.item_id, 'd' VALUE l.description, 'q' VALUE l.quantity,
                                    'p' VALUE l.unit_price, 'disc' VALUE l.discount_amount, 'net' VALUE l.net_amount, 'tx' VALUE l.tax_amount,
                                    'tc' VALUE (SELECT code FROM loc_tax_code WHERE id = l.tax_code_id), 'cost' VALUE l.unit_cost,
                                    'n' VALUE (SELECT item_no || ' - ' || name_ar FROM inv_item WHERE id = l.item_id))
                                    ORDER BY l.line_no RETURNING CLOB)
                              FROM sal_invoice_line l WHERE l.invoice_id = i.id) FORMAT JSON
             RETURNING CLOB)
      INTO l FROM sal_invoice i WHERE i.id = p_invoice_id AND i.company_id = company;
    RETURN REPLACE(l, '"lines":null', '"lines":[]');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SAL-025', 'فاتورة المبيعات غير موجودة', 'Sales invoice not found');
  END invoice_json;

  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_cc NUMBER,
                     p_party NUMBER, p_desc VARCHAR2) IS
  BEGIN
    IF NVL(p_dr, 0) = 0 AND NVL(p_cr, 0) = 0 THEN RETURN; END IF;
    FOR i IN 1 .. p_lines.COUNT LOOP
      IF p_lines(i).account_id = p_acc AND NVL(p_lines(i).cost_center_id, 0) = NVL(p_cc, 0) AND NVL(p_lines(i).party_id, 0) = NVL(p_party, 0)
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
    p_lines(p_lines.COUNT).cost_center_id := p_cc;
    p_lines(p_lines.COUNT).party_id := p_party;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
  END add_line;

  FUNCTION cc_for(p_acc NUMBER, p_cc NUMBER, p_wh NUMBER) RETURN NUMBER IS
    l_rule VARCHAR2(30) := NOONA_GL_PKG.cc_rule(p_acc);
    l_cc   NUMBER := p_cc;
  BEGIN
    IF l_rule = 'FORBIDDEN' THEN RETURN NULL; END IF;
    IF l_cc IS NULL AND l_rule = 'REQUIRED' AND p_wh IS NOT NULL THEN
      SELECT MAX(cost_center_id) INTO l_cc FROM inv_warehouse WHERE id = p_wh;
    END IF;
    RETURN l_cc;
  END cc_for;

  PROCEDURE post_invoice(p_invoice_id IN NUMBER) IS
    l_i     sal_invoice%ROWTYPE;
    l_acc   ar_customer_account%ROWTYPE;
    l_party NUMBER;
    l_moves NOONA_INV_PKG.t_moves := NOONA_INV_PKG.t_moves();
    l_txn   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_due   NUMBER;
    l_n     NUMBER;
    l_x     NUMBER;
    l_cogs  NUMBER := 0;
    l_desc  VARCHAR2(1000);
  BEGIN
    guard('SAL_INVOICE.POST');
    SELECT * INTO l_i FROM sal_invoice WHERE id = p_invoice_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_i.status_code = 'DRAFT', 'NOONA-SAL-022', 'الفاتورة مرحلة أو ملغاة', 'Invoice is not a draft');
    l_acc := get_account(l_i.customer_account_id);
    l_party := customer_party(l_acc.id);
    -- الأدوية الوصفية تتطلب رقم الوصفة
    SELECT COUNT(*) INTO l_n FROM sal_invoice_line l JOIN inv_item i ON i.id = l.item_id
     WHERE l.invoice_id = p_invoice_id AND i.requires_prescription = 'Y';
    NOONA_CORE_PKG.assert(l_n = 0 OR l_i.prescription_no IS NOT NULL, 'NOONA-SAL-030',
                          'الفاتورة تحتوي دواءً لا يصرف إلا بوصفة طبية؛ أدخل رقم الوصفة', 'Prescription number is required');
    IF l_i.payment_mode = 'CREDIT' THEN
      check_credit(l_acc.id, l_i.total_amount);
    END IF;
    UPDATE sal_invoice SET doc_no = NOONA_REFERENCE_PKG.next_doc_no('SAL_INVOICE', company, branch_id, doc_date, c_inv, id),
                           issued_at = SYSTIMESTAMP
     WHERE id = p_invoice_id
    RETURNING doc_no INTO l_i.doc_no;
    l_desc := 'فاتورة مبيعات ' || l_i.doc_no || ' - ' || l_i.customer_name_snapshot;
    -- صرف المخزون (الدفعات السارية بالأقدم انتهاءً)
    FOR r IN (SELECT l.* FROM sal_invoice_line l WHERE l.invoice_id = p_invoice_id AND l.line_type = 'ITEM' ORDER BY l.line_no) LOOP
      l_moves.EXTEND;
      l_moves(l_moves.COUNT).item_id := r.item_id;
      l_moves(l_moves.COUNT).qty := r.quantity;
      l_moves(l_moves.COUNT).line_ref := TO_CHAR(r.id);
    END LOOP;
    IF l_moves.COUNT > 0 THEN
      NOONA_CORE_PKG.assert(l_i.warehouse_id IS NOT NULL, 'NOONA-SAL-027', 'اختر مستودع الصرف', 'Warehouse is required');
      l_txn := NOONA_INV_PKG.move('SALES_ISSUE', l_i.warehouse_id, l_i.doc_date, c_inv, p_invoice_id, l_moves, l_i.doc_no);
      FOR k IN 1 .. l_moves.COUNT LOOP
        UPDATE sal_invoice_line SET unit_cost = ROUND(l_moves(k).total_cost / l_moves(k).qty, 6) WHERE id = TO_NUMBER(l_moves(k).line_ref);
        l_cogs := l_cogs + l_moves(k).total_cost;
        IF l_moves(k).total_cost > 0 THEN
          l_x := NOONA_INV_PKG.account_for(l_moves(k).item_id, 'COGS');
          add_line(l_lines, l_x, l_moves(k).total_cost, 0, cc_for(l_x, l_i.cost_center_id, l_i.warehouse_id), NULL, 'تكلفة ' || l_desc);
          l_x := NOONA_INV_PKG.account_for(l_moves(k).item_id, 'INVENTORY');
          add_line(l_lines, l_x, 0, l_moves(k).total_cost, cc_for(l_x, NULL, l_i.warehouse_id), NULL, 'تكلفة ' || l_desc);
        END IF;
      END LOOP;
    END IF;
    -- الإيراد والضريبة
    FOR r IN (SELECT l.* FROM sal_invoice_line l WHERE l.invoice_id = p_invoice_id ORDER BY l.line_no) LOOP
      add_line(l_lines, r.revenue_account_id, 0, r.net_amount, cc_for(r.revenue_account_id, r.cost_center_id, l_i.warehouse_id), NULL, l_desc);
      IF NVL(r.tax_amount, 0) > 0 THEN
        add_line(l_lines, NOONA_INV_PKG.tax_account(r.tax_code_id, 'SALE'), 0, r.tax_amount, NULL, NULL, 'ضريبة مخرجات ' || l_i.doc_no);
      END IF;
    END LOOP;
    l_x := CASE WHEN l_i.payment_mode = 'CASH' THEN NOONA_CSH_PKG.place_account(l_i.settle_place) ELSE receivable_account(l_acc) END;
    add_line(l_lines, l_x, l_i.total_amount, 0, NULL, CASE WHEN l_i.payment_mode = 'CREDIT' THEN l_party END, l_desc);
    l_j := NOONA_ACE_PKG.post_source('SAL_INVOICE_POSTED', 'SALES', c_inv, p_invoice_id, l_i.doc_date, l_desc, l_i.currency_code, 1,
                                     l_lines, l_i.doc_no, l_i.branch_id, 'SALES_INVOICE');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    IF l_i.payment_mode = 'CREDIT' THEN
      SELECT NVL(MAX(due_days), 0) INTO l_due FROM ref_payment_term WHERE id = l_i.payment_term_id;
      INSERT INTO ar_open_item (company_id, branch_id, source_entity_type, source_entity_id, currency_code, exchange_rate, customer_account_id,
                                item_type, doc_no, doc_date, due_date, installment_no, original_amount, open_amount, original_func, open_func,
                                tax_amount, gl_journal_id, status_code)
      VALUES (company, l_i.branch_id, c_inv, p_invoice_id, l_i.currency_code, 1, l_acc.id, 'INVOICE', l_i.doc_no, l_i.doc_date,
              l_i.doc_date + l_due, 1, l_i.total_amount, l_i.total_amount, l_i.total_amount, l_i.total_amount, l_i.tax_amount, l_j, 'OPEN');
    ELSE
      l_x := NOONA_CSH_PKG.record_settlement('RECEIPT', l_i.settle_place, l_i.doc_date, l_i.total_amount, l_party,
                                             l_i.customer_name_snapshot, c_inv, p_invoice_id, l_i.doc_no, l_desc, l_ev);
    END IF;
    UPDATE sal_invoice SET status_code = CASE WHEN payment_mode = 'CASH' THEN 'PAID' ELSE 'POSTED' END, inv_transaction_id = l_txn,
                           due_date = CASE WHEN payment_mode = 'CREDIT' THEN doc_date + NVL(l_due, 0) ELSE doc_date END,
                           cogs_amount = l_cogs, accounting_event_id = l_ev, posted_at = SYSTIMESTAMP,
                           posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = p_invoice_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_inv, p_invoice_id, 'POST', 'SUCCESS');
    NOONA_EINV_PKG.on_invoice_posted(p_invoice_id);
    NOONA_API_PKG.publish('SAL_INVOICE.POSTED', c_inv, p_invoice_id);
  END post_invoice;

  PROCEDURE cancel_invoice(p_invoice_id IN NUMBER) IS
  BEGIN
    guard('SAL_INVOICE.CANCEL');
    UPDATE sal_invoice SET status_code = 'CANCELLED' WHERE id = p_invoice_id AND company_id = company AND status_code = 'DRAFT';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-SAL-022', 'تلغى الفاتورة المسودة فقط؛ المرحلة تعالج بالمرتجع', 'Only drafts can be cancelled');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_inv, p_invoice_id, 'CANCEL', 'SUCCESS');
  END cancel_invoice;

  -- ================================================================ المرتجع
  FUNCTION return_doc_json(p_invoice_id IN NUMBER) RETURN CLOB IS
    l_no VARCHAR2(100);
  BEGIN
    SELECT doc_no INTO l_no FROM sal_invoice WHERE id = p_invoice_id AND company_id = company;
    RETURN '{"inv":' || p_invoice_id || ',"no":' || NOONA_CORE_PKG.json_text(l_no) || ',"date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD')
        || '","lines":' || returnable_json(p_invoice_id) || '}';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '{"lines":[]}';
  END return_doc_json;

  FUNCTION returnable_json(p_invoice_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('l' VALUE l.id, 'i' VALUE l.item_id, 'd' VALUE l.description, 'q' VALUE l.quantity,
             'r' VALUE NVL((SELECT SUM(x.quantity) FROM sal_invoice_line x JOIN sal_invoice h ON h.id = x.invoice_id
                             WHERE h.original_invoice_id = l.invoice_id AND h.status_code <> 'CANCELLED' AND x.original_line_id = l.id), 0),
             'p' VALUE ROUND((l.net_amount + NVL(l.tax_amount, 0)) / l.quantity, 6)) ORDER BY l.line_no RETURNING CLOB)
      INTO l FROM sal_invoice_line l WHERE l.invoice_id = p_invoice_id;
    RETURN NVL(l, '[]');
  END returnable_json;

  FUNCTION settle_open(p_source_type IN VARCHAR2, p_source_id IN NUMBER, p_amount IN NUMBER) RETURN NUMBER IS
    l_left NUMBER := p_amount;
    l_x    NUMBER;
  BEGIN
    FOR oi IN (SELECT id, open_amount FROM ar_open_item
                WHERE source_entity_type = p_source_type AND source_entity_id = p_source_id AND item_type = 'INVOICE' AND open_amount > 0
                FOR UPDATE) LOOP
      EXIT WHEN l_left <= 0;
      l_x := LEAST(oi.open_amount, l_left);
      UPDATE ar_open_item SET open_amount = open_amount - l_x, open_func = open_func - l_x,
                              status_code = CASE WHEN open_amount - l_x = 0 THEN 'PAID' ELSE 'PARTIALLY_PAID' END
       WHERE id = oi.id;
      l_left := l_left - l_x;
    END LOOP;
    RETURN l_left;
  END settle_open;

  FUNCTION post_return(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_orig  NUMBER := l_o.get_number('inv');
    l_date  DATE := NVL(d(l_o.get_string('date')), TRUNC(SYSDATE));
    l_rsn   VARCHAR2(400) := l_o.get_string('reason');
    l_place VARCHAR2(30) := l_o.get_string('place');
    l_i     sal_invoice%ROWTYPE;
    l_acc   ar_customer_account%ROWTYPE;
    l_party NUMBER;
    l_id    NUMBER;
    l_no    PLS_INTEGER := 0;
    l_sub   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_net   NUMBER;
    l_tx    NUMBER;
    l_done  NUMBER;
    l_line  sal_invoice_line%ROWTYPE;
    l_moves NOONA_INV_PKG.t_moves := NOONA_INV_PKG.t_moves();
    l_txn   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_x     NUMBER;
    l_cogs  NUMBER := 0;
    l_desc  VARCHAR2(1000);
    l_dno   VARCHAR2(100);
    l_left  NUMBER;
    l_lot   NUMBER;
    l_ret   NUMBER := NOONA_INV_PKG.acc_id('4102');
  BEGIN
    guard('SAL_INVOICE.CREATE');
    guard('SAL_INVOICE.POST');
    SELECT * INTO l_i FROM sal_invoice WHERE id = l_orig AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_i.doc_type IN ('INVOICE', 'SIMPLIFIED_INVOICE') AND l_i.status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID', 'CREDITED'),
                          'NOONA-SAL-040', 'المرتجع من فاتورة مبيعات مرحلة فقط', 'Return requires a posted sales invoice');
    NOONA_CORE_PKG.assert(TRIM(l_rsn) IS NOT NULL, 'NOONA-SAL-041', 'سبب المرتجع إلزامي', 'Return reason is required');
    IF l_i.payment_mode = 'CASH' THEN l_place := NVL(l_place, l_i.settle_place); END IF;
    l_acc := get_account(l_i.customer_account_id);
    l_party := customer_party(l_acc.id);
    l_dno := NOONA_REFERENCE_PKG.next_doc_no('SAL_CREDIT_NOTE', company, l_i.branch_id, l_date, c_inv, NULL);
    INSERT INTO sal_invoice (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, doc_type, customer_account_id,
                             original_invoice_id, supply_date, customer_name_snapshot, customer_tax_no_snapshot, einvoice_status, issued_at,
                             warehouse_id, payment_mode, settle_place, cost_center_id, status_code)
    VALUES (company, l_i.branch_id, l_dno, l_date, l_i.currency_code, 1, 'CREDIT_NOTE', l_acc.id, l_orig, l_date, l_i.customer_name_snapshot,
            l_i.customer_tax_no_snapshot, 'NOT_REQUIRED', SYSTIMESTAMP, l_i.warehouse_id, l_i.payment_mode, l_place, l_i.cost_center_id, 'DRAFT')
    RETURNING id INTO l_id;
    l_desc := 'مرتجع مبيعات ' || l_dno || ' من الفاتورة ' || l_i.doc_no || ' - ' || l_i.customer_name_snapshot || ': ' || l_rsn;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (ln NUMBER PATH '$.l', q NUMBER PATH '$.q'))) LOOP
      CONTINUE WHEN NVL(r.q, 0) = 0;
      BEGIN
        SELECT * INTO l_line FROM sal_invoice_line WHERE id = r.ln AND invoice_id = l_orig;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-SAL-042', 'البند ليس من الفاتورة الأصلية', 'Line is not on the original invoice');
      END;
      SELECT NVL(SUM(x.quantity), 0) INTO l_done FROM sal_invoice_line x JOIN sal_invoice h ON h.id = x.invoice_id
       WHERE h.original_invoice_id = l_orig AND h.status_code <> 'CANCELLED' AND x.original_line_id = l_line.id;
      NOONA_CORE_PKG.assert(r.q > 0 AND r.q <= l_line.quantity - l_done, 'NOONA-SAL-043',
        'كمية المرتجع أكبر من المتبقي (' || fqty(l_line.quantity - l_done) || ') للبند ' || l_line.description, 'Return quantity exceeds remaining');
      l_net := ROUND(l_line.net_amount * r.q / l_line.quantity, 2);
      l_tx := ROUND(NVL(l_line.tax_amount, 0) * r.q / l_line.quantity, 2);
      l_no := l_no + 1;
      INSERT INTO sal_invoice_line (company_id, invoice_id, line_no, line_type, item_id, description, quantity, uom_id, unit_price,
                                    discount_amount, net_amount, tax_code_id, tax_amount, original_line_id, revenue_account_id, cost_center_id,
                                    unit_cost)
      VALUES (company, l_id, l_no, l_line.line_type, l_line.item_id, l_line.description, r.q, l_line.uom_id, l_line.unit_price,
              ROUND(NVL(l_line.discount_amount, 0) * r.q / l_line.quantity, 2), l_net, l_line.tax_code_id, l_tx, l_line.id,
              l_line.revenue_account_id, l_line.cost_center_id, l_line.unit_cost);
      l_sub := l_sub + l_net;
      l_tax := l_tax + l_tx;
      add_line(l_lines, NVL(l_ret, l_line.revenue_account_id), l_net, 0,
               cc_for(NVL(l_ret, l_line.revenue_account_id), l_line.cost_center_id, l_i.warehouse_id), NULL, l_desc);
      IF l_tx > 0 THEN
        add_line(l_lines, NOONA_INV_PKG.tax_account(l_line.tax_code_id, 'SALE'), l_tx, 0, NULL, NULL, 'عكس ضريبة مخرجات');
      END IF;
      IF l_line.line_type = 'ITEM' THEN
        SELECT MIN(lot_id) INTO l_lot FROM inv_transaction_line
         WHERE transaction_id = l_i.inv_transaction_id AND source_line_ref = TO_CHAR(l_line.id);
        l_moves.EXTEND;
        l_moves(l_moves.COUNT).item_id := l_line.item_id;
        l_moves(l_moves.COUNT).qty := r.q;
        l_moves(l_moves.COUNT).unit_cost := NVL(l_line.unit_cost, 0);
        l_moves(l_moves.COUNT).lot_id := l_lot;
        l_moves(l_moves.COUNT).line_ref := TO_CHAR(l_line.id);
      END IF;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-SAL-044', 'حدد كمية مرتجعة لبند واحد على الأقل', 'Return at least one line');
    -- إعادة البضاعة للمخزون بتكلفتها الأصلية
    IF l_moves.COUNT > 0 THEN
      l_txn := NOONA_INV_PKG.move('SALES_RETURN', l_i.warehouse_id, l_date, c_inv, l_id, l_moves, l_rsn);
      FOR k IN 1 .. l_moves.COUNT LOOP
        IF l_moves(k).total_cost > 0 THEN
          l_cogs := l_cogs + l_moves(k).total_cost;
          l_x := NOONA_INV_PKG.account_for(l_moves(k).item_id, 'INVENTORY');
          add_line(l_lines, l_x, l_moves(k).total_cost, 0, cc_for(l_x, NULL, l_i.warehouse_id), NULL, l_desc);
          l_x := NOONA_INV_PKG.account_for(l_moves(k).item_id, 'COGS');
          add_line(l_lines, l_x, 0, l_moves(k).total_cost, cc_for(l_x, l_i.cost_center_id, l_i.warehouse_id), NULL, l_desc);
        END IF;
      END LOOP;
    END IF;
    l_x := CASE WHEN l_i.payment_mode = 'CASH' THEN NOONA_CSH_PKG.place_account(l_place) ELSE receivable_account(l_acc) END;
    add_line(l_lines, l_x, 0, l_sub + l_tax, NULL, CASE WHEN l_i.payment_mode = 'CREDIT' THEN l_party END, l_desc);
    UPDATE sal_invoice SET subtotal = l_sub, tax_amount = l_tax, total_amount = l_sub + l_tax, total_func = l_sub + l_tax, cogs_amount = l_cogs
     WHERE id = l_id;
    l_j := NOONA_ACE_PKG.post_source('SAL_CREDIT_NOTE_POSTED', 'SALES', c_inv, l_id, l_date, l_desc, l_i.currency_code, 1, l_lines, l_dno,
                                     l_i.branch_id, 'SALES_RETURN');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    IF l_i.payment_mode = 'CREDIT' THEN
      l_left := settle_open(c_inv, l_orig, l_sub + l_tax);
      INSERT INTO ar_open_item (company_id, branch_id, source_entity_type, source_entity_id, currency_code, exchange_rate, customer_account_id,
                                item_type, doc_no, doc_date, due_date, installment_no, original_amount, open_amount, original_func, open_func,
                                tax_amount, gl_journal_id, status_code)
      VALUES (company, l_i.branch_id, c_inv, l_id, l_i.currency_code, 1, l_acc.id, 'CREDIT_NOTE', l_dno, l_date, l_date, 1, l_sub + l_tax,
              l_left, l_sub + l_tax, l_left, l_tax, l_j, CASE WHEN l_left = 0 THEN 'PAID' ELSE 'OPEN' END);
      SELECT NVL(SUM(open_amount), 0) INTO l_x FROM ar_open_item WHERE source_entity_type = c_inv AND source_entity_id = l_orig;
      UPDATE sal_invoice SET status_code = CASE WHEN l_x = 0 THEN 'PAID' ELSE status_code END WHERE id = l_orig;
    ELSE
      l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', l_place, l_date, l_sub + l_tax, l_party, l_i.customer_name_snapshot, c_inv, l_id,
                                             l_dno, 'رد نقدي لمرتجع مبيعات', l_ev);
    END IF;
    UPDATE sal_invoice SET status_code = 'POSTED', inv_transaction_id = l_txn, accounting_event_id = l_ev, posted_at = SYSTIMESTAMP,
                           posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = l_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_inv, l_id, 'RETURN', 'SUCCESS');
    NOONA_EINV_PKG.on_invoice_posted(l_id);
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SAL-025', 'فاتورة المبيعات غير موجودة', 'Sales invoice not found');
  END post_return;

  -- ================================================================ التحصيل
  FUNCTION open_items_json(p_account_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE o.id, 'src' VALUE o.source_entity_type, 'inv' VALUE o.source_entity_id, 'no' VALUE o.doc_no,
             'date' VALUE TO_CHAR(o.doc_date, 'YYYY-MM-DD'), 'due' VALUE TO_CHAR(o.due_date, 'YYYY-MM-DD'), 'amt' VALUE o.original_amount,
             'open' VALUE o.open_amount, 'late' VALUE GREATEST(TRUNC(SYSDATE) - o.due_date, 0)) ORDER BY o.due_date, o.id RETURNING CLOB)
      INTO l FROM ar_open_item o
     WHERE o.customer_account_id = p_account_id AND o.company_id = company AND o.item_type = 'INVOICE' AND o.open_amount > 0;
    RETURN NVL(l, '[]');
  END open_items_json;

  FUNCTION receive(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_cust  NUMBER := l_o.get_number('cust');
    l_date  DATE := NVL(d(l_o.get_string('date')), TRUNC(SYSDATE));
    l_amt   NUMBER := ROUND(l_o.get_number('amount'), 2);
    l_place VARCHAR2(30) := l_o.get_string('place');
    l_meth  VARCHAR2(30) := NVL(l_o.get_string('method'), CASE WHEN l_o.get_string('place') LIKE 'BANK:%' THEN 'BANK_APP' ELSE 'CASH' END);
    l_ref   VARCHAR2(200) := l_o.get_string('ref');
    l_notes VARCHAR2(1000) := l_o.get_string('notes');
    l_acc   ar_customer_account%ROWTYPE;
    l_party NUMBER;
    l_id    NUMBER;
    l_no    VARCHAR2(100);
    l_left  NUMBER;
    l_x     NUMBER;
    l_open  NUMBER;
    l_mid   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_desc  VARCHAR2(1000);
    l_has   BOOLEAN := FALSE;
    PROCEDURE apply(p_item NUMBER, p_amt NUMBER) IS
      l_src VARCHAR2(30); l_sid NUMBER; l_rem NUMBER;
    BEGIN
      UPDATE ar_open_item SET open_amount = open_amount - p_amt, open_func = open_func - p_amt,
                              status_code = CASE WHEN open_amount - p_amt = 0 THEN 'PAID' ELSE 'PARTIALLY_PAID' END
       WHERE id = p_item
      RETURNING source_entity_type, source_entity_id INTO l_src, l_sid;
      INSERT INTO ar_receipt_application (company_id, receipt_id, open_item_id, applied_amount, discount_amount, applied_date, status_code)
      VALUES (company, l_id, p_item, p_amt, 0, l_date, 'APPLIED');
      IF l_src = c_inv THEN
        SELECT NVL(SUM(open_amount), 0) INTO l_rem FROM ar_open_item WHERE source_entity_type = c_inv AND source_entity_id = l_sid;
        UPDATE sal_invoice SET status_code = CASE WHEN l_rem = 0 THEN 'PAID' ELSE 'PARTIALLY_PAID' END WHERE id = l_sid;
      END IF;
      l_left := l_left - p_amt;
    END apply;
  BEGIN
    guard('AR_RECEIPT.CREATE');
    NOONA_CORE_PKG.assert(l_cust IS NOT NULL, 'NOONA-SAL-050', 'اختر العميل', 'Customer is required');
    NOONA_CORE_PKG.assert(NVL(l_amt, 0) > 0, 'NOONA-SAL-051', 'مبلغ التحصيل يجب أن يكون موجباً', 'Amount must be positive');
    NOONA_CORE_PKG.assert(l_place IS NOT NULL, 'NOONA-SAL-052', 'اختر الصندوق أو البنك المستلم', 'Choose the cash box or bank');
    l_acc := get_account(l_cust);
    l_party := customer_party(l_acc.id);
    l_x := NOONA_CSH_PKG.place_account(l_place);
    l_mid := method_id(l_meth);
    l_no := NOONA_REFERENCE_PKG.next_doc_no('AR_RECEIPT', company, NULL, l_date, c_rcp, NULL);
    INSERT INTO ar_receipt (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, customer_account_id, payment_method_id,
                            cash_box_id, bank_account_id, amount, amount_func, unapplied_amount, external_reference, status_code)
    VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), l_no, l_date, NOONA_GL_PKG.ledger_currency, 1, l_acc.id, l_mid,
            CASE WHEN l_place LIKE 'BOX:%' THEN TO_NUMBER(SUBSTR(l_place, 5)) END,
            CASE WHEN l_place LIKE 'BANK:%' THEN TO_NUMBER(SUBSTR(l_place, 6)) END, l_amt, l_amt, 0, l_ref, 'DRAFT')
    RETURNING id INTO l_id;
    l_left := l_amt;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.alloc[*]' COLUMNS (inv NUMBER PATH '$.inv', a NUMBER PATH '$.a'))) LOOP
      CONTINUE WHEN NVL(r.a, 0) <= 0;
      l_has := TRUE;
      SELECT MIN(id), NVL(SUM(open_amount), 0) INTO l_x, l_open FROM ar_open_item
       WHERE id = r.inv AND customer_account_id = l_acc.id AND item_type = 'INVOICE' AND open_amount > 0;
      NOONA_CORE_PKG.assert(l_x IS NOT NULL AND r.a <= l_open AND r.a <= l_left, 'NOONA-SAL-053',
                            'مبلغ التخصيص أكبر من المتبقي على الفاتورة أو من مبلغ التحصيل', 'Allocation exceeds open amount');
      apply(l_x, ROUND(r.a, 2));
    END LOOP;
    IF NOT l_has THEN
      FOR oi IN (SELECT id, open_amount FROM ar_open_item
                  WHERE customer_account_id = l_acc.id AND company_id = company AND item_type = 'INVOICE' AND open_amount > 0
                  ORDER BY due_date, id FOR UPDATE) LOOP
        EXIT WHEN l_left <= 0;
        apply(oi.id, LEAST(oi.open_amount, l_left));
      END LOOP;
    END IF;
    l_desc := 'تحصيل من العميل ' || customer_label(l_acc.id) || ' ' || l_no || NVL2(l_ref, ' مرجع ' || l_ref, '') || NVL2(l_notes, ': ' || l_notes, '');
    add_line(l_lines, NOONA_CSH_PKG.place_account(l_place), l_amt, 0, NULL, NULL, l_desc);
    add_line(l_lines, receivable_account(l_acc), 0, l_amt, NULL, l_party, l_desc);
    l_j := NOONA_ACE_PKG.post_source('AR_RECEIPT_CONFIRMED', 'SALES', c_rcp, l_id, l_date, l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                     l_lines, l_no, NULL, 'CUSTOMER_RECEIPT');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    l_x := NOONA_CSH_PKG.record_settlement('RECEIPT', l_place, l_date, l_amt, l_party, customer_label(l_acc.id), c_rcp, l_id, l_no, l_desc, l_ev,
                                           CASE WHEN l_meth IN ('MADA', 'CARD') THEN 'CARD' WHEN l_meth IN ('APPLE_PAY', 'STC_PAY') THEN 'WALLET'
                                                WHEN l_meth = 'CHEQUE' THEN 'CHEQUE' END);
    UPDATE ar_receipt SET status_code = 'CONFIRMED', unapplied_amount = l_left, cash_transaction_id = l_x, accounting_event_id = l_ev,
                          posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = l_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_rcp, l_id, 'CONFIRM', 'SUCCESS');
    NOONA_API_PKG.publish('AR_RECEIPT.CREATED', c_rcp, l_id);
    RETURN l_id;
  END receive;

  FUNCTION reverse_receipt(p_receipt_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_r ar_receipt%ROWTYPE;
    l_j NUMBER;
    l_src VARCHAR2(30); l_sid NUMBER; l_rem NUMBER;
  BEGIN
    guard('AR_RECEIPT.REVERSE');
    SELECT * INTO l_r FROM ar_receipt WHERE id = p_receipt_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_r.status_code = 'CONFIRMED', 'NOONA-SAL-054', 'يعكس التحصيل المؤكد فقط', 'Only confirmed receipts can be reversed');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-SAL-055', 'سبب العكس إلزامي', 'Reason is required');
    l_j := NOONA_ACE_PKG.reverse_source(c_rcp, p_receipt_id, NVL(p_date, TRUNC(SYSDATE)), p_reason);
    FOR a IN (SELECT id, open_item_id, applied_amount FROM ar_receipt_application WHERE receipt_id = p_receipt_id AND status_code = 'APPLIED') LOOP
      UPDATE ar_open_item SET open_amount = open_amount + a.applied_amount, open_func = open_func + a.applied_amount,
                              status_code = CASE WHEN open_amount + a.applied_amount = original_amount THEN 'OPEN' ELSE 'PARTIALLY_PAID' END
       WHERE id = a.open_item_id
      RETURNING source_entity_type, source_entity_id INTO l_src, l_sid;
      UPDATE ar_receipt_application SET status_code = 'UNAPPLIED' WHERE id = a.id;
      IF l_src = c_inv THEN
        SELECT NVL(SUM(open_amount), 0) INTO l_rem FROM ar_open_item WHERE source_entity_type = c_inv AND source_entity_id = l_sid;
        UPDATE sal_invoice SET status_code = CASE WHEN l_rem >= total_amount THEN 'POSTED' ELSE 'PARTIALLY_PAID' END WHERE id = l_sid;
      END IF;
    END LOOP;
    UPDATE ar_receipt SET status_code = 'REVERSED', return_reason = SUBSTR(p_reason, 1, 400) WHERE id = p_receipt_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_rcp, p_receipt_id, 'REVERSE', 'SUCCESS');
    RETURN l_j;
  END reverse_receipt;

  -- ================================================================ التقارير
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_class VARCHAR2 DEFAULT '') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div>'
        || '<div class="nn-kpi-value">' || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION sal_summary RETURN CLOB IS
    l_today NUMBER; l_month NUMBER; l_open NUMBER; l_over NUMBER; l_pos NUMBER; l_gp NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE WHEN doc_type = 'CREDIT_NOTE' THEN -total_amount ELSE total_amount END), 0),
           NVL(SUM(CASE WHEN doc_date = TRUNC(SYSDATE) THEN CASE WHEN doc_type = 'CREDIT_NOTE' THEN -total_amount ELSE total_amount END END), 0),
           NVL(SUM(CASE WHEN doc_type = 'CREDIT_NOTE' THEN -(subtotal - cogs_amount) ELSE subtotal - cogs_amount END), 0)
      INTO l_month, l_today, l_gp
      FROM sal_invoice WHERE company_id = company AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID') AND doc_date >= TRUNC(SYSDATE, 'MM');
    SELECT NVL(SUM(CASE WHEN sale_type = 'RETURN' THEN -total_amount ELSE total_amount END), 0) INTO l_pos
      FROM pos_sale WHERE company_id = company AND status_code IN ('COMPLETED', 'RETURNED', 'PARTIALLY_RETURNED') AND sale_at >= TRUNC(SYSDATE, 'MM');
    SELECT NVL(SUM(CASE WHEN item_type = 'CREDIT_NOTE' THEN -open_amount ELSE open_amount END), 0),
           NVL(SUM(CASE WHEN item_type = 'INVOICE' AND due_date < TRUNC(SYSDATE) THEN open_amount END), 0)
      INTO l_open, l_over FROM ar_open_item WHERE company_id = company AND open_amount > 0;
    RETURN '<div class="nn-kpis">' || kpi('مبيعات اليوم (فواتير)', fmt0(l_today), 'fa-calendar-check-o')
        || kpi('مبيعات الشهر (فواتير)', fmt0(l_month), 'fa-line-chart') || kpi('نقاط البيع هذا الشهر', fmt0(l_pos), 'fa-shopping-basket')
        || kpi('مجمل ربح الفواتير', fmt0(l_gp), 'fa-percent')
        || kpi('مستحق على العملاء', fmt0(l_open), 'fa-users')
        || kpi('متأخر التحصيل', fmt0(l_over), 'fa-exclamation-triangle', CASE WHEN l_over > 0 THEN 'is-danger' END) || '</div>';
  END sal_summary;

  FUNCTION customer_statement(p_account_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_html CLOB;
    l_open NUMBER;
    l_bal  NUMBER;
    l_dr   NUMBER := 0;
    l_cr   NUMBER := 0;
  BEGIN
    guard('SAL_INVOICE.VIEW');
    IF p_account_id IS NULL THEN RETURN '<div class="nn-empty">اختر العميل</div>'; END IF;
    l_open := customer_balance(p_account_id, p_from - 1);
    l_bal := l_open;
    l_html := NOONA_BRAND_PKG.report_header('كشف حساب عميل: ' || customer_label(p_account_id) || ' من ' || TO_CHAR(p_from, 'YYYY-MM-DD')
                                            || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>المستند</th><th>البيان</th><th>مدين (مبيعات)</th>'
           || '<th>دائن (تحصيل ومرتجع)</th><th>الرصيد</th></tr></thead><tbody>'
           || '<tr class="nn-rpt-group"><td colspan="5">الرصيد الافتتاحي</td><td>' || fmt0(l_open) || '</td></tr>';
    FOR r IN (SELECT doc_date d, doc_no, CASE WHEN item_type = 'CREDIT_NOTE' THEN 'مرتجع / إشعار دائن'
                                             WHEN source_entity_type = 'POS_SALE' THEN 'بيع آجل من نقطة البيع' ELSE 'فاتورة مبيعات آجلة' END txt,
                     CASE WHEN item_type = 'CREDIT_NOTE' THEN 0 ELSE original_amount END dr,
                     CASE WHEN item_type = 'CREDIT_NOTE' THEN original_amount ELSE 0 END cr, 1 o, id
                FROM ar_open_item WHERE customer_account_id = p_account_id AND company_id = company AND status_code <> 'CANCELLED'
                 AND doc_date BETWEEN p_from AND p_to
              UNION ALL
              SELECT doc_date, doc_no, 'تحصيل' || NVL2(external_reference, ' (' || external_reference || ')', ''), 0, amount, 2, id
                FROM ar_receipt WHERE customer_account_id = p_account_id AND company_id = company AND status_code = 'CONFIRMED'
                 AND doc_date BETWEEN p_from AND p_to
               ORDER BY 1, 6, 7) LOOP
      l_bal := l_bal + r.dr - r.cr;
      l_dr := l_dr + r.dr;
      l_cr := l_cr + r.cr;
      l_html := l_html || ('<tr><td>' || TO_CHAR(r.d, 'YYYY-MM-DD') || '</td><td>' || esc(r.doc_no) || '</td><td class="nn-rpt-text">'
             || esc(r.txt) || '</td><td>' || fmt(r.dr) || '</td><td>' || fmt(r.cr) || '</td><td>' || fmt0(l_bal) || '</td></tr>');
    END LOOP;
    RETURN l_html || ('</tbody><tfoot><tr><td colspan="3">الإجمالي والرصيد المستحق على العميل</td><td>' || fmt0(l_dr) || '</td><td>'
        || fmt0(l_cr) || '</td><td>' || fmt0(l_bal) || '</td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('المبيعات الآجلة فقط؛ الفواتير النقدية لا تؤثر في رصيد العميل'));
  END customer_statement;

  FUNCTION ar_aging(p_as_of IN DATE DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_d    DATE := NVL(p_as_of, TRUNC(SYSDATE));
    l_html CLOB;
    t NUMBER := 0; t0 NUMBER := 0; t1 NUMBER := 0; t2 NUMBER := 0; t3 NUMBER := 0; t4 NUMBER := 0;
    l_lim NUMBER;
  BEGIN
    guard('SAL_INVOICE.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('أعمار ديون العملاء في ' || TO_CHAR(l_d, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>العميل</th><th>حد الائتمان</th><th>غير مستحق</th><th>1-30</th><th>31-60</th><th>61-90</th>'
           || '<th>أكثر من 90</th><th>الإجمالي</th></tr></thead><tbody>';
    FOR r IN (SELECT o.customer_account_id cid,
                     SUM(CASE WHEN o.item_type = 'CREDIT_NOTE' THEN -o.open_amount ELSE o.open_amount END) tot,
                     SUM(CASE WHEN o.item_type = 'CREDIT_NOTE' THEN -o.open_amount WHEN o.due_date >= l_d THEN o.open_amount ELSE 0 END) b0,
                     SUM(CASE WHEN o.item_type <> 'CREDIT_NOTE' AND l_d - o.due_date BETWEEN 1 AND 30 THEN o.open_amount ELSE 0 END) b1,
                     SUM(CASE WHEN o.item_type <> 'CREDIT_NOTE' AND l_d - o.due_date BETWEEN 31 AND 60 THEN o.open_amount ELSE 0 END) b2,
                     SUM(CASE WHEN o.item_type <> 'CREDIT_NOTE' AND l_d - o.due_date BETWEEN 61 AND 90 THEN o.open_amount ELSE 0 END) b3,
                     SUM(CASE WHEN o.item_type <> 'CREDIT_NOTE' AND l_d - o.due_date > 90 THEN o.open_amount ELSE 0 END) b4
                FROM ar_open_item o WHERE o.company_id = company AND o.open_amount > 0
               GROUP BY o.customer_account_id ORDER BY 2 DESC) LOOP
      t := t + r.tot; t0 := t0 + r.b0; t1 := t1 + r.b1; t2 := t2 + r.b2; t3 := t3 + r.b3; t4 := t4 + r.b4;
      l_lim := credit_limit(r.cid);
      l_html := l_html || ('<tr' || CASE WHEN l_lim IS NOT NULL AND r.tot > l_lim THEN ' class="nn-rpt-warn"' END || '><td class="nn-rpt-text">'
             || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.cid) || '">' || esc(customer_label(r.cid)) || '</a>'
                     ELSE esc(customer_label(r.cid)) END
             || '</td><td>' || fmt(l_lim) || '</td><td>' || fmt(r.b0) || '</td><td>' || fmt(r.b1) || '</td><td>' || fmt(r.b2) || '</td><td>'
             || fmt(r.b3) || '</td><td' || CASE WHEN r.b4 > 0 THEN ' class="nn-rpt-bad"' END || '>' || fmt(r.b4) || '</td><td><b>' || fmt(r.tot)
             || '</b></td></tr>');
    END LOOP;
    RETURN l_html || ('</tbody><tfoot><tr><td colspan="2">الإجمالي</td><td>' || fmt0(t0) || '</td><td>' || fmt0(t1) || '</td><td>' || fmt0(t2)
        || '</td><td>' || fmt0(t3) || '</td><td>' || fmt0(t4) || '</td><td>' || fmt0(t) || '</td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('حسب تاريخ الاستحقاق؛ الصفوف المظللة تجاوزت حد الائتمان'));
  END ar_aging;

  FUNCTION sales_register(p_from IN DATE, p_to IN DATE, p_account_id IN NUMBER DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0; s2 NUMBER := 0; s3 NUMBER := 0; s4 NUMBER := 0;
    l_sg NUMBER;
  BEGIN
    guard('SAL_INVOICE.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('سجل المبيعات من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>رقم الفاتورة</th><th>النوع</th><th>العميل</th><th>الطريقة</th>'
           || '<th>الصافي</th><th>الضريبة</th><th>الإجمالي</th><th>التكلفة</th><th>مجمل الربح</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT id, doc_date, doc_no, doc_type, customer_name_snapshot, payment_mode, subtotal, tax_amount, total_amount, cogs_amount,
                     status_code
                FROM sal_invoice WHERE company_id = company AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID')
                 AND doc_date BETWEEN p_from AND p_to AND (p_account_id IS NULL OR customer_account_id = p_account_id)
               ORDER BY doc_date, id) LOOP
      l_sg := CASE WHEN r.doc_type = 'CREDIT_NOTE' THEN -1 ELSE 1 END;
      s1 := s1 + l_sg * r.subtotal; s2 := s2 + l_sg * r.tax_amount; s3 := s3 + l_sg * r.total_amount; s4 := s4 + l_sg * r.cogs_amount;
      l_html := l_html || ('<tr' || CASE WHEN l_sg < 0 THEN ' class="nn-rpt-warn"' END || '><td>' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') || '</td><td>'
             || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(r.doc_no) || '</a>' ELSE esc(r.doc_no) END
             || '</td><td>' || CASE r.doc_type WHEN 'CREDIT_NOTE' THEN 'مرتجع' WHEN 'INVOICE' THEN 'ضريبية' ELSE 'مبسطة' END
             || '</td><td class="nn-rpt-text">' || esc(r.customer_name_snapshot) || '</td><td>' || mode_label(r.payment_mode) || '</td><td>'
             || fmt(l_sg * r.subtotal) || '</td><td>' || fmt(l_sg * r.tax_amount) || '</td><td>' || fmt(l_sg * r.total_amount) || '</td><td>'
             || fmt(l_sg * r.cogs_amount) || '</td><td>' || fmt(l_sg * (r.subtotal - r.cogs_amount)) || '</td><td>' || status_label(r.status_code)
             || '</td></tr>');
    END LOOP;
    RETURN l_html || ('</tbody><tfoot><tr><td colspan="5">صافي المبيعات</td><td>' || fmt0(s1) || '</td><td>' || fmt0(s2) || '</td><td>'
        || fmt0(s3) || '</td><td>' || fmt0(s4) || '</td><td>' || fmt0(s1 - s4) || '</td><td></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('فواتير المبيعات والمرتجعات المرحلة (مبيعات نقاط البيع في تقارير الورديات)'));
  END sales_register;

  FUNCTION sales_by_item(p_from IN DATE, p_to IN DATE, p_category_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0; s2 NUMBER := 0;
  BEGIN
    guard('SAL_INVOICE.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('المبيعات والربحية حسب الصنف من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>الصنف</th><th>الفئة</th><th>الكمية</th><th>صافي المبيعات</th><th>التكلفة</th>'
           || '<th>مجمل الربح</th><th>هامش %</th><th>منها نقاط البيع</th></tr></thead><tbody>';
    FOR r IN (SELECT i.item_no || ' - ' || i.name_ar item, g.name_ar cat, SUM(x.q) q, SUM(x.net) net, SUM(x.cost) cost, SUM(x.pos) pos
                FROM (SELECT l.item_id, CASE WHEN h.doc_type = 'CREDIT_NOTE' THEN -1 ELSE 1 END * l.quantity q,
                             CASE WHEN h.doc_type = 'CREDIT_NOTE' THEN -1 ELSE 1 END * l.net_amount net,
                             CASE WHEN h.doc_type = 'CREDIT_NOTE' THEN -1 ELSE 1 END * l.quantity * NVL(l.unit_cost, 0) cost, 0 pos
                        FROM sal_invoice_line l JOIN sal_invoice h ON h.id = l.invoice_id
                       WHERE h.company_id = company AND h.status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID') AND h.doc_date BETWEEN p_from AND p_to
                         AND l.item_id IS NOT NULL
                      UNION ALL
                      SELECT l.item_id, CASE WHEN s.sale_type = 'RETURN' THEN -1 ELSE 1 END * l.quantity,
                             CASE WHEN s.sale_type = 'RETURN' THEN -1 ELSE 1 END * (l.line_total - l.tax_amount),
                             CASE WHEN s.sale_type = 'RETURN' THEN -1 ELSE 1 END * l.quantity * NVL(l.unit_cost, 0),
                             CASE WHEN s.sale_type = 'RETURN' THEN -1 ELSE 1 END * (l.line_total - l.tax_amount)
                        FROM pos_sale_line l JOIN pos_sale s ON s.id = l.sale_id
                       WHERE s.company_id = company AND s.status_code IN ('COMPLETED', 'RETURNED', 'PARTIALLY_RETURNED')
                         AND TRUNC(s.sale_at) BETWEEN p_from AND p_to) x
                JOIN inv_item i ON i.id = x.item_id JOIN inv_item_category g ON g.id = i.category_id
               WHERE p_category_id IS NULL OR i.category_id = p_category_id
               GROUP BY i.item_no, i.name_ar, g.name_ar ORDER BY 4 DESC) LOOP
      s1 := s1 + r.net; s2 := s2 + r.cost;
      l_html := l_html || ('<tr><td class="nn-rpt-text">' || esc(r.item) || '</td><td>' || esc(r.cat) || '</td><td>' || fqty(r.q) || '</td><td>'
             || fmt(r.net) || '</td><td>' || fmt(r.cost) || '</td><td>' || fmt(r.net - r.cost) || '</td><td>'
             || CASE WHEN r.net <> 0 THEN TO_CHAR(ROUND((r.net - r.cost) * 100 / r.net, 1)) END || '</td><td>' || fmt(r.pos) || '</td></tr>');
    END LOOP;
    RETURN l_html || ('</tbody><tfoot><tr><td colspan="3">الإجمالي</td><td>' || fmt0(s1) || '</td><td>' || fmt0(s2) || '</td><td>' || fmt0(s1 - s2)
        || '</td><td>' || CASE WHEN s1 <> 0 THEN TO_CHAR(ROUND((s1 - s2) * 100 / s1, 1)) END || '</td><td></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('الصافي قبل الضريبة بعد الخصم والمرتجعات؛ التكلفة بالمتوسط المرجح وقت البيع'));
  END sales_by_item;

  FUNCTION invoice_print(p_invoice_id IN NUMBER) RETURN CLOB IS
    l_i    sal_invoice%ROWTYPE;
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
    l_vat  VARCHAR2(100) := seller_vat;
  BEGIN
    guard('SAL_INVOICE.VIEW');
    SELECT * INTO l_i FROM sal_invoice WHERE id = p_invoice_id AND company_id = company;
    l_html := NOONA_BRAND_PKG.report_header(CASE l_i.doc_type WHEN 'CREDIT_NOTE' THEN 'إشعار دائن (مرتجع مبيعات)'
                                                              WHEN 'INVOICE' THEN 'فاتورة ضريبية' ELSE 'فاتورة ضريبية مبسطة' END || ' ' || l_i.doc_no)
           || '<table class="nn-rpt nn-rpt-meta"><tbody><tr><th>العميل</th><td>' || esc(l_i.customer_name_snapshot) || '</td><th>التاريخ</th><td>'
           || TO_CHAR(l_i.doc_date, 'YYYY-MM-DD') || '</td></tr><tr><th>الرقم الضريبي للعميل</th><td>' || esc(l_i.customer_tax_no_snapshot)
           || '</td><th>الرقم الضريبي للبائع</th><td>' || esc(l_vat) || '</td></tr><tr><th>الطريقة</th><td>' || mode_label(l_i.payment_mode)
           || '</td><th>تاريخ الاستحقاق</th><td>' || TO_CHAR(l_i.due_date, 'YYYY-MM-DD') || '</td></tr></tbody></table>'
           || '<table class="nn-rpt"><thead><tr><th>#</th><th>البند</th><th>الكمية</th><th>السعر</th><th>الخصم</th><th>الصافي</th><th>الضريبة</th>'
           || '<th>الإجمالي</th></tr></thead><tbody>';
    FOR r IN (SELECT l.*, (SELECT item_no FROM inv_item WHERE id = l.item_id) ino FROM sal_invoice_line l
               WHERE l.invoice_id = p_invoice_id ORDER BY l.line_no) LOOP
      l_n := l_n + 1;
      l_html := l_html || ('<tr><td>' || l_n || '</td><td class="nn-rpt-text">' || esc(NVL2(r.ino, r.ino || ' - ', '') || r.description) || '</td><td>'
             || fqty(r.quantity) || '</td><td>' || fmt(r.unit_price) || '</td><td>' || fmt(r.discount_amount) || '</td><td>' || fmt(r.net_amount)
             || '</td><td>' || fmt(r.tax_amount) || '</td><td>' || fmt(r.net_amount + NVL(r.tax_amount, 0)) || '</td></tr>');
    END LOOP;
    RETURN l_html || ('</tbody><tfoot><tr><td colspan="5">الإجمالي</td><td>' || fmt0(l_i.subtotal) || '</td><td>' || fmt0(l_i.tax_amount)
        || '</td><td>' || fmt0(l_i.total_amount) || '</td></tr></tfoot></table>'
        || '<p class="nn-rpt-words">' || esc(NOONA_CSH_PKG.amount_words(l_i.total_amount, l_i.currency_code)) || '</p>'
        || '<div class="nn-qr" data-qr="' || NVL(NOONA_EINV_PKG.invoice_qr(l_i.id), zatca_qr(NVL(l_i.issued_at, SYSTIMESTAMP), l_i.total_amount, l_i.tax_amount)) || '"></div>');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SAL-025', 'فاتورة المبيعات غير موجودة', 'Sales invoice not found');
  END invoice_print;

END NOONA_SAL_PKG;
/
