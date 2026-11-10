-- =============================================================================
-- NOONA PLUS ERP | الموردون والمشتريات: NOONA_PUR_PKG
--   الموردون (طرف موحد + حساب مورد لكل شركة)، أوامر الشراء، فاتورة المشتريات مع الاستلام المباشر للمخزن
--   (الدفعات والصلاحية)، آجل أو نقدي من صندوق/بنك، مرتجع المشتريات، سداد الموردين وتخصيصه على الفواتير،
--   كشف حساب المورد وأعمار الديون وسجل المشتريات. كل مستند مرحل يولد قيده عبر محرك المحاسبة بنوعه.
-- =============================================================================

CREATE OR REPLACE PACKAGE NOONA_PUR_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;

  -- ---------------------------------------------------------- الموردون
  -- {"id":accountId,"name","nameEn","person":"N","type":"GOODS","tax","cr","phone","email","address","term":"NET30","status"}
  FUNCTION save_supplier(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION supplier_json(p_account_id IN NUMBER) RETURN CLOB;
  FUNCTION suppliers_json(p_term IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION supplier_label(p_account_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION supplier_balance(p_account_id IN NUMBER, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER;
  FUNCTION payment_methods_json RETURN CLOB;

  -- ---------------------------------------------------------- أوامر الشراء
  -- {"id","sup","date","wh","need","notes","action":"SAVE|APPROVE","lines":[{"i","d","q","p","disc","tc"}]}
  FUNCTION save_order(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION order_json(p_order_id IN NUMBER) RETURN CLOB;
  PROCEDURE cancel_order(p_order_id IN NUMBER);

  -- ---------------------------------------------------------- فاتورة المشتريات
  -- {"id","sup","date","supInv","supDate","wh","po","mode":"CREDIT|CASH","place":"BOX:1","cc","notes","action":"SAVE|POST",
  --  "lines":[{"i":item,"d":desc,"q","p","disc","tc":"VAT15","acc":"5205","cc","lot","exp","pol":poLine}]}
  FUNCTION save_invoice(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION invoice_json(p_invoice_id IN NUMBER) RETURN CLOB;
  PROCEDURE post_invoice(p_invoice_id IN NUMBER);
  PROCEDURE cancel_invoice(p_invoice_id IN NUMBER);
  -- فاتورة جديدة من أمر شراء معتمد (الكميات المتبقية)
  FUNCTION invoice_from_order(p_order_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- مرتجع المشتريات (إشعار مدين للمورد)
  -- {"inv":originalId,"date","reason","place":"BOX:1 (للفاتورة النقدية)","lines":[{"l":invoiceLineId,"q":2}]}
  FUNCTION post_return(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION returnable_json(p_invoice_id IN NUMBER) RETURN CLOB;
  -- شاشة المرتجع: {"inv","no","date","lines":[...]}
  FUNCTION return_doc_json(p_invoice_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- سداد الموردين
  -- {"sup","date","amount","place":"BOX:1|BANK:2","method":"CASH","ref","notes","alloc":[{"inv":id,"a":100}]}  (بلا alloc: الأقدم أولاً)
  FUNCTION pay_supplier(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION reverse_payment(p_payment_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER;
  FUNCTION open_items_json(p_account_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- التقارير
  FUNCTION pur_summary RETURN CLOB;
  FUNCTION supplier_statement(p_account_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION ap_aging(p_as_of IN DATE DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION purchase_register(p_from IN DATE, p_to IN DATE, p_account_id IN NUMBER DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION purchases_by_item(p_from IN DATE, p_to IN DATE, p_category_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION invoice_print(p_invoice_id IN NUMBER) RETURN CLOB;
  FUNCTION mode_label(p_mode IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
END NOONA_PUR_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PUR_PKG AS

  c_inv CONSTANT VARCHAR2(30) := 'AP_INVOICE';
  c_pay CONSTANT VARCHAR2(30) := 'AP_PAYMENT';

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
    RETURN CASE p_status WHEN 'DRAFT' THEN 'مسودة' WHEN 'APPROVED' THEN 'معتمد' WHEN 'POSTED' THEN 'مرحلة'
                         WHEN 'PARTIALLY_PAID' THEN 'مسددة جزئياً' WHEN 'PAID' THEN 'مسددة' WHEN 'CANCELLED' THEN 'ملغاة'
                         WHEN 'PARTIALLY_RECEIVED' THEN 'مستلم جزئياً' WHEN 'RECEIVED' THEN 'مستلم' WHEN 'SETTLED' THEN 'منفذ'
                         WHEN 'REVERSED' THEN 'معكوس' WHEN 'ACTIVE' THEN 'نشط' WHEN 'BLOCKED' THEN 'موقوف' ELSE p_status END;
  END status_label;

  -- ================================================================ التجهيز
  FUNCTION is_ready RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(DISTINCT doc_type_code) INTO l FROM ref_doc_sequence WHERE company_id = company AND doc_type_code IN ('AP_INVOICE', 'AP_PAYMENT', 'AP_SUPPLIER');
    RETURN CASE WHEN l = 3 AND NOONA_INV_PKG.is_ready = 'Y' THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n NUMBER := 0;
  BEGIN
    guard('AP_SUPPLIER.CREATE');
    IF NOONA_INV_PKG.is_ready = 'N' THEN
      l_n := NOONA_INV_PKG.quick_setup;
    ELSE
      l_n := NOONA_INV_PKG.quick_setup;    -- طرق السداد وشروط الدفع (لا يكرر)
    END IF;
    NOONA_INV_PKG.ensure_sequence('AP_SUPPLIER', 'SUP-');
    NOONA_INV_PKG.ensure_sequence('PUR_ORDER', 'PO-');
    NOONA_INV_PKG.ensure_sequence('AP_INVOICE', 'PI-');
    NOONA_INV_PKG.ensure_sequence('AP_DEBIT_NOTE', 'PR-');
    NOONA_INV_PKG.ensure_sequence('AP_PAYMENT', 'SP-');
    RETURN l_n;
  END quick_setup;

  FUNCTION term_id(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM ref_payment_term WHERE code = NVL(p_code, 'NET30') AND is_active = 'Y';
    RETURN l;
  END term_id;

  FUNCTION method_id(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM ref_payment_method WHERE code = NVL(p_code, 'CASH') AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-PUR-060', 'طريقة السداد غير معرفة (نفذ تجهيز المشتريات)', 'Unknown payment method');
    RETURN l;
  END method_id;

  FUNCTION payment_methods_json RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('c' VALUE code, 'n' VALUE name_ar, 't' VALUE method_type, 'r' VALUE requires_reference,
                                     'i' VALUE icon_class) ORDER BY sort_order, id RETURNING CLOB)
      INTO l FROM ref_payment_method WHERE is_active = 'Y';
    RETURN NVL(l, '[]');
  END payment_methods_json;

  -- ================================================================ الموردون
  FUNCTION get_account(p_account_id NUMBER) RETURN ap_supplier_account%ROWTYPE IS
    l ap_supplier_account%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM ap_supplier_account WHERE id = p_account_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-001', 'المورد غير موجود في هذه الشركة', 'Supplier not found');
  END get_account;

  FUNCTION supplier_party(p_account_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT s.party_id INTO l FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id WHERE a.id = p_account_id;
    RETURN l;
  END supplier_party;

  FUNCTION supplier_label(p_account_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT s.supplier_no || ' - ' || p.display_name_ar INTO l
      FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
     WHERE a.id = p_account_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END supplier_label;

  FUNCTION payable_account(p_acc ap_supplier_account%ROWTYPE) RETURN NUMBER IS
  BEGIN
    RETURN NVL(p_acc.payable_account_id, NOONA_INV_PKG.acc_id('2101'));
  END payable_account;

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
      SELECT MIN(id) INTO l FROM ref_address WHERE party_id = p_party AND address_type = 'LEGAL';
      IF l IS NULL THEN
        INSERT INTO ref_address (party_id, address_type, country_code, address_line_ar, is_primary) VALUES (p_party, 'LEGAL', 'SA', p_address, 'Y');
      ELSE
        UPDATE ref_address SET address_line_ar = p_address WHERE id = l;
      END IF;
    END IF;
  END upsert_contact;

  FUNCTION save_supplier(p_doc IN CLOB) RETURN NUMBER IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id     NUMBER := l_o.get_number('id');
    l_name   VARCHAR2(400) := TRIM(l_o.get_string('name'));
    l_name_en VARCHAR2(400) := l_o.get_string('nameEn');
    l_person VARCHAR2(1) := NVL(l_o.get_string('person'), 'N');
    l_type   VARCHAR2(30) := NVL(l_o.get_string('type'), 'GOODS');
    l_tax    VARCHAR2(50) := l_o.get_string('tax');
    l_cr     VARCHAR2(50) := l_o.get_string('cr');
    l_phone  VARCHAR2(50) := l_o.get_string('phone');
    l_email  VARCHAR2(200) := l_o.get_string('email');
    l_addr   VARCHAR2(500) := l_o.get_string('address');
    l_term   NUMBER := term_id(l_o.get_string('term'));
    l_status VARCHAR2(30) := NVL(l_o.get_string('status'), 'ACTIVE');
    l_party  NUMBER;
    l_sup    NUMBER;
    l_no     VARCHAR2(50);
  BEGIN
    NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-PUR-002', 'اسم المورد إلزامي', 'Supplier name is required');
    IF l_id IS NULL THEN
      guard('AP_SUPPLIER.CREATE');
      l_party := NOONA_PTY_PKG.create_party(CASE WHEN l_person = 'Y' THEN 'PERSON' ELSE 'ORGANIZATION' END, l_name, 'SUPPLIER',
                                            l_name_en, l_tax, l_cr);
      l_no := NOONA_REFERENCE_PKG.next_doc_no('AP_SUPPLIER', company, NULL, TRUNC(SYSDATE), 'AP_SUPPLIER', NULL);
      INSERT INTO ap_supplier (party_id, supplier_no, supplier_type, is_local, status_code)
      VALUES (l_party, l_no, l_type, 'Y', 'ACTIVE')
      RETURNING id INTO l_sup;
      INSERT INTO ap_supplier_account (company_id, supplier_id, account_no, currency_code, payment_term_id, payable_account_id,
                                       default_tax_code_id, match_policy, required_docs_ok, status_code)
      VALUES (company, l_sup, l_no, NOONA_GL_PKG.ledger_currency, l_term, NOONA_INV_PKG.acc_id('2101'), NOONA_INV_PKG.tax_id('VAT15'),
              'TWO_WAY', 'N', l_status)
      RETURNING id INTO l_id;
    ELSE
      guard('AP_SUPPLIER.UPDATE');
      SELECT s.party_id, s.id INTO l_party, l_sup FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id
       WHERE a.id = l_id AND a.company_id = company;
      UPDATE pty_party SET display_name_ar = l_name, display_name_en = l_name_en,
                           tax_number = NVL(REPLACE(TRIM(l_tax), ' '), tax_number) WHERE id = l_party;
      UPDATE ap_supplier SET supplier_type = l_type WHERE id = l_sup;
      UPDATE ap_supplier_account SET payment_term_id = l_term, status_code = l_status WHERE id = l_id;
    END IF;
    upsert_contact(l_party, l_phone, l_email, l_addr);
    UPDATE ap_supplier_account SET required_docs_ok = CASE WHEN NOONA_DMS_PKG.missing_documents(l_party, 'SUPPLIER') = 0 THEN 'Y' ELSE 'N' END
     WHERE id = l_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'AP_SUPPLIER', l_sup, 'SAVE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-001', 'المورد غير موجود في هذه الشركة', 'Supplier not found');
  END save_supplier;

  FUNCTION supplier_json(p_account_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    IF p_account_id IS NULL THEN
      RETURN '{"id":null,"type":"GOODS","person":"N","term":"NET30","status":"ACTIVE"}';
    END IF;
    SELECT JSON_OBJECT('id' VALUE a.id, 'no' VALUE s.supplier_no, 'name' VALUE p.display_name_ar, 'nameEn' VALUE p.display_name_en,
             'person' VALUE CASE WHEN p.party_type = 'PERSON' THEN 'Y' ELSE 'N' END, 'type' VALUE s.supplier_type, 'tax' VALUE p.tax_number,
             'cr' VALUE (SELECT cr_number FROM pty_organization WHERE party_id = p.id),
             'phone' VALUE (SELECT MAX(mobile) FROM ref_contact WHERE party_id = p.id AND is_primary = 'Y'),
             'email' VALUE (SELECT MAX(email) FROM ref_contact WHERE party_id = p.id AND is_primary = 'Y'),
             'address' VALUE (SELECT MAX(address_line_ar) FROM ref_address WHERE party_id = p.id AND address_type = 'LEGAL'),
             'term' VALUE (SELECT code FROM ref_payment_term WHERE id = a.payment_term_id), 'status' VALUE a.status_code,
             'party' VALUE p.id, 'docsOk' VALUE a.required_docs_ok, 'balance' VALUE supplier_balance(a.id))
      INTO l
      FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
     WHERE a.id = p_account_id AND a.company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-001', 'المورد غير موجود في هذه الشركة', 'Supplier not found');
  END supplier_json;

  FUNCTION suppliers_json(p_term IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l   CLOB;
    l_t VARCHAR2(210) := '%' || UPPER(TRIM(p_term)) || '%';
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE a.id, 'n' VALUE s.supplier_no || ' - ' || p.display_name_ar, 'tax' VALUE p.tax_number,
                                     'term' VALUE t.due_days) ORDER BY p.display_name_ar RETURNING CLOB)
      INTO l
      FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
      LEFT JOIN ref_payment_term t ON t.id = a.payment_term_id
     WHERE a.company_id = company AND a.status_code = 'ACTIVE'
       AND (p_term IS NULL OR UPPER(p.display_name_ar) LIKE l_t OR UPPER(p.display_name_en) LIKE l_t OR s.supplier_no LIKE l_t
            OR p.tax_number LIKE l_t);
    RETURN NVL(l, '[]');
  END suppliers_json;

  -- الرصيد الدائن للمورد (ما علينا): الفواتير الآجلة - المرتجعات - المدفوعات
  FUNCTION supplier_balance(p_account_id IN NUMBER, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_inv NUMBER; l_pay NUMBER;
    l_to  DATE := NVL(p_as_of, DATE '9999-12-31');
  BEGIN
    SELECT NVL(SUM(CASE WHEN invoice_type = 'CREDIT_MEMO' THEN -total_amount ELSE total_amount END), 0) INTO l_inv
      FROM ap_invoice WHERE supplier_account_id = p_account_id AND company_id = company AND payment_mode = 'CREDIT'
       AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID') AND gl_date <= l_to;
    SELECT NVL(SUM(amount), 0) INTO l_pay FROM ap_payment
     WHERE supplier_account_id = p_account_id AND company_id = company AND status_code = 'SETTLED' AND doc_date <= l_to;
    -- مستحقات دون فاتورة مشتريات: الأرصدة الافتتاحية المستوردة ومستخلصات مقاولي الباطن
    SELECT l_inv + NVL(SUM(CASE WHEN item_type = 'CREDIT_MEMO' THEN -original_amount ELSE original_amount END), 0) INTO l_inv
      FROM ap_open_item WHERE supplier_account_id = p_account_id AND company_id = company AND invoice_id IS NULL
       AND item_type IN ('INVOICE', 'CREDIT_MEMO') AND status_code <> 'CANCELLED' AND NVL(doc_date, due_date) <= l_to;
    RETURN l_inv - l_pay;
  END supplier_balance;

  -- ================================================================ أوامر الشراء
  FUNCTION save_order(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id    NUMBER := l_o.get_number('id');
    l_sup   NUMBER := l_o.get_number('sup');
    l_date  DATE := NVL(d(l_o.get_string('date')), TRUNC(SYSDATE));
    l_wh    NUMBER := NVL(l_o.get_number('wh'), NOONA_INV_PKG.default_warehouse);
    l_need  DATE := d(l_o.get_string('need'));
    l_act   VARCHAR2(30) := NVL(l_o.get_string('action'), 'SAVE');
    l_acc   ap_supplier_account%ROWTYPE;
    l_st    VARCHAR2(30);
    l_no    PLS_INTEGER := 0;
    l_sub   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_net   NUMBER;
    l_tx    NUMBER;
    l_tc    NUMBER;
    l_uom   NUMBER;
    l_desc  VARCHAR2(1000);
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'PUR_ORDER.CREATE' ELSE 'PUR_ORDER.UPDATE' END);
    NOONA_CORE_PKG.assert(l_sup IS NOT NULL, 'NOONA-PUR-010', 'اختر المورد', 'Supplier is required');
    l_acc := get_account(l_sup);
    NOONA_CORE_PKG.assert(l_acc.status_code = 'ACTIVE', 'NOONA-PUR-003', 'المورد غير نشط', 'Supplier is not active');
    IF l_id IS NULL THEN
      INSERT INTO pur_order (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, supplier_account_id, order_type,
                             payment_term_id, delivery_warehouse_id, promised_date, status_code)
      VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'DRAFT-' || RAWTOHEX(SYS_GUID()), l_date, NOONA_GL_PKG.ledger_currency,
              1, l_sup, 'STANDARD', l_acc.payment_term_id, l_wh, l_need, 'DRAFT')
      RETURNING id INTO l_id;
      UPDATE pur_order SET doc_no = 'مسودة-' || l_id WHERE id = l_id;
    ELSE
      SELECT status_code INTO l_st FROM pur_order WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-PUR-011', 'لا يعدل أمر الشراء بعد اعتماده', 'Only draft orders can be edited');
      UPDATE pur_order SET supplier_account_id = l_sup, doc_date = l_date, delivery_warehouse_id = l_wh, promised_date = l_need
       WHERE id = l_id;
      DELETE FROM pur_order_line WHERE order_id = l_id;
    END IF;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', ds VARCHAR2(1000) PATH '$.d',
                q NUMBER PATH '$.q', p NUMBER PATH '$.p', disc NUMBER PATH '$.disc', tc VARCHAR2(30) PATH '$.tc'))) LOOP
      CONTINUE WHEN r.i IS NULL AND TRIM(r.ds) IS NULL;
      NOONA_CORE_PKG.assert(NVL(r.q, 0) > 0 AND NVL(r.p, 0) >= 0, 'NOONA-PUR-012', 'الكمية والسعر غير صحيحين', 'Invalid quantity or price');
      l_tc := CASE WHEN r.tc IS NOT NULL THEN NOONA_INV_PKG.tax_id(r.tc) WHEN r.i IS NOT NULL THEN NOONA_INV_PKG.item_tax_code(r.i, 'PURCHASE')
                   ELSE NOONA_INV_PKG.tax_id('VAT15') END;
      l_net := ROUND(r.q * r.p - NVL(r.disc, 0), 2);
      l_tx := ROUND(l_net * NOONA_INV_PKG.tax_rate(l_tc, l_date) / 100, 2);
      IF r.i IS NOT NULL THEN
        SELECT base_uom_id, name_ar INTO l_uom, l_desc FROM inv_item WHERE id = r.i;
      ELSE
        SELECT MIN(id) INTO l_uom FROM inv_uom WHERE code = 'SRV';
        l_desc := NULL;
      END IF;
      l_no := l_no + 1;
      INSERT INTO pur_order_line (company_id, order_id, line_no, item_id, description, quantity, uom_id, unit_price, discount_pct, tax_code_id,
                                  line_amount, received_qty, invoiced_qty, returned_qty, status_code)
      VALUES (company, l_id, l_no, r.i, NVL(TRIM(r.ds), l_desc), r.q, l_uom, r.p,
              CASE WHEN r.q * r.p > 0 THEN ROUND(NVL(r.disc, 0) * 100 / (r.q * r.p), 6) END, l_tc, l_net, 0, 0, 0, 'OPEN');
      l_sub := l_sub + l_net;
      l_tax := l_tax + l_tx;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-PUR-013', 'أضف بنداً واحداً على الأقل', 'Add at least one line');
    UPDATE pur_order SET subtotal = l_sub, tax_amount = l_tax, total_amount = l_sub + l_tax WHERE id = l_id;
    IF l_act = 'APPROVE' THEN
      guard('PUR_ORDER.APPROVE');
      UPDATE pur_order SET status_code = 'APPROVED',
                           doc_no = NOONA_REFERENCE_PKG.next_doc_no('PUR_ORDER', company, branch_id, l_date, 'PUR_ORDER', l_id)
       WHERE id = l_id;
      NOONA_AUDIT_PKG.log_event('APPROVAL', 'PUR_ORDER', l_id, 'APPROVE', 'SUCCESS');
    END IF;
    RETURN l_id;
  END save_order;

  FUNCTION order_json(p_order_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    IF p_order_id IS NULL THEN
      RETURN '{"id":null,"status":"DRAFT","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":'
          || NVL(TO_CHAR(NOONA_INV_PKG.default_warehouse), 'null') || ',"lines":[]}';
    END IF;
    SELECT JSON_OBJECT('id' VALUE o.id, 'no' VALUE o.doc_no, 'status' VALUE o.status_code, 'sup' VALUE o.supplier_account_id,
             'supName' VALUE supplier_label(o.supplier_account_id), 'date' VALUE TO_CHAR(o.doc_date, 'YYYY-MM-DD'),
             'wh' VALUE o.delivery_warehouse_id, 'need' VALUE TO_CHAR(o.promised_date, 'YYYY-MM-DD'),
             'subtotal' VALUE o.subtotal, 'tax' VALUE o.tax_amount, 'total' VALUE o.total_amount,
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE l.id, 'i' VALUE l.item_id, 'd' VALUE l.description, 'q' VALUE l.quantity,
                                    'p' VALUE l.unit_price, 'disc' VALUE ROUND(l.quantity * l.unit_price - l.line_amount, 2),
                                    'tc' VALUE (SELECT code FROM loc_tax_code WHERE id = l.tax_code_id), 'rq' VALUE l.received_qty,
                                    'n' VALUE (SELECT item_no || ' - ' || name_ar FROM inv_item WHERE id = l.item_id))
                                    ORDER BY l.line_no RETURNING CLOB)
                              FROM pur_order_line l WHERE l.order_id = o.id) FORMAT JSON
             RETURNING CLOB)
      INTO l FROM pur_order o WHERE o.id = p_order_id AND o.company_id = company;
    RETURN REPLACE(l, '"lines":null', '"lines":[]');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-014', 'أمر الشراء غير موجود', 'Purchase order not found');
  END order_json;

  PROCEDURE cancel_order(p_order_id IN NUMBER) IS
    l_n NUMBER;
  BEGIN
    guard('PUR_ORDER.CANCEL');
    SELECT NVL(SUM(received_qty), 0) INTO l_n FROM pur_order_line WHERE order_id = p_order_id;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PUR-015', 'لا يلغى أمر شراء تم استلام جزء منه', 'Order has receipts');
    UPDATE pur_order SET status_code = 'CANCELLED' WHERE id = p_order_id AND company_id = company AND status_code IN ('DRAFT', 'APPROVED');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PUR-015', 'لا يمكن إلغاء أمر الشراء في حالته الحالية', 'Order cannot be cancelled');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PUR_ORDER', p_order_id, 'CANCEL', 'SUCCESS');
  END cancel_order;

  -- ================================================================ فاتورة المشتريات
  FUNCTION save_invoice(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id    NUMBER := l_o.get_number('id');
    l_sup   NUMBER := l_o.get_number('sup');
    l_date  DATE := NVL(d(l_o.get_string('date')), TRUNC(SYSDATE));
    l_sinv  VARCHAR2(100) := TRIM(l_o.get_string('supInv'));
    l_sdate DATE := NVL(d(l_o.get_string('supDate')), NVL(d(l_o.get_string('date')), TRUNC(SYSDATE)));
    l_wh    NUMBER := NVL(l_o.get_number('wh'), NOONA_INV_PKG.default_warehouse);
    l_po    NUMBER := l_o.get_number('po');
    l_mode  VARCHAR2(30) := NVL(l_o.get_string('mode'), 'CREDIT');
    l_place VARCHAR2(30) := l_o.get_string('place');
    l_cc    NUMBER := l_o.get_number('cc');
    l_act   VARCHAR2(30) := NVL(l_o.get_string('action'), 'SAVE');
    l_acc   ap_supplier_account%ROWTYPE;
    l_st    VARCHAR2(30);
    l_no    PLS_INTEGER := 0;
    l_sub   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_net   NUMBER;
    l_tx    NUMBER;
    l_tc    NUMBER;
    l_uom   NUMBER;
    l_desc  VARCHAR2(1000);
    l_type  VARCHAR2(30);
    l_exp   NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'AP_INVOICE.CREATE' ELSE 'AP_INVOICE.UPDATE' END);
    NOONA_CORE_PKG.assert(l_sup IS NOT NULL, 'NOONA-PUR-010', 'اختر المورد', 'Supplier is required');
    l_acc := get_account(l_sup);
    NOONA_CORE_PKG.assert(l_acc.status_code = 'ACTIVE', 'NOONA-PUR-003', 'المورد غير نشط', 'Supplier is not active');
    NOONA_CORE_PKG.assert(l_mode IN ('CREDIT', 'CASH'), 'NOONA-PUR-020', 'طريقة الفاتورة: آجل أو نقدي', 'Mode must be CREDIT or CASH');
    NOONA_CORE_PKG.assert(l_mode = 'CREDIT' OR l_place IS NOT NULL, 'NOONA-PUR-021', 'اختر الصندوق أو البنك للفاتورة النقدية',
                          'Choose the cash box or bank for a cash invoice');
    IF l_id IS NULL THEN
      INSERT INTO ap_invoice (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, supplier_account_id, invoice_type,
                              supplier_invoice_no, supplier_invoice_date, gl_date, purchase_order_id, payment_term_id, match_status,
                              warehouse_id, payment_mode, settle_place, cost_center_id, status_code)
      VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'DRAFT-' || RAWTOHEX(SYS_GUID()), l_date, NOONA_GL_PKG.ledger_currency,
              1, l_sup, 'STANDARD', NVL(l_sinv, '#' || RAWTOHEX(SYS_GUID())), l_sdate, l_date, l_po, l_acc.payment_term_id,
              CASE WHEN l_po IS NULL THEN 'NOT_REQUIRED' ELSE 'MATCHED' END, l_wh, l_mode, CASE WHEN l_mode = 'CASH' THEN l_place END,
              l_cc, 'DRAFT')
      RETURNING id INTO l_id;
      UPDATE ap_invoice SET doc_no = 'مسودة-' || l_id, supplier_invoice_no = NVL(l_sinv, '#' || l_id) WHERE id = l_id;
    ELSE
      SELECT status_code INTO l_st FROM ap_invoice WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-PUR-022', 'لا تعدل فاتورة مرحلة؛ استخدم المرتجع', 'Only draft invoices can be edited');
      UPDATE ap_invoice SET supplier_account_id = l_sup, doc_date = l_date, gl_date = l_date, supplier_invoice_no = NVL(l_sinv, '#' || l_id),
                            supplier_invoice_date = l_sdate, warehouse_id = l_wh, purchase_order_id = l_po, payment_mode = l_mode,
                            settle_place = CASE WHEN l_mode = 'CASH' THEN l_place END, cost_center_id = l_cc,
                            payment_term_id = l_acc.payment_term_id
       WHERE id = l_id;
      DELETE FROM ap_invoice_line WHERE invoice_id = l_id;
    END IF;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', ds VARCHAR2(1000) PATH '$.d',
                q NUMBER PATH '$.q', p NUMBER PATH '$.p', disc NUMBER PATH '$.disc', tc VARCHAR2(30) PATH '$.tc',
                acc VARCHAR2(30) PATH '$.acc', cc NUMBER PATH '$.cc', lot VARCHAR2(100) PATH '$.lot', ex VARCHAR2(10) PATH '$.exp',
                pol NUMBER PATH '$.pol'))) LOOP
      CONTINUE WHEN r.i IS NULL AND TRIM(r.ds) IS NULL;
      NOONA_CORE_PKG.assert(NVL(r.q, 0) > 0 AND NVL(r.p, 0) >= 0, 'NOONA-PUR-012', 'الكمية والسعر غير صحيحين', 'Invalid quantity or price');
      NOONA_CORE_PKG.assert(NVL(r.disc, 0) >= 0 AND NVL(r.disc, 0) <= r.q * r.p, 'NOONA-PUR-023', 'الخصم أكبر من قيمة البند',
                            'Discount exceeds line value');
      l_tc := CASE WHEN r.tc IS NOT NULL THEN NOONA_INV_PKG.tax_id(r.tc) WHEN r.i IS NOT NULL THEN NOONA_INV_PKG.item_tax_code(r.i, 'PURCHASE')
                   ELSE NOONA_INV_PKG.tax_id('VAT15') END;
      l_net := ROUND(r.q * r.p - NVL(r.disc, 0), 2);
      l_tx := ROUND(l_net * NOONA_INV_PKG.tax_rate(l_tc, l_date) / 100, 2);
      l_exp := NULL;
      IF r.i IS NOT NULL THEN
        SELECT base_uom_id, name_ar, CASE WHEN item_type IN ('SERVICE', 'NON_STOCK') THEN 'SERVICE' ELSE 'ITEM' END
          INTO l_uom, l_desc, l_type FROM inv_item WHERE id = r.i;
        IF l_type = 'SERVICE' THEN l_exp := NOONA_INV_PKG.account_for(r.i, 'EXPENSE'); END IF;
      ELSE
        l_uom := NULL; l_desc := NULL; l_type := 'EXPENSE';
        l_exp := NOONA_INV_PKG.acc_id(NVL(r.acc, '5299'));
        NOONA_CORE_PKG.assert(l_exp IS NOT NULL, 'NOONA-PUR-024', 'حساب المصروف غير موجود: ' || r.acc, 'Expense account not found');
      END IF;
      l_no := l_no + 1;
      INSERT INTO ap_invoice_line (company_id, invoice_id, line_no, line_type, item_id, description, quantity, uom_id, unit_price,
                                   line_amount, tax_code_id, expense_account_id, po_line_id, cost_center_id, discount_amount, tax_amount,
                                   lot_no, expiry_date)
      VALUES (company, l_id, l_no, l_type, r.i, NVL(TRIM(r.ds), l_desc), r.q, l_uom, r.p, l_net, l_tc, l_exp, r.pol, NVL(r.cc, l_cc),
              NVL(r.disc, 0), l_tx, TRIM(r.lot), TO_DATE(r.ex, 'YYYY-MM-DD'));
      l_sub := l_sub + l_net;
      l_tax := l_tax + l_tx;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-PUR-013', 'أضف بنداً واحداً على الأقل', 'Add at least one line');
    UPDATE ap_invoice SET subtotal = l_sub, tax_amount = l_tax, total_amount = l_sub + l_tax WHERE id = l_id;
    IF l_act = 'POST' THEN
      post_invoice(l_id);
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-026', 'فاتورة المورد رقم ' || l_sinv || ' مسجلة سابقاً', 'Supplier invoice already recorded');
  END save_invoice;

  FUNCTION invoice_json(p_invoice_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    IF p_invoice_id IS NULL THEN
      RETURN '{"id":null,"status":"DRAFT","mode":"CREDIT","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":'
          || NVL(TO_CHAR(NOONA_INV_PKG.default_warehouse), 'null') || ',"lines":[]}';
    END IF;
    SELECT JSON_OBJECT('id' VALUE i.id, 'no' VALUE i.doc_no, 'status' VALUE i.status_code, 'type' VALUE i.invoice_type,
             'sup' VALUE i.supplier_account_id, 'supName' VALUE supplier_label(i.supplier_account_id),
             'date' VALUE TO_CHAR(i.gl_date, 'YYYY-MM-DD'), 'supInv' VALUE CASE WHEN i.supplier_invoice_no NOT LIKE '#%' THEN i.supplier_invoice_no END,
             'supDate' VALUE TO_CHAR(i.supplier_invoice_date, 'YYYY-MM-DD'), 'wh' VALUE i.warehouse_id, 'po' VALUE i.purchase_order_id,
             'mode' VALUE i.payment_mode, 'place' VALUE i.settle_place, 'cc' VALUE i.cost_center_id, 'orig' VALUE i.original_invoice_id,
             'subtotal' VALUE i.subtotal, 'tax' VALUE i.tax_amount, 'total' VALUE i.total_amount,
             'open' VALUE (SELECT SUM(open_amount) FROM ap_open_item WHERE invoice_id = i.id AND status_code <> 'CANCELLED'),
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE l.id, 'i' VALUE l.item_id, 'd' VALUE l.description, 'q' VALUE l.quantity,
                                    'p' VALUE l.unit_price, 'disc' VALUE l.discount_amount, 'net' VALUE l.line_amount, 'tx' VALUE l.tax_amount,
                                    'tc' VALUE (SELECT code FROM loc_tax_code WHERE id = l.tax_code_id),
                                    'acc' VALUE CASE WHEN l.item_id IS NULL THEN (SELECT account_code FROM gl_account WHERE id = l.expense_account_id) END,
                                    'cc' VALUE l.cost_center_id, 'lot' VALUE l.lot_no, 'exp' VALUE TO_CHAR(l.expiry_date, 'YYYY-MM-DD'),
                                    'pol' VALUE l.po_line_id, 'n' VALUE (SELECT item_no || ' - ' || name_ar FROM inv_item WHERE id = l.item_id))
                                    ORDER BY l.line_no RETURNING CLOB)
                              FROM ap_invoice_line l WHERE l.invoice_id = i.id) FORMAT JSON
             RETURNING CLOB)
      INTO l FROM ap_invoice i WHERE i.id = p_invoice_id AND i.company_id = company;
    RETURN REPLACE(l, '"lines":null', '"lines":[]');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-025', 'فاتورة المشتريات غير موجودة', 'Purchase invoice not found');
  END invoice_json;

  FUNCTION invoice_from_order(p_order_id IN NUMBER) RETURN CLOB IS
    l  CLOB;
    o  pur_order%ROWTYPE;
  BEGIN
    SELECT * INTO o FROM pur_order WHERE id = p_order_id AND company_id = company;
    NOONA_CORE_PKG.assert(o.status_code IN ('APPROVED', 'ISSUED', 'PARTIALLY_RECEIVED'), 'NOONA-PUR-016',
                          'أمر الشراء غير معتمد أو مستلم بالكامل', 'Order is not open for receipt');
    SELECT JSON_OBJECT('id' VALUE NULL, 'status' VALUE 'DRAFT', 'mode' VALUE 'CREDIT', 'sup' VALUE o.supplier_account_id,
             'supName' VALUE supplier_label(o.supplier_account_id), 'date' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD'),
             'wh' VALUE o.delivery_warehouse_id, 'po' VALUE o.id, 'poNo' VALUE o.doc_no,
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('i' VALUE l.item_id, 'd' VALUE l.description,
                                    'q' VALUE l.quantity - NVL(l.received_qty, 0), 'p' VALUE l.unit_price,
                                    'disc' VALUE ROUND((l.quantity * l.unit_price - l.line_amount) * (l.quantity - NVL(l.received_qty, 0)) / l.quantity, 2),
                                    'tc' VALUE (SELECT code FROM loc_tax_code WHERE id = l.tax_code_id), 'pol' VALUE l.id,
                                    'n' VALUE (SELECT item_no || ' - ' || name_ar FROM inv_item WHERE id = l.item_id))
                                    ORDER BY l.line_no RETURNING CLOB)
                              FROM pur_order_line l WHERE l.order_id = o.id AND l.quantity > NVL(l.received_qty, 0)) FORMAT JSON
             RETURNING CLOB)
      INTO l FROM dual;
    RETURN REPLACE(l, '"lines":null', '"lines":[]');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-014', 'أمر الشراء غير موجود', 'Purchase order not found');
  END invoice_from_order;

  -- إضافة سطر قيد مع دمج نفس الحساب ومركز التكلفة
  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_cc NUMBER,
                     p_party NUMBER, p_desc VARCHAR2, p_item NUMBER DEFAULT NULL) IS
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
    p_lines(p_lines.COUNT).item_id := p_item;
  END add_line;

  FUNCTION cc_for(p_acc NUMBER, p_cc NUMBER, p_wh NUMBER) RETURN NUMBER IS
    l_rule VARCHAR2(30) := NOONA_GL_PKG.cc_rule(p_acc);
    l_cc   NUMBER;
  BEGIN
    IF l_rule = 'FORBIDDEN' THEN RETURN NULL; END IF;
    l_cc := p_cc;
    IF l_cc IS NULL AND l_rule = 'REQUIRED' AND p_wh IS NOT NULL THEN
      SELECT MAX(cost_center_id) INTO l_cc FROM inv_warehouse WHERE id = p_wh;
    END IF;
    RETURN l_cc;
  END cc_for;

  PROCEDURE post_invoice(p_invoice_id IN NUMBER) IS
    l_i     ap_invoice%ROWTYPE;
    l_acc   ap_supplier_account%ROWTYPE;
    l_party NUMBER;
    l_moves NOONA_INV_PKG.t_moves := NOONA_INV_PKG.t_moves();
    l_txn   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_n     NUMBER;
    l_due   NUMBER;
    l_ev    NUMBER;
    l_cr    NUMBER;
    l_desc  VARCHAR2(1000);
    l_x     NUMBER;
  BEGIN
    guard('AP_INVOICE.POST');
    SELECT * INTO l_i FROM ap_invoice WHERE id = p_invoice_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_i.status_code = 'DRAFT', 'NOONA-PUR-022', 'الفاتورة مرحلة أو ملغاة', 'Invoice is not a draft');
    l_acc := get_account(l_i.supplier_account_id);
    l_party := supplier_party(l_acc.id);
    -- فاتورة المورد لا تسجل مرتين
    IF l_i.supplier_invoice_no NOT LIKE '#%' THEN
      SELECT COUNT(*) INTO l_n FROM ap_invoice
       WHERE supplier_account_id = l_i.supplier_account_id AND supplier_invoice_no = l_i.supplier_invoice_no AND id <> l_i.id
         AND invoice_type = 'STANDARD' AND status_code NOT IN ('DRAFT', 'CANCELLED');
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PUR-026', 'فاتورة المورد رقم ' || l_i.supplier_invoice_no || ' مسجلة سابقاً',
                            'Supplier invoice already recorded');
    END IF;
    -- رقم الفاتورة
    UPDATE ap_invoice SET doc_no = NOONA_REFERENCE_PKG.next_doc_no('AP_INVOICE', company, branch_id, gl_date, c_inv, id),
                          duplicate_check_key = supplier_account_id || ':' || supplier_invoice_no
     WHERE id = p_invoice_id
    RETURNING doc_no INTO l_i.doc_no;
    l_desc := 'فاتورة مشتريات ' || l_i.doc_no || ' - ' || supplier_label(l_acc.id)
           || CASE WHEN l_i.supplier_invoice_no NOT LIKE '#%' THEN ' (فاتورة المورد ' || l_i.supplier_invoice_no || ')' END;
    -- الاستلام المخزني بالتكلفة الصافية للوحدة
    FOR r IN (SELECT l.* FROM ap_invoice_line l WHERE l.invoice_id = p_invoice_id AND l.line_type = 'ITEM' ORDER BY l.line_no) LOOP
      l_moves.EXTEND;
      l_moves(l_moves.COUNT).item_id := r.item_id;
      l_moves(l_moves.COUNT).qty := r.quantity;
      l_moves(l_moves.COUNT).unit_cost := ROUND(r.line_amount / r.quantity, 6);
      l_moves(l_moves.COUNT).lot_no := r.lot_no;
      l_moves(l_moves.COUNT).expiry := r.expiry_date;
      l_moves(l_moves.COUNT).line_ref := TO_CHAR(r.id);
      UPDATE inv_item_company SET last_purchase_price = ROUND(r.line_amount / r.quantity, 6)
       WHERE item_id = r.item_id AND company_id = company;
      IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO inv_item_company (company_id, item_id, costing_method, last_purchase_price, is_active)
        VALUES (company, r.item_id, 'WEIGHTED_AVERAGE', ROUND(r.line_amount / r.quantity, 6), 'Y');
      END IF;
    END LOOP;
    IF l_moves.COUNT > 0 THEN
      NOONA_CORE_PKG.assert(l_i.warehouse_id IS NOT NULL, 'NOONA-PUR-027', 'اختر المستودع المستلم', 'Warehouse is required');
      l_txn := NOONA_INV_PKG.move('PURCHASE_RECEIPT', l_i.warehouse_id, l_i.gl_date, c_inv, p_invoice_id, l_moves, l_i.doc_no);
    END IF;
    -- القيد: مدين المخزون/المصروف والضريبة، دائن المورد أو الصندوق
    FOR r IN (SELECT l.* FROM ap_invoice_line l WHERE l.invoice_id = p_invoice_id ORDER BY l.line_no) LOOP
      IF r.line_type = 'ITEM' THEN
        l_x := NOONA_INV_PKG.account_for(r.item_id, 'INVENTORY');
        add_line(l_lines, l_x, r.line_amount, 0, cc_for(l_x, NULL, l_i.warehouse_id), NULL, l_desc);
      ELSE
        add_line(l_lines, r.expense_account_id, r.line_amount, 0,
                 cc_for(r.expense_account_id, NVL(r.cost_center_id, l_i.cost_center_id), l_i.warehouse_id), NULL,
                 NVL(r.description, l_desc), r.item_id);
      END IF;
      IF NVL(r.tax_amount, 0) > 0 THEN
        l_x := NOONA_INV_PKG.tax_account(r.tax_code_id, 'PURCHASE');
        add_line(l_lines, l_x, r.tax_amount, 0, NULL, NULL, 'ضريبة مدخلات ' || l_i.doc_no);
      END IF;
    END LOOP;
    IF l_i.payment_mode = 'CASH' AND l_i.settle_place LIKE 'BOX:%' THEN
      l_x := NOONA_CSH_PKG.balance(TO_NUMBER(SUBSTR(l_i.settle_place, 5)), NULL, l_i.gl_date);
      NOONA_CORE_PKG.assert(l_x >= l_i.total_amount, 'NOONA-PUR-042', 'رصيد الصندوق (' || fmt0(l_x) || ') لا يكفي لسداد الفاتورة',
                            'Insufficient cash box balance');
    END IF;
    l_cr := CASE WHEN l_i.payment_mode = 'CASH' THEN NOONA_CSH_PKG.place_account(l_i.settle_place) ELSE payable_account(l_acc) END;
    add_line(l_lines, l_cr, 0, l_i.total_amount, NULL, CASE WHEN l_i.payment_mode = 'CREDIT' THEN l_party END, l_desc);
    l_j := NOONA_ACE_PKG.post_source('AP_INVOICE_APPROVED', 'PURCHASE', c_inv, p_invoice_id, l_i.gl_date, l_desc,
                                     l_i.currency_code, 1, l_lines, l_i.doc_no, l_i.branch_id, 'PURCHASE_INVOICE');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    -- الذمة أو السداد الفوري
    IF l_i.payment_mode = 'CREDIT' THEN
      SELECT NVL(MAX(due_days), 0) INTO l_due FROM ref_payment_term WHERE id = l_i.payment_term_id;
      INSERT INTO ap_open_item (company_id, branch_id, currency_code, exchange_rate, supplier_account_id, invoice_id, item_type, doc_no, due_date,
                                installment_no, original_amount, open_amount, original_func, open_func, status_code)
      VALUES (company, l_i.branch_id, l_i.currency_code, 1, l_acc.id, p_invoice_id, 'INVOICE', l_i.doc_no, l_i.gl_date + l_due, 1,
              l_i.total_amount, l_i.total_amount, l_i.total_amount, l_i.total_amount, 'OPEN');
    ELSE
      l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', l_i.settle_place, l_i.gl_date, l_i.total_amount, l_party, supplier_label(l_acc.id),
                                             c_inv, p_invoice_id, l_i.doc_no, l_desc, l_ev);
    END IF;
    UPDATE ap_invoice SET status_code = CASE WHEN payment_mode = 'CASH' THEN 'PAID' ELSE 'POSTED' END, inv_transaction_id = l_txn,
                          accounting_event_id = l_ev, posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = p_invoice_id;
    -- أمر الشراء: الكميات المستلمة والحالة
    IF l_i.purchase_order_id IS NOT NULL THEN
      FOR r IN (SELECT po_line_id, SUM(quantity) q FROM ap_invoice_line WHERE invoice_id = p_invoice_id AND po_line_id IS NOT NULL
                 GROUP BY po_line_id) LOOP
        UPDATE pur_order_line SET received_qty = NVL(received_qty, 0) + r.q, invoiced_qty = NVL(invoiced_qty, 0) + r.q,
                                  status_code = CASE WHEN NVL(received_qty, 0) + r.q >= quantity THEN 'RECEIVED' ELSE 'PARTIALLY_RECEIVED' END
         WHERE id = r.po_line_id AND order_id = l_i.purchase_order_id;
      END LOOP;
      SELECT COUNT(*) INTO l_n FROM pur_order_line WHERE order_id = l_i.purchase_order_id AND NVL(received_qty, 0) < quantity;
      UPDATE pur_order SET status_code = CASE WHEN l_n = 0 THEN 'RECEIVED' ELSE 'PARTIALLY_RECEIVED' END WHERE id = l_i.purchase_order_id;
    END IF;
    NOONA_AUDIT_PKG.log_event('POSTING', c_inv, p_invoice_id, 'POST', 'SUCCESS');
    NOONA_API_PKG.publish('AP_INVOICE.POSTED', c_inv, p_invoice_id);
  END post_invoice;

  PROCEDURE cancel_invoice(p_invoice_id IN NUMBER) IS
  BEGIN
    guard('AP_INVOICE.CANCEL');
    UPDATE ap_invoice SET status_code = 'CANCELLED' WHERE id = p_invoice_id AND company_id = company AND status_code = 'DRAFT';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PUR-022', 'تلغى الفاتورة المسودة فقط؛ المرحلة تعالج بالمرتجع', 'Only drafts can be cancelled');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_inv, p_invoice_id, 'CANCEL', 'SUCCESS');
  END cancel_invoice;

  -- ================================================================ المرتجع
  FUNCTION return_doc_json(p_invoice_id IN NUMBER) RETURN CLOB IS
    l_no VARCHAR2(100);
  BEGIN
    SELECT doc_no INTO l_no FROM ap_invoice WHERE id = p_invoice_id AND company_id = company;
    RETURN '{"inv":' || p_invoice_id || ',"no":' || NOONA_CORE_PKG.json_text(l_no) || ',"date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD')
        || '","lines":' || returnable_json(p_invoice_id) || '}';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '{"lines":[]}';
  END return_doc_json;

  FUNCTION returnable_json(p_invoice_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('l' VALUE l.id, 'i' VALUE l.item_id, 'd' VALUE l.description, 'q' VALUE l.quantity,
             'r' VALUE NVL((SELECT SUM(x.quantity) FROM ap_invoice_line x JOIN ap_invoice h ON h.id = x.invoice_id
                             WHERE h.original_invoice_id = l.invoice_id AND h.status_code <> 'CANCELLED' AND x.po_line_id IS NULL
                               AND x.original_line_id = l.id), 0),
             'p' VALUE ROUND(l.line_amount / l.quantity, 6), 'lot' VALUE l.lot_no) ORDER BY l.line_no RETURNING CLOB)
      INTO l FROM ap_invoice_line l WHERE l.invoice_id = p_invoice_id;
    RETURN NVL(l, '[]');
  END returnable_json;

  FUNCTION post_return(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_orig  NUMBER := l_o.get_number('inv');
    l_date  DATE := NVL(d(l_o.get_string('date')), TRUNC(SYSDATE));
    l_rsn   VARCHAR2(400) := l_o.get_string('reason');
    l_place VARCHAR2(30) := l_o.get_string('place');
    l_i     ap_invoice%ROWTYPE;
    l_acc   ap_supplier_account%ROWTYPE;
    l_party NUMBER;
    l_id    NUMBER;
    l_no    PLS_INTEGER := 0;
    l_sub   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_net   NUMBER;
    l_tx    NUMBER;
    l_done  NUMBER;
    l_line  ap_invoice_line%ROWTYPE;
    l_moves NOONA_INV_PKG.t_moves := NOONA_INV_PKG.t_moves();
    l_txn   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_cost  NUMBER := 0;
    l_x     NUMBER;
    l_desc  VARCHAR2(1000);
    l_left  NUMBER;
    l_lot   NUMBER;
  BEGIN
    guard('AP_INVOICE.CREATE');
    guard('AP_INVOICE.POST');
    SELECT * INTO l_i FROM ap_invoice WHERE id = l_orig AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_i.invoice_type = 'STANDARD' AND l_i.status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID'), 'NOONA-PUR-030',
                          'المرتجع من فاتورة مشتريات مرحلة فقط', 'Return requires a posted purchase invoice');
    NOONA_CORE_PKG.assert(TRIM(l_rsn) IS NOT NULL, 'NOONA-PUR-031', 'سبب المرتجع إلزامي', 'Return reason is required');
    IF l_i.payment_mode = 'CASH' THEN
      l_place := NVL(l_place, l_i.settle_place);
    END IF;
    l_acc := get_account(l_i.supplier_account_id);
    l_party := supplier_party(l_acc.id);
    INSERT INTO ap_invoice (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, supplier_account_id, invoice_type,
                            supplier_invoice_no, supplier_invoice_date, gl_date, original_invoice_id, match_status, warehouse_id,
                            payment_mode, settle_place, cost_center_id, status_code)
    VALUES (company, l_i.branch_id, NOONA_REFERENCE_PKG.next_doc_no('AP_DEBIT_NOTE', company, l_i.branch_id, l_date, c_inv, NULL), l_date,
            l_i.currency_code, 1, l_acc.id, 'CREDIT_MEMO', '#R' || RAWTOHEX(SYS_GUID()), l_date, l_date, l_orig, 'NOT_REQUIRED', l_i.warehouse_id,
            l_i.payment_mode, l_place, l_i.cost_center_id, 'DRAFT')
    RETURNING id INTO l_id;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (ln NUMBER PATH '$.l', q NUMBER PATH '$.q'))) LOOP
      CONTINUE WHEN NVL(r.q, 0) = 0;
      BEGIN
        SELECT * INTO l_line FROM ap_invoice_line WHERE id = r.ln AND invoice_id = l_orig;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-PUR-032', 'البند ليس من الفاتورة الأصلية', 'Line is not on the original invoice');
      END;
      SELECT NVL(SUM(x.quantity), 0) INTO l_done FROM ap_invoice_line x JOIN ap_invoice h ON h.id = x.invoice_id
       WHERE h.original_invoice_id = l_orig AND h.status_code <> 'CANCELLED' AND x.original_line_id = l_line.id;
      NOONA_CORE_PKG.assert(r.q > 0 AND r.q <= l_line.quantity - l_done, 'NOONA-PUR-033',
        'كمية المرتجع أكبر من المتبقي (' || fqty(l_line.quantity - l_done) || ') للبند ' || l_line.description, 'Return quantity exceeds remaining');
      l_net := ROUND(l_line.line_amount * r.q / l_line.quantity, 2);
      l_tx := ROUND(NVL(l_line.tax_amount, 0) * r.q / l_line.quantity, 2);
      l_no := l_no + 1;
      INSERT INTO ap_invoice_line (company_id, invoice_id, line_no, line_type, item_id, description, quantity, uom_id, unit_price,
                                   line_amount, tax_code_id, expense_account_id, original_line_id, cost_center_id, discount_amount, tax_amount,
                                   lot_no, expiry_date)
      VALUES (company, l_id, l_no, l_line.line_type, l_line.item_id, l_line.description, r.q, l_line.uom_id, l_line.unit_price, l_net,
              l_line.tax_code_id, l_line.expense_account_id, l_line.id, l_line.cost_center_id,
              ROUND(NVL(l_line.discount_amount, 0) * r.q / l_line.quantity, 2), l_tx, l_line.lot_no, l_line.expiry_date);
      l_sub := l_sub + l_net;
      l_tax := l_tax + l_tx;
      IF l_line.line_type = 'ITEM' THEN
        l_lot := NULL;
        IF l_line.lot_no IS NOT NULL THEN
          SELECT MIN(id) INTO l_lot FROM inv_lot WHERE item_id = l_line.item_id AND lot_no = l_line.lot_no;
        END IF;
        l_moves.EXTEND;
        l_moves(l_moves.COUNT).item_id := l_line.item_id;
        l_moves(l_moves.COUNT).qty := r.q;
        l_moves(l_moves.COUNT).lot_id := l_lot;
        l_moves(l_moves.COUNT).line_ref := TO_CHAR(l_line.id);
        l_moves(l_moves.COUNT).total_cost := l_net;           -- القيمة الصافية المرتجعة (تستبدل بالتكلفة بعد الحركة)
      ELSE
        add_line(l_lines, l_line.expense_account_id, 0, l_net, cc_for(l_line.expense_account_id, l_line.cost_center_id, l_i.warehouse_id),
                 NULL, 'مرتجع ' || l_line.description, l_line.item_id);
      END IF;
      IF l_tx > 0 THEN
        add_line(l_lines, NOONA_INV_PKG.tax_account(l_line.tax_code_id, 'PURCHASE'), 0, l_tx, NULL, NULL, 'عكس ضريبة مدخلات');
      END IF;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-PUR-034', 'حدد كمية مرتجعة لبند واحد على الأقل', 'Return at least one line');
    UPDATE ap_invoice SET subtotal = l_sub, tax_amount = l_tax, total_amount = l_sub + l_tax WHERE id = l_id
    RETURNING doc_no INTO l_desc;
    l_desc := 'مرتجع مشتريات ' || l_desc || ' من الفاتورة ' || l_i.doc_no || ' - ' || supplier_label(l_acc.id) || ': ' || l_rsn;
    -- إخراج المرتجع من المخزون بالمتوسط؛ فرق السعر عن المتوسط إلى تكلفة المبيعات
    IF l_moves.COUNT > 0 THEN
      DECLARE
        l_val NOONA_INV_PKG.t_moves := l_moves;
      BEGIN
        l_txn := NOONA_INV_PKG.move('PURCHASE_RETURN', l_i.warehouse_id, l_date, c_inv, l_id, l_moves, l_rsn);
        FOR k IN 1 .. l_moves.COUNT LOOP
          l_x := NOONA_INV_PKG.account_for(l_moves(k).item_id, 'INVENTORY');
          add_line(l_lines, l_x, 0, l_moves(k).total_cost, cc_for(l_x, NULL, l_i.warehouse_id), NULL, l_desc);
          IF l_val(k).total_cost <> l_moves(k).total_cost THEN
            l_x := NOONA_INV_PKG.account_for(l_moves(k).item_id, 'COGS');
            add_line(l_lines, l_x, GREATEST(l_moves(k).total_cost - l_val(k).total_cost, 0), GREATEST(l_val(k).total_cost - l_moves(k).total_cost, 0),
                     cc_for(l_x, l_i.cost_center_id, l_i.warehouse_id), NULL, 'فرق سعر المرتجع عن متوسط التكلفة');
          END IF;
        END LOOP;
      END;
    END IF;
    l_x := CASE WHEN l_i.payment_mode = 'CASH' THEN NOONA_CSH_PKG.place_account(l_place) ELSE payable_account(l_acc) END;
    add_line(l_lines, l_x, l_sub + l_tax, 0, NULL, CASE WHEN l_i.payment_mode = 'CREDIT' THEN l_party END, l_desc);
    SELECT doc_no INTO l_desc FROM ap_invoice WHERE id = l_id;
    l_j := NOONA_ACE_PKG.post_source('PUR_RETURN_POSTED', 'PURCHASE', c_inv, l_id, l_date,
                                     'مرتجع مشتريات ' || l_desc || ' - ' || supplier_label(l_acc.id) || ': ' || l_rsn,
                                     l_i.currency_code, 1, l_lines, l_desc, l_i.branch_id, 'PURCHASE_RETURN');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    IF l_i.payment_mode = 'CREDIT' THEN
      -- يخفض المتبقي من الفاتورة الأصلية، والزيادة رصيد مدين للمورد
      l_left := l_sub + l_tax;
      FOR oi IN (SELECT id, open_amount FROM ap_open_item WHERE invoice_id = l_orig AND open_amount > 0 FOR UPDATE) LOOP
        l_x := LEAST(oi.open_amount, l_left);
        UPDATE ap_open_item SET open_amount = open_amount - l_x, open_func = open_func - l_x,
                                status_code = CASE WHEN open_amount - l_x = 0 THEN 'PAID' ELSE 'PARTIALLY_PAID' END
         WHERE id = oi.id;
        l_left := l_left - l_x;
      END LOOP;
      INSERT INTO ap_open_item (company_id, branch_id, currency_code, exchange_rate, supplier_account_id, invoice_id, item_type, doc_no, due_date,
                                installment_no, original_amount, open_amount, original_func, open_func, status_code)
      VALUES (company, l_i.branch_id, l_i.currency_code, 1, l_acc.id, l_id, 'CREDIT_MEMO', l_desc, l_date, 1, l_sub + l_tax, l_left,
              l_sub + l_tax, l_left, CASE WHEN l_left = 0 THEN 'PAID' ELSE 'OPEN' END);
      SELECT NVL(SUM(open_amount), 0) INTO l_x FROM ap_open_item WHERE invoice_id = l_orig;
      UPDATE ap_invoice SET status_code = CASE WHEN l_x = 0 THEN 'PAID' ELSE status_code END WHERE id = l_orig;
    ELSE
      l_x := NOONA_CSH_PKG.record_settlement('RECEIPT', l_place, l_date, l_sub + l_tax, l_party, supplier_label(l_acc.id), c_inv, l_id,
                                             l_desc, 'استرداد نقدي لمرتجع مشتريات', l_ev);
    END IF;
    UPDATE ap_invoice SET status_code = 'POSTED', inv_transaction_id = l_txn, accounting_event_id = l_ev, posted_at = SYSTIMESTAMP,
                          posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = l_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_inv, l_id, 'RETURN', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-025', 'فاتورة المشتريات غير موجودة', 'Purchase invoice not found');
  END post_return;

  -- ================================================================ السداد
  FUNCTION open_items_json(p_account_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('inv' VALUE o.invoice_id, 'no' VALUE o.doc_no, 'due' VALUE TO_CHAR(o.due_date, 'YYYY-MM-DD'),
             'amt' VALUE o.original_amount, 'open' VALUE o.open_amount, 'late' VALUE GREATEST(TRUNC(SYSDATE) - o.due_date, 0),
             'sup' VALUE (SELECT CASE WHEN supplier_invoice_no NOT LIKE '#%' THEN supplier_invoice_no END FROM ap_invoice WHERE id = o.invoice_id))
             ORDER BY o.due_date, o.id RETURNING CLOB)
      INTO l FROM ap_open_item o
     WHERE o.supplier_account_id = p_account_id AND o.company_id = company AND o.item_type = 'INVOICE' AND o.open_amount > 0;
    RETURN NVL(l, '[]');
  END open_items_json;

  FUNCTION pay_supplier(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_sup   NUMBER := l_o.get_number('sup');
    l_date  DATE := NVL(d(l_o.get_string('date')), TRUNC(SYSDATE));
    l_amt   NUMBER := ROUND(l_o.get_number('amount'), 2);
    l_place VARCHAR2(30) := l_o.get_string('place');
    l_meth  VARCHAR2(30) := NVL(l_o.get_string('method'), CASE WHEN l_o.get_string('place') LIKE 'BANK:%' THEN 'BANK_APP' ELSE 'CASH' END);
    l_ref   VARCHAR2(200) := l_o.get_string('ref');
    l_notes VARCHAR2(1000) := l_o.get_string('notes');
    l_acc   ap_supplier_account%ROWTYPE;
    l_party NUMBER;
    l_id    NUMBER;
    l_no    VARCHAR2(100);
    l_left  NUMBER;
    l_x     NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_desc  VARCHAR2(1000);
    l_has   BOOLEAN := FALSE;
    l_cash  NUMBER;
    l_open  NUMBER;
    l_mid   NUMBER;
    PROCEDURE apply(p_item NUMBER, p_amt NUMBER) IS
    BEGIN
      UPDATE ap_open_item SET open_amount = open_amount - p_amt, open_func = open_func - p_amt,
                              status_code = CASE WHEN open_amount - p_amt = 0 THEN 'PAID' ELSE 'PARTIALLY_PAID' END
       WHERE id = p_item;
      INSERT INTO ap_payment_application (company_id, payment_id, open_item_id, applied_amount, discount_taken, applied_date, status_code)
      VALUES (company, l_id, p_item, p_amt, 0, l_date, 'APPLIED');
      UPDATE ap_invoice i SET status_code = CASE WHEN (SELECT SUM(open_amount) FROM ap_open_item WHERE invoice_id = i.id) = 0 THEN 'PAID'
                                                 ELSE 'PARTIALLY_PAID' END
       WHERE id = (SELECT invoice_id FROM ap_open_item WHERE id = p_item);
      l_left := l_left - p_amt;
    END apply;
  BEGIN
    guard('AP_PAYMENT.CREATE');
    NOONA_CORE_PKG.assert(l_sup IS NOT NULL, 'NOONA-PUR-010', 'اختر المورد', 'Supplier is required');
    NOONA_CORE_PKG.assert(NVL(l_amt, 0) > 0, 'NOONA-PUR-040', 'مبلغ السداد يجب أن يكون موجباً', 'Amount must be positive');
    NOONA_CORE_PKG.assert(l_place IS NOT NULL, 'NOONA-PUR-041', 'اختر الصندوق أو البنك المسدد منه', 'Choose the cash box or bank');
    l_acc := get_account(l_sup);
    l_party := supplier_party(l_acc.id);
    l_cash := NOONA_CSH_PKG.place_account(l_place);
    -- لا يسدد من الصندوق أكثر من رصيده
    IF l_place LIKE 'BOX:%' THEN
      l_x := NOONA_CSH_PKG.balance(TO_NUMBER(SUBSTR(l_place, 5)), NULL, l_date);
      NOONA_CORE_PKG.assert(l_x >= l_amt, 'NOONA-PUR-042', 'رصيد الصندوق (' || fmt0(l_x) || ') لا يكفي للسداد', 'Insufficient cash box balance');
    END IF;
    l_mid := method_id(l_meth);
    l_no := NOONA_REFERENCE_PKG.next_doc_no('AP_PAYMENT', company, NULL, l_date, c_pay, NULL);
    INSERT INTO ap_payment (company_id, branch_id, doc_no, doc_date, currency_code, exchange_rate, supplier_account_id, payment_method_id,
                            company_bank_account_id, cash_box_id, amount, amount_func, unapplied_amount, status_code)
    VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), l_no, l_date, NOONA_GL_PKG.ledger_currency, 1, l_acc.id, l_mid,
            CASE WHEN l_place LIKE 'BANK:%' THEN TO_NUMBER(SUBSTR(l_place, 6)) END,
            CASE WHEN l_place LIKE 'BOX:%' THEN TO_NUMBER(SUBSTR(l_place, 5)) END, l_amt, l_amt, 0, 'DRAFT')
    RETURNING id INTO l_id;
    l_left := l_amt;
    -- التخصيص المحدد ثم الأقدم استحقاقاً
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.alloc[*]' COLUMNS (inv NUMBER PATH '$.inv', a NUMBER PATH '$.a'))) LOOP
      CONTINUE WHEN NVL(r.a, 0) <= 0;
      l_has := TRUE;
      SELECT MIN(id), NVL(SUM(open_amount), 0) INTO l_x, l_open FROM ap_open_item
       WHERE invoice_id = r.inv AND supplier_account_id = l_acc.id AND item_type = 'INVOICE' AND open_amount > 0;
      NOONA_CORE_PKG.assert(l_x IS NOT NULL AND r.a <= l_open AND r.a <= l_left, 'NOONA-PUR-043',
                            'مبلغ التخصيص أكبر من المتبقي على الفاتورة أو من مبلغ السداد', 'Allocation exceeds open amount');
      apply(l_x, ROUND(r.a, 2));
    END LOOP;
    IF NOT l_has THEN
      FOR oi IN (SELECT id, open_amount FROM ap_open_item
                  WHERE supplier_account_id = l_acc.id AND company_id = company AND item_type = 'INVOICE' AND open_amount > 0
                  ORDER BY due_date, id FOR UPDATE) LOOP
        EXIT WHEN l_left <= 0;
        apply(oi.id, LEAST(oi.open_amount, l_left));
      END LOOP;
    END IF;
    l_desc := 'سداد للمورد ' || supplier_label(l_acc.id) || ' ' || l_no || NVL2(l_ref, ' مرجع ' || l_ref, '') || NVL2(l_notes, ': ' || l_notes, '');
    add_line(l_lines, payable_account(l_acc), l_amt, 0, NULL, l_party, l_desc);
    add_line(l_lines, l_cash, 0, l_amt, NULL, NULL, l_desc);
    l_j := NOONA_ACE_PKG.post_source('AP_PAYMENT_SETTLED', 'PURCHASE', c_pay, l_id, l_date, l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                     l_lines, l_no, NULL, 'SUPPLIER_PAYMENT');
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', l_place, l_date, l_amt, l_party, supplier_label(l_acc.id), c_pay, l_id, l_no, l_desc, l_ev);
    UPDATE ap_payment SET status_code = 'SETTLED', unapplied_amount = l_left, cash_transaction_id = l_x, accounting_event_id = l_ev,
                          posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = l_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_pay, l_id, 'SETTLE', 'SUCCESS');
    RETURN l_id;
  END pay_supplier;

  FUNCTION reverse_payment(p_payment_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_p ap_payment%ROWTYPE;
    l_j NUMBER;
  BEGIN
    guard('AP_PAYMENT.REVERSE');
    SELECT * INTO l_p FROM ap_payment WHERE id = p_payment_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_p.status_code = 'SETTLED', 'NOONA-PUR-044', 'يعكس السداد المنفذ فقط', 'Only settled payments can be reversed');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-PUR-045', 'سبب العكس إلزامي', 'Reason is required');
    l_j := NOONA_ACE_PKG.reverse_source(c_pay, p_payment_id, NVL(p_date, TRUNC(SYSDATE)), p_reason);
    FOR a IN (SELECT id, open_item_id, applied_amount FROM ap_payment_application WHERE payment_id = p_payment_id AND status_code = 'APPLIED') LOOP
      UPDATE ap_open_item SET open_amount = open_amount + a.applied_amount, open_func = open_func + a.applied_amount,
                              status_code = CASE WHEN open_amount + a.applied_amount = original_amount THEN 'OPEN' ELSE 'PARTIALLY_PAID' END
       WHERE id = a.open_item_id;
      UPDATE ap_payment_application SET status_code = 'UNAPPLIED' WHERE id = a.id;
      UPDATE ap_invoice i SET status_code = CASE WHEN (SELECT SUM(open_amount) FROM ap_open_item WHERE invoice_id = i.id) = i.total_amount
                                                 THEN 'POSTED' ELSE 'PARTIALLY_PAID' END
       WHERE id = (SELECT invoice_id FROM ap_open_item WHERE id = a.open_item_id);
    END LOOP;
    UPDATE ap_payment SET status_code = 'REVERSED', failure_reason = SUBSTR(p_reason, 1, 400) WHERE id = p_payment_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_pay, p_payment_id, 'REVERSE', 'SUCCESS');
    RETURN l_j;
  END reverse_payment;

  -- ================================================================ التقارير
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_class VARCHAR2 DEFAULT '') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div>'
        || '<div class="nn-kpi-value">' || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION pur_summary RETURN CLOB IS
    l_month NUMBER; l_open NUMBER; l_over NUMBER; l_po NUMBER; l_sup NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE WHEN invoice_type = 'CREDIT_MEMO' THEN -total_amount ELSE total_amount END), 0) INTO l_month
      FROM ap_invoice WHERE company_id = company AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID')
       AND gl_date >= TRUNC(SYSDATE, 'MM');
    SELECT NVL(SUM(CASE WHEN item_type = 'CREDIT_MEMO' THEN -open_amount ELSE open_amount END), 0),
           NVL(SUM(CASE WHEN item_type = 'INVOICE' AND due_date < TRUNC(SYSDATE) THEN open_amount END), 0)
      INTO l_open, l_over FROM ap_open_item WHERE company_id = company AND open_amount > 0;
    SELECT COUNT(*) INTO l_po FROM pur_order WHERE company_id = company AND status_code IN ('APPROVED', 'PARTIALLY_RECEIVED');
    SELECT COUNT(*) INTO l_sup FROM ap_supplier_account WHERE company_id = company AND status_code = 'ACTIVE';
    RETURN '<div class="nn-kpis">' || kpi('مشتريات الشهر', fmt0(l_month), 'fa-shopping-cart')
        || kpi('مستحق للموردين', fmt0(l_open), 'fa-balance-scale')
        || kpi('متأخر السداد', fmt0(l_over), 'fa-exclamation-triangle', CASE WHEN l_over > 0 THEN 'is-danger' END)
        || kpi('أوامر شراء مفتوحة', l_po, 'fa-file-text-o') || kpi('الموردون النشطون', l_sup, 'fa-truck') || '</div>';
  END pur_summary;

  FUNCTION supplier_statement(p_account_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_html CLOB;
    l_open NUMBER;
    l_bal  NUMBER;
    l_dr   NUMBER := 0;
    l_cr   NUMBER := 0;
  BEGIN
    guard('AP_INVOICE.VIEW');
    IF p_account_id IS NULL THEN RETURN '<div class="nn-empty">اختر المورد</div>'; END IF;
    l_open := supplier_balance(p_account_id, p_from - 1);
    l_bal := l_open;
    l_html := NOONA_BRAND_PKG.report_header('كشف حساب مورد: ' || supplier_label(p_account_id) || ' من ' || TO_CHAR(p_from, 'YYYY-MM-DD')
                                            || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>المستند</th><th>البيان</th><th>مدين (سداد ومرتجع)</th>'
           || '<th>دائن (مشتريات)</th><th>الرصيد</th></tr></thead><tbody>'
           || '<tr class="nn-rpt-group"><td colspan="5">الرصيد الافتتاحي</td><td>' || fmt0(l_open) || '</td></tr>';
    FOR r IN (SELECT gl_date d, doc_no, CASE WHEN invoice_type = 'CREDIT_MEMO' THEN 'مرتجع مشتريات' ELSE 'فاتورة مشتريات ' || mode_label(payment_mode) END
                     || CASE WHEN supplier_invoice_no NOT LIKE '#%' THEN ' (' || supplier_invoice_no || ')' END txt,
                     CASE WHEN invoice_type = 'CREDIT_MEMO' THEN total_amount ELSE 0 END dr,
                     CASE WHEN invoice_type = 'CREDIT_MEMO' THEN 0 ELSE total_amount END cr, payment_mode, 1 o, id
                FROM ap_invoice WHERE supplier_account_id = p_account_id AND company_id = company
                 AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID') AND gl_date BETWEEN p_from AND p_to
              UNION ALL
              SELECT NVL(doc_date, due_date), doc_no, CASE WHEN item_type = 'CREDIT_MEMO' THEN 'رصيد افتتاحي مدين' ELSE 'رصيد مستحق' END,
                     CASE WHEN item_type = 'CREDIT_MEMO' THEN original_amount ELSE 0 END,
                     CASE WHEN item_type = 'CREDIT_MEMO' THEN 0 ELSE original_amount END, 'CREDIT', 1, id
                FROM ap_open_item WHERE supplier_account_id = p_account_id AND company_id = company AND invoice_id IS NULL
                 AND item_type IN ('INVOICE', 'CREDIT_MEMO') AND status_code <> 'CANCELLED' AND NVL(doc_date, due_date) BETWEEN p_from AND p_to
              UNION ALL
              -- الفاتورة النقدية تسدد فوراً
              SELECT gl_date, doc_no, 'سداد نقدي للفاتورة', CASE WHEN invoice_type = 'CREDIT_MEMO' THEN 0 ELSE total_amount END,
                     CASE WHEN invoice_type = 'CREDIT_MEMO' THEN total_amount ELSE 0 END, 'CASH', 2, id
                FROM ap_invoice WHERE supplier_account_id = p_account_id AND company_id = company AND payment_mode = 'CASH'
                 AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID') AND gl_date BETWEEN p_from AND p_to
              UNION ALL
              SELECT doc_date, doc_no, 'سداد' || CASE WHEN status_code = 'REVERSED' THEN ' (معكوس)' END, amount, 0, 'CREDIT', 3, id
                FROM ap_payment WHERE supplier_account_id = p_account_id AND company_id = company AND status_code IN ('SETTLED', 'REVERSED')
                 AND doc_date BETWEEN p_from AND p_to
              UNION ALL
              SELECT e.accounting_date, p.doc_no, 'عكس سداد', 0, p.amount, 'CREDIT', 4, p.id
                FROM ap_payment p JOIN ace_accounting_event o ON o.id = p.accounting_event_id
                JOIN ace_accounting_event e ON e.reversal_of_event_id = o.id
               WHERE p.supplier_account_id = p_account_id AND p.company_id = company AND p.status_code = 'REVERSED'
                 AND e.accounting_date BETWEEN p_from AND p_to
               ORDER BY 1, 7, 8) LOOP
      IF r.payment_mode = 'CREDIT' THEN
        l_bal := l_bal + r.cr - r.dr;
      END IF;
      l_dr := l_dr + r.dr;
      l_cr := l_cr + r.cr;
      l_html := l_html || (('<tr><td>' || TO_CHAR(r.d, 'YYYY-MM-DD') || '</td><td>' || esc(r.doc_no) || '</td><td class="nn-rpt-text">'
             || esc(r.txt) || '</td><td>' || fmt(r.dr) || '</td><td>' || fmt(r.cr) || '</td><td>' || fmt0(l_bal) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="3">الإجمالي والرصيد المستحق للمورد</td><td>' || fmt0(l_dr) || '</td><td>'
        || fmt0(l_cr) || '</td><td>' || fmt0(l_bal) || '</td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('الرصيد الموجب مستحق للمورد؛ الفواتير النقدية تظهر مع سدادها ولا تؤثر في الرصيد')));
  END supplier_statement;

  FUNCTION ap_aging(p_as_of IN DATE DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_d    DATE := NVL(p_as_of, TRUNC(SYSDATE));
    l_html CLOB;
    t      NUMBER := 0; t0 NUMBER := 0; t1 NUMBER := 0; t2 NUMBER := 0; t3 NUMBER := 0; t4 NUMBER := 0;
  BEGIN
    guard('AP_INVOICE.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('أعمار ديون الموردين في ' || TO_CHAR(l_d, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>المورد</th><th>غير مستحق</th><th>1-30</th><th>31-60</th><th>61-90</th><th>أكثر من 90</th>'
           || '<th>الإجمالي</th></tr></thead><tbody>';
    FOR r IN (SELECT o.supplier_account_id sid,
                     SUM(CASE WHEN o.item_type = 'CREDIT_MEMO' THEN -o.open_amount ELSE o.open_amount END) tot,
                     SUM(CASE WHEN o.item_type = 'CREDIT_MEMO' THEN -o.open_amount WHEN o.due_date >= l_d THEN o.open_amount ELSE 0 END) b0,
                     SUM(CASE WHEN o.item_type = 'INVOICE' AND l_d - o.due_date BETWEEN 1 AND 30 THEN o.open_amount ELSE 0 END) b1,
                     SUM(CASE WHEN o.item_type = 'INVOICE' AND l_d - o.due_date BETWEEN 31 AND 60 THEN o.open_amount ELSE 0 END) b2,
                     SUM(CASE WHEN o.item_type = 'INVOICE' AND l_d - o.due_date BETWEEN 61 AND 90 THEN o.open_amount ELSE 0 END) b3,
                     SUM(CASE WHEN o.item_type = 'INVOICE' AND l_d - o.due_date > 90 THEN o.open_amount ELSE 0 END) b4
                FROM ap_open_item o WHERE o.company_id = company AND o.open_amount > 0
               GROUP BY o.supplier_account_id ORDER BY 2 DESC) LOOP
      t := t + r.tot; t0 := t0 + r.b0; t1 := t1 + r.b1; t2 := t2 + r.b2; t3 := t3 + r.b3; t4 := t4 + r.b4;
      l_html := l_html || (('<tr><td class="nn-rpt-text">'
             || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.sid) || '">' || esc(supplier_label(r.sid)) || '</a>'
                     ELSE esc(supplier_label(r.sid)) END
             || '</td><td>' || fmt(r.b0) || '</td><td>' || fmt(r.b1) || '</td><td>' || fmt(r.b2) || '</td><td>' || fmt(r.b3)
             || '</td><td' || CASE WHEN r.b4 > 0 THEN ' class="nn-rpt-bad"' END || '>' || fmt(r.b4) || '</td><td><b>' || fmt(r.tot) || '</b></td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td>الإجمالي</td><td>' || fmt0(t0) || '</td><td>' || fmt0(t1) || '</td><td>' || fmt0(t2)
        || '</td><td>' || fmt0(t3) || '</td><td>' || fmt0(t4) || '</td><td>' || fmt0(t) || '</td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('حسب تاريخ الاستحقاق من شروط الدفع؛ المرتجعات غير المسواة تخصم من غير المستحق')));
  END ap_aging;

  FUNCTION purchase_register(p_from IN DATE, p_to IN DATE, p_account_id IN NUMBER DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0; s2 NUMBER := 0; s3 NUMBER := 0;
    l_sg NUMBER;
  BEGIN
    guard('AP_INVOICE.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('سجل المشتريات من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>رقم الفاتورة</th><th>النوع</th><th>المورد</th><th>فاتورة المورد</th>'
           || '<th>الطريقة</th><th>الصافي</th><th>الضريبة</th><th>الإجمالي</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT id, gl_date, doc_no, invoice_type, supplier_account_id, supplier_invoice_no, payment_mode, subtotal, tax_amount,
                     total_amount, status_code
                FROM ap_invoice WHERE company_id = company AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID')
                 AND gl_date BETWEEN p_from AND p_to AND (p_account_id IS NULL OR supplier_account_id = p_account_id)
               ORDER BY gl_date, id) LOOP
      l_sg := CASE WHEN r.invoice_type = 'CREDIT_MEMO' THEN -1 ELSE 1 END;
      s1 := s1 + l_sg * r.subtotal; s2 := s2 + l_sg * r.tax_amount; s3 := s3 + l_sg * r.total_amount;
      l_html := l_html || (('<tr' || CASE WHEN l_sg < 0 THEN ' class="nn-rpt-warn"' END || '><td>' || TO_CHAR(r.gl_date, 'YYYY-MM-DD') || '</td><td>'
             || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(r.doc_no) || '</a>' ELSE esc(r.doc_no) END
             || '</td><td>' || CASE WHEN l_sg < 0 THEN 'مرتجع' ELSE 'فاتورة' END || '</td><td class="nn-rpt-text">'
             || esc(supplier_label(r.supplier_account_id)) || '</td><td>' || esc(CASE WHEN r.supplier_invoice_no NOT LIKE '#%' THEN r.supplier_invoice_no END) || '</td><td>'
             || mode_label(r.payment_mode) || '</td><td>' || fmt(l_sg * r.subtotal) || '</td><td>' || fmt(l_sg * r.tax_amount) || '</td><td>'
             || fmt(l_sg * r.total_amount) || '</td><td>' || status_label(r.status_code) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="6">صافي المشتريات</td><td>' || fmt0(s1) || '</td><td>' || fmt0(s2) || '</td><td>'
        || fmt0(s3) || '</td><td></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('الفواتير والمرتجعات المرحلة؛ الضريبة هي ضريبة المدخلات القابلة للاسترداد')));
  END purchase_register;

  FUNCTION purchases_by_item(p_from IN DATE, p_to IN DATE, p_category_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0;
  BEGIN
    guard('AP_INVOICE.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('المشتريات حسب الصنف من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>الصنف</th><th>الفئة</th><th>الكمية</th><th>متوسط السعر</th><th>أقل سعر</th><th>أعلى سعر</th>'
           || '<th>الصافي</th><th>عدد الموردين</th></tr></thead><tbody>';
    FOR r IN (SELECT i.item_no || ' - ' || i.name_ar item, g.name_ar cat,
                     SUM(CASE WHEN h.invoice_type = 'CREDIT_MEMO' THEN -l.quantity ELSE l.quantity END) q,
                     SUM(CASE WHEN h.invoice_type = 'CREDIT_MEMO' THEN -l.line_amount ELSE l.line_amount END) amt,
                     MIN(CASE WHEN h.invoice_type = 'STANDARD' THEN l.line_amount / l.quantity END) mn,
                     MAX(CASE WHEN h.invoice_type = 'STANDARD' THEN l.line_amount / l.quantity END) mx,
                     COUNT(DISTINCT h.supplier_account_id) sups
                FROM ap_invoice_line l JOIN ap_invoice h ON h.id = l.invoice_id JOIN inv_item i ON i.id = l.item_id
                JOIN inv_item_category g ON g.id = i.category_id
               WHERE h.company_id = company AND h.status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID') AND h.gl_date BETWEEN p_from AND p_to
                 AND (p_category_id IS NULL OR i.category_id = p_category_id)
               GROUP BY i.item_no, i.name_ar, g.name_ar ORDER BY 4 DESC) LOOP
      s1 := s1 + r.amt;
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(r.item) || '</td><td>' || esc(r.cat) || '</td><td>' || fqty(r.q) || '</td><td>'
             || fmt(CASE WHEN r.q <> 0 THEN r.amt / r.q END) || '</td><td>' || fmt(r.mn) || '</td><td>' || fmt(r.mx) || '</td><td>' || fmt(r.amt)
             || '</td><td>' || r.sups || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="6">الإجمالي</td><td>' || fmt0(s1) || '</td><td></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('الأصناف فقط (بدون بنود المصروفات)، بعد خصم المرتجعات')));
  END purchases_by_item;

  FUNCTION invoice_print(p_invoice_id IN NUMBER) RETURN CLOB IS
    l_i    ap_invoice%ROWTYPE;
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    guard('AP_INVOICE.VIEW');
    SELECT * INTO l_i FROM ap_invoice WHERE id = p_invoice_id AND company_id = company;
    l_html := NOONA_BRAND_PKG.report_header(CASE WHEN l_i.invoice_type = 'CREDIT_MEMO' THEN 'إشعار مرتجع مشتريات' ELSE 'فاتورة مشتريات' END
                                            || ' ' || l_i.doc_no, l_i.company_id, l_i.branch_id)
           || '<table class="nn-rpt nn-rpt-meta"><tbody><tr><th>المورد</th><td>' || esc(supplier_label(l_i.supplier_account_id))
           || '</td><th>التاريخ</th><td>' || TO_CHAR(l_i.gl_date, 'YYYY-MM-DD') || '</td></tr><tr><th>فاتورة المورد</th><td>'
           || esc(CASE WHEN l_i.supplier_invoice_no NOT LIKE '#%' THEN l_i.supplier_invoice_no END) || '</td><th>الطريقة</th><td>' || mode_label(l_i.payment_mode) || '</td></tr></tbody></table>'
           || '<table class="nn-rpt"><thead><tr><th>#</th><th>البند</th><th>الكمية</th><th>السعر</th><th>الخصم</th><th>الصافي</th><th>الضريبة</th>'
           || '<th>الإجمالي</th></tr></thead><tbody>';
    FOR r IN (SELECT l.*, (SELECT item_no FROM inv_item WHERE id = l.item_id) ino FROM ap_invoice_line l
               WHERE l.invoice_id = p_invoice_id ORDER BY l.line_no) LOOP
      l_n := l_n + 1;
      l_html := l_html || (('<tr><td>' || l_n || '</td><td class="nn-rpt-text">' || esc(NVL2(r.ino, r.ino || ' - ', '') || r.description)
             || CASE WHEN r.lot_no IS NOT NULL THEN ' <small>دفعة ' || esc(r.lot_no) || NVL2(r.expiry_date, ' تنتهي ' || TO_CHAR(r.expiry_date, 'YYYY-MM-DD'), '') || '</small>' END
             || '</td><td>' || fqty(r.quantity) || '</td><td>' || fmt(r.unit_price) || '</td><td>' || fmt(r.discount_amount) || '</td><td>'
             || fmt(r.line_amount) || '</td><td>' || fmt(r.tax_amount) || '</td><td>' || fmt(r.line_amount + NVL(r.tax_amount, 0)) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="5">الإجمالي</td><td>' || fmt0(l_i.subtotal) || '</td><td>' || fmt0(l_i.tax_amount)
        || '</td><td>' || fmt0(l_i.total_amount) || '</td></tr></tfoot></table>'
        || '<p class="nn-rpt-words">' || esc(NOONA_CSH_PKG.amount_words(l_i.total_amount, l_i.currency_code)) || '</p>'
        || NOONA_BRAND_PKG.doc_footer('أعده|المحاسب|المدير المعتمد', l_i.company_id, l_i.branch_id)));
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PUR-025', 'فاتورة المشتريات غير موجودة', 'Purchase invoice not found');
  END invoice_print;

END NOONA_PUR_PKG;
/
