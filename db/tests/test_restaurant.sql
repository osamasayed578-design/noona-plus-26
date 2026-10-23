-- =============================================================================
-- NOONA PLUS ERP | اختبار المطاعم والكافتريا بحساب NOONA_APP - يتراجع عن كل التغييرات في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_restaurant.sql
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
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_n    NUMBER;
  l_c    CLOB;
  l_r    CLOB;
  l_term NUMBER;
  l_box  NUMBER;
  l_wh   NUMBER;
  l_area NUMBER;
  l_t1   NUMBER;
  l_t2   NUMBER;
  l_cat  NUMBER;
  l_i1   NUMBER;
  l_i2   NUMBER;
  l_i3   NUMBER;
  l_o1   NUMBER;
  l_o2   NUMBER;
  l_o3   NUMBER;
  l_o4   NUMBER;
  l_o5   NUMBER;
  l_ln   NUMBER;
  l_sale NUMBER;
  l_cus  NUMBER;
  l_sh   NUMBER;
  l_j    NUMBER;
  l_rc   NUMBER;
  l_bal  NUMBER;
  l_s    VARCHAR2(4000);
  l_g1   NUMBER;
  l_g2   NUMBER;
  l_i4   NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION tot(p_o NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT total_amount INTO l FROM rst_order WHERE id = p_o; RETURN l;
  END tot;
  FUNCTION st(p_o NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT status_code INTO l FROM rst_order WHERE id = p_o; RETURN l;
  END st;
  FUNCTION js(p CLOB, k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN JSON_VALUE(p, '$.' || k);
  END js;
  FUNCTION line_of(p_o NUMBER, p_i NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM rst_order_line WHERE order_id = p_o AND item_id = p_i AND kitchen_status <> 'VOID'; RETURN l;
  END line_of;
  FUNCTION jl(p_j NUMBER, p_code VARCHAR2, p_side VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE p_side WHEN 'D' THEN l.debit_amount ELSE l.credit_amount END), 0) INTO l
      FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id WHERE l.journal_id = p_j AND a.account_code = p_code;
    RETURN l;
  END jl;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));

  -- التجهيز
  l_n := NOONA_RST_PKG.quick_setup;
  ok('restaurant ready after setup', NOONA_RST_PKG.is_ready = 'Y');
  SELECT COUNT(*) INTO l_n FROM inv_item_category WHERE code = 'MENU';
  ok('menu root category created', l_n = 1);
  -- نقطة بيع مستقلة للاختبار (لا تتعارض مع ورديات بيانات التجربة)
  SELECT MIN(warehouse_id), MIN(cash_box_id) INTO l_wh, l_box FROM pos_terminal WHERE company_id = NOONA_RST_PKG.company AND status_code = 'ACTIVE';
  l_term := NOONA_POS_PKG.create_terminal('RT' || SUBSTR(l_sfx, -5), 'كاشير المطعم ' || l_sfx, l_wh, l_box);
  l_area := NOONA_RST_PKG.save_area(NULL, 'A' || l_sfx, 'صالة اختبار ' || l_sfx, l_term, 1);
  BEGIN l_n := NOONA_RST_PKG.save_area(NULL, 'A' || l_sfx, 'مكرر', l_term); ok('duplicate area code rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate area code rejected', 'NOONA-RST-002', SQLERRM); END;
  l_n := NOONA_RST_PKG.add_tables(l_area, 3, 'Z' || SUBSTR(l_sfx, -4) || 'X', 4);
  SELECT MIN(id), MAX(id) INTO l_t1, l_t2 FROM rst_table WHERE area_id = l_area;
  SELECT COUNT(*) INTO l_n FROM rst_table WHERE area_id = l_area;
  ok('three tables generated in the area', l_n = 3, l_n);
  SELECT COUNT(*) INTO l_n FROM rst_table WHERE area_id = l_area AND code LIKE 'Z%X1' OR (area_id = l_area AND code LIKE 'Z%X3');
  ok('table codes are sequential', l_n = 2, l_n);

  -- قائمة الطعام: أسعار شاملة الضريبة
  l_cat := NOONA_RST_PKG.menu_category('MT' || SUBSTR(l_sfx, -6), 'مشروبات اختبار');
  l_i1 := NOONA_RST_PKG.save_menu_item(NULL, 'قهوة عربية اختبار ' || l_sfx, l_cat, 11.5);
  l_i2 := NOONA_RST_PKG.save_menu_item(NULL, 'برجر لحم اختبار ' || l_sfx, l_cat, 34.5);
  l_i3 := NOONA_RST_PKG.save_menu_item(NULL, 'عصير برتقال اختبار ' || l_sfx, l_cat, 23);
  SELECT COUNT(*) INTO l_n FROM inv_item WHERE id IN (l_i1, l_i2, l_i3) AND item_type = 'NON_STOCK' AND is_sellable = 'Y';
  ok('menu items created as non-stock sellable', l_n = 3, l_n);
  l_c := NOONA_RST_PKG.boot_json(l_term);
  ok('boot carries items with gross price and the area', INSTR(l_c, '"p":34.5') > 0 AND INSTR(l_c, 'صالة اختبار ' || l_sfx) > 0
     AND INSTR(l_c, '"methods"') > 0);

  -- طلب على طاولة
  BEGIN l_n := NOONA_RST_PKG.open_order('{"type":"DINE_IN","terminal":' || l_term || '}'); ok('dine-in needs a table', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('dine-in needs a table', 'NOONA-RST-015', SQLERRM); END;
  l_o1 := NOONA_RST_PKG.open_order('{"table":' || l_t1 || ',"guests":3,"waiter":"أحمد"}');
  ok('order opened on the table with its terminal', st(l_o1) = 'OPEN' AND l_o1 IS NOT NULL);
  SELECT terminal_id INTO l_n FROM rst_order WHERE id = l_o1;
  ok('order takes the area terminal', l_n = l_term);
  NOONA_RST_PKG.add_items(l_o1, '[{"i":' || l_i1 || ',"q":2},{"i":' || l_i2 || ',"q":1,"n":"بدون بصل"}]');
  NOONA_RST_PKG.add_items(l_o1, '[{"i":' || l_i1 || ',"q":1}]');
  SELECT COUNT(*), SUM(quantity) INTO l_n, l_bal FROM rst_order_line WHERE order_id = l_o1;
  ok('same item merges into the unsent line', l_n = 2 AND l_bal = 4, l_n || '/' || l_bal);
  ok('order total incl. VAT', tot(l_o1) = 69, tot(l_o1));
  SELECT tax_amount INTO l_bal FROM rst_order WHERE id = l_o1;
  ok('VAT part of the inclusive total', l_bal = 9, l_bal);
  l_c := NOONA_RST_PKG.floor_json(l_term);
  ok('floor shows the table occupied', INSTR(l_c, '"id":' || l_t1 || ',') > 0 AND INSTR(l_c, '"state":"OPEN"') > 0);

  -- المطبخ
  ok('first kitchen round', NOONA_RST_PKG.send_kitchen(l_o1) = 1);
  ok('nothing new to send', NOONA_RST_PKG.send_kitchen(l_o1) = 0);
  l_c := NOONA_RST_PKG.kitchen_json(l_term);
  ok('kitchen ticket with notes', INSTR(l_c, 'بدون بصل') > 0 AND INSTR(l_c, '"ready":"N"') > 0);
  l_ln := line_of(l_o1, l_i2);
  BEGIN NOONA_RST_PKG.set_qty(l_ln, 2); ok('sent line qty is locked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('sent line qty is locked', 'NOONA-RST-019', SQLERRM); END;
  BEGIN NOONA_RST_PKG.void_line(l_ln, NULL); ok('void of sent line needs reason', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('void of sent line needs reason', 'NOONA-RST-021', SQLERRM); END;
  NOONA_RST_PKG.add_items(l_o1, '[{"i":' || l_i3 || ',"q":1}]');
  ok('second kitchen round', NOONA_RST_PKG.send_kitchen(l_o1) = 2);
  NOONA_RST_PKG.kitchen_ready(l_o1, 1);
  SELECT COUNT(*) INTO l_n FROM rst_order_line WHERE order_id = l_o1 AND kitchen_status = 'READY';
  ok('round 1 ready', l_n = 2, l_n);
  NOONA_RST_PKG.kitchen_served(l_o1);
  SELECT COUNT(*) INTO l_n FROM rst_order_line WHERE order_id = l_o1 AND kitchen_status = 'SERVED';
  ok('all served', l_n = 3, l_n);
  ok('total after third item', tot(l_o1) = 92, tot(l_o1));

  -- طلب ثان على نفس الطاولة ثم الدمج
  l_o2 := NOONA_RST_PKG.open_order('{"table":' || l_t1 || ',"guests":1}');
  NOONA_RST_PKG.add_items(l_o2, '[{"i":' || l_i3 || ',"q":2}]');
  NOONA_RST_PKG.merge_orders(l_o2, l_o1);
  ok('merged order cancelled and lines moved', st(l_o2) = 'CANCELLED' AND tot(l_o1) = 138, st(l_o2) || ' ' || tot(l_o1));
  SELECT guests INTO l_n FROM rst_order WHERE id = l_o1;
  ok('guests added on merge', l_n = 4, l_n);

  -- تقسيم الحساب
  l_ln := line_of(l_o1, l_i1);
  l_o3 := NOONA_RST_PKG.split_order(l_o1, '[{"l":' || l_ln || ',"q":1}]');
  ok('split moved one coffee to a new bill', tot(l_o3) = 11.5 AND tot(l_o1) = 126.5, tot(l_o3) || ' / ' || tot(l_o1));
  SELECT table_id INTO l_n FROM rst_order WHERE id = l_o3;
  ok('split bill stays on the table', l_n = l_t1);
  BEGIN l_n := NOONA_RST_PKG.split_order(l_o1, '[{"l":' || l_ln || ',"q":99}]'); ok('split qty validated', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('split qty validated', 'NOONA-RST-023', SQLERRM); END;

  -- نقل الطاولة
  NOONA_RST_PKG.move_table(l_o3, l_t2);
  SELECT table_id INTO l_n FROM rst_order WHERE id = l_o3;
  ok('order moved to another table', l_n = l_t2);

  -- طباعة الحساب ثم إضافة تعيده مفتوحاً
  l_c := NOONA_RST_PKG.bill_html(l_o1);
  ok('bill printed and order marked billed', INSTR(l_c, '126.50') > 0 AND st(l_o1) = 'BILLED');
  NOONA_RST_PKG.update_order('{"id":' || l_o1 || ',"disc":10}');
  ok('10% discount on the bill', tot(l_o1) = 113.85, tot(l_o1));
  NOONA_RST_PKG.update_order('{"id":' || l_o1 || ',"disc":0}');
  ok('discount removed', tot(l_o1) = 126.5, tot(l_o1));

  -- السداد بالطاولة كاملة: نقدي + شبكة
  BEGIN l_r := NOONA_RST_PKG.settle('{"key":"k1' || l_sfx || '","table":' || l_t1 || ',"pays":[{"m":"CASH","a":50}]}'); ok('underpaid bill rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('underpaid bill rejected', 'NOONA-POS-023', SQLERRM); END;
  l_r := NOONA_RST_PKG.settle('{"key":"k2' || l_sfx || '","table":' || l_t1 || ',"pays":[{"m":"MADA","a":100,"ref":"1234"},{"m":"CASH","a":30}]}');
  l_sale := TO_NUMBER(js(l_r, 'id'));
  ok('table settled as POS receipt with change', l_sale IS NOT NULL AND TO_NUMBER(js(l_r, 'total')) = 126.5 AND TO_NUMBER(js(l_r, 'change')) = 3.5,
     DBMS_LOB.SUBSTR(l_r, 300, 1));
  ok('order paid and linked', st(l_o1) = 'PAID');
  SELECT pos_sale_id, settle_mode INTO l_n, l_s FROM rst_order WHERE id = l_o1;
  ok('settle mode PAID and sale link', l_n = l_sale AND l_s = 'PAID');
  SELECT COUNT(*) INTO l_n FROM pos_sale_line WHERE sale_id = l_sale;
  ok('receipt lines match the bill', l_n = 4, l_n);
  l_r := NOONA_RST_PKG.settle('{"key":"k2' || l_sfx || '","table":' || l_t1 || ',"pays":[{"m":"CASH","a":200}]}');
  ok('same key returns the same receipt', TO_NUMBER(js(l_r, 'id')) = l_sale);
  BEGIN NOONA_RST_PKG.add_items(l_o1, '[{"i":' || l_i1 || ',"q":1}]'); ok('paid order is locked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('paid order is locked', 'NOONA-RST-011', SQLERRM); END;
  l_c := NOONA_RST_PKG.floor_json(l_term);
  ok('table 1 free after payment', INSTR(l_c, '"id":' || l_t1 || ',"code"') > 0 AND INSTR(l_c, '"state":"FREE"') > 0);
  SELECT shift_id INTO l_sh FROM pos_sale WHERE id = l_sale;
  ok('shift auto-opened for the cashier', NOONA_POS_PKG.current_shift(l_term) = l_sh);

  -- سفري سريع: يرسل للمطبخ مع السداد
  l_o4 := NOONA_RST_PKG.open_order('{"type":"TAKEAWAY","terminal":' || l_term || ',"name":"سفري 1"}');
  NOONA_RST_PKG.add_items(l_o4, '[{"i":' || l_i2 || ',"q":2}]');
  l_r := NOONA_RST_PKG.settle('{"key":"k3' || l_sfx || '","orders":[' || l_o4 || '],"pays":[{"m":"CASH","a":69}]}');
  SELECT COUNT(*) INTO l_n FROM rst_order_line WHERE order_id = l_o4 AND kitchen_status = 'SENT';
  ok('takeaway paid and sent to kitchen', st(l_o4) = 'PAID' AND l_n = 1, st(l_o4) || ' ' || l_n);

  -- آجل على العميل
  l_o5 := NOONA_RST_PKG.open_order('{"type":"DELIVERY","terminal":' || l_term || ',"phone":"0500000000","addr":"حي النرجس"}');
  NOONA_RST_PKG.add_items(l_o5, '[{"i":' || l_i2 || ',"q":1},{"i":' || l_i3 || ',"q":1}]');
  BEGIN l_r := NOONA_RST_PKG.settle('{"key":"k4' || l_sfx || '","orders":[' || l_o5 || '],"pays":[{"m":"CREDIT","a":57.5}]}');
    ok('credit needs a registered customer', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('credit needs a registered customer', 'NOONA-RST-033', SQLERRM); END;
  l_cus := NOONA_RST_PKG.quick_customer('عميل مطعم اختبار ' || l_sfx, '0551234567', 500);
  l_c := NOONA_RST_PKG.credit_customers_json('مطعم اختبار ' || l_sfx);
  ok('credit customer searchable with phone', INSTR(l_c, '0551234567') > 0);
  l_r := NOONA_RST_PKG.settle('{"key":"k5' || l_sfx || '","orders":[' || l_o5 || '],"cust":' || l_cus || ',"pays":[{"m":"CREDIT","a":57.5}]}');
  SELECT settle_mode, customer_account_id INTO l_s, l_n FROM rst_order WHERE id = l_o5;
  ok('order charged to the customer', st(l_o5) = 'CHARGED' AND l_s = 'CREDIT' AND l_n = l_cus);
  ok('customer balance carries the credit sale', NOONA_SAL_PKG.customer_balance(l_cus) = 57.5, NOONA_SAL_PKG.customer_balance(l_cus));
  -- حد الائتمان
  l_o2 := NOONA_RST_PKG.open_order('{"type":"TAKEAWAY","terminal":' || l_term || ',"cust":' || l_cus || '}');
  NOONA_RST_PKG.add_items(l_o2, '[{"i":' || l_i2 || ',"q":20}]');
  BEGIN l_r := NOONA_RST_PKG.settle('{"key":"k6' || l_sfx || '","orders":[' || l_o2 || '],"pays":[{"m":"CREDIT","a":690}]}');
    ok('credit limit enforced', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('credit limit enforced', 'NOONA-SAL-031', SQLERRM); END;
  -- جزء آجل وجزء نقدي (العميل من الطلب)
  NOONA_RST_PKG.set_qty(line_of(l_o2, l_i2), 2);
  l_r := NOONA_RST_PKG.settle('{"key":"k7' || l_sfx || '","orders":[' || l_o2 || '],"pays":[{"m":"CASH","a":19},{"m":"CREDIT","a":50}]}');
  SELECT settle_mode INTO l_s FROM rst_order WHERE id = l_o2;
  ok('mixed cash and credit', st(l_o2) = 'CHARGED' AND l_s = 'MIXED' AND NOONA_SAL_PKG.customer_balance(l_cus) = 107.5,
     l_s || ' ' || NOONA_SAL_PKG.customer_balance(l_cus));
  l_c := NOONA_RST_PKG.credit_html('مطعم اختبار ' || l_sfx);
  ok('credit customers list with collect action', INSTR(l_c, 'data-collect="' || l_cus || '"') > 0 AND INSTR(l_c, '107.50') > 0);

  -- التحصيل من العميل الآجل
  BEGIN l_rc := NOONA_RST_PKG.collect('{"cust":' || l_cus || ',"amount":0}'); ok('collection amount required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('collection amount required', 'NOONA-SAL-051', SQLERRM); END;
  l_rc := NOONA_RST_PKG.collect('{"cust":' || l_cus || ',"amount":60,"method":"CASH","notes":"تحصيل مطعم"}');
  ok('collection reduces the balance', NOONA_SAL_PKG.customer_balance(l_cus) = 47.5, NOONA_SAL_PKG.customer_balance(l_cus));
  SELECT COUNT(*) INTO l_n FROM ar_open_item WHERE customer_account_id = l_cus AND status_code = 'PAID';
  ok('oldest credit receipt fully settled', l_n = 1, l_n);
  SELECT j.id INTO l_j FROM ar_receipt r JOIN gl_journal j ON j.accounting_event_id = r.accounting_event_id WHERE r.id = l_rc;
  ok('collection journal Dr cash Cr receivable', jl(l_j, '1103', 'C') = 60, jl(l_j, '1103', 'C'));

  -- الإلغاء
  l_o2 := NOONA_RST_PKG.open_order('{"table":' || l_t2 || '}');
  NOONA_RST_PKG.add_items(l_o2, '[{"i":' || l_i1 || ',"q":1}]');
  l_n := NOONA_RST_PKG.send_kitchen(l_o2);
  BEGIN NOONA_RST_PKG.cancel_order(l_o2, NULL); ok('cancel after kitchen needs reason', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cancel after kitchen needs reason', 'NOONA-RST-025', SQLERRM); END;
  NOONA_RST_PKG.cancel_order(l_o2, 'العميل غادر');
  ok('order cancelled with reason', st(l_o2) = 'CANCELLED');

  -- السداد بالطلب على طاولة بها طلبان: طلب واحد فقط
  l_r := NOONA_RST_PKG.settle('{"key":"k8' || l_sfx || '","orders":[' || l_o3 || '],"pays":[{"m":"CASH","a":11.5}]}');
  ok('single order on a table settled alone', st(l_o3) = 'PAID');

  -- ======================================================== الخصم من المخزون: الوصفات والأصناف المخزنية
  l_cat := NOONA_INV_PKG.create_category('IG' || SUBSTR(l_sfx, -6), 'مواد خام المطبخ اختبار', 'FOOD');
  SELECT id INTO l_n FROM inv_uom WHERE code = 'KG';
  l_g1 := NOONA_INV_PKG.save_item('{"name":"صدر دجاج اختبار ' || l_sfx || '","type":"STOCK","cat":' || l_cat || ',"uom":' || l_n || ',"sell":"N"}');
  l_g2 := NOONA_INV_PKG.save_item('{"name":"خبز برجر اختبار ' || l_sfx || '","type":"STOCK","cat":' || l_cat || ',"sell":"N"}');
  l_i4 := NOONA_RST_PKG.save_menu_item(NULL, 'مياه معدنية اختبار ' || l_sfx, NULL, 3, 'ACTIVE', 'STOCK');
  ok('stock menu item sold as is', NOONA_INV_PKG.is_stocked(l_i4) = 'Y' AND NOONA_INV_PKG.is_stocked(l_i2) = 'N');
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_wh || ',"action":"POST",'
         || '"lines":[{"i":' || l_g1 || ',"q":10,"c":20},{"i":' || l_g2 || ',"q":50,"c":1.5},{"i":' || l_i4 || ',"q":24,"c":1}]}');
  ok('opening stock of ingredients', NOONA_INV_PKG.on_hand(l_g1, l_wh) = 10 AND NOONA_INV_PKG.on_hand(l_g2, l_wh) = 50);
  BEGIN NOONA_RST_PKG.recipe_set(l_i2, l_i1, 1); ok('recipe component must be stocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('recipe component must be stocked', 'NOONA-RST-042', SQLERRM); END;
  BEGIN NOONA_RST_PKG.recipe_set(l_i4, l_g1, 1); ok('stock item takes no recipe', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('stock item takes no recipe', 'NOONA-RST-043', SQLERRM); END;
  NOONA_RST_PKG.recipe_set(l_i2, l_g1, 0.15);
  NOONA_RST_PKG.recipe_set(l_i2, l_g2, 1);
  NOONA_RST_PKG.recipe_set(l_i2, l_g2, 2);      -- تعديل كمية مكون قائم
  NOONA_RST_PKG.recipe_set(l_i2, l_g2, 1);
  ok('recipe cost per portion', NOONA_RST_PKG.recipe_cost(l_i2) = 4.5, NOONA_RST_PKG.recipe_cost(l_i2));
  ok('recipe card with cost ratio', INSTR(NOONA_RST_PKG.recipe_html(l_i2), 'نسبة التكلفة') > 0
     AND INSTR(NOONA_RST_PKG.recipe_html(l_i4), 'صنف مخزني') > 0);
  l_o2 := NOONA_RST_PKG.open_order('{"type":"TAKEAWAY","terminal":' || l_term || '}');
  NOONA_RST_PKG.add_items(l_o2, '[{"i":' || l_i2 || ',"q":2},{"i":' || l_i4 || ',"q":3}]');
  l_r := NOONA_RST_PKG.settle('{"key":"k9' || l_sfx || '","orders":[' || l_o2 || '],"pays":[{"m":"CASH","a":78}]}');
  ok('ingredients issued by recipe', NOONA_INV_PKG.on_hand(l_g1, l_wh) = 9.7 AND NOONA_INV_PKG.on_hand(l_g2, l_wh) = 48,
     NOONA_INV_PKG.on_hand(l_g1, l_wh) || ' / ' || NOONA_INV_PKG.on_hand(l_g2, l_wh));
  ok('stock menu item issued', NOONA_INV_PKG.on_hand(l_i4, l_wh) = 21, NOONA_INV_PKG.on_hand(l_i4, l_wh));
  l_sale := TO_NUMBER(js(l_r, 'id'));
  SELECT MAX(CASE WHEN item_id = l_i2 THEN unit_cost END), MAX(CASE WHEN item_id = l_i4 THEN unit_cost END) INTO l_bal, l_n
    FROM pos_sale_line WHERE sale_id = l_sale;
  ok('sale line cost = recipe cost', l_bal = 4.5 AND l_n = 1, l_bal || ' / ' || l_n);
  -- نقص المكونات يمنع البيع ولا يترك أثراً
  l_o2 := NOONA_RST_PKG.open_order('{"type":"TAKEAWAY","terminal":' || l_term || '}');
  NOONA_RST_PKG.add_items(l_o2, '[{"i":' || l_i2 || ',"q":100}]');
  BEGIN l_r := NOONA_RST_PKG.settle('{"key":"k10' || l_sfx || '","orders":[' || l_o2 || '],"pays":[{"m":"CASH","a":3450}]}');
    ok('not enough ingredient stock', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('not enough ingredient stock', 'NOONA-INV-025', SQLERRM); END;
  SELECT COUNT(*) INTO l_n FROM rst_order_line WHERE order_id = l_o2 AND kitchen_status = 'NEW';
  ok('failed settle leaves the order open and unsent', st(l_o2) = 'OPEN' AND l_n = 1);
  NOONA_RST_PKG.cancel_order(l_o2, NULL);
  -- حذف مكون
  NOONA_RST_PKG.recipe_remove(l_i2, l_g2);
  ok('component removed from recipe', NOONA_RST_PKG.recipe_cost(l_i2) = 3, NOONA_RST_PKG.recipe_cost(l_i2));

  -- إقفال الوردية: القيد يتضمن الآجل على ذمة العميل
  l_j := NOONA_POS_PKG.close_shift(l_sh, NOONA_POS_PKG.expected_cash(l_sh));
  ok('shift closed with journal', l_j IS NOT NULL);
  ok('shift journal debits receivable for credit sales', jl(l_j, '1103', 'D') = 107.5, jl(l_j, '1103', 'D'));
  -- 9 مكونات الوجبات (2 × 4.5) + 3 مياه مخزنية: من حـ/ تكلفة المبيعات إلى حـ/ المخزون
  ok('shift journal: COGS to inventory for recipes and stock items', jl(l_j, '1105', 'C') = 12 AND jl(l_j, '5101', 'D') = 12,
     jl(l_j, '1105', 'C') || ' / ' || jl(l_j, '5101', 'D'));
  SELECT SUM(debit_amount) - SUM(credit_amount) INTO l_n FROM gl_journal_line WHERE journal_id = l_j;
  ok('shift journal balanced', l_n = 0, l_n);

  -- اللوحات
  l_c := NOONA_RST_PKG.dashboard_html(TRUNC(SYSDATE), TRUNC(SYSDATE), l_term);
  ok('dashboard shows sales and breakdowns', INSTR(l_c, '411.50') > 0 AND INSTR(l_c, '<b>6</b>') > 0 AND INSTR(l_c, 'سفري') > 0 AND INSTR(l_c, 'برجر لحم اختبار') > 0
     AND INSTR(l_c, 'المبيعات الآجلة حسب العميل') > 0, DBMS_LOB.SUBSTR(l_c, 400, 1));
  ok('today summary renders', DBMS_LOB.GETLENGTH(NOONA_RST_PKG.today_html) > 300);
  ok('labels', NOONA_RST_PKG.type_label('TAKEAWAY') = 'سفري' AND NOONA_RST_PKG.status_label('CHARGED') = 'آجل على العميل');

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
