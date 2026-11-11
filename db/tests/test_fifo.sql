-- =============================================================================
-- NOONA PLUS ERP | اختبار الصرف بطريقة FIFO بحساب NOONA_APP - يتراجع في النهاية
--   التحول إلى FIFO بطبقة الرصيد القائم، الصرف من الأقدم، الإتلاف، التحويل بين المستودعات، القيد، العودة للمتوسط، الفئة
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_fifo.sql
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

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(6) := TO_CHAR(MOD(TO_NUMBER(TO_CHAR(SYSTIMESTAMP, 'SSFF3')), 90000) + 10000);
  l_d    VARCHAR2(10) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');
  l_wh NUMBER; l_wh2 NUMBER; l_cc NUMBER; l_it NUMBER; l_it2 NUMBER; l_cat NUMBER; l_t NUMBER; l_n NUMBER; l_x NUMBER; l_s VARCHAR2(4000);
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  FUNCTION doc(p_type VARCHAR2, p_lines VARCHAR2, p_extra VARCHAR2 DEFAULT NULL, p_wh NUMBER DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_INV_PKG.save_stock_doc('{"id":null,"type":"' || p_type || '","date":"' || l_d || '","wh":' || NVL(p_wh, l_wh) || p_extra
      || ',"action":"POST","lines":[' || p_lines || ']}');
  END doc;
  FUNCTION cost_of(p_txn NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT SUM(ABS(total_cost)) INTO l FROM inv_transaction_line WHERE transaction_id = p_txn AND item_id = l_it; RETURN l;
  END cost_of;
  FUNCTION layers RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(remaining_qty || '@' || unit_cost, ',') WITHIN GROUP (ORDER BY layer_date, id) INTO l
      FROM inv_cost_layer WHERE item_id = l_it AND company_id = NOONA_INV_PKG.company AND status_code = 'OPEN' AND remaining_qty > 0;
    RETURN l;
  END layers;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_INV_PKG.quick_setup;
  l_wh := NOONA_INV_PKG.create_warehouse('FA' || l_sfx, 'مستودع FIFO', 'MAIN');
  l_wh2 := NOONA_INV_PKG.create_warehouse('FB' || l_sfx, 'مستودع FIFO 2', 'STORE');
  SELECT MIN(id) INTO l_cc FROM gl_cost_center WHERE company_id = NOONA_INV_PKG.company;
  SELECT id INTO l_cat FROM inv_item_category WHERE code = 'AUTO';
  l_it := NOONA_INV_PKG.save_item('{"name":"إطار FIFO ' || l_sfx || '","code":"FI' || l_sfx || '","cat":' || l_cat || ',"price":900}');
  ok('new item defaults to weighted average', NOONA_INV_PKG.costing_method(l_it) = 'WEIGHTED_AVERAGE');

  l_t := doc('OPENING', '{"i":' || l_it || ',"q":10,"c":10}');
  l_n := NOONA_INV_PKG.set_costing_method(l_it, NULL, 'FIFO');
  ok('switched item to FIFO', l_n = 1 AND NOONA_INV_PKG.costing_method(l_it) = 'FIFO');
  l_t := doc('ADJ_IN', '{"i":' || l_it || ',"q":10,"c":20}', ',"reason":"COUNT"');
  ok('existing stock became the first layer, new receipt a second layer', layers = '10@10,10@20', layers);
  l_t := doc('CONSUMPTION', '{"i":' || l_it || ',"q":15}', ',"cc":' || l_cc);
  ok('FIFO issue 15 = 10 x 10 + 5 x 20 = 200 (average would be 225)', cost_of(l_t) = 200, cost_of(l_t));
  ok('remaining layer 5 @ 20', layers = '5@20', layers);
  SELECT average_cost INTO l_x FROM inv_item_cost WHERE item_id = l_it AND company_id = NOONA_INV_PKG.company AND warehouse_id IS NULL;
  ok('item cost now equals remaining layer cost', l_x = 20, l_x);
  SELECT SUM(jl.credit_amount) INTO l_x FROM inv_transaction t JOIN ace_accounting_event e ON e.id = t.accounting_event_id
    JOIN gl_journal_line jl ON jl.journal_id = e.journal_id WHERE t.id = l_t;
  ok('journal credits inventory with FIFO cost 200', l_x = 200, l_x);

  l_t := doc('ADJ_IN', '{"i":' || l_it || ',"q":5,"c":30}', ',"reason":"COUNT"');
  l_t := doc('TRANSFER_OUT', '{"i":' || l_it || ',"q":2}', ',"toWh":' || l_wh2);
  ok('transfer between warehouses keeps layers', layers = '5@20,5@30', layers);
  l_t := doc('SCRAP', '{"i":' || l_it || ',"q":7}', ',"reason":"DAMAGED"');
  ok('scrap 7 = 5 x 20 + 2 x 30 = 160', cost_of(l_t) = 160, cost_of(l_t));
  ok('remaining 3 @ 30', layers = '3@30', layers);
  ok('layers page', DBMS_LOB.INSTR(NOONA_INV_PKG.fifo_layers_html(l_it), '90.00') > 0);

  l_n := NOONA_INV_PKG.set_costing_method(l_it, NULL, 'WEIGHTED_AVERAGE');
  ok('back to weighted average closes the layers', layers IS NULL AND NOONA_INV_PKG.costing_method(l_it) = 'WEIGHTED_AVERAGE');
  l_t := doc('CONSUMPTION', '{"i":' || l_it || ',"q":1}', ',"cc":' || l_cc, l_wh2);
  ok('weighted average issue after switching back (30)', cost_of(l_t) = 30, cost_of(l_t));

  -- الفئة كاملة: تتغير أصنافها ويصبح افتراضي الجديدة
  l_n := NOONA_INV_PKG.set_costing_method(NULL, l_cat, 'FIFO');
  ok('category switch changed its items', l_n >= 1 AND NOONA_INV_PKG.costing_method(l_it) = 'FIFO', l_n);
  l_it2 := NOONA_INV_PKG.save_item('{"name":"بطارية FIFO ' || l_sfx || '","code":"FB' || l_sfx || '","cat":' || l_cat || ',"price":500}');
  ok('new item in FIFO category is FIFO', NOONA_INV_PKG.costing_method(l_it2) = 'FIFO');
  BEGIN
    l_n := NOONA_INV_PKG.set_costing_method(l_it, NULL, 'LIFO');
    ok('LIFO rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('LIFO rejected', INSTR(SQLERRM, 'NOONA-INV-092') > 0, SQLERRM);
  END;

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
