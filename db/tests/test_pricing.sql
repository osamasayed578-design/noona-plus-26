-- =============================================================================
-- NOONA PLUS ERP | اختبار التسعير الموحد بحساب NOONA_APP - يتراجع في النهاية
--   سعر البيع من التكلفة (نسبة، هامش، مبلغ، معامل، تقريب)، تكلفة الخدمة ببطاقة التكلفة، السياسات وأولويتها،
--   إعادة التسعير وسجل الأسعار، العروض (نسبة، اشتر واحصل، كوبون، قناة، ساعات، سقف، قيمة الفاتورة)، والباقات وتوزيع سعرها
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_pricing.sql
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
  l_sfx  VARCHAR2(4) := TO_CHAR(MOD(TO_NUMBER(TO_CHAR(SYSTIMESTAMP, 'SSFF3')), 9000) + 1000);
  l_item  NUMBER;
  l_item2 NUMBER;
  l_cat   NUMBER;
  l_svc   NUMBER;
  l_stp   VARCHAR2(30);
  l_cost  NUMBER;
  l_base  NUMBER;
  l_pol   NUMBER;
  l_pol2  NUMBER;
  l_run   NUMBER;
  l_line  NUMBER;
  l_n     NUMBER;
  l_p     NUMBER;
  l_pr    NUMBER;
  l_b     NUMBER;
  l_j     JSON_OBJECT_T;
  l_a     JSON_ARRAY_T;
  l_sum   NUMBER;
  l_s     VARCHAR2(4000);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  -- يتوقع رفضاً برمز معين
  PROCEDURE rejects(p_name VARCHAR2, p_code VARCHAR2, p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    ok(p_name, FALSE, 'accepted');
  EXCEPTION WHEN OTHERS THEN
    ok(p_name, INSTR(SQLERRM, p_code) > 0, SUBSTR(SQLERRM, 1, 200));
  END rejects;
  FUNCTION jnum(p_doc CLOB, p_k VARCHAR2) RETURN NUMBER IS
    l JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
  BEGIN
    RETURN CASE WHEN l.has(p_k) AND NOT l.get(p_k).is_null THEN l.get_number(p_k) END;
  END jnum;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));

  -- ---------------------------------------------------------------- سعر البيع من التكلفة
  ok('markup 25% on 100 = 125', NOONA_PRC_PKG.price_from_cost(100, 'MARKUP_PCT', 25) = 125);
  ok('margin 20% of price on cost 100 = 125', NOONA_PRC_PKG.price_from_cost(100, 'MARGIN_PCT', 20) = 125);
  ok('fixed amount 30 over cost 100 = 130', NOONA_PRC_PKG.price_from_cost(100, 'FIXED_AMOUNT', 30) = 130);
  ok('multiplier 1.5 on 100 = 150', NOONA_PRC_PKG.price_from_cost(100, 'MULTIPLIER', 1.5) = 150);
  ok('round up to 0.50: 12.30 -> 12.50', NOONA_PRC_PKG.round_price(12.30, 'R050') = 12.5);
  ok('round up to 5: 123 -> 125', NOONA_PRC_PKG.round_price(123, 'R5') = 125);
  ok('ending .99: 12.30 -> 12.99', NOONA_PRC_PKG.round_price(12.30, 'END99') = 12.99);
  ok('round to 0.05 keeps exact 12.35', NOONA_PRC_PKG.round_price(12.35, 'R005') = 12.35);
  ok('markup 40% rounded to 1: cost 7.10 -> 10', NOONA_PRC_PKG.price_from_cost(7.10, 'MARKUP_PCT', 40, 'R1') = 10);

  -- ---------------------------------------------------------------- صنف بتكلفة: السياسات وأولويتها
  SELECT MIN(c.item_id) KEEP (DENSE_RANK FIRST ORDER BY c.item_id) INTO l_item
    FROM inv_item_company c JOIN inv_item i ON i.id = c.item_id
   WHERE c.company_id = NOONA_PRC_PKG.company AND i.status_code = 'ACTIVE' AND NVL(i.is_sellable, 'Y') = 'Y'
     AND NVL(c.prices_include_tax, 'N') = 'N' AND NOONA_PRC_PKG.cost_of('ITEM', c.item_id) > 0;
  IF l_item IS NULL THEN
    -- البيئة بلا صنف بسعر غير شامل للضريبة وله تكلفة: ينشأ صنف للاختبار برصيد وتكلفة (يتراجع في النهاية)
    l_item := NOONA_INV_PKG.save_item('{"name":"صنف اختبار التسعير","code":"PRC-T' || TO_CHAR(SYSTIMESTAMP, 'SSFF3') || '","price":20,"incl":"N"}');
    DECLARE l_d NUMBER; BEGIN
      l_d := NOONA_INV_PKG.save_stock_doc('{"id":null,"type":"ADJ_IN","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || NOONA_INV_PKG.default_warehouse
          || ',"reason":"COUNT","action":"POST","lines":[{"i":' || l_item || ',"q":50,"c":10}]}');
    END;
  END IF;
  ok('an active sellable item with cost exists', l_item IS NOT NULL);
  SELECT category_id INTO l_cat FROM inv_item WHERE id = l_item;
  l_cost := NOONA_PRC_PKG.cost_of('ITEM', l_item);
  ok('average cost basis = default cost', NOONA_PRC_PKG.cost_of('ITEM', l_item, 'AVERAGE') = l_cost);

  l_pol2 := NOONA_PRC_PKG.save_policy('{"code":"TCAT' || l_sfx || '","name":"فئة","targetType":"ITEM_CATEGORY","targetId":' || l_cat
          || ',"method":"MARKUP_PCT","value":10,"priority":1}');
  l_pol := NOONA_PRC_PKG.save_policy('{"code":"TITM' || l_sfx || '","name":"صنف","targetType":"ITEM","targetId":' || l_item
          || ',"method":"MARKUP_PCT","value":50,"minMargin":10,"rounding":"R1","priority":500}');
  ok('item policy wins over category policy (more specific)', NOONA_PRC_PKG.policy_for('ITEM', l_item) = l_pol);
  l_p := jnum(NOONA_PRC_PKG.suggest_json('ITEM', l_item), 'price');
  ok('suggested price = cost x 1.5 rounded up to 1', l_p = CEIL(ROUND(l_cost * 1.5, 6)), l_p || ' cost ' || l_cost);
  ok('suggested min price = cost x 1.10', ABS(jnum(NOONA_PRC_PKG.suggest_json('ITEM', l_item), 'minPrice') - ROUND(l_cost * 1.1, 2)) < 0.01);
  NOONA_PRC_PKG.set_policy_status(l_pol, 'INACTIVE');
  ok('inactive item policy falls back to category', NOONA_PRC_PKG.policy_for('ITEM', l_item) = l_pol2);
  NOONA_PRC_PKG.set_policy_status(l_pol, 'ACTIVE');
  ok('policy text describes method', NOONA_PRC_PKG.policy_text(l_pol) LIKE '%التكلفة + 50%%');

  -- ---------------------------------------------------------------- إعادة التسعير
  l_base := NOONA_PRC_PKG.current_price('ITEM', l_item);
  UPDATE inv_item_company SET sale_price = 0.01 WHERE item_id = l_item AND company_id = NOONA_PRC_PKG.company;
  l_run := NOONA_PRC_PKG.new_run('ITEMS');
  SELECT MAX(id), MAX(new_price) INTO l_line, l_p FROM sal_price_run_line WHERE run_id = l_run AND target_type = 'ITEM' AND target_id = l_item;
  ok('run proposes the item new price', l_line IS NOT NULL AND l_p = CEIL(ROUND(l_cost * 1.5, 6)));
  NOONA_PRC_PKG.set_run_line(l_line, 'Y', l_p + 3);
  SELECT COUNT(*) INTO l_n FROM sal_price_run_line WHERE run_id = l_run AND id <> l_line;
  UPDATE sal_price_run_line SET is_selected = 'N' WHERE run_id = l_run AND id <> l_line;
  l_n := NOONA_PRC_PKG.apply_run(l_run);
  ok('apply run updates exactly the selected line', l_n = 1);
  ok('item price = reviewed price', NOONA_PRC_PKG.current_price('ITEM', l_item) = l_p + 3);
  SELECT COUNT(*) INTO l_n FROM sal_price_history WHERE run_id = l_run AND target_id = l_item AND old_price = 0.01 AND new_price = l_p + 3;
  ok('price history keeps old and new', l_n = 1);
  rejects('applied run cannot be applied again', 'NOONA-PRC-023', 'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.apply_run(' || l_run || '); END;');
  NOONA_PRC_PKG.set_price('ITEM', l_item, 99, 90);
  ok('manual price change', NOONA_PRC_PKG.current_price('ITEM', l_item) = 99);
  rejects('min price above price rejected', 'NOONA-PRC-024', 'BEGIN NOONA_PRC_PKG.set_price(''ITEM'', ' || l_item || ', 50, 60); END;');
  rejects('margin of 100% rejected', 'NOONA-PRC-014',
    'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_policy(''{"code":"X' || l_sfx || '","name":"x","targetType":"ALL_ITEMS","method":"MARGIN_PCT","value":100}''); END;');
  rejects('multiplier below 1 rejected', 'NOONA-PRC-015',
    'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_policy(''{"code":"Y' || l_sfx || '","name":"x","targetType":"ALL_ITEMS","method":"MULTIPLIER","value":0.8}''); END;');
  -- أدنى سعر البيع: يقيد الخصم اليدوي، ولا يقيد خصم العرض/الباقة/الكوبون المعتمد
  DECLARE l_pp NUMBER; l_ii VARCHAR2(1); l_tc NUMBER; l_nn NUMBER; l_tt NUMBER; BEGIN
    UPDATE inv_item_company SET sale_price = 100, min_sale_price = 90 WHERE item_id = l_item AND company_id = NOONA_PRC_PKG.company;
    l_pp := 100; l_ii := 'N';
    NOONA_SAL_PKG.price_line(l_item, 1, l_pp, 20, l_ii, l_tc, TRUNC(SYSDATE), l_nn, l_tt, 20);
    ok('approved promotion discount may go below the minimum price', l_nn = 80);
    BEGIN
      l_pp := 100; l_tc := NULL;
      NOONA_SAL_PKG.price_line(l_item, 1, l_pp, 20, l_ii, l_tc, TRUNC(SYSDATE), l_nn, l_tt, 5);
      ok('manual part of the discount still respects the minimum price', FALSE, 'accepted');
    EXCEPTION WHEN OTHERS THEN ok('manual part of the discount still respects the minimum price', INSTR(SQLERRM, 'NOONA-SAL-015') > 0, SQLERRM);
    END;
  END;
  ok('margin report lists items', DBMS_LOB.INSTR(NOONA_PRC_PKG.margin_html('ITEMS'), 'nn-rpt') > 0);

  -- ---------------------------------------------------------------- تكلفة الخدمة الطبية ببطاقة التكلفة
  SELECT MIN(id) INTO l_svc FROM his_service WHERE company_id = NOONA_PRC_PKG.company AND status_code = 'ACTIVE';
  IF l_svc IS NOT NULL THEN
    SELECT service_type INTO l_stp FROM his_service WHERE id = l_svc;
    DELETE FROM sal_cost_element WHERE target_type = 'HIS_SERVICE' AND target_id = l_svc;
    l_base := NOONA_PRC_PKG.service_cost('HIS_SERVICE', l_svc);  -- مواد الخدمة المعرفة في دليل الخدمات
    l_n := NOONA_PRC_PKG.save_cost_element('{"targetType":"HIS_SERVICE","targetId":' || l_svc || ',"type":"LABOR","desc":"وقت الطبيب","minutes":30,"rate":120}');
    l_n := NOONA_PRC_PKG.save_cost_element('{"targetType":"HIS_SERVICE","targetId":' || l_svc || ',"type":"OVERHEAD_AMOUNT","desc":"تشغيل العيادة","amount":15}');
    l_n := NOONA_PRC_PKG.save_cost_element('{"targetType":"HIS_SERVICE","targetId":' || l_svc || ',"type":"OVERHEAD_PCT","desc":"إدارية","pct":10}');
    l_cost := NOONA_PRC_PKG.service_cost('HIS_SERVICE', l_svc);
    ok('service cost = (materials + 30min x 120/h + 15) x 1.10', ABS(l_cost - ROUND((l_base + 60 + 15) * 1.1, 4)) < 0.001, l_cost || ' base ' || l_base);
    ok('cost sheet html shows labor', DBMS_LOB.INSTR(NOONA_PRC_PKG.cost_html('HIS_SERVICE', l_svc), 'عمالة') > 0);
    rejects('labor without minutes rejected', 'NOONA-PRC-005',
      'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_cost_element(''{"targetType":"HIS_SERVICE","targetId":' || l_svc || ',"type":"LABOR","rate":50}''); END;');
    l_pol := NOONA_PRC_PKG.save_policy('{"code":"THIS' || l_sfx || '","name":"خدمات","targetType":"HIS_SERVICE_TYPE","targetCode":"' || l_stp
           || '","basis":"COST_SHEET","method":"MARGIN_PCT","value":40,"rounding":"R5","priority":1}');
    ok('service type policy applies to the service', NOONA_PRC_PKG.policy_for('HIS_SERVICE', l_svc) = l_pol);
    l_p := jnum(NOONA_PRC_PKG.suggest_json('HIS_SERVICE', l_svc), 'price');
    ok('service price = cost / 0.60 rounded up to 5', l_p = CEIL(ROUND(l_cost / 0.6 / 5, 6)) * 5, l_p || ' cost ' || l_cost);
    l_run := NOONA_PRC_PKG.new_run('HIS', 'N');
    SELECT COUNT(*) INTO l_n FROM sal_price_run_line WHERE run_id = l_run AND target_type = 'HIS_SERVICE' AND target_id = l_svc AND new_price = l_p;
    ok('HIS run proposes the service price', l_n = 1);
  ELSE
    ok('HIS services exist for this company (skipped)', TRUE);
  END IF;

  -- ---------------------------------------------------------------- العروض
  UPDATE sal_promotion SET status_code = 'PAUSED' WHERE company_id = NOONA_PRC_PKG.company AND status_code = 'ACTIVE';
  l_pr := NOONA_PRC_PKG.save_promotion('{"code":"P10' || l_sfx || '","name":"خصم 10%","type":"PCT_OFF","value":10,"channels":"POS,SALES",'
        || '"targets":[{"type":"ITEM","id":' || l_item || '}]}');
  ok('10% off: 2 x 100 -> 20', NOONA_PRC_PKG.line_discount('ITEM', l_item, 2, 100, 'POS') = 20);
  ok('channel not included -> no discount', NOONA_PRC_PKG.line_discount('ITEM', l_item, 2, 100, 'HIS') = 0);
  ok('line promo json carries net', jnum(NOONA_PRC_PKG.line_promo('ITEM', l_item, 2, 100, 'POS'), 'net') = 180);
  l_b := NOONA_PRC_PKG.save_promotion('{"code":"BXG' || l_sfx || '","name":"اشتر 2 واحصل على 1","type":"BUY_X_GET_Y","buyQty":2,"getQty":1,'
        || '"targets":[{"type":"ITEM_CATEGORY","id":' || l_cat || '}]}');
  ok('buy 2 get 1: 6 x 10 -> 20 (best of the two)', NOONA_PRC_PKG.line_discount('ITEM', l_item, 6, 10, 'POS') = 20);
  ok('buy 2 get 1: 2 units -> 10% only', NOONA_PRC_PKG.line_discount('ITEM', l_item, 2, 10, 'POS') = 2);
  UPDATE sal_promotion SET stackable = 'Y' WHERE id IN (l_pr, l_b);
  ok('stackable promotions add up: 6 x 10 -> 6 + 20', NOONA_PRC_PKG.line_discount('ITEM', l_item, 6, 10, 'POS') = 26);
  UPDATE sal_promotion SET stackable = 'N', max_discount = 15 WHERE id IN (l_pr, l_b);
  ok('max discount caps the promotion', NOONA_PRC_PKG.line_discount('ITEM', l_item, 6, 10, 'POS') = 15);
  UPDATE sal_promotion SET status_code = 'PAUSED' WHERE id IN (l_pr, l_b);
  l_pr := NOONA_PRC_PKG.save_promotion('{"code":"CPN' || l_sfx || '","name":"كوبون","type":"AMOUNT_OFF","value":5,"coupon":"vip' || l_sfx || '",'
        || '"targets":[{"type":"ALL_ITEMS"}]}');
  ok('coupon promotion needs the coupon', NOONA_PRC_PKG.line_discount('ITEM', l_item, 3, 20, 'POS') = 0);
  ok('coupon promotion with coupon: 3 x 5', NOONA_PRC_PKG.line_discount('ITEM', l_item, 3, 20, 'POS', 'VIP' || l_sfx) = 15);
  UPDATE sal_promotion SET coupon_code = NULL, hour_from = 3, hour_to = 4 WHERE id = l_pr;
  ok('happy hour outside its hours -> none', NOONA_PRC_PKG.line_discount('ITEM', l_item, 1, 20, 'POS', NULL, TRUNC(SYSDATE) + 10 / 24) = 0);
  ok('happy hour inside its hours -> 5', NOONA_PRC_PKG.line_discount('ITEM', l_item, 1, 20, 'POS', NULL, TRUNC(SYSDATE) + 3.5 / 24) = 5);
  UPDATE sal_promotion SET status_code = 'PAUSED' WHERE id = l_pr;
  l_pr := NOONA_PRC_PKG.save_promotion('{"code":"FIX' || l_sfx || '","name":"سعر خاص","type":"FIXED_PRICE","value":8,"targets":[{"type":"ITEM","id":' || l_item || '}]}');
  ok('special price 8 instead of 10: 4 units -> 8', NOONA_PRC_PKG.line_discount('ITEM', l_item, 4, 10, 'SALES') = 8);
  l_pr := NOONA_PRC_PKG.save_promotion('{"code":"SPD' || l_sfx || '","name":"5% فوق 500","type":"SPEND_PCT","value":5,"minAmount":500,"maxDiscount":40}');
  ok('spend promotion below minimum -> none', NOONA_PRC_PKG.doc_promo('POS', 400) = '{}');
  ok('spend 5% on 600 -> 30', jnum(NOONA_PRC_PKG.doc_promo('POS', 600), 'discount') = 30);
  ok('spend promotion capped at 40', jnum(NOONA_PRC_PKG.doc_promo('POS', 2000), 'discount') = 40);
  -- سلة: سطر بعرض السعر الخاص (4 × 10 → خصم 8)، سطر يدوي بخصمه، ثم 5% على الإجمالي فوق 500
  l_s := NOONA_PRC_PKG.quote_cart('{"lines":[{"k":0,"id":' || l_item || ',"q":4,"p":10},{"k":1,"id":' || l_item || ',"q":60,"p":10,"man":"Y","disc":0}]}', 'POS');
  l_j := JSON_OBJECT_T.parse(l_s);
  ok('cart: auto line promotion applied', TREAT(l_j.get_array('lines').get(0) AS JSON_OBJECT_T).get_number('disc') = 8, l_s);
  ok('cart: manual line keeps its own discount', TREAT(l_j.get_array('lines').get(1) AS JSON_OBJECT_T).get_number('disc') = 0);
  ok('cart: spend promotion on total after line discounts (632 -> 31.6)', l_j.get_number('docDisc') = 31.6 AND l_j.get_number('total') = 600.4, l_s);
  ok('active promotions listed for POS', DBMS_LOB.INSTR(NOONA_PRC_PKG.active_promotions_json('POS'), 'SPD') = 0
     AND DBMS_LOB.INSTR(NOONA_PRC_PKG.active_promotions_json('POS'), '5% فوق 500') > 0);
  rejects('promotion without targets rejected', 'NOONA-PRC-042',
    'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_promotion(''{"code":"NT' || l_sfx || '","name":"x","type":"PCT_OFF","value":5,"targets":[]}''); END;');
  rejects('percent above 100 rejected', 'NOONA-PRC-032',
    'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_promotion(''{"code":"NP' || l_sfx || '","name":"x","type":"PCT_OFF","value":150,"targets":[{"type":"ALL_ITEMS"}]}''); END;');
  rejects('bad days of week rejected', 'NOONA-PRC-037',
    'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_promotion(''{"code":"ND' || l_sfx || '","name":"x","type":"PCT_OFF","value":5,"days":"8","targets":[{"type":"ALL_ITEMS"}]}''); END;');
  rejects('buy x get y without quantities rejected', 'NOONA-PRC-034',
    'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_promotion(''{"code":"NB' || l_sfx || '","name":"x","type":"BUY_X_GET_Y","targets":[{"type":"ALL_ITEMS"}]}''); END;');

  -- ---------------------------------------------------------------- الباقات
  SELECT MIN(c.item_id) INTO l_item2 FROM inv_item_company c JOIN inv_item i ON i.id = c.item_id
   WHERE c.company_id = NOONA_PRC_PKG.company AND c.item_id <> l_item AND i.status_code = 'ACTIVE' AND NVL(c.sale_price, 0) > 0;
  NOONA_PRC_PKG.set_price('ITEM', l_item, 60);
  UPDATE inv_item_company SET sale_price = 40 WHERE item_id = l_item2 AND company_id = NOONA_PRC_PKG.company;
  l_b := NOONA_PRC_PKG.save_bundle('{"code":"BND' || l_sfx || '","name":"باقة","method":"PCT_OFF","value":20,"channels":"POS",'
       || '"lines":[{"type":"ITEM","id":' || l_item || ',"qty":2},{"type":"ITEM","id":' || l_item2 || ',"qty":1}]}');
  ok('bundle 20% off list 160 = 128', NOONA_PRC_PKG.bundle_price(l_b) = 128);
  l_j := JSON_OBJECT_T.parse(NOONA_PRC_PKG.bundle_json(l_b));
  l_a := l_j.get_array('lines');
  l_sum := 0;
  FOR i IN 0 .. l_a.get_size - 1 LOOP l_sum := l_sum + TREAT(l_a.get(i) AS JSON_OBJECT_T).get_number('lineNet'); END LOOP;
  ok('component net prices add up to the bundle price', l_sum = 128 AND l_j.get_number('saving') = 32);
  ok('first component share = 128 x 120 / 160 = 96', TREAT(l_a.get(0) AS JSON_OBJECT_T).get_number('lineNet') = 96);
  ok('bundle listed for its channel only', DBMS_LOB.INSTR(NOONA_PRC_PKG.bundles_json('POS'), 'BND' || l_sfx) > 0
     AND DBMS_LOB.INSTR(NOONA_PRC_PKG.bundles_json('HIS'), 'BND' || l_sfx) = 0);
  rejects('fixed bundle price above components total rejected', 'NOONA-PRC-057',
    'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_bundle(''{"code":"BX' || l_sfx || '","name":"x","method":"FIXED_PRICE","value":500,'
    || '"lines":[{"type":"ITEM","id":' || l_item || '},{"type":"ITEM","id":' || l_item2 || '}]}''); END;');
  rejects('bundle with one component rejected', 'NOONA-PRC-056',
    'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_bundle(''{"code":"BY' || l_sfx || '","name":"x","method":"PCT_OFF","value":5,'
    || '"lines":[{"type":"ITEM","id":' || l_item || '}]}''); END;');
  IF l_svc IS NOT NULL THEN
    l_b := NOONA_PRC_PKG.save_bundle('{"code":"BHS' || l_sfx || '","name":"باقة فحص","method":"FIXED_PRICE","value":50,"channels":"HIS",'
         || '"lines":[{"type":"HIS_SERVICE","id":' || l_svc || '},{"type":"ITEM","id":' || l_item2 || '}]}');
    ok('mixed service + item bundle at fixed price', NOONA_PRC_PKG.bundle_price(l_b) = 50);
    ok('bundle html shows saving', DBMS_LOB.INSTR(NOONA_PRC_PKG.bundle_html(l_b), 'التوفير') > 0);
  END IF;

  -- ---------------------------------------------------------------- المستشفيات: العرض على الخدمة النقدية وباقة الزيارة
  DECLARE
    l_visit NUMBER; l_svc2 NUMBER; l_o NUMBER; l_d NUMBER; l_g NUMBER; l_k NUMBER;
  BEGIN
    SELECT MIN(v.id) INTO l_visit FROM his_visit v WHERE v.company_id = NOONA_PRC_PKG.company AND v.status_code = 'OPEN' AND v.bill_to = 'CASH';
    SELECT MIN(id) INTO l_svc2 FROM his_service WHERE company_id = NOONA_PRC_PKG.company AND status_code = 'ACTIVE' AND id <> l_svc AND price > 0;
    IF l_visit IS NOT NULL AND l_svc2 IS NOT NULL THEN
      UPDATE sal_promotion SET status_code = 'PAUSED' WHERE company_id = NOONA_PRC_PKG.company AND status_code = 'ACTIVE';
      l_pr := NOONA_PRC_PKG.save_promotion('{"code":"HPR' || l_sfx || '","name":"خصم الكشف","type":"PCT_OFF","value":25,"channels":"HIS",'
            || '"targets":[{"type":"HIS_SERVICE","id":' || l_svc2 || '}]}');
      l_o := NOONA_HIS_PKG.add_order(l_visit, l_svc2, 2);
      SELECT gross_amount, discount_amount INTO l_g, l_d FROM his_order WHERE id = l_o;
      ok('HIS cash order gets 25% promotion', l_d = ROUND(l_g * 0.25, 2) AND l_d > 0, l_g || ' / ' || l_d);
      UPDATE sal_promotion SET status_code = 'PAUSED' WHERE id = l_pr;
      UPDATE his_service SET price = 100 WHERE id = l_svc2;
      UPDATE his_service SET price = 300 WHERE id = l_svc;
      l_b := NOONA_PRC_PKG.save_bundle('{"code":"HB' || l_sfx || '","name":"فحص شامل","method":"FIXED_PRICE","value":320,"channels":"HIS",'
           || '"lines":[{"type":"HIS_SERVICE","id":' || l_svc || '},{"type":"HIS_SERVICE","id":' || l_svc2 || '}]}');
      l_k := NOONA_HIS_PKG.add_bundle(l_visit, l_b);
      SELECT SUM(gross_amount - discount_amount), COUNT(*) INTO l_g, l_n FROM his_order WHERE visit_id = l_visit AND bundle_id = l_b;
      ok('HIS bundle adds its services at the bundle price', l_k = 2 AND l_n = 2 AND l_g = 320, l_k || ' ' || l_n || ' ' || l_g);
      rejects('item in a visit bundle rejected', 'NOONA-HIS-058', 'DECLARE n NUMBER; BEGIN n := NOONA_HIS_PKG.add_bundle(' || l_visit || ', '
        || NOONA_PRC_PKG.save_bundle('{"code":"HX' || l_sfx || '","name":"x","method":"PCT_OFF","value":5,"lines":[{"type":"HIS_SERVICE","id":' || l_svc
        || '},{"type":"ITEM","id":' || l_item2 || '}]}') || '); END;');
    ELSE
      ok('open cash visit exists for HIS checks (skipped)', TRUE);
    END IF;
  END;

  -- ---------------------------------------------------------------- خدمة السيارات: العرض على الخدمة وباقة أمر الإصلاح
  DECLARE
    l_job NUMBER; l_as NUMBER; l_as2 NUMBER; l_ln NUMBER; l_d NUMBER; l_k NUMBER; l_net NUMBER;
  BEGIN
    SELECT MIN(id) INTO l_job FROM aut_job_card WHERE company_id = NOONA_PRC_PKG.company AND status_code IN ('OPEN', 'IN_PROGRESS')
       AND payer_type = 'CUSTOMER';
    SELECT MIN(id), MAX(id) INTO l_as, l_as2 FROM aut_service WHERE company_id = NOONA_PRC_PKG.company AND is_active = 'Y' AND price > 0;
    IF l_job IS NOT NULL AND l_as <> l_as2 THEN
      UPDATE sal_promotion SET status_code = 'PAUSED' WHERE company_id = NOONA_PRC_PKG.company AND status_code = 'ACTIVE';
      l_pr := NOONA_PRC_PKG.save_promotion('{"code":"APR' || l_sfx || '","name":"خصم الصيانة","type":"AMOUNT_OFF","value":20,"channels":"AUT",'
            || '"targets":[{"type":"ALL_AUT"}]}');
      l_ln := NOONA_AUT_PKG.add_service(l_job, l_as);
      SELECT discount_amount INTO l_d FROM aut_job_line WHERE id = l_ln;
      ok('AUT customer service line gets promotion 20', l_d = 20, l_d);
      UPDATE sal_promotion SET status_code = 'PAUSED' WHERE id = l_pr;
      l_b := NOONA_PRC_PKG.save_bundle('{"code":"AB' || l_sfx || '","name":"باقة الصيانة","method":"PCT_OFF","value":10,"channels":"AUT",'
           || '"lines":[{"type":"AUT_SERVICE","id":' || l_as || '},{"type":"AUT_SERVICE","id":' || l_as2 || '}]}');
      l_k := NOONA_AUT_PKG.add_bundle(l_job, l_b);
      SELECT SUM(quantity * unit_price - NVL(discount_amount, 0)) INTO l_net FROM aut_job_line WHERE job_card_id = l_job AND notes = 'باقة: باقة الصيانة';
      ok('AUT bundle lines at bundle price', l_k = 2 AND ABS(l_net - NOONA_PRC_PKG.bundle_price(l_b)) < 0.01, l_k || ' ' || l_net);
    ELSE
      ok('open customer job card exists for AUT checks (skipped)', TRUE);
    END IF;
  END;

  -- ---------------------------------------------------------------- شروط العروض: أيام الشهر، الاستثناء، الفروع، العملاء، حدود الاستخدام
  DECLARE
    l_pm   NUMBER;
    l_dd   NUMBER := TO_NUMBER(TO_CHAR(SYSDATE, 'DD'));
    l_other VARCHAR2(10) := TO_CHAR(CASE WHEN TO_NUMBER(TO_CHAR(SYSDATE, 'DD')) = 1 THEN 2 ELSE 1 END);
    l_walk NUMBER := NOONA_SAL_PKG.walk_in_customer;
    l_c1   NUMBER;
    l_c2   NUMBER;
    l_br1  NUMBER;
    l_br2  NUMBER;
    l_pr0  NUMBER;
    FUNCTION hit(p_branch NUMBER DEFAULT NULL) RETURN BOOLEAN IS
      l CLOB := NOONA_PRC_PKG.line_promo('ITEM', l_item, 1, 100, 'SALES', NULL, SYSDATE, p_branch);
    BEGIN
      RETURN l <> '{}' AND JSON_VALUE(l, '$.promoId' RETURNING NUMBER) = l_pm;
    END hit;
    PROCEDURE upd(p_sql VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p_sql USING l_pm; END upd;
  BEGIN
    ok('in_ranges 3 in 1-5,25-31', NOONA_PRC_PKG.in_ranges('1-5,25-31', 3) = 'Y');
    ok('in_ranges 10 not in 1-5,25-31', NOONA_PRC_PKG.in_ranges('1-5,25-31', 10) = 'N');
    ok('in_ranges single day 31', NOONA_PRC_PKG.in_ranges('15,31', 31) = 'Y');
    rejects('bad days of month rejected', 'NOONA-PRC-047',
      'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_promotion(''{"code":"BD' || l_sfx || '","name":"x","type":"PCT_OFF","value":5,'
      || '"daysOfMonth":"1-40","targets":[{"type":"ALL_ITEMS"}]}''); END;');
    rejects('bad excluded date rejected', 'NOONA-PRC-048',
      'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_promotion(''{"code":"BX' || l_sfx || '","name":"x","type":"PCT_OFF","value":5,'
      || '"excludedDates":"2026-02-30","targets":[{"type":"ALL_ITEMS"}]}''); END;');
    rejects('bad customer scope rejected', 'NOONA-PRC-050',
      'DECLARE n NUMBER; BEGIN n := NOONA_PRC_PKG.save_promotion(''{"code":"BC' || l_sfx || '","name":"x","type":"PCT_OFF","value":5,'
      || '"customerScope":"VIP","targets":[{"type":"ALL_ITEMS"}]}''); END;');

    l_pm := NOONA_PRC_PKG.save_promotion('{"code":"RULE' || l_sfx || '","name":"عرض بشروط","type":"PCT_OFF","value":60,"priority":1,'
          || '"channels":"SALES","daysOfMonth":"' || l_dd || '","targets":[{"type":"ITEM","id":' || l_item || '}]}');
    NOONA_PRC_PKG.set_customer(NULL);
    ok('promotion on today''s day of month applies', hit);
    ok('promotion text shows days of month', INSTR(NOONA_PRC_PKG.promotion_text(l_pm), 'أيام الشهر') > 0);
    upd('UPDATE sal_promotion SET days_of_month = ''' || l_other || ''' WHERE id = :1');
    ok('promotion on another day of month does not apply', NOT hit);
    upd('UPDATE sal_promotion SET days_of_month = NULL, excluded_dates = ''2001-01-01,' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ''' WHERE id = :1');
    ok('excluded date (holiday) blocks the promotion', NOT hit);
    upd('UPDATE sal_promotion SET excluded_dates = ''2001-01-01'' WHERE id = :1');
    ok('other excluded date does not block', hit);

    SELECT MIN(id), MAX(id) INTO l_br1, l_br2 FROM org_branch WHERE company_id = NOONA_PRC_PKG.company;
    upd('UPDATE sal_promotion SET branch_ids = ''' || l_br1 || ''' WHERE id = :1');
    ok('branch list: listed branch applies', hit(l_br1));
    IF l_br2 <> l_br1 THEN
      ok('branch list: other branch does not apply', NOT hit(l_br2));
    ELSE
      ok('branch list: other branch (single branch company, skipped)', TRUE);
    END IF;
    upd('UPDATE sal_promotion SET branch_ids = NULL WHERE id = :1');

    -- العملاء
    SELECT MIN(a.id), MAX(a.id) INTO l_c1, l_c2 FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
     WHERE a.company_id = NOONA_PRC_PKG.company AND NVL(c.is_walk_in, 'N') = 'N' AND a.status_code = 'ACTIVE';
    upd('UPDATE sal_promotion SET customer_scope = ''REGISTERED'' WHERE id = :1');
    NOONA_PRC_PKG.set_customer(NULL);
    ok('registered-only: unknown customer excluded', NOT hit);
    NOONA_PRC_PKG.set_customer(l_walk);
    ok('registered-only: walk-in customer excluded', NOT hit);
    NOONA_PRC_PKG.set_customer(l_c1);
    ok('registered-only: registered customer gets it', l_c1 IS NOT NULL AND hit);
    NOONA_PRC_PKG.add_promotion_customer(l_pm, l_c1);
    SELECT customer_scope INTO l_s FROM sal_promotion WHERE id = l_pm;
    ok('adding a customer switches scope to the list', l_s = 'LIST');
    ok('listed customer gets it', hit);
    IF l_c2 <> l_c1 THEN
      NOONA_PRC_PKG.set_customer(l_c2);
      ok('customer not in list excluded', NOT hit);
    ELSE
      ok('customer not in list (one customer, skipped)', TRUE);
    END IF;
    ok('customer names listed', NOONA_PRC_PKG.promotion_customers(l_pm) IS NOT NULL);
    rejects('same customer twice rejected', 'NOONA-PRC-045',
      'BEGIN NOONA_PRC_PKG.add_promotion_customer(' || l_pm || ', ' || l_c1 || '); END;');
    NOONA_PRC_PKG.remove_promotion_customer(l_pm, l_c1);
    NOONA_PRC_PKG.set_customer(l_c1);
    ok('removed customer excluded', NOT hit);

    -- حدود الاستخدام: مرة واحدة كلياً
    upd('UPDATE sal_promotion SET customer_scope = ''ALL'', customer_ids = NULL, max_uses = 1 WHERE id = :1');
    NOONA_PRC_PKG.begin_doc('SALES', 'TEST_DOC', 1, l_c1);
    l_pr0 := NOONA_PRC_PKG.line_discount('ITEM', l_item, 1, 100, 'SALES');
    NOONA_PRC_PKG.end_doc;
    ok('first document uses the promotion (60)', l_pr0 = 60, l_pr0);
    ok('use recorded', NOONA_PRC_PKG.uses_of(l_pm) = 1);
    NOONA_PRC_PKG.set_customer(l_c1);
    ok('limit reached: second document gets nothing', NOT hit);
    NOONA_PRC_PKG.begin_doc('SALES', 'TEST_DOC', 1, l_c1);
    ok('re-saving the same document keeps its promotion', hit);
    NOONA_PRC_PKG.end_doc;
    ok('re-save does not double count', NOONA_PRC_PKG.uses_of(l_pm) = 1);
    NOONA_PRC_PKG.release_uses('TEST_DOC', 1);
    NOONA_PRC_PKG.set_customer(l_c1);
    ok('cancelled document frees the use', hit);

    -- لكل عميل مرة
    upd('UPDATE sal_promotion SET max_uses = NULL, max_uses_per_customer = 1 WHERE id = :1');
    NOONA_PRC_PKG.begin_doc('SALES', 'TEST_DOC', 2, l_c1);
    l_pr0 := NOONA_PRC_PKG.line_discount('ITEM', l_item, 1, 100, 'SALES');
    NOONA_PRC_PKG.end_doc;
    NOONA_PRC_PKG.set_customer(l_c1);
    ok('per-customer limit: same customer blocked', NOT hit);
    IF l_c2 <> l_c1 THEN
      NOONA_PRC_PKG.set_customer(l_c2);
      ok('per-customer limit: another customer still gets it', hit);
    ELSE
      ok('per-customer limit: another customer (skipped)', TRUE);
    END IF;
    NOONA_PRC_PKG.set_customer(l_walk);
    ok('per-customer limit needs a registered customer', NOT hit);

    -- عميل جديد (أول شراء)
    upd('UPDATE sal_promotion SET max_uses_per_customer = NULL, customer_scope = ''NEW'' WHERE id = :1');
    SELECT MIN(a.id) INTO l_c2 FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
     WHERE a.company_id = NOONA_PRC_PKG.company AND NVL(c.is_walk_in, 'N') = 'N'
       AND EXISTS (SELECT 1 FROM sal_invoice i WHERE i.customer_account_id = a.id AND i.status_code NOT IN ('DRAFT', 'CANCELLED'));
    IF l_c2 IS NOT NULL THEN
      NOONA_PRC_PKG.set_customer(l_c2);
      ok('first-purchase promotion: customer with invoices excluded', NOT hit);
    ELSE
      ok('first-purchase promotion (no invoiced customer, skipped)', TRUE);
    END IF;
    NOONA_PRC_PKG.set_customer(NULL);
    UPDATE sal_promotion SET status_code = 'CANCELLED' WHERE id = l_pm;
  END;

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('========== pricing: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('========== pricing: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
