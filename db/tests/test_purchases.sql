-- =============================================================================
-- NOONA PLUS ERP | اختبار الموردين والمشتريات (المورد، أمر الشراء، فاتورة آجلة ونقدية مع الاستلام المخزني والدفعات،
--                  المرتجع، السداد وتخصيصه وعكسه، كشف الحساب وأعمار الديون والسجلات) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_purchases.sql
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
  DBMS_OUTPUT.PUT_LINE('setup rows: ' || NOONA_PUR_PKG.quick_setup || ' / box ' || NOONA_CSH_PKG.quick_setup);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;
END;
/

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3');
  l_n    NUMBER;
  l_sup  NUMBER;
  l_gen  NUMBER;
  l_ph   NUMBER;
  l_srv  NUMBER;
  l_po   NUMBER;
  l_inv  NUMBER;
  l_inv2 NUMBER;
  l_ret  NUMBER;
  l_pay  NUMBER;
  l_box  NUMBER;
  l_box2 NUMBER;
  l_bank NUMBER;
  l_v    NUMBER;
  l_mem  NUMBER;
  l_role NUMBER;
  l_user VARCHAR2(100);
  l_pol1 NUMBER;
  l_pol2 NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_d    VARCHAR2(10) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');
  l_b0   NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
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
  FUNCTION open_amt(p_inv NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(open_amount), 0) INTO l FROM ap_open_item WHERE invoice_id = p_inv; RETURN l;
  END open_amt;
  FUNCTION istatus(p_inv NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT status_code INTO l FROM ap_invoice WHERE id = p_inv; RETURN l;
  END istatus;
BEGIN
  login('ADMIN');
  UPDATE dms_archive_rule SET is_active = 'N';
  UPDATE dms_required_document SET is_active = 'N';

  -- صندوق اختبار ممول، وصندوق فارغ، وحساب بنكي
  l_box := NOONA_CSH_PKG.create_cash_box('PB' || SUBSTR(l_sfx, 1, 6), 'صندوق مشتريات اختبار');
  l_box2 := NOONA_CSH_PKG.create_cash_box('PE' || SUBSTR(l_sfx, 1, 6), 'صندوق فارغ اختبار');
  SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = NOONA_PUR_PKG.company AND status_code = 'ACTIVE';
  -- حد الدفع المعرف للحساب في بيانات الشركة لا يقيد الاختبار (يتراجع في النهاية)
  UPDATE csh_bank_account SET max_payment_amount = NULL WHERE id = l_bank;
  -- الحساب البنكي في قاعدة جديدة بلا رصيد: تسهيل سحب على المكشوف للاختبار (يتراجع بنهاية الاختبار)
  NOONA_CSH_PKG.set_overdraft(l_bank, 100000);
  l_user := 'PUA' || l_sfx;
  l_mem := NOONA_SEC_ADMIN_PKG.create_user(l_user, 'معتمد مالي', LOWER(l_user) || '@x.local', NOONA_PUR_PKG.company);
  l_role := NOONA_SEC_ADMIN_PKG.create_role('PUR' || l_sfx, 'معتمد');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,APPROVE,POST');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,APPROVE,POST');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'اختبار');
  l_v := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', TRUNC(SYSDATE), l_box, NULL, NULL, 'الشريك', 'تمويل الصندوق', NULL, '[{"a":"3101","m":5000}]');
  NOONA_CSH_PKG.submit_voucher(l_v);
  login(l_user);
  NOONA_CSH_PKG.approve_voucher(l_v);
  login('ADMIN');
  ok('test cash box funded', NOONA_CSH_PKG.balance(l_box, NULL) = 5000, NOONA_CSH_PKG.balance(l_box, NULL));
  SELECT COUNT(*) INTO l_n FROM ref_payment_method WHERE code IN ('CASH', 'MADA', 'APPLE_PAY', 'STC_PAY', 'BANK_APP', 'CREDIT');
  ok('payment methods seeded (cash, mada, wallets, bank apps, credit)', l_n = 6, l_n);

  -- المورد
  BEGIN
    l_n := NOONA_PUR_PKG.save_supplier('{"name":"مورد خاطئ","tax":"12345"}');
    ok('invalid VAT number rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid VAT number rejected', 'NOONA-PTY-002', SQLERRM); END;
  l_sup := NOONA_PUR_PKG.save_supplier('{"name":"شركة التوريدات اختبار ' || l_sfx || '","tax":"3' || LPAD(SUBSTR(l_sfx, 1, 9), 13, '0')
             || '3","phone":"0500000000","address":"الرياض","term":"NET30"}');
  SELECT s.supplier_no || '|' || a.status_code INTO l_s FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id WHERE a.id = l_sup;
  ok('supplier created active with number', l_s LIKE 'SUP-%|ACTIVE', l_s);
  ok('supplier search', INSTR(NOONA_PUR_PKG.suppliers_json('التوريدات اختبار ' || l_sfx), '"id":' || l_sup || ',') > 0);
  l_c := NOONA_PUR_PKG.supplier_json(l_sup);
  ok('supplier JSON with contact and term', INSTR(l_c, '"phone":"0500000000"') > 0 AND INSTR(l_c, '"term":"NET30"') > 0);

  -- الأصناف
  l_gen := NOONA_INV_PKG.save_item('{"name":"إطار 16 بوصة اختبار ' || l_sfx || '","cat":' || cat('AUTO') || ',"price":90}');
  l_ph := NOONA_INV_PKG.save_item('{"name":"شراب كحة اختبار ' || l_sfx || '","cat":' || cat('PHARMA') || ',"generic":"Dextromethorphan","price":9}');
  l_srv := NOONA_INV_PKG.save_item('{"name":"خدمة شحن اختبار ' || l_sfx || '","type":"SERVICE","cat":' || cat('SRV') || '}');

  -- أمر الشراء
  l_po := NOONA_PUR_PKG.save_order('{"sup":' || l_sup || ',"date":"' || l_d || '","action":"APPROVE","lines":[{"i":' || l_gen
            || ',"q":10,"p":50},{"i":' || l_ph || ',"q":100,"p":4}]}');
  SELECT doc_no || '|' || status_code || '|' || total_amount INTO l_s FROM pur_order WHERE id = l_po;
  ok('purchase order approved and numbered with VAT total', l_s LIKE 'PO-%|APPROVED|1035', l_s);
  SELECT MIN(id), MAX(id) INTO l_pol1, l_pol2 FROM pur_order_line WHERE order_id = l_po;
  l_c := NOONA_PUR_PKG.invoice_from_order(l_po);
  ok('invoice prefilled from the order', INSTR(l_c, '"pol":' || l_pol1) > 0 AND INSTR(l_c, '"q":10') > 0);

  -- فاتورة آجلة من الأمر: الدواء بلا دفعة يرفض
  SAVEPOINT s1;
  BEGIN
    l_n := NOONA_PUR_PKG.save_invoice('{"sup":' || l_sup || ',"date":"' || l_d || '","supInv":"S-' || l_sfx || '","po":' || l_po
             || ',"mode":"CREDIT","action":"POST","lines":[{"i":' || l_ph || ',"q":100,"p":4,"pol":' || l_pol2 || '}]}');
    ok('pharma purchase requires lot', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('pharma purchase requires lot', 'NOONA-INV-022', SQLERRM); ROLLBACK TO s1; END;
  l_inv := NOONA_PUR_PKG.save_invoice('{"sup":' || l_sup || ',"date":"' || l_d || '","supInv":"S-' || l_sfx || '","po":' || l_po
             || ',"mode":"CREDIT","action":"POST","lines":[{"i":' || l_gen || ',"q":6,"p":50,"pol":' || l_pol1 || '},{"i":' || l_ph
             || ',"q":100,"p":4,"pol":' || l_pol2 || ',"lot":"L' || l_sfx || '","exp":"' || TO_CHAR(SYSDATE + 365, 'YYYY-MM-DD') || '"}]}');
  ok('credit purchase posted', istatus(l_inv) = 'POSTED', istatus(l_inv));
  ok('stock received at net cost', NOONA_INV_PKG.on_hand(l_gen) = 6 AND NOONA_INV_PKG.avg_cost(l_gen) = 50 AND NOONA_INV_PKG.on_hand(l_ph) = 100);
  SELECT COUNT(*) INTO l_n FROM inv_onhand o JOIN inv_lot t ON t.id = o.lot_id WHERE o.item_id = l_ph AND t.lot_no = 'L' || l_sfx AND t.expiry_date IS NOT NULL;
  ok('pharma lot with expiry received', l_n = 1);
  ok('purchase journal Dr inventory + input VAT / Cr payables', jl('AP_INVOICE', l_inv) = '1105:700/0 1107:105/0 2101:0/805', jl('AP_INVOICE', l_inv));
  ok('purchase journal typed PURCHASE_INVOICE', jtype('AP_INVOICE', l_inv) = 'PURCHASE_INVOICE');
  SELECT COUNT(*) INTO l_n FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN ace_accounting_event e ON e.id = j.accounting_event_id
   WHERE e.source_entity_type = 'AP_INVOICE' AND e.source_entity_id = l_inv AND l.credit_amount = 805 AND l.party_id IS NOT NULL;
  ok('payable line carries the supplier party', l_n = 1);
  SELECT TO_CHAR(due_date - TRUNC(SYSDATE)) INTO l_s FROM ap_open_item WHERE invoice_id = l_inv;
  ok('open item due by payment term (30 days)', open_amt(l_inv) = 805 AND l_s = '30', l_s);
  SELECT status_code INTO l_s FROM pur_order WHERE id = l_po;
  ok('order partially received', l_s = 'PARTIALLY_RECEIVED', l_s);
  ok('last purchase price kept for the item', INSTR(NOONA_INV_PKG.find_items(NULL, NULL, 500, 'PURCHASE'), '"id":' || l_gen || ',') > 0);
  BEGIN
    l_n := NOONA_PUR_PKG.save_invoice('{"sup":' || l_sup || ',"supInv":"S-' || l_sfx || '","action":"POST","lines":[{"i":' || l_gen || ',"q":1,"p":50}]}');
    ok('duplicate supplier invoice rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate supplier invoice rejected', 'NOONA-PUR-026', SQLERRM); END;
  BEGIN
    NOONA_PUR_PKG.cancel_invoice(l_inv);
    ok('posted invoice cannot be cancelled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('posted invoice cannot be cancelled', 'NOONA-PUR-022', SQLERRM); END;

  -- فاتورة نقدية من الصندوق: خدمة + مصروف بمركز تكلفة
  SAVEPOINT s2;
  BEGIN
    l_n := NOONA_PUR_PKG.save_invoice('{"sup":' || l_sup || ',"mode":"CASH","place":"BOX:' || l_box2 || '","action":"POST","lines":[{"i":'
             || l_srv || ',"q":1,"p":100}]}');
    ok('cash purchase limited by box balance', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cash purchase limited by box balance', 'NOONA-PUR-042', SQLERRM); ROLLBACK TO s2; END;
  l_inv2 := NOONA_PUR_PKG.save_invoice('{"sup":' || l_sup || ',"date":"' || l_d || '","mode":"CASH","place":"BOX:' || l_box
              || '","action":"POST","lines":[{"i":' || l_srv || ',"q":1,"p":60},{"d":"صيانة رافعة","q":1,"p":40,"acc":"5205"}]}');
  ok('cash purchase paid immediately', istatus(l_inv2) = 'PAID' AND open_amt(l_inv2) = 0, istatus(l_inv2));
  ok('cash purchase journal Dr expenses + VAT / Cr cash', jl('AP_INVOICE', l_inv2) = '1101:0/115 1107:15/0 5102:60/0 5205:40/0',
     jl('AP_INVOICE', l_inv2));
  ok('cash box reduced by the cash purchase', NOONA_CSH_PKG.balance(l_box, NULL) = 4885, NOONA_CSH_PKG.balance(l_box, NULL));
  ok('services are not stocked', NOONA_INV_PKG.on_hand(l_srv) = 0);

  -- المرتجع
  SELECT MIN(id) INTO l_n FROM ap_invoice_line WHERE invoice_id = l_inv AND item_id = l_gen;
  BEGIN
    l_ret := NOONA_PUR_PKG.post_return('{"inv":' || l_inv || ',"reason":"تالف","lines":[{"l":' || l_n || ',"q":7}]}');
    ok('return quantity limited to purchased', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('return quantity limited to purchased', 'NOONA-PUR-033', SQLERRM); END;
  l_ret := NOONA_PUR_PKG.post_return('{"inv":' || l_inv || ',"date":"' || l_d || '","reason":"تالف عند الاستلام","lines":[{"l":' || l_n || ',"q":2}]}');
  ok('purchase return reduces stock', NOONA_INV_PKG.on_hand(l_gen) = 4);
  ok('return journal Dr payables / Cr inventory + VAT', jl('AP_INVOICE', l_ret) = '1105:0/100 1107:0/15 2101:115/0', jl('AP_INVOICE', l_ret));
  ok('return journal typed PURCHASE_RETURN', jtype('AP_INVOICE', l_ret) = 'PURCHASE_RETURN');
  ok('return reduces the open invoice', open_amt(l_inv) = 690, open_amt(l_inv));
  BEGIN
    l_n := NOONA_PUR_PKG.post_return('{"inv":' || l_inv || ',"reason":"تالف","lines":[{"l":' || l_n || ',"q":5}]}');
    ok('cumulative returns limited', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cumulative returns limited', 'NOONA-PUR-033', SQLERRM); END;

  -- السداد
  ok('open items for payment screen', INSTR(NOONA_PUR_PKG.open_items_json(l_sup), '"open":690') > 0);
  BEGIN
    l_n := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_sup || ',"amount":100,"place":"BOX:' || l_box2 || '"}');
    ok('payment limited by box balance', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('payment limited by box balance', 'NOONA-PUR-042', SQLERRM); END;
  l_pay := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_sup || ',"date":"' || l_d || '","amount":500,"place":"BOX:' || l_box || '","method":"CASH"}');
  ok('payment applied to the oldest invoice', open_amt(l_inv) = 190 AND istatus(l_inv) = 'PARTIALLY_PAID', open_amt(l_inv) || ' ' || istatus(l_inv));
  ok('payment journal Dr payables / Cr cash', jl('AP_PAYMENT', l_pay) = '1101:0/500 2101:500/0', jl('AP_PAYMENT', l_pay));
  ok('payment journal typed SUPPLIER_PAYMENT', jtype('AP_PAYMENT', l_pay) = 'SUPPLIER_PAYMENT');
  ok('cash box reduced by the payment', NOONA_CSH_PKG.balance(l_box, NULL) = 4385, NOONA_CSH_PKG.balance(l_box, NULL));
  ok('supplier balance = invoices - returns - payments', NOONA_PUR_PKG.supplier_balance(l_sup) = 190, NOONA_PUR_PKG.supplier_balance(l_sup));
  l_c := NOONA_CSH_PKG.cash_book(l_box, NULL, TRUNC(SYSDATE), TRUNC(SYSDATE));
  ok('cash book shows the supplier payment', INSTR(l_c, 'التوريدات اختبار ' || l_sfx) > 0);
  l_n := NOONA_PUR_PKG.reverse_payment(l_pay, TRUNC(SYSDATE), 'خطأ في المبلغ');
  ok('reversed payment reopens the invoice', open_amt(l_inv) = 690 AND istatus(l_inv) = 'PARTIALLY_PAID' OR open_amt(l_inv) = 690,
     open_amt(l_inv) || ' ' || istatus(l_inv));
  ok('reversal restores the cash box', NOONA_CSH_PKG.balance(l_box, NULL) = 4885, NOONA_CSH_PKG.balance(l_box, NULL));
  ok('supplier balance after reversal', NOONA_PUR_PKG.supplier_balance(l_sup) = 690, NOONA_PUR_PKG.supplier_balance(l_sup));
  l_pay := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_sup || ',"date":"' || l_d || '","amount":690,"place":"BANK:' || l_bank
             || '","method":"BANK_APP","ref":"TRX-1","alloc":[{"inv":' || l_inv || ',"a":690}]}');
  ok('bank payment settles the invoice', open_amt(l_inv) = 0 AND istatus(l_inv) = 'PAID', istatus(l_inv));

  -- التقارير
  l_c := NOONA_PUR_PKG.supplier_statement(l_sup, TRUNC(SYSDATE) - 1, TRUNC(SYSDATE));
  ok('supplier statement', INSTR(l_c, 'فاتورة مشتريات آجل') > 0 AND INSTR(l_c, 'مرتجع مشتريات') > 0 AND INSTR(l_c, 'عكس سداد') > 0
     AND INSTR(l_c, '<td>0.00</td></tr></tfoot>') > 0, SUBSTR(l_c, -300));
  l_c := NOONA_PUR_PKG.purchase_register(TRUNC(SYSDATE), TRUNC(SYSDATE), l_sup);
  ok('purchase register nets returns', INSTR(l_c, '805.00') > 0 AND INSTR(l_c, '-115.00') > 0);
  l_c := NOONA_PUR_PKG.purchases_by_item(TRUNC(SYSDATE), TRUNC(SYSDATE));
  ok('purchases by item', INSTR(l_c, 'إطار 16 بوصة اختبار') > 0);
  l_c := NOONA_PUR_PKG.ap_aging;
  ok('AP aging report', INSTR(l_c, 'أعمار ديون الموردين') > 0);
  l_c := NOONA_PUR_PKG.invoice_print(l_inv);
  ok('invoice print with lot and amount in words', INSTR(l_c, 'L' || l_sfx) > 0 AND INSTR(l_c, 'ريال') > 0);
  ok('purchases summary', INSTR(NOONA_PUR_PKG.pur_summary, 'مستحق للموردين') > 0);

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
