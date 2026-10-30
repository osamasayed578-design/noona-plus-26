-- =============================================================================
-- NOONA PLUS ERP | اختبار العملاء والمبيعات ونقاط البيع (العميل العام، حد الائتمان، السعر الشامل للضريبة والحد الأدنى،
--                  الوصفة الطبية والدفعات المنتهية، تكلفة المبيعات، المرتجع، التحصيل، رمز ZATCA،
--                  الوردية والبيع السريع بطرق سداد مختلطة ومنع التكرار والمرتجع وإقفال الوردية بقيد واحد) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_sales.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  DBMS_OUTPUT.PUT_LINE('setup rows: ' || NOONA_POS_PKG.quick_setup || ' / ' || NOONA_PUR_PKG.quick_setup);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;
END;
/

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3');
  l_n    NUMBER;
  l_walk NUMBER;
  l_cus  NUMBER;
  l_gen  NUMBER;
  l_rx   NUMBER;
  l_inv  NUMBER;
  l_cr   NUMBER;
  l_ret  NUMBER;
  l_rcp  NUMBER;
  l_box  NUMBER;
  l_bank NUMBER;
  l_term NUMBER;
  l_sh   NUMBER;
  l_dbox NUMBER;
  l_s1   NUMBER;
  l_ln   NUMBER;
  l_b0   NUMBER;
  l_j    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_r    CLOB;
  l_d    VARCHAR2(10) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION cat(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM inv_item_category WHERE code = p_code; RETURN l;
  END cat;
  FUNCTION jl(p_type VARCHAR2, p_entity NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(a.account_code || ':' || l.debit_amount || '/' || l.credit_amount, ' ') WITHIN GROUP (ORDER BY a.account_code, l.debit_amount)
      INTO l
      FROM ace_accounting_event e JOIN gl_journal j ON j.accounting_event_id = e.id JOIN gl_journal_line l ON l.journal_id = j.id
      JOIN gl_account a ON a.id = l.account_id
     WHERE e.source_entity_type = p_type AND e.source_entity_id = p_entity AND e.reversal_of_event_id IS NULL;
    RETURN l;
  END jl;
  FUNCTION jtype(p_type VARCHAR2, p_entity NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT MAX(j.journal_category) INTO l FROM ace_accounting_event e JOIN gl_journal j ON j.accounting_event_id = e.id
     WHERE e.source_entity_type = p_type AND e.source_entity_id = p_entity AND e.reversal_of_event_id IS NULL;
    RETURN l;
  END jtype;
  FUNCTION open_amt(p_src VARCHAR2, p_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(open_amount), 0) INTO l FROM ar_open_item WHERE source_entity_type = p_src AND source_entity_id = p_id; RETURN l;
  END open_amt;
  FUNCTION inv(p_json VARCHAR2) RETURN NUMBER IS BEGIN RETURN NOONA_SAL_PKG.save_invoice(p_json); END;
  FUNCTION js(p CLOB, p_key VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN JSON_VALUE(p, '$.' || p_key); END;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  UPDATE dms_archive_rule SET is_active = 'N';
  l_box := NOONA_CSH_PKG.create_cash_box('SB' || SUBSTR(l_sfx, 1, 6), 'صندوق مبيعات اختبار');
  SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = NOONA_SAL_PKG.company AND status_code = 'ACTIVE';
  -- حد الدفع المعرف للحساب في بيانات الشركة لا يقيد الاختبار (يتراجع في النهاية)
  UPDATE csh_bank_account SET max_payment_amount = NULL WHERE id = l_bank;

  -- العميل العام والعملاء
  l_walk := NOONA_SAL_PKG.walk_in_customer;
  ok('walk-in customer exists', l_walk IS NOT NULL AND NOONA_SAL_PKG.is_walk_in(l_walk) = 'Y');
  ok('walk-in customer is unique', NOONA_SAL_PKG.walk_in_customer = l_walk);
  l_cus := NOONA_SAL_PKG.save_customer('{"name":"مؤسسة العميل اختبار ' || l_sfx || '","phone":"055' || SUBSTR(l_sfx, 1, 7) || '","term":"NET30","limit":500}');
  ok('customer with credit limit', NOONA_SAL_PKG.credit_limit(l_cus) = 500 AND INSTR(NOONA_SAL_PKG.customers_json('055' || SUBSTR(l_sfx, 1, 7)), '"id":' || l_cus || ',') > 0);

  -- الأصناف ورصيدها
  l_gen := NOONA_INV_PKG.save_item('{"name":"بطارية سيارة 70 أمبير اختبار ' || l_sfx || '","cat":' || cat('AUTO') || ',"price":115,"incl":"Y","minPrice":92,'
             || '"barcodes":["B' || l_sfx || '"]}');
  l_rx := NOONA_INV_PKG.save_item('{"name":"مضاد حيوي اختبار ' || l_sfx || '","cat":' || cat('PHARMA') || ',"rx":"Y","generic":"Amoxicillin","price":20}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || l_d || '","action":"POST","lines":[{"i":' || l_gen || ',"q":20,"c":60},'
             || '{"i":' || l_rx || ',"q":5,"c":8,"lot":"X' || l_sfx || '","exp":"' || TO_CHAR(SYSDATE - 3, 'YYYY-MM-DD') || '"},'
             || '{"i":' || l_rx || ',"q":10,"c":8,"lot":"V' || l_sfx || '","exp":"' || TO_CHAR(SYSDATE + 100, 'YYYY-MM-DD') || '"}]}');

  -- فاتورة نقدية للعميل العام بسعر شامل الضريبة
  l_inv := inv('{"date":"' || l_d || '","mode":"CASH","place":"BOX:' || l_box || '","action":"POST","lines":[{"i":' || l_gen || ',"q":2}]}');
  SELECT doc_type || '|' || status_code || '|' || subtotal || '|' || tax_amount || '|' || total_amount || '|' || cogs_amount INTO l_s
    FROM sal_invoice WHERE id = l_inv;
  ok('cash simplified invoice, price includes VAT', l_s = 'SIMPLIFIED_INVOICE|PAID|200|30|230|120', l_s);
  ok('sales journal: cash, revenue, output VAT, COGS', jl('SAL_INVOICE', l_inv) = '1101:230/0 1105:0/120 2104:0/30 4101:0/200 5101:120/0',
     jl('SAL_INVOICE', l_inv));
  ok('sales journal typed SALES_INVOICE', jtype('SAL_INVOICE', l_inv) = 'SALES_INVOICE');
  ok('stock issued', NOONA_INV_PKG.on_hand(l_gen) = 18);
  ok('cash box received the sale', NOONA_CSH_PKG.balance(l_box, NULL) = 230, NOONA_CSH_PKG.balance(l_box, NULL));
  BEGIN
    l_n := inv('{"mode":"CREDIT","action":"POST","lines":[{"i":' || l_gen || ',"q":1}]}');
    ok('walk-in invoice must be cash with a place', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('walk-in invoice must be cash with a place', 'NOONA-SAL-021', SQLERRM); END;
  BEGIN
    l_n := inv('{"mode":"CASH","place":"BOX:' || l_box || '","lines":[{"i":' || l_gen || ',"q":1,"p":80,"inc":"Y"}]}');
    ok('minimum sale price enforced', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('minimum sale price enforced', 'NOONA-SAL-015', SQLERRM); END;
  l_c := NOONA_SAL_PKG.invoice_print(l_inv);
  l_s := REGEXP_SUBSTR(l_c, 'data-qr="([^"]+)"', 1, 1, NULL, 1);
  ok('ZATCA QR (TLV base64) on the invoice', l_s IS NOT NULL
     AND SUBSTR(RAWTOHEX(UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(l_s))), 1, 2) = '01', SUBSTR(l_s, 1, 40));

  -- البيع الآجل وحد الائتمان
  l_cr := inv('{"cust":' || l_cus || ',"date":"' || l_d || '","mode":"CREDIT","action":"POST","lines":[{"i":' || l_gen || ',"q":4}]}');
  ok('credit invoice opens receivable', open_amt('SAL_INVOICE', l_cr) = 460 AND NOONA_SAL_PKG.customer_balance(l_cus) = 460);
  ok('credit journal Dr receivables', INSTR(jl('SAL_INVOICE', l_cr), '1103:460/0') > 0, jl('SAL_INVOICE', l_cr));
  SAVEPOINT s1;
  BEGIN
    l_n := inv('{"cust":' || l_cus || ',"mode":"CREDIT","action":"POST","lines":[{"i":' || l_gen || ',"q":1}]}');
    ok('credit limit enforced', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('credit limit enforced', 'NOONA-SAL-031', SQLERRM); ROLLBACK TO s1; END;

  -- الأدوية: الوصفة، والدفعة المنتهية لا تباع
  SAVEPOINT s2;
  BEGIN
    l_n := inv('{"mode":"CASH","place":"BOX:' || l_box || '","action":"POST","lines":[{"i":' || l_rx || ',"q":3}]}');
    ok('prescription required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('prescription required', 'NOONA-SAL-030', SQLERRM); ROLLBACK TO s2; END;
  l_n := inv('{"mode":"CASH","place":"BOX:' || l_box || '","rx":"RX-' || l_sfx || '","action":"POST","lines":[{"i":' || l_rx || ',"q":3}]}');
  SELECT NVL(SUM(o.on_hand_qty), 0) INTO l_b0 FROM inv_onhand o JOIN inv_lot t ON t.id = o.lot_id WHERE o.item_id = l_rx AND t.lot_no = 'X' || l_sfx;
  ok('sale skips the expired lot (FEFO on valid lots)', l_b0 = 5 AND NOONA_INV_PKG.on_hand(l_rx) = 12, l_b0);
  SAVEPOINT s3;
  BEGIN
    l_n := inv('{"mode":"CASH","place":"BOX:' || l_box || '","rx":"RX","action":"POST","lines":[{"i":' || l_rx || ',"q":8}]}');
    ok('expired stock cannot be sold', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('expired stock cannot be sold', 'NOONA-INV-024', SQLERRM); ROLLBACK TO s3; END;

  -- المرتجع
  SELECT MIN(id) INTO l_ln FROM sal_invoice_line WHERE invoice_id = l_cr;
  l_ret := NOONA_SAL_PKG.post_return('{"inv":' || l_cr || ',"date":"' || l_d || '","reason":"عيب مصنعي","lines":[{"l":' || l_ln || ',"q":1}]}');
  ok('sales return reduces receivable', open_amt('SAL_INVOICE', l_cr) = 345 AND NOONA_SAL_PKG.customer_balance(l_cus) = 345,
     open_amt('SAL_INVOICE', l_cr));
  ok('return journal: returns, VAT, receivable, stock back at cost', jl('SAL_INVOICE', l_ret) = '1103:0/115 1105:60/0 2104:15/0 4102:100/0 5101:0/60',
     jl('SAL_INVOICE', l_ret));
  ok('return journal typed SALES_RETURN', jtype('SAL_INVOICE', l_ret) = 'SALES_RETURN');
  ok('returned stock back', NOONA_INV_PKG.on_hand(l_gen) = 15);
  BEGIN
    l_n := NOONA_SAL_PKG.post_return('{"inv":' || l_cr || ',"reason":"x","lines":[{"l":' || l_ln || ',"q":4}]}');
    ok('return limited to remaining quantity', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('return limited to remaining quantity', 'NOONA-SAL-043', SQLERRM); END;

  -- التحصيل
  l_rcp := NOONA_SAL_PKG.receive('{"cust":' || l_cus || ',"date":"' || l_d || '","amount":200,"place":"BANK:' || l_bank || '","method":"BANK_APP","ref":"TR-9"}');
  ok('receipt applied FIFO', open_amt('SAL_INVOICE', l_cr) = 145 AND NOONA_SAL_PKG.customer_balance(l_cus) = 145);
  ok('receipt journal typed CUSTOMER_RECEIPT', jtype('AR_RECEIPT', l_rcp) = 'CUSTOMER_RECEIPT' AND INSTR(jl('AR_RECEIPT', l_rcp), '1103:0/200') > 0);
  l_n := NOONA_SAL_PKG.reverse_receipt(l_rcp, TRUNC(SYSDATE), 'شيك مرتد');
  ok('reversed receipt reopens receivable', open_amt('SAL_INVOICE', l_cr) = 345 AND NOONA_SAL_PKG.customer_balance(l_cus) = 345);

  -- التقارير
  l_c := NOONA_SAL_PKG.customer_statement(l_cus, TRUNC(SYSDATE) - 1, TRUNC(SYSDATE));
  ok('customer statement', INSTR(l_c, 'فاتورة مبيعات آجلة') > 0 AND INSTR(l_c, 'مرتجع') > 0 AND INSTR(l_c, '345.00</td></tr></tfoot>') > 0);
  ok('AR aging', INSTR(NOONA_SAL_PKG.ar_aging, 'مؤسسة العميل اختبار ' || l_sfx) > 0);
  l_c := NOONA_SAL_PKG.sales_register(TRUNC(SYSDATE), TRUNC(SYSDATE));
  ok('sales register with gross profit', INSTR(l_c, 'مجمل الربح') > 0 AND INSTR(l_c, 'مبسطة') > 0);
  ok('sales by item with margin', INSTR(NOONA_SAL_PKG.sales_by_item(TRUNC(SYSDATE), TRUNC(SYSDATE)), 'بطارية سيارة 70 أمبير اختبار') > 0);

  -- ======================================================== نقاط البيع
  SELECT MIN(id) INTO l_term FROM pos_terminal WHERE company_id = NOONA_SAL_PKG.company AND status_code = 'ACTIVE';
  SELECT MAX(cash_box_id) INTO l_dbox FROM pos_terminal WHERE id = l_term;
  ok('default POS terminal with cash drawer', l_term IS NOT NULL AND l_dbox IS NOT NULL);
  -- وردية مفتوحة سابقاً في بيانات التجربة تقفل أولاً
  FOR o IN (SELECT id FROM pos_shift WHERE terminal_id = l_term AND status_code = 'OPEN') LOOP
    l_n := NOONA_POS_PKG.close_shift(o.id, NOONA_POS_PKG.expected_cash(o.id));
  END LOOP;
  l_b0 := NOONA_CSH_PKG.balance(l_dbox, NULL);
  l_sh := NOONA_POS_PKG.open_shift(l_term, 100);
  ok('shift opened and reused', l_sh IS NOT NULL AND NOONA_POS_PKG.open_shift(l_term) = l_sh);
  l_c := NOONA_POS_PKG.boot_json(l_term);
  ok('POS boot loads items with barcodes, prices, tax and methods', INSTR(l_c, '"b":"B' || l_sfx || '"') > 0 AND INSTR(l_c, '"c":"MADA"') > 0
     AND INSTR(l_c, '"shift":' || l_sh) > 0);
  l_r := NOONA_POS_PKG.sale('{"key":"K1' || l_sfx || '","shift":' || l_sh || ',"lines":[{"i":' || l_gen || ',"q":1,"b":"B' || l_sfx || '"}],'
           || '"pays":[{"m":"CASH","a":200}]}');
  l_s1 := TO_NUMBER(js(l_r, 'id'));
  ok('fast cash sale with change', js(l_r, 'total') = '115' AND js(l_r, 'change') = '85' AND js(l_r, 'qr') IS NOT NULL, SUBSTR(l_r, 1, 200));
  l_r := NOONA_POS_PKG.sale('{"key":"K1' || l_sfx || '","shift":' || l_sh || ',"lines":[{"i":' || l_gen || ',"q":1}],"pays":[{"m":"CASH","a":200}]}');
  ok('resent sale is idempotent (no double sale or stock)', TO_NUMBER(js(l_r, 'id')) = l_s1 AND NOONA_INV_PKG.on_hand(l_gen) = 14);
  l_r := NOONA_POS_PKG.sale('{"key":"K2' || l_sfx || '","shift":' || l_sh || ',"lines":[{"i":' || l_gen || ',"q":2}],'
           || '"pays":[{"m":"MADA","a":100,"ref":"APP123"},{"m":"CASH","a":130}]}');
  ok('mixed payment mada + cash', js(l_r, 'total') = '230' AND js(l_r, 'change') = '0', SUBSTR(l_r, 1, 200));
  BEGIN
    l_r := NOONA_POS_PKG.sale('{"key":"K3' || l_sfx || '","shift":' || l_sh || ',"lines":[{"i":' || l_gen || ',"q":1}],"pays":[{"m":"STC_PAY","a":300}]}');
    ok('no change from electronic payment', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no change from electronic payment', 'NOONA-POS-024', SQLERRM); END;
  BEGIN
    l_r := NOONA_POS_PKG.sale('{"key":"K4' || l_sfx || '","shift":' || l_sh || ',"lines":[{"i":' || l_gen || ',"q":1}],"pays":[{"m":"CREDIT","a":115}]}');
    ok('walk-in cannot buy on credit', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('walk-in cannot buy on credit', 'NOONA-SAL-032', SQLERRM); END;
  BEGIN
    l_r := NOONA_POS_PKG.sale('{"key":"K5' || l_sfx || '","shift":' || l_sh || ',"lines":[{"i":' || l_rx || ',"q":1}],"pays":[{"m":"CASH","a":50}]}');
    ok('POS prescription check', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('POS prescription check', 'NOONA-SAL-030', SQLERRM); END;
  l_r := NOONA_POS_PKG.sale('{"key":"K6' || l_sfx || '","shift":' || l_sh || ',"cust":' || l_cus || ',"lines":[{"i":' || l_gen || ',"q":1}],'
           || '"pays":[{"m":"CREDIT","a":115}]}');
  ok('credit POS sale to a registered customer', open_amt('POS_SALE', TO_NUMBER(js(l_r, 'id'))) = 115 AND NOONA_SAL_PKG.customer_balance(l_cus) = 460);
  -- مرتجع بالإيصال
  SELECT receipt_no INTO l_s FROM pos_sale WHERE id = l_s1;
  ok('find receipt for return', INSTR(NOONA_POS_PKG.find_receipt(l_s), '"no":"' || l_s || '"') > 0);
  SELECT MIN(id) INTO l_ln FROM pos_sale_line WHERE sale_id = l_s1;
  l_r := NOONA_POS_PKG.return_sale('{"key":"R1' || l_sfx || '","shift":' || l_sh || ',"orig":' || l_s1 || ',"lines":[{"l":' || l_ln || ',"q":1}]}');
  SELECT status_code INTO l_s FROM pos_sale WHERE id = l_s1;
  ok('POS return refunds cash and restores stock', js(l_r, 'total') = '115' AND l_s = 'RETURNED' AND NOONA_INV_PKG.on_hand(l_gen) = 12, l_s);
  BEGIN
    l_r := NOONA_POS_PKG.return_sale('{"key":"R2' || l_sfx || '","shift":' || l_sh || ',"orig":' || l_s1 || ',"lines":[{"l":' || l_ln || ',"q":1}]}');
    ok('receipt cannot be returned twice', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('receipt cannot be returned twice', 'NOONA-POS-031', SQLERRM); END;
  ok('expected drawer cash', NOONA_POS_PKG.expected_cash(l_sh) = 230, NOONA_POS_PKG.expected_cash(l_sh));
  ok('X report', INSTR(NOONA_POS_PKG.x_report(l_sh), 'تقرير X') > 0);
  -- إقفال الوردية بعجز 5 (المتوقع 100 افتتاح + 115 + 130 نقداً - 115 رد = 230)
  l_j := NOONA_POS_PKG.close_shift(l_sh, 225);
  l_s := jl('POS_SHIFT', l_sh);
  ok('shift journal: drawer cash net of shortage', INSTR(l_s, '1101:125/0') > 0, l_s);
  ok('shift journal: returns, VAT, credit, shortage, COGS', INSTR(l_s, '4102:100/0') > 0 AND INSTR(l_s, '2104:0/45') > 0 AND INSTR(l_s, '1103:115/0') > 0
     AND INSTR(l_s, '5299:5/0') > 0 AND INSTR(l_s, '4101:0/400') > 0 AND INSTR(l_s, '5101:180/0') > 0 AND INSTR(l_s, '1105:0/180') > 0, l_s);
  ok('shift journal typed POS_SALE', jtype('POS_SHIFT', l_sh) = 'POS_SALE');
  ok('drawer balance increased by counted cash sales', NOONA_CSH_PKG.balance(l_dbox, NULL) - l_b0 = 125, NOONA_CSH_PKG.balance(l_dbox, NULL) - l_b0);
  SELECT status_code || '|' || variance_amount INTO l_s FROM pos_shift WHERE id = l_sh;
  ok('shift closed with variance', l_s = 'CLOSED|-5', l_s);
  ok('Z report shows the variance', INSTR(NOONA_POS_PKG.x_report(l_sh), 'تقرير Z') > 0);
  BEGIN
    l_r := NOONA_POS_PKG.sale('{"key":"K9' || l_sfx || '","shift":' || l_sh || ',"lines":[{"i":' || l_gen || ',"q":1}],"pays":[{"m":"CASH","a":115}]}');
    ok('no sales on a closed shift', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no sales on a closed shift', 'NOONA-POS-012', SQLERRM); END;
  ok('receipt HTML with QR', INSTR(NOONA_POS_PKG.receipt_html(TO_NUMBER(js(l_r, 'id'))), 'data-qr') > 0 OR INSTR(NOONA_POS_PKG.receipt_html(l_s1), 'data-qr') > 0);
  ok('POS sales report', INSTR(NOONA_POS_PKG.pos_sales_report(TRUNC(SYSDATE), TRUNC(SYSDATE)), 'مبيعات نقاط البيع') > 0);
  ok('sales by item includes POS', INSTR(NOONA_SAL_PKG.sales_by_item(TRUNC(SYSDATE), TRUNC(SYSDATE)), 'منها نقاط البيع') > 0);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
  IF g_fail > 0 THEN RAISE_APPLICATION_ERROR(-20999, g_fail || ' test(s) failed'); END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
