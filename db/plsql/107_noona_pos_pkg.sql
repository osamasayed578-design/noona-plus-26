-- =============================================================================
-- NOONA PLUS ERP | نقاط البيع: NOONA_POS_PKG
--   المحطات والورديات، تحميل أولي واحد للأصناف والأسعار وطرق السداد (البحث بالباركود في المتصفح بلا انتظار)،
--   البيع بطلب واحد (مفتاح منع التكرار)، السداد المختلط: نقدي، مدى، بطاقات، Apple Pay، STC Pay، تطبيقات بنكية، آجل،
--   العميل النقدي العام افتراضياً، الصرف الفوري من المخزون بالأقدم انتهاءً، المرتجع بالإيصال،
--   إقفال الوردية بقيد واحد (نوع مبيعات نقاط البيع) مع فروقات الجرد النقدي، تقرير X والإيصال الحراري برمز ZATCA.
-- =============================================================================

CREATE OR REPLACE PACKAGE NOONA_POS_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  FUNCTION cashier_member RETURN NUMBER;
  -- درج نقدي ومحطة افتراضية على المستودع الرئيسي
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION create_terminal(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_warehouse_id IN NUMBER, p_cash_box_id IN NUMBER,
                           p_bank_account_id IN NUMBER DEFAULT NULL, p_cost_center_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION terminals_json RETURN CLOB;

  -- ---------------------------------------------------------- الورديات
  FUNCTION open_shift(p_terminal_id IN NUMBER, p_float IN NUMBER DEFAULT 0) RETURN NUMBER;
  FUNCTION current_shift(p_terminal_id IN NUMBER) RETURN NUMBER;
  -- حركة درج: CASH_IN / CASH_OUT / SAFE_DROP / PAYOUT
  PROCEDURE cash_movement(p_shift_id IN NUMBER, p_type IN VARCHAR2, p_amount IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION expected_cash(p_shift_id IN NUMBER) RETURN NUMBER;
  -- إقفال الوردية: قيد واحد للوردية؛ يعيد رقم القيد
  FUNCTION close_shift(p_shift_id IN NUMBER, p_counted_cash IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- البيع
  -- كل ما تحتاجه الشاشة مرة واحدة: المحطة، الوردية، العميل العام، طرق السداد، الأصناف (الباركودات والأسعار والضريبة والرصيد)
  FUNCTION boot_json(p_terminal_id IN NUMBER) RETURN CLOB;
  -- {"key":"uuid","shift":1,"cust":null,"rx":"","lines":[{"i":5,"q":2,"p":null,"disc":0,"b":"628..."}],
  --  "pays":[{"m":"CASH","a":50},{"m":"MADA","a":20,"ref":"123456"}]}
  -- يعيد {"ok":true,"id","no","total","tax","paid","change","qr"}
  FUNCTION sale(p_doc IN CLOB) RETURN CLOB;
  -- {"key","shift","orig":saleId,"lines":[{"l":lineId,"q":1}],"pays":[{"m":"CASH","a":10}]}
  FUNCTION return_sale(p_doc IN CLOB) RETURN CLOB;
  FUNCTION find_receipt(p_receipt_no IN VARCHAR2) RETURN CLOB;

  -- ---------------------------------------------------------- التقارير
  FUNCTION receipt_html(p_sale_id IN NUMBER) RETURN CLOB;
  FUNCTION x_report(p_shift_id IN NUMBER) RETURN CLOB;
  FUNCTION pos_sales_report(p_from IN DATE, p_to IN DATE, p_terminal_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION pos_summary RETURN CLOB;
END NOONA_POS_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_POS_PKG AS

  c_shift CONSTANT VARCHAR2(30) := 'POS_SHIFT';
  c_sale  CONSTANT VARCHAR2(30) := 'POS_SALE';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  FUNCTION cashier_member RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')); END;
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
  FUNCTION fnum(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN NVL(TO_CHAR(p, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0');
  END fnum;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  -- ================================================================ التجهيز
  FUNCTION create_terminal(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_warehouse_id IN NUMBER, p_cash_box_id IN NUMBER,
                           p_bank_account_id IN NUMBER DEFAULT NULL, p_cost_center_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    guard('POS_TERMINAL.CREATE');
    NOONA_CORE_PKG.assert(p_warehouse_id IS NOT NULL AND p_cash_box_id IS NOT NULL, 'NOONA-POS-001',
                          'المستودع والدرج النقدي إلزاميان للمحطة', 'Warehouse and cash drawer are required');
    INSERT INTO pos_terminal (company_id, branch_id, code, name_ar, warehouse_id, cash_box_id, bank_account_id, cost_center_id,
                              offline_allowed, local_number_prefix, status_code)
    VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), UPPER(TRIM(p_code)), p_name_ar, p_warehouse_id, p_cash_box_id,
            p_bank_account_id, p_cost_center_id, 'N', UPPER(TRIM(p_code)), 'ACTIVE')
    RETURNING id INTO l;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'POS_TERMINAL', l, 'CREATE', 'SUCCESS');
    RETURN l;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-POS-002', 'رمز المحطة مستخدم', 'Terminal code already exists');
  END create_terminal;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n    NUMBER;
    l_box  NUMBER;
    l_bank NUMBER;
    l_x    NUMBER;
  BEGIN
    guard('POS_TERMINAL.CREATE');
    l_n := NOONA_SAL_PKG.quick_setup;
    NOONA_INV_PKG.ensure_sequence('POS_SALE', 'R-');
    SELECT COUNT(*) INTO l_x FROM pos_terminal WHERE company_id = company;
    IF l_x = 0 THEN
      SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = company AND box_type = 'POS_DRAWER' AND status_code = 'ACTIVE';
      IF l_box IS NULL THEN
        l_box := NOONA_CSH_PKG.create_cash_box('POS-01', 'درج نقطة البيع 1', '1101', 'POS_DRAWER');
      END IF;
      SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE';
      l_x := create_terminal('T01', 'نقطة البيع 1', NOONA_INV_PKG.default_warehouse, l_box, l_bank, NULL);
      l_n := l_n + 1;
    END IF;
    RETURN l_n;
  END quick_setup;

  FUNCTION terminals_json RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE t.id, 'code' VALUE t.code, 'n' VALUE t.name_ar, 'wh' VALUE w.name_ar,
             'shift' VALUE (SELECT MAX(s.id) FROM pos_shift s WHERE s.terminal_id = t.id AND s.status_code = 'OPEN')) ORDER BY t.code RETURNING CLOB)
      INTO l FROM pos_terminal t JOIN inv_warehouse w ON w.id = t.warehouse_id WHERE t.company_id = company AND t.status_code = 'ACTIVE';
    RETURN NVL(l, '[]');
  END terminals_json;

  -- ================================================================ الورديات
  FUNCTION current_shift(p_terminal_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM pos_shift WHERE terminal_id = p_terminal_id AND company_id = company AND status_code = 'OPEN';
    RETURN l;
  END current_shift;

  FUNCTION open_shift(p_terminal_id IN NUMBER, p_float IN NUMBER DEFAULT 0) RETURN NUMBER IS
    l_t pos_terminal%ROWTYPE;
    l   NUMBER := current_shift(p_terminal_id);
    l_m NUMBER;
  BEGIN
    guard('POS_SHIFT.CREATE');
    IF l IS NOT NULL THEN
      SELECT cashier_member_id INTO l_m FROM pos_shift WHERE id = l;
      NOONA_CORE_PKG.assert(l_m = cashier_member, 'NOONA-POS-010', 'المحطة عليها وردية مفتوحة لكاشير آخر؛ يجب إقفالها أولاً',
                            'Terminal has an open shift of another cashier');
      RETURN l;
    END IF;
    SELECT * INTO l_t FROM pos_terminal WHERE id = p_terminal_id AND company_id = company AND status_code = 'ACTIVE';
    INSERT INTO pos_shift (company_id, terminal_id, cashier_member_id, cash_box_id, opened_at, opening_float, sales_total, status_code)
    VALUES (company, p_terminal_id, cashier_member, l_t.cash_box_id, SYSTIMESTAMP, NVL(p_float, 0), 0, 'OPEN')
    RETURNING id INTO l;
    IF NVL(p_float, 0) > 0 THEN
      INSERT INTO pos_cash_movement (company_id, shift_id, movement_type, amount, reason)
      VALUES (company, l, 'FLOAT_IN', p_float, 'رصيد افتتاح الوردية');
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_shift, l, 'OPEN', 'SUCCESS');
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-POS-003', 'المحطة غير موجودة أو غير نشطة', 'Terminal not found');
  END open_shift;

  FUNCTION get_shift(p_shift_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN pos_shift%ROWTYPE IS
    l pos_shift%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM pos_shift WHERE id = p_shift_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM pos_shift WHERE id = p_shift_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-POS-011', 'الوردية غير موجودة', 'Shift not found');
  END get_shift;

  PROCEDURE cash_movement(p_shift_id IN NUMBER, p_type IN VARCHAR2, p_amount IN NUMBER, p_reason IN VARCHAR2) IS
    l_s pos_shift%ROWTYPE := get_shift(p_shift_id);
  BEGIN
    guard('POS_SHIFT.UPDATE');
    NOONA_CORE_PKG.assert(l_s.status_code = 'OPEN', 'NOONA-POS-012', 'الوردية مقفلة', 'Shift is closed');
    NOONA_CORE_PKG.assert(p_type IN ('CASH_IN', 'CASH_OUT', 'SAFE_DROP', 'PAYOUT') AND NVL(p_amount, 0) > 0 AND TRIM(p_reason) IS NOT NULL,
                          'NOONA-POS-013', 'حدد نوع الحركة والمبلغ والسبب', 'Type, amount and reason are required');
    NOONA_CORE_PKG.assert(p_type = 'CASH_IN' OR expected_cash(p_shift_id) >= p_amount, 'NOONA-POS-014',
                          'النقد في الدرج لا يكفي', 'Not enough cash in drawer');
    INSERT INTO pos_cash_movement (company_id, shift_id, movement_type, amount, reason, approved_by_member_id)
    VALUES (company, p_shift_id, p_type, p_amount, p_reason, cashier_member);
  END cash_movement;

  FUNCTION method_type(p_method_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT method_type INTO l FROM ref_payment_method WHERE id = p_method_id;
    RETURN l;
  END method_type;

  FUNCTION expected_cash(p_shift_id IN NUMBER) RETURN NUMBER IS
    l_s    pos_shift%ROWTYPE := get_shift(p_shift_id);
    l_cash NUMBER;
    l_mv   NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE WHEN s.sale_type = 'RETURN' THEN -p.amount ELSE p.amount END), 0) - NVL(SUM(CASE WHEN s.sale_type <> 'RETURN' THEN 0 END), 0)
      INTO l_cash
      FROM pos_payment p JOIN pos_sale s ON s.id = p.sale_id JOIN ref_payment_method m ON m.id = p.payment_method_id
     WHERE s.shift_id = p_shift_id AND m.method_type = 'CASH' AND p.status_code IN ('APPROVED', 'REFUNDED');
    -- الباقي المرتجع للعميل يخصم من النقد
    SELECT l_cash - NVL(SUM(change_amount), 0) INTO l_cash FROM pos_sale WHERE shift_id = p_shift_id AND sale_type = 'SALE';
    SELECT NVL(SUM(CASE WHEN movement_type IN ('CASH_IN') THEN amount WHEN movement_type = 'FLOAT_IN' THEN 0 ELSE -amount END), 0)
      INTO l_mv FROM pos_cash_movement WHERE shift_id = p_shift_id;
    RETURN NVL(l_s.opening_float, 0) + l_cash + l_mv;
  END expected_cash;

  -- ================================================================ التحميل الأولي
  FUNCTION boot_json(p_terminal_id IN NUMBER) RETURN CLOB IS
    l_t     pos_terminal%ROWTYPE;
    l_items CLOB;
    l_out   CLOB;
    l_vat   NUMBER := NOONA_INV_PKG.tax_id('VAT15');
    l_d     DATE := TRUNC(SYSDATE);
    l_co    NUMBER := company;
    l_walk  NUMBER;
  BEGIN
    guard('POS_SALE.CREATE');
    SELECT * INTO l_t FROM pos_terminal WHERE id = p_terminal_id AND company_id = company;
    l_walk := NOONA_SAL_PKG.walk_in_customer;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE x.id, 'no' VALUE x.item_no, 'c' VALUE x.item_code, 'n' VALUE x.name_ar, 'b' VALUE x.bars,
             'p' VALUE x.sale_price, 'inc' VALUE x.incl, 't' VALUE x.rate, 'q' VALUE x.qty, 'rx' VALUE x.rx, 'st' VALUE x.stocked,
             'g' VALUE x.generic_name, 'mpn' VALUE x.manufacturer_part_no) RETURNING CLOB)
      INTO l_items
      FROM (SELECT i.id, i.item_no, i.item_code, i.name_ar, i.generic_name, i.manufacturer_part_no, i.requires_prescription rx,
                   (SELECT LISTAGG(b.barcode, ' ') WITHIN GROUP (ORDER BY b.id) FROM inv_item_barcode b WHERE b.item_id = i.id AND b.is_active = 'Y') bars,
                   c.sale_price, NVL(c.prices_include_tax, 'N') incl,
                   NVL((SELECT MAX(r.rate_pct) KEEP (DENSE_RANK LAST ORDER BY r.version_no) FROM loc_tax_rate r
                         WHERE r.tax_code_id = NVL(c.sales_tax_code_id, l_vat) AND r.effective_from <= l_d
                           AND (r.effective_to IS NULL OR r.effective_to >= l_d)), 0) rate,
                   CASE WHEN i.item_type IN ('SERVICE', 'NON_STOCK') THEN 'N' ELSE 'Y' END stocked,
                   (SELECT NVL(SUM(o.on_hand_qty), 0) FROM inv_onhand o WHERE o.item_id = i.id AND o.company_id = l_co
                       AND o.warehouse_id = l_t.warehouse_id) qty
              FROM inv_item i JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = l_co
             WHERE i.status_code = 'ACTIVE' AND i.is_sellable = 'Y' AND c.sale_price IS NOT NULL) x;
    SELECT JSON_OBJECT('terminal' VALUE JSON_OBJECT('id' VALUE l_t.id, 'code' VALUE l_t.code, 'n' VALUE l_t.name_ar),
             'shift' VALUE current_shift(p_terminal_id), 'walkIn' VALUE l_walk,
             'walkInName' VALUE NOONA_SAL_PKG.customer_label(l_walk),
             'seller' VALUE NOONA_SAL_PKG.seller_name, 'vat' VALUE NOONA_SAL_PKG.seller_vat,
             'methods' VALUE NOONA_PUR_PKG.payment_methods_json FORMAT JSON,
             'items' VALUE NVL(l_items, TO_CLOB('[]')) FORMAT JSON RETURNING CLOB)
      INTO l_out FROM dual;
    RETURN l_out;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-POS-003', 'المحطة غير موجودة أو غير نشطة', 'Terminal not found');
  END boot_json;

  -- ================================================================ البيع
  FUNCTION result_json(p_sale_id NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_OBJECT('ok' VALUE 'true' FORMAT JSON, 'id' VALUE s.id, 'no' VALUE s.receipt_no, 'type' VALUE s.sale_type,
             'total' VALUE s.total_amount, 'tax' VALUE s.tax_amount, 'paid' VALUE s.paid_amount, 'change' VALUE s.change_amount,
             'qr' VALUE NOONA_SAL_PKG.zatca_qr(s.sale_at, s.total_amount, s.tax_amount) RETURNING CLOB)
      INTO l FROM pos_sale s WHERE s.id = p_sale_id;
    RETURN l;
  END result_json;

  FUNCTION existing(p_key VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM pos_sale WHERE sync_idempotency_key = p_key;
    RETURN l;
  END existing;

  FUNCTION method_id(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM ref_payment_method WHERE code = p_code AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-POS-020', 'طريقة السداد غير معرفة: ' || p_code, 'Unknown payment method');
    RETURN l;
  END method_id;

  FUNCTION sale(p_doc IN CLOB) RETURN CLOB IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_key   VARCHAR2(100) := l_o.get_string('key');
    l_shift NUMBER := l_o.get_number('shift');
    l_cust  NUMBER := l_o.get_number('cust');
    l_rx    VARCHAR2(50) := TRIM(l_o.get_string('rx'));
    l_s     pos_shift%ROWTYPE;
    l_t     pos_terminal%ROWTYPE;
    l_id    NUMBER;
    l_no    PLS_INTEGER := 0;
    l_sub   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_dis   NUMBER := 0;
    l_net   NUMBER;
    l_tx    NUMBER;
    l_p     NUMBER;
    l_inc   VARCHAR2(1);
    l_tc    NUMBER;
    l_uom   NUMBER;
    l_rxn   NUMBER := 0;
    l_total NUMBER;
    l_paid  NUMBER := 0;
    l_cash  NUMBER := 0;
    l_cred  NUMBER := 0;
    l_mid   NUMBER;
    l_mt    VARCHAR2(30);
    l_moves NOONA_INV_PKG.t_moves := NOONA_INV_PKG.t_moves();
    l_txn   NUMBER;
    l_rno   VARCHAR2(50);
    l_line  NUMBER;
  BEGIN
    guard('POS_SALE.CREATE');
    NOONA_CORE_PKG.assert(TRIM(l_key) IS NOT NULL, 'NOONA-POS-021', 'مفتاح العملية مفقود', 'Idempotency key is required');
    l_id := existing(l_key);
    IF l_id IS NOT NULL THEN RETURN result_json(l_id); END IF;           -- إعادة الإرسال بعد انقطاع: نفس الإيصال
    l_s := get_shift(l_shift);
    NOONA_CORE_PKG.assert(l_s.status_code = 'OPEN', 'NOONA-POS-012', 'الوردية مقفلة؛ افتح وردية جديدة', 'Shift is closed');
    NOONA_CORE_PKG.assert(l_s.cashier_member_id = cashier_member, 'NOONA-POS-015', 'الوردية لكاشير آخر', 'Shift belongs to another cashier');
    SELECT * INTO l_t FROM pos_terminal WHERE id = l_s.terminal_id;
    l_cust := NVL(l_cust, NOONA_SAL_PKG.walk_in_customer);
    l_rno := NOONA_REFERENCE_PKG.next_doc_no('POS_SALE', company, l_t.branch_id, TRUNC(SYSDATE), c_sale, NULL);
    INSERT INTO pos_sale (company_id, branch_id, currency_code, exchange_rate, shift_id, terminal_id, receipt_no, sale_type, customer_account_id,
                          sale_at, is_offline, sync_idempotency_key, prescription_no, status_code)
    VALUES (company, l_t.branch_id, NOONA_GL_PKG.ledger_currency, 1, l_shift, l_t.id, l_rno, 'SALE', l_cust, SYSTIMESTAMP, 'N', l_key, l_rx, 'OPEN')
    RETURNING id INTO l_id;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q', p NUMBER PATH '$.p',
                inc VARCHAR2(1) PATH '$.inc', disc NUMBER PATH '$.disc', b VARCHAR2(100) PATH '$.b'))) LOOP
      CONTINUE WHEN r.i IS NULL;
      l_p := r.p; l_inc := CASE WHEN r.p IS NOT NULL THEN r.inc END; l_tc := NULL;
      NOONA_SAL_PKG.price_line(r.i, r.q, l_p, r.disc, l_inc, l_tc, TRUNC(SYSDATE), l_net, l_tx);
      SELECT base_uom_id, l_rxn + CASE WHEN requires_prescription = 'Y' THEN 1 ELSE 0 END INTO l_uom, l_rxn FROM inv_item WHERE id = r.i;
      l_no := l_no + 1;
      INSERT INTO pos_sale_line (company_id, sale_id, line_no, item_id, barcode_scanned, quantity, uom_id, unit_price, discount_amount, tax_code_id,
                                 tax_amount, line_total)
      VALUES (company, l_id, l_no, r.i, r.b, r.q, l_uom, l_p, NVL(r.disc, 0), l_tc, l_tx, l_net + l_tx)
      RETURNING id INTO l_line;
      l_sub := l_sub + l_net; l_tax := l_tax + l_tx; l_dis := l_dis + NVL(r.disc, 0);
      IF NOONA_INV_PKG.is_stocked(r.i) = 'Y' THEN
        l_moves.EXTEND;
        l_moves(l_moves.COUNT).item_id := r.i;
        l_moves(l_moves.COUNT).qty := r.q;
        l_moves(l_moves.COUNT).line_ref := TO_CHAR(l_line);
      END IF;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-POS-022', 'السلة فارغة', 'Cart is empty');
    NOONA_CORE_PKG.assert(l_rxn = 0 OR l_rx IS NOT NULL, 'NOONA-SAL-030', 'السلة تحتوي دواءً لا يصرف إلا بوصفة طبية؛ أدخل رقم الوصفة',
                          'Prescription number is required');
    l_total := l_sub + l_tax;
    -- المدفوعات: غير النقدي لا يتجاوز الإجمالي، والباقي من النقد فقط
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.pays[*]' COLUMNS (m VARCHAR2(30) PATH '$.m', a NUMBER PATH '$.a', rf VARCHAR2(100) PATH '$.ref',
                l4 VARCHAR2(4) PATH '$.last4'))) LOOP
      CONTINUE WHEN NVL(r.a, 0) <= 0;
      l_mid := method_id(r.m);
      l_mt := method_type(l_mid);
      IF l_mt = 'CASH' THEN l_cash := l_cash + r.a; ELSIF l_mt = 'CREDIT' THEN l_cred := l_cred + r.a; END IF;
      l_paid := l_paid + r.a;
      INSERT INTO pos_payment (company_id, sale_id, payment_method_id, amount, card_last4, approval_code, terminal_reference, status_code)
      VALUES (company, l_id, l_mid, ROUND(r.a, 2), r.l4, r.rf, r.rf, 'APPROVED');
    END LOOP;
    l_paid := ROUND(l_paid, 2);
    NOONA_CORE_PKG.assert(l_paid >= l_total, 'NOONA-POS-023', 'المدفوع (' || fmt0(l_paid) || ') أقل من الإجمالي (' || fmt0(l_total) || ')',
                          'Paid amount is less than total');
    NOONA_CORE_PKG.assert(l_paid - l_total <= l_cash, 'NOONA-POS-024', 'الدفع الإلكتروني أو الآجل أكبر من المطلوب؛ الباقي يرد من النقد فقط',
                          'Change can only be given from cash');
    IF l_cred > 0 THEN
      NOONA_SAL_PKG.check_credit(l_cust, l_cred);
    END IF;
    -- صرف المخزون فوراً (FEFO، لا تباع دفعة منتهية)
    IF l_moves.COUNT > 0 THEN
      l_txn := NOONA_INV_PKG.move('POS_ISSUE', l_t.warehouse_id, TRUNC(SYSDATE), c_sale, l_id, l_moves, l_rno);
      FOR k IN 1 .. l_moves.COUNT LOOP
        UPDATE pos_sale_line SET unit_cost = ROUND(l_moves(k).total_cost / l_moves(k).qty, 6),
                                 lot_id = l_moves(k).lot_id
         WHERE id = TO_NUMBER(l_moves(k).line_ref);
      END LOOP;
    END IF;
    -- البيع الآجل: ذمة على العميل
    IF l_cred > 0 THEN
      INSERT INTO ar_open_item (company_id, branch_id, source_entity_type, source_entity_id, currency_code, exchange_rate, customer_account_id,
                                item_type, doc_no, doc_date, due_date, installment_no, original_amount, open_amount, original_func, open_func,
                                status_code)
      SELECT company, l_t.branch_id, c_sale, l_id, NOONA_GL_PKG.ledger_currency, 1, l_cust, 'INVOICE', l_rno, TRUNC(SYSDATE),
             TRUNC(SYSDATE) + NVL((SELECT due_days FROM ref_payment_term t WHERE t.id = a.payment_term_id), 0), 1, l_cred, l_cred, l_cred,
             l_cred, 'OPEN'
        FROM ar_customer_account a WHERE a.id = l_cust;
    END IF;
    UPDATE pos_sale SET subtotal = l_sub, discount_amount = l_dis, tax_amount = l_tax, total_amount = l_total, paid_amount = l_paid,
                        change_amount = l_paid - l_total, inv_transaction_id = l_txn, status_code = 'COMPLETED'
     WHERE id = l_id;
    UPDATE pos_shift SET sales_total = NVL(sales_total, 0) + l_total WHERE id = l_shift;
    RETURN result_json(l_id);
  END sale;

  FUNCTION return_sale(p_doc IN CLOB) RETURN CLOB IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_key   VARCHAR2(100) := l_o.get_string('key');
    l_shift NUMBER := l_o.get_number('shift');
    l_orig  NUMBER := l_o.get_number('orig');
    l_s     pos_shift%ROWTYPE;
    l_os    pos_sale%ROWTYPE;
    l_id    NUMBER;
    l_no    PLS_INTEGER := 0;
    l_line  pos_sale_line%ROWTYPE;
    l_done  NUMBER;
    l_net   NUMBER;
    l_tx    NUMBER;
    l_sub   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_total NUMBER;
    l_paid  NUMBER := 0;
    l_cred  NUMBER := 0;
    l_cash  NUMBER := 0;
    l_mid   NUMBER;
    l_mt    VARCHAR2(30);
    l_moves NOONA_INV_PKG.t_moves := NOONA_INV_PKG.t_moves();
    l_txn   NUMBER;
    l_rno   VARCHAR2(50);
    l_nl    NUMBER;
    l_x     NUMBER;
    l_rem   NUMBER;
  BEGIN
    guard('POS_SALE.CREATE');
    l_id := existing(l_key);
    IF l_id IS NOT NULL THEN RETURN result_json(l_id); END IF;
    l_s := get_shift(l_shift);
    NOONA_CORE_PKG.assert(l_s.status_code = 'OPEN' AND l_s.cashier_member_id = cashier_member, 'NOONA-POS-012', 'الوردية مقفلة أو لكاشير آخر',
                          'Shift is not open for this cashier');
    BEGIN
      SELECT * INTO l_os FROM pos_sale WHERE id = l_orig AND company_id = company FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-POS-030', 'الإيصال الأصلي غير موجود', 'Original receipt not found');
    END;
    NOONA_CORE_PKG.assert(l_os.sale_type = 'SALE' AND l_os.status_code IN ('COMPLETED', 'PARTIALLY_RETURNED'), 'NOONA-POS-031',
                          'الإيصال مرتجع بالكامل أو غير صالح للإرجاع', 'Receipt cannot be returned');
    l_rno := NOONA_REFERENCE_PKG.next_doc_no('POS_SALE', company, l_os.branch_id, TRUNC(SYSDATE), c_sale, NULL);
    INSERT INTO pos_sale (company_id, branch_id, currency_code, exchange_rate, shift_id, terminal_id, receipt_no, sale_type, original_sale_id,
                          customer_account_id, sale_at, is_offline, sync_idempotency_key, status_code)
    VALUES (company, l_os.branch_id, l_os.currency_code, 1, l_shift, l_s.terminal_id, l_rno, 'RETURN', l_orig, l_os.customer_account_id,
            SYSTIMESTAMP, 'N', NVL(l_key, 'RET-' || RAWTOHEX(SYS_GUID())), 'OPEN')
    RETURNING id INTO l_id;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (ln NUMBER PATH '$.l', q NUMBER PATH '$.q'))) LOOP
      CONTINUE WHEN NVL(r.q, 0) = 0;
      BEGIN
        SELECT * INTO l_line FROM pos_sale_line WHERE id = r.ln AND sale_id = l_orig;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-POS-032', 'البند ليس من الإيصال الأصلي', 'Line is not on the original receipt');
      END;
      SELECT NVL(SUM(x.quantity), 0) INTO l_done FROM pos_sale_line x JOIN pos_sale h ON h.id = x.sale_id
       WHERE h.original_sale_id = l_orig AND x.original_line_id = l_line.id;
      NOONA_CORE_PKG.assert(r.q > 0 AND r.q <= l_line.quantity - l_done, 'NOONA-POS-033',
        'كمية المرتجع أكبر من المتبقي (' || fqty(l_line.quantity - l_done) || ')', 'Return quantity exceeds remaining');
      l_tx := ROUND(l_line.tax_amount * r.q / l_line.quantity, 2);
      l_net := ROUND(l_line.line_total * r.q / l_line.quantity, 2) - l_tx;
      l_no := l_no + 1;
      INSERT INTO pos_sale_line (company_id, sale_id, line_no, item_id, quantity, uom_id, unit_price, discount_amount, tax_code_id, tax_amount,
                                 line_total, lot_id, unit_cost, original_line_id)
      VALUES (company, l_id, l_no, l_line.item_id, r.q, l_line.uom_id, l_line.unit_price,
              ROUND(l_line.discount_amount * r.q / l_line.quantity, 2), l_line.tax_code_id, l_tx, l_net + l_tx, l_line.lot_id, l_line.unit_cost,
              l_line.id)
      RETURNING id INTO l_nl;
      l_sub := l_sub + l_net; l_tax := l_tax + l_tx;
      IF NOONA_INV_PKG.is_stocked(l_line.item_id) = 'Y' THEN
        l_moves.EXTEND;
        l_moves(l_moves.COUNT).item_id := l_line.item_id;
        l_moves(l_moves.COUNT).qty := r.q;
        l_moves(l_moves.COUNT).unit_cost := NVL(l_line.unit_cost, 0);
        l_moves(l_moves.COUNT).lot_id := l_line.lot_id;
        l_moves(l_moves.COUNT).line_ref := TO_CHAR(l_nl);
      END IF;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-POS-034', 'حدد كمية مرتجعة', 'Return at least one line');
    l_total := l_sub + l_tax;
    -- الرد: بنفس الطرق المحددة، أو نقداً، والآجل يخفض ذمة الإيصال
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.pays[*]' COLUMNS (m VARCHAR2(30) PATH '$.m', a NUMBER PATH '$.a'))) LOOP
      CONTINUE WHEN NVL(r.a, 0) <= 0;
      l_mid := method_id(r.m);
      l_mt := method_type(l_mid);
      IF l_mt = 'CREDIT' THEN l_cred := l_cred + r.a; ELSIF l_mt = 'CASH' THEN l_cash := l_cash + r.a; END IF;
      l_paid := l_paid + r.a;
      INSERT INTO pos_payment (company_id, sale_id, payment_method_id, amount, status_code) VALUES (company, l_id, l_mid, ROUND(r.a, 2), 'REFUNDED');
    END LOOP;
    IF l_paid = 0 THEN
      l_mid := method_id('CASH');
      l_cash := l_total;
      INSERT INTO pos_payment (company_id, sale_id, payment_method_id, amount, status_code) VALUES (company, l_id, l_mid, l_total, 'REFUNDED');
      l_paid := l_total;
    END IF;
    NOONA_CORE_PKG.assert(ROUND(l_paid, 2) = l_total, 'NOONA-POS-035', 'مبلغ الرد (' || fmt0(l_paid) || ') لا يساوي قيمة المرتجع ('
                          || fmt0(l_total) || ')', 'Refund must equal return total');
    NOONA_CORE_PKG.assert(l_cash <= expected_cash(l_shift), 'NOONA-POS-014', 'النقد في الدرج لا يكفي للرد', 'Not enough cash in drawer');
    IF l_cred > 0 THEN
      l_rem := NOONA_SAL_PKG.settle_open(c_sale, l_orig, l_cred);
      NOONA_CORE_PKG.assert(l_rem = 0, 'NOONA-POS-036', 'الرد على الحساب أكبر من المتبقي آجلاً على الإيصال', 'Credit refund exceeds open amount');
      INSERT INTO ar_open_item (company_id, branch_id, source_entity_type, source_entity_id, currency_code, exchange_rate, customer_account_id,
                                item_type, doc_no, doc_date, due_date, installment_no, original_amount, open_amount, original_func, open_func,
                                status_code)
      VALUES (company, l_os.branch_id, c_sale, l_id, l_os.currency_code, 1, l_os.customer_account_id, 'CREDIT_NOTE', l_rno, TRUNC(SYSDATE),
              TRUNC(SYSDATE), 1, l_cred, 0, l_cred, 0, 'PAID');
    END IF;
    IF l_moves.COUNT > 0 THEN
      SELECT warehouse_id INTO l_x FROM pos_terminal WHERE id = l_s.terminal_id;
      l_txn := NOONA_INV_PKG.move('POS_RETURN', l_x, TRUNC(SYSDATE), c_sale, l_id, l_moves, l_rno);
    END IF;
    UPDATE pos_sale SET subtotal = l_sub, tax_amount = l_tax, total_amount = l_total, paid_amount = l_total, change_amount = 0,
                        inv_transaction_id = l_txn, status_code = 'COMPLETED'
     WHERE id = l_id;
    SELECT NVL(SUM(l.quantity), 0) - NVL(SUM((SELECT SUM(x.quantity) FROM pos_sale_line x JOIN pos_sale h ON h.id = x.sale_id
                                               WHERE h.original_sale_id = l_orig AND x.original_line_id = l.id)), 0)
      INTO l_x FROM pos_sale_line l WHERE l.sale_id = l_orig;
    UPDATE pos_sale SET status_code = CASE WHEN l_x <= 0 THEN 'RETURNED' ELSE 'PARTIALLY_RETURNED' END WHERE id = l_orig;
    UPDATE pos_shift SET sales_total = NVL(sales_total, 0) - l_total WHERE id = l_shift;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_sale, l_id, 'RETURN', 'SUCCESS');
    RETURN result_json(l_id);
  END return_sale;

  FUNCTION find_receipt(p_receipt_no IN VARCHAR2) RETURN CLOB IS
    l CLOB;
  BEGIN
    guard('POS_SALE.VIEW');
    SELECT JSON_OBJECT('id' VALUE s.id, 'no' VALUE s.receipt_no, 'at' VALUE TO_CHAR(s.sale_at, 'YYYY-MM-DD HH24:MI'), 'status' VALUE s.status_code,
             'total' VALUE s.total_amount, 'cust' VALUE NOONA_SAL_PKG.customer_label(s.customer_account_id),
             'credit' VALUE (SELECT NVL(SUM(open_amount), 0) FROM ar_open_item WHERE source_entity_type = c_sale AND source_entity_id = s.id),
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('l' VALUE l.id, 'n' VALUE i.name_ar, 'q' VALUE l.quantity,
                                    'r' VALUE NVL((SELECT SUM(x.quantity) FROM pos_sale_line x JOIN pos_sale h ON h.id = x.sale_id
                                                    WHERE h.original_sale_id = s.id AND x.original_line_id = l.id), 0),
                                    'u' VALUE ROUND(l.line_total / l.quantity, 4)) ORDER BY l.line_no RETURNING CLOB)
                              FROM pos_sale_line l JOIN inv_item i ON i.id = l.item_id WHERE l.sale_id = s.id) FORMAT JSON RETURNING CLOB)
      INTO l FROM pos_sale s WHERE s.receipt_no = TRIM(p_receipt_no) AND s.company_id = company AND s.sale_type = 'SALE';
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-POS-030', 'الإيصال غير موجود', 'Receipt not found');
  END find_receipt;

  -- ================================================================ إقفال الوردية
  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_cc NUMBER, p_party NUMBER,
                     p_desc VARCHAR2) IS
    l_dr NUMBER := NVL(p_dr, 0);
    l_cr NUMBER := NVL(p_cr, 0);
  BEGIN
    -- المبالغ السالبة تقلب الجانب
    IF l_dr < 0 THEN l_cr := l_cr - l_dr; l_dr := 0; END IF;
    IF l_cr < 0 THEN l_dr := l_dr - l_cr; l_cr := 0; END IF;
    IF l_dr = 0 AND l_cr = 0 THEN RETURN; END IF;
    FOR i IN 1 .. p_lines.COUNT LOOP
      IF p_lines(i).account_id = p_acc AND NVL(p_lines(i).cost_center_id, 0) = NVL(p_cc, 0) AND NVL(p_lines(i).party_id, 0) = NVL(p_party, 0) THEN
        p_lines(i).debit := p_lines(i).debit + l_dr;
        p_lines(i).credit := p_lines(i).credit + l_cr;
        -- صافي السطر في جانب واحد
        IF p_lines(i).debit >= p_lines(i).credit THEN
          p_lines(i).debit := p_lines(i).debit - p_lines(i).credit; p_lines(i).credit := 0;
        ELSE
          p_lines(i).credit := p_lines(i).credit - p_lines(i).debit; p_lines(i).debit := 0;
        END IF;
        RETURN;
      END IF;
    END LOOP;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := l_dr;
    p_lines(p_lines.COUNT).credit := l_cr;
    p_lines(p_lines.COUNT).cost_center_id := p_cc;
    p_lines(p_lines.COUNT).party_id := p_party;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
  END add_line;

  FUNCTION cc(p_acc NUMBER, p_cc NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN NOONA_GL_PKG.cc_rule(p_acc) = 'FORBIDDEN' THEN NULL ELSE p_cc END;
  END cc;

  FUNCTION close_shift(p_shift_id IN NUMBER, p_counted_cash IN NUMBER) RETURN NUMBER IS
    l_s     pos_shift%ROWTYPE := get_shift(p_shift_id, TRUE);
    l_t     pos_terminal%ROWTYPE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_exp   NUMBER;
    l_var   NUMBER;
    l_box   NUMBER;
    l_bank  NUMBER;
    l_cashn NUMBER := 0;
    l_bankn NUMBER := 0;
    l_j     NUMBER := NULL;
    l_ev    NUMBER;
    l_x     NUMBER;
    l_sg    NUMBER;
    l_ret   NUMBER := NOONA_INV_PKG.acc_id('4102');
    l_desc  VARCHAR2(1000);
    l_cc    NUMBER;
    l_n     NUMBER;
    l_mv    NUMBER;
  BEGIN
    guard('POS_SHIFT.UPDATE');
    NOONA_CORE_PKG.assert(l_s.status_code = 'OPEN', 'NOONA-POS-012', 'الوردية مقفلة', 'Shift is closed');
    NOONA_CORE_PKG.assert(p_counted_cash IS NOT NULL AND p_counted_cash >= 0, 'NOONA-POS-040', 'أدخل النقد المعدود في الدرج',
                          'Counted cash is required');
    SELECT * INTO l_t FROM pos_terminal WHERE id = l_s.terminal_id;
    l_cc := l_t.cost_center_id;
    l_exp := expected_cash(p_shift_id);
    l_var := ROUND(p_counted_cash - l_exp, 2);
    l_box := NOONA_CSH_PKG.place_account('BOX:' || l_s.cash_box_id);
    l_bank := CASE WHEN l_t.bank_account_id IS NOT NULL THEN NOONA_CSH_PKG.place_account('BANK:' || l_t.bank_account_id)
                   ELSE NOONA_INV_PKG.acc_id('1102') END;
    l_desc := 'مبيعات نقطة البيع ' || l_t.name_ar || ' - وردية ' || p_shift_id || ' (' || TO_CHAR(l_s.opened_at, 'YYYY-MM-DD HH24:MI') || ')';
    SELECT COUNT(*) INTO l_n FROM pos_sale WHERE shift_id = p_shift_id AND status_code <> 'OPEN';
    -- الإيراد والضريبة (المرتجعات مدينة لحساب مردودات المبيعات)
    FOR r IN (SELECT s.sale_type, NOONA_INV_PKG.account_for(l.item_id, 'REVENUE') rev, l.tax_code_id,
                     SUM(l.line_total - l.tax_amount) net, SUM(l.tax_amount) tax, SUM(l.quantity * NVL(l.unit_cost, 0)) cost,
                     NOONA_INV_PKG.account_for(l.item_id, 'COGS') cogs, NOONA_INV_PKG.account_for(l.item_id, 'INVENTORY') inv
                FROM pos_sale_line l JOIN pos_sale s ON s.id = l.sale_id
               WHERE s.shift_id = p_shift_id AND s.status_code <> 'OPEN'
               GROUP BY s.sale_type, NOONA_INV_PKG.account_for(l.item_id, 'REVENUE'), l.tax_code_id,
                        NOONA_INV_PKG.account_for(l.item_id, 'COGS'), NOONA_INV_PKG.account_for(l.item_id, 'INVENTORY')) LOOP
      l_sg := CASE WHEN r.sale_type = 'RETURN' THEN -1 ELSE 1 END;
      IF l_sg > 0 THEN
        add_line(l_lines, r.rev, 0, r.net, cc(r.rev, l_cc), NULL, l_desc);
      ELSE
        add_line(l_lines, NVL(l_ret, r.rev), r.net, 0, cc(NVL(l_ret, r.rev), l_cc), NULL, 'مرتجعات ' || l_desc);
      END IF;
      IF r.tax <> 0 THEN
        add_line(l_lines, NOONA_INV_PKG.tax_account(r.tax_code_id, 'SALE'), 0, l_sg * r.tax, NULL, NULL, 'ضريبة مخرجات ' || l_desc);
      END IF;
      IF r.cost <> 0 THEN
        add_line(l_lines, r.cogs, l_sg * r.cost, 0, cc(r.cogs, l_cc), NULL, 'تكلفة ' || l_desc);
        add_line(l_lines, r.inv, 0, l_sg * r.cost, NULL, NULL, 'تكلفة ' || l_desc);
      END IF;
    END LOOP;
    -- المتحصلات حسب نوع الطريقة
    FOR r IN (SELECT m.method_type, s.customer_account_id, SUM(CASE WHEN s.sale_type = 'RETURN' THEN -p.amount ELSE p.amount END) amt
                FROM pos_payment p JOIN pos_sale s ON s.id = p.sale_id JOIN ref_payment_method m ON m.id = p.payment_method_id
               WHERE s.shift_id = p_shift_id AND s.status_code <> 'OPEN'
               GROUP BY m.method_type, CASE WHEN m.method_type = 'CREDIT' THEN s.customer_account_id END, s.customer_account_id) LOOP
      IF r.method_type = 'CASH' THEN
        l_cashn := l_cashn + r.amt;
      ELSIF r.method_type = 'CREDIT' THEN
        SELECT NVL(MAX(receivable_account_id), NOONA_INV_PKG.acc_id('1103')) INTO l_x FROM ar_customer_account WHERE id = r.customer_account_id;
        add_line(l_lines, l_x, r.amt, 0, NULL, NOONA_SAL_PKG.customer_party(r.customer_account_id), 'آجل ' || l_desc);
      ELSE
        l_bankn := l_bankn + r.amt;
      END IF;
    END LOOP;
    SELECT NVL(SUM(change_amount), 0) INTO l_x FROM pos_sale WHERE shift_id = p_shift_id AND sale_type = 'SALE' AND status_code <> 'OPEN';
    l_cashn := l_cashn - l_x;
    -- حركات الدرج تؤثر في الدرج نفسه (تحويل داخلي)، والصرف النثري مصروف متنوع
    SELECT NVL(SUM(amount), 0) INTO l_mv FROM pos_cash_movement WHERE shift_id = p_shift_id AND movement_type = 'PAYOUT';
    IF l_mv > 0 THEN
      add_line(l_lines, NOONA_INV_PKG.acc_id('5299'), l_mv, 0, cc(NOONA_INV_PKG.acc_id('5299'), l_cc), NULL, 'مصروفات نثرية من الدرج');
      l_cashn := l_cashn - l_mv;
    END IF;
    -- فروقات الجرد النقدي
    IF l_var < 0 THEN
      add_line(l_lines, NOONA_INV_PKG.acc_id('5299'), -l_var, 0, cc(NOONA_INV_PKG.acc_id('5299'), l_cc), NULL, 'عجز نقدية الوردية');
    ELSIF l_var > 0 THEN
      add_line(l_lines, NOONA_INV_PKG.acc_id('4201'), 0, l_var, cc(NOONA_INV_PKG.acc_id('4201'), l_cc), NULL, 'زيادة نقدية الوردية');
    END IF;
    l_cashn := l_cashn + l_var;
    add_line(l_lines, l_box, l_cashn, 0, NULL, NULL, 'نقدية ' || l_desc);
    add_line(l_lines, l_bank, l_bankn, 0, NULL, NULL, 'مدفوعات إلكترونية (مدى/بطاقات/محافظ/تطبيقات بنكية) ' || l_desc);
    IF l_lines.COUNT >= 2 THEN
      l_j := NOONA_ACE_PKG.post_source('POS_SHIFT_CLOSED', 'POS', c_shift, p_shift_id, TRUNC(SYSDATE), l_desc, NOONA_GL_PKG.ledger_currency, 1,
                                       l_lines, 'SH-' || p_shift_id, l_t.branch_id, 'POS_SALE');
      SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
      IF l_cashn <> 0 THEN
        l_x := NOONA_CSH_PKG.record_settlement(CASE WHEN l_cashn > 0 THEN 'RECEIPT' ELSE 'PAYMENT' END, 'BOX:' || l_s.cash_box_id, TRUNC(SYSDATE),
                                               ABS(l_cashn), NULL, 'مبيعات نقطة البيع', c_shift, p_shift_id, 'SH-' || p_shift_id, l_desc, l_ev);
      END IF;
      IF l_bankn <> 0 AND l_t.bank_account_id IS NOT NULL THEN
        l_x := NOONA_CSH_PKG.record_settlement(CASE WHEN l_bankn > 0 THEN 'RECEIPT' ELSE 'PAYMENT' END, 'BANK:' || l_t.bank_account_id,
                                               TRUNC(SYSDATE), ABS(l_bankn), NULL, 'مبيعات نقطة البيع', c_shift, p_shift_id, 'SH-' || p_shift_id || '-B',
                                               l_desc, l_ev, 'CARD');
      END IF;
      UPDATE pos_sale SET accounting_event_id = l_ev, posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name
       WHERE shift_id = p_shift_id AND status_code <> 'OPEN';
    END IF;
    UPDATE pos_shift SET status_code = 'CLOSED', closed_at = SYSTIMESTAMP, expected_cash = l_exp, counted_cash = p_counted_cash,
                         variance_amount = l_var, gl_journal_id = l_j
     WHERE id = p_shift_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_shift, p_shift_id, 'CLOSE', 'SUCCESS',
      p_new_values => '{"sales":' || l_n || ',"expected":' || fnum(l_exp) || ',"counted":' || fnum(p_counted_cash) || '}');
    RETURN l_j;
  END close_shift;

  -- ================================================================ التقارير
  FUNCTION receipt_html(p_sale_id IN NUMBER) RETURN CLOB IS
    l_s    pos_sale%ROWTYPE;
    l_html CLOB;
    l_t    pos_terminal%ROWTYPE;
  BEGIN
    guard('POS_SALE.VIEW');
    SELECT * INTO l_s FROM pos_sale WHERE id = p_sale_id AND company_id = company;
    SELECT * INTO l_t FROM pos_terminal WHERE id = l_s.terminal_id;
    l_html := '<div class="nn-receipt"><div class="nn-rc-head"><b>' || esc(NOONA_SAL_PKG.seller_name) || '</b><br>الرقم الضريبي: '
           || esc(NOONA_SAL_PKG.seller_vat) || '<br>' || CASE WHEN l_s.sale_type = 'RETURN' THEN 'إشعار مرتجع' ELSE 'فاتورة ضريبية مبسطة' END
           || '</div><div class="nn-rc-meta">رقم: ' || esc(l_s.receipt_no) || '<br>' || TO_CHAR(l_s.sale_at, 'YYYY-MM-DD HH24:MI') || ' | '
           || esc(l_t.name_ar) || CASE WHEN NOONA_SAL_PKG.is_walk_in(l_s.customer_account_id) = 'N'
                                       THEN '<br>العميل: ' || esc(NOONA_SAL_PKG.customer_label(l_s.customer_account_id)) END
           || CASE WHEN l_s.prescription_no IS NOT NULL THEN '<br>الوصفة: ' || esc(l_s.prescription_no) END
           || '</div><table class="nn-rc-lines"><thead><tr><th>الصنف</th><th>الكمية</th><th>الإجمالي</th></tr></thead><tbody>';
    FOR r IN (SELECT i.name_ar, l.quantity, l.unit_price, l.line_total, l.discount_amount FROM pos_sale_line l JOIN inv_item i ON i.id = l.item_id
               WHERE l.sale_id = p_sale_id ORDER BY l.line_no) LOOP
      l_html := l_html || '<tr><td>' || esc(r.name_ar) || CASE WHEN r.discount_amount > 0 THEN ' <small>خصم ' || fmt(r.discount_amount) || '</small>' END
             || '</td><td>' || fqty(r.quantity) || ' × ' || fmt0(r.unit_price) || '</td><td>' || fmt0(r.line_total) || '</td></tr>';
    END LOOP;
    l_html := l_html || '</tbody></table><table class="nn-rc-tot"><tr><td>الإجمالي قبل الضريبة</td><td>' || fmt0(l_s.subtotal)
           || '</td></tr><tr><td>ضريبة القيمة المضافة</td><td>' || fmt0(l_s.tax_amount) || '</td></tr><tr class="nn-rc-grand"><td>الإجمالي</td><td>'
           || fmt0(l_s.total_amount) || '</td></tr>';
    FOR r IN (SELECT m.name_ar, p.amount FROM pos_payment p JOIN ref_payment_method m ON m.id = p.payment_method_id WHERE p.sale_id = p_sale_id) LOOP
      l_html := l_html || '<tr><td>' || esc(r.name_ar) || '</td><td>' || fmt0(r.amount) || '</td></tr>';
    END LOOP;
    IF l_s.change_amount > 0 THEN
      l_html := l_html || '<tr><td>الباقي</td><td>' || fmt0(l_s.change_amount) || '</td></tr>';
    END IF;
    RETURN l_html || '</table><div class="nn-qr" data-qr="' || NOONA_SAL_PKG.zatca_qr(l_s.sale_at, l_s.total_amount, l_s.tax_amount)
        || '"></div><div class="nn-rc-foot">شكراً لزيارتكم</div></div>';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-POS-030', 'الإيصال غير موجود', 'Receipt not found');
  END receipt_html;

  FUNCTION x_report(p_shift_id IN NUMBER) RETURN CLOB IS
    l_s    pos_shift%ROWTYPE := get_shift(p_shift_id);
    l_html CLOB;
    l_cnt  NUMBER; l_ret NUMBER; l_net NUMBER; l_tax NUMBER;
  BEGIN
    guard('POS_SALE.VIEW');
    SELECT COUNT(CASE WHEN sale_type = 'SALE' THEN 1 END), COUNT(CASE WHEN sale_type = 'RETURN' THEN 1 END),
           NVL(SUM(CASE WHEN sale_type = 'RETURN' THEN -total_amount ELSE total_amount END), 0),
           NVL(SUM(CASE WHEN sale_type = 'RETURN' THEN -tax_amount ELSE tax_amount END), 0)
      INTO l_cnt, l_ret, l_net, l_tax FROM pos_sale WHERE shift_id = p_shift_id AND status_code <> 'OPEN';
    l_html := NOONA_BRAND_PKG.report_header(CASE WHEN l_s.status_code = 'OPEN' THEN 'تقرير X (الوردية مفتوحة)' ELSE 'تقرير Z (إقفال الوردية)' END
                                            || ' - وردية ' || p_shift_id)
           || '<div class="nn-kpis"><div class="nn-kpi"><div><div class="nn-kpi-value">' || l_cnt || '</div><div class="nn-kpi-label">عدد المبيعات</div></div></div>'
           || '<div class="nn-kpi"><div><div class="nn-kpi-value">' || l_ret || '</div><div class="nn-kpi-label">المرتجعات</div></div></div>'
           || '<div class="nn-kpi"><div><div class="nn-kpi-value">' || fmt0(l_net) || '</div><div class="nn-kpi-label">صافي المبيعات</div></div></div>'
           || '<div class="nn-kpi"><div><div class="nn-kpi-value">' || fmt0(l_tax) || '</div><div class="nn-kpi-label">الضريبة</div></div></div></div>'
           || '<table class="nn-rpt"><thead><tr><th>طريقة السداد</th><th>المبيعات</th><th>المرتجعات</th><th>الصافي</th></tr></thead><tbody>';
    FOR r IN (SELECT m.name_ar, SUM(CASE WHEN s.sale_type = 'SALE' THEN p.amount ELSE 0 END) - SUM(CASE WHEN s.sale_type = 'SALE' AND m.method_type = 'CASH'
                     THEN 0 ELSE 0 END) sal, SUM(CASE WHEN s.sale_type = 'RETURN' THEN p.amount ELSE 0 END) ret
                FROM pos_payment p JOIN pos_sale s ON s.id = p.sale_id JOIN ref_payment_method m ON m.id = p.payment_method_id
               WHERE s.shift_id = p_shift_id AND s.status_code <> 'OPEN' GROUP BY m.name_ar, m.sort_order ORDER BY m.sort_order) LOOP
      l_html := l_html || '<tr><td class="nn-rpt-text">' || esc(r.name_ar) || '</td><td>' || fmt(r.sal) || '</td><td>' || fmt(r.ret) || '</td><td>'
             || fmt0(r.sal - r.ret) || '</td></tr>';
    END LOOP;
    l_html := l_html || '</tbody></table><table class="nn-rpt nn-rpt-meta"><tbody><tr><th>رصيد الافتتاح</th><td>' || fmt0(l_s.opening_float)
           || '</td><th>النقد المتوقع في الدرج</th><td>' || fmt0(CASE WHEN l_s.status_code = 'OPEN' THEN expected_cash(p_shift_id) ELSE l_s.expected_cash END)
           || '</td></tr>' || CASE WHEN l_s.status_code <> 'OPEN' THEN '<tr><th>النقد المعدود</th><td>' || fmt0(l_s.counted_cash)
           || '</td><th>الفرق</th><td' || CASE WHEN l_s.variance_amount <> 0 THEN ' class="nn-rpt-bad"' END || '>' || fmt0(l_s.variance_amount)
           || '</td></tr>' END || '</tbody></table><table class="nn-rpt"><thead><tr><th>الأكثر مبيعاً</th><th>الكمية</th><th>القيمة</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM (SELECT i.name_ar, SUM(l.quantity) q, SUM(l.line_total) v FROM pos_sale_line l JOIN pos_sale s ON s.id = l.sale_id
                               JOIN inv_item i ON i.id = l.item_id WHERE s.shift_id = p_shift_id AND s.sale_type = 'SALE' AND s.status_code <> 'OPEN'
                              GROUP BY i.name_ar ORDER BY 3 DESC) WHERE ROWNUM <= 10) LOOP
      l_html := l_html || '<tr><td class="nn-rpt-text">' || esc(r.name_ar) || '</td><td>' || fqty(r.q) || '</td><td>' || fmt0(r.v) || '</td></tr>';
    END LOOP;
    RETURN l_html || '</tbody></table>' || NOONA_GL_PKG.report_footer;
  END x_report;

  FUNCTION pos_sales_report(p_from IN DATE, p_to IN DATE, p_terminal_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0; s2 NUMBER := 0; s3 NUMBER := 0;
  BEGIN
    guard('POS_SALE.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('مبيعات نقاط البيع من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>المحطة</th><th>الوردية</th><th>الكاشير</th><th>الإيصالات</th><th>المرتجعات</th>'
           || '<th>الصافي قبل الضريبة</th><th>الضريبة</th><th>الإجمالي</th><th>فرق النقدية</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT TRUNC(h.opened_at) d, t.name_ar term, h.id shift, h.status_code, h.variance_amount,
                     (SELECT MAX(u.display_name) FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE m.id = h.cashier_member_id) cashier,
                     COUNT(CASE WHEN s.sale_type = 'SALE' THEN 1 END) cnt, COUNT(CASE WHEN s.sale_type = 'RETURN' THEN 1 END) ret,
                     NVL(SUM(CASE WHEN s.sale_type = 'RETURN' THEN -s.subtotal ELSE s.subtotal END), 0) net,
                     NVL(SUM(CASE WHEN s.sale_type = 'RETURN' THEN -s.tax_amount ELSE s.tax_amount END), 0) tax
                FROM pos_shift h JOIN pos_terminal t ON t.id = h.terminal_id
                LEFT JOIN pos_sale s ON s.shift_id = h.id AND s.status_code <> 'OPEN'
               WHERE h.company_id = company AND TRUNC(h.opened_at) BETWEEN p_from AND p_to AND (p_terminal_id IS NULL OR h.terminal_id = p_terminal_id)
               GROUP BY TRUNC(h.opened_at), t.name_ar, h.id, h.status_code, h.variance_amount, h.cashier_member_id
               ORDER BY 1, 3) LOOP
      s1 := s1 + r.net; s2 := s2 + r.tax; s3 := s3 + NVL(r.variance_amount, 0);
      l_html := l_html || '<tr><td>' || TO_CHAR(r.d, 'YYYY-MM-DD') || '</td><td>' || esc(r.term) || '</td><td>' || r.shift || '</td><td>' || esc(r.cashier)
             || '</td><td>' || r.cnt || '</td><td>' || r.ret || '</td><td>' || fmt(r.net) || '</td><td>' || fmt(r.tax) || '</td><td>' || fmt(r.net + r.tax)
             || '</td><td' || CASE WHEN NVL(r.variance_amount, 0) <> 0 THEN ' class="nn-rpt-bad"' END || '>' || fmt(r.variance_amount) || '</td><td>'
             || CASE r.status_code WHEN 'OPEN' THEN 'مفتوحة' ELSE 'مقفلة' END || '</td></tr>';
    END LOOP;
    RETURN l_html || '</tbody><tfoot><tr><td colspan="6">الإجمالي</td><td>' || fmt0(s1) || '</td><td>' || fmt0(s2) || '</td><td>' || fmt0(s1 + s2)
        || '</td><td>' || fmt0(s3) || '</td><td></td></tr></tfoot></table>' || NOONA_GL_PKG.report_footer('الورديات المقفلة مرحلة بقيد واحد لكل وردية');
  END pos_sales_report;

  FUNCTION pos_summary RETURN CLOB IS
    l_today NUMBER; l_cnt NUMBER; l_open NUMBER; l_avg NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE WHEN sale_type = 'RETURN' THEN -total_amount ELSE total_amount END), 0), COUNT(CASE WHEN sale_type = 'SALE' THEN 1 END)
      INTO l_today, l_cnt FROM pos_sale WHERE company_id = company AND status_code <> 'OPEN' AND sale_at >= TRUNC(SYSDATE);
    SELECT COUNT(*) INTO l_open FROM pos_shift WHERE company_id = company AND status_code = 'OPEN';
    l_avg := CASE WHEN l_cnt > 0 THEN l_today / l_cnt END;
    RETURN '<div class="nn-kpis"><div class="nn-kpi"><span class="nn-kpi-icon fa fa-shopping-basket"></span><div><div class="nn-kpi-value">'
        || fmt0(l_today) || '</div><div class="nn-kpi-label">مبيعات اليوم</div></div></div><div class="nn-kpi"><span class="nn-kpi-icon fa fa-receipt fa-file-text-o"></span><div><div class="nn-kpi-value">'
        || l_cnt || '</div><div class="nn-kpi-label">إيصالات اليوم</div></div></div><div class="nn-kpi"><span class="nn-kpi-icon fa fa-calculator"></span><div><div class="nn-kpi-value">'
        || fmt0(l_avg) || '</div><div class="nn-kpi-label">متوسط السلة</div></div></div><div class="nn-kpi"><span class="nn-kpi-icon fa fa-clock-o"></span><div><div class="nn-kpi-value">'
        || l_open || '</div><div class="nn-kpi-label">ورديات مفتوحة</div></div></div></div>';
  END pos_summary;

END NOONA_POS_PKG;
/
