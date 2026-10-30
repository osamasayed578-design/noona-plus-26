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

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('========== pricing: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('========== pricing: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
